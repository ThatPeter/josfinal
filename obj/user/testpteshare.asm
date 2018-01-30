
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
  800081:	68 8c 2b 80 00       	push   $0x802b8c
  800086:	6a 13                	push   $0x13
  800088:	68 9f 2b 80 00       	push   $0x802b9f
  80008d:	e8 69 01 00 00       	call   8001fb <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 ec 0e 00 00       	call   800f83 <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 b3 2b 80 00       	push   $0x802bb3
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 9f 2b 80 00       	push   $0x802b9f
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
  8000d2:	e8 35 24 00 00       	call   80250c <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 40 80 00    	pushl  0x804004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 19 08 00 00       	call   800903 <strcmp>
  8000ea:	83 c4 08             	add    $0x8,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	ba 86 2b 80 00       	mov    $0x802b86,%edx
  8000f4:	b8 80 2b 80 00       	mov    $0x802b80,%eax
  8000f9:	0f 45 c2             	cmovne %edx,%eax
  8000fc:	50                   	push   %eax
  8000fd:	68 bc 2b 80 00       	push   $0x802bbc
  800102:	e8 cd 01 00 00       	call   8002d4 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800107:	6a 00                	push   $0x0
  800109:	68 d7 2b 80 00       	push   $0x802bd7
  80010e:	68 dc 2b 80 00       	push   $0x802bdc
  800113:	68 db 2b 80 00       	push   $0x802bdb
  800118:	e8 17 20 00 00       	call   802134 <spawnl>
  80011d:	83 c4 20             	add    $0x20,%esp
  800120:	85 c0                	test   %eax,%eax
  800122:	79 12                	jns    800136 <umain+0xe3>
		panic("spawn: %e", r);
  800124:	50                   	push   %eax
  800125:	68 e9 2b 80 00       	push   $0x802be9
  80012a:	6a 21                	push   $0x21
  80012c:	68 9f 2b 80 00       	push   $0x802b9f
  800131:	e8 c5 00 00 00       	call   8001fb <_panic>
	wait(r);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	e8 cd 23 00 00       	call   80250c <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff 35 00 40 80 00    	pushl  0x804000
  800148:	68 00 00 00 a0       	push   $0xa0000000
  80014d:	e8 b1 07 00 00       	call   800903 <strcmp>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba 86 2b 80 00       	mov    $0x802b86,%edx
  80015c:	b8 80 2b 80 00       	mov    $0x802b80,%eax
  800161:	0f 45 c2             	cmovne %edx,%eax
  800164:	50                   	push   %eax
  800165:	68 f3 2b 80 00       	push   $0x802bf3
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
  8001e7:	e8 8d 13 00 00       	call   801579 <close_all>
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
  800219:	68 38 2c 80 00       	push   $0x802c38
  80021e:	e8 b1 00 00 00       	call   8002d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800223:	83 c4 18             	add    $0x18,%esp
  800226:	53                   	push   %ebx
  800227:	ff 75 10             	pushl  0x10(%ebp)
  80022a:	e8 54 00 00 00       	call   800283 <vcprintf>
	cprintf("\n");
  80022f:	c7 04 24 fb 2f 80 00 	movl   $0x802ffb,(%esp)
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
  800337:	e8 a4 25 00 00       	call   8028e0 <__udivdi3>
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
  80037a:	e8 91 26 00 00       	call   802a10 <__umoddi3>
  80037f:	83 c4 14             	add    $0x14,%esp
  800382:	0f be 80 5b 2c 80 00 	movsbl 0x802c5b(%eax),%eax
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
  80047e:	ff 24 85 a0 2d 80 00 	jmp    *0x802da0(,%eax,4)
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
  800542:	8b 14 85 00 2f 80 00 	mov    0x802f00(,%eax,4),%edx
  800549:	85 d2                	test   %edx,%edx
  80054b:	75 18                	jne    800565 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80054d:	50                   	push   %eax
  80054e:	68 73 2c 80 00       	push   $0x802c73
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
  800566:	68 bd 30 80 00       	push   $0x8030bd
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
  80058a:	b8 6c 2c 80 00       	mov    $0x802c6c,%eax
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
  800c05:	68 5f 2f 80 00       	push   $0x802f5f
  800c0a:	6a 23                	push   $0x23
  800c0c:	68 7c 2f 80 00       	push   $0x802f7c
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
  800c86:	68 5f 2f 80 00       	push   $0x802f5f
  800c8b:	6a 23                	push   $0x23
  800c8d:	68 7c 2f 80 00       	push   $0x802f7c
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
  800cc8:	68 5f 2f 80 00       	push   $0x802f5f
  800ccd:	6a 23                	push   $0x23
  800ccf:	68 7c 2f 80 00       	push   $0x802f7c
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
  800d0a:	68 5f 2f 80 00       	push   $0x802f5f
  800d0f:	6a 23                	push   $0x23
  800d11:	68 7c 2f 80 00       	push   $0x802f7c
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
  800d4c:	68 5f 2f 80 00       	push   $0x802f5f
  800d51:	6a 23                	push   $0x23
  800d53:	68 7c 2f 80 00       	push   $0x802f7c
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
  800d8e:	68 5f 2f 80 00       	push   $0x802f5f
  800d93:	6a 23                	push   $0x23
  800d95:	68 7c 2f 80 00       	push   $0x802f7c
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
  800dd0:	68 5f 2f 80 00       	push   $0x802f5f
  800dd5:	6a 23                	push   $0x23
  800dd7:	68 7c 2f 80 00       	push   $0x802f7c
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
  800e34:	68 5f 2f 80 00       	push   $0x802f5f
  800e39:	6a 23                	push   $0x23
  800e3b:	68 7c 2f 80 00       	push   $0x802f7c
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
  800ed3:	68 8a 2f 80 00       	push   $0x802f8a
  800ed8:	6a 1f                	push   $0x1f
  800eda:	68 9a 2f 80 00       	push   $0x802f9a
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
  800efd:	68 a5 2f 80 00       	push   $0x802fa5
  800f02:	6a 2d                	push   $0x2d
  800f04:	68 9a 2f 80 00       	push   $0x802f9a
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
  800f45:	68 a5 2f 80 00       	push   $0x802fa5
  800f4a:	6a 34                	push   $0x34
  800f4c:	68 9a 2f 80 00       	push   $0x802f9a
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
  800f6d:	68 a5 2f 80 00       	push   $0x802fa5
  800f72:	6a 38                	push   $0x38
  800f74:	68 9a 2f 80 00       	push   $0x802f9a
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
  800f91:	e8 51 17 00 00       	call   8026e7 <set_pgfault_handler>
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
  800faa:	68 be 2f 80 00       	push   $0x802fbe
  800faf:	68 85 00 00 00       	push   $0x85
  800fb4:	68 9a 2f 80 00       	push   $0x802f9a
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
  801066:	68 cc 2f 80 00       	push   $0x802fcc
  80106b:	6a 55                	push   $0x55
  80106d:	68 9a 2f 80 00       	push   $0x802f9a
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
  8010ab:	68 cc 2f 80 00       	push   $0x802fcc
  8010b0:	6a 5c                	push   $0x5c
  8010b2:	68 9a 2f 80 00       	push   $0x802f9a
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
  8010d9:	68 cc 2f 80 00       	push   $0x802fcc
  8010de:	6a 60                	push   $0x60
  8010e0:	68 9a 2f 80 00       	push   $0x802f9a
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
  801103:	68 cc 2f 80 00       	push   $0x802fcc
  801108:	6a 65                	push   $0x65
  80110a:	68 9a 2f 80 00       	push   $0x802f9a
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
  8011c0:	68 12 30 80 00       	push   $0x803012
  8011c5:	68 d5 00 00 00       	push   $0xd5
  8011ca:	68 9a 2f 80 00       	push   $0x802f9a
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
  801226:	68 e2 2f 80 00       	push   $0x802fe2
  80122b:	68 ec 00 00 00       	push   $0xec
  801230:	68 9a 2f 80 00       	push   $0x802f9a
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
  801246:	56                   	push   %esi
  801247:	53                   	push   %ebx
  801248:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  80124b:	b8 01 00 00 00       	mov    $0x1,%eax
  801250:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801253:	85 c0                	test   %eax,%eax
  801255:	74 4a                	je     8012a1 <mutex_lock+0x5e>
  801257:	8b 73 04             	mov    0x4(%ebx),%esi
  80125a:	83 3e 00             	cmpl   $0x0,(%esi)
  80125d:	75 42                	jne    8012a1 <mutex_lock+0x5e>
		queue_append(sys_getenvid(), mtx->queue);		
  80125f:	e8 ba f9 ff ff       	call   800c1e <sys_getenvid>
  801264:	83 ec 08             	sub    $0x8,%esp
  801267:	56                   	push   %esi
  801268:	50                   	push   %eax
  801269:	e8 32 ff ff ff       	call   8011a0 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  80126e:	e8 ab f9 ff ff       	call   800c1e <sys_getenvid>
  801273:	83 c4 08             	add    $0x8,%esp
  801276:	6a 04                	push   $0x4
  801278:	50                   	push   %eax
  801279:	e8 a5 fa ff ff       	call   800d23 <sys_env_set_status>

		if (r < 0) {
  80127e:	83 c4 10             	add    $0x10,%esp
  801281:	85 c0                	test   %eax,%eax
  801283:	79 15                	jns    80129a <mutex_lock+0x57>
			panic("%e\n", r);
  801285:	50                   	push   %eax
  801286:	68 12 30 80 00       	push   $0x803012
  80128b:	68 02 01 00 00       	push   $0x102
  801290:	68 9a 2f 80 00       	push   $0x802f9a
  801295:	e8 61 ef ff ff       	call   8001fb <_panic>
		}
		sys_yield();
  80129a:	e8 9e f9 ff ff       	call   800c3d <sys_yield>
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  80129f:	eb 08                	jmp    8012a9 <mutex_lock+0x66>
		if (r < 0) {
			panic("%e\n", r);
		}
		sys_yield();
	} else {
		mtx->owner = sys_getenvid();
  8012a1:	e8 78 f9 ff ff       	call   800c1e <sys_getenvid>
  8012a6:	89 43 08             	mov    %eax,0x8(%ebx)
	}
}
  8012a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ac:	5b                   	pop    %ebx
  8012ad:	5e                   	pop    %esi
  8012ae:	5d                   	pop    %ebp
  8012af:	c3                   	ret    

008012b0 <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  8012b0:	55                   	push   %ebp
  8012b1:	89 e5                	mov    %esp,%ebp
  8012b3:	53                   	push   %ebx
  8012b4:	83 ec 04             	sub    $0x4,%esp
  8012b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8012bf:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  8012c2:	8b 43 04             	mov    0x4(%ebx),%eax
  8012c5:	83 38 00             	cmpl   $0x0,(%eax)
  8012c8:	74 33                	je     8012fd <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  8012ca:	83 ec 0c             	sub    $0xc,%esp
  8012cd:	50                   	push   %eax
  8012ce:	e8 41 ff ff ff       	call   801214 <queue_pop>
  8012d3:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8012d6:	83 c4 08             	add    $0x8,%esp
  8012d9:	6a 02                	push   $0x2
  8012db:	50                   	push   %eax
  8012dc:	e8 42 fa ff ff       	call   800d23 <sys_env_set_status>
		if (r < 0) {
  8012e1:	83 c4 10             	add    $0x10,%esp
  8012e4:	85 c0                	test   %eax,%eax
  8012e6:	79 15                	jns    8012fd <mutex_unlock+0x4d>
			panic("%e\n", r);
  8012e8:	50                   	push   %eax
  8012e9:	68 12 30 80 00       	push   $0x803012
  8012ee:	68 16 01 00 00       	push   $0x116
  8012f3:	68 9a 2f 80 00       	push   $0x802f9a
  8012f8:	e8 fe ee ff ff       	call   8001fb <_panic>
		}
	}

	//asm volatile("pause"); 	// might be useless here
}
  8012fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801300:	c9                   	leave  
  801301:	c3                   	ret    

00801302 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  801302:	55                   	push   %ebp
  801303:	89 e5                	mov    %esp,%ebp
  801305:	53                   	push   %ebx
  801306:	83 ec 04             	sub    $0x4,%esp
  801309:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  80130c:	e8 0d f9 ff ff       	call   800c1e <sys_getenvid>
  801311:	83 ec 04             	sub    $0x4,%esp
  801314:	6a 07                	push   $0x7
  801316:	53                   	push   %ebx
  801317:	50                   	push   %eax
  801318:	e8 3f f9 ff ff       	call   800c5c <sys_page_alloc>
  80131d:	83 c4 10             	add    $0x10,%esp
  801320:	85 c0                	test   %eax,%eax
  801322:	79 15                	jns    801339 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  801324:	50                   	push   %eax
  801325:	68 fd 2f 80 00       	push   $0x802ffd
  80132a:	68 22 01 00 00       	push   $0x122
  80132f:	68 9a 2f 80 00       	push   $0x802f9a
  801334:	e8 c2 ee ff ff       	call   8001fb <_panic>
	}	
	mtx->locked = 0;
  801339:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  80133f:	8b 43 04             	mov    0x4(%ebx),%eax
  801342:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  801348:	8b 43 04             	mov    0x4(%ebx),%eax
  80134b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  801352:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  801359:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80135c:	c9                   	leave  
  80135d:	c3                   	ret    

0080135e <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  80135e:	55                   	push   %ebp
  80135f:	89 e5                	mov    %esp,%ebp
  801361:	53                   	push   %ebx
  801362:	83 ec 04             	sub    $0x4,%esp
  801365:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue->first != NULL) {
  801368:	eb 21                	jmp    80138b <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
  80136a:	83 ec 0c             	sub    $0xc,%esp
  80136d:	50                   	push   %eax
  80136e:	e8 a1 fe ff ff       	call   801214 <queue_pop>
  801373:	83 c4 08             	add    $0x8,%esp
  801376:	6a 02                	push   $0x2
  801378:	50                   	push   %eax
  801379:	e8 a5 f9 ff ff       	call   800d23 <sys_env_set_status>
		mtx->queue->first = mtx->queue->first->next;
  80137e:	8b 43 04             	mov    0x4(%ebx),%eax
  801381:	8b 10                	mov    (%eax),%edx
  801383:	8b 52 04             	mov    0x4(%edx),%edx
  801386:	89 10                	mov    %edx,(%eax)
  801388:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue->first != NULL) {
  80138b:	8b 43 04             	mov    0x4(%ebx),%eax
  80138e:	83 38 00             	cmpl   $0x0,(%eax)
  801391:	75 d7                	jne    80136a <mutex_destroy+0xc>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
		mtx->queue->first = mtx->queue->first->next;
	}

	memset(mtx, 0, PGSIZE);
  801393:	83 ec 04             	sub    $0x4,%esp
  801396:	68 00 10 00 00       	push   $0x1000
  80139b:	6a 00                	push   $0x0
  80139d:	53                   	push   %ebx
  80139e:	e8 fb f5 ff ff       	call   80099e <memset>
	mtx = NULL;
}
  8013a3:	83 c4 10             	add    $0x10,%esp
  8013a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a9:	c9                   	leave  
  8013aa:	c3                   	ret    

