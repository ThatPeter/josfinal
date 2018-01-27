
obj/user/spawnhello.debug:     file format elf32-i386


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
  80002c:	e8 4a 00 00 00       	call   80007b <libmain>
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
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  800039:	a1 04 40 80 00       	mov    0x804004,%eax
  80003e:	8b 40 7c             	mov    0x7c(%eax),%eax
  800041:	50                   	push   %eax
  800042:	68 e0 27 80 00       	push   $0x8027e0
  800047:	e8 8b 01 00 00       	call   8001d7 <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  80004c:	83 c4 0c             	add    $0xc,%esp
  80004f:	6a 00                	push   $0x0
  800051:	68 fe 27 80 00       	push   $0x8027fe
  800056:	68 fe 27 80 00       	push   $0x8027fe
  80005b:	e8 a1 1d 00 00       	call   801e01 <spawnl>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	85 c0                	test   %eax,%eax
  800065:	79 12                	jns    800079 <umain+0x46>
		panic("spawn(hello) failed: %e", r);
  800067:	50                   	push   %eax
  800068:	68 04 28 80 00       	push   $0x802804
  80006d:	6a 09                	push   $0x9
  80006f:	68 1c 28 80 00       	push   $0x80281c
  800074:	e8 85 00 00 00       	call   8000fe <_panic>
}
  800079:	c9                   	leave  
  80007a:	c3                   	ret    

0080007b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80007b:	55                   	push   %ebp
  80007c:	89 e5                	mov    %esp,%ebp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800083:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800086:	e8 96 0a 00 00       	call   800b21 <sys_getenvid>
  80008b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800090:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800096:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009b:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a0:	85 db                	test   %ebx,%ebx
  8000a2:	7e 07                	jle    8000ab <libmain+0x30>
		binaryname = argv[0];
  8000a4:	8b 06                	mov    (%esi),%eax
  8000a6:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ab:	83 ec 08             	sub    $0x8,%esp
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
  8000b0:	e8 7e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b5:	e8 2a 00 00 00       	call   8000e4 <exit>
}
  8000ba:	83 c4 10             	add    $0x10,%esp
  8000bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c0:	5b                   	pop    %ebx
  8000c1:	5e                   	pop    %esi
  8000c2:	5d                   	pop    %ebp
  8000c3:	c3                   	ret    

008000c4 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  8000ca:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  8000cf:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8000d1:	e8 4b 0a 00 00       	call   800b21 <sys_getenvid>
  8000d6:	83 ec 0c             	sub    $0xc,%esp
  8000d9:	50                   	push   %eax
  8000da:	e8 91 0c 00 00       	call   800d70 <sys_thread_free>
}
  8000df:	83 c4 10             	add    $0x10,%esp
  8000e2:	c9                   	leave  
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
  8000ea:	e8 60 11 00 00       	call   80124f <close_all>
	sys_env_destroy(0);
  8000ef:	83 ec 0c             	sub    $0xc,%esp
  8000f2:	6a 00                	push   $0x0
  8000f4:	e8 e7 09 00 00       	call   800ae0 <sys_env_destroy>
}
  8000f9:	83 c4 10             	add    $0x10,%esp
  8000fc:	c9                   	leave  
  8000fd:	c3                   	ret    

008000fe <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800103:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800106:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80010c:	e8 10 0a 00 00       	call   800b21 <sys_getenvid>
  800111:	83 ec 0c             	sub    $0xc,%esp
  800114:	ff 75 0c             	pushl  0xc(%ebp)
  800117:	ff 75 08             	pushl  0x8(%ebp)
  80011a:	56                   	push   %esi
  80011b:	50                   	push   %eax
  80011c:	68 38 28 80 00       	push   $0x802838
  800121:	e8 b1 00 00 00       	call   8001d7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800126:	83 c4 18             	add    $0x18,%esp
  800129:	53                   	push   %ebx
  80012a:	ff 75 10             	pushl  0x10(%ebp)
  80012d:	e8 54 00 00 00       	call   800186 <vcprintf>
	cprintf("\n");
  800132:	c7 04 24 94 2d 80 00 	movl   $0x802d94,(%esp)
  800139:	e8 99 00 00 00       	call   8001d7 <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800141:	cc                   	int3   
  800142:	eb fd                	jmp    800141 <_panic+0x43>

00800144 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	53                   	push   %ebx
  800148:	83 ec 04             	sub    $0x4,%esp
  80014b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80014e:	8b 13                	mov    (%ebx),%edx
  800150:	8d 42 01             	lea    0x1(%edx),%eax
  800153:	89 03                	mov    %eax,(%ebx)
  800155:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800158:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80015c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800161:	75 1a                	jne    80017d <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800163:	83 ec 08             	sub    $0x8,%esp
  800166:	68 ff 00 00 00       	push   $0xff
  80016b:	8d 43 08             	lea    0x8(%ebx),%eax
  80016e:	50                   	push   %eax
  80016f:	e8 2f 09 00 00       	call   800aa3 <sys_cputs>
		b->idx = 0;
  800174:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80017a:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80017d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800181:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800184:	c9                   	leave  
  800185:	c3                   	ret    

00800186 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800186:	55                   	push   %ebp
  800187:	89 e5                	mov    %esp,%ebp
  800189:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80018f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800196:	00 00 00 
	b.cnt = 0;
  800199:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001a0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a3:	ff 75 0c             	pushl  0xc(%ebp)
  8001a6:	ff 75 08             	pushl  0x8(%ebp)
  8001a9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001af:	50                   	push   %eax
  8001b0:	68 44 01 80 00       	push   $0x800144
  8001b5:	e8 54 01 00 00       	call   80030e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ba:	83 c4 08             	add    $0x8,%esp
  8001bd:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001c3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c9:	50                   	push   %eax
  8001ca:	e8 d4 08 00 00       	call   800aa3 <sys_cputs>

	return b.cnt;
}
  8001cf:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d5:	c9                   	leave  
  8001d6:	c3                   	ret    

008001d7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001dd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001e0:	50                   	push   %eax
  8001e1:	ff 75 08             	pushl  0x8(%ebp)
  8001e4:	e8 9d ff ff ff       	call   800186 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e9:	c9                   	leave  
  8001ea:	c3                   	ret    

008001eb <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	57                   	push   %edi
  8001ef:	56                   	push   %esi
  8001f0:	53                   	push   %ebx
  8001f1:	83 ec 1c             	sub    $0x1c,%esp
  8001f4:	89 c7                	mov    %eax,%edi
  8001f6:	89 d6                	mov    %edx,%esi
  8001f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800201:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800204:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800207:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80020f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800212:	39 d3                	cmp    %edx,%ebx
  800214:	72 05                	jb     80021b <printnum+0x30>
  800216:	39 45 10             	cmp    %eax,0x10(%ebp)
  800219:	77 45                	ja     800260 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	ff 75 18             	pushl  0x18(%ebp)
  800221:	8b 45 14             	mov    0x14(%ebp),%eax
  800224:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800227:	53                   	push   %ebx
  800228:	ff 75 10             	pushl  0x10(%ebp)
  80022b:	83 ec 08             	sub    $0x8,%esp
  80022e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800231:	ff 75 e0             	pushl  -0x20(%ebp)
  800234:	ff 75 dc             	pushl  -0x24(%ebp)
  800237:	ff 75 d8             	pushl  -0x28(%ebp)
  80023a:	e8 11 23 00 00       	call   802550 <__udivdi3>
  80023f:	83 c4 18             	add    $0x18,%esp
  800242:	52                   	push   %edx
  800243:	50                   	push   %eax
  800244:	89 f2                	mov    %esi,%edx
  800246:	89 f8                	mov    %edi,%eax
  800248:	e8 9e ff ff ff       	call   8001eb <printnum>
  80024d:	83 c4 20             	add    $0x20,%esp
  800250:	eb 18                	jmp    80026a <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800252:	83 ec 08             	sub    $0x8,%esp
  800255:	56                   	push   %esi
  800256:	ff 75 18             	pushl  0x18(%ebp)
  800259:	ff d7                	call   *%edi
  80025b:	83 c4 10             	add    $0x10,%esp
  80025e:	eb 03                	jmp    800263 <printnum+0x78>
  800260:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800263:	83 eb 01             	sub    $0x1,%ebx
  800266:	85 db                	test   %ebx,%ebx
  800268:	7f e8                	jg     800252 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80026a:	83 ec 08             	sub    $0x8,%esp
  80026d:	56                   	push   %esi
  80026e:	83 ec 04             	sub    $0x4,%esp
  800271:	ff 75 e4             	pushl  -0x1c(%ebp)
  800274:	ff 75 e0             	pushl  -0x20(%ebp)
  800277:	ff 75 dc             	pushl  -0x24(%ebp)
  80027a:	ff 75 d8             	pushl  -0x28(%ebp)
  80027d:	e8 fe 23 00 00       	call   802680 <__umoddi3>
  800282:	83 c4 14             	add    $0x14,%esp
  800285:	0f be 80 5b 28 80 00 	movsbl 0x80285b(%eax),%eax
  80028c:	50                   	push   %eax
  80028d:	ff d7                	call   *%edi
}
  80028f:	83 c4 10             	add    $0x10,%esp
  800292:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800295:	5b                   	pop    %ebx
  800296:	5e                   	pop    %esi
  800297:	5f                   	pop    %edi
  800298:	5d                   	pop    %ebp
  800299:	c3                   	ret    

0080029a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80029a:	55                   	push   %ebp
  80029b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80029d:	83 fa 01             	cmp    $0x1,%edx
  8002a0:	7e 0e                	jle    8002b0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002a2:	8b 10                	mov    (%eax),%edx
  8002a4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a7:	89 08                	mov    %ecx,(%eax)
  8002a9:	8b 02                	mov    (%edx),%eax
  8002ab:	8b 52 04             	mov    0x4(%edx),%edx
  8002ae:	eb 22                	jmp    8002d2 <getuint+0x38>
	else if (lflag)
  8002b0:	85 d2                	test   %edx,%edx
  8002b2:	74 10                	je     8002c4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b4:	8b 10                	mov    (%eax),%edx
  8002b6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b9:	89 08                	mov    %ecx,(%eax)
  8002bb:	8b 02                	mov    (%edx),%eax
  8002bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c2:	eb 0e                	jmp    8002d2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c4:	8b 10                	mov    (%eax),%edx
  8002c6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c9:	89 08                	mov    %ecx,(%eax)
  8002cb:	8b 02                	mov    (%edx),%eax
  8002cd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002d2:	5d                   	pop    %ebp
  8002d3:	c3                   	ret    

008002d4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
  8002d7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002da:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002de:	8b 10                	mov    (%eax),%edx
  8002e0:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e3:	73 0a                	jae    8002ef <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e8:	89 08                	mov    %ecx,(%eax)
  8002ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ed:	88 02                	mov    %al,(%edx)
}
  8002ef:	5d                   	pop    %ebp
  8002f0:	c3                   	ret    

008002f1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002fa:	50                   	push   %eax
  8002fb:	ff 75 10             	pushl  0x10(%ebp)
  8002fe:	ff 75 0c             	pushl  0xc(%ebp)
  800301:	ff 75 08             	pushl  0x8(%ebp)
  800304:	e8 05 00 00 00       	call   80030e <vprintfmt>
	va_end(ap);
}
  800309:	83 c4 10             	add    $0x10,%esp
  80030c:	c9                   	leave  
  80030d:	c3                   	ret    

0080030e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
  800314:	83 ec 2c             	sub    $0x2c,%esp
  800317:	8b 75 08             	mov    0x8(%ebp),%esi
  80031a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80031d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800320:	eb 12                	jmp    800334 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800322:	85 c0                	test   %eax,%eax
  800324:	0f 84 89 03 00 00    	je     8006b3 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80032a:	83 ec 08             	sub    $0x8,%esp
  80032d:	53                   	push   %ebx
  80032e:	50                   	push   %eax
  80032f:	ff d6                	call   *%esi
  800331:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800334:	83 c7 01             	add    $0x1,%edi
  800337:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80033b:	83 f8 25             	cmp    $0x25,%eax
  80033e:	75 e2                	jne    800322 <vprintfmt+0x14>
  800340:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800344:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80034b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800352:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800359:	ba 00 00 00 00       	mov    $0x0,%edx
  80035e:	eb 07                	jmp    800367 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800360:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800363:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800367:	8d 47 01             	lea    0x1(%edi),%eax
  80036a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036d:	0f b6 07             	movzbl (%edi),%eax
  800370:	0f b6 c8             	movzbl %al,%ecx
  800373:	83 e8 23             	sub    $0x23,%eax
  800376:	3c 55                	cmp    $0x55,%al
  800378:	0f 87 1a 03 00 00    	ja     800698 <vprintfmt+0x38a>
  80037e:	0f b6 c0             	movzbl %al,%eax
  800381:	ff 24 85 a0 29 80 00 	jmp    *0x8029a0(,%eax,4)
  800388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80038b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80038f:	eb d6                	jmp    800367 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800391:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800394:	b8 00 00 00 00       	mov    $0x0,%eax
  800399:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80039c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80039f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003a3:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003a6:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003a9:	83 fa 09             	cmp    $0x9,%edx
  8003ac:	77 39                	ja     8003e7 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ae:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003b1:	eb e9                	jmp    80039c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b6:	8d 48 04             	lea    0x4(%eax),%ecx
  8003b9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003bc:	8b 00                	mov    (%eax),%eax
  8003be:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003c4:	eb 27                	jmp    8003ed <vprintfmt+0xdf>
  8003c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c9:	85 c0                	test   %eax,%eax
  8003cb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d0:	0f 49 c8             	cmovns %eax,%ecx
  8003d3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d9:	eb 8c                	jmp    800367 <vprintfmt+0x59>
  8003db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003de:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003e5:	eb 80                	jmp    800367 <vprintfmt+0x59>
  8003e7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003ea:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003ed:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f1:	0f 89 70 ff ff ff    	jns    800367 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003f7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003fd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800404:	e9 5e ff ff ff       	jmp    800367 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800409:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80040f:	e9 53 ff ff ff       	jmp    800367 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8d 50 04             	lea    0x4(%eax),%edx
  80041a:	89 55 14             	mov    %edx,0x14(%ebp)
  80041d:	83 ec 08             	sub    $0x8,%esp
  800420:	53                   	push   %ebx
  800421:	ff 30                	pushl  (%eax)
  800423:	ff d6                	call   *%esi
			break;
  800425:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800428:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80042b:	e9 04 ff ff ff       	jmp    800334 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800430:	8b 45 14             	mov    0x14(%ebp),%eax
  800433:	8d 50 04             	lea    0x4(%eax),%edx
  800436:	89 55 14             	mov    %edx,0x14(%ebp)
  800439:	8b 00                	mov    (%eax),%eax
  80043b:	99                   	cltd   
  80043c:	31 d0                	xor    %edx,%eax
  80043e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800440:	83 f8 0f             	cmp    $0xf,%eax
  800443:	7f 0b                	jg     800450 <vprintfmt+0x142>
  800445:	8b 14 85 00 2b 80 00 	mov    0x802b00(,%eax,4),%edx
  80044c:	85 d2                	test   %edx,%edx
  80044e:	75 18                	jne    800468 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800450:	50                   	push   %eax
  800451:	68 73 28 80 00       	push   $0x802873
  800456:	53                   	push   %ebx
  800457:	56                   	push   %esi
  800458:	e8 94 fe ff ff       	call   8002f1 <printfmt>
  80045d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800460:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800463:	e9 cc fe ff ff       	jmp    800334 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800468:	52                   	push   %edx
  800469:	68 ad 2c 80 00       	push   $0x802cad
  80046e:	53                   	push   %ebx
  80046f:	56                   	push   %esi
  800470:	e8 7c fe ff ff       	call   8002f1 <printfmt>
  800475:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800478:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80047b:	e9 b4 fe ff ff       	jmp    800334 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800480:	8b 45 14             	mov    0x14(%ebp),%eax
  800483:	8d 50 04             	lea    0x4(%eax),%edx
  800486:	89 55 14             	mov    %edx,0x14(%ebp)
  800489:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80048b:	85 ff                	test   %edi,%edi
  80048d:	b8 6c 28 80 00       	mov    $0x80286c,%eax
  800492:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800495:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800499:	0f 8e 94 00 00 00    	jle    800533 <vprintfmt+0x225>
  80049f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004a3:	0f 84 98 00 00 00    	je     800541 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a9:	83 ec 08             	sub    $0x8,%esp
  8004ac:	ff 75 d0             	pushl  -0x30(%ebp)
  8004af:	57                   	push   %edi
  8004b0:	e8 86 02 00 00       	call   80073b <strnlen>
  8004b5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b8:	29 c1                	sub    %eax,%ecx
  8004ba:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004bd:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004c0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ca:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cc:	eb 0f                	jmp    8004dd <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	53                   	push   %ebx
  8004d2:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d5:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d7:	83 ef 01             	sub    $0x1,%edi
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	85 ff                	test   %edi,%edi
  8004df:	7f ed                	jg     8004ce <vprintfmt+0x1c0>
  8004e1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004e4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004e7:	85 c9                	test   %ecx,%ecx
  8004e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ee:	0f 49 c1             	cmovns %ecx,%eax
  8004f1:	29 c1                	sub    %eax,%ecx
  8004f3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004fc:	89 cb                	mov    %ecx,%ebx
  8004fe:	eb 4d                	jmp    80054d <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800500:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800504:	74 1b                	je     800521 <vprintfmt+0x213>
  800506:	0f be c0             	movsbl %al,%eax
  800509:	83 e8 20             	sub    $0x20,%eax
  80050c:	83 f8 5e             	cmp    $0x5e,%eax
  80050f:	76 10                	jbe    800521 <vprintfmt+0x213>
					putch('?', putdat);
  800511:	83 ec 08             	sub    $0x8,%esp
  800514:	ff 75 0c             	pushl  0xc(%ebp)
  800517:	6a 3f                	push   $0x3f
  800519:	ff 55 08             	call   *0x8(%ebp)
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	eb 0d                	jmp    80052e <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800521:	83 ec 08             	sub    $0x8,%esp
  800524:	ff 75 0c             	pushl  0xc(%ebp)
  800527:	52                   	push   %edx
  800528:	ff 55 08             	call   *0x8(%ebp)
  80052b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052e:	83 eb 01             	sub    $0x1,%ebx
  800531:	eb 1a                	jmp    80054d <vprintfmt+0x23f>
  800533:	89 75 08             	mov    %esi,0x8(%ebp)
  800536:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800539:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80053f:	eb 0c                	jmp    80054d <vprintfmt+0x23f>
  800541:	89 75 08             	mov    %esi,0x8(%ebp)
  800544:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800547:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80054d:	83 c7 01             	add    $0x1,%edi
  800550:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800554:	0f be d0             	movsbl %al,%edx
  800557:	85 d2                	test   %edx,%edx
  800559:	74 23                	je     80057e <vprintfmt+0x270>
  80055b:	85 f6                	test   %esi,%esi
  80055d:	78 a1                	js     800500 <vprintfmt+0x1f2>
  80055f:	83 ee 01             	sub    $0x1,%esi
  800562:	79 9c                	jns    800500 <vprintfmt+0x1f2>
  800564:	89 df                	mov    %ebx,%edi
  800566:	8b 75 08             	mov    0x8(%ebp),%esi
  800569:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80056c:	eb 18                	jmp    800586 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80056e:	83 ec 08             	sub    $0x8,%esp
  800571:	53                   	push   %ebx
  800572:	6a 20                	push   $0x20
  800574:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800576:	83 ef 01             	sub    $0x1,%edi
  800579:	83 c4 10             	add    $0x10,%esp
  80057c:	eb 08                	jmp    800586 <vprintfmt+0x278>
  80057e:	89 df                	mov    %ebx,%edi
  800580:	8b 75 08             	mov    0x8(%ebp),%esi
  800583:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800586:	85 ff                	test   %edi,%edi
  800588:	7f e4                	jg     80056e <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80058d:	e9 a2 fd ff ff       	jmp    800334 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800592:	83 fa 01             	cmp    $0x1,%edx
  800595:	7e 16                	jle    8005ad <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8d 50 08             	lea    0x8(%eax),%edx
  80059d:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a0:	8b 50 04             	mov    0x4(%eax),%edx
  8005a3:	8b 00                	mov    (%eax),%eax
  8005a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ab:	eb 32                	jmp    8005df <vprintfmt+0x2d1>
	else if (lflag)
  8005ad:	85 d2                	test   %edx,%edx
  8005af:	74 18                	je     8005c9 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8d 50 04             	lea    0x4(%eax),%edx
  8005b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ba:	8b 00                	mov    (%eax),%eax
  8005bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bf:	89 c1                	mov    %eax,%ecx
  8005c1:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c7:	eb 16                	jmp    8005df <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	8d 50 04             	lea    0x4(%eax),%edx
  8005cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d2:	8b 00                	mov    (%eax),%eax
  8005d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d7:	89 c1                	mov    %eax,%ecx
  8005d9:	c1 f9 1f             	sar    $0x1f,%ecx
  8005dc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005df:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005e2:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005ea:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ee:	79 74                	jns    800664 <vprintfmt+0x356>
				putch('-', putdat);
  8005f0:	83 ec 08             	sub    $0x8,%esp
  8005f3:	53                   	push   %ebx
  8005f4:	6a 2d                	push   $0x2d
  8005f6:	ff d6                	call   *%esi
				num = -(long long) num;
  8005f8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005fb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005fe:	f7 d8                	neg    %eax
  800600:	83 d2 00             	adc    $0x0,%edx
  800603:	f7 da                	neg    %edx
  800605:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800608:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80060d:	eb 55                	jmp    800664 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80060f:	8d 45 14             	lea    0x14(%ebp),%eax
  800612:	e8 83 fc ff ff       	call   80029a <getuint>
			base = 10;
  800617:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80061c:	eb 46                	jmp    800664 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80061e:	8d 45 14             	lea    0x14(%ebp),%eax
  800621:	e8 74 fc ff ff       	call   80029a <getuint>
			base = 8;
  800626:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80062b:	eb 37                	jmp    800664 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	53                   	push   %ebx
  800631:	6a 30                	push   $0x30
  800633:	ff d6                	call   *%esi
			putch('x', putdat);
  800635:	83 c4 08             	add    $0x8,%esp
  800638:	53                   	push   %ebx
  800639:	6a 78                	push   $0x78
  80063b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8d 50 04             	lea    0x4(%eax),%edx
  800643:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800646:	8b 00                	mov    (%eax),%eax
  800648:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80064d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800650:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800655:	eb 0d                	jmp    800664 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800657:	8d 45 14             	lea    0x14(%ebp),%eax
  80065a:	e8 3b fc ff ff       	call   80029a <getuint>
			base = 16;
  80065f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800664:	83 ec 0c             	sub    $0xc,%esp
  800667:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80066b:	57                   	push   %edi
  80066c:	ff 75 e0             	pushl  -0x20(%ebp)
  80066f:	51                   	push   %ecx
  800670:	52                   	push   %edx
  800671:	50                   	push   %eax
  800672:	89 da                	mov    %ebx,%edx
  800674:	89 f0                	mov    %esi,%eax
  800676:	e8 70 fb ff ff       	call   8001eb <printnum>
			break;
  80067b:	83 c4 20             	add    $0x20,%esp
  80067e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800681:	e9 ae fc ff ff       	jmp    800334 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	53                   	push   %ebx
  80068a:	51                   	push   %ecx
  80068b:	ff d6                	call   *%esi
			break;
  80068d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800690:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800693:	e9 9c fc ff ff       	jmp    800334 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800698:	83 ec 08             	sub    $0x8,%esp
  80069b:	53                   	push   %ebx
  80069c:	6a 25                	push   $0x25
  80069e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a0:	83 c4 10             	add    $0x10,%esp
  8006a3:	eb 03                	jmp    8006a8 <vprintfmt+0x39a>
  8006a5:	83 ef 01             	sub    $0x1,%edi
  8006a8:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006ac:	75 f7                	jne    8006a5 <vprintfmt+0x397>
  8006ae:	e9 81 fc ff ff       	jmp    800334 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b6:	5b                   	pop    %ebx
  8006b7:	5e                   	pop    %esi
  8006b8:	5f                   	pop    %edi
  8006b9:	5d                   	pop    %ebp
  8006ba:	c3                   	ret    

