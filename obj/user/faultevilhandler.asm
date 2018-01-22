
obj/user/faultevilhandler.debug:     file format elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 f9 0a 00 00       	call   800b40 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 20 00 10 f0       	push   $0xf0100020
  80004f:	6a 00                	push   $0x0
  800051:	e8 35 0c 00 00       	call   800c8b <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	57                   	push   %edi
  800069:	56                   	push   %esi
  80006a:	53                   	push   %ebx
  80006b:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80006e:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800075:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  800078:	e8 85 0a 00 00       	call   800b02 <sys_getenvid>
  80007d:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  80007f:	83 ec 08             	sub    $0x8,%esp
  800082:	50                   	push   %eax
  800083:	68 80 1e 80 00       	push   $0x801e80
  800088:	e8 2b 01 00 00       	call   8001b8 <cprintf>
  80008d:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  800093:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800098:	83 c4 10             	add    $0x10,%esp
  80009b:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000a0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  8000a5:	89 c1                	mov    %eax,%ecx
  8000a7:	c1 e1 07             	shl    $0x7,%ecx
  8000aa:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  8000b1:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  8000b4:	39 cb                	cmp    %ecx,%ebx
  8000b6:	0f 44 fa             	cmove  %edx,%edi
  8000b9:	b9 01 00 00 00       	mov    $0x1,%ecx
  8000be:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000c1:	83 c0 01             	add    $0x1,%eax
  8000c4:	81 c2 84 00 00 00    	add    $0x84,%edx
  8000ca:	3d 00 04 00 00       	cmp    $0x400,%eax
  8000cf:	75 d4                	jne    8000a5 <libmain+0x40>
  8000d1:	89 f0                	mov    %esi,%eax
  8000d3:	84 c0                	test   %al,%al
  8000d5:	74 06                	je     8000dd <libmain+0x78>
  8000d7:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000dd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000e1:	7e 0a                	jle    8000ed <libmain+0x88>
		binaryname = argv[0];
  8000e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000e6:	8b 00                	mov    (%eax),%eax
  8000e8:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ed:	83 ec 08             	sub    $0x8,%esp
  8000f0:	ff 75 0c             	pushl  0xc(%ebp)
  8000f3:	ff 75 08             	pushl  0x8(%ebp)
  8000f6:	e8 38 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000fb:	e8 0b 00 00 00       	call   80010b <exit>
}
  800100:	83 c4 10             	add    $0x10,%esp
  800103:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800106:	5b                   	pop    %ebx
  800107:	5e                   	pop    %esi
  800108:	5f                   	pop    %edi
  800109:	5d                   	pop    %ebp
  80010a:	c3                   	ret    

0080010b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800111:	e8 06 0e 00 00       	call   800f1c <close_all>
	sys_env_destroy(0);
  800116:	83 ec 0c             	sub    $0xc,%esp
  800119:	6a 00                	push   $0x0
  80011b:	e8 a1 09 00 00       	call   800ac1 <sys_env_destroy>
}
  800120:	83 c4 10             	add    $0x10,%esp
  800123:	c9                   	leave  
  800124:	c3                   	ret    

00800125 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	53                   	push   %ebx
  800129:	83 ec 04             	sub    $0x4,%esp
  80012c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012f:	8b 13                	mov    (%ebx),%edx
  800131:	8d 42 01             	lea    0x1(%edx),%eax
  800134:	89 03                	mov    %eax,(%ebx)
  800136:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800139:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80013d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800142:	75 1a                	jne    80015e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800144:	83 ec 08             	sub    $0x8,%esp
  800147:	68 ff 00 00 00       	push   $0xff
  80014c:	8d 43 08             	lea    0x8(%ebx),%eax
  80014f:	50                   	push   %eax
  800150:	e8 2f 09 00 00       	call   800a84 <sys_cputs>
		b->idx = 0;
  800155:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80015e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800162:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800165:	c9                   	leave  
  800166:	c3                   	ret    

00800167 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800170:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800177:	00 00 00 
	b.cnt = 0;
  80017a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800181:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800184:	ff 75 0c             	pushl  0xc(%ebp)
  800187:	ff 75 08             	pushl  0x8(%ebp)
  80018a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800190:	50                   	push   %eax
  800191:	68 25 01 80 00       	push   $0x800125
  800196:	e8 54 01 00 00       	call   8002ef <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80019b:	83 c4 08             	add    $0x8,%esp
  80019e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001aa:	50                   	push   %eax
  8001ab:	e8 d4 08 00 00       	call   800a84 <sys_cputs>

	return b.cnt;
}
  8001b0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b6:	c9                   	leave  
  8001b7:	c3                   	ret    

008001b8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001be:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c1:	50                   	push   %eax
  8001c2:	ff 75 08             	pushl  0x8(%ebp)
  8001c5:	e8 9d ff ff ff       	call   800167 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ca:	c9                   	leave  
  8001cb:	c3                   	ret    

008001cc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	57                   	push   %edi
  8001d0:	56                   	push   %esi
  8001d1:	53                   	push   %ebx
  8001d2:	83 ec 1c             	sub    $0x1c,%esp
  8001d5:	89 c7                	mov    %eax,%edi
  8001d7:	89 d6                	mov    %edx,%esi
  8001d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ed:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001f0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001f3:	39 d3                	cmp    %edx,%ebx
  8001f5:	72 05                	jb     8001fc <printnum+0x30>
  8001f7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001fa:	77 45                	ja     800241 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fc:	83 ec 0c             	sub    $0xc,%esp
  8001ff:	ff 75 18             	pushl  0x18(%ebp)
  800202:	8b 45 14             	mov    0x14(%ebp),%eax
  800205:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800208:	53                   	push   %ebx
  800209:	ff 75 10             	pushl  0x10(%ebp)
  80020c:	83 ec 08             	sub    $0x8,%esp
  80020f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800212:	ff 75 e0             	pushl  -0x20(%ebp)
  800215:	ff 75 dc             	pushl  -0x24(%ebp)
  800218:	ff 75 d8             	pushl  -0x28(%ebp)
  80021b:	e8 c0 19 00 00       	call   801be0 <__udivdi3>
  800220:	83 c4 18             	add    $0x18,%esp
  800223:	52                   	push   %edx
  800224:	50                   	push   %eax
  800225:	89 f2                	mov    %esi,%edx
  800227:	89 f8                	mov    %edi,%eax
  800229:	e8 9e ff ff ff       	call   8001cc <printnum>
  80022e:	83 c4 20             	add    $0x20,%esp
  800231:	eb 18                	jmp    80024b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800233:	83 ec 08             	sub    $0x8,%esp
  800236:	56                   	push   %esi
  800237:	ff 75 18             	pushl  0x18(%ebp)
  80023a:	ff d7                	call   *%edi
  80023c:	83 c4 10             	add    $0x10,%esp
  80023f:	eb 03                	jmp    800244 <printnum+0x78>
  800241:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800244:	83 eb 01             	sub    $0x1,%ebx
  800247:	85 db                	test   %ebx,%ebx
  800249:	7f e8                	jg     800233 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80024b:	83 ec 08             	sub    $0x8,%esp
  80024e:	56                   	push   %esi
  80024f:	83 ec 04             	sub    $0x4,%esp
  800252:	ff 75 e4             	pushl  -0x1c(%ebp)
  800255:	ff 75 e0             	pushl  -0x20(%ebp)
  800258:	ff 75 dc             	pushl  -0x24(%ebp)
  80025b:	ff 75 d8             	pushl  -0x28(%ebp)
  80025e:	e8 ad 1a 00 00       	call   801d10 <__umoddi3>
  800263:	83 c4 14             	add    $0x14,%esp
  800266:	0f be 80 a9 1e 80 00 	movsbl 0x801ea9(%eax),%eax
  80026d:	50                   	push   %eax
  80026e:	ff d7                	call   *%edi
}
  800270:	83 c4 10             	add    $0x10,%esp
  800273:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800276:	5b                   	pop    %ebx
  800277:	5e                   	pop    %esi
  800278:	5f                   	pop    %edi
  800279:	5d                   	pop    %ebp
  80027a:	c3                   	ret    

0080027b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80027e:	83 fa 01             	cmp    $0x1,%edx
  800281:	7e 0e                	jle    800291 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800283:	8b 10                	mov    (%eax),%edx
  800285:	8d 4a 08             	lea    0x8(%edx),%ecx
  800288:	89 08                	mov    %ecx,(%eax)
  80028a:	8b 02                	mov    (%edx),%eax
  80028c:	8b 52 04             	mov    0x4(%edx),%edx
  80028f:	eb 22                	jmp    8002b3 <getuint+0x38>
	else if (lflag)
  800291:	85 d2                	test   %edx,%edx
  800293:	74 10                	je     8002a5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800295:	8b 10                	mov    (%eax),%edx
  800297:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029a:	89 08                	mov    %ecx,(%eax)
  80029c:	8b 02                	mov    (%edx),%eax
  80029e:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a3:	eb 0e                	jmp    8002b3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a5:	8b 10                	mov    (%eax),%edx
  8002a7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002aa:	89 08                	mov    %ecx,(%eax)
  8002ac:	8b 02                	mov    (%edx),%eax
  8002ae:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002bb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002bf:	8b 10                	mov    (%eax),%edx
  8002c1:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c4:	73 0a                	jae    8002d0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c9:	89 08                	mov    %ecx,(%eax)
  8002cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ce:	88 02                	mov    %al,(%edx)
}
  8002d0:	5d                   	pop    %ebp
  8002d1:	c3                   	ret    

008002d2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002db:	50                   	push   %eax
  8002dc:	ff 75 10             	pushl  0x10(%ebp)
  8002df:	ff 75 0c             	pushl  0xc(%ebp)
  8002e2:	ff 75 08             	pushl  0x8(%ebp)
  8002e5:	e8 05 00 00 00       	call   8002ef <vprintfmt>
	va_end(ap);
}
  8002ea:	83 c4 10             	add    $0x10,%esp
  8002ed:	c9                   	leave  
  8002ee:	c3                   	ret    

