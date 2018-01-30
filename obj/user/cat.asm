
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
  800048:	e8 d1 16 00 00       	call   80171e <write>
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
  80007a:	e8 c2 15 00 00       	call   801641 <read>
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
  8000e8:	e8 e8 19 00 00       	call   801ad5 <open>
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
  800102:	e8 6c 1b 00 00       	call   801c73 <printf>
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
  80011b:	e8 e5 13 00 00       	call   801505 <close>
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
  8001a2:	e8 89 13 00 00       	call   801530 <close_all>
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
  8002f2:	e8 69 20 00 00       	call   802360 <__udivdi3>
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
  800335:	e8 56 21 00 00       	call   802490 <__umoddi3>
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
  800f4c:	e8 20 12 00 00       	call   802171 <set_pgfault_handler>
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
  801201:	53                   	push   %ebx
  801202:	83 ec 04             	sub    $0x4,%esp
  801205:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801208:	b8 01 00 00 00       	mov    $0x1,%eax
  80120d:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  801210:	85 c0                	test   %eax,%eax
  801212:	74 45                	je     801259 <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  801214:	e8 c0 f9 ff ff       	call   800bd9 <sys_getenvid>
  801219:	83 ec 08             	sub    $0x8,%esp
  80121c:	83 c3 04             	add    $0x4,%ebx
  80121f:	53                   	push   %ebx
  801220:	50                   	push   %eax
  801221:	e8 35 ff ff ff       	call   80115b <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  801226:	e8 ae f9 ff ff       	call   800bd9 <sys_getenvid>
  80122b:	83 c4 08             	add    $0x8,%esp
  80122e:	6a 04                	push   $0x4
  801230:	50                   	push   %eax
  801231:	e8 a8 fa ff ff       	call   800cde <sys_env_set_status>

		if (r < 0) {
  801236:	83 c4 10             	add    $0x10,%esp
  801239:	85 c0                	test   %eax,%eax
  80123b:	79 15                	jns    801252 <mutex_lock+0x54>
			panic("%e\n", r);
  80123d:	50                   	push   %eax
  80123e:	68 56 26 80 00       	push   $0x802656
  801243:	68 02 01 00 00       	push   $0x102
  801248:	68 ba 29 80 00       	push   $0x8029ba
  80124d:	e8 64 ef ff ff       	call   8001b6 <_panic>
		}
		sys_yield();
  801252:	e8 a1 f9 ff ff       	call   800bf8 <sys_yield>
  801257:	eb 08                	jmp    801261 <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  801259:	e8 7b f9 ff ff       	call   800bd9 <sys_getenvid>
  80125e:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801261:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801264:	c9                   	leave  
  801265:	c3                   	ret    

00801266 <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  801266:	55                   	push   %ebp
  801267:	89 e5                	mov    %esp,%ebp
  801269:	53                   	push   %ebx
  80126a:	83 ec 04             	sub    $0x4,%esp
  80126d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  801270:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  801274:	74 36                	je     8012ac <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  801276:	83 ec 0c             	sub    $0xc,%esp
  801279:	8d 43 04             	lea    0x4(%ebx),%eax
  80127c:	50                   	push   %eax
  80127d:	e8 4d ff ff ff       	call   8011cf <queue_pop>
  801282:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  801285:	83 c4 08             	add    $0x8,%esp
  801288:	6a 02                	push   $0x2
  80128a:	50                   	push   %eax
  80128b:	e8 4e fa ff ff       	call   800cde <sys_env_set_status>
		if (r < 0) {
  801290:	83 c4 10             	add    $0x10,%esp
  801293:	85 c0                	test   %eax,%eax
  801295:	79 1d                	jns    8012b4 <mutex_unlock+0x4e>
			panic("%e\n", r);
  801297:	50                   	push   %eax
  801298:	68 56 26 80 00       	push   $0x802656
  80129d:	68 16 01 00 00       	push   $0x116
  8012a2:	68 ba 29 80 00       	push   $0x8029ba
  8012a7:	e8 0a ef ff ff       	call   8001b6 <_panic>
  8012ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b1:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  8012b4:	e8 3f f9 ff ff       	call   800bf8 <sys_yield>
}
  8012b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012bc:	c9                   	leave  
  8012bd:	c3                   	ret    

008012be <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  8012be:	55                   	push   %ebp
  8012bf:	89 e5                	mov    %esp,%ebp
  8012c1:	53                   	push   %ebx
  8012c2:	83 ec 04             	sub    $0x4,%esp
  8012c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8012c8:	e8 0c f9 ff ff       	call   800bd9 <sys_getenvid>
  8012cd:	83 ec 04             	sub    $0x4,%esp
  8012d0:	6a 07                	push   $0x7
  8012d2:	53                   	push   %ebx
  8012d3:	50                   	push   %eax
  8012d4:	e8 3e f9 ff ff       	call   800c17 <sys_page_alloc>
  8012d9:	83 c4 10             	add    $0x10,%esp
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	79 15                	jns    8012f5 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  8012e0:	50                   	push   %eax
  8012e1:	68 1d 2a 80 00       	push   $0x802a1d
  8012e6:	68 23 01 00 00       	push   $0x123
  8012eb:	68 ba 29 80 00       	push   $0x8029ba
  8012f0:	e8 c1 ee ff ff       	call   8001b6 <_panic>
	}	
	mtx->locked = 0;
  8012f5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  8012fb:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  801302:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  801309:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  801310:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801313:	c9                   	leave  
  801314:	c3                   	ret    

00801315 <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  801315:	55                   	push   %ebp
  801316:	89 e5                	mov    %esp,%ebp
  801318:	56                   	push   %esi
  801319:	53                   	push   %ebx
  80131a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  80131d:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  801320:	eb 20                	jmp    801342 <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  801322:	83 ec 0c             	sub    $0xc,%esp
  801325:	56                   	push   %esi
  801326:	e8 a4 fe ff ff       	call   8011cf <queue_pop>
  80132b:	83 c4 08             	add    $0x8,%esp
  80132e:	6a 02                	push   $0x2
  801330:	50                   	push   %eax
  801331:	e8 a8 f9 ff ff       	call   800cde <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  801336:	8b 43 04             	mov    0x4(%ebx),%eax
  801339:	8b 40 04             	mov    0x4(%eax),%eax
  80133c:	89 43 04             	mov    %eax,0x4(%ebx)
  80133f:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  801342:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  801346:	75 da                	jne    801322 <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  801348:	83 ec 04             	sub    $0x4,%esp
  80134b:	68 00 10 00 00       	push   $0x1000
  801350:	6a 00                	push   $0x0
  801352:	53                   	push   %ebx
  801353:	e8 01 f6 ff ff       	call   800959 <memset>
	mtx = NULL;
}
  801358:	83 c4 10             	add    $0x10,%esp
  80135b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80135e:	5b                   	pop    %ebx
  80135f:	5e                   	pop    %esi
  801360:	5d                   	pop    %ebp
  801361:	c3                   	ret    

00801362 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801362:	55                   	push   %ebp
  801363:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801365:	8b 45 08             	mov    0x8(%ebp),%eax
  801368:	05 00 00 00 30       	add    $0x30000000,%eax
  80136d:	c1 e8 0c             	shr    $0xc,%eax
}
  801370:	5d                   	pop    %ebp
  801371:	c3                   	ret    

00801372 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801372:	55                   	push   %ebp
  801373:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801375:	8b 45 08             	mov    0x8(%ebp),%eax
  801378:	05 00 00 00 30       	add    $0x30000000,%eax
  80137d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801382:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801387:	5d                   	pop    %ebp
  801388:	c3                   	ret    

00801389 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801389:	55                   	push   %ebp
  80138a:	89 e5                	mov    %esp,%ebp
  80138c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80138f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801394:	89 c2                	mov    %eax,%edx
  801396:	c1 ea 16             	shr    $0x16,%edx
  801399:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013a0:	f6 c2 01             	test   $0x1,%dl
  8013a3:	74 11                	je     8013b6 <fd_alloc+0x2d>
  8013a5:	89 c2                	mov    %eax,%edx
  8013a7:	c1 ea 0c             	shr    $0xc,%edx
  8013aa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013b1:	f6 c2 01             	test   $0x1,%dl
  8013b4:	75 09                	jne    8013bf <fd_alloc+0x36>
			*fd_store = fd;
  8013b6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8013bd:	eb 17                	jmp    8013d6 <fd_alloc+0x4d>
  8013bf:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013c4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013c9:	75 c9                	jne    801394 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013cb:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8013d1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013d6:	5d                   	pop    %ebp
  8013d7:	c3                   	ret    

008013d8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013d8:	55                   	push   %ebp
  8013d9:	89 e5                	mov    %esp,%ebp
  8013db:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013de:	83 f8 1f             	cmp    $0x1f,%eax
  8013e1:	77 36                	ja     801419 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013e3:	c1 e0 0c             	shl    $0xc,%eax
  8013e6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013eb:	89 c2                	mov    %eax,%edx
  8013ed:	c1 ea 16             	shr    $0x16,%edx
  8013f0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013f7:	f6 c2 01             	test   $0x1,%dl
  8013fa:	74 24                	je     801420 <fd_lookup+0x48>
  8013fc:	89 c2                	mov    %eax,%edx
  8013fe:	c1 ea 0c             	shr    $0xc,%edx
  801401:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801408:	f6 c2 01             	test   $0x1,%dl
  80140b:	74 1a                	je     801427 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80140d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801410:	89 02                	mov    %eax,(%edx)
	return 0;
  801412:	b8 00 00 00 00       	mov    $0x0,%eax
  801417:	eb 13                	jmp    80142c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80141e:	eb 0c                	jmp    80142c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801420:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801425:	eb 05                	jmp    80142c <fd_lookup+0x54>
  801427:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80142c:	5d                   	pop    %ebp
  80142d:	c3                   	ret    

0080142e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
  801431:	83 ec 08             	sub    $0x8,%esp
  801434:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801437:	ba b8 2a 80 00       	mov    $0x802ab8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80143c:	eb 13                	jmp    801451 <dev_lookup+0x23>
  80143e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801441:	39 08                	cmp    %ecx,(%eax)
  801443:	75 0c                	jne    801451 <dev_lookup+0x23>
			*dev = devtab[i];
  801445:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801448:	89 01                	mov    %eax,(%ecx)
			return 0;
  80144a:	b8 00 00 00 00       	mov    $0x0,%eax
  80144f:	eb 31                	jmp    801482 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801451:	8b 02                	mov    (%edx),%eax
  801453:	85 c0                	test   %eax,%eax
  801455:	75 e7                	jne    80143e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801457:	a1 20 60 80 00       	mov    0x806020,%eax
  80145c:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801462:	83 ec 04             	sub    $0x4,%esp
  801465:	51                   	push   %ecx
  801466:	50                   	push   %eax
  801467:	68 38 2a 80 00       	push   $0x802a38
  80146c:	e8 1e ee ff ff       	call   80028f <cprintf>
	*dev = 0;
  801471:	8b 45 0c             	mov    0xc(%ebp),%eax
  801474:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80147a:	83 c4 10             	add    $0x10,%esp
  80147d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801482:	c9                   	leave  
  801483:	c3                   	ret    

