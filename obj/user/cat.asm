
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
  800048:	e8 53 17 00 00       	call   8017a0 <write>
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	39 c3                	cmp    %eax,%ebx
  800052:	74 18                	je     80006c <cat+0x39>
			panic("write error copying %s: %e", s, r);
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	50                   	push   %eax
  800058:	ff 75 0c             	pushl  0xc(%ebp)
  80005b:	68 80 26 80 00       	push   $0x802680
  800060:	6a 0d                	push   $0xd
  800062:	68 9b 26 80 00       	push   $0x80269b
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
  80007a:	e8 44 16 00 00       	call   8016c3 <read>
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
  800093:	68 a6 26 80 00       	push   $0x8026a6
  800098:	6a 0f                	push   $0xf
  80009a:	68 9b 26 80 00       	push   $0x80269b
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
  8000b7:	c7 05 00 30 80 00 bb 	movl   $0x8026bb,0x803000
  8000be:	26 80 00 
  8000c1:	bb 01 00 00 00       	mov    $0x1,%ebx
	if (argc == 1)
  8000c6:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ca:	75 5a                	jne    800126 <umain+0x7b>
		cat(0, "<stdin>");
  8000cc:	83 ec 08             	sub    $0x8,%esp
  8000cf:	68 bf 26 80 00       	push   $0x8026bf
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
  8000e8:	e8 6a 1a 00 00       	call   801b57 <open>
  8000ed:	89 c6                	mov    %eax,%esi
			if (f < 0)
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	85 c0                	test   %eax,%eax
  8000f4:	79 16                	jns    80010c <umain+0x61>
				printf("can't open %s: %e\n", argv[i], f);
  8000f6:	83 ec 04             	sub    $0x4,%esp
  8000f9:	50                   	push   %eax
  8000fa:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000fd:	68 c7 26 80 00       	push   $0x8026c7
  800102:	e8 ee 1b 00 00       	call   801cf5 <printf>
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
  80011b:	e8 67 14 00 00       	call   801587 <close>
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
  800148:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  80014e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800153:	a3 20 60 80 00       	mov    %eax,0x806020
			thisenv = &envs[i];
		}
	}*/

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

void 
thread_main(/*uintptr_t eip*/)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

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
  8001a2:	e8 0b 14 00 00       	call   8015b2 <close_all>
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
  8001d4:	68 e4 26 80 00       	push   $0x8026e4
  8001d9:	e8 b1 00 00 00       	call   80028f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001de:	83 c4 18             	add    $0x18,%esp
  8001e1:	53                   	push   %ebx
  8001e2:	ff 75 10             	pushl  0x10(%ebp)
  8001e5:	e8 54 00 00 00       	call   80023e <vcprintf>
	cprintf("\n");
  8001ea:	c7 04 24 c6 2a 80 00 	movl   $0x802ac6,(%esp)
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
  8002f2:	e8 e9 20 00 00       	call   8023e0 <__udivdi3>
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
  800335:	e8 d6 21 00 00       	call   802510 <__umoddi3>
  80033a:	83 c4 14             	add    $0x14,%esp
  80033d:	0f be 80 07 27 80 00 	movsbl 0x802707(%eax),%eax
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
  800439:	ff 24 85 40 28 80 00 	jmp    *0x802840(,%eax,4)
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
  8004fd:	8b 14 85 a0 29 80 00 	mov    0x8029a0(,%eax,4),%edx
  800504:	85 d2                	test   %edx,%edx
  800506:	75 18                	jne    800520 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800508:	50                   	push   %eax
  800509:	68 1f 27 80 00       	push   $0x80271f
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
  800521:	68 31 2c 80 00       	push   $0x802c31
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
  800545:	b8 18 27 80 00       	mov    $0x802718,%eax
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
  800bc0:	68 ff 29 80 00       	push   $0x8029ff
  800bc5:	6a 23                	push   $0x23
  800bc7:	68 1c 2a 80 00       	push   $0x802a1c
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
  800c41:	68 ff 29 80 00       	push   $0x8029ff
  800c46:	6a 23                	push   $0x23
  800c48:	68 1c 2a 80 00       	push   $0x802a1c
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
  800c83:	68 ff 29 80 00       	push   $0x8029ff
  800c88:	6a 23                	push   $0x23
  800c8a:	68 1c 2a 80 00       	push   $0x802a1c
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
  800cc5:	68 ff 29 80 00       	push   $0x8029ff
  800cca:	6a 23                	push   $0x23
  800ccc:	68 1c 2a 80 00       	push   $0x802a1c
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
  800d07:	68 ff 29 80 00       	push   $0x8029ff
  800d0c:	6a 23                	push   $0x23
  800d0e:	68 1c 2a 80 00       	push   $0x802a1c
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
  800d49:	68 ff 29 80 00       	push   $0x8029ff
  800d4e:	6a 23                	push   $0x23
  800d50:	68 1c 2a 80 00       	push   $0x802a1c
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
  800d8b:	68 ff 29 80 00       	push   $0x8029ff
  800d90:	6a 23                	push   $0x23
  800d92:	68 1c 2a 80 00       	push   $0x802a1c
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
  800def:	68 ff 29 80 00       	push   $0x8029ff
  800df4:	6a 23                	push   $0x23
  800df6:	68 1c 2a 80 00       	push   $0x802a1c
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
  800e8e:	68 2a 2a 80 00       	push   $0x802a2a
  800e93:	6a 1f                	push   $0x1f
  800e95:	68 3a 2a 80 00       	push   $0x802a3a
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
  800eb8:	68 45 2a 80 00       	push   $0x802a45
  800ebd:	6a 2d                	push   $0x2d
  800ebf:	68 3a 2a 80 00       	push   $0x802a3a
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
  800f00:	68 45 2a 80 00       	push   $0x802a45
  800f05:	6a 34                	push   $0x34
  800f07:	68 3a 2a 80 00       	push   $0x802a3a
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
  800f28:	68 45 2a 80 00       	push   $0x802a45
  800f2d:	6a 38                	push   $0x38
  800f2f:	68 3a 2a 80 00       	push   $0x802a3a
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
  800f4c:	e8 a2 12 00 00       	call   8021f3 <set_pgfault_handler>
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
  800f65:	68 5e 2a 80 00       	push   $0x802a5e
  800f6a:	68 85 00 00 00       	push   $0x85
  800f6f:	68 3a 2a 80 00       	push   $0x802a3a
  800f74:	e8 3d f2 ff ff       	call   8001b6 <_panic>
  800f79:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f7b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f7f:	75 24                	jne    800fa5 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f81:	e8 53 fc ff ff       	call   800bd9 <sys_getenvid>
  800f86:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f8b:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  801021:	68 6c 2a 80 00       	push   $0x802a6c
  801026:	6a 55                	push   $0x55
  801028:	68 3a 2a 80 00       	push   $0x802a3a
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
  801066:	68 6c 2a 80 00       	push   $0x802a6c
  80106b:	6a 5c                	push   $0x5c
  80106d:	68 3a 2a 80 00       	push   $0x802a3a
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
  801094:	68 6c 2a 80 00       	push   $0x802a6c
  801099:	6a 60                	push   $0x60
  80109b:	68 3a 2a 80 00       	push   $0x802a3a
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
  8010be:	68 6c 2a 80 00       	push   $0x802a6c
  8010c3:	6a 65                	push   $0x65
  8010c5:	68 3a 2a 80 00       	push   $0x802a3a
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
  8010e6:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
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
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	56                   	push   %esi
  80111f:	53                   	push   %ebx
  801120:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801123:	89 1d 24 60 80 00    	mov    %ebx,0x806024
	cprintf("in fork.c thread create. func: %x\n", func);
  801129:	83 ec 08             	sub    $0x8,%esp
  80112c:	53                   	push   %ebx
  80112d:	68 fc 2a 80 00       	push   $0x802afc
  801132:	e8 58 f1 ff ff       	call   80028f <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801137:	c7 04 24 7c 01 80 00 	movl   $0x80017c,(%esp)
  80113e:	e8 c5 fc ff ff       	call   800e08 <sys_thread_create>
  801143:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801145:	83 c4 08             	add    $0x8,%esp
  801148:	53                   	push   %ebx
  801149:	68 fc 2a 80 00       	push   $0x802afc
  80114e:	e8 3c f1 ff ff       	call   80028f <cprintf>
	return id;
}
  801153:	89 f0                	mov    %esi,%eax
  801155:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801158:	5b                   	pop    %ebx
  801159:	5e                   	pop    %esi
  80115a:	5d                   	pop    %ebp
  80115b:	c3                   	ret    

0080115c <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
  80115f:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  801162:	ff 75 08             	pushl  0x8(%ebp)
  801165:	e8 be fc ff ff       	call   800e28 <sys_thread_free>
}
  80116a:	83 c4 10             	add    $0x10,%esp
  80116d:	c9                   	leave  
  80116e:	c3                   	ret    

0080116f <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  80116f:	55                   	push   %ebp
  801170:	89 e5                	mov    %esp,%ebp
  801172:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  801175:	ff 75 08             	pushl  0x8(%ebp)
  801178:	e8 cb fc ff ff       	call   800e48 <sys_thread_join>
}
  80117d:	83 c4 10             	add    $0x10,%esp
  801180:	c9                   	leave  
  801181:	c3                   	ret    

00801182 <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  801182:	55                   	push   %ebp
  801183:	89 e5                	mov    %esp,%ebp
  801185:	56                   	push   %esi
  801186:	53                   	push   %ebx
  801187:	8b 75 08             	mov    0x8(%ebp),%esi
  80118a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  80118d:	83 ec 04             	sub    $0x4,%esp
  801190:	6a 07                	push   $0x7
  801192:	6a 00                	push   $0x0
  801194:	56                   	push   %esi
  801195:	e8 7d fa ff ff       	call   800c17 <sys_page_alloc>
	if (r < 0) {
  80119a:	83 c4 10             	add    $0x10,%esp
  80119d:	85 c0                	test   %eax,%eax
  80119f:	79 15                	jns    8011b6 <queue_append+0x34>
		panic("%e\n", r);
  8011a1:	50                   	push   %eax
  8011a2:	68 d6 26 80 00       	push   $0x8026d6
  8011a7:	68 c4 00 00 00       	push   $0xc4
  8011ac:	68 3a 2a 80 00       	push   $0x802a3a
  8011b1:	e8 00 f0 ff ff       	call   8001b6 <_panic>
	}	
	wt->envid = envid;
  8011b6:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  8011bc:	83 ec 04             	sub    $0x4,%esp
  8011bf:	ff 33                	pushl  (%ebx)
  8011c1:	56                   	push   %esi
  8011c2:	68 20 2b 80 00       	push   $0x802b20
  8011c7:	e8 c3 f0 ff ff       	call   80028f <cprintf>
	if (queue->first == NULL) {
  8011cc:	83 c4 10             	add    $0x10,%esp
  8011cf:	83 3b 00             	cmpl   $0x0,(%ebx)
  8011d2:	75 29                	jne    8011fd <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  8011d4:	83 ec 0c             	sub    $0xc,%esp
  8011d7:	68 82 2a 80 00       	push   $0x802a82
  8011dc:	e8 ae f0 ff ff       	call   80028f <cprintf>
		queue->first = wt;
  8011e1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  8011e7:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  8011ee:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8011f5:	00 00 00 
  8011f8:	83 c4 10             	add    $0x10,%esp
  8011fb:	eb 2b                	jmp    801228 <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  8011fd:	83 ec 0c             	sub    $0xc,%esp
  801200:	68 9c 2a 80 00       	push   $0x802a9c
  801205:	e8 85 f0 ff ff       	call   80028f <cprintf>
		queue->last->next = wt;
  80120a:	8b 43 04             	mov    0x4(%ebx),%eax
  80120d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  801214:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80121b:	00 00 00 
		queue->last = wt;
  80121e:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  801225:	83 c4 10             	add    $0x10,%esp
	}
}
  801228:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80122b:	5b                   	pop    %ebx
  80122c:	5e                   	pop    %esi
  80122d:	5d                   	pop    %ebp
  80122e:	c3                   	ret    

0080122f <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  80122f:	55                   	push   %ebp
  801230:	89 e5                	mov    %esp,%ebp
  801232:	53                   	push   %ebx
  801233:	83 ec 04             	sub    $0x4,%esp
  801236:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  801239:	8b 02                	mov    (%edx),%eax
  80123b:	85 c0                	test   %eax,%eax
  80123d:	75 17                	jne    801256 <queue_pop+0x27>
		panic("queue empty!\n");
  80123f:	83 ec 04             	sub    $0x4,%esp
  801242:	68 ba 2a 80 00       	push   $0x802aba
  801247:	68 d8 00 00 00       	push   $0xd8
  80124c:	68 3a 2a 80 00       	push   $0x802a3a
  801251:	e8 60 ef ff ff       	call   8001b6 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  801256:	8b 48 04             	mov    0x4(%eax),%ecx
  801259:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  80125b:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  80125d:	83 ec 08             	sub    $0x8,%esp
  801260:	53                   	push   %ebx
  801261:	68 c8 2a 80 00       	push   $0x802ac8
  801266:	e8 24 f0 ff ff       	call   80028f <cprintf>
	return envid;
}
  80126b:	89 d8                	mov    %ebx,%eax
  80126d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801270:	c9                   	leave  
  801271:	c3                   	ret    

