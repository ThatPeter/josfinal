
obj/user/cat.debug:     file format elf32-i386


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
  80002c:	e8 02 01 00 00       	call   800133 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80003b:	eb 2f                	jmp    80006c <cat+0x39>
		if ((r = write(1, buf, n)) != n)
  80003d:	83 ec 04             	sub    $0x4,%esp
  800040:	53                   	push   %ebx
  800041:	68 20 40 80 00       	push   $0x804020
  800046:	6a 01                	push   $0x1
  800048:	e8 a4 14 00 00       	call   8014f1 <write>
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	39 c3                	cmp    %eax,%ebx
  800052:	74 18                	je     80006c <cat+0x39>
			panic("write error copying %s: %e", s, r);
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	50                   	push   %eax
  800058:	ff 75 0c             	pushl  0xc(%ebp)
  80005b:	68 c0 23 80 00       	push   $0x8023c0
  800060:	6a 0d                	push   $0xd
  800062:	68 db 23 80 00       	push   $0x8023db
  800067:	e8 4b 01 00 00       	call   8001b7 <_panic>
cat(int f, char *s)
{
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80006c:	83 ec 04             	sub    $0x4,%esp
  80006f:	68 00 20 00 00       	push   $0x2000
  800074:	68 20 40 80 00       	push   $0x804020
  800079:	56                   	push   %esi
  80007a:	e8 98 13 00 00       	call   801417 <read>
  80007f:	89 c3                	mov    %eax,%ebx
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	85 c0                	test   %eax,%eax
  800086:	7f b5                	jg     80003d <cat+0xa>
		if ((r = write(1, buf, n)) != n)
			panic("write error copying %s: %e", s, r);
	if (n < 0)
  800088:	85 c0                	test   %eax,%eax
  80008a:	79 18                	jns    8000a4 <cat+0x71>
		panic("error reading %s: %e", s, n);
  80008c:	83 ec 0c             	sub    $0xc,%esp
  80008f:	50                   	push   %eax
  800090:	ff 75 0c             	pushl  0xc(%ebp)
  800093:	68 e6 23 80 00       	push   $0x8023e6
  800098:	6a 0f                	push   $0xf
  80009a:	68 db 23 80 00       	push   $0x8023db
  80009f:	e8 13 01 00 00       	call   8001b7 <_panic>
}
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <umain>:

void
umain(int argc, char **argv)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	57                   	push   %edi
  8000af:	56                   	push   %esi
  8000b0:	53                   	push   %ebx
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int f, i;

	binaryname = "cat";
  8000b7:	c7 05 00 30 80 00 fb 	movl   $0x8023fb,0x803000
  8000be:	23 80 00 
  8000c1:	bb 01 00 00 00       	mov    $0x1,%ebx
	if (argc == 1)
  8000c6:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ca:	75 5a                	jne    800126 <umain+0x7b>
		cat(0, "<stdin>");
  8000cc:	83 ec 08             	sub    $0x8,%esp
  8000cf:	68 ff 23 80 00       	push   $0x8023ff
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 58 ff ff ff       	call   800033 <cat>
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	eb 4b                	jmp    80012b <umain+0x80>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  8000e0:	83 ec 08             	sub    $0x8,%esp
  8000e3:	6a 00                	push   $0x0
  8000e5:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000e8:	e8 b5 17 00 00       	call   8018a2 <open>
  8000ed:	89 c6                	mov    %eax,%esi
			if (f < 0)
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	85 c0                	test   %eax,%eax
  8000f4:	79 16                	jns    80010c <umain+0x61>
				printf("can't open %s: %e\n", argv[i], f);
  8000f6:	83 ec 04             	sub    $0x4,%esp
  8000f9:	50                   	push   %eax
  8000fa:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000fd:	68 07 24 80 00       	push   $0x802407
  800102:	e8 39 19 00 00       	call   801a40 <printf>
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	eb 17                	jmp    800123 <umain+0x78>
			else {
				cat(f, argv[i]);
  80010c:	83 ec 08             	sub    $0x8,%esp
  80010f:	ff 34 9f             	pushl  (%edi,%ebx,4)
  800112:	50                   	push   %eax
  800113:	e8 1b ff ff ff       	call   800033 <cat>
				close(f);
  800118:	89 34 24             	mov    %esi,(%esp)
  80011b:	e8 bb 11 00 00       	call   8012db <close>
  800120:	83 c4 10             	add    $0x10,%esp

	binaryname = "cat";
	if (argc == 1)
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  800123:	83 c3 01             	add    $0x1,%ebx
  800126:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800129:	7c b5                	jl     8000e0 <umain+0x35>
			else {
				cat(f, argv[i]);
				close(f);
			}
		}
}
  80012b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
  800138:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80013e:	e8 97 0a 00 00       	call   800bda <sys_getenvid>
  800143:	25 ff 03 00 00       	and    $0x3ff,%eax
  800148:	89 c2                	mov    %eax,%edx
  80014a:	c1 e2 07             	shl    $0x7,%edx
  80014d:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800154:	a3 20 60 80 00       	mov    %eax,0x806020
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800159:	85 db                	test   %ebx,%ebx
  80015b:	7e 07                	jle    800164 <libmain+0x31>
		binaryname = argv[0];
  80015d:	8b 06                	mov    (%esi),%eax
  80015f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800164:	83 ec 08             	sub    $0x8,%esp
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	e8 3d ff ff ff       	call   8000ab <umain>

	// exit gracefully
	exit();
  80016e:	e8 2a 00 00 00       	call   80019d <exit>
}
  800173:	83 c4 10             	add    $0x10,%esp
  800176:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800179:	5b                   	pop    %ebx
  80017a:	5e                   	pop    %esi
  80017b:	5d                   	pop    %ebp
  80017c:	c3                   	ret    

0080017d <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  80017d:	55                   	push   %ebp
  80017e:	89 e5                	mov    %esp,%ebp
  800180:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  800183:	a1 24 60 80 00       	mov    0x806024,%eax
	func();
  800188:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  80018a:	e8 4b 0a 00 00       	call   800bda <sys_getenvid>
  80018f:	83 ec 0c             	sub    $0xc,%esp
  800192:	50                   	push   %eax
  800193:	e8 91 0c 00 00       	call   800e29 <sys_thread_free>
}
  800198:	83 c4 10             	add    $0x10,%esp
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    

0080019d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001a3:	e8 5e 11 00 00       	call   801306 <close_all>
	sys_env_destroy(0);
  8001a8:	83 ec 0c             	sub    $0xc,%esp
  8001ab:	6a 00                	push   $0x0
  8001ad:	e8 e7 09 00 00       	call   800b99 <sys_env_destroy>
}
  8001b2:	83 c4 10             	add    $0x10,%esp
  8001b5:	c9                   	leave  
  8001b6:	c3                   	ret    

008001b7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	56                   	push   %esi
  8001bb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001bc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001bf:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001c5:	e8 10 0a 00 00       	call   800bda <sys_getenvid>
  8001ca:	83 ec 0c             	sub    $0xc,%esp
  8001cd:	ff 75 0c             	pushl  0xc(%ebp)
  8001d0:	ff 75 08             	pushl  0x8(%ebp)
  8001d3:	56                   	push   %esi
  8001d4:	50                   	push   %eax
  8001d5:	68 24 24 80 00       	push   $0x802424
  8001da:	e8 b1 00 00 00       	call   800290 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001df:	83 c4 18             	add    $0x18,%esp
  8001e2:	53                   	push   %ebx
  8001e3:	ff 75 10             	pushl  0x10(%ebp)
  8001e6:	e8 54 00 00 00       	call   80023f <vcprintf>
	cprintf("\n");
  8001eb:	c7 04 24 c3 28 80 00 	movl   $0x8028c3,(%esp)
  8001f2:	e8 99 00 00 00       	call   800290 <cprintf>
  8001f7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001fa:	cc                   	int3   
  8001fb:	eb fd                	jmp    8001fa <_panic+0x43>

008001fd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001fd:	55                   	push   %ebp
  8001fe:	89 e5                	mov    %esp,%ebp
  800200:	53                   	push   %ebx
  800201:	83 ec 04             	sub    $0x4,%esp
  800204:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800207:	8b 13                	mov    (%ebx),%edx
  800209:	8d 42 01             	lea    0x1(%edx),%eax
  80020c:	89 03                	mov    %eax,(%ebx)
  80020e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800211:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800215:	3d ff 00 00 00       	cmp    $0xff,%eax
  80021a:	75 1a                	jne    800236 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80021c:	83 ec 08             	sub    $0x8,%esp
  80021f:	68 ff 00 00 00       	push   $0xff
  800224:	8d 43 08             	lea    0x8(%ebx),%eax
  800227:	50                   	push   %eax
  800228:	e8 2f 09 00 00       	call   800b5c <sys_cputs>
		b->idx = 0;
  80022d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800233:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800236:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80023a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80023d:	c9                   	leave  
  80023e:	c3                   	ret    

0080023f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023f:	55                   	push   %ebp
  800240:	89 e5                	mov    %esp,%ebp
  800242:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800248:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024f:	00 00 00 
	b.cnt = 0;
  800252:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800259:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80025c:	ff 75 0c             	pushl  0xc(%ebp)
  80025f:	ff 75 08             	pushl  0x8(%ebp)
  800262:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800268:	50                   	push   %eax
  800269:	68 fd 01 80 00       	push   $0x8001fd
  80026e:	e8 54 01 00 00       	call   8003c7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800273:	83 c4 08             	add    $0x8,%esp
  800276:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80027c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800282:	50                   	push   %eax
  800283:	e8 d4 08 00 00       	call   800b5c <sys_cputs>

	return b.cnt;
}
  800288:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028e:	c9                   	leave  
  80028f:	c3                   	ret    

00800290 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800296:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800299:	50                   	push   %eax
  80029a:	ff 75 08             	pushl  0x8(%ebp)
  80029d:	e8 9d ff ff ff       	call   80023f <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a2:	c9                   	leave  
  8002a3:	c3                   	ret    

008002a4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	57                   	push   %edi
  8002a8:	56                   	push   %esi
  8002a9:	53                   	push   %ebx
  8002aa:	83 ec 1c             	sub    $0x1c,%esp
  8002ad:	89 c7                	mov    %eax,%edi
  8002af:	89 d6                	mov    %edx,%esi
  8002b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ba:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002c8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002cb:	39 d3                	cmp    %edx,%ebx
  8002cd:	72 05                	jb     8002d4 <printnum+0x30>
  8002cf:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002d2:	77 45                	ja     800319 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d4:	83 ec 0c             	sub    $0xc,%esp
  8002d7:	ff 75 18             	pushl  0x18(%ebp)
  8002da:	8b 45 14             	mov    0x14(%ebp),%eax
  8002dd:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002e0:	53                   	push   %ebx
  8002e1:	ff 75 10             	pushl  0x10(%ebp)
  8002e4:	83 ec 08             	sub    $0x8,%esp
  8002e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ed:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f0:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f3:	e8 28 1e 00 00       	call   802120 <__udivdi3>
  8002f8:	83 c4 18             	add    $0x18,%esp
  8002fb:	52                   	push   %edx
  8002fc:	50                   	push   %eax
  8002fd:	89 f2                	mov    %esi,%edx
  8002ff:	89 f8                	mov    %edi,%eax
  800301:	e8 9e ff ff ff       	call   8002a4 <printnum>
  800306:	83 c4 20             	add    $0x20,%esp
  800309:	eb 18                	jmp    800323 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80030b:	83 ec 08             	sub    $0x8,%esp
  80030e:	56                   	push   %esi
  80030f:	ff 75 18             	pushl  0x18(%ebp)
  800312:	ff d7                	call   *%edi
  800314:	83 c4 10             	add    $0x10,%esp
  800317:	eb 03                	jmp    80031c <printnum+0x78>
  800319:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80031c:	83 eb 01             	sub    $0x1,%ebx
  80031f:	85 db                	test   %ebx,%ebx
  800321:	7f e8                	jg     80030b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800323:	83 ec 08             	sub    $0x8,%esp
  800326:	56                   	push   %esi
  800327:	83 ec 04             	sub    $0x4,%esp
  80032a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80032d:	ff 75 e0             	pushl  -0x20(%ebp)
  800330:	ff 75 dc             	pushl  -0x24(%ebp)
  800333:	ff 75 d8             	pushl  -0x28(%ebp)
  800336:	e8 15 1f 00 00       	call   802250 <__umoddi3>
  80033b:	83 c4 14             	add    $0x14,%esp
  80033e:	0f be 80 47 24 80 00 	movsbl 0x802447(%eax),%eax
  800345:	50                   	push   %eax
  800346:	ff d7                	call   *%edi
}
  800348:	83 c4 10             	add    $0x10,%esp
  80034b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034e:	5b                   	pop    %ebx
  80034f:	5e                   	pop    %esi
  800350:	5f                   	pop    %edi
  800351:	5d                   	pop    %ebp
  800352:	c3                   	ret    

00800353 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800353:	55                   	push   %ebp
  800354:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800356:	83 fa 01             	cmp    $0x1,%edx
  800359:	7e 0e                	jle    800369 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80035b:	8b 10                	mov    (%eax),%edx
  80035d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800360:	89 08                	mov    %ecx,(%eax)
  800362:	8b 02                	mov    (%edx),%eax
  800364:	8b 52 04             	mov    0x4(%edx),%edx
  800367:	eb 22                	jmp    80038b <getuint+0x38>
	else if (lflag)
  800369:	85 d2                	test   %edx,%edx
  80036b:	74 10                	je     80037d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80036d:	8b 10                	mov    (%eax),%edx
  80036f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800372:	89 08                	mov    %ecx,(%eax)
  800374:	8b 02                	mov    (%edx),%eax
  800376:	ba 00 00 00 00       	mov    $0x0,%edx
  80037b:	eb 0e                	jmp    80038b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80037d:	8b 10                	mov    (%eax),%edx
  80037f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800382:	89 08                	mov    %ecx,(%eax)
  800384:	8b 02                	mov    (%edx),%eax
  800386:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80038b:	5d                   	pop    %ebp
  80038c:	c3                   	ret    

0080038d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80038d:	55                   	push   %ebp
  80038e:	89 e5                	mov    %esp,%ebp
  800390:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800393:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800397:	8b 10                	mov    (%eax),%edx
  800399:	3b 50 04             	cmp    0x4(%eax),%edx
  80039c:	73 0a                	jae    8003a8 <sprintputch+0x1b>
		*b->buf++ = ch;
  80039e:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003a1:	89 08                	mov    %ecx,(%eax)
  8003a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a6:	88 02                	mov    %al,(%edx)
}
  8003a8:	5d                   	pop    %ebp
  8003a9:	c3                   	ret    

008003aa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003aa:	55                   	push   %ebp
  8003ab:	89 e5                	mov    %esp,%ebp
  8003ad:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003b0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003b3:	50                   	push   %eax
  8003b4:	ff 75 10             	pushl  0x10(%ebp)
  8003b7:	ff 75 0c             	pushl  0xc(%ebp)
  8003ba:	ff 75 08             	pushl  0x8(%ebp)
  8003bd:	e8 05 00 00 00       	call   8003c7 <vprintfmt>
	va_end(ap);
}
  8003c2:	83 c4 10             	add    $0x10,%esp
  8003c5:	c9                   	leave  
  8003c6:	c3                   	ret    

