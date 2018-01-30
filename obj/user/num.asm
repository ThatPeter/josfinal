
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
  80005d:	68 e0 26 80 00       	push   $0x8026e0
  800062:	e8 e0 1c 00 00       	call   801d47 <printf>
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
  80007c:	e8 71 17 00 00       	call   8017f2 <write>
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	83 f8 01             	cmp    $0x1,%eax
  800087:	74 18                	je     8000a1 <num+0x6e>
			panic("write error copying %s: %e", s, r);
  800089:	83 ec 0c             	sub    $0xc,%esp
  80008c:	50                   	push   %eax
  80008d:	ff 75 0c             	pushl  0xc(%ebp)
  800090:	68 e5 26 80 00       	push   $0x8026e5
  800095:	6a 13                	push   $0x13
  800097:	68 00 27 80 00       	push   $0x802700
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
  8000b8:	e8 58 16 00 00       	call   801715 <read>
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
  8000d3:	68 0b 27 80 00       	push   $0x80270b
  8000d8:	6a 18                	push   $0x18
  8000da:	68 00 27 80 00       	push   $0x802700
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
  8000f4:	c7 05 04 30 80 00 20 	movl   $0x802720,0x803004
  8000fb:	27 80 00 
	if (argc == 1)
  8000fe:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  800102:	74 0d                	je     800111 <umain+0x26>
  800104:	8b 45 0c             	mov    0xc(%ebp),%eax
  800107:	8d 58 04             	lea    0x4(%eax),%ebx
  80010a:	bf 01 00 00 00       	mov    $0x1,%edi
  80010f:	eb 62                	jmp    800173 <umain+0x88>
		num(0, "<stdin>");
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	68 24 27 80 00       	push   $0x802724
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
  80012f:	e8 75 1a 00 00       	call   801ba9 <open>
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
  800146:	68 2c 27 80 00       	push   $0x80272c
  80014b:	6a 27                	push   $0x27
  80014d:	68 00 27 80 00       	push   $0x802700
  800152:	e8 b1 00 00 00       	call   800208 <_panic>
			else {
				num(f, argv[i]);
  800157:	83 ec 08             	sub    $0x8,%esp
  80015a:	ff 33                	pushl  (%ebx)
  80015c:	50                   	push   %eax
  80015d:	e8 d1 fe ff ff       	call   800033 <num>
				close(f);
  800162:	89 34 24             	mov    %esi,(%esp)
  800165:	e8 6f 14 00 00       	call   8015d9 <close>

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
  8001f4:	e8 0b 14 00 00       	call   801604 <close_all>
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
  800226:	68 48 27 80 00       	push   $0x802748
  80022b:	e8 b1 00 00 00       	call   8002e1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800230:	83 c4 18             	add    $0x18,%esp
  800233:	53                   	push   %ebx
  800234:	ff 75 10             	pushl  0x10(%ebp)
  800237:	e8 54 00 00 00       	call   800290 <vcprintf>
	cprintf("\n");
  80023c:	c7 04 24 26 2b 80 00 	movl   $0x802b26,(%esp)
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
  800344:	e8 f7 20 00 00       	call   802440 <__udivdi3>
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
  800387:	e8 e4 21 00 00       	call   802570 <__umoddi3>
  80038c:	83 c4 14             	add    $0x14,%esp
  80038f:	0f be 80 6b 27 80 00 	movsbl 0x80276b(%eax),%eax
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
  80048b:	ff 24 85 a0 28 80 00 	jmp    *0x8028a0(,%eax,4)
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
  80054f:	8b 14 85 00 2a 80 00 	mov    0x802a00(,%eax,4),%edx
  800556:	85 d2                	test   %edx,%edx
  800558:	75 18                	jne    800572 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80055a:	50                   	push   %eax
  80055b:	68 83 27 80 00       	push   $0x802783
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
  800573:	68 91 2c 80 00       	push   $0x802c91
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
  800597:	b8 7c 27 80 00       	mov    $0x80277c,%eax
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
  800c12:	68 5f 2a 80 00       	push   $0x802a5f
  800c17:	6a 23                	push   $0x23
  800c19:	68 7c 2a 80 00       	push   $0x802a7c
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
  800c93:	68 5f 2a 80 00       	push   $0x802a5f
  800c98:	6a 23                	push   $0x23
  800c9a:	68 7c 2a 80 00       	push   $0x802a7c
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
  800cd5:	68 5f 2a 80 00       	push   $0x802a5f
  800cda:	6a 23                	push   $0x23
  800cdc:	68 7c 2a 80 00       	push   $0x802a7c
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
  800d17:	68 5f 2a 80 00       	push   $0x802a5f
  800d1c:	6a 23                	push   $0x23
  800d1e:	68 7c 2a 80 00       	push   $0x802a7c
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
  800d59:	68 5f 2a 80 00       	push   $0x802a5f
  800d5e:	6a 23                	push   $0x23
  800d60:	68 7c 2a 80 00       	push   $0x802a7c
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
  800d9b:	68 5f 2a 80 00       	push   $0x802a5f
  800da0:	6a 23                	push   $0x23
  800da2:	68 7c 2a 80 00       	push   $0x802a7c
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
  800ddd:	68 5f 2a 80 00       	push   $0x802a5f
  800de2:	6a 23                	push   $0x23
  800de4:	68 7c 2a 80 00       	push   $0x802a7c
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
  800e41:	68 5f 2a 80 00       	push   $0x802a5f
  800e46:	6a 23                	push   $0x23
  800e48:	68 7c 2a 80 00       	push   $0x802a7c
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
  800ee0:	68 8a 2a 80 00       	push   $0x802a8a
  800ee5:	6a 1f                	push   $0x1f
  800ee7:	68 9a 2a 80 00       	push   $0x802a9a
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
  800f0a:	68 a5 2a 80 00       	push   $0x802aa5
  800f0f:	6a 2d                	push   $0x2d
  800f11:	68 9a 2a 80 00       	push   $0x802a9a
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
  800f52:	68 a5 2a 80 00       	push   $0x802aa5
  800f57:	6a 34                	push   $0x34
  800f59:	68 9a 2a 80 00       	push   $0x802a9a
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
  800f7a:	68 a5 2a 80 00       	push   $0x802aa5
  800f7f:	6a 38                	push   $0x38
  800f81:	68 9a 2a 80 00       	push   $0x802a9a
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
  800f9e:	e8 a2 12 00 00       	call   802245 <set_pgfault_handler>
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
  800fb7:	68 be 2a 80 00       	push   $0x802abe
  800fbc:	68 85 00 00 00       	push   $0x85
  800fc1:	68 9a 2a 80 00       	push   $0x802a9a
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
  801073:	68 cc 2a 80 00       	push   $0x802acc
  801078:	6a 55                	push   $0x55
  80107a:	68 9a 2a 80 00       	push   $0x802a9a
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
  8010b8:	68 cc 2a 80 00       	push   $0x802acc
  8010bd:	6a 5c                	push   $0x5c
  8010bf:	68 9a 2a 80 00       	push   $0x802a9a
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
  8010e6:	68 cc 2a 80 00       	push   $0x802acc
  8010eb:	6a 60                	push   $0x60
  8010ed:	68 9a 2a 80 00       	push   $0x802a9a
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
  801110:	68 cc 2a 80 00       	push   $0x802acc
  801115:	6a 65                	push   $0x65
  801117:	68 9a 2a 80 00       	push   $0x802a9a
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
  80117f:	68 5c 2b 80 00       	push   $0x802b5c
  801184:	e8 58 f1 ff ff       	call   8002e1 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801189:	c7 04 24 ce 01 80 00 	movl   $0x8001ce,(%esp)
  801190:	e8 c5 fc ff ff       	call   800e5a <sys_thread_create>
  801195:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801197:	83 c4 08             	add    $0x8,%esp
  80119a:	53                   	push   %ebx
  80119b:	68 5c 2b 80 00       	push   $0x802b5c
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

008011d4 <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  8011d4:	55                   	push   %ebp
  8011d5:	89 e5                	mov    %esp,%ebp
  8011d7:	56                   	push   %esi
  8011d8:	53                   	push   %ebx
  8011d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8011dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8011df:	83 ec 04             	sub    $0x4,%esp
  8011e2:	6a 07                	push   $0x7
  8011e4:	6a 00                	push   $0x0
  8011e6:	56                   	push   %esi
  8011e7:	e8 7d fa ff ff       	call   800c69 <sys_page_alloc>
	if (r < 0) {
  8011ec:	83 c4 10             	add    $0x10,%esp
  8011ef:	85 c0                	test   %eax,%eax
  8011f1:	79 15                	jns    801208 <queue_append+0x34>
		panic("%e\n", r);
  8011f3:	50                   	push   %eax
  8011f4:	68 58 2b 80 00       	push   $0x802b58
  8011f9:	68 c4 00 00 00       	push   $0xc4
  8011fe:	68 9a 2a 80 00       	push   $0x802a9a
  801203:	e8 00 f0 ff ff       	call   800208 <_panic>
	}	
	wt->envid = envid;
  801208:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  80120e:	83 ec 04             	sub    $0x4,%esp
  801211:	ff 33                	pushl  (%ebx)
  801213:	56                   	push   %esi
  801214:	68 80 2b 80 00       	push   $0x802b80
  801219:	e8 c3 f0 ff ff       	call   8002e1 <cprintf>
	if (queue->first == NULL) {
  80121e:	83 c4 10             	add    $0x10,%esp
  801221:	83 3b 00             	cmpl   $0x0,(%ebx)
  801224:	75 29                	jne    80124f <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  801226:	83 ec 0c             	sub    $0xc,%esp
  801229:	68 e2 2a 80 00       	push   $0x802ae2
  80122e:	e8 ae f0 ff ff       	call   8002e1 <cprintf>
		queue->first = wt;
  801233:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  801239:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  801240:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801247:	00 00 00 
  80124a:	83 c4 10             	add    $0x10,%esp
  80124d:	eb 2b                	jmp    80127a <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  80124f:	83 ec 0c             	sub    $0xc,%esp
  801252:	68 fc 2a 80 00       	push   $0x802afc
  801257:	e8 85 f0 ff ff       	call   8002e1 <cprintf>
		queue->last->next = wt;
  80125c:	8b 43 04             	mov    0x4(%ebx),%eax
  80125f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  801266:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80126d:	00 00 00 
		queue->last = wt;
  801270:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  801277:	83 c4 10             	add    $0x10,%esp
	}
}
  80127a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80127d:	5b                   	pop    %ebx
  80127e:	5e                   	pop    %esi
  80127f:	5d                   	pop    %ebp
  801280:	c3                   	ret    

00801281 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  801281:	55                   	push   %ebp
  801282:	89 e5                	mov    %esp,%ebp
  801284:	53                   	push   %ebx
  801285:	83 ec 04             	sub    $0x4,%esp
  801288:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  80128b:	8b 02                	mov    (%edx),%eax
  80128d:	85 c0                	test   %eax,%eax
  80128f:	75 17                	jne    8012a8 <queue_pop+0x27>
		panic("queue empty!\n");
  801291:	83 ec 04             	sub    $0x4,%esp
  801294:	68 1a 2b 80 00       	push   $0x802b1a
  801299:	68 d8 00 00 00       	push   $0xd8
  80129e:	68 9a 2a 80 00       	push   $0x802a9a
  8012a3:	e8 60 ef ff ff       	call   800208 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  8012a8:	8b 48 04             	mov    0x4(%eax),%ecx
  8012ab:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  8012ad:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  8012af:	83 ec 08             	sub    $0x8,%esp
  8012b2:	53                   	push   %ebx
  8012b3:	68 28 2b 80 00       	push   $0x802b28
  8012b8:	e8 24 f0 ff ff       	call   8002e1 <cprintf>
	return envid;
}
  8012bd:	89 d8                	mov    %ebx,%eax
  8012bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c2:	c9                   	leave  
  8012c3:	c3                   	ret    

