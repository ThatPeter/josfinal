
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
  80005d:	68 60 24 80 00       	push   $0x802460
  800062:	e8 7e 1a 00 00       	call   801ae5 <printf>
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
  80007c:	e8 0f 15 00 00       	call   801590 <write>
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	83 f8 01             	cmp    $0x1,%eax
  800087:	74 18                	je     8000a1 <num+0x6e>
			panic("write error copying %s: %e", s, r);
  800089:	83 ec 0c             	sub    $0xc,%esp
  80008c:	50                   	push   %eax
  80008d:	ff 75 0c             	pushl  0xc(%ebp)
  800090:	68 65 24 80 00       	push   $0x802465
  800095:	6a 13                	push   $0x13
  800097:	68 80 24 80 00       	push   $0x802480
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
  8000b8:	e8 f6 13 00 00       	call   8014b3 <read>
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
  8000d3:	68 8b 24 80 00       	push   $0x80248b
  8000d8:	6a 18                	push   $0x18
  8000da:	68 80 24 80 00       	push   $0x802480
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
  8000f4:	c7 05 04 30 80 00 a0 	movl   $0x8024a0,0x803004
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
  800114:	68 a4 24 80 00       	push   $0x8024a4
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
  80012f:	e8 13 18 00 00       	call   801947 <open>
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
  800146:	68 ac 24 80 00       	push   $0x8024ac
  80014b:	6a 27                	push   $0x27
  80014d:	68 80 24 80 00       	push   $0x802480
  800152:	e8 b1 00 00 00       	call   800208 <_panic>
			else {
				num(f, argv[i]);
  800157:	83 ec 08             	sub    $0x8,%esp
  80015a:	ff 33                	pushl  (%ebx)
  80015c:	50                   	push   %eax
  80015d:	e8 d1 fe ff ff       	call   800033 <num>
				close(f);
  800162:	89 34 24             	mov    %esi,(%esp)
  800165:	e8 0d 12 00 00       	call   801377 <close>

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
  80019a:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  8001f4:	e8 a9 11 00 00       	call   8013a2 <close_all>
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
  800226:	68 c8 24 80 00       	push   $0x8024c8
  80022b:	e8 b1 00 00 00       	call   8002e1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800230:	83 c4 18             	add    $0x18,%esp
  800233:	53                   	push   %ebx
  800234:	ff 75 10             	pushl  0x10(%ebp)
  800237:	e8 54 00 00 00       	call   800290 <vcprintf>
	cprintf("\n");
  80023c:	c7 04 24 63 29 80 00 	movl   $0x802963,(%esp)
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
  800344:	e8 87 1e 00 00       	call   8021d0 <__udivdi3>
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
  800387:	e8 74 1f 00 00       	call   802300 <__umoddi3>
  80038c:	83 c4 14             	add    $0x14,%esp
  80038f:	0f be 80 eb 24 80 00 	movsbl 0x8024eb(%eax),%eax
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
  80048b:	ff 24 85 20 26 80 00 	jmp    *0x802620(,%eax,4)
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
  80054f:	8b 14 85 80 27 80 00 	mov    0x802780(,%eax,4),%edx
  800556:	85 d2                	test   %edx,%edx
  800558:	75 18                	jne    800572 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80055a:	50                   	push   %eax
  80055b:	68 03 25 80 00       	push   $0x802503
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
  800573:	68 31 29 80 00       	push   $0x802931
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
  800597:	b8 fc 24 80 00       	mov    $0x8024fc,%eax
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
  800c12:	68 df 27 80 00       	push   $0x8027df
  800c17:	6a 23                	push   $0x23
  800c19:	68 fc 27 80 00       	push   $0x8027fc
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
  800c93:	68 df 27 80 00       	push   $0x8027df
  800c98:	6a 23                	push   $0x23
  800c9a:	68 fc 27 80 00       	push   $0x8027fc
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
  800cd5:	68 df 27 80 00       	push   $0x8027df
  800cda:	6a 23                	push   $0x23
  800cdc:	68 fc 27 80 00       	push   $0x8027fc
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
  800d17:	68 df 27 80 00       	push   $0x8027df
  800d1c:	6a 23                	push   $0x23
  800d1e:	68 fc 27 80 00       	push   $0x8027fc
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
  800d59:	68 df 27 80 00       	push   $0x8027df
  800d5e:	6a 23                	push   $0x23
  800d60:	68 fc 27 80 00       	push   $0x8027fc
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
  800d9b:	68 df 27 80 00       	push   $0x8027df
  800da0:	6a 23                	push   $0x23
  800da2:	68 fc 27 80 00       	push   $0x8027fc
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
  800ddd:	68 df 27 80 00       	push   $0x8027df
  800de2:	6a 23                	push   $0x23
  800de4:	68 fc 27 80 00       	push   $0x8027fc
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
  800e41:	68 df 27 80 00       	push   $0x8027df
  800e46:	6a 23                	push   $0x23
  800e48:	68 fc 27 80 00       	push   $0x8027fc
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
  800ee0:	68 0a 28 80 00       	push   $0x80280a
  800ee5:	6a 1e                	push   $0x1e
  800ee7:	68 1a 28 80 00       	push   $0x80281a
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
  800f0a:	68 25 28 80 00       	push   $0x802825
  800f0f:	6a 2c                	push   $0x2c
  800f11:	68 1a 28 80 00       	push   $0x80281a
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
  800f52:	68 25 28 80 00       	push   $0x802825
  800f57:	6a 33                	push   $0x33
  800f59:	68 1a 28 80 00       	push   $0x80281a
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
  800f7a:	68 25 28 80 00       	push   $0x802825
  800f7f:	6a 37                	push   $0x37
  800f81:	68 1a 28 80 00       	push   $0x80281a
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
  800f9e:	e8 40 10 00 00       	call   801fe3 <set_pgfault_handler>
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
  800fb7:	68 3e 28 80 00       	push   $0x80283e
  800fbc:	68 84 00 00 00       	push   $0x84
  800fc1:	68 1a 28 80 00       	push   $0x80281a
  800fc6:	e8 3d f2 ff ff       	call   800208 <_panic>
  800fcb:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800fcd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fd1:	75 24                	jne    800ff7 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fd3:	e8 53 fc ff ff       	call   800c2b <sys_getenvid>
  800fd8:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fdd:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  801073:	68 4c 28 80 00       	push   $0x80284c
  801078:	6a 54                	push   $0x54
  80107a:	68 1a 28 80 00       	push   $0x80281a
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
  8010b8:	68 4c 28 80 00       	push   $0x80284c
  8010bd:	6a 5b                	push   $0x5b
  8010bf:	68 1a 28 80 00       	push   $0x80281a
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
  8010e6:	68 4c 28 80 00       	push   $0x80284c
  8010eb:	6a 5f                	push   $0x5f
  8010ed:	68 1a 28 80 00       	push   $0x80281a
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
  801110:	68 4c 28 80 00       	push   $0x80284c
  801115:	6a 64                	push   $0x64
  801117:	68 1a 28 80 00       	push   $0x80281a
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
  801138:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
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
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80116d:	55                   	push   %ebp
  80116e:	89 e5                	mov    %esp,%ebp
  801170:	56                   	push   %esi
  801171:	53                   	push   %ebx
  801172:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801175:	89 1d 0c 40 80 00    	mov    %ebx,0x80400c
	cprintf("in fork.c thread create. func: %x\n", func);
  80117b:	83 ec 08             	sub    $0x8,%esp
  80117e:	53                   	push   %ebx
  80117f:	68 64 28 80 00       	push   $0x802864
  801184:	e8 58 f1 ff ff       	call   8002e1 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801189:	c7 04 24 ce 01 80 00 	movl   $0x8001ce,(%esp)
  801190:	e8 c5 fc ff ff       	call   800e5a <sys_thread_create>
  801195:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801197:	83 c4 08             	add    $0x8,%esp
  80119a:	53                   	push   %ebx
  80119b:	68 64 28 80 00       	push   $0x802864
  8011a0:	e8 3c f1 ff ff       	call   8002e1 <cprintf>
	return id;
}
  8011a5:	89 f0                	mov    %esi,%eax
  8011a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011aa:	5b                   	pop    %ebx
  8011ab:	5e                   	pop    %esi
  8011ac:	5d                   	pop    %ebp
  8011ad:	c3                   	ret    

008011ae <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8011ae:	55                   	push   %ebp
  8011af:	89 e5                	mov    %esp,%ebp
  8011b1:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  8011b4:	ff 75 08             	pushl  0x8(%ebp)
  8011b7:	e8 be fc ff ff       	call   800e7a <sys_thread_free>
}
  8011bc:	83 c4 10             	add    $0x10,%esp
  8011bf:	c9                   	leave  
  8011c0:	c3                   	ret    

008011c1 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8011c1:	55                   	push   %ebp
  8011c2:	89 e5                	mov    %esp,%ebp
  8011c4:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  8011c7:	ff 75 08             	pushl  0x8(%ebp)
  8011ca:	e8 cb fc ff ff       	call   800e9a <sys_thread_join>
}
  8011cf:	83 c4 10             	add    $0x10,%esp
  8011d2:	c9                   	leave  
  8011d3:	c3                   	ret    

008011d4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011d4:	55                   	push   %ebp
  8011d5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011da:	05 00 00 00 30       	add    $0x30000000,%eax
  8011df:	c1 e8 0c             	shr    $0xc,%eax
}
  8011e2:	5d                   	pop    %ebp
  8011e3:	c3                   	ret    

008011e4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ea:	05 00 00 00 30       	add    $0x30000000,%eax
  8011ef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011f4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011f9:	5d                   	pop    %ebp
  8011fa:	c3                   	ret    

008011fb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801201:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801206:	89 c2                	mov    %eax,%edx
  801208:	c1 ea 16             	shr    $0x16,%edx
  80120b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801212:	f6 c2 01             	test   $0x1,%dl
  801215:	74 11                	je     801228 <fd_alloc+0x2d>
  801217:	89 c2                	mov    %eax,%edx
  801219:	c1 ea 0c             	shr    $0xc,%edx
  80121c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801223:	f6 c2 01             	test   $0x1,%dl
  801226:	75 09                	jne    801231 <fd_alloc+0x36>
			*fd_store = fd;
  801228:	89 01                	mov    %eax,(%ecx)
			return 0;
  80122a:	b8 00 00 00 00       	mov    $0x0,%eax
  80122f:	eb 17                	jmp    801248 <fd_alloc+0x4d>
  801231:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801236:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80123b:	75 c9                	jne    801206 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80123d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801243:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801248:	5d                   	pop    %ebp
  801249:	c3                   	ret    

0080124a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801250:	83 f8 1f             	cmp    $0x1f,%eax
  801253:	77 36                	ja     80128b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801255:	c1 e0 0c             	shl    $0xc,%eax
  801258:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80125d:	89 c2                	mov    %eax,%edx
  80125f:	c1 ea 16             	shr    $0x16,%edx
  801262:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801269:	f6 c2 01             	test   $0x1,%dl
  80126c:	74 24                	je     801292 <fd_lookup+0x48>
  80126e:	89 c2                	mov    %eax,%edx
  801270:	c1 ea 0c             	shr    $0xc,%edx
  801273:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80127a:	f6 c2 01             	test   $0x1,%dl
  80127d:	74 1a                	je     801299 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80127f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801282:	89 02                	mov    %eax,(%edx)
	return 0;
  801284:	b8 00 00 00 00       	mov    $0x0,%eax
  801289:	eb 13                	jmp    80129e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80128b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801290:	eb 0c                	jmp    80129e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801292:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801297:	eb 05                	jmp    80129e <fd_lookup+0x54>
  801299:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80129e:	5d                   	pop    %ebp
  80129f:	c3                   	ret    

