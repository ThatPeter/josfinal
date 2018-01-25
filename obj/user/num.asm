
obj/user/num.debug:     file format elf32-i386


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
  80002c:	e8 54 01 00 00       	call   800185 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <num>:
int bol = 1;
int line = 0;

void
num(int f, const char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
  80003b:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  80003e:	8d 5d f7             	lea    -0x9(%ebp),%ebx
  800041:	eb 6e                	jmp    8000b1 <num+0x7e>
		if (bol) {
  800043:	83 3d 00 30 80 00 00 	cmpl   $0x0,0x803000
  80004a:	74 28                	je     800074 <num+0x41>
			printf("%5d ", ++line);
  80004c:	a1 00 40 80 00       	mov    0x804000,%eax
  800051:	83 c0 01             	add    $0x1,%eax
  800054:	a3 00 40 80 00       	mov    %eax,0x804000
  800059:	83 ec 08             	sub    $0x8,%esp
  80005c:	50                   	push   %eax
  80005d:	68 00 24 80 00       	push   $0x802400
  800062:	e8 2b 1a 00 00       	call   801a92 <printf>
			bol = 0;
  800067:	c7 05 00 30 80 00 00 	movl   $0x0,0x803000
  80006e:	00 00 00 
  800071:	83 c4 10             	add    $0x10,%esp
		}
		if ((r = write(1, &c, 1)) != 1)
  800074:	83 ec 04             	sub    $0x4,%esp
  800077:	6a 01                	push   $0x1
  800079:	53                   	push   %ebx
  80007a:	6a 01                	push   $0x1
  80007c:	e8 c2 14 00 00       	call   801543 <write>
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	83 f8 01             	cmp    $0x1,%eax
  800087:	74 18                	je     8000a1 <num+0x6e>
			panic("write error copying %s: %e", s, r);
  800089:	83 ec 0c             	sub    $0xc,%esp
  80008c:	50                   	push   %eax
  80008d:	ff 75 0c             	pushl  0xc(%ebp)
  800090:	68 05 24 80 00       	push   $0x802405
  800095:	6a 13                	push   $0x13
  800097:	68 20 24 80 00       	push   $0x802420
  80009c:	e8 68 01 00 00       	call   800209 <_panic>
		if (c == '\n')
  8000a1:	80 7d f7 0a          	cmpb   $0xa,-0x9(%ebp)
  8000a5:	75 0a                	jne    8000b1 <num+0x7e>
			bol = 1;
  8000a7:	c7 05 00 30 80 00 01 	movl   $0x1,0x803000
  8000ae:	00 00 00 
{
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  8000b1:	83 ec 04             	sub    $0x4,%esp
  8000b4:	6a 01                	push   $0x1
  8000b6:	53                   	push   %ebx
  8000b7:	56                   	push   %esi
  8000b8:	e8 ac 13 00 00       	call   801469 <read>
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	85 c0                	test   %eax,%eax
  8000c2:	0f 8f 7b ff ff ff    	jg     800043 <num+0x10>
		if ((r = write(1, &c, 1)) != 1)
			panic("write error copying %s: %e", s, r);
		if (c == '\n')
			bol = 1;
	}
	if (n < 0)
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	79 18                	jns    8000e4 <num+0xb1>
		panic("error reading %s: %e", s, n);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	50                   	push   %eax
  8000d0:	ff 75 0c             	pushl  0xc(%ebp)
  8000d3:	68 2b 24 80 00       	push   $0x80242b
  8000d8:	6a 18                	push   $0x18
  8000da:	68 20 24 80 00       	push   $0x802420
  8000df:	e8 25 01 00 00       	call   800209 <_panic>
}
  8000e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e7:	5b                   	pop    %ebx
  8000e8:	5e                   	pop    %esi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 1c             	sub    $0x1c,%esp
	int f, i;

	binaryname = "num";
  8000f4:	c7 05 04 30 80 00 40 	movl   $0x802440,0x803004
  8000fb:	24 80 00 
	if (argc == 1)
  8000fe:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  800102:	74 0d                	je     800111 <umain+0x26>
  800104:	8b 45 0c             	mov    0xc(%ebp),%eax
  800107:	8d 58 04             	lea    0x4(%eax),%ebx
  80010a:	bf 01 00 00 00       	mov    $0x1,%edi
  80010f:	eb 62                	jmp    800173 <umain+0x88>
		num(0, "<stdin>");
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	68 44 24 80 00       	push   $0x802444
  800119:	6a 00                	push   $0x0
  80011b:	e8 13 ff ff ff       	call   800033 <num>
  800120:	83 c4 10             	add    $0x10,%esp
  800123:	eb 53                	jmp    800178 <umain+0x8d>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  800125:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 00                	push   $0x0
  80012d:	ff 33                	pushl  (%ebx)
  80012f:	e8 c0 17 00 00       	call   8018f4 <open>
  800134:	89 c6                	mov    %eax,%esi
			if (f < 0)
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	85 c0                	test   %eax,%eax
  80013b:	79 1a                	jns    800157 <umain+0x6c>
				panic("can't open %s: %e", argv[i], f);
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	50                   	push   %eax
  800141:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800144:	ff 30                	pushl  (%eax)
  800146:	68 4c 24 80 00       	push   $0x80244c
  80014b:	6a 27                	push   $0x27
  80014d:	68 20 24 80 00       	push   $0x802420
  800152:	e8 b2 00 00 00       	call   800209 <_panic>
			else {
				num(f, argv[i]);
  800157:	83 ec 08             	sub    $0x8,%esp
  80015a:	ff 33                	pushl  (%ebx)
  80015c:	50                   	push   %eax
  80015d:	e8 d1 fe ff ff       	call   800033 <num>
				close(f);
  800162:	89 34 24             	mov    %esi,(%esp)
  800165:	e8 c3 11 00 00       	call   80132d <close>

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  80016a:	83 c7 01             	add    $0x1,%edi
  80016d:	83 c3 04             	add    $0x4,%ebx
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	3b 7d 08             	cmp    0x8(%ebp),%edi
  800176:	7c ad                	jl     800125 <umain+0x3a>
			else {
				num(f, argv[i]);
				close(f);
			}
		}
	exit();
  800178:	e8 72 00 00 00       	call   8001ef <exit>
}
  80017d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800180:	5b                   	pop    %ebx
  800181:	5e                   	pop    %esi
  800182:	5f                   	pop    %edi
  800183:	5d                   	pop    %ebp
  800184:	c3                   	ret    

00800185 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	56                   	push   %esi
  800189:	53                   	push   %ebx
  80018a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80018d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800190:	e8 97 0a 00 00       	call   800c2c <sys_getenvid>
  800195:	25 ff 03 00 00       	and    $0x3ff,%eax
  80019a:	89 c2                	mov    %eax,%edx
  80019c:	c1 e2 07             	shl    $0x7,%edx
  80019f:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8001a6:	a3 08 40 80 00       	mov    %eax,0x804008
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001ab:	85 db                	test   %ebx,%ebx
  8001ad:	7e 07                	jle    8001b6 <libmain+0x31>
		binaryname = argv[0];
  8001af:	8b 06                	mov    (%esi),%eax
  8001b1:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8001b6:	83 ec 08             	sub    $0x8,%esp
  8001b9:	56                   	push   %esi
  8001ba:	53                   	push   %ebx
  8001bb:	e8 2b ff ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8001c0:	e8 2a 00 00 00       	call   8001ef <exit>
}
  8001c5:	83 c4 10             	add    $0x10,%esp
  8001c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001cb:	5b                   	pop    %ebx
  8001cc:	5e                   	pop    %esi
  8001cd:	5d                   	pop    %ebp
  8001ce:	c3                   	ret    

008001cf <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  8001d5:	a1 0c 40 80 00       	mov    0x80400c,%eax
	func();
  8001da:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8001dc:	e8 4b 0a 00 00       	call   800c2c <sys_getenvid>
  8001e1:	83 ec 0c             	sub    $0xc,%esp
  8001e4:	50                   	push   %eax
  8001e5:	e8 91 0c 00 00       	call   800e7b <sys_thread_free>
}
  8001ea:	83 c4 10             	add    $0x10,%esp
  8001ed:	c9                   	leave  
  8001ee:	c3                   	ret    

008001ef <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001f5:	e8 5e 11 00 00       	call   801358 <close_all>
	sys_env_destroy(0);
  8001fa:	83 ec 0c             	sub    $0xc,%esp
  8001fd:	6a 00                	push   $0x0
  8001ff:	e8 e7 09 00 00       	call   800beb <sys_env_destroy>
}
  800204:	83 c4 10             	add    $0x10,%esp
  800207:	c9                   	leave  
  800208:	c3                   	ret    

00800209 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	56                   	push   %esi
  80020d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80020e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800211:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800217:	e8 10 0a 00 00       	call   800c2c <sys_getenvid>
  80021c:	83 ec 0c             	sub    $0xc,%esp
  80021f:	ff 75 0c             	pushl  0xc(%ebp)
  800222:	ff 75 08             	pushl  0x8(%ebp)
  800225:	56                   	push   %esi
  800226:	50                   	push   %eax
  800227:	68 68 24 80 00       	push   $0x802468
  80022c:	e8 b1 00 00 00       	call   8002e2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800231:	83 c4 18             	add    $0x18,%esp
  800234:	53                   	push   %ebx
  800235:	ff 75 10             	pushl  0x10(%ebp)
  800238:	e8 54 00 00 00       	call   800291 <vcprintf>
	cprintf("\n");
  80023d:	c7 04 24 03 29 80 00 	movl   $0x802903,(%esp)
  800244:	e8 99 00 00 00       	call   8002e2 <cprintf>
  800249:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80024c:	cc                   	int3   
  80024d:	eb fd                	jmp    80024c <_panic+0x43>

0080024f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	53                   	push   %ebx
  800253:	83 ec 04             	sub    $0x4,%esp
  800256:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800259:	8b 13                	mov    (%ebx),%edx
  80025b:	8d 42 01             	lea    0x1(%edx),%eax
  80025e:	89 03                	mov    %eax,(%ebx)
  800260:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800263:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800267:	3d ff 00 00 00       	cmp    $0xff,%eax
  80026c:	75 1a                	jne    800288 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80026e:	83 ec 08             	sub    $0x8,%esp
  800271:	68 ff 00 00 00       	push   $0xff
  800276:	8d 43 08             	lea    0x8(%ebx),%eax
  800279:	50                   	push   %eax
  80027a:	e8 2f 09 00 00       	call   800bae <sys_cputs>
		b->idx = 0;
  80027f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800285:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800288:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80028c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80028f:	c9                   	leave  
  800290:	c3                   	ret    

00800291 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80029a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002a1:	00 00 00 
	b.cnt = 0;
  8002a4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002ab:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002ae:	ff 75 0c             	pushl  0xc(%ebp)
  8002b1:	ff 75 08             	pushl  0x8(%ebp)
  8002b4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002ba:	50                   	push   %eax
  8002bb:	68 4f 02 80 00       	push   $0x80024f
  8002c0:	e8 54 01 00 00       	call   800419 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002c5:	83 c4 08             	add    $0x8,%esp
  8002c8:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002ce:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002d4:	50                   	push   %eax
  8002d5:	e8 d4 08 00 00       	call   800bae <sys_cputs>

	return b.cnt;
}
  8002da:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002e0:	c9                   	leave  
  8002e1:	c3                   	ret    

008002e2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002e8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002eb:	50                   	push   %eax
  8002ec:	ff 75 08             	pushl  0x8(%ebp)
  8002ef:	e8 9d ff ff ff       	call   800291 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002f4:	c9                   	leave  
  8002f5:	c3                   	ret    

008002f6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002f6:	55                   	push   %ebp
  8002f7:	89 e5                	mov    %esp,%ebp
  8002f9:	57                   	push   %edi
  8002fa:	56                   	push   %esi
  8002fb:	53                   	push   %ebx
  8002fc:	83 ec 1c             	sub    $0x1c,%esp
  8002ff:	89 c7                	mov    %eax,%edi
  800301:	89 d6                	mov    %edx,%esi
  800303:	8b 45 08             	mov    0x8(%ebp),%eax
  800306:	8b 55 0c             	mov    0xc(%ebp),%edx
  800309:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80030c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80030f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800312:	bb 00 00 00 00       	mov    $0x0,%ebx
  800317:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80031a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80031d:	39 d3                	cmp    %edx,%ebx
  80031f:	72 05                	jb     800326 <printnum+0x30>
  800321:	39 45 10             	cmp    %eax,0x10(%ebp)
  800324:	77 45                	ja     80036b <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800326:	83 ec 0c             	sub    $0xc,%esp
  800329:	ff 75 18             	pushl  0x18(%ebp)
  80032c:	8b 45 14             	mov    0x14(%ebp),%eax
  80032f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800332:	53                   	push   %ebx
  800333:	ff 75 10             	pushl  0x10(%ebp)
  800336:	83 ec 08             	sub    $0x8,%esp
  800339:	ff 75 e4             	pushl  -0x1c(%ebp)
  80033c:	ff 75 e0             	pushl  -0x20(%ebp)
  80033f:	ff 75 dc             	pushl  -0x24(%ebp)
  800342:	ff 75 d8             	pushl  -0x28(%ebp)
  800345:	e8 26 1e 00 00       	call   802170 <__udivdi3>
  80034a:	83 c4 18             	add    $0x18,%esp
  80034d:	52                   	push   %edx
  80034e:	50                   	push   %eax
  80034f:	89 f2                	mov    %esi,%edx
  800351:	89 f8                	mov    %edi,%eax
  800353:	e8 9e ff ff ff       	call   8002f6 <printnum>
  800358:	83 c4 20             	add    $0x20,%esp
  80035b:	eb 18                	jmp    800375 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80035d:	83 ec 08             	sub    $0x8,%esp
  800360:	56                   	push   %esi
  800361:	ff 75 18             	pushl  0x18(%ebp)
  800364:	ff d7                	call   *%edi
  800366:	83 c4 10             	add    $0x10,%esp
  800369:	eb 03                	jmp    80036e <printnum+0x78>
  80036b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80036e:	83 eb 01             	sub    $0x1,%ebx
  800371:	85 db                	test   %ebx,%ebx
  800373:	7f e8                	jg     80035d <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800375:	83 ec 08             	sub    $0x8,%esp
  800378:	56                   	push   %esi
  800379:	83 ec 04             	sub    $0x4,%esp
  80037c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80037f:	ff 75 e0             	pushl  -0x20(%ebp)
  800382:	ff 75 dc             	pushl  -0x24(%ebp)
  800385:	ff 75 d8             	pushl  -0x28(%ebp)
  800388:	e8 13 1f 00 00       	call   8022a0 <__umoddi3>
  80038d:	83 c4 14             	add    $0x14,%esp
  800390:	0f be 80 8b 24 80 00 	movsbl 0x80248b(%eax),%eax
  800397:	50                   	push   %eax
  800398:	ff d7                	call   *%edi
}
  80039a:	83 c4 10             	add    $0x10,%esp
  80039d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003a0:	5b                   	pop    %ebx
  8003a1:	5e                   	pop    %esi
  8003a2:	5f                   	pop    %edi
  8003a3:	5d                   	pop    %ebp
  8003a4:	c3                   	ret    

008003a5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003a5:	55                   	push   %ebp
  8003a6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003a8:	83 fa 01             	cmp    $0x1,%edx
  8003ab:	7e 0e                	jle    8003bb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003ad:	8b 10                	mov    (%eax),%edx
  8003af:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003b2:	89 08                	mov    %ecx,(%eax)
  8003b4:	8b 02                	mov    (%edx),%eax
  8003b6:	8b 52 04             	mov    0x4(%edx),%edx
  8003b9:	eb 22                	jmp    8003dd <getuint+0x38>
	else if (lflag)
  8003bb:	85 d2                	test   %edx,%edx
  8003bd:	74 10                	je     8003cf <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003bf:	8b 10                	mov    (%eax),%edx
  8003c1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c4:	89 08                	mov    %ecx,(%eax)
  8003c6:	8b 02                	mov    (%edx),%eax
  8003c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003cd:	eb 0e                	jmp    8003dd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003cf:	8b 10                	mov    (%eax),%edx
  8003d1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d4:	89 08                	mov    %ecx,(%eax)
  8003d6:	8b 02                	mov    (%edx),%eax
  8003d8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003dd:	5d                   	pop    %ebp
  8003de:	c3                   	ret    

008003df <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003df:	55                   	push   %ebp
  8003e0:	89 e5                	mov    %esp,%ebp
  8003e2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003e5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003e9:	8b 10                	mov    (%eax),%edx
  8003eb:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ee:	73 0a                	jae    8003fa <sprintputch+0x1b>
		*b->buf++ = ch;
  8003f0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003f3:	89 08                	mov    %ecx,(%eax)
  8003f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f8:	88 02                	mov    %al,(%edx)
}
  8003fa:	5d                   	pop    %ebp
  8003fb:	c3                   	ret    

008003fc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
  8003ff:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800402:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800405:	50                   	push   %eax
  800406:	ff 75 10             	pushl  0x10(%ebp)
  800409:	ff 75 0c             	pushl  0xc(%ebp)
  80040c:	ff 75 08             	pushl  0x8(%ebp)
  80040f:	e8 05 00 00 00       	call   800419 <vprintfmt>
	va_end(ap);
}
  800414:	83 c4 10             	add    $0x10,%esp
  800417:	c9                   	leave  
  800418:	c3                   	ret    