008012c4 <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	53                   	push   %ebx
  8012c8:	83 ec 04             	sub    $0x4,%esp
  8012cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  8012ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8012d3:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8012d6:	85 c0                	test   %eax,%eax
  8012d8:	74 5a                	je     801334 <mutex_lock+0x70>
  8012da:	8b 43 04             	mov    0x4(%ebx),%eax
  8012dd:	83 38 00             	cmpl   $0x0,(%eax)
  8012e0:	75 52                	jne    801334 <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  8012e2:	83 ec 0c             	sub    $0xc,%esp
  8012e5:	68 a8 2b 80 00       	push   $0x802ba8
  8012ea:	e8 f2 ef ff ff       	call   8002e1 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  8012ef:	8b 5b 04             	mov    0x4(%ebx),%ebx
  8012f2:	e8 34 f9 ff ff       	call   800c2b <sys_getenvid>
  8012f7:	83 c4 08             	add    $0x8,%esp
  8012fa:	53                   	push   %ebx
  8012fb:	50                   	push   %eax
  8012fc:	e8 d3 fe ff ff       	call   8011d4 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  801301:	e8 25 f9 ff ff       	call   800c2b <sys_getenvid>
  801306:	83 c4 08             	add    $0x8,%esp
  801309:	6a 04                	push   $0x4
  80130b:	50                   	push   %eax
  80130c:	e8 1f fa ff ff       	call   800d30 <sys_env_set_status>
		if (r < 0) {
  801311:	83 c4 10             	add    $0x10,%esp
  801314:	85 c0                	test   %eax,%eax
  801316:	79 15                	jns    80132d <mutex_lock+0x69>
			panic("%e\n", r);
  801318:	50                   	push   %eax
  801319:	68 58 2b 80 00       	push   $0x802b58
  80131e:	68 eb 00 00 00       	push   $0xeb
  801323:	68 9a 2a 80 00       	push   $0x802a9a
  801328:	e8 db ee ff ff       	call   800208 <_panic>
		}
		sys_yield();
  80132d:	e8 18 f9 ff ff       	call   800c4a <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801332:	eb 18                	jmp    80134c <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  801334:	83 ec 0c             	sub    $0xc,%esp
  801337:	68 c8 2b 80 00       	push   $0x802bc8
  80133c:	e8 a0 ef ff ff       	call   8002e1 <cprintf>
	mtx->owner = sys_getenvid();}
  801341:	e8 e5 f8 ff ff       	call   800c2b <sys_getenvid>
  801346:	89 43 08             	mov    %eax,0x8(%ebx)
  801349:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  80134c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80134f:	c9                   	leave  
  801350:	c3                   	ret    

00801351 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  801351:	55                   	push   %ebp
  801352:	89 e5                	mov    %esp,%ebp
  801354:	53                   	push   %ebx
  801355:	83 ec 04             	sub    $0x4,%esp
  801358:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80135b:	b8 00 00 00 00       	mov    $0x0,%eax
  801360:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  801363:	8b 43 04             	mov    0x4(%ebx),%eax
  801366:	83 38 00             	cmpl   $0x0,(%eax)
  801369:	74 33                	je     80139e <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  80136b:	83 ec 0c             	sub    $0xc,%esp
  80136e:	50                   	push   %eax
  80136f:	e8 0d ff ff ff       	call   801281 <queue_pop>
  801374:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  801377:	83 c4 08             	add    $0x8,%esp
  80137a:	6a 02                	push   $0x2
  80137c:	50                   	push   %eax
  80137d:	e8 ae f9 ff ff       	call   800d30 <sys_env_set_status>
		if (r < 0) {
  801382:	83 c4 10             	add    $0x10,%esp
  801385:	85 c0                	test   %eax,%eax
  801387:	79 15                	jns    80139e <mutex_unlock+0x4d>
			panic("%e\n", r);
  801389:	50                   	push   %eax
  80138a:	68 58 2b 80 00       	push   $0x802b58
  80138f:	68 00 01 00 00       	push   $0x100
  801394:	68 9a 2a 80 00       	push   $0x802a9a
  801399:	e8 6a ee ff ff       	call   800208 <_panic>
		}
	}

	asm volatile("pause");
  80139e:	f3 90                	pause  
	//sys_yield();
}
  8013a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a3:	c9                   	leave  
  8013a4:	c3                   	ret    

008013a5 <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	53                   	push   %ebx
  8013a9:	83 ec 04             	sub    $0x4,%esp
  8013ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8013af:	e8 77 f8 ff ff       	call   800c2b <sys_getenvid>
  8013b4:	83 ec 04             	sub    $0x4,%esp
  8013b7:	6a 07                	push   $0x7
  8013b9:	53                   	push   %ebx
  8013ba:	50                   	push   %eax
  8013bb:	e8 a9 f8 ff ff       	call   800c69 <sys_page_alloc>
  8013c0:	83 c4 10             	add    $0x10,%esp
  8013c3:	85 c0                	test   %eax,%eax
  8013c5:	79 15                	jns    8013dc <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  8013c7:	50                   	push   %eax
  8013c8:	68 43 2b 80 00       	push   $0x802b43
  8013cd:	68 0d 01 00 00       	push   $0x10d
  8013d2:	68 9a 2a 80 00       	push   $0x802a9a
  8013d7:	e8 2c ee ff ff       	call   800208 <_panic>
	}	
	mtx->locked = 0;
  8013dc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  8013e2:	8b 43 04             	mov    0x4(%ebx),%eax
  8013e5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  8013eb:	8b 43 04             	mov    0x4(%ebx),%eax
  8013ee:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  8013f5:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  8013fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ff:	c9                   	leave  
  801400:	c3                   	ret    

00801401 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  801401:	55                   	push   %ebp
  801402:	89 e5                	mov    %esp,%ebp
  801404:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  801407:	e8 1f f8 ff ff       	call   800c2b <sys_getenvid>
  80140c:	83 ec 08             	sub    $0x8,%esp
  80140f:	ff 75 08             	pushl  0x8(%ebp)
  801412:	50                   	push   %eax
  801413:	e8 d6 f8 ff ff       	call   800cee <sys_page_unmap>
	if (r < 0) {
  801418:	83 c4 10             	add    $0x10,%esp
  80141b:	85 c0                	test   %eax,%eax
  80141d:	79 15                	jns    801434 <mutex_destroy+0x33>
		panic("%e\n", r);
  80141f:	50                   	push   %eax
  801420:	68 58 2b 80 00       	push   $0x802b58
  801425:	68 1a 01 00 00       	push   $0x11a
  80142a:	68 9a 2a 80 00       	push   $0x802a9a
  80142f:	e8 d4 ed ff ff       	call   800208 <_panic>
	}
}
  801434:	c9                   	leave  
  801435:	c3                   	ret    

00801436 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801436:	55                   	push   %ebp
  801437:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801439:	8b 45 08             	mov    0x8(%ebp),%eax
  80143c:	05 00 00 00 30       	add    $0x30000000,%eax
  801441:	c1 e8 0c             	shr    $0xc,%eax
}
  801444:	5d                   	pop    %ebp
  801445:	c3                   	ret    

00801446 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801446:	55                   	push   %ebp
  801447:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801449:	8b 45 08             	mov    0x8(%ebp),%eax
  80144c:	05 00 00 00 30       	add    $0x30000000,%eax
  801451:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801456:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80145b:	5d                   	pop    %ebp
  80145c:	c3                   	ret    

0080145d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80145d:	55                   	push   %ebp
  80145e:	89 e5                	mov    %esp,%ebp
  801460:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801463:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801468:	89 c2                	mov    %eax,%edx
  80146a:	c1 ea 16             	shr    $0x16,%edx
  80146d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801474:	f6 c2 01             	test   $0x1,%dl
  801477:	74 11                	je     80148a <fd_alloc+0x2d>
  801479:	89 c2                	mov    %eax,%edx
  80147b:	c1 ea 0c             	shr    $0xc,%edx
  80147e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801485:	f6 c2 01             	test   $0x1,%dl
  801488:	75 09                	jne    801493 <fd_alloc+0x36>
			*fd_store = fd;
  80148a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80148c:	b8 00 00 00 00       	mov    $0x0,%eax
  801491:	eb 17                	jmp    8014aa <fd_alloc+0x4d>
  801493:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801498:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80149d:	75 c9                	jne    801468 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80149f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8014a5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014aa:	5d                   	pop    %ebp
  8014ab:	c3                   	ret    

008014ac <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014ac:	55                   	push   %ebp
  8014ad:	89 e5                	mov    %esp,%ebp
  8014af:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014b2:	83 f8 1f             	cmp    $0x1f,%eax
  8014b5:	77 36                	ja     8014ed <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014b7:	c1 e0 0c             	shl    $0xc,%eax
  8014ba:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014bf:	89 c2                	mov    %eax,%edx
  8014c1:	c1 ea 16             	shr    $0x16,%edx
  8014c4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014cb:	f6 c2 01             	test   $0x1,%dl
  8014ce:	74 24                	je     8014f4 <fd_lookup+0x48>
  8014d0:	89 c2                	mov    %eax,%edx
  8014d2:	c1 ea 0c             	shr    $0xc,%edx
  8014d5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014dc:	f6 c2 01             	test   $0x1,%dl
  8014df:	74 1a                	je     8014fb <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014e4:	89 02                	mov    %eax,(%edx)
	return 0;
  8014e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8014eb:	eb 13                	jmp    801500 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014f2:	eb 0c                	jmp    801500 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014f9:	eb 05                	jmp    801500 <fd_lookup+0x54>
  8014fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801500:	5d                   	pop    %ebp
  801501:	c3                   	ret    

00801502 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801502:	55                   	push   %ebp
  801503:	89 e5                	mov    %esp,%ebp
  801505:	83 ec 08             	sub    $0x8,%esp
  801508:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80150b:	ba 68 2c 80 00       	mov    $0x802c68,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801510:	eb 13                	jmp    801525 <dev_lookup+0x23>
  801512:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801515:	39 08                	cmp    %ecx,(%eax)
  801517:	75 0c                	jne    801525 <dev_lookup+0x23>
			*dev = devtab[i];
  801519:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80151c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80151e:	b8 00 00 00 00       	mov    $0x0,%eax
  801523:	eb 31                	jmp    801556 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801525:	8b 02                	mov    (%edx),%eax
  801527:	85 c0                	test   %eax,%eax
  801529:	75 e7                	jne    801512 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80152b:	a1 08 40 80 00       	mov    0x804008,%eax
  801530:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801536:	83 ec 04             	sub    $0x4,%esp
  801539:	51                   	push   %ecx
  80153a:	50                   	push   %eax
  80153b:	68 e8 2b 80 00       	push   $0x802be8
  801540:	e8 9c ed ff ff       	call   8002e1 <cprintf>
	*dev = 0;
  801545:	8b 45 0c             	mov    0xc(%ebp),%eax
  801548:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80154e:	83 c4 10             	add    $0x10,%esp
  801551:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801556:	c9                   	leave  
  801557:	c3                   	ret    

00801558 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801558:	55                   	push   %ebp
  801559:	89 e5                	mov    %esp,%ebp
  80155b:	56                   	push   %esi
  80155c:	53                   	push   %ebx
  80155d:	83 ec 10             	sub    $0x10,%esp
  801560:	8b 75 08             	mov    0x8(%ebp),%esi
  801563:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801566:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801569:	50                   	push   %eax
  80156a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801570:	c1 e8 0c             	shr    $0xc,%eax
  801573:	50                   	push   %eax
  801574:	e8 33 ff ff ff       	call   8014ac <fd_lookup>
  801579:	83 c4 08             	add    $0x8,%esp
  80157c:	85 c0                	test   %eax,%eax
  80157e:	78 05                	js     801585 <fd_close+0x2d>
	    || fd != fd2)
  801580:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801583:	74 0c                	je     801591 <fd_close+0x39>
		return (must_exist ? r : 0);
  801585:	84 db                	test   %bl,%bl
  801587:	ba 00 00 00 00       	mov    $0x0,%edx
  80158c:	0f 44 c2             	cmove  %edx,%eax
  80158f:	eb 41                	jmp    8015d2 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801591:	83 ec 08             	sub    $0x8,%esp
  801594:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801597:	50                   	push   %eax
  801598:	ff 36                	pushl  (%esi)
  80159a:	e8 63 ff ff ff       	call   801502 <dev_lookup>
  80159f:	89 c3                	mov    %eax,%ebx
  8015a1:	83 c4 10             	add    $0x10,%esp
  8015a4:	85 c0                	test   %eax,%eax
  8015a6:	78 1a                	js     8015c2 <fd_close+0x6a>
		if (dev->dev_close)
  8015a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ab:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8015ae:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	74 0b                	je     8015c2 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8015b7:	83 ec 0c             	sub    $0xc,%esp
  8015ba:	56                   	push   %esi
  8015bb:	ff d0                	call   *%eax
  8015bd:	89 c3                	mov    %eax,%ebx
  8015bf:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015c2:	83 ec 08             	sub    $0x8,%esp
  8015c5:	56                   	push   %esi
  8015c6:	6a 00                	push   $0x0
  8015c8:	e8 21 f7 ff ff       	call   800cee <sys_page_unmap>
	return r;
  8015cd:	83 c4 10             	add    $0x10,%esp
  8015d0:	89 d8                	mov    %ebx,%eax
}
  8015d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015d5:	5b                   	pop    %ebx
  8015d6:	5e                   	pop    %esi
  8015d7:	5d                   	pop    %ebp
  8015d8:	c3                   	ret    