008002ef <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	57                   	push   %edi
  8002f3:	56                   	push   %esi
  8002f4:	53                   	push   %ebx
  8002f5:	83 ec 2c             	sub    $0x2c,%esp
  8002f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8002fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fe:	8b 7d 10             	mov    0x10(%ebp),%edi
  800301:	eb 12                	jmp    800315 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800303:	85 c0                	test   %eax,%eax
  800305:	0f 84 89 03 00 00    	je     800694 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80030b:	83 ec 08             	sub    $0x8,%esp
  80030e:	53                   	push   %ebx
  80030f:	50                   	push   %eax
  800310:	ff d6                	call   *%esi
  800312:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800315:	83 c7 01             	add    $0x1,%edi
  800318:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80031c:	83 f8 25             	cmp    $0x25,%eax
  80031f:	75 e2                	jne    800303 <vprintfmt+0x14>
  800321:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800325:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80032c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800333:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80033a:	ba 00 00 00 00       	mov    $0x0,%edx
  80033f:	eb 07                	jmp    800348 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800341:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800344:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800348:	8d 47 01             	lea    0x1(%edi),%eax
  80034b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034e:	0f b6 07             	movzbl (%edi),%eax
  800351:	0f b6 c8             	movzbl %al,%ecx
  800354:	83 e8 23             	sub    $0x23,%eax
  800357:	3c 55                	cmp    $0x55,%al
  800359:	0f 87 1a 03 00 00    	ja     800679 <vprintfmt+0x38a>
  80035f:	0f b6 c0             	movzbl %al,%eax
  800362:	ff 24 85 e0 1f 80 00 	jmp    *0x801fe0(,%eax,4)
  800369:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80036c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800370:	eb d6                	jmp    800348 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800372:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800375:	b8 00 00 00 00       	mov    $0x0,%eax
  80037a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80037d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800380:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800384:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800387:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80038a:	83 fa 09             	cmp    $0x9,%edx
  80038d:	77 39                	ja     8003c8 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800392:	eb e9                	jmp    80037d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800394:	8b 45 14             	mov    0x14(%ebp),%eax
  800397:	8d 48 04             	lea    0x4(%eax),%ecx
  80039a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80039d:	8b 00                	mov    (%eax),%eax
  80039f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a5:	eb 27                	jmp    8003ce <vprintfmt+0xdf>
  8003a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003aa:	85 c0                	test   %eax,%eax
  8003ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b1:	0f 49 c8             	cmovns %eax,%ecx
  8003b4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ba:	eb 8c                	jmp    800348 <vprintfmt+0x59>
  8003bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003bf:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c6:	eb 80                	jmp    800348 <vprintfmt+0x59>
  8003c8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003cb:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003ce:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d2:	0f 89 70 ff ff ff    	jns    800348 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003d8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003de:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e5:	e9 5e ff ff ff       	jmp    800348 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ea:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003f0:	e9 53 ff ff ff       	jmp    800348 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f8:	8d 50 04             	lea    0x4(%eax),%edx
  8003fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fe:	83 ec 08             	sub    $0x8,%esp
  800401:	53                   	push   %ebx
  800402:	ff 30                	pushl  (%eax)
  800404:	ff d6                	call   *%esi
			break;
  800406:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80040c:	e9 04 ff ff ff       	jmp    800315 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800411:	8b 45 14             	mov    0x14(%ebp),%eax
  800414:	8d 50 04             	lea    0x4(%eax),%edx
  800417:	89 55 14             	mov    %edx,0x14(%ebp)
  80041a:	8b 00                	mov    (%eax),%eax
  80041c:	99                   	cltd   
  80041d:	31 d0                	xor    %edx,%eax
  80041f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800421:	83 f8 0f             	cmp    $0xf,%eax
  800424:	7f 0b                	jg     800431 <vprintfmt+0x142>
  800426:	8b 14 85 40 21 80 00 	mov    0x802140(,%eax,4),%edx
  80042d:	85 d2                	test   %edx,%edx
  80042f:	75 18                	jne    800449 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800431:	50                   	push   %eax
  800432:	68 c1 1e 80 00       	push   $0x801ec1
  800437:	53                   	push   %ebx
  800438:	56                   	push   %esi
  800439:	e8 94 fe ff ff       	call   8002d2 <printfmt>
  80043e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800441:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800444:	e9 cc fe ff ff       	jmp    800315 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800449:	52                   	push   %edx
  80044a:	68 71 22 80 00       	push   $0x802271
  80044f:	53                   	push   %ebx
  800450:	56                   	push   %esi
  800451:	e8 7c fe ff ff       	call   8002d2 <printfmt>
  800456:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800459:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80045c:	e9 b4 fe ff ff       	jmp    800315 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800461:	8b 45 14             	mov    0x14(%ebp),%eax
  800464:	8d 50 04             	lea    0x4(%eax),%edx
  800467:	89 55 14             	mov    %edx,0x14(%ebp)
  80046a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80046c:	85 ff                	test   %edi,%edi
  80046e:	b8 ba 1e 80 00       	mov    $0x801eba,%eax
  800473:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800476:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80047a:	0f 8e 94 00 00 00    	jle    800514 <vprintfmt+0x225>
  800480:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800484:	0f 84 98 00 00 00    	je     800522 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80048a:	83 ec 08             	sub    $0x8,%esp
  80048d:	ff 75 d0             	pushl  -0x30(%ebp)
  800490:	57                   	push   %edi
  800491:	e8 86 02 00 00       	call   80071c <strnlen>
  800496:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800499:	29 c1                	sub    %eax,%ecx
  80049b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80049e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004a1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ab:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ad:	eb 0f                	jmp    8004be <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	53                   	push   %ebx
  8004b3:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b8:	83 ef 01             	sub    $0x1,%edi
  8004bb:	83 c4 10             	add    $0x10,%esp
  8004be:	85 ff                	test   %edi,%edi
  8004c0:	7f ed                	jg     8004af <vprintfmt+0x1c0>
  8004c2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004c5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004c8:	85 c9                	test   %ecx,%ecx
  8004ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cf:	0f 49 c1             	cmovns %ecx,%eax
  8004d2:	29 c1                	sub    %eax,%ecx
  8004d4:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004da:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004dd:	89 cb                	mov    %ecx,%ebx
  8004df:	eb 4d                	jmp    80052e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004e1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e5:	74 1b                	je     800502 <vprintfmt+0x213>
  8004e7:	0f be c0             	movsbl %al,%eax
  8004ea:	83 e8 20             	sub    $0x20,%eax
  8004ed:	83 f8 5e             	cmp    $0x5e,%eax
  8004f0:	76 10                	jbe    800502 <vprintfmt+0x213>
					putch('?', putdat);
  8004f2:	83 ec 08             	sub    $0x8,%esp
  8004f5:	ff 75 0c             	pushl  0xc(%ebp)
  8004f8:	6a 3f                	push   $0x3f
  8004fa:	ff 55 08             	call   *0x8(%ebp)
  8004fd:	83 c4 10             	add    $0x10,%esp
  800500:	eb 0d                	jmp    80050f <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800502:	83 ec 08             	sub    $0x8,%esp
  800505:	ff 75 0c             	pushl  0xc(%ebp)
  800508:	52                   	push   %edx
  800509:	ff 55 08             	call   *0x8(%ebp)
  80050c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050f:	83 eb 01             	sub    $0x1,%ebx
  800512:	eb 1a                	jmp    80052e <vprintfmt+0x23f>
  800514:	89 75 08             	mov    %esi,0x8(%ebp)
  800517:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80051a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800520:	eb 0c                	jmp    80052e <vprintfmt+0x23f>
  800522:	89 75 08             	mov    %esi,0x8(%ebp)
  800525:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800528:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80052b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80052e:	83 c7 01             	add    $0x1,%edi
  800531:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800535:	0f be d0             	movsbl %al,%edx
  800538:	85 d2                	test   %edx,%edx
  80053a:	74 23                	je     80055f <vprintfmt+0x270>
  80053c:	85 f6                	test   %esi,%esi
  80053e:	78 a1                	js     8004e1 <vprintfmt+0x1f2>
  800540:	83 ee 01             	sub    $0x1,%esi
  800543:	79 9c                	jns    8004e1 <vprintfmt+0x1f2>
  800545:	89 df                	mov    %ebx,%edi
  800547:	8b 75 08             	mov    0x8(%ebp),%esi
  80054a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80054d:	eb 18                	jmp    800567 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054f:	83 ec 08             	sub    $0x8,%esp
  800552:	53                   	push   %ebx
  800553:	6a 20                	push   $0x20
  800555:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800557:	83 ef 01             	sub    $0x1,%edi
  80055a:	83 c4 10             	add    $0x10,%esp
  80055d:	eb 08                	jmp    800567 <vprintfmt+0x278>
  80055f:	89 df                	mov    %ebx,%edi
  800561:	8b 75 08             	mov    0x8(%ebp),%esi
  800564:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800567:	85 ff                	test   %edi,%edi
  800569:	7f e4                	jg     80054f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056e:	e9 a2 fd ff ff       	jmp    800315 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800573:	83 fa 01             	cmp    $0x1,%edx
  800576:	7e 16                	jle    80058e <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8d 50 08             	lea    0x8(%eax),%edx
  80057e:	89 55 14             	mov    %edx,0x14(%ebp)
  800581:	8b 50 04             	mov    0x4(%eax),%edx
  800584:	8b 00                	mov    (%eax),%eax
  800586:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800589:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058c:	eb 32                	jmp    8005c0 <vprintfmt+0x2d1>
	else if (lflag)
  80058e:	85 d2                	test   %edx,%edx
  800590:	74 18                	je     8005aa <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8d 50 04             	lea    0x4(%eax),%edx
  800598:	89 55 14             	mov    %edx,0x14(%ebp)
  80059b:	8b 00                	mov    (%eax),%eax
  80059d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a0:	89 c1                	mov    %eax,%ecx
  8005a2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a8:	eb 16                	jmp    8005c0 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ad:	8d 50 04             	lea    0x4(%eax),%edx
  8005b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b3:	8b 00                	mov    (%eax),%eax
  8005b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b8:	89 c1                	mov    %eax,%ecx
  8005ba:	c1 f9 1f             	sar    $0x1f,%ecx
  8005bd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005c3:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005cb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005cf:	79 74                	jns    800645 <vprintfmt+0x356>
				putch('-', putdat);
  8005d1:	83 ec 08             	sub    $0x8,%esp
  8005d4:	53                   	push   %ebx
  8005d5:	6a 2d                	push   $0x2d
  8005d7:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005dc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005df:	f7 d8                	neg    %eax
  8005e1:	83 d2 00             	adc    $0x0,%edx
  8005e4:	f7 da                	neg    %edx
  8005e6:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005e9:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005ee:	eb 55                	jmp    800645 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005f0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f3:	e8 83 fc ff ff       	call   80027b <getuint>
			base = 10;
  8005f8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005fd:	eb 46                	jmp    800645 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800602:	e8 74 fc ff ff       	call   80027b <getuint>
			base = 8;
  800607:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80060c:	eb 37                	jmp    800645 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	6a 30                	push   $0x30
  800614:	ff d6                	call   *%esi
			putch('x', putdat);
  800616:	83 c4 08             	add    $0x8,%esp
  800619:	53                   	push   %ebx
  80061a:	6a 78                	push   $0x78
  80061c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80061e:	8b 45 14             	mov    0x14(%ebp),%eax
  800621:	8d 50 04             	lea    0x4(%eax),%edx
  800624:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800627:	8b 00                	mov    (%eax),%eax
  800629:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80062e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800631:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800636:	eb 0d                	jmp    800645 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800638:	8d 45 14             	lea    0x14(%ebp),%eax
  80063b:	e8 3b fc ff ff       	call   80027b <getuint>
			base = 16;
  800640:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800645:	83 ec 0c             	sub    $0xc,%esp
  800648:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80064c:	57                   	push   %edi
  80064d:	ff 75 e0             	pushl  -0x20(%ebp)
  800650:	51                   	push   %ecx
  800651:	52                   	push   %edx
  800652:	50                   	push   %eax
  800653:	89 da                	mov    %ebx,%edx
  800655:	89 f0                	mov    %esi,%eax
  800657:	e8 70 fb ff ff       	call   8001cc <printnum>
			break;
  80065c:	83 c4 20             	add    $0x20,%esp
  80065f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800662:	e9 ae fc ff ff       	jmp    800315 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	53                   	push   %ebx
  80066b:	51                   	push   %ecx
  80066c:	ff d6                	call   *%esi
			break;
  80066e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800671:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800674:	e9 9c fc ff ff       	jmp    800315 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800679:	83 ec 08             	sub    $0x8,%esp
  80067c:	53                   	push   %ebx
  80067d:	6a 25                	push   $0x25
  80067f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800681:	83 c4 10             	add    $0x10,%esp
  800684:	eb 03                	jmp    800689 <vprintfmt+0x39a>
  800686:	83 ef 01             	sub    $0x1,%edi
  800689:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80068d:	75 f7                	jne    800686 <vprintfmt+0x397>
  80068f:	e9 81 fc ff ff       	jmp    800315 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800694:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800697:	5b                   	pop    %ebx
  800698:	5e                   	pop    %esi
  800699:	5f                   	pop    %edi
  80069a:	5d                   	pop    %ebp
  80069b:	c3                   	ret    

0080069c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80069c:	55                   	push   %ebp
  80069d:	89 e5                	mov    %esp,%ebp
  80069f:	83 ec 18             	sub    $0x18,%esp
  8006a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ab:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006af:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b9:	85 c0                	test   %eax,%eax
  8006bb:	74 26                	je     8006e3 <vsnprintf+0x47>
  8006bd:	85 d2                	test   %edx,%edx
  8006bf:	7e 22                	jle    8006e3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006c1:	ff 75 14             	pushl  0x14(%ebp)
  8006c4:	ff 75 10             	pushl  0x10(%ebp)
  8006c7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ca:	50                   	push   %eax
  8006cb:	68 b5 02 80 00       	push   $0x8002b5
  8006d0:	e8 1a fc ff ff       	call   8002ef <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006de:	83 c4 10             	add    $0x10,%esp
  8006e1:	eb 05                	jmp    8006e8 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e8:	c9                   	leave  
  8006e9:	c3                   	ret    

008006ea <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006ea:	55                   	push   %ebp
  8006eb:	89 e5                	mov    %esp,%ebp
  8006ed:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006f0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006f3:	50                   	push   %eax
  8006f4:	ff 75 10             	pushl  0x10(%ebp)
  8006f7:	ff 75 0c             	pushl  0xc(%ebp)
  8006fa:	ff 75 08             	pushl  0x8(%ebp)
  8006fd:	e8 9a ff ff ff       	call   80069c <vsnprintf>
	va_end(ap);

	return rc;
}
  800702:	c9                   	leave  
  800703:	c3                   	ret    

00800704 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80070a:	b8 00 00 00 00       	mov    $0x0,%eax
  80070f:	eb 03                	jmp    800714 <strlen+0x10>
		n++;
  800711:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800714:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800718:	75 f7                	jne    800711 <strlen+0xd>
		n++;
	return n;
}
  80071a:	5d                   	pop    %ebp
  80071b:	c3                   	ret    

0080071c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800722:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800725:	ba 00 00 00 00       	mov    $0x0,%edx
  80072a:	eb 03                	jmp    80072f <strnlen+0x13>
		n++;
  80072c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072f:	39 c2                	cmp    %eax,%edx
  800731:	74 08                	je     80073b <strnlen+0x1f>
  800733:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800737:	75 f3                	jne    80072c <strnlen+0x10>
  800739:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80073b:	5d                   	pop    %ebp
  80073c:	c3                   	ret    

0080073d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
  800740:	53                   	push   %ebx
  800741:	8b 45 08             	mov    0x8(%ebp),%eax
  800744:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800747:	89 c2                	mov    %eax,%edx
  800749:	83 c2 01             	add    $0x1,%edx
  80074c:	83 c1 01             	add    $0x1,%ecx
  80074f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800753:	88 5a ff             	mov    %bl,-0x1(%edx)
  800756:	84 db                	test   %bl,%bl
  800758:	75 ef                	jne    800749 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80075a:	5b                   	pop    %ebx
  80075b:	5d                   	pop    %ebp
  80075c:	c3                   	ret    

0080075d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	53                   	push   %ebx
  800761:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800764:	53                   	push   %ebx
  800765:	e8 9a ff ff ff       	call   800704 <strlen>
  80076a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80076d:	ff 75 0c             	pushl  0xc(%ebp)
  800770:	01 d8                	add    %ebx,%eax
  800772:	50                   	push   %eax
  800773:	e8 c5 ff ff ff       	call   80073d <strcpy>
	return dst;
}
  800778:	89 d8                	mov    %ebx,%eax
  80077a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80077d:	c9                   	leave  
  80077e:	c3                   	ret    

0080077f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	56                   	push   %esi
  800783:	53                   	push   %ebx
  800784:	8b 75 08             	mov    0x8(%ebp),%esi
  800787:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078a:	89 f3                	mov    %esi,%ebx
  80078c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078f:	89 f2                	mov    %esi,%edx
  800791:	eb 0f                	jmp    8007a2 <strncpy+0x23>
		*dst++ = *src;
  800793:	83 c2 01             	add    $0x1,%edx
  800796:	0f b6 01             	movzbl (%ecx),%eax
  800799:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80079c:	80 39 01             	cmpb   $0x1,(%ecx)
  80079f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a2:	39 da                	cmp    %ebx,%edx
  8007a4:	75 ed                	jne    800793 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a6:	89 f0                	mov    %esi,%eax
  8007a8:	5b                   	pop    %ebx
  8007a9:	5e                   	pop    %esi
  8007aa:	5d                   	pop    %ebp
  8007ab:	c3                   	ret    

008007ac <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	56                   	push   %esi
  8007b0:	53                   	push   %ebx
  8007b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b7:	8b 55 10             	mov    0x10(%ebp),%edx
  8007ba:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007bc:	85 d2                	test   %edx,%edx
  8007be:	74 21                	je     8007e1 <strlcpy+0x35>
  8007c0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007c4:	89 f2                	mov    %esi,%edx
  8007c6:	eb 09                	jmp    8007d1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c8:	83 c2 01             	add    $0x1,%edx
  8007cb:	83 c1 01             	add    $0x1,%ecx
  8007ce:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007d1:	39 c2                	cmp    %eax,%edx
  8007d3:	74 09                	je     8007de <strlcpy+0x32>
  8007d5:	0f b6 19             	movzbl (%ecx),%ebx
  8007d8:	84 db                	test   %bl,%bl
  8007da:	75 ec                	jne    8007c8 <strlcpy+0x1c>
  8007dc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007de:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007e1:	29 f0                	sub    %esi,%eax
}
  8007e3:	5b                   	pop    %ebx
  8007e4:	5e                   	pop    %esi
  8007e5:	5d                   	pop    %ebp
  8007e6:	c3                   	ret    

008007e7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ed:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007f0:	eb 06                	jmp    8007f8 <strcmp+0x11>
		p++, q++;
  8007f2:	83 c1 01             	add    $0x1,%ecx
  8007f5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f8:	0f b6 01             	movzbl (%ecx),%eax
  8007fb:	84 c0                	test   %al,%al
  8007fd:	74 04                	je     800803 <strcmp+0x1c>
  8007ff:	3a 02                	cmp    (%edx),%al
  800801:	74 ef                	je     8007f2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800803:	0f b6 c0             	movzbl %al,%eax
  800806:	0f b6 12             	movzbl (%edx),%edx
  800809:	29 d0                	sub    %edx,%eax
}
  80080b:	5d                   	pop    %ebp
  80080c:	c3                   	ret    

0080080d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80080d:	55                   	push   %ebp
  80080e:	89 e5                	mov    %esp,%ebp
  800810:	53                   	push   %ebx
  800811:	8b 45 08             	mov    0x8(%ebp),%eax
  800814:	8b 55 0c             	mov    0xc(%ebp),%edx
  800817:	89 c3                	mov    %eax,%ebx
  800819:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80081c:	eb 06                	jmp    800824 <strncmp+0x17>
		n--, p++, q++;
  80081e:	83 c0 01             	add    $0x1,%eax
  800821:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800824:	39 d8                	cmp    %ebx,%eax
  800826:	74 15                	je     80083d <strncmp+0x30>
  800828:	0f b6 08             	movzbl (%eax),%ecx
  80082b:	84 c9                	test   %cl,%cl
  80082d:	74 04                	je     800833 <strncmp+0x26>
  80082f:	3a 0a                	cmp    (%edx),%cl
  800831:	74 eb                	je     80081e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800833:	0f b6 00             	movzbl (%eax),%eax
  800836:	0f b6 12             	movzbl (%edx),%edx
  800839:	29 d0                	sub    %edx,%eax
  80083b:	eb 05                	jmp    800842 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80083d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800842:	5b                   	pop    %ebx
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	8b 45 08             	mov    0x8(%ebp),%eax
  80084b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084f:	eb 07                	jmp    800858 <strchr+0x13>
		if (*s == c)
  800851:	38 ca                	cmp    %cl,%dl
  800853:	74 0f                	je     800864 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800855:	83 c0 01             	add    $0x1,%eax
  800858:	0f b6 10             	movzbl (%eax),%edx
  80085b:	84 d2                	test   %dl,%dl
  80085d:	75 f2                	jne    800851 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80085f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800864:	5d                   	pop    %ebp
  800865:	c3                   	ret    