00800419 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800419:	55                   	push   %ebp
  80041a:	89 e5                	mov    %esp,%ebp
  80041c:	57                   	push   %edi
  80041d:	56                   	push   %esi
  80041e:	53                   	push   %ebx
  80041f:	83 ec 2c             	sub    $0x2c,%esp
  800422:	8b 75 08             	mov    0x8(%ebp),%esi
  800425:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800428:	8b 7d 10             	mov    0x10(%ebp),%edi
  80042b:	eb 12                	jmp    80043f <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80042d:	85 c0                	test   %eax,%eax
  80042f:	0f 84 89 03 00 00    	je     8007be <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800435:	83 ec 08             	sub    $0x8,%esp
  800438:	53                   	push   %ebx
  800439:	50                   	push   %eax
  80043a:	ff d6                	call   *%esi
  80043c:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80043f:	83 c7 01             	add    $0x1,%edi
  800442:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800446:	83 f8 25             	cmp    $0x25,%eax
  800449:	75 e2                	jne    80042d <vprintfmt+0x14>
  80044b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80044f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800456:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80045d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800464:	ba 00 00 00 00       	mov    $0x0,%edx
  800469:	eb 07                	jmp    800472 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80046e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800472:	8d 47 01             	lea    0x1(%edi),%eax
  800475:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800478:	0f b6 07             	movzbl (%edi),%eax
  80047b:	0f b6 c8             	movzbl %al,%ecx
  80047e:	83 e8 23             	sub    $0x23,%eax
  800481:	3c 55                	cmp    $0x55,%al
  800483:	0f 87 1a 03 00 00    	ja     8007a3 <vprintfmt+0x38a>
  800489:	0f b6 c0             	movzbl %al,%eax
  80048c:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  800493:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800496:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80049a:	eb d6                	jmp    800472 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80049f:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004a7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004aa:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004ae:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004b1:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004b4:	83 fa 09             	cmp    $0x9,%edx
  8004b7:	77 39                	ja     8004f2 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004b9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004bc:	eb e9                	jmp    8004a7 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004be:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c1:	8d 48 04             	lea    0x4(%eax),%ecx
  8004c4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004c7:	8b 00                	mov    (%eax),%eax
  8004c9:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004cf:	eb 27                	jmp    8004f8 <vprintfmt+0xdf>
  8004d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004d4:	85 c0                	test   %eax,%eax
  8004d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004db:	0f 49 c8             	cmovns %eax,%ecx
  8004de:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004e4:	eb 8c                	jmp    800472 <vprintfmt+0x59>
  8004e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004e9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004f0:	eb 80                	jmp    800472 <vprintfmt+0x59>
  8004f2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004f5:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004f8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004fc:	0f 89 70 ff ff ff    	jns    800472 <vprintfmt+0x59>
				width = precision, precision = -1;
  800502:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800505:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800508:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80050f:	e9 5e ff ff ff       	jmp    800472 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800514:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800517:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80051a:	e9 53 ff ff ff       	jmp    800472 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80051f:	8b 45 14             	mov    0x14(%ebp),%eax
  800522:	8d 50 04             	lea    0x4(%eax),%edx
  800525:	89 55 14             	mov    %edx,0x14(%ebp)
  800528:	83 ec 08             	sub    $0x8,%esp
  80052b:	53                   	push   %ebx
  80052c:	ff 30                	pushl  (%eax)
  80052e:	ff d6                	call   *%esi
			break;
  800530:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800533:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800536:	e9 04 ff ff ff       	jmp    80043f <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80053b:	8b 45 14             	mov    0x14(%ebp),%eax
  80053e:	8d 50 04             	lea    0x4(%eax),%edx
  800541:	89 55 14             	mov    %edx,0x14(%ebp)
  800544:	8b 00                	mov    (%eax),%eax
  800546:	99                   	cltd   
  800547:	31 d0                	xor    %edx,%eax
  800549:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80054b:	83 f8 0f             	cmp    $0xf,%eax
  80054e:	7f 0b                	jg     80055b <vprintfmt+0x142>
  800550:	8b 14 85 20 27 80 00 	mov    0x802720(,%eax,4),%edx
  800557:	85 d2                	test   %edx,%edx
  800559:	75 18                	jne    800573 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80055b:	50                   	push   %eax
  80055c:	68 a3 24 80 00       	push   $0x8024a3
  800561:	53                   	push   %ebx
  800562:	56                   	push   %esi
  800563:	e8 94 fe ff ff       	call   8003fc <printfmt>
  800568:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80056e:	e9 cc fe ff ff       	jmp    80043f <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800573:	52                   	push   %edx
  800574:	68 d1 28 80 00       	push   $0x8028d1
  800579:	53                   	push   %ebx
  80057a:	56                   	push   %esi
  80057b:	e8 7c fe ff ff       	call   8003fc <printfmt>
  800580:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800583:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800586:	e9 b4 fe ff ff       	jmp    80043f <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80058b:	8b 45 14             	mov    0x14(%ebp),%eax
  80058e:	8d 50 04             	lea    0x4(%eax),%edx
  800591:	89 55 14             	mov    %edx,0x14(%ebp)
  800594:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800596:	85 ff                	test   %edi,%edi
  800598:	b8 9c 24 80 00       	mov    $0x80249c,%eax
  80059d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005a0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005a4:	0f 8e 94 00 00 00    	jle    80063e <vprintfmt+0x225>
  8005aa:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005ae:	0f 84 98 00 00 00    	je     80064c <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b4:	83 ec 08             	sub    $0x8,%esp
  8005b7:	ff 75 d0             	pushl  -0x30(%ebp)
  8005ba:	57                   	push   %edi
  8005bb:	e8 86 02 00 00       	call   800846 <strnlen>
  8005c0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005c3:	29 c1                	sub    %eax,%ecx
  8005c5:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005c8:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005cb:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d2:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005d5:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d7:	eb 0f                	jmp    8005e8 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005d9:	83 ec 08             	sub    $0x8,%esp
  8005dc:	53                   	push   %ebx
  8005dd:	ff 75 e0             	pushl  -0x20(%ebp)
  8005e0:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e2:	83 ef 01             	sub    $0x1,%edi
  8005e5:	83 c4 10             	add    $0x10,%esp
  8005e8:	85 ff                	test   %edi,%edi
  8005ea:	7f ed                	jg     8005d9 <vprintfmt+0x1c0>
  8005ec:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005ef:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005f2:	85 c9                	test   %ecx,%ecx
  8005f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f9:	0f 49 c1             	cmovns %ecx,%eax
  8005fc:	29 c1                	sub    %eax,%ecx
  8005fe:	89 75 08             	mov    %esi,0x8(%ebp)
  800601:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800604:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800607:	89 cb                	mov    %ecx,%ebx
  800609:	eb 4d                	jmp    800658 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80060b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80060f:	74 1b                	je     80062c <vprintfmt+0x213>
  800611:	0f be c0             	movsbl %al,%eax
  800614:	83 e8 20             	sub    $0x20,%eax
  800617:	83 f8 5e             	cmp    $0x5e,%eax
  80061a:	76 10                	jbe    80062c <vprintfmt+0x213>
					putch('?', putdat);
  80061c:	83 ec 08             	sub    $0x8,%esp
  80061f:	ff 75 0c             	pushl  0xc(%ebp)
  800622:	6a 3f                	push   $0x3f
  800624:	ff 55 08             	call   *0x8(%ebp)
  800627:	83 c4 10             	add    $0x10,%esp
  80062a:	eb 0d                	jmp    800639 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	ff 75 0c             	pushl  0xc(%ebp)
  800632:	52                   	push   %edx
  800633:	ff 55 08             	call   *0x8(%ebp)
  800636:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800639:	83 eb 01             	sub    $0x1,%ebx
  80063c:	eb 1a                	jmp    800658 <vprintfmt+0x23f>
  80063e:	89 75 08             	mov    %esi,0x8(%ebp)
  800641:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800644:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800647:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80064a:	eb 0c                	jmp    800658 <vprintfmt+0x23f>
  80064c:	89 75 08             	mov    %esi,0x8(%ebp)
  80064f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800652:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800655:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800658:	83 c7 01             	add    $0x1,%edi
  80065b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80065f:	0f be d0             	movsbl %al,%edx
  800662:	85 d2                	test   %edx,%edx
  800664:	74 23                	je     800689 <vprintfmt+0x270>
  800666:	85 f6                	test   %esi,%esi
  800668:	78 a1                	js     80060b <vprintfmt+0x1f2>
  80066a:	83 ee 01             	sub    $0x1,%esi
  80066d:	79 9c                	jns    80060b <vprintfmt+0x1f2>
  80066f:	89 df                	mov    %ebx,%edi
  800671:	8b 75 08             	mov    0x8(%ebp),%esi
  800674:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800677:	eb 18                	jmp    800691 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800679:	83 ec 08             	sub    $0x8,%esp
  80067c:	53                   	push   %ebx
  80067d:	6a 20                	push   $0x20
  80067f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800681:	83 ef 01             	sub    $0x1,%edi
  800684:	83 c4 10             	add    $0x10,%esp
  800687:	eb 08                	jmp    800691 <vprintfmt+0x278>
  800689:	89 df                	mov    %ebx,%edi
  80068b:	8b 75 08             	mov    0x8(%ebp),%esi
  80068e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800691:	85 ff                	test   %edi,%edi
  800693:	7f e4                	jg     800679 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800695:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800698:	e9 a2 fd ff ff       	jmp    80043f <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80069d:	83 fa 01             	cmp    $0x1,%edx
  8006a0:	7e 16                	jle    8006b8 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a5:	8d 50 08             	lea    0x8(%eax),%edx
  8006a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ab:	8b 50 04             	mov    0x4(%eax),%edx
  8006ae:	8b 00                	mov    (%eax),%eax
  8006b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006b6:	eb 32                	jmp    8006ea <vprintfmt+0x2d1>
	else if (lflag)
  8006b8:	85 d2                	test   %edx,%edx
  8006ba:	74 18                	je     8006d4 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bf:	8d 50 04             	lea    0x4(%eax),%edx
  8006c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c5:	8b 00                	mov    (%eax),%eax
  8006c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ca:	89 c1                	mov    %eax,%ecx
  8006cc:	c1 f9 1f             	sar    $0x1f,%ecx
  8006cf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006d2:	eb 16                	jmp    8006ea <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8d 50 04             	lea    0x4(%eax),%edx
  8006da:	89 55 14             	mov    %edx,0x14(%ebp)
  8006dd:	8b 00                	mov    (%eax),%eax
  8006df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e2:	89 c1                	mov    %eax,%ecx
  8006e4:	c1 f9 1f             	sar    $0x1f,%ecx
  8006e7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006ea:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006ed:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006f0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006f5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006f9:	79 74                	jns    80076f <vprintfmt+0x356>
				putch('-', putdat);
  8006fb:	83 ec 08             	sub    $0x8,%esp
  8006fe:	53                   	push   %ebx
  8006ff:	6a 2d                	push   $0x2d
  800701:	ff d6                	call   *%esi
				num = -(long long) num;
  800703:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800706:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800709:	f7 d8                	neg    %eax
  80070b:	83 d2 00             	adc    $0x0,%edx
  80070e:	f7 da                	neg    %edx
  800710:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800713:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800718:	eb 55                	jmp    80076f <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80071a:	8d 45 14             	lea    0x14(%ebp),%eax
  80071d:	e8 83 fc ff ff       	call   8003a5 <getuint>
			base = 10;
  800722:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800727:	eb 46                	jmp    80076f <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800729:	8d 45 14             	lea    0x14(%ebp),%eax
  80072c:	e8 74 fc ff ff       	call   8003a5 <getuint>
			base = 8;
  800731:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800736:	eb 37                	jmp    80076f <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800738:	83 ec 08             	sub    $0x8,%esp
  80073b:	53                   	push   %ebx
  80073c:	6a 30                	push   $0x30
  80073e:	ff d6                	call   *%esi
			putch('x', putdat);
  800740:	83 c4 08             	add    $0x8,%esp
  800743:	53                   	push   %ebx
  800744:	6a 78                	push   $0x78
  800746:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800748:	8b 45 14             	mov    0x14(%ebp),%eax
  80074b:	8d 50 04             	lea    0x4(%eax),%edx
  80074e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800751:	8b 00                	mov    (%eax),%eax
  800753:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800758:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80075b:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800760:	eb 0d                	jmp    80076f <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800762:	8d 45 14             	lea    0x14(%ebp),%eax
  800765:	e8 3b fc ff ff       	call   8003a5 <getuint>
			base = 16;
  80076a:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80076f:	83 ec 0c             	sub    $0xc,%esp
  800772:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800776:	57                   	push   %edi
  800777:	ff 75 e0             	pushl  -0x20(%ebp)
  80077a:	51                   	push   %ecx
  80077b:	52                   	push   %edx
  80077c:	50                   	push   %eax
  80077d:	89 da                	mov    %ebx,%edx
  80077f:	89 f0                	mov    %esi,%eax
  800781:	e8 70 fb ff ff       	call   8002f6 <printnum>
			break;
  800786:	83 c4 20             	add    $0x20,%esp
  800789:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80078c:	e9 ae fc ff ff       	jmp    80043f <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800791:	83 ec 08             	sub    $0x8,%esp
  800794:	53                   	push   %ebx
  800795:	51                   	push   %ecx
  800796:	ff d6                	call   *%esi
			break;
  800798:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80079e:	e9 9c fc ff ff       	jmp    80043f <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007a3:	83 ec 08             	sub    $0x8,%esp
  8007a6:	53                   	push   %ebx
  8007a7:	6a 25                	push   $0x25
  8007a9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007ab:	83 c4 10             	add    $0x10,%esp
  8007ae:	eb 03                	jmp    8007b3 <vprintfmt+0x39a>
  8007b0:	83 ef 01             	sub    $0x1,%edi
  8007b3:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007b7:	75 f7                	jne    8007b0 <vprintfmt+0x397>
  8007b9:	e9 81 fc ff ff       	jmp    80043f <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007c1:	5b                   	pop    %ebx
  8007c2:	5e                   	pop    %esi
  8007c3:	5f                   	pop    %edi
  8007c4:	5d                   	pop    %ebp
  8007c5:	c3                   	ret    

008007c6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	83 ec 18             	sub    $0x18,%esp
  8007cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cf:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007d5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007d9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007e3:	85 c0                	test   %eax,%eax
  8007e5:	74 26                	je     80080d <vsnprintf+0x47>
  8007e7:	85 d2                	test   %edx,%edx
  8007e9:	7e 22                	jle    80080d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007eb:	ff 75 14             	pushl  0x14(%ebp)
  8007ee:	ff 75 10             	pushl  0x10(%ebp)
  8007f1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007f4:	50                   	push   %eax
  8007f5:	68 df 03 80 00       	push   $0x8003df
  8007fa:	e8 1a fc ff ff       	call   800419 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800802:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800805:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800808:	83 c4 10             	add    $0x10,%esp
  80080b:	eb 05                	jmp    800812 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80080d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800812:	c9                   	leave  
  800813:	c3                   	ret    

00800814 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80081a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80081d:	50                   	push   %eax
  80081e:	ff 75 10             	pushl  0x10(%ebp)
  800821:	ff 75 0c             	pushl  0xc(%ebp)
  800824:	ff 75 08             	pushl  0x8(%ebp)
  800827:	e8 9a ff ff ff       	call   8007c6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80082c:	c9                   	leave  
  80082d:	c3                   	ret    

0080082e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800834:	b8 00 00 00 00       	mov    $0x0,%eax
  800839:	eb 03                	jmp    80083e <strlen+0x10>
		n++;
  80083b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80083e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800842:	75 f7                	jne    80083b <strlen+0xd>
		n++;
	return n;
}
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80084f:	ba 00 00 00 00       	mov    $0x0,%edx
  800854:	eb 03                	jmp    800859 <strnlen+0x13>
		n++;
  800856:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800859:	39 c2                	cmp    %eax,%edx
  80085b:	74 08                	je     800865 <strnlen+0x1f>
  80085d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800861:	75 f3                	jne    800856 <strnlen+0x10>
  800863:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	53                   	push   %ebx
  80086b:	8b 45 08             	mov    0x8(%ebp),%eax
  80086e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800871:	89 c2                	mov    %eax,%edx
  800873:	83 c2 01             	add    $0x1,%edx
  800876:	83 c1 01             	add    $0x1,%ecx
  800879:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80087d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800880:	84 db                	test   %bl,%bl
  800882:	75 ef                	jne    800873 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800884:	5b                   	pop    %ebx
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	53                   	push   %ebx
  80088b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80088e:	53                   	push   %ebx
  80088f:	e8 9a ff ff ff       	call   80082e <strlen>
  800894:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800897:	ff 75 0c             	pushl  0xc(%ebp)
  80089a:	01 d8                	add    %ebx,%eax
  80089c:	50                   	push   %eax
  80089d:	e8 c5 ff ff ff       	call   800867 <strcpy>
	return dst;
}
  8008a2:	89 d8                	mov    %ebx,%eax
  8008a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a7:	c9                   	leave  
  8008a8:	c3                   	ret    

008008a9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	56                   	push   %esi
  8008ad:	53                   	push   %ebx
  8008ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b4:	89 f3                	mov    %esi,%ebx
  8008b6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b9:	89 f2                	mov    %esi,%edx
  8008bb:	eb 0f                	jmp    8008cc <strncpy+0x23>
		*dst++ = *src;
  8008bd:	83 c2 01             	add    $0x1,%edx
  8008c0:	0f b6 01             	movzbl (%ecx),%eax
  8008c3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008c6:	80 39 01             	cmpb   $0x1,(%ecx)
  8008c9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008cc:	39 da                	cmp    %ebx,%edx
  8008ce:	75 ed                	jne    8008bd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008d0:	89 f0                	mov    %esi,%eax
  8008d2:	5b                   	pop    %ebx
  8008d3:	5e                   	pop    %esi
  8008d4:	5d                   	pop    %ebp
  8008d5:	c3                   	ret    

008008d6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	56                   	push   %esi
  8008da:	53                   	push   %ebx
  8008db:	8b 75 08             	mov    0x8(%ebp),%esi
  8008de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e1:	8b 55 10             	mov    0x10(%ebp),%edx
  8008e4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e6:	85 d2                	test   %edx,%edx
  8008e8:	74 21                	je     80090b <strlcpy+0x35>
  8008ea:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008ee:	89 f2                	mov    %esi,%edx
  8008f0:	eb 09                	jmp    8008fb <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008f2:	83 c2 01             	add    $0x1,%edx
  8008f5:	83 c1 01             	add    $0x1,%ecx
  8008f8:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008fb:	39 c2                	cmp    %eax,%edx
  8008fd:	74 09                	je     800908 <strlcpy+0x32>
  8008ff:	0f b6 19             	movzbl (%ecx),%ebx
  800902:	84 db                	test   %bl,%bl
  800904:	75 ec                	jne    8008f2 <strlcpy+0x1c>
  800906:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800908:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80090b:	29 f0                	sub    %esi,%eax
}
  80090d:	5b                   	pop    %ebx
  80090e:	5e                   	pop    %esi
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800917:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80091a:	eb 06                	jmp    800922 <strcmp+0x11>
		p++, q++;
  80091c:	83 c1 01             	add    $0x1,%ecx
  80091f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800922:	0f b6 01             	movzbl (%ecx),%eax
  800925:	84 c0                	test   %al,%al
  800927:	74 04                	je     80092d <strcmp+0x1c>
  800929:	3a 02                	cmp    (%edx),%al
  80092b:	74 ef                	je     80091c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80092d:	0f b6 c0             	movzbl %al,%eax
  800930:	0f b6 12             	movzbl (%edx),%edx
  800933:	29 d0                	sub    %edx,%eax
}
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	53                   	push   %ebx
  80093b:	8b 45 08             	mov    0x8(%ebp),%eax
  80093e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800941:	89 c3                	mov    %eax,%ebx
  800943:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800946:	eb 06                	jmp    80094e <strncmp+0x17>
		n--, p++, q++;
  800948:	83 c0 01             	add    $0x1,%eax
  80094b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80094e:	39 d8                	cmp    %ebx,%eax
  800950:	74 15                	je     800967 <strncmp+0x30>
  800952:	0f b6 08             	movzbl (%eax),%ecx
  800955:	84 c9                	test   %cl,%cl
  800957:	74 04                	je     80095d <strncmp+0x26>
  800959:	3a 0a                	cmp    (%edx),%cl
  80095b:	74 eb                	je     800948 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80095d:	0f b6 00             	movzbl (%eax),%eax
  800960:	0f b6 12             	movzbl (%edx),%edx
  800963:	29 d0                	sub    %edx,%eax
  800965:	eb 05                	jmp    80096c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800967:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80096c:	5b                   	pop    %ebx
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    

0080096f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
  800975:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800979:	eb 07                	jmp    800982 <strchr+0x13>
		if (*s == c)
  80097b:	38 ca                	cmp    %cl,%dl
  80097d:	74 0f                	je     80098e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80097f:	83 c0 01             	add    $0x1,%eax
  800982:	0f b6 10             	movzbl (%eax),%edx
  800985:	84 d2                	test   %dl,%dl
  800987:	75 f2                	jne    80097b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800989:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	8b 45 08             	mov    0x8(%ebp),%eax
  800996:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80099a:	eb 03                	jmp    80099f <strfind+0xf>
  80099c:	83 c0 01             	add    $0x1,%eax
  80099f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009a2:	38 ca                	cmp    %cl,%dl
  8009a4:	74 04                	je     8009aa <strfind+0x1a>
  8009a6:	84 d2                	test   %dl,%dl
  8009a8:	75 f2                	jne    80099c <strfind+0xc>
			break;
	return (char *) s;
}
  8009aa:	5d                   	pop    %ebp
  8009ab:	c3                   	ret    

