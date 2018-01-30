
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
  800048:	e8 d5 16 00 00       	call   801722 <write>
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	39 c3                	cmp    %eax,%ebx
  800052:	74 18                	je     80006c <cat+0x39>
			panic("write error copying %s: %e", s, r);
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	50                   	push   %eax
  800058:	ff 75 0c             	pushl  0xc(%ebp)
  80005b:	68 00 26 80 00       	push   $0x802600
  800060:	6a 0d                	push   $0xd
  800062:	68 1b 26 80 00       	push   $0x80261b
  800067:	e8 4a 01 00 00       	call   8001b6 <_panic>
cat(int f, char *s)
{
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80006c:	83 ec 04             	sub    $0x4,%esp
  80006f:	68 00 20 00 00       	push   $0x2000
  800074:	68 20 40 80 00       	push   $0x804020
  800079:	56                   	push   %esi
  80007a:	e8 c6 15 00 00       	call   801645 <read>
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
  800093:	68 26 26 80 00       	push   $0x802626
  800098:	6a 0f                	push   $0xf
  80009a:	68 1b 26 80 00       	push   $0x80261b
  80009f:	e8 12 01 00 00       	call   8001b6 <_panic>
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
  8000b7:	c7 05 00 30 80 00 3b 	movl   $0x80263b,0x803000
  8000be:	26 80 00 
  8000c1:	bb 01 00 00 00       	mov    $0x1,%ebx
	if (argc == 1)
  8000c6:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ca:	75 5a                	jne    800126 <umain+0x7b>
		cat(0, "<stdin>");
  8000cc:	83 ec 08             	sub    $0x8,%esp
  8000cf:	68 3f 26 80 00       	push   $0x80263f
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
  8000e8:	e8 ec 19 00 00       	call   801ad9 <open>
  8000ed:	89 c6                	mov    %eax,%esi
			if (f < 0)
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	85 c0                	test   %eax,%eax
  8000f4:	79 16                	jns    80010c <umain+0x61>
				printf("can't open %s: %e\n", argv[i], f);
  8000f6:	83 ec 04             	sub    $0x4,%esp
  8000f9:	50                   	push   %eax
  8000fa:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000fd:	68 47 26 80 00       	push   $0x802647
  800102:	e8 70 1b 00 00       	call   801c77 <printf>
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
  80011b:	e8 e9 13 00 00       	call   801509 <close>
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
  80013e:	e8 96 0a 00 00       	call   800bd9 <sys_getenvid>
  800143:	25 ff 03 00 00       	and    $0x3ff,%eax
  800148:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  80014e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800153:	a3 20 60 80 00       	mov    %eax,0x806020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800158:	85 db                	test   %ebx,%ebx
  80015a:	7e 07                	jle    800163 <libmain+0x30>
		binaryname = argv[0];
  80015c:	8b 06                	mov    (%esi),%eax
  80015e:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800163:	83 ec 08             	sub    $0x8,%esp
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
  800168:	e8 3e ff ff ff       	call   8000ab <umain>

	// exit gracefully
	exit();
  80016d:	e8 2a 00 00 00       	call   80019c <exit>
}
  800172:	83 c4 10             	add    $0x10,%esp
  800175:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800178:	5b                   	pop    %ebx
  800179:	5e                   	pop    %esi
  80017a:	5d                   	pop    %ebp
  80017b:	c3                   	ret    

0080017c <thread_main>:

/*Lab 7: Multithreading thread main routine*/
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	83 ec 08             	sub    $0x8,%esp
	void (*func)(void) = (void (*)(void))eip;
  800182:	a1 24 60 80 00       	mov    0x806024,%eax
	func();
  800187:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800189:	e8 4b 0a 00 00       	call   800bd9 <sys_getenvid>
  80018e:	83 ec 0c             	sub    $0xc,%esp
  800191:	50                   	push   %eax
  800192:	e8 91 0c 00 00       	call   800e28 <sys_thread_free>
}
  800197:	83 c4 10             	add    $0x10,%esp
  80019a:	c9                   	leave  
  80019b:	c3                   	ret    

0080019c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001a2:	e8 8d 13 00 00       	call   801534 <close_all>
	sys_env_destroy(0);
  8001a7:	83 ec 0c             	sub    $0xc,%esp
  8001aa:	6a 00                	push   $0x0
  8001ac:	e8 e7 09 00 00       	call   800b98 <sys_env_destroy>
}
  8001b1:	83 c4 10             	add    $0x10,%esp
  8001b4:	c9                   	leave  
  8001b5:	c3                   	ret    

008001b6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001b6:	55                   	push   %ebp
  8001b7:	89 e5                	mov    %esp,%ebp
  8001b9:	56                   	push   %esi
  8001ba:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001bb:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001be:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001c4:	e8 10 0a 00 00       	call   800bd9 <sys_getenvid>
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	ff 75 0c             	pushl  0xc(%ebp)
  8001cf:	ff 75 08             	pushl  0x8(%ebp)
  8001d2:	56                   	push   %esi
  8001d3:	50                   	push   %eax
  8001d4:	68 64 26 80 00       	push   $0x802664
  8001d9:	e8 b1 00 00 00       	call   80028f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001de:	83 c4 18             	add    $0x18,%esp
  8001e1:	53                   	push   %ebx
  8001e2:	ff 75 10             	pushl  0x10(%ebp)
  8001e5:	e8 54 00 00 00       	call   80023e <vcprintf>
	cprintf("\n");
  8001ea:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  8001f1:	e8 99 00 00 00       	call   80028f <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001f9:	cc                   	int3   
  8001fa:	eb fd                	jmp    8001f9 <_panic+0x43>

008001fc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	53                   	push   %ebx
  800200:	83 ec 04             	sub    $0x4,%esp
  800203:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800206:	8b 13                	mov    (%ebx),%edx
  800208:	8d 42 01             	lea    0x1(%edx),%eax
  80020b:	89 03                	mov    %eax,(%ebx)
  80020d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800210:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800214:	3d ff 00 00 00       	cmp    $0xff,%eax
  800219:	75 1a                	jne    800235 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80021b:	83 ec 08             	sub    $0x8,%esp
  80021e:	68 ff 00 00 00       	push   $0xff
  800223:	8d 43 08             	lea    0x8(%ebx),%eax
  800226:	50                   	push   %eax
  800227:	e8 2f 09 00 00       	call   800b5b <sys_cputs>
		b->idx = 0;
  80022c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800232:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800235:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800239:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80023c:	c9                   	leave  
  80023d:	c3                   	ret    

0080023e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023e:	55                   	push   %ebp
  80023f:	89 e5                	mov    %esp,%ebp
  800241:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800247:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024e:	00 00 00 
	b.cnt = 0;
  800251:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800258:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80025b:	ff 75 0c             	pushl  0xc(%ebp)
  80025e:	ff 75 08             	pushl  0x8(%ebp)
  800261:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800267:	50                   	push   %eax
  800268:	68 fc 01 80 00       	push   $0x8001fc
  80026d:	e8 54 01 00 00       	call   8003c6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800272:	83 c4 08             	add    $0x8,%esp
  800275:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80027b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800281:	50                   	push   %eax
  800282:	e8 d4 08 00 00       	call   800b5b <sys_cputs>

	return b.cnt;
}
  800287:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028d:	c9                   	leave  
  80028e:	c3                   	ret    

0080028f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
  800292:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800295:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800298:	50                   	push   %eax
  800299:	ff 75 08             	pushl  0x8(%ebp)
  80029c:	e8 9d ff ff ff       	call   80023e <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a1:	c9                   	leave  
  8002a2:	c3                   	ret    

008002a3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a3:	55                   	push   %ebp
  8002a4:	89 e5                	mov    %esp,%ebp
  8002a6:	57                   	push   %edi
  8002a7:	56                   	push   %esi
  8002a8:	53                   	push   %ebx
  8002a9:	83 ec 1c             	sub    $0x1c,%esp
  8002ac:	89 c7                	mov    %eax,%edi
  8002ae:	89 d6                	mov    %edx,%esi
  8002b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002b9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002c7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002ca:	39 d3                	cmp    %edx,%ebx
  8002cc:	72 05                	jb     8002d3 <printnum+0x30>
  8002ce:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002d1:	77 45                	ja     800318 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d3:	83 ec 0c             	sub    $0xc,%esp
  8002d6:	ff 75 18             	pushl  0x18(%ebp)
  8002d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8002dc:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002df:	53                   	push   %ebx
  8002e0:	ff 75 10             	pushl  0x10(%ebp)
  8002e3:	83 ec 08             	sub    $0x8,%esp
  8002e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ec:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ef:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f2:	e8 79 20 00 00       	call   802370 <__udivdi3>
  8002f7:	83 c4 18             	add    $0x18,%esp
  8002fa:	52                   	push   %edx
  8002fb:	50                   	push   %eax
  8002fc:	89 f2                	mov    %esi,%edx
  8002fe:	89 f8                	mov    %edi,%eax
  800300:	e8 9e ff ff ff       	call   8002a3 <printnum>
  800305:	83 c4 20             	add    $0x20,%esp
  800308:	eb 18                	jmp    800322 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80030a:	83 ec 08             	sub    $0x8,%esp
  80030d:	56                   	push   %esi
  80030e:	ff 75 18             	pushl  0x18(%ebp)
  800311:	ff d7                	call   *%edi
  800313:	83 c4 10             	add    $0x10,%esp
  800316:	eb 03                	jmp    80031b <printnum+0x78>
  800318:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80031b:	83 eb 01             	sub    $0x1,%ebx
  80031e:	85 db                	test   %ebx,%ebx
  800320:	7f e8                	jg     80030a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800322:	83 ec 08             	sub    $0x8,%esp
  800325:	56                   	push   %esi
  800326:	83 ec 04             	sub    $0x4,%esp
  800329:	ff 75 e4             	pushl  -0x1c(%ebp)
  80032c:	ff 75 e0             	pushl  -0x20(%ebp)
  80032f:	ff 75 dc             	pushl  -0x24(%ebp)
  800332:	ff 75 d8             	pushl  -0x28(%ebp)
  800335:	e8 66 21 00 00       	call   8024a0 <__umoddi3>
  80033a:	83 c4 14             	add    $0x14,%esp
  80033d:	0f be 80 87 26 80 00 	movsbl 0x802687(%eax),%eax
  800344:	50                   	push   %eax
  800345:	ff d7                	call   *%edi
}
  800347:	83 c4 10             	add    $0x10,%esp
  80034a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034d:	5b                   	pop    %ebx
  80034e:	5e                   	pop    %esi
  80034f:	5f                   	pop    %edi
  800350:	5d                   	pop    %ebp
  800351:	c3                   	ret    

00800352 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800352:	55                   	push   %ebp
  800353:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800355:	83 fa 01             	cmp    $0x1,%edx
  800358:	7e 0e                	jle    800368 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80035a:	8b 10                	mov    (%eax),%edx
  80035c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80035f:	89 08                	mov    %ecx,(%eax)
  800361:	8b 02                	mov    (%edx),%eax
  800363:	8b 52 04             	mov    0x4(%edx),%edx
  800366:	eb 22                	jmp    80038a <getuint+0x38>
	else if (lflag)
  800368:	85 d2                	test   %edx,%edx
  80036a:	74 10                	je     80037c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80036c:	8b 10                	mov    (%eax),%edx
  80036e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800371:	89 08                	mov    %ecx,(%eax)
  800373:	8b 02                	mov    (%edx),%eax
  800375:	ba 00 00 00 00       	mov    $0x0,%edx
  80037a:	eb 0e                	jmp    80038a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80037c:	8b 10                	mov    (%eax),%edx
  80037e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800381:	89 08                	mov    %ecx,(%eax)
  800383:	8b 02                	mov    (%edx),%eax
  800385:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80038a:	5d                   	pop    %ebp
  80038b:	c3                   	ret    

0080038c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800392:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800396:	8b 10                	mov    (%eax),%edx
  800398:	3b 50 04             	cmp    0x4(%eax),%edx
  80039b:	73 0a                	jae    8003a7 <sprintputch+0x1b>
		*b->buf++ = ch;
  80039d:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003a0:	89 08                	mov    %ecx,(%eax)
  8003a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a5:	88 02                	mov    %al,(%edx)
}
  8003a7:	5d                   	pop    %ebp
  8003a8:	c3                   	ret    

008003a9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003a9:	55                   	push   %ebp
  8003aa:	89 e5                	mov    %esp,%ebp
  8003ac:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003af:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003b2:	50                   	push   %eax
  8003b3:	ff 75 10             	pushl  0x10(%ebp)
  8003b6:	ff 75 0c             	pushl  0xc(%ebp)
  8003b9:	ff 75 08             	pushl  0x8(%ebp)
  8003bc:	e8 05 00 00 00       	call   8003c6 <vprintfmt>
	va_end(ap);
}
  8003c1:	83 c4 10             	add    $0x10,%esp
  8003c4:	c9                   	leave  
  8003c5:	c3                   	ret    

008003c6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c6:	55                   	push   %ebp
  8003c7:	89 e5                	mov    %esp,%ebp
  8003c9:	57                   	push   %edi
  8003ca:	56                   	push   %esi
  8003cb:	53                   	push   %ebx
  8003cc:	83 ec 2c             	sub    $0x2c,%esp
  8003cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8003d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003d5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003d8:	eb 12                	jmp    8003ec <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003da:	85 c0                	test   %eax,%eax
  8003dc:	0f 84 89 03 00 00    	je     80076b <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003e2:	83 ec 08             	sub    $0x8,%esp
  8003e5:	53                   	push   %ebx
  8003e6:	50                   	push   %eax
  8003e7:	ff d6                	call   *%esi
  8003e9:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ec:	83 c7 01             	add    $0x1,%edi
  8003ef:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003f3:	83 f8 25             	cmp    $0x25,%eax
  8003f6:	75 e2                	jne    8003da <vprintfmt+0x14>
  8003f8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003fc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800403:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80040a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800411:	ba 00 00 00 00       	mov    $0x0,%edx
  800416:	eb 07                	jmp    80041f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800418:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80041b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041f:	8d 47 01             	lea    0x1(%edi),%eax
  800422:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800425:	0f b6 07             	movzbl (%edi),%eax
  800428:	0f b6 c8             	movzbl %al,%ecx
  80042b:	83 e8 23             	sub    $0x23,%eax
  80042e:	3c 55                	cmp    $0x55,%al
  800430:	0f 87 1a 03 00 00    	ja     800750 <vprintfmt+0x38a>
  800436:	0f b6 c0             	movzbl %al,%eax
  800439:	ff 24 85 c0 27 80 00 	jmp    *0x8027c0(,%eax,4)
  800440:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800443:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800447:	eb d6                	jmp    80041f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80044c:	b8 00 00 00 00       	mov    $0x0,%eax
  800451:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800454:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800457:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80045b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80045e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800461:	83 fa 09             	cmp    $0x9,%edx
  800464:	77 39                	ja     80049f <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800466:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800469:	eb e9                	jmp    800454 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80046b:	8b 45 14             	mov    0x14(%ebp),%eax
  80046e:	8d 48 04             	lea    0x4(%eax),%ecx
  800471:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800474:	8b 00                	mov    (%eax),%eax
  800476:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800479:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80047c:	eb 27                	jmp    8004a5 <vprintfmt+0xdf>
  80047e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800481:	85 c0                	test   %eax,%eax
  800483:	b9 00 00 00 00       	mov    $0x0,%ecx
  800488:	0f 49 c8             	cmovns %eax,%ecx
  80048b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800491:	eb 8c                	jmp    80041f <vprintfmt+0x59>
  800493:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800496:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80049d:	eb 80                	jmp    80041f <vprintfmt+0x59>
  80049f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004a2:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004a5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a9:	0f 89 70 ff ff ff    	jns    80041f <vprintfmt+0x59>
				width = precision, precision = -1;
  8004af:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004bc:	e9 5e ff ff ff       	jmp    80041f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004c1:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004c7:	e9 53 ff ff ff       	jmp    80041f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cf:	8d 50 04             	lea    0x4(%eax),%edx
  8004d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d5:	83 ec 08             	sub    $0x8,%esp
  8004d8:	53                   	push   %ebx
  8004d9:	ff 30                	pushl  (%eax)
  8004db:	ff d6                	call   *%esi
			break;
  8004dd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004e3:	e9 04 ff ff ff       	jmp    8003ec <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004eb:	8d 50 04             	lea    0x4(%eax),%edx
  8004ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f1:	8b 00                	mov    (%eax),%eax
  8004f3:	99                   	cltd   
  8004f4:	31 d0                	xor    %edx,%eax
  8004f6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f8:	83 f8 0f             	cmp    $0xf,%eax
  8004fb:	7f 0b                	jg     800508 <vprintfmt+0x142>
  8004fd:	8b 14 85 20 29 80 00 	mov    0x802920(,%eax,4),%edx
  800504:	85 d2                	test   %edx,%edx
  800506:	75 18                	jne    800520 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800508:	50                   	push   %eax
  800509:	68 9f 26 80 00       	push   $0x80269f
  80050e:	53                   	push   %ebx
  80050f:	56                   	push   %esi
  800510:	e8 94 fe ff ff       	call   8003a9 <printfmt>
  800515:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800518:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80051b:	e9 cc fe ff ff       	jmp    8003ec <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800520:	52                   	push   %edx
  800521:	68 e1 2a 80 00       	push   $0x802ae1
  800526:	53                   	push   %ebx
  800527:	56                   	push   %esi
  800528:	e8 7c fe ff ff       	call   8003a9 <printfmt>
  80052d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800530:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800533:	e9 b4 fe ff ff       	jmp    8003ec <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800538:	8b 45 14             	mov    0x14(%ebp),%eax
  80053b:	8d 50 04             	lea    0x4(%eax),%edx
  80053e:	89 55 14             	mov    %edx,0x14(%ebp)
  800541:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800543:	85 ff                	test   %edi,%edi
  800545:	b8 98 26 80 00       	mov    $0x802698,%eax
  80054a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80054d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800551:	0f 8e 94 00 00 00    	jle    8005eb <vprintfmt+0x225>
  800557:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80055b:	0f 84 98 00 00 00    	je     8005f9 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800561:	83 ec 08             	sub    $0x8,%esp
  800564:	ff 75 d0             	pushl  -0x30(%ebp)
  800567:	57                   	push   %edi
  800568:	e8 86 02 00 00       	call   8007f3 <strnlen>
  80056d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800570:	29 c1                	sub    %eax,%ecx
  800572:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800575:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800578:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80057c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80057f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800582:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800584:	eb 0f                	jmp    800595 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800586:	83 ec 08             	sub    $0x8,%esp
  800589:	53                   	push   %ebx
  80058a:	ff 75 e0             	pushl  -0x20(%ebp)
  80058d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058f:	83 ef 01             	sub    $0x1,%edi
  800592:	83 c4 10             	add    $0x10,%esp
  800595:	85 ff                	test   %edi,%edi
  800597:	7f ed                	jg     800586 <vprintfmt+0x1c0>
  800599:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80059c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80059f:	85 c9                	test   %ecx,%ecx
  8005a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a6:	0f 49 c1             	cmovns %ecx,%eax
  8005a9:	29 c1                	sub    %eax,%ecx
  8005ab:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ae:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005b1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005b4:	89 cb                	mov    %ecx,%ebx
  8005b6:	eb 4d                	jmp    800605 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005bc:	74 1b                	je     8005d9 <vprintfmt+0x213>
  8005be:	0f be c0             	movsbl %al,%eax
  8005c1:	83 e8 20             	sub    $0x20,%eax
  8005c4:	83 f8 5e             	cmp    $0x5e,%eax
  8005c7:	76 10                	jbe    8005d9 <vprintfmt+0x213>
					putch('?', putdat);
  8005c9:	83 ec 08             	sub    $0x8,%esp
  8005cc:	ff 75 0c             	pushl  0xc(%ebp)
  8005cf:	6a 3f                	push   $0x3f
  8005d1:	ff 55 08             	call   *0x8(%ebp)
  8005d4:	83 c4 10             	add    $0x10,%esp
  8005d7:	eb 0d                	jmp    8005e6 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005d9:	83 ec 08             	sub    $0x8,%esp
  8005dc:	ff 75 0c             	pushl  0xc(%ebp)
  8005df:	52                   	push   %edx
  8005e0:	ff 55 08             	call   *0x8(%ebp)
  8005e3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e6:	83 eb 01             	sub    $0x1,%ebx
  8005e9:	eb 1a                	jmp    800605 <vprintfmt+0x23f>
  8005eb:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ee:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005f1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005f7:	eb 0c                	jmp    800605 <vprintfmt+0x23f>
  8005f9:	89 75 08             	mov    %esi,0x8(%ebp)
  8005fc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ff:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800602:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800605:	83 c7 01             	add    $0x1,%edi
  800608:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80060c:	0f be d0             	movsbl %al,%edx
  80060f:	85 d2                	test   %edx,%edx
  800611:	74 23                	je     800636 <vprintfmt+0x270>
  800613:	85 f6                	test   %esi,%esi
  800615:	78 a1                	js     8005b8 <vprintfmt+0x1f2>
  800617:	83 ee 01             	sub    $0x1,%esi
  80061a:	79 9c                	jns    8005b8 <vprintfmt+0x1f2>
  80061c:	89 df                	mov    %ebx,%edi
  80061e:	8b 75 08             	mov    0x8(%ebp),%esi
  800621:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800624:	eb 18                	jmp    80063e <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800626:	83 ec 08             	sub    $0x8,%esp
  800629:	53                   	push   %ebx
  80062a:	6a 20                	push   $0x20
  80062c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80062e:	83 ef 01             	sub    $0x1,%edi
  800631:	83 c4 10             	add    $0x10,%esp
  800634:	eb 08                	jmp    80063e <vprintfmt+0x278>
  800636:	89 df                	mov    %ebx,%edi
  800638:	8b 75 08             	mov    0x8(%ebp),%esi
  80063b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80063e:	85 ff                	test   %edi,%edi
  800640:	7f e4                	jg     800626 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800642:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800645:	e9 a2 fd ff ff       	jmp    8003ec <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80064a:	83 fa 01             	cmp    $0x1,%edx
  80064d:	7e 16                	jle    800665 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80064f:	8b 45 14             	mov    0x14(%ebp),%eax
  800652:	8d 50 08             	lea    0x8(%eax),%edx
  800655:	89 55 14             	mov    %edx,0x14(%ebp)
  800658:	8b 50 04             	mov    0x4(%eax),%edx
  80065b:	8b 00                	mov    (%eax),%eax
  80065d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800660:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800663:	eb 32                	jmp    800697 <vprintfmt+0x2d1>
	else if (lflag)
  800665:	85 d2                	test   %edx,%edx
  800667:	74 18                	je     800681 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8d 50 04             	lea    0x4(%eax),%edx
  80066f:	89 55 14             	mov    %edx,0x14(%ebp)
  800672:	8b 00                	mov    (%eax),%eax
  800674:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800677:	89 c1                	mov    %eax,%ecx
  800679:	c1 f9 1f             	sar    $0x1f,%ecx
  80067c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80067f:	eb 16                	jmp    800697 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800681:	8b 45 14             	mov    0x14(%ebp),%eax
  800684:	8d 50 04             	lea    0x4(%eax),%edx
  800687:	89 55 14             	mov    %edx,0x14(%ebp)
  80068a:	8b 00                	mov    (%eax),%eax
  80068c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068f:	89 c1                	mov    %eax,%ecx
  800691:	c1 f9 1f             	sar    $0x1f,%ecx
  800694:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800697:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80069a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80069d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006a2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006a6:	79 74                	jns    80071c <vprintfmt+0x356>
				putch('-', putdat);
  8006a8:	83 ec 08             	sub    $0x8,%esp
  8006ab:	53                   	push   %ebx
  8006ac:	6a 2d                	push   $0x2d
  8006ae:	ff d6                	call   *%esi
				num = -(long long) num;
  8006b0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006b3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006b6:	f7 d8                	neg    %eax
  8006b8:	83 d2 00             	adc    $0x0,%edx
  8006bb:	f7 da                	neg    %edx
  8006bd:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006c0:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006c5:	eb 55                	jmp    80071c <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006c7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ca:	e8 83 fc ff ff       	call   800352 <getuint>
			base = 10;
  8006cf:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006d4:	eb 46                	jmp    80071c <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d9:	e8 74 fc ff ff       	call   800352 <getuint>
			base = 8;
  8006de:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006e3:	eb 37                	jmp    80071c <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8006e5:	83 ec 08             	sub    $0x8,%esp
  8006e8:	53                   	push   %ebx
  8006e9:	6a 30                	push   $0x30
  8006eb:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ed:	83 c4 08             	add    $0x8,%esp
  8006f0:	53                   	push   %ebx
  8006f1:	6a 78                	push   $0x78
  8006f3:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f8:	8d 50 04             	lea    0x4(%eax),%edx
  8006fb:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006fe:	8b 00                	mov    (%eax),%eax
  800700:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800705:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800708:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80070d:	eb 0d                	jmp    80071c <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80070f:	8d 45 14             	lea    0x14(%ebp),%eax
  800712:	e8 3b fc ff ff       	call   800352 <getuint>
			base = 16;
  800717:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80071c:	83 ec 0c             	sub    $0xc,%esp
  80071f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800723:	57                   	push   %edi
  800724:	ff 75 e0             	pushl  -0x20(%ebp)
  800727:	51                   	push   %ecx
  800728:	52                   	push   %edx
  800729:	50                   	push   %eax
  80072a:	89 da                	mov    %ebx,%edx
  80072c:	89 f0                	mov    %esi,%eax
  80072e:	e8 70 fb ff ff       	call   8002a3 <printnum>
			break;
  800733:	83 c4 20             	add    $0x20,%esp
  800736:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800739:	e9 ae fc ff ff       	jmp    8003ec <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80073e:	83 ec 08             	sub    $0x8,%esp
  800741:	53                   	push   %ebx
  800742:	51                   	push   %ecx
  800743:	ff d6                	call   *%esi
			break;
  800745:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800748:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80074b:	e9 9c fc ff ff       	jmp    8003ec <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800750:	83 ec 08             	sub    $0x8,%esp
  800753:	53                   	push   %ebx
  800754:	6a 25                	push   $0x25
  800756:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800758:	83 c4 10             	add    $0x10,%esp
  80075b:	eb 03                	jmp    800760 <vprintfmt+0x39a>
  80075d:	83 ef 01             	sub    $0x1,%edi
  800760:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800764:	75 f7                	jne    80075d <vprintfmt+0x397>
  800766:	e9 81 fc ff ff       	jmp    8003ec <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80076b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076e:	5b                   	pop    %ebx
  80076f:	5e                   	pop    %esi
  800770:	5f                   	pop    %edi
  800771:	5d                   	pop    %ebp
  800772:	c3                   	ret    