00801272 <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	53                   	push   %ebx
  801276:	83 ec 04             	sub    $0x4,%esp
  801279:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  80127c:	b8 01 00 00 00       	mov    $0x1,%eax
  801281:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801284:	85 c0                	test   %eax,%eax
  801286:	74 5a                	je     8012e2 <mutex_lock+0x70>
  801288:	8b 43 04             	mov    0x4(%ebx),%eax
  80128b:	83 38 00             	cmpl   $0x0,(%eax)
  80128e:	75 52                	jne    8012e2 <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  801290:	83 ec 0c             	sub    $0xc,%esp
  801293:	68 48 2b 80 00       	push   $0x802b48
  801298:	e8 f2 ef ff ff       	call   80028f <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  80129d:	8b 5b 04             	mov    0x4(%ebx),%ebx
  8012a0:	e8 34 f9 ff ff       	call   800bd9 <sys_getenvid>
  8012a5:	83 c4 08             	add    $0x8,%esp
  8012a8:	53                   	push   %ebx
  8012a9:	50                   	push   %eax
  8012aa:	e8 d3 fe ff ff       	call   801182 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  8012af:	e8 25 f9 ff ff       	call   800bd9 <sys_getenvid>
  8012b4:	83 c4 08             	add    $0x8,%esp
  8012b7:	6a 04                	push   $0x4
  8012b9:	50                   	push   %eax
  8012ba:	e8 1f fa ff ff       	call   800cde <sys_env_set_status>
		if (r < 0) {
  8012bf:	83 c4 10             	add    $0x10,%esp
  8012c2:	85 c0                	test   %eax,%eax
  8012c4:	79 15                	jns    8012db <mutex_lock+0x69>
			panic("%e\n", r);
  8012c6:	50                   	push   %eax
  8012c7:	68 d6 26 80 00       	push   $0x8026d6
  8012cc:	68 eb 00 00 00       	push   $0xeb
  8012d1:	68 3a 2a 80 00       	push   $0x802a3a
  8012d6:	e8 db ee ff ff       	call   8001b6 <_panic>
		}
		sys_yield();
  8012db:	e8 18 f9 ff ff       	call   800bf8 <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8012e0:	eb 18                	jmp    8012fa <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  8012e2:	83 ec 0c             	sub    $0xc,%esp
  8012e5:	68 68 2b 80 00       	push   $0x802b68
  8012ea:	e8 a0 ef ff ff       	call   80028f <cprintf>
	mtx->owner = sys_getenvid();}
  8012ef:	e8 e5 f8 ff ff       	call   800bd9 <sys_getenvid>
  8012f4:	89 43 08             	mov    %eax,0x8(%ebx)
  8012f7:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  8012fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012fd:	c9                   	leave  
  8012fe:	c3                   	ret    

008012ff <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  8012ff:	55                   	push   %ebp
  801300:	89 e5                	mov    %esp,%ebp
  801302:	53                   	push   %ebx
  801303:	83 ec 04             	sub    $0x4,%esp
  801306:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801309:	b8 00 00 00 00       	mov    $0x0,%eax
  80130e:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  801311:	8b 43 04             	mov    0x4(%ebx),%eax
  801314:	83 38 00             	cmpl   $0x0,(%eax)
  801317:	74 33                	je     80134c <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  801319:	83 ec 0c             	sub    $0xc,%esp
  80131c:	50                   	push   %eax
  80131d:	e8 0d ff ff ff       	call   80122f <queue_pop>
  801322:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  801325:	83 c4 08             	add    $0x8,%esp
  801328:	6a 02                	push   $0x2
  80132a:	50                   	push   %eax
  80132b:	e8 ae f9 ff ff       	call   800cde <sys_env_set_status>
		if (r < 0) {
  801330:	83 c4 10             	add    $0x10,%esp
  801333:	85 c0                	test   %eax,%eax
  801335:	79 15                	jns    80134c <mutex_unlock+0x4d>
			panic("%e\n", r);
  801337:	50                   	push   %eax
  801338:	68 d6 26 80 00       	push   $0x8026d6
  80133d:	68 00 01 00 00       	push   $0x100
  801342:	68 3a 2a 80 00       	push   $0x802a3a
  801347:	e8 6a ee ff ff       	call   8001b6 <_panic>
		}
	}

	asm volatile("pause");
  80134c:	f3 90                	pause  
	//sys_yield();
}
  80134e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801351:	c9                   	leave  
  801352:	c3                   	ret    

00801353 <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  801353:	55                   	push   %ebp
  801354:	89 e5                	mov    %esp,%ebp
  801356:	53                   	push   %ebx
  801357:	83 ec 04             	sub    $0x4,%esp
  80135a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  80135d:	e8 77 f8 ff ff       	call   800bd9 <sys_getenvid>
  801362:	83 ec 04             	sub    $0x4,%esp
  801365:	6a 07                	push   $0x7
  801367:	53                   	push   %ebx
  801368:	50                   	push   %eax
  801369:	e8 a9 f8 ff ff       	call   800c17 <sys_page_alloc>
  80136e:	83 c4 10             	add    $0x10,%esp
  801371:	85 c0                	test   %eax,%eax
  801373:	79 15                	jns    80138a <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  801375:	50                   	push   %eax
  801376:	68 e3 2a 80 00       	push   $0x802ae3
  80137b:	68 0d 01 00 00       	push   $0x10d
  801380:	68 3a 2a 80 00       	push   $0x802a3a
  801385:	e8 2c ee ff ff       	call   8001b6 <_panic>
	}	
	mtx->locked = 0;
  80138a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  801390:	8b 43 04             	mov    0x4(%ebx),%eax
  801393:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  801399:	8b 43 04             	mov    0x4(%ebx),%eax
  80139c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  8013a3:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  8013aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ad:	c9                   	leave  
  8013ae:	c3                   	ret    

008013af <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  8013af:	55                   	push   %ebp
  8013b0:	89 e5                	mov    %esp,%ebp
  8013b2:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  8013b5:	e8 1f f8 ff ff       	call   800bd9 <sys_getenvid>
  8013ba:	83 ec 08             	sub    $0x8,%esp
  8013bd:	ff 75 08             	pushl  0x8(%ebp)
  8013c0:	50                   	push   %eax
  8013c1:	e8 d6 f8 ff ff       	call   800c9c <sys_page_unmap>
	if (r < 0) {
  8013c6:	83 c4 10             	add    $0x10,%esp
  8013c9:	85 c0                	test   %eax,%eax
  8013cb:	79 15                	jns    8013e2 <mutex_destroy+0x33>
		panic("%e\n", r);
  8013cd:	50                   	push   %eax
  8013ce:	68 d6 26 80 00       	push   $0x8026d6
  8013d3:	68 1a 01 00 00       	push   $0x11a
  8013d8:	68 3a 2a 80 00       	push   $0x802a3a
  8013dd:	e8 d4 ed ff ff       	call   8001b6 <_panic>
	}
}
  8013e2:	c9                   	leave  
  8013e3:	c3                   	ret    

008013e4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013e4:	55                   	push   %ebp
  8013e5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ea:	05 00 00 00 30       	add    $0x30000000,%eax
  8013ef:	c1 e8 0c             	shr    $0xc,%eax
}
  8013f2:	5d                   	pop    %ebp
  8013f3:	c3                   	ret    

008013f4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013f4:	55                   	push   %ebp
  8013f5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8013f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fa:	05 00 00 00 30       	add    $0x30000000,%eax
  8013ff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801404:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801409:	5d                   	pop    %ebp
  80140a:	c3                   	ret    

0080140b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80140b:	55                   	push   %ebp
  80140c:	89 e5                	mov    %esp,%ebp
  80140e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801411:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801416:	89 c2                	mov    %eax,%edx
  801418:	c1 ea 16             	shr    $0x16,%edx
  80141b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801422:	f6 c2 01             	test   $0x1,%dl
  801425:	74 11                	je     801438 <fd_alloc+0x2d>
  801427:	89 c2                	mov    %eax,%edx
  801429:	c1 ea 0c             	shr    $0xc,%edx
  80142c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801433:	f6 c2 01             	test   $0x1,%dl
  801436:	75 09                	jne    801441 <fd_alloc+0x36>
			*fd_store = fd;
  801438:	89 01                	mov    %eax,(%ecx)
			return 0;
  80143a:	b8 00 00 00 00       	mov    $0x0,%eax
  80143f:	eb 17                	jmp    801458 <fd_alloc+0x4d>
  801441:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801446:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80144b:	75 c9                	jne    801416 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80144d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801453:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801458:	5d                   	pop    %ebp
  801459:	c3                   	ret    

0080145a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801460:	83 f8 1f             	cmp    $0x1f,%eax
  801463:	77 36                	ja     80149b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801465:	c1 e0 0c             	shl    $0xc,%eax
  801468:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80146d:	89 c2                	mov    %eax,%edx
  80146f:	c1 ea 16             	shr    $0x16,%edx
  801472:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801479:	f6 c2 01             	test   $0x1,%dl
  80147c:	74 24                	je     8014a2 <fd_lookup+0x48>
  80147e:	89 c2                	mov    %eax,%edx
  801480:	c1 ea 0c             	shr    $0xc,%edx
  801483:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80148a:	f6 c2 01             	test   $0x1,%dl
  80148d:	74 1a                	je     8014a9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80148f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801492:	89 02                	mov    %eax,(%edx)
	return 0;
  801494:	b8 00 00 00 00       	mov    $0x0,%eax
  801499:	eb 13                	jmp    8014ae <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80149b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014a0:	eb 0c                	jmp    8014ae <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014a7:	eb 05                	jmp    8014ae <fd_lookup+0x54>
  8014a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014ae:	5d                   	pop    %ebp
  8014af:	c3                   	ret    

008014b0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014b0:	55                   	push   %ebp
  8014b1:	89 e5                	mov    %esp,%ebp
  8014b3:	83 ec 08             	sub    $0x8,%esp
  8014b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014b9:	ba 08 2c 80 00       	mov    $0x802c08,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014be:	eb 13                	jmp    8014d3 <dev_lookup+0x23>
  8014c0:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8014c3:	39 08                	cmp    %ecx,(%eax)
  8014c5:	75 0c                	jne    8014d3 <dev_lookup+0x23>
			*dev = devtab[i];
  8014c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014ca:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8014d1:	eb 31                	jmp    801504 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014d3:	8b 02                	mov    (%edx),%eax
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	75 e7                	jne    8014c0 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014d9:	a1 20 60 80 00       	mov    0x806020,%eax
  8014de:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8014e4:	83 ec 04             	sub    $0x4,%esp
  8014e7:	51                   	push   %ecx
  8014e8:	50                   	push   %eax
  8014e9:	68 88 2b 80 00       	push   $0x802b88
  8014ee:	e8 9c ed ff ff       	call   80028f <cprintf>
	*dev = 0;
  8014f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014fc:	83 c4 10             	add    $0x10,%esp
  8014ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801504:	c9                   	leave  
  801505:	c3                   	ret    

00801506 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801506:	55                   	push   %ebp
  801507:	89 e5                	mov    %esp,%ebp
  801509:	56                   	push   %esi
  80150a:	53                   	push   %ebx
  80150b:	83 ec 10             	sub    $0x10,%esp
  80150e:	8b 75 08             	mov    0x8(%ebp),%esi
  801511:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801514:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801517:	50                   	push   %eax
  801518:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80151e:	c1 e8 0c             	shr    $0xc,%eax
  801521:	50                   	push   %eax
  801522:	e8 33 ff ff ff       	call   80145a <fd_lookup>
  801527:	83 c4 08             	add    $0x8,%esp
  80152a:	85 c0                	test   %eax,%eax
  80152c:	78 05                	js     801533 <fd_close+0x2d>
	    || fd != fd2)
  80152e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801531:	74 0c                	je     80153f <fd_close+0x39>
		return (must_exist ? r : 0);
  801533:	84 db                	test   %bl,%bl
  801535:	ba 00 00 00 00       	mov    $0x0,%edx
  80153a:	0f 44 c2             	cmove  %edx,%eax
  80153d:	eb 41                	jmp    801580 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80153f:	83 ec 08             	sub    $0x8,%esp
  801542:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801545:	50                   	push   %eax
  801546:	ff 36                	pushl  (%esi)
  801548:	e8 63 ff ff ff       	call   8014b0 <dev_lookup>
  80154d:	89 c3                	mov    %eax,%ebx
  80154f:	83 c4 10             	add    $0x10,%esp
  801552:	85 c0                	test   %eax,%eax
  801554:	78 1a                	js     801570 <fd_close+0x6a>
		if (dev->dev_close)
  801556:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801559:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80155c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801561:	85 c0                	test   %eax,%eax
  801563:	74 0b                	je     801570 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801565:	83 ec 0c             	sub    $0xc,%esp
  801568:	56                   	push   %esi
  801569:	ff d0                	call   *%eax
  80156b:	89 c3                	mov    %eax,%ebx
  80156d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801570:	83 ec 08             	sub    $0x8,%esp
  801573:	56                   	push   %esi
  801574:	6a 00                	push   $0x0
  801576:	e8 21 f7 ff ff       	call   800c9c <sys_page_unmap>
	return r;
  80157b:	83 c4 10             	add    $0x10,%esp
  80157e:	89 d8                	mov    %ebx,%eax
}
  801580:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801583:	5b                   	pop    %ebx
  801584:	5e                   	pop    %esi
  801585:	5d                   	pop    %ebp
  801586:	c3                   	ret    

