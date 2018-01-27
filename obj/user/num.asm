
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
  80005d:	68 20 24 80 00       	push   $0x802420
  800062:	e8 2c 1a 00 00       	call   801a93 <printf>
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
  80007c:	e8 c3 14 00 00       	call   801544 <write>
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	83 f8 01             	cmp    $0x1,%eax
  800087:	74 18                	je     8000a1 <num+0x6e>
			panic("write error copying %s: %e", s, r);
  800089:	83 ec 0c             	sub    $0xc,%esp
  80008c:	50                   	push   %eax
  80008d:	ff 75 0c             	pushl  0xc(%ebp)
  800090:	68 25 24 80 00       	push   $0x802425
  800095:	6a 13                	push   $0x13
  800097:	68 40 24 80 00       	push   $0x802440
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
  8000b8:	e8 ad 13 00 00       	call   80146a <read>
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
  8000d3:	68 4b 24 80 00       	push   $0x80244b
  8000d8:	6a 18                	push   $0x18
  8000da:	68 40 24 80 00       	push   $0x802440
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
  8000f4:	c7 05 04 30 80 00 60 	movl   $0x802460,0x803004
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
  800114:	68 64 24 80 00       	push   $0x802464
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
  80012f:	e8 c1 17 00 00       	call   8018f5 <open>
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
  800146:	68 6c 24 80 00       	push   $0x80246c
  80014b:	6a 27                	push   $0x27
  80014d:	68 40 24 80 00       	push   $0x802440
  800152:	e8 b1 00 00 00       	call   800208 <_panic>
			else {
				num(f, argv[i]);
  800157:	83 ec 08             	sub    $0x8,%esp
  80015a:	ff 33                	pushl  (%ebx)
  80015c:	50                   	push   %eax
  80015d:	e8 d1 fe ff ff       	call   800033 <num>
				close(f);
  800162:	89 34 24             	mov    %esi,(%esp)
  800165:	e8 c4 11 00 00       	call   80132e <close>

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
  80019a:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  8001a0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001a5:	a3 08 40 80 00       	mov    %eax,0x804008
			thisenv = &envs[i];
		}
	}*/

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