008015d9 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015d9:	55                   	push   %ebp
  8015da:	89 e5                	mov    %esp,%ebp
  8015dc:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e2:	50                   	push   %eax
  8015e3:	ff 75 08             	pushl  0x8(%ebp)
  8015e6:	e8 c1 fe ff ff       	call   8014ac <fd_lookup>
  8015eb:	83 c4 08             	add    $0x8,%esp
  8015ee:	85 c0                	test   %eax,%eax
  8015f0:	78 10                	js     801602 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8015f2:	83 ec 08             	sub    $0x8,%esp
  8015f5:	6a 01                	push   $0x1
  8015f7:	ff 75 f4             	pushl  -0xc(%ebp)
  8015fa:	e8 59 ff ff ff       	call   801558 <fd_close>
  8015ff:	83 c4 10             	add    $0x10,%esp
}
  801602:	c9                   	leave  
  801603:	c3                   	ret    

00801604 <close_all>:

void
close_all(void)
{
  801604:	55                   	push   %ebp
  801605:	89 e5                	mov    %esp,%ebp
  801607:	53                   	push   %ebx
  801608:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80160b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801610:	83 ec 0c             	sub    $0xc,%esp
  801613:	53                   	push   %ebx
  801614:	e8 c0 ff ff ff       	call   8015d9 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801619:	83 c3 01             	add    $0x1,%ebx
  80161c:	83 c4 10             	add    $0x10,%esp
  80161f:	83 fb 20             	cmp    $0x20,%ebx
  801622:	75 ec                	jne    801610 <close_all+0xc>
		close(i);
}
  801624:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801627:	c9                   	leave  
  801628:	c3                   	ret    

00801629 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801629:	55                   	push   %ebp
  80162a:	89 e5                	mov    %esp,%ebp
  80162c:	57                   	push   %edi
  80162d:	56                   	push   %esi
  80162e:	53                   	push   %ebx
  80162f:	83 ec 2c             	sub    $0x2c,%esp
  801632:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801635:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801638:	50                   	push   %eax
  801639:	ff 75 08             	pushl  0x8(%ebp)
  80163c:	e8 6b fe ff ff       	call   8014ac <fd_lookup>
  801641:	83 c4 08             	add    $0x8,%esp
  801644:	85 c0                	test   %eax,%eax
  801646:	0f 88 c1 00 00 00    	js     80170d <dup+0xe4>
		return r;
	close(newfdnum);
  80164c:	83 ec 0c             	sub    $0xc,%esp
  80164f:	56                   	push   %esi
  801650:	e8 84 ff ff ff       	call   8015d9 <close>

	newfd = INDEX2FD(newfdnum);
  801655:	89 f3                	mov    %esi,%ebx
  801657:	c1 e3 0c             	shl    $0xc,%ebx
  80165a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801660:	83 c4 04             	add    $0x4,%esp
  801663:	ff 75 e4             	pushl  -0x1c(%ebp)
  801666:	e8 db fd ff ff       	call   801446 <fd2data>
  80166b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80166d:	89 1c 24             	mov    %ebx,(%esp)
  801670:	e8 d1 fd ff ff       	call   801446 <fd2data>
  801675:	83 c4 10             	add    $0x10,%esp
  801678:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80167b:	89 f8                	mov    %edi,%eax
  80167d:	c1 e8 16             	shr    $0x16,%eax
  801680:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801687:	a8 01                	test   $0x1,%al
  801689:	74 37                	je     8016c2 <dup+0x99>
  80168b:	89 f8                	mov    %edi,%eax
  80168d:	c1 e8 0c             	shr    $0xc,%eax
  801690:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801697:	f6 c2 01             	test   $0x1,%dl
  80169a:	74 26                	je     8016c2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80169c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016a3:	83 ec 0c             	sub    $0xc,%esp
  8016a6:	25 07 0e 00 00       	and    $0xe07,%eax
  8016ab:	50                   	push   %eax
  8016ac:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016af:	6a 00                	push   $0x0
  8016b1:	57                   	push   %edi
  8016b2:	6a 00                	push   $0x0
  8016b4:	e8 f3 f5 ff ff       	call   800cac <sys_page_map>
  8016b9:	89 c7                	mov    %eax,%edi
  8016bb:	83 c4 20             	add    $0x20,%esp
  8016be:	85 c0                	test   %eax,%eax
  8016c0:	78 2e                	js     8016f0 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016c2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016c5:	89 d0                	mov    %edx,%eax
  8016c7:	c1 e8 0c             	shr    $0xc,%eax
  8016ca:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016d1:	83 ec 0c             	sub    $0xc,%esp
  8016d4:	25 07 0e 00 00       	and    $0xe07,%eax
  8016d9:	50                   	push   %eax
  8016da:	53                   	push   %ebx
  8016db:	6a 00                	push   $0x0
  8016dd:	52                   	push   %edx
  8016de:	6a 00                	push   $0x0
  8016e0:	e8 c7 f5 ff ff       	call   800cac <sys_page_map>
  8016e5:	89 c7                	mov    %eax,%edi
  8016e7:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8016ea:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016ec:	85 ff                	test   %edi,%edi
  8016ee:	79 1d                	jns    80170d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016f0:	83 ec 08             	sub    $0x8,%esp
  8016f3:	53                   	push   %ebx
  8016f4:	6a 00                	push   $0x0
  8016f6:	e8 f3 f5 ff ff       	call   800cee <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016fb:	83 c4 08             	add    $0x8,%esp
  8016fe:	ff 75 d4             	pushl  -0x2c(%ebp)
  801701:	6a 00                	push   $0x0
  801703:	e8 e6 f5 ff ff       	call   800cee <sys_page_unmap>
	return r;
  801708:	83 c4 10             	add    $0x10,%esp
  80170b:	89 f8                	mov    %edi,%eax
}
  80170d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801710:	5b                   	pop    %ebx
  801711:	5e                   	pop    %esi
  801712:	5f                   	pop    %edi
  801713:	5d                   	pop    %ebp
  801714:	c3                   	ret    

00801715 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	53                   	push   %ebx
  801719:	83 ec 14             	sub    $0x14,%esp
  80171c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80171f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801722:	50                   	push   %eax
  801723:	53                   	push   %ebx
  801724:	e8 83 fd ff ff       	call   8014ac <fd_lookup>
  801729:	83 c4 08             	add    $0x8,%esp
  80172c:	89 c2                	mov    %eax,%edx
  80172e:	85 c0                	test   %eax,%eax
  801730:	78 70                	js     8017a2 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801732:	83 ec 08             	sub    $0x8,%esp
  801735:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801738:	50                   	push   %eax
  801739:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80173c:	ff 30                	pushl  (%eax)
  80173e:	e8 bf fd ff ff       	call   801502 <dev_lookup>
  801743:	83 c4 10             	add    $0x10,%esp
  801746:	85 c0                	test   %eax,%eax
  801748:	78 4f                	js     801799 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80174a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80174d:	8b 42 08             	mov    0x8(%edx),%eax
  801750:	83 e0 03             	and    $0x3,%eax
  801753:	83 f8 01             	cmp    $0x1,%eax
  801756:	75 24                	jne    80177c <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801758:	a1 08 40 80 00       	mov    0x804008,%eax
  80175d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801763:	83 ec 04             	sub    $0x4,%esp
  801766:	53                   	push   %ebx
  801767:	50                   	push   %eax
  801768:	68 2c 2c 80 00       	push   $0x802c2c
  80176d:	e8 6f eb ff ff       	call   8002e1 <cprintf>
		return -E_INVAL;
  801772:	83 c4 10             	add    $0x10,%esp
  801775:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80177a:	eb 26                	jmp    8017a2 <read+0x8d>
	}
	if (!dev->dev_read)
  80177c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80177f:	8b 40 08             	mov    0x8(%eax),%eax
  801782:	85 c0                	test   %eax,%eax
  801784:	74 17                	je     80179d <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801786:	83 ec 04             	sub    $0x4,%esp
  801789:	ff 75 10             	pushl  0x10(%ebp)
  80178c:	ff 75 0c             	pushl  0xc(%ebp)
  80178f:	52                   	push   %edx
  801790:	ff d0                	call   *%eax
  801792:	89 c2                	mov    %eax,%edx
  801794:	83 c4 10             	add    $0x10,%esp
  801797:	eb 09                	jmp    8017a2 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801799:	89 c2                	mov    %eax,%edx
  80179b:	eb 05                	jmp    8017a2 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80179d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8017a2:	89 d0                	mov    %edx,%eax
  8017a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a7:	c9                   	leave  
  8017a8:	c3                   	ret    

008017a9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017a9:	55                   	push   %ebp
  8017aa:	89 e5                	mov    %esp,%ebp
  8017ac:	57                   	push   %edi
  8017ad:	56                   	push   %esi
  8017ae:	53                   	push   %ebx
  8017af:	83 ec 0c             	sub    $0xc,%esp
  8017b2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017b5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017bd:	eb 21                	jmp    8017e0 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017bf:	83 ec 04             	sub    $0x4,%esp
  8017c2:	89 f0                	mov    %esi,%eax
  8017c4:	29 d8                	sub    %ebx,%eax
  8017c6:	50                   	push   %eax
  8017c7:	89 d8                	mov    %ebx,%eax
  8017c9:	03 45 0c             	add    0xc(%ebp),%eax
  8017cc:	50                   	push   %eax
  8017cd:	57                   	push   %edi
  8017ce:	e8 42 ff ff ff       	call   801715 <read>
		if (m < 0)
  8017d3:	83 c4 10             	add    $0x10,%esp
  8017d6:	85 c0                	test   %eax,%eax
  8017d8:	78 10                	js     8017ea <readn+0x41>
			return m;
		if (m == 0)
  8017da:	85 c0                	test   %eax,%eax
  8017dc:	74 0a                	je     8017e8 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017de:	01 c3                	add    %eax,%ebx
  8017e0:	39 f3                	cmp    %esi,%ebx
  8017e2:	72 db                	jb     8017bf <readn+0x16>
  8017e4:	89 d8                	mov    %ebx,%eax
  8017e6:	eb 02                	jmp    8017ea <readn+0x41>
  8017e8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8017ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017ed:	5b                   	pop    %ebx
  8017ee:	5e                   	pop    %esi
  8017ef:	5f                   	pop    %edi
  8017f0:	5d                   	pop    %ebp
  8017f1:	c3                   	ret    

008017f2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	53                   	push   %ebx
  8017f6:	83 ec 14             	sub    $0x14,%esp
  8017f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017ff:	50                   	push   %eax
  801800:	53                   	push   %ebx
  801801:	e8 a6 fc ff ff       	call   8014ac <fd_lookup>
  801806:	83 c4 08             	add    $0x8,%esp
  801809:	89 c2                	mov    %eax,%edx
  80180b:	85 c0                	test   %eax,%eax
  80180d:	78 6b                	js     80187a <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80180f:	83 ec 08             	sub    $0x8,%esp
  801812:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801815:	50                   	push   %eax
  801816:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801819:	ff 30                	pushl  (%eax)
  80181b:	e8 e2 fc ff ff       	call   801502 <dev_lookup>
  801820:	83 c4 10             	add    $0x10,%esp
  801823:	85 c0                	test   %eax,%eax
  801825:	78 4a                	js     801871 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801827:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80182a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80182e:	75 24                	jne    801854 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801830:	a1 08 40 80 00       	mov    0x804008,%eax
  801835:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80183b:	83 ec 04             	sub    $0x4,%esp
  80183e:	53                   	push   %ebx
  80183f:	50                   	push   %eax
  801840:	68 48 2c 80 00       	push   $0x802c48
  801845:	e8 97 ea ff ff       	call   8002e1 <cprintf>
		return -E_INVAL;
  80184a:	83 c4 10             	add    $0x10,%esp
  80184d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801852:	eb 26                	jmp    80187a <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801854:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801857:	8b 52 0c             	mov    0xc(%edx),%edx
  80185a:	85 d2                	test   %edx,%edx
  80185c:	74 17                	je     801875 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80185e:	83 ec 04             	sub    $0x4,%esp
  801861:	ff 75 10             	pushl  0x10(%ebp)
  801864:	ff 75 0c             	pushl  0xc(%ebp)
  801867:	50                   	push   %eax
  801868:	ff d2                	call   *%edx
  80186a:	89 c2                	mov    %eax,%edx
  80186c:	83 c4 10             	add    $0x10,%esp
  80186f:	eb 09                	jmp    80187a <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801871:	89 c2                	mov    %eax,%edx
  801873:	eb 05                	jmp    80187a <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801875:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80187a:	89 d0                	mov    %edx,%eax
  80187c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187f:	c9                   	leave  
  801880:	c3                   	ret    

00801881 <seek>:

int
seek(int fdnum, off_t offset)
{
  801881:	55                   	push   %ebp
  801882:	89 e5                	mov    %esp,%ebp
  801884:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801887:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80188a:	50                   	push   %eax
  80188b:	ff 75 08             	pushl  0x8(%ebp)
  80188e:	e8 19 fc ff ff       	call   8014ac <fd_lookup>
  801893:	83 c4 08             	add    $0x8,%esp
  801896:	85 c0                	test   %eax,%eax
  801898:	78 0e                	js     8018a8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80189a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80189d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018a0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018a8:	c9                   	leave  
  8018a9:	c3                   	ret    

008018aa <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018aa:	55                   	push   %ebp
  8018ab:	89 e5                	mov    %esp,%ebp
  8018ad:	53                   	push   %ebx
  8018ae:	83 ec 14             	sub    $0x14,%esp
  8018b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018b7:	50                   	push   %eax
  8018b8:	53                   	push   %ebx
  8018b9:	e8 ee fb ff ff       	call   8014ac <fd_lookup>
  8018be:	83 c4 08             	add    $0x8,%esp
  8018c1:	89 c2                	mov    %eax,%edx
  8018c3:	85 c0                	test   %eax,%eax
  8018c5:	78 68                	js     80192f <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018c7:	83 ec 08             	sub    $0x8,%esp
  8018ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018cd:	50                   	push   %eax
  8018ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d1:	ff 30                	pushl  (%eax)
  8018d3:	e8 2a fc ff ff       	call   801502 <dev_lookup>
  8018d8:	83 c4 10             	add    $0x10,%esp
  8018db:	85 c0                	test   %eax,%eax
  8018dd:	78 47                	js     801926 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018e6:	75 24                	jne    80190c <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018e8:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018ed:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8018f3:	83 ec 04             	sub    $0x4,%esp
  8018f6:	53                   	push   %ebx
  8018f7:	50                   	push   %eax
  8018f8:	68 08 2c 80 00       	push   $0x802c08
  8018fd:	e8 df e9 ff ff       	call   8002e1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801902:	83 c4 10             	add    $0x10,%esp
  801905:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80190a:	eb 23                	jmp    80192f <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  80190c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80190f:	8b 52 18             	mov    0x18(%edx),%edx
  801912:	85 d2                	test   %edx,%edx
  801914:	74 14                	je     80192a <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801916:	83 ec 08             	sub    $0x8,%esp
  801919:	ff 75 0c             	pushl  0xc(%ebp)
  80191c:	50                   	push   %eax
  80191d:	ff d2                	call   *%edx
  80191f:	89 c2                	mov    %eax,%edx
  801921:	83 c4 10             	add    $0x10,%esp
  801924:	eb 09                	jmp    80192f <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801926:	89 c2                	mov    %eax,%edx
  801928:	eb 05                	jmp    80192f <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80192a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80192f:	89 d0                	mov    %edx,%eax
  801931:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801934:	c9                   	leave  
  801935:	c3                   	ret    

00801936 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	53                   	push   %ebx
  80193a:	83 ec 14             	sub    $0x14,%esp
  80193d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801940:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801943:	50                   	push   %eax
  801944:	ff 75 08             	pushl  0x8(%ebp)
  801947:	e8 60 fb ff ff       	call   8014ac <fd_lookup>
  80194c:	83 c4 08             	add    $0x8,%esp
  80194f:	89 c2                	mov    %eax,%edx
  801951:	85 c0                	test   %eax,%eax
  801953:	78 58                	js     8019ad <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801955:	83 ec 08             	sub    $0x8,%esp
  801958:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80195b:	50                   	push   %eax
  80195c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80195f:	ff 30                	pushl  (%eax)
  801961:	e8 9c fb ff ff       	call   801502 <dev_lookup>
  801966:	83 c4 10             	add    $0x10,%esp
  801969:	85 c0                	test   %eax,%eax
  80196b:	78 37                	js     8019a4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80196d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801970:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801974:	74 32                	je     8019a8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801976:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801979:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801980:	00 00 00 
	stat->st_isdir = 0;
  801983:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80198a:	00 00 00 
	stat->st_dev = dev;
  80198d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801993:	83 ec 08             	sub    $0x8,%esp
  801996:	53                   	push   %ebx
  801997:	ff 75 f0             	pushl  -0x10(%ebp)
  80199a:	ff 50 14             	call   *0x14(%eax)
  80199d:	89 c2                	mov    %eax,%edx
  80199f:	83 c4 10             	add    $0x10,%esp
  8019a2:	eb 09                	jmp    8019ad <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019a4:	89 c2                	mov    %eax,%edx
  8019a6:	eb 05                	jmp    8019ad <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019a8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019ad:	89 d0                	mov    %edx,%eax
  8019af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b2:	c9                   	leave  
  8019b3:	c3                   	ret    

008019b4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	56                   	push   %esi
  8019b8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019b9:	83 ec 08             	sub    $0x8,%esp
  8019bc:	6a 00                	push   $0x0
  8019be:	ff 75 08             	pushl  0x8(%ebp)
  8019c1:	e8 e3 01 00 00       	call   801ba9 <open>
  8019c6:	89 c3                	mov    %eax,%ebx
  8019c8:	83 c4 10             	add    $0x10,%esp
  8019cb:	85 c0                	test   %eax,%eax
  8019cd:	78 1b                	js     8019ea <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019cf:	83 ec 08             	sub    $0x8,%esp
  8019d2:	ff 75 0c             	pushl  0xc(%ebp)
  8019d5:	50                   	push   %eax
  8019d6:	e8 5b ff ff ff       	call   801936 <fstat>
  8019db:	89 c6                	mov    %eax,%esi
	close(fd);
  8019dd:	89 1c 24             	mov    %ebx,(%esp)
  8019e0:	e8 f4 fb ff ff       	call   8015d9 <close>
	return r;
  8019e5:	83 c4 10             	add    $0x10,%esp
  8019e8:	89 f0                	mov    %esi,%eax
}
  8019ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ed:	5b                   	pop    %ebx
  8019ee:	5e                   	pop    %esi
  8019ef:	5d                   	pop    %ebp
  8019f0:	c3                   	ret    

008019f1 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019f1:	55                   	push   %ebp
  8019f2:	89 e5                	mov    %esp,%ebp
  8019f4:	56                   	push   %esi
  8019f5:	53                   	push   %ebx
  8019f6:	89 c6                	mov    %eax,%esi
  8019f8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019fa:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801a01:	75 12                	jne    801a15 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a03:	83 ec 0c             	sub    $0xc,%esp
  801a06:	6a 01                	push   $0x1
  801a08:	e8 a4 09 00 00       	call   8023b1 <ipc_find_env>
  801a0d:	a3 04 40 80 00       	mov    %eax,0x804004
  801a12:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a15:	6a 07                	push   $0x7
  801a17:	68 00 50 80 00       	push   $0x805000
  801a1c:	56                   	push   %esi
  801a1d:	ff 35 04 40 80 00    	pushl  0x804004
  801a23:	e8 27 09 00 00       	call   80234f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a28:	83 c4 0c             	add    $0xc,%esp
  801a2b:	6a 00                	push   $0x0
  801a2d:	53                   	push   %ebx
  801a2e:	6a 00                	push   $0x0
  801a30:	e8 9f 08 00 00       	call   8022d4 <ipc_recv>
}
  801a35:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a38:	5b                   	pop    %ebx
  801a39:	5e                   	pop    %esi
  801a3a:	5d                   	pop    %ebp
  801a3b:	c3                   	ret    

00801a3c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
  801a3f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a42:	8b 45 08             	mov    0x8(%ebp),%eax
  801a45:	8b 40 0c             	mov    0xc(%eax),%eax
  801a48:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a50:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a55:	ba 00 00 00 00       	mov    $0x0,%edx
  801a5a:	b8 02 00 00 00       	mov    $0x2,%eax
  801a5f:	e8 8d ff ff ff       	call   8019f1 <fsipc>
}
  801a64:	c9                   	leave  
  801a65:	c3                   	ret    

00801a66 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6f:	8b 40 0c             	mov    0xc(%eax),%eax
  801a72:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a77:	ba 00 00 00 00       	mov    $0x0,%edx
  801a7c:	b8 06 00 00 00       	mov    $0x6,%eax
  801a81:	e8 6b ff ff ff       	call   8019f1 <fsipc>
}
  801a86:	c9                   	leave  
  801a87:	c3                   	ret    

00801a88 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a88:	55                   	push   %ebp
  801a89:	89 e5                	mov    %esp,%ebp
  801a8b:	53                   	push   %ebx
  801a8c:	83 ec 04             	sub    $0x4,%esp
  801a8f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a92:	8b 45 08             	mov    0x8(%ebp),%eax
  801a95:	8b 40 0c             	mov    0xc(%eax),%eax
  801a98:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a9d:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa2:	b8 05 00 00 00       	mov    $0x5,%eax
  801aa7:	e8 45 ff ff ff       	call   8019f1 <fsipc>
  801aac:	85 c0                	test   %eax,%eax
  801aae:	78 2c                	js     801adc <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ab0:	83 ec 08             	sub    $0x8,%esp
  801ab3:	68 00 50 80 00       	push   $0x805000
  801ab8:	53                   	push   %ebx
  801ab9:	e8 a8 ed ff ff       	call   800866 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801abe:	a1 80 50 80 00       	mov    0x805080,%eax
  801ac3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ac9:	a1 84 50 80 00       	mov    0x805084,%eax
  801ace:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ad4:	83 c4 10             	add    $0x10,%esp
  801ad7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801adc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801adf:	c9                   	leave  
  801ae0:	c3                   	ret    

00801ae1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	83 ec 0c             	sub    $0xc,%esp
  801ae7:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801aea:	8b 55 08             	mov    0x8(%ebp),%edx
  801aed:	8b 52 0c             	mov    0xc(%edx),%edx
  801af0:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801af6:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801afb:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801b00:	0f 47 c2             	cmova  %edx,%eax
  801b03:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801b08:	50                   	push   %eax
  801b09:	ff 75 0c             	pushl  0xc(%ebp)
  801b0c:	68 08 50 80 00       	push   $0x805008
  801b11:	e8 e2 ee ff ff       	call   8009f8 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801b16:	ba 00 00 00 00       	mov    $0x0,%edx
  801b1b:	b8 04 00 00 00       	mov    $0x4,%eax
  801b20:	e8 cc fe ff ff       	call   8019f1 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801b25:	c9                   	leave  
  801b26:	c3                   	ret    

00801b27 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b27:	55                   	push   %ebp
  801b28:	89 e5                	mov    %esp,%ebp
  801b2a:	56                   	push   %esi
  801b2b:	53                   	push   %ebx
  801b2c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b32:	8b 40 0c             	mov    0xc(%eax),%eax
  801b35:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b3a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b40:	ba 00 00 00 00       	mov    $0x0,%edx
  801b45:	b8 03 00 00 00       	mov    $0x3,%eax
  801b4a:	e8 a2 fe ff ff       	call   8019f1 <fsipc>
  801b4f:	89 c3                	mov    %eax,%ebx
  801b51:	85 c0                	test   %eax,%eax
  801b53:	78 4b                	js     801ba0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b55:	39 c6                	cmp    %eax,%esi
  801b57:	73 16                	jae    801b6f <devfile_read+0x48>
  801b59:	68 78 2c 80 00       	push   $0x802c78
  801b5e:	68 7f 2c 80 00       	push   $0x802c7f
  801b63:	6a 7c                	push   $0x7c
  801b65:	68 94 2c 80 00       	push   $0x802c94
  801b6a:	e8 99 e6 ff ff       	call   800208 <_panic>
	assert(r <= PGSIZE);
  801b6f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b74:	7e 16                	jle    801b8c <devfile_read+0x65>
  801b76:	68 9f 2c 80 00       	push   $0x802c9f
  801b7b:	68 7f 2c 80 00       	push   $0x802c7f
  801b80:	6a 7d                	push   $0x7d
  801b82:	68 94 2c 80 00       	push   $0x802c94
  801b87:	e8 7c e6 ff ff       	call   800208 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b8c:	83 ec 04             	sub    $0x4,%esp
  801b8f:	50                   	push   %eax
  801b90:	68 00 50 80 00       	push   $0x805000
  801b95:	ff 75 0c             	pushl  0xc(%ebp)
  801b98:	e8 5b ee ff ff       	call   8009f8 <memmove>
	return r;
  801b9d:	83 c4 10             	add    $0x10,%esp
}
  801ba0:	89 d8                	mov    %ebx,%eax
  801ba2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ba5:	5b                   	pop    %ebx
  801ba6:	5e                   	pop    %esi
  801ba7:	5d                   	pop    %ebp
  801ba8:	c3                   	ret    