00800866 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	8b 45 08             	mov    0x8(%ebp),%eax
  80086c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800870:	eb 03                	jmp    800875 <strfind+0xf>
  800872:	83 c0 01             	add    $0x1,%eax
  800875:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800878:	38 ca                	cmp    %cl,%dl
  80087a:	74 04                	je     800880 <strfind+0x1a>
  80087c:	84 d2                	test   %dl,%dl
  80087e:	75 f2                	jne    800872 <strfind+0xc>
			break;
	return (char *) s;
}
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	57                   	push   %edi
  800886:	56                   	push   %esi
  800887:	53                   	push   %ebx
  800888:	8b 7d 08             	mov    0x8(%ebp),%edi
  80088b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80088e:	85 c9                	test   %ecx,%ecx
  800890:	74 36                	je     8008c8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800892:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800898:	75 28                	jne    8008c2 <memset+0x40>
  80089a:	f6 c1 03             	test   $0x3,%cl
  80089d:	75 23                	jne    8008c2 <memset+0x40>
		c &= 0xFF;
  80089f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008a3:	89 d3                	mov    %edx,%ebx
  8008a5:	c1 e3 08             	shl    $0x8,%ebx
  8008a8:	89 d6                	mov    %edx,%esi
  8008aa:	c1 e6 18             	shl    $0x18,%esi
  8008ad:	89 d0                	mov    %edx,%eax
  8008af:	c1 e0 10             	shl    $0x10,%eax
  8008b2:	09 f0                	or     %esi,%eax
  8008b4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008b6:	89 d8                	mov    %ebx,%eax
  8008b8:	09 d0                	or     %edx,%eax
  8008ba:	c1 e9 02             	shr    $0x2,%ecx
  8008bd:	fc                   	cld    
  8008be:	f3 ab                	rep stos %eax,%es:(%edi)
  8008c0:	eb 06                	jmp    8008c8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c5:	fc                   	cld    
  8008c6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c8:	89 f8                	mov    %edi,%eax
  8008ca:	5b                   	pop    %ebx
  8008cb:	5e                   	pop    %esi
  8008cc:	5f                   	pop    %edi
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	57                   	push   %edi
  8008d3:	56                   	push   %esi
  8008d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008da:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008dd:	39 c6                	cmp    %eax,%esi
  8008df:	73 35                	jae    800916 <memmove+0x47>
  8008e1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008e4:	39 d0                	cmp    %edx,%eax
  8008e6:	73 2e                	jae    800916 <memmove+0x47>
		s += n;
		d += n;
  8008e8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008eb:	89 d6                	mov    %edx,%esi
  8008ed:	09 fe                	or     %edi,%esi
  8008ef:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008f5:	75 13                	jne    80090a <memmove+0x3b>
  8008f7:	f6 c1 03             	test   $0x3,%cl
  8008fa:	75 0e                	jne    80090a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008fc:	83 ef 04             	sub    $0x4,%edi
  8008ff:	8d 72 fc             	lea    -0x4(%edx),%esi
  800902:	c1 e9 02             	shr    $0x2,%ecx
  800905:	fd                   	std    
  800906:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800908:	eb 09                	jmp    800913 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80090a:	83 ef 01             	sub    $0x1,%edi
  80090d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800910:	fd                   	std    
  800911:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800913:	fc                   	cld    
  800914:	eb 1d                	jmp    800933 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800916:	89 f2                	mov    %esi,%edx
  800918:	09 c2                	or     %eax,%edx
  80091a:	f6 c2 03             	test   $0x3,%dl
  80091d:	75 0f                	jne    80092e <memmove+0x5f>
  80091f:	f6 c1 03             	test   $0x3,%cl
  800922:	75 0a                	jne    80092e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800924:	c1 e9 02             	shr    $0x2,%ecx
  800927:	89 c7                	mov    %eax,%edi
  800929:	fc                   	cld    
  80092a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092c:	eb 05                	jmp    800933 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80092e:	89 c7                	mov    %eax,%edi
  800930:	fc                   	cld    
  800931:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800933:	5e                   	pop    %esi
  800934:	5f                   	pop    %edi
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80093a:	ff 75 10             	pushl  0x10(%ebp)
  80093d:	ff 75 0c             	pushl  0xc(%ebp)
  800940:	ff 75 08             	pushl  0x8(%ebp)
  800943:	e8 87 ff ff ff       	call   8008cf <memmove>
}
  800948:	c9                   	leave  
  800949:	c3                   	ret    

0080094a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	56                   	push   %esi
  80094e:	53                   	push   %ebx
  80094f:	8b 45 08             	mov    0x8(%ebp),%eax
  800952:	8b 55 0c             	mov    0xc(%ebp),%edx
  800955:	89 c6                	mov    %eax,%esi
  800957:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80095a:	eb 1a                	jmp    800976 <memcmp+0x2c>
		if (*s1 != *s2)
  80095c:	0f b6 08             	movzbl (%eax),%ecx
  80095f:	0f b6 1a             	movzbl (%edx),%ebx
  800962:	38 d9                	cmp    %bl,%cl
  800964:	74 0a                	je     800970 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800966:	0f b6 c1             	movzbl %cl,%eax
  800969:	0f b6 db             	movzbl %bl,%ebx
  80096c:	29 d8                	sub    %ebx,%eax
  80096e:	eb 0f                	jmp    80097f <memcmp+0x35>
		s1++, s2++;
  800970:	83 c0 01             	add    $0x1,%eax
  800973:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800976:	39 f0                	cmp    %esi,%eax
  800978:	75 e2                	jne    80095c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80097a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097f:	5b                   	pop    %ebx
  800980:	5e                   	pop    %esi
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    

00800983 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	53                   	push   %ebx
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80098a:	89 c1                	mov    %eax,%ecx
  80098c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80098f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800993:	eb 0a                	jmp    80099f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800995:	0f b6 10             	movzbl (%eax),%edx
  800998:	39 da                	cmp    %ebx,%edx
  80099a:	74 07                	je     8009a3 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80099c:	83 c0 01             	add    $0x1,%eax
  80099f:	39 c8                	cmp    %ecx,%eax
  8009a1:	72 f2                	jb     800995 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009a3:	5b                   	pop    %ebx
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	57                   	push   %edi
  8009aa:	56                   	push   %esi
  8009ab:	53                   	push   %ebx
  8009ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009af:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b2:	eb 03                	jmp    8009b7 <strtol+0x11>
		s++;
  8009b4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b7:	0f b6 01             	movzbl (%ecx),%eax
  8009ba:	3c 20                	cmp    $0x20,%al
  8009bc:	74 f6                	je     8009b4 <strtol+0xe>
  8009be:	3c 09                	cmp    $0x9,%al
  8009c0:	74 f2                	je     8009b4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009c2:	3c 2b                	cmp    $0x2b,%al
  8009c4:	75 0a                	jne    8009d0 <strtol+0x2a>
		s++;
  8009c6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c9:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ce:	eb 11                	jmp    8009e1 <strtol+0x3b>
  8009d0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009d5:	3c 2d                	cmp    $0x2d,%al
  8009d7:	75 08                	jne    8009e1 <strtol+0x3b>
		s++, neg = 1;
  8009d9:	83 c1 01             	add    $0x1,%ecx
  8009dc:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009e1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e7:	75 15                	jne    8009fe <strtol+0x58>
  8009e9:	80 39 30             	cmpb   $0x30,(%ecx)
  8009ec:	75 10                	jne    8009fe <strtol+0x58>
  8009ee:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009f2:	75 7c                	jne    800a70 <strtol+0xca>
		s += 2, base = 16;
  8009f4:	83 c1 02             	add    $0x2,%ecx
  8009f7:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009fc:	eb 16                	jmp    800a14 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009fe:	85 db                	test   %ebx,%ebx
  800a00:	75 12                	jne    800a14 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a02:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a07:	80 39 30             	cmpb   $0x30,(%ecx)
  800a0a:	75 08                	jne    800a14 <strtol+0x6e>
		s++, base = 8;
  800a0c:	83 c1 01             	add    $0x1,%ecx
  800a0f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a14:	b8 00 00 00 00       	mov    $0x0,%eax
  800a19:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a1c:	0f b6 11             	movzbl (%ecx),%edx
  800a1f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a22:	89 f3                	mov    %esi,%ebx
  800a24:	80 fb 09             	cmp    $0x9,%bl
  800a27:	77 08                	ja     800a31 <strtol+0x8b>
			dig = *s - '0';
  800a29:	0f be d2             	movsbl %dl,%edx
  800a2c:	83 ea 30             	sub    $0x30,%edx
  800a2f:	eb 22                	jmp    800a53 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a31:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a34:	89 f3                	mov    %esi,%ebx
  800a36:	80 fb 19             	cmp    $0x19,%bl
  800a39:	77 08                	ja     800a43 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a3b:	0f be d2             	movsbl %dl,%edx
  800a3e:	83 ea 57             	sub    $0x57,%edx
  800a41:	eb 10                	jmp    800a53 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a43:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a46:	89 f3                	mov    %esi,%ebx
  800a48:	80 fb 19             	cmp    $0x19,%bl
  800a4b:	77 16                	ja     800a63 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a4d:	0f be d2             	movsbl %dl,%edx
  800a50:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a53:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a56:	7d 0b                	jge    800a63 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a58:	83 c1 01             	add    $0x1,%ecx
  800a5b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a5f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a61:	eb b9                	jmp    800a1c <strtol+0x76>

	if (endptr)
  800a63:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a67:	74 0d                	je     800a76 <strtol+0xd0>
		*endptr = (char *) s;
  800a69:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a6c:	89 0e                	mov    %ecx,(%esi)
  800a6e:	eb 06                	jmp    800a76 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a70:	85 db                	test   %ebx,%ebx
  800a72:	74 98                	je     800a0c <strtol+0x66>
  800a74:	eb 9e                	jmp    800a14 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a76:	89 c2                	mov    %eax,%edx
  800a78:	f7 da                	neg    %edx
  800a7a:	85 ff                	test   %edi,%edi
  800a7c:	0f 45 c2             	cmovne %edx,%eax
}
  800a7f:	5b                   	pop    %ebx
  800a80:	5e                   	pop    %esi
  800a81:	5f                   	pop    %edi
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800a8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a92:	8b 55 08             	mov    0x8(%ebp),%edx
  800a95:	89 c3                	mov    %eax,%ebx
  800a97:	89 c7                	mov    %eax,%edi
  800a99:	89 c6                	mov    %eax,%esi
  800a9b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a9d:	5b                   	pop    %ebx
  800a9e:	5e                   	pop    %esi
  800a9f:	5f                   	pop    %edi
  800aa0:	5d                   	pop    %ebp
  800aa1:	c3                   	ret    

00800aa2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	57                   	push   %edi
  800aa6:	56                   	push   %esi
  800aa7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa8:	ba 00 00 00 00       	mov    $0x0,%edx
  800aad:	b8 01 00 00 00       	mov    $0x1,%eax
  800ab2:	89 d1                	mov    %edx,%ecx
  800ab4:	89 d3                	mov    %edx,%ebx
  800ab6:	89 d7                	mov    %edx,%edi
  800ab8:	89 d6                	mov    %edx,%esi
  800aba:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800abc:	5b                   	pop    %ebx
  800abd:	5e                   	pop    %esi
  800abe:	5f                   	pop    %edi
  800abf:	5d                   	pop    %ebp
  800ac0:	c3                   	ret    

00800ac1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	57                   	push   %edi
  800ac5:	56                   	push   %esi
  800ac6:	53                   	push   %ebx
  800ac7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aca:	b9 00 00 00 00       	mov    $0x0,%ecx
  800acf:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad7:	89 cb                	mov    %ecx,%ebx
  800ad9:	89 cf                	mov    %ecx,%edi
  800adb:	89 ce                	mov    %ecx,%esi
  800add:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800adf:	85 c0                	test   %eax,%eax
  800ae1:	7e 17                	jle    800afa <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ae3:	83 ec 0c             	sub    $0xc,%esp
  800ae6:	50                   	push   %eax
  800ae7:	6a 03                	push   $0x3
  800ae9:	68 9f 21 80 00       	push   $0x80219f
  800aee:	6a 23                	push   $0x23
  800af0:	68 bc 21 80 00       	push   $0x8021bc
  800af5:	e8 41 0f 00 00       	call   801a3b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800afa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5f                   	pop    %edi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b08:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b12:	89 d1                	mov    %edx,%ecx
  800b14:	89 d3                	mov    %edx,%ebx
  800b16:	89 d7                	mov    %edx,%edi
  800b18:	89 d6                	mov    %edx,%esi
  800b1a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b1c:	5b                   	pop    %ebx
  800b1d:	5e                   	pop    %esi
  800b1e:	5f                   	pop    %edi
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <sys_yield>:

void
sys_yield(void)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	57                   	push   %edi
  800b25:	56                   	push   %esi
  800b26:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b27:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b31:	89 d1                	mov    %edx,%ecx
  800b33:	89 d3                	mov    %edx,%ebx
  800b35:	89 d7                	mov    %edx,%edi
  800b37:	89 d6                	mov    %edx,%esi
  800b39:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b3b:	5b                   	pop    %ebx
  800b3c:	5e                   	pop    %esi
  800b3d:	5f                   	pop    %edi
  800b3e:	5d                   	pop    %ebp
  800b3f:	c3                   	ret    

00800b40 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
  800b46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b49:	be 00 00 00 00       	mov    $0x0,%esi
  800b4e:	b8 04 00 00 00       	mov    $0x4,%eax
  800b53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b56:	8b 55 08             	mov    0x8(%ebp),%edx
  800b59:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b5c:	89 f7                	mov    %esi,%edi
  800b5e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b60:	85 c0                	test   %eax,%eax
  800b62:	7e 17                	jle    800b7b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b64:	83 ec 0c             	sub    $0xc,%esp
  800b67:	50                   	push   %eax
  800b68:	6a 04                	push   $0x4
  800b6a:	68 9f 21 80 00       	push   $0x80219f
  800b6f:	6a 23                	push   $0x23
  800b71:	68 bc 21 80 00       	push   $0x8021bc
  800b76:	e8 c0 0e 00 00       	call   801a3b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7e:	5b                   	pop    %ebx
  800b7f:	5e                   	pop    %esi
  800b80:	5f                   	pop    %edi
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    

00800b83 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	57                   	push   %edi
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8c:	b8 05 00 00 00       	mov    $0x5,%eax
  800b91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b94:	8b 55 08             	mov    0x8(%ebp),%edx
  800b97:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b9d:	8b 75 18             	mov    0x18(%ebp),%esi
  800ba0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba2:	85 c0                	test   %eax,%eax
  800ba4:	7e 17                	jle    800bbd <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba6:	83 ec 0c             	sub    $0xc,%esp
  800ba9:	50                   	push   %eax
  800baa:	6a 05                	push   $0x5
  800bac:	68 9f 21 80 00       	push   $0x80219f
  800bb1:	6a 23                	push   $0x23
  800bb3:	68 bc 21 80 00       	push   $0x8021bc
  800bb8:	e8 7e 0e 00 00       	call   801a3b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	57                   	push   %edi
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
  800bcb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bce:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd3:	b8 06 00 00 00       	mov    $0x6,%eax
  800bd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bde:	89 df                	mov    %ebx,%edi
  800be0:	89 de                	mov    %ebx,%esi
  800be2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be4:	85 c0                	test   %eax,%eax
  800be6:	7e 17                	jle    800bff <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be8:	83 ec 0c             	sub    $0xc,%esp
  800beb:	50                   	push   %eax
  800bec:	6a 06                	push   $0x6
  800bee:	68 9f 21 80 00       	push   $0x80219f
  800bf3:	6a 23                	push   $0x23
  800bf5:	68 bc 21 80 00       	push   $0x8021bc
  800bfa:	e8 3c 0e 00 00       	call   801a3b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
  800c0d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c15:	b8 08 00 00 00       	mov    $0x8,%eax
  800c1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c20:	89 df                	mov    %ebx,%edi
  800c22:	89 de                	mov    %ebx,%esi
  800c24:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c26:	85 c0                	test   %eax,%eax
  800c28:	7e 17                	jle    800c41 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2a:	83 ec 0c             	sub    $0xc,%esp
  800c2d:	50                   	push   %eax
  800c2e:	6a 08                	push   $0x8
  800c30:	68 9f 21 80 00       	push   $0x80219f
  800c35:	6a 23                	push   $0x23
  800c37:	68 bc 21 80 00       	push   $0x8021bc
  800c3c:	e8 fa 0d 00 00       	call   801a3b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c44:	5b                   	pop    %ebx
  800c45:	5e                   	pop    %esi
  800c46:	5f                   	pop    %edi
  800c47:	5d                   	pop    %ebp
  800c48:	c3                   	ret    

00800c49 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	57                   	push   %edi
  800c4d:	56                   	push   %esi
  800c4e:	53                   	push   %ebx
  800c4f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c52:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c57:	b8 09 00 00 00       	mov    $0x9,%eax
  800c5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c62:	89 df                	mov    %ebx,%edi
  800c64:	89 de                	mov    %ebx,%esi
  800c66:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c68:	85 c0                	test   %eax,%eax
  800c6a:	7e 17                	jle    800c83 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6c:	83 ec 0c             	sub    $0xc,%esp
  800c6f:	50                   	push   %eax
  800c70:	6a 09                	push   $0x9
  800c72:	68 9f 21 80 00       	push   $0x80219f
  800c77:	6a 23                	push   $0x23
  800c79:	68 bc 21 80 00       	push   $0x8021bc
  800c7e:	e8 b8 0d 00 00       	call   801a3b <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c86:	5b                   	pop    %ebx
  800c87:	5e                   	pop    %esi
  800c88:	5f                   	pop    %edi
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    