void 
thread_main(/*uintptr_t eip*/)
{
  8001ce:	55                   	push   %ebp
  8001cf:	89 e5                	mov    %esp,%ebp
  8001d1:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

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
  8001f4:	e8 60 11 00 00       	call   801359 <close_all>
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
  800226:	68 88 24 80 00       	push   $0x802488
  80022b:	e8 b1 00 00 00       	call   8002e1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800230:	83 c4 18             	add    $0x18,%esp
  800233:	53                   	push   %ebx
  800234:	ff 75 10             	pushl  0x10(%ebp)
  800237:	e8 54 00 00 00       	call   800290 <vcprintf>
	cprintf("\n");
  80023c:	c7 04 24 23 29 80 00 	movl   $0x802923,(%esp)
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
  800344:	e8 37 1e 00 00       	call   802180 <__udivdi3>
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
  800387:	e8 24 1f 00 00       	call   8022b0 <__umoddi3>
  80038c:	83 c4 14             	add    $0x14,%esp
  80038f:	0f be 80 ab 24 80 00 	movsbl 0x8024ab(%eax),%eax
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
  80048b:	ff 24 85 e0 25 80 00 	jmp    *0x8025e0(,%eax,4)
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
  80054f:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  800556:	85 d2                	test   %edx,%edx
  800558:	75 18                	jne    800572 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80055a:	50                   	push   %eax
  80055b:	68 c3 24 80 00       	push   $0x8024c3
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
  800573:	68 f1 28 80 00       	push   $0x8028f1
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
  800597:	b8 bc 24 80 00       	mov    $0x8024bc,%eax
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
  800c12:	68 9f 27 80 00       	push   $0x80279f
  800c17:	6a 23                	push   $0x23
  800c19:	68 bc 27 80 00       	push   $0x8027bc
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
  800c93:	68 9f 27 80 00       	push   $0x80279f
  800c98:	6a 23                	push   $0x23
  800c9a:	68 bc 27 80 00       	push   $0x8027bc
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
  800cd5:	68 9f 27 80 00       	push   $0x80279f
  800cda:	6a 23                	push   $0x23
  800cdc:	68 bc 27 80 00       	push   $0x8027bc
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
  800d17:	68 9f 27 80 00       	push   $0x80279f
  800d1c:	6a 23                	push   $0x23
  800d1e:	68 bc 27 80 00       	push   $0x8027bc
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
  800d59:	68 9f 27 80 00       	push   $0x80279f
  800d5e:	6a 23                	push   $0x23
  800d60:	68 bc 27 80 00       	push   $0x8027bc
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
  800d9b:	68 9f 27 80 00       	push   $0x80279f
  800da0:	6a 23                	push   $0x23
  800da2:	68 bc 27 80 00       	push   $0x8027bc
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
  800ddd:	68 9f 27 80 00       	push   $0x80279f
  800de2:	6a 23                	push   $0x23
  800de4:	68 bc 27 80 00       	push   $0x8027bc
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
  800e41:	68 9f 27 80 00       	push   $0x80279f
  800e46:	6a 23                	push   $0x23
  800e48:	68 bc 27 80 00       	push   $0x8027bc
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

00800e9a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	53                   	push   %ebx
  800e9e:	83 ec 04             	sub    $0x4,%esp
  800ea1:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ea4:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800ea6:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800eaa:	74 11                	je     800ebd <pgfault+0x23>
  800eac:	89 d8                	mov    %ebx,%eax
  800eae:	c1 e8 0c             	shr    $0xc,%eax
  800eb1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eb8:	f6 c4 08             	test   $0x8,%ah
  800ebb:	75 14                	jne    800ed1 <pgfault+0x37>
		panic("faulting access");
  800ebd:	83 ec 04             	sub    $0x4,%esp
  800ec0:	68 ca 27 80 00       	push   $0x8027ca
  800ec5:	6a 1e                	push   $0x1e
  800ec7:	68 da 27 80 00       	push   $0x8027da
  800ecc:	e8 37 f3 ff ff       	call   800208 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800ed1:	83 ec 04             	sub    $0x4,%esp
  800ed4:	6a 07                	push   $0x7
  800ed6:	68 00 f0 7f 00       	push   $0x7ff000
  800edb:	6a 00                	push   $0x0
  800edd:	e8 87 fd ff ff       	call   800c69 <sys_page_alloc>
	if (r < 0) {
  800ee2:	83 c4 10             	add    $0x10,%esp
  800ee5:	85 c0                	test   %eax,%eax
  800ee7:	79 12                	jns    800efb <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800ee9:	50                   	push   %eax
  800eea:	68 e5 27 80 00       	push   $0x8027e5
  800eef:	6a 2c                	push   $0x2c
  800ef1:	68 da 27 80 00       	push   $0x8027da
  800ef6:	e8 0d f3 ff ff       	call   800208 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800efb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800f01:	83 ec 04             	sub    $0x4,%esp
  800f04:	68 00 10 00 00       	push   $0x1000
  800f09:	53                   	push   %ebx
  800f0a:	68 00 f0 7f 00       	push   $0x7ff000
  800f0f:	e8 4c fb ff ff       	call   800a60 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800f14:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f1b:	53                   	push   %ebx
  800f1c:	6a 00                	push   $0x0
  800f1e:	68 00 f0 7f 00       	push   $0x7ff000
  800f23:	6a 00                	push   $0x0
  800f25:	e8 82 fd ff ff       	call   800cac <sys_page_map>
	if (r < 0) {
  800f2a:	83 c4 20             	add    $0x20,%esp
  800f2d:	85 c0                	test   %eax,%eax
  800f2f:	79 12                	jns    800f43 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800f31:	50                   	push   %eax
  800f32:	68 e5 27 80 00       	push   $0x8027e5
  800f37:	6a 33                	push   $0x33
  800f39:	68 da 27 80 00       	push   $0x8027da
  800f3e:	e8 c5 f2 ff ff       	call   800208 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800f43:	83 ec 08             	sub    $0x8,%esp
  800f46:	68 00 f0 7f 00       	push   $0x7ff000
  800f4b:	6a 00                	push   $0x0
  800f4d:	e8 9c fd ff ff       	call   800cee <sys_page_unmap>
	if (r < 0) {
  800f52:	83 c4 10             	add    $0x10,%esp
  800f55:	85 c0                	test   %eax,%eax
  800f57:	79 12                	jns    800f6b <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800f59:	50                   	push   %eax
  800f5a:	68 e5 27 80 00       	push   $0x8027e5
  800f5f:	6a 37                	push   $0x37
  800f61:	68 da 27 80 00       	push   $0x8027da
  800f66:	e8 9d f2 ff ff       	call   800208 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800f6b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f6e:	c9                   	leave  
  800f6f:	c3                   	ret    

00800f70 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	57                   	push   %edi
  800f74:	56                   	push   %esi
  800f75:	53                   	push   %ebx
  800f76:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800f79:	68 9a 0e 80 00       	push   $0x800e9a
  800f7e:	e8 0e 10 00 00       	call   801f91 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f83:	b8 07 00 00 00       	mov    $0x7,%eax
  800f88:	cd 30                	int    $0x30
  800f8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800f8d:	83 c4 10             	add    $0x10,%esp
  800f90:	85 c0                	test   %eax,%eax
  800f92:	79 17                	jns    800fab <fork+0x3b>
		panic("fork fault %e");
  800f94:	83 ec 04             	sub    $0x4,%esp
  800f97:	68 fe 27 80 00       	push   $0x8027fe
  800f9c:	68 84 00 00 00       	push   $0x84
  800fa1:	68 da 27 80 00       	push   $0x8027da
  800fa6:	e8 5d f2 ff ff       	call   800208 <_panic>
  800fab:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800fad:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fb1:	75 24                	jne    800fd7 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fb3:	e8 73 fc ff ff       	call   800c2b <sys_getenvid>
  800fb8:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fbd:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800fc3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fc8:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800fcd:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd2:	e9 64 01 00 00       	jmp    80113b <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800fd7:	83 ec 04             	sub    $0x4,%esp
  800fda:	6a 07                	push   $0x7
  800fdc:	68 00 f0 bf ee       	push   $0xeebff000
  800fe1:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fe4:	e8 80 fc ff ff       	call   800c69 <sys_page_alloc>
  800fe9:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fec:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ff1:	89 d8                	mov    %ebx,%eax
  800ff3:	c1 e8 16             	shr    $0x16,%eax
  800ff6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ffd:	a8 01                	test   $0x1,%al
  800fff:	0f 84 fc 00 00 00    	je     801101 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  801005:	89 d8                	mov    %ebx,%eax
  801007:	c1 e8 0c             	shr    $0xc,%eax
  80100a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801011:	f6 c2 01             	test   $0x1,%dl
  801014:	0f 84 e7 00 00 00    	je     801101 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80101a:	89 c6                	mov    %eax,%esi
  80101c:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  80101f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801026:	f6 c6 04             	test   $0x4,%dh
  801029:	74 39                	je     801064 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80102b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801032:	83 ec 0c             	sub    $0xc,%esp
  801035:	25 07 0e 00 00       	and    $0xe07,%eax
  80103a:	50                   	push   %eax
  80103b:	56                   	push   %esi
  80103c:	57                   	push   %edi
  80103d:	56                   	push   %esi
  80103e:	6a 00                	push   $0x0
  801040:	e8 67 fc ff ff       	call   800cac <sys_page_map>
		if (r < 0) {
  801045:	83 c4 20             	add    $0x20,%esp
  801048:	85 c0                	test   %eax,%eax
  80104a:	0f 89 b1 00 00 00    	jns    801101 <fork+0x191>
		    	panic("sys page map fault %e");
  801050:	83 ec 04             	sub    $0x4,%esp
  801053:	68 0c 28 80 00       	push   $0x80280c
  801058:	6a 54                	push   $0x54
  80105a:	68 da 27 80 00       	push   $0x8027da
  80105f:	e8 a4 f1 ff ff       	call   800208 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801064:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80106b:	f6 c2 02             	test   $0x2,%dl
  80106e:	75 0c                	jne    80107c <fork+0x10c>
  801070:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801077:	f6 c4 08             	test   $0x8,%ah
  80107a:	74 5b                	je     8010d7 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80107c:	83 ec 0c             	sub    $0xc,%esp
  80107f:	68 05 08 00 00       	push   $0x805
  801084:	56                   	push   %esi
  801085:	57                   	push   %edi
  801086:	56                   	push   %esi
  801087:	6a 00                	push   $0x0
  801089:	e8 1e fc ff ff       	call   800cac <sys_page_map>
		if (r < 0) {
  80108e:	83 c4 20             	add    $0x20,%esp
  801091:	85 c0                	test   %eax,%eax
  801093:	79 14                	jns    8010a9 <fork+0x139>
		    	panic("sys page map fault %e");
  801095:	83 ec 04             	sub    $0x4,%esp
  801098:	68 0c 28 80 00       	push   $0x80280c
  80109d:	6a 5b                	push   $0x5b
  80109f:	68 da 27 80 00       	push   $0x8027da
  8010a4:	e8 5f f1 ff ff       	call   800208 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8010a9:	83 ec 0c             	sub    $0xc,%esp
  8010ac:	68 05 08 00 00       	push   $0x805
  8010b1:	56                   	push   %esi
  8010b2:	6a 00                	push   $0x0
  8010b4:	56                   	push   %esi
  8010b5:	6a 00                	push   $0x0
  8010b7:	e8 f0 fb ff ff       	call   800cac <sys_page_map>
		if (r < 0) {
  8010bc:	83 c4 20             	add    $0x20,%esp
  8010bf:	85 c0                	test   %eax,%eax
  8010c1:	79 3e                	jns    801101 <fork+0x191>
		    	panic("sys page map fault %e");
  8010c3:	83 ec 04             	sub    $0x4,%esp
  8010c6:	68 0c 28 80 00       	push   $0x80280c
  8010cb:	6a 5f                	push   $0x5f
  8010cd:	68 da 27 80 00       	push   $0x8027da
  8010d2:	e8 31 f1 ff ff       	call   800208 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8010d7:	83 ec 0c             	sub    $0xc,%esp
  8010da:	6a 05                	push   $0x5
  8010dc:	56                   	push   %esi
  8010dd:	57                   	push   %edi
  8010de:	56                   	push   %esi
  8010df:	6a 00                	push   $0x0
  8010e1:	e8 c6 fb ff ff       	call   800cac <sys_page_map>
		if (r < 0) {
  8010e6:	83 c4 20             	add    $0x20,%esp
  8010e9:	85 c0                	test   %eax,%eax
  8010eb:	79 14                	jns    801101 <fork+0x191>
		    	panic("sys page map fault %e");
  8010ed:	83 ec 04             	sub    $0x4,%esp
  8010f0:	68 0c 28 80 00       	push   $0x80280c
  8010f5:	6a 64                	push   $0x64
  8010f7:	68 da 27 80 00       	push   $0x8027da
  8010fc:	e8 07 f1 ff ff       	call   800208 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801101:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801107:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80110d:	0f 85 de fe ff ff    	jne    800ff1 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801113:	a1 08 40 80 00       	mov    0x804008,%eax
  801118:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  80111e:	83 ec 08             	sub    $0x8,%esp
  801121:	50                   	push   %eax
  801122:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801125:	57                   	push   %edi
  801126:	e8 89 fc ff ff       	call   800db4 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80112b:	83 c4 08             	add    $0x8,%esp
  80112e:	6a 02                	push   $0x2
  801130:	57                   	push   %edi
  801131:	e8 fa fb ff ff       	call   800d30 <sys_env_set_status>
	
	return envid;
  801136:	83 c4 10             	add    $0x10,%esp
  801139:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80113b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113e:	5b                   	pop    %ebx
  80113f:	5e                   	pop    %esi
  801140:	5f                   	pop    %edi
  801141:	5d                   	pop    %ebp
  801142:	c3                   	ret    

00801143 <sfork>:

envid_t
sfork(void)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801146:	b8 00 00 00 00       	mov    $0x0,%eax
  80114b:	5d                   	pop    %ebp
  80114c:	c3                   	ret    

0080114d <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80114d:	55                   	push   %ebp
  80114e:	89 e5                	mov    %esp,%ebp
  801150:	56                   	push   %esi
  801151:	53                   	push   %ebx
  801152:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801155:	89 1d 0c 40 80 00    	mov    %ebx,0x80400c
	cprintf("in fork.c thread create. func: %x\n", func);
  80115b:	83 ec 08             	sub    $0x8,%esp
  80115e:	53                   	push   %ebx
  80115f:	68 24 28 80 00       	push   $0x802824
  801164:	e8 78 f1 ff ff       	call   8002e1 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801169:	c7 04 24 ce 01 80 00 	movl   $0x8001ce,(%esp)
  801170:	e8 e5 fc ff ff       	call   800e5a <sys_thread_create>
  801175:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801177:	83 c4 08             	add    $0x8,%esp
  80117a:	53                   	push   %ebx
  80117b:	68 24 28 80 00       	push   $0x802824
  801180:	e8 5c f1 ff ff       	call   8002e1 <cprintf>
	return id;
}
  801185:	89 f0                	mov    %esi,%eax
  801187:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80118a:	5b                   	pop    %ebx
  80118b:	5e                   	pop    %esi
  80118c:	5d                   	pop    %ebp
  80118d:	c3                   	ret    

0080118e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80118e:	55                   	push   %ebp
  80118f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801191:	8b 45 08             	mov    0x8(%ebp),%eax
  801194:	05 00 00 00 30       	add    $0x30000000,%eax
  801199:	c1 e8 0c             	shr    $0xc,%eax
}
  80119c:	5d                   	pop    %ebp
  80119d:	c3                   	ret    

0080119e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a4:	05 00 00 00 30       	add    $0x30000000,%eax
  8011a9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011ae:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011b3:	5d                   	pop    %ebp
  8011b4:	c3                   	ret    

008011b5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
  8011b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011bb:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011c0:	89 c2                	mov    %eax,%edx
  8011c2:	c1 ea 16             	shr    $0x16,%edx
  8011c5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011cc:	f6 c2 01             	test   $0x1,%dl
  8011cf:	74 11                	je     8011e2 <fd_alloc+0x2d>
  8011d1:	89 c2                	mov    %eax,%edx
  8011d3:	c1 ea 0c             	shr    $0xc,%edx
  8011d6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011dd:	f6 c2 01             	test   $0x1,%dl
  8011e0:	75 09                	jne    8011eb <fd_alloc+0x36>
			*fd_store = fd;
  8011e2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e9:	eb 17                	jmp    801202 <fd_alloc+0x4d>
  8011eb:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011f0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011f5:	75 c9                	jne    8011c0 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011f7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011fd:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801202:	5d                   	pop    %ebp
  801203:	c3                   	ret    

00801204 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801204:	55                   	push   %ebp
  801205:	89 e5                	mov    %esp,%ebp
  801207:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80120a:	83 f8 1f             	cmp    $0x1f,%eax
  80120d:	77 36                	ja     801245 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80120f:	c1 e0 0c             	shl    $0xc,%eax
  801212:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801217:	89 c2                	mov    %eax,%edx
  801219:	c1 ea 16             	shr    $0x16,%edx
  80121c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801223:	f6 c2 01             	test   $0x1,%dl
  801226:	74 24                	je     80124c <fd_lookup+0x48>
  801228:	89 c2                	mov    %eax,%edx
  80122a:	c1 ea 0c             	shr    $0xc,%edx
  80122d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801234:	f6 c2 01             	test   $0x1,%dl
  801237:	74 1a                	je     801253 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801239:	8b 55 0c             	mov    0xc(%ebp),%edx
  80123c:	89 02                	mov    %eax,(%edx)
	return 0;
  80123e:	b8 00 00 00 00       	mov    $0x0,%eax
  801243:	eb 13                	jmp    801258 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801245:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80124a:	eb 0c                	jmp    801258 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80124c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801251:	eb 05                	jmp    801258 <fd_lookup+0x54>
  801253:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801258:	5d                   	pop    %ebp
  801259:	c3                   	ret    

0080125a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80125a:	55                   	push   %ebp
  80125b:	89 e5                	mov    %esp,%ebp
  80125d:	83 ec 08             	sub    $0x8,%esp
  801260:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801263:	ba c8 28 80 00       	mov    $0x8028c8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801268:	eb 13                	jmp    80127d <dev_lookup+0x23>
  80126a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80126d:	39 08                	cmp    %ecx,(%eax)
  80126f:	75 0c                	jne    80127d <dev_lookup+0x23>
			*dev = devtab[i];
  801271:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801274:	89 01                	mov    %eax,(%ecx)
			return 0;
  801276:	b8 00 00 00 00       	mov    $0x0,%eax
  80127b:	eb 2e                	jmp    8012ab <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80127d:	8b 02                	mov    (%edx),%eax
  80127f:	85 c0                	test   %eax,%eax
  801281:	75 e7                	jne    80126a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801283:	a1 08 40 80 00       	mov    0x804008,%eax
  801288:	8b 40 7c             	mov    0x7c(%eax),%eax
  80128b:	83 ec 04             	sub    $0x4,%esp
  80128e:	51                   	push   %ecx
  80128f:	50                   	push   %eax
  801290:	68 48 28 80 00       	push   $0x802848
  801295:	e8 47 f0 ff ff       	call   8002e1 <cprintf>
	*dev = 0;
  80129a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80129d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012a3:	83 c4 10             	add    $0x10,%esp
  8012a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012ab:	c9                   	leave  
  8012ac:	c3                   	ret    

008012ad <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012ad:	55                   	push   %ebp
  8012ae:	89 e5                	mov    %esp,%ebp
  8012b0:	56                   	push   %esi
  8012b1:	53                   	push   %ebx
  8012b2:	83 ec 10             	sub    $0x10,%esp
  8012b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8012b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012be:	50                   	push   %eax
  8012bf:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012c5:	c1 e8 0c             	shr    $0xc,%eax
  8012c8:	50                   	push   %eax
  8012c9:	e8 36 ff ff ff       	call   801204 <fd_lookup>
  8012ce:	83 c4 08             	add    $0x8,%esp
  8012d1:	85 c0                	test   %eax,%eax
  8012d3:	78 05                	js     8012da <fd_close+0x2d>
	    || fd != fd2)
  8012d5:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012d8:	74 0c                	je     8012e6 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012da:	84 db                	test   %bl,%bl
  8012dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e1:	0f 44 c2             	cmove  %edx,%eax
  8012e4:	eb 41                	jmp    801327 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012e6:	83 ec 08             	sub    $0x8,%esp
  8012e9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ec:	50                   	push   %eax
  8012ed:	ff 36                	pushl  (%esi)
  8012ef:	e8 66 ff ff ff       	call   80125a <dev_lookup>
  8012f4:	89 c3                	mov    %eax,%ebx
  8012f6:	83 c4 10             	add    $0x10,%esp
  8012f9:	85 c0                	test   %eax,%eax
  8012fb:	78 1a                	js     801317 <fd_close+0x6a>
		if (dev->dev_close)
  8012fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801300:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801303:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801308:	85 c0                	test   %eax,%eax
  80130a:	74 0b                	je     801317 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80130c:	83 ec 0c             	sub    $0xc,%esp
  80130f:	56                   	push   %esi
  801310:	ff d0                	call   *%eax
  801312:	89 c3                	mov    %eax,%ebx
  801314:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801317:	83 ec 08             	sub    $0x8,%esp
  80131a:	56                   	push   %esi
  80131b:	6a 00                	push   $0x0
  80131d:	e8 cc f9 ff ff       	call   800cee <sys_page_unmap>
	return r;
  801322:	83 c4 10             	add    $0x10,%esp
  801325:	89 d8                	mov    %ebx,%eax
}
  801327:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80132a:	5b                   	pop    %ebx
  80132b:	5e                   	pop    %esi
  80132c:	5d                   	pop    %ebp
  80132d:	c3                   	ret    

0080132e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80132e:	55                   	push   %ebp
  80132f:	89 e5                	mov    %esp,%ebp
  801331:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801334:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801337:	50                   	push   %eax
  801338:	ff 75 08             	pushl  0x8(%ebp)
  80133b:	e8 c4 fe ff ff       	call   801204 <fd_lookup>
  801340:	83 c4 08             	add    $0x8,%esp
  801343:	85 c0                	test   %eax,%eax
  801345:	78 10                	js     801357 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801347:	83 ec 08             	sub    $0x8,%esp
  80134a:	6a 01                	push   $0x1
  80134c:	ff 75 f4             	pushl  -0xc(%ebp)
  80134f:	e8 59 ff ff ff       	call   8012ad <fd_close>
  801354:	83 c4 10             	add    $0x10,%esp
}
  801357:	c9                   	leave  
  801358:	c3                   	ret    

00801359 <close_all>:

void
close_all(void)
{
  801359:	55                   	push   %ebp
  80135a:	89 e5                	mov    %esp,%ebp
  80135c:	53                   	push   %ebx
  80135d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801360:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801365:	83 ec 0c             	sub    $0xc,%esp
  801368:	53                   	push   %ebx
  801369:	e8 c0 ff ff ff       	call   80132e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80136e:	83 c3 01             	add    $0x1,%ebx
  801371:	83 c4 10             	add    $0x10,%esp
  801374:	83 fb 20             	cmp    $0x20,%ebx
  801377:	75 ec                	jne    801365 <close_all+0xc>
		close(i);
}
  801379:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137c:	c9                   	leave  
  80137d:	c3                   	ret    

0080137e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80137e:	55                   	push   %ebp
  80137f:	89 e5                	mov    %esp,%ebp
  801381:	57                   	push   %edi
  801382:	56                   	push   %esi
  801383:	53                   	push   %ebx
  801384:	83 ec 2c             	sub    $0x2c,%esp
  801387:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80138a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80138d:	50                   	push   %eax
  80138e:	ff 75 08             	pushl  0x8(%ebp)
  801391:	e8 6e fe ff ff       	call   801204 <fd_lookup>
  801396:	83 c4 08             	add    $0x8,%esp
  801399:	85 c0                	test   %eax,%eax
  80139b:	0f 88 c1 00 00 00    	js     801462 <dup+0xe4>
		return r;
	close(newfdnum);
  8013a1:	83 ec 0c             	sub    $0xc,%esp
  8013a4:	56                   	push   %esi
  8013a5:	e8 84 ff ff ff       	call   80132e <close>

	newfd = INDEX2FD(newfdnum);
  8013aa:	89 f3                	mov    %esi,%ebx
  8013ac:	c1 e3 0c             	shl    $0xc,%ebx
  8013af:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013b5:	83 c4 04             	add    $0x4,%esp
  8013b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013bb:	e8 de fd ff ff       	call   80119e <fd2data>
  8013c0:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013c2:	89 1c 24             	mov    %ebx,(%esp)
  8013c5:	e8 d4 fd ff ff       	call   80119e <fd2data>
  8013ca:	83 c4 10             	add    $0x10,%esp
  8013cd:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013d0:	89 f8                	mov    %edi,%eax
  8013d2:	c1 e8 16             	shr    $0x16,%eax
  8013d5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013dc:	a8 01                	test   $0x1,%al
  8013de:	74 37                	je     801417 <dup+0x99>
  8013e0:	89 f8                	mov    %edi,%eax
  8013e2:	c1 e8 0c             	shr    $0xc,%eax
  8013e5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013ec:	f6 c2 01             	test   $0x1,%dl
  8013ef:	74 26                	je     801417 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013f1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013f8:	83 ec 0c             	sub    $0xc,%esp
  8013fb:	25 07 0e 00 00       	and    $0xe07,%eax
  801400:	50                   	push   %eax
  801401:	ff 75 d4             	pushl  -0x2c(%ebp)
  801404:	6a 00                	push   $0x0
  801406:	57                   	push   %edi
  801407:	6a 00                	push   $0x0
  801409:	e8 9e f8 ff ff       	call   800cac <sys_page_map>
  80140e:	89 c7                	mov    %eax,%edi
  801410:	83 c4 20             	add    $0x20,%esp
  801413:	85 c0                	test   %eax,%eax
  801415:	78 2e                	js     801445 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801417:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80141a:	89 d0                	mov    %edx,%eax
  80141c:	c1 e8 0c             	shr    $0xc,%eax
  80141f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801426:	83 ec 0c             	sub    $0xc,%esp
  801429:	25 07 0e 00 00       	and    $0xe07,%eax
  80142e:	50                   	push   %eax
  80142f:	53                   	push   %ebx
  801430:	6a 00                	push   $0x0
  801432:	52                   	push   %edx
  801433:	6a 00                	push   $0x0
  801435:	e8 72 f8 ff ff       	call   800cac <sys_page_map>
  80143a:	89 c7                	mov    %eax,%edi
  80143c:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80143f:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801441:	85 ff                	test   %edi,%edi
  801443:	79 1d                	jns    801462 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801445:	83 ec 08             	sub    $0x8,%esp
  801448:	53                   	push   %ebx
  801449:	6a 00                	push   $0x0
  80144b:	e8 9e f8 ff ff       	call   800cee <sys_page_unmap>
	sys_page_unmap(0, nva);
  801450:	83 c4 08             	add    $0x8,%esp
  801453:	ff 75 d4             	pushl  -0x2c(%ebp)
  801456:	6a 00                	push   $0x0
  801458:	e8 91 f8 ff ff       	call   800cee <sys_page_unmap>
	return r;
  80145d:	83 c4 10             	add    $0x10,%esp
  801460:	89 f8                	mov    %edi,%eax
}
  801462:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801465:	5b                   	pop    %ebx
  801466:	5e                   	pop    %esi
  801467:	5f                   	pop    %edi
  801468:	5d                   	pop    %ebp
  801469:	c3                   	ret    

0080146a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80146a:	55                   	push   %ebp
  80146b:	89 e5                	mov    %esp,%ebp
  80146d:	53                   	push   %ebx
  80146e:	83 ec 14             	sub    $0x14,%esp
  801471:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801474:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801477:	50                   	push   %eax
  801478:	53                   	push   %ebx
  801479:	e8 86 fd ff ff       	call   801204 <fd_lookup>
  80147e:	83 c4 08             	add    $0x8,%esp
  801481:	89 c2                	mov    %eax,%edx
  801483:	85 c0                	test   %eax,%eax
  801485:	78 6d                	js     8014f4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801487:	83 ec 08             	sub    $0x8,%esp
  80148a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148d:	50                   	push   %eax
  80148e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801491:	ff 30                	pushl  (%eax)
  801493:	e8 c2 fd ff ff       	call   80125a <dev_lookup>
  801498:	83 c4 10             	add    $0x10,%esp
  80149b:	85 c0                	test   %eax,%eax
  80149d:	78 4c                	js     8014eb <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80149f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014a2:	8b 42 08             	mov    0x8(%edx),%eax
  8014a5:	83 e0 03             	and    $0x3,%eax
  8014a8:	83 f8 01             	cmp    $0x1,%eax
  8014ab:	75 21                	jne    8014ce <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ad:	a1 08 40 80 00       	mov    0x804008,%eax
  8014b2:	8b 40 7c             	mov    0x7c(%eax),%eax
  8014b5:	83 ec 04             	sub    $0x4,%esp
  8014b8:	53                   	push   %ebx
  8014b9:	50                   	push   %eax
  8014ba:	68 8c 28 80 00       	push   $0x80288c
  8014bf:	e8 1d ee ff ff       	call   8002e1 <cprintf>
		return -E_INVAL;
  8014c4:	83 c4 10             	add    $0x10,%esp
  8014c7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014cc:	eb 26                	jmp    8014f4 <read+0x8a>
	}
	if (!dev->dev_read)
  8014ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d1:	8b 40 08             	mov    0x8(%eax),%eax
  8014d4:	85 c0                	test   %eax,%eax
  8014d6:	74 17                	je     8014ef <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8014d8:	83 ec 04             	sub    $0x4,%esp
  8014db:	ff 75 10             	pushl  0x10(%ebp)
  8014de:	ff 75 0c             	pushl  0xc(%ebp)
  8014e1:	52                   	push   %edx
  8014e2:	ff d0                	call   *%eax
  8014e4:	89 c2                	mov    %eax,%edx
  8014e6:	83 c4 10             	add    $0x10,%esp
  8014e9:	eb 09                	jmp    8014f4 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014eb:	89 c2                	mov    %eax,%edx
  8014ed:	eb 05                	jmp    8014f4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014ef:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8014f4:	89 d0                	mov    %edx,%eax
  8014f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f9:	c9                   	leave  
  8014fa:	c3                   	ret    

008014fb <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014fb:	55                   	push   %ebp
  8014fc:	89 e5                	mov    %esp,%ebp
  8014fe:	57                   	push   %edi
  8014ff:	56                   	push   %esi
  801500:	53                   	push   %ebx
  801501:	83 ec 0c             	sub    $0xc,%esp
  801504:	8b 7d 08             	mov    0x8(%ebp),%edi
  801507:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80150a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80150f:	eb 21                	jmp    801532 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801511:	83 ec 04             	sub    $0x4,%esp
  801514:	89 f0                	mov    %esi,%eax
  801516:	29 d8                	sub    %ebx,%eax
  801518:	50                   	push   %eax
  801519:	89 d8                	mov    %ebx,%eax
  80151b:	03 45 0c             	add    0xc(%ebp),%eax
  80151e:	50                   	push   %eax
  80151f:	57                   	push   %edi
  801520:	e8 45 ff ff ff       	call   80146a <read>
		if (m < 0)
  801525:	83 c4 10             	add    $0x10,%esp
  801528:	85 c0                	test   %eax,%eax
  80152a:	78 10                	js     80153c <readn+0x41>
			return m;
		if (m == 0)
  80152c:	85 c0                	test   %eax,%eax
  80152e:	74 0a                	je     80153a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801530:	01 c3                	add    %eax,%ebx
  801532:	39 f3                	cmp    %esi,%ebx
  801534:	72 db                	jb     801511 <readn+0x16>
  801536:	89 d8                	mov    %ebx,%eax
  801538:	eb 02                	jmp    80153c <readn+0x41>
  80153a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80153c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80153f:	5b                   	pop    %ebx
  801540:	5e                   	pop    %esi
  801541:	5f                   	pop    %edi
  801542:	5d                   	pop    %ebp
  801543:	c3                   	ret    

00801544 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801544:	55                   	push   %ebp
  801545:	89 e5                	mov    %esp,%ebp
  801547:	53                   	push   %ebx
  801548:	83 ec 14             	sub    $0x14,%esp
  80154b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80154e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801551:	50                   	push   %eax
  801552:	53                   	push   %ebx
  801553:	e8 ac fc ff ff       	call   801204 <fd_lookup>
  801558:	83 c4 08             	add    $0x8,%esp
  80155b:	89 c2                	mov    %eax,%edx
  80155d:	85 c0                	test   %eax,%eax
  80155f:	78 68                	js     8015c9 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801561:	83 ec 08             	sub    $0x8,%esp
  801564:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801567:	50                   	push   %eax
  801568:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156b:	ff 30                	pushl  (%eax)
  80156d:	e8 e8 fc ff ff       	call   80125a <dev_lookup>
  801572:	83 c4 10             	add    $0x10,%esp
  801575:	85 c0                	test   %eax,%eax
  801577:	78 47                	js     8015c0 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801579:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801580:	75 21                	jne    8015a3 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801582:	a1 08 40 80 00       	mov    0x804008,%eax
  801587:	8b 40 7c             	mov    0x7c(%eax),%eax
  80158a:	83 ec 04             	sub    $0x4,%esp
  80158d:	53                   	push   %ebx
  80158e:	50                   	push   %eax
  80158f:	68 a8 28 80 00       	push   $0x8028a8
  801594:	e8 48 ed ff ff       	call   8002e1 <cprintf>
		return -E_INVAL;
  801599:	83 c4 10             	add    $0x10,%esp
  80159c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015a1:	eb 26                	jmp    8015c9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a6:	8b 52 0c             	mov    0xc(%edx),%edx
  8015a9:	85 d2                	test   %edx,%edx
  8015ab:	74 17                	je     8015c4 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015ad:	83 ec 04             	sub    $0x4,%esp
  8015b0:	ff 75 10             	pushl  0x10(%ebp)
  8015b3:	ff 75 0c             	pushl  0xc(%ebp)
  8015b6:	50                   	push   %eax
  8015b7:	ff d2                	call   *%edx
  8015b9:	89 c2                	mov    %eax,%edx
  8015bb:	83 c4 10             	add    $0x10,%esp
  8015be:	eb 09                	jmp    8015c9 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c0:	89 c2                	mov    %eax,%edx
  8015c2:	eb 05                	jmp    8015c9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015c4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015c9:	89 d0                	mov    %edx,%eax
  8015cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ce:	c9                   	leave  
  8015cf:	c3                   	ret    

008015d0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015d6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015d9:	50                   	push   %eax
  8015da:	ff 75 08             	pushl  0x8(%ebp)
  8015dd:	e8 22 fc ff ff       	call   801204 <fd_lookup>
  8015e2:	83 c4 08             	add    $0x8,%esp
  8015e5:	85 c0                	test   %eax,%eax
  8015e7:	78 0e                	js     8015f7 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015ef:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015f7:	c9                   	leave  
  8015f8:	c3                   	ret    

008015f9 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015f9:	55                   	push   %ebp
  8015fa:	89 e5                	mov    %esp,%ebp
  8015fc:	53                   	push   %ebx
  8015fd:	83 ec 14             	sub    $0x14,%esp
  801600:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801603:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801606:	50                   	push   %eax
  801607:	53                   	push   %ebx
  801608:	e8 f7 fb ff ff       	call   801204 <fd_lookup>
  80160d:	83 c4 08             	add    $0x8,%esp
  801610:	89 c2                	mov    %eax,%edx
  801612:	85 c0                	test   %eax,%eax
  801614:	78 65                	js     80167b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801616:	83 ec 08             	sub    $0x8,%esp
  801619:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161c:	50                   	push   %eax
  80161d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801620:	ff 30                	pushl  (%eax)
  801622:	e8 33 fc ff ff       	call   80125a <dev_lookup>
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	85 c0                	test   %eax,%eax
  80162c:	78 44                	js     801672 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80162e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801631:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801635:	75 21                	jne    801658 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801637:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80163c:	8b 40 7c             	mov    0x7c(%eax),%eax
  80163f:	83 ec 04             	sub    $0x4,%esp
  801642:	53                   	push   %ebx
  801643:	50                   	push   %eax
  801644:	68 68 28 80 00       	push   $0x802868
  801649:	e8 93 ec ff ff       	call   8002e1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80164e:	83 c4 10             	add    $0x10,%esp
  801651:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801656:	eb 23                	jmp    80167b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801658:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80165b:	8b 52 18             	mov    0x18(%edx),%edx
  80165e:	85 d2                	test   %edx,%edx
  801660:	74 14                	je     801676 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801662:	83 ec 08             	sub    $0x8,%esp
  801665:	ff 75 0c             	pushl  0xc(%ebp)
  801668:	50                   	push   %eax
  801669:	ff d2                	call   *%edx
  80166b:	89 c2                	mov    %eax,%edx
  80166d:	83 c4 10             	add    $0x10,%esp
  801670:	eb 09                	jmp    80167b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801672:	89 c2                	mov    %eax,%edx
  801674:	eb 05                	jmp    80167b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801676:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80167b:	89 d0                	mov    %edx,%eax
  80167d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801680:	c9                   	leave  
  801681:	c3                   	ret    

00801682 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	53                   	push   %ebx
  801686:	83 ec 14             	sub    $0x14,%esp
  801689:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80168f:	50                   	push   %eax
  801690:	ff 75 08             	pushl  0x8(%ebp)
  801693:	e8 6c fb ff ff       	call   801204 <fd_lookup>
  801698:	83 c4 08             	add    $0x8,%esp
  80169b:	89 c2                	mov    %eax,%edx
  80169d:	85 c0                	test   %eax,%eax
  80169f:	78 58                	js     8016f9 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a1:	83 ec 08             	sub    $0x8,%esp
  8016a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a7:	50                   	push   %eax
  8016a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ab:	ff 30                	pushl  (%eax)
  8016ad:	e8 a8 fb ff ff       	call   80125a <dev_lookup>
  8016b2:	83 c4 10             	add    $0x10,%esp
  8016b5:	85 c0                	test   %eax,%eax
  8016b7:	78 37                	js     8016f0 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016bc:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016c0:	74 32                	je     8016f4 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016c2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016c5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016cc:	00 00 00 
	stat->st_isdir = 0;
  8016cf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016d6:	00 00 00 
	stat->st_dev = dev;
  8016d9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016df:	83 ec 08             	sub    $0x8,%esp
  8016e2:	53                   	push   %ebx
  8016e3:	ff 75 f0             	pushl  -0x10(%ebp)
  8016e6:	ff 50 14             	call   *0x14(%eax)
  8016e9:	89 c2                	mov    %eax,%edx
  8016eb:	83 c4 10             	add    $0x10,%esp
  8016ee:	eb 09                	jmp    8016f9 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f0:	89 c2                	mov    %eax,%edx
  8016f2:	eb 05                	jmp    8016f9 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016f4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016f9:	89 d0                	mov    %edx,%eax
  8016fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016fe:	c9                   	leave  
  8016ff:	c3                   	ret    

00801700 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801700:	55                   	push   %ebp
  801701:	89 e5                	mov    %esp,%ebp
  801703:	56                   	push   %esi
  801704:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801705:	83 ec 08             	sub    $0x8,%esp
  801708:	6a 00                	push   $0x0
  80170a:	ff 75 08             	pushl  0x8(%ebp)
  80170d:	e8 e3 01 00 00       	call   8018f5 <open>
  801712:	89 c3                	mov    %eax,%ebx
  801714:	83 c4 10             	add    $0x10,%esp
  801717:	85 c0                	test   %eax,%eax
  801719:	78 1b                	js     801736 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80171b:	83 ec 08             	sub    $0x8,%esp
  80171e:	ff 75 0c             	pushl  0xc(%ebp)
  801721:	50                   	push   %eax
  801722:	e8 5b ff ff ff       	call   801682 <fstat>
  801727:	89 c6                	mov    %eax,%esi
	close(fd);
  801729:	89 1c 24             	mov    %ebx,(%esp)
  80172c:	e8 fd fb ff ff       	call   80132e <close>
	return r;
  801731:	83 c4 10             	add    $0x10,%esp
  801734:	89 f0                	mov    %esi,%eax
}
  801736:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801739:	5b                   	pop    %ebx
  80173a:	5e                   	pop    %esi
  80173b:	5d                   	pop    %ebp
  80173c:	c3                   	ret    