00801ba9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ba9:	55                   	push   %ebp
  801baa:	89 e5                	mov    %esp,%ebp
  801bac:	53                   	push   %ebx
  801bad:	83 ec 20             	sub    $0x20,%esp
  801bb0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bb3:	53                   	push   %ebx
  801bb4:	e8 74 ec ff ff       	call   80082d <strlen>
  801bb9:	83 c4 10             	add    $0x10,%esp
  801bbc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bc1:	7f 67                	jg     801c2a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bc3:	83 ec 0c             	sub    $0xc,%esp
  801bc6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bc9:	50                   	push   %eax
  801bca:	e8 8e f8 ff ff       	call   80145d <fd_alloc>
  801bcf:	83 c4 10             	add    $0x10,%esp
		return r;
  801bd2:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bd4:	85 c0                	test   %eax,%eax
  801bd6:	78 57                	js     801c2f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bd8:	83 ec 08             	sub    $0x8,%esp
  801bdb:	53                   	push   %ebx
  801bdc:	68 00 50 80 00       	push   $0x805000
  801be1:	e8 80 ec ff ff       	call   800866 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801be6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be9:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bf1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bf6:	e8 f6 fd ff ff       	call   8019f1 <fsipc>
  801bfb:	89 c3                	mov    %eax,%ebx
  801bfd:	83 c4 10             	add    $0x10,%esp
  801c00:	85 c0                	test   %eax,%eax
  801c02:	79 14                	jns    801c18 <open+0x6f>
		fd_close(fd, 0);
  801c04:	83 ec 08             	sub    $0x8,%esp
  801c07:	6a 00                	push   $0x0
  801c09:	ff 75 f4             	pushl  -0xc(%ebp)
  801c0c:	e8 47 f9 ff ff       	call   801558 <fd_close>
		return r;
  801c11:	83 c4 10             	add    $0x10,%esp
  801c14:	89 da                	mov    %ebx,%edx
  801c16:	eb 17                	jmp    801c2f <open+0x86>
	}

	return fd2num(fd);
  801c18:	83 ec 0c             	sub    $0xc,%esp
  801c1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c1e:	e8 13 f8 ff ff       	call   801436 <fd2num>
  801c23:	89 c2                	mov    %eax,%edx
  801c25:	83 c4 10             	add    $0x10,%esp
  801c28:	eb 05                	jmp    801c2f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c2a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c2f:	89 d0                	mov    %edx,%eax
  801c31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c34:	c9                   	leave  
  801c35:	c3                   	ret    

00801c36 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c36:	55                   	push   %ebp
  801c37:	89 e5                	mov    %esp,%ebp
  801c39:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c3c:	ba 00 00 00 00       	mov    $0x0,%edx
  801c41:	b8 08 00 00 00       	mov    $0x8,%eax
  801c46:	e8 a6 fd ff ff       	call   8019f1 <fsipc>
}
  801c4b:	c9                   	leave  
  801c4c:	c3                   	ret    

00801c4d <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801c4d:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801c51:	7e 37                	jle    801c8a <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801c53:	55                   	push   %ebp
  801c54:	89 e5                	mov    %esp,%ebp
  801c56:	53                   	push   %ebx
  801c57:	83 ec 08             	sub    $0x8,%esp
  801c5a:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801c5c:	ff 70 04             	pushl  0x4(%eax)
  801c5f:	8d 40 10             	lea    0x10(%eax),%eax
  801c62:	50                   	push   %eax
  801c63:	ff 33                	pushl  (%ebx)
  801c65:	e8 88 fb ff ff       	call   8017f2 <write>
		if (result > 0)
  801c6a:	83 c4 10             	add    $0x10,%esp
  801c6d:	85 c0                	test   %eax,%eax
  801c6f:	7e 03                	jle    801c74 <writebuf+0x27>
			b->result += result;
  801c71:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801c74:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c77:	74 0d                	je     801c86 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801c79:	85 c0                	test   %eax,%eax
  801c7b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c80:	0f 4f c2             	cmovg  %edx,%eax
  801c83:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801c86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c89:	c9                   	leave  
  801c8a:	f3 c3                	repz ret 

00801c8c <putch>:

static void
putch(int ch, void *thunk)
{
  801c8c:	55                   	push   %ebp
  801c8d:	89 e5                	mov    %esp,%ebp
  801c8f:	53                   	push   %ebx
  801c90:	83 ec 04             	sub    $0x4,%esp
  801c93:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801c96:	8b 53 04             	mov    0x4(%ebx),%edx
  801c99:	8d 42 01             	lea    0x1(%edx),%eax
  801c9c:	89 43 04             	mov    %eax,0x4(%ebx)
  801c9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ca2:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801ca6:	3d 00 01 00 00       	cmp    $0x100,%eax
  801cab:	75 0e                	jne    801cbb <putch+0x2f>
		writebuf(b);
  801cad:	89 d8                	mov    %ebx,%eax
  801caf:	e8 99 ff ff ff       	call   801c4d <writebuf>
		b->idx = 0;
  801cb4:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801cbb:	83 c4 04             	add    $0x4,%esp
  801cbe:	5b                   	pop    %ebx
  801cbf:	5d                   	pop    %ebp
  801cc0:	c3                   	ret    

00801cc1 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801cc1:	55                   	push   %ebp
  801cc2:	89 e5                	mov    %esp,%ebp
  801cc4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801cca:	8b 45 08             	mov    0x8(%ebp),%eax
  801ccd:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801cd3:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801cda:	00 00 00 
	b.result = 0;
  801cdd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801ce4:	00 00 00 
	b.error = 1;
  801ce7:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801cee:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801cf1:	ff 75 10             	pushl  0x10(%ebp)
  801cf4:	ff 75 0c             	pushl  0xc(%ebp)
  801cf7:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801cfd:	50                   	push   %eax
  801cfe:	68 8c 1c 80 00       	push   $0x801c8c
  801d03:	e8 10 e7 ff ff       	call   800418 <vprintfmt>
	if (b.idx > 0)
  801d08:	83 c4 10             	add    $0x10,%esp
  801d0b:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801d12:	7e 0b                	jle    801d1f <vfprintf+0x5e>
		writebuf(&b);
  801d14:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801d1a:	e8 2e ff ff ff       	call   801c4d <writebuf>

	return (b.result ? b.result : b.error);
  801d1f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801d25:	85 c0                	test   %eax,%eax
  801d27:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801d2e:	c9                   	leave  
  801d2f:	c3                   	ret    

00801d30 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801d30:	55                   	push   %ebp
  801d31:	89 e5                	mov    %esp,%ebp
  801d33:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801d36:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801d39:	50                   	push   %eax
  801d3a:	ff 75 0c             	pushl  0xc(%ebp)
  801d3d:	ff 75 08             	pushl  0x8(%ebp)
  801d40:	e8 7c ff ff ff       	call   801cc1 <vfprintf>
	va_end(ap);

	return cnt;
}
  801d45:	c9                   	leave  
  801d46:	c3                   	ret    

00801d47 <printf>:

int
printf(const char *fmt, ...)
{
  801d47:	55                   	push   %ebp
  801d48:	89 e5                	mov    %esp,%ebp
  801d4a:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801d4d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801d50:	50                   	push   %eax
  801d51:	ff 75 08             	pushl  0x8(%ebp)
  801d54:	6a 01                	push   $0x1
  801d56:	e8 66 ff ff ff       	call   801cc1 <vfprintf>
	va_end(ap);

	return cnt;
}
  801d5b:	c9                   	leave  
  801d5c:	c3                   	ret    

00801d5d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d5d:	55                   	push   %ebp
  801d5e:	89 e5                	mov    %esp,%ebp
  801d60:	56                   	push   %esi
  801d61:	53                   	push   %ebx
  801d62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d65:	83 ec 0c             	sub    $0xc,%esp
  801d68:	ff 75 08             	pushl  0x8(%ebp)
  801d6b:	e8 d6 f6 ff ff       	call   801446 <fd2data>
  801d70:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d72:	83 c4 08             	add    $0x8,%esp
  801d75:	68 ab 2c 80 00       	push   $0x802cab
  801d7a:	53                   	push   %ebx
  801d7b:	e8 e6 ea ff ff       	call   800866 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d80:	8b 46 04             	mov    0x4(%esi),%eax
  801d83:	2b 06                	sub    (%esi),%eax
  801d85:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d8b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d92:	00 00 00 
	stat->st_dev = &devpipe;
  801d95:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801d9c:	30 80 00 
	return 0;
}
  801d9f:	b8 00 00 00 00       	mov    $0x0,%eax
  801da4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801da7:	5b                   	pop    %ebx
  801da8:	5e                   	pop    %esi
  801da9:	5d                   	pop    %ebp
  801daa:	c3                   	ret    

00801dab <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801dab:	55                   	push   %ebp
  801dac:	89 e5                	mov    %esp,%ebp
  801dae:	53                   	push   %ebx
  801daf:	83 ec 0c             	sub    $0xc,%esp
  801db2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801db5:	53                   	push   %ebx
  801db6:	6a 00                	push   $0x0
  801db8:	e8 31 ef ff ff       	call   800cee <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801dbd:	89 1c 24             	mov    %ebx,(%esp)
  801dc0:	e8 81 f6 ff ff       	call   801446 <fd2data>
  801dc5:	83 c4 08             	add    $0x8,%esp
  801dc8:	50                   	push   %eax
  801dc9:	6a 00                	push   $0x0
  801dcb:	e8 1e ef ff ff       	call   800cee <sys_page_unmap>
}
  801dd0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dd3:	c9                   	leave  
  801dd4:	c3                   	ret    

00801dd5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801dd5:	55                   	push   %ebp
  801dd6:	89 e5                	mov    %esp,%ebp
  801dd8:	57                   	push   %edi
  801dd9:	56                   	push   %esi
  801dda:	53                   	push   %ebx
  801ddb:	83 ec 1c             	sub    $0x1c,%esp
  801dde:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801de1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801de3:	a1 08 40 80 00       	mov    0x804008,%eax
  801de8:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801dee:	83 ec 0c             	sub    $0xc,%esp
  801df1:	ff 75 e0             	pushl  -0x20(%ebp)
  801df4:	e8 fd 05 00 00       	call   8023f6 <pageref>
  801df9:	89 c3                	mov    %eax,%ebx
  801dfb:	89 3c 24             	mov    %edi,(%esp)
  801dfe:	e8 f3 05 00 00       	call   8023f6 <pageref>
  801e03:	83 c4 10             	add    $0x10,%esp
  801e06:	39 c3                	cmp    %eax,%ebx
  801e08:	0f 94 c1             	sete   %cl
  801e0b:	0f b6 c9             	movzbl %cl,%ecx
  801e0e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801e11:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801e17:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801e1d:	39 ce                	cmp    %ecx,%esi
  801e1f:	74 1e                	je     801e3f <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801e21:	39 c3                	cmp    %eax,%ebx
  801e23:	75 be                	jne    801de3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e25:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801e2b:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e2e:	50                   	push   %eax
  801e2f:	56                   	push   %esi
  801e30:	68 b2 2c 80 00       	push   $0x802cb2
  801e35:	e8 a7 e4 ff ff       	call   8002e1 <cprintf>
  801e3a:	83 c4 10             	add    $0x10,%esp
  801e3d:	eb a4                	jmp    801de3 <_pipeisclosed+0xe>
	}
}
  801e3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e45:	5b                   	pop    %ebx
  801e46:	5e                   	pop    %esi
  801e47:	5f                   	pop    %edi
  801e48:	5d                   	pop    %ebp
  801e49:	c3                   	ret    

00801e4a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e4a:	55                   	push   %ebp
  801e4b:	89 e5                	mov    %esp,%ebp
  801e4d:	57                   	push   %edi
  801e4e:	56                   	push   %esi
  801e4f:	53                   	push   %ebx
  801e50:	83 ec 28             	sub    $0x28,%esp
  801e53:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e56:	56                   	push   %esi
  801e57:	e8 ea f5 ff ff       	call   801446 <fd2data>
  801e5c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e5e:	83 c4 10             	add    $0x10,%esp
  801e61:	bf 00 00 00 00       	mov    $0x0,%edi
  801e66:	eb 4b                	jmp    801eb3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e68:	89 da                	mov    %ebx,%edx
  801e6a:	89 f0                	mov    %esi,%eax
  801e6c:	e8 64 ff ff ff       	call   801dd5 <_pipeisclosed>
  801e71:	85 c0                	test   %eax,%eax
  801e73:	75 48                	jne    801ebd <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e75:	e8 d0 ed ff ff       	call   800c4a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e7a:	8b 43 04             	mov    0x4(%ebx),%eax
  801e7d:	8b 0b                	mov    (%ebx),%ecx
  801e7f:	8d 51 20             	lea    0x20(%ecx),%edx
  801e82:	39 d0                	cmp    %edx,%eax
  801e84:	73 e2                	jae    801e68 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e89:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e8d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e90:	89 c2                	mov    %eax,%edx
  801e92:	c1 fa 1f             	sar    $0x1f,%edx
  801e95:	89 d1                	mov    %edx,%ecx
  801e97:	c1 e9 1b             	shr    $0x1b,%ecx
  801e9a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e9d:	83 e2 1f             	and    $0x1f,%edx
  801ea0:	29 ca                	sub    %ecx,%edx
  801ea2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ea6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801eaa:	83 c0 01             	add    $0x1,%eax
  801ead:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801eb0:	83 c7 01             	add    $0x1,%edi
  801eb3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801eb6:	75 c2                	jne    801e7a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801eb8:	8b 45 10             	mov    0x10(%ebp),%eax
  801ebb:	eb 05                	jmp    801ec2 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ebd:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ec2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ec5:	5b                   	pop    %ebx
  801ec6:	5e                   	pop    %esi
  801ec7:	5f                   	pop    %edi
  801ec8:	5d                   	pop    %ebp
  801ec9:	c3                   	ret    