00801484 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801484:	55                   	push   %ebp
  801485:	89 e5                	mov    %esp,%ebp
  801487:	56                   	push   %esi
  801488:	53                   	push   %ebx
  801489:	83 ec 10             	sub    $0x10,%esp
  80148c:	8b 75 08             	mov    0x8(%ebp),%esi
  80148f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801492:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801495:	50                   	push   %eax
  801496:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80149c:	c1 e8 0c             	shr    $0xc,%eax
  80149f:	50                   	push   %eax
  8014a0:	e8 33 ff ff ff       	call   8013d8 <fd_lookup>
  8014a5:	83 c4 08             	add    $0x8,%esp
  8014a8:	85 c0                	test   %eax,%eax
  8014aa:	78 05                	js     8014b1 <fd_close+0x2d>
	    || fd != fd2)
  8014ac:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014af:	74 0c                	je     8014bd <fd_close+0x39>
		return (must_exist ? r : 0);
  8014b1:	84 db                	test   %bl,%bl
  8014b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b8:	0f 44 c2             	cmove  %edx,%eax
  8014bb:	eb 41                	jmp    8014fe <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014bd:	83 ec 08             	sub    $0x8,%esp
  8014c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c3:	50                   	push   %eax
  8014c4:	ff 36                	pushl  (%esi)
  8014c6:	e8 63 ff ff ff       	call   80142e <dev_lookup>
  8014cb:	89 c3                	mov    %eax,%ebx
  8014cd:	83 c4 10             	add    $0x10,%esp
  8014d0:	85 c0                	test   %eax,%eax
  8014d2:	78 1a                	js     8014ee <fd_close+0x6a>
		if (dev->dev_close)
  8014d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8014da:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	74 0b                	je     8014ee <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014e3:	83 ec 0c             	sub    $0xc,%esp
  8014e6:	56                   	push   %esi
  8014e7:	ff d0                	call   *%eax
  8014e9:	89 c3                	mov    %eax,%ebx
  8014eb:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014ee:	83 ec 08             	sub    $0x8,%esp
  8014f1:	56                   	push   %esi
  8014f2:	6a 00                	push   $0x0
  8014f4:	e8 a3 f7 ff ff       	call   800c9c <sys_page_unmap>
	return r;
  8014f9:	83 c4 10             	add    $0x10,%esp
  8014fc:	89 d8                	mov    %ebx,%eax
}
  8014fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801501:	5b                   	pop    %ebx
  801502:	5e                   	pop    %esi
  801503:	5d                   	pop    %ebp
  801504:	c3                   	ret    

00801505 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
  801508:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80150b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150e:	50                   	push   %eax
  80150f:	ff 75 08             	pushl  0x8(%ebp)
  801512:	e8 c1 fe ff ff       	call   8013d8 <fd_lookup>
  801517:	83 c4 08             	add    $0x8,%esp
  80151a:	85 c0                	test   %eax,%eax
  80151c:	78 10                	js     80152e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80151e:	83 ec 08             	sub    $0x8,%esp
  801521:	6a 01                	push   $0x1
  801523:	ff 75 f4             	pushl  -0xc(%ebp)
  801526:	e8 59 ff ff ff       	call   801484 <fd_close>
  80152b:	83 c4 10             	add    $0x10,%esp
}
  80152e:	c9                   	leave  
  80152f:	c3                   	ret    

00801530 <close_all>:

void
close_all(void)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	53                   	push   %ebx
  801534:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801537:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80153c:	83 ec 0c             	sub    $0xc,%esp
  80153f:	53                   	push   %ebx
  801540:	e8 c0 ff ff ff       	call   801505 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801545:	83 c3 01             	add    $0x1,%ebx
  801548:	83 c4 10             	add    $0x10,%esp
  80154b:	83 fb 20             	cmp    $0x20,%ebx
  80154e:	75 ec                	jne    80153c <close_all+0xc>
		close(i);
}
  801550:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801553:	c9                   	leave  
  801554:	c3                   	ret    

00801555 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801555:	55                   	push   %ebp
  801556:	89 e5                	mov    %esp,%ebp
  801558:	57                   	push   %edi
  801559:	56                   	push   %esi
  80155a:	53                   	push   %ebx
  80155b:	83 ec 2c             	sub    $0x2c,%esp
  80155e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801561:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801564:	50                   	push   %eax
  801565:	ff 75 08             	pushl  0x8(%ebp)
  801568:	e8 6b fe ff ff       	call   8013d8 <fd_lookup>
  80156d:	83 c4 08             	add    $0x8,%esp
  801570:	85 c0                	test   %eax,%eax
  801572:	0f 88 c1 00 00 00    	js     801639 <dup+0xe4>
		return r;
	close(newfdnum);
  801578:	83 ec 0c             	sub    $0xc,%esp
  80157b:	56                   	push   %esi
  80157c:	e8 84 ff ff ff       	call   801505 <close>

	newfd = INDEX2FD(newfdnum);
  801581:	89 f3                	mov    %esi,%ebx
  801583:	c1 e3 0c             	shl    $0xc,%ebx
  801586:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80158c:	83 c4 04             	add    $0x4,%esp
  80158f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801592:	e8 db fd ff ff       	call   801372 <fd2data>
  801597:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801599:	89 1c 24             	mov    %ebx,(%esp)
  80159c:	e8 d1 fd ff ff       	call   801372 <fd2data>
  8015a1:	83 c4 10             	add    $0x10,%esp
  8015a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015a7:	89 f8                	mov    %edi,%eax
  8015a9:	c1 e8 16             	shr    $0x16,%eax
  8015ac:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015b3:	a8 01                	test   $0x1,%al
  8015b5:	74 37                	je     8015ee <dup+0x99>
  8015b7:	89 f8                	mov    %edi,%eax
  8015b9:	c1 e8 0c             	shr    $0xc,%eax
  8015bc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015c3:	f6 c2 01             	test   $0x1,%dl
  8015c6:	74 26                	je     8015ee <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015c8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015cf:	83 ec 0c             	sub    $0xc,%esp
  8015d2:	25 07 0e 00 00       	and    $0xe07,%eax
  8015d7:	50                   	push   %eax
  8015d8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015db:	6a 00                	push   $0x0
  8015dd:	57                   	push   %edi
  8015de:	6a 00                	push   $0x0
  8015e0:	e8 75 f6 ff ff       	call   800c5a <sys_page_map>
  8015e5:	89 c7                	mov    %eax,%edi
  8015e7:	83 c4 20             	add    $0x20,%esp
  8015ea:	85 c0                	test   %eax,%eax
  8015ec:	78 2e                	js     80161c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015ee:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015f1:	89 d0                	mov    %edx,%eax
  8015f3:	c1 e8 0c             	shr    $0xc,%eax
  8015f6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015fd:	83 ec 0c             	sub    $0xc,%esp
  801600:	25 07 0e 00 00       	and    $0xe07,%eax
  801605:	50                   	push   %eax
  801606:	53                   	push   %ebx
  801607:	6a 00                	push   $0x0
  801609:	52                   	push   %edx
  80160a:	6a 00                	push   $0x0
  80160c:	e8 49 f6 ff ff       	call   800c5a <sys_page_map>
  801611:	89 c7                	mov    %eax,%edi
  801613:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801616:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801618:	85 ff                	test   %edi,%edi
  80161a:	79 1d                	jns    801639 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80161c:	83 ec 08             	sub    $0x8,%esp
  80161f:	53                   	push   %ebx
  801620:	6a 00                	push   $0x0
  801622:	e8 75 f6 ff ff       	call   800c9c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801627:	83 c4 08             	add    $0x8,%esp
  80162a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80162d:	6a 00                	push   $0x0
  80162f:	e8 68 f6 ff ff       	call   800c9c <sys_page_unmap>
	return r;
  801634:	83 c4 10             	add    $0x10,%esp
  801637:	89 f8                	mov    %edi,%eax
}
  801639:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80163c:	5b                   	pop    %ebx
  80163d:	5e                   	pop    %esi
  80163e:	5f                   	pop    %edi
  80163f:	5d                   	pop    %ebp
  801640:	c3                   	ret    

00801641 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801641:	55                   	push   %ebp
  801642:	89 e5                	mov    %esp,%ebp
  801644:	53                   	push   %ebx
  801645:	83 ec 14             	sub    $0x14,%esp
  801648:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80164b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164e:	50                   	push   %eax
  80164f:	53                   	push   %ebx
  801650:	e8 83 fd ff ff       	call   8013d8 <fd_lookup>
  801655:	83 c4 08             	add    $0x8,%esp
  801658:	89 c2                	mov    %eax,%edx
  80165a:	85 c0                	test   %eax,%eax
  80165c:	78 70                	js     8016ce <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165e:	83 ec 08             	sub    $0x8,%esp
  801661:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801664:	50                   	push   %eax
  801665:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801668:	ff 30                	pushl  (%eax)
  80166a:	e8 bf fd ff ff       	call   80142e <dev_lookup>
  80166f:	83 c4 10             	add    $0x10,%esp
  801672:	85 c0                	test   %eax,%eax
  801674:	78 4f                	js     8016c5 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801676:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801679:	8b 42 08             	mov    0x8(%edx),%eax
  80167c:	83 e0 03             	and    $0x3,%eax
  80167f:	83 f8 01             	cmp    $0x1,%eax
  801682:	75 24                	jne    8016a8 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801684:	a1 20 60 80 00       	mov    0x806020,%eax
  801689:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80168f:	83 ec 04             	sub    $0x4,%esp
  801692:	53                   	push   %ebx
  801693:	50                   	push   %eax
  801694:	68 7c 2a 80 00       	push   $0x802a7c
  801699:	e8 f1 eb ff ff       	call   80028f <cprintf>
		return -E_INVAL;
  80169e:	83 c4 10             	add    $0x10,%esp
  8016a1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016a6:	eb 26                	jmp    8016ce <read+0x8d>
	}
	if (!dev->dev_read)
  8016a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ab:	8b 40 08             	mov    0x8(%eax),%eax
  8016ae:	85 c0                	test   %eax,%eax
  8016b0:	74 17                	je     8016c9 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8016b2:	83 ec 04             	sub    $0x4,%esp
  8016b5:	ff 75 10             	pushl  0x10(%ebp)
  8016b8:	ff 75 0c             	pushl  0xc(%ebp)
  8016bb:	52                   	push   %edx
  8016bc:	ff d0                	call   *%eax
  8016be:	89 c2                	mov    %eax,%edx
  8016c0:	83 c4 10             	add    $0x10,%esp
  8016c3:	eb 09                	jmp    8016ce <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c5:	89 c2                	mov    %eax,%edx
  8016c7:	eb 05                	jmp    8016ce <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016c9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8016ce:	89 d0                	mov    %edx,%eax
  8016d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d3:	c9                   	leave  
  8016d4:	c3                   	ret    