00800773 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	83 ec 18             	sub    $0x18,%esp
  800779:	8b 45 08             	mov    0x8(%ebp),%eax
  80077c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80077f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800782:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800786:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800789:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800790:	85 c0                	test   %eax,%eax
  800792:	74 26                	je     8007ba <vsnprintf+0x47>
  800794:	85 d2                	test   %edx,%edx
  800796:	7e 22                	jle    8007ba <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800798:	ff 75 14             	pushl  0x14(%ebp)
  80079b:	ff 75 10             	pushl  0x10(%ebp)
  80079e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a1:	50                   	push   %eax
  8007a2:	68 8c 03 80 00       	push   $0x80038c
  8007a7:	e8 1a fc ff ff       	call   8003c6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007af:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b5:	83 c4 10             	add    $0x10,%esp
  8007b8:	eb 05                	jmp    8007bf <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007bf:	c9                   	leave  
  8007c0:	c3                   	ret    

008007c1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ca:	50                   	push   %eax
  8007cb:	ff 75 10             	pushl  0x10(%ebp)
  8007ce:	ff 75 0c             	pushl  0xc(%ebp)
  8007d1:	ff 75 08             	pushl  0x8(%ebp)
  8007d4:	e8 9a ff ff ff       	call   800773 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d9:	c9                   	leave  
  8007da:	c3                   	ret    

008007db <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e6:	eb 03                	jmp    8007eb <strlen+0x10>
		n++;
  8007e8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007eb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ef:	75 f7                	jne    8007e8 <strlen+0xd>
		n++;
	return n;
}
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fc:	ba 00 00 00 00       	mov    $0x0,%edx
  800801:	eb 03                	jmp    800806 <strnlen+0x13>
		n++;
  800803:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800806:	39 c2                	cmp    %eax,%edx
  800808:	74 08                	je     800812 <strnlen+0x1f>
  80080a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80080e:	75 f3                	jne    800803 <strnlen+0x10>
  800810:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800812:	5d                   	pop    %ebp
  800813:	c3                   	ret    

00800814 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	53                   	push   %ebx
  800818:	8b 45 08             	mov    0x8(%ebp),%eax
  80081b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80081e:	89 c2                	mov    %eax,%edx
  800820:	83 c2 01             	add    $0x1,%edx
  800823:	83 c1 01             	add    $0x1,%ecx
  800826:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80082a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80082d:	84 db                	test   %bl,%bl
  80082f:	75 ef                	jne    800820 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800831:	5b                   	pop    %ebx
  800832:	5d                   	pop    %ebp
  800833:	c3                   	ret    

00800834 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	53                   	push   %ebx
  800838:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80083b:	53                   	push   %ebx
  80083c:	e8 9a ff ff ff       	call   8007db <strlen>
  800841:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800844:	ff 75 0c             	pushl  0xc(%ebp)
  800847:	01 d8                	add    %ebx,%eax
  800849:	50                   	push   %eax
  80084a:	e8 c5 ff ff ff       	call   800814 <strcpy>
	return dst;
}
  80084f:	89 d8                	mov    %ebx,%eax
  800851:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800854:	c9                   	leave  
  800855:	c3                   	ret    

00800856 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	56                   	push   %esi
  80085a:	53                   	push   %ebx
  80085b:	8b 75 08             	mov    0x8(%ebp),%esi
  80085e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800861:	89 f3                	mov    %esi,%ebx
  800863:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800866:	89 f2                	mov    %esi,%edx
  800868:	eb 0f                	jmp    800879 <strncpy+0x23>
		*dst++ = *src;
  80086a:	83 c2 01             	add    $0x1,%edx
  80086d:	0f b6 01             	movzbl (%ecx),%eax
  800870:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800873:	80 39 01             	cmpb   $0x1,(%ecx)
  800876:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800879:	39 da                	cmp    %ebx,%edx
  80087b:	75 ed                	jne    80086a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80087d:	89 f0                	mov    %esi,%eax
  80087f:	5b                   	pop    %ebx
  800880:	5e                   	pop    %esi
  800881:	5d                   	pop    %ebp
  800882:	c3                   	ret    

00800883 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	56                   	push   %esi
  800887:	53                   	push   %ebx
  800888:	8b 75 08             	mov    0x8(%ebp),%esi
  80088b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088e:	8b 55 10             	mov    0x10(%ebp),%edx
  800891:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800893:	85 d2                	test   %edx,%edx
  800895:	74 21                	je     8008b8 <strlcpy+0x35>
  800897:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80089b:	89 f2                	mov    %esi,%edx
  80089d:	eb 09                	jmp    8008a8 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80089f:	83 c2 01             	add    $0x1,%edx
  8008a2:	83 c1 01             	add    $0x1,%ecx
  8008a5:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a8:	39 c2                	cmp    %eax,%edx
  8008aa:	74 09                	je     8008b5 <strlcpy+0x32>
  8008ac:	0f b6 19             	movzbl (%ecx),%ebx
  8008af:	84 db                	test   %bl,%bl
  8008b1:	75 ec                	jne    80089f <strlcpy+0x1c>
  8008b3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008b5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b8:	29 f0                	sub    %esi,%eax
}
  8008ba:	5b                   	pop    %ebx
  8008bb:	5e                   	pop    %esi
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c7:	eb 06                	jmp    8008cf <strcmp+0x11>
		p++, q++;
  8008c9:	83 c1 01             	add    $0x1,%ecx
  8008cc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008cf:	0f b6 01             	movzbl (%ecx),%eax
  8008d2:	84 c0                	test   %al,%al
  8008d4:	74 04                	je     8008da <strcmp+0x1c>
  8008d6:	3a 02                	cmp    (%edx),%al
  8008d8:	74 ef                	je     8008c9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008da:	0f b6 c0             	movzbl %al,%eax
  8008dd:	0f b6 12             	movzbl (%edx),%edx
  8008e0:	29 d0                	sub    %edx,%eax
}
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	53                   	push   %ebx
  8008e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ee:	89 c3                	mov    %eax,%ebx
  8008f0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008f3:	eb 06                	jmp    8008fb <strncmp+0x17>
		n--, p++, q++;
  8008f5:	83 c0 01             	add    $0x1,%eax
  8008f8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008fb:	39 d8                	cmp    %ebx,%eax
  8008fd:	74 15                	je     800914 <strncmp+0x30>
  8008ff:	0f b6 08             	movzbl (%eax),%ecx
  800902:	84 c9                	test   %cl,%cl
  800904:	74 04                	je     80090a <strncmp+0x26>
  800906:	3a 0a                	cmp    (%edx),%cl
  800908:	74 eb                	je     8008f5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80090a:	0f b6 00             	movzbl (%eax),%eax
  80090d:	0f b6 12             	movzbl (%edx),%edx
  800910:	29 d0                	sub    %edx,%eax
  800912:	eb 05                	jmp    800919 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800914:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800919:	5b                   	pop    %ebx
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	8b 45 08             	mov    0x8(%ebp),%eax
  800922:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800926:	eb 07                	jmp    80092f <strchr+0x13>
		if (*s == c)
  800928:	38 ca                	cmp    %cl,%dl
  80092a:	74 0f                	je     80093b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80092c:	83 c0 01             	add    $0x1,%eax
  80092f:	0f b6 10             	movzbl (%eax),%edx
  800932:	84 d2                	test   %dl,%dl
  800934:	75 f2                	jne    800928 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800936:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800947:	eb 03                	jmp    80094c <strfind+0xf>
  800949:	83 c0 01             	add    $0x1,%eax
  80094c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80094f:	38 ca                	cmp    %cl,%dl
  800951:	74 04                	je     800957 <strfind+0x1a>
  800953:	84 d2                	test   %dl,%dl
  800955:	75 f2                	jne    800949 <strfind+0xc>
			break;
	return (char *) s;
}
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	57                   	push   %edi
  80095d:	56                   	push   %esi
  80095e:	53                   	push   %ebx
  80095f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800962:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800965:	85 c9                	test   %ecx,%ecx
  800967:	74 36                	je     80099f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800969:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096f:	75 28                	jne    800999 <memset+0x40>
  800971:	f6 c1 03             	test   $0x3,%cl
  800974:	75 23                	jne    800999 <memset+0x40>
		c &= 0xFF;
  800976:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80097a:	89 d3                	mov    %edx,%ebx
  80097c:	c1 e3 08             	shl    $0x8,%ebx
  80097f:	89 d6                	mov    %edx,%esi
  800981:	c1 e6 18             	shl    $0x18,%esi
  800984:	89 d0                	mov    %edx,%eax
  800986:	c1 e0 10             	shl    $0x10,%eax
  800989:	09 f0                	or     %esi,%eax
  80098b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80098d:	89 d8                	mov    %ebx,%eax
  80098f:	09 d0                	or     %edx,%eax
  800991:	c1 e9 02             	shr    $0x2,%ecx
  800994:	fc                   	cld    
  800995:	f3 ab                	rep stos %eax,%es:(%edi)
  800997:	eb 06                	jmp    80099f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800999:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099c:	fc                   	cld    
  80099d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80099f:	89 f8                	mov    %edi,%eax
  8009a1:	5b                   	pop    %ebx
  8009a2:	5e                   	pop    %esi
  8009a3:	5f                   	pop    %edi
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	57                   	push   %edi
  8009aa:	56                   	push   %esi
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b4:	39 c6                	cmp    %eax,%esi
  8009b6:	73 35                	jae    8009ed <memmove+0x47>
  8009b8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009bb:	39 d0                	cmp    %edx,%eax
  8009bd:	73 2e                	jae    8009ed <memmove+0x47>
		s += n;
		d += n;
  8009bf:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c2:	89 d6                	mov    %edx,%esi
  8009c4:	09 fe                	or     %edi,%esi
  8009c6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009cc:	75 13                	jne    8009e1 <memmove+0x3b>
  8009ce:	f6 c1 03             	test   $0x3,%cl
  8009d1:	75 0e                	jne    8009e1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009d3:	83 ef 04             	sub    $0x4,%edi
  8009d6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d9:	c1 e9 02             	shr    $0x2,%ecx
  8009dc:	fd                   	std    
  8009dd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009df:	eb 09                	jmp    8009ea <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009e1:	83 ef 01             	sub    $0x1,%edi
  8009e4:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009e7:	fd                   	std    
  8009e8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ea:	fc                   	cld    
  8009eb:	eb 1d                	jmp    800a0a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ed:	89 f2                	mov    %esi,%edx
  8009ef:	09 c2                	or     %eax,%edx
  8009f1:	f6 c2 03             	test   $0x3,%dl
  8009f4:	75 0f                	jne    800a05 <memmove+0x5f>
  8009f6:	f6 c1 03             	test   $0x3,%cl
  8009f9:	75 0a                	jne    800a05 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009fb:	c1 e9 02             	shr    $0x2,%ecx
  8009fe:	89 c7                	mov    %eax,%edi
  800a00:	fc                   	cld    
  800a01:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a03:	eb 05                	jmp    800a0a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a05:	89 c7                	mov    %eax,%edi
  800a07:	fc                   	cld    
  800a08:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a0a:	5e                   	pop    %esi
  800a0b:	5f                   	pop    %edi
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a11:	ff 75 10             	pushl  0x10(%ebp)
  800a14:	ff 75 0c             	pushl  0xc(%ebp)
  800a17:	ff 75 08             	pushl  0x8(%ebp)
  800a1a:	e8 87 ff ff ff       	call   8009a6 <memmove>
}
  800a1f:	c9                   	leave  
  800a20:	c3                   	ret    

