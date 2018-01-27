
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
  800048:	e8 a5 14 00 00       	call   8014f2 <write>
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
  80007a:	e8 99 13 00 00       	call   801418 <read>
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
  8000e8:	e8 b6 17 00 00       	call   8018a3 <open>
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
  800102:	e8 3a 19 00 00       	call   801a41 <printf>
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
  80011b:	e8 bc 11 00 00       	call   8012dc <close>
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
  800148:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
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
  8001a2:	e8 60 11 00 00       	call   801307 <close_all>
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
  8001d4:	68 24 24 80 00       	push   $0x802424
  8001d9:	e8 b1 00 00 00       	call   80028f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001de:	83 c4 18             	add    $0x18,%esp
  8001e1:	53                   	push   %ebx
  8001e2:	ff 75 10             	pushl  0x10(%ebp)
  8001e5:	e8 54 00 00 00       	call   80023e <vcprintf>
	cprintf("\n");
  8001ea:	c7 04 24 c3 28 80 00 	movl   $0x8028c3,(%esp)
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
  8002f2:	e8 39 1e 00 00       	call   802130 <__udivdi3>
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
  800335:	e8 26 1f 00 00       	call   802260 <__umoddi3>
  80033a:	83 c4 14             	add    $0x14,%esp
  80033d:	0f be 80 47 24 80 00 	movsbl 0x802447(%eax),%eax
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
  800439:	ff 24 85 80 25 80 00 	jmp    *0x802580(,%eax,4)
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
  8004fd:	8b 14 85 e0 26 80 00 	mov    0x8026e0(,%eax,4),%edx
  800504:	85 d2                	test   %edx,%edx
  800506:	75 18                	jne    800520 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800508:	50                   	push   %eax
  800509:	68 5f 24 80 00       	push   $0x80245f
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
  800521:	68 91 28 80 00       	push   $0x802891
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
  800545:	b8 58 24 80 00       	mov    $0x802458,%eax
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
  800bc0:	68 3f 27 80 00       	push   $0x80273f
  800bc5:	6a 23                	push   $0x23
  800bc7:	68 5c 27 80 00       	push   $0x80275c
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
  800c41:	68 3f 27 80 00       	push   $0x80273f
  800c46:	6a 23                	push   $0x23
  800c48:	68 5c 27 80 00       	push   $0x80275c
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
  800c83:	68 3f 27 80 00       	push   $0x80273f
  800c88:	6a 23                	push   $0x23
  800c8a:	68 5c 27 80 00       	push   $0x80275c
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
  800cc5:	68 3f 27 80 00       	push   $0x80273f
  800cca:	6a 23                	push   $0x23
  800ccc:	68 5c 27 80 00       	push   $0x80275c
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
  800d07:	68 3f 27 80 00       	push   $0x80273f
  800d0c:	6a 23                	push   $0x23
  800d0e:	68 5c 27 80 00       	push   $0x80275c
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
  800d49:	68 3f 27 80 00       	push   $0x80273f
  800d4e:	6a 23                	push   $0x23
  800d50:	68 5c 27 80 00       	push   $0x80275c
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
  800d8b:	68 3f 27 80 00       	push   $0x80273f
  800d90:	6a 23                	push   $0x23
  800d92:	68 5c 27 80 00       	push   $0x80275c
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
  800def:	68 3f 27 80 00       	push   $0x80273f
  800df4:	6a 23                	push   $0x23
  800df6:	68 5c 27 80 00       	push   $0x80275c
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

