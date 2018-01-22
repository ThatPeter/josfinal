
obj/user/yield.debug:     file format elf32-i386


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
  80002c:	e8 69 00 00 00       	call   80009a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 04 40 80 00       	mov    0x804004,%eax
  80003f:	8b 40 50             	mov    0x50(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 a0 1e 80 00       	push   $0x801ea0
  800048:	e8 a0 01 00 00       	call   8001ed <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 fc 0a 00 00       	call   800b56 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 04 40 80 00       	mov    0x804004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  80005f:	8b 40 50             	mov    0x50(%eax),%eax
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 c0 1e 80 00       	push   $0x801ec0
  80006c:	e8 7c 01 00 00       	call   8001ed <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800071:	83 c3 01             	add    $0x1,%ebx
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	83 fb 05             	cmp    $0x5,%ebx
  80007a:	75 d9                	jne    800055 <umain+0x22>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007c:	a1 04 40 80 00       	mov    0x804004,%eax
  800081:	8b 40 50             	mov    0x50(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 ec 1e 80 00       	push   $0x801eec
  80008d:	e8 5b 01 00 00       	call   8001ed <cprintf>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	57                   	push   %edi
  80009e:	56                   	push   %esi
  80009f:	53                   	push   %ebx
  8000a0:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000a3:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  8000aa:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  8000ad:	e8 85 0a 00 00       	call   800b37 <sys_getenvid>
  8000b2:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  8000b4:	83 ec 08             	sub    $0x8,%esp
  8000b7:	50                   	push   %eax
  8000b8:	68 0c 1f 80 00       	push   $0x801f0c
  8000bd:	e8 2b 01 00 00       	call   8001ed <cprintf>
  8000c2:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  8000c8:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000d5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  8000da:	89 c1                	mov    %eax,%ecx
  8000dc:	c1 e1 07             	shl    $0x7,%ecx
  8000df:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  8000e6:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  8000e9:	39 cb                	cmp    %ecx,%ebx
  8000eb:	0f 44 fa             	cmove  %edx,%edi
  8000ee:	b9 01 00 00 00       	mov    $0x1,%ecx
  8000f3:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000f6:	83 c0 01             	add    $0x1,%eax
  8000f9:	81 c2 84 00 00 00    	add    $0x84,%edx
  8000ff:	3d 00 04 00 00       	cmp    $0x400,%eax
  800104:	75 d4                	jne    8000da <libmain+0x40>
  800106:	89 f0                	mov    %esi,%eax
  800108:	84 c0                	test   %al,%al
  80010a:	74 06                	je     800112 <libmain+0x78>
  80010c:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800112:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800116:	7e 0a                	jle    800122 <libmain+0x88>
		binaryname = argv[0];
  800118:	8b 45 0c             	mov    0xc(%ebp),%eax
  80011b:	8b 00                	mov    (%eax),%eax
  80011d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800122:	83 ec 08             	sub    $0x8,%esp
  800125:	ff 75 0c             	pushl  0xc(%ebp)
  800128:	ff 75 08             	pushl  0x8(%ebp)
  80012b:	e8 03 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800130:	e8 0b 00 00 00       	call   800140 <exit>
}
  800135:	83 c4 10             	add    $0x10,%esp
  800138:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80013b:	5b                   	pop    %ebx
  80013c:	5e                   	pop    %esi
  80013d:	5f                   	pop    %edi
  80013e:	5d                   	pop    %ebp
  80013f:	c3                   	ret    

00800140 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800146:	e8 06 0e 00 00       	call   800f51 <close_all>
	sys_env_destroy(0);
  80014b:	83 ec 0c             	sub    $0xc,%esp
  80014e:	6a 00                	push   $0x0
  800150:	e8 a1 09 00 00       	call   800af6 <sys_env_destroy>
}
  800155:	83 c4 10             	add    $0x10,%esp
  800158:	c9                   	leave  
  800159:	c3                   	ret    

0080015a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	53                   	push   %ebx
  80015e:	83 ec 04             	sub    $0x4,%esp
  800161:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800164:	8b 13                	mov    (%ebx),%edx
  800166:	8d 42 01             	lea    0x1(%edx),%eax
  800169:	89 03                	mov    %eax,(%ebx)
  80016b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800172:	3d ff 00 00 00       	cmp    $0xff,%eax
  800177:	75 1a                	jne    800193 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800179:	83 ec 08             	sub    $0x8,%esp
  80017c:	68 ff 00 00 00       	push   $0xff
  800181:	8d 43 08             	lea    0x8(%ebx),%eax
  800184:	50                   	push   %eax
  800185:	e8 2f 09 00 00       	call   800ab9 <sys_cputs>
		b->idx = 0;
  80018a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800190:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800193:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800197:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019a:	c9                   	leave  
  80019b:	c3                   	ret    

0080019c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ac:	00 00 00 
	b.cnt = 0;
  8001af:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b9:	ff 75 0c             	pushl  0xc(%ebp)
  8001bc:	ff 75 08             	pushl  0x8(%ebp)
  8001bf:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c5:	50                   	push   %eax
  8001c6:	68 5a 01 80 00       	push   $0x80015a
  8001cb:	e8 54 01 00 00       	call   800324 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d0:	83 c4 08             	add    $0x8,%esp
  8001d3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001d9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001df:	50                   	push   %eax
  8001e0:	e8 d4 08 00 00       	call   800ab9 <sys_cputs>

	return b.cnt;
}
  8001e5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001eb:	c9                   	leave  
  8001ec:	c3                   	ret    

008001ed <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f6:	50                   	push   %eax
  8001f7:	ff 75 08             	pushl  0x8(%ebp)
  8001fa:	e8 9d ff ff ff       	call   80019c <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ff:	c9                   	leave  
  800200:	c3                   	ret    

00800201 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800201:	55                   	push   %ebp
  800202:	89 e5                	mov    %esp,%ebp
  800204:	57                   	push   %edi
  800205:	56                   	push   %esi
  800206:	53                   	push   %ebx
  800207:	83 ec 1c             	sub    $0x1c,%esp
  80020a:	89 c7                	mov    %eax,%edi
  80020c:	89 d6                	mov    %edx,%esi
  80020e:	8b 45 08             	mov    0x8(%ebp),%eax
  800211:	8b 55 0c             	mov    0xc(%ebp),%edx
  800214:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800217:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80021d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800222:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800225:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800228:	39 d3                	cmp    %edx,%ebx
  80022a:	72 05                	jb     800231 <printnum+0x30>
  80022c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80022f:	77 45                	ja     800276 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800231:	83 ec 0c             	sub    $0xc,%esp
  800234:	ff 75 18             	pushl  0x18(%ebp)
  800237:	8b 45 14             	mov    0x14(%ebp),%eax
  80023a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80023d:	53                   	push   %ebx
  80023e:	ff 75 10             	pushl  0x10(%ebp)
  800241:	83 ec 08             	sub    $0x8,%esp
  800244:	ff 75 e4             	pushl  -0x1c(%ebp)
  800247:	ff 75 e0             	pushl  -0x20(%ebp)
  80024a:	ff 75 dc             	pushl  -0x24(%ebp)
  80024d:	ff 75 d8             	pushl  -0x28(%ebp)
  800250:	e8 bb 19 00 00       	call   801c10 <__udivdi3>
  800255:	83 c4 18             	add    $0x18,%esp
  800258:	52                   	push   %edx
  800259:	50                   	push   %eax
  80025a:	89 f2                	mov    %esi,%edx
  80025c:	89 f8                	mov    %edi,%eax
  80025e:	e8 9e ff ff ff       	call   800201 <printnum>
  800263:	83 c4 20             	add    $0x20,%esp
  800266:	eb 18                	jmp    800280 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800268:	83 ec 08             	sub    $0x8,%esp
  80026b:	56                   	push   %esi
  80026c:	ff 75 18             	pushl  0x18(%ebp)
  80026f:	ff d7                	call   *%edi
  800271:	83 c4 10             	add    $0x10,%esp
  800274:	eb 03                	jmp    800279 <printnum+0x78>
  800276:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800279:	83 eb 01             	sub    $0x1,%ebx
  80027c:	85 db                	test   %ebx,%ebx
  80027e:	7f e8                	jg     800268 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800280:	83 ec 08             	sub    $0x8,%esp
  800283:	56                   	push   %esi
  800284:	83 ec 04             	sub    $0x4,%esp
  800287:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028a:	ff 75 e0             	pushl  -0x20(%ebp)
  80028d:	ff 75 dc             	pushl  -0x24(%ebp)
  800290:	ff 75 d8             	pushl  -0x28(%ebp)
  800293:	e8 a8 1a 00 00       	call   801d40 <__umoddi3>
  800298:	83 c4 14             	add    $0x14,%esp
  80029b:	0f be 80 35 1f 80 00 	movsbl 0x801f35(%eax),%eax
  8002a2:	50                   	push   %eax
  8002a3:	ff d7                	call   *%edi
}
  8002a5:	83 c4 10             	add    $0x10,%esp
  8002a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ab:	5b                   	pop    %ebx
  8002ac:	5e                   	pop    %esi
  8002ad:	5f                   	pop    %edi
  8002ae:	5d                   	pop    %ebp
  8002af:	c3                   	ret    

008002b0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b3:	83 fa 01             	cmp    $0x1,%edx
  8002b6:	7e 0e                	jle    8002c6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b8:	8b 10                	mov    (%eax),%edx
  8002ba:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002bd:	89 08                	mov    %ecx,(%eax)
  8002bf:	8b 02                	mov    (%edx),%eax
  8002c1:	8b 52 04             	mov    0x4(%edx),%edx
  8002c4:	eb 22                	jmp    8002e8 <getuint+0x38>
	else if (lflag)
  8002c6:	85 d2                	test   %edx,%edx
  8002c8:	74 10                	je     8002da <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ca:	8b 10                	mov    (%eax),%edx
  8002cc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002cf:	89 08                	mov    %ecx,(%eax)
  8002d1:	8b 02                	mov    (%edx),%eax
  8002d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d8:	eb 0e                	jmp    8002e8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002da:	8b 10                	mov    (%eax),%edx
  8002dc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002df:	89 08                	mov    %ecx,(%eax)
  8002e1:	8b 02                	mov    (%edx),%eax
  8002e3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e8:	5d                   	pop    %ebp
  8002e9:	c3                   	ret    

008002ea <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
  8002ed:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f4:	8b 10                	mov    (%eax),%edx
  8002f6:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f9:	73 0a                	jae    800305 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002fb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002fe:	89 08                	mov    %ecx,(%eax)
  800300:	8b 45 08             	mov    0x8(%ebp),%eax
  800303:	88 02                	mov    %al,(%edx)
}
  800305:	5d                   	pop    %ebp
  800306:	c3                   	ret    