00800a21 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	56                   	push   %esi
  800a25:	53                   	push   %ebx
  800a26:	8b 45 08             	mov    0x8(%ebp),%eax
  800a29:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2c:	89 c6                	mov    %eax,%esi
  800a2e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a31:	eb 1a                	jmp    800a4d <memcmp+0x2c>
		if (*s1 != *s2)
  800a33:	0f b6 08             	movzbl (%eax),%ecx
  800a36:	0f b6 1a             	movzbl (%edx),%ebx
  800a39:	38 d9                	cmp    %bl,%cl
  800a3b:	74 0a                	je     800a47 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a3d:	0f b6 c1             	movzbl %cl,%eax
  800a40:	0f b6 db             	movzbl %bl,%ebx
  800a43:	29 d8                	sub    %ebx,%eax
  800a45:	eb 0f                	jmp    800a56 <memcmp+0x35>
		s1++, s2++;
  800a47:	83 c0 01             	add    $0x1,%eax
  800a4a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4d:	39 f0                	cmp    %esi,%eax
  800a4f:	75 e2                	jne    800a33 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a51:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a56:	5b                   	pop    %ebx
  800a57:	5e                   	pop    %esi
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	53                   	push   %ebx
  800a5e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a61:	89 c1                	mov    %eax,%ecx
  800a63:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a66:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a6a:	eb 0a                	jmp    800a76 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a6c:	0f b6 10             	movzbl (%eax),%edx
  800a6f:	39 da                	cmp    %ebx,%edx
  800a71:	74 07                	je     800a7a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a73:	83 c0 01             	add    $0x1,%eax
  800a76:	39 c8                	cmp    %ecx,%eax
  800a78:	72 f2                	jb     800a6c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a7a:	5b                   	pop    %ebx
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	57                   	push   %edi
  800a81:	56                   	push   %esi
  800a82:	53                   	push   %ebx
  800a83:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a86:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a89:	eb 03                	jmp    800a8e <strtol+0x11>
		s++;
  800a8b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8e:	0f b6 01             	movzbl (%ecx),%eax
  800a91:	3c 20                	cmp    $0x20,%al
  800a93:	74 f6                	je     800a8b <strtol+0xe>
  800a95:	3c 09                	cmp    $0x9,%al
  800a97:	74 f2                	je     800a8b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a99:	3c 2b                	cmp    $0x2b,%al
  800a9b:	75 0a                	jne    800aa7 <strtol+0x2a>
		s++;
  800a9d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa0:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa5:	eb 11                	jmp    800ab8 <strtol+0x3b>
  800aa7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aac:	3c 2d                	cmp    $0x2d,%al
  800aae:	75 08                	jne    800ab8 <strtol+0x3b>
		s++, neg = 1;
  800ab0:	83 c1 01             	add    $0x1,%ecx
  800ab3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800abe:	75 15                	jne    800ad5 <strtol+0x58>
  800ac0:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac3:	75 10                	jne    800ad5 <strtol+0x58>
  800ac5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ac9:	75 7c                	jne    800b47 <strtol+0xca>
		s += 2, base = 16;
  800acb:	83 c1 02             	add    $0x2,%ecx
  800ace:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad3:	eb 16                	jmp    800aeb <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ad5:	85 db                	test   %ebx,%ebx
  800ad7:	75 12                	jne    800aeb <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ad9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ade:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae1:	75 08                	jne    800aeb <strtol+0x6e>
		s++, base = 8;
  800ae3:	83 c1 01             	add    $0x1,%ecx
  800ae6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aeb:	b8 00 00 00 00       	mov    $0x0,%eax
  800af0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af3:	0f b6 11             	movzbl (%ecx),%edx
  800af6:	8d 72 d0             	lea    -0x30(%edx),%esi
  800af9:	89 f3                	mov    %esi,%ebx
  800afb:	80 fb 09             	cmp    $0x9,%bl
  800afe:	77 08                	ja     800b08 <strtol+0x8b>
			dig = *s - '0';
  800b00:	0f be d2             	movsbl %dl,%edx
  800b03:	83 ea 30             	sub    $0x30,%edx
  800b06:	eb 22                	jmp    800b2a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b08:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b0b:	89 f3                	mov    %esi,%ebx
  800b0d:	80 fb 19             	cmp    $0x19,%bl
  800b10:	77 08                	ja     800b1a <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b12:	0f be d2             	movsbl %dl,%edx
  800b15:	83 ea 57             	sub    $0x57,%edx
  800b18:	eb 10                	jmp    800b2a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b1a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b1d:	89 f3                	mov    %esi,%ebx
  800b1f:	80 fb 19             	cmp    $0x19,%bl
  800b22:	77 16                	ja     800b3a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b24:	0f be d2             	movsbl %dl,%edx
  800b27:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b2a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b2d:	7d 0b                	jge    800b3a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b2f:	83 c1 01             	add    $0x1,%ecx
  800b32:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b36:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b38:	eb b9                	jmp    800af3 <strtol+0x76>

	if (endptr)
  800b3a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b3e:	74 0d                	je     800b4d <strtol+0xd0>
		*endptr = (char *) s;
  800b40:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b43:	89 0e                	mov    %ecx,(%esi)
  800b45:	eb 06                	jmp    800b4d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b47:	85 db                	test   %ebx,%ebx
  800b49:	74 98                	je     800ae3 <strtol+0x66>
  800b4b:	eb 9e                	jmp    800aeb <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b4d:	89 c2                	mov    %eax,%edx
  800b4f:	f7 da                	neg    %edx
  800b51:	85 ff                	test   %edi,%edi
  800b53:	0f 45 c2             	cmovne %edx,%eax
}
  800b56:	5b                   	pop    %ebx
  800b57:	5e                   	pop    %esi
  800b58:	5f                   	pop    %edi
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	57                   	push   %edi
  800b5f:	56                   	push   %esi
  800b60:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b61:	b8 00 00 00 00       	mov    $0x0,%eax
  800b66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b69:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6c:	89 c3                	mov    %eax,%ebx
  800b6e:	89 c7                	mov    %eax,%edi
  800b70:	89 c6                	mov    %eax,%esi
  800b72:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	57                   	push   %edi
  800b7d:	56                   	push   %esi
  800b7e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b84:	b8 01 00 00 00       	mov    $0x1,%eax
  800b89:	89 d1                	mov    %edx,%ecx
  800b8b:	89 d3                	mov    %edx,%ebx
  800b8d:	89 d7                	mov    %edx,%edi
  800b8f:	89 d6                	mov    %edx,%esi
  800b91:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b93:	5b                   	pop    %ebx
  800b94:	5e                   	pop    %esi
  800b95:	5f                   	pop    %edi
  800b96:	5d                   	pop    %ebp
  800b97:	c3                   	ret    

00800b98 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	57                   	push   %edi
  800b9c:	56                   	push   %esi
  800b9d:	53                   	push   %ebx
  800b9e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba6:	b8 03 00 00 00       	mov    $0x3,%eax
  800bab:	8b 55 08             	mov    0x8(%ebp),%edx
  800bae:	89 cb                	mov    %ecx,%ebx
  800bb0:	89 cf                	mov    %ecx,%edi
  800bb2:	89 ce                	mov    %ecx,%esi
  800bb4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb6:	85 c0                	test   %eax,%eax
  800bb8:	7e 17                	jle    800bd1 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bba:	83 ec 0c             	sub    $0xc,%esp
  800bbd:	50                   	push   %eax
  800bbe:	6a 03                	push   $0x3
  800bc0:	68 7f 29 80 00       	push   $0x80297f
  800bc5:	6a 23                	push   $0x23
  800bc7:	68 9c 29 80 00       	push   $0x80299c
  800bcc:	e8 e5 f5 ff ff       	call   8001b6 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd4:	5b                   	pop    %ebx
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	57                   	push   %edi
  800bdd:	56                   	push   %esi
  800bde:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdf:	ba 00 00 00 00       	mov    $0x0,%edx
  800be4:	b8 02 00 00 00       	mov    $0x2,%eax
  800be9:	89 d1                	mov    %edx,%ecx
  800beb:	89 d3                	mov    %edx,%ebx
  800bed:	89 d7                	mov    %edx,%edi
  800bef:	89 d6                	mov    %edx,%esi
  800bf1:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf3:	5b                   	pop    %ebx
  800bf4:	5e                   	pop    %esi
  800bf5:	5f                   	pop    %edi
  800bf6:	5d                   	pop    %ebp
  800bf7:	c3                   	ret    

00800bf8 <sys_yield>:

void
sys_yield(void)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	57                   	push   %edi
  800bfc:	56                   	push   %esi
  800bfd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfe:	ba 00 00 00 00       	mov    $0x0,%edx
  800c03:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c08:	89 d1                	mov    %edx,%ecx
  800c0a:	89 d3                	mov    %edx,%ebx
  800c0c:	89 d7                	mov    %edx,%edi
  800c0e:	89 d6                	mov    %edx,%esi
  800c10:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c12:	5b                   	pop    %ebx
  800c13:	5e                   	pop    %esi
  800c14:	5f                   	pop    %edi
  800c15:	5d                   	pop    %ebp
  800c16:	c3                   	ret    

00800c17 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	57                   	push   %edi
  800c1b:	56                   	push   %esi
  800c1c:	53                   	push   %ebx
  800c1d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c20:	be 00 00 00 00       	mov    $0x0,%esi
  800c25:	b8 04 00 00 00       	mov    $0x4,%eax
  800c2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c33:	89 f7                	mov    %esi,%edi
  800c35:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c37:	85 c0                	test   %eax,%eax
  800c39:	7e 17                	jle    800c52 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3b:	83 ec 0c             	sub    $0xc,%esp
  800c3e:	50                   	push   %eax
  800c3f:	6a 04                	push   $0x4
  800c41:	68 7f 29 80 00       	push   $0x80297f
  800c46:	6a 23                	push   $0x23
  800c48:	68 9c 29 80 00       	push   $0x80299c
  800c4d:	e8 64 f5 ff ff       	call   8001b6 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
  800c60:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c63:	b8 05 00 00 00       	mov    $0x5,%eax
  800c68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c71:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c74:	8b 75 18             	mov    0x18(%ebp),%esi
  800c77:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c79:	85 c0                	test   %eax,%eax
  800c7b:	7e 17                	jle    800c94 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7d:	83 ec 0c             	sub    $0xc,%esp
  800c80:	50                   	push   %eax
  800c81:	6a 05                	push   $0x5
  800c83:	68 7f 29 80 00       	push   $0x80297f
  800c88:	6a 23                	push   $0x23
  800c8a:	68 9c 29 80 00       	push   $0x80299c
  800c8f:	e8 22 f5 ff ff       	call   8001b6 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c97:	5b                   	pop    %ebx
  800c98:	5e                   	pop    %esi
  800c99:	5f                   	pop    %edi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	57                   	push   %edi
  800ca0:	56                   	push   %esi
  800ca1:	53                   	push   %ebx
  800ca2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800caa:	b8 06 00 00 00       	mov    $0x6,%eax
  800caf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb5:	89 df                	mov    %ebx,%edi
  800cb7:	89 de                	mov    %ebx,%esi
  800cb9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbb:	85 c0                	test   %eax,%eax
  800cbd:	7e 17                	jle    800cd6 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbf:	83 ec 0c             	sub    $0xc,%esp
  800cc2:	50                   	push   %eax
  800cc3:	6a 06                	push   $0x6
  800cc5:	68 7f 29 80 00       	push   $0x80297f
  800cca:	6a 23                	push   $0x23
  800ccc:	68 9c 29 80 00       	push   $0x80299c
  800cd1:	e8 e0 f4 ff ff       	call   8001b6 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd9:	5b                   	pop    %ebx
  800cda:	5e                   	pop    %esi
  800cdb:	5f                   	pop    %edi
  800cdc:	5d                   	pop    %ebp
  800cdd:	c3                   	ret    

00800cde <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cde:	55                   	push   %ebp
  800cdf:	89 e5                	mov    %esp,%ebp
  800ce1:	57                   	push   %edi
  800ce2:	56                   	push   %esi
  800ce3:	53                   	push   %ebx
  800ce4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cec:	b8 08 00 00 00       	mov    $0x8,%eax
  800cf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf7:	89 df                	mov    %ebx,%edi
  800cf9:	89 de                	mov    %ebx,%esi
  800cfb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfd:	85 c0                	test   %eax,%eax
  800cff:	7e 17                	jle    800d18 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d01:	83 ec 0c             	sub    $0xc,%esp
  800d04:	50                   	push   %eax
  800d05:	6a 08                	push   $0x8
  800d07:	68 7f 29 80 00       	push   $0x80297f
  800d0c:	6a 23                	push   $0x23
  800d0e:	68 9c 29 80 00       	push   $0x80299c
  800d13:	e8 9e f4 ff ff       	call   8001b6 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1b:	5b                   	pop    %ebx
  800d1c:	5e                   	pop    %esi
  800d1d:	5f                   	pop    %edi
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    

00800d20 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	57                   	push   %edi
  800d24:	56                   	push   %esi
  800d25:	53                   	push   %ebx
  800d26:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d29:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2e:	b8 09 00 00 00       	mov    $0x9,%eax
  800d33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d36:	8b 55 08             	mov    0x8(%ebp),%edx
  800d39:	89 df                	mov    %ebx,%edi
  800d3b:	89 de                	mov    %ebx,%esi
  800d3d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3f:	85 c0                	test   %eax,%eax
  800d41:	7e 17                	jle    800d5a <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d43:	83 ec 0c             	sub    $0xc,%esp
  800d46:	50                   	push   %eax
  800d47:	6a 09                	push   $0x9
  800d49:	68 7f 29 80 00       	push   $0x80297f
  800d4e:	6a 23                	push   $0x23
  800d50:	68 9c 29 80 00       	push   $0x80299c
  800d55:	e8 5c f4 ff ff       	call   8001b6 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5d:	5b                   	pop    %ebx
  800d5e:	5e                   	pop    %esi
  800d5f:	5f                   	pop    %edi
  800d60:	5d                   	pop    %ebp
  800d61:	c3                   	ret    

00800d62 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	57                   	push   %edi
  800d66:	56                   	push   %esi
  800d67:	53                   	push   %ebx
  800d68:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d70:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d78:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7b:	89 df                	mov    %ebx,%edi
  800d7d:	89 de                	mov    %ebx,%esi
  800d7f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d81:	85 c0                	test   %eax,%eax
  800d83:	7e 17                	jle    800d9c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d85:	83 ec 0c             	sub    $0xc,%esp
  800d88:	50                   	push   %eax
  800d89:	6a 0a                	push   $0xa
  800d8b:	68 7f 29 80 00       	push   $0x80297f
  800d90:	6a 23                	push   $0x23
  800d92:	68 9c 29 80 00       	push   $0x80299c
  800d97:	e8 1a f4 ff ff       	call   8001b6 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9f:	5b                   	pop    %ebx
  800da0:	5e                   	pop    %esi
  800da1:	5f                   	pop    %edi
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	57                   	push   %edi
  800da8:	56                   	push   %esi
  800da9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daa:	be 00 00 00 00       	mov    $0x0,%esi
  800daf:	b8 0c 00 00 00       	mov    $0xc,%eax
  800db4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dbd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dc0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dc2:	5b                   	pop    %ebx
  800dc3:	5e                   	pop    %esi
  800dc4:	5f                   	pop    %edi
  800dc5:	5d                   	pop    %ebp
  800dc6:	c3                   	ret    

00800dc7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc7:	55                   	push   %ebp
  800dc8:	89 e5                	mov    %esp,%ebp
  800dca:	57                   	push   %edi
  800dcb:	56                   	push   %esi
  800dcc:	53                   	push   %ebx
  800dcd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dda:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddd:	89 cb                	mov    %ecx,%ebx
  800ddf:	89 cf                	mov    %ecx,%edi
  800de1:	89 ce                	mov    %ecx,%esi
  800de3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de5:	85 c0                	test   %eax,%eax
  800de7:	7e 17                	jle    800e00 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de9:	83 ec 0c             	sub    $0xc,%esp
  800dec:	50                   	push   %eax
  800ded:	6a 0d                	push   $0xd
  800def:	68 7f 29 80 00       	push   $0x80297f
  800df4:	6a 23                	push   $0x23
  800df6:	68 9c 29 80 00       	push   $0x80299c
  800dfb:	e8 b6 f3 ff ff       	call   8001b6 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e03:	5b                   	pop    %ebx
  800e04:	5e                   	pop    %esi
  800e05:	5f                   	pop    %edi
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    

00800e08 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
  800e0b:	57                   	push   %edi
  800e0c:	56                   	push   %esi
  800e0d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e13:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e18:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1b:	89 cb                	mov    %ecx,%ebx
  800e1d:	89 cf                	mov    %ecx,%edi
  800e1f:	89 ce                	mov    %ecx,%esi
  800e21:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800e23:	5b                   	pop    %ebx
  800e24:	5e                   	pop    %esi
  800e25:	5f                   	pop    %edi
  800e26:	5d                   	pop    %ebp
  800e27:	c3                   	ret    

00800e28 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	57                   	push   %edi
  800e2c:	56                   	push   %esi
  800e2d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e33:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e38:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3b:	89 cb                	mov    %ecx,%ebx
  800e3d:	89 cf                	mov    %ecx,%edi
  800e3f:	89 ce                	mov    %ecx,%esi
  800e41:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800e43:	5b                   	pop    %ebx
  800e44:	5e                   	pop    %esi
  800e45:	5f                   	pop    %edi
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    

00800e48 <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	57                   	push   %edi
  800e4c:	56                   	push   %esi
  800e4d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e53:	b8 10 00 00 00       	mov    $0x10,%eax
  800e58:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5b:	89 cb                	mov    %ecx,%ebx
  800e5d:	89 cf                	mov    %ecx,%edi
  800e5f:	89 ce                	mov    %ecx,%esi
  800e61:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800e63:	5b                   	pop    %ebx
  800e64:	5e                   	pop    %esi
  800e65:	5f                   	pop    %edi
  800e66:	5d                   	pop    %ebp
  800e67:	c3                   	ret    