0080173d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80173d:	55                   	push   %ebp
  80173e:	89 e5                	mov    %esp,%ebp
  801740:	56                   	push   %esi
  801741:	53                   	push   %ebx
  801742:	89 c6                	mov    %eax,%esi
  801744:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801746:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80174d:	75 12                	jne    801761 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80174f:	83 ec 0c             	sub    $0xc,%esp
  801752:	6a 01                	push   $0x1
  801754:	e8 a4 09 00 00       	call   8020fd <ipc_find_env>
  801759:	a3 04 40 80 00       	mov    %eax,0x804004
  80175e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801761:	6a 07                	push   $0x7
  801763:	68 00 50 80 00       	push   $0x805000
  801768:	56                   	push   %esi
  801769:	ff 35 04 40 80 00    	pushl  0x804004
  80176f:	e8 27 09 00 00       	call   80209b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801774:	83 c4 0c             	add    $0xc,%esp
  801777:	6a 00                	push   $0x0
  801779:	53                   	push   %ebx
  80177a:	6a 00                	push   $0x0
  80177c:	e8 9f 08 00 00       	call   802020 <ipc_recv>
}
  801781:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801784:	5b                   	pop    %ebx
  801785:	5e                   	pop    %esi
  801786:	5d                   	pop    %ebp
  801787:	c3                   	ret    