00800307 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800307:	55                   	push   %ebp
  800308:	89 e5                	mov    %esp,%ebp
  80030a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80030d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800310:	50                   	push   %eax
  800311:	ff 75 10             	pushl  0x10(%ebp)
  800314:	ff 75 0c             	pushl  0xc(%ebp)
  800317:	ff 75 08             	pushl  0x8(%ebp)
  80031a:	e8 05 00 00 00       	call   800324 <vprintfmt>
	va_end(ap);
}
  80031f:	83 c4 10             	add    $0x10,%esp
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	57                   	push   %edi
  800328:	56                   	push   %esi
  800329:	53                   	push   %ebx
  80032a:	83 ec 2c             	sub    $0x2c,%esp
  80032d:	8b 75 08             	mov    0x8(%ebp),%esi
  800330:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800333:	8b 7d 10             	mov    0x10(%ebp),%edi
  800336:	eb 12                	jmp    80034a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800338:	85 c0                	test   %eax,%eax
  80033a:	0f 84 89 03 00 00    	je     8006c9 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800340:	83 ec 08             	sub    $0x8,%esp
  800343:	53                   	push   %ebx
  800344:	50                   	push   %eax
  800345:	ff d6                	call   *%esi
  800347:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80034a:	83 c7 01             	add    $0x1,%edi
  80034d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800351:	83 f8 25             	cmp    $0x25,%eax
  800354:	75 e2                	jne    800338 <vprintfmt+0x14>
  800356:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80035a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800361:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800368:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80036f:	ba 00 00 00 00       	mov    $0x0,%edx
  800374:	eb 07                	jmp    80037d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800376:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800379:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037d:	8d 47 01             	lea    0x1(%edi),%eax
  800380:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800383:	0f b6 07             	movzbl (%edi),%eax
  800386:	0f b6 c8             	movzbl %al,%ecx
  800389:	83 e8 23             	sub    $0x23,%eax
  80038c:	3c 55                	cmp    $0x55,%al
  80038e:	0f 87 1a 03 00 00    	ja     8006ae <vprintfmt+0x38a>
  800394:	0f b6 c0             	movzbl %al,%eax
  800397:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a5:	eb d6                	jmp    80037d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8003af:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003b9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003bc:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003bf:	83 fa 09             	cmp    $0x9,%edx
  8003c2:	77 39                	ja     8003fd <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003c7:	eb e9                	jmp    8003b2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cc:	8d 48 04             	lea    0x4(%eax),%ecx
  8003cf:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003d2:	8b 00                	mov    (%eax),%eax
  8003d4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003da:	eb 27                	jmp    800403 <vprintfmt+0xdf>
  8003dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003df:	85 c0                	test   %eax,%eax
  8003e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e6:	0f 49 c8             	cmovns %eax,%ecx
  8003e9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ef:	eb 8c                	jmp    80037d <vprintfmt+0x59>
  8003f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003fb:	eb 80                	jmp    80037d <vprintfmt+0x59>
  8003fd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800400:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800403:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800407:	0f 89 70 ff ff ff    	jns    80037d <vprintfmt+0x59>
				width = precision, precision = -1;
  80040d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800410:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800413:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80041a:	e9 5e ff ff ff       	jmp    80037d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80041f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800425:	e9 53 ff ff ff       	jmp    80037d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80042a:	8b 45 14             	mov    0x14(%ebp),%eax
  80042d:	8d 50 04             	lea    0x4(%eax),%edx
  800430:	89 55 14             	mov    %edx,0x14(%ebp)
  800433:	83 ec 08             	sub    $0x8,%esp
  800436:	53                   	push   %ebx
  800437:	ff 30                	pushl  (%eax)
  800439:	ff d6                	call   *%esi
			break;
  80043b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800441:	e9 04 ff ff ff       	jmp    80034a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800446:	8b 45 14             	mov    0x14(%ebp),%eax
  800449:	8d 50 04             	lea    0x4(%eax),%edx
  80044c:	89 55 14             	mov    %edx,0x14(%ebp)
  80044f:	8b 00                	mov    (%eax),%eax
  800451:	99                   	cltd   
  800452:	31 d0                	xor    %edx,%eax
  800454:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800456:	83 f8 0f             	cmp    $0xf,%eax
  800459:	7f 0b                	jg     800466 <vprintfmt+0x142>
  80045b:	8b 14 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%edx
  800462:	85 d2                	test   %edx,%edx
  800464:	75 18                	jne    80047e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800466:	50                   	push   %eax
  800467:	68 4d 1f 80 00       	push   $0x801f4d
  80046c:	53                   	push   %ebx
  80046d:	56                   	push   %esi
  80046e:	e8 94 fe ff ff       	call   800307 <printfmt>
  800473:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800476:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800479:	e9 cc fe ff ff       	jmp    80034a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80047e:	52                   	push   %edx
  80047f:	68 11 23 80 00       	push   $0x802311
  800484:	53                   	push   %ebx
  800485:	56                   	push   %esi
  800486:	e8 7c fe ff ff       	call   800307 <printfmt>
  80048b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800491:	e9 b4 fe ff ff       	jmp    80034a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800496:	8b 45 14             	mov    0x14(%ebp),%eax
  800499:	8d 50 04             	lea    0x4(%eax),%edx
  80049c:	89 55 14             	mov    %edx,0x14(%ebp)
  80049f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a1:	85 ff                	test   %edi,%edi
  8004a3:	b8 46 1f 80 00       	mov    $0x801f46,%eax
  8004a8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004ab:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004af:	0f 8e 94 00 00 00    	jle    800549 <vprintfmt+0x225>
  8004b5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004b9:	0f 84 98 00 00 00    	je     800557 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bf:	83 ec 08             	sub    $0x8,%esp
  8004c2:	ff 75 d0             	pushl  -0x30(%ebp)
  8004c5:	57                   	push   %edi
  8004c6:	e8 86 02 00 00       	call   800751 <strnlen>
  8004cb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ce:	29 c1                	sub    %eax,%ecx
  8004d0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004d3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004d6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004da:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004dd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e2:	eb 0f                	jmp    8004f3 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004e4:	83 ec 08             	sub    $0x8,%esp
  8004e7:	53                   	push   %ebx
  8004e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8004eb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ed:	83 ef 01             	sub    $0x1,%edi
  8004f0:	83 c4 10             	add    $0x10,%esp
  8004f3:	85 ff                	test   %edi,%edi
  8004f5:	7f ed                	jg     8004e4 <vprintfmt+0x1c0>
  8004f7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004fa:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004fd:	85 c9                	test   %ecx,%ecx
  8004ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800504:	0f 49 c1             	cmovns %ecx,%eax
  800507:	29 c1                	sub    %eax,%ecx
  800509:	89 75 08             	mov    %esi,0x8(%ebp)
  80050c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80050f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800512:	89 cb                	mov    %ecx,%ebx
  800514:	eb 4d                	jmp    800563 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800516:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051a:	74 1b                	je     800537 <vprintfmt+0x213>
  80051c:	0f be c0             	movsbl %al,%eax
  80051f:	83 e8 20             	sub    $0x20,%eax
  800522:	83 f8 5e             	cmp    $0x5e,%eax
  800525:	76 10                	jbe    800537 <vprintfmt+0x213>
					putch('?', putdat);
  800527:	83 ec 08             	sub    $0x8,%esp
  80052a:	ff 75 0c             	pushl  0xc(%ebp)
  80052d:	6a 3f                	push   $0x3f
  80052f:	ff 55 08             	call   *0x8(%ebp)
  800532:	83 c4 10             	add    $0x10,%esp
  800535:	eb 0d                	jmp    800544 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	ff 75 0c             	pushl  0xc(%ebp)
  80053d:	52                   	push   %edx
  80053e:	ff 55 08             	call   *0x8(%ebp)
  800541:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800544:	83 eb 01             	sub    $0x1,%ebx
  800547:	eb 1a                	jmp    800563 <vprintfmt+0x23f>
  800549:	89 75 08             	mov    %esi,0x8(%ebp)
  80054c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80054f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800552:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800555:	eb 0c                	jmp    800563 <vprintfmt+0x23f>
  800557:	89 75 08             	mov    %esi,0x8(%ebp)
  80055a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800560:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800563:	83 c7 01             	add    $0x1,%edi
  800566:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056a:	0f be d0             	movsbl %al,%edx
  80056d:	85 d2                	test   %edx,%edx
  80056f:	74 23                	je     800594 <vprintfmt+0x270>
  800571:	85 f6                	test   %esi,%esi
  800573:	78 a1                	js     800516 <vprintfmt+0x1f2>
  800575:	83 ee 01             	sub    $0x1,%esi
  800578:	79 9c                	jns    800516 <vprintfmt+0x1f2>
  80057a:	89 df                	mov    %ebx,%edi
  80057c:	8b 75 08             	mov    0x8(%ebp),%esi
  80057f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800582:	eb 18                	jmp    80059c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800584:	83 ec 08             	sub    $0x8,%esp
  800587:	53                   	push   %ebx
  800588:	6a 20                	push   $0x20
  80058a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058c:	83 ef 01             	sub    $0x1,%edi
  80058f:	83 c4 10             	add    $0x10,%esp
  800592:	eb 08                	jmp    80059c <vprintfmt+0x278>
  800594:	89 df                	mov    %ebx,%edi
  800596:	8b 75 08             	mov    0x8(%ebp),%esi
  800599:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059c:	85 ff                	test   %edi,%edi
  80059e:	7f e4                	jg     800584 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a3:	e9 a2 fd ff ff       	jmp    80034a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a8:	83 fa 01             	cmp    $0x1,%edx
  8005ab:	7e 16                	jle    8005c3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8d 50 08             	lea    0x8(%eax),%edx
  8005b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b6:	8b 50 04             	mov    0x4(%eax),%edx
  8005b9:	8b 00                	mov    (%eax),%eax
  8005bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005be:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c1:	eb 32                	jmp    8005f5 <vprintfmt+0x2d1>
	else if (lflag)
  8005c3:	85 d2                	test   %edx,%edx
  8005c5:	74 18                	je     8005df <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8d 50 04             	lea    0x4(%eax),%edx
  8005cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d0:	8b 00                	mov    (%eax),%eax
  8005d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d5:	89 c1                	mov    %eax,%ecx
  8005d7:	c1 f9 1f             	sar    $0x1f,%ecx
  8005da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005dd:	eb 16                	jmp    8005f5 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8d 50 04             	lea    0x4(%eax),%edx
  8005e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e8:	8b 00                	mov    (%eax),%eax
  8005ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ed:	89 c1                	mov    %eax,%ecx
  8005ef:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f8:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005fb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800600:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800604:	79 74                	jns    80067a <vprintfmt+0x356>
				putch('-', putdat);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	6a 2d                	push   $0x2d
  80060c:	ff d6                	call   *%esi
				num = -(long long) num;
  80060e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800611:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800614:	f7 d8                	neg    %eax
  800616:	83 d2 00             	adc    $0x0,%edx
  800619:	f7 da                	neg    %edx
  80061b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80061e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800623:	eb 55                	jmp    80067a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800625:	8d 45 14             	lea    0x14(%ebp),%eax
  800628:	e8 83 fc ff ff       	call   8002b0 <getuint>
			base = 10;
  80062d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800632:	eb 46                	jmp    80067a <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800634:	8d 45 14             	lea    0x14(%ebp),%eax
  800637:	e8 74 fc ff ff       	call   8002b0 <getuint>
			base = 8;
  80063c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800641:	eb 37                	jmp    80067a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	53                   	push   %ebx
  800647:	6a 30                	push   $0x30
  800649:	ff d6                	call   *%esi
			putch('x', putdat);
  80064b:	83 c4 08             	add    $0x8,%esp
  80064e:	53                   	push   %ebx
  80064f:	6a 78                	push   $0x78
  800651:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800653:	8b 45 14             	mov    0x14(%ebp),%eax
  800656:	8d 50 04             	lea    0x4(%eax),%edx
  800659:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80065c:	8b 00                	mov    (%eax),%eax
  80065e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800663:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800666:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80066b:	eb 0d                	jmp    80067a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80066d:	8d 45 14             	lea    0x14(%ebp),%eax
  800670:	e8 3b fc ff ff       	call   8002b0 <getuint>
			base = 16;
  800675:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80067a:	83 ec 0c             	sub    $0xc,%esp
  80067d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800681:	57                   	push   %edi
  800682:	ff 75 e0             	pushl  -0x20(%ebp)
  800685:	51                   	push   %ecx
  800686:	52                   	push   %edx
  800687:	50                   	push   %eax
  800688:	89 da                	mov    %ebx,%edx
  80068a:	89 f0                	mov    %esi,%eax
  80068c:	e8 70 fb ff ff       	call   800201 <printnum>
			break;
  800691:	83 c4 20             	add    $0x20,%esp
  800694:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800697:	e9 ae fc ff ff       	jmp    80034a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80069c:	83 ec 08             	sub    $0x8,%esp
  80069f:	53                   	push   %ebx
  8006a0:	51                   	push   %ecx
  8006a1:	ff d6                	call   *%esi
			break;
  8006a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006a9:	e9 9c fc ff ff       	jmp    80034a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ae:	83 ec 08             	sub    $0x8,%esp
  8006b1:	53                   	push   %ebx
  8006b2:	6a 25                	push   $0x25
  8006b4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b6:	83 c4 10             	add    $0x10,%esp
  8006b9:	eb 03                	jmp    8006be <vprintfmt+0x39a>
  8006bb:	83 ef 01             	sub    $0x1,%edi
  8006be:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006c2:	75 f7                	jne    8006bb <vprintfmt+0x397>
  8006c4:	e9 81 fc ff ff       	jmp    80034a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006cc:	5b                   	pop    %ebx
  8006cd:	5e                   	pop    %esi
  8006ce:	5f                   	pop    %edi
  8006cf:	5d                   	pop    %ebp
  8006d0:	c3                   	ret    

008006d1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d1:	55                   	push   %ebp
  8006d2:	89 e5                	mov    %esp,%ebp
  8006d4:	83 ec 18             	sub    $0x18,%esp
  8006d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006da:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ee:	85 c0                	test   %eax,%eax
  8006f0:	74 26                	je     800718 <vsnprintf+0x47>
  8006f2:	85 d2                	test   %edx,%edx
  8006f4:	7e 22                	jle    800718 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f6:	ff 75 14             	pushl  0x14(%ebp)
  8006f9:	ff 75 10             	pushl  0x10(%ebp)
  8006fc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ff:	50                   	push   %eax
  800700:	68 ea 02 80 00       	push   $0x8002ea
  800705:	e8 1a fc ff ff       	call   800324 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80070d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800710:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800713:	83 c4 10             	add    $0x10,%esp
  800716:	eb 05                	jmp    80071d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800718:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80071d:	c9                   	leave  
  80071e:	c3                   	ret    

0080071f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800725:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800728:	50                   	push   %eax
  800729:	ff 75 10             	pushl  0x10(%ebp)
  80072c:	ff 75 0c             	pushl  0xc(%ebp)
  80072f:	ff 75 08             	pushl  0x8(%ebp)
  800732:	e8 9a ff ff ff       	call   8006d1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800737:	c9                   	leave  
  800738:	c3                   	ret    

00800739 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800739:	55                   	push   %ebp
  80073a:	89 e5                	mov    %esp,%ebp
  80073c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80073f:	b8 00 00 00 00       	mov    $0x0,%eax
  800744:	eb 03                	jmp    800749 <strlen+0x10>
		n++;
  800746:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800749:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80074d:	75 f7                	jne    800746 <strlen+0xd>
		n++;
	return n;
}
  80074f:	5d                   	pop    %ebp
  800750:	c3                   	ret    

00800751 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800751:	55                   	push   %ebp
  800752:	89 e5                	mov    %esp,%ebp
  800754:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800757:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075a:	ba 00 00 00 00       	mov    $0x0,%edx
  80075f:	eb 03                	jmp    800764 <strnlen+0x13>
		n++;
  800761:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800764:	39 c2                	cmp    %eax,%edx
  800766:	74 08                	je     800770 <strnlen+0x1f>
  800768:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80076c:	75 f3                	jne    800761 <strnlen+0x10>
  80076e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800770:	5d                   	pop    %ebp
  800771:	c3                   	ret    

00800772 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	53                   	push   %ebx
  800776:	8b 45 08             	mov    0x8(%ebp),%eax
  800779:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80077c:	89 c2                	mov    %eax,%edx
  80077e:	83 c2 01             	add    $0x1,%edx
  800781:	83 c1 01             	add    $0x1,%ecx
  800784:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800788:	88 5a ff             	mov    %bl,-0x1(%edx)
  80078b:	84 db                	test   %bl,%bl
  80078d:	75 ef                	jne    80077e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80078f:	5b                   	pop    %ebx
  800790:	5d                   	pop    %ebp
  800791:	c3                   	ret    

00800792 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	53                   	push   %ebx
  800796:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800799:	53                   	push   %ebx
  80079a:	e8 9a ff ff ff       	call   800739 <strlen>
  80079f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a2:	ff 75 0c             	pushl  0xc(%ebp)
  8007a5:	01 d8                	add    %ebx,%eax
  8007a7:	50                   	push   %eax
  8007a8:	e8 c5 ff ff ff       	call   800772 <strcpy>
	return dst;
}
  8007ad:	89 d8                	mov    %ebx,%eax
  8007af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b2:	c9                   	leave  
  8007b3:	c3                   	ret    

008007b4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	56                   	push   %esi
  8007b8:	53                   	push   %ebx
  8007b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007bf:	89 f3                	mov    %esi,%ebx
  8007c1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c4:	89 f2                	mov    %esi,%edx
  8007c6:	eb 0f                	jmp    8007d7 <strncpy+0x23>
		*dst++ = *src;
  8007c8:	83 c2 01             	add    $0x1,%edx
  8007cb:	0f b6 01             	movzbl (%ecx),%eax
  8007ce:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d1:	80 39 01             	cmpb   $0x1,(%ecx)
  8007d4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d7:	39 da                	cmp    %ebx,%edx
  8007d9:	75 ed                	jne    8007c8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007db:	89 f0                	mov    %esi,%eax
  8007dd:	5b                   	pop    %ebx
  8007de:	5e                   	pop    %esi
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	56                   	push   %esi
  8007e5:	53                   	push   %ebx
  8007e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ec:	8b 55 10             	mov    0x10(%ebp),%edx
  8007ef:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f1:	85 d2                	test   %edx,%edx
  8007f3:	74 21                	je     800816 <strlcpy+0x35>
  8007f5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007f9:	89 f2                	mov    %esi,%edx
  8007fb:	eb 09                	jmp    800806 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007fd:	83 c2 01             	add    $0x1,%edx
  800800:	83 c1 01             	add    $0x1,%ecx
  800803:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800806:	39 c2                	cmp    %eax,%edx
  800808:	74 09                	je     800813 <strlcpy+0x32>
  80080a:	0f b6 19             	movzbl (%ecx),%ebx
  80080d:	84 db                	test   %bl,%bl
  80080f:	75 ec                	jne    8007fd <strlcpy+0x1c>
  800811:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800813:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800816:	29 f0                	sub    %esi,%eax
}
  800818:	5b                   	pop    %ebx
  800819:	5e                   	pop    %esi
  80081a:	5d                   	pop    %ebp
  80081b:	c3                   	ret    

