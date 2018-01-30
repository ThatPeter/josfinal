
obj/user/testpteshare.debug:     file format elf32-i386


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
  80002c:	e8 47 01 00 00       	call   800178 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	strcpy(VA, msg2);
  800039:	ff 35 00 40 80 00    	pushl  0x804000
  80003f:	68 00 00 00 a0       	push   $0xa0000000
  800044:	e8 10 08 00 00       	call   800859 <strcpy>
	exit();
  800049:	e8 93 01 00 00       	call   8001e1 <exit>
}
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	c9                   	leave  
  800052:	c3                   	ret    

00800053 <umain>:

void childofspawn(void);

void
umain(int argc, char **argv)
{
  800053:	55                   	push   %ebp
  800054:	89 e5                	mov    %esp,%ebp
  800056:	53                   	push   %ebx
  800057:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (argc != 0)
  80005a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80005e:	74 05                	je     800065 <umain+0x12>
		childofspawn();
  800060:	e8 ce ff ff ff       	call   800033 <childofspawn>

	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800065:	83 ec 04             	sub    $0x4,%esp
  800068:	68 07 04 00 00       	push   $0x407
  80006d:	68 00 00 00 a0       	push   $0xa0000000
  800072:	6a 00                	push   $0x0
  800074:	e8 e3 0b 00 00       	call   800c5c <sys_page_alloc>
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	85 c0                	test   %eax,%eax
  80007e:	79 12                	jns    800092 <umain+0x3f>
		panic("sys_page_alloc: %e", r);
  800080:	50                   	push   %eax
  800081:	68 6c 2b 80 00       	push   $0x802b6c
  800086:	6a 13                	push   $0x13
  800088:	68 7f 2b 80 00       	push   $0x802b7f
  80008d:	e8 69 01 00 00       	call   8001fb <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 ec 0e 00 00       	call   800f83 <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 93 2b 80 00       	push   $0x802b93
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 7f 2b 80 00       	push   $0x802b7f
  8000aa:	e8 4c 01 00 00       	call   8001fb <_panic>
	if (r == 0) {
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	75 1b                	jne    8000ce <umain+0x7b>
		strcpy(VA, msg);
  8000b3:	83 ec 08             	sub    $0x8,%esp
  8000b6:	ff 35 04 40 80 00    	pushl  0x804004
  8000bc:	68 00 00 00 a0       	push   $0xa0000000
  8000c1:	e8 93 07 00 00       	call   800859 <strcpy>
		exit();
  8000c6:	e8 16 01 00 00       	call   8001e1 <exit>
  8000cb:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	53                   	push   %ebx
  8000d2:	e8 31 24 00 00       	call   802508 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 40 80 00    	pushl  0x804004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 19 08 00 00       	call   800903 <strcmp>
  8000ea:	83 c4 08             	add    $0x8,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	ba 66 2b 80 00       	mov    $0x802b66,%edx
  8000f4:	b8 60 2b 80 00       	mov    $0x802b60,%eax
  8000f9:	0f 45 c2             	cmovne %edx,%eax
  8000fc:	50                   	push   %eax
  8000fd:	68 9c 2b 80 00       	push   $0x802b9c
  800102:	e8 cd 01 00 00       	call   8002d4 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800107:	6a 00                	push   $0x0
  800109:	68 b7 2b 80 00       	push   $0x802bb7
  80010e:	68 bc 2b 80 00       	push   $0x802bbc
  800113:	68 bb 2b 80 00       	push   $0x802bbb
  800118:	e8 13 20 00 00       	call   802130 <spawnl>
  80011d:	83 c4 20             	add    $0x20,%esp
  800120:	85 c0                	test   %eax,%eax
  800122:	79 12                	jns    800136 <umain+0xe3>
		panic("spawn: %e", r);
  800124:	50                   	push   %eax
  800125:	68 c9 2b 80 00       	push   $0x802bc9
  80012a:	6a 21                	push   $0x21
  80012c:	68 7f 2b 80 00       	push   $0x802b7f
  800131:	e8 c5 00 00 00       	call   8001fb <_panic>
	wait(r);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	e8 c9 23 00 00       	call   802508 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff 35 00 40 80 00    	pushl  0x804000
  800148:	68 00 00 00 a0       	push   $0xa0000000
  80014d:	e8 b1 07 00 00       	call   800903 <strcmp>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba 66 2b 80 00       	mov    $0x802b66,%edx
  80015c:	b8 60 2b 80 00       	mov    $0x802b60,%eax
  800161:	0f 45 c2             	cmovne %edx,%eax
  800164:	50                   	push   %eax
  800165:	68 d3 2b 80 00       	push   $0x802bd3
  80016a:	e8 65 01 00 00       	call   8002d4 <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  80016f:	cc                   	int3   

	breakpoint();
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	56                   	push   %esi
  80017c:	53                   	push   %ebx
  80017d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800180:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800183:	e8 96 0a 00 00       	call   800c1e <sys_getenvid>
  800188:	25 ff 03 00 00       	and    $0x3ff,%eax
  80018d:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800193:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800198:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80019d:	85 db                	test   %ebx,%ebx
  80019f:	7e 07                	jle    8001a8 <libmain+0x30>
		binaryname = argv[0];
  8001a1:	8b 06                	mov    (%esi),%eax
  8001a3:	a3 08 40 80 00       	mov    %eax,0x804008

	// call user main routine
	umain(argc, argv);
  8001a8:	83 ec 08             	sub    $0x8,%esp
  8001ab:	56                   	push   %esi
  8001ac:	53                   	push   %ebx
  8001ad:	e8 a1 fe ff ff       	call   800053 <umain>

	// exit gracefully
	exit();
  8001b2:	e8 2a 00 00 00       	call   8001e1 <exit>
}
  8001b7:	83 c4 10             	add    $0x10,%esp
  8001ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001bd:	5b                   	pop    %ebx
  8001be:	5e                   	pop    %esi
  8001bf:	5d                   	pop    %ebp
  8001c0:	c3                   	ret    

008001c1 <thread_main>:

/*Lab 7: Multithreading thread main routine*/
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  8001c1:	55                   	push   %ebp
  8001c2:	89 e5                	mov    %esp,%ebp
  8001c4:	83 ec 08             	sub    $0x8,%esp
	void (*func)(void) = (void (*)(void))eip;
  8001c7:	a1 08 50 80 00       	mov    0x805008,%eax
	func();
  8001cc:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8001ce:	e8 4b 0a 00 00       	call   800c1e <sys_getenvid>
  8001d3:	83 ec 0c             	sub    $0xc,%esp
  8001d6:	50                   	push   %eax
  8001d7:	e8 91 0c 00 00       	call   800e6d <sys_thread_free>
}
  8001dc:	83 c4 10             	add    $0x10,%esp
  8001df:	c9                   	leave  
  8001e0:	c3                   	ret    

008001e1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001e1:	55                   	push   %ebp
  8001e2:	89 e5                	mov    %esp,%ebp
  8001e4:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001e7:	e8 89 13 00 00       	call   801575 <close_all>
	sys_env_destroy(0);
  8001ec:	83 ec 0c             	sub    $0xc,%esp
  8001ef:	6a 00                	push   $0x0
  8001f1:	e8 e7 09 00 00       	call   800bdd <sys_env_destroy>
}
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	c9                   	leave  
  8001fa:	c3                   	ret    

008001fb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001fb:	55                   	push   %ebp
  8001fc:	89 e5                	mov    %esp,%ebp
  8001fe:	56                   	push   %esi
  8001ff:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800200:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800203:	8b 35 08 40 80 00    	mov    0x804008,%esi
  800209:	e8 10 0a 00 00       	call   800c1e <sys_getenvid>
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	ff 75 0c             	pushl  0xc(%ebp)
  800214:	ff 75 08             	pushl  0x8(%ebp)
  800217:	56                   	push   %esi
  800218:	50                   	push   %eax
  800219:	68 18 2c 80 00       	push   $0x802c18
  80021e:	e8 b1 00 00 00       	call   8002d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800223:	83 c4 18             	add    $0x18,%esp
  800226:	53                   	push   %ebx
  800227:	ff 75 10             	pushl  0x10(%ebp)
  80022a:	e8 54 00 00 00       	call   800283 <vcprintf>
	cprintf("\n");
  80022f:	c7 04 24 db 2f 80 00 	movl   $0x802fdb,(%esp)
  800236:	e8 99 00 00 00       	call   8002d4 <cprintf>
  80023b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80023e:	cc                   	int3   
  80023f:	eb fd                	jmp    80023e <_panic+0x43>

00800241 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800241:	55                   	push   %ebp
  800242:	89 e5                	mov    %esp,%ebp
  800244:	53                   	push   %ebx
  800245:	83 ec 04             	sub    $0x4,%esp
  800248:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80024b:	8b 13                	mov    (%ebx),%edx
  80024d:	8d 42 01             	lea    0x1(%edx),%eax
  800250:	89 03                	mov    %eax,(%ebx)
  800252:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800255:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800259:	3d ff 00 00 00       	cmp    $0xff,%eax
  80025e:	75 1a                	jne    80027a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800260:	83 ec 08             	sub    $0x8,%esp
  800263:	68 ff 00 00 00       	push   $0xff
  800268:	8d 43 08             	lea    0x8(%ebx),%eax
  80026b:	50                   	push   %eax
  80026c:	e8 2f 09 00 00       	call   800ba0 <sys_cputs>
		b->idx = 0;
  800271:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800277:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80027a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80027e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800281:	c9                   	leave  
  800282:	c3                   	ret    

00800283 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
  800286:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80028c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800293:	00 00 00 
	b.cnt = 0;
  800296:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80029d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002a0:	ff 75 0c             	pushl  0xc(%ebp)
  8002a3:	ff 75 08             	pushl  0x8(%ebp)
  8002a6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002ac:	50                   	push   %eax
  8002ad:	68 41 02 80 00       	push   $0x800241
  8002b2:	e8 54 01 00 00       	call   80040b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002b7:	83 c4 08             	add    $0x8,%esp
  8002ba:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002c0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002c6:	50                   	push   %eax
  8002c7:	e8 d4 08 00 00       	call   800ba0 <sys_cputs>

	return b.cnt;
}
  8002cc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002d2:	c9                   	leave  
  8002d3:	c3                   	ret    

008002d4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
  8002d7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002da:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002dd:	50                   	push   %eax
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	e8 9d ff ff ff       	call   800283 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002e6:	c9                   	leave  
  8002e7:	c3                   	ret    

008002e8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	57                   	push   %edi
  8002ec:	56                   	push   %esi
  8002ed:	53                   	push   %ebx
  8002ee:	83 ec 1c             	sub    $0x1c,%esp
  8002f1:	89 c7                	mov    %eax,%edi
  8002f3:	89 d6                	mov    %edx,%esi
  8002f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800301:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800304:	bb 00 00 00 00       	mov    $0x0,%ebx
  800309:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80030c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80030f:	39 d3                	cmp    %edx,%ebx
  800311:	72 05                	jb     800318 <printnum+0x30>
  800313:	39 45 10             	cmp    %eax,0x10(%ebp)
  800316:	77 45                	ja     80035d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800318:	83 ec 0c             	sub    $0xc,%esp
  80031b:	ff 75 18             	pushl  0x18(%ebp)
  80031e:	8b 45 14             	mov    0x14(%ebp),%eax
  800321:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800324:	53                   	push   %ebx
  800325:	ff 75 10             	pushl  0x10(%ebp)
  800328:	83 ec 08             	sub    $0x8,%esp
  80032b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80032e:	ff 75 e0             	pushl  -0x20(%ebp)
  800331:	ff 75 dc             	pushl  -0x24(%ebp)
  800334:	ff 75 d8             	pushl  -0x28(%ebp)
  800337:	e8 94 25 00 00       	call   8028d0 <__udivdi3>
  80033c:	83 c4 18             	add    $0x18,%esp
  80033f:	52                   	push   %edx
  800340:	50                   	push   %eax
  800341:	89 f2                	mov    %esi,%edx
  800343:	89 f8                	mov    %edi,%eax
  800345:	e8 9e ff ff ff       	call   8002e8 <printnum>
  80034a:	83 c4 20             	add    $0x20,%esp
  80034d:	eb 18                	jmp    800367 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80034f:	83 ec 08             	sub    $0x8,%esp
  800352:	56                   	push   %esi
  800353:	ff 75 18             	pushl  0x18(%ebp)
  800356:	ff d7                	call   *%edi
  800358:	83 c4 10             	add    $0x10,%esp
  80035b:	eb 03                	jmp    800360 <printnum+0x78>
  80035d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800360:	83 eb 01             	sub    $0x1,%ebx
  800363:	85 db                	test   %ebx,%ebx
  800365:	7f e8                	jg     80034f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800367:	83 ec 08             	sub    $0x8,%esp
  80036a:	56                   	push   %esi
  80036b:	83 ec 04             	sub    $0x4,%esp
  80036e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800371:	ff 75 e0             	pushl  -0x20(%ebp)
  800374:	ff 75 dc             	pushl  -0x24(%ebp)
  800377:	ff 75 d8             	pushl  -0x28(%ebp)
  80037a:	e8 81 26 00 00       	call   802a00 <__umoddi3>
  80037f:	83 c4 14             	add    $0x14,%esp
  800382:	0f be 80 3b 2c 80 00 	movsbl 0x802c3b(%eax),%eax
  800389:	50                   	push   %eax
  80038a:	ff d7                	call   *%edi
}
  80038c:	83 c4 10             	add    $0x10,%esp
  80038f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800392:	5b                   	pop    %ebx
  800393:	5e                   	pop    %esi
  800394:	5f                   	pop    %edi
  800395:	5d                   	pop    %ebp
  800396:	c3                   	ret    

00800397 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80039a:	83 fa 01             	cmp    $0x1,%edx
  80039d:	7e 0e                	jle    8003ad <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80039f:	8b 10                	mov    (%eax),%edx
  8003a1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003a4:	89 08                	mov    %ecx,(%eax)
  8003a6:	8b 02                	mov    (%edx),%eax
  8003a8:	8b 52 04             	mov    0x4(%edx),%edx
  8003ab:	eb 22                	jmp    8003cf <getuint+0x38>
	else if (lflag)
  8003ad:	85 d2                	test   %edx,%edx
  8003af:	74 10                	je     8003c1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003b1:	8b 10                	mov    (%eax),%edx
  8003b3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b6:	89 08                	mov    %ecx,(%eax)
  8003b8:	8b 02                	mov    (%edx),%eax
  8003ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8003bf:	eb 0e                	jmp    8003cf <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003c1:	8b 10                	mov    (%eax),%edx
  8003c3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c6:	89 08                	mov    %ecx,(%eax)
  8003c8:	8b 02                	mov    (%edx),%eax
  8003ca:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003cf:	5d                   	pop    %ebp
  8003d0:	c3                   	ret    

008003d1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003d7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003db:	8b 10                	mov    (%eax),%edx
  8003dd:	3b 50 04             	cmp    0x4(%eax),%edx
  8003e0:	73 0a                	jae    8003ec <sprintputch+0x1b>
		*b->buf++ = ch;
  8003e2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003e5:	89 08                	mov    %ecx,(%eax)
  8003e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ea:	88 02                	mov    %al,(%edx)
}
  8003ec:	5d                   	pop    %ebp
  8003ed:	c3                   	ret    

008003ee <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
  8003f1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003f4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003f7:	50                   	push   %eax
  8003f8:	ff 75 10             	pushl  0x10(%ebp)
  8003fb:	ff 75 0c             	pushl  0xc(%ebp)
  8003fe:	ff 75 08             	pushl  0x8(%ebp)
  800401:	e8 05 00 00 00       	call   80040b <vprintfmt>
	va_end(ap);
}
  800406:	83 c4 10             	add    $0x10,%esp
  800409:	c9                   	leave  
  80040a:	c3                   	ret    