00800c8b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	57                   	push   %edi
  800c8f:	56                   	push   %esi
  800c90:	53                   	push   %ebx
  800c91:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c94:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c99:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca4:	89 df                	mov    %ebx,%edi
  800ca6:	89 de                	mov    %ebx,%esi
  800ca8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800caa:	85 c0                	test   %eax,%eax
  800cac:	7e 17                	jle    800cc5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cae:	83 ec 0c             	sub    $0xc,%esp
  800cb1:	50                   	push   %eax
  800cb2:	6a 0a                	push   $0xa
  800cb4:	68 9f 21 80 00       	push   $0x80219f
  800cb9:	6a 23                	push   $0x23
  800cbb:	68 bc 21 80 00       	push   $0x8021bc
  800cc0:	e8 76 0d 00 00       	call   801a3b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc8:	5b                   	pop    %ebx
  800cc9:	5e                   	pop    %esi
  800cca:	5f                   	pop    %edi
  800ccb:	5d                   	pop    %ebp
  800ccc:	c3                   	ret    

00800ccd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	57                   	push   %edi
  800cd1:	56                   	push   %esi
  800cd2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd3:	be 00 00 00 00       	mov    $0x0,%esi
  800cd8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ceb:	5b                   	pop    %ebx
  800cec:	5e                   	pop    %esi
  800ced:	5f                   	pop    %edi
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	57                   	push   %edi
  800cf4:	56                   	push   %esi
  800cf5:	53                   	push   %ebx
  800cf6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cfe:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d03:	8b 55 08             	mov    0x8(%ebp),%edx
  800d06:	89 cb                	mov    %ecx,%ebx
  800d08:	89 cf                	mov    %ecx,%edi
  800d0a:	89 ce                	mov    %ecx,%esi
  800d0c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0e:	85 c0                	test   %eax,%eax
  800d10:	7e 17                	jle    800d29 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d12:	83 ec 0c             	sub    $0xc,%esp
  800d15:	50                   	push   %eax
  800d16:	6a 0d                	push   $0xd
  800d18:	68 9f 21 80 00       	push   $0x80219f
  800d1d:	6a 23                	push   $0x23
  800d1f:	68 bc 21 80 00       	push   $0x8021bc
  800d24:	e8 12 0d 00 00       	call   801a3b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2c:	5b                   	pop    %ebx
  800d2d:	5e                   	pop    %esi
  800d2e:	5f                   	pop    %edi
  800d2f:	5d                   	pop    %ebp
  800d30:	c3                   	ret    

00800d31 <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	57                   	push   %edi
  800d35:	56                   	push   %esi
  800d36:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d37:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d41:	8b 55 08             	mov    0x8(%ebp),%edx
  800d44:	89 cb                	mov    %ecx,%ebx
  800d46:	89 cf                	mov    %ecx,%edi
  800d48:	89 ce                	mov    %ecx,%esi
  800d4a:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d4c:	5b                   	pop    %ebx
  800d4d:	5e                   	pop    %esi
  800d4e:	5f                   	pop    %edi
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    

00800d51 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d54:	8b 45 08             	mov    0x8(%ebp),%eax
  800d57:	05 00 00 00 30       	add    $0x30000000,%eax
  800d5c:	c1 e8 0c             	shr    $0xc,%eax
}
  800d5f:	5d                   	pop    %ebp
  800d60:	c3                   	ret    

00800d61 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d61:	55                   	push   %ebp
  800d62:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d64:	8b 45 08             	mov    0x8(%ebp),%eax
  800d67:	05 00 00 00 30       	add    $0x30000000,%eax
  800d6c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d71:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d7e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d83:	89 c2                	mov    %eax,%edx
  800d85:	c1 ea 16             	shr    $0x16,%edx
  800d88:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d8f:	f6 c2 01             	test   $0x1,%dl
  800d92:	74 11                	je     800da5 <fd_alloc+0x2d>
  800d94:	89 c2                	mov    %eax,%edx
  800d96:	c1 ea 0c             	shr    $0xc,%edx
  800d99:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800da0:	f6 c2 01             	test   $0x1,%dl
  800da3:	75 09                	jne    800dae <fd_alloc+0x36>
			*fd_store = fd;
  800da5:	89 01                	mov    %eax,(%ecx)
			return 0;
  800da7:	b8 00 00 00 00       	mov    $0x0,%eax
  800dac:	eb 17                	jmp    800dc5 <fd_alloc+0x4d>
  800dae:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800db3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800db8:	75 c9                	jne    800d83 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dba:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800dc0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dc5:	5d                   	pop    %ebp
  800dc6:	c3                   	ret    

00800dc7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dc7:	55                   	push   %ebp
  800dc8:	89 e5                	mov    %esp,%ebp
  800dca:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dcd:	83 f8 1f             	cmp    $0x1f,%eax
  800dd0:	77 36                	ja     800e08 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dd2:	c1 e0 0c             	shl    $0xc,%eax
  800dd5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dda:	89 c2                	mov    %eax,%edx
  800ddc:	c1 ea 16             	shr    $0x16,%edx
  800ddf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800de6:	f6 c2 01             	test   $0x1,%dl
  800de9:	74 24                	je     800e0f <fd_lookup+0x48>
  800deb:	89 c2                	mov    %eax,%edx
  800ded:	c1 ea 0c             	shr    $0xc,%edx
  800df0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800df7:	f6 c2 01             	test   $0x1,%dl
  800dfa:	74 1a                	je     800e16 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dfc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dff:	89 02                	mov    %eax,(%edx)
	return 0;
  800e01:	b8 00 00 00 00       	mov    $0x0,%eax
  800e06:	eb 13                	jmp    800e1b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e08:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e0d:	eb 0c                	jmp    800e1b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e0f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e14:	eb 05                	jmp    800e1b <fd_lookup+0x54>
  800e16:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e1b:	5d                   	pop    %ebp
  800e1c:	c3                   	ret    

00800e1d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e1d:	55                   	push   %ebp
  800e1e:	89 e5                	mov    %esp,%ebp
  800e20:	83 ec 08             	sub    $0x8,%esp
  800e23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e26:	ba 48 22 80 00       	mov    $0x802248,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e2b:	eb 13                	jmp    800e40 <dev_lookup+0x23>
  800e2d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e30:	39 08                	cmp    %ecx,(%eax)
  800e32:	75 0c                	jne    800e40 <dev_lookup+0x23>
			*dev = devtab[i];
  800e34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e37:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e39:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3e:	eb 2e                	jmp    800e6e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e40:	8b 02                	mov    (%edx),%eax
  800e42:	85 c0                	test   %eax,%eax
  800e44:	75 e7                	jne    800e2d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e46:	a1 04 40 80 00       	mov    0x804004,%eax
  800e4b:	8b 40 50             	mov    0x50(%eax),%eax
  800e4e:	83 ec 04             	sub    $0x4,%esp
  800e51:	51                   	push   %ecx
  800e52:	50                   	push   %eax
  800e53:	68 cc 21 80 00       	push   $0x8021cc
  800e58:	e8 5b f3 ff ff       	call   8001b8 <cprintf>
	*dev = 0;
  800e5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e60:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e66:	83 c4 10             	add    $0x10,%esp
  800e69:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e6e:	c9                   	leave  
  800e6f:	c3                   	ret    

00800e70 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	56                   	push   %esi
  800e74:	53                   	push   %ebx
  800e75:	83 ec 10             	sub    $0x10,%esp
  800e78:	8b 75 08             	mov    0x8(%ebp),%esi
  800e7b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e81:	50                   	push   %eax
  800e82:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e88:	c1 e8 0c             	shr    $0xc,%eax
  800e8b:	50                   	push   %eax
  800e8c:	e8 36 ff ff ff       	call   800dc7 <fd_lookup>
  800e91:	83 c4 08             	add    $0x8,%esp
  800e94:	85 c0                	test   %eax,%eax
  800e96:	78 05                	js     800e9d <fd_close+0x2d>
	    || fd != fd2)
  800e98:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e9b:	74 0c                	je     800ea9 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e9d:	84 db                	test   %bl,%bl
  800e9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea4:	0f 44 c2             	cmove  %edx,%eax
  800ea7:	eb 41                	jmp    800eea <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ea9:	83 ec 08             	sub    $0x8,%esp
  800eac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800eaf:	50                   	push   %eax
  800eb0:	ff 36                	pushl  (%esi)
  800eb2:	e8 66 ff ff ff       	call   800e1d <dev_lookup>
  800eb7:	89 c3                	mov    %eax,%ebx
  800eb9:	83 c4 10             	add    $0x10,%esp
  800ebc:	85 c0                	test   %eax,%eax
  800ebe:	78 1a                	js     800eda <fd_close+0x6a>
		if (dev->dev_close)
  800ec0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ec3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ec6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ecb:	85 c0                	test   %eax,%eax
  800ecd:	74 0b                	je     800eda <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ecf:	83 ec 0c             	sub    $0xc,%esp
  800ed2:	56                   	push   %esi
  800ed3:	ff d0                	call   *%eax
  800ed5:	89 c3                	mov    %eax,%ebx
  800ed7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800eda:	83 ec 08             	sub    $0x8,%esp
  800edd:	56                   	push   %esi
  800ede:	6a 00                	push   $0x0
  800ee0:	e8 e0 fc ff ff       	call   800bc5 <sys_page_unmap>
	return r;
  800ee5:	83 c4 10             	add    $0x10,%esp
  800ee8:	89 d8                	mov    %ebx,%eax
}
  800eea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eed:	5b                   	pop    %ebx
  800eee:	5e                   	pop    %esi
  800eef:	5d                   	pop    %ebp
  800ef0:	c3                   	ret    

00800ef1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ef7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800efa:	50                   	push   %eax
  800efb:	ff 75 08             	pushl  0x8(%ebp)
  800efe:	e8 c4 fe ff ff       	call   800dc7 <fd_lookup>
  800f03:	83 c4 08             	add    $0x8,%esp
  800f06:	85 c0                	test   %eax,%eax
  800f08:	78 10                	js     800f1a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f0a:	83 ec 08             	sub    $0x8,%esp
  800f0d:	6a 01                	push   $0x1
  800f0f:	ff 75 f4             	pushl  -0xc(%ebp)
  800f12:	e8 59 ff ff ff       	call   800e70 <fd_close>
  800f17:	83 c4 10             	add    $0x10,%esp
}
  800f1a:	c9                   	leave  
  800f1b:	c3                   	ret    

00800f1c <close_all>:

void
close_all(void)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	53                   	push   %ebx
  800f20:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f23:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f28:	83 ec 0c             	sub    $0xc,%esp
  800f2b:	53                   	push   %ebx
  800f2c:	e8 c0 ff ff ff       	call   800ef1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f31:	83 c3 01             	add    $0x1,%ebx
  800f34:	83 c4 10             	add    $0x10,%esp
  800f37:	83 fb 20             	cmp    $0x20,%ebx
  800f3a:	75 ec                	jne    800f28 <close_all+0xc>
		close(i);
}
  800f3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f3f:	c9                   	leave  
  800f40:	c3                   	ret    

00800f41 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f41:	55                   	push   %ebp
  800f42:	89 e5                	mov    %esp,%ebp
  800f44:	57                   	push   %edi
  800f45:	56                   	push   %esi
  800f46:	53                   	push   %ebx
  800f47:	83 ec 2c             	sub    $0x2c,%esp
  800f4a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f4d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f50:	50                   	push   %eax
  800f51:	ff 75 08             	pushl  0x8(%ebp)
  800f54:	e8 6e fe ff ff       	call   800dc7 <fd_lookup>
  800f59:	83 c4 08             	add    $0x8,%esp
  800f5c:	85 c0                	test   %eax,%eax
  800f5e:	0f 88 c1 00 00 00    	js     801025 <dup+0xe4>
		return r;
	close(newfdnum);
  800f64:	83 ec 0c             	sub    $0xc,%esp
  800f67:	56                   	push   %esi
  800f68:	e8 84 ff ff ff       	call   800ef1 <close>

	newfd = INDEX2FD(newfdnum);
  800f6d:	89 f3                	mov    %esi,%ebx
  800f6f:	c1 e3 0c             	shl    $0xc,%ebx
  800f72:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f78:	83 c4 04             	add    $0x4,%esp
  800f7b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f7e:	e8 de fd ff ff       	call   800d61 <fd2data>
  800f83:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f85:	89 1c 24             	mov    %ebx,(%esp)
  800f88:	e8 d4 fd ff ff       	call   800d61 <fd2data>
  800f8d:	83 c4 10             	add    $0x10,%esp
  800f90:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f93:	89 f8                	mov    %edi,%eax
  800f95:	c1 e8 16             	shr    $0x16,%eax
  800f98:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f9f:	a8 01                	test   $0x1,%al
  800fa1:	74 37                	je     800fda <dup+0x99>
  800fa3:	89 f8                	mov    %edi,%eax
  800fa5:	c1 e8 0c             	shr    $0xc,%eax
  800fa8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800faf:	f6 c2 01             	test   $0x1,%dl
  800fb2:	74 26                	je     800fda <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fb4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fbb:	83 ec 0c             	sub    $0xc,%esp
  800fbe:	25 07 0e 00 00       	and    $0xe07,%eax
  800fc3:	50                   	push   %eax
  800fc4:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fc7:	6a 00                	push   $0x0
  800fc9:	57                   	push   %edi
  800fca:	6a 00                	push   $0x0
  800fcc:	e8 b2 fb ff ff       	call   800b83 <sys_page_map>
  800fd1:	89 c7                	mov    %eax,%edi
  800fd3:	83 c4 20             	add    $0x20,%esp
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	78 2e                	js     801008 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fda:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fdd:	89 d0                	mov    %edx,%eax
  800fdf:	c1 e8 0c             	shr    $0xc,%eax
  800fe2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fe9:	83 ec 0c             	sub    $0xc,%esp
  800fec:	25 07 0e 00 00       	and    $0xe07,%eax
  800ff1:	50                   	push   %eax
  800ff2:	53                   	push   %ebx
  800ff3:	6a 00                	push   $0x0
  800ff5:	52                   	push   %edx
  800ff6:	6a 00                	push   $0x0
  800ff8:	e8 86 fb ff ff       	call   800b83 <sys_page_map>
  800ffd:	89 c7                	mov    %eax,%edi
  800fff:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801002:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801004:	85 ff                	test   %edi,%edi
  801006:	79 1d                	jns    801025 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801008:	83 ec 08             	sub    $0x8,%esp
  80100b:	53                   	push   %ebx
  80100c:	6a 00                	push   $0x0
  80100e:	e8 b2 fb ff ff       	call   800bc5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801013:	83 c4 08             	add    $0x8,%esp
  801016:	ff 75 d4             	pushl  -0x2c(%ebp)
  801019:	6a 00                	push   $0x0
  80101b:	e8 a5 fb ff ff       	call   800bc5 <sys_page_unmap>
	return r;
  801020:	83 c4 10             	add    $0x10,%esp
  801023:	89 f8                	mov    %edi,%eax
}
  801025:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801028:	5b                   	pop    %ebx
  801029:	5e                   	pop    %esi
  80102a:	5f                   	pop    %edi
  80102b:	5d                   	pop    %ebp
  80102c:	c3                   	ret    