0080081c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800822:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800825:	eb 06                	jmp    80082d <strcmp+0x11>
		p++, q++;
  800827:	83 c1 01             	add    $0x1,%ecx
  80082a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80082d:	0f b6 01             	movzbl (%ecx),%eax
  800830:	84 c0                	test   %al,%al
  800832:	74 04                	je     800838 <strcmp+0x1c>
  800834:	3a 02                	cmp    (%edx),%al
  800836:	74 ef                	je     800827 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800838:	0f b6 c0             	movzbl %al,%eax
  80083b:	0f b6 12             	movzbl (%edx),%edx
  80083e:	29 d0                	sub    %edx,%eax
}
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	53                   	push   %ebx
  800846:	8b 45 08             	mov    0x8(%ebp),%eax
  800849:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084c:	89 c3                	mov    %eax,%ebx
  80084e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800851:	eb 06                	jmp    800859 <strncmp+0x17>
		n--, p++, q++;
  800853:	83 c0 01             	add    $0x1,%eax
  800856:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800859:	39 d8                	cmp    %ebx,%eax
  80085b:	74 15                	je     800872 <strncmp+0x30>
  80085d:	0f b6 08             	movzbl (%eax),%ecx
  800860:	84 c9                	test   %cl,%cl
  800862:	74 04                	je     800868 <strncmp+0x26>
  800864:	3a 0a                	cmp    (%edx),%cl
  800866:	74 eb                	je     800853 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800868:	0f b6 00             	movzbl (%eax),%eax
  80086b:	0f b6 12             	movzbl (%edx),%edx
  80086e:	29 d0                	sub    %edx,%eax
  800870:	eb 05                	jmp    800877 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800872:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800877:	5b                   	pop    %ebx
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	8b 45 08             	mov    0x8(%ebp),%eax
  800880:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800884:	eb 07                	jmp    80088d <strchr+0x13>
		if (*s == c)
  800886:	38 ca                	cmp    %cl,%dl
  800888:	74 0f                	je     800899 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80088a:	83 c0 01             	add    $0x1,%eax
  80088d:	0f b6 10             	movzbl (%eax),%edx
  800890:	84 d2                	test   %dl,%dl
  800892:	75 f2                	jne    800886 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800894:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a5:	eb 03                	jmp    8008aa <strfind+0xf>
  8008a7:	83 c0 01             	add    $0x1,%eax
  8008aa:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008ad:	38 ca                	cmp    %cl,%dl
  8008af:	74 04                	je     8008b5 <strfind+0x1a>
  8008b1:	84 d2                	test   %dl,%dl
  8008b3:	75 f2                	jne    8008a7 <strfind+0xc>
			break;
	return (char *) s;
}
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	57                   	push   %edi
  8008bb:	56                   	push   %esi
  8008bc:	53                   	push   %ebx
  8008bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c3:	85 c9                	test   %ecx,%ecx
  8008c5:	74 36                	je     8008fd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008cd:	75 28                	jne    8008f7 <memset+0x40>
  8008cf:	f6 c1 03             	test   $0x3,%cl
  8008d2:	75 23                	jne    8008f7 <memset+0x40>
		c &= 0xFF;
  8008d4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d8:	89 d3                	mov    %edx,%ebx
  8008da:	c1 e3 08             	shl    $0x8,%ebx
  8008dd:	89 d6                	mov    %edx,%esi
  8008df:	c1 e6 18             	shl    $0x18,%esi
  8008e2:	89 d0                	mov    %edx,%eax
  8008e4:	c1 e0 10             	shl    $0x10,%eax
  8008e7:	09 f0                	or     %esi,%eax
  8008e9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008eb:	89 d8                	mov    %ebx,%eax
  8008ed:	09 d0                	or     %edx,%eax
  8008ef:	c1 e9 02             	shr    $0x2,%ecx
  8008f2:	fc                   	cld    
  8008f3:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f5:	eb 06                	jmp    8008fd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fa:	fc                   	cld    
  8008fb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008fd:	89 f8                	mov    %edi,%eax
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5f                   	pop    %edi
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	57                   	push   %edi
  800908:	56                   	push   %esi
  800909:	8b 45 08             	mov    0x8(%ebp),%eax
  80090c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80090f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800912:	39 c6                	cmp    %eax,%esi
  800914:	73 35                	jae    80094b <memmove+0x47>
  800916:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800919:	39 d0                	cmp    %edx,%eax
  80091b:	73 2e                	jae    80094b <memmove+0x47>
		s += n;
		d += n;
  80091d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800920:	89 d6                	mov    %edx,%esi
  800922:	09 fe                	or     %edi,%esi
  800924:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80092a:	75 13                	jne    80093f <memmove+0x3b>
  80092c:	f6 c1 03             	test   $0x3,%cl
  80092f:	75 0e                	jne    80093f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800931:	83 ef 04             	sub    $0x4,%edi
  800934:	8d 72 fc             	lea    -0x4(%edx),%esi
  800937:	c1 e9 02             	shr    $0x2,%ecx
  80093a:	fd                   	std    
  80093b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093d:	eb 09                	jmp    800948 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80093f:	83 ef 01             	sub    $0x1,%edi
  800942:	8d 72 ff             	lea    -0x1(%edx),%esi
  800945:	fd                   	std    
  800946:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800948:	fc                   	cld    
  800949:	eb 1d                	jmp    800968 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094b:	89 f2                	mov    %esi,%edx
  80094d:	09 c2                	or     %eax,%edx
  80094f:	f6 c2 03             	test   $0x3,%dl
  800952:	75 0f                	jne    800963 <memmove+0x5f>
  800954:	f6 c1 03             	test   $0x3,%cl
  800957:	75 0a                	jne    800963 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800959:	c1 e9 02             	shr    $0x2,%ecx
  80095c:	89 c7                	mov    %eax,%edi
  80095e:	fc                   	cld    
  80095f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800961:	eb 05                	jmp    800968 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800963:	89 c7                	mov    %eax,%edi
  800965:	fc                   	cld    
  800966:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800968:	5e                   	pop    %esi
  800969:	5f                   	pop    %edi
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80096f:	ff 75 10             	pushl  0x10(%ebp)
  800972:	ff 75 0c             	pushl  0xc(%ebp)
  800975:	ff 75 08             	pushl  0x8(%ebp)
  800978:	e8 87 ff ff ff       	call   800904 <memmove>
}
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	56                   	push   %esi
  800983:	53                   	push   %ebx
  800984:	8b 45 08             	mov    0x8(%ebp),%eax
  800987:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098a:	89 c6                	mov    %eax,%esi
  80098c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80098f:	eb 1a                	jmp    8009ab <memcmp+0x2c>
		if (*s1 != *s2)
  800991:	0f b6 08             	movzbl (%eax),%ecx
  800994:	0f b6 1a             	movzbl (%edx),%ebx
  800997:	38 d9                	cmp    %bl,%cl
  800999:	74 0a                	je     8009a5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80099b:	0f b6 c1             	movzbl %cl,%eax
  80099e:	0f b6 db             	movzbl %bl,%ebx
  8009a1:	29 d8                	sub    %ebx,%eax
  8009a3:	eb 0f                	jmp    8009b4 <memcmp+0x35>
		s1++, s2++;
  8009a5:	83 c0 01             	add    $0x1,%eax
  8009a8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ab:	39 f0                	cmp    %esi,%eax
  8009ad:	75 e2                	jne    800991 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b4:	5b                   	pop    %ebx
  8009b5:	5e                   	pop    %esi
  8009b6:	5d                   	pop    %ebp
  8009b7:	c3                   	ret    

008009b8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	53                   	push   %ebx
  8009bc:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009bf:	89 c1                	mov    %eax,%ecx
  8009c1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009c8:	eb 0a                	jmp    8009d4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ca:	0f b6 10             	movzbl (%eax),%edx
  8009cd:	39 da                	cmp    %ebx,%edx
  8009cf:	74 07                	je     8009d8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d1:	83 c0 01             	add    $0x1,%eax
  8009d4:	39 c8                	cmp    %ecx,%eax
  8009d6:	72 f2                	jb     8009ca <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009d8:	5b                   	pop    %ebx
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	57                   	push   %edi
  8009df:	56                   	push   %esi
  8009e0:	53                   	push   %ebx
  8009e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e7:	eb 03                	jmp    8009ec <strtol+0x11>
		s++;
  8009e9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ec:	0f b6 01             	movzbl (%ecx),%eax
  8009ef:	3c 20                	cmp    $0x20,%al
  8009f1:	74 f6                	je     8009e9 <strtol+0xe>
  8009f3:	3c 09                	cmp    $0x9,%al
  8009f5:	74 f2                	je     8009e9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009f7:	3c 2b                	cmp    $0x2b,%al
  8009f9:	75 0a                	jne    800a05 <strtol+0x2a>
		s++;
  8009fb:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009fe:	bf 00 00 00 00       	mov    $0x0,%edi
  800a03:	eb 11                	jmp    800a16 <strtol+0x3b>
  800a05:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a0a:	3c 2d                	cmp    $0x2d,%al
  800a0c:	75 08                	jne    800a16 <strtol+0x3b>
		s++, neg = 1;
  800a0e:	83 c1 01             	add    $0x1,%ecx
  800a11:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a16:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a1c:	75 15                	jne    800a33 <strtol+0x58>
  800a1e:	80 39 30             	cmpb   $0x30,(%ecx)
  800a21:	75 10                	jne    800a33 <strtol+0x58>
  800a23:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a27:	75 7c                	jne    800aa5 <strtol+0xca>
		s += 2, base = 16;
  800a29:	83 c1 02             	add    $0x2,%ecx
  800a2c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a31:	eb 16                	jmp    800a49 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a33:	85 db                	test   %ebx,%ebx
  800a35:	75 12                	jne    800a49 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a37:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a3c:	80 39 30             	cmpb   $0x30,(%ecx)
  800a3f:	75 08                	jne    800a49 <strtol+0x6e>
		s++, base = 8;
  800a41:	83 c1 01             	add    $0x1,%ecx
  800a44:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a49:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a51:	0f b6 11             	movzbl (%ecx),%edx
  800a54:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a57:	89 f3                	mov    %esi,%ebx
  800a59:	80 fb 09             	cmp    $0x9,%bl
  800a5c:	77 08                	ja     800a66 <strtol+0x8b>
			dig = *s - '0';
  800a5e:	0f be d2             	movsbl %dl,%edx
  800a61:	83 ea 30             	sub    $0x30,%edx
  800a64:	eb 22                	jmp    800a88 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a66:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a69:	89 f3                	mov    %esi,%ebx
  800a6b:	80 fb 19             	cmp    $0x19,%bl
  800a6e:	77 08                	ja     800a78 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a70:	0f be d2             	movsbl %dl,%edx
  800a73:	83 ea 57             	sub    $0x57,%edx
  800a76:	eb 10                	jmp    800a88 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a78:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a7b:	89 f3                	mov    %esi,%ebx
  800a7d:	80 fb 19             	cmp    $0x19,%bl
  800a80:	77 16                	ja     800a98 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a82:	0f be d2             	movsbl %dl,%edx
  800a85:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a88:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a8b:	7d 0b                	jge    800a98 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a8d:	83 c1 01             	add    $0x1,%ecx
  800a90:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a94:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a96:	eb b9                	jmp    800a51 <strtol+0x76>

	if (endptr)
  800a98:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a9c:	74 0d                	je     800aab <strtol+0xd0>
		*endptr = (char *) s;
  800a9e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa1:	89 0e                	mov    %ecx,(%esi)
  800aa3:	eb 06                	jmp    800aab <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa5:	85 db                	test   %ebx,%ebx
  800aa7:	74 98                	je     800a41 <strtol+0x66>
  800aa9:	eb 9e                	jmp    800a49 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aab:	89 c2                	mov    %eax,%edx
  800aad:	f7 da                	neg    %edx
  800aaf:	85 ff                	test   %edi,%edi
  800ab1:	0f 45 c2             	cmovne %edx,%eax
}
  800ab4:	5b                   	pop    %ebx
  800ab5:	5e                   	pop    %esi
  800ab6:	5f                   	pop    %edi
  800ab7:	5d                   	pop    %ebp
  800ab8:	c3                   	ret    

00800ab9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	57                   	push   %edi
  800abd:	56                   	push   %esi
  800abe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800abf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac7:	8b 55 08             	mov    0x8(%ebp),%edx
  800aca:	89 c3                	mov    %eax,%ebx
  800acc:	89 c7                	mov    %eax,%edi
  800ace:	89 c6                	mov    %eax,%esi
  800ad0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	5f                   	pop    %edi
  800ad5:	5d                   	pop    %ebp
  800ad6:	c3                   	ret    

00800ad7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	57                   	push   %edi
  800adb:	56                   	push   %esi
  800adc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800add:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae7:	89 d1                	mov    %edx,%ecx
  800ae9:	89 d3                	mov    %edx,%ebx
  800aeb:	89 d7                	mov    %edx,%edi
  800aed:	89 d6                	mov    %edx,%esi
  800aef:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5f                   	pop    %edi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	57                   	push   %edi
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
  800afc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b04:	b8 03 00 00 00       	mov    $0x3,%eax
  800b09:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0c:	89 cb                	mov    %ecx,%ebx
  800b0e:	89 cf                	mov    %ecx,%edi
  800b10:	89 ce                	mov    %ecx,%esi
  800b12:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b14:	85 c0                	test   %eax,%eax
  800b16:	7e 17                	jle    800b2f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b18:	83 ec 0c             	sub    $0xc,%esp
  800b1b:	50                   	push   %eax
  800b1c:	6a 03                	push   $0x3
  800b1e:	68 3f 22 80 00       	push   $0x80223f
  800b23:	6a 23                	push   $0x23
  800b25:	68 5c 22 80 00       	push   $0x80225c
  800b2a:	e8 41 0f 00 00       	call   801a70 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b32:	5b                   	pop    %ebx
  800b33:	5e                   	pop    %esi
  800b34:	5f                   	pop    %edi
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	57                   	push   %edi
  800b3b:	56                   	push   %esi
  800b3c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b42:	b8 02 00 00 00       	mov    $0x2,%eax
  800b47:	89 d1                	mov    %edx,%ecx
  800b49:	89 d3                	mov    %edx,%ebx
  800b4b:	89 d7                	mov    %edx,%edi
  800b4d:	89 d6                	mov    %edx,%esi
  800b4f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b51:	5b                   	pop    %ebx
  800b52:	5e                   	pop    %esi
  800b53:	5f                   	pop    %edi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <sys_yield>:

void
sys_yield(void)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	57                   	push   %edi
  800b5a:	56                   	push   %esi
  800b5b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b61:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b66:	89 d1                	mov    %edx,%ecx
  800b68:	89 d3                	mov    %edx,%ebx
  800b6a:	89 d7                	mov    %edx,%edi
  800b6c:	89 d6                	mov    %edx,%esi
  800b6e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	57                   	push   %edi
  800b79:	56                   	push   %esi
  800b7a:	53                   	push   %ebx
  800b7b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7e:	be 00 00 00 00       	mov    $0x0,%esi
  800b83:	b8 04 00 00 00       	mov    $0x4,%eax
  800b88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b91:	89 f7                	mov    %esi,%edi
  800b93:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b95:	85 c0                	test   %eax,%eax
  800b97:	7e 17                	jle    800bb0 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b99:	83 ec 0c             	sub    $0xc,%esp
  800b9c:	50                   	push   %eax
  800b9d:	6a 04                	push   $0x4
  800b9f:	68 3f 22 80 00       	push   $0x80223f
  800ba4:	6a 23                	push   $0x23
  800ba6:	68 5c 22 80 00       	push   $0x80225c
  800bab:	e8 c0 0e 00 00       	call   801a70 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb3:	5b                   	pop    %ebx
  800bb4:	5e                   	pop    %esi
  800bb5:	5f                   	pop    %edi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	57                   	push   %edi
  800bbc:	56                   	push   %esi
  800bbd:	53                   	push   %ebx
  800bbe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc1:	b8 05 00 00 00       	mov    $0x5,%eax
  800bc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bcf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd2:	8b 75 18             	mov    0x18(%ebp),%esi
  800bd5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd7:	85 c0                	test   %eax,%eax
  800bd9:	7e 17                	jle    800bf2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdb:	83 ec 0c             	sub    $0xc,%esp
  800bde:	50                   	push   %eax
  800bdf:	6a 05                	push   $0x5
  800be1:	68 3f 22 80 00       	push   $0x80223f
  800be6:	6a 23                	push   $0x23
  800be8:	68 5c 22 80 00       	push   $0x80225c
  800bed:	e8 7e 0e 00 00       	call   801a70 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	57                   	push   %edi
  800bfe:	56                   	push   %esi
  800bff:	53                   	push   %ebx
  800c00:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c03:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c08:	b8 06 00 00 00       	mov    $0x6,%eax
  800c0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c10:	8b 55 08             	mov    0x8(%ebp),%edx
  800c13:	89 df                	mov    %ebx,%edi
  800c15:	89 de                	mov    %ebx,%esi
  800c17:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c19:	85 c0                	test   %eax,%eax
  800c1b:	7e 17                	jle    800c34 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1d:	83 ec 0c             	sub    $0xc,%esp
  800c20:	50                   	push   %eax
  800c21:	6a 06                	push   $0x6
  800c23:	68 3f 22 80 00       	push   $0x80223f
  800c28:	6a 23                	push   $0x23
  800c2a:	68 5c 22 80 00       	push   $0x80225c
  800c2f:	e8 3c 0e 00 00       	call   801a70 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c37:	5b                   	pop    %ebx
  800c38:	5e                   	pop    %esi
  800c39:	5f                   	pop    %edi
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    

00800c3c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	57                   	push   %edi
  800c40:	56                   	push   %esi
  800c41:	53                   	push   %ebx
  800c42:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c45:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4a:	b8 08 00 00 00       	mov    $0x8,%eax
  800c4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c52:	8b 55 08             	mov    0x8(%ebp),%edx
  800c55:	89 df                	mov    %ebx,%edi
  800c57:	89 de                	mov    %ebx,%esi
  800c59:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5b:	85 c0                	test   %eax,%eax
  800c5d:	7e 17                	jle    800c76 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5f:	83 ec 0c             	sub    $0xc,%esp
  800c62:	50                   	push   %eax
  800c63:	6a 08                	push   $0x8
  800c65:	68 3f 22 80 00       	push   $0x80223f
  800c6a:	6a 23                	push   $0x23
  800c6c:	68 5c 22 80 00       	push   $0x80225c
  800c71:	e8 fa 0d 00 00       	call   801a70 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	5f                   	pop    %edi
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    