0080040b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80040b:	55                   	push   %ebp
  80040c:	89 e5                	mov    %esp,%ebp
  80040e:	57                   	push   %edi
  80040f:	56                   	push   %esi
  800410:	53                   	push   %ebx
  800411:	83 ec 2c             	sub    $0x2c,%esp
  800414:	8b 75 08             	mov    0x8(%ebp),%esi
  800417:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80041a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80041d:	eb 12                	jmp    800431 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80041f:	85 c0                	test   %eax,%eax
  800421:	0f 84 89 03 00 00    	je     8007b0 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800427:	83 ec 08             	sub    $0x8,%esp
  80042a:	53                   	push   %ebx
  80042b:	50                   	push   %eax
  80042c:	ff d6                	call   *%esi
  80042e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800431:	83 c7 01             	add    $0x1,%edi
  800434:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800438:	83 f8 25             	cmp    $0x25,%eax
  80043b:	75 e2                	jne    80041f <vprintfmt+0x14>
  80043d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800441:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800448:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80044f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800456:	ba 00 00 00 00       	mov    $0x0,%edx
  80045b:	eb 07                	jmp    800464 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800460:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800464:	8d 47 01             	lea    0x1(%edi),%eax
  800467:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80046a:	0f b6 07             	movzbl (%edi),%eax
  80046d:	0f b6 c8             	movzbl %al,%ecx
  800470:	83 e8 23             	sub    $0x23,%eax
  800473:	3c 55                	cmp    $0x55,%al
  800475:	0f 87 1a 03 00 00    	ja     800795 <vprintfmt+0x38a>
  80047b:	0f b6 c0             	movzbl %al,%eax
  80047e:	ff 24 85 80 2d 80 00 	jmp    *0x802d80(,%eax,4)
  800485:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800488:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80048c:	eb d6                	jmp    800464 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800491:	b8 00 00 00 00       	mov    $0x0,%eax
  800496:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800499:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80049c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004a0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004a3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004a6:	83 fa 09             	cmp    $0x9,%edx
  8004a9:	77 39                	ja     8004e4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004ab:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004ae:	eb e9                	jmp    800499 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b3:	8d 48 04             	lea    0x4(%eax),%ecx
  8004b6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004b9:	8b 00                	mov    (%eax),%eax
  8004bb:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004c1:	eb 27                	jmp    8004ea <vprintfmt+0xdf>
  8004c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004c6:	85 c0                	test   %eax,%eax
  8004c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004cd:	0f 49 c8             	cmovns %eax,%ecx
  8004d0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d6:	eb 8c                	jmp    800464 <vprintfmt+0x59>
  8004d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004db:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004e2:	eb 80                	jmp    800464 <vprintfmt+0x59>
  8004e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004e7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004ea:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ee:	0f 89 70 ff ff ff    	jns    800464 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004f4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004fa:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800501:	e9 5e ff ff ff       	jmp    800464 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800506:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800509:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80050c:	e9 53 ff ff ff       	jmp    800464 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800511:	8b 45 14             	mov    0x14(%ebp),%eax
  800514:	8d 50 04             	lea    0x4(%eax),%edx
  800517:	89 55 14             	mov    %edx,0x14(%ebp)
  80051a:	83 ec 08             	sub    $0x8,%esp
  80051d:	53                   	push   %ebx
  80051e:	ff 30                	pushl  (%eax)
  800520:	ff d6                	call   *%esi
			break;
  800522:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800525:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800528:	e9 04 ff ff ff       	jmp    800431 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80052d:	8b 45 14             	mov    0x14(%ebp),%eax
  800530:	8d 50 04             	lea    0x4(%eax),%edx
  800533:	89 55 14             	mov    %edx,0x14(%ebp)
  800536:	8b 00                	mov    (%eax),%eax
  800538:	99                   	cltd   
  800539:	31 d0                	xor    %edx,%eax
  80053b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80053d:	83 f8 0f             	cmp    $0xf,%eax
  800540:	7f 0b                	jg     80054d <vprintfmt+0x142>
  800542:	8b 14 85 e0 2e 80 00 	mov    0x802ee0(,%eax,4),%edx
  800549:	85 d2                	test   %edx,%edx
  80054b:	75 18                	jne    800565 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80054d:	50                   	push   %eax
  80054e:	68 53 2c 80 00       	push   $0x802c53
  800553:	53                   	push   %ebx
  800554:	56                   	push   %esi
  800555:	e8 94 fe ff ff       	call   8003ee <printfmt>
  80055a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800560:	e9 cc fe ff ff       	jmp    800431 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800565:	52                   	push   %edx
  800566:	68 9d 30 80 00       	push   $0x80309d
  80056b:	53                   	push   %ebx
  80056c:	56                   	push   %esi
  80056d:	e8 7c fe ff ff       	call   8003ee <printfmt>
  800572:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800575:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800578:	e9 b4 fe ff ff       	jmp    800431 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80057d:	8b 45 14             	mov    0x14(%ebp),%eax
  800580:	8d 50 04             	lea    0x4(%eax),%edx
  800583:	89 55 14             	mov    %edx,0x14(%ebp)
  800586:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800588:	85 ff                	test   %edi,%edi
  80058a:	b8 4c 2c 80 00       	mov    $0x802c4c,%eax
  80058f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800592:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800596:	0f 8e 94 00 00 00    	jle    800630 <vprintfmt+0x225>
  80059c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005a0:	0f 84 98 00 00 00    	je     80063e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a6:	83 ec 08             	sub    $0x8,%esp
  8005a9:	ff 75 d0             	pushl  -0x30(%ebp)
  8005ac:	57                   	push   %edi
  8005ad:	e8 86 02 00 00       	call   800838 <strnlen>
  8005b2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005b5:	29 c1                	sub    %eax,%ecx
  8005b7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005ba:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005bd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005c4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005c7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c9:	eb 0f                	jmp    8005da <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005cb:	83 ec 08             	sub    $0x8,%esp
  8005ce:	53                   	push   %ebx
  8005cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8005d2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d4:	83 ef 01             	sub    $0x1,%edi
  8005d7:	83 c4 10             	add    $0x10,%esp
  8005da:	85 ff                	test   %edi,%edi
  8005dc:	7f ed                	jg     8005cb <vprintfmt+0x1c0>
  8005de:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005e1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005e4:	85 c9                	test   %ecx,%ecx
  8005e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8005eb:	0f 49 c1             	cmovns %ecx,%eax
  8005ee:	29 c1                	sub    %eax,%ecx
  8005f0:	89 75 08             	mov    %esi,0x8(%ebp)
  8005f3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005f6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f9:	89 cb                	mov    %ecx,%ebx
  8005fb:	eb 4d                	jmp    80064a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005fd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800601:	74 1b                	je     80061e <vprintfmt+0x213>
  800603:	0f be c0             	movsbl %al,%eax
  800606:	83 e8 20             	sub    $0x20,%eax
  800609:	83 f8 5e             	cmp    $0x5e,%eax
  80060c:	76 10                	jbe    80061e <vprintfmt+0x213>
					putch('?', putdat);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	ff 75 0c             	pushl  0xc(%ebp)
  800614:	6a 3f                	push   $0x3f
  800616:	ff 55 08             	call   *0x8(%ebp)
  800619:	83 c4 10             	add    $0x10,%esp
  80061c:	eb 0d                	jmp    80062b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80061e:	83 ec 08             	sub    $0x8,%esp
  800621:	ff 75 0c             	pushl  0xc(%ebp)
  800624:	52                   	push   %edx
  800625:	ff 55 08             	call   *0x8(%ebp)
  800628:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80062b:	83 eb 01             	sub    $0x1,%ebx
  80062e:	eb 1a                	jmp    80064a <vprintfmt+0x23f>
  800630:	89 75 08             	mov    %esi,0x8(%ebp)
  800633:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800636:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800639:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80063c:	eb 0c                	jmp    80064a <vprintfmt+0x23f>
  80063e:	89 75 08             	mov    %esi,0x8(%ebp)
  800641:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800644:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800647:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80064a:	83 c7 01             	add    $0x1,%edi
  80064d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800651:	0f be d0             	movsbl %al,%edx
  800654:	85 d2                	test   %edx,%edx
  800656:	74 23                	je     80067b <vprintfmt+0x270>
  800658:	85 f6                	test   %esi,%esi
  80065a:	78 a1                	js     8005fd <vprintfmt+0x1f2>
  80065c:	83 ee 01             	sub    $0x1,%esi
  80065f:	79 9c                	jns    8005fd <vprintfmt+0x1f2>
  800661:	89 df                	mov    %ebx,%edi
  800663:	8b 75 08             	mov    0x8(%ebp),%esi
  800666:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800669:	eb 18                	jmp    800683 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	53                   	push   %ebx
  80066f:	6a 20                	push   $0x20
  800671:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800673:	83 ef 01             	sub    $0x1,%edi
  800676:	83 c4 10             	add    $0x10,%esp
  800679:	eb 08                	jmp    800683 <vprintfmt+0x278>
  80067b:	89 df                	mov    %ebx,%edi
  80067d:	8b 75 08             	mov    0x8(%ebp),%esi
  800680:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800683:	85 ff                	test   %edi,%edi
  800685:	7f e4                	jg     80066b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800687:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80068a:	e9 a2 fd ff ff       	jmp    800431 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80068f:	83 fa 01             	cmp    $0x1,%edx
  800692:	7e 16                	jle    8006aa <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8d 50 08             	lea    0x8(%eax),%edx
  80069a:	89 55 14             	mov    %edx,0x14(%ebp)
  80069d:	8b 50 04             	mov    0x4(%eax),%edx
  8006a0:	8b 00                	mov    (%eax),%eax
  8006a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006a8:	eb 32                	jmp    8006dc <vprintfmt+0x2d1>
	else if (lflag)
  8006aa:	85 d2                	test   %edx,%edx
  8006ac:	74 18                	je     8006c6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b1:	8d 50 04             	lea    0x4(%eax),%edx
  8006b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b7:	8b 00                	mov    (%eax),%eax
  8006b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006bc:	89 c1                	mov    %eax,%ecx
  8006be:	c1 f9 1f             	sar    $0x1f,%ecx
  8006c1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006c4:	eb 16                	jmp    8006dc <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8d 50 04             	lea    0x4(%eax),%edx
  8006cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006cf:	8b 00                	mov    (%eax),%eax
  8006d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d4:	89 c1                	mov    %eax,%ecx
  8006d6:	c1 f9 1f             	sar    $0x1f,%ecx
  8006d9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006dc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006df:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006e2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006e7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006eb:	79 74                	jns    800761 <vprintfmt+0x356>
				putch('-', putdat);
  8006ed:	83 ec 08             	sub    $0x8,%esp
  8006f0:	53                   	push   %ebx
  8006f1:	6a 2d                	push   $0x2d
  8006f3:	ff d6                	call   *%esi
				num = -(long long) num;
  8006f5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006f8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006fb:	f7 d8                	neg    %eax
  8006fd:	83 d2 00             	adc    $0x0,%edx
  800700:	f7 da                	neg    %edx
  800702:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800705:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80070a:	eb 55                	jmp    800761 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80070c:	8d 45 14             	lea    0x14(%ebp),%eax
  80070f:	e8 83 fc ff ff       	call   800397 <getuint>
			base = 10;
  800714:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800719:	eb 46                	jmp    800761 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80071b:	8d 45 14             	lea    0x14(%ebp),%eax
  80071e:	e8 74 fc ff ff       	call   800397 <getuint>
			base = 8;
  800723:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800728:	eb 37                	jmp    800761 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80072a:	83 ec 08             	sub    $0x8,%esp
  80072d:	53                   	push   %ebx
  80072e:	6a 30                	push   $0x30
  800730:	ff d6                	call   *%esi
			putch('x', putdat);
  800732:	83 c4 08             	add    $0x8,%esp
  800735:	53                   	push   %ebx
  800736:	6a 78                	push   $0x78
  800738:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80073a:	8b 45 14             	mov    0x14(%ebp),%eax
  80073d:	8d 50 04             	lea    0x4(%eax),%edx
  800740:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800743:	8b 00                	mov    (%eax),%eax
  800745:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80074a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80074d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800752:	eb 0d                	jmp    800761 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800754:	8d 45 14             	lea    0x14(%ebp),%eax
  800757:	e8 3b fc ff ff       	call   800397 <getuint>
			base = 16;
  80075c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800761:	83 ec 0c             	sub    $0xc,%esp
  800764:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800768:	57                   	push   %edi
  800769:	ff 75 e0             	pushl  -0x20(%ebp)
  80076c:	51                   	push   %ecx
  80076d:	52                   	push   %edx
  80076e:	50                   	push   %eax
  80076f:	89 da                	mov    %ebx,%edx
  800771:	89 f0                	mov    %esi,%eax
  800773:	e8 70 fb ff ff       	call   8002e8 <printnum>
			break;
  800778:	83 c4 20             	add    $0x20,%esp
  80077b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80077e:	e9 ae fc ff ff       	jmp    800431 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800783:	83 ec 08             	sub    $0x8,%esp
  800786:	53                   	push   %ebx
  800787:	51                   	push   %ecx
  800788:	ff d6                	call   *%esi
			break;
  80078a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800790:	e9 9c fc ff ff       	jmp    800431 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800795:	83 ec 08             	sub    $0x8,%esp
  800798:	53                   	push   %ebx
  800799:	6a 25                	push   $0x25
  80079b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80079d:	83 c4 10             	add    $0x10,%esp
  8007a0:	eb 03                	jmp    8007a5 <vprintfmt+0x39a>
  8007a2:	83 ef 01             	sub    $0x1,%edi
  8007a5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007a9:	75 f7                	jne    8007a2 <vprintfmt+0x397>
  8007ab:	e9 81 fc ff ff       	jmp    800431 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007b3:	5b                   	pop    %ebx
  8007b4:	5e                   	pop    %esi
  8007b5:	5f                   	pop    %edi
  8007b6:	5d                   	pop    %ebp
  8007b7:	c3                   	ret    

008007b8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	83 ec 18             	sub    $0x18,%esp
  8007be:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007cb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007d5:	85 c0                	test   %eax,%eax
  8007d7:	74 26                	je     8007ff <vsnprintf+0x47>
  8007d9:	85 d2                	test   %edx,%edx
  8007db:	7e 22                	jle    8007ff <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007dd:	ff 75 14             	pushl  0x14(%ebp)
  8007e0:	ff 75 10             	pushl  0x10(%ebp)
  8007e3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e6:	50                   	push   %eax
  8007e7:	68 d1 03 80 00       	push   $0x8003d1
  8007ec:	e8 1a fc ff ff       	call   80040b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007f4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007fa:	83 c4 10             	add    $0x10,%esp
  8007fd:	eb 05                	jmp    800804 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800804:	c9                   	leave  
  800805:	c3                   	ret    

00800806 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80080c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80080f:	50                   	push   %eax
  800810:	ff 75 10             	pushl  0x10(%ebp)
  800813:	ff 75 0c             	pushl  0xc(%ebp)
  800816:	ff 75 08             	pushl  0x8(%ebp)
  800819:	e8 9a ff ff ff       	call   8007b8 <vsnprintf>
	va_end(ap);

	return rc;
}
  80081e:	c9                   	leave  
  80081f:	c3                   	ret    

00800820 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800826:	b8 00 00 00 00       	mov    $0x0,%eax
  80082b:	eb 03                	jmp    800830 <strlen+0x10>
		n++;
  80082d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800830:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800834:	75 f7                	jne    80082d <strlen+0xd>
		n++;
	return n;
}
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800841:	ba 00 00 00 00       	mov    $0x0,%edx
  800846:	eb 03                	jmp    80084b <strnlen+0x13>
		n++;
  800848:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80084b:	39 c2                	cmp    %eax,%edx
  80084d:	74 08                	je     800857 <strnlen+0x1f>
  80084f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800853:	75 f3                	jne    800848 <strnlen+0x10>
  800855:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800857:	5d                   	pop    %ebp
  800858:	c3                   	ret    

00800859 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	53                   	push   %ebx
  80085d:	8b 45 08             	mov    0x8(%ebp),%eax
  800860:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800863:	89 c2                	mov    %eax,%edx
  800865:	83 c2 01             	add    $0x1,%edx
  800868:	83 c1 01             	add    $0x1,%ecx
  80086b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80086f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800872:	84 db                	test   %bl,%bl
  800874:	75 ef                	jne    800865 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800876:	5b                   	pop    %ebx
  800877:	5d                   	pop    %ebp
  800878:	c3                   	ret    

00800879 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	53                   	push   %ebx
  80087d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800880:	53                   	push   %ebx
  800881:	e8 9a ff ff ff       	call   800820 <strlen>
  800886:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800889:	ff 75 0c             	pushl  0xc(%ebp)
  80088c:	01 d8                	add    %ebx,%eax
  80088e:	50                   	push   %eax
  80088f:	e8 c5 ff ff ff       	call   800859 <strcpy>
	return dst;
}
  800894:	89 d8                	mov    %ebx,%eax
  800896:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800899:	c9                   	leave  
  80089a:	c3                   	ret    

0080089b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	56                   	push   %esi
  80089f:	53                   	push   %ebx
  8008a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a6:	89 f3                	mov    %esi,%ebx
  8008a8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008ab:	89 f2                	mov    %esi,%edx
  8008ad:	eb 0f                	jmp    8008be <strncpy+0x23>
		*dst++ = *src;
  8008af:	83 c2 01             	add    $0x1,%edx
  8008b2:	0f b6 01             	movzbl (%ecx),%eax
  8008b5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b8:	80 39 01             	cmpb   $0x1,(%ecx)
  8008bb:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008be:	39 da                	cmp    %ebx,%edx
  8008c0:	75 ed                	jne    8008af <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008c2:	89 f0                	mov    %esi,%eax
  8008c4:	5b                   	pop    %ebx
  8008c5:	5e                   	pop    %esi
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    

008008c8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	56                   	push   %esi
  8008cc:	53                   	push   %ebx
  8008cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d3:	8b 55 10             	mov    0x10(%ebp),%edx
  8008d6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d8:	85 d2                	test   %edx,%edx
  8008da:	74 21                	je     8008fd <strlcpy+0x35>
  8008dc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008e0:	89 f2                	mov    %esi,%edx
  8008e2:	eb 09                	jmp    8008ed <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008e4:	83 c2 01             	add    $0x1,%edx
  8008e7:	83 c1 01             	add    $0x1,%ecx
  8008ea:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008ed:	39 c2                	cmp    %eax,%edx
  8008ef:	74 09                	je     8008fa <strlcpy+0x32>
  8008f1:	0f b6 19             	movzbl (%ecx),%ebx
  8008f4:	84 db                	test   %bl,%bl
  8008f6:	75 ec                	jne    8008e4 <strlcpy+0x1c>
  8008f8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008fa:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008fd:	29 f0                	sub    %esi,%eax
}
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800909:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80090c:	eb 06                	jmp    800914 <strcmp+0x11>
		p++, q++;
  80090e:	83 c1 01             	add    $0x1,%ecx
  800911:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800914:	0f b6 01             	movzbl (%ecx),%eax
  800917:	84 c0                	test   %al,%al
  800919:	74 04                	je     80091f <strcmp+0x1c>
  80091b:	3a 02                	cmp    (%edx),%al
  80091d:	74 ef                	je     80090e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80091f:	0f b6 c0             	movzbl %al,%eax
  800922:	0f b6 12             	movzbl (%edx),%edx
  800925:	29 d0                	sub    %edx,%eax
}
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	53                   	push   %ebx
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	8b 55 0c             	mov    0xc(%ebp),%edx
  800933:	89 c3                	mov    %eax,%ebx
  800935:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800938:	eb 06                	jmp    800940 <strncmp+0x17>
		n--, p++, q++;
  80093a:	83 c0 01             	add    $0x1,%eax
  80093d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800940:	39 d8                	cmp    %ebx,%eax
  800942:	74 15                	je     800959 <strncmp+0x30>
  800944:	0f b6 08             	movzbl (%eax),%ecx
  800947:	84 c9                	test   %cl,%cl
  800949:	74 04                	je     80094f <strncmp+0x26>
  80094b:	3a 0a                	cmp    (%edx),%cl
  80094d:	74 eb                	je     80093a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80094f:	0f b6 00             	movzbl (%eax),%eax
  800952:	0f b6 12             	movzbl (%edx),%edx
  800955:	29 d0                	sub    %edx,%eax
  800957:	eb 05                	jmp    80095e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800959:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80095e:	5b                   	pop    %ebx
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	8b 45 08             	mov    0x8(%ebp),%eax
  800967:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80096b:	eb 07                	jmp    800974 <strchr+0x13>
		if (*s == c)
  80096d:	38 ca                	cmp    %cl,%dl
  80096f:	74 0f                	je     800980 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800971:	83 c0 01             	add    $0x1,%eax
  800974:	0f b6 10             	movzbl (%eax),%edx
  800977:	84 d2                	test   %dl,%dl
  800979:	75 f2                	jne    80096d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80097b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80098c:	eb 03                	jmp    800991 <strfind+0xf>
  80098e:	83 c0 01             	add    $0x1,%eax
  800991:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800994:	38 ca                	cmp    %cl,%dl
  800996:	74 04                	je     80099c <strfind+0x1a>
  800998:	84 d2                	test   %dl,%dl
  80099a:	75 f2                	jne    80098e <strfind+0xc>
			break;
	return (char *) s;
}
  80099c:	5d                   	pop    %ebp
  80099d:	c3                   	ret    

0080099e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	57                   	push   %edi
  8009a2:	56                   	push   %esi
  8009a3:	53                   	push   %ebx
  8009a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009aa:	85 c9                	test   %ecx,%ecx
  8009ac:	74 36                	je     8009e4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009ae:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009b4:	75 28                	jne    8009de <memset+0x40>
  8009b6:	f6 c1 03             	test   $0x3,%cl
  8009b9:	75 23                	jne    8009de <memset+0x40>
		c &= 0xFF;
  8009bb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009bf:	89 d3                	mov    %edx,%ebx
  8009c1:	c1 e3 08             	shl    $0x8,%ebx
  8009c4:	89 d6                	mov    %edx,%esi
  8009c6:	c1 e6 18             	shl    $0x18,%esi
  8009c9:	89 d0                	mov    %edx,%eax
  8009cb:	c1 e0 10             	shl    $0x10,%eax
  8009ce:	09 f0                	or     %esi,%eax
  8009d0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009d2:	89 d8                	mov    %ebx,%eax
  8009d4:	09 d0                	or     %edx,%eax
  8009d6:	c1 e9 02             	shr    $0x2,%ecx
  8009d9:	fc                   	cld    
  8009da:	f3 ab                	rep stos %eax,%es:(%edi)
  8009dc:	eb 06                	jmp    8009e4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e1:	fc                   	cld    
  8009e2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009e4:	89 f8                	mov    %edi,%eax
  8009e6:	5b                   	pop    %ebx
  8009e7:	5e                   	pop    %esi
  8009e8:	5f                   	pop    %edi
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	57                   	push   %edi
  8009ef:	56                   	push   %esi
  8009f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009f9:	39 c6                	cmp    %eax,%esi
  8009fb:	73 35                	jae    800a32 <memmove+0x47>
  8009fd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a00:	39 d0                	cmp    %edx,%eax
  800a02:	73 2e                	jae    800a32 <memmove+0x47>
		s += n;
		d += n;
  800a04:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a07:	89 d6                	mov    %edx,%esi
  800a09:	09 fe                	or     %edi,%esi
  800a0b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a11:	75 13                	jne    800a26 <memmove+0x3b>
  800a13:	f6 c1 03             	test   $0x3,%cl
  800a16:	75 0e                	jne    800a26 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a18:	83 ef 04             	sub    $0x4,%edi
  800a1b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a1e:	c1 e9 02             	shr    $0x2,%ecx
  800a21:	fd                   	std    
  800a22:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a24:	eb 09                	jmp    800a2f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a26:	83 ef 01             	sub    $0x1,%edi
  800a29:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a2c:	fd                   	std    
  800a2d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a2f:	fc                   	cld    
  800a30:	eb 1d                	jmp    800a4f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a32:	89 f2                	mov    %esi,%edx
  800a34:	09 c2                	or     %eax,%edx
  800a36:	f6 c2 03             	test   $0x3,%dl
  800a39:	75 0f                	jne    800a4a <memmove+0x5f>
  800a3b:	f6 c1 03             	test   $0x3,%cl
  800a3e:	75 0a                	jne    800a4a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a40:	c1 e9 02             	shr    $0x2,%ecx
  800a43:	89 c7                	mov    %eax,%edi
  800a45:	fc                   	cld    
  800a46:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a48:	eb 05                	jmp    800a4f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a4a:	89 c7                	mov    %eax,%edi
  800a4c:	fc                   	cld    
  800a4d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a4f:	5e                   	pop    %esi
  800a50:	5f                   	pop    %edi
  800a51:	5d                   	pop    %ebp
  800a52:	c3                   	ret    

00800a53 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a56:	ff 75 10             	pushl  0x10(%ebp)
  800a59:	ff 75 0c             	pushl  0xc(%ebp)
  800a5c:	ff 75 08             	pushl  0x8(%ebp)
  800a5f:	e8 87 ff ff ff       	call   8009eb <memmove>
}
  800a64:	c9                   	leave  
  800a65:	c3                   	ret    

00800a66 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	56                   	push   %esi
  800a6a:	53                   	push   %ebx
  800a6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a71:	89 c6                	mov    %eax,%esi
  800a73:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a76:	eb 1a                	jmp    800a92 <memcmp+0x2c>
		if (*s1 != *s2)
  800a78:	0f b6 08             	movzbl (%eax),%ecx
  800a7b:	0f b6 1a             	movzbl (%edx),%ebx
  800a7e:	38 d9                	cmp    %bl,%cl
  800a80:	74 0a                	je     800a8c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a82:	0f b6 c1             	movzbl %cl,%eax
  800a85:	0f b6 db             	movzbl %bl,%ebx
  800a88:	29 d8                	sub    %ebx,%eax
  800a8a:	eb 0f                	jmp    800a9b <memcmp+0x35>
		s1++, s2++;
  800a8c:	83 c0 01             	add    $0x1,%eax
  800a8f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a92:	39 f0                	cmp    %esi,%eax
  800a94:	75 e2                	jne    800a78 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a96:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a9b:	5b                   	pop    %ebx
  800a9c:	5e                   	pop    %esi
  800a9d:	5d                   	pop    %ebp
  800a9e:	c3                   	ret    

00800a9f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	53                   	push   %ebx
  800aa3:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800aa6:	89 c1                	mov    %eax,%ecx
  800aa8:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800aab:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aaf:	eb 0a                	jmp    800abb <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ab1:	0f b6 10             	movzbl (%eax),%edx
  800ab4:	39 da                	cmp    %ebx,%edx
  800ab6:	74 07                	je     800abf <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ab8:	83 c0 01             	add    $0x1,%eax
  800abb:	39 c8                	cmp    %ecx,%eax
  800abd:	72 f2                	jb     800ab1 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800abf:	5b                   	pop    %ebx
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    