008016d5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	57                   	push   %edi
  8016d9:	56                   	push   %esi
  8016da:	53                   	push   %ebx
  8016db:	83 ec 0c             	sub    $0xc,%esp
  8016de:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016e1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016e9:	eb 21                	jmp    80170c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016eb:	83 ec 04             	sub    $0x4,%esp
  8016ee:	89 f0                	mov    %esi,%eax
  8016f0:	29 d8                	sub    %ebx,%eax
  8016f2:	50                   	push   %eax
  8016f3:	89 d8                	mov    %ebx,%eax
  8016f5:	03 45 0c             	add    0xc(%ebp),%eax
  8016f8:	50                   	push   %eax
  8016f9:	57                   	push   %edi
  8016fa:	e8 42 ff ff ff       	call   801641 <read>
		if (m < 0)
  8016ff:	83 c4 10             	add    $0x10,%esp
  801702:	85 c0                	test   %eax,%eax
  801704:	78 10                	js     801716 <readn+0x41>
			return m;
		if (m == 0)
  801706:	85 c0                	test   %eax,%eax
  801708:	74 0a                	je     801714 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80170a:	01 c3                	add    %eax,%ebx
  80170c:	39 f3                	cmp    %esi,%ebx
  80170e:	72 db                	jb     8016eb <readn+0x16>
  801710:	89 d8                	mov    %ebx,%eax
  801712:	eb 02                	jmp    801716 <readn+0x41>
  801714:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801716:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801719:	5b                   	pop    %ebx
  80171a:	5e                   	pop    %esi
  80171b:	5f                   	pop    %edi
  80171c:	5d                   	pop    %ebp
  80171d:	c3                   	ret    

0080171e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	53                   	push   %ebx
  801722:	83 ec 14             	sub    $0x14,%esp
  801725:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801728:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80172b:	50                   	push   %eax
  80172c:	53                   	push   %ebx
  80172d:	e8 a6 fc ff ff       	call   8013d8 <fd_lookup>
  801732:	83 c4 08             	add    $0x8,%esp
  801735:	89 c2                	mov    %eax,%edx
  801737:	85 c0                	test   %eax,%eax
  801739:	78 6b                	js     8017a6 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173b:	83 ec 08             	sub    $0x8,%esp
  80173e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801741:	50                   	push   %eax
  801742:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801745:	ff 30                	pushl  (%eax)
  801747:	e8 e2 fc ff ff       	call   80142e <dev_lookup>
  80174c:	83 c4 10             	add    $0x10,%esp
  80174f:	85 c0                	test   %eax,%eax
  801751:	78 4a                	js     80179d <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801753:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801756:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80175a:	75 24                	jne    801780 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80175c:	a1 20 60 80 00       	mov    0x806020,%eax
  801761:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801767:	83 ec 04             	sub    $0x4,%esp
  80176a:	53                   	push   %ebx
  80176b:	50                   	push   %eax
  80176c:	68 98 2a 80 00       	push   $0x802a98
  801771:	e8 19 eb ff ff       	call   80028f <cprintf>
		return -E_INVAL;
  801776:	83 c4 10             	add    $0x10,%esp
  801779:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80177e:	eb 26                	jmp    8017a6 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801780:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801783:	8b 52 0c             	mov    0xc(%edx),%edx
  801786:	85 d2                	test   %edx,%edx
  801788:	74 17                	je     8017a1 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80178a:	83 ec 04             	sub    $0x4,%esp
  80178d:	ff 75 10             	pushl  0x10(%ebp)
  801790:	ff 75 0c             	pushl  0xc(%ebp)
  801793:	50                   	push   %eax
  801794:	ff d2                	call   *%edx
  801796:	89 c2                	mov    %eax,%edx
  801798:	83 c4 10             	add    $0x10,%esp
  80179b:	eb 09                	jmp    8017a6 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179d:	89 c2                	mov    %eax,%edx
  80179f:	eb 05                	jmp    8017a6 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017a1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8017a6:	89 d0                	mov    %edx,%eax
  8017a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ab:	c9                   	leave  
  8017ac:	c3                   	ret    

008017ad <seek>:

int
seek(int fdnum, off_t offset)
{
  8017ad:	55                   	push   %ebp
  8017ae:	89 e5                	mov    %esp,%ebp
  8017b0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017b3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017b6:	50                   	push   %eax
  8017b7:	ff 75 08             	pushl  0x8(%ebp)
  8017ba:	e8 19 fc ff ff       	call   8013d8 <fd_lookup>
  8017bf:	83 c4 08             	add    $0x8,%esp
  8017c2:	85 c0                	test   %eax,%eax
  8017c4:	78 0e                	js     8017d4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017cc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d4:	c9                   	leave  
  8017d5:	c3                   	ret    

008017d6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	53                   	push   %ebx
  8017da:	83 ec 14             	sub    $0x14,%esp
  8017dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e3:	50                   	push   %eax
  8017e4:	53                   	push   %ebx
  8017e5:	e8 ee fb ff ff       	call   8013d8 <fd_lookup>
  8017ea:	83 c4 08             	add    $0x8,%esp
  8017ed:	89 c2                	mov    %eax,%edx
  8017ef:	85 c0                	test   %eax,%eax
  8017f1:	78 68                	js     80185b <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f3:	83 ec 08             	sub    $0x8,%esp
  8017f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f9:	50                   	push   %eax
  8017fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fd:	ff 30                	pushl  (%eax)
  8017ff:	e8 2a fc ff ff       	call   80142e <dev_lookup>
  801804:	83 c4 10             	add    $0x10,%esp
  801807:	85 c0                	test   %eax,%eax
  801809:	78 47                	js     801852 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80180b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80180e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801812:	75 24                	jne    801838 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801814:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801819:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80181f:	83 ec 04             	sub    $0x4,%esp
  801822:	53                   	push   %ebx
  801823:	50                   	push   %eax
  801824:	68 58 2a 80 00       	push   $0x802a58
  801829:	e8 61 ea ff ff       	call   80028f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80182e:	83 c4 10             	add    $0x10,%esp
  801831:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801836:	eb 23                	jmp    80185b <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801838:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80183b:	8b 52 18             	mov    0x18(%edx),%edx
  80183e:	85 d2                	test   %edx,%edx
  801840:	74 14                	je     801856 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801842:	83 ec 08             	sub    $0x8,%esp
  801845:	ff 75 0c             	pushl  0xc(%ebp)
  801848:	50                   	push   %eax
  801849:	ff d2                	call   *%edx
  80184b:	89 c2                	mov    %eax,%edx
  80184d:	83 c4 10             	add    $0x10,%esp
  801850:	eb 09                	jmp    80185b <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801852:	89 c2                	mov    %eax,%edx
  801854:	eb 05                	jmp    80185b <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801856:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80185b:	89 d0                	mov    %edx,%eax
  80185d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801860:	c9                   	leave  
  801861:	c3                   	ret    

00801862 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801862:	55                   	push   %ebp
  801863:	89 e5                	mov    %esp,%ebp
  801865:	53                   	push   %ebx
  801866:	83 ec 14             	sub    $0x14,%esp
  801869:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80186c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80186f:	50                   	push   %eax
  801870:	ff 75 08             	pushl  0x8(%ebp)
  801873:	e8 60 fb ff ff       	call   8013d8 <fd_lookup>
  801878:	83 c4 08             	add    $0x8,%esp
  80187b:	89 c2                	mov    %eax,%edx
  80187d:	85 c0                	test   %eax,%eax
  80187f:	78 58                	js     8018d9 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801881:	83 ec 08             	sub    $0x8,%esp
  801884:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801887:	50                   	push   %eax
  801888:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80188b:	ff 30                	pushl  (%eax)
  80188d:	e8 9c fb ff ff       	call   80142e <dev_lookup>
  801892:	83 c4 10             	add    $0x10,%esp
  801895:	85 c0                	test   %eax,%eax
  801897:	78 37                	js     8018d0 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801899:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80189c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018a0:	74 32                	je     8018d4 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018a2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018a5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018ac:	00 00 00 
	stat->st_isdir = 0;
  8018af:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018b6:	00 00 00 
	stat->st_dev = dev;
  8018b9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018bf:	83 ec 08             	sub    $0x8,%esp
  8018c2:	53                   	push   %ebx
  8018c3:	ff 75 f0             	pushl  -0x10(%ebp)
  8018c6:	ff 50 14             	call   *0x14(%eax)
  8018c9:	89 c2                	mov    %eax,%edx
  8018cb:	83 c4 10             	add    $0x10,%esp
  8018ce:	eb 09                	jmp    8018d9 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018d0:	89 c2                	mov    %eax,%edx
  8018d2:	eb 05                	jmp    8018d9 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018d4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018d9:	89 d0                	mov    %edx,%eax
  8018db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018de:	c9                   	leave  
  8018df:	c3                   	ret    

008018e0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	56                   	push   %esi
  8018e4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018e5:	83 ec 08             	sub    $0x8,%esp
  8018e8:	6a 00                	push   $0x0
  8018ea:	ff 75 08             	pushl  0x8(%ebp)
  8018ed:	e8 e3 01 00 00       	call   801ad5 <open>
  8018f2:	89 c3                	mov    %eax,%ebx
  8018f4:	83 c4 10             	add    $0x10,%esp
  8018f7:	85 c0                	test   %eax,%eax
  8018f9:	78 1b                	js     801916 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018fb:	83 ec 08             	sub    $0x8,%esp
  8018fe:	ff 75 0c             	pushl  0xc(%ebp)
  801901:	50                   	push   %eax
  801902:	e8 5b ff ff ff       	call   801862 <fstat>
  801907:	89 c6                	mov    %eax,%esi
	close(fd);
  801909:	89 1c 24             	mov    %ebx,(%esp)
  80190c:	e8 f4 fb ff ff       	call   801505 <close>
	return r;
  801911:	83 c4 10             	add    $0x10,%esp
  801914:	89 f0                	mov    %esi,%eax
}
  801916:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801919:	5b                   	pop    %ebx
  80191a:	5e                   	pop    %esi
  80191b:	5d                   	pop    %ebp
  80191c:	c3                   	ret    

0080191d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80191d:	55                   	push   %ebp
  80191e:	89 e5                	mov    %esp,%ebp
  801920:	56                   	push   %esi
  801921:	53                   	push   %ebx
  801922:	89 c6                	mov    %eax,%esi
  801924:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801926:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80192d:	75 12                	jne    801941 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80192f:	83 ec 0c             	sub    $0xc,%esp
  801932:	6a 01                	push   $0x1
  801934:	e8 a4 09 00 00       	call   8022dd <ipc_find_env>
  801939:	a3 00 40 80 00       	mov    %eax,0x804000
  80193e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801941:	6a 07                	push   $0x7
  801943:	68 00 70 80 00       	push   $0x807000
  801948:	56                   	push   %esi
  801949:	ff 35 00 40 80 00    	pushl  0x804000
  80194f:	e8 27 09 00 00       	call   80227b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801954:	83 c4 0c             	add    $0xc,%esp
  801957:	6a 00                	push   $0x0
  801959:	53                   	push   %ebx
  80195a:	6a 00                	push   $0x0
  80195c:	e8 9f 08 00 00       	call   802200 <ipc_recv>
}
  801961:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801964:	5b                   	pop    %ebx
  801965:	5e                   	pop    %esi
  801966:	5d                   	pop    %ebp
  801967:	c3                   	ret    

00801968 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801968:	55                   	push   %ebp
  801969:	89 e5                	mov    %esp,%ebp
  80196b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80196e:	8b 45 08             	mov    0x8(%ebp),%eax
  801971:	8b 40 0c             	mov    0xc(%eax),%eax
  801974:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  801979:	8b 45 0c             	mov    0xc(%ebp),%eax
  80197c:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801981:	ba 00 00 00 00       	mov    $0x0,%edx
  801986:	b8 02 00 00 00       	mov    $0x2,%eax
  80198b:	e8 8d ff ff ff       	call   80191d <fsipc>
}
  801990:	c9                   	leave  
  801991:	c3                   	ret    