00800e68 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	53                   	push   %ebx
  800e6c:	83 ec 04             	sub    $0x4,%esp
  800e6f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e72:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800e74:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e78:	74 11                	je     800e8b <pgfault+0x23>
  800e7a:	89 d8                	mov    %ebx,%eax
  800e7c:	c1 e8 0c             	shr    $0xc,%eax
  800e7f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e86:	f6 c4 08             	test   $0x8,%ah
  800e89:	75 14                	jne    800e9f <pgfault+0x37>
		panic("faulting access");
  800e8b:	83 ec 04             	sub    $0x4,%esp
  800e8e:	68 aa 29 80 00       	push   $0x8029aa
  800e93:	6a 1f                	push   $0x1f
  800e95:	68 ba 29 80 00       	push   $0x8029ba
  800e9a:	e8 17 f3 ff ff       	call   8001b6 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e9f:	83 ec 04             	sub    $0x4,%esp
  800ea2:	6a 07                	push   $0x7
  800ea4:	68 00 f0 7f 00       	push   $0x7ff000
  800ea9:	6a 00                	push   $0x0
  800eab:	e8 67 fd ff ff       	call   800c17 <sys_page_alloc>
	if (r < 0) {
  800eb0:	83 c4 10             	add    $0x10,%esp
  800eb3:	85 c0                	test   %eax,%eax
  800eb5:	79 12                	jns    800ec9 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800eb7:	50                   	push   %eax
  800eb8:	68 c5 29 80 00       	push   $0x8029c5
  800ebd:	6a 2d                	push   $0x2d
  800ebf:	68 ba 29 80 00       	push   $0x8029ba
  800ec4:	e8 ed f2 ff ff       	call   8001b6 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800ec9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800ecf:	83 ec 04             	sub    $0x4,%esp
  800ed2:	68 00 10 00 00       	push   $0x1000
  800ed7:	53                   	push   %ebx
  800ed8:	68 00 f0 7f 00       	push   $0x7ff000
  800edd:	e8 2c fb ff ff       	call   800a0e <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800ee2:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ee9:	53                   	push   %ebx
  800eea:	6a 00                	push   $0x0
  800eec:	68 00 f0 7f 00       	push   $0x7ff000
  800ef1:	6a 00                	push   $0x0
  800ef3:	e8 62 fd ff ff       	call   800c5a <sys_page_map>
	if (r < 0) {
  800ef8:	83 c4 20             	add    $0x20,%esp
  800efb:	85 c0                	test   %eax,%eax
  800efd:	79 12                	jns    800f11 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800eff:	50                   	push   %eax
  800f00:	68 c5 29 80 00       	push   $0x8029c5
  800f05:	6a 34                	push   $0x34
  800f07:	68 ba 29 80 00       	push   $0x8029ba
  800f0c:	e8 a5 f2 ff ff       	call   8001b6 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800f11:	83 ec 08             	sub    $0x8,%esp
  800f14:	68 00 f0 7f 00       	push   $0x7ff000
  800f19:	6a 00                	push   $0x0
  800f1b:	e8 7c fd ff ff       	call   800c9c <sys_page_unmap>
	if (r < 0) {
  800f20:	83 c4 10             	add    $0x10,%esp
  800f23:	85 c0                	test   %eax,%eax
  800f25:	79 12                	jns    800f39 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800f27:	50                   	push   %eax
  800f28:	68 c5 29 80 00       	push   $0x8029c5
  800f2d:	6a 38                	push   $0x38
  800f2f:	68 ba 29 80 00       	push   $0x8029ba
  800f34:	e8 7d f2 ff ff       	call   8001b6 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800f39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f3c:	c9                   	leave  
  800f3d:	c3                   	ret    

00800f3e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f3e:	55                   	push   %ebp
  800f3f:	89 e5                	mov    %esp,%ebp
  800f41:	57                   	push   %edi
  800f42:	56                   	push   %esi
  800f43:	53                   	push   %ebx
  800f44:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800f47:	68 68 0e 80 00       	push   $0x800e68
  800f4c:	e8 24 12 00 00       	call   802175 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f51:	b8 07 00 00 00       	mov    $0x7,%eax
  800f56:	cd 30                	int    $0x30
  800f58:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800f5b:	83 c4 10             	add    $0x10,%esp
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	79 17                	jns    800f79 <fork+0x3b>
		panic("fork fault %e");
  800f62:	83 ec 04             	sub    $0x4,%esp
  800f65:	68 de 29 80 00       	push   $0x8029de
  800f6a:	68 85 00 00 00       	push   $0x85
  800f6f:	68 ba 29 80 00       	push   $0x8029ba
  800f74:	e8 3d f2 ff ff       	call   8001b6 <_panic>
  800f79:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f7b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f7f:	75 24                	jne    800fa5 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f81:	e8 53 fc ff ff       	call   800bd9 <sys_getenvid>
  800f86:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f8b:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800f91:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f96:	a3 20 60 80 00       	mov    %eax,0x806020
		return 0;
  800f9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa0:	e9 64 01 00 00       	jmp    801109 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800fa5:	83 ec 04             	sub    $0x4,%esp
  800fa8:	6a 07                	push   $0x7
  800faa:	68 00 f0 bf ee       	push   $0xeebff000
  800faf:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fb2:	e8 60 fc ff ff       	call   800c17 <sys_page_alloc>
  800fb7:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fba:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fbf:	89 d8                	mov    %ebx,%eax
  800fc1:	c1 e8 16             	shr    $0x16,%eax
  800fc4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fcb:	a8 01                	test   $0x1,%al
  800fcd:	0f 84 fc 00 00 00    	je     8010cf <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800fd3:	89 d8                	mov    %ebx,%eax
  800fd5:	c1 e8 0c             	shr    $0xc,%eax
  800fd8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fdf:	f6 c2 01             	test   $0x1,%dl
  800fe2:	0f 84 e7 00 00 00    	je     8010cf <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800fe8:	89 c6                	mov    %eax,%esi
  800fea:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800fed:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ff4:	f6 c6 04             	test   $0x4,%dh
  800ff7:	74 39                	je     801032 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800ff9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801000:	83 ec 0c             	sub    $0xc,%esp
  801003:	25 07 0e 00 00       	and    $0xe07,%eax
  801008:	50                   	push   %eax
  801009:	56                   	push   %esi
  80100a:	57                   	push   %edi
  80100b:	56                   	push   %esi
  80100c:	6a 00                	push   $0x0
  80100e:	e8 47 fc ff ff       	call   800c5a <sys_page_map>
		if (r < 0) {
  801013:	83 c4 20             	add    $0x20,%esp
  801016:	85 c0                	test   %eax,%eax
  801018:	0f 89 b1 00 00 00    	jns    8010cf <fork+0x191>
		    	panic("sys page map fault %e");
  80101e:	83 ec 04             	sub    $0x4,%esp
  801021:	68 ec 29 80 00       	push   $0x8029ec
  801026:	6a 55                	push   $0x55
  801028:	68 ba 29 80 00       	push   $0x8029ba
  80102d:	e8 84 f1 ff ff       	call   8001b6 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801032:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801039:	f6 c2 02             	test   $0x2,%dl
  80103c:	75 0c                	jne    80104a <fork+0x10c>
  80103e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801045:	f6 c4 08             	test   $0x8,%ah
  801048:	74 5b                	je     8010a5 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80104a:	83 ec 0c             	sub    $0xc,%esp
  80104d:	68 05 08 00 00       	push   $0x805
  801052:	56                   	push   %esi
  801053:	57                   	push   %edi
  801054:	56                   	push   %esi
  801055:	6a 00                	push   $0x0
  801057:	e8 fe fb ff ff       	call   800c5a <sys_page_map>
		if (r < 0) {
  80105c:	83 c4 20             	add    $0x20,%esp
  80105f:	85 c0                	test   %eax,%eax
  801061:	79 14                	jns    801077 <fork+0x139>
		    	panic("sys page map fault %e");
  801063:	83 ec 04             	sub    $0x4,%esp
  801066:	68 ec 29 80 00       	push   $0x8029ec
  80106b:	6a 5c                	push   $0x5c
  80106d:	68 ba 29 80 00       	push   $0x8029ba
  801072:	e8 3f f1 ff ff       	call   8001b6 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  801077:	83 ec 0c             	sub    $0xc,%esp
  80107a:	68 05 08 00 00       	push   $0x805
  80107f:	56                   	push   %esi
  801080:	6a 00                	push   $0x0
  801082:	56                   	push   %esi
  801083:	6a 00                	push   $0x0
  801085:	e8 d0 fb ff ff       	call   800c5a <sys_page_map>
		if (r < 0) {
  80108a:	83 c4 20             	add    $0x20,%esp
  80108d:	85 c0                	test   %eax,%eax
  80108f:	79 3e                	jns    8010cf <fork+0x191>
		    	panic("sys page map fault %e");
  801091:	83 ec 04             	sub    $0x4,%esp
  801094:	68 ec 29 80 00       	push   $0x8029ec
  801099:	6a 60                	push   $0x60
  80109b:	68 ba 29 80 00       	push   $0x8029ba
  8010a0:	e8 11 f1 ff ff       	call   8001b6 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8010a5:	83 ec 0c             	sub    $0xc,%esp
  8010a8:	6a 05                	push   $0x5
  8010aa:	56                   	push   %esi
  8010ab:	57                   	push   %edi
  8010ac:	56                   	push   %esi
  8010ad:	6a 00                	push   $0x0
  8010af:	e8 a6 fb ff ff       	call   800c5a <sys_page_map>
		if (r < 0) {
  8010b4:	83 c4 20             	add    $0x20,%esp
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	79 14                	jns    8010cf <fork+0x191>
		    	panic("sys page map fault %e");
  8010bb:	83 ec 04             	sub    $0x4,%esp
  8010be:	68 ec 29 80 00       	push   $0x8029ec
  8010c3:	6a 65                	push   $0x65
  8010c5:	68 ba 29 80 00       	push   $0x8029ba
  8010ca:	e8 e7 f0 ff ff       	call   8001b6 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8010cf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010d5:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8010db:	0f 85 de fe ff ff    	jne    800fbf <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8010e1:	a1 20 60 80 00       	mov    0x806020,%eax
  8010e6:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  8010ec:	83 ec 08             	sub    $0x8,%esp
  8010ef:	50                   	push   %eax
  8010f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010f3:	57                   	push   %edi
  8010f4:	e8 69 fc ff ff       	call   800d62 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8010f9:	83 c4 08             	add    $0x8,%esp
  8010fc:	6a 02                	push   $0x2
  8010fe:	57                   	push   %edi
  8010ff:	e8 da fb ff ff       	call   800cde <sys_env_set_status>
	
	return envid;
  801104:	83 c4 10             	add    $0x10,%esp
  801107:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801109:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80110c:	5b                   	pop    %ebx
  80110d:	5e                   	pop    %esi
  80110e:	5f                   	pop    %edi
  80110f:	5d                   	pop    %ebp
  801110:	c3                   	ret    

00801111 <sfork>:

envid_t
sfork(void)
{
  801111:	55                   	push   %ebp
  801112:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801114:	b8 00 00 00 00       	mov    $0x0,%eax
  801119:	5d                   	pop    %ebp
  80111a:	c3                   	ret    

0080111b <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  801121:	8b 45 08             	mov    0x8(%ebp),%eax
  801124:	a3 24 60 80 00       	mov    %eax,0x806024
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801129:	68 7c 01 80 00       	push   $0x80017c
  80112e:	e8 d5 fc ff ff       	call   800e08 <sys_thread_create>

	return id;
}
  801133:	c9                   	leave  
  801134:	c3                   	ret    

00801135 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  80113b:	ff 75 08             	pushl  0x8(%ebp)
  80113e:	e8 e5 fc ff ff       	call   800e28 <sys_thread_free>
}
  801143:	83 c4 10             	add    $0x10,%esp
  801146:	c9                   	leave  
  801147:	c3                   	ret    

00801148 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  801148:	55                   	push   %ebp
  801149:	89 e5                	mov    %esp,%ebp
  80114b:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  80114e:	ff 75 08             	pushl  0x8(%ebp)
  801151:	e8 f2 fc ff ff       	call   800e48 <sys_thread_join>
}
  801156:	83 c4 10             	add    $0x10,%esp
  801159:	c9                   	leave  
  80115a:	c3                   	ret    

0080115b <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  80115b:	55                   	push   %ebp
  80115c:	89 e5                	mov    %esp,%ebp
  80115e:	56                   	push   %esi
  80115f:	53                   	push   %ebx
  801160:	8b 75 08             	mov    0x8(%ebp),%esi
  801163:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  801166:	83 ec 04             	sub    $0x4,%esp
  801169:	6a 07                	push   $0x7
  80116b:	6a 00                	push   $0x0
  80116d:	56                   	push   %esi
  80116e:	e8 a4 fa ff ff       	call   800c17 <sys_page_alloc>
	if (r < 0) {
  801173:	83 c4 10             	add    $0x10,%esp
  801176:	85 c0                	test   %eax,%eax
  801178:	79 15                	jns    80118f <queue_append+0x34>
		panic("%e\n", r);
  80117a:	50                   	push   %eax
  80117b:	68 56 26 80 00       	push   $0x802656
  801180:	68 d5 00 00 00       	push   $0xd5
  801185:	68 ba 29 80 00       	push   $0x8029ba
  80118a:	e8 27 f0 ff ff       	call   8001b6 <_panic>
	}	

	wt->envid = envid;
  80118f:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  801195:	83 3b 00             	cmpl   $0x0,(%ebx)
  801198:	75 13                	jne    8011ad <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  80119a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  8011a1:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8011a8:	00 00 00 
  8011ab:	eb 1b                	jmp    8011c8 <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  8011ad:	8b 43 04             	mov    0x4(%ebx),%eax
  8011b0:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  8011b7:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8011be:	00 00 00 
		queue->last = wt;
  8011c1:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8011c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011cb:	5b                   	pop    %ebx
  8011cc:	5e                   	pop    %esi
  8011cd:	5d                   	pop    %ebp
  8011ce:	c3                   	ret    

008011cf <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  8011cf:	55                   	push   %ebp
  8011d0:	89 e5                	mov    %esp,%ebp
  8011d2:	83 ec 08             	sub    $0x8,%esp
  8011d5:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  8011d8:	8b 02                	mov    (%edx),%eax
  8011da:	85 c0                	test   %eax,%eax
  8011dc:	75 17                	jne    8011f5 <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  8011de:	83 ec 04             	sub    $0x4,%esp
  8011e1:	68 02 2a 80 00       	push   $0x802a02
  8011e6:	68 ec 00 00 00       	push   $0xec
  8011eb:	68 ba 29 80 00       	push   $0x8029ba
  8011f0:	e8 c1 ef ff ff       	call   8001b6 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  8011f5:	8b 48 04             	mov    0x4(%eax),%ecx
  8011f8:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  8011fa:	8b 00                	mov    (%eax),%eax
}
  8011fc:	c9                   	leave  
  8011fd:	c3                   	ret    

008011fe <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  8011fe:	55                   	push   %ebp
  8011ff:	89 e5                	mov    %esp,%ebp
  801201:	56                   	push   %esi
  801202:	53                   	push   %ebx
  801203:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801206:	b8 01 00 00 00       	mov    $0x1,%eax
  80120b:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  80120e:	85 c0                	test   %eax,%eax
  801210:	74 4a                	je     80125c <mutex_lock+0x5e>
  801212:	8b 73 04             	mov    0x4(%ebx),%esi
  801215:	83 3e 00             	cmpl   $0x0,(%esi)
  801218:	75 42                	jne    80125c <mutex_lock+0x5e>
		queue_append(sys_getenvid(), mtx->queue);		
  80121a:	e8 ba f9 ff ff       	call   800bd9 <sys_getenvid>
  80121f:	83 ec 08             	sub    $0x8,%esp
  801222:	56                   	push   %esi
  801223:	50                   	push   %eax
  801224:	e8 32 ff ff ff       	call   80115b <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  801229:	e8 ab f9 ff ff       	call   800bd9 <sys_getenvid>
  80122e:	83 c4 08             	add    $0x8,%esp
  801231:	6a 04                	push   $0x4
  801233:	50                   	push   %eax
  801234:	e8 a5 fa ff ff       	call   800cde <sys_env_set_status>

		if (r < 0) {
  801239:	83 c4 10             	add    $0x10,%esp
  80123c:	85 c0                	test   %eax,%eax
  80123e:	79 15                	jns    801255 <mutex_lock+0x57>
			panic("%e\n", r);
  801240:	50                   	push   %eax
  801241:	68 56 26 80 00       	push   $0x802656
  801246:	68 02 01 00 00       	push   $0x102
  80124b:	68 ba 29 80 00       	push   $0x8029ba
  801250:	e8 61 ef ff ff       	call   8001b6 <_panic>
		}
		sys_yield();
  801255:	e8 9e f9 ff ff       	call   800bf8 <sys_yield>
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  80125a:	eb 08                	jmp    801264 <mutex_lock+0x66>
		if (r < 0) {
			panic("%e\n", r);
		}
		sys_yield();
	} else {
		mtx->owner = sys_getenvid();
  80125c:	e8 78 f9 ff ff       	call   800bd9 <sys_getenvid>
  801261:	89 43 08             	mov    %eax,0x8(%ebx)
	}
}
  801264:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801267:	5b                   	pop    %ebx
  801268:	5e                   	pop    %esi
  801269:	5d                   	pop    %ebp
  80126a:	c3                   	ret    

0080126b <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  80126b:	55                   	push   %ebp
  80126c:	89 e5                	mov    %esp,%ebp
  80126e:	53                   	push   %ebx
  80126f:	83 ec 04             	sub    $0x4,%esp
  801272:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801275:	b8 00 00 00 00       	mov    $0x0,%eax
  80127a:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  80127d:	8b 43 04             	mov    0x4(%ebx),%eax
  801280:	83 38 00             	cmpl   $0x0,(%eax)
  801283:	74 33                	je     8012b8 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  801285:	83 ec 0c             	sub    $0xc,%esp
  801288:	50                   	push   %eax
  801289:	e8 41 ff ff ff       	call   8011cf <queue_pop>
  80128e:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  801291:	83 c4 08             	add    $0x8,%esp
  801294:	6a 02                	push   $0x2
  801296:	50                   	push   %eax
  801297:	e8 42 fa ff ff       	call   800cde <sys_env_set_status>
		if (r < 0) {
  80129c:	83 c4 10             	add    $0x10,%esp
  80129f:	85 c0                	test   %eax,%eax
  8012a1:	79 15                	jns    8012b8 <mutex_unlock+0x4d>
			panic("%e\n", r);
  8012a3:	50                   	push   %eax
  8012a4:	68 56 26 80 00       	push   $0x802656
  8012a9:	68 16 01 00 00       	push   $0x116
  8012ae:	68 ba 29 80 00       	push   $0x8029ba
  8012b3:	e8 fe ee ff ff       	call   8001b6 <_panic>
		}
	}

	//asm volatile("pause"); 	// might be useless here
}
  8012b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012bb:	c9                   	leave  
  8012bc:	c3                   	ret    

008012bd <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
  8012c0:	53                   	push   %ebx
  8012c1:	83 ec 04             	sub    $0x4,%esp
  8012c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8012c7:	e8 0d f9 ff ff       	call   800bd9 <sys_getenvid>
  8012cc:	83 ec 04             	sub    $0x4,%esp
  8012cf:	6a 07                	push   $0x7
  8012d1:	53                   	push   %ebx
  8012d2:	50                   	push   %eax
  8012d3:	e8 3f f9 ff ff       	call   800c17 <sys_page_alloc>
  8012d8:	83 c4 10             	add    $0x10,%esp
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	79 15                	jns    8012f4 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  8012df:	50                   	push   %eax
  8012e0:	68 1d 2a 80 00       	push   $0x802a1d
  8012e5:	68 22 01 00 00       	push   $0x122
  8012ea:	68 ba 29 80 00       	push   $0x8029ba
  8012ef:	e8 c2 ee ff ff       	call   8001b6 <_panic>
	}	
	mtx->locked = 0;
  8012f4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  8012fa:	8b 43 04             	mov    0x4(%ebx),%eax
  8012fd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  801303:	8b 43 04             	mov    0x4(%ebx),%eax
  801306:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  80130d:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  801314:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801317:	c9                   	leave  
  801318:	c3                   	ret    

00801319 <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  801319:	55                   	push   %ebp
  80131a:	89 e5                	mov    %esp,%ebp
  80131c:	53                   	push   %ebx
  80131d:	83 ec 04             	sub    $0x4,%esp
  801320:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue->first != NULL) {
  801323:	eb 21                	jmp    801346 <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
  801325:	83 ec 0c             	sub    $0xc,%esp
  801328:	50                   	push   %eax
  801329:	e8 a1 fe ff ff       	call   8011cf <queue_pop>
  80132e:	83 c4 08             	add    $0x8,%esp
  801331:	6a 02                	push   $0x2
  801333:	50                   	push   %eax
  801334:	e8 a5 f9 ff ff       	call   800cde <sys_env_set_status>
		mtx->queue->first = mtx->queue->first->next;
  801339:	8b 43 04             	mov    0x4(%ebx),%eax
  80133c:	8b 10                	mov    (%eax),%edx
  80133e:	8b 52 04             	mov    0x4(%edx),%edx
  801341:	89 10                	mov    %edx,(%eax)
  801343:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue->first != NULL) {
  801346:	8b 43 04             	mov    0x4(%ebx),%eax
  801349:	83 38 00             	cmpl   $0x0,(%eax)
  80134c:	75 d7                	jne    801325 <mutex_destroy+0xc>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
		mtx->queue->first = mtx->queue->first->next;
	}

	memset(mtx, 0, PGSIZE);
  80134e:	83 ec 04             	sub    $0x4,%esp
  801351:	68 00 10 00 00       	push   $0x1000
  801356:	6a 00                	push   $0x0
  801358:	53                   	push   %ebx
  801359:	e8 fb f5 ff ff       	call   800959 <memset>
	mtx = NULL;
}
  80135e:	83 c4 10             	add    $0x10,%esp
  801361:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801364:	c9                   	leave  
  801365:	c3                   	ret    

00801366 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801366:	55                   	push   %ebp
  801367:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801369:	8b 45 08             	mov    0x8(%ebp),%eax
  80136c:	05 00 00 00 30       	add    $0x30000000,%eax
  801371:	c1 e8 0c             	shr    $0xc,%eax
}
  801374:	5d                   	pop    %ebp
  801375:	c3                   	ret    

00801376 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801376:	55                   	push   %ebp
  801377:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801379:	8b 45 08             	mov    0x8(%ebp),%eax
  80137c:	05 00 00 00 30       	add    $0x30000000,%eax
  801381:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801386:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80138b:	5d                   	pop    %ebp
  80138c:	c3                   	ret    

0080138d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80138d:	55                   	push   %ebp
  80138e:	89 e5                	mov    %esp,%ebp
  801390:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801393:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801398:	89 c2                	mov    %eax,%edx
  80139a:	c1 ea 16             	shr    $0x16,%edx
  80139d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013a4:	f6 c2 01             	test   $0x1,%dl
  8013a7:	74 11                	je     8013ba <fd_alloc+0x2d>
  8013a9:	89 c2                	mov    %eax,%edx
  8013ab:	c1 ea 0c             	shr    $0xc,%edx
  8013ae:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013b5:	f6 c2 01             	test   $0x1,%dl
  8013b8:	75 09                	jne    8013c3 <fd_alloc+0x36>
			*fd_store = fd;
  8013ba:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c1:	eb 17                	jmp    8013da <fd_alloc+0x4d>
  8013c3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013c8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013cd:	75 c9                	jne    801398 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013cf:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8013d5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013da:	5d                   	pop    %ebp
  8013db:	c3                   	ret    

008013dc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013e2:	83 f8 1f             	cmp    $0x1f,%eax
  8013e5:	77 36                	ja     80141d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013e7:	c1 e0 0c             	shl    $0xc,%eax
  8013ea:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013ef:	89 c2                	mov    %eax,%edx
  8013f1:	c1 ea 16             	shr    $0x16,%edx
  8013f4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013fb:	f6 c2 01             	test   $0x1,%dl
  8013fe:	74 24                	je     801424 <fd_lookup+0x48>
  801400:	89 c2                	mov    %eax,%edx
  801402:	c1 ea 0c             	shr    $0xc,%edx
  801405:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80140c:	f6 c2 01             	test   $0x1,%dl
  80140f:	74 1a                	je     80142b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801411:	8b 55 0c             	mov    0xc(%ebp),%edx
  801414:	89 02                	mov    %eax,(%edx)
	return 0;
  801416:	b8 00 00 00 00       	mov    $0x0,%eax
  80141b:	eb 13                	jmp    801430 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80141d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801422:	eb 0c                	jmp    801430 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801424:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801429:	eb 05                	jmp    801430 <fd_lookup+0x54>
  80142b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801430:	5d                   	pop    %ebp
  801431:	c3                   	ret    