00801788 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801788:	55                   	push   %ebp
  801789:	89 e5                	mov    %esp,%ebp
  80178b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80178e:	8b 45 08             	mov    0x8(%ebp),%eax
  801791:	8b 40 0c             	mov    0xc(%eax),%eax
  801794:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801799:	8b 45 0c             	mov    0xc(%ebp),%eax
  80179c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a6:	b8 02 00 00 00       	mov    $0x2,%eax
  8017ab:	e8 8d ff ff ff       	call   80173d <fsipc>
}
  8017b0:	c9                   	leave  
  8017b1:	c3                   	ret    

008017b2 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017b2:	55                   	push   %ebp
  8017b3:	89 e5                	mov    %esp,%ebp
  8017b5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8017be:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c8:	b8 06 00 00 00       	mov    $0x6,%eax
  8017cd:	e8 6b ff ff ff       	call   80173d <fsipc>
}
  8017d2:	c9                   	leave  
  8017d3:	c3                   	ret    

008017d4 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	53                   	push   %ebx
  8017d8:	83 ec 04             	sub    $0x4,%esp
  8017db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017de:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e4:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ee:	b8 05 00 00 00       	mov    $0x5,%eax
  8017f3:	e8 45 ff ff ff       	call   80173d <fsipc>
  8017f8:	85 c0                	test   %eax,%eax
  8017fa:	78 2c                	js     801828 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017fc:	83 ec 08             	sub    $0x8,%esp
  8017ff:	68 00 50 80 00       	push   $0x805000
  801804:	53                   	push   %ebx
  801805:	e8 5c f0 ff ff       	call   800866 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80180a:	a1 80 50 80 00       	mov    0x805080,%eax
  80180f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801815:	a1 84 50 80 00       	mov    0x805084,%eax
  80181a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801820:	83 c4 10             	add    $0x10,%esp
  801823:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801828:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80182b:	c9                   	leave  
  80182c:	c3                   	ret    

0080182d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80182d:	55                   	push   %ebp
  80182e:	89 e5                	mov    %esp,%ebp
  801830:	83 ec 0c             	sub    $0xc,%esp
  801833:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801836:	8b 55 08             	mov    0x8(%ebp),%edx
  801839:	8b 52 0c             	mov    0xc(%edx),%edx
  80183c:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801842:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801847:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80184c:	0f 47 c2             	cmova  %edx,%eax
  80184f:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801854:	50                   	push   %eax
  801855:	ff 75 0c             	pushl  0xc(%ebp)
  801858:	68 08 50 80 00       	push   $0x805008
  80185d:	e8 96 f1 ff ff       	call   8009f8 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801862:	ba 00 00 00 00       	mov    $0x0,%edx
  801867:	b8 04 00 00 00       	mov    $0x4,%eax
  80186c:	e8 cc fe ff ff       	call   80173d <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801871:	c9                   	leave  
  801872:	c3                   	ret    

00801873 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801873:	55                   	push   %ebp
  801874:	89 e5                	mov    %esp,%ebp
  801876:	56                   	push   %esi
  801877:	53                   	push   %ebx
  801878:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80187b:	8b 45 08             	mov    0x8(%ebp),%eax
  80187e:	8b 40 0c             	mov    0xc(%eax),%eax
  801881:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801886:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80188c:	ba 00 00 00 00       	mov    $0x0,%edx
  801891:	b8 03 00 00 00       	mov    $0x3,%eax
  801896:	e8 a2 fe ff ff       	call   80173d <fsipc>
  80189b:	89 c3                	mov    %eax,%ebx
  80189d:	85 c0                	test   %eax,%eax
  80189f:	78 4b                	js     8018ec <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018a1:	39 c6                	cmp    %eax,%esi
  8018a3:	73 16                	jae    8018bb <devfile_read+0x48>
  8018a5:	68 d8 28 80 00       	push   $0x8028d8
  8018aa:	68 df 28 80 00       	push   $0x8028df
  8018af:	6a 7c                	push   $0x7c
  8018b1:	68 f4 28 80 00       	push   $0x8028f4
  8018b6:	e8 4d e9 ff ff       	call   800208 <_panic>
	assert(r <= PGSIZE);
  8018bb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018c0:	7e 16                	jle    8018d8 <devfile_read+0x65>
  8018c2:	68 ff 28 80 00       	push   $0x8028ff
  8018c7:	68 df 28 80 00       	push   $0x8028df
  8018cc:	6a 7d                	push   $0x7d
  8018ce:	68 f4 28 80 00       	push   $0x8028f4
  8018d3:	e8 30 e9 ff ff       	call   800208 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018d8:	83 ec 04             	sub    $0x4,%esp
  8018db:	50                   	push   %eax
  8018dc:	68 00 50 80 00       	push   $0x805000
  8018e1:	ff 75 0c             	pushl  0xc(%ebp)
  8018e4:	e8 0f f1 ff ff       	call   8009f8 <memmove>
	return r;
  8018e9:	83 c4 10             	add    $0x10,%esp
}
  8018ec:	89 d8                	mov    %ebx,%eax
  8018ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f1:	5b                   	pop    %ebx
  8018f2:	5e                   	pop    %esi
  8018f3:	5d                   	pop    %ebp
  8018f4:	c3                   	ret    