008003c7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c7:	55                   	push   %ebp
  8003c8:	89 e5                	mov    %esp,%ebp
  8003ca:	57                   	push   %edi
  8003cb:	56                   	push   %esi
  8003cc:	53                   	push   %ebx
  8003cd:	83 ec 2c             	sub    $0x2c,%esp
  8003d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8003d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003d6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003d9:	eb 12                	jmp    8003ed <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	0f 84 89 03 00 00    	je     80076c <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003e3:	83 ec 08             	sub    $0x8,%esp
  8003e6:	53                   	push   %ebx
  8003e7:	50                   	push   %eax
  8003e8:	ff d6                	call   *%esi
  8003ea:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ed:	83 c7 01             	add    $0x1,%edi
  8003f0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003f4:	83 f8 25             	cmp    $0x25,%eax
  8003f7:	75 e2                	jne    8003db <vprintfmt+0x14>
  8003f9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003fd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800404:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80040b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800412:	ba 00 00 00 00       	mov    $0x0,%edx
  800417:	eb 07                	jmp    800420 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800419:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80041c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8d 47 01             	lea    0x1(%edi),%eax
  800423:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800426:	0f b6 07             	movzbl (%edi),%eax
  800429:	0f b6 c8             	movzbl %al,%ecx
  80042c:	83 e8 23             	sub    $0x23,%eax
  80042f:	3c 55                	cmp    $0x55,%al
  800431:	0f 87 1a 03 00 00    	ja     800751 <vprintfmt+0x38a>
  800437:	0f b6 c0             	movzbl %al,%eax
  80043a:	ff 24 85 80 25 80 00 	jmp    *0x802580(,%eax,4)
  800441:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800444:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800448:	eb d6                	jmp    800420 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80044d:	b8 00 00 00 00       	mov    $0x0,%eax
  800452:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800455:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800458:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80045c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80045f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800462:	83 fa 09             	cmp    $0x9,%edx
  800465:	77 39                	ja     8004a0 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800467:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80046a:	eb e9                	jmp    800455 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80046c:	8b 45 14             	mov    0x14(%ebp),%eax
  80046f:	8d 48 04             	lea    0x4(%eax),%ecx
  800472:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800475:	8b 00                	mov    (%eax),%eax
  800477:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80047d:	eb 27                	jmp    8004a6 <vprintfmt+0xdf>
  80047f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800482:	85 c0                	test   %eax,%eax
  800484:	b9 00 00 00 00       	mov    $0x0,%ecx
  800489:	0f 49 c8             	cmovns %eax,%ecx
  80048c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800492:	eb 8c                	jmp    800420 <vprintfmt+0x59>
  800494:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800497:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80049e:	eb 80                	jmp    800420 <vprintfmt+0x59>
  8004a0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004a3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004a6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004aa:	0f 89 70 ff ff ff    	jns    800420 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004b0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004bd:	e9 5e ff ff ff       	jmp    800420 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004c2:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004c8:	e9 53 ff ff ff       	jmp    800420 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d0:	8d 50 04             	lea    0x4(%eax),%edx
  8004d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d6:	83 ec 08             	sub    $0x8,%esp
  8004d9:	53                   	push   %ebx
  8004da:	ff 30                	pushl  (%eax)
  8004dc:	ff d6                	call   *%esi
			break;
  8004de:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004e4:	e9 04 ff ff ff       	jmp    8003ed <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ec:	8d 50 04             	lea    0x4(%eax),%edx
  8004ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f2:	8b 00                	mov    (%eax),%eax
  8004f4:	99                   	cltd   
  8004f5:	31 d0                	xor    %edx,%eax
  8004f7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f9:	83 f8 0f             	cmp    $0xf,%eax
  8004fc:	7f 0b                	jg     800509 <vprintfmt+0x142>
  8004fe:	8b 14 85 e0 26 80 00 	mov    0x8026e0(,%eax,4),%edx
  800505:	85 d2                	test   %edx,%edx
  800507:	75 18                	jne    800521 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800509:	50                   	push   %eax
  80050a:	68 5f 24 80 00       	push   $0x80245f
  80050f:	53                   	push   %ebx
  800510:	56                   	push   %esi
  800511:	e8 94 fe ff ff       	call   8003aa <printfmt>
  800516:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800519:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80051c:	e9 cc fe ff ff       	jmp    8003ed <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800521:	52                   	push   %edx
  800522:	68 91 28 80 00       	push   $0x802891
  800527:	53                   	push   %ebx
  800528:	56                   	push   %esi
  800529:	e8 7c fe ff ff       	call   8003aa <printfmt>
  80052e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800531:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800534:	e9 b4 fe ff ff       	jmp    8003ed <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800539:	8b 45 14             	mov    0x14(%ebp),%eax
  80053c:	8d 50 04             	lea    0x4(%eax),%edx
  80053f:	89 55 14             	mov    %edx,0x14(%ebp)
  800542:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800544:	85 ff                	test   %edi,%edi
  800546:	b8 58 24 80 00       	mov    $0x802458,%eax
  80054b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80054e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800552:	0f 8e 94 00 00 00    	jle    8005ec <vprintfmt+0x225>
  800558:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80055c:	0f 84 98 00 00 00    	je     8005fa <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800562:	83 ec 08             	sub    $0x8,%esp
  800565:	ff 75 d0             	pushl  -0x30(%ebp)
  800568:	57                   	push   %edi
  800569:	e8 86 02 00 00       	call   8007f4 <strnlen>
  80056e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800571:	29 c1                	sub    %eax,%ecx
  800573:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800576:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800579:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80057d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800580:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800583:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800585:	eb 0f                	jmp    800596 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800587:	83 ec 08             	sub    $0x8,%esp
  80058a:	53                   	push   %ebx
  80058b:	ff 75 e0             	pushl  -0x20(%ebp)
  80058e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800590:	83 ef 01             	sub    $0x1,%edi
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	85 ff                	test   %edi,%edi
  800598:	7f ed                	jg     800587 <vprintfmt+0x1c0>
  80059a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80059d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005a0:	85 c9                	test   %ecx,%ecx
  8005a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a7:	0f 49 c1             	cmovns %ecx,%eax
  8005aa:	29 c1                	sub    %eax,%ecx
  8005ac:	89 75 08             	mov    %esi,0x8(%ebp)
  8005af:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005b2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005b5:	89 cb                	mov    %ecx,%ebx
  8005b7:	eb 4d                	jmp    800606 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005bd:	74 1b                	je     8005da <vprintfmt+0x213>
  8005bf:	0f be c0             	movsbl %al,%eax
  8005c2:	83 e8 20             	sub    $0x20,%eax
  8005c5:	83 f8 5e             	cmp    $0x5e,%eax
  8005c8:	76 10                	jbe    8005da <vprintfmt+0x213>
					putch('?', putdat);
  8005ca:	83 ec 08             	sub    $0x8,%esp
  8005cd:	ff 75 0c             	pushl  0xc(%ebp)
  8005d0:	6a 3f                	push   $0x3f
  8005d2:	ff 55 08             	call   *0x8(%ebp)
  8005d5:	83 c4 10             	add    $0x10,%esp
  8005d8:	eb 0d                	jmp    8005e7 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005da:	83 ec 08             	sub    $0x8,%esp
  8005dd:	ff 75 0c             	pushl  0xc(%ebp)
  8005e0:	52                   	push   %edx
  8005e1:	ff 55 08             	call   *0x8(%ebp)
  8005e4:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e7:	83 eb 01             	sub    $0x1,%ebx
  8005ea:	eb 1a                	jmp    800606 <vprintfmt+0x23f>
  8005ec:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ef:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005f2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005f8:	eb 0c                	jmp    800606 <vprintfmt+0x23f>
  8005fa:	89 75 08             	mov    %esi,0x8(%ebp)
  8005fd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800600:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800603:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800606:	83 c7 01             	add    $0x1,%edi
  800609:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80060d:	0f be d0             	movsbl %al,%edx
  800610:	85 d2                	test   %edx,%edx
  800612:	74 23                	je     800637 <vprintfmt+0x270>
  800614:	85 f6                	test   %esi,%esi
  800616:	78 a1                	js     8005b9 <vprintfmt+0x1f2>
  800618:	83 ee 01             	sub    $0x1,%esi
  80061b:	79 9c                	jns    8005b9 <vprintfmt+0x1f2>
  80061d:	89 df                	mov    %ebx,%edi
  80061f:	8b 75 08             	mov    0x8(%ebp),%esi
  800622:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800625:	eb 18                	jmp    80063f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800627:	83 ec 08             	sub    $0x8,%esp
  80062a:	53                   	push   %ebx
  80062b:	6a 20                	push   $0x20
  80062d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80062f:	83 ef 01             	sub    $0x1,%edi
  800632:	83 c4 10             	add    $0x10,%esp
  800635:	eb 08                	jmp    80063f <vprintfmt+0x278>
  800637:	89 df                	mov    %ebx,%edi
  800639:	8b 75 08             	mov    0x8(%ebp),%esi
  80063c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80063f:	85 ff                	test   %edi,%edi
  800641:	7f e4                	jg     800627 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800643:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800646:	e9 a2 fd ff ff       	jmp    8003ed <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80064b:	83 fa 01             	cmp    $0x1,%edx
  80064e:	7e 16                	jle    800666 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8d 50 08             	lea    0x8(%eax),%edx
  800656:	89 55 14             	mov    %edx,0x14(%ebp)
  800659:	8b 50 04             	mov    0x4(%eax),%edx
  80065c:	8b 00                	mov    (%eax),%eax
  80065e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800661:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800664:	eb 32                	jmp    800698 <vprintfmt+0x2d1>
	else if (lflag)
  800666:	85 d2                	test   %edx,%edx
  800668:	74 18                	je     800682 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8d 50 04             	lea    0x4(%eax),%edx
  800670:	89 55 14             	mov    %edx,0x14(%ebp)
  800673:	8b 00                	mov    (%eax),%eax
  800675:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800678:	89 c1                	mov    %eax,%ecx
  80067a:	c1 f9 1f             	sar    $0x1f,%ecx
  80067d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800680:	eb 16                	jmp    800698 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8d 50 04             	lea    0x4(%eax),%edx
  800688:	89 55 14             	mov    %edx,0x14(%ebp)
  80068b:	8b 00                	mov    (%eax),%eax
  80068d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800690:	89 c1                	mov    %eax,%ecx
  800692:	c1 f9 1f             	sar    $0x1f,%ecx
  800695:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800698:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80069b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80069e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006a3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006a7:	79 74                	jns    80071d <vprintfmt+0x356>
				putch('-', putdat);
  8006a9:	83 ec 08             	sub    $0x8,%esp
  8006ac:	53                   	push   %ebx
  8006ad:	6a 2d                	push   $0x2d
  8006af:	ff d6                	call   *%esi
				num = -(long long) num;
  8006b1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006b4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006b7:	f7 d8                	neg    %eax
  8006b9:	83 d2 00             	adc    $0x0,%edx
  8006bc:	f7 da                	neg    %edx
  8006be:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006c1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006c6:	eb 55                	jmp    80071d <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006c8:	8d 45 14             	lea    0x14(%ebp),%eax
  8006cb:	e8 83 fc ff ff       	call   800353 <getuint>
			base = 10;
  8006d0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006d5:	eb 46                	jmp    80071d <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006da:	e8 74 fc ff ff       	call   800353 <getuint>
			base = 8;
  8006df:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006e4:	eb 37                	jmp    80071d <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8006e6:	83 ec 08             	sub    $0x8,%esp
  8006e9:	53                   	push   %ebx
  8006ea:	6a 30                	push   $0x30
  8006ec:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ee:	83 c4 08             	add    $0x8,%esp
  8006f1:	53                   	push   %ebx
  8006f2:	6a 78                	push   $0x78
  8006f4:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f9:	8d 50 04             	lea    0x4(%eax),%edx
  8006fc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006ff:	8b 00                	mov    (%eax),%eax
  800701:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800706:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800709:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80070e:	eb 0d                	jmp    80071d <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800710:	8d 45 14             	lea    0x14(%ebp),%eax
  800713:	e8 3b fc ff ff       	call   800353 <getuint>
			base = 16;
  800718:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80071d:	83 ec 0c             	sub    $0xc,%esp
  800720:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800724:	57                   	push   %edi
  800725:	ff 75 e0             	pushl  -0x20(%ebp)
  800728:	51                   	push   %ecx
  800729:	52                   	push   %edx
  80072a:	50                   	push   %eax
  80072b:	89 da                	mov    %ebx,%edx
  80072d:	89 f0                	mov    %esi,%eax
  80072f:	e8 70 fb ff ff       	call   8002a4 <printnum>
			break;
  800734:	83 c4 20             	add    $0x20,%esp
  800737:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80073a:	e9 ae fc ff ff       	jmp    8003ed <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80073f:	83 ec 08             	sub    $0x8,%esp
  800742:	53                   	push   %ebx
  800743:	51                   	push   %ecx
  800744:	ff d6                	call   *%esi
			break;
  800746:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800749:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80074c:	e9 9c fc ff ff       	jmp    8003ed <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800751:	83 ec 08             	sub    $0x8,%esp
  800754:	53                   	push   %ebx
  800755:	6a 25                	push   $0x25
  800757:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	eb 03                	jmp    800761 <vprintfmt+0x39a>
  80075e:	83 ef 01             	sub    $0x1,%edi
  800761:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800765:	75 f7                	jne    80075e <vprintfmt+0x397>
  800767:	e9 81 fc ff ff       	jmp    8003ed <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80076c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076f:	5b                   	pop    %ebx
  800770:	5e                   	pop    %esi
  800771:	5f                   	pop    %edi
  800772:	5d                   	pop    %ebp
  800773:	c3                   	ret    

00800774 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	83 ec 18             	sub    $0x18,%esp
  80077a:	8b 45 08             	mov    0x8(%ebp),%eax
  80077d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800780:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800783:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800787:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80078a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800791:	85 c0                	test   %eax,%eax
  800793:	74 26                	je     8007bb <vsnprintf+0x47>
  800795:	85 d2                	test   %edx,%edx
  800797:	7e 22                	jle    8007bb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800799:	ff 75 14             	pushl  0x14(%ebp)
  80079c:	ff 75 10             	pushl  0x10(%ebp)
  80079f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a2:	50                   	push   %eax
  8007a3:	68 8d 03 80 00       	push   $0x80038d
  8007a8:	e8 1a fc ff ff       	call   8003c7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b6:	83 c4 10             	add    $0x10,%esp
  8007b9:	eb 05                	jmp    8007c0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007c0:	c9                   	leave  
  8007c1:	c3                   	ret    

008007c2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007cb:	50                   	push   %eax
  8007cc:	ff 75 10             	pushl  0x10(%ebp)
  8007cf:	ff 75 0c             	pushl  0xc(%ebp)
  8007d2:	ff 75 08             	pushl  0x8(%ebp)
  8007d5:	e8 9a ff ff ff       	call   800774 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007da:	c9                   	leave  
  8007db:	c3                   	ret    

008007dc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e7:	eb 03                	jmp    8007ec <strlen+0x10>
		n++;
  8007e9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ec:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f0:	75 f7                	jne    8007e9 <strlen+0xd>
		n++;
	return n;
}
  8007f2:	5d                   	pop    %ebp
  8007f3:	c3                   	ret    

008007f4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007fa:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800802:	eb 03                	jmp    800807 <strnlen+0x13>
		n++;
  800804:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800807:	39 c2                	cmp    %eax,%edx
  800809:	74 08                	je     800813 <strnlen+0x1f>
  80080b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80080f:	75 f3                	jne    800804 <strnlen+0x10>
  800811:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	53                   	push   %ebx
  800819:	8b 45 08             	mov    0x8(%ebp),%eax
  80081c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80081f:	89 c2                	mov    %eax,%edx
  800821:	83 c2 01             	add    $0x1,%edx
  800824:	83 c1 01             	add    $0x1,%ecx
  800827:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80082b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80082e:	84 db                	test   %bl,%bl
  800830:	75 ef                	jne    800821 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800832:	5b                   	pop    %ebx
  800833:	5d                   	pop    %ebp
  800834:	c3                   	ret    

00800835 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	53                   	push   %ebx
  800839:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80083c:	53                   	push   %ebx
  80083d:	e8 9a ff ff ff       	call   8007dc <strlen>
  800842:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800845:	ff 75 0c             	pushl  0xc(%ebp)
  800848:	01 d8                	add    %ebx,%eax
  80084a:	50                   	push   %eax
  80084b:	e8 c5 ff ff ff       	call   800815 <strcpy>
	return dst;
}
  800850:	89 d8                	mov    %ebx,%eax
  800852:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800855:	c9                   	leave  
  800856:	c3                   	ret    

00800857 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	56                   	push   %esi
  80085b:	53                   	push   %ebx
  80085c:	8b 75 08             	mov    0x8(%ebp),%esi
  80085f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800862:	89 f3                	mov    %esi,%ebx
  800864:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800867:	89 f2                	mov    %esi,%edx
  800869:	eb 0f                	jmp    80087a <strncpy+0x23>
		*dst++ = *src;
  80086b:	83 c2 01             	add    $0x1,%edx
  80086e:	0f b6 01             	movzbl (%ecx),%eax
  800871:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800874:	80 39 01             	cmpb   $0x1,(%ecx)
  800877:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80087a:	39 da                	cmp    %ebx,%edx
  80087c:	75 ed                	jne    80086b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80087e:	89 f0                	mov    %esi,%eax
  800880:	5b                   	pop    %ebx
  800881:	5e                   	pop    %esi
  800882:	5d                   	pop    %ebp
  800883:	c3                   	ret    

00800884 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	56                   	push   %esi
  800888:	53                   	push   %ebx
  800889:	8b 75 08             	mov    0x8(%ebp),%esi
  80088c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088f:	8b 55 10             	mov    0x10(%ebp),%edx
  800892:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800894:	85 d2                	test   %edx,%edx
  800896:	74 21                	je     8008b9 <strlcpy+0x35>
  800898:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80089c:	89 f2                	mov    %esi,%edx
  80089e:	eb 09                	jmp    8008a9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008a0:	83 c2 01             	add    $0x1,%edx
  8008a3:	83 c1 01             	add    $0x1,%ecx
  8008a6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a9:	39 c2                	cmp    %eax,%edx
  8008ab:	74 09                	je     8008b6 <strlcpy+0x32>
  8008ad:	0f b6 19             	movzbl (%ecx),%ebx
  8008b0:	84 db                	test   %bl,%bl
  8008b2:	75 ec                	jne    8008a0 <strlcpy+0x1c>
  8008b4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008b6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b9:	29 f0                	sub    %esi,%eax
}
  8008bb:	5b                   	pop    %ebx
  8008bc:	5e                   	pop    %esi
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c8:	eb 06                	jmp    8008d0 <strcmp+0x11>
		p++, q++;
  8008ca:	83 c1 01             	add    $0x1,%ecx
  8008cd:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008d0:	0f b6 01             	movzbl (%ecx),%eax
  8008d3:	84 c0                	test   %al,%al
  8008d5:	74 04                	je     8008db <strcmp+0x1c>
  8008d7:	3a 02                	cmp    (%edx),%al
  8008d9:	74 ef                	je     8008ca <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008db:	0f b6 c0             	movzbl %al,%eax
  8008de:	0f b6 12             	movzbl (%edx),%edx
  8008e1:	29 d0                	sub    %edx,%eax
}
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    

008008e5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	53                   	push   %ebx
  8008e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ef:	89 c3                	mov    %eax,%ebx
  8008f1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008f4:	eb 06                	jmp    8008fc <strncmp+0x17>
		n--, p++, q++;
  8008f6:	83 c0 01             	add    $0x1,%eax
  8008f9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008fc:	39 d8                	cmp    %ebx,%eax
  8008fe:	74 15                	je     800915 <strncmp+0x30>
  800900:	0f b6 08             	movzbl (%eax),%ecx
  800903:	84 c9                	test   %cl,%cl
  800905:	74 04                	je     80090b <strncmp+0x26>
  800907:	3a 0a                	cmp    (%edx),%cl
  800909:	74 eb                	je     8008f6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80090b:	0f b6 00             	movzbl (%eax),%eax
  80090e:	0f b6 12             	movzbl (%edx),%edx
  800911:	29 d0                	sub    %edx,%eax
  800913:	eb 05                	jmp    80091a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800915:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80091a:	5b                   	pop    %ebx
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
  800923:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800927:	eb 07                	jmp    800930 <strchr+0x13>
		if (*s == c)
  800929:	38 ca                	cmp    %cl,%dl
  80092b:	74 0f                	je     80093c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80092d:	83 c0 01             	add    $0x1,%eax
  800930:	0f b6 10             	movzbl (%eax),%edx
  800933:	84 d2                	test   %dl,%dl
  800935:	75 f2                	jne    800929 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800937:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	8b 45 08             	mov    0x8(%ebp),%eax
  800944:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800948:	eb 03                	jmp    80094d <strfind+0xf>
  80094a:	83 c0 01             	add    $0x1,%eax
  80094d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800950:	38 ca                	cmp    %cl,%dl
  800952:	74 04                	je     800958 <strfind+0x1a>
  800954:	84 d2                	test   %dl,%dl
  800956:	75 f2                	jne    80094a <strfind+0xc>
			break;
	return (char *) s;
}
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	57                   	push   %edi
  80095e:	56                   	push   %esi
  80095f:	53                   	push   %ebx
  800960:	8b 7d 08             	mov    0x8(%ebp),%edi
  800963:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800966:	85 c9                	test   %ecx,%ecx
  800968:	74 36                	je     8009a0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80096a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800970:	75 28                	jne    80099a <memset+0x40>
  800972:	f6 c1 03             	test   $0x3,%cl
  800975:	75 23                	jne    80099a <memset+0x40>
		c &= 0xFF;
  800977:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80097b:	89 d3                	mov    %edx,%ebx
  80097d:	c1 e3 08             	shl    $0x8,%ebx
  800980:	89 d6                	mov    %edx,%esi
  800982:	c1 e6 18             	shl    $0x18,%esi
  800985:	89 d0                	mov    %edx,%eax
  800987:	c1 e0 10             	shl    $0x10,%eax
  80098a:	09 f0                	or     %esi,%eax
  80098c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80098e:	89 d8                	mov    %ebx,%eax
  800990:	09 d0                	or     %edx,%eax
  800992:	c1 e9 02             	shr    $0x2,%ecx
  800995:	fc                   	cld    
  800996:	f3 ab                	rep stos %eax,%es:(%edi)
  800998:	eb 06                	jmp    8009a0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80099a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099d:	fc                   	cld    
  80099e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009a0:	89 f8                	mov    %edi,%eax
  8009a2:	5b                   	pop    %ebx
  8009a3:	5e                   	pop    %esi
  8009a4:	5f                   	pop    %edi
  8009a5:	5d                   	pop    %ebp
  8009a6:	c3                   	ret    