008009ac <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	57                   	push   %edi
  8009b0:	56                   	push   %esi
  8009b1:	53                   	push   %ebx
  8009b2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009b8:	85 c9                	test   %ecx,%ecx
  8009ba:	74 36                	je     8009f2 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009bc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009c2:	75 28                	jne    8009ec <memset+0x40>
  8009c4:	f6 c1 03             	test   $0x3,%cl
  8009c7:	75 23                	jne    8009ec <memset+0x40>
		c &= 0xFF;
  8009c9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009cd:	89 d3                	mov    %edx,%ebx
  8009cf:	c1 e3 08             	shl    $0x8,%ebx
  8009d2:	89 d6                	mov    %edx,%esi
  8009d4:	c1 e6 18             	shl    $0x18,%esi
  8009d7:	89 d0                	mov    %edx,%eax
  8009d9:	c1 e0 10             	shl    $0x10,%eax
  8009dc:	09 f0                	or     %esi,%eax
  8009de:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009e0:	89 d8                	mov    %ebx,%eax
  8009e2:	09 d0                	or     %edx,%eax
  8009e4:	c1 e9 02             	shr    $0x2,%ecx
  8009e7:	fc                   	cld    
  8009e8:	f3 ab                	rep stos %eax,%es:(%edi)
  8009ea:	eb 06                	jmp    8009f2 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ef:	fc                   	cld    
  8009f0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009f2:	89 f8                	mov    %edi,%eax
  8009f4:	5b                   	pop    %ebx
  8009f5:	5e                   	pop    %esi
  8009f6:	5f                   	pop    %edi
  8009f7:	5d                   	pop    %ebp
  8009f8:	c3                   	ret    

008009f9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	57                   	push   %edi
  8009fd:	56                   	push   %esi
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a04:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a07:	39 c6                	cmp    %eax,%esi
  800a09:	73 35                	jae    800a40 <memmove+0x47>
  800a0b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a0e:	39 d0                	cmp    %edx,%eax
  800a10:	73 2e                	jae    800a40 <memmove+0x47>
		s += n;
		d += n;
  800a12:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a15:	89 d6                	mov    %edx,%esi
  800a17:	09 fe                	or     %edi,%esi
  800a19:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a1f:	75 13                	jne    800a34 <memmove+0x3b>
  800a21:	f6 c1 03             	test   $0x3,%cl
  800a24:	75 0e                	jne    800a34 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a26:	83 ef 04             	sub    $0x4,%edi
  800a29:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a2c:	c1 e9 02             	shr    $0x2,%ecx
  800a2f:	fd                   	std    
  800a30:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a32:	eb 09                	jmp    800a3d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a34:	83 ef 01             	sub    $0x1,%edi
  800a37:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a3a:	fd                   	std    
  800a3b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a3d:	fc                   	cld    
  800a3e:	eb 1d                	jmp    800a5d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a40:	89 f2                	mov    %esi,%edx
  800a42:	09 c2                	or     %eax,%edx
  800a44:	f6 c2 03             	test   $0x3,%dl
  800a47:	75 0f                	jne    800a58 <memmove+0x5f>
  800a49:	f6 c1 03             	test   $0x3,%cl
  800a4c:	75 0a                	jne    800a58 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a4e:	c1 e9 02             	shr    $0x2,%ecx
  800a51:	89 c7                	mov    %eax,%edi
  800a53:	fc                   	cld    
  800a54:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a56:	eb 05                	jmp    800a5d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a58:	89 c7                	mov    %eax,%edi
  800a5a:	fc                   	cld    
  800a5b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a5d:	5e                   	pop    %esi
  800a5e:	5f                   	pop    %edi
  800a5f:	5d                   	pop    %ebp
  800a60:	c3                   	ret    

00800a61 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a64:	ff 75 10             	pushl  0x10(%ebp)
  800a67:	ff 75 0c             	pushl  0xc(%ebp)
  800a6a:	ff 75 08             	pushl  0x8(%ebp)
  800a6d:	e8 87 ff ff ff       	call   8009f9 <memmove>
}
  800a72:	c9                   	leave  
  800a73:	c3                   	ret    

00800a74 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	56                   	push   %esi
  800a78:	53                   	push   %ebx
  800a79:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7f:	89 c6                	mov    %eax,%esi
  800a81:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a84:	eb 1a                	jmp    800aa0 <memcmp+0x2c>
		if (*s1 != *s2)
  800a86:	0f b6 08             	movzbl (%eax),%ecx
  800a89:	0f b6 1a             	movzbl (%edx),%ebx
  800a8c:	38 d9                	cmp    %bl,%cl
  800a8e:	74 0a                	je     800a9a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a90:	0f b6 c1             	movzbl %cl,%eax
  800a93:	0f b6 db             	movzbl %bl,%ebx
  800a96:	29 d8                	sub    %ebx,%eax
  800a98:	eb 0f                	jmp    800aa9 <memcmp+0x35>
		s1++, s2++;
  800a9a:	83 c0 01             	add    $0x1,%eax
  800a9d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa0:	39 f0                	cmp    %esi,%eax
  800aa2:	75 e2                	jne    800a86 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aa4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa9:	5b                   	pop    %ebx
  800aaa:	5e                   	pop    %esi
  800aab:	5d                   	pop    %ebp
  800aac:	c3                   	ret    

00800aad <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	53                   	push   %ebx
  800ab1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ab4:	89 c1                	mov    %eax,%ecx
  800ab6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ab9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800abd:	eb 0a                	jmp    800ac9 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800abf:	0f b6 10             	movzbl (%eax),%edx
  800ac2:	39 da                	cmp    %ebx,%edx
  800ac4:	74 07                	je     800acd <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ac6:	83 c0 01             	add    $0x1,%eax
  800ac9:	39 c8                	cmp    %ecx,%eax
  800acb:	72 f2                	jb     800abf <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800acd:	5b                   	pop    %ebx
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    

00800ad0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	57                   	push   %edi
  800ad4:	56                   	push   %esi
  800ad5:	53                   	push   %ebx
  800ad6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800adc:	eb 03                	jmp    800ae1 <strtol+0x11>
		s++;
  800ade:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ae1:	0f b6 01             	movzbl (%ecx),%eax
  800ae4:	3c 20                	cmp    $0x20,%al
  800ae6:	74 f6                	je     800ade <strtol+0xe>
  800ae8:	3c 09                	cmp    $0x9,%al
  800aea:	74 f2                	je     800ade <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aec:	3c 2b                	cmp    $0x2b,%al
  800aee:	75 0a                	jne    800afa <strtol+0x2a>
		s++;
  800af0:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800af3:	bf 00 00 00 00       	mov    $0x0,%edi
  800af8:	eb 11                	jmp    800b0b <strtol+0x3b>
  800afa:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aff:	3c 2d                	cmp    $0x2d,%al
  800b01:	75 08                	jne    800b0b <strtol+0x3b>
		s++, neg = 1;
  800b03:	83 c1 01             	add    $0x1,%ecx
  800b06:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b0b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b11:	75 15                	jne    800b28 <strtol+0x58>
  800b13:	80 39 30             	cmpb   $0x30,(%ecx)
  800b16:	75 10                	jne    800b28 <strtol+0x58>
  800b18:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b1c:	75 7c                	jne    800b9a <strtol+0xca>
		s += 2, base = 16;
  800b1e:	83 c1 02             	add    $0x2,%ecx
  800b21:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b26:	eb 16                	jmp    800b3e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b28:	85 db                	test   %ebx,%ebx
  800b2a:	75 12                	jne    800b3e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b2c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b31:	80 39 30             	cmpb   $0x30,(%ecx)
  800b34:	75 08                	jne    800b3e <strtol+0x6e>
		s++, base = 8;
  800b36:	83 c1 01             	add    $0x1,%ecx
  800b39:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b43:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b46:	0f b6 11             	movzbl (%ecx),%edx
  800b49:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b4c:	89 f3                	mov    %esi,%ebx
  800b4e:	80 fb 09             	cmp    $0x9,%bl
  800b51:	77 08                	ja     800b5b <strtol+0x8b>
			dig = *s - '0';
  800b53:	0f be d2             	movsbl %dl,%edx
  800b56:	83 ea 30             	sub    $0x30,%edx
  800b59:	eb 22                	jmp    800b7d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b5b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b5e:	89 f3                	mov    %esi,%ebx
  800b60:	80 fb 19             	cmp    $0x19,%bl
  800b63:	77 08                	ja     800b6d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b65:	0f be d2             	movsbl %dl,%edx
  800b68:	83 ea 57             	sub    $0x57,%edx
  800b6b:	eb 10                	jmp    800b7d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b6d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b70:	89 f3                	mov    %esi,%ebx
  800b72:	80 fb 19             	cmp    $0x19,%bl
  800b75:	77 16                	ja     800b8d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b77:	0f be d2             	movsbl %dl,%edx
  800b7a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b7d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b80:	7d 0b                	jge    800b8d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b82:	83 c1 01             	add    $0x1,%ecx
  800b85:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b89:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b8b:	eb b9                	jmp    800b46 <strtol+0x76>

	if (endptr)
  800b8d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b91:	74 0d                	je     800ba0 <strtol+0xd0>
		*endptr = (char *) s;
  800b93:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b96:	89 0e                	mov    %ecx,(%esi)
  800b98:	eb 06                	jmp    800ba0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b9a:	85 db                	test   %ebx,%ebx
  800b9c:	74 98                	je     800b36 <strtol+0x66>
  800b9e:	eb 9e                	jmp    800b3e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ba0:	89 c2                	mov    %eax,%edx
  800ba2:	f7 da                	neg    %edx
  800ba4:	85 ff                	test   %edi,%edi
  800ba6:	0f 45 c2             	cmovne %edx,%eax
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb4:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbf:	89 c3                	mov    %eax,%ebx
  800bc1:	89 c7                	mov    %eax,%edi
  800bc3:	89 c6                	mov    %eax,%esi
  800bc5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bc7:	5b                   	pop    %ebx
  800bc8:	5e                   	pop    %esi
  800bc9:	5f                   	pop    %edi
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    

00800bcc <sys_cgetc>:

int
sys_cgetc(void)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	57                   	push   %edi
  800bd0:	56                   	push   %esi
  800bd1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd7:	b8 01 00 00 00       	mov    $0x1,%eax
  800bdc:	89 d1                	mov    %edx,%ecx
  800bde:	89 d3                	mov    %edx,%ebx
  800be0:	89 d7                	mov    %edx,%edi
  800be2:	89 d6                	mov    %edx,%esi
  800be4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800be6:	5b                   	pop    %ebx
  800be7:	5e                   	pop    %esi
  800be8:	5f                   	pop    %edi
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
  800bf1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf9:	b8 03 00 00 00       	mov    $0x3,%eax
  800bfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800c01:	89 cb                	mov    %ecx,%ebx
  800c03:	89 cf                	mov    %ecx,%edi
  800c05:	89 ce                	mov    %ecx,%esi
  800c07:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c09:	85 c0                	test   %eax,%eax
  800c0b:	7e 17                	jle    800c24 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0d:	83 ec 0c             	sub    $0xc,%esp
  800c10:	50                   	push   %eax
  800c11:	6a 03                	push   $0x3
  800c13:	68 7f 27 80 00       	push   $0x80277f
  800c18:	6a 23                	push   $0x23
  800c1a:	68 9c 27 80 00       	push   $0x80279c
  800c1f:	e8 e5 f5 ff ff       	call   800209 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c27:	5b                   	pop    %ebx
  800c28:	5e                   	pop    %esi
  800c29:	5f                   	pop    %edi
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    

00800c2c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	57                   	push   %edi
  800c30:	56                   	push   %esi
  800c31:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c32:	ba 00 00 00 00       	mov    $0x0,%edx
  800c37:	b8 02 00 00 00       	mov    $0x2,%eax
  800c3c:	89 d1                	mov    %edx,%ecx
  800c3e:	89 d3                	mov    %edx,%ebx
  800c40:	89 d7                	mov    %edx,%edi
  800c42:	89 d6                	mov    %edx,%esi
  800c44:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c46:	5b                   	pop    %ebx
  800c47:	5e                   	pop    %esi
  800c48:	5f                   	pop    %edi
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <sys_yield>:

void
sys_yield(void)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	57                   	push   %edi
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c51:	ba 00 00 00 00       	mov    $0x0,%edx
  800c56:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c5b:	89 d1                	mov    %edx,%ecx
  800c5d:	89 d3                	mov    %edx,%ebx
  800c5f:	89 d7                	mov    %edx,%edi
  800c61:	89 d6                	mov    %edx,%esi
  800c63:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    

00800c6a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	57                   	push   %edi
  800c6e:	56                   	push   %esi
  800c6f:	53                   	push   %ebx
  800c70:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c73:	be 00 00 00 00       	mov    $0x0,%esi
  800c78:	b8 04 00 00 00       	mov    $0x4,%eax
  800c7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c80:	8b 55 08             	mov    0x8(%ebp),%edx
  800c83:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c86:	89 f7                	mov    %esi,%edi
  800c88:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8a:	85 c0                	test   %eax,%eax
  800c8c:	7e 17                	jle    800ca5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8e:	83 ec 0c             	sub    $0xc,%esp
  800c91:	50                   	push   %eax
  800c92:	6a 04                	push   $0x4
  800c94:	68 7f 27 80 00       	push   $0x80277f
  800c99:	6a 23                	push   $0x23
  800c9b:	68 9c 27 80 00       	push   $0x80279c
  800ca0:	e8 64 f5 ff ff       	call   800209 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ca5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    

00800cad <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	57                   	push   %edi
  800cb1:	56                   	push   %esi
  800cb2:	53                   	push   %ebx
  800cb3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb6:	b8 05 00 00 00       	mov    $0x5,%eax
  800cbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc7:	8b 75 18             	mov    0x18(%ebp),%esi
  800cca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ccc:	85 c0                	test   %eax,%eax
  800cce:	7e 17                	jle    800ce7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd0:	83 ec 0c             	sub    $0xc,%esp
  800cd3:	50                   	push   %eax
  800cd4:	6a 05                	push   $0x5
  800cd6:	68 7f 27 80 00       	push   $0x80277f
  800cdb:	6a 23                	push   $0x23
  800cdd:	68 9c 27 80 00       	push   $0x80279c
  800ce2:	e8 22 f5 ff ff       	call   800209 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ce7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5f                   	pop    %edi
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    

00800cef <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	57                   	push   %edi
  800cf3:	56                   	push   %esi
  800cf4:	53                   	push   %ebx
  800cf5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfd:	b8 06 00 00 00       	mov    $0x6,%eax
  800d02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d05:	8b 55 08             	mov    0x8(%ebp),%edx
  800d08:	89 df                	mov    %ebx,%edi
  800d0a:	89 de                	mov    %ebx,%esi
  800d0c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0e:	85 c0                	test   %eax,%eax
  800d10:	7e 17                	jle    800d29 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d12:	83 ec 0c             	sub    $0xc,%esp
  800d15:	50                   	push   %eax
  800d16:	6a 06                	push   $0x6
  800d18:	68 7f 27 80 00       	push   $0x80277f
  800d1d:	6a 23                	push   $0x23
  800d1f:	68 9c 27 80 00       	push   $0x80279c
  800d24:	e8 e0 f4 ff ff       	call   800209 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2c:	5b                   	pop    %ebx
  800d2d:	5e                   	pop    %esi
  800d2e:	5f                   	pop    %edi
  800d2f:	5d                   	pop    %ebp
  800d30:	c3                   	ret    

00800d31 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	57                   	push   %edi
  800d35:	56                   	push   %esi
  800d36:	53                   	push   %ebx
  800d37:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3f:	b8 08 00 00 00       	mov    $0x8,%eax
  800d44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d47:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4a:	89 df                	mov    %ebx,%edi
  800d4c:	89 de                	mov    %ebx,%esi
  800d4e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d50:	85 c0                	test   %eax,%eax
  800d52:	7e 17                	jle    800d6b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d54:	83 ec 0c             	sub    $0xc,%esp
  800d57:	50                   	push   %eax
  800d58:	6a 08                	push   $0x8
  800d5a:	68 7f 27 80 00       	push   $0x80277f
  800d5f:	6a 23                	push   $0x23
  800d61:	68 9c 27 80 00       	push   $0x80279c
  800d66:	e8 9e f4 ff ff       	call   800209 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6e:	5b                   	pop    %ebx
  800d6f:	5e                   	pop    %esi
  800d70:	5f                   	pop    %edi
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	57                   	push   %edi
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
  800d79:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d81:	b8 09 00 00 00       	mov    $0x9,%eax
  800d86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d89:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8c:	89 df                	mov    %ebx,%edi
  800d8e:	89 de                	mov    %ebx,%esi
  800d90:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d92:	85 c0                	test   %eax,%eax
  800d94:	7e 17                	jle    800dad <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d96:	83 ec 0c             	sub    $0xc,%esp
  800d99:	50                   	push   %eax
  800d9a:	6a 09                	push   $0x9
  800d9c:	68 7f 27 80 00       	push   $0x80277f
  800da1:	6a 23                	push   $0x23
  800da3:	68 9c 27 80 00       	push   $0x80279c
  800da8:	e8 5c f4 ff ff       	call   800209 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    

00800db5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	57                   	push   %edi
  800db9:	56                   	push   %esi
  800dba:	53                   	push   %ebx
  800dbb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dce:	89 df                	mov    %ebx,%edi
  800dd0:	89 de                	mov    %ebx,%esi
  800dd2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd4:	85 c0                	test   %eax,%eax
  800dd6:	7e 17                	jle    800def <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd8:	83 ec 0c             	sub    $0xc,%esp
  800ddb:	50                   	push   %eax
  800ddc:	6a 0a                	push   $0xa
  800dde:	68 7f 27 80 00       	push   $0x80277f
  800de3:	6a 23                	push   $0x23
  800de5:	68 9c 27 80 00       	push   $0x80279c
  800dea:	e8 1a f4 ff ff       	call   800209 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800def:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df2:	5b                   	pop    %ebx
  800df3:	5e                   	pop    %esi
  800df4:	5f                   	pop    %edi
  800df5:	5d                   	pop    %ebp
  800df6:	c3                   	ret    

00800df7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	57                   	push   %edi
  800dfb:	56                   	push   %esi
  800dfc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfd:	be 00 00 00 00       	mov    $0x0,%esi
  800e02:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e10:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e13:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e15:	5b                   	pop    %ebx
  800e16:	5e                   	pop    %esi
  800e17:	5f                   	pop    %edi
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    