0080102d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	53                   	push   %ebx
  801031:	83 ec 14             	sub    $0x14,%esp
  801034:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801037:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80103a:	50                   	push   %eax
  80103b:	53                   	push   %ebx
  80103c:	e8 86 fd ff ff       	call   800dc7 <fd_lookup>
  801041:	83 c4 08             	add    $0x8,%esp
  801044:	89 c2                	mov    %eax,%edx
  801046:	85 c0                	test   %eax,%eax
  801048:	78 6d                	js     8010b7 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80104a:	83 ec 08             	sub    $0x8,%esp
  80104d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801050:	50                   	push   %eax
  801051:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801054:	ff 30                	pushl  (%eax)
  801056:	e8 c2 fd ff ff       	call   800e1d <dev_lookup>
  80105b:	83 c4 10             	add    $0x10,%esp
  80105e:	85 c0                	test   %eax,%eax
  801060:	78 4c                	js     8010ae <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801062:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801065:	8b 42 08             	mov    0x8(%edx),%eax
  801068:	83 e0 03             	and    $0x3,%eax
  80106b:	83 f8 01             	cmp    $0x1,%eax
  80106e:	75 21                	jne    801091 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801070:	a1 04 40 80 00       	mov    0x804004,%eax
  801075:	8b 40 50             	mov    0x50(%eax),%eax
  801078:	83 ec 04             	sub    $0x4,%esp
  80107b:	53                   	push   %ebx
  80107c:	50                   	push   %eax
  80107d:	68 0d 22 80 00       	push   $0x80220d
  801082:	e8 31 f1 ff ff       	call   8001b8 <cprintf>
		return -E_INVAL;
  801087:	83 c4 10             	add    $0x10,%esp
  80108a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80108f:	eb 26                	jmp    8010b7 <read+0x8a>
	}
	if (!dev->dev_read)
  801091:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801094:	8b 40 08             	mov    0x8(%eax),%eax
  801097:	85 c0                	test   %eax,%eax
  801099:	74 17                	je     8010b2 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80109b:	83 ec 04             	sub    $0x4,%esp
  80109e:	ff 75 10             	pushl  0x10(%ebp)
  8010a1:	ff 75 0c             	pushl  0xc(%ebp)
  8010a4:	52                   	push   %edx
  8010a5:	ff d0                	call   *%eax
  8010a7:	89 c2                	mov    %eax,%edx
  8010a9:	83 c4 10             	add    $0x10,%esp
  8010ac:	eb 09                	jmp    8010b7 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010ae:	89 c2                	mov    %eax,%edx
  8010b0:	eb 05                	jmp    8010b7 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010b2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8010b7:	89 d0                	mov    %edx,%eax
  8010b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010bc:	c9                   	leave  
  8010bd:	c3                   	ret    

008010be <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010be:	55                   	push   %ebp
  8010bf:	89 e5                	mov    %esp,%ebp
  8010c1:	57                   	push   %edi
  8010c2:	56                   	push   %esi
  8010c3:	53                   	push   %ebx
  8010c4:	83 ec 0c             	sub    $0xc,%esp
  8010c7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010ca:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010d2:	eb 21                	jmp    8010f5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010d4:	83 ec 04             	sub    $0x4,%esp
  8010d7:	89 f0                	mov    %esi,%eax
  8010d9:	29 d8                	sub    %ebx,%eax
  8010db:	50                   	push   %eax
  8010dc:	89 d8                	mov    %ebx,%eax
  8010de:	03 45 0c             	add    0xc(%ebp),%eax
  8010e1:	50                   	push   %eax
  8010e2:	57                   	push   %edi
  8010e3:	e8 45 ff ff ff       	call   80102d <read>
		if (m < 0)
  8010e8:	83 c4 10             	add    $0x10,%esp
  8010eb:	85 c0                	test   %eax,%eax
  8010ed:	78 10                	js     8010ff <readn+0x41>
			return m;
		if (m == 0)
  8010ef:	85 c0                	test   %eax,%eax
  8010f1:	74 0a                	je     8010fd <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010f3:	01 c3                	add    %eax,%ebx
  8010f5:	39 f3                	cmp    %esi,%ebx
  8010f7:	72 db                	jb     8010d4 <readn+0x16>
  8010f9:	89 d8                	mov    %ebx,%eax
  8010fb:	eb 02                	jmp    8010ff <readn+0x41>
  8010fd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801102:	5b                   	pop    %ebx
  801103:	5e                   	pop    %esi
  801104:	5f                   	pop    %edi
  801105:	5d                   	pop    %ebp
  801106:	c3                   	ret    

00801107 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	53                   	push   %ebx
  80110b:	83 ec 14             	sub    $0x14,%esp
  80110e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801111:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801114:	50                   	push   %eax
  801115:	53                   	push   %ebx
  801116:	e8 ac fc ff ff       	call   800dc7 <fd_lookup>
  80111b:	83 c4 08             	add    $0x8,%esp
  80111e:	89 c2                	mov    %eax,%edx
  801120:	85 c0                	test   %eax,%eax
  801122:	78 68                	js     80118c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801124:	83 ec 08             	sub    $0x8,%esp
  801127:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80112a:	50                   	push   %eax
  80112b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80112e:	ff 30                	pushl  (%eax)
  801130:	e8 e8 fc ff ff       	call   800e1d <dev_lookup>
  801135:	83 c4 10             	add    $0x10,%esp
  801138:	85 c0                	test   %eax,%eax
  80113a:	78 47                	js     801183 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80113c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80113f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801143:	75 21                	jne    801166 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801145:	a1 04 40 80 00       	mov    0x804004,%eax
  80114a:	8b 40 50             	mov    0x50(%eax),%eax
  80114d:	83 ec 04             	sub    $0x4,%esp
  801150:	53                   	push   %ebx
  801151:	50                   	push   %eax
  801152:	68 29 22 80 00       	push   $0x802229
  801157:	e8 5c f0 ff ff       	call   8001b8 <cprintf>
		return -E_INVAL;
  80115c:	83 c4 10             	add    $0x10,%esp
  80115f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801164:	eb 26                	jmp    80118c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801166:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801169:	8b 52 0c             	mov    0xc(%edx),%edx
  80116c:	85 d2                	test   %edx,%edx
  80116e:	74 17                	je     801187 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801170:	83 ec 04             	sub    $0x4,%esp
  801173:	ff 75 10             	pushl  0x10(%ebp)
  801176:	ff 75 0c             	pushl  0xc(%ebp)
  801179:	50                   	push   %eax
  80117a:	ff d2                	call   *%edx
  80117c:	89 c2                	mov    %eax,%edx
  80117e:	83 c4 10             	add    $0x10,%esp
  801181:	eb 09                	jmp    80118c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801183:	89 c2                	mov    %eax,%edx
  801185:	eb 05                	jmp    80118c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801187:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80118c:	89 d0                	mov    %edx,%eax
  80118e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801191:	c9                   	leave  
  801192:	c3                   	ret    

00801193 <seek>:

int
seek(int fdnum, off_t offset)
{
  801193:	55                   	push   %ebp
  801194:	89 e5                	mov    %esp,%ebp
  801196:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801199:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80119c:	50                   	push   %eax
  80119d:	ff 75 08             	pushl  0x8(%ebp)
  8011a0:	e8 22 fc ff ff       	call   800dc7 <fd_lookup>
  8011a5:	83 c4 08             	add    $0x8,%esp
  8011a8:	85 c0                	test   %eax,%eax
  8011aa:	78 0e                	js     8011ba <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011b2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011ba:	c9                   	leave  
  8011bb:	c3                   	ret    

008011bc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011bc:	55                   	push   %ebp
  8011bd:	89 e5                	mov    %esp,%ebp
  8011bf:	53                   	push   %ebx
  8011c0:	83 ec 14             	sub    $0x14,%esp
  8011c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c9:	50                   	push   %eax
  8011ca:	53                   	push   %ebx
  8011cb:	e8 f7 fb ff ff       	call   800dc7 <fd_lookup>
  8011d0:	83 c4 08             	add    $0x8,%esp
  8011d3:	89 c2                	mov    %eax,%edx
  8011d5:	85 c0                	test   %eax,%eax
  8011d7:	78 65                	js     80123e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d9:	83 ec 08             	sub    $0x8,%esp
  8011dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011df:	50                   	push   %eax
  8011e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e3:	ff 30                	pushl  (%eax)
  8011e5:	e8 33 fc ff ff       	call   800e1d <dev_lookup>
  8011ea:	83 c4 10             	add    $0x10,%esp
  8011ed:	85 c0                	test   %eax,%eax
  8011ef:	78 44                	js     801235 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011f8:	75 21                	jne    80121b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011fa:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011ff:	8b 40 50             	mov    0x50(%eax),%eax
  801202:	83 ec 04             	sub    $0x4,%esp
  801205:	53                   	push   %ebx
  801206:	50                   	push   %eax
  801207:	68 ec 21 80 00       	push   $0x8021ec
  80120c:	e8 a7 ef ff ff       	call   8001b8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801211:	83 c4 10             	add    $0x10,%esp
  801214:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801219:	eb 23                	jmp    80123e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80121b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80121e:	8b 52 18             	mov    0x18(%edx),%edx
  801221:	85 d2                	test   %edx,%edx
  801223:	74 14                	je     801239 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801225:	83 ec 08             	sub    $0x8,%esp
  801228:	ff 75 0c             	pushl  0xc(%ebp)
  80122b:	50                   	push   %eax
  80122c:	ff d2                	call   *%edx
  80122e:	89 c2                	mov    %eax,%edx
  801230:	83 c4 10             	add    $0x10,%esp
  801233:	eb 09                	jmp    80123e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801235:	89 c2                	mov    %eax,%edx
  801237:	eb 05                	jmp    80123e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801239:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80123e:	89 d0                	mov    %edx,%eax
  801240:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801243:	c9                   	leave  
  801244:	c3                   	ret    

00801245 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801245:	55                   	push   %ebp
  801246:	89 e5                	mov    %esp,%ebp
  801248:	53                   	push   %ebx
  801249:	83 ec 14             	sub    $0x14,%esp
  80124c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80124f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801252:	50                   	push   %eax
  801253:	ff 75 08             	pushl  0x8(%ebp)
  801256:	e8 6c fb ff ff       	call   800dc7 <fd_lookup>
  80125b:	83 c4 08             	add    $0x8,%esp
  80125e:	89 c2                	mov    %eax,%edx
  801260:	85 c0                	test   %eax,%eax
  801262:	78 58                	js     8012bc <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801264:	83 ec 08             	sub    $0x8,%esp
  801267:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126a:	50                   	push   %eax
  80126b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126e:	ff 30                	pushl  (%eax)
  801270:	e8 a8 fb ff ff       	call   800e1d <dev_lookup>
  801275:	83 c4 10             	add    $0x10,%esp
  801278:	85 c0                	test   %eax,%eax
  80127a:	78 37                	js     8012b3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80127c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80127f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801283:	74 32                	je     8012b7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801285:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801288:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80128f:	00 00 00 
	stat->st_isdir = 0;
  801292:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801299:	00 00 00 
	stat->st_dev = dev;
  80129c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012a2:	83 ec 08             	sub    $0x8,%esp
  8012a5:	53                   	push   %ebx
  8012a6:	ff 75 f0             	pushl  -0x10(%ebp)
  8012a9:	ff 50 14             	call   *0x14(%eax)
  8012ac:	89 c2                	mov    %eax,%edx
  8012ae:	83 c4 10             	add    $0x10,%esp
  8012b1:	eb 09                	jmp    8012bc <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b3:	89 c2                	mov    %eax,%edx
  8012b5:	eb 05                	jmp    8012bc <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012b7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012bc:	89 d0                	mov    %edx,%eax
  8012be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c1:	c9                   	leave  
  8012c2:	c3                   	ret    

008012c3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012c3:	55                   	push   %ebp
  8012c4:	89 e5                	mov    %esp,%ebp
  8012c6:	56                   	push   %esi
  8012c7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012c8:	83 ec 08             	sub    $0x8,%esp
  8012cb:	6a 00                	push   $0x0
  8012cd:	ff 75 08             	pushl  0x8(%ebp)
  8012d0:	e8 e3 01 00 00       	call   8014b8 <open>
  8012d5:	89 c3                	mov    %eax,%ebx
  8012d7:	83 c4 10             	add    $0x10,%esp
  8012da:	85 c0                	test   %eax,%eax
  8012dc:	78 1b                	js     8012f9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012de:	83 ec 08             	sub    $0x8,%esp
  8012e1:	ff 75 0c             	pushl  0xc(%ebp)
  8012e4:	50                   	push   %eax
  8012e5:	e8 5b ff ff ff       	call   801245 <fstat>
  8012ea:	89 c6                	mov    %eax,%esi
	close(fd);
  8012ec:	89 1c 24             	mov    %ebx,(%esp)
  8012ef:	e8 fd fb ff ff       	call   800ef1 <close>
	return r;
  8012f4:	83 c4 10             	add    $0x10,%esp
  8012f7:	89 f0                	mov    %esi,%eax
}
  8012f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012fc:	5b                   	pop    %ebx
  8012fd:	5e                   	pop    %esi
  8012fe:	5d                   	pop    %ebp
  8012ff:	c3                   	ret    

00801300 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	56                   	push   %esi
  801304:	53                   	push   %ebx
  801305:	89 c6                	mov    %eax,%esi
  801307:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801309:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801310:	75 12                	jne    801324 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801312:	83 ec 0c             	sub    $0xc,%esp
  801315:	6a 01                	push   $0x1
  801317:	e8 3c 08 00 00       	call   801b58 <ipc_find_env>
  80131c:	a3 00 40 80 00       	mov    %eax,0x804000
  801321:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801324:	6a 07                	push   $0x7
  801326:	68 00 50 80 00       	push   $0x805000
  80132b:	56                   	push   %esi
  80132c:	ff 35 00 40 80 00    	pushl  0x804000
  801332:	e8 bf 07 00 00       	call   801af6 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801337:	83 c4 0c             	add    $0xc,%esp
  80133a:	6a 00                	push   $0x0
  80133c:	53                   	push   %ebx
  80133d:	6a 00                	push   $0x0
  80133f:	e8 3d 07 00 00       	call   801a81 <ipc_recv>
}
  801344:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801347:	5b                   	pop    %ebx
  801348:	5e                   	pop    %esi
  801349:	5d                   	pop    %ebp
  80134a:	c3                   	ret    

0080134b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80134b:	55                   	push   %ebp
  80134c:	89 e5                	mov    %esp,%ebp
  80134e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801351:	8b 45 08             	mov    0x8(%ebp),%eax
  801354:	8b 40 0c             	mov    0xc(%eax),%eax
  801357:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80135c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80135f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801364:	ba 00 00 00 00       	mov    $0x0,%edx
  801369:	b8 02 00 00 00       	mov    $0x2,%eax
  80136e:	e8 8d ff ff ff       	call   801300 <fsipc>
}
  801373:	c9                   	leave  
  801374:	c3                   	ret    

00801375 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801375:	55                   	push   %ebp
  801376:	89 e5                	mov    %esp,%ebp
  801378:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80137b:	8b 45 08             	mov    0x8(%ebp),%eax
  80137e:	8b 40 0c             	mov    0xc(%eax),%eax
  801381:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801386:	ba 00 00 00 00       	mov    $0x0,%edx
  80138b:	b8 06 00 00 00       	mov    $0x6,%eax
  801390:	e8 6b ff ff ff       	call   801300 <fsipc>
}
  801395:	c9                   	leave  
  801396:	c3                   	ret    

00801397 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801397:	55                   	push   %ebp
  801398:	89 e5                	mov    %esp,%ebp
  80139a:	53                   	push   %ebx
  80139b:	83 ec 04             	sub    $0x4,%esp
  80139e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a4:	8b 40 0c             	mov    0xc(%eax),%eax
  8013a7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b1:	b8 05 00 00 00       	mov    $0x5,%eax
  8013b6:	e8 45 ff ff ff       	call   801300 <fsipc>
  8013bb:	85 c0                	test   %eax,%eax
  8013bd:	78 2c                	js     8013eb <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013bf:	83 ec 08             	sub    $0x8,%esp
  8013c2:	68 00 50 80 00       	push   $0x805000
  8013c7:	53                   	push   %ebx
  8013c8:	e8 70 f3 ff ff       	call   80073d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013cd:	a1 80 50 80 00       	mov    0x805080,%eax
  8013d2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013d8:	a1 84 50 80 00       	mov    0x805084,%eax
  8013dd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013e3:	83 c4 10             	add    $0x10,%esp
  8013e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ee:	c9                   	leave  
  8013ef:	c3                   	ret    