00800c7e <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	57                   	push   %edi
  800c82:	56                   	push   %esi
  800c83:	53                   	push   %ebx
  800c84:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c87:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8c:	b8 09 00 00 00       	mov    $0x9,%eax
  800c91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c94:	8b 55 08             	mov    0x8(%ebp),%edx
  800c97:	89 df                	mov    %ebx,%edi
  800c99:	89 de                	mov    %ebx,%esi
  800c9b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9d:	85 c0                	test   %eax,%eax
  800c9f:	7e 17                	jle    800cb8 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca1:	83 ec 0c             	sub    $0xc,%esp
  800ca4:	50                   	push   %eax
  800ca5:	6a 09                	push   $0x9
  800ca7:	68 3f 22 80 00       	push   $0x80223f
  800cac:	6a 23                	push   $0x23
  800cae:	68 5c 22 80 00       	push   $0x80225c
  800cb3:	e8 b8 0d 00 00       	call   801a70 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbb:	5b                   	pop    %ebx
  800cbc:	5e                   	pop    %esi
  800cbd:	5f                   	pop    %edi
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    

00800cc0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	57                   	push   %edi
  800cc4:	56                   	push   %esi
  800cc5:	53                   	push   %ebx
  800cc6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cce:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd9:	89 df                	mov    %ebx,%edi
  800cdb:	89 de                	mov    %ebx,%esi
  800cdd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cdf:	85 c0                	test   %eax,%eax
  800ce1:	7e 17                	jle    800cfa <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce3:	83 ec 0c             	sub    $0xc,%esp
  800ce6:	50                   	push   %eax
  800ce7:	6a 0a                	push   $0xa
  800ce9:	68 3f 22 80 00       	push   $0x80223f
  800cee:	6a 23                	push   $0x23
  800cf0:	68 5c 22 80 00       	push   $0x80225c
  800cf5:	e8 76 0d 00 00       	call   801a70 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfd:	5b                   	pop    %ebx
  800cfe:	5e                   	pop    %esi
  800cff:	5f                   	pop    %edi
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    

00800d02 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	57                   	push   %edi
  800d06:	56                   	push   %esi
  800d07:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d08:	be 00 00 00 00       	mov    $0x0,%esi
  800d0d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d15:	8b 55 08             	mov    0x8(%ebp),%edx
  800d18:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d1e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    

00800d25 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	57                   	push   %edi
  800d29:	56                   	push   %esi
  800d2a:	53                   	push   %ebx
  800d2b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d33:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d38:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3b:	89 cb                	mov    %ecx,%ebx
  800d3d:	89 cf                	mov    %ecx,%edi
  800d3f:	89 ce                	mov    %ecx,%esi
  800d41:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d43:	85 c0                	test   %eax,%eax
  800d45:	7e 17                	jle    800d5e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d47:	83 ec 0c             	sub    $0xc,%esp
  800d4a:	50                   	push   %eax
  800d4b:	6a 0d                	push   $0xd
  800d4d:	68 3f 22 80 00       	push   $0x80223f
  800d52:	6a 23                	push   $0x23
  800d54:	68 5c 22 80 00       	push   $0x80225c
  800d59:	e8 12 0d 00 00       	call   801a70 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	57                   	push   %edi
  800d6a:	56                   	push   %esi
  800d6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d71:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d76:	8b 55 08             	mov    0x8(%ebp),%edx
  800d79:	89 cb                	mov    %ecx,%ebx
  800d7b:	89 cf                	mov    %ecx,%edi
  800d7d:	89 ce                	mov    %ecx,%esi
  800d7f:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d81:	5b                   	pop    %ebx
  800d82:	5e                   	pop    %esi
  800d83:	5f                   	pop    %edi
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    

00800d86 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d89:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8c:	05 00 00 00 30       	add    $0x30000000,%eax
  800d91:	c1 e8 0c             	shr    $0xc,%eax
}
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d99:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9c:	05 00 00 00 30       	add    $0x30000000,%eax
  800da1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800da6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800db8:	89 c2                	mov    %eax,%edx
  800dba:	c1 ea 16             	shr    $0x16,%edx
  800dbd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dc4:	f6 c2 01             	test   $0x1,%dl
  800dc7:	74 11                	je     800dda <fd_alloc+0x2d>
  800dc9:	89 c2                	mov    %eax,%edx
  800dcb:	c1 ea 0c             	shr    $0xc,%edx
  800dce:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dd5:	f6 c2 01             	test   $0x1,%dl
  800dd8:	75 09                	jne    800de3 <fd_alloc+0x36>
			*fd_store = fd;
  800dda:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ddc:	b8 00 00 00 00       	mov    $0x0,%eax
  800de1:	eb 17                	jmp    800dfa <fd_alloc+0x4d>
  800de3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800de8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ded:	75 c9                	jne    800db8 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800def:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800df5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    

00800dfc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e02:	83 f8 1f             	cmp    $0x1f,%eax
  800e05:	77 36                	ja     800e3d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e07:	c1 e0 0c             	shl    $0xc,%eax
  800e0a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e0f:	89 c2                	mov    %eax,%edx
  800e11:	c1 ea 16             	shr    $0x16,%edx
  800e14:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e1b:	f6 c2 01             	test   $0x1,%dl
  800e1e:	74 24                	je     800e44 <fd_lookup+0x48>
  800e20:	89 c2                	mov    %eax,%edx
  800e22:	c1 ea 0c             	shr    $0xc,%edx
  800e25:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e2c:	f6 c2 01             	test   $0x1,%dl
  800e2f:	74 1a                	je     800e4b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e31:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e34:	89 02                	mov    %eax,(%edx)
	return 0;
  800e36:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3b:	eb 13                	jmp    800e50 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e3d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e42:	eb 0c                	jmp    800e50 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e44:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e49:	eb 05                	jmp    800e50 <fd_lookup+0x54>
  800e4b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e50:	5d                   	pop    %ebp
  800e51:	c3                   	ret    

00800e52 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e52:	55                   	push   %ebp
  800e53:	89 e5                	mov    %esp,%ebp
  800e55:	83 ec 08             	sub    $0x8,%esp
  800e58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5b:	ba e8 22 80 00       	mov    $0x8022e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e60:	eb 13                	jmp    800e75 <dev_lookup+0x23>
  800e62:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e65:	39 08                	cmp    %ecx,(%eax)
  800e67:	75 0c                	jne    800e75 <dev_lookup+0x23>
			*dev = devtab[i];
  800e69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6c:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e73:	eb 2e                	jmp    800ea3 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e75:	8b 02                	mov    (%edx),%eax
  800e77:	85 c0                	test   %eax,%eax
  800e79:	75 e7                	jne    800e62 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e7b:	a1 04 40 80 00       	mov    0x804004,%eax
  800e80:	8b 40 50             	mov    0x50(%eax),%eax
  800e83:	83 ec 04             	sub    $0x4,%esp
  800e86:	51                   	push   %ecx
  800e87:	50                   	push   %eax
  800e88:	68 6c 22 80 00       	push   $0x80226c
  800e8d:	e8 5b f3 ff ff       	call   8001ed <cprintf>
	*dev = 0;
  800e92:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e95:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e9b:	83 c4 10             	add    $0x10,%esp
  800e9e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ea3:	c9                   	leave  
  800ea4:	c3                   	ret    

00800ea5 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	56                   	push   %esi
  800ea9:	53                   	push   %ebx
  800eaa:	83 ec 10             	sub    $0x10,%esp
  800ead:	8b 75 08             	mov    0x8(%ebp),%esi
  800eb0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eb3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eb6:	50                   	push   %eax
  800eb7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ebd:	c1 e8 0c             	shr    $0xc,%eax
  800ec0:	50                   	push   %eax
  800ec1:	e8 36 ff ff ff       	call   800dfc <fd_lookup>
  800ec6:	83 c4 08             	add    $0x8,%esp
  800ec9:	85 c0                	test   %eax,%eax
  800ecb:	78 05                	js     800ed2 <fd_close+0x2d>
	    || fd != fd2)
  800ecd:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ed0:	74 0c                	je     800ede <fd_close+0x39>
		return (must_exist ? r : 0);
  800ed2:	84 db                	test   %bl,%bl
  800ed4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed9:	0f 44 c2             	cmove  %edx,%eax
  800edc:	eb 41                	jmp    800f1f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ede:	83 ec 08             	sub    $0x8,%esp
  800ee1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ee4:	50                   	push   %eax
  800ee5:	ff 36                	pushl  (%esi)
  800ee7:	e8 66 ff ff ff       	call   800e52 <dev_lookup>
  800eec:	89 c3                	mov    %eax,%ebx
  800eee:	83 c4 10             	add    $0x10,%esp
  800ef1:	85 c0                	test   %eax,%eax
  800ef3:	78 1a                	js     800f0f <fd_close+0x6a>
		if (dev->dev_close)
  800ef5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ef8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800efb:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f00:	85 c0                	test   %eax,%eax
  800f02:	74 0b                	je     800f0f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f04:	83 ec 0c             	sub    $0xc,%esp
  800f07:	56                   	push   %esi
  800f08:	ff d0                	call   *%eax
  800f0a:	89 c3                	mov    %eax,%ebx
  800f0c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f0f:	83 ec 08             	sub    $0x8,%esp
  800f12:	56                   	push   %esi
  800f13:	6a 00                	push   $0x0
  800f15:	e8 e0 fc ff ff       	call   800bfa <sys_page_unmap>
	return r;
  800f1a:	83 c4 10             	add    $0x10,%esp
  800f1d:	89 d8                	mov    %ebx,%eax
}
  800f1f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f22:	5b                   	pop    %ebx
  800f23:	5e                   	pop    %esi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    

00800f26 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f2f:	50                   	push   %eax
  800f30:	ff 75 08             	pushl  0x8(%ebp)
  800f33:	e8 c4 fe ff ff       	call   800dfc <fd_lookup>
  800f38:	83 c4 08             	add    $0x8,%esp
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	78 10                	js     800f4f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f3f:	83 ec 08             	sub    $0x8,%esp
  800f42:	6a 01                	push   $0x1
  800f44:	ff 75 f4             	pushl  -0xc(%ebp)
  800f47:	e8 59 ff ff ff       	call   800ea5 <fd_close>
  800f4c:	83 c4 10             	add    $0x10,%esp
}
  800f4f:	c9                   	leave  
  800f50:	c3                   	ret    

00800f51 <close_all>:

void
close_all(void)
{
  800f51:	55                   	push   %ebp
  800f52:	89 e5                	mov    %esp,%ebp
  800f54:	53                   	push   %ebx
  800f55:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f58:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f5d:	83 ec 0c             	sub    $0xc,%esp
  800f60:	53                   	push   %ebx
  800f61:	e8 c0 ff ff ff       	call   800f26 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f66:	83 c3 01             	add    $0x1,%ebx
  800f69:	83 c4 10             	add    $0x10,%esp
  800f6c:	83 fb 20             	cmp    $0x20,%ebx
  800f6f:	75 ec                	jne    800f5d <close_all+0xc>
		close(i);
}
  800f71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f74:	c9                   	leave  
  800f75:	c3                   	ret    

00800f76 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	57                   	push   %edi
  800f7a:	56                   	push   %esi
  800f7b:	53                   	push   %ebx
  800f7c:	83 ec 2c             	sub    $0x2c,%esp
  800f7f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f82:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f85:	50                   	push   %eax
  800f86:	ff 75 08             	pushl  0x8(%ebp)
  800f89:	e8 6e fe ff ff       	call   800dfc <fd_lookup>
  800f8e:	83 c4 08             	add    $0x8,%esp
  800f91:	85 c0                	test   %eax,%eax
  800f93:	0f 88 c1 00 00 00    	js     80105a <dup+0xe4>
		return r;
	close(newfdnum);
  800f99:	83 ec 0c             	sub    $0xc,%esp
  800f9c:	56                   	push   %esi
  800f9d:	e8 84 ff ff ff       	call   800f26 <close>

	newfd = INDEX2FD(newfdnum);
  800fa2:	89 f3                	mov    %esi,%ebx
  800fa4:	c1 e3 0c             	shl    $0xc,%ebx
  800fa7:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800fad:	83 c4 04             	add    $0x4,%esp
  800fb0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fb3:	e8 de fd ff ff       	call   800d96 <fd2data>
  800fb8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fba:	89 1c 24             	mov    %ebx,(%esp)
  800fbd:	e8 d4 fd ff ff       	call   800d96 <fd2data>
  800fc2:	83 c4 10             	add    $0x10,%esp
  800fc5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fc8:	89 f8                	mov    %edi,%eax
  800fca:	c1 e8 16             	shr    $0x16,%eax
  800fcd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fd4:	a8 01                	test   $0x1,%al
  800fd6:	74 37                	je     80100f <dup+0x99>
  800fd8:	89 f8                	mov    %edi,%eax
  800fda:	c1 e8 0c             	shr    $0xc,%eax
  800fdd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fe4:	f6 c2 01             	test   $0x1,%dl
  800fe7:	74 26                	je     80100f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fe9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ff0:	83 ec 0c             	sub    $0xc,%esp
  800ff3:	25 07 0e 00 00       	and    $0xe07,%eax
  800ff8:	50                   	push   %eax
  800ff9:	ff 75 d4             	pushl  -0x2c(%ebp)
  800ffc:	6a 00                	push   $0x0
  800ffe:	57                   	push   %edi
  800fff:	6a 00                	push   $0x0
  801001:	e8 b2 fb ff ff       	call   800bb8 <sys_page_map>
  801006:	89 c7                	mov    %eax,%edi
  801008:	83 c4 20             	add    $0x20,%esp
  80100b:	85 c0                	test   %eax,%eax
  80100d:	78 2e                	js     80103d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80100f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801012:	89 d0                	mov    %edx,%eax
  801014:	c1 e8 0c             	shr    $0xc,%eax
  801017:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80101e:	83 ec 0c             	sub    $0xc,%esp
  801021:	25 07 0e 00 00       	and    $0xe07,%eax
  801026:	50                   	push   %eax
  801027:	53                   	push   %ebx
  801028:	6a 00                	push   $0x0
  80102a:	52                   	push   %edx
  80102b:	6a 00                	push   $0x0
  80102d:	e8 86 fb ff ff       	call   800bb8 <sys_page_map>
  801032:	89 c7                	mov    %eax,%edi
  801034:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801037:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801039:	85 ff                	test   %edi,%edi
  80103b:	79 1d                	jns    80105a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80103d:	83 ec 08             	sub    $0x8,%esp
  801040:	53                   	push   %ebx
  801041:	6a 00                	push   $0x0
  801043:	e8 b2 fb ff ff       	call   800bfa <sys_page_unmap>
	sys_page_unmap(0, nva);
  801048:	83 c4 08             	add    $0x8,%esp
  80104b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80104e:	6a 00                	push   $0x0
  801050:	e8 a5 fb ff ff       	call   800bfa <sys_page_unmap>
	return r;
  801055:	83 c4 10             	add    $0x10,%esp
  801058:	89 f8                	mov    %edi,%eax
}
  80105a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80105d:	5b                   	pop    %ebx
  80105e:	5e                   	pop    %esi
  80105f:	5f                   	pop    %edi
  801060:	5d                   	pop    %ebp
  801061:	c3                   	ret    