00800ac2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	57                   	push   %edi
  800ac6:	56                   	push   %esi
  800ac7:	53                   	push   %ebx
  800ac8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800acb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ace:	eb 03                	jmp    800ad3 <strtol+0x11>
		s++;
  800ad0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad3:	0f b6 01             	movzbl (%ecx),%eax
  800ad6:	3c 20                	cmp    $0x20,%al
  800ad8:	74 f6                	je     800ad0 <strtol+0xe>
  800ada:	3c 09                	cmp    $0x9,%al
  800adc:	74 f2                	je     800ad0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ade:	3c 2b                	cmp    $0x2b,%al
  800ae0:	75 0a                	jne    800aec <strtol+0x2a>
		s++;
  800ae2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ae5:	bf 00 00 00 00       	mov    $0x0,%edi
  800aea:	eb 11                	jmp    800afd <strtol+0x3b>
  800aec:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800af1:	3c 2d                	cmp    $0x2d,%al
  800af3:	75 08                	jne    800afd <strtol+0x3b>
		s++, neg = 1;
  800af5:	83 c1 01             	add    $0x1,%ecx
  800af8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800afd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b03:	75 15                	jne    800b1a <strtol+0x58>
  800b05:	80 39 30             	cmpb   $0x30,(%ecx)
  800b08:	75 10                	jne    800b1a <strtol+0x58>
  800b0a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b0e:	75 7c                	jne    800b8c <strtol+0xca>
		s += 2, base = 16;
  800b10:	83 c1 02             	add    $0x2,%ecx
  800b13:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b18:	eb 16                	jmp    800b30 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b1a:	85 db                	test   %ebx,%ebx
  800b1c:	75 12                	jne    800b30 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b1e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b23:	80 39 30             	cmpb   $0x30,(%ecx)
  800b26:	75 08                	jne    800b30 <strtol+0x6e>
		s++, base = 8;
  800b28:	83 c1 01             	add    $0x1,%ecx
  800b2b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b30:	b8 00 00 00 00       	mov    $0x0,%eax
  800b35:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b38:	0f b6 11             	movzbl (%ecx),%edx
  800b3b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b3e:	89 f3                	mov    %esi,%ebx
  800b40:	80 fb 09             	cmp    $0x9,%bl
  800b43:	77 08                	ja     800b4d <strtol+0x8b>
			dig = *s - '0';
  800b45:	0f be d2             	movsbl %dl,%edx
  800b48:	83 ea 30             	sub    $0x30,%edx
  800b4b:	eb 22                	jmp    800b6f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b4d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b50:	89 f3                	mov    %esi,%ebx
  800b52:	80 fb 19             	cmp    $0x19,%bl
  800b55:	77 08                	ja     800b5f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b57:	0f be d2             	movsbl %dl,%edx
  800b5a:	83 ea 57             	sub    $0x57,%edx
  800b5d:	eb 10                	jmp    800b6f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b5f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b62:	89 f3                	mov    %esi,%ebx
  800b64:	80 fb 19             	cmp    $0x19,%bl
  800b67:	77 16                	ja     800b7f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b69:	0f be d2             	movsbl %dl,%edx
  800b6c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b6f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b72:	7d 0b                	jge    800b7f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b74:	83 c1 01             	add    $0x1,%ecx
  800b77:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b7b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b7d:	eb b9                	jmp    800b38 <strtol+0x76>

	if (endptr)
  800b7f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b83:	74 0d                	je     800b92 <strtol+0xd0>
		*endptr = (char *) s;
  800b85:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b88:	89 0e                	mov    %ecx,(%esi)
  800b8a:	eb 06                	jmp    800b92 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b8c:	85 db                	test   %ebx,%ebx
  800b8e:	74 98                	je     800b28 <strtol+0x66>
  800b90:	eb 9e                	jmp    800b30 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b92:	89 c2                	mov    %eax,%edx
  800b94:	f7 da                	neg    %edx
  800b96:	85 ff                	test   %edi,%edi
  800b98:	0f 45 c2             	cmovne %edx,%eax
}
  800b9b:	5b                   	pop    %ebx
  800b9c:	5e                   	pop    %esi
  800b9d:	5f                   	pop    %edi
  800b9e:	5d                   	pop    %ebp
  800b9f:	c3                   	ret    

00800ba0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	57                   	push   %edi
  800ba4:	56                   	push   %esi
  800ba5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bae:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb1:	89 c3                	mov    %eax,%ebx
  800bb3:	89 c7                	mov    %eax,%edi
  800bb5:	89 c6                	mov    %eax,%esi
  800bb7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <sys_cgetc>:

int
sys_cgetc(void)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc9:	b8 01 00 00 00       	mov    $0x1,%eax
  800bce:	89 d1                	mov    %edx,%ecx
  800bd0:	89 d3                	mov    %edx,%ebx
  800bd2:	89 d7                	mov    %edx,%edi
  800bd4:	89 d6                	mov    %edx,%esi
  800bd6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bd8:	5b                   	pop    %ebx
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    

00800bdd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	57                   	push   %edi
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
  800be3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800beb:	b8 03 00 00 00       	mov    $0x3,%eax
  800bf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf3:	89 cb                	mov    %ecx,%ebx
  800bf5:	89 cf                	mov    %ecx,%edi
  800bf7:	89 ce                	mov    %ecx,%esi
  800bf9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	7e 17                	jle    800c16 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bff:	83 ec 0c             	sub    $0xc,%esp
  800c02:	50                   	push   %eax
  800c03:	6a 03                	push   $0x3
  800c05:	68 3f 2f 80 00       	push   $0x802f3f
  800c0a:	6a 23                	push   $0x23
  800c0c:	68 5c 2f 80 00       	push   $0x802f5c
  800c11:	e8 e5 f5 ff ff       	call   8001fb <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c24:	ba 00 00 00 00       	mov    $0x0,%edx
  800c29:	b8 02 00 00 00       	mov    $0x2,%eax
  800c2e:	89 d1                	mov    %edx,%ecx
  800c30:	89 d3                	mov    %edx,%ebx
  800c32:	89 d7                	mov    %edx,%edi
  800c34:	89 d6                	mov    %edx,%esi
  800c36:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <sys_yield>:

void
sys_yield(void)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c43:	ba 00 00 00 00       	mov    $0x0,%edx
  800c48:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c4d:	89 d1                	mov    %edx,%ecx
  800c4f:	89 d3                	mov    %edx,%ebx
  800c51:	89 d7                	mov    %edx,%edi
  800c53:	89 d6                	mov    %edx,%esi
  800c55:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c57:	5b                   	pop    %ebx
  800c58:	5e                   	pop    %esi
  800c59:	5f                   	pop    %edi
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    

00800c5c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	57                   	push   %edi
  800c60:	56                   	push   %esi
  800c61:	53                   	push   %ebx
  800c62:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c65:	be 00 00 00 00       	mov    $0x0,%esi
  800c6a:	b8 04 00 00 00       	mov    $0x4,%eax
  800c6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c72:	8b 55 08             	mov    0x8(%ebp),%edx
  800c75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c78:	89 f7                	mov    %esi,%edi
  800c7a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7c:	85 c0                	test   %eax,%eax
  800c7e:	7e 17                	jle    800c97 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c80:	83 ec 0c             	sub    $0xc,%esp
  800c83:	50                   	push   %eax
  800c84:	6a 04                	push   $0x4
  800c86:	68 3f 2f 80 00       	push   $0x802f3f
  800c8b:	6a 23                	push   $0x23
  800c8d:	68 5c 2f 80 00       	push   $0x802f5c
  800c92:	e8 64 f5 ff ff       	call   8001fb <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9a:	5b                   	pop    %ebx
  800c9b:	5e                   	pop    %esi
  800c9c:	5f                   	pop    %edi
  800c9d:	5d                   	pop    %ebp
  800c9e:	c3                   	ret    

00800c9f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	57                   	push   %edi
  800ca3:	56                   	push   %esi
  800ca4:	53                   	push   %ebx
  800ca5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca8:	b8 05 00 00 00       	mov    $0x5,%eax
  800cad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cb9:	8b 75 18             	mov    0x18(%ebp),%esi
  800cbc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbe:	85 c0                	test   %eax,%eax
  800cc0:	7e 17                	jle    800cd9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc2:	83 ec 0c             	sub    $0xc,%esp
  800cc5:	50                   	push   %eax
  800cc6:	6a 05                	push   $0x5
  800cc8:	68 3f 2f 80 00       	push   $0x802f3f
  800ccd:	6a 23                	push   $0x23
  800ccf:	68 5c 2f 80 00       	push   $0x802f5c
  800cd4:	e8 22 f5 ff ff       	call   8001fb <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdc:	5b                   	pop    %ebx
  800cdd:	5e                   	pop    %esi
  800cde:	5f                   	pop    %edi
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    

00800ce1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	57                   	push   %edi
  800ce5:	56                   	push   %esi
  800ce6:	53                   	push   %ebx
  800ce7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cea:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cef:	b8 06 00 00 00       	mov    $0x6,%eax
  800cf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfa:	89 df                	mov    %ebx,%edi
  800cfc:	89 de                	mov    %ebx,%esi
  800cfe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d00:	85 c0                	test   %eax,%eax
  800d02:	7e 17                	jle    800d1b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d04:	83 ec 0c             	sub    $0xc,%esp
  800d07:	50                   	push   %eax
  800d08:	6a 06                	push   $0x6
  800d0a:	68 3f 2f 80 00       	push   $0x802f3f
  800d0f:	6a 23                	push   $0x23
  800d11:	68 5c 2f 80 00       	push   $0x802f5c
  800d16:	e8 e0 f4 ff ff       	call   8001fb <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1e:	5b                   	pop    %ebx
  800d1f:	5e                   	pop    %esi
  800d20:	5f                   	pop    %edi
  800d21:	5d                   	pop    %ebp
  800d22:	c3                   	ret    

00800d23 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	57                   	push   %edi
  800d27:	56                   	push   %esi
  800d28:	53                   	push   %ebx
  800d29:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d31:	b8 08 00 00 00       	mov    $0x8,%eax
  800d36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d39:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3c:	89 df                	mov    %ebx,%edi
  800d3e:	89 de                	mov    %ebx,%esi
  800d40:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d42:	85 c0                	test   %eax,%eax
  800d44:	7e 17                	jle    800d5d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d46:	83 ec 0c             	sub    $0xc,%esp
  800d49:	50                   	push   %eax
  800d4a:	6a 08                	push   $0x8
  800d4c:	68 3f 2f 80 00       	push   $0x802f3f
  800d51:	6a 23                	push   $0x23
  800d53:	68 5c 2f 80 00       	push   $0x802f5c
  800d58:	e8 9e f4 ff ff       	call   8001fb <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d60:	5b                   	pop    %ebx
  800d61:	5e                   	pop    %esi
  800d62:	5f                   	pop    %edi
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    

00800d65 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	57                   	push   %edi
  800d69:	56                   	push   %esi
  800d6a:	53                   	push   %ebx
  800d6b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d73:	b8 09 00 00 00       	mov    $0x9,%eax
  800d78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7e:	89 df                	mov    %ebx,%edi
  800d80:	89 de                	mov    %ebx,%esi
  800d82:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d84:	85 c0                	test   %eax,%eax
  800d86:	7e 17                	jle    800d9f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d88:	83 ec 0c             	sub    $0xc,%esp
  800d8b:	50                   	push   %eax
  800d8c:	6a 09                	push   $0x9
  800d8e:	68 3f 2f 80 00       	push   $0x802f3f
  800d93:	6a 23                	push   $0x23
  800d95:	68 5c 2f 80 00       	push   $0x802f5c
  800d9a:	e8 5c f4 ff ff       	call   8001fb <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da2:	5b                   	pop    %ebx
  800da3:	5e                   	pop    %esi
  800da4:	5f                   	pop    %edi
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	57                   	push   %edi
  800dab:	56                   	push   %esi
  800dac:	53                   	push   %ebx
  800dad:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc0:	89 df                	mov    %ebx,%edi
  800dc2:	89 de                	mov    %ebx,%esi
  800dc4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc6:	85 c0                	test   %eax,%eax
  800dc8:	7e 17                	jle    800de1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dca:	83 ec 0c             	sub    $0xc,%esp
  800dcd:	50                   	push   %eax
  800dce:	6a 0a                	push   $0xa
  800dd0:	68 3f 2f 80 00       	push   $0x802f3f
  800dd5:	6a 23                	push   $0x23
  800dd7:	68 5c 2f 80 00       	push   $0x802f5c
  800ddc:	e8 1a f4 ff ff       	call   8001fb <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800de1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de4:	5b                   	pop    %ebx
  800de5:	5e                   	pop    %esi
  800de6:	5f                   	pop    %edi
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    

00800de9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	57                   	push   %edi
  800ded:	56                   	push   %esi
  800dee:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800def:	be 00 00 00 00       	mov    $0x0,%esi
  800df4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800df9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e02:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e05:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e07:	5b                   	pop    %ebx
  800e08:	5e                   	pop    %esi
  800e09:	5f                   	pop    %edi
  800e0a:	5d                   	pop    %ebp
  800e0b:	c3                   	ret    

00800e0c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	57                   	push   %edi
  800e10:	56                   	push   %esi
  800e11:	53                   	push   %ebx
  800e12:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e15:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e1a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e22:	89 cb                	mov    %ecx,%ebx
  800e24:	89 cf                	mov    %ecx,%edi
  800e26:	89 ce                	mov    %ecx,%esi
  800e28:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e2a:	85 c0                	test   %eax,%eax
  800e2c:	7e 17                	jle    800e45 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2e:	83 ec 0c             	sub    $0xc,%esp
  800e31:	50                   	push   %eax
  800e32:	6a 0d                	push   $0xd
  800e34:	68 3f 2f 80 00       	push   $0x802f3f
  800e39:	6a 23                	push   $0x23
  800e3b:	68 5c 2f 80 00       	push   $0x802f5c
  800e40:	e8 b6 f3 ff ff       	call   8001fb <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e48:	5b                   	pop    %ebx
  800e49:	5e                   	pop    %esi
  800e4a:	5f                   	pop    %edi
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    

00800e4d <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	57                   	push   %edi
  800e51:	56                   	push   %esi
  800e52:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e53:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e58:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e60:	89 cb                	mov    %ecx,%ebx
  800e62:	89 cf                	mov    %ecx,%edi
  800e64:	89 ce                	mov    %ecx,%esi
  800e66:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800e68:	5b                   	pop    %ebx
  800e69:	5e                   	pop    %esi
  800e6a:	5f                   	pop    %edi
  800e6b:	5d                   	pop    %ebp
  800e6c:	c3                   	ret    

00800e6d <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800e6d:	55                   	push   %ebp
  800e6e:	89 e5                	mov    %esp,%ebp
  800e70:	57                   	push   %edi
  800e71:	56                   	push   %esi
  800e72:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e73:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e78:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e80:	89 cb                	mov    %ecx,%ebx
  800e82:	89 cf                	mov    %ecx,%edi
  800e84:	89 ce                	mov    %ecx,%esi
  800e86:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800e88:	5b                   	pop    %ebx
  800e89:	5e                   	pop    %esi
  800e8a:	5f                   	pop    %edi
  800e8b:	5d                   	pop    %ebp
  800e8c:	c3                   	ret    

00800e8d <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
  800e90:	57                   	push   %edi
  800e91:	56                   	push   %esi
  800e92:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e93:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e98:	b8 10 00 00 00       	mov    $0x10,%eax
  800e9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea0:	89 cb                	mov    %ecx,%ebx
  800ea2:	89 cf                	mov    %ecx,%edi
  800ea4:	89 ce                	mov    %ecx,%esi
  800ea6:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800ea8:	5b                   	pop    %ebx
  800ea9:	5e                   	pop    %esi
  800eaa:	5f                   	pop    %edi
  800eab:	5d                   	pop    %ebp
  800eac:	c3                   	ret    