00800e1a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e1a:	55                   	push   %ebp
  800e1b:	89 e5                	mov    %esp,%ebp
  800e1d:	57                   	push   %edi
  800e1e:	56                   	push   %esi
  800e1f:	53                   	push   %ebx
  800e20:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e23:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e28:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e30:	89 cb                	mov    %ecx,%ebx
  800e32:	89 cf                	mov    %ecx,%edi
  800e34:	89 ce                	mov    %ecx,%esi
  800e36:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e38:	85 c0                	test   %eax,%eax
  800e3a:	7e 17                	jle    800e53 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3c:	83 ec 0c             	sub    $0xc,%esp
  800e3f:	50                   	push   %eax
  800e40:	6a 0d                	push   $0xd
  800e42:	68 7f 27 80 00       	push   $0x80277f
  800e47:	6a 23                	push   $0x23
  800e49:	68 9c 27 80 00       	push   $0x80279c
  800e4e:	e8 b6 f3 ff ff       	call   800209 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e56:	5b                   	pop    %ebx
  800e57:	5e                   	pop    %esi
  800e58:	5f                   	pop    %edi
  800e59:	5d                   	pop    %ebp
  800e5a:	c3                   	ret    

00800e5b <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800e5b:	55                   	push   %ebp
  800e5c:	89 e5                	mov    %esp,%ebp
  800e5e:	57                   	push   %edi
  800e5f:	56                   	push   %esi
  800e60:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e61:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e66:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6e:	89 cb                	mov    %ecx,%ebx
  800e70:	89 cf                	mov    %ecx,%edi
  800e72:	89 ce                	mov    %ecx,%esi
  800e74:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800e76:	5b                   	pop    %ebx
  800e77:	5e                   	pop    %esi
  800e78:	5f                   	pop    %edi
  800e79:	5d                   	pop    %ebp
  800e7a:	c3                   	ret    

00800e7b <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800e7b:	55                   	push   %ebp
  800e7c:	89 e5                	mov    %esp,%ebp
  800e7e:	57                   	push   %edi
  800e7f:	56                   	push   %esi
  800e80:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e81:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e86:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8e:	89 cb                	mov    %ecx,%ebx
  800e90:	89 cf                	mov    %ecx,%edi
  800e92:	89 ce                	mov    %ecx,%esi
  800e94:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800e96:	5b                   	pop    %ebx
  800e97:	5e                   	pop    %esi
  800e98:	5f                   	pop    %edi
  800e99:	5d                   	pop    %ebp
  800e9a:	c3                   	ret    

