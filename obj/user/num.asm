
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
  80005d:	68 60 26 80 00       	push   $0x802660
  800062:	e8 62 1c 00 00       	call   801cc9 <printf>
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
  80007c:	e8 f3 16 00 00       	call   801774 <write>
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	83 f8 01             	cmp    $0x1,%eax
  800087:	74 18                	je     8000a1 <num+0x6e>
			panic("write error copying %s: %e", s, r);
  800089:	83 ec 0c             	sub    $0xc,%esp
  80008c:	50                   	push   %eax
  80008d:	ff 75 0c             	pushl  0xc(%ebp)
  800090:	68 65 26 80 00       	push   $0x802665
  800095:	6a 13                	push   $0x13
  800097:	68 80 26 80 00       	push   $0x802680
  80009c:	e8 67 01 00 00       	call   800208 <_panic>
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
  8000b8:	e8 da 15 00 00       	call   801697 <read>
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
  8000d3:	68 8b 26 80 00       	push   $0x80268b
  8000d8:	6a 18                	push   $0x18
  8000da:	68 80 26 80 00       	push   $0x802680
  8000df:	e8 24 01 00 00       	call   800208 <_panic>
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
  8000f4:	c7 05 04 30 80 00 a0 	movl   $0x8026a0,0x803004
  8000fb:	26 80 00 
	if (argc == 1)
  8000fe:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  800102:	74 0d                	je     800111 <umain+0x26>
  800104:	8b 45 0c             	mov    0xc(%ebp),%eax
  800107:	8d 58 04             	lea    0x4(%eax),%ebx
  80010a:	bf 01 00 00 00       	mov    $0x1,%edi
  80010f:	eb 62                	jmp    800173 <umain+0x88>
		num(0, "<stdin>");
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	68 a4 26 80 00       	push   $0x8026a4
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
  80012f:	e8 f7 19 00 00       	call   801b2b <open>
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
  800146:	68 ac 26 80 00       	push   $0x8026ac
  80014b:	6a 27                	push   $0x27
  80014d:	68 80 26 80 00       	push   $0x802680
  800152:	e8 b1 00 00 00       	call   800208 <_panic>
			else {
				num(f, argv[i]);
  800157:	83 ec 08             	sub    $0x8,%esp
  80015a:	ff 33                	pushl  (%ebx)
  80015c:	50                   	push   %eax
  80015d:	e8 d1 fe ff ff       	call   800033 <num>
				close(f);
  800162:	89 34 24             	mov    %esi,(%esp)
  800165:	e8 f1 13 00 00       	call   80155b <close>

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
  800178:	e8 71 00 00 00       	call   8001ee <exit>
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
  800190:	e8 96 0a 00 00       	call   800c2b <sys_getenvid>
  800195:	25 ff 03 00 00       	and    $0x3ff,%eax
  80019a:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8001a0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001a5:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001aa:	85 db                	test   %ebx,%ebx
  8001ac:	7e 07                	jle    8001b5 <libmain+0x30>
		binaryname = argv[0];
  8001ae:	8b 06                	mov    (%esi),%eax
  8001b0:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8001b5:	83 ec 08             	sub    $0x8,%esp
  8001b8:	56                   	push   %esi
  8001b9:	53                   	push   %ebx
  8001ba:	e8 2c ff ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8001bf:	e8 2a 00 00 00       	call   8001ee <exit>
}
  8001c4:	83 c4 10             	add    $0x10,%esp
  8001c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001ca:	5b                   	pop    %ebx
  8001cb:	5e                   	pop    %esi
  8001cc:	5d                   	pop    %ebp
  8001cd:	c3                   	ret    

008001ce <thread_main>:

/*Lab 7: Multithreading thread main routine*/
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  8001ce:	55                   	push   %ebp
  8001cf:	89 e5                	mov    %esp,%ebp
  8001d1:	83 ec 08             	sub    $0x8,%esp
	void (*func)(void) = (void (*)(void))eip;
  8001d4:	a1 0c 40 80 00       	mov    0x80400c,%eax
	func();
  8001d9:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8001db:	e8 4b 0a 00 00       	call   800c2b <sys_getenvid>
  8001e0:	83 ec 0c             	sub    $0xc,%esp
  8001e3:	50                   	push   %eax
  8001e4:	e8 91 0c 00 00       	call   800e7a <sys_thread_free>
}
  8001e9:	83 c4 10             	add    $0x10,%esp
  8001ec:	c9                   	leave  
  8001ed:	c3                   	ret    

008001ee <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001f4:	e8 8d 13 00 00       	call   801586 <close_all>
	sys_env_destroy(0);
  8001f9:	83 ec 0c             	sub    $0xc,%esp
  8001fc:	6a 00                	push   $0x0
  8001fe:	e8 e7 09 00 00       	call   800bea <sys_env_destroy>
}
  800203:	83 c4 10             	add    $0x10,%esp
  800206:	c9                   	leave  
  800207:	c3                   	ret    

00800208 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	56                   	push   %esi
  80020c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80020d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800210:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800216:	e8 10 0a 00 00       	call   800c2b <sys_getenvid>
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	ff 75 0c             	pushl  0xc(%ebp)
  800221:	ff 75 08             	pushl  0x8(%ebp)
  800224:	56                   	push   %esi
  800225:	50                   	push   %eax
  800226:	68 c8 26 80 00       	push   $0x8026c8
  80022b:	e8 b1 00 00 00       	call   8002e1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800230:	83 c4 18             	add    $0x18,%esp
  800233:	53                   	push   %ebx
  800234:	ff 75 10             	pushl  0x10(%ebp)
  800237:	e8 54 00 00 00       	call   800290 <vcprintf>
	cprintf("\n");
  80023c:	c7 04 24 7b 2a 80 00 	movl   $0x802a7b,(%esp)
  800243:	e8 99 00 00 00       	call   8002e1 <cprintf>
  800248:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80024b:	cc                   	int3   
  80024c:	eb fd                	jmp    80024b <_panic+0x43>

0080024e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	53                   	push   %ebx
  800252:	83 ec 04             	sub    $0x4,%esp
  800255:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800258:	8b 13                	mov    (%ebx),%edx
  80025a:	8d 42 01             	lea    0x1(%edx),%eax
  80025d:	89 03                	mov    %eax,(%ebx)
  80025f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800262:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800266:	3d ff 00 00 00       	cmp    $0xff,%eax
  80026b:	75 1a                	jne    800287 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80026d:	83 ec 08             	sub    $0x8,%esp
  800270:	68 ff 00 00 00       	push   $0xff
  800275:	8d 43 08             	lea    0x8(%ebx),%eax
  800278:	50                   	push   %eax
  800279:	e8 2f 09 00 00       	call   800bad <sys_cputs>
		b->idx = 0;
  80027e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800284:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800287:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80028b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80028e:	c9                   	leave  
  80028f:	c3                   	ret    

00800290 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800299:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002a0:	00 00 00 
	b.cnt = 0;
  8002a3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002aa:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002ad:	ff 75 0c             	pushl  0xc(%ebp)
  8002b0:	ff 75 08             	pushl  0x8(%ebp)
  8002b3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002b9:	50                   	push   %eax
  8002ba:	68 4e 02 80 00       	push   $0x80024e
  8002bf:	e8 54 01 00 00       	call   800418 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002c4:	83 c4 08             	add    $0x8,%esp
  8002c7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002cd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002d3:	50                   	push   %eax
  8002d4:	e8 d4 08 00 00       	call   800bad <sys_cputs>

	return b.cnt;
}
  8002d9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002df:	c9                   	leave  
  8002e0:	c3                   	ret    

008002e1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002e1:	55                   	push   %ebp
  8002e2:	89 e5                	mov    %esp,%ebp
  8002e4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002e7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002ea:	50                   	push   %eax
  8002eb:	ff 75 08             	pushl  0x8(%ebp)
  8002ee:	e8 9d ff ff ff       	call   800290 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002f3:	c9                   	leave  
  8002f4:	c3                   	ret    

008002f5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	57                   	push   %edi
  8002f9:	56                   	push   %esi
  8002fa:	53                   	push   %ebx
  8002fb:	83 ec 1c             	sub    $0x1c,%esp
  8002fe:	89 c7                	mov    %eax,%edi
  800300:	89 d6                	mov    %edx,%esi
  800302:	8b 45 08             	mov    0x8(%ebp),%eax
  800305:	8b 55 0c             	mov    0xc(%ebp),%edx
  800308:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80030b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80030e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800311:	bb 00 00 00 00       	mov    $0x0,%ebx
  800316:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800319:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80031c:	39 d3                	cmp    %edx,%ebx
  80031e:	72 05                	jb     800325 <printnum+0x30>
  800320:	39 45 10             	cmp    %eax,0x10(%ebp)
  800323:	77 45                	ja     80036a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800325:	83 ec 0c             	sub    $0xc,%esp
  800328:	ff 75 18             	pushl  0x18(%ebp)
  80032b:	8b 45 14             	mov    0x14(%ebp),%eax
  80032e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800331:	53                   	push   %ebx
  800332:	ff 75 10             	pushl  0x10(%ebp)
  800335:	83 ec 08             	sub    $0x8,%esp
  800338:	ff 75 e4             	pushl  -0x1c(%ebp)
  80033b:	ff 75 e0             	pushl  -0x20(%ebp)
  80033e:	ff 75 dc             	pushl  -0x24(%ebp)
  800341:	ff 75 d8             	pushl  -0x28(%ebp)
  800344:	e8 77 20 00 00       	call   8023c0 <__udivdi3>
  800349:	83 c4 18             	add    $0x18,%esp
  80034c:	52                   	push   %edx
  80034d:	50                   	push   %eax
  80034e:	89 f2                	mov    %esi,%edx
  800350:	89 f8                	mov    %edi,%eax
  800352:	e8 9e ff ff ff       	call   8002f5 <printnum>
  800357:	83 c4 20             	add    $0x20,%esp
  80035a:	eb 18                	jmp    800374 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80035c:	83 ec 08             	sub    $0x8,%esp
  80035f:	56                   	push   %esi
  800360:	ff 75 18             	pushl  0x18(%ebp)
  800363:	ff d7                	call   *%edi
  800365:	83 c4 10             	add    $0x10,%esp
  800368:	eb 03                	jmp    80036d <printnum+0x78>
  80036a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80036d:	83 eb 01             	sub    $0x1,%ebx
  800370:	85 db                	test   %ebx,%ebx
  800372:	7f e8                	jg     80035c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800374:	83 ec 08             	sub    $0x8,%esp
  800377:	56                   	push   %esi
  800378:	83 ec 04             	sub    $0x4,%esp
  80037b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80037e:	ff 75 e0             	pushl  -0x20(%ebp)
  800381:	ff 75 dc             	pushl  -0x24(%ebp)
  800384:	ff 75 d8             	pushl  -0x28(%ebp)
  800387:	e8 64 21 00 00       	call   8024f0 <__umoddi3>
  80038c:	83 c4 14             	add    $0x14,%esp
  80038f:	0f be 80 eb 26 80 00 	movsbl 0x8026eb(%eax),%eax
  800396:	50                   	push   %eax
  800397:	ff d7                	call   *%edi
}
  800399:	83 c4 10             	add    $0x10,%esp
  80039c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039f:	5b                   	pop    %ebx
  8003a0:	5e                   	pop    %esi
  8003a1:	5f                   	pop    %edi
  8003a2:	5d                   	pop    %ebp
  8003a3:	c3                   	ret    

008003a4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003a4:	55                   	push   %ebp
  8003a5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003a7:	83 fa 01             	cmp    $0x1,%edx
  8003aa:	7e 0e                	jle    8003ba <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003ac:	8b 10                	mov    (%eax),%edx
  8003ae:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003b1:	89 08                	mov    %ecx,(%eax)
  8003b3:	8b 02                	mov    (%edx),%eax
  8003b5:	8b 52 04             	mov    0x4(%edx),%edx
  8003b8:	eb 22                	jmp    8003dc <getuint+0x38>
	else if (lflag)
  8003ba:	85 d2                	test   %edx,%edx
  8003bc:	74 10                	je     8003ce <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003be:	8b 10                	mov    (%eax),%edx
  8003c0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c3:	89 08                	mov    %ecx,(%eax)
  8003c5:	8b 02                	mov    (%edx),%eax
  8003c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003cc:	eb 0e                	jmp    8003dc <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003ce:	8b 10                	mov    (%eax),%edx
  8003d0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d3:	89 08                	mov    %ecx,(%eax)
  8003d5:	8b 02                	mov    (%edx),%eax
  8003d7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003dc:	5d                   	pop    %ebp
  8003dd:	c3                   	ret    

008003de <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003de:	55                   	push   %ebp
  8003df:	89 e5                	mov    %esp,%ebp
  8003e1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003e4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003e8:	8b 10                	mov    (%eax),%edx
  8003ea:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ed:	73 0a                	jae    8003f9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003ef:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003f2:	89 08                	mov    %ecx,(%eax)
  8003f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f7:	88 02                	mov    %al,(%edx)
}
  8003f9:	5d                   	pop    %ebp
  8003fa:	c3                   	ret    

008003fb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003fb:	55                   	push   %ebp
  8003fc:	89 e5                	mov    %esp,%ebp
  8003fe:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800401:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800404:	50                   	push   %eax
  800405:	ff 75 10             	pushl  0x10(%ebp)
  800408:	ff 75 0c             	pushl  0xc(%ebp)
  80040b:	ff 75 08             	pushl  0x8(%ebp)
  80040e:	e8 05 00 00 00       	call   800418 <vprintfmt>
	va_end(ap);
}
  800413:	83 c4 10             	add    $0x10,%esp
  800416:	c9                   	leave  
  800417:	c3                   	ret    