00801062 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801062:	55                   	push   %ebp
  801063:	89 e5                	mov    %esp,%ebp
  801065:	53                   	push   %ebx
  801066:	83 ec 14             	sub    $0x14,%esp
  801069:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80106c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80106f:	50                   	push   %eax
  801070:	53                   	push   %ebx
  801071:	e8 86 fd ff ff       	call   800dfc <fd_lookup>
  801076:	83 c4 08             	add    $0x8,%esp
  801079:	89 c2                	mov    %eax,%edx
  80107b:	85 c0                	test   %eax,%eax
  80107d:	78 6d                	js     8010ec <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80107f:	83 ec 08             	sub    $0x8,%esp
  801082:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801085:	50                   	push   %eax
  801086:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801089:	ff 30                	pushl  (%eax)
  80108b:	e8 c2 fd ff ff       	call   800e52 <dev_lookup>
  801090:	83 c4 10             	add    $0x10,%esp
  801093:	85 c0                	test   %eax,%eax
  801095:	78 4c                	js     8010e3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801097:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80109a:	8b 42 08             	mov    0x8(%edx),%eax
  80109d:	83 e0 03             	and    $0x3,%eax
  8010a0:	83 f8 01             	cmp    $0x1,%eax
  8010a3:	75 21                	jne    8010c6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010a5:	a1 04 40 80 00       	mov    0x804004,%eax
  8010aa:	8b 40 50             	mov    0x50(%eax),%eax
  8010ad:	83 ec 04             	sub    $0x4,%esp
  8010b0:	53                   	push   %ebx
  8010b1:	50                   	push   %eax
  8010b2:	68 ad 22 80 00       	push   $0x8022ad
  8010b7:	e8 31 f1 ff ff       	call   8001ed <cprintf>
		return -E_INVAL;
  8010bc:	83 c4 10             	add    $0x10,%esp
  8010bf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010c4:	eb 26                	jmp    8010ec <read+0x8a>
	}
	if (!dev->dev_read)
  8010c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010c9:	8b 40 08             	mov    0x8(%eax),%eax
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	74 17                	je     8010e7 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8010d0:	83 ec 04             	sub    $0x4,%esp
  8010d3:	ff 75 10             	pushl  0x10(%ebp)
  8010d6:	ff 75 0c             	pushl  0xc(%ebp)
  8010d9:	52                   	push   %edx
  8010da:	ff d0                	call   *%eax
  8010dc:	89 c2                	mov    %eax,%edx
  8010de:	83 c4 10             	add    $0x10,%esp
  8010e1:	eb 09                	jmp    8010ec <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010e3:	89 c2                	mov    %eax,%edx
  8010e5:	eb 05                	jmp    8010ec <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010e7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8010ec:	89 d0                	mov    %edx,%eax
  8010ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010f1:	c9                   	leave  
  8010f2:	c3                   	ret    

008010f3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010f3:	55                   	push   %ebp
  8010f4:	89 e5                	mov    %esp,%ebp
  8010f6:	57                   	push   %edi
  8010f7:	56                   	push   %esi
  8010f8:	53                   	push   %ebx
  8010f9:	83 ec 0c             	sub    $0xc,%esp
  8010fc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010ff:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801102:	bb 00 00 00 00       	mov    $0x0,%ebx
  801107:	eb 21                	jmp    80112a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801109:	83 ec 04             	sub    $0x4,%esp
  80110c:	89 f0                	mov    %esi,%eax
  80110e:	29 d8                	sub    %ebx,%eax
  801110:	50                   	push   %eax
  801111:	89 d8                	mov    %ebx,%eax
  801113:	03 45 0c             	add    0xc(%ebp),%eax
  801116:	50                   	push   %eax
  801117:	57                   	push   %edi
  801118:	e8 45 ff ff ff       	call   801062 <read>
		if (m < 0)
  80111d:	83 c4 10             	add    $0x10,%esp
  801120:	85 c0                	test   %eax,%eax
  801122:	78 10                	js     801134 <readn+0x41>
			return m;
		if (m == 0)
  801124:	85 c0                	test   %eax,%eax
  801126:	74 0a                	je     801132 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801128:	01 c3                	add    %eax,%ebx
  80112a:	39 f3                	cmp    %esi,%ebx
  80112c:	72 db                	jb     801109 <readn+0x16>
  80112e:	89 d8                	mov    %ebx,%eax
  801130:	eb 02                	jmp    801134 <readn+0x41>
  801132:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801134:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801137:	5b                   	pop    %ebx
  801138:	5e                   	pop    %esi
  801139:	5f                   	pop    %edi
  80113a:	5d                   	pop    %ebp
  80113b:	c3                   	ret    

0080113c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80113c:	55                   	push   %ebp
  80113d:	89 e5                	mov    %esp,%ebp
  80113f:	53                   	push   %ebx
  801140:	83 ec 14             	sub    $0x14,%esp
  801143:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801146:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801149:	50                   	push   %eax
  80114a:	53                   	push   %ebx
  80114b:	e8 ac fc ff ff       	call   800dfc <fd_lookup>
  801150:	83 c4 08             	add    $0x8,%esp
  801153:	89 c2                	mov    %eax,%edx
  801155:	85 c0                	test   %eax,%eax
  801157:	78 68                	js     8011c1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801159:	83 ec 08             	sub    $0x8,%esp
  80115c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80115f:	50                   	push   %eax
  801160:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801163:	ff 30                	pushl  (%eax)
  801165:	e8 e8 fc ff ff       	call   800e52 <dev_lookup>
  80116a:	83 c4 10             	add    $0x10,%esp
  80116d:	85 c0                	test   %eax,%eax
  80116f:	78 47                	js     8011b8 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801171:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801174:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801178:	75 21                	jne    80119b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80117a:	a1 04 40 80 00       	mov    0x804004,%eax
  80117f:	8b 40 50             	mov    0x50(%eax),%eax
  801182:	83 ec 04             	sub    $0x4,%esp
  801185:	53                   	push   %ebx
  801186:	50                   	push   %eax
  801187:	68 c9 22 80 00       	push   $0x8022c9
  80118c:	e8 5c f0 ff ff       	call   8001ed <cprintf>
		return -E_INVAL;
  801191:	83 c4 10             	add    $0x10,%esp
  801194:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801199:	eb 26                	jmp    8011c1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80119b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80119e:	8b 52 0c             	mov    0xc(%edx),%edx
  8011a1:	85 d2                	test   %edx,%edx
  8011a3:	74 17                	je     8011bc <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011a5:	83 ec 04             	sub    $0x4,%esp
  8011a8:	ff 75 10             	pushl  0x10(%ebp)
  8011ab:	ff 75 0c             	pushl  0xc(%ebp)
  8011ae:	50                   	push   %eax
  8011af:	ff d2                	call   *%edx
  8011b1:	89 c2                	mov    %eax,%edx
  8011b3:	83 c4 10             	add    $0x10,%esp
  8011b6:	eb 09                	jmp    8011c1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b8:	89 c2                	mov    %eax,%edx
  8011ba:	eb 05                	jmp    8011c1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011bc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011c1:	89 d0                	mov    %edx,%eax
  8011c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c6:	c9                   	leave  
  8011c7:	c3                   	ret    

008011c8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
  8011cb:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011ce:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011d1:	50                   	push   %eax
  8011d2:	ff 75 08             	pushl  0x8(%ebp)
  8011d5:	e8 22 fc ff ff       	call   800dfc <fd_lookup>
  8011da:	83 c4 08             	add    $0x8,%esp
  8011dd:	85 c0                	test   %eax,%eax
  8011df:	78 0e                	js     8011ef <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011ef:	c9                   	leave  
  8011f0:	c3                   	ret    

008011f1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011f1:	55                   	push   %ebp
  8011f2:	89 e5                	mov    %esp,%ebp
  8011f4:	53                   	push   %ebx
  8011f5:	83 ec 14             	sub    $0x14,%esp
  8011f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011fe:	50                   	push   %eax
  8011ff:	53                   	push   %ebx
  801200:	e8 f7 fb ff ff       	call   800dfc <fd_lookup>
  801205:	83 c4 08             	add    $0x8,%esp
  801208:	89 c2                	mov    %eax,%edx
  80120a:	85 c0                	test   %eax,%eax
  80120c:	78 65                	js     801273 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120e:	83 ec 08             	sub    $0x8,%esp
  801211:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801214:	50                   	push   %eax
  801215:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801218:	ff 30                	pushl  (%eax)
  80121a:	e8 33 fc ff ff       	call   800e52 <dev_lookup>
  80121f:	83 c4 10             	add    $0x10,%esp
  801222:	85 c0                	test   %eax,%eax
  801224:	78 44                	js     80126a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801226:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801229:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80122d:	75 21                	jne    801250 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80122f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801234:	8b 40 50             	mov    0x50(%eax),%eax
  801237:	83 ec 04             	sub    $0x4,%esp
  80123a:	53                   	push   %ebx
  80123b:	50                   	push   %eax
  80123c:	68 8c 22 80 00       	push   $0x80228c
  801241:	e8 a7 ef ff ff       	call   8001ed <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801246:	83 c4 10             	add    $0x10,%esp
  801249:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80124e:	eb 23                	jmp    801273 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801250:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801253:	8b 52 18             	mov    0x18(%edx),%edx
  801256:	85 d2                	test   %edx,%edx
  801258:	74 14                	je     80126e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80125a:	83 ec 08             	sub    $0x8,%esp
  80125d:	ff 75 0c             	pushl  0xc(%ebp)
  801260:	50                   	push   %eax
  801261:	ff d2                	call   *%edx
  801263:	89 c2                	mov    %eax,%edx
  801265:	83 c4 10             	add    $0x10,%esp
  801268:	eb 09                	jmp    801273 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126a:	89 c2                	mov    %eax,%edx
  80126c:	eb 05                	jmp    801273 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80126e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801273:	89 d0                	mov    %edx,%eax
  801275:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801278:	c9                   	leave  
  801279:	c3                   	ret    

0080127a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80127a:	55                   	push   %ebp
  80127b:	89 e5                	mov    %esp,%ebp
  80127d:	53                   	push   %ebx
  80127e:	83 ec 14             	sub    $0x14,%esp
  801281:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801284:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801287:	50                   	push   %eax
  801288:	ff 75 08             	pushl  0x8(%ebp)
  80128b:	e8 6c fb ff ff       	call   800dfc <fd_lookup>
  801290:	83 c4 08             	add    $0x8,%esp
  801293:	89 c2                	mov    %eax,%edx
  801295:	85 c0                	test   %eax,%eax
  801297:	78 58                	js     8012f1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801299:	83 ec 08             	sub    $0x8,%esp
  80129c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129f:	50                   	push   %eax
  8012a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a3:	ff 30                	pushl  (%eax)
  8012a5:	e8 a8 fb ff ff       	call   800e52 <dev_lookup>
  8012aa:	83 c4 10             	add    $0x10,%esp
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	78 37                	js     8012e8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012b8:	74 32                	je     8012ec <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012ba:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012bd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012c4:	00 00 00 
	stat->st_isdir = 0;
  8012c7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012ce:	00 00 00 
	stat->st_dev = dev;
  8012d1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012d7:	83 ec 08             	sub    $0x8,%esp
  8012da:	53                   	push   %ebx
  8012db:	ff 75 f0             	pushl  -0x10(%ebp)
  8012de:	ff 50 14             	call   *0x14(%eax)
  8012e1:	89 c2                	mov    %eax,%edx
  8012e3:	83 c4 10             	add    $0x10,%esp
  8012e6:	eb 09                	jmp    8012f1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e8:	89 c2                	mov    %eax,%edx
  8012ea:	eb 05                	jmp    8012f1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012ec:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012f1:	89 d0                	mov    %edx,%eax
  8012f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f6:	c9                   	leave  
  8012f7:	c3                   	ret    

008012f8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	56                   	push   %esi
  8012fc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012fd:	83 ec 08             	sub    $0x8,%esp
  801300:	6a 00                	push   $0x0
  801302:	ff 75 08             	pushl  0x8(%ebp)
  801305:	e8 e3 01 00 00       	call   8014ed <open>
  80130a:	89 c3                	mov    %eax,%ebx
  80130c:	83 c4 10             	add    $0x10,%esp
  80130f:	85 c0                	test   %eax,%eax
  801311:	78 1b                	js     80132e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801313:	83 ec 08             	sub    $0x8,%esp
  801316:	ff 75 0c             	pushl  0xc(%ebp)
  801319:	50                   	push   %eax
  80131a:	e8 5b ff ff ff       	call   80127a <fstat>
  80131f:	89 c6                	mov    %eax,%esi
	close(fd);
  801321:	89 1c 24             	mov    %ebx,(%esp)
  801324:	e8 fd fb ff ff       	call   800f26 <close>
	return r;
  801329:	83 c4 10             	add    $0x10,%esp
  80132c:	89 f0                	mov    %esi,%eax
}
  80132e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801331:	5b                   	pop    %ebx
  801332:	5e                   	pop    %esi
  801333:	5d                   	pop    %ebp
  801334:	c3                   	ret    

00801335 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801335:	55                   	push   %ebp
  801336:	89 e5                	mov    %esp,%ebp
  801338:	56                   	push   %esi
  801339:	53                   	push   %ebx
  80133a:	89 c6                	mov    %eax,%esi
  80133c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80133e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801345:	75 12                	jne    801359 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801347:	83 ec 0c             	sub    $0xc,%esp
  80134a:	6a 01                	push   $0x1
  80134c:	e8 3c 08 00 00       	call   801b8d <ipc_find_env>
  801351:	a3 00 40 80 00       	mov    %eax,0x804000
  801356:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801359:	6a 07                	push   $0x7
  80135b:	68 00 50 80 00       	push   $0x805000
  801360:	56                   	push   %esi
  801361:	ff 35 00 40 80 00    	pushl  0x804000
  801367:	e8 bf 07 00 00       	call   801b2b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80136c:	83 c4 0c             	add    $0xc,%esp
  80136f:	6a 00                	push   $0x0
  801371:	53                   	push   %ebx
  801372:	6a 00                	push   $0x0
  801374:	e8 3d 07 00 00       	call   801ab6 <ipc_recv>
}
  801379:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80137c:	5b                   	pop    %ebx
  80137d:	5e                   	pop    %esi
  80137e:	5d                   	pop    %ebp
  80137f:	c3                   	ret    

00801380 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801386:	8b 45 08             	mov    0x8(%ebp),%eax
  801389:	8b 40 0c             	mov    0xc(%eax),%eax
  80138c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801391:	8b 45 0c             	mov    0xc(%ebp),%eax
  801394:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801399:	ba 00 00 00 00       	mov    $0x0,%edx
  80139e:	b8 02 00 00 00       	mov    $0x2,%eax
  8013a3:	e8 8d ff ff ff       	call   801335 <fsipc>
}
  8013a8:	c9                   	leave  
  8013a9:	c3                   	ret    

008013aa <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013aa:	55                   	push   %ebp
  8013ab:	89 e5                	mov    %esp,%ebp
  8013ad:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b3:	8b 40 0c             	mov    0xc(%eax),%eax
  8013b6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c0:	b8 06 00 00 00       	mov    $0x6,%eax
  8013c5:	e8 6b ff ff ff       	call   801335 <fsipc>
}
  8013ca:	c9                   	leave  
  8013cb:	c3                   	ret    

008013cc <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013cc:	55                   	push   %ebp
  8013cd:	89 e5                	mov    %esp,%ebp
  8013cf:	53                   	push   %ebx
  8013d0:	83 ec 04             	sub    $0x4,%esp
  8013d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8013dc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e6:	b8 05 00 00 00       	mov    $0x5,%eax
  8013eb:	e8 45 ff ff ff       	call   801335 <fsipc>
  8013f0:	85 c0                	test   %eax,%eax
  8013f2:	78 2c                	js     801420 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013f4:	83 ec 08             	sub    $0x8,%esp
  8013f7:	68 00 50 80 00       	push   $0x805000
  8013fc:	53                   	push   %ebx
  8013fd:	e8 70 f3 ff ff       	call   800772 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801402:	a1 80 50 80 00       	mov    0x805080,%eax
  801407:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80140d:	a1 84 50 80 00       	mov    0x805084,%eax
  801412:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801418:	83 c4 10             	add    $0x10,%esp
  80141b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801420:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801423:	c9                   	leave  
  801424:	c3                   	ret    

00801425 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801425:	55                   	push   %ebp
  801426:	89 e5                	mov    %esp,%ebp
  801428:	83 ec 0c             	sub    $0xc,%esp
  80142b:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80142e:	8b 55 08             	mov    0x8(%ebp),%edx
  801431:	8b 52 0c             	mov    0xc(%edx),%edx
  801434:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80143a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80143f:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801444:	0f 47 c2             	cmova  %edx,%eax
  801447:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80144c:	50                   	push   %eax
  80144d:	ff 75 0c             	pushl  0xc(%ebp)
  801450:	68 08 50 80 00       	push   $0x805008
  801455:	e8 aa f4 ff ff       	call   800904 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80145a:	ba 00 00 00 00       	mov    $0x0,%edx
  80145f:	b8 04 00 00 00       	mov    $0x4,%eax
  801464:	e8 cc fe ff ff       	call   801335 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801469:	c9                   	leave  
  80146a:	c3                   	ret    