00801432 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801432:	55                   	push   %ebp
  801433:	89 e5                	mov    %esp,%ebp
  801435:	83 ec 08             	sub    $0x8,%esp
  801438:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80143b:	ba b8 2a 80 00       	mov    $0x802ab8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801440:	eb 13                	jmp    801455 <dev_lookup+0x23>
  801442:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801445:	39 08                	cmp    %ecx,(%eax)
  801447:	75 0c                	jne    801455 <dev_lookup+0x23>
			*dev = devtab[i];
  801449:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80144c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80144e:	b8 00 00 00 00       	mov    $0x0,%eax
  801453:	eb 31                	jmp    801486 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801455:	8b 02                	mov    (%edx),%eax
  801457:	85 c0                	test   %eax,%eax
  801459:	75 e7                	jne    801442 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80145b:	a1 20 60 80 00       	mov    0x806020,%eax
  801460:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801466:	83 ec 04             	sub    $0x4,%esp
  801469:	51                   	push   %ecx
  80146a:	50                   	push   %eax
  80146b:	68 38 2a 80 00       	push   $0x802a38
  801470:	e8 1a ee ff ff       	call   80028f <cprintf>
	*dev = 0;
  801475:	8b 45 0c             	mov    0xc(%ebp),%eax
  801478:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80147e:	83 c4 10             	add    $0x10,%esp
  801481:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801486:	c9                   	leave  
  801487:	c3                   	ret    

00801488 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801488:	55                   	push   %ebp
  801489:	89 e5                	mov    %esp,%ebp
  80148b:	56                   	push   %esi
  80148c:	53                   	push   %ebx
  80148d:	83 ec 10             	sub    $0x10,%esp
  801490:	8b 75 08             	mov    0x8(%ebp),%esi
  801493:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801496:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801499:	50                   	push   %eax
  80149a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014a0:	c1 e8 0c             	shr    $0xc,%eax
  8014a3:	50                   	push   %eax
  8014a4:	e8 33 ff ff ff       	call   8013dc <fd_lookup>
  8014a9:	83 c4 08             	add    $0x8,%esp
  8014ac:	85 c0                	test   %eax,%eax
  8014ae:	78 05                	js     8014b5 <fd_close+0x2d>
	    || fd != fd2)
  8014b0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014b3:	74 0c                	je     8014c1 <fd_close+0x39>
		return (must_exist ? r : 0);
  8014b5:	84 db                	test   %bl,%bl
  8014b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014bc:	0f 44 c2             	cmove  %edx,%eax
  8014bf:	eb 41                	jmp    801502 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014c1:	83 ec 08             	sub    $0x8,%esp
  8014c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c7:	50                   	push   %eax
  8014c8:	ff 36                	pushl  (%esi)
  8014ca:	e8 63 ff ff ff       	call   801432 <dev_lookup>
  8014cf:	89 c3                	mov    %eax,%ebx
  8014d1:	83 c4 10             	add    $0x10,%esp
  8014d4:	85 c0                	test   %eax,%eax
  8014d6:	78 1a                	js     8014f2 <fd_close+0x6a>
		if (dev->dev_close)
  8014d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014db:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8014de:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8014e3:	85 c0                	test   %eax,%eax
  8014e5:	74 0b                	je     8014f2 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014e7:	83 ec 0c             	sub    $0xc,%esp
  8014ea:	56                   	push   %esi
  8014eb:	ff d0                	call   *%eax
  8014ed:	89 c3                	mov    %eax,%ebx
  8014ef:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014f2:	83 ec 08             	sub    $0x8,%esp
  8014f5:	56                   	push   %esi
  8014f6:	6a 00                	push   $0x0
  8014f8:	e8 9f f7 ff ff       	call   800c9c <sys_page_unmap>
	return r;
  8014fd:	83 c4 10             	add    $0x10,%esp
  801500:	89 d8                	mov    %ebx,%eax
}
  801502:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801505:	5b                   	pop    %ebx
  801506:	5e                   	pop    %esi
  801507:	5d                   	pop    %ebp
  801508:	c3                   	ret    

00801509 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801509:	55                   	push   %ebp
  80150a:	89 e5                	mov    %esp,%ebp
  80150c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80150f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801512:	50                   	push   %eax
  801513:	ff 75 08             	pushl  0x8(%ebp)
  801516:	e8 c1 fe ff ff       	call   8013dc <fd_lookup>
  80151b:	83 c4 08             	add    $0x8,%esp
  80151e:	85 c0                	test   %eax,%eax
  801520:	78 10                	js     801532 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801522:	83 ec 08             	sub    $0x8,%esp
  801525:	6a 01                	push   $0x1
  801527:	ff 75 f4             	pushl  -0xc(%ebp)
  80152a:	e8 59 ff ff ff       	call   801488 <fd_close>
  80152f:	83 c4 10             	add    $0x10,%esp
}
  801532:	c9                   	leave  
  801533:	c3                   	ret    

00801534 <close_all>:

void
close_all(void)
{
  801534:	55                   	push   %ebp
  801535:	89 e5                	mov    %esp,%ebp
  801537:	53                   	push   %ebx
  801538:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80153b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801540:	83 ec 0c             	sub    $0xc,%esp
  801543:	53                   	push   %ebx
  801544:	e8 c0 ff ff ff       	call   801509 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801549:	83 c3 01             	add    $0x1,%ebx
  80154c:	83 c4 10             	add    $0x10,%esp
  80154f:	83 fb 20             	cmp    $0x20,%ebx
  801552:	75 ec                	jne    801540 <close_all+0xc>
		close(i);
}
  801554:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801557:	c9                   	leave  
  801558:	c3                   	ret    

00801559 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801559:	55                   	push   %ebp
  80155a:	89 e5                	mov    %esp,%ebp
  80155c:	57                   	push   %edi
  80155d:	56                   	push   %esi
  80155e:	53                   	push   %ebx
  80155f:	83 ec 2c             	sub    $0x2c,%esp
  801562:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801565:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801568:	50                   	push   %eax
  801569:	ff 75 08             	pushl  0x8(%ebp)
  80156c:	e8 6b fe ff ff       	call   8013dc <fd_lookup>
  801571:	83 c4 08             	add    $0x8,%esp
  801574:	85 c0                	test   %eax,%eax
  801576:	0f 88 c1 00 00 00    	js     80163d <dup+0xe4>
		return r;
	close(newfdnum);
  80157c:	83 ec 0c             	sub    $0xc,%esp
  80157f:	56                   	push   %esi
  801580:	e8 84 ff ff ff       	call   801509 <close>

	newfd = INDEX2FD(newfdnum);
  801585:	89 f3                	mov    %esi,%ebx
  801587:	c1 e3 0c             	shl    $0xc,%ebx
  80158a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801590:	83 c4 04             	add    $0x4,%esp
  801593:	ff 75 e4             	pushl  -0x1c(%ebp)
  801596:	e8 db fd ff ff       	call   801376 <fd2data>
  80159b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80159d:	89 1c 24             	mov    %ebx,(%esp)
  8015a0:	e8 d1 fd ff ff       	call   801376 <fd2data>
  8015a5:	83 c4 10             	add    $0x10,%esp
  8015a8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015ab:	89 f8                	mov    %edi,%eax
  8015ad:	c1 e8 16             	shr    $0x16,%eax
  8015b0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015b7:	a8 01                	test   $0x1,%al
  8015b9:	74 37                	je     8015f2 <dup+0x99>
  8015bb:	89 f8                	mov    %edi,%eax
  8015bd:	c1 e8 0c             	shr    $0xc,%eax
  8015c0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015c7:	f6 c2 01             	test   $0x1,%dl
  8015ca:	74 26                	je     8015f2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015cc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015d3:	83 ec 0c             	sub    $0xc,%esp
  8015d6:	25 07 0e 00 00       	and    $0xe07,%eax
  8015db:	50                   	push   %eax
  8015dc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015df:	6a 00                	push   $0x0
  8015e1:	57                   	push   %edi
  8015e2:	6a 00                	push   $0x0
  8015e4:	e8 71 f6 ff ff       	call   800c5a <sys_page_map>
  8015e9:	89 c7                	mov    %eax,%edi
  8015eb:	83 c4 20             	add    $0x20,%esp
  8015ee:	85 c0                	test   %eax,%eax
  8015f0:	78 2e                	js     801620 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015f2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015f5:	89 d0                	mov    %edx,%eax
  8015f7:	c1 e8 0c             	shr    $0xc,%eax
  8015fa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801601:	83 ec 0c             	sub    $0xc,%esp
  801604:	25 07 0e 00 00       	and    $0xe07,%eax
  801609:	50                   	push   %eax
  80160a:	53                   	push   %ebx
  80160b:	6a 00                	push   $0x0
  80160d:	52                   	push   %edx
  80160e:	6a 00                	push   $0x0
  801610:	e8 45 f6 ff ff       	call   800c5a <sys_page_map>
  801615:	89 c7                	mov    %eax,%edi
  801617:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80161a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80161c:	85 ff                	test   %edi,%edi
  80161e:	79 1d                	jns    80163d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801620:	83 ec 08             	sub    $0x8,%esp
  801623:	53                   	push   %ebx
  801624:	6a 00                	push   $0x0
  801626:	e8 71 f6 ff ff       	call   800c9c <sys_page_unmap>
	sys_page_unmap(0, nva);
  80162b:	83 c4 08             	add    $0x8,%esp
  80162e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801631:	6a 00                	push   $0x0
  801633:	e8 64 f6 ff ff       	call   800c9c <sys_page_unmap>
	return r;
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	89 f8                	mov    %edi,%eax
}
  80163d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801640:	5b                   	pop    %ebx
  801641:	5e                   	pop    %esi
  801642:	5f                   	pop    %edi
  801643:	5d                   	pop    %ebp
  801644:	c3                   	ret    

00801645 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
  801648:	53                   	push   %ebx
  801649:	83 ec 14             	sub    $0x14,%esp
  80164c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80164f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801652:	50                   	push   %eax
  801653:	53                   	push   %ebx
  801654:	e8 83 fd ff ff       	call   8013dc <fd_lookup>
  801659:	83 c4 08             	add    $0x8,%esp
  80165c:	89 c2                	mov    %eax,%edx
  80165e:	85 c0                	test   %eax,%eax
  801660:	78 70                	js     8016d2 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801662:	83 ec 08             	sub    $0x8,%esp
  801665:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801668:	50                   	push   %eax
  801669:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166c:	ff 30                	pushl  (%eax)
  80166e:	e8 bf fd ff ff       	call   801432 <dev_lookup>
  801673:	83 c4 10             	add    $0x10,%esp
  801676:	85 c0                	test   %eax,%eax
  801678:	78 4f                	js     8016c9 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80167a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80167d:	8b 42 08             	mov    0x8(%edx),%eax
  801680:	83 e0 03             	and    $0x3,%eax
  801683:	83 f8 01             	cmp    $0x1,%eax
  801686:	75 24                	jne    8016ac <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801688:	a1 20 60 80 00       	mov    0x806020,%eax
  80168d:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801693:	83 ec 04             	sub    $0x4,%esp
  801696:	53                   	push   %ebx
  801697:	50                   	push   %eax
  801698:	68 7c 2a 80 00       	push   $0x802a7c
  80169d:	e8 ed eb ff ff       	call   80028f <cprintf>
		return -E_INVAL;
  8016a2:	83 c4 10             	add    $0x10,%esp
  8016a5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016aa:	eb 26                	jmp    8016d2 <read+0x8d>
	}
	if (!dev->dev_read)
  8016ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016af:	8b 40 08             	mov    0x8(%eax),%eax
  8016b2:	85 c0                	test   %eax,%eax
  8016b4:	74 17                	je     8016cd <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8016b6:	83 ec 04             	sub    $0x4,%esp
  8016b9:	ff 75 10             	pushl  0x10(%ebp)
  8016bc:	ff 75 0c             	pushl  0xc(%ebp)
  8016bf:	52                   	push   %edx
  8016c0:	ff d0                	call   *%eax
  8016c2:	89 c2                	mov    %eax,%edx
  8016c4:	83 c4 10             	add    $0x10,%esp
  8016c7:	eb 09                	jmp    8016d2 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c9:	89 c2                	mov    %eax,%edx
  8016cb:	eb 05                	jmp    8016d2 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016cd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8016d2:	89 d0                	mov    %edx,%eax
  8016d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d7:	c9                   	leave  
  8016d8:	c3                   	ret    

008016d9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016d9:	55                   	push   %ebp
  8016da:	89 e5                	mov    %esp,%ebp
  8016dc:	57                   	push   %edi
  8016dd:	56                   	push   %esi
  8016de:	53                   	push   %ebx
  8016df:	83 ec 0c             	sub    $0xc,%esp
  8016e2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016e5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016ed:	eb 21                	jmp    801710 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016ef:	83 ec 04             	sub    $0x4,%esp
  8016f2:	89 f0                	mov    %esi,%eax
  8016f4:	29 d8                	sub    %ebx,%eax
  8016f6:	50                   	push   %eax
  8016f7:	89 d8                	mov    %ebx,%eax
  8016f9:	03 45 0c             	add    0xc(%ebp),%eax
  8016fc:	50                   	push   %eax
  8016fd:	57                   	push   %edi
  8016fe:	e8 42 ff ff ff       	call   801645 <read>
		if (m < 0)
  801703:	83 c4 10             	add    $0x10,%esp
  801706:	85 c0                	test   %eax,%eax
  801708:	78 10                	js     80171a <readn+0x41>
			return m;
		if (m == 0)
  80170a:	85 c0                	test   %eax,%eax
  80170c:	74 0a                	je     801718 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80170e:	01 c3                	add    %eax,%ebx
  801710:	39 f3                	cmp    %esi,%ebx
  801712:	72 db                	jb     8016ef <readn+0x16>
  801714:	89 d8                	mov    %ebx,%eax
  801716:	eb 02                	jmp    80171a <readn+0x41>
  801718:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80171a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80171d:	5b                   	pop    %ebx
  80171e:	5e                   	pop    %esi
  80171f:	5f                   	pop    %edi
  801720:	5d                   	pop    %ebp
  801721:	c3                   	ret    

00801722 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801722:	55                   	push   %ebp
  801723:	89 e5                	mov    %esp,%ebp
  801725:	53                   	push   %ebx
  801726:	83 ec 14             	sub    $0x14,%esp
  801729:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80172c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80172f:	50                   	push   %eax
  801730:	53                   	push   %ebx
  801731:	e8 a6 fc ff ff       	call   8013dc <fd_lookup>
  801736:	83 c4 08             	add    $0x8,%esp
  801739:	89 c2                	mov    %eax,%edx
  80173b:	85 c0                	test   %eax,%eax
  80173d:	78 6b                	js     8017aa <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173f:	83 ec 08             	sub    $0x8,%esp
  801742:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801745:	50                   	push   %eax
  801746:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801749:	ff 30                	pushl  (%eax)
  80174b:	e8 e2 fc ff ff       	call   801432 <dev_lookup>
  801750:	83 c4 10             	add    $0x10,%esp
  801753:	85 c0                	test   %eax,%eax
  801755:	78 4a                	js     8017a1 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801757:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80175a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80175e:	75 24                	jne    801784 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801760:	a1 20 60 80 00       	mov    0x806020,%eax
  801765:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80176b:	83 ec 04             	sub    $0x4,%esp
  80176e:	53                   	push   %ebx
  80176f:	50                   	push   %eax
  801770:	68 98 2a 80 00       	push   $0x802a98
  801775:	e8 15 eb ff ff       	call   80028f <cprintf>
		return -E_INVAL;
  80177a:	83 c4 10             	add    $0x10,%esp
  80177d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801782:	eb 26                	jmp    8017aa <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801784:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801787:	8b 52 0c             	mov    0xc(%edx),%edx
  80178a:	85 d2                	test   %edx,%edx
  80178c:	74 17                	je     8017a5 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80178e:	83 ec 04             	sub    $0x4,%esp
  801791:	ff 75 10             	pushl  0x10(%ebp)
  801794:	ff 75 0c             	pushl  0xc(%ebp)
  801797:	50                   	push   %eax
  801798:	ff d2                	call   *%edx
  80179a:	89 c2                	mov    %eax,%edx
  80179c:	83 c4 10             	add    $0x10,%esp
  80179f:	eb 09                	jmp    8017aa <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a1:	89 c2                	mov    %eax,%edx
  8017a3:	eb 05                	jmp    8017aa <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017a5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8017aa:	89 d0                	mov    %edx,%eax
  8017ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017af:	c9                   	leave  
  8017b0:	c3                   	ret    

008017b1 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017b1:	55                   	push   %ebp
  8017b2:	89 e5                	mov    %esp,%ebp
  8017b4:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017b7:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017ba:	50                   	push   %eax
  8017bb:	ff 75 08             	pushl  0x8(%ebp)
  8017be:	e8 19 fc ff ff       	call   8013dc <fd_lookup>
  8017c3:	83 c4 08             	add    $0x8,%esp
  8017c6:	85 c0                	test   %eax,%eax
  8017c8:	78 0e                	js     8017d8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017d0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d8:	c9                   	leave  
  8017d9:	c3                   	ret    

008017da <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017da:	55                   	push   %ebp
  8017db:	89 e5                	mov    %esp,%ebp
  8017dd:	53                   	push   %ebx
  8017de:	83 ec 14             	sub    $0x14,%esp
  8017e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e7:	50                   	push   %eax
  8017e8:	53                   	push   %ebx
  8017e9:	e8 ee fb ff ff       	call   8013dc <fd_lookup>
  8017ee:	83 c4 08             	add    $0x8,%esp
  8017f1:	89 c2                	mov    %eax,%edx
  8017f3:	85 c0                	test   %eax,%eax
  8017f5:	78 68                	js     80185f <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f7:	83 ec 08             	sub    $0x8,%esp
  8017fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017fd:	50                   	push   %eax
  8017fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801801:	ff 30                	pushl  (%eax)
  801803:	e8 2a fc ff ff       	call   801432 <dev_lookup>
  801808:	83 c4 10             	add    $0x10,%esp
  80180b:	85 c0                	test   %eax,%eax
  80180d:	78 47                	js     801856 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80180f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801812:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801816:	75 24                	jne    80183c <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801818:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80181d:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801823:	83 ec 04             	sub    $0x4,%esp
  801826:	53                   	push   %ebx
  801827:	50                   	push   %eax
  801828:	68 58 2a 80 00       	push   $0x802a58
  80182d:	e8 5d ea ff ff       	call   80028f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801832:	83 c4 10             	add    $0x10,%esp
  801835:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80183a:	eb 23                	jmp    80185f <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  80183c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80183f:	8b 52 18             	mov    0x18(%edx),%edx
  801842:	85 d2                	test   %edx,%edx
  801844:	74 14                	je     80185a <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801846:	83 ec 08             	sub    $0x8,%esp
  801849:	ff 75 0c             	pushl  0xc(%ebp)
  80184c:	50                   	push   %eax
  80184d:	ff d2                	call   *%edx
  80184f:	89 c2                	mov    %eax,%edx
  801851:	83 c4 10             	add    $0x10,%esp
  801854:	eb 09                	jmp    80185f <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801856:	89 c2                	mov    %eax,%edx
  801858:	eb 05                	jmp    80185f <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80185a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80185f:	89 d0                	mov    %edx,%eax
  801861:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801864:	c9                   	leave  
  801865:	c3                   	ret    