00800418 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800418:	55                   	push   %ebp
  800419:	89 e5                	mov    %esp,%ebp
  80041b:	57                   	push   %edi
  80041c:	56                   	push   %esi
  80041d:	53                   	push   %ebx
  80041e:	83 ec 2c             	sub    $0x2c,%esp
  800421:	8b 75 08             	mov    0x8(%ebp),%esi
  800424:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800427:	8b 7d 10             	mov    0x10(%ebp),%edi
  80042a:	eb 12                	jmp    80043e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80042c:	85 c0                	test   %eax,%eax
  80042e:	0f 84 89 03 00 00    	je     8007bd <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800434:	83 ec 08             	sub    $0x8,%esp
  800437:	53                   	push   %ebx
  800438:	50                   	push   %eax
  800439:	ff d6                	call   *%esi
  80043b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80043e:	83 c7 01             	add    $0x1,%edi
  800441:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800445:	83 f8 25             	cmp    $0x25,%eax
  800448:	75 e2                	jne    80042c <vprintfmt+0x14>
  80044a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80044e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800455:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80045c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800463:	ba 00 00 00 00       	mov    $0x0,%edx
  800468:	eb 07                	jmp    800471 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80046d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800471:	8d 47 01             	lea    0x1(%edi),%eax
  800474:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800477:	0f b6 07             	movzbl (%edi),%eax
  80047a:	0f b6 c8             	movzbl %al,%ecx
  80047d:	83 e8 23             	sub    $0x23,%eax
  800480:	3c 55                	cmp    $0x55,%al
  800482:	0f 87 1a 03 00 00    	ja     8007a2 <vprintfmt+0x38a>
  800488:	0f b6 c0             	movzbl %al,%eax
  80048b:	ff 24 85 20 28 80 00 	jmp    *0x802820(,%eax,4)
  800492:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800495:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800499:	eb d6                	jmp    800471 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80049e:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004a6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004a9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004ad:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004b0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004b3:	83 fa 09             	cmp    $0x9,%edx
  8004b6:	77 39                	ja     8004f1 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004b8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004bb:	eb e9                	jmp    8004a6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c0:	8d 48 04             	lea    0x4(%eax),%ecx
  8004c3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004c6:	8b 00                	mov    (%eax),%eax
  8004c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004ce:	eb 27                	jmp    8004f7 <vprintfmt+0xdf>
  8004d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004d3:	85 c0                	test   %eax,%eax
  8004d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004da:	0f 49 c8             	cmovns %eax,%ecx
  8004dd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004e3:	eb 8c                	jmp    800471 <vprintfmt+0x59>
  8004e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004e8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004ef:	eb 80                	jmp    800471 <vprintfmt+0x59>
  8004f1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004f4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004f7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004fb:	0f 89 70 ff ff ff    	jns    800471 <vprintfmt+0x59>
				width = precision, precision = -1;
  800501:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800504:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800507:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80050e:	e9 5e ff ff ff       	jmp    800471 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800513:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800516:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800519:	e9 53 ff ff ff       	jmp    800471 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80051e:	8b 45 14             	mov    0x14(%ebp),%eax
  800521:	8d 50 04             	lea    0x4(%eax),%edx
  800524:	89 55 14             	mov    %edx,0x14(%ebp)
  800527:	83 ec 08             	sub    $0x8,%esp
  80052a:	53                   	push   %ebx
  80052b:	ff 30                	pushl  (%eax)
  80052d:	ff d6                	call   *%esi
			break;
  80052f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800532:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800535:	e9 04 ff ff ff       	jmp    80043e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80053a:	8b 45 14             	mov    0x14(%ebp),%eax
  80053d:	8d 50 04             	lea    0x4(%eax),%edx
  800540:	89 55 14             	mov    %edx,0x14(%ebp)
  800543:	8b 00                	mov    (%eax),%eax
  800545:	99                   	cltd   
  800546:	31 d0                	xor    %edx,%eax
  800548:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80054a:	83 f8 0f             	cmp    $0xf,%eax
  80054d:	7f 0b                	jg     80055a <vprintfmt+0x142>
  80054f:	8b 14 85 80 29 80 00 	mov    0x802980(,%eax,4),%edx
  800556:	85 d2                	test   %edx,%edx
  800558:	75 18                	jne    800572 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80055a:	50                   	push   %eax
  80055b:	68 03 27 80 00       	push   $0x802703
  800560:	53                   	push   %ebx
  800561:	56                   	push   %esi
  800562:	e8 94 fe ff ff       	call   8003fb <printfmt>
  800567:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80056d:	e9 cc fe ff ff       	jmp    80043e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800572:	52                   	push   %edx
  800573:	68 41 2b 80 00       	push   $0x802b41
  800578:	53                   	push   %ebx
  800579:	56                   	push   %esi
  80057a:	e8 7c fe ff ff       	call   8003fb <printfmt>
  80057f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800582:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800585:	e9 b4 fe ff ff       	jmp    80043e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80058a:	8b 45 14             	mov    0x14(%ebp),%eax
  80058d:	8d 50 04             	lea    0x4(%eax),%edx
  800590:	89 55 14             	mov    %edx,0x14(%ebp)
  800593:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800595:	85 ff                	test   %edi,%edi
  800597:	b8 fc 26 80 00       	mov    $0x8026fc,%eax
  80059c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80059f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005a3:	0f 8e 94 00 00 00    	jle    80063d <vprintfmt+0x225>
  8005a9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005ad:	0f 84 98 00 00 00    	je     80064b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b3:	83 ec 08             	sub    $0x8,%esp
  8005b6:	ff 75 d0             	pushl  -0x30(%ebp)
  8005b9:	57                   	push   %edi
  8005ba:	e8 86 02 00 00       	call   800845 <strnlen>
  8005bf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005c2:	29 c1                	sub    %eax,%ecx
  8005c4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005c7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005ca:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005d4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d6:	eb 0f                	jmp    8005e7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005d8:	83 ec 08             	sub    $0x8,%esp
  8005db:	53                   	push   %ebx
  8005dc:	ff 75 e0             	pushl  -0x20(%ebp)
  8005df:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e1:	83 ef 01             	sub    $0x1,%edi
  8005e4:	83 c4 10             	add    $0x10,%esp
  8005e7:	85 ff                	test   %edi,%edi
  8005e9:	7f ed                	jg     8005d8 <vprintfmt+0x1c0>
  8005eb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005ee:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005f1:	85 c9                	test   %ecx,%ecx
  8005f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f8:	0f 49 c1             	cmovns %ecx,%eax
  8005fb:	29 c1                	sub    %eax,%ecx
  8005fd:	89 75 08             	mov    %esi,0x8(%ebp)
  800600:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800603:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800606:	89 cb                	mov    %ecx,%ebx
  800608:	eb 4d                	jmp    800657 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80060a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80060e:	74 1b                	je     80062b <vprintfmt+0x213>
  800610:	0f be c0             	movsbl %al,%eax
  800613:	83 e8 20             	sub    $0x20,%eax
  800616:	83 f8 5e             	cmp    $0x5e,%eax
  800619:	76 10                	jbe    80062b <vprintfmt+0x213>
					putch('?', putdat);
  80061b:	83 ec 08             	sub    $0x8,%esp
  80061e:	ff 75 0c             	pushl  0xc(%ebp)
  800621:	6a 3f                	push   $0x3f
  800623:	ff 55 08             	call   *0x8(%ebp)
  800626:	83 c4 10             	add    $0x10,%esp
  800629:	eb 0d                	jmp    800638 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	ff 75 0c             	pushl  0xc(%ebp)
  800631:	52                   	push   %edx
  800632:	ff 55 08             	call   *0x8(%ebp)
  800635:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800638:	83 eb 01             	sub    $0x1,%ebx
  80063b:	eb 1a                	jmp    800657 <vprintfmt+0x23f>
  80063d:	89 75 08             	mov    %esi,0x8(%ebp)
  800640:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800643:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800646:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800649:	eb 0c                	jmp    800657 <vprintfmt+0x23f>
  80064b:	89 75 08             	mov    %esi,0x8(%ebp)
  80064e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800651:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800654:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800657:	83 c7 01             	add    $0x1,%edi
  80065a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80065e:	0f be d0             	movsbl %al,%edx
  800661:	85 d2                	test   %edx,%edx
  800663:	74 23                	je     800688 <vprintfmt+0x270>
  800665:	85 f6                	test   %esi,%esi
  800667:	78 a1                	js     80060a <vprintfmt+0x1f2>
  800669:	83 ee 01             	sub    $0x1,%esi
  80066c:	79 9c                	jns    80060a <vprintfmt+0x1f2>
  80066e:	89 df                	mov    %ebx,%edi
  800670:	8b 75 08             	mov    0x8(%ebp),%esi
  800673:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800676:	eb 18                	jmp    800690 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800678:	83 ec 08             	sub    $0x8,%esp
  80067b:	53                   	push   %ebx
  80067c:	6a 20                	push   $0x20
  80067e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800680:	83 ef 01             	sub    $0x1,%edi
  800683:	83 c4 10             	add    $0x10,%esp
  800686:	eb 08                	jmp    800690 <vprintfmt+0x278>
  800688:	89 df                	mov    %ebx,%edi
  80068a:	8b 75 08             	mov    0x8(%ebp),%esi
  80068d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800690:	85 ff                	test   %edi,%edi
  800692:	7f e4                	jg     800678 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800694:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800697:	e9 a2 fd ff ff       	jmp    80043e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80069c:	83 fa 01             	cmp    $0x1,%edx
  80069f:	7e 16                	jle    8006b7 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a4:	8d 50 08             	lea    0x8(%eax),%edx
  8006a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006aa:	8b 50 04             	mov    0x4(%eax),%edx
  8006ad:	8b 00                	mov    (%eax),%eax
  8006af:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006b5:	eb 32                	jmp    8006e9 <vprintfmt+0x2d1>
	else if (lflag)
  8006b7:	85 d2                	test   %edx,%edx
  8006b9:	74 18                	je     8006d3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006be:	8d 50 04             	lea    0x4(%eax),%edx
  8006c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c4:	8b 00                	mov    (%eax),%eax
  8006c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c9:	89 c1                	mov    %eax,%ecx
  8006cb:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ce:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006d1:	eb 16                	jmp    8006e9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	8d 50 04             	lea    0x4(%eax),%edx
  8006d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006dc:	8b 00                	mov    (%eax),%eax
  8006de:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e1:	89 c1                	mov    %eax,%ecx
  8006e3:	c1 f9 1f             	sar    $0x1f,%ecx
  8006e6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006e9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006ec:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006ef:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006f4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006f8:	79 74                	jns    80076e <vprintfmt+0x356>
				putch('-', putdat);
  8006fa:	83 ec 08             	sub    $0x8,%esp
  8006fd:	53                   	push   %ebx
  8006fe:	6a 2d                	push   $0x2d
  800700:	ff d6                	call   *%esi
				num = -(long long) num;
  800702:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800705:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800708:	f7 d8                	neg    %eax
  80070a:	83 d2 00             	adc    $0x0,%edx
  80070d:	f7 da                	neg    %edx
  80070f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800712:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800717:	eb 55                	jmp    80076e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800719:	8d 45 14             	lea    0x14(%ebp),%eax
  80071c:	e8 83 fc ff ff       	call   8003a4 <getuint>
			base = 10;
  800721:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800726:	eb 46                	jmp    80076e <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800728:	8d 45 14             	lea    0x14(%ebp),%eax
  80072b:	e8 74 fc ff ff       	call   8003a4 <getuint>
			base = 8;
  800730:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800735:	eb 37                	jmp    80076e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800737:	83 ec 08             	sub    $0x8,%esp
  80073a:	53                   	push   %ebx
  80073b:	6a 30                	push   $0x30
  80073d:	ff d6                	call   *%esi
			putch('x', putdat);
  80073f:	83 c4 08             	add    $0x8,%esp
  800742:	53                   	push   %ebx
  800743:	6a 78                	push   $0x78
  800745:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800747:	8b 45 14             	mov    0x14(%ebp),%eax
  80074a:	8d 50 04             	lea    0x4(%eax),%edx
  80074d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800750:	8b 00                	mov    (%eax),%eax
  800752:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800757:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80075a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80075f:	eb 0d                	jmp    80076e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800761:	8d 45 14             	lea    0x14(%ebp),%eax
  800764:	e8 3b fc ff ff       	call   8003a4 <getuint>
			base = 16;
  800769:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80076e:	83 ec 0c             	sub    $0xc,%esp
  800771:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800775:	57                   	push   %edi
  800776:	ff 75 e0             	pushl  -0x20(%ebp)
  800779:	51                   	push   %ecx
  80077a:	52                   	push   %edx
  80077b:	50                   	push   %eax
  80077c:	89 da                	mov    %ebx,%edx
  80077e:	89 f0                	mov    %esi,%eax
  800780:	e8 70 fb ff ff       	call   8002f5 <printnum>
			break;
  800785:	83 c4 20             	add    $0x20,%esp
  800788:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80078b:	e9 ae fc ff ff       	jmp    80043e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800790:	83 ec 08             	sub    $0x8,%esp
  800793:	53                   	push   %ebx
  800794:	51                   	push   %ecx
  800795:	ff d6                	call   *%esi
			break;
  800797:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80079d:	e9 9c fc ff ff       	jmp    80043e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007a2:	83 ec 08             	sub    $0x8,%esp
  8007a5:	53                   	push   %ebx
  8007a6:	6a 25                	push   $0x25
  8007a8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007aa:	83 c4 10             	add    $0x10,%esp
  8007ad:	eb 03                	jmp    8007b2 <vprintfmt+0x39a>
  8007af:	83 ef 01             	sub    $0x1,%edi
  8007b2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007b6:	75 f7                	jne    8007af <vprintfmt+0x397>
  8007b8:	e9 81 fc ff ff       	jmp    80043e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007c0:	5b                   	pop    %ebx
  8007c1:	5e                   	pop    %esi
  8007c2:	5f                   	pop    %edi
  8007c3:	5d                   	pop    %ebp
  8007c4:	c3                   	ret    

008007c5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	83 ec 18             	sub    $0x18,%esp
  8007cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ce:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007d4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007d8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007e2:	85 c0                	test   %eax,%eax
  8007e4:	74 26                	je     80080c <vsnprintf+0x47>
  8007e6:	85 d2                	test   %edx,%edx
  8007e8:	7e 22                	jle    80080c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007ea:	ff 75 14             	pushl  0x14(%ebp)
  8007ed:	ff 75 10             	pushl  0x10(%ebp)
  8007f0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007f3:	50                   	push   %eax
  8007f4:	68 de 03 80 00       	push   $0x8003de
  8007f9:	e8 1a fc ff ff       	call   800418 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800801:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800804:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800807:	83 c4 10             	add    $0x10,%esp
  80080a:	eb 05                	jmp    800811 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80080c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800811:	c9                   	leave  
  800812:	c3                   	ret    

00800813 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800819:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80081c:	50                   	push   %eax
  80081d:	ff 75 10             	pushl  0x10(%ebp)
  800820:	ff 75 0c             	pushl  0xc(%ebp)
  800823:	ff 75 08             	pushl  0x8(%ebp)
  800826:	e8 9a ff ff ff       	call   8007c5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80082b:	c9                   	leave  
  80082c:	c3                   	ret    

0080082d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800833:	b8 00 00 00 00       	mov    $0x0,%eax
  800838:	eb 03                	jmp    80083d <strlen+0x10>
		n++;
  80083a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80083d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800841:	75 f7                	jne    80083a <strlen+0xd>
		n++;
	return n;
}
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80084e:	ba 00 00 00 00       	mov    $0x0,%edx
  800853:	eb 03                	jmp    800858 <strnlen+0x13>
		n++;
  800855:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800858:	39 c2                	cmp    %eax,%edx
  80085a:	74 08                	je     800864 <strnlen+0x1f>
  80085c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800860:	75 f3                	jne    800855 <strnlen+0x10>
  800862:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800864:	5d                   	pop    %ebp
  800865:	c3                   	ret    

00800866 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	53                   	push   %ebx
  80086a:	8b 45 08             	mov    0x8(%ebp),%eax
  80086d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800870:	89 c2                	mov    %eax,%edx
  800872:	83 c2 01             	add    $0x1,%edx
  800875:	83 c1 01             	add    $0x1,%ecx
  800878:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80087c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80087f:	84 db                	test   %bl,%bl
  800881:	75 ef                	jne    800872 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800883:	5b                   	pop    %ebx
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	53                   	push   %ebx
  80088a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80088d:	53                   	push   %ebx
  80088e:	e8 9a ff ff ff       	call   80082d <strlen>
  800893:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800896:	ff 75 0c             	pushl  0xc(%ebp)
  800899:	01 d8                	add    %ebx,%eax
  80089b:	50                   	push   %eax
  80089c:	e8 c5 ff ff ff       	call   800866 <strcpy>
	return dst;
}
  8008a1:	89 d8                	mov    %ebx,%eax
  8008a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a6:	c9                   	leave  
  8008a7:	c3                   	ret    

008008a8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	56                   	push   %esi
  8008ac:	53                   	push   %ebx
  8008ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b3:	89 f3                	mov    %esi,%ebx
  8008b5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b8:	89 f2                	mov    %esi,%edx
  8008ba:	eb 0f                	jmp    8008cb <strncpy+0x23>
		*dst++ = *src;
  8008bc:	83 c2 01             	add    $0x1,%edx
  8008bf:	0f b6 01             	movzbl (%ecx),%eax
  8008c2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008c5:	80 39 01             	cmpb   $0x1,(%ecx)
  8008c8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008cb:	39 da                	cmp    %ebx,%edx
  8008cd:	75 ed                	jne    8008bc <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008cf:	89 f0                	mov    %esi,%eax
  8008d1:	5b                   	pop    %ebx
  8008d2:	5e                   	pop    %esi
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	56                   	push   %esi
  8008d9:	53                   	push   %ebx
  8008da:	8b 75 08             	mov    0x8(%ebp),%esi
  8008dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e0:	8b 55 10             	mov    0x10(%ebp),%edx
  8008e3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e5:	85 d2                	test   %edx,%edx
  8008e7:	74 21                	je     80090a <strlcpy+0x35>
  8008e9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008ed:	89 f2                	mov    %esi,%edx
  8008ef:	eb 09                	jmp    8008fa <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008f1:	83 c2 01             	add    $0x1,%edx
  8008f4:	83 c1 01             	add    $0x1,%ecx
  8008f7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008fa:	39 c2                	cmp    %eax,%edx
  8008fc:	74 09                	je     800907 <strlcpy+0x32>
  8008fe:	0f b6 19             	movzbl (%ecx),%ebx
  800901:	84 db                	test   %bl,%bl
  800903:	75 ec                	jne    8008f1 <strlcpy+0x1c>
  800905:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800907:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80090a:	29 f0                	sub    %esi,%eax
}
  80090c:	5b                   	pop    %ebx
  80090d:	5e                   	pop    %esi
  80090e:	5d                   	pop    %ebp
  80090f:	c3                   	ret    

00800910 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800916:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800919:	eb 06                	jmp    800921 <strcmp+0x11>
		p++, q++;
  80091b:	83 c1 01             	add    $0x1,%ecx
  80091e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800921:	0f b6 01             	movzbl (%ecx),%eax
  800924:	84 c0                	test   %al,%al
  800926:	74 04                	je     80092c <strcmp+0x1c>
  800928:	3a 02                	cmp    (%edx),%al
  80092a:	74 ef                	je     80091b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80092c:	0f b6 c0             	movzbl %al,%eax
  80092f:	0f b6 12             	movzbl (%edx),%edx
  800932:	29 d0                	sub    %edx,%eax
}
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	53                   	push   %ebx
  80093a:	8b 45 08             	mov    0x8(%ebp),%eax
  80093d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800940:	89 c3                	mov    %eax,%ebx
  800942:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800945:	eb 06                	jmp    80094d <strncmp+0x17>
		n--, p++, q++;
  800947:	83 c0 01             	add    $0x1,%eax
  80094a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80094d:	39 d8                	cmp    %ebx,%eax
  80094f:	74 15                	je     800966 <strncmp+0x30>
  800951:	0f b6 08             	movzbl (%eax),%ecx
  800954:	84 c9                	test   %cl,%cl
  800956:	74 04                	je     80095c <strncmp+0x26>
  800958:	3a 0a                	cmp    (%edx),%cl
  80095a:	74 eb                	je     800947 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80095c:	0f b6 00             	movzbl (%eax),%eax
  80095f:	0f b6 12             	movzbl (%edx),%edx
  800962:	29 d0                	sub    %edx,%eax
  800964:	eb 05                	jmp    80096b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800966:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80096b:	5b                   	pop    %ebx
  80096c:	5d                   	pop    %ebp
  80096d:	c3                   	ret    

0080096e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
  800974:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800978:	eb 07                	jmp    800981 <strchr+0x13>
		if (*s == c)
  80097a:	38 ca                	cmp    %cl,%dl
  80097c:	74 0f                	je     80098d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80097e:	83 c0 01             	add    $0x1,%eax
  800981:	0f b6 10             	movzbl (%eax),%edx
  800984:	84 d2                	test   %dl,%dl
  800986:	75 f2                	jne    80097a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800988:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80098d:	5d                   	pop    %ebp
  80098e:	c3                   	ret    

0080098f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	8b 45 08             	mov    0x8(%ebp),%eax
  800995:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800999:	eb 03                	jmp    80099e <strfind+0xf>
  80099b:	83 c0 01             	add    $0x1,%eax
  80099e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009a1:	38 ca                	cmp    %cl,%dl
  8009a3:	74 04                	je     8009a9 <strfind+0x1a>
  8009a5:	84 d2                	test   %dl,%dl
  8009a7:	75 f2                	jne    80099b <strfind+0xc>
			break;
	return (char *) s;
}
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	57                   	push   %edi
  8009af:	56                   	push   %esi
  8009b0:	53                   	push   %ebx
  8009b1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009b7:	85 c9                	test   %ecx,%ecx
  8009b9:	74 36                	je     8009f1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009bb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009c1:	75 28                	jne    8009eb <memset+0x40>
  8009c3:	f6 c1 03             	test   $0x3,%cl
  8009c6:	75 23                	jne    8009eb <memset+0x40>
		c &= 0xFF;
  8009c8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009cc:	89 d3                	mov    %edx,%ebx
  8009ce:	c1 e3 08             	shl    $0x8,%ebx
  8009d1:	89 d6                	mov    %edx,%esi
  8009d3:	c1 e6 18             	shl    $0x18,%esi
  8009d6:	89 d0                	mov    %edx,%eax
  8009d8:	c1 e0 10             	shl    $0x10,%eax
  8009db:	09 f0                	or     %esi,%eax
  8009dd:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009df:	89 d8                	mov    %ebx,%eax
  8009e1:	09 d0                	or     %edx,%eax
  8009e3:	c1 e9 02             	shr    $0x2,%ecx
  8009e6:	fc                   	cld    
  8009e7:	f3 ab                	rep stos %eax,%es:(%edi)
  8009e9:	eb 06                	jmp    8009f1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ee:	fc                   	cld    
  8009ef:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009f1:	89 f8                	mov    %edi,%eax
  8009f3:	5b                   	pop    %ebx
  8009f4:	5e                   	pop    %esi
  8009f5:	5f                   	pop    %edi
  8009f6:	5d                   	pop    %ebp
  8009f7:	c3                   	ret    

008009f8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	57                   	push   %edi
  8009fc:	56                   	push   %esi
  8009fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800a00:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a03:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a06:	39 c6                	cmp    %eax,%esi
  800a08:	73 35                	jae    800a3f <memmove+0x47>
  800a0a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a0d:	39 d0                	cmp    %edx,%eax
  800a0f:	73 2e                	jae    800a3f <memmove+0x47>
		s += n;
		d += n;
  800a11:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a14:	89 d6                	mov    %edx,%esi
  800a16:	09 fe                	or     %edi,%esi
  800a18:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a1e:	75 13                	jne    800a33 <memmove+0x3b>
  800a20:	f6 c1 03             	test   $0x3,%cl
  800a23:	75 0e                	jne    800a33 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a25:	83 ef 04             	sub    $0x4,%edi
  800a28:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a2b:	c1 e9 02             	shr    $0x2,%ecx
  800a2e:	fd                   	std    
  800a2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a31:	eb 09                	jmp    800a3c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a33:	83 ef 01             	sub    $0x1,%edi
  800a36:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a39:	fd                   	std    
  800a3a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a3c:	fc                   	cld    
  800a3d:	eb 1d                	jmp    800a5c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3f:	89 f2                	mov    %esi,%edx
  800a41:	09 c2                	or     %eax,%edx
  800a43:	f6 c2 03             	test   $0x3,%dl
  800a46:	75 0f                	jne    800a57 <memmove+0x5f>
  800a48:	f6 c1 03             	test   $0x3,%cl
  800a4b:	75 0a                	jne    800a57 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a4d:	c1 e9 02             	shr    $0x2,%ecx
  800a50:	89 c7                	mov    %eax,%edi
  800a52:	fc                   	cld    
  800a53:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a55:	eb 05                	jmp    800a5c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a57:	89 c7                	mov    %eax,%edi
  800a59:	fc                   	cld    
  800a5a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a5c:	5e                   	pop    %esi
  800a5d:	5f                   	pop    %edi
  800a5e:	5d                   	pop    %ebp
  800a5f:	c3                   	ret    

00800a60 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a63:	ff 75 10             	pushl  0x10(%ebp)
  800a66:	ff 75 0c             	pushl  0xc(%ebp)
  800a69:	ff 75 08             	pushl  0x8(%ebp)
  800a6c:	e8 87 ff ff ff       	call   8009f8 <memmove>
}
  800a71:	c9                   	leave  
  800a72:	c3                   	ret    