008013f0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013f0:	55                   	push   %ebp
  8013f1:	89 e5                	mov    %esp,%ebp
  8013f3:	83 ec 0c             	sub    $0xc,%esp
  8013f6:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8013fc:	8b 52 0c             	mov    0xc(%edx),%edx
  8013ff:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801405:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80140a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80140f:	0f 47 c2             	cmova  %edx,%eax
  801412:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801417:	50                   	push   %eax
  801418:	ff 75 0c             	pushl  0xc(%ebp)
  80141b:	68 08 50 80 00       	push   $0x805008
  801420:	e8 aa f4 ff ff       	call   8008cf <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801425:	ba 00 00 00 00       	mov    $0x0,%edx
  80142a:	b8 04 00 00 00       	mov    $0x4,%eax
  80142f:	e8 cc fe ff ff       	call   801300 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801434:	c9                   	leave  
  801435:	c3                   	ret    

00801436 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801436:	55                   	push   %ebp
  801437:	89 e5                	mov    %esp,%ebp
  801439:	56                   	push   %esi
  80143a:	53                   	push   %ebx
  80143b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80143e:	8b 45 08             	mov    0x8(%ebp),%eax
  801441:	8b 40 0c             	mov    0xc(%eax),%eax
  801444:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801449:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80144f:	ba 00 00 00 00       	mov    $0x0,%edx
  801454:	b8 03 00 00 00       	mov    $0x3,%eax
  801459:	e8 a2 fe ff ff       	call   801300 <fsipc>
  80145e:	89 c3                	mov    %eax,%ebx
  801460:	85 c0                	test   %eax,%eax
  801462:	78 4b                	js     8014af <devfile_read+0x79>
		return r;
	assert(r <= n);
  801464:	39 c6                	cmp    %eax,%esi
  801466:	73 16                	jae    80147e <devfile_read+0x48>
  801468:	68 58 22 80 00       	push   $0x802258
  80146d:	68 5f 22 80 00       	push   $0x80225f
  801472:	6a 7c                	push   $0x7c
  801474:	68 74 22 80 00       	push   $0x802274
  801479:	e8 bd 05 00 00       	call   801a3b <_panic>
	assert(r <= PGSIZE);
  80147e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801483:	7e 16                	jle    80149b <devfile_read+0x65>
  801485:	68 7f 22 80 00       	push   $0x80227f
  80148a:	68 5f 22 80 00       	push   $0x80225f
  80148f:	6a 7d                	push   $0x7d
  801491:	68 74 22 80 00       	push   $0x802274
  801496:	e8 a0 05 00 00       	call   801a3b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80149b:	83 ec 04             	sub    $0x4,%esp
  80149e:	50                   	push   %eax
  80149f:	68 00 50 80 00       	push   $0x805000
  8014a4:	ff 75 0c             	pushl  0xc(%ebp)
  8014a7:	e8 23 f4 ff ff       	call   8008cf <memmove>
	return r;
  8014ac:	83 c4 10             	add    $0x10,%esp
}
  8014af:	89 d8                	mov    %ebx,%eax
  8014b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b4:	5b                   	pop    %ebx
  8014b5:	5e                   	pop    %esi
  8014b6:	5d                   	pop    %ebp
  8014b7:	c3                   	ret    

008014b8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014b8:	55                   	push   %ebp
  8014b9:	89 e5                	mov    %esp,%ebp
  8014bb:	53                   	push   %ebx
  8014bc:	83 ec 20             	sub    $0x20,%esp
  8014bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014c2:	53                   	push   %ebx
  8014c3:	e8 3c f2 ff ff       	call   800704 <strlen>
  8014c8:	83 c4 10             	add    $0x10,%esp
  8014cb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014d0:	7f 67                	jg     801539 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014d2:	83 ec 0c             	sub    $0xc,%esp
  8014d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d8:	50                   	push   %eax
  8014d9:	e8 9a f8 ff ff       	call   800d78 <fd_alloc>
  8014de:	83 c4 10             	add    $0x10,%esp
		return r;
  8014e1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014e3:	85 c0                	test   %eax,%eax
  8014e5:	78 57                	js     80153e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014e7:	83 ec 08             	sub    $0x8,%esp
  8014ea:	53                   	push   %ebx
  8014eb:	68 00 50 80 00       	push   $0x805000
  8014f0:	e8 48 f2 ff ff       	call   80073d <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801500:	b8 01 00 00 00       	mov    $0x1,%eax
  801505:	e8 f6 fd ff ff       	call   801300 <fsipc>
  80150a:	89 c3                	mov    %eax,%ebx
  80150c:	83 c4 10             	add    $0x10,%esp
  80150f:	85 c0                	test   %eax,%eax
  801511:	79 14                	jns    801527 <open+0x6f>
		fd_close(fd, 0);
  801513:	83 ec 08             	sub    $0x8,%esp
  801516:	6a 00                	push   $0x0
  801518:	ff 75 f4             	pushl  -0xc(%ebp)
  80151b:	e8 50 f9 ff ff       	call   800e70 <fd_close>
		return r;
  801520:	83 c4 10             	add    $0x10,%esp
  801523:	89 da                	mov    %ebx,%edx
  801525:	eb 17                	jmp    80153e <open+0x86>
	}

	return fd2num(fd);
  801527:	83 ec 0c             	sub    $0xc,%esp
  80152a:	ff 75 f4             	pushl  -0xc(%ebp)
  80152d:	e8 1f f8 ff ff       	call   800d51 <fd2num>
  801532:	89 c2                	mov    %eax,%edx
  801534:	83 c4 10             	add    $0x10,%esp
  801537:	eb 05                	jmp    80153e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801539:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80153e:	89 d0                	mov    %edx,%eax
  801540:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801543:	c9                   	leave  
  801544:	c3                   	ret    

00801545 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801545:	55                   	push   %ebp
  801546:	89 e5                	mov    %esp,%ebp
  801548:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80154b:	ba 00 00 00 00       	mov    $0x0,%edx
  801550:	b8 08 00 00 00       	mov    $0x8,%eax
  801555:	e8 a6 fd ff ff       	call   801300 <fsipc>
}
  80155a:	c9                   	leave  
  80155b:	c3                   	ret    

0080155c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80155c:	55                   	push   %ebp
  80155d:	89 e5                	mov    %esp,%ebp
  80155f:	56                   	push   %esi
  801560:	53                   	push   %ebx
  801561:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801564:	83 ec 0c             	sub    $0xc,%esp
  801567:	ff 75 08             	pushl  0x8(%ebp)
  80156a:	e8 f2 f7 ff ff       	call   800d61 <fd2data>
  80156f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801571:	83 c4 08             	add    $0x8,%esp
  801574:	68 8b 22 80 00       	push   $0x80228b
  801579:	53                   	push   %ebx
  80157a:	e8 be f1 ff ff       	call   80073d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80157f:	8b 46 04             	mov    0x4(%esi),%eax
  801582:	2b 06                	sub    (%esi),%eax
  801584:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80158a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801591:	00 00 00 
	stat->st_dev = &devpipe;
  801594:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80159b:	30 80 00 
	return 0;
}
  80159e:	b8 00 00 00 00       	mov    $0x0,%eax
  8015a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015a6:	5b                   	pop    %ebx
  8015a7:	5e                   	pop    %esi
  8015a8:	5d                   	pop    %ebp
  8015a9:	c3                   	ret    

008015aa <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8015aa:	55                   	push   %ebp
  8015ab:	89 e5                	mov    %esp,%ebp
  8015ad:	53                   	push   %ebx
  8015ae:	83 ec 0c             	sub    $0xc,%esp
  8015b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015b4:	53                   	push   %ebx
  8015b5:	6a 00                	push   $0x0
  8015b7:	e8 09 f6 ff ff       	call   800bc5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015bc:	89 1c 24             	mov    %ebx,(%esp)
  8015bf:	e8 9d f7 ff ff       	call   800d61 <fd2data>
  8015c4:	83 c4 08             	add    $0x8,%esp
  8015c7:	50                   	push   %eax
  8015c8:	6a 00                	push   $0x0
  8015ca:	e8 f6 f5 ff ff       	call   800bc5 <sys_page_unmap>
}
  8015cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d2:	c9                   	leave  
  8015d3:	c3                   	ret    

008015d4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015d4:	55                   	push   %ebp
  8015d5:	89 e5                	mov    %esp,%ebp
  8015d7:	57                   	push   %edi
  8015d8:	56                   	push   %esi
  8015d9:	53                   	push   %ebx
  8015da:	83 ec 1c             	sub    $0x1c,%esp
  8015dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015e0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015e2:	a1 04 40 80 00       	mov    0x804004,%eax
  8015e7:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015ea:	83 ec 0c             	sub    $0xc,%esp
  8015ed:	ff 75 e0             	pushl  -0x20(%ebp)
  8015f0:	e8 a3 05 00 00       	call   801b98 <pageref>
  8015f5:	89 c3                	mov    %eax,%ebx
  8015f7:	89 3c 24             	mov    %edi,(%esp)
  8015fa:	e8 99 05 00 00       	call   801b98 <pageref>
  8015ff:	83 c4 10             	add    $0x10,%esp
  801602:	39 c3                	cmp    %eax,%ebx
  801604:	0f 94 c1             	sete   %cl
  801607:	0f b6 c9             	movzbl %cl,%ecx
  80160a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80160d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801613:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  801616:	39 ce                	cmp    %ecx,%esi
  801618:	74 1b                	je     801635 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80161a:	39 c3                	cmp    %eax,%ebx
  80161c:	75 c4                	jne    8015e2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80161e:	8b 42 60             	mov    0x60(%edx),%eax
  801621:	ff 75 e4             	pushl  -0x1c(%ebp)
  801624:	50                   	push   %eax
  801625:	56                   	push   %esi
  801626:	68 92 22 80 00       	push   $0x802292
  80162b:	e8 88 eb ff ff       	call   8001b8 <cprintf>
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	eb ad                	jmp    8015e2 <_pipeisclosed+0xe>
	}
}
  801635:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801638:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80163b:	5b                   	pop    %ebx
  80163c:	5e                   	pop    %esi
  80163d:	5f                   	pop    %edi
  80163e:	5d                   	pop    %ebp
  80163f:	c3                   	ret    

00801640 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801640:	55                   	push   %ebp
  801641:	89 e5                	mov    %esp,%ebp
  801643:	57                   	push   %edi
  801644:	56                   	push   %esi
  801645:	53                   	push   %ebx
  801646:	83 ec 28             	sub    $0x28,%esp
  801649:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80164c:	56                   	push   %esi
  80164d:	e8 0f f7 ff ff       	call   800d61 <fd2data>
  801652:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801654:	83 c4 10             	add    $0x10,%esp
  801657:	bf 00 00 00 00       	mov    $0x0,%edi
  80165c:	eb 4b                	jmp    8016a9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80165e:	89 da                	mov    %ebx,%edx
  801660:	89 f0                	mov    %esi,%eax
  801662:	e8 6d ff ff ff       	call   8015d4 <_pipeisclosed>
  801667:	85 c0                	test   %eax,%eax
  801669:	75 48                	jne    8016b3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80166b:	e8 b1 f4 ff ff       	call   800b21 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801670:	8b 43 04             	mov    0x4(%ebx),%eax
  801673:	8b 0b                	mov    (%ebx),%ecx
  801675:	8d 51 20             	lea    0x20(%ecx),%edx
  801678:	39 d0                	cmp    %edx,%eax
  80167a:	73 e2                	jae    80165e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80167c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80167f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801683:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801686:	89 c2                	mov    %eax,%edx
  801688:	c1 fa 1f             	sar    $0x1f,%edx
  80168b:	89 d1                	mov    %edx,%ecx
  80168d:	c1 e9 1b             	shr    $0x1b,%ecx
  801690:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801693:	83 e2 1f             	and    $0x1f,%edx
  801696:	29 ca                	sub    %ecx,%edx
  801698:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80169c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8016a0:	83 c0 01             	add    $0x1,%eax
  8016a3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016a6:	83 c7 01             	add    $0x1,%edi
  8016a9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8016ac:	75 c2                	jne    801670 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8016ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8016b1:	eb 05                	jmp    8016b8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016b3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8016b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016bb:	5b                   	pop    %ebx
  8016bc:	5e                   	pop    %esi
  8016bd:	5f                   	pop    %edi
  8016be:	5d                   	pop    %ebp
  8016bf:	c3                   	ret    

008016c0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	57                   	push   %edi
  8016c4:	56                   	push   %esi
  8016c5:	53                   	push   %ebx
  8016c6:	83 ec 18             	sub    $0x18,%esp
  8016c9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016cc:	57                   	push   %edi
  8016cd:	e8 8f f6 ff ff       	call   800d61 <fd2data>
  8016d2:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016d4:	83 c4 10             	add    $0x10,%esp
  8016d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016dc:	eb 3d                	jmp    80171b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016de:	85 db                	test   %ebx,%ebx
  8016e0:	74 04                	je     8016e6 <devpipe_read+0x26>
				return i;
  8016e2:	89 d8                	mov    %ebx,%eax
  8016e4:	eb 44                	jmp    80172a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016e6:	89 f2                	mov    %esi,%edx
  8016e8:	89 f8                	mov    %edi,%eax
  8016ea:	e8 e5 fe ff ff       	call   8015d4 <_pipeisclosed>
  8016ef:	85 c0                	test   %eax,%eax
  8016f1:	75 32                	jne    801725 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016f3:	e8 29 f4 ff ff       	call   800b21 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016f8:	8b 06                	mov    (%esi),%eax
  8016fa:	3b 46 04             	cmp    0x4(%esi),%eax
  8016fd:	74 df                	je     8016de <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016ff:	99                   	cltd   
  801700:	c1 ea 1b             	shr    $0x1b,%edx
  801703:	01 d0                	add    %edx,%eax
  801705:	83 e0 1f             	and    $0x1f,%eax
  801708:	29 d0                	sub    %edx,%eax
  80170a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80170f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801712:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801715:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801718:	83 c3 01             	add    $0x1,%ebx
  80171b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80171e:	75 d8                	jne    8016f8 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801720:	8b 45 10             	mov    0x10(%ebp),%eax
  801723:	eb 05                	jmp    80172a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801725:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80172a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80172d:	5b                   	pop    %ebx
  80172e:	5e                   	pop    %esi
  80172f:	5f                   	pop    %edi
  801730:	5d                   	pop    %ebp
  801731:	c3                   	ret    