00801587 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801587:	55                   	push   %ebp
  801588:	89 e5                	mov    %esp,%ebp
  80158a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80158d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801590:	50                   	push   %eax
  801591:	ff 75 08             	pushl  0x8(%ebp)
  801594:	e8 c1 fe ff ff       	call   80145a <fd_lookup>
  801599:	83 c4 08             	add    $0x8,%esp
  80159c:	85 c0                	test   %eax,%eax
  80159e:	78 10                	js     8015b0 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8015a0:	83 ec 08             	sub    $0x8,%esp
  8015a3:	6a 01                	push   $0x1
  8015a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8015a8:	e8 59 ff ff ff       	call   801506 <fd_close>
  8015ad:	83 c4 10             	add    $0x10,%esp
}
  8015b0:	c9                   	leave  
  8015b1:	c3                   	ret    

008015b2 <close_all>:

void
close_all(void)
{
  8015b2:	55                   	push   %ebp
  8015b3:	89 e5                	mov    %esp,%ebp
  8015b5:	53                   	push   %ebx
  8015b6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015b9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015be:	83 ec 0c             	sub    $0xc,%esp
  8015c1:	53                   	push   %ebx
  8015c2:	e8 c0 ff ff ff       	call   801587 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015c7:	83 c3 01             	add    $0x1,%ebx
  8015ca:	83 c4 10             	add    $0x10,%esp
  8015cd:	83 fb 20             	cmp    $0x20,%ebx
  8015d0:	75 ec                	jne    8015be <close_all+0xc>
		close(i);
}
  8015d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d5:	c9                   	leave  
  8015d6:	c3                   	ret    

008015d7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015d7:	55                   	push   %ebp
  8015d8:	89 e5                	mov    %esp,%ebp
  8015da:	57                   	push   %edi
  8015db:	56                   	push   %esi
  8015dc:	53                   	push   %ebx
  8015dd:	83 ec 2c             	sub    $0x2c,%esp
  8015e0:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015e3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015e6:	50                   	push   %eax
  8015e7:	ff 75 08             	pushl  0x8(%ebp)
  8015ea:	e8 6b fe ff ff       	call   80145a <fd_lookup>
  8015ef:	83 c4 08             	add    $0x8,%esp
  8015f2:	85 c0                	test   %eax,%eax
  8015f4:	0f 88 c1 00 00 00    	js     8016bb <dup+0xe4>
		return r;
	close(newfdnum);
  8015fa:	83 ec 0c             	sub    $0xc,%esp
  8015fd:	56                   	push   %esi
  8015fe:	e8 84 ff ff ff       	call   801587 <close>

	newfd = INDEX2FD(newfdnum);
  801603:	89 f3                	mov    %esi,%ebx
  801605:	c1 e3 0c             	shl    $0xc,%ebx
  801608:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80160e:	83 c4 04             	add    $0x4,%esp
  801611:	ff 75 e4             	pushl  -0x1c(%ebp)
  801614:	e8 db fd ff ff       	call   8013f4 <fd2data>
  801619:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80161b:	89 1c 24             	mov    %ebx,(%esp)
  80161e:	e8 d1 fd ff ff       	call   8013f4 <fd2data>
  801623:	83 c4 10             	add    $0x10,%esp
  801626:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801629:	89 f8                	mov    %edi,%eax
  80162b:	c1 e8 16             	shr    $0x16,%eax
  80162e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801635:	a8 01                	test   $0x1,%al
  801637:	74 37                	je     801670 <dup+0x99>
  801639:	89 f8                	mov    %edi,%eax
  80163b:	c1 e8 0c             	shr    $0xc,%eax
  80163e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801645:	f6 c2 01             	test   $0x1,%dl
  801648:	74 26                	je     801670 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80164a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801651:	83 ec 0c             	sub    $0xc,%esp
  801654:	25 07 0e 00 00       	and    $0xe07,%eax
  801659:	50                   	push   %eax
  80165a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80165d:	6a 00                	push   $0x0
  80165f:	57                   	push   %edi
  801660:	6a 00                	push   $0x0
  801662:	e8 f3 f5 ff ff       	call   800c5a <sys_page_map>
  801667:	89 c7                	mov    %eax,%edi
  801669:	83 c4 20             	add    $0x20,%esp
  80166c:	85 c0                	test   %eax,%eax
  80166e:	78 2e                	js     80169e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801670:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801673:	89 d0                	mov    %edx,%eax
  801675:	c1 e8 0c             	shr    $0xc,%eax
  801678:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80167f:	83 ec 0c             	sub    $0xc,%esp
  801682:	25 07 0e 00 00       	and    $0xe07,%eax
  801687:	50                   	push   %eax
  801688:	53                   	push   %ebx
  801689:	6a 00                	push   $0x0
  80168b:	52                   	push   %edx
  80168c:	6a 00                	push   $0x0
  80168e:	e8 c7 f5 ff ff       	call   800c5a <sys_page_map>
  801693:	89 c7                	mov    %eax,%edi
  801695:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801698:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80169a:	85 ff                	test   %edi,%edi
  80169c:	79 1d                	jns    8016bb <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80169e:	83 ec 08             	sub    $0x8,%esp
  8016a1:	53                   	push   %ebx
  8016a2:	6a 00                	push   $0x0
  8016a4:	e8 f3 f5 ff ff       	call   800c9c <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016a9:	83 c4 08             	add    $0x8,%esp
  8016ac:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016af:	6a 00                	push   $0x0
  8016b1:	e8 e6 f5 ff ff       	call   800c9c <sys_page_unmap>
	return r;
  8016b6:	83 c4 10             	add    $0x10,%esp
  8016b9:	89 f8                	mov    %edi,%eax
}
  8016bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016be:	5b                   	pop    %ebx
  8016bf:	5e                   	pop    %esi
  8016c0:	5f                   	pop    %edi
  8016c1:	5d                   	pop    %ebp
  8016c2:	c3                   	ret    

008016c3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	53                   	push   %ebx
  8016c7:	83 ec 14             	sub    $0x14,%esp
  8016ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d0:	50                   	push   %eax
  8016d1:	53                   	push   %ebx
  8016d2:	e8 83 fd ff ff       	call   80145a <fd_lookup>
  8016d7:	83 c4 08             	add    $0x8,%esp
  8016da:	89 c2                	mov    %eax,%edx
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	78 70                	js     801750 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e0:	83 ec 08             	sub    $0x8,%esp
  8016e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e6:	50                   	push   %eax
  8016e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ea:	ff 30                	pushl  (%eax)
  8016ec:	e8 bf fd ff ff       	call   8014b0 <dev_lookup>
  8016f1:	83 c4 10             	add    $0x10,%esp
  8016f4:	85 c0                	test   %eax,%eax
  8016f6:	78 4f                	js     801747 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016fb:	8b 42 08             	mov    0x8(%edx),%eax
  8016fe:	83 e0 03             	and    $0x3,%eax
  801701:	83 f8 01             	cmp    $0x1,%eax
  801704:	75 24                	jne    80172a <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801706:	a1 20 60 80 00       	mov    0x806020,%eax
  80170b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801711:	83 ec 04             	sub    $0x4,%esp
  801714:	53                   	push   %ebx
  801715:	50                   	push   %eax
  801716:	68 cc 2b 80 00       	push   $0x802bcc
  80171b:	e8 6f eb ff ff       	call   80028f <cprintf>
		return -E_INVAL;
  801720:	83 c4 10             	add    $0x10,%esp
  801723:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801728:	eb 26                	jmp    801750 <read+0x8d>
	}
	if (!dev->dev_read)
  80172a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80172d:	8b 40 08             	mov    0x8(%eax),%eax
  801730:	85 c0                	test   %eax,%eax
  801732:	74 17                	je     80174b <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801734:	83 ec 04             	sub    $0x4,%esp
  801737:	ff 75 10             	pushl  0x10(%ebp)
  80173a:	ff 75 0c             	pushl  0xc(%ebp)
  80173d:	52                   	push   %edx
  80173e:	ff d0                	call   *%eax
  801740:	89 c2                	mov    %eax,%edx
  801742:	83 c4 10             	add    $0x10,%esp
  801745:	eb 09                	jmp    801750 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801747:	89 c2                	mov    %eax,%edx
  801749:	eb 05                	jmp    801750 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80174b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801750:	89 d0                	mov    %edx,%eax
  801752:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801755:	c9                   	leave  
  801756:	c3                   	ret    

00801757 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801757:	55                   	push   %ebp
  801758:	89 e5                	mov    %esp,%ebp
  80175a:	57                   	push   %edi
  80175b:	56                   	push   %esi
  80175c:	53                   	push   %ebx
  80175d:	83 ec 0c             	sub    $0xc,%esp
  801760:	8b 7d 08             	mov    0x8(%ebp),%edi
  801763:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801766:	bb 00 00 00 00       	mov    $0x0,%ebx
  80176b:	eb 21                	jmp    80178e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80176d:	83 ec 04             	sub    $0x4,%esp
  801770:	89 f0                	mov    %esi,%eax
  801772:	29 d8                	sub    %ebx,%eax
  801774:	50                   	push   %eax
  801775:	89 d8                	mov    %ebx,%eax
  801777:	03 45 0c             	add    0xc(%ebp),%eax
  80177a:	50                   	push   %eax
  80177b:	57                   	push   %edi
  80177c:	e8 42 ff ff ff       	call   8016c3 <read>
		if (m < 0)
  801781:	83 c4 10             	add    $0x10,%esp
  801784:	85 c0                	test   %eax,%eax
  801786:	78 10                	js     801798 <readn+0x41>
			return m;
		if (m == 0)
  801788:	85 c0                	test   %eax,%eax
  80178a:	74 0a                	je     801796 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80178c:	01 c3                	add    %eax,%ebx
  80178e:	39 f3                	cmp    %esi,%ebx
  801790:	72 db                	jb     80176d <readn+0x16>
  801792:	89 d8                	mov    %ebx,%eax
  801794:	eb 02                	jmp    801798 <readn+0x41>
  801796:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801798:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80179b:	5b                   	pop    %ebx
  80179c:	5e                   	pop    %esi
  80179d:	5f                   	pop    %edi
  80179e:	5d                   	pop    %ebp
  80179f:	c3                   	ret    

008017a0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	53                   	push   %ebx
  8017a4:	83 ec 14             	sub    $0x14,%esp
  8017a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017ad:	50                   	push   %eax
  8017ae:	53                   	push   %ebx
  8017af:	e8 a6 fc ff ff       	call   80145a <fd_lookup>
  8017b4:	83 c4 08             	add    $0x8,%esp
  8017b7:	89 c2                	mov    %eax,%edx
  8017b9:	85 c0                	test   %eax,%eax
  8017bb:	78 6b                	js     801828 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017bd:	83 ec 08             	sub    $0x8,%esp
  8017c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c3:	50                   	push   %eax
  8017c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c7:	ff 30                	pushl  (%eax)
  8017c9:	e8 e2 fc ff ff       	call   8014b0 <dev_lookup>
  8017ce:	83 c4 10             	add    $0x10,%esp
  8017d1:	85 c0                	test   %eax,%eax
  8017d3:	78 4a                	js     80181f <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017dc:	75 24                	jne    801802 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017de:	a1 20 60 80 00       	mov    0x806020,%eax
  8017e3:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8017e9:	83 ec 04             	sub    $0x4,%esp
  8017ec:	53                   	push   %ebx
  8017ed:	50                   	push   %eax
  8017ee:	68 e8 2b 80 00       	push   $0x802be8
  8017f3:	e8 97 ea ff ff       	call   80028f <cprintf>
		return -E_INVAL;
  8017f8:	83 c4 10             	add    $0x10,%esp
  8017fb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801800:	eb 26                	jmp    801828 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801802:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801805:	8b 52 0c             	mov    0xc(%edx),%edx
  801808:	85 d2                	test   %edx,%edx
  80180a:	74 17                	je     801823 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80180c:	83 ec 04             	sub    $0x4,%esp
  80180f:	ff 75 10             	pushl  0x10(%ebp)
  801812:	ff 75 0c             	pushl  0xc(%ebp)
  801815:	50                   	push   %eax
  801816:	ff d2                	call   *%edx
  801818:	89 c2                	mov    %eax,%edx
  80181a:	83 c4 10             	add    $0x10,%esp
  80181d:	eb 09                	jmp    801828 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80181f:	89 c2                	mov    %eax,%edx
  801821:	eb 05                	jmp    801828 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801823:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801828:	89 d0                	mov    %edx,%eax
  80182a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80182d:	c9                   	leave  
  80182e:	c3                   	ret    

