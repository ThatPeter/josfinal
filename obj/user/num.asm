
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
  80005d:	68 40 26 80 00       	push   $0x802640
  800062:	e8 5e 1c 00 00       	call   801cc5 <printf>
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
  80007c:	e8 ef 16 00 00       	call   801770 <write>
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	83 f8 01             	cmp    $0x1,%eax
  800087:	74 18                	je     8000a1 <num+0x6e>
			panic("write error copying %s: %e", s, r);
  800089:	83 ec 0c             	sub    $0xc,%esp
  80008c:	50                   	push   %eax
  80008d:	ff 75 0c             	pushl  0xc(%ebp)
  800090:	68 45 26 80 00       	push   $0x802645
  800095:	6a 13                	push   $0x13
  800097:	68 60 26 80 00       	push   $0x802660
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
  8000b8:	e8 d6 15 00 00       	call   801693 <read>
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
  8000d3:	68 6b 26 80 00       	push   $0x80266b
  8000d8:	6a 18                	push   $0x18
  8000da:	68 60 26 80 00       	push   $0x802660
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
  8000f4:	c7 05 04 30 80 00 80 	movl   $0x802680,0x803004
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
  800114:	68 84 26 80 00       	push   $0x802684
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
  80012f:	e8 f3 19 00 00       	call   801b27 <open>
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
  800146:	68 8c 26 80 00       	push   $0x80268c
  80014b:	6a 27                	push   $0x27
  80014d:	68 60 26 80 00       	push   $0x802660
  800152:	e8 b1 00 00 00       	call   800208 <_panic>
			else {
				num(f, argv[i]);
  800157:	83 ec 08             	sub    $0x8,%esp
  80015a:	ff 33                	pushl  (%ebx)
  80015c:	50                   	push   %eax
  80015d:	e8 d1 fe ff ff       	call   800033 <num>
				close(f);
  800162:	89 34 24             	mov    %esi,(%esp)
  800165:	e8 ed 13 00 00       	call   801557 <close>

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
  8001f4:	e8 89 13 00 00       	call   801582 <close_all>
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
  800226:	68 a8 26 80 00       	push   $0x8026a8
  80022b:	e8 b1 00 00 00       	call   8002e1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800230:	83 c4 18             	add    $0x18,%esp
  800233:	53                   	push   %ebx
  800234:	ff 75 10             	pushl  0x10(%ebp)
  800237:	e8 54 00 00 00       	call   800290 <vcprintf>
	cprintf("\n");
  80023c:	c7 04 24 5b 2a 80 00 	movl   $0x802a5b,(%esp)
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
  800344:	e8 67 20 00 00       	call   8023b0 <__udivdi3>
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
  800387:	e8 54 21 00 00       	call   8024e0 <__umoddi3>
  80038c:	83 c4 14             	add    $0x14,%esp
  80038f:	0f be 80 cb 26 80 00 	movsbl 0x8026cb(%eax),%eax
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
  80048b:	ff 24 85 00 28 80 00 	jmp    *0x802800(,%eax,4)
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
  80054f:	8b 14 85 60 29 80 00 	mov    0x802960(,%eax,4),%edx
  800556:	85 d2                	test   %edx,%edx
  800558:	75 18                	jne    800572 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80055a:	50                   	push   %eax
  80055b:	68 e3 26 80 00       	push   $0x8026e3
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
  800573:	68 21 2b 80 00       	push   $0x802b21
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
  800597:	b8 dc 26 80 00       	mov    $0x8026dc,%eax
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
  800c12:	68 bf 29 80 00       	push   $0x8029bf
  800c17:	6a 23                	push   $0x23
  800c19:	68 dc 29 80 00       	push   $0x8029dc
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
  800c93:	68 bf 29 80 00       	push   $0x8029bf
  800c98:	6a 23                	push   $0x23
  800c9a:	68 dc 29 80 00       	push   $0x8029dc
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
  800cd5:	68 bf 29 80 00       	push   $0x8029bf
  800cda:	6a 23                	push   $0x23
  800cdc:	68 dc 29 80 00       	push   $0x8029dc
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
  800d17:	68 bf 29 80 00       	push   $0x8029bf
  800d1c:	6a 23                	push   $0x23
  800d1e:	68 dc 29 80 00       	push   $0x8029dc
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
  800d59:	68 bf 29 80 00       	push   $0x8029bf
  800d5e:	6a 23                	push   $0x23
  800d60:	68 dc 29 80 00       	push   $0x8029dc
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
  800d9b:	68 bf 29 80 00       	push   $0x8029bf
  800da0:	6a 23                	push   $0x23
  800da2:	68 dc 29 80 00       	push   $0x8029dc
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
  800ddd:	68 bf 29 80 00       	push   $0x8029bf
  800de2:	6a 23                	push   $0x23
  800de4:	68 dc 29 80 00       	push   $0x8029dc
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
  800e41:	68 bf 29 80 00       	push   $0x8029bf
  800e46:	6a 23                	push   $0x23
  800e48:	68 dc 29 80 00       	push   $0x8029dc
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
  800ee0:	68 ea 29 80 00       	push   $0x8029ea
  800ee5:	6a 1f                	push   $0x1f
  800ee7:	68 fa 29 80 00       	push   $0x8029fa
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
  800f0a:	68 05 2a 80 00       	push   $0x802a05
  800f0f:	6a 2d                	push   $0x2d
  800f11:	68 fa 29 80 00       	push   $0x8029fa
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
  800f52:	68 05 2a 80 00       	push   $0x802a05
  800f57:	6a 34                	push   $0x34
  800f59:	68 fa 29 80 00       	push   $0x8029fa
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
  800f7a:	68 05 2a 80 00       	push   $0x802a05
  800f7f:	6a 38                	push   $0x38
  800f81:	68 fa 29 80 00       	push   $0x8029fa
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
  800f9e:	e8 20 12 00 00       	call   8021c3 <set_pgfault_handler>
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
  800fb7:	68 1e 2a 80 00       	push   $0x802a1e
  800fbc:	68 85 00 00 00       	push   $0x85
  800fc1:	68 fa 29 80 00       	push   $0x8029fa
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
  801073:	68 2c 2a 80 00       	push   $0x802a2c
  801078:	6a 55                	push   $0x55
  80107a:	68 fa 29 80 00       	push   $0x8029fa
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
  8010b8:	68 2c 2a 80 00       	push   $0x802a2c
  8010bd:	6a 5c                	push   $0x5c
  8010bf:	68 fa 29 80 00       	push   $0x8029fa
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
  8010e6:	68 2c 2a 80 00       	push   $0x802a2c
  8010eb:	6a 60                	push   $0x60
  8010ed:	68 fa 29 80 00       	push   $0x8029fa
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
  801110:	68 2c 2a 80 00       	push   $0x802a2c
  801115:	6a 65                	push   $0x65
  801117:	68 fa 29 80 00       	push   $0x8029fa
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
  8011cd:	68 72 2a 80 00       	push   $0x802a72
  8011d2:	68 d5 00 00 00       	push   $0xd5
  8011d7:	68 fa 29 80 00       	push   $0x8029fa
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
  801233:	68 42 2a 80 00       	push   $0x802a42
  801238:	68 ec 00 00 00       	push   $0xec
  80123d:	68 fa 29 80 00       	push   $0x8029fa
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
  801253:	53                   	push   %ebx
  801254:	83 ec 04             	sub    $0x4,%esp
  801257:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  80125a:	b8 01 00 00 00       	mov    $0x1,%eax
  80125f:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  801262:	85 c0                	test   %eax,%eax
  801264:	74 45                	je     8012ab <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  801266:	e8 c0 f9 ff ff       	call   800c2b <sys_getenvid>
  80126b:	83 ec 08             	sub    $0x8,%esp
  80126e:	83 c3 04             	add    $0x4,%ebx
  801271:	53                   	push   %ebx
  801272:	50                   	push   %eax
  801273:	e8 35 ff ff ff       	call   8011ad <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  801278:	e8 ae f9 ff ff       	call   800c2b <sys_getenvid>
  80127d:	83 c4 08             	add    $0x8,%esp
  801280:	6a 04                	push   $0x4
  801282:	50                   	push   %eax
  801283:	e8 a8 fa ff ff       	call   800d30 <sys_env_set_status>

		if (r < 0) {
  801288:	83 c4 10             	add    $0x10,%esp
  80128b:	85 c0                	test   %eax,%eax
  80128d:	79 15                	jns    8012a4 <mutex_lock+0x54>
			panic("%e\n", r);
  80128f:	50                   	push   %eax
  801290:	68 72 2a 80 00       	push   $0x802a72
  801295:	68 02 01 00 00       	push   $0x102
  80129a:	68 fa 29 80 00       	push   $0x8029fa
  80129f:	e8 64 ef ff ff       	call   800208 <_panic>
		}
		sys_yield();
  8012a4:	e8 a1 f9 ff ff       	call   800c4a <sys_yield>
  8012a9:	eb 08                	jmp    8012b3 <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  8012ab:	e8 7b f9 ff ff       	call   800c2b <sys_getenvid>
  8012b0:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8012b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b6:	c9                   	leave  
  8012b7:	c3                   	ret    

008012b8 <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  8012b8:	55                   	push   %ebp
  8012b9:	89 e5                	mov    %esp,%ebp
  8012bb:	53                   	push   %ebx
  8012bc:	83 ec 04             	sub    $0x4,%esp
  8012bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  8012c2:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8012c6:	74 36                	je     8012fe <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  8012c8:	83 ec 0c             	sub    $0xc,%esp
  8012cb:	8d 43 04             	lea    0x4(%ebx),%eax
  8012ce:	50                   	push   %eax
  8012cf:	e8 4d ff ff ff       	call   801221 <queue_pop>
  8012d4:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8012d7:	83 c4 08             	add    $0x8,%esp
  8012da:	6a 02                	push   $0x2
  8012dc:	50                   	push   %eax
  8012dd:	e8 4e fa ff ff       	call   800d30 <sys_env_set_status>
		if (r < 0) {
  8012e2:	83 c4 10             	add    $0x10,%esp
  8012e5:	85 c0                	test   %eax,%eax
  8012e7:	79 1d                	jns    801306 <mutex_unlock+0x4e>
			panic("%e\n", r);
  8012e9:	50                   	push   %eax
  8012ea:	68 72 2a 80 00       	push   $0x802a72
  8012ef:	68 16 01 00 00       	push   $0x116
  8012f4:	68 fa 29 80 00       	push   $0x8029fa
  8012f9:	e8 0a ef ff ff       	call   800208 <_panic>
  8012fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801303:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  801306:	e8 3f f9 ff ff       	call   800c4a <sys_yield>
}
  80130b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80130e:	c9                   	leave  
  80130f:	c3                   	ret    

00801310 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  801310:	55                   	push   %ebp
  801311:	89 e5                	mov    %esp,%ebp
  801313:	53                   	push   %ebx
  801314:	83 ec 04             	sub    $0x4,%esp
  801317:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  80131a:	e8 0c f9 ff ff       	call   800c2b <sys_getenvid>
  80131f:	83 ec 04             	sub    $0x4,%esp
  801322:	6a 07                	push   $0x7
  801324:	53                   	push   %ebx
  801325:	50                   	push   %eax
  801326:	e8 3e f9 ff ff       	call   800c69 <sys_page_alloc>
  80132b:	83 c4 10             	add    $0x10,%esp
  80132e:	85 c0                	test   %eax,%eax
  801330:	79 15                	jns    801347 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  801332:	50                   	push   %eax
  801333:	68 5d 2a 80 00       	push   $0x802a5d
  801338:	68 23 01 00 00       	push   $0x123
  80133d:	68 fa 29 80 00       	push   $0x8029fa
  801342:	e8 c1 ee ff ff       	call   800208 <_panic>
	}	
	mtx->locked = 0;
  801347:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  80134d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  801354:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  80135b:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  801362:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801365:	c9                   	leave  
  801366:	c3                   	ret    

