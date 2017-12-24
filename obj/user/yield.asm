
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
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 60 1e 80 00       	push   $0x801e60
  800048:	e8 88 01 00 00       	call   8001d5 <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 e4 0a 00 00       	call   800b3e <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 04 40 80 00       	mov    0x804004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  80005f:	8b 40 48             	mov    0x48(%eax),%eax
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 80 1e 80 00       	push   $0x801e80
  80006c:	e8 64 01 00 00       	call   8001d5 <cprintf>
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
  800081:	8b 40 48             	mov    0x48(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 ac 1e 80 00       	push   $0x801eac
  80008d:	e8 43 01 00 00       	call   8001d5 <cprintf>
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
  8000ad:	e8 6d 0a 00 00       	call   800b1f <sys_getenvid>
  8000b2:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  8000b8:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8000bd:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000c2:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  8000c7:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  8000ca:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  8000d0:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  8000d3:	39 c8                	cmp    %ecx,%eax
  8000d5:	0f 44 fb             	cmove  %ebx,%edi
  8000d8:	b9 01 00 00 00       	mov    $0x1,%ecx
  8000dd:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000e0:	83 c2 01             	add    $0x1,%edx
  8000e3:	83 c3 7c             	add    $0x7c,%ebx
  8000e6:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  8000ec:	75 d9                	jne    8000c7 <libmain+0x2d>
  8000ee:	89 f0                	mov    %esi,%eax
  8000f0:	84 c0                	test   %al,%al
  8000f2:	74 06                	je     8000fa <libmain+0x60>
  8000f4:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000fa:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000fe:	7e 0a                	jle    80010a <libmain+0x70>
		binaryname = argv[0];
  800100:	8b 45 0c             	mov    0xc(%ebp),%eax
  800103:	8b 00                	mov    (%eax),%eax
  800105:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80010a:	83 ec 08             	sub    $0x8,%esp
  80010d:	ff 75 0c             	pushl  0xc(%ebp)
  800110:	ff 75 08             	pushl  0x8(%ebp)
  800113:	e8 1b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800118:	e8 0b 00 00 00       	call   800128 <exit>
}
  80011d:	83 c4 10             	add    $0x10,%esp
  800120:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5f                   	pop    %edi
  800126:	5d                   	pop    %ebp
  800127:	c3                   	ret    

00800128 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012e:	e8 e6 0d 00 00       	call   800f19 <close_all>
	sys_env_destroy(0);
  800133:	83 ec 0c             	sub    $0xc,%esp
  800136:	6a 00                	push   $0x0
  800138:	e8 a1 09 00 00       	call   800ade <sys_env_destroy>
}
  80013d:	83 c4 10             	add    $0x10,%esp
  800140:	c9                   	leave  
  800141:	c3                   	ret    

00800142 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800142:	55                   	push   %ebp
  800143:	89 e5                	mov    %esp,%ebp
  800145:	53                   	push   %ebx
  800146:	83 ec 04             	sub    $0x4,%esp
  800149:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80014c:	8b 13                	mov    (%ebx),%edx
  80014e:	8d 42 01             	lea    0x1(%edx),%eax
  800151:	89 03                	mov    %eax,(%ebx)
  800153:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800156:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80015a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80015f:	75 1a                	jne    80017b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800161:	83 ec 08             	sub    $0x8,%esp
  800164:	68 ff 00 00 00       	push   $0xff
  800169:	8d 43 08             	lea    0x8(%ebx),%eax
  80016c:	50                   	push   %eax
  80016d:	e8 2f 09 00 00       	call   800aa1 <sys_cputs>
		b->idx = 0;
  800172:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800178:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80017b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80017f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800182:	c9                   	leave  
  800183:	c3                   	ret    

00800184 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80018d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800194:	00 00 00 
	b.cnt = 0;
  800197:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80019e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a1:	ff 75 0c             	pushl  0xc(%ebp)
  8001a4:	ff 75 08             	pushl  0x8(%ebp)
  8001a7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ad:	50                   	push   %eax
  8001ae:	68 42 01 80 00       	push   $0x800142
  8001b3:	e8 54 01 00 00       	call   80030c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b8:	83 c4 08             	add    $0x8,%esp
  8001bb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001c1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c7:	50                   	push   %eax
  8001c8:	e8 d4 08 00 00       	call   800aa1 <sys_cputs>

	return b.cnt;
}
  8001cd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d3:	c9                   	leave  
  8001d4:	c3                   	ret    

008001d5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001db:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001de:	50                   	push   %eax
  8001df:	ff 75 08             	pushl  0x8(%ebp)
  8001e2:	e8 9d ff ff ff       	call   800184 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e7:	c9                   	leave  
  8001e8:	c3                   	ret    

008001e9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	57                   	push   %edi
  8001ed:	56                   	push   %esi
  8001ee:	53                   	push   %ebx
  8001ef:	83 ec 1c             	sub    $0x1c,%esp
  8001f2:	89 c7                	mov    %eax,%edi
  8001f4:	89 d6                	mov    %edx,%esi
  8001f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001ff:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800202:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800205:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80020d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800210:	39 d3                	cmp    %edx,%ebx
  800212:	72 05                	jb     800219 <printnum+0x30>
  800214:	39 45 10             	cmp    %eax,0x10(%ebp)
  800217:	77 45                	ja     80025e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800219:	83 ec 0c             	sub    $0xc,%esp
  80021c:	ff 75 18             	pushl  0x18(%ebp)
  80021f:	8b 45 14             	mov    0x14(%ebp),%eax
  800222:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800225:	53                   	push   %ebx
  800226:	ff 75 10             	pushl  0x10(%ebp)
  800229:	83 ec 08             	sub    $0x8,%esp
  80022c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022f:	ff 75 e0             	pushl  -0x20(%ebp)
  800232:	ff 75 dc             	pushl  -0x24(%ebp)
  800235:	ff 75 d8             	pushl  -0x28(%ebp)
  800238:	e8 93 19 00 00       	call   801bd0 <__udivdi3>
  80023d:	83 c4 18             	add    $0x18,%esp
  800240:	52                   	push   %edx
  800241:	50                   	push   %eax
  800242:	89 f2                	mov    %esi,%edx
  800244:	89 f8                	mov    %edi,%eax
  800246:	e8 9e ff ff ff       	call   8001e9 <printnum>
  80024b:	83 c4 20             	add    $0x20,%esp
  80024e:	eb 18                	jmp    800268 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800250:	83 ec 08             	sub    $0x8,%esp
  800253:	56                   	push   %esi
  800254:	ff 75 18             	pushl  0x18(%ebp)
  800257:	ff d7                	call   *%edi
  800259:	83 c4 10             	add    $0x10,%esp
  80025c:	eb 03                	jmp    800261 <printnum+0x78>
  80025e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800261:	83 eb 01             	sub    $0x1,%ebx
  800264:	85 db                	test   %ebx,%ebx
  800266:	7f e8                	jg     800250 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800268:	83 ec 08             	sub    $0x8,%esp
  80026b:	56                   	push   %esi
  80026c:	83 ec 04             	sub    $0x4,%esp
  80026f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800272:	ff 75 e0             	pushl  -0x20(%ebp)
  800275:	ff 75 dc             	pushl  -0x24(%ebp)
  800278:	ff 75 d8             	pushl  -0x28(%ebp)
  80027b:	e8 80 1a 00 00       	call   801d00 <__umoddi3>
  800280:	83 c4 14             	add    $0x14,%esp
  800283:	0f be 80 d5 1e 80 00 	movsbl 0x801ed5(%eax),%eax
  80028a:	50                   	push   %eax
  80028b:	ff d7                	call   *%edi
}
  80028d:	83 c4 10             	add    $0x10,%esp
  800290:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800293:	5b                   	pop    %ebx
  800294:	5e                   	pop    %esi
  800295:	5f                   	pop    %edi
  800296:	5d                   	pop    %ebp
  800297:	c3                   	ret    

00800298 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80029b:	83 fa 01             	cmp    $0x1,%edx
  80029e:	7e 0e                	jle    8002ae <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002a0:	8b 10                	mov    (%eax),%edx
  8002a2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a5:	89 08                	mov    %ecx,(%eax)
  8002a7:	8b 02                	mov    (%edx),%eax
  8002a9:	8b 52 04             	mov    0x4(%edx),%edx
  8002ac:	eb 22                	jmp    8002d0 <getuint+0x38>
	else if (lflag)
  8002ae:	85 d2                	test   %edx,%edx
  8002b0:	74 10                	je     8002c2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b2:	8b 10                	mov    (%eax),%edx
  8002b4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b7:	89 08                	mov    %ecx,(%eax)
  8002b9:	8b 02                	mov    (%edx),%eax
  8002bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c0:	eb 0e                	jmp    8002d0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c2:	8b 10                	mov    (%eax),%edx
  8002c4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c7:	89 08                	mov    %ecx,(%eax)
  8002c9:	8b 02                	mov    (%edx),%eax
  8002cb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002d0:	5d                   	pop    %ebp
  8002d1:	c3                   	ret    

008002d2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002dc:	8b 10                	mov    (%eax),%edx
  8002de:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e1:	73 0a                	jae    8002ed <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e6:	89 08                	mov    %ecx,(%eax)
  8002e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002eb:	88 02                	mov    %al,(%edx)
}
  8002ed:	5d                   	pop    %ebp
  8002ee:	c3                   	ret    

008002ef <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f8:	50                   	push   %eax
  8002f9:	ff 75 10             	pushl  0x10(%ebp)
  8002fc:	ff 75 0c             	pushl  0xc(%ebp)
  8002ff:	ff 75 08             	pushl  0x8(%ebp)
  800302:	e8 05 00 00 00       	call   80030c <vprintfmt>
	va_end(ap);
}
  800307:	83 c4 10             	add    $0x10,%esp
  80030a:	c9                   	leave  
  80030b:	c3                   	ret    