008013ab <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013ab:	55                   	push   %ebp
  8013ac:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b1:	05 00 00 00 30       	add    $0x30000000,%eax
  8013b6:	c1 e8 0c             	shr    $0xc,%eax
}
  8013b9:	5d                   	pop    %ebp
  8013ba:	c3                   	ret    

008013bb <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013bb:	55                   	push   %ebp
  8013bc:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8013be:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c1:	05 00 00 00 30       	add    $0x30000000,%eax
  8013c6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013cb:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013d0:	5d                   	pop    %ebp
  8013d1:	c3                   	ret    

008013d2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013d2:	55                   	push   %ebp
  8013d3:	89 e5                	mov    %esp,%ebp
  8013d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013d8:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013dd:	89 c2                	mov    %eax,%edx
  8013df:	c1 ea 16             	shr    $0x16,%edx
  8013e2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013e9:	f6 c2 01             	test   $0x1,%dl
  8013ec:	74 11                	je     8013ff <fd_alloc+0x2d>
  8013ee:	89 c2                	mov    %eax,%edx
  8013f0:	c1 ea 0c             	shr    $0xc,%edx
  8013f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013fa:	f6 c2 01             	test   $0x1,%dl
  8013fd:	75 09                	jne    801408 <fd_alloc+0x36>
			*fd_store = fd;
  8013ff:	89 01                	mov    %eax,(%ecx)
			return 0;
  801401:	b8 00 00 00 00       	mov    $0x0,%eax
  801406:	eb 17                	jmp    80141f <fd_alloc+0x4d>
  801408:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80140d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801412:	75 c9                	jne    8013dd <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801414:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80141a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80141f:	5d                   	pop    %ebp
  801420:	c3                   	ret    

00801421 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801421:	55                   	push   %ebp
  801422:	89 e5                	mov    %esp,%ebp
  801424:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801427:	83 f8 1f             	cmp    $0x1f,%eax
  80142a:	77 36                	ja     801462 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80142c:	c1 e0 0c             	shl    $0xc,%eax
  80142f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801434:	89 c2                	mov    %eax,%edx
  801436:	c1 ea 16             	shr    $0x16,%edx
  801439:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801440:	f6 c2 01             	test   $0x1,%dl
  801443:	74 24                	je     801469 <fd_lookup+0x48>
  801445:	89 c2                	mov    %eax,%edx
  801447:	c1 ea 0c             	shr    $0xc,%edx
  80144a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801451:	f6 c2 01             	test   $0x1,%dl
  801454:	74 1a                	je     801470 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801456:	8b 55 0c             	mov    0xc(%ebp),%edx
  801459:	89 02                	mov    %eax,(%edx)
	return 0;
  80145b:	b8 00 00 00 00       	mov    $0x0,%eax
  801460:	eb 13                	jmp    801475 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801462:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801467:	eb 0c                	jmp    801475 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801469:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80146e:	eb 05                	jmp    801475 <fd_lookup+0x54>
  801470:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801475:	5d                   	pop    %ebp
  801476:	c3                   	ret    

00801477 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801477:	55                   	push   %ebp
  801478:	89 e5                	mov    %esp,%ebp
  80147a:	83 ec 08             	sub    $0x8,%esp
  80147d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801480:	ba 94 30 80 00       	mov    $0x803094,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801485:	eb 13                	jmp    80149a <dev_lookup+0x23>
  801487:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80148a:	39 08                	cmp    %ecx,(%eax)
  80148c:	75 0c                	jne    80149a <dev_lookup+0x23>
			*dev = devtab[i];
  80148e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801491:	89 01                	mov    %eax,(%ecx)
			return 0;
  801493:	b8 00 00 00 00       	mov    $0x0,%eax
  801498:	eb 31                	jmp    8014cb <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80149a:	8b 02                	mov    (%edx),%eax
  80149c:	85 c0                	test   %eax,%eax
  80149e:	75 e7                	jne    801487 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014a0:	a1 04 50 80 00       	mov    0x805004,%eax
  8014a5:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8014ab:	83 ec 04             	sub    $0x4,%esp
  8014ae:	51                   	push   %ecx
  8014af:	50                   	push   %eax
  8014b0:	68 18 30 80 00       	push   $0x803018
  8014b5:	e8 1a ee ff ff       	call   8002d4 <cprintf>
	*dev = 0;
  8014ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014bd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014c3:	83 c4 10             	add    $0x10,%esp
  8014c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014cb:	c9                   	leave  
  8014cc:	c3                   	ret    

008014cd <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014cd:	55                   	push   %ebp
  8014ce:	89 e5                	mov    %esp,%ebp
  8014d0:	56                   	push   %esi
  8014d1:	53                   	push   %ebx
  8014d2:	83 ec 10             	sub    $0x10,%esp
  8014d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8014d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014de:	50                   	push   %eax
  8014df:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014e5:	c1 e8 0c             	shr    $0xc,%eax
  8014e8:	50                   	push   %eax
  8014e9:	e8 33 ff ff ff       	call   801421 <fd_lookup>
  8014ee:	83 c4 08             	add    $0x8,%esp
  8014f1:	85 c0                	test   %eax,%eax
  8014f3:	78 05                	js     8014fa <fd_close+0x2d>
	    || fd != fd2)
  8014f5:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014f8:	74 0c                	je     801506 <fd_close+0x39>
		return (must_exist ? r : 0);
  8014fa:	84 db                	test   %bl,%bl
  8014fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801501:	0f 44 c2             	cmove  %edx,%eax
  801504:	eb 41                	jmp    801547 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801506:	83 ec 08             	sub    $0x8,%esp
  801509:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80150c:	50                   	push   %eax
  80150d:	ff 36                	pushl  (%esi)
  80150f:	e8 63 ff ff ff       	call   801477 <dev_lookup>
  801514:	89 c3                	mov    %eax,%ebx
  801516:	83 c4 10             	add    $0x10,%esp
  801519:	85 c0                	test   %eax,%eax
  80151b:	78 1a                	js     801537 <fd_close+0x6a>
		if (dev->dev_close)
  80151d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801520:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801523:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801528:	85 c0                	test   %eax,%eax
  80152a:	74 0b                	je     801537 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80152c:	83 ec 0c             	sub    $0xc,%esp
  80152f:	56                   	push   %esi
  801530:	ff d0                	call   *%eax
  801532:	89 c3                	mov    %eax,%ebx
  801534:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801537:	83 ec 08             	sub    $0x8,%esp
  80153a:	56                   	push   %esi
  80153b:	6a 00                	push   $0x0
  80153d:	e8 9f f7 ff ff       	call   800ce1 <sys_page_unmap>
	return r;
  801542:	83 c4 10             	add    $0x10,%esp
  801545:	89 d8                	mov    %ebx,%eax
}
  801547:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80154a:	5b                   	pop    %ebx
  80154b:	5e                   	pop    %esi
  80154c:	5d                   	pop    %ebp
  80154d:	c3                   	ret    

0080154e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80154e:	55                   	push   %ebp
  80154f:	89 e5                	mov    %esp,%ebp
  801551:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801554:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801557:	50                   	push   %eax
  801558:	ff 75 08             	pushl  0x8(%ebp)
  80155b:	e8 c1 fe ff ff       	call   801421 <fd_lookup>
  801560:	83 c4 08             	add    $0x8,%esp
  801563:	85 c0                	test   %eax,%eax
  801565:	78 10                	js     801577 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801567:	83 ec 08             	sub    $0x8,%esp
  80156a:	6a 01                	push   $0x1
  80156c:	ff 75 f4             	pushl  -0xc(%ebp)
  80156f:	e8 59 ff ff ff       	call   8014cd <fd_close>
  801574:	83 c4 10             	add    $0x10,%esp
}
  801577:	c9                   	leave  
  801578:	c3                   	ret    

00801579 <close_all>:

void
close_all(void)
{
  801579:	55                   	push   %ebp
  80157a:	89 e5                	mov    %esp,%ebp
  80157c:	53                   	push   %ebx
  80157d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801580:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801585:	83 ec 0c             	sub    $0xc,%esp
  801588:	53                   	push   %ebx
  801589:	e8 c0 ff ff ff       	call   80154e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80158e:	83 c3 01             	add    $0x1,%ebx
  801591:	83 c4 10             	add    $0x10,%esp
  801594:	83 fb 20             	cmp    $0x20,%ebx
  801597:	75 ec                	jne    801585 <close_all+0xc>
		close(i);
}
  801599:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159c:	c9                   	leave  
  80159d:	c3                   	ret    

0080159e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80159e:	55                   	push   %ebp
  80159f:	89 e5                	mov    %esp,%ebp
  8015a1:	57                   	push   %edi
  8015a2:	56                   	push   %esi
  8015a3:	53                   	push   %ebx
  8015a4:	83 ec 2c             	sub    $0x2c,%esp
  8015a7:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015aa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015ad:	50                   	push   %eax
  8015ae:	ff 75 08             	pushl  0x8(%ebp)
  8015b1:	e8 6b fe ff ff       	call   801421 <fd_lookup>
  8015b6:	83 c4 08             	add    $0x8,%esp
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	0f 88 c1 00 00 00    	js     801682 <dup+0xe4>
		return r;
	close(newfdnum);
  8015c1:	83 ec 0c             	sub    $0xc,%esp
  8015c4:	56                   	push   %esi
  8015c5:	e8 84 ff ff ff       	call   80154e <close>

	newfd = INDEX2FD(newfdnum);
  8015ca:	89 f3                	mov    %esi,%ebx
  8015cc:	c1 e3 0c             	shl    $0xc,%ebx
  8015cf:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8015d5:	83 c4 04             	add    $0x4,%esp
  8015d8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015db:	e8 db fd ff ff       	call   8013bb <fd2data>
  8015e0:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8015e2:	89 1c 24             	mov    %ebx,(%esp)
  8015e5:	e8 d1 fd ff ff       	call   8013bb <fd2data>
  8015ea:	83 c4 10             	add    $0x10,%esp
  8015ed:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015f0:	89 f8                	mov    %edi,%eax
  8015f2:	c1 e8 16             	shr    $0x16,%eax
  8015f5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015fc:	a8 01                	test   $0x1,%al
  8015fe:	74 37                	je     801637 <dup+0x99>
  801600:	89 f8                	mov    %edi,%eax
  801602:	c1 e8 0c             	shr    $0xc,%eax
  801605:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80160c:	f6 c2 01             	test   $0x1,%dl
  80160f:	74 26                	je     801637 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801611:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801618:	83 ec 0c             	sub    $0xc,%esp
  80161b:	25 07 0e 00 00       	and    $0xe07,%eax
  801620:	50                   	push   %eax
  801621:	ff 75 d4             	pushl  -0x2c(%ebp)
  801624:	6a 00                	push   $0x0
  801626:	57                   	push   %edi
  801627:	6a 00                	push   $0x0
  801629:	e8 71 f6 ff ff       	call   800c9f <sys_page_map>
  80162e:	89 c7                	mov    %eax,%edi
  801630:	83 c4 20             	add    $0x20,%esp
  801633:	85 c0                	test   %eax,%eax
  801635:	78 2e                	js     801665 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801637:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80163a:	89 d0                	mov    %edx,%eax
  80163c:	c1 e8 0c             	shr    $0xc,%eax
  80163f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801646:	83 ec 0c             	sub    $0xc,%esp
  801649:	25 07 0e 00 00       	and    $0xe07,%eax
  80164e:	50                   	push   %eax
  80164f:	53                   	push   %ebx
  801650:	6a 00                	push   $0x0
  801652:	52                   	push   %edx
  801653:	6a 00                	push   $0x0
  801655:	e8 45 f6 ff ff       	call   800c9f <sys_page_map>
  80165a:	89 c7                	mov    %eax,%edi
  80165c:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80165f:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801661:	85 ff                	test   %edi,%edi
  801663:	79 1d                	jns    801682 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801665:	83 ec 08             	sub    $0x8,%esp
  801668:	53                   	push   %ebx
  801669:	6a 00                	push   $0x0
  80166b:	e8 71 f6 ff ff       	call   800ce1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801670:	83 c4 08             	add    $0x8,%esp
  801673:	ff 75 d4             	pushl  -0x2c(%ebp)
  801676:	6a 00                	push   $0x0
  801678:	e8 64 f6 ff ff       	call   800ce1 <sys_page_unmap>
	return r;
  80167d:	83 c4 10             	add    $0x10,%esp
  801680:	89 f8                	mov    %edi,%eax
}
  801682:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801685:	5b                   	pop    %ebx
  801686:	5e                   	pop    %esi
  801687:	5f                   	pop    %edi
  801688:	5d                   	pop    %ebp
  801689:	c3                   	ret    