008006bb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006bb:	55                   	push   %ebp
  8006bc:	89 e5                	mov    %esp,%ebp
  8006be:	83 ec 18             	sub    $0x18,%esp
  8006c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ca:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ce:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d8:	85 c0                	test   %eax,%eax
  8006da:	74 26                	je     800702 <vsnprintf+0x47>
  8006dc:	85 d2                	test   %edx,%edx
  8006de:	7e 22                	jle    800702 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e0:	ff 75 14             	pushl  0x14(%ebp)
  8006e3:	ff 75 10             	pushl  0x10(%ebp)
  8006e6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e9:	50                   	push   %eax
  8006ea:	68 d4 02 80 00       	push   $0x8002d4
  8006ef:	e8 1a fc ff ff       	call   80030e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006fd:	83 c4 10             	add    $0x10,%esp
  800700:	eb 05                	jmp    800707 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800702:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800707:	c9                   	leave  
  800708:	c3                   	ret    

00800709 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800709:	55                   	push   %ebp
  80070a:	89 e5                	mov    %esp,%ebp
  80070c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800712:	50                   	push   %eax
  800713:	ff 75 10             	pushl  0x10(%ebp)
  800716:	ff 75 0c             	pushl  0xc(%ebp)
  800719:	ff 75 08             	pushl  0x8(%ebp)
  80071c:	e8 9a ff ff ff       	call   8006bb <vsnprintf>
	va_end(ap);

	return rc;
}
  800721:	c9                   	leave  
  800722:	c3                   	ret    

00800723 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800729:	b8 00 00 00 00       	mov    $0x0,%eax
  80072e:	eb 03                	jmp    800733 <strlen+0x10>
		n++;
  800730:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800733:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800737:	75 f7                	jne    800730 <strlen+0xd>
		n++;
	return n;
}
  800739:	5d                   	pop    %ebp
  80073a:	c3                   	ret    

0080073b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800741:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800744:	ba 00 00 00 00       	mov    $0x0,%edx
  800749:	eb 03                	jmp    80074e <strnlen+0x13>
		n++;
  80074b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074e:	39 c2                	cmp    %eax,%edx
  800750:	74 08                	je     80075a <strnlen+0x1f>
  800752:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800756:	75 f3                	jne    80074b <strnlen+0x10>
  800758:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80075a:	5d                   	pop    %ebp
  80075b:	c3                   	ret    

0080075c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	53                   	push   %ebx
  800760:	8b 45 08             	mov    0x8(%ebp),%eax
  800763:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800766:	89 c2                	mov    %eax,%edx
  800768:	83 c2 01             	add    $0x1,%edx
  80076b:	83 c1 01             	add    $0x1,%ecx
  80076e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800772:	88 5a ff             	mov    %bl,-0x1(%edx)
  800775:	84 db                	test   %bl,%bl
  800777:	75 ef                	jne    800768 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800779:	5b                   	pop    %ebx
  80077a:	5d                   	pop    %ebp
  80077b:	c3                   	ret    

0080077c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	53                   	push   %ebx
  800780:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800783:	53                   	push   %ebx
  800784:	e8 9a ff ff ff       	call   800723 <strlen>
  800789:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80078c:	ff 75 0c             	pushl  0xc(%ebp)
  80078f:	01 d8                	add    %ebx,%eax
  800791:	50                   	push   %eax
  800792:	e8 c5 ff ff ff       	call   80075c <strcpy>
	return dst;
}
  800797:	89 d8                	mov    %ebx,%eax
  800799:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80079c:	c9                   	leave  
  80079d:	c3                   	ret    

0080079e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	56                   	push   %esi
  8007a2:	53                   	push   %ebx
  8007a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a9:	89 f3                	mov    %esi,%ebx
  8007ab:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ae:	89 f2                	mov    %esi,%edx
  8007b0:	eb 0f                	jmp    8007c1 <strncpy+0x23>
		*dst++ = *src;
  8007b2:	83 c2 01             	add    $0x1,%edx
  8007b5:	0f b6 01             	movzbl (%ecx),%eax
  8007b8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007bb:	80 39 01             	cmpb   $0x1,(%ecx)
  8007be:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c1:	39 da                	cmp    %ebx,%edx
  8007c3:	75 ed                	jne    8007b2 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007c5:	89 f0                	mov    %esi,%eax
  8007c7:	5b                   	pop    %ebx
  8007c8:	5e                   	pop    %esi
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	56                   	push   %esi
  8007cf:	53                   	push   %ebx
  8007d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d6:	8b 55 10             	mov    0x10(%ebp),%edx
  8007d9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007db:	85 d2                	test   %edx,%edx
  8007dd:	74 21                	je     800800 <strlcpy+0x35>
  8007df:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007e3:	89 f2                	mov    %esi,%edx
  8007e5:	eb 09                	jmp    8007f0 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e7:	83 c2 01             	add    $0x1,%edx
  8007ea:	83 c1 01             	add    $0x1,%ecx
  8007ed:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007f0:	39 c2                	cmp    %eax,%edx
  8007f2:	74 09                	je     8007fd <strlcpy+0x32>
  8007f4:	0f b6 19             	movzbl (%ecx),%ebx
  8007f7:	84 db                	test   %bl,%bl
  8007f9:	75 ec                	jne    8007e7 <strlcpy+0x1c>
  8007fb:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007fd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800800:	29 f0                	sub    %esi,%eax
}
  800802:	5b                   	pop    %ebx
  800803:	5e                   	pop    %esi
  800804:	5d                   	pop    %ebp
  800805:	c3                   	ret    

00800806 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80080f:	eb 06                	jmp    800817 <strcmp+0x11>
		p++, q++;
  800811:	83 c1 01             	add    $0x1,%ecx
  800814:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800817:	0f b6 01             	movzbl (%ecx),%eax
  80081a:	84 c0                	test   %al,%al
  80081c:	74 04                	je     800822 <strcmp+0x1c>
  80081e:	3a 02                	cmp    (%edx),%al
  800820:	74 ef                	je     800811 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800822:	0f b6 c0             	movzbl %al,%eax
  800825:	0f b6 12             	movzbl (%edx),%edx
  800828:	29 d0                	sub    %edx,%eax
}
  80082a:	5d                   	pop    %ebp
  80082b:	c3                   	ret    

0080082c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	53                   	push   %ebx
  800830:	8b 45 08             	mov    0x8(%ebp),%eax
  800833:	8b 55 0c             	mov    0xc(%ebp),%edx
  800836:	89 c3                	mov    %eax,%ebx
  800838:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80083b:	eb 06                	jmp    800843 <strncmp+0x17>
		n--, p++, q++;
  80083d:	83 c0 01             	add    $0x1,%eax
  800840:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800843:	39 d8                	cmp    %ebx,%eax
  800845:	74 15                	je     80085c <strncmp+0x30>
  800847:	0f b6 08             	movzbl (%eax),%ecx
  80084a:	84 c9                	test   %cl,%cl
  80084c:	74 04                	je     800852 <strncmp+0x26>
  80084e:	3a 0a                	cmp    (%edx),%cl
  800850:	74 eb                	je     80083d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800852:	0f b6 00             	movzbl (%eax),%eax
  800855:	0f b6 12             	movzbl (%edx),%edx
  800858:	29 d0                	sub    %edx,%eax
  80085a:	eb 05                	jmp    800861 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80085c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800861:	5b                   	pop    %ebx
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	8b 45 08             	mov    0x8(%ebp),%eax
  80086a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086e:	eb 07                	jmp    800877 <strchr+0x13>
		if (*s == c)
  800870:	38 ca                	cmp    %cl,%dl
  800872:	74 0f                	je     800883 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800874:	83 c0 01             	add    $0x1,%eax
  800877:	0f b6 10             	movzbl (%eax),%edx
  80087a:	84 d2                	test   %dl,%dl
  80087c:	75 f2                	jne    800870 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80087e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800883:	5d                   	pop    %ebp
  800884:	c3                   	ret    

00800885 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	8b 45 08             	mov    0x8(%ebp),%eax
  80088b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088f:	eb 03                	jmp    800894 <strfind+0xf>
  800891:	83 c0 01             	add    $0x1,%eax
  800894:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800897:	38 ca                	cmp    %cl,%dl
  800899:	74 04                	je     80089f <strfind+0x1a>
  80089b:	84 d2                	test   %dl,%dl
  80089d:	75 f2                	jne    800891 <strfind+0xc>
			break;
	return (char *) s;
}
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	57                   	push   %edi
  8008a5:	56                   	push   %esi
  8008a6:	53                   	push   %ebx
  8008a7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ad:	85 c9                	test   %ecx,%ecx
  8008af:	74 36                	je     8008e7 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008b1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b7:	75 28                	jne    8008e1 <memset+0x40>
  8008b9:	f6 c1 03             	test   $0x3,%cl
  8008bc:	75 23                	jne    8008e1 <memset+0x40>
		c &= 0xFF;
  8008be:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008c2:	89 d3                	mov    %edx,%ebx
  8008c4:	c1 e3 08             	shl    $0x8,%ebx
  8008c7:	89 d6                	mov    %edx,%esi
  8008c9:	c1 e6 18             	shl    $0x18,%esi
  8008cc:	89 d0                	mov    %edx,%eax
  8008ce:	c1 e0 10             	shl    $0x10,%eax
  8008d1:	09 f0                	or     %esi,%eax
  8008d3:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008d5:	89 d8                	mov    %ebx,%eax
  8008d7:	09 d0                	or     %edx,%eax
  8008d9:	c1 e9 02             	shr    $0x2,%ecx
  8008dc:	fc                   	cld    
  8008dd:	f3 ab                	rep stos %eax,%es:(%edi)
  8008df:	eb 06                	jmp    8008e7 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e4:	fc                   	cld    
  8008e5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008e7:	89 f8                	mov    %edi,%eax
  8008e9:	5b                   	pop    %ebx
  8008ea:	5e                   	pop    %esi
  8008eb:	5f                   	pop    %edi
  8008ec:	5d                   	pop    %ebp
  8008ed:	c3                   	ret    

008008ee <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	57                   	push   %edi
  8008f2:	56                   	push   %esi
  8008f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008fc:	39 c6                	cmp    %eax,%esi
  8008fe:	73 35                	jae    800935 <memmove+0x47>
  800900:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800903:	39 d0                	cmp    %edx,%eax
  800905:	73 2e                	jae    800935 <memmove+0x47>
		s += n;
		d += n;
  800907:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090a:	89 d6                	mov    %edx,%esi
  80090c:	09 fe                	or     %edi,%esi
  80090e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800914:	75 13                	jne    800929 <memmove+0x3b>
  800916:	f6 c1 03             	test   $0x3,%cl
  800919:	75 0e                	jne    800929 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80091b:	83 ef 04             	sub    $0x4,%edi
  80091e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800921:	c1 e9 02             	shr    $0x2,%ecx
  800924:	fd                   	std    
  800925:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800927:	eb 09                	jmp    800932 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800929:	83 ef 01             	sub    $0x1,%edi
  80092c:	8d 72 ff             	lea    -0x1(%edx),%esi
  80092f:	fd                   	std    
  800930:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800932:	fc                   	cld    
  800933:	eb 1d                	jmp    800952 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800935:	89 f2                	mov    %esi,%edx
  800937:	09 c2                	or     %eax,%edx
  800939:	f6 c2 03             	test   $0x3,%dl
  80093c:	75 0f                	jne    80094d <memmove+0x5f>
  80093e:	f6 c1 03             	test   $0x3,%cl
  800941:	75 0a                	jne    80094d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800943:	c1 e9 02             	shr    $0x2,%ecx
  800946:	89 c7                	mov    %eax,%edi
  800948:	fc                   	cld    
  800949:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094b:	eb 05                	jmp    800952 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80094d:	89 c7                	mov    %eax,%edi
  80094f:	fc                   	cld    
  800950:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800952:	5e                   	pop    %esi
  800953:	5f                   	pop    %edi
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800959:	ff 75 10             	pushl  0x10(%ebp)
  80095c:	ff 75 0c             	pushl  0xc(%ebp)
  80095f:	ff 75 08             	pushl  0x8(%ebp)
  800962:	e8 87 ff ff ff       	call   8008ee <memmove>
}
  800967:	c9                   	leave  
  800968:	c3                   	ret    

00800969 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	56                   	push   %esi
  80096d:	53                   	push   %ebx
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	8b 55 0c             	mov    0xc(%ebp),%edx
  800974:	89 c6                	mov    %eax,%esi
  800976:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800979:	eb 1a                	jmp    800995 <memcmp+0x2c>
		if (*s1 != *s2)
  80097b:	0f b6 08             	movzbl (%eax),%ecx
  80097e:	0f b6 1a             	movzbl (%edx),%ebx
  800981:	38 d9                	cmp    %bl,%cl
  800983:	74 0a                	je     80098f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800985:	0f b6 c1             	movzbl %cl,%eax
  800988:	0f b6 db             	movzbl %bl,%ebx
  80098b:	29 d8                	sub    %ebx,%eax
  80098d:	eb 0f                	jmp    80099e <memcmp+0x35>
		s1++, s2++;
  80098f:	83 c0 01             	add    $0x1,%eax
  800992:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800995:	39 f0                	cmp    %esi,%eax
  800997:	75 e2                	jne    80097b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800999:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099e:	5b                   	pop    %ebx
  80099f:	5e                   	pop    %esi
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	53                   	push   %ebx
  8009a6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009a9:	89 c1                	mov    %eax,%ecx
  8009ab:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ae:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b2:	eb 0a                	jmp    8009be <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b4:	0f b6 10             	movzbl (%eax),%edx
  8009b7:	39 da                	cmp    %ebx,%edx
  8009b9:	74 07                	je     8009c2 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009bb:	83 c0 01             	add    $0x1,%eax
  8009be:	39 c8                	cmp    %ecx,%eax
  8009c0:	72 f2                	jb     8009b4 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009c2:	5b                   	pop    %ebx
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	57                   	push   %edi
  8009c9:	56                   	push   %esi
  8009ca:	53                   	push   %ebx
  8009cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d1:	eb 03                	jmp    8009d6 <strtol+0x11>
		s++;
  8009d3:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d6:	0f b6 01             	movzbl (%ecx),%eax
  8009d9:	3c 20                	cmp    $0x20,%al
  8009db:	74 f6                	je     8009d3 <strtol+0xe>
  8009dd:	3c 09                	cmp    $0x9,%al
  8009df:	74 f2                	je     8009d3 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009e1:	3c 2b                	cmp    $0x2b,%al
  8009e3:	75 0a                	jne    8009ef <strtol+0x2a>
		s++;
  8009e5:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e8:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ed:	eb 11                	jmp    800a00 <strtol+0x3b>
  8009ef:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009f4:	3c 2d                	cmp    $0x2d,%al
  8009f6:	75 08                	jne    800a00 <strtol+0x3b>
		s++, neg = 1;
  8009f8:	83 c1 01             	add    $0x1,%ecx
  8009fb:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a00:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a06:	75 15                	jne    800a1d <strtol+0x58>
  800a08:	80 39 30             	cmpb   $0x30,(%ecx)
  800a0b:	75 10                	jne    800a1d <strtol+0x58>
  800a0d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a11:	75 7c                	jne    800a8f <strtol+0xca>
		s += 2, base = 16;
  800a13:	83 c1 02             	add    $0x2,%ecx
  800a16:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a1b:	eb 16                	jmp    800a33 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a1d:	85 db                	test   %ebx,%ebx
  800a1f:	75 12                	jne    800a33 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a21:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a26:	80 39 30             	cmpb   $0x30,(%ecx)
  800a29:	75 08                	jne    800a33 <strtol+0x6e>
		s++, base = 8;
  800a2b:	83 c1 01             	add    $0x1,%ecx
  800a2e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a33:	b8 00 00 00 00       	mov    $0x0,%eax
  800a38:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a3b:	0f b6 11             	movzbl (%ecx),%edx
  800a3e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a41:	89 f3                	mov    %esi,%ebx
  800a43:	80 fb 09             	cmp    $0x9,%bl
  800a46:	77 08                	ja     800a50 <strtol+0x8b>
			dig = *s - '0';
  800a48:	0f be d2             	movsbl %dl,%edx
  800a4b:	83 ea 30             	sub    $0x30,%edx
  800a4e:	eb 22                	jmp    800a72 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a50:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a53:	89 f3                	mov    %esi,%ebx
  800a55:	80 fb 19             	cmp    $0x19,%bl
  800a58:	77 08                	ja     800a62 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a5a:	0f be d2             	movsbl %dl,%edx
  800a5d:	83 ea 57             	sub    $0x57,%edx
  800a60:	eb 10                	jmp    800a72 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a62:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a65:	89 f3                	mov    %esi,%ebx
  800a67:	80 fb 19             	cmp    $0x19,%bl
  800a6a:	77 16                	ja     800a82 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a6c:	0f be d2             	movsbl %dl,%edx
  800a6f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a72:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a75:	7d 0b                	jge    800a82 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a77:	83 c1 01             	add    $0x1,%ecx
  800a7a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a7e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a80:	eb b9                	jmp    800a3b <strtol+0x76>

	if (endptr)
  800a82:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a86:	74 0d                	je     800a95 <strtol+0xd0>
		*endptr = (char *) s;
  800a88:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8b:	89 0e                	mov    %ecx,(%esi)
  800a8d:	eb 06                	jmp    800a95 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a8f:	85 db                	test   %ebx,%ebx
  800a91:	74 98                	je     800a2b <strtol+0x66>
  800a93:	eb 9e                	jmp    800a33 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a95:	89 c2                	mov    %eax,%edx
  800a97:	f7 da                	neg    %edx
  800a99:	85 ff                	test   %edi,%edi
  800a9b:	0f 45 c2             	cmovne %edx,%eax
}
  800a9e:	5b                   	pop    %ebx
  800a9f:	5e                   	pop    %esi
  800aa0:	5f                   	pop    %edi
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	57                   	push   %edi
  800aa7:	56                   	push   %esi
  800aa8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa9:	b8 00 00 00 00       	mov    $0x0,%eax
  800aae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab4:	89 c3                	mov    %eax,%ebx
  800ab6:	89 c7                	mov    %eax,%edi
  800ab8:	89 c6                	mov    %eax,%esi
  800aba:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800abc:	5b                   	pop    %ebx
  800abd:	5e                   	pop    %esi
  800abe:	5f                   	pop    %edi
  800abf:	5d                   	pop    %ebp
  800ac0:	c3                   	ret    