00801992 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801992:	55                   	push   %ebp
  801993:	89 e5                	mov    %esp,%ebp
  801995:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801998:	8b 45 08             	mov    0x8(%ebp),%eax
  80199b:	8b 40 0c             	mov    0xc(%eax),%eax
  80199e:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  8019a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a8:	b8 06 00 00 00       	mov    $0x6,%eax
  8019ad:	e8 6b ff ff ff       	call   80191d <fsipc>
}
  8019b2:	c9                   	leave  
  8019b3:	c3                   	ret    

008019b4 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	53                   	push   %ebx
  8019b8:	83 ec 04             	sub    $0x4,%esp
  8019bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019be:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c1:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c4:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ce:	b8 05 00 00 00       	mov    $0x5,%eax
  8019d3:	e8 45 ff ff ff       	call   80191d <fsipc>
  8019d8:	85 c0                	test   %eax,%eax
  8019da:	78 2c                	js     801a08 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019dc:	83 ec 08             	sub    $0x8,%esp
  8019df:	68 00 70 80 00       	push   $0x807000
  8019e4:	53                   	push   %ebx
  8019e5:	e8 2a ee ff ff       	call   800814 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019ea:	a1 80 70 80 00       	mov    0x807080,%eax
  8019ef:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019f5:	a1 84 70 80 00       	mov    0x807084,%eax
  8019fa:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a00:	83 c4 10             	add    $0x10,%esp
  801a03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a08:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a0b:	c9                   	leave  
  801a0c:	c3                   	ret    

00801a0d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a0d:	55                   	push   %ebp
  801a0e:	89 e5                	mov    %esp,%ebp
  801a10:	83 ec 0c             	sub    $0xc,%esp
  801a13:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a16:	8b 55 08             	mov    0x8(%ebp),%edx
  801a19:	8b 52 0c             	mov    0xc(%edx),%edx
  801a1c:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801a22:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a27:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a2c:	0f 47 c2             	cmova  %edx,%eax
  801a2f:	a3 04 70 80 00       	mov    %eax,0x807004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801a34:	50                   	push   %eax
  801a35:	ff 75 0c             	pushl  0xc(%ebp)
  801a38:	68 08 70 80 00       	push   $0x807008
  801a3d:	e8 64 ef ff ff       	call   8009a6 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801a42:	ba 00 00 00 00       	mov    $0x0,%edx
  801a47:	b8 04 00 00 00       	mov    $0x4,%eax
  801a4c:	e8 cc fe ff ff       	call   80191d <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801a51:	c9                   	leave  
  801a52:	c3                   	ret    

00801a53 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a53:	55                   	push   %ebp
  801a54:	89 e5                	mov    %esp,%ebp
  801a56:	56                   	push   %esi
  801a57:	53                   	push   %ebx
  801a58:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5e:	8b 40 0c             	mov    0xc(%eax),%eax
  801a61:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801a66:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a6c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a71:	b8 03 00 00 00       	mov    $0x3,%eax
  801a76:	e8 a2 fe ff ff       	call   80191d <fsipc>
  801a7b:	89 c3                	mov    %eax,%ebx
  801a7d:	85 c0                	test   %eax,%eax
  801a7f:	78 4b                	js     801acc <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a81:	39 c6                	cmp    %eax,%esi
  801a83:	73 16                	jae    801a9b <devfile_read+0x48>
  801a85:	68 c8 2a 80 00       	push   $0x802ac8
  801a8a:	68 cf 2a 80 00       	push   $0x802acf
  801a8f:	6a 7c                	push   $0x7c
  801a91:	68 e4 2a 80 00       	push   $0x802ae4
  801a96:	e8 1b e7 ff ff       	call   8001b6 <_panic>
	assert(r <= PGSIZE);
  801a9b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801aa0:	7e 16                	jle    801ab8 <devfile_read+0x65>
  801aa2:	68 ef 2a 80 00       	push   $0x802aef
  801aa7:	68 cf 2a 80 00       	push   $0x802acf
  801aac:	6a 7d                	push   $0x7d
  801aae:	68 e4 2a 80 00       	push   $0x802ae4
  801ab3:	e8 fe e6 ff ff       	call   8001b6 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ab8:	83 ec 04             	sub    $0x4,%esp
  801abb:	50                   	push   %eax
  801abc:	68 00 70 80 00       	push   $0x807000
  801ac1:	ff 75 0c             	pushl  0xc(%ebp)
  801ac4:	e8 dd ee ff ff       	call   8009a6 <memmove>
	return r;
  801ac9:	83 c4 10             	add    $0x10,%esp
}
  801acc:	89 d8                	mov    %ebx,%eax
  801ace:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad1:	5b                   	pop    %ebx
  801ad2:	5e                   	pop    %esi
  801ad3:	5d                   	pop    %ebp
  801ad4:	c3                   	ret    

00801ad5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ad5:	55                   	push   %ebp
  801ad6:	89 e5                	mov    %esp,%ebp
  801ad8:	53                   	push   %ebx
  801ad9:	83 ec 20             	sub    $0x20,%esp
  801adc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801adf:	53                   	push   %ebx
  801ae0:	e8 f6 ec ff ff       	call   8007db <strlen>
  801ae5:	83 c4 10             	add    $0x10,%esp
  801ae8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801aed:	7f 67                	jg     801b56 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801aef:	83 ec 0c             	sub    $0xc,%esp
  801af2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801af5:	50                   	push   %eax
  801af6:	e8 8e f8 ff ff       	call   801389 <fd_alloc>
  801afb:	83 c4 10             	add    $0x10,%esp
		return r;
  801afe:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b00:	85 c0                	test   %eax,%eax
  801b02:	78 57                	js     801b5b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b04:	83 ec 08             	sub    $0x8,%esp
  801b07:	53                   	push   %ebx
  801b08:	68 00 70 80 00       	push   $0x807000
  801b0d:	e8 02 ed ff ff       	call   800814 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b12:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b15:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b1d:	b8 01 00 00 00       	mov    $0x1,%eax
  801b22:	e8 f6 fd ff ff       	call   80191d <fsipc>
  801b27:	89 c3                	mov    %eax,%ebx
  801b29:	83 c4 10             	add    $0x10,%esp
  801b2c:	85 c0                	test   %eax,%eax
  801b2e:	79 14                	jns    801b44 <open+0x6f>
		fd_close(fd, 0);
  801b30:	83 ec 08             	sub    $0x8,%esp
  801b33:	6a 00                	push   $0x0
  801b35:	ff 75 f4             	pushl  -0xc(%ebp)
  801b38:	e8 47 f9 ff ff       	call   801484 <fd_close>
		return r;
  801b3d:	83 c4 10             	add    $0x10,%esp
  801b40:	89 da                	mov    %ebx,%edx
  801b42:	eb 17                	jmp    801b5b <open+0x86>
	}

	return fd2num(fd);
  801b44:	83 ec 0c             	sub    $0xc,%esp
  801b47:	ff 75 f4             	pushl  -0xc(%ebp)
  801b4a:	e8 13 f8 ff ff       	call   801362 <fd2num>
  801b4f:	89 c2                	mov    %eax,%edx
  801b51:	83 c4 10             	add    $0x10,%esp
  801b54:	eb 05                	jmp    801b5b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b56:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b5b:	89 d0                	mov    %edx,%eax
  801b5d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b60:	c9                   	leave  
  801b61:	c3                   	ret    

00801b62 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b62:	55                   	push   %ebp
  801b63:	89 e5                	mov    %esp,%ebp
  801b65:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b68:	ba 00 00 00 00       	mov    $0x0,%edx
  801b6d:	b8 08 00 00 00       	mov    $0x8,%eax
  801b72:	e8 a6 fd ff ff       	call   80191d <fsipc>
}
  801b77:	c9                   	leave  
  801b78:	c3                   	ret    

00801b79 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801b79:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801b7d:	7e 37                	jle    801bb6 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801b7f:	55                   	push   %ebp
  801b80:	89 e5                	mov    %esp,%ebp
  801b82:	53                   	push   %ebx
  801b83:	83 ec 08             	sub    $0x8,%esp
  801b86:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801b88:	ff 70 04             	pushl  0x4(%eax)
  801b8b:	8d 40 10             	lea    0x10(%eax),%eax
  801b8e:	50                   	push   %eax
  801b8f:	ff 33                	pushl  (%ebx)
  801b91:	e8 88 fb ff ff       	call   80171e <write>
		if (result > 0)
  801b96:	83 c4 10             	add    $0x10,%esp
  801b99:	85 c0                	test   %eax,%eax
  801b9b:	7e 03                	jle    801ba0 <writebuf+0x27>
			b->result += result;
  801b9d:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801ba0:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ba3:	74 0d                	je     801bb2 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801ba5:	85 c0                	test   %eax,%eax
  801ba7:	ba 00 00 00 00       	mov    $0x0,%edx
  801bac:	0f 4f c2             	cmovg  %edx,%eax
  801baf:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801bb2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb5:	c9                   	leave  
  801bb6:	f3 c3                	repz ret 

00801bb8 <putch>:

static void
putch(int ch, void *thunk)
{
  801bb8:	55                   	push   %ebp
  801bb9:	89 e5                	mov    %esp,%ebp
  801bbb:	53                   	push   %ebx
  801bbc:	83 ec 04             	sub    $0x4,%esp
  801bbf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801bc2:	8b 53 04             	mov    0x4(%ebx),%edx
  801bc5:	8d 42 01             	lea    0x1(%edx),%eax
  801bc8:	89 43 04             	mov    %eax,0x4(%ebx)
  801bcb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bce:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801bd2:	3d 00 01 00 00       	cmp    $0x100,%eax
  801bd7:	75 0e                	jne    801be7 <putch+0x2f>
		writebuf(b);
  801bd9:	89 d8                	mov    %ebx,%eax
  801bdb:	e8 99 ff ff ff       	call   801b79 <writebuf>
		b->idx = 0;
  801be0:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801be7:	83 c4 04             	add    $0x4,%esp
  801bea:	5b                   	pop    %ebx
  801beb:	5d                   	pop    %ebp
  801bec:	c3                   	ret    

00801bed <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801bed:	55                   	push   %ebp
  801bee:	89 e5                	mov    %esp,%ebp
  801bf0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801bf6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf9:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801bff:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801c06:	00 00 00 
	b.result = 0;
  801c09:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801c10:	00 00 00 
	b.error = 1;
  801c13:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801c1a:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801c1d:	ff 75 10             	pushl  0x10(%ebp)
  801c20:	ff 75 0c             	pushl  0xc(%ebp)
  801c23:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801c29:	50                   	push   %eax
  801c2a:	68 b8 1b 80 00       	push   $0x801bb8
  801c2f:	e8 92 e7 ff ff       	call   8003c6 <vprintfmt>
	if (b.idx > 0)
  801c34:	83 c4 10             	add    $0x10,%esp
  801c37:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801c3e:	7e 0b                	jle    801c4b <vfprintf+0x5e>
		writebuf(&b);
  801c40:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801c46:	e8 2e ff ff ff       	call   801b79 <writebuf>

	return (b.result ? b.result : b.error);
  801c4b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801c51:	85 c0                	test   %eax,%eax
  801c53:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801c5a:	c9                   	leave  
  801c5b:	c3                   	ret    

00801c5c <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801c62:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801c65:	50                   	push   %eax
  801c66:	ff 75 0c             	pushl  0xc(%ebp)
  801c69:	ff 75 08             	pushl  0x8(%ebp)
  801c6c:	e8 7c ff ff ff       	call   801bed <vfprintf>
	va_end(ap);

	return cnt;
}
  801c71:	c9                   	leave  
  801c72:	c3                   	ret    