00800a73 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	56                   	push   %esi
  800a77:	53                   	push   %ebx
  800a78:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7e:	89 c6                	mov    %eax,%esi
  800a80:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a83:	eb 1a                	jmp    800a9f <memcmp+0x2c>
		if (*s1 != *s2)
  800a85:	0f b6 08             	movzbl (%eax),%ecx
  800a88:	0f b6 1a             	movzbl (%edx),%ebx
  800a8b:	38 d9                	cmp    %bl,%cl
  800a8d:	74 0a                	je     800a99 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a8f:	0f b6 c1             	movzbl %cl,%eax
  800a92:	0f b6 db             	movzbl %bl,%ebx
  800a95:	29 d8                	sub    %ebx,%eax
  800a97:	eb 0f                	jmp    800aa8 <memcmp+0x35>
		s1++, s2++;
  800a99:	83 c0 01             	add    $0x1,%eax
  800a9c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a9f:	39 f0                	cmp    %esi,%eax
  800aa1:	75 e2                	jne    800a85 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aa3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa8:	5b                   	pop    %ebx
  800aa9:	5e                   	pop    %esi
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	53                   	push   %ebx
  800ab0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ab3:	89 c1                	mov    %eax,%ecx
  800ab5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ab8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800abc:	eb 0a                	jmp    800ac8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800abe:	0f b6 10             	movzbl (%eax),%edx
  800ac1:	39 da                	cmp    %ebx,%edx
  800ac3:	74 07                	je     800acc <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ac5:	83 c0 01             	add    $0x1,%eax
  800ac8:	39 c8                	cmp    %ecx,%eax
  800aca:	72 f2                	jb     800abe <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800acc:	5b                   	pop    %ebx
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	57                   	push   %edi
  800ad3:	56                   	push   %esi
  800ad4:	53                   	push   %ebx
  800ad5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800adb:	eb 03                	jmp    800ae0 <strtol+0x11>
		s++;
  800add:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ae0:	0f b6 01             	movzbl (%ecx),%eax
  800ae3:	3c 20                	cmp    $0x20,%al
  800ae5:	74 f6                	je     800add <strtol+0xe>
  800ae7:	3c 09                	cmp    $0x9,%al
  800ae9:	74 f2                	je     800add <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aeb:	3c 2b                	cmp    $0x2b,%al
  800aed:	75 0a                	jne    800af9 <strtol+0x2a>
		s++;
  800aef:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800af2:	bf 00 00 00 00       	mov    $0x0,%edi
  800af7:	eb 11                	jmp    800b0a <strtol+0x3b>
  800af9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800afe:	3c 2d                	cmp    $0x2d,%al
  800b00:	75 08                	jne    800b0a <strtol+0x3b>
		s++, neg = 1;
  800b02:	83 c1 01             	add    $0x1,%ecx
  800b05:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b0a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b10:	75 15                	jne    800b27 <strtol+0x58>
  800b12:	80 39 30             	cmpb   $0x30,(%ecx)
  800b15:	75 10                	jne    800b27 <strtol+0x58>
  800b17:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b1b:	75 7c                	jne    800b99 <strtol+0xca>
		s += 2, base = 16;
  800b1d:	83 c1 02             	add    $0x2,%ecx
  800b20:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b25:	eb 16                	jmp    800b3d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b27:	85 db                	test   %ebx,%ebx
  800b29:	75 12                	jne    800b3d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b2b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b30:	80 39 30             	cmpb   $0x30,(%ecx)
  800b33:	75 08                	jne    800b3d <strtol+0x6e>
		s++, base = 8;
  800b35:	83 c1 01             	add    $0x1,%ecx
  800b38:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b42:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b45:	0f b6 11             	movzbl (%ecx),%edx
  800b48:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b4b:	89 f3                	mov    %esi,%ebx
  800b4d:	80 fb 09             	cmp    $0x9,%bl
  800b50:	77 08                	ja     800b5a <strtol+0x8b>
			dig = *s - '0';
  800b52:	0f be d2             	movsbl %dl,%edx
  800b55:	83 ea 30             	sub    $0x30,%edx
  800b58:	eb 22                	jmp    800b7c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b5a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b5d:	89 f3                	mov    %esi,%ebx
  800b5f:	80 fb 19             	cmp    $0x19,%bl
  800b62:	77 08                	ja     800b6c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b64:	0f be d2             	movsbl %dl,%edx
  800b67:	83 ea 57             	sub    $0x57,%edx
  800b6a:	eb 10                	jmp    800b7c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b6c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b6f:	89 f3                	mov    %esi,%ebx
  800b71:	80 fb 19             	cmp    $0x19,%bl
  800b74:	77 16                	ja     800b8c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b76:	0f be d2             	movsbl %dl,%edx
  800b79:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b7c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b7f:	7d 0b                	jge    800b8c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b81:	83 c1 01             	add    $0x1,%ecx
  800b84:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b88:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b8a:	eb b9                	jmp    800b45 <strtol+0x76>

	if (endptr)
  800b8c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b90:	74 0d                	je     800b9f <strtol+0xd0>
		*endptr = (char *) s;
  800b92:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b95:	89 0e                	mov    %ecx,(%esi)
  800b97:	eb 06                	jmp    800b9f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b99:	85 db                	test   %ebx,%ebx
  800b9b:	74 98                	je     800b35 <strtol+0x66>
  800b9d:	eb 9e                	jmp    800b3d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b9f:	89 c2                	mov    %eax,%edx
  800ba1:	f7 da                	neg    %edx
  800ba3:	85 ff                	test   %edi,%edi
  800ba5:	0f 45 c2             	cmovne %edx,%eax
}
  800ba8:	5b                   	pop    %ebx
  800ba9:	5e                   	pop    %esi
  800baa:	5f                   	pop    %edi
  800bab:	5d                   	pop    %ebp
  800bac:	c3                   	ret    

00800bad <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	57                   	push   %edi
  800bb1:	56                   	push   %esi
  800bb2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbe:	89 c3                	mov    %eax,%ebx
  800bc0:	89 c7                	mov    %eax,%edi
  800bc2:	89 c6                	mov    %eax,%esi
  800bc4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bc6:	5b                   	pop    %ebx
  800bc7:	5e                   	pop    %esi
  800bc8:	5f                   	pop    %edi
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <sys_cgetc>:

int
sys_cgetc(void)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	57                   	push   %edi
  800bcf:	56                   	push   %esi
  800bd0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd1:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd6:	b8 01 00 00 00       	mov    $0x1,%eax
  800bdb:	89 d1                	mov    %edx,%ecx
  800bdd:	89 d3                	mov    %edx,%ebx
  800bdf:	89 d7                	mov    %edx,%edi
  800be1:	89 d6                	mov    %edx,%esi
  800be3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800be5:	5b                   	pop    %ebx
  800be6:	5e                   	pop    %esi
  800be7:	5f                   	pop    %edi
  800be8:	5d                   	pop    %ebp
  800be9:	c3                   	ret    

00800bea <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	57                   	push   %edi
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
  800bf0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf8:	b8 03 00 00 00       	mov    $0x3,%eax
  800bfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800c00:	89 cb                	mov    %ecx,%ebx
  800c02:	89 cf                	mov    %ecx,%edi
  800c04:	89 ce                	mov    %ecx,%esi
  800c06:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c08:	85 c0                	test   %eax,%eax
  800c0a:	7e 17                	jle    800c23 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0c:	83 ec 0c             	sub    $0xc,%esp
  800c0f:	50                   	push   %eax
  800c10:	6a 03                	push   $0x3
  800c12:	68 df 29 80 00       	push   $0x8029df
  800c17:	6a 23                	push   $0x23
  800c19:	68 fc 29 80 00       	push   $0x8029fc
  800c1e:	e8 e5 f5 ff ff       	call   800208 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c26:	5b                   	pop    %ebx
  800c27:	5e                   	pop    %esi
  800c28:	5f                   	pop    %edi
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	57                   	push   %edi
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c31:	ba 00 00 00 00       	mov    $0x0,%edx
  800c36:	b8 02 00 00 00       	mov    $0x2,%eax
  800c3b:	89 d1                	mov    %edx,%ecx
  800c3d:	89 d3                	mov    %edx,%ebx
  800c3f:	89 d7                	mov    %edx,%edi
  800c41:	89 d6                	mov    %edx,%esi
  800c43:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <sys_yield>:

void
sys_yield(void)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	57                   	push   %edi
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c50:	ba 00 00 00 00       	mov    $0x0,%edx
  800c55:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c5a:	89 d1                	mov    %edx,%ecx
  800c5c:	89 d3                	mov    %edx,%ebx
  800c5e:	89 d7                	mov    %edx,%edi
  800c60:	89 d6                	mov    %edx,%esi
  800c62:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c64:	5b                   	pop    %ebx
  800c65:	5e                   	pop    %esi
  800c66:	5f                   	pop    %edi
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	57                   	push   %edi
  800c6d:	56                   	push   %esi
  800c6e:	53                   	push   %ebx
  800c6f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c72:	be 00 00 00 00       	mov    $0x0,%esi
  800c77:	b8 04 00 00 00       	mov    $0x4,%eax
  800c7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c82:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c85:	89 f7                	mov    %esi,%edi
  800c87:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c89:	85 c0                	test   %eax,%eax
  800c8b:	7e 17                	jle    800ca4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8d:	83 ec 0c             	sub    $0xc,%esp
  800c90:	50                   	push   %eax
  800c91:	6a 04                	push   $0x4
  800c93:	68 df 29 80 00       	push   $0x8029df
  800c98:	6a 23                	push   $0x23
  800c9a:	68 fc 29 80 00       	push   $0x8029fc
  800c9f:	e8 64 f5 ff ff       	call   800208 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ca4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca7:	5b                   	pop    %ebx
  800ca8:	5e                   	pop    %esi
  800ca9:	5f                   	pop    %edi
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    

00800cac <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	57                   	push   %edi
  800cb0:	56                   	push   %esi
  800cb1:	53                   	push   %ebx
  800cb2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb5:	b8 05 00 00 00       	mov    $0x5,%eax
  800cba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc6:	8b 75 18             	mov    0x18(%ebp),%esi
  800cc9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ccb:	85 c0                	test   %eax,%eax
  800ccd:	7e 17                	jle    800ce6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccf:	83 ec 0c             	sub    $0xc,%esp
  800cd2:	50                   	push   %eax
  800cd3:	6a 05                	push   $0x5
  800cd5:	68 df 29 80 00       	push   $0x8029df
  800cda:	6a 23                	push   $0x23
  800cdc:	68 fc 29 80 00       	push   $0x8029fc
  800ce1:	e8 22 f5 ff ff       	call   800208 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ce6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5f                   	pop    %edi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    

00800cee <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	57                   	push   %edi
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
  800cf4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfc:	b8 06 00 00 00       	mov    $0x6,%eax
  800d01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d04:	8b 55 08             	mov    0x8(%ebp),%edx
  800d07:	89 df                	mov    %ebx,%edi
  800d09:	89 de                	mov    %ebx,%esi
  800d0b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0d:	85 c0                	test   %eax,%eax
  800d0f:	7e 17                	jle    800d28 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d11:	83 ec 0c             	sub    $0xc,%esp
  800d14:	50                   	push   %eax
  800d15:	6a 06                	push   $0x6
  800d17:	68 df 29 80 00       	push   $0x8029df
  800d1c:	6a 23                	push   $0x23
  800d1e:	68 fc 29 80 00       	push   $0x8029fc
  800d23:	e8 e0 f4 ff ff       	call   800208 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
  800d36:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d39:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3e:	b8 08 00 00 00       	mov    $0x8,%eax
  800d43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d46:	8b 55 08             	mov    0x8(%ebp),%edx
  800d49:	89 df                	mov    %ebx,%edi
  800d4b:	89 de                	mov    %ebx,%esi
  800d4d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	7e 17                	jle    800d6a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d53:	83 ec 0c             	sub    $0xc,%esp
  800d56:	50                   	push   %eax
  800d57:	6a 08                	push   $0x8
  800d59:	68 df 29 80 00       	push   $0x8029df
  800d5e:	6a 23                	push   $0x23
  800d60:	68 fc 29 80 00       	push   $0x8029fc
  800d65:	e8 9e f4 ff ff       	call   800208 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6d:	5b                   	pop    %ebx
  800d6e:	5e                   	pop    %esi
  800d6f:	5f                   	pop    %edi
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	57                   	push   %edi
  800d76:	56                   	push   %esi
  800d77:	53                   	push   %ebx
  800d78:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d80:	b8 09 00 00 00       	mov    $0x9,%eax
  800d85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d88:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8b:	89 df                	mov    %ebx,%edi
  800d8d:	89 de                	mov    %ebx,%esi
  800d8f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d91:	85 c0                	test   %eax,%eax
  800d93:	7e 17                	jle    800dac <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d95:	83 ec 0c             	sub    $0xc,%esp
  800d98:	50                   	push   %eax
  800d99:	6a 09                	push   $0x9
  800d9b:	68 df 29 80 00       	push   $0x8029df
  800da0:	6a 23                	push   $0x23
  800da2:	68 fc 29 80 00       	push   $0x8029fc
  800da7:	e8 5c f4 ff ff       	call   800208 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    

00800db4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	57                   	push   %edi
  800db8:	56                   	push   %esi
  800db9:	53                   	push   %ebx
  800dba:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dca:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcd:	89 df                	mov    %ebx,%edi
  800dcf:	89 de                	mov    %ebx,%esi
  800dd1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	7e 17                	jle    800dee <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd7:	83 ec 0c             	sub    $0xc,%esp
  800dda:	50                   	push   %eax
  800ddb:	6a 0a                	push   $0xa
  800ddd:	68 df 29 80 00       	push   $0x8029df
  800de2:	6a 23                	push   $0x23
  800de4:	68 fc 29 80 00       	push   $0x8029fc
  800de9:	e8 1a f4 ff ff       	call   800208 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df1:	5b                   	pop    %ebx
  800df2:	5e                   	pop    %esi
  800df3:	5f                   	pop    %edi
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	57                   	push   %edi
  800dfa:	56                   	push   %esi
  800dfb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfc:	be 00 00 00 00       	mov    $0x0,%esi
  800e01:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e09:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e0f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e12:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e14:	5b                   	pop    %ebx
  800e15:	5e                   	pop    %esi
  800e16:	5f                   	pop    %edi
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    

00800e19 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	57                   	push   %edi
  800e1d:	56                   	push   %esi
  800e1e:	53                   	push   %ebx
  800e1f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e22:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e27:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2f:	89 cb                	mov    %ecx,%ebx
  800e31:	89 cf                	mov    %ecx,%edi
  800e33:	89 ce                	mov    %ecx,%esi
  800e35:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e37:	85 c0                	test   %eax,%eax
  800e39:	7e 17                	jle    800e52 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3b:	83 ec 0c             	sub    $0xc,%esp
  800e3e:	50                   	push   %eax
  800e3f:	6a 0d                	push   $0xd
  800e41:	68 df 29 80 00       	push   $0x8029df
  800e46:	6a 23                	push   $0x23
  800e48:	68 fc 29 80 00       	push   $0x8029fc
  800e4d:	e8 b6 f3 ff ff       	call   800208 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e55:	5b                   	pop    %ebx
  800e56:	5e                   	pop    %esi
  800e57:	5f                   	pop    %edi
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    

00800e5a <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	57                   	push   %edi
  800e5e:	56                   	push   %esi
  800e5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e60:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e65:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6d:	89 cb                	mov    %ecx,%ebx
  800e6f:	89 cf                	mov    %ecx,%edi
  800e71:	89 ce                	mov    %ecx,%esi
  800e73:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800e75:	5b                   	pop    %ebx
  800e76:	5e                   	pop    %esi
  800e77:	5f                   	pop    %edi
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    

00800e7a <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	57                   	push   %edi
  800e7e:	56                   	push   %esi
  800e7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e80:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e85:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8d:	89 cb                	mov    %ecx,%ebx
  800e8f:	89 cf                	mov    %ecx,%edi
  800e91:	89 ce                	mov    %ecx,%esi
  800e93:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800e95:	5b                   	pop    %ebx
  800e96:	5e                   	pop    %esi
  800e97:	5f                   	pop    %edi
  800e98:	5d                   	pop    %ebp
  800e99:	c3                   	ret    

00800e9a <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	57                   	push   %edi
  800e9e:	56                   	push   %esi
  800e9f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ea5:	b8 10 00 00 00       	mov    $0x10,%eax
  800eaa:	8b 55 08             	mov    0x8(%ebp),%edx
  800ead:	89 cb                	mov    %ecx,%ebx
  800eaf:	89 cf                	mov    %ecx,%edi
  800eb1:	89 ce                	mov    %ecx,%esi
  800eb3:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800eb5:	5b                   	pop    %ebx
  800eb6:	5e                   	pop    %esi
  800eb7:	5f                   	pop    %edi
  800eb8:	5d                   	pop    %ebp
  800eb9:	c3                   	ret    