0080168a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80168a:	55                   	push   %ebp
  80168b:	89 e5                	mov    %esp,%ebp
  80168d:	53                   	push   %ebx
  80168e:	83 ec 14             	sub    $0x14,%esp
  801691:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801694:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801697:	50                   	push   %eax
  801698:	53                   	push   %ebx
  801699:	e8 83 fd ff ff       	call   801421 <fd_lookup>
  80169e:	83 c4 08             	add    $0x8,%esp
  8016a1:	89 c2                	mov    %eax,%edx
  8016a3:	85 c0                	test   %eax,%eax
  8016a5:	78 70                	js     801717 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a7:	83 ec 08             	sub    $0x8,%esp
  8016aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ad:	50                   	push   %eax
  8016ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b1:	ff 30                	pushl  (%eax)
  8016b3:	e8 bf fd ff ff       	call   801477 <dev_lookup>
  8016b8:	83 c4 10             	add    $0x10,%esp
  8016bb:	85 c0                	test   %eax,%eax
  8016bd:	78 4f                	js     80170e <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016bf:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016c2:	8b 42 08             	mov    0x8(%edx),%eax
  8016c5:	83 e0 03             	and    $0x3,%eax
  8016c8:	83 f8 01             	cmp    $0x1,%eax
  8016cb:	75 24                	jne    8016f1 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016cd:	a1 04 50 80 00       	mov    0x805004,%eax
  8016d2:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8016d8:	83 ec 04             	sub    $0x4,%esp
  8016db:	53                   	push   %ebx
  8016dc:	50                   	push   %eax
  8016dd:	68 59 30 80 00       	push   $0x803059
  8016e2:	e8 ed eb ff ff       	call   8002d4 <cprintf>
		return -E_INVAL;
  8016e7:	83 c4 10             	add    $0x10,%esp
  8016ea:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016ef:	eb 26                	jmp    801717 <read+0x8d>
	}
	if (!dev->dev_read)
  8016f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016f4:	8b 40 08             	mov    0x8(%eax),%eax
  8016f7:	85 c0                	test   %eax,%eax
  8016f9:	74 17                	je     801712 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8016fb:	83 ec 04             	sub    $0x4,%esp
  8016fe:	ff 75 10             	pushl  0x10(%ebp)
  801701:	ff 75 0c             	pushl  0xc(%ebp)
  801704:	52                   	push   %edx
  801705:	ff d0                	call   *%eax
  801707:	89 c2                	mov    %eax,%edx
  801709:	83 c4 10             	add    $0x10,%esp
  80170c:	eb 09                	jmp    801717 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80170e:	89 c2                	mov    %eax,%edx
  801710:	eb 05                	jmp    801717 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801712:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801717:	89 d0                	mov    %edx,%eax
  801719:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171c:	c9                   	leave  
  80171d:	c3                   	ret    

0080171e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	57                   	push   %edi
  801722:	56                   	push   %esi
  801723:	53                   	push   %ebx
  801724:	83 ec 0c             	sub    $0xc,%esp
  801727:	8b 7d 08             	mov    0x8(%ebp),%edi
  80172a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80172d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801732:	eb 21                	jmp    801755 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801734:	83 ec 04             	sub    $0x4,%esp
  801737:	89 f0                	mov    %esi,%eax
  801739:	29 d8                	sub    %ebx,%eax
  80173b:	50                   	push   %eax
  80173c:	89 d8                	mov    %ebx,%eax
  80173e:	03 45 0c             	add    0xc(%ebp),%eax
  801741:	50                   	push   %eax
  801742:	57                   	push   %edi
  801743:	e8 42 ff ff ff       	call   80168a <read>
		if (m < 0)
  801748:	83 c4 10             	add    $0x10,%esp
  80174b:	85 c0                	test   %eax,%eax
  80174d:	78 10                	js     80175f <readn+0x41>
			return m;
		if (m == 0)
  80174f:	85 c0                	test   %eax,%eax
  801751:	74 0a                	je     80175d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801753:	01 c3                	add    %eax,%ebx
  801755:	39 f3                	cmp    %esi,%ebx
  801757:	72 db                	jb     801734 <readn+0x16>
  801759:	89 d8                	mov    %ebx,%eax
  80175b:	eb 02                	jmp    80175f <readn+0x41>
  80175d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80175f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801762:	5b                   	pop    %ebx
  801763:	5e                   	pop    %esi
  801764:	5f                   	pop    %edi
  801765:	5d                   	pop    %ebp
  801766:	c3                   	ret    

00801767 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801767:	55                   	push   %ebp
  801768:	89 e5                	mov    %esp,%ebp
  80176a:	53                   	push   %ebx
  80176b:	83 ec 14             	sub    $0x14,%esp
  80176e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801771:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801774:	50                   	push   %eax
  801775:	53                   	push   %ebx
  801776:	e8 a6 fc ff ff       	call   801421 <fd_lookup>
  80177b:	83 c4 08             	add    $0x8,%esp
  80177e:	89 c2                	mov    %eax,%edx
  801780:	85 c0                	test   %eax,%eax
  801782:	78 6b                	js     8017ef <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801784:	83 ec 08             	sub    $0x8,%esp
  801787:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80178a:	50                   	push   %eax
  80178b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80178e:	ff 30                	pushl  (%eax)
  801790:	e8 e2 fc ff ff       	call   801477 <dev_lookup>
  801795:	83 c4 10             	add    $0x10,%esp
  801798:	85 c0                	test   %eax,%eax
  80179a:	78 4a                	js     8017e6 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80179c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80179f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017a3:	75 24                	jne    8017c9 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017a5:	a1 04 50 80 00       	mov    0x805004,%eax
  8017aa:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8017b0:	83 ec 04             	sub    $0x4,%esp
  8017b3:	53                   	push   %ebx
  8017b4:	50                   	push   %eax
  8017b5:	68 75 30 80 00       	push   $0x803075
  8017ba:	e8 15 eb ff ff       	call   8002d4 <cprintf>
		return -E_INVAL;
  8017bf:	83 c4 10             	add    $0x10,%esp
  8017c2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017c7:	eb 26                	jmp    8017ef <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017cc:	8b 52 0c             	mov    0xc(%edx),%edx
  8017cf:	85 d2                	test   %edx,%edx
  8017d1:	74 17                	je     8017ea <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017d3:	83 ec 04             	sub    $0x4,%esp
  8017d6:	ff 75 10             	pushl  0x10(%ebp)
  8017d9:	ff 75 0c             	pushl  0xc(%ebp)
  8017dc:	50                   	push   %eax
  8017dd:	ff d2                	call   *%edx
  8017df:	89 c2                	mov    %eax,%edx
  8017e1:	83 c4 10             	add    $0x10,%esp
  8017e4:	eb 09                	jmp    8017ef <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e6:	89 c2                	mov    %eax,%edx
  8017e8:	eb 05                	jmp    8017ef <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017ea:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8017ef:	89 d0                	mov    %edx,%eax
  8017f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f4:	c9                   	leave  
  8017f5:	c3                   	ret    

008017f6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017f6:	55                   	push   %ebp
  8017f7:	89 e5                	mov    %esp,%ebp
  8017f9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017fc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017ff:	50                   	push   %eax
  801800:	ff 75 08             	pushl  0x8(%ebp)
  801803:	e8 19 fc ff ff       	call   801421 <fd_lookup>
  801808:	83 c4 08             	add    $0x8,%esp
  80180b:	85 c0                	test   %eax,%eax
  80180d:	78 0e                	js     80181d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80180f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801812:	8b 55 0c             	mov    0xc(%ebp),%edx
  801815:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801818:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80181d:	c9                   	leave  
  80181e:	c3                   	ret    

0080181f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80181f:	55                   	push   %ebp
  801820:	89 e5                	mov    %esp,%ebp
  801822:	53                   	push   %ebx
  801823:	83 ec 14             	sub    $0x14,%esp
  801826:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801829:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80182c:	50                   	push   %eax
  80182d:	53                   	push   %ebx
  80182e:	e8 ee fb ff ff       	call   801421 <fd_lookup>
  801833:	83 c4 08             	add    $0x8,%esp
  801836:	89 c2                	mov    %eax,%edx
  801838:	85 c0                	test   %eax,%eax
  80183a:	78 68                	js     8018a4 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80183c:	83 ec 08             	sub    $0x8,%esp
  80183f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801842:	50                   	push   %eax
  801843:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801846:	ff 30                	pushl  (%eax)
  801848:	e8 2a fc ff ff       	call   801477 <dev_lookup>
  80184d:	83 c4 10             	add    $0x10,%esp
  801850:	85 c0                	test   %eax,%eax
  801852:	78 47                	js     80189b <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801854:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801857:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80185b:	75 24                	jne    801881 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80185d:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801862:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801868:	83 ec 04             	sub    $0x4,%esp
  80186b:	53                   	push   %ebx
  80186c:	50                   	push   %eax
  80186d:	68 38 30 80 00       	push   $0x803038
  801872:	e8 5d ea ff ff       	call   8002d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801877:	83 c4 10             	add    $0x10,%esp
  80187a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80187f:	eb 23                	jmp    8018a4 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801881:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801884:	8b 52 18             	mov    0x18(%edx),%edx
  801887:	85 d2                	test   %edx,%edx
  801889:	74 14                	je     80189f <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80188b:	83 ec 08             	sub    $0x8,%esp
  80188e:	ff 75 0c             	pushl  0xc(%ebp)
  801891:	50                   	push   %eax
  801892:	ff d2                	call   *%edx
  801894:	89 c2                	mov    %eax,%edx
  801896:	83 c4 10             	add    $0x10,%esp
  801899:	eb 09                	jmp    8018a4 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80189b:	89 c2                	mov    %eax,%edx
  80189d:	eb 05                	jmp    8018a4 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80189f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8018a4:	89 d0                	mov    %edx,%eax
  8018a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a9:	c9                   	leave  
  8018aa:	c3                   	ret    

008018ab <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018ab:	55                   	push   %ebp
  8018ac:	89 e5                	mov    %esp,%ebp
  8018ae:	53                   	push   %ebx
  8018af:	83 ec 14             	sub    $0x14,%esp
  8018b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018b8:	50                   	push   %eax
  8018b9:	ff 75 08             	pushl  0x8(%ebp)
  8018bc:	e8 60 fb ff ff       	call   801421 <fd_lookup>
  8018c1:	83 c4 08             	add    $0x8,%esp
  8018c4:	89 c2                	mov    %eax,%edx
  8018c6:	85 c0                	test   %eax,%eax
  8018c8:	78 58                	js     801922 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018ca:	83 ec 08             	sub    $0x8,%esp
  8018cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d0:	50                   	push   %eax
  8018d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d4:	ff 30                	pushl  (%eax)
  8018d6:	e8 9c fb ff ff       	call   801477 <dev_lookup>
  8018db:	83 c4 10             	add    $0x10,%esp
  8018de:	85 c0                	test   %eax,%eax
  8018e0:	78 37                	js     801919 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8018e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018e9:	74 32                	je     80191d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018eb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018ee:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018f5:	00 00 00 
	stat->st_isdir = 0;
  8018f8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018ff:	00 00 00 
	stat->st_dev = dev;
  801902:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801908:	83 ec 08             	sub    $0x8,%esp
  80190b:	53                   	push   %ebx
  80190c:	ff 75 f0             	pushl  -0x10(%ebp)
  80190f:	ff 50 14             	call   *0x14(%eax)
  801912:	89 c2                	mov    %eax,%edx
  801914:	83 c4 10             	add    $0x10,%esp
  801917:	eb 09                	jmp    801922 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801919:	89 c2                	mov    %eax,%edx
  80191b:	eb 05                	jmp    801922 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80191d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801922:	89 d0                	mov    %edx,%eax
  801924:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801927:	c9                   	leave  
  801928:	c3                   	ret    

00801929 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801929:	55                   	push   %ebp
  80192a:	89 e5                	mov    %esp,%ebp
  80192c:	56                   	push   %esi
  80192d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80192e:	83 ec 08             	sub    $0x8,%esp
  801931:	6a 00                	push   $0x0
  801933:	ff 75 08             	pushl  0x8(%ebp)
  801936:	e8 e3 01 00 00       	call   801b1e <open>
  80193b:	89 c3                	mov    %eax,%ebx
  80193d:	83 c4 10             	add    $0x10,%esp
  801940:	85 c0                	test   %eax,%eax
  801942:	78 1b                	js     80195f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801944:	83 ec 08             	sub    $0x8,%esp
  801947:	ff 75 0c             	pushl  0xc(%ebp)
  80194a:	50                   	push   %eax
  80194b:	e8 5b ff ff ff       	call   8018ab <fstat>
  801950:	89 c6                	mov    %eax,%esi
	close(fd);
  801952:	89 1c 24             	mov    %ebx,(%esp)
  801955:	e8 f4 fb ff ff       	call   80154e <close>
	return r;
  80195a:	83 c4 10             	add    $0x10,%esp
  80195d:	89 f0                	mov    %esi,%eax
}
  80195f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801962:	5b                   	pop    %ebx
  801963:	5e                   	pop    %esi
  801964:	5d                   	pop    %ebp
  801965:	c3                   	ret    

00801966 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801966:	55                   	push   %ebp
  801967:	89 e5                	mov    %esp,%ebp
  801969:	56                   	push   %esi
  80196a:	53                   	push   %ebx
  80196b:	89 c6                	mov    %eax,%esi
  80196d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80196f:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801976:	75 12                	jne    80198a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801978:	83 ec 0c             	sub    $0xc,%esp
  80197b:	6a 01                	push   $0x1
  80197d:	e8 d1 0e 00 00       	call   802853 <ipc_find_env>
  801982:	a3 00 50 80 00       	mov    %eax,0x805000
  801987:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80198a:	6a 07                	push   $0x7
  80198c:	68 00 60 80 00       	push   $0x806000
  801991:	56                   	push   %esi
  801992:	ff 35 00 50 80 00    	pushl  0x805000
  801998:	e8 54 0e 00 00       	call   8027f1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80199d:	83 c4 0c             	add    $0xc,%esp
  8019a0:	6a 00                	push   $0x0
  8019a2:	53                   	push   %ebx
  8019a3:	6a 00                	push   $0x0
  8019a5:	e8 cc 0d 00 00       	call   802776 <ipc_recv>
}
  8019aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ad:	5b                   	pop    %ebx
  8019ae:	5e                   	pop    %esi
  8019af:	5d                   	pop    %ebp
  8019b0:	c3                   	ret    

008019b1 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019b1:	55                   	push   %ebp
  8019b2:	89 e5                	mov    %esp,%ebp
  8019b4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ba:	8b 40 0c             	mov    0xc(%eax),%eax
  8019bd:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8019c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c5:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8019cf:	b8 02 00 00 00       	mov    $0x2,%eax
  8019d4:	e8 8d ff ff ff       	call   801966 <fsipc>
}
  8019d9:	c9                   	leave  
  8019da:	c3                   	ret    

008019db <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
  8019de:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8019e7:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8019ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f1:	b8 06 00 00 00       	mov    $0x6,%eax
  8019f6:	e8 6b ff ff ff       	call   801966 <fsipc>
}
  8019fb:	c9                   	leave  
  8019fc:	c3                   	ret    

008019fd <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019fd:	55                   	push   %ebp
  8019fe:	89 e5                	mov    %esp,%ebp
  801a00:	53                   	push   %ebx
  801a01:	83 ec 04             	sub    $0x4,%esp
  801a04:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a07:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0a:	8b 40 0c             	mov    0xc(%eax),%eax
  801a0d:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a12:	ba 00 00 00 00       	mov    $0x0,%edx
  801a17:	b8 05 00 00 00       	mov    $0x5,%eax
  801a1c:	e8 45 ff ff ff       	call   801966 <fsipc>
  801a21:	85 c0                	test   %eax,%eax
  801a23:	78 2c                	js     801a51 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a25:	83 ec 08             	sub    $0x8,%esp
  801a28:	68 00 60 80 00       	push   $0x806000
  801a2d:	53                   	push   %ebx
  801a2e:	e8 26 ee ff ff       	call   800859 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a33:	a1 80 60 80 00       	mov    0x806080,%eax
  801a38:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a3e:	a1 84 60 80 00       	mov    0x806084,%eax
  801a43:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a49:	83 c4 10             	add    $0x10,%esp
  801a4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a54:	c9                   	leave  
  801a55:	c3                   	ret    