00800ac1 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	57                   	push   %edi
  800ac5:	56                   	push   %esi
  800ac6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac7:	ba 00 00 00 00       	mov    $0x0,%edx
  800acc:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad1:	89 d1                	mov    %edx,%ecx
  800ad3:	89 d3                	mov    %edx,%ebx
  800ad5:	89 d7                	mov    %edx,%edi
  800ad7:	89 d6                	mov    %edx,%esi
  800ad9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800adb:	5b                   	pop    %ebx
  800adc:	5e                   	pop    %esi
  800add:	5f                   	pop    %edi
  800ade:	5d                   	pop    %ebp
  800adf:	c3                   	ret    

00800ae0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	57                   	push   %edi
  800ae4:	56                   	push   %esi
  800ae5:	53                   	push   %ebx
  800ae6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aee:	b8 03 00 00 00       	mov    $0x3,%eax
  800af3:	8b 55 08             	mov    0x8(%ebp),%edx
  800af6:	89 cb                	mov    %ecx,%ebx
  800af8:	89 cf                	mov    %ecx,%edi
  800afa:	89 ce                	mov    %ecx,%esi
  800afc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800afe:	85 c0                	test   %eax,%eax
  800b00:	7e 17                	jle    800b19 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b02:	83 ec 0c             	sub    $0xc,%esp
  800b05:	50                   	push   %eax
  800b06:	6a 03                	push   $0x3
  800b08:	68 5f 2b 80 00       	push   $0x802b5f
  800b0d:	6a 23                	push   $0x23
  800b0f:	68 7c 2b 80 00       	push   $0x802b7c
  800b14:	e8 e5 f5 ff ff       	call   8000fe <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b1c:	5b                   	pop    %ebx
  800b1d:	5e                   	pop    %esi
  800b1e:	5f                   	pop    %edi
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800b2c:	b8 02 00 00 00       	mov    $0x2,%eax
  800b31:	89 d1                	mov    %edx,%ecx
  800b33:	89 d3                	mov    %edx,%ebx
  800b35:	89 d7                	mov    %edx,%edi
  800b37:	89 d6                	mov    %edx,%esi
  800b39:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b3b:	5b                   	pop    %ebx
  800b3c:	5e                   	pop    %esi
  800b3d:	5f                   	pop    %edi
  800b3e:	5d                   	pop    %ebp
  800b3f:	c3                   	ret    

00800b40 <sys_yield>:

void
sys_yield(void)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b46:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b50:	89 d1                	mov    %edx,%ecx
  800b52:	89 d3                	mov    %edx,%ebx
  800b54:	89 d7                	mov    %edx,%edi
  800b56:	89 d6                	mov    %edx,%esi
  800b58:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5f                   	pop    %edi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
  800b65:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b68:	be 00 00 00 00       	mov    $0x0,%esi
  800b6d:	b8 04 00 00 00       	mov    $0x4,%eax
  800b72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b75:	8b 55 08             	mov    0x8(%ebp),%edx
  800b78:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b7b:	89 f7                	mov    %esi,%edi
  800b7d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b7f:	85 c0                	test   %eax,%eax
  800b81:	7e 17                	jle    800b9a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b83:	83 ec 0c             	sub    $0xc,%esp
  800b86:	50                   	push   %eax
  800b87:	6a 04                	push   $0x4
  800b89:	68 5f 2b 80 00       	push   $0x802b5f
  800b8e:	6a 23                	push   $0x23
  800b90:	68 7c 2b 80 00       	push   $0x802b7c
  800b95:	e8 64 f5 ff ff       	call   8000fe <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9d:	5b                   	pop    %ebx
  800b9e:	5e                   	pop    %esi
  800b9f:	5f                   	pop    %edi
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bab:	b8 05 00 00 00       	mov    $0x5,%eax
  800bb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bbc:	8b 75 18             	mov    0x18(%ebp),%esi
  800bbf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc1:	85 c0                	test   %eax,%eax
  800bc3:	7e 17                	jle    800bdc <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc5:	83 ec 0c             	sub    $0xc,%esp
  800bc8:	50                   	push   %eax
  800bc9:	6a 05                	push   $0x5
  800bcb:	68 5f 2b 80 00       	push   $0x802b5f
  800bd0:	6a 23                	push   $0x23
  800bd2:	68 7c 2b 80 00       	push   $0x802b7c
  800bd7:	e8 22 f5 ff ff       	call   8000fe <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5f                   	pop    %edi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	57                   	push   %edi
  800be8:	56                   	push   %esi
  800be9:	53                   	push   %ebx
  800bea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bed:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf2:	b8 06 00 00 00       	mov    $0x6,%eax
  800bf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfd:	89 df                	mov    %ebx,%edi
  800bff:	89 de                	mov    %ebx,%esi
  800c01:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c03:	85 c0                	test   %eax,%eax
  800c05:	7e 17                	jle    800c1e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c07:	83 ec 0c             	sub    $0xc,%esp
  800c0a:	50                   	push   %eax
  800c0b:	6a 06                	push   $0x6
  800c0d:	68 5f 2b 80 00       	push   $0x802b5f
  800c12:	6a 23                	push   $0x23
  800c14:	68 7c 2b 80 00       	push   $0x802b7c
  800c19:	e8 e0 f4 ff ff       	call   8000fe <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
  800c2c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c34:	b8 08 00 00 00       	mov    $0x8,%eax
  800c39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3f:	89 df                	mov    %ebx,%edi
  800c41:	89 de                	mov    %ebx,%esi
  800c43:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c45:	85 c0                	test   %eax,%eax
  800c47:	7e 17                	jle    800c60 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c49:	83 ec 0c             	sub    $0xc,%esp
  800c4c:	50                   	push   %eax
  800c4d:	6a 08                	push   $0x8
  800c4f:	68 5f 2b 80 00       	push   $0x802b5f
  800c54:	6a 23                	push   $0x23
  800c56:	68 7c 2b 80 00       	push   $0x802b7c
  800c5b:	e8 9e f4 ff ff       	call   8000fe <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5f                   	pop    %edi
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	57                   	push   %edi
  800c6c:	56                   	push   %esi
  800c6d:	53                   	push   %ebx
  800c6e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c71:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c76:	b8 09 00 00 00       	mov    $0x9,%eax
  800c7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c81:	89 df                	mov    %ebx,%edi
  800c83:	89 de                	mov    %ebx,%esi
  800c85:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c87:	85 c0                	test   %eax,%eax
  800c89:	7e 17                	jle    800ca2 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8b:	83 ec 0c             	sub    $0xc,%esp
  800c8e:	50                   	push   %eax
  800c8f:	6a 09                	push   $0x9
  800c91:	68 5f 2b 80 00       	push   $0x802b5f
  800c96:	6a 23                	push   $0x23
  800c98:	68 7c 2b 80 00       	push   $0x802b7c
  800c9d:	e8 5c f4 ff ff       	call   8000fe <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ca2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	57                   	push   %edi
  800cae:	56                   	push   %esi
  800caf:	53                   	push   %ebx
  800cb0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc3:	89 df                	mov    %ebx,%edi
  800cc5:	89 de                	mov    %ebx,%esi
  800cc7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	7e 17                	jle    800ce4 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccd:	83 ec 0c             	sub    $0xc,%esp
  800cd0:	50                   	push   %eax
  800cd1:	6a 0a                	push   $0xa
  800cd3:	68 5f 2b 80 00       	push   $0x802b5f
  800cd8:	6a 23                	push   $0x23
  800cda:	68 7c 2b 80 00       	push   $0x802b7c
  800cdf:	e8 1a f4 ff ff       	call   8000fe <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ce4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf2:	be 00 00 00 00       	mov    $0x0,%esi
  800cf7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cff:	8b 55 08             	mov    0x8(%ebp),%edx
  800d02:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d05:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d08:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d0a:	5b                   	pop    %ebx
  800d0b:	5e                   	pop    %esi
  800d0c:	5f                   	pop    %edi
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	57                   	push   %edi
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
  800d15:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d18:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d1d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d22:	8b 55 08             	mov    0x8(%ebp),%edx
  800d25:	89 cb                	mov    %ecx,%ebx
  800d27:	89 cf                	mov    %ecx,%edi
  800d29:	89 ce                	mov    %ecx,%esi
  800d2b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d2d:	85 c0                	test   %eax,%eax
  800d2f:	7e 17                	jle    800d48 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d31:	83 ec 0c             	sub    $0xc,%esp
  800d34:	50                   	push   %eax
  800d35:	6a 0d                	push   $0xd
  800d37:	68 5f 2b 80 00       	push   $0x802b5f
  800d3c:	6a 23                	push   $0x23
  800d3e:	68 7c 2b 80 00       	push   $0x802b7c
  800d43:	e8 b6 f3 ff ff       	call   8000fe <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4b:	5b                   	pop    %ebx
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d56:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d5b:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d60:	8b 55 08             	mov    0x8(%ebp),%edx
  800d63:	89 cb                	mov    %ecx,%ebx
  800d65:	89 cf                	mov    %ecx,%edi
  800d67:	89 ce                	mov    %ecx,%esi
  800d69:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	57                   	push   %edi
  800d74:	56                   	push   %esi
  800d75:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d76:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d7b:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d80:	8b 55 08             	mov    0x8(%ebp),%edx
  800d83:	89 cb                	mov    %ecx,%ebx
  800d85:	89 cf                	mov    %ecx,%edi
  800d87:	89 ce                	mov    %ecx,%esi
  800d89:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800d8b:	5b                   	pop    %ebx
  800d8c:	5e                   	pop    %esi
  800d8d:	5f                   	pop    %edi
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	53                   	push   %ebx
  800d94:	83 ec 04             	sub    $0x4,%esp
  800d97:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d9a:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800d9c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800da0:	74 11                	je     800db3 <pgfault+0x23>
  800da2:	89 d8                	mov    %ebx,%eax
  800da4:	c1 e8 0c             	shr    $0xc,%eax
  800da7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dae:	f6 c4 08             	test   $0x8,%ah
  800db1:	75 14                	jne    800dc7 <pgfault+0x37>
		panic("faulting access");
  800db3:	83 ec 04             	sub    $0x4,%esp
  800db6:	68 8a 2b 80 00       	push   $0x802b8a
  800dbb:	6a 1e                	push   $0x1e
  800dbd:	68 9a 2b 80 00       	push   $0x802b9a
  800dc2:	e8 37 f3 ff ff       	call   8000fe <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800dc7:	83 ec 04             	sub    $0x4,%esp
  800dca:	6a 07                	push   $0x7
  800dcc:	68 00 f0 7f 00       	push   $0x7ff000
  800dd1:	6a 00                	push   $0x0
  800dd3:	e8 87 fd ff ff       	call   800b5f <sys_page_alloc>
	if (r < 0) {
  800dd8:	83 c4 10             	add    $0x10,%esp
  800ddb:	85 c0                	test   %eax,%eax
  800ddd:	79 12                	jns    800df1 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800ddf:	50                   	push   %eax
  800de0:	68 a5 2b 80 00       	push   $0x802ba5
  800de5:	6a 2c                	push   $0x2c
  800de7:	68 9a 2b 80 00       	push   $0x802b9a
  800dec:	e8 0d f3 ff ff       	call   8000fe <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800df1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800df7:	83 ec 04             	sub    $0x4,%esp
  800dfa:	68 00 10 00 00       	push   $0x1000
  800dff:	53                   	push   %ebx
  800e00:	68 00 f0 7f 00       	push   $0x7ff000
  800e05:	e8 4c fb ff ff       	call   800956 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e0a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e11:	53                   	push   %ebx
  800e12:	6a 00                	push   $0x0
  800e14:	68 00 f0 7f 00       	push   $0x7ff000
  800e19:	6a 00                	push   $0x0
  800e1b:	e8 82 fd ff ff       	call   800ba2 <sys_page_map>
	if (r < 0) {
  800e20:	83 c4 20             	add    $0x20,%esp
  800e23:	85 c0                	test   %eax,%eax
  800e25:	79 12                	jns    800e39 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e27:	50                   	push   %eax
  800e28:	68 a5 2b 80 00       	push   $0x802ba5
  800e2d:	6a 33                	push   $0x33
  800e2f:	68 9a 2b 80 00       	push   $0x802b9a
  800e34:	e8 c5 f2 ff ff       	call   8000fe <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e39:	83 ec 08             	sub    $0x8,%esp
  800e3c:	68 00 f0 7f 00       	push   $0x7ff000
  800e41:	6a 00                	push   $0x0
  800e43:	e8 9c fd ff ff       	call   800be4 <sys_page_unmap>
	if (r < 0) {
  800e48:	83 c4 10             	add    $0x10,%esp
  800e4b:	85 c0                	test   %eax,%eax
  800e4d:	79 12                	jns    800e61 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e4f:	50                   	push   %eax
  800e50:	68 a5 2b 80 00       	push   $0x802ba5
  800e55:	6a 37                	push   $0x37
  800e57:	68 9a 2b 80 00       	push   $0x802b9a
  800e5c:	e8 9d f2 ff ff       	call   8000fe <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e64:	c9                   	leave  
  800e65:	c3                   	ret    

00800e66 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	57                   	push   %edi
  800e6a:	56                   	push   %esi
  800e6b:	53                   	push   %ebx
  800e6c:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e6f:	68 90 0d 80 00       	push   $0x800d90
  800e74:	e8 e3 14 00 00       	call   80235c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e79:	b8 07 00 00 00       	mov    $0x7,%eax
  800e7e:	cd 30                	int    $0x30
  800e80:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800e83:	83 c4 10             	add    $0x10,%esp
  800e86:	85 c0                	test   %eax,%eax
  800e88:	79 17                	jns    800ea1 <fork+0x3b>
		panic("fork fault %e");
  800e8a:	83 ec 04             	sub    $0x4,%esp
  800e8d:	68 be 2b 80 00       	push   $0x802bbe
  800e92:	68 84 00 00 00       	push   $0x84
  800e97:	68 9a 2b 80 00       	push   $0x802b9a
  800e9c:	e8 5d f2 ff ff       	call   8000fe <_panic>
  800ea1:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800ea3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ea7:	75 24                	jne    800ecd <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ea9:	e8 73 fc ff ff       	call   800b21 <sys_getenvid>
  800eae:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eb3:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800eb9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ebe:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800ec3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec8:	e9 64 01 00 00       	jmp    801031 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800ecd:	83 ec 04             	sub    $0x4,%esp
  800ed0:	6a 07                	push   $0x7
  800ed2:	68 00 f0 bf ee       	push   $0xeebff000
  800ed7:	ff 75 e4             	pushl  -0x1c(%ebp)
  800eda:	e8 80 fc ff ff       	call   800b5f <sys_page_alloc>
  800edf:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800ee2:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ee7:	89 d8                	mov    %ebx,%eax
  800ee9:	c1 e8 16             	shr    $0x16,%eax
  800eec:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ef3:	a8 01                	test   $0x1,%al
  800ef5:	0f 84 fc 00 00 00    	je     800ff7 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800efb:	89 d8                	mov    %ebx,%eax
  800efd:	c1 e8 0c             	shr    $0xc,%eax
  800f00:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f07:	f6 c2 01             	test   $0x1,%dl
  800f0a:	0f 84 e7 00 00 00    	je     800ff7 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f10:	89 c6                	mov    %eax,%esi
  800f12:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f15:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f1c:	f6 c6 04             	test   $0x4,%dh
  800f1f:	74 39                	je     800f5a <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f21:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f28:	83 ec 0c             	sub    $0xc,%esp
  800f2b:	25 07 0e 00 00       	and    $0xe07,%eax
  800f30:	50                   	push   %eax
  800f31:	56                   	push   %esi
  800f32:	57                   	push   %edi
  800f33:	56                   	push   %esi
  800f34:	6a 00                	push   $0x0
  800f36:	e8 67 fc ff ff       	call   800ba2 <sys_page_map>
		if (r < 0) {
  800f3b:	83 c4 20             	add    $0x20,%esp
  800f3e:	85 c0                	test   %eax,%eax
  800f40:	0f 89 b1 00 00 00    	jns    800ff7 <fork+0x191>
		    	panic("sys page map fault %e");
  800f46:	83 ec 04             	sub    $0x4,%esp
  800f49:	68 cc 2b 80 00       	push   $0x802bcc
  800f4e:	6a 54                	push   $0x54
  800f50:	68 9a 2b 80 00       	push   $0x802b9a
  800f55:	e8 a4 f1 ff ff       	call   8000fe <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f5a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f61:	f6 c2 02             	test   $0x2,%dl
  800f64:	75 0c                	jne    800f72 <fork+0x10c>
  800f66:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f6d:	f6 c4 08             	test   $0x8,%ah
  800f70:	74 5b                	je     800fcd <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f72:	83 ec 0c             	sub    $0xc,%esp
  800f75:	68 05 08 00 00       	push   $0x805
  800f7a:	56                   	push   %esi
  800f7b:	57                   	push   %edi
  800f7c:	56                   	push   %esi
  800f7d:	6a 00                	push   $0x0
  800f7f:	e8 1e fc ff ff       	call   800ba2 <sys_page_map>
		if (r < 0) {
  800f84:	83 c4 20             	add    $0x20,%esp
  800f87:	85 c0                	test   %eax,%eax
  800f89:	79 14                	jns    800f9f <fork+0x139>
		    	panic("sys page map fault %e");
  800f8b:	83 ec 04             	sub    $0x4,%esp
  800f8e:	68 cc 2b 80 00       	push   $0x802bcc
  800f93:	6a 5b                	push   $0x5b
  800f95:	68 9a 2b 80 00       	push   $0x802b9a
  800f9a:	e8 5f f1 ff ff       	call   8000fe <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800f9f:	83 ec 0c             	sub    $0xc,%esp
  800fa2:	68 05 08 00 00       	push   $0x805
  800fa7:	56                   	push   %esi
  800fa8:	6a 00                	push   $0x0
  800faa:	56                   	push   %esi
  800fab:	6a 00                	push   $0x0
  800fad:	e8 f0 fb ff ff       	call   800ba2 <sys_page_map>
		if (r < 0) {
  800fb2:	83 c4 20             	add    $0x20,%esp
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	79 3e                	jns    800ff7 <fork+0x191>
		    	panic("sys page map fault %e");
  800fb9:	83 ec 04             	sub    $0x4,%esp
  800fbc:	68 cc 2b 80 00       	push   $0x802bcc
  800fc1:	6a 5f                	push   $0x5f
  800fc3:	68 9a 2b 80 00       	push   $0x802b9a
  800fc8:	e8 31 f1 ff ff       	call   8000fe <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800fcd:	83 ec 0c             	sub    $0xc,%esp
  800fd0:	6a 05                	push   $0x5
  800fd2:	56                   	push   %esi
  800fd3:	57                   	push   %edi
  800fd4:	56                   	push   %esi
  800fd5:	6a 00                	push   $0x0
  800fd7:	e8 c6 fb ff ff       	call   800ba2 <sys_page_map>
		if (r < 0) {
  800fdc:	83 c4 20             	add    $0x20,%esp
  800fdf:	85 c0                	test   %eax,%eax
  800fe1:	79 14                	jns    800ff7 <fork+0x191>
		    	panic("sys page map fault %e");
  800fe3:	83 ec 04             	sub    $0x4,%esp
  800fe6:	68 cc 2b 80 00       	push   $0x802bcc
  800feb:	6a 64                	push   $0x64
  800fed:	68 9a 2b 80 00       	push   $0x802b9a
  800ff2:	e8 07 f1 ff ff       	call   8000fe <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800ff7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800ffd:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801003:	0f 85 de fe ff ff    	jne    800ee7 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801009:	a1 04 40 80 00       	mov    0x804004,%eax
  80100e:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  801014:	83 ec 08             	sub    $0x8,%esp
  801017:	50                   	push   %eax
  801018:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80101b:	57                   	push   %edi
  80101c:	e8 89 fc ff ff       	call   800caa <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801021:	83 c4 08             	add    $0x8,%esp
  801024:	6a 02                	push   $0x2
  801026:	57                   	push   %edi
  801027:	e8 fa fb ff ff       	call   800c26 <sys_env_set_status>
	
	return envid;
  80102c:	83 c4 10             	add    $0x10,%esp
  80102f:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801031:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801034:	5b                   	pop    %ebx
  801035:	5e                   	pop    %esi
  801036:	5f                   	pop    %edi
  801037:	5d                   	pop    %ebp
  801038:	c3                   	ret    

00801039 <sfork>:

envid_t
sfork(void)
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80103c:	b8 00 00 00 00       	mov    $0x0,%eax
  801041:	5d                   	pop    %ebp
  801042:	c3                   	ret    

00801043 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	56                   	push   %esi
  801047:	53                   	push   %ebx
  801048:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  80104b:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  801051:	83 ec 08             	sub    $0x8,%esp
  801054:	53                   	push   %ebx
  801055:	68 e4 2b 80 00       	push   $0x802be4
  80105a:	e8 78 f1 ff ff       	call   8001d7 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80105f:	c7 04 24 c4 00 80 00 	movl   $0x8000c4,(%esp)
  801066:	e8 e5 fc ff ff       	call   800d50 <sys_thread_create>
  80106b:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80106d:	83 c4 08             	add    $0x8,%esp
  801070:	53                   	push   %ebx
  801071:	68 e4 2b 80 00       	push   $0x802be4
  801076:	e8 5c f1 ff ff       	call   8001d7 <cprintf>
	return id;
}
  80107b:	89 f0                	mov    %esi,%eax
  80107d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801080:	5b                   	pop    %ebx
  801081:	5e                   	pop    %esi
  801082:	5d                   	pop    %ebp
  801083:	c3                   	ret    

00801084 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801087:	8b 45 08             	mov    0x8(%ebp),%eax
  80108a:	05 00 00 00 30       	add    $0x30000000,%eax
  80108f:	c1 e8 0c             	shr    $0xc,%eax
}
  801092:	5d                   	pop    %ebp
  801093:	c3                   	ret    

00801094 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801097:	8b 45 08             	mov    0x8(%ebp),%eax
  80109a:	05 00 00 00 30       	add    $0x30000000,%eax
  80109f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010a4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010a9:	5d                   	pop    %ebp
  8010aa:	c3                   	ret    

008010ab <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
  8010ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010b1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010b6:	89 c2                	mov    %eax,%edx
  8010b8:	c1 ea 16             	shr    $0x16,%edx
  8010bb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010c2:	f6 c2 01             	test   $0x1,%dl
  8010c5:	74 11                	je     8010d8 <fd_alloc+0x2d>
  8010c7:	89 c2                	mov    %eax,%edx
  8010c9:	c1 ea 0c             	shr    $0xc,%edx
  8010cc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010d3:	f6 c2 01             	test   $0x1,%dl
  8010d6:	75 09                	jne    8010e1 <fd_alloc+0x36>
			*fd_store = fd;
  8010d8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010da:	b8 00 00 00 00       	mov    $0x0,%eax
  8010df:	eb 17                	jmp    8010f8 <fd_alloc+0x4d>
  8010e1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010e6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010eb:	75 c9                	jne    8010b6 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010ed:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010f3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010f8:	5d                   	pop    %ebp
  8010f9:	c3                   	ret    

008010fa <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010fa:	55                   	push   %ebp
  8010fb:	89 e5                	mov    %esp,%ebp
  8010fd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801100:	83 f8 1f             	cmp    $0x1f,%eax
  801103:	77 36                	ja     80113b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801105:	c1 e0 0c             	shl    $0xc,%eax
  801108:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80110d:	89 c2                	mov    %eax,%edx
  80110f:	c1 ea 16             	shr    $0x16,%edx
  801112:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801119:	f6 c2 01             	test   $0x1,%dl
  80111c:	74 24                	je     801142 <fd_lookup+0x48>
  80111e:	89 c2                	mov    %eax,%edx
  801120:	c1 ea 0c             	shr    $0xc,%edx
  801123:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80112a:	f6 c2 01             	test   $0x1,%dl
  80112d:	74 1a                	je     801149 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80112f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801132:	89 02                	mov    %eax,(%edx)
	return 0;
  801134:	b8 00 00 00 00       	mov    $0x0,%eax
  801139:	eb 13                	jmp    80114e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80113b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801140:	eb 0c                	jmp    80114e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801142:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801147:	eb 05                	jmp    80114e <fd_lookup+0x54>
  801149:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80114e:	5d                   	pop    %ebp
  80114f:	c3                   	ret    

00801150 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
  801153:	83 ec 08             	sub    $0x8,%esp
  801156:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801159:	ba 84 2c 80 00       	mov    $0x802c84,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80115e:	eb 13                	jmp    801173 <dev_lookup+0x23>
  801160:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801163:	39 08                	cmp    %ecx,(%eax)
  801165:	75 0c                	jne    801173 <dev_lookup+0x23>
			*dev = devtab[i];
  801167:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80116a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80116c:	b8 00 00 00 00       	mov    $0x0,%eax
  801171:	eb 2e                	jmp    8011a1 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801173:	8b 02                	mov    (%edx),%eax
  801175:	85 c0                	test   %eax,%eax
  801177:	75 e7                	jne    801160 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801179:	a1 04 40 80 00       	mov    0x804004,%eax
  80117e:	8b 40 7c             	mov    0x7c(%eax),%eax
  801181:	83 ec 04             	sub    $0x4,%esp
  801184:	51                   	push   %ecx
  801185:	50                   	push   %eax
  801186:	68 08 2c 80 00       	push   $0x802c08
  80118b:	e8 47 f0 ff ff       	call   8001d7 <cprintf>
	*dev = 0;
  801190:	8b 45 0c             	mov    0xc(%ebp),%eax
  801193:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801199:	83 c4 10             	add    $0x10,%esp
  80119c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011a1:	c9                   	leave  
  8011a2:	c3                   	ret    

008011a3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011a3:	55                   	push   %ebp
  8011a4:	89 e5                	mov    %esp,%ebp
  8011a6:	56                   	push   %esi
  8011a7:	53                   	push   %ebx
  8011a8:	83 ec 10             	sub    $0x10,%esp
  8011ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8011ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b4:	50                   	push   %eax
  8011b5:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011bb:	c1 e8 0c             	shr    $0xc,%eax
  8011be:	50                   	push   %eax
  8011bf:	e8 36 ff ff ff       	call   8010fa <fd_lookup>
  8011c4:	83 c4 08             	add    $0x8,%esp
  8011c7:	85 c0                	test   %eax,%eax
  8011c9:	78 05                	js     8011d0 <fd_close+0x2d>
	    || fd != fd2)
  8011cb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011ce:	74 0c                	je     8011dc <fd_close+0x39>
		return (must_exist ? r : 0);
  8011d0:	84 db                	test   %bl,%bl
  8011d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8011d7:	0f 44 c2             	cmove  %edx,%eax
  8011da:	eb 41                	jmp    80121d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011dc:	83 ec 08             	sub    $0x8,%esp
  8011df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e2:	50                   	push   %eax
  8011e3:	ff 36                	pushl  (%esi)
  8011e5:	e8 66 ff ff ff       	call   801150 <dev_lookup>
  8011ea:	89 c3                	mov    %eax,%ebx
  8011ec:	83 c4 10             	add    $0x10,%esp
  8011ef:	85 c0                	test   %eax,%eax
  8011f1:	78 1a                	js     80120d <fd_close+0x6a>
		if (dev->dev_close)
  8011f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011f9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011fe:	85 c0                	test   %eax,%eax
  801200:	74 0b                	je     80120d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801202:	83 ec 0c             	sub    $0xc,%esp
  801205:	56                   	push   %esi
  801206:	ff d0                	call   *%eax
  801208:	89 c3                	mov    %eax,%ebx
  80120a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80120d:	83 ec 08             	sub    $0x8,%esp
  801210:	56                   	push   %esi
  801211:	6a 00                	push   $0x0
  801213:	e8 cc f9 ff ff       	call   800be4 <sys_page_unmap>
	return r;
  801218:	83 c4 10             	add    $0x10,%esp
  80121b:	89 d8                	mov    %ebx,%eax
}
  80121d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801220:	5b                   	pop    %ebx
  801221:	5e                   	pop    %esi
  801222:	5d                   	pop    %ebp
  801223:	c3                   	ret    

00801224 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801224:	55                   	push   %ebp
  801225:	89 e5                	mov    %esp,%ebp
  801227:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80122a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122d:	50                   	push   %eax
  80122e:	ff 75 08             	pushl  0x8(%ebp)
  801231:	e8 c4 fe ff ff       	call   8010fa <fd_lookup>
  801236:	83 c4 08             	add    $0x8,%esp
  801239:	85 c0                	test   %eax,%eax
  80123b:	78 10                	js     80124d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80123d:	83 ec 08             	sub    $0x8,%esp
  801240:	6a 01                	push   $0x1
  801242:	ff 75 f4             	pushl  -0xc(%ebp)
  801245:	e8 59 ff ff ff       	call   8011a3 <fd_close>
  80124a:	83 c4 10             	add    $0x10,%esp
}
  80124d:	c9                   	leave  
  80124e:	c3                   	ret    

0080124f <close_all>:

void
close_all(void)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	53                   	push   %ebx
  801253:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801256:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80125b:	83 ec 0c             	sub    $0xc,%esp
  80125e:	53                   	push   %ebx
  80125f:	e8 c0 ff ff ff       	call   801224 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801264:	83 c3 01             	add    $0x1,%ebx
  801267:	83 c4 10             	add    $0x10,%esp
  80126a:	83 fb 20             	cmp    $0x20,%ebx
  80126d:	75 ec                	jne    80125b <close_all+0xc>
		close(i);
}
  80126f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801272:	c9                   	leave  
  801273:	c3                   	ret    

00801274 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801274:	55                   	push   %ebp
  801275:	89 e5                	mov    %esp,%ebp
  801277:	57                   	push   %edi
  801278:	56                   	push   %esi
  801279:	53                   	push   %ebx
  80127a:	83 ec 2c             	sub    $0x2c,%esp
  80127d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801280:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801283:	50                   	push   %eax
  801284:	ff 75 08             	pushl  0x8(%ebp)
  801287:	e8 6e fe ff ff       	call   8010fa <fd_lookup>
  80128c:	83 c4 08             	add    $0x8,%esp
  80128f:	85 c0                	test   %eax,%eax
  801291:	0f 88 c1 00 00 00    	js     801358 <dup+0xe4>
		return r;
	close(newfdnum);
  801297:	83 ec 0c             	sub    $0xc,%esp
  80129a:	56                   	push   %esi
  80129b:	e8 84 ff ff ff       	call   801224 <close>

	newfd = INDEX2FD(newfdnum);
  8012a0:	89 f3                	mov    %esi,%ebx
  8012a2:	c1 e3 0c             	shl    $0xc,%ebx
  8012a5:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012ab:	83 c4 04             	add    $0x4,%esp
  8012ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012b1:	e8 de fd ff ff       	call   801094 <fd2data>
  8012b6:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012b8:	89 1c 24             	mov    %ebx,(%esp)
  8012bb:	e8 d4 fd ff ff       	call   801094 <fd2data>
  8012c0:	83 c4 10             	add    $0x10,%esp
  8012c3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012c6:	89 f8                	mov    %edi,%eax
  8012c8:	c1 e8 16             	shr    $0x16,%eax
  8012cb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012d2:	a8 01                	test   $0x1,%al
  8012d4:	74 37                	je     80130d <dup+0x99>
  8012d6:	89 f8                	mov    %edi,%eax
  8012d8:	c1 e8 0c             	shr    $0xc,%eax
  8012db:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012e2:	f6 c2 01             	test   $0x1,%dl
  8012e5:	74 26                	je     80130d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012e7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012ee:	83 ec 0c             	sub    $0xc,%esp
  8012f1:	25 07 0e 00 00       	and    $0xe07,%eax
  8012f6:	50                   	push   %eax
  8012f7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012fa:	6a 00                	push   $0x0
  8012fc:	57                   	push   %edi
  8012fd:	6a 00                	push   $0x0
  8012ff:	e8 9e f8 ff ff       	call   800ba2 <sys_page_map>
  801304:	89 c7                	mov    %eax,%edi
  801306:	83 c4 20             	add    $0x20,%esp
  801309:	85 c0                	test   %eax,%eax
  80130b:	78 2e                	js     80133b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80130d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801310:	89 d0                	mov    %edx,%eax
  801312:	c1 e8 0c             	shr    $0xc,%eax
  801315:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80131c:	83 ec 0c             	sub    $0xc,%esp
  80131f:	25 07 0e 00 00       	and    $0xe07,%eax
  801324:	50                   	push   %eax
  801325:	53                   	push   %ebx
  801326:	6a 00                	push   $0x0
  801328:	52                   	push   %edx
  801329:	6a 00                	push   $0x0
  80132b:	e8 72 f8 ff ff       	call   800ba2 <sys_page_map>
  801330:	89 c7                	mov    %eax,%edi
  801332:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801335:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801337:	85 ff                	test   %edi,%edi
  801339:	79 1d                	jns    801358 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80133b:	83 ec 08             	sub    $0x8,%esp
  80133e:	53                   	push   %ebx
  80133f:	6a 00                	push   $0x0
  801341:	e8 9e f8 ff ff       	call   800be4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801346:	83 c4 08             	add    $0x8,%esp
  801349:	ff 75 d4             	pushl  -0x2c(%ebp)
  80134c:	6a 00                	push   $0x0
  80134e:	e8 91 f8 ff ff       	call   800be4 <sys_page_unmap>
	return r;
  801353:	83 c4 10             	add    $0x10,%esp
  801356:	89 f8                	mov    %edi,%eax
}
  801358:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80135b:	5b                   	pop    %ebx
  80135c:	5e                   	pop    %esi
  80135d:	5f                   	pop    %edi
  80135e:	5d                   	pop    %ebp
  80135f:	c3                   	ret    