008009a7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	57                   	push   %edi
  8009ab:	56                   	push   %esi
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b5:	39 c6                	cmp    %eax,%esi
  8009b7:	73 35                	jae    8009ee <memmove+0x47>
  8009b9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009bc:	39 d0                	cmp    %edx,%eax
  8009be:	73 2e                	jae    8009ee <memmove+0x47>
		s += n;
		d += n;
  8009c0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c3:	89 d6                	mov    %edx,%esi
  8009c5:	09 fe                	or     %edi,%esi
  8009c7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009cd:	75 13                	jne    8009e2 <memmove+0x3b>
  8009cf:	f6 c1 03             	test   $0x3,%cl
  8009d2:	75 0e                	jne    8009e2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009d4:	83 ef 04             	sub    $0x4,%edi
  8009d7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009da:	c1 e9 02             	shr    $0x2,%ecx
  8009dd:	fd                   	std    
  8009de:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e0:	eb 09                	jmp    8009eb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009e2:	83 ef 01             	sub    $0x1,%edi
  8009e5:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009e8:	fd                   	std    
  8009e9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009eb:	fc                   	cld    
  8009ec:	eb 1d                	jmp    800a0b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ee:	89 f2                	mov    %esi,%edx
  8009f0:	09 c2                	or     %eax,%edx
  8009f2:	f6 c2 03             	test   $0x3,%dl
  8009f5:	75 0f                	jne    800a06 <memmove+0x5f>
  8009f7:	f6 c1 03             	test   $0x3,%cl
  8009fa:	75 0a                	jne    800a06 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009fc:	c1 e9 02             	shr    $0x2,%ecx
  8009ff:	89 c7                	mov    %eax,%edi
  800a01:	fc                   	cld    
  800a02:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a04:	eb 05                	jmp    800a0b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a06:	89 c7                	mov    %eax,%edi
  800a08:	fc                   	cld    
  800a09:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a0b:	5e                   	pop    %esi
  800a0c:	5f                   	pop    %edi
  800a0d:	5d                   	pop    %ebp
  800a0e:	c3                   	ret    

00800a0f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a12:	ff 75 10             	pushl  0x10(%ebp)
  800a15:	ff 75 0c             	pushl  0xc(%ebp)
  800a18:	ff 75 08             	pushl  0x8(%ebp)
  800a1b:	e8 87 ff ff ff       	call   8009a7 <memmove>
}
  800a20:	c9                   	leave  
  800a21:	c3                   	ret    

00800a22 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	56                   	push   %esi
  800a26:	53                   	push   %ebx
  800a27:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2d:	89 c6                	mov    %eax,%esi
  800a2f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a32:	eb 1a                	jmp    800a4e <memcmp+0x2c>
		if (*s1 != *s2)
  800a34:	0f b6 08             	movzbl (%eax),%ecx
  800a37:	0f b6 1a             	movzbl (%edx),%ebx
  800a3a:	38 d9                	cmp    %bl,%cl
  800a3c:	74 0a                	je     800a48 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a3e:	0f b6 c1             	movzbl %cl,%eax
  800a41:	0f b6 db             	movzbl %bl,%ebx
  800a44:	29 d8                	sub    %ebx,%eax
  800a46:	eb 0f                	jmp    800a57 <memcmp+0x35>
		s1++, s2++;
  800a48:	83 c0 01             	add    $0x1,%eax
  800a4b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4e:	39 f0                	cmp    %esi,%eax
  800a50:	75 e2                	jne    800a34 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a52:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a57:	5b                   	pop    %ebx
  800a58:	5e                   	pop    %esi
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	53                   	push   %ebx
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a62:	89 c1                	mov    %eax,%ecx
  800a64:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a67:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a6b:	eb 0a                	jmp    800a77 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a6d:	0f b6 10             	movzbl (%eax),%edx
  800a70:	39 da                	cmp    %ebx,%edx
  800a72:	74 07                	je     800a7b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a74:	83 c0 01             	add    $0x1,%eax
  800a77:	39 c8                	cmp    %ecx,%eax
  800a79:	72 f2                	jb     800a6d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a7b:	5b                   	pop    %ebx
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	57                   	push   %edi
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
  800a84:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8a:	eb 03                	jmp    800a8f <strtol+0x11>
		s++;
  800a8c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8f:	0f b6 01             	movzbl (%ecx),%eax
  800a92:	3c 20                	cmp    $0x20,%al
  800a94:	74 f6                	je     800a8c <strtol+0xe>
  800a96:	3c 09                	cmp    $0x9,%al
  800a98:	74 f2                	je     800a8c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a9a:	3c 2b                	cmp    $0x2b,%al
  800a9c:	75 0a                	jne    800aa8 <strtol+0x2a>
		s++;
  800a9e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa1:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa6:	eb 11                	jmp    800ab9 <strtol+0x3b>
  800aa8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aad:	3c 2d                	cmp    $0x2d,%al
  800aaf:	75 08                	jne    800ab9 <strtol+0x3b>
		s++, neg = 1;
  800ab1:	83 c1 01             	add    $0x1,%ecx
  800ab4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800abf:	75 15                	jne    800ad6 <strtol+0x58>
  800ac1:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac4:	75 10                	jne    800ad6 <strtol+0x58>
  800ac6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aca:	75 7c                	jne    800b48 <strtol+0xca>
		s += 2, base = 16;
  800acc:	83 c1 02             	add    $0x2,%ecx
  800acf:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad4:	eb 16                	jmp    800aec <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ad6:	85 db                	test   %ebx,%ebx
  800ad8:	75 12                	jne    800aec <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ada:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800adf:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae2:	75 08                	jne    800aec <strtol+0x6e>
		s++, base = 8;
  800ae4:	83 c1 01             	add    $0x1,%ecx
  800ae7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aec:	b8 00 00 00 00       	mov    $0x0,%eax
  800af1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af4:	0f b6 11             	movzbl (%ecx),%edx
  800af7:	8d 72 d0             	lea    -0x30(%edx),%esi
  800afa:	89 f3                	mov    %esi,%ebx
  800afc:	80 fb 09             	cmp    $0x9,%bl
  800aff:	77 08                	ja     800b09 <strtol+0x8b>
			dig = *s - '0';
  800b01:	0f be d2             	movsbl %dl,%edx
  800b04:	83 ea 30             	sub    $0x30,%edx
  800b07:	eb 22                	jmp    800b2b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b09:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b0c:	89 f3                	mov    %esi,%ebx
  800b0e:	80 fb 19             	cmp    $0x19,%bl
  800b11:	77 08                	ja     800b1b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b13:	0f be d2             	movsbl %dl,%edx
  800b16:	83 ea 57             	sub    $0x57,%edx
  800b19:	eb 10                	jmp    800b2b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b1b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b1e:	89 f3                	mov    %esi,%ebx
  800b20:	80 fb 19             	cmp    $0x19,%bl
  800b23:	77 16                	ja     800b3b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b25:	0f be d2             	movsbl %dl,%edx
  800b28:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b2b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b2e:	7d 0b                	jge    800b3b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b30:	83 c1 01             	add    $0x1,%ecx
  800b33:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b37:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b39:	eb b9                	jmp    800af4 <strtol+0x76>

	if (endptr)
  800b3b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b3f:	74 0d                	je     800b4e <strtol+0xd0>
		*endptr = (char *) s;
  800b41:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b44:	89 0e                	mov    %ecx,(%esi)
  800b46:	eb 06                	jmp    800b4e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b48:	85 db                	test   %ebx,%ebx
  800b4a:	74 98                	je     800ae4 <strtol+0x66>
  800b4c:	eb 9e                	jmp    800aec <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b4e:	89 c2                	mov    %eax,%edx
  800b50:	f7 da                	neg    %edx
  800b52:	85 ff                	test   %edi,%edi
  800b54:	0f 45 c2             	cmovne %edx,%eax
}
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b62:	b8 00 00 00 00       	mov    $0x0,%eax
  800b67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6d:	89 c3                	mov    %eax,%ebx
  800b6f:	89 c7                	mov    %eax,%edi
  800b71:	89 c6                	mov    %eax,%esi
  800b73:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b75:	5b                   	pop    %ebx
  800b76:	5e                   	pop    %esi
  800b77:	5f                   	pop    %edi
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	57                   	push   %edi
  800b7e:	56                   	push   %esi
  800b7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b80:	ba 00 00 00 00       	mov    $0x0,%edx
  800b85:	b8 01 00 00 00       	mov    $0x1,%eax
  800b8a:	89 d1                	mov    %edx,%ecx
  800b8c:	89 d3                	mov    %edx,%ebx
  800b8e:	89 d7                	mov    %edx,%edi
  800b90:	89 d6                	mov    %edx,%esi
  800b92:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b94:	5b                   	pop    %ebx
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    

00800b99 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	57                   	push   %edi
  800b9d:	56                   	push   %esi
  800b9e:	53                   	push   %ebx
  800b9f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba7:	b8 03 00 00 00       	mov    $0x3,%eax
  800bac:	8b 55 08             	mov    0x8(%ebp),%edx
  800baf:	89 cb                	mov    %ecx,%ebx
  800bb1:	89 cf                	mov    %ecx,%edi
  800bb3:	89 ce                	mov    %ecx,%esi
  800bb5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb7:	85 c0                	test   %eax,%eax
  800bb9:	7e 17                	jle    800bd2 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbb:	83 ec 0c             	sub    $0xc,%esp
  800bbe:	50                   	push   %eax
  800bbf:	6a 03                	push   $0x3
  800bc1:	68 3f 27 80 00       	push   $0x80273f
  800bc6:	6a 23                	push   $0x23
  800bc8:	68 5c 27 80 00       	push   $0x80275c
  800bcd:	e8 e5 f5 ff ff       	call   8001b7 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5f                   	pop    %edi
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	57                   	push   %edi
  800bde:	56                   	push   %esi
  800bdf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be0:	ba 00 00 00 00       	mov    $0x0,%edx
  800be5:	b8 02 00 00 00       	mov    $0x2,%eax
  800bea:	89 d1                	mov    %edx,%ecx
  800bec:	89 d3                	mov    %edx,%ebx
  800bee:	89 d7                	mov    %edx,%edi
  800bf0:	89 d6                	mov    %edx,%esi
  800bf2:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <sys_yield>:

void
sys_yield(void)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bff:	ba 00 00 00 00       	mov    $0x0,%edx
  800c04:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c09:	89 d1                	mov    %edx,%ecx
  800c0b:	89 d3                	mov    %edx,%ebx
  800c0d:	89 d7                	mov    %edx,%edi
  800c0f:	89 d6                	mov    %edx,%esi
  800c11:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5f                   	pop    %edi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	57                   	push   %edi
  800c1c:	56                   	push   %esi
  800c1d:	53                   	push   %ebx
  800c1e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c21:	be 00 00 00 00       	mov    $0x0,%esi
  800c26:	b8 04 00 00 00       	mov    $0x4,%eax
  800c2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c31:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c34:	89 f7                	mov    %esi,%edi
  800c36:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c38:	85 c0                	test   %eax,%eax
  800c3a:	7e 17                	jle    800c53 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3c:	83 ec 0c             	sub    $0xc,%esp
  800c3f:	50                   	push   %eax
  800c40:	6a 04                	push   $0x4
  800c42:	68 3f 27 80 00       	push   $0x80273f
  800c47:	6a 23                	push   $0x23
  800c49:	68 5c 27 80 00       	push   $0x80275c
  800c4e:	e8 64 f5 ff ff       	call   8001b7 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	57                   	push   %edi
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
  800c61:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c64:	b8 05 00 00 00       	mov    $0x5,%eax
  800c69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c72:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c75:	8b 75 18             	mov    0x18(%ebp),%esi
  800c78:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7a:	85 c0                	test   %eax,%eax
  800c7c:	7e 17                	jle    800c95 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7e:	83 ec 0c             	sub    $0xc,%esp
  800c81:	50                   	push   %eax
  800c82:	6a 05                	push   $0x5
  800c84:	68 3f 27 80 00       	push   $0x80273f
  800c89:	6a 23                	push   $0x23
  800c8b:	68 5c 27 80 00       	push   $0x80275c
  800c90:	e8 22 f5 ff ff       	call   8001b7 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c98:	5b                   	pop    %ebx
  800c99:	5e                   	pop    %esi
  800c9a:	5f                   	pop    %edi
  800c9b:	5d                   	pop    %ebp
  800c9c:	c3                   	ret    

00800c9d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	57                   	push   %edi
  800ca1:	56                   	push   %esi
  800ca2:	53                   	push   %ebx
  800ca3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cab:	b8 06 00 00 00       	mov    $0x6,%eax
  800cb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb6:	89 df                	mov    %ebx,%edi
  800cb8:	89 de                	mov    %ebx,%esi
  800cba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbc:	85 c0                	test   %eax,%eax
  800cbe:	7e 17                	jle    800cd7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc0:	83 ec 0c             	sub    $0xc,%esp
  800cc3:	50                   	push   %eax
  800cc4:	6a 06                	push   $0x6
  800cc6:	68 3f 27 80 00       	push   $0x80273f
  800ccb:	6a 23                	push   $0x23
  800ccd:	68 5c 27 80 00       	push   $0x80275c
  800cd2:	e8 e0 f4 ff ff       	call   8001b7 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800ce8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ced:	b8 08 00 00 00       	mov    $0x8,%eax
  800cf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf8:	89 df                	mov    %ebx,%edi
  800cfa:	89 de                	mov    %ebx,%esi
  800cfc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	7e 17                	jle    800d19 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	50                   	push   %eax
  800d06:	6a 08                	push   $0x8
  800d08:	68 3f 27 80 00       	push   $0x80273f
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 5c 27 80 00       	push   $0x80275c
  800d14:	e8 9e f4 ff ff       	call   8001b7 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	57                   	push   %edi
  800d25:	56                   	push   %esi
  800d26:	53                   	push   %ebx
  800d27:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2f:	b8 09 00 00 00       	mov    $0x9,%eax
  800d34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d37:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3a:	89 df                	mov    %ebx,%edi
  800d3c:	89 de                	mov    %ebx,%esi
  800d3e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d40:	85 c0                	test   %eax,%eax
  800d42:	7e 17                	jle    800d5b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d44:	83 ec 0c             	sub    $0xc,%esp
  800d47:	50                   	push   %eax
  800d48:	6a 09                	push   $0x9
  800d4a:	68 3f 27 80 00       	push   $0x80273f
  800d4f:	6a 23                	push   $0x23
  800d51:	68 5c 27 80 00       	push   $0x80275c
  800d56:	e8 5c f4 ff ff       	call   8001b7 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	57                   	push   %edi
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
  800d69:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d71:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	89 df                	mov    %ebx,%edi
  800d7e:	89 de                	mov    %ebx,%esi
  800d80:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d82:	85 c0                	test   %eax,%eax
  800d84:	7e 17                	jle    800d9d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d86:	83 ec 0c             	sub    $0xc,%esp
  800d89:	50                   	push   %eax
  800d8a:	6a 0a                	push   $0xa
  800d8c:	68 3f 27 80 00       	push   $0x80273f
  800d91:	6a 23                	push   $0x23
  800d93:	68 5c 27 80 00       	push   $0x80275c
  800d98:	e8 1a f4 ff ff       	call   8001b7 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	57                   	push   %edi
  800da9:	56                   	push   %esi
  800daa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dab:	be 00 00 00 00       	mov    $0x0,%esi
  800db0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800db5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dbe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dc1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
  800dce:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd6:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ddb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dde:	89 cb                	mov    %ecx,%ebx
  800de0:	89 cf                	mov    %ecx,%edi
  800de2:	89 ce                	mov    %ecx,%esi
  800de4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de6:	85 c0                	test   %eax,%eax
  800de8:	7e 17                	jle    800e01 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dea:	83 ec 0c             	sub    $0xc,%esp
  800ded:	50                   	push   %eax
  800dee:	6a 0d                	push   $0xd
  800df0:	68 3f 27 80 00       	push   $0x80273f
  800df5:	6a 23                	push   $0x23
  800df7:	68 5c 27 80 00       	push   $0x80275c
  800dfc:	e8 b6 f3 ff ff       	call   8001b7 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e04:	5b                   	pop    %ebx
  800e05:	5e                   	pop    %esi
  800e06:	5f                   	pop    %edi
  800e07:	5d                   	pop    %ebp
  800e08:	c3                   	ret    