00801eca <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801eca:	55                   	push   %ebp
  801ecb:	89 e5                	mov    %esp,%ebp
  801ecd:	57                   	push   %edi
  801ece:	56                   	push   %esi
  801ecf:	53                   	push   %ebx
  801ed0:	83 ec 18             	sub    $0x18,%esp
  801ed3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ed6:	57                   	push   %edi
  801ed7:	e8 6a f5 ff ff       	call   801446 <fd2data>
  801edc:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ede:	83 c4 10             	add    $0x10,%esp
  801ee1:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ee6:	eb 3d                	jmp    801f25 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ee8:	85 db                	test   %ebx,%ebx
  801eea:	74 04                	je     801ef0 <devpipe_read+0x26>
				return i;
  801eec:	89 d8                	mov    %ebx,%eax
  801eee:	eb 44                	jmp    801f34 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ef0:	89 f2                	mov    %esi,%edx
  801ef2:	89 f8                	mov    %edi,%eax
  801ef4:	e8 dc fe ff ff       	call   801dd5 <_pipeisclosed>
  801ef9:	85 c0                	test   %eax,%eax
  801efb:	75 32                	jne    801f2f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801efd:	e8 48 ed ff ff       	call   800c4a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f02:	8b 06                	mov    (%esi),%eax
  801f04:	3b 46 04             	cmp    0x4(%esi),%eax
  801f07:	74 df                	je     801ee8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f09:	99                   	cltd   
  801f0a:	c1 ea 1b             	shr    $0x1b,%edx
  801f0d:	01 d0                	add    %edx,%eax
  801f0f:	83 e0 1f             	and    $0x1f,%eax
  801f12:	29 d0                	sub    %edx,%eax
  801f14:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801f19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f1c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801f1f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f22:	83 c3 01             	add    $0x1,%ebx
  801f25:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f28:	75 d8                	jne    801f02 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f2a:	8b 45 10             	mov    0x10(%ebp),%eax
  801f2d:	eb 05                	jmp    801f34 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f2f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f37:	5b                   	pop    %ebx
  801f38:	5e                   	pop    %esi
  801f39:	5f                   	pop    %edi
  801f3a:	5d                   	pop    %ebp
  801f3b:	c3                   	ret    

00801f3c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f3c:	55                   	push   %ebp
  801f3d:	89 e5                	mov    %esp,%ebp
  801f3f:	56                   	push   %esi
  801f40:	53                   	push   %ebx
  801f41:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f47:	50                   	push   %eax
  801f48:	e8 10 f5 ff ff       	call   80145d <fd_alloc>
  801f4d:	83 c4 10             	add    $0x10,%esp
  801f50:	89 c2                	mov    %eax,%edx
  801f52:	85 c0                	test   %eax,%eax
  801f54:	0f 88 2c 01 00 00    	js     802086 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f5a:	83 ec 04             	sub    $0x4,%esp
  801f5d:	68 07 04 00 00       	push   $0x407
  801f62:	ff 75 f4             	pushl  -0xc(%ebp)
  801f65:	6a 00                	push   $0x0
  801f67:	e8 fd ec ff ff       	call   800c69 <sys_page_alloc>
  801f6c:	83 c4 10             	add    $0x10,%esp
  801f6f:	89 c2                	mov    %eax,%edx
  801f71:	85 c0                	test   %eax,%eax
  801f73:	0f 88 0d 01 00 00    	js     802086 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f79:	83 ec 0c             	sub    $0xc,%esp
  801f7c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f7f:	50                   	push   %eax
  801f80:	e8 d8 f4 ff ff       	call   80145d <fd_alloc>
  801f85:	89 c3                	mov    %eax,%ebx
  801f87:	83 c4 10             	add    $0x10,%esp
  801f8a:	85 c0                	test   %eax,%eax
  801f8c:	0f 88 e2 00 00 00    	js     802074 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f92:	83 ec 04             	sub    $0x4,%esp
  801f95:	68 07 04 00 00       	push   $0x407
  801f9a:	ff 75 f0             	pushl  -0x10(%ebp)
  801f9d:	6a 00                	push   $0x0
  801f9f:	e8 c5 ec ff ff       	call   800c69 <sys_page_alloc>
  801fa4:	89 c3                	mov    %eax,%ebx
  801fa6:	83 c4 10             	add    $0x10,%esp
  801fa9:	85 c0                	test   %eax,%eax
  801fab:	0f 88 c3 00 00 00    	js     802074 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801fb1:	83 ec 0c             	sub    $0xc,%esp
  801fb4:	ff 75 f4             	pushl  -0xc(%ebp)
  801fb7:	e8 8a f4 ff ff       	call   801446 <fd2data>
  801fbc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fbe:	83 c4 0c             	add    $0xc,%esp
  801fc1:	68 07 04 00 00       	push   $0x407
  801fc6:	50                   	push   %eax
  801fc7:	6a 00                	push   $0x0
  801fc9:	e8 9b ec ff ff       	call   800c69 <sys_page_alloc>
  801fce:	89 c3                	mov    %eax,%ebx
  801fd0:	83 c4 10             	add    $0x10,%esp
  801fd3:	85 c0                	test   %eax,%eax
  801fd5:	0f 88 89 00 00 00    	js     802064 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fdb:	83 ec 0c             	sub    $0xc,%esp
  801fde:	ff 75 f0             	pushl  -0x10(%ebp)
  801fe1:	e8 60 f4 ff ff       	call   801446 <fd2data>
  801fe6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801fed:	50                   	push   %eax
  801fee:	6a 00                	push   $0x0
  801ff0:	56                   	push   %esi
  801ff1:	6a 00                	push   $0x0
  801ff3:	e8 b4 ec ff ff       	call   800cac <sys_page_map>
  801ff8:	89 c3                	mov    %eax,%ebx
  801ffa:	83 c4 20             	add    $0x20,%esp
  801ffd:	85 c0                	test   %eax,%eax
  801fff:	78 55                	js     802056 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802001:	8b 15 24 30 80 00    	mov    0x803024,%edx
  802007:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80200c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802016:	8b 15 24 30 80 00    	mov    0x803024,%edx
  80201c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80201f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802021:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802024:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80202b:	83 ec 0c             	sub    $0xc,%esp
  80202e:	ff 75 f4             	pushl  -0xc(%ebp)
  802031:	e8 00 f4 ff ff       	call   801436 <fd2num>
  802036:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802039:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80203b:	83 c4 04             	add    $0x4,%esp
  80203e:	ff 75 f0             	pushl  -0x10(%ebp)
  802041:	e8 f0 f3 ff ff       	call   801436 <fd2num>
  802046:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802049:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80204c:	83 c4 10             	add    $0x10,%esp
  80204f:	ba 00 00 00 00       	mov    $0x0,%edx
  802054:	eb 30                	jmp    802086 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802056:	83 ec 08             	sub    $0x8,%esp
  802059:	56                   	push   %esi
  80205a:	6a 00                	push   $0x0
  80205c:	e8 8d ec ff ff       	call   800cee <sys_page_unmap>
  802061:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802064:	83 ec 08             	sub    $0x8,%esp
  802067:	ff 75 f0             	pushl  -0x10(%ebp)
  80206a:	6a 00                	push   $0x0
  80206c:	e8 7d ec ff ff       	call   800cee <sys_page_unmap>
  802071:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802074:	83 ec 08             	sub    $0x8,%esp
  802077:	ff 75 f4             	pushl  -0xc(%ebp)
  80207a:	6a 00                	push   $0x0
  80207c:	e8 6d ec ff ff       	call   800cee <sys_page_unmap>
  802081:	83 c4 10             	add    $0x10,%esp
  802084:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802086:	89 d0                	mov    %edx,%eax
  802088:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80208b:	5b                   	pop    %ebx
  80208c:	5e                   	pop    %esi
  80208d:	5d                   	pop    %ebp
  80208e:	c3                   	ret    

0080208f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80208f:	55                   	push   %ebp
  802090:	89 e5                	mov    %esp,%ebp
  802092:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802095:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802098:	50                   	push   %eax
  802099:	ff 75 08             	pushl  0x8(%ebp)
  80209c:	e8 0b f4 ff ff       	call   8014ac <fd_lookup>
  8020a1:	83 c4 10             	add    $0x10,%esp
  8020a4:	85 c0                	test   %eax,%eax
  8020a6:	78 18                	js     8020c0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8020a8:	83 ec 0c             	sub    $0xc,%esp
  8020ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ae:	e8 93 f3 ff ff       	call   801446 <fd2data>
	return _pipeisclosed(fd, p);
  8020b3:	89 c2                	mov    %eax,%edx
  8020b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020b8:	e8 18 fd ff ff       	call   801dd5 <_pipeisclosed>
  8020bd:	83 c4 10             	add    $0x10,%esp
}
  8020c0:	c9                   	leave  
  8020c1:	c3                   	ret    

008020c2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8020c2:	55                   	push   %ebp
  8020c3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8020c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8020ca:	5d                   	pop    %ebp
  8020cb:	c3                   	ret    

008020cc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8020cc:	55                   	push   %ebp
  8020cd:	89 e5                	mov    %esp,%ebp
  8020cf:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8020d2:	68 ca 2c 80 00       	push   $0x802cca
  8020d7:	ff 75 0c             	pushl  0xc(%ebp)
  8020da:	e8 87 e7 ff ff       	call   800866 <strcpy>
	return 0;
}
  8020df:	b8 00 00 00 00       	mov    $0x0,%eax
  8020e4:	c9                   	leave  
  8020e5:	c3                   	ret    

008020e6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020e6:	55                   	push   %ebp
  8020e7:	89 e5                	mov    %esp,%ebp
  8020e9:	57                   	push   %edi
  8020ea:	56                   	push   %esi
  8020eb:	53                   	push   %ebx
  8020ec:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020f2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020f7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020fd:	eb 2d                	jmp    80212c <devcons_write+0x46>
		m = n - tot;
  8020ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802102:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802104:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802107:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80210c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80210f:	83 ec 04             	sub    $0x4,%esp
  802112:	53                   	push   %ebx
  802113:	03 45 0c             	add    0xc(%ebp),%eax
  802116:	50                   	push   %eax
  802117:	57                   	push   %edi
  802118:	e8 db e8 ff ff       	call   8009f8 <memmove>
		sys_cputs(buf, m);
  80211d:	83 c4 08             	add    $0x8,%esp
  802120:	53                   	push   %ebx
  802121:	57                   	push   %edi
  802122:	e8 86 ea ff ff       	call   800bad <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802127:	01 de                	add    %ebx,%esi
  802129:	83 c4 10             	add    $0x10,%esp
  80212c:	89 f0                	mov    %esi,%eax
  80212e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802131:	72 cc                	jb     8020ff <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802133:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802136:	5b                   	pop    %ebx
  802137:	5e                   	pop    %esi
  802138:	5f                   	pop    %edi
  802139:	5d                   	pop    %ebp
  80213a:	c3                   	ret    

0080213b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80213b:	55                   	push   %ebp
  80213c:	89 e5                	mov    %esp,%ebp
  80213e:	83 ec 08             	sub    $0x8,%esp
  802141:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802146:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80214a:	74 2a                	je     802176 <devcons_read+0x3b>
  80214c:	eb 05                	jmp    802153 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80214e:	e8 f7 ea ff ff       	call   800c4a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802153:	e8 73 ea ff ff       	call   800bcb <sys_cgetc>
  802158:	85 c0                	test   %eax,%eax
  80215a:	74 f2                	je     80214e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80215c:	85 c0                	test   %eax,%eax
  80215e:	78 16                	js     802176 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802160:	83 f8 04             	cmp    $0x4,%eax
  802163:	74 0c                	je     802171 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802165:	8b 55 0c             	mov    0xc(%ebp),%edx
  802168:	88 02                	mov    %al,(%edx)
	return 1;
  80216a:	b8 01 00 00 00       	mov    $0x1,%eax
  80216f:	eb 05                	jmp    802176 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802171:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802176:	c9                   	leave  
  802177:	c3                   	ret    