00800eba <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	53                   	push   %ebx
  800ebe:	83 ec 04             	sub    $0x4,%esp
  800ec1:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ec4:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800ec6:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800eca:	74 11                	je     800edd <pgfault+0x23>
  800ecc:	89 d8                	mov    %ebx,%eax
  800ece:	c1 e8 0c             	shr    $0xc,%eax
  800ed1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ed8:	f6 c4 08             	test   $0x8,%ah
  800edb:	75 14                	jne    800ef1 <pgfault+0x37>
		panic("faulting access");
  800edd:	83 ec 04             	sub    $0x4,%esp
  800ee0:	68 0a 2a 80 00       	push   $0x802a0a
  800ee5:	6a 1f                	push   $0x1f
  800ee7:	68 1a 2a 80 00       	push   $0x802a1a
  800eec:	e8 17 f3 ff ff       	call   800208 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800ef1:	83 ec 04             	sub    $0x4,%esp
  800ef4:	6a 07                	push   $0x7
  800ef6:	68 00 f0 7f 00       	push   $0x7ff000
  800efb:	6a 00                	push   $0x0
  800efd:	e8 67 fd ff ff       	call   800c69 <sys_page_alloc>
	if (r < 0) {
  800f02:	83 c4 10             	add    $0x10,%esp
  800f05:	85 c0                	test   %eax,%eax
  800f07:	79 12                	jns    800f1b <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800f09:	50                   	push   %eax
  800f0a:	68 25 2a 80 00       	push   $0x802a25
  800f0f:	6a 2d                	push   $0x2d
  800f11:	68 1a 2a 80 00       	push   $0x802a1a
  800f16:	e8 ed f2 ff ff       	call   800208 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800f1b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800f21:	83 ec 04             	sub    $0x4,%esp
  800f24:	68 00 10 00 00       	push   $0x1000
  800f29:	53                   	push   %ebx
  800f2a:	68 00 f0 7f 00       	push   $0x7ff000
  800f2f:	e8 2c fb ff ff       	call   800a60 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800f34:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f3b:	53                   	push   %ebx
  800f3c:	6a 00                	push   $0x0
  800f3e:	68 00 f0 7f 00       	push   $0x7ff000
  800f43:	6a 00                	push   $0x0
  800f45:	e8 62 fd ff ff       	call   800cac <sys_page_map>
	if (r < 0) {
  800f4a:	83 c4 20             	add    $0x20,%esp
  800f4d:	85 c0                	test   %eax,%eax
  800f4f:	79 12                	jns    800f63 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800f51:	50                   	push   %eax
  800f52:	68 25 2a 80 00       	push   $0x802a25
  800f57:	6a 34                	push   $0x34
  800f59:	68 1a 2a 80 00       	push   $0x802a1a
  800f5e:	e8 a5 f2 ff ff       	call   800208 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800f63:	83 ec 08             	sub    $0x8,%esp
  800f66:	68 00 f0 7f 00       	push   $0x7ff000
  800f6b:	6a 00                	push   $0x0
  800f6d:	e8 7c fd ff ff       	call   800cee <sys_page_unmap>
	if (r < 0) {
  800f72:	83 c4 10             	add    $0x10,%esp
  800f75:	85 c0                	test   %eax,%eax
  800f77:	79 12                	jns    800f8b <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800f79:	50                   	push   %eax
  800f7a:	68 25 2a 80 00       	push   $0x802a25
  800f7f:	6a 38                	push   $0x38
  800f81:	68 1a 2a 80 00       	push   $0x802a1a
  800f86:	e8 7d f2 ff ff       	call   800208 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800f8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f8e:	c9                   	leave  
  800f8f:	c3                   	ret    

00800f90 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	57                   	push   %edi
  800f94:	56                   	push   %esi
  800f95:	53                   	push   %ebx
  800f96:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800f99:	68 ba 0e 80 00       	push   $0x800eba
  800f9e:	e8 24 12 00 00       	call   8021c7 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fa3:	b8 07 00 00 00       	mov    $0x7,%eax
  800fa8:	cd 30                	int    $0x30
  800faa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800fad:	83 c4 10             	add    $0x10,%esp
  800fb0:	85 c0                	test   %eax,%eax
  800fb2:	79 17                	jns    800fcb <fork+0x3b>
		panic("fork fault %e");
  800fb4:	83 ec 04             	sub    $0x4,%esp
  800fb7:	68 3e 2a 80 00       	push   $0x802a3e
  800fbc:	68 85 00 00 00       	push   $0x85
  800fc1:	68 1a 2a 80 00       	push   $0x802a1a
  800fc6:	e8 3d f2 ff ff       	call   800208 <_panic>
  800fcb:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800fcd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fd1:	75 24                	jne    800ff7 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fd3:	e8 53 fc ff ff       	call   800c2b <sys_getenvid>
  800fd8:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fdd:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800fe3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fe8:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800fed:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff2:	e9 64 01 00 00       	jmp    80115b <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800ff7:	83 ec 04             	sub    $0x4,%esp
  800ffa:	6a 07                	push   $0x7
  800ffc:	68 00 f0 bf ee       	push   $0xeebff000
  801001:	ff 75 e4             	pushl  -0x1c(%ebp)
  801004:	e8 60 fc ff ff       	call   800c69 <sys_page_alloc>
  801009:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80100c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801011:	89 d8                	mov    %ebx,%eax
  801013:	c1 e8 16             	shr    $0x16,%eax
  801016:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80101d:	a8 01                	test   $0x1,%al
  80101f:	0f 84 fc 00 00 00    	je     801121 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  801025:	89 d8                	mov    %ebx,%eax
  801027:	c1 e8 0c             	shr    $0xc,%eax
  80102a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801031:	f6 c2 01             	test   $0x1,%dl
  801034:	0f 84 e7 00 00 00    	je     801121 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80103a:	89 c6                	mov    %eax,%esi
  80103c:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  80103f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801046:	f6 c6 04             	test   $0x4,%dh
  801049:	74 39                	je     801084 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80104b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801052:	83 ec 0c             	sub    $0xc,%esp
  801055:	25 07 0e 00 00       	and    $0xe07,%eax
  80105a:	50                   	push   %eax
  80105b:	56                   	push   %esi
  80105c:	57                   	push   %edi
  80105d:	56                   	push   %esi
  80105e:	6a 00                	push   $0x0
  801060:	e8 47 fc ff ff       	call   800cac <sys_page_map>
		if (r < 0) {
  801065:	83 c4 20             	add    $0x20,%esp
  801068:	85 c0                	test   %eax,%eax
  80106a:	0f 89 b1 00 00 00    	jns    801121 <fork+0x191>
		    	panic("sys page map fault %e");
  801070:	83 ec 04             	sub    $0x4,%esp
  801073:	68 4c 2a 80 00       	push   $0x802a4c
  801078:	6a 55                	push   $0x55
  80107a:	68 1a 2a 80 00       	push   $0x802a1a
  80107f:	e8 84 f1 ff ff       	call   800208 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801084:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80108b:	f6 c2 02             	test   $0x2,%dl
  80108e:	75 0c                	jne    80109c <fork+0x10c>
  801090:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801097:	f6 c4 08             	test   $0x8,%ah
  80109a:	74 5b                	je     8010f7 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80109c:	83 ec 0c             	sub    $0xc,%esp
  80109f:	68 05 08 00 00       	push   $0x805
  8010a4:	56                   	push   %esi
  8010a5:	57                   	push   %edi
  8010a6:	56                   	push   %esi
  8010a7:	6a 00                	push   $0x0
  8010a9:	e8 fe fb ff ff       	call   800cac <sys_page_map>
		if (r < 0) {
  8010ae:	83 c4 20             	add    $0x20,%esp
  8010b1:	85 c0                	test   %eax,%eax
  8010b3:	79 14                	jns    8010c9 <fork+0x139>
		    	panic("sys page map fault %e");
  8010b5:	83 ec 04             	sub    $0x4,%esp
  8010b8:	68 4c 2a 80 00       	push   $0x802a4c
  8010bd:	6a 5c                	push   $0x5c
  8010bf:	68 1a 2a 80 00       	push   $0x802a1a
  8010c4:	e8 3f f1 ff ff       	call   800208 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8010c9:	83 ec 0c             	sub    $0xc,%esp
  8010cc:	68 05 08 00 00       	push   $0x805
  8010d1:	56                   	push   %esi
  8010d2:	6a 00                	push   $0x0
  8010d4:	56                   	push   %esi
  8010d5:	6a 00                	push   $0x0
  8010d7:	e8 d0 fb ff ff       	call   800cac <sys_page_map>
		if (r < 0) {
  8010dc:	83 c4 20             	add    $0x20,%esp
  8010df:	85 c0                	test   %eax,%eax
  8010e1:	79 3e                	jns    801121 <fork+0x191>
		    	panic("sys page map fault %e");
  8010e3:	83 ec 04             	sub    $0x4,%esp
  8010e6:	68 4c 2a 80 00       	push   $0x802a4c
  8010eb:	6a 60                	push   $0x60
  8010ed:	68 1a 2a 80 00       	push   $0x802a1a
  8010f2:	e8 11 f1 ff ff       	call   800208 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8010f7:	83 ec 0c             	sub    $0xc,%esp
  8010fa:	6a 05                	push   $0x5
  8010fc:	56                   	push   %esi
  8010fd:	57                   	push   %edi
  8010fe:	56                   	push   %esi
  8010ff:	6a 00                	push   $0x0
  801101:	e8 a6 fb ff ff       	call   800cac <sys_page_map>
		if (r < 0) {
  801106:	83 c4 20             	add    $0x20,%esp
  801109:	85 c0                	test   %eax,%eax
  80110b:	79 14                	jns    801121 <fork+0x191>
		    	panic("sys page map fault %e");
  80110d:	83 ec 04             	sub    $0x4,%esp
  801110:	68 4c 2a 80 00       	push   $0x802a4c
  801115:	6a 65                	push   $0x65
  801117:	68 1a 2a 80 00       	push   $0x802a1a
  80111c:	e8 e7 f0 ff ff       	call   800208 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801121:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801127:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80112d:	0f 85 de fe ff ff    	jne    801011 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801133:	a1 08 40 80 00       	mov    0x804008,%eax
  801138:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  80113e:	83 ec 08             	sub    $0x8,%esp
  801141:	50                   	push   %eax
  801142:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801145:	57                   	push   %edi
  801146:	e8 69 fc ff ff       	call   800db4 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80114b:	83 c4 08             	add    $0x8,%esp
  80114e:	6a 02                	push   $0x2
  801150:	57                   	push   %edi
  801151:	e8 da fb ff ff       	call   800d30 <sys_env_set_status>
	
	return envid;
  801156:	83 c4 10             	add    $0x10,%esp
  801159:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80115b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115e:	5b                   	pop    %ebx
  80115f:	5e                   	pop    %esi
  801160:	5f                   	pop    %edi
  801161:	5d                   	pop    %ebp
  801162:	c3                   	ret    

00801163 <sfork>:

envid_t
sfork(void)
{
  801163:	55                   	push   %ebp
  801164:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801166:	b8 00 00 00 00       	mov    $0x0,%eax
  80116b:	5d                   	pop    %ebp
  80116c:	c3                   	ret    

0080116d <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  80116d:	55                   	push   %ebp
  80116e:	89 e5                	mov    %esp,%ebp
  801170:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  801173:	8b 45 08             	mov    0x8(%ebp),%eax
  801176:	a3 0c 40 80 00       	mov    %eax,0x80400c
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80117b:	68 ce 01 80 00       	push   $0x8001ce
  801180:	e8 d5 fc ff ff       	call   800e5a <sys_thread_create>

	return id;
}
  801185:	c9                   	leave  
  801186:	c3                   	ret    

00801187 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  80118d:	ff 75 08             	pushl  0x8(%ebp)
  801190:	e8 e5 fc ff ff       	call   800e7a <sys_thread_free>
}
  801195:	83 c4 10             	add    $0x10,%esp
  801198:	c9                   	leave  
  801199:	c3                   	ret    

0080119a <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  80119a:	55                   	push   %ebp
  80119b:	89 e5                	mov    %esp,%ebp
  80119d:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  8011a0:	ff 75 08             	pushl  0x8(%ebp)
  8011a3:	e8 f2 fc ff ff       	call   800e9a <sys_thread_join>
}
  8011a8:	83 c4 10             	add    $0x10,%esp
  8011ab:	c9                   	leave  
  8011ac:	c3                   	ret    

008011ad <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  8011ad:	55                   	push   %ebp
  8011ae:	89 e5                	mov    %esp,%ebp
  8011b0:	56                   	push   %esi
  8011b1:	53                   	push   %ebx
  8011b2:	8b 75 08             	mov    0x8(%ebp),%esi
  8011b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8011b8:	83 ec 04             	sub    $0x4,%esp
  8011bb:	6a 07                	push   $0x7
  8011bd:	6a 00                	push   $0x0
  8011bf:	56                   	push   %esi
  8011c0:	e8 a4 fa ff ff       	call   800c69 <sys_page_alloc>
	if (r < 0) {
  8011c5:	83 c4 10             	add    $0x10,%esp
  8011c8:	85 c0                	test   %eax,%eax
  8011ca:	79 15                	jns    8011e1 <queue_append+0x34>
		panic("%e\n", r);
  8011cc:	50                   	push   %eax
  8011cd:	68 92 2a 80 00       	push   $0x802a92
  8011d2:	68 d5 00 00 00       	push   $0xd5
  8011d7:	68 1a 2a 80 00       	push   $0x802a1a
  8011dc:	e8 27 f0 ff ff       	call   800208 <_panic>
	}	

	wt->envid = envid;
  8011e1:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  8011e7:	83 3b 00             	cmpl   $0x0,(%ebx)
  8011ea:	75 13                	jne    8011ff <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  8011ec:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  8011f3:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8011fa:	00 00 00 
  8011fd:	eb 1b                	jmp    80121a <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  8011ff:	8b 43 04             	mov    0x4(%ebx),%eax
  801202:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  801209:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801210:	00 00 00 
		queue->last = wt;
  801213:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80121a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80121d:	5b                   	pop    %ebx
  80121e:	5e                   	pop    %esi
  80121f:	5d                   	pop    %ebp
  801220:	c3                   	ret    

00801221 <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
  801224:	83 ec 08             	sub    $0x8,%esp
  801227:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  80122a:	8b 02                	mov    (%edx),%eax
  80122c:	85 c0                	test   %eax,%eax
  80122e:	75 17                	jne    801247 <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  801230:	83 ec 04             	sub    $0x4,%esp
  801233:	68 62 2a 80 00       	push   $0x802a62
  801238:	68 ec 00 00 00       	push   $0xec
  80123d:	68 1a 2a 80 00       	push   $0x802a1a
  801242:	e8 c1 ef ff ff       	call   800208 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  801247:	8b 48 04             	mov    0x4(%eax),%ecx
  80124a:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  80124c:	8b 00                	mov    (%eax),%eax
}
  80124e:	c9                   	leave  
  80124f:	c3                   	ret    

00801250 <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	56                   	push   %esi
  801254:	53                   	push   %ebx
  801255:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801258:	b8 01 00 00 00       	mov    $0x1,%eax
  80125d:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801260:	85 c0                	test   %eax,%eax
  801262:	74 4a                	je     8012ae <mutex_lock+0x5e>
  801264:	8b 73 04             	mov    0x4(%ebx),%esi
  801267:	83 3e 00             	cmpl   $0x0,(%esi)
  80126a:	75 42                	jne    8012ae <mutex_lock+0x5e>
		queue_append(sys_getenvid(), mtx->queue);		
  80126c:	e8 ba f9 ff ff       	call   800c2b <sys_getenvid>
  801271:	83 ec 08             	sub    $0x8,%esp
  801274:	56                   	push   %esi
  801275:	50                   	push   %eax
  801276:	e8 32 ff ff ff       	call   8011ad <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  80127b:	e8 ab f9 ff ff       	call   800c2b <sys_getenvid>
  801280:	83 c4 08             	add    $0x8,%esp
  801283:	6a 04                	push   $0x4
  801285:	50                   	push   %eax
  801286:	e8 a5 fa ff ff       	call   800d30 <sys_env_set_status>

		if (r < 0) {
  80128b:	83 c4 10             	add    $0x10,%esp
  80128e:	85 c0                	test   %eax,%eax
  801290:	79 15                	jns    8012a7 <mutex_lock+0x57>
			panic("%e\n", r);
  801292:	50                   	push   %eax
  801293:	68 92 2a 80 00       	push   $0x802a92
  801298:	68 02 01 00 00       	push   $0x102
  80129d:	68 1a 2a 80 00       	push   $0x802a1a
  8012a2:	e8 61 ef ff ff       	call   800208 <_panic>
		}
		sys_yield();
  8012a7:	e8 9e f9 ff ff       	call   800c4a <sys_yield>
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8012ac:	eb 08                	jmp    8012b6 <mutex_lock+0x66>
		if (r < 0) {
			panic("%e\n", r);
		}
		sys_yield();
	} else {
		mtx->owner = sys_getenvid();
  8012ae:	e8 78 f9 ff ff       	call   800c2b <sys_getenvid>
  8012b3:	89 43 08             	mov    %eax,0x8(%ebx)
	}
}
  8012b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012b9:	5b                   	pop    %ebx
  8012ba:	5e                   	pop    %esi
  8012bb:	5d                   	pop    %ebp
  8012bc:	c3                   	ret    

008012bd <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
  8012c0:	53                   	push   %ebx
  8012c1:	83 ec 04             	sub    $0x4,%esp
  8012c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8012cc:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  8012cf:	8b 43 04             	mov    0x4(%ebx),%eax
  8012d2:	83 38 00             	cmpl   $0x0,(%eax)
  8012d5:	74 33                	je     80130a <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  8012d7:	83 ec 0c             	sub    $0xc,%esp
  8012da:	50                   	push   %eax
  8012db:	e8 41 ff ff ff       	call   801221 <queue_pop>
  8012e0:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8012e3:	83 c4 08             	add    $0x8,%esp
  8012e6:	6a 02                	push   $0x2
  8012e8:	50                   	push   %eax
  8012e9:	e8 42 fa ff ff       	call   800d30 <sys_env_set_status>
		if (r < 0) {
  8012ee:	83 c4 10             	add    $0x10,%esp
  8012f1:	85 c0                	test   %eax,%eax
  8012f3:	79 15                	jns    80130a <mutex_unlock+0x4d>
			panic("%e\n", r);
  8012f5:	50                   	push   %eax
  8012f6:	68 92 2a 80 00       	push   $0x802a92
  8012fb:	68 16 01 00 00       	push   $0x116
  801300:	68 1a 2a 80 00       	push   $0x802a1a
  801305:	e8 fe ee ff ff       	call   800208 <_panic>
		}
	}

	//asm volatile("pause"); 	// might be useless here
}
  80130a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80130d:	c9                   	leave  
  80130e:	c3                   	ret    

0080130f <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  80130f:	55                   	push   %ebp
  801310:	89 e5                	mov    %esp,%ebp
  801312:	53                   	push   %ebx
  801313:	83 ec 04             	sub    $0x4,%esp
  801316:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  801319:	e8 0d f9 ff ff       	call   800c2b <sys_getenvid>
  80131e:	83 ec 04             	sub    $0x4,%esp
  801321:	6a 07                	push   $0x7
  801323:	53                   	push   %ebx
  801324:	50                   	push   %eax
  801325:	e8 3f f9 ff ff       	call   800c69 <sys_page_alloc>
  80132a:	83 c4 10             	add    $0x10,%esp
  80132d:	85 c0                	test   %eax,%eax
  80132f:	79 15                	jns    801346 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  801331:	50                   	push   %eax
  801332:	68 7d 2a 80 00       	push   $0x802a7d
  801337:	68 22 01 00 00       	push   $0x122
  80133c:	68 1a 2a 80 00       	push   $0x802a1a
  801341:	e8 c2 ee ff ff       	call   800208 <_panic>
	}	
	mtx->locked = 0;
  801346:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  80134c:	8b 43 04             	mov    0x4(%ebx),%eax
  80134f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  801355:	8b 43 04             	mov    0x4(%ebx),%eax
  801358:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  80135f:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  801366:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801369:	c9                   	leave  
  80136a:	c3                   	ret    

0080136b <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
  80136e:	53                   	push   %ebx
  80136f:	83 ec 04             	sub    $0x4,%esp
  801372:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue->first != NULL) {
  801375:	eb 21                	jmp    801398 <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
  801377:	83 ec 0c             	sub    $0xc,%esp
  80137a:	50                   	push   %eax
  80137b:	e8 a1 fe ff ff       	call   801221 <queue_pop>
  801380:	83 c4 08             	add    $0x8,%esp
  801383:	6a 02                	push   $0x2
  801385:	50                   	push   %eax
  801386:	e8 a5 f9 ff ff       	call   800d30 <sys_env_set_status>
		mtx->queue->first = mtx->queue->first->next;
  80138b:	8b 43 04             	mov    0x4(%ebx),%eax
  80138e:	8b 10                	mov    (%eax),%edx
  801390:	8b 52 04             	mov    0x4(%edx),%edx
  801393:	89 10                	mov    %edx,(%eax)
  801395:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue->first != NULL) {
  801398:	8b 43 04             	mov    0x4(%ebx),%eax
  80139b:	83 38 00             	cmpl   $0x0,(%eax)
  80139e:	75 d7                	jne    801377 <mutex_destroy+0xc>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
		mtx->queue->first = mtx->queue->first->next;
	}

	memset(mtx, 0, PGSIZE);
  8013a0:	83 ec 04             	sub    $0x4,%esp
  8013a3:	68 00 10 00 00       	push   $0x1000
  8013a8:	6a 00                	push   $0x0
  8013aa:	53                   	push   %ebx
  8013ab:	e8 fb f5 ff ff       	call   8009ab <memset>
	mtx = NULL;
}
  8013b0:	83 c4 10             	add    $0x10,%esp
  8013b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013b6:	c9                   	leave  
  8013b7:	c3                   	ret    

008013b8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013b8:	55                   	push   %ebp
  8013b9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8013be:	05 00 00 00 30       	add    $0x30000000,%eax
  8013c3:	c1 e8 0c             	shr    $0xc,%eax
}
  8013c6:	5d                   	pop    %ebp
  8013c7:	c3                   	ret    

008013c8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013c8:	55                   	push   %ebp
  8013c9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8013cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ce:	05 00 00 00 30       	add    $0x30000000,%eax
  8013d3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013d8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013dd:	5d                   	pop    %ebp
  8013de:	c3                   	ret    

008013df <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
  8013e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013e5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013ea:	89 c2                	mov    %eax,%edx
  8013ec:	c1 ea 16             	shr    $0x16,%edx
  8013ef:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013f6:	f6 c2 01             	test   $0x1,%dl
  8013f9:	74 11                	je     80140c <fd_alloc+0x2d>
  8013fb:	89 c2                	mov    %eax,%edx
  8013fd:	c1 ea 0c             	shr    $0xc,%edx
  801400:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801407:	f6 c2 01             	test   $0x1,%dl
  80140a:	75 09                	jne    801415 <fd_alloc+0x36>
			*fd_store = fd;
  80140c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80140e:	b8 00 00 00 00       	mov    $0x0,%eax
  801413:	eb 17                	jmp    80142c <fd_alloc+0x4d>
  801415:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80141a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80141f:	75 c9                	jne    8013ea <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801421:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801427:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80142c:	5d                   	pop    %ebp
  80142d:	c3                   	ret    

0080142e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
  801431:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801434:	83 f8 1f             	cmp    $0x1f,%eax
  801437:	77 36                	ja     80146f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801439:	c1 e0 0c             	shl    $0xc,%eax
  80143c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801441:	89 c2                	mov    %eax,%edx
  801443:	c1 ea 16             	shr    $0x16,%edx
  801446:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80144d:	f6 c2 01             	test   $0x1,%dl
  801450:	74 24                	je     801476 <fd_lookup+0x48>
  801452:	89 c2                	mov    %eax,%edx
  801454:	c1 ea 0c             	shr    $0xc,%edx
  801457:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80145e:	f6 c2 01             	test   $0x1,%dl
  801461:	74 1a                	je     80147d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801463:	8b 55 0c             	mov    0xc(%ebp),%edx
  801466:	89 02                	mov    %eax,(%edx)
	return 0;
  801468:	b8 00 00 00 00       	mov    $0x0,%eax
  80146d:	eb 13                	jmp    801482 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80146f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801474:	eb 0c                	jmp    801482 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801476:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80147b:	eb 05                	jmp    801482 <fd_lookup+0x54>
  80147d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801482:	5d                   	pop    %ebp
  801483:	c3                   	ret    