00801732 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801732:	55                   	push   %ebp
  801733:	89 e5                	mov    %esp,%ebp
  801735:	56                   	push   %esi
  801736:	53                   	push   %ebx
  801737:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80173a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80173d:	50                   	push   %eax
  80173e:	e8 35 f6 ff ff       	call   800d78 <fd_alloc>
  801743:	83 c4 10             	add    $0x10,%esp
  801746:	89 c2                	mov    %eax,%edx
  801748:	85 c0                	test   %eax,%eax
  80174a:	0f 88 2c 01 00 00    	js     80187c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801750:	83 ec 04             	sub    $0x4,%esp
  801753:	68 07 04 00 00       	push   $0x407
  801758:	ff 75 f4             	pushl  -0xc(%ebp)
  80175b:	6a 00                	push   $0x0
  80175d:	e8 de f3 ff ff       	call   800b40 <sys_page_alloc>
  801762:	83 c4 10             	add    $0x10,%esp
  801765:	89 c2                	mov    %eax,%edx
  801767:	85 c0                	test   %eax,%eax
  801769:	0f 88 0d 01 00 00    	js     80187c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80176f:	83 ec 0c             	sub    $0xc,%esp
  801772:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801775:	50                   	push   %eax
  801776:	e8 fd f5 ff ff       	call   800d78 <fd_alloc>
  80177b:	89 c3                	mov    %eax,%ebx
  80177d:	83 c4 10             	add    $0x10,%esp
  801780:	85 c0                	test   %eax,%eax
  801782:	0f 88 e2 00 00 00    	js     80186a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801788:	83 ec 04             	sub    $0x4,%esp
  80178b:	68 07 04 00 00       	push   $0x407
  801790:	ff 75 f0             	pushl  -0x10(%ebp)
  801793:	6a 00                	push   $0x0
  801795:	e8 a6 f3 ff ff       	call   800b40 <sys_page_alloc>
  80179a:	89 c3                	mov    %eax,%ebx
  80179c:	83 c4 10             	add    $0x10,%esp
  80179f:	85 c0                	test   %eax,%eax
  8017a1:	0f 88 c3 00 00 00    	js     80186a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8017a7:	83 ec 0c             	sub    $0xc,%esp
  8017aa:	ff 75 f4             	pushl  -0xc(%ebp)
  8017ad:	e8 af f5 ff ff       	call   800d61 <fd2data>
  8017b2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017b4:	83 c4 0c             	add    $0xc,%esp
  8017b7:	68 07 04 00 00       	push   $0x407
  8017bc:	50                   	push   %eax
  8017bd:	6a 00                	push   $0x0
  8017bf:	e8 7c f3 ff ff       	call   800b40 <sys_page_alloc>
  8017c4:	89 c3                	mov    %eax,%ebx
  8017c6:	83 c4 10             	add    $0x10,%esp
  8017c9:	85 c0                	test   %eax,%eax
  8017cb:	0f 88 89 00 00 00    	js     80185a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017d1:	83 ec 0c             	sub    $0xc,%esp
  8017d4:	ff 75 f0             	pushl  -0x10(%ebp)
  8017d7:	e8 85 f5 ff ff       	call   800d61 <fd2data>
  8017dc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017e3:	50                   	push   %eax
  8017e4:	6a 00                	push   $0x0
  8017e6:	56                   	push   %esi
  8017e7:	6a 00                	push   $0x0
  8017e9:	e8 95 f3 ff ff       	call   800b83 <sys_page_map>
  8017ee:	89 c3                	mov    %eax,%ebx
  8017f0:	83 c4 20             	add    $0x20,%esp
  8017f3:	85 c0                	test   %eax,%eax
  8017f5:	78 55                	js     80184c <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017f7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801800:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801802:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801805:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80180c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801812:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801815:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801817:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80181a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801821:	83 ec 0c             	sub    $0xc,%esp
  801824:	ff 75 f4             	pushl  -0xc(%ebp)
  801827:	e8 25 f5 ff ff       	call   800d51 <fd2num>
  80182c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80182f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801831:	83 c4 04             	add    $0x4,%esp
  801834:	ff 75 f0             	pushl  -0x10(%ebp)
  801837:	e8 15 f5 ff ff       	call   800d51 <fd2num>
  80183c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80183f:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801842:	83 c4 10             	add    $0x10,%esp
  801845:	ba 00 00 00 00       	mov    $0x0,%edx
  80184a:	eb 30                	jmp    80187c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80184c:	83 ec 08             	sub    $0x8,%esp
  80184f:	56                   	push   %esi
  801850:	6a 00                	push   $0x0
  801852:	e8 6e f3 ff ff       	call   800bc5 <sys_page_unmap>
  801857:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80185a:	83 ec 08             	sub    $0x8,%esp
  80185d:	ff 75 f0             	pushl  -0x10(%ebp)
  801860:	6a 00                	push   $0x0
  801862:	e8 5e f3 ff ff       	call   800bc5 <sys_page_unmap>
  801867:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80186a:	83 ec 08             	sub    $0x8,%esp
  80186d:	ff 75 f4             	pushl  -0xc(%ebp)
  801870:	6a 00                	push   $0x0
  801872:	e8 4e f3 ff ff       	call   800bc5 <sys_page_unmap>
  801877:	83 c4 10             	add    $0x10,%esp
  80187a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80187c:	89 d0                	mov    %edx,%eax
  80187e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801881:	5b                   	pop    %ebx
  801882:	5e                   	pop    %esi
  801883:	5d                   	pop    %ebp
  801884:	c3                   	ret    

00801885 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801885:	55                   	push   %ebp
  801886:	89 e5                	mov    %esp,%ebp
  801888:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80188b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80188e:	50                   	push   %eax
  80188f:	ff 75 08             	pushl  0x8(%ebp)
  801892:	e8 30 f5 ff ff       	call   800dc7 <fd_lookup>
  801897:	83 c4 10             	add    $0x10,%esp
  80189a:	85 c0                	test   %eax,%eax
  80189c:	78 18                	js     8018b6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80189e:	83 ec 0c             	sub    $0xc,%esp
  8018a1:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a4:	e8 b8 f4 ff ff       	call   800d61 <fd2data>
	return _pipeisclosed(fd, p);
  8018a9:	89 c2                	mov    %eax,%edx
  8018ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ae:	e8 21 fd ff ff       	call   8015d4 <_pipeisclosed>
  8018b3:	83 c4 10             	add    $0x10,%esp
}
  8018b6:	c9                   	leave  
  8018b7:	c3                   	ret    

008018b8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8018b8:	55                   	push   %ebp
  8018b9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8018bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8018c0:	5d                   	pop    %ebp
  8018c1:	c3                   	ret    

008018c2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018c2:	55                   	push   %ebp
  8018c3:	89 e5                	mov    %esp,%ebp
  8018c5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018c8:	68 aa 22 80 00       	push   $0x8022aa
  8018cd:	ff 75 0c             	pushl  0xc(%ebp)
  8018d0:	e8 68 ee ff ff       	call   80073d <strcpy>
	return 0;
}
  8018d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8018da:	c9                   	leave  
  8018db:	c3                   	ret    

008018dc <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
  8018df:	57                   	push   %edi
  8018e0:	56                   	push   %esi
  8018e1:	53                   	push   %ebx
  8018e2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018e8:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018ed:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018f3:	eb 2d                	jmp    801922 <devcons_write+0x46>
		m = n - tot;
  8018f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018f8:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018fa:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018fd:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801902:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801905:	83 ec 04             	sub    $0x4,%esp
  801908:	53                   	push   %ebx
  801909:	03 45 0c             	add    0xc(%ebp),%eax
  80190c:	50                   	push   %eax
  80190d:	57                   	push   %edi
  80190e:	e8 bc ef ff ff       	call   8008cf <memmove>
		sys_cputs(buf, m);
  801913:	83 c4 08             	add    $0x8,%esp
  801916:	53                   	push   %ebx
  801917:	57                   	push   %edi
  801918:	e8 67 f1 ff ff       	call   800a84 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80191d:	01 de                	add    %ebx,%esi
  80191f:	83 c4 10             	add    $0x10,%esp
  801922:	89 f0                	mov    %esi,%eax
  801924:	3b 75 10             	cmp    0x10(%ebp),%esi
  801927:	72 cc                	jb     8018f5 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801929:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80192c:	5b                   	pop    %ebx
  80192d:	5e                   	pop    %esi
  80192e:	5f                   	pop    %edi
  80192f:	5d                   	pop    %ebp
  801930:	c3                   	ret    

00801931 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801931:	55                   	push   %ebp
  801932:	89 e5                	mov    %esp,%ebp
  801934:	83 ec 08             	sub    $0x8,%esp
  801937:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80193c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801940:	74 2a                	je     80196c <devcons_read+0x3b>
  801942:	eb 05                	jmp    801949 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801944:	e8 d8 f1 ff ff       	call   800b21 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801949:	e8 54 f1 ff ff       	call   800aa2 <sys_cgetc>
  80194e:	85 c0                	test   %eax,%eax
  801950:	74 f2                	je     801944 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801952:	85 c0                	test   %eax,%eax
  801954:	78 16                	js     80196c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801956:	83 f8 04             	cmp    $0x4,%eax
  801959:	74 0c                	je     801967 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80195b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80195e:	88 02                	mov    %al,(%edx)
	return 1;
  801960:	b8 01 00 00 00       	mov    $0x1,%eax
  801965:	eb 05                	jmp    80196c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801967:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80196c:	c9                   	leave  
  80196d:	c3                   	ret    

0080196e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80196e:	55                   	push   %ebp
  80196f:	89 e5                	mov    %esp,%ebp
  801971:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801974:	8b 45 08             	mov    0x8(%ebp),%eax
  801977:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80197a:	6a 01                	push   $0x1
  80197c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80197f:	50                   	push   %eax
  801980:	e8 ff f0 ff ff       	call   800a84 <sys_cputs>
}
  801985:	83 c4 10             	add    $0x10,%esp
  801988:	c9                   	leave  
  801989:	c3                   	ret    

0080198a <getchar>:

int
getchar(void)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801990:	6a 01                	push   $0x1
  801992:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801995:	50                   	push   %eax
  801996:	6a 00                	push   $0x0
  801998:	e8 90 f6 ff ff       	call   80102d <read>
	if (r < 0)
  80199d:	83 c4 10             	add    $0x10,%esp
  8019a0:	85 c0                	test   %eax,%eax
  8019a2:	78 0f                	js     8019b3 <getchar+0x29>
		return r;
	if (r < 1)
  8019a4:	85 c0                	test   %eax,%eax
  8019a6:	7e 06                	jle    8019ae <getchar+0x24>
		return -E_EOF;
	return c;
  8019a8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8019ac:	eb 05                	jmp    8019b3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8019ae:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8019b3:	c9                   	leave  
  8019b4:	c3                   	ret    

008019b5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8019b5:	55                   	push   %ebp
  8019b6:	89 e5                	mov    %esp,%ebp
  8019b8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019be:	50                   	push   %eax
  8019bf:	ff 75 08             	pushl  0x8(%ebp)
  8019c2:	e8 00 f4 ff ff       	call   800dc7 <fd_lookup>
  8019c7:	83 c4 10             	add    $0x10,%esp
  8019ca:	85 c0                	test   %eax,%eax
  8019cc:	78 11                	js     8019df <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019d7:	39 10                	cmp    %edx,(%eax)
  8019d9:	0f 94 c0             	sete   %al
  8019dc:	0f b6 c0             	movzbl %al,%eax
}
  8019df:	c9                   	leave  
  8019e0:	c3                   	ret    

008019e1 <opencons>:

int
opencons(void)
{
  8019e1:	55                   	push   %ebp
  8019e2:	89 e5                	mov    %esp,%ebp
  8019e4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ea:	50                   	push   %eax
  8019eb:	e8 88 f3 ff ff       	call   800d78 <fd_alloc>
  8019f0:	83 c4 10             	add    $0x10,%esp
		return r;
  8019f3:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019f5:	85 c0                	test   %eax,%eax
  8019f7:	78 3e                	js     801a37 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019f9:	83 ec 04             	sub    $0x4,%esp
  8019fc:	68 07 04 00 00       	push   $0x407
  801a01:	ff 75 f4             	pushl  -0xc(%ebp)
  801a04:	6a 00                	push   $0x0
  801a06:	e8 35 f1 ff ff       	call   800b40 <sys_page_alloc>
  801a0b:	83 c4 10             	add    $0x10,%esp
		return r;
  801a0e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a10:	85 c0                	test   %eax,%eax
  801a12:	78 23                	js     801a37 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a14:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a1d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a22:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a29:	83 ec 0c             	sub    $0xc,%esp
  801a2c:	50                   	push   %eax
  801a2d:	e8 1f f3 ff ff       	call   800d51 <fd2num>
  801a32:	89 c2                	mov    %eax,%edx
  801a34:	83 c4 10             	add    $0x10,%esp
}
  801a37:	89 d0                	mov    %edx,%eax
  801a39:	c9                   	leave  
  801a3a:	c3                   	ret    

00801a3b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a3b:	55                   	push   %ebp
  801a3c:	89 e5                	mov    %esp,%ebp
  801a3e:	56                   	push   %esi
  801a3f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a40:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a43:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a49:	e8 b4 f0 ff ff       	call   800b02 <sys_getenvid>
  801a4e:	83 ec 0c             	sub    $0xc,%esp
  801a51:	ff 75 0c             	pushl  0xc(%ebp)
  801a54:	ff 75 08             	pushl  0x8(%ebp)
  801a57:	56                   	push   %esi
  801a58:	50                   	push   %eax
  801a59:	68 b8 22 80 00       	push   $0x8022b8
  801a5e:	e8 55 e7 ff ff       	call   8001b8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a63:	83 c4 18             	add    $0x18,%esp
  801a66:	53                   	push   %ebx
  801a67:	ff 75 10             	pushl  0x10(%ebp)
  801a6a:	e8 f8 e6 ff ff       	call   800167 <vcprintf>
	cprintf("\n");
  801a6f:	c7 04 24 a3 22 80 00 	movl   $0x8022a3,(%esp)
  801a76:	e8 3d e7 ff ff       	call   8001b8 <cprintf>
  801a7b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a7e:	cc                   	int3   
  801a7f:	eb fd                	jmp    801a7e <_panic+0x43>

00801a81 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a81:	55                   	push   %ebp
  801a82:	89 e5                	mov    %esp,%ebp
  801a84:	56                   	push   %esi
  801a85:	53                   	push   %ebx
  801a86:	8b 75 08             	mov    0x8(%ebp),%esi
  801a89:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801a8f:	85 c0                	test   %eax,%eax
  801a91:	75 12                	jne    801aa5 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801a93:	83 ec 0c             	sub    $0xc,%esp
  801a96:	68 00 00 c0 ee       	push   $0xeec00000
  801a9b:	e8 50 f2 ff ff       	call   800cf0 <sys_ipc_recv>
  801aa0:	83 c4 10             	add    $0x10,%esp
  801aa3:	eb 0c                	jmp    801ab1 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801aa5:	83 ec 0c             	sub    $0xc,%esp
  801aa8:	50                   	push   %eax
  801aa9:	e8 42 f2 ff ff       	call   800cf0 <sys_ipc_recv>
  801aae:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801ab1:	85 f6                	test   %esi,%esi
  801ab3:	0f 95 c1             	setne  %cl
  801ab6:	85 db                	test   %ebx,%ebx
  801ab8:	0f 95 c2             	setne  %dl
  801abb:	84 d1                	test   %dl,%cl
  801abd:	74 09                	je     801ac8 <ipc_recv+0x47>
  801abf:	89 c2                	mov    %eax,%edx
  801ac1:	c1 ea 1f             	shr    $0x1f,%edx
  801ac4:	84 d2                	test   %dl,%dl
  801ac6:	75 27                	jne    801aef <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801ac8:	85 f6                	test   %esi,%esi
  801aca:	74 0a                	je     801ad6 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801acc:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad1:	8b 40 7c             	mov    0x7c(%eax),%eax
  801ad4:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801ad6:	85 db                	test   %ebx,%ebx
  801ad8:	74 0d                	je     801ae7 <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  801ada:	a1 04 40 80 00       	mov    0x804004,%eax
  801adf:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801ae5:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ae7:	a1 04 40 80 00       	mov    0x804004,%eax
  801aec:	8b 40 78             	mov    0x78(%eax),%eax
}
  801aef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af2:	5b                   	pop    %ebx
  801af3:	5e                   	pop    %esi
  801af4:	5d                   	pop    %ebp
  801af5:	c3                   	ret    

00801af6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	57                   	push   %edi
  801afa:	56                   	push   %esi
  801afb:	53                   	push   %ebx
  801afc:	83 ec 0c             	sub    $0xc,%esp
  801aff:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b02:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b05:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801b08:	85 db                	test   %ebx,%ebx
  801b0a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b0f:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801b12:	ff 75 14             	pushl  0x14(%ebp)
  801b15:	53                   	push   %ebx
  801b16:	56                   	push   %esi
  801b17:	57                   	push   %edi
  801b18:	e8 b0 f1 ff ff       	call   800ccd <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801b1d:	89 c2                	mov    %eax,%edx
  801b1f:	c1 ea 1f             	shr    $0x1f,%edx
  801b22:	83 c4 10             	add    $0x10,%esp
  801b25:	84 d2                	test   %dl,%dl
  801b27:	74 17                	je     801b40 <ipc_send+0x4a>
  801b29:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b2c:	74 12                	je     801b40 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801b2e:	50                   	push   %eax
  801b2f:	68 dc 22 80 00       	push   $0x8022dc
  801b34:	6a 47                	push   $0x47
  801b36:	68 ea 22 80 00       	push   $0x8022ea
  801b3b:	e8 fb fe ff ff       	call   801a3b <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801b40:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b43:	75 07                	jne    801b4c <ipc_send+0x56>
			sys_yield();
  801b45:	e8 d7 ef ff ff       	call   800b21 <sys_yield>
  801b4a:	eb c6                	jmp    801b12 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801b4c:	85 c0                	test   %eax,%eax
  801b4e:	75 c2                	jne    801b12 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801b50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b53:	5b                   	pop    %ebx
  801b54:	5e                   	pop    %esi
  801b55:	5f                   	pop    %edi
  801b56:	5d                   	pop    %ebp
  801b57:	c3                   	ret    