00800e48 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	53                   	push   %ebx
  800e4c:	83 ec 04             	sub    $0x4,%esp
  800e4f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e52:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800e54:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e58:	74 11                	je     800e6b <pgfault+0x23>
  800e5a:	89 d8                	mov    %ebx,%eax
  800e5c:	c1 e8 0c             	shr    $0xc,%eax
  800e5f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e66:	f6 c4 08             	test   $0x8,%ah
  800e69:	75 14                	jne    800e7f <pgfault+0x37>
		panic("faulting access");
  800e6b:	83 ec 04             	sub    $0x4,%esp
  800e6e:	68 6a 27 80 00       	push   $0x80276a
  800e73:	6a 1e                	push   $0x1e
  800e75:	68 7a 27 80 00       	push   $0x80277a
  800e7a:	e8 37 f3 ff ff       	call   8001b6 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e7f:	83 ec 04             	sub    $0x4,%esp
  800e82:	6a 07                	push   $0x7
  800e84:	68 00 f0 7f 00       	push   $0x7ff000
  800e89:	6a 00                	push   $0x0
  800e8b:	e8 87 fd ff ff       	call   800c17 <sys_page_alloc>
	if (r < 0) {
  800e90:	83 c4 10             	add    $0x10,%esp
  800e93:	85 c0                	test   %eax,%eax
  800e95:	79 12                	jns    800ea9 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e97:	50                   	push   %eax
  800e98:	68 85 27 80 00       	push   $0x802785
  800e9d:	6a 2c                	push   $0x2c
  800e9f:	68 7a 27 80 00       	push   $0x80277a
  800ea4:	e8 0d f3 ff ff       	call   8001b6 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800ea9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800eaf:	83 ec 04             	sub    $0x4,%esp
  800eb2:	68 00 10 00 00       	push   $0x1000
  800eb7:	53                   	push   %ebx
  800eb8:	68 00 f0 7f 00       	push   $0x7ff000
  800ebd:	e8 4c fb ff ff       	call   800a0e <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800ec2:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ec9:	53                   	push   %ebx
  800eca:	6a 00                	push   $0x0
  800ecc:	68 00 f0 7f 00       	push   $0x7ff000
  800ed1:	6a 00                	push   $0x0
  800ed3:	e8 82 fd ff ff       	call   800c5a <sys_page_map>
	if (r < 0) {
  800ed8:	83 c4 20             	add    $0x20,%esp
  800edb:	85 c0                	test   %eax,%eax
  800edd:	79 12                	jns    800ef1 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800edf:	50                   	push   %eax
  800ee0:	68 85 27 80 00       	push   $0x802785
  800ee5:	6a 33                	push   $0x33
  800ee7:	68 7a 27 80 00       	push   $0x80277a
  800eec:	e8 c5 f2 ff ff       	call   8001b6 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800ef1:	83 ec 08             	sub    $0x8,%esp
  800ef4:	68 00 f0 7f 00       	push   $0x7ff000
  800ef9:	6a 00                	push   $0x0
  800efb:	e8 9c fd ff ff       	call   800c9c <sys_page_unmap>
	if (r < 0) {
  800f00:	83 c4 10             	add    $0x10,%esp
  800f03:	85 c0                	test   %eax,%eax
  800f05:	79 12                	jns    800f19 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800f07:	50                   	push   %eax
  800f08:	68 85 27 80 00       	push   $0x802785
  800f0d:	6a 37                	push   $0x37
  800f0f:	68 7a 27 80 00       	push   $0x80277a
  800f14:	e8 9d f2 ff ff       	call   8001b6 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800f19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f1c:	c9                   	leave  
  800f1d:	c3                   	ret    

00800f1e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	57                   	push   %edi
  800f22:	56                   	push   %esi
  800f23:	53                   	push   %ebx
  800f24:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800f27:	68 48 0e 80 00       	push   $0x800e48
  800f2c:	e8 0e 10 00 00       	call   801f3f <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f31:	b8 07 00 00 00       	mov    $0x7,%eax
  800f36:	cd 30                	int    $0x30
  800f38:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800f3b:	83 c4 10             	add    $0x10,%esp
  800f3e:	85 c0                	test   %eax,%eax
  800f40:	79 17                	jns    800f59 <fork+0x3b>
		panic("fork fault %e");
  800f42:	83 ec 04             	sub    $0x4,%esp
  800f45:	68 9e 27 80 00       	push   $0x80279e
  800f4a:	68 84 00 00 00       	push   $0x84
  800f4f:	68 7a 27 80 00       	push   $0x80277a
  800f54:	e8 5d f2 ff ff       	call   8001b6 <_panic>
  800f59:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f5b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f5f:	75 24                	jne    800f85 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f61:	e8 73 fc ff ff       	call   800bd9 <sys_getenvid>
  800f66:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f6b:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800f71:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f76:	a3 20 60 80 00       	mov    %eax,0x806020
		return 0;
  800f7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f80:	e9 64 01 00 00       	jmp    8010e9 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f85:	83 ec 04             	sub    $0x4,%esp
  800f88:	6a 07                	push   $0x7
  800f8a:	68 00 f0 bf ee       	push   $0xeebff000
  800f8f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f92:	e8 80 fc ff ff       	call   800c17 <sys_page_alloc>
  800f97:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f9a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f9f:	89 d8                	mov    %ebx,%eax
  800fa1:	c1 e8 16             	shr    $0x16,%eax
  800fa4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fab:	a8 01                	test   $0x1,%al
  800fad:	0f 84 fc 00 00 00    	je     8010af <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800fb3:	89 d8                	mov    %ebx,%eax
  800fb5:	c1 e8 0c             	shr    $0xc,%eax
  800fb8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fbf:	f6 c2 01             	test   $0x1,%dl
  800fc2:	0f 84 e7 00 00 00    	je     8010af <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800fc8:	89 c6                	mov    %eax,%esi
  800fca:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800fcd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fd4:	f6 c6 04             	test   $0x4,%dh
  800fd7:	74 39                	je     801012 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800fd9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fe0:	83 ec 0c             	sub    $0xc,%esp
  800fe3:	25 07 0e 00 00       	and    $0xe07,%eax
  800fe8:	50                   	push   %eax
  800fe9:	56                   	push   %esi
  800fea:	57                   	push   %edi
  800feb:	56                   	push   %esi
  800fec:	6a 00                	push   $0x0
  800fee:	e8 67 fc ff ff       	call   800c5a <sys_page_map>
		if (r < 0) {
  800ff3:	83 c4 20             	add    $0x20,%esp
  800ff6:	85 c0                	test   %eax,%eax
  800ff8:	0f 89 b1 00 00 00    	jns    8010af <fork+0x191>
		    	panic("sys page map fault %e");
  800ffe:	83 ec 04             	sub    $0x4,%esp
  801001:	68 ac 27 80 00       	push   $0x8027ac
  801006:	6a 54                	push   $0x54
  801008:	68 7a 27 80 00       	push   $0x80277a
  80100d:	e8 a4 f1 ff ff       	call   8001b6 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801012:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801019:	f6 c2 02             	test   $0x2,%dl
  80101c:	75 0c                	jne    80102a <fork+0x10c>
  80101e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801025:	f6 c4 08             	test   $0x8,%ah
  801028:	74 5b                	je     801085 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80102a:	83 ec 0c             	sub    $0xc,%esp
  80102d:	68 05 08 00 00       	push   $0x805
  801032:	56                   	push   %esi
  801033:	57                   	push   %edi
  801034:	56                   	push   %esi
  801035:	6a 00                	push   $0x0
  801037:	e8 1e fc ff ff       	call   800c5a <sys_page_map>
		if (r < 0) {
  80103c:	83 c4 20             	add    $0x20,%esp
  80103f:	85 c0                	test   %eax,%eax
  801041:	79 14                	jns    801057 <fork+0x139>
		    	panic("sys page map fault %e");
  801043:	83 ec 04             	sub    $0x4,%esp
  801046:	68 ac 27 80 00       	push   $0x8027ac
  80104b:	6a 5b                	push   $0x5b
  80104d:	68 7a 27 80 00       	push   $0x80277a
  801052:	e8 5f f1 ff ff       	call   8001b6 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  801057:	83 ec 0c             	sub    $0xc,%esp
  80105a:	68 05 08 00 00       	push   $0x805
  80105f:	56                   	push   %esi
  801060:	6a 00                	push   $0x0
  801062:	56                   	push   %esi
  801063:	6a 00                	push   $0x0
  801065:	e8 f0 fb ff ff       	call   800c5a <sys_page_map>
		if (r < 0) {
  80106a:	83 c4 20             	add    $0x20,%esp
  80106d:	85 c0                	test   %eax,%eax
  80106f:	79 3e                	jns    8010af <fork+0x191>
		    	panic("sys page map fault %e");
  801071:	83 ec 04             	sub    $0x4,%esp
  801074:	68 ac 27 80 00       	push   $0x8027ac
  801079:	6a 5f                	push   $0x5f
  80107b:	68 7a 27 80 00       	push   $0x80277a
  801080:	e8 31 f1 ff ff       	call   8001b6 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801085:	83 ec 0c             	sub    $0xc,%esp
  801088:	6a 05                	push   $0x5
  80108a:	56                   	push   %esi
  80108b:	57                   	push   %edi
  80108c:	56                   	push   %esi
  80108d:	6a 00                	push   $0x0
  80108f:	e8 c6 fb ff ff       	call   800c5a <sys_page_map>
		if (r < 0) {
  801094:	83 c4 20             	add    $0x20,%esp
  801097:	85 c0                	test   %eax,%eax
  801099:	79 14                	jns    8010af <fork+0x191>
		    	panic("sys page map fault %e");
  80109b:	83 ec 04             	sub    $0x4,%esp
  80109e:	68 ac 27 80 00       	push   $0x8027ac
  8010a3:	6a 64                	push   $0x64
  8010a5:	68 7a 27 80 00       	push   $0x80277a
  8010aa:	e8 07 f1 ff ff       	call   8001b6 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8010af:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010b5:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8010bb:	0f 85 de fe ff ff    	jne    800f9f <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8010c1:	a1 20 60 80 00       	mov    0x806020,%eax
  8010c6:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  8010cc:	83 ec 08             	sub    $0x8,%esp
  8010cf:	50                   	push   %eax
  8010d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010d3:	57                   	push   %edi
  8010d4:	e8 89 fc ff ff       	call   800d62 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8010d9:	83 c4 08             	add    $0x8,%esp
  8010dc:	6a 02                	push   $0x2
  8010de:	57                   	push   %edi
  8010df:	e8 fa fb ff ff       	call   800cde <sys_env_set_status>
	
	return envid;
  8010e4:	83 c4 10             	add    $0x10,%esp
  8010e7:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8010e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ec:	5b                   	pop    %ebx
  8010ed:	5e                   	pop    %esi
  8010ee:	5f                   	pop    %edi
  8010ef:	5d                   	pop    %ebp
  8010f0:	c3                   	ret    

008010f1 <sfork>:

envid_t
sfork(void)
{
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
	return 0;
}
  8010f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f9:	5d                   	pop    %ebp
  8010fa:	c3                   	ret    

008010fb <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8010fb:	55                   	push   %ebp
  8010fc:	89 e5                	mov    %esp,%ebp
  8010fe:	56                   	push   %esi
  8010ff:	53                   	push   %ebx
  801100:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801103:	89 1d 24 60 80 00    	mov    %ebx,0x806024
	cprintf("in fork.c thread create. func: %x\n", func);
  801109:	83 ec 08             	sub    $0x8,%esp
  80110c:	53                   	push   %ebx
  80110d:	68 c4 27 80 00       	push   $0x8027c4
  801112:	e8 78 f1 ff ff       	call   80028f <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801117:	c7 04 24 7c 01 80 00 	movl   $0x80017c,(%esp)
  80111e:	e8 e5 fc ff ff       	call   800e08 <sys_thread_create>
  801123:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801125:	83 c4 08             	add    $0x8,%esp
  801128:	53                   	push   %ebx
  801129:	68 c4 27 80 00       	push   $0x8027c4
  80112e:	e8 5c f1 ff ff       	call   80028f <cprintf>
	return id;
}
  801133:	89 f0                	mov    %esi,%eax
  801135:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801138:	5b                   	pop    %ebx
  801139:	5e                   	pop    %esi
  80113a:	5d                   	pop    %ebp
  80113b:	c3                   	ret    

0080113c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80113c:	55                   	push   %ebp
  80113d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80113f:	8b 45 08             	mov    0x8(%ebp),%eax
  801142:	05 00 00 00 30       	add    $0x30000000,%eax
  801147:	c1 e8 0c             	shr    $0xc,%eax
}
  80114a:	5d                   	pop    %ebp
  80114b:	c3                   	ret    

0080114c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80114c:	55                   	push   %ebp
  80114d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80114f:	8b 45 08             	mov    0x8(%ebp),%eax
  801152:	05 00 00 00 30       	add    $0x30000000,%eax
  801157:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80115c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801161:	5d                   	pop    %ebp
  801162:	c3                   	ret    

00801163 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801163:	55                   	push   %ebp
  801164:	89 e5                	mov    %esp,%ebp
  801166:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801169:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80116e:	89 c2                	mov    %eax,%edx
  801170:	c1 ea 16             	shr    $0x16,%edx
  801173:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80117a:	f6 c2 01             	test   $0x1,%dl
  80117d:	74 11                	je     801190 <fd_alloc+0x2d>
  80117f:	89 c2                	mov    %eax,%edx
  801181:	c1 ea 0c             	shr    $0xc,%edx
  801184:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80118b:	f6 c2 01             	test   $0x1,%dl
  80118e:	75 09                	jne    801199 <fd_alloc+0x36>
			*fd_store = fd;
  801190:	89 01                	mov    %eax,(%ecx)
			return 0;
  801192:	b8 00 00 00 00       	mov    $0x0,%eax
  801197:	eb 17                	jmp    8011b0 <fd_alloc+0x4d>
  801199:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80119e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011a3:	75 c9                	jne    80116e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011a5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011ab:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011b0:	5d                   	pop    %ebp
  8011b1:	c3                   	ret    

008011b2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011b2:	55                   	push   %ebp
  8011b3:	89 e5                	mov    %esp,%ebp
  8011b5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011b8:	83 f8 1f             	cmp    $0x1f,%eax
  8011bb:	77 36                	ja     8011f3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011bd:	c1 e0 0c             	shl    $0xc,%eax
  8011c0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011c5:	89 c2                	mov    %eax,%edx
  8011c7:	c1 ea 16             	shr    $0x16,%edx
  8011ca:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011d1:	f6 c2 01             	test   $0x1,%dl
  8011d4:	74 24                	je     8011fa <fd_lookup+0x48>
  8011d6:	89 c2                	mov    %eax,%edx
  8011d8:	c1 ea 0c             	shr    $0xc,%edx
  8011db:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011e2:	f6 c2 01             	test   $0x1,%dl
  8011e5:	74 1a                	je     801201 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ea:	89 02                	mov    %eax,(%edx)
	return 0;
  8011ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f1:	eb 13                	jmp    801206 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f8:	eb 0c                	jmp    801206 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ff:	eb 05                	jmp    801206 <fd_lookup+0x54>
  801201:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801206:	5d                   	pop    %ebp
  801207:	c3                   	ret    

00801208 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	83 ec 08             	sub    $0x8,%esp
  80120e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801211:	ba 68 28 80 00       	mov    $0x802868,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801216:	eb 13                	jmp    80122b <dev_lookup+0x23>
  801218:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80121b:	39 08                	cmp    %ecx,(%eax)
  80121d:	75 0c                	jne    80122b <dev_lookup+0x23>
			*dev = devtab[i];
  80121f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801222:	89 01                	mov    %eax,(%ecx)
			return 0;
  801224:	b8 00 00 00 00       	mov    $0x0,%eax
  801229:	eb 2e                	jmp    801259 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80122b:	8b 02                	mov    (%edx),%eax
  80122d:	85 c0                	test   %eax,%eax
  80122f:	75 e7                	jne    801218 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801231:	a1 20 60 80 00       	mov    0x806020,%eax
  801236:	8b 40 7c             	mov    0x7c(%eax),%eax
  801239:	83 ec 04             	sub    $0x4,%esp
  80123c:	51                   	push   %ecx
  80123d:	50                   	push   %eax
  80123e:	68 e8 27 80 00       	push   $0x8027e8
  801243:	e8 47 f0 ff ff       	call   80028f <cprintf>
	*dev = 0;
  801248:	8b 45 0c             	mov    0xc(%ebp),%eax
  80124b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801251:	83 c4 10             	add    $0x10,%esp
  801254:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801259:	c9                   	leave  
  80125a:	c3                   	ret    

0080125b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80125b:	55                   	push   %ebp
  80125c:	89 e5                	mov    %esp,%ebp
  80125e:	56                   	push   %esi
  80125f:	53                   	push   %ebx
  801260:	83 ec 10             	sub    $0x10,%esp
  801263:	8b 75 08             	mov    0x8(%ebp),%esi
  801266:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801269:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126c:	50                   	push   %eax
  80126d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801273:	c1 e8 0c             	shr    $0xc,%eax
  801276:	50                   	push   %eax
  801277:	e8 36 ff ff ff       	call   8011b2 <fd_lookup>
  80127c:	83 c4 08             	add    $0x8,%esp
  80127f:	85 c0                	test   %eax,%eax
  801281:	78 05                	js     801288 <fd_close+0x2d>
	    || fd != fd2)
  801283:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801286:	74 0c                	je     801294 <fd_close+0x39>
		return (must_exist ? r : 0);
  801288:	84 db                	test   %bl,%bl
  80128a:	ba 00 00 00 00       	mov    $0x0,%edx
  80128f:	0f 44 c2             	cmove  %edx,%eax
  801292:	eb 41                	jmp    8012d5 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801294:	83 ec 08             	sub    $0x8,%esp
  801297:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80129a:	50                   	push   %eax
  80129b:	ff 36                	pushl  (%esi)
  80129d:	e8 66 ff ff ff       	call   801208 <dev_lookup>
  8012a2:	89 c3                	mov    %eax,%ebx
  8012a4:	83 c4 10             	add    $0x10,%esp
  8012a7:	85 c0                	test   %eax,%eax
  8012a9:	78 1a                	js     8012c5 <fd_close+0x6a>
		if (dev->dev_close)
  8012ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ae:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012b1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012b6:	85 c0                	test   %eax,%eax
  8012b8:	74 0b                	je     8012c5 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012ba:	83 ec 0c             	sub    $0xc,%esp
  8012bd:	56                   	push   %esi
  8012be:	ff d0                	call   *%eax
  8012c0:	89 c3                	mov    %eax,%ebx
  8012c2:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012c5:	83 ec 08             	sub    $0x8,%esp
  8012c8:	56                   	push   %esi
  8012c9:	6a 00                	push   $0x0
  8012cb:	e8 cc f9 ff ff       	call   800c9c <sys_page_unmap>
	return r;
  8012d0:	83 c4 10             	add    $0x10,%esp
  8012d3:	89 d8                	mov    %ebx,%eax
}
  8012d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d8:	5b                   	pop    %ebx
  8012d9:	5e                   	pop    %esi
  8012da:	5d                   	pop    %ebp
  8012db:	c3                   	ret    

008012dc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012dc:	55                   	push   %ebp
  8012dd:	89 e5                	mov    %esp,%ebp
  8012df:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e5:	50                   	push   %eax
  8012e6:	ff 75 08             	pushl  0x8(%ebp)
  8012e9:	e8 c4 fe ff ff       	call   8011b2 <fd_lookup>
  8012ee:	83 c4 08             	add    $0x8,%esp
  8012f1:	85 c0                	test   %eax,%eax
  8012f3:	78 10                	js     801305 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012f5:	83 ec 08             	sub    $0x8,%esp
  8012f8:	6a 01                	push   $0x1
  8012fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8012fd:	e8 59 ff ff ff       	call   80125b <fd_close>
  801302:	83 c4 10             	add    $0x10,%esp
}
  801305:	c9                   	leave  
  801306:	c3                   	ret    

00801307 <close_all>:

void
close_all(void)
{
  801307:	55                   	push   %ebp
  801308:	89 e5                	mov    %esp,%ebp
  80130a:	53                   	push   %ebx
  80130b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80130e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801313:	83 ec 0c             	sub    $0xc,%esp
  801316:	53                   	push   %ebx
  801317:	e8 c0 ff ff ff       	call   8012dc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80131c:	83 c3 01             	add    $0x1,%ebx
  80131f:	83 c4 10             	add    $0x10,%esp
  801322:	83 fb 20             	cmp    $0x20,%ebx
  801325:	75 ec                	jne    801313 <close_all+0xc>
		close(i);
}
  801327:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80132a:	c9                   	leave  
  80132b:	c3                   	ret    

0080132c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80132c:	55                   	push   %ebp
  80132d:	89 e5                	mov    %esp,%ebp
  80132f:	57                   	push   %edi
  801330:	56                   	push   %esi
  801331:	53                   	push   %ebx
  801332:	83 ec 2c             	sub    $0x2c,%esp
  801335:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801338:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80133b:	50                   	push   %eax
  80133c:	ff 75 08             	pushl  0x8(%ebp)
  80133f:	e8 6e fe ff ff       	call   8011b2 <fd_lookup>
  801344:	83 c4 08             	add    $0x8,%esp
  801347:	85 c0                	test   %eax,%eax
  801349:	0f 88 c1 00 00 00    	js     801410 <dup+0xe4>
		return r;
	close(newfdnum);
  80134f:	83 ec 0c             	sub    $0xc,%esp
  801352:	56                   	push   %esi
  801353:	e8 84 ff ff ff       	call   8012dc <close>

	newfd = INDEX2FD(newfdnum);
  801358:	89 f3                	mov    %esi,%ebx
  80135a:	c1 e3 0c             	shl    $0xc,%ebx
  80135d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801363:	83 c4 04             	add    $0x4,%esp
  801366:	ff 75 e4             	pushl  -0x1c(%ebp)
  801369:	e8 de fd ff ff       	call   80114c <fd2data>
  80136e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801370:	89 1c 24             	mov    %ebx,(%esp)
  801373:	e8 d4 fd ff ff       	call   80114c <fd2data>
  801378:	83 c4 10             	add    $0x10,%esp
  80137b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80137e:	89 f8                	mov    %edi,%eax
  801380:	c1 e8 16             	shr    $0x16,%eax
  801383:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80138a:	a8 01                	test   $0x1,%al
  80138c:	74 37                	je     8013c5 <dup+0x99>
  80138e:	89 f8                	mov    %edi,%eax
  801390:	c1 e8 0c             	shr    $0xc,%eax
  801393:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80139a:	f6 c2 01             	test   $0x1,%dl
  80139d:	74 26                	je     8013c5 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80139f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013a6:	83 ec 0c             	sub    $0xc,%esp
  8013a9:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ae:	50                   	push   %eax
  8013af:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013b2:	6a 00                	push   $0x0
  8013b4:	57                   	push   %edi
  8013b5:	6a 00                	push   $0x0
  8013b7:	e8 9e f8 ff ff       	call   800c5a <sys_page_map>
  8013bc:	89 c7                	mov    %eax,%edi
  8013be:	83 c4 20             	add    $0x20,%esp
  8013c1:	85 c0                	test   %eax,%eax
  8013c3:	78 2e                	js     8013f3 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013c5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013c8:	89 d0                	mov    %edx,%eax
  8013ca:	c1 e8 0c             	shr    $0xc,%eax
  8013cd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013d4:	83 ec 0c             	sub    $0xc,%esp
  8013d7:	25 07 0e 00 00       	and    $0xe07,%eax
  8013dc:	50                   	push   %eax
  8013dd:	53                   	push   %ebx
  8013de:	6a 00                	push   $0x0
  8013e0:	52                   	push   %edx
  8013e1:	6a 00                	push   $0x0
  8013e3:	e8 72 f8 ff ff       	call   800c5a <sys_page_map>
  8013e8:	89 c7                	mov    %eax,%edi
  8013ea:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013ed:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013ef:	85 ff                	test   %edi,%edi
  8013f1:	79 1d                	jns    801410 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013f3:	83 ec 08             	sub    $0x8,%esp
  8013f6:	53                   	push   %ebx
  8013f7:	6a 00                	push   $0x0
  8013f9:	e8 9e f8 ff ff       	call   800c9c <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013fe:	83 c4 08             	add    $0x8,%esp
  801401:	ff 75 d4             	pushl  -0x2c(%ebp)
  801404:	6a 00                	push   $0x0
  801406:	e8 91 f8 ff ff       	call   800c9c <sys_page_unmap>
	return r;
  80140b:	83 c4 10             	add    $0x10,%esp
  80140e:	89 f8                	mov    %edi,%eax
}
  801410:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801413:	5b                   	pop    %ebx
  801414:	5e                   	pop    %esi
  801415:	5f                   	pop    %edi
  801416:	5d                   	pop    %ebp
  801417:	c3                   	ret    

00801418 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801418:	55                   	push   %ebp
  801419:	89 e5                	mov    %esp,%ebp
  80141b:	53                   	push   %ebx
  80141c:	83 ec 14             	sub    $0x14,%esp
  80141f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801422:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801425:	50                   	push   %eax
  801426:	53                   	push   %ebx
  801427:	e8 86 fd ff ff       	call   8011b2 <fd_lookup>
  80142c:	83 c4 08             	add    $0x8,%esp
  80142f:	89 c2                	mov    %eax,%edx
  801431:	85 c0                	test   %eax,%eax
  801433:	78 6d                	js     8014a2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801435:	83 ec 08             	sub    $0x8,%esp
  801438:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80143b:	50                   	push   %eax
  80143c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143f:	ff 30                	pushl  (%eax)
  801441:	e8 c2 fd ff ff       	call   801208 <dev_lookup>
  801446:	83 c4 10             	add    $0x10,%esp
  801449:	85 c0                	test   %eax,%eax
  80144b:	78 4c                	js     801499 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80144d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801450:	8b 42 08             	mov    0x8(%edx),%eax
  801453:	83 e0 03             	and    $0x3,%eax
  801456:	83 f8 01             	cmp    $0x1,%eax
  801459:	75 21                	jne    80147c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80145b:	a1 20 60 80 00       	mov    0x806020,%eax
  801460:	8b 40 7c             	mov    0x7c(%eax),%eax
  801463:	83 ec 04             	sub    $0x4,%esp
  801466:	53                   	push   %ebx
  801467:	50                   	push   %eax
  801468:	68 2c 28 80 00       	push   $0x80282c
  80146d:	e8 1d ee ff ff       	call   80028f <cprintf>
		return -E_INVAL;
  801472:	83 c4 10             	add    $0x10,%esp
  801475:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80147a:	eb 26                	jmp    8014a2 <read+0x8a>
	}
	if (!dev->dev_read)
  80147c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147f:	8b 40 08             	mov    0x8(%eax),%eax
  801482:	85 c0                	test   %eax,%eax
  801484:	74 17                	je     80149d <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801486:	83 ec 04             	sub    $0x4,%esp
  801489:	ff 75 10             	pushl  0x10(%ebp)
  80148c:	ff 75 0c             	pushl  0xc(%ebp)
  80148f:	52                   	push   %edx
  801490:	ff d0                	call   *%eax
  801492:	89 c2                	mov    %eax,%edx
  801494:	83 c4 10             	add    $0x10,%esp
  801497:	eb 09                	jmp    8014a2 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801499:	89 c2                	mov    %eax,%edx
  80149b:	eb 05                	jmp    8014a2 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80149d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8014a2:	89 d0                	mov    %edx,%eax
  8014a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a7:	c9                   	leave  
  8014a8:	c3                   	ret    