00800e9b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	53                   	push   %ebx
  800e9f:	83 ec 04             	sub    $0x4,%esp
  800ea2:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ea5:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800ea7:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800eab:	74 11                	je     800ebe <pgfault+0x23>
  800ead:	89 d8                	mov    %ebx,%eax
  800eaf:	c1 e8 0c             	shr    $0xc,%eax
  800eb2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eb9:	f6 c4 08             	test   $0x8,%ah
  800ebc:	75 14                	jne    800ed2 <pgfault+0x37>
		panic("faulting access");
  800ebe:	83 ec 04             	sub    $0x4,%esp
  800ec1:	68 aa 27 80 00       	push   $0x8027aa
  800ec6:	6a 1e                	push   $0x1e
  800ec8:	68 ba 27 80 00       	push   $0x8027ba
  800ecd:	e8 37 f3 ff ff       	call   800209 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800ed2:	83 ec 04             	sub    $0x4,%esp
  800ed5:	6a 07                	push   $0x7
  800ed7:	68 00 f0 7f 00       	push   $0x7ff000
  800edc:	6a 00                	push   $0x0
  800ede:	e8 87 fd ff ff       	call   800c6a <sys_page_alloc>
	if (r < 0) {
  800ee3:	83 c4 10             	add    $0x10,%esp
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	79 12                	jns    800efc <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800eea:	50                   	push   %eax
  800eeb:	68 c5 27 80 00       	push   $0x8027c5
  800ef0:	6a 2c                	push   $0x2c
  800ef2:	68 ba 27 80 00       	push   $0x8027ba
  800ef7:	e8 0d f3 ff ff       	call   800209 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800efc:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800f02:	83 ec 04             	sub    $0x4,%esp
  800f05:	68 00 10 00 00       	push   $0x1000
  800f0a:	53                   	push   %ebx
  800f0b:	68 00 f0 7f 00       	push   $0x7ff000
  800f10:	e8 4c fb ff ff       	call   800a61 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800f15:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f1c:	53                   	push   %ebx
  800f1d:	6a 00                	push   $0x0
  800f1f:	68 00 f0 7f 00       	push   $0x7ff000
  800f24:	6a 00                	push   $0x0
  800f26:	e8 82 fd ff ff       	call   800cad <sys_page_map>
	if (r < 0) {
  800f2b:	83 c4 20             	add    $0x20,%esp
  800f2e:	85 c0                	test   %eax,%eax
  800f30:	79 12                	jns    800f44 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800f32:	50                   	push   %eax
  800f33:	68 c5 27 80 00       	push   $0x8027c5
  800f38:	6a 33                	push   $0x33
  800f3a:	68 ba 27 80 00       	push   $0x8027ba
  800f3f:	e8 c5 f2 ff ff       	call   800209 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800f44:	83 ec 08             	sub    $0x8,%esp
  800f47:	68 00 f0 7f 00       	push   $0x7ff000
  800f4c:	6a 00                	push   $0x0
  800f4e:	e8 9c fd ff ff       	call   800cef <sys_page_unmap>
	if (r < 0) {
  800f53:	83 c4 10             	add    $0x10,%esp
  800f56:	85 c0                	test   %eax,%eax
  800f58:	79 12                	jns    800f6c <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800f5a:	50                   	push   %eax
  800f5b:	68 c5 27 80 00       	push   $0x8027c5
  800f60:	6a 37                	push   $0x37
  800f62:	68 ba 27 80 00       	push   $0x8027ba
  800f67:	e8 9d f2 ff ff       	call   800209 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800f6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f6f:	c9                   	leave  
  800f70:	c3                   	ret    

00800f71 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	57                   	push   %edi
  800f75:	56                   	push   %esi
  800f76:	53                   	push   %ebx
  800f77:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800f7a:	68 9b 0e 80 00       	push   $0x800e9b
  800f7f:	e8 03 10 00 00       	call   801f87 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f84:	b8 07 00 00 00       	mov    $0x7,%eax
  800f89:	cd 30                	int    $0x30
  800f8b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800f8e:	83 c4 10             	add    $0x10,%esp
  800f91:	85 c0                	test   %eax,%eax
  800f93:	79 17                	jns    800fac <fork+0x3b>
		panic("fork fault %e");
  800f95:	83 ec 04             	sub    $0x4,%esp
  800f98:	68 de 27 80 00       	push   $0x8027de
  800f9d:	68 84 00 00 00       	push   $0x84
  800fa2:	68 ba 27 80 00       	push   $0x8027ba
  800fa7:	e8 5d f2 ff ff       	call   800209 <_panic>
  800fac:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800fae:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fb2:	75 25                	jne    800fd9 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fb4:	e8 73 fc ff ff       	call   800c2c <sys_getenvid>
  800fb9:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fbe:	89 c2                	mov    %eax,%edx
  800fc0:	c1 e2 07             	shl    $0x7,%edx
  800fc3:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800fca:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800fcf:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd4:	e9 61 01 00 00       	jmp    80113a <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800fd9:	83 ec 04             	sub    $0x4,%esp
  800fdc:	6a 07                	push   $0x7
  800fde:	68 00 f0 bf ee       	push   $0xeebff000
  800fe3:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fe6:	e8 7f fc ff ff       	call   800c6a <sys_page_alloc>
  800feb:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fee:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ff3:	89 d8                	mov    %ebx,%eax
  800ff5:	c1 e8 16             	shr    $0x16,%eax
  800ff8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fff:	a8 01                	test   $0x1,%al
  801001:	0f 84 fc 00 00 00    	je     801103 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  801007:	89 d8                	mov    %ebx,%eax
  801009:	c1 e8 0c             	shr    $0xc,%eax
  80100c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801013:	f6 c2 01             	test   $0x1,%dl
  801016:	0f 84 e7 00 00 00    	je     801103 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80101c:	89 c6                	mov    %eax,%esi
  80101e:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  801021:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801028:	f6 c6 04             	test   $0x4,%dh
  80102b:	74 39                	je     801066 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80102d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801034:	83 ec 0c             	sub    $0xc,%esp
  801037:	25 07 0e 00 00       	and    $0xe07,%eax
  80103c:	50                   	push   %eax
  80103d:	56                   	push   %esi
  80103e:	57                   	push   %edi
  80103f:	56                   	push   %esi
  801040:	6a 00                	push   $0x0
  801042:	e8 66 fc ff ff       	call   800cad <sys_page_map>
		if (r < 0) {
  801047:	83 c4 20             	add    $0x20,%esp
  80104a:	85 c0                	test   %eax,%eax
  80104c:	0f 89 b1 00 00 00    	jns    801103 <fork+0x192>
		    	panic("sys page map fault %e");
  801052:	83 ec 04             	sub    $0x4,%esp
  801055:	68 ec 27 80 00       	push   $0x8027ec
  80105a:	6a 54                	push   $0x54
  80105c:	68 ba 27 80 00       	push   $0x8027ba
  801061:	e8 a3 f1 ff ff       	call   800209 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801066:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80106d:	f6 c2 02             	test   $0x2,%dl
  801070:	75 0c                	jne    80107e <fork+0x10d>
  801072:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801079:	f6 c4 08             	test   $0x8,%ah
  80107c:	74 5b                	je     8010d9 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80107e:	83 ec 0c             	sub    $0xc,%esp
  801081:	68 05 08 00 00       	push   $0x805
  801086:	56                   	push   %esi
  801087:	57                   	push   %edi
  801088:	56                   	push   %esi
  801089:	6a 00                	push   $0x0
  80108b:	e8 1d fc ff ff       	call   800cad <sys_page_map>
		if (r < 0) {
  801090:	83 c4 20             	add    $0x20,%esp
  801093:	85 c0                	test   %eax,%eax
  801095:	79 14                	jns    8010ab <fork+0x13a>
		    	panic("sys page map fault %e");
  801097:	83 ec 04             	sub    $0x4,%esp
  80109a:	68 ec 27 80 00       	push   $0x8027ec
  80109f:	6a 5b                	push   $0x5b
  8010a1:	68 ba 27 80 00       	push   $0x8027ba
  8010a6:	e8 5e f1 ff ff       	call   800209 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8010ab:	83 ec 0c             	sub    $0xc,%esp
  8010ae:	68 05 08 00 00       	push   $0x805
  8010b3:	56                   	push   %esi
  8010b4:	6a 00                	push   $0x0
  8010b6:	56                   	push   %esi
  8010b7:	6a 00                	push   $0x0
  8010b9:	e8 ef fb ff ff       	call   800cad <sys_page_map>
		if (r < 0) {
  8010be:	83 c4 20             	add    $0x20,%esp
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	79 3e                	jns    801103 <fork+0x192>
		    	panic("sys page map fault %e");
  8010c5:	83 ec 04             	sub    $0x4,%esp
  8010c8:	68 ec 27 80 00       	push   $0x8027ec
  8010cd:	6a 5f                	push   $0x5f
  8010cf:	68 ba 27 80 00       	push   $0x8027ba
  8010d4:	e8 30 f1 ff ff       	call   800209 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8010d9:	83 ec 0c             	sub    $0xc,%esp
  8010dc:	6a 05                	push   $0x5
  8010de:	56                   	push   %esi
  8010df:	57                   	push   %edi
  8010e0:	56                   	push   %esi
  8010e1:	6a 00                	push   $0x0
  8010e3:	e8 c5 fb ff ff       	call   800cad <sys_page_map>
		if (r < 0) {
  8010e8:	83 c4 20             	add    $0x20,%esp
  8010eb:	85 c0                	test   %eax,%eax
  8010ed:	79 14                	jns    801103 <fork+0x192>
		    	panic("sys page map fault %e");
  8010ef:	83 ec 04             	sub    $0x4,%esp
  8010f2:	68 ec 27 80 00       	push   $0x8027ec
  8010f7:	6a 64                	push   $0x64
  8010f9:	68 ba 27 80 00       	push   $0x8027ba
  8010fe:	e8 06 f1 ff ff       	call   800209 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801103:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801109:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80110f:	0f 85 de fe ff ff    	jne    800ff3 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801115:	a1 08 40 80 00       	mov    0x804008,%eax
  80111a:	8b 40 70             	mov    0x70(%eax),%eax
  80111d:	83 ec 08             	sub    $0x8,%esp
  801120:	50                   	push   %eax
  801121:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801124:	57                   	push   %edi
  801125:	e8 8b fc ff ff       	call   800db5 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80112a:	83 c4 08             	add    $0x8,%esp
  80112d:	6a 02                	push   $0x2
  80112f:	57                   	push   %edi
  801130:	e8 fc fb ff ff       	call   800d31 <sys_env_set_status>
	
	return envid;
  801135:	83 c4 10             	add    $0x10,%esp
  801138:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80113a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113d:	5b                   	pop    %ebx
  80113e:	5e                   	pop    %esi
  80113f:	5f                   	pop    %edi
  801140:	5d                   	pop    %ebp
  801141:	c3                   	ret    

00801142 <sfork>:

envid_t
sfork(void)
{
  801142:	55                   	push   %ebp
  801143:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801145:	b8 00 00 00 00       	mov    $0x0,%eax
  80114a:	5d                   	pop    %ebp
  80114b:	c3                   	ret    

0080114c <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80114c:	55                   	push   %ebp
  80114d:	89 e5                	mov    %esp,%ebp
  80114f:	56                   	push   %esi
  801150:	53                   	push   %ebx
  801151:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801154:	89 1d 0c 40 80 00    	mov    %ebx,0x80400c
	cprintf("in fork.c thread create. func: %x\n", func);
  80115a:	83 ec 08             	sub    $0x8,%esp
  80115d:	53                   	push   %ebx
  80115e:	68 04 28 80 00       	push   $0x802804
  801163:	e8 7a f1 ff ff       	call   8002e2 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801168:	c7 04 24 cf 01 80 00 	movl   $0x8001cf,(%esp)
  80116f:	e8 e7 fc ff ff       	call   800e5b <sys_thread_create>
  801174:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801176:	83 c4 08             	add    $0x8,%esp
  801179:	53                   	push   %ebx
  80117a:	68 04 28 80 00       	push   $0x802804
  80117f:	e8 5e f1 ff ff       	call   8002e2 <cprintf>
	return id;
	//return 0;
}
  801184:	89 f0                	mov    %esi,%eax
  801186:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801189:	5b                   	pop    %ebx
  80118a:	5e                   	pop    %esi
  80118b:	5d                   	pop    %ebp
  80118c:	c3                   	ret    

0080118d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80118d:	55                   	push   %ebp
  80118e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801190:	8b 45 08             	mov    0x8(%ebp),%eax
  801193:	05 00 00 00 30       	add    $0x30000000,%eax
  801198:	c1 e8 0c             	shr    $0xc,%eax
}
  80119b:	5d                   	pop    %ebp
  80119c:	c3                   	ret    

0080119d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a3:	05 00 00 00 30       	add    $0x30000000,%eax
  8011a8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011ad:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011b2:	5d                   	pop    %ebp
  8011b3:	c3                   	ret    

008011b4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
  8011b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ba:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011bf:	89 c2                	mov    %eax,%edx
  8011c1:	c1 ea 16             	shr    $0x16,%edx
  8011c4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011cb:	f6 c2 01             	test   $0x1,%dl
  8011ce:	74 11                	je     8011e1 <fd_alloc+0x2d>
  8011d0:	89 c2                	mov    %eax,%edx
  8011d2:	c1 ea 0c             	shr    $0xc,%edx
  8011d5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011dc:	f6 c2 01             	test   $0x1,%dl
  8011df:	75 09                	jne    8011ea <fd_alloc+0x36>
			*fd_store = fd;
  8011e1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e8:	eb 17                	jmp    801201 <fd_alloc+0x4d>
  8011ea:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011ef:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011f4:	75 c9                	jne    8011bf <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011f6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011fc:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801201:	5d                   	pop    %ebp
  801202:	c3                   	ret    

00801203 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801203:	55                   	push   %ebp
  801204:	89 e5                	mov    %esp,%ebp
  801206:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801209:	83 f8 1f             	cmp    $0x1f,%eax
  80120c:	77 36                	ja     801244 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80120e:	c1 e0 0c             	shl    $0xc,%eax
  801211:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801216:	89 c2                	mov    %eax,%edx
  801218:	c1 ea 16             	shr    $0x16,%edx
  80121b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801222:	f6 c2 01             	test   $0x1,%dl
  801225:	74 24                	je     80124b <fd_lookup+0x48>
  801227:	89 c2                	mov    %eax,%edx
  801229:	c1 ea 0c             	shr    $0xc,%edx
  80122c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801233:	f6 c2 01             	test   $0x1,%dl
  801236:	74 1a                	je     801252 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801238:	8b 55 0c             	mov    0xc(%ebp),%edx
  80123b:	89 02                	mov    %eax,(%edx)
	return 0;
  80123d:	b8 00 00 00 00       	mov    $0x0,%eax
  801242:	eb 13                	jmp    801257 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801244:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801249:	eb 0c                	jmp    801257 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80124b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801250:	eb 05                	jmp    801257 <fd_lookup+0x54>
  801252:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801257:	5d                   	pop    %ebp
  801258:	c3                   	ret    

00801259 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801259:	55                   	push   %ebp
  80125a:	89 e5                	mov    %esp,%ebp
  80125c:	83 ec 08             	sub    $0x8,%esp
  80125f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801262:	ba a8 28 80 00       	mov    $0x8028a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801267:	eb 13                	jmp    80127c <dev_lookup+0x23>
  801269:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80126c:	39 08                	cmp    %ecx,(%eax)
  80126e:	75 0c                	jne    80127c <dev_lookup+0x23>
			*dev = devtab[i];
  801270:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801273:	89 01                	mov    %eax,(%ecx)
			return 0;
  801275:	b8 00 00 00 00       	mov    $0x0,%eax
  80127a:	eb 2e                	jmp    8012aa <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80127c:	8b 02                	mov    (%edx),%eax
  80127e:	85 c0                	test   %eax,%eax
  801280:	75 e7                	jne    801269 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801282:	a1 08 40 80 00       	mov    0x804008,%eax
  801287:	8b 40 54             	mov    0x54(%eax),%eax
  80128a:	83 ec 04             	sub    $0x4,%esp
  80128d:	51                   	push   %ecx
  80128e:	50                   	push   %eax
  80128f:	68 28 28 80 00       	push   $0x802828
  801294:	e8 49 f0 ff ff       	call   8002e2 <cprintf>
	*dev = 0;
  801299:	8b 45 0c             	mov    0xc(%ebp),%eax
  80129c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012a2:	83 c4 10             	add    $0x10,%esp
  8012a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012aa:	c9                   	leave  
  8012ab:	c3                   	ret    

008012ac <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012ac:	55                   	push   %ebp
  8012ad:	89 e5                	mov    %esp,%ebp
  8012af:	56                   	push   %esi
  8012b0:	53                   	push   %ebx
  8012b1:	83 ec 10             	sub    $0x10,%esp
  8012b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8012b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012bd:	50                   	push   %eax
  8012be:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012c4:	c1 e8 0c             	shr    $0xc,%eax
  8012c7:	50                   	push   %eax
  8012c8:	e8 36 ff ff ff       	call   801203 <fd_lookup>
  8012cd:	83 c4 08             	add    $0x8,%esp
  8012d0:	85 c0                	test   %eax,%eax
  8012d2:	78 05                	js     8012d9 <fd_close+0x2d>
	    || fd != fd2)
  8012d4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012d7:	74 0c                	je     8012e5 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012d9:	84 db                	test   %bl,%bl
  8012db:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e0:	0f 44 c2             	cmove  %edx,%eax
  8012e3:	eb 41                	jmp    801326 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012e5:	83 ec 08             	sub    $0x8,%esp
  8012e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012eb:	50                   	push   %eax
  8012ec:	ff 36                	pushl  (%esi)
  8012ee:	e8 66 ff ff ff       	call   801259 <dev_lookup>
  8012f3:	89 c3                	mov    %eax,%ebx
  8012f5:	83 c4 10             	add    $0x10,%esp
  8012f8:	85 c0                	test   %eax,%eax
  8012fa:	78 1a                	js     801316 <fd_close+0x6a>
		if (dev->dev_close)
  8012fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ff:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801302:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801307:	85 c0                	test   %eax,%eax
  801309:	74 0b                	je     801316 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80130b:	83 ec 0c             	sub    $0xc,%esp
  80130e:	56                   	push   %esi
  80130f:	ff d0                	call   *%eax
  801311:	89 c3                	mov    %eax,%ebx
  801313:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801316:	83 ec 08             	sub    $0x8,%esp
  801319:	56                   	push   %esi
  80131a:	6a 00                	push   $0x0
  80131c:	e8 ce f9 ff ff       	call   800cef <sys_page_unmap>
	return r;
  801321:	83 c4 10             	add    $0x10,%esp
  801324:	89 d8                	mov    %ebx,%eax
}
  801326:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801329:	5b                   	pop    %ebx
  80132a:	5e                   	pop    %esi
  80132b:	5d                   	pop    %ebp
  80132c:	c3                   	ret    

0080132d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80132d:	55                   	push   %ebp
  80132e:	89 e5                	mov    %esp,%ebp
  801330:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801333:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801336:	50                   	push   %eax
  801337:	ff 75 08             	pushl  0x8(%ebp)
  80133a:	e8 c4 fe ff ff       	call   801203 <fd_lookup>
  80133f:	83 c4 08             	add    $0x8,%esp
  801342:	85 c0                	test   %eax,%eax
  801344:	78 10                	js     801356 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801346:	83 ec 08             	sub    $0x8,%esp
  801349:	6a 01                	push   $0x1
  80134b:	ff 75 f4             	pushl  -0xc(%ebp)
  80134e:	e8 59 ff ff ff       	call   8012ac <fd_close>
  801353:	83 c4 10             	add    $0x10,%esp
}
  801356:	c9                   	leave  
  801357:	c3                   	ret    

00801358 <close_all>:

void
close_all(void)
{
  801358:	55                   	push   %ebp
  801359:	89 e5                	mov    %esp,%ebp
  80135b:	53                   	push   %ebx
  80135c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80135f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801364:	83 ec 0c             	sub    $0xc,%esp
  801367:	53                   	push   %ebx
  801368:	e8 c0 ff ff ff       	call   80132d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80136d:	83 c3 01             	add    $0x1,%ebx
  801370:	83 c4 10             	add    $0x10,%esp
  801373:	83 fb 20             	cmp    $0x20,%ebx
  801376:	75 ec                	jne    801364 <close_all+0xc>
		close(i);
}
  801378:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137b:	c9                   	leave  
  80137c:	c3                   	ret    

0080137d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80137d:	55                   	push   %ebp
  80137e:	89 e5                	mov    %esp,%ebp
  801380:	57                   	push   %edi
  801381:	56                   	push   %esi
  801382:	53                   	push   %ebx
  801383:	83 ec 2c             	sub    $0x2c,%esp
  801386:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801389:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80138c:	50                   	push   %eax
  80138d:	ff 75 08             	pushl  0x8(%ebp)
  801390:	e8 6e fe ff ff       	call   801203 <fd_lookup>
  801395:	83 c4 08             	add    $0x8,%esp
  801398:	85 c0                	test   %eax,%eax
  80139a:	0f 88 c1 00 00 00    	js     801461 <dup+0xe4>
		return r;
	close(newfdnum);
  8013a0:	83 ec 0c             	sub    $0xc,%esp
  8013a3:	56                   	push   %esi
  8013a4:	e8 84 ff ff ff       	call   80132d <close>

	newfd = INDEX2FD(newfdnum);
  8013a9:	89 f3                	mov    %esi,%ebx
  8013ab:	c1 e3 0c             	shl    $0xc,%ebx
  8013ae:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013b4:	83 c4 04             	add    $0x4,%esp
  8013b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013ba:	e8 de fd ff ff       	call   80119d <fd2data>
  8013bf:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013c1:	89 1c 24             	mov    %ebx,(%esp)
  8013c4:	e8 d4 fd ff ff       	call   80119d <fd2data>
  8013c9:	83 c4 10             	add    $0x10,%esp
  8013cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013cf:	89 f8                	mov    %edi,%eax
  8013d1:	c1 e8 16             	shr    $0x16,%eax
  8013d4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013db:	a8 01                	test   $0x1,%al
  8013dd:	74 37                	je     801416 <dup+0x99>
  8013df:	89 f8                	mov    %edi,%eax
  8013e1:	c1 e8 0c             	shr    $0xc,%eax
  8013e4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013eb:	f6 c2 01             	test   $0x1,%dl
  8013ee:	74 26                	je     801416 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013f0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013f7:	83 ec 0c             	sub    $0xc,%esp
  8013fa:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ff:	50                   	push   %eax
  801400:	ff 75 d4             	pushl  -0x2c(%ebp)
  801403:	6a 00                	push   $0x0
  801405:	57                   	push   %edi
  801406:	6a 00                	push   $0x0
  801408:	e8 a0 f8 ff ff       	call   800cad <sys_page_map>
  80140d:	89 c7                	mov    %eax,%edi
  80140f:	83 c4 20             	add    $0x20,%esp
  801412:	85 c0                	test   %eax,%eax
  801414:	78 2e                	js     801444 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801416:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801419:	89 d0                	mov    %edx,%eax
  80141b:	c1 e8 0c             	shr    $0xc,%eax
  80141e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801425:	83 ec 0c             	sub    $0xc,%esp
  801428:	25 07 0e 00 00       	and    $0xe07,%eax
  80142d:	50                   	push   %eax
  80142e:	53                   	push   %ebx
  80142f:	6a 00                	push   $0x0
  801431:	52                   	push   %edx
  801432:	6a 00                	push   $0x0
  801434:	e8 74 f8 ff ff       	call   800cad <sys_page_map>
  801439:	89 c7                	mov    %eax,%edi
  80143b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80143e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801440:	85 ff                	test   %edi,%edi
  801442:	79 1d                	jns    801461 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801444:	83 ec 08             	sub    $0x8,%esp
  801447:	53                   	push   %ebx
  801448:	6a 00                	push   $0x0
  80144a:	e8 a0 f8 ff ff       	call   800cef <sys_page_unmap>
	sys_page_unmap(0, nva);
  80144f:	83 c4 08             	add    $0x8,%esp
  801452:	ff 75 d4             	pushl  -0x2c(%ebp)
  801455:	6a 00                	push   $0x0
  801457:	e8 93 f8 ff ff       	call   800cef <sys_page_unmap>
	return r;
  80145c:	83 c4 10             	add    $0x10,%esp
  80145f:	89 f8                	mov    %edi,%eax
}
  801461:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801464:	5b                   	pop    %ebx
  801465:	5e                   	pop    %esi
  801466:	5f                   	pop    %edi
  801467:	5d                   	pop    %ebp
  801468:	c3                   	ret    

00801469 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801469:	55                   	push   %ebp
  80146a:	89 e5                	mov    %esp,%ebp
  80146c:	53                   	push   %ebx
  80146d:	83 ec 14             	sub    $0x14,%esp
  801470:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801473:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801476:	50                   	push   %eax
  801477:	53                   	push   %ebx
  801478:	e8 86 fd ff ff       	call   801203 <fd_lookup>
  80147d:	83 c4 08             	add    $0x8,%esp
  801480:	89 c2                	mov    %eax,%edx
  801482:	85 c0                	test   %eax,%eax
  801484:	78 6d                	js     8014f3 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801486:	83 ec 08             	sub    $0x8,%esp
  801489:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148c:	50                   	push   %eax
  80148d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801490:	ff 30                	pushl  (%eax)
  801492:	e8 c2 fd ff ff       	call   801259 <dev_lookup>
  801497:	83 c4 10             	add    $0x10,%esp
  80149a:	85 c0                	test   %eax,%eax
  80149c:	78 4c                	js     8014ea <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80149e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014a1:	8b 42 08             	mov    0x8(%edx),%eax
  8014a4:	83 e0 03             	and    $0x3,%eax
  8014a7:	83 f8 01             	cmp    $0x1,%eax
  8014aa:	75 21                	jne    8014cd <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ac:	a1 08 40 80 00       	mov    0x804008,%eax
  8014b1:	8b 40 54             	mov    0x54(%eax),%eax
  8014b4:	83 ec 04             	sub    $0x4,%esp
  8014b7:	53                   	push   %ebx
  8014b8:	50                   	push   %eax
  8014b9:	68 6c 28 80 00       	push   $0x80286c
  8014be:	e8 1f ee ff ff       	call   8002e2 <cprintf>
		return -E_INVAL;
  8014c3:	83 c4 10             	add    $0x10,%esp
  8014c6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014cb:	eb 26                	jmp    8014f3 <read+0x8a>
	}
	if (!dev->dev_read)
  8014cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d0:	8b 40 08             	mov    0x8(%eax),%eax
  8014d3:	85 c0                	test   %eax,%eax
  8014d5:	74 17                	je     8014ee <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8014d7:	83 ec 04             	sub    $0x4,%esp
  8014da:	ff 75 10             	pushl  0x10(%ebp)
  8014dd:	ff 75 0c             	pushl  0xc(%ebp)
  8014e0:	52                   	push   %edx
  8014e1:	ff d0                	call   *%eax
  8014e3:	89 c2                	mov    %eax,%edx
  8014e5:	83 c4 10             	add    $0x10,%esp
  8014e8:	eb 09                	jmp    8014f3 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ea:	89 c2                	mov    %eax,%edx
  8014ec:	eb 05                	jmp    8014f3 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014ee:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8014f3:	89 d0                	mov    %edx,%eax
  8014f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f8:	c9                   	leave  
  8014f9:	c3                   	ret    

008014fa <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014fa:	55                   	push   %ebp
  8014fb:	89 e5                	mov    %esp,%ebp
  8014fd:	57                   	push   %edi
  8014fe:	56                   	push   %esi
  8014ff:	53                   	push   %ebx
  801500:	83 ec 0c             	sub    $0xc,%esp
  801503:	8b 7d 08             	mov    0x8(%ebp),%edi
  801506:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801509:	bb 00 00 00 00       	mov    $0x0,%ebx
  80150e:	eb 21                	jmp    801531 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801510:	83 ec 04             	sub    $0x4,%esp
  801513:	89 f0                	mov    %esi,%eax
  801515:	29 d8                	sub    %ebx,%eax
  801517:	50                   	push   %eax
  801518:	89 d8                	mov    %ebx,%eax
  80151a:	03 45 0c             	add    0xc(%ebp),%eax
  80151d:	50                   	push   %eax
  80151e:	57                   	push   %edi
  80151f:	e8 45 ff ff ff       	call   801469 <read>
		if (m < 0)
  801524:	83 c4 10             	add    $0x10,%esp
  801527:	85 c0                	test   %eax,%eax
  801529:	78 10                	js     80153b <readn+0x41>
			return m;
		if (m == 0)
  80152b:	85 c0                	test   %eax,%eax
  80152d:	74 0a                	je     801539 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80152f:	01 c3                	add    %eax,%ebx
  801531:	39 f3                	cmp    %esi,%ebx
  801533:	72 db                	jb     801510 <readn+0x16>
  801535:	89 d8                	mov    %ebx,%eax
  801537:	eb 02                	jmp    80153b <readn+0x41>
  801539:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80153b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80153e:	5b                   	pop    %ebx
  80153f:	5e                   	pop    %esi
  801540:	5f                   	pop    %edi
  801541:	5d                   	pop    %ebp
  801542:	c3                   	ret    

00801543 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801543:	55                   	push   %ebp
  801544:	89 e5                	mov    %esp,%ebp
  801546:	53                   	push   %ebx
  801547:	83 ec 14             	sub    $0x14,%esp
  80154a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80154d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801550:	50                   	push   %eax
  801551:	53                   	push   %ebx
  801552:	e8 ac fc ff ff       	call   801203 <fd_lookup>
  801557:	83 c4 08             	add    $0x8,%esp
  80155a:	89 c2                	mov    %eax,%edx
  80155c:	85 c0                	test   %eax,%eax
  80155e:	78 68                	js     8015c8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801560:	83 ec 08             	sub    $0x8,%esp
  801563:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801566:	50                   	push   %eax
  801567:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156a:	ff 30                	pushl  (%eax)
  80156c:	e8 e8 fc ff ff       	call   801259 <dev_lookup>
  801571:	83 c4 10             	add    $0x10,%esp
  801574:	85 c0                	test   %eax,%eax
  801576:	78 47                	js     8015bf <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801578:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80157f:	75 21                	jne    8015a2 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801581:	a1 08 40 80 00       	mov    0x804008,%eax
  801586:	8b 40 54             	mov    0x54(%eax),%eax
  801589:	83 ec 04             	sub    $0x4,%esp
  80158c:	53                   	push   %ebx
  80158d:	50                   	push   %eax
  80158e:	68 88 28 80 00       	push   $0x802888
  801593:	e8 4a ed ff ff       	call   8002e2 <cprintf>
		return -E_INVAL;
  801598:	83 c4 10             	add    $0x10,%esp
  80159b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015a0:	eb 26                	jmp    8015c8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a5:	8b 52 0c             	mov    0xc(%edx),%edx
  8015a8:	85 d2                	test   %edx,%edx
  8015aa:	74 17                	je     8015c3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015ac:	83 ec 04             	sub    $0x4,%esp
  8015af:	ff 75 10             	pushl  0x10(%ebp)
  8015b2:	ff 75 0c             	pushl  0xc(%ebp)
  8015b5:	50                   	push   %eax
  8015b6:	ff d2                	call   *%edx
  8015b8:	89 c2                	mov    %eax,%edx
  8015ba:	83 c4 10             	add    $0x10,%esp
  8015bd:	eb 09                	jmp    8015c8 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015bf:	89 c2                	mov    %eax,%edx
  8015c1:	eb 05                	jmp    8015c8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015c3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015c8:	89 d0                	mov    %edx,%eax
  8015ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015cd:	c9                   	leave  
  8015ce:	c3                   	ret    

008015cf <seek>:

int
seek(int fdnum, off_t offset)
{
  8015cf:	55                   	push   %ebp
  8015d0:	89 e5                	mov    %esp,%ebp
  8015d2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015d5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015d8:	50                   	push   %eax
  8015d9:	ff 75 08             	pushl  0x8(%ebp)
  8015dc:	e8 22 fc ff ff       	call   801203 <fd_lookup>
  8015e1:	83 c4 08             	add    $0x8,%esp
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	78 0e                	js     8015f6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015ee:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015f6:	c9                   	leave  
  8015f7:	c3                   	ret    

008015f8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015f8:	55                   	push   %ebp
  8015f9:	89 e5                	mov    %esp,%ebp
  8015fb:	53                   	push   %ebx
  8015fc:	83 ec 14             	sub    $0x14,%esp
  8015ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801602:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801605:	50                   	push   %eax
  801606:	53                   	push   %ebx
  801607:	e8 f7 fb ff ff       	call   801203 <fd_lookup>
  80160c:	83 c4 08             	add    $0x8,%esp
  80160f:	89 c2                	mov    %eax,%edx
  801611:	85 c0                	test   %eax,%eax
  801613:	78 65                	js     80167a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801615:	83 ec 08             	sub    $0x8,%esp
  801618:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161b:	50                   	push   %eax
  80161c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161f:	ff 30                	pushl  (%eax)
  801621:	e8 33 fc ff ff       	call   801259 <dev_lookup>
  801626:	83 c4 10             	add    $0x10,%esp
  801629:	85 c0                	test   %eax,%eax
  80162b:	78 44                	js     801671 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80162d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801630:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801634:	75 21                	jne    801657 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801636:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80163b:	8b 40 54             	mov    0x54(%eax),%eax
  80163e:	83 ec 04             	sub    $0x4,%esp
  801641:	53                   	push   %ebx
  801642:	50                   	push   %eax
  801643:	68 48 28 80 00       	push   $0x802848
  801648:	e8 95 ec ff ff       	call   8002e2 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80164d:	83 c4 10             	add    $0x10,%esp
  801650:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801655:	eb 23                	jmp    80167a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801657:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80165a:	8b 52 18             	mov    0x18(%edx),%edx
  80165d:	85 d2                	test   %edx,%edx
  80165f:	74 14                	je     801675 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801661:	83 ec 08             	sub    $0x8,%esp
  801664:	ff 75 0c             	pushl  0xc(%ebp)
  801667:	50                   	push   %eax
  801668:	ff d2                	call   *%edx
  80166a:	89 c2                	mov    %eax,%edx
  80166c:	83 c4 10             	add    $0x10,%esp
  80166f:	eb 09                	jmp    80167a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801671:	89 c2                	mov    %eax,%edx
  801673:	eb 05                	jmp    80167a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801675:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80167a:	89 d0                	mov    %edx,%eax
  80167c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167f:	c9                   	leave  
  801680:	c3                   	ret    

00801681 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
  801684:	53                   	push   %ebx
  801685:	83 ec 14             	sub    $0x14,%esp
  801688:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80168e:	50                   	push   %eax
  80168f:	ff 75 08             	pushl  0x8(%ebp)
  801692:	e8 6c fb ff ff       	call   801203 <fd_lookup>
  801697:	83 c4 08             	add    $0x8,%esp
  80169a:	89 c2                	mov    %eax,%edx
  80169c:	85 c0                	test   %eax,%eax
  80169e:	78 58                	js     8016f8 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a0:	83 ec 08             	sub    $0x8,%esp
  8016a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a6:	50                   	push   %eax
  8016a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016aa:	ff 30                	pushl  (%eax)
  8016ac:	e8 a8 fb ff ff       	call   801259 <dev_lookup>
  8016b1:	83 c4 10             	add    $0x10,%esp
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	78 37                	js     8016ef <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016bb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016bf:	74 32                	je     8016f3 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016c1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016c4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016cb:	00 00 00 
	stat->st_isdir = 0;
  8016ce:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016d5:	00 00 00 
	stat->st_dev = dev;
  8016d8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016de:	83 ec 08             	sub    $0x8,%esp
  8016e1:	53                   	push   %ebx
  8016e2:	ff 75 f0             	pushl  -0x10(%ebp)
  8016e5:	ff 50 14             	call   *0x14(%eax)
  8016e8:	89 c2                	mov    %eax,%edx
  8016ea:	83 c4 10             	add    $0x10,%esp
  8016ed:	eb 09                	jmp    8016f8 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ef:	89 c2                	mov    %eax,%edx
  8016f1:	eb 05                	jmp    8016f8 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016f3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016f8:	89 d0                	mov    %edx,%eax
  8016fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016fd:	c9                   	leave  
  8016fe:	c3                   	ret    

008016ff <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016ff:	55                   	push   %ebp
  801700:	89 e5                	mov    %esp,%ebp
  801702:	56                   	push   %esi
  801703:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801704:	83 ec 08             	sub    $0x8,%esp
  801707:	6a 00                	push   $0x0
  801709:	ff 75 08             	pushl  0x8(%ebp)
  80170c:	e8 e3 01 00 00       	call   8018f4 <open>
  801711:	89 c3                	mov    %eax,%ebx
  801713:	83 c4 10             	add    $0x10,%esp
  801716:	85 c0                	test   %eax,%eax
  801718:	78 1b                	js     801735 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80171a:	83 ec 08             	sub    $0x8,%esp
  80171d:	ff 75 0c             	pushl  0xc(%ebp)
  801720:	50                   	push   %eax
  801721:	e8 5b ff ff ff       	call   801681 <fstat>
  801726:	89 c6                	mov    %eax,%esi
	close(fd);
  801728:	89 1c 24             	mov    %ebx,(%esp)
  80172b:	e8 fd fb ff ff       	call   80132d <close>
	return r;
  801730:	83 c4 10             	add    $0x10,%esp
  801733:	89 f0                	mov    %esi,%eax
}
  801735:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801738:	5b                   	pop    %ebx
  801739:	5e                   	pop    %esi
  80173a:	5d                   	pop    %ebp
  80173b:	c3                   	ret    

0080173c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	56                   	push   %esi
  801740:	53                   	push   %ebx
  801741:	89 c6                	mov    %eax,%esi
  801743:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801745:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80174c:	75 12                	jne    801760 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80174e:	83 ec 0c             	sub    $0xc,%esp
  801751:	6a 01                	push   $0x1
  801753:	e8 98 09 00 00       	call   8020f0 <ipc_find_env>
  801758:	a3 04 40 80 00       	mov    %eax,0x804004
  80175d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801760:	6a 07                	push   $0x7
  801762:	68 00 50 80 00       	push   $0x805000
  801767:	56                   	push   %esi
  801768:	ff 35 04 40 80 00    	pushl  0x804004
  80176e:	e8 1b 09 00 00       	call   80208e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801773:	83 c4 0c             	add    $0xc,%esp
  801776:	6a 00                	push   $0x0
  801778:	53                   	push   %ebx
  801779:	6a 00                	push   $0x0
  80177b:	e8 96 08 00 00       	call   802016 <ipc_recv>
}
  801780:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801783:	5b                   	pop    %ebx
  801784:	5e                   	pop    %esi
  801785:	5d                   	pop    %ebp
  801786:	c3                   	ret    