00801360 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801360:	55                   	push   %ebp
  801361:	89 e5                	mov    %esp,%ebp
  801363:	53                   	push   %ebx
  801364:	83 ec 14             	sub    $0x14,%esp
  801367:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80136a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80136d:	50                   	push   %eax
  80136e:	53                   	push   %ebx
  80136f:	e8 86 fd ff ff       	call   8010fa <fd_lookup>
  801374:	83 c4 08             	add    $0x8,%esp
  801377:	89 c2                	mov    %eax,%edx
  801379:	85 c0                	test   %eax,%eax
  80137b:	78 6d                	js     8013ea <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80137d:	83 ec 08             	sub    $0x8,%esp
  801380:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801383:	50                   	push   %eax
  801384:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801387:	ff 30                	pushl  (%eax)
  801389:	e8 c2 fd ff ff       	call   801150 <dev_lookup>
  80138e:	83 c4 10             	add    $0x10,%esp
  801391:	85 c0                	test   %eax,%eax
  801393:	78 4c                	js     8013e1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801395:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801398:	8b 42 08             	mov    0x8(%edx),%eax
  80139b:	83 e0 03             	and    $0x3,%eax
  80139e:	83 f8 01             	cmp    $0x1,%eax
  8013a1:	75 21                	jne    8013c4 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013a3:	a1 04 40 80 00       	mov    0x804004,%eax
  8013a8:	8b 40 7c             	mov    0x7c(%eax),%eax
  8013ab:	83 ec 04             	sub    $0x4,%esp
  8013ae:	53                   	push   %ebx
  8013af:	50                   	push   %eax
  8013b0:	68 49 2c 80 00       	push   $0x802c49
  8013b5:	e8 1d ee ff ff       	call   8001d7 <cprintf>
		return -E_INVAL;
  8013ba:	83 c4 10             	add    $0x10,%esp
  8013bd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013c2:	eb 26                	jmp    8013ea <read+0x8a>
	}
	if (!dev->dev_read)
  8013c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c7:	8b 40 08             	mov    0x8(%eax),%eax
  8013ca:	85 c0                	test   %eax,%eax
  8013cc:	74 17                	je     8013e5 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8013ce:	83 ec 04             	sub    $0x4,%esp
  8013d1:	ff 75 10             	pushl  0x10(%ebp)
  8013d4:	ff 75 0c             	pushl  0xc(%ebp)
  8013d7:	52                   	push   %edx
  8013d8:	ff d0                	call   *%eax
  8013da:	89 c2                	mov    %eax,%edx
  8013dc:	83 c4 10             	add    $0x10,%esp
  8013df:	eb 09                	jmp    8013ea <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e1:	89 c2                	mov    %eax,%edx
  8013e3:	eb 05                	jmp    8013ea <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013e5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8013ea:	89 d0                	mov    %edx,%eax
  8013ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ef:	c9                   	leave  
  8013f0:	c3                   	ret    

008013f1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013f1:	55                   	push   %ebp
  8013f2:	89 e5                	mov    %esp,%ebp
  8013f4:	57                   	push   %edi
  8013f5:	56                   	push   %esi
  8013f6:	53                   	push   %ebx
  8013f7:	83 ec 0c             	sub    $0xc,%esp
  8013fa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013fd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801400:	bb 00 00 00 00       	mov    $0x0,%ebx
  801405:	eb 21                	jmp    801428 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801407:	83 ec 04             	sub    $0x4,%esp
  80140a:	89 f0                	mov    %esi,%eax
  80140c:	29 d8                	sub    %ebx,%eax
  80140e:	50                   	push   %eax
  80140f:	89 d8                	mov    %ebx,%eax
  801411:	03 45 0c             	add    0xc(%ebp),%eax
  801414:	50                   	push   %eax
  801415:	57                   	push   %edi
  801416:	e8 45 ff ff ff       	call   801360 <read>
		if (m < 0)
  80141b:	83 c4 10             	add    $0x10,%esp
  80141e:	85 c0                	test   %eax,%eax
  801420:	78 10                	js     801432 <readn+0x41>
			return m;
		if (m == 0)
  801422:	85 c0                	test   %eax,%eax
  801424:	74 0a                	je     801430 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801426:	01 c3                	add    %eax,%ebx
  801428:	39 f3                	cmp    %esi,%ebx
  80142a:	72 db                	jb     801407 <readn+0x16>
  80142c:	89 d8                	mov    %ebx,%eax
  80142e:	eb 02                	jmp    801432 <readn+0x41>
  801430:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801432:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801435:	5b                   	pop    %ebx
  801436:	5e                   	pop    %esi
  801437:	5f                   	pop    %edi
  801438:	5d                   	pop    %ebp
  801439:	c3                   	ret    