00801367 <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  801367:	55                   	push   %ebp
  801368:	89 e5                	mov    %esp,%ebp
  80136a:	56                   	push   %esi
  80136b:	53                   	push   %ebx
  80136c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  80136f:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  801372:	eb 20                	jmp    801394 <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  801374:	83 ec 0c             	sub    $0xc,%esp
  801377:	56                   	push   %esi
  801378:	e8 a4 fe ff ff       	call   801221 <queue_pop>
  80137d:	83 c4 08             	add    $0x8,%esp
  801380:	6a 02                	push   $0x2
  801382:	50                   	push   %eax
  801383:	e8 a8 f9 ff ff       	call   800d30 <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  801388:	8b 43 04             	mov    0x4(%ebx),%eax
  80138b:	8b 40 04             	mov    0x4(%eax),%eax
  80138e:	89 43 04             	mov    %eax,0x4(%ebx)
  801391:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  801394:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  801398:	75 da                	jne    801374 <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  80139a:	83 ec 04             	sub    $0x4,%esp
  80139d:	68 00 10 00 00       	push   $0x1000
  8013a2:	6a 00                	push   $0x0
  8013a4:	53                   	push   %ebx
  8013a5:	e8 01 f6 ff ff       	call   8009ab <memset>
	mtx = NULL;
}
  8013aa:	83 c4 10             	add    $0x10,%esp
  8013ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013b0:	5b                   	pop    %ebx
  8013b1:	5e                   	pop    %esi
  8013b2:	5d                   	pop    %ebp
  8013b3:	c3                   	ret    

008013b4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013b4:	55                   	push   %ebp
  8013b5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ba:	05 00 00 00 30       	add    $0x30000000,%eax
  8013bf:	c1 e8 0c             	shr    $0xc,%eax
}
  8013c2:	5d                   	pop    %ebp
  8013c3:	c3                   	ret    

008013c4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013c4:	55                   	push   %ebp
  8013c5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8013c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ca:	05 00 00 00 30       	add    $0x30000000,%eax
  8013cf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013d4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013d9:	5d                   	pop    %ebp
  8013da:	c3                   	ret    

008013db <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013db:	55                   	push   %ebp
  8013dc:	89 e5                	mov    %esp,%ebp
  8013de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013e1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013e6:	89 c2                	mov    %eax,%edx
  8013e8:	c1 ea 16             	shr    $0x16,%edx
  8013eb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013f2:	f6 c2 01             	test   $0x1,%dl
  8013f5:	74 11                	je     801408 <fd_alloc+0x2d>
  8013f7:	89 c2                	mov    %eax,%edx
  8013f9:	c1 ea 0c             	shr    $0xc,%edx
  8013fc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801403:	f6 c2 01             	test   $0x1,%dl
  801406:	75 09                	jne    801411 <fd_alloc+0x36>
			*fd_store = fd;
  801408:	89 01                	mov    %eax,(%ecx)
			return 0;
  80140a:	b8 00 00 00 00       	mov    $0x0,%eax
  80140f:	eb 17                	jmp    801428 <fd_alloc+0x4d>
  801411:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801416:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80141b:	75 c9                	jne    8013e6 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80141d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801423:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801428:	5d                   	pop    %ebp
  801429:	c3                   	ret    

0080142a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80142a:	55                   	push   %ebp
  80142b:	89 e5                	mov    %esp,%ebp
  80142d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801430:	83 f8 1f             	cmp    $0x1f,%eax
  801433:	77 36                	ja     80146b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801435:	c1 e0 0c             	shl    $0xc,%eax
  801438:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80143d:	89 c2                	mov    %eax,%edx
  80143f:	c1 ea 16             	shr    $0x16,%edx
  801442:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801449:	f6 c2 01             	test   $0x1,%dl
  80144c:	74 24                	je     801472 <fd_lookup+0x48>
  80144e:	89 c2                	mov    %eax,%edx
  801450:	c1 ea 0c             	shr    $0xc,%edx
  801453:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80145a:	f6 c2 01             	test   $0x1,%dl
  80145d:	74 1a                	je     801479 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80145f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801462:	89 02                	mov    %eax,(%edx)
	return 0;
  801464:	b8 00 00 00 00       	mov    $0x0,%eax
  801469:	eb 13                	jmp    80147e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80146b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801470:	eb 0c                	jmp    80147e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801472:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801477:	eb 05                	jmp    80147e <fd_lookup+0x54>
  801479:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80147e:	5d                   	pop    %ebp
  80147f:	c3                   	ret    

00801480 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801480:	55                   	push   %ebp
  801481:	89 e5                	mov    %esp,%ebp
  801483:	83 ec 08             	sub    $0x8,%esp
  801486:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801489:	ba f8 2a 80 00       	mov    $0x802af8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80148e:	eb 13                	jmp    8014a3 <dev_lookup+0x23>
  801490:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801493:	39 08                	cmp    %ecx,(%eax)
  801495:	75 0c                	jne    8014a3 <dev_lookup+0x23>
			*dev = devtab[i];
  801497:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80149a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80149c:	b8 00 00 00 00       	mov    $0x0,%eax
  8014a1:	eb 31                	jmp    8014d4 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014a3:	8b 02                	mov    (%edx),%eax
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	75 e7                	jne    801490 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014a9:	a1 08 40 80 00       	mov    0x804008,%eax
  8014ae:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8014b4:	83 ec 04             	sub    $0x4,%esp
  8014b7:	51                   	push   %ecx
  8014b8:	50                   	push   %eax
  8014b9:	68 78 2a 80 00       	push   $0x802a78
  8014be:	e8 1e ee ff ff       	call   8002e1 <cprintf>
	*dev = 0;
  8014c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014c6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014cc:	83 c4 10             	add    $0x10,%esp
  8014cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014d4:	c9                   	leave  
  8014d5:	c3                   	ret    

008014d6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014d6:	55                   	push   %ebp
  8014d7:	89 e5                	mov    %esp,%ebp
  8014d9:	56                   	push   %esi
  8014da:	53                   	push   %ebx
  8014db:	83 ec 10             	sub    $0x10,%esp
  8014de:	8b 75 08             	mov    0x8(%ebp),%esi
  8014e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e7:	50                   	push   %eax
  8014e8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014ee:	c1 e8 0c             	shr    $0xc,%eax
  8014f1:	50                   	push   %eax
  8014f2:	e8 33 ff ff ff       	call   80142a <fd_lookup>
  8014f7:	83 c4 08             	add    $0x8,%esp
  8014fa:	85 c0                	test   %eax,%eax
  8014fc:	78 05                	js     801503 <fd_close+0x2d>
	    || fd != fd2)
  8014fe:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801501:	74 0c                	je     80150f <fd_close+0x39>
		return (must_exist ? r : 0);
  801503:	84 db                	test   %bl,%bl
  801505:	ba 00 00 00 00       	mov    $0x0,%edx
  80150a:	0f 44 c2             	cmove  %edx,%eax
  80150d:	eb 41                	jmp    801550 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80150f:	83 ec 08             	sub    $0x8,%esp
  801512:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801515:	50                   	push   %eax
  801516:	ff 36                	pushl  (%esi)
  801518:	e8 63 ff ff ff       	call   801480 <dev_lookup>
  80151d:	89 c3                	mov    %eax,%ebx
  80151f:	83 c4 10             	add    $0x10,%esp
  801522:	85 c0                	test   %eax,%eax
  801524:	78 1a                	js     801540 <fd_close+0x6a>
		if (dev->dev_close)
  801526:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801529:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80152c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801531:	85 c0                	test   %eax,%eax
  801533:	74 0b                	je     801540 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801535:	83 ec 0c             	sub    $0xc,%esp
  801538:	56                   	push   %esi
  801539:	ff d0                	call   *%eax
  80153b:	89 c3                	mov    %eax,%ebx
  80153d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801540:	83 ec 08             	sub    $0x8,%esp
  801543:	56                   	push   %esi
  801544:	6a 00                	push   $0x0
  801546:	e8 a3 f7 ff ff       	call   800cee <sys_page_unmap>
	return r;
  80154b:	83 c4 10             	add    $0x10,%esp
  80154e:	89 d8                	mov    %ebx,%eax
}
  801550:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801553:	5b                   	pop    %ebx
  801554:	5e                   	pop    %esi
  801555:	5d                   	pop    %ebp
  801556:	c3                   	ret    

00801557 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801557:	55                   	push   %ebp
  801558:	89 e5                	mov    %esp,%ebp
  80155a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80155d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801560:	50                   	push   %eax
  801561:	ff 75 08             	pushl  0x8(%ebp)
  801564:	e8 c1 fe ff ff       	call   80142a <fd_lookup>
  801569:	83 c4 08             	add    $0x8,%esp
  80156c:	85 c0                	test   %eax,%eax
  80156e:	78 10                	js     801580 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801570:	83 ec 08             	sub    $0x8,%esp
  801573:	6a 01                	push   $0x1
  801575:	ff 75 f4             	pushl  -0xc(%ebp)
  801578:	e8 59 ff ff ff       	call   8014d6 <fd_close>
  80157d:	83 c4 10             	add    $0x10,%esp
}
  801580:	c9                   	leave  
  801581:	c3                   	ret    

00801582 <close_all>:

void
close_all(void)
{
  801582:	55                   	push   %ebp
  801583:	89 e5                	mov    %esp,%ebp
  801585:	53                   	push   %ebx
  801586:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801589:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80158e:	83 ec 0c             	sub    $0xc,%esp
  801591:	53                   	push   %ebx
  801592:	e8 c0 ff ff ff       	call   801557 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801597:	83 c3 01             	add    $0x1,%ebx
  80159a:	83 c4 10             	add    $0x10,%esp
  80159d:	83 fb 20             	cmp    $0x20,%ebx
  8015a0:	75 ec                	jne    80158e <close_all+0xc>
		close(i);
}
  8015a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a5:	c9                   	leave  
  8015a6:	c3                   	ret    

008015a7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015a7:	55                   	push   %ebp
  8015a8:	89 e5                	mov    %esp,%ebp
  8015aa:	57                   	push   %edi
  8015ab:	56                   	push   %esi
  8015ac:	53                   	push   %ebx
  8015ad:	83 ec 2c             	sub    $0x2c,%esp
  8015b0:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015b3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015b6:	50                   	push   %eax
  8015b7:	ff 75 08             	pushl  0x8(%ebp)
  8015ba:	e8 6b fe ff ff       	call   80142a <fd_lookup>
  8015bf:	83 c4 08             	add    $0x8,%esp
  8015c2:	85 c0                	test   %eax,%eax
  8015c4:	0f 88 c1 00 00 00    	js     80168b <dup+0xe4>
		return r;
	close(newfdnum);
  8015ca:	83 ec 0c             	sub    $0xc,%esp
  8015cd:	56                   	push   %esi
  8015ce:	e8 84 ff ff ff       	call   801557 <close>

	newfd = INDEX2FD(newfdnum);
  8015d3:	89 f3                	mov    %esi,%ebx
  8015d5:	c1 e3 0c             	shl    $0xc,%ebx
  8015d8:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8015de:	83 c4 04             	add    $0x4,%esp
  8015e1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015e4:	e8 db fd ff ff       	call   8013c4 <fd2data>
  8015e9:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8015eb:	89 1c 24             	mov    %ebx,(%esp)
  8015ee:	e8 d1 fd ff ff       	call   8013c4 <fd2data>
  8015f3:	83 c4 10             	add    $0x10,%esp
  8015f6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015f9:	89 f8                	mov    %edi,%eax
  8015fb:	c1 e8 16             	shr    $0x16,%eax
  8015fe:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801605:	a8 01                	test   $0x1,%al
  801607:	74 37                	je     801640 <dup+0x99>
  801609:	89 f8                	mov    %edi,%eax
  80160b:	c1 e8 0c             	shr    $0xc,%eax
  80160e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801615:	f6 c2 01             	test   $0x1,%dl
  801618:	74 26                	je     801640 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80161a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801621:	83 ec 0c             	sub    $0xc,%esp
  801624:	25 07 0e 00 00       	and    $0xe07,%eax
  801629:	50                   	push   %eax
  80162a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80162d:	6a 00                	push   $0x0
  80162f:	57                   	push   %edi
  801630:	6a 00                	push   $0x0
  801632:	e8 75 f6 ff ff       	call   800cac <sys_page_map>
  801637:	89 c7                	mov    %eax,%edi
  801639:	83 c4 20             	add    $0x20,%esp
  80163c:	85 c0                	test   %eax,%eax
  80163e:	78 2e                	js     80166e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801640:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801643:	89 d0                	mov    %edx,%eax
  801645:	c1 e8 0c             	shr    $0xc,%eax
  801648:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80164f:	83 ec 0c             	sub    $0xc,%esp
  801652:	25 07 0e 00 00       	and    $0xe07,%eax
  801657:	50                   	push   %eax
  801658:	53                   	push   %ebx
  801659:	6a 00                	push   $0x0
  80165b:	52                   	push   %edx
  80165c:	6a 00                	push   $0x0
  80165e:	e8 49 f6 ff ff       	call   800cac <sys_page_map>
  801663:	89 c7                	mov    %eax,%edi
  801665:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801668:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80166a:	85 ff                	test   %edi,%edi
  80166c:	79 1d                	jns    80168b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80166e:	83 ec 08             	sub    $0x8,%esp
  801671:	53                   	push   %ebx
  801672:	6a 00                	push   $0x0
  801674:	e8 75 f6 ff ff       	call   800cee <sys_page_unmap>
	sys_page_unmap(0, nva);
  801679:	83 c4 08             	add    $0x8,%esp
  80167c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80167f:	6a 00                	push   $0x0
  801681:	e8 68 f6 ff ff       	call   800cee <sys_page_unmap>
	return r;
  801686:	83 c4 10             	add    $0x10,%esp
  801689:	89 f8                	mov    %edi,%eax
}
  80168b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80168e:	5b                   	pop    %ebx
  80168f:	5e                   	pop    %esi
  801690:	5f                   	pop    %edi
  801691:	5d                   	pop    %ebp
  801692:	c3                   	ret    