0080030c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	57                   	push   %edi
  800310:	56                   	push   %esi
  800311:	53                   	push   %ebx
  800312:	83 ec 2c             	sub    $0x2c,%esp
  800315:	8b 75 08             	mov    0x8(%ebp),%esi
  800318:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80031b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80031e:	eb 12                	jmp    800332 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800320:	85 c0                	test   %eax,%eax
  800322:	0f 84 89 03 00 00    	je     8006b1 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800328:	83 ec 08             	sub    $0x8,%esp
  80032b:	53                   	push   %ebx
  80032c:	50                   	push   %eax
  80032d:	ff d6                	call   *%esi
  80032f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800332:	83 c7 01             	add    $0x1,%edi
  800335:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800339:	83 f8 25             	cmp    $0x25,%eax
  80033c:	75 e2                	jne    800320 <vprintfmt+0x14>
  80033e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800342:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800349:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800350:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800357:	ba 00 00 00 00       	mov    $0x0,%edx
  80035c:	eb 07                	jmp    800365 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800361:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800365:	8d 47 01             	lea    0x1(%edi),%eax
  800368:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036b:	0f b6 07             	movzbl (%edi),%eax
  80036e:	0f b6 c8             	movzbl %al,%ecx
  800371:	83 e8 23             	sub    $0x23,%eax
  800374:	3c 55                	cmp    $0x55,%al
  800376:	0f 87 1a 03 00 00    	ja     800696 <vprintfmt+0x38a>
  80037c:	0f b6 c0             	movzbl %al,%eax
  80037f:	ff 24 85 20 20 80 00 	jmp    *0x802020(,%eax,4)
  800386:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800389:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80038d:	eb d6                	jmp    800365 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800392:	b8 00 00 00 00       	mov    $0x0,%eax
  800397:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80039a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80039d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003a1:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003a4:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003a7:	83 fa 09             	cmp    $0x9,%edx
  8003aa:	77 39                	ja     8003e5 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ac:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003af:	eb e9                	jmp    80039a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b4:	8d 48 04             	lea    0x4(%eax),%ecx
  8003b7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003ba:	8b 00                	mov    (%eax),%eax
  8003bc:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003c2:	eb 27                	jmp    8003eb <vprintfmt+0xdf>
  8003c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c7:	85 c0                	test   %eax,%eax
  8003c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ce:	0f 49 c8             	cmovns %eax,%ecx
  8003d1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d7:	eb 8c                	jmp    800365 <vprintfmt+0x59>
  8003d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003dc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003e3:	eb 80                	jmp    800365 <vprintfmt+0x59>
  8003e5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003e8:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003eb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ef:	0f 89 70 ff ff ff    	jns    800365 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003f5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003fb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800402:	e9 5e ff ff ff       	jmp    800365 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800407:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80040d:	e9 53 ff ff ff       	jmp    800365 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800412:	8b 45 14             	mov    0x14(%ebp),%eax
  800415:	8d 50 04             	lea    0x4(%eax),%edx
  800418:	89 55 14             	mov    %edx,0x14(%ebp)
  80041b:	83 ec 08             	sub    $0x8,%esp
  80041e:	53                   	push   %ebx
  80041f:	ff 30                	pushl  (%eax)
  800421:	ff d6                	call   *%esi
			break;
  800423:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800429:	e9 04 ff ff ff       	jmp    800332 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8d 50 04             	lea    0x4(%eax),%edx
  800434:	89 55 14             	mov    %edx,0x14(%ebp)
  800437:	8b 00                	mov    (%eax),%eax
  800439:	99                   	cltd   
  80043a:	31 d0                	xor    %edx,%eax
  80043c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80043e:	83 f8 0f             	cmp    $0xf,%eax
  800441:	7f 0b                	jg     80044e <vprintfmt+0x142>
  800443:	8b 14 85 80 21 80 00 	mov    0x802180(,%eax,4),%edx
  80044a:	85 d2                	test   %edx,%edx
  80044c:	75 18                	jne    800466 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80044e:	50                   	push   %eax
  80044f:	68 ed 1e 80 00       	push   $0x801eed
  800454:	53                   	push   %ebx
  800455:	56                   	push   %esi
  800456:	e8 94 fe ff ff       	call   8002ef <printfmt>
  80045b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800461:	e9 cc fe ff ff       	jmp    800332 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800466:	52                   	push   %edx
  800467:	68 b1 22 80 00       	push   $0x8022b1
  80046c:	53                   	push   %ebx
  80046d:	56                   	push   %esi
  80046e:	e8 7c fe ff ff       	call   8002ef <printfmt>
  800473:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800476:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800479:	e9 b4 fe ff ff       	jmp    800332 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80047e:	8b 45 14             	mov    0x14(%ebp),%eax
  800481:	8d 50 04             	lea    0x4(%eax),%edx
  800484:	89 55 14             	mov    %edx,0x14(%ebp)
  800487:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800489:	85 ff                	test   %edi,%edi
  80048b:	b8 e6 1e 80 00       	mov    $0x801ee6,%eax
  800490:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800493:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800497:	0f 8e 94 00 00 00    	jle    800531 <vprintfmt+0x225>
  80049d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004a1:	0f 84 98 00 00 00    	je     80053f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	ff 75 d0             	pushl  -0x30(%ebp)
  8004ad:	57                   	push   %edi
  8004ae:	e8 86 02 00 00       	call   800739 <strnlen>
  8004b3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b6:	29 c1                	sub    %eax,%ecx
  8004b8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004bb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004be:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004c8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ca:	eb 0f                	jmp    8004db <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004cc:	83 ec 08             	sub    $0x8,%esp
  8004cf:	53                   	push   %ebx
  8004d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d5:	83 ef 01             	sub    $0x1,%edi
  8004d8:	83 c4 10             	add    $0x10,%esp
  8004db:	85 ff                	test   %edi,%edi
  8004dd:	7f ed                	jg     8004cc <vprintfmt+0x1c0>
  8004df:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004e2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004e5:	85 c9                	test   %ecx,%ecx
  8004e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ec:	0f 49 c1             	cmovns %ecx,%eax
  8004ef:	29 c1                	sub    %eax,%ecx
  8004f1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004fa:	89 cb                	mov    %ecx,%ebx
  8004fc:	eb 4d                	jmp    80054b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004fe:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800502:	74 1b                	je     80051f <vprintfmt+0x213>
  800504:	0f be c0             	movsbl %al,%eax
  800507:	83 e8 20             	sub    $0x20,%eax
  80050a:	83 f8 5e             	cmp    $0x5e,%eax
  80050d:	76 10                	jbe    80051f <vprintfmt+0x213>
					putch('?', putdat);
  80050f:	83 ec 08             	sub    $0x8,%esp
  800512:	ff 75 0c             	pushl  0xc(%ebp)
  800515:	6a 3f                	push   $0x3f
  800517:	ff 55 08             	call   *0x8(%ebp)
  80051a:	83 c4 10             	add    $0x10,%esp
  80051d:	eb 0d                	jmp    80052c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	ff 75 0c             	pushl  0xc(%ebp)
  800525:	52                   	push   %edx
  800526:	ff 55 08             	call   *0x8(%ebp)
  800529:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052c:	83 eb 01             	sub    $0x1,%ebx
  80052f:	eb 1a                	jmp    80054b <vprintfmt+0x23f>
  800531:	89 75 08             	mov    %esi,0x8(%ebp)
  800534:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800537:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80053d:	eb 0c                	jmp    80054b <vprintfmt+0x23f>
  80053f:	89 75 08             	mov    %esi,0x8(%ebp)
  800542:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800545:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800548:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80054b:	83 c7 01             	add    $0x1,%edi
  80054e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800552:	0f be d0             	movsbl %al,%edx
  800555:	85 d2                	test   %edx,%edx
  800557:	74 23                	je     80057c <vprintfmt+0x270>
  800559:	85 f6                	test   %esi,%esi
  80055b:	78 a1                	js     8004fe <vprintfmt+0x1f2>
  80055d:	83 ee 01             	sub    $0x1,%esi
  800560:	79 9c                	jns    8004fe <vprintfmt+0x1f2>
  800562:	89 df                	mov    %ebx,%edi
  800564:	8b 75 08             	mov    0x8(%ebp),%esi
  800567:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80056a:	eb 18                	jmp    800584 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80056c:	83 ec 08             	sub    $0x8,%esp
  80056f:	53                   	push   %ebx
  800570:	6a 20                	push   $0x20
  800572:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800574:	83 ef 01             	sub    $0x1,%edi
  800577:	83 c4 10             	add    $0x10,%esp
  80057a:	eb 08                	jmp    800584 <vprintfmt+0x278>
  80057c:	89 df                	mov    %ebx,%edi
  80057e:	8b 75 08             	mov    0x8(%ebp),%esi
  800581:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800584:	85 ff                	test   %edi,%edi
  800586:	7f e4                	jg     80056c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800588:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80058b:	e9 a2 fd ff ff       	jmp    800332 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800590:	83 fa 01             	cmp    $0x1,%edx
  800593:	7e 16                	jle    8005ab <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8d 50 08             	lea    0x8(%eax),%edx
  80059b:	89 55 14             	mov    %edx,0x14(%ebp)
  80059e:	8b 50 04             	mov    0x4(%eax),%edx
  8005a1:	8b 00                	mov    (%eax),%eax
  8005a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a9:	eb 32                	jmp    8005dd <vprintfmt+0x2d1>
	else if (lflag)
  8005ab:	85 d2                	test   %edx,%edx
  8005ad:	74 18                	je     8005c7 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005af:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b2:	8d 50 04             	lea    0x4(%eax),%edx
  8005b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b8:	8b 00                	mov    (%eax),%eax
  8005ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bd:	89 c1                	mov    %eax,%ecx
  8005bf:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c5:	eb 16                	jmp    8005dd <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8d 50 04             	lea    0x4(%eax),%edx
  8005cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d0:	8b 00                	mov    (%eax),%eax
  8005d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d5:	89 c1                	mov    %eax,%ecx
  8005d7:	c1 f9 1f             	sar    $0x1f,%ecx
  8005da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005dd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005e0:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005e8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ec:	79 74                	jns    800662 <vprintfmt+0x356>
				putch('-', putdat);
  8005ee:	83 ec 08             	sub    $0x8,%esp
  8005f1:	53                   	push   %ebx
  8005f2:	6a 2d                	push   $0x2d
  8005f4:	ff d6                	call   *%esi
				num = -(long long) num;
  8005f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005fc:	f7 d8                	neg    %eax
  8005fe:	83 d2 00             	adc    $0x0,%edx
  800601:	f7 da                	neg    %edx
  800603:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800606:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80060b:	eb 55                	jmp    800662 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80060d:	8d 45 14             	lea    0x14(%ebp),%eax
  800610:	e8 83 fc ff ff       	call   800298 <getuint>
			base = 10;
  800615:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80061a:	eb 46                	jmp    800662 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80061c:	8d 45 14             	lea    0x14(%ebp),%eax
  80061f:	e8 74 fc ff ff       	call   800298 <getuint>
			base = 8;
  800624:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800629:	eb 37                	jmp    800662 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	53                   	push   %ebx
  80062f:	6a 30                	push   $0x30
  800631:	ff d6                	call   *%esi
			putch('x', putdat);
  800633:	83 c4 08             	add    $0x8,%esp
  800636:	53                   	push   %ebx
  800637:	6a 78                	push   $0x78
  800639:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80063b:	8b 45 14             	mov    0x14(%ebp),%eax
  80063e:	8d 50 04             	lea    0x4(%eax),%edx
  800641:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800644:	8b 00                	mov    (%eax),%eax
  800646:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80064b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80064e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800653:	eb 0d                	jmp    800662 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800655:	8d 45 14             	lea    0x14(%ebp),%eax
  800658:	e8 3b fc ff ff       	call   800298 <getuint>
			base = 16;
  80065d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800662:	83 ec 0c             	sub    $0xc,%esp
  800665:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800669:	57                   	push   %edi
  80066a:	ff 75 e0             	pushl  -0x20(%ebp)
  80066d:	51                   	push   %ecx
  80066e:	52                   	push   %edx
  80066f:	50                   	push   %eax
  800670:	89 da                	mov    %ebx,%edx
  800672:	89 f0                	mov    %esi,%eax
  800674:	e8 70 fb ff ff       	call   8001e9 <printnum>
			break;
  800679:	83 c4 20             	add    $0x20,%esp
  80067c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80067f:	e9 ae fc ff ff       	jmp    800332 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800684:	83 ec 08             	sub    $0x8,%esp
  800687:	53                   	push   %ebx
  800688:	51                   	push   %ecx
  800689:	ff d6                	call   *%esi
			break;
  80068b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800691:	e9 9c fc ff ff       	jmp    800332 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800696:	83 ec 08             	sub    $0x8,%esp
  800699:	53                   	push   %ebx
  80069a:	6a 25                	push   $0x25
  80069c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80069e:	83 c4 10             	add    $0x10,%esp
  8006a1:	eb 03                	jmp    8006a6 <vprintfmt+0x39a>
  8006a3:	83 ef 01             	sub    $0x1,%edi
  8006a6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006aa:	75 f7                	jne    8006a3 <vprintfmt+0x397>
  8006ac:	e9 81 fc ff ff       	jmp    800332 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b4:	5b                   	pop    %ebx
  8006b5:	5e                   	pop    %esi
  8006b6:	5f                   	pop    %edi
  8006b7:	5d                   	pop    %ebp
  8006b8:	c3                   	ret    

008006b9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b9:	55                   	push   %ebp
  8006ba:	89 e5                	mov    %esp,%ebp
  8006bc:	83 ec 18             	sub    $0x18,%esp
  8006bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006cc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d6:	85 c0                	test   %eax,%eax
  8006d8:	74 26                	je     800700 <vsnprintf+0x47>
  8006da:	85 d2                	test   %edx,%edx
  8006dc:	7e 22                	jle    800700 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006de:	ff 75 14             	pushl  0x14(%ebp)
  8006e1:	ff 75 10             	pushl  0x10(%ebp)
  8006e4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e7:	50                   	push   %eax
  8006e8:	68 d2 02 80 00       	push   $0x8002d2
  8006ed:	e8 1a fc ff ff       	call   80030c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006fb:	83 c4 10             	add    $0x10,%esp
  8006fe:	eb 05                	jmp    800705 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800700:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800705:	c9                   	leave  
  800706:	c3                   	ret    

00800707 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800710:	50                   	push   %eax
  800711:	ff 75 10             	pushl  0x10(%ebp)
  800714:	ff 75 0c             	pushl  0xc(%ebp)
  800717:	ff 75 08             	pushl  0x8(%ebp)
  80071a:	e8 9a ff ff ff       	call   8006b9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80071f:	c9                   	leave  
  800720:	c3                   	ret    

00800721 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800721:	55                   	push   %ebp
  800722:	89 e5                	mov    %esp,%ebp
  800724:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800727:	b8 00 00 00 00       	mov    $0x0,%eax
  80072c:	eb 03                	jmp    800731 <strlen+0x10>
		n++;
  80072e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800731:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800735:	75 f7                	jne    80072e <strlen+0xd>
		n++;
	return n;
}
  800737:	5d                   	pop    %ebp
  800738:	c3                   	ret    

00800739 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800739:	55                   	push   %ebp
  80073a:	89 e5                	mov    %esp,%ebp
  80073c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80073f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800742:	ba 00 00 00 00       	mov    $0x0,%edx
  800747:	eb 03                	jmp    80074c <strnlen+0x13>
		n++;
  800749:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074c:	39 c2                	cmp    %eax,%edx
  80074e:	74 08                	je     800758 <strnlen+0x1f>
  800750:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800754:	75 f3                	jne    800749 <strnlen+0x10>
  800756:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800758:	5d                   	pop    %ebp
  800759:	c3                   	ret    

0080075a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	53                   	push   %ebx
  80075e:	8b 45 08             	mov    0x8(%ebp),%eax
  800761:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800764:	89 c2                	mov    %eax,%edx
  800766:	83 c2 01             	add    $0x1,%edx
  800769:	83 c1 01             	add    $0x1,%ecx
  80076c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800770:	88 5a ff             	mov    %bl,-0x1(%edx)
  800773:	84 db                	test   %bl,%bl
  800775:	75 ef                	jne    800766 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800777:	5b                   	pop    %ebx
  800778:	5d                   	pop    %ebp
  800779:	c3                   	ret    

0080077a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	53                   	push   %ebx
  80077e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800781:	53                   	push   %ebx
  800782:	e8 9a ff ff ff       	call   800721 <strlen>
  800787:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80078a:	ff 75 0c             	pushl  0xc(%ebp)
  80078d:	01 d8                	add    %ebx,%eax
  80078f:	50                   	push   %eax
  800790:	e8 c5 ff ff ff       	call   80075a <strcpy>
	return dst;
}
  800795:	89 d8                	mov    %ebx,%eax
  800797:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80079a:	c9                   	leave  
  80079b:	c3                   	ret    

0080079c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	56                   	push   %esi
  8007a0:	53                   	push   %ebx
  8007a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a7:	89 f3                	mov    %esi,%ebx
  8007a9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ac:	89 f2                	mov    %esi,%edx
  8007ae:	eb 0f                	jmp    8007bf <strncpy+0x23>
		*dst++ = *src;
  8007b0:	83 c2 01             	add    $0x1,%edx
  8007b3:	0f b6 01             	movzbl (%ecx),%eax
  8007b6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b9:	80 39 01             	cmpb   $0x1,(%ecx)
  8007bc:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007bf:	39 da                	cmp    %ebx,%edx
  8007c1:	75 ed                	jne    8007b0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007c3:	89 f0                	mov    %esi,%eax
  8007c5:	5b                   	pop    %ebx
  8007c6:	5e                   	pop    %esi
  8007c7:	5d                   	pop    %ebp
  8007c8:	c3                   	ret    

008007c9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	56                   	push   %esi
  8007cd:	53                   	push   %ebx
  8007ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d4:	8b 55 10             	mov    0x10(%ebp),%edx
  8007d7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d9:	85 d2                	test   %edx,%edx
  8007db:	74 21                	je     8007fe <strlcpy+0x35>
  8007dd:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007e1:	89 f2                	mov    %esi,%edx
  8007e3:	eb 09                	jmp    8007ee <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e5:	83 c2 01             	add    $0x1,%edx
  8007e8:	83 c1 01             	add    $0x1,%ecx
  8007eb:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ee:	39 c2                	cmp    %eax,%edx
  8007f0:	74 09                	je     8007fb <strlcpy+0x32>
  8007f2:	0f b6 19             	movzbl (%ecx),%ebx
  8007f5:	84 db                	test   %bl,%bl
  8007f7:	75 ec                	jne    8007e5 <strlcpy+0x1c>
  8007f9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007fb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007fe:	29 f0                	sub    %esi,%eax
}
  800800:	5b                   	pop    %ebx
  800801:	5e                   	pop    %esi
  800802:	5d                   	pop    %ebp
  800803:	c3                   	ret    