00801a56 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a56:	55                   	push   %ebp
  801a57:	89 e5                	mov    %esp,%ebp
  801a59:	83 ec 0c             	sub    $0xc,%esp
  801a5c:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a5f:	8b 55 08             	mov    0x8(%ebp),%edx
  801a62:	8b 52 0c             	mov    0xc(%edx),%edx
  801a65:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801a6b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a70:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a75:	0f 47 c2             	cmova  %edx,%eax
  801a78:	a3 04 60 80 00       	mov    %eax,0x806004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801a7d:	50                   	push   %eax
  801a7e:	ff 75 0c             	pushl  0xc(%ebp)
  801a81:	68 08 60 80 00       	push   $0x806008
  801a86:	e8 60 ef ff ff       	call   8009eb <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801a8b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a90:	b8 04 00 00 00       	mov    $0x4,%eax
  801a95:	e8 cc fe ff ff       	call   801966 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801a9a:	c9                   	leave  
  801a9b:	c3                   	ret    

00801a9c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
  801a9f:	56                   	push   %esi
  801aa0:	53                   	push   %ebx
  801aa1:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801aa4:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa7:	8b 40 0c             	mov    0xc(%eax),%eax
  801aaa:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801aaf:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ab5:	ba 00 00 00 00       	mov    $0x0,%edx
  801aba:	b8 03 00 00 00       	mov    $0x3,%eax
  801abf:	e8 a2 fe ff ff       	call   801966 <fsipc>
  801ac4:	89 c3                	mov    %eax,%ebx
  801ac6:	85 c0                	test   %eax,%eax
  801ac8:	78 4b                	js     801b15 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801aca:	39 c6                	cmp    %eax,%esi
  801acc:	73 16                	jae    801ae4 <devfile_read+0x48>
  801ace:	68 a4 30 80 00       	push   $0x8030a4
  801ad3:	68 ab 30 80 00       	push   $0x8030ab
  801ad8:	6a 7c                	push   $0x7c
  801ada:	68 c0 30 80 00       	push   $0x8030c0
  801adf:	e8 17 e7 ff ff       	call   8001fb <_panic>
	assert(r <= PGSIZE);
  801ae4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ae9:	7e 16                	jle    801b01 <devfile_read+0x65>
  801aeb:	68 cb 30 80 00       	push   $0x8030cb
  801af0:	68 ab 30 80 00       	push   $0x8030ab
  801af5:	6a 7d                	push   $0x7d
  801af7:	68 c0 30 80 00       	push   $0x8030c0
  801afc:	e8 fa e6 ff ff       	call   8001fb <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b01:	83 ec 04             	sub    $0x4,%esp
  801b04:	50                   	push   %eax
  801b05:	68 00 60 80 00       	push   $0x806000
  801b0a:	ff 75 0c             	pushl  0xc(%ebp)
  801b0d:	e8 d9 ee ff ff       	call   8009eb <memmove>
	return r;
  801b12:	83 c4 10             	add    $0x10,%esp
}
  801b15:	89 d8                	mov    %ebx,%eax
  801b17:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b1a:	5b                   	pop    %ebx
  801b1b:	5e                   	pop    %esi
  801b1c:	5d                   	pop    %ebp
  801b1d:	c3                   	ret    

00801b1e <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b1e:	55                   	push   %ebp
  801b1f:	89 e5                	mov    %esp,%ebp
  801b21:	53                   	push   %ebx
  801b22:	83 ec 20             	sub    $0x20,%esp
  801b25:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b28:	53                   	push   %ebx
  801b29:	e8 f2 ec ff ff       	call   800820 <strlen>
  801b2e:	83 c4 10             	add    $0x10,%esp
  801b31:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b36:	7f 67                	jg     801b9f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b38:	83 ec 0c             	sub    $0xc,%esp
  801b3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b3e:	50                   	push   %eax
  801b3f:	e8 8e f8 ff ff       	call   8013d2 <fd_alloc>
  801b44:	83 c4 10             	add    $0x10,%esp
		return r;
  801b47:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b49:	85 c0                	test   %eax,%eax
  801b4b:	78 57                	js     801ba4 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b4d:	83 ec 08             	sub    $0x8,%esp
  801b50:	53                   	push   %ebx
  801b51:	68 00 60 80 00       	push   $0x806000
  801b56:	e8 fe ec ff ff       	call   800859 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b5e:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b63:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b66:	b8 01 00 00 00       	mov    $0x1,%eax
  801b6b:	e8 f6 fd ff ff       	call   801966 <fsipc>
  801b70:	89 c3                	mov    %eax,%ebx
  801b72:	83 c4 10             	add    $0x10,%esp
  801b75:	85 c0                	test   %eax,%eax
  801b77:	79 14                	jns    801b8d <open+0x6f>
		fd_close(fd, 0);
  801b79:	83 ec 08             	sub    $0x8,%esp
  801b7c:	6a 00                	push   $0x0
  801b7e:	ff 75 f4             	pushl  -0xc(%ebp)
  801b81:	e8 47 f9 ff ff       	call   8014cd <fd_close>
		return r;
  801b86:	83 c4 10             	add    $0x10,%esp
  801b89:	89 da                	mov    %ebx,%edx
  801b8b:	eb 17                	jmp    801ba4 <open+0x86>
	}

	return fd2num(fd);
  801b8d:	83 ec 0c             	sub    $0xc,%esp
  801b90:	ff 75 f4             	pushl  -0xc(%ebp)
  801b93:	e8 13 f8 ff ff       	call   8013ab <fd2num>
  801b98:	89 c2                	mov    %eax,%edx
  801b9a:	83 c4 10             	add    $0x10,%esp
  801b9d:	eb 05                	jmp    801ba4 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b9f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ba4:	89 d0                	mov    %edx,%eax
  801ba6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ba9:	c9                   	leave  
  801baa:	c3                   	ret    

00801bab <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bab:	55                   	push   %ebp
  801bac:	89 e5                	mov    %esp,%ebp
  801bae:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bb1:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb6:	b8 08 00 00 00       	mov    $0x8,%eax
  801bbb:	e8 a6 fd ff ff       	call   801966 <fsipc>
}
  801bc0:	c9                   	leave  
  801bc1:	c3                   	ret    