00800ead <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	53                   	push   %ebx
  800eb1:	83 ec 04             	sub    $0x4,%esp
  800eb4:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800eb7:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800eb9:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ebd:	74 11                	je     800ed0 <pgfault+0x23>
  800ebf:	89 d8                	mov    %ebx,%eax
  800ec1:	c1 e8 0c             	shr    $0xc,%eax
  800ec4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ecb:	f6 c4 08             	test   $0x8,%ah
  800ece:	75 14                	jne    800ee4 <pgfault+0x37>
		panic("faulting access");
  800ed0:	83 ec 04             	sub    $0x4,%esp
  800ed3:	68 6a 2f 80 00       	push   $0x802f6a
  800ed8:	6a 1f                	push   $0x1f
  800eda:	68 7a 2f 80 00       	push   $0x802f7a
  800edf:	e8 17 f3 ff ff       	call   8001fb <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800ee4:	83 ec 04             	sub    $0x4,%esp
  800ee7:	6a 07                	push   $0x7
  800ee9:	68 00 f0 7f 00       	push   $0x7ff000
  800eee:	6a 00                	push   $0x0
  800ef0:	e8 67 fd ff ff       	call   800c5c <sys_page_alloc>
	if (r < 0) {
  800ef5:	83 c4 10             	add    $0x10,%esp
  800ef8:	85 c0                	test   %eax,%eax
  800efa:	79 12                	jns    800f0e <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800efc:	50                   	push   %eax
  800efd:	68 85 2f 80 00       	push   $0x802f85
  800f02:	6a 2d                	push   $0x2d
  800f04:	68 7a 2f 80 00       	push   $0x802f7a
  800f09:	e8 ed f2 ff ff       	call   8001fb <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800f0e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800f14:	83 ec 04             	sub    $0x4,%esp
  800f17:	68 00 10 00 00       	push   $0x1000
  800f1c:	53                   	push   %ebx
  800f1d:	68 00 f0 7f 00       	push   $0x7ff000
  800f22:	e8 2c fb ff ff       	call   800a53 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800f27:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f2e:	53                   	push   %ebx
  800f2f:	6a 00                	push   $0x0
  800f31:	68 00 f0 7f 00       	push   $0x7ff000
  800f36:	6a 00                	push   $0x0
  800f38:	e8 62 fd ff ff       	call   800c9f <sys_page_map>
	if (r < 0) {
  800f3d:	83 c4 20             	add    $0x20,%esp
  800f40:	85 c0                	test   %eax,%eax
  800f42:	79 12                	jns    800f56 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800f44:	50                   	push   %eax
  800f45:	68 85 2f 80 00       	push   $0x802f85
  800f4a:	6a 34                	push   $0x34
  800f4c:	68 7a 2f 80 00       	push   $0x802f7a
  800f51:	e8 a5 f2 ff ff       	call   8001fb <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800f56:	83 ec 08             	sub    $0x8,%esp
  800f59:	68 00 f0 7f 00       	push   $0x7ff000
  800f5e:	6a 00                	push   $0x0
  800f60:	e8 7c fd ff ff       	call   800ce1 <sys_page_unmap>
	if (r < 0) {
  800f65:	83 c4 10             	add    $0x10,%esp
  800f68:	85 c0                	test   %eax,%eax
  800f6a:	79 12                	jns    800f7e <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800f6c:	50                   	push   %eax
  800f6d:	68 85 2f 80 00       	push   $0x802f85
  800f72:	6a 38                	push   $0x38
  800f74:	68 7a 2f 80 00       	push   $0x802f7a
  800f79:	e8 7d f2 ff ff       	call   8001fb <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800f7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f81:	c9                   	leave  
  800f82:	c3                   	ret    

00800f83 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	57                   	push   %edi
  800f87:	56                   	push   %esi
  800f88:	53                   	push   %ebx
  800f89:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800f8c:	68 ad 0e 80 00       	push   $0x800ead
  800f91:	e8 4d 17 00 00       	call   8026e3 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f96:	b8 07 00 00 00       	mov    $0x7,%eax
  800f9b:	cd 30                	int    $0x30
  800f9d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800fa0:	83 c4 10             	add    $0x10,%esp
  800fa3:	85 c0                	test   %eax,%eax
  800fa5:	79 17                	jns    800fbe <fork+0x3b>
		panic("fork fault %e");
  800fa7:	83 ec 04             	sub    $0x4,%esp
  800faa:	68 9e 2f 80 00       	push   $0x802f9e
  800faf:	68 85 00 00 00       	push   $0x85
  800fb4:	68 7a 2f 80 00       	push   $0x802f7a
  800fb9:	e8 3d f2 ff ff       	call   8001fb <_panic>
  800fbe:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800fc0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fc4:	75 24                	jne    800fea <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fc6:	e8 53 fc ff ff       	call   800c1e <sys_getenvid>
  800fcb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fd0:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800fd6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fdb:	a3 04 50 80 00       	mov    %eax,0x805004
		return 0;
  800fe0:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe5:	e9 64 01 00 00       	jmp    80114e <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800fea:	83 ec 04             	sub    $0x4,%esp
  800fed:	6a 07                	push   $0x7
  800fef:	68 00 f0 bf ee       	push   $0xeebff000
  800ff4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ff7:	e8 60 fc ff ff       	call   800c5c <sys_page_alloc>
  800ffc:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fff:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801004:	89 d8                	mov    %ebx,%eax
  801006:	c1 e8 16             	shr    $0x16,%eax
  801009:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801010:	a8 01                	test   $0x1,%al
  801012:	0f 84 fc 00 00 00    	je     801114 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  801018:	89 d8                	mov    %ebx,%eax
  80101a:	c1 e8 0c             	shr    $0xc,%eax
  80101d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801024:	f6 c2 01             	test   $0x1,%dl
  801027:	0f 84 e7 00 00 00    	je     801114 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80102d:	89 c6                	mov    %eax,%esi
  80102f:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  801032:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801039:	f6 c6 04             	test   $0x4,%dh
  80103c:	74 39                	je     801077 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80103e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801045:	83 ec 0c             	sub    $0xc,%esp
  801048:	25 07 0e 00 00       	and    $0xe07,%eax
  80104d:	50                   	push   %eax
  80104e:	56                   	push   %esi
  80104f:	57                   	push   %edi
  801050:	56                   	push   %esi
  801051:	6a 00                	push   $0x0
  801053:	e8 47 fc ff ff       	call   800c9f <sys_page_map>
		if (r < 0) {
  801058:	83 c4 20             	add    $0x20,%esp
  80105b:	85 c0                	test   %eax,%eax
  80105d:	0f 89 b1 00 00 00    	jns    801114 <fork+0x191>
		    	panic("sys page map fault %e");
  801063:	83 ec 04             	sub    $0x4,%esp
  801066:	68 ac 2f 80 00       	push   $0x802fac
  80106b:	6a 55                	push   $0x55
  80106d:	68 7a 2f 80 00       	push   $0x802f7a
  801072:	e8 84 f1 ff ff       	call   8001fb <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801077:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80107e:	f6 c2 02             	test   $0x2,%dl
  801081:	75 0c                	jne    80108f <fork+0x10c>
  801083:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80108a:	f6 c4 08             	test   $0x8,%ah
  80108d:	74 5b                	je     8010ea <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80108f:	83 ec 0c             	sub    $0xc,%esp
  801092:	68 05 08 00 00       	push   $0x805
  801097:	56                   	push   %esi
  801098:	57                   	push   %edi
  801099:	56                   	push   %esi
  80109a:	6a 00                	push   $0x0
  80109c:	e8 fe fb ff ff       	call   800c9f <sys_page_map>
		if (r < 0) {
  8010a1:	83 c4 20             	add    $0x20,%esp
  8010a4:	85 c0                	test   %eax,%eax
  8010a6:	79 14                	jns    8010bc <fork+0x139>
		    	panic("sys page map fault %e");
  8010a8:	83 ec 04             	sub    $0x4,%esp
  8010ab:	68 ac 2f 80 00       	push   $0x802fac
  8010b0:	6a 5c                	push   $0x5c
  8010b2:	68 7a 2f 80 00       	push   $0x802f7a
  8010b7:	e8 3f f1 ff ff       	call   8001fb <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8010bc:	83 ec 0c             	sub    $0xc,%esp
  8010bf:	68 05 08 00 00       	push   $0x805
  8010c4:	56                   	push   %esi
  8010c5:	6a 00                	push   $0x0
  8010c7:	56                   	push   %esi
  8010c8:	6a 00                	push   $0x0
  8010ca:	e8 d0 fb ff ff       	call   800c9f <sys_page_map>
		if (r < 0) {
  8010cf:	83 c4 20             	add    $0x20,%esp
  8010d2:	85 c0                	test   %eax,%eax
  8010d4:	79 3e                	jns    801114 <fork+0x191>
		    	panic("sys page map fault %e");
  8010d6:	83 ec 04             	sub    $0x4,%esp
  8010d9:	68 ac 2f 80 00       	push   $0x802fac
  8010de:	6a 60                	push   $0x60
  8010e0:	68 7a 2f 80 00       	push   $0x802f7a
  8010e5:	e8 11 f1 ff ff       	call   8001fb <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8010ea:	83 ec 0c             	sub    $0xc,%esp
  8010ed:	6a 05                	push   $0x5
  8010ef:	56                   	push   %esi
  8010f0:	57                   	push   %edi
  8010f1:	56                   	push   %esi
  8010f2:	6a 00                	push   $0x0
  8010f4:	e8 a6 fb ff ff       	call   800c9f <sys_page_map>
		if (r < 0) {
  8010f9:	83 c4 20             	add    $0x20,%esp
  8010fc:	85 c0                	test   %eax,%eax
  8010fe:	79 14                	jns    801114 <fork+0x191>
		    	panic("sys page map fault %e");
  801100:	83 ec 04             	sub    $0x4,%esp
  801103:	68 ac 2f 80 00       	push   $0x802fac
  801108:	6a 65                	push   $0x65
  80110a:	68 7a 2f 80 00       	push   $0x802f7a
  80110f:	e8 e7 f0 ff ff       	call   8001fb <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801114:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80111a:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801120:	0f 85 de fe ff ff    	jne    801004 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801126:	a1 04 50 80 00       	mov    0x805004,%eax
  80112b:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  801131:	83 ec 08             	sub    $0x8,%esp
  801134:	50                   	push   %eax
  801135:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801138:	57                   	push   %edi
  801139:	e8 69 fc ff ff       	call   800da7 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80113e:	83 c4 08             	add    $0x8,%esp
  801141:	6a 02                	push   $0x2
  801143:	57                   	push   %edi
  801144:	e8 da fb ff ff       	call   800d23 <sys_env_set_status>
	
	return envid;
  801149:	83 c4 10             	add    $0x10,%esp
  80114c:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80114e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801151:	5b                   	pop    %ebx
  801152:	5e                   	pop    %esi
  801153:	5f                   	pop    %edi
  801154:	5d                   	pop    %ebp
  801155:	c3                   	ret    

00801156 <sfork>:

envid_t
sfork(void)
{
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801159:	b8 00 00 00 00       	mov    $0x0,%eax
  80115e:	5d                   	pop    %ebp
  80115f:	c3                   	ret    

00801160 <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
  801163:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  801166:	8b 45 08             	mov    0x8(%ebp),%eax
  801169:	a3 08 50 80 00       	mov    %eax,0x805008
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80116e:	68 c1 01 80 00       	push   $0x8001c1
  801173:	e8 d5 fc ff ff       	call   800e4d <sys_thread_create>

	return id;
}
  801178:	c9                   	leave  
  801179:	c3                   	ret    

0080117a <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  80117a:	55                   	push   %ebp
  80117b:	89 e5                	mov    %esp,%ebp
  80117d:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  801180:	ff 75 08             	pushl  0x8(%ebp)
  801183:	e8 e5 fc ff ff       	call   800e6d <sys_thread_free>
}
  801188:	83 c4 10             	add    $0x10,%esp
  80118b:	c9                   	leave  
  80118c:	c3                   	ret    

0080118d <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  80118d:	55                   	push   %ebp
  80118e:	89 e5                	mov    %esp,%ebp
  801190:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  801193:	ff 75 08             	pushl  0x8(%ebp)
  801196:	e8 f2 fc ff ff       	call   800e8d <sys_thread_join>
}
  80119b:	83 c4 10             	add    $0x10,%esp
  80119e:	c9                   	leave  
  80119f:	c3                   	ret    

008011a0 <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	56                   	push   %esi
  8011a4:	53                   	push   %ebx
  8011a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8011a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8011ab:	83 ec 04             	sub    $0x4,%esp
  8011ae:	6a 07                	push   $0x7
  8011b0:	6a 00                	push   $0x0
  8011b2:	56                   	push   %esi
  8011b3:	e8 a4 fa ff ff       	call   800c5c <sys_page_alloc>
	if (r < 0) {
  8011b8:	83 c4 10             	add    $0x10,%esp
  8011bb:	85 c0                	test   %eax,%eax
  8011bd:	79 15                	jns    8011d4 <queue_append+0x34>
		panic("%e\n", r);
  8011bf:	50                   	push   %eax
  8011c0:	68 f2 2f 80 00       	push   $0x802ff2
  8011c5:	68 d5 00 00 00       	push   $0xd5
  8011ca:	68 7a 2f 80 00       	push   $0x802f7a
  8011cf:	e8 27 f0 ff ff       	call   8001fb <_panic>
	}	

	wt->envid = envid;
  8011d4:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  8011da:	83 3b 00             	cmpl   $0x0,(%ebx)
  8011dd:	75 13                	jne    8011f2 <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  8011df:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  8011e6:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8011ed:	00 00 00 
  8011f0:	eb 1b                	jmp    80120d <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  8011f2:	8b 43 04             	mov    0x4(%ebx),%eax
  8011f5:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  8011fc:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801203:	00 00 00 
		queue->last = wt;
  801206:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80120d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801210:	5b                   	pop    %ebx
  801211:	5e                   	pop    %esi
  801212:	5d                   	pop    %ebp
  801213:	c3                   	ret    

00801214 <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  801214:	55                   	push   %ebp
  801215:	89 e5                	mov    %esp,%ebp
  801217:	83 ec 08             	sub    $0x8,%esp
  80121a:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  80121d:	8b 02                	mov    (%edx),%eax
  80121f:	85 c0                	test   %eax,%eax
  801221:	75 17                	jne    80123a <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  801223:	83 ec 04             	sub    $0x4,%esp
  801226:	68 c2 2f 80 00       	push   $0x802fc2
  80122b:	68 ec 00 00 00       	push   $0xec
  801230:	68 7a 2f 80 00       	push   $0x802f7a
  801235:	e8 c1 ef ff ff       	call   8001fb <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  80123a:	8b 48 04             	mov    0x4(%eax),%ecx
  80123d:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  80123f:	8b 00                	mov    (%eax),%eax
}
  801241:	c9                   	leave  
  801242:	c3                   	ret    

00801243 <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	53                   	push   %ebx
  801247:	83 ec 04             	sub    $0x4,%esp
  80124a:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  80124d:	b8 01 00 00 00       	mov    $0x1,%eax
  801252:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  801255:	85 c0                	test   %eax,%eax
  801257:	74 45                	je     80129e <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  801259:	e8 c0 f9 ff ff       	call   800c1e <sys_getenvid>
  80125e:	83 ec 08             	sub    $0x8,%esp
  801261:	83 c3 04             	add    $0x4,%ebx
  801264:	53                   	push   %ebx
  801265:	50                   	push   %eax
  801266:	e8 35 ff ff ff       	call   8011a0 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  80126b:	e8 ae f9 ff ff       	call   800c1e <sys_getenvid>
  801270:	83 c4 08             	add    $0x8,%esp
  801273:	6a 04                	push   $0x4
  801275:	50                   	push   %eax
  801276:	e8 a8 fa ff ff       	call   800d23 <sys_env_set_status>

		if (r < 0) {
  80127b:	83 c4 10             	add    $0x10,%esp
  80127e:	85 c0                	test   %eax,%eax
  801280:	79 15                	jns    801297 <mutex_lock+0x54>
			panic("%e\n", r);
  801282:	50                   	push   %eax
  801283:	68 f2 2f 80 00       	push   $0x802ff2
  801288:	68 02 01 00 00       	push   $0x102
  80128d:	68 7a 2f 80 00       	push   $0x802f7a
  801292:	e8 64 ef ff ff       	call   8001fb <_panic>
		}
		sys_yield();
  801297:	e8 a1 f9 ff ff       	call   800c3d <sys_yield>
  80129c:	eb 08                	jmp    8012a6 <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  80129e:	e8 7b f9 ff ff       	call   800c1e <sys_getenvid>
  8012a3:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8012a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a9:	c9                   	leave  
  8012aa:	c3                   	ret    

008012ab <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  8012ab:	55                   	push   %ebp
  8012ac:	89 e5                	mov    %esp,%ebp
  8012ae:	53                   	push   %ebx
  8012af:	83 ec 04             	sub    $0x4,%esp
  8012b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  8012b5:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8012b9:	74 36                	je     8012f1 <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  8012bb:	83 ec 0c             	sub    $0xc,%esp
  8012be:	8d 43 04             	lea    0x4(%ebx),%eax
  8012c1:	50                   	push   %eax
  8012c2:	e8 4d ff ff ff       	call   801214 <queue_pop>
  8012c7:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8012ca:	83 c4 08             	add    $0x8,%esp
  8012cd:	6a 02                	push   $0x2
  8012cf:	50                   	push   %eax
  8012d0:	e8 4e fa ff ff       	call   800d23 <sys_env_set_status>
		if (r < 0) {
  8012d5:	83 c4 10             	add    $0x10,%esp
  8012d8:	85 c0                	test   %eax,%eax
  8012da:	79 1d                	jns    8012f9 <mutex_unlock+0x4e>
			panic("%e\n", r);
  8012dc:	50                   	push   %eax
  8012dd:	68 f2 2f 80 00       	push   $0x802ff2
  8012e2:	68 16 01 00 00       	push   $0x116
  8012e7:	68 7a 2f 80 00       	push   $0x802f7a
  8012ec:	e8 0a ef ff ff       	call   8001fb <_panic>
  8012f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f6:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  8012f9:	e8 3f f9 ff ff       	call   800c3d <sys_yield>
}
  8012fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801301:	c9                   	leave  
  801302:	c3                   	ret    

00801303 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  801303:	55                   	push   %ebp
  801304:	89 e5                	mov    %esp,%ebp
  801306:	53                   	push   %ebx
  801307:	83 ec 04             	sub    $0x4,%esp
  80130a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  80130d:	e8 0c f9 ff ff       	call   800c1e <sys_getenvid>
  801312:	83 ec 04             	sub    $0x4,%esp
  801315:	6a 07                	push   $0x7
  801317:	53                   	push   %ebx
  801318:	50                   	push   %eax
  801319:	e8 3e f9 ff ff       	call   800c5c <sys_page_alloc>
  80131e:	83 c4 10             	add    $0x10,%esp
  801321:	85 c0                	test   %eax,%eax
  801323:	79 15                	jns    80133a <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  801325:	50                   	push   %eax
  801326:	68 dd 2f 80 00       	push   $0x802fdd
  80132b:	68 23 01 00 00       	push   $0x123
  801330:	68 7a 2f 80 00       	push   $0x802f7a
  801335:	e8 c1 ee ff ff       	call   8001fb <_panic>
	}	
	mtx->locked = 0;
  80133a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  801340:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  801347:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  80134e:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  801355:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801358:	c9                   	leave  
  801359:	c3                   	ret    

0080135a <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  80135a:	55                   	push   %ebp
  80135b:	89 e5                	mov    %esp,%ebp
  80135d:	56                   	push   %esi
  80135e:	53                   	push   %ebx
  80135f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  801362:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  801365:	eb 20                	jmp    801387 <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  801367:	83 ec 0c             	sub    $0xc,%esp
  80136a:	56                   	push   %esi
  80136b:	e8 a4 fe ff ff       	call   801214 <queue_pop>
  801370:	83 c4 08             	add    $0x8,%esp
  801373:	6a 02                	push   $0x2
  801375:	50                   	push   %eax
  801376:	e8 a8 f9 ff ff       	call   800d23 <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  80137b:	8b 43 04             	mov    0x4(%ebx),%eax
  80137e:	8b 40 04             	mov    0x4(%eax),%eax
  801381:	89 43 04             	mov    %eax,0x4(%ebx)
  801384:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  801387:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  80138b:	75 da                	jne    801367 <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  80138d:	83 ec 04             	sub    $0x4,%esp
  801390:	68 00 10 00 00       	push   $0x1000
  801395:	6a 00                	push   $0x0
  801397:	53                   	push   %ebx
  801398:	e8 01 f6 ff ff       	call   80099e <memset>
	mtx = NULL;
}
  80139d:	83 c4 10             	add    $0x10,%esp
  8013a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013a3:	5b                   	pop    %ebx
  8013a4:	5e                   	pop    %esi
  8013a5:	5d                   	pop    %ebp
  8013a6:	c3                   	ret    

008013a7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013a7:	55                   	push   %ebp
  8013a8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ad:	05 00 00 00 30       	add    $0x30000000,%eax
  8013b2:	c1 e8 0c             	shr    $0xc,%eax
}
  8013b5:	5d                   	pop    %ebp
  8013b6:	c3                   	ret    

008013b7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013b7:	55                   	push   %ebp
  8013b8:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8013ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8013bd:	05 00 00 00 30       	add    $0x30000000,%eax
  8013c2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013c7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013cc:	5d                   	pop    %ebp
  8013cd:	c3                   	ret    

008013ce <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
  8013d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013d4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013d9:	89 c2                	mov    %eax,%edx
  8013db:	c1 ea 16             	shr    $0x16,%edx
  8013de:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013e5:	f6 c2 01             	test   $0x1,%dl
  8013e8:	74 11                	je     8013fb <fd_alloc+0x2d>
  8013ea:	89 c2                	mov    %eax,%edx
  8013ec:	c1 ea 0c             	shr    $0xc,%edx
  8013ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013f6:	f6 c2 01             	test   $0x1,%dl
  8013f9:	75 09                	jne    801404 <fd_alloc+0x36>
			*fd_store = fd;
  8013fb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801402:	eb 17                	jmp    80141b <fd_alloc+0x4d>
  801404:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801409:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80140e:	75 c9                	jne    8013d9 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801410:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801416:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80141b:	5d                   	pop    %ebp
  80141c:	c3                   	ret    

0080141d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80141d:	55                   	push   %ebp
  80141e:	89 e5                	mov    %esp,%ebp
  801420:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801423:	83 f8 1f             	cmp    $0x1f,%eax
  801426:	77 36                	ja     80145e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801428:	c1 e0 0c             	shl    $0xc,%eax
  80142b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801430:	89 c2                	mov    %eax,%edx
  801432:	c1 ea 16             	shr    $0x16,%edx
  801435:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80143c:	f6 c2 01             	test   $0x1,%dl
  80143f:	74 24                	je     801465 <fd_lookup+0x48>
  801441:	89 c2                	mov    %eax,%edx
  801443:	c1 ea 0c             	shr    $0xc,%edx
  801446:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80144d:	f6 c2 01             	test   $0x1,%dl
  801450:	74 1a                	je     80146c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801452:	8b 55 0c             	mov    0xc(%ebp),%edx
  801455:	89 02                	mov    %eax,(%edx)
	return 0;
  801457:	b8 00 00 00 00       	mov    $0x0,%eax
  80145c:	eb 13                	jmp    801471 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80145e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801463:	eb 0c                	jmp    801471 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801465:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80146a:	eb 05                	jmp    801471 <fd_lookup+0x54>
  80146c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801471:	5d                   	pop    %ebp
  801472:	c3                   	ret    

00801473 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801473:	55                   	push   %ebp
  801474:	89 e5                	mov    %esp,%ebp
  801476:	83 ec 08             	sub    $0x8,%esp
  801479:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80147c:	ba 74 30 80 00       	mov    $0x803074,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801481:	eb 13                	jmp    801496 <dev_lookup+0x23>
  801483:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801486:	39 08                	cmp    %ecx,(%eax)
  801488:	75 0c                	jne    801496 <dev_lookup+0x23>
			*dev = devtab[i];
  80148a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80148d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80148f:	b8 00 00 00 00       	mov    $0x0,%eax
  801494:	eb 31                	jmp    8014c7 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801496:	8b 02                	mov    (%edx),%eax
  801498:	85 c0                	test   %eax,%eax
  80149a:	75 e7                	jne    801483 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80149c:	a1 04 50 80 00       	mov    0x805004,%eax
  8014a1:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8014a7:	83 ec 04             	sub    $0x4,%esp
  8014aa:	51                   	push   %ecx
  8014ab:	50                   	push   %eax
  8014ac:	68 f8 2f 80 00       	push   $0x802ff8
  8014b1:	e8 1e ee ff ff       	call   8002d4 <cprintf>
	*dev = 0;
  8014b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014b9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014bf:	83 c4 10             	add    $0x10,%esp
  8014c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014c7:	c9                   	leave  
  8014c8:	c3                   	ret    

008014c9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014c9:	55                   	push   %ebp
  8014ca:	89 e5                	mov    %esp,%ebp
  8014cc:	56                   	push   %esi
  8014cd:	53                   	push   %ebx
  8014ce:	83 ec 10             	sub    $0x10,%esp
  8014d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8014d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014da:	50                   	push   %eax
  8014db:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014e1:	c1 e8 0c             	shr    $0xc,%eax
  8014e4:	50                   	push   %eax
  8014e5:	e8 33 ff ff ff       	call   80141d <fd_lookup>
  8014ea:	83 c4 08             	add    $0x8,%esp
  8014ed:	85 c0                	test   %eax,%eax
  8014ef:	78 05                	js     8014f6 <fd_close+0x2d>
	    || fd != fd2)
  8014f1:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014f4:	74 0c                	je     801502 <fd_close+0x39>
		return (must_exist ? r : 0);
  8014f6:	84 db                	test   %bl,%bl
  8014f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fd:	0f 44 c2             	cmove  %edx,%eax
  801500:	eb 41                	jmp    801543 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801502:	83 ec 08             	sub    $0x8,%esp
  801505:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801508:	50                   	push   %eax
  801509:	ff 36                	pushl  (%esi)
  80150b:	e8 63 ff ff ff       	call   801473 <dev_lookup>
  801510:	89 c3                	mov    %eax,%ebx
  801512:	83 c4 10             	add    $0x10,%esp
  801515:	85 c0                	test   %eax,%eax
  801517:	78 1a                	js     801533 <fd_close+0x6a>
		if (dev->dev_close)
  801519:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80151f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801524:	85 c0                	test   %eax,%eax
  801526:	74 0b                	je     801533 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801528:	83 ec 0c             	sub    $0xc,%esp
  80152b:	56                   	push   %esi
  80152c:	ff d0                	call   *%eax
  80152e:	89 c3                	mov    %eax,%ebx
  801530:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801533:	83 ec 08             	sub    $0x8,%esp
  801536:	56                   	push   %esi
  801537:	6a 00                	push   $0x0
  801539:	e8 a3 f7 ff ff       	call   800ce1 <sys_page_unmap>
	return r;
  80153e:	83 c4 10             	add    $0x10,%esp
  801541:	89 d8                	mov    %ebx,%eax
}
  801543:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801546:	5b                   	pop    %ebx
  801547:	5e                   	pop    %esi
  801548:	5d                   	pop    %ebp
  801549:	c3                   	ret    

0080154a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80154a:	55                   	push   %ebp
  80154b:	89 e5                	mov    %esp,%ebp
  80154d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801550:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801553:	50                   	push   %eax
  801554:	ff 75 08             	pushl  0x8(%ebp)
  801557:	e8 c1 fe ff ff       	call   80141d <fd_lookup>
  80155c:	83 c4 08             	add    $0x8,%esp
  80155f:	85 c0                	test   %eax,%eax
  801561:	78 10                	js     801573 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801563:	83 ec 08             	sub    $0x8,%esp
  801566:	6a 01                	push   $0x1
  801568:	ff 75 f4             	pushl  -0xc(%ebp)
  80156b:	e8 59 ff ff ff       	call   8014c9 <fd_close>
  801570:	83 c4 10             	add    $0x10,%esp
}
  801573:	c9                   	leave  
  801574:	c3                   	ret    

00801575 <close_all>:

void
close_all(void)
{
  801575:	55                   	push   %ebp
  801576:	89 e5                	mov    %esp,%ebp
  801578:	53                   	push   %ebx
  801579:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80157c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801581:	83 ec 0c             	sub    $0xc,%esp
  801584:	53                   	push   %ebx
  801585:	e8 c0 ff ff ff       	call   80154a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80158a:	83 c3 01             	add    $0x1,%ebx
  80158d:	83 c4 10             	add    $0x10,%esp
  801590:	83 fb 20             	cmp    $0x20,%ebx
  801593:	75 ec                	jne    801581 <close_all+0xc>
		close(i);
}
  801595:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801598:	c9                   	leave  
  801599:	c3                   	ret    