00801866 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801866:	55                   	push   %ebp
  801867:	89 e5                	mov    %esp,%ebp
  801869:	53                   	push   %ebx
  80186a:	83 ec 14             	sub    $0x14,%esp
  80186d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801870:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801873:	50                   	push   %eax
  801874:	ff 75 08             	pushl  0x8(%ebp)
  801877:	e8 60 fb ff ff       	call   8013dc <fd_lookup>
  80187c:	83 c4 08             	add    $0x8,%esp
  80187f:	89 c2                	mov    %eax,%edx
  801881:	85 c0                	test   %eax,%eax
  801883:	78 58                	js     8018dd <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801885:	83 ec 08             	sub    $0x8,%esp
  801888:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80188b:	50                   	push   %eax
  80188c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80188f:	ff 30                	pushl  (%eax)
  801891:	e8 9c fb ff ff       	call   801432 <dev_lookup>
  801896:	83 c4 10             	add    $0x10,%esp
  801899:	85 c0                	test   %eax,%eax
  80189b:	78 37                	js     8018d4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80189d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018a4:	74 32                	je     8018d8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018a6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018a9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018b0:	00 00 00 
	stat->st_isdir = 0;
  8018b3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018ba:	00 00 00 
	stat->st_dev = dev;
  8018bd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018c3:	83 ec 08             	sub    $0x8,%esp
  8018c6:	53                   	push   %ebx
  8018c7:	ff 75 f0             	pushl  -0x10(%ebp)
  8018ca:	ff 50 14             	call   *0x14(%eax)
  8018cd:	89 c2                	mov    %eax,%edx
  8018cf:	83 c4 10             	add    $0x10,%esp
  8018d2:	eb 09                	jmp    8018dd <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018d4:	89 c2                	mov    %eax,%edx
  8018d6:	eb 05                	jmp    8018dd <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018d8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018dd:	89 d0                	mov    %edx,%eax
  8018df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e2:	c9                   	leave  
  8018e3:	c3                   	ret    

008018e4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018e4:	55                   	push   %ebp
  8018e5:	89 e5                	mov    %esp,%ebp
  8018e7:	56                   	push   %esi
  8018e8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018e9:	83 ec 08             	sub    $0x8,%esp
  8018ec:	6a 00                	push   $0x0
  8018ee:	ff 75 08             	pushl  0x8(%ebp)
  8018f1:	e8 e3 01 00 00       	call   801ad9 <open>
  8018f6:	89 c3                	mov    %eax,%ebx
  8018f8:	83 c4 10             	add    $0x10,%esp
  8018fb:	85 c0                	test   %eax,%eax
  8018fd:	78 1b                	js     80191a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018ff:	83 ec 08             	sub    $0x8,%esp
  801902:	ff 75 0c             	pushl  0xc(%ebp)
  801905:	50                   	push   %eax
  801906:	e8 5b ff ff ff       	call   801866 <fstat>
  80190b:	89 c6                	mov    %eax,%esi
	close(fd);
  80190d:	89 1c 24             	mov    %ebx,(%esp)
  801910:	e8 f4 fb ff ff       	call   801509 <close>
	return r;
  801915:	83 c4 10             	add    $0x10,%esp
  801918:	89 f0                	mov    %esi,%eax
}
  80191a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80191d:	5b                   	pop    %ebx
  80191e:	5e                   	pop    %esi
  80191f:	5d                   	pop    %ebp
  801920:	c3                   	ret    

00801921 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801921:	55                   	push   %ebp
  801922:	89 e5                	mov    %esp,%ebp
  801924:	56                   	push   %esi
  801925:	53                   	push   %ebx
  801926:	89 c6                	mov    %eax,%esi
  801928:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80192a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801931:	75 12                	jne    801945 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801933:	83 ec 0c             	sub    $0xc,%esp
  801936:	6a 01                	push   $0x1
  801938:	e8 a4 09 00 00       	call   8022e1 <ipc_find_env>
  80193d:	a3 00 40 80 00       	mov    %eax,0x804000
  801942:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801945:	6a 07                	push   $0x7
  801947:	68 00 70 80 00       	push   $0x807000
  80194c:	56                   	push   %esi
  80194d:	ff 35 00 40 80 00    	pushl  0x804000
  801953:	e8 27 09 00 00       	call   80227f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801958:	83 c4 0c             	add    $0xc,%esp
  80195b:	6a 00                	push   $0x0
  80195d:	53                   	push   %ebx
  80195e:	6a 00                	push   $0x0
  801960:	e8 9f 08 00 00       	call   802204 <ipc_recv>
}
  801965:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801968:	5b                   	pop    %ebx
  801969:	5e                   	pop    %esi
  80196a:	5d                   	pop    %ebp
  80196b:	c3                   	ret    

0080196c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801972:	8b 45 08             	mov    0x8(%ebp),%eax
  801975:	8b 40 0c             	mov    0xc(%eax),%eax
  801978:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  80197d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801980:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801985:	ba 00 00 00 00       	mov    $0x0,%edx
  80198a:	b8 02 00 00 00       	mov    $0x2,%eax
  80198f:	e8 8d ff ff ff       	call   801921 <fsipc>
}
  801994:	c9                   	leave  
  801995:	c3                   	ret    

00801996 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801996:	55                   	push   %ebp
  801997:	89 e5                	mov    %esp,%ebp
  801999:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80199c:	8b 45 08             	mov    0x8(%ebp),%eax
  80199f:	8b 40 0c             	mov    0xc(%eax),%eax
  8019a2:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  8019a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ac:	b8 06 00 00 00       	mov    $0x6,%eax
  8019b1:	e8 6b ff ff ff       	call   801921 <fsipc>
}
  8019b6:	c9                   	leave  
  8019b7:	c3                   	ret    

008019b8 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019b8:	55                   	push   %ebp
  8019b9:	89 e5                	mov    %esp,%ebp
  8019bb:	53                   	push   %ebx
  8019bc:	83 ec 04             	sub    $0x4,%esp
  8019bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c8:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d2:	b8 05 00 00 00       	mov    $0x5,%eax
  8019d7:	e8 45 ff ff ff       	call   801921 <fsipc>
  8019dc:	85 c0                	test   %eax,%eax
  8019de:	78 2c                	js     801a0c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019e0:	83 ec 08             	sub    $0x8,%esp
  8019e3:	68 00 70 80 00       	push   $0x807000
  8019e8:	53                   	push   %ebx
  8019e9:	e8 26 ee ff ff       	call   800814 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019ee:	a1 80 70 80 00       	mov    0x807080,%eax
  8019f3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019f9:	a1 84 70 80 00       	mov    0x807084,%eax
  8019fe:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a04:	83 c4 10             	add    $0x10,%esp
  801a07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a0f:	c9                   	leave  
  801a10:	c3                   	ret    

00801a11 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a11:	55                   	push   %ebp
  801a12:	89 e5                	mov    %esp,%ebp
  801a14:	83 ec 0c             	sub    $0xc,%esp
  801a17:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a1a:	8b 55 08             	mov    0x8(%ebp),%edx
  801a1d:	8b 52 0c             	mov    0xc(%edx),%edx
  801a20:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801a26:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a2b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a30:	0f 47 c2             	cmova  %edx,%eax
  801a33:	a3 04 70 80 00       	mov    %eax,0x807004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801a38:	50                   	push   %eax
  801a39:	ff 75 0c             	pushl  0xc(%ebp)
  801a3c:	68 08 70 80 00       	push   $0x807008
  801a41:	e8 60 ef ff ff       	call   8009a6 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801a46:	ba 00 00 00 00       	mov    $0x0,%edx
  801a4b:	b8 04 00 00 00       	mov    $0x4,%eax
  801a50:	e8 cc fe ff ff       	call   801921 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801a55:	c9                   	leave  
  801a56:	c3                   	ret    

00801a57 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a57:	55                   	push   %ebp
  801a58:	89 e5                	mov    %esp,%ebp
  801a5a:	56                   	push   %esi
  801a5b:	53                   	push   %ebx
  801a5c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a62:	8b 40 0c             	mov    0xc(%eax),%eax
  801a65:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801a6a:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a70:	ba 00 00 00 00       	mov    $0x0,%edx
  801a75:	b8 03 00 00 00       	mov    $0x3,%eax
  801a7a:	e8 a2 fe ff ff       	call   801921 <fsipc>
  801a7f:	89 c3                	mov    %eax,%ebx
  801a81:	85 c0                	test   %eax,%eax
  801a83:	78 4b                	js     801ad0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a85:	39 c6                	cmp    %eax,%esi
  801a87:	73 16                	jae    801a9f <devfile_read+0x48>
  801a89:	68 c8 2a 80 00       	push   $0x802ac8
  801a8e:	68 cf 2a 80 00       	push   $0x802acf
  801a93:	6a 7c                	push   $0x7c
  801a95:	68 e4 2a 80 00       	push   $0x802ae4
  801a9a:	e8 17 e7 ff ff       	call   8001b6 <_panic>
	assert(r <= PGSIZE);
  801a9f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801aa4:	7e 16                	jle    801abc <devfile_read+0x65>
  801aa6:	68 ef 2a 80 00       	push   $0x802aef
  801aab:	68 cf 2a 80 00       	push   $0x802acf
  801ab0:	6a 7d                	push   $0x7d
  801ab2:	68 e4 2a 80 00       	push   $0x802ae4
  801ab7:	e8 fa e6 ff ff       	call   8001b6 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801abc:	83 ec 04             	sub    $0x4,%esp
  801abf:	50                   	push   %eax
  801ac0:	68 00 70 80 00       	push   $0x807000
  801ac5:	ff 75 0c             	pushl  0xc(%ebp)
  801ac8:	e8 d9 ee ff ff       	call   8009a6 <memmove>
	return r;
  801acd:	83 c4 10             	add    $0x10,%esp
}
  801ad0:	89 d8                	mov    %ebx,%eax
  801ad2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad5:	5b                   	pop    %ebx
  801ad6:	5e                   	pop    %esi
  801ad7:	5d                   	pop    %ebp
  801ad8:	c3                   	ret    

00801ad9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ad9:	55                   	push   %ebp
  801ada:	89 e5                	mov    %esp,%ebp
  801adc:	53                   	push   %ebx
  801add:	83 ec 20             	sub    $0x20,%esp
  801ae0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ae3:	53                   	push   %ebx
  801ae4:	e8 f2 ec ff ff       	call   8007db <strlen>
  801ae9:	83 c4 10             	add    $0x10,%esp
  801aec:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801af1:	7f 67                	jg     801b5a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801af3:	83 ec 0c             	sub    $0xc,%esp
  801af6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801af9:	50                   	push   %eax
  801afa:	e8 8e f8 ff ff       	call   80138d <fd_alloc>
  801aff:	83 c4 10             	add    $0x10,%esp
		return r;
  801b02:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b04:	85 c0                	test   %eax,%eax
  801b06:	78 57                	js     801b5f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b08:	83 ec 08             	sub    $0x8,%esp
  801b0b:	53                   	push   %ebx
  801b0c:	68 00 70 80 00       	push   $0x807000
  801b11:	e8 fe ec ff ff       	call   800814 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b16:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b19:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b1e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b21:	b8 01 00 00 00       	mov    $0x1,%eax
  801b26:	e8 f6 fd ff ff       	call   801921 <fsipc>
  801b2b:	89 c3                	mov    %eax,%ebx
  801b2d:	83 c4 10             	add    $0x10,%esp
  801b30:	85 c0                	test   %eax,%eax
  801b32:	79 14                	jns    801b48 <open+0x6f>
		fd_close(fd, 0);
  801b34:	83 ec 08             	sub    $0x8,%esp
  801b37:	6a 00                	push   $0x0
  801b39:	ff 75 f4             	pushl  -0xc(%ebp)
  801b3c:	e8 47 f9 ff ff       	call   801488 <fd_close>
		return r;
  801b41:	83 c4 10             	add    $0x10,%esp
  801b44:	89 da                	mov    %ebx,%edx
  801b46:	eb 17                	jmp    801b5f <open+0x86>
	}

	return fd2num(fd);
  801b48:	83 ec 0c             	sub    $0xc,%esp
  801b4b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b4e:	e8 13 f8 ff ff       	call   801366 <fd2num>
  801b53:	89 c2                	mov    %eax,%edx
  801b55:	83 c4 10             	add    $0x10,%esp
  801b58:	eb 05                	jmp    801b5f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b5a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b5f:	89 d0                	mov    %edx,%eax
  801b61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b64:	c9                   	leave  
  801b65:	c3                   	ret    

00801b66 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b66:	55                   	push   %ebp
  801b67:	89 e5                	mov    %esp,%ebp
  801b69:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b6c:	ba 00 00 00 00       	mov    $0x0,%edx
  801b71:	b8 08 00 00 00       	mov    $0x8,%eax
  801b76:	e8 a6 fd ff ff       	call   801921 <fsipc>
}
  801b7b:	c9                   	leave  
  801b7c:	c3                   	ret    

00801b7d <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801b7d:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801b81:	7e 37                	jle    801bba <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801b83:	55                   	push   %ebp
  801b84:	89 e5                	mov    %esp,%ebp
  801b86:	53                   	push   %ebx
  801b87:	83 ec 08             	sub    $0x8,%esp
  801b8a:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801b8c:	ff 70 04             	pushl  0x4(%eax)
  801b8f:	8d 40 10             	lea    0x10(%eax),%eax
  801b92:	50                   	push   %eax
  801b93:	ff 33                	pushl  (%ebx)
  801b95:	e8 88 fb ff ff       	call   801722 <write>
		if (result > 0)
  801b9a:	83 c4 10             	add    $0x10,%esp
  801b9d:	85 c0                	test   %eax,%eax
  801b9f:	7e 03                	jle    801ba4 <writebuf+0x27>
			b->result += result;
  801ba1:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801ba4:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ba7:	74 0d                	je     801bb6 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801ba9:	85 c0                	test   %eax,%eax
  801bab:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb0:	0f 4f c2             	cmovg  %edx,%eax
  801bb3:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801bb6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb9:	c9                   	leave  
  801bba:	f3 c3                	repz ret 

00801bbc <putch>:

static void
putch(int ch, void *thunk)
{
  801bbc:	55                   	push   %ebp
  801bbd:	89 e5                	mov    %esp,%ebp
  801bbf:	53                   	push   %ebx
  801bc0:	83 ec 04             	sub    $0x4,%esp
  801bc3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801bc6:	8b 53 04             	mov    0x4(%ebx),%edx
  801bc9:	8d 42 01             	lea    0x1(%edx),%eax
  801bcc:	89 43 04             	mov    %eax,0x4(%ebx)
  801bcf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bd2:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801bd6:	3d 00 01 00 00       	cmp    $0x100,%eax
  801bdb:	75 0e                	jne    801beb <putch+0x2f>
		writebuf(b);
  801bdd:	89 d8                	mov    %ebx,%eax
  801bdf:	e8 99 ff ff ff       	call   801b7d <writebuf>
		b->idx = 0;
  801be4:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801beb:	83 c4 04             	add    $0x4,%esp
  801bee:	5b                   	pop    %ebx
  801bef:	5d                   	pop    %ebp
  801bf0:	c3                   	ret    

00801bf1 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801bf1:	55                   	push   %ebp
  801bf2:	89 e5                	mov    %esp,%ebp
  801bf4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801bfa:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfd:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801c03:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801c0a:	00 00 00 
	b.result = 0;
  801c0d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801c14:	00 00 00 
	b.error = 1;
  801c17:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801c1e:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801c21:	ff 75 10             	pushl  0x10(%ebp)
  801c24:	ff 75 0c             	pushl  0xc(%ebp)
  801c27:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801c2d:	50                   	push   %eax
  801c2e:	68 bc 1b 80 00       	push   $0x801bbc
  801c33:	e8 8e e7 ff ff       	call   8003c6 <vprintfmt>
	if (b.idx > 0)
  801c38:	83 c4 10             	add    $0x10,%esp
  801c3b:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801c42:	7e 0b                	jle    801c4f <vfprintf+0x5e>
		writebuf(&b);
  801c44:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801c4a:	e8 2e ff ff ff       	call   801b7d <writebuf>

	return (b.result ? b.result : b.error);
  801c4f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801c55:	85 c0                	test   %eax,%eax
  801c57:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801c5e:	c9                   	leave  
  801c5f:	c3                   	ret    

00801c60 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801c60:	55                   	push   %ebp
  801c61:	89 e5                	mov    %esp,%ebp
  801c63:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801c66:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801c69:	50                   	push   %eax
  801c6a:	ff 75 0c             	pushl  0xc(%ebp)
  801c6d:	ff 75 08             	pushl  0x8(%ebp)
  801c70:	e8 7c ff ff ff       	call   801bf1 <vfprintf>
	va_end(ap);

	return cnt;
}
  801c75:	c9                   	leave  
  801c76:	c3                   	ret    

00801c77 <printf>:

int
printf(const char *fmt, ...)
{
  801c77:	55                   	push   %ebp
  801c78:	89 e5                	mov    %esp,%ebp
  801c7a:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801c7d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801c80:	50                   	push   %eax
  801c81:	ff 75 08             	pushl  0x8(%ebp)
  801c84:	6a 01                	push   $0x1
  801c86:	e8 66 ff ff ff       	call   801bf1 <vfprintf>
	va_end(ap);

	return cnt;
}
  801c8b:	c9                   	leave  
  801c8c:	c3                   	ret    

00801c8d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c8d:	55                   	push   %ebp
  801c8e:	89 e5                	mov    %esp,%ebp
  801c90:	56                   	push   %esi
  801c91:	53                   	push   %ebx
  801c92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c95:	83 ec 0c             	sub    $0xc,%esp
  801c98:	ff 75 08             	pushl  0x8(%ebp)
  801c9b:	e8 d6 f6 ff ff       	call   801376 <fd2data>
  801ca0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ca2:	83 c4 08             	add    $0x8,%esp
  801ca5:	68 fb 2a 80 00       	push   $0x802afb
  801caa:	53                   	push   %ebx
  801cab:	e8 64 eb ff ff       	call   800814 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801cb0:	8b 46 04             	mov    0x4(%esi),%eax
  801cb3:	2b 06                	sub    (%esi),%eax
  801cb5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801cbb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cc2:	00 00 00 
	stat->st_dev = &devpipe;
  801cc5:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801ccc:	30 80 00 
	return 0;
}
  801ccf:	b8 00 00 00 00       	mov    $0x0,%eax
  801cd4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cd7:	5b                   	pop    %ebx
  801cd8:	5e                   	pop    %esi
  801cd9:	5d                   	pop    %ebp
  801cda:	c3                   	ret    

00801cdb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cdb:	55                   	push   %ebp
  801cdc:	89 e5                	mov    %esp,%ebp
  801cde:	53                   	push   %ebx
  801cdf:	83 ec 0c             	sub    $0xc,%esp
  801ce2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ce5:	53                   	push   %ebx
  801ce6:	6a 00                	push   $0x0
  801ce8:	e8 af ef ff ff       	call   800c9c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ced:	89 1c 24             	mov    %ebx,(%esp)
  801cf0:	e8 81 f6 ff ff       	call   801376 <fd2data>
  801cf5:	83 c4 08             	add    $0x8,%esp
  801cf8:	50                   	push   %eax
  801cf9:	6a 00                	push   $0x0
  801cfb:	e8 9c ef ff ff       	call   800c9c <sys_page_unmap>
}
  801d00:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d03:	c9                   	leave  
  801d04:	c3                   	ret    

00801d05 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d05:	55                   	push   %ebp
  801d06:	89 e5                	mov    %esp,%ebp
  801d08:	57                   	push   %edi
  801d09:	56                   	push   %esi
  801d0a:	53                   	push   %ebx
  801d0b:	83 ec 1c             	sub    $0x1c,%esp
  801d0e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d11:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d13:	a1 20 60 80 00       	mov    0x806020,%eax
  801d18:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d1e:	83 ec 0c             	sub    $0xc,%esp
  801d21:	ff 75 e0             	pushl  -0x20(%ebp)
  801d24:	e8 fd 05 00 00       	call   802326 <pageref>
  801d29:	89 c3                	mov    %eax,%ebx
  801d2b:	89 3c 24             	mov    %edi,(%esp)
  801d2e:	e8 f3 05 00 00       	call   802326 <pageref>
  801d33:	83 c4 10             	add    $0x10,%esp
  801d36:	39 c3                	cmp    %eax,%ebx
  801d38:	0f 94 c1             	sete   %cl
  801d3b:	0f b6 c9             	movzbl %cl,%ecx
  801d3e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d41:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801d47:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  801d4d:	39 ce                	cmp    %ecx,%esi
  801d4f:	74 1e                	je     801d6f <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801d51:	39 c3                	cmp    %eax,%ebx
  801d53:	75 be                	jne    801d13 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d55:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  801d5b:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d5e:	50                   	push   %eax
  801d5f:	56                   	push   %esi
  801d60:	68 02 2b 80 00       	push   $0x802b02
  801d65:	e8 25 e5 ff ff       	call   80028f <cprintf>
  801d6a:	83 c4 10             	add    $0x10,%esp
  801d6d:	eb a4                	jmp    801d13 <_pipeisclosed+0xe>
	}
}
  801d6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d75:	5b                   	pop    %ebx
  801d76:	5e                   	pop    %esi
  801d77:	5f                   	pop    %edi
  801d78:	5d                   	pop    %ebp
  801d79:	c3                   	ret    