008018f5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018f5:	55                   	push   %ebp
  8018f6:	89 e5                	mov    %esp,%ebp
  8018f8:	53                   	push   %ebx
  8018f9:	83 ec 20             	sub    $0x20,%esp
  8018fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018ff:	53                   	push   %ebx
  801900:	e8 28 ef ff ff       	call   80082d <strlen>
  801905:	83 c4 10             	add    $0x10,%esp
  801908:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80190d:	7f 67                	jg     801976 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80190f:	83 ec 0c             	sub    $0xc,%esp
  801912:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801915:	50                   	push   %eax
  801916:	e8 9a f8 ff ff       	call   8011b5 <fd_alloc>
  80191b:	83 c4 10             	add    $0x10,%esp
		return r;
  80191e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801920:	85 c0                	test   %eax,%eax
  801922:	78 57                	js     80197b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801924:	83 ec 08             	sub    $0x8,%esp
  801927:	53                   	push   %ebx
  801928:	68 00 50 80 00       	push   $0x805000
  80192d:	e8 34 ef ff ff       	call   800866 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801932:	8b 45 0c             	mov    0xc(%ebp),%eax
  801935:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80193a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80193d:	b8 01 00 00 00       	mov    $0x1,%eax
  801942:	e8 f6 fd ff ff       	call   80173d <fsipc>
  801947:	89 c3                	mov    %eax,%ebx
  801949:	83 c4 10             	add    $0x10,%esp
  80194c:	85 c0                	test   %eax,%eax
  80194e:	79 14                	jns    801964 <open+0x6f>
		fd_close(fd, 0);
  801950:	83 ec 08             	sub    $0x8,%esp
  801953:	6a 00                	push   $0x0
  801955:	ff 75 f4             	pushl  -0xc(%ebp)
  801958:	e8 50 f9 ff ff       	call   8012ad <fd_close>
		return r;
  80195d:	83 c4 10             	add    $0x10,%esp
  801960:	89 da                	mov    %ebx,%edx
  801962:	eb 17                	jmp    80197b <open+0x86>
	}

	return fd2num(fd);
  801964:	83 ec 0c             	sub    $0xc,%esp
  801967:	ff 75 f4             	pushl  -0xc(%ebp)
  80196a:	e8 1f f8 ff ff       	call   80118e <fd2num>
  80196f:	89 c2                	mov    %eax,%edx
  801971:	83 c4 10             	add    $0x10,%esp
  801974:	eb 05                	jmp    80197b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801976:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80197b:	89 d0                	mov    %edx,%eax
  80197d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801980:	c9                   	leave  
  801981:	c3                   	ret    

00801982 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801982:	55                   	push   %ebp
  801983:	89 e5                	mov    %esp,%ebp
  801985:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801988:	ba 00 00 00 00       	mov    $0x0,%edx
  80198d:	b8 08 00 00 00       	mov    $0x8,%eax
  801992:	e8 a6 fd ff ff       	call   80173d <fsipc>
}
  801997:	c9                   	leave  
  801998:	c3                   	ret    

00801999 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801999:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80199d:	7e 37                	jle    8019d6 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  80199f:	55                   	push   %ebp
  8019a0:	89 e5                	mov    %esp,%ebp
  8019a2:	53                   	push   %ebx
  8019a3:	83 ec 08             	sub    $0x8,%esp
  8019a6:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8019a8:	ff 70 04             	pushl  0x4(%eax)
  8019ab:	8d 40 10             	lea    0x10(%eax),%eax
  8019ae:	50                   	push   %eax
  8019af:	ff 33                	pushl  (%ebx)
  8019b1:	e8 8e fb ff ff       	call   801544 <write>
		if (result > 0)
  8019b6:	83 c4 10             	add    $0x10,%esp
  8019b9:	85 c0                	test   %eax,%eax
  8019bb:	7e 03                	jle    8019c0 <writebuf+0x27>
			b->result += result;
  8019bd:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8019c0:	3b 43 04             	cmp    0x4(%ebx),%eax
  8019c3:	74 0d                	je     8019d2 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8019c5:	85 c0                	test   %eax,%eax
  8019c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019cc:	0f 4f c2             	cmovg  %edx,%eax
  8019cf:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8019d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d5:	c9                   	leave  
  8019d6:	f3 c3                	repz ret 

008019d8 <putch>:

static void
putch(int ch, void *thunk)
{
  8019d8:	55                   	push   %ebp
  8019d9:	89 e5                	mov    %esp,%ebp
  8019db:	53                   	push   %ebx
  8019dc:	83 ec 04             	sub    $0x4,%esp
  8019df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8019e2:	8b 53 04             	mov    0x4(%ebx),%edx
  8019e5:	8d 42 01             	lea    0x1(%edx),%eax
  8019e8:	89 43 04             	mov    %eax,0x4(%ebx)
  8019eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019ee:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8019f2:	3d 00 01 00 00       	cmp    $0x100,%eax
  8019f7:	75 0e                	jne    801a07 <putch+0x2f>
		writebuf(b);
  8019f9:	89 d8                	mov    %ebx,%eax
  8019fb:	e8 99 ff ff ff       	call   801999 <writebuf>
		b->idx = 0;
  801a00:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801a07:	83 c4 04             	add    $0x4,%esp
  801a0a:	5b                   	pop    %ebx
  801a0b:	5d                   	pop    %ebp
  801a0c:	c3                   	ret    

00801a0d <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801a0d:	55                   	push   %ebp
  801a0e:	89 e5                	mov    %esp,%ebp
  801a10:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801a16:	8b 45 08             	mov    0x8(%ebp),%eax
  801a19:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801a1f:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801a26:	00 00 00 
	b.result = 0;
  801a29:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801a30:	00 00 00 
	b.error = 1;
  801a33:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801a3a:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801a3d:	ff 75 10             	pushl  0x10(%ebp)
  801a40:	ff 75 0c             	pushl  0xc(%ebp)
  801a43:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a49:	50                   	push   %eax
  801a4a:	68 d8 19 80 00       	push   $0x8019d8
  801a4f:	e8 c4 e9 ff ff       	call   800418 <vprintfmt>
	if (b.idx > 0)
  801a54:	83 c4 10             	add    $0x10,%esp
  801a57:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801a5e:	7e 0b                	jle    801a6b <vfprintf+0x5e>
		writebuf(&b);
  801a60:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a66:	e8 2e ff ff ff       	call   801999 <writebuf>

	return (b.result ? b.result : b.error);
  801a6b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801a71:	85 c0                	test   %eax,%eax
  801a73:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801a7a:	c9                   	leave  
  801a7b:	c3                   	ret    

00801a7c <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801a7c:	55                   	push   %ebp
  801a7d:	89 e5                	mov    %esp,%ebp
  801a7f:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a82:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801a85:	50                   	push   %eax
  801a86:	ff 75 0c             	pushl  0xc(%ebp)
  801a89:	ff 75 08             	pushl  0x8(%ebp)
  801a8c:	e8 7c ff ff ff       	call   801a0d <vfprintf>
	va_end(ap);

	return cnt;
}
  801a91:	c9                   	leave  
  801a92:	c3                   	ret    

00801a93 <printf>:

int
printf(const char *fmt, ...)
{
  801a93:	55                   	push   %ebp
  801a94:	89 e5                	mov    %esp,%ebp
  801a96:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a99:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801a9c:	50                   	push   %eax
  801a9d:	ff 75 08             	pushl  0x8(%ebp)
  801aa0:	6a 01                	push   $0x1
  801aa2:	e8 66 ff ff ff       	call   801a0d <vfprintf>
	va_end(ap);

	return cnt;
}
  801aa7:	c9                   	leave  
  801aa8:	c3                   	ret    

00801aa9 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801aa9:	55                   	push   %ebp
  801aaa:	89 e5                	mov    %esp,%ebp
  801aac:	56                   	push   %esi
  801aad:	53                   	push   %ebx
  801aae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ab1:	83 ec 0c             	sub    $0xc,%esp
  801ab4:	ff 75 08             	pushl  0x8(%ebp)
  801ab7:	e8 e2 f6 ff ff       	call   80119e <fd2data>
  801abc:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801abe:	83 c4 08             	add    $0x8,%esp
  801ac1:	68 0b 29 80 00       	push   $0x80290b
  801ac6:	53                   	push   %ebx
  801ac7:	e8 9a ed ff ff       	call   800866 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801acc:	8b 46 04             	mov    0x4(%esi),%eax
  801acf:	2b 06                	sub    (%esi),%eax
  801ad1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ad7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ade:	00 00 00 
	stat->st_dev = &devpipe;
  801ae1:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801ae8:	30 80 00 
	return 0;
}
  801aeb:	b8 00 00 00 00       	mov    $0x0,%eax
  801af0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af3:	5b                   	pop    %ebx
  801af4:	5e                   	pop    %esi
  801af5:	5d                   	pop    %ebp
  801af6:	c3                   	ret    

00801af7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	53                   	push   %ebx
  801afb:	83 ec 0c             	sub    $0xc,%esp
  801afe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b01:	53                   	push   %ebx
  801b02:	6a 00                	push   $0x0
  801b04:	e8 e5 f1 ff ff       	call   800cee <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b09:	89 1c 24             	mov    %ebx,(%esp)
  801b0c:	e8 8d f6 ff ff       	call   80119e <fd2data>
  801b11:	83 c4 08             	add    $0x8,%esp
  801b14:	50                   	push   %eax
  801b15:	6a 00                	push   $0x0
  801b17:	e8 d2 f1 ff ff       	call   800cee <sys_page_unmap>
}
  801b1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b1f:	c9                   	leave  
  801b20:	c3                   	ret    

00801b21 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b21:	55                   	push   %ebp
  801b22:	89 e5                	mov    %esp,%ebp
  801b24:	57                   	push   %edi
  801b25:	56                   	push   %esi
  801b26:	53                   	push   %ebx
  801b27:	83 ec 1c             	sub    $0x1c,%esp
  801b2a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b2d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b2f:	a1 08 40 80 00       	mov    0x804008,%eax
  801b34:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b3a:	83 ec 0c             	sub    $0xc,%esp
  801b3d:	ff 75 e0             	pushl  -0x20(%ebp)
  801b40:	e8 fa 05 00 00       	call   80213f <pageref>
  801b45:	89 c3                	mov    %eax,%ebx
  801b47:	89 3c 24             	mov    %edi,(%esp)
  801b4a:	e8 f0 05 00 00       	call   80213f <pageref>
  801b4f:	83 c4 10             	add    $0x10,%esp
  801b52:	39 c3                	cmp    %eax,%ebx
  801b54:	0f 94 c1             	sete   %cl
  801b57:	0f b6 c9             	movzbl %cl,%ecx
  801b5a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b5d:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801b63:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  801b69:	39 ce                	cmp    %ecx,%esi
  801b6b:	74 1e                	je     801b8b <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801b6d:	39 c3                	cmp    %eax,%ebx
  801b6f:	75 be                	jne    801b2f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b71:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  801b77:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b7a:	50                   	push   %eax
  801b7b:	56                   	push   %esi
  801b7c:	68 12 29 80 00       	push   $0x802912
  801b81:	e8 5b e7 ff ff       	call   8002e1 <cprintf>
  801b86:	83 c4 10             	add    $0x10,%esp
  801b89:	eb a4                	jmp    801b2f <_pipeisclosed+0xe>
	}
}
  801b8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b91:	5b                   	pop    %ebx
  801b92:	5e                   	pop    %esi
  801b93:	5f                   	pop    %edi
  801b94:	5d                   	pop    %ebp
  801b95:	c3                   	ret    

00801b96 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	57                   	push   %edi
  801b9a:	56                   	push   %esi
  801b9b:	53                   	push   %ebx
  801b9c:	83 ec 28             	sub    $0x28,%esp
  801b9f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ba2:	56                   	push   %esi
  801ba3:	e8 f6 f5 ff ff       	call   80119e <fd2data>
  801ba8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801baa:	83 c4 10             	add    $0x10,%esp
  801bad:	bf 00 00 00 00       	mov    $0x0,%edi
  801bb2:	eb 4b                	jmp    801bff <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bb4:	89 da                	mov    %ebx,%edx
  801bb6:	89 f0                	mov    %esi,%eax
  801bb8:	e8 64 ff ff ff       	call   801b21 <_pipeisclosed>
  801bbd:	85 c0                	test   %eax,%eax
  801bbf:	75 48                	jne    801c09 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bc1:	e8 84 f0 ff ff       	call   800c4a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bc6:	8b 43 04             	mov    0x4(%ebx),%eax
  801bc9:	8b 0b                	mov    (%ebx),%ecx
  801bcb:	8d 51 20             	lea    0x20(%ecx),%edx
  801bce:	39 d0                	cmp    %edx,%eax
  801bd0:	73 e2                	jae    801bb4 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bd5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bd9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bdc:	89 c2                	mov    %eax,%edx
  801bde:	c1 fa 1f             	sar    $0x1f,%edx
  801be1:	89 d1                	mov    %edx,%ecx
  801be3:	c1 e9 1b             	shr    $0x1b,%ecx
  801be6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801be9:	83 e2 1f             	and    $0x1f,%edx
  801bec:	29 ca                	sub    %ecx,%edx
  801bee:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bf2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bf6:	83 c0 01             	add    $0x1,%eax
  801bf9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bfc:	83 c7 01             	add    $0x1,%edi
  801bff:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c02:	75 c2                	jne    801bc6 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c04:	8b 45 10             	mov    0x10(%ebp),%eax
  801c07:	eb 05                	jmp    801c0e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c09:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c11:	5b                   	pop    %ebx
  801c12:	5e                   	pop    %esi
  801c13:	5f                   	pop    %edi
  801c14:	5d                   	pop    %ebp
  801c15:	c3                   	ret    