00801484 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801484:	55                   	push   %ebp
  801485:	89 e5                	mov    %esp,%ebp
  801487:	83 ec 08             	sub    $0x8,%esp
  80148a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80148d:	ba 18 2b 80 00       	mov    $0x802b18,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801492:	eb 13                	jmp    8014a7 <dev_lookup+0x23>
  801494:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801497:	39 08                	cmp    %ecx,(%eax)
  801499:	75 0c                	jne    8014a7 <dev_lookup+0x23>
			*dev = devtab[i];
  80149b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80149e:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8014a5:	eb 31                	jmp    8014d8 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014a7:	8b 02                	mov    (%edx),%eax
  8014a9:	85 c0                	test   %eax,%eax
  8014ab:	75 e7                	jne    801494 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014ad:	a1 08 40 80 00       	mov    0x804008,%eax
  8014b2:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8014b8:	83 ec 04             	sub    $0x4,%esp
  8014bb:	51                   	push   %ecx
  8014bc:	50                   	push   %eax
  8014bd:	68 98 2a 80 00       	push   $0x802a98
  8014c2:	e8 1a ee ff ff       	call   8002e1 <cprintf>
	*dev = 0;
  8014c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ca:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014d0:	83 c4 10             	add    $0x10,%esp
  8014d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014d8:	c9                   	leave  
  8014d9:	c3                   	ret    

008014da <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014da:	55                   	push   %ebp
  8014db:	89 e5                	mov    %esp,%ebp
  8014dd:	56                   	push   %esi
  8014de:	53                   	push   %ebx
  8014df:	83 ec 10             	sub    $0x10,%esp
  8014e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8014e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014eb:	50                   	push   %eax
  8014ec:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014f2:	c1 e8 0c             	shr    $0xc,%eax
  8014f5:	50                   	push   %eax
  8014f6:	e8 33 ff ff ff       	call   80142e <fd_lookup>
  8014fb:	83 c4 08             	add    $0x8,%esp
  8014fe:	85 c0                	test   %eax,%eax
  801500:	78 05                	js     801507 <fd_close+0x2d>
	    || fd != fd2)
  801502:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801505:	74 0c                	je     801513 <fd_close+0x39>
		return (must_exist ? r : 0);
  801507:	84 db                	test   %bl,%bl
  801509:	ba 00 00 00 00       	mov    $0x0,%edx
  80150e:	0f 44 c2             	cmove  %edx,%eax
  801511:	eb 41                	jmp    801554 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801513:	83 ec 08             	sub    $0x8,%esp
  801516:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801519:	50                   	push   %eax
  80151a:	ff 36                	pushl  (%esi)
  80151c:	e8 63 ff ff ff       	call   801484 <dev_lookup>
  801521:	89 c3                	mov    %eax,%ebx
  801523:	83 c4 10             	add    $0x10,%esp
  801526:	85 c0                	test   %eax,%eax
  801528:	78 1a                	js     801544 <fd_close+0x6a>
		if (dev->dev_close)
  80152a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801530:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801535:	85 c0                	test   %eax,%eax
  801537:	74 0b                	je     801544 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801539:	83 ec 0c             	sub    $0xc,%esp
  80153c:	56                   	push   %esi
  80153d:	ff d0                	call   *%eax
  80153f:	89 c3                	mov    %eax,%ebx
  801541:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801544:	83 ec 08             	sub    $0x8,%esp
  801547:	56                   	push   %esi
  801548:	6a 00                	push   $0x0
  80154a:	e8 9f f7 ff ff       	call   800cee <sys_page_unmap>
	return r;
  80154f:	83 c4 10             	add    $0x10,%esp
  801552:	89 d8                	mov    %ebx,%eax
}
  801554:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801557:	5b                   	pop    %ebx
  801558:	5e                   	pop    %esi
  801559:	5d                   	pop    %ebp
  80155a:	c3                   	ret    

0080155b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801561:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801564:	50                   	push   %eax
  801565:	ff 75 08             	pushl  0x8(%ebp)
  801568:	e8 c1 fe ff ff       	call   80142e <fd_lookup>
  80156d:	83 c4 08             	add    $0x8,%esp
  801570:	85 c0                	test   %eax,%eax
  801572:	78 10                	js     801584 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801574:	83 ec 08             	sub    $0x8,%esp
  801577:	6a 01                	push   $0x1
  801579:	ff 75 f4             	pushl  -0xc(%ebp)
  80157c:	e8 59 ff ff ff       	call   8014da <fd_close>
  801581:	83 c4 10             	add    $0x10,%esp
}
  801584:	c9                   	leave  
  801585:	c3                   	ret    

00801586 <close_all>:

void
close_all(void)
{
  801586:	55                   	push   %ebp
  801587:	89 e5                	mov    %esp,%ebp
  801589:	53                   	push   %ebx
  80158a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80158d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801592:	83 ec 0c             	sub    $0xc,%esp
  801595:	53                   	push   %ebx
  801596:	e8 c0 ff ff ff       	call   80155b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80159b:	83 c3 01             	add    $0x1,%ebx
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	83 fb 20             	cmp    $0x20,%ebx
  8015a4:	75 ec                	jne    801592 <close_all+0xc>
		close(i);
}
  8015a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a9:	c9                   	leave  
  8015aa:	c3                   	ret    

008015ab <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015ab:	55                   	push   %ebp
  8015ac:	89 e5                	mov    %esp,%ebp
  8015ae:	57                   	push   %edi
  8015af:	56                   	push   %esi
  8015b0:	53                   	push   %ebx
  8015b1:	83 ec 2c             	sub    $0x2c,%esp
  8015b4:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015ba:	50                   	push   %eax
  8015bb:	ff 75 08             	pushl  0x8(%ebp)
  8015be:	e8 6b fe ff ff       	call   80142e <fd_lookup>
  8015c3:	83 c4 08             	add    $0x8,%esp
  8015c6:	85 c0                	test   %eax,%eax
  8015c8:	0f 88 c1 00 00 00    	js     80168f <dup+0xe4>
		return r;
	close(newfdnum);
  8015ce:	83 ec 0c             	sub    $0xc,%esp
  8015d1:	56                   	push   %esi
  8015d2:	e8 84 ff ff ff       	call   80155b <close>

	newfd = INDEX2FD(newfdnum);
  8015d7:	89 f3                	mov    %esi,%ebx
  8015d9:	c1 e3 0c             	shl    $0xc,%ebx
  8015dc:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8015e2:	83 c4 04             	add    $0x4,%esp
  8015e5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015e8:	e8 db fd ff ff       	call   8013c8 <fd2data>
  8015ed:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8015ef:	89 1c 24             	mov    %ebx,(%esp)
  8015f2:	e8 d1 fd ff ff       	call   8013c8 <fd2data>
  8015f7:	83 c4 10             	add    $0x10,%esp
  8015fa:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015fd:	89 f8                	mov    %edi,%eax
  8015ff:	c1 e8 16             	shr    $0x16,%eax
  801602:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801609:	a8 01                	test   $0x1,%al
  80160b:	74 37                	je     801644 <dup+0x99>
  80160d:	89 f8                	mov    %edi,%eax
  80160f:	c1 e8 0c             	shr    $0xc,%eax
  801612:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801619:	f6 c2 01             	test   $0x1,%dl
  80161c:	74 26                	je     801644 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80161e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801625:	83 ec 0c             	sub    $0xc,%esp
  801628:	25 07 0e 00 00       	and    $0xe07,%eax
  80162d:	50                   	push   %eax
  80162e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801631:	6a 00                	push   $0x0
  801633:	57                   	push   %edi
  801634:	6a 00                	push   $0x0
  801636:	e8 71 f6 ff ff       	call   800cac <sys_page_map>
  80163b:	89 c7                	mov    %eax,%edi
  80163d:	83 c4 20             	add    $0x20,%esp
  801640:	85 c0                	test   %eax,%eax
  801642:	78 2e                	js     801672 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801644:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801647:	89 d0                	mov    %edx,%eax
  801649:	c1 e8 0c             	shr    $0xc,%eax
  80164c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801653:	83 ec 0c             	sub    $0xc,%esp
  801656:	25 07 0e 00 00       	and    $0xe07,%eax
  80165b:	50                   	push   %eax
  80165c:	53                   	push   %ebx
  80165d:	6a 00                	push   $0x0
  80165f:	52                   	push   %edx
  801660:	6a 00                	push   $0x0
  801662:	e8 45 f6 ff ff       	call   800cac <sys_page_map>
  801667:	89 c7                	mov    %eax,%edi
  801669:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80166c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80166e:	85 ff                	test   %edi,%edi
  801670:	79 1d                	jns    80168f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801672:	83 ec 08             	sub    $0x8,%esp
  801675:	53                   	push   %ebx
  801676:	6a 00                	push   $0x0
  801678:	e8 71 f6 ff ff       	call   800cee <sys_page_unmap>
	sys_page_unmap(0, nva);
  80167d:	83 c4 08             	add    $0x8,%esp
  801680:	ff 75 d4             	pushl  -0x2c(%ebp)
  801683:	6a 00                	push   $0x0
  801685:	e8 64 f6 ff ff       	call   800cee <sys_page_unmap>
	return r;
  80168a:	83 c4 10             	add    $0x10,%esp
  80168d:	89 f8                	mov    %edi,%eax
}
  80168f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801692:	5b                   	pop    %ebx
  801693:	5e                   	pop    %esi
  801694:	5f                   	pop    %edi
  801695:	5d                   	pop    %ebp
  801696:	c3                   	ret    

00801697 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801697:	55                   	push   %ebp
  801698:	89 e5                	mov    %esp,%ebp
  80169a:	53                   	push   %ebx
  80169b:	83 ec 14             	sub    $0x14,%esp
  80169e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016a4:	50                   	push   %eax
  8016a5:	53                   	push   %ebx
  8016a6:	e8 83 fd ff ff       	call   80142e <fd_lookup>
  8016ab:	83 c4 08             	add    $0x8,%esp
  8016ae:	89 c2                	mov    %eax,%edx
  8016b0:	85 c0                	test   %eax,%eax
  8016b2:	78 70                	js     801724 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b4:	83 ec 08             	sub    $0x8,%esp
  8016b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ba:	50                   	push   %eax
  8016bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016be:	ff 30                	pushl  (%eax)
  8016c0:	e8 bf fd ff ff       	call   801484 <dev_lookup>
  8016c5:	83 c4 10             	add    $0x10,%esp
  8016c8:	85 c0                	test   %eax,%eax
  8016ca:	78 4f                	js     80171b <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016cf:	8b 42 08             	mov    0x8(%edx),%eax
  8016d2:	83 e0 03             	and    $0x3,%eax
  8016d5:	83 f8 01             	cmp    $0x1,%eax
  8016d8:	75 24                	jne    8016fe <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016da:	a1 08 40 80 00       	mov    0x804008,%eax
  8016df:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8016e5:	83 ec 04             	sub    $0x4,%esp
  8016e8:	53                   	push   %ebx
  8016e9:	50                   	push   %eax
  8016ea:	68 dc 2a 80 00       	push   $0x802adc
  8016ef:	e8 ed eb ff ff       	call   8002e1 <cprintf>
		return -E_INVAL;
  8016f4:	83 c4 10             	add    $0x10,%esp
  8016f7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016fc:	eb 26                	jmp    801724 <read+0x8d>
	}
	if (!dev->dev_read)
  8016fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801701:	8b 40 08             	mov    0x8(%eax),%eax
  801704:	85 c0                	test   %eax,%eax
  801706:	74 17                	je     80171f <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801708:	83 ec 04             	sub    $0x4,%esp
  80170b:	ff 75 10             	pushl  0x10(%ebp)
  80170e:	ff 75 0c             	pushl  0xc(%ebp)
  801711:	52                   	push   %edx
  801712:	ff d0                	call   *%eax
  801714:	89 c2                	mov    %eax,%edx
  801716:	83 c4 10             	add    $0x10,%esp
  801719:	eb 09                	jmp    801724 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80171b:	89 c2                	mov    %eax,%edx
  80171d:	eb 05                	jmp    801724 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80171f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801724:	89 d0                	mov    %edx,%eax
  801726:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801729:	c9                   	leave  
  80172a:	c3                   	ret    

0080172b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80172b:	55                   	push   %ebp
  80172c:	89 e5                	mov    %esp,%ebp
  80172e:	57                   	push   %edi
  80172f:	56                   	push   %esi
  801730:	53                   	push   %ebx
  801731:	83 ec 0c             	sub    $0xc,%esp
  801734:	8b 7d 08             	mov    0x8(%ebp),%edi
  801737:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80173a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80173f:	eb 21                	jmp    801762 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801741:	83 ec 04             	sub    $0x4,%esp
  801744:	89 f0                	mov    %esi,%eax
  801746:	29 d8                	sub    %ebx,%eax
  801748:	50                   	push   %eax
  801749:	89 d8                	mov    %ebx,%eax
  80174b:	03 45 0c             	add    0xc(%ebp),%eax
  80174e:	50                   	push   %eax
  80174f:	57                   	push   %edi
  801750:	e8 42 ff ff ff       	call   801697 <read>
		if (m < 0)
  801755:	83 c4 10             	add    $0x10,%esp
  801758:	85 c0                	test   %eax,%eax
  80175a:	78 10                	js     80176c <readn+0x41>
			return m;
		if (m == 0)
  80175c:	85 c0                	test   %eax,%eax
  80175e:	74 0a                	je     80176a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801760:	01 c3                	add    %eax,%ebx
  801762:	39 f3                	cmp    %esi,%ebx
  801764:	72 db                	jb     801741 <readn+0x16>
  801766:	89 d8                	mov    %ebx,%eax
  801768:	eb 02                	jmp    80176c <readn+0x41>
  80176a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80176c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80176f:	5b                   	pop    %ebx
  801770:	5e                   	pop    %esi
  801771:	5f                   	pop    %edi
  801772:	5d                   	pop    %ebp
  801773:	c3                   	ret    

00801774 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801774:	55                   	push   %ebp
  801775:	89 e5                	mov    %esp,%ebp
  801777:	53                   	push   %ebx
  801778:	83 ec 14             	sub    $0x14,%esp
  80177b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80177e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801781:	50                   	push   %eax
  801782:	53                   	push   %ebx
  801783:	e8 a6 fc ff ff       	call   80142e <fd_lookup>
  801788:	83 c4 08             	add    $0x8,%esp
  80178b:	89 c2                	mov    %eax,%edx
  80178d:	85 c0                	test   %eax,%eax
  80178f:	78 6b                	js     8017fc <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801791:	83 ec 08             	sub    $0x8,%esp
  801794:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801797:	50                   	push   %eax
  801798:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80179b:	ff 30                	pushl  (%eax)
  80179d:	e8 e2 fc ff ff       	call   801484 <dev_lookup>
  8017a2:	83 c4 10             	add    $0x10,%esp
  8017a5:	85 c0                	test   %eax,%eax
  8017a7:	78 4a                	js     8017f3 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ac:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017b0:	75 24                	jne    8017d6 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017b2:	a1 08 40 80 00       	mov    0x804008,%eax
  8017b7:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8017bd:	83 ec 04             	sub    $0x4,%esp
  8017c0:	53                   	push   %ebx
  8017c1:	50                   	push   %eax
  8017c2:	68 f8 2a 80 00       	push   $0x802af8
  8017c7:	e8 15 eb ff ff       	call   8002e1 <cprintf>
		return -E_INVAL;
  8017cc:	83 c4 10             	add    $0x10,%esp
  8017cf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017d4:	eb 26                	jmp    8017fc <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017d9:	8b 52 0c             	mov    0xc(%edx),%edx
  8017dc:	85 d2                	test   %edx,%edx
  8017de:	74 17                	je     8017f7 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017e0:	83 ec 04             	sub    $0x4,%esp
  8017e3:	ff 75 10             	pushl  0x10(%ebp)
  8017e6:	ff 75 0c             	pushl  0xc(%ebp)
  8017e9:	50                   	push   %eax
  8017ea:	ff d2                	call   *%edx
  8017ec:	89 c2                	mov    %eax,%edx
  8017ee:	83 c4 10             	add    $0x10,%esp
  8017f1:	eb 09                	jmp    8017fc <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f3:	89 c2                	mov    %eax,%edx
  8017f5:	eb 05                	jmp    8017fc <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017f7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8017fc:	89 d0                	mov    %edx,%eax
  8017fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801801:	c9                   	leave  
  801802:	c3                   	ret    

00801803 <seek>:

int
seek(int fdnum, off_t offset)
{
  801803:	55                   	push   %ebp
  801804:	89 e5                	mov    %esp,%ebp
  801806:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801809:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80180c:	50                   	push   %eax
  80180d:	ff 75 08             	pushl  0x8(%ebp)
  801810:	e8 19 fc ff ff       	call   80142e <fd_lookup>
  801815:	83 c4 08             	add    $0x8,%esp
  801818:	85 c0                	test   %eax,%eax
  80181a:	78 0e                	js     80182a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80181c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80181f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801822:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801825:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80182a:	c9                   	leave  
  80182b:	c3                   	ret    

0080182c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80182c:	55                   	push   %ebp
  80182d:	89 e5                	mov    %esp,%ebp
  80182f:	53                   	push   %ebx
  801830:	83 ec 14             	sub    $0x14,%esp
  801833:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801836:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801839:	50                   	push   %eax
  80183a:	53                   	push   %ebx
  80183b:	e8 ee fb ff ff       	call   80142e <fd_lookup>
  801840:	83 c4 08             	add    $0x8,%esp
  801843:	89 c2                	mov    %eax,%edx
  801845:	85 c0                	test   %eax,%eax
  801847:	78 68                	js     8018b1 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801849:	83 ec 08             	sub    $0x8,%esp
  80184c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80184f:	50                   	push   %eax
  801850:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801853:	ff 30                	pushl  (%eax)
  801855:	e8 2a fc ff ff       	call   801484 <dev_lookup>
  80185a:	83 c4 10             	add    $0x10,%esp
  80185d:	85 c0                	test   %eax,%eax
  80185f:	78 47                	js     8018a8 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801861:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801864:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801868:	75 24                	jne    80188e <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80186a:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80186f:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801875:	83 ec 04             	sub    $0x4,%esp
  801878:	53                   	push   %ebx
  801879:	50                   	push   %eax
  80187a:	68 b8 2a 80 00       	push   $0x802ab8
  80187f:	e8 5d ea ff ff       	call   8002e1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801884:	83 c4 10             	add    $0x10,%esp
  801887:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80188c:	eb 23                	jmp    8018b1 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  80188e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801891:	8b 52 18             	mov    0x18(%edx),%edx
  801894:	85 d2                	test   %edx,%edx
  801896:	74 14                	je     8018ac <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801898:	83 ec 08             	sub    $0x8,%esp
  80189b:	ff 75 0c             	pushl  0xc(%ebp)
  80189e:	50                   	push   %eax
  80189f:	ff d2                	call   *%edx
  8018a1:	89 c2                	mov    %eax,%edx
  8018a3:	83 c4 10             	add    $0x10,%esp
  8018a6:	eb 09                	jmp    8018b1 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a8:	89 c2                	mov    %eax,%edx
  8018aa:	eb 05                	jmp    8018b1 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8018b1:	89 d0                	mov    %edx,%eax
  8018b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b6:	c9                   	leave  
  8018b7:	c3                   	ret    

008018b8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018b8:	55                   	push   %ebp
  8018b9:	89 e5                	mov    %esp,%ebp
  8018bb:	53                   	push   %ebx
  8018bc:	83 ec 14             	sub    $0x14,%esp
  8018bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018c5:	50                   	push   %eax
  8018c6:	ff 75 08             	pushl  0x8(%ebp)
  8018c9:	e8 60 fb ff ff       	call   80142e <fd_lookup>
  8018ce:	83 c4 08             	add    $0x8,%esp
  8018d1:	89 c2                	mov    %eax,%edx
  8018d3:	85 c0                	test   %eax,%eax
  8018d5:	78 58                	js     80192f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018d7:	83 ec 08             	sub    $0x8,%esp
  8018da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018dd:	50                   	push   %eax
  8018de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e1:	ff 30                	pushl  (%eax)
  8018e3:	e8 9c fb ff ff       	call   801484 <dev_lookup>
  8018e8:	83 c4 10             	add    $0x10,%esp
  8018eb:	85 c0                	test   %eax,%eax
  8018ed:	78 37                	js     801926 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8018ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018f6:	74 32                	je     80192a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018f8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018fb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801902:	00 00 00 
	stat->st_isdir = 0;
  801905:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80190c:	00 00 00 
	stat->st_dev = dev;
  80190f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801915:	83 ec 08             	sub    $0x8,%esp
  801918:	53                   	push   %ebx
  801919:	ff 75 f0             	pushl  -0x10(%ebp)
  80191c:	ff 50 14             	call   *0x14(%eax)
  80191f:	89 c2                	mov    %eax,%edx
  801921:	83 c4 10             	add    $0x10,%esp
  801924:	eb 09                	jmp    80192f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801926:	89 c2                	mov    %eax,%edx
  801928:	eb 05                	jmp    80192f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80192a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80192f:	89 d0                	mov    %edx,%eax
  801931:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801934:	c9                   	leave  
  801935:	c3                   	ret    

00801936 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	56                   	push   %esi
  80193a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80193b:	83 ec 08             	sub    $0x8,%esp
  80193e:	6a 00                	push   $0x0
  801940:	ff 75 08             	pushl  0x8(%ebp)
  801943:	e8 e3 01 00 00       	call   801b2b <open>
  801948:	89 c3                	mov    %eax,%ebx
  80194a:	83 c4 10             	add    $0x10,%esp
  80194d:	85 c0                	test   %eax,%eax
  80194f:	78 1b                	js     80196c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801951:	83 ec 08             	sub    $0x8,%esp
  801954:	ff 75 0c             	pushl  0xc(%ebp)
  801957:	50                   	push   %eax
  801958:	e8 5b ff ff ff       	call   8018b8 <fstat>
  80195d:	89 c6                	mov    %eax,%esi
	close(fd);
  80195f:	89 1c 24             	mov    %ebx,(%esp)
  801962:	e8 f4 fb ff ff       	call   80155b <close>
	return r;
  801967:	83 c4 10             	add    $0x10,%esp
  80196a:	89 f0                	mov    %esi,%eax
}
  80196c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80196f:	5b                   	pop    %ebx
  801970:	5e                   	pop    %esi
  801971:	5d                   	pop    %ebp
  801972:	c3                   	ret    