0080143a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80143a:	55                   	push   %ebp
  80143b:	89 e5                	mov    %esp,%ebp
  80143d:	53                   	push   %ebx
  80143e:	83 ec 14             	sub    $0x14,%esp
  801441:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801444:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801447:	50                   	push   %eax
  801448:	53                   	push   %ebx
  801449:	e8 ac fc ff ff       	call   8010fa <fd_lookup>
  80144e:	83 c4 08             	add    $0x8,%esp
  801451:	89 c2                	mov    %eax,%edx
  801453:	85 c0                	test   %eax,%eax
  801455:	78 68                	js     8014bf <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801457:	83 ec 08             	sub    $0x8,%esp
  80145a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80145d:	50                   	push   %eax
  80145e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801461:	ff 30                	pushl  (%eax)
  801463:	e8 e8 fc ff ff       	call   801150 <dev_lookup>
  801468:	83 c4 10             	add    $0x10,%esp
  80146b:	85 c0                	test   %eax,%eax
  80146d:	78 47                	js     8014b6 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80146f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801472:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801476:	75 21                	jne    801499 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801478:	a1 04 40 80 00       	mov    0x804004,%eax
  80147d:	8b 40 7c             	mov    0x7c(%eax),%eax
  801480:	83 ec 04             	sub    $0x4,%esp
  801483:	53                   	push   %ebx
  801484:	50                   	push   %eax
  801485:	68 65 2c 80 00       	push   $0x802c65
  80148a:	e8 48 ed ff ff       	call   8001d7 <cprintf>
		return -E_INVAL;
  80148f:	83 c4 10             	add    $0x10,%esp
  801492:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801497:	eb 26                	jmp    8014bf <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801499:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80149c:	8b 52 0c             	mov    0xc(%edx),%edx
  80149f:	85 d2                	test   %edx,%edx
  8014a1:	74 17                	je     8014ba <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014a3:	83 ec 04             	sub    $0x4,%esp
  8014a6:	ff 75 10             	pushl  0x10(%ebp)
  8014a9:	ff 75 0c             	pushl  0xc(%ebp)
  8014ac:	50                   	push   %eax
  8014ad:	ff d2                	call   *%edx
  8014af:	89 c2                	mov    %eax,%edx
  8014b1:	83 c4 10             	add    $0x10,%esp
  8014b4:	eb 09                	jmp    8014bf <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b6:	89 c2                	mov    %eax,%edx
  8014b8:	eb 05                	jmp    8014bf <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014bf:	89 d0                	mov    %edx,%eax
  8014c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c4:	c9                   	leave  
  8014c5:	c3                   	ret    

008014c6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014c6:	55                   	push   %ebp
  8014c7:	89 e5                	mov    %esp,%ebp
  8014c9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014cc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014cf:	50                   	push   %eax
  8014d0:	ff 75 08             	pushl  0x8(%ebp)
  8014d3:	e8 22 fc ff ff       	call   8010fa <fd_lookup>
  8014d8:	83 c4 08             	add    $0x8,%esp
  8014db:	85 c0                	test   %eax,%eax
  8014dd:	78 0e                	js     8014ed <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014df:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014e5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014ed:	c9                   	leave  
  8014ee:	c3                   	ret    

008014ef <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014ef:	55                   	push   %ebp
  8014f0:	89 e5                	mov    %esp,%ebp
  8014f2:	53                   	push   %ebx
  8014f3:	83 ec 14             	sub    $0x14,%esp
  8014f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014fc:	50                   	push   %eax
  8014fd:	53                   	push   %ebx
  8014fe:	e8 f7 fb ff ff       	call   8010fa <fd_lookup>
  801503:	83 c4 08             	add    $0x8,%esp
  801506:	89 c2                	mov    %eax,%edx
  801508:	85 c0                	test   %eax,%eax
  80150a:	78 65                	js     801571 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80150c:	83 ec 08             	sub    $0x8,%esp
  80150f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801512:	50                   	push   %eax
  801513:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801516:	ff 30                	pushl  (%eax)
  801518:	e8 33 fc ff ff       	call   801150 <dev_lookup>
  80151d:	83 c4 10             	add    $0x10,%esp
  801520:	85 c0                	test   %eax,%eax
  801522:	78 44                	js     801568 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801524:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801527:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80152b:	75 21                	jne    80154e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80152d:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801532:	8b 40 7c             	mov    0x7c(%eax),%eax
  801535:	83 ec 04             	sub    $0x4,%esp
  801538:	53                   	push   %ebx
  801539:	50                   	push   %eax
  80153a:	68 28 2c 80 00       	push   $0x802c28
  80153f:	e8 93 ec ff ff       	call   8001d7 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801544:	83 c4 10             	add    $0x10,%esp
  801547:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80154c:	eb 23                	jmp    801571 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80154e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801551:	8b 52 18             	mov    0x18(%edx),%edx
  801554:	85 d2                	test   %edx,%edx
  801556:	74 14                	je     80156c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801558:	83 ec 08             	sub    $0x8,%esp
  80155b:	ff 75 0c             	pushl  0xc(%ebp)
  80155e:	50                   	push   %eax
  80155f:	ff d2                	call   *%edx
  801561:	89 c2                	mov    %eax,%edx
  801563:	83 c4 10             	add    $0x10,%esp
  801566:	eb 09                	jmp    801571 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801568:	89 c2                	mov    %eax,%edx
  80156a:	eb 05                	jmp    801571 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80156c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801571:	89 d0                	mov    %edx,%eax
  801573:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801576:	c9                   	leave  
  801577:	c3                   	ret    

00801578 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801578:	55                   	push   %ebp
  801579:	89 e5                	mov    %esp,%ebp
  80157b:	53                   	push   %ebx
  80157c:	83 ec 14             	sub    $0x14,%esp
  80157f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801582:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801585:	50                   	push   %eax
  801586:	ff 75 08             	pushl  0x8(%ebp)
  801589:	e8 6c fb ff ff       	call   8010fa <fd_lookup>
  80158e:	83 c4 08             	add    $0x8,%esp
  801591:	89 c2                	mov    %eax,%edx
  801593:	85 c0                	test   %eax,%eax
  801595:	78 58                	js     8015ef <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801597:	83 ec 08             	sub    $0x8,%esp
  80159a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159d:	50                   	push   %eax
  80159e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a1:	ff 30                	pushl  (%eax)
  8015a3:	e8 a8 fb ff ff       	call   801150 <dev_lookup>
  8015a8:	83 c4 10             	add    $0x10,%esp
  8015ab:	85 c0                	test   %eax,%eax
  8015ad:	78 37                	js     8015e6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015b6:	74 32                	je     8015ea <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015b8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015bb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015c2:	00 00 00 
	stat->st_isdir = 0;
  8015c5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015cc:	00 00 00 
	stat->st_dev = dev;
  8015cf:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015d5:	83 ec 08             	sub    $0x8,%esp
  8015d8:	53                   	push   %ebx
  8015d9:	ff 75 f0             	pushl  -0x10(%ebp)
  8015dc:	ff 50 14             	call   *0x14(%eax)
  8015df:	89 c2                	mov    %eax,%edx
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	eb 09                	jmp    8015ef <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e6:	89 c2                	mov    %eax,%edx
  8015e8:	eb 05                	jmp    8015ef <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015ea:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015ef:	89 d0                	mov    %edx,%eax
  8015f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f4:	c9                   	leave  
  8015f5:	c3                   	ret    

008015f6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015f6:	55                   	push   %ebp
  8015f7:	89 e5                	mov    %esp,%ebp
  8015f9:	56                   	push   %esi
  8015fa:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015fb:	83 ec 08             	sub    $0x8,%esp
  8015fe:	6a 00                	push   $0x0
  801600:	ff 75 08             	pushl  0x8(%ebp)
  801603:	e8 e3 01 00 00       	call   8017eb <open>
  801608:	89 c3                	mov    %eax,%ebx
  80160a:	83 c4 10             	add    $0x10,%esp
  80160d:	85 c0                	test   %eax,%eax
  80160f:	78 1b                	js     80162c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801611:	83 ec 08             	sub    $0x8,%esp
  801614:	ff 75 0c             	pushl  0xc(%ebp)
  801617:	50                   	push   %eax
  801618:	e8 5b ff ff ff       	call   801578 <fstat>
  80161d:	89 c6                	mov    %eax,%esi
	close(fd);
  80161f:	89 1c 24             	mov    %ebx,(%esp)
  801622:	e8 fd fb ff ff       	call   801224 <close>
	return r;
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	89 f0                	mov    %esi,%eax
}
  80162c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80162f:	5b                   	pop    %ebx
  801630:	5e                   	pop    %esi
  801631:	5d                   	pop    %ebp
  801632:	c3                   	ret    

00801633 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801633:	55                   	push   %ebp
  801634:	89 e5                	mov    %esp,%ebp
  801636:	56                   	push   %esi
  801637:	53                   	push   %ebx
  801638:	89 c6                	mov    %eax,%esi
  80163a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80163c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801643:	75 12                	jne    801657 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801645:	83 ec 0c             	sub    $0xc,%esp
  801648:	6a 01                	push   $0x1
  80164a:	e8 79 0e 00 00       	call   8024c8 <ipc_find_env>
  80164f:	a3 00 40 80 00       	mov    %eax,0x804000
  801654:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801657:	6a 07                	push   $0x7
  801659:	68 00 50 80 00       	push   $0x805000
  80165e:	56                   	push   %esi
  80165f:	ff 35 00 40 80 00    	pushl  0x804000
  801665:	e8 fc 0d 00 00       	call   802466 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80166a:	83 c4 0c             	add    $0xc,%esp
  80166d:	6a 00                	push   $0x0
  80166f:	53                   	push   %ebx
  801670:	6a 00                	push   $0x0
  801672:	e8 74 0d 00 00       	call   8023eb <ipc_recv>
}
  801677:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167a:	5b                   	pop    %ebx
  80167b:	5e                   	pop    %esi
  80167c:	5d                   	pop    %ebp
  80167d:	c3                   	ret    

0080167e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
  801681:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801684:	8b 45 08             	mov    0x8(%ebp),%eax
  801687:	8b 40 0c             	mov    0xc(%eax),%eax
  80168a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80168f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801692:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801697:	ba 00 00 00 00       	mov    $0x0,%edx
  80169c:	b8 02 00 00 00       	mov    $0x2,%eax
  8016a1:	e8 8d ff ff ff       	call   801633 <fsipc>
}
  8016a6:	c9                   	leave  
  8016a7:	c3                   	ret    

008016a8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016a8:	55                   	push   %ebp
  8016a9:	89 e5                	mov    %esp,%ebp
  8016ab:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b1:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016be:	b8 06 00 00 00       	mov    $0x6,%eax
  8016c3:	e8 6b ff ff ff       	call   801633 <fsipc>
}
  8016c8:	c9                   	leave  
  8016c9:	c3                   	ret    

008016ca <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	53                   	push   %ebx
  8016ce:	83 ec 04             	sub    $0x4,%esp
  8016d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8016da:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016df:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e4:	b8 05 00 00 00       	mov    $0x5,%eax
  8016e9:	e8 45 ff ff ff       	call   801633 <fsipc>
  8016ee:	85 c0                	test   %eax,%eax
  8016f0:	78 2c                	js     80171e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016f2:	83 ec 08             	sub    $0x8,%esp
  8016f5:	68 00 50 80 00       	push   $0x805000
  8016fa:	53                   	push   %ebx
  8016fb:	e8 5c f0 ff ff       	call   80075c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801700:	a1 80 50 80 00       	mov    0x805080,%eax
  801705:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80170b:	a1 84 50 80 00       	mov    0x805084,%eax
  801710:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801716:	83 c4 10             	add    $0x10,%esp
  801719:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80171e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801721:	c9                   	leave  
  801722:	c3                   	ret    

00801723 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801723:	55                   	push   %ebp
  801724:	89 e5                	mov    %esp,%ebp
  801726:	83 ec 0c             	sub    $0xc,%esp
  801729:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80172c:	8b 55 08             	mov    0x8(%ebp),%edx
  80172f:	8b 52 0c             	mov    0xc(%edx),%edx
  801732:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801738:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80173d:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801742:	0f 47 c2             	cmova  %edx,%eax
  801745:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80174a:	50                   	push   %eax
  80174b:	ff 75 0c             	pushl  0xc(%ebp)
  80174e:	68 08 50 80 00       	push   $0x805008
  801753:	e8 96 f1 ff ff       	call   8008ee <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801758:	ba 00 00 00 00       	mov    $0x0,%edx
  80175d:	b8 04 00 00 00       	mov    $0x4,%eax
  801762:	e8 cc fe ff ff       	call   801633 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801767:	c9                   	leave  
  801768:	c3                   	ret    

00801769 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801769:	55                   	push   %ebp
  80176a:	89 e5                	mov    %esp,%ebp
  80176c:	56                   	push   %esi
  80176d:	53                   	push   %ebx
  80176e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801771:	8b 45 08             	mov    0x8(%ebp),%eax
  801774:	8b 40 0c             	mov    0xc(%eax),%eax
  801777:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80177c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801782:	ba 00 00 00 00       	mov    $0x0,%edx
  801787:	b8 03 00 00 00       	mov    $0x3,%eax
  80178c:	e8 a2 fe ff ff       	call   801633 <fsipc>
  801791:	89 c3                	mov    %eax,%ebx
  801793:	85 c0                	test   %eax,%eax
  801795:	78 4b                	js     8017e2 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801797:	39 c6                	cmp    %eax,%esi
  801799:	73 16                	jae    8017b1 <devfile_read+0x48>
  80179b:	68 94 2c 80 00       	push   $0x802c94
  8017a0:	68 9b 2c 80 00       	push   $0x802c9b
  8017a5:	6a 7c                	push   $0x7c
  8017a7:	68 b0 2c 80 00       	push   $0x802cb0
  8017ac:	e8 4d e9 ff ff       	call   8000fe <_panic>
	assert(r <= PGSIZE);
  8017b1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017b6:	7e 16                	jle    8017ce <devfile_read+0x65>
  8017b8:	68 bb 2c 80 00       	push   $0x802cbb
  8017bd:	68 9b 2c 80 00       	push   $0x802c9b
  8017c2:	6a 7d                	push   $0x7d
  8017c4:	68 b0 2c 80 00       	push   $0x802cb0
  8017c9:	e8 30 e9 ff ff       	call   8000fe <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017ce:	83 ec 04             	sub    $0x4,%esp
  8017d1:	50                   	push   %eax
  8017d2:	68 00 50 80 00       	push   $0x805000
  8017d7:	ff 75 0c             	pushl  0xc(%ebp)
  8017da:	e8 0f f1 ff ff       	call   8008ee <memmove>
	return r;
  8017df:	83 c4 10             	add    $0x10,%esp
}
  8017e2:	89 d8                	mov    %ebx,%eax
  8017e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e7:	5b                   	pop    %ebx
  8017e8:	5e                   	pop    %esi
  8017e9:	5d                   	pop    %ebp
  8017ea:	c3                   	ret    

008017eb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017eb:	55                   	push   %ebp
  8017ec:	89 e5                	mov    %esp,%ebp
  8017ee:	53                   	push   %ebx
  8017ef:	83 ec 20             	sub    $0x20,%esp
  8017f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017f5:	53                   	push   %ebx
  8017f6:	e8 28 ef ff ff       	call   800723 <strlen>
  8017fb:	83 c4 10             	add    $0x10,%esp
  8017fe:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801803:	7f 67                	jg     80186c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801805:	83 ec 0c             	sub    $0xc,%esp
  801808:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80180b:	50                   	push   %eax
  80180c:	e8 9a f8 ff ff       	call   8010ab <fd_alloc>
  801811:	83 c4 10             	add    $0x10,%esp
		return r;
  801814:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801816:	85 c0                	test   %eax,%eax
  801818:	78 57                	js     801871 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80181a:	83 ec 08             	sub    $0x8,%esp
  80181d:	53                   	push   %ebx
  80181e:	68 00 50 80 00       	push   $0x805000
  801823:	e8 34 ef ff ff       	call   80075c <strcpy>
	fsipcbuf.open.req_omode = mode;
  801828:	8b 45 0c             	mov    0xc(%ebp),%eax
  80182b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801830:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801833:	b8 01 00 00 00       	mov    $0x1,%eax
  801838:	e8 f6 fd ff ff       	call   801633 <fsipc>
  80183d:	89 c3                	mov    %eax,%ebx
  80183f:	83 c4 10             	add    $0x10,%esp
  801842:	85 c0                	test   %eax,%eax
  801844:	79 14                	jns    80185a <open+0x6f>
		fd_close(fd, 0);
  801846:	83 ec 08             	sub    $0x8,%esp
  801849:	6a 00                	push   $0x0
  80184b:	ff 75 f4             	pushl  -0xc(%ebp)
  80184e:	e8 50 f9 ff ff       	call   8011a3 <fd_close>
		return r;
  801853:	83 c4 10             	add    $0x10,%esp
  801856:	89 da                	mov    %ebx,%edx
  801858:	eb 17                	jmp    801871 <open+0x86>
	}

	return fd2num(fd);
  80185a:	83 ec 0c             	sub    $0xc,%esp
  80185d:	ff 75 f4             	pushl  -0xc(%ebp)
  801860:	e8 1f f8 ff ff       	call   801084 <fd2num>
  801865:	89 c2                	mov    %eax,%edx
  801867:	83 c4 10             	add    $0x10,%esp
  80186a:	eb 05                	jmp    801871 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80186c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801871:	89 d0                	mov    %edx,%eax
  801873:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801876:	c9                   	leave  
  801877:	c3                   	ret    

00801878 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80187e:	ba 00 00 00 00       	mov    $0x0,%edx
  801883:	b8 08 00 00 00       	mov    $0x8,%eax
  801888:	e8 a6 fd ff ff       	call   801633 <fsipc>
}
  80188d:	c9                   	leave  
  80188e:	c3                   	ret    