008012a0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
  8012a3:	83 ec 08             	sub    $0x8,%esp
  8012a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012a9:	ba 08 29 80 00       	mov    $0x802908,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012ae:	eb 13                	jmp    8012c3 <dev_lookup+0x23>
  8012b0:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012b3:	39 08                	cmp    %ecx,(%eax)
  8012b5:	75 0c                	jne    8012c3 <dev_lookup+0x23>
			*dev = devtab[i];
  8012b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ba:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c1:	eb 31                	jmp    8012f4 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012c3:	8b 02                	mov    (%edx),%eax
  8012c5:	85 c0                	test   %eax,%eax
  8012c7:	75 e7                	jne    8012b0 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012c9:	a1 08 40 80 00       	mov    0x804008,%eax
  8012ce:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8012d4:	83 ec 04             	sub    $0x4,%esp
  8012d7:	51                   	push   %ecx
  8012d8:	50                   	push   %eax
  8012d9:	68 88 28 80 00       	push   $0x802888
  8012de:	e8 fe ef ff ff       	call   8002e1 <cprintf>
	*dev = 0;
  8012e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012e6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012ec:	83 c4 10             	add    $0x10,%esp
  8012ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012f4:	c9                   	leave  
  8012f5:	c3                   	ret    

008012f6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012f6:	55                   	push   %ebp
  8012f7:	89 e5                	mov    %esp,%ebp
  8012f9:	56                   	push   %esi
  8012fa:	53                   	push   %ebx
  8012fb:	83 ec 10             	sub    $0x10,%esp
  8012fe:	8b 75 08             	mov    0x8(%ebp),%esi
  801301:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801304:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801307:	50                   	push   %eax
  801308:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80130e:	c1 e8 0c             	shr    $0xc,%eax
  801311:	50                   	push   %eax
  801312:	e8 33 ff ff ff       	call   80124a <fd_lookup>
  801317:	83 c4 08             	add    $0x8,%esp
  80131a:	85 c0                	test   %eax,%eax
  80131c:	78 05                	js     801323 <fd_close+0x2d>
	    || fd != fd2)
  80131e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801321:	74 0c                	je     80132f <fd_close+0x39>
		return (must_exist ? r : 0);
  801323:	84 db                	test   %bl,%bl
  801325:	ba 00 00 00 00       	mov    $0x0,%edx
  80132a:	0f 44 c2             	cmove  %edx,%eax
  80132d:	eb 41                	jmp    801370 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80132f:	83 ec 08             	sub    $0x8,%esp
  801332:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801335:	50                   	push   %eax
  801336:	ff 36                	pushl  (%esi)
  801338:	e8 63 ff ff ff       	call   8012a0 <dev_lookup>
  80133d:	89 c3                	mov    %eax,%ebx
  80133f:	83 c4 10             	add    $0x10,%esp
  801342:	85 c0                	test   %eax,%eax
  801344:	78 1a                	js     801360 <fd_close+0x6a>
		if (dev->dev_close)
  801346:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801349:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80134c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801351:	85 c0                	test   %eax,%eax
  801353:	74 0b                	je     801360 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801355:	83 ec 0c             	sub    $0xc,%esp
  801358:	56                   	push   %esi
  801359:	ff d0                	call   *%eax
  80135b:	89 c3                	mov    %eax,%ebx
  80135d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801360:	83 ec 08             	sub    $0x8,%esp
  801363:	56                   	push   %esi
  801364:	6a 00                	push   $0x0
  801366:	e8 83 f9 ff ff       	call   800cee <sys_page_unmap>
	return r;
  80136b:	83 c4 10             	add    $0x10,%esp
  80136e:	89 d8                	mov    %ebx,%eax
}
  801370:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801373:	5b                   	pop    %ebx
  801374:	5e                   	pop    %esi
  801375:	5d                   	pop    %ebp
  801376:	c3                   	ret    

00801377 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80137d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801380:	50                   	push   %eax
  801381:	ff 75 08             	pushl  0x8(%ebp)
  801384:	e8 c1 fe ff ff       	call   80124a <fd_lookup>
  801389:	83 c4 08             	add    $0x8,%esp
  80138c:	85 c0                	test   %eax,%eax
  80138e:	78 10                	js     8013a0 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801390:	83 ec 08             	sub    $0x8,%esp
  801393:	6a 01                	push   $0x1
  801395:	ff 75 f4             	pushl  -0xc(%ebp)
  801398:	e8 59 ff ff ff       	call   8012f6 <fd_close>
  80139d:	83 c4 10             	add    $0x10,%esp
}
  8013a0:	c9                   	leave  
  8013a1:	c3                   	ret    

008013a2 <close_all>:

void
close_all(void)
{
  8013a2:	55                   	push   %ebp
  8013a3:	89 e5                	mov    %esp,%ebp
  8013a5:	53                   	push   %ebx
  8013a6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013a9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013ae:	83 ec 0c             	sub    $0xc,%esp
  8013b1:	53                   	push   %ebx
  8013b2:	e8 c0 ff ff ff       	call   801377 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013b7:	83 c3 01             	add    $0x1,%ebx
  8013ba:	83 c4 10             	add    $0x10,%esp
  8013bd:	83 fb 20             	cmp    $0x20,%ebx
  8013c0:	75 ec                	jne    8013ae <close_all+0xc>
		close(i);
}
  8013c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c5:	c9                   	leave  
  8013c6:	c3                   	ret    

008013c7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013c7:	55                   	push   %ebp
  8013c8:	89 e5                	mov    %esp,%ebp
  8013ca:	57                   	push   %edi
  8013cb:	56                   	push   %esi
  8013cc:	53                   	push   %ebx
  8013cd:	83 ec 2c             	sub    $0x2c,%esp
  8013d0:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013d3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013d6:	50                   	push   %eax
  8013d7:	ff 75 08             	pushl  0x8(%ebp)
  8013da:	e8 6b fe ff ff       	call   80124a <fd_lookup>
  8013df:	83 c4 08             	add    $0x8,%esp
  8013e2:	85 c0                	test   %eax,%eax
  8013e4:	0f 88 c1 00 00 00    	js     8014ab <dup+0xe4>
		return r;
	close(newfdnum);
  8013ea:	83 ec 0c             	sub    $0xc,%esp
  8013ed:	56                   	push   %esi
  8013ee:	e8 84 ff ff ff       	call   801377 <close>

	newfd = INDEX2FD(newfdnum);
  8013f3:	89 f3                	mov    %esi,%ebx
  8013f5:	c1 e3 0c             	shl    $0xc,%ebx
  8013f8:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013fe:	83 c4 04             	add    $0x4,%esp
  801401:	ff 75 e4             	pushl  -0x1c(%ebp)
  801404:	e8 db fd ff ff       	call   8011e4 <fd2data>
  801409:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80140b:	89 1c 24             	mov    %ebx,(%esp)
  80140e:	e8 d1 fd ff ff       	call   8011e4 <fd2data>
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801419:	89 f8                	mov    %edi,%eax
  80141b:	c1 e8 16             	shr    $0x16,%eax
  80141e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801425:	a8 01                	test   $0x1,%al
  801427:	74 37                	je     801460 <dup+0x99>
  801429:	89 f8                	mov    %edi,%eax
  80142b:	c1 e8 0c             	shr    $0xc,%eax
  80142e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801435:	f6 c2 01             	test   $0x1,%dl
  801438:	74 26                	je     801460 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80143a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801441:	83 ec 0c             	sub    $0xc,%esp
  801444:	25 07 0e 00 00       	and    $0xe07,%eax
  801449:	50                   	push   %eax
  80144a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80144d:	6a 00                	push   $0x0
  80144f:	57                   	push   %edi
  801450:	6a 00                	push   $0x0
  801452:	e8 55 f8 ff ff       	call   800cac <sys_page_map>
  801457:	89 c7                	mov    %eax,%edi
  801459:	83 c4 20             	add    $0x20,%esp
  80145c:	85 c0                	test   %eax,%eax
  80145e:	78 2e                	js     80148e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801460:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801463:	89 d0                	mov    %edx,%eax
  801465:	c1 e8 0c             	shr    $0xc,%eax
  801468:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80146f:	83 ec 0c             	sub    $0xc,%esp
  801472:	25 07 0e 00 00       	and    $0xe07,%eax
  801477:	50                   	push   %eax
  801478:	53                   	push   %ebx
  801479:	6a 00                	push   $0x0
  80147b:	52                   	push   %edx
  80147c:	6a 00                	push   $0x0
  80147e:	e8 29 f8 ff ff       	call   800cac <sys_page_map>
  801483:	89 c7                	mov    %eax,%edi
  801485:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801488:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80148a:	85 ff                	test   %edi,%edi
  80148c:	79 1d                	jns    8014ab <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80148e:	83 ec 08             	sub    $0x8,%esp
  801491:	53                   	push   %ebx
  801492:	6a 00                	push   $0x0
  801494:	e8 55 f8 ff ff       	call   800cee <sys_page_unmap>
	sys_page_unmap(0, nva);
  801499:	83 c4 08             	add    $0x8,%esp
  80149c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80149f:	6a 00                	push   $0x0
  8014a1:	e8 48 f8 ff ff       	call   800cee <sys_page_unmap>
	return r;
  8014a6:	83 c4 10             	add    $0x10,%esp
  8014a9:	89 f8                	mov    %edi,%eax
}
  8014ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ae:	5b                   	pop    %ebx
  8014af:	5e                   	pop    %esi
  8014b0:	5f                   	pop    %edi
  8014b1:	5d                   	pop    %ebp
  8014b2:	c3                   	ret    

008014b3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014b3:	55                   	push   %ebp
  8014b4:	89 e5                	mov    %esp,%ebp
  8014b6:	53                   	push   %ebx
  8014b7:	83 ec 14             	sub    $0x14,%esp
  8014ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c0:	50                   	push   %eax
  8014c1:	53                   	push   %ebx
  8014c2:	e8 83 fd ff ff       	call   80124a <fd_lookup>
  8014c7:	83 c4 08             	add    $0x8,%esp
  8014ca:	89 c2                	mov    %eax,%edx
  8014cc:	85 c0                	test   %eax,%eax
  8014ce:	78 70                	js     801540 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d0:	83 ec 08             	sub    $0x8,%esp
  8014d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d6:	50                   	push   %eax
  8014d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014da:	ff 30                	pushl  (%eax)
  8014dc:	e8 bf fd ff ff       	call   8012a0 <dev_lookup>
  8014e1:	83 c4 10             	add    $0x10,%esp
  8014e4:	85 c0                	test   %eax,%eax
  8014e6:	78 4f                	js     801537 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014eb:	8b 42 08             	mov    0x8(%edx),%eax
  8014ee:	83 e0 03             	and    $0x3,%eax
  8014f1:	83 f8 01             	cmp    $0x1,%eax
  8014f4:	75 24                	jne    80151a <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f6:	a1 08 40 80 00       	mov    0x804008,%eax
  8014fb:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801501:	83 ec 04             	sub    $0x4,%esp
  801504:	53                   	push   %ebx
  801505:	50                   	push   %eax
  801506:	68 cc 28 80 00       	push   $0x8028cc
  80150b:	e8 d1 ed ff ff       	call   8002e1 <cprintf>
		return -E_INVAL;
  801510:	83 c4 10             	add    $0x10,%esp
  801513:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801518:	eb 26                	jmp    801540 <read+0x8d>
	}
	if (!dev->dev_read)
  80151a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80151d:	8b 40 08             	mov    0x8(%eax),%eax
  801520:	85 c0                	test   %eax,%eax
  801522:	74 17                	je     80153b <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801524:	83 ec 04             	sub    $0x4,%esp
  801527:	ff 75 10             	pushl  0x10(%ebp)
  80152a:	ff 75 0c             	pushl  0xc(%ebp)
  80152d:	52                   	push   %edx
  80152e:	ff d0                	call   *%eax
  801530:	89 c2                	mov    %eax,%edx
  801532:	83 c4 10             	add    $0x10,%esp
  801535:	eb 09                	jmp    801540 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801537:	89 c2                	mov    %eax,%edx
  801539:	eb 05                	jmp    801540 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80153b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801540:	89 d0                	mov    %edx,%eax
  801542:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801545:	c9                   	leave  
  801546:	c3                   	ret    