00801c73 <printf>:

int
printf(const char *fmt, ...)
{
  801c73:	55                   	push   %ebp
  801c74:	89 e5                	mov    %esp,%ebp
  801c76:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801c79:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801c7c:	50                   	push   %eax
  801c7d:	ff 75 08             	pushl  0x8(%ebp)
  801c80:	6a 01                	push   $0x1
  801c82:	e8 66 ff ff ff       	call   801bed <vfprintf>
	va_end(ap);

	return cnt;
}
  801c87:	c9                   	leave  
  801c88:	c3                   	ret    

00801c89 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c89:	55                   	push   %ebp
  801c8a:	89 e5                	mov    %esp,%ebp
  801c8c:	56                   	push   %esi
  801c8d:	53                   	push   %ebx
  801c8e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c91:	83 ec 0c             	sub    $0xc,%esp
  801c94:	ff 75 08             	pushl  0x8(%ebp)
  801c97:	e8 d6 f6 ff ff       	call   801372 <fd2data>
  801c9c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c9e:	83 c4 08             	add    $0x8,%esp
  801ca1:	68 fb 2a 80 00       	push   $0x802afb
  801ca6:	53                   	push   %ebx
  801ca7:	e8 68 eb ff ff       	call   800814 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801cac:	8b 46 04             	mov    0x4(%esi),%eax
  801caf:	2b 06                	sub    (%esi),%eax
  801cb1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801cb7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cbe:	00 00 00 
	stat->st_dev = &devpipe;
  801cc1:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801cc8:	30 80 00 
	return 0;
}
  801ccb:	b8 00 00 00 00       	mov    $0x0,%eax
  801cd0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cd3:	5b                   	pop    %ebx
  801cd4:	5e                   	pop    %esi
  801cd5:	5d                   	pop    %ebp
  801cd6:	c3                   	ret    

00801cd7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cd7:	55                   	push   %ebp
  801cd8:	89 e5                	mov    %esp,%ebp
  801cda:	53                   	push   %ebx
  801cdb:	83 ec 0c             	sub    $0xc,%esp
  801cde:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ce1:	53                   	push   %ebx
  801ce2:	6a 00                	push   $0x0
  801ce4:	e8 b3 ef ff ff       	call   800c9c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ce9:	89 1c 24             	mov    %ebx,(%esp)
  801cec:	e8 81 f6 ff ff       	call   801372 <fd2data>
  801cf1:	83 c4 08             	add    $0x8,%esp
  801cf4:	50                   	push   %eax
  801cf5:	6a 00                	push   $0x0
  801cf7:	e8 a0 ef ff ff       	call   800c9c <sys_page_unmap>
}
  801cfc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cff:	c9                   	leave  
  801d00:	c3                   	ret    

00801d01 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d01:	55                   	push   %ebp
  801d02:	89 e5                	mov    %esp,%ebp
  801d04:	57                   	push   %edi
  801d05:	56                   	push   %esi
  801d06:	53                   	push   %ebx
  801d07:	83 ec 1c             	sub    $0x1c,%esp
  801d0a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d0d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d0f:	a1 20 60 80 00       	mov    0x806020,%eax
  801d14:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d1a:	83 ec 0c             	sub    $0xc,%esp
  801d1d:	ff 75 e0             	pushl  -0x20(%ebp)
  801d20:	e8 fd 05 00 00       	call   802322 <pageref>
  801d25:	89 c3                	mov    %eax,%ebx
  801d27:	89 3c 24             	mov    %edi,(%esp)
  801d2a:	e8 f3 05 00 00       	call   802322 <pageref>
  801d2f:	83 c4 10             	add    $0x10,%esp
  801d32:	39 c3                	cmp    %eax,%ebx
  801d34:	0f 94 c1             	sete   %cl
  801d37:	0f b6 c9             	movzbl %cl,%ecx
  801d3a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d3d:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801d43:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  801d49:	39 ce                	cmp    %ecx,%esi
  801d4b:	74 1e                	je     801d6b <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801d4d:	39 c3                	cmp    %eax,%ebx
  801d4f:	75 be                	jne    801d0f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d51:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  801d57:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d5a:	50                   	push   %eax
  801d5b:	56                   	push   %esi
  801d5c:	68 02 2b 80 00       	push   $0x802b02
  801d61:	e8 29 e5 ff ff       	call   80028f <cprintf>
  801d66:	83 c4 10             	add    $0x10,%esp
  801d69:	eb a4                	jmp    801d0f <_pipeisclosed+0xe>
	}
}
  801d6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d71:	5b                   	pop    %ebx
  801d72:	5e                   	pop    %esi
  801d73:	5f                   	pop    %edi
  801d74:	5d                   	pop    %ebp
  801d75:	c3                   	ret    

00801d76 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d76:	55                   	push   %ebp
  801d77:	89 e5                	mov    %esp,%ebp
  801d79:	57                   	push   %edi
  801d7a:	56                   	push   %esi
  801d7b:	53                   	push   %ebx
  801d7c:	83 ec 28             	sub    $0x28,%esp
  801d7f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d82:	56                   	push   %esi
  801d83:	e8 ea f5 ff ff       	call   801372 <fd2data>
  801d88:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d8a:	83 c4 10             	add    $0x10,%esp
  801d8d:	bf 00 00 00 00       	mov    $0x0,%edi
  801d92:	eb 4b                	jmp    801ddf <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d94:	89 da                	mov    %ebx,%edx
  801d96:	89 f0                	mov    %esi,%eax
  801d98:	e8 64 ff ff ff       	call   801d01 <_pipeisclosed>
  801d9d:	85 c0                	test   %eax,%eax
  801d9f:	75 48                	jne    801de9 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801da1:	e8 52 ee ff ff       	call   800bf8 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801da6:	8b 43 04             	mov    0x4(%ebx),%eax
  801da9:	8b 0b                	mov    (%ebx),%ecx
  801dab:	8d 51 20             	lea    0x20(%ecx),%edx
  801dae:	39 d0                	cmp    %edx,%eax
  801db0:	73 e2                	jae    801d94 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801db2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801db5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801db9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801dbc:	89 c2                	mov    %eax,%edx
  801dbe:	c1 fa 1f             	sar    $0x1f,%edx
  801dc1:	89 d1                	mov    %edx,%ecx
  801dc3:	c1 e9 1b             	shr    $0x1b,%ecx
  801dc6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801dc9:	83 e2 1f             	and    $0x1f,%edx
  801dcc:	29 ca                	sub    %ecx,%edx
  801dce:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801dd2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801dd6:	83 c0 01             	add    $0x1,%eax
  801dd9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ddc:	83 c7 01             	add    $0x1,%edi
  801ddf:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801de2:	75 c2                	jne    801da6 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801de4:	8b 45 10             	mov    0x10(%ebp),%eax
  801de7:	eb 05                	jmp    801dee <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801de9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801dee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801df1:	5b                   	pop    %ebx
  801df2:	5e                   	pop    %esi
  801df3:	5f                   	pop    %edi
  801df4:	5d                   	pop    %ebp
  801df5:	c3                   	ret    

00801df6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801df6:	55                   	push   %ebp
  801df7:	89 e5                	mov    %esp,%ebp
  801df9:	57                   	push   %edi
  801dfa:	56                   	push   %esi
  801dfb:	53                   	push   %ebx
  801dfc:	83 ec 18             	sub    $0x18,%esp
  801dff:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e02:	57                   	push   %edi
  801e03:	e8 6a f5 ff ff       	call   801372 <fd2data>
  801e08:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e0a:	83 c4 10             	add    $0x10,%esp
  801e0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e12:	eb 3d                	jmp    801e51 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e14:	85 db                	test   %ebx,%ebx
  801e16:	74 04                	je     801e1c <devpipe_read+0x26>
				return i;
  801e18:	89 d8                	mov    %ebx,%eax
  801e1a:	eb 44                	jmp    801e60 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e1c:	89 f2                	mov    %esi,%edx
  801e1e:	89 f8                	mov    %edi,%eax
  801e20:	e8 dc fe ff ff       	call   801d01 <_pipeisclosed>
  801e25:	85 c0                	test   %eax,%eax
  801e27:	75 32                	jne    801e5b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e29:	e8 ca ed ff ff       	call   800bf8 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e2e:	8b 06                	mov    (%esi),%eax
  801e30:	3b 46 04             	cmp    0x4(%esi),%eax
  801e33:	74 df                	je     801e14 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e35:	99                   	cltd   
  801e36:	c1 ea 1b             	shr    $0x1b,%edx
  801e39:	01 d0                	add    %edx,%eax
  801e3b:	83 e0 1f             	and    $0x1f,%eax
  801e3e:	29 d0                	sub    %edx,%eax
  801e40:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e48:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e4b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e4e:	83 c3 01             	add    $0x1,%ebx
  801e51:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e54:	75 d8                	jne    801e2e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e56:	8b 45 10             	mov    0x10(%ebp),%eax
  801e59:	eb 05                	jmp    801e60 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e5b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e63:	5b                   	pop    %ebx
  801e64:	5e                   	pop    %esi
  801e65:	5f                   	pop    %edi
  801e66:	5d                   	pop    %ebp
  801e67:	c3                   	ret    