00801693 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	53                   	push   %ebx
  801697:	83 ec 14             	sub    $0x14,%esp
  80169a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80169d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016a0:	50                   	push   %eax
  8016a1:	53                   	push   %ebx
  8016a2:	e8 83 fd ff ff       	call   80142a <fd_lookup>
  8016a7:	83 c4 08             	add    $0x8,%esp
  8016aa:	89 c2                	mov    %eax,%edx
  8016ac:	85 c0                	test   %eax,%eax
  8016ae:	78 70                	js     801720 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b0:	83 ec 08             	sub    $0x8,%esp
  8016b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b6:	50                   	push   %eax
  8016b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ba:	ff 30                	pushl  (%eax)
  8016bc:	e8 bf fd ff ff       	call   801480 <dev_lookup>
  8016c1:	83 c4 10             	add    $0x10,%esp
  8016c4:	85 c0                	test   %eax,%eax
  8016c6:	78 4f                	js     801717 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016cb:	8b 42 08             	mov    0x8(%edx),%eax
  8016ce:	83 e0 03             	and    $0x3,%eax
  8016d1:	83 f8 01             	cmp    $0x1,%eax
  8016d4:	75 24                	jne    8016fa <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016d6:	a1 08 40 80 00       	mov    0x804008,%eax
  8016db:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8016e1:	83 ec 04             	sub    $0x4,%esp
  8016e4:	53                   	push   %ebx
  8016e5:	50                   	push   %eax
  8016e6:	68 bc 2a 80 00       	push   $0x802abc
  8016eb:	e8 f1 eb ff ff       	call   8002e1 <cprintf>
		return -E_INVAL;
  8016f0:	83 c4 10             	add    $0x10,%esp
  8016f3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016f8:	eb 26                	jmp    801720 <read+0x8d>
	}
	if (!dev->dev_read)
  8016fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016fd:	8b 40 08             	mov    0x8(%eax),%eax
  801700:	85 c0                	test   %eax,%eax
  801702:	74 17                	je     80171b <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801704:	83 ec 04             	sub    $0x4,%esp
  801707:	ff 75 10             	pushl  0x10(%ebp)
  80170a:	ff 75 0c             	pushl  0xc(%ebp)
  80170d:	52                   	push   %edx
  80170e:	ff d0                	call   *%eax
  801710:	89 c2                	mov    %eax,%edx
  801712:	83 c4 10             	add    $0x10,%esp
  801715:	eb 09                	jmp    801720 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801717:	89 c2                	mov    %eax,%edx
  801719:	eb 05                	jmp    801720 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80171b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801720:	89 d0                	mov    %edx,%eax
  801722:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801725:	c9                   	leave  
  801726:	c3                   	ret    

00801727 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801727:	55                   	push   %ebp
  801728:	89 e5                	mov    %esp,%ebp
  80172a:	57                   	push   %edi
  80172b:	56                   	push   %esi
  80172c:	53                   	push   %ebx
  80172d:	83 ec 0c             	sub    $0xc,%esp
  801730:	8b 7d 08             	mov    0x8(%ebp),%edi
  801733:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801736:	bb 00 00 00 00       	mov    $0x0,%ebx
  80173b:	eb 21                	jmp    80175e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80173d:	83 ec 04             	sub    $0x4,%esp
  801740:	89 f0                	mov    %esi,%eax
  801742:	29 d8                	sub    %ebx,%eax
  801744:	50                   	push   %eax
  801745:	89 d8                	mov    %ebx,%eax
  801747:	03 45 0c             	add    0xc(%ebp),%eax
  80174a:	50                   	push   %eax
  80174b:	57                   	push   %edi
  80174c:	e8 42 ff ff ff       	call   801693 <read>
		if (m < 0)
  801751:	83 c4 10             	add    $0x10,%esp
  801754:	85 c0                	test   %eax,%eax
  801756:	78 10                	js     801768 <readn+0x41>
			return m;
		if (m == 0)
  801758:	85 c0                	test   %eax,%eax
  80175a:	74 0a                	je     801766 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80175c:	01 c3                	add    %eax,%ebx
  80175e:	39 f3                	cmp    %esi,%ebx
  801760:	72 db                	jb     80173d <readn+0x16>
  801762:	89 d8                	mov    %ebx,%eax
  801764:	eb 02                	jmp    801768 <readn+0x41>
  801766:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801768:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80176b:	5b                   	pop    %ebx
  80176c:	5e                   	pop    %esi
  80176d:	5f                   	pop    %edi
  80176e:	5d                   	pop    %ebp
  80176f:	c3                   	ret    

00801770 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
  801773:	53                   	push   %ebx
  801774:	83 ec 14             	sub    $0x14,%esp
  801777:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80177a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80177d:	50                   	push   %eax
  80177e:	53                   	push   %ebx
  80177f:	e8 a6 fc ff ff       	call   80142a <fd_lookup>
  801784:	83 c4 08             	add    $0x8,%esp
  801787:	89 c2                	mov    %eax,%edx
  801789:	85 c0                	test   %eax,%eax
  80178b:	78 6b                	js     8017f8 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80178d:	83 ec 08             	sub    $0x8,%esp
  801790:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801793:	50                   	push   %eax
  801794:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801797:	ff 30                	pushl  (%eax)
  801799:	e8 e2 fc ff ff       	call   801480 <dev_lookup>
  80179e:	83 c4 10             	add    $0x10,%esp
  8017a1:	85 c0                	test   %eax,%eax
  8017a3:	78 4a                	js     8017ef <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017ac:	75 24                	jne    8017d2 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017ae:	a1 08 40 80 00       	mov    0x804008,%eax
  8017b3:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8017b9:	83 ec 04             	sub    $0x4,%esp
  8017bc:	53                   	push   %ebx
  8017bd:	50                   	push   %eax
  8017be:	68 d8 2a 80 00       	push   $0x802ad8
  8017c3:	e8 19 eb ff ff       	call   8002e1 <cprintf>
		return -E_INVAL;
  8017c8:	83 c4 10             	add    $0x10,%esp
  8017cb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017d0:	eb 26                	jmp    8017f8 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017d5:	8b 52 0c             	mov    0xc(%edx),%edx
  8017d8:	85 d2                	test   %edx,%edx
  8017da:	74 17                	je     8017f3 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017dc:	83 ec 04             	sub    $0x4,%esp
  8017df:	ff 75 10             	pushl  0x10(%ebp)
  8017e2:	ff 75 0c             	pushl  0xc(%ebp)
  8017e5:	50                   	push   %eax
  8017e6:	ff d2                	call   *%edx
  8017e8:	89 c2                	mov    %eax,%edx
  8017ea:	83 c4 10             	add    $0x10,%esp
  8017ed:	eb 09                	jmp    8017f8 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ef:	89 c2                	mov    %eax,%edx
  8017f1:	eb 05                	jmp    8017f8 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017f3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8017f8:	89 d0                	mov    %edx,%eax
  8017fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017fd:	c9                   	leave  
  8017fe:	c3                   	ret    

008017ff <seek>:

int
seek(int fdnum, off_t offset)
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801805:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801808:	50                   	push   %eax
  801809:	ff 75 08             	pushl  0x8(%ebp)
  80180c:	e8 19 fc ff ff       	call   80142a <fd_lookup>
  801811:	83 c4 08             	add    $0x8,%esp
  801814:	85 c0                	test   %eax,%eax
  801816:	78 0e                	js     801826 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801818:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80181b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80181e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801821:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801826:	c9                   	leave  
  801827:	c3                   	ret    

00801828 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801828:	55                   	push   %ebp
  801829:	89 e5                	mov    %esp,%ebp
  80182b:	53                   	push   %ebx
  80182c:	83 ec 14             	sub    $0x14,%esp
  80182f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801832:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801835:	50                   	push   %eax
  801836:	53                   	push   %ebx
  801837:	e8 ee fb ff ff       	call   80142a <fd_lookup>
  80183c:	83 c4 08             	add    $0x8,%esp
  80183f:	89 c2                	mov    %eax,%edx
  801841:	85 c0                	test   %eax,%eax
  801843:	78 68                	js     8018ad <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801845:	83 ec 08             	sub    $0x8,%esp
  801848:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80184b:	50                   	push   %eax
  80184c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80184f:	ff 30                	pushl  (%eax)
  801851:	e8 2a fc ff ff       	call   801480 <dev_lookup>
  801856:	83 c4 10             	add    $0x10,%esp
  801859:	85 c0                	test   %eax,%eax
  80185b:	78 47                	js     8018a4 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80185d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801860:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801864:	75 24                	jne    80188a <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801866:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80186b:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801871:	83 ec 04             	sub    $0x4,%esp
  801874:	53                   	push   %ebx
  801875:	50                   	push   %eax
  801876:	68 98 2a 80 00       	push   $0x802a98
  80187b:	e8 61 ea ff ff       	call   8002e1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801880:	83 c4 10             	add    $0x10,%esp
  801883:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801888:	eb 23                	jmp    8018ad <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  80188a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80188d:	8b 52 18             	mov    0x18(%edx),%edx
  801890:	85 d2                	test   %edx,%edx
  801892:	74 14                	je     8018a8 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801894:	83 ec 08             	sub    $0x8,%esp
  801897:	ff 75 0c             	pushl  0xc(%ebp)
  80189a:	50                   	push   %eax
  80189b:	ff d2                	call   *%edx
  80189d:	89 c2                	mov    %eax,%edx
  80189f:	83 c4 10             	add    $0x10,%esp
  8018a2:	eb 09                	jmp    8018ad <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a4:	89 c2                	mov    %eax,%edx
  8018a6:	eb 05                	jmp    8018ad <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018a8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8018ad:	89 d0                	mov    %edx,%eax
  8018af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b2:	c9                   	leave  
  8018b3:	c3                   	ret    