00801c16 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c16:	55                   	push   %ebp
  801c17:	89 e5                	mov    %esp,%ebp
  801c19:	57                   	push   %edi
  801c1a:	56                   	push   %esi
  801c1b:	53                   	push   %ebx
  801c1c:	83 ec 18             	sub    $0x18,%esp
  801c1f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c22:	57                   	push   %edi
  801c23:	e8 76 f5 ff ff       	call   80119e <fd2data>
  801c28:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c2a:	83 c4 10             	add    $0x10,%esp
  801c2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c32:	eb 3d                	jmp    801c71 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c34:	85 db                	test   %ebx,%ebx
  801c36:	74 04                	je     801c3c <devpipe_read+0x26>
				return i;
  801c38:	89 d8                	mov    %ebx,%eax
  801c3a:	eb 44                	jmp    801c80 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c3c:	89 f2                	mov    %esi,%edx
  801c3e:	89 f8                	mov    %edi,%eax
  801c40:	e8 dc fe ff ff       	call   801b21 <_pipeisclosed>
  801c45:	85 c0                	test   %eax,%eax
  801c47:	75 32                	jne    801c7b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c49:	e8 fc ef ff ff       	call   800c4a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c4e:	8b 06                	mov    (%esi),%eax
  801c50:	3b 46 04             	cmp    0x4(%esi),%eax
  801c53:	74 df                	je     801c34 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c55:	99                   	cltd   
  801c56:	c1 ea 1b             	shr    $0x1b,%edx
  801c59:	01 d0                	add    %edx,%eax
  801c5b:	83 e0 1f             	and    $0x1f,%eax
  801c5e:	29 d0                	sub    %edx,%eax
  801c60:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c68:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c6b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c6e:	83 c3 01             	add    $0x1,%ebx
  801c71:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c74:	75 d8                	jne    801c4e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c76:	8b 45 10             	mov    0x10(%ebp),%eax
  801c79:	eb 05                	jmp    801c80 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c7b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c83:	5b                   	pop    %ebx
  801c84:	5e                   	pop    %esi
  801c85:	5f                   	pop    %edi
  801c86:	5d                   	pop    %ebp
  801c87:	c3                   	ret    

00801c88 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c88:	55                   	push   %ebp
  801c89:	89 e5                	mov    %esp,%ebp
  801c8b:	56                   	push   %esi
  801c8c:	53                   	push   %ebx
  801c8d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c90:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c93:	50                   	push   %eax
  801c94:	e8 1c f5 ff ff       	call   8011b5 <fd_alloc>
  801c99:	83 c4 10             	add    $0x10,%esp
  801c9c:	89 c2                	mov    %eax,%edx
  801c9e:	85 c0                	test   %eax,%eax
  801ca0:	0f 88 2c 01 00 00    	js     801dd2 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ca6:	83 ec 04             	sub    $0x4,%esp
  801ca9:	68 07 04 00 00       	push   $0x407
  801cae:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb1:	6a 00                	push   $0x0
  801cb3:	e8 b1 ef ff ff       	call   800c69 <sys_page_alloc>
  801cb8:	83 c4 10             	add    $0x10,%esp
  801cbb:	89 c2                	mov    %eax,%edx
  801cbd:	85 c0                	test   %eax,%eax
  801cbf:	0f 88 0d 01 00 00    	js     801dd2 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cc5:	83 ec 0c             	sub    $0xc,%esp
  801cc8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ccb:	50                   	push   %eax
  801ccc:	e8 e4 f4 ff ff       	call   8011b5 <fd_alloc>
  801cd1:	89 c3                	mov    %eax,%ebx
  801cd3:	83 c4 10             	add    $0x10,%esp
  801cd6:	85 c0                	test   %eax,%eax
  801cd8:	0f 88 e2 00 00 00    	js     801dc0 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cde:	83 ec 04             	sub    $0x4,%esp
  801ce1:	68 07 04 00 00       	push   $0x407
  801ce6:	ff 75 f0             	pushl  -0x10(%ebp)
  801ce9:	6a 00                	push   $0x0
  801ceb:	e8 79 ef ff ff       	call   800c69 <sys_page_alloc>
  801cf0:	89 c3                	mov    %eax,%ebx
  801cf2:	83 c4 10             	add    $0x10,%esp
  801cf5:	85 c0                	test   %eax,%eax
  801cf7:	0f 88 c3 00 00 00    	js     801dc0 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cfd:	83 ec 0c             	sub    $0xc,%esp
  801d00:	ff 75 f4             	pushl  -0xc(%ebp)
  801d03:	e8 96 f4 ff ff       	call   80119e <fd2data>
  801d08:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d0a:	83 c4 0c             	add    $0xc,%esp
  801d0d:	68 07 04 00 00       	push   $0x407
  801d12:	50                   	push   %eax
  801d13:	6a 00                	push   $0x0
  801d15:	e8 4f ef ff ff       	call   800c69 <sys_page_alloc>
  801d1a:	89 c3                	mov    %eax,%ebx
  801d1c:	83 c4 10             	add    $0x10,%esp
  801d1f:	85 c0                	test   %eax,%eax
  801d21:	0f 88 89 00 00 00    	js     801db0 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d27:	83 ec 0c             	sub    $0xc,%esp
  801d2a:	ff 75 f0             	pushl  -0x10(%ebp)
  801d2d:	e8 6c f4 ff ff       	call   80119e <fd2data>
  801d32:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d39:	50                   	push   %eax
  801d3a:	6a 00                	push   $0x0
  801d3c:	56                   	push   %esi
  801d3d:	6a 00                	push   $0x0
  801d3f:	e8 68 ef ff ff       	call   800cac <sys_page_map>
  801d44:	89 c3                	mov    %eax,%ebx
  801d46:	83 c4 20             	add    $0x20,%esp
  801d49:	85 c0                	test   %eax,%eax
  801d4b:	78 55                	js     801da2 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d4d:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d56:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d5b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d62:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d68:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d6b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d70:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d77:	83 ec 0c             	sub    $0xc,%esp
  801d7a:	ff 75 f4             	pushl  -0xc(%ebp)
  801d7d:	e8 0c f4 ff ff       	call   80118e <fd2num>
  801d82:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d85:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d87:	83 c4 04             	add    $0x4,%esp
  801d8a:	ff 75 f0             	pushl  -0x10(%ebp)
  801d8d:	e8 fc f3 ff ff       	call   80118e <fd2num>
  801d92:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d95:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801d98:	83 c4 10             	add    $0x10,%esp
  801d9b:	ba 00 00 00 00       	mov    $0x0,%edx
  801da0:	eb 30                	jmp    801dd2 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801da2:	83 ec 08             	sub    $0x8,%esp
  801da5:	56                   	push   %esi
  801da6:	6a 00                	push   $0x0
  801da8:	e8 41 ef ff ff       	call   800cee <sys_page_unmap>
  801dad:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801db0:	83 ec 08             	sub    $0x8,%esp
  801db3:	ff 75 f0             	pushl  -0x10(%ebp)
  801db6:	6a 00                	push   $0x0
  801db8:	e8 31 ef ff ff       	call   800cee <sys_page_unmap>
  801dbd:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801dc0:	83 ec 08             	sub    $0x8,%esp
  801dc3:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc6:	6a 00                	push   $0x0
  801dc8:	e8 21 ef ff ff       	call   800cee <sys_page_unmap>
  801dcd:	83 c4 10             	add    $0x10,%esp
  801dd0:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801dd2:	89 d0                	mov    %edx,%eax
  801dd4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dd7:	5b                   	pop    %ebx
  801dd8:	5e                   	pop    %esi
  801dd9:	5d                   	pop    %ebp
  801dda:	c3                   	ret    

00801ddb <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ddb:	55                   	push   %ebp
  801ddc:	89 e5                	mov    %esp,%ebp
  801dde:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801de1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de4:	50                   	push   %eax
  801de5:	ff 75 08             	pushl  0x8(%ebp)
  801de8:	e8 17 f4 ff ff       	call   801204 <fd_lookup>
  801ded:	83 c4 10             	add    $0x10,%esp
  801df0:	85 c0                	test   %eax,%eax
  801df2:	78 18                	js     801e0c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801df4:	83 ec 0c             	sub    $0xc,%esp
  801df7:	ff 75 f4             	pushl  -0xc(%ebp)
  801dfa:	e8 9f f3 ff ff       	call   80119e <fd2data>
	return _pipeisclosed(fd, p);
  801dff:	89 c2                	mov    %eax,%edx
  801e01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e04:	e8 18 fd ff ff       	call   801b21 <_pipeisclosed>
  801e09:	83 c4 10             	add    $0x10,%esp
}
  801e0c:	c9                   	leave  
  801e0d:	c3                   	ret    

00801e0e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e0e:	55                   	push   %ebp
  801e0f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e11:	b8 00 00 00 00       	mov    $0x0,%eax
  801e16:	5d                   	pop    %ebp
  801e17:	c3                   	ret    

00801e18 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e18:	55                   	push   %ebp
  801e19:	89 e5                	mov    %esp,%ebp
  801e1b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e1e:	68 2a 29 80 00       	push   $0x80292a
  801e23:	ff 75 0c             	pushl  0xc(%ebp)
  801e26:	e8 3b ea ff ff       	call   800866 <strcpy>
	return 0;
}
  801e2b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e30:	c9                   	leave  
  801e31:	c3                   	ret    

00801e32 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e32:	55                   	push   %ebp
  801e33:	89 e5                	mov    %esp,%ebp
  801e35:	57                   	push   %edi
  801e36:	56                   	push   %esi
  801e37:	53                   	push   %ebx
  801e38:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e3e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e43:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e49:	eb 2d                	jmp    801e78 <devcons_write+0x46>
		m = n - tot;
  801e4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e4e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e50:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e53:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e58:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e5b:	83 ec 04             	sub    $0x4,%esp
  801e5e:	53                   	push   %ebx
  801e5f:	03 45 0c             	add    0xc(%ebp),%eax
  801e62:	50                   	push   %eax
  801e63:	57                   	push   %edi
  801e64:	e8 8f eb ff ff       	call   8009f8 <memmove>
		sys_cputs(buf, m);
  801e69:	83 c4 08             	add    $0x8,%esp
  801e6c:	53                   	push   %ebx
  801e6d:	57                   	push   %edi
  801e6e:	e8 3a ed ff ff       	call   800bad <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e73:	01 de                	add    %ebx,%esi
  801e75:	83 c4 10             	add    $0x10,%esp
  801e78:	89 f0                	mov    %esi,%eax
  801e7a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e7d:	72 cc                	jb     801e4b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e82:	5b                   	pop    %ebx
  801e83:	5e                   	pop    %esi
  801e84:	5f                   	pop    %edi
  801e85:	5d                   	pop    %ebp
  801e86:	c3                   	ret    

00801e87 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e87:	55                   	push   %ebp
  801e88:	89 e5                	mov    %esp,%ebp
  801e8a:	83 ec 08             	sub    $0x8,%esp
  801e8d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e92:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e96:	74 2a                	je     801ec2 <devcons_read+0x3b>
  801e98:	eb 05                	jmp    801e9f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e9a:	e8 ab ed ff ff       	call   800c4a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e9f:	e8 27 ed ff ff       	call   800bcb <sys_cgetc>
  801ea4:	85 c0                	test   %eax,%eax
  801ea6:	74 f2                	je     801e9a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ea8:	85 c0                	test   %eax,%eax
  801eaa:	78 16                	js     801ec2 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801eac:	83 f8 04             	cmp    $0x4,%eax
  801eaf:	74 0c                	je     801ebd <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801eb1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801eb4:	88 02                	mov    %al,(%edx)
	return 1;
  801eb6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ebb:	eb 05                	jmp    801ec2 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ebd:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ec2:	c9                   	leave  
  801ec3:	c3                   	ret    

00801ec4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ec4:	55                   	push   %ebp
  801ec5:	89 e5                	mov    %esp,%ebp
  801ec7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801eca:	8b 45 08             	mov    0x8(%ebp),%eax
  801ecd:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ed0:	6a 01                	push   $0x1
  801ed2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ed5:	50                   	push   %eax
  801ed6:	e8 d2 ec ff ff       	call   800bad <sys_cputs>
}
  801edb:	83 c4 10             	add    $0x10,%esp
  801ede:	c9                   	leave  
  801edf:	c3                   	ret    