0080182f <seek>:

int
seek(int fdnum, off_t offset)
{
  80182f:	55                   	push   %ebp
  801830:	89 e5                	mov    %esp,%ebp
  801832:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801835:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801838:	50                   	push   %eax
  801839:	ff 75 08             	pushl  0x8(%ebp)
  80183c:	e8 19 fc ff ff       	call   80145a <fd_lookup>
  801841:	83 c4 08             	add    $0x8,%esp
  801844:	85 c0                	test   %eax,%eax
  801846:	78 0e                	js     801856 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801848:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80184b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80184e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801851:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801856:	c9                   	leave  
  801857:	c3                   	ret    

00801858 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801858:	55                   	push   %ebp
  801859:	89 e5                	mov    %esp,%ebp
  80185b:	53                   	push   %ebx
  80185c:	83 ec 14             	sub    $0x14,%esp
  80185f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801862:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801865:	50                   	push   %eax
  801866:	53                   	push   %ebx
  801867:	e8 ee fb ff ff       	call   80145a <fd_lookup>
  80186c:	83 c4 08             	add    $0x8,%esp
  80186f:	89 c2                	mov    %eax,%edx
  801871:	85 c0                	test   %eax,%eax
  801873:	78 68                	js     8018dd <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801875:	83 ec 08             	sub    $0x8,%esp
  801878:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80187b:	50                   	push   %eax
  80187c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80187f:	ff 30                	pushl  (%eax)
  801881:	e8 2a fc ff ff       	call   8014b0 <dev_lookup>
  801886:	83 c4 10             	add    $0x10,%esp
  801889:	85 c0                	test   %eax,%eax
  80188b:	78 47                	js     8018d4 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80188d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801890:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801894:	75 24                	jne    8018ba <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801896:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80189b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8018a1:	83 ec 04             	sub    $0x4,%esp
  8018a4:	53                   	push   %ebx
  8018a5:	50                   	push   %eax
  8018a6:	68 a8 2b 80 00       	push   $0x802ba8
  8018ab:	e8 df e9 ff ff       	call   80028f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018b0:	83 c4 10             	add    $0x10,%esp
  8018b3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018b8:	eb 23                	jmp    8018dd <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  8018ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018bd:	8b 52 18             	mov    0x18(%edx),%edx
  8018c0:	85 d2                	test   %edx,%edx
  8018c2:	74 14                	je     8018d8 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018c4:	83 ec 08             	sub    $0x8,%esp
  8018c7:	ff 75 0c             	pushl  0xc(%ebp)
  8018ca:	50                   	push   %eax
  8018cb:	ff d2                	call   *%edx
  8018cd:	89 c2                	mov    %eax,%edx
  8018cf:	83 c4 10             	add    $0x10,%esp
  8018d2:	eb 09                	jmp    8018dd <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018d4:	89 c2                	mov    %eax,%edx
  8018d6:	eb 05                	jmp    8018dd <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018d8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8018dd:	89 d0                	mov    %edx,%eax
  8018df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e2:	c9                   	leave  
  8018e3:	c3                   	ret    

008018e4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018e4:	55                   	push   %ebp
  8018e5:	89 e5                	mov    %esp,%ebp
  8018e7:	53                   	push   %ebx
  8018e8:	83 ec 14             	sub    $0x14,%esp
  8018eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018f1:	50                   	push   %eax
  8018f2:	ff 75 08             	pushl  0x8(%ebp)
  8018f5:	e8 60 fb ff ff       	call   80145a <fd_lookup>
  8018fa:	83 c4 08             	add    $0x8,%esp
  8018fd:	89 c2                	mov    %eax,%edx
  8018ff:	85 c0                	test   %eax,%eax
  801901:	78 58                	js     80195b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801903:	83 ec 08             	sub    $0x8,%esp
  801906:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801909:	50                   	push   %eax
  80190a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80190d:	ff 30                	pushl  (%eax)
  80190f:	e8 9c fb ff ff       	call   8014b0 <dev_lookup>
  801914:	83 c4 10             	add    $0x10,%esp
  801917:	85 c0                	test   %eax,%eax
  801919:	78 37                	js     801952 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80191b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80191e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801922:	74 32                	je     801956 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801924:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801927:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80192e:	00 00 00 
	stat->st_isdir = 0;
  801931:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801938:	00 00 00 
	stat->st_dev = dev;
  80193b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801941:	83 ec 08             	sub    $0x8,%esp
  801944:	53                   	push   %ebx
  801945:	ff 75 f0             	pushl  -0x10(%ebp)
  801948:	ff 50 14             	call   *0x14(%eax)
  80194b:	89 c2                	mov    %eax,%edx
  80194d:	83 c4 10             	add    $0x10,%esp
  801950:	eb 09                	jmp    80195b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801952:	89 c2                	mov    %eax,%edx
  801954:	eb 05                	jmp    80195b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801956:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80195b:	89 d0                	mov    %edx,%eax
  80195d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801960:	c9                   	leave  
  801961:	c3                   	ret    

00801962 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	56                   	push   %esi
  801966:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801967:	83 ec 08             	sub    $0x8,%esp
  80196a:	6a 00                	push   $0x0
  80196c:	ff 75 08             	pushl  0x8(%ebp)
  80196f:	e8 e3 01 00 00       	call   801b57 <open>
  801974:	89 c3                	mov    %eax,%ebx
  801976:	83 c4 10             	add    $0x10,%esp
  801979:	85 c0                	test   %eax,%eax
  80197b:	78 1b                	js     801998 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80197d:	83 ec 08             	sub    $0x8,%esp
  801980:	ff 75 0c             	pushl  0xc(%ebp)
  801983:	50                   	push   %eax
  801984:	e8 5b ff ff ff       	call   8018e4 <fstat>
  801989:	89 c6                	mov    %eax,%esi
	close(fd);
  80198b:	89 1c 24             	mov    %ebx,(%esp)
  80198e:	e8 f4 fb ff ff       	call   801587 <close>
	return r;
  801993:	83 c4 10             	add    $0x10,%esp
  801996:	89 f0                	mov    %esi,%eax
}
  801998:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80199b:	5b                   	pop    %ebx
  80199c:	5e                   	pop    %esi
  80199d:	5d                   	pop    %ebp
  80199e:	c3                   	ret    

0080199f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80199f:	55                   	push   %ebp
  8019a0:	89 e5                	mov    %esp,%ebp
  8019a2:	56                   	push   %esi
  8019a3:	53                   	push   %ebx
  8019a4:	89 c6                	mov    %eax,%esi
  8019a6:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019a8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8019af:	75 12                	jne    8019c3 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019b1:	83 ec 0c             	sub    $0xc,%esp
  8019b4:	6a 01                	push   $0x1
  8019b6:	e8 a4 09 00 00       	call   80235f <ipc_find_env>
  8019bb:	a3 00 40 80 00       	mov    %eax,0x804000
  8019c0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019c3:	6a 07                	push   $0x7
  8019c5:	68 00 70 80 00       	push   $0x807000
  8019ca:	56                   	push   %esi
  8019cb:	ff 35 00 40 80 00    	pushl  0x804000
  8019d1:	e8 27 09 00 00       	call   8022fd <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019d6:	83 c4 0c             	add    $0xc,%esp
  8019d9:	6a 00                	push   $0x0
  8019db:	53                   	push   %ebx
  8019dc:	6a 00                	push   $0x0
  8019de:	e8 9f 08 00 00       	call   802282 <ipc_recv>
}
  8019e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019e6:	5b                   	pop    %ebx
  8019e7:	5e                   	pop    %esi
  8019e8:	5d                   	pop    %ebp
  8019e9:	c3                   	ret    

008019ea <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019ea:	55                   	push   %ebp
  8019eb:	89 e5                	mov    %esp,%ebp
  8019ed:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f3:	8b 40 0c             	mov    0xc(%eax),%eax
  8019f6:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  8019fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019fe:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a03:	ba 00 00 00 00       	mov    $0x0,%edx
  801a08:	b8 02 00 00 00       	mov    $0x2,%eax
  801a0d:	e8 8d ff ff ff       	call   80199f <fsipc>
}
  801a12:	c9                   	leave  
  801a13:	c3                   	ret    

00801a14 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a14:	55                   	push   %ebp
  801a15:	89 e5                	mov    %esp,%ebp
  801a17:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a20:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  801a25:	ba 00 00 00 00       	mov    $0x0,%edx
  801a2a:	b8 06 00 00 00       	mov    $0x6,%eax
  801a2f:	e8 6b ff ff ff       	call   80199f <fsipc>
}
  801a34:	c9                   	leave  
  801a35:	c3                   	ret    

00801a36 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a36:	55                   	push   %ebp
  801a37:	89 e5                	mov    %esp,%ebp
  801a39:	53                   	push   %ebx
  801a3a:	83 ec 04             	sub    $0x4,%esp
  801a3d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a40:	8b 45 08             	mov    0x8(%ebp),%eax
  801a43:	8b 40 0c             	mov    0xc(%eax),%eax
  801a46:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a4b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a50:	b8 05 00 00 00       	mov    $0x5,%eax
  801a55:	e8 45 ff ff ff       	call   80199f <fsipc>
  801a5a:	85 c0                	test   %eax,%eax
  801a5c:	78 2c                	js     801a8a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a5e:	83 ec 08             	sub    $0x8,%esp
  801a61:	68 00 70 80 00       	push   $0x807000
  801a66:	53                   	push   %ebx
  801a67:	e8 a8 ed ff ff       	call   800814 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a6c:	a1 80 70 80 00       	mov    0x807080,%eax
  801a71:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a77:	a1 84 70 80 00       	mov    0x807084,%eax
  801a7c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a82:	83 c4 10             	add    $0x10,%esp
  801a85:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a8d:	c9                   	leave  
  801a8e:	c3                   	ret    

00801a8f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a8f:	55                   	push   %ebp
  801a90:	89 e5                	mov    %esp,%ebp
  801a92:	83 ec 0c             	sub    $0xc,%esp
  801a95:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a98:	8b 55 08             	mov    0x8(%ebp),%edx
  801a9b:	8b 52 0c             	mov    0xc(%edx),%edx
  801a9e:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801aa4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801aa9:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801aae:	0f 47 c2             	cmova  %edx,%eax
  801ab1:	a3 04 70 80 00       	mov    %eax,0x807004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801ab6:	50                   	push   %eax
  801ab7:	ff 75 0c             	pushl  0xc(%ebp)
  801aba:	68 08 70 80 00       	push   $0x807008
  801abf:	e8 e2 ee ff ff       	call   8009a6 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801ac4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac9:	b8 04 00 00 00       	mov    $0x4,%eax
  801ace:	e8 cc fe ff ff       	call   80199f <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801ad3:	c9                   	leave  
  801ad4:	c3                   	ret    

00801ad5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801ad5:	55                   	push   %ebp
  801ad6:	89 e5                	mov    %esp,%ebp
  801ad8:	56                   	push   %esi
  801ad9:	53                   	push   %ebx
  801ada:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801add:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae0:	8b 40 0c             	mov    0xc(%eax),%eax
  801ae3:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801ae8:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801aee:	ba 00 00 00 00       	mov    $0x0,%edx
  801af3:	b8 03 00 00 00       	mov    $0x3,%eax
  801af8:	e8 a2 fe ff ff       	call   80199f <fsipc>
  801afd:	89 c3                	mov    %eax,%ebx
  801aff:	85 c0                	test   %eax,%eax
  801b01:	78 4b                	js     801b4e <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b03:	39 c6                	cmp    %eax,%esi
  801b05:	73 16                	jae    801b1d <devfile_read+0x48>
  801b07:	68 18 2c 80 00       	push   $0x802c18
  801b0c:	68 1f 2c 80 00       	push   $0x802c1f
  801b11:	6a 7c                	push   $0x7c
  801b13:	68 34 2c 80 00       	push   $0x802c34
  801b18:	e8 99 e6 ff ff       	call   8001b6 <_panic>
	assert(r <= PGSIZE);
  801b1d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b22:	7e 16                	jle    801b3a <devfile_read+0x65>
  801b24:	68 3f 2c 80 00       	push   $0x802c3f
  801b29:	68 1f 2c 80 00       	push   $0x802c1f
  801b2e:	6a 7d                	push   $0x7d
  801b30:	68 34 2c 80 00       	push   $0x802c34
  801b35:	e8 7c e6 ff ff       	call   8001b6 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b3a:	83 ec 04             	sub    $0x4,%esp
  801b3d:	50                   	push   %eax
  801b3e:	68 00 70 80 00       	push   $0x807000
  801b43:	ff 75 0c             	pushl  0xc(%ebp)
  801b46:	e8 5b ee ff ff       	call   8009a6 <memmove>
	return r;
  801b4b:	83 c4 10             	add    $0x10,%esp
}
  801b4e:	89 d8                	mov    %ebx,%eax
  801b50:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b53:	5b                   	pop    %ebx
  801b54:	5e                   	pop    %esi
  801b55:	5d                   	pop    %ebp
  801b56:	c3                   	ret    