00800804 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800804:	55                   	push   %ebp
  800805:	89 e5                	mov    %esp,%ebp
  800807:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80080d:	eb 06                	jmp    800815 <strcmp+0x11>
		p++, q++;
  80080f:	83 c1 01             	add    $0x1,%ecx
  800812:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800815:	0f b6 01             	movzbl (%ecx),%eax
  800818:	84 c0                	test   %al,%al
  80081a:	74 04                	je     800820 <strcmp+0x1c>
  80081c:	3a 02                	cmp    (%edx),%al
  80081e:	74 ef                	je     80080f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800820:	0f b6 c0             	movzbl %al,%eax
  800823:	0f b6 12             	movzbl (%edx),%edx
  800826:	29 d0                	sub    %edx,%eax
}
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	53                   	push   %ebx
  80082e:	8b 45 08             	mov    0x8(%ebp),%eax
  800831:	8b 55 0c             	mov    0xc(%ebp),%edx
  800834:	89 c3                	mov    %eax,%ebx
  800836:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800839:	eb 06                	jmp    800841 <strncmp+0x17>
		n--, p++, q++;
  80083b:	83 c0 01             	add    $0x1,%eax
  80083e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800841:	39 d8                	cmp    %ebx,%eax
  800843:	74 15                	je     80085a <strncmp+0x30>
  800845:	0f b6 08             	movzbl (%eax),%ecx
  800848:	84 c9                	test   %cl,%cl
  80084a:	74 04                	je     800850 <strncmp+0x26>
  80084c:	3a 0a                	cmp    (%edx),%cl
  80084e:	74 eb                	je     80083b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800850:	0f b6 00             	movzbl (%eax),%eax
  800853:	0f b6 12             	movzbl (%edx),%edx
  800856:	29 d0                	sub    %edx,%eax
  800858:	eb 05                	jmp    80085f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80085a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80085f:	5b                   	pop    %ebx
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	8b 45 08             	mov    0x8(%ebp),%eax
  800868:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086c:	eb 07                	jmp    800875 <strchr+0x13>
		if (*s == c)
  80086e:	38 ca                	cmp    %cl,%dl
  800870:	74 0f                	je     800881 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800872:	83 c0 01             	add    $0x1,%eax
  800875:	0f b6 10             	movzbl (%eax),%edx
  800878:	84 d2                	test   %dl,%dl
  80087a:	75 f2                	jne    80086e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80087c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800881:	5d                   	pop    %ebp
  800882:	c3                   	ret    

00800883 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088d:	eb 03                	jmp    800892 <strfind+0xf>
  80088f:	83 c0 01             	add    $0x1,%eax
  800892:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800895:	38 ca                	cmp    %cl,%dl
  800897:	74 04                	je     80089d <strfind+0x1a>
  800899:	84 d2                	test   %dl,%dl
  80089b:	75 f2                	jne    80088f <strfind+0xc>
			break;
	return (char *) s;
}
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	57                   	push   %edi
  8008a3:	56                   	push   %esi
  8008a4:	53                   	push   %ebx
  8008a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ab:	85 c9                	test   %ecx,%ecx
  8008ad:	74 36                	je     8008e5 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008af:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b5:	75 28                	jne    8008df <memset+0x40>
  8008b7:	f6 c1 03             	test   $0x3,%cl
  8008ba:	75 23                	jne    8008df <memset+0x40>
		c &= 0xFF;
  8008bc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008c0:	89 d3                	mov    %edx,%ebx
  8008c2:	c1 e3 08             	shl    $0x8,%ebx
  8008c5:	89 d6                	mov    %edx,%esi
  8008c7:	c1 e6 18             	shl    $0x18,%esi
  8008ca:	89 d0                	mov    %edx,%eax
  8008cc:	c1 e0 10             	shl    $0x10,%eax
  8008cf:	09 f0                	or     %esi,%eax
  8008d1:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008d3:	89 d8                	mov    %ebx,%eax
  8008d5:	09 d0                	or     %edx,%eax
  8008d7:	c1 e9 02             	shr    $0x2,%ecx
  8008da:	fc                   	cld    
  8008db:	f3 ab                	rep stos %eax,%es:(%edi)
  8008dd:	eb 06                	jmp    8008e5 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e2:	fc                   	cld    
  8008e3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008e5:	89 f8                	mov    %edi,%eax
  8008e7:	5b                   	pop    %ebx
  8008e8:	5e                   	pop    %esi
  8008e9:	5f                   	pop    %edi
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    

008008ec <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	57                   	push   %edi
  8008f0:	56                   	push   %esi
  8008f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008fa:	39 c6                	cmp    %eax,%esi
  8008fc:	73 35                	jae    800933 <memmove+0x47>
  8008fe:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800901:	39 d0                	cmp    %edx,%eax
  800903:	73 2e                	jae    800933 <memmove+0x47>
		s += n;
		d += n;
  800905:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800908:	89 d6                	mov    %edx,%esi
  80090a:	09 fe                	or     %edi,%esi
  80090c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800912:	75 13                	jne    800927 <memmove+0x3b>
  800914:	f6 c1 03             	test   $0x3,%cl
  800917:	75 0e                	jne    800927 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800919:	83 ef 04             	sub    $0x4,%edi
  80091c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80091f:	c1 e9 02             	shr    $0x2,%ecx
  800922:	fd                   	std    
  800923:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800925:	eb 09                	jmp    800930 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800927:	83 ef 01             	sub    $0x1,%edi
  80092a:	8d 72 ff             	lea    -0x1(%edx),%esi
  80092d:	fd                   	std    
  80092e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800930:	fc                   	cld    
  800931:	eb 1d                	jmp    800950 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800933:	89 f2                	mov    %esi,%edx
  800935:	09 c2                	or     %eax,%edx
  800937:	f6 c2 03             	test   $0x3,%dl
  80093a:	75 0f                	jne    80094b <memmove+0x5f>
  80093c:	f6 c1 03             	test   $0x3,%cl
  80093f:	75 0a                	jne    80094b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800941:	c1 e9 02             	shr    $0x2,%ecx
  800944:	89 c7                	mov    %eax,%edi
  800946:	fc                   	cld    
  800947:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800949:	eb 05                	jmp    800950 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80094b:	89 c7                	mov    %eax,%edi
  80094d:	fc                   	cld    
  80094e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800950:	5e                   	pop    %esi
  800951:	5f                   	pop    %edi
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800957:	ff 75 10             	pushl  0x10(%ebp)
  80095a:	ff 75 0c             	pushl  0xc(%ebp)
  80095d:	ff 75 08             	pushl  0x8(%ebp)
  800960:	e8 87 ff ff ff       	call   8008ec <memmove>
}
  800965:	c9                   	leave  
  800966:	c3                   	ret    

00800967 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	56                   	push   %esi
  80096b:	53                   	push   %ebx
  80096c:	8b 45 08             	mov    0x8(%ebp),%eax
  80096f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800972:	89 c6                	mov    %eax,%esi
  800974:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800977:	eb 1a                	jmp    800993 <memcmp+0x2c>
		if (*s1 != *s2)
  800979:	0f b6 08             	movzbl (%eax),%ecx
  80097c:	0f b6 1a             	movzbl (%edx),%ebx
  80097f:	38 d9                	cmp    %bl,%cl
  800981:	74 0a                	je     80098d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800983:	0f b6 c1             	movzbl %cl,%eax
  800986:	0f b6 db             	movzbl %bl,%ebx
  800989:	29 d8                	sub    %ebx,%eax
  80098b:	eb 0f                	jmp    80099c <memcmp+0x35>
		s1++, s2++;
  80098d:	83 c0 01             	add    $0x1,%eax
  800990:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800993:	39 f0                	cmp    %esi,%eax
  800995:	75 e2                	jne    800979 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800997:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099c:	5b                   	pop    %ebx
  80099d:	5e                   	pop    %esi
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	53                   	push   %ebx
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009a7:	89 c1                	mov    %eax,%ecx
  8009a9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ac:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b0:	eb 0a                	jmp    8009bc <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b2:	0f b6 10             	movzbl (%eax),%edx
  8009b5:	39 da                	cmp    %ebx,%edx
  8009b7:	74 07                	je     8009c0 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b9:	83 c0 01             	add    $0x1,%eax
  8009bc:	39 c8                	cmp    %ecx,%eax
  8009be:	72 f2                	jb     8009b2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009c0:	5b                   	pop    %ebx
  8009c1:	5d                   	pop    %ebp
  8009c2:	c3                   	ret    

008009c3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	57                   	push   %edi
  8009c7:	56                   	push   %esi
  8009c8:	53                   	push   %ebx
  8009c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009cf:	eb 03                	jmp    8009d4 <strtol+0x11>
		s++;
  8009d1:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d4:	0f b6 01             	movzbl (%ecx),%eax
  8009d7:	3c 20                	cmp    $0x20,%al
  8009d9:	74 f6                	je     8009d1 <strtol+0xe>
  8009db:	3c 09                	cmp    $0x9,%al
  8009dd:	74 f2                	je     8009d1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009df:	3c 2b                	cmp    $0x2b,%al
  8009e1:	75 0a                	jne    8009ed <strtol+0x2a>
		s++;
  8009e3:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e6:	bf 00 00 00 00       	mov    $0x0,%edi
  8009eb:	eb 11                	jmp    8009fe <strtol+0x3b>
  8009ed:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009f2:	3c 2d                	cmp    $0x2d,%al
  8009f4:	75 08                	jne    8009fe <strtol+0x3b>
		s++, neg = 1;
  8009f6:	83 c1 01             	add    $0x1,%ecx
  8009f9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009fe:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a04:	75 15                	jne    800a1b <strtol+0x58>
  800a06:	80 39 30             	cmpb   $0x30,(%ecx)
  800a09:	75 10                	jne    800a1b <strtol+0x58>
  800a0b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a0f:	75 7c                	jne    800a8d <strtol+0xca>
		s += 2, base = 16;
  800a11:	83 c1 02             	add    $0x2,%ecx
  800a14:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a19:	eb 16                	jmp    800a31 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a1b:	85 db                	test   %ebx,%ebx
  800a1d:	75 12                	jne    800a31 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a1f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a24:	80 39 30             	cmpb   $0x30,(%ecx)
  800a27:	75 08                	jne    800a31 <strtol+0x6e>
		s++, base = 8;
  800a29:	83 c1 01             	add    $0x1,%ecx
  800a2c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a31:	b8 00 00 00 00       	mov    $0x0,%eax
  800a36:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a39:	0f b6 11             	movzbl (%ecx),%edx
  800a3c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a3f:	89 f3                	mov    %esi,%ebx
  800a41:	80 fb 09             	cmp    $0x9,%bl
  800a44:	77 08                	ja     800a4e <strtol+0x8b>
			dig = *s - '0';
  800a46:	0f be d2             	movsbl %dl,%edx
  800a49:	83 ea 30             	sub    $0x30,%edx
  800a4c:	eb 22                	jmp    800a70 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a4e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a51:	89 f3                	mov    %esi,%ebx
  800a53:	80 fb 19             	cmp    $0x19,%bl
  800a56:	77 08                	ja     800a60 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a58:	0f be d2             	movsbl %dl,%edx
  800a5b:	83 ea 57             	sub    $0x57,%edx
  800a5e:	eb 10                	jmp    800a70 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a60:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a63:	89 f3                	mov    %esi,%ebx
  800a65:	80 fb 19             	cmp    $0x19,%bl
  800a68:	77 16                	ja     800a80 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a6a:	0f be d2             	movsbl %dl,%edx
  800a6d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a70:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a73:	7d 0b                	jge    800a80 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a75:	83 c1 01             	add    $0x1,%ecx
  800a78:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a7c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a7e:	eb b9                	jmp    800a39 <strtol+0x76>

	if (endptr)
  800a80:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a84:	74 0d                	je     800a93 <strtol+0xd0>
		*endptr = (char *) s;
  800a86:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a89:	89 0e                	mov    %ecx,(%esi)
  800a8b:	eb 06                	jmp    800a93 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a8d:	85 db                	test   %ebx,%ebx
  800a8f:	74 98                	je     800a29 <strtol+0x66>
  800a91:	eb 9e                	jmp    800a31 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a93:	89 c2                	mov    %eax,%edx
  800a95:	f7 da                	neg    %edx
  800a97:	85 ff                	test   %edi,%edi
  800a99:	0f 45 c2             	cmovne %edx,%eax
}
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5f                   	pop    %edi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	57                   	push   %edi
  800aa5:	56                   	push   %esi
  800aa6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa7:	b8 00 00 00 00       	mov    $0x0,%eax
  800aac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aaf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab2:	89 c3                	mov    %eax,%ebx
  800ab4:	89 c7                	mov    %eax,%edi
  800ab6:	89 c6                	mov    %eax,%esi
  800ab8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aba:	5b                   	pop    %ebx
  800abb:	5e                   	pop    %esi
  800abc:	5f                   	pop    %edi
  800abd:	5d                   	pop    %ebp
  800abe:	c3                   	ret    

00800abf <sys_cgetc>:

int
sys_cgetc(void)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	57                   	push   %edi
  800ac3:	56                   	push   %esi
  800ac4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aca:	b8 01 00 00 00       	mov    $0x1,%eax
  800acf:	89 d1                	mov    %edx,%ecx
  800ad1:	89 d3                	mov    %edx,%ebx
  800ad3:	89 d7                	mov    %edx,%edi
  800ad5:	89 d6                	mov    %edx,%esi
  800ad7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ad9:	5b                   	pop    %ebx
  800ada:	5e                   	pop    %esi
  800adb:	5f                   	pop    %edi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	57                   	push   %edi
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
  800ae4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aec:	b8 03 00 00 00       	mov    $0x3,%eax
  800af1:	8b 55 08             	mov    0x8(%ebp),%edx
  800af4:	89 cb                	mov    %ecx,%ebx
  800af6:	89 cf                	mov    %ecx,%edi
  800af8:	89 ce                	mov    %ecx,%esi
  800afa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800afc:	85 c0                	test   %eax,%eax
  800afe:	7e 17                	jle    800b17 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b00:	83 ec 0c             	sub    $0xc,%esp
  800b03:	50                   	push   %eax
  800b04:	6a 03                	push   $0x3
  800b06:	68 df 21 80 00       	push   $0x8021df
  800b0b:	6a 23                	push   $0x23
  800b0d:	68 fc 21 80 00       	push   $0x8021fc
  800b12:	e8 21 0f 00 00       	call   801a38 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b1a:	5b                   	pop    %ebx
  800b1b:	5e                   	pop    %esi
  800b1c:	5f                   	pop    %edi
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	57                   	push   %edi
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b25:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b2f:	89 d1                	mov    %edx,%ecx
  800b31:	89 d3                	mov    %edx,%ebx
  800b33:	89 d7                	mov    %edx,%edi
  800b35:	89 d6                	mov    %edx,%esi
  800b37:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <sys_yield>:

void
sys_yield(void)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	57                   	push   %edi
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b44:	ba 00 00 00 00       	mov    $0x0,%edx
  800b49:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b4e:	89 d1                	mov    %edx,%ecx
  800b50:	89 d3                	mov    %edx,%ebx
  800b52:	89 d7                	mov    %edx,%edi
  800b54:	89 d6                	mov    %edx,%esi
  800b56:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	57                   	push   %edi
  800b61:	56                   	push   %esi
  800b62:	53                   	push   %ebx
  800b63:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b66:	be 00 00 00 00       	mov    $0x0,%esi
  800b6b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b73:	8b 55 08             	mov    0x8(%ebp),%edx
  800b76:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b79:	89 f7                	mov    %esi,%edi
  800b7b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b7d:	85 c0                	test   %eax,%eax
  800b7f:	7e 17                	jle    800b98 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b81:	83 ec 0c             	sub    $0xc,%esp
  800b84:	50                   	push   %eax
  800b85:	6a 04                	push   $0x4
  800b87:	68 df 21 80 00       	push   $0x8021df
  800b8c:	6a 23                	push   $0x23
  800b8e:	68 fc 21 80 00       	push   $0x8021fc
  800b93:	e8 a0 0e 00 00       	call   801a38 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9b:	5b                   	pop    %ebx
  800b9c:	5e                   	pop    %esi
  800b9d:	5f                   	pop    %edi
  800b9e:	5d                   	pop    %ebp
  800b9f:	c3                   	ret    

00800ba0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	57                   	push   %edi
  800ba4:	56                   	push   %esi
  800ba5:	53                   	push   %ebx
  800ba6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba9:	b8 05 00 00 00       	mov    $0x5,%eax
  800bae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bba:	8b 75 18             	mov    0x18(%ebp),%esi
  800bbd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bbf:	85 c0                	test   %eax,%eax
  800bc1:	7e 17                	jle    800bda <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc3:	83 ec 0c             	sub    $0xc,%esp
  800bc6:	50                   	push   %eax
  800bc7:	6a 05                	push   $0x5
  800bc9:	68 df 21 80 00       	push   $0x8021df
  800bce:	6a 23                	push   $0x23
  800bd0:	68 fc 21 80 00       	push   $0x8021fc
  800bd5:	e8 5e 0e 00 00       	call   801a38 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
  800be8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800beb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf0:	b8 06 00 00 00       	mov    $0x6,%eax
  800bf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfb:	89 df                	mov    %ebx,%edi
  800bfd:	89 de                	mov    %ebx,%esi
  800bff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c01:	85 c0                	test   %eax,%eax
  800c03:	7e 17                	jle    800c1c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c05:	83 ec 0c             	sub    $0xc,%esp
  800c08:	50                   	push   %eax
  800c09:	6a 06                	push   $0x6
  800c0b:	68 df 21 80 00       	push   $0x8021df
  800c10:	6a 23                	push   $0x23
  800c12:	68 fc 21 80 00       	push   $0x8021fc
  800c17:	e8 1c 0e 00 00       	call   801a38 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1f:	5b                   	pop    %ebx
  800c20:	5e                   	pop    %esi
  800c21:	5f                   	pop    %edi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	57                   	push   %edi
  800c28:	56                   	push   %esi
  800c29:	53                   	push   %ebx
  800c2a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c32:	b8 08 00 00 00       	mov    $0x8,%eax
  800c37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3d:	89 df                	mov    %ebx,%edi
  800c3f:	89 de                	mov    %ebx,%esi
  800c41:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c43:	85 c0                	test   %eax,%eax
  800c45:	7e 17                	jle    800c5e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c47:	83 ec 0c             	sub    $0xc,%esp
  800c4a:	50                   	push   %eax
  800c4b:	6a 08                	push   $0x8
  800c4d:	68 df 21 80 00       	push   $0x8021df
  800c52:	6a 23                	push   $0x23
  800c54:	68 fc 21 80 00       	push   $0x8021fc
  800c59:	e8 da 0d 00 00       	call   801a38 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c61:	5b                   	pop    %ebx
  800c62:	5e                   	pop    %esi
  800c63:	5f                   	pop    %edi
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    

00800c66 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	57                   	push   %edi
  800c6a:	56                   	push   %esi
  800c6b:	53                   	push   %ebx
  800c6c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c74:	b8 09 00 00 00       	mov    $0x9,%eax
  800c79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7f:	89 df                	mov    %ebx,%edi
  800c81:	89 de                	mov    %ebx,%esi
  800c83:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c85:	85 c0                	test   %eax,%eax
  800c87:	7e 17                	jle    800ca0 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c89:	83 ec 0c             	sub    $0xc,%esp
  800c8c:	50                   	push   %eax
  800c8d:	6a 09                	push   $0x9
  800c8f:	68 df 21 80 00       	push   $0x8021df
  800c94:	6a 23                	push   $0x23
  800c96:	68 fc 21 80 00       	push   $0x8021fc
  800c9b:	e8 98 0d 00 00       	call   801a38 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ca0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca3:	5b                   	pop    %ebx
  800ca4:	5e                   	pop    %esi
  800ca5:	5f                   	pop    %edi
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    

00800ca8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	57                   	push   %edi
  800cac:	56                   	push   %esi
  800cad:	53                   	push   %ebx
  800cae:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc1:	89 df                	mov    %ebx,%edi
  800cc3:	89 de                	mov    %ebx,%esi
  800cc5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc7:	85 c0                	test   %eax,%eax
  800cc9:	7e 17                	jle    800ce2 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccb:	83 ec 0c             	sub    $0xc,%esp
  800cce:	50                   	push   %eax
  800ccf:	6a 0a                	push   $0xa
  800cd1:	68 df 21 80 00       	push   $0x8021df
  800cd6:	6a 23                	push   $0x23
  800cd8:	68 fc 21 80 00       	push   $0x8021fc
  800cdd:	e8 56 0d 00 00       	call   801a38 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ce2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf0:	be 00 00 00 00       	mov    $0x0,%esi
  800cf5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800d00:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d03:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d06:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
  800d13:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d16:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d1b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d20:	8b 55 08             	mov    0x8(%ebp),%edx
  800d23:	89 cb                	mov    %ecx,%ebx
  800d25:	89 cf                	mov    %ecx,%edi
  800d27:	89 ce                	mov    %ecx,%esi
  800d29:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d2b:	85 c0                	test   %eax,%eax
  800d2d:	7e 17                	jle    800d46 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2f:	83 ec 0c             	sub    $0xc,%esp
  800d32:	50                   	push   %eax
  800d33:	6a 0d                	push   $0xd
  800d35:	68 df 21 80 00       	push   $0x8021df
  800d3a:	6a 23                	push   $0x23
  800d3c:	68 fc 21 80 00       	push   $0x8021fc
  800d41:	e8 f2 0c 00 00       	call   801a38 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d49:	5b                   	pop    %ebx
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    

00800d4e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d51:	8b 45 08             	mov    0x8(%ebp),%eax
  800d54:	05 00 00 00 30       	add    $0x30000000,%eax
  800d59:	c1 e8 0c             	shr    $0xc,%eax
}
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d61:	8b 45 08             	mov    0x8(%ebp),%eax
  800d64:	05 00 00 00 30       	add    $0x30000000,%eax
  800d69:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d6e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    

00800d75 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d7b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d80:	89 c2                	mov    %eax,%edx
  800d82:	c1 ea 16             	shr    $0x16,%edx
  800d85:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d8c:	f6 c2 01             	test   $0x1,%dl
  800d8f:	74 11                	je     800da2 <fd_alloc+0x2d>
  800d91:	89 c2                	mov    %eax,%edx
  800d93:	c1 ea 0c             	shr    $0xc,%edx
  800d96:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d9d:	f6 c2 01             	test   $0x1,%dl
  800da0:	75 09                	jne    800dab <fd_alloc+0x36>
			*fd_store = fd;
  800da2:	89 01                	mov    %eax,(%ecx)
			return 0;
  800da4:	b8 00 00 00 00       	mov    $0x0,%eax
  800da9:	eb 17                	jmp    800dc2 <fd_alloc+0x4d>
  800dab:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800db0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800db5:	75 c9                	jne    800d80 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800db7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800dbd:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dca:	83 f8 1f             	cmp    $0x1f,%eax
  800dcd:	77 36                	ja     800e05 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dcf:	c1 e0 0c             	shl    $0xc,%eax
  800dd2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dd7:	89 c2                	mov    %eax,%edx
  800dd9:	c1 ea 16             	shr    $0x16,%edx
  800ddc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800de3:	f6 c2 01             	test   $0x1,%dl
  800de6:	74 24                	je     800e0c <fd_lookup+0x48>
  800de8:	89 c2                	mov    %eax,%edx
  800dea:	c1 ea 0c             	shr    $0xc,%edx
  800ded:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800df4:	f6 c2 01             	test   $0x1,%dl
  800df7:	74 1a                	je     800e13 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800df9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dfc:	89 02                	mov    %eax,(%edx)
	return 0;
  800dfe:	b8 00 00 00 00       	mov    $0x0,%eax
  800e03:	eb 13                	jmp    800e18 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e05:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e0a:	eb 0c                	jmp    800e18 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e0c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e11:	eb 05                	jmp    800e18 <fd_lookup+0x54>
  800e13:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    

00800e1a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e1a:	55                   	push   %ebp
  800e1b:	89 e5                	mov    %esp,%ebp
  800e1d:	83 ec 08             	sub    $0x8,%esp
  800e20:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e23:	ba 88 22 80 00       	mov    $0x802288,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e28:	eb 13                	jmp    800e3d <dev_lookup+0x23>
  800e2a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e2d:	39 08                	cmp    %ecx,(%eax)
  800e2f:	75 0c                	jne    800e3d <dev_lookup+0x23>
			*dev = devtab[i];
  800e31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e34:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e36:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3b:	eb 2e                	jmp    800e6b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e3d:	8b 02                	mov    (%edx),%eax
  800e3f:	85 c0                	test   %eax,%eax
  800e41:	75 e7                	jne    800e2a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e43:	a1 04 40 80 00       	mov    0x804004,%eax
  800e48:	8b 40 48             	mov    0x48(%eax),%eax
  800e4b:	83 ec 04             	sub    $0x4,%esp
  800e4e:	51                   	push   %ecx
  800e4f:	50                   	push   %eax
  800e50:	68 0c 22 80 00       	push   $0x80220c
  800e55:	e8 7b f3 ff ff       	call   8001d5 <cprintf>
	*dev = 0;
  800e5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e63:	83 c4 10             	add    $0x10,%esp
  800e66:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e6b:	c9                   	leave  
  800e6c:	c3                   	ret    

00800e6d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e6d:	55                   	push   %ebp
  800e6e:	89 e5                	mov    %esp,%ebp
  800e70:	56                   	push   %esi
  800e71:	53                   	push   %ebx
  800e72:	83 ec 10             	sub    $0x10,%esp
  800e75:	8b 75 08             	mov    0x8(%ebp),%esi
  800e78:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e7e:	50                   	push   %eax
  800e7f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e85:	c1 e8 0c             	shr    $0xc,%eax
  800e88:	50                   	push   %eax
  800e89:	e8 36 ff ff ff       	call   800dc4 <fd_lookup>
  800e8e:	83 c4 08             	add    $0x8,%esp
  800e91:	85 c0                	test   %eax,%eax
  800e93:	78 05                	js     800e9a <fd_close+0x2d>
	    || fd != fd2)
  800e95:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e98:	74 0c                	je     800ea6 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e9a:	84 db                	test   %bl,%bl
  800e9c:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea1:	0f 44 c2             	cmove  %edx,%eax
  800ea4:	eb 41                	jmp    800ee7 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ea6:	83 ec 08             	sub    $0x8,%esp
  800ea9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800eac:	50                   	push   %eax
  800ead:	ff 36                	pushl  (%esi)
  800eaf:	e8 66 ff ff ff       	call   800e1a <dev_lookup>
  800eb4:	89 c3                	mov    %eax,%ebx
  800eb6:	83 c4 10             	add    $0x10,%esp
  800eb9:	85 c0                	test   %eax,%eax
  800ebb:	78 1a                	js     800ed7 <fd_close+0x6a>
		if (dev->dev_close)
  800ebd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ec0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ec3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ec8:	85 c0                	test   %eax,%eax
  800eca:	74 0b                	je     800ed7 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ecc:	83 ec 0c             	sub    $0xc,%esp
  800ecf:	56                   	push   %esi
  800ed0:	ff d0                	call   *%eax
  800ed2:	89 c3                	mov    %eax,%ebx
  800ed4:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ed7:	83 ec 08             	sub    $0x8,%esp
  800eda:	56                   	push   %esi
  800edb:	6a 00                	push   $0x0
  800edd:	e8 00 fd ff ff       	call   800be2 <sys_page_unmap>
	return r;
  800ee2:	83 c4 10             	add    $0x10,%esp
  800ee5:	89 d8                	mov    %ebx,%eax
}
  800ee7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eea:	5b                   	pop    %ebx
  800eeb:	5e                   	pop    %esi
  800eec:	5d                   	pop    %ebp
  800eed:	c3                   	ret    