00801ee0 <getchar>:

int
getchar(void)
{
  801ee0:	55                   	push   %ebp
  801ee1:	89 e5                	mov    %esp,%ebp
  801ee3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ee6:	6a 01                	push   $0x1
  801ee8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eeb:	50                   	push   %eax
  801eec:	6a 00                	push   $0x0
  801eee:	e8 77 f5 ff ff       	call   80146a <read>
	if (r < 0)
  801ef3:	83 c4 10             	add    $0x10,%esp
  801ef6:	85 c0                	test   %eax,%eax
  801ef8:	78 0f                	js     801f09 <getchar+0x29>
		return r;
	if (r < 1)
  801efa:	85 c0                	test   %eax,%eax
  801efc:	7e 06                	jle    801f04 <getchar+0x24>
		return -E_EOF;
	return c;
  801efe:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f02:	eb 05                	jmp    801f09 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f04:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f09:	c9                   	leave  
  801f0a:	c3                   	ret    

00801f0b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f0b:	55                   	push   %ebp
  801f0c:	89 e5                	mov    %esp,%ebp
  801f0e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f14:	50                   	push   %eax
  801f15:	ff 75 08             	pushl  0x8(%ebp)
  801f18:	e8 e7 f2 ff ff       	call   801204 <fd_lookup>
  801f1d:	83 c4 10             	add    $0x10,%esp
  801f20:	85 c0                	test   %eax,%eax
  801f22:	78 11                	js     801f35 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f27:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f2d:	39 10                	cmp    %edx,(%eax)
  801f2f:	0f 94 c0             	sete   %al
  801f32:	0f b6 c0             	movzbl %al,%eax
}
  801f35:	c9                   	leave  
  801f36:	c3                   	ret    

00801f37 <opencons>:

int
opencons(void)
{
  801f37:	55                   	push   %ebp
  801f38:	89 e5                	mov    %esp,%ebp
  801f3a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f3d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f40:	50                   	push   %eax
  801f41:	e8 6f f2 ff ff       	call   8011b5 <fd_alloc>
  801f46:	83 c4 10             	add    $0x10,%esp
		return r;
  801f49:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f4b:	85 c0                	test   %eax,%eax
  801f4d:	78 3e                	js     801f8d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f4f:	83 ec 04             	sub    $0x4,%esp
  801f52:	68 07 04 00 00       	push   $0x407
  801f57:	ff 75 f4             	pushl  -0xc(%ebp)
  801f5a:	6a 00                	push   $0x0
  801f5c:	e8 08 ed ff ff       	call   800c69 <sys_page_alloc>
  801f61:	83 c4 10             	add    $0x10,%esp
		return r;
  801f64:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f66:	85 c0                	test   %eax,%eax
  801f68:	78 23                	js     801f8d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f6a:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f73:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f78:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f7f:	83 ec 0c             	sub    $0xc,%esp
  801f82:	50                   	push   %eax
  801f83:	e8 06 f2 ff ff       	call   80118e <fd2num>
  801f88:	89 c2                	mov    %eax,%edx
  801f8a:	83 c4 10             	add    $0x10,%esp
}
  801f8d:	89 d0                	mov    %edx,%eax
  801f8f:	c9                   	leave  
  801f90:	c3                   	ret    

00801f91 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f91:	55                   	push   %ebp
  801f92:	89 e5                	mov    %esp,%ebp
  801f94:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f97:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f9e:	75 2a                	jne    801fca <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801fa0:	83 ec 04             	sub    $0x4,%esp
  801fa3:	6a 07                	push   $0x7
  801fa5:	68 00 f0 bf ee       	push   $0xeebff000
  801faa:	6a 00                	push   $0x0
  801fac:	e8 b8 ec ff ff       	call   800c69 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801fb1:	83 c4 10             	add    $0x10,%esp
  801fb4:	85 c0                	test   %eax,%eax
  801fb6:	79 12                	jns    801fca <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801fb8:	50                   	push   %eax
  801fb9:	68 36 29 80 00       	push   $0x802936
  801fbe:	6a 23                	push   $0x23
  801fc0:	68 3a 29 80 00       	push   $0x80293a
  801fc5:	e8 3e e2 ff ff       	call   800208 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fca:	8b 45 08             	mov    0x8(%ebp),%eax
  801fcd:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801fd2:	83 ec 08             	sub    $0x8,%esp
  801fd5:	68 fc 1f 80 00       	push   $0x801ffc
  801fda:	6a 00                	push   $0x0
  801fdc:	e8 d3 ed ff ff       	call   800db4 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801fe1:	83 c4 10             	add    $0x10,%esp
  801fe4:	85 c0                	test   %eax,%eax
  801fe6:	79 12                	jns    801ffa <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801fe8:	50                   	push   %eax
  801fe9:	68 36 29 80 00       	push   $0x802936
  801fee:	6a 2c                	push   $0x2c
  801ff0:	68 3a 29 80 00       	push   $0x80293a
  801ff5:	e8 0e e2 ff ff       	call   800208 <_panic>
	}
}
  801ffa:	c9                   	leave  
  801ffb:	c3                   	ret    

00801ffc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801ffc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801ffd:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802002:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802004:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802007:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  80200b:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802010:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802014:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802016:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802019:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  80201a:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80201d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80201e:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80201f:	c3                   	ret    

00802020 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
  802023:	56                   	push   %esi
  802024:	53                   	push   %ebx
  802025:	8b 75 08             	mov    0x8(%ebp),%esi
  802028:	8b 45 0c             	mov    0xc(%ebp),%eax
  80202b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80202e:	85 c0                	test   %eax,%eax
  802030:	75 12                	jne    802044 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802032:	83 ec 0c             	sub    $0xc,%esp
  802035:	68 00 00 c0 ee       	push   $0xeec00000
  80203a:	e8 da ed ff ff       	call   800e19 <sys_ipc_recv>
  80203f:	83 c4 10             	add    $0x10,%esp
  802042:	eb 0c                	jmp    802050 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802044:	83 ec 0c             	sub    $0xc,%esp
  802047:	50                   	push   %eax
  802048:	e8 cc ed ff ff       	call   800e19 <sys_ipc_recv>
  80204d:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802050:	85 f6                	test   %esi,%esi
  802052:	0f 95 c1             	setne  %cl
  802055:	85 db                	test   %ebx,%ebx
  802057:	0f 95 c2             	setne  %dl
  80205a:	84 d1                	test   %dl,%cl
  80205c:	74 09                	je     802067 <ipc_recv+0x47>
  80205e:	89 c2                	mov    %eax,%edx
  802060:	c1 ea 1f             	shr    $0x1f,%edx
  802063:	84 d2                	test   %dl,%dl
  802065:	75 2d                	jne    802094 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802067:	85 f6                	test   %esi,%esi
  802069:	74 0d                	je     802078 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80206b:	a1 08 40 80 00       	mov    0x804008,%eax
  802070:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  802076:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802078:	85 db                	test   %ebx,%ebx
  80207a:	74 0d                	je     802089 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80207c:	a1 08 40 80 00       	mov    0x804008,%eax
  802081:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  802087:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802089:	a1 08 40 80 00       	mov    0x804008,%eax
  80208e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  802094:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802097:	5b                   	pop    %ebx
  802098:	5e                   	pop    %esi
  802099:	5d                   	pop    %ebp
  80209a:	c3                   	ret    

0080209b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80209b:	55                   	push   %ebp
  80209c:	89 e5                	mov    %esp,%ebp
  80209e:	57                   	push   %edi
  80209f:	56                   	push   %esi
  8020a0:	53                   	push   %ebx
  8020a1:	83 ec 0c             	sub    $0xc,%esp
  8020a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020a7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8020ad:	85 db                	test   %ebx,%ebx
  8020af:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020b4:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8020b7:	ff 75 14             	pushl  0x14(%ebp)
  8020ba:	53                   	push   %ebx
  8020bb:	56                   	push   %esi
  8020bc:	57                   	push   %edi
  8020bd:	e8 34 ed ff ff       	call   800df6 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8020c2:	89 c2                	mov    %eax,%edx
  8020c4:	c1 ea 1f             	shr    $0x1f,%edx
  8020c7:	83 c4 10             	add    $0x10,%esp
  8020ca:	84 d2                	test   %dl,%dl
  8020cc:	74 17                	je     8020e5 <ipc_send+0x4a>
  8020ce:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020d1:	74 12                	je     8020e5 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8020d3:	50                   	push   %eax
  8020d4:	68 48 29 80 00       	push   $0x802948
  8020d9:	6a 47                	push   $0x47
  8020db:	68 56 29 80 00       	push   $0x802956
  8020e0:	e8 23 e1 ff ff       	call   800208 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8020e5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020e8:	75 07                	jne    8020f1 <ipc_send+0x56>
			sys_yield();
  8020ea:	e8 5b eb ff ff       	call   800c4a <sys_yield>
  8020ef:	eb c6                	jmp    8020b7 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8020f1:	85 c0                	test   %eax,%eax
  8020f3:	75 c2                	jne    8020b7 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8020f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020f8:	5b                   	pop    %ebx
  8020f9:	5e                   	pop    %esi
  8020fa:	5f                   	pop    %edi
  8020fb:	5d                   	pop    %ebp
  8020fc:	c3                   	ret    

008020fd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020fd:	55                   	push   %ebp
  8020fe:	89 e5                	mov    %esp,%ebp
  802100:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802103:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802108:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  80210e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802114:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  80211a:	39 ca                	cmp    %ecx,%edx
  80211c:	75 10                	jne    80212e <ipc_find_env+0x31>
			return envs[i].env_id;
  80211e:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  802124:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802129:	8b 40 7c             	mov    0x7c(%eax),%eax
  80212c:	eb 0f                	jmp    80213d <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80212e:	83 c0 01             	add    $0x1,%eax
  802131:	3d 00 04 00 00       	cmp    $0x400,%eax
  802136:	75 d0                	jne    802108 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802138:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80213d:	5d                   	pop    %ebp
  80213e:	c3                   	ret    

0080213f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80213f:	55                   	push   %ebp
  802140:	89 e5                	mov    %esp,%ebp
  802142:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802145:	89 d0                	mov    %edx,%eax
  802147:	c1 e8 16             	shr    $0x16,%eax
  80214a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802151:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802156:	f6 c1 01             	test   $0x1,%cl
  802159:	74 1d                	je     802178 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80215b:	c1 ea 0c             	shr    $0xc,%edx
  80215e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802165:	f6 c2 01             	test   $0x1,%dl
  802168:	74 0e                	je     802178 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80216a:	c1 ea 0c             	shr    $0xc,%edx
  80216d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802174:	ef 
  802175:	0f b7 c0             	movzwl %ax,%eax
}
  802178:	5d                   	pop    %ebp
  802179:	c3                   	ret    
  80217a:	66 90                	xchg   %ax,%ax
  80217c:	66 90                	xchg   %ax,%ax
  80217e:	66 90                	xchg   %ax,%ax