00801973 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801973:	55                   	push   %ebp
  801974:	89 e5                	mov    %esp,%ebp
  801976:	56                   	push   %esi
  801977:	53                   	push   %ebx
  801978:	89 c6                	mov    %eax,%esi
  80197a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80197c:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801983:	75 12                	jne    801997 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801985:	83 ec 0c             	sub    $0xc,%esp
  801988:	6a 01                	push   $0x1
  80198a:	e8 a4 09 00 00       	call   802333 <ipc_find_env>
  80198f:	a3 04 40 80 00       	mov    %eax,0x804004
  801994:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801997:	6a 07                	push   $0x7
  801999:	68 00 50 80 00       	push   $0x805000
  80199e:	56                   	push   %esi
  80199f:	ff 35 04 40 80 00    	pushl  0x804004
  8019a5:	e8 27 09 00 00       	call   8022d1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019aa:	83 c4 0c             	add    $0xc,%esp
  8019ad:	6a 00                	push   $0x0
  8019af:	53                   	push   %ebx
  8019b0:	6a 00                	push   $0x0
  8019b2:	e8 9f 08 00 00       	call   802256 <ipc_recv>
}
  8019b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ba:	5b                   	pop    %ebx
  8019bb:	5e                   	pop    %esi
  8019bc:	5d                   	pop    %ebp
  8019bd:	c3                   	ret    

008019be <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019be:	55                   	push   %ebp
  8019bf:	89 e5                	mov    %esp,%ebp
  8019c1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c7:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ca:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8019cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019dc:	b8 02 00 00 00       	mov    $0x2,%eax
  8019e1:	e8 8d ff ff ff       	call   801973 <fsipc>
}
  8019e6:	c9                   	leave  
  8019e7:	c3                   	ret    

008019e8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019e8:	55                   	push   %ebp
  8019e9:	89 e5                	mov    %esp,%ebp
  8019eb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f1:	8b 40 0c             	mov    0xc(%eax),%eax
  8019f4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8019fe:	b8 06 00 00 00       	mov    $0x6,%eax
  801a03:	e8 6b ff ff ff       	call   801973 <fsipc>
}
  801a08:	c9                   	leave  
  801a09:	c3                   	ret    

00801a0a <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a0a:	55                   	push   %ebp
  801a0b:	89 e5                	mov    %esp,%ebp
  801a0d:	53                   	push   %ebx
  801a0e:	83 ec 04             	sub    $0x4,%esp
  801a11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a14:	8b 45 08             	mov    0x8(%ebp),%eax
  801a17:	8b 40 0c             	mov    0xc(%eax),%eax
  801a1a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a1f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a24:	b8 05 00 00 00       	mov    $0x5,%eax
  801a29:	e8 45 ff ff ff       	call   801973 <fsipc>
  801a2e:	85 c0                	test   %eax,%eax
  801a30:	78 2c                	js     801a5e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a32:	83 ec 08             	sub    $0x8,%esp
  801a35:	68 00 50 80 00       	push   $0x805000
  801a3a:	53                   	push   %ebx
  801a3b:	e8 26 ee ff ff       	call   800866 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a40:	a1 80 50 80 00       	mov    0x805080,%eax
  801a45:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a4b:	a1 84 50 80 00       	mov    0x805084,%eax
  801a50:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a56:	83 c4 10             	add    $0x10,%esp
  801a59:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a5e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a61:	c9                   	leave  
  801a62:	c3                   	ret    

00801a63 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a63:	55                   	push   %ebp
  801a64:	89 e5                	mov    %esp,%ebp
  801a66:	83 ec 0c             	sub    $0xc,%esp
  801a69:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a6c:	8b 55 08             	mov    0x8(%ebp),%edx
  801a6f:	8b 52 0c             	mov    0xc(%edx),%edx
  801a72:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801a78:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a7d:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a82:	0f 47 c2             	cmova  %edx,%eax
  801a85:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801a8a:	50                   	push   %eax
  801a8b:	ff 75 0c             	pushl  0xc(%ebp)
  801a8e:	68 08 50 80 00       	push   $0x805008
  801a93:	e8 60 ef ff ff       	call   8009f8 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801a98:	ba 00 00 00 00       	mov    $0x0,%edx
  801a9d:	b8 04 00 00 00       	mov    $0x4,%eax
  801aa2:	e8 cc fe ff ff       	call   801973 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801aa7:	c9                   	leave  
  801aa8:	c3                   	ret    

00801aa9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801aa9:	55                   	push   %ebp
  801aaa:	89 e5                	mov    %esp,%ebp
  801aac:	56                   	push   %esi
  801aad:	53                   	push   %ebx
  801aae:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ab1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab4:	8b 40 0c             	mov    0xc(%eax),%eax
  801ab7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801abc:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ac2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac7:	b8 03 00 00 00       	mov    $0x3,%eax
  801acc:	e8 a2 fe ff ff       	call   801973 <fsipc>
  801ad1:	89 c3                	mov    %eax,%ebx
  801ad3:	85 c0                	test   %eax,%eax
  801ad5:	78 4b                	js     801b22 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801ad7:	39 c6                	cmp    %eax,%esi
  801ad9:	73 16                	jae    801af1 <devfile_read+0x48>
  801adb:	68 28 2b 80 00       	push   $0x802b28
  801ae0:	68 2f 2b 80 00       	push   $0x802b2f
  801ae5:	6a 7c                	push   $0x7c
  801ae7:	68 44 2b 80 00       	push   $0x802b44
  801aec:	e8 17 e7 ff ff       	call   800208 <_panic>
	assert(r <= PGSIZE);
  801af1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801af6:	7e 16                	jle    801b0e <devfile_read+0x65>
  801af8:	68 4f 2b 80 00       	push   $0x802b4f
  801afd:	68 2f 2b 80 00       	push   $0x802b2f
  801b02:	6a 7d                	push   $0x7d
  801b04:	68 44 2b 80 00       	push   $0x802b44
  801b09:	e8 fa e6 ff ff       	call   800208 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b0e:	83 ec 04             	sub    $0x4,%esp
  801b11:	50                   	push   %eax
  801b12:	68 00 50 80 00       	push   $0x805000
  801b17:	ff 75 0c             	pushl  0xc(%ebp)
  801b1a:	e8 d9 ee ff ff       	call   8009f8 <memmove>
	return r;
  801b1f:	83 c4 10             	add    $0x10,%esp
}
  801b22:	89 d8                	mov    %ebx,%eax
  801b24:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b27:	5b                   	pop    %ebx
  801b28:	5e                   	pop    %esi
  801b29:	5d                   	pop    %ebp
  801b2a:	c3                   	ret    

00801b2b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	53                   	push   %ebx
  801b2f:	83 ec 20             	sub    $0x20,%esp
  801b32:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b35:	53                   	push   %ebx
  801b36:	e8 f2 ec ff ff       	call   80082d <strlen>
  801b3b:	83 c4 10             	add    $0x10,%esp
  801b3e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b43:	7f 67                	jg     801bac <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b45:	83 ec 0c             	sub    $0xc,%esp
  801b48:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b4b:	50                   	push   %eax
  801b4c:	e8 8e f8 ff ff       	call   8013df <fd_alloc>
  801b51:	83 c4 10             	add    $0x10,%esp
		return r;
  801b54:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b56:	85 c0                	test   %eax,%eax
  801b58:	78 57                	js     801bb1 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b5a:	83 ec 08             	sub    $0x8,%esp
  801b5d:	53                   	push   %ebx
  801b5e:	68 00 50 80 00       	push   $0x805000
  801b63:	e8 fe ec ff ff       	call   800866 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b68:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b6b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b70:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b73:	b8 01 00 00 00       	mov    $0x1,%eax
  801b78:	e8 f6 fd ff ff       	call   801973 <fsipc>
  801b7d:	89 c3                	mov    %eax,%ebx
  801b7f:	83 c4 10             	add    $0x10,%esp
  801b82:	85 c0                	test   %eax,%eax
  801b84:	79 14                	jns    801b9a <open+0x6f>
		fd_close(fd, 0);
  801b86:	83 ec 08             	sub    $0x8,%esp
  801b89:	6a 00                	push   $0x0
  801b8b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b8e:	e8 47 f9 ff ff       	call   8014da <fd_close>
		return r;
  801b93:	83 c4 10             	add    $0x10,%esp
  801b96:	89 da                	mov    %ebx,%edx
  801b98:	eb 17                	jmp    801bb1 <open+0x86>
	}

	return fd2num(fd);
  801b9a:	83 ec 0c             	sub    $0xc,%esp
  801b9d:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba0:	e8 13 f8 ff ff       	call   8013b8 <fd2num>
  801ba5:	89 c2                	mov    %eax,%edx
  801ba7:	83 c4 10             	add    $0x10,%esp
  801baa:	eb 05                	jmp    801bb1 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801bac:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801bb1:	89 d0                	mov    %edx,%eax
  801bb3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb6:	c9                   	leave  
  801bb7:	c3                   	ret    

00801bb8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bb8:	55                   	push   %ebp
  801bb9:	89 e5                	mov    %esp,%ebp
  801bbb:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bbe:	ba 00 00 00 00       	mov    $0x0,%edx
  801bc3:	b8 08 00 00 00       	mov    $0x8,%eax
  801bc8:	e8 a6 fd ff ff       	call   801973 <fsipc>
}
  801bcd:	c9                   	leave  
  801bce:	c3                   	ret    

00801bcf <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801bcf:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801bd3:	7e 37                	jle    801c0c <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801bd5:	55                   	push   %ebp
  801bd6:	89 e5                	mov    %esp,%ebp
  801bd8:	53                   	push   %ebx
  801bd9:	83 ec 08             	sub    $0x8,%esp
  801bdc:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801bde:	ff 70 04             	pushl  0x4(%eax)
  801be1:	8d 40 10             	lea    0x10(%eax),%eax
  801be4:	50                   	push   %eax
  801be5:	ff 33                	pushl  (%ebx)
  801be7:	e8 88 fb ff ff       	call   801774 <write>
		if (result > 0)
  801bec:	83 c4 10             	add    $0x10,%esp
  801bef:	85 c0                	test   %eax,%eax
  801bf1:	7e 03                	jle    801bf6 <writebuf+0x27>
			b->result += result;
  801bf3:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801bf6:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bf9:	74 0d                	je     801c08 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801bfb:	85 c0                	test   %eax,%eax
  801bfd:	ba 00 00 00 00       	mov    $0x0,%edx
  801c02:	0f 4f c2             	cmovg  %edx,%eax
  801c05:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801c08:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c0b:	c9                   	leave  
  801c0c:	f3 c3                	repz ret 

00801c0e <putch>:

static void
putch(int ch, void *thunk)
{
  801c0e:	55                   	push   %ebp
  801c0f:	89 e5                	mov    %esp,%ebp
  801c11:	53                   	push   %ebx
  801c12:	83 ec 04             	sub    $0x4,%esp
  801c15:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801c18:	8b 53 04             	mov    0x4(%ebx),%edx
  801c1b:	8d 42 01             	lea    0x1(%edx),%eax
  801c1e:	89 43 04             	mov    %eax,0x4(%ebx)
  801c21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c24:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801c28:	3d 00 01 00 00       	cmp    $0x100,%eax
  801c2d:	75 0e                	jne    801c3d <putch+0x2f>
		writebuf(b);
  801c2f:	89 d8                	mov    %ebx,%eax
  801c31:	e8 99 ff ff ff       	call   801bcf <writebuf>
		b->idx = 0;
  801c36:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801c3d:	83 c4 04             	add    $0x4,%esp
  801c40:	5b                   	pop    %ebx
  801c41:	5d                   	pop    %ebp
  801c42:	c3                   	ret    

00801c43 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801c43:	55                   	push   %ebp
  801c44:	89 e5                	mov    %esp,%ebp
  801c46:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801c4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4f:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801c55:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801c5c:	00 00 00 
	b.result = 0;
  801c5f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801c66:	00 00 00 
	b.error = 1;
  801c69:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801c70:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801c73:	ff 75 10             	pushl  0x10(%ebp)
  801c76:	ff 75 0c             	pushl  0xc(%ebp)
  801c79:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801c7f:	50                   	push   %eax
  801c80:	68 0e 1c 80 00       	push   $0x801c0e
  801c85:	e8 8e e7 ff ff       	call   800418 <vprintfmt>
	if (b.idx > 0)
  801c8a:	83 c4 10             	add    $0x10,%esp
  801c8d:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801c94:	7e 0b                	jle    801ca1 <vfprintf+0x5e>
		writebuf(&b);
  801c96:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801c9c:	e8 2e ff ff ff       	call   801bcf <writebuf>

	return (b.result ? b.result : b.error);
  801ca1:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801ca7:	85 c0                	test   %eax,%eax
  801ca9:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801cb0:	c9                   	leave  
  801cb1:	c3                   	ret    

00801cb2 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801cb2:	55                   	push   %ebp
  801cb3:	89 e5                	mov    %esp,%ebp
  801cb5:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801cb8:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801cbb:	50                   	push   %eax
  801cbc:	ff 75 0c             	pushl  0xc(%ebp)
  801cbf:	ff 75 08             	pushl  0x8(%ebp)
  801cc2:	e8 7c ff ff ff       	call   801c43 <vfprintf>
	va_end(ap);

	return cnt;
}
  801cc7:	c9                   	leave  
  801cc8:	c3                   	ret    

00801cc9 <printf>:

int
printf(const char *fmt, ...)
{
  801cc9:	55                   	push   %ebp
  801cca:	89 e5                	mov    %esp,%ebp
  801ccc:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801ccf:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801cd2:	50                   	push   %eax
  801cd3:	ff 75 08             	pushl  0x8(%ebp)
  801cd6:	6a 01                	push   $0x1
  801cd8:	e8 66 ff ff ff       	call   801c43 <vfprintf>
	va_end(ap);

	return cnt;
}
  801cdd:	c9                   	leave  
  801cde:	c3                   	ret    

00801cdf <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801cdf:	55                   	push   %ebp
  801ce0:	89 e5                	mov    %esp,%ebp
  801ce2:	56                   	push   %esi
  801ce3:	53                   	push   %ebx
  801ce4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ce7:	83 ec 0c             	sub    $0xc,%esp
  801cea:	ff 75 08             	pushl  0x8(%ebp)
  801ced:	e8 d6 f6 ff ff       	call   8013c8 <fd2data>
  801cf2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801cf4:	83 c4 08             	add    $0x8,%esp
  801cf7:	68 5b 2b 80 00       	push   $0x802b5b
  801cfc:	53                   	push   %ebx
  801cfd:	e8 64 eb ff ff       	call   800866 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d02:	8b 46 04             	mov    0x4(%esi),%eax
  801d05:	2b 06                	sub    (%esi),%eax
  801d07:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d0d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d14:	00 00 00 
	stat->st_dev = &devpipe;
  801d17:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801d1e:	30 80 00 
	return 0;
}
  801d21:	b8 00 00 00 00       	mov    $0x0,%eax
  801d26:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d29:	5b                   	pop    %ebx
  801d2a:	5e                   	pop    %esi
  801d2b:	5d                   	pop    %ebp
  801d2c:	c3                   	ret    

00801d2d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d2d:	55                   	push   %ebp
  801d2e:	89 e5                	mov    %esp,%ebp
  801d30:	53                   	push   %ebx
  801d31:	83 ec 0c             	sub    $0xc,%esp
  801d34:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d37:	53                   	push   %ebx
  801d38:	6a 00                	push   $0x0
  801d3a:	e8 af ef ff ff       	call   800cee <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d3f:	89 1c 24             	mov    %ebx,(%esp)
  801d42:	e8 81 f6 ff ff       	call   8013c8 <fd2data>
  801d47:	83 c4 08             	add    $0x8,%esp
  801d4a:	50                   	push   %eax
  801d4b:	6a 00                	push   $0x0
  801d4d:	e8 9c ef ff ff       	call   800cee <sys_page_unmap>
}
  801d52:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d55:	c9                   	leave  
  801d56:	c3                   	ret    

00801d57 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d57:	55                   	push   %ebp
  801d58:	89 e5                	mov    %esp,%ebp
  801d5a:	57                   	push   %edi
  801d5b:	56                   	push   %esi
  801d5c:	53                   	push   %ebx
  801d5d:	83 ec 1c             	sub    $0x1c,%esp
  801d60:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d63:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d65:	a1 08 40 80 00       	mov    0x804008,%eax
  801d6a:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d70:	83 ec 0c             	sub    $0xc,%esp
  801d73:	ff 75 e0             	pushl  -0x20(%ebp)
  801d76:	e8 fd 05 00 00       	call   802378 <pageref>
  801d7b:	89 c3                	mov    %eax,%ebx
  801d7d:	89 3c 24             	mov    %edi,(%esp)
  801d80:	e8 f3 05 00 00       	call   802378 <pageref>
  801d85:	83 c4 10             	add    $0x10,%esp
  801d88:	39 c3                	cmp    %eax,%ebx
  801d8a:	0f 94 c1             	sete   %cl
  801d8d:	0f b6 c9             	movzbl %cl,%ecx
  801d90:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d93:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801d99:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  801d9f:	39 ce                	cmp    %ecx,%esi
  801da1:	74 1e                	je     801dc1 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801da3:	39 c3                	cmp    %eax,%ebx
  801da5:	75 be                	jne    801d65 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801da7:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  801dad:	ff 75 e4             	pushl  -0x1c(%ebp)
  801db0:	50                   	push   %eax
  801db1:	56                   	push   %esi
  801db2:	68 62 2b 80 00       	push   $0x802b62
  801db7:	e8 25 e5 ff ff       	call   8002e1 <cprintf>
  801dbc:	83 c4 10             	add    $0x10,%esp
  801dbf:	eb a4                	jmp    801d65 <_pipeisclosed+0xe>
	}
}
  801dc1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dc7:	5b                   	pop    %ebx
  801dc8:	5e                   	pop    %esi
  801dc9:	5f                   	pop    %edi
  801dca:	5d                   	pop    %ebp
  801dcb:	c3                   	ret    