00800e09 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	57                   	push   %edi
  800e0d:	56                   	push   %esi
  800e0e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e14:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e19:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1c:	89 cb                	mov    %ecx,%ebx
  800e1e:	89 cf                	mov    %ecx,%edi
  800e20:	89 ce                	mov    %ecx,%esi
  800e22:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e34:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e39:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3c:	89 cb                	mov    %ecx,%ebx
  800e3e:	89 cf                	mov    %ecx,%edi
  800e40:	89 ce                	mov    %ecx,%esi
  800e42:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800e44:	5b                   	pop    %ebx
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	53                   	push   %ebx
  800e4d:	83 ec 04             	sub    $0x4,%esp
  800e50:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e53:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800e55:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e59:	74 11                	je     800e6c <pgfault+0x23>
  800e5b:	89 d8                	mov    %ebx,%eax
  800e5d:	c1 e8 0c             	shr    $0xc,%eax
  800e60:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e67:	f6 c4 08             	test   $0x8,%ah
  800e6a:	75 14                	jne    800e80 <pgfault+0x37>
		panic("faulting access");
  800e6c:	83 ec 04             	sub    $0x4,%esp
  800e6f:	68 6a 27 80 00       	push   $0x80276a
  800e74:	6a 1e                	push   $0x1e
  800e76:	68 7a 27 80 00       	push   $0x80277a
  800e7b:	e8 37 f3 ff ff       	call   8001b7 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e80:	83 ec 04             	sub    $0x4,%esp
  800e83:	6a 07                	push   $0x7
  800e85:	68 00 f0 7f 00       	push   $0x7ff000
  800e8a:	6a 00                	push   $0x0
  800e8c:	e8 87 fd ff ff       	call   800c18 <sys_page_alloc>
	if (r < 0) {
  800e91:	83 c4 10             	add    $0x10,%esp
  800e94:	85 c0                	test   %eax,%eax
  800e96:	79 12                	jns    800eaa <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e98:	50                   	push   %eax
  800e99:	68 85 27 80 00       	push   $0x802785
  800e9e:	6a 2c                	push   $0x2c
  800ea0:	68 7a 27 80 00       	push   $0x80277a
  800ea5:	e8 0d f3 ff ff       	call   8001b7 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800eaa:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800eb0:	83 ec 04             	sub    $0x4,%esp
  800eb3:	68 00 10 00 00       	push   $0x1000
  800eb8:	53                   	push   %ebx
  800eb9:	68 00 f0 7f 00       	push   $0x7ff000
  800ebe:	e8 4c fb ff ff       	call   800a0f <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800ec3:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800eca:	53                   	push   %ebx
  800ecb:	6a 00                	push   $0x0
  800ecd:	68 00 f0 7f 00       	push   $0x7ff000
  800ed2:	6a 00                	push   $0x0
  800ed4:	e8 82 fd ff ff       	call   800c5b <sys_page_map>
	if (r < 0) {
  800ed9:	83 c4 20             	add    $0x20,%esp
  800edc:	85 c0                	test   %eax,%eax
  800ede:	79 12                	jns    800ef2 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800ee0:	50                   	push   %eax
  800ee1:	68 85 27 80 00       	push   $0x802785
  800ee6:	6a 33                	push   $0x33
  800ee8:	68 7a 27 80 00       	push   $0x80277a
  800eed:	e8 c5 f2 ff ff       	call   8001b7 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800ef2:	83 ec 08             	sub    $0x8,%esp
  800ef5:	68 00 f0 7f 00       	push   $0x7ff000
  800efa:	6a 00                	push   $0x0
  800efc:	e8 9c fd ff ff       	call   800c9d <sys_page_unmap>
	if (r < 0) {
  800f01:	83 c4 10             	add    $0x10,%esp
  800f04:	85 c0                	test   %eax,%eax
  800f06:	79 12                	jns    800f1a <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800f08:	50                   	push   %eax
  800f09:	68 85 27 80 00       	push   $0x802785
  800f0e:	6a 37                	push   $0x37
  800f10:	68 7a 27 80 00       	push   $0x80277a
  800f15:	e8 9d f2 ff ff       	call   8001b7 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800f1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f1d:	c9                   	leave  
  800f1e:	c3                   	ret    

00800f1f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
  800f22:	57                   	push   %edi
  800f23:	56                   	push   %esi
  800f24:	53                   	push   %ebx
  800f25:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800f28:	68 49 0e 80 00       	push   $0x800e49
  800f2d:	e8 03 10 00 00       	call   801f35 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f32:	b8 07 00 00 00       	mov    $0x7,%eax
  800f37:	cd 30                	int    $0x30
  800f39:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800f3c:	83 c4 10             	add    $0x10,%esp
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	79 17                	jns    800f5a <fork+0x3b>
		panic("fork fault %e");
  800f43:	83 ec 04             	sub    $0x4,%esp
  800f46:	68 9e 27 80 00       	push   $0x80279e
  800f4b:	68 84 00 00 00       	push   $0x84
  800f50:	68 7a 27 80 00       	push   $0x80277a
  800f55:	e8 5d f2 ff ff       	call   8001b7 <_panic>
  800f5a:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f5c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f60:	75 25                	jne    800f87 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f62:	e8 73 fc ff ff       	call   800bda <sys_getenvid>
  800f67:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f6c:	89 c2                	mov    %eax,%edx
  800f6e:	c1 e2 07             	shl    $0x7,%edx
  800f71:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800f78:	a3 20 60 80 00       	mov    %eax,0x806020
		return 0;
  800f7d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f82:	e9 61 01 00 00       	jmp    8010e8 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f87:	83 ec 04             	sub    $0x4,%esp
  800f8a:	6a 07                	push   $0x7
  800f8c:	68 00 f0 bf ee       	push   $0xeebff000
  800f91:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f94:	e8 7f fc ff ff       	call   800c18 <sys_page_alloc>
  800f99:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f9c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fa1:	89 d8                	mov    %ebx,%eax
  800fa3:	c1 e8 16             	shr    $0x16,%eax
  800fa6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fad:	a8 01                	test   $0x1,%al
  800faf:	0f 84 fc 00 00 00    	je     8010b1 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800fb5:	89 d8                	mov    %ebx,%eax
  800fb7:	c1 e8 0c             	shr    $0xc,%eax
  800fba:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fc1:	f6 c2 01             	test   $0x1,%dl
  800fc4:	0f 84 e7 00 00 00    	je     8010b1 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800fca:	89 c6                	mov    %eax,%esi
  800fcc:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800fcf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fd6:	f6 c6 04             	test   $0x4,%dh
  800fd9:	74 39                	je     801014 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800fdb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fe2:	83 ec 0c             	sub    $0xc,%esp
  800fe5:	25 07 0e 00 00       	and    $0xe07,%eax
  800fea:	50                   	push   %eax
  800feb:	56                   	push   %esi
  800fec:	57                   	push   %edi
  800fed:	56                   	push   %esi
  800fee:	6a 00                	push   $0x0
  800ff0:	e8 66 fc ff ff       	call   800c5b <sys_page_map>
		if (r < 0) {
  800ff5:	83 c4 20             	add    $0x20,%esp
  800ff8:	85 c0                	test   %eax,%eax
  800ffa:	0f 89 b1 00 00 00    	jns    8010b1 <fork+0x192>
		    	panic("sys page map fault %e");
  801000:	83 ec 04             	sub    $0x4,%esp
  801003:	68 ac 27 80 00       	push   $0x8027ac
  801008:	6a 54                	push   $0x54
  80100a:	68 7a 27 80 00       	push   $0x80277a
  80100f:	e8 a3 f1 ff ff       	call   8001b7 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801014:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80101b:	f6 c2 02             	test   $0x2,%dl
  80101e:	75 0c                	jne    80102c <fork+0x10d>
  801020:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801027:	f6 c4 08             	test   $0x8,%ah
  80102a:	74 5b                	je     801087 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80102c:	83 ec 0c             	sub    $0xc,%esp
  80102f:	68 05 08 00 00       	push   $0x805
  801034:	56                   	push   %esi
  801035:	57                   	push   %edi
  801036:	56                   	push   %esi
  801037:	6a 00                	push   $0x0
  801039:	e8 1d fc ff ff       	call   800c5b <sys_page_map>
		if (r < 0) {
  80103e:	83 c4 20             	add    $0x20,%esp
  801041:	85 c0                	test   %eax,%eax
  801043:	79 14                	jns    801059 <fork+0x13a>
		    	panic("sys page map fault %e");
  801045:	83 ec 04             	sub    $0x4,%esp
  801048:	68 ac 27 80 00       	push   $0x8027ac
  80104d:	6a 5b                	push   $0x5b
  80104f:	68 7a 27 80 00       	push   $0x80277a
  801054:	e8 5e f1 ff ff       	call   8001b7 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  801059:	83 ec 0c             	sub    $0xc,%esp
  80105c:	68 05 08 00 00       	push   $0x805
  801061:	56                   	push   %esi
  801062:	6a 00                	push   $0x0
  801064:	56                   	push   %esi
  801065:	6a 00                	push   $0x0
  801067:	e8 ef fb ff ff       	call   800c5b <sys_page_map>
		if (r < 0) {
  80106c:	83 c4 20             	add    $0x20,%esp
  80106f:	85 c0                	test   %eax,%eax
  801071:	79 3e                	jns    8010b1 <fork+0x192>
		    	panic("sys page map fault %e");
  801073:	83 ec 04             	sub    $0x4,%esp
  801076:	68 ac 27 80 00       	push   $0x8027ac
  80107b:	6a 5f                	push   $0x5f
  80107d:	68 7a 27 80 00       	push   $0x80277a
  801082:	e8 30 f1 ff ff       	call   8001b7 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801087:	83 ec 0c             	sub    $0xc,%esp
  80108a:	6a 05                	push   $0x5
  80108c:	56                   	push   %esi
  80108d:	57                   	push   %edi
  80108e:	56                   	push   %esi
  80108f:	6a 00                	push   $0x0
  801091:	e8 c5 fb ff ff       	call   800c5b <sys_page_map>
		if (r < 0) {
  801096:	83 c4 20             	add    $0x20,%esp
  801099:	85 c0                	test   %eax,%eax
  80109b:	79 14                	jns    8010b1 <fork+0x192>
		    	panic("sys page map fault %e");
  80109d:	83 ec 04             	sub    $0x4,%esp
  8010a0:	68 ac 27 80 00       	push   $0x8027ac
  8010a5:	6a 64                	push   $0x64
  8010a7:	68 7a 27 80 00       	push   $0x80277a
  8010ac:	e8 06 f1 ff ff       	call   8001b7 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8010b1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010b7:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8010bd:	0f 85 de fe ff ff    	jne    800fa1 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8010c3:	a1 20 60 80 00       	mov    0x806020,%eax
  8010c8:	8b 40 70             	mov    0x70(%eax),%eax
  8010cb:	83 ec 08             	sub    $0x8,%esp
  8010ce:	50                   	push   %eax
  8010cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010d2:	57                   	push   %edi
  8010d3:	e8 8b fc ff ff       	call   800d63 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8010d8:	83 c4 08             	add    $0x8,%esp
  8010db:	6a 02                	push   $0x2
  8010dd:	57                   	push   %edi
  8010de:	e8 fc fb ff ff       	call   800cdf <sys_env_set_status>
	
	return envid;
  8010e3:	83 c4 10             	add    $0x10,%esp
  8010e6:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8010e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010eb:	5b                   	pop    %ebx
  8010ec:	5e                   	pop    %esi
  8010ed:	5f                   	pop    %edi
  8010ee:	5d                   	pop    %ebp
  8010ef:	c3                   	ret    

008010f0 <sfork>:

envid_t
sfork(void)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
	return 0;
}
  8010f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f8:	5d                   	pop    %ebp
  8010f9:	c3                   	ret    

008010fa <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8010fa:	55                   	push   %ebp
  8010fb:	89 e5                	mov    %esp,%ebp
  8010fd:	56                   	push   %esi
  8010fe:	53                   	push   %ebx
  8010ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801102:	89 1d 24 60 80 00    	mov    %ebx,0x806024
	cprintf("in fork.c thread create. func: %x\n", func);
  801108:	83 ec 08             	sub    $0x8,%esp
  80110b:	53                   	push   %ebx
  80110c:	68 c4 27 80 00       	push   $0x8027c4
  801111:	e8 7a f1 ff ff       	call   800290 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801116:	c7 04 24 7d 01 80 00 	movl   $0x80017d,(%esp)
  80111d:	e8 e7 fc ff ff       	call   800e09 <sys_thread_create>
  801122:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801124:	83 c4 08             	add    $0x8,%esp
  801127:	53                   	push   %ebx
  801128:	68 c4 27 80 00       	push   $0x8027c4
  80112d:	e8 5e f1 ff ff       	call   800290 <cprintf>
	return id;
	//return 0;
}
  801132:	89 f0                	mov    %esi,%eax
  801134:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801137:	5b                   	pop    %ebx
  801138:	5e                   	pop    %esi
  801139:	5d                   	pop    %ebp
  80113a:	c3                   	ret    

0080113b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80113b:	55                   	push   %ebp
  80113c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80113e:	8b 45 08             	mov    0x8(%ebp),%eax
  801141:	05 00 00 00 30       	add    $0x30000000,%eax
  801146:	c1 e8 0c             	shr    $0xc,%eax
}
  801149:	5d                   	pop    %ebp
  80114a:	c3                   	ret    

0080114b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80114b:	55                   	push   %ebp
  80114c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80114e:	8b 45 08             	mov    0x8(%ebp),%eax
  801151:	05 00 00 00 30       	add    $0x30000000,%eax
  801156:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80115b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801160:	5d                   	pop    %ebp
  801161:	c3                   	ret    

00801162 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801162:	55                   	push   %ebp
  801163:	89 e5                	mov    %esp,%ebp
  801165:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801168:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80116d:	89 c2                	mov    %eax,%edx
  80116f:	c1 ea 16             	shr    $0x16,%edx
  801172:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801179:	f6 c2 01             	test   $0x1,%dl
  80117c:	74 11                	je     80118f <fd_alloc+0x2d>
  80117e:	89 c2                	mov    %eax,%edx
  801180:	c1 ea 0c             	shr    $0xc,%edx
  801183:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80118a:	f6 c2 01             	test   $0x1,%dl
  80118d:	75 09                	jne    801198 <fd_alloc+0x36>
			*fd_store = fd;
  80118f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801191:	b8 00 00 00 00       	mov    $0x0,%eax
  801196:	eb 17                	jmp    8011af <fd_alloc+0x4d>
  801198:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80119d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011a2:	75 c9                	jne    80116d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011a4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011aa:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011af:	5d                   	pop    %ebp
  8011b0:	c3                   	ret    

008011b1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011b1:	55                   	push   %ebp
  8011b2:	89 e5                	mov    %esp,%ebp
  8011b4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011b7:	83 f8 1f             	cmp    $0x1f,%eax
  8011ba:	77 36                	ja     8011f2 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011bc:	c1 e0 0c             	shl    $0xc,%eax
  8011bf:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011c4:	89 c2                	mov    %eax,%edx
  8011c6:	c1 ea 16             	shr    $0x16,%edx
  8011c9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011d0:	f6 c2 01             	test   $0x1,%dl
  8011d3:	74 24                	je     8011f9 <fd_lookup+0x48>
  8011d5:	89 c2                	mov    %eax,%edx
  8011d7:	c1 ea 0c             	shr    $0xc,%edx
  8011da:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011e1:	f6 c2 01             	test   $0x1,%dl
  8011e4:	74 1a                	je     801200 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e9:	89 02                	mov    %eax,(%edx)
	return 0;
  8011eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f0:	eb 13                	jmp    801205 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f7:	eb 0c                	jmp    801205 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011fe:	eb 05                	jmp    801205 <fd_lookup+0x54>
  801200:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801205:	5d                   	pop    %ebp
  801206:	c3                   	ret    

00801207 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	83 ec 08             	sub    $0x8,%esp
  80120d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801210:	ba 68 28 80 00       	mov    $0x802868,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801215:	eb 13                	jmp    80122a <dev_lookup+0x23>
  801217:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80121a:	39 08                	cmp    %ecx,(%eax)
  80121c:	75 0c                	jne    80122a <dev_lookup+0x23>
			*dev = devtab[i];
  80121e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801221:	89 01                	mov    %eax,(%ecx)
			return 0;
  801223:	b8 00 00 00 00       	mov    $0x0,%eax
  801228:	eb 2e                	jmp    801258 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80122a:	8b 02                	mov    (%edx),%eax
  80122c:	85 c0                	test   %eax,%eax
  80122e:	75 e7                	jne    801217 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801230:	a1 20 60 80 00       	mov    0x806020,%eax
  801235:	8b 40 54             	mov    0x54(%eax),%eax
  801238:	83 ec 04             	sub    $0x4,%esp
  80123b:	51                   	push   %ecx
  80123c:	50                   	push   %eax
  80123d:	68 e8 27 80 00       	push   $0x8027e8
  801242:	e8 49 f0 ff ff       	call   800290 <cprintf>
	*dev = 0;
  801247:	8b 45 0c             	mov    0xc(%ebp),%eax
  80124a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801250:	83 c4 10             	add    $0x10,%esp
  801253:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801258:	c9                   	leave  
  801259:	c3                   	ret    

0080125a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80125a:	55                   	push   %ebp
  80125b:	89 e5                	mov    %esp,%ebp
  80125d:	56                   	push   %esi
  80125e:	53                   	push   %ebx
  80125f:	83 ec 10             	sub    $0x10,%esp
  801262:	8b 75 08             	mov    0x8(%ebp),%esi
  801265:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801268:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126b:	50                   	push   %eax
  80126c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801272:	c1 e8 0c             	shr    $0xc,%eax
  801275:	50                   	push   %eax
  801276:	e8 36 ff ff ff       	call   8011b1 <fd_lookup>
  80127b:	83 c4 08             	add    $0x8,%esp
  80127e:	85 c0                	test   %eax,%eax
  801280:	78 05                	js     801287 <fd_close+0x2d>
	    || fd != fd2)
  801282:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801285:	74 0c                	je     801293 <fd_close+0x39>
		return (must_exist ? r : 0);
  801287:	84 db                	test   %bl,%bl
  801289:	ba 00 00 00 00       	mov    $0x0,%edx
  80128e:	0f 44 c2             	cmove  %edx,%eax
  801291:	eb 41                	jmp    8012d4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801293:	83 ec 08             	sub    $0x8,%esp
  801296:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801299:	50                   	push   %eax
  80129a:	ff 36                	pushl  (%esi)
  80129c:	e8 66 ff ff ff       	call   801207 <dev_lookup>
  8012a1:	89 c3                	mov    %eax,%ebx
  8012a3:	83 c4 10             	add    $0x10,%esp
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	78 1a                	js     8012c4 <fd_close+0x6a>
		if (dev->dev_close)
  8012aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ad:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012b0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	74 0b                	je     8012c4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012b9:	83 ec 0c             	sub    $0xc,%esp
  8012bc:	56                   	push   %esi
  8012bd:	ff d0                	call   *%eax
  8012bf:	89 c3                	mov    %eax,%ebx
  8012c1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012c4:	83 ec 08             	sub    $0x8,%esp
  8012c7:	56                   	push   %esi
  8012c8:	6a 00                	push   $0x0
  8012ca:	e8 ce f9 ff ff       	call   800c9d <sys_page_unmap>
	return r;
  8012cf:	83 c4 10             	add    $0x10,%esp
  8012d2:	89 d8                	mov    %ebx,%eax
}
  8012d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d7:	5b                   	pop    %ebx
  8012d8:	5e                   	pop    %esi
  8012d9:	5d                   	pop    %ebp
  8012da:	c3                   	ret    

008012db <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012db:	55                   	push   %ebp
  8012dc:	89 e5                	mov    %esp,%ebp
  8012de:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e4:	50                   	push   %eax
  8012e5:	ff 75 08             	pushl  0x8(%ebp)
  8012e8:	e8 c4 fe ff ff       	call   8011b1 <fd_lookup>
  8012ed:	83 c4 08             	add    $0x8,%esp
  8012f0:	85 c0                	test   %eax,%eax
  8012f2:	78 10                	js     801304 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012f4:	83 ec 08             	sub    $0x8,%esp
  8012f7:	6a 01                	push   $0x1
  8012f9:	ff 75 f4             	pushl  -0xc(%ebp)
  8012fc:	e8 59 ff ff ff       	call   80125a <fd_close>
  801301:	83 c4 10             	add    $0x10,%esp
}
  801304:	c9                   	leave  
  801305:	c3                   	ret    

00801306 <close_all>:

void
close_all(void)
{
  801306:	55                   	push   %ebp
  801307:	89 e5                	mov    %esp,%ebp
  801309:	53                   	push   %ebx
  80130a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80130d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801312:	83 ec 0c             	sub    $0xc,%esp
  801315:	53                   	push   %ebx
  801316:	e8 c0 ff ff ff       	call   8012db <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80131b:	83 c3 01             	add    $0x1,%ebx
  80131e:	83 c4 10             	add    $0x10,%esp
  801321:	83 fb 20             	cmp    $0x20,%ebx
  801324:	75 ec                	jne    801312 <close_all+0xc>
		close(i);
}
  801326:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801329:	c9                   	leave  
  80132a:	c3                   	ret    

0080132b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80132b:	55                   	push   %ebp
  80132c:	89 e5                	mov    %esp,%ebp
  80132e:	57                   	push   %edi
  80132f:	56                   	push   %esi
  801330:	53                   	push   %ebx
  801331:	83 ec 2c             	sub    $0x2c,%esp
  801334:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801337:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80133a:	50                   	push   %eax
  80133b:	ff 75 08             	pushl  0x8(%ebp)
  80133e:	e8 6e fe ff ff       	call   8011b1 <fd_lookup>
  801343:	83 c4 08             	add    $0x8,%esp
  801346:	85 c0                	test   %eax,%eax
  801348:	0f 88 c1 00 00 00    	js     80140f <dup+0xe4>
		return r;
	close(newfdnum);
  80134e:	83 ec 0c             	sub    $0xc,%esp
  801351:	56                   	push   %esi
  801352:	e8 84 ff ff ff       	call   8012db <close>

	newfd = INDEX2FD(newfdnum);
  801357:	89 f3                	mov    %esi,%ebx
  801359:	c1 e3 0c             	shl    $0xc,%ebx
  80135c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801362:	83 c4 04             	add    $0x4,%esp
  801365:	ff 75 e4             	pushl  -0x1c(%ebp)
  801368:	e8 de fd ff ff       	call   80114b <fd2data>
  80136d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80136f:	89 1c 24             	mov    %ebx,(%esp)
  801372:	e8 d4 fd ff ff       	call   80114b <fd2data>
  801377:	83 c4 10             	add    $0x10,%esp
  80137a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80137d:	89 f8                	mov    %edi,%eax
  80137f:	c1 e8 16             	shr    $0x16,%eax
  801382:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801389:	a8 01                	test   $0x1,%al
  80138b:	74 37                	je     8013c4 <dup+0x99>
  80138d:	89 f8                	mov    %edi,%eax
  80138f:	c1 e8 0c             	shr    $0xc,%eax
  801392:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801399:	f6 c2 01             	test   $0x1,%dl
  80139c:	74 26                	je     8013c4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80139e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013a5:	83 ec 0c             	sub    $0xc,%esp
  8013a8:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ad:	50                   	push   %eax
  8013ae:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013b1:	6a 00                	push   $0x0
  8013b3:	57                   	push   %edi
  8013b4:	6a 00                	push   $0x0
  8013b6:	e8 a0 f8 ff ff       	call   800c5b <sys_page_map>
  8013bb:	89 c7                	mov    %eax,%edi
  8013bd:	83 c4 20             	add    $0x20,%esp
  8013c0:	85 c0                	test   %eax,%eax
  8013c2:	78 2e                	js     8013f2 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013c7:	89 d0                	mov    %edx,%eax
  8013c9:	c1 e8 0c             	shr    $0xc,%eax
  8013cc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013d3:	83 ec 0c             	sub    $0xc,%esp
  8013d6:	25 07 0e 00 00       	and    $0xe07,%eax
  8013db:	50                   	push   %eax
  8013dc:	53                   	push   %ebx
  8013dd:	6a 00                	push   $0x0
  8013df:	52                   	push   %edx
  8013e0:	6a 00                	push   $0x0
  8013e2:	e8 74 f8 ff ff       	call   800c5b <sys_page_map>
  8013e7:	89 c7                	mov    %eax,%edi
  8013e9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013ec:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013ee:	85 ff                	test   %edi,%edi
  8013f0:	79 1d                	jns    80140f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013f2:	83 ec 08             	sub    $0x8,%esp
  8013f5:	53                   	push   %ebx
  8013f6:	6a 00                	push   $0x0
  8013f8:	e8 a0 f8 ff ff       	call   800c9d <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013fd:	83 c4 08             	add    $0x8,%esp
  801400:	ff 75 d4             	pushl  -0x2c(%ebp)
  801403:	6a 00                	push   $0x0
  801405:	e8 93 f8 ff ff       	call   800c9d <sys_page_unmap>
	return r;
  80140a:	83 c4 10             	add    $0x10,%esp
  80140d:	89 f8                	mov    %edi,%eax
}
  80140f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801412:	5b                   	pop    %ebx
  801413:	5e                   	pop    %esi
  801414:	5f                   	pop    %edi
  801415:	5d                   	pop    %ebp
  801416:	c3                   	ret    