00801bc2 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801bc2:	55                   	push   %ebp
  801bc3:	89 e5                	mov    %esp,%ebp
  801bc5:	57                   	push   %edi
  801bc6:	56                   	push   %esi
  801bc7:	53                   	push   %ebx
  801bc8:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801bce:	6a 00                	push   $0x0
  801bd0:	ff 75 08             	pushl  0x8(%ebp)
  801bd3:	e8 46 ff ff ff       	call   801b1e <open>
  801bd8:	89 c7                	mov    %eax,%edi
  801bda:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801be0:	83 c4 10             	add    $0x10,%esp
  801be3:	85 c0                	test   %eax,%eax
  801be5:	0f 88 8c 04 00 00    	js     802077 <spawn+0x4b5>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801beb:	83 ec 04             	sub    $0x4,%esp
  801bee:	68 00 02 00 00       	push   $0x200
  801bf3:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801bf9:	50                   	push   %eax
  801bfa:	57                   	push   %edi
  801bfb:	e8 1e fb ff ff       	call   80171e <readn>
  801c00:	83 c4 10             	add    $0x10,%esp
  801c03:	3d 00 02 00 00       	cmp    $0x200,%eax
  801c08:	75 0c                	jne    801c16 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801c0a:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801c11:	45 4c 46 
  801c14:	74 33                	je     801c49 <spawn+0x87>
		close(fd);
  801c16:	83 ec 0c             	sub    $0xc,%esp
  801c19:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c1f:	e8 2a f9 ff ff       	call   80154e <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801c24:	83 c4 0c             	add    $0xc,%esp
  801c27:	68 7f 45 4c 46       	push   $0x464c457f
  801c2c:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801c32:	68 d7 30 80 00       	push   $0x8030d7
  801c37:	e8 98 e6 ff ff       	call   8002d4 <cprintf>
		return -E_NOT_EXEC;
  801c3c:	83 c4 10             	add    $0x10,%esp
  801c3f:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801c44:	e9 e1 04 00 00       	jmp    80212a <spawn+0x568>
  801c49:	b8 07 00 00 00       	mov    $0x7,%eax
  801c4e:	cd 30                	int    $0x30
  801c50:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801c56:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801c5c:	85 c0                	test   %eax,%eax
  801c5e:	0f 88 1e 04 00 00    	js     802082 <spawn+0x4c0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801c64:	89 c6                	mov    %eax,%esi
  801c66:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801c6c:	69 f6 d4 00 00 00    	imul   $0xd4,%esi,%esi
  801c72:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801c78:	81 c6 58 00 c0 ee    	add    $0xeec00058,%esi
  801c7e:	b9 11 00 00 00       	mov    $0x11,%ecx
  801c83:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801c85:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801c8b:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801c91:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801c96:	be 00 00 00 00       	mov    $0x0,%esi
  801c9b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c9e:	eb 13                	jmp    801cb3 <spawn+0xf1>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801ca0:	83 ec 0c             	sub    $0xc,%esp
  801ca3:	50                   	push   %eax
  801ca4:	e8 77 eb ff ff       	call   800820 <strlen>
  801ca9:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801cad:	83 c3 01             	add    $0x1,%ebx
  801cb0:	83 c4 10             	add    $0x10,%esp
  801cb3:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801cba:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801cbd:	85 c0                	test   %eax,%eax
  801cbf:	75 df                	jne    801ca0 <spawn+0xde>
  801cc1:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801cc7:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801ccd:	bf 00 10 40 00       	mov    $0x401000,%edi
  801cd2:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801cd4:	89 fa                	mov    %edi,%edx
  801cd6:	83 e2 fc             	and    $0xfffffffc,%edx
  801cd9:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801ce0:	29 c2                	sub    %eax,%edx
  801ce2:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801ce8:	8d 42 f8             	lea    -0x8(%edx),%eax
  801ceb:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801cf0:	0f 86 a2 03 00 00    	jbe    802098 <spawn+0x4d6>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801cf6:	83 ec 04             	sub    $0x4,%esp
  801cf9:	6a 07                	push   $0x7
  801cfb:	68 00 00 40 00       	push   $0x400000
  801d00:	6a 00                	push   $0x0
  801d02:	e8 55 ef ff ff       	call   800c5c <sys_page_alloc>
  801d07:	83 c4 10             	add    $0x10,%esp
  801d0a:	85 c0                	test   %eax,%eax
  801d0c:	0f 88 90 03 00 00    	js     8020a2 <spawn+0x4e0>
  801d12:	be 00 00 00 00       	mov    $0x0,%esi
  801d17:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801d1d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d20:	eb 30                	jmp    801d52 <spawn+0x190>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801d22:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801d28:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801d2e:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801d31:	83 ec 08             	sub    $0x8,%esp
  801d34:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801d37:	57                   	push   %edi
  801d38:	e8 1c eb ff ff       	call   800859 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801d3d:	83 c4 04             	add    $0x4,%esp
  801d40:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801d43:	e8 d8 ea ff ff       	call   800820 <strlen>
  801d48:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801d4c:	83 c6 01             	add    $0x1,%esi
  801d4f:	83 c4 10             	add    $0x10,%esp
  801d52:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801d58:	7f c8                	jg     801d22 <spawn+0x160>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801d5a:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801d60:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801d66:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801d6d:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801d73:	74 19                	je     801d8e <spawn+0x1cc>
  801d75:	68 64 31 80 00       	push   $0x803164
  801d7a:	68 ab 30 80 00       	push   $0x8030ab
  801d7f:	68 f2 00 00 00       	push   $0xf2
  801d84:	68 f1 30 80 00       	push   $0x8030f1
  801d89:	e8 6d e4 ff ff       	call   8001fb <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801d8e:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801d94:	89 f8                	mov    %edi,%eax
  801d96:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801d9b:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801d9e:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801da4:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801da7:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801dad:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801db3:	83 ec 0c             	sub    $0xc,%esp
  801db6:	6a 07                	push   $0x7
  801db8:	68 00 d0 bf ee       	push   $0xeebfd000
  801dbd:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801dc3:	68 00 00 40 00       	push   $0x400000
  801dc8:	6a 00                	push   $0x0
  801dca:	e8 d0 ee ff ff       	call   800c9f <sys_page_map>
  801dcf:	89 c3                	mov    %eax,%ebx
  801dd1:	83 c4 20             	add    $0x20,%esp
  801dd4:	85 c0                	test   %eax,%eax
  801dd6:	0f 88 3c 03 00 00    	js     802118 <spawn+0x556>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801ddc:	83 ec 08             	sub    $0x8,%esp
  801ddf:	68 00 00 40 00       	push   $0x400000
  801de4:	6a 00                	push   $0x0
  801de6:	e8 f6 ee ff ff       	call   800ce1 <sys_page_unmap>
  801deb:	89 c3                	mov    %eax,%ebx
  801ded:	83 c4 10             	add    $0x10,%esp
  801df0:	85 c0                	test   %eax,%eax
  801df2:	0f 88 20 03 00 00    	js     802118 <spawn+0x556>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801df8:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801dfe:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801e05:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801e0b:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801e12:	00 00 00 
  801e15:	e9 88 01 00 00       	jmp    801fa2 <spawn+0x3e0>
		if (ph->p_type != ELF_PROG_LOAD)
  801e1a:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801e20:	83 38 01             	cmpl   $0x1,(%eax)
  801e23:	0f 85 6b 01 00 00    	jne    801f94 <spawn+0x3d2>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801e29:	89 c2                	mov    %eax,%edx
  801e2b:	8b 40 18             	mov    0x18(%eax),%eax
  801e2e:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801e34:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801e37:	83 f8 01             	cmp    $0x1,%eax
  801e3a:	19 c0                	sbb    %eax,%eax
  801e3c:	83 e0 fe             	and    $0xfffffffe,%eax
  801e3f:	83 c0 07             	add    $0x7,%eax
  801e42:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801e48:	89 d0                	mov    %edx,%eax
  801e4a:	8b 7a 04             	mov    0x4(%edx),%edi
  801e4d:	89 f9                	mov    %edi,%ecx
  801e4f:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801e55:	8b 7a 10             	mov    0x10(%edx),%edi
  801e58:	8b 52 14             	mov    0x14(%edx),%edx
  801e5b:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801e61:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801e64:	89 f0                	mov    %esi,%eax
  801e66:	25 ff 0f 00 00       	and    $0xfff,%eax
  801e6b:	74 14                	je     801e81 <spawn+0x2bf>
		va -= i;
  801e6d:	29 c6                	sub    %eax,%esi
		memsz += i;
  801e6f:	01 c2                	add    %eax,%edx
  801e71:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801e77:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801e79:	29 c1                	sub    %eax,%ecx
  801e7b:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801e81:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e86:	e9 f7 00 00 00       	jmp    801f82 <spawn+0x3c0>
		if (i >= filesz) {
  801e8b:	39 fb                	cmp    %edi,%ebx
  801e8d:	72 27                	jb     801eb6 <spawn+0x2f4>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801e8f:	83 ec 04             	sub    $0x4,%esp
  801e92:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801e98:	56                   	push   %esi
  801e99:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801e9f:	e8 b8 ed ff ff       	call   800c5c <sys_page_alloc>
  801ea4:	83 c4 10             	add    $0x10,%esp
  801ea7:	85 c0                	test   %eax,%eax
  801ea9:	0f 89 c7 00 00 00    	jns    801f76 <spawn+0x3b4>
  801eaf:	89 c3                	mov    %eax,%ebx
  801eb1:	e9 fd 01 00 00       	jmp    8020b3 <spawn+0x4f1>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801eb6:	83 ec 04             	sub    $0x4,%esp
  801eb9:	6a 07                	push   $0x7
  801ebb:	68 00 00 40 00       	push   $0x400000
  801ec0:	6a 00                	push   $0x0
  801ec2:	e8 95 ed ff ff       	call   800c5c <sys_page_alloc>
  801ec7:	83 c4 10             	add    $0x10,%esp
  801eca:	85 c0                	test   %eax,%eax
  801ecc:	0f 88 d7 01 00 00    	js     8020a9 <spawn+0x4e7>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801ed2:	83 ec 08             	sub    $0x8,%esp
  801ed5:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801edb:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801ee1:	50                   	push   %eax
  801ee2:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ee8:	e8 09 f9 ff ff       	call   8017f6 <seek>
  801eed:	83 c4 10             	add    $0x10,%esp
  801ef0:	85 c0                	test   %eax,%eax
  801ef2:	0f 88 b5 01 00 00    	js     8020ad <spawn+0x4eb>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801ef8:	83 ec 04             	sub    $0x4,%esp
  801efb:	89 f8                	mov    %edi,%eax
  801efd:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801f03:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801f08:	ba 00 10 00 00       	mov    $0x1000,%edx
  801f0d:	0f 47 c2             	cmova  %edx,%eax
  801f10:	50                   	push   %eax
  801f11:	68 00 00 40 00       	push   $0x400000
  801f16:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801f1c:	e8 fd f7 ff ff       	call   80171e <readn>
  801f21:	83 c4 10             	add    $0x10,%esp
  801f24:	85 c0                	test   %eax,%eax
  801f26:	0f 88 85 01 00 00    	js     8020b1 <spawn+0x4ef>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801f2c:	83 ec 0c             	sub    $0xc,%esp
  801f2f:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801f35:	56                   	push   %esi
  801f36:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801f3c:	68 00 00 40 00       	push   $0x400000
  801f41:	6a 00                	push   $0x0
  801f43:	e8 57 ed ff ff       	call   800c9f <sys_page_map>
  801f48:	83 c4 20             	add    $0x20,%esp
  801f4b:	85 c0                	test   %eax,%eax
  801f4d:	79 15                	jns    801f64 <spawn+0x3a2>
				panic("spawn: sys_page_map data: %e", r);
  801f4f:	50                   	push   %eax
  801f50:	68 fd 30 80 00       	push   $0x8030fd
  801f55:	68 25 01 00 00       	push   $0x125
  801f5a:	68 f1 30 80 00       	push   $0x8030f1
  801f5f:	e8 97 e2 ff ff       	call   8001fb <_panic>
			sys_page_unmap(0, UTEMP);
  801f64:	83 ec 08             	sub    $0x8,%esp
  801f67:	68 00 00 40 00       	push   $0x400000
  801f6c:	6a 00                	push   $0x0
  801f6e:	e8 6e ed ff ff       	call   800ce1 <sys_page_unmap>
  801f73:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801f76:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801f7c:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801f82:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801f88:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801f8e:	0f 82 f7 fe ff ff    	jb     801e8b <spawn+0x2c9>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f94:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801f9b:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801fa2:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801fa9:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801faf:	0f 8c 65 fe ff ff    	jl     801e1a <spawn+0x258>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801fb5:	83 ec 0c             	sub    $0xc,%esp
  801fb8:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801fbe:	e8 8b f5 ff ff       	call   80154e <close>
  801fc3:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801fc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fcb:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801fd1:	89 d8                	mov    %ebx,%eax
  801fd3:	c1 e8 16             	shr    $0x16,%eax
  801fd6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801fdd:	a8 01                	test   $0x1,%al
  801fdf:	74 42                	je     802023 <spawn+0x461>
  801fe1:	89 d8                	mov    %ebx,%eax
  801fe3:	c1 e8 0c             	shr    $0xc,%eax
  801fe6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801fed:	f6 c2 01             	test   $0x1,%dl
  801ff0:	74 31                	je     802023 <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  801ff2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801ff9:	f6 c6 04             	test   $0x4,%dh
  801ffc:	74 25                	je     802023 <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  801ffe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802005:	83 ec 0c             	sub    $0xc,%esp
  802008:	25 07 0e 00 00       	and    $0xe07,%eax
  80200d:	50                   	push   %eax
  80200e:	53                   	push   %ebx
  80200f:	56                   	push   %esi
  802010:	53                   	push   %ebx
  802011:	6a 00                	push   $0x0
  802013:	e8 87 ec ff ff       	call   800c9f <sys_page_map>
			if (r < 0) {
  802018:	83 c4 20             	add    $0x20,%esp
  80201b:	85 c0                	test   %eax,%eax
  80201d:	0f 88 b1 00 00 00    	js     8020d4 <spawn+0x512>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  802023:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802029:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  80202f:	75 a0                	jne    801fd1 <spawn+0x40f>
  802031:	e9 b3 00 00 00       	jmp    8020e9 <spawn+0x527>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  802036:	50                   	push   %eax
  802037:	68 1a 31 80 00       	push   $0x80311a
  80203c:	68 86 00 00 00       	push   $0x86
  802041:	68 f1 30 80 00       	push   $0x8030f1
  802046:	e8 b0 e1 ff ff       	call   8001fb <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  80204b:	83 ec 08             	sub    $0x8,%esp
  80204e:	6a 02                	push   $0x2
  802050:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802056:	e8 c8 ec ff ff       	call   800d23 <sys_env_set_status>
  80205b:	83 c4 10             	add    $0x10,%esp
  80205e:	85 c0                	test   %eax,%eax
  802060:	79 2b                	jns    80208d <spawn+0x4cb>
		panic("sys_env_set_status: %e", r);
  802062:	50                   	push   %eax
  802063:	68 34 31 80 00       	push   $0x803134
  802068:	68 89 00 00 00       	push   $0x89
  80206d:	68 f1 30 80 00       	push   $0x8030f1
  802072:	e8 84 e1 ff ff       	call   8001fb <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802077:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  80207d:	e9 a8 00 00 00       	jmp    80212a <spawn+0x568>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802082:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802088:	e9 9d 00 00 00       	jmp    80212a <spawn+0x568>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  80208d:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802093:	e9 92 00 00 00       	jmp    80212a <spawn+0x568>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802098:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  80209d:	e9 88 00 00 00       	jmp    80212a <spawn+0x568>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  8020a2:	89 c3                	mov    %eax,%ebx
  8020a4:	e9 81 00 00 00       	jmp    80212a <spawn+0x568>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8020a9:	89 c3                	mov    %eax,%ebx
  8020ab:	eb 06                	jmp    8020b3 <spawn+0x4f1>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8020ad:	89 c3                	mov    %eax,%ebx
  8020af:	eb 02                	jmp    8020b3 <spawn+0x4f1>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8020b1:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  8020b3:	83 ec 0c             	sub    $0xc,%esp
  8020b6:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8020bc:	e8 1c eb ff ff       	call   800bdd <sys_env_destroy>
	close(fd);
  8020c1:	83 c4 04             	add    $0x4,%esp
  8020c4:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8020ca:	e8 7f f4 ff ff       	call   80154e <close>
	return r;
  8020cf:	83 c4 10             	add    $0x10,%esp
  8020d2:	eb 56                	jmp    80212a <spawn+0x568>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  8020d4:	50                   	push   %eax
  8020d5:	68 4b 31 80 00       	push   $0x80314b
  8020da:	68 82 00 00 00       	push   $0x82
  8020df:	68 f1 30 80 00       	push   $0x8030f1
  8020e4:	e8 12 e1 ff ff       	call   8001fb <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  8020e9:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  8020f0:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8020f3:	83 ec 08             	sub    $0x8,%esp
  8020f6:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8020fc:	50                   	push   %eax
  8020fd:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802103:	e8 5d ec ff ff       	call   800d65 <sys_env_set_trapframe>
  802108:	83 c4 10             	add    $0x10,%esp
  80210b:	85 c0                	test   %eax,%eax
  80210d:	0f 89 38 ff ff ff    	jns    80204b <spawn+0x489>
  802113:	e9 1e ff ff ff       	jmp    802036 <spawn+0x474>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802118:	83 ec 08             	sub    $0x8,%esp
  80211b:	68 00 00 40 00       	push   $0x400000
  802120:	6a 00                	push   $0x0
  802122:	e8 ba eb ff ff       	call   800ce1 <sys_page_unmap>
  802127:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  80212a:	89 d8                	mov    %ebx,%eax
  80212c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80212f:	5b                   	pop    %ebx
  802130:	5e                   	pop    %esi
  802131:	5f                   	pop    %edi
  802132:	5d                   	pop    %ebp
  802133:	c3                   	ret    

00802134 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802134:	55                   	push   %ebp
  802135:	89 e5                	mov    %esp,%ebp
  802137:	56                   	push   %esi
  802138:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802139:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  80213c:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802141:	eb 03                	jmp    802146 <spawnl+0x12>
		argc++;
  802143:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802146:	83 c2 04             	add    $0x4,%edx
  802149:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  80214d:	75 f4                	jne    802143 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80214f:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802156:	83 e2 f0             	and    $0xfffffff0,%edx
  802159:	29 d4                	sub    %edx,%esp
  80215b:	8d 54 24 03          	lea    0x3(%esp),%edx
  80215f:	c1 ea 02             	shr    $0x2,%edx
  802162:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802169:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  80216b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80216e:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802175:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  80217c:	00 
  80217d:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  80217f:	b8 00 00 00 00       	mov    $0x0,%eax
  802184:	eb 0a                	jmp    802190 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802186:	83 c0 01             	add    $0x1,%eax
  802189:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  80218d:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802190:	39 d0                	cmp    %edx,%eax
  802192:	75 f2                	jne    802186 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802194:	83 ec 08             	sub    $0x8,%esp
  802197:	56                   	push   %esi
  802198:	ff 75 08             	pushl  0x8(%ebp)
  80219b:	e8 22 fa ff ff       	call   801bc2 <spawn>
}
  8021a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021a3:	5b                   	pop    %ebx
  8021a4:	5e                   	pop    %esi
  8021a5:	5d                   	pop    %ebp
  8021a6:	c3                   	ret    

008021a7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8021a7:	55                   	push   %ebp
  8021a8:	89 e5                	mov    %esp,%ebp
  8021aa:	56                   	push   %esi
  8021ab:	53                   	push   %ebx
  8021ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8021af:	83 ec 0c             	sub    $0xc,%esp
  8021b2:	ff 75 08             	pushl  0x8(%ebp)
  8021b5:	e8 01 f2 ff ff       	call   8013bb <fd2data>
  8021ba:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8021bc:	83 c4 08             	add    $0x8,%esp
  8021bf:	68 8c 31 80 00       	push   $0x80318c
  8021c4:	53                   	push   %ebx
  8021c5:	e8 8f e6 ff ff       	call   800859 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8021ca:	8b 46 04             	mov    0x4(%esi),%eax
  8021cd:	2b 06                	sub    (%esi),%eax
  8021cf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8021d5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8021dc:	00 00 00 
	stat->st_dev = &devpipe;
  8021df:	c7 83 88 00 00 00 28 	movl   $0x804028,0x88(%ebx)
  8021e6:	40 80 00 
	return 0;
}
  8021e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8021ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021f1:	5b                   	pop    %ebx
  8021f2:	5e                   	pop    %esi
  8021f3:	5d                   	pop    %ebp
  8021f4:	c3                   	ret    

008021f5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8021f5:	55                   	push   %ebp
  8021f6:	89 e5                	mov    %esp,%ebp
  8021f8:	53                   	push   %ebx
  8021f9:	83 ec 0c             	sub    $0xc,%esp
  8021fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8021ff:	53                   	push   %ebx
  802200:	6a 00                	push   $0x0
  802202:	e8 da ea ff ff       	call   800ce1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802207:	89 1c 24             	mov    %ebx,(%esp)
  80220a:	e8 ac f1 ff ff       	call   8013bb <fd2data>
  80220f:	83 c4 08             	add    $0x8,%esp
  802212:	50                   	push   %eax
  802213:	6a 00                	push   $0x0
  802215:	e8 c7 ea ff ff       	call   800ce1 <sys_page_unmap>
}
  80221a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80221d:	c9                   	leave  
  80221e:	c3                   	ret    