008014a9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014a9:	55                   	push   %ebp
  8014aa:	89 e5                	mov    %esp,%ebp
  8014ac:	57                   	push   %edi
  8014ad:	56                   	push   %esi
  8014ae:	53                   	push   %ebx
  8014af:	83 ec 0c             	sub    $0xc,%esp
  8014b2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014b5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014bd:	eb 21                	jmp    8014e0 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014bf:	83 ec 04             	sub    $0x4,%esp
  8014c2:	89 f0                	mov    %esi,%eax
  8014c4:	29 d8                	sub    %ebx,%eax
  8014c6:	50                   	push   %eax
  8014c7:	89 d8                	mov    %ebx,%eax
  8014c9:	03 45 0c             	add    0xc(%ebp),%eax
  8014cc:	50                   	push   %eax
  8014cd:	57                   	push   %edi
  8014ce:	e8 45 ff ff ff       	call   801418 <read>
		if (m < 0)
  8014d3:	83 c4 10             	add    $0x10,%esp
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	78 10                	js     8014ea <readn+0x41>
			return m;
		if (m == 0)
  8014da:	85 c0                	test   %eax,%eax
  8014dc:	74 0a                	je     8014e8 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014de:	01 c3                	add    %eax,%ebx
  8014e0:	39 f3                	cmp    %esi,%ebx
  8014e2:	72 db                	jb     8014bf <readn+0x16>
  8014e4:	89 d8                	mov    %ebx,%eax
  8014e6:	eb 02                	jmp    8014ea <readn+0x41>
  8014e8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ed:	5b                   	pop    %ebx
  8014ee:	5e                   	pop    %esi
  8014ef:	5f                   	pop    %edi
  8014f0:	5d                   	pop    %ebp
  8014f1:	c3                   	ret    

008014f2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014f2:	55                   	push   %ebp
  8014f3:	89 e5                	mov    %esp,%ebp
  8014f5:	53                   	push   %ebx
  8014f6:	83 ec 14             	sub    $0x14,%esp
  8014f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ff:	50                   	push   %eax
  801500:	53                   	push   %ebx
  801501:	e8 ac fc ff ff       	call   8011b2 <fd_lookup>
  801506:	83 c4 08             	add    $0x8,%esp
  801509:	89 c2                	mov    %eax,%edx
  80150b:	85 c0                	test   %eax,%eax
  80150d:	78 68                	js     801577 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80150f:	83 ec 08             	sub    $0x8,%esp
  801512:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801515:	50                   	push   %eax
  801516:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801519:	ff 30                	pushl  (%eax)
  80151b:	e8 e8 fc ff ff       	call   801208 <dev_lookup>
  801520:	83 c4 10             	add    $0x10,%esp
  801523:	85 c0                	test   %eax,%eax
  801525:	78 47                	js     80156e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801527:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80152e:	75 21                	jne    801551 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801530:	a1 20 60 80 00       	mov    0x806020,%eax
  801535:	8b 40 7c             	mov    0x7c(%eax),%eax
  801538:	83 ec 04             	sub    $0x4,%esp
  80153b:	53                   	push   %ebx
  80153c:	50                   	push   %eax
  80153d:	68 48 28 80 00       	push   $0x802848
  801542:	e8 48 ed ff ff       	call   80028f <cprintf>
		return -E_INVAL;
  801547:	83 c4 10             	add    $0x10,%esp
  80154a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80154f:	eb 26                	jmp    801577 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801551:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801554:	8b 52 0c             	mov    0xc(%edx),%edx
  801557:	85 d2                	test   %edx,%edx
  801559:	74 17                	je     801572 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80155b:	83 ec 04             	sub    $0x4,%esp
  80155e:	ff 75 10             	pushl  0x10(%ebp)
  801561:	ff 75 0c             	pushl  0xc(%ebp)
  801564:	50                   	push   %eax
  801565:	ff d2                	call   *%edx
  801567:	89 c2                	mov    %eax,%edx
  801569:	83 c4 10             	add    $0x10,%esp
  80156c:	eb 09                	jmp    801577 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156e:	89 c2                	mov    %eax,%edx
  801570:	eb 05                	jmp    801577 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801572:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801577:	89 d0                	mov    %edx,%eax
  801579:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157c:	c9                   	leave  
  80157d:	c3                   	ret    

0080157e <seek>:

int
seek(int fdnum, off_t offset)
{
  80157e:	55                   	push   %ebp
  80157f:	89 e5                	mov    %esp,%ebp
  801581:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801584:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801587:	50                   	push   %eax
  801588:	ff 75 08             	pushl  0x8(%ebp)
  80158b:	e8 22 fc ff ff       	call   8011b2 <fd_lookup>
  801590:	83 c4 08             	add    $0x8,%esp
  801593:	85 c0                	test   %eax,%eax
  801595:	78 0e                	js     8015a5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801597:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80159a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80159d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015a5:	c9                   	leave  
  8015a6:	c3                   	ret    

008015a7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015a7:	55                   	push   %ebp
  8015a8:	89 e5                	mov    %esp,%ebp
  8015aa:	53                   	push   %ebx
  8015ab:	83 ec 14             	sub    $0x14,%esp
  8015ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b4:	50                   	push   %eax
  8015b5:	53                   	push   %ebx
  8015b6:	e8 f7 fb ff ff       	call   8011b2 <fd_lookup>
  8015bb:	83 c4 08             	add    $0x8,%esp
  8015be:	89 c2                	mov    %eax,%edx
  8015c0:	85 c0                	test   %eax,%eax
  8015c2:	78 65                	js     801629 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c4:	83 ec 08             	sub    $0x8,%esp
  8015c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ca:	50                   	push   %eax
  8015cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ce:	ff 30                	pushl  (%eax)
  8015d0:	e8 33 fc ff ff       	call   801208 <dev_lookup>
  8015d5:	83 c4 10             	add    $0x10,%esp
  8015d8:	85 c0                	test   %eax,%eax
  8015da:	78 44                	js     801620 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015df:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015e3:	75 21                	jne    801606 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015e5:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015ea:	8b 40 7c             	mov    0x7c(%eax),%eax
  8015ed:	83 ec 04             	sub    $0x4,%esp
  8015f0:	53                   	push   %ebx
  8015f1:	50                   	push   %eax
  8015f2:	68 08 28 80 00       	push   $0x802808
  8015f7:	e8 93 ec ff ff       	call   80028f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801604:	eb 23                	jmp    801629 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801606:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801609:	8b 52 18             	mov    0x18(%edx),%edx
  80160c:	85 d2                	test   %edx,%edx
  80160e:	74 14                	je     801624 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801610:	83 ec 08             	sub    $0x8,%esp
  801613:	ff 75 0c             	pushl  0xc(%ebp)
  801616:	50                   	push   %eax
  801617:	ff d2                	call   *%edx
  801619:	89 c2                	mov    %eax,%edx
  80161b:	83 c4 10             	add    $0x10,%esp
  80161e:	eb 09                	jmp    801629 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801620:	89 c2                	mov    %eax,%edx
  801622:	eb 05                	jmp    801629 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801624:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801629:	89 d0                	mov    %edx,%eax
  80162b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80162e:	c9                   	leave  
  80162f:	c3                   	ret    

00801630 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	53                   	push   %ebx
  801634:	83 ec 14             	sub    $0x14,%esp
  801637:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80163a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80163d:	50                   	push   %eax
  80163e:	ff 75 08             	pushl  0x8(%ebp)
  801641:	e8 6c fb ff ff       	call   8011b2 <fd_lookup>
  801646:	83 c4 08             	add    $0x8,%esp
  801649:	89 c2                	mov    %eax,%edx
  80164b:	85 c0                	test   %eax,%eax
  80164d:	78 58                	js     8016a7 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164f:	83 ec 08             	sub    $0x8,%esp
  801652:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801655:	50                   	push   %eax
  801656:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801659:	ff 30                	pushl  (%eax)
  80165b:	e8 a8 fb ff ff       	call   801208 <dev_lookup>
  801660:	83 c4 10             	add    $0x10,%esp
  801663:	85 c0                	test   %eax,%eax
  801665:	78 37                	js     80169e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801667:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80166a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80166e:	74 32                	je     8016a2 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801670:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801673:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80167a:	00 00 00 
	stat->st_isdir = 0;
  80167d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801684:	00 00 00 
	stat->st_dev = dev;
  801687:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80168d:	83 ec 08             	sub    $0x8,%esp
  801690:	53                   	push   %ebx
  801691:	ff 75 f0             	pushl  -0x10(%ebp)
  801694:	ff 50 14             	call   *0x14(%eax)
  801697:	89 c2                	mov    %eax,%edx
  801699:	83 c4 10             	add    $0x10,%esp
  80169c:	eb 09                	jmp    8016a7 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169e:	89 c2                	mov    %eax,%edx
  8016a0:	eb 05                	jmp    8016a7 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016a2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016a7:	89 d0                	mov    %edx,%eax
  8016a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ac:	c9                   	leave  
  8016ad:	c3                   	ret    

008016ae <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	56                   	push   %esi
  8016b2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016b3:	83 ec 08             	sub    $0x8,%esp
  8016b6:	6a 00                	push   $0x0
  8016b8:	ff 75 08             	pushl  0x8(%ebp)
  8016bb:	e8 e3 01 00 00       	call   8018a3 <open>
  8016c0:	89 c3                	mov    %eax,%ebx
  8016c2:	83 c4 10             	add    $0x10,%esp
  8016c5:	85 c0                	test   %eax,%eax
  8016c7:	78 1b                	js     8016e4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016c9:	83 ec 08             	sub    $0x8,%esp
  8016cc:	ff 75 0c             	pushl  0xc(%ebp)
  8016cf:	50                   	push   %eax
  8016d0:	e8 5b ff ff ff       	call   801630 <fstat>
  8016d5:	89 c6                	mov    %eax,%esi
	close(fd);
  8016d7:	89 1c 24             	mov    %ebx,(%esp)
  8016da:	e8 fd fb ff ff       	call   8012dc <close>
	return r;
  8016df:	83 c4 10             	add    $0x10,%esp
  8016e2:	89 f0                	mov    %esi,%eax
}
  8016e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016e7:	5b                   	pop    %ebx
  8016e8:	5e                   	pop    %esi
  8016e9:	5d                   	pop    %ebp
  8016ea:	c3                   	ret    

008016eb <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016eb:	55                   	push   %ebp
  8016ec:	89 e5                	mov    %esp,%ebp
  8016ee:	56                   	push   %esi
  8016ef:	53                   	push   %ebx
  8016f0:	89 c6                	mov    %eax,%esi
  8016f2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016f4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016fb:	75 12                	jne    80170f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016fd:	83 ec 0c             	sub    $0xc,%esp
  801700:	6a 01                	push   $0x1
  801702:	e8 a4 09 00 00       	call   8020ab <ipc_find_env>
  801707:	a3 00 40 80 00       	mov    %eax,0x804000
  80170c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80170f:	6a 07                	push   $0x7
  801711:	68 00 70 80 00       	push   $0x807000
  801716:	56                   	push   %esi
  801717:	ff 35 00 40 80 00    	pushl  0x804000
  80171d:	e8 27 09 00 00       	call   802049 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801722:	83 c4 0c             	add    $0xc,%esp
  801725:	6a 00                	push   $0x0
  801727:	53                   	push   %ebx
  801728:	6a 00                	push   $0x0
  80172a:	e8 9f 08 00 00       	call   801fce <ipc_recv>
}
  80172f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801732:	5b                   	pop    %ebx
  801733:	5e                   	pop    %esi
  801734:	5d                   	pop    %ebp
  801735:	c3                   	ret    

00801736 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801736:	55                   	push   %ebp
  801737:	89 e5                	mov    %esp,%ebp
  801739:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80173c:	8b 45 08             	mov    0x8(%ebp),%eax
  80173f:	8b 40 0c             	mov    0xc(%eax),%eax
  801742:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  801747:	8b 45 0c             	mov    0xc(%ebp),%eax
  80174a:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80174f:	ba 00 00 00 00       	mov    $0x0,%edx
  801754:	b8 02 00 00 00       	mov    $0x2,%eax
  801759:	e8 8d ff ff ff       	call   8016eb <fsipc>
}
  80175e:	c9                   	leave  
  80175f:	c3                   	ret    

00801760 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801760:	55                   	push   %ebp
  801761:	89 e5                	mov    %esp,%ebp
  801763:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801766:	8b 45 08             	mov    0x8(%ebp),%eax
  801769:	8b 40 0c             	mov    0xc(%eax),%eax
  80176c:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  801771:	ba 00 00 00 00       	mov    $0x0,%edx
  801776:	b8 06 00 00 00       	mov    $0x6,%eax
  80177b:	e8 6b ff ff ff       	call   8016eb <fsipc>
}
  801780:	c9                   	leave  
  801781:	c3                   	ret    

00801782 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801782:	55                   	push   %ebp
  801783:	89 e5                	mov    %esp,%ebp
  801785:	53                   	push   %ebx
  801786:	83 ec 04             	sub    $0x4,%esp
  801789:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80178c:	8b 45 08             	mov    0x8(%ebp),%eax
  80178f:	8b 40 0c             	mov    0xc(%eax),%eax
  801792:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801797:	ba 00 00 00 00       	mov    $0x0,%edx
  80179c:	b8 05 00 00 00       	mov    $0x5,%eax
  8017a1:	e8 45 ff ff ff       	call   8016eb <fsipc>
  8017a6:	85 c0                	test   %eax,%eax
  8017a8:	78 2c                	js     8017d6 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017aa:	83 ec 08             	sub    $0x8,%esp
  8017ad:	68 00 70 80 00       	push   $0x807000
  8017b2:	53                   	push   %ebx
  8017b3:	e8 5c f0 ff ff       	call   800814 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017b8:	a1 80 70 80 00       	mov    0x807080,%eax
  8017bd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017c3:	a1 84 70 80 00       	mov    0x807084,%eax
  8017c8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017ce:	83 c4 10             	add    $0x10,%esp
  8017d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d9:	c9                   	leave  
  8017da:	c3                   	ret    

008017db <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017db:	55                   	push   %ebp
  8017dc:	89 e5                	mov    %esp,%ebp
  8017de:	83 ec 0c             	sub    $0xc,%esp
  8017e1:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8017e7:	8b 52 0c             	mov    0xc(%edx),%edx
  8017ea:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8017f0:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017f5:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017fa:	0f 47 c2             	cmova  %edx,%eax
  8017fd:	a3 04 70 80 00       	mov    %eax,0x807004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801802:	50                   	push   %eax
  801803:	ff 75 0c             	pushl  0xc(%ebp)
  801806:	68 08 70 80 00       	push   $0x807008
  80180b:	e8 96 f1 ff ff       	call   8009a6 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801810:	ba 00 00 00 00       	mov    $0x0,%edx
  801815:	b8 04 00 00 00       	mov    $0x4,%eax
  80181a:	e8 cc fe ff ff       	call   8016eb <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80181f:	c9                   	leave  
  801820:	c3                   	ret    

00801821 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801821:	55                   	push   %ebp
  801822:	89 e5                	mov    %esp,%ebp
  801824:	56                   	push   %esi
  801825:	53                   	push   %ebx
  801826:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801829:	8b 45 08             	mov    0x8(%ebp),%eax
  80182c:	8b 40 0c             	mov    0xc(%eax),%eax
  80182f:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801834:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80183a:	ba 00 00 00 00       	mov    $0x0,%edx
  80183f:	b8 03 00 00 00       	mov    $0x3,%eax
  801844:	e8 a2 fe ff ff       	call   8016eb <fsipc>
  801849:	89 c3                	mov    %eax,%ebx
  80184b:	85 c0                	test   %eax,%eax
  80184d:	78 4b                	js     80189a <devfile_read+0x79>
		return r;
	assert(r <= n);
  80184f:	39 c6                	cmp    %eax,%esi
  801851:	73 16                	jae    801869 <devfile_read+0x48>
  801853:	68 78 28 80 00       	push   $0x802878
  801858:	68 7f 28 80 00       	push   $0x80287f
  80185d:	6a 7c                	push   $0x7c
  80185f:	68 94 28 80 00       	push   $0x802894
  801864:	e8 4d e9 ff ff       	call   8001b6 <_panic>
	assert(r <= PGSIZE);
  801869:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80186e:	7e 16                	jle    801886 <devfile_read+0x65>
  801870:	68 9f 28 80 00       	push   $0x80289f
  801875:	68 7f 28 80 00       	push   $0x80287f
  80187a:	6a 7d                	push   $0x7d
  80187c:	68 94 28 80 00       	push   $0x802894
  801881:	e8 30 e9 ff ff       	call   8001b6 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801886:	83 ec 04             	sub    $0x4,%esp
  801889:	50                   	push   %eax
  80188a:	68 00 70 80 00       	push   $0x807000
  80188f:	ff 75 0c             	pushl  0xc(%ebp)
  801892:	e8 0f f1 ff ff       	call   8009a6 <memmove>
	return r;
  801897:	83 c4 10             	add    $0x10,%esp
}
  80189a:	89 d8                	mov    %ebx,%eax
  80189c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80189f:	5b                   	pop    %ebx
  8018a0:	5e                   	pop    %esi
  8018a1:	5d                   	pop    %ebp
  8018a2:	c3                   	ret    