00801417 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801417:	55                   	push   %ebp
  801418:	89 e5                	mov    %esp,%ebp
  80141a:	53                   	push   %ebx
  80141b:	83 ec 14             	sub    $0x14,%esp
  80141e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801421:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801424:	50                   	push   %eax
  801425:	53                   	push   %ebx
  801426:	e8 86 fd ff ff       	call   8011b1 <fd_lookup>
  80142b:	83 c4 08             	add    $0x8,%esp
  80142e:	89 c2                	mov    %eax,%edx
  801430:	85 c0                	test   %eax,%eax
  801432:	78 6d                	js     8014a1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801434:	83 ec 08             	sub    $0x8,%esp
  801437:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80143a:	50                   	push   %eax
  80143b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143e:	ff 30                	pushl  (%eax)
  801440:	e8 c2 fd ff ff       	call   801207 <dev_lookup>
  801445:	83 c4 10             	add    $0x10,%esp
  801448:	85 c0                	test   %eax,%eax
  80144a:	78 4c                	js     801498 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80144c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80144f:	8b 42 08             	mov    0x8(%edx),%eax
  801452:	83 e0 03             	and    $0x3,%eax
  801455:	83 f8 01             	cmp    $0x1,%eax
  801458:	75 21                	jne    80147b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80145a:	a1 20 60 80 00       	mov    0x806020,%eax
  80145f:	8b 40 54             	mov    0x54(%eax),%eax
  801462:	83 ec 04             	sub    $0x4,%esp
  801465:	53                   	push   %ebx
  801466:	50                   	push   %eax
  801467:	68 2c 28 80 00       	push   $0x80282c
  80146c:	e8 1f ee ff ff       	call   800290 <cprintf>
		return -E_INVAL;
  801471:	83 c4 10             	add    $0x10,%esp
  801474:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801479:	eb 26                	jmp    8014a1 <read+0x8a>
	}
	if (!dev->dev_read)
  80147b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147e:	8b 40 08             	mov    0x8(%eax),%eax
  801481:	85 c0                	test   %eax,%eax
  801483:	74 17                	je     80149c <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801485:	83 ec 04             	sub    $0x4,%esp
  801488:	ff 75 10             	pushl  0x10(%ebp)
  80148b:	ff 75 0c             	pushl  0xc(%ebp)
  80148e:	52                   	push   %edx
  80148f:	ff d0                	call   *%eax
  801491:	89 c2                	mov    %eax,%edx
  801493:	83 c4 10             	add    $0x10,%esp
  801496:	eb 09                	jmp    8014a1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801498:	89 c2                	mov    %eax,%edx
  80149a:	eb 05                	jmp    8014a1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80149c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8014a1:	89 d0                	mov    %edx,%eax
  8014a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a6:	c9                   	leave  
  8014a7:	c3                   	ret    

008014a8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014a8:	55                   	push   %ebp
  8014a9:	89 e5                	mov    %esp,%ebp
  8014ab:	57                   	push   %edi
  8014ac:	56                   	push   %esi
  8014ad:	53                   	push   %ebx
  8014ae:	83 ec 0c             	sub    $0xc,%esp
  8014b1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014b4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014bc:	eb 21                	jmp    8014df <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014be:	83 ec 04             	sub    $0x4,%esp
  8014c1:	89 f0                	mov    %esi,%eax
  8014c3:	29 d8                	sub    %ebx,%eax
  8014c5:	50                   	push   %eax
  8014c6:	89 d8                	mov    %ebx,%eax
  8014c8:	03 45 0c             	add    0xc(%ebp),%eax
  8014cb:	50                   	push   %eax
  8014cc:	57                   	push   %edi
  8014cd:	e8 45 ff ff ff       	call   801417 <read>
		if (m < 0)
  8014d2:	83 c4 10             	add    $0x10,%esp
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	78 10                	js     8014e9 <readn+0x41>
			return m;
		if (m == 0)
  8014d9:	85 c0                	test   %eax,%eax
  8014db:	74 0a                	je     8014e7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014dd:	01 c3                	add    %eax,%ebx
  8014df:	39 f3                	cmp    %esi,%ebx
  8014e1:	72 db                	jb     8014be <readn+0x16>
  8014e3:	89 d8                	mov    %ebx,%eax
  8014e5:	eb 02                	jmp    8014e9 <readn+0x41>
  8014e7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ec:	5b                   	pop    %ebx
  8014ed:	5e                   	pop    %esi
  8014ee:	5f                   	pop    %edi
  8014ef:	5d                   	pop    %ebp
  8014f0:	c3                   	ret    

008014f1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014f1:	55                   	push   %ebp
  8014f2:	89 e5                	mov    %esp,%ebp
  8014f4:	53                   	push   %ebx
  8014f5:	83 ec 14             	sub    $0x14,%esp
  8014f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014fe:	50                   	push   %eax
  8014ff:	53                   	push   %ebx
  801500:	e8 ac fc ff ff       	call   8011b1 <fd_lookup>
  801505:	83 c4 08             	add    $0x8,%esp
  801508:	89 c2                	mov    %eax,%edx
  80150a:	85 c0                	test   %eax,%eax
  80150c:	78 68                	js     801576 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80150e:	83 ec 08             	sub    $0x8,%esp
  801511:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801514:	50                   	push   %eax
  801515:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801518:	ff 30                	pushl  (%eax)
  80151a:	e8 e8 fc ff ff       	call   801207 <dev_lookup>
  80151f:	83 c4 10             	add    $0x10,%esp
  801522:	85 c0                	test   %eax,%eax
  801524:	78 47                	js     80156d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801526:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801529:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80152d:	75 21                	jne    801550 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80152f:	a1 20 60 80 00       	mov    0x806020,%eax
  801534:	8b 40 54             	mov    0x54(%eax),%eax
  801537:	83 ec 04             	sub    $0x4,%esp
  80153a:	53                   	push   %ebx
  80153b:	50                   	push   %eax
  80153c:	68 48 28 80 00       	push   $0x802848
  801541:	e8 4a ed ff ff       	call   800290 <cprintf>
		return -E_INVAL;
  801546:	83 c4 10             	add    $0x10,%esp
  801549:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80154e:	eb 26                	jmp    801576 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801550:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801553:	8b 52 0c             	mov    0xc(%edx),%edx
  801556:	85 d2                	test   %edx,%edx
  801558:	74 17                	je     801571 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80155a:	83 ec 04             	sub    $0x4,%esp
  80155d:	ff 75 10             	pushl  0x10(%ebp)
  801560:	ff 75 0c             	pushl  0xc(%ebp)
  801563:	50                   	push   %eax
  801564:	ff d2                	call   *%edx
  801566:	89 c2                	mov    %eax,%edx
  801568:	83 c4 10             	add    $0x10,%esp
  80156b:	eb 09                	jmp    801576 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156d:	89 c2                	mov    %eax,%edx
  80156f:	eb 05                	jmp    801576 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801571:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801576:	89 d0                	mov    %edx,%eax
  801578:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157b:	c9                   	leave  
  80157c:	c3                   	ret    

0080157d <seek>:

int
seek(int fdnum, off_t offset)
{
  80157d:	55                   	push   %ebp
  80157e:	89 e5                	mov    %esp,%ebp
  801580:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801583:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801586:	50                   	push   %eax
  801587:	ff 75 08             	pushl  0x8(%ebp)
  80158a:	e8 22 fc ff ff       	call   8011b1 <fd_lookup>
  80158f:	83 c4 08             	add    $0x8,%esp
  801592:	85 c0                	test   %eax,%eax
  801594:	78 0e                	js     8015a4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801596:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801599:	8b 55 0c             	mov    0xc(%ebp),%edx
  80159c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80159f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015a4:	c9                   	leave  
  8015a5:	c3                   	ret    

008015a6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015a6:	55                   	push   %ebp
  8015a7:	89 e5                	mov    %esp,%ebp
  8015a9:	53                   	push   %ebx
  8015aa:	83 ec 14             	sub    $0x14,%esp
  8015ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b3:	50                   	push   %eax
  8015b4:	53                   	push   %ebx
  8015b5:	e8 f7 fb ff ff       	call   8011b1 <fd_lookup>
  8015ba:	83 c4 08             	add    $0x8,%esp
  8015bd:	89 c2                	mov    %eax,%edx
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	78 65                	js     801628 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c3:	83 ec 08             	sub    $0x8,%esp
  8015c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c9:	50                   	push   %eax
  8015ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015cd:	ff 30                	pushl  (%eax)
  8015cf:	e8 33 fc ff ff       	call   801207 <dev_lookup>
  8015d4:	83 c4 10             	add    $0x10,%esp
  8015d7:	85 c0                	test   %eax,%eax
  8015d9:	78 44                	js     80161f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015de:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015e2:	75 21                	jne    801605 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015e4:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015e9:	8b 40 54             	mov    0x54(%eax),%eax
  8015ec:	83 ec 04             	sub    $0x4,%esp
  8015ef:	53                   	push   %ebx
  8015f0:	50                   	push   %eax
  8015f1:	68 08 28 80 00       	push   $0x802808
  8015f6:	e8 95 ec ff ff       	call   800290 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015fb:	83 c4 10             	add    $0x10,%esp
  8015fe:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801603:	eb 23                	jmp    801628 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801605:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801608:	8b 52 18             	mov    0x18(%edx),%edx
  80160b:	85 d2                	test   %edx,%edx
  80160d:	74 14                	je     801623 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80160f:	83 ec 08             	sub    $0x8,%esp
  801612:	ff 75 0c             	pushl  0xc(%ebp)
  801615:	50                   	push   %eax
  801616:	ff d2                	call   *%edx
  801618:	89 c2                	mov    %eax,%edx
  80161a:	83 c4 10             	add    $0x10,%esp
  80161d:	eb 09                	jmp    801628 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161f:	89 c2                	mov    %eax,%edx
  801621:	eb 05                	jmp    801628 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801623:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801628:	89 d0                	mov    %edx,%eax
  80162a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80162d:	c9                   	leave  
  80162e:	c3                   	ret    

0080162f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80162f:	55                   	push   %ebp
  801630:	89 e5                	mov    %esp,%ebp
  801632:	53                   	push   %ebx
  801633:	83 ec 14             	sub    $0x14,%esp
  801636:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801639:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80163c:	50                   	push   %eax
  80163d:	ff 75 08             	pushl  0x8(%ebp)
  801640:	e8 6c fb ff ff       	call   8011b1 <fd_lookup>
  801645:	83 c4 08             	add    $0x8,%esp
  801648:	89 c2                	mov    %eax,%edx
  80164a:	85 c0                	test   %eax,%eax
  80164c:	78 58                	js     8016a6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164e:	83 ec 08             	sub    $0x8,%esp
  801651:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801654:	50                   	push   %eax
  801655:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801658:	ff 30                	pushl  (%eax)
  80165a:	e8 a8 fb ff ff       	call   801207 <dev_lookup>
  80165f:	83 c4 10             	add    $0x10,%esp
  801662:	85 c0                	test   %eax,%eax
  801664:	78 37                	js     80169d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801666:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801669:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80166d:	74 32                	je     8016a1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80166f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801672:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801679:	00 00 00 
	stat->st_isdir = 0;
  80167c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801683:	00 00 00 
	stat->st_dev = dev;
  801686:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80168c:	83 ec 08             	sub    $0x8,%esp
  80168f:	53                   	push   %ebx
  801690:	ff 75 f0             	pushl  -0x10(%ebp)
  801693:	ff 50 14             	call   *0x14(%eax)
  801696:	89 c2                	mov    %eax,%edx
  801698:	83 c4 10             	add    $0x10,%esp
  80169b:	eb 09                	jmp    8016a6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169d:	89 c2                	mov    %eax,%edx
  80169f:	eb 05                	jmp    8016a6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016a1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016a6:	89 d0                	mov    %edx,%eax
  8016a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ab:	c9                   	leave  
  8016ac:	c3                   	ret    

008016ad <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
  8016b0:	56                   	push   %esi
  8016b1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016b2:	83 ec 08             	sub    $0x8,%esp
  8016b5:	6a 00                	push   $0x0
  8016b7:	ff 75 08             	pushl  0x8(%ebp)
  8016ba:	e8 e3 01 00 00       	call   8018a2 <open>
  8016bf:	89 c3                	mov    %eax,%ebx
  8016c1:	83 c4 10             	add    $0x10,%esp
  8016c4:	85 c0                	test   %eax,%eax
  8016c6:	78 1b                	js     8016e3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016c8:	83 ec 08             	sub    $0x8,%esp
  8016cb:	ff 75 0c             	pushl  0xc(%ebp)
  8016ce:	50                   	push   %eax
  8016cf:	e8 5b ff ff ff       	call   80162f <fstat>
  8016d4:	89 c6                	mov    %eax,%esi
	close(fd);
  8016d6:	89 1c 24             	mov    %ebx,(%esp)
  8016d9:	e8 fd fb ff ff       	call   8012db <close>
	return r;
  8016de:	83 c4 10             	add    $0x10,%esp
  8016e1:	89 f0                	mov    %esi,%eax
}
  8016e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016e6:	5b                   	pop    %ebx
  8016e7:	5e                   	pop    %esi
  8016e8:	5d                   	pop    %ebp
  8016e9:	c3                   	ret    

008016ea <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	56                   	push   %esi
  8016ee:	53                   	push   %ebx
  8016ef:	89 c6                	mov    %eax,%esi
  8016f1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016f3:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016fa:	75 12                	jne    80170e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016fc:	83 ec 0c             	sub    $0xc,%esp
  8016ff:	6a 01                	push   $0x1
  801701:	e8 98 09 00 00       	call   80209e <ipc_find_env>
  801706:	a3 00 40 80 00       	mov    %eax,0x804000
  80170b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80170e:	6a 07                	push   $0x7
  801710:	68 00 70 80 00       	push   $0x807000
  801715:	56                   	push   %esi
  801716:	ff 35 00 40 80 00    	pushl  0x804000
  80171c:	e8 1b 09 00 00       	call   80203c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801721:	83 c4 0c             	add    $0xc,%esp
  801724:	6a 00                	push   $0x0
  801726:	53                   	push   %ebx
  801727:	6a 00                	push   $0x0
  801729:	e8 96 08 00 00       	call   801fc4 <ipc_recv>
}
  80172e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801731:	5b                   	pop    %ebx
  801732:	5e                   	pop    %esi
  801733:	5d                   	pop    %ebp
  801734:	c3                   	ret    