00800eee <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800eee:	55                   	push   %ebp
  800eef:	89 e5                	mov    %esp,%ebp
  800ef1:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ef4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ef7:	50                   	push   %eax
  800ef8:	ff 75 08             	pushl  0x8(%ebp)
  800efb:	e8 c4 fe ff ff       	call   800dc4 <fd_lookup>
  800f00:	83 c4 08             	add    $0x8,%esp
  800f03:	85 c0                	test   %eax,%eax
  800f05:	78 10                	js     800f17 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f07:	83 ec 08             	sub    $0x8,%esp
  800f0a:	6a 01                	push   $0x1
  800f0c:	ff 75 f4             	pushl  -0xc(%ebp)
  800f0f:	e8 59 ff ff ff       	call   800e6d <fd_close>
  800f14:	83 c4 10             	add    $0x10,%esp
}
  800f17:	c9                   	leave  
  800f18:	c3                   	ret    

00800f19 <close_all>:

void
close_all(void)
{
  800f19:	55                   	push   %ebp
  800f1a:	89 e5                	mov    %esp,%ebp
  800f1c:	53                   	push   %ebx
  800f1d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f20:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f25:	83 ec 0c             	sub    $0xc,%esp
  800f28:	53                   	push   %ebx
  800f29:	e8 c0 ff ff ff       	call   800eee <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f2e:	83 c3 01             	add    $0x1,%ebx
  800f31:	83 c4 10             	add    $0x10,%esp
  800f34:	83 fb 20             	cmp    $0x20,%ebx
  800f37:	75 ec                	jne    800f25 <close_all+0xc>
		close(i);
}
  800f39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f3c:	c9                   	leave  
  800f3d:	c3                   	ret    

00800f3e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f3e:	55                   	push   %ebp
  800f3f:	89 e5                	mov    %esp,%ebp
  800f41:	57                   	push   %edi
  800f42:	56                   	push   %esi
  800f43:	53                   	push   %ebx
  800f44:	83 ec 2c             	sub    $0x2c,%esp
  800f47:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f4a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f4d:	50                   	push   %eax
  800f4e:	ff 75 08             	pushl  0x8(%ebp)
  800f51:	e8 6e fe ff ff       	call   800dc4 <fd_lookup>
  800f56:	83 c4 08             	add    $0x8,%esp
  800f59:	85 c0                	test   %eax,%eax
  800f5b:	0f 88 c1 00 00 00    	js     801022 <dup+0xe4>
		return r;
	close(newfdnum);
  800f61:	83 ec 0c             	sub    $0xc,%esp
  800f64:	56                   	push   %esi
  800f65:	e8 84 ff ff ff       	call   800eee <close>

	newfd = INDEX2FD(newfdnum);
  800f6a:	89 f3                	mov    %esi,%ebx
  800f6c:	c1 e3 0c             	shl    $0xc,%ebx
  800f6f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f75:	83 c4 04             	add    $0x4,%esp
  800f78:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f7b:	e8 de fd ff ff       	call   800d5e <fd2data>
  800f80:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f82:	89 1c 24             	mov    %ebx,(%esp)
  800f85:	e8 d4 fd ff ff       	call   800d5e <fd2data>
  800f8a:	83 c4 10             	add    $0x10,%esp
  800f8d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f90:	89 f8                	mov    %edi,%eax
  800f92:	c1 e8 16             	shr    $0x16,%eax
  800f95:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f9c:	a8 01                	test   $0x1,%al
  800f9e:	74 37                	je     800fd7 <dup+0x99>
  800fa0:	89 f8                	mov    %edi,%eax
  800fa2:	c1 e8 0c             	shr    $0xc,%eax
  800fa5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fac:	f6 c2 01             	test   $0x1,%dl
  800faf:	74 26                	je     800fd7 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fb1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fb8:	83 ec 0c             	sub    $0xc,%esp
  800fbb:	25 07 0e 00 00       	and    $0xe07,%eax
  800fc0:	50                   	push   %eax
  800fc1:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fc4:	6a 00                	push   $0x0
  800fc6:	57                   	push   %edi
  800fc7:	6a 00                	push   $0x0
  800fc9:	e8 d2 fb ff ff       	call   800ba0 <sys_page_map>
  800fce:	89 c7                	mov    %eax,%edi
  800fd0:	83 c4 20             	add    $0x20,%esp
  800fd3:	85 c0                	test   %eax,%eax
  800fd5:	78 2e                	js     801005 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fd7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fda:	89 d0                	mov    %edx,%eax
  800fdc:	c1 e8 0c             	shr    $0xc,%eax
  800fdf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fe6:	83 ec 0c             	sub    $0xc,%esp
  800fe9:	25 07 0e 00 00       	and    $0xe07,%eax
  800fee:	50                   	push   %eax
  800fef:	53                   	push   %ebx
  800ff0:	6a 00                	push   $0x0
  800ff2:	52                   	push   %edx
  800ff3:	6a 00                	push   $0x0
  800ff5:	e8 a6 fb ff ff       	call   800ba0 <sys_page_map>
  800ffa:	89 c7                	mov    %eax,%edi
  800ffc:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fff:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801001:	85 ff                	test   %edi,%edi
  801003:	79 1d                	jns    801022 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801005:	83 ec 08             	sub    $0x8,%esp
  801008:	53                   	push   %ebx
  801009:	6a 00                	push   $0x0
  80100b:	e8 d2 fb ff ff       	call   800be2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801010:	83 c4 08             	add    $0x8,%esp
  801013:	ff 75 d4             	pushl  -0x2c(%ebp)
  801016:	6a 00                	push   $0x0
  801018:	e8 c5 fb ff ff       	call   800be2 <sys_page_unmap>
	return r;
  80101d:	83 c4 10             	add    $0x10,%esp
  801020:	89 f8                	mov    %edi,%eax
}
  801022:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801025:	5b                   	pop    %ebx
  801026:	5e                   	pop    %esi
  801027:	5f                   	pop    %edi
  801028:	5d                   	pop    %ebp
  801029:	c3                   	ret    

0080102a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80102a:	55                   	push   %ebp
  80102b:	89 e5                	mov    %esp,%ebp
  80102d:	53                   	push   %ebx
  80102e:	83 ec 14             	sub    $0x14,%esp
  801031:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801034:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801037:	50                   	push   %eax
  801038:	53                   	push   %ebx
  801039:	e8 86 fd ff ff       	call   800dc4 <fd_lookup>
  80103e:	83 c4 08             	add    $0x8,%esp
  801041:	89 c2                	mov    %eax,%edx
  801043:	85 c0                	test   %eax,%eax
  801045:	78 6d                	js     8010b4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801047:	83 ec 08             	sub    $0x8,%esp
  80104a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80104d:	50                   	push   %eax
  80104e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801051:	ff 30                	pushl  (%eax)
  801053:	e8 c2 fd ff ff       	call   800e1a <dev_lookup>
  801058:	83 c4 10             	add    $0x10,%esp
  80105b:	85 c0                	test   %eax,%eax
  80105d:	78 4c                	js     8010ab <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80105f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801062:	8b 42 08             	mov    0x8(%edx),%eax
  801065:	83 e0 03             	and    $0x3,%eax
  801068:	83 f8 01             	cmp    $0x1,%eax
  80106b:	75 21                	jne    80108e <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80106d:	a1 04 40 80 00       	mov    0x804004,%eax
  801072:	8b 40 48             	mov    0x48(%eax),%eax
  801075:	83 ec 04             	sub    $0x4,%esp
  801078:	53                   	push   %ebx
  801079:	50                   	push   %eax
  80107a:	68 4d 22 80 00       	push   $0x80224d
  80107f:	e8 51 f1 ff ff       	call   8001d5 <cprintf>
		return -E_INVAL;
  801084:	83 c4 10             	add    $0x10,%esp
  801087:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80108c:	eb 26                	jmp    8010b4 <read+0x8a>
	}
	if (!dev->dev_read)
  80108e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801091:	8b 40 08             	mov    0x8(%eax),%eax
  801094:	85 c0                	test   %eax,%eax
  801096:	74 17                	je     8010af <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801098:	83 ec 04             	sub    $0x4,%esp
  80109b:	ff 75 10             	pushl  0x10(%ebp)
  80109e:	ff 75 0c             	pushl  0xc(%ebp)
  8010a1:	52                   	push   %edx
  8010a2:	ff d0                	call   *%eax
  8010a4:	89 c2                	mov    %eax,%edx
  8010a6:	83 c4 10             	add    $0x10,%esp
  8010a9:	eb 09                	jmp    8010b4 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010ab:	89 c2                	mov    %eax,%edx
  8010ad:	eb 05                	jmp    8010b4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010af:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8010b4:	89 d0                	mov    %edx,%eax
  8010b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b9:	c9                   	leave  
  8010ba:	c3                   	ret    

008010bb <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010bb:	55                   	push   %ebp
  8010bc:	89 e5                	mov    %esp,%ebp
  8010be:	57                   	push   %edi
  8010bf:	56                   	push   %esi
  8010c0:	53                   	push   %ebx
  8010c1:	83 ec 0c             	sub    $0xc,%esp
  8010c4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010c7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010ca:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010cf:	eb 21                	jmp    8010f2 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010d1:	83 ec 04             	sub    $0x4,%esp
  8010d4:	89 f0                	mov    %esi,%eax
  8010d6:	29 d8                	sub    %ebx,%eax
  8010d8:	50                   	push   %eax
  8010d9:	89 d8                	mov    %ebx,%eax
  8010db:	03 45 0c             	add    0xc(%ebp),%eax
  8010de:	50                   	push   %eax
  8010df:	57                   	push   %edi
  8010e0:	e8 45 ff ff ff       	call   80102a <read>
		if (m < 0)
  8010e5:	83 c4 10             	add    $0x10,%esp
  8010e8:	85 c0                	test   %eax,%eax
  8010ea:	78 10                	js     8010fc <readn+0x41>
			return m;
		if (m == 0)
  8010ec:	85 c0                	test   %eax,%eax
  8010ee:	74 0a                	je     8010fa <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010f0:	01 c3                	add    %eax,%ebx
  8010f2:	39 f3                	cmp    %esi,%ebx
  8010f4:	72 db                	jb     8010d1 <readn+0x16>
  8010f6:	89 d8                	mov    %ebx,%eax
  8010f8:	eb 02                	jmp    8010fc <readn+0x41>
  8010fa:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ff:	5b                   	pop    %ebx
  801100:	5e                   	pop    %esi
  801101:	5f                   	pop    %edi
  801102:	5d                   	pop    %ebp
  801103:	c3                   	ret    

00801104 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
  801107:	53                   	push   %ebx
  801108:	83 ec 14             	sub    $0x14,%esp
  80110b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80110e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801111:	50                   	push   %eax
  801112:	53                   	push   %ebx
  801113:	e8 ac fc ff ff       	call   800dc4 <fd_lookup>
  801118:	83 c4 08             	add    $0x8,%esp
  80111b:	89 c2                	mov    %eax,%edx
  80111d:	85 c0                	test   %eax,%eax
  80111f:	78 68                	js     801189 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801121:	83 ec 08             	sub    $0x8,%esp
  801124:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801127:	50                   	push   %eax
  801128:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80112b:	ff 30                	pushl  (%eax)
  80112d:	e8 e8 fc ff ff       	call   800e1a <dev_lookup>
  801132:	83 c4 10             	add    $0x10,%esp
  801135:	85 c0                	test   %eax,%eax
  801137:	78 47                	js     801180 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801139:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80113c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801140:	75 21                	jne    801163 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801142:	a1 04 40 80 00       	mov    0x804004,%eax
  801147:	8b 40 48             	mov    0x48(%eax),%eax
  80114a:	83 ec 04             	sub    $0x4,%esp
  80114d:	53                   	push   %ebx
  80114e:	50                   	push   %eax
  80114f:	68 69 22 80 00       	push   $0x802269
  801154:	e8 7c f0 ff ff       	call   8001d5 <cprintf>
		return -E_INVAL;
  801159:	83 c4 10             	add    $0x10,%esp
  80115c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801161:	eb 26                	jmp    801189 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801163:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801166:	8b 52 0c             	mov    0xc(%edx),%edx
  801169:	85 d2                	test   %edx,%edx
  80116b:	74 17                	je     801184 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80116d:	83 ec 04             	sub    $0x4,%esp
  801170:	ff 75 10             	pushl  0x10(%ebp)
  801173:	ff 75 0c             	pushl  0xc(%ebp)
  801176:	50                   	push   %eax
  801177:	ff d2                	call   *%edx
  801179:	89 c2                	mov    %eax,%edx
  80117b:	83 c4 10             	add    $0x10,%esp
  80117e:	eb 09                	jmp    801189 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801180:	89 c2                	mov    %eax,%edx
  801182:	eb 05                	jmp    801189 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801184:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801189:	89 d0                	mov    %edx,%eax
  80118b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80118e:	c9                   	leave  
  80118f:	c3                   	ret    

00801190 <seek>:

int
seek(int fdnum, off_t offset)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801196:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801199:	50                   	push   %eax
  80119a:	ff 75 08             	pushl  0x8(%ebp)
  80119d:	e8 22 fc ff ff       	call   800dc4 <fd_lookup>
  8011a2:	83 c4 08             	add    $0x8,%esp
  8011a5:	85 c0                	test   %eax,%eax
  8011a7:	78 0e                	js     8011b7 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011af:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011b7:	c9                   	leave  
  8011b8:	c3                   	ret    

008011b9 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011b9:	55                   	push   %ebp
  8011ba:	89 e5                	mov    %esp,%ebp
  8011bc:	53                   	push   %ebx
  8011bd:	83 ec 14             	sub    $0x14,%esp
  8011c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c6:	50                   	push   %eax
  8011c7:	53                   	push   %ebx
  8011c8:	e8 f7 fb ff ff       	call   800dc4 <fd_lookup>
  8011cd:	83 c4 08             	add    $0x8,%esp
  8011d0:	89 c2                	mov    %eax,%edx
  8011d2:	85 c0                	test   %eax,%eax
  8011d4:	78 65                	js     80123b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d6:	83 ec 08             	sub    $0x8,%esp
  8011d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011dc:	50                   	push   %eax
  8011dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e0:	ff 30                	pushl  (%eax)
  8011e2:	e8 33 fc ff ff       	call   800e1a <dev_lookup>
  8011e7:	83 c4 10             	add    $0x10,%esp
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	78 44                	js     801232 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011f5:	75 21                	jne    801218 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011f7:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011fc:	8b 40 48             	mov    0x48(%eax),%eax
  8011ff:	83 ec 04             	sub    $0x4,%esp
  801202:	53                   	push   %ebx
  801203:	50                   	push   %eax
  801204:	68 2c 22 80 00       	push   $0x80222c
  801209:	e8 c7 ef ff ff       	call   8001d5 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80120e:	83 c4 10             	add    $0x10,%esp
  801211:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801216:	eb 23                	jmp    80123b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801218:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80121b:	8b 52 18             	mov    0x18(%edx),%edx
  80121e:	85 d2                	test   %edx,%edx
  801220:	74 14                	je     801236 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801222:	83 ec 08             	sub    $0x8,%esp
  801225:	ff 75 0c             	pushl  0xc(%ebp)
  801228:	50                   	push   %eax
  801229:	ff d2                	call   *%edx
  80122b:	89 c2                	mov    %eax,%edx
  80122d:	83 c4 10             	add    $0x10,%esp
  801230:	eb 09                	jmp    80123b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801232:	89 c2                	mov    %eax,%edx
  801234:	eb 05                	jmp    80123b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801236:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80123b:	89 d0                	mov    %edx,%eax
  80123d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801240:	c9                   	leave  
  801241:	c3                   	ret    