00801547 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801547:	55                   	push   %ebp
  801548:	89 e5                	mov    %esp,%ebp
  80154a:	57                   	push   %edi
  80154b:	56                   	push   %esi
  80154c:	53                   	push   %ebx
  80154d:	83 ec 0c             	sub    $0xc,%esp
  801550:	8b 7d 08             	mov    0x8(%ebp),%edi
  801553:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801556:	bb 00 00 00 00       	mov    $0x0,%ebx
  80155b:	eb 21                	jmp    80157e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80155d:	83 ec 04             	sub    $0x4,%esp
  801560:	89 f0                	mov    %esi,%eax
  801562:	29 d8                	sub    %ebx,%eax
  801564:	50                   	push   %eax
  801565:	89 d8                	mov    %ebx,%eax
  801567:	03 45 0c             	add    0xc(%ebp),%eax
  80156a:	50                   	push   %eax
  80156b:	57                   	push   %edi
  80156c:	e8 42 ff ff ff       	call   8014b3 <read>
		if (m < 0)
  801571:	83 c4 10             	add    $0x10,%esp
  801574:	85 c0                	test   %eax,%eax
  801576:	78 10                	js     801588 <readn+0x41>
			return m;
		if (m == 0)
  801578:	85 c0                	test   %eax,%eax
  80157a:	74 0a                	je     801586 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80157c:	01 c3                	add    %eax,%ebx
  80157e:	39 f3                	cmp    %esi,%ebx
  801580:	72 db                	jb     80155d <readn+0x16>
  801582:	89 d8                	mov    %ebx,%eax
  801584:	eb 02                	jmp    801588 <readn+0x41>
  801586:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801588:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80158b:	5b                   	pop    %ebx
  80158c:	5e                   	pop    %esi
  80158d:	5f                   	pop    %edi
  80158e:	5d                   	pop    %ebp
  80158f:	c3                   	ret    

00801590 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	53                   	push   %ebx
  801594:	83 ec 14             	sub    $0x14,%esp
  801597:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80159a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80159d:	50                   	push   %eax
  80159e:	53                   	push   %ebx
  80159f:	e8 a6 fc ff ff       	call   80124a <fd_lookup>
  8015a4:	83 c4 08             	add    $0x8,%esp
  8015a7:	89 c2                	mov    %eax,%edx
  8015a9:	85 c0                	test   %eax,%eax
  8015ab:	78 6b                	js     801618 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ad:	83 ec 08             	sub    $0x8,%esp
  8015b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b3:	50                   	push   %eax
  8015b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b7:	ff 30                	pushl  (%eax)
  8015b9:	e8 e2 fc ff ff       	call   8012a0 <dev_lookup>
  8015be:	83 c4 10             	add    $0x10,%esp
  8015c1:	85 c0                	test   %eax,%eax
  8015c3:	78 4a                	js     80160f <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015cc:	75 24                	jne    8015f2 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015ce:	a1 08 40 80 00       	mov    0x804008,%eax
  8015d3:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8015d9:	83 ec 04             	sub    $0x4,%esp
  8015dc:	53                   	push   %ebx
  8015dd:	50                   	push   %eax
  8015de:	68 e8 28 80 00       	push   $0x8028e8
  8015e3:	e8 f9 ec ff ff       	call   8002e1 <cprintf>
		return -E_INVAL;
  8015e8:	83 c4 10             	add    $0x10,%esp
  8015eb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015f0:	eb 26                	jmp    801618 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f5:	8b 52 0c             	mov    0xc(%edx),%edx
  8015f8:	85 d2                	test   %edx,%edx
  8015fa:	74 17                	je     801613 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015fc:	83 ec 04             	sub    $0x4,%esp
  8015ff:	ff 75 10             	pushl  0x10(%ebp)
  801602:	ff 75 0c             	pushl  0xc(%ebp)
  801605:	50                   	push   %eax
  801606:	ff d2                	call   *%edx
  801608:	89 c2                	mov    %eax,%edx
  80160a:	83 c4 10             	add    $0x10,%esp
  80160d:	eb 09                	jmp    801618 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160f:	89 c2                	mov    %eax,%edx
  801611:	eb 05                	jmp    801618 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801613:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801618:	89 d0                	mov    %edx,%eax
  80161a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161d:	c9                   	leave  
  80161e:	c3                   	ret    

0080161f <seek>:

int
seek(int fdnum, off_t offset)
{
  80161f:	55                   	push   %ebp
  801620:	89 e5                	mov    %esp,%ebp
  801622:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801625:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801628:	50                   	push   %eax
  801629:	ff 75 08             	pushl  0x8(%ebp)
  80162c:	e8 19 fc ff ff       	call   80124a <fd_lookup>
  801631:	83 c4 08             	add    $0x8,%esp
  801634:	85 c0                	test   %eax,%eax
  801636:	78 0e                	js     801646 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801638:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80163b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80163e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801641:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801646:	c9                   	leave  
  801647:	c3                   	ret    

00801648 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	53                   	push   %ebx
  80164c:	83 ec 14             	sub    $0x14,%esp
  80164f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801652:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801655:	50                   	push   %eax
  801656:	53                   	push   %ebx
  801657:	e8 ee fb ff ff       	call   80124a <fd_lookup>
  80165c:	83 c4 08             	add    $0x8,%esp
  80165f:	89 c2                	mov    %eax,%edx
  801661:	85 c0                	test   %eax,%eax
  801663:	78 68                	js     8016cd <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801665:	83 ec 08             	sub    $0x8,%esp
  801668:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166b:	50                   	push   %eax
  80166c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166f:	ff 30                	pushl  (%eax)
  801671:	e8 2a fc ff ff       	call   8012a0 <dev_lookup>
  801676:	83 c4 10             	add    $0x10,%esp
  801679:	85 c0                	test   %eax,%eax
  80167b:	78 47                	js     8016c4 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80167d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801680:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801684:	75 24                	jne    8016aa <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801686:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80168b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801691:	83 ec 04             	sub    $0x4,%esp
  801694:	53                   	push   %ebx
  801695:	50                   	push   %eax
  801696:	68 a8 28 80 00       	push   $0x8028a8
  80169b:	e8 41 ec ff ff       	call   8002e1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016a0:	83 c4 10             	add    $0x10,%esp
  8016a3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016a8:	eb 23                	jmp    8016cd <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  8016aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ad:	8b 52 18             	mov    0x18(%edx),%edx
  8016b0:	85 d2                	test   %edx,%edx
  8016b2:	74 14                	je     8016c8 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016b4:	83 ec 08             	sub    $0x8,%esp
  8016b7:	ff 75 0c             	pushl  0xc(%ebp)
  8016ba:	50                   	push   %eax
  8016bb:	ff d2                	call   *%edx
  8016bd:	89 c2                	mov    %eax,%edx
  8016bf:	83 c4 10             	add    $0x10,%esp
  8016c2:	eb 09                	jmp    8016cd <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c4:	89 c2                	mov    %eax,%edx
  8016c6:	eb 05                	jmp    8016cd <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016c8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016cd:	89 d0                	mov    %edx,%eax
  8016cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d2:	c9                   	leave  
  8016d3:	c3                   	ret    

008016d4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016d4:	55                   	push   %ebp
  8016d5:	89 e5                	mov    %esp,%ebp
  8016d7:	53                   	push   %ebx
  8016d8:	83 ec 14             	sub    $0x14,%esp
  8016db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e1:	50                   	push   %eax
  8016e2:	ff 75 08             	pushl  0x8(%ebp)
  8016e5:	e8 60 fb ff ff       	call   80124a <fd_lookup>
  8016ea:	83 c4 08             	add    $0x8,%esp
  8016ed:	89 c2                	mov    %eax,%edx
  8016ef:	85 c0                	test   %eax,%eax
  8016f1:	78 58                	js     80174b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f3:	83 ec 08             	sub    $0x8,%esp
  8016f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f9:	50                   	push   %eax
  8016fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016fd:	ff 30                	pushl  (%eax)
  8016ff:	e8 9c fb ff ff       	call   8012a0 <dev_lookup>
  801704:	83 c4 10             	add    $0x10,%esp
  801707:	85 c0                	test   %eax,%eax
  801709:	78 37                	js     801742 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80170b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80170e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801712:	74 32                	je     801746 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801714:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801717:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80171e:	00 00 00 
	stat->st_isdir = 0;
  801721:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801728:	00 00 00 
	stat->st_dev = dev;
  80172b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801731:	83 ec 08             	sub    $0x8,%esp
  801734:	53                   	push   %ebx
  801735:	ff 75 f0             	pushl  -0x10(%ebp)
  801738:	ff 50 14             	call   *0x14(%eax)
  80173b:	89 c2                	mov    %eax,%edx
  80173d:	83 c4 10             	add    $0x10,%esp
  801740:	eb 09                	jmp    80174b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801742:	89 c2                	mov    %eax,%edx
  801744:	eb 05                	jmp    80174b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801746:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80174b:	89 d0                	mov    %edx,%eax
  80174d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801750:	c9                   	leave  
  801751:	c3                   	ret    

00801752 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801752:	55                   	push   %ebp
  801753:	89 e5                	mov    %esp,%ebp
  801755:	56                   	push   %esi
  801756:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801757:	83 ec 08             	sub    $0x8,%esp
  80175a:	6a 00                	push   $0x0
  80175c:	ff 75 08             	pushl  0x8(%ebp)
  80175f:	e8 e3 01 00 00       	call   801947 <open>
  801764:	89 c3                	mov    %eax,%ebx
  801766:	83 c4 10             	add    $0x10,%esp
  801769:	85 c0                	test   %eax,%eax
  80176b:	78 1b                	js     801788 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80176d:	83 ec 08             	sub    $0x8,%esp
  801770:	ff 75 0c             	pushl  0xc(%ebp)
  801773:	50                   	push   %eax
  801774:	e8 5b ff ff ff       	call   8016d4 <fstat>
  801779:	89 c6                	mov    %eax,%esi
	close(fd);
  80177b:	89 1c 24             	mov    %ebx,(%esp)
  80177e:	e8 f4 fb ff ff       	call   801377 <close>
	return r;
  801783:	83 c4 10             	add    $0x10,%esp
  801786:	89 f0                	mov    %esi,%eax
}
  801788:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80178b:	5b                   	pop    %ebx
  80178c:	5e                   	pop    %esi
  80178d:	5d                   	pop    %ebp
  80178e:	c3                   	ret    