00801735 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801735:	55                   	push   %ebp
  801736:	89 e5                	mov    %esp,%ebp
  801738:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80173b:	8b 45 08             	mov    0x8(%ebp),%eax
  80173e:	8b 40 0c             	mov    0xc(%eax),%eax
  801741:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  801746:	8b 45 0c             	mov    0xc(%ebp),%eax
  801749:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80174e:	ba 00 00 00 00       	mov    $0x0,%edx
  801753:	b8 02 00 00 00       	mov    $0x2,%eax
  801758:	e8 8d ff ff ff       	call   8016ea <fsipc>
}
  80175d:	c9                   	leave  
  80175e:	c3                   	ret    

0080175f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80175f:	55                   	push   %ebp
  801760:	89 e5                	mov    %esp,%ebp
  801762:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801765:	8b 45 08             	mov    0x8(%ebp),%eax
  801768:	8b 40 0c             	mov    0xc(%eax),%eax
  80176b:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  801770:	ba 00 00 00 00       	mov    $0x0,%edx
  801775:	b8 06 00 00 00       	mov    $0x6,%eax
  80177a:	e8 6b ff ff ff       	call   8016ea <fsipc>
}
  80177f:	c9                   	leave  
  801780:	c3                   	ret    

00801781 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
  801784:	53                   	push   %ebx
  801785:	83 ec 04             	sub    $0x4,%esp
  801788:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80178b:	8b 45 08             	mov    0x8(%ebp),%eax
  80178e:	8b 40 0c             	mov    0xc(%eax),%eax
  801791:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801796:	ba 00 00 00 00       	mov    $0x0,%edx
  80179b:	b8 05 00 00 00       	mov    $0x5,%eax
  8017a0:	e8 45 ff ff ff       	call   8016ea <fsipc>
  8017a5:	85 c0                	test   %eax,%eax
  8017a7:	78 2c                	js     8017d5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017a9:	83 ec 08             	sub    $0x8,%esp
  8017ac:	68 00 70 80 00       	push   $0x807000
  8017b1:	53                   	push   %ebx
  8017b2:	e8 5e f0 ff ff       	call   800815 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017b7:	a1 80 70 80 00       	mov    0x807080,%eax
  8017bc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017c2:	a1 84 70 80 00       	mov    0x807084,%eax
  8017c7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017cd:	83 c4 10             	add    $0x10,%esp
  8017d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d8:	c9                   	leave  
  8017d9:	c3                   	ret    

008017da <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017da:	55                   	push   %ebp
  8017db:	89 e5                	mov    %esp,%ebp
  8017dd:	83 ec 0c             	sub    $0xc,%esp
  8017e0:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8017e6:	8b 52 0c             	mov    0xc(%edx),%edx
  8017e9:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8017ef:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017f4:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017f9:	0f 47 c2             	cmova  %edx,%eax
  8017fc:	a3 04 70 80 00       	mov    %eax,0x807004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801801:	50                   	push   %eax
  801802:	ff 75 0c             	pushl  0xc(%ebp)
  801805:	68 08 70 80 00       	push   $0x807008
  80180a:	e8 98 f1 ff ff       	call   8009a7 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80180f:	ba 00 00 00 00       	mov    $0x0,%edx
  801814:	b8 04 00 00 00       	mov    $0x4,%eax
  801819:	e8 cc fe ff ff       	call   8016ea <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80181e:	c9                   	leave  
  80181f:	c3                   	ret    

00801820 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	56                   	push   %esi
  801824:	53                   	push   %ebx
  801825:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801828:	8b 45 08             	mov    0x8(%ebp),%eax
  80182b:	8b 40 0c             	mov    0xc(%eax),%eax
  80182e:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801833:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801839:	ba 00 00 00 00       	mov    $0x0,%edx
  80183e:	b8 03 00 00 00       	mov    $0x3,%eax
  801843:	e8 a2 fe ff ff       	call   8016ea <fsipc>
  801848:	89 c3                	mov    %eax,%ebx
  80184a:	85 c0                	test   %eax,%eax
  80184c:	78 4b                	js     801899 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80184e:	39 c6                	cmp    %eax,%esi
  801850:	73 16                	jae    801868 <devfile_read+0x48>
  801852:	68 78 28 80 00       	push   $0x802878
  801857:	68 7f 28 80 00       	push   $0x80287f
  80185c:	6a 7c                	push   $0x7c
  80185e:	68 94 28 80 00       	push   $0x802894
  801863:	e8 4f e9 ff ff       	call   8001b7 <_panic>
	assert(r <= PGSIZE);
  801868:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80186d:	7e 16                	jle    801885 <devfile_read+0x65>
  80186f:	68 9f 28 80 00       	push   $0x80289f
  801874:	68 7f 28 80 00       	push   $0x80287f
  801879:	6a 7d                	push   $0x7d
  80187b:	68 94 28 80 00       	push   $0x802894
  801880:	e8 32 e9 ff ff       	call   8001b7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801885:	83 ec 04             	sub    $0x4,%esp
  801888:	50                   	push   %eax
  801889:	68 00 70 80 00       	push   $0x807000
  80188e:	ff 75 0c             	pushl  0xc(%ebp)
  801891:	e8 11 f1 ff ff       	call   8009a7 <memmove>
	return r;
  801896:	83 c4 10             	add    $0x10,%esp
}
  801899:	89 d8                	mov    %ebx,%eax
  80189b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80189e:	5b                   	pop    %ebx
  80189f:	5e                   	pop    %esi
  8018a0:	5d                   	pop    %ebp
  8018a1:	c3                   	ret    

008018a2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018a2:	55                   	push   %ebp
  8018a3:	89 e5                	mov    %esp,%ebp
  8018a5:	53                   	push   %ebx
  8018a6:	83 ec 20             	sub    $0x20,%esp
  8018a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018ac:	53                   	push   %ebx
  8018ad:	e8 2a ef ff ff       	call   8007dc <strlen>
  8018b2:	83 c4 10             	add    $0x10,%esp
  8018b5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018ba:	7f 67                	jg     801923 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018bc:	83 ec 0c             	sub    $0xc,%esp
  8018bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c2:	50                   	push   %eax
  8018c3:	e8 9a f8 ff ff       	call   801162 <fd_alloc>
  8018c8:	83 c4 10             	add    $0x10,%esp
		return r;
  8018cb:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018cd:	85 c0                	test   %eax,%eax
  8018cf:	78 57                	js     801928 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018d1:	83 ec 08             	sub    $0x8,%esp
  8018d4:	53                   	push   %ebx
  8018d5:	68 00 70 80 00       	push   $0x807000
  8018da:	e8 36 ef ff ff       	call   800815 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e2:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ea:	b8 01 00 00 00       	mov    $0x1,%eax
  8018ef:	e8 f6 fd ff ff       	call   8016ea <fsipc>
  8018f4:	89 c3                	mov    %eax,%ebx
  8018f6:	83 c4 10             	add    $0x10,%esp
  8018f9:	85 c0                	test   %eax,%eax
  8018fb:	79 14                	jns    801911 <open+0x6f>
		fd_close(fd, 0);
  8018fd:	83 ec 08             	sub    $0x8,%esp
  801900:	6a 00                	push   $0x0
  801902:	ff 75 f4             	pushl  -0xc(%ebp)
  801905:	e8 50 f9 ff ff       	call   80125a <fd_close>
		return r;
  80190a:	83 c4 10             	add    $0x10,%esp
  80190d:	89 da                	mov    %ebx,%edx
  80190f:	eb 17                	jmp    801928 <open+0x86>
	}

	return fd2num(fd);
  801911:	83 ec 0c             	sub    $0xc,%esp
  801914:	ff 75 f4             	pushl  -0xc(%ebp)
  801917:	e8 1f f8 ff ff       	call   80113b <fd2num>
  80191c:	89 c2                	mov    %eax,%edx
  80191e:	83 c4 10             	add    $0x10,%esp
  801921:	eb 05                	jmp    801928 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801923:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801928:	89 d0                	mov    %edx,%eax
  80192a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80192d:	c9                   	leave  
  80192e:	c3                   	ret    

0080192f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80192f:	55                   	push   %ebp
  801930:	89 e5                	mov    %esp,%ebp
  801932:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801935:	ba 00 00 00 00       	mov    $0x0,%edx
  80193a:	b8 08 00 00 00       	mov    $0x8,%eax
  80193f:	e8 a6 fd ff ff       	call   8016ea <fsipc>
}
  801944:	c9                   	leave  
  801945:	c3                   	ret    

00801946 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801946:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80194a:	7e 37                	jle    801983 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  80194c:	55                   	push   %ebp
  80194d:	89 e5                	mov    %esp,%ebp
  80194f:	53                   	push   %ebx
  801950:	83 ec 08             	sub    $0x8,%esp
  801953:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801955:	ff 70 04             	pushl  0x4(%eax)
  801958:	8d 40 10             	lea    0x10(%eax),%eax
  80195b:	50                   	push   %eax
  80195c:	ff 33                	pushl  (%ebx)
  80195e:	e8 8e fb ff ff       	call   8014f1 <write>
		if (result > 0)
  801963:	83 c4 10             	add    $0x10,%esp
  801966:	85 c0                	test   %eax,%eax
  801968:	7e 03                	jle    80196d <writebuf+0x27>
			b->result += result;
  80196a:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80196d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801970:	74 0d                	je     80197f <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801972:	85 c0                	test   %eax,%eax
  801974:	ba 00 00 00 00       	mov    $0x0,%edx
  801979:	0f 4f c2             	cmovg  %edx,%eax
  80197c:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80197f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801982:	c9                   	leave  
  801983:	f3 c3                	repz ret 

00801985 <putch>:

static void
putch(int ch, void *thunk)
{
  801985:	55                   	push   %ebp
  801986:	89 e5                	mov    %esp,%ebp
  801988:	53                   	push   %ebx
  801989:	83 ec 04             	sub    $0x4,%esp
  80198c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80198f:	8b 53 04             	mov    0x4(%ebx),%edx
  801992:	8d 42 01             	lea    0x1(%edx),%eax
  801995:	89 43 04             	mov    %eax,0x4(%ebx)
  801998:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80199b:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80199f:	3d 00 01 00 00       	cmp    $0x100,%eax
  8019a4:	75 0e                	jne    8019b4 <putch+0x2f>
		writebuf(b);
  8019a6:	89 d8                	mov    %ebx,%eax
  8019a8:	e8 99 ff ff ff       	call   801946 <writebuf>
		b->idx = 0;
  8019ad:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8019b4:	83 c4 04             	add    $0x4,%esp
  8019b7:	5b                   	pop    %ebx
  8019b8:	5d                   	pop    %ebp
  8019b9:	c3                   	ret    

008019ba <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8019c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c6:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8019cc:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8019d3:	00 00 00 
	b.result = 0;
  8019d6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8019dd:	00 00 00 
	b.error = 1;
  8019e0:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8019e7:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8019ea:	ff 75 10             	pushl  0x10(%ebp)
  8019ed:	ff 75 0c             	pushl  0xc(%ebp)
  8019f0:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8019f6:	50                   	push   %eax
  8019f7:	68 85 19 80 00       	push   $0x801985
  8019fc:	e8 c6 e9 ff ff       	call   8003c7 <vprintfmt>
	if (b.idx > 0)
  801a01:	83 c4 10             	add    $0x10,%esp
  801a04:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801a0b:	7e 0b                	jle    801a18 <vfprintf+0x5e>
		writebuf(&b);
  801a0d:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a13:	e8 2e ff ff ff       	call   801946 <writebuf>

	return (b.result ? b.result : b.error);
  801a18:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801a1e:	85 c0                	test   %eax,%eax
  801a20:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801a27:	c9                   	leave  
  801a28:	c3                   	ret    

00801a29 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801a29:	55                   	push   %ebp
  801a2a:	89 e5                	mov    %esp,%ebp
  801a2c:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a2f:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801a32:	50                   	push   %eax
  801a33:	ff 75 0c             	pushl  0xc(%ebp)
  801a36:	ff 75 08             	pushl  0x8(%ebp)
  801a39:	e8 7c ff ff ff       	call   8019ba <vfprintf>
	va_end(ap);

	return cnt;
}
  801a3e:	c9                   	leave  
  801a3f:	c3                   	ret    

00801a40 <printf>:

int
printf(const char *fmt, ...)
{
  801a40:	55                   	push   %ebp
  801a41:	89 e5                	mov    %esp,%ebp
  801a43:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a46:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801a49:	50                   	push   %eax
  801a4a:	ff 75 08             	pushl  0x8(%ebp)
  801a4d:	6a 01                	push   $0x1
  801a4f:	e8 66 ff ff ff       	call   8019ba <vfprintf>
	va_end(ap);

	return cnt;
}
  801a54:	c9                   	leave  
  801a55:	c3                   	ret    

00801a56 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a56:	55                   	push   %ebp
  801a57:	89 e5                	mov    %esp,%ebp
  801a59:	56                   	push   %esi
  801a5a:	53                   	push   %ebx
  801a5b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a5e:	83 ec 0c             	sub    $0xc,%esp
  801a61:	ff 75 08             	pushl  0x8(%ebp)
  801a64:	e8 e2 f6 ff ff       	call   80114b <fd2data>
  801a69:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a6b:	83 c4 08             	add    $0x8,%esp
  801a6e:	68 ab 28 80 00       	push   $0x8028ab
  801a73:	53                   	push   %ebx
  801a74:	e8 9c ed ff ff       	call   800815 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a79:	8b 46 04             	mov    0x4(%esi),%eax
  801a7c:	2b 06                	sub    (%esi),%eax
  801a7e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a84:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a8b:	00 00 00 
	stat->st_dev = &devpipe;
  801a8e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a95:	30 80 00 
	return 0;
}
  801a98:	b8 00 00 00 00       	mov    $0x0,%eax
  801a9d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa0:	5b                   	pop    %ebx
  801aa1:	5e                   	pop    %esi
  801aa2:	5d                   	pop    %ebp
  801aa3:	c3                   	ret    

00801aa4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801aa4:	55                   	push   %ebp
  801aa5:	89 e5                	mov    %esp,%ebp
  801aa7:	53                   	push   %ebx
  801aa8:	83 ec 0c             	sub    $0xc,%esp
  801aab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801aae:	53                   	push   %ebx
  801aaf:	6a 00                	push   $0x0
  801ab1:	e8 e7 f1 ff ff       	call   800c9d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ab6:	89 1c 24             	mov    %ebx,(%esp)
  801ab9:	e8 8d f6 ff ff       	call   80114b <fd2data>
  801abe:	83 c4 08             	add    $0x8,%esp
  801ac1:	50                   	push   %eax
  801ac2:	6a 00                	push   $0x0
  801ac4:	e8 d4 f1 ff ff       	call   800c9d <sys_page_unmap>
}
  801ac9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801acc:	c9                   	leave  
  801acd:	c3                   	ret    

00801ace <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ace:	55                   	push   %ebp
  801acf:	89 e5                	mov    %esp,%ebp
  801ad1:	57                   	push   %edi
  801ad2:	56                   	push   %esi
  801ad3:	53                   	push   %ebx
  801ad4:	83 ec 1c             	sub    $0x1c,%esp
  801ad7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ada:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801adc:	a1 20 60 80 00       	mov    0x806020,%eax
  801ae1:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ae4:	83 ec 0c             	sub    $0xc,%esp
  801ae7:	ff 75 e0             	pushl  -0x20(%ebp)
  801aea:	e8 ef 05 00 00       	call   8020de <pageref>
  801aef:	89 c3                	mov    %eax,%ebx
  801af1:	89 3c 24             	mov    %edi,(%esp)
  801af4:	e8 e5 05 00 00       	call   8020de <pageref>
  801af9:	83 c4 10             	add    $0x10,%esp
  801afc:	39 c3                	cmp    %eax,%ebx
  801afe:	0f 94 c1             	sete   %cl
  801b01:	0f b6 c9             	movzbl %cl,%ecx
  801b04:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b07:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801b0d:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  801b10:	39 ce                	cmp    %ecx,%esi
  801b12:	74 1b                	je     801b2f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b14:	39 c3                	cmp    %eax,%ebx
  801b16:	75 c4                	jne    801adc <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b18:	8b 42 64             	mov    0x64(%edx),%eax
  801b1b:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b1e:	50                   	push   %eax
  801b1f:	56                   	push   %esi
  801b20:	68 b2 28 80 00       	push   $0x8028b2
  801b25:	e8 66 e7 ff ff       	call   800290 <cprintf>
  801b2a:	83 c4 10             	add    $0x10,%esp
  801b2d:	eb ad                	jmp    801adc <_pipeisclosed+0xe>
	}
}
  801b2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b35:	5b                   	pop    %ebx
  801b36:	5e                   	pop    %esi
  801b37:	5f                   	pop    %edi
  801b38:	5d                   	pop    %ebp
  801b39:	c3                   	ret    

00801b3a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b3a:	55                   	push   %ebp
  801b3b:	89 e5                	mov    %esp,%ebp
  801b3d:	57                   	push   %edi
  801b3e:	56                   	push   %esi
  801b3f:	53                   	push   %ebx
  801b40:	83 ec 28             	sub    $0x28,%esp
  801b43:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b46:	56                   	push   %esi
  801b47:	e8 ff f5 ff ff       	call   80114b <fd2data>
  801b4c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b4e:	83 c4 10             	add    $0x10,%esp
  801b51:	bf 00 00 00 00       	mov    $0x0,%edi
  801b56:	eb 4b                	jmp    801ba3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b58:	89 da                	mov    %ebx,%edx
  801b5a:	89 f0                	mov    %esi,%eax
  801b5c:	e8 6d ff ff ff       	call   801ace <_pipeisclosed>
  801b61:	85 c0                	test   %eax,%eax
  801b63:	75 48                	jne    801bad <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b65:	e8 8f f0 ff ff       	call   800bf9 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b6a:	8b 43 04             	mov    0x4(%ebx),%eax
  801b6d:	8b 0b                	mov    (%ebx),%ecx
  801b6f:	8d 51 20             	lea    0x20(%ecx),%edx
  801b72:	39 d0                	cmp    %edx,%eax
  801b74:	73 e2                	jae    801b58 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b79:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b7d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b80:	89 c2                	mov    %eax,%edx
  801b82:	c1 fa 1f             	sar    $0x1f,%edx
  801b85:	89 d1                	mov    %edx,%ecx
  801b87:	c1 e9 1b             	shr    $0x1b,%ecx
  801b8a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b8d:	83 e2 1f             	and    $0x1f,%edx
  801b90:	29 ca                	sub    %ecx,%edx
  801b92:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b96:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b9a:	83 c0 01             	add    $0x1,%eax
  801b9d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ba0:	83 c7 01             	add    $0x1,%edi
  801ba3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ba6:	75 c2                	jne    801b6a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ba8:	8b 45 10             	mov    0x10(%ebp),%eax
  801bab:	eb 05                	jmp    801bb2 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bad:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bb5:	5b                   	pop    %ebx
  801bb6:	5e                   	pop    %esi
  801bb7:	5f                   	pop    %edi
  801bb8:	5d                   	pop    %ebp
  801bb9:	c3                   	ret    