00801e68 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e68:	55                   	push   %ebp
  801e69:	89 e5                	mov    %esp,%ebp
  801e6b:	56                   	push   %esi
  801e6c:	53                   	push   %ebx
  801e6d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e73:	50                   	push   %eax
  801e74:	e8 10 f5 ff ff       	call   801389 <fd_alloc>
  801e79:	83 c4 10             	add    $0x10,%esp
  801e7c:	89 c2                	mov    %eax,%edx
  801e7e:	85 c0                	test   %eax,%eax
  801e80:	0f 88 2c 01 00 00    	js     801fb2 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e86:	83 ec 04             	sub    $0x4,%esp
  801e89:	68 07 04 00 00       	push   $0x407
  801e8e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e91:	6a 00                	push   $0x0
  801e93:	e8 7f ed ff ff       	call   800c17 <sys_page_alloc>
  801e98:	83 c4 10             	add    $0x10,%esp
  801e9b:	89 c2                	mov    %eax,%edx
  801e9d:	85 c0                	test   %eax,%eax
  801e9f:	0f 88 0d 01 00 00    	js     801fb2 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ea5:	83 ec 0c             	sub    $0xc,%esp
  801ea8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801eab:	50                   	push   %eax
  801eac:	e8 d8 f4 ff ff       	call   801389 <fd_alloc>
  801eb1:	89 c3                	mov    %eax,%ebx
  801eb3:	83 c4 10             	add    $0x10,%esp
  801eb6:	85 c0                	test   %eax,%eax
  801eb8:	0f 88 e2 00 00 00    	js     801fa0 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ebe:	83 ec 04             	sub    $0x4,%esp
  801ec1:	68 07 04 00 00       	push   $0x407
  801ec6:	ff 75 f0             	pushl  -0x10(%ebp)
  801ec9:	6a 00                	push   $0x0
  801ecb:	e8 47 ed ff ff       	call   800c17 <sys_page_alloc>
  801ed0:	89 c3                	mov    %eax,%ebx
  801ed2:	83 c4 10             	add    $0x10,%esp
  801ed5:	85 c0                	test   %eax,%eax
  801ed7:	0f 88 c3 00 00 00    	js     801fa0 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801edd:	83 ec 0c             	sub    $0xc,%esp
  801ee0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ee3:	e8 8a f4 ff ff       	call   801372 <fd2data>
  801ee8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eea:	83 c4 0c             	add    $0xc,%esp
  801eed:	68 07 04 00 00       	push   $0x407
  801ef2:	50                   	push   %eax
  801ef3:	6a 00                	push   $0x0
  801ef5:	e8 1d ed ff ff       	call   800c17 <sys_page_alloc>
  801efa:	89 c3                	mov    %eax,%ebx
  801efc:	83 c4 10             	add    $0x10,%esp
  801eff:	85 c0                	test   %eax,%eax
  801f01:	0f 88 89 00 00 00    	js     801f90 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f07:	83 ec 0c             	sub    $0xc,%esp
  801f0a:	ff 75 f0             	pushl  -0x10(%ebp)
  801f0d:	e8 60 f4 ff ff       	call   801372 <fd2data>
  801f12:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f19:	50                   	push   %eax
  801f1a:	6a 00                	push   $0x0
  801f1c:	56                   	push   %esi
  801f1d:	6a 00                	push   $0x0
  801f1f:	e8 36 ed ff ff       	call   800c5a <sys_page_map>
  801f24:	89 c3                	mov    %eax,%ebx
  801f26:	83 c4 20             	add    $0x20,%esp
  801f29:	85 c0                	test   %eax,%eax
  801f2b:	78 55                	js     801f82 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f2d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f36:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f42:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f48:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f4b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f50:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f57:	83 ec 0c             	sub    $0xc,%esp
  801f5a:	ff 75 f4             	pushl  -0xc(%ebp)
  801f5d:	e8 00 f4 ff ff       	call   801362 <fd2num>
  801f62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f65:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f67:	83 c4 04             	add    $0x4,%esp
  801f6a:	ff 75 f0             	pushl  -0x10(%ebp)
  801f6d:	e8 f0 f3 ff ff       	call   801362 <fd2num>
  801f72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f75:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801f78:	83 c4 10             	add    $0x10,%esp
  801f7b:	ba 00 00 00 00       	mov    $0x0,%edx
  801f80:	eb 30                	jmp    801fb2 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f82:	83 ec 08             	sub    $0x8,%esp
  801f85:	56                   	push   %esi
  801f86:	6a 00                	push   $0x0
  801f88:	e8 0f ed ff ff       	call   800c9c <sys_page_unmap>
  801f8d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f90:	83 ec 08             	sub    $0x8,%esp
  801f93:	ff 75 f0             	pushl  -0x10(%ebp)
  801f96:	6a 00                	push   $0x0
  801f98:	e8 ff ec ff ff       	call   800c9c <sys_page_unmap>
  801f9d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801fa0:	83 ec 08             	sub    $0x8,%esp
  801fa3:	ff 75 f4             	pushl  -0xc(%ebp)
  801fa6:	6a 00                	push   $0x0
  801fa8:	e8 ef ec ff ff       	call   800c9c <sys_page_unmap>
  801fad:	83 c4 10             	add    $0x10,%esp
  801fb0:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801fb2:	89 d0                	mov    %edx,%eax
  801fb4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fb7:	5b                   	pop    %ebx
  801fb8:	5e                   	pop    %esi
  801fb9:	5d                   	pop    %ebp
  801fba:	c3                   	ret    

00801fbb <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801fbb:	55                   	push   %ebp
  801fbc:	89 e5                	mov    %esp,%ebp
  801fbe:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fc1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fc4:	50                   	push   %eax
  801fc5:	ff 75 08             	pushl  0x8(%ebp)
  801fc8:	e8 0b f4 ff ff       	call   8013d8 <fd_lookup>
  801fcd:	83 c4 10             	add    $0x10,%esp
  801fd0:	85 c0                	test   %eax,%eax
  801fd2:	78 18                	js     801fec <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fd4:	83 ec 0c             	sub    $0xc,%esp
  801fd7:	ff 75 f4             	pushl  -0xc(%ebp)
  801fda:	e8 93 f3 ff ff       	call   801372 <fd2data>
	return _pipeisclosed(fd, p);
  801fdf:	89 c2                	mov    %eax,%edx
  801fe1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe4:	e8 18 fd ff ff       	call   801d01 <_pipeisclosed>
  801fe9:	83 c4 10             	add    $0x10,%esp
}
  801fec:	c9                   	leave  
  801fed:	c3                   	ret    

00801fee <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fee:	55                   	push   %ebp
  801fef:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ff1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ff6:	5d                   	pop    %ebp
  801ff7:	c3                   	ret    

00801ff8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ff8:	55                   	push   %ebp
  801ff9:	89 e5                	mov    %esp,%ebp
  801ffb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ffe:	68 1a 2b 80 00       	push   $0x802b1a
  802003:	ff 75 0c             	pushl  0xc(%ebp)
  802006:	e8 09 e8 ff ff       	call   800814 <strcpy>
	return 0;
}
  80200b:	b8 00 00 00 00       	mov    $0x0,%eax
  802010:	c9                   	leave  
  802011:	c3                   	ret    

00802012 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802012:	55                   	push   %ebp
  802013:	89 e5                	mov    %esp,%ebp
  802015:	57                   	push   %edi
  802016:	56                   	push   %esi
  802017:	53                   	push   %ebx
  802018:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80201e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802023:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802029:	eb 2d                	jmp    802058 <devcons_write+0x46>
		m = n - tot;
  80202b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80202e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802030:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802033:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802038:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80203b:	83 ec 04             	sub    $0x4,%esp
  80203e:	53                   	push   %ebx
  80203f:	03 45 0c             	add    0xc(%ebp),%eax
  802042:	50                   	push   %eax
  802043:	57                   	push   %edi
  802044:	e8 5d e9 ff ff       	call   8009a6 <memmove>
		sys_cputs(buf, m);
  802049:	83 c4 08             	add    $0x8,%esp
  80204c:	53                   	push   %ebx
  80204d:	57                   	push   %edi
  80204e:	e8 08 eb ff ff       	call   800b5b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802053:	01 de                	add    %ebx,%esi
  802055:	83 c4 10             	add    $0x10,%esp
  802058:	89 f0                	mov    %esi,%eax
  80205a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80205d:	72 cc                	jb     80202b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80205f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802062:	5b                   	pop    %ebx
  802063:	5e                   	pop    %esi
  802064:	5f                   	pop    %edi
  802065:	5d                   	pop    %ebp
  802066:	c3                   	ret    

00802067 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802067:	55                   	push   %ebp
  802068:	89 e5                	mov    %esp,%ebp
  80206a:	83 ec 08             	sub    $0x8,%esp
  80206d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802072:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802076:	74 2a                	je     8020a2 <devcons_read+0x3b>
  802078:	eb 05                	jmp    80207f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80207a:	e8 79 eb ff ff       	call   800bf8 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80207f:	e8 f5 ea ff ff       	call   800b79 <sys_cgetc>
  802084:	85 c0                	test   %eax,%eax
  802086:	74 f2                	je     80207a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802088:	85 c0                	test   %eax,%eax
  80208a:	78 16                	js     8020a2 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80208c:	83 f8 04             	cmp    $0x4,%eax
  80208f:	74 0c                	je     80209d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802091:	8b 55 0c             	mov    0xc(%ebp),%edx
  802094:	88 02                	mov    %al,(%edx)
	return 1;
  802096:	b8 01 00 00 00       	mov    $0x1,%eax
  80209b:	eb 05                	jmp    8020a2 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80209d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020a2:	c9                   	leave  
  8020a3:	c3                   	ret    

008020a4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020a4:	55                   	push   %ebp
  8020a5:	89 e5                	mov    %esp,%ebp
  8020a7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8020aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ad:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020b0:	6a 01                	push   $0x1
  8020b2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020b5:	50                   	push   %eax
  8020b6:	e8 a0 ea ff ff       	call   800b5b <sys_cputs>
}
  8020bb:	83 c4 10             	add    $0x10,%esp
  8020be:	c9                   	leave  
  8020bf:	c3                   	ret    

008020c0 <getchar>:

int
getchar(void)
{
  8020c0:	55                   	push   %ebp
  8020c1:	89 e5                	mov    %esp,%ebp
  8020c3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020c6:	6a 01                	push   $0x1
  8020c8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020cb:	50                   	push   %eax
  8020cc:	6a 00                	push   $0x0
  8020ce:	e8 6e f5 ff ff       	call   801641 <read>
	if (r < 0)
  8020d3:	83 c4 10             	add    $0x10,%esp
  8020d6:	85 c0                	test   %eax,%eax
  8020d8:	78 0f                	js     8020e9 <getchar+0x29>
		return r;
	if (r < 1)
  8020da:	85 c0                	test   %eax,%eax
  8020dc:	7e 06                	jle    8020e4 <getchar+0x24>
		return -E_EOF;
	return c;
  8020de:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020e2:	eb 05                	jmp    8020e9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020e4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020e9:	c9                   	leave  
  8020ea:	c3                   	ret    

008020eb <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020eb:	55                   	push   %ebp
  8020ec:	89 e5                	mov    %esp,%ebp
  8020ee:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020f4:	50                   	push   %eax
  8020f5:	ff 75 08             	pushl  0x8(%ebp)
  8020f8:	e8 db f2 ff ff       	call   8013d8 <fd_lookup>
  8020fd:	83 c4 10             	add    $0x10,%esp
  802100:	85 c0                	test   %eax,%eax
  802102:	78 11                	js     802115 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802104:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802107:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80210d:	39 10                	cmp    %edx,(%eax)
  80210f:	0f 94 c0             	sete   %al
  802112:	0f b6 c0             	movzbl %al,%eax
}
  802115:	c9                   	leave  
  802116:	c3                   	ret    

00802117 <opencons>:

int
opencons(void)
{
  802117:	55                   	push   %ebp
  802118:	89 e5                	mov    %esp,%ebp
  80211a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80211d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802120:	50                   	push   %eax
  802121:	e8 63 f2 ff ff       	call   801389 <fd_alloc>
  802126:	83 c4 10             	add    $0x10,%esp
		return r;
  802129:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80212b:	85 c0                	test   %eax,%eax
  80212d:	78 3e                	js     80216d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80212f:	83 ec 04             	sub    $0x4,%esp
  802132:	68 07 04 00 00       	push   $0x407
  802137:	ff 75 f4             	pushl  -0xc(%ebp)
  80213a:	6a 00                	push   $0x0
  80213c:	e8 d6 ea ff ff       	call   800c17 <sys_page_alloc>
  802141:	83 c4 10             	add    $0x10,%esp
		return r;
  802144:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802146:	85 c0                	test   %eax,%eax
  802148:	78 23                	js     80216d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80214a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802150:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802153:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802155:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802158:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80215f:	83 ec 0c             	sub    $0xc,%esp
  802162:	50                   	push   %eax
  802163:	e8 fa f1 ff ff       	call   801362 <fd2num>
  802168:	89 c2                	mov    %eax,%edx
  80216a:	83 c4 10             	add    $0x10,%esp
}
  80216d:	89 d0                	mov    %edx,%eax
  80216f:	c9                   	leave  
  802170:	c3                   	ret    