0080188f <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80188f:	55                   	push   %ebp
  801890:	89 e5                	mov    %esp,%ebp
  801892:	57                   	push   %edi
  801893:	56                   	push   %esi
  801894:	53                   	push   %ebx
  801895:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80189b:	6a 00                	push   $0x0
  80189d:	ff 75 08             	pushl  0x8(%ebp)
  8018a0:	e8 46 ff ff ff       	call   8017eb <open>
  8018a5:	89 c7                	mov    %eax,%edi
  8018a7:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8018ad:	83 c4 10             	add    $0x10,%esp
  8018b0:	85 c0                	test   %eax,%eax
  8018b2:	0f 88 8c 04 00 00    	js     801d44 <spawn+0x4b5>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8018b8:	83 ec 04             	sub    $0x4,%esp
  8018bb:	68 00 02 00 00       	push   $0x200
  8018c0:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8018c6:	50                   	push   %eax
  8018c7:	57                   	push   %edi
  8018c8:	e8 24 fb ff ff       	call   8013f1 <readn>
  8018cd:	83 c4 10             	add    $0x10,%esp
  8018d0:	3d 00 02 00 00       	cmp    $0x200,%eax
  8018d5:	75 0c                	jne    8018e3 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8018d7:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8018de:	45 4c 46 
  8018e1:	74 33                	je     801916 <spawn+0x87>
		close(fd);
  8018e3:	83 ec 0c             	sub    $0xc,%esp
  8018e6:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8018ec:	e8 33 f9 ff ff       	call   801224 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8018f1:	83 c4 0c             	add    $0xc,%esp
  8018f4:	68 7f 45 4c 46       	push   $0x464c457f
  8018f9:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8018ff:	68 c7 2c 80 00       	push   $0x802cc7
  801904:	e8 ce e8 ff ff       	call   8001d7 <cprintf>
		return -E_NOT_EXEC;
  801909:	83 c4 10             	add    $0x10,%esp
  80190c:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801911:	e9 e1 04 00 00       	jmp    801df7 <spawn+0x568>
  801916:	b8 07 00 00 00       	mov    $0x7,%eax
  80191b:	cd 30                	int    $0x30
  80191d:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801923:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801929:	85 c0                	test   %eax,%eax
  80192b:	0f 88 1e 04 00 00    	js     801d4f <spawn+0x4c0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801931:	89 c6                	mov    %eax,%esi
  801933:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801939:	69 f6 b0 00 00 00    	imul   $0xb0,%esi,%esi
  80193f:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801945:	81 c6 34 00 c0 ee    	add    $0xeec00034,%esi
  80194b:	b9 11 00 00 00       	mov    $0x11,%ecx
  801950:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801952:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801958:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80195e:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801963:	be 00 00 00 00       	mov    $0x0,%esi
  801968:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80196b:	eb 13                	jmp    801980 <spawn+0xf1>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  80196d:	83 ec 0c             	sub    $0xc,%esp
  801970:	50                   	push   %eax
  801971:	e8 ad ed ff ff       	call   800723 <strlen>
  801976:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80197a:	83 c3 01             	add    $0x1,%ebx
  80197d:	83 c4 10             	add    $0x10,%esp
  801980:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801987:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80198a:	85 c0                	test   %eax,%eax
  80198c:	75 df                	jne    80196d <spawn+0xde>
  80198e:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801994:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  80199a:	bf 00 10 40 00       	mov    $0x401000,%edi
  80199f:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8019a1:	89 fa                	mov    %edi,%edx
  8019a3:	83 e2 fc             	and    $0xfffffffc,%edx
  8019a6:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8019ad:	29 c2                	sub    %eax,%edx
  8019af:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8019b5:	8d 42 f8             	lea    -0x8(%edx),%eax
  8019b8:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8019bd:	0f 86 a2 03 00 00    	jbe    801d65 <spawn+0x4d6>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8019c3:	83 ec 04             	sub    $0x4,%esp
  8019c6:	6a 07                	push   $0x7
  8019c8:	68 00 00 40 00       	push   $0x400000
  8019cd:	6a 00                	push   $0x0
  8019cf:	e8 8b f1 ff ff       	call   800b5f <sys_page_alloc>
  8019d4:	83 c4 10             	add    $0x10,%esp
  8019d7:	85 c0                	test   %eax,%eax
  8019d9:	0f 88 90 03 00 00    	js     801d6f <spawn+0x4e0>
  8019df:	be 00 00 00 00       	mov    $0x0,%esi
  8019e4:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8019ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019ed:	eb 30                	jmp    801a1f <spawn+0x190>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8019ef:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8019f5:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8019fb:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  8019fe:	83 ec 08             	sub    $0x8,%esp
  801a01:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a04:	57                   	push   %edi
  801a05:	e8 52 ed ff ff       	call   80075c <strcpy>
		string_store += strlen(argv[i]) + 1;
  801a0a:	83 c4 04             	add    $0x4,%esp
  801a0d:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a10:	e8 0e ed ff ff       	call   800723 <strlen>
  801a15:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a19:	83 c6 01             	add    $0x1,%esi
  801a1c:	83 c4 10             	add    $0x10,%esp
  801a1f:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801a25:	7f c8                	jg     8019ef <spawn+0x160>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801a27:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a2d:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801a33:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801a3a:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801a40:	74 19                	je     801a5b <spawn+0x1cc>
  801a42:	68 54 2d 80 00       	push   $0x802d54
  801a47:	68 9b 2c 80 00       	push   $0x802c9b
  801a4c:	68 f2 00 00 00       	push   $0xf2
  801a51:	68 e1 2c 80 00       	push   $0x802ce1
  801a56:	e8 a3 e6 ff ff       	call   8000fe <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801a5b:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801a61:	89 f8                	mov    %edi,%eax
  801a63:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801a68:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801a6b:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a71:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801a74:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801a7a:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801a80:	83 ec 0c             	sub    $0xc,%esp
  801a83:	6a 07                	push   $0x7
  801a85:	68 00 d0 bf ee       	push   $0xeebfd000
  801a8a:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a90:	68 00 00 40 00       	push   $0x400000
  801a95:	6a 00                	push   $0x0
  801a97:	e8 06 f1 ff ff       	call   800ba2 <sys_page_map>
  801a9c:	89 c3                	mov    %eax,%ebx
  801a9e:	83 c4 20             	add    $0x20,%esp
  801aa1:	85 c0                	test   %eax,%eax
  801aa3:	0f 88 3c 03 00 00    	js     801de5 <spawn+0x556>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801aa9:	83 ec 08             	sub    $0x8,%esp
  801aac:	68 00 00 40 00       	push   $0x400000
  801ab1:	6a 00                	push   $0x0
  801ab3:	e8 2c f1 ff ff       	call   800be4 <sys_page_unmap>
  801ab8:	89 c3                	mov    %eax,%ebx
  801aba:	83 c4 10             	add    $0x10,%esp
  801abd:	85 c0                	test   %eax,%eax
  801abf:	0f 88 20 03 00 00    	js     801de5 <spawn+0x556>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801ac5:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801acb:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801ad2:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ad8:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801adf:	00 00 00 
  801ae2:	e9 88 01 00 00       	jmp    801c6f <spawn+0x3e0>
		if (ph->p_type != ELF_PROG_LOAD)
  801ae7:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801aed:	83 38 01             	cmpl   $0x1,(%eax)
  801af0:	0f 85 6b 01 00 00    	jne    801c61 <spawn+0x3d2>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801af6:	89 c2                	mov    %eax,%edx
  801af8:	8b 40 18             	mov    0x18(%eax),%eax
  801afb:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801b01:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801b04:	83 f8 01             	cmp    $0x1,%eax
  801b07:	19 c0                	sbb    %eax,%eax
  801b09:	83 e0 fe             	and    $0xfffffffe,%eax
  801b0c:	83 c0 07             	add    $0x7,%eax
  801b0f:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801b15:	89 d0                	mov    %edx,%eax
  801b17:	8b 7a 04             	mov    0x4(%edx),%edi
  801b1a:	89 f9                	mov    %edi,%ecx
  801b1c:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801b22:	8b 7a 10             	mov    0x10(%edx),%edi
  801b25:	8b 52 14             	mov    0x14(%edx),%edx
  801b28:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801b2e:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801b31:	89 f0                	mov    %esi,%eax
  801b33:	25 ff 0f 00 00       	and    $0xfff,%eax
  801b38:	74 14                	je     801b4e <spawn+0x2bf>
		va -= i;
  801b3a:	29 c6                	sub    %eax,%esi
		memsz += i;
  801b3c:	01 c2                	add    %eax,%edx
  801b3e:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801b44:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801b46:	29 c1                	sub    %eax,%ecx
  801b48:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801b4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b53:	e9 f7 00 00 00       	jmp    801c4f <spawn+0x3c0>
		if (i >= filesz) {
  801b58:	39 fb                	cmp    %edi,%ebx
  801b5a:	72 27                	jb     801b83 <spawn+0x2f4>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801b5c:	83 ec 04             	sub    $0x4,%esp
  801b5f:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801b65:	56                   	push   %esi
  801b66:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801b6c:	e8 ee ef ff ff       	call   800b5f <sys_page_alloc>
  801b71:	83 c4 10             	add    $0x10,%esp
  801b74:	85 c0                	test   %eax,%eax
  801b76:	0f 89 c7 00 00 00    	jns    801c43 <spawn+0x3b4>
  801b7c:	89 c3                	mov    %eax,%ebx
  801b7e:	e9 fd 01 00 00       	jmp    801d80 <spawn+0x4f1>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b83:	83 ec 04             	sub    $0x4,%esp
  801b86:	6a 07                	push   $0x7
  801b88:	68 00 00 40 00       	push   $0x400000
  801b8d:	6a 00                	push   $0x0
  801b8f:	e8 cb ef ff ff       	call   800b5f <sys_page_alloc>
  801b94:	83 c4 10             	add    $0x10,%esp
  801b97:	85 c0                	test   %eax,%eax
  801b99:	0f 88 d7 01 00 00    	js     801d76 <spawn+0x4e7>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b9f:	83 ec 08             	sub    $0x8,%esp
  801ba2:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801ba8:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801bae:	50                   	push   %eax
  801baf:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801bb5:	e8 0c f9 ff ff       	call   8014c6 <seek>
  801bba:	83 c4 10             	add    $0x10,%esp
  801bbd:	85 c0                	test   %eax,%eax
  801bbf:	0f 88 b5 01 00 00    	js     801d7a <spawn+0x4eb>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801bc5:	83 ec 04             	sub    $0x4,%esp
  801bc8:	89 f8                	mov    %edi,%eax
  801bca:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801bd0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bd5:	ba 00 10 00 00       	mov    $0x1000,%edx
  801bda:	0f 47 c2             	cmova  %edx,%eax
  801bdd:	50                   	push   %eax
  801bde:	68 00 00 40 00       	push   $0x400000
  801be3:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801be9:	e8 03 f8 ff ff       	call   8013f1 <readn>
  801bee:	83 c4 10             	add    $0x10,%esp
  801bf1:	85 c0                	test   %eax,%eax
  801bf3:	0f 88 85 01 00 00    	js     801d7e <spawn+0x4ef>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801bf9:	83 ec 0c             	sub    $0xc,%esp
  801bfc:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c02:	56                   	push   %esi
  801c03:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c09:	68 00 00 40 00       	push   $0x400000
  801c0e:	6a 00                	push   $0x0
  801c10:	e8 8d ef ff ff       	call   800ba2 <sys_page_map>
  801c15:	83 c4 20             	add    $0x20,%esp
  801c18:	85 c0                	test   %eax,%eax
  801c1a:	79 15                	jns    801c31 <spawn+0x3a2>
				panic("spawn: sys_page_map data: %e", r);
  801c1c:	50                   	push   %eax
  801c1d:	68 ed 2c 80 00       	push   $0x802ced
  801c22:	68 25 01 00 00       	push   $0x125
  801c27:	68 e1 2c 80 00       	push   $0x802ce1
  801c2c:	e8 cd e4 ff ff       	call   8000fe <_panic>
			sys_page_unmap(0, UTEMP);
  801c31:	83 ec 08             	sub    $0x8,%esp
  801c34:	68 00 00 40 00       	push   $0x400000
  801c39:	6a 00                	push   $0x0
  801c3b:	e8 a4 ef ff ff       	call   800be4 <sys_page_unmap>
  801c40:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c43:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801c49:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801c4f:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801c55:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801c5b:	0f 82 f7 fe ff ff    	jb     801b58 <spawn+0x2c9>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c61:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801c68:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801c6f:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801c76:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801c7c:	0f 8c 65 fe ff ff    	jl     801ae7 <spawn+0x258>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801c82:	83 ec 0c             	sub    $0xc,%esp
  801c85:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c8b:	e8 94 f5 ff ff       	call   801224 <close>
  801c90:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801c93:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c98:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801c9e:	89 d8                	mov    %ebx,%eax
  801ca0:	c1 e8 16             	shr    $0x16,%eax
  801ca3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801caa:	a8 01                	test   $0x1,%al
  801cac:	74 42                	je     801cf0 <spawn+0x461>
  801cae:	89 d8                	mov    %ebx,%eax
  801cb0:	c1 e8 0c             	shr    $0xc,%eax
  801cb3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801cba:	f6 c2 01             	test   $0x1,%dl
  801cbd:	74 31                	je     801cf0 <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  801cbf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801cc6:	f6 c6 04             	test   $0x4,%dh
  801cc9:	74 25                	je     801cf0 <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  801ccb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801cd2:	83 ec 0c             	sub    $0xc,%esp
  801cd5:	25 07 0e 00 00       	and    $0xe07,%eax
  801cda:	50                   	push   %eax
  801cdb:	53                   	push   %ebx
  801cdc:	56                   	push   %esi
  801cdd:	53                   	push   %ebx
  801cde:	6a 00                	push   $0x0
  801ce0:	e8 bd ee ff ff       	call   800ba2 <sys_page_map>
			if (r < 0) {
  801ce5:	83 c4 20             	add    $0x20,%esp
  801ce8:	85 c0                	test   %eax,%eax
  801cea:	0f 88 b1 00 00 00    	js     801da1 <spawn+0x512>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801cf0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801cf6:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801cfc:	75 a0                	jne    801c9e <spawn+0x40f>
  801cfe:	e9 b3 00 00 00       	jmp    801db6 <spawn+0x527>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801d03:	50                   	push   %eax
  801d04:	68 0a 2d 80 00       	push   $0x802d0a
  801d09:	68 86 00 00 00       	push   $0x86
  801d0e:	68 e1 2c 80 00       	push   $0x802ce1
  801d13:	e8 e6 e3 ff ff       	call   8000fe <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d18:	83 ec 08             	sub    $0x8,%esp
  801d1b:	6a 02                	push   $0x2
  801d1d:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d23:	e8 fe ee ff ff       	call   800c26 <sys_env_set_status>
  801d28:	83 c4 10             	add    $0x10,%esp
  801d2b:	85 c0                	test   %eax,%eax
  801d2d:	79 2b                	jns    801d5a <spawn+0x4cb>
		panic("sys_env_set_status: %e", r);
  801d2f:	50                   	push   %eax
  801d30:	68 24 2d 80 00       	push   $0x802d24
  801d35:	68 89 00 00 00       	push   $0x89
  801d3a:	68 e1 2c 80 00       	push   $0x802ce1
  801d3f:	e8 ba e3 ff ff       	call   8000fe <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801d44:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801d4a:	e9 a8 00 00 00       	jmp    801df7 <spawn+0x568>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801d4f:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801d55:	e9 9d 00 00 00       	jmp    801df7 <spawn+0x568>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801d5a:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801d60:	e9 92 00 00 00       	jmp    801df7 <spawn+0x568>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801d65:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801d6a:	e9 88 00 00 00       	jmp    801df7 <spawn+0x568>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801d6f:	89 c3                	mov    %eax,%ebx
  801d71:	e9 81 00 00 00       	jmp    801df7 <spawn+0x568>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d76:	89 c3                	mov    %eax,%ebx
  801d78:	eb 06                	jmp    801d80 <spawn+0x4f1>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801d7a:	89 c3                	mov    %eax,%ebx
  801d7c:	eb 02                	jmp    801d80 <spawn+0x4f1>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801d7e:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801d80:	83 ec 0c             	sub    $0xc,%esp
  801d83:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d89:	e8 52 ed ff ff       	call   800ae0 <sys_env_destroy>
	close(fd);
  801d8e:	83 c4 04             	add    $0x4,%esp
  801d91:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d97:	e8 88 f4 ff ff       	call   801224 <close>
	return r;
  801d9c:	83 c4 10             	add    $0x10,%esp
  801d9f:	eb 56                	jmp    801df7 <spawn+0x568>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801da1:	50                   	push   %eax
  801da2:	68 3b 2d 80 00       	push   $0x802d3b
  801da7:	68 82 00 00 00       	push   $0x82
  801dac:	68 e1 2c 80 00       	push   $0x802ce1
  801db1:	e8 48 e3 ff ff       	call   8000fe <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801db6:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801dbd:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801dc0:	83 ec 08             	sub    $0x8,%esp
  801dc3:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801dc9:	50                   	push   %eax
  801dca:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801dd0:	e8 93 ee ff ff       	call   800c68 <sys_env_set_trapframe>
  801dd5:	83 c4 10             	add    $0x10,%esp
  801dd8:	85 c0                	test   %eax,%eax
  801dda:	0f 89 38 ff ff ff    	jns    801d18 <spawn+0x489>
  801de0:	e9 1e ff ff ff       	jmp    801d03 <spawn+0x474>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801de5:	83 ec 08             	sub    $0x8,%esp
  801de8:	68 00 00 40 00       	push   $0x400000
  801ded:	6a 00                	push   $0x0
  801def:	e8 f0 ed ff ff       	call   800be4 <sys_page_unmap>
  801df4:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801df7:	89 d8                	mov    %ebx,%eax
  801df9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dfc:	5b                   	pop    %ebx
  801dfd:	5e                   	pop    %esi
  801dfe:	5f                   	pop    %edi
  801dff:	5d                   	pop    %ebp
  801e00:	c3                   	ret    

00801e01 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801e01:	55                   	push   %ebp
  801e02:	89 e5                	mov    %esp,%ebp
  801e04:	56                   	push   %esi
  801e05:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e06:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801e09:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e0e:	eb 03                	jmp    801e13 <spawnl+0x12>
		argc++;
  801e10:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e13:	83 c2 04             	add    $0x4,%edx
  801e16:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801e1a:	75 f4                	jne    801e10 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801e1c:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801e23:	83 e2 f0             	and    $0xfffffff0,%edx
  801e26:	29 d4                	sub    %edx,%esp
  801e28:	8d 54 24 03          	lea    0x3(%esp),%edx
  801e2c:	c1 ea 02             	shr    $0x2,%edx
  801e2f:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801e36:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801e38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e3b:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801e42:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801e49:	00 
  801e4a:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e4c:	b8 00 00 00 00       	mov    $0x0,%eax
  801e51:	eb 0a                	jmp    801e5d <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801e53:	83 c0 01             	add    $0x1,%eax
  801e56:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801e5a:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e5d:	39 d0                	cmp    %edx,%eax
  801e5f:	75 f2                	jne    801e53 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801e61:	83 ec 08             	sub    $0x8,%esp
  801e64:	56                   	push   %esi
  801e65:	ff 75 08             	pushl  0x8(%ebp)
  801e68:	e8 22 fa ff ff       	call   80188f <spawn>
}
  801e6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e70:	5b                   	pop    %ebx
  801e71:	5e                   	pop    %esi
  801e72:	5d                   	pop    %ebp
  801e73:	c3                   	ret    

00801e74 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e74:	55                   	push   %ebp
  801e75:	89 e5                	mov    %esp,%ebp
  801e77:	56                   	push   %esi
  801e78:	53                   	push   %ebx
  801e79:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e7c:	83 ec 0c             	sub    $0xc,%esp
  801e7f:	ff 75 08             	pushl  0x8(%ebp)
  801e82:	e8 0d f2 ff ff       	call   801094 <fd2data>
  801e87:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e89:	83 c4 08             	add    $0x8,%esp
  801e8c:	68 7c 2d 80 00       	push   $0x802d7c
  801e91:	53                   	push   %ebx
  801e92:	e8 c5 e8 ff ff       	call   80075c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e97:	8b 46 04             	mov    0x4(%esi),%eax
  801e9a:	2b 06                	sub    (%esi),%eax
  801e9c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ea2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ea9:	00 00 00 
	stat->st_dev = &devpipe;
  801eac:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801eb3:	30 80 00 
	return 0;
}
  801eb6:	b8 00 00 00 00       	mov    $0x0,%eax
  801ebb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ebe:	5b                   	pop    %ebx
  801ebf:	5e                   	pop    %esi
  801ec0:	5d                   	pop    %ebp
  801ec1:	c3                   	ret    

00801ec2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ec2:	55                   	push   %ebp
  801ec3:	89 e5                	mov    %esp,%ebp
  801ec5:	53                   	push   %ebx
  801ec6:	83 ec 0c             	sub    $0xc,%esp
  801ec9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ecc:	53                   	push   %ebx
  801ecd:	6a 00                	push   $0x0
  801ecf:	e8 10 ed ff ff       	call   800be4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ed4:	89 1c 24             	mov    %ebx,(%esp)
  801ed7:	e8 b8 f1 ff ff       	call   801094 <fd2data>
  801edc:	83 c4 08             	add    $0x8,%esp
  801edf:	50                   	push   %eax
  801ee0:	6a 00                	push   $0x0
  801ee2:	e8 fd ec ff ff       	call   800be4 <sys_page_unmap>
}
  801ee7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eea:	c9                   	leave  
  801eeb:	c3                   	ret    