00802180 <__udivdi3>:
  802180:	55                   	push   %ebp
  802181:	57                   	push   %edi
  802182:	56                   	push   %esi
  802183:	53                   	push   %ebx
  802184:	83 ec 1c             	sub    $0x1c,%esp
  802187:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80218b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80218f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802193:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802197:	85 f6                	test   %esi,%esi
  802199:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80219d:	89 ca                	mov    %ecx,%edx
  80219f:	89 f8                	mov    %edi,%eax
  8021a1:	75 3d                	jne    8021e0 <__udivdi3+0x60>
  8021a3:	39 cf                	cmp    %ecx,%edi
  8021a5:	0f 87 c5 00 00 00    	ja     802270 <__udivdi3+0xf0>
  8021ab:	85 ff                	test   %edi,%edi
  8021ad:	89 fd                	mov    %edi,%ebp
  8021af:	75 0b                	jne    8021bc <__udivdi3+0x3c>
  8021b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021b6:	31 d2                	xor    %edx,%edx
  8021b8:	f7 f7                	div    %edi
  8021ba:	89 c5                	mov    %eax,%ebp
  8021bc:	89 c8                	mov    %ecx,%eax
  8021be:	31 d2                	xor    %edx,%edx
  8021c0:	f7 f5                	div    %ebp
  8021c2:	89 c1                	mov    %eax,%ecx
  8021c4:	89 d8                	mov    %ebx,%eax
  8021c6:	89 cf                	mov    %ecx,%edi
  8021c8:	f7 f5                	div    %ebp
  8021ca:	89 c3                	mov    %eax,%ebx
  8021cc:	89 d8                	mov    %ebx,%eax
  8021ce:	89 fa                	mov    %edi,%edx
  8021d0:	83 c4 1c             	add    $0x1c,%esp
  8021d3:	5b                   	pop    %ebx
  8021d4:	5e                   	pop    %esi
  8021d5:	5f                   	pop    %edi
  8021d6:	5d                   	pop    %ebp
  8021d7:	c3                   	ret    
  8021d8:	90                   	nop
  8021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	39 ce                	cmp    %ecx,%esi
  8021e2:	77 74                	ja     802258 <__udivdi3+0xd8>
  8021e4:	0f bd fe             	bsr    %esi,%edi
  8021e7:	83 f7 1f             	xor    $0x1f,%edi
  8021ea:	0f 84 98 00 00 00    	je     802288 <__udivdi3+0x108>
  8021f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021f5:	89 f9                	mov    %edi,%ecx
  8021f7:	89 c5                	mov    %eax,%ebp
  8021f9:	29 fb                	sub    %edi,%ebx
  8021fb:	d3 e6                	shl    %cl,%esi
  8021fd:	89 d9                	mov    %ebx,%ecx
  8021ff:	d3 ed                	shr    %cl,%ebp
  802201:	89 f9                	mov    %edi,%ecx
  802203:	d3 e0                	shl    %cl,%eax
  802205:	09 ee                	or     %ebp,%esi
  802207:	89 d9                	mov    %ebx,%ecx
  802209:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80220d:	89 d5                	mov    %edx,%ebp
  80220f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802213:	d3 ed                	shr    %cl,%ebp
  802215:	89 f9                	mov    %edi,%ecx
  802217:	d3 e2                	shl    %cl,%edx
  802219:	89 d9                	mov    %ebx,%ecx
  80221b:	d3 e8                	shr    %cl,%eax
  80221d:	09 c2                	or     %eax,%edx
  80221f:	89 d0                	mov    %edx,%eax
  802221:	89 ea                	mov    %ebp,%edx
  802223:	f7 f6                	div    %esi
  802225:	89 d5                	mov    %edx,%ebp
  802227:	89 c3                	mov    %eax,%ebx
  802229:	f7 64 24 0c          	mull   0xc(%esp)
  80222d:	39 d5                	cmp    %edx,%ebp
  80222f:	72 10                	jb     802241 <__udivdi3+0xc1>
  802231:	8b 74 24 08          	mov    0x8(%esp),%esi
  802235:	89 f9                	mov    %edi,%ecx
  802237:	d3 e6                	shl    %cl,%esi
  802239:	39 c6                	cmp    %eax,%esi
  80223b:	73 07                	jae    802244 <__udivdi3+0xc4>
  80223d:	39 d5                	cmp    %edx,%ebp
  80223f:	75 03                	jne    802244 <__udivdi3+0xc4>
  802241:	83 eb 01             	sub    $0x1,%ebx
  802244:	31 ff                	xor    %edi,%edi
  802246:	89 d8                	mov    %ebx,%eax
  802248:	89 fa                	mov    %edi,%edx
  80224a:	83 c4 1c             	add    $0x1c,%esp
  80224d:	5b                   	pop    %ebx
  80224e:	5e                   	pop    %esi
  80224f:	5f                   	pop    %edi
  802250:	5d                   	pop    %ebp
  802251:	c3                   	ret    
  802252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802258:	31 ff                	xor    %edi,%edi
  80225a:	31 db                	xor    %ebx,%ebx
  80225c:	89 d8                	mov    %ebx,%eax
  80225e:	89 fa                	mov    %edi,%edx
  802260:	83 c4 1c             	add    $0x1c,%esp
  802263:	5b                   	pop    %ebx
  802264:	5e                   	pop    %esi
  802265:	5f                   	pop    %edi
  802266:	5d                   	pop    %ebp
  802267:	c3                   	ret    
  802268:	90                   	nop
  802269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802270:	89 d8                	mov    %ebx,%eax
  802272:	f7 f7                	div    %edi
  802274:	31 ff                	xor    %edi,%edi
  802276:	89 c3                	mov    %eax,%ebx
  802278:	89 d8                	mov    %ebx,%eax
  80227a:	89 fa                	mov    %edi,%edx
  80227c:	83 c4 1c             	add    $0x1c,%esp
  80227f:	5b                   	pop    %ebx
  802280:	5e                   	pop    %esi
  802281:	5f                   	pop    %edi
  802282:	5d                   	pop    %ebp
  802283:	c3                   	ret    
  802284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802288:	39 ce                	cmp    %ecx,%esi
  80228a:	72 0c                	jb     802298 <__udivdi3+0x118>
  80228c:	31 db                	xor    %ebx,%ebx
  80228e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802292:	0f 87 34 ff ff ff    	ja     8021cc <__udivdi3+0x4c>
  802298:	bb 01 00 00 00       	mov    $0x1,%ebx
  80229d:	e9 2a ff ff ff       	jmp    8021cc <__udivdi3+0x4c>
  8022a2:	66 90                	xchg   %ax,%ax
  8022a4:	66 90                	xchg   %ax,%ax
  8022a6:	66 90                	xchg   %ax,%ax
  8022a8:	66 90                	xchg   %ax,%ax
  8022aa:	66 90                	xchg   %ax,%ax
  8022ac:	66 90                	xchg   %ax,%ax
  8022ae:	66 90                	xchg   %ax,%ax

008022b0 <__umoddi3>:
  8022b0:	55                   	push   %ebp
  8022b1:	57                   	push   %edi
  8022b2:	56                   	push   %esi
  8022b3:	53                   	push   %ebx
  8022b4:	83 ec 1c             	sub    $0x1c,%esp
  8022b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022c7:	85 d2                	test   %edx,%edx
  8022c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022d1:	89 f3                	mov    %esi,%ebx
  8022d3:	89 3c 24             	mov    %edi,(%esp)
  8022d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022da:	75 1c                	jne    8022f8 <__umoddi3+0x48>
  8022dc:	39 f7                	cmp    %esi,%edi
  8022de:	76 50                	jbe    802330 <__umoddi3+0x80>
  8022e0:	89 c8                	mov    %ecx,%eax
  8022e2:	89 f2                	mov    %esi,%edx
  8022e4:	f7 f7                	div    %edi
  8022e6:	89 d0                	mov    %edx,%eax
  8022e8:	31 d2                	xor    %edx,%edx
  8022ea:	83 c4 1c             	add    $0x1c,%esp
  8022ed:	5b                   	pop    %ebx
  8022ee:	5e                   	pop    %esi
  8022ef:	5f                   	pop    %edi
  8022f0:	5d                   	pop    %ebp
  8022f1:	c3                   	ret    
  8022f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022f8:	39 f2                	cmp    %esi,%edx
  8022fa:	89 d0                	mov    %edx,%eax
  8022fc:	77 52                	ja     802350 <__umoddi3+0xa0>
  8022fe:	0f bd ea             	bsr    %edx,%ebp
  802301:	83 f5 1f             	xor    $0x1f,%ebp
  802304:	75 5a                	jne    802360 <__umoddi3+0xb0>
  802306:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80230a:	0f 82 e0 00 00 00    	jb     8023f0 <__umoddi3+0x140>
  802310:	39 0c 24             	cmp    %ecx,(%esp)
  802313:	0f 86 d7 00 00 00    	jbe    8023f0 <__umoddi3+0x140>
  802319:	8b 44 24 08          	mov    0x8(%esp),%eax
  80231d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802321:	83 c4 1c             	add    $0x1c,%esp
  802324:	5b                   	pop    %ebx
  802325:	5e                   	pop    %esi
  802326:	5f                   	pop    %edi
  802327:	5d                   	pop    %ebp
  802328:	c3                   	ret    
  802329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802330:	85 ff                	test   %edi,%edi
  802332:	89 fd                	mov    %edi,%ebp
  802334:	75 0b                	jne    802341 <__umoddi3+0x91>
  802336:	b8 01 00 00 00       	mov    $0x1,%eax
  80233b:	31 d2                	xor    %edx,%edx
  80233d:	f7 f7                	div    %edi
  80233f:	89 c5                	mov    %eax,%ebp
  802341:	89 f0                	mov    %esi,%eax
  802343:	31 d2                	xor    %edx,%edx
  802345:	f7 f5                	div    %ebp
  802347:	89 c8                	mov    %ecx,%eax
  802349:	f7 f5                	div    %ebp
  80234b:	89 d0                	mov    %edx,%eax
  80234d:	eb 99                	jmp    8022e8 <__umoddi3+0x38>
  80234f:	90                   	nop
  802350:	89 c8                	mov    %ecx,%eax
  802352:	89 f2                	mov    %esi,%edx
  802354:	83 c4 1c             	add    $0x1c,%esp
  802357:	5b                   	pop    %ebx
  802358:	5e                   	pop    %esi
  802359:	5f                   	pop    %edi
  80235a:	5d                   	pop    %ebp
  80235b:	c3                   	ret    
  80235c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802360:	8b 34 24             	mov    (%esp),%esi
  802363:	bf 20 00 00 00       	mov    $0x20,%edi
  802368:	89 e9                	mov    %ebp,%ecx
  80236a:	29 ef                	sub    %ebp,%edi
  80236c:	d3 e0                	shl    %cl,%eax
  80236e:	89 f9                	mov    %edi,%ecx
  802370:	89 f2                	mov    %esi,%edx
  802372:	d3 ea                	shr    %cl,%edx
  802374:	89 e9                	mov    %ebp,%ecx
  802376:	09 c2                	or     %eax,%edx
  802378:	89 d8                	mov    %ebx,%eax
  80237a:	89 14 24             	mov    %edx,(%esp)
  80237d:	89 f2                	mov    %esi,%edx
  80237f:	d3 e2                	shl    %cl,%edx
  802381:	89 f9                	mov    %edi,%ecx
  802383:	89 54 24 04          	mov    %edx,0x4(%esp)
  802387:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80238b:	d3 e8                	shr    %cl,%eax
  80238d:	89 e9                	mov    %ebp,%ecx
  80238f:	89 c6                	mov    %eax,%esi
  802391:	d3 e3                	shl    %cl,%ebx
  802393:	89 f9                	mov    %edi,%ecx
  802395:	89 d0                	mov    %edx,%eax
  802397:	d3 e8                	shr    %cl,%eax
  802399:	89 e9                	mov    %ebp,%ecx
  80239b:	09 d8                	or     %ebx,%eax
  80239d:	89 d3                	mov    %edx,%ebx
  80239f:	89 f2                	mov    %esi,%edx
  8023a1:	f7 34 24             	divl   (%esp)
  8023a4:	89 d6                	mov    %edx,%esi
  8023a6:	d3 e3                	shl    %cl,%ebx
  8023a8:	f7 64 24 04          	mull   0x4(%esp)
  8023ac:	39 d6                	cmp    %edx,%esi
  8023ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023b2:	89 d1                	mov    %edx,%ecx
  8023b4:	89 c3                	mov    %eax,%ebx
  8023b6:	72 08                	jb     8023c0 <__umoddi3+0x110>
  8023b8:	75 11                	jne    8023cb <__umoddi3+0x11b>
  8023ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023be:	73 0b                	jae    8023cb <__umoddi3+0x11b>
  8023c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023c4:	1b 14 24             	sbb    (%esp),%edx
  8023c7:	89 d1                	mov    %edx,%ecx
  8023c9:	89 c3                	mov    %eax,%ebx
  8023cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023cf:	29 da                	sub    %ebx,%edx
  8023d1:	19 ce                	sbb    %ecx,%esi
  8023d3:	89 f9                	mov    %edi,%ecx
  8023d5:	89 f0                	mov    %esi,%eax
  8023d7:	d3 e0                	shl    %cl,%eax
  8023d9:	89 e9                	mov    %ebp,%ecx
  8023db:	d3 ea                	shr    %cl,%edx
  8023dd:	89 e9                	mov    %ebp,%ecx
  8023df:	d3 ee                	shr    %cl,%esi
  8023e1:	09 d0                	or     %edx,%eax
  8023e3:	89 f2                	mov    %esi,%edx
  8023e5:	83 c4 1c             	add    $0x1c,%esp
  8023e8:	5b                   	pop    %ebx
  8023e9:	5e                   	pop    %esi
  8023ea:	5f                   	pop    %edi
  8023eb:	5d                   	pop    %ebp
  8023ec:	c3                   	ret    
  8023ed:	8d 76 00             	lea    0x0(%esi),%esi
  8023f0:	29 f9                	sub    %edi,%ecx
  8023f2:	19 d6                	sbb    %edx,%esi
  8023f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023fc:	e9 18 ff ff ff       	jmp    802319 <__umoddi3+0x69>