00801787 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80178d:	8b 45 08             	mov    0x8(%ebp),%eax
  801790:	8b 40 0c             	mov    0xc(%eax),%eax
  801793:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801798:	8b 45 0c             	mov    0xc(%ebp),%eax
  80179b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a5:	b8 02 00 00 00       	mov    $0x2,%eax
  8017aa:	e8 8d ff ff ff       	call   80173c <fsipc>
}
  8017af:	c9                   	leave  
  8017b0:	c3                   	ret    

008017b1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017b1:	55                   	push   %ebp
  8017b2:	89 e5                	mov    %esp,%ebp
  8017b4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ba:	8b 40 0c             	mov    0xc(%eax),%eax
  8017bd:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c7:	b8 06 00 00 00       	mov    $0x6,%eax
  8017cc:	e8 6b ff ff ff       	call   80173c <fsipc>
}
  8017d1:	c9                   	leave  
  8017d2:	c3                   	ret    

008017d3 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017d3:	55                   	push   %ebp
  8017d4:	89 e5                	mov    %esp,%ebp
  8017d6:	53                   	push   %ebx
  8017d7:	83 ec 04             	sub    $0x4,%esp
  8017da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ed:	b8 05 00 00 00       	mov    $0x5,%eax
  8017f2:	e8 45 ff ff ff       	call   80173c <fsipc>
  8017f7:	85 c0                	test   %eax,%eax
  8017f9:	78 2c                	js     801827 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017fb:	83 ec 08             	sub    $0x8,%esp
  8017fe:	68 00 50 80 00       	push   $0x805000
  801803:	53                   	push   %ebx
  801804:	e8 5e f0 ff ff       	call   800867 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801809:	a1 80 50 80 00       	mov    0x805080,%eax
  80180e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801814:	a1 84 50 80 00       	mov    0x805084,%eax
  801819:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80181f:	83 c4 10             	add    $0x10,%esp
  801822:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801827:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80182a:	c9                   	leave  
  80182b:	c3                   	ret    

0080182c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80182c:	55                   	push   %ebp
  80182d:	89 e5                	mov    %esp,%ebp
  80182f:	83 ec 0c             	sub    $0xc,%esp
  801832:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801835:	8b 55 08             	mov    0x8(%ebp),%edx
  801838:	8b 52 0c             	mov    0xc(%edx),%edx
  80183b:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801841:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801846:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80184b:	0f 47 c2             	cmova  %edx,%eax
  80184e:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801853:	50                   	push   %eax
  801854:	ff 75 0c             	pushl  0xc(%ebp)
  801857:	68 08 50 80 00       	push   $0x805008
  80185c:	e8 98 f1 ff ff       	call   8009f9 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801861:	ba 00 00 00 00       	mov    $0x0,%edx
  801866:	b8 04 00 00 00       	mov    $0x4,%eax
  80186b:	e8 cc fe ff ff       	call   80173c <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801870:	c9                   	leave  
  801871:	c3                   	ret    

00801872 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	56                   	push   %esi
  801876:	53                   	push   %ebx
  801877:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80187a:	8b 45 08             	mov    0x8(%ebp),%eax
  80187d:	8b 40 0c             	mov    0xc(%eax),%eax
  801880:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801885:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80188b:	ba 00 00 00 00       	mov    $0x0,%edx
  801890:	b8 03 00 00 00       	mov    $0x3,%eax
  801895:	e8 a2 fe ff ff       	call   80173c <fsipc>
  80189a:	89 c3                	mov    %eax,%ebx
  80189c:	85 c0                	test   %eax,%eax
  80189e:	78 4b                	js     8018eb <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018a0:	39 c6                	cmp    %eax,%esi
  8018a2:	73 16                	jae    8018ba <devfile_read+0x48>
  8018a4:	68 b8 28 80 00       	push   $0x8028b8
  8018a9:	68 bf 28 80 00       	push   $0x8028bf
  8018ae:	6a 7c                	push   $0x7c
  8018b0:	68 d4 28 80 00       	push   $0x8028d4
  8018b5:	e8 4f e9 ff ff       	call   800209 <_panic>
	assert(r <= PGSIZE);
  8018ba:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018bf:	7e 16                	jle    8018d7 <devfile_read+0x65>
  8018c1:	68 df 28 80 00       	push   $0x8028df
  8018c6:	68 bf 28 80 00       	push   $0x8028bf
  8018cb:	6a 7d                	push   $0x7d
  8018cd:	68 d4 28 80 00       	push   $0x8028d4
  8018d2:	e8 32 e9 ff ff       	call   800209 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018d7:	83 ec 04             	sub    $0x4,%esp
  8018da:	50                   	push   %eax
  8018db:	68 00 50 80 00       	push   $0x805000
  8018e0:	ff 75 0c             	pushl  0xc(%ebp)
  8018e3:	e8 11 f1 ff ff       	call   8009f9 <memmove>
	return r;
  8018e8:	83 c4 10             	add    $0x10,%esp
}
  8018eb:	89 d8                	mov    %ebx,%eax
  8018ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f0:	5b                   	pop    %ebx
  8018f1:	5e                   	pop    %esi
  8018f2:	5d                   	pop    %ebp
  8018f3:	c3                   	ret    

008018f4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	53                   	push   %ebx
  8018f8:	83 ec 20             	sub    $0x20,%esp
  8018fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018fe:	53                   	push   %ebx
  8018ff:	e8 2a ef ff ff       	call   80082e <strlen>
  801904:	83 c4 10             	add    $0x10,%esp
  801907:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80190c:	7f 67                	jg     801975 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80190e:	83 ec 0c             	sub    $0xc,%esp
  801911:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801914:	50                   	push   %eax
  801915:	e8 9a f8 ff ff       	call   8011b4 <fd_alloc>
  80191a:	83 c4 10             	add    $0x10,%esp
		return r;
  80191d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80191f:	85 c0                	test   %eax,%eax
  801921:	78 57                	js     80197a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801923:	83 ec 08             	sub    $0x8,%esp
  801926:	53                   	push   %ebx
  801927:	68 00 50 80 00       	push   $0x805000
  80192c:	e8 36 ef ff ff       	call   800867 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801931:	8b 45 0c             	mov    0xc(%ebp),%eax
  801934:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801939:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80193c:	b8 01 00 00 00       	mov    $0x1,%eax
  801941:	e8 f6 fd ff ff       	call   80173c <fsipc>
  801946:	89 c3                	mov    %eax,%ebx
  801948:	83 c4 10             	add    $0x10,%esp
  80194b:	85 c0                	test   %eax,%eax
  80194d:	79 14                	jns    801963 <open+0x6f>
		fd_close(fd, 0);
  80194f:	83 ec 08             	sub    $0x8,%esp
  801952:	6a 00                	push   $0x0
  801954:	ff 75 f4             	pushl  -0xc(%ebp)
  801957:	e8 50 f9 ff ff       	call   8012ac <fd_close>
		return r;
  80195c:	83 c4 10             	add    $0x10,%esp
  80195f:	89 da                	mov    %ebx,%edx
  801961:	eb 17                	jmp    80197a <open+0x86>
	}

	return fd2num(fd);
  801963:	83 ec 0c             	sub    $0xc,%esp
  801966:	ff 75 f4             	pushl  -0xc(%ebp)
  801969:	e8 1f f8 ff ff       	call   80118d <fd2num>
  80196e:	89 c2                	mov    %eax,%edx
  801970:	83 c4 10             	add    $0x10,%esp
  801973:	eb 05                	jmp    80197a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801975:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80197a:	89 d0                	mov    %edx,%eax
  80197c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80197f:	c9                   	leave  
  801980:	c3                   	ret    

00801981 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801981:	55                   	push   %ebp
  801982:	89 e5                	mov    %esp,%ebp
  801984:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801987:	ba 00 00 00 00       	mov    $0x0,%edx
  80198c:	b8 08 00 00 00       	mov    $0x8,%eax
  801991:	e8 a6 fd ff ff       	call   80173c <fsipc>
}
  801996:	c9                   	leave  
  801997:	c3                   	ret    

00801998 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801998:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80199c:	7e 37                	jle    8019d5 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	53                   	push   %ebx
  8019a2:	83 ec 08             	sub    $0x8,%esp
  8019a5:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8019a7:	ff 70 04             	pushl  0x4(%eax)
  8019aa:	8d 40 10             	lea    0x10(%eax),%eax
  8019ad:	50                   	push   %eax
  8019ae:	ff 33                	pushl  (%ebx)
  8019b0:	e8 8e fb ff ff       	call   801543 <write>
		if (result > 0)
  8019b5:	83 c4 10             	add    $0x10,%esp
  8019b8:	85 c0                	test   %eax,%eax
  8019ba:	7e 03                	jle    8019bf <writebuf+0x27>
			b->result += result;
  8019bc:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8019bf:	3b 43 04             	cmp    0x4(%ebx),%eax
  8019c2:	74 0d                	je     8019d1 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8019c4:	85 c0                	test   %eax,%eax
  8019c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8019cb:	0f 4f c2             	cmovg  %edx,%eax
  8019ce:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8019d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d4:	c9                   	leave  
  8019d5:	f3 c3                	repz ret 

008019d7 <putch>:

static void
putch(int ch, void *thunk)
{
  8019d7:	55                   	push   %ebp
  8019d8:	89 e5                	mov    %esp,%ebp
  8019da:	53                   	push   %ebx
  8019db:	83 ec 04             	sub    $0x4,%esp
  8019de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8019e1:	8b 53 04             	mov    0x4(%ebx),%edx
  8019e4:	8d 42 01             	lea    0x1(%edx),%eax
  8019e7:	89 43 04             	mov    %eax,0x4(%ebx)
  8019ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019ed:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8019f1:	3d 00 01 00 00       	cmp    $0x100,%eax
  8019f6:	75 0e                	jne    801a06 <putch+0x2f>
		writebuf(b);
  8019f8:	89 d8                	mov    %ebx,%eax
  8019fa:	e8 99 ff ff ff       	call   801998 <writebuf>
		b->idx = 0;
  8019ff:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801a06:	83 c4 04             	add    $0x4,%esp
  801a09:	5b                   	pop    %ebx
  801a0a:	5d                   	pop    %ebp
  801a0b:	c3                   	ret    

00801a0c <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801a15:	8b 45 08             	mov    0x8(%ebp),%eax
  801a18:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801a1e:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801a25:	00 00 00 
	b.result = 0;
  801a28:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801a2f:	00 00 00 
	b.error = 1;
  801a32:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801a39:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801a3c:	ff 75 10             	pushl  0x10(%ebp)
  801a3f:	ff 75 0c             	pushl  0xc(%ebp)
  801a42:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a48:	50                   	push   %eax
  801a49:	68 d7 19 80 00       	push   $0x8019d7
  801a4e:	e8 c6 e9 ff ff       	call   800419 <vprintfmt>
	if (b.idx > 0)
  801a53:	83 c4 10             	add    $0x10,%esp
  801a56:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801a5d:	7e 0b                	jle    801a6a <vfprintf+0x5e>
		writebuf(&b);
  801a5f:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a65:	e8 2e ff ff ff       	call   801998 <writebuf>

	return (b.result ? b.result : b.error);
  801a6a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801a70:	85 c0                	test   %eax,%eax
  801a72:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801a79:	c9                   	leave  
  801a7a:	c3                   	ret    

00801a7b <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801a7b:	55                   	push   %ebp
  801a7c:	89 e5                	mov    %esp,%ebp
  801a7e:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a81:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801a84:	50                   	push   %eax
  801a85:	ff 75 0c             	pushl  0xc(%ebp)
  801a88:	ff 75 08             	pushl  0x8(%ebp)
  801a8b:	e8 7c ff ff ff       	call   801a0c <vfprintf>
	va_end(ap);

	return cnt;
}
  801a90:	c9                   	leave  
  801a91:	c3                   	ret    

00801a92 <printf>:

int
printf(const char *fmt, ...)
{
  801a92:	55                   	push   %ebp
  801a93:	89 e5                	mov    %esp,%ebp
  801a95:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a98:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801a9b:	50                   	push   %eax
  801a9c:	ff 75 08             	pushl  0x8(%ebp)
  801a9f:	6a 01                	push   $0x1
  801aa1:	e8 66 ff ff ff       	call   801a0c <vfprintf>
	va_end(ap);

	return cnt;
}
  801aa6:	c9                   	leave  
  801aa7:	c3                   	ret    

00801aa8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	56                   	push   %esi
  801aac:	53                   	push   %ebx
  801aad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ab0:	83 ec 0c             	sub    $0xc,%esp
  801ab3:	ff 75 08             	pushl  0x8(%ebp)
  801ab6:	e8 e2 f6 ff ff       	call   80119d <fd2data>
  801abb:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801abd:	83 c4 08             	add    $0x8,%esp
  801ac0:	68 eb 28 80 00       	push   $0x8028eb
  801ac5:	53                   	push   %ebx
  801ac6:	e8 9c ed ff ff       	call   800867 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801acb:	8b 46 04             	mov    0x4(%esi),%eax
  801ace:	2b 06                	sub    (%esi),%eax
  801ad0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ad6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801add:	00 00 00 
	stat->st_dev = &devpipe;
  801ae0:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801ae7:	30 80 00 
	return 0;
}
  801aea:	b8 00 00 00 00       	mov    $0x0,%eax
  801aef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af2:	5b                   	pop    %ebx
  801af3:	5e                   	pop    %esi
  801af4:	5d                   	pop    %ebp
  801af5:	c3                   	ret    

00801af6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	53                   	push   %ebx
  801afa:	83 ec 0c             	sub    $0xc,%esp
  801afd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b00:	53                   	push   %ebx
  801b01:	6a 00                	push   $0x0
  801b03:	e8 e7 f1 ff ff       	call   800cef <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b08:	89 1c 24             	mov    %ebx,(%esp)
  801b0b:	e8 8d f6 ff ff       	call   80119d <fd2data>
  801b10:	83 c4 08             	add    $0x8,%esp
  801b13:	50                   	push   %eax
  801b14:	6a 00                	push   $0x0
  801b16:	e8 d4 f1 ff ff       	call   800cef <sys_page_unmap>
}
  801b1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b1e:	c9                   	leave  
  801b1f:	c3                   	ret    

00801b20 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	57                   	push   %edi
  801b24:	56                   	push   %esi
  801b25:	53                   	push   %ebx
  801b26:	83 ec 1c             	sub    $0x1c,%esp
  801b29:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b2c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b2e:	a1 08 40 80 00       	mov    0x804008,%eax
  801b33:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b36:	83 ec 0c             	sub    $0xc,%esp
  801b39:	ff 75 e0             	pushl  -0x20(%ebp)
  801b3c:	e8 ef 05 00 00       	call   802130 <pageref>
  801b41:	89 c3                	mov    %eax,%ebx
  801b43:	89 3c 24             	mov    %edi,(%esp)
  801b46:	e8 e5 05 00 00       	call   802130 <pageref>
  801b4b:	83 c4 10             	add    $0x10,%esp
  801b4e:	39 c3                	cmp    %eax,%ebx
  801b50:	0f 94 c1             	sete   %cl
  801b53:	0f b6 c9             	movzbl %cl,%ecx
  801b56:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b59:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801b5f:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  801b62:	39 ce                	cmp    %ecx,%esi
  801b64:	74 1b                	je     801b81 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b66:	39 c3                	cmp    %eax,%ebx
  801b68:	75 c4                	jne    801b2e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b6a:	8b 42 64             	mov    0x64(%edx),%eax
  801b6d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b70:	50                   	push   %eax
  801b71:	56                   	push   %esi
  801b72:	68 f2 28 80 00       	push   $0x8028f2
  801b77:	e8 66 e7 ff ff       	call   8002e2 <cprintf>
  801b7c:	83 c4 10             	add    $0x10,%esp
  801b7f:	eb ad                	jmp    801b2e <_pipeisclosed+0xe>
	}
}
  801b81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b87:	5b                   	pop    %ebx
  801b88:	5e                   	pop    %esi
  801b89:	5f                   	pop    %edi
  801b8a:	5d                   	pop    %ebp
  801b8b:	c3                   	ret    