00801b57 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b57:	55                   	push   %ebp
  801b58:	89 e5                	mov    %esp,%ebp
  801b5a:	53                   	push   %ebx
  801b5b:	83 ec 20             	sub    $0x20,%esp
  801b5e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b61:	53                   	push   %ebx
  801b62:	e8 74 ec ff ff       	call   8007db <strlen>
  801b67:	83 c4 10             	add    $0x10,%esp
  801b6a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b6f:	7f 67                	jg     801bd8 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b71:	83 ec 0c             	sub    $0xc,%esp
  801b74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b77:	50                   	push   %eax
  801b78:	e8 8e f8 ff ff       	call   80140b <fd_alloc>
  801b7d:	83 c4 10             	add    $0x10,%esp
		return r;
  801b80:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b82:	85 c0                	test   %eax,%eax
  801b84:	78 57                	js     801bdd <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b86:	83 ec 08             	sub    $0x8,%esp
  801b89:	53                   	push   %ebx
  801b8a:	68 00 70 80 00       	push   $0x807000
  801b8f:	e8 80 ec ff ff       	call   800814 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b94:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b97:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b9f:	b8 01 00 00 00       	mov    $0x1,%eax
  801ba4:	e8 f6 fd ff ff       	call   80199f <fsipc>
  801ba9:	89 c3                	mov    %eax,%ebx
  801bab:	83 c4 10             	add    $0x10,%esp
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	79 14                	jns    801bc6 <open+0x6f>
		fd_close(fd, 0);
  801bb2:	83 ec 08             	sub    $0x8,%esp
  801bb5:	6a 00                	push   $0x0
  801bb7:	ff 75 f4             	pushl  -0xc(%ebp)
  801bba:	e8 47 f9 ff ff       	call   801506 <fd_close>
		return r;
  801bbf:	83 c4 10             	add    $0x10,%esp
  801bc2:	89 da                	mov    %ebx,%edx
  801bc4:	eb 17                	jmp    801bdd <open+0x86>
	}

	return fd2num(fd);
  801bc6:	83 ec 0c             	sub    $0xc,%esp
  801bc9:	ff 75 f4             	pushl  -0xc(%ebp)
  801bcc:	e8 13 f8 ff ff       	call   8013e4 <fd2num>
  801bd1:	89 c2                	mov    %eax,%edx
  801bd3:	83 c4 10             	add    $0x10,%esp
  801bd6:	eb 05                	jmp    801bdd <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801bd8:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801bdd:	89 d0                	mov    %edx,%eax
  801bdf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be2:	c9                   	leave  
  801be3:	c3                   	ret    

00801be4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801be4:	55                   	push   %ebp
  801be5:	89 e5                	mov    %esp,%ebp
  801be7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bea:	ba 00 00 00 00       	mov    $0x0,%edx
  801bef:	b8 08 00 00 00       	mov    $0x8,%eax
  801bf4:	e8 a6 fd ff ff       	call   80199f <fsipc>
}
  801bf9:	c9                   	leave  
  801bfa:	c3                   	ret    

00801bfb <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801bfb:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801bff:	7e 37                	jle    801c38 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801c01:	55                   	push   %ebp
  801c02:	89 e5                	mov    %esp,%ebp
  801c04:	53                   	push   %ebx
  801c05:	83 ec 08             	sub    $0x8,%esp
  801c08:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801c0a:	ff 70 04             	pushl  0x4(%eax)
  801c0d:	8d 40 10             	lea    0x10(%eax),%eax
  801c10:	50                   	push   %eax
  801c11:	ff 33                	pushl  (%ebx)
  801c13:	e8 88 fb ff ff       	call   8017a0 <write>
		if (result > 0)
  801c18:	83 c4 10             	add    $0x10,%esp
  801c1b:	85 c0                	test   %eax,%eax
  801c1d:	7e 03                	jle    801c22 <writebuf+0x27>
			b->result += result;
  801c1f:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801c22:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c25:	74 0d                	je     801c34 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801c27:	85 c0                	test   %eax,%eax
  801c29:	ba 00 00 00 00       	mov    $0x0,%edx
  801c2e:	0f 4f c2             	cmovg  %edx,%eax
  801c31:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801c34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c37:	c9                   	leave  
  801c38:	f3 c3                	repz ret 

00801c3a <putch>:

static void
putch(int ch, void *thunk)
{
  801c3a:	55                   	push   %ebp
  801c3b:	89 e5                	mov    %esp,%ebp
  801c3d:	53                   	push   %ebx
  801c3e:	83 ec 04             	sub    $0x4,%esp
  801c41:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801c44:	8b 53 04             	mov    0x4(%ebx),%edx
  801c47:	8d 42 01             	lea    0x1(%edx),%eax
  801c4a:	89 43 04             	mov    %eax,0x4(%ebx)
  801c4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c50:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801c54:	3d 00 01 00 00       	cmp    $0x100,%eax
  801c59:	75 0e                	jne    801c69 <putch+0x2f>
		writebuf(b);
  801c5b:	89 d8                	mov    %ebx,%eax
  801c5d:	e8 99 ff ff ff       	call   801bfb <writebuf>
		b->idx = 0;
  801c62:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801c69:	83 c4 04             	add    $0x4,%esp
  801c6c:	5b                   	pop    %ebx
  801c6d:	5d                   	pop    %ebp
  801c6e:	c3                   	ret    

00801c6f <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801c6f:	55                   	push   %ebp
  801c70:	89 e5                	mov    %esp,%ebp
  801c72:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801c78:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7b:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801c81:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801c88:	00 00 00 
	b.result = 0;
  801c8b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801c92:	00 00 00 
	b.error = 1;
  801c95:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801c9c:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801c9f:	ff 75 10             	pushl  0x10(%ebp)
  801ca2:	ff 75 0c             	pushl  0xc(%ebp)
  801ca5:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801cab:	50                   	push   %eax
  801cac:	68 3a 1c 80 00       	push   $0x801c3a
  801cb1:	e8 10 e7 ff ff       	call   8003c6 <vprintfmt>
	if (b.idx > 0)
  801cb6:	83 c4 10             	add    $0x10,%esp
  801cb9:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801cc0:	7e 0b                	jle    801ccd <vfprintf+0x5e>
		writebuf(&b);
  801cc2:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801cc8:	e8 2e ff ff ff       	call   801bfb <writebuf>

	return (b.result ? b.result : b.error);
  801ccd:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801cd3:	85 c0                	test   %eax,%eax
  801cd5:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801cdc:	c9                   	leave  
  801cdd:	c3                   	ret    

00801cde <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801cde:	55                   	push   %ebp
  801cdf:	89 e5                	mov    %esp,%ebp
  801ce1:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801ce4:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801ce7:	50                   	push   %eax
  801ce8:	ff 75 0c             	pushl  0xc(%ebp)
  801ceb:	ff 75 08             	pushl  0x8(%ebp)
  801cee:	e8 7c ff ff ff       	call   801c6f <vfprintf>
	va_end(ap);

	return cnt;
}
  801cf3:	c9                   	leave  
  801cf4:	c3                   	ret    

00801cf5 <printf>:

int
printf(const char *fmt, ...)
{
  801cf5:	55                   	push   %ebp
  801cf6:	89 e5                	mov    %esp,%ebp
  801cf8:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801cfb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801cfe:	50                   	push   %eax
  801cff:	ff 75 08             	pushl  0x8(%ebp)
  801d02:	6a 01                	push   $0x1
  801d04:	e8 66 ff ff ff       	call   801c6f <vfprintf>
	va_end(ap);

	return cnt;
}
  801d09:	c9                   	leave  
  801d0a:	c3                   	ret    

00801d0b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d0b:	55                   	push   %ebp
  801d0c:	89 e5                	mov    %esp,%ebp
  801d0e:	56                   	push   %esi
  801d0f:	53                   	push   %ebx
  801d10:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d13:	83 ec 0c             	sub    $0xc,%esp
  801d16:	ff 75 08             	pushl  0x8(%ebp)
  801d19:	e8 d6 f6 ff ff       	call   8013f4 <fd2data>
  801d1e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d20:	83 c4 08             	add    $0x8,%esp
  801d23:	68 4b 2c 80 00       	push   $0x802c4b
  801d28:	53                   	push   %ebx
  801d29:	e8 e6 ea ff ff       	call   800814 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d2e:	8b 46 04             	mov    0x4(%esi),%eax
  801d31:	2b 06                	sub    (%esi),%eax
  801d33:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d39:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d40:	00 00 00 
	stat->st_dev = &devpipe;
  801d43:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801d4a:	30 80 00 
	return 0;
}
  801d4d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d55:	5b                   	pop    %ebx
  801d56:	5e                   	pop    %esi
  801d57:	5d                   	pop    %ebp
  801d58:	c3                   	ret    

00801d59 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d59:	55                   	push   %ebp
  801d5a:	89 e5                	mov    %esp,%ebp
  801d5c:	53                   	push   %ebx
  801d5d:	83 ec 0c             	sub    $0xc,%esp
  801d60:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d63:	53                   	push   %ebx
  801d64:	6a 00                	push   $0x0
  801d66:	e8 31 ef ff ff       	call   800c9c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d6b:	89 1c 24             	mov    %ebx,(%esp)
  801d6e:	e8 81 f6 ff ff       	call   8013f4 <fd2data>
  801d73:	83 c4 08             	add    $0x8,%esp
  801d76:	50                   	push   %eax
  801d77:	6a 00                	push   $0x0
  801d79:	e8 1e ef ff ff       	call   800c9c <sys_page_unmap>
}
  801d7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d81:	c9                   	leave  
  801d82:	c3                   	ret    

00801d83 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d83:	55                   	push   %ebp
  801d84:	89 e5                	mov    %esp,%ebp
  801d86:	57                   	push   %edi
  801d87:	56                   	push   %esi
  801d88:	53                   	push   %ebx
  801d89:	83 ec 1c             	sub    $0x1c,%esp
  801d8c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d8f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d91:	a1 20 60 80 00       	mov    0x806020,%eax
  801d96:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d9c:	83 ec 0c             	sub    $0xc,%esp
  801d9f:	ff 75 e0             	pushl  -0x20(%ebp)
  801da2:	e8 fd 05 00 00       	call   8023a4 <pageref>
  801da7:	89 c3                	mov    %eax,%ebx
  801da9:	89 3c 24             	mov    %edi,(%esp)
  801dac:	e8 f3 05 00 00       	call   8023a4 <pageref>
  801db1:	83 c4 10             	add    $0x10,%esp
  801db4:	39 c3                	cmp    %eax,%ebx
  801db6:	0f 94 c1             	sete   %cl
  801db9:	0f b6 c9             	movzbl %cl,%ecx
  801dbc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801dbf:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801dc5:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801dcb:	39 ce                	cmp    %ecx,%esi
  801dcd:	74 1e                	je     801ded <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801dcf:	39 c3                	cmp    %eax,%ebx
  801dd1:	75 be                	jne    801d91 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801dd3:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801dd9:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ddc:	50                   	push   %eax
  801ddd:	56                   	push   %esi
  801dde:	68 52 2c 80 00       	push   $0x802c52
  801de3:	e8 a7 e4 ff ff       	call   80028f <cprintf>
  801de8:	83 c4 10             	add    $0x10,%esp
  801deb:	eb a4                	jmp    801d91 <_pipeisclosed+0xe>
	}
}
  801ded:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801df0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801df3:	5b                   	pop    %ebx
  801df4:	5e                   	pop    %esi
  801df5:	5f                   	pop    %edi
  801df6:	5d                   	pop    %ebp
  801df7:	c3                   	ret    