0080159a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80159a:	55                   	push   %ebp
  80159b:	89 e5                	mov    %esp,%ebp
  80159d:	57                   	push   %edi
  80159e:	56                   	push   %esi
  80159f:	53                   	push   %ebx
  8015a0:	83 ec 2c             	sub    $0x2c,%esp
  8015a3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015a6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015a9:	50                   	push   %eax
  8015aa:	ff 75 08             	pushl  0x8(%ebp)
  8015ad:	e8 6b fe ff ff       	call   80141d <fd_lookup>
  8015b2:	83 c4 08             	add    $0x8,%esp
  8015b5:	85 c0                	test   %eax,%eax
  8015b7:	0f 88 c1 00 00 00    	js     80167e <dup+0xe4>
		return r;
	close(newfdnum);
  8015bd:	83 ec 0c             	sub    $0xc,%esp
  8015c0:	56                   	push   %esi
  8015c1:	e8 84 ff ff ff       	call   80154a <close>

	newfd = INDEX2FD(newfdnum);
  8015c6:	89 f3                	mov    %esi,%ebx
  8015c8:	c1 e3 0c             	shl    $0xc,%ebx
  8015cb:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8015d1:	83 c4 04             	add    $0x4,%esp
  8015d4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015d7:	e8 db fd ff ff       	call   8013b7 <fd2data>
  8015dc:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8015de:	89 1c 24             	mov    %ebx,(%esp)
  8015e1:	e8 d1 fd ff ff       	call   8013b7 <fd2data>
  8015e6:	83 c4 10             	add    $0x10,%esp
  8015e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015ec:	89 f8                	mov    %edi,%eax
  8015ee:	c1 e8 16             	shr    $0x16,%eax
  8015f1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015f8:	a8 01                	test   $0x1,%al
  8015fa:	74 37                	je     801633 <dup+0x99>
  8015fc:	89 f8                	mov    %edi,%eax
  8015fe:	c1 e8 0c             	shr    $0xc,%eax
  801601:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801608:	f6 c2 01             	test   $0x1,%dl
  80160b:	74 26                	je     801633 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80160d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801614:	83 ec 0c             	sub    $0xc,%esp
  801617:	25 07 0e 00 00       	and    $0xe07,%eax
  80161c:	50                   	push   %eax
  80161d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801620:	6a 00                	push   $0x0
  801622:	57                   	push   %edi
  801623:	6a 00                	push   $0x0
  801625:	e8 75 f6 ff ff       	call   800c9f <sys_page_map>
  80162a:	89 c7                	mov    %eax,%edi
  80162c:	83 c4 20             	add    $0x20,%esp
  80162f:	85 c0                	test   %eax,%eax
  801631:	78 2e                	js     801661 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801633:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801636:	89 d0                	mov    %edx,%eax
  801638:	c1 e8 0c             	shr    $0xc,%eax
  80163b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801642:	83 ec 0c             	sub    $0xc,%esp
  801645:	25 07 0e 00 00       	and    $0xe07,%eax
  80164a:	50                   	push   %eax
  80164b:	53                   	push   %ebx
  80164c:	6a 00                	push   $0x0
  80164e:	52                   	push   %edx
  80164f:	6a 00                	push   $0x0
  801651:	e8 49 f6 ff ff       	call   800c9f <sys_page_map>
  801656:	89 c7                	mov    %eax,%edi
  801658:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80165b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80165d:	85 ff                	test   %edi,%edi
  80165f:	79 1d                	jns    80167e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801661:	83 ec 08             	sub    $0x8,%esp
  801664:	53                   	push   %ebx
  801665:	6a 00                	push   $0x0
  801667:	e8 75 f6 ff ff       	call   800ce1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80166c:	83 c4 08             	add    $0x8,%esp
  80166f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801672:	6a 00                	push   $0x0
  801674:	e8 68 f6 ff ff       	call   800ce1 <sys_page_unmap>
	return r;
  801679:	83 c4 10             	add    $0x10,%esp
  80167c:	89 f8                	mov    %edi,%eax
}
  80167e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801681:	5b                   	pop    %ebx
  801682:	5e                   	pop    %esi
  801683:	5f                   	pop    %edi
  801684:	5d                   	pop    %ebp
  801685:	c3                   	ret    

00801686 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801686:	55                   	push   %ebp
  801687:	89 e5                	mov    %esp,%ebp
  801689:	53                   	push   %ebx
  80168a:	83 ec 14             	sub    $0x14,%esp
  80168d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801690:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801693:	50                   	push   %eax
  801694:	53                   	push   %ebx
  801695:	e8 83 fd ff ff       	call   80141d <fd_lookup>
  80169a:	83 c4 08             	add    $0x8,%esp
  80169d:	89 c2                	mov    %eax,%edx
  80169f:	85 c0                	test   %eax,%eax
  8016a1:	78 70                	js     801713 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a3:	83 ec 08             	sub    $0x8,%esp
  8016a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a9:	50                   	push   %eax
  8016aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ad:	ff 30                	pushl  (%eax)
  8016af:	e8 bf fd ff ff       	call   801473 <dev_lookup>
  8016b4:	83 c4 10             	add    $0x10,%esp
  8016b7:	85 c0                	test   %eax,%eax
  8016b9:	78 4f                	js     80170a <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016bb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016be:	8b 42 08             	mov    0x8(%edx),%eax
  8016c1:	83 e0 03             	and    $0x3,%eax
  8016c4:	83 f8 01             	cmp    $0x1,%eax
  8016c7:	75 24                	jne    8016ed <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016c9:	a1 04 50 80 00       	mov    0x805004,%eax
  8016ce:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8016d4:	83 ec 04             	sub    $0x4,%esp
  8016d7:	53                   	push   %ebx
  8016d8:	50                   	push   %eax
  8016d9:	68 39 30 80 00       	push   $0x803039
  8016de:	e8 f1 eb ff ff       	call   8002d4 <cprintf>
		return -E_INVAL;
  8016e3:	83 c4 10             	add    $0x10,%esp
  8016e6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016eb:	eb 26                	jmp    801713 <read+0x8d>
	}
	if (!dev->dev_read)
  8016ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016f0:	8b 40 08             	mov    0x8(%eax),%eax
  8016f3:	85 c0                	test   %eax,%eax
  8016f5:	74 17                	je     80170e <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8016f7:	83 ec 04             	sub    $0x4,%esp
  8016fa:	ff 75 10             	pushl  0x10(%ebp)
  8016fd:	ff 75 0c             	pushl  0xc(%ebp)
  801700:	52                   	push   %edx
  801701:	ff d0                	call   *%eax
  801703:	89 c2                	mov    %eax,%edx
  801705:	83 c4 10             	add    $0x10,%esp
  801708:	eb 09                	jmp    801713 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80170a:	89 c2                	mov    %eax,%edx
  80170c:	eb 05                	jmp    801713 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80170e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801713:	89 d0                	mov    %edx,%eax
  801715:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801718:	c9                   	leave  
  801719:	c3                   	ret    

0080171a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80171a:	55                   	push   %ebp
  80171b:	89 e5                	mov    %esp,%ebp
  80171d:	57                   	push   %edi
  80171e:	56                   	push   %esi
  80171f:	53                   	push   %ebx
  801720:	83 ec 0c             	sub    $0xc,%esp
  801723:	8b 7d 08             	mov    0x8(%ebp),%edi
  801726:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801729:	bb 00 00 00 00       	mov    $0x0,%ebx
  80172e:	eb 21                	jmp    801751 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801730:	83 ec 04             	sub    $0x4,%esp
  801733:	89 f0                	mov    %esi,%eax
  801735:	29 d8                	sub    %ebx,%eax
  801737:	50                   	push   %eax
  801738:	89 d8                	mov    %ebx,%eax
  80173a:	03 45 0c             	add    0xc(%ebp),%eax
  80173d:	50                   	push   %eax
  80173e:	57                   	push   %edi
  80173f:	e8 42 ff ff ff       	call   801686 <read>
		if (m < 0)
  801744:	83 c4 10             	add    $0x10,%esp
  801747:	85 c0                	test   %eax,%eax
  801749:	78 10                	js     80175b <readn+0x41>
			return m;
		if (m == 0)
  80174b:	85 c0                	test   %eax,%eax
  80174d:	74 0a                	je     801759 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80174f:	01 c3                	add    %eax,%ebx
  801751:	39 f3                	cmp    %esi,%ebx
  801753:	72 db                	jb     801730 <readn+0x16>
  801755:	89 d8                	mov    %ebx,%eax
  801757:	eb 02                	jmp    80175b <readn+0x41>
  801759:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80175b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80175e:	5b                   	pop    %ebx
  80175f:	5e                   	pop    %esi
  801760:	5f                   	pop    %edi
  801761:	5d                   	pop    %ebp
  801762:	c3                   	ret    

00801763 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801763:	55                   	push   %ebp
  801764:	89 e5                	mov    %esp,%ebp
  801766:	53                   	push   %ebx
  801767:	83 ec 14             	sub    $0x14,%esp
  80176a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80176d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801770:	50                   	push   %eax
  801771:	53                   	push   %ebx
  801772:	e8 a6 fc ff ff       	call   80141d <fd_lookup>
  801777:	83 c4 08             	add    $0x8,%esp
  80177a:	89 c2                	mov    %eax,%edx
  80177c:	85 c0                	test   %eax,%eax
  80177e:	78 6b                	js     8017eb <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801780:	83 ec 08             	sub    $0x8,%esp
  801783:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801786:	50                   	push   %eax
  801787:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80178a:	ff 30                	pushl  (%eax)
  80178c:	e8 e2 fc ff ff       	call   801473 <dev_lookup>
  801791:	83 c4 10             	add    $0x10,%esp
  801794:	85 c0                	test   %eax,%eax
  801796:	78 4a                	js     8017e2 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801798:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80179b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80179f:	75 24                	jne    8017c5 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017a1:	a1 04 50 80 00       	mov    0x805004,%eax
  8017a6:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8017ac:	83 ec 04             	sub    $0x4,%esp
  8017af:	53                   	push   %ebx
  8017b0:	50                   	push   %eax
  8017b1:	68 55 30 80 00       	push   $0x803055
  8017b6:	e8 19 eb ff ff       	call   8002d4 <cprintf>
		return -E_INVAL;
  8017bb:	83 c4 10             	add    $0x10,%esp
  8017be:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017c3:	eb 26                	jmp    8017eb <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017c8:	8b 52 0c             	mov    0xc(%edx),%edx
  8017cb:	85 d2                	test   %edx,%edx
  8017cd:	74 17                	je     8017e6 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017cf:	83 ec 04             	sub    $0x4,%esp
  8017d2:	ff 75 10             	pushl  0x10(%ebp)
  8017d5:	ff 75 0c             	pushl  0xc(%ebp)
  8017d8:	50                   	push   %eax
  8017d9:	ff d2                	call   *%edx
  8017db:	89 c2                	mov    %eax,%edx
  8017dd:	83 c4 10             	add    $0x10,%esp
  8017e0:	eb 09                	jmp    8017eb <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e2:	89 c2                	mov    %eax,%edx
  8017e4:	eb 05                	jmp    8017eb <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017e6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8017eb:	89 d0                	mov    %edx,%eax
  8017ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f0:	c9                   	leave  
  8017f1:	c3                   	ret    

008017f2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017f8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017fb:	50                   	push   %eax
  8017fc:	ff 75 08             	pushl  0x8(%ebp)
  8017ff:	e8 19 fc ff ff       	call   80141d <fd_lookup>
  801804:	83 c4 08             	add    $0x8,%esp
  801807:	85 c0                	test   %eax,%eax
  801809:	78 0e                	js     801819 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80180b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80180e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801811:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801814:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801819:	c9                   	leave  
  80181a:	c3                   	ret    

0080181b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80181b:	55                   	push   %ebp
  80181c:	89 e5                	mov    %esp,%ebp
  80181e:	53                   	push   %ebx
  80181f:	83 ec 14             	sub    $0x14,%esp
  801822:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801825:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801828:	50                   	push   %eax
  801829:	53                   	push   %ebx
  80182a:	e8 ee fb ff ff       	call   80141d <fd_lookup>
  80182f:	83 c4 08             	add    $0x8,%esp
  801832:	89 c2                	mov    %eax,%edx
  801834:	85 c0                	test   %eax,%eax
  801836:	78 68                	js     8018a0 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801838:	83 ec 08             	sub    $0x8,%esp
  80183b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80183e:	50                   	push   %eax
  80183f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801842:	ff 30                	pushl  (%eax)
  801844:	e8 2a fc ff ff       	call   801473 <dev_lookup>
  801849:	83 c4 10             	add    $0x10,%esp
  80184c:	85 c0                	test   %eax,%eax
  80184e:	78 47                	js     801897 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801850:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801853:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801857:	75 24                	jne    80187d <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801859:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80185e:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801864:	83 ec 04             	sub    $0x4,%esp
  801867:	53                   	push   %ebx
  801868:	50                   	push   %eax
  801869:	68 18 30 80 00       	push   $0x803018
  80186e:	e8 61 ea ff ff       	call   8002d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80187b:	eb 23                	jmp    8018a0 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  80187d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801880:	8b 52 18             	mov    0x18(%edx),%edx
  801883:	85 d2                	test   %edx,%edx
  801885:	74 14                	je     80189b <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801887:	83 ec 08             	sub    $0x8,%esp
  80188a:	ff 75 0c             	pushl  0xc(%ebp)
  80188d:	50                   	push   %eax
  80188e:	ff d2                	call   *%edx
  801890:	89 c2                	mov    %eax,%edx
  801892:	83 c4 10             	add    $0x10,%esp
  801895:	eb 09                	jmp    8018a0 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801897:	89 c2                	mov    %eax,%edx
  801899:	eb 05                	jmp    8018a0 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80189b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8018a0:	89 d0                	mov    %edx,%eax
  8018a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a5:	c9                   	leave  
  8018a6:	c3                   	ret    

008018a7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	53                   	push   %ebx
  8018ab:	83 ec 14             	sub    $0x14,%esp
  8018ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018b4:	50                   	push   %eax
  8018b5:	ff 75 08             	pushl  0x8(%ebp)
  8018b8:	e8 60 fb ff ff       	call   80141d <fd_lookup>
  8018bd:	83 c4 08             	add    $0x8,%esp
  8018c0:	89 c2                	mov    %eax,%edx
  8018c2:	85 c0                	test   %eax,%eax
  8018c4:	78 58                	js     80191e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018c6:	83 ec 08             	sub    $0x8,%esp
  8018c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018cc:	50                   	push   %eax
  8018cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d0:	ff 30                	pushl  (%eax)
  8018d2:	e8 9c fb ff ff       	call   801473 <dev_lookup>
  8018d7:	83 c4 10             	add    $0x10,%esp
  8018da:	85 c0                	test   %eax,%eax
  8018dc:	78 37                	js     801915 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8018de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018e5:	74 32                	je     801919 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018e7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018ea:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018f1:	00 00 00 
	stat->st_isdir = 0;
  8018f4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018fb:	00 00 00 
	stat->st_dev = dev;
  8018fe:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801904:	83 ec 08             	sub    $0x8,%esp
  801907:	53                   	push   %ebx
  801908:	ff 75 f0             	pushl  -0x10(%ebp)
  80190b:	ff 50 14             	call   *0x14(%eax)
  80190e:	89 c2                	mov    %eax,%edx
  801910:	83 c4 10             	add    $0x10,%esp
  801913:	eb 09                	jmp    80191e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801915:	89 c2                	mov    %eax,%edx
  801917:	eb 05                	jmp    80191e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801919:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80191e:	89 d0                	mov    %edx,%eax
  801920:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801923:	c9                   	leave  
  801924:	c3                   	ret    

00801925 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801925:	55                   	push   %ebp
  801926:	89 e5                	mov    %esp,%ebp
  801928:	56                   	push   %esi
  801929:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80192a:	83 ec 08             	sub    $0x8,%esp
  80192d:	6a 00                	push   $0x0
  80192f:	ff 75 08             	pushl  0x8(%ebp)
  801932:	e8 e3 01 00 00       	call   801b1a <open>
  801937:	89 c3                	mov    %eax,%ebx
  801939:	83 c4 10             	add    $0x10,%esp
  80193c:	85 c0                	test   %eax,%eax
  80193e:	78 1b                	js     80195b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801940:	83 ec 08             	sub    $0x8,%esp
  801943:	ff 75 0c             	pushl  0xc(%ebp)
  801946:	50                   	push   %eax
  801947:	e8 5b ff ff ff       	call   8018a7 <fstat>
  80194c:	89 c6                	mov    %eax,%esi
	close(fd);
  80194e:	89 1c 24             	mov    %ebx,(%esp)
  801951:	e8 f4 fb ff ff       	call   80154a <close>
	return r;
  801956:	83 c4 10             	add    $0x10,%esp
  801959:	89 f0                	mov    %esi,%eax
}
  80195b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80195e:	5b                   	pop    %ebx
  80195f:	5e                   	pop    %esi
  801960:	5d                   	pop    %ebp
  801961:	c3                   	ret    

00801962 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	56                   	push   %esi
  801966:	53                   	push   %ebx
  801967:	89 c6                	mov    %eax,%esi
  801969:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80196b:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801972:	75 12                	jne    801986 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801974:	83 ec 0c             	sub    $0xc,%esp
  801977:	6a 01                	push   $0x1
  801979:	e8 d1 0e 00 00       	call   80284f <ipc_find_env>
  80197e:	a3 00 50 80 00       	mov    %eax,0x805000
  801983:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801986:	6a 07                	push   $0x7
  801988:	68 00 60 80 00       	push   $0x806000
  80198d:	56                   	push   %esi
  80198e:	ff 35 00 50 80 00    	pushl  0x805000
  801994:	e8 54 0e 00 00       	call   8027ed <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801999:	83 c4 0c             	add    $0xc,%esp
  80199c:	6a 00                	push   $0x0
  80199e:	53                   	push   %ebx
  80199f:	6a 00                	push   $0x0
  8019a1:	e8 cc 0d 00 00       	call   802772 <ipc_recv>
}
  8019a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a9:	5b                   	pop    %ebx
  8019aa:	5e                   	pop    %esi
  8019ab:	5d                   	pop    %ebp
  8019ac:	c3                   	ret    

008019ad <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019ad:	55                   	push   %ebp
  8019ae:	89 e5                	mov    %esp,%ebp
  8019b0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b6:	8b 40 0c             	mov    0xc(%eax),%eax
  8019b9:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8019be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c1:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8019cb:	b8 02 00 00 00       	mov    $0x2,%eax
  8019d0:	e8 8d ff ff ff       	call   801962 <fsipc>
}
  8019d5:	c9                   	leave  
  8019d6:	c3                   	ret    

008019d7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019d7:	55                   	push   %ebp
  8019d8:	89 e5                	mov    %esp,%ebp
  8019da:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e0:	8b 40 0c             	mov    0xc(%eax),%eax
  8019e3:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8019e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ed:	b8 06 00 00 00       	mov    $0x6,%eax
  8019f2:	e8 6b ff ff ff       	call   801962 <fsipc>
}
  8019f7:	c9                   	leave  
  8019f8:	c3                   	ret    

008019f9 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019f9:	55                   	push   %ebp
  8019fa:	89 e5                	mov    %esp,%ebp
  8019fc:	53                   	push   %ebx
  8019fd:	83 ec 04             	sub    $0x4,%esp
  801a00:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a03:	8b 45 08             	mov    0x8(%ebp),%eax
  801a06:	8b 40 0c             	mov    0xc(%eax),%eax
  801a09:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a0e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a13:	b8 05 00 00 00       	mov    $0x5,%eax
  801a18:	e8 45 ff ff ff       	call   801962 <fsipc>
  801a1d:	85 c0                	test   %eax,%eax
  801a1f:	78 2c                	js     801a4d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a21:	83 ec 08             	sub    $0x8,%esp
  801a24:	68 00 60 80 00       	push   $0x806000
  801a29:	53                   	push   %ebx
  801a2a:	e8 2a ee ff ff       	call   800859 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a2f:	a1 80 60 80 00       	mov    0x806080,%eax
  801a34:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a3a:	a1 84 60 80 00       	mov    0x806084,%eax
  801a3f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a45:	83 c4 10             	add    $0x10,%esp
  801a48:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a50:	c9                   	leave  
  801a51:	c3                   	ret    

00801a52 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a52:	55                   	push   %ebp
  801a53:	89 e5                	mov    %esp,%ebp
  801a55:	83 ec 0c             	sub    $0xc,%esp
  801a58:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a5b:	8b 55 08             	mov    0x8(%ebp),%edx
  801a5e:	8b 52 0c             	mov    0xc(%edx),%edx
  801a61:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801a67:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a6c:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a71:	0f 47 c2             	cmova  %edx,%eax
  801a74:	a3 04 60 80 00       	mov    %eax,0x806004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801a79:	50                   	push   %eax
  801a7a:	ff 75 0c             	pushl  0xc(%ebp)
  801a7d:	68 08 60 80 00       	push   $0x806008
  801a82:	e8 64 ef ff ff       	call   8009eb <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801a87:	ba 00 00 00 00       	mov    $0x0,%edx
  801a8c:	b8 04 00 00 00       	mov    $0x4,%eax
  801a91:	e8 cc fe ff ff       	call   801962 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801a96:	c9                   	leave  
  801a97:	c3                   	ret    

00801a98 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a98:	55                   	push   %ebp
  801a99:	89 e5                	mov    %esp,%ebp
  801a9b:	56                   	push   %esi
  801a9c:	53                   	push   %ebx
  801a9d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa3:	8b 40 0c             	mov    0xc(%eax),%eax
  801aa6:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801aab:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ab1:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab6:	b8 03 00 00 00       	mov    $0x3,%eax
  801abb:	e8 a2 fe ff ff       	call   801962 <fsipc>
  801ac0:	89 c3                	mov    %eax,%ebx
  801ac2:	85 c0                	test   %eax,%eax
  801ac4:	78 4b                	js     801b11 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801ac6:	39 c6                	cmp    %eax,%esi
  801ac8:	73 16                	jae    801ae0 <devfile_read+0x48>
  801aca:	68 84 30 80 00       	push   $0x803084
  801acf:	68 8b 30 80 00       	push   $0x80308b
  801ad4:	6a 7c                	push   $0x7c
  801ad6:	68 a0 30 80 00       	push   $0x8030a0
  801adb:	e8 1b e7 ff ff       	call   8001fb <_panic>
	assert(r <= PGSIZE);
  801ae0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ae5:	7e 16                	jle    801afd <devfile_read+0x65>
  801ae7:	68 ab 30 80 00       	push   $0x8030ab
  801aec:	68 8b 30 80 00       	push   $0x80308b
  801af1:	6a 7d                	push   $0x7d
  801af3:	68 a0 30 80 00       	push   $0x8030a0
  801af8:	e8 fe e6 ff ff       	call   8001fb <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801afd:	83 ec 04             	sub    $0x4,%esp
  801b00:	50                   	push   %eax
  801b01:	68 00 60 80 00       	push   $0x806000
  801b06:	ff 75 0c             	pushl  0xc(%ebp)
  801b09:	e8 dd ee ff ff       	call   8009eb <memmove>
	return r;
  801b0e:	83 c4 10             	add    $0x10,%esp
}
  801b11:	89 d8                	mov    %ebx,%eax
  801b13:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b16:	5b                   	pop    %ebx
  801b17:	5e                   	pop    %esi
  801b18:	5d                   	pop    %ebp
  801b19:	c3                   	ret    