008018b4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018b4:	55                   	push   %ebp
  8018b5:	89 e5                	mov    %esp,%ebp
  8018b7:	53                   	push   %ebx
  8018b8:	83 ec 14             	sub    $0x14,%esp
  8018bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018c1:	50                   	push   %eax
  8018c2:	ff 75 08             	pushl  0x8(%ebp)
  8018c5:	e8 60 fb ff ff       	call   80142a <fd_lookup>
  8018ca:	83 c4 08             	add    $0x8,%esp
  8018cd:	89 c2                	mov    %eax,%edx
  8018cf:	85 c0                	test   %eax,%eax
  8018d1:	78 58                	js     80192b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018d3:	83 ec 08             	sub    $0x8,%esp
  8018d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d9:	50                   	push   %eax
  8018da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018dd:	ff 30                	pushl  (%eax)
  8018df:	e8 9c fb ff ff       	call   801480 <dev_lookup>
  8018e4:	83 c4 10             	add    $0x10,%esp
  8018e7:	85 c0                	test   %eax,%eax
  8018e9:	78 37                	js     801922 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8018eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ee:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018f2:	74 32                	je     801926 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018f4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018f7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018fe:	00 00 00 
	stat->st_isdir = 0;
  801901:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801908:	00 00 00 
	stat->st_dev = dev;
  80190b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801911:	83 ec 08             	sub    $0x8,%esp
  801914:	53                   	push   %ebx
  801915:	ff 75 f0             	pushl  -0x10(%ebp)
  801918:	ff 50 14             	call   *0x14(%eax)
  80191b:	89 c2                	mov    %eax,%edx
  80191d:	83 c4 10             	add    $0x10,%esp
  801920:	eb 09                	jmp    80192b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801922:	89 c2                	mov    %eax,%edx
  801924:	eb 05                	jmp    80192b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801926:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80192b:	89 d0                	mov    %edx,%eax
  80192d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801930:	c9                   	leave  
  801931:	c3                   	ret    

00801932 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801932:	55                   	push   %ebp
  801933:	89 e5                	mov    %esp,%ebp
  801935:	56                   	push   %esi
  801936:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801937:	83 ec 08             	sub    $0x8,%esp
  80193a:	6a 00                	push   $0x0
  80193c:	ff 75 08             	pushl  0x8(%ebp)
  80193f:	e8 e3 01 00 00       	call   801b27 <open>
  801944:	89 c3                	mov    %eax,%ebx
  801946:	83 c4 10             	add    $0x10,%esp
  801949:	85 c0                	test   %eax,%eax
  80194b:	78 1b                	js     801968 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80194d:	83 ec 08             	sub    $0x8,%esp
  801950:	ff 75 0c             	pushl  0xc(%ebp)
  801953:	50                   	push   %eax
  801954:	e8 5b ff ff ff       	call   8018b4 <fstat>
  801959:	89 c6                	mov    %eax,%esi
	close(fd);
  80195b:	89 1c 24             	mov    %ebx,(%esp)
  80195e:	e8 f4 fb ff ff       	call   801557 <close>
	return r;
  801963:	83 c4 10             	add    $0x10,%esp
  801966:	89 f0                	mov    %esi,%eax
}
  801968:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80196b:	5b                   	pop    %ebx
  80196c:	5e                   	pop    %esi
  80196d:	5d                   	pop    %ebp
  80196e:	c3                   	ret    

0080196f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80196f:	55                   	push   %ebp
  801970:	89 e5                	mov    %esp,%ebp
  801972:	56                   	push   %esi
  801973:	53                   	push   %ebx
  801974:	89 c6                	mov    %eax,%esi
  801976:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801978:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80197f:	75 12                	jne    801993 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801981:	83 ec 0c             	sub    $0xc,%esp
  801984:	6a 01                	push   $0x1
  801986:	e8 a4 09 00 00       	call   80232f <ipc_find_env>
  80198b:	a3 04 40 80 00       	mov    %eax,0x804004
  801990:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801993:	6a 07                	push   $0x7
  801995:	68 00 50 80 00       	push   $0x805000
  80199a:	56                   	push   %esi
  80199b:	ff 35 04 40 80 00    	pushl  0x804004
  8019a1:	e8 27 09 00 00       	call   8022cd <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019a6:	83 c4 0c             	add    $0xc,%esp
  8019a9:	6a 00                	push   $0x0
  8019ab:	53                   	push   %ebx
  8019ac:	6a 00                	push   $0x0
  8019ae:	e8 9f 08 00 00       	call   802252 <ipc_recv>
}
  8019b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b6:	5b                   	pop    %ebx
  8019b7:	5e                   	pop    %esi
  8019b8:	5d                   	pop    %ebp
  8019b9:	c3                   	ret    

008019ba <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c3:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8019cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ce:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d8:	b8 02 00 00 00       	mov    $0x2,%eax
  8019dd:	e8 8d ff ff ff       	call   80196f <fsipc>
}
  8019e2:	c9                   	leave  
  8019e3:	c3                   	ret    

008019e4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019e4:	55                   	push   %ebp
  8019e5:	89 e5                	mov    %esp,%ebp
  8019e7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8019f0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8019fa:	b8 06 00 00 00       	mov    $0x6,%eax
  8019ff:	e8 6b ff ff ff       	call   80196f <fsipc>
}
  801a04:	c9                   	leave  
  801a05:	c3                   	ret    

00801a06 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a06:	55                   	push   %ebp
  801a07:	89 e5                	mov    %esp,%ebp
  801a09:	53                   	push   %ebx
  801a0a:	83 ec 04             	sub    $0x4,%esp
  801a0d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a10:	8b 45 08             	mov    0x8(%ebp),%eax
  801a13:	8b 40 0c             	mov    0xc(%eax),%eax
  801a16:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a1b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a20:	b8 05 00 00 00       	mov    $0x5,%eax
  801a25:	e8 45 ff ff ff       	call   80196f <fsipc>
  801a2a:	85 c0                	test   %eax,%eax
  801a2c:	78 2c                	js     801a5a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a2e:	83 ec 08             	sub    $0x8,%esp
  801a31:	68 00 50 80 00       	push   $0x805000
  801a36:	53                   	push   %ebx
  801a37:	e8 2a ee ff ff       	call   800866 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a3c:	a1 80 50 80 00       	mov    0x805080,%eax
  801a41:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a47:	a1 84 50 80 00       	mov    0x805084,%eax
  801a4c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a52:	83 c4 10             	add    $0x10,%esp
  801a55:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a5a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a5d:	c9                   	leave  
  801a5e:	c3                   	ret    

00801a5f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	83 ec 0c             	sub    $0xc,%esp
  801a65:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a68:	8b 55 08             	mov    0x8(%ebp),%edx
  801a6b:	8b 52 0c             	mov    0xc(%edx),%edx
  801a6e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801a74:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a79:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a7e:	0f 47 c2             	cmova  %edx,%eax
  801a81:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801a86:	50                   	push   %eax
  801a87:	ff 75 0c             	pushl  0xc(%ebp)
  801a8a:	68 08 50 80 00       	push   $0x805008
  801a8f:	e8 64 ef ff ff       	call   8009f8 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801a94:	ba 00 00 00 00       	mov    $0x0,%edx
  801a99:	b8 04 00 00 00       	mov    $0x4,%eax
  801a9e:	e8 cc fe ff ff       	call   80196f <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801aa3:	c9                   	leave  
  801aa4:	c3                   	ret    

00801aa5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801aa5:	55                   	push   %ebp
  801aa6:	89 e5                	mov    %esp,%ebp
  801aa8:	56                   	push   %esi
  801aa9:	53                   	push   %ebx
  801aaa:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801aad:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab0:	8b 40 0c             	mov    0xc(%eax),%eax
  801ab3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801ab8:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801abe:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac3:	b8 03 00 00 00       	mov    $0x3,%eax
  801ac8:	e8 a2 fe ff ff       	call   80196f <fsipc>
  801acd:	89 c3                	mov    %eax,%ebx
  801acf:	85 c0                	test   %eax,%eax
  801ad1:	78 4b                	js     801b1e <devfile_read+0x79>
		return r;
	assert(r <= n);
  801ad3:	39 c6                	cmp    %eax,%esi
  801ad5:	73 16                	jae    801aed <devfile_read+0x48>
  801ad7:	68 08 2b 80 00       	push   $0x802b08
  801adc:	68 0f 2b 80 00       	push   $0x802b0f
  801ae1:	6a 7c                	push   $0x7c
  801ae3:	68 24 2b 80 00       	push   $0x802b24
  801ae8:	e8 1b e7 ff ff       	call   800208 <_panic>
	assert(r <= PGSIZE);
  801aed:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801af2:	7e 16                	jle    801b0a <devfile_read+0x65>
  801af4:	68 2f 2b 80 00       	push   $0x802b2f
  801af9:	68 0f 2b 80 00       	push   $0x802b0f
  801afe:	6a 7d                	push   $0x7d
  801b00:	68 24 2b 80 00       	push   $0x802b24
  801b05:	e8 fe e6 ff ff       	call   800208 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b0a:	83 ec 04             	sub    $0x4,%esp
  801b0d:	50                   	push   %eax
  801b0e:	68 00 50 80 00       	push   $0x805000
  801b13:	ff 75 0c             	pushl  0xc(%ebp)
  801b16:	e8 dd ee ff ff       	call   8009f8 <memmove>
	return r;
  801b1b:	83 c4 10             	add    $0x10,%esp
}
  801b1e:	89 d8                	mov    %ebx,%eax
  801b20:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b23:	5b                   	pop    %ebx
  801b24:	5e                   	pop    %esi
  801b25:	5d                   	pop    %ebp
  801b26:	c3                   	ret    

00801b27 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b27:	55                   	push   %ebp
  801b28:	89 e5                	mov    %esp,%ebp
  801b2a:	53                   	push   %ebx
  801b2b:	83 ec 20             	sub    $0x20,%esp
  801b2e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b31:	53                   	push   %ebx
  801b32:	e8 f6 ec ff ff       	call   80082d <strlen>
  801b37:	83 c4 10             	add    $0x10,%esp
  801b3a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b3f:	7f 67                	jg     801ba8 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b41:	83 ec 0c             	sub    $0xc,%esp
  801b44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b47:	50                   	push   %eax
  801b48:	e8 8e f8 ff ff       	call   8013db <fd_alloc>
  801b4d:	83 c4 10             	add    $0x10,%esp
		return r;
  801b50:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b52:	85 c0                	test   %eax,%eax
  801b54:	78 57                	js     801bad <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b56:	83 ec 08             	sub    $0x8,%esp
  801b59:	53                   	push   %ebx
  801b5a:	68 00 50 80 00       	push   $0x805000
  801b5f:	e8 02 ed ff ff       	call   800866 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b64:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b67:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b6f:	b8 01 00 00 00       	mov    $0x1,%eax
  801b74:	e8 f6 fd ff ff       	call   80196f <fsipc>
  801b79:	89 c3                	mov    %eax,%ebx
  801b7b:	83 c4 10             	add    $0x10,%esp
  801b7e:	85 c0                	test   %eax,%eax
  801b80:	79 14                	jns    801b96 <open+0x6f>
		fd_close(fd, 0);
  801b82:	83 ec 08             	sub    $0x8,%esp
  801b85:	6a 00                	push   $0x0
  801b87:	ff 75 f4             	pushl  -0xc(%ebp)
  801b8a:	e8 47 f9 ff ff       	call   8014d6 <fd_close>
		return r;
  801b8f:	83 c4 10             	add    $0x10,%esp
  801b92:	89 da                	mov    %ebx,%edx
  801b94:	eb 17                	jmp    801bad <open+0x86>
	}

	return fd2num(fd);
  801b96:	83 ec 0c             	sub    $0xc,%esp
  801b99:	ff 75 f4             	pushl  -0xc(%ebp)
  801b9c:	e8 13 f8 ff ff       	call   8013b4 <fd2num>
  801ba1:	89 c2                	mov    %eax,%edx
  801ba3:	83 c4 10             	add    $0x10,%esp
  801ba6:	eb 05                	jmp    801bad <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ba8:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801bad:	89 d0                	mov    %edx,%eax
  801baf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb2:	c9                   	leave  
  801bb3:	c3                   	ret    

00801bb4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bb4:	55                   	push   %ebp
  801bb5:	89 e5                	mov    %esp,%ebp
  801bb7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bba:	ba 00 00 00 00       	mov    $0x0,%edx
  801bbf:	b8 08 00 00 00       	mov    $0x8,%eax
  801bc4:	e8 a6 fd ff ff       	call   80196f <fsipc>
}
  801bc9:	c9                   	leave  
  801bca:	c3                   	ret    