008018a3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018a3:	55                   	push   %ebp
  8018a4:	89 e5                	mov    %esp,%ebp
  8018a6:	53                   	push   %ebx
  8018a7:	83 ec 20             	sub    $0x20,%esp
  8018aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018ad:	53                   	push   %ebx
  8018ae:	e8 28 ef ff ff       	call   8007db <strlen>
  8018b3:	83 c4 10             	add    $0x10,%esp
  8018b6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018bb:	7f 67                	jg     801924 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018bd:	83 ec 0c             	sub    $0xc,%esp
  8018c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c3:	50                   	push   %eax
  8018c4:	e8 9a f8 ff ff       	call   801163 <fd_alloc>
  8018c9:	83 c4 10             	add    $0x10,%esp
		return r;
  8018cc:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018ce:	85 c0                	test   %eax,%eax
  8018d0:	78 57                	js     801929 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018d2:	83 ec 08             	sub    $0x8,%esp
  8018d5:	53                   	push   %ebx
  8018d6:	68 00 70 80 00       	push   $0x807000
  8018db:	e8 34 ef ff ff       	call   800814 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e3:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018eb:	b8 01 00 00 00       	mov    $0x1,%eax
  8018f0:	e8 f6 fd ff ff       	call   8016eb <fsipc>
  8018f5:	89 c3                	mov    %eax,%ebx
  8018f7:	83 c4 10             	add    $0x10,%esp
  8018fa:	85 c0                	test   %eax,%eax
  8018fc:	79 14                	jns    801912 <open+0x6f>
		fd_close(fd, 0);
  8018fe:	83 ec 08             	sub    $0x8,%esp
  801901:	6a 00                	push   $0x0
  801903:	ff 75 f4             	pushl  -0xc(%ebp)
  801906:	e8 50 f9 ff ff       	call   80125b <fd_close>
		return r;
  80190b:	83 c4 10             	add    $0x10,%esp
  80190e:	89 da                	mov    %ebx,%edx
  801910:	eb 17                	jmp    801929 <open+0x86>
	}

	return fd2num(fd);
  801912:	83 ec 0c             	sub    $0xc,%esp
  801915:	ff 75 f4             	pushl  -0xc(%ebp)
  801918:	e8 1f f8 ff ff       	call   80113c <fd2num>
  80191d:	89 c2                	mov    %eax,%edx
  80191f:	83 c4 10             	add    $0x10,%esp
  801922:	eb 05                	jmp    801929 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801924:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801929:	89 d0                	mov    %edx,%eax
  80192b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80192e:	c9                   	leave  
  80192f:	c3                   	ret    

00801930 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801936:	ba 00 00 00 00       	mov    $0x0,%edx
  80193b:	b8 08 00 00 00       	mov    $0x8,%eax
  801940:	e8 a6 fd ff ff       	call   8016eb <fsipc>
}
  801945:	c9                   	leave  
  801946:	c3                   	ret    

00801947 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801947:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80194b:	7e 37                	jle    801984 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  80194d:	55                   	push   %ebp
  80194e:	89 e5                	mov    %esp,%ebp
  801950:	53                   	push   %ebx
  801951:	83 ec 08             	sub    $0x8,%esp
  801954:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801956:	ff 70 04             	pushl  0x4(%eax)
  801959:	8d 40 10             	lea    0x10(%eax),%eax
  80195c:	50                   	push   %eax
  80195d:	ff 33                	pushl  (%ebx)
  80195f:	e8 8e fb ff ff       	call   8014f2 <write>
		if (result > 0)
  801964:	83 c4 10             	add    $0x10,%esp
  801967:	85 c0                	test   %eax,%eax
  801969:	7e 03                	jle    80196e <writebuf+0x27>
			b->result += result;
  80196b:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80196e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801971:	74 0d                	je     801980 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801973:	85 c0                	test   %eax,%eax
  801975:	ba 00 00 00 00       	mov    $0x0,%edx
  80197a:	0f 4f c2             	cmovg  %edx,%eax
  80197d:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801980:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801983:	c9                   	leave  
  801984:	f3 c3                	repz ret 

00801986 <putch>:

static void
putch(int ch, void *thunk)
{
  801986:	55                   	push   %ebp
  801987:	89 e5                	mov    %esp,%ebp
  801989:	53                   	push   %ebx
  80198a:	83 ec 04             	sub    $0x4,%esp
  80198d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801990:	8b 53 04             	mov    0x4(%ebx),%edx
  801993:	8d 42 01             	lea    0x1(%edx),%eax
  801996:	89 43 04             	mov    %eax,0x4(%ebx)
  801999:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80199c:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8019a0:	3d 00 01 00 00       	cmp    $0x100,%eax
  8019a5:	75 0e                	jne    8019b5 <putch+0x2f>
		writebuf(b);
  8019a7:	89 d8                	mov    %ebx,%eax
  8019a9:	e8 99 ff ff ff       	call   801947 <writebuf>
		b->idx = 0;
  8019ae:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8019b5:	83 c4 04             	add    $0x4,%esp
  8019b8:	5b                   	pop    %ebx
  8019b9:	5d                   	pop    %ebp
  8019ba:	c3                   	ret    

008019bb <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8019c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c7:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8019cd:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8019d4:	00 00 00 
	b.result = 0;
  8019d7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8019de:	00 00 00 
	b.error = 1;
  8019e1:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8019e8:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8019eb:	ff 75 10             	pushl  0x10(%ebp)
  8019ee:	ff 75 0c             	pushl  0xc(%ebp)
  8019f1:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8019f7:	50                   	push   %eax
  8019f8:	68 86 19 80 00       	push   $0x801986
  8019fd:	e8 c4 e9 ff ff       	call   8003c6 <vprintfmt>
	if (b.idx > 0)
  801a02:	83 c4 10             	add    $0x10,%esp
  801a05:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801a0c:	7e 0b                	jle    801a19 <vfprintf+0x5e>
		writebuf(&b);
  801a0e:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a14:	e8 2e ff ff ff       	call   801947 <writebuf>

	return (b.result ? b.result : b.error);
  801a19:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801a1f:	85 c0                	test   %eax,%eax
  801a21:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801a28:	c9                   	leave  
  801a29:	c3                   	ret    

00801a2a <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801a2a:	55                   	push   %ebp
  801a2b:	89 e5                	mov    %esp,%ebp
  801a2d:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a30:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801a33:	50                   	push   %eax
  801a34:	ff 75 0c             	pushl  0xc(%ebp)
  801a37:	ff 75 08             	pushl  0x8(%ebp)
  801a3a:	e8 7c ff ff ff       	call   8019bb <vfprintf>
	va_end(ap);

	return cnt;
}
  801a3f:	c9                   	leave  
  801a40:	c3                   	ret    

00801a41 <printf>:

int
printf(const char *fmt, ...)
{
  801a41:	55                   	push   %ebp
  801a42:	89 e5                	mov    %esp,%ebp
  801a44:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a47:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801a4a:	50                   	push   %eax
  801a4b:	ff 75 08             	pushl  0x8(%ebp)
  801a4e:	6a 01                	push   $0x1
  801a50:	e8 66 ff ff ff       	call   8019bb <vfprintf>
	va_end(ap);

	return cnt;
}
  801a55:	c9                   	leave  
  801a56:	c3                   	ret    

00801a57 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a57:	55                   	push   %ebp
  801a58:	89 e5                	mov    %esp,%ebp
  801a5a:	56                   	push   %esi
  801a5b:	53                   	push   %ebx
  801a5c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a5f:	83 ec 0c             	sub    $0xc,%esp
  801a62:	ff 75 08             	pushl  0x8(%ebp)
  801a65:	e8 e2 f6 ff ff       	call   80114c <fd2data>
  801a6a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a6c:	83 c4 08             	add    $0x8,%esp
  801a6f:	68 ab 28 80 00       	push   $0x8028ab
  801a74:	53                   	push   %ebx
  801a75:	e8 9a ed ff ff       	call   800814 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a7a:	8b 46 04             	mov    0x4(%esi),%eax
  801a7d:	2b 06                	sub    (%esi),%eax
  801a7f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a85:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a8c:	00 00 00 
	stat->st_dev = &devpipe;
  801a8f:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a96:	30 80 00 
	return 0;
}
  801a99:	b8 00 00 00 00       	mov    $0x0,%eax
  801a9e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa1:	5b                   	pop    %ebx
  801aa2:	5e                   	pop    %esi
  801aa3:	5d                   	pop    %ebp
  801aa4:	c3                   	ret    

00801aa5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801aa5:	55                   	push   %ebp
  801aa6:	89 e5                	mov    %esp,%ebp
  801aa8:	53                   	push   %ebx
  801aa9:	83 ec 0c             	sub    $0xc,%esp
  801aac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801aaf:	53                   	push   %ebx
  801ab0:	6a 00                	push   $0x0
  801ab2:	e8 e5 f1 ff ff       	call   800c9c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ab7:	89 1c 24             	mov    %ebx,(%esp)
  801aba:	e8 8d f6 ff ff       	call   80114c <fd2data>
  801abf:	83 c4 08             	add    $0x8,%esp
  801ac2:	50                   	push   %eax
  801ac3:	6a 00                	push   $0x0
  801ac5:	e8 d2 f1 ff ff       	call   800c9c <sys_page_unmap>
}
  801aca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801acd:	c9                   	leave  
  801ace:	c3                   	ret    

00801acf <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801acf:	55                   	push   %ebp
  801ad0:	89 e5                	mov    %esp,%ebp
  801ad2:	57                   	push   %edi
  801ad3:	56                   	push   %esi
  801ad4:	53                   	push   %ebx
  801ad5:	83 ec 1c             	sub    $0x1c,%esp
  801ad8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801adb:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801add:	a1 20 60 80 00       	mov    0x806020,%eax
  801ae2:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ae8:	83 ec 0c             	sub    $0xc,%esp
  801aeb:	ff 75 e0             	pushl  -0x20(%ebp)
  801aee:	e8 fa 05 00 00       	call   8020ed <pageref>
  801af3:	89 c3                	mov    %eax,%ebx
  801af5:	89 3c 24             	mov    %edi,(%esp)
  801af8:	e8 f0 05 00 00       	call   8020ed <pageref>
  801afd:	83 c4 10             	add    $0x10,%esp
  801b00:	39 c3                	cmp    %eax,%ebx
  801b02:	0f 94 c1             	sete   %cl
  801b05:	0f b6 c9             	movzbl %cl,%ecx
  801b08:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b0b:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801b11:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  801b17:	39 ce                	cmp    %ecx,%esi
  801b19:	74 1e                	je     801b39 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801b1b:	39 c3                	cmp    %eax,%ebx
  801b1d:	75 be                	jne    801add <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b1f:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  801b25:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b28:	50                   	push   %eax
  801b29:	56                   	push   %esi
  801b2a:	68 b2 28 80 00       	push   $0x8028b2
  801b2f:	e8 5b e7 ff ff       	call   80028f <cprintf>
  801b34:	83 c4 10             	add    $0x10,%esp
  801b37:	eb a4                	jmp    801add <_pipeisclosed+0xe>
	}
}
  801b39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3f:	5b                   	pop    %ebx
  801b40:	5e                   	pop    %esi
  801b41:	5f                   	pop    %edi
  801b42:	5d                   	pop    %ebp
  801b43:	c3                   	ret    

00801b44 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	57                   	push   %edi
  801b48:	56                   	push   %esi
  801b49:	53                   	push   %ebx
  801b4a:	83 ec 28             	sub    $0x28,%esp
  801b4d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b50:	56                   	push   %esi
  801b51:	e8 f6 f5 ff ff       	call   80114c <fd2data>
  801b56:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b58:	83 c4 10             	add    $0x10,%esp
  801b5b:	bf 00 00 00 00       	mov    $0x0,%edi
  801b60:	eb 4b                	jmp    801bad <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b62:	89 da                	mov    %ebx,%edx
  801b64:	89 f0                	mov    %esi,%eax
  801b66:	e8 64 ff ff ff       	call   801acf <_pipeisclosed>
  801b6b:	85 c0                	test   %eax,%eax
  801b6d:	75 48                	jne    801bb7 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b6f:	e8 84 f0 ff ff       	call   800bf8 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b74:	8b 43 04             	mov    0x4(%ebx),%eax
  801b77:	8b 0b                	mov    (%ebx),%ecx
  801b79:	8d 51 20             	lea    0x20(%ecx),%edx
  801b7c:	39 d0                	cmp    %edx,%eax
  801b7e:	73 e2                	jae    801b62 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b83:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b87:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b8a:	89 c2                	mov    %eax,%edx
  801b8c:	c1 fa 1f             	sar    $0x1f,%edx
  801b8f:	89 d1                	mov    %edx,%ecx
  801b91:	c1 e9 1b             	shr    $0x1b,%ecx
  801b94:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b97:	83 e2 1f             	and    $0x1f,%edx
  801b9a:	29 ca                	sub    %ecx,%edx
  801b9c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ba0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ba4:	83 c0 01             	add    $0x1,%eax
  801ba7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801baa:	83 c7 01             	add    $0x1,%edi
  801bad:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bb0:	75 c2                	jne    801b74 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bb2:	8b 45 10             	mov    0x10(%ebp),%eax
  801bb5:	eb 05                	jmp    801bbc <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bb7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bbf:	5b                   	pop    %ebx
  801bc0:	5e                   	pop    %esi
  801bc1:	5f                   	pop    %edi
  801bc2:	5d                   	pop    %ebp
  801bc3:	c3                   	ret    