0080221f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80221f:	55                   	push   %ebp
  802220:	89 e5                	mov    %esp,%ebp
  802222:	57                   	push   %edi
  802223:	56                   	push   %esi
  802224:	53                   	push   %ebx
  802225:	83 ec 1c             	sub    $0x1c,%esp
  802228:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80222b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80222d:	a1 04 50 80 00       	mov    0x805004,%eax
  802232:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802238:	83 ec 0c             	sub    $0xc,%esp
  80223b:	ff 75 e0             	pushl  -0x20(%ebp)
  80223e:	e8 55 06 00 00       	call   802898 <pageref>
  802243:	89 c3                	mov    %eax,%ebx
  802245:	89 3c 24             	mov    %edi,(%esp)
  802248:	e8 4b 06 00 00       	call   802898 <pageref>
  80224d:	83 c4 10             	add    $0x10,%esp
  802250:	39 c3                	cmp    %eax,%ebx
  802252:	0f 94 c1             	sete   %cl
  802255:	0f b6 c9             	movzbl %cl,%ecx
  802258:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80225b:	8b 15 04 50 80 00    	mov    0x805004,%edx
  802261:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  802267:	39 ce                	cmp    %ecx,%esi
  802269:	74 1e                	je     802289 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  80226b:	39 c3                	cmp    %eax,%ebx
  80226d:	75 be                	jne    80222d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80226f:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  802275:	ff 75 e4             	pushl  -0x1c(%ebp)
  802278:	50                   	push   %eax
  802279:	56                   	push   %esi
  80227a:	68 93 31 80 00       	push   $0x803193
  80227f:	e8 50 e0 ff ff       	call   8002d4 <cprintf>
  802284:	83 c4 10             	add    $0x10,%esp
  802287:	eb a4                	jmp    80222d <_pipeisclosed+0xe>
	}
}
  802289:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80228c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80228f:	5b                   	pop    %ebx
  802290:	5e                   	pop    %esi
  802291:	5f                   	pop    %edi
  802292:	5d                   	pop    %ebp
  802293:	c3                   	ret    

00802294 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802294:	55                   	push   %ebp
  802295:	89 e5                	mov    %esp,%ebp
  802297:	57                   	push   %edi
  802298:	56                   	push   %esi
  802299:	53                   	push   %ebx
  80229a:	83 ec 28             	sub    $0x28,%esp
  80229d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8022a0:	56                   	push   %esi
  8022a1:	e8 15 f1 ff ff       	call   8013bb <fd2data>
  8022a6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022a8:	83 c4 10             	add    $0x10,%esp
  8022ab:	bf 00 00 00 00       	mov    $0x0,%edi
  8022b0:	eb 4b                	jmp    8022fd <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8022b2:	89 da                	mov    %ebx,%edx
  8022b4:	89 f0                	mov    %esi,%eax
  8022b6:	e8 64 ff ff ff       	call   80221f <_pipeisclosed>
  8022bb:	85 c0                	test   %eax,%eax
  8022bd:	75 48                	jne    802307 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8022bf:	e8 79 e9 ff ff       	call   800c3d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8022c4:	8b 43 04             	mov    0x4(%ebx),%eax
  8022c7:	8b 0b                	mov    (%ebx),%ecx
  8022c9:	8d 51 20             	lea    0x20(%ecx),%edx
  8022cc:	39 d0                	cmp    %edx,%eax
  8022ce:	73 e2                	jae    8022b2 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8022d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022d3:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8022d7:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8022da:	89 c2                	mov    %eax,%edx
  8022dc:	c1 fa 1f             	sar    $0x1f,%edx
  8022df:	89 d1                	mov    %edx,%ecx
  8022e1:	c1 e9 1b             	shr    $0x1b,%ecx
  8022e4:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8022e7:	83 e2 1f             	and    $0x1f,%edx
  8022ea:	29 ca                	sub    %ecx,%edx
  8022ec:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8022f0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8022f4:	83 c0 01             	add    $0x1,%eax
  8022f7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022fa:	83 c7 01             	add    $0x1,%edi
  8022fd:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802300:	75 c2                	jne    8022c4 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802302:	8b 45 10             	mov    0x10(%ebp),%eax
  802305:	eb 05                	jmp    80230c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802307:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80230c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80230f:	5b                   	pop    %ebx
  802310:	5e                   	pop    %esi
  802311:	5f                   	pop    %edi
  802312:	5d                   	pop    %ebp
  802313:	c3                   	ret    

00802314 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802314:	55                   	push   %ebp
  802315:	89 e5                	mov    %esp,%ebp
  802317:	57                   	push   %edi
  802318:	56                   	push   %esi
  802319:	53                   	push   %ebx
  80231a:	83 ec 18             	sub    $0x18,%esp
  80231d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802320:	57                   	push   %edi
  802321:	e8 95 f0 ff ff       	call   8013bb <fd2data>
  802326:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802328:	83 c4 10             	add    $0x10,%esp
  80232b:	bb 00 00 00 00       	mov    $0x0,%ebx
  802330:	eb 3d                	jmp    80236f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802332:	85 db                	test   %ebx,%ebx
  802334:	74 04                	je     80233a <devpipe_read+0x26>
				return i;
  802336:	89 d8                	mov    %ebx,%eax
  802338:	eb 44                	jmp    80237e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80233a:	89 f2                	mov    %esi,%edx
  80233c:	89 f8                	mov    %edi,%eax
  80233e:	e8 dc fe ff ff       	call   80221f <_pipeisclosed>
  802343:	85 c0                	test   %eax,%eax
  802345:	75 32                	jne    802379 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802347:	e8 f1 e8 ff ff       	call   800c3d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80234c:	8b 06                	mov    (%esi),%eax
  80234e:	3b 46 04             	cmp    0x4(%esi),%eax
  802351:	74 df                	je     802332 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802353:	99                   	cltd   
  802354:	c1 ea 1b             	shr    $0x1b,%edx
  802357:	01 d0                	add    %edx,%eax
  802359:	83 e0 1f             	and    $0x1f,%eax
  80235c:	29 d0                	sub    %edx,%eax
  80235e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802363:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802366:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802369:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80236c:	83 c3 01             	add    $0x1,%ebx
  80236f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802372:	75 d8                	jne    80234c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802374:	8b 45 10             	mov    0x10(%ebp),%eax
  802377:	eb 05                	jmp    80237e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802379:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80237e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802381:	5b                   	pop    %ebx
  802382:	5e                   	pop    %esi
  802383:	5f                   	pop    %edi
  802384:	5d                   	pop    %ebp
  802385:	c3                   	ret    

00802386 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802386:	55                   	push   %ebp
  802387:	89 e5                	mov    %esp,%ebp
  802389:	56                   	push   %esi
  80238a:	53                   	push   %ebx
  80238b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80238e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802391:	50                   	push   %eax
  802392:	e8 3b f0 ff ff       	call   8013d2 <fd_alloc>
  802397:	83 c4 10             	add    $0x10,%esp
  80239a:	89 c2                	mov    %eax,%edx
  80239c:	85 c0                	test   %eax,%eax
  80239e:	0f 88 2c 01 00 00    	js     8024d0 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023a4:	83 ec 04             	sub    $0x4,%esp
  8023a7:	68 07 04 00 00       	push   $0x407
  8023ac:	ff 75 f4             	pushl  -0xc(%ebp)
  8023af:	6a 00                	push   $0x0
  8023b1:	e8 a6 e8 ff ff       	call   800c5c <sys_page_alloc>
  8023b6:	83 c4 10             	add    $0x10,%esp
  8023b9:	89 c2                	mov    %eax,%edx
  8023bb:	85 c0                	test   %eax,%eax
  8023bd:	0f 88 0d 01 00 00    	js     8024d0 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8023c3:	83 ec 0c             	sub    $0xc,%esp
  8023c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8023c9:	50                   	push   %eax
  8023ca:	e8 03 f0 ff ff       	call   8013d2 <fd_alloc>
  8023cf:	89 c3                	mov    %eax,%ebx
  8023d1:	83 c4 10             	add    $0x10,%esp
  8023d4:	85 c0                	test   %eax,%eax
  8023d6:	0f 88 e2 00 00 00    	js     8024be <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023dc:	83 ec 04             	sub    $0x4,%esp
  8023df:	68 07 04 00 00       	push   $0x407
  8023e4:	ff 75 f0             	pushl  -0x10(%ebp)
  8023e7:	6a 00                	push   $0x0
  8023e9:	e8 6e e8 ff ff       	call   800c5c <sys_page_alloc>
  8023ee:	89 c3                	mov    %eax,%ebx
  8023f0:	83 c4 10             	add    $0x10,%esp
  8023f3:	85 c0                	test   %eax,%eax
  8023f5:	0f 88 c3 00 00 00    	js     8024be <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8023fb:	83 ec 0c             	sub    $0xc,%esp
  8023fe:	ff 75 f4             	pushl  -0xc(%ebp)
  802401:	e8 b5 ef ff ff       	call   8013bb <fd2data>
  802406:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802408:	83 c4 0c             	add    $0xc,%esp
  80240b:	68 07 04 00 00       	push   $0x407
  802410:	50                   	push   %eax
  802411:	6a 00                	push   $0x0
  802413:	e8 44 e8 ff ff       	call   800c5c <sys_page_alloc>
  802418:	89 c3                	mov    %eax,%ebx
  80241a:	83 c4 10             	add    $0x10,%esp
  80241d:	85 c0                	test   %eax,%eax
  80241f:	0f 88 89 00 00 00    	js     8024ae <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802425:	83 ec 0c             	sub    $0xc,%esp
  802428:	ff 75 f0             	pushl  -0x10(%ebp)
  80242b:	e8 8b ef ff ff       	call   8013bb <fd2data>
  802430:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802437:	50                   	push   %eax
  802438:	6a 00                	push   $0x0
  80243a:	56                   	push   %esi
  80243b:	6a 00                	push   $0x0
  80243d:	e8 5d e8 ff ff       	call   800c9f <sys_page_map>
  802442:	89 c3                	mov    %eax,%ebx
  802444:	83 c4 20             	add    $0x20,%esp
  802447:	85 c0                	test   %eax,%eax
  802449:	78 55                	js     8024a0 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80244b:	8b 15 28 40 80 00    	mov    0x804028,%edx
  802451:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802454:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802456:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802459:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802460:	8b 15 28 40 80 00    	mov    0x804028,%edx
  802466:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802469:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80246b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80246e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802475:	83 ec 0c             	sub    $0xc,%esp
  802478:	ff 75 f4             	pushl  -0xc(%ebp)
  80247b:	e8 2b ef ff ff       	call   8013ab <fd2num>
  802480:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802483:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802485:	83 c4 04             	add    $0x4,%esp
  802488:	ff 75 f0             	pushl  -0x10(%ebp)
  80248b:	e8 1b ef ff ff       	call   8013ab <fd2num>
  802490:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802493:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  802496:	83 c4 10             	add    $0x10,%esp
  802499:	ba 00 00 00 00       	mov    $0x0,%edx
  80249e:	eb 30                	jmp    8024d0 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8024a0:	83 ec 08             	sub    $0x8,%esp
  8024a3:	56                   	push   %esi
  8024a4:	6a 00                	push   $0x0
  8024a6:	e8 36 e8 ff ff       	call   800ce1 <sys_page_unmap>
  8024ab:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8024ae:	83 ec 08             	sub    $0x8,%esp
  8024b1:	ff 75 f0             	pushl  -0x10(%ebp)
  8024b4:	6a 00                	push   $0x0
  8024b6:	e8 26 e8 ff ff       	call   800ce1 <sys_page_unmap>
  8024bb:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8024be:	83 ec 08             	sub    $0x8,%esp
  8024c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8024c4:	6a 00                	push   $0x0
  8024c6:	e8 16 e8 ff ff       	call   800ce1 <sys_page_unmap>
  8024cb:	83 c4 10             	add    $0x10,%esp
  8024ce:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8024d0:	89 d0                	mov    %edx,%eax
  8024d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024d5:	5b                   	pop    %ebx
  8024d6:	5e                   	pop    %esi
  8024d7:	5d                   	pop    %ebp
  8024d8:	c3                   	ret    

008024d9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8024d9:	55                   	push   %ebp
  8024da:	89 e5                	mov    %esp,%ebp
  8024dc:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024e2:	50                   	push   %eax
  8024e3:	ff 75 08             	pushl  0x8(%ebp)
  8024e6:	e8 36 ef ff ff       	call   801421 <fd_lookup>
  8024eb:	83 c4 10             	add    $0x10,%esp
  8024ee:	85 c0                	test   %eax,%eax
  8024f0:	78 18                	js     80250a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8024f2:	83 ec 0c             	sub    $0xc,%esp
  8024f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8024f8:	e8 be ee ff ff       	call   8013bb <fd2data>
	return _pipeisclosed(fd, p);
  8024fd:	89 c2                	mov    %eax,%edx
  8024ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802502:	e8 18 fd ff ff       	call   80221f <_pipeisclosed>
  802507:	83 c4 10             	add    $0x10,%esp
}
  80250a:	c9                   	leave  
  80250b:	c3                   	ret    

0080250c <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80250c:	55                   	push   %ebp
  80250d:	89 e5                	mov    %esp,%ebp
  80250f:	56                   	push   %esi
  802510:	53                   	push   %ebx
  802511:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802514:	85 f6                	test   %esi,%esi
  802516:	75 16                	jne    80252e <wait+0x22>
  802518:	68 ab 31 80 00       	push   $0x8031ab
  80251d:	68 ab 30 80 00       	push   $0x8030ab
  802522:	6a 09                	push   $0x9
  802524:	68 b6 31 80 00       	push   $0x8031b6
  802529:	e8 cd dc ff ff       	call   8001fb <_panic>
	e = &envs[ENVX(envid)];
  80252e:	89 f3                	mov    %esi,%ebx
  802530:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802536:	69 db d4 00 00 00    	imul   $0xd4,%ebx,%ebx
  80253c:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802542:	eb 05                	jmp    802549 <wait+0x3d>
		sys_yield();
  802544:	e8 f4 e6 ff ff       	call   800c3d <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802549:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
  80254f:	39 c6                	cmp    %eax,%esi
  802551:	75 0a                	jne    80255d <wait+0x51>
  802553:	8b 83 ac 00 00 00    	mov    0xac(%ebx),%eax
  802559:	85 c0                	test   %eax,%eax
  80255b:	75 e7                	jne    802544 <wait+0x38>
		sys_yield();
}
  80255d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802560:	5b                   	pop    %ebx
  802561:	5e                   	pop    %esi
  802562:	5d                   	pop    %ebp
  802563:	c3                   	ret    

00802564 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802564:	55                   	push   %ebp
  802565:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802567:	b8 00 00 00 00       	mov    $0x0,%eax
  80256c:	5d                   	pop    %ebp
  80256d:	c3                   	ret    

0080256e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80256e:	55                   	push   %ebp
  80256f:	89 e5                	mov    %esp,%ebp
  802571:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802574:	68 c1 31 80 00       	push   $0x8031c1
  802579:	ff 75 0c             	pushl  0xc(%ebp)
  80257c:	e8 d8 e2 ff ff       	call   800859 <strcpy>
	return 0;
}
  802581:	b8 00 00 00 00       	mov    $0x0,%eax
  802586:	c9                   	leave  
  802587:	c3                   	ret    