00801eec <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801eec:	55                   	push   %ebp
  801eed:	89 e5                	mov    %esp,%ebp
  801eef:	57                   	push   %edi
  801ef0:	56                   	push   %esi
  801ef1:	53                   	push   %ebx
  801ef2:	83 ec 1c             	sub    $0x1c,%esp
  801ef5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ef8:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801efa:	a1 04 40 80 00       	mov    0x804004,%eax
  801eff:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801f05:	83 ec 0c             	sub    $0xc,%esp
  801f08:	ff 75 e0             	pushl  -0x20(%ebp)
  801f0b:	e8 fa 05 00 00       	call   80250a <pageref>
  801f10:	89 c3                	mov    %eax,%ebx
  801f12:	89 3c 24             	mov    %edi,(%esp)
  801f15:	e8 f0 05 00 00       	call   80250a <pageref>
  801f1a:	83 c4 10             	add    $0x10,%esp
  801f1d:	39 c3                	cmp    %eax,%ebx
  801f1f:	0f 94 c1             	sete   %cl
  801f22:	0f b6 c9             	movzbl %cl,%ecx
  801f25:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f28:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801f2e:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  801f34:	39 ce                	cmp    %ecx,%esi
  801f36:	74 1e                	je     801f56 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801f38:	39 c3                	cmp    %eax,%ebx
  801f3a:	75 be                	jne    801efa <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f3c:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  801f42:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f45:	50                   	push   %eax
  801f46:	56                   	push   %esi
  801f47:	68 83 2d 80 00       	push   $0x802d83
  801f4c:	e8 86 e2 ff ff       	call   8001d7 <cprintf>
  801f51:	83 c4 10             	add    $0x10,%esp
  801f54:	eb a4                	jmp    801efa <_pipeisclosed+0xe>
	}
}
  801f56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f5c:	5b                   	pop    %ebx
  801f5d:	5e                   	pop    %esi
  801f5e:	5f                   	pop    %edi
  801f5f:	5d                   	pop    %ebp
  801f60:	c3                   	ret    

00801f61 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f61:	55                   	push   %ebp
  801f62:	89 e5                	mov    %esp,%ebp
  801f64:	57                   	push   %edi
  801f65:	56                   	push   %esi
  801f66:	53                   	push   %ebx
  801f67:	83 ec 28             	sub    $0x28,%esp
  801f6a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f6d:	56                   	push   %esi
  801f6e:	e8 21 f1 ff ff       	call   801094 <fd2data>
  801f73:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f75:	83 c4 10             	add    $0x10,%esp
  801f78:	bf 00 00 00 00       	mov    $0x0,%edi
  801f7d:	eb 4b                	jmp    801fca <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f7f:	89 da                	mov    %ebx,%edx
  801f81:	89 f0                	mov    %esi,%eax
  801f83:	e8 64 ff ff ff       	call   801eec <_pipeisclosed>
  801f88:	85 c0                	test   %eax,%eax
  801f8a:	75 48                	jne    801fd4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f8c:	e8 af eb ff ff       	call   800b40 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f91:	8b 43 04             	mov    0x4(%ebx),%eax
  801f94:	8b 0b                	mov    (%ebx),%ecx
  801f96:	8d 51 20             	lea    0x20(%ecx),%edx
  801f99:	39 d0                	cmp    %edx,%eax
  801f9b:	73 e2                	jae    801f7f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fa0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801fa4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801fa7:	89 c2                	mov    %eax,%edx
  801fa9:	c1 fa 1f             	sar    $0x1f,%edx
  801fac:	89 d1                	mov    %edx,%ecx
  801fae:	c1 e9 1b             	shr    $0x1b,%ecx
  801fb1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801fb4:	83 e2 1f             	and    $0x1f,%edx
  801fb7:	29 ca                	sub    %ecx,%edx
  801fb9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801fbd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fc1:	83 c0 01             	add    $0x1,%eax
  801fc4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fc7:	83 c7 01             	add    $0x1,%edi
  801fca:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fcd:	75 c2                	jne    801f91 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fcf:	8b 45 10             	mov    0x10(%ebp),%eax
  801fd2:	eb 05                	jmp    801fd9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fd4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fdc:	5b                   	pop    %ebx
  801fdd:	5e                   	pop    %esi
  801fde:	5f                   	pop    %edi
  801fdf:	5d                   	pop    %ebp
  801fe0:	c3                   	ret    

00801fe1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fe1:	55                   	push   %ebp
  801fe2:	89 e5                	mov    %esp,%ebp
  801fe4:	57                   	push   %edi
  801fe5:	56                   	push   %esi
  801fe6:	53                   	push   %ebx
  801fe7:	83 ec 18             	sub    $0x18,%esp
  801fea:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fed:	57                   	push   %edi
  801fee:	e8 a1 f0 ff ff       	call   801094 <fd2data>
  801ff3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ff5:	83 c4 10             	add    $0x10,%esp
  801ff8:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ffd:	eb 3d                	jmp    80203c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801fff:	85 db                	test   %ebx,%ebx
  802001:	74 04                	je     802007 <devpipe_read+0x26>
				return i;
  802003:	89 d8                	mov    %ebx,%eax
  802005:	eb 44                	jmp    80204b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802007:	89 f2                	mov    %esi,%edx
  802009:	89 f8                	mov    %edi,%eax
  80200b:	e8 dc fe ff ff       	call   801eec <_pipeisclosed>
  802010:	85 c0                	test   %eax,%eax
  802012:	75 32                	jne    802046 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802014:	e8 27 eb ff ff       	call   800b40 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802019:	8b 06                	mov    (%esi),%eax
  80201b:	3b 46 04             	cmp    0x4(%esi),%eax
  80201e:	74 df                	je     801fff <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802020:	99                   	cltd   
  802021:	c1 ea 1b             	shr    $0x1b,%edx
  802024:	01 d0                	add    %edx,%eax
  802026:	83 e0 1f             	and    $0x1f,%eax
  802029:	29 d0                	sub    %edx,%eax
  80202b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802030:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802033:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802036:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802039:	83 c3 01             	add    $0x1,%ebx
  80203c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80203f:	75 d8                	jne    802019 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802041:	8b 45 10             	mov    0x10(%ebp),%eax
  802044:	eb 05                	jmp    80204b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802046:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80204b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80204e:	5b                   	pop    %ebx
  80204f:	5e                   	pop    %esi
  802050:	5f                   	pop    %edi
  802051:	5d                   	pop    %ebp
  802052:	c3                   	ret    

00802053 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802053:	55                   	push   %ebp
  802054:	89 e5                	mov    %esp,%ebp
  802056:	56                   	push   %esi
  802057:	53                   	push   %ebx
  802058:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80205b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80205e:	50                   	push   %eax
  80205f:	e8 47 f0 ff ff       	call   8010ab <fd_alloc>
  802064:	83 c4 10             	add    $0x10,%esp
  802067:	89 c2                	mov    %eax,%edx
  802069:	85 c0                	test   %eax,%eax
  80206b:	0f 88 2c 01 00 00    	js     80219d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802071:	83 ec 04             	sub    $0x4,%esp
  802074:	68 07 04 00 00       	push   $0x407
  802079:	ff 75 f4             	pushl  -0xc(%ebp)
  80207c:	6a 00                	push   $0x0
  80207e:	e8 dc ea ff ff       	call   800b5f <sys_page_alloc>
  802083:	83 c4 10             	add    $0x10,%esp
  802086:	89 c2                	mov    %eax,%edx
  802088:	85 c0                	test   %eax,%eax
  80208a:	0f 88 0d 01 00 00    	js     80219d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802090:	83 ec 0c             	sub    $0xc,%esp
  802093:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802096:	50                   	push   %eax
  802097:	e8 0f f0 ff ff       	call   8010ab <fd_alloc>
  80209c:	89 c3                	mov    %eax,%ebx
  80209e:	83 c4 10             	add    $0x10,%esp
  8020a1:	85 c0                	test   %eax,%eax
  8020a3:	0f 88 e2 00 00 00    	js     80218b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020a9:	83 ec 04             	sub    $0x4,%esp
  8020ac:	68 07 04 00 00       	push   $0x407
  8020b1:	ff 75 f0             	pushl  -0x10(%ebp)
  8020b4:	6a 00                	push   $0x0
  8020b6:	e8 a4 ea ff ff       	call   800b5f <sys_page_alloc>
  8020bb:	89 c3                	mov    %eax,%ebx
  8020bd:	83 c4 10             	add    $0x10,%esp
  8020c0:	85 c0                	test   %eax,%eax
  8020c2:	0f 88 c3 00 00 00    	js     80218b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020c8:	83 ec 0c             	sub    $0xc,%esp
  8020cb:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ce:	e8 c1 ef ff ff       	call   801094 <fd2data>
  8020d3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020d5:	83 c4 0c             	add    $0xc,%esp
  8020d8:	68 07 04 00 00       	push   $0x407
  8020dd:	50                   	push   %eax
  8020de:	6a 00                	push   $0x0
  8020e0:	e8 7a ea ff ff       	call   800b5f <sys_page_alloc>
  8020e5:	89 c3                	mov    %eax,%ebx
  8020e7:	83 c4 10             	add    $0x10,%esp
  8020ea:	85 c0                	test   %eax,%eax
  8020ec:	0f 88 89 00 00 00    	js     80217b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020f2:	83 ec 0c             	sub    $0xc,%esp
  8020f5:	ff 75 f0             	pushl  -0x10(%ebp)
  8020f8:	e8 97 ef ff ff       	call   801094 <fd2data>
  8020fd:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802104:	50                   	push   %eax
  802105:	6a 00                	push   $0x0
  802107:	56                   	push   %esi
  802108:	6a 00                	push   $0x0
  80210a:	e8 93 ea ff ff       	call   800ba2 <sys_page_map>
  80210f:	89 c3                	mov    %eax,%ebx
  802111:	83 c4 20             	add    $0x20,%esp
  802114:	85 c0                	test   %eax,%eax
  802116:	78 55                	js     80216d <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802118:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80211e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802121:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802123:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802126:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80212d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  802133:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802136:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802138:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80213b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802142:	83 ec 0c             	sub    $0xc,%esp
  802145:	ff 75 f4             	pushl  -0xc(%ebp)
  802148:	e8 37 ef ff ff       	call   801084 <fd2num>
  80214d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802150:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802152:	83 c4 04             	add    $0x4,%esp
  802155:	ff 75 f0             	pushl  -0x10(%ebp)
  802158:	e8 27 ef ff ff       	call   801084 <fd2num>
  80215d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802160:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  802163:	83 c4 10             	add    $0x10,%esp
  802166:	ba 00 00 00 00       	mov    $0x0,%edx
  80216b:	eb 30                	jmp    80219d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80216d:	83 ec 08             	sub    $0x8,%esp
  802170:	56                   	push   %esi
  802171:	6a 00                	push   $0x0
  802173:	e8 6c ea ff ff       	call   800be4 <sys_page_unmap>
  802178:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80217b:	83 ec 08             	sub    $0x8,%esp
  80217e:	ff 75 f0             	pushl  -0x10(%ebp)
  802181:	6a 00                	push   $0x0
  802183:	e8 5c ea ff ff       	call   800be4 <sys_page_unmap>
  802188:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80218b:	83 ec 08             	sub    $0x8,%esp
  80218e:	ff 75 f4             	pushl  -0xc(%ebp)
  802191:	6a 00                	push   $0x0
  802193:	e8 4c ea ff ff       	call   800be4 <sys_page_unmap>
  802198:	83 c4 10             	add    $0x10,%esp
  80219b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80219d:	89 d0                	mov    %edx,%eax
  80219f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021a2:	5b                   	pop    %ebx
  8021a3:	5e                   	pop    %esi
  8021a4:	5d                   	pop    %ebp
  8021a5:	c3                   	ret    

008021a6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021a6:	55                   	push   %ebp
  8021a7:	89 e5                	mov    %esp,%ebp
  8021a9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021af:	50                   	push   %eax
  8021b0:	ff 75 08             	pushl  0x8(%ebp)
  8021b3:	e8 42 ef ff ff       	call   8010fa <fd_lookup>
  8021b8:	83 c4 10             	add    $0x10,%esp
  8021bb:	85 c0                	test   %eax,%eax
  8021bd:	78 18                	js     8021d7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021bf:	83 ec 0c             	sub    $0xc,%esp
  8021c2:	ff 75 f4             	pushl  -0xc(%ebp)
  8021c5:	e8 ca ee ff ff       	call   801094 <fd2data>
	return _pipeisclosed(fd, p);
  8021ca:	89 c2                	mov    %eax,%edx
  8021cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021cf:	e8 18 fd ff ff       	call   801eec <_pipeisclosed>
  8021d4:	83 c4 10             	add    $0x10,%esp
}
  8021d7:	c9                   	leave  
  8021d8:	c3                   	ret    

008021d9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021d9:	55                   	push   %ebp
  8021da:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8021e1:	5d                   	pop    %ebp
  8021e2:	c3                   	ret    

008021e3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021e3:	55                   	push   %ebp
  8021e4:	89 e5                	mov    %esp,%ebp
  8021e6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021e9:	68 9b 2d 80 00       	push   $0x802d9b
  8021ee:	ff 75 0c             	pushl  0xc(%ebp)
  8021f1:	e8 66 e5 ff ff       	call   80075c <strcpy>
	return 0;
}
  8021f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8021fb:	c9                   	leave  
  8021fc:	c3                   	ret    

008021fd <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021fd:	55                   	push   %ebp
  8021fe:	89 e5                	mov    %esp,%ebp
  802200:	57                   	push   %edi
  802201:	56                   	push   %esi
  802202:	53                   	push   %ebx
  802203:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802209:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80220e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802214:	eb 2d                	jmp    802243 <devcons_write+0x46>
		m = n - tot;
  802216:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802219:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80221b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80221e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802223:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802226:	83 ec 04             	sub    $0x4,%esp
  802229:	53                   	push   %ebx
  80222a:	03 45 0c             	add    0xc(%ebp),%eax
  80222d:	50                   	push   %eax
  80222e:	57                   	push   %edi
  80222f:	e8 ba e6 ff ff       	call   8008ee <memmove>
		sys_cputs(buf, m);
  802234:	83 c4 08             	add    $0x8,%esp
  802237:	53                   	push   %ebx
  802238:	57                   	push   %edi
  802239:	e8 65 e8 ff ff       	call   800aa3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80223e:	01 de                	add    %ebx,%esi
  802240:	83 c4 10             	add    $0x10,%esp
  802243:	89 f0                	mov    %esi,%eax
  802245:	3b 75 10             	cmp    0x10(%ebp),%esi
  802248:	72 cc                	jb     802216 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80224a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80224d:	5b                   	pop    %ebx
  80224e:	5e                   	pop    %esi
  80224f:	5f                   	pop    %edi
  802250:	5d                   	pop    %ebp
  802251:	c3                   	ret    

00802252 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802252:	55                   	push   %ebp
  802253:	89 e5                	mov    %esp,%ebp
  802255:	83 ec 08             	sub    $0x8,%esp
  802258:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80225d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802261:	74 2a                	je     80228d <devcons_read+0x3b>
  802263:	eb 05                	jmp    80226a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802265:	e8 d6 e8 ff ff       	call   800b40 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80226a:	e8 52 e8 ff ff       	call   800ac1 <sys_cgetc>
  80226f:	85 c0                	test   %eax,%eax
  802271:	74 f2                	je     802265 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802273:	85 c0                	test   %eax,%eax
  802275:	78 16                	js     80228d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802277:	83 f8 04             	cmp    $0x4,%eax
  80227a:	74 0c                	je     802288 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80227c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80227f:	88 02                	mov    %al,(%edx)
	return 1;
  802281:	b8 01 00 00 00       	mov    $0x1,%eax
  802286:	eb 05                	jmp    80228d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802288:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80228d:	c9                   	leave  
  80228e:	c3                   	ret    

0080228f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80228f:	55                   	push   %ebp
  802290:	89 e5                	mov    %esp,%ebp
  802292:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802295:	8b 45 08             	mov    0x8(%ebp),%eax
  802298:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80229b:	6a 01                	push   $0x1
  80229d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022a0:	50                   	push   %eax
  8022a1:	e8 fd e7 ff ff       	call   800aa3 <sys_cputs>
}
  8022a6:	83 c4 10             	add    $0x10,%esp
  8022a9:	c9                   	leave  
  8022aa:	c3                   	ret    

008022ab <getchar>:

int
getchar(void)
{
  8022ab:	55                   	push   %ebp
  8022ac:	89 e5                	mov    %esp,%ebp
  8022ae:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022b1:	6a 01                	push   $0x1
  8022b3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022b6:	50                   	push   %eax
  8022b7:	6a 00                	push   $0x0
  8022b9:	e8 a2 f0 ff ff       	call   801360 <read>
	if (r < 0)
  8022be:	83 c4 10             	add    $0x10,%esp
  8022c1:	85 c0                	test   %eax,%eax
  8022c3:	78 0f                	js     8022d4 <getchar+0x29>
		return r;
	if (r < 1)
  8022c5:	85 c0                	test   %eax,%eax
  8022c7:	7e 06                	jle    8022cf <getchar+0x24>
		return -E_EOF;
	return c;
  8022c9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022cd:	eb 05                	jmp    8022d4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022cf:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022d4:	c9                   	leave  
  8022d5:	c3                   	ret    

008022d6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022d6:	55                   	push   %ebp
  8022d7:	89 e5                	mov    %esp,%ebp
  8022d9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022df:	50                   	push   %eax
  8022e0:	ff 75 08             	pushl  0x8(%ebp)
  8022e3:	e8 12 ee ff ff       	call   8010fa <fd_lookup>
  8022e8:	83 c4 10             	add    $0x10,%esp
  8022eb:	85 c0                	test   %eax,%eax
  8022ed:	78 11                	js     802300 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022f2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022f8:	39 10                	cmp    %edx,(%eax)
  8022fa:	0f 94 c0             	sete   %al
  8022fd:	0f b6 c0             	movzbl %al,%eax
}
  802300:	c9                   	leave  
  802301:	c3                   	ret    

00802302 <opencons>:

int
opencons(void)
{
  802302:	55                   	push   %ebp
  802303:	89 e5                	mov    %esp,%ebp
  802305:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802308:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80230b:	50                   	push   %eax
  80230c:	e8 9a ed ff ff       	call   8010ab <fd_alloc>
  802311:	83 c4 10             	add    $0x10,%esp
		return r;
  802314:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802316:	85 c0                	test   %eax,%eax
  802318:	78 3e                	js     802358 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80231a:	83 ec 04             	sub    $0x4,%esp
  80231d:	68 07 04 00 00       	push   $0x407
  802322:	ff 75 f4             	pushl  -0xc(%ebp)
  802325:	6a 00                	push   $0x0
  802327:	e8 33 e8 ff ff       	call   800b5f <sys_page_alloc>
  80232c:	83 c4 10             	add    $0x10,%esp
		return r;
  80232f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802331:	85 c0                	test   %eax,%eax
  802333:	78 23                	js     802358 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802335:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80233b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80233e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802340:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802343:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80234a:	83 ec 0c             	sub    $0xc,%esp
  80234d:	50                   	push   %eax
  80234e:	e8 31 ed ff ff       	call   801084 <fd2num>
  802353:	89 c2                	mov    %eax,%edx
  802355:	83 c4 10             	add    $0x10,%esp
}
  802358:	89 d0                	mov    %edx,%eax
  80235a:	c9                   	leave  
  80235b:	c3                   	ret    

0080235c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80235c:	55                   	push   %ebp
  80235d:	89 e5                	mov    %esp,%ebp
  80235f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802362:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802369:	75 2a                	jne    802395 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  80236b:	83 ec 04             	sub    $0x4,%esp
  80236e:	6a 07                	push   $0x7
  802370:	68 00 f0 bf ee       	push   $0xeebff000
  802375:	6a 00                	push   $0x0
  802377:	e8 e3 e7 ff ff       	call   800b5f <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  80237c:	83 c4 10             	add    $0x10,%esp
  80237f:	85 c0                	test   %eax,%eax
  802381:	79 12                	jns    802395 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802383:	50                   	push   %eax
  802384:	68 a7 2d 80 00       	push   $0x802da7
  802389:	6a 23                	push   $0x23
  80238b:	68 ab 2d 80 00       	push   $0x802dab
  802390:	e8 69 dd ff ff       	call   8000fe <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802395:	8b 45 08             	mov    0x8(%ebp),%eax
  802398:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80239d:	83 ec 08             	sub    $0x8,%esp
  8023a0:	68 c7 23 80 00       	push   $0x8023c7
  8023a5:	6a 00                	push   $0x0
  8023a7:	e8 fe e8 ff ff       	call   800caa <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8023ac:	83 c4 10             	add    $0x10,%esp
  8023af:	85 c0                	test   %eax,%eax
  8023b1:	79 12                	jns    8023c5 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8023b3:	50                   	push   %eax
  8023b4:	68 a7 2d 80 00       	push   $0x802da7
  8023b9:	6a 2c                	push   $0x2c
  8023bb:	68 ab 2d 80 00       	push   $0x802dab
  8023c0:	e8 39 dd ff ff       	call   8000fe <_panic>
	}
}
  8023c5:	c9                   	leave  
  8023c6:	c3                   	ret    