00801df8 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801df8:	55                   	push   %ebp
  801df9:	89 e5                	mov    %esp,%ebp
  801dfb:	57                   	push   %edi
  801dfc:	56                   	push   %esi
  801dfd:	53                   	push   %ebx
  801dfe:	83 ec 28             	sub    $0x28,%esp
  801e01:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e04:	56                   	push   %esi
  801e05:	e8 ea f5 ff ff       	call   8013f4 <fd2data>
  801e0a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e0c:	83 c4 10             	add    $0x10,%esp
  801e0f:	bf 00 00 00 00       	mov    $0x0,%edi
  801e14:	eb 4b                	jmp    801e61 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e16:	89 da                	mov    %ebx,%edx
  801e18:	89 f0                	mov    %esi,%eax
  801e1a:	e8 64 ff ff ff       	call   801d83 <_pipeisclosed>
  801e1f:	85 c0                	test   %eax,%eax
  801e21:	75 48                	jne    801e6b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e23:	e8 d0 ed ff ff       	call   800bf8 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e28:	8b 43 04             	mov    0x4(%ebx),%eax
  801e2b:	8b 0b                	mov    (%ebx),%ecx
  801e2d:	8d 51 20             	lea    0x20(%ecx),%edx
  801e30:	39 d0                	cmp    %edx,%eax
  801e32:	73 e2                	jae    801e16 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e37:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e3b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e3e:	89 c2                	mov    %eax,%edx
  801e40:	c1 fa 1f             	sar    $0x1f,%edx
  801e43:	89 d1                	mov    %edx,%ecx
  801e45:	c1 e9 1b             	shr    $0x1b,%ecx
  801e48:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e4b:	83 e2 1f             	and    $0x1f,%edx
  801e4e:	29 ca                	sub    %ecx,%edx
  801e50:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e54:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e58:	83 c0 01             	add    $0x1,%eax
  801e5b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e5e:	83 c7 01             	add    $0x1,%edi
  801e61:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e64:	75 c2                	jne    801e28 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e66:	8b 45 10             	mov    0x10(%ebp),%eax
  801e69:	eb 05                	jmp    801e70 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e6b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e73:	5b                   	pop    %ebx
  801e74:	5e                   	pop    %esi
  801e75:	5f                   	pop    %edi
  801e76:	5d                   	pop    %ebp
  801e77:	c3                   	ret    

00801e78 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e78:	55                   	push   %ebp
  801e79:	89 e5                	mov    %esp,%ebp
  801e7b:	57                   	push   %edi
  801e7c:	56                   	push   %esi
  801e7d:	53                   	push   %ebx
  801e7e:	83 ec 18             	sub    $0x18,%esp
  801e81:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e84:	57                   	push   %edi
  801e85:	e8 6a f5 ff ff       	call   8013f4 <fd2data>
  801e8a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e8c:	83 c4 10             	add    $0x10,%esp
  801e8f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e94:	eb 3d                	jmp    801ed3 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e96:	85 db                	test   %ebx,%ebx
  801e98:	74 04                	je     801e9e <devpipe_read+0x26>
				return i;
  801e9a:	89 d8                	mov    %ebx,%eax
  801e9c:	eb 44                	jmp    801ee2 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e9e:	89 f2                	mov    %esi,%edx
  801ea0:	89 f8                	mov    %edi,%eax
  801ea2:	e8 dc fe ff ff       	call   801d83 <_pipeisclosed>
  801ea7:	85 c0                	test   %eax,%eax
  801ea9:	75 32                	jne    801edd <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801eab:	e8 48 ed ff ff       	call   800bf8 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801eb0:	8b 06                	mov    (%esi),%eax
  801eb2:	3b 46 04             	cmp    0x4(%esi),%eax
  801eb5:	74 df                	je     801e96 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801eb7:	99                   	cltd   
  801eb8:	c1 ea 1b             	shr    $0x1b,%edx
  801ebb:	01 d0                	add    %edx,%eax
  801ebd:	83 e0 1f             	and    $0x1f,%eax
  801ec0:	29 d0                	sub    %edx,%eax
  801ec2:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ec7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801eca:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ecd:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ed0:	83 c3 01             	add    $0x1,%ebx
  801ed3:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ed6:	75 d8                	jne    801eb0 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ed8:	8b 45 10             	mov    0x10(%ebp),%eax
  801edb:	eb 05                	jmp    801ee2 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801edd:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ee2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ee5:	5b                   	pop    %ebx
  801ee6:	5e                   	pop    %esi
  801ee7:	5f                   	pop    %edi
  801ee8:	5d                   	pop    %ebp
  801ee9:	c3                   	ret    

00801eea <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801eea:	55                   	push   %ebp
  801eeb:	89 e5                	mov    %esp,%ebp
  801eed:	56                   	push   %esi
  801eee:	53                   	push   %ebx
  801eef:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ef2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ef5:	50                   	push   %eax
  801ef6:	e8 10 f5 ff ff       	call   80140b <fd_alloc>
  801efb:	83 c4 10             	add    $0x10,%esp
  801efe:	89 c2                	mov    %eax,%edx
  801f00:	85 c0                	test   %eax,%eax
  801f02:	0f 88 2c 01 00 00    	js     802034 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f08:	83 ec 04             	sub    $0x4,%esp
  801f0b:	68 07 04 00 00       	push   $0x407
  801f10:	ff 75 f4             	pushl  -0xc(%ebp)
  801f13:	6a 00                	push   $0x0
  801f15:	e8 fd ec ff ff       	call   800c17 <sys_page_alloc>
  801f1a:	83 c4 10             	add    $0x10,%esp
  801f1d:	89 c2                	mov    %eax,%edx
  801f1f:	85 c0                	test   %eax,%eax
  801f21:	0f 88 0d 01 00 00    	js     802034 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f27:	83 ec 0c             	sub    $0xc,%esp
  801f2a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f2d:	50                   	push   %eax
  801f2e:	e8 d8 f4 ff ff       	call   80140b <fd_alloc>
  801f33:	89 c3                	mov    %eax,%ebx
  801f35:	83 c4 10             	add    $0x10,%esp
  801f38:	85 c0                	test   %eax,%eax
  801f3a:	0f 88 e2 00 00 00    	js     802022 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f40:	83 ec 04             	sub    $0x4,%esp
  801f43:	68 07 04 00 00       	push   $0x407
  801f48:	ff 75 f0             	pushl  -0x10(%ebp)
  801f4b:	6a 00                	push   $0x0
  801f4d:	e8 c5 ec ff ff       	call   800c17 <sys_page_alloc>
  801f52:	89 c3                	mov    %eax,%ebx
  801f54:	83 c4 10             	add    $0x10,%esp
  801f57:	85 c0                	test   %eax,%eax
  801f59:	0f 88 c3 00 00 00    	js     802022 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f5f:	83 ec 0c             	sub    $0xc,%esp
  801f62:	ff 75 f4             	pushl  -0xc(%ebp)
  801f65:	e8 8a f4 ff ff       	call   8013f4 <fd2data>
  801f6a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f6c:	83 c4 0c             	add    $0xc,%esp
  801f6f:	68 07 04 00 00       	push   $0x407
  801f74:	50                   	push   %eax
  801f75:	6a 00                	push   $0x0
  801f77:	e8 9b ec ff ff       	call   800c17 <sys_page_alloc>
  801f7c:	89 c3                	mov    %eax,%ebx
  801f7e:	83 c4 10             	add    $0x10,%esp
  801f81:	85 c0                	test   %eax,%eax
  801f83:	0f 88 89 00 00 00    	js     802012 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f89:	83 ec 0c             	sub    $0xc,%esp
  801f8c:	ff 75 f0             	pushl  -0x10(%ebp)
  801f8f:	e8 60 f4 ff ff       	call   8013f4 <fd2data>
  801f94:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f9b:	50                   	push   %eax
  801f9c:	6a 00                	push   $0x0
  801f9e:	56                   	push   %esi
  801f9f:	6a 00                	push   $0x0
  801fa1:	e8 b4 ec ff ff       	call   800c5a <sys_page_map>
  801fa6:	89 c3                	mov    %eax,%ebx
  801fa8:	83 c4 20             	add    $0x20,%esp
  801fab:	85 c0                	test   %eax,%eax
  801fad:	78 55                	js     802004 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801faf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fbd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801fc4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801fca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fcd:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801fcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fd2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801fd9:	83 ec 0c             	sub    $0xc,%esp
  801fdc:	ff 75 f4             	pushl  -0xc(%ebp)
  801fdf:	e8 00 f4 ff ff       	call   8013e4 <fd2num>
  801fe4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fe7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801fe9:	83 c4 04             	add    $0x4,%esp
  801fec:	ff 75 f0             	pushl  -0x10(%ebp)
  801fef:	e8 f0 f3 ff ff       	call   8013e4 <fd2num>
  801ff4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ff7:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801ffa:	83 c4 10             	add    $0x10,%esp
  801ffd:	ba 00 00 00 00       	mov    $0x0,%edx
  802002:	eb 30                	jmp    802034 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802004:	83 ec 08             	sub    $0x8,%esp
  802007:	56                   	push   %esi
  802008:	6a 00                	push   $0x0
  80200a:	e8 8d ec ff ff       	call   800c9c <sys_page_unmap>
  80200f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802012:	83 ec 08             	sub    $0x8,%esp
  802015:	ff 75 f0             	pushl  -0x10(%ebp)
  802018:	6a 00                	push   $0x0
  80201a:	e8 7d ec ff ff       	call   800c9c <sys_page_unmap>
  80201f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802022:	83 ec 08             	sub    $0x8,%esp
  802025:	ff 75 f4             	pushl  -0xc(%ebp)
  802028:	6a 00                	push   $0x0
  80202a:	e8 6d ec ff ff       	call   800c9c <sys_page_unmap>
  80202f:	83 c4 10             	add    $0x10,%esp
  802032:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802034:	89 d0                	mov    %edx,%eax
  802036:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802039:	5b                   	pop    %ebx
  80203a:	5e                   	pop    %esi
  80203b:	5d                   	pop    %ebp
  80203c:	c3                   	ret    

0080203d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80203d:	55                   	push   %ebp
  80203e:	89 e5                	mov    %esp,%ebp
  802040:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802043:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802046:	50                   	push   %eax
  802047:	ff 75 08             	pushl  0x8(%ebp)
  80204a:	e8 0b f4 ff ff       	call   80145a <fd_lookup>
  80204f:	83 c4 10             	add    $0x10,%esp
  802052:	85 c0                	test   %eax,%eax
  802054:	78 18                	js     80206e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802056:	83 ec 0c             	sub    $0xc,%esp
  802059:	ff 75 f4             	pushl  -0xc(%ebp)
  80205c:	e8 93 f3 ff ff       	call   8013f4 <fd2data>
	return _pipeisclosed(fd, p);
  802061:	89 c2                	mov    %eax,%edx
  802063:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802066:	e8 18 fd ff ff       	call   801d83 <_pipeisclosed>
  80206b:	83 c4 10             	add    $0x10,%esp
}
  80206e:	c9                   	leave  
  80206f:	c3                   	ret    

00802070 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802073:	b8 00 00 00 00       	mov    $0x0,%eax
  802078:	5d                   	pop    %ebp
  802079:	c3                   	ret    

0080207a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80207a:	55                   	push   %ebp
  80207b:	89 e5                	mov    %esp,%ebp
  80207d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802080:	68 6a 2c 80 00       	push   $0x802c6a
  802085:	ff 75 0c             	pushl  0xc(%ebp)
  802088:	e8 87 e7 ff ff       	call   800814 <strcpy>
	return 0;
}
  80208d:	b8 00 00 00 00       	mov    $0x0,%eax
  802092:	c9                   	leave  
  802093:	c3                   	ret    

00802094 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802094:	55                   	push   %ebp
  802095:	89 e5                	mov    %esp,%ebp
  802097:	57                   	push   %edi
  802098:	56                   	push   %esi
  802099:	53                   	push   %ebx
  80209a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020a0:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020a5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020ab:	eb 2d                	jmp    8020da <devcons_write+0x46>
		m = n - tot;
  8020ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8020b0:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8020b2:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8020b5:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8020ba:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020bd:	83 ec 04             	sub    $0x4,%esp
  8020c0:	53                   	push   %ebx
  8020c1:	03 45 0c             	add    0xc(%ebp),%eax
  8020c4:	50                   	push   %eax
  8020c5:	57                   	push   %edi
  8020c6:	e8 db e8 ff ff       	call   8009a6 <memmove>
		sys_cputs(buf, m);
  8020cb:	83 c4 08             	add    $0x8,%esp
  8020ce:	53                   	push   %ebx
  8020cf:	57                   	push   %edi
  8020d0:	e8 86 ea ff ff       	call   800b5b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020d5:	01 de                	add    %ebx,%esi
  8020d7:	83 c4 10             	add    $0x10,%esp
  8020da:	89 f0                	mov    %esi,%eax
  8020dc:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020df:	72 cc                	jb     8020ad <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8020e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020e4:	5b                   	pop    %ebx
  8020e5:	5e                   	pop    %esi
  8020e6:	5f                   	pop    %edi
  8020e7:	5d                   	pop    %ebp
  8020e8:	c3                   	ret    

008020e9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020e9:	55                   	push   %ebp
  8020ea:	89 e5                	mov    %esp,%ebp
  8020ec:	83 ec 08             	sub    $0x8,%esp
  8020ef:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8020f4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020f8:	74 2a                	je     802124 <devcons_read+0x3b>
  8020fa:	eb 05                	jmp    802101 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8020fc:	e8 f7 ea ff ff       	call   800bf8 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802101:	e8 73 ea ff ff       	call   800b79 <sys_cgetc>
  802106:	85 c0                	test   %eax,%eax
  802108:	74 f2                	je     8020fc <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80210a:	85 c0                	test   %eax,%eax
  80210c:	78 16                	js     802124 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80210e:	83 f8 04             	cmp    $0x4,%eax
  802111:	74 0c                	je     80211f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802113:	8b 55 0c             	mov    0xc(%ebp),%edx
  802116:	88 02                	mov    %al,(%edx)
	return 1;
  802118:	b8 01 00 00 00       	mov    $0x1,%eax
  80211d:	eb 05                	jmp    802124 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80211f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802124:	c9                   	leave  
  802125:	c3                   	ret    