00801bcb <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801bcb:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801bcf:	7e 37                	jle    801c08 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801bd1:	55                   	push   %ebp
  801bd2:	89 e5                	mov    %esp,%ebp
  801bd4:	53                   	push   %ebx
  801bd5:	83 ec 08             	sub    $0x8,%esp
  801bd8:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801bda:	ff 70 04             	pushl  0x4(%eax)
  801bdd:	8d 40 10             	lea    0x10(%eax),%eax
  801be0:	50                   	push   %eax
  801be1:	ff 33                	pushl  (%ebx)
  801be3:	e8 88 fb ff ff       	call   801770 <write>
		if (result > 0)
  801be8:	83 c4 10             	add    $0x10,%esp
  801beb:	85 c0                	test   %eax,%eax
  801bed:	7e 03                	jle    801bf2 <writebuf+0x27>
			b->result += result;
  801bef:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801bf2:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bf5:	74 0d                	je     801c04 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801bf7:	85 c0                	test   %eax,%eax
  801bf9:	ba 00 00 00 00       	mov    $0x0,%edx
  801bfe:	0f 4f c2             	cmovg  %edx,%eax
  801c01:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801c04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c07:	c9                   	leave  
  801c08:	f3 c3                	repz ret 

00801c0a <putch>:

static void
putch(int ch, void *thunk)
{
  801c0a:	55                   	push   %ebp
  801c0b:	89 e5                	mov    %esp,%ebp
  801c0d:	53                   	push   %ebx
  801c0e:	83 ec 04             	sub    $0x4,%esp
  801c11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801c14:	8b 53 04             	mov    0x4(%ebx),%edx
  801c17:	8d 42 01             	lea    0x1(%edx),%eax
  801c1a:	89 43 04             	mov    %eax,0x4(%ebx)
  801c1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c20:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801c24:	3d 00 01 00 00       	cmp    $0x100,%eax
  801c29:	75 0e                	jne    801c39 <putch+0x2f>
		writebuf(b);
  801c2b:	89 d8                	mov    %ebx,%eax
  801c2d:	e8 99 ff ff ff       	call   801bcb <writebuf>
		b->idx = 0;
  801c32:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801c39:	83 c4 04             	add    $0x4,%esp
  801c3c:	5b                   	pop    %ebx
  801c3d:	5d                   	pop    %ebp
  801c3e:	c3                   	ret    

00801c3f <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801c3f:	55                   	push   %ebp
  801c40:	89 e5                	mov    %esp,%ebp
  801c42:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801c48:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4b:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801c51:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801c58:	00 00 00 
	b.result = 0;
  801c5b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801c62:	00 00 00 
	b.error = 1;
  801c65:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801c6c:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801c6f:	ff 75 10             	pushl  0x10(%ebp)
  801c72:	ff 75 0c             	pushl  0xc(%ebp)
  801c75:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801c7b:	50                   	push   %eax
  801c7c:	68 0a 1c 80 00       	push   $0x801c0a
  801c81:	e8 92 e7 ff ff       	call   800418 <vprintfmt>
	if (b.idx > 0)
  801c86:	83 c4 10             	add    $0x10,%esp
  801c89:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801c90:	7e 0b                	jle    801c9d <vfprintf+0x5e>
		writebuf(&b);
  801c92:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801c98:	e8 2e ff ff ff       	call   801bcb <writebuf>

	return (b.result ? b.result : b.error);
  801c9d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801ca3:	85 c0                	test   %eax,%eax
  801ca5:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801cac:	c9                   	leave  
  801cad:	c3                   	ret    

00801cae <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801cae:	55                   	push   %ebp
  801caf:	89 e5                	mov    %esp,%ebp
  801cb1:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801cb4:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801cb7:	50                   	push   %eax
  801cb8:	ff 75 0c             	pushl  0xc(%ebp)
  801cbb:	ff 75 08             	pushl  0x8(%ebp)
  801cbe:	e8 7c ff ff ff       	call   801c3f <vfprintf>
	va_end(ap);

	return cnt;
}
  801cc3:	c9                   	leave  
  801cc4:	c3                   	ret    

00801cc5 <printf>:

int
printf(const char *fmt, ...)
{
  801cc5:	55                   	push   %ebp
  801cc6:	89 e5                	mov    %esp,%ebp
  801cc8:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801ccb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801cce:	50                   	push   %eax
  801ccf:	ff 75 08             	pushl  0x8(%ebp)
  801cd2:	6a 01                	push   $0x1
  801cd4:	e8 66 ff ff ff       	call   801c3f <vfprintf>
	va_end(ap);

	return cnt;
}
  801cd9:	c9                   	leave  
  801cda:	c3                   	ret    

00801cdb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801cdb:	55                   	push   %ebp
  801cdc:	89 e5                	mov    %esp,%ebp
  801cde:	56                   	push   %esi
  801cdf:	53                   	push   %ebx
  801ce0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ce3:	83 ec 0c             	sub    $0xc,%esp
  801ce6:	ff 75 08             	pushl  0x8(%ebp)
  801ce9:	e8 d6 f6 ff ff       	call   8013c4 <fd2data>
  801cee:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801cf0:	83 c4 08             	add    $0x8,%esp
  801cf3:	68 3b 2b 80 00       	push   $0x802b3b
  801cf8:	53                   	push   %ebx
  801cf9:	e8 68 eb ff ff       	call   800866 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801cfe:	8b 46 04             	mov    0x4(%esi),%eax
  801d01:	2b 06                	sub    (%esi),%eax
  801d03:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d09:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d10:	00 00 00 
	stat->st_dev = &devpipe;
  801d13:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801d1a:	30 80 00 
	return 0;
}
  801d1d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d22:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d25:	5b                   	pop    %ebx
  801d26:	5e                   	pop    %esi
  801d27:	5d                   	pop    %ebp
  801d28:	c3                   	ret    

00801d29 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d29:	55                   	push   %ebp
  801d2a:	89 e5                	mov    %esp,%ebp
  801d2c:	53                   	push   %ebx
  801d2d:	83 ec 0c             	sub    $0xc,%esp
  801d30:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d33:	53                   	push   %ebx
  801d34:	6a 00                	push   $0x0
  801d36:	e8 b3 ef ff ff       	call   800cee <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d3b:	89 1c 24             	mov    %ebx,(%esp)
  801d3e:	e8 81 f6 ff ff       	call   8013c4 <fd2data>
  801d43:	83 c4 08             	add    $0x8,%esp
  801d46:	50                   	push   %eax
  801d47:	6a 00                	push   $0x0
  801d49:	e8 a0 ef ff ff       	call   800cee <sys_page_unmap>
}
  801d4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d51:	c9                   	leave  
  801d52:	c3                   	ret    

00801d53 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d53:	55                   	push   %ebp
  801d54:	89 e5                	mov    %esp,%ebp
  801d56:	57                   	push   %edi
  801d57:	56                   	push   %esi
  801d58:	53                   	push   %ebx
  801d59:	83 ec 1c             	sub    $0x1c,%esp
  801d5c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d5f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d61:	a1 08 40 80 00       	mov    0x804008,%eax
  801d66:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d6c:	83 ec 0c             	sub    $0xc,%esp
  801d6f:	ff 75 e0             	pushl  -0x20(%ebp)
  801d72:	e8 fd 05 00 00       	call   802374 <pageref>
  801d77:	89 c3                	mov    %eax,%ebx
  801d79:	89 3c 24             	mov    %edi,(%esp)
  801d7c:	e8 f3 05 00 00       	call   802374 <pageref>
  801d81:	83 c4 10             	add    $0x10,%esp
  801d84:	39 c3                	cmp    %eax,%ebx
  801d86:	0f 94 c1             	sete   %cl
  801d89:	0f b6 c9             	movzbl %cl,%ecx
  801d8c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d8f:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801d95:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  801d9b:	39 ce                	cmp    %ecx,%esi
  801d9d:	74 1e                	je     801dbd <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801d9f:	39 c3                	cmp    %eax,%ebx
  801da1:	75 be                	jne    801d61 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801da3:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  801da9:	ff 75 e4             	pushl  -0x1c(%ebp)
  801dac:	50                   	push   %eax
  801dad:	56                   	push   %esi
  801dae:	68 42 2b 80 00       	push   $0x802b42
  801db3:	e8 29 e5 ff ff       	call   8002e1 <cprintf>
  801db8:	83 c4 10             	add    $0x10,%esp
  801dbb:	eb a4                	jmp    801d61 <_pipeisclosed+0xe>
	}
}
  801dbd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dc3:	5b                   	pop    %ebx
  801dc4:	5e                   	pop    %esi
  801dc5:	5f                   	pop    %edi
  801dc6:	5d                   	pop    %ebp
  801dc7:	c3                   	ret    

00801dc8 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dc8:	55                   	push   %ebp
  801dc9:	89 e5                	mov    %esp,%ebp
  801dcb:	57                   	push   %edi
  801dcc:	56                   	push   %esi
  801dcd:	53                   	push   %ebx
  801dce:	83 ec 28             	sub    $0x28,%esp
  801dd1:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801dd4:	56                   	push   %esi
  801dd5:	e8 ea f5 ff ff       	call   8013c4 <fd2data>
  801dda:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ddc:	83 c4 10             	add    $0x10,%esp
  801ddf:	bf 00 00 00 00       	mov    $0x0,%edi
  801de4:	eb 4b                	jmp    801e31 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801de6:	89 da                	mov    %ebx,%edx
  801de8:	89 f0                	mov    %esi,%eax
  801dea:	e8 64 ff ff ff       	call   801d53 <_pipeisclosed>
  801def:	85 c0                	test   %eax,%eax
  801df1:	75 48                	jne    801e3b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801df3:	e8 52 ee ff ff       	call   800c4a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801df8:	8b 43 04             	mov    0x4(%ebx),%eax
  801dfb:	8b 0b                	mov    (%ebx),%ecx
  801dfd:	8d 51 20             	lea    0x20(%ecx),%edx
  801e00:	39 d0                	cmp    %edx,%eax
  801e02:	73 e2                	jae    801de6 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e07:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e0b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e0e:	89 c2                	mov    %eax,%edx
  801e10:	c1 fa 1f             	sar    $0x1f,%edx
  801e13:	89 d1                	mov    %edx,%ecx
  801e15:	c1 e9 1b             	shr    $0x1b,%ecx
  801e18:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e1b:	83 e2 1f             	and    $0x1f,%edx
  801e1e:	29 ca                	sub    %ecx,%edx
  801e20:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e24:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e28:	83 c0 01             	add    $0x1,%eax
  801e2b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e2e:	83 c7 01             	add    $0x1,%edi
  801e31:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e34:	75 c2                	jne    801df8 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e36:	8b 45 10             	mov    0x10(%ebp),%eax
  801e39:	eb 05                	jmp    801e40 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e3b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e43:	5b                   	pop    %ebx
  801e44:	5e                   	pop    %esi
  801e45:	5f                   	pop    %edi
  801e46:	5d                   	pop    %ebp
  801e47:	c3                   	ret    