00801bc4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bc4:	55                   	push   %ebp
  801bc5:	89 e5                	mov    %esp,%ebp
  801bc7:	57                   	push   %edi
  801bc8:	56                   	push   %esi
  801bc9:	53                   	push   %ebx
  801bca:	83 ec 18             	sub    $0x18,%esp
  801bcd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bd0:	57                   	push   %edi
  801bd1:	e8 76 f5 ff ff       	call   80114c <fd2data>
  801bd6:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bd8:	83 c4 10             	add    $0x10,%esp
  801bdb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801be0:	eb 3d                	jmp    801c1f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801be2:	85 db                	test   %ebx,%ebx
  801be4:	74 04                	je     801bea <devpipe_read+0x26>
				return i;
  801be6:	89 d8                	mov    %ebx,%eax
  801be8:	eb 44                	jmp    801c2e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bea:	89 f2                	mov    %esi,%edx
  801bec:	89 f8                	mov    %edi,%eax
  801bee:	e8 dc fe ff ff       	call   801acf <_pipeisclosed>
  801bf3:	85 c0                	test   %eax,%eax
  801bf5:	75 32                	jne    801c29 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bf7:	e8 fc ef ff ff       	call   800bf8 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bfc:	8b 06                	mov    (%esi),%eax
  801bfe:	3b 46 04             	cmp    0x4(%esi),%eax
  801c01:	74 df                	je     801be2 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c03:	99                   	cltd   
  801c04:	c1 ea 1b             	shr    $0x1b,%edx
  801c07:	01 d0                	add    %edx,%eax
  801c09:	83 e0 1f             	and    $0x1f,%eax
  801c0c:	29 d0                	sub    %edx,%eax
  801c0e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c16:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c19:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c1c:	83 c3 01             	add    $0x1,%ebx
  801c1f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c22:	75 d8                	jne    801bfc <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c24:	8b 45 10             	mov    0x10(%ebp),%eax
  801c27:	eb 05                	jmp    801c2e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c29:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c31:	5b                   	pop    %ebx
  801c32:	5e                   	pop    %esi
  801c33:	5f                   	pop    %edi
  801c34:	5d                   	pop    %ebp
  801c35:	c3                   	ret    

00801c36 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c36:	55                   	push   %ebp
  801c37:	89 e5                	mov    %esp,%ebp
  801c39:	56                   	push   %esi
  801c3a:	53                   	push   %ebx
  801c3b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c41:	50                   	push   %eax
  801c42:	e8 1c f5 ff ff       	call   801163 <fd_alloc>
  801c47:	83 c4 10             	add    $0x10,%esp
  801c4a:	89 c2                	mov    %eax,%edx
  801c4c:	85 c0                	test   %eax,%eax
  801c4e:	0f 88 2c 01 00 00    	js     801d80 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c54:	83 ec 04             	sub    $0x4,%esp
  801c57:	68 07 04 00 00       	push   $0x407
  801c5c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c5f:	6a 00                	push   $0x0
  801c61:	e8 b1 ef ff ff       	call   800c17 <sys_page_alloc>
  801c66:	83 c4 10             	add    $0x10,%esp
  801c69:	89 c2                	mov    %eax,%edx
  801c6b:	85 c0                	test   %eax,%eax
  801c6d:	0f 88 0d 01 00 00    	js     801d80 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c73:	83 ec 0c             	sub    $0xc,%esp
  801c76:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c79:	50                   	push   %eax
  801c7a:	e8 e4 f4 ff ff       	call   801163 <fd_alloc>
  801c7f:	89 c3                	mov    %eax,%ebx
  801c81:	83 c4 10             	add    $0x10,%esp
  801c84:	85 c0                	test   %eax,%eax
  801c86:	0f 88 e2 00 00 00    	js     801d6e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c8c:	83 ec 04             	sub    $0x4,%esp
  801c8f:	68 07 04 00 00       	push   $0x407
  801c94:	ff 75 f0             	pushl  -0x10(%ebp)
  801c97:	6a 00                	push   $0x0
  801c99:	e8 79 ef ff ff       	call   800c17 <sys_page_alloc>
  801c9e:	89 c3                	mov    %eax,%ebx
  801ca0:	83 c4 10             	add    $0x10,%esp
  801ca3:	85 c0                	test   %eax,%eax
  801ca5:	0f 88 c3 00 00 00    	js     801d6e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cab:	83 ec 0c             	sub    $0xc,%esp
  801cae:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb1:	e8 96 f4 ff ff       	call   80114c <fd2data>
  801cb6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cb8:	83 c4 0c             	add    $0xc,%esp
  801cbb:	68 07 04 00 00       	push   $0x407
  801cc0:	50                   	push   %eax
  801cc1:	6a 00                	push   $0x0
  801cc3:	e8 4f ef ff ff       	call   800c17 <sys_page_alloc>
  801cc8:	89 c3                	mov    %eax,%ebx
  801cca:	83 c4 10             	add    $0x10,%esp
  801ccd:	85 c0                	test   %eax,%eax
  801ccf:	0f 88 89 00 00 00    	js     801d5e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cd5:	83 ec 0c             	sub    $0xc,%esp
  801cd8:	ff 75 f0             	pushl  -0x10(%ebp)
  801cdb:	e8 6c f4 ff ff       	call   80114c <fd2data>
  801ce0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ce7:	50                   	push   %eax
  801ce8:	6a 00                	push   $0x0
  801cea:	56                   	push   %esi
  801ceb:	6a 00                	push   $0x0
  801ced:	e8 68 ef ff ff       	call   800c5a <sys_page_map>
  801cf2:	89 c3                	mov    %eax,%ebx
  801cf4:	83 c4 20             	add    $0x20,%esp
  801cf7:	85 c0                	test   %eax,%eax
  801cf9:	78 55                	js     801d50 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cfb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d04:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d09:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d10:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d16:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d19:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d1e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d25:	83 ec 0c             	sub    $0xc,%esp
  801d28:	ff 75 f4             	pushl  -0xc(%ebp)
  801d2b:	e8 0c f4 ff ff       	call   80113c <fd2num>
  801d30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d33:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d35:	83 c4 04             	add    $0x4,%esp
  801d38:	ff 75 f0             	pushl  -0x10(%ebp)
  801d3b:	e8 fc f3 ff ff       	call   80113c <fd2num>
  801d40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d43:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801d46:	83 c4 10             	add    $0x10,%esp
  801d49:	ba 00 00 00 00       	mov    $0x0,%edx
  801d4e:	eb 30                	jmp    801d80 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d50:	83 ec 08             	sub    $0x8,%esp
  801d53:	56                   	push   %esi
  801d54:	6a 00                	push   $0x0
  801d56:	e8 41 ef ff ff       	call   800c9c <sys_page_unmap>
  801d5b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d5e:	83 ec 08             	sub    $0x8,%esp
  801d61:	ff 75 f0             	pushl  -0x10(%ebp)
  801d64:	6a 00                	push   $0x0
  801d66:	e8 31 ef ff ff       	call   800c9c <sys_page_unmap>
  801d6b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d6e:	83 ec 08             	sub    $0x8,%esp
  801d71:	ff 75 f4             	pushl  -0xc(%ebp)
  801d74:	6a 00                	push   $0x0
  801d76:	e8 21 ef ff ff       	call   800c9c <sys_page_unmap>
  801d7b:	83 c4 10             	add    $0x10,%esp
  801d7e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d80:	89 d0                	mov    %edx,%eax
  801d82:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d85:	5b                   	pop    %ebx
  801d86:	5e                   	pop    %esi
  801d87:	5d                   	pop    %ebp
  801d88:	c3                   	ret    

00801d89 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d89:	55                   	push   %ebp
  801d8a:	89 e5                	mov    %esp,%ebp
  801d8c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d92:	50                   	push   %eax
  801d93:	ff 75 08             	pushl  0x8(%ebp)
  801d96:	e8 17 f4 ff ff       	call   8011b2 <fd_lookup>
  801d9b:	83 c4 10             	add    $0x10,%esp
  801d9e:	85 c0                	test   %eax,%eax
  801da0:	78 18                	js     801dba <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801da2:	83 ec 0c             	sub    $0xc,%esp
  801da5:	ff 75 f4             	pushl  -0xc(%ebp)
  801da8:	e8 9f f3 ff ff       	call   80114c <fd2data>
	return _pipeisclosed(fd, p);
  801dad:	89 c2                	mov    %eax,%edx
  801daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db2:	e8 18 fd ff ff       	call   801acf <_pipeisclosed>
  801db7:	83 c4 10             	add    $0x10,%esp
}
  801dba:	c9                   	leave  
  801dbb:	c3                   	ret    

00801dbc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801dbc:	55                   	push   %ebp
  801dbd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801dbf:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc4:	5d                   	pop    %ebp
  801dc5:	c3                   	ret    

00801dc6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dc6:	55                   	push   %ebp
  801dc7:	89 e5                	mov    %esp,%ebp
  801dc9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dcc:	68 ca 28 80 00       	push   $0x8028ca
  801dd1:	ff 75 0c             	pushl  0xc(%ebp)
  801dd4:	e8 3b ea ff ff       	call   800814 <strcpy>
	return 0;
}
  801dd9:	b8 00 00 00 00       	mov    $0x0,%eax
  801dde:	c9                   	leave  
  801ddf:	c3                   	ret    

00801de0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	57                   	push   %edi
  801de4:	56                   	push   %esi
  801de5:	53                   	push   %ebx
  801de6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dec:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801df1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801df7:	eb 2d                	jmp    801e26 <devcons_write+0x46>
		m = n - tot;
  801df9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dfc:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801dfe:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e01:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e06:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e09:	83 ec 04             	sub    $0x4,%esp
  801e0c:	53                   	push   %ebx
  801e0d:	03 45 0c             	add    0xc(%ebp),%eax
  801e10:	50                   	push   %eax
  801e11:	57                   	push   %edi
  801e12:	e8 8f eb ff ff       	call   8009a6 <memmove>
		sys_cputs(buf, m);
  801e17:	83 c4 08             	add    $0x8,%esp
  801e1a:	53                   	push   %ebx
  801e1b:	57                   	push   %edi
  801e1c:	e8 3a ed ff ff       	call   800b5b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e21:	01 de                	add    %ebx,%esi
  801e23:	83 c4 10             	add    $0x10,%esp
  801e26:	89 f0                	mov    %esi,%eax
  801e28:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e2b:	72 cc                	jb     801df9 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e30:	5b                   	pop    %ebx
  801e31:	5e                   	pop    %esi
  801e32:	5f                   	pop    %edi
  801e33:	5d                   	pop    %ebp
  801e34:	c3                   	ret    

00801e35 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e35:	55                   	push   %ebp
  801e36:	89 e5                	mov    %esp,%ebp
  801e38:	83 ec 08             	sub    $0x8,%esp
  801e3b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e40:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e44:	74 2a                	je     801e70 <devcons_read+0x3b>
  801e46:	eb 05                	jmp    801e4d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e48:	e8 ab ed ff ff       	call   800bf8 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e4d:	e8 27 ed ff ff       	call   800b79 <sys_cgetc>
  801e52:	85 c0                	test   %eax,%eax
  801e54:	74 f2                	je     801e48 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e56:	85 c0                	test   %eax,%eax
  801e58:	78 16                	js     801e70 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e5a:	83 f8 04             	cmp    $0x4,%eax
  801e5d:	74 0c                	je     801e6b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e5f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e62:	88 02                	mov    %al,(%edx)
	return 1;
  801e64:	b8 01 00 00 00       	mov    $0x1,%eax
  801e69:	eb 05                	jmp    801e70 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e6b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e70:	c9                   	leave  
  801e71:	c3                   	ret    

00801e72 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e72:	55                   	push   %ebp
  801e73:	89 e5                	mov    %esp,%ebp
  801e75:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e78:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e7e:	6a 01                	push   $0x1
  801e80:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e83:	50                   	push   %eax
  801e84:	e8 d2 ec ff ff       	call   800b5b <sys_cputs>
}
  801e89:	83 c4 10             	add    $0x10,%esp
  801e8c:	c9                   	leave  
  801e8d:	c3                   	ret    

00801e8e <getchar>:

int
getchar(void)
{
  801e8e:	55                   	push   %ebp
  801e8f:	89 e5                	mov    %esp,%ebp
  801e91:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e94:	6a 01                	push   $0x1
  801e96:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e99:	50                   	push   %eax
  801e9a:	6a 00                	push   $0x0
  801e9c:	e8 77 f5 ff ff       	call   801418 <read>
	if (r < 0)
  801ea1:	83 c4 10             	add    $0x10,%esp
  801ea4:	85 c0                	test   %eax,%eax
  801ea6:	78 0f                	js     801eb7 <getchar+0x29>
		return r;
	if (r < 1)
  801ea8:	85 c0                	test   %eax,%eax
  801eaa:	7e 06                	jle    801eb2 <getchar+0x24>
		return -E_EOF;
	return c;
  801eac:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801eb0:	eb 05                	jmp    801eb7 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801eb2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801eb7:	c9                   	leave  
  801eb8:	c3                   	ret    

00801eb9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801eb9:	55                   	push   %ebp
  801eba:	89 e5                	mov    %esp,%ebp
  801ebc:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ebf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ec2:	50                   	push   %eax
  801ec3:	ff 75 08             	pushl  0x8(%ebp)
  801ec6:	e8 e7 f2 ff ff       	call   8011b2 <fd_lookup>
  801ecb:	83 c4 10             	add    $0x10,%esp
  801ece:	85 c0                	test   %eax,%eax
  801ed0:	78 11                	js     801ee3 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801edb:	39 10                	cmp    %edx,(%eax)
  801edd:	0f 94 c0             	sete   %al
  801ee0:	0f b6 c0             	movzbl %al,%eax
}
  801ee3:	c9                   	leave  
  801ee4:	c3                   	ret    

00801ee5 <opencons>:

int
opencons(void)
{
  801ee5:	55                   	push   %ebp
  801ee6:	89 e5                	mov    %esp,%ebp
  801ee8:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eeb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eee:	50                   	push   %eax
  801eef:	e8 6f f2 ff ff       	call   801163 <fd_alloc>
  801ef4:	83 c4 10             	add    $0x10,%esp
		return r;
  801ef7:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ef9:	85 c0                	test   %eax,%eax
  801efb:	78 3e                	js     801f3b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801efd:	83 ec 04             	sub    $0x4,%esp
  801f00:	68 07 04 00 00       	push   $0x407
  801f05:	ff 75 f4             	pushl  -0xc(%ebp)
  801f08:	6a 00                	push   $0x0
  801f0a:	e8 08 ed ff ff       	call   800c17 <sys_page_alloc>
  801f0f:	83 c4 10             	add    $0x10,%esp
		return r;
  801f12:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f14:	85 c0                	test   %eax,%eax
  801f16:	78 23                	js     801f3b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f18:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f21:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f26:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f2d:	83 ec 0c             	sub    $0xc,%esp
  801f30:	50                   	push   %eax
  801f31:	e8 06 f2 ff ff       	call   80113c <fd2num>
  801f36:	89 c2                	mov    %eax,%edx
  801f38:	83 c4 10             	add    $0x10,%esp
}
  801f3b:	89 d0                	mov    %edx,%eax
  801f3d:	c9                   	leave  
  801f3e:	c3                   	ret    

00801f3f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f3f:	55                   	push   %ebp
  801f40:	89 e5                	mov    %esp,%ebp
  801f42:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f45:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801f4c:	75 2a                	jne    801f78 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801f4e:	83 ec 04             	sub    $0x4,%esp
  801f51:	6a 07                	push   $0x7
  801f53:	68 00 f0 bf ee       	push   $0xeebff000
  801f58:	6a 00                	push   $0x0
  801f5a:	e8 b8 ec ff ff       	call   800c17 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801f5f:	83 c4 10             	add    $0x10,%esp
  801f62:	85 c0                	test   %eax,%eax
  801f64:	79 12                	jns    801f78 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801f66:	50                   	push   %eax
  801f67:	68 16 24 80 00       	push   $0x802416
  801f6c:	6a 23                	push   $0x23
  801f6e:	68 d6 28 80 00       	push   $0x8028d6
  801f73:	e8 3e e2 ff ff       	call   8001b6 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f78:	8b 45 08             	mov    0x8(%ebp),%eax
  801f7b:	a3 00 80 80 00       	mov    %eax,0x808000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801f80:	83 ec 08             	sub    $0x8,%esp
  801f83:	68 aa 1f 80 00       	push   $0x801faa
  801f88:	6a 00                	push   $0x0
  801f8a:	e8 d3 ed ff ff       	call   800d62 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801f8f:	83 c4 10             	add    $0x10,%esp
  801f92:	85 c0                	test   %eax,%eax
  801f94:	79 12                	jns    801fa8 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801f96:	50                   	push   %eax
  801f97:	68 16 24 80 00       	push   $0x802416
  801f9c:	6a 2c                	push   $0x2c
  801f9e:	68 d6 28 80 00       	push   $0x8028d6
  801fa3:	e8 0e e2 ff ff       	call   8001b6 <_panic>
	}
}
  801fa8:	c9                   	leave  
  801fa9:	c3                   	ret    

00801faa <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801faa:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fab:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  801fb0:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fb2:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801fb5:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801fb9:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801fbe:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801fc2:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801fc4:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801fc7:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801fc8:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801fcb:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801fcc:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801fcd:	c3                   	ret    

00801fce <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fce:	55                   	push   %ebp
  801fcf:	89 e5                	mov    %esp,%ebp
  801fd1:	56                   	push   %esi
  801fd2:	53                   	push   %ebx
  801fd3:	8b 75 08             	mov    0x8(%ebp),%esi
  801fd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fd9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801fdc:	85 c0                	test   %eax,%eax
  801fde:	75 12                	jne    801ff2 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801fe0:	83 ec 0c             	sub    $0xc,%esp
  801fe3:	68 00 00 c0 ee       	push   $0xeec00000
  801fe8:	e8 da ed ff ff       	call   800dc7 <sys_ipc_recv>
  801fed:	83 c4 10             	add    $0x10,%esp
  801ff0:	eb 0c                	jmp    801ffe <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801ff2:	83 ec 0c             	sub    $0xc,%esp
  801ff5:	50                   	push   %eax
  801ff6:	e8 cc ed ff ff       	call   800dc7 <sys_ipc_recv>
  801ffb:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801ffe:	85 f6                	test   %esi,%esi
  802000:	0f 95 c1             	setne  %cl
  802003:	85 db                	test   %ebx,%ebx
  802005:	0f 95 c2             	setne  %dl
  802008:	84 d1                	test   %dl,%cl
  80200a:	74 09                	je     802015 <ipc_recv+0x47>
  80200c:	89 c2                	mov    %eax,%edx
  80200e:	c1 ea 1f             	shr    $0x1f,%edx
  802011:	84 d2                	test   %dl,%dl
  802013:	75 2d                	jne    802042 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802015:	85 f6                	test   %esi,%esi
  802017:	74 0d                	je     802026 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802019:	a1 20 60 80 00       	mov    0x806020,%eax
  80201e:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  802024:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802026:	85 db                	test   %ebx,%ebx
  802028:	74 0d                	je     802037 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80202a:	a1 20 60 80 00       	mov    0x806020,%eax
  80202f:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  802035:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802037:	a1 20 60 80 00       	mov    0x806020,%eax
  80203c:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  802042:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802045:	5b                   	pop    %ebx
  802046:	5e                   	pop    %esi
  802047:	5d                   	pop    %ebp
  802048:	c3                   	ret    

00802049 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802049:	55                   	push   %ebp
  80204a:	89 e5                	mov    %esp,%ebp
  80204c:	57                   	push   %edi
  80204d:	56                   	push   %esi
  80204e:	53                   	push   %ebx
  80204f:	83 ec 0c             	sub    $0xc,%esp
  802052:	8b 7d 08             	mov    0x8(%ebp),%edi
  802055:	8b 75 0c             	mov    0xc(%ebp),%esi
  802058:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80205b:	85 db                	test   %ebx,%ebx
  80205d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802062:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802065:	ff 75 14             	pushl  0x14(%ebp)
  802068:	53                   	push   %ebx
  802069:	56                   	push   %esi
  80206a:	57                   	push   %edi
  80206b:	e8 34 ed ff ff       	call   800da4 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802070:	89 c2                	mov    %eax,%edx
  802072:	c1 ea 1f             	shr    $0x1f,%edx
  802075:	83 c4 10             	add    $0x10,%esp
  802078:	84 d2                	test   %dl,%dl
  80207a:	74 17                	je     802093 <ipc_send+0x4a>
  80207c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80207f:	74 12                	je     802093 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802081:	50                   	push   %eax
  802082:	68 e4 28 80 00       	push   $0x8028e4
  802087:	6a 47                	push   $0x47
  802089:	68 f2 28 80 00       	push   $0x8028f2
  80208e:	e8 23 e1 ff ff       	call   8001b6 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802093:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802096:	75 07                	jne    80209f <ipc_send+0x56>
			sys_yield();
  802098:	e8 5b eb ff ff       	call   800bf8 <sys_yield>
  80209d:	eb c6                	jmp    802065 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80209f:	85 c0                	test   %eax,%eax
  8020a1:	75 c2                	jne    802065 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8020a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020a6:	5b                   	pop    %ebx
  8020a7:	5e                   	pop    %esi
  8020a8:	5f                   	pop    %edi
  8020a9:	5d                   	pop    %ebp
  8020aa:	c3                   	ret    

008020ab <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020ab:	55                   	push   %ebp
  8020ac:	89 e5                	mov    %esp,%ebp
  8020ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020b1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020b6:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  8020bc:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020c2:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  8020c8:	39 ca                	cmp    %ecx,%edx
  8020ca:	75 10                	jne    8020dc <ipc_find_env+0x31>
			return envs[i].env_id;
  8020cc:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  8020d2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020d7:	8b 40 7c             	mov    0x7c(%eax),%eax
  8020da:	eb 0f                	jmp    8020eb <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020dc:	83 c0 01             	add    $0x1,%eax
  8020df:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020e4:	75 d0                	jne    8020b6 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020eb:	5d                   	pop    %ebp
  8020ec:	c3                   	ret    

008020ed <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020ed:	55                   	push   %ebp
  8020ee:	89 e5                	mov    %esp,%ebp
  8020f0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020f3:	89 d0                	mov    %edx,%eax
  8020f5:	c1 e8 16             	shr    $0x16,%eax
  8020f8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020ff:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802104:	f6 c1 01             	test   $0x1,%cl
  802107:	74 1d                	je     802126 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802109:	c1 ea 0c             	shr    $0xc,%edx
  80210c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802113:	f6 c2 01             	test   $0x1,%dl
  802116:	74 0e                	je     802126 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802118:	c1 ea 0c             	shr    $0xc,%edx
  80211b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802122:	ef 
  802123:	0f b7 c0             	movzwl %ax,%eax
}
  802126:	5d                   	pop    %ebp
  802127:	c3                   	ret    
  802128:	66 90                	xchg   %ax,%ax
  80212a:	66 90                	xchg   %ax,%ax
  80212c:	66 90                	xchg   %ax,%ax
  80212e:	66 90                	xchg   %ax,%ax