00801b58 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b58:	55                   	push   %ebp
  801b59:	89 e5                	mov    %esp,%ebp
  801b5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b5e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b63:	89 c2                	mov    %eax,%edx
  801b65:	c1 e2 07             	shl    $0x7,%edx
  801b68:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801b6f:	8b 52 58             	mov    0x58(%edx),%edx
  801b72:	39 ca                	cmp    %ecx,%edx
  801b74:	75 11                	jne    801b87 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801b76:	89 c2                	mov    %eax,%edx
  801b78:	c1 e2 07             	shl    $0x7,%edx
  801b7b:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801b82:	8b 40 50             	mov    0x50(%eax),%eax
  801b85:	eb 0f                	jmp    801b96 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b87:	83 c0 01             	add    $0x1,%eax
  801b8a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b8f:	75 d2                	jne    801b63 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b91:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b96:	5d                   	pop    %ebp
  801b97:	c3                   	ret    

00801b98 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b98:	55                   	push   %ebp
  801b99:	89 e5                	mov    %esp,%ebp
  801b9b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b9e:	89 d0                	mov    %edx,%eax
  801ba0:	c1 e8 16             	shr    $0x16,%eax
  801ba3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801baa:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801baf:	f6 c1 01             	test   $0x1,%cl
  801bb2:	74 1d                	je     801bd1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bb4:	c1 ea 0c             	shr    $0xc,%edx
  801bb7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bbe:	f6 c2 01             	test   $0x1,%dl
  801bc1:	74 0e                	je     801bd1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bc3:	c1 ea 0c             	shr    $0xc,%edx
  801bc6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bcd:	ef 
  801bce:	0f b7 c0             	movzwl %ax,%eax
}
  801bd1:	5d                   	pop    %ebp
  801bd2:	c3                   	ret    
  801bd3:	66 90                	xchg   %ax,%ax
  801bd5:	66 90                	xchg   %ax,%ax
  801bd7:	66 90                	xchg   %ax,%ax
  801bd9:	66 90                	xchg   %ax,%ax
  801bdb:	66 90                	xchg   %ax,%ax
  801bdd:	66 90                	xchg   %ax,%ax
  801bdf:	90                   	nop

00801be0 <__udivdi3>:
  801be0:	55                   	push   %ebp
  801be1:	57                   	push   %edi
  801be2:	56                   	push   %esi
  801be3:	53                   	push   %ebx
  801be4:	83 ec 1c             	sub    $0x1c,%esp
  801be7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801beb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bf3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801bf7:	85 f6                	test   %esi,%esi
  801bf9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bfd:	89 ca                	mov    %ecx,%edx
  801bff:	89 f8                	mov    %edi,%eax
  801c01:	75 3d                	jne    801c40 <__udivdi3+0x60>
  801c03:	39 cf                	cmp    %ecx,%edi
  801c05:	0f 87 c5 00 00 00    	ja     801cd0 <__udivdi3+0xf0>
  801c0b:	85 ff                	test   %edi,%edi
  801c0d:	89 fd                	mov    %edi,%ebp
  801c0f:	75 0b                	jne    801c1c <__udivdi3+0x3c>
  801c11:	b8 01 00 00 00       	mov    $0x1,%eax
  801c16:	31 d2                	xor    %edx,%edx
  801c18:	f7 f7                	div    %edi
  801c1a:	89 c5                	mov    %eax,%ebp
  801c1c:	89 c8                	mov    %ecx,%eax
  801c1e:	31 d2                	xor    %edx,%edx
  801c20:	f7 f5                	div    %ebp
  801c22:	89 c1                	mov    %eax,%ecx
  801c24:	89 d8                	mov    %ebx,%eax
  801c26:	89 cf                	mov    %ecx,%edi
  801c28:	f7 f5                	div    %ebp
  801c2a:	89 c3                	mov    %eax,%ebx
  801c2c:	89 d8                	mov    %ebx,%eax
  801c2e:	89 fa                	mov    %edi,%edx
  801c30:	83 c4 1c             	add    $0x1c,%esp
  801c33:	5b                   	pop    %ebx
  801c34:	5e                   	pop    %esi
  801c35:	5f                   	pop    %edi
  801c36:	5d                   	pop    %ebp
  801c37:	c3                   	ret    
  801c38:	90                   	nop
  801c39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c40:	39 ce                	cmp    %ecx,%esi
  801c42:	77 74                	ja     801cb8 <__udivdi3+0xd8>
  801c44:	0f bd fe             	bsr    %esi,%edi
  801c47:	83 f7 1f             	xor    $0x1f,%edi
  801c4a:	0f 84 98 00 00 00    	je     801ce8 <__udivdi3+0x108>
  801c50:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c55:	89 f9                	mov    %edi,%ecx
  801c57:	89 c5                	mov    %eax,%ebp
  801c59:	29 fb                	sub    %edi,%ebx
  801c5b:	d3 e6                	shl    %cl,%esi
  801c5d:	89 d9                	mov    %ebx,%ecx
  801c5f:	d3 ed                	shr    %cl,%ebp
  801c61:	89 f9                	mov    %edi,%ecx
  801c63:	d3 e0                	shl    %cl,%eax
  801c65:	09 ee                	or     %ebp,%esi
  801c67:	89 d9                	mov    %ebx,%ecx
  801c69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c6d:	89 d5                	mov    %edx,%ebp
  801c6f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c73:	d3 ed                	shr    %cl,%ebp
  801c75:	89 f9                	mov    %edi,%ecx
  801c77:	d3 e2                	shl    %cl,%edx
  801c79:	89 d9                	mov    %ebx,%ecx
  801c7b:	d3 e8                	shr    %cl,%eax
  801c7d:	09 c2                	or     %eax,%edx
  801c7f:	89 d0                	mov    %edx,%eax
  801c81:	89 ea                	mov    %ebp,%edx
  801c83:	f7 f6                	div    %esi
  801c85:	89 d5                	mov    %edx,%ebp
  801c87:	89 c3                	mov    %eax,%ebx
  801c89:	f7 64 24 0c          	mull   0xc(%esp)
  801c8d:	39 d5                	cmp    %edx,%ebp
  801c8f:	72 10                	jb     801ca1 <__udivdi3+0xc1>
  801c91:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c95:	89 f9                	mov    %edi,%ecx
  801c97:	d3 e6                	shl    %cl,%esi
  801c99:	39 c6                	cmp    %eax,%esi
  801c9b:	73 07                	jae    801ca4 <__udivdi3+0xc4>
  801c9d:	39 d5                	cmp    %edx,%ebp
  801c9f:	75 03                	jne    801ca4 <__udivdi3+0xc4>
  801ca1:	83 eb 01             	sub    $0x1,%ebx
  801ca4:	31 ff                	xor    %edi,%edi
  801ca6:	89 d8                	mov    %ebx,%eax
  801ca8:	89 fa                	mov    %edi,%edx
  801caa:	83 c4 1c             	add    $0x1c,%esp
  801cad:	5b                   	pop    %ebx
  801cae:	5e                   	pop    %esi
  801caf:	5f                   	pop    %edi
  801cb0:	5d                   	pop    %ebp
  801cb1:	c3                   	ret    
  801cb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cb8:	31 ff                	xor    %edi,%edi
  801cba:	31 db                	xor    %ebx,%ebx
  801cbc:	89 d8                	mov    %ebx,%eax
  801cbe:	89 fa                	mov    %edi,%edx
  801cc0:	83 c4 1c             	add    $0x1c,%esp
  801cc3:	5b                   	pop    %ebx
  801cc4:	5e                   	pop    %esi
  801cc5:	5f                   	pop    %edi
  801cc6:	5d                   	pop    %ebp
  801cc7:	c3                   	ret    
  801cc8:	90                   	nop
  801cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cd0:	89 d8                	mov    %ebx,%eax
  801cd2:	f7 f7                	div    %edi
  801cd4:	31 ff                	xor    %edi,%edi
  801cd6:	89 c3                	mov    %eax,%ebx
  801cd8:	89 d8                	mov    %ebx,%eax
  801cda:	89 fa                	mov    %edi,%edx
  801cdc:	83 c4 1c             	add    $0x1c,%esp
  801cdf:	5b                   	pop    %ebx
  801ce0:	5e                   	pop    %esi
  801ce1:	5f                   	pop    %edi
  801ce2:	5d                   	pop    %ebp
  801ce3:	c3                   	ret    
  801ce4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ce8:	39 ce                	cmp    %ecx,%esi
  801cea:	72 0c                	jb     801cf8 <__udivdi3+0x118>
  801cec:	31 db                	xor    %ebx,%ebx
  801cee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cf2:	0f 87 34 ff ff ff    	ja     801c2c <__udivdi3+0x4c>
  801cf8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801cfd:	e9 2a ff ff ff       	jmp    801c2c <__udivdi3+0x4c>
  801d02:	66 90                	xchg   %ax,%ax
  801d04:	66 90                	xchg   %ax,%ax
  801d06:	66 90                	xchg   %ax,%ax
  801d08:	66 90                	xchg   %ax,%ax
  801d0a:	66 90                	xchg   %ax,%ax
  801d0c:	66 90                	xchg   %ax,%ax
  801d0e:	66 90                	xchg   %ax,%ax

00801d10 <__umoddi3>:
  801d10:	55                   	push   %ebp
  801d11:	57                   	push   %edi
  801d12:	56                   	push   %esi
  801d13:	53                   	push   %ebx
  801d14:	83 ec 1c             	sub    $0x1c,%esp
  801d17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d1b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d1f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d27:	85 d2                	test   %edx,%edx
  801d29:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d31:	89 f3                	mov    %esi,%ebx
  801d33:	89 3c 24             	mov    %edi,(%esp)
  801d36:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d3a:	75 1c                	jne    801d58 <__umoddi3+0x48>
  801d3c:	39 f7                	cmp    %esi,%edi
  801d3e:	76 50                	jbe    801d90 <__umoddi3+0x80>
  801d40:	89 c8                	mov    %ecx,%eax
  801d42:	89 f2                	mov    %esi,%edx
  801d44:	f7 f7                	div    %edi
  801d46:	89 d0                	mov    %edx,%eax
  801d48:	31 d2                	xor    %edx,%edx
  801d4a:	83 c4 1c             	add    $0x1c,%esp
  801d4d:	5b                   	pop    %ebx
  801d4e:	5e                   	pop    %esi
  801d4f:	5f                   	pop    %edi
  801d50:	5d                   	pop    %ebp
  801d51:	c3                   	ret    
  801d52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d58:	39 f2                	cmp    %esi,%edx
  801d5a:	89 d0                	mov    %edx,%eax
  801d5c:	77 52                	ja     801db0 <__umoddi3+0xa0>
  801d5e:	0f bd ea             	bsr    %edx,%ebp
  801d61:	83 f5 1f             	xor    $0x1f,%ebp
  801d64:	75 5a                	jne    801dc0 <__umoddi3+0xb0>
  801d66:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d6a:	0f 82 e0 00 00 00    	jb     801e50 <__umoddi3+0x140>
  801d70:	39 0c 24             	cmp    %ecx,(%esp)
  801d73:	0f 86 d7 00 00 00    	jbe    801e50 <__umoddi3+0x140>
  801d79:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d7d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d81:	83 c4 1c             	add    $0x1c,%esp
  801d84:	5b                   	pop    %ebx
  801d85:	5e                   	pop    %esi
  801d86:	5f                   	pop    %edi
  801d87:	5d                   	pop    %ebp
  801d88:	c3                   	ret    
  801d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d90:	85 ff                	test   %edi,%edi
  801d92:	89 fd                	mov    %edi,%ebp
  801d94:	75 0b                	jne    801da1 <__umoddi3+0x91>
  801d96:	b8 01 00 00 00       	mov    $0x1,%eax
  801d9b:	31 d2                	xor    %edx,%edx
  801d9d:	f7 f7                	div    %edi
  801d9f:	89 c5                	mov    %eax,%ebp
  801da1:	89 f0                	mov    %esi,%eax
  801da3:	31 d2                	xor    %edx,%edx
  801da5:	f7 f5                	div    %ebp
  801da7:	89 c8                	mov    %ecx,%eax
  801da9:	f7 f5                	div    %ebp
  801dab:	89 d0                	mov    %edx,%eax
  801dad:	eb 99                	jmp    801d48 <__umoddi3+0x38>
  801daf:	90                   	nop
  801db0:	89 c8                	mov    %ecx,%eax
  801db2:	89 f2                	mov    %esi,%edx
  801db4:	83 c4 1c             	add    $0x1c,%esp
  801db7:	5b                   	pop    %ebx
  801db8:	5e                   	pop    %esi
  801db9:	5f                   	pop    %edi
  801dba:	5d                   	pop    %ebp
  801dbb:	c3                   	ret    
  801dbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801dc0:	8b 34 24             	mov    (%esp),%esi
  801dc3:	bf 20 00 00 00       	mov    $0x20,%edi
  801dc8:	89 e9                	mov    %ebp,%ecx
  801dca:	29 ef                	sub    %ebp,%edi
  801dcc:	d3 e0                	shl    %cl,%eax
  801dce:	89 f9                	mov    %edi,%ecx
  801dd0:	89 f2                	mov    %esi,%edx
  801dd2:	d3 ea                	shr    %cl,%edx
  801dd4:	89 e9                	mov    %ebp,%ecx
  801dd6:	09 c2                	or     %eax,%edx
  801dd8:	89 d8                	mov    %ebx,%eax
  801dda:	89 14 24             	mov    %edx,(%esp)
  801ddd:	89 f2                	mov    %esi,%edx
  801ddf:	d3 e2                	shl    %cl,%edx
  801de1:	89 f9                	mov    %edi,%ecx
  801de3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801de7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801deb:	d3 e8                	shr    %cl,%eax
  801ded:	89 e9                	mov    %ebp,%ecx
  801def:	89 c6                	mov    %eax,%esi
  801df1:	d3 e3                	shl    %cl,%ebx
  801df3:	89 f9                	mov    %edi,%ecx
  801df5:	89 d0                	mov    %edx,%eax
  801df7:	d3 e8                	shr    %cl,%eax
  801df9:	89 e9                	mov    %ebp,%ecx
  801dfb:	09 d8                	or     %ebx,%eax
  801dfd:	89 d3                	mov    %edx,%ebx
  801dff:	89 f2                	mov    %esi,%edx
  801e01:	f7 34 24             	divl   (%esp)
  801e04:	89 d6                	mov    %edx,%esi
  801e06:	d3 e3                	shl    %cl,%ebx
  801e08:	f7 64 24 04          	mull   0x4(%esp)
  801e0c:	39 d6                	cmp    %edx,%esi
  801e0e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e12:	89 d1                	mov    %edx,%ecx
  801e14:	89 c3                	mov    %eax,%ebx
  801e16:	72 08                	jb     801e20 <__umoddi3+0x110>
  801e18:	75 11                	jne    801e2b <__umoddi3+0x11b>
  801e1a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e1e:	73 0b                	jae    801e2b <__umoddi3+0x11b>
  801e20:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e24:	1b 14 24             	sbb    (%esp),%edx
  801e27:	89 d1                	mov    %edx,%ecx
  801e29:	89 c3                	mov    %eax,%ebx
  801e2b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e2f:	29 da                	sub    %ebx,%edx
  801e31:	19 ce                	sbb    %ecx,%esi
  801e33:	89 f9                	mov    %edi,%ecx
  801e35:	89 f0                	mov    %esi,%eax
  801e37:	d3 e0                	shl    %cl,%eax
  801e39:	89 e9                	mov    %ebp,%ecx
  801e3b:	d3 ea                	shr    %cl,%edx
  801e3d:	89 e9                	mov    %ebp,%ecx
  801e3f:	d3 ee                	shr    %cl,%esi
  801e41:	09 d0                	or     %edx,%eax
  801e43:	89 f2                	mov    %esi,%edx
  801e45:	83 c4 1c             	add    $0x1c,%esp
  801e48:	5b                   	pop    %ebx
  801e49:	5e                   	pop    %esi
  801e4a:	5f                   	pop    %edi
  801e4b:	5d                   	pop    %ebp
  801e4c:	c3                   	ret    
  801e4d:	8d 76 00             	lea    0x0(%esi),%esi
  801e50:	29 f9                	sub    %edi,%ecx
  801e52:	19 d6                	sbb    %edx,%esi
  801e54:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e58:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e5c:	e9 18 ff ff ff       	jmp    801d79 <__umoddi3+0x69>