0080178f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80178f:	55                   	push   %ebp
  801790:	89 e5                	mov    %esp,%ebp
  801792:	56                   	push   %esi
  801793:	53                   	push   %ebx
  801794:	89 c6                	mov    %eax,%esi
  801796:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801798:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80179f:	75 12                	jne    8017b3 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017a1:	83 ec 0c             	sub    $0xc,%esp
  8017a4:	6a 01                	push   $0x1
  8017a6:	e8 a4 09 00 00       	call   80214f <ipc_find_env>
  8017ab:	a3 04 40 80 00       	mov    %eax,0x804004
  8017b0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017b3:	6a 07                	push   $0x7
  8017b5:	68 00 50 80 00       	push   $0x805000
  8017ba:	56                   	push   %esi
  8017bb:	ff 35 04 40 80 00    	pushl  0x804004
  8017c1:	e8 27 09 00 00       	call   8020ed <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017c6:	83 c4 0c             	add    $0xc,%esp
  8017c9:	6a 00                	push   $0x0
  8017cb:	53                   	push   %ebx
  8017cc:	6a 00                	push   $0x0
  8017ce:	e8 9f 08 00 00       	call   802072 <ipc_recv>
}
  8017d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d6:	5b                   	pop    %ebx
  8017d7:	5e                   	pop    %esi
  8017d8:	5d                   	pop    %ebp
  8017d9:	c3                   	ret    

008017da <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017da:	55                   	push   %ebp
  8017db:	89 e5                	mov    %esp,%ebp
  8017dd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ee:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f8:	b8 02 00 00 00       	mov    $0x2,%eax
  8017fd:	e8 8d ff ff ff       	call   80178f <fsipc>
}
  801802:	c9                   	leave  
  801803:	c3                   	ret    

00801804 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80180a:	8b 45 08             	mov    0x8(%ebp),%eax
  80180d:	8b 40 0c             	mov    0xc(%eax),%eax
  801810:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801815:	ba 00 00 00 00       	mov    $0x0,%edx
  80181a:	b8 06 00 00 00       	mov    $0x6,%eax
  80181f:	e8 6b ff ff ff       	call   80178f <fsipc>
}
  801824:	c9                   	leave  
  801825:	c3                   	ret    

00801826 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801826:	55                   	push   %ebp
  801827:	89 e5                	mov    %esp,%ebp
  801829:	53                   	push   %ebx
  80182a:	83 ec 04             	sub    $0x4,%esp
  80182d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801830:	8b 45 08             	mov    0x8(%ebp),%eax
  801833:	8b 40 0c             	mov    0xc(%eax),%eax
  801836:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80183b:	ba 00 00 00 00       	mov    $0x0,%edx
  801840:	b8 05 00 00 00       	mov    $0x5,%eax
  801845:	e8 45 ff ff ff       	call   80178f <fsipc>
  80184a:	85 c0                	test   %eax,%eax
  80184c:	78 2c                	js     80187a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80184e:	83 ec 08             	sub    $0x8,%esp
  801851:	68 00 50 80 00       	push   $0x805000
  801856:	53                   	push   %ebx
  801857:	e8 0a f0 ff ff       	call   800866 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80185c:	a1 80 50 80 00       	mov    0x805080,%eax
  801861:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801867:	a1 84 50 80 00       	mov    0x805084,%eax
  80186c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801872:	83 c4 10             	add    $0x10,%esp
  801875:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80187a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187d:	c9                   	leave  
  80187e:	c3                   	ret    

0080187f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80187f:	55                   	push   %ebp
  801880:	89 e5                	mov    %esp,%ebp
  801882:	83 ec 0c             	sub    $0xc,%esp
  801885:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801888:	8b 55 08             	mov    0x8(%ebp),%edx
  80188b:	8b 52 0c             	mov    0xc(%edx),%edx
  80188e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801894:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801899:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80189e:	0f 47 c2             	cmova  %edx,%eax
  8018a1:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8018a6:	50                   	push   %eax
  8018a7:	ff 75 0c             	pushl  0xc(%ebp)
  8018aa:	68 08 50 80 00       	push   $0x805008
  8018af:	e8 44 f1 ff ff       	call   8009f8 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8018b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b9:	b8 04 00 00 00       	mov    $0x4,%eax
  8018be:	e8 cc fe ff ff       	call   80178f <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8018c3:	c9                   	leave  
  8018c4:	c3                   	ret    

008018c5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018c5:	55                   	push   %ebp
  8018c6:	89 e5                	mov    %esp,%ebp
  8018c8:	56                   	push   %esi
  8018c9:	53                   	push   %ebx
  8018ca:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d0:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018d8:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018de:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e3:	b8 03 00 00 00       	mov    $0x3,%eax
  8018e8:	e8 a2 fe ff ff       	call   80178f <fsipc>
  8018ed:	89 c3                	mov    %eax,%ebx
  8018ef:	85 c0                	test   %eax,%eax
  8018f1:	78 4b                	js     80193e <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018f3:	39 c6                	cmp    %eax,%esi
  8018f5:	73 16                	jae    80190d <devfile_read+0x48>
  8018f7:	68 18 29 80 00       	push   $0x802918
  8018fc:	68 1f 29 80 00       	push   $0x80291f
  801901:	6a 7c                	push   $0x7c
  801903:	68 34 29 80 00       	push   $0x802934
  801908:	e8 fb e8 ff ff       	call   800208 <_panic>
	assert(r <= PGSIZE);
  80190d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801912:	7e 16                	jle    80192a <devfile_read+0x65>
  801914:	68 3f 29 80 00       	push   $0x80293f
  801919:	68 1f 29 80 00       	push   $0x80291f
  80191e:	6a 7d                	push   $0x7d
  801920:	68 34 29 80 00       	push   $0x802934
  801925:	e8 de e8 ff ff       	call   800208 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80192a:	83 ec 04             	sub    $0x4,%esp
  80192d:	50                   	push   %eax
  80192e:	68 00 50 80 00       	push   $0x805000
  801933:	ff 75 0c             	pushl  0xc(%ebp)
  801936:	e8 bd f0 ff ff       	call   8009f8 <memmove>
	return r;
  80193b:	83 c4 10             	add    $0x10,%esp
}
  80193e:	89 d8                	mov    %ebx,%eax
  801940:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801943:	5b                   	pop    %ebx
  801944:	5e                   	pop    %esi
  801945:	5d                   	pop    %ebp
  801946:	c3                   	ret    

00801947 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801947:	55                   	push   %ebp
  801948:	89 e5                	mov    %esp,%ebp
  80194a:	53                   	push   %ebx
  80194b:	83 ec 20             	sub    $0x20,%esp
  80194e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801951:	53                   	push   %ebx
  801952:	e8 d6 ee ff ff       	call   80082d <strlen>
  801957:	83 c4 10             	add    $0x10,%esp
  80195a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80195f:	7f 67                	jg     8019c8 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801961:	83 ec 0c             	sub    $0xc,%esp
  801964:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801967:	50                   	push   %eax
  801968:	e8 8e f8 ff ff       	call   8011fb <fd_alloc>
  80196d:	83 c4 10             	add    $0x10,%esp
		return r;
  801970:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801972:	85 c0                	test   %eax,%eax
  801974:	78 57                	js     8019cd <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801976:	83 ec 08             	sub    $0x8,%esp
  801979:	53                   	push   %ebx
  80197a:	68 00 50 80 00       	push   $0x805000
  80197f:	e8 e2 ee ff ff       	call   800866 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801984:	8b 45 0c             	mov    0xc(%ebp),%eax
  801987:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80198c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80198f:	b8 01 00 00 00       	mov    $0x1,%eax
  801994:	e8 f6 fd ff ff       	call   80178f <fsipc>
  801999:	89 c3                	mov    %eax,%ebx
  80199b:	83 c4 10             	add    $0x10,%esp
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	79 14                	jns    8019b6 <open+0x6f>
		fd_close(fd, 0);
  8019a2:	83 ec 08             	sub    $0x8,%esp
  8019a5:	6a 00                	push   $0x0
  8019a7:	ff 75 f4             	pushl  -0xc(%ebp)
  8019aa:	e8 47 f9 ff ff       	call   8012f6 <fd_close>
		return r;
  8019af:	83 c4 10             	add    $0x10,%esp
  8019b2:	89 da                	mov    %ebx,%edx
  8019b4:	eb 17                	jmp    8019cd <open+0x86>
	}

	return fd2num(fd);
  8019b6:	83 ec 0c             	sub    $0xc,%esp
  8019b9:	ff 75 f4             	pushl  -0xc(%ebp)
  8019bc:	e8 13 f8 ff ff       	call   8011d4 <fd2num>
  8019c1:	89 c2                	mov    %eax,%edx
  8019c3:	83 c4 10             	add    $0x10,%esp
  8019c6:	eb 05                	jmp    8019cd <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019c8:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019cd:	89 d0                	mov    %edx,%eax
  8019cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d2:	c9                   	leave  
  8019d3:	c3                   	ret    

008019d4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019d4:	55                   	push   %ebp
  8019d5:	89 e5                	mov    %esp,%ebp
  8019d7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019da:	ba 00 00 00 00       	mov    $0x0,%edx
  8019df:	b8 08 00 00 00       	mov    $0x8,%eax
  8019e4:	e8 a6 fd ff ff       	call   80178f <fsipc>
}
  8019e9:	c9                   	leave  
  8019ea:	c3                   	ret    

008019eb <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8019eb:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8019ef:	7e 37                	jle    801a28 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8019f1:	55                   	push   %ebp
  8019f2:	89 e5                	mov    %esp,%ebp
  8019f4:	53                   	push   %ebx
  8019f5:	83 ec 08             	sub    $0x8,%esp
  8019f8:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8019fa:	ff 70 04             	pushl  0x4(%eax)
  8019fd:	8d 40 10             	lea    0x10(%eax),%eax
  801a00:	50                   	push   %eax
  801a01:	ff 33                	pushl  (%ebx)
  801a03:	e8 88 fb ff ff       	call   801590 <write>
		if (result > 0)
  801a08:	83 c4 10             	add    $0x10,%esp
  801a0b:	85 c0                	test   %eax,%eax
  801a0d:	7e 03                	jle    801a12 <writebuf+0x27>
			b->result += result;
  801a0f:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801a12:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a15:	74 0d                	je     801a24 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801a17:	85 c0                	test   %eax,%eax
  801a19:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1e:	0f 4f c2             	cmovg  %edx,%eax
  801a21:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801a24:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a27:	c9                   	leave  
  801a28:	f3 c3                	repz ret 

00801a2a <putch>:

static void
putch(int ch, void *thunk)
{
  801a2a:	55                   	push   %ebp
  801a2b:	89 e5                	mov    %esp,%ebp
  801a2d:	53                   	push   %ebx
  801a2e:	83 ec 04             	sub    $0x4,%esp
  801a31:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801a34:	8b 53 04             	mov    0x4(%ebx),%edx
  801a37:	8d 42 01             	lea    0x1(%edx),%eax
  801a3a:	89 43 04             	mov    %eax,0x4(%ebx)
  801a3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a40:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801a44:	3d 00 01 00 00       	cmp    $0x100,%eax
  801a49:	75 0e                	jne    801a59 <putch+0x2f>
		writebuf(b);
  801a4b:	89 d8                	mov    %ebx,%eax
  801a4d:	e8 99 ff ff ff       	call   8019eb <writebuf>
		b->idx = 0;
  801a52:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801a59:	83 c4 04             	add    $0x4,%esp
  801a5c:	5b                   	pop    %ebx
  801a5d:	5d                   	pop    %ebp
  801a5e:	c3                   	ret    

00801a5f <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801a68:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6b:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801a71:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801a78:	00 00 00 
	b.result = 0;
  801a7b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801a82:	00 00 00 
	b.error = 1;
  801a85:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801a8c:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801a8f:	ff 75 10             	pushl  0x10(%ebp)
  801a92:	ff 75 0c             	pushl  0xc(%ebp)
  801a95:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a9b:	50                   	push   %eax
  801a9c:	68 2a 1a 80 00       	push   $0x801a2a
  801aa1:	e8 72 e9 ff ff       	call   800418 <vprintfmt>
	if (b.idx > 0)
  801aa6:	83 c4 10             	add    $0x10,%esp
  801aa9:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801ab0:	7e 0b                	jle    801abd <vfprintf+0x5e>
		writebuf(&b);
  801ab2:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801ab8:	e8 2e ff ff ff       	call   8019eb <writebuf>

	return (b.result ? b.result : b.error);
  801abd:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801ac3:	85 c0                	test   %eax,%eax
  801ac5:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801acc:	c9                   	leave  
  801acd:	c3                   	ret    

00801ace <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801ace:	55                   	push   %ebp
  801acf:	89 e5                	mov    %esp,%ebp
  801ad1:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801ad4:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801ad7:	50                   	push   %eax
  801ad8:	ff 75 0c             	pushl  0xc(%ebp)
  801adb:	ff 75 08             	pushl  0x8(%ebp)
  801ade:	e8 7c ff ff ff       	call   801a5f <vfprintf>
	va_end(ap);

	return cnt;
}
  801ae3:	c9                   	leave  
  801ae4:	c3                   	ret    

00801ae5 <printf>:

int
printf(const char *fmt, ...)
{
  801ae5:	55                   	push   %ebp
  801ae6:	89 e5                	mov    %esp,%ebp
  801ae8:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801aeb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801aee:	50                   	push   %eax
  801aef:	ff 75 08             	pushl  0x8(%ebp)
  801af2:	6a 01                	push   $0x1
  801af4:	e8 66 ff ff ff       	call   801a5f <vfprintf>
	va_end(ap);

	return cnt;
}
  801af9:	c9                   	leave  
  801afa:	c3                   	ret    

00801afb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801afb:	55                   	push   %ebp
  801afc:	89 e5                	mov    %esp,%ebp
  801afe:	56                   	push   %esi
  801aff:	53                   	push   %ebx
  801b00:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b03:	83 ec 0c             	sub    $0xc,%esp
  801b06:	ff 75 08             	pushl  0x8(%ebp)
  801b09:	e8 d6 f6 ff ff       	call   8011e4 <fd2data>
  801b0e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b10:	83 c4 08             	add    $0x8,%esp
  801b13:	68 4b 29 80 00       	push   $0x80294b
  801b18:	53                   	push   %ebx
  801b19:	e8 48 ed ff ff       	call   800866 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b1e:	8b 46 04             	mov    0x4(%esi),%eax
  801b21:	2b 06                	sub    (%esi),%eax
  801b23:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b29:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b30:	00 00 00 
	stat->st_dev = &devpipe;
  801b33:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801b3a:	30 80 00 
	return 0;
}
  801b3d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b42:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b45:	5b                   	pop    %ebx
  801b46:	5e                   	pop    %esi
  801b47:	5d                   	pop    %ebp
  801b48:	c3                   	ret    

00801b49 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b49:	55                   	push   %ebp
  801b4a:	89 e5                	mov    %esp,%ebp
  801b4c:	53                   	push   %ebx
  801b4d:	83 ec 0c             	sub    $0xc,%esp
  801b50:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b53:	53                   	push   %ebx
  801b54:	6a 00                	push   $0x0
  801b56:	e8 93 f1 ff ff       	call   800cee <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b5b:	89 1c 24             	mov    %ebx,(%esp)
  801b5e:	e8 81 f6 ff ff       	call   8011e4 <fd2data>
  801b63:	83 c4 08             	add    $0x8,%esp
  801b66:	50                   	push   %eax
  801b67:	6a 00                	push   $0x0
  801b69:	e8 80 f1 ff ff       	call   800cee <sys_page_unmap>
}
  801b6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b71:	c9                   	leave  
  801b72:	c3                   	ret    

00801b73 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b73:	55                   	push   %ebp
  801b74:	89 e5                	mov    %esp,%ebp
  801b76:	57                   	push   %edi
  801b77:	56                   	push   %esi
  801b78:	53                   	push   %ebx
  801b79:	83 ec 1c             	sub    $0x1c,%esp
  801b7c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b7f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b81:	a1 08 40 80 00       	mov    0x804008,%eax
  801b86:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b8c:	83 ec 0c             	sub    $0xc,%esp
  801b8f:	ff 75 e0             	pushl  -0x20(%ebp)
  801b92:	e8 fd 05 00 00       	call   802194 <pageref>
  801b97:	89 c3                	mov    %eax,%ebx
  801b99:	89 3c 24             	mov    %edi,(%esp)
  801b9c:	e8 f3 05 00 00       	call   802194 <pageref>
  801ba1:	83 c4 10             	add    $0x10,%esp
  801ba4:	39 c3                	cmp    %eax,%ebx
  801ba6:	0f 94 c1             	sete   %cl
  801ba9:	0f b6 c9             	movzbl %cl,%ecx
  801bac:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801baf:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801bb5:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801bbb:	39 ce                	cmp    %ecx,%esi
  801bbd:	74 1e                	je     801bdd <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801bbf:	39 c3                	cmp    %eax,%ebx
  801bc1:	75 be                	jne    801b81 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bc3:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801bc9:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bcc:	50                   	push   %eax
  801bcd:	56                   	push   %esi
  801bce:	68 52 29 80 00       	push   $0x802952
  801bd3:	e8 09 e7 ff ff       	call   8002e1 <cprintf>
  801bd8:	83 c4 10             	add    $0x10,%esp
  801bdb:	eb a4                	jmp    801b81 <_pipeisclosed+0xe>
	}
}
  801bdd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801be0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801be3:	5b                   	pop    %ebx
  801be4:	5e                   	pop    %esi
  801be5:	5f                   	pop    %edi
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    

00801be8 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
  801beb:	57                   	push   %edi
  801bec:	56                   	push   %esi
  801bed:	53                   	push   %ebx
  801bee:	83 ec 28             	sub    $0x28,%esp
  801bf1:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bf4:	56                   	push   %esi
  801bf5:	e8 ea f5 ff ff       	call   8011e4 <fd2data>
  801bfa:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bfc:	83 c4 10             	add    $0x10,%esp
  801bff:	bf 00 00 00 00       	mov    $0x0,%edi
  801c04:	eb 4b                	jmp    801c51 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c06:	89 da                	mov    %ebx,%edx
  801c08:	89 f0                	mov    %esi,%eax
  801c0a:	e8 64 ff ff ff       	call   801b73 <_pipeisclosed>
  801c0f:	85 c0                	test   %eax,%eax
  801c11:	75 48                	jne    801c5b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c13:	e8 32 f0 ff ff       	call   800c4a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c18:	8b 43 04             	mov    0x4(%ebx),%eax
  801c1b:	8b 0b                	mov    (%ebx),%ecx
  801c1d:	8d 51 20             	lea    0x20(%ecx),%edx
  801c20:	39 d0                	cmp    %edx,%eax
  801c22:	73 e2                	jae    801c06 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c27:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c2b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c2e:	89 c2                	mov    %eax,%edx
  801c30:	c1 fa 1f             	sar    $0x1f,%edx
  801c33:	89 d1                	mov    %edx,%ecx
  801c35:	c1 e9 1b             	shr    $0x1b,%ecx
  801c38:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c3b:	83 e2 1f             	and    $0x1f,%edx
  801c3e:	29 ca                	sub    %ecx,%edx
  801c40:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c44:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c48:	83 c0 01             	add    $0x1,%eax
  801c4b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c4e:	83 c7 01             	add    $0x1,%edi
  801c51:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c54:	75 c2                	jne    801c18 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c56:	8b 45 10             	mov    0x10(%ebp),%eax
  801c59:	eb 05                	jmp    801c60 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c5b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c63:	5b                   	pop    %ebx
  801c64:	5e                   	pop    %esi
  801c65:	5f                   	pop    %edi
  801c66:	5d                   	pop    %ebp
  801c67:	c3                   	ret    

00801c68 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
  801c6b:	57                   	push   %edi
  801c6c:	56                   	push   %esi
  801c6d:	53                   	push   %ebx
  801c6e:	83 ec 18             	sub    $0x18,%esp
  801c71:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c74:	57                   	push   %edi
  801c75:	e8 6a f5 ff ff       	call   8011e4 <fd2data>
  801c7a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c7c:	83 c4 10             	add    $0x10,%esp
  801c7f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c84:	eb 3d                	jmp    801cc3 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c86:	85 db                	test   %ebx,%ebx
  801c88:	74 04                	je     801c8e <devpipe_read+0x26>
				return i;
  801c8a:	89 d8                	mov    %ebx,%eax
  801c8c:	eb 44                	jmp    801cd2 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c8e:	89 f2                	mov    %esi,%edx
  801c90:	89 f8                	mov    %edi,%eax
  801c92:	e8 dc fe ff ff       	call   801b73 <_pipeisclosed>
  801c97:	85 c0                	test   %eax,%eax
  801c99:	75 32                	jne    801ccd <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c9b:	e8 aa ef ff ff       	call   800c4a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ca0:	8b 06                	mov    (%esi),%eax
  801ca2:	3b 46 04             	cmp    0x4(%esi),%eax
  801ca5:	74 df                	je     801c86 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ca7:	99                   	cltd   
  801ca8:	c1 ea 1b             	shr    $0x1b,%edx
  801cab:	01 d0                	add    %edx,%eax
  801cad:	83 e0 1f             	and    $0x1f,%eax
  801cb0:	29 d0                	sub    %edx,%eax
  801cb2:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801cb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cba:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801cbd:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cc0:	83 c3 01             	add    $0x1,%ebx
  801cc3:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cc6:	75 d8                	jne    801ca0 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cc8:	8b 45 10             	mov    0x10(%ebp),%eax
  801ccb:	eb 05                	jmp    801cd2 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ccd:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cd5:	5b                   	pop    %ebx
  801cd6:	5e                   	pop    %esi
  801cd7:	5f                   	pop    %edi
  801cd8:	5d                   	pop    %ebp
  801cd9:	c3                   	ret    