00801242 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801242:	55                   	push   %ebp
  801243:	89 e5                	mov    %esp,%ebp
  801245:	53                   	push   %ebx
  801246:	83 ec 14             	sub    $0x14,%esp
  801249:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80124c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124f:	50                   	push   %eax
  801250:	ff 75 08             	pushl  0x8(%ebp)
  801253:	e8 6c fb ff ff       	call   800dc4 <fd_lookup>
  801258:	83 c4 08             	add    $0x8,%esp
  80125b:	89 c2                	mov    %eax,%edx
  80125d:	85 c0                	test   %eax,%eax
  80125f:	78 58                	js     8012b9 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801261:	83 ec 08             	sub    $0x8,%esp
  801264:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801267:	50                   	push   %eax
  801268:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126b:	ff 30                	pushl  (%eax)
  80126d:	e8 a8 fb ff ff       	call   800e1a <dev_lookup>
  801272:	83 c4 10             	add    $0x10,%esp
  801275:	85 c0                	test   %eax,%eax
  801277:	78 37                	js     8012b0 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801279:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80127c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801280:	74 32                	je     8012b4 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801282:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801285:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80128c:	00 00 00 
	stat->st_isdir = 0;
  80128f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801296:	00 00 00 
	stat->st_dev = dev;
  801299:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80129f:	83 ec 08             	sub    $0x8,%esp
  8012a2:	53                   	push   %ebx
  8012a3:	ff 75 f0             	pushl  -0x10(%ebp)
  8012a6:	ff 50 14             	call   *0x14(%eax)
  8012a9:	89 c2                	mov    %eax,%edx
  8012ab:	83 c4 10             	add    $0x10,%esp
  8012ae:	eb 09                	jmp    8012b9 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b0:	89 c2                	mov    %eax,%edx
  8012b2:	eb 05                	jmp    8012b9 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012b4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012b9:	89 d0                	mov    %edx,%eax
  8012bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012be:	c9                   	leave  
  8012bf:	c3                   	ret    

008012c0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012c0:	55                   	push   %ebp
  8012c1:	89 e5                	mov    %esp,%ebp
  8012c3:	56                   	push   %esi
  8012c4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012c5:	83 ec 08             	sub    $0x8,%esp
  8012c8:	6a 00                	push   $0x0
  8012ca:	ff 75 08             	pushl  0x8(%ebp)
  8012cd:	e8 e3 01 00 00       	call   8014b5 <open>
  8012d2:	89 c3                	mov    %eax,%ebx
  8012d4:	83 c4 10             	add    $0x10,%esp
  8012d7:	85 c0                	test   %eax,%eax
  8012d9:	78 1b                	js     8012f6 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012db:	83 ec 08             	sub    $0x8,%esp
  8012de:	ff 75 0c             	pushl  0xc(%ebp)
  8012e1:	50                   	push   %eax
  8012e2:	e8 5b ff ff ff       	call   801242 <fstat>
  8012e7:	89 c6                	mov    %eax,%esi
	close(fd);
  8012e9:	89 1c 24             	mov    %ebx,(%esp)
  8012ec:	e8 fd fb ff ff       	call   800eee <close>
	return r;
  8012f1:	83 c4 10             	add    $0x10,%esp
  8012f4:	89 f0                	mov    %esi,%eax
}
  8012f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f9:	5b                   	pop    %ebx
  8012fa:	5e                   	pop    %esi
  8012fb:	5d                   	pop    %ebp
  8012fc:	c3                   	ret    

008012fd <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012fd:	55                   	push   %ebp
  8012fe:	89 e5                	mov    %esp,%ebp
  801300:	56                   	push   %esi
  801301:	53                   	push   %ebx
  801302:	89 c6                	mov    %eax,%esi
  801304:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801306:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80130d:	75 12                	jne    801321 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80130f:	83 ec 0c             	sub    $0xc,%esp
  801312:	6a 01                	push   $0x1
  801314:	e8 39 08 00 00       	call   801b52 <ipc_find_env>
  801319:	a3 00 40 80 00       	mov    %eax,0x804000
  80131e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801321:	6a 07                	push   $0x7
  801323:	68 00 50 80 00       	push   $0x805000
  801328:	56                   	push   %esi
  801329:	ff 35 00 40 80 00    	pushl  0x804000
  80132f:	e8 bc 07 00 00       	call   801af0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801334:	83 c4 0c             	add    $0xc,%esp
  801337:	6a 00                	push   $0x0
  801339:	53                   	push   %ebx
  80133a:	6a 00                	push   $0x0
  80133c:	e8 3d 07 00 00       	call   801a7e <ipc_recv>
}
  801341:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801344:	5b                   	pop    %ebx
  801345:	5e                   	pop    %esi
  801346:	5d                   	pop    %ebp
  801347:	c3                   	ret    

00801348 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801348:	55                   	push   %ebp
  801349:	89 e5                	mov    %esp,%ebp
  80134b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80134e:	8b 45 08             	mov    0x8(%ebp),%eax
  801351:	8b 40 0c             	mov    0xc(%eax),%eax
  801354:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801359:	8b 45 0c             	mov    0xc(%ebp),%eax
  80135c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801361:	ba 00 00 00 00       	mov    $0x0,%edx
  801366:	b8 02 00 00 00       	mov    $0x2,%eax
  80136b:	e8 8d ff ff ff       	call   8012fd <fsipc>
}
  801370:	c9                   	leave  
  801371:	c3                   	ret    

00801372 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801372:	55                   	push   %ebp
  801373:	89 e5                	mov    %esp,%ebp
  801375:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801378:	8b 45 08             	mov    0x8(%ebp),%eax
  80137b:	8b 40 0c             	mov    0xc(%eax),%eax
  80137e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801383:	ba 00 00 00 00       	mov    $0x0,%edx
  801388:	b8 06 00 00 00       	mov    $0x6,%eax
  80138d:	e8 6b ff ff ff       	call   8012fd <fsipc>
}
  801392:	c9                   	leave  
  801393:	c3                   	ret    

00801394 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801394:	55                   	push   %ebp
  801395:	89 e5                	mov    %esp,%ebp
  801397:	53                   	push   %ebx
  801398:	83 ec 04             	sub    $0x4,%esp
  80139b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80139e:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a1:	8b 40 0c             	mov    0xc(%eax),%eax
  8013a4:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ae:	b8 05 00 00 00       	mov    $0x5,%eax
  8013b3:	e8 45 ff ff ff       	call   8012fd <fsipc>
  8013b8:	85 c0                	test   %eax,%eax
  8013ba:	78 2c                	js     8013e8 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013bc:	83 ec 08             	sub    $0x8,%esp
  8013bf:	68 00 50 80 00       	push   $0x805000
  8013c4:	53                   	push   %ebx
  8013c5:	e8 90 f3 ff ff       	call   80075a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013ca:	a1 80 50 80 00       	mov    0x805080,%eax
  8013cf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013d5:	a1 84 50 80 00       	mov    0x805084,%eax
  8013da:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013e0:	83 c4 10             	add    $0x10,%esp
  8013e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013eb:	c9                   	leave  
  8013ec:	c3                   	ret    

008013ed <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013ed:	55                   	push   %ebp
  8013ee:	89 e5                	mov    %esp,%ebp
  8013f0:	83 ec 0c             	sub    $0xc,%esp
  8013f3:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8013f9:	8b 52 0c             	mov    0xc(%edx),%edx
  8013fc:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801402:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801407:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80140c:	0f 47 c2             	cmova  %edx,%eax
  80140f:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801414:	50                   	push   %eax
  801415:	ff 75 0c             	pushl  0xc(%ebp)
  801418:	68 08 50 80 00       	push   $0x805008
  80141d:	e8 ca f4 ff ff       	call   8008ec <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801422:	ba 00 00 00 00       	mov    $0x0,%edx
  801427:	b8 04 00 00 00       	mov    $0x4,%eax
  80142c:	e8 cc fe ff ff       	call   8012fd <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801431:	c9                   	leave  
  801432:	c3                   	ret    

00801433 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801433:	55                   	push   %ebp
  801434:	89 e5                	mov    %esp,%ebp
  801436:	56                   	push   %esi
  801437:	53                   	push   %ebx
  801438:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80143b:	8b 45 08             	mov    0x8(%ebp),%eax
  80143e:	8b 40 0c             	mov    0xc(%eax),%eax
  801441:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801446:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80144c:	ba 00 00 00 00       	mov    $0x0,%edx
  801451:	b8 03 00 00 00       	mov    $0x3,%eax
  801456:	e8 a2 fe ff ff       	call   8012fd <fsipc>
  80145b:	89 c3                	mov    %eax,%ebx
  80145d:	85 c0                	test   %eax,%eax
  80145f:	78 4b                	js     8014ac <devfile_read+0x79>
		return r;
	assert(r <= n);
  801461:	39 c6                	cmp    %eax,%esi
  801463:	73 16                	jae    80147b <devfile_read+0x48>
  801465:	68 98 22 80 00       	push   $0x802298
  80146a:	68 9f 22 80 00       	push   $0x80229f
  80146f:	6a 7c                	push   $0x7c
  801471:	68 b4 22 80 00       	push   $0x8022b4
  801476:	e8 bd 05 00 00       	call   801a38 <_panic>
	assert(r <= PGSIZE);
  80147b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801480:	7e 16                	jle    801498 <devfile_read+0x65>
  801482:	68 bf 22 80 00       	push   $0x8022bf
  801487:	68 9f 22 80 00       	push   $0x80229f
  80148c:	6a 7d                	push   $0x7d
  80148e:	68 b4 22 80 00       	push   $0x8022b4
  801493:	e8 a0 05 00 00       	call   801a38 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801498:	83 ec 04             	sub    $0x4,%esp
  80149b:	50                   	push   %eax
  80149c:	68 00 50 80 00       	push   $0x805000
  8014a1:	ff 75 0c             	pushl  0xc(%ebp)
  8014a4:	e8 43 f4 ff ff       	call   8008ec <memmove>
	return r;
  8014a9:	83 c4 10             	add    $0x10,%esp
}
  8014ac:	89 d8                	mov    %ebx,%eax
  8014ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b1:	5b                   	pop    %ebx
  8014b2:	5e                   	pop    %esi
  8014b3:	5d                   	pop    %ebp
  8014b4:	c3                   	ret    

008014b5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014b5:	55                   	push   %ebp
  8014b6:	89 e5                	mov    %esp,%ebp
  8014b8:	53                   	push   %ebx
  8014b9:	83 ec 20             	sub    $0x20,%esp
  8014bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014bf:	53                   	push   %ebx
  8014c0:	e8 5c f2 ff ff       	call   800721 <strlen>
  8014c5:	83 c4 10             	add    $0x10,%esp
  8014c8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014cd:	7f 67                	jg     801536 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014cf:	83 ec 0c             	sub    $0xc,%esp
  8014d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d5:	50                   	push   %eax
  8014d6:	e8 9a f8 ff ff       	call   800d75 <fd_alloc>
  8014db:	83 c4 10             	add    $0x10,%esp
		return r;
  8014de:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014e0:	85 c0                	test   %eax,%eax
  8014e2:	78 57                	js     80153b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014e4:	83 ec 08             	sub    $0x8,%esp
  8014e7:	53                   	push   %ebx
  8014e8:	68 00 50 80 00       	push   $0x805000
  8014ed:	e8 68 f2 ff ff       	call   80075a <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f5:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014fd:	b8 01 00 00 00       	mov    $0x1,%eax
  801502:	e8 f6 fd ff ff       	call   8012fd <fsipc>
  801507:	89 c3                	mov    %eax,%ebx
  801509:	83 c4 10             	add    $0x10,%esp
  80150c:	85 c0                	test   %eax,%eax
  80150e:	79 14                	jns    801524 <open+0x6f>
		fd_close(fd, 0);
  801510:	83 ec 08             	sub    $0x8,%esp
  801513:	6a 00                	push   $0x0
  801515:	ff 75 f4             	pushl  -0xc(%ebp)
  801518:	e8 50 f9 ff ff       	call   800e6d <fd_close>
		return r;
  80151d:	83 c4 10             	add    $0x10,%esp
  801520:	89 da                	mov    %ebx,%edx
  801522:	eb 17                	jmp    80153b <open+0x86>
	}

	return fd2num(fd);
  801524:	83 ec 0c             	sub    $0xc,%esp
  801527:	ff 75 f4             	pushl  -0xc(%ebp)
  80152a:	e8 1f f8 ff ff       	call   800d4e <fd2num>
  80152f:	89 c2                	mov    %eax,%edx
  801531:	83 c4 10             	add    $0x10,%esp
  801534:	eb 05                	jmp    80153b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801536:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80153b:	89 d0                	mov    %edx,%eax
  80153d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801540:	c9                   	leave  
  801541:	c3                   	ret    

00801542 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801542:	55                   	push   %ebp
  801543:	89 e5                	mov    %esp,%ebp
  801545:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801548:	ba 00 00 00 00       	mov    $0x0,%edx
  80154d:	b8 08 00 00 00       	mov    $0x8,%eax
  801552:	e8 a6 fd ff ff       	call   8012fd <fsipc>
}
  801557:	c9                   	leave  
  801558:	c3                   	ret    