00802171 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802171:	55                   	push   %ebp
  802172:	89 e5                	mov    %esp,%ebp
  802174:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802177:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  80217e:	75 2a                	jne    8021aa <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802180:	83 ec 04             	sub    $0x4,%esp
  802183:	6a 07                	push   $0x7
  802185:	68 00 f0 bf ee       	push   $0xeebff000
  80218a:	6a 00                	push   $0x0
  80218c:	e8 86 ea ff ff       	call   800c17 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802191:	83 c4 10             	add    $0x10,%esp
  802194:	85 c0                	test   %eax,%eax
  802196:	79 12                	jns    8021aa <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802198:	50                   	push   %eax
  802199:	68 56 26 80 00       	push   $0x802656
  80219e:	6a 23                	push   $0x23
  8021a0:	68 26 2b 80 00       	push   $0x802b26
  8021a5:	e8 0c e0 ff ff       	call   8001b6 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8021aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ad:	a3 00 80 80 00       	mov    %eax,0x808000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8021b2:	83 ec 08             	sub    $0x8,%esp
  8021b5:	68 dc 21 80 00       	push   $0x8021dc
  8021ba:	6a 00                	push   $0x0
  8021bc:	e8 a1 eb ff ff       	call   800d62 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8021c1:	83 c4 10             	add    $0x10,%esp
  8021c4:	85 c0                	test   %eax,%eax
  8021c6:	79 12                	jns    8021da <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8021c8:	50                   	push   %eax
  8021c9:	68 56 26 80 00       	push   $0x802656
  8021ce:	6a 2c                	push   $0x2c
  8021d0:	68 26 2b 80 00       	push   $0x802b26
  8021d5:	e8 dc df ff ff       	call   8001b6 <_panic>
	}
}
  8021da:	c9                   	leave  
  8021db:	c3                   	ret    

008021dc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8021dc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8021dd:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  8021e2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8021e4:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8021e7:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8021eb:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8021f0:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8021f4:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8021f6:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8021f9:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8021fa:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8021fd:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8021fe:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8021ff:	c3                   	ret    

00802200 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802200:	55                   	push   %ebp
  802201:	89 e5                	mov    %esp,%ebp
  802203:	56                   	push   %esi
  802204:	53                   	push   %ebx
  802205:	8b 75 08             	mov    0x8(%ebp),%esi
  802208:	8b 45 0c             	mov    0xc(%ebp),%eax
  80220b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80220e:	85 c0                	test   %eax,%eax
  802210:	75 12                	jne    802224 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802212:	83 ec 0c             	sub    $0xc,%esp
  802215:	68 00 00 c0 ee       	push   $0xeec00000
  80221a:	e8 a8 eb ff ff       	call   800dc7 <sys_ipc_recv>
  80221f:	83 c4 10             	add    $0x10,%esp
  802222:	eb 0c                	jmp    802230 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802224:	83 ec 0c             	sub    $0xc,%esp
  802227:	50                   	push   %eax
  802228:	e8 9a eb ff ff       	call   800dc7 <sys_ipc_recv>
  80222d:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802230:	85 f6                	test   %esi,%esi
  802232:	0f 95 c1             	setne  %cl
  802235:	85 db                	test   %ebx,%ebx
  802237:	0f 95 c2             	setne  %dl
  80223a:	84 d1                	test   %dl,%cl
  80223c:	74 09                	je     802247 <ipc_recv+0x47>
  80223e:	89 c2                	mov    %eax,%edx
  802240:	c1 ea 1f             	shr    $0x1f,%edx
  802243:	84 d2                	test   %dl,%dl
  802245:	75 2d                	jne    802274 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802247:	85 f6                	test   %esi,%esi
  802249:	74 0d                	je     802258 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80224b:	a1 20 60 80 00       	mov    0x806020,%eax
  802250:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  802256:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802258:	85 db                	test   %ebx,%ebx
  80225a:	74 0d                	je     802269 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80225c:	a1 20 60 80 00       	mov    0x806020,%eax
  802261:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802267:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802269:	a1 20 60 80 00       	mov    0x806020,%eax
  80226e:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  802274:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802277:	5b                   	pop    %ebx
  802278:	5e                   	pop    %esi
  802279:	5d                   	pop    %ebp
  80227a:	c3                   	ret    

0080227b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80227b:	55                   	push   %ebp
  80227c:	89 e5                	mov    %esp,%ebp
  80227e:	57                   	push   %edi
  80227f:	56                   	push   %esi
  802280:	53                   	push   %ebx
  802281:	83 ec 0c             	sub    $0xc,%esp
  802284:	8b 7d 08             	mov    0x8(%ebp),%edi
  802287:	8b 75 0c             	mov    0xc(%ebp),%esi
  80228a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80228d:	85 db                	test   %ebx,%ebx
  80228f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802294:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802297:	ff 75 14             	pushl  0x14(%ebp)
  80229a:	53                   	push   %ebx
  80229b:	56                   	push   %esi
  80229c:	57                   	push   %edi
  80229d:	e8 02 eb ff ff       	call   800da4 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8022a2:	89 c2                	mov    %eax,%edx
  8022a4:	c1 ea 1f             	shr    $0x1f,%edx
  8022a7:	83 c4 10             	add    $0x10,%esp
  8022aa:	84 d2                	test   %dl,%dl
  8022ac:	74 17                	je     8022c5 <ipc_send+0x4a>
  8022ae:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022b1:	74 12                	je     8022c5 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8022b3:	50                   	push   %eax
  8022b4:	68 34 2b 80 00       	push   $0x802b34
  8022b9:	6a 47                	push   $0x47
  8022bb:	68 42 2b 80 00       	push   $0x802b42
  8022c0:	e8 f1 de ff ff       	call   8001b6 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8022c5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022c8:	75 07                	jne    8022d1 <ipc_send+0x56>
			sys_yield();
  8022ca:	e8 29 e9 ff ff       	call   800bf8 <sys_yield>
  8022cf:	eb c6                	jmp    802297 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8022d1:	85 c0                	test   %eax,%eax
  8022d3:	75 c2                	jne    802297 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8022d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022d8:	5b                   	pop    %ebx
  8022d9:	5e                   	pop    %esi
  8022da:	5f                   	pop    %edi
  8022db:	5d                   	pop    %ebp
  8022dc:	c3                   	ret    

008022dd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022dd:	55                   	push   %ebp
  8022de:	89 e5                	mov    %esp,%ebp
  8022e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8022e3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022e8:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  8022ee:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022f4:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  8022fa:	39 ca                	cmp    %ecx,%edx
  8022fc:	75 13                	jne    802311 <ipc_find_env+0x34>
			return envs[i].env_id;
  8022fe:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  802304:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802309:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80230f:	eb 0f                	jmp    802320 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802311:	83 c0 01             	add    $0x1,%eax
  802314:	3d 00 04 00 00       	cmp    $0x400,%eax
  802319:	75 cd                	jne    8022e8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80231b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802320:	5d                   	pop    %ebp
  802321:	c3                   	ret    

00802322 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802322:	55                   	push   %ebp
  802323:	89 e5                	mov    %esp,%ebp
  802325:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802328:	89 d0                	mov    %edx,%eax
  80232a:	c1 e8 16             	shr    $0x16,%eax
  80232d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802334:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802339:	f6 c1 01             	test   $0x1,%cl
  80233c:	74 1d                	je     80235b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80233e:	c1 ea 0c             	shr    $0xc,%edx
  802341:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802348:	f6 c2 01             	test   $0x1,%dl
  80234b:	74 0e                	je     80235b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80234d:	c1 ea 0c             	shr    $0xc,%edx
  802350:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802357:	ef 
  802358:	0f b7 c0             	movzwl %ax,%eax
}
  80235b:	5d                   	pop    %ebp
  80235c:	c3                   	ret    
  80235d:	66 90                	xchg   %ax,%ax
  80235f:	90                   	nop