00801e48 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e48:	55                   	push   %ebp
  801e49:	89 e5                	mov    %esp,%ebp
  801e4b:	57                   	push   %edi
  801e4c:	56                   	push   %esi
  801e4d:	53                   	push   %ebx
  801e4e:	83 ec 18             	sub    $0x18,%esp
  801e51:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e54:	57                   	push   %edi
  801e55:	e8 6a f5 ff ff       	call   8013c4 <fd2data>
  801e5a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e5c:	83 c4 10             	add    $0x10,%esp
  801e5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e64:	eb 3d                	jmp    801ea3 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e66:	85 db                	test   %ebx,%ebx
  801e68:	74 04                	je     801e6e <devpipe_read+0x26>
				return i;
  801e6a:	89 d8                	mov    %ebx,%eax
  801e6c:	eb 44                	jmp    801eb2 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e6e:	89 f2                	mov    %esi,%edx
  801e70:	89 f8                	mov    %edi,%eax
  801e72:	e8 dc fe ff ff       	call   801d53 <_pipeisclosed>
  801e77:	85 c0                	test   %eax,%eax
  801e79:	75 32                	jne    801ead <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e7b:	e8 ca ed ff ff       	call   800c4a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e80:	8b 06                	mov    (%esi),%eax
  801e82:	3b 46 04             	cmp    0x4(%esi),%eax
  801e85:	74 df                	je     801e66 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e87:	99                   	cltd   
  801e88:	c1 ea 1b             	shr    $0x1b,%edx
  801e8b:	01 d0                	add    %edx,%eax
  801e8d:	83 e0 1f             	and    $0x1f,%eax
  801e90:	29 d0                	sub    %edx,%eax
  801e92:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e9a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e9d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ea0:	83 c3 01             	add    $0x1,%ebx
  801ea3:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ea6:	75 d8                	jne    801e80 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ea8:	8b 45 10             	mov    0x10(%ebp),%eax
  801eab:	eb 05                	jmp    801eb2 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ead:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801eb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eb5:	5b                   	pop    %ebx
  801eb6:	5e                   	pop    %esi
  801eb7:	5f                   	pop    %edi
  801eb8:	5d                   	pop    %ebp
  801eb9:	c3                   	ret    

00801eba <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801eba:	55                   	push   %ebp
  801ebb:	89 e5                	mov    %esp,%ebp
  801ebd:	56                   	push   %esi
  801ebe:	53                   	push   %ebx
  801ebf:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ec2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ec5:	50                   	push   %eax
  801ec6:	e8 10 f5 ff ff       	call   8013db <fd_alloc>
  801ecb:	83 c4 10             	add    $0x10,%esp
  801ece:	89 c2                	mov    %eax,%edx
  801ed0:	85 c0                	test   %eax,%eax
  801ed2:	0f 88 2c 01 00 00    	js     802004 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ed8:	83 ec 04             	sub    $0x4,%esp
  801edb:	68 07 04 00 00       	push   $0x407
  801ee0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ee3:	6a 00                	push   $0x0
  801ee5:	e8 7f ed ff ff       	call   800c69 <sys_page_alloc>
  801eea:	83 c4 10             	add    $0x10,%esp
  801eed:	89 c2                	mov    %eax,%edx
  801eef:	85 c0                	test   %eax,%eax
  801ef1:	0f 88 0d 01 00 00    	js     802004 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ef7:	83 ec 0c             	sub    $0xc,%esp
  801efa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801efd:	50                   	push   %eax
  801efe:	e8 d8 f4 ff ff       	call   8013db <fd_alloc>
  801f03:	89 c3                	mov    %eax,%ebx
  801f05:	83 c4 10             	add    $0x10,%esp
  801f08:	85 c0                	test   %eax,%eax
  801f0a:	0f 88 e2 00 00 00    	js     801ff2 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f10:	83 ec 04             	sub    $0x4,%esp
  801f13:	68 07 04 00 00       	push   $0x407
  801f18:	ff 75 f0             	pushl  -0x10(%ebp)
  801f1b:	6a 00                	push   $0x0
  801f1d:	e8 47 ed ff ff       	call   800c69 <sys_page_alloc>
  801f22:	89 c3                	mov    %eax,%ebx
  801f24:	83 c4 10             	add    $0x10,%esp
  801f27:	85 c0                	test   %eax,%eax
  801f29:	0f 88 c3 00 00 00    	js     801ff2 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f2f:	83 ec 0c             	sub    $0xc,%esp
  801f32:	ff 75 f4             	pushl  -0xc(%ebp)
  801f35:	e8 8a f4 ff ff       	call   8013c4 <fd2data>
  801f3a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f3c:	83 c4 0c             	add    $0xc,%esp
  801f3f:	68 07 04 00 00       	push   $0x407
  801f44:	50                   	push   %eax
  801f45:	6a 00                	push   $0x0
  801f47:	e8 1d ed ff ff       	call   800c69 <sys_page_alloc>
  801f4c:	89 c3                	mov    %eax,%ebx
  801f4e:	83 c4 10             	add    $0x10,%esp
  801f51:	85 c0                	test   %eax,%eax
  801f53:	0f 88 89 00 00 00    	js     801fe2 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f59:	83 ec 0c             	sub    $0xc,%esp
  801f5c:	ff 75 f0             	pushl  -0x10(%ebp)
  801f5f:	e8 60 f4 ff ff       	call   8013c4 <fd2data>
  801f64:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f6b:	50                   	push   %eax
  801f6c:	6a 00                	push   $0x0
  801f6e:	56                   	push   %esi
  801f6f:	6a 00                	push   $0x0
  801f71:	e8 36 ed ff ff       	call   800cac <sys_page_map>
  801f76:	89 c3                	mov    %eax,%ebx
  801f78:	83 c4 20             	add    $0x20,%esp
  801f7b:	85 c0                	test   %eax,%eax
  801f7d:	78 55                	js     801fd4 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f7f:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f88:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f8d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f94:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801f9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f9d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fa2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801fa9:	83 ec 0c             	sub    $0xc,%esp
  801fac:	ff 75 f4             	pushl  -0xc(%ebp)
  801faf:	e8 00 f4 ff ff       	call   8013b4 <fd2num>
  801fb4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fb7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801fb9:	83 c4 04             	add    $0x4,%esp
  801fbc:	ff 75 f0             	pushl  -0x10(%ebp)
  801fbf:	e8 f0 f3 ff ff       	call   8013b4 <fd2num>
  801fc4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fc7:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801fca:	83 c4 10             	add    $0x10,%esp
  801fcd:	ba 00 00 00 00       	mov    $0x0,%edx
  801fd2:	eb 30                	jmp    802004 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801fd4:	83 ec 08             	sub    $0x8,%esp
  801fd7:	56                   	push   %esi
  801fd8:	6a 00                	push   $0x0
  801fda:	e8 0f ed ff ff       	call   800cee <sys_page_unmap>
  801fdf:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801fe2:	83 ec 08             	sub    $0x8,%esp
  801fe5:	ff 75 f0             	pushl  -0x10(%ebp)
  801fe8:	6a 00                	push   $0x0
  801fea:	e8 ff ec ff ff       	call   800cee <sys_page_unmap>
  801fef:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ff2:	83 ec 08             	sub    $0x8,%esp
  801ff5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ff8:	6a 00                	push   $0x0
  801ffa:	e8 ef ec ff ff       	call   800cee <sys_page_unmap>
  801fff:	83 c4 10             	add    $0x10,%esp
  802002:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802004:	89 d0                	mov    %edx,%eax
  802006:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802009:	5b                   	pop    %ebx
  80200a:	5e                   	pop    %esi
  80200b:	5d                   	pop    %ebp
  80200c:	c3                   	ret    

0080200d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80200d:	55                   	push   %ebp
  80200e:	89 e5                	mov    %esp,%ebp
  802010:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802013:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802016:	50                   	push   %eax
  802017:	ff 75 08             	pushl  0x8(%ebp)
  80201a:	e8 0b f4 ff ff       	call   80142a <fd_lookup>
  80201f:	83 c4 10             	add    $0x10,%esp
  802022:	85 c0                	test   %eax,%eax
  802024:	78 18                	js     80203e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802026:	83 ec 0c             	sub    $0xc,%esp
  802029:	ff 75 f4             	pushl  -0xc(%ebp)
  80202c:	e8 93 f3 ff ff       	call   8013c4 <fd2data>
	return _pipeisclosed(fd, p);
  802031:	89 c2                	mov    %eax,%edx
  802033:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802036:	e8 18 fd ff ff       	call   801d53 <_pipeisclosed>
  80203b:	83 c4 10             	add    $0x10,%esp
}
  80203e:	c9                   	leave  
  80203f:	c3                   	ret    

00802040 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802040:	55                   	push   %ebp
  802041:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802043:	b8 00 00 00 00       	mov    $0x0,%eax
  802048:	5d                   	pop    %ebp
  802049:	c3                   	ret    

0080204a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80204a:	55                   	push   %ebp
  80204b:	89 e5                	mov    %esp,%ebp
  80204d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802050:	68 5a 2b 80 00       	push   $0x802b5a
  802055:	ff 75 0c             	pushl  0xc(%ebp)
  802058:	e8 09 e8 ff ff       	call   800866 <strcpy>
	return 0;
}
  80205d:	b8 00 00 00 00       	mov    $0x0,%eax
  802062:	c9                   	leave  
  802063:	c3                   	ret    

00802064 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802064:	55                   	push   %ebp
  802065:	89 e5                	mov    %esp,%ebp
  802067:	57                   	push   %edi
  802068:	56                   	push   %esi
  802069:	53                   	push   %ebx
  80206a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802070:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802075:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80207b:	eb 2d                	jmp    8020aa <devcons_write+0x46>
		m = n - tot;
  80207d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802080:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802082:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802085:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80208a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80208d:	83 ec 04             	sub    $0x4,%esp
  802090:	53                   	push   %ebx
  802091:	03 45 0c             	add    0xc(%ebp),%eax
  802094:	50                   	push   %eax
  802095:	57                   	push   %edi
  802096:	e8 5d e9 ff ff       	call   8009f8 <memmove>
		sys_cputs(buf, m);
  80209b:	83 c4 08             	add    $0x8,%esp
  80209e:	53                   	push   %ebx
  80209f:	57                   	push   %edi
  8020a0:	e8 08 eb ff ff       	call   800bad <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020a5:	01 de                	add    %ebx,%esi
  8020a7:	83 c4 10             	add    $0x10,%esp
  8020aa:	89 f0                	mov    %esi,%eax
  8020ac:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020af:	72 cc                	jb     80207d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8020b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020b4:	5b                   	pop    %ebx
  8020b5:	5e                   	pop    %esi
  8020b6:	5f                   	pop    %edi
  8020b7:	5d                   	pop    %ebp
  8020b8:	c3                   	ret    

008020b9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020b9:	55                   	push   %ebp
  8020ba:	89 e5                	mov    %esp,%ebp
  8020bc:	83 ec 08             	sub    $0x8,%esp
  8020bf:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8020c4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020c8:	74 2a                	je     8020f4 <devcons_read+0x3b>
  8020ca:	eb 05                	jmp    8020d1 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8020cc:	e8 79 eb ff ff       	call   800c4a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8020d1:	e8 f5 ea ff ff       	call   800bcb <sys_cgetc>
  8020d6:	85 c0                	test   %eax,%eax
  8020d8:	74 f2                	je     8020cc <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8020da:	85 c0                	test   %eax,%eax
  8020dc:	78 16                	js     8020f4 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8020de:	83 f8 04             	cmp    $0x4,%eax
  8020e1:	74 0c                	je     8020ef <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8020e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020e6:	88 02                	mov    %al,(%edx)
	return 1;
  8020e8:	b8 01 00 00 00       	mov    $0x1,%eax
  8020ed:	eb 05                	jmp    8020f4 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020ef:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020f4:	c9                   	leave  
  8020f5:	c3                   	ret    

008020f6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020f6:	55                   	push   %ebp
  8020f7:	89 e5                	mov    %esp,%ebp
  8020f9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8020fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ff:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802102:	6a 01                	push   $0x1
  802104:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802107:	50                   	push   %eax
  802108:	e8 a0 ea ff ff       	call   800bad <sys_cputs>
}
  80210d:	83 c4 10             	add    $0x10,%esp
  802110:	c9                   	leave  
  802111:	c3                   	ret    

00802112 <getchar>:

int
getchar(void)
{
  802112:	55                   	push   %ebp
  802113:	89 e5                	mov    %esp,%ebp
  802115:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802118:	6a 01                	push   $0x1
  80211a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80211d:	50                   	push   %eax
  80211e:	6a 00                	push   $0x0
  802120:	e8 6e f5 ff ff       	call   801693 <read>
	if (r < 0)
  802125:	83 c4 10             	add    $0x10,%esp
  802128:	85 c0                	test   %eax,%eax
  80212a:	78 0f                	js     80213b <getchar+0x29>
		return r;
	if (r < 1)
  80212c:	85 c0                	test   %eax,%eax
  80212e:	7e 06                	jle    802136 <getchar+0x24>
		return -E_EOF;
	return c;
  802130:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802134:	eb 05                	jmp    80213b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802136:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80213b:	c9                   	leave  
  80213c:	c3                   	ret    

0080213d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80213d:	55                   	push   %ebp
  80213e:	89 e5                	mov    %esp,%ebp
  802140:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802143:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802146:	50                   	push   %eax
  802147:	ff 75 08             	pushl  0x8(%ebp)
  80214a:	e8 db f2 ff ff       	call   80142a <fd_lookup>
  80214f:	83 c4 10             	add    $0x10,%esp
  802152:	85 c0                	test   %eax,%eax
  802154:	78 11                	js     802167 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802156:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802159:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80215f:	39 10                	cmp    %edx,(%eax)
  802161:	0f 94 c0             	sete   %al
  802164:	0f b6 c0             	movzbl %al,%eax
}
  802167:	c9                   	leave  
  802168:	c3                   	ret    

00802169 <opencons>:

int
opencons(void)
{
  802169:	55                   	push   %ebp
  80216a:	89 e5                	mov    %esp,%ebp
  80216c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80216f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802172:	50                   	push   %eax
  802173:	e8 63 f2 ff ff       	call   8013db <fd_alloc>
  802178:	83 c4 10             	add    $0x10,%esp
		return r;
  80217b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80217d:	85 c0                	test   %eax,%eax
  80217f:	78 3e                	js     8021bf <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802181:	83 ec 04             	sub    $0x4,%esp
  802184:	68 07 04 00 00       	push   $0x407
  802189:	ff 75 f4             	pushl  -0xc(%ebp)
  80218c:	6a 00                	push   $0x0
  80218e:	e8 d6 ea ff ff       	call   800c69 <sys_page_alloc>
  802193:	83 c4 10             	add    $0x10,%esp
		return r;
  802196:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802198:	85 c0                	test   %eax,%eax
  80219a:	78 23                	js     8021bf <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80219c:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8021a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021a5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021aa:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021b1:	83 ec 0c             	sub    $0xc,%esp
  8021b4:	50                   	push   %eax
  8021b5:	e8 fa f1 ff ff       	call   8013b4 <fd2num>
  8021ba:	89 c2                	mov    %eax,%edx
  8021bc:	83 c4 10             	add    $0x10,%esp
}
  8021bf:	89 d0                	mov    %edx,%eax
  8021c1:	c9                   	leave  
  8021c2:	c3                   	ret    

008021c3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8021c3:	55                   	push   %ebp
  8021c4:	89 e5                	mov    %esp,%ebp
  8021c6:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8021c9:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8021d0:	75 2a                	jne    8021fc <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  8021d2:	83 ec 04             	sub    $0x4,%esp
  8021d5:	6a 07                	push   $0x7
  8021d7:	68 00 f0 bf ee       	push   $0xeebff000
  8021dc:	6a 00                	push   $0x0
  8021de:	e8 86 ea ff ff       	call   800c69 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8021e3:	83 c4 10             	add    $0x10,%esp
  8021e6:	85 c0                	test   %eax,%eax
  8021e8:	79 12                	jns    8021fc <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8021ea:	50                   	push   %eax
  8021eb:	68 72 2a 80 00       	push   $0x802a72
  8021f0:	6a 23                	push   $0x23
  8021f2:	68 66 2b 80 00       	push   $0x802b66
  8021f7:	e8 0c e0 ff ff       	call   800208 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8021fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ff:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802204:	83 ec 08             	sub    $0x8,%esp
  802207:	68 2e 22 80 00       	push   $0x80222e
  80220c:	6a 00                	push   $0x0
  80220e:	e8 a1 eb ff ff       	call   800db4 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802213:	83 c4 10             	add    $0x10,%esp
  802216:	85 c0                	test   %eax,%eax
  802218:	79 12                	jns    80222c <set_pgfault_handler+0x69>
		panic("%e\n", r);
  80221a:	50                   	push   %eax
  80221b:	68 72 2a 80 00       	push   $0x802a72
  802220:	6a 2c                	push   $0x2c
  802222:	68 66 2b 80 00       	push   $0x802b66
  802227:	e8 dc df ff ff       	call   800208 <_panic>
	}
}
  80222c:	c9                   	leave  
  80222d:	c3                   	ret    

0080222e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80222e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80222f:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802234:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802236:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802239:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  80223d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802242:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802246:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802248:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  80224b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  80224c:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80224f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802250:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802251:	c3                   	ret    

00802252 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802252:	55                   	push   %ebp
  802253:	89 e5                	mov    %esp,%ebp
  802255:	56                   	push   %esi
  802256:	53                   	push   %ebx
  802257:	8b 75 08             	mov    0x8(%ebp),%esi
  80225a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80225d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802260:	85 c0                	test   %eax,%eax
  802262:	75 12                	jne    802276 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802264:	83 ec 0c             	sub    $0xc,%esp
  802267:	68 00 00 c0 ee       	push   $0xeec00000
  80226c:	e8 a8 eb ff ff       	call   800e19 <sys_ipc_recv>
  802271:	83 c4 10             	add    $0x10,%esp
  802274:	eb 0c                	jmp    802282 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802276:	83 ec 0c             	sub    $0xc,%esp
  802279:	50                   	push   %eax
  80227a:	e8 9a eb ff ff       	call   800e19 <sys_ipc_recv>
  80227f:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802282:	85 f6                	test   %esi,%esi
  802284:	0f 95 c1             	setne  %cl
  802287:	85 db                	test   %ebx,%ebx
  802289:	0f 95 c2             	setne  %dl
  80228c:	84 d1                	test   %dl,%cl
  80228e:	74 09                	je     802299 <ipc_recv+0x47>
  802290:	89 c2                	mov    %eax,%edx
  802292:	c1 ea 1f             	shr    $0x1f,%edx
  802295:	84 d2                	test   %dl,%dl
  802297:	75 2d                	jne    8022c6 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802299:	85 f6                	test   %esi,%esi
  80229b:	74 0d                	je     8022aa <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80229d:	a1 08 40 80 00       	mov    0x804008,%eax
  8022a2:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  8022a8:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8022aa:	85 db                	test   %ebx,%ebx
  8022ac:	74 0d                	je     8022bb <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8022ae:	a1 08 40 80 00       	mov    0x804008,%eax
  8022b3:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8022b9:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8022bb:	a1 08 40 80 00       	mov    0x804008,%eax
  8022c0:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  8022c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022c9:	5b                   	pop    %ebx
  8022ca:	5e                   	pop    %esi
  8022cb:	5d                   	pop    %ebp
  8022cc:	c3                   	ret    

008022cd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022cd:	55                   	push   %ebp
  8022ce:	89 e5                	mov    %esp,%ebp
  8022d0:	57                   	push   %edi
  8022d1:	56                   	push   %esi
  8022d2:	53                   	push   %ebx
  8022d3:	83 ec 0c             	sub    $0xc,%esp
  8022d6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022d9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8022df:	85 db                	test   %ebx,%ebx
  8022e1:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8022e6:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8022e9:	ff 75 14             	pushl  0x14(%ebp)
  8022ec:	53                   	push   %ebx
  8022ed:	56                   	push   %esi
  8022ee:	57                   	push   %edi
  8022ef:	e8 02 eb ff ff       	call   800df6 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8022f4:	89 c2                	mov    %eax,%edx
  8022f6:	c1 ea 1f             	shr    $0x1f,%edx
  8022f9:	83 c4 10             	add    $0x10,%esp
  8022fc:	84 d2                	test   %dl,%dl
  8022fe:	74 17                	je     802317 <ipc_send+0x4a>
  802300:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802303:	74 12                	je     802317 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802305:	50                   	push   %eax
  802306:	68 74 2b 80 00       	push   $0x802b74
  80230b:	6a 47                	push   $0x47
  80230d:	68 82 2b 80 00       	push   $0x802b82
  802312:	e8 f1 de ff ff       	call   800208 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802317:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80231a:	75 07                	jne    802323 <ipc_send+0x56>
			sys_yield();
  80231c:	e8 29 e9 ff ff       	call   800c4a <sys_yield>
  802321:	eb c6                	jmp    8022e9 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802323:	85 c0                	test   %eax,%eax
  802325:	75 c2                	jne    8022e9 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802327:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80232a:	5b                   	pop    %ebx
  80232b:	5e                   	pop    %esi
  80232c:	5f                   	pop    %edi
  80232d:	5d                   	pop    %ebp
  80232e:	c3                   	ret    

0080232f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80232f:	55                   	push   %ebp
  802330:	89 e5                	mov    %esp,%ebp
  802332:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802335:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80233a:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  802340:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802346:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  80234c:	39 ca                	cmp    %ecx,%edx
  80234e:	75 13                	jne    802363 <ipc_find_env+0x34>
			return envs[i].env_id;
  802350:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  802356:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80235b:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  802361:	eb 0f                	jmp    802372 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802363:	83 c0 01             	add    $0x1,%eax
  802366:	3d 00 04 00 00       	cmp    $0x400,%eax
  80236b:	75 cd                	jne    80233a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80236d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802372:	5d                   	pop    %ebp
  802373:	c3                   	ret    

00802374 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802374:	55                   	push   %ebp
  802375:	89 e5                	mov    %esp,%ebp
  802377:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80237a:	89 d0                	mov    %edx,%eax
  80237c:	c1 e8 16             	shr    $0x16,%eax
  80237f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802386:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80238b:	f6 c1 01             	test   $0x1,%cl
  80238e:	74 1d                	je     8023ad <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802390:	c1 ea 0c             	shr    $0xc,%edx
  802393:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80239a:	f6 c2 01             	test   $0x1,%dl
  80239d:	74 0e                	je     8023ad <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80239f:	c1 ea 0c             	shr    $0xc,%edx
  8023a2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8023a9:	ef 
  8023aa:	0f b7 c0             	movzwl %ax,%eax
}
  8023ad:	5d                   	pop    %ebp
  8023ae:	c3                   	ret    
  8023af:	90                   	nop