0080146b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80146b:	55                   	push   %ebp
  80146c:	89 e5                	mov    %esp,%ebp
  80146e:	56                   	push   %esi
  80146f:	53                   	push   %ebx
  801470:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801473:	8b 45 08             	mov    0x8(%ebp),%eax
  801476:	8b 40 0c             	mov    0xc(%eax),%eax
  801479:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80147e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801484:	ba 00 00 00 00       	mov    $0x0,%edx
  801489:	b8 03 00 00 00       	mov    $0x3,%eax
  80148e:	e8 a2 fe ff ff       	call   801335 <fsipc>
  801493:	89 c3                	mov    %eax,%ebx
  801495:	85 c0                	test   %eax,%eax
  801497:	78 4b                	js     8014e4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801499:	39 c6                	cmp    %eax,%esi
  80149b:	73 16                	jae    8014b3 <devfile_read+0x48>
  80149d:	68 f8 22 80 00       	push   $0x8022f8
  8014a2:	68 ff 22 80 00       	push   $0x8022ff
  8014a7:	6a 7c                	push   $0x7c
  8014a9:	68 14 23 80 00       	push   $0x802314
  8014ae:	e8 bd 05 00 00       	call   801a70 <_panic>
	assert(r <= PGSIZE);
  8014b3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014b8:	7e 16                	jle    8014d0 <devfile_read+0x65>
  8014ba:	68 1f 23 80 00       	push   $0x80231f
  8014bf:	68 ff 22 80 00       	push   $0x8022ff
  8014c4:	6a 7d                	push   $0x7d
  8014c6:	68 14 23 80 00       	push   $0x802314
  8014cb:	e8 a0 05 00 00       	call   801a70 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014d0:	83 ec 04             	sub    $0x4,%esp
  8014d3:	50                   	push   %eax
  8014d4:	68 00 50 80 00       	push   $0x805000
  8014d9:	ff 75 0c             	pushl  0xc(%ebp)
  8014dc:	e8 23 f4 ff ff       	call   800904 <memmove>
	return r;
  8014e1:	83 c4 10             	add    $0x10,%esp
}
  8014e4:	89 d8                	mov    %ebx,%eax
  8014e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014e9:	5b                   	pop    %ebx
  8014ea:	5e                   	pop    %esi
  8014eb:	5d                   	pop    %ebp
  8014ec:	c3                   	ret    

008014ed <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014ed:	55                   	push   %ebp
  8014ee:	89 e5                	mov    %esp,%ebp
  8014f0:	53                   	push   %ebx
  8014f1:	83 ec 20             	sub    $0x20,%esp
  8014f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014f7:	53                   	push   %ebx
  8014f8:	e8 3c f2 ff ff       	call   800739 <strlen>
  8014fd:	83 c4 10             	add    $0x10,%esp
  801500:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801505:	7f 67                	jg     80156e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801507:	83 ec 0c             	sub    $0xc,%esp
  80150a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150d:	50                   	push   %eax
  80150e:	e8 9a f8 ff ff       	call   800dad <fd_alloc>
  801513:	83 c4 10             	add    $0x10,%esp
		return r;
  801516:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801518:	85 c0                	test   %eax,%eax
  80151a:	78 57                	js     801573 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80151c:	83 ec 08             	sub    $0x8,%esp
  80151f:	53                   	push   %ebx
  801520:	68 00 50 80 00       	push   $0x805000
  801525:	e8 48 f2 ff ff       	call   800772 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80152a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80152d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801532:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801535:	b8 01 00 00 00       	mov    $0x1,%eax
  80153a:	e8 f6 fd ff ff       	call   801335 <fsipc>
  80153f:	89 c3                	mov    %eax,%ebx
  801541:	83 c4 10             	add    $0x10,%esp
  801544:	85 c0                	test   %eax,%eax
  801546:	79 14                	jns    80155c <open+0x6f>
		fd_close(fd, 0);
  801548:	83 ec 08             	sub    $0x8,%esp
  80154b:	6a 00                	push   $0x0
  80154d:	ff 75 f4             	pushl  -0xc(%ebp)
  801550:	e8 50 f9 ff ff       	call   800ea5 <fd_close>
		return r;
  801555:	83 c4 10             	add    $0x10,%esp
  801558:	89 da                	mov    %ebx,%edx
  80155a:	eb 17                	jmp    801573 <open+0x86>
	}

	return fd2num(fd);
  80155c:	83 ec 0c             	sub    $0xc,%esp
  80155f:	ff 75 f4             	pushl  -0xc(%ebp)
  801562:	e8 1f f8 ff ff       	call   800d86 <fd2num>
  801567:	89 c2                	mov    %eax,%edx
  801569:	83 c4 10             	add    $0x10,%esp
  80156c:	eb 05                	jmp    801573 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80156e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801573:	89 d0                	mov    %edx,%eax
  801575:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801578:	c9                   	leave  
  801579:	c3                   	ret    

0080157a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80157a:	55                   	push   %ebp
  80157b:	89 e5                	mov    %esp,%ebp
  80157d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801580:	ba 00 00 00 00       	mov    $0x0,%edx
  801585:	b8 08 00 00 00       	mov    $0x8,%eax
  80158a:	e8 a6 fd ff ff       	call   801335 <fsipc>
}
  80158f:	c9                   	leave  
  801590:	c3                   	ret    

00801591 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801591:	55                   	push   %ebp
  801592:	89 e5                	mov    %esp,%ebp
  801594:	56                   	push   %esi
  801595:	53                   	push   %ebx
  801596:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801599:	83 ec 0c             	sub    $0xc,%esp
  80159c:	ff 75 08             	pushl  0x8(%ebp)
  80159f:	e8 f2 f7 ff ff       	call   800d96 <fd2data>
  8015a4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8015a6:	83 c4 08             	add    $0x8,%esp
  8015a9:	68 2b 23 80 00       	push   $0x80232b
  8015ae:	53                   	push   %ebx
  8015af:	e8 be f1 ff ff       	call   800772 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015b4:	8b 46 04             	mov    0x4(%esi),%eax
  8015b7:	2b 06                	sub    (%esi),%eax
  8015b9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8015bf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015c6:	00 00 00 
	stat->st_dev = &devpipe;
  8015c9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8015d0:	30 80 00 
	return 0;
}
  8015d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8015d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015db:	5b                   	pop    %ebx
  8015dc:	5e                   	pop    %esi
  8015dd:	5d                   	pop    %ebp
  8015de:	c3                   	ret    

008015df <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8015df:	55                   	push   %ebp
  8015e0:	89 e5                	mov    %esp,%ebp
  8015e2:	53                   	push   %ebx
  8015e3:	83 ec 0c             	sub    $0xc,%esp
  8015e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015e9:	53                   	push   %ebx
  8015ea:	6a 00                	push   $0x0
  8015ec:	e8 09 f6 ff ff       	call   800bfa <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015f1:	89 1c 24             	mov    %ebx,(%esp)
  8015f4:	e8 9d f7 ff ff       	call   800d96 <fd2data>
  8015f9:	83 c4 08             	add    $0x8,%esp
  8015fc:	50                   	push   %eax
  8015fd:	6a 00                	push   $0x0
  8015ff:	e8 f6 f5 ff ff       	call   800bfa <sys_page_unmap>
}
  801604:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801607:	c9                   	leave  
  801608:	c3                   	ret    

00801609 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801609:	55                   	push   %ebp
  80160a:	89 e5                	mov    %esp,%ebp
  80160c:	57                   	push   %edi
  80160d:	56                   	push   %esi
  80160e:	53                   	push   %ebx
  80160f:	83 ec 1c             	sub    $0x1c,%esp
  801612:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801615:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801617:	a1 04 40 80 00       	mov    0x804004,%eax
  80161c:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80161f:	83 ec 0c             	sub    $0xc,%esp
  801622:	ff 75 e0             	pushl  -0x20(%ebp)
  801625:	e8 a3 05 00 00       	call   801bcd <pageref>
  80162a:	89 c3                	mov    %eax,%ebx
  80162c:	89 3c 24             	mov    %edi,(%esp)
  80162f:	e8 99 05 00 00       	call   801bcd <pageref>
  801634:	83 c4 10             	add    $0x10,%esp
  801637:	39 c3                	cmp    %eax,%ebx
  801639:	0f 94 c1             	sete   %cl
  80163c:	0f b6 c9             	movzbl %cl,%ecx
  80163f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801642:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801648:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  80164b:	39 ce                	cmp    %ecx,%esi
  80164d:	74 1b                	je     80166a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80164f:	39 c3                	cmp    %eax,%ebx
  801651:	75 c4                	jne    801617 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801653:	8b 42 60             	mov    0x60(%edx),%eax
  801656:	ff 75 e4             	pushl  -0x1c(%ebp)
  801659:	50                   	push   %eax
  80165a:	56                   	push   %esi
  80165b:	68 32 23 80 00       	push   $0x802332
  801660:	e8 88 eb ff ff       	call   8001ed <cprintf>
  801665:	83 c4 10             	add    $0x10,%esp
  801668:	eb ad                	jmp    801617 <_pipeisclosed+0xe>
	}
}
  80166a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80166d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801670:	5b                   	pop    %ebx
  801671:	5e                   	pop    %esi
  801672:	5f                   	pop    %edi
  801673:	5d                   	pop    %ebp
  801674:	c3                   	ret    

00801675 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
  801678:	57                   	push   %edi
  801679:	56                   	push   %esi
  80167a:	53                   	push   %ebx
  80167b:	83 ec 28             	sub    $0x28,%esp
  80167e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801681:	56                   	push   %esi
  801682:	e8 0f f7 ff ff       	call   800d96 <fd2data>
  801687:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801689:	83 c4 10             	add    $0x10,%esp
  80168c:	bf 00 00 00 00       	mov    $0x0,%edi
  801691:	eb 4b                	jmp    8016de <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801693:	89 da                	mov    %ebx,%edx
  801695:	89 f0                	mov    %esi,%eax
  801697:	e8 6d ff ff ff       	call   801609 <_pipeisclosed>
  80169c:	85 c0                	test   %eax,%eax
  80169e:	75 48                	jne    8016e8 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8016a0:	e8 b1 f4 ff ff       	call   800b56 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016a5:	8b 43 04             	mov    0x4(%ebx),%eax
  8016a8:	8b 0b                	mov    (%ebx),%ecx
  8016aa:	8d 51 20             	lea    0x20(%ecx),%edx
  8016ad:	39 d0                	cmp    %edx,%eax
  8016af:	73 e2                	jae    801693 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8016b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016b4:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8016b8:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8016bb:	89 c2                	mov    %eax,%edx
  8016bd:	c1 fa 1f             	sar    $0x1f,%edx
  8016c0:	89 d1                	mov    %edx,%ecx
  8016c2:	c1 e9 1b             	shr    $0x1b,%ecx
  8016c5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8016c8:	83 e2 1f             	and    $0x1f,%edx
  8016cb:	29 ca                	sub    %ecx,%edx
  8016cd:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8016d1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8016d5:	83 c0 01             	add    $0x1,%eax
  8016d8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016db:	83 c7 01             	add    $0x1,%edi
  8016de:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8016e1:	75 c2                	jne    8016a5 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8016e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8016e6:	eb 05                	jmp    8016ed <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016e8:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8016ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f0:	5b                   	pop    %ebx
  8016f1:	5e                   	pop    %esi
  8016f2:	5f                   	pop    %edi
  8016f3:	5d                   	pop    %ebp
  8016f4:	c3                   	ret    

008016f5 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016f5:	55                   	push   %ebp
  8016f6:	89 e5                	mov    %esp,%ebp
  8016f8:	57                   	push   %edi
  8016f9:	56                   	push   %esi
  8016fa:	53                   	push   %ebx
  8016fb:	83 ec 18             	sub    $0x18,%esp
  8016fe:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801701:	57                   	push   %edi
  801702:	e8 8f f6 ff ff       	call   800d96 <fd2data>
  801707:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801709:	83 c4 10             	add    $0x10,%esp
  80170c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801711:	eb 3d                	jmp    801750 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801713:	85 db                	test   %ebx,%ebx
  801715:	74 04                	je     80171b <devpipe_read+0x26>
				return i;
  801717:	89 d8                	mov    %ebx,%eax
  801719:	eb 44                	jmp    80175f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80171b:	89 f2                	mov    %esi,%edx
  80171d:	89 f8                	mov    %edi,%eax
  80171f:	e8 e5 fe ff ff       	call   801609 <_pipeisclosed>
  801724:	85 c0                	test   %eax,%eax
  801726:	75 32                	jne    80175a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801728:	e8 29 f4 ff ff       	call   800b56 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80172d:	8b 06                	mov    (%esi),%eax
  80172f:	3b 46 04             	cmp    0x4(%esi),%eax
  801732:	74 df                	je     801713 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801734:	99                   	cltd   
  801735:	c1 ea 1b             	shr    $0x1b,%edx
  801738:	01 d0                	add    %edx,%eax
  80173a:	83 e0 1f             	and    $0x1f,%eax
  80173d:	29 d0                	sub    %edx,%eax
  80173f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801744:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801747:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80174a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80174d:	83 c3 01             	add    $0x1,%ebx
  801750:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801753:	75 d8                	jne    80172d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801755:	8b 45 10             	mov    0x10(%ebp),%eax
  801758:	eb 05                	jmp    80175f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80175a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80175f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801762:	5b                   	pop    %ebx
  801763:	5e                   	pop    %esi
  801764:	5f                   	pop    %edi
  801765:	5d                   	pop    %ebp
  801766:	c3                   	ret    