00801b8c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
  801b8f:	57                   	push   %edi
  801b90:	56                   	push   %esi
  801b91:	53                   	push   %ebx
  801b92:	83 ec 28             	sub    $0x28,%esp
  801b95:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b98:	56                   	push   %esi
  801b99:	e8 ff f5 ff ff       	call   80119d <fd2data>
  801b9e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ba0:	83 c4 10             	add    $0x10,%esp
  801ba3:	bf 00 00 00 00       	mov    $0x0,%edi
  801ba8:	eb 4b                	jmp    801bf5 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801baa:	89 da                	mov    %ebx,%edx
  801bac:	89 f0                	mov    %esi,%eax
  801bae:	e8 6d ff ff ff       	call   801b20 <_pipeisclosed>
  801bb3:	85 c0                	test   %eax,%eax
  801bb5:	75 48                	jne    801bff <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bb7:	e8 8f f0 ff ff       	call   800c4b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bbc:	8b 43 04             	mov    0x4(%ebx),%eax
  801bbf:	8b 0b                	mov    (%ebx),%ecx
  801bc1:	8d 51 20             	lea    0x20(%ecx),%edx
  801bc4:	39 d0                	cmp    %edx,%eax
  801bc6:	73 e2                	jae    801baa <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bcb:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bcf:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bd2:	89 c2                	mov    %eax,%edx
  801bd4:	c1 fa 1f             	sar    $0x1f,%edx
  801bd7:	89 d1                	mov    %edx,%ecx
  801bd9:	c1 e9 1b             	shr    $0x1b,%ecx
  801bdc:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bdf:	83 e2 1f             	and    $0x1f,%edx
  801be2:	29 ca                	sub    %ecx,%edx
  801be4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801be8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bec:	83 c0 01             	add    $0x1,%eax
  801bef:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bf2:	83 c7 01             	add    $0x1,%edi
  801bf5:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bf8:	75 c2                	jne    801bbc <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bfa:	8b 45 10             	mov    0x10(%ebp),%eax
  801bfd:	eb 05                	jmp    801c04 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bff:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c07:	5b                   	pop    %ebx
  801c08:	5e                   	pop    %esi
  801c09:	5f                   	pop    %edi
  801c0a:	5d                   	pop    %ebp
  801c0b:	c3                   	ret    

00801c0c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c0c:	55                   	push   %ebp
  801c0d:	89 e5                	mov    %esp,%ebp
  801c0f:	57                   	push   %edi
  801c10:	56                   	push   %esi
  801c11:	53                   	push   %ebx
  801c12:	83 ec 18             	sub    $0x18,%esp
  801c15:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c18:	57                   	push   %edi
  801c19:	e8 7f f5 ff ff       	call   80119d <fd2data>
  801c1e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c20:	83 c4 10             	add    $0x10,%esp
  801c23:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c28:	eb 3d                	jmp    801c67 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c2a:	85 db                	test   %ebx,%ebx
  801c2c:	74 04                	je     801c32 <devpipe_read+0x26>
				return i;
  801c2e:	89 d8                	mov    %ebx,%eax
  801c30:	eb 44                	jmp    801c76 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c32:	89 f2                	mov    %esi,%edx
  801c34:	89 f8                	mov    %edi,%eax
  801c36:	e8 e5 fe ff ff       	call   801b20 <_pipeisclosed>
  801c3b:	85 c0                	test   %eax,%eax
  801c3d:	75 32                	jne    801c71 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c3f:	e8 07 f0 ff ff       	call   800c4b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c44:	8b 06                	mov    (%esi),%eax
  801c46:	3b 46 04             	cmp    0x4(%esi),%eax
  801c49:	74 df                	je     801c2a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c4b:	99                   	cltd   
  801c4c:	c1 ea 1b             	shr    $0x1b,%edx
  801c4f:	01 d0                	add    %edx,%eax
  801c51:	83 e0 1f             	and    $0x1f,%eax
  801c54:	29 d0                	sub    %edx,%eax
  801c56:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c5e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c61:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c64:	83 c3 01             	add    $0x1,%ebx
  801c67:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c6a:	75 d8                	jne    801c44 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c6c:	8b 45 10             	mov    0x10(%ebp),%eax
  801c6f:	eb 05                	jmp    801c76 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c71:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c79:	5b                   	pop    %ebx
  801c7a:	5e                   	pop    %esi
  801c7b:	5f                   	pop    %edi
  801c7c:	5d                   	pop    %ebp
  801c7d:	c3                   	ret    

00801c7e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c7e:	55                   	push   %ebp
  801c7f:	89 e5                	mov    %esp,%ebp
  801c81:	56                   	push   %esi
  801c82:	53                   	push   %ebx
  801c83:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c89:	50                   	push   %eax
  801c8a:	e8 25 f5 ff ff       	call   8011b4 <fd_alloc>
  801c8f:	83 c4 10             	add    $0x10,%esp
  801c92:	89 c2                	mov    %eax,%edx
  801c94:	85 c0                	test   %eax,%eax
  801c96:	0f 88 2c 01 00 00    	js     801dc8 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c9c:	83 ec 04             	sub    $0x4,%esp
  801c9f:	68 07 04 00 00       	push   $0x407
  801ca4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca7:	6a 00                	push   $0x0
  801ca9:	e8 bc ef ff ff       	call   800c6a <sys_page_alloc>
  801cae:	83 c4 10             	add    $0x10,%esp
  801cb1:	89 c2                	mov    %eax,%edx
  801cb3:	85 c0                	test   %eax,%eax
  801cb5:	0f 88 0d 01 00 00    	js     801dc8 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cbb:	83 ec 0c             	sub    $0xc,%esp
  801cbe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cc1:	50                   	push   %eax
  801cc2:	e8 ed f4 ff ff       	call   8011b4 <fd_alloc>
  801cc7:	89 c3                	mov    %eax,%ebx
  801cc9:	83 c4 10             	add    $0x10,%esp
  801ccc:	85 c0                	test   %eax,%eax
  801cce:	0f 88 e2 00 00 00    	js     801db6 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cd4:	83 ec 04             	sub    $0x4,%esp
  801cd7:	68 07 04 00 00       	push   $0x407
  801cdc:	ff 75 f0             	pushl  -0x10(%ebp)
  801cdf:	6a 00                	push   $0x0
  801ce1:	e8 84 ef ff ff       	call   800c6a <sys_page_alloc>
  801ce6:	89 c3                	mov    %eax,%ebx
  801ce8:	83 c4 10             	add    $0x10,%esp
  801ceb:	85 c0                	test   %eax,%eax
  801ced:	0f 88 c3 00 00 00    	js     801db6 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cf3:	83 ec 0c             	sub    $0xc,%esp
  801cf6:	ff 75 f4             	pushl  -0xc(%ebp)
  801cf9:	e8 9f f4 ff ff       	call   80119d <fd2data>
  801cfe:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d00:	83 c4 0c             	add    $0xc,%esp
  801d03:	68 07 04 00 00       	push   $0x407
  801d08:	50                   	push   %eax
  801d09:	6a 00                	push   $0x0
  801d0b:	e8 5a ef ff ff       	call   800c6a <sys_page_alloc>
  801d10:	89 c3                	mov    %eax,%ebx
  801d12:	83 c4 10             	add    $0x10,%esp
  801d15:	85 c0                	test   %eax,%eax
  801d17:	0f 88 89 00 00 00    	js     801da6 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d1d:	83 ec 0c             	sub    $0xc,%esp
  801d20:	ff 75 f0             	pushl  -0x10(%ebp)
  801d23:	e8 75 f4 ff ff       	call   80119d <fd2data>
  801d28:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d2f:	50                   	push   %eax
  801d30:	6a 00                	push   $0x0
  801d32:	56                   	push   %esi
  801d33:	6a 00                	push   $0x0
  801d35:	e8 73 ef ff ff       	call   800cad <sys_page_map>
  801d3a:	89 c3                	mov    %eax,%ebx
  801d3c:	83 c4 20             	add    $0x20,%esp
  801d3f:	85 c0                	test   %eax,%eax
  801d41:	78 55                	js     801d98 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d43:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d51:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d58:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d61:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d66:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d6d:	83 ec 0c             	sub    $0xc,%esp
  801d70:	ff 75 f4             	pushl  -0xc(%ebp)
  801d73:	e8 15 f4 ff ff       	call   80118d <fd2num>
  801d78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d7b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d7d:	83 c4 04             	add    $0x4,%esp
  801d80:	ff 75 f0             	pushl  -0x10(%ebp)
  801d83:	e8 05 f4 ff ff       	call   80118d <fd2num>
  801d88:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d8b:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801d8e:	83 c4 10             	add    $0x10,%esp
  801d91:	ba 00 00 00 00       	mov    $0x0,%edx
  801d96:	eb 30                	jmp    801dc8 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d98:	83 ec 08             	sub    $0x8,%esp
  801d9b:	56                   	push   %esi
  801d9c:	6a 00                	push   $0x0
  801d9e:	e8 4c ef ff ff       	call   800cef <sys_page_unmap>
  801da3:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801da6:	83 ec 08             	sub    $0x8,%esp
  801da9:	ff 75 f0             	pushl  -0x10(%ebp)
  801dac:	6a 00                	push   $0x0
  801dae:	e8 3c ef ff ff       	call   800cef <sys_page_unmap>
  801db3:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801db6:	83 ec 08             	sub    $0x8,%esp
  801db9:	ff 75 f4             	pushl  -0xc(%ebp)
  801dbc:	6a 00                	push   $0x0
  801dbe:	e8 2c ef ff ff       	call   800cef <sys_page_unmap>
  801dc3:	83 c4 10             	add    $0x10,%esp
  801dc6:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801dc8:	89 d0                	mov    %edx,%eax
  801dca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dcd:	5b                   	pop    %ebx
  801dce:	5e                   	pop    %esi
  801dcf:	5d                   	pop    %ebp
  801dd0:	c3                   	ret    

00801dd1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801dd1:	55                   	push   %ebp
  801dd2:	89 e5                	mov    %esp,%ebp
  801dd4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dd7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dda:	50                   	push   %eax
  801ddb:	ff 75 08             	pushl  0x8(%ebp)
  801dde:	e8 20 f4 ff ff       	call   801203 <fd_lookup>
  801de3:	83 c4 10             	add    $0x10,%esp
  801de6:	85 c0                	test   %eax,%eax
  801de8:	78 18                	js     801e02 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801dea:	83 ec 0c             	sub    $0xc,%esp
  801ded:	ff 75 f4             	pushl  -0xc(%ebp)
  801df0:	e8 a8 f3 ff ff       	call   80119d <fd2data>
	return _pipeisclosed(fd, p);
  801df5:	89 c2                	mov    %eax,%edx
  801df7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dfa:	e8 21 fd ff ff       	call   801b20 <_pipeisclosed>
  801dff:	83 c4 10             	add    $0x10,%esp
}
  801e02:	c9                   	leave  
  801e03:	c3                   	ret    

00801e04 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e04:	55                   	push   %ebp
  801e05:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e07:	b8 00 00 00 00       	mov    $0x0,%eax
  801e0c:	5d                   	pop    %ebp
  801e0d:	c3                   	ret    

00801e0e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e0e:	55                   	push   %ebp
  801e0f:	89 e5                	mov    %esp,%ebp
  801e11:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e14:	68 0a 29 80 00       	push   $0x80290a
  801e19:	ff 75 0c             	pushl  0xc(%ebp)
  801e1c:	e8 46 ea ff ff       	call   800867 <strcpy>
	return 0;
}
  801e21:	b8 00 00 00 00       	mov    $0x0,%eax
  801e26:	c9                   	leave  
  801e27:	c3                   	ret    

00801e28 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e28:	55                   	push   %ebp
  801e29:	89 e5                	mov    %esp,%ebp
  801e2b:	57                   	push   %edi
  801e2c:	56                   	push   %esi
  801e2d:	53                   	push   %ebx
  801e2e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e34:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e39:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e3f:	eb 2d                	jmp    801e6e <devcons_write+0x46>
		m = n - tot;
  801e41:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e44:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e46:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e49:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e4e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e51:	83 ec 04             	sub    $0x4,%esp
  801e54:	53                   	push   %ebx
  801e55:	03 45 0c             	add    0xc(%ebp),%eax
  801e58:	50                   	push   %eax
  801e59:	57                   	push   %edi
  801e5a:	e8 9a eb ff ff       	call   8009f9 <memmove>
		sys_cputs(buf, m);
  801e5f:	83 c4 08             	add    $0x8,%esp
  801e62:	53                   	push   %ebx
  801e63:	57                   	push   %edi
  801e64:	e8 45 ed ff ff       	call   800bae <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e69:	01 de                	add    %ebx,%esi
  801e6b:	83 c4 10             	add    $0x10,%esp
  801e6e:	89 f0                	mov    %esi,%eax
  801e70:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e73:	72 cc                	jb     801e41 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e78:	5b                   	pop    %ebx
  801e79:	5e                   	pop    %esi
  801e7a:	5f                   	pop    %edi
  801e7b:	5d                   	pop    %ebp
  801e7c:	c3                   	ret    

00801e7d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e7d:	55                   	push   %ebp
  801e7e:	89 e5                	mov    %esp,%ebp
  801e80:	83 ec 08             	sub    $0x8,%esp
  801e83:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e88:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e8c:	74 2a                	je     801eb8 <devcons_read+0x3b>
  801e8e:	eb 05                	jmp    801e95 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e90:	e8 b6 ed ff ff       	call   800c4b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e95:	e8 32 ed ff ff       	call   800bcc <sys_cgetc>
  801e9a:	85 c0                	test   %eax,%eax
  801e9c:	74 f2                	je     801e90 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	78 16                	js     801eb8 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ea2:	83 f8 04             	cmp    $0x4,%eax
  801ea5:	74 0c                	je     801eb3 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ea7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801eaa:	88 02                	mov    %al,(%edx)
	return 1;
  801eac:	b8 01 00 00 00       	mov    $0x1,%eax
  801eb1:	eb 05                	jmp    801eb8 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801eb3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801eb8:	c9                   	leave  
  801eb9:	c3                   	ret    

00801eba <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801eba:	55                   	push   %ebp
  801ebb:	89 e5                	mov    %esp,%ebp
  801ebd:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ec0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ec6:	6a 01                	push   $0x1
  801ec8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ecb:	50                   	push   %eax
  801ecc:	e8 dd ec ff ff       	call   800bae <sys_cputs>
}
  801ed1:	83 c4 10             	add    $0x10,%esp
  801ed4:	c9                   	leave  
  801ed5:	c3                   	ret    

00801ed6 <getchar>:

int
getchar(void)
{
  801ed6:	55                   	push   %ebp
  801ed7:	89 e5                	mov    %esp,%ebp
  801ed9:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801edc:	6a 01                	push   $0x1
  801ede:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ee1:	50                   	push   %eax
  801ee2:	6a 00                	push   $0x0
  801ee4:	e8 80 f5 ff ff       	call   801469 <read>
	if (r < 0)
  801ee9:	83 c4 10             	add    $0x10,%esp
  801eec:	85 c0                	test   %eax,%eax
  801eee:	78 0f                	js     801eff <getchar+0x29>
		return r;
	if (r < 1)
  801ef0:	85 c0                	test   %eax,%eax
  801ef2:	7e 06                	jle    801efa <getchar+0x24>
		return -E_EOF;
	return c;
  801ef4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ef8:	eb 05                	jmp    801eff <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801efa:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801eff:	c9                   	leave  
  801f00:	c3                   	ret    

00801f01 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f01:	55                   	push   %ebp
  801f02:	89 e5                	mov    %esp,%ebp
  801f04:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f07:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f0a:	50                   	push   %eax
  801f0b:	ff 75 08             	pushl  0x8(%ebp)
  801f0e:	e8 f0 f2 ff ff       	call   801203 <fd_lookup>
  801f13:	83 c4 10             	add    $0x10,%esp
  801f16:	85 c0                	test   %eax,%eax
  801f18:	78 11                	js     801f2b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f1d:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f23:	39 10                	cmp    %edx,(%eax)
  801f25:	0f 94 c0             	sete   %al
  801f28:	0f b6 c0             	movzbl %al,%eax
}
  801f2b:	c9                   	leave  
  801f2c:	c3                   	ret    

00801f2d <opencons>:

int
opencons(void)
{
  801f2d:	55                   	push   %ebp
  801f2e:	89 e5                	mov    %esp,%ebp
  801f30:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f33:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f36:	50                   	push   %eax
  801f37:	e8 78 f2 ff ff       	call   8011b4 <fd_alloc>
  801f3c:	83 c4 10             	add    $0x10,%esp
		return r;
  801f3f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f41:	85 c0                	test   %eax,%eax
  801f43:	78 3e                	js     801f83 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f45:	83 ec 04             	sub    $0x4,%esp
  801f48:	68 07 04 00 00       	push   $0x407
  801f4d:	ff 75 f4             	pushl  -0xc(%ebp)
  801f50:	6a 00                	push   $0x0
  801f52:	e8 13 ed ff ff       	call   800c6a <sys_page_alloc>
  801f57:	83 c4 10             	add    $0x10,%esp
		return r;
  801f5a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f5c:	85 c0                	test   %eax,%eax
  801f5e:	78 23                	js     801f83 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f60:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f69:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f6e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f75:	83 ec 0c             	sub    $0xc,%esp
  801f78:	50                   	push   %eax
  801f79:	e8 0f f2 ff ff       	call   80118d <fd2num>
  801f7e:	89 c2                	mov    %eax,%edx
  801f80:	83 c4 10             	add    $0x10,%esp
}
  801f83:	89 d0                	mov    %edx,%eax
  801f85:	c9                   	leave  
  801f86:	c3                   	ret    

00801f87 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f87:	55                   	push   %ebp
  801f88:	89 e5                	mov    %esp,%ebp
  801f8a:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f8d:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f94:	75 2a                	jne    801fc0 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801f96:	83 ec 04             	sub    $0x4,%esp
  801f99:	6a 07                	push   $0x7
  801f9b:	68 00 f0 bf ee       	push   $0xeebff000
  801fa0:	6a 00                	push   $0x0
  801fa2:	e8 c3 ec ff ff       	call   800c6a <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801fa7:	83 c4 10             	add    $0x10,%esp
  801faa:	85 c0                	test   %eax,%eax
  801fac:	79 12                	jns    801fc0 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801fae:	50                   	push   %eax
  801faf:	68 16 29 80 00       	push   $0x802916
  801fb4:	6a 23                	push   $0x23
  801fb6:	68 1a 29 80 00       	push   $0x80291a
  801fbb:	e8 49 e2 ff ff       	call   800209 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fc0:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc3:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801fc8:	83 ec 08             	sub    $0x8,%esp
  801fcb:	68 f2 1f 80 00       	push   $0x801ff2
  801fd0:	6a 00                	push   $0x0
  801fd2:	e8 de ed ff ff       	call   800db5 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801fd7:	83 c4 10             	add    $0x10,%esp
  801fda:	85 c0                	test   %eax,%eax
  801fdc:	79 12                	jns    801ff0 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801fde:	50                   	push   %eax
  801fdf:	68 16 29 80 00       	push   $0x802916
  801fe4:	6a 2c                	push   $0x2c
  801fe6:	68 1a 29 80 00       	push   $0x80291a
  801feb:	e8 19 e2 ff ff       	call   800209 <_panic>
	}
}
  801ff0:	c9                   	leave  
  801ff1:	c3                   	ret    

00801ff2 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801ff2:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801ff3:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801ff8:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801ffa:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801ffd:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802001:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802006:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80200a:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  80200c:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  80200f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802010:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802013:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802014:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802015:	c3                   	ret    