00801b1a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b1a:	55                   	push   %ebp
  801b1b:	89 e5                	mov    %esp,%ebp
  801b1d:	53                   	push   %ebx
  801b1e:	83 ec 20             	sub    $0x20,%esp
  801b21:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b24:	53                   	push   %ebx
  801b25:	e8 f6 ec ff ff       	call   800820 <strlen>
  801b2a:	83 c4 10             	add    $0x10,%esp
  801b2d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b32:	7f 67                	jg     801b9b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b34:	83 ec 0c             	sub    $0xc,%esp
  801b37:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b3a:	50                   	push   %eax
  801b3b:	e8 8e f8 ff ff       	call   8013ce <fd_alloc>
  801b40:	83 c4 10             	add    $0x10,%esp
		return r;
  801b43:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b45:	85 c0                	test   %eax,%eax
  801b47:	78 57                	js     801ba0 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b49:	83 ec 08             	sub    $0x8,%esp
  801b4c:	53                   	push   %ebx
  801b4d:	68 00 60 80 00       	push   $0x806000
  801b52:	e8 02 ed ff ff       	call   800859 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b57:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b5a:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b62:	b8 01 00 00 00       	mov    $0x1,%eax
  801b67:	e8 f6 fd ff ff       	call   801962 <fsipc>
  801b6c:	89 c3                	mov    %eax,%ebx
  801b6e:	83 c4 10             	add    $0x10,%esp
  801b71:	85 c0                	test   %eax,%eax
  801b73:	79 14                	jns    801b89 <open+0x6f>
		fd_close(fd, 0);
  801b75:	83 ec 08             	sub    $0x8,%esp
  801b78:	6a 00                	push   $0x0
  801b7a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b7d:	e8 47 f9 ff ff       	call   8014c9 <fd_close>
		return r;
  801b82:	83 c4 10             	add    $0x10,%esp
  801b85:	89 da                	mov    %ebx,%edx
  801b87:	eb 17                	jmp    801ba0 <open+0x86>
	}

	return fd2num(fd);
  801b89:	83 ec 0c             	sub    $0xc,%esp
  801b8c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b8f:	e8 13 f8 ff ff       	call   8013a7 <fd2num>
  801b94:	89 c2                	mov    %eax,%edx
  801b96:	83 c4 10             	add    $0x10,%esp
  801b99:	eb 05                	jmp    801ba0 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b9b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ba0:	89 d0                	mov    %edx,%eax
  801ba2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ba5:	c9                   	leave  
  801ba6:	c3                   	ret    

00801ba7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ba7:	55                   	push   %ebp
  801ba8:	89 e5                	mov    %esp,%ebp
  801baa:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bad:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb2:	b8 08 00 00 00       	mov    $0x8,%eax
  801bb7:	e8 a6 fd ff ff       	call   801962 <fsipc>
}
  801bbc:	c9                   	leave  
  801bbd:	c3                   	ret    

00801bbe <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801bbe:	55                   	push   %ebp
  801bbf:	89 e5                	mov    %esp,%ebp
  801bc1:	57                   	push   %edi
  801bc2:	56                   	push   %esi
  801bc3:	53                   	push   %ebx
  801bc4:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801bca:	6a 00                	push   $0x0
  801bcc:	ff 75 08             	pushl  0x8(%ebp)
  801bcf:	e8 46 ff ff ff       	call   801b1a <open>
  801bd4:	89 c7                	mov    %eax,%edi
  801bd6:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801bdc:	83 c4 10             	add    $0x10,%esp
  801bdf:	85 c0                	test   %eax,%eax
  801be1:	0f 88 8c 04 00 00    	js     802073 <spawn+0x4b5>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801be7:	83 ec 04             	sub    $0x4,%esp
  801bea:	68 00 02 00 00       	push   $0x200
  801bef:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801bf5:	50                   	push   %eax
  801bf6:	57                   	push   %edi
  801bf7:	e8 1e fb ff ff       	call   80171a <readn>
  801bfc:	83 c4 10             	add    $0x10,%esp
  801bff:	3d 00 02 00 00       	cmp    $0x200,%eax
  801c04:	75 0c                	jne    801c12 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801c06:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801c0d:	45 4c 46 
  801c10:	74 33                	je     801c45 <spawn+0x87>
		close(fd);
  801c12:	83 ec 0c             	sub    $0xc,%esp
  801c15:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c1b:	e8 2a f9 ff ff       	call   80154a <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801c20:	83 c4 0c             	add    $0xc,%esp
  801c23:	68 7f 45 4c 46       	push   $0x464c457f
  801c28:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801c2e:	68 b7 30 80 00       	push   $0x8030b7
  801c33:	e8 9c e6 ff ff       	call   8002d4 <cprintf>
		return -E_NOT_EXEC;
  801c38:	83 c4 10             	add    $0x10,%esp
  801c3b:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801c40:	e9 e1 04 00 00       	jmp    802126 <spawn+0x568>
  801c45:	b8 07 00 00 00       	mov    $0x7,%eax
  801c4a:	cd 30                	int    $0x30
  801c4c:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801c52:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801c58:	85 c0                	test   %eax,%eax
  801c5a:	0f 88 1e 04 00 00    	js     80207e <spawn+0x4c0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801c60:	89 c6                	mov    %eax,%esi
  801c62:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801c68:	69 f6 d4 00 00 00    	imul   $0xd4,%esi,%esi
  801c6e:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801c74:	81 c6 58 00 c0 ee    	add    $0xeec00058,%esi
  801c7a:	b9 11 00 00 00       	mov    $0x11,%ecx
  801c7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801c81:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801c87:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801c8d:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801c92:	be 00 00 00 00       	mov    $0x0,%esi
  801c97:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c9a:	eb 13                	jmp    801caf <spawn+0xf1>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801c9c:	83 ec 0c             	sub    $0xc,%esp
  801c9f:	50                   	push   %eax
  801ca0:	e8 7b eb ff ff       	call   800820 <strlen>
  801ca5:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801ca9:	83 c3 01             	add    $0x1,%ebx
  801cac:	83 c4 10             	add    $0x10,%esp
  801caf:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801cb6:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801cb9:	85 c0                	test   %eax,%eax
  801cbb:	75 df                	jne    801c9c <spawn+0xde>
  801cbd:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801cc3:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801cc9:	bf 00 10 40 00       	mov    $0x401000,%edi
  801cce:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801cd0:	89 fa                	mov    %edi,%edx
  801cd2:	83 e2 fc             	and    $0xfffffffc,%edx
  801cd5:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801cdc:	29 c2                	sub    %eax,%edx
  801cde:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801ce4:	8d 42 f8             	lea    -0x8(%edx),%eax
  801ce7:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801cec:	0f 86 a2 03 00 00    	jbe    802094 <spawn+0x4d6>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801cf2:	83 ec 04             	sub    $0x4,%esp
  801cf5:	6a 07                	push   $0x7
  801cf7:	68 00 00 40 00       	push   $0x400000
  801cfc:	6a 00                	push   $0x0
  801cfe:	e8 59 ef ff ff       	call   800c5c <sys_page_alloc>
  801d03:	83 c4 10             	add    $0x10,%esp
  801d06:	85 c0                	test   %eax,%eax
  801d08:	0f 88 90 03 00 00    	js     80209e <spawn+0x4e0>
  801d0e:	be 00 00 00 00       	mov    $0x0,%esi
  801d13:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801d19:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d1c:	eb 30                	jmp    801d4e <spawn+0x190>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801d1e:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801d24:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801d2a:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801d2d:	83 ec 08             	sub    $0x8,%esp
  801d30:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801d33:	57                   	push   %edi
  801d34:	e8 20 eb ff ff       	call   800859 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801d39:	83 c4 04             	add    $0x4,%esp
  801d3c:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801d3f:	e8 dc ea ff ff       	call   800820 <strlen>
  801d44:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801d48:	83 c6 01             	add    $0x1,%esi
  801d4b:	83 c4 10             	add    $0x10,%esp
  801d4e:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801d54:	7f c8                	jg     801d1e <spawn+0x160>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801d56:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801d5c:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801d62:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801d69:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801d6f:	74 19                	je     801d8a <spawn+0x1cc>
  801d71:	68 44 31 80 00       	push   $0x803144
  801d76:	68 8b 30 80 00       	push   $0x80308b
  801d7b:	68 f2 00 00 00       	push   $0xf2
  801d80:	68 d1 30 80 00       	push   $0x8030d1
  801d85:	e8 71 e4 ff ff       	call   8001fb <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801d8a:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801d90:	89 f8                	mov    %edi,%eax
  801d92:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801d97:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801d9a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801da0:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801da3:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801da9:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801daf:	83 ec 0c             	sub    $0xc,%esp
  801db2:	6a 07                	push   $0x7
  801db4:	68 00 d0 bf ee       	push   $0xeebfd000
  801db9:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801dbf:	68 00 00 40 00       	push   $0x400000
  801dc4:	6a 00                	push   $0x0
  801dc6:	e8 d4 ee ff ff       	call   800c9f <sys_page_map>
  801dcb:	89 c3                	mov    %eax,%ebx
  801dcd:	83 c4 20             	add    $0x20,%esp
  801dd0:	85 c0                	test   %eax,%eax
  801dd2:	0f 88 3c 03 00 00    	js     802114 <spawn+0x556>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801dd8:	83 ec 08             	sub    $0x8,%esp
  801ddb:	68 00 00 40 00       	push   $0x400000
  801de0:	6a 00                	push   $0x0
  801de2:	e8 fa ee ff ff       	call   800ce1 <sys_page_unmap>
  801de7:	89 c3                	mov    %eax,%ebx
  801de9:	83 c4 10             	add    $0x10,%esp
  801dec:	85 c0                	test   %eax,%eax
  801dee:	0f 88 20 03 00 00    	js     802114 <spawn+0x556>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801df4:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801dfa:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801e01:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801e07:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801e0e:	00 00 00 
  801e11:	e9 88 01 00 00       	jmp    801f9e <spawn+0x3e0>
		if (ph->p_type != ELF_PROG_LOAD)
  801e16:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801e1c:	83 38 01             	cmpl   $0x1,(%eax)
  801e1f:	0f 85 6b 01 00 00    	jne    801f90 <spawn+0x3d2>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801e25:	89 c2                	mov    %eax,%edx
  801e27:	8b 40 18             	mov    0x18(%eax),%eax
  801e2a:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801e30:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801e33:	83 f8 01             	cmp    $0x1,%eax
  801e36:	19 c0                	sbb    %eax,%eax
  801e38:	83 e0 fe             	and    $0xfffffffe,%eax
  801e3b:	83 c0 07             	add    $0x7,%eax
  801e3e:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801e44:	89 d0                	mov    %edx,%eax
  801e46:	8b 7a 04             	mov    0x4(%edx),%edi
  801e49:	89 f9                	mov    %edi,%ecx
  801e4b:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801e51:	8b 7a 10             	mov    0x10(%edx),%edi
  801e54:	8b 52 14             	mov    0x14(%edx),%edx
  801e57:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801e5d:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801e60:	89 f0                	mov    %esi,%eax
  801e62:	25 ff 0f 00 00       	and    $0xfff,%eax
  801e67:	74 14                	je     801e7d <spawn+0x2bf>
		va -= i;
  801e69:	29 c6                	sub    %eax,%esi
		memsz += i;
  801e6b:	01 c2                	add    %eax,%edx
  801e6d:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801e73:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801e75:	29 c1                	sub    %eax,%ecx
  801e77:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801e7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e82:	e9 f7 00 00 00       	jmp    801f7e <spawn+0x3c0>
		if (i >= filesz) {
  801e87:	39 fb                	cmp    %edi,%ebx
  801e89:	72 27                	jb     801eb2 <spawn+0x2f4>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801e8b:	83 ec 04             	sub    $0x4,%esp
  801e8e:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801e94:	56                   	push   %esi
  801e95:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801e9b:	e8 bc ed ff ff       	call   800c5c <sys_page_alloc>
  801ea0:	83 c4 10             	add    $0x10,%esp
  801ea3:	85 c0                	test   %eax,%eax
  801ea5:	0f 89 c7 00 00 00    	jns    801f72 <spawn+0x3b4>
  801eab:	89 c3                	mov    %eax,%ebx
  801ead:	e9 fd 01 00 00       	jmp    8020af <spawn+0x4f1>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801eb2:	83 ec 04             	sub    $0x4,%esp
  801eb5:	6a 07                	push   $0x7
  801eb7:	68 00 00 40 00       	push   $0x400000
  801ebc:	6a 00                	push   $0x0
  801ebe:	e8 99 ed ff ff       	call   800c5c <sys_page_alloc>
  801ec3:	83 c4 10             	add    $0x10,%esp
  801ec6:	85 c0                	test   %eax,%eax
  801ec8:	0f 88 d7 01 00 00    	js     8020a5 <spawn+0x4e7>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801ece:	83 ec 08             	sub    $0x8,%esp
  801ed1:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801ed7:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801edd:	50                   	push   %eax
  801ede:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ee4:	e8 09 f9 ff ff       	call   8017f2 <seek>
  801ee9:	83 c4 10             	add    $0x10,%esp
  801eec:	85 c0                	test   %eax,%eax
  801eee:	0f 88 b5 01 00 00    	js     8020a9 <spawn+0x4eb>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801ef4:	83 ec 04             	sub    $0x4,%esp
  801ef7:	89 f8                	mov    %edi,%eax
  801ef9:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801eff:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801f04:	ba 00 10 00 00       	mov    $0x1000,%edx
  801f09:	0f 47 c2             	cmova  %edx,%eax
  801f0c:	50                   	push   %eax
  801f0d:	68 00 00 40 00       	push   $0x400000
  801f12:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801f18:	e8 fd f7 ff ff       	call   80171a <readn>
  801f1d:	83 c4 10             	add    $0x10,%esp
  801f20:	85 c0                	test   %eax,%eax
  801f22:	0f 88 85 01 00 00    	js     8020ad <spawn+0x4ef>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801f28:	83 ec 0c             	sub    $0xc,%esp
  801f2b:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801f31:	56                   	push   %esi
  801f32:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801f38:	68 00 00 40 00       	push   $0x400000
  801f3d:	6a 00                	push   $0x0
  801f3f:	e8 5b ed ff ff       	call   800c9f <sys_page_map>
  801f44:	83 c4 20             	add    $0x20,%esp
  801f47:	85 c0                	test   %eax,%eax
  801f49:	79 15                	jns    801f60 <spawn+0x3a2>
				panic("spawn: sys_page_map data: %e", r);
  801f4b:	50                   	push   %eax
  801f4c:	68 dd 30 80 00       	push   $0x8030dd
  801f51:	68 25 01 00 00       	push   $0x125
  801f56:	68 d1 30 80 00       	push   $0x8030d1
  801f5b:	e8 9b e2 ff ff       	call   8001fb <_panic>
			sys_page_unmap(0, UTEMP);
  801f60:	83 ec 08             	sub    $0x8,%esp
  801f63:	68 00 00 40 00       	push   $0x400000
  801f68:	6a 00                	push   $0x0
  801f6a:	e8 72 ed ff ff       	call   800ce1 <sys_page_unmap>
  801f6f:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801f72:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801f78:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801f7e:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801f84:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801f8a:	0f 82 f7 fe ff ff    	jb     801e87 <spawn+0x2c9>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f90:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801f97:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801f9e:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801fa5:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801fab:	0f 8c 65 fe ff ff    	jl     801e16 <spawn+0x258>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801fb1:	83 ec 0c             	sub    $0xc,%esp
  801fb4:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801fba:	e8 8b f5 ff ff       	call   80154a <close>
  801fbf:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801fc2:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fc7:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801fcd:	89 d8                	mov    %ebx,%eax
  801fcf:	c1 e8 16             	shr    $0x16,%eax
  801fd2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801fd9:	a8 01                	test   $0x1,%al
  801fdb:	74 42                	je     80201f <spawn+0x461>
  801fdd:	89 d8                	mov    %ebx,%eax
  801fdf:	c1 e8 0c             	shr    $0xc,%eax
  801fe2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801fe9:	f6 c2 01             	test   $0x1,%dl
  801fec:	74 31                	je     80201f <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  801fee:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801ff5:	f6 c6 04             	test   $0x4,%dh
  801ff8:	74 25                	je     80201f <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  801ffa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802001:	83 ec 0c             	sub    $0xc,%esp
  802004:	25 07 0e 00 00       	and    $0xe07,%eax
  802009:	50                   	push   %eax
  80200a:	53                   	push   %ebx
  80200b:	56                   	push   %esi
  80200c:	53                   	push   %ebx
  80200d:	6a 00                	push   $0x0
  80200f:	e8 8b ec ff ff       	call   800c9f <sys_page_map>
			if (r < 0) {
  802014:	83 c4 20             	add    $0x20,%esp
  802017:	85 c0                	test   %eax,%eax
  802019:	0f 88 b1 00 00 00    	js     8020d0 <spawn+0x512>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  80201f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802025:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  80202b:	75 a0                	jne    801fcd <spawn+0x40f>
  80202d:	e9 b3 00 00 00       	jmp    8020e5 <spawn+0x527>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  802032:	50                   	push   %eax
  802033:	68 fa 30 80 00       	push   $0x8030fa
  802038:	68 86 00 00 00       	push   $0x86
  80203d:	68 d1 30 80 00       	push   $0x8030d1
  802042:	e8 b4 e1 ff ff       	call   8001fb <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802047:	83 ec 08             	sub    $0x8,%esp
  80204a:	6a 02                	push   $0x2
  80204c:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802052:	e8 cc ec ff ff       	call   800d23 <sys_env_set_status>
  802057:	83 c4 10             	add    $0x10,%esp
  80205a:	85 c0                	test   %eax,%eax
  80205c:	79 2b                	jns    802089 <spawn+0x4cb>
		panic("sys_env_set_status: %e", r);
  80205e:	50                   	push   %eax
  80205f:	68 14 31 80 00       	push   $0x803114
  802064:	68 89 00 00 00       	push   $0x89
  802069:	68 d1 30 80 00       	push   $0x8030d1
  80206e:	e8 88 e1 ff ff       	call   8001fb <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802073:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  802079:	e9 a8 00 00 00       	jmp    802126 <spawn+0x568>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  80207e:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802084:	e9 9d 00 00 00       	jmp    802126 <spawn+0x568>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  802089:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  80208f:	e9 92 00 00 00       	jmp    802126 <spawn+0x568>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802094:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  802099:	e9 88 00 00 00       	jmp    802126 <spawn+0x568>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  80209e:	89 c3                	mov    %eax,%ebx
  8020a0:	e9 81 00 00 00       	jmp    802126 <spawn+0x568>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8020a5:	89 c3                	mov    %eax,%ebx
  8020a7:	eb 06                	jmp    8020af <spawn+0x4f1>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8020a9:	89 c3                	mov    %eax,%ebx
  8020ab:	eb 02                	jmp    8020af <spawn+0x4f1>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8020ad:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  8020af:	83 ec 0c             	sub    $0xc,%esp
  8020b2:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8020b8:	e8 20 eb ff ff       	call   800bdd <sys_env_destroy>
	close(fd);
  8020bd:	83 c4 04             	add    $0x4,%esp
  8020c0:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8020c6:	e8 7f f4 ff ff       	call   80154a <close>
	return r;
  8020cb:	83 c4 10             	add    $0x10,%esp
  8020ce:	eb 56                	jmp    802126 <spawn+0x568>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  8020d0:	50                   	push   %eax
  8020d1:	68 2b 31 80 00       	push   $0x80312b
  8020d6:	68 82 00 00 00       	push   $0x82
  8020db:	68 d1 30 80 00       	push   $0x8030d1
  8020e0:	e8 16 e1 ff ff       	call   8001fb <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  8020e5:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  8020ec:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8020ef:	83 ec 08             	sub    $0x8,%esp
  8020f2:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8020f8:	50                   	push   %eax
  8020f9:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8020ff:	e8 61 ec ff ff       	call   800d65 <sys_env_set_trapframe>
  802104:	83 c4 10             	add    $0x10,%esp
  802107:	85 c0                	test   %eax,%eax
  802109:	0f 89 38 ff ff ff    	jns    802047 <spawn+0x489>
  80210f:	e9 1e ff ff ff       	jmp    802032 <spawn+0x474>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802114:	83 ec 08             	sub    $0x8,%esp
  802117:	68 00 00 40 00       	push   $0x400000
  80211c:	6a 00                	push   $0x0
  80211e:	e8 be eb ff ff       	call   800ce1 <sys_page_unmap>
  802123:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802126:	89 d8                	mov    %ebx,%eax
  802128:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80212b:	5b                   	pop    %ebx
  80212c:	5e                   	pop    %esi
  80212d:	5f                   	pop    %edi
  80212e:	5d                   	pop    %ebp
  80212f:	c3                   	ret    

00802130 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802130:	55                   	push   %ebp
  802131:	89 e5                	mov    %esp,%ebp
  802133:	56                   	push   %esi
  802134:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802135:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802138:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80213d:	eb 03                	jmp    802142 <spawnl+0x12>
		argc++;
  80213f:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802142:	83 c2 04             	add    $0x4,%edx
  802145:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802149:	75 f4                	jne    80213f <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80214b:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802152:	83 e2 f0             	and    $0xfffffff0,%edx
  802155:	29 d4                	sub    %edx,%esp
  802157:	8d 54 24 03          	lea    0x3(%esp),%edx
  80215b:	c1 ea 02             	shr    $0x2,%edx
  80215e:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802165:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802167:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80216a:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802171:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802178:	00 
  802179:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  80217b:	b8 00 00 00 00       	mov    $0x0,%eax
  802180:	eb 0a                	jmp    80218c <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802182:	83 c0 01             	add    $0x1,%eax
  802185:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802189:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  80218c:	39 d0                	cmp    %edx,%eax
  80218e:	75 f2                	jne    802182 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802190:	83 ec 08             	sub    $0x8,%esp
  802193:	56                   	push   %esi
  802194:	ff 75 08             	pushl  0x8(%ebp)
  802197:	e8 22 fa ff ff       	call   801bbe <spawn>
}
  80219c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80219f:	5b                   	pop    %ebx
  8021a0:	5e                   	pop    %esi
  8021a1:	5d                   	pop    %ebp
  8021a2:	c3                   	ret    

008021a3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8021a3:	55                   	push   %ebp
  8021a4:	89 e5                	mov    %esp,%ebp
  8021a6:	56                   	push   %esi
  8021a7:	53                   	push   %ebx
  8021a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8021ab:	83 ec 0c             	sub    $0xc,%esp
  8021ae:	ff 75 08             	pushl  0x8(%ebp)
  8021b1:	e8 01 f2 ff ff       	call   8013b7 <fd2data>
  8021b6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8021b8:	83 c4 08             	add    $0x8,%esp
  8021bb:	68 6c 31 80 00       	push   $0x80316c
  8021c0:	53                   	push   %ebx
  8021c1:	e8 93 e6 ff ff       	call   800859 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8021c6:	8b 46 04             	mov    0x4(%esi),%eax
  8021c9:	2b 06                	sub    (%esi),%eax
  8021cb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8021d1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8021d8:	00 00 00 
	stat->st_dev = &devpipe;
  8021db:	c7 83 88 00 00 00 28 	movl   $0x804028,0x88(%ebx)
  8021e2:	40 80 00 
	return 0;
}
  8021e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8021ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021ed:	5b                   	pop    %ebx
  8021ee:	5e                   	pop    %esi
  8021ef:	5d                   	pop    %ebp
  8021f0:	c3                   	ret    