00802178 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802178:	55                   	push   %ebp
  802179:	89 e5                	mov    %esp,%ebp
  80217b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80217e:	8b 45 08             	mov    0x8(%ebp),%eax
  802181:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802184:	6a 01                	push   $0x1
  802186:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802189:	50                   	push   %eax
  80218a:	e8 1e ea ff ff       	call   800bad <sys_cputs>
}
  80218f:	83 c4 10             	add    $0x10,%esp
  802192:	c9                   	leave  
  802193:	c3                   	ret    

00802194 <getchar>:

int
getchar(void)
{
  802194:	55                   	push   %ebp
  802195:	89 e5                	mov    %esp,%ebp
  802197:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80219a:	6a 01                	push   $0x1
  80219c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80219f:	50                   	push   %eax
  8021a0:	6a 00                	push   $0x0
  8021a2:	e8 6e f5 ff ff       	call   801715 <read>
	if (r < 0)
  8021a7:	83 c4 10             	add    $0x10,%esp
  8021aa:	85 c0                	test   %eax,%eax
  8021ac:	78 0f                	js     8021bd <getchar+0x29>
		return r;
	if (r < 1)
  8021ae:	85 c0                	test   %eax,%eax
  8021b0:	7e 06                	jle    8021b8 <getchar+0x24>
		return -E_EOF;
	return c;
  8021b2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8021b6:	eb 05                	jmp    8021bd <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8021b8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8021bd:	c9                   	leave  
  8021be:	c3                   	ret    

008021bf <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8021bf:	55                   	push   %ebp
  8021c0:	89 e5                	mov    %esp,%ebp
  8021c2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021c8:	50                   	push   %eax
  8021c9:	ff 75 08             	pushl  0x8(%ebp)
  8021cc:	e8 db f2 ff ff       	call   8014ac <fd_lookup>
  8021d1:	83 c4 10             	add    $0x10,%esp
  8021d4:	85 c0                	test   %eax,%eax
  8021d6:	78 11                	js     8021e9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8021d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021db:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8021e1:	39 10                	cmp    %edx,(%eax)
  8021e3:	0f 94 c0             	sete   %al
  8021e6:	0f b6 c0             	movzbl %al,%eax
}
  8021e9:	c9                   	leave  
  8021ea:	c3                   	ret    

008021eb <opencons>:

int
opencons(void)
{
  8021eb:	55                   	push   %ebp
  8021ec:	89 e5                	mov    %esp,%ebp
  8021ee:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021f4:	50                   	push   %eax
  8021f5:	e8 63 f2 ff ff       	call   80145d <fd_alloc>
  8021fa:	83 c4 10             	add    $0x10,%esp
		return r;
  8021fd:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021ff:	85 c0                	test   %eax,%eax
  802201:	78 3e                	js     802241 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802203:	83 ec 04             	sub    $0x4,%esp
  802206:	68 07 04 00 00       	push   $0x407
  80220b:	ff 75 f4             	pushl  -0xc(%ebp)
  80220e:	6a 00                	push   $0x0
  802210:	e8 54 ea ff ff       	call   800c69 <sys_page_alloc>
  802215:	83 c4 10             	add    $0x10,%esp
		return r;
  802218:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80221a:	85 c0                	test   %eax,%eax
  80221c:	78 23                	js     802241 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80221e:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802224:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802227:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802229:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80222c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802233:	83 ec 0c             	sub    $0xc,%esp
  802236:	50                   	push   %eax
  802237:	e8 fa f1 ff ff       	call   801436 <fd2num>
  80223c:	89 c2                	mov    %eax,%edx
  80223e:	83 c4 10             	add    $0x10,%esp
}
  802241:	89 d0                	mov    %edx,%eax
  802243:	c9                   	leave  
  802244:	c3                   	ret    

00802245 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802245:	55                   	push   %ebp
  802246:	89 e5                	mov    %esp,%ebp
  802248:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80224b:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802252:	75 2a                	jne    80227e <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802254:	83 ec 04             	sub    $0x4,%esp
  802257:	6a 07                	push   $0x7
  802259:	68 00 f0 bf ee       	push   $0xeebff000
  80225e:	6a 00                	push   $0x0
  802260:	e8 04 ea ff ff       	call   800c69 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802265:	83 c4 10             	add    $0x10,%esp
  802268:	85 c0                	test   %eax,%eax
  80226a:	79 12                	jns    80227e <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80226c:	50                   	push   %eax
  80226d:	68 58 2b 80 00       	push   $0x802b58
  802272:	6a 23                	push   $0x23
  802274:	68 d6 2c 80 00       	push   $0x802cd6
  802279:	e8 8a df ff ff       	call   800208 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80227e:	8b 45 08             	mov    0x8(%ebp),%eax
  802281:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802286:	83 ec 08             	sub    $0x8,%esp
  802289:	68 b0 22 80 00       	push   $0x8022b0
  80228e:	6a 00                	push   $0x0
  802290:	e8 1f eb ff ff       	call   800db4 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802295:	83 c4 10             	add    $0x10,%esp
  802298:	85 c0                	test   %eax,%eax
  80229a:	79 12                	jns    8022ae <set_pgfault_handler+0x69>
		panic("%e\n", r);
  80229c:	50                   	push   %eax
  80229d:	68 58 2b 80 00       	push   $0x802b58
  8022a2:	6a 2c                	push   $0x2c
  8022a4:	68 d6 2c 80 00       	push   $0x802cd6
  8022a9:	e8 5a df ff ff       	call   800208 <_panic>
	}
}
  8022ae:	c9                   	leave  
  8022af:	c3                   	ret    

008022b0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8022b0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8022b1:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8022b6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8022b8:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8022bb:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8022bf:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8022c4:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8022c8:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8022ca:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8022cd:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8022ce:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8022d1:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8022d2:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8022d3:	c3                   	ret    

008022d4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022d4:	55                   	push   %ebp
  8022d5:	89 e5                	mov    %esp,%ebp
  8022d7:	56                   	push   %esi
  8022d8:	53                   	push   %ebx
  8022d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8022dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022df:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8022e2:	85 c0                	test   %eax,%eax
  8022e4:	75 12                	jne    8022f8 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8022e6:	83 ec 0c             	sub    $0xc,%esp
  8022e9:	68 00 00 c0 ee       	push   $0xeec00000
  8022ee:	e8 26 eb ff ff       	call   800e19 <sys_ipc_recv>
  8022f3:	83 c4 10             	add    $0x10,%esp
  8022f6:	eb 0c                	jmp    802304 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8022f8:	83 ec 0c             	sub    $0xc,%esp
  8022fb:	50                   	push   %eax
  8022fc:	e8 18 eb ff ff       	call   800e19 <sys_ipc_recv>
  802301:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802304:	85 f6                	test   %esi,%esi
  802306:	0f 95 c1             	setne  %cl
  802309:	85 db                	test   %ebx,%ebx
  80230b:	0f 95 c2             	setne  %dl
  80230e:	84 d1                	test   %dl,%cl
  802310:	74 09                	je     80231b <ipc_recv+0x47>
  802312:	89 c2                	mov    %eax,%edx
  802314:	c1 ea 1f             	shr    $0x1f,%edx
  802317:	84 d2                	test   %dl,%dl
  802319:	75 2d                	jne    802348 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80231b:	85 f6                	test   %esi,%esi
  80231d:	74 0d                	je     80232c <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80231f:	a1 08 40 80 00       	mov    0x804008,%eax
  802324:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  80232a:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80232c:	85 db                	test   %ebx,%ebx
  80232e:	74 0d                	je     80233d <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802330:	a1 08 40 80 00       	mov    0x804008,%eax
  802335:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  80233b:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80233d:	a1 08 40 80 00       	mov    0x804008,%eax
  802342:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  802348:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80234b:	5b                   	pop    %ebx
  80234c:	5e                   	pop    %esi
  80234d:	5d                   	pop    %ebp
  80234e:	c3                   	ret    

0080234f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80234f:	55                   	push   %ebp
  802350:	89 e5                	mov    %esp,%ebp
  802352:	57                   	push   %edi
  802353:	56                   	push   %esi
  802354:	53                   	push   %ebx
  802355:	83 ec 0c             	sub    $0xc,%esp
  802358:	8b 7d 08             	mov    0x8(%ebp),%edi
  80235b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80235e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802361:	85 db                	test   %ebx,%ebx
  802363:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802368:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80236b:	ff 75 14             	pushl  0x14(%ebp)
  80236e:	53                   	push   %ebx
  80236f:	56                   	push   %esi
  802370:	57                   	push   %edi
  802371:	e8 80 ea ff ff       	call   800df6 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802376:	89 c2                	mov    %eax,%edx
  802378:	c1 ea 1f             	shr    $0x1f,%edx
  80237b:	83 c4 10             	add    $0x10,%esp
  80237e:	84 d2                	test   %dl,%dl
  802380:	74 17                	je     802399 <ipc_send+0x4a>
  802382:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802385:	74 12                	je     802399 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802387:	50                   	push   %eax
  802388:	68 e4 2c 80 00       	push   $0x802ce4
  80238d:	6a 47                	push   $0x47
  80238f:	68 f2 2c 80 00       	push   $0x802cf2
  802394:	e8 6f de ff ff       	call   800208 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802399:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80239c:	75 07                	jne    8023a5 <ipc_send+0x56>
			sys_yield();
  80239e:	e8 a7 e8 ff ff       	call   800c4a <sys_yield>
  8023a3:	eb c6                	jmp    80236b <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8023a5:	85 c0                	test   %eax,%eax
  8023a7:	75 c2                	jne    80236b <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8023a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023ac:	5b                   	pop    %ebx
  8023ad:	5e                   	pop    %esi
  8023ae:	5f                   	pop    %edi
  8023af:	5d                   	pop    %ebp
  8023b0:	c3                   	ret    

008023b1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023b1:	55                   	push   %ebp
  8023b2:	89 e5                	mov    %esp,%ebp
  8023b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8023b7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8023bc:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  8023c2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8023c8:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  8023ce:	39 ca                	cmp    %ecx,%edx
  8023d0:	75 13                	jne    8023e5 <ipc_find_env+0x34>
			return envs[i].env_id;
  8023d2:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8023d8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8023dd:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8023e3:	eb 0f                	jmp    8023f4 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023e5:	83 c0 01             	add    $0x1,%eax
  8023e8:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023ed:	75 cd                	jne    8023bc <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8023ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023f4:	5d                   	pop    %ebp
  8023f5:	c3                   	ret    

008023f6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023f6:	55                   	push   %ebp
  8023f7:	89 e5                	mov    %esp,%ebp
  8023f9:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023fc:	89 d0                	mov    %edx,%eax
  8023fe:	c1 e8 16             	shr    $0x16,%eax
  802401:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802408:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80240d:	f6 c1 01             	test   $0x1,%cl
  802410:	74 1d                	je     80242f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802412:	c1 ea 0c             	shr    $0xc,%edx
  802415:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80241c:	f6 c2 01             	test   $0x1,%dl
  80241f:	74 0e                	je     80242f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802421:	c1 ea 0c             	shr    $0xc,%edx
  802424:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80242b:	ef 
  80242c:	0f b7 c0             	movzwl %ax,%eax
}
  80242f:	5d                   	pop    %ebp
  802430:	c3                   	ret    
  802431:	66 90                	xchg   %ax,%ax
  802433:	66 90                	xchg   %ax,%ax
  802435:	66 90                	xchg   %ax,%ax
  802437:	66 90                	xchg   %ax,%ax
  802439:	66 90                	xchg   %ax,%ax
  80243b:	66 90                	xchg   %ax,%ax
  80243d:	66 90                	xchg   %ax,%ax
  80243f:	90                   	nop