00801cda <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cda:	55                   	push   %ebp
  801cdb:	89 e5                	mov    %esp,%ebp
  801cdd:	56                   	push   %esi
  801cde:	53                   	push   %ebx
  801cdf:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ce2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce5:	50                   	push   %eax
  801ce6:	e8 10 f5 ff ff       	call   8011fb <fd_alloc>
  801ceb:	83 c4 10             	add    $0x10,%esp
  801cee:	89 c2                	mov    %eax,%edx
  801cf0:	85 c0                	test   %eax,%eax
  801cf2:	0f 88 2c 01 00 00    	js     801e24 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf8:	83 ec 04             	sub    $0x4,%esp
  801cfb:	68 07 04 00 00       	push   $0x407
  801d00:	ff 75 f4             	pushl  -0xc(%ebp)
  801d03:	6a 00                	push   $0x0
  801d05:	e8 5f ef ff ff       	call   800c69 <sys_page_alloc>
  801d0a:	83 c4 10             	add    $0x10,%esp
  801d0d:	89 c2                	mov    %eax,%edx
  801d0f:	85 c0                	test   %eax,%eax
  801d11:	0f 88 0d 01 00 00    	js     801e24 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d17:	83 ec 0c             	sub    $0xc,%esp
  801d1a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d1d:	50                   	push   %eax
  801d1e:	e8 d8 f4 ff ff       	call   8011fb <fd_alloc>
  801d23:	89 c3                	mov    %eax,%ebx
  801d25:	83 c4 10             	add    $0x10,%esp
  801d28:	85 c0                	test   %eax,%eax
  801d2a:	0f 88 e2 00 00 00    	js     801e12 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d30:	83 ec 04             	sub    $0x4,%esp
  801d33:	68 07 04 00 00       	push   $0x407
  801d38:	ff 75 f0             	pushl  -0x10(%ebp)
  801d3b:	6a 00                	push   $0x0
  801d3d:	e8 27 ef ff ff       	call   800c69 <sys_page_alloc>
  801d42:	89 c3                	mov    %eax,%ebx
  801d44:	83 c4 10             	add    $0x10,%esp
  801d47:	85 c0                	test   %eax,%eax
  801d49:	0f 88 c3 00 00 00    	js     801e12 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d4f:	83 ec 0c             	sub    $0xc,%esp
  801d52:	ff 75 f4             	pushl  -0xc(%ebp)
  801d55:	e8 8a f4 ff ff       	call   8011e4 <fd2data>
  801d5a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d5c:	83 c4 0c             	add    $0xc,%esp
  801d5f:	68 07 04 00 00       	push   $0x407
  801d64:	50                   	push   %eax
  801d65:	6a 00                	push   $0x0
  801d67:	e8 fd ee ff ff       	call   800c69 <sys_page_alloc>
  801d6c:	89 c3                	mov    %eax,%ebx
  801d6e:	83 c4 10             	add    $0x10,%esp
  801d71:	85 c0                	test   %eax,%eax
  801d73:	0f 88 89 00 00 00    	js     801e02 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d79:	83 ec 0c             	sub    $0xc,%esp
  801d7c:	ff 75 f0             	pushl  -0x10(%ebp)
  801d7f:	e8 60 f4 ff ff       	call   8011e4 <fd2data>
  801d84:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d8b:	50                   	push   %eax
  801d8c:	6a 00                	push   $0x0
  801d8e:	56                   	push   %esi
  801d8f:	6a 00                	push   $0x0
  801d91:	e8 16 ef ff ff       	call   800cac <sys_page_map>
  801d96:	89 c3                	mov    %eax,%ebx
  801d98:	83 c4 20             	add    $0x20,%esp
  801d9b:	85 c0                	test   %eax,%eax
  801d9d:	78 55                	js     801df4 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d9f:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801daa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dad:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801db4:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801dba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dbd:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801dbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dc2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801dc9:	83 ec 0c             	sub    $0xc,%esp
  801dcc:	ff 75 f4             	pushl  -0xc(%ebp)
  801dcf:	e8 00 f4 ff ff       	call   8011d4 <fd2num>
  801dd4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dd7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dd9:	83 c4 04             	add    $0x4,%esp
  801ddc:	ff 75 f0             	pushl  -0x10(%ebp)
  801ddf:	e8 f0 f3 ff ff       	call   8011d4 <fd2num>
  801de4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801de7:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801dea:	83 c4 10             	add    $0x10,%esp
  801ded:	ba 00 00 00 00       	mov    $0x0,%edx
  801df2:	eb 30                	jmp    801e24 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801df4:	83 ec 08             	sub    $0x8,%esp
  801df7:	56                   	push   %esi
  801df8:	6a 00                	push   $0x0
  801dfa:	e8 ef ee ff ff       	call   800cee <sys_page_unmap>
  801dff:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e02:	83 ec 08             	sub    $0x8,%esp
  801e05:	ff 75 f0             	pushl  -0x10(%ebp)
  801e08:	6a 00                	push   $0x0
  801e0a:	e8 df ee ff ff       	call   800cee <sys_page_unmap>
  801e0f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e12:	83 ec 08             	sub    $0x8,%esp
  801e15:	ff 75 f4             	pushl  -0xc(%ebp)
  801e18:	6a 00                	push   $0x0
  801e1a:	e8 cf ee ff ff       	call   800cee <sys_page_unmap>
  801e1f:	83 c4 10             	add    $0x10,%esp
  801e22:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e24:	89 d0                	mov    %edx,%eax
  801e26:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e29:	5b                   	pop    %ebx
  801e2a:	5e                   	pop    %esi
  801e2b:	5d                   	pop    %ebp
  801e2c:	c3                   	ret    

00801e2d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e2d:	55                   	push   %ebp
  801e2e:	89 e5                	mov    %esp,%ebp
  801e30:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e33:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e36:	50                   	push   %eax
  801e37:	ff 75 08             	pushl  0x8(%ebp)
  801e3a:	e8 0b f4 ff ff       	call   80124a <fd_lookup>
  801e3f:	83 c4 10             	add    $0x10,%esp
  801e42:	85 c0                	test   %eax,%eax
  801e44:	78 18                	js     801e5e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e46:	83 ec 0c             	sub    $0xc,%esp
  801e49:	ff 75 f4             	pushl  -0xc(%ebp)
  801e4c:	e8 93 f3 ff ff       	call   8011e4 <fd2data>
	return _pipeisclosed(fd, p);
  801e51:	89 c2                	mov    %eax,%edx
  801e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e56:	e8 18 fd ff ff       	call   801b73 <_pipeisclosed>
  801e5b:	83 c4 10             	add    $0x10,%esp
}
  801e5e:	c9                   	leave  
  801e5f:	c3                   	ret    

00801e60 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e60:	55                   	push   %ebp
  801e61:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e63:	b8 00 00 00 00       	mov    $0x0,%eax
  801e68:	5d                   	pop    %ebp
  801e69:	c3                   	ret    

00801e6a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e6a:	55                   	push   %ebp
  801e6b:	89 e5                	mov    %esp,%ebp
  801e6d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e70:	68 6a 29 80 00       	push   $0x80296a
  801e75:	ff 75 0c             	pushl  0xc(%ebp)
  801e78:	e8 e9 e9 ff ff       	call   800866 <strcpy>
	return 0;
}
  801e7d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e82:	c9                   	leave  
  801e83:	c3                   	ret    

00801e84 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e84:	55                   	push   %ebp
  801e85:	89 e5                	mov    %esp,%ebp
  801e87:	57                   	push   %edi
  801e88:	56                   	push   %esi
  801e89:	53                   	push   %ebx
  801e8a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e90:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e95:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e9b:	eb 2d                	jmp    801eca <devcons_write+0x46>
		m = n - tot;
  801e9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ea0:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ea2:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ea5:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801eaa:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ead:	83 ec 04             	sub    $0x4,%esp
  801eb0:	53                   	push   %ebx
  801eb1:	03 45 0c             	add    0xc(%ebp),%eax
  801eb4:	50                   	push   %eax
  801eb5:	57                   	push   %edi
  801eb6:	e8 3d eb ff ff       	call   8009f8 <memmove>
		sys_cputs(buf, m);
  801ebb:	83 c4 08             	add    $0x8,%esp
  801ebe:	53                   	push   %ebx
  801ebf:	57                   	push   %edi
  801ec0:	e8 e8 ec ff ff       	call   800bad <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ec5:	01 de                	add    %ebx,%esi
  801ec7:	83 c4 10             	add    $0x10,%esp
  801eca:	89 f0                	mov    %esi,%eax
  801ecc:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ecf:	72 cc                	jb     801e9d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ed1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ed4:	5b                   	pop    %ebx
  801ed5:	5e                   	pop    %esi
  801ed6:	5f                   	pop    %edi
  801ed7:	5d                   	pop    %ebp
  801ed8:	c3                   	ret    

00801ed9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
  801edc:	83 ec 08             	sub    $0x8,%esp
  801edf:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ee4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ee8:	74 2a                	je     801f14 <devcons_read+0x3b>
  801eea:	eb 05                	jmp    801ef1 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801eec:	e8 59 ed ff ff       	call   800c4a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ef1:	e8 d5 ec ff ff       	call   800bcb <sys_cgetc>
  801ef6:	85 c0                	test   %eax,%eax
  801ef8:	74 f2                	je     801eec <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801efa:	85 c0                	test   %eax,%eax
  801efc:	78 16                	js     801f14 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801efe:	83 f8 04             	cmp    $0x4,%eax
  801f01:	74 0c                	je     801f0f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f03:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f06:	88 02                	mov    %al,(%edx)
	return 1;
  801f08:	b8 01 00 00 00       	mov    $0x1,%eax
  801f0d:	eb 05                	jmp    801f14 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f0f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f14:	c9                   	leave  
  801f15:	c3                   	ret    

00801f16 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f16:	55                   	push   %ebp
  801f17:	89 e5                	mov    %esp,%ebp
  801f19:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f22:	6a 01                	push   $0x1
  801f24:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f27:	50                   	push   %eax
  801f28:	e8 80 ec ff ff       	call   800bad <sys_cputs>
}
  801f2d:	83 c4 10             	add    $0x10,%esp
  801f30:	c9                   	leave  
  801f31:	c3                   	ret    

00801f32 <getchar>:

int
getchar(void)
{
  801f32:	55                   	push   %ebp
  801f33:	89 e5                	mov    %esp,%ebp
  801f35:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f38:	6a 01                	push   $0x1
  801f3a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f3d:	50                   	push   %eax
  801f3e:	6a 00                	push   $0x0
  801f40:	e8 6e f5 ff ff       	call   8014b3 <read>
	if (r < 0)
  801f45:	83 c4 10             	add    $0x10,%esp
  801f48:	85 c0                	test   %eax,%eax
  801f4a:	78 0f                	js     801f5b <getchar+0x29>
		return r;
	if (r < 1)
  801f4c:	85 c0                	test   %eax,%eax
  801f4e:	7e 06                	jle    801f56 <getchar+0x24>
		return -E_EOF;
	return c;
  801f50:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f54:	eb 05                	jmp    801f5b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f56:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f5b:	c9                   	leave  
  801f5c:	c3                   	ret    

00801f5d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f5d:	55                   	push   %ebp
  801f5e:	89 e5                	mov    %esp,%ebp
  801f60:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f63:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f66:	50                   	push   %eax
  801f67:	ff 75 08             	pushl  0x8(%ebp)
  801f6a:	e8 db f2 ff ff       	call   80124a <fd_lookup>
  801f6f:	83 c4 10             	add    $0x10,%esp
  801f72:	85 c0                	test   %eax,%eax
  801f74:	78 11                	js     801f87 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f79:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f7f:	39 10                	cmp    %edx,(%eax)
  801f81:	0f 94 c0             	sete   %al
  801f84:	0f b6 c0             	movzbl %al,%eax
}
  801f87:	c9                   	leave  
  801f88:	c3                   	ret    

00801f89 <opencons>:

int
opencons(void)
{
  801f89:	55                   	push   %ebp
  801f8a:	89 e5                	mov    %esp,%ebp
  801f8c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f92:	50                   	push   %eax
  801f93:	e8 63 f2 ff ff       	call   8011fb <fd_alloc>
  801f98:	83 c4 10             	add    $0x10,%esp
		return r;
  801f9b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f9d:	85 c0                	test   %eax,%eax
  801f9f:	78 3e                	js     801fdf <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fa1:	83 ec 04             	sub    $0x4,%esp
  801fa4:	68 07 04 00 00       	push   $0x407
  801fa9:	ff 75 f4             	pushl  -0xc(%ebp)
  801fac:	6a 00                	push   $0x0
  801fae:	e8 b6 ec ff ff       	call   800c69 <sys_page_alloc>
  801fb3:	83 c4 10             	add    $0x10,%esp
		return r;
  801fb6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fb8:	85 c0                	test   %eax,%eax
  801fba:	78 23                	js     801fdf <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fbc:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fca:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fd1:	83 ec 0c             	sub    $0xc,%esp
  801fd4:	50                   	push   %eax
  801fd5:	e8 fa f1 ff ff       	call   8011d4 <fd2num>
  801fda:	89 c2                	mov    %eax,%edx
  801fdc:	83 c4 10             	add    $0x10,%esp
}
  801fdf:	89 d0                	mov    %edx,%eax
  801fe1:	c9                   	leave  
  801fe2:	c3                   	ret    

00801fe3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fe3:	55                   	push   %ebp
  801fe4:	89 e5                	mov    %esp,%ebp
  801fe6:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801fe9:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ff0:	75 2a                	jne    80201c <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801ff2:	83 ec 04             	sub    $0x4,%esp
  801ff5:	6a 07                	push   $0x7
  801ff7:	68 00 f0 bf ee       	push   $0xeebff000
  801ffc:	6a 00                	push   $0x0
  801ffe:	e8 66 ec ff ff       	call   800c69 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802003:	83 c4 10             	add    $0x10,%esp
  802006:	85 c0                	test   %eax,%eax
  802008:	79 12                	jns    80201c <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80200a:	50                   	push   %eax
  80200b:	68 76 29 80 00       	push   $0x802976
  802010:	6a 23                	push   $0x23
  802012:	68 7a 29 80 00       	push   $0x80297a
  802017:	e8 ec e1 ff ff       	call   800208 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80201c:	8b 45 08             	mov    0x8(%ebp),%eax
  80201f:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802024:	83 ec 08             	sub    $0x8,%esp
  802027:	68 4e 20 80 00       	push   $0x80204e
  80202c:	6a 00                	push   $0x0
  80202e:	e8 81 ed ff ff       	call   800db4 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802033:	83 c4 10             	add    $0x10,%esp
  802036:	85 c0                	test   %eax,%eax
  802038:	79 12                	jns    80204c <set_pgfault_handler+0x69>
		panic("%e\n", r);
  80203a:	50                   	push   %eax
  80203b:	68 76 29 80 00       	push   $0x802976
  802040:	6a 2c                	push   $0x2c
  802042:	68 7a 29 80 00       	push   $0x80297a
  802047:	e8 bc e1 ff ff       	call   800208 <_panic>
	}
}
  80204c:	c9                   	leave  
  80204d:	c3                   	ret    

0080204e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80204e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80204f:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802054:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802056:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802059:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  80205d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802062:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802066:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802068:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  80206b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  80206c:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80206f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802070:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802071:	c3                   	ret    

00802072 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802072:	55                   	push   %ebp
  802073:	89 e5                	mov    %esp,%ebp
  802075:	56                   	push   %esi
  802076:	53                   	push   %ebx
  802077:	8b 75 08             	mov    0x8(%ebp),%esi
  80207a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80207d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802080:	85 c0                	test   %eax,%eax
  802082:	75 12                	jne    802096 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802084:	83 ec 0c             	sub    $0xc,%esp
  802087:	68 00 00 c0 ee       	push   $0xeec00000
  80208c:	e8 88 ed ff ff       	call   800e19 <sys_ipc_recv>
  802091:	83 c4 10             	add    $0x10,%esp
  802094:	eb 0c                	jmp    8020a2 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802096:	83 ec 0c             	sub    $0xc,%esp
  802099:	50                   	push   %eax
  80209a:	e8 7a ed ff ff       	call   800e19 <sys_ipc_recv>
  80209f:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8020a2:	85 f6                	test   %esi,%esi
  8020a4:	0f 95 c1             	setne  %cl
  8020a7:	85 db                	test   %ebx,%ebx
  8020a9:	0f 95 c2             	setne  %dl
  8020ac:	84 d1                	test   %dl,%cl
  8020ae:	74 09                	je     8020b9 <ipc_recv+0x47>
  8020b0:	89 c2                	mov    %eax,%edx
  8020b2:	c1 ea 1f             	shr    $0x1f,%edx
  8020b5:	84 d2                	test   %dl,%dl
  8020b7:	75 2d                	jne    8020e6 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8020b9:	85 f6                	test   %esi,%esi
  8020bb:	74 0d                	je     8020ca <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8020bd:	a1 08 40 80 00       	mov    0x804008,%eax
  8020c2:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8020c8:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8020ca:	85 db                	test   %ebx,%ebx
  8020cc:	74 0d                	je     8020db <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8020ce:	a1 08 40 80 00       	mov    0x804008,%eax
  8020d3:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  8020d9:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8020db:	a1 08 40 80 00       	mov    0x804008,%eax
  8020e0:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  8020e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020e9:	5b                   	pop    %ebx
  8020ea:	5e                   	pop    %esi
  8020eb:	5d                   	pop    %ebp
  8020ec:	c3                   	ret    

008020ed <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020ed:	55                   	push   %ebp
  8020ee:	89 e5                	mov    %esp,%ebp
  8020f0:	57                   	push   %edi
  8020f1:	56                   	push   %esi
  8020f2:	53                   	push   %ebx
  8020f3:	83 ec 0c             	sub    $0xc,%esp
  8020f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020f9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8020ff:	85 db                	test   %ebx,%ebx
  802101:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802106:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802109:	ff 75 14             	pushl  0x14(%ebp)
  80210c:	53                   	push   %ebx
  80210d:	56                   	push   %esi
  80210e:	57                   	push   %edi
  80210f:	e8 e2 ec ff ff       	call   800df6 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802114:	89 c2                	mov    %eax,%edx
  802116:	c1 ea 1f             	shr    $0x1f,%edx
  802119:	83 c4 10             	add    $0x10,%esp
  80211c:	84 d2                	test   %dl,%dl
  80211e:	74 17                	je     802137 <ipc_send+0x4a>
  802120:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802123:	74 12                	je     802137 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802125:	50                   	push   %eax
  802126:	68 88 29 80 00       	push   $0x802988
  80212b:	6a 47                	push   $0x47
  80212d:	68 96 29 80 00       	push   $0x802996
  802132:	e8 d1 e0 ff ff       	call   800208 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802137:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80213a:	75 07                	jne    802143 <ipc_send+0x56>
			sys_yield();
  80213c:	e8 09 eb ff ff       	call   800c4a <sys_yield>
  802141:	eb c6                	jmp    802109 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802143:	85 c0                	test   %eax,%eax
  802145:	75 c2                	jne    802109 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802147:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80214a:	5b                   	pop    %ebx
  80214b:	5e                   	pop    %esi
  80214c:	5f                   	pop    %edi
  80214d:	5d                   	pop    %ebp
  80214e:	c3                   	ret    

0080214f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80214f:	55                   	push   %ebp
  802150:	89 e5                	mov    %esp,%ebp
  802152:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802155:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80215a:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  802160:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802166:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  80216c:	39 ca                	cmp    %ecx,%edx
  80216e:	75 13                	jne    802183 <ipc_find_env+0x34>
			return envs[i].env_id;
  802170:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  802176:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80217b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  802181:	eb 0f                	jmp    802192 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802183:	83 c0 01             	add    $0x1,%eax
  802186:	3d 00 04 00 00       	cmp    $0x400,%eax
  80218b:	75 cd                	jne    80215a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80218d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802192:	5d                   	pop    %ebp
  802193:	c3                   	ret    

00802194 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802194:	55                   	push   %ebp
  802195:	89 e5                	mov    %esp,%ebp
  802197:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80219a:	89 d0                	mov    %edx,%eax
  80219c:	c1 e8 16             	shr    $0x16,%eax
  80219f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021a6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021ab:	f6 c1 01             	test   $0x1,%cl
  8021ae:	74 1d                	je     8021cd <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021b0:	c1 ea 0c             	shr    $0xc,%edx
  8021b3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021ba:	f6 c2 01             	test   $0x1,%dl
  8021bd:	74 0e                	je     8021cd <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021bf:	c1 ea 0c             	shr    $0xc,%edx
  8021c2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021c9:	ef 
  8021ca:	0f b7 c0             	movzwl %ax,%eax
}
  8021cd:	5d                   	pop    %ebp
  8021ce:	c3                   	ret    
  8021cf:	90                   	nop