008023c7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8023c7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8023c8:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8023cd:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8023cf:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8023d2:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8023d6:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8023db:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8023df:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8023e1:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8023e4:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8023e5:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8023e8:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8023e9:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8023ea:	c3                   	ret    

008023eb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8023eb:	55                   	push   %ebp
  8023ec:	89 e5                	mov    %esp,%ebp
  8023ee:	56                   	push   %esi
  8023ef:	53                   	push   %ebx
  8023f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8023f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023f6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8023f9:	85 c0                	test   %eax,%eax
  8023fb:	75 12                	jne    80240f <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8023fd:	83 ec 0c             	sub    $0xc,%esp
  802400:	68 00 00 c0 ee       	push   $0xeec00000
  802405:	e8 05 e9 ff ff       	call   800d0f <sys_ipc_recv>
  80240a:	83 c4 10             	add    $0x10,%esp
  80240d:	eb 0c                	jmp    80241b <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80240f:	83 ec 0c             	sub    $0xc,%esp
  802412:	50                   	push   %eax
  802413:	e8 f7 e8 ff ff       	call   800d0f <sys_ipc_recv>
  802418:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80241b:	85 f6                	test   %esi,%esi
  80241d:	0f 95 c1             	setne  %cl
  802420:	85 db                	test   %ebx,%ebx
  802422:	0f 95 c2             	setne  %dl
  802425:	84 d1                	test   %dl,%cl
  802427:	74 09                	je     802432 <ipc_recv+0x47>
  802429:	89 c2                	mov    %eax,%edx
  80242b:	c1 ea 1f             	shr    $0x1f,%edx
  80242e:	84 d2                	test   %dl,%dl
  802430:	75 2d                	jne    80245f <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802432:	85 f6                	test   %esi,%esi
  802434:	74 0d                	je     802443 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802436:	a1 04 40 80 00       	mov    0x804004,%eax
  80243b:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  802441:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802443:	85 db                	test   %ebx,%ebx
  802445:	74 0d                	je     802454 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802447:	a1 04 40 80 00       	mov    0x804004,%eax
  80244c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  802452:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802454:	a1 04 40 80 00       	mov    0x804004,%eax
  802459:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  80245f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802462:	5b                   	pop    %ebx
  802463:	5e                   	pop    %esi
  802464:	5d                   	pop    %ebp
  802465:	c3                   	ret    

00802466 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802466:	55                   	push   %ebp
  802467:	89 e5                	mov    %esp,%ebp
  802469:	57                   	push   %edi
  80246a:	56                   	push   %esi
  80246b:	53                   	push   %ebx
  80246c:	83 ec 0c             	sub    $0xc,%esp
  80246f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802472:	8b 75 0c             	mov    0xc(%ebp),%esi
  802475:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802478:	85 db                	test   %ebx,%ebx
  80247a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80247f:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802482:	ff 75 14             	pushl  0x14(%ebp)
  802485:	53                   	push   %ebx
  802486:	56                   	push   %esi
  802487:	57                   	push   %edi
  802488:	e8 5f e8 ff ff       	call   800cec <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80248d:	89 c2                	mov    %eax,%edx
  80248f:	c1 ea 1f             	shr    $0x1f,%edx
  802492:	83 c4 10             	add    $0x10,%esp
  802495:	84 d2                	test   %dl,%dl
  802497:	74 17                	je     8024b0 <ipc_send+0x4a>
  802499:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80249c:	74 12                	je     8024b0 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  80249e:	50                   	push   %eax
  80249f:	68 b9 2d 80 00       	push   $0x802db9
  8024a4:	6a 47                	push   $0x47
  8024a6:	68 c7 2d 80 00       	push   $0x802dc7
  8024ab:	e8 4e dc ff ff       	call   8000fe <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8024b0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024b3:	75 07                	jne    8024bc <ipc_send+0x56>
			sys_yield();
  8024b5:	e8 86 e6 ff ff       	call   800b40 <sys_yield>
  8024ba:	eb c6                	jmp    802482 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8024bc:	85 c0                	test   %eax,%eax
  8024be:	75 c2                	jne    802482 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8024c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024c3:	5b                   	pop    %ebx
  8024c4:	5e                   	pop    %esi
  8024c5:	5f                   	pop    %edi
  8024c6:	5d                   	pop    %ebp
  8024c7:	c3                   	ret    

008024c8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8024c8:	55                   	push   %ebp
  8024c9:	89 e5                	mov    %esp,%ebp
  8024cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8024ce:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8024d3:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  8024d9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8024df:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  8024e5:	39 ca                	cmp    %ecx,%edx
  8024e7:	75 10                	jne    8024f9 <ipc_find_env+0x31>
			return envs[i].env_id;
  8024e9:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  8024ef:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8024f4:	8b 40 7c             	mov    0x7c(%eax),%eax
  8024f7:	eb 0f                	jmp    802508 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8024f9:	83 c0 01             	add    $0x1,%eax
  8024fc:	3d 00 04 00 00       	cmp    $0x400,%eax
  802501:	75 d0                	jne    8024d3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802503:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802508:	5d                   	pop    %ebp
  802509:	c3                   	ret    

0080250a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80250a:	55                   	push   %ebp
  80250b:	89 e5                	mov    %esp,%ebp
  80250d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802510:	89 d0                	mov    %edx,%eax
  802512:	c1 e8 16             	shr    $0x16,%eax
  802515:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80251c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802521:	f6 c1 01             	test   $0x1,%cl
  802524:	74 1d                	je     802543 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802526:	c1 ea 0c             	shr    $0xc,%edx
  802529:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802530:	f6 c2 01             	test   $0x1,%dl
  802533:	74 0e                	je     802543 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802535:	c1 ea 0c             	shr    $0xc,%edx
  802538:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80253f:	ef 
  802540:	0f b7 c0             	movzwl %ax,%eax
}
  802543:	5d                   	pop    %ebp
  802544:	c3                   	ret    
  802545:	66 90                	xchg   %ax,%ax
  802547:	66 90                	xchg   %ax,%ax
  802549:	66 90                	xchg   %ax,%ax
  80254b:	66 90                	xchg   %ax,%ax
  80254d:	66 90                	xchg   %ax,%ax
  80254f:	90                   	nop

00802550 <__udivdi3>:
  802550:	55                   	push   %ebp
  802551:	57                   	push   %edi
  802552:	56                   	push   %esi
  802553:	53                   	push   %ebx
  802554:	83 ec 1c             	sub    $0x1c,%esp
  802557:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80255b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80255f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802563:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802567:	85 f6                	test   %esi,%esi
  802569:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80256d:	89 ca                	mov    %ecx,%edx
  80256f:	89 f8                	mov    %edi,%eax
  802571:	75 3d                	jne    8025b0 <__udivdi3+0x60>
  802573:	39 cf                	cmp    %ecx,%edi
  802575:	0f 87 c5 00 00 00    	ja     802640 <__udivdi3+0xf0>
  80257b:	85 ff                	test   %edi,%edi
  80257d:	89 fd                	mov    %edi,%ebp
  80257f:	75 0b                	jne    80258c <__udivdi3+0x3c>
  802581:	b8 01 00 00 00       	mov    $0x1,%eax
  802586:	31 d2                	xor    %edx,%edx
  802588:	f7 f7                	div    %edi
  80258a:	89 c5                	mov    %eax,%ebp
  80258c:	89 c8                	mov    %ecx,%eax
  80258e:	31 d2                	xor    %edx,%edx
  802590:	f7 f5                	div    %ebp
  802592:	89 c1                	mov    %eax,%ecx
  802594:	89 d8                	mov    %ebx,%eax
  802596:	89 cf                	mov    %ecx,%edi
  802598:	f7 f5                	div    %ebp
  80259a:	89 c3                	mov    %eax,%ebx
  80259c:	89 d8                	mov    %ebx,%eax
  80259e:	89 fa                	mov    %edi,%edx
  8025a0:	83 c4 1c             	add    $0x1c,%esp
  8025a3:	5b                   	pop    %ebx
  8025a4:	5e                   	pop    %esi
  8025a5:	5f                   	pop    %edi
  8025a6:	5d                   	pop    %ebp
  8025a7:	c3                   	ret    
  8025a8:	90                   	nop
  8025a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025b0:	39 ce                	cmp    %ecx,%esi
  8025b2:	77 74                	ja     802628 <__udivdi3+0xd8>
  8025b4:	0f bd fe             	bsr    %esi,%edi
  8025b7:	83 f7 1f             	xor    $0x1f,%edi
  8025ba:	0f 84 98 00 00 00    	je     802658 <__udivdi3+0x108>
  8025c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8025c5:	89 f9                	mov    %edi,%ecx
  8025c7:	89 c5                	mov    %eax,%ebp
  8025c9:	29 fb                	sub    %edi,%ebx
  8025cb:	d3 e6                	shl    %cl,%esi
  8025cd:	89 d9                	mov    %ebx,%ecx
  8025cf:	d3 ed                	shr    %cl,%ebp
  8025d1:	89 f9                	mov    %edi,%ecx
  8025d3:	d3 e0                	shl    %cl,%eax
  8025d5:	09 ee                	or     %ebp,%esi
  8025d7:	89 d9                	mov    %ebx,%ecx
  8025d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025dd:	89 d5                	mov    %edx,%ebp
  8025df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025e3:	d3 ed                	shr    %cl,%ebp
  8025e5:	89 f9                	mov    %edi,%ecx
  8025e7:	d3 e2                	shl    %cl,%edx
  8025e9:	89 d9                	mov    %ebx,%ecx
  8025eb:	d3 e8                	shr    %cl,%eax
  8025ed:	09 c2                	or     %eax,%edx
  8025ef:	89 d0                	mov    %edx,%eax
  8025f1:	89 ea                	mov    %ebp,%edx
  8025f3:	f7 f6                	div    %esi
  8025f5:	89 d5                	mov    %edx,%ebp
  8025f7:	89 c3                	mov    %eax,%ebx
  8025f9:	f7 64 24 0c          	mull   0xc(%esp)
  8025fd:	39 d5                	cmp    %edx,%ebp
  8025ff:	72 10                	jb     802611 <__udivdi3+0xc1>
  802601:	8b 74 24 08          	mov    0x8(%esp),%esi
  802605:	89 f9                	mov    %edi,%ecx
  802607:	d3 e6                	shl    %cl,%esi
  802609:	39 c6                	cmp    %eax,%esi
  80260b:	73 07                	jae    802614 <__udivdi3+0xc4>
  80260d:	39 d5                	cmp    %edx,%ebp
  80260f:	75 03                	jne    802614 <__udivdi3+0xc4>
  802611:	83 eb 01             	sub    $0x1,%ebx
  802614:	31 ff                	xor    %edi,%edi
  802616:	89 d8                	mov    %ebx,%eax
  802618:	89 fa                	mov    %edi,%edx
  80261a:	83 c4 1c             	add    $0x1c,%esp
  80261d:	5b                   	pop    %ebx
  80261e:	5e                   	pop    %esi
  80261f:	5f                   	pop    %edi
  802620:	5d                   	pop    %ebp
  802621:	c3                   	ret    
  802622:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802628:	31 ff                	xor    %edi,%edi
  80262a:	31 db                	xor    %ebx,%ebx
  80262c:	89 d8                	mov    %ebx,%eax
  80262e:	89 fa                	mov    %edi,%edx
  802630:	83 c4 1c             	add    $0x1c,%esp
  802633:	5b                   	pop    %ebx
  802634:	5e                   	pop    %esi
  802635:	5f                   	pop    %edi
  802636:	5d                   	pop    %ebp
  802637:	c3                   	ret    
  802638:	90                   	nop
  802639:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802640:	89 d8                	mov    %ebx,%eax
  802642:	f7 f7                	div    %edi
  802644:	31 ff                	xor    %edi,%edi
  802646:	89 c3                	mov    %eax,%ebx
  802648:	89 d8                	mov    %ebx,%eax
  80264a:	89 fa                	mov    %edi,%edx
  80264c:	83 c4 1c             	add    $0x1c,%esp
  80264f:	5b                   	pop    %ebx
  802650:	5e                   	pop    %esi
  802651:	5f                   	pop    %edi
  802652:	5d                   	pop    %ebp
  802653:	c3                   	ret    
  802654:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802658:	39 ce                	cmp    %ecx,%esi
  80265a:	72 0c                	jb     802668 <__udivdi3+0x118>
  80265c:	31 db                	xor    %ebx,%ebx
  80265e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802662:	0f 87 34 ff ff ff    	ja     80259c <__udivdi3+0x4c>
  802668:	bb 01 00 00 00       	mov    $0x1,%ebx
  80266d:	e9 2a ff ff ff       	jmp    80259c <__udivdi3+0x4c>
  802672:	66 90                	xchg   %ax,%ax
  802674:	66 90                	xchg   %ax,%ax
  802676:	66 90                	xchg   %ax,%ax
  802678:	66 90                	xchg   %ax,%ax
  80267a:	66 90                	xchg   %ax,%ax
  80267c:	66 90                	xchg   %ax,%ax
  80267e:	66 90                	xchg   %ax,%ax

00802680 <__umoddi3>:
  802680:	55                   	push   %ebp
  802681:	57                   	push   %edi
  802682:	56                   	push   %esi
  802683:	53                   	push   %ebx
  802684:	83 ec 1c             	sub    $0x1c,%esp
  802687:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80268b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80268f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802693:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802697:	85 d2                	test   %edx,%edx
  802699:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80269d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026a1:	89 f3                	mov    %esi,%ebx
  8026a3:	89 3c 24             	mov    %edi,(%esp)
  8026a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026aa:	75 1c                	jne    8026c8 <__umoddi3+0x48>
  8026ac:	39 f7                	cmp    %esi,%edi
  8026ae:	76 50                	jbe    802700 <__umoddi3+0x80>
  8026b0:	89 c8                	mov    %ecx,%eax
  8026b2:	89 f2                	mov    %esi,%edx
  8026b4:	f7 f7                	div    %edi
  8026b6:	89 d0                	mov    %edx,%eax
  8026b8:	31 d2                	xor    %edx,%edx
  8026ba:	83 c4 1c             	add    $0x1c,%esp
  8026bd:	5b                   	pop    %ebx
  8026be:	5e                   	pop    %esi
  8026bf:	5f                   	pop    %edi
  8026c0:	5d                   	pop    %ebp
  8026c1:	c3                   	ret    
  8026c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026c8:	39 f2                	cmp    %esi,%edx
  8026ca:	89 d0                	mov    %edx,%eax
  8026cc:	77 52                	ja     802720 <__umoddi3+0xa0>
  8026ce:	0f bd ea             	bsr    %edx,%ebp
  8026d1:	83 f5 1f             	xor    $0x1f,%ebp
  8026d4:	75 5a                	jne    802730 <__umoddi3+0xb0>
  8026d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8026da:	0f 82 e0 00 00 00    	jb     8027c0 <__umoddi3+0x140>
  8026e0:	39 0c 24             	cmp    %ecx,(%esp)
  8026e3:	0f 86 d7 00 00 00    	jbe    8027c0 <__umoddi3+0x140>
  8026e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8026ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8026f1:	83 c4 1c             	add    $0x1c,%esp
  8026f4:	5b                   	pop    %ebx
  8026f5:	5e                   	pop    %esi
  8026f6:	5f                   	pop    %edi
  8026f7:	5d                   	pop    %ebp
  8026f8:	c3                   	ret    
  8026f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802700:	85 ff                	test   %edi,%edi
  802702:	89 fd                	mov    %edi,%ebp
  802704:	75 0b                	jne    802711 <__umoddi3+0x91>
  802706:	b8 01 00 00 00       	mov    $0x1,%eax
  80270b:	31 d2                	xor    %edx,%edx
  80270d:	f7 f7                	div    %edi
  80270f:	89 c5                	mov    %eax,%ebp
  802711:	89 f0                	mov    %esi,%eax
  802713:	31 d2                	xor    %edx,%edx
  802715:	f7 f5                	div    %ebp
  802717:	89 c8                	mov    %ecx,%eax
  802719:	f7 f5                	div    %ebp
  80271b:	89 d0                	mov    %edx,%eax
  80271d:	eb 99                	jmp    8026b8 <__umoddi3+0x38>
  80271f:	90                   	nop
  802720:	89 c8                	mov    %ecx,%eax
  802722:	89 f2                	mov    %esi,%edx
  802724:	83 c4 1c             	add    $0x1c,%esp
  802727:	5b                   	pop    %ebx
  802728:	5e                   	pop    %esi
  802729:	5f                   	pop    %edi
  80272a:	5d                   	pop    %ebp
  80272b:	c3                   	ret    
  80272c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802730:	8b 34 24             	mov    (%esp),%esi
  802733:	bf 20 00 00 00       	mov    $0x20,%edi
  802738:	89 e9                	mov    %ebp,%ecx
  80273a:	29 ef                	sub    %ebp,%edi
  80273c:	d3 e0                	shl    %cl,%eax
  80273e:	89 f9                	mov    %edi,%ecx
  802740:	89 f2                	mov    %esi,%edx
  802742:	d3 ea                	shr    %cl,%edx
  802744:	89 e9                	mov    %ebp,%ecx
  802746:	09 c2                	or     %eax,%edx
  802748:	89 d8                	mov    %ebx,%eax
  80274a:	89 14 24             	mov    %edx,(%esp)
  80274d:	89 f2                	mov    %esi,%edx
  80274f:	d3 e2                	shl    %cl,%edx
  802751:	89 f9                	mov    %edi,%ecx
  802753:	89 54 24 04          	mov    %edx,0x4(%esp)
  802757:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80275b:	d3 e8                	shr    %cl,%eax
  80275d:	89 e9                	mov    %ebp,%ecx
  80275f:	89 c6                	mov    %eax,%esi
  802761:	d3 e3                	shl    %cl,%ebx
  802763:	89 f9                	mov    %edi,%ecx
  802765:	89 d0                	mov    %edx,%eax
  802767:	d3 e8                	shr    %cl,%eax
  802769:	89 e9                	mov    %ebp,%ecx
  80276b:	09 d8                	or     %ebx,%eax
  80276d:	89 d3                	mov    %edx,%ebx
  80276f:	89 f2                	mov    %esi,%edx
  802771:	f7 34 24             	divl   (%esp)
  802774:	89 d6                	mov    %edx,%esi
  802776:	d3 e3                	shl    %cl,%ebx
  802778:	f7 64 24 04          	mull   0x4(%esp)
  80277c:	39 d6                	cmp    %edx,%esi
  80277e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802782:	89 d1                	mov    %edx,%ecx
  802784:	89 c3                	mov    %eax,%ebx
  802786:	72 08                	jb     802790 <__umoddi3+0x110>
  802788:	75 11                	jne    80279b <__umoddi3+0x11b>
  80278a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80278e:	73 0b                	jae    80279b <__umoddi3+0x11b>
  802790:	2b 44 24 04          	sub    0x4(%esp),%eax
  802794:	1b 14 24             	sbb    (%esp),%edx
  802797:	89 d1                	mov    %edx,%ecx
  802799:	89 c3                	mov    %eax,%ebx
  80279b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80279f:	29 da                	sub    %ebx,%edx
  8027a1:	19 ce                	sbb    %ecx,%esi
  8027a3:	89 f9                	mov    %edi,%ecx
  8027a5:	89 f0                	mov    %esi,%eax
  8027a7:	d3 e0                	shl    %cl,%eax
  8027a9:	89 e9                	mov    %ebp,%ecx
  8027ab:	d3 ea                	shr    %cl,%edx
  8027ad:	89 e9                	mov    %ebp,%ecx
  8027af:	d3 ee                	shr    %cl,%esi
  8027b1:	09 d0                	or     %edx,%eax
  8027b3:	89 f2                	mov    %esi,%edx
  8027b5:	83 c4 1c             	add    $0x1c,%esp
  8027b8:	5b                   	pop    %ebx
  8027b9:	5e                   	pop    %esi
  8027ba:	5f                   	pop    %edi
  8027bb:	5d                   	pop    %ebp
  8027bc:	c3                   	ret    
  8027bd:	8d 76 00             	lea    0x0(%esi),%esi
  8027c0:	29 f9                	sub    %edi,%ecx
  8027c2:	19 d6                	sbb    %edx,%esi
  8027c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027cc:	e9 18 ff ff ff       	jmp    8026e9 <__umoddi3+0x69>