00802126 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802126:	55                   	push   %ebp
  802127:	89 e5                	mov    %esp,%ebp
  802129:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80212c:	8b 45 08             	mov    0x8(%ebp),%eax
  80212f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802132:	6a 01                	push   $0x1
  802134:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802137:	50                   	push   %eax
  802138:	e8 1e ea ff ff       	call   800b5b <sys_cputs>
}
  80213d:	83 c4 10             	add    $0x10,%esp
  802140:	c9                   	leave  
  802141:	c3                   	ret    

00802142 <getchar>:

int
getchar(void)
{
  802142:	55                   	push   %ebp
  802143:	89 e5                	mov    %esp,%ebp
  802145:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802148:	6a 01                	push   $0x1
  80214a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80214d:	50                   	push   %eax
  80214e:	6a 00                	push   $0x0
  802150:	e8 6e f5 ff ff       	call   8016c3 <read>
	if (r < 0)
  802155:	83 c4 10             	add    $0x10,%esp
  802158:	85 c0                	test   %eax,%eax
  80215a:	78 0f                	js     80216b <getchar+0x29>
		return r;
	if (r < 1)
  80215c:	85 c0                	test   %eax,%eax
  80215e:	7e 06                	jle    802166 <getchar+0x24>
		return -E_EOF;
	return c;
  802160:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802164:	eb 05                	jmp    80216b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802166:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80216b:	c9                   	leave  
  80216c:	c3                   	ret    

0080216d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80216d:	55                   	push   %ebp
  80216e:	89 e5                	mov    %esp,%ebp
  802170:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802173:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802176:	50                   	push   %eax
  802177:	ff 75 08             	pushl  0x8(%ebp)
  80217a:	e8 db f2 ff ff       	call   80145a <fd_lookup>
  80217f:	83 c4 10             	add    $0x10,%esp
  802182:	85 c0                	test   %eax,%eax
  802184:	78 11                	js     802197 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802186:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802189:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80218f:	39 10                	cmp    %edx,(%eax)
  802191:	0f 94 c0             	sete   %al
  802194:	0f b6 c0             	movzbl %al,%eax
}
  802197:	c9                   	leave  
  802198:	c3                   	ret    

00802199 <opencons>:

int
opencons(void)
{
  802199:	55                   	push   %ebp
  80219a:	89 e5                	mov    %esp,%ebp
  80219c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80219f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021a2:	50                   	push   %eax
  8021a3:	e8 63 f2 ff ff       	call   80140b <fd_alloc>
  8021a8:	83 c4 10             	add    $0x10,%esp
		return r;
  8021ab:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021ad:	85 c0                	test   %eax,%eax
  8021af:	78 3e                	js     8021ef <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021b1:	83 ec 04             	sub    $0x4,%esp
  8021b4:	68 07 04 00 00       	push   $0x407
  8021b9:	ff 75 f4             	pushl  -0xc(%ebp)
  8021bc:	6a 00                	push   $0x0
  8021be:	e8 54 ea ff ff       	call   800c17 <sys_page_alloc>
  8021c3:	83 c4 10             	add    $0x10,%esp
		return r;
  8021c6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021c8:	85 c0                	test   %eax,%eax
  8021ca:	78 23                	js     8021ef <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8021cc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021d5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021da:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021e1:	83 ec 0c             	sub    $0xc,%esp
  8021e4:	50                   	push   %eax
  8021e5:	e8 fa f1 ff ff       	call   8013e4 <fd2num>
  8021ea:	89 c2                	mov    %eax,%edx
  8021ec:	83 c4 10             	add    $0x10,%esp
}
  8021ef:	89 d0                	mov    %edx,%eax
  8021f1:	c9                   	leave  
  8021f2:	c3                   	ret    

008021f3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8021f3:	55                   	push   %ebp
  8021f4:	89 e5                	mov    %esp,%ebp
  8021f6:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8021f9:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802200:	75 2a                	jne    80222c <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802202:	83 ec 04             	sub    $0x4,%esp
  802205:	6a 07                	push   $0x7
  802207:	68 00 f0 bf ee       	push   $0xeebff000
  80220c:	6a 00                	push   $0x0
  80220e:	e8 04 ea ff ff       	call   800c17 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802213:	83 c4 10             	add    $0x10,%esp
  802216:	85 c0                	test   %eax,%eax
  802218:	79 12                	jns    80222c <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80221a:	50                   	push   %eax
  80221b:	68 d6 26 80 00       	push   $0x8026d6
  802220:	6a 23                	push   $0x23
  802222:	68 76 2c 80 00       	push   $0x802c76
  802227:	e8 8a df ff ff       	call   8001b6 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80222c:	8b 45 08             	mov    0x8(%ebp),%eax
  80222f:	a3 00 80 80 00       	mov    %eax,0x808000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802234:	83 ec 08             	sub    $0x8,%esp
  802237:	68 5e 22 80 00       	push   $0x80225e
  80223c:	6a 00                	push   $0x0
  80223e:	e8 1f eb ff ff       	call   800d62 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802243:	83 c4 10             	add    $0x10,%esp
  802246:	85 c0                	test   %eax,%eax
  802248:	79 12                	jns    80225c <set_pgfault_handler+0x69>
		panic("%e\n", r);
  80224a:	50                   	push   %eax
  80224b:	68 d6 26 80 00       	push   $0x8026d6
  802250:	6a 2c                	push   $0x2c
  802252:	68 76 2c 80 00       	push   $0x802c76
  802257:	e8 5a df ff ff       	call   8001b6 <_panic>
	}
}
  80225c:	c9                   	leave  
  80225d:	c3                   	ret    

0080225e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80225e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80225f:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802264:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802266:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802269:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  80226d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802272:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802276:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802278:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  80227b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  80227c:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80227f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802280:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802281:	c3                   	ret    

00802282 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802282:	55                   	push   %ebp
  802283:	89 e5                	mov    %esp,%ebp
  802285:	56                   	push   %esi
  802286:	53                   	push   %ebx
  802287:	8b 75 08             	mov    0x8(%ebp),%esi
  80228a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80228d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802290:	85 c0                	test   %eax,%eax
  802292:	75 12                	jne    8022a6 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802294:	83 ec 0c             	sub    $0xc,%esp
  802297:	68 00 00 c0 ee       	push   $0xeec00000
  80229c:	e8 26 eb ff ff       	call   800dc7 <sys_ipc_recv>
  8022a1:	83 c4 10             	add    $0x10,%esp
  8022a4:	eb 0c                	jmp    8022b2 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8022a6:	83 ec 0c             	sub    $0xc,%esp
  8022a9:	50                   	push   %eax
  8022aa:	e8 18 eb ff ff       	call   800dc7 <sys_ipc_recv>
  8022af:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8022b2:	85 f6                	test   %esi,%esi
  8022b4:	0f 95 c1             	setne  %cl
  8022b7:	85 db                	test   %ebx,%ebx
  8022b9:	0f 95 c2             	setne  %dl
  8022bc:	84 d1                	test   %dl,%cl
  8022be:	74 09                	je     8022c9 <ipc_recv+0x47>
  8022c0:	89 c2                	mov    %eax,%edx
  8022c2:	c1 ea 1f             	shr    $0x1f,%edx
  8022c5:	84 d2                	test   %dl,%dl
  8022c7:	75 2d                	jne    8022f6 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8022c9:	85 f6                	test   %esi,%esi
  8022cb:	74 0d                	je     8022da <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8022cd:	a1 20 60 80 00       	mov    0x806020,%eax
  8022d2:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8022d8:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8022da:	85 db                	test   %ebx,%ebx
  8022dc:	74 0d                	je     8022eb <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8022de:	a1 20 60 80 00       	mov    0x806020,%eax
  8022e3:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  8022e9:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8022eb:	a1 20 60 80 00       	mov    0x806020,%eax
  8022f0:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  8022f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022f9:	5b                   	pop    %ebx
  8022fa:	5e                   	pop    %esi
  8022fb:	5d                   	pop    %ebp
  8022fc:	c3                   	ret    

008022fd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022fd:	55                   	push   %ebp
  8022fe:	89 e5                	mov    %esp,%ebp
  802300:	57                   	push   %edi
  802301:	56                   	push   %esi
  802302:	53                   	push   %ebx
  802303:	83 ec 0c             	sub    $0xc,%esp
  802306:	8b 7d 08             	mov    0x8(%ebp),%edi
  802309:	8b 75 0c             	mov    0xc(%ebp),%esi
  80230c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80230f:	85 db                	test   %ebx,%ebx
  802311:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802316:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802319:	ff 75 14             	pushl  0x14(%ebp)
  80231c:	53                   	push   %ebx
  80231d:	56                   	push   %esi
  80231e:	57                   	push   %edi
  80231f:	e8 80 ea ff ff       	call   800da4 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802324:	89 c2                	mov    %eax,%edx
  802326:	c1 ea 1f             	shr    $0x1f,%edx
  802329:	83 c4 10             	add    $0x10,%esp
  80232c:	84 d2                	test   %dl,%dl
  80232e:	74 17                	je     802347 <ipc_send+0x4a>
  802330:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802333:	74 12                	je     802347 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802335:	50                   	push   %eax
  802336:	68 84 2c 80 00       	push   $0x802c84
  80233b:	6a 47                	push   $0x47
  80233d:	68 92 2c 80 00       	push   $0x802c92
  802342:	e8 6f de ff ff       	call   8001b6 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802347:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80234a:	75 07                	jne    802353 <ipc_send+0x56>
			sys_yield();
  80234c:	e8 a7 e8 ff ff       	call   800bf8 <sys_yield>
  802351:	eb c6                	jmp    802319 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802353:	85 c0                	test   %eax,%eax
  802355:	75 c2                	jne    802319 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802357:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80235a:	5b                   	pop    %ebx
  80235b:	5e                   	pop    %esi
  80235c:	5f                   	pop    %edi
  80235d:	5d                   	pop    %ebp
  80235e:	c3                   	ret    

0080235f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80235f:	55                   	push   %ebp
  802360:	89 e5                	mov    %esp,%ebp
  802362:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802365:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80236a:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  802370:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802376:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  80237c:	39 ca                	cmp    %ecx,%edx
  80237e:	75 13                	jne    802393 <ipc_find_env+0x34>
			return envs[i].env_id;
  802380:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  802386:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80238b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  802391:	eb 0f                	jmp    8023a2 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802393:	83 c0 01             	add    $0x1,%eax
  802396:	3d 00 04 00 00       	cmp    $0x400,%eax
  80239b:	75 cd                	jne    80236a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80239d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023a2:	5d                   	pop    %ebp
  8023a3:	c3                   	ret    

008023a4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023a4:	55                   	push   %ebp
  8023a5:	89 e5                	mov    %esp,%ebp
  8023a7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023aa:	89 d0                	mov    %edx,%eax
  8023ac:	c1 e8 16             	shr    $0x16,%eax
  8023af:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023b6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023bb:	f6 c1 01             	test   $0x1,%cl
  8023be:	74 1d                	je     8023dd <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023c0:	c1 ea 0c             	shr    $0xc,%edx
  8023c3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023ca:	f6 c2 01             	test   $0x1,%dl
  8023cd:	74 0e                	je     8023dd <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023cf:	c1 ea 0c             	shr    $0xc,%edx
  8023d2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8023d9:	ef 
  8023da:	0f b7 c0             	movzwl %ax,%eax
}
  8023dd:	5d                   	pop    %ebp
  8023de:	c3                   	ret    
  8023df:	90                   	nop