00801bba <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bba:	55                   	push   %ebp
  801bbb:	89 e5                	mov    %esp,%ebp
  801bbd:	57                   	push   %edi
  801bbe:	56                   	push   %esi
  801bbf:	53                   	push   %ebx
  801bc0:	83 ec 18             	sub    $0x18,%esp
  801bc3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bc6:	57                   	push   %edi
  801bc7:	e8 7f f5 ff ff       	call   80114b <fd2data>
  801bcc:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bce:	83 c4 10             	add    $0x10,%esp
  801bd1:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bd6:	eb 3d                	jmp    801c15 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bd8:	85 db                	test   %ebx,%ebx
  801bda:	74 04                	je     801be0 <devpipe_read+0x26>
				return i;
  801bdc:	89 d8                	mov    %ebx,%eax
  801bde:	eb 44                	jmp    801c24 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801be0:	89 f2                	mov    %esi,%edx
  801be2:	89 f8                	mov    %edi,%eax
  801be4:	e8 e5 fe ff ff       	call   801ace <_pipeisclosed>
  801be9:	85 c0                	test   %eax,%eax
  801beb:	75 32                	jne    801c1f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bed:	e8 07 f0 ff ff       	call   800bf9 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bf2:	8b 06                	mov    (%esi),%eax
  801bf4:	3b 46 04             	cmp    0x4(%esi),%eax
  801bf7:	74 df                	je     801bd8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bf9:	99                   	cltd   
  801bfa:	c1 ea 1b             	shr    $0x1b,%edx
  801bfd:	01 d0                	add    %edx,%eax
  801bff:	83 e0 1f             	and    $0x1f,%eax
  801c02:	29 d0                	sub    %edx,%eax
  801c04:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c0c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c0f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c12:	83 c3 01             	add    $0x1,%ebx
  801c15:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c18:	75 d8                	jne    801bf2 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c1a:	8b 45 10             	mov    0x10(%ebp),%eax
  801c1d:	eb 05                	jmp    801c24 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c1f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c27:	5b                   	pop    %ebx
  801c28:	5e                   	pop    %esi
  801c29:	5f                   	pop    %edi
  801c2a:	5d                   	pop    %ebp
  801c2b:	c3                   	ret    

00801c2c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c2c:	55                   	push   %ebp
  801c2d:	89 e5                	mov    %esp,%ebp
  801c2f:	56                   	push   %esi
  801c30:	53                   	push   %ebx
  801c31:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c34:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c37:	50                   	push   %eax
  801c38:	e8 25 f5 ff ff       	call   801162 <fd_alloc>
  801c3d:	83 c4 10             	add    $0x10,%esp
  801c40:	89 c2                	mov    %eax,%edx
  801c42:	85 c0                	test   %eax,%eax
  801c44:	0f 88 2c 01 00 00    	js     801d76 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c4a:	83 ec 04             	sub    $0x4,%esp
  801c4d:	68 07 04 00 00       	push   $0x407
  801c52:	ff 75 f4             	pushl  -0xc(%ebp)
  801c55:	6a 00                	push   $0x0
  801c57:	e8 bc ef ff ff       	call   800c18 <sys_page_alloc>
  801c5c:	83 c4 10             	add    $0x10,%esp
  801c5f:	89 c2                	mov    %eax,%edx
  801c61:	85 c0                	test   %eax,%eax
  801c63:	0f 88 0d 01 00 00    	js     801d76 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c69:	83 ec 0c             	sub    $0xc,%esp
  801c6c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c6f:	50                   	push   %eax
  801c70:	e8 ed f4 ff ff       	call   801162 <fd_alloc>
  801c75:	89 c3                	mov    %eax,%ebx
  801c77:	83 c4 10             	add    $0x10,%esp
  801c7a:	85 c0                	test   %eax,%eax
  801c7c:	0f 88 e2 00 00 00    	js     801d64 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c82:	83 ec 04             	sub    $0x4,%esp
  801c85:	68 07 04 00 00       	push   $0x407
  801c8a:	ff 75 f0             	pushl  -0x10(%ebp)
  801c8d:	6a 00                	push   $0x0
  801c8f:	e8 84 ef ff ff       	call   800c18 <sys_page_alloc>
  801c94:	89 c3                	mov    %eax,%ebx
  801c96:	83 c4 10             	add    $0x10,%esp
  801c99:	85 c0                	test   %eax,%eax
  801c9b:	0f 88 c3 00 00 00    	js     801d64 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ca1:	83 ec 0c             	sub    $0xc,%esp
  801ca4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca7:	e8 9f f4 ff ff       	call   80114b <fd2data>
  801cac:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cae:	83 c4 0c             	add    $0xc,%esp
  801cb1:	68 07 04 00 00       	push   $0x407
  801cb6:	50                   	push   %eax
  801cb7:	6a 00                	push   $0x0
  801cb9:	e8 5a ef ff ff       	call   800c18 <sys_page_alloc>
  801cbe:	89 c3                	mov    %eax,%ebx
  801cc0:	83 c4 10             	add    $0x10,%esp
  801cc3:	85 c0                	test   %eax,%eax
  801cc5:	0f 88 89 00 00 00    	js     801d54 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ccb:	83 ec 0c             	sub    $0xc,%esp
  801cce:	ff 75 f0             	pushl  -0x10(%ebp)
  801cd1:	e8 75 f4 ff ff       	call   80114b <fd2data>
  801cd6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cdd:	50                   	push   %eax
  801cde:	6a 00                	push   $0x0
  801ce0:	56                   	push   %esi
  801ce1:	6a 00                	push   $0x0
  801ce3:	e8 73 ef ff ff       	call   800c5b <sys_page_map>
  801ce8:	89 c3                	mov    %eax,%ebx
  801cea:	83 c4 20             	add    $0x20,%esp
  801ced:	85 c0                	test   %eax,%eax
  801cef:	78 55                	js     801d46 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cf1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cfa:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cff:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d06:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d0f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d11:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d14:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d1b:	83 ec 0c             	sub    $0xc,%esp
  801d1e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d21:	e8 15 f4 ff ff       	call   80113b <fd2num>
  801d26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d29:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d2b:	83 c4 04             	add    $0x4,%esp
  801d2e:	ff 75 f0             	pushl  -0x10(%ebp)
  801d31:	e8 05 f4 ff ff       	call   80113b <fd2num>
  801d36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d39:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801d3c:	83 c4 10             	add    $0x10,%esp
  801d3f:	ba 00 00 00 00       	mov    $0x0,%edx
  801d44:	eb 30                	jmp    801d76 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d46:	83 ec 08             	sub    $0x8,%esp
  801d49:	56                   	push   %esi
  801d4a:	6a 00                	push   $0x0
  801d4c:	e8 4c ef ff ff       	call   800c9d <sys_page_unmap>
  801d51:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d54:	83 ec 08             	sub    $0x8,%esp
  801d57:	ff 75 f0             	pushl  -0x10(%ebp)
  801d5a:	6a 00                	push   $0x0
  801d5c:	e8 3c ef ff ff       	call   800c9d <sys_page_unmap>
  801d61:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d64:	83 ec 08             	sub    $0x8,%esp
  801d67:	ff 75 f4             	pushl  -0xc(%ebp)
  801d6a:	6a 00                	push   $0x0
  801d6c:	e8 2c ef ff ff       	call   800c9d <sys_page_unmap>
  801d71:	83 c4 10             	add    $0x10,%esp
  801d74:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d76:	89 d0                	mov    %edx,%eax
  801d78:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d7b:	5b                   	pop    %ebx
  801d7c:	5e                   	pop    %esi
  801d7d:	5d                   	pop    %ebp
  801d7e:	c3                   	ret    

00801d7f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d7f:	55                   	push   %ebp
  801d80:	89 e5                	mov    %esp,%ebp
  801d82:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d85:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d88:	50                   	push   %eax
  801d89:	ff 75 08             	pushl  0x8(%ebp)
  801d8c:	e8 20 f4 ff ff       	call   8011b1 <fd_lookup>
  801d91:	83 c4 10             	add    $0x10,%esp
  801d94:	85 c0                	test   %eax,%eax
  801d96:	78 18                	js     801db0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d98:	83 ec 0c             	sub    $0xc,%esp
  801d9b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d9e:	e8 a8 f3 ff ff       	call   80114b <fd2data>
	return _pipeisclosed(fd, p);
  801da3:	89 c2                	mov    %eax,%edx
  801da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da8:	e8 21 fd ff ff       	call   801ace <_pipeisclosed>
  801dad:	83 c4 10             	add    $0x10,%esp
}
  801db0:	c9                   	leave  
  801db1:	c3                   	ret    

00801db2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801db2:	55                   	push   %ebp
  801db3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801db5:	b8 00 00 00 00       	mov    $0x0,%eax
  801dba:	5d                   	pop    %ebp
  801dbb:	c3                   	ret    

00801dbc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dbc:	55                   	push   %ebp
  801dbd:	89 e5                	mov    %esp,%ebp
  801dbf:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dc2:	68 ca 28 80 00       	push   $0x8028ca
  801dc7:	ff 75 0c             	pushl  0xc(%ebp)
  801dca:	e8 46 ea ff ff       	call   800815 <strcpy>
	return 0;
}
  801dcf:	b8 00 00 00 00       	mov    $0x0,%eax
  801dd4:	c9                   	leave  
  801dd5:	c3                   	ret    

00801dd6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dd6:	55                   	push   %ebp
  801dd7:	89 e5                	mov    %esp,%ebp
  801dd9:	57                   	push   %edi
  801dda:	56                   	push   %esi
  801ddb:	53                   	push   %ebx
  801ddc:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801de2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801de7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ded:	eb 2d                	jmp    801e1c <devcons_write+0x46>
		m = n - tot;
  801def:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801df2:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801df4:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801df7:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801dfc:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dff:	83 ec 04             	sub    $0x4,%esp
  801e02:	53                   	push   %ebx
  801e03:	03 45 0c             	add    0xc(%ebp),%eax
  801e06:	50                   	push   %eax
  801e07:	57                   	push   %edi
  801e08:	e8 9a eb ff ff       	call   8009a7 <memmove>
		sys_cputs(buf, m);
  801e0d:	83 c4 08             	add    $0x8,%esp
  801e10:	53                   	push   %ebx
  801e11:	57                   	push   %edi
  801e12:	e8 45 ed ff ff       	call   800b5c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e17:	01 de                	add    %ebx,%esi
  801e19:	83 c4 10             	add    $0x10,%esp
  801e1c:	89 f0                	mov    %esi,%eax
  801e1e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e21:	72 cc                	jb     801def <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e26:	5b                   	pop    %ebx
  801e27:	5e                   	pop    %esi
  801e28:	5f                   	pop    %edi
  801e29:	5d                   	pop    %ebp
  801e2a:	c3                   	ret    

00801e2b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e2b:	55                   	push   %ebp
  801e2c:	89 e5                	mov    %esp,%ebp
  801e2e:	83 ec 08             	sub    $0x8,%esp
  801e31:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e36:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e3a:	74 2a                	je     801e66 <devcons_read+0x3b>
  801e3c:	eb 05                	jmp    801e43 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e3e:	e8 b6 ed ff ff       	call   800bf9 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e43:	e8 32 ed ff ff       	call   800b7a <sys_cgetc>
  801e48:	85 c0                	test   %eax,%eax
  801e4a:	74 f2                	je     801e3e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e4c:	85 c0                	test   %eax,%eax
  801e4e:	78 16                	js     801e66 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e50:	83 f8 04             	cmp    $0x4,%eax
  801e53:	74 0c                	je     801e61 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e55:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e58:	88 02                	mov    %al,(%edx)
	return 1;
  801e5a:	b8 01 00 00 00       	mov    $0x1,%eax
  801e5f:	eb 05                	jmp    801e66 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e61:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e66:	c9                   	leave  
  801e67:	c3                   	ret    

00801e68 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e68:	55                   	push   %ebp
  801e69:	89 e5                	mov    %esp,%ebp
  801e6b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e71:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e74:	6a 01                	push   $0x1
  801e76:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e79:	50                   	push   %eax
  801e7a:	e8 dd ec ff ff       	call   800b5c <sys_cputs>
}
  801e7f:	83 c4 10             	add    $0x10,%esp
  801e82:	c9                   	leave  
  801e83:	c3                   	ret    

00801e84 <getchar>:

int
getchar(void)
{
  801e84:	55                   	push   %ebp
  801e85:	89 e5                	mov    %esp,%ebp
  801e87:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e8a:	6a 01                	push   $0x1
  801e8c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e8f:	50                   	push   %eax
  801e90:	6a 00                	push   $0x0
  801e92:	e8 80 f5 ff ff       	call   801417 <read>
	if (r < 0)
  801e97:	83 c4 10             	add    $0x10,%esp
  801e9a:	85 c0                	test   %eax,%eax
  801e9c:	78 0f                	js     801ead <getchar+0x29>
		return r;
	if (r < 1)
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	7e 06                	jle    801ea8 <getchar+0x24>
		return -E_EOF;
	return c;
  801ea2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ea6:	eb 05                	jmp    801ead <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ea8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ead:	c9                   	leave  
  801eae:	c3                   	ret    

00801eaf <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801eaf:	55                   	push   %ebp
  801eb0:	89 e5                	mov    %esp,%ebp
  801eb2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eb5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb8:	50                   	push   %eax
  801eb9:	ff 75 08             	pushl  0x8(%ebp)
  801ebc:	e8 f0 f2 ff ff       	call   8011b1 <fd_lookup>
  801ec1:	83 c4 10             	add    $0x10,%esp
  801ec4:	85 c0                	test   %eax,%eax
  801ec6:	78 11                	js     801ed9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ec8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ecb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ed1:	39 10                	cmp    %edx,(%eax)
  801ed3:	0f 94 c0             	sete   %al
  801ed6:	0f b6 c0             	movzbl %al,%eax
}
  801ed9:	c9                   	leave  
  801eda:	c3                   	ret    

00801edb <opencons>:

int
opencons(void)
{
  801edb:	55                   	push   %ebp
  801edc:	89 e5                	mov    %esp,%ebp
  801ede:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ee1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ee4:	50                   	push   %eax
  801ee5:	e8 78 f2 ff ff       	call   801162 <fd_alloc>
  801eea:	83 c4 10             	add    $0x10,%esp
		return r;
  801eed:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eef:	85 c0                	test   %eax,%eax
  801ef1:	78 3e                	js     801f31 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ef3:	83 ec 04             	sub    $0x4,%esp
  801ef6:	68 07 04 00 00       	push   $0x407
  801efb:	ff 75 f4             	pushl  -0xc(%ebp)
  801efe:	6a 00                	push   $0x0
  801f00:	e8 13 ed ff ff       	call   800c18 <sys_page_alloc>
  801f05:	83 c4 10             	add    $0x10,%esp
		return r;
  801f08:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f0a:	85 c0                	test   %eax,%eax
  801f0c:	78 23                	js     801f31 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f0e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f17:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f1c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f23:	83 ec 0c             	sub    $0xc,%esp
  801f26:	50                   	push   %eax
  801f27:	e8 0f f2 ff ff       	call   80113b <fd2num>
  801f2c:	89 c2                	mov    %eax,%edx
  801f2e:	83 c4 10             	add    $0x10,%esp
}
  801f31:	89 d0                	mov    %edx,%eax
  801f33:	c9                   	leave  
  801f34:	c3                   	ret    

00801f35 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f35:	55                   	push   %ebp
  801f36:	89 e5                	mov    %esp,%ebp
  801f38:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f3b:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801f42:	75 2a                	jne    801f6e <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801f44:	83 ec 04             	sub    $0x4,%esp
  801f47:	6a 07                	push   $0x7
  801f49:	68 00 f0 bf ee       	push   $0xeebff000
  801f4e:	6a 00                	push   $0x0
  801f50:	e8 c3 ec ff ff       	call   800c18 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801f55:	83 c4 10             	add    $0x10,%esp
  801f58:	85 c0                	test   %eax,%eax
  801f5a:	79 12                	jns    801f6e <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801f5c:	50                   	push   %eax
  801f5d:	68 16 24 80 00       	push   $0x802416
  801f62:	6a 23                	push   $0x23
  801f64:	68 d6 28 80 00       	push   $0x8028d6
  801f69:	e8 49 e2 ff ff       	call   8001b7 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f71:	a3 00 80 80 00       	mov    %eax,0x808000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801f76:	83 ec 08             	sub    $0x8,%esp
  801f79:	68 a0 1f 80 00       	push   $0x801fa0
  801f7e:	6a 00                	push   $0x0
  801f80:	e8 de ed ff ff       	call   800d63 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801f85:	83 c4 10             	add    $0x10,%esp
  801f88:	85 c0                	test   %eax,%eax
  801f8a:	79 12                	jns    801f9e <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801f8c:	50                   	push   %eax
  801f8d:	68 16 24 80 00       	push   $0x802416
  801f92:	6a 2c                	push   $0x2c
  801f94:	68 d6 28 80 00       	push   $0x8028d6
  801f99:	e8 19 e2 ff ff       	call   8001b7 <_panic>
	}
}
  801f9e:	c9                   	leave  
  801f9f:	c3                   	ret    

00801fa0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fa0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fa1:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  801fa6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fa8:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801fab:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801faf:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801fb4:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801fb8:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801fba:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801fbd:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801fbe:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801fc1:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801fc2:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801fc3:	c3                   	ret    

00801fc4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fc4:	55                   	push   %ebp
  801fc5:	89 e5                	mov    %esp,%ebp
  801fc7:	56                   	push   %esi
  801fc8:	53                   	push   %ebx
  801fc9:	8b 75 08             	mov    0x8(%ebp),%esi
  801fcc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fcf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801fd2:	85 c0                	test   %eax,%eax
  801fd4:	75 12                	jne    801fe8 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801fd6:	83 ec 0c             	sub    $0xc,%esp
  801fd9:	68 00 00 c0 ee       	push   $0xeec00000
  801fde:	e8 e5 ed ff ff       	call   800dc8 <sys_ipc_recv>
  801fe3:	83 c4 10             	add    $0x10,%esp
  801fe6:	eb 0c                	jmp    801ff4 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801fe8:	83 ec 0c             	sub    $0xc,%esp
  801feb:	50                   	push   %eax
  801fec:	e8 d7 ed ff ff       	call   800dc8 <sys_ipc_recv>
  801ff1:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801ff4:	85 f6                	test   %esi,%esi
  801ff6:	0f 95 c1             	setne  %cl
  801ff9:	85 db                	test   %ebx,%ebx
  801ffb:	0f 95 c2             	setne  %dl
  801ffe:	84 d1                	test   %dl,%cl
  802000:	74 09                	je     80200b <ipc_recv+0x47>
  802002:	89 c2                	mov    %eax,%edx
  802004:	c1 ea 1f             	shr    $0x1f,%edx
  802007:	84 d2                	test   %dl,%dl
  802009:	75 2a                	jne    802035 <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80200b:	85 f6                	test   %esi,%esi
  80200d:	74 0d                	je     80201c <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80200f:	a1 20 60 80 00       	mov    0x806020,%eax
  802014:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  80201a:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80201c:	85 db                	test   %ebx,%ebx
  80201e:	74 0d                	je     80202d <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802020:	a1 20 60 80 00       	mov    0x806020,%eax
  802025:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  80202b:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80202d:	a1 20 60 80 00       	mov    0x806020,%eax
  802032:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  802035:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802038:	5b                   	pop    %ebx
  802039:	5e                   	pop    %esi
  80203a:	5d                   	pop    %ebp
  80203b:	c3                   	ret    