00801767 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801767:	55                   	push   %ebp
  801768:	89 e5                	mov    %esp,%ebp
  80176a:	56                   	push   %esi
  80176b:	53                   	push   %ebx
  80176c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80176f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801772:	50                   	push   %eax
  801773:	e8 35 f6 ff ff       	call   800dad <fd_alloc>
  801778:	83 c4 10             	add    $0x10,%esp
  80177b:	89 c2                	mov    %eax,%edx
  80177d:	85 c0                	test   %eax,%eax
  80177f:	0f 88 2c 01 00 00    	js     8018b1 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801785:	83 ec 04             	sub    $0x4,%esp
  801788:	68 07 04 00 00       	push   $0x407
  80178d:	ff 75 f4             	pushl  -0xc(%ebp)
  801790:	6a 00                	push   $0x0
  801792:	e8 de f3 ff ff       	call   800b75 <sys_page_alloc>
  801797:	83 c4 10             	add    $0x10,%esp
  80179a:	89 c2                	mov    %eax,%edx
  80179c:	85 c0                	test   %eax,%eax
  80179e:	0f 88 0d 01 00 00    	js     8018b1 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017a4:	83 ec 0c             	sub    $0xc,%esp
  8017a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017aa:	50                   	push   %eax
  8017ab:	e8 fd f5 ff ff       	call   800dad <fd_alloc>
  8017b0:	89 c3                	mov    %eax,%ebx
  8017b2:	83 c4 10             	add    $0x10,%esp
  8017b5:	85 c0                	test   %eax,%eax
  8017b7:	0f 88 e2 00 00 00    	js     80189f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017bd:	83 ec 04             	sub    $0x4,%esp
  8017c0:	68 07 04 00 00       	push   $0x407
  8017c5:	ff 75 f0             	pushl  -0x10(%ebp)
  8017c8:	6a 00                	push   $0x0
  8017ca:	e8 a6 f3 ff ff       	call   800b75 <sys_page_alloc>
  8017cf:	89 c3                	mov    %eax,%ebx
  8017d1:	83 c4 10             	add    $0x10,%esp
  8017d4:	85 c0                	test   %eax,%eax
  8017d6:	0f 88 c3 00 00 00    	js     80189f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8017dc:	83 ec 0c             	sub    $0xc,%esp
  8017df:	ff 75 f4             	pushl  -0xc(%ebp)
  8017e2:	e8 af f5 ff ff       	call   800d96 <fd2data>
  8017e7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017e9:	83 c4 0c             	add    $0xc,%esp
  8017ec:	68 07 04 00 00       	push   $0x407
  8017f1:	50                   	push   %eax
  8017f2:	6a 00                	push   $0x0
  8017f4:	e8 7c f3 ff ff       	call   800b75 <sys_page_alloc>
  8017f9:	89 c3                	mov    %eax,%ebx
  8017fb:	83 c4 10             	add    $0x10,%esp
  8017fe:	85 c0                	test   %eax,%eax
  801800:	0f 88 89 00 00 00    	js     80188f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801806:	83 ec 0c             	sub    $0xc,%esp
  801809:	ff 75 f0             	pushl  -0x10(%ebp)
  80180c:	e8 85 f5 ff ff       	call   800d96 <fd2data>
  801811:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801818:	50                   	push   %eax
  801819:	6a 00                	push   $0x0
  80181b:	56                   	push   %esi
  80181c:	6a 00                	push   $0x0
  80181e:	e8 95 f3 ff ff       	call   800bb8 <sys_page_map>
  801823:	89 c3                	mov    %eax,%ebx
  801825:	83 c4 20             	add    $0x20,%esp
  801828:	85 c0                	test   %eax,%eax
  80182a:	78 55                	js     801881 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80182c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801832:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801835:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801837:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80183a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801841:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801847:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80184a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80184c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80184f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801856:	83 ec 0c             	sub    $0xc,%esp
  801859:	ff 75 f4             	pushl  -0xc(%ebp)
  80185c:	e8 25 f5 ff ff       	call   800d86 <fd2num>
  801861:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801864:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801866:	83 c4 04             	add    $0x4,%esp
  801869:	ff 75 f0             	pushl  -0x10(%ebp)
  80186c:	e8 15 f5 ff ff       	call   800d86 <fd2num>
  801871:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801874:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801877:	83 c4 10             	add    $0x10,%esp
  80187a:	ba 00 00 00 00       	mov    $0x0,%edx
  80187f:	eb 30                	jmp    8018b1 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801881:	83 ec 08             	sub    $0x8,%esp
  801884:	56                   	push   %esi
  801885:	6a 00                	push   $0x0
  801887:	e8 6e f3 ff ff       	call   800bfa <sys_page_unmap>
  80188c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80188f:	83 ec 08             	sub    $0x8,%esp
  801892:	ff 75 f0             	pushl  -0x10(%ebp)
  801895:	6a 00                	push   $0x0
  801897:	e8 5e f3 ff ff       	call   800bfa <sys_page_unmap>
  80189c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80189f:	83 ec 08             	sub    $0x8,%esp
  8018a2:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a5:	6a 00                	push   $0x0
  8018a7:	e8 4e f3 ff ff       	call   800bfa <sys_page_unmap>
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8018b1:	89 d0                	mov    %edx,%eax
  8018b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b6:	5b                   	pop    %ebx
  8018b7:	5e                   	pop    %esi
  8018b8:	5d                   	pop    %ebp
  8018b9:	c3                   	ret    

008018ba <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8018ba:	55                   	push   %ebp
  8018bb:	89 e5                	mov    %esp,%ebp
  8018bd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c3:	50                   	push   %eax
  8018c4:	ff 75 08             	pushl  0x8(%ebp)
  8018c7:	e8 30 f5 ff ff       	call   800dfc <fd_lookup>
  8018cc:	83 c4 10             	add    $0x10,%esp
  8018cf:	85 c0                	test   %eax,%eax
  8018d1:	78 18                	js     8018eb <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8018d3:	83 ec 0c             	sub    $0xc,%esp
  8018d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8018d9:	e8 b8 f4 ff ff       	call   800d96 <fd2data>
	return _pipeisclosed(fd, p);
  8018de:	89 c2                	mov    %eax,%edx
  8018e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e3:	e8 21 fd ff ff       	call   801609 <_pipeisclosed>
  8018e8:	83 c4 10             	add    $0x10,%esp
}
  8018eb:	c9                   	leave  
  8018ec:	c3                   	ret    

008018ed <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8018ed:	55                   	push   %ebp
  8018ee:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8018f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f5:	5d                   	pop    %ebp
  8018f6:	c3                   	ret    

008018f7 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018fd:	68 4a 23 80 00       	push   $0x80234a
  801902:	ff 75 0c             	pushl  0xc(%ebp)
  801905:	e8 68 ee ff ff       	call   800772 <strcpy>
	return 0;
}
  80190a:	b8 00 00 00 00       	mov    $0x0,%eax
  80190f:	c9                   	leave  
  801910:	c3                   	ret    

00801911 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
  801914:	57                   	push   %edi
  801915:	56                   	push   %esi
  801916:	53                   	push   %ebx
  801917:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80191d:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801922:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801928:	eb 2d                	jmp    801957 <devcons_write+0x46>
		m = n - tot;
  80192a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80192d:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80192f:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801932:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801937:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80193a:	83 ec 04             	sub    $0x4,%esp
  80193d:	53                   	push   %ebx
  80193e:	03 45 0c             	add    0xc(%ebp),%eax
  801941:	50                   	push   %eax
  801942:	57                   	push   %edi
  801943:	e8 bc ef ff ff       	call   800904 <memmove>
		sys_cputs(buf, m);
  801948:	83 c4 08             	add    $0x8,%esp
  80194b:	53                   	push   %ebx
  80194c:	57                   	push   %edi
  80194d:	e8 67 f1 ff ff       	call   800ab9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801952:	01 de                	add    %ebx,%esi
  801954:	83 c4 10             	add    $0x10,%esp
  801957:	89 f0                	mov    %esi,%eax
  801959:	3b 75 10             	cmp    0x10(%ebp),%esi
  80195c:	72 cc                	jb     80192a <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80195e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801961:	5b                   	pop    %ebx
  801962:	5e                   	pop    %esi
  801963:	5f                   	pop    %edi
  801964:	5d                   	pop    %ebp
  801965:	c3                   	ret    

00801966 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801966:	55                   	push   %ebp
  801967:	89 e5                	mov    %esp,%ebp
  801969:	83 ec 08             	sub    $0x8,%esp
  80196c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801971:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801975:	74 2a                	je     8019a1 <devcons_read+0x3b>
  801977:	eb 05                	jmp    80197e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801979:	e8 d8 f1 ff ff       	call   800b56 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80197e:	e8 54 f1 ff ff       	call   800ad7 <sys_cgetc>
  801983:	85 c0                	test   %eax,%eax
  801985:	74 f2                	je     801979 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801987:	85 c0                	test   %eax,%eax
  801989:	78 16                	js     8019a1 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80198b:	83 f8 04             	cmp    $0x4,%eax
  80198e:	74 0c                	je     80199c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801990:	8b 55 0c             	mov    0xc(%ebp),%edx
  801993:	88 02                	mov    %al,(%edx)
	return 1;
  801995:	b8 01 00 00 00       	mov    $0x1,%eax
  80199a:	eb 05                	jmp    8019a1 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80199c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8019a1:	c9                   	leave  
  8019a2:	c3                   	ret    

008019a3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8019a3:	55                   	push   %ebp
  8019a4:	89 e5                	mov    %esp,%ebp
  8019a6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ac:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8019af:	6a 01                	push   $0x1
  8019b1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019b4:	50                   	push   %eax
  8019b5:	e8 ff f0 ff ff       	call   800ab9 <sys_cputs>
}
  8019ba:	83 c4 10             	add    $0x10,%esp
  8019bd:	c9                   	leave  
  8019be:	c3                   	ret    

008019bf <getchar>:

int
getchar(void)
{
  8019bf:	55                   	push   %ebp
  8019c0:	89 e5                	mov    %esp,%ebp
  8019c2:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8019c5:	6a 01                	push   $0x1
  8019c7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019ca:	50                   	push   %eax
  8019cb:	6a 00                	push   $0x0
  8019cd:	e8 90 f6 ff ff       	call   801062 <read>
	if (r < 0)
  8019d2:	83 c4 10             	add    $0x10,%esp
  8019d5:	85 c0                	test   %eax,%eax
  8019d7:	78 0f                	js     8019e8 <getchar+0x29>
		return r;
	if (r < 1)
  8019d9:	85 c0                	test   %eax,%eax
  8019db:	7e 06                	jle    8019e3 <getchar+0x24>
		return -E_EOF;
	return c;
  8019dd:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8019e1:	eb 05                	jmp    8019e8 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8019e3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8019e8:	c9                   	leave  
  8019e9:	c3                   	ret    

008019ea <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8019ea:	55                   	push   %ebp
  8019eb:	89 e5                	mov    %esp,%ebp
  8019ed:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f3:	50                   	push   %eax
  8019f4:	ff 75 08             	pushl  0x8(%ebp)
  8019f7:	e8 00 f4 ff ff       	call   800dfc <fd_lookup>
  8019fc:	83 c4 10             	add    $0x10,%esp
  8019ff:	85 c0                	test   %eax,%eax
  801a01:	78 11                	js     801a14 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a06:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a0c:	39 10                	cmp    %edx,(%eax)
  801a0e:	0f 94 c0             	sete   %al
  801a11:	0f b6 c0             	movzbl %al,%eax
}
  801a14:	c9                   	leave  
  801a15:	c3                   	ret    

00801a16 <opencons>:

int
opencons(void)
{
  801a16:	55                   	push   %ebp
  801a17:	89 e5                	mov    %esp,%ebp
  801a19:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a1f:	50                   	push   %eax
  801a20:	e8 88 f3 ff ff       	call   800dad <fd_alloc>
  801a25:	83 c4 10             	add    $0x10,%esp
		return r;
  801a28:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a2a:	85 c0                	test   %eax,%eax
  801a2c:	78 3e                	js     801a6c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a2e:	83 ec 04             	sub    $0x4,%esp
  801a31:	68 07 04 00 00       	push   $0x407
  801a36:	ff 75 f4             	pushl  -0xc(%ebp)
  801a39:	6a 00                	push   $0x0
  801a3b:	e8 35 f1 ff ff       	call   800b75 <sys_page_alloc>
  801a40:	83 c4 10             	add    $0x10,%esp
		return r;
  801a43:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a45:	85 c0                	test   %eax,%eax
  801a47:	78 23                	js     801a6c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a49:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a52:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a57:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a5e:	83 ec 0c             	sub    $0xc,%esp
  801a61:	50                   	push   %eax
  801a62:	e8 1f f3 ff ff       	call   800d86 <fd2num>
  801a67:	89 c2                	mov    %eax,%edx
  801a69:	83 c4 10             	add    $0x10,%esp
}
  801a6c:	89 d0                	mov    %edx,%eax
  801a6e:	c9                   	leave  
  801a6f:	c3                   	ret    

00801a70 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a70:	55                   	push   %ebp
  801a71:	89 e5                	mov    %esp,%ebp
  801a73:	56                   	push   %esi
  801a74:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a75:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a78:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a7e:	e8 b4 f0 ff ff       	call   800b37 <sys_getenvid>
  801a83:	83 ec 0c             	sub    $0xc,%esp
  801a86:	ff 75 0c             	pushl  0xc(%ebp)
  801a89:	ff 75 08             	pushl  0x8(%ebp)
  801a8c:	56                   	push   %esi
  801a8d:	50                   	push   %eax
  801a8e:	68 58 23 80 00       	push   $0x802358
  801a93:	e8 55 e7 ff ff       	call   8001ed <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a98:	83 c4 18             	add    $0x18,%esp
  801a9b:	53                   	push   %ebx
  801a9c:	ff 75 10             	pushl  0x10(%ebp)
  801a9f:	e8 f8 e6 ff ff       	call   80019c <vcprintf>
	cprintf("\n");
  801aa4:	c7 04 24 43 23 80 00 	movl   $0x802343,(%esp)
  801aab:	e8 3d e7 ff ff       	call   8001ed <cprintf>
  801ab0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ab3:	cc                   	int3   
  801ab4:	eb fd                	jmp    801ab3 <_panic+0x43>

00801ab6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ab6:	55                   	push   %ebp
  801ab7:	89 e5                	mov    %esp,%ebp
  801ab9:	56                   	push   %esi
  801aba:	53                   	push   %ebx
  801abb:	8b 75 08             	mov    0x8(%ebp),%esi
  801abe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801ac4:	85 c0                	test   %eax,%eax
  801ac6:	75 12                	jne    801ada <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801ac8:	83 ec 0c             	sub    $0xc,%esp
  801acb:	68 00 00 c0 ee       	push   $0xeec00000
  801ad0:	e8 50 f2 ff ff       	call   800d25 <sys_ipc_recv>
  801ad5:	83 c4 10             	add    $0x10,%esp
  801ad8:	eb 0c                	jmp    801ae6 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801ada:	83 ec 0c             	sub    $0xc,%esp
  801add:	50                   	push   %eax
  801ade:	e8 42 f2 ff ff       	call   800d25 <sys_ipc_recv>
  801ae3:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801ae6:	85 f6                	test   %esi,%esi
  801ae8:	0f 95 c1             	setne  %cl
  801aeb:	85 db                	test   %ebx,%ebx
  801aed:	0f 95 c2             	setne  %dl
  801af0:	84 d1                	test   %dl,%cl
  801af2:	74 09                	je     801afd <ipc_recv+0x47>
  801af4:	89 c2                	mov    %eax,%edx
  801af6:	c1 ea 1f             	shr    $0x1f,%edx
  801af9:	84 d2                	test   %dl,%dl
  801afb:	75 27                	jne    801b24 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801afd:	85 f6                	test   %esi,%esi
  801aff:	74 0a                	je     801b0b <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801b01:	a1 04 40 80 00       	mov    0x804004,%eax
  801b06:	8b 40 7c             	mov    0x7c(%eax),%eax
  801b09:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801b0b:	85 db                	test   %ebx,%ebx
  801b0d:	74 0d                	je     801b1c <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  801b0f:	a1 04 40 80 00       	mov    0x804004,%eax
  801b14:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801b1a:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801b1c:	a1 04 40 80 00       	mov    0x804004,%eax
  801b21:	8b 40 78             	mov    0x78(%eax),%eax
}
  801b24:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b27:	5b                   	pop    %ebx
  801b28:	5e                   	pop    %esi
  801b29:	5d                   	pop    %ebp
  801b2a:	c3                   	ret    

00801b2b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	57                   	push   %edi
  801b2f:	56                   	push   %esi
  801b30:	53                   	push   %ebx
  801b31:	83 ec 0c             	sub    $0xc,%esp
  801b34:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b37:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801b3d:	85 db                	test   %ebx,%ebx
  801b3f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b44:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801b47:	ff 75 14             	pushl  0x14(%ebp)
  801b4a:	53                   	push   %ebx
  801b4b:	56                   	push   %esi
  801b4c:	57                   	push   %edi
  801b4d:	e8 b0 f1 ff ff       	call   800d02 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801b52:	89 c2                	mov    %eax,%edx
  801b54:	c1 ea 1f             	shr    $0x1f,%edx
  801b57:	83 c4 10             	add    $0x10,%esp
  801b5a:	84 d2                	test   %dl,%dl
  801b5c:	74 17                	je     801b75 <ipc_send+0x4a>
  801b5e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b61:	74 12                	je     801b75 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801b63:	50                   	push   %eax
  801b64:	68 7c 23 80 00       	push   $0x80237c
  801b69:	6a 47                	push   $0x47
  801b6b:	68 8a 23 80 00       	push   $0x80238a
  801b70:	e8 fb fe ff ff       	call   801a70 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801b75:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b78:	75 07                	jne    801b81 <ipc_send+0x56>
			sys_yield();
  801b7a:	e8 d7 ef ff ff       	call   800b56 <sys_yield>
  801b7f:	eb c6                	jmp    801b47 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801b81:	85 c0                	test   %eax,%eax
  801b83:	75 c2                	jne    801b47 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801b85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b88:	5b                   	pop    %ebx
  801b89:	5e                   	pop    %esi
  801b8a:	5f                   	pop    %edi
  801b8b:	5d                   	pop    %ebp
  801b8c:	c3                   	ret    