00802588 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802588:	55                   	push   %ebp
  802589:	89 e5                	mov    %esp,%ebp
  80258b:	57                   	push   %edi
  80258c:	56                   	push   %esi
  80258d:	53                   	push   %ebx
  80258e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802594:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802599:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80259f:	eb 2d                	jmp    8025ce <devcons_write+0x46>
		m = n - tot;
  8025a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025a4:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8025a6:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8025a9:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8025ae:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8025b1:	83 ec 04             	sub    $0x4,%esp
  8025b4:	53                   	push   %ebx
  8025b5:	03 45 0c             	add    0xc(%ebp),%eax
  8025b8:	50                   	push   %eax
  8025b9:	57                   	push   %edi
  8025ba:	e8 2c e4 ff ff       	call   8009eb <memmove>
		sys_cputs(buf, m);
  8025bf:	83 c4 08             	add    $0x8,%esp
  8025c2:	53                   	push   %ebx
  8025c3:	57                   	push   %edi
  8025c4:	e8 d7 e5 ff ff       	call   800ba0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8025c9:	01 de                	add    %ebx,%esi
  8025cb:	83 c4 10             	add    $0x10,%esp
  8025ce:	89 f0                	mov    %esi,%eax
  8025d0:	3b 75 10             	cmp    0x10(%ebp),%esi
  8025d3:	72 cc                	jb     8025a1 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8025d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025d8:	5b                   	pop    %ebx
  8025d9:	5e                   	pop    %esi
  8025da:	5f                   	pop    %edi
  8025db:	5d                   	pop    %ebp
  8025dc:	c3                   	ret    

008025dd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8025dd:	55                   	push   %ebp
  8025de:	89 e5                	mov    %esp,%ebp
  8025e0:	83 ec 08             	sub    $0x8,%esp
  8025e3:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8025e8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8025ec:	74 2a                	je     802618 <devcons_read+0x3b>
  8025ee:	eb 05                	jmp    8025f5 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8025f0:	e8 48 e6 ff ff       	call   800c3d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8025f5:	e8 c4 e5 ff ff       	call   800bbe <sys_cgetc>
  8025fa:	85 c0                	test   %eax,%eax
  8025fc:	74 f2                	je     8025f0 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8025fe:	85 c0                	test   %eax,%eax
  802600:	78 16                	js     802618 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802602:	83 f8 04             	cmp    $0x4,%eax
  802605:	74 0c                	je     802613 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802607:	8b 55 0c             	mov    0xc(%ebp),%edx
  80260a:	88 02                	mov    %al,(%edx)
	return 1;
  80260c:	b8 01 00 00 00       	mov    $0x1,%eax
  802611:	eb 05                	jmp    802618 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802613:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802618:	c9                   	leave  
  802619:	c3                   	ret    

0080261a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80261a:	55                   	push   %ebp
  80261b:	89 e5                	mov    %esp,%ebp
  80261d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802620:	8b 45 08             	mov    0x8(%ebp),%eax
  802623:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802626:	6a 01                	push   $0x1
  802628:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80262b:	50                   	push   %eax
  80262c:	e8 6f e5 ff ff       	call   800ba0 <sys_cputs>
}
  802631:	83 c4 10             	add    $0x10,%esp
  802634:	c9                   	leave  
  802635:	c3                   	ret    

00802636 <getchar>:

int
getchar(void)
{
  802636:	55                   	push   %ebp
  802637:	89 e5                	mov    %esp,%ebp
  802639:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80263c:	6a 01                	push   $0x1
  80263e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802641:	50                   	push   %eax
  802642:	6a 00                	push   $0x0
  802644:	e8 41 f0 ff ff       	call   80168a <read>
	if (r < 0)
  802649:	83 c4 10             	add    $0x10,%esp
  80264c:	85 c0                	test   %eax,%eax
  80264e:	78 0f                	js     80265f <getchar+0x29>
		return r;
	if (r < 1)
  802650:	85 c0                	test   %eax,%eax
  802652:	7e 06                	jle    80265a <getchar+0x24>
		return -E_EOF;
	return c;
  802654:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802658:	eb 05                	jmp    80265f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80265a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80265f:	c9                   	leave  
  802660:	c3                   	ret    

00802661 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802661:	55                   	push   %ebp
  802662:	89 e5                	mov    %esp,%ebp
  802664:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802667:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80266a:	50                   	push   %eax
  80266b:	ff 75 08             	pushl  0x8(%ebp)
  80266e:	e8 ae ed ff ff       	call   801421 <fd_lookup>
  802673:	83 c4 10             	add    $0x10,%esp
  802676:	85 c0                	test   %eax,%eax
  802678:	78 11                	js     80268b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80267a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80267d:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802683:	39 10                	cmp    %edx,(%eax)
  802685:	0f 94 c0             	sete   %al
  802688:	0f b6 c0             	movzbl %al,%eax
}
  80268b:	c9                   	leave  
  80268c:	c3                   	ret    

0080268d <opencons>:

int
opencons(void)
{
  80268d:	55                   	push   %ebp
  80268e:	89 e5                	mov    %esp,%ebp
  802690:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802693:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802696:	50                   	push   %eax
  802697:	e8 36 ed ff ff       	call   8013d2 <fd_alloc>
  80269c:	83 c4 10             	add    $0x10,%esp
		return r;
  80269f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8026a1:	85 c0                	test   %eax,%eax
  8026a3:	78 3e                	js     8026e3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8026a5:	83 ec 04             	sub    $0x4,%esp
  8026a8:	68 07 04 00 00       	push   $0x407
  8026ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8026b0:	6a 00                	push   $0x0
  8026b2:	e8 a5 e5 ff ff       	call   800c5c <sys_page_alloc>
  8026b7:	83 c4 10             	add    $0x10,%esp
		return r;
  8026ba:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8026bc:	85 c0                	test   %eax,%eax
  8026be:	78 23                	js     8026e3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8026c0:	8b 15 44 40 80 00    	mov    0x804044,%edx
  8026c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026c9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8026cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026ce:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8026d5:	83 ec 0c             	sub    $0xc,%esp
  8026d8:	50                   	push   %eax
  8026d9:	e8 cd ec ff ff       	call   8013ab <fd2num>
  8026de:	89 c2                	mov    %eax,%edx
  8026e0:	83 c4 10             	add    $0x10,%esp
}
  8026e3:	89 d0                	mov    %edx,%eax
  8026e5:	c9                   	leave  
  8026e6:	c3                   	ret    

008026e7 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8026e7:	55                   	push   %ebp
  8026e8:	89 e5                	mov    %esp,%ebp
  8026ea:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8026ed:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8026f4:	75 2a                	jne    802720 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  8026f6:	83 ec 04             	sub    $0x4,%esp
  8026f9:	6a 07                	push   $0x7
  8026fb:	68 00 f0 bf ee       	push   $0xeebff000
  802700:	6a 00                	push   $0x0
  802702:	e8 55 e5 ff ff       	call   800c5c <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802707:	83 c4 10             	add    $0x10,%esp
  80270a:	85 c0                	test   %eax,%eax
  80270c:	79 12                	jns    802720 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80270e:	50                   	push   %eax
  80270f:	68 12 30 80 00       	push   $0x803012
  802714:	6a 23                	push   $0x23
  802716:	68 cd 31 80 00       	push   $0x8031cd
  80271b:	e8 db da ff ff       	call   8001fb <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802720:	8b 45 08             	mov    0x8(%ebp),%eax
  802723:	a3 00 70 80 00       	mov    %eax,0x807000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802728:	83 ec 08             	sub    $0x8,%esp
  80272b:	68 52 27 80 00       	push   $0x802752
  802730:	6a 00                	push   $0x0
  802732:	e8 70 e6 ff ff       	call   800da7 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802737:	83 c4 10             	add    $0x10,%esp
  80273a:	85 c0                	test   %eax,%eax
  80273c:	79 12                	jns    802750 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  80273e:	50                   	push   %eax
  80273f:	68 12 30 80 00       	push   $0x803012
  802744:	6a 2c                	push   $0x2c
  802746:	68 cd 31 80 00       	push   $0x8031cd
  80274b:	e8 ab da ff ff       	call   8001fb <_panic>
	}
}
  802750:	c9                   	leave  
  802751:	c3                   	ret    

00802752 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802752:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802753:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802758:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80275a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  80275d:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802761:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802766:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80276a:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  80276c:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  80276f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802770:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802773:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802774:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802775:	c3                   	ret    

00802776 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802776:	55                   	push   %ebp
  802777:	89 e5                	mov    %esp,%ebp
  802779:	56                   	push   %esi
  80277a:	53                   	push   %ebx
  80277b:	8b 75 08             	mov    0x8(%ebp),%esi
  80277e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802781:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802784:	85 c0                	test   %eax,%eax
  802786:	75 12                	jne    80279a <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802788:	83 ec 0c             	sub    $0xc,%esp
  80278b:	68 00 00 c0 ee       	push   $0xeec00000
  802790:	e8 77 e6 ff ff       	call   800e0c <sys_ipc_recv>
  802795:	83 c4 10             	add    $0x10,%esp
  802798:	eb 0c                	jmp    8027a6 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80279a:	83 ec 0c             	sub    $0xc,%esp
  80279d:	50                   	push   %eax
  80279e:	e8 69 e6 ff ff       	call   800e0c <sys_ipc_recv>
  8027a3:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8027a6:	85 f6                	test   %esi,%esi
  8027a8:	0f 95 c1             	setne  %cl
  8027ab:	85 db                	test   %ebx,%ebx
  8027ad:	0f 95 c2             	setne  %dl
  8027b0:	84 d1                	test   %dl,%cl
  8027b2:	74 09                	je     8027bd <ipc_recv+0x47>
  8027b4:	89 c2                	mov    %eax,%edx
  8027b6:	c1 ea 1f             	shr    $0x1f,%edx
  8027b9:	84 d2                	test   %dl,%dl
  8027bb:	75 2d                	jne    8027ea <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8027bd:	85 f6                	test   %esi,%esi
  8027bf:	74 0d                	je     8027ce <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8027c1:	a1 04 50 80 00       	mov    0x805004,%eax
  8027c6:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  8027cc:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8027ce:	85 db                	test   %ebx,%ebx
  8027d0:	74 0d                	je     8027df <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8027d2:	a1 04 50 80 00       	mov    0x805004,%eax
  8027d7:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8027dd:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8027df:	a1 04 50 80 00       	mov    0x805004,%eax
  8027e4:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  8027ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8027ed:	5b                   	pop    %ebx
  8027ee:	5e                   	pop    %esi
  8027ef:	5d                   	pop    %ebp
  8027f0:	c3                   	ret    

008027f1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8027f1:	55                   	push   %ebp
  8027f2:	89 e5                	mov    %esp,%ebp
  8027f4:	57                   	push   %edi
  8027f5:	56                   	push   %esi
  8027f6:	53                   	push   %ebx
  8027f7:	83 ec 0c             	sub    $0xc,%esp
  8027fa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8027fd:	8b 75 0c             	mov    0xc(%ebp),%esi
  802800:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802803:	85 db                	test   %ebx,%ebx
  802805:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80280a:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80280d:	ff 75 14             	pushl  0x14(%ebp)
  802810:	53                   	push   %ebx
  802811:	56                   	push   %esi
  802812:	57                   	push   %edi
  802813:	e8 d1 e5 ff ff       	call   800de9 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802818:	89 c2                	mov    %eax,%edx
  80281a:	c1 ea 1f             	shr    $0x1f,%edx
  80281d:	83 c4 10             	add    $0x10,%esp
  802820:	84 d2                	test   %dl,%dl
  802822:	74 17                	je     80283b <ipc_send+0x4a>
  802824:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802827:	74 12                	je     80283b <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802829:	50                   	push   %eax
  80282a:	68 db 31 80 00       	push   $0x8031db
  80282f:	6a 47                	push   $0x47
  802831:	68 e9 31 80 00       	push   $0x8031e9
  802836:	e8 c0 d9 ff ff       	call   8001fb <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80283b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80283e:	75 07                	jne    802847 <ipc_send+0x56>
			sys_yield();
  802840:	e8 f8 e3 ff ff       	call   800c3d <sys_yield>
  802845:	eb c6                	jmp    80280d <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802847:	85 c0                	test   %eax,%eax
  802849:	75 c2                	jne    80280d <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80284b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80284e:	5b                   	pop    %ebx
  80284f:	5e                   	pop    %esi
  802850:	5f                   	pop    %edi
  802851:	5d                   	pop    %ebp
  802852:	c3                   	ret    

00802853 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802853:	55                   	push   %ebp
  802854:	89 e5                	mov    %esp,%ebp
  802856:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802859:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80285e:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  802864:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80286a:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  802870:	39 ca                	cmp    %ecx,%edx
  802872:	75 13                	jne    802887 <ipc_find_env+0x34>
			return envs[i].env_id;
  802874:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  80287a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80287f:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  802885:	eb 0f                	jmp    802896 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802887:	83 c0 01             	add    $0x1,%eax
  80288a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80288f:	75 cd                	jne    80285e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802891:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802896:	5d                   	pop    %ebp
  802897:	c3                   	ret    

00802898 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802898:	55                   	push   %ebp
  802899:	89 e5                	mov    %esp,%ebp
  80289b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80289e:	89 d0                	mov    %edx,%eax
  8028a0:	c1 e8 16             	shr    $0x16,%eax
  8028a3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8028aa:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8028af:	f6 c1 01             	test   $0x1,%cl
  8028b2:	74 1d                	je     8028d1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8028b4:	c1 ea 0c             	shr    $0xc,%edx
  8028b7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8028be:	f6 c2 01             	test   $0x1,%dl
  8028c1:	74 0e                	je     8028d1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8028c3:	c1 ea 0c             	shr    $0xc,%edx
  8028c6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8028cd:	ef 
  8028ce:	0f b7 c0             	movzwl %ax,%eax
}
  8028d1:	5d                   	pop    %ebp
  8028d2:	c3                   	ret    
  8028d3:	66 90                	xchg   %ax,%ax
  8028d5:	66 90                	xchg   %ax,%ax
  8028d7:	66 90                	xchg   %ax,%ax
  8028d9:	66 90                	xchg   %ax,%ax
  8028db:	66 90                	xchg   %ax,%ax
  8028dd:	66 90                	xchg   %ax,%ax
  8028df:	90                   	nop