008023b0 <__udivdi3>:
  8023b0:	55                   	push   %ebp
  8023b1:	57                   	push   %edi
  8023b2:	56                   	push   %esi
  8023b3:	53                   	push   %ebx
  8023b4:	83 ec 1c             	sub    $0x1c,%esp
  8023b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8023bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8023bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8023c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023c7:	85 f6                	test   %esi,%esi
  8023c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023cd:	89 ca                	mov    %ecx,%edx
  8023cf:	89 f8                	mov    %edi,%eax
  8023d1:	75 3d                	jne    802410 <__udivdi3+0x60>
  8023d3:	39 cf                	cmp    %ecx,%edi
  8023d5:	0f 87 c5 00 00 00    	ja     8024a0 <__udivdi3+0xf0>
  8023db:	85 ff                	test   %edi,%edi
  8023dd:	89 fd                	mov    %edi,%ebp
  8023df:	75 0b                	jne    8023ec <__udivdi3+0x3c>
  8023e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8023e6:	31 d2                	xor    %edx,%edx
  8023e8:	f7 f7                	div    %edi
  8023ea:	89 c5                	mov    %eax,%ebp
  8023ec:	89 c8                	mov    %ecx,%eax
  8023ee:	31 d2                	xor    %edx,%edx
  8023f0:	f7 f5                	div    %ebp
  8023f2:	89 c1                	mov    %eax,%ecx
  8023f4:	89 d8                	mov    %ebx,%eax
  8023f6:	89 cf                	mov    %ecx,%edi
  8023f8:	f7 f5                	div    %ebp
  8023fa:	89 c3                	mov    %eax,%ebx
  8023fc:	89 d8                	mov    %ebx,%eax
  8023fe:	89 fa                	mov    %edi,%edx
  802400:	83 c4 1c             	add    $0x1c,%esp
  802403:	5b                   	pop    %ebx
  802404:	5e                   	pop    %esi
  802405:	5f                   	pop    %edi
  802406:	5d                   	pop    %ebp
  802407:	c3                   	ret    
  802408:	90                   	nop
  802409:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802410:	39 ce                	cmp    %ecx,%esi
  802412:	77 74                	ja     802488 <__udivdi3+0xd8>
  802414:	0f bd fe             	bsr    %esi,%edi
  802417:	83 f7 1f             	xor    $0x1f,%edi
  80241a:	0f 84 98 00 00 00    	je     8024b8 <__udivdi3+0x108>
  802420:	bb 20 00 00 00       	mov    $0x20,%ebx
  802425:	89 f9                	mov    %edi,%ecx
  802427:	89 c5                	mov    %eax,%ebp
  802429:	29 fb                	sub    %edi,%ebx
  80242b:	d3 e6                	shl    %cl,%esi
  80242d:	89 d9                	mov    %ebx,%ecx
  80242f:	d3 ed                	shr    %cl,%ebp
  802431:	89 f9                	mov    %edi,%ecx
  802433:	d3 e0                	shl    %cl,%eax
  802435:	09 ee                	or     %ebp,%esi
  802437:	89 d9                	mov    %ebx,%ecx
  802439:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80243d:	89 d5                	mov    %edx,%ebp
  80243f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802443:	d3 ed                	shr    %cl,%ebp
  802445:	89 f9                	mov    %edi,%ecx
  802447:	d3 e2                	shl    %cl,%edx
  802449:	89 d9                	mov    %ebx,%ecx
  80244b:	d3 e8                	shr    %cl,%eax
  80244d:	09 c2                	or     %eax,%edx
  80244f:	89 d0                	mov    %edx,%eax
  802451:	89 ea                	mov    %ebp,%edx
  802453:	f7 f6                	div    %esi
  802455:	89 d5                	mov    %edx,%ebp
  802457:	89 c3                	mov    %eax,%ebx
  802459:	f7 64 24 0c          	mull   0xc(%esp)
  80245d:	39 d5                	cmp    %edx,%ebp
  80245f:	72 10                	jb     802471 <__udivdi3+0xc1>
  802461:	8b 74 24 08          	mov    0x8(%esp),%esi
  802465:	89 f9                	mov    %edi,%ecx
  802467:	d3 e6                	shl    %cl,%esi
  802469:	39 c6                	cmp    %eax,%esi
  80246b:	73 07                	jae    802474 <__udivdi3+0xc4>
  80246d:	39 d5                	cmp    %edx,%ebp
  80246f:	75 03                	jne    802474 <__udivdi3+0xc4>
  802471:	83 eb 01             	sub    $0x1,%ebx
  802474:	31 ff                	xor    %edi,%edi
  802476:	89 d8                	mov    %ebx,%eax
  802478:	89 fa                	mov    %edi,%edx
  80247a:	83 c4 1c             	add    $0x1c,%esp
  80247d:	5b                   	pop    %ebx
  80247e:	5e                   	pop    %esi
  80247f:	5f                   	pop    %edi
  802480:	5d                   	pop    %ebp
  802481:	c3                   	ret    
  802482:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802488:	31 ff                	xor    %edi,%edi
  80248a:	31 db                	xor    %ebx,%ebx
  80248c:	89 d8                	mov    %ebx,%eax
  80248e:	89 fa                	mov    %edi,%edx
  802490:	83 c4 1c             	add    $0x1c,%esp
  802493:	5b                   	pop    %ebx
  802494:	5e                   	pop    %esi
  802495:	5f                   	pop    %edi
  802496:	5d                   	pop    %ebp
  802497:	c3                   	ret    
  802498:	90                   	nop
  802499:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024a0:	89 d8                	mov    %ebx,%eax
  8024a2:	f7 f7                	div    %edi
  8024a4:	31 ff                	xor    %edi,%edi
  8024a6:	89 c3                	mov    %eax,%ebx
  8024a8:	89 d8                	mov    %ebx,%eax
  8024aa:	89 fa                	mov    %edi,%edx
  8024ac:	83 c4 1c             	add    $0x1c,%esp
  8024af:	5b                   	pop    %ebx
  8024b0:	5e                   	pop    %esi
  8024b1:	5f                   	pop    %edi
  8024b2:	5d                   	pop    %ebp
  8024b3:	c3                   	ret    
  8024b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024b8:	39 ce                	cmp    %ecx,%esi
  8024ba:	72 0c                	jb     8024c8 <__udivdi3+0x118>
  8024bc:	31 db                	xor    %ebx,%ebx
  8024be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8024c2:	0f 87 34 ff ff ff    	ja     8023fc <__udivdi3+0x4c>
  8024c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8024cd:	e9 2a ff ff ff       	jmp    8023fc <__udivdi3+0x4c>
  8024d2:	66 90                	xchg   %ax,%ax
  8024d4:	66 90                	xchg   %ax,%ax
  8024d6:	66 90                	xchg   %ax,%ax
  8024d8:	66 90                	xchg   %ax,%ax
  8024da:	66 90                	xchg   %ax,%ax
  8024dc:	66 90                	xchg   %ax,%ax
  8024de:	66 90                	xchg   %ax,%ax

008024e0 <__umoddi3>:
  8024e0:	55                   	push   %ebp
  8024e1:	57                   	push   %edi
  8024e2:	56                   	push   %esi
  8024e3:	53                   	push   %ebx
  8024e4:	83 ec 1c             	sub    $0x1c,%esp
  8024e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8024eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8024ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024f7:	85 d2                	test   %edx,%edx
  8024f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8024fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802501:	89 f3                	mov    %esi,%ebx
  802503:	89 3c 24             	mov    %edi,(%esp)
  802506:	89 74 24 04          	mov    %esi,0x4(%esp)
  80250a:	75 1c                	jne    802528 <__umoddi3+0x48>
  80250c:	39 f7                	cmp    %esi,%edi
  80250e:	76 50                	jbe    802560 <__umoddi3+0x80>
  802510:	89 c8                	mov    %ecx,%eax
  802512:	89 f2                	mov    %esi,%edx
  802514:	f7 f7                	div    %edi
  802516:	89 d0                	mov    %edx,%eax
  802518:	31 d2                	xor    %edx,%edx
  80251a:	83 c4 1c             	add    $0x1c,%esp
  80251d:	5b                   	pop    %ebx
  80251e:	5e                   	pop    %esi
  80251f:	5f                   	pop    %edi
  802520:	5d                   	pop    %ebp
  802521:	c3                   	ret    
  802522:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802528:	39 f2                	cmp    %esi,%edx
  80252a:	89 d0                	mov    %edx,%eax
  80252c:	77 52                	ja     802580 <__umoddi3+0xa0>
  80252e:	0f bd ea             	bsr    %edx,%ebp
  802531:	83 f5 1f             	xor    $0x1f,%ebp
  802534:	75 5a                	jne    802590 <__umoddi3+0xb0>
  802536:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80253a:	0f 82 e0 00 00 00    	jb     802620 <__umoddi3+0x140>
  802540:	39 0c 24             	cmp    %ecx,(%esp)
  802543:	0f 86 d7 00 00 00    	jbe    802620 <__umoddi3+0x140>
  802549:	8b 44 24 08          	mov    0x8(%esp),%eax
  80254d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802551:	83 c4 1c             	add    $0x1c,%esp
  802554:	5b                   	pop    %ebx
  802555:	5e                   	pop    %esi
  802556:	5f                   	pop    %edi
  802557:	5d                   	pop    %ebp
  802558:	c3                   	ret    
  802559:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802560:	85 ff                	test   %edi,%edi
  802562:	89 fd                	mov    %edi,%ebp
  802564:	75 0b                	jne    802571 <__umoddi3+0x91>
  802566:	b8 01 00 00 00       	mov    $0x1,%eax
  80256b:	31 d2                	xor    %edx,%edx
  80256d:	f7 f7                	div    %edi
  80256f:	89 c5                	mov    %eax,%ebp
  802571:	89 f0                	mov    %esi,%eax
  802573:	31 d2                	xor    %edx,%edx
  802575:	f7 f5                	div    %ebp
  802577:	89 c8                	mov    %ecx,%eax
  802579:	f7 f5                	div    %ebp
  80257b:	89 d0                	mov    %edx,%eax
  80257d:	eb 99                	jmp    802518 <__umoddi3+0x38>
  80257f:	90                   	nop
  802580:	89 c8                	mov    %ecx,%eax
  802582:	89 f2                	mov    %esi,%edx
  802584:	83 c4 1c             	add    $0x1c,%esp
  802587:	5b                   	pop    %ebx
  802588:	5e                   	pop    %esi
  802589:	5f                   	pop    %edi
  80258a:	5d                   	pop    %ebp
  80258b:	c3                   	ret    
  80258c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802590:	8b 34 24             	mov    (%esp),%esi
  802593:	bf 20 00 00 00       	mov    $0x20,%edi
  802598:	89 e9                	mov    %ebp,%ecx
  80259a:	29 ef                	sub    %ebp,%edi
  80259c:	d3 e0                	shl    %cl,%eax
  80259e:	89 f9                	mov    %edi,%ecx
  8025a0:	89 f2                	mov    %esi,%edx
  8025a2:	d3 ea                	shr    %cl,%edx
  8025a4:	89 e9                	mov    %ebp,%ecx
  8025a6:	09 c2                	or     %eax,%edx
  8025a8:	89 d8                	mov    %ebx,%eax
  8025aa:	89 14 24             	mov    %edx,(%esp)
  8025ad:	89 f2                	mov    %esi,%edx
  8025af:	d3 e2                	shl    %cl,%edx
  8025b1:	89 f9                	mov    %edi,%ecx
  8025b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8025bb:	d3 e8                	shr    %cl,%eax
  8025bd:	89 e9                	mov    %ebp,%ecx
  8025bf:	89 c6                	mov    %eax,%esi
  8025c1:	d3 e3                	shl    %cl,%ebx
  8025c3:	89 f9                	mov    %edi,%ecx
  8025c5:	89 d0                	mov    %edx,%eax
  8025c7:	d3 e8                	shr    %cl,%eax
  8025c9:	89 e9                	mov    %ebp,%ecx
  8025cb:	09 d8                	or     %ebx,%eax
  8025cd:	89 d3                	mov    %edx,%ebx
  8025cf:	89 f2                	mov    %esi,%edx
  8025d1:	f7 34 24             	divl   (%esp)
  8025d4:	89 d6                	mov    %edx,%esi
  8025d6:	d3 e3                	shl    %cl,%ebx
  8025d8:	f7 64 24 04          	mull   0x4(%esp)
  8025dc:	39 d6                	cmp    %edx,%esi
  8025de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025e2:	89 d1                	mov    %edx,%ecx
  8025e4:	89 c3                	mov    %eax,%ebx
  8025e6:	72 08                	jb     8025f0 <__umoddi3+0x110>
  8025e8:	75 11                	jne    8025fb <__umoddi3+0x11b>
  8025ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8025ee:	73 0b                	jae    8025fb <__umoddi3+0x11b>
  8025f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8025f4:	1b 14 24             	sbb    (%esp),%edx
  8025f7:	89 d1                	mov    %edx,%ecx
  8025f9:	89 c3                	mov    %eax,%ebx
  8025fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8025ff:	29 da                	sub    %ebx,%edx
  802601:	19 ce                	sbb    %ecx,%esi
  802603:	89 f9                	mov    %edi,%ecx
  802605:	89 f0                	mov    %esi,%eax
  802607:	d3 e0                	shl    %cl,%eax
  802609:	89 e9                	mov    %ebp,%ecx
  80260b:	d3 ea                	shr    %cl,%edx
  80260d:	89 e9                	mov    %ebp,%ecx
  80260f:	d3 ee                	shr    %cl,%esi
  802611:	09 d0                	or     %edx,%eax
  802613:	89 f2                	mov    %esi,%edx
  802615:	83 c4 1c             	add    $0x1c,%esp
  802618:	5b                   	pop    %ebx
  802619:	5e                   	pop    %esi
  80261a:	5f                   	pop    %edi
  80261b:	5d                   	pop    %ebp
  80261c:	c3                   	ret    
  80261d:	8d 76 00             	lea    0x0(%esi),%esi
  802620:	29 f9                	sub    %edi,%ecx
  802622:	19 d6                	sbb    %edx,%esi
  802624:	89 74 24 04          	mov    %esi,0x4(%esp)
  802628:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80262c:	e9 18 ff ff ff       	jmp    802549 <__umoddi3+0x69>