00801b8d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b8d:	55                   	push   %ebp
  801b8e:	89 e5                	mov    %esp,%ebp
  801b90:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b93:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b98:	89 c2                	mov    %eax,%edx
  801b9a:	c1 e2 07             	shl    $0x7,%edx
  801b9d:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801ba4:	8b 52 58             	mov    0x58(%edx),%edx
  801ba7:	39 ca                	cmp    %ecx,%edx
  801ba9:	75 11                	jne    801bbc <ipc_find_env+0x2f>
			return envs[i].env_id;
  801bab:	89 c2                	mov    %eax,%edx
  801bad:	c1 e2 07             	shl    $0x7,%edx
  801bb0:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801bb7:	8b 40 50             	mov    0x50(%eax),%eax
  801bba:	eb 0f                	jmp    801bcb <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bbc:	83 c0 01             	add    $0x1,%eax
  801bbf:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bc4:	75 d2                	jne    801b98 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801bc6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bcb:	5d                   	pop    %ebp
  801bcc:	c3                   	ret    

00801bcd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bcd:	55                   	push   %ebp
  801bce:	89 e5                	mov    %esp,%ebp
  801bd0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bd3:	89 d0                	mov    %edx,%eax
  801bd5:	c1 e8 16             	shr    $0x16,%eax
  801bd8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801bdf:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801be4:	f6 c1 01             	test   $0x1,%cl
  801be7:	74 1d                	je     801c06 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801be9:	c1 ea 0c             	shr    $0xc,%edx
  801bec:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bf3:	f6 c2 01             	test   $0x1,%dl
  801bf6:	74 0e                	je     801c06 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bf8:	c1 ea 0c             	shr    $0xc,%edx
  801bfb:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c02:	ef 
  801c03:	0f b7 c0             	movzwl %ax,%eax
}
  801c06:	5d                   	pop    %ebp
  801c07:	c3                   	ret    
  801c08:	66 90                	xchg   %ax,%ax
  801c0a:	66 90                	xchg   %ax,%ax
  801c0c:	66 90                	xchg   %ax,%ax
  801c0e:	66 90                	xchg   %ax,%ax

00801c10 <__udivdi3>:
  801c10:	55                   	push   %ebp
  801c11:	57                   	push   %edi
  801c12:	56                   	push   %esi
  801c13:	53                   	push   %ebx
  801c14:	83 ec 1c             	sub    $0x1c,%esp
  801c17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c27:	85 f6                	test   %esi,%esi
  801c29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c2d:	89 ca                	mov    %ecx,%edx
  801c2f:	89 f8                	mov    %edi,%eax
  801c31:	75 3d                	jne    801c70 <__udivdi3+0x60>
  801c33:	39 cf                	cmp    %ecx,%edi
  801c35:	0f 87 c5 00 00 00    	ja     801d00 <__udivdi3+0xf0>
  801c3b:	85 ff                	test   %edi,%edi
  801c3d:	89 fd                	mov    %edi,%ebp
  801c3f:	75 0b                	jne    801c4c <__udivdi3+0x3c>
  801c41:	b8 01 00 00 00       	mov    $0x1,%eax
  801c46:	31 d2                	xor    %edx,%edx
  801c48:	f7 f7                	div    %edi
  801c4a:	89 c5                	mov    %eax,%ebp
  801c4c:	89 c8                	mov    %ecx,%eax
  801c4e:	31 d2                	xor    %edx,%edx
  801c50:	f7 f5                	div    %ebp
  801c52:	89 c1                	mov    %eax,%ecx
  801c54:	89 d8                	mov    %ebx,%eax
  801c56:	89 cf                	mov    %ecx,%edi
  801c58:	f7 f5                	div    %ebp
  801c5a:	89 c3                	mov    %eax,%ebx
  801c5c:	89 d8                	mov    %ebx,%eax
  801c5e:	89 fa                	mov    %edi,%edx
  801c60:	83 c4 1c             	add    $0x1c,%esp
  801c63:	5b                   	pop    %ebx
  801c64:	5e                   	pop    %esi
  801c65:	5f                   	pop    %edi
  801c66:	5d                   	pop    %ebp
  801c67:	c3                   	ret    
  801c68:	90                   	nop
  801c69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c70:	39 ce                	cmp    %ecx,%esi
  801c72:	77 74                	ja     801ce8 <__udivdi3+0xd8>
  801c74:	0f bd fe             	bsr    %esi,%edi
  801c77:	83 f7 1f             	xor    $0x1f,%edi
  801c7a:	0f 84 98 00 00 00    	je     801d18 <__udivdi3+0x108>
  801c80:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c85:	89 f9                	mov    %edi,%ecx
  801c87:	89 c5                	mov    %eax,%ebp
  801c89:	29 fb                	sub    %edi,%ebx
  801c8b:	d3 e6                	shl    %cl,%esi
  801c8d:	89 d9                	mov    %ebx,%ecx
  801c8f:	d3 ed                	shr    %cl,%ebp
  801c91:	89 f9                	mov    %edi,%ecx
  801c93:	d3 e0                	shl    %cl,%eax
  801c95:	09 ee                	or     %ebp,%esi
  801c97:	89 d9                	mov    %ebx,%ecx
  801c99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c9d:	89 d5                	mov    %edx,%ebp
  801c9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ca3:	d3 ed                	shr    %cl,%ebp
  801ca5:	89 f9                	mov    %edi,%ecx
  801ca7:	d3 e2                	shl    %cl,%edx
  801ca9:	89 d9                	mov    %ebx,%ecx
  801cab:	d3 e8                	shr    %cl,%eax
  801cad:	09 c2                	or     %eax,%edx
  801caf:	89 d0                	mov    %edx,%eax
  801cb1:	89 ea                	mov    %ebp,%edx
  801cb3:	f7 f6                	div    %esi
  801cb5:	89 d5                	mov    %edx,%ebp
  801cb7:	89 c3                	mov    %eax,%ebx
  801cb9:	f7 64 24 0c          	mull   0xc(%esp)
  801cbd:	39 d5                	cmp    %edx,%ebp
  801cbf:	72 10                	jb     801cd1 <__udivdi3+0xc1>
  801cc1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801cc5:	89 f9                	mov    %edi,%ecx
  801cc7:	d3 e6                	shl    %cl,%esi
  801cc9:	39 c6                	cmp    %eax,%esi
  801ccb:	73 07                	jae    801cd4 <__udivdi3+0xc4>
  801ccd:	39 d5                	cmp    %edx,%ebp
  801ccf:	75 03                	jne    801cd4 <__udivdi3+0xc4>
  801cd1:	83 eb 01             	sub    $0x1,%ebx
  801cd4:	31 ff                	xor    %edi,%edi
  801cd6:	89 d8                	mov    %ebx,%eax
  801cd8:	89 fa                	mov    %edi,%edx
  801cda:	83 c4 1c             	add    $0x1c,%esp
  801cdd:	5b                   	pop    %ebx
  801cde:	5e                   	pop    %esi
  801cdf:	5f                   	pop    %edi
  801ce0:	5d                   	pop    %ebp
  801ce1:	c3                   	ret    
  801ce2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ce8:	31 ff                	xor    %edi,%edi
  801cea:	31 db                	xor    %ebx,%ebx
  801cec:	89 d8                	mov    %ebx,%eax
  801cee:	89 fa                	mov    %edi,%edx
  801cf0:	83 c4 1c             	add    $0x1c,%esp
  801cf3:	5b                   	pop    %ebx
  801cf4:	5e                   	pop    %esi
  801cf5:	5f                   	pop    %edi
  801cf6:	5d                   	pop    %ebp
  801cf7:	c3                   	ret    
  801cf8:	90                   	nop
  801cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d00:	89 d8                	mov    %ebx,%eax
  801d02:	f7 f7                	div    %edi
  801d04:	31 ff                	xor    %edi,%edi
  801d06:	89 c3                	mov    %eax,%ebx
  801d08:	89 d8                	mov    %ebx,%eax
  801d0a:	89 fa                	mov    %edi,%edx
  801d0c:	83 c4 1c             	add    $0x1c,%esp
  801d0f:	5b                   	pop    %ebx
  801d10:	5e                   	pop    %esi
  801d11:	5f                   	pop    %edi
  801d12:	5d                   	pop    %ebp
  801d13:	c3                   	ret    
  801d14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d18:	39 ce                	cmp    %ecx,%esi
  801d1a:	72 0c                	jb     801d28 <__udivdi3+0x118>
  801d1c:	31 db                	xor    %ebx,%ebx
  801d1e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d22:	0f 87 34 ff ff ff    	ja     801c5c <__udivdi3+0x4c>
  801d28:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d2d:	e9 2a ff ff ff       	jmp    801c5c <__udivdi3+0x4c>
  801d32:	66 90                	xchg   %ax,%ax
  801d34:	66 90                	xchg   %ax,%ax
  801d36:	66 90                	xchg   %ax,%ax
  801d38:	66 90                	xchg   %ax,%ax
  801d3a:	66 90                	xchg   %ax,%ax
  801d3c:	66 90                	xchg   %ax,%ax
  801d3e:	66 90                	xchg   %ax,%ax

00801d40 <__umoddi3>:
  801d40:	55                   	push   %ebp
  801d41:	57                   	push   %edi
  801d42:	56                   	push   %esi
  801d43:	53                   	push   %ebx
  801d44:	83 ec 1c             	sub    $0x1c,%esp
  801d47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d57:	85 d2                	test   %edx,%edx
  801d59:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d61:	89 f3                	mov    %esi,%ebx
  801d63:	89 3c 24             	mov    %edi,(%esp)
  801d66:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d6a:	75 1c                	jne    801d88 <__umoddi3+0x48>
  801d6c:	39 f7                	cmp    %esi,%edi
  801d6e:	76 50                	jbe    801dc0 <__umoddi3+0x80>
  801d70:	89 c8                	mov    %ecx,%eax
  801d72:	89 f2                	mov    %esi,%edx
  801d74:	f7 f7                	div    %edi
  801d76:	89 d0                	mov    %edx,%eax
  801d78:	31 d2                	xor    %edx,%edx
  801d7a:	83 c4 1c             	add    $0x1c,%esp
  801d7d:	5b                   	pop    %ebx
  801d7e:	5e                   	pop    %esi
  801d7f:	5f                   	pop    %edi
  801d80:	5d                   	pop    %ebp
  801d81:	c3                   	ret    
  801d82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d88:	39 f2                	cmp    %esi,%edx
  801d8a:	89 d0                	mov    %edx,%eax
  801d8c:	77 52                	ja     801de0 <__umoddi3+0xa0>
  801d8e:	0f bd ea             	bsr    %edx,%ebp
  801d91:	83 f5 1f             	xor    $0x1f,%ebp
  801d94:	75 5a                	jne    801df0 <__umoddi3+0xb0>
  801d96:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d9a:	0f 82 e0 00 00 00    	jb     801e80 <__umoddi3+0x140>
  801da0:	39 0c 24             	cmp    %ecx,(%esp)
  801da3:	0f 86 d7 00 00 00    	jbe    801e80 <__umoddi3+0x140>
  801da9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801dad:	8b 54 24 04          	mov    0x4(%esp),%edx
  801db1:	83 c4 1c             	add    $0x1c,%esp
  801db4:	5b                   	pop    %ebx
  801db5:	5e                   	pop    %esi
  801db6:	5f                   	pop    %edi
  801db7:	5d                   	pop    %ebp
  801db8:	c3                   	ret    
  801db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dc0:	85 ff                	test   %edi,%edi
  801dc2:	89 fd                	mov    %edi,%ebp
  801dc4:	75 0b                	jne    801dd1 <__umoddi3+0x91>
  801dc6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dcb:	31 d2                	xor    %edx,%edx
  801dcd:	f7 f7                	div    %edi
  801dcf:	89 c5                	mov    %eax,%ebp
  801dd1:	89 f0                	mov    %esi,%eax
  801dd3:	31 d2                	xor    %edx,%edx
  801dd5:	f7 f5                	div    %ebp
  801dd7:	89 c8                	mov    %ecx,%eax
  801dd9:	f7 f5                	div    %ebp
  801ddb:	89 d0                	mov    %edx,%eax
  801ddd:	eb 99                	jmp    801d78 <__umoddi3+0x38>
  801ddf:	90                   	nop
  801de0:	89 c8                	mov    %ecx,%eax
  801de2:	89 f2                	mov    %esi,%edx
  801de4:	83 c4 1c             	add    $0x1c,%esp
  801de7:	5b                   	pop    %ebx
  801de8:	5e                   	pop    %esi
  801de9:	5f                   	pop    %edi
  801dea:	5d                   	pop    %ebp
  801deb:	c3                   	ret    
  801dec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801df0:	8b 34 24             	mov    (%esp),%esi
  801df3:	bf 20 00 00 00       	mov    $0x20,%edi
  801df8:	89 e9                	mov    %ebp,%ecx
  801dfa:	29 ef                	sub    %ebp,%edi
  801dfc:	d3 e0                	shl    %cl,%eax
  801dfe:	89 f9                	mov    %edi,%ecx
  801e00:	89 f2                	mov    %esi,%edx
  801e02:	d3 ea                	shr    %cl,%edx
  801e04:	89 e9                	mov    %ebp,%ecx
  801e06:	09 c2                	or     %eax,%edx
  801e08:	89 d8                	mov    %ebx,%eax
  801e0a:	89 14 24             	mov    %edx,(%esp)
  801e0d:	89 f2                	mov    %esi,%edx
  801e0f:	d3 e2                	shl    %cl,%edx
  801e11:	89 f9                	mov    %edi,%ecx
  801e13:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e17:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e1b:	d3 e8                	shr    %cl,%eax
  801e1d:	89 e9                	mov    %ebp,%ecx
  801e1f:	89 c6                	mov    %eax,%esi
  801e21:	d3 e3                	shl    %cl,%ebx
  801e23:	89 f9                	mov    %edi,%ecx
  801e25:	89 d0                	mov    %edx,%eax
  801e27:	d3 e8                	shr    %cl,%eax
  801e29:	89 e9                	mov    %ebp,%ecx
  801e2b:	09 d8                	or     %ebx,%eax
  801e2d:	89 d3                	mov    %edx,%ebx
  801e2f:	89 f2                	mov    %esi,%edx
  801e31:	f7 34 24             	divl   (%esp)
  801e34:	89 d6                	mov    %edx,%esi
  801e36:	d3 e3                	shl    %cl,%ebx
  801e38:	f7 64 24 04          	mull   0x4(%esp)
  801e3c:	39 d6                	cmp    %edx,%esi
  801e3e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e42:	89 d1                	mov    %edx,%ecx
  801e44:	89 c3                	mov    %eax,%ebx
  801e46:	72 08                	jb     801e50 <__umoddi3+0x110>
  801e48:	75 11                	jne    801e5b <__umoddi3+0x11b>
  801e4a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e4e:	73 0b                	jae    801e5b <__umoddi3+0x11b>
  801e50:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e54:	1b 14 24             	sbb    (%esp),%edx
  801e57:	89 d1                	mov    %edx,%ecx
  801e59:	89 c3                	mov    %eax,%ebx
  801e5b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e5f:	29 da                	sub    %ebx,%edx
  801e61:	19 ce                	sbb    %ecx,%esi
  801e63:	89 f9                	mov    %edi,%ecx
  801e65:	89 f0                	mov    %esi,%eax
  801e67:	d3 e0                	shl    %cl,%eax
  801e69:	89 e9                	mov    %ebp,%ecx
  801e6b:	d3 ea                	shr    %cl,%edx
  801e6d:	89 e9                	mov    %ebp,%ecx
  801e6f:	d3 ee                	shr    %cl,%esi
  801e71:	09 d0                	or     %edx,%eax
  801e73:	89 f2                	mov    %esi,%edx
  801e75:	83 c4 1c             	add    $0x1c,%esp
  801e78:	5b                   	pop    %ebx
  801e79:	5e                   	pop    %esi
  801e7a:	5f                   	pop    %edi
  801e7b:	5d                   	pop    %ebp
  801e7c:	c3                   	ret    
  801e7d:	8d 76 00             	lea    0x0(%esi),%esi
  801e80:	29 f9                	sub    %edi,%ecx
  801e82:	19 d6                	sbb    %edx,%esi
  801e84:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e88:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e8c:	e9 18 ff ff ff       	jmp    801da9 <__umoddi3+0x69>