008028e0 <__udivdi3>:
  8028e0:	55                   	push   %ebp
  8028e1:	57                   	push   %edi
  8028e2:	56                   	push   %esi
  8028e3:	53                   	push   %ebx
  8028e4:	83 ec 1c             	sub    $0x1c,%esp
  8028e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8028eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8028ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8028f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8028f7:	85 f6                	test   %esi,%esi
  8028f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8028fd:	89 ca                	mov    %ecx,%edx
  8028ff:	89 f8                	mov    %edi,%eax
  802901:	75 3d                	jne    802940 <__udivdi3+0x60>
  802903:	39 cf                	cmp    %ecx,%edi
  802905:	0f 87 c5 00 00 00    	ja     8029d0 <__udivdi3+0xf0>
  80290b:	85 ff                	test   %edi,%edi
  80290d:	89 fd                	mov    %edi,%ebp
  80290f:	75 0b                	jne    80291c <__udivdi3+0x3c>
  802911:	b8 01 00 00 00       	mov    $0x1,%eax
  802916:	31 d2                	xor    %edx,%edx
  802918:	f7 f7                	div    %edi
  80291a:	89 c5                	mov    %eax,%ebp
  80291c:	89 c8                	mov    %ecx,%eax
  80291e:	31 d2                	xor    %edx,%edx
  802920:	f7 f5                	div    %ebp
  802922:	89 c1                	mov    %eax,%ecx
  802924:	89 d8                	mov    %ebx,%eax
  802926:	89 cf                	mov    %ecx,%edi
  802928:	f7 f5                	div    %ebp
  80292a:	89 c3                	mov    %eax,%ebx
  80292c:	89 d8                	mov    %ebx,%eax
  80292e:	89 fa                	mov    %edi,%edx
  802930:	83 c4 1c             	add    $0x1c,%esp
  802933:	5b                   	pop    %ebx
  802934:	5e                   	pop    %esi
  802935:	5f                   	pop    %edi
  802936:	5d                   	pop    %ebp
  802937:	c3                   	ret    
  802938:	90                   	nop
  802939:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802940:	39 ce                	cmp    %ecx,%esi
  802942:	77 74                	ja     8029b8 <__udivdi3+0xd8>
  802944:	0f bd fe             	bsr    %esi,%edi
  802947:	83 f7 1f             	xor    $0x1f,%edi
  80294a:	0f 84 98 00 00 00    	je     8029e8 <__udivdi3+0x108>
  802950:	bb 20 00 00 00       	mov    $0x20,%ebx
  802955:	89 f9                	mov    %edi,%ecx
  802957:	89 c5                	mov    %eax,%ebp
  802959:	29 fb                	sub    %edi,%ebx
  80295b:	d3 e6                	shl    %cl,%esi
  80295d:	89 d9                	mov    %ebx,%ecx
  80295f:	d3 ed                	shr    %cl,%ebp
  802961:	89 f9                	mov    %edi,%ecx
  802963:	d3 e0                	shl    %cl,%eax
  802965:	09 ee                	or     %ebp,%esi
  802967:	89 d9                	mov    %ebx,%ecx
  802969:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80296d:	89 d5                	mov    %edx,%ebp
  80296f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802973:	d3 ed                	shr    %cl,%ebp
  802975:	89 f9                	mov    %edi,%ecx
  802977:	d3 e2                	shl    %cl,%edx
  802979:	89 d9                	mov    %ebx,%ecx
  80297b:	d3 e8                	shr    %cl,%eax
  80297d:	09 c2                	or     %eax,%edx
  80297f:	89 d0                	mov    %edx,%eax
  802981:	89 ea                	mov    %ebp,%edx
  802983:	f7 f6                	div    %esi
  802985:	89 d5                	mov    %edx,%ebp
  802987:	89 c3                	mov    %eax,%ebx
  802989:	f7 64 24 0c          	mull   0xc(%esp)
  80298d:	39 d5                	cmp    %edx,%ebp
  80298f:	72 10                	jb     8029a1 <__udivdi3+0xc1>
  802991:	8b 74 24 08          	mov    0x8(%esp),%esi
  802995:	89 f9                	mov    %edi,%ecx
  802997:	d3 e6                	shl    %cl,%esi
  802999:	39 c6                	cmp    %eax,%esi
  80299b:	73 07                	jae    8029a4 <__udivdi3+0xc4>
  80299d:	39 d5                	cmp    %edx,%ebp
  80299f:	75 03                	jne    8029a4 <__udivdi3+0xc4>
  8029a1:	83 eb 01             	sub    $0x1,%ebx
  8029a4:	31 ff                	xor    %edi,%edi
  8029a6:	89 d8                	mov    %ebx,%eax
  8029a8:	89 fa                	mov    %edi,%edx
  8029aa:	83 c4 1c             	add    $0x1c,%esp
  8029ad:	5b                   	pop    %ebx
  8029ae:	5e                   	pop    %esi
  8029af:	5f                   	pop    %edi
  8029b0:	5d                   	pop    %ebp
  8029b1:	c3                   	ret    
  8029b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8029b8:	31 ff                	xor    %edi,%edi
  8029ba:	31 db                	xor    %ebx,%ebx
  8029bc:	89 d8                	mov    %ebx,%eax
  8029be:	89 fa                	mov    %edi,%edx
  8029c0:	83 c4 1c             	add    $0x1c,%esp
  8029c3:	5b                   	pop    %ebx
  8029c4:	5e                   	pop    %esi
  8029c5:	5f                   	pop    %edi
  8029c6:	5d                   	pop    %ebp
  8029c7:	c3                   	ret    
  8029c8:	90                   	nop
  8029c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8029d0:	89 d8                	mov    %ebx,%eax
  8029d2:	f7 f7                	div    %edi
  8029d4:	31 ff                	xor    %edi,%edi
  8029d6:	89 c3                	mov    %eax,%ebx
  8029d8:	89 d8                	mov    %ebx,%eax
  8029da:	89 fa                	mov    %edi,%edx
  8029dc:	83 c4 1c             	add    $0x1c,%esp
  8029df:	5b                   	pop    %ebx
  8029e0:	5e                   	pop    %esi
  8029e1:	5f                   	pop    %edi
  8029e2:	5d                   	pop    %ebp
  8029e3:	c3                   	ret    
  8029e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8029e8:	39 ce                	cmp    %ecx,%esi
  8029ea:	72 0c                	jb     8029f8 <__udivdi3+0x118>
  8029ec:	31 db                	xor    %ebx,%ebx
  8029ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8029f2:	0f 87 34 ff ff ff    	ja     80292c <__udivdi3+0x4c>
  8029f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8029fd:	e9 2a ff ff ff       	jmp    80292c <__udivdi3+0x4c>
  802a02:	66 90                	xchg   %ax,%ax
  802a04:	66 90                	xchg   %ax,%ax
  802a06:	66 90                	xchg   %ax,%ax
  802a08:	66 90                	xchg   %ax,%ax
  802a0a:	66 90                	xchg   %ax,%ax
  802a0c:	66 90                	xchg   %ax,%ax
  802a0e:	66 90                	xchg   %ax,%ax

00802a10 <__umoddi3>:
  802a10:	55                   	push   %ebp
  802a11:	57                   	push   %edi
  802a12:	56                   	push   %esi
  802a13:	53                   	push   %ebx
  802a14:	83 ec 1c             	sub    $0x1c,%esp
  802a17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802a1b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802a1f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802a23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802a27:	85 d2                	test   %edx,%edx
  802a29:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802a2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802a31:	89 f3                	mov    %esi,%ebx
  802a33:	89 3c 24             	mov    %edi,(%esp)
  802a36:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a3a:	75 1c                	jne    802a58 <__umoddi3+0x48>
  802a3c:	39 f7                	cmp    %esi,%edi
  802a3e:	76 50                	jbe    802a90 <__umoddi3+0x80>
  802a40:	89 c8                	mov    %ecx,%eax
  802a42:	89 f2                	mov    %esi,%edx
  802a44:	f7 f7                	div    %edi
  802a46:	89 d0                	mov    %edx,%eax
  802a48:	31 d2                	xor    %edx,%edx
  802a4a:	83 c4 1c             	add    $0x1c,%esp
  802a4d:	5b                   	pop    %ebx
  802a4e:	5e                   	pop    %esi
  802a4f:	5f                   	pop    %edi
  802a50:	5d                   	pop    %ebp
  802a51:	c3                   	ret    
  802a52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802a58:	39 f2                	cmp    %esi,%edx
  802a5a:	89 d0                	mov    %edx,%eax
  802a5c:	77 52                	ja     802ab0 <__umoddi3+0xa0>
  802a5e:	0f bd ea             	bsr    %edx,%ebp
  802a61:	83 f5 1f             	xor    $0x1f,%ebp
  802a64:	75 5a                	jne    802ac0 <__umoddi3+0xb0>
  802a66:	3b 54 24 04          	cmp    0x4(%esp),%edx
  802a6a:	0f 82 e0 00 00 00    	jb     802b50 <__umoddi3+0x140>
  802a70:	39 0c 24             	cmp    %ecx,(%esp)
  802a73:	0f 86 d7 00 00 00    	jbe    802b50 <__umoddi3+0x140>
  802a79:	8b 44 24 08          	mov    0x8(%esp),%eax
  802a7d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802a81:	83 c4 1c             	add    $0x1c,%esp
  802a84:	5b                   	pop    %ebx
  802a85:	5e                   	pop    %esi
  802a86:	5f                   	pop    %edi
  802a87:	5d                   	pop    %ebp
  802a88:	c3                   	ret    
  802a89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802a90:	85 ff                	test   %edi,%edi
  802a92:	89 fd                	mov    %edi,%ebp
  802a94:	75 0b                	jne    802aa1 <__umoddi3+0x91>
  802a96:	b8 01 00 00 00       	mov    $0x1,%eax
  802a9b:	31 d2                	xor    %edx,%edx
  802a9d:	f7 f7                	div    %edi
  802a9f:	89 c5                	mov    %eax,%ebp
  802aa1:	89 f0                	mov    %esi,%eax
  802aa3:	31 d2                	xor    %edx,%edx
  802aa5:	f7 f5                	div    %ebp
  802aa7:	89 c8                	mov    %ecx,%eax
  802aa9:	f7 f5                	div    %ebp
  802aab:	89 d0                	mov    %edx,%eax
  802aad:	eb 99                	jmp    802a48 <__umoddi3+0x38>
  802aaf:	90                   	nop
  802ab0:	89 c8                	mov    %ecx,%eax
  802ab2:	89 f2                	mov    %esi,%edx
  802ab4:	83 c4 1c             	add    $0x1c,%esp
  802ab7:	5b                   	pop    %ebx
  802ab8:	5e                   	pop    %esi
  802ab9:	5f                   	pop    %edi
  802aba:	5d                   	pop    %ebp
  802abb:	c3                   	ret    
  802abc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ac0:	8b 34 24             	mov    (%esp),%esi
  802ac3:	bf 20 00 00 00       	mov    $0x20,%edi
  802ac8:	89 e9                	mov    %ebp,%ecx
  802aca:	29 ef                	sub    %ebp,%edi
  802acc:	d3 e0                	shl    %cl,%eax
  802ace:	89 f9                	mov    %edi,%ecx
  802ad0:	89 f2                	mov    %esi,%edx
  802ad2:	d3 ea                	shr    %cl,%edx
  802ad4:	89 e9                	mov    %ebp,%ecx
  802ad6:	09 c2                	or     %eax,%edx
  802ad8:	89 d8                	mov    %ebx,%eax
  802ada:	89 14 24             	mov    %edx,(%esp)
  802add:	89 f2                	mov    %esi,%edx
  802adf:	d3 e2                	shl    %cl,%edx
  802ae1:	89 f9                	mov    %edi,%ecx
  802ae3:	89 54 24 04          	mov    %edx,0x4(%esp)
  802ae7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802aeb:	d3 e8                	shr    %cl,%eax
  802aed:	89 e9                	mov    %ebp,%ecx
  802aef:	89 c6                	mov    %eax,%esi
  802af1:	d3 e3                	shl    %cl,%ebx
  802af3:	89 f9                	mov    %edi,%ecx
  802af5:	89 d0                	mov    %edx,%eax
  802af7:	d3 e8                	shr    %cl,%eax
  802af9:	89 e9                	mov    %ebp,%ecx
  802afb:	09 d8                	or     %ebx,%eax
  802afd:	89 d3                	mov    %edx,%ebx
  802aff:	89 f2                	mov    %esi,%edx
  802b01:	f7 34 24             	divl   (%esp)
  802b04:	89 d6                	mov    %edx,%esi
  802b06:	d3 e3                	shl    %cl,%ebx
  802b08:	f7 64 24 04          	mull   0x4(%esp)
  802b0c:	39 d6                	cmp    %edx,%esi
  802b0e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802b12:	89 d1                	mov    %edx,%ecx
  802b14:	89 c3                	mov    %eax,%ebx
  802b16:	72 08                	jb     802b20 <__umoddi3+0x110>
  802b18:	75 11                	jne    802b2b <__umoddi3+0x11b>
  802b1a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802b1e:	73 0b                	jae    802b2b <__umoddi3+0x11b>
  802b20:	2b 44 24 04          	sub    0x4(%esp),%eax
  802b24:	1b 14 24             	sbb    (%esp),%edx
  802b27:	89 d1                	mov    %edx,%ecx
  802b29:	89 c3                	mov    %eax,%ebx
  802b2b:	8b 54 24 08          	mov    0x8(%esp),%edx
  802b2f:	29 da                	sub    %ebx,%edx
  802b31:	19 ce                	sbb    %ecx,%esi
  802b33:	89 f9                	mov    %edi,%ecx
  802b35:	89 f0                	mov    %esi,%eax
  802b37:	d3 e0                	shl    %cl,%eax
  802b39:	89 e9                	mov    %ebp,%ecx
  802b3b:	d3 ea                	shr    %cl,%edx
  802b3d:	89 e9                	mov    %ebp,%ecx
  802b3f:	d3 ee                	shr    %cl,%esi
  802b41:	09 d0                	or     %edx,%eax
  802b43:	89 f2                	mov    %esi,%edx
  802b45:	83 c4 1c             	add    $0x1c,%esp
  802b48:	5b                   	pop    %ebx
  802b49:	5e                   	pop    %esi
  802b4a:	5f                   	pop    %edi
  802b4b:	5d                   	pop    %ebp
  802b4c:	c3                   	ret    
  802b4d:	8d 76 00             	lea    0x0(%esi),%esi
  802b50:	29 f9                	sub    %edi,%ecx
  802b52:	19 d6                	sbb    %edx,%esi
  802b54:	89 74 24 04          	mov    %esi,0x4(%esp)
  802b58:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802b5c:	e9 18 ff ff ff       	jmp    802a79 <__umoddi3+0x69>