00802360 <__udivdi3>:
  802360:	55                   	push   %ebp
  802361:	57                   	push   %edi
  802362:	56                   	push   %esi
  802363:	53                   	push   %ebx
  802364:	83 ec 1c             	sub    $0x1c,%esp
  802367:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80236b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80236f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802373:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802377:	85 f6                	test   %esi,%esi
  802379:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80237d:	89 ca                	mov    %ecx,%edx
  80237f:	89 f8                	mov    %edi,%eax
  802381:	75 3d                	jne    8023c0 <__udivdi3+0x60>
  802383:	39 cf                	cmp    %ecx,%edi
  802385:	0f 87 c5 00 00 00    	ja     802450 <__udivdi3+0xf0>
  80238b:	85 ff                	test   %edi,%edi
  80238d:	89 fd                	mov    %edi,%ebp
  80238f:	75 0b                	jne    80239c <__udivdi3+0x3c>
  802391:	b8 01 00 00 00       	mov    $0x1,%eax
  802396:	31 d2                	xor    %edx,%edx
  802398:	f7 f7                	div    %edi
  80239a:	89 c5                	mov    %eax,%ebp
  80239c:	89 c8                	mov    %ecx,%eax
  80239e:	31 d2                	xor    %edx,%edx
  8023a0:	f7 f5                	div    %ebp
  8023a2:	89 c1                	mov    %eax,%ecx
  8023a4:	89 d8                	mov    %ebx,%eax
  8023a6:	89 cf                	mov    %ecx,%edi
  8023a8:	f7 f5                	div    %ebp
  8023aa:	89 c3                	mov    %eax,%ebx
  8023ac:	89 d8                	mov    %ebx,%eax
  8023ae:	89 fa                	mov    %edi,%edx
  8023b0:	83 c4 1c             	add    $0x1c,%esp
  8023b3:	5b                   	pop    %ebx
  8023b4:	5e                   	pop    %esi
  8023b5:	5f                   	pop    %edi
  8023b6:	5d                   	pop    %ebp
  8023b7:	c3                   	ret    
  8023b8:	90                   	nop
  8023b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023c0:	39 ce                	cmp    %ecx,%esi
  8023c2:	77 74                	ja     802438 <__udivdi3+0xd8>
  8023c4:	0f bd fe             	bsr    %esi,%edi
  8023c7:	83 f7 1f             	xor    $0x1f,%edi
  8023ca:	0f 84 98 00 00 00    	je     802468 <__udivdi3+0x108>
  8023d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8023d5:	89 f9                	mov    %edi,%ecx
  8023d7:	89 c5                	mov    %eax,%ebp
  8023d9:	29 fb                	sub    %edi,%ebx
  8023db:	d3 e6                	shl    %cl,%esi
  8023dd:	89 d9                	mov    %ebx,%ecx
  8023df:	d3 ed                	shr    %cl,%ebp
  8023e1:	89 f9                	mov    %edi,%ecx
  8023e3:	d3 e0                	shl    %cl,%eax
  8023e5:	09 ee                	or     %ebp,%esi
  8023e7:	89 d9                	mov    %ebx,%ecx
  8023e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023ed:	89 d5                	mov    %edx,%ebp
  8023ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023f3:	d3 ed                	shr    %cl,%ebp
  8023f5:	89 f9                	mov    %edi,%ecx
  8023f7:	d3 e2                	shl    %cl,%edx
  8023f9:	89 d9                	mov    %ebx,%ecx
  8023fb:	d3 e8                	shr    %cl,%eax
  8023fd:	09 c2                	or     %eax,%edx
  8023ff:	89 d0                	mov    %edx,%eax
  802401:	89 ea                	mov    %ebp,%edx
  802403:	f7 f6                	div    %esi
  802405:	89 d5                	mov    %edx,%ebp
  802407:	89 c3                	mov    %eax,%ebx
  802409:	f7 64 24 0c          	mull   0xc(%esp)
  80240d:	39 d5                	cmp    %edx,%ebp
  80240f:	72 10                	jb     802421 <__udivdi3+0xc1>
  802411:	8b 74 24 08          	mov    0x8(%esp),%esi
  802415:	89 f9                	mov    %edi,%ecx
  802417:	d3 e6                	shl    %cl,%esi
  802419:	39 c6                	cmp    %eax,%esi
  80241b:	73 07                	jae    802424 <__udivdi3+0xc4>
  80241d:	39 d5                	cmp    %edx,%ebp
  80241f:	75 03                	jne    802424 <__udivdi3+0xc4>
  802421:	83 eb 01             	sub    $0x1,%ebx
  802424:	31 ff                	xor    %edi,%edi
  802426:	89 d8                	mov    %ebx,%eax
  802428:	89 fa                	mov    %edi,%edx
  80242a:	83 c4 1c             	add    $0x1c,%esp
  80242d:	5b                   	pop    %ebx
  80242e:	5e                   	pop    %esi
  80242f:	5f                   	pop    %edi
  802430:	5d                   	pop    %ebp
  802431:	c3                   	ret    
  802432:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802438:	31 ff                	xor    %edi,%edi
  80243a:	31 db                	xor    %ebx,%ebx
  80243c:	89 d8                	mov    %ebx,%eax
  80243e:	89 fa                	mov    %edi,%edx
  802440:	83 c4 1c             	add    $0x1c,%esp
  802443:	5b                   	pop    %ebx
  802444:	5e                   	pop    %esi
  802445:	5f                   	pop    %edi
  802446:	5d                   	pop    %ebp
  802447:	c3                   	ret    
  802448:	90                   	nop
  802449:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802450:	89 d8                	mov    %ebx,%eax
  802452:	f7 f7                	div    %edi
  802454:	31 ff                	xor    %edi,%edi
  802456:	89 c3                	mov    %eax,%ebx
  802458:	89 d8                	mov    %ebx,%eax
  80245a:	89 fa                	mov    %edi,%edx
  80245c:	83 c4 1c             	add    $0x1c,%esp
  80245f:	5b                   	pop    %ebx
  802460:	5e                   	pop    %esi
  802461:	5f                   	pop    %edi
  802462:	5d                   	pop    %ebp
  802463:	c3                   	ret    
  802464:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802468:	39 ce                	cmp    %ecx,%esi
  80246a:	72 0c                	jb     802478 <__udivdi3+0x118>
  80246c:	31 db                	xor    %ebx,%ebx
  80246e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802472:	0f 87 34 ff ff ff    	ja     8023ac <__udivdi3+0x4c>
  802478:	bb 01 00 00 00       	mov    $0x1,%ebx
  80247d:	e9 2a ff ff ff       	jmp    8023ac <__udivdi3+0x4c>
  802482:	66 90                	xchg   %ax,%ax
  802484:	66 90                	xchg   %ax,%ax
  802486:	66 90                	xchg   %ax,%ax
  802488:	66 90                	xchg   %ax,%ax
  80248a:	66 90                	xchg   %ax,%ax
  80248c:	66 90                	xchg   %ax,%ax
  80248e:	66 90                	xchg   %ax,%ax

00802490 <__umoddi3>:
  802490:	55                   	push   %ebp
  802491:	57                   	push   %edi
  802492:	56                   	push   %esi
  802493:	53                   	push   %ebx
  802494:	83 ec 1c             	sub    $0x1c,%esp
  802497:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80249b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80249f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024a7:	85 d2                	test   %edx,%edx
  8024a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8024ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024b1:	89 f3                	mov    %esi,%ebx
  8024b3:	89 3c 24             	mov    %edi,(%esp)
  8024b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024ba:	75 1c                	jne    8024d8 <__umoddi3+0x48>
  8024bc:	39 f7                	cmp    %esi,%edi
  8024be:	76 50                	jbe    802510 <__umoddi3+0x80>
  8024c0:	89 c8                	mov    %ecx,%eax
  8024c2:	89 f2                	mov    %esi,%edx
  8024c4:	f7 f7                	div    %edi
  8024c6:	89 d0                	mov    %edx,%eax
  8024c8:	31 d2                	xor    %edx,%edx
  8024ca:	83 c4 1c             	add    $0x1c,%esp
  8024cd:	5b                   	pop    %ebx
  8024ce:	5e                   	pop    %esi
  8024cf:	5f                   	pop    %edi
  8024d0:	5d                   	pop    %ebp
  8024d1:	c3                   	ret    
  8024d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024d8:	39 f2                	cmp    %esi,%edx
  8024da:	89 d0                	mov    %edx,%eax
  8024dc:	77 52                	ja     802530 <__umoddi3+0xa0>
  8024de:	0f bd ea             	bsr    %edx,%ebp
  8024e1:	83 f5 1f             	xor    $0x1f,%ebp
  8024e4:	75 5a                	jne    802540 <__umoddi3+0xb0>
  8024e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8024ea:	0f 82 e0 00 00 00    	jb     8025d0 <__umoddi3+0x140>
  8024f0:	39 0c 24             	cmp    %ecx,(%esp)
  8024f3:	0f 86 d7 00 00 00    	jbe    8025d0 <__umoddi3+0x140>
  8024f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802501:	83 c4 1c             	add    $0x1c,%esp
  802504:	5b                   	pop    %ebx
  802505:	5e                   	pop    %esi
  802506:	5f                   	pop    %edi
  802507:	5d                   	pop    %ebp
  802508:	c3                   	ret    
  802509:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802510:	85 ff                	test   %edi,%edi
  802512:	89 fd                	mov    %edi,%ebp
  802514:	75 0b                	jne    802521 <__umoddi3+0x91>
  802516:	b8 01 00 00 00       	mov    $0x1,%eax
  80251b:	31 d2                	xor    %edx,%edx
  80251d:	f7 f7                	div    %edi
  80251f:	89 c5                	mov    %eax,%ebp
  802521:	89 f0                	mov    %esi,%eax
  802523:	31 d2                	xor    %edx,%edx
  802525:	f7 f5                	div    %ebp
  802527:	89 c8                	mov    %ecx,%eax
  802529:	f7 f5                	div    %ebp
  80252b:	89 d0                	mov    %edx,%eax
  80252d:	eb 99                	jmp    8024c8 <__umoddi3+0x38>
  80252f:	90                   	nop
  802530:	89 c8                	mov    %ecx,%eax
  802532:	89 f2                	mov    %esi,%edx
  802534:	83 c4 1c             	add    $0x1c,%esp
  802537:	5b                   	pop    %ebx
  802538:	5e                   	pop    %esi
  802539:	5f                   	pop    %edi
  80253a:	5d                   	pop    %ebp
  80253b:	c3                   	ret    
  80253c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802540:	8b 34 24             	mov    (%esp),%esi
  802543:	bf 20 00 00 00       	mov    $0x20,%edi
  802548:	89 e9                	mov    %ebp,%ecx
  80254a:	29 ef                	sub    %ebp,%edi
  80254c:	d3 e0                	shl    %cl,%eax
  80254e:	89 f9                	mov    %edi,%ecx
  802550:	89 f2                	mov    %esi,%edx
  802552:	d3 ea                	shr    %cl,%edx
  802554:	89 e9                	mov    %ebp,%ecx
  802556:	09 c2                	or     %eax,%edx
  802558:	89 d8                	mov    %ebx,%eax
  80255a:	89 14 24             	mov    %edx,(%esp)
  80255d:	89 f2                	mov    %esi,%edx
  80255f:	d3 e2                	shl    %cl,%edx
  802561:	89 f9                	mov    %edi,%ecx
  802563:	89 54 24 04          	mov    %edx,0x4(%esp)
  802567:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80256b:	d3 e8                	shr    %cl,%eax
  80256d:	89 e9                	mov    %ebp,%ecx
  80256f:	89 c6                	mov    %eax,%esi
  802571:	d3 e3                	shl    %cl,%ebx
  802573:	89 f9                	mov    %edi,%ecx
  802575:	89 d0                	mov    %edx,%eax
  802577:	d3 e8                	shr    %cl,%eax
  802579:	89 e9                	mov    %ebp,%ecx
  80257b:	09 d8                	or     %ebx,%eax
  80257d:	89 d3                	mov    %edx,%ebx
  80257f:	89 f2                	mov    %esi,%edx
  802581:	f7 34 24             	divl   (%esp)
  802584:	89 d6                	mov    %edx,%esi
  802586:	d3 e3                	shl    %cl,%ebx
  802588:	f7 64 24 04          	mull   0x4(%esp)
  80258c:	39 d6                	cmp    %edx,%esi
  80258e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802592:	89 d1                	mov    %edx,%ecx
  802594:	89 c3                	mov    %eax,%ebx
  802596:	72 08                	jb     8025a0 <__umoddi3+0x110>
  802598:	75 11                	jne    8025ab <__umoddi3+0x11b>
  80259a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80259e:	73 0b                	jae    8025ab <__umoddi3+0x11b>
  8025a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8025a4:	1b 14 24             	sbb    (%esp),%edx
  8025a7:	89 d1                	mov    %edx,%ecx
  8025a9:	89 c3                	mov    %eax,%ebx
  8025ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8025af:	29 da                	sub    %ebx,%edx
  8025b1:	19 ce                	sbb    %ecx,%esi
  8025b3:	89 f9                	mov    %edi,%ecx
  8025b5:	89 f0                	mov    %esi,%eax
  8025b7:	d3 e0                	shl    %cl,%eax
  8025b9:	89 e9                	mov    %ebp,%ecx
  8025bb:	d3 ea                	shr    %cl,%edx
  8025bd:	89 e9                	mov    %ebp,%ecx
  8025bf:	d3 ee                	shr    %cl,%esi
  8025c1:	09 d0                	or     %edx,%eax
  8025c3:	89 f2                	mov    %esi,%edx
  8025c5:	83 c4 1c             	add    $0x1c,%esp
  8025c8:	5b                   	pop    %ebx
  8025c9:	5e                   	pop    %esi
  8025ca:	5f                   	pop    %edi
  8025cb:	5d                   	pop    %ebp
  8025cc:	c3                   	ret    
  8025cd:	8d 76 00             	lea    0x0(%esi),%esi
  8025d0:	29 f9                	sub    %edi,%ecx
  8025d2:	19 d6                	sbb    %edx,%esi
  8025d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025dc:	e9 18 ff ff ff       	jmp    8024f9 <__umoddi3+0x69>