00802016 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802016:	55                   	push   %ebp
  802017:	89 e5                	mov    %esp,%ebp
  802019:	56                   	push   %esi
  80201a:	53                   	push   %ebx
  80201b:	8b 75 08             	mov    0x8(%ebp),%esi
  80201e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802021:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802024:	85 c0                	test   %eax,%eax
  802026:	75 12                	jne    80203a <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802028:	83 ec 0c             	sub    $0xc,%esp
  80202b:	68 00 00 c0 ee       	push   $0xeec00000
  802030:	e8 e5 ed ff ff       	call   800e1a <sys_ipc_recv>
  802035:	83 c4 10             	add    $0x10,%esp
  802038:	eb 0c                	jmp    802046 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80203a:	83 ec 0c             	sub    $0xc,%esp
  80203d:	50                   	push   %eax
  80203e:	e8 d7 ed ff ff       	call   800e1a <sys_ipc_recv>
  802043:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802046:	85 f6                	test   %esi,%esi
  802048:	0f 95 c1             	setne  %cl
  80204b:	85 db                	test   %ebx,%ebx
  80204d:	0f 95 c2             	setne  %dl
  802050:	84 d1                	test   %dl,%cl
  802052:	74 09                	je     80205d <ipc_recv+0x47>
  802054:	89 c2                	mov    %eax,%edx
  802056:	c1 ea 1f             	shr    $0x1f,%edx
  802059:	84 d2                	test   %dl,%dl
  80205b:	75 2a                	jne    802087 <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80205d:	85 f6                	test   %esi,%esi
  80205f:	74 0d                	je     80206e <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802061:	a1 08 40 80 00       	mov    0x804008,%eax
  802066:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  80206c:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80206e:	85 db                	test   %ebx,%ebx
  802070:	74 0d                	je     80207f <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802072:	a1 08 40 80 00       	mov    0x804008,%eax
  802077:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  80207d:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80207f:	a1 08 40 80 00       	mov    0x804008,%eax
  802084:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  802087:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80208a:	5b                   	pop    %ebx
  80208b:	5e                   	pop    %esi
  80208c:	5d                   	pop    %ebp
  80208d:	c3                   	ret    

0080208e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80208e:	55                   	push   %ebp
  80208f:	89 e5                	mov    %esp,%ebp
  802091:	57                   	push   %edi
  802092:	56                   	push   %esi
  802093:	53                   	push   %ebx
  802094:	83 ec 0c             	sub    $0xc,%esp
  802097:	8b 7d 08             	mov    0x8(%ebp),%edi
  80209a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80209d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8020a0:	85 db                	test   %ebx,%ebx
  8020a2:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020a7:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8020aa:	ff 75 14             	pushl  0x14(%ebp)
  8020ad:	53                   	push   %ebx
  8020ae:	56                   	push   %esi
  8020af:	57                   	push   %edi
  8020b0:	e8 42 ed ff ff       	call   800df7 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8020b5:	89 c2                	mov    %eax,%edx
  8020b7:	c1 ea 1f             	shr    $0x1f,%edx
  8020ba:	83 c4 10             	add    $0x10,%esp
  8020bd:	84 d2                	test   %dl,%dl
  8020bf:	74 17                	je     8020d8 <ipc_send+0x4a>
  8020c1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020c4:	74 12                	je     8020d8 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8020c6:	50                   	push   %eax
  8020c7:	68 28 29 80 00       	push   $0x802928
  8020cc:	6a 47                	push   $0x47
  8020ce:	68 36 29 80 00       	push   $0x802936
  8020d3:	e8 31 e1 ff ff       	call   800209 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8020d8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020db:	75 07                	jne    8020e4 <ipc_send+0x56>
			sys_yield();
  8020dd:	e8 69 eb ff ff       	call   800c4b <sys_yield>
  8020e2:	eb c6                	jmp    8020aa <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8020e4:	85 c0                	test   %eax,%eax
  8020e6:	75 c2                	jne    8020aa <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8020e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020eb:	5b                   	pop    %ebx
  8020ec:	5e                   	pop    %esi
  8020ed:	5f                   	pop    %edi
  8020ee:	5d                   	pop    %ebp
  8020ef:	c3                   	ret    

008020f0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020f0:	55                   	push   %ebp
  8020f1:	89 e5                	mov    %esp,%ebp
  8020f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020f6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020fb:	89 c2                	mov    %eax,%edx
  8020fd:	c1 e2 07             	shl    $0x7,%edx
  802100:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  802107:	8b 52 5c             	mov    0x5c(%edx),%edx
  80210a:	39 ca                	cmp    %ecx,%edx
  80210c:	75 11                	jne    80211f <ipc_find_env+0x2f>
			return envs[i].env_id;
  80210e:	89 c2                	mov    %eax,%edx
  802110:	c1 e2 07             	shl    $0x7,%edx
  802113:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  80211a:	8b 40 54             	mov    0x54(%eax),%eax
  80211d:	eb 0f                	jmp    80212e <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80211f:	83 c0 01             	add    $0x1,%eax
  802122:	3d 00 04 00 00       	cmp    $0x400,%eax
  802127:	75 d2                	jne    8020fb <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802129:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80212e:	5d                   	pop    %ebp
  80212f:	c3                   	ret    

00802130 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802130:	55                   	push   %ebp
  802131:	89 e5                	mov    %esp,%ebp
  802133:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802136:	89 d0                	mov    %edx,%eax
  802138:	c1 e8 16             	shr    $0x16,%eax
  80213b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802142:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802147:	f6 c1 01             	test   $0x1,%cl
  80214a:	74 1d                	je     802169 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80214c:	c1 ea 0c             	shr    $0xc,%edx
  80214f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802156:	f6 c2 01             	test   $0x1,%dl
  802159:	74 0e                	je     802169 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80215b:	c1 ea 0c             	shr    $0xc,%edx
  80215e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802165:	ef 
  802166:	0f b7 c0             	movzwl %ax,%eax
}
  802169:	5d                   	pop    %ebp
  80216a:	c3                   	ret    
  80216b:	66 90                	xchg   %ax,%ax
  80216d:	66 90                	xchg   %ax,%ax
  80216f:	90                   	nop

00802170 <__udivdi3>:
  802170:	55                   	push   %ebp
  802171:	57                   	push   %edi
  802172:	56                   	push   %esi
  802173:	53                   	push   %ebx
  802174:	83 ec 1c             	sub    $0x1c,%esp
  802177:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80217b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80217f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802183:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802187:	85 f6                	test   %esi,%esi
  802189:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80218d:	89 ca                	mov    %ecx,%edx
  80218f:	89 f8                	mov    %edi,%eax
  802191:	75 3d                	jne    8021d0 <__udivdi3+0x60>
  802193:	39 cf                	cmp    %ecx,%edi
  802195:	0f 87 c5 00 00 00    	ja     802260 <__udivdi3+0xf0>
  80219b:	85 ff                	test   %edi,%edi
  80219d:	89 fd                	mov    %edi,%ebp
  80219f:	75 0b                	jne    8021ac <__udivdi3+0x3c>
  8021a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021a6:	31 d2                	xor    %edx,%edx
  8021a8:	f7 f7                	div    %edi
  8021aa:	89 c5                	mov    %eax,%ebp
  8021ac:	89 c8                	mov    %ecx,%eax
  8021ae:	31 d2                	xor    %edx,%edx
  8021b0:	f7 f5                	div    %ebp
  8021b2:	89 c1                	mov    %eax,%ecx
  8021b4:	89 d8                	mov    %ebx,%eax
  8021b6:	89 cf                	mov    %ecx,%edi
  8021b8:	f7 f5                	div    %ebp
  8021ba:	89 c3                	mov    %eax,%ebx
  8021bc:	89 d8                	mov    %ebx,%eax
  8021be:	89 fa                	mov    %edi,%edx
  8021c0:	83 c4 1c             	add    $0x1c,%esp
  8021c3:	5b                   	pop    %ebx
  8021c4:	5e                   	pop    %esi
  8021c5:	5f                   	pop    %edi
  8021c6:	5d                   	pop    %ebp
  8021c7:	c3                   	ret    
  8021c8:	90                   	nop
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	39 ce                	cmp    %ecx,%esi
  8021d2:	77 74                	ja     802248 <__udivdi3+0xd8>
  8021d4:	0f bd fe             	bsr    %esi,%edi
  8021d7:	83 f7 1f             	xor    $0x1f,%edi
  8021da:	0f 84 98 00 00 00    	je     802278 <__udivdi3+0x108>
  8021e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021e5:	89 f9                	mov    %edi,%ecx
  8021e7:	89 c5                	mov    %eax,%ebp
  8021e9:	29 fb                	sub    %edi,%ebx
  8021eb:	d3 e6                	shl    %cl,%esi
  8021ed:	89 d9                	mov    %ebx,%ecx
  8021ef:	d3 ed                	shr    %cl,%ebp
  8021f1:	89 f9                	mov    %edi,%ecx
  8021f3:	d3 e0                	shl    %cl,%eax
  8021f5:	09 ee                	or     %ebp,%esi
  8021f7:	89 d9                	mov    %ebx,%ecx
  8021f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021fd:	89 d5                	mov    %edx,%ebp
  8021ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802203:	d3 ed                	shr    %cl,%ebp
  802205:	89 f9                	mov    %edi,%ecx
  802207:	d3 e2                	shl    %cl,%edx
  802209:	89 d9                	mov    %ebx,%ecx
  80220b:	d3 e8                	shr    %cl,%eax
  80220d:	09 c2                	or     %eax,%edx
  80220f:	89 d0                	mov    %edx,%eax
  802211:	89 ea                	mov    %ebp,%edx
  802213:	f7 f6                	div    %esi
  802215:	89 d5                	mov    %edx,%ebp
  802217:	89 c3                	mov    %eax,%ebx
  802219:	f7 64 24 0c          	mull   0xc(%esp)
  80221d:	39 d5                	cmp    %edx,%ebp
  80221f:	72 10                	jb     802231 <__udivdi3+0xc1>
  802221:	8b 74 24 08          	mov    0x8(%esp),%esi
  802225:	89 f9                	mov    %edi,%ecx
  802227:	d3 e6                	shl    %cl,%esi
  802229:	39 c6                	cmp    %eax,%esi
  80222b:	73 07                	jae    802234 <__udivdi3+0xc4>
  80222d:	39 d5                	cmp    %edx,%ebp
  80222f:	75 03                	jne    802234 <__udivdi3+0xc4>
  802231:	83 eb 01             	sub    $0x1,%ebx
  802234:	31 ff                	xor    %edi,%edi
  802236:	89 d8                	mov    %ebx,%eax
  802238:	89 fa                	mov    %edi,%edx
  80223a:	83 c4 1c             	add    $0x1c,%esp
  80223d:	5b                   	pop    %ebx
  80223e:	5e                   	pop    %esi
  80223f:	5f                   	pop    %edi
  802240:	5d                   	pop    %ebp
  802241:	c3                   	ret    
  802242:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802248:	31 ff                	xor    %edi,%edi
  80224a:	31 db                	xor    %ebx,%ebx
  80224c:	89 d8                	mov    %ebx,%eax
  80224e:	89 fa                	mov    %edi,%edx
  802250:	83 c4 1c             	add    $0x1c,%esp
  802253:	5b                   	pop    %ebx
  802254:	5e                   	pop    %esi
  802255:	5f                   	pop    %edi
  802256:	5d                   	pop    %ebp
  802257:	c3                   	ret    
  802258:	90                   	nop
  802259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802260:	89 d8                	mov    %ebx,%eax
  802262:	f7 f7                	div    %edi
  802264:	31 ff                	xor    %edi,%edi
  802266:	89 c3                	mov    %eax,%ebx
  802268:	89 d8                	mov    %ebx,%eax
  80226a:	89 fa                	mov    %edi,%edx
  80226c:	83 c4 1c             	add    $0x1c,%esp
  80226f:	5b                   	pop    %ebx
  802270:	5e                   	pop    %esi
  802271:	5f                   	pop    %edi
  802272:	5d                   	pop    %ebp
  802273:	c3                   	ret    
  802274:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802278:	39 ce                	cmp    %ecx,%esi
  80227a:	72 0c                	jb     802288 <__udivdi3+0x118>
  80227c:	31 db                	xor    %ebx,%ebx
  80227e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802282:	0f 87 34 ff ff ff    	ja     8021bc <__udivdi3+0x4c>
  802288:	bb 01 00 00 00       	mov    $0x1,%ebx
  80228d:	e9 2a ff ff ff       	jmp    8021bc <__udivdi3+0x4c>
  802292:	66 90                	xchg   %ax,%ax
  802294:	66 90                	xchg   %ax,%ax
  802296:	66 90                	xchg   %ax,%ax
  802298:	66 90                	xchg   %ax,%ax
  80229a:	66 90                	xchg   %ax,%ax
  80229c:	66 90                	xchg   %ax,%ax
  80229e:	66 90                	xchg   %ax,%ax

008022a0 <__umoddi3>:
  8022a0:	55                   	push   %ebp
  8022a1:	57                   	push   %edi
  8022a2:	56                   	push   %esi
  8022a3:	53                   	push   %ebx
  8022a4:	83 ec 1c             	sub    $0x1c,%esp
  8022a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022b7:	85 d2                	test   %edx,%edx
  8022b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022c1:	89 f3                	mov    %esi,%ebx
  8022c3:	89 3c 24             	mov    %edi,(%esp)
  8022c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022ca:	75 1c                	jne    8022e8 <__umoddi3+0x48>
  8022cc:	39 f7                	cmp    %esi,%edi
  8022ce:	76 50                	jbe    802320 <__umoddi3+0x80>
  8022d0:	89 c8                	mov    %ecx,%eax
  8022d2:	89 f2                	mov    %esi,%edx
  8022d4:	f7 f7                	div    %edi
  8022d6:	89 d0                	mov    %edx,%eax
  8022d8:	31 d2                	xor    %edx,%edx
  8022da:	83 c4 1c             	add    $0x1c,%esp
  8022dd:	5b                   	pop    %ebx
  8022de:	5e                   	pop    %esi
  8022df:	5f                   	pop    %edi
  8022e0:	5d                   	pop    %ebp
  8022e1:	c3                   	ret    
  8022e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022e8:	39 f2                	cmp    %esi,%edx
  8022ea:	89 d0                	mov    %edx,%eax
  8022ec:	77 52                	ja     802340 <__umoddi3+0xa0>
  8022ee:	0f bd ea             	bsr    %edx,%ebp
  8022f1:	83 f5 1f             	xor    $0x1f,%ebp
  8022f4:	75 5a                	jne    802350 <__umoddi3+0xb0>
  8022f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022fa:	0f 82 e0 00 00 00    	jb     8023e0 <__umoddi3+0x140>
  802300:	39 0c 24             	cmp    %ecx,(%esp)
  802303:	0f 86 d7 00 00 00    	jbe    8023e0 <__umoddi3+0x140>
  802309:	8b 44 24 08          	mov    0x8(%esp),%eax
  80230d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802311:	83 c4 1c             	add    $0x1c,%esp
  802314:	5b                   	pop    %ebx
  802315:	5e                   	pop    %esi
  802316:	5f                   	pop    %edi
  802317:	5d                   	pop    %ebp
  802318:	c3                   	ret    
  802319:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802320:	85 ff                	test   %edi,%edi
  802322:	89 fd                	mov    %edi,%ebp
  802324:	75 0b                	jne    802331 <__umoddi3+0x91>
  802326:	b8 01 00 00 00       	mov    $0x1,%eax
  80232b:	31 d2                	xor    %edx,%edx
  80232d:	f7 f7                	div    %edi
  80232f:	89 c5                	mov    %eax,%ebp
  802331:	89 f0                	mov    %esi,%eax
  802333:	31 d2                	xor    %edx,%edx
  802335:	f7 f5                	div    %ebp
  802337:	89 c8                	mov    %ecx,%eax
  802339:	f7 f5                	div    %ebp
  80233b:	89 d0                	mov    %edx,%eax
  80233d:	eb 99                	jmp    8022d8 <__umoddi3+0x38>
  80233f:	90                   	nop
  802340:	89 c8                	mov    %ecx,%eax
  802342:	89 f2                	mov    %esi,%edx
  802344:	83 c4 1c             	add    $0x1c,%esp
  802347:	5b                   	pop    %ebx
  802348:	5e                   	pop    %esi
  802349:	5f                   	pop    %edi
  80234a:	5d                   	pop    %ebp
  80234b:	c3                   	ret    
  80234c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802350:	8b 34 24             	mov    (%esp),%esi
  802353:	bf 20 00 00 00       	mov    $0x20,%edi
  802358:	89 e9                	mov    %ebp,%ecx
  80235a:	29 ef                	sub    %ebp,%edi
  80235c:	d3 e0                	shl    %cl,%eax
  80235e:	89 f9                	mov    %edi,%ecx
  802360:	89 f2                	mov    %esi,%edx
  802362:	d3 ea                	shr    %cl,%edx
  802364:	89 e9                	mov    %ebp,%ecx
  802366:	09 c2                	or     %eax,%edx
  802368:	89 d8                	mov    %ebx,%eax
  80236a:	89 14 24             	mov    %edx,(%esp)
  80236d:	89 f2                	mov    %esi,%edx
  80236f:	d3 e2                	shl    %cl,%edx
  802371:	89 f9                	mov    %edi,%ecx
  802373:	89 54 24 04          	mov    %edx,0x4(%esp)
  802377:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80237b:	d3 e8                	shr    %cl,%eax
  80237d:	89 e9                	mov    %ebp,%ecx
  80237f:	89 c6                	mov    %eax,%esi
  802381:	d3 e3                	shl    %cl,%ebx
  802383:	89 f9                	mov    %edi,%ecx
  802385:	89 d0                	mov    %edx,%eax
  802387:	d3 e8                	shr    %cl,%eax
  802389:	89 e9                	mov    %ebp,%ecx
  80238b:	09 d8                	or     %ebx,%eax
  80238d:	89 d3                	mov    %edx,%ebx
  80238f:	89 f2                	mov    %esi,%edx
  802391:	f7 34 24             	divl   (%esp)
  802394:	89 d6                	mov    %edx,%esi
  802396:	d3 e3                	shl    %cl,%ebx
  802398:	f7 64 24 04          	mull   0x4(%esp)
  80239c:	39 d6                	cmp    %edx,%esi
  80239e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023a2:	89 d1                	mov    %edx,%ecx
  8023a4:	89 c3                	mov    %eax,%ebx
  8023a6:	72 08                	jb     8023b0 <__umoddi3+0x110>
  8023a8:	75 11                	jne    8023bb <__umoddi3+0x11b>
  8023aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023ae:	73 0b                	jae    8023bb <__umoddi3+0x11b>
  8023b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023b4:	1b 14 24             	sbb    (%esp),%edx
  8023b7:	89 d1                	mov    %edx,%ecx
  8023b9:	89 c3                	mov    %eax,%ebx
  8023bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023bf:	29 da                	sub    %ebx,%edx
  8023c1:	19 ce                	sbb    %ecx,%esi
  8023c3:	89 f9                	mov    %edi,%ecx
  8023c5:	89 f0                	mov    %esi,%eax
  8023c7:	d3 e0                	shl    %cl,%eax
  8023c9:	89 e9                	mov    %ebp,%ecx
  8023cb:	d3 ea                	shr    %cl,%edx
  8023cd:	89 e9                	mov    %ebp,%ecx
  8023cf:	d3 ee                	shr    %cl,%esi
  8023d1:	09 d0                	or     %edx,%eax
  8023d3:	89 f2                	mov    %esi,%edx
  8023d5:	83 c4 1c             	add    $0x1c,%esp
  8023d8:	5b                   	pop    %ebx
  8023d9:	5e                   	pop    %esi
  8023da:	5f                   	pop    %edi
  8023db:	5d                   	pop    %ebp
  8023dc:	c3                   	ret    
  8023dd:	8d 76 00             	lea    0x0(%esi),%esi
  8023e0:	29 f9                	sub    %edi,%ecx
  8023e2:	19 d6                	sbb    %edx,%esi
  8023e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023ec:	e9 18 ff ff ff       	jmp    802309 <__umoddi3+0x69>