00801d7a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d7a:	55                   	push   %ebp
  801d7b:	89 e5                	mov    %esp,%ebp
  801d7d:	57                   	push   %edi
  801d7e:	56                   	push   %esi
  801d7f:	53                   	push   %ebx
  801d80:	83 ec 28             	sub    $0x28,%esp
  801d83:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d86:	56                   	push   %esi
  801d87:	e8 ea f5 ff ff       	call   801376 <fd2data>
  801d8c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d8e:	83 c4 10             	add    $0x10,%esp
  801d91:	bf 00 00 00 00       	mov    $0x0,%edi
  801d96:	eb 4b                	jmp    801de3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d98:	89 da                	mov    %ebx,%edx
  801d9a:	89 f0                	mov    %esi,%eax
  801d9c:	e8 64 ff ff ff       	call   801d05 <_pipeisclosed>
  801da1:	85 c0                	test   %eax,%eax
  801da3:	75 48                	jne    801ded <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801da5:	e8 4e ee ff ff       	call   800bf8 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801daa:	8b 43 04             	mov    0x4(%ebx),%eax
  801dad:	8b 0b                	mov    (%ebx),%ecx
  801daf:	8d 51 20             	lea    0x20(%ecx),%edx
  801db2:	39 d0                	cmp    %edx,%eax
  801db4:	73 e2                	jae    801d98 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801db6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801db9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801dbd:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801dc0:	89 c2                	mov    %eax,%edx
  801dc2:	c1 fa 1f             	sar    $0x1f,%edx
  801dc5:	89 d1                	mov    %edx,%ecx
  801dc7:	c1 e9 1b             	shr    $0x1b,%ecx
  801dca:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801dcd:	83 e2 1f             	and    $0x1f,%edx
  801dd0:	29 ca                	sub    %ecx,%edx
  801dd2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801dd6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801dda:	83 c0 01             	add    $0x1,%eax
  801ddd:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801de0:	83 c7 01             	add    $0x1,%edi
  801de3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801de6:	75 c2                	jne    801daa <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801de8:	8b 45 10             	mov    0x10(%ebp),%eax
  801deb:	eb 05                	jmp    801df2 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ded:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801df2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801df5:	5b                   	pop    %ebx
  801df6:	5e                   	pop    %esi
  801df7:	5f                   	pop    %edi
  801df8:	5d                   	pop    %ebp
  801df9:	c3                   	ret    

00801dfa <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dfa:	55                   	push   %ebp
  801dfb:	89 e5                	mov    %esp,%ebp
  801dfd:	57                   	push   %edi
  801dfe:	56                   	push   %esi
  801dff:	53                   	push   %ebx
  801e00:	83 ec 18             	sub    $0x18,%esp
  801e03:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e06:	57                   	push   %edi
  801e07:	e8 6a f5 ff ff       	call   801376 <fd2data>
  801e0c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e0e:	83 c4 10             	add    $0x10,%esp
  801e11:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e16:	eb 3d                	jmp    801e55 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e18:	85 db                	test   %ebx,%ebx
  801e1a:	74 04                	je     801e20 <devpipe_read+0x26>
				return i;
  801e1c:	89 d8                	mov    %ebx,%eax
  801e1e:	eb 44                	jmp    801e64 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e20:	89 f2                	mov    %esi,%edx
  801e22:	89 f8                	mov    %edi,%eax
  801e24:	e8 dc fe ff ff       	call   801d05 <_pipeisclosed>
  801e29:	85 c0                	test   %eax,%eax
  801e2b:	75 32                	jne    801e5f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e2d:	e8 c6 ed ff ff       	call   800bf8 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e32:	8b 06                	mov    (%esi),%eax
  801e34:	3b 46 04             	cmp    0x4(%esi),%eax
  801e37:	74 df                	je     801e18 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e39:	99                   	cltd   
  801e3a:	c1 ea 1b             	shr    $0x1b,%edx
  801e3d:	01 d0                	add    %edx,%eax
  801e3f:	83 e0 1f             	and    $0x1f,%eax
  801e42:	29 d0                	sub    %edx,%eax
  801e44:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e4c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e4f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e52:	83 c3 01             	add    $0x1,%ebx
  801e55:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e58:	75 d8                	jne    801e32 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e5a:	8b 45 10             	mov    0x10(%ebp),%eax
  801e5d:	eb 05                	jmp    801e64 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e5f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e67:	5b                   	pop    %ebx
  801e68:	5e                   	pop    %esi
  801e69:	5f                   	pop    %edi
  801e6a:	5d                   	pop    %ebp
  801e6b:	c3                   	ret    

00801e6c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e6c:	55                   	push   %ebp
  801e6d:	89 e5                	mov    %esp,%ebp
  801e6f:	56                   	push   %esi
  801e70:	53                   	push   %ebx
  801e71:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e77:	50                   	push   %eax
  801e78:	e8 10 f5 ff ff       	call   80138d <fd_alloc>
  801e7d:	83 c4 10             	add    $0x10,%esp
  801e80:	89 c2                	mov    %eax,%edx
  801e82:	85 c0                	test   %eax,%eax
  801e84:	0f 88 2c 01 00 00    	js     801fb6 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e8a:	83 ec 04             	sub    $0x4,%esp
  801e8d:	68 07 04 00 00       	push   $0x407
  801e92:	ff 75 f4             	pushl  -0xc(%ebp)
  801e95:	6a 00                	push   $0x0
  801e97:	e8 7b ed ff ff       	call   800c17 <sys_page_alloc>
  801e9c:	83 c4 10             	add    $0x10,%esp
  801e9f:	89 c2                	mov    %eax,%edx
  801ea1:	85 c0                	test   %eax,%eax
  801ea3:	0f 88 0d 01 00 00    	js     801fb6 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ea9:	83 ec 0c             	sub    $0xc,%esp
  801eac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801eaf:	50                   	push   %eax
  801eb0:	e8 d8 f4 ff ff       	call   80138d <fd_alloc>
  801eb5:	89 c3                	mov    %eax,%ebx
  801eb7:	83 c4 10             	add    $0x10,%esp
  801eba:	85 c0                	test   %eax,%eax
  801ebc:	0f 88 e2 00 00 00    	js     801fa4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ec2:	83 ec 04             	sub    $0x4,%esp
  801ec5:	68 07 04 00 00       	push   $0x407
  801eca:	ff 75 f0             	pushl  -0x10(%ebp)
  801ecd:	6a 00                	push   $0x0
  801ecf:	e8 43 ed ff ff       	call   800c17 <sys_page_alloc>
  801ed4:	89 c3                	mov    %eax,%ebx
  801ed6:	83 c4 10             	add    $0x10,%esp
  801ed9:	85 c0                	test   %eax,%eax
  801edb:	0f 88 c3 00 00 00    	js     801fa4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ee1:	83 ec 0c             	sub    $0xc,%esp
  801ee4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ee7:	e8 8a f4 ff ff       	call   801376 <fd2data>
  801eec:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eee:	83 c4 0c             	add    $0xc,%esp
  801ef1:	68 07 04 00 00       	push   $0x407
  801ef6:	50                   	push   %eax
  801ef7:	6a 00                	push   $0x0
  801ef9:	e8 19 ed ff ff       	call   800c17 <sys_page_alloc>
  801efe:	89 c3                	mov    %eax,%ebx
  801f00:	83 c4 10             	add    $0x10,%esp
  801f03:	85 c0                	test   %eax,%eax
  801f05:	0f 88 89 00 00 00    	js     801f94 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f0b:	83 ec 0c             	sub    $0xc,%esp
  801f0e:	ff 75 f0             	pushl  -0x10(%ebp)
  801f11:	e8 60 f4 ff ff       	call   801376 <fd2data>
  801f16:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f1d:	50                   	push   %eax
  801f1e:	6a 00                	push   $0x0
  801f20:	56                   	push   %esi
  801f21:	6a 00                	push   $0x0
  801f23:	e8 32 ed ff ff       	call   800c5a <sys_page_map>
  801f28:	89 c3                	mov    %eax,%ebx
  801f2a:	83 c4 20             	add    $0x20,%esp
  801f2d:	85 c0                	test   %eax,%eax
  801f2f:	78 55                	js     801f86 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f31:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f46:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f4f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f51:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f54:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f5b:	83 ec 0c             	sub    $0xc,%esp
  801f5e:	ff 75 f4             	pushl  -0xc(%ebp)
  801f61:	e8 00 f4 ff ff       	call   801366 <fd2num>
  801f66:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f69:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f6b:	83 c4 04             	add    $0x4,%esp
  801f6e:	ff 75 f0             	pushl  -0x10(%ebp)
  801f71:	e8 f0 f3 ff ff       	call   801366 <fd2num>
  801f76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f79:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801f7c:	83 c4 10             	add    $0x10,%esp
  801f7f:	ba 00 00 00 00       	mov    $0x0,%edx
  801f84:	eb 30                	jmp    801fb6 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f86:	83 ec 08             	sub    $0x8,%esp
  801f89:	56                   	push   %esi
  801f8a:	6a 00                	push   $0x0
  801f8c:	e8 0b ed ff ff       	call   800c9c <sys_page_unmap>
  801f91:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f94:	83 ec 08             	sub    $0x8,%esp
  801f97:	ff 75 f0             	pushl  -0x10(%ebp)
  801f9a:	6a 00                	push   $0x0
  801f9c:	e8 fb ec ff ff       	call   800c9c <sys_page_unmap>
  801fa1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801fa4:	83 ec 08             	sub    $0x8,%esp
  801fa7:	ff 75 f4             	pushl  -0xc(%ebp)
  801faa:	6a 00                	push   $0x0
  801fac:	e8 eb ec ff ff       	call   800c9c <sys_page_unmap>
  801fb1:	83 c4 10             	add    $0x10,%esp
  801fb4:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801fb6:	89 d0                	mov    %edx,%eax
  801fb8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fbb:	5b                   	pop    %ebx
  801fbc:	5e                   	pop    %esi
  801fbd:	5d                   	pop    %ebp
  801fbe:	c3                   	ret    

00801fbf <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801fbf:	55                   	push   %ebp
  801fc0:	89 e5                	mov    %esp,%ebp
  801fc2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fc5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fc8:	50                   	push   %eax
  801fc9:	ff 75 08             	pushl  0x8(%ebp)
  801fcc:	e8 0b f4 ff ff       	call   8013dc <fd_lookup>
  801fd1:	83 c4 10             	add    $0x10,%esp
  801fd4:	85 c0                	test   %eax,%eax
  801fd6:	78 18                	js     801ff0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fd8:	83 ec 0c             	sub    $0xc,%esp
  801fdb:	ff 75 f4             	pushl  -0xc(%ebp)
  801fde:	e8 93 f3 ff ff       	call   801376 <fd2data>
	return _pipeisclosed(fd, p);
  801fe3:	89 c2                	mov    %eax,%edx
  801fe5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe8:	e8 18 fd ff ff       	call   801d05 <_pipeisclosed>
  801fed:	83 c4 10             	add    $0x10,%esp
}
  801ff0:	c9                   	leave  
  801ff1:	c3                   	ret    

00801ff2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ff2:	55                   	push   %ebp
  801ff3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ff5:	b8 00 00 00 00       	mov    $0x0,%eax
  801ffa:	5d                   	pop    %ebp
  801ffb:	c3                   	ret    

00801ffc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ffc:	55                   	push   %ebp
  801ffd:	89 e5                	mov    %esp,%ebp
  801fff:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802002:	68 1a 2b 80 00       	push   $0x802b1a
  802007:	ff 75 0c             	pushl  0xc(%ebp)
  80200a:	e8 05 e8 ff ff       	call   800814 <strcpy>
	return 0;
}
  80200f:	b8 00 00 00 00       	mov    $0x0,%eax
  802014:	c9                   	leave  
  802015:	c3                   	ret    

00802016 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802016:	55                   	push   %ebp
  802017:	89 e5                	mov    %esp,%ebp
  802019:	57                   	push   %edi
  80201a:	56                   	push   %esi
  80201b:	53                   	push   %ebx
  80201c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802022:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802027:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80202d:	eb 2d                	jmp    80205c <devcons_write+0x46>
		m = n - tot;
  80202f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802032:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802034:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802037:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80203c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80203f:	83 ec 04             	sub    $0x4,%esp
  802042:	53                   	push   %ebx
  802043:	03 45 0c             	add    0xc(%ebp),%eax
  802046:	50                   	push   %eax
  802047:	57                   	push   %edi
  802048:	e8 59 e9 ff ff       	call   8009a6 <memmove>
		sys_cputs(buf, m);
  80204d:	83 c4 08             	add    $0x8,%esp
  802050:	53                   	push   %ebx
  802051:	57                   	push   %edi
  802052:	e8 04 eb ff ff       	call   800b5b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802057:	01 de                	add    %ebx,%esi
  802059:	83 c4 10             	add    $0x10,%esp
  80205c:	89 f0                	mov    %esi,%eax
  80205e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802061:	72 cc                	jb     80202f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802063:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802066:	5b                   	pop    %ebx
  802067:	5e                   	pop    %esi
  802068:	5f                   	pop    %edi
  802069:	5d                   	pop    %ebp
  80206a:	c3                   	ret    

0080206b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80206b:	55                   	push   %ebp
  80206c:	89 e5                	mov    %esp,%ebp
  80206e:	83 ec 08             	sub    $0x8,%esp
  802071:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802076:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80207a:	74 2a                	je     8020a6 <devcons_read+0x3b>
  80207c:	eb 05                	jmp    802083 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80207e:	e8 75 eb ff ff       	call   800bf8 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802083:	e8 f1 ea ff ff       	call   800b79 <sys_cgetc>
  802088:	85 c0                	test   %eax,%eax
  80208a:	74 f2                	je     80207e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80208c:	85 c0                	test   %eax,%eax
  80208e:	78 16                	js     8020a6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802090:	83 f8 04             	cmp    $0x4,%eax
  802093:	74 0c                	je     8020a1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802095:	8b 55 0c             	mov    0xc(%ebp),%edx
  802098:	88 02                	mov    %al,(%edx)
	return 1;
  80209a:	b8 01 00 00 00       	mov    $0x1,%eax
  80209f:	eb 05                	jmp    8020a6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020a1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020a6:	c9                   	leave  
  8020a7:	c3                   	ret    

008020a8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020a8:	55                   	push   %ebp
  8020a9:	89 e5                	mov    %esp,%ebp
  8020ab:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8020ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020b4:	6a 01                	push   $0x1
  8020b6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020b9:	50                   	push   %eax
  8020ba:	e8 9c ea ff ff       	call   800b5b <sys_cputs>
}
  8020bf:	83 c4 10             	add    $0x10,%esp
  8020c2:	c9                   	leave  
  8020c3:	c3                   	ret    

008020c4 <getchar>:

int
getchar(void)
{
  8020c4:	55                   	push   %ebp
  8020c5:	89 e5                	mov    %esp,%ebp
  8020c7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020ca:	6a 01                	push   $0x1
  8020cc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020cf:	50                   	push   %eax
  8020d0:	6a 00                	push   $0x0
  8020d2:	e8 6e f5 ff ff       	call   801645 <read>
	if (r < 0)
  8020d7:	83 c4 10             	add    $0x10,%esp
  8020da:	85 c0                	test   %eax,%eax
  8020dc:	78 0f                	js     8020ed <getchar+0x29>
		return r;
	if (r < 1)
  8020de:	85 c0                	test   %eax,%eax
  8020e0:	7e 06                	jle    8020e8 <getchar+0x24>
		return -E_EOF;
	return c;
  8020e2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020e6:	eb 05                	jmp    8020ed <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020e8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020ed:	c9                   	leave  
  8020ee:	c3                   	ret    

008020ef <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020ef:	55                   	push   %ebp
  8020f0:	89 e5                	mov    %esp,%ebp
  8020f2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020f8:	50                   	push   %eax
  8020f9:	ff 75 08             	pushl  0x8(%ebp)
  8020fc:	e8 db f2 ff ff       	call   8013dc <fd_lookup>
  802101:	83 c4 10             	add    $0x10,%esp
  802104:	85 c0                	test   %eax,%eax
  802106:	78 11                	js     802119 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802108:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80210b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802111:	39 10                	cmp    %edx,(%eax)
  802113:	0f 94 c0             	sete   %al
  802116:	0f b6 c0             	movzbl %al,%eax
}
  802119:	c9                   	leave  
  80211a:	c3                   	ret    

0080211b <opencons>:

int
opencons(void)
{
  80211b:	55                   	push   %ebp
  80211c:	89 e5                	mov    %esp,%ebp
  80211e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802121:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802124:	50                   	push   %eax
  802125:	e8 63 f2 ff ff       	call   80138d <fd_alloc>
  80212a:	83 c4 10             	add    $0x10,%esp
		return r;
  80212d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80212f:	85 c0                	test   %eax,%eax
  802131:	78 3e                	js     802171 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802133:	83 ec 04             	sub    $0x4,%esp
  802136:	68 07 04 00 00       	push   $0x407
  80213b:	ff 75 f4             	pushl  -0xc(%ebp)
  80213e:	6a 00                	push   $0x0
  802140:	e8 d2 ea ff ff       	call   800c17 <sys_page_alloc>
  802145:	83 c4 10             	add    $0x10,%esp
		return r;
  802148:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80214a:	85 c0                	test   %eax,%eax
  80214c:	78 23                	js     802171 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80214e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802154:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802157:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802159:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80215c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802163:	83 ec 0c             	sub    $0xc,%esp
  802166:	50                   	push   %eax
  802167:	e8 fa f1 ff ff       	call   801366 <fd2num>
  80216c:	89 c2                	mov    %eax,%edx
  80216e:	83 c4 10             	add    $0x10,%esp
}
  802171:	89 d0                	mov    %edx,%eax
  802173:	c9                   	leave  
  802174:	c3                   	ret    

00802175 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802175:	55                   	push   %ebp
  802176:	89 e5                	mov    %esp,%ebp
  802178:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80217b:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802182:	75 2a                	jne    8021ae <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802184:	83 ec 04             	sub    $0x4,%esp
  802187:	6a 07                	push   $0x7
  802189:	68 00 f0 bf ee       	push   $0xeebff000
  80218e:	6a 00                	push   $0x0
  802190:	e8 82 ea ff ff       	call   800c17 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802195:	83 c4 10             	add    $0x10,%esp
  802198:	85 c0                	test   %eax,%eax
  80219a:	79 12                	jns    8021ae <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80219c:	50                   	push   %eax
  80219d:	68 56 26 80 00       	push   $0x802656
  8021a2:	6a 23                	push   $0x23
  8021a4:	68 26 2b 80 00       	push   $0x802b26
  8021a9:	e8 08 e0 ff ff       	call   8001b6 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8021ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b1:	a3 00 80 80 00       	mov    %eax,0x808000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8021b6:	83 ec 08             	sub    $0x8,%esp
  8021b9:	68 e0 21 80 00       	push   $0x8021e0
  8021be:	6a 00                	push   $0x0
  8021c0:	e8 9d eb ff ff       	call   800d62 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8021c5:	83 c4 10             	add    $0x10,%esp
  8021c8:	85 c0                	test   %eax,%eax
  8021ca:	79 12                	jns    8021de <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8021cc:	50                   	push   %eax
  8021cd:	68 56 26 80 00       	push   $0x802656
  8021d2:	6a 2c                	push   $0x2c
  8021d4:	68 26 2b 80 00       	push   $0x802b26
  8021d9:	e8 d8 df ff ff       	call   8001b6 <_panic>
	}
}
  8021de:	c9                   	leave  
  8021df:	c3                   	ret    