008023e0 <__udivdi3>:
  8023e0:	55                   	push   %ebp
  8023e1:	57                   	push   %edi
  8023e2:	56                   	push   %esi
  8023e3:	53                   	push   %ebx
  8023e4:	83 ec 1c             	sub    $0x1c,%esp
  8023e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8023eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8023ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8023f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023f7:	85 f6                	test   %esi,%esi
  8023f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023fd:	89 ca                	mov    %ecx,%edx
  8023ff:	89 f8                	mov    %edi,%eax
  802401:	75 3d                	jne    802440 <__udivdi3+0x60>
  802403:	39 cf                	cmp    %ecx,%edi
  802405:	0f 87 c5 00 00 00    	ja     8024d0 <__udivdi3+0xf0>
  80240b:	85 ff                	test   %edi,%edi
  80240d:	89 fd                	mov    %edi,%ebp
  80240f:	75 0b                	jne    80241c <__udivdi3+0x3c>
  802411:	b8 01 00 00 00       	mov    $0x1,%eax
  802416:	31 d2                	xor    %edx,%edx
  802418:	f7 f7                	div    %edi
  80241a:	89 c5                	mov    %eax,%ebp
  80241c:	89 c8                	mov    %ecx,%eax
  80241e:	31 d2                	xor    %edx,%edx
  802420:	f7 f5                	div    %ebp
  802422:	89 c1                	mov    %eax,%ecx
  802424:	89 d8                	mov    %ebx,%eax
  802426:	89 cf                	mov    %ecx,%edi
  802428:	f7 f5                	div    %ebp
  80242a:	89 c3                	mov    %eax,%ebx
  80242c:	89 d8                	mov    %ebx,%eax
  80242e:	89 fa                	mov    %edi,%edx
  802430:	83 c4 1c             	add    $0x1c,%esp
  802433:	5b                   	pop    %ebx
  802434:	5e                   	pop    %esi
  802435:	5f                   	pop    %edi
  802436:	5d                   	pop    %ebp
  802437:	c3                   	ret    
  802438:	90                   	nop
  802439:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802440:	39 ce                	cmp    %ecx,%esi
  802442:	77 74                	ja     8024b8 <__udivdi3+0xd8>
  802444:	0f bd fe             	bsr    %esi,%edi
  802447:	83 f7 1f             	xor    $0x1f,%edi
  80244a:	0f 84 98 00 00 00    	je     8024e8 <__udivdi3+0x108>
  802450:	bb 20 00 00 00       	mov    $0x20,%ebx
  802455:	89 f9                	mov    %edi,%ecx
  802457:	89 c5                	mov    %eax,%ebp
  802459:	29 fb                	sub    %edi,%ebx
  80245b:	d3 e6                	shl    %cl,%esi
  80245d:	89 d9                	mov    %ebx,%ecx
  80245f:	d3 ed                	shr    %cl,%ebp
  802461:	89 f9                	mov    %edi,%ecx
  802463:	d3 e0                	shl    %cl,%eax
  802465:	09 ee                	or     %ebp,%esi
  802467:	89 d9                	mov    %ebx,%ecx
  802469:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80246d:	89 d5                	mov    %edx,%ebp
  80246f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802473:	d3 ed                	shr    %cl,%ebp
  802475:	89 f9                	mov    %edi,%ecx
  802477:	d3 e2                	shl    %cl,%edx
  802479:	89 d9                	mov    %ebx,%ecx
  80247b:	d3 e8                	shr    %cl,%eax
  80247d:	09 c2                	or     %eax,%edx
  80247f:	89 d0                	mov    %edx,%eax
  802481:	89 ea                	mov    %ebp,%edx
  802483:	f7 f6                	div    %esi
  802485:	89 d5                	mov    %edx,%ebp
  802487:	89 c3                	mov    %eax,%ebx
  802489:	f7 64 24 0c          	mull   0xc(%esp)
  80248d:	39 d5                	cmp    %edx,%ebp
  80248f:	72 10                	jb     8024a1 <__udivdi3+0xc1>
  802491:	8b 74 24 08          	mov    0x8(%esp),%esi
  802495:	89 f9                	mov    %edi,%ecx
  802497:	d3 e6                	shl    %cl,%esi
  802499:	39 c6                	cmp    %eax,%esi
  80249b:	73 07                	jae    8024a4 <__udivdi3+0xc4>
  80249d:	39 d5                	cmp    %edx,%ebp
  80249f:	75 03                	jne    8024a4 <__udivdi3+0xc4>
  8024a1:	83 eb 01             	sub    $0x1,%ebx
  8024a4:	31 ff                	xor    %edi,%edi
  8024a6:	89 d8                	mov    %ebx,%eax
  8024a8:	89 fa                	mov    %edi,%edx
  8024aa:	83 c4 1c             	add    $0x1c,%esp
  8024ad:	5b                   	pop    %ebx
  8024ae:	5e                   	pop    %esi
  8024af:	5f                   	pop    %edi
  8024b0:	5d                   	pop    %ebp
  8024b1:	c3                   	ret    
  8024b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024b8:	31 ff                	xor    %edi,%edi
  8024ba:	31 db                	xor    %ebx,%ebx
  8024bc:	89 d8                	mov    %ebx,%eax
  8024be:	89 fa                	mov    %edi,%edx
  8024c0:	83 c4 1c             	add    $0x1c,%esp
  8024c3:	5b                   	pop    %ebx
  8024c4:	5e                   	pop    %esi
  8024c5:	5f                   	pop    %edi
  8024c6:	5d                   	pop    %ebp
  8024c7:	c3                   	ret    
  8024c8:	90                   	nop
  8024c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024d0:	89 d8                	mov    %ebx,%eax
  8024d2:	f7 f7                	div    %edi
  8024d4:	31 ff                	xor    %edi,%edi
  8024d6:	89 c3                	mov    %eax,%ebx
  8024d8:	89 d8                	mov    %ebx,%eax
  8024da:	89 fa                	mov    %edi,%edx
  8024dc:	83 c4 1c             	add    $0x1c,%esp
  8024df:	5b                   	pop    %ebx
  8024e0:	5e                   	pop    %esi
  8024e1:	5f                   	pop    %edi
  8024e2:	5d                   	pop    %ebp
  8024e3:	c3                   	ret    
  8024e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024e8:	39 ce                	cmp    %ecx,%esi
  8024ea:	72 0c                	jb     8024f8 <__udivdi3+0x118>
  8024ec:	31 db                	xor    %ebx,%ebx
  8024ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8024f2:	0f 87 34 ff ff ff    	ja     80242c <__udivdi3+0x4c>
  8024f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8024fd:	e9 2a ff ff ff       	jmp    80242c <__udivdi3+0x4c>
  802502:	66 90                	xchg   %ax,%ax
  802504:	66 90                	xchg   %ax,%ax
  802506:	66 90                	xchg   %ax,%ax
  802508:	66 90                	xchg   %ax,%ax
  80250a:	66 90                	xchg   %ax,%ax
  80250c:	66 90                	xchg   %ax,%ax
  80250e:	66 90                	xchg   %ax,%ax

00802510 <__umoddi3>:
  802510:	55                   	push   %ebp
  802511:	57                   	push   %edi
  802512:	56                   	push   %esi
  802513:	53                   	push   %ebx
  802514:	83 ec 1c             	sub    $0x1c,%esp
  802517:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80251b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80251f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802523:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802527:	85 d2                	test   %edx,%edx
  802529:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80252d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802531:	89 f3                	mov    %esi,%ebx
  802533:	89 3c 24             	mov    %edi,(%esp)
  802536:	89 74 24 04          	mov    %esi,0x4(%esp)
  80253a:	75 1c                	jne    802558 <__umoddi3+0x48>
  80253c:	39 f7                	cmp    %esi,%edi
  80253e:	76 50                	jbe    802590 <__umoddi3+0x80>
  802540:	89 c8                	mov    %ecx,%eax
  802542:	89 f2                	mov    %esi,%edx
  802544:	f7 f7                	div    %edi
  802546:	89 d0                	mov    %edx,%eax
  802548:	31 d2                	xor    %edx,%edx
  80254a:	83 c4 1c             	add    $0x1c,%esp
  80254d:	5b                   	pop    %ebx
  80254e:	5e                   	pop    %esi
  80254f:	5f                   	pop    %edi
  802550:	5d                   	pop    %ebp
  802551:	c3                   	ret    
  802552:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802558:	39 f2                	cmp    %esi,%edx
  80255a:	89 d0                	mov    %edx,%eax
  80255c:	77 52                	ja     8025b0 <__umoddi3+0xa0>
  80255e:	0f bd ea             	bsr    %edx,%ebp
  802561:	83 f5 1f             	xor    $0x1f,%ebp
  802564:	75 5a                	jne    8025c0 <__umoddi3+0xb0>
  802566:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80256a:	0f 82 e0 00 00 00    	jb     802650 <__umoddi3+0x140>
  802570:	39 0c 24             	cmp    %ecx,(%esp)
  802573:	0f 86 d7 00 00 00    	jbe    802650 <__umoddi3+0x140>
  802579:	8b 44 24 08          	mov    0x8(%esp),%eax
  80257d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802581:	83 c4 1c             	add    $0x1c,%esp
  802584:	5b                   	pop    %ebx
  802585:	5e                   	pop    %esi
  802586:	5f                   	pop    %edi
  802587:	5d                   	pop    %ebp
  802588:	c3                   	ret    
  802589:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802590:	85 ff                	test   %edi,%edi
  802592:	89 fd                	mov    %edi,%ebp
  802594:	75 0b                	jne    8025a1 <__umoddi3+0x91>
  802596:	b8 01 00 00 00       	mov    $0x1,%eax
  80259b:	31 d2                	xor    %edx,%edx
  80259d:	f7 f7                	div    %edi
  80259f:	89 c5                	mov    %eax,%ebp
  8025a1:	89 f0                	mov    %esi,%eax
  8025a3:	31 d2                	xor    %edx,%edx
  8025a5:	f7 f5                	div    %ebp
  8025a7:	89 c8                	mov    %ecx,%eax
  8025a9:	f7 f5                	div    %ebp
  8025ab:	89 d0                	mov    %edx,%eax
  8025ad:	eb 99                	jmp    802548 <__umoddi3+0x38>
  8025af:	90                   	nop
  8025b0:	89 c8                	mov    %ecx,%eax
  8025b2:	89 f2                	mov    %esi,%edx
  8025b4:	83 c4 1c             	add    $0x1c,%esp
  8025b7:	5b                   	pop    %ebx
  8025b8:	5e                   	pop    %esi
  8025b9:	5f                   	pop    %edi
  8025ba:	5d                   	pop    %ebp
  8025bb:	c3                   	ret    
  8025bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025c0:	8b 34 24             	mov    (%esp),%esi
  8025c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8025c8:	89 e9                	mov    %ebp,%ecx
  8025ca:	29 ef                	sub    %ebp,%edi
  8025cc:	d3 e0                	shl    %cl,%eax
  8025ce:	89 f9                	mov    %edi,%ecx
  8025d0:	89 f2                	mov    %esi,%edx
  8025d2:	d3 ea                	shr    %cl,%edx
  8025d4:	89 e9                	mov    %ebp,%ecx
  8025d6:	09 c2                	or     %eax,%edx
  8025d8:	89 d8                	mov    %ebx,%eax
  8025da:	89 14 24             	mov    %edx,(%esp)
  8025dd:	89 f2                	mov    %esi,%edx
  8025df:	d3 e2                	shl    %cl,%edx
  8025e1:	89 f9                	mov    %edi,%ecx
  8025e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8025eb:	d3 e8                	shr    %cl,%eax
  8025ed:	89 e9                	mov    %ebp,%ecx
  8025ef:	89 c6                	mov    %eax,%esi
  8025f1:	d3 e3                	shl    %cl,%ebx
  8025f3:	89 f9                	mov    %edi,%ecx
  8025f5:	89 d0                	mov    %edx,%eax
  8025f7:	d3 e8                	shr    %cl,%eax
  8025f9:	89 e9                	mov    %ebp,%ecx
  8025fb:	09 d8                	or     %ebx,%eax
  8025fd:	89 d3                	mov    %edx,%ebx
  8025ff:	89 f2                	mov    %esi,%edx
  802601:	f7 34 24             	divl   (%esp)
  802604:	89 d6                	mov    %edx,%esi
  802606:	d3 e3                	shl    %cl,%ebx
  802608:	f7 64 24 04          	mull   0x4(%esp)
  80260c:	39 d6                	cmp    %edx,%esi
  80260e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802612:	89 d1                	mov    %edx,%ecx
  802614:	89 c3                	mov    %eax,%ebx
  802616:	72 08                	jb     802620 <__umoddi3+0x110>
  802618:	75 11                	jne    80262b <__umoddi3+0x11b>
  80261a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80261e:	73 0b                	jae    80262b <__umoddi3+0x11b>
  802620:	2b 44 24 04          	sub    0x4(%esp),%eax
  802624:	1b 14 24             	sbb    (%esp),%edx
  802627:	89 d1                	mov    %edx,%ecx
  802629:	89 c3                	mov    %eax,%ebx
  80262b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80262f:	29 da                	sub    %ebx,%edx
  802631:	19 ce                	sbb    %ecx,%esi
  802633:	89 f9                	mov    %edi,%ecx
  802635:	89 f0                	mov    %esi,%eax
  802637:	d3 e0                	shl    %cl,%eax
  802639:	89 e9                	mov    %ebp,%ecx
  80263b:	d3 ea                	shr    %cl,%edx
  80263d:	89 e9                	mov    %ebp,%ecx
  80263f:	d3 ee                	shr    %cl,%esi
  802641:	09 d0                	or     %edx,%eax
  802643:	89 f2                	mov    %esi,%edx
  802645:	83 c4 1c             	add    $0x1c,%esp
  802648:	5b                   	pop    %ebx
  802649:	5e                   	pop    %esi
  80264a:	5f                   	pop    %edi
  80264b:	5d                   	pop    %ebp
  80264c:	c3                   	ret    
  80264d:	8d 76 00             	lea    0x0(%esi),%esi
  802650:	29 f9                	sub    %edi,%ecx
  802652:	19 d6                	sbb    %edx,%esi
  802654:	89 74 24 04          	mov    %esi,0x4(%esp)
  802658:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80265c:	e9 18 ff ff ff       	jmp    802579 <__umoddi3+0x69>