00801559 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801559:	55                   	push   %ebp
  80155a:	89 e5                	mov    %esp,%ebp
  80155c:	56                   	push   %esi
  80155d:	53                   	push   %ebx
  80155e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801561:	83 ec 0c             	sub    $0xc,%esp
  801564:	ff 75 08             	pushl  0x8(%ebp)
  801567:	e8 f2 f7 ff ff       	call   800d5e <fd2data>
  80156c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80156e:	83 c4 08             	add    $0x8,%esp
  801571:	68 cb 22 80 00       	push   $0x8022cb
  801576:	53                   	push   %ebx
  801577:	e8 de f1 ff ff       	call   80075a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80157c:	8b 46 04             	mov    0x4(%esi),%eax
  80157f:	2b 06                	sub    (%esi),%eax
  801581:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801587:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80158e:	00 00 00 
	stat->st_dev = &devpipe;
  801591:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801598:	30 80 00 
	return 0;
}
  80159b:	b8 00 00 00 00       	mov    $0x0,%eax
  8015a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015a3:	5b                   	pop    %ebx
  8015a4:	5e                   	pop    %esi
  8015a5:	5d                   	pop    %ebp
  8015a6:	c3                   	ret    

008015a7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8015a7:	55                   	push   %ebp
  8015a8:	89 e5                	mov    %esp,%ebp
  8015aa:	53                   	push   %ebx
  8015ab:	83 ec 0c             	sub    $0xc,%esp
  8015ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015b1:	53                   	push   %ebx
  8015b2:	6a 00                	push   $0x0
  8015b4:	e8 29 f6 ff ff       	call   800be2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015b9:	89 1c 24             	mov    %ebx,(%esp)
  8015bc:	e8 9d f7 ff ff       	call   800d5e <fd2data>
  8015c1:	83 c4 08             	add    $0x8,%esp
  8015c4:	50                   	push   %eax
  8015c5:	6a 00                	push   $0x0
  8015c7:	e8 16 f6 ff ff       	call   800be2 <sys_page_unmap>
}
  8015cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015cf:	c9                   	leave  
  8015d0:	c3                   	ret    

008015d1 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015d1:	55                   	push   %ebp
  8015d2:	89 e5                	mov    %esp,%ebp
  8015d4:	57                   	push   %edi
  8015d5:	56                   	push   %esi
  8015d6:	53                   	push   %ebx
  8015d7:	83 ec 1c             	sub    $0x1c,%esp
  8015da:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015dd:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015df:	a1 04 40 80 00       	mov    0x804004,%eax
  8015e4:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015e7:	83 ec 0c             	sub    $0xc,%esp
  8015ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8015ed:	e8 99 05 00 00       	call   801b8b <pageref>
  8015f2:	89 c3                	mov    %eax,%ebx
  8015f4:	89 3c 24             	mov    %edi,(%esp)
  8015f7:	e8 8f 05 00 00       	call   801b8b <pageref>
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	39 c3                	cmp    %eax,%ebx
  801601:	0f 94 c1             	sete   %cl
  801604:	0f b6 c9             	movzbl %cl,%ecx
  801607:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80160a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801610:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801613:	39 ce                	cmp    %ecx,%esi
  801615:	74 1b                	je     801632 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801617:	39 c3                	cmp    %eax,%ebx
  801619:	75 c4                	jne    8015df <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80161b:	8b 42 58             	mov    0x58(%edx),%eax
  80161e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801621:	50                   	push   %eax
  801622:	56                   	push   %esi
  801623:	68 d2 22 80 00       	push   $0x8022d2
  801628:	e8 a8 eb ff ff       	call   8001d5 <cprintf>
  80162d:	83 c4 10             	add    $0x10,%esp
  801630:	eb ad                	jmp    8015df <_pipeisclosed+0xe>
	}
}
  801632:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801635:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801638:	5b                   	pop    %ebx
  801639:	5e                   	pop    %esi
  80163a:	5f                   	pop    %edi
  80163b:	5d                   	pop    %ebp
  80163c:	c3                   	ret    

0080163d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80163d:	55                   	push   %ebp
  80163e:	89 e5                	mov    %esp,%ebp
  801640:	57                   	push   %edi
  801641:	56                   	push   %esi
  801642:	53                   	push   %ebx
  801643:	83 ec 28             	sub    $0x28,%esp
  801646:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801649:	56                   	push   %esi
  80164a:	e8 0f f7 ff ff       	call   800d5e <fd2data>
  80164f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801651:	83 c4 10             	add    $0x10,%esp
  801654:	bf 00 00 00 00       	mov    $0x0,%edi
  801659:	eb 4b                	jmp    8016a6 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80165b:	89 da                	mov    %ebx,%edx
  80165d:	89 f0                	mov    %esi,%eax
  80165f:	e8 6d ff ff ff       	call   8015d1 <_pipeisclosed>
  801664:	85 c0                	test   %eax,%eax
  801666:	75 48                	jne    8016b0 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801668:	e8 d1 f4 ff ff       	call   800b3e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80166d:	8b 43 04             	mov    0x4(%ebx),%eax
  801670:	8b 0b                	mov    (%ebx),%ecx
  801672:	8d 51 20             	lea    0x20(%ecx),%edx
  801675:	39 d0                	cmp    %edx,%eax
  801677:	73 e2                	jae    80165b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801679:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80167c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801680:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801683:	89 c2                	mov    %eax,%edx
  801685:	c1 fa 1f             	sar    $0x1f,%edx
  801688:	89 d1                	mov    %edx,%ecx
  80168a:	c1 e9 1b             	shr    $0x1b,%ecx
  80168d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801690:	83 e2 1f             	and    $0x1f,%edx
  801693:	29 ca                	sub    %ecx,%edx
  801695:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801699:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80169d:	83 c0 01             	add    $0x1,%eax
  8016a0:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016a3:	83 c7 01             	add    $0x1,%edi
  8016a6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8016a9:	75 c2                	jne    80166d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8016ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8016ae:	eb 05                	jmp    8016b5 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016b0:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8016b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b8:	5b                   	pop    %ebx
  8016b9:	5e                   	pop    %esi
  8016ba:	5f                   	pop    %edi
  8016bb:	5d                   	pop    %ebp
  8016bc:	c3                   	ret    

008016bd <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016bd:	55                   	push   %ebp
  8016be:	89 e5                	mov    %esp,%ebp
  8016c0:	57                   	push   %edi
  8016c1:	56                   	push   %esi
  8016c2:	53                   	push   %ebx
  8016c3:	83 ec 18             	sub    $0x18,%esp
  8016c6:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016c9:	57                   	push   %edi
  8016ca:	e8 8f f6 ff ff       	call   800d5e <fd2data>
  8016cf:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016d1:	83 c4 10             	add    $0x10,%esp
  8016d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016d9:	eb 3d                	jmp    801718 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016db:	85 db                	test   %ebx,%ebx
  8016dd:	74 04                	je     8016e3 <devpipe_read+0x26>
				return i;
  8016df:	89 d8                	mov    %ebx,%eax
  8016e1:	eb 44                	jmp    801727 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016e3:	89 f2                	mov    %esi,%edx
  8016e5:	89 f8                	mov    %edi,%eax
  8016e7:	e8 e5 fe ff ff       	call   8015d1 <_pipeisclosed>
  8016ec:	85 c0                	test   %eax,%eax
  8016ee:	75 32                	jne    801722 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016f0:	e8 49 f4 ff ff       	call   800b3e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016f5:	8b 06                	mov    (%esi),%eax
  8016f7:	3b 46 04             	cmp    0x4(%esi),%eax
  8016fa:	74 df                	je     8016db <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016fc:	99                   	cltd   
  8016fd:	c1 ea 1b             	shr    $0x1b,%edx
  801700:	01 d0                	add    %edx,%eax
  801702:	83 e0 1f             	and    $0x1f,%eax
  801705:	29 d0                	sub    %edx,%eax
  801707:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80170c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80170f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801712:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801715:	83 c3 01             	add    $0x1,%ebx
  801718:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80171b:	75 d8                	jne    8016f5 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80171d:	8b 45 10             	mov    0x10(%ebp),%eax
  801720:	eb 05                	jmp    801727 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801722:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801727:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80172a:	5b                   	pop    %ebx
  80172b:	5e                   	pop    %esi
  80172c:	5f                   	pop    %edi
  80172d:	5d                   	pop    %ebp
  80172e:	c3                   	ret    

0080172f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80172f:	55                   	push   %ebp
  801730:	89 e5                	mov    %esp,%ebp
  801732:	56                   	push   %esi
  801733:	53                   	push   %ebx
  801734:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801737:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80173a:	50                   	push   %eax
  80173b:	e8 35 f6 ff ff       	call   800d75 <fd_alloc>
  801740:	83 c4 10             	add    $0x10,%esp
  801743:	89 c2                	mov    %eax,%edx
  801745:	85 c0                	test   %eax,%eax
  801747:	0f 88 2c 01 00 00    	js     801879 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80174d:	83 ec 04             	sub    $0x4,%esp
  801750:	68 07 04 00 00       	push   $0x407
  801755:	ff 75 f4             	pushl  -0xc(%ebp)
  801758:	6a 00                	push   $0x0
  80175a:	e8 fe f3 ff ff       	call   800b5d <sys_page_alloc>
  80175f:	83 c4 10             	add    $0x10,%esp
  801762:	89 c2                	mov    %eax,%edx
  801764:	85 c0                	test   %eax,%eax
  801766:	0f 88 0d 01 00 00    	js     801879 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80176c:	83 ec 0c             	sub    $0xc,%esp
  80176f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801772:	50                   	push   %eax
  801773:	e8 fd f5 ff ff       	call   800d75 <fd_alloc>
  801778:	89 c3                	mov    %eax,%ebx
  80177a:	83 c4 10             	add    $0x10,%esp
  80177d:	85 c0                	test   %eax,%eax
  80177f:	0f 88 e2 00 00 00    	js     801867 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801785:	83 ec 04             	sub    $0x4,%esp
  801788:	68 07 04 00 00       	push   $0x407
  80178d:	ff 75 f0             	pushl  -0x10(%ebp)
  801790:	6a 00                	push   $0x0
  801792:	e8 c6 f3 ff ff       	call   800b5d <sys_page_alloc>
  801797:	89 c3                	mov    %eax,%ebx
  801799:	83 c4 10             	add    $0x10,%esp
  80179c:	85 c0                	test   %eax,%eax
  80179e:	0f 88 c3 00 00 00    	js     801867 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8017a4:	83 ec 0c             	sub    $0xc,%esp
  8017a7:	ff 75 f4             	pushl  -0xc(%ebp)
  8017aa:	e8 af f5 ff ff       	call   800d5e <fd2data>
  8017af:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017b1:	83 c4 0c             	add    $0xc,%esp
  8017b4:	68 07 04 00 00       	push   $0x407
  8017b9:	50                   	push   %eax
  8017ba:	6a 00                	push   $0x0
  8017bc:	e8 9c f3 ff ff       	call   800b5d <sys_page_alloc>
  8017c1:	89 c3                	mov    %eax,%ebx
  8017c3:	83 c4 10             	add    $0x10,%esp
  8017c6:	85 c0                	test   %eax,%eax
  8017c8:	0f 88 89 00 00 00    	js     801857 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017ce:	83 ec 0c             	sub    $0xc,%esp
  8017d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8017d4:	e8 85 f5 ff ff       	call   800d5e <fd2data>
  8017d9:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017e0:	50                   	push   %eax
  8017e1:	6a 00                	push   $0x0
  8017e3:	56                   	push   %esi
  8017e4:	6a 00                	push   $0x0
  8017e6:	e8 b5 f3 ff ff       	call   800ba0 <sys_page_map>
  8017eb:	89 c3                	mov    %eax,%ebx
  8017ed:	83 c4 20             	add    $0x20,%esp
  8017f0:	85 c0                	test   %eax,%eax
  8017f2:	78 55                	js     801849 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017f4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017fd:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801802:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801809:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80180f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801812:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801814:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801817:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80181e:	83 ec 0c             	sub    $0xc,%esp
  801821:	ff 75 f4             	pushl  -0xc(%ebp)
  801824:	e8 25 f5 ff ff       	call   800d4e <fd2num>
  801829:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80182c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80182e:	83 c4 04             	add    $0x4,%esp
  801831:	ff 75 f0             	pushl  -0x10(%ebp)
  801834:	e8 15 f5 ff ff       	call   800d4e <fd2num>
  801839:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80183c:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80183f:	83 c4 10             	add    $0x10,%esp
  801842:	ba 00 00 00 00       	mov    $0x0,%edx
  801847:	eb 30                	jmp    801879 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801849:	83 ec 08             	sub    $0x8,%esp
  80184c:	56                   	push   %esi
  80184d:	6a 00                	push   $0x0
  80184f:	e8 8e f3 ff ff       	call   800be2 <sys_page_unmap>
  801854:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801857:	83 ec 08             	sub    $0x8,%esp
  80185a:	ff 75 f0             	pushl  -0x10(%ebp)
  80185d:	6a 00                	push   $0x0
  80185f:	e8 7e f3 ff ff       	call   800be2 <sys_page_unmap>
  801864:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801867:	83 ec 08             	sub    $0x8,%esp
  80186a:	ff 75 f4             	pushl  -0xc(%ebp)
  80186d:	6a 00                	push   $0x0
  80186f:	e8 6e f3 ff ff       	call   800be2 <sys_page_unmap>
  801874:	83 c4 10             	add    $0x10,%esp
  801877:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801879:	89 d0                	mov    %edx,%eax
  80187b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80187e:	5b                   	pop    %ebx
  80187f:	5e                   	pop    %esi
  801880:	5d                   	pop    %ebp
  801881:	c3                   	ret    

00801882 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801882:	55                   	push   %ebp
  801883:	89 e5                	mov    %esp,%ebp
  801885:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801888:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80188b:	50                   	push   %eax
  80188c:	ff 75 08             	pushl  0x8(%ebp)
  80188f:	e8 30 f5 ff ff       	call   800dc4 <fd_lookup>
  801894:	83 c4 10             	add    $0x10,%esp
  801897:	85 c0                	test   %eax,%eax
  801899:	78 18                	js     8018b3 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80189b:	83 ec 0c             	sub    $0xc,%esp
  80189e:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a1:	e8 b8 f4 ff ff       	call   800d5e <fd2data>
	return _pipeisclosed(fd, p);
  8018a6:	89 c2                	mov    %eax,%edx
  8018a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ab:	e8 21 fd ff ff       	call   8015d1 <_pipeisclosed>
  8018b0:	83 c4 10             	add    $0x10,%esp
}
  8018b3:	c9                   	leave  
  8018b4:	c3                   	ret    