00802130 <__udivdi3>:
  802130:	55                   	push   %ebp
  802131:	57                   	push   %edi
  802132:	56                   	push   %esi
  802133:	53                   	push   %ebx
  802134:	83 ec 1c             	sub    $0x1c,%esp
  802137:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80213b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80213f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802143:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802147:	85 f6                	test   %esi,%esi
  802149:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80214d:	89 ca                	mov    %ecx,%edx
  80214f:	89 f8                	mov    %edi,%eax
  802151:	75 3d                	jne    802190 <__udivdi3+0x60>
  802153:	39 cf                	cmp    %ecx,%edi
  802155:	0f 87 c5 00 00 00    	ja     802220 <__udivdi3+0xf0>
  80215b:	85 ff                	test   %edi,%edi
  80215d:	89 fd                	mov    %edi,%ebp
  80215f:	75 0b                	jne    80216c <__udivdi3+0x3c>
  802161:	b8 01 00 00 00       	mov    $0x1,%eax
  802166:	31 d2                	xor    %edx,%edx
  802168:	f7 f7                	div    %edi
  80216a:	89 c5                	mov    %eax,%ebp
  80216c:	89 c8                	mov    %ecx,%eax
  80216e:	31 d2                	xor    %edx,%edx
  802170:	f7 f5                	div    %ebp
  802172:	89 c1                	mov    %eax,%ecx
  802174:	89 d8                	mov    %ebx,%eax
  802176:	89 cf                	mov    %ecx,%edi
  802178:	f7 f5                	div    %ebp
  80217a:	89 c3                	mov    %eax,%ebx
  80217c:	89 d8                	mov    %ebx,%eax
  80217e:	89 fa                	mov    %edi,%edx
  802180:	83 c4 1c             	add    $0x1c,%esp
  802183:	5b                   	pop    %ebx
  802184:	5e                   	pop    %esi
  802185:	5f                   	pop    %edi
  802186:	5d                   	pop    %ebp
  802187:	c3                   	ret    
  802188:	90                   	nop
  802189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802190:	39 ce                	cmp    %ecx,%esi
  802192:	77 74                	ja     802208 <__udivdi3+0xd8>
  802194:	0f bd fe             	bsr    %esi,%edi
  802197:	83 f7 1f             	xor    $0x1f,%edi
  80219a:	0f 84 98 00 00 00    	je     802238 <__udivdi3+0x108>
  8021a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021a5:	89 f9                	mov    %edi,%ecx
  8021a7:	89 c5                	mov    %eax,%ebp
  8021a9:	29 fb                	sub    %edi,%ebx
  8021ab:	d3 e6                	shl    %cl,%esi
  8021ad:	89 d9                	mov    %ebx,%ecx
  8021af:	d3 ed                	shr    %cl,%ebp
  8021b1:	89 f9                	mov    %edi,%ecx
  8021b3:	d3 e0                	shl    %cl,%eax
  8021b5:	09 ee                	or     %ebp,%esi
  8021b7:	89 d9                	mov    %ebx,%ecx
  8021b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021bd:	89 d5                	mov    %edx,%ebp
  8021bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021c3:	d3 ed                	shr    %cl,%ebp
  8021c5:	89 f9                	mov    %edi,%ecx
  8021c7:	d3 e2                	shl    %cl,%edx
  8021c9:	89 d9                	mov    %ebx,%ecx
  8021cb:	d3 e8                	shr    %cl,%eax
  8021cd:	09 c2                	or     %eax,%edx
  8021cf:	89 d0                	mov    %edx,%eax
  8021d1:	89 ea                	mov    %ebp,%edx
  8021d3:	f7 f6                	div    %esi
  8021d5:	89 d5                	mov    %edx,%ebp
  8021d7:	89 c3                	mov    %eax,%ebx
  8021d9:	f7 64 24 0c          	mull   0xc(%esp)
  8021dd:	39 d5                	cmp    %edx,%ebp
  8021df:	72 10                	jb     8021f1 <__udivdi3+0xc1>
  8021e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021e5:	89 f9                	mov    %edi,%ecx
  8021e7:	d3 e6                	shl    %cl,%esi
  8021e9:	39 c6                	cmp    %eax,%esi
  8021eb:	73 07                	jae    8021f4 <__udivdi3+0xc4>
  8021ed:	39 d5                	cmp    %edx,%ebp
  8021ef:	75 03                	jne    8021f4 <__udivdi3+0xc4>
  8021f1:	83 eb 01             	sub    $0x1,%ebx
  8021f4:	31 ff                	xor    %edi,%edi
  8021f6:	89 d8                	mov    %ebx,%eax
  8021f8:	89 fa                	mov    %edi,%edx
  8021fa:	83 c4 1c             	add    $0x1c,%esp
  8021fd:	5b                   	pop    %ebx
  8021fe:	5e                   	pop    %esi
  8021ff:	5f                   	pop    %edi
  802200:	5d                   	pop    %ebp
  802201:	c3                   	ret    
  802202:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802208:	31 ff                	xor    %edi,%edi
  80220a:	31 db                	xor    %ebx,%ebx
  80220c:	89 d8                	mov    %ebx,%eax
  80220e:	89 fa                	mov    %edi,%edx
  802210:	83 c4 1c             	add    $0x1c,%esp
  802213:	5b                   	pop    %ebx
  802214:	5e                   	pop    %esi
  802215:	5f                   	pop    %edi
  802216:	5d                   	pop    %ebp
  802217:	c3                   	ret    
  802218:	90                   	nop
  802219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802220:	89 d8                	mov    %ebx,%eax
  802222:	f7 f7                	div    %edi
  802224:	31 ff                	xor    %edi,%edi
  802226:	89 c3                	mov    %eax,%ebx
  802228:	89 d8                	mov    %ebx,%eax
  80222a:	89 fa                	mov    %edi,%edx
  80222c:	83 c4 1c             	add    $0x1c,%esp
  80222f:	5b                   	pop    %ebx
  802230:	5e                   	pop    %esi
  802231:	5f                   	pop    %edi
  802232:	5d                   	pop    %ebp
  802233:	c3                   	ret    
  802234:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802238:	39 ce                	cmp    %ecx,%esi
  80223a:	72 0c                	jb     802248 <__udivdi3+0x118>
  80223c:	31 db                	xor    %ebx,%ebx
  80223e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802242:	0f 87 34 ff ff ff    	ja     80217c <__udivdi3+0x4c>
  802248:	bb 01 00 00 00       	mov    $0x1,%ebx
  80224d:	e9 2a ff ff ff       	jmp    80217c <__udivdi3+0x4c>
  802252:	66 90                	xchg   %ax,%ax
  802254:	66 90                	xchg   %ax,%ax
  802256:	66 90                	xchg   %ax,%ax
  802258:	66 90                	xchg   %ax,%ax
  80225a:	66 90                	xchg   %ax,%ax
  80225c:	66 90                	xchg   %ax,%ax
  80225e:	66 90                	xchg   %ax,%ax

00802260 <__umoddi3>:
  802260:	55                   	push   %ebp
  802261:	57                   	push   %edi
  802262:	56                   	push   %esi
  802263:	53                   	push   %ebx
  802264:	83 ec 1c             	sub    $0x1c,%esp
  802267:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80226b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80226f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802273:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802277:	85 d2                	test   %edx,%edx
  802279:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80227d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802281:	89 f3                	mov    %esi,%ebx
  802283:	89 3c 24             	mov    %edi,(%esp)
  802286:	89 74 24 04          	mov    %esi,0x4(%esp)
  80228a:	75 1c                	jne    8022a8 <__umoddi3+0x48>
  80228c:	39 f7                	cmp    %esi,%edi
  80228e:	76 50                	jbe    8022e0 <__umoddi3+0x80>
  802290:	89 c8                	mov    %ecx,%eax
  802292:	89 f2                	mov    %esi,%edx
  802294:	f7 f7                	div    %edi
  802296:	89 d0                	mov    %edx,%eax
  802298:	31 d2                	xor    %edx,%edx
  80229a:	83 c4 1c             	add    $0x1c,%esp
  80229d:	5b                   	pop    %ebx
  80229e:	5e                   	pop    %esi
  80229f:	5f                   	pop    %edi
  8022a0:	5d                   	pop    %ebp
  8022a1:	c3                   	ret    
  8022a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022a8:	39 f2                	cmp    %esi,%edx
  8022aa:	89 d0                	mov    %edx,%eax
  8022ac:	77 52                	ja     802300 <__umoddi3+0xa0>
  8022ae:	0f bd ea             	bsr    %edx,%ebp
  8022b1:	83 f5 1f             	xor    $0x1f,%ebp
  8022b4:	75 5a                	jne    802310 <__umoddi3+0xb0>
  8022b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022ba:	0f 82 e0 00 00 00    	jb     8023a0 <__umoddi3+0x140>
  8022c0:	39 0c 24             	cmp    %ecx,(%esp)
  8022c3:	0f 86 d7 00 00 00    	jbe    8023a0 <__umoddi3+0x140>
  8022c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022d1:	83 c4 1c             	add    $0x1c,%esp
  8022d4:	5b                   	pop    %ebx
  8022d5:	5e                   	pop    %esi
  8022d6:	5f                   	pop    %edi
  8022d7:	5d                   	pop    %ebp
  8022d8:	c3                   	ret    
  8022d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022e0:	85 ff                	test   %edi,%edi
  8022e2:	89 fd                	mov    %edi,%ebp
  8022e4:	75 0b                	jne    8022f1 <__umoddi3+0x91>
  8022e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022eb:	31 d2                	xor    %edx,%edx
  8022ed:	f7 f7                	div    %edi
  8022ef:	89 c5                	mov    %eax,%ebp
  8022f1:	89 f0                	mov    %esi,%eax
  8022f3:	31 d2                	xor    %edx,%edx
  8022f5:	f7 f5                	div    %ebp
  8022f7:	89 c8                	mov    %ecx,%eax
  8022f9:	f7 f5                	div    %ebp
  8022fb:	89 d0                	mov    %edx,%eax
  8022fd:	eb 99                	jmp    802298 <__umoddi3+0x38>
  8022ff:	90                   	nop
  802300:	89 c8                	mov    %ecx,%eax
  802302:	89 f2                	mov    %esi,%edx
  802304:	83 c4 1c             	add    $0x1c,%esp
  802307:	5b                   	pop    %ebx
  802308:	5e                   	pop    %esi
  802309:	5f                   	pop    %edi
  80230a:	5d                   	pop    %ebp
  80230b:	c3                   	ret    
  80230c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802310:	8b 34 24             	mov    (%esp),%esi
  802313:	bf 20 00 00 00       	mov    $0x20,%edi
  802318:	89 e9                	mov    %ebp,%ecx
  80231a:	29 ef                	sub    %ebp,%edi
  80231c:	d3 e0                	shl    %cl,%eax
  80231e:	89 f9                	mov    %edi,%ecx
  802320:	89 f2                	mov    %esi,%edx
  802322:	d3 ea                	shr    %cl,%edx
  802324:	89 e9                	mov    %ebp,%ecx
  802326:	09 c2                	or     %eax,%edx
  802328:	89 d8                	mov    %ebx,%eax
  80232a:	89 14 24             	mov    %edx,(%esp)
  80232d:	89 f2                	mov    %esi,%edx
  80232f:	d3 e2                	shl    %cl,%edx
  802331:	89 f9                	mov    %edi,%ecx
  802333:	89 54 24 04          	mov    %edx,0x4(%esp)
  802337:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80233b:	d3 e8                	shr    %cl,%eax
  80233d:	89 e9                	mov    %ebp,%ecx
  80233f:	89 c6                	mov    %eax,%esi
  802341:	d3 e3                	shl    %cl,%ebx
  802343:	89 f9                	mov    %edi,%ecx
  802345:	89 d0                	mov    %edx,%eax
  802347:	d3 e8                	shr    %cl,%eax
  802349:	89 e9                	mov    %ebp,%ecx
  80234b:	09 d8                	or     %ebx,%eax
  80234d:	89 d3                	mov    %edx,%ebx
  80234f:	89 f2                	mov    %esi,%edx
  802351:	f7 34 24             	divl   (%esp)
  802354:	89 d6                	mov    %edx,%esi
  802356:	d3 e3                	shl    %cl,%ebx
  802358:	f7 64 24 04          	mull   0x4(%esp)
  80235c:	39 d6                	cmp    %edx,%esi
  80235e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802362:	89 d1                	mov    %edx,%ecx
  802364:	89 c3                	mov    %eax,%ebx
  802366:	72 08                	jb     802370 <__umoddi3+0x110>
  802368:	75 11                	jne    80237b <__umoddi3+0x11b>
  80236a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80236e:	73 0b                	jae    80237b <__umoddi3+0x11b>
  802370:	2b 44 24 04          	sub    0x4(%esp),%eax
  802374:	1b 14 24             	sbb    (%esp),%edx
  802377:	89 d1                	mov    %edx,%ecx
  802379:	89 c3                	mov    %eax,%ebx
  80237b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80237f:	29 da                	sub    %ebx,%edx
  802381:	19 ce                	sbb    %ecx,%esi
  802383:	89 f9                	mov    %edi,%ecx
  802385:	89 f0                	mov    %esi,%eax
  802387:	d3 e0                	shl    %cl,%eax
  802389:	89 e9                	mov    %ebp,%ecx
  80238b:	d3 ea                	shr    %cl,%edx
  80238d:	89 e9                	mov    %ebp,%ecx
  80238f:	d3 ee                	shr    %cl,%esi
  802391:	09 d0                	or     %edx,%eax
  802393:	89 f2                	mov    %esi,%edx
  802395:	83 c4 1c             	add    $0x1c,%esp
  802398:	5b                   	pop    %ebx
  802399:	5e                   	pop    %esi
  80239a:	5f                   	pop    %edi
  80239b:	5d                   	pop    %ebp
  80239c:	c3                   	ret    
  80239d:	8d 76 00             	lea    0x0(%esi),%esi
  8023a0:	29 f9                	sub    %edi,%ecx
  8023a2:	19 d6                	sbb    %edx,%esi
  8023a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023ac:	e9 18 ff ff ff       	jmp    8022c9 <__umoddi3+0x69>