00801dcc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dcc:	55                   	push   %ebp
  801dcd:	89 e5                	mov    %esp,%ebp
  801dcf:	57                   	push   %edi
  801dd0:	56                   	push   %esi
  801dd1:	53                   	push   %ebx
  801dd2:	83 ec 28             	sub    $0x28,%esp
  801dd5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801dd8:	56                   	push   %esi
  801dd9:	e8 ea f5 ff ff       	call   8013c8 <fd2data>
  801dde:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801de0:	83 c4 10             	add    $0x10,%esp
  801de3:	bf 00 00 00 00       	mov    $0x0,%edi
  801de8:	eb 4b                	jmp    801e35 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801dea:	89 da                	mov    %ebx,%edx
  801dec:	89 f0                	mov    %esi,%eax
  801dee:	e8 64 ff ff ff       	call   801d57 <_pipeisclosed>
  801df3:	85 c0                	test   %eax,%eax
  801df5:	75 48                	jne    801e3f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801df7:	e8 4e ee ff ff       	call   800c4a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801dfc:	8b 43 04             	mov    0x4(%ebx),%eax
  801dff:	8b 0b                	mov    (%ebx),%ecx
  801e01:	8d 51 20             	lea    0x20(%ecx),%edx
  801e04:	39 d0                	cmp    %edx,%eax
  801e06:	73 e2                	jae    801dea <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e0b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e0f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e12:	89 c2                	mov    %eax,%edx
  801e14:	c1 fa 1f             	sar    $0x1f,%edx
  801e17:	89 d1                	mov    %edx,%ecx
  801e19:	c1 e9 1b             	shr    $0x1b,%ecx
  801e1c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e1f:	83 e2 1f             	and    $0x1f,%edx
  801e22:	29 ca                	sub    %ecx,%edx
  801e24:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e28:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e2c:	83 c0 01             	add    $0x1,%eax
  801e2f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e32:	83 c7 01             	add    $0x1,%edi
  801e35:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e38:	75 c2                	jne    801dfc <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e3a:	8b 45 10             	mov    0x10(%ebp),%eax
  801e3d:	eb 05                	jmp    801e44 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e3f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e47:	5b                   	pop    %ebx
  801e48:	5e                   	pop    %esi
  801e49:	5f                   	pop    %edi
  801e4a:	5d                   	pop    %ebp
  801e4b:	c3                   	ret    

00801e4c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e4c:	55                   	push   %ebp
  801e4d:	89 e5                	mov    %esp,%ebp
  801e4f:	57                   	push   %edi
  801e50:	56                   	push   %esi
  801e51:	53                   	push   %ebx
  801e52:	83 ec 18             	sub    $0x18,%esp
  801e55:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e58:	57                   	push   %edi
  801e59:	e8 6a f5 ff ff       	call   8013c8 <fd2data>
  801e5e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e60:	83 c4 10             	add    $0x10,%esp
  801e63:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e68:	eb 3d                	jmp    801ea7 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e6a:	85 db                	test   %ebx,%ebx
  801e6c:	74 04                	je     801e72 <devpipe_read+0x26>
				return i;
  801e6e:	89 d8                	mov    %ebx,%eax
  801e70:	eb 44                	jmp    801eb6 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e72:	89 f2                	mov    %esi,%edx
  801e74:	89 f8                	mov    %edi,%eax
  801e76:	e8 dc fe ff ff       	call   801d57 <_pipeisclosed>
  801e7b:	85 c0                	test   %eax,%eax
  801e7d:	75 32                	jne    801eb1 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e7f:	e8 c6 ed ff ff       	call   800c4a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e84:	8b 06                	mov    (%esi),%eax
  801e86:	3b 46 04             	cmp    0x4(%esi),%eax
  801e89:	74 df                	je     801e6a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e8b:	99                   	cltd   
  801e8c:	c1 ea 1b             	shr    $0x1b,%edx
  801e8f:	01 d0                	add    %edx,%eax
  801e91:	83 e0 1f             	and    $0x1f,%eax
  801e94:	29 d0                	sub    %edx,%eax
  801e96:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e9e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ea1:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ea4:	83 c3 01             	add    $0x1,%ebx
  801ea7:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801eaa:	75 d8                	jne    801e84 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801eac:	8b 45 10             	mov    0x10(%ebp),%eax
  801eaf:	eb 05                	jmp    801eb6 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801eb1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801eb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eb9:	5b                   	pop    %ebx
  801eba:	5e                   	pop    %esi
  801ebb:	5f                   	pop    %edi
  801ebc:	5d                   	pop    %ebp
  801ebd:	c3                   	ret    

00801ebe <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ebe:	55                   	push   %ebp
  801ebf:	89 e5                	mov    %esp,%ebp
  801ec1:	56                   	push   %esi
  801ec2:	53                   	push   %ebx
  801ec3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ec6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ec9:	50                   	push   %eax
  801eca:	e8 10 f5 ff ff       	call   8013df <fd_alloc>
  801ecf:	83 c4 10             	add    $0x10,%esp
  801ed2:	89 c2                	mov    %eax,%edx
  801ed4:	85 c0                	test   %eax,%eax
  801ed6:	0f 88 2c 01 00 00    	js     802008 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801edc:	83 ec 04             	sub    $0x4,%esp
  801edf:	68 07 04 00 00       	push   $0x407
  801ee4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ee7:	6a 00                	push   $0x0
  801ee9:	e8 7b ed ff ff       	call   800c69 <sys_page_alloc>
  801eee:	83 c4 10             	add    $0x10,%esp
  801ef1:	89 c2                	mov    %eax,%edx
  801ef3:	85 c0                	test   %eax,%eax
  801ef5:	0f 88 0d 01 00 00    	js     802008 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801efb:	83 ec 0c             	sub    $0xc,%esp
  801efe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f01:	50                   	push   %eax
  801f02:	e8 d8 f4 ff ff       	call   8013df <fd_alloc>
  801f07:	89 c3                	mov    %eax,%ebx
  801f09:	83 c4 10             	add    $0x10,%esp
  801f0c:	85 c0                	test   %eax,%eax
  801f0e:	0f 88 e2 00 00 00    	js     801ff6 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f14:	83 ec 04             	sub    $0x4,%esp
  801f17:	68 07 04 00 00       	push   $0x407
  801f1c:	ff 75 f0             	pushl  -0x10(%ebp)
  801f1f:	6a 00                	push   $0x0
  801f21:	e8 43 ed ff ff       	call   800c69 <sys_page_alloc>
  801f26:	89 c3                	mov    %eax,%ebx
  801f28:	83 c4 10             	add    $0x10,%esp
  801f2b:	85 c0                	test   %eax,%eax
  801f2d:	0f 88 c3 00 00 00    	js     801ff6 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f33:	83 ec 0c             	sub    $0xc,%esp
  801f36:	ff 75 f4             	pushl  -0xc(%ebp)
  801f39:	e8 8a f4 ff ff       	call   8013c8 <fd2data>
  801f3e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f40:	83 c4 0c             	add    $0xc,%esp
  801f43:	68 07 04 00 00       	push   $0x407
  801f48:	50                   	push   %eax
  801f49:	6a 00                	push   $0x0
  801f4b:	e8 19 ed ff ff       	call   800c69 <sys_page_alloc>
  801f50:	89 c3                	mov    %eax,%ebx
  801f52:	83 c4 10             	add    $0x10,%esp
  801f55:	85 c0                	test   %eax,%eax
  801f57:	0f 88 89 00 00 00    	js     801fe6 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f5d:	83 ec 0c             	sub    $0xc,%esp
  801f60:	ff 75 f0             	pushl  -0x10(%ebp)
  801f63:	e8 60 f4 ff ff       	call   8013c8 <fd2data>
  801f68:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f6f:	50                   	push   %eax
  801f70:	6a 00                	push   $0x0
  801f72:	56                   	push   %esi
  801f73:	6a 00                	push   $0x0
  801f75:	e8 32 ed ff ff       	call   800cac <sys_page_map>
  801f7a:	89 c3                	mov    %eax,%ebx
  801f7c:	83 c4 20             	add    $0x20,%esp
  801f7f:	85 c0                	test   %eax,%eax
  801f81:	78 55                	js     801fd8 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f83:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801f89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f8c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f91:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f98:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801f9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fa1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801fa3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fa6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801fad:	83 ec 0c             	sub    $0xc,%esp
  801fb0:	ff 75 f4             	pushl  -0xc(%ebp)
  801fb3:	e8 00 f4 ff ff       	call   8013b8 <fd2num>
  801fb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fbb:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801fbd:	83 c4 04             	add    $0x4,%esp
  801fc0:	ff 75 f0             	pushl  -0x10(%ebp)
  801fc3:	e8 f0 f3 ff ff       	call   8013b8 <fd2num>
  801fc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fcb:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801fce:	83 c4 10             	add    $0x10,%esp
  801fd1:	ba 00 00 00 00       	mov    $0x0,%edx
  801fd6:	eb 30                	jmp    802008 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801fd8:	83 ec 08             	sub    $0x8,%esp
  801fdb:	56                   	push   %esi
  801fdc:	6a 00                	push   $0x0
  801fde:	e8 0b ed ff ff       	call   800cee <sys_page_unmap>
  801fe3:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801fe6:	83 ec 08             	sub    $0x8,%esp
  801fe9:	ff 75 f0             	pushl  -0x10(%ebp)
  801fec:	6a 00                	push   $0x0
  801fee:	e8 fb ec ff ff       	call   800cee <sys_page_unmap>
  801ff3:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ff6:	83 ec 08             	sub    $0x8,%esp
  801ff9:	ff 75 f4             	pushl  -0xc(%ebp)
  801ffc:	6a 00                	push   $0x0
  801ffe:	e8 eb ec ff ff       	call   800cee <sys_page_unmap>
  802003:	83 c4 10             	add    $0x10,%esp
  802006:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802008:	89 d0                	mov    %edx,%eax
  80200a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80200d:	5b                   	pop    %ebx
  80200e:	5e                   	pop    %esi
  80200f:	5d                   	pop    %ebp
  802010:	c3                   	ret    

00802011 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802011:	55                   	push   %ebp
  802012:	89 e5                	mov    %esp,%ebp
  802014:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802017:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80201a:	50                   	push   %eax
  80201b:	ff 75 08             	pushl  0x8(%ebp)
  80201e:	e8 0b f4 ff ff       	call   80142e <fd_lookup>
  802023:	83 c4 10             	add    $0x10,%esp
  802026:	85 c0                	test   %eax,%eax
  802028:	78 18                	js     802042 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80202a:	83 ec 0c             	sub    $0xc,%esp
  80202d:	ff 75 f4             	pushl  -0xc(%ebp)
  802030:	e8 93 f3 ff ff       	call   8013c8 <fd2data>
	return _pipeisclosed(fd, p);
  802035:	89 c2                	mov    %eax,%edx
  802037:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80203a:	e8 18 fd ff ff       	call   801d57 <_pipeisclosed>
  80203f:	83 c4 10             	add    $0x10,%esp
}
  802042:	c9                   	leave  
  802043:	c3                   	ret    

00802044 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802044:	55                   	push   %ebp
  802045:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802047:	b8 00 00 00 00       	mov    $0x0,%eax
  80204c:	5d                   	pop    %ebp
  80204d:	c3                   	ret    

0080204e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80204e:	55                   	push   %ebp
  80204f:	89 e5                	mov    %esp,%ebp
  802051:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802054:	68 7a 2b 80 00       	push   $0x802b7a
  802059:	ff 75 0c             	pushl  0xc(%ebp)
  80205c:	e8 05 e8 ff ff       	call   800866 <strcpy>
	return 0;
}
  802061:	b8 00 00 00 00       	mov    $0x0,%eax
  802066:	c9                   	leave  
  802067:	c3                   	ret    

00802068 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802068:	55                   	push   %ebp
  802069:	89 e5                	mov    %esp,%ebp
  80206b:	57                   	push   %edi
  80206c:	56                   	push   %esi
  80206d:	53                   	push   %ebx
  80206e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802074:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802079:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80207f:	eb 2d                	jmp    8020ae <devcons_write+0x46>
		m = n - tot;
  802081:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802084:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802086:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802089:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80208e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802091:	83 ec 04             	sub    $0x4,%esp
  802094:	53                   	push   %ebx
  802095:	03 45 0c             	add    0xc(%ebp),%eax
  802098:	50                   	push   %eax
  802099:	57                   	push   %edi
  80209a:	e8 59 e9 ff ff       	call   8009f8 <memmove>
		sys_cputs(buf, m);
  80209f:	83 c4 08             	add    $0x8,%esp
  8020a2:	53                   	push   %ebx
  8020a3:	57                   	push   %edi
  8020a4:	e8 04 eb ff ff       	call   800bad <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020a9:	01 de                	add    %ebx,%esi
  8020ab:	83 c4 10             	add    $0x10,%esp
  8020ae:	89 f0                	mov    %esi,%eax
  8020b0:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020b3:	72 cc                	jb     802081 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8020b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020b8:	5b                   	pop    %ebx
  8020b9:	5e                   	pop    %esi
  8020ba:	5f                   	pop    %edi
  8020bb:	5d                   	pop    %ebp
  8020bc:	c3                   	ret    

008020bd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020bd:	55                   	push   %ebp
  8020be:	89 e5                	mov    %esp,%ebp
  8020c0:	83 ec 08             	sub    $0x8,%esp
  8020c3:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8020c8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020cc:	74 2a                	je     8020f8 <devcons_read+0x3b>
  8020ce:	eb 05                	jmp    8020d5 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8020d0:	e8 75 eb ff ff       	call   800c4a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8020d5:	e8 f1 ea ff ff       	call   800bcb <sys_cgetc>
  8020da:	85 c0                	test   %eax,%eax
  8020dc:	74 f2                	je     8020d0 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8020de:	85 c0                	test   %eax,%eax
  8020e0:	78 16                	js     8020f8 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8020e2:	83 f8 04             	cmp    $0x4,%eax
  8020e5:	74 0c                	je     8020f3 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8020e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020ea:	88 02                	mov    %al,(%edx)
	return 1;
  8020ec:	b8 01 00 00 00       	mov    $0x1,%eax
  8020f1:	eb 05                	jmp    8020f8 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020f3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020f8:	c9                   	leave  
  8020f9:	c3                   	ret    

008020fa <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020fa:	55                   	push   %ebp
  8020fb:	89 e5                	mov    %esp,%ebp
  8020fd:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802100:	8b 45 08             	mov    0x8(%ebp),%eax
  802103:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802106:	6a 01                	push   $0x1
  802108:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80210b:	50                   	push   %eax
  80210c:	e8 9c ea ff ff       	call   800bad <sys_cputs>
}
  802111:	83 c4 10             	add    $0x10,%esp
  802114:	c9                   	leave  
  802115:	c3                   	ret    

00802116 <getchar>:

int
getchar(void)
{
  802116:	55                   	push   %ebp
  802117:	89 e5                	mov    %esp,%ebp
  802119:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80211c:	6a 01                	push   $0x1
  80211e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802121:	50                   	push   %eax
  802122:	6a 00                	push   $0x0
  802124:	e8 6e f5 ff ff       	call   801697 <read>
	if (r < 0)
  802129:	83 c4 10             	add    $0x10,%esp
  80212c:	85 c0                	test   %eax,%eax
  80212e:	78 0f                	js     80213f <getchar+0x29>
		return r;
	if (r < 1)
  802130:	85 c0                	test   %eax,%eax
  802132:	7e 06                	jle    80213a <getchar+0x24>
		return -E_EOF;
	return c;
  802134:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802138:	eb 05                	jmp    80213f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80213a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80213f:	c9                   	leave  
  802140:	c3                   	ret    

00802141 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802141:	55                   	push   %ebp
  802142:	89 e5                	mov    %esp,%ebp
  802144:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802147:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80214a:	50                   	push   %eax
  80214b:	ff 75 08             	pushl  0x8(%ebp)
  80214e:	e8 db f2 ff ff       	call   80142e <fd_lookup>
  802153:	83 c4 10             	add    $0x10,%esp
  802156:	85 c0                	test   %eax,%eax
  802158:	78 11                	js     80216b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80215a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80215d:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802163:	39 10                	cmp    %edx,(%eax)
  802165:	0f 94 c0             	sete   %al
  802168:	0f b6 c0             	movzbl %al,%eax
}
  80216b:	c9                   	leave  
  80216c:	c3                   	ret    

0080216d <opencons>:

int
opencons(void)
{
  80216d:	55                   	push   %ebp
  80216e:	89 e5                	mov    %esp,%ebp
  802170:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802173:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802176:	50                   	push   %eax
  802177:	e8 63 f2 ff ff       	call   8013df <fd_alloc>
  80217c:	83 c4 10             	add    $0x10,%esp
		return r;
  80217f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802181:	85 c0                	test   %eax,%eax
  802183:	78 3e                	js     8021c3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802185:	83 ec 04             	sub    $0x4,%esp
  802188:	68 07 04 00 00       	push   $0x407
  80218d:	ff 75 f4             	pushl  -0xc(%ebp)
  802190:	6a 00                	push   $0x0
  802192:	e8 d2 ea ff ff       	call   800c69 <sys_page_alloc>
  802197:	83 c4 10             	add    $0x10,%esp
		return r;
  80219a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80219c:	85 c0                	test   %eax,%eax
  80219e:	78 23                	js     8021c3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8021a0:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8021a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021a9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ae:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021b5:	83 ec 0c             	sub    $0xc,%esp
  8021b8:	50                   	push   %eax
  8021b9:	e8 fa f1 ff ff       	call   8013b8 <fd2num>
  8021be:	89 c2                	mov    %eax,%edx
  8021c0:	83 c4 10             	add    $0x10,%esp
}
  8021c3:	89 d0                	mov    %edx,%eax
  8021c5:	c9                   	leave  
  8021c6:	c3                   	ret    

008021c7 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8021c7:	55                   	push   %ebp
  8021c8:	89 e5                	mov    %esp,%ebp
  8021ca:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8021cd:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8021d4:	75 2a                	jne    802200 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  8021d6:	83 ec 04             	sub    $0x4,%esp
  8021d9:	6a 07                	push   $0x7
  8021db:	68 00 f0 bf ee       	push   $0xeebff000
  8021e0:	6a 00                	push   $0x0
  8021e2:	e8 82 ea ff ff       	call   800c69 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8021e7:	83 c4 10             	add    $0x10,%esp
  8021ea:	85 c0                	test   %eax,%eax
  8021ec:	79 12                	jns    802200 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8021ee:	50                   	push   %eax
  8021ef:	68 92 2a 80 00       	push   $0x802a92
  8021f4:	6a 23                	push   $0x23
  8021f6:	68 86 2b 80 00       	push   $0x802b86
  8021fb:	e8 08 e0 ff ff       	call   800208 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802200:	8b 45 08             	mov    0x8(%ebp),%eax
  802203:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802208:	83 ec 08             	sub    $0x8,%esp
  80220b:	68 32 22 80 00       	push   $0x802232
  802210:	6a 00                	push   $0x0
  802212:	e8 9d eb ff ff       	call   800db4 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802217:	83 c4 10             	add    $0x10,%esp
  80221a:	85 c0                	test   %eax,%eax
  80221c:	79 12                	jns    802230 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  80221e:	50                   	push   %eax
  80221f:	68 92 2a 80 00       	push   $0x802a92
  802224:	6a 2c                	push   $0x2c
  802226:	68 86 2b 80 00       	push   $0x802b86
  80222b:	e8 d8 df ff ff       	call   800208 <_panic>
	}
}
  802230:	c9                   	leave  
  802231:	c3                   	ret    