0080203c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80203c:	55                   	push   %ebp
  80203d:	89 e5                	mov    %esp,%ebp
  80203f:	57                   	push   %edi
  802040:	56                   	push   %esi
  802041:	53                   	push   %ebx
  802042:	83 ec 0c             	sub    $0xc,%esp
  802045:	8b 7d 08             	mov    0x8(%ebp),%edi
  802048:	8b 75 0c             	mov    0xc(%ebp),%esi
  80204b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80204e:	85 db                	test   %ebx,%ebx
  802050:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802055:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802058:	ff 75 14             	pushl  0x14(%ebp)
  80205b:	53                   	push   %ebx
  80205c:	56                   	push   %esi
  80205d:	57                   	push   %edi
  80205e:	e8 42 ed ff ff       	call   800da5 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802063:	89 c2                	mov    %eax,%edx
  802065:	c1 ea 1f             	shr    $0x1f,%edx
  802068:	83 c4 10             	add    $0x10,%esp
  80206b:	84 d2                	test   %dl,%dl
  80206d:	74 17                	je     802086 <ipc_send+0x4a>
  80206f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802072:	74 12                	je     802086 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802074:	50                   	push   %eax
  802075:	68 e4 28 80 00       	push   $0x8028e4
  80207a:	6a 47                	push   $0x47
  80207c:	68 f2 28 80 00       	push   $0x8028f2
  802081:	e8 31 e1 ff ff       	call   8001b7 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802086:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802089:	75 07                	jne    802092 <ipc_send+0x56>
			sys_yield();
  80208b:	e8 69 eb ff ff       	call   800bf9 <sys_yield>
  802090:	eb c6                	jmp    802058 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802092:	85 c0                	test   %eax,%eax
  802094:	75 c2                	jne    802058 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802096:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802099:	5b                   	pop    %ebx
  80209a:	5e                   	pop    %esi
  80209b:	5f                   	pop    %edi
  80209c:	5d                   	pop    %ebp
  80209d:	c3                   	ret    

0080209e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80209e:	55                   	push   %ebp
  80209f:	89 e5                	mov    %esp,%ebp
  8020a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020a4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020a9:	89 c2                	mov    %eax,%edx
  8020ab:	c1 e2 07             	shl    $0x7,%edx
  8020ae:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  8020b5:	8b 52 5c             	mov    0x5c(%edx),%edx
  8020b8:	39 ca                	cmp    %ecx,%edx
  8020ba:	75 11                	jne    8020cd <ipc_find_env+0x2f>
			return envs[i].env_id;
  8020bc:	89 c2                	mov    %eax,%edx
  8020be:	c1 e2 07             	shl    $0x7,%edx
  8020c1:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8020c8:	8b 40 54             	mov    0x54(%eax),%eax
  8020cb:	eb 0f                	jmp    8020dc <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020cd:	83 c0 01             	add    $0x1,%eax
  8020d0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020d5:	75 d2                	jne    8020a9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020dc:	5d                   	pop    %ebp
  8020dd:	c3                   	ret    

008020de <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020de:	55                   	push   %ebp
  8020df:	89 e5                	mov    %esp,%ebp
  8020e1:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020e4:	89 d0                	mov    %edx,%eax
  8020e6:	c1 e8 16             	shr    $0x16,%eax
  8020e9:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020f0:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020f5:	f6 c1 01             	test   $0x1,%cl
  8020f8:	74 1d                	je     802117 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020fa:	c1 ea 0c             	shr    $0xc,%edx
  8020fd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802104:	f6 c2 01             	test   $0x1,%dl
  802107:	74 0e                	je     802117 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802109:	c1 ea 0c             	shr    $0xc,%edx
  80210c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802113:	ef 
  802114:	0f b7 c0             	movzwl %ax,%eax
}
  802117:	5d                   	pop    %ebp
  802118:	c3                   	ret    
  802119:	66 90                	xchg   %ax,%ax
  80211b:	66 90                	xchg   %ax,%ax
  80211d:	66 90                	xchg   %ax,%ax
  80211f:	90                   	nop

00802120 <__udivdi3>:
  802120:	55                   	push   %ebp
  802121:	57                   	push   %edi
  802122:	56                   	push   %esi
  802123:	53                   	push   %ebx
  802124:	83 ec 1c             	sub    $0x1c,%esp
  802127:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80212b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80212f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802133:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802137:	85 f6                	test   %esi,%esi
  802139:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80213d:	89 ca                	mov    %ecx,%edx
  80213f:	89 f8                	mov    %edi,%eax
  802141:	75 3d                	jne    802180 <__udivdi3+0x60>
  802143:	39 cf                	cmp    %ecx,%edi
  802145:	0f 87 c5 00 00 00    	ja     802210 <__udivdi3+0xf0>
  80214b:	85 ff                	test   %edi,%edi
  80214d:	89 fd                	mov    %edi,%ebp
  80214f:	75 0b                	jne    80215c <__udivdi3+0x3c>
  802151:	b8 01 00 00 00       	mov    $0x1,%eax
  802156:	31 d2                	xor    %edx,%edx
  802158:	f7 f7                	div    %edi
  80215a:	89 c5                	mov    %eax,%ebp
  80215c:	89 c8                	mov    %ecx,%eax
  80215e:	31 d2                	xor    %edx,%edx
  802160:	f7 f5                	div    %ebp
  802162:	89 c1                	mov    %eax,%ecx
  802164:	89 d8                	mov    %ebx,%eax
  802166:	89 cf                	mov    %ecx,%edi
  802168:	f7 f5                	div    %ebp
  80216a:	89 c3                	mov    %eax,%ebx
  80216c:	89 d8                	mov    %ebx,%eax
  80216e:	89 fa                	mov    %edi,%edx
  802170:	83 c4 1c             	add    $0x1c,%esp
  802173:	5b                   	pop    %ebx
  802174:	5e                   	pop    %esi
  802175:	5f                   	pop    %edi
  802176:	5d                   	pop    %ebp
  802177:	c3                   	ret    
  802178:	90                   	nop
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	39 ce                	cmp    %ecx,%esi
  802182:	77 74                	ja     8021f8 <__udivdi3+0xd8>
  802184:	0f bd fe             	bsr    %esi,%edi
  802187:	83 f7 1f             	xor    $0x1f,%edi
  80218a:	0f 84 98 00 00 00    	je     802228 <__udivdi3+0x108>
  802190:	bb 20 00 00 00       	mov    $0x20,%ebx
  802195:	89 f9                	mov    %edi,%ecx
  802197:	89 c5                	mov    %eax,%ebp
  802199:	29 fb                	sub    %edi,%ebx
  80219b:	d3 e6                	shl    %cl,%esi
  80219d:	89 d9                	mov    %ebx,%ecx
  80219f:	d3 ed                	shr    %cl,%ebp
  8021a1:	89 f9                	mov    %edi,%ecx
  8021a3:	d3 e0                	shl    %cl,%eax
  8021a5:	09 ee                	or     %ebp,%esi
  8021a7:	89 d9                	mov    %ebx,%ecx
  8021a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021ad:	89 d5                	mov    %edx,%ebp
  8021af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021b3:	d3 ed                	shr    %cl,%ebp
  8021b5:	89 f9                	mov    %edi,%ecx
  8021b7:	d3 e2                	shl    %cl,%edx
  8021b9:	89 d9                	mov    %ebx,%ecx
  8021bb:	d3 e8                	shr    %cl,%eax
  8021bd:	09 c2                	or     %eax,%edx
  8021bf:	89 d0                	mov    %edx,%eax
  8021c1:	89 ea                	mov    %ebp,%edx
  8021c3:	f7 f6                	div    %esi
  8021c5:	89 d5                	mov    %edx,%ebp
  8021c7:	89 c3                	mov    %eax,%ebx
  8021c9:	f7 64 24 0c          	mull   0xc(%esp)
  8021cd:	39 d5                	cmp    %edx,%ebp
  8021cf:	72 10                	jb     8021e1 <__udivdi3+0xc1>
  8021d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021d5:	89 f9                	mov    %edi,%ecx
  8021d7:	d3 e6                	shl    %cl,%esi
  8021d9:	39 c6                	cmp    %eax,%esi
  8021db:	73 07                	jae    8021e4 <__udivdi3+0xc4>
  8021dd:	39 d5                	cmp    %edx,%ebp
  8021df:	75 03                	jne    8021e4 <__udivdi3+0xc4>
  8021e1:	83 eb 01             	sub    $0x1,%ebx
  8021e4:	31 ff                	xor    %edi,%edi
  8021e6:	89 d8                	mov    %ebx,%eax
  8021e8:	89 fa                	mov    %edi,%edx
  8021ea:	83 c4 1c             	add    $0x1c,%esp
  8021ed:	5b                   	pop    %ebx
  8021ee:	5e                   	pop    %esi
  8021ef:	5f                   	pop    %edi
  8021f0:	5d                   	pop    %ebp
  8021f1:	c3                   	ret    
  8021f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021f8:	31 ff                	xor    %edi,%edi
  8021fa:	31 db                	xor    %ebx,%ebx
  8021fc:	89 d8                	mov    %ebx,%eax
  8021fe:	89 fa                	mov    %edi,%edx
  802200:	83 c4 1c             	add    $0x1c,%esp
  802203:	5b                   	pop    %ebx
  802204:	5e                   	pop    %esi
  802205:	5f                   	pop    %edi
  802206:	5d                   	pop    %ebp
  802207:	c3                   	ret    
  802208:	90                   	nop
  802209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802210:	89 d8                	mov    %ebx,%eax
  802212:	f7 f7                	div    %edi
  802214:	31 ff                	xor    %edi,%edi
  802216:	89 c3                	mov    %eax,%ebx
  802218:	89 d8                	mov    %ebx,%eax
  80221a:	89 fa                	mov    %edi,%edx
  80221c:	83 c4 1c             	add    $0x1c,%esp
  80221f:	5b                   	pop    %ebx
  802220:	5e                   	pop    %esi
  802221:	5f                   	pop    %edi
  802222:	5d                   	pop    %ebp
  802223:	c3                   	ret    
  802224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802228:	39 ce                	cmp    %ecx,%esi
  80222a:	72 0c                	jb     802238 <__udivdi3+0x118>
  80222c:	31 db                	xor    %ebx,%ebx
  80222e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802232:	0f 87 34 ff ff ff    	ja     80216c <__udivdi3+0x4c>
  802238:	bb 01 00 00 00       	mov    $0x1,%ebx
  80223d:	e9 2a ff ff ff       	jmp    80216c <__udivdi3+0x4c>
  802242:	66 90                	xchg   %ax,%ax
  802244:	66 90                	xchg   %ax,%ax
  802246:	66 90                	xchg   %ax,%ax
  802248:	66 90                	xchg   %ax,%ax
  80224a:	66 90                	xchg   %ax,%ax
  80224c:	66 90                	xchg   %ax,%ax
  80224e:	66 90                	xchg   %ax,%ax

00802250 <__umoddi3>:
  802250:	55                   	push   %ebp
  802251:	57                   	push   %edi
  802252:	56                   	push   %esi
  802253:	53                   	push   %ebx
  802254:	83 ec 1c             	sub    $0x1c,%esp
  802257:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80225b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80225f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802263:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802267:	85 d2                	test   %edx,%edx
  802269:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80226d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802271:	89 f3                	mov    %esi,%ebx
  802273:	89 3c 24             	mov    %edi,(%esp)
  802276:	89 74 24 04          	mov    %esi,0x4(%esp)
  80227a:	75 1c                	jne    802298 <__umoddi3+0x48>
  80227c:	39 f7                	cmp    %esi,%edi
  80227e:	76 50                	jbe    8022d0 <__umoddi3+0x80>
  802280:	89 c8                	mov    %ecx,%eax
  802282:	89 f2                	mov    %esi,%edx
  802284:	f7 f7                	div    %edi
  802286:	89 d0                	mov    %edx,%eax
  802288:	31 d2                	xor    %edx,%edx
  80228a:	83 c4 1c             	add    $0x1c,%esp
  80228d:	5b                   	pop    %ebx
  80228e:	5e                   	pop    %esi
  80228f:	5f                   	pop    %edi
  802290:	5d                   	pop    %ebp
  802291:	c3                   	ret    
  802292:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802298:	39 f2                	cmp    %esi,%edx
  80229a:	89 d0                	mov    %edx,%eax
  80229c:	77 52                	ja     8022f0 <__umoddi3+0xa0>
  80229e:	0f bd ea             	bsr    %edx,%ebp
  8022a1:	83 f5 1f             	xor    $0x1f,%ebp
  8022a4:	75 5a                	jne    802300 <__umoddi3+0xb0>
  8022a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022aa:	0f 82 e0 00 00 00    	jb     802390 <__umoddi3+0x140>
  8022b0:	39 0c 24             	cmp    %ecx,(%esp)
  8022b3:	0f 86 d7 00 00 00    	jbe    802390 <__umoddi3+0x140>
  8022b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022c1:	83 c4 1c             	add    $0x1c,%esp
  8022c4:	5b                   	pop    %ebx
  8022c5:	5e                   	pop    %esi
  8022c6:	5f                   	pop    %edi
  8022c7:	5d                   	pop    %ebp
  8022c8:	c3                   	ret    
  8022c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	85 ff                	test   %edi,%edi
  8022d2:	89 fd                	mov    %edi,%ebp
  8022d4:	75 0b                	jne    8022e1 <__umoddi3+0x91>
  8022d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022db:	31 d2                	xor    %edx,%edx
  8022dd:	f7 f7                	div    %edi
  8022df:	89 c5                	mov    %eax,%ebp
  8022e1:	89 f0                	mov    %esi,%eax
  8022e3:	31 d2                	xor    %edx,%edx
  8022e5:	f7 f5                	div    %ebp
  8022e7:	89 c8                	mov    %ecx,%eax
  8022e9:	f7 f5                	div    %ebp
  8022eb:	89 d0                	mov    %edx,%eax
  8022ed:	eb 99                	jmp    802288 <__umoddi3+0x38>
  8022ef:	90                   	nop
  8022f0:	89 c8                	mov    %ecx,%eax
  8022f2:	89 f2                	mov    %esi,%edx
  8022f4:	83 c4 1c             	add    $0x1c,%esp
  8022f7:	5b                   	pop    %ebx
  8022f8:	5e                   	pop    %esi
  8022f9:	5f                   	pop    %edi
  8022fa:	5d                   	pop    %ebp
  8022fb:	c3                   	ret    
  8022fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802300:	8b 34 24             	mov    (%esp),%esi
  802303:	bf 20 00 00 00       	mov    $0x20,%edi
  802308:	89 e9                	mov    %ebp,%ecx
  80230a:	29 ef                	sub    %ebp,%edi
  80230c:	d3 e0                	shl    %cl,%eax
  80230e:	89 f9                	mov    %edi,%ecx
  802310:	89 f2                	mov    %esi,%edx
  802312:	d3 ea                	shr    %cl,%edx
  802314:	89 e9                	mov    %ebp,%ecx
  802316:	09 c2                	or     %eax,%edx
  802318:	89 d8                	mov    %ebx,%eax
  80231a:	89 14 24             	mov    %edx,(%esp)
  80231d:	89 f2                	mov    %esi,%edx
  80231f:	d3 e2                	shl    %cl,%edx
  802321:	89 f9                	mov    %edi,%ecx
  802323:	89 54 24 04          	mov    %edx,0x4(%esp)
  802327:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80232b:	d3 e8                	shr    %cl,%eax
  80232d:	89 e9                	mov    %ebp,%ecx
  80232f:	89 c6                	mov    %eax,%esi
  802331:	d3 e3                	shl    %cl,%ebx
  802333:	89 f9                	mov    %edi,%ecx
  802335:	89 d0                	mov    %edx,%eax
  802337:	d3 e8                	shr    %cl,%eax
  802339:	89 e9                	mov    %ebp,%ecx
  80233b:	09 d8                	or     %ebx,%eax
  80233d:	89 d3                	mov    %edx,%ebx
  80233f:	89 f2                	mov    %esi,%edx
  802341:	f7 34 24             	divl   (%esp)
  802344:	89 d6                	mov    %edx,%esi
  802346:	d3 e3                	shl    %cl,%ebx
  802348:	f7 64 24 04          	mull   0x4(%esp)
  80234c:	39 d6                	cmp    %edx,%esi
  80234e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802352:	89 d1                	mov    %edx,%ecx
  802354:	89 c3                	mov    %eax,%ebx
  802356:	72 08                	jb     802360 <__umoddi3+0x110>
  802358:	75 11                	jne    80236b <__umoddi3+0x11b>
  80235a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80235e:	73 0b                	jae    80236b <__umoddi3+0x11b>
  802360:	2b 44 24 04          	sub    0x4(%esp),%eax
  802364:	1b 14 24             	sbb    (%esp),%edx
  802367:	89 d1                	mov    %edx,%ecx
  802369:	89 c3                	mov    %eax,%ebx
  80236b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80236f:	29 da                	sub    %ebx,%edx
  802371:	19 ce                	sbb    %ecx,%esi
  802373:	89 f9                	mov    %edi,%ecx
  802375:	89 f0                	mov    %esi,%eax
  802377:	d3 e0                	shl    %cl,%eax
  802379:	89 e9                	mov    %ebp,%ecx
  80237b:	d3 ea                	shr    %cl,%edx
  80237d:	89 e9                	mov    %ebp,%ecx
  80237f:	d3 ee                	shr    %cl,%esi
  802381:	09 d0                	or     %edx,%eax
  802383:	89 f2                	mov    %esi,%edx
  802385:	83 c4 1c             	add    $0x1c,%esp
  802388:	5b                   	pop    %ebx
  802389:	5e                   	pop    %esi
  80238a:	5f                   	pop    %edi
  80238b:	5d                   	pop    %ebp
  80238c:	c3                   	ret    
  80238d:	8d 76 00             	lea    0x0(%esi),%esi
  802390:	29 f9                	sub    %edi,%ecx
  802392:	19 d6                	sbb    %edx,%esi
  802394:	89 74 24 04          	mov    %esi,0x4(%esp)
  802398:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80239c:	e9 18 ff ff ff       	jmp    8022b9 <__umoddi3+0x69>