008018b5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8018b5:	55                   	push   %ebp
  8018b6:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8018b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8018bd:	5d                   	pop    %ebp
  8018be:	c3                   	ret    

008018bf <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018c5:	68 ea 22 80 00       	push   $0x8022ea
  8018ca:	ff 75 0c             	pushl  0xc(%ebp)
  8018cd:	e8 88 ee ff ff       	call   80075a <strcpy>
	return 0;
}
  8018d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d7:	c9                   	leave  
  8018d8:	c3                   	ret    

008018d9 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018d9:	55                   	push   %ebp
  8018da:	89 e5                	mov    %esp,%ebp
  8018dc:	57                   	push   %edi
  8018dd:	56                   	push   %esi
  8018de:	53                   	push   %ebx
  8018df:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018e5:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018ea:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018f0:	eb 2d                	jmp    80191f <devcons_write+0x46>
		m = n - tot;
  8018f2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018f5:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018f7:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018fa:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018ff:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801902:	83 ec 04             	sub    $0x4,%esp
  801905:	53                   	push   %ebx
  801906:	03 45 0c             	add    0xc(%ebp),%eax
  801909:	50                   	push   %eax
  80190a:	57                   	push   %edi
  80190b:	e8 dc ef ff ff       	call   8008ec <memmove>
		sys_cputs(buf, m);
  801910:	83 c4 08             	add    $0x8,%esp
  801913:	53                   	push   %ebx
  801914:	57                   	push   %edi
  801915:	e8 87 f1 ff ff       	call   800aa1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80191a:	01 de                	add    %ebx,%esi
  80191c:	83 c4 10             	add    $0x10,%esp
  80191f:	89 f0                	mov    %esi,%eax
  801921:	3b 75 10             	cmp    0x10(%ebp),%esi
  801924:	72 cc                	jb     8018f2 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801926:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801929:	5b                   	pop    %ebx
  80192a:	5e                   	pop    %esi
  80192b:	5f                   	pop    %edi
  80192c:	5d                   	pop    %ebp
  80192d:	c3                   	ret    

0080192e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80192e:	55                   	push   %ebp
  80192f:	89 e5                	mov    %esp,%ebp
  801931:	83 ec 08             	sub    $0x8,%esp
  801934:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801939:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80193d:	74 2a                	je     801969 <devcons_read+0x3b>
  80193f:	eb 05                	jmp    801946 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801941:	e8 f8 f1 ff ff       	call   800b3e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801946:	e8 74 f1 ff ff       	call   800abf <sys_cgetc>
  80194b:	85 c0                	test   %eax,%eax
  80194d:	74 f2                	je     801941 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80194f:	85 c0                	test   %eax,%eax
  801951:	78 16                	js     801969 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801953:	83 f8 04             	cmp    $0x4,%eax
  801956:	74 0c                	je     801964 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801958:	8b 55 0c             	mov    0xc(%ebp),%edx
  80195b:	88 02                	mov    %al,(%edx)
	return 1;
  80195d:	b8 01 00 00 00       	mov    $0x1,%eax
  801962:	eb 05                	jmp    801969 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801964:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801969:	c9                   	leave  
  80196a:	c3                   	ret    

0080196b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80196b:	55                   	push   %ebp
  80196c:	89 e5                	mov    %esp,%ebp
  80196e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801971:	8b 45 08             	mov    0x8(%ebp),%eax
  801974:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801977:	6a 01                	push   $0x1
  801979:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80197c:	50                   	push   %eax
  80197d:	e8 1f f1 ff ff       	call   800aa1 <sys_cputs>
}
  801982:	83 c4 10             	add    $0x10,%esp
  801985:	c9                   	leave  
  801986:	c3                   	ret    

00801987 <getchar>:

int
getchar(void)
{
  801987:	55                   	push   %ebp
  801988:	89 e5                	mov    %esp,%ebp
  80198a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80198d:	6a 01                	push   $0x1
  80198f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801992:	50                   	push   %eax
  801993:	6a 00                	push   $0x0
  801995:	e8 90 f6 ff ff       	call   80102a <read>
	if (r < 0)
  80199a:	83 c4 10             	add    $0x10,%esp
  80199d:	85 c0                	test   %eax,%eax
  80199f:	78 0f                	js     8019b0 <getchar+0x29>
		return r;
	if (r < 1)
  8019a1:	85 c0                	test   %eax,%eax
  8019a3:	7e 06                	jle    8019ab <getchar+0x24>
		return -E_EOF;
	return c;
  8019a5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8019a9:	eb 05                	jmp    8019b0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8019ab:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8019b0:	c9                   	leave  
  8019b1:	c3                   	ret    

008019b2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8019b2:	55                   	push   %ebp
  8019b3:	89 e5                	mov    %esp,%ebp
  8019b5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019bb:	50                   	push   %eax
  8019bc:	ff 75 08             	pushl  0x8(%ebp)
  8019bf:	e8 00 f4 ff ff       	call   800dc4 <fd_lookup>
  8019c4:	83 c4 10             	add    $0x10,%esp
  8019c7:	85 c0                	test   %eax,%eax
  8019c9:	78 11                	js     8019dc <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ce:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019d4:	39 10                	cmp    %edx,(%eax)
  8019d6:	0f 94 c0             	sete   %al
  8019d9:	0f b6 c0             	movzbl %al,%eax
}
  8019dc:	c9                   	leave  
  8019dd:	c3                   	ret    

008019de <opencons>:

int
opencons(void)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e7:	50                   	push   %eax
  8019e8:	e8 88 f3 ff ff       	call   800d75 <fd_alloc>
  8019ed:	83 c4 10             	add    $0x10,%esp
		return r;
  8019f0:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019f2:	85 c0                	test   %eax,%eax
  8019f4:	78 3e                	js     801a34 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019f6:	83 ec 04             	sub    $0x4,%esp
  8019f9:	68 07 04 00 00       	push   $0x407
  8019fe:	ff 75 f4             	pushl  -0xc(%ebp)
  801a01:	6a 00                	push   $0x0
  801a03:	e8 55 f1 ff ff       	call   800b5d <sys_page_alloc>
  801a08:	83 c4 10             	add    $0x10,%esp
		return r;
  801a0b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a0d:	85 c0                	test   %eax,%eax
  801a0f:	78 23                	js     801a34 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a11:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a1a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a1f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a26:	83 ec 0c             	sub    $0xc,%esp
  801a29:	50                   	push   %eax
  801a2a:	e8 1f f3 ff ff       	call   800d4e <fd2num>
  801a2f:	89 c2                	mov    %eax,%edx
  801a31:	83 c4 10             	add    $0x10,%esp
}
  801a34:	89 d0                	mov    %edx,%eax
  801a36:	c9                   	leave  
  801a37:	c3                   	ret    

00801a38 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a38:	55                   	push   %ebp
  801a39:	89 e5                	mov    %esp,%ebp
  801a3b:	56                   	push   %esi
  801a3c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a3d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a40:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a46:	e8 d4 f0 ff ff       	call   800b1f <sys_getenvid>
  801a4b:	83 ec 0c             	sub    $0xc,%esp
  801a4e:	ff 75 0c             	pushl  0xc(%ebp)
  801a51:	ff 75 08             	pushl  0x8(%ebp)
  801a54:	56                   	push   %esi
  801a55:	50                   	push   %eax
  801a56:	68 f8 22 80 00       	push   $0x8022f8
  801a5b:	e8 75 e7 ff ff       	call   8001d5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a60:	83 c4 18             	add    $0x18,%esp
  801a63:	53                   	push   %ebx
  801a64:	ff 75 10             	pushl  0x10(%ebp)
  801a67:	e8 18 e7 ff ff       	call   800184 <vcprintf>
	cprintf("\n");
  801a6c:	c7 04 24 e3 22 80 00 	movl   $0x8022e3,(%esp)
  801a73:	e8 5d e7 ff ff       	call   8001d5 <cprintf>
  801a78:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a7b:	cc                   	int3   
  801a7c:	eb fd                	jmp    801a7b <_panic+0x43>

00801a7e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a7e:	55                   	push   %ebp
  801a7f:	89 e5                	mov    %esp,%ebp
  801a81:	56                   	push   %esi
  801a82:	53                   	push   %ebx
  801a83:	8b 75 08             	mov    0x8(%ebp),%esi
  801a86:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a89:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801a8c:	85 c0                	test   %eax,%eax
  801a8e:	75 12                	jne    801aa2 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801a90:	83 ec 0c             	sub    $0xc,%esp
  801a93:	68 00 00 c0 ee       	push   $0xeec00000
  801a98:	e8 70 f2 ff ff       	call   800d0d <sys_ipc_recv>
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	eb 0c                	jmp    801aae <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801aa2:	83 ec 0c             	sub    $0xc,%esp
  801aa5:	50                   	push   %eax
  801aa6:	e8 62 f2 ff ff       	call   800d0d <sys_ipc_recv>
  801aab:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801aae:	85 f6                	test   %esi,%esi
  801ab0:	0f 95 c1             	setne  %cl
  801ab3:	85 db                	test   %ebx,%ebx
  801ab5:	0f 95 c2             	setne  %dl
  801ab8:	84 d1                	test   %dl,%cl
  801aba:	74 09                	je     801ac5 <ipc_recv+0x47>
  801abc:	89 c2                	mov    %eax,%edx
  801abe:	c1 ea 1f             	shr    $0x1f,%edx
  801ac1:	84 d2                	test   %dl,%dl
  801ac3:	75 24                	jne    801ae9 <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801ac5:	85 f6                	test   %esi,%esi
  801ac7:	74 0a                	je     801ad3 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801ac9:	a1 04 40 80 00       	mov    0x804004,%eax
  801ace:	8b 40 74             	mov    0x74(%eax),%eax
  801ad1:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801ad3:	85 db                	test   %ebx,%ebx
  801ad5:	74 0a                	je     801ae1 <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  801ad7:	a1 04 40 80 00       	mov    0x804004,%eax
  801adc:	8b 40 78             	mov    0x78(%eax),%eax
  801adf:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ae1:	a1 04 40 80 00       	mov    0x804004,%eax
  801ae6:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ae9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aec:	5b                   	pop    %ebx
  801aed:	5e                   	pop    %esi
  801aee:	5d                   	pop    %ebp
  801aef:	c3                   	ret    

00801af0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801af0:	55                   	push   %ebp
  801af1:	89 e5                	mov    %esp,%ebp
  801af3:	57                   	push   %edi
  801af4:	56                   	push   %esi
  801af5:	53                   	push   %ebx
  801af6:	83 ec 0c             	sub    $0xc,%esp
  801af9:	8b 7d 08             	mov    0x8(%ebp),%edi
  801afc:	8b 75 0c             	mov    0xc(%ebp),%esi
  801aff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801b02:	85 db                	test   %ebx,%ebx
  801b04:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b09:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801b0c:	ff 75 14             	pushl  0x14(%ebp)
  801b0f:	53                   	push   %ebx
  801b10:	56                   	push   %esi
  801b11:	57                   	push   %edi
  801b12:	e8 d3 f1 ff ff       	call   800cea <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801b17:	89 c2                	mov    %eax,%edx
  801b19:	c1 ea 1f             	shr    $0x1f,%edx
  801b1c:	83 c4 10             	add    $0x10,%esp
  801b1f:	84 d2                	test   %dl,%dl
  801b21:	74 17                	je     801b3a <ipc_send+0x4a>
  801b23:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b26:	74 12                	je     801b3a <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801b28:	50                   	push   %eax
  801b29:	68 1c 23 80 00       	push   $0x80231c
  801b2e:	6a 47                	push   $0x47
  801b30:	68 2a 23 80 00       	push   $0x80232a
  801b35:	e8 fe fe ff ff       	call   801a38 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801b3a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b3d:	75 07                	jne    801b46 <ipc_send+0x56>
			sys_yield();
  801b3f:	e8 fa ef ff ff       	call   800b3e <sys_yield>
  801b44:	eb c6                	jmp    801b0c <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801b46:	85 c0                	test   %eax,%eax
  801b48:	75 c2                	jne    801b0c <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801b4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b4d:	5b                   	pop    %ebx
  801b4e:	5e                   	pop    %esi
  801b4f:	5f                   	pop    %edi
  801b50:	5d                   	pop    %ebp
  801b51:	c3                   	ret    

00801b52 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b52:	55                   	push   %ebp
  801b53:	89 e5                	mov    %esp,%ebp
  801b55:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b58:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b5d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b60:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b66:	8b 52 50             	mov    0x50(%edx),%edx
  801b69:	39 ca                	cmp    %ecx,%edx
  801b6b:	75 0d                	jne    801b7a <ipc_find_env+0x28>
			return envs[i].env_id;
  801b6d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b70:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b75:	8b 40 48             	mov    0x48(%eax),%eax
  801b78:	eb 0f                	jmp    801b89 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b7a:	83 c0 01             	add    $0x1,%eax
  801b7d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b82:	75 d9                	jne    801b5d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b84:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b89:	5d                   	pop    %ebp
  801b8a:	c3                   	ret    

00801b8b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b91:	89 d0                	mov    %edx,%eax
  801b93:	c1 e8 16             	shr    $0x16,%eax
  801b96:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b9d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ba2:	f6 c1 01             	test   $0x1,%cl
  801ba5:	74 1d                	je     801bc4 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ba7:	c1 ea 0c             	shr    $0xc,%edx
  801baa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bb1:	f6 c2 01             	test   $0x1,%dl
  801bb4:	74 0e                	je     801bc4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bb6:	c1 ea 0c             	shr    $0xc,%edx
  801bb9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bc0:	ef 
  801bc1:	0f b7 c0             	movzwl %ax,%eax
}
  801bc4:	5d                   	pop    %ebp
  801bc5:	c3                   	ret    
  801bc6:	66 90                	xchg   %ax,%ax
  801bc8:	66 90                	xchg   %ax,%ax
  801bca:	66 90                	xchg   %ax,%ax
  801bcc:	66 90                	xchg   %ax,%ax
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