00802232 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802232:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802233:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802238:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80223a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  80223d:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802241:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802246:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80224a:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  80224c:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  80224f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802250:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802253:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802254:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802255:	c3                   	ret    

00802256 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802256:	55                   	push   %ebp
  802257:	89 e5                	mov    %esp,%ebp
  802259:	56                   	push   %esi
  80225a:	53                   	push   %ebx
  80225b:	8b 75 08             	mov    0x8(%ebp),%esi
  80225e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802261:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802264:	85 c0                	test   %eax,%eax
  802266:	75 12                	jne    80227a <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802268:	83 ec 0c             	sub    $0xc,%esp
  80226b:	68 00 00 c0 ee       	push   $0xeec00000
  802270:	e8 a4 eb ff ff       	call   800e19 <sys_ipc_recv>
  802275:	83 c4 10             	add    $0x10,%esp
  802278:	eb 0c                	jmp    802286 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80227a:	83 ec 0c             	sub    $0xc,%esp
  80227d:	50                   	push   %eax
  80227e:	e8 96 eb ff ff       	call   800e19 <sys_ipc_recv>
  802283:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802286:	85 f6                	test   %esi,%esi
  802288:	0f 95 c1             	setne  %cl
  80228b:	85 db                	test   %ebx,%ebx
  80228d:	0f 95 c2             	setne  %dl
  802290:	84 d1                	test   %dl,%cl
  802292:	74 09                	je     80229d <ipc_recv+0x47>
  802294:	89 c2                	mov    %eax,%edx
  802296:	c1 ea 1f             	shr    $0x1f,%edx
  802299:	84 d2                	test   %dl,%dl
  80229b:	75 2d                	jne    8022ca <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80229d:	85 f6                	test   %esi,%esi
  80229f:	74 0d                	je     8022ae <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8022a1:	a1 08 40 80 00       	mov    0x804008,%eax
  8022a6:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  8022ac:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8022ae:	85 db                	test   %ebx,%ebx
  8022b0:	74 0d                	je     8022bf <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8022b2:	a1 08 40 80 00       	mov    0x804008,%eax
  8022b7:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8022bd:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8022bf:	a1 08 40 80 00       	mov    0x804008,%eax
  8022c4:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  8022ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022cd:	5b                   	pop    %ebx
  8022ce:	5e                   	pop    %esi
  8022cf:	5d                   	pop    %ebp
  8022d0:	c3                   	ret    

008022d1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022d1:	55                   	push   %ebp
  8022d2:	89 e5                	mov    %esp,%ebp
  8022d4:	57                   	push   %edi
  8022d5:	56                   	push   %esi
  8022d6:	53                   	push   %ebx
  8022d7:	83 ec 0c             	sub    $0xc,%esp
  8022da:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022dd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8022e3:	85 db                	test   %ebx,%ebx
  8022e5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8022ea:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8022ed:	ff 75 14             	pushl  0x14(%ebp)
  8022f0:	53                   	push   %ebx
  8022f1:	56                   	push   %esi
  8022f2:	57                   	push   %edi
  8022f3:	e8 fe ea ff ff       	call   800df6 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8022f8:	89 c2                	mov    %eax,%edx
  8022fa:	c1 ea 1f             	shr    $0x1f,%edx
  8022fd:	83 c4 10             	add    $0x10,%esp
  802300:	84 d2                	test   %dl,%dl
  802302:	74 17                	je     80231b <ipc_send+0x4a>
  802304:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802307:	74 12                	je     80231b <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802309:	50                   	push   %eax
  80230a:	68 94 2b 80 00       	push   $0x802b94
  80230f:	6a 47                	push   $0x47
  802311:	68 a2 2b 80 00       	push   $0x802ba2
  802316:	e8 ed de ff ff       	call   800208 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80231b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80231e:	75 07                	jne    802327 <ipc_send+0x56>
			sys_yield();
  802320:	e8 25 e9 ff ff       	call   800c4a <sys_yield>
  802325:	eb c6                	jmp    8022ed <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802327:	85 c0                	test   %eax,%eax
  802329:	75 c2                	jne    8022ed <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80232b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80232e:	5b                   	pop    %ebx
  80232f:	5e                   	pop    %esi
  802330:	5f                   	pop    %edi
  802331:	5d                   	pop    %ebp
  802332:	c3                   	ret    

00802333 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802333:	55                   	push   %ebp
  802334:	89 e5                	mov    %esp,%ebp
  802336:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802339:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80233e:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  802344:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80234a:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  802350:	39 ca                	cmp    %ecx,%edx
  802352:	75 13                	jne    802367 <ipc_find_env+0x34>
			return envs[i].env_id;
  802354:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  80235a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80235f:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  802365:	eb 0f                	jmp    802376 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802367:	83 c0 01             	add    $0x1,%eax
  80236a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80236f:	75 cd                	jne    80233e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802371:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802376:	5d                   	pop    %ebp
  802377:	c3                   	ret    

00802378 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802378:	55                   	push   %ebp
  802379:	89 e5                	mov    %esp,%ebp
  80237b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80237e:	89 d0                	mov    %edx,%eax
  802380:	c1 e8 16             	shr    $0x16,%eax
  802383:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80238a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80238f:	f6 c1 01             	test   $0x1,%cl
  802392:	74 1d                	je     8023b1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802394:	c1 ea 0c             	shr    $0xc,%edx
  802397:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80239e:	f6 c2 01             	test   $0x1,%dl
  8023a1:	74 0e                	je     8023b1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023a3:	c1 ea 0c             	shr    $0xc,%edx
  8023a6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8023ad:	ef 
  8023ae:	0f b7 c0             	movzwl %ax,%eax
}
  8023b1:	5d                   	pop    %ebp
  8023b2:	c3                   	ret    
  8023b3:	66 90                	xchg   %ax,%ax
  8023b5:	66 90                	xchg   %ax,%ax
  8023b7:	66 90                	xchg   %ax,%ax
  8023b9:	66 90                	xchg   %ax,%ax
  8023bb:	66 90                	xchg   %ax,%ax
  8023bd:	66 90                	xchg   %ax,%ax
  8023bf:	90                   	nop

008023c0 <__udivdi3>:
  8023c0:	55                   	push   %ebp
  8023c1:	57                   	push   %edi
  8023c2:	56                   	push   %esi
  8023c3:	53                   	push   %ebx
  8023c4:	83 ec 1c             	sub    $0x1c,%esp
  8023c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8023cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8023cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8023d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023d7:	85 f6                	test   %esi,%esi
  8023d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023dd:	89 ca                	mov    %ecx,%edx
  8023df:	89 f8                	mov    %edi,%eax
  8023e1:	75 3d                	jne    802420 <__udivdi3+0x60>
  8023e3:	39 cf                	cmp    %ecx,%edi
  8023e5:	0f 87 c5 00 00 00    	ja     8024b0 <__udivdi3+0xf0>
  8023eb:	85 ff                	test   %edi,%edi
  8023ed:	89 fd                	mov    %edi,%ebp
  8023ef:	75 0b                	jne    8023fc <__udivdi3+0x3c>
  8023f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8023f6:	31 d2                	xor    %edx,%edx
  8023f8:	f7 f7                	div    %edi
  8023fa:	89 c5                	mov    %eax,%ebp
  8023fc:	89 c8                	mov    %ecx,%eax
  8023fe:	31 d2                	xor    %edx,%edx
  802400:	f7 f5                	div    %ebp
  802402:	89 c1                	mov    %eax,%ecx
  802404:	89 d8                	mov    %ebx,%eax
  802406:	89 cf                	mov    %ecx,%edi
  802408:	f7 f5                	div    %ebp
  80240a:	89 c3                	mov    %eax,%ebx
  80240c:	89 d8                	mov    %ebx,%eax
  80240e:	89 fa                	mov    %edi,%edx
  802410:	83 c4 1c             	add    $0x1c,%esp
  802413:	5b                   	pop    %ebx
  802414:	5e                   	pop    %esi
  802415:	5f                   	pop    %edi
  802416:	5d                   	pop    %ebp
  802417:	c3                   	ret    
  802418:	90                   	nop
  802419:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802420:	39 ce                	cmp    %ecx,%esi
  802422:	77 74                	ja     802498 <__udivdi3+0xd8>
  802424:	0f bd fe             	bsr    %esi,%edi
  802427:	83 f7 1f             	xor    $0x1f,%edi
  80242a:	0f 84 98 00 00 00    	je     8024c8 <__udivdi3+0x108>
  802430:	bb 20 00 00 00       	mov    $0x20,%ebx
  802435:	89 f9                	mov    %edi,%ecx
  802437:	89 c5                	mov    %eax,%ebp
  802439:	29 fb                	sub    %edi,%ebx
  80243b:	d3 e6                	shl    %cl,%esi
  80243d:	89 d9                	mov    %ebx,%ecx
  80243f:	d3 ed                	shr    %cl,%ebp
  802441:	89 f9                	mov    %edi,%ecx
  802443:	d3 e0                	shl    %cl,%eax
  802445:	09 ee                	or     %ebp,%esi
  802447:	89 d9                	mov    %ebx,%ecx
  802449:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80244d:	89 d5                	mov    %edx,%ebp
  80244f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802453:	d3 ed                	shr    %cl,%ebp
  802455:	89 f9                	mov    %edi,%ecx
  802457:	d3 e2                	shl    %cl,%edx
  802459:	89 d9                	mov    %ebx,%ecx
  80245b:	d3 e8                	shr    %cl,%eax
  80245d:	09 c2                	or     %eax,%edx
  80245f:	89 d0                	mov    %edx,%eax
  802461:	89 ea                	mov    %ebp,%edx
  802463:	f7 f6                	div    %esi
  802465:	89 d5                	mov    %edx,%ebp
  802467:	89 c3                	mov    %eax,%ebx
  802469:	f7 64 24 0c          	mull   0xc(%esp)
  80246d:	39 d5                	cmp    %edx,%ebp
  80246f:	72 10                	jb     802481 <__udivdi3+0xc1>
  802471:	8b 74 24 08          	mov    0x8(%esp),%esi
  802475:	89 f9                	mov    %edi,%ecx
  802477:	d3 e6                	shl    %cl,%esi
  802479:	39 c6                	cmp    %eax,%esi
  80247b:	73 07                	jae    802484 <__udivdi3+0xc4>
  80247d:	39 d5                	cmp    %edx,%ebp
  80247f:	75 03                	jne    802484 <__udivdi3+0xc4>
  802481:	83 eb 01             	sub    $0x1,%ebx
  802484:	31 ff                	xor    %edi,%edi
  802486:	89 d8                	mov    %ebx,%eax
  802488:	89 fa                	mov    %edi,%edx
  80248a:	83 c4 1c             	add    $0x1c,%esp
  80248d:	5b                   	pop    %ebx
  80248e:	5e                   	pop    %esi
  80248f:	5f                   	pop    %edi
  802490:	5d                   	pop    %ebp
  802491:	c3                   	ret    
  802492:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802498:	31 ff                	xor    %edi,%edi
  80249a:	31 db                	xor    %ebx,%ebx
  80249c:	89 d8                	mov    %ebx,%eax
  80249e:	89 fa                	mov    %edi,%edx
  8024a0:	83 c4 1c             	add    $0x1c,%esp
  8024a3:	5b                   	pop    %ebx
  8024a4:	5e                   	pop    %esi
  8024a5:	5f                   	pop    %edi
  8024a6:	5d                   	pop    %ebp
  8024a7:	c3                   	ret    
  8024a8:	90                   	nop
  8024a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024b0:	89 d8                	mov    %ebx,%eax
  8024b2:	f7 f7                	div    %edi
  8024b4:	31 ff                	xor    %edi,%edi
  8024b6:	89 c3                	mov    %eax,%ebx
  8024b8:	89 d8                	mov    %ebx,%eax
  8024ba:	89 fa                	mov    %edi,%edx
  8024bc:	83 c4 1c             	add    $0x1c,%esp
  8024bf:	5b                   	pop    %ebx
  8024c0:	5e                   	pop    %esi
  8024c1:	5f                   	pop    %edi
  8024c2:	5d                   	pop    %ebp
  8024c3:	c3                   	ret    
  8024c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024c8:	39 ce                	cmp    %ecx,%esi
  8024ca:	72 0c                	jb     8024d8 <__udivdi3+0x118>
  8024cc:	31 db                	xor    %ebx,%ebx
  8024ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8024d2:	0f 87 34 ff ff ff    	ja     80240c <__udivdi3+0x4c>
  8024d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8024dd:	e9 2a ff ff ff       	jmp    80240c <__udivdi3+0x4c>
  8024e2:	66 90                	xchg   %ax,%ax
  8024e4:	66 90                	xchg   %ax,%ax
  8024e6:	66 90                	xchg   %ax,%ax
  8024e8:	66 90                	xchg   %ax,%ax
  8024ea:	66 90                	xchg   %ax,%ax
  8024ec:	66 90                	xchg   %ax,%ax
  8024ee:	66 90                	xchg   %ax,%ax

008024f0 <__umoddi3>:
  8024f0:	55                   	push   %ebp
  8024f1:	57                   	push   %edi
  8024f2:	56                   	push   %esi
  8024f3:	53                   	push   %ebx
  8024f4:	83 ec 1c             	sub    $0x1c,%esp
  8024f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8024fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8024ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802503:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802507:	85 d2                	test   %edx,%edx
  802509:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80250d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802511:	89 f3                	mov    %esi,%ebx
  802513:	89 3c 24             	mov    %edi,(%esp)
  802516:	89 74 24 04          	mov    %esi,0x4(%esp)
  80251a:	75 1c                	jne    802538 <__umoddi3+0x48>
  80251c:	39 f7                	cmp    %esi,%edi
  80251e:	76 50                	jbe    802570 <__umoddi3+0x80>
  802520:	89 c8                	mov    %ecx,%eax
  802522:	89 f2                	mov    %esi,%edx
  802524:	f7 f7                	div    %edi
  802526:	89 d0                	mov    %edx,%eax
  802528:	31 d2                	xor    %edx,%edx
  80252a:	83 c4 1c             	add    $0x1c,%esp
  80252d:	5b                   	pop    %ebx
  80252e:	5e                   	pop    %esi
  80252f:	5f                   	pop    %edi
  802530:	5d                   	pop    %ebp
  802531:	c3                   	ret    
  802532:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802538:	39 f2                	cmp    %esi,%edx
  80253a:	89 d0                	mov    %edx,%eax
  80253c:	77 52                	ja     802590 <__umoddi3+0xa0>
  80253e:	0f bd ea             	bsr    %edx,%ebp
  802541:	83 f5 1f             	xor    $0x1f,%ebp
  802544:	75 5a                	jne    8025a0 <__umoddi3+0xb0>
  802546:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80254a:	0f 82 e0 00 00 00    	jb     802630 <__umoddi3+0x140>
  802550:	39 0c 24             	cmp    %ecx,(%esp)
  802553:	0f 86 d7 00 00 00    	jbe    802630 <__umoddi3+0x140>
  802559:	8b 44 24 08          	mov    0x8(%esp),%eax
  80255d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802561:	83 c4 1c             	add    $0x1c,%esp
  802564:	5b                   	pop    %ebx
  802565:	5e                   	pop    %esi
  802566:	5f                   	pop    %edi
  802567:	5d                   	pop    %ebp
  802568:	c3                   	ret    
  802569:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802570:	85 ff                	test   %edi,%edi
  802572:	89 fd                	mov    %edi,%ebp
  802574:	75 0b                	jne    802581 <__umoddi3+0x91>
  802576:	b8 01 00 00 00       	mov    $0x1,%eax
  80257b:	31 d2                	xor    %edx,%edx
  80257d:	f7 f7                	div    %edi
  80257f:	89 c5                	mov    %eax,%ebp
  802581:	89 f0                	mov    %esi,%eax
  802583:	31 d2                	xor    %edx,%edx
  802585:	f7 f5                	div    %ebp
  802587:	89 c8                	mov    %ecx,%eax
  802589:	f7 f5                	div    %ebp
  80258b:	89 d0                	mov    %edx,%eax
  80258d:	eb 99                	jmp    802528 <__umoddi3+0x38>
  80258f:	90                   	nop
  802590:	89 c8                	mov    %ecx,%eax
  802592:	89 f2                	mov    %esi,%edx
  802594:	83 c4 1c             	add    $0x1c,%esp
  802597:	5b                   	pop    %ebx
  802598:	5e                   	pop    %esi
  802599:	5f                   	pop    %edi
  80259a:	5d                   	pop    %ebp
  80259b:	c3                   	ret    
  80259c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025a0:	8b 34 24             	mov    (%esp),%esi
  8025a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8025a8:	89 e9                	mov    %ebp,%ecx
  8025aa:	29 ef                	sub    %ebp,%edi
  8025ac:	d3 e0                	shl    %cl,%eax
  8025ae:	89 f9                	mov    %edi,%ecx
  8025b0:	89 f2                	mov    %esi,%edx
  8025b2:	d3 ea                	shr    %cl,%edx
  8025b4:	89 e9                	mov    %ebp,%ecx
  8025b6:	09 c2                	or     %eax,%edx
  8025b8:	89 d8                	mov    %ebx,%eax
  8025ba:	89 14 24             	mov    %edx,(%esp)
  8025bd:	89 f2                	mov    %esi,%edx
  8025bf:	d3 e2                	shl    %cl,%edx
  8025c1:	89 f9                	mov    %edi,%ecx
  8025c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8025cb:	d3 e8                	shr    %cl,%eax
  8025cd:	89 e9                	mov    %ebp,%ecx
  8025cf:	89 c6                	mov    %eax,%esi
  8025d1:	d3 e3                	shl    %cl,%ebx
  8025d3:	89 f9                	mov    %edi,%ecx
  8025d5:	89 d0                	mov    %edx,%eax
  8025d7:	d3 e8                	shr    %cl,%eax
  8025d9:	89 e9                	mov    %ebp,%ecx
  8025db:	09 d8                	or     %ebx,%eax
  8025dd:	89 d3                	mov    %edx,%ebx
  8025df:	89 f2                	mov    %esi,%edx
  8025e1:	f7 34 24             	divl   (%esp)
  8025e4:	89 d6                	mov    %edx,%esi
  8025e6:	d3 e3                	shl    %cl,%ebx
  8025e8:	f7 64 24 04          	mull   0x4(%esp)
  8025ec:	39 d6                	cmp    %edx,%esi
  8025ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025f2:	89 d1                	mov    %edx,%ecx
  8025f4:	89 c3                	mov    %eax,%ebx
  8025f6:	72 08                	jb     802600 <__umoddi3+0x110>
  8025f8:	75 11                	jne    80260b <__umoddi3+0x11b>
  8025fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8025fe:	73 0b                	jae    80260b <__umoddi3+0x11b>
  802600:	2b 44 24 04          	sub    0x4(%esp),%eax
  802604:	1b 14 24             	sbb    (%esp),%edx
  802607:	89 d1                	mov    %edx,%ecx
  802609:	89 c3                	mov    %eax,%ebx
  80260b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80260f:	29 da                	sub    %ebx,%edx
  802611:	19 ce                	sbb    %ecx,%esi
  802613:	89 f9                	mov    %edi,%ecx
  802615:	89 f0                	mov    %esi,%eax
  802617:	d3 e0                	shl    %cl,%eax
  802619:	89 e9                	mov    %ebp,%ecx
  80261b:	d3 ea                	shr    %cl,%edx
  80261d:	89 e9                	mov    %ebp,%ecx
  80261f:	d3 ee                	shr    %cl,%esi
  802621:	09 d0                	or     %edx,%eax
  802623:	89 f2                	mov    %esi,%edx
  802625:	83 c4 1c             	add    $0x1c,%esp
  802628:	5b                   	pop    %ebx
  802629:	5e                   	pop    %esi
  80262a:	5f                   	pop    %edi
  80262b:	5d                   	pop    %ebp
  80262c:	c3                   	ret    
  80262d:	8d 76 00             	lea    0x0(%esi),%esi
  802630:	29 f9                	sub    %edi,%ecx
  802632:	19 d6                	sbb    %edx,%esi
  802634:	89 74 24 04          	mov    %esi,0x4(%esp)
  802638:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80263c:	e9 18 ff ff ff       	jmp    802559 <__umoddi3+0x69>