008021f1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8021f1:	55                   	push   %ebp
  8021f2:	89 e5                	mov    %esp,%ebp
  8021f4:	53                   	push   %ebx
  8021f5:	83 ec 0c             	sub    $0xc,%esp
  8021f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8021fb:	53                   	push   %ebx
  8021fc:	6a 00                	push   $0x0
  8021fe:	e8 de ea ff ff       	call   800ce1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802203:	89 1c 24             	mov    %ebx,(%esp)
  802206:	e8 ac f1 ff ff       	call   8013b7 <fd2data>
  80220b:	83 c4 08             	add    $0x8,%esp
  80220e:	50                   	push   %eax
  80220f:	6a 00                	push   $0x0
  802211:	e8 cb ea ff ff       	call   800ce1 <sys_page_unmap>
}
  802216:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802219:	c9                   	leave  
  80221a:	c3                   	ret    

0080221b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80221b:	55                   	push   %ebp
  80221c:	89 e5                	mov    %esp,%ebp
  80221e:	57                   	push   %edi
  80221f:	56                   	push   %esi
  802220:	53                   	push   %ebx
  802221:	83 ec 1c             	sub    $0x1c,%esp
  802224:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802227:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802229:	a1 04 50 80 00       	mov    0x805004,%eax
  80222e:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802234:	83 ec 0c             	sub    $0xc,%esp
  802237:	ff 75 e0             	pushl  -0x20(%ebp)
  80223a:	e8 55 06 00 00       	call   802894 <pageref>
  80223f:	89 c3                	mov    %eax,%ebx
  802241:	89 3c 24             	mov    %edi,(%esp)
  802244:	e8 4b 06 00 00       	call   802894 <pageref>
  802249:	83 c4 10             	add    $0x10,%esp
  80224c:	39 c3                	cmp    %eax,%ebx
  80224e:	0f 94 c1             	sete   %cl
  802251:	0f b6 c9             	movzbl %cl,%ecx
  802254:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802257:	8b 15 04 50 80 00    	mov    0x805004,%edx
  80225d:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  802263:	39 ce                	cmp    %ecx,%esi
  802265:	74 1e                	je     802285 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  802267:	39 c3                	cmp    %eax,%ebx
  802269:	75 be                	jne    802229 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80226b:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  802271:	ff 75 e4             	pushl  -0x1c(%ebp)
  802274:	50                   	push   %eax
  802275:	56                   	push   %esi
  802276:	68 73 31 80 00       	push   $0x803173
  80227b:	e8 54 e0 ff ff       	call   8002d4 <cprintf>
  802280:	83 c4 10             	add    $0x10,%esp
  802283:	eb a4                	jmp    802229 <_pipeisclosed+0xe>
	}
}
  802285:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802288:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80228b:	5b                   	pop    %ebx
  80228c:	5e                   	pop    %esi
  80228d:	5f                   	pop    %edi
  80228e:	5d                   	pop    %ebp
  80228f:	c3                   	ret    

00802290 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802290:	55                   	push   %ebp
  802291:	89 e5                	mov    %esp,%ebp
  802293:	57                   	push   %edi
  802294:	56                   	push   %esi
  802295:	53                   	push   %ebx
  802296:	83 ec 28             	sub    $0x28,%esp
  802299:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80229c:	56                   	push   %esi
  80229d:	e8 15 f1 ff ff       	call   8013b7 <fd2data>
  8022a2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022a4:	83 c4 10             	add    $0x10,%esp
  8022a7:	bf 00 00 00 00       	mov    $0x0,%edi
  8022ac:	eb 4b                	jmp    8022f9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8022ae:	89 da                	mov    %ebx,%edx
  8022b0:	89 f0                	mov    %esi,%eax
  8022b2:	e8 64 ff ff ff       	call   80221b <_pipeisclosed>
  8022b7:	85 c0                	test   %eax,%eax
  8022b9:	75 48                	jne    802303 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8022bb:	e8 7d e9 ff ff       	call   800c3d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8022c0:	8b 43 04             	mov    0x4(%ebx),%eax
  8022c3:	8b 0b                	mov    (%ebx),%ecx
  8022c5:	8d 51 20             	lea    0x20(%ecx),%edx
  8022c8:	39 d0                	cmp    %edx,%eax
  8022ca:	73 e2                	jae    8022ae <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8022cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022cf:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8022d3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8022d6:	89 c2                	mov    %eax,%edx
  8022d8:	c1 fa 1f             	sar    $0x1f,%edx
  8022db:	89 d1                	mov    %edx,%ecx
  8022dd:	c1 e9 1b             	shr    $0x1b,%ecx
  8022e0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8022e3:	83 e2 1f             	and    $0x1f,%edx
  8022e6:	29 ca                	sub    %ecx,%edx
  8022e8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8022ec:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8022f0:	83 c0 01             	add    $0x1,%eax
  8022f3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022f6:	83 c7 01             	add    $0x1,%edi
  8022f9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8022fc:	75 c2                	jne    8022c0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8022fe:	8b 45 10             	mov    0x10(%ebp),%eax
  802301:	eb 05                	jmp    802308 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802303:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802308:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80230b:	5b                   	pop    %ebx
  80230c:	5e                   	pop    %esi
  80230d:	5f                   	pop    %edi
  80230e:	5d                   	pop    %ebp
  80230f:	c3                   	ret    

00802310 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802310:	55                   	push   %ebp
  802311:	89 e5                	mov    %esp,%ebp
  802313:	57                   	push   %edi
  802314:	56                   	push   %esi
  802315:	53                   	push   %ebx
  802316:	83 ec 18             	sub    $0x18,%esp
  802319:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80231c:	57                   	push   %edi
  80231d:	e8 95 f0 ff ff       	call   8013b7 <fd2data>
  802322:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802324:	83 c4 10             	add    $0x10,%esp
  802327:	bb 00 00 00 00       	mov    $0x0,%ebx
  80232c:	eb 3d                	jmp    80236b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80232e:	85 db                	test   %ebx,%ebx
  802330:	74 04                	je     802336 <devpipe_read+0x26>
				return i;
  802332:	89 d8                	mov    %ebx,%eax
  802334:	eb 44                	jmp    80237a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802336:	89 f2                	mov    %esi,%edx
  802338:	89 f8                	mov    %edi,%eax
  80233a:	e8 dc fe ff ff       	call   80221b <_pipeisclosed>
  80233f:	85 c0                	test   %eax,%eax
  802341:	75 32                	jne    802375 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802343:	e8 f5 e8 ff ff       	call   800c3d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802348:	8b 06                	mov    (%esi),%eax
  80234a:	3b 46 04             	cmp    0x4(%esi),%eax
  80234d:	74 df                	je     80232e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80234f:	99                   	cltd   
  802350:	c1 ea 1b             	shr    $0x1b,%edx
  802353:	01 d0                	add    %edx,%eax
  802355:	83 e0 1f             	and    $0x1f,%eax
  802358:	29 d0                	sub    %edx,%eax
  80235a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80235f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802362:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802365:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802368:	83 c3 01             	add    $0x1,%ebx
  80236b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80236e:	75 d8                	jne    802348 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802370:	8b 45 10             	mov    0x10(%ebp),%eax
  802373:	eb 05                	jmp    80237a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802375:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80237a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80237d:	5b                   	pop    %ebx
  80237e:	5e                   	pop    %esi
  80237f:	5f                   	pop    %edi
  802380:	5d                   	pop    %ebp
  802381:	c3                   	ret    

00802382 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802382:	55                   	push   %ebp
  802383:	89 e5                	mov    %esp,%ebp
  802385:	56                   	push   %esi
  802386:	53                   	push   %ebx
  802387:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80238a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80238d:	50                   	push   %eax
  80238e:	e8 3b f0 ff ff       	call   8013ce <fd_alloc>
  802393:	83 c4 10             	add    $0x10,%esp
  802396:	89 c2                	mov    %eax,%edx
  802398:	85 c0                	test   %eax,%eax
  80239a:	0f 88 2c 01 00 00    	js     8024cc <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023a0:	83 ec 04             	sub    $0x4,%esp
  8023a3:	68 07 04 00 00       	push   $0x407
  8023a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8023ab:	6a 00                	push   $0x0
  8023ad:	e8 aa e8 ff ff       	call   800c5c <sys_page_alloc>
  8023b2:	83 c4 10             	add    $0x10,%esp
  8023b5:	89 c2                	mov    %eax,%edx
  8023b7:	85 c0                	test   %eax,%eax
  8023b9:	0f 88 0d 01 00 00    	js     8024cc <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8023bf:	83 ec 0c             	sub    $0xc,%esp
  8023c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8023c5:	50                   	push   %eax
  8023c6:	e8 03 f0 ff ff       	call   8013ce <fd_alloc>
  8023cb:	89 c3                	mov    %eax,%ebx
  8023cd:	83 c4 10             	add    $0x10,%esp
  8023d0:	85 c0                	test   %eax,%eax
  8023d2:	0f 88 e2 00 00 00    	js     8024ba <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023d8:	83 ec 04             	sub    $0x4,%esp
  8023db:	68 07 04 00 00       	push   $0x407
  8023e0:	ff 75 f0             	pushl  -0x10(%ebp)
  8023e3:	6a 00                	push   $0x0
  8023e5:	e8 72 e8 ff ff       	call   800c5c <sys_page_alloc>
  8023ea:	89 c3                	mov    %eax,%ebx
  8023ec:	83 c4 10             	add    $0x10,%esp
  8023ef:	85 c0                	test   %eax,%eax
  8023f1:	0f 88 c3 00 00 00    	js     8024ba <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8023f7:	83 ec 0c             	sub    $0xc,%esp
  8023fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8023fd:	e8 b5 ef ff ff       	call   8013b7 <fd2data>
  802402:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802404:	83 c4 0c             	add    $0xc,%esp
  802407:	68 07 04 00 00       	push   $0x407
  80240c:	50                   	push   %eax
  80240d:	6a 00                	push   $0x0
  80240f:	e8 48 e8 ff ff       	call   800c5c <sys_page_alloc>
  802414:	89 c3                	mov    %eax,%ebx
  802416:	83 c4 10             	add    $0x10,%esp
  802419:	85 c0                	test   %eax,%eax
  80241b:	0f 88 89 00 00 00    	js     8024aa <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802421:	83 ec 0c             	sub    $0xc,%esp
  802424:	ff 75 f0             	pushl  -0x10(%ebp)
  802427:	e8 8b ef ff ff       	call   8013b7 <fd2data>
  80242c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802433:	50                   	push   %eax
  802434:	6a 00                	push   $0x0
  802436:	56                   	push   %esi
  802437:	6a 00                	push   $0x0
  802439:	e8 61 e8 ff ff       	call   800c9f <sys_page_map>
  80243e:	89 c3                	mov    %eax,%ebx
  802440:	83 c4 20             	add    $0x20,%esp
  802443:	85 c0                	test   %eax,%eax
  802445:	78 55                	js     80249c <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802447:	8b 15 28 40 80 00    	mov    0x804028,%edx
  80244d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802450:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802452:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802455:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80245c:	8b 15 28 40 80 00    	mov    0x804028,%edx
  802462:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802465:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802467:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80246a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802471:	83 ec 0c             	sub    $0xc,%esp
  802474:	ff 75 f4             	pushl  -0xc(%ebp)
  802477:	e8 2b ef ff ff       	call   8013a7 <fd2num>
  80247c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80247f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802481:	83 c4 04             	add    $0x4,%esp
  802484:	ff 75 f0             	pushl  -0x10(%ebp)
  802487:	e8 1b ef ff ff       	call   8013a7 <fd2num>
  80248c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80248f:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  802492:	83 c4 10             	add    $0x10,%esp
  802495:	ba 00 00 00 00       	mov    $0x0,%edx
  80249a:	eb 30                	jmp    8024cc <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80249c:	83 ec 08             	sub    $0x8,%esp
  80249f:	56                   	push   %esi
  8024a0:	6a 00                	push   $0x0
  8024a2:	e8 3a e8 ff ff       	call   800ce1 <sys_page_unmap>
  8024a7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8024aa:	83 ec 08             	sub    $0x8,%esp
  8024ad:	ff 75 f0             	pushl  -0x10(%ebp)
  8024b0:	6a 00                	push   $0x0
  8024b2:	e8 2a e8 ff ff       	call   800ce1 <sys_page_unmap>
  8024b7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8024ba:	83 ec 08             	sub    $0x8,%esp
  8024bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8024c0:	6a 00                	push   $0x0
  8024c2:	e8 1a e8 ff ff       	call   800ce1 <sys_page_unmap>
  8024c7:	83 c4 10             	add    $0x10,%esp
  8024ca:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8024cc:	89 d0                	mov    %edx,%eax
  8024ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024d1:	5b                   	pop    %ebx
  8024d2:	5e                   	pop    %esi
  8024d3:	5d                   	pop    %ebp
  8024d4:	c3                   	ret    

008024d5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8024d5:	55                   	push   %ebp
  8024d6:	89 e5                	mov    %esp,%ebp
  8024d8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024de:	50                   	push   %eax
  8024df:	ff 75 08             	pushl  0x8(%ebp)
  8024e2:	e8 36 ef ff ff       	call   80141d <fd_lookup>
  8024e7:	83 c4 10             	add    $0x10,%esp
  8024ea:	85 c0                	test   %eax,%eax
  8024ec:	78 18                	js     802506 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8024ee:	83 ec 0c             	sub    $0xc,%esp
  8024f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8024f4:	e8 be ee ff ff       	call   8013b7 <fd2data>
	return _pipeisclosed(fd, p);
  8024f9:	89 c2                	mov    %eax,%edx
  8024fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024fe:	e8 18 fd ff ff       	call   80221b <_pipeisclosed>
  802503:	83 c4 10             	add    $0x10,%esp
}
  802506:	c9                   	leave  
  802507:	c3                   	ret    

00802508 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802508:	55                   	push   %ebp
  802509:	89 e5                	mov    %esp,%ebp
  80250b:	56                   	push   %esi
  80250c:	53                   	push   %ebx
  80250d:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802510:	85 f6                	test   %esi,%esi
  802512:	75 16                	jne    80252a <wait+0x22>
  802514:	68 8b 31 80 00       	push   $0x80318b
  802519:	68 8b 30 80 00       	push   $0x80308b
  80251e:	6a 09                	push   $0x9
  802520:	68 96 31 80 00       	push   $0x803196
  802525:	e8 d1 dc ff ff       	call   8001fb <_panic>
	e = &envs[ENVX(envid)];
  80252a:	89 f3                	mov    %esi,%ebx
  80252c:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802532:	69 db d4 00 00 00    	imul   $0xd4,%ebx,%ebx
  802538:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80253e:	eb 05                	jmp    802545 <wait+0x3d>
		sys_yield();
  802540:	e8 f8 e6 ff ff       	call   800c3d <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802545:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
  80254b:	39 c6                	cmp    %eax,%esi
  80254d:	75 0a                	jne    802559 <wait+0x51>
  80254f:	8b 83 ac 00 00 00    	mov    0xac(%ebx),%eax
  802555:	85 c0                	test   %eax,%eax
  802557:	75 e7                	jne    802540 <wait+0x38>
		sys_yield();
}
  802559:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80255c:	5b                   	pop    %ebx
  80255d:	5e                   	pop    %esi
  80255e:	5d                   	pop    %ebp
  80255f:	c3                   	ret    

00802560 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802560:	55                   	push   %ebp
  802561:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802563:	b8 00 00 00 00       	mov    $0x0,%eax
  802568:	5d                   	pop    %ebp
  802569:	c3                   	ret    

0080256a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80256a:	55                   	push   %ebp
  80256b:	89 e5                	mov    %esp,%ebp
  80256d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802570:	68 a1 31 80 00       	push   $0x8031a1
  802575:	ff 75 0c             	pushl  0xc(%ebp)
  802578:	e8 dc e2 ff ff       	call   800859 <strcpy>
	return 0;
}
  80257d:	b8 00 00 00 00       	mov    $0x0,%eax
  802582:	c9                   	leave  
  802583:	c3                   	ret    

00802584 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802584:	55                   	push   %ebp
  802585:	89 e5                	mov    %esp,%ebp
  802587:	57                   	push   %edi
  802588:	56                   	push   %esi
  802589:	53                   	push   %ebx
  80258a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802590:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802595:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80259b:	eb 2d                	jmp    8025ca <devcons_write+0x46>
		m = n - tot;
  80259d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025a0:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8025a2:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8025a5:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8025aa:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8025ad:	83 ec 04             	sub    $0x4,%esp
  8025b0:	53                   	push   %ebx
  8025b1:	03 45 0c             	add    0xc(%ebp),%eax
  8025b4:	50                   	push   %eax
  8025b5:	57                   	push   %edi
  8025b6:	e8 30 e4 ff ff       	call   8009eb <memmove>
		sys_cputs(buf, m);
  8025bb:	83 c4 08             	add    $0x8,%esp
  8025be:	53                   	push   %ebx
  8025bf:	57                   	push   %edi
  8025c0:	e8 db e5 ff ff       	call   800ba0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8025c5:	01 de                	add    %ebx,%esi
  8025c7:	83 c4 10             	add    $0x10,%esp
  8025ca:	89 f0                	mov    %esi,%eax
  8025cc:	3b 75 10             	cmp    0x10(%ebp),%esi
  8025cf:	72 cc                	jb     80259d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8025d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025d4:	5b                   	pop    %ebx
  8025d5:	5e                   	pop    %esi
  8025d6:	5f                   	pop    %edi
  8025d7:	5d                   	pop    %ebp
  8025d8:	c3                   	ret    

008025d9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8025d9:	55                   	push   %ebp
  8025da:	89 e5                	mov    %esp,%ebp
  8025dc:	83 ec 08             	sub    $0x8,%esp
  8025df:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8025e4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8025e8:	74 2a                	je     802614 <devcons_read+0x3b>
  8025ea:	eb 05                	jmp    8025f1 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8025ec:	e8 4c e6 ff ff       	call   800c3d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8025f1:	e8 c8 e5 ff ff       	call   800bbe <sys_cgetc>
  8025f6:	85 c0                	test   %eax,%eax
  8025f8:	74 f2                	je     8025ec <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8025fa:	85 c0                	test   %eax,%eax
  8025fc:	78 16                	js     802614 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8025fe:	83 f8 04             	cmp    $0x4,%eax
  802601:	74 0c                	je     80260f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802603:	8b 55 0c             	mov    0xc(%ebp),%edx
  802606:	88 02                	mov    %al,(%edx)
	return 1;
  802608:	b8 01 00 00 00       	mov    $0x1,%eax
  80260d:	eb 05                	jmp    802614 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80260f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802614:	c9                   	leave  
  802615:	c3                   	ret    

00802616 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802616:	55                   	push   %ebp
  802617:	89 e5                	mov    %esp,%ebp
  802619:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80261c:	8b 45 08             	mov    0x8(%ebp),%eax
  80261f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802622:	6a 01                	push   $0x1
  802624:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802627:	50                   	push   %eax
  802628:	e8 73 e5 ff ff       	call   800ba0 <sys_cputs>
}
  80262d:	83 c4 10             	add    $0x10,%esp
  802630:	c9                   	leave  
  802631:	c3                   	ret    

00802632 <getchar>:

int
getchar(void)
{
  802632:	55                   	push   %ebp
  802633:	89 e5                	mov    %esp,%ebp
  802635:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802638:	6a 01                	push   $0x1
  80263a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80263d:	50                   	push   %eax
  80263e:	6a 00                	push   $0x0
  802640:	e8 41 f0 ff ff       	call   801686 <read>
	if (r < 0)
  802645:	83 c4 10             	add    $0x10,%esp
  802648:	85 c0                	test   %eax,%eax
  80264a:	78 0f                	js     80265b <getchar+0x29>
		return r;
	if (r < 1)
  80264c:	85 c0                	test   %eax,%eax
  80264e:	7e 06                	jle    802656 <getchar+0x24>
		return -E_EOF;
	return c;
  802650:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802654:	eb 05                	jmp    80265b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802656:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80265b:	c9                   	leave  
  80265c:	c3                   	ret    

0080265d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80265d:	55                   	push   %ebp
  80265e:	89 e5                	mov    %esp,%ebp
  802660:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802663:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802666:	50                   	push   %eax
  802667:	ff 75 08             	pushl  0x8(%ebp)
  80266a:	e8 ae ed ff ff       	call   80141d <fd_lookup>
  80266f:	83 c4 10             	add    $0x10,%esp
  802672:	85 c0                	test   %eax,%eax
  802674:	78 11                	js     802687 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802676:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802679:	8b 15 44 40 80 00    	mov    0x804044,%edx
  80267f:	39 10                	cmp    %edx,(%eax)
  802681:	0f 94 c0             	sete   %al
  802684:	0f b6 c0             	movzbl %al,%eax
}
  802687:	c9                   	leave  
  802688:	c3                   	ret    

00802689 <opencons>:

int
opencons(void)
{
  802689:	55                   	push   %ebp
  80268a:	89 e5                	mov    %esp,%ebp
  80268c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80268f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802692:	50                   	push   %eax
  802693:	e8 36 ed ff ff       	call   8013ce <fd_alloc>
  802698:	83 c4 10             	add    $0x10,%esp
		return r;
  80269b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80269d:	85 c0                	test   %eax,%eax
  80269f:	78 3e                	js     8026df <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8026a1:	83 ec 04             	sub    $0x4,%esp
  8026a4:	68 07 04 00 00       	push   $0x407
  8026a9:	ff 75 f4             	pushl  -0xc(%ebp)
  8026ac:	6a 00                	push   $0x0
  8026ae:	e8 a9 e5 ff ff       	call   800c5c <sys_page_alloc>
  8026b3:	83 c4 10             	add    $0x10,%esp
		return r;
  8026b6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8026b8:	85 c0                	test   %eax,%eax
  8026ba:	78 23                	js     8026df <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8026bc:	8b 15 44 40 80 00    	mov    0x804044,%edx
  8026c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026c5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8026c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026ca:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8026d1:	83 ec 0c             	sub    $0xc,%esp
  8026d4:	50                   	push   %eax
  8026d5:	e8 cd ec ff ff       	call   8013a7 <fd2num>
  8026da:	89 c2                	mov    %eax,%edx
  8026dc:	83 c4 10             	add    $0x10,%esp
}
  8026df:	89 d0                	mov    %edx,%eax
  8026e1:	c9                   	leave  
  8026e2:	c3                   	ret    