008021e0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8021e0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8021e1:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  8021e6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8021e8:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8021eb:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8021ef:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8021f4:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8021f8:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8021fa:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8021fd:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8021fe:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802201:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802202:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802203:	c3                   	ret    

00802204 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802204:	55                   	push   %ebp
  802205:	89 e5                	mov    %esp,%ebp
  802207:	56                   	push   %esi
  802208:	53                   	push   %ebx
  802209:	8b 75 08             	mov    0x8(%ebp),%esi
  80220c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80220f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802212:	85 c0                	test   %eax,%eax
  802214:	75 12                	jne    802228 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802216:	83 ec 0c             	sub    $0xc,%esp
  802219:	68 00 00 c0 ee       	push   $0xeec00000
  80221e:	e8 a4 eb ff ff       	call   800dc7 <sys_ipc_recv>
  802223:	83 c4 10             	add    $0x10,%esp
  802226:	eb 0c                	jmp    802234 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802228:	83 ec 0c             	sub    $0xc,%esp
  80222b:	50                   	push   %eax
  80222c:	e8 96 eb ff ff       	call   800dc7 <sys_ipc_recv>
  802231:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802234:	85 f6                	test   %esi,%esi
  802236:	0f 95 c1             	setne  %cl
  802239:	85 db                	test   %ebx,%ebx
  80223b:	0f 95 c2             	setne  %dl
  80223e:	84 d1                	test   %dl,%cl
  802240:	74 09                	je     80224b <ipc_recv+0x47>
  802242:	89 c2                	mov    %eax,%edx
  802244:	c1 ea 1f             	shr    $0x1f,%edx
  802247:	84 d2                	test   %dl,%dl
  802249:	75 2d                	jne    802278 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80224b:	85 f6                	test   %esi,%esi
  80224d:	74 0d                	je     80225c <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80224f:	a1 20 60 80 00       	mov    0x806020,%eax
  802254:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  80225a:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80225c:	85 db                	test   %ebx,%ebx
  80225e:	74 0d                	je     80226d <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802260:	a1 20 60 80 00       	mov    0x806020,%eax
  802265:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  80226b:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80226d:	a1 20 60 80 00       	mov    0x806020,%eax
  802272:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  802278:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80227b:	5b                   	pop    %ebx
  80227c:	5e                   	pop    %esi
  80227d:	5d                   	pop    %ebp
  80227e:	c3                   	ret    

0080227f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80227f:	55                   	push   %ebp
  802280:	89 e5                	mov    %esp,%ebp
  802282:	57                   	push   %edi
  802283:	56                   	push   %esi
  802284:	53                   	push   %ebx
  802285:	83 ec 0c             	sub    $0xc,%esp
  802288:	8b 7d 08             	mov    0x8(%ebp),%edi
  80228b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80228e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802291:	85 db                	test   %ebx,%ebx
  802293:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802298:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80229b:	ff 75 14             	pushl  0x14(%ebp)
  80229e:	53                   	push   %ebx
  80229f:	56                   	push   %esi
  8022a0:	57                   	push   %edi
  8022a1:	e8 fe ea ff ff       	call   800da4 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8022a6:	89 c2                	mov    %eax,%edx
  8022a8:	c1 ea 1f             	shr    $0x1f,%edx
  8022ab:	83 c4 10             	add    $0x10,%esp
  8022ae:	84 d2                	test   %dl,%dl
  8022b0:	74 17                	je     8022c9 <ipc_send+0x4a>
  8022b2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022b5:	74 12                	je     8022c9 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8022b7:	50                   	push   %eax
  8022b8:	68 34 2b 80 00       	push   $0x802b34
  8022bd:	6a 47                	push   $0x47
  8022bf:	68 42 2b 80 00       	push   $0x802b42
  8022c4:	e8 ed de ff ff       	call   8001b6 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8022c9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022cc:	75 07                	jne    8022d5 <ipc_send+0x56>
			sys_yield();
  8022ce:	e8 25 e9 ff ff       	call   800bf8 <sys_yield>
  8022d3:	eb c6                	jmp    80229b <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8022d5:	85 c0                	test   %eax,%eax
  8022d7:	75 c2                	jne    80229b <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8022d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022dc:	5b                   	pop    %ebx
  8022dd:	5e                   	pop    %esi
  8022de:	5f                   	pop    %edi
  8022df:	5d                   	pop    %ebp
  8022e0:	c3                   	ret    

008022e1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022e1:	55                   	push   %ebp
  8022e2:	89 e5                	mov    %esp,%ebp
  8022e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8022e7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022ec:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  8022f2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022f8:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  8022fe:	39 ca                	cmp    %ecx,%edx
  802300:	75 13                	jne    802315 <ipc_find_env+0x34>
			return envs[i].env_id;
  802302:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  802308:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80230d:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  802313:	eb 0f                	jmp    802324 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802315:	83 c0 01             	add    $0x1,%eax
  802318:	3d 00 04 00 00       	cmp    $0x400,%eax
  80231d:	75 cd                	jne    8022ec <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80231f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802324:	5d                   	pop    %ebp
  802325:	c3                   	ret    

00802326 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802326:	55                   	push   %ebp
  802327:	89 e5                	mov    %esp,%ebp
  802329:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80232c:	89 d0                	mov    %edx,%eax
  80232e:	c1 e8 16             	shr    $0x16,%eax
  802331:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802338:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80233d:	f6 c1 01             	test   $0x1,%cl
  802340:	74 1d                	je     80235f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802342:	c1 ea 0c             	shr    $0xc,%edx
  802345:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80234c:	f6 c2 01             	test   $0x1,%dl
  80234f:	74 0e                	je     80235f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802351:	c1 ea 0c             	shr    $0xc,%edx
  802354:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80235b:	ef 
  80235c:	0f b7 c0             	movzwl %ax,%eax
}
  80235f:	5d                   	pop    %ebp
  802360:	c3                   	ret    
  802361:	66 90                	xchg   %ax,%ax
  802363:	66 90                	xchg   %ax,%ax
  802365:	66 90                	xchg   %ax,%ax
  802367:	66 90                	xchg   %ax,%ax
  802369:	66 90                	xchg   %ax,%ax
  80236b:	66 90                	xchg   %ax,%ax
  80236d:	66 90                	xchg   %ax,%ax
  80236f:	90                   	nop

00802370 <__udivdi3>:
  802370:	55                   	push   %ebp
  802371:	57                   	push   %edi
  802372:	56                   	push   %esi
  802373:	53                   	push   %ebx
  802374:	83 ec 1c             	sub    $0x1c,%esp
  802377:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80237b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80237f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802383:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802387:	85 f6                	test   %esi,%esi
  802389:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80238d:	89 ca                	mov    %ecx,%edx
  80238f:	89 f8                	mov    %edi,%eax
  802391:	75 3d                	jne    8023d0 <__udivdi3+0x60>
  802393:	39 cf                	cmp    %ecx,%edi
  802395:	0f 87 c5 00 00 00    	ja     802460 <__udivdi3+0xf0>
  80239b:	85 ff                	test   %edi,%edi
  80239d:	89 fd                	mov    %edi,%ebp
  80239f:	75 0b                	jne    8023ac <__udivdi3+0x3c>
  8023a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8023a6:	31 d2                	xor    %edx,%edx
  8023a8:	f7 f7                	div    %edi
  8023aa:	89 c5                	mov    %eax,%ebp
  8023ac:	89 c8                	mov    %ecx,%eax
  8023ae:	31 d2                	xor    %edx,%edx
  8023b0:	f7 f5                	div    %ebp
  8023b2:	89 c1                	mov    %eax,%ecx
  8023b4:	89 d8                	mov    %ebx,%eax
  8023b6:	89 cf                	mov    %ecx,%edi
  8023b8:	f7 f5                	div    %ebp
  8023ba:	89 c3                	mov    %eax,%ebx
  8023bc:	89 d8                	mov    %ebx,%eax
  8023be:	89 fa                	mov    %edi,%edx
  8023c0:	83 c4 1c             	add    $0x1c,%esp
  8023c3:	5b                   	pop    %ebx
  8023c4:	5e                   	pop    %esi
  8023c5:	5f                   	pop    %edi
  8023c6:	5d                   	pop    %ebp
  8023c7:	c3                   	ret    
  8023c8:	90                   	nop
  8023c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023d0:	39 ce                	cmp    %ecx,%esi
  8023d2:	77 74                	ja     802448 <__udivdi3+0xd8>
  8023d4:	0f bd fe             	bsr    %esi,%edi
  8023d7:	83 f7 1f             	xor    $0x1f,%edi
  8023da:	0f 84 98 00 00 00    	je     802478 <__udivdi3+0x108>
  8023e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8023e5:	89 f9                	mov    %edi,%ecx
  8023e7:	89 c5                	mov    %eax,%ebp
  8023e9:	29 fb                	sub    %edi,%ebx
  8023eb:	d3 e6                	shl    %cl,%esi
  8023ed:	89 d9                	mov    %ebx,%ecx
  8023ef:	d3 ed                	shr    %cl,%ebp
  8023f1:	89 f9                	mov    %edi,%ecx
  8023f3:	d3 e0                	shl    %cl,%eax
  8023f5:	09 ee                	or     %ebp,%esi
  8023f7:	89 d9                	mov    %ebx,%ecx
  8023f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023fd:	89 d5                	mov    %edx,%ebp
  8023ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802403:	d3 ed                	shr    %cl,%ebp
  802405:	89 f9                	mov    %edi,%ecx
  802407:	d3 e2                	shl    %cl,%edx
  802409:	89 d9                	mov    %ebx,%ecx
  80240b:	d3 e8                	shr    %cl,%eax
  80240d:	09 c2                	or     %eax,%edx
  80240f:	89 d0                	mov    %edx,%eax
  802411:	89 ea                	mov    %ebp,%edx
  802413:	f7 f6                	div    %esi
  802415:	89 d5                	mov    %edx,%ebp
  802417:	89 c3                	mov    %eax,%ebx
  802419:	f7 64 24 0c          	mull   0xc(%esp)
  80241d:	39 d5                	cmp    %edx,%ebp
  80241f:	72 10                	jb     802431 <__udivdi3+0xc1>
  802421:	8b 74 24 08          	mov    0x8(%esp),%esi
  802425:	89 f9                	mov    %edi,%ecx
  802427:	d3 e6                	shl    %cl,%esi
  802429:	39 c6                	cmp    %eax,%esi
  80242b:	73 07                	jae    802434 <__udivdi3+0xc4>
  80242d:	39 d5                	cmp    %edx,%ebp
  80242f:	75 03                	jne    802434 <__udivdi3+0xc4>
  802431:	83 eb 01             	sub    $0x1,%ebx
  802434:	31 ff                	xor    %edi,%edi
  802436:	89 d8                	mov    %ebx,%eax
  802438:	89 fa                	mov    %edi,%edx
  80243a:	83 c4 1c             	add    $0x1c,%esp
  80243d:	5b                   	pop    %ebx
  80243e:	5e                   	pop    %esi
  80243f:	5f                   	pop    %edi
  802440:	5d                   	pop    %ebp
  802441:	c3                   	ret    
  802442:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802448:	31 ff                	xor    %edi,%edi
  80244a:	31 db                	xor    %ebx,%ebx
  80244c:	89 d8                	mov    %ebx,%eax
  80244e:	89 fa                	mov    %edi,%edx
  802450:	83 c4 1c             	add    $0x1c,%esp
  802453:	5b                   	pop    %ebx
  802454:	5e                   	pop    %esi
  802455:	5f                   	pop    %edi
  802456:	5d                   	pop    %ebp
  802457:	c3                   	ret    
  802458:	90                   	nop
  802459:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802460:	89 d8                	mov    %ebx,%eax
  802462:	f7 f7                	div    %edi
  802464:	31 ff                	xor    %edi,%edi
  802466:	89 c3                	mov    %eax,%ebx
  802468:	89 d8                	mov    %ebx,%eax
  80246a:	89 fa                	mov    %edi,%edx
  80246c:	83 c4 1c             	add    $0x1c,%esp
  80246f:	5b                   	pop    %ebx
  802470:	5e                   	pop    %esi
  802471:	5f                   	pop    %edi
  802472:	5d                   	pop    %ebp
  802473:	c3                   	ret    
  802474:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802478:	39 ce                	cmp    %ecx,%esi
  80247a:	72 0c                	jb     802488 <__udivdi3+0x118>
  80247c:	31 db                	xor    %ebx,%ebx
  80247e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802482:	0f 87 34 ff ff ff    	ja     8023bc <__udivdi3+0x4c>
  802488:	bb 01 00 00 00       	mov    $0x1,%ebx
  80248d:	e9 2a ff ff ff       	jmp    8023bc <__udivdi3+0x4c>
  802492:	66 90                	xchg   %ax,%ax
  802494:	66 90                	xchg   %ax,%ax
  802496:	66 90                	xchg   %ax,%ax
  802498:	66 90                	xchg   %ax,%ax
  80249a:	66 90                	xchg   %ax,%ax
  80249c:	66 90                	xchg   %ax,%ax
  80249e:	66 90                	xchg   %ax,%ax

008024a0 <__umoddi3>:
  8024a0:	55                   	push   %ebp
  8024a1:	57                   	push   %edi
  8024a2:	56                   	push   %esi
  8024a3:	53                   	push   %ebx
  8024a4:	83 ec 1c             	sub    $0x1c,%esp
  8024a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8024ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8024af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024b7:	85 d2                	test   %edx,%edx
  8024b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8024bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024c1:	89 f3                	mov    %esi,%ebx
  8024c3:	89 3c 24             	mov    %edi,(%esp)
  8024c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024ca:	75 1c                	jne    8024e8 <__umoddi3+0x48>
  8024cc:	39 f7                	cmp    %esi,%edi
  8024ce:	76 50                	jbe    802520 <__umoddi3+0x80>
  8024d0:	89 c8                	mov    %ecx,%eax
  8024d2:	89 f2                	mov    %esi,%edx
  8024d4:	f7 f7                	div    %edi
  8024d6:	89 d0                	mov    %edx,%eax
  8024d8:	31 d2                	xor    %edx,%edx
  8024da:	83 c4 1c             	add    $0x1c,%esp
  8024dd:	5b                   	pop    %ebx
  8024de:	5e                   	pop    %esi
  8024df:	5f                   	pop    %edi
  8024e0:	5d                   	pop    %ebp
  8024e1:	c3                   	ret    
  8024e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024e8:	39 f2                	cmp    %esi,%edx
  8024ea:	89 d0                	mov    %edx,%eax
  8024ec:	77 52                	ja     802540 <__umoddi3+0xa0>
  8024ee:	0f bd ea             	bsr    %edx,%ebp
  8024f1:	83 f5 1f             	xor    $0x1f,%ebp
  8024f4:	75 5a                	jne    802550 <__umoddi3+0xb0>
  8024f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8024fa:	0f 82 e0 00 00 00    	jb     8025e0 <__umoddi3+0x140>
  802500:	39 0c 24             	cmp    %ecx,(%esp)
  802503:	0f 86 d7 00 00 00    	jbe    8025e0 <__umoddi3+0x140>
  802509:	8b 44 24 08          	mov    0x8(%esp),%eax
  80250d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802511:	83 c4 1c             	add    $0x1c,%esp
  802514:	5b                   	pop    %ebx
  802515:	5e                   	pop    %esi
  802516:	5f                   	pop    %edi
  802517:	5d                   	pop    %ebp
  802518:	c3                   	ret    
  802519:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802520:	85 ff                	test   %edi,%edi
  802522:	89 fd                	mov    %edi,%ebp
  802524:	75 0b                	jne    802531 <__umoddi3+0x91>
  802526:	b8 01 00 00 00       	mov    $0x1,%eax
  80252b:	31 d2                	xor    %edx,%edx
  80252d:	f7 f7                	div    %edi
  80252f:	89 c5                	mov    %eax,%ebp
  802531:	89 f0                	mov    %esi,%eax
  802533:	31 d2                	xor    %edx,%edx
  802535:	f7 f5                	div    %ebp
  802537:	89 c8                	mov    %ecx,%eax
  802539:	f7 f5                	div    %ebp
  80253b:	89 d0                	mov    %edx,%eax
  80253d:	eb 99                	jmp    8024d8 <__umoddi3+0x38>
  80253f:	90                   	nop
  802540:	89 c8                	mov    %ecx,%eax
  802542:	89 f2                	mov    %esi,%edx
  802544:	83 c4 1c             	add    $0x1c,%esp
  802547:	5b                   	pop    %ebx
  802548:	5e                   	pop    %esi
  802549:	5f                   	pop    %edi
  80254a:	5d                   	pop    %ebp
  80254b:	c3                   	ret    
  80254c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802550:	8b 34 24             	mov    (%esp),%esi
  802553:	bf 20 00 00 00       	mov    $0x20,%edi
  802558:	89 e9                	mov    %ebp,%ecx
  80255a:	29 ef                	sub    %ebp,%edi
  80255c:	d3 e0                	shl    %cl,%eax
  80255e:	89 f9                	mov    %edi,%ecx
  802560:	89 f2                	mov    %esi,%edx
  802562:	d3 ea                	shr    %cl,%edx
  802564:	89 e9                	mov    %ebp,%ecx
  802566:	09 c2                	or     %eax,%edx
  802568:	89 d8                	mov    %ebx,%eax
  80256a:	89 14 24             	mov    %edx,(%esp)
  80256d:	89 f2                	mov    %esi,%edx
  80256f:	d3 e2                	shl    %cl,%edx
  802571:	89 f9                	mov    %edi,%ecx
  802573:	89 54 24 04          	mov    %edx,0x4(%esp)
  802577:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80257b:	d3 e8                	shr    %cl,%eax
  80257d:	89 e9                	mov    %ebp,%ecx
  80257f:	89 c6                	mov    %eax,%esi
  802581:	d3 e3                	shl    %cl,%ebx
  802583:	89 f9                	mov    %edi,%ecx
  802585:	89 d0                	mov    %edx,%eax
  802587:	d3 e8                	shr    %cl,%eax
  802589:	89 e9                	mov    %ebp,%ecx
  80258b:	09 d8                	or     %ebx,%eax
  80258d:	89 d3                	mov    %edx,%ebx
  80258f:	89 f2                	mov    %esi,%edx
  802591:	f7 34 24             	divl   (%esp)
  802594:	89 d6                	mov    %edx,%esi
  802596:	d3 e3                	shl    %cl,%ebx
  802598:	f7 64 24 04          	mull   0x4(%esp)
  80259c:	39 d6                	cmp    %edx,%esi
  80259e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025a2:	89 d1                	mov    %edx,%ecx
  8025a4:	89 c3                	mov    %eax,%ebx
  8025a6:	72 08                	jb     8025b0 <__umoddi3+0x110>
  8025a8:	75 11                	jne    8025bb <__umoddi3+0x11b>
  8025aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8025ae:	73 0b                	jae    8025bb <__umoddi3+0x11b>
  8025b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8025b4:	1b 14 24             	sbb    (%esp),%edx
  8025b7:	89 d1                	mov    %edx,%ecx
  8025b9:	89 c3                	mov    %eax,%ebx
  8025bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8025bf:	29 da                	sub    %ebx,%edx
  8025c1:	19 ce                	sbb    %ecx,%esi
  8025c3:	89 f9                	mov    %edi,%ecx
  8025c5:	89 f0                	mov    %esi,%eax
  8025c7:	d3 e0                	shl    %cl,%eax
  8025c9:	89 e9                	mov    %ebp,%ecx
  8025cb:	d3 ea                	shr    %cl,%edx
  8025cd:	89 e9                	mov    %ebp,%ecx
  8025cf:	d3 ee                	shr    %cl,%esi
  8025d1:	09 d0                	or     %edx,%eax
  8025d3:	89 f2                	mov    %esi,%edx
  8025d5:	83 c4 1c             	add    $0x1c,%esp
  8025d8:	5b                   	pop    %ebx
  8025d9:	5e                   	pop    %esi
  8025da:	5f                   	pop    %edi
  8025db:	5d                   	pop    %ebp
  8025dc:	c3                   	ret    
  8025dd:	8d 76 00             	lea    0x0(%esi),%esi
  8025e0:	29 f9                	sub    %edi,%ecx
  8025e2:	19 d6                	sbb    %edx,%esi
  8025e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025ec:	e9 18 ff ff ff       	jmp    802509 <__umoddi3+0x69>