00802440 <__udivdi3>:
  802440:	55                   	push   %ebp
  802441:	57                   	push   %edi
  802442:	56                   	push   %esi
  802443:	53                   	push   %ebx
  802444:	83 ec 1c             	sub    $0x1c,%esp
  802447:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80244b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80244f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802453:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802457:	85 f6                	test   %esi,%esi
  802459:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80245d:	89 ca                	mov    %ecx,%edx
  80245f:	89 f8                	mov    %edi,%eax
  802461:	75 3d                	jne    8024a0 <__udivdi3+0x60>
  802463:	39 cf                	cmp    %ecx,%edi
  802465:	0f 87 c5 00 00 00    	ja     802530 <__udivdi3+0xf0>
  80246b:	85 ff                	test   %edi,%edi
  80246d:	89 fd                	mov    %edi,%ebp
  80246f:	75 0b                	jne    80247c <__udivdi3+0x3c>
  802471:	b8 01 00 00 00       	mov    $0x1,%eax
  802476:	31 d2                	xor    %edx,%edx
  802478:	f7 f7                	div    %edi
  80247a:	89 c5                	mov    %eax,%ebp
  80247c:	89 c8                	mov    %ecx,%eax
  80247e:	31 d2                	xor    %edx,%edx
  802480:	f7 f5                	div    %ebp
  802482:	89 c1                	mov    %eax,%ecx
  802484:	89 d8                	mov    %ebx,%eax
  802486:	89 cf                	mov    %ecx,%edi
  802488:	f7 f5                	div    %ebp
  80248a:	89 c3                	mov    %eax,%ebx
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
  8024a0:	39 ce                	cmp    %ecx,%esi
  8024a2:	77 74                	ja     802518 <__udivdi3+0xd8>
  8024a4:	0f bd fe             	bsr    %esi,%edi
  8024a7:	83 f7 1f             	xor    $0x1f,%edi
  8024aa:	0f 84 98 00 00 00    	je     802548 <__udivdi3+0x108>
  8024b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8024b5:	89 f9                	mov    %edi,%ecx
  8024b7:	89 c5                	mov    %eax,%ebp
  8024b9:	29 fb                	sub    %edi,%ebx
  8024bb:	d3 e6                	shl    %cl,%esi
  8024bd:	89 d9                	mov    %ebx,%ecx
  8024bf:	d3 ed                	shr    %cl,%ebp
  8024c1:	89 f9                	mov    %edi,%ecx
  8024c3:	d3 e0                	shl    %cl,%eax
  8024c5:	09 ee                	or     %ebp,%esi
  8024c7:	89 d9                	mov    %ebx,%ecx
  8024c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024cd:	89 d5                	mov    %edx,%ebp
  8024cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024d3:	d3 ed                	shr    %cl,%ebp
  8024d5:	89 f9                	mov    %edi,%ecx
  8024d7:	d3 e2                	shl    %cl,%edx
  8024d9:	89 d9                	mov    %ebx,%ecx
  8024db:	d3 e8                	shr    %cl,%eax
  8024dd:	09 c2                	or     %eax,%edx
  8024df:	89 d0                	mov    %edx,%eax
  8024e1:	89 ea                	mov    %ebp,%edx
  8024e3:	f7 f6                	div    %esi
  8024e5:	89 d5                	mov    %edx,%ebp
  8024e7:	89 c3                	mov    %eax,%ebx
  8024e9:	f7 64 24 0c          	mull   0xc(%esp)
  8024ed:	39 d5                	cmp    %edx,%ebp
  8024ef:	72 10                	jb     802501 <__udivdi3+0xc1>
  8024f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8024f5:	89 f9                	mov    %edi,%ecx
  8024f7:	d3 e6                	shl    %cl,%esi
  8024f9:	39 c6                	cmp    %eax,%esi
  8024fb:	73 07                	jae    802504 <__udivdi3+0xc4>
  8024fd:	39 d5                	cmp    %edx,%ebp
  8024ff:	75 03                	jne    802504 <__udivdi3+0xc4>
  802501:	83 eb 01             	sub    $0x1,%ebx
  802504:	31 ff                	xor    %edi,%edi
  802506:	89 d8                	mov    %ebx,%eax
  802508:	89 fa                	mov    %edi,%edx
  80250a:	83 c4 1c             	add    $0x1c,%esp
  80250d:	5b                   	pop    %ebx
  80250e:	5e                   	pop    %esi
  80250f:	5f                   	pop    %edi
  802510:	5d                   	pop    %ebp
  802511:	c3                   	ret    
  802512:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802518:	31 ff                	xor    %edi,%edi
  80251a:	31 db                	xor    %ebx,%ebx
  80251c:	89 d8                	mov    %ebx,%eax
  80251e:	89 fa                	mov    %edi,%edx
  802520:	83 c4 1c             	add    $0x1c,%esp
  802523:	5b                   	pop    %ebx
  802524:	5e                   	pop    %esi
  802525:	5f                   	pop    %edi
  802526:	5d                   	pop    %ebp
  802527:	c3                   	ret    
  802528:	90                   	nop
  802529:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802530:	89 d8                	mov    %ebx,%eax
  802532:	f7 f7                	div    %edi
  802534:	31 ff                	xor    %edi,%edi
  802536:	89 c3                	mov    %eax,%ebx
  802538:	89 d8                	mov    %ebx,%eax
  80253a:	89 fa                	mov    %edi,%edx
  80253c:	83 c4 1c             	add    $0x1c,%esp
  80253f:	5b                   	pop    %ebx
  802540:	5e                   	pop    %esi
  802541:	5f                   	pop    %edi
  802542:	5d                   	pop    %ebp
  802543:	c3                   	ret    
  802544:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802548:	39 ce                	cmp    %ecx,%esi
  80254a:	72 0c                	jb     802558 <__udivdi3+0x118>
  80254c:	31 db                	xor    %ebx,%ebx
  80254e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802552:	0f 87 34 ff ff ff    	ja     80248c <__udivdi3+0x4c>
  802558:	bb 01 00 00 00       	mov    $0x1,%ebx
  80255d:	e9 2a ff ff ff       	jmp    80248c <__udivdi3+0x4c>
  802562:	66 90                	xchg   %ax,%ax
  802564:	66 90                	xchg   %ax,%ax
  802566:	66 90                	xchg   %ax,%ax
  802568:	66 90                	xchg   %ax,%ax
  80256a:	66 90                	xchg   %ax,%ax
  80256c:	66 90                	xchg   %ax,%ax
  80256e:	66 90                	xchg   %ax,%ax

00802570 <__umoddi3>:
  802570:	55                   	push   %ebp
  802571:	57                   	push   %edi
  802572:	56                   	push   %esi
  802573:	53                   	push   %ebx
  802574:	83 ec 1c             	sub    $0x1c,%esp
  802577:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80257b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80257f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802583:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802587:	85 d2                	test   %edx,%edx
  802589:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80258d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802591:	89 f3                	mov    %esi,%ebx
  802593:	89 3c 24             	mov    %edi,(%esp)
  802596:	89 74 24 04          	mov    %esi,0x4(%esp)
  80259a:	75 1c                	jne    8025b8 <__umoddi3+0x48>
  80259c:	39 f7                	cmp    %esi,%edi
  80259e:	76 50                	jbe    8025f0 <__umoddi3+0x80>
  8025a0:	89 c8                	mov    %ecx,%eax
  8025a2:	89 f2                	mov    %esi,%edx
  8025a4:	f7 f7                	div    %edi
  8025a6:	89 d0                	mov    %edx,%eax
  8025a8:	31 d2                	xor    %edx,%edx
  8025aa:	83 c4 1c             	add    $0x1c,%esp
  8025ad:	5b                   	pop    %ebx
  8025ae:	5e                   	pop    %esi
  8025af:	5f                   	pop    %edi
  8025b0:	5d                   	pop    %ebp
  8025b1:	c3                   	ret    
  8025b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025b8:	39 f2                	cmp    %esi,%edx
  8025ba:	89 d0                	mov    %edx,%eax
  8025bc:	77 52                	ja     802610 <__umoddi3+0xa0>
  8025be:	0f bd ea             	bsr    %edx,%ebp
  8025c1:	83 f5 1f             	xor    $0x1f,%ebp
  8025c4:	75 5a                	jne    802620 <__umoddi3+0xb0>
  8025c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8025ca:	0f 82 e0 00 00 00    	jb     8026b0 <__umoddi3+0x140>
  8025d0:	39 0c 24             	cmp    %ecx,(%esp)
  8025d3:	0f 86 d7 00 00 00    	jbe    8026b0 <__umoddi3+0x140>
  8025d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025e1:	83 c4 1c             	add    $0x1c,%esp
  8025e4:	5b                   	pop    %ebx
  8025e5:	5e                   	pop    %esi
  8025e6:	5f                   	pop    %edi
  8025e7:	5d                   	pop    %ebp
  8025e8:	c3                   	ret    
  8025e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025f0:	85 ff                	test   %edi,%edi
  8025f2:	89 fd                	mov    %edi,%ebp
  8025f4:	75 0b                	jne    802601 <__umoddi3+0x91>
  8025f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025fb:	31 d2                	xor    %edx,%edx
  8025fd:	f7 f7                	div    %edi
  8025ff:	89 c5                	mov    %eax,%ebp
  802601:	89 f0                	mov    %esi,%eax
  802603:	31 d2                	xor    %edx,%edx
  802605:	f7 f5                	div    %ebp
  802607:	89 c8                	mov    %ecx,%eax
  802609:	f7 f5                	div    %ebp
  80260b:	89 d0                	mov    %edx,%eax
  80260d:	eb 99                	jmp    8025a8 <__umoddi3+0x38>
  80260f:	90                   	nop
  802610:	89 c8                	mov    %ecx,%eax
  802612:	89 f2                	mov    %esi,%edx
  802614:	83 c4 1c             	add    $0x1c,%esp
  802617:	5b                   	pop    %ebx
  802618:	5e                   	pop    %esi
  802619:	5f                   	pop    %edi
  80261a:	5d                   	pop    %ebp
  80261b:	c3                   	ret    
  80261c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802620:	8b 34 24             	mov    (%esp),%esi
  802623:	bf 20 00 00 00       	mov    $0x20,%edi
  802628:	89 e9                	mov    %ebp,%ecx
  80262a:	29 ef                	sub    %ebp,%edi
  80262c:	d3 e0                	shl    %cl,%eax
  80262e:	89 f9                	mov    %edi,%ecx
  802630:	89 f2                	mov    %esi,%edx
  802632:	d3 ea                	shr    %cl,%edx
  802634:	89 e9                	mov    %ebp,%ecx
  802636:	09 c2                	or     %eax,%edx
  802638:	89 d8                	mov    %ebx,%eax
  80263a:	89 14 24             	mov    %edx,(%esp)
  80263d:	89 f2                	mov    %esi,%edx
  80263f:	d3 e2                	shl    %cl,%edx
  802641:	89 f9                	mov    %edi,%ecx
  802643:	89 54 24 04          	mov    %edx,0x4(%esp)
  802647:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80264b:	d3 e8                	shr    %cl,%eax
  80264d:	89 e9                	mov    %ebp,%ecx
  80264f:	89 c6                	mov    %eax,%esi
  802651:	d3 e3                	shl    %cl,%ebx
  802653:	89 f9                	mov    %edi,%ecx
  802655:	89 d0                	mov    %edx,%eax
  802657:	d3 e8                	shr    %cl,%eax
  802659:	89 e9                	mov    %ebp,%ecx
  80265b:	09 d8                	or     %ebx,%eax
  80265d:	89 d3                	mov    %edx,%ebx
  80265f:	89 f2                	mov    %esi,%edx
  802661:	f7 34 24             	divl   (%esp)
  802664:	89 d6                	mov    %edx,%esi
  802666:	d3 e3                	shl    %cl,%ebx
  802668:	f7 64 24 04          	mull   0x4(%esp)
  80266c:	39 d6                	cmp    %edx,%esi
  80266e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802672:	89 d1                	mov    %edx,%ecx
  802674:	89 c3                	mov    %eax,%ebx
  802676:	72 08                	jb     802680 <__umoddi3+0x110>
  802678:	75 11                	jne    80268b <__umoddi3+0x11b>
  80267a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80267e:	73 0b                	jae    80268b <__umoddi3+0x11b>
  802680:	2b 44 24 04          	sub    0x4(%esp),%eax
  802684:	1b 14 24             	sbb    (%esp),%edx
  802687:	89 d1                	mov    %edx,%ecx
  802689:	89 c3                	mov    %eax,%ebx
  80268b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80268f:	29 da                	sub    %ebx,%edx
  802691:	19 ce                	sbb    %ecx,%esi
  802693:	89 f9                	mov    %edi,%ecx
  802695:	89 f0                	mov    %esi,%eax
  802697:	d3 e0                	shl    %cl,%eax
  802699:	89 e9                	mov    %ebp,%ecx
  80269b:	d3 ea                	shr    %cl,%edx
  80269d:	89 e9                	mov    %ebp,%ecx
  80269f:	d3 ee                	shr    %cl,%esi
  8026a1:	09 d0                	or     %edx,%eax
  8026a3:	89 f2                	mov    %esi,%edx
  8026a5:	83 c4 1c             	add    $0x1c,%esp
  8026a8:	5b                   	pop    %ebx
  8026a9:	5e                   	pop    %esi
  8026aa:	5f                   	pop    %edi
  8026ab:	5d                   	pop    %ebp
  8026ac:	c3                   	ret    
  8026ad:	8d 76 00             	lea    0x0(%esi),%esi
  8026b0:	29 f9                	sub    %edi,%ecx
  8026b2:	19 d6                	sbb    %edx,%esi
  8026b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026bc:	e9 18 ff ff ff       	jmp    8025d9 <__umoddi3+0x69>