008021d0 <__udivdi3>:
  8021d0:	55                   	push   %ebp
  8021d1:	57                   	push   %edi
  8021d2:	56                   	push   %esi
  8021d3:	53                   	push   %ebx
  8021d4:	83 ec 1c             	sub    $0x1c,%esp
  8021d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021e7:	85 f6                	test   %esi,%esi
  8021e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021ed:	89 ca                	mov    %ecx,%edx
  8021ef:	89 f8                	mov    %edi,%eax
  8021f1:	75 3d                	jne    802230 <__udivdi3+0x60>
  8021f3:	39 cf                	cmp    %ecx,%edi
  8021f5:	0f 87 c5 00 00 00    	ja     8022c0 <__udivdi3+0xf0>
  8021fb:	85 ff                	test   %edi,%edi
  8021fd:	89 fd                	mov    %edi,%ebp
  8021ff:	75 0b                	jne    80220c <__udivdi3+0x3c>
  802201:	b8 01 00 00 00       	mov    $0x1,%eax
  802206:	31 d2                	xor    %edx,%edx
  802208:	f7 f7                	div    %edi
  80220a:	89 c5                	mov    %eax,%ebp
  80220c:	89 c8                	mov    %ecx,%eax
  80220e:	31 d2                	xor    %edx,%edx
  802210:	f7 f5                	div    %ebp
  802212:	89 c1                	mov    %eax,%ecx
  802214:	89 d8                	mov    %ebx,%eax
  802216:	89 cf                	mov    %ecx,%edi
  802218:	f7 f5                	div    %ebp
  80221a:	89 c3                	mov    %eax,%ebx
  80221c:	89 d8                	mov    %ebx,%eax
  80221e:	89 fa                	mov    %edi,%edx
  802220:	83 c4 1c             	add    $0x1c,%esp
  802223:	5b                   	pop    %ebx
  802224:	5e                   	pop    %esi
  802225:	5f                   	pop    %edi
  802226:	5d                   	pop    %ebp
  802227:	c3                   	ret    
  802228:	90                   	nop
  802229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802230:	39 ce                	cmp    %ecx,%esi
  802232:	77 74                	ja     8022a8 <__udivdi3+0xd8>
  802234:	0f bd fe             	bsr    %esi,%edi
  802237:	83 f7 1f             	xor    $0x1f,%edi
  80223a:	0f 84 98 00 00 00    	je     8022d8 <__udivdi3+0x108>
  802240:	bb 20 00 00 00       	mov    $0x20,%ebx
  802245:	89 f9                	mov    %edi,%ecx
  802247:	89 c5                	mov    %eax,%ebp
  802249:	29 fb                	sub    %edi,%ebx
  80224b:	d3 e6                	shl    %cl,%esi
  80224d:	89 d9                	mov    %ebx,%ecx
  80224f:	d3 ed                	shr    %cl,%ebp
  802251:	89 f9                	mov    %edi,%ecx
  802253:	d3 e0                	shl    %cl,%eax
  802255:	09 ee                	or     %ebp,%esi
  802257:	89 d9                	mov    %ebx,%ecx
  802259:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80225d:	89 d5                	mov    %edx,%ebp
  80225f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802263:	d3 ed                	shr    %cl,%ebp
  802265:	89 f9                	mov    %edi,%ecx
  802267:	d3 e2                	shl    %cl,%edx
  802269:	89 d9                	mov    %ebx,%ecx
  80226b:	d3 e8                	shr    %cl,%eax
  80226d:	09 c2                	or     %eax,%edx
  80226f:	89 d0                	mov    %edx,%eax
  802271:	89 ea                	mov    %ebp,%edx
  802273:	f7 f6                	div    %esi
  802275:	89 d5                	mov    %edx,%ebp
  802277:	89 c3                	mov    %eax,%ebx
  802279:	f7 64 24 0c          	mull   0xc(%esp)
  80227d:	39 d5                	cmp    %edx,%ebp
  80227f:	72 10                	jb     802291 <__udivdi3+0xc1>
  802281:	8b 74 24 08          	mov    0x8(%esp),%esi
  802285:	89 f9                	mov    %edi,%ecx
  802287:	d3 e6                	shl    %cl,%esi
  802289:	39 c6                	cmp    %eax,%esi
  80228b:	73 07                	jae    802294 <__udivdi3+0xc4>
  80228d:	39 d5                	cmp    %edx,%ebp
  80228f:	75 03                	jne    802294 <__udivdi3+0xc4>
  802291:	83 eb 01             	sub    $0x1,%ebx
  802294:	31 ff                	xor    %edi,%edi
  802296:	89 d8                	mov    %ebx,%eax
  802298:	89 fa                	mov    %edi,%edx
  80229a:	83 c4 1c             	add    $0x1c,%esp
  80229d:	5b                   	pop    %ebx
  80229e:	5e                   	pop    %esi
  80229f:	5f                   	pop    %edi
  8022a0:	5d                   	pop    %ebp
  8022a1:	c3                   	ret    
  8022a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022a8:	31 ff                	xor    %edi,%edi
  8022aa:	31 db                	xor    %ebx,%ebx
  8022ac:	89 d8                	mov    %ebx,%eax
  8022ae:	89 fa                	mov    %edi,%edx
  8022b0:	83 c4 1c             	add    $0x1c,%esp
  8022b3:	5b                   	pop    %ebx
  8022b4:	5e                   	pop    %esi
  8022b5:	5f                   	pop    %edi
  8022b6:	5d                   	pop    %ebp
  8022b7:	c3                   	ret    
  8022b8:	90                   	nop
  8022b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	89 d8                	mov    %ebx,%eax
  8022c2:	f7 f7                	div    %edi
  8022c4:	31 ff                	xor    %edi,%edi
  8022c6:	89 c3                	mov    %eax,%ebx
  8022c8:	89 d8                	mov    %ebx,%eax
  8022ca:	89 fa                	mov    %edi,%edx
  8022cc:	83 c4 1c             	add    $0x1c,%esp
  8022cf:	5b                   	pop    %ebx
  8022d0:	5e                   	pop    %esi
  8022d1:	5f                   	pop    %edi
  8022d2:	5d                   	pop    %ebp
  8022d3:	c3                   	ret    
  8022d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022d8:	39 ce                	cmp    %ecx,%esi
  8022da:	72 0c                	jb     8022e8 <__udivdi3+0x118>
  8022dc:	31 db                	xor    %ebx,%ebx
  8022de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022e2:	0f 87 34 ff ff ff    	ja     80221c <__udivdi3+0x4c>
  8022e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022ed:	e9 2a ff ff ff       	jmp    80221c <__udivdi3+0x4c>
  8022f2:	66 90                	xchg   %ax,%ax
  8022f4:	66 90                	xchg   %ax,%ax
  8022f6:	66 90                	xchg   %ax,%ax
  8022f8:	66 90                	xchg   %ax,%ax
  8022fa:	66 90                	xchg   %ax,%ax
  8022fc:	66 90                	xchg   %ax,%ax
  8022fe:	66 90                	xchg   %ax,%ax

00802300 <__umoddi3>:
  802300:	55                   	push   %ebp
  802301:	57                   	push   %edi
  802302:	56                   	push   %esi
  802303:	53                   	push   %ebx
  802304:	83 ec 1c             	sub    $0x1c,%esp
  802307:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80230b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80230f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802313:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802317:	85 d2                	test   %edx,%edx
  802319:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80231d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802321:	89 f3                	mov    %esi,%ebx
  802323:	89 3c 24             	mov    %edi,(%esp)
  802326:	89 74 24 04          	mov    %esi,0x4(%esp)
  80232a:	75 1c                	jne    802348 <__umoddi3+0x48>
  80232c:	39 f7                	cmp    %esi,%edi
  80232e:	76 50                	jbe    802380 <__umoddi3+0x80>
  802330:	89 c8                	mov    %ecx,%eax
  802332:	89 f2                	mov    %esi,%edx
  802334:	f7 f7                	div    %edi
  802336:	89 d0                	mov    %edx,%eax
  802338:	31 d2                	xor    %edx,%edx
  80233a:	83 c4 1c             	add    $0x1c,%esp
  80233d:	5b                   	pop    %ebx
  80233e:	5e                   	pop    %esi
  80233f:	5f                   	pop    %edi
  802340:	5d                   	pop    %ebp
  802341:	c3                   	ret    
  802342:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802348:	39 f2                	cmp    %esi,%edx
  80234a:	89 d0                	mov    %edx,%eax
  80234c:	77 52                	ja     8023a0 <__umoddi3+0xa0>
  80234e:	0f bd ea             	bsr    %edx,%ebp
  802351:	83 f5 1f             	xor    $0x1f,%ebp
  802354:	75 5a                	jne    8023b0 <__umoddi3+0xb0>
  802356:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80235a:	0f 82 e0 00 00 00    	jb     802440 <__umoddi3+0x140>
  802360:	39 0c 24             	cmp    %ecx,(%esp)
  802363:	0f 86 d7 00 00 00    	jbe    802440 <__umoddi3+0x140>
  802369:	8b 44 24 08          	mov    0x8(%esp),%eax
  80236d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802371:	83 c4 1c             	add    $0x1c,%esp
  802374:	5b                   	pop    %ebx
  802375:	5e                   	pop    %esi
  802376:	5f                   	pop    %edi
  802377:	5d                   	pop    %ebp
  802378:	c3                   	ret    
  802379:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802380:	85 ff                	test   %edi,%edi
  802382:	89 fd                	mov    %edi,%ebp
  802384:	75 0b                	jne    802391 <__umoddi3+0x91>
  802386:	b8 01 00 00 00       	mov    $0x1,%eax
  80238b:	31 d2                	xor    %edx,%edx
  80238d:	f7 f7                	div    %edi
  80238f:	89 c5                	mov    %eax,%ebp
  802391:	89 f0                	mov    %esi,%eax
  802393:	31 d2                	xor    %edx,%edx
  802395:	f7 f5                	div    %ebp
  802397:	89 c8                	mov    %ecx,%eax
  802399:	f7 f5                	div    %ebp
  80239b:	89 d0                	mov    %edx,%eax
  80239d:	eb 99                	jmp    802338 <__umoddi3+0x38>
  80239f:	90                   	nop
  8023a0:	89 c8                	mov    %ecx,%eax
  8023a2:	89 f2                	mov    %esi,%edx
  8023a4:	83 c4 1c             	add    $0x1c,%esp
  8023a7:	5b                   	pop    %ebx
  8023a8:	5e                   	pop    %esi
  8023a9:	5f                   	pop    %edi
  8023aa:	5d                   	pop    %ebp
  8023ab:	c3                   	ret    
  8023ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023b0:	8b 34 24             	mov    (%esp),%esi
  8023b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023b8:	89 e9                	mov    %ebp,%ecx
  8023ba:	29 ef                	sub    %ebp,%edi
  8023bc:	d3 e0                	shl    %cl,%eax
  8023be:	89 f9                	mov    %edi,%ecx
  8023c0:	89 f2                	mov    %esi,%edx
  8023c2:	d3 ea                	shr    %cl,%edx
  8023c4:	89 e9                	mov    %ebp,%ecx
  8023c6:	09 c2                	or     %eax,%edx
  8023c8:	89 d8                	mov    %ebx,%eax
  8023ca:	89 14 24             	mov    %edx,(%esp)
  8023cd:	89 f2                	mov    %esi,%edx
  8023cf:	d3 e2                	shl    %cl,%edx
  8023d1:	89 f9                	mov    %edi,%ecx
  8023d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023db:	d3 e8                	shr    %cl,%eax
  8023dd:	89 e9                	mov    %ebp,%ecx
  8023df:	89 c6                	mov    %eax,%esi
  8023e1:	d3 e3                	shl    %cl,%ebx
  8023e3:	89 f9                	mov    %edi,%ecx
  8023e5:	89 d0                	mov    %edx,%eax
  8023e7:	d3 e8                	shr    %cl,%eax
  8023e9:	89 e9                	mov    %ebp,%ecx
  8023eb:	09 d8                	or     %ebx,%eax
  8023ed:	89 d3                	mov    %edx,%ebx
  8023ef:	89 f2                	mov    %esi,%edx
  8023f1:	f7 34 24             	divl   (%esp)
  8023f4:	89 d6                	mov    %edx,%esi
  8023f6:	d3 e3                	shl    %cl,%ebx
  8023f8:	f7 64 24 04          	mull   0x4(%esp)
  8023fc:	39 d6                	cmp    %edx,%esi
  8023fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802402:	89 d1                	mov    %edx,%ecx
  802404:	89 c3                	mov    %eax,%ebx
  802406:	72 08                	jb     802410 <__umoddi3+0x110>
  802408:	75 11                	jne    80241b <__umoddi3+0x11b>
  80240a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80240e:	73 0b                	jae    80241b <__umoddi3+0x11b>
  802410:	2b 44 24 04          	sub    0x4(%esp),%eax
  802414:	1b 14 24             	sbb    (%esp),%edx
  802417:	89 d1                	mov    %edx,%ecx
  802419:	89 c3                	mov    %eax,%ebx
  80241b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80241f:	29 da                	sub    %ebx,%edx
  802421:	19 ce                	sbb    %ecx,%esi
  802423:	89 f9                	mov    %edi,%ecx
  802425:	89 f0                	mov    %esi,%eax
  802427:	d3 e0                	shl    %cl,%eax
  802429:	89 e9                	mov    %ebp,%ecx
  80242b:	d3 ea                	shr    %cl,%edx
  80242d:	89 e9                	mov    %ebp,%ecx
  80242f:	d3 ee                	shr    %cl,%esi
  802431:	09 d0                	or     %edx,%eax
  802433:	89 f2                	mov    %esi,%edx
  802435:	83 c4 1c             	add    $0x1c,%esp
  802438:	5b                   	pop    %ebx
  802439:	5e                   	pop    %esi
  80243a:	5f                   	pop    %edi
  80243b:	5d                   	pop    %ebp
  80243c:	c3                   	ret    
  80243d:	8d 76 00             	lea    0x0(%esi),%esi
  802440:	29 f9                	sub    %edi,%ecx
  802442:	19 d6                	sbb    %edx,%esi
  802444:	89 74 24 04          	mov    %esi,0x4(%esp)
  802448:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80244c:	e9 18 ff ff ff       	jmp    802369 <__umoddi3+0x69>