008026e3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8026e3:	55                   	push   %ebp
  8026e4:	89 e5                	mov    %esp,%ebp
  8026e6:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8026e9:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8026f0:	75 2a                	jne    80271c <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  8026f2:	83 ec 04             	sub    $0x4,%esp
  8026f5:	6a 07                	push   $0x7
  8026f7:	68 00 f0 bf ee       	push   $0xeebff000
  8026fc:	6a 00                	push   $0x0
  8026fe:	e8 59 e5 ff ff       	call   800c5c <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802703:	83 c4 10             	add    $0x10,%esp
  802706:	85 c0                	test   %eax,%eax
  802708:	79 12                	jns    80271c <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80270a:	50                   	push   %eax
  80270b:	68 f2 2f 80 00       	push   $0x802ff2
  802710:	6a 23                	push   $0x23
  802712:	68 ad 31 80 00       	push   $0x8031ad
  802717:	e8 df da ff ff       	call   8001fb <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80271c:	8b 45 08             	mov    0x8(%ebp),%eax
  80271f:	a3 00 70 80 00       	mov    %eax,0x807000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802724:	83 ec 08             	sub    $0x8,%esp
  802727:	68 4e 27 80 00       	push   $0x80274e
  80272c:	6a 00                	push   $0x0
  80272e:	e8 74 e6 ff ff       	call   800da7 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802733:	83 c4 10             	add    $0x10,%esp
  802736:	85 c0                	test   %eax,%eax
  802738:	79 12                	jns    80274c <set_pgfault_handler+0x69>
		panic("%e\n", r);
  80273a:	50                   	push   %eax
  80273b:	68 f2 2f 80 00       	push   $0x802ff2
  802740:	6a 2c                	push   $0x2c
  802742:	68 ad 31 80 00       	push   $0x8031ad
  802747:	e8 af da ff ff       	call   8001fb <_panic>
	}
}
  80274c:	c9                   	leave  
  80274d:	c3                   	ret    

0080274e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80274e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80274f:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802754:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802756:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802759:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  80275d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802762:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802766:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802768:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  80276b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  80276c:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80276f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802770:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802771:	c3                   	ret    

00802772 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802772:	55                   	push   %ebp
  802773:	89 e5                	mov    %esp,%ebp
  802775:	56                   	push   %esi
  802776:	53                   	push   %ebx
  802777:	8b 75 08             	mov    0x8(%ebp),%esi
  80277a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80277d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802780:	85 c0                	test   %eax,%eax
  802782:	75 12                	jne    802796 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802784:	83 ec 0c             	sub    $0xc,%esp
  802787:	68 00 00 c0 ee       	push   $0xeec00000
  80278c:	e8 7b e6 ff ff       	call   800e0c <sys_ipc_recv>
  802791:	83 c4 10             	add    $0x10,%esp
  802794:	eb 0c                	jmp    8027a2 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802796:	83 ec 0c             	sub    $0xc,%esp
  802799:	50                   	push   %eax
  80279a:	e8 6d e6 ff ff       	call   800e0c <sys_ipc_recv>
  80279f:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8027a2:	85 f6                	test   %esi,%esi
  8027a4:	0f 95 c1             	setne  %cl
  8027a7:	85 db                	test   %ebx,%ebx
  8027a9:	0f 95 c2             	setne  %dl
  8027ac:	84 d1                	test   %dl,%cl
  8027ae:	74 09                	je     8027b9 <ipc_recv+0x47>
  8027b0:	89 c2                	mov    %eax,%edx
  8027b2:	c1 ea 1f             	shr    $0x1f,%edx
  8027b5:	84 d2                	test   %dl,%dl
  8027b7:	75 2d                	jne    8027e6 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8027b9:	85 f6                	test   %esi,%esi
  8027bb:	74 0d                	je     8027ca <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8027bd:	a1 04 50 80 00       	mov    0x805004,%eax
  8027c2:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  8027c8:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8027ca:	85 db                	test   %ebx,%ebx
  8027cc:	74 0d                	je     8027db <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8027ce:	a1 04 50 80 00       	mov    0x805004,%eax
  8027d3:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8027d9:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8027db:	a1 04 50 80 00       	mov    0x805004,%eax
  8027e0:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  8027e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8027e9:	5b                   	pop    %ebx
  8027ea:	5e                   	pop    %esi
  8027eb:	5d                   	pop    %ebp
  8027ec:	c3                   	ret    

008027ed <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8027ed:	55                   	push   %ebp
  8027ee:	89 e5                	mov    %esp,%ebp
  8027f0:	57                   	push   %edi
  8027f1:	56                   	push   %esi
  8027f2:	53                   	push   %ebx
  8027f3:	83 ec 0c             	sub    $0xc,%esp
  8027f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8027f9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8027fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8027ff:	85 db                	test   %ebx,%ebx
  802801:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802806:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802809:	ff 75 14             	pushl  0x14(%ebp)
  80280c:	53                   	push   %ebx
  80280d:	56                   	push   %esi
  80280e:	57                   	push   %edi
  80280f:	e8 d5 e5 ff ff       	call   800de9 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802814:	89 c2                	mov    %eax,%edx
  802816:	c1 ea 1f             	shr    $0x1f,%edx
  802819:	83 c4 10             	add    $0x10,%esp
  80281c:	84 d2                	test   %dl,%dl
  80281e:	74 17                	je     802837 <ipc_send+0x4a>
  802820:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802823:	74 12                	je     802837 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802825:	50                   	push   %eax
  802826:	68 bb 31 80 00       	push   $0x8031bb
  80282b:	6a 47                	push   $0x47
  80282d:	68 c9 31 80 00       	push   $0x8031c9
  802832:	e8 c4 d9 ff ff       	call   8001fb <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802837:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80283a:	75 07                	jne    802843 <ipc_send+0x56>
			sys_yield();
  80283c:	e8 fc e3 ff ff       	call   800c3d <sys_yield>
  802841:	eb c6                	jmp    802809 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802843:	85 c0                	test   %eax,%eax
  802845:	75 c2                	jne    802809 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802847:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80284a:	5b                   	pop    %ebx
  80284b:	5e                   	pop    %esi
  80284c:	5f                   	pop    %edi
  80284d:	5d                   	pop    %ebp
  80284e:	c3                   	ret    

0080284f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80284f:	55                   	push   %ebp
  802850:	89 e5                	mov    %esp,%ebp
  802852:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802855:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80285a:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  802860:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802866:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  80286c:	39 ca                	cmp    %ecx,%edx
  80286e:	75 13                	jne    802883 <ipc_find_env+0x34>
			return envs[i].env_id;
  802870:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  802876:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80287b:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  802881:	eb 0f                	jmp    802892 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802883:	83 c0 01             	add    $0x1,%eax
  802886:	3d 00 04 00 00       	cmp    $0x400,%eax
  80288b:	75 cd                	jne    80285a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80288d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802892:	5d                   	pop    %ebp
  802893:	c3                   	ret    

00802894 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802894:	55                   	push   %ebp
  802895:	89 e5                	mov    %esp,%ebp
  802897:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80289a:	89 d0                	mov    %edx,%eax
  80289c:	c1 e8 16             	shr    $0x16,%eax
  80289f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8028a6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8028ab:	f6 c1 01             	test   $0x1,%cl
  8028ae:	74 1d                	je     8028cd <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8028b0:	c1 ea 0c             	shr    $0xc,%edx
  8028b3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8028ba:	f6 c2 01             	test   $0x1,%dl
  8028bd:	74 0e                	je     8028cd <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8028bf:	c1 ea 0c             	shr    $0xc,%edx
  8028c2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8028c9:	ef 
  8028ca:	0f b7 c0             	movzwl %ax,%eax
}
  8028cd:	5d                   	pop    %ebp
  8028ce:	c3                   	ret    
  8028cf:	90                   	nop

008028d0 <__udivdi3>:
  8028d0:	55                   	push   %ebp
  8028d1:	57                   	push   %edi
  8028d2:	56                   	push   %esi
  8028d3:	53                   	push   %ebx
  8028d4:	83 ec 1c             	sub    $0x1c,%esp
  8028d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8028db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8028df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8028e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8028e7:	85 f6                	test   %esi,%esi
  8028e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8028ed:	89 ca                	mov    %ecx,%edx
  8028ef:	89 f8                	mov    %edi,%eax
  8028f1:	75 3d                	jne    802930 <__udivdi3+0x60>
  8028f3:	39 cf                	cmp    %ecx,%edi
  8028f5:	0f 87 c5 00 00 00    	ja     8029c0 <__udivdi3+0xf0>
  8028fb:	85 ff                	test   %edi,%edi
  8028fd:	89 fd                	mov    %edi,%ebp
  8028ff:	75 0b                	jne    80290c <__udivdi3+0x3c>
  802901:	b8 01 00 00 00       	mov    $0x1,%eax
  802906:	31 d2                	xor    %edx,%edx
  802908:	f7 f7                	div    %edi
  80290a:	89 c5                	mov    %eax,%ebp
  80290c:	89 c8                	mov    %ecx,%eax
  80290e:	31 d2                	xor    %edx,%edx
  802910:	f7 f5                	div    %ebp
  802912:	89 c1                	mov    %eax,%ecx
  802914:	89 d8                	mov    %ebx,%eax
  802916:	89 cf                	mov    %ecx,%edi
  802918:	f7 f5                	div    %ebp
  80291a:	89 c3                	mov    %eax,%ebx
  80291c:	89 d8                	mov    %ebx,%eax
  80291e:	89 fa                	mov    %edi,%edx
  802920:	83 c4 1c             	add    $0x1c,%esp
  802923:	5b                   	pop    %ebx
  802924:	5e                   	pop    %esi
  802925:	5f                   	pop    %edi
  802926:	5d                   	pop    %ebp
  802927:	c3                   	ret    
  802928:	90                   	nop
  802929:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802930:	39 ce                	cmp    %ecx,%esi
  802932:	77 74                	ja     8029a8 <__udivdi3+0xd8>
  802934:	0f bd fe             	bsr    %esi,%edi
  802937:	83 f7 1f             	xor    $0x1f,%edi
  80293a:	0f 84 98 00 00 00    	je     8029d8 <__udivdi3+0x108>
  802940:	bb 20 00 00 00       	mov    $0x20,%ebx
  802945:	89 f9                	mov    %edi,%ecx
  802947:	89 c5                	mov    %eax,%ebp
  802949:	29 fb                	sub    %edi,%ebx
  80294b:	d3 e6                	shl    %cl,%esi
  80294d:	89 d9                	mov    %ebx,%ecx
  80294f:	d3 ed                	shr    %cl,%ebp
  802951:	89 f9                	mov    %edi,%ecx
  802953:	d3 e0                	shl    %cl,%eax
  802955:	09 ee                	or     %ebp,%esi
  802957:	89 d9                	mov    %ebx,%ecx
  802959:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80295d:	89 d5                	mov    %edx,%ebp
  80295f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802963:	d3 ed                	shr    %cl,%ebp
  802965:	89 f9                	mov    %edi,%ecx
  802967:	d3 e2                	shl    %cl,%edx
  802969:	89 d9                	mov    %ebx,%ecx
  80296b:	d3 e8                	shr    %cl,%eax
  80296d:	09 c2                	or     %eax,%edx
  80296f:	89 d0                	mov    %edx,%eax
  802971:	89 ea                	mov    %ebp,%edx
  802973:	f7 f6                	div    %esi
  802975:	89 d5                	mov    %edx,%ebp
  802977:	89 c3                	mov    %eax,%ebx
  802979:	f7 64 24 0c          	mull   0xc(%esp)
  80297d:	39 d5                	cmp    %edx,%ebp
  80297f:	72 10                	jb     802991 <__udivdi3+0xc1>
  802981:	8b 74 24 08          	mov    0x8(%esp),%esi
  802985:	89 f9                	mov    %edi,%ecx
  802987:	d3 e6                	shl    %cl,%esi
  802989:	39 c6                	cmp    %eax,%esi
  80298b:	73 07                	jae    802994 <__udivdi3+0xc4>
  80298d:	39 d5                	cmp    %edx,%ebp
  80298f:	75 03                	jne    802994 <__udivdi3+0xc4>
  802991:	83 eb 01             	sub    $0x1,%ebx
  802994:	31 ff                	xor    %edi,%edi
  802996:	89 d8                	mov    %ebx,%eax
  802998:	89 fa                	mov    %edi,%edx
  80299a:	83 c4 1c             	add    $0x1c,%esp
  80299d:	5b                   	pop    %ebx
  80299e:	5e                   	pop    %esi
  80299f:	5f                   	pop    %edi
  8029a0:	5d                   	pop    %ebp
  8029a1:	c3                   	ret    
  8029a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8029a8:	31 ff                	xor    %edi,%edi
  8029aa:	31 db                	xor    %ebx,%ebx
  8029ac:	89 d8                	mov    %ebx,%eax
  8029ae:	89 fa                	mov    %edi,%edx
  8029b0:	83 c4 1c             	add    $0x1c,%esp
  8029b3:	5b                   	pop    %ebx
  8029b4:	5e                   	pop    %esi
  8029b5:	5f                   	pop    %edi
  8029b6:	5d                   	pop    %ebp
  8029b7:	c3                   	ret    
  8029b8:	90                   	nop
  8029b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8029c0:	89 d8                	mov    %ebx,%eax
  8029c2:	f7 f7                	div    %edi
  8029c4:	31 ff                	xor    %edi,%edi
  8029c6:	89 c3                	mov    %eax,%ebx
  8029c8:	89 d8                	mov    %ebx,%eax
  8029ca:	89 fa                	mov    %edi,%edx
  8029cc:	83 c4 1c             	add    $0x1c,%esp
  8029cf:	5b                   	pop    %ebx
  8029d0:	5e                   	pop    %esi
  8029d1:	5f                   	pop    %edi
  8029d2:	5d                   	pop    %ebp
  8029d3:	c3                   	ret    
  8029d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8029d8:	39 ce                	cmp    %ecx,%esi
  8029da:	72 0c                	jb     8029e8 <__udivdi3+0x118>
  8029dc:	31 db                	xor    %ebx,%ebx
  8029de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8029e2:	0f 87 34 ff ff ff    	ja     80291c <__udivdi3+0x4c>
  8029e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8029ed:	e9 2a ff ff ff       	jmp    80291c <__udivdi3+0x4c>
  8029f2:	66 90                	xchg   %ax,%ax
  8029f4:	66 90                	xchg   %ax,%ax
  8029f6:	66 90                	xchg   %ax,%ax
  8029f8:	66 90                	xchg   %ax,%ax
  8029fa:	66 90                	xchg   %ax,%ax
  8029fc:	66 90                	xchg   %ax,%ax
  8029fe:	66 90                	xchg   %ax,%ax

00802a00 <__umoddi3>:
  802a00:	55                   	push   %ebp
  802a01:	57                   	push   %edi
  802a02:	56                   	push   %esi
  802a03:	53                   	push   %ebx
  802a04:	83 ec 1c             	sub    $0x1c,%esp
  802a07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802a0b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802a0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802a13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802a17:	85 d2                	test   %edx,%edx
  802a19:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802a1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802a21:	89 f3                	mov    %esi,%ebx
  802a23:	89 3c 24             	mov    %edi,(%esp)
  802a26:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a2a:	75 1c                	jne    802a48 <__umoddi3+0x48>
  802a2c:	39 f7                	cmp    %esi,%edi
  802a2e:	76 50                	jbe    802a80 <__umoddi3+0x80>
  802a30:	89 c8                	mov    %ecx,%eax
  802a32:	89 f2                	mov    %esi,%edx
  802a34:	f7 f7                	div    %edi
  802a36:	89 d0                	mov    %edx,%eax
  802a38:	31 d2                	xor    %edx,%edx
  802a3a:	83 c4 1c             	add    $0x1c,%esp
  802a3d:	5b                   	pop    %ebx
  802a3e:	5e                   	pop    %esi
  802a3f:	5f                   	pop    %edi
  802a40:	5d                   	pop    %ebp
  802a41:	c3                   	ret    
  802a42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802a48:	39 f2                	cmp    %esi,%edx
  802a4a:	89 d0                	mov    %edx,%eax
  802a4c:	77 52                	ja     802aa0 <__umoddi3+0xa0>
  802a4e:	0f bd ea             	bsr    %edx,%ebp
  802a51:	83 f5 1f             	xor    $0x1f,%ebp
  802a54:	75 5a                	jne    802ab0 <__umoddi3+0xb0>
  802a56:	3b 54 24 04          	cmp    0x4(%esp),%edx
  802a5a:	0f 82 e0 00 00 00    	jb     802b40 <__umoddi3+0x140>
  802a60:	39 0c 24             	cmp    %ecx,(%esp)
  802a63:	0f 86 d7 00 00 00    	jbe    802b40 <__umoddi3+0x140>
  802a69:	8b 44 24 08          	mov    0x8(%esp),%eax
  802a6d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802a71:	83 c4 1c             	add    $0x1c,%esp
  802a74:	5b                   	pop    %ebx
  802a75:	5e                   	pop    %esi
  802a76:	5f                   	pop    %edi
  802a77:	5d                   	pop    %ebp
  802a78:	c3                   	ret    
  802a79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802a80:	85 ff                	test   %edi,%edi
  802a82:	89 fd                	mov    %edi,%ebp
  802a84:	75 0b                	jne    802a91 <__umoddi3+0x91>
  802a86:	b8 01 00 00 00       	mov    $0x1,%eax
  802a8b:	31 d2                	xor    %edx,%edx
  802a8d:	f7 f7                	div    %edi
  802a8f:	89 c5                	mov    %eax,%ebp
  802a91:	89 f0                	mov    %esi,%eax
  802a93:	31 d2                	xor    %edx,%edx
  802a95:	f7 f5                	div    %ebp
  802a97:	89 c8                	mov    %ecx,%eax
  802a99:	f7 f5                	div    %ebp
  802a9b:	89 d0                	mov    %edx,%eax
  802a9d:	eb 99                	jmp    802a38 <__umoddi3+0x38>
  802a9f:	90                   	nop
  802aa0:	89 c8                	mov    %ecx,%eax
  802aa2:	89 f2                	mov    %esi,%edx
  802aa4:	83 c4 1c             	add    $0x1c,%esp
  802aa7:	5b                   	pop    %ebx
  802aa8:	5e                   	pop    %esi
  802aa9:	5f                   	pop    %edi
  802aaa:	5d                   	pop    %ebp
  802aab:	c3                   	ret    
  802aac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ab0:	8b 34 24             	mov    (%esp),%esi
  802ab3:	bf 20 00 00 00       	mov    $0x20,%edi
  802ab8:	89 e9                	mov    %ebp,%ecx
  802aba:	29 ef                	sub    %ebp,%edi
  802abc:	d3 e0                	shl    %cl,%eax
  802abe:	89 f9                	mov    %edi,%ecx
  802ac0:	89 f2                	mov    %esi,%edx
  802ac2:	d3 ea                	shr    %cl,%edx
  802ac4:	89 e9                	mov    %ebp,%ecx
  802ac6:	09 c2                	or     %eax,%edx
  802ac8:	89 d8                	mov    %ebx,%eax
  802aca:	89 14 24             	mov    %edx,(%esp)
  802acd:	89 f2                	mov    %esi,%edx
  802acf:	d3 e2                	shl    %cl,%edx
  802ad1:	89 f9                	mov    %edi,%ecx
  802ad3:	89 54 24 04          	mov    %edx,0x4(%esp)
  802ad7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802adb:	d3 e8                	shr    %cl,%eax
  802add:	89 e9                	mov    %ebp,%ecx
  802adf:	89 c6                	mov    %eax,%esi
  802ae1:	d3 e3                	shl    %cl,%ebx
  802ae3:	89 f9                	mov    %edi,%ecx
  802ae5:	89 d0                	mov    %edx,%eax
  802ae7:	d3 e8                	shr    %cl,%eax
  802ae9:	89 e9                	mov    %ebp,%ecx
  802aeb:	09 d8                	or     %ebx,%eax
  802aed:	89 d3                	mov    %edx,%ebx
  802aef:	89 f2                	mov    %esi,%edx
  802af1:	f7 34 24             	divl   (%esp)
  802af4:	89 d6                	mov    %edx,%esi
  802af6:	d3 e3                	shl    %cl,%ebx
  802af8:	f7 64 24 04          	mull   0x4(%esp)
  802afc:	39 d6                	cmp    %edx,%esi
  802afe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802b02:	89 d1                	mov    %edx,%ecx
  802b04:	89 c3                	mov    %eax,%ebx
  802b06:	72 08                	jb     802b10 <__umoddi3+0x110>
  802b08:	75 11                	jne    802b1b <__umoddi3+0x11b>
  802b0a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802b0e:	73 0b                	jae    802b1b <__umoddi3+0x11b>
  802b10:	2b 44 24 04          	sub    0x4(%esp),%eax
  802b14:	1b 14 24             	sbb    (%esp),%edx
  802b17:	89 d1                	mov    %edx,%ecx
  802b19:	89 c3                	mov    %eax,%ebx
  802b1b:	8b 54 24 08          	mov    0x8(%esp),%edx
  802b1f:	29 da                	sub    %ebx,%edx
  802b21:	19 ce                	sbb    %ecx,%esi
  802b23:	89 f9                	mov    %edi,%ecx
  802b25:	89 f0                	mov    %esi,%eax
  802b27:	d3 e0                	shl    %cl,%eax
  802b29:	89 e9                	mov    %ebp,%ecx
  802b2b:	d3 ea                	shr    %cl,%edx
  802b2d:	89 e9                	mov    %ebp,%ecx
  802b2f:	d3 ee                	shr    %cl,%esi
  802b31:	09 d0                	or     %edx,%eax
  802b33:	89 f2                	mov    %esi,%edx
  802b35:	83 c4 1c             	add    $0x1c,%esp
  802b38:	5b                   	pop    %ebx
  802b39:	5e                   	pop    %esi
  802b3a:	5f                   	pop    %edi
  802b3b:	5d                   	pop    %ebp
  802b3c:	c3                   	ret    
  802b3d:	8d 76 00             	lea    0x0(%esi),%esi
  802b40:	29 f9                	sub    %edi,%ecx
  802b42:	19 d6                	sbb    %edx,%esi
  802b44:	89 74 24 04          	mov    %esi,0x4(%esp)
  802b48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802b4c:	e9 18 ff ff ff       	jmp    802a69 <__umoddi3+0x69>
