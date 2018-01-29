
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
  800039:	ff 35 00 30 80 00    	pushl  0x803000
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
  800081:	68 8c 29 80 00       	push   $0x80298c
  800086:	6a 13                	push   $0x13
  800088:	68 9f 29 80 00       	push   $0x80299f
  80008d:	e8 69 01 00 00       	call   8001fb <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 ec 0e 00 00       	call   800f83 <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 b3 29 80 00       	push   $0x8029b3
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 9f 29 80 00       	push   $0x80299f
  8000aa:	e8 4c 01 00 00       	call   8001fb <_panic>
	if (r == 0) {
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	75 1b                	jne    8000ce <umain+0x7b>
		strcpy(VA, msg);
  8000b3:	83 ec 08             	sub    $0x8,%esp
  8000b6:	ff 35 04 30 80 00    	pushl  0x803004
  8000bc:	68 00 00 00 a0       	push   $0xa0000000
  8000c1:	e8 93 07 00 00       	call   800859 <strcpy>
		exit();
  8000c6:	e8 16 01 00 00       	call   8001e1 <exit>
  8000cb:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	53                   	push   %ebx
  8000d2:	e8 51 22 00 00       	call   802328 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 30 80 00    	pushl  0x803004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 19 08 00 00       	call   800903 <strcmp>
  8000ea:	83 c4 08             	add    $0x8,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	ba 86 29 80 00       	mov    $0x802986,%edx
  8000f4:	b8 80 29 80 00       	mov    $0x802980,%eax
  8000f9:	0f 45 c2             	cmovne %edx,%eax
  8000fc:	50                   	push   %eax
  8000fd:	68 bc 29 80 00       	push   $0x8029bc
  800102:	e8 cd 01 00 00       	call   8002d4 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800107:	6a 00                	push   $0x0
  800109:	68 d7 29 80 00       	push   $0x8029d7
  80010e:	68 dc 29 80 00       	push   $0x8029dc
  800113:	68 db 29 80 00       	push   $0x8029db
  800118:	e8 33 1e 00 00       	call   801f50 <spawnl>
  80011d:	83 c4 20             	add    $0x20,%esp
  800120:	85 c0                	test   %eax,%eax
  800122:	79 12                	jns    800136 <umain+0xe3>
		panic("spawn: %e", r);
  800124:	50                   	push   %eax
  800125:	68 e9 29 80 00       	push   $0x8029e9
  80012a:	6a 21                	push   $0x21
  80012c:	68 9f 29 80 00       	push   $0x80299f
  800131:	e8 c5 00 00 00       	call   8001fb <_panic>
	wait(r);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	e8 e9 21 00 00       	call   802328 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff 35 00 30 80 00    	pushl  0x803000
  800148:	68 00 00 00 a0       	push   $0xa0000000
  80014d:	e8 b1 07 00 00       	call   800903 <strcmp>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba 86 29 80 00       	mov    $0x802986,%edx
  80015c:	b8 80 29 80 00       	mov    $0x802980,%eax
  800161:	0f 45 c2             	cmovne %edx,%eax
  800164:	50                   	push   %eax
  800165:	68 f3 29 80 00       	push   $0x8029f3
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
  80018d:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  800193:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800198:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80019d:	85 db                	test   %ebx,%ebx
  80019f:	7e 07                	jle    8001a8 <libmain+0x30>
		binaryname = argv[0];
  8001a1:	8b 06                	mov    (%esi),%eax
  8001a3:	a3 08 30 80 00       	mov    %eax,0x803008

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

void 
thread_main(/*uintptr_t eip*/)
{
  8001c1:	55                   	push   %ebp
  8001c2:	89 e5                	mov    %esp,%ebp
  8001c4:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  8001c7:	a1 08 40 80 00       	mov    0x804008,%eax
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
  8001e7:	e8 a9 11 00 00       	call   801395 <close_all>
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
  800203:	8b 35 08 30 80 00    	mov    0x803008,%esi
  800209:	e8 10 0a 00 00       	call   800c1e <sys_getenvid>
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	ff 75 0c             	pushl  0xc(%ebp)
  800214:	ff 75 08             	pushl  0x8(%ebp)
  800217:	56                   	push   %esi
  800218:	50                   	push   %eax
  800219:	68 38 2a 80 00       	push   $0x802a38
  80021e:	e8 b1 00 00 00       	call   8002d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800223:	83 c4 18             	add    $0x18,%esp
  800226:	53                   	push   %ebx
  800227:	ff 75 10             	pushl  0x10(%ebp)
  80022a:	e8 54 00 00 00       	call   800283 <vcprintf>
	cprintf("\n");
  80022f:	c7 04 24 94 2f 80 00 	movl   $0x802f94,(%esp)
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
  800337:	e8 b4 23 00 00       	call   8026f0 <__udivdi3>
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
  80037a:	e8 a1 24 00 00       	call   802820 <__umoddi3>
  80037f:	83 c4 14             	add    $0x14,%esp
  800382:	0f be 80 5b 2a 80 00 	movsbl 0x802a5b(%eax),%eax
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
  80047e:	ff 24 85 a0 2b 80 00 	jmp    *0x802ba0(,%eax,4)
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
  800542:	8b 14 85 00 2d 80 00 	mov    0x802d00(,%eax,4),%edx
  800549:	85 d2                	test   %edx,%edx
  80054b:	75 18                	jne    800565 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80054d:	50                   	push   %eax
  80054e:	68 73 2a 80 00       	push   $0x802a73
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
  800566:	68 ad 2e 80 00       	push   $0x802ead
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
  80058a:	b8 6c 2a 80 00       	mov    $0x802a6c,%eax
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
  800c05:	68 5f 2d 80 00       	push   $0x802d5f
  800c0a:	6a 23                	push   $0x23
  800c0c:	68 7c 2d 80 00       	push   $0x802d7c
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
  800c86:	68 5f 2d 80 00       	push   $0x802d5f
  800c8b:	6a 23                	push   $0x23
  800c8d:	68 7c 2d 80 00       	push   $0x802d7c
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
  800cc8:	68 5f 2d 80 00       	push   $0x802d5f
  800ccd:	6a 23                	push   $0x23
  800ccf:	68 7c 2d 80 00       	push   $0x802d7c
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
  800d0a:	68 5f 2d 80 00       	push   $0x802d5f
  800d0f:	6a 23                	push   $0x23
  800d11:	68 7c 2d 80 00       	push   $0x802d7c
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
  800d4c:	68 5f 2d 80 00       	push   $0x802d5f
  800d51:	6a 23                	push   $0x23
  800d53:	68 7c 2d 80 00       	push   $0x802d7c
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
  800d8e:	68 5f 2d 80 00       	push   $0x802d5f
  800d93:	6a 23                	push   $0x23
  800d95:	68 7c 2d 80 00       	push   $0x802d7c
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
  800dd0:	68 5f 2d 80 00       	push   $0x802d5f
  800dd5:	6a 23                	push   $0x23
  800dd7:	68 7c 2d 80 00       	push   $0x802d7c
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
  800e34:	68 5f 2d 80 00       	push   $0x802d5f
  800e39:	6a 23                	push   $0x23
  800e3b:	68 7c 2d 80 00       	push   $0x802d7c
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
  800ed3:	68 8a 2d 80 00       	push   $0x802d8a
  800ed8:	6a 1e                	push   $0x1e
  800eda:	68 9a 2d 80 00       	push   $0x802d9a
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
  800efd:	68 a5 2d 80 00       	push   $0x802da5
  800f02:	6a 2c                	push   $0x2c
  800f04:	68 9a 2d 80 00       	push   $0x802d9a
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
  800f45:	68 a5 2d 80 00       	push   $0x802da5
  800f4a:	6a 33                	push   $0x33
  800f4c:	68 9a 2d 80 00       	push   $0x802d9a
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
  800f6d:	68 a5 2d 80 00       	push   $0x802da5
  800f72:	6a 37                	push   $0x37
  800f74:	68 9a 2d 80 00       	push   $0x802d9a
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
  800f91:	e8 6d 15 00 00       	call   802503 <set_pgfault_handler>
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
  800faa:	68 be 2d 80 00       	push   $0x802dbe
  800faf:	68 84 00 00 00       	push   $0x84
  800fb4:	68 9a 2d 80 00       	push   $0x802d9a
  800fb9:	e8 3d f2 ff ff       	call   8001fb <_panic>
  800fbe:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800fc0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fc4:	75 24                	jne    800fea <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fc6:	e8 53 fc ff ff       	call   800c1e <sys_getenvid>
  800fcb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fd0:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  800fd6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fdb:	a3 04 40 80 00       	mov    %eax,0x804004
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
  801066:	68 cc 2d 80 00       	push   $0x802dcc
  80106b:	6a 54                	push   $0x54
  80106d:	68 9a 2d 80 00       	push   $0x802d9a
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
  8010ab:	68 cc 2d 80 00       	push   $0x802dcc
  8010b0:	6a 5b                	push   $0x5b
  8010b2:	68 9a 2d 80 00       	push   $0x802d9a
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
  8010d9:	68 cc 2d 80 00       	push   $0x802dcc
  8010de:	6a 5f                	push   $0x5f
  8010e0:	68 9a 2d 80 00       	push   $0x802d9a
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
  801103:	68 cc 2d 80 00       	push   $0x802dcc
  801108:	6a 64                	push   $0x64
  80110a:	68 9a 2d 80 00       	push   $0x802d9a
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
  801126:	a1 04 40 80 00       	mov    0x804004,%eax
  80112b:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
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
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
  801163:	56                   	push   %esi
  801164:	53                   	push   %ebx
  801165:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801168:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  80116e:	83 ec 08             	sub    $0x8,%esp
  801171:	53                   	push   %ebx
  801172:	68 e4 2d 80 00       	push   $0x802de4
  801177:	e8 58 f1 ff ff       	call   8002d4 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80117c:	c7 04 24 c1 01 80 00 	movl   $0x8001c1,(%esp)
  801183:	e8 c5 fc ff ff       	call   800e4d <sys_thread_create>
  801188:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80118a:	83 c4 08             	add    $0x8,%esp
  80118d:	53                   	push   %ebx
  80118e:	68 e4 2d 80 00       	push   $0x802de4
  801193:	e8 3c f1 ff ff       	call   8002d4 <cprintf>
	return id;
}
  801198:	89 f0                	mov    %esi,%eax
  80119a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80119d:	5b                   	pop    %ebx
  80119e:	5e                   	pop    %esi
  80119f:	5d                   	pop    %ebp
  8011a0:	c3                   	ret    

008011a1 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8011a1:	55                   	push   %ebp
  8011a2:	89 e5                	mov    %esp,%ebp
  8011a4:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  8011a7:	ff 75 08             	pushl  0x8(%ebp)
  8011aa:	e8 be fc ff ff       	call   800e6d <sys_thread_free>
}
  8011af:	83 c4 10             	add    $0x10,%esp
  8011b2:	c9                   	leave  
  8011b3:	c3                   	ret    

008011b4 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
  8011b7:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  8011ba:	ff 75 08             	pushl  0x8(%ebp)
  8011bd:	e8 cb fc ff ff       	call   800e8d <sys_thread_join>
}
  8011c2:	83 c4 10             	add    $0x10,%esp
  8011c5:	c9                   	leave  
  8011c6:	c3                   	ret    

008011c7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8011cd:	05 00 00 00 30       	add    $0x30000000,%eax
  8011d2:	c1 e8 0c             	shr    $0xc,%eax
}
  8011d5:	5d                   	pop    %ebp
  8011d6:	c3                   	ret    

008011d7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011d7:	55                   	push   %ebp
  8011d8:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011da:	8b 45 08             	mov    0x8(%ebp),%eax
  8011dd:	05 00 00 00 30       	add    $0x30000000,%eax
  8011e2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011e7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011ec:	5d                   	pop    %ebp
  8011ed:	c3                   	ret    

008011ee <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011ee:	55                   	push   %ebp
  8011ef:	89 e5                	mov    %esp,%ebp
  8011f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011f4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011f9:	89 c2                	mov    %eax,%edx
  8011fb:	c1 ea 16             	shr    $0x16,%edx
  8011fe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801205:	f6 c2 01             	test   $0x1,%dl
  801208:	74 11                	je     80121b <fd_alloc+0x2d>
  80120a:	89 c2                	mov    %eax,%edx
  80120c:	c1 ea 0c             	shr    $0xc,%edx
  80120f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801216:	f6 c2 01             	test   $0x1,%dl
  801219:	75 09                	jne    801224 <fd_alloc+0x36>
			*fd_store = fd;
  80121b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80121d:	b8 00 00 00 00       	mov    $0x0,%eax
  801222:	eb 17                	jmp    80123b <fd_alloc+0x4d>
  801224:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801229:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80122e:	75 c9                	jne    8011f9 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801230:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801236:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80123b:	5d                   	pop    %ebp
  80123c:	c3                   	ret    

0080123d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80123d:	55                   	push   %ebp
  80123e:	89 e5                	mov    %esp,%ebp
  801240:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801243:	83 f8 1f             	cmp    $0x1f,%eax
  801246:	77 36                	ja     80127e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801248:	c1 e0 0c             	shl    $0xc,%eax
  80124b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801250:	89 c2                	mov    %eax,%edx
  801252:	c1 ea 16             	shr    $0x16,%edx
  801255:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80125c:	f6 c2 01             	test   $0x1,%dl
  80125f:	74 24                	je     801285 <fd_lookup+0x48>
  801261:	89 c2                	mov    %eax,%edx
  801263:	c1 ea 0c             	shr    $0xc,%edx
  801266:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80126d:	f6 c2 01             	test   $0x1,%dl
  801270:	74 1a                	je     80128c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801272:	8b 55 0c             	mov    0xc(%ebp),%edx
  801275:	89 02                	mov    %eax,(%edx)
	return 0;
  801277:	b8 00 00 00 00       	mov    $0x0,%eax
  80127c:	eb 13                	jmp    801291 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80127e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801283:	eb 0c                	jmp    801291 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801285:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80128a:	eb 05                	jmp    801291 <fd_lookup+0x54>
  80128c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801291:	5d                   	pop    %ebp
  801292:	c3                   	ret    

00801293 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801293:	55                   	push   %ebp
  801294:	89 e5                	mov    %esp,%ebp
  801296:	83 ec 08             	sub    $0x8,%esp
  801299:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80129c:	ba 84 2e 80 00       	mov    $0x802e84,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012a1:	eb 13                	jmp    8012b6 <dev_lookup+0x23>
  8012a3:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012a6:	39 08                	cmp    %ecx,(%eax)
  8012a8:	75 0c                	jne    8012b6 <dev_lookup+0x23>
			*dev = devtab[i];
  8012aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ad:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012af:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b4:	eb 31                	jmp    8012e7 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012b6:	8b 02                	mov    (%edx),%eax
  8012b8:	85 c0                	test   %eax,%eax
  8012ba:	75 e7                	jne    8012a3 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012bc:	a1 04 40 80 00       	mov    0x804004,%eax
  8012c1:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8012c7:	83 ec 04             	sub    $0x4,%esp
  8012ca:	51                   	push   %ecx
  8012cb:	50                   	push   %eax
  8012cc:	68 08 2e 80 00       	push   $0x802e08
  8012d1:	e8 fe ef ff ff       	call   8002d4 <cprintf>
	*dev = 0;
  8012d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012d9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012df:	83 c4 10             	add    $0x10,%esp
  8012e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012e7:	c9                   	leave  
  8012e8:	c3                   	ret    

008012e9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	56                   	push   %esi
  8012ed:	53                   	push   %ebx
  8012ee:	83 ec 10             	sub    $0x10,%esp
  8012f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8012f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012fa:	50                   	push   %eax
  8012fb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801301:	c1 e8 0c             	shr    $0xc,%eax
  801304:	50                   	push   %eax
  801305:	e8 33 ff ff ff       	call   80123d <fd_lookup>
  80130a:	83 c4 08             	add    $0x8,%esp
  80130d:	85 c0                	test   %eax,%eax
  80130f:	78 05                	js     801316 <fd_close+0x2d>
	    || fd != fd2)
  801311:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801314:	74 0c                	je     801322 <fd_close+0x39>
		return (must_exist ? r : 0);
  801316:	84 db                	test   %bl,%bl
  801318:	ba 00 00 00 00       	mov    $0x0,%edx
  80131d:	0f 44 c2             	cmove  %edx,%eax
  801320:	eb 41                	jmp    801363 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801322:	83 ec 08             	sub    $0x8,%esp
  801325:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801328:	50                   	push   %eax
  801329:	ff 36                	pushl  (%esi)
  80132b:	e8 63 ff ff ff       	call   801293 <dev_lookup>
  801330:	89 c3                	mov    %eax,%ebx
  801332:	83 c4 10             	add    $0x10,%esp
  801335:	85 c0                	test   %eax,%eax
  801337:	78 1a                	js     801353 <fd_close+0x6a>
		if (dev->dev_close)
  801339:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80133f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801344:	85 c0                	test   %eax,%eax
  801346:	74 0b                	je     801353 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801348:	83 ec 0c             	sub    $0xc,%esp
  80134b:	56                   	push   %esi
  80134c:	ff d0                	call   *%eax
  80134e:	89 c3                	mov    %eax,%ebx
  801350:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801353:	83 ec 08             	sub    $0x8,%esp
  801356:	56                   	push   %esi
  801357:	6a 00                	push   $0x0
  801359:	e8 83 f9 ff ff       	call   800ce1 <sys_page_unmap>
	return r;
  80135e:	83 c4 10             	add    $0x10,%esp
  801361:	89 d8                	mov    %ebx,%eax
}
  801363:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801366:	5b                   	pop    %ebx
  801367:	5e                   	pop    %esi
  801368:	5d                   	pop    %ebp
  801369:	c3                   	ret    

0080136a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80136a:	55                   	push   %ebp
  80136b:	89 e5                	mov    %esp,%ebp
  80136d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801370:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801373:	50                   	push   %eax
  801374:	ff 75 08             	pushl  0x8(%ebp)
  801377:	e8 c1 fe ff ff       	call   80123d <fd_lookup>
  80137c:	83 c4 08             	add    $0x8,%esp
  80137f:	85 c0                	test   %eax,%eax
  801381:	78 10                	js     801393 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801383:	83 ec 08             	sub    $0x8,%esp
  801386:	6a 01                	push   $0x1
  801388:	ff 75 f4             	pushl  -0xc(%ebp)
  80138b:	e8 59 ff ff ff       	call   8012e9 <fd_close>
  801390:	83 c4 10             	add    $0x10,%esp
}
  801393:	c9                   	leave  
  801394:	c3                   	ret    

00801395 <close_all>:

void
close_all(void)
{
  801395:	55                   	push   %ebp
  801396:	89 e5                	mov    %esp,%ebp
  801398:	53                   	push   %ebx
  801399:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80139c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013a1:	83 ec 0c             	sub    $0xc,%esp
  8013a4:	53                   	push   %ebx
  8013a5:	e8 c0 ff ff ff       	call   80136a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013aa:	83 c3 01             	add    $0x1,%ebx
  8013ad:	83 c4 10             	add    $0x10,%esp
  8013b0:	83 fb 20             	cmp    $0x20,%ebx
  8013b3:	75 ec                	jne    8013a1 <close_all+0xc>
		close(i);
}
  8013b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013b8:	c9                   	leave  
  8013b9:	c3                   	ret    

008013ba <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013ba:	55                   	push   %ebp
  8013bb:	89 e5                	mov    %esp,%ebp
  8013bd:	57                   	push   %edi
  8013be:	56                   	push   %esi
  8013bf:	53                   	push   %ebx
  8013c0:	83 ec 2c             	sub    $0x2c,%esp
  8013c3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013c6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013c9:	50                   	push   %eax
  8013ca:	ff 75 08             	pushl  0x8(%ebp)
  8013cd:	e8 6b fe ff ff       	call   80123d <fd_lookup>
  8013d2:	83 c4 08             	add    $0x8,%esp
  8013d5:	85 c0                	test   %eax,%eax
  8013d7:	0f 88 c1 00 00 00    	js     80149e <dup+0xe4>
		return r;
	close(newfdnum);
  8013dd:	83 ec 0c             	sub    $0xc,%esp
  8013e0:	56                   	push   %esi
  8013e1:	e8 84 ff ff ff       	call   80136a <close>

	newfd = INDEX2FD(newfdnum);
  8013e6:	89 f3                	mov    %esi,%ebx
  8013e8:	c1 e3 0c             	shl    $0xc,%ebx
  8013eb:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013f1:	83 c4 04             	add    $0x4,%esp
  8013f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013f7:	e8 db fd ff ff       	call   8011d7 <fd2data>
  8013fc:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013fe:	89 1c 24             	mov    %ebx,(%esp)
  801401:	e8 d1 fd ff ff       	call   8011d7 <fd2data>
  801406:	83 c4 10             	add    $0x10,%esp
  801409:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80140c:	89 f8                	mov    %edi,%eax
  80140e:	c1 e8 16             	shr    $0x16,%eax
  801411:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801418:	a8 01                	test   $0x1,%al
  80141a:	74 37                	je     801453 <dup+0x99>
  80141c:	89 f8                	mov    %edi,%eax
  80141e:	c1 e8 0c             	shr    $0xc,%eax
  801421:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801428:	f6 c2 01             	test   $0x1,%dl
  80142b:	74 26                	je     801453 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80142d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801434:	83 ec 0c             	sub    $0xc,%esp
  801437:	25 07 0e 00 00       	and    $0xe07,%eax
  80143c:	50                   	push   %eax
  80143d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801440:	6a 00                	push   $0x0
  801442:	57                   	push   %edi
  801443:	6a 00                	push   $0x0
  801445:	e8 55 f8 ff ff       	call   800c9f <sys_page_map>
  80144a:	89 c7                	mov    %eax,%edi
  80144c:	83 c4 20             	add    $0x20,%esp
  80144f:	85 c0                	test   %eax,%eax
  801451:	78 2e                	js     801481 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801453:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801456:	89 d0                	mov    %edx,%eax
  801458:	c1 e8 0c             	shr    $0xc,%eax
  80145b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801462:	83 ec 0c             	sub    $0xc,%esp
  801465:	25 07 0e 00 00       	and    $0xe07,%eax
  80146a:	50                   	push   %eax
  80146b:	53                   	push   %ebx
  80146c:	6a 00                	push   $0x0
  80146e:	52                   	push   %edx
  80146f:	6a 00                	push   $0x0
  801471:	e8 29 f8 ff ff       	call   800c9f <sys_page_map>
  801476:	89 c7                	mov    %eax,%edi
  801478:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80147b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80147d:	85 ff                	test   %edi,%edi
  80147f:	79 1d                	jns    80149e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801481:	83 ec 08             	sub    $0x8,%esp
  801484:	53                   	push   %ebx
  801485:	6a 00                	push   $0x0
  801487:	e8 55 f8 ff ff       	call   800ce1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80148c:	83 c4 08             	add    $0x8,%esp
  80148f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801492:	6a 00                	push   $0x0
  801494:	e8 48 f8 ff ff       	call   800ce1 <sys_page_unmap>
	return r;
  801499:	83 c4 10             	add    $0x10,%esp
  80149c:	89 f8                	mov    %edi,%eax
}
  80149e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014a1:	5b                   	pop    %ebx
  8014a2:	5e                   	pop    %esi
  8014a3:	5f                   	pop    %edi
  8014a4:	5d                   	pop    %ebp
  8014a5:	c3                   	ret    

008014a6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014a6:	55                   	push   %ebp
  8014a7:	89 e5                	mov    %esp,%ebp
  8014a9:	53                   	push   %ebx
  8014aa:	83 ec 14             	sub    $0x14,%esp
  8014ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014b3:	50                   	push   %eax
  8014b4:	53                   	push   %ebx
  8014b5:	e8 83 fd ff ff       	call   80123d <fd_lookup>
  8014ba:	83 c4 08             	add    $0x8,%esp
  8014bd:	89 c2                	mov    %eax,%edx
  8014bf:	85 c0                	test   %eax,%eax
  8014c1:	78 70                	js     801533 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014c3:	83 ec 08             	sub    $0x8,%esp
  8014c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c9:	50                   	push   %eax
  8014ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014cd:	ff 30                	pushl  (%eax)
  8014cf:	e8 bf fd ff ff       	call   801293 <dev_lookup>
  8014d4:	83 c4 10             	add    $0x10,%esp
  8014d7:	85 c0                	test   %eax,%eax
  8014d9:	78 4f                	js     80152a <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014db:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014de:	8b 42 08             	mov    0x8(%edx),%eax
  8014e1:	83 e0 03             	and    $0x3,%eax
  8014e4:	83 f8 01             	cmp    $0x1,%eax
  8014e7:	75 24                	jne    80150d <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014e9:	a1 04 40 80 00       	mov    0x804004,%eax
  8014ee:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8014f4:	83 ec 04             	sub    $0x4,%esp
  8014f7:	53                   	push   %ebx
  8014f8:	50                   	push   %eax
  8014f9:	68 49 2e 80 00       	push   $0x802e49
  8014fe:	e8 d1 ed ff ff       	call   8002d4 <cprintf>
		return -E_INVAL;
  801503:	83 c4 10             	add    $0x10,%esp
  801506:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80150b:	eb 26                	jmp    801533 <read+0x8d>
	}
	if (!dev->dev_read)
  80150d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801510:	8b 40 08             	mov    0x8(%eax),%eax
  801513:	85 c0                	test   %eax,%eax
  801515:	74 17                	je     80152e <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801517:	83 ec 04             	sub    $0x4,%esp
  80151a:	ff 75 10             	pushl  0x10(%ebp)
  80151d:	ff 75 0c             	pushl  0xc(%ebp)
  801520:	52                   	push   %edx
  801521:	ff d0                	call   *%eax
  801523:	89 c2                	mov    %eax,%edx
  801525:	83 c4 10             	add    $0x10,%esp
  801528:	eb 09                	jmp    801533 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152a:	89 c2                	mov    %eax,%edx
  80152c:	eb 05                	jmp    801533 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80152e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801533:	89 d0                	mov    %edx,%eax
  801535:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801538:	c9                   	leave  
  801539:	c3                   	ret    

0080153a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80153a:	55                   	push   %ebp
  80153b:	89 e5                	mov    %esp,%ebp
  80153d:	57                   	push   %edi
  80153e:	56                   	push   %esi
  80153f:	53                   	push   %ebx
  801540:	83 ec 0c             	sub    $0xc,%esp
  801543:	8b 7d 08             	mov    0x8(%ebp),%edi
  801546:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801549:	bb 00 00 00 00       	mov    $0x0,%ebx
  80154e:	eb 21                	jmp    801571 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801550:	83 ec 04             	sub    $0x4,%esp
  801553:	89 f0                	mov    %esi,%eax
  801555:	29 d8                	sub    %ebx,%eax
  801557:	50                   	push   %eax
  801558:	89 d8                	mov    %ebx,%eax
  80155a:	03 45 0c             	add    0xc(%ebp),%eax
  80155d:	50                   	push   %eax
  80155e:	57                   	push   %edi
  80155f:	e8 42 ff ff ff       	call   8014a6 <read>
		if (m < 0)
  801564:	83 c4 10             	add    $0x10,%esp
  801567:	85 c0                	test   %eax,%eax
  801569:	78 10                	js     80157b <readn+0x41>
			return m;
		if (m == 0)
  80156b:	85 c0                	test   %eax,%eax
  80156d:	74 0a                	je     801579 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80156f:	01 c3                	add    %eax,%ebx
  801571:	39 f3                	cmp    %esi,%ebx
  801573:	72 db                	jb     801550 <readn+0x16>
  801575:	89 d8                	mov    %ebx,%eax
  801577:	eb 02                	jmp    80157b <readn+0x41>
  801579:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80157b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80157e:	5b                   	pop    %ebx
  80157f:	5e                   	pop    %esi
  801580:	5f                   	pop    %edi
  801581:	5d                   	pop    %ebp
  801582:	c3                   	ret    

00801583 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801583:	55                   	push   %ebp
  801584:	89 e5                	mov    %esp,%ebp
  801586:	53                   	push   %ebx
  801587:	83 ec 14             	sub    $0x14,%esp
  80158a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80158d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801590:	50                   	push   %eax
  801591:	53                   	push   %ebx
  801592:	e8 a6 fc ff ff       	call   80123d <fd_lookup>
  801597:	83 c4 08             	add    $0x8,%esp
  80159a:	89 c2                	mov    %eax,%edx
  80159c:	85 c0                	test   %eax,%eax
  80159e:	78 6b                	js     80160b <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a0:	83 ec 08             	sub    $0x8,%esp
  8015a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a6:	50                   	push   %eax
  8015a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015aa:	ff 30                	pushl  (%eax)
  8015ac:	e8 e2 fc ff ff       	call   801293 <dev_lookup>
  8015b1:	83 c4 10             	add    $0x10,%esp
  8015b4:	85 c0                	test   %eax,%eax
  8015b6:	78 4a                	js     801602 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015bb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015bf:	75 24                	jne    8015e5 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015c1:	a1 04 40 80 00       	mov    0x804004,%eax
  8015c6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8015cc:	83 ec 04             	sub    $0x4,%esp
  8015cf:	53                   	push   %ebx
  8015d0:	50                   	push   %eax
  8015d1:	68 65 2e 80 00       	push   $0x802e65
  8015d6:	e8 f9 ec ff ff       	call   8002d4 <cprintf>
		return -E_INVAL;
  8015db:	83 c4 10             	add    $0x10,%esp
  8015de:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015e3:	eb 26                	jmp    80160b <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015e8:	8b 52 0c             	mov    0xc(%edx),%edx
  8015eb:	85 d2                	test   %edx,%edx
  8015ed:	74 17                	je     801606 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015ef:	83 ec 04             	sub    $0x4,%esp
  8015f2:	ff 75 10             	pushl  0x10(%ebp)
  8015f5:	ff 75 0c             	pushl  0xc(%ebp)
  8015f8:	50                   	push   %eax
  8015f9:	ff d2                	call   *%edx
  8015fb:	89 c2                	mov    %eax,%edx
  8015fd:	83 c4 10             	add    $0x10,%esp
  801600:	eb 09                	jmp    80160b <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801602:	89 c2                	mov    %eax,%edx
  801604:	eb 05                	jmp    80160b <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801606:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80160b:	89 d0                	mov    %edx,%eax
  80160d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801610:	c9                   	leave  
  801611:	c3                   	ret    

00801612 <seek>:

int
seek(int fdnum, off_t offset)
{
  801612:	55                   	push   %ebp
  801613:	89 e5                	mov    %esp,%ebp
  801615:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801618:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80161b:	50                   	push   %eax
  80161c:	ff 75 08             	pushl  0x8(%ebp)
  80161f:	e8 19 fc ff ff       	call   80123d <fd_lookup>
  801624:	83 c4 08             	add    $0x8,%esp
  801627:	85 c0                	test   %eax,%eax
  801629:	78 0e                	js     801639 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80162b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80162e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801631:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801634:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801639:	c9                   	leave  
  80163a:	c3                   	ret    

0080163b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80163b:	55                   	push   %ebp
  80163c:	89 e5                	mov    %esp,%ebp
  80163e:	53                   	push   %ebx
  80163f:	83 ec 14             	sub    $0x14,%esp
  801642:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801645:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801648:	50                   	push   %eax
  801649:	53                   	push   %ebx
  80164a:	e8 ee fb ff ff       	call   80123d <fd_lookup>
  80164f:	83 c4 08             	add    $0x8,%esp
  801652:	89 c2                	mov    %eax,%edx
  801654:	85 c0                	test   %eax,%eax
  801656:	78 68                	js     8016c0 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801658:	83 ec 08             	sub    $0x8,%esp
  80165b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165e:	50                   	push   %eax
  80165f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801662:	ff 30                	pushl  (%eax)
  801664:	e8 2a fc ff ff       	call   801293 <dev_lookup>
  801669:	83 c4 10             	add    $0x10,%esp
  80166c:	85 c0                	test   %eax,%eax
  80166e:	78 47                	js     8016b7 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801670:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801673:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801677:	75 24                	jne    80169d <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801679:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80167e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801684:	83 ec 04             	sub    $0x4,%esp
  801687:	53                   	push   %ebx
  801688:	50                   	push   %eax
  801689:	68 28 2e 80 00       	push   $0x802e28
  80168e:	e8 41 ec ff ff       	call   8002d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801693:	83 c4 10             	add    $0x10,%esp
  801696:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80169b:	eb 23                	jmp    8016c0 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  80169d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a0:	8b 52 18             	mov    0x18(%edx),%edx
  8016a3:	85 d2                	test   %edx,%edx
  8016a5:	74 14                	je     8016bb <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016a7:	83 ec 08             	sub    $0x8,%esp
  8016aa:	ff 75 0c             	pushl  0xc(%ebp)
  8016ad:	50                   	push   %eax
  8016ae:	ff d2                	call   *%edx
  8016b0:	89 c2                	mov    %eax,%edx
  8016b2:	83 c4 10             	add    $0x10,%esp
  8016b5:	eb 09                	jmp    8016c0 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b7:	89 c2                	mov    %eax,%edx
  8016b9:	eb 05                	jmp    8016c0 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016bb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016c0:	89 d0                	mov    %edx,%eax
  8016c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c5:	c9                   	leave  
  8016c6:	c3                   	ret    

008016c7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
  8016ca:	53                   	push   %ebx
  8016cb:	83 ec 14             	sub    $0x14,%esp
  8016ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d4:	50                   	push   %eax
  8016d5:	ff 75 08             	pushl  0x8(%ebp)
  8016d8:	e8 60 fb ff ff       	call   80123d <fd_lookup>
  8016dd:	83 c4 08             	add    $0x8,%esp
  8016e0:	89 c2                	mov    %eax,%edx
  8016e2:	85 c0                	test   %eax,%eax
  8016e4:	78 58                	js     80173e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e6:	83 ec 08             	sub    $0x8,%esp
  8016e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ec:	50                   	push   %eax
  8016ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f0:	ff 30                	pushl  (%eax)
  8016f2:	e8 9c fb ff ff       	call   801293 <dev_lookup>
  8016f7:	83 c4 10             	add    $0x10,%esp
  8016fa:	85 c0                	test   %eax,%eax
  8016fc:	78 37                	js     801735 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801701:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801705:	74 32                	je     801739 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801707:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80170a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801711:	00 00 00 
	stat->st_isdir = 0;
  801714:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80171b:	00 00 00 
	stat->st_dev = dev;
  80171e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801724:	83 ec 08             	sub    $0x8,%esp
  801727:	53                   	push   %ebx
  801728:	ff 75 f0             	pushl  -0x10(%ebp)
  80172b:	ff 50 14             	call   *0x14(%eax)
  80172e:	89 c2                	mov    %eax,%edx
  801730:	83 c4 10             	add    $0x10,%esp
  801733:	eb 09                	jmp    80173e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801735:	89 c2                	mov    %eax,%edx
  801737:	eb 05                	jmp    80173e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801739:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80173e:	89 d0                	mov    %edx,%eax
  801740:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801743:	c9                   	leave  
  801744:	c3                   	ret    

00801745 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	56                   	push   %esi
  801749:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80174a:	83 ec 08             	sub    $0x8,%esp
  80174d:	6a 00                	push   $0x0
  80174f:	ff 75 08             	pushl  0x8(%ebp)
  801752:	e8 e3 01 00 00       	call   80193a <open>
  801757:	89 c3                	mov    %eax,%ebx
  801759:	83 c4 10             	add    $0x10,%esp
  80175c:	85 c0                	test   %eax,%eax
  80175e:	78 1b                	js     80177b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801760:	83 ec 08             	sub    $0x8,%esp
  801763:	ff 75 0c             	pushl  0xc(%ebp)
  801766:	50                   	push   %eax
  801767:	e8 5b ff ff ff       	call   8016c7 <fstat>
  80176c:	89 c6                	mov    %eax,%esi
	close(fd);
  80176e:	89 1c 24             	mov    %ebx,(%esp)
  801771:	e8 f4 fb ff ff       	call   80136a <close>
	return r;
  801776:	83 c4 10             	add    $0x10,%esp
  801779:	89 f0                	mov    %esi,%eax
}
  80177b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80177e:	5b                   	pop    %ebx
  80177f:	5e                   	pop    %esi
  801780:	5d                   	pop    %ebp
  801781:	c3                   	ret    

00801782 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801782:	55                   	push   %ebp
  801783:	89 e5                	mov    %esp,%ebp
  801785:	56                   	push   %esi
  801786:	53                   	push   %ebx
  801787:	89 c6                	mov    %eax,%esi
  801789:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80178b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801792:	75 12                	jne    8017a6 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801794:	83 ec 0c             	sub    $0xc,%esp
  801797:	6a 01                	push   $0x1
  801799:	e8 d1 0e 00 00       	call   80266f <ipc_find_env>
  80179e:	a3 00 40 80 00       	mov    %eax,0x804000
  8017a3:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017a6:	6a 07                	push   $0x7
  8017a8:	68 00 50 80 00       	push   $0x805000
  8017ad:	56                   	push   %esi
  8017ae:	ff 35 00 40 80 00    	pushl  0x804000
  8017b4:	e8 54 0e 00 00       	call   80260d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017b9:	83 c4 0c             	add    $0xc,%esp
  8017bc:	6a 00                	push   $0x0
  8017be:	53                   	push   %ebx
  8017bf:	6a 00                	push   $0x0
  8017c1:	e8 cc 0d 00 00       	call   802592 <ipc_recv>
}
  8017c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c9:	5b                   	pop    %ebx
  8017ca:	5e                   	pop    %esi
  8017cb:	5d                   	pop    %ebp
  8017cc:	c3                   	ret    

008017cd <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017cd:	55                   	push   %ebp
  8017ce:	89 e5                	mov    %esp,%ebp
  8017d0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d6:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e1:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017eb:	b8 02 00 00 00       	mov    $0x2,%eax
  8017f0:	e8 8d ff ff ff       	call   801782 <fsipc>
}
  8017f5:	c9                   	leave  
  8017f6:	c3                   	ret    

008017f7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017f7:	55                   	push   %ebp
  8017f8:	89 e5                	mov    %esp,%ebp
  8017fa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801800:	8b 40 0c             	mov    0xc(%eax),%eax
  801803:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801808:	ba 00 00 00 00       	mov    $0x0,%edx
  80180d:	b8 06 00 00 00       	mov    $0x6,%eax
  801812:	e8 6b ff ff ff       	call   801782 <fsipc>
}
  801817:	c9                   	leave  
  801818:	c3                   	ret    

00801819 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801819:	55                   	push   %ebp
  80181a:	89 e5                	mov    %esp,%ebp
  80181c:	53                   	push   %ebx
  80181d:	83 ec 04             	sub    $0x4,%esp
  801820:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801823:	8b 45 08             	mov    0x8(%ebp),%eax
  801826:	8b 40 0c             	mov    0xc(%eax),%eax
  801829:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80182e:	ba 00 00 00 00       	mov    $0x0,%edx
  801833:	b8 05 00 00 00       	mov    $0x5,%eax
  801838:	e8 45 ff ff ff       	call   801782 <fsipc>
  80183d:	85 c0                	test   %eax,%eax
  80183f:	78 2c                	js     80186d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801841:	83 ec 08             	sub    $0x8,%esp
  801844:	68 00 50 80 00       	push   $0x805000
  801849:	53                   	push   %ebx
  80184a:	e8 0a f0 ff ff       	call   800859 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80184f:	a1 80 50 80 00       	mov    0x805080,%eax
  801854:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80185a:	a1 84 50 80 00       	mov    0x805084,%eax
  80185f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801865:	83 c4 10             	add    $0x10,%esp
  801868:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80186d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801870:	c9                   	leave  
  801871:	c3                   	ret    

00801872 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	83 ec 0c             	sub    $0xc,%esp
  801878:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80187b:	8b 55 08             	mov    0x8(%ebp),%edx
  80187e:	8b 52 0c             	mov    0xc(%edx),%edx
  801881:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801887:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80188c:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801891:	0f 47 c2             	cmova  %edx,%eax
  801894:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801899:	50                   	push   %eax
  80189a:	ff 75 0c             	pushl  0xc(%ebp)
  80189d:	68 08 50 80 00       	push   $0x805008
  8018a2:	e8 44 f1 ff ff       	call   8009eb <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8018a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ac:	b8 04 00 00 00       	mov    $0x4,%eax
  8018b1:	e8 cc fe ff ff       	call   801782 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8018b6:	c9                   	leave  
  8018b7:	c3                   	ret    

008018b8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018b8:	55                   	push   %ebp
  8018b9:	89 e5                	mov    %esp,%ebp
  8018bb:	56                   	push   %esi
  8018bc:	53                   	push   %ebx
  8018bd:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c3:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018cb:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d6:	b8 03 00 00 00       	mov    $0x3,%eax
  8018db:	e8 a2 fe ff ff       	call   801782 <fsipc>
  8018e0:	89 c3                	mov    %eax,%ebx
  8018e2:	85 c0                	test   %eax,%eax
  8018e4:	78 4b                	js     801931 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018e6:	39 c6                	cmp    %eax,%esi
  8018e8:	73 16                	jae    801900 <devfile_read+0x48>
  8018ea:	68 94 2e 80 00       	push   $0x802e94
  8018ef:	68 9b 2e 80 00       	push   $0x802e9b
  8018f4:	6a 7c                	push   $0x7c
  8018f6:	68 b0 2e 80 00       	push   $0x802eb0
  8018fb:	e8 fb e8 ff ff       	call   8001fb <_panic>
	assert(r <= PGSIZE);
  801900:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801905:	7e 16                	jle    80191d <devfile_read+0x65>
  801907:	68 bb 2e 80 00       	push   $0x802ebb
  80190c:	68 9b 2e 80 00       	push   $0x802e9b
  801911:	6a 7d                	push   $0x7d
  801913:	68 b0 2e 80 00       	push   $0x802eb0
  801918:	e8 de e8 ff ff       	call   8001fb <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80191d:	83 ec 04             	sub    $0x4,%esp
  801920:	50                   	push   %eax
  801921:	68 00 50 80 00       	push   $0x805000
  801926:	ff 75 0c             	pushl  0xc(%ebp)
  801929:	e8 bd f0 ff ff       	call   8009eb <memmove>
	return r;
  80192e:	83 c4 10             	add    $0x10,%esp
}
  801931:	89 d8                	mov    %ebx,%eax
  801933:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801936:	5b                   	pop    %ebx
  801937:	5e                   	pop    %esi
  801938:	5d                   	pop    %ebp
  801939:	c3                   	ret    

0080193a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80193a:	55                   	push   %ebp
  80193b:	89 e5                	mov    %esp,%ebp
  80193d:	53                   	push   %ebx
  80193e:	83 ec 20             	sub    $0x20,%esp
  801941:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801944:	53                   	push   %ebx
  801945:	e8 d6 ee ff ff       	call   800820 <strlen>
  80194a:	83 c4 10             	add    $0x10,%esp
  80194d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801952:	7f 67                	jg     8019bb <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801954:	83 ec 0c             	sub    $0xc,%esp
  801957:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80195a:	50                   	push   %eax
  80195b:	e8 8e f8 ff ff       	call   8011ee <fd_alloc>
  801960:	83 c4 10             	add    $0x10,%esp
		return r;
  801963:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801965:	85 c0                	test   %eax,%eax
  801967:	78 57                	js     8019c0 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801969:	83 ec 08             	sub    $0x8,%esp
  80196c:	53                   	push   %ebx
  80196d:	68 00 50 80 00       	push   $0x805000
  801972:	e8 e2 ee ff ff       	call   800859 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801977:	8b 45 0c             	mov    0xc(%ebp),%eax
  80197a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80197f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801982:	b8 01 00 00 00       	mov    $0x1,%eax
  801987:	e8 f6 fd ff ff       	call   801782 <fsipc>
  80198c:	89 c3                	mov    %eax,%ebx
  80198e:	83 c4 10             	add    $0x10,%esp
  801991:	85 c0                	test   %eax,%eax
  801993:	79 14                	jns    8019a9 <open+0x6f>
		fd_close(fd, 0);
  801995:	83 ec 08             	sub    $0x8,%esp
  801998:	6a 00                	push   $0x0
  80199a:	ff 75 f4             	pushl  -0xc(%ebp)
  80199d:	e8 47 f9 ff ff       	call   8012e9 <fd_close>
		return r;
  8019a2:	83 c4 10             	add    $0x10,%esp
  8019a5:	89 da                	mov    %ebx,%edx
  8019a7:	eb 17                	jmp    8019c0 <open+0x86>
	}

	return fd2num(fd);
  8019a9:	83 ec 0c             	sub    $0xc,%esp
  8019ac:	ff 75 f4             	pushl  -0xc(%ebp)
  8019af:	e8 13 f8 ff ff       	call   8011c7 <fd2num>
  8019b4:	89 c2                	mov    %eax,%edx
  8019b6:	83 c4 10             	add    $0x10,%esp
  8019b9:	eb 05                	jmp    8019c0 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019bb:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019c0:	89 d0                	mov    %edx,%eax
  8019c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c5:	c9                   	leave  
  8019c6:	c3                   	ret    

008019c7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019c7:	55                   	push   %ebp
  8019c8:	89 e5                	mov    %esp,%ebp
  8019ca:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d2:	b8 08 00 00 00       	mov    $0x8,%eax
  8019d7:	e8 a6 fd ff ff       	call   801782 <fsipc>
}
  8019dc:	c9                   	leave  
  8019dd:	c3                   	ret    

008019de <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	57                   	push   %edi
  8019e2:	56                   	push   %esi
  8019e3:	53                   	push   %ebx
  8019e4:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8019ea:	6a 00                	push   $0x0
  8019ec:	ff 75 08             	pushl  0x8(%ebp)
  8019ef:	e8 46 ff ff ff       	call   80193a <open>
  8019f4:	89 c7                	mov    %eax,%edi
  8019f6:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8019fc:	83 c4 10             	add    $0x10,%esp
  8019ff:	85 c0                	test   %eax,%eax
  801a01:	0f 88 8c 04 00 00    	js     801e93 <spawn+0x4b5>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801a07:	83 ec 04             	sub    $0x4,%esp
  801a0a:	68 00 02 00 00       	push   $0x200
  801a0f:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801a15:	50                   	push   %eax
  801a16:	57                   	push   %edi
  801a17:	e8 1e fb ff ff       	call   80153a <readn>
  801a1c:	83 c4 10             	add    $0x10,%esp
  801a1f:	3d 00 02 00 00       	cmp    $0x200,%eax
  801a24:	75 0c                	jne    801a32 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801a26:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801a2d:	45 4c 46 
  801a30:	74 33                	je     801a65 <spawn+0x87>
		close(fd);
  801a32:	83 ec 0c             	sub    $0xc,%esp
  801a35:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a3b:	e8 2a f9 ff ff       	call   80136a <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801a40:	83 c4 0c             	add    $0xc,%esp
  801a43:	68 7f 45 4c 46       	push   $0x464c457f
  801a48:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801a4e:	68 c7 2e 80 00       	push   $0x802ec7
  801a53:	e8 7c e8 ff ff       	call   8002d4 <cprintf>
		return -E_NOT_EXEC;
  801a58:	83 c4 10             	add    $0x10,%esp
  801a5b:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801a60:	e9 e1 04 00 00       	jmp    801f46 <spawn+0x568>
  801a65:	b8 07 00 00 00       	mov    $0x7,%eax
  801a6a:	cd 30                	int    $0x30
  801a6c:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801a72:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801a78:	85 c0                	test   %eax,%eax
  801a7a:	0f 88 1e 04 00 00    	js     801e9e <spawn+0x4c0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801a80:	89 c6                	mov    %eax,%esi
  801a82:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801a88:	69 f6 d8 00 00 00    	imul   $0xd8,%esi,%esi
  801a8e:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801a94:	81 c6 59 00 c0 ee    	add    $0xeec00059,%esi
  801a9a:	b9 11 00 00 00       	mov    $0x11,%ecx
  801a9f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801aa1:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801aa7:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801aad:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801ab2:	be 00 00 00 00       	mov    $0x0,%esi
  801ab7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801aba:	eb 13                	jmp    801acf <spawn+0xf1>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801abc:	83 ec 0c             	sub    $0xc,%esp
  801abf:	50                   	push   %eax
  801ac0:	e8 5b ed ff ff       	call   800820 <strlen>
  801ac5:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801ac9:	83 c3 01             	add    $0x1,%ebx
  801acc:	83 c4 10             	add    $0x10,%esp
  801acf:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801ad6:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801ad9:	85 c0                	test   %eax,%eax
  801adb:	75 df                	jne    801abc <spawn+0xde>
  801add:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801ae3:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801ae9:	bf 00 10 40 00       	mov    $0x401000,%edi
  801aee:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801af0:	89 fa                	mov    %edi,%edx
  801af2:	83 e2 fc             	and    $0xfffffffc,%edx
  801af5:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801afc:	29 c2                	sub    %eax,%edx
  801afe:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801b04:	8d 42 f8             	lea    -0x8(%edx),%eax
  801b07:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801b0c:	0f 86 a2 03 00 00    	jbe    801eb4 <spawn+0x4d6>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b12:	83 ec 04             	sub    $0x4,%esp
  801b15:	6a 07                	push   $0x7
  801b17:	68 00 00 40 00       	push   $0x400000
  801b1c:	6a 00                	push   $0x0
  801b1e:	e8 39 f1 ff ff       	call   800c5c <sys_page_alloc>
  801b23:	83 c4 10             	add    $0x10,%esp
  801b26:	85 c0                	test   %eax,%eax
  801b28:	0f 88 90 03 00 00    	js     801ebe <spawn+0x4e0>
  801b2e:	be 00 00 00 00       	mov    $0x0,%esi
  801b33:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801b39:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b3c:	eb 30                	jmp    801b6e <spawn+0x190>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801b3e:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801b44:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801b4a:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801b4d:	83 ec 08             	sub    $0x8,%esp
  801b50:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801b53:	57                   	push   %edi
  801b54:	e8 00 ed ff ff       	call   800859 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801b59:	83 c4 04             	add    $0x4,%esp
  801b5c:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801b5f:	e8 bc ec ff ff       	call   800820 <strlen>
  801b64:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801b68:	83 c6 01             	add    $0x1,%esi
  801b6b:	83 c4 10             	add    $0x10,%esp
  801b6e:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801b74:	7f c8                	jg     801b3e <spawn+0x160>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801b76:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801b7c:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801b82:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801b89:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801b8f:	74 19                	je     801baa <spawn+0x1cc>
  801b91:	68 54 2f 80 00       	push   $0x802f54
  801b96:	68 9b 2e 80 00       	push   $0x802e9b
  801b9b:	68 f2 00 00 00       	push   $0xf2
  801ba0:	68 e1 2e 80 00       	push   $0x802ee1
  801ba5:	e8 51 e6 ff ff       	call   8001fb <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801baa:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801bb0:	89 f8                	mov    %edi,%eax
  801bb2:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801bb7:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801bba:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801bc0:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801bc3:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801bc9:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801bcf:	83 ec 0c             	sub    $0xc,%esp
  801bd2:	6a 07                	push   $0x7
  801bd4:	68 00 d0 bf ee       	push   $0xeebfd000
  801bd9:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801bdf:	68 00 00 40 00       	push   $0x400000
  801be4:	6a 00                	push   $0x0
  801be6:	e8 b4 f0 ff ff       	call   800c9f <sys_page_map>
  801beb:	89 c3                	mov    %eax,%ebx
  801bed:	83 c4 20             	add    $0x20,%esp
  801bf0:	85 c0                	test   %eax,%eax
  801bf2:	0f 88 3c 03 00 00    	js     801f34 <spawn+0x556>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801bf8:	83 ec 08             	sub    $0x8,%esp
  801bfb:	68 00 00 40 00       	push   $0x400000
  801c00:	6a 00                	push   $0x0
  801c02:	e8 da f0 ff ff       	call   800ce1 <sys_page_unmap>
  801c07:	89 c3                	mov    %eax,%ebx
  801c09:	83 c4 10             	add    $0x10,%esp
  801c0c:	85 c0                	test   %eax,%eax
  801c0e:	0f 88 20 03 00 00    	js     801f34 <spawn+0x556>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801c14:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801c1a:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801c21:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c27:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801c2e:	00 00 00 
  801c31:	e9 88 01 00 00       	jmp    801dbe <spawn+0x3e0>
		if (ph->p_type != ELF_PROG_LOAD)
  801c36:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801c3c:	83 38 01             	cmpl   $0x1,(%eax)
  801c3f:	0f 85 6b 01 00 00    	jne    801db0 <spawn+0x3d2>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801c45:	89 c2                	mov    %eax,%edx
  801c47:	8b 40 18             	mov    0x18(%eax),%eax
  801c4a:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801c50:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801c53:	83 f8 01             	cmp    $0x1,%eax
  801c56:	19 c0                	sbb    %eax,%eax
  801c58:	83 e0 fe             	and    $0xfffffffe,%eax
  801c5b:	83 c0 07             	add    $0x7,%eax
  801c5e:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801c64:	89 d0                	mov    %edx,%eax
  801c66:	8b 7a 04             	mov    0x4(%edx),%edi
  801c69:	89 f9                	mov    %edi,%ecx
  801c6b:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801c71:	8b 7a 10             	mov    0x10(%edx),%edi
  801c74:	8b 52 14             	mov    0x14(%edx),%edx
  801c77:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801c7d:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801c80:	89 f0                	mov    %esi,%eax
  801c82:	25 ff 0f 00 00       	and    $0xfff,%eax
  801c87:	74 14                	je     801c9d <spawn+0x2bf>
		va -= i;
  801c89:	29 c6                	sub    %eax,%esi
		memsz += i;
  801c8b:	01 c2                	add    %eax,%edx
  801c8d:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801c93:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801c95:	29 c1                	sub    %eax,%ecx
  801c97:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ca2:	e9 f7 00 00 00       	jmp    801d9e <spawn+0x3c0>
		if (i >= filesz) {
  801ca7:	39 fb                	cmp    %edi,%ebx
  801ca9:	72 27                	jb     801cd2 <spawn+0x2f4>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801cab:	83 ec 04             	sub    $0x4,%esp
  801cae:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801cb4:	56                   	push   %esi
  801cb5:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801cbb:	e8 9c ef ff ff       	call   800c5c <sys_page_alloc>
  801cc0:	83 c4 10             	add    $0x10,%esp
  801cc3:	85 c0                	test   %eax,%eax
  801cc5:	0f 89 c7 00 00 00    	jns    801d92 <spawn+0x3b4>
  801ccb:	89 c3                	mov    %eax,%ebx
  801ccd:	e9 fd 01 00 00       	jmp    801ecf <spawn+0x4f1>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801cd2:	83 ec 04             	sub    $0x4,%esp
  801cd5:	6a 07                	push   $0x7
  801cd7:	68 00 00 40 00       	push   $0x400000
  801cdc:	6a 00                	push   $0x0
  801cde:	e8 79 ef ff ff       	call   800c5c <sys_page_alloc>
  801ce3:	83 c4 10             	add    $0x10,%esp
  801ce6:	85 c0                	test   %eax,%eax
  801ce8:	0f 88 d7 01 00 00    	js     801ec5 <spawn+0x4e7>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801cee:	83 ec 08             	sub    $0x8,%esp
  801cf1:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801cf7:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801cfd:	50                   	push   %eax
  801cfe:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d04:	e8 09 f9 ff ff       	call   801612 <seek>
  801d09:	83 c4 10             	add    $0x10,%esp
  801d0c:	85 c0                	test   %eax,%eax
  801d0e:	0f 88 b5 01 00 00    	js     801ec9 <spawn+0x4eb>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801d14:	83 ec 04             	sub    $0x4,%esp
  801d17:	89 f8                	mov    %edi,%eax
  801d19:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801d1f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801d24:	ba 00 10 00 00       	mov    $0x1000,%edx
  801d29:	0f 47 c2             	cmova  %edx,%eax
  801d2c:	50                   	push   %eax
  801d2d:	68 00 00 40 00       	push   $0x400000
  801d32:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d38:	e8 fd f7 ff ff       	call   80153a <readn>
  801d3d:	83 c4 10             	add    $0x10,%esp
  801d40:	85 c0                	test   %eax,%eax
  801d42:	0f 88 85 01 00 00    	js     801ecd <spawn+0x4ef>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801d48:	83 ec 0c             	sub    $0xc,%esp
  801d4b:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801d51:	56                   	push   %esi
  801d52:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801d58:	68 00 00 40 00       	push   $0x400000
  801d5d:	6a 00                	push   $0x0
  801d5f:	e8 3b ef ff ff       	call   800c9f <sys_page_map>
  801d64:	83 c4 20             	add    $0x20,%esp
  801d67:	85 c0                	test   %eax,%eax
  801d69:	79 15                	jns    801d80 <spawn+0x3a2>
				panic("spawn: sys_page_map data: %e", r);
  801d6b:	50                   	push   %eax
  801d6c:	68 ed 2e 80 00       	push   $0x802eed
  801d71:	68 25 01 00 00       	push   $0x125
  801d76:	68 e1 2e 80 00       	push   $0x802ee1
  801d7b:	e8 7b e4 ff ff       	call   8001fb <_panic>
			sys_page_unmap(0, UTEMP);
  801d80:	83 ec 08             	sub    $0x8,%esp
  801d83:	68 00 00 40 00       	push   $0x400000
  801d88:	6a 00                	push   $0x0
  801d8a:	e8 52 ef ff ff       	call   800ce1 <sys_page_unmap>
  801d8f:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801d92:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d98:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801d9e:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801da4:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801daa:	0f 82 f7 fe ff ff    	jb     801ca7 <spawn+0x2c9>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801db0:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801db7:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801dbe:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801dc5:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801dcb:	0f 8c 65 fe ff ff    	jl     801c36 <spawn+0x258>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801dd1:	83 ec 0c             	sub    $0xc,%esp
  801dd4:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801dda:	e8 8b f5 ff ff       	call   80136a <close>
  801ddf:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801de2:	bb 00 00 00 00       	mov    $0x0,%ebx
  801de7:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801ded:	89 d8                	mov    %ebx,%eax
  801def:	c1 e8 16             	shr    $0x16,%eax
  801df2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801df9:	a8 01                	test   $0x1,%al
  801dfb:	74 42                	je     801e3f <spawn+0x461>
  801dfd:	89 d8                	mov    %ebx,%eax
  801dff:	c1 e8 0c             	shr    $0xc,%eax
  801e02:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e09:	f6 c2 01             	test   $0x1,%dl
  801e0c:	74 31                	je     801e3f <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  801e0e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801e15:	f6 c6 04             	test   $0x4,%dh
  801e18:	74 25                	je     801e3f <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  801e1a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e21:	83 ec 0c             	sub    $0xc,%esp
  801e24:	25 07 0e 00 00       	and    $0xe07,%eax
  801e29:	50                   	push   %eax
  801e2a:	53                   	push   %ebx
  801e2b:	56                   	push   %esi
  801e2c:	53                   	push   %ebx
  801e2d:	6a 00                	push   $0x0
  801e2f:	e8 6b ee ff ff       	call   800c9f <sys_page_map>
			if (r < 0) {
  801e34:	83 c4 20             	add    $0x20,%esp
  801e37:	85 c0                	test   %eax,%eax
  801e39:	0f 88 b1 00 00 00    	js     801ef0 <spawn+0x512>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801e3f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801e45:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801e4b:	75 a0                	jne    801ded <spawn+0x40f>
  801e4d:	e9 b3 00 00 00       	jmp    801f05 <spawn+0x527>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801e52:	50                   	push   %eax
  801e53:	68 0a 2f 80 00       	push   $0x802f0a
  801e58:	68 86 00 00 00       	push   $0x86
  801e5d:	68 e1 2e 80 00       	push   $0x802ee1
  801e62:	e8 94 e3 ff ff       	call   8001fb <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801e67:	83 ec 08             	sub    $0x8,%esp
  801e6a:	6a 02                	push   $0x2
  801e6c:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e72:	e8 ac ee ff ff       	call   800d23 <sys_env_set_status>
  801e77:	83 c4 10             	add    $0x10,%esp
  801e7a:	85 c0                	test   %eax,%eax
  801e7c:	79 2b                	jns    801ea9 <spawn+0x4cb>
		panic("sys_env_set_status: %e", r);
  801e7e:	50                   	push   %eax
  801e7f:	68 24 2f 80 00       	push   $0x802f24
  801e84:	68 89 00 00 00       	push   $0x89
  801e89:	68 e1 2e 80 00       	push   $0x802ee1
  801e8e:	e8 68 e3 ff ff       	call   8001fb <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801e93:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801e99:	e9 a8 00 00 00       	jmp    801f46 <spawn+0x568>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801e9e:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801ea4:	e9 9d 00 00 00       	jmp    801f46 <spawn+0x568>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801ea9:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801eaf:	e9 92 00 00 00       	jmp    801f46 <spawn+0x568>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801eb4:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801eb9:	e9 88 00 00 00       	jmp    801f46 <spawn+0x568>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801ebe:	89 c3                	mov    %eax,%ebx
  801ec0:	e9 81 00 00 00       	jmp    801f46 <spawn+0x568>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ec5:	89 c3                	mov    %eax,%ebx
  801ec7:	eb 06                	jmp    801ecf <spawn+0x4f1>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801ec9:	89 c3                	mov    %eax,%ebx
  801ecb:	eb 02                	jmp    801ecf <spawn+0x4f1>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801ecd:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801ecf:	83 ec 0c             	sub    $0xc,%esp
  801ed2:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ed8:	e8 00 ed ff ff       	call   800bdd <sys_env_destroy>
	close(fd);
  801edd:	83 c4 04             	add    $0x4,%esp
  801ee0:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ee6:	e8 7f f4 ff ff       	call   80136a <close>
	return r;
  801eeb:	83 c4 10             	add    $0x10,%esp
  801eee:	eb 56                	jmp    801f46 <spawn+0x568>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801ef0:	50                   	push   %eax
  801ef1:	68 3b 2f 80 00       	push   $0x802f3b
  801ef6:	68 82 00 00 00       	push   $0x82
  801efb:	68 e1 2e 80 00       	push   $0x802ee1
  801f00:	e8 f6 e2 ff ff       	call   8001fb <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801f05:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801f0c:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801f0f:	83 ec 08             	sub    $0x8,%esp
  801f12:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801f18:	50                   	push   %eax
  801f19:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801f1f:	e8 41 ee ff ff       	call   800d65 <sys_env_set_trapframe>
  801f24:	83 c4 10             	add    $0x10,%esp
  801f27:	85 c0                	test   %eax,%eax
  801f29:	0f 89 38 ff ff ff    	jns    801e67 <spawn+0x489>
  801f2f:	e9 1e ff ff ff       	jmp    801e52 <spawn+0x474>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801f34:	83 ec 08             	sub    $0x8,%esp
  801f37:	68 00 00 40 00       	push   $0x400000
  801f3c:	6a 00                	push   $0x0
  801f3e:	e8 9e ed ff ff       	call   800ce1 <sys_page_unmap>
  801f43:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801f46:	89 d8                	mov    %ebx,%eax
  801f48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f4b:	5b                   	pop    %ebx
  801f4c:	5e                   	pop    %esi
  801f4d:	5f                   	pop    %edi
  801f4e:	5d                   	pop    %ebp
  801f4f:	c3                   	ret    

00801f50 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801f50:	55                   	push   %ebp
  801f51:	89 e5                	mov    %esp,%ebp
  801f53:	56                   	push   %esi
  801f54:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f55:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801f58:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f5d:	eb 03                	jmp    801f62 <spawnl+0x12>
		argc++;
  801f5f:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f62:	83 c2 04             	add    $0x4,%edx
  801f65:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801f69:	75 f4                	jne    801f5f <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801f6b:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801f72:	83 e2 f0             	and    $0xfffffff0,%edx
  801f75:	29 d4                	sub    %edx,%esp
  801f77:	8d 54 24 03          	lea    0x3(%esp),%edx
  801f7b:	c1 ea 02             	shr    $0x2,%edx
  801f7e:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801f85:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801f87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f8a:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801f91:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801f98:	00 
  801f99:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f9b:	b8 00 00 00 00       	mov    $0x0,%eax
  801fa0:	eb 0a                	jmp    801fac <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801fa2:	83 c0 01             	add    $0x1,%eax
  801fa5:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801fa9:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801fac:	39 d0                	cmp    %edx,%eax
  801fae:	75 f2                	jne    801fa2 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801fb0:	83 ec 08             	sub    $0x8,%esp
  801fb3:	56                   	push   %esi
  801fb4:	ff 75 08             	pushl  0x8(%ebp)
  801fb7:	e8 22 fa ff ff       	call   8019de <spawn>
}
  801fbc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fbf:	5b                   	pop    %ebx
  801fc0:	5e                   	pop    %esi
  801fc1:	5d                   	pop    %ebp
  801fc2:	c3                   	ret    

00801fc3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801fc3:	55                   	push   %ebp
  801fc4:	89 e5                	mov    %esp,%ebp
  801fc6:	56                   	push   %esi
  801fc7:	53                   	push   %ebx
  801fc8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801fcb:	83 ec 0c             	sub    $0xc,%esp
  801fce:	ff 75 08             	pushl  0x8(%ebp)
  801fd1:	e8 01 f2 ff ff       	call   8011d7 <fd2data>
  801fd6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801fd8:	83 c4 08             	add    $0x8,%esp
  801fdb:	68 7c 2f 80 00       	push   $0x802f7c
  801fe0:	53                   	push   %ebx
  801fe1:	e8 73 e8 ff ff       	call   800859 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801fe6:	8b 46 04             	mov    0x4(%esi),%eax
  801fe9:	2b 06                	sub    (%esi),%eax
  801feb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ff1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ff8:	00 00 00 
	stat->st_dev = &devpipe;
  801ffb:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  802002:	30 80 00 
	return 0;
}
  802005:	b8 00 00 00 00       	mov    $0x0,%eax
  80200a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80200d:	5b                   	pop    %ebx
  80200e:	5e                   	pop    %esi
  80200f:	5d                   	pop    %ebp
  802010:	c3                   	ret    

00802011 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802011:	55                   	push   %ebp
  802012:	89 e5                	mov    %esp,%ebp
  802014:	53                   	push   %ebx
  802015:	83 ec 0c             	sub    $0xc,%esp
  802018:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80201b:	53                   	push   %ebx
  80201c:	6a 00                	push   $0x0
  80201e:	e8 be ec ff ff       	call   800ce1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802023:	89 1c 24             	mov    %ebx,(%esp)
  802026:	e8 ac f1 ff ff       	call   8011d7 <fd2data>
  80202b:	83 c4 08             	add    $0x8,%esp
  80202e:	50                   	push   %eax
  80202f:	6a 00                	push   $0x0
  802031:	e8 ab ec ff ff       	call   800ce1 <sys_page_unmap>
}
  802036:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802039:	c9                   	leave  
  80203a:	c3                   	ret    

0080203b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80203b:	55                   	push   %ebp
  80203c:	89 e5                	mov    %esp,%ebp
  80203e:	57                   	push   %edi
  80203f:	56                   	push   %esi
  802040:	53                   	push   %ebx
  802041:	83 ec 1c             	sub    $0x1c,%esp
  802044:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802047:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802049:	a1 04 40 80 00       	mov    0x804004,%eax
  80204e:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802054:	83 ec 0c             	sub    $0xc,%esp
  802057:	ff 75 e0             	pushl  -0x20(%ebp)
  80205a:	e8 55 06 00 00       	call   8026b4 <pageref>
  80205f:	89 c3                	mov    %eax,%ebx
  802061:	89 3c 24             	mov    %edi,(%esp)
  802064:	e8 4b 06 00 00       	call   8026b4 <pageref>
  802069:	83 c4 10             	add    $0x10,%esp
  80206c:	39 c3                	cmp    %eax,%ebx
  80206e:	0f 94 c1             	sete   %cl
  802071:	0f b6 c9             	movzbl %cl,%ecx
  802074:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802077:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80207d:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  802083:	39 ce                	cmp    %ecx,%esi
  802085:	74 1e                	je     8020a5 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  802087:	39 c3                	cmp    %eax,%ebx
  802089:	75 be                	jne    802049 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80208b:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  802091:	ff 75 e4             	pushl  -0x1c(%ebp)
  802094:	50                   	push   %eax
  802095:	56                   	push   %esi
  802096:	68 83 2f 80 00       	push   $0x802f83
  80209b:	e8 34 e2 ff ff       	call   8002d4 <cprintf>
  8020a0:	83 c4 10             	add    $0x10,%esp
  8020a3:	eb a4                	jmp    802049 <_pipeisclosed+0xe>
	}
}
  8020a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020ab:	5b                   	pop    %ebx
  8020ac:	5e                   	pop    %esi
  8020ad:	5f                   	pop    %edi
  8020ae:	5d                   	pop    %ebp
  8020af:	c3                   	ret    

008020b0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020b0:	55                   	push   %ebp
  8020b1:	89 e5                	mov    %esp,%ebp
  8020b3:	57                   	push   %edi
  8020b4:	56                   	push   %esi
  8020b5:	53                   	push   %ebx
  8020b6:	83 ec 28             	sub    $0x28,%esp
  8020b9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8020bc:	56                   	push   %esi
  8020bd:	e8 15 f1 ff ff       	call   8011d7 <fd2data>
  8020c2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020c4:	83 c4 10             	add    $0x10,%esp
  8020c7:	bf 00 00 00 00       	mov    $0x0,%edi
  8020cc:	eb 4b                	jmp    802119 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8020ce:	89 da                	mov    %ebx,%edx
  8020d0:	89 f0                	mov    %esi,%eax
  8020d2:	e8 64 ff ff ff       	call   80203b <_pipeisclosed>
  8020d7:	85 c0                	test   %eax,%eax
  8020d9:	75 48                	jne    802123 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8020db:	e8 5d eb ff ff       	call   800c3d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8020e0:	8b 43 04             	mov    0x4(%ebx),%eax
  8020e3:	8b 0b                	mov    (%ebx),%ecx
  8020e5:	8d 51 20             	lea    0x20(%ecx),%edx
  8020e8:	39 d0                	cmp    %edx,%eax
  8020ea:	73 e2                	jae    8020ce <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8020ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020ef:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8020f3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8020f6:	89 c2                	mov    %eax,%edx
  8020f8:	c1 fa 1f             	sar    $0x1f,%edx
  8020fb:	89 d1                	mov    %edx,%ecx
  8020fd:	c1 e9 1b             	shr    $0x1b,%ecx
  802100:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802103:	83 e2 1f             	and    $0x1f,%edx
  802106:	29 ca                	sub    %ecx,%edx
  802108:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80210c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802110:	83 c0 01             	add    $0x1,%eax
  802113:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802116:	83 c7 01             	add    $0x1,%edi
  802119:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80211c:	75 c2                	jne    8020e0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80211e:	8b 45 10             	mov    0x10(%ebp),%eax
  802121:	eb 05                	jmp    802128 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802123:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802128:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80212b:	5b                   	pop    %ebx
  80212c:	5e                   	pop    %esi
  80212d:	5f                   	pop    %edi
  80212e:	5d                   	pop    %ebp
  80212f:	c3                   	ret    

00802130 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802130:	55                   	push   %ebp
  802131:	89 e5                	mov    %esp,%ebp
  802133:	57                   	push   %edi
  802134:	56                   	push   %esi
  802135:	53                   	push   %ebx
  802136:	83 ec 18             	sub    $0x18,%esp
  802139:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80213c:	57                   	push   %edi
  80213d:	e8 95 f0 ff ff       	call   8011d7 <fd2data>
  802142:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802144:	83 c4 10             	add    $0x10,%esp
  802147:	bb 00 00 00 00       	mov    $0x0,%ebx
  80214c:	eb 3d                	jmp    80218b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80214e:	85 db                	test   %ebx,%ebx
  802150:	74 04                	je     802156 <devpipe_read+0x26>
				return i;
  802152:	89 d8                	mov    %ebx,%eax
  802154:	eb 44                	jmp    80219a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802156:	89 f2                	mov    %esi,%edx
  802158:	89 f8                	mov    %edi,%eax
  80215a:	e8 dc fe ff ff       	call   80203b <_pipeisclosed>
  80215f:	85 c0                	test   %eax,%eax
  802161:	75 32                	jne    802195 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802163:	e8 d5 ea ff ff       	call   800c3d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802168:	8b 06                	mov    (%esi),%eax
  80216a:	3b 46 04             	cmp    0x4(%esi),%eax
  80216d:	74 df                	je     80214e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80216f:	99                   	cltd   
  802170:	c1 ea 1b             	shr    $0x1b,%edx
  802173:	01 d0                	add    %edx,%eax
  802175:	83 e0 1f             	and    $0x1f,%eax
  802178:	29 d0                	sub    %edx,%eax
  80217a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80217f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802182:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802185:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802188:	83 c3 01             	add    $0x1,%ebx
  80218b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80218e:	75 d8                	jne    802168 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802190:	8b 45 10             	mov    0x10(%ebp),%eax
  802193:	eb 05                	jmp    80219a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802195:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80219a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80219d:	5b                   	pop    %ebx
  80219e:	5e                   	pop    %esi
  80219f:	5f                   	pop    %edi
  8021a0:	5d                   	pop    %ebp
  8021a1:	c3                   	ret    

008021a2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8021a2:	55                   	push   %ebp
  8021a3:	89 e5                	mov    %esp,%ebp
  8021a5:	56                   	push   %esi
  8021a6:	53                   	push   %ebx
  8021a7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8021aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021ad:	50                   	push   %eax
  8021ae:	e8 3b f0 ff ff       	call   8011ee <fd_alloc>
  8021b3:	83 c4 10             	add    $0x10,%esp
  8021b6:	89 c2                	mov    %eax,%edx
  8021b8:	85 c0                	test   %eax,%eax
  8021ba:	0f 88 2c 01 00 00    	js     8022ec <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021c0:	83 ec 04             	sub    $0x4,%esp
  8021c3:	68 07 04 00 00       	push   $0x407
  8021c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8021cb:	6a 00                	push   $0x0
  8021cd:	e8 8a ea ff ff       	call   800c5c <sys_page_alloc>
  8021d2:	83 c4 10             	add    $0x10,%esp
  8021d5:	89 c2                	mov    %eax,%edx
  8021d7:	85 c0                	test   %eax,%eax
  8021d9:	0f 88 0d 01 00 00    	js     8022ec <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8021df:	83 ec 0c             	sub    $0xc,%esp
  8021e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021e5:	50                   	push   %eax
  8021e6:	e8 03 f0 ff ff       	call   8011ee <fd_alloc>
  8021eb:	89 c3                	mov    %eax,%ebx
  8021ed:	83 c4 10             	add    $0x10,%esp
  8021f0:	85 c0                	test   %eax,%eax
  8021f2:	0f 88 e2 00 00 00    	js     8022da <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021f8:	83 ec 04             	sub    $0x4,%esp
  8021fb:	68 07 04 00 00       	push   $0x407
  802200:	ff 75 f0             	pushl  -0x10(%ebp)
  802203:	6a 00                	push   $0x0
  802205:	e8 52 ea ff ff       	call   800c5c <sys_page_alloc>
  80220a:	89 c3                	mov    %eax,%ebx
  80220c:	83 c4 10             	add    $0x10,%esp
  80220f:	85 c0                	test   %eax,%eax
  802211:	0f 88 c3 00 00 00    	js     8022da <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802217:	83 ec 0c             	sub    $0xc,%esp
  80221a:	ff 75 f4             	pushl  -0xc(%ebp)
  80221d:	e8 b5 ef ff ff       	call   8011d7 <fd2data>
  802222:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802224:	83 c4 0c             	add    $0xc,%esp
  802227:	68 07 04 00 00       	push   $0x407
  80222c:	50                   	push   %eax
  80222d:	6a 00                	push   $0x0
  80222f:	e8 28 ea ff ff       	call   800c5c <sys_page_alloc>
  802234:	89 c3                	mov    %eax,%ebx
  802236:	83 c4 10             	add    $0x10,%esp
  802239:	85 c0                	test   %eax,%eax
  80223b:	0f 88 89 00 00 00    	js     8022ca <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802241:	83 ec 0c             	sub    $0xc,%esp
  802244:	ff 75 f0             	pushl  -0x10(%ebp)
  802247:	e8 8b ef ff ff       	call   8011d7 <fd2data>
  80224c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802253:	50                   	push   %eax
  802254:	6a 00                	push   $0x0
  802256:	56                   	push   %esi
  802257:	6a 00                	push   $0x0
  802259:	e8 41 ea ff ff       	call   800c9f <sys_page_map>
  80225e:	89 c3                	mov    %eax,%ebx
  802260:	83 c4 20             	add    $0x20,%esp
  802263:	85 c0                	test   %eax,%eax
  802265:	78 55                	js     8022bc <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802267:	8b 15 28 30 80 00    	mov    0x803028,%edx
  80226d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802270:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802272:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802275:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80227c:	8b 15 28 30 80 00    	mov    0x803028,%edx
  802282:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802285:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802287:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80228a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802291:	83 ec 0c             	sub    $0xc,%esp
  802294:	ff 75 f4             	pushl  -0xc(%ebp)
  802297:	e8 2b ef ff ff       	call   8011c7 <fd2num>
  80229c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80229f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8022a1:	83 c4 04             	add    $0x4,%esp
  8022a4:	ff 75 f0             	pushl  -0x10(%ebp)
  8022a7:	e8 1b ef ff ff       	call   8011c7 <fd2num>
  8022ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022af:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8022b2:	83 c4 10             	add    $0x10,%esp
  8022b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8022ba:	eb 30                	jmp    8022ec <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8022bc:	83 ec 08             	sub    $0x8,%esp
  8022bf:	56                   	push   %esi
  8022c0:	6a 00                	push   $0x0
  8022c2:	e8 1a ea ff ff       	call   800ce1 <sys_page_unmap>
  8022c7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8022ca:	83 ec 08             	sub    $0x8,%esp
  8022cd:	ff 75 f0             	pushl  -0x10(%ebp)
  8022d0:	6a 00                	push   $0x0
  8022d2:	e8 0a ea ff ff       	call   800ce1 <sys_page_unmap>
  8022d7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8022da:	83 ec 08             	sub    $0x8,%esp
  8022dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8022e0:	6a 00                	push   $0x0
  8022e2:	e8 fa e9 ff ff       	call   800ce1 <sys_page_unmap>
  8022e7:	83 c4 10             	add    $0x10,%esp
  8022ea:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8022ec:	89 d0                	mov    %edx,%eax
  8022ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022f1:	5b                   	pop    %ebx
  8022f2:	5e                   	pop    %esi
  8022f3:	5d                   	pop    %ebp
  8022f4:	c3                   	ret    

008022f5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8022f5:	55                   	push   %ebp
  8022f6:	89 e5                	mov    %esp,%ebp
  8022f8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022fe:	50                   	push   %eax
  8022ff:	ff 75 08             	pushl  0x8(%ebp)
  802302:	e8 36 ef ff ff       	call   80123d <fd_lookup>
  802307:	83 c4 10             	add    $0x10,%esp
  80230a:	85 c0                	test   %eax,%eax
  80230c:	78 18                	js     802326 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80230e:	83 ec 0c             	sub    $0xc,%esp
  802311:	ff 75 f4             	pushl  -0xc(%ebp)
  802314:	e8 be ee ff ff       	call   8011d7 <fd2data>
	return _pipeisclosed(fd, p);
  802319:	89 c2                	mov    %eax,%edx
  80231b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80231e:	e8 18 fd ff ff       	call   80203b <_pipeisclosed>
  802323:	83 c4 10             	add    $0x10,%esp
}
  802326:	c9                   	leave  
  802327:	c3                   	ret    

00802328 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802328:	55                   	push   %ebp
  802329:	89 e5                	mov    %esp,%ebp
  80232b:	56                   	push   %esi
  80232c:	53                   	push   %ebx
  80232d:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802330:	85 f6                	test   %esi,%esi
  802332:	75 16                	jne    80234a <wait+0x22>
  802334:	68 9b 2f 80 00       	push   $0x802f9b
  802339:	68 9b 2e 80 00       	push   $0x802e9b
  80233e:	6a 09                	push   $0x9
  802340:	68 a6 2f 80 00       	push   $0x802fa6
  802345:	e8 b1 de ff ff       	call   8001fb <_panic>
	e = &envs[ENVX(envid)];
  80234a:	89 f3                	mov    %esi,%ebx
  80234c:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802352:	69 db d8 00 00 00    	imul   $0xd8,%ebx,%ebx
  802358:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80235e:	eb 05                	jmp    802365 <wait+0x3d>
		sys_yield();
  802360:	e8 d8 e8 ff ff       	call   800c3d <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802365:	8b 83 a4 00 00 00    	mov    0xa4(%ebx),%eax
  80236b:	39 c6                	cmp    %eax,%esi
  80236d:	75 0a                	jne    802379 <wait+0x51>
  80236f:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  802375:	85 c0                	test   %eax,%eax
  802377:	75 e7                	jne    802360 <wait+0x38>
		sys_yield();
}
  802379:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80237c:	5b                   	pop    %ebx
  80237d:	5e                   	pop    %esi
  80237e:	5d                   	pop    %ebp
  80237f:	c3                   	ret    

00802380 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802380:	55                   	push   %ebp
  802381:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802383:	b8 00 00 00 00       	mov    $0x0,%eax
  802388:	5d                   	pop    %ebp
  802389:	c3                   	ret    

0080238a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80238a:	55                   	push   %ebp
  80238b:	89 e5                	mov    %esp,%ebp
  80238d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802390:	68 b1 2f 80 00       	push   $0x802fb1
  802395:	ff 75 0c             	pushl  0xc(%ebp)
  802398:	e8 bc e4 ff ff       	call   800859 <strcpy>
	return 0;
}
  80239d:	b8 00 00 00 00       	mov    $0x0,%eax
  8023a2:	c9                   	leave  
  8023a3:	c3                   	ret    

008023a4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8023a4:	55                   	push   %ebp
  8023a5:	89 e5                	mov    %esp,%ebp
  8023a7:	57                   	push   %edi
  8023a8:	56                   	push   %esi
  8023a9:	53                   	push   %ebx
  8023aa:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023b0:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023b5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023bb:	eb 2d                	jmp    8023ea <devcons_write+0x46>
		m = n - tot;
  8023bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8023c0:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8023c2:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8023c5:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8023ca:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023cd:	83 ec 04             	sub    $0x4,%esp
  8023d0:	53                   	push   %ebx
  8023d1:	03 45 0c             	add    0xc(%ebp),%eax
  8023d4:	50                   	push   %eax
  8023d5:	57                   	push   %edi
  8023d6:	e8 10 e6 ff ff       	call   8009eb <memmove>
		sys_cputs(buf, m);
  8023db:	83 c4 08             	add    $0x8,%esp
  8023de:	53                   	push   %ebx
  8023df:	57                   	push   %edi
  8023e0:	e8 bb e7 ff ff       	call   800ba0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023e5:	01 de                	add    %ebx,%esi
  8023e7:	83 c4 10             	add    $0x10,%esp
  8023ea:	89 f0                	mov    %esi,%eax
  8023ec:	3b 75 10             	cmp    0x10(%ebp),%esi
  8023ef:	72 cc                	jb     8023bd <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8023f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023f4:	5b                   	pop    %ebx
  8023f5:	5e                   	pop    %esi
  8023f6:	5f                   	pop    %edi
  8023f7:	5d                   	pop    %ebp
  8023f8:	c3                   	ret    

008023f9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8023f9:	55                   	push   %ebp
  8023fa:	89 e5                	mov    %esp,%ebp
  8023fc:	83 ec 08             	sub    $0x8,%esp
  8023ff:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802404:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802408:	74 2a                	je     802434 <devcons_read+0x3b>
  80240a:	eb 05                	jmp    802411 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80240c:	e8 2c e8 ff ff       	call   800c3d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802411:	e8 a8 e7 ff ff       	call   800bbe <sys_cgetc>
  802416:	85 c0                	test   %eax,%eax
  802418:	74 f2                	je     80240c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80241a:	85 c0                	test   %eax,%eax
  80241c:	78 16                	js     802434 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80241e:	83 f8 04             	cmp    $0x4,%eax
  802421:	74 0c                	je     80242f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802423:	8b 55 0c             	mov    0xc(%ebp),%edx
  802426:	88 02                	mov    %al,(%edx)
	return 1;
  802428:	b8 01 00 00 00       	mov    $0x1,%eax
  80242d:	eb 05                	jmp    802434 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80242f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802434:	c9                   	leave  
  802435:	c3                   	ret    

00802436 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802436:	55                   	push   %ebp
  802437:	89 e5                	mov    %esp,%ebp
  802439:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80243c:	8b 45 08             	mov    0x8(%ebp),%eax
  80243f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802442:	6a 01                	push   $0x1
  802444:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802447:	50                   	push   %eax
  802448:	e8 53 e7 ff ff       	call   800ba0 <sys_cputs>
}
  80244d:	83 c4 10             	add    $0x10,%esp
  802450:	c9                   	leave  
  802451:	c3                   	ret    

00802452 <getchar>:

int
getchar(void)
{
  802452:	55                   	push   %ebp
  802453:	89 e5                	mov    %esp,%ebp
  802455:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802458:	6a 01                	push   $0x1
  80245a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80245d:	50                   	push   %eax
  80245e:	6a 00                	push   $0x0
  802460:	e8 41 f0 ff ff       	call   8014a6 <read>
	if (r < 0)
  802465:	83 c4 10             	add    $0x10,%esp
  802468:	85 c0                	test   %eax,%eax
  80246a:	78 0f                	js     80247b <getchar+0x29>
		return r;
	if (r < 1)
  80246c:	85 c0                	test   %eax,%eax
  80246e:	7e 06                	jle    802476 <getchar+0x24>
		return -E_EOF;
	return c;
  802470:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802474:	eb 05                	jmp    80247b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802476:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80247b:	c9                   	leave  
  80247c:	c3                   	ret    

0080247d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80247d:	55                   	push   %ebp
  80247e:	89 e5                	mov    %esp,%ebp
  802480:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802483:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802486:	50                   	push   %eax
  802487:	ff 75 08             	pushl  0x8(%ebp)
  80248a:	e8 ae ed ff ff       	call   80123d <fd_lookup>
  80248f:	83 c4 10             	add    $0x10,%esp
  802492:	85 c0                	test   %eax,%eax
  802494:	78 11                	js     8024a7 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802496:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802499:	8b 15 44 30 80 00    	mov    0x803044,%edx
  80249f:	39 10                	cmp    %edx,(%eax)
  8024a1:	0f 94 c0             	sete   %al
  8024a4:	0f b6 c0             	movzbl %al,%eax
}
  8024a7:	c9                   	leave  
  8024a8:	c3                   	ret    

008024a9 <opencons>:

int
opencons(void)
{
  8024a9:	55                   	push   %ebp
  8024aa:	89 e5                	mov    %esp,%ebp
  8024ac:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8024af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024b2:	50                   	push   %eax
  8024b3:	e8 36 ed ff ff       	call   8011ee <fd_alloc>
  8024b8:	83 c4 10             	add    $0x10,%esp
		return r;
  8024bb:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8024bd:	85 c0                	test   %eax,%eax
  8024bf:	78 3e                	js     8024ff <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024c1:	83 ec 04             	sub    $0x4,%esp
  8024c4:	68 07 04 00 00       	push   $0x407
  8024c9:	ff 75 f4             	pushl  -0xc(%ebp)
  8024cc:	6a 00                	push   $0x0
  8024ce:	e8 89 e7 ff ff       	call   800c5c <sys_page_alloc>
  8024d3:	83 c4 10             	add    $0x10,%esp
		return r;
  8024d6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024d8:	85 c0                	test   %eax,%eax
  8024da:	78 23                	js     8024ff <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8024dc:	8b 15 44 30 80 00    	mov    0x803044,%edx
  8024e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024e5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8024e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024ea:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8024f1:	83 ec 0c             	sub    $0xc,%esp
  8024f4:	50                   	push   %eax
  8024f5:	e8 cd ec ff ff       	call   8011c7 <fd2num>
  8024fa:	89 c2                	mov    %eax,%edx
  8024fc:	83 c4 10             	add    $0x10,%esp
}
  8024ff:	89 d0                	mov    %edx,%eax
  802501:	c9                   	leave  
  802502:	c3                   	ret    

00802503 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802503:	55                   	push   %ebp
  802504:	89 e5                	mov    %esp,%ebp
  802506:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802509:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802510:	75 2a                	jne    80253c <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802512:	83 ec 04             	sub    $0x4,%esp
  802515:	6a 07                	push   $0x7
  802517:	68 00 f0 bf ee       	push   $0xeebff000
  80251c:	6a 00                	push   $0x0
  80251e:	e8 39 e7 ff ff       	call   800c5c <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802523:	83 c4 10             	add    $0x10,%esp
  802526:	85 c0                	test   %eax,%eax
  802528:	79 12                	jns    80253c <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80252a:	50                   	push   %eax
  80252b:	68 bd 2f 80 00       	push   $0x802fbd
  802530:	6a 23                	push   $0x23
  802532:	68 c1 2f 80 00       	push   $0x802fc1
  802537:	e8 bf dc ff ff       	call   8001fb <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80253c:	8b 45 08             	mov    0x8(%ebp),%eax
  80253f:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802544:	83 ec 08             	sub    $0x8,%esp
  802547:	68 6e 25 80 00       	push   $0x80256e
  80254c:	6a 00                	push   $0x0
  80254e:	e8 54 e8 ff ff       	call   800da7 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802553:	83 c4 10             	add    $0x10,%esp
  802556:	85 c0                	test   %eax,%eax
  802558:	79 12                	jns    80256c <set_pgfault_handler+0x69>
		panic("%e\n", r);
  80255a:	50                   	push   %eax
  80255b:	68 bd 2f 80 00       	push   $0x802fbd
  802560:	6a 2c                	push   $0x2c
  802562:	68 c1 2f 80 00       	push   $0x802fc1
  802567:	e8 8f dc ff ff       	call   8001fb <_panic>
	}
}
  80256c:	c9                   	leave  
  80256d:	c3                   	ret    

0080256e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80256e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80256f:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802574:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802576:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802579:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  80257d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802582:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802586:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802588:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  80258b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  80258c:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80258f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802590:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802591:	c3                   	ret    

00802592 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802592:	55                   	push   %ebp
  802593:	89 e5                	mov    %esp,%ebp
  802595:	56                   	push   %esi
  802596:	53                   	push   %ebx
  802597:	8b 75 08             	mov    0x8(%ebp),%esi
  80259a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80259d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8025a0:	85 c0                	test   %eax,%eax
  8025a2:	75 12                	jne    8025b6 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8025a4:	83 ec 0c             	sub    $0xc,%esp
  8025a7:	68 00 00 c0 ee       	push   $0xeec00000
  8025ac:	e8 5b e8 ff ff       	call   800e0c <sys_ipc_recv>
  8025b1:	83 c4 10             	add    $0x10,%esp
  8025b4:	eb 0c                	jmp    8025c2 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8025b6:	83 ec 0c             	sub    $0xc,%esp
  8025b9:	50                   	push   %eax
  8025ba:	e8 4d e8 ff ff       	call   800e0c <sys_ipc_recv>
  8025bf:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8025c2:	85 f6                	test   %esi,%esi
  8025c4:	0f 95 c1             	setne  %cl
  8025c7:	85 db                	test   %ebx,%ebx
  8025c9:	0f 95 c2             	setne  %dl
  8025cc:	84 d1                	test   %dl,%cl
  8025ce:	74 09                	je     8025d9 <ipc_recv+0x47>
  8025d0:	89 c2                	mov    %eax,%edx
  8025d2:	c1 ea 1f             	shr    $0x1f,%edx
  8025d5:	84 d2                	test   %dl,%dl
  8025d7:	75 2d                	jne    802606 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8025d9:	85 f6                	test   %esi,%esi
  8025db:	74 0d                	je     8025ea <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8025dd:	a1 04 40 80 00       	mov    0x804004,%eax
  8025e2:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8025e8:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8025ea:	85 db                	test   %ebx,%ebx
  8025ec:	74 0d                	je     8025fb <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8025ee:	a1 04 40 80 00       	mov    0x804004,%eax
  8025f3:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  8025f9:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8025fb:	a1 04 40 80 00       	mov    0x804004,%eax
  802600:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  802606:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802609:	5b                   	pop    %ebx
  80260a:	5e                   	pop    %esi
  80260b:	5d                   	pop    %ebp
  80260c:	c3                   	ret    

0080260d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80260d:	55                   	push   %ebp
  80260e:	89 e5                	mov    %esp,%ebp
  802610:	57                   	push   %edi
  802611:	56                   	push   %esi
  802612:	53                   	push   %ebx
  802613:	83 ec 0c             	sub    $0xc,%esp
  802616:	8b 7d 08             	mov    0x8(%ebp),%edi
  802619:	8b 75 0c             	mov    0xc(%ebp),%esi
  80261c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80261f:	85 db                	test   %ebx,%ebx
  802621:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802626:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802629:	ff 75 14             	pushl  0x14(%ebp)
  80262c:	53                   	push   %ebx
  80262d:	56                   	push   %esi
  80262e:	57                   	push   %edi
  80262f:	e8 b5 e7 ff ff       	call   800de9 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802634:	89 c2                	mov    %eax,%edx
  802636:	c1 ea 1f             	shr    $0x1f,%edx
  802639:	83 c4 10             	add    $0x10,%esp
  80263c:	84 d2                	test   %dl,%dl
  80263e:	74 17                	je     802657 <ipc_send+0x4a>
  802640:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802643:	74 12                	je     802657 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802645:	50                   	push   %eax
  802646:	68 cf 2f 80 00       	push   $0x802fcf
  80264b:	6a 47                	push   $0x47
  80264d:	68 dd 2f 80 00       	push   $0x802fdd
  802652:	e8 a4 db ff ff       	call   8001fb <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802657:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80265a:	75 07                	jne    802663 <ipc_send+0x56>
			sys_yield();
  80265c:	e8 dc e5 ff ff       	call   800c3d <sys_yield>
  802661:	eb c6                	jmp    802629 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802663:	85 c0                	test   %eax,%eax
  802665:	75 c2                	jne    802629 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802667:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80266a:	5b                   	pop    %ebx
  80266b:	5e                   	pop    %esi
  80266c:	5f                   	pop    %edi
  80266d:	5d                   	pop    %ebp
  80266e:	c3                   	ret    

0080266f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80266f:	55                   	push   %ebp
  802670:	89 e5                	mov    %esp,%ebp
  802672:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802675:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80267a:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  802680:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802686:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  80268c:	39 ca                	cmp    %ecx,%edx
  80268e:	75 13                	jne    8026a3 <ipc_find_env+0x34>
			return envs[i].env_id;
  802690:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  802696:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80269b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8026a1:	eb 0f                	jmp    8026b2 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8026a3:	83 c0 01             	add    $0x1,%eax
  8026a6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8026ab:	75 cd                	jne    80267a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8026ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8026b2:	5d                   	pop    %ebp
  8026b3:	c3                   	ret    

008026b4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8026b4:	55                   	push   %ebp
  8026b5:	89 e5                	mov    %esp,%ebp
  8026b7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026ba:	89 d0                	mov    %edx,%eax
  8026bc:	c1 e8 16             	shr    $0x16,%eax
  8026bf:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8026c6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026cb:	f6 c1 01             	test   $0x1,%cl
  8026ce:	74 1d                	je     8026ed <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8026d0:	c1 ea 0c             	shr    $0xc,%edx
  8026d3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8026da:	f6 c2 01             	test   $0x1,%dl
  8026dd:	74 0e                	je     8026ed <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8026df:	c1 ea 0c             	shr    $0xc,%edx
  8026e2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8026e9:	ef 
  8026ea:	0f b7 c0             	movzwl %ax,%eax
}
  8026ed:	5d                   	pop    %ebp
  8026ee:	c3                   	ret    
  8026ef:	90                   	nop

008026f0 <__udivdi3>:
  8026f0:	55                   	push   %ebp
  8026f1:	57                   	push   %edi
  8026f2:	56                   	push   %esi
  8026f3:	53                   	push   %ebx
  8026f4:	83 ec 1c             	sub    $0x1c,%esp
  8026f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8026fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8026ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802703:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802707:	85 f6                	test   %esi,%esi
  802709:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80270d:	89 ca                	mov    %ecx,%edx
  80270f:	89 f8                	mov    %edi,%eax
  802711:	75 3d                	jne    802750 <__udivdi3+0x60>
  802713:	39 cf                	cmp    %ecx,%edi
  802715:	0f 87 c5 00 00 00    	ja     8027e0 <__udivdi3+0xf0>
  80271b:	85 ff                	test   %edi,%edi
  80271d:	89 fd                	mov    %edi,%ebp
  80271f:	75 0b                	jne    80272c <__udivdi3+0x3c>
  802721:	b8 01 00 00 00       	mov    $0x1,%eax
  802726:	31 d2                	xor    %edx,%edx
  802728:	f7 f7                	div    %edi
  80272a:	89 c5                	mov    %eax,%ebp
  80272c:	89 c8                	mov    %ecx,%eax
  80272e:	31 d2                	xor    %edx,%edx
  802730:	f7 f5                	div    %ebp
  802732:	89 c1                	mov    %eax,%ecx
  802734:	89 d8                	mov    %ebx,%eax
  802736:	89 cf                	mov    %ecx,%edi
  802738:	f7 f5                	div    %ebp
  80273a:	89 c3                	mov    %eax,%ebx
  80273c:	89 d8                	mov    %ebx,%eax
  80273e:	89 fa                	mov    %edi,%edx
  802740:	83 c4 1c             	add    $0x1c,%esp
  802743:	5b                   	pop    %ebx
  802744:	5e                   	pop    %esi
  802745:	5f                   	pop    %edi
  802746:	5d                   	pop    %ebp
  802747:	c3                   	ret    
  802748:	90                   	nop
  802749:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802750:	39 ce                	cmp    %ecx,%esi
  802752:	77 74                	ja     8027c8 <__udivdi3+0xd8>
  802754:	0f bd fe             	bsr    %esi,%edi
  802757:	83 f7 1f             	xor    $0x1f,%edi
  80275a:	0f 84 98 00 00 00    	je     8027f8 <__udivdi3+0x108>
  802760:	bb 20 00 00 00       	mov    $0x20,%ebx
  802765:	89 f9                	mov    %edi,%ecx
  802767:	89 c5                	mov    %eax,%ebp
  802769:	29 fb                	sub    %edi,%ebx
  80276b:	d3 e6                	shl    %cl,%esi
  80276d:	89 d9                	mov    %ebx,%ecx
  80276f:	d3 ed                	shr    %cl,%ebp
  802771:	89 f9                	mov    %edi,%ecx
  802773:	d3 e0                	shl    %cl,%eax
  802775:	09 ee                	or     %ebp,%esi
  802777:	89 d9                	mov    %ebx,%ecx
  802779:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80277d:	89 d5                	mov    %edx,%ebp
  80277f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802783:	d3 ed                	shr    %cl,%ebp
  802785:	89 f9                	mov    %edi,%ecx
  802787:	d3 e2                	shl    %cl,%edx
  802789:	89 d9                	mov    %ebx,%ecx
  80278b:	d3 e8                	shr    %cl,%eax
  80278d:	09 c2                	or     %eax,%edx
  80278f:	89 d0                	mov    %edx,%eax
  802791:	89 ea                	mov    %ebp,%edx
  802793:	f7 f6                	div    %esi
  802795:	89 d5                	mov    %edx,%ebp
  802797:	89 c3                	mov    %eax,%ebx
  802799:	f7 64 24 0c          	mull   0xc(%esp)
  80279d:	39 d5                	cmp    %edx,%ebp
  80279f:	72 10                	jb     8027b1 <__udivdi3+0xc1>
  8027a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8027a5:	89 f9                	mov    %edi,%ecx
  8027a7:	d3 e6                	shl    %cl,%esi
  8027a9:	39 c6                	cmp    %eax,%esi
  8027ab:	73 07                	jae    8027b4 <__udivdi3+0xc4>
  8027ad:	39 d5                	cmp    %edx,%ebp
  8027af:	75 03                	jne    8027b4 <__udivdi3+0xc4>
  8027b1:	83 eb 01             	sub    $0x1,%ebx
  8027b4:	31 ff                	xor    %edi,%edi
  8027b6:	89 d8                	mov    %ebx,%eax
  8027b8:	89 fa                	mov    %edi,%edx
  8027ba:	83 c4 1c             	add    $0x1c,%esp
  8027bd:	5b                   	pop    %ebx
  8027be:	5e                   	pop    %esi
  8027bf:	5f                   	pop    %edi
  8027c0:	5d                   	pop    %ebp
  8027c1:	c3                   	ret    
  8027c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027c8:	31 ff                	xor    %edi,%edi
  8027ca:	31 db                	xor    %ebx,%ebx
  8027cc:	89 d8                	mov    %ebx,%eax
  8027ce:	89 fa                	mov    %edi,%edx
  8027d0:	83 c4 1c             	add    $0x1c,%esp
  8027d3:	5b                   	pop    %ebx
  8027d4:	5e                   	pop    %esi
  8027d5:	5f                   	pop    %edi
  8027d6:	5d                   	pop    %ebp
  8027d7:	c3                   	ret    
  8027d8:	90                   	nop
  8027d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027e0:	89 d8                	mov    %ebx,%eax
  8027e2:	f7 f7                	div    %edi
  8027e4:	31 ff                	xor    %edi,%edi
  8027e6:	89 c3                	mov    %eax,%ebx
  8027e8:	89 d8                	mov    %ebx,%eax
  8027ea:	89 fa                	mov    %edi,%edx
  8027ec:	83 c4 1c             	add    $0x1c,%esp
  8027ef:	5b                   	pop    %ebx
  8027f0:	5e                   	pop    %esi
  8027f1:	5f                   	pop    %edi
  8027f2:	5d                   	pop    %ebp
  8027f3:	c3                   	ret    
  8027f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027f8:	39 ce                	cmp    %ecx,%esi
  8027fa:	72 0c                	jb     802808 <__udivdi3+0x118>
  8027fc:	31 db                	xor    %ebx,%ebx
  8027fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802802:	0f 87 34 ff ff ff    	ja     80273c <__udivdi3+0x4c>
  802808:	bb 01 00 00 00       	mov    $0x1,%ebx
  80280d:	e9 2a ff ff ff       	jmp    80273c <__udivdi3+0x4c>
  802812:	66 90                	xchg   %ax,%ax
  802814:	66 90                	xchg   %ax,%ax
  802816:	66 90                	xchg   %ax,%ax
  802818:	66 90                	xchg   %ax,%ax
  80281a:	66 90                	xchg   %ax,%ax
  80281c:	66 90                	xchg   %ax,%ax
  80281e:	66 90                	xchg   %ax,%ax

00802820 <__umoddi3>:
  802820:	55                   	push   %ebp
  802821:	57                   	push   %edi
  802822:	56                   	push   %esi
  802823:	53                   	push   %ebx
  802824:	83 ec 1c             	sub    $0x1c,%esp
  802827:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80282b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80282f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802833:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802837:	85 d2                	test   %edx,%edx
  802839:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80283d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802841:	89 f3                	mov    %esi,%ebx
  802843:	89 3c 24             	mov    %edi,(%esp)
  802846:	89 74 24 04          	mov    %esi,0x4(%esp)
  80284a:	75 1c                	jne    802868 <__umoddi3+0x48>
  80284c:	39 f7                	cmp    %esi,%edi
  80284e:	76 50                	jbe    8028a0 <__umoddi3+0x80>
  802850:	89 c8                	mov    %ecx,%eax
  802852:	89 f2                	mov    %esi,%edx
  802854:	f7 f7                	div    %edi
  802856:	89 d0                	mov    %edx,%eax
  802858:	31 d2                	xor    %edx,%edx
  80285a:	83 c4 1c             	add    $0x1c,%esp
  80285d:	5b                   	pop    %ebx
  80285e:	5e                   	pop    %esi
  80285f:	5f                   	pop    %edi
  802860:	5d                   	pop    %ebp
  802861:	c3                   	ret    
  802862:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802868:	39 f2                	cmp    %esi,%edx
  80286a:	89 d0                	mov    %edx,%eax
  80286c:	77 52                	ja     8028c0 <__umoddi3+0xa0>
  80286e:	0f bd ea             	bsr    %edx,%ebp
  802871:	83 f5 1f             	xor    $0x1f,%ebp
  802874:	75 5a                	jne    8028d0 <__umoddi3+0xb0>
  802876:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80287a:	0f 82 e0 00 00 00    	jb     802960 <__umoddi3+0x140>
  802880:	39 0c 24             	cmp    %ecx,(%esp)
  802883:	0f 86 d7 00 00 00    	jbe    802960 <__umoddi3+0x140>
  802889:	8b 44 24 08          	mov    0x8(%esp),%eax
  80288d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802891:	83 c4 1c             	add    $0x1c,%esp
  802894:	5b                   	pop    %ebx
  802895:	5e                   	pop    %esi
  802896:	5f                   	pop    %edi
  802897:	5d                   	pop    %ebp
  802898:	c3                   	ret    
  802899:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028a0:	85 ff                	test   %edi,%edi
  8028a2:	89 fd                	mov    %edi,%ebp
  8028a4:	75 0b                	jne    8028b1 <__umoddi3+0x91>
  8028a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8028ab:	31 d2                	xor    %edx,%edx
  8028ad:	f7 f7                	div    %edi
  8028af:	89 c5                	mov    %eax,%ebp
  8028b1:	89 f0                	mov    %esi,%eax
  8028b3:	31 d2                	xor    %edx,%edx
  8028b5:	f7 f5                	div    %ebp
  8028b7:	89 c8                	mov    %ecx,%eax
  8028b9:	f7 f5                	div    %ebp
  8028bb:	89 d0                	mov    %edx,%eax
  8028bd:	eb 99                	jmp    802858 <__umoddi3+0x38>
  8028bf:	90                   	nop
  8028c0:	89 c8                	mov    %ecx,%eax
  8028c2:	89 f2                	mov    %esi,%edx
  8028c4:	83 c4 1c             	add    $0x1c,%esp
  8028c7:	5b                   	pop    %ebx
  8028c8:	5e                   	pop    %esi
  8028c9:	5f                   	pop    %edi
  8028ca:	5d                   	pop    %ebp
  8028cb:	c3                   	ret    
  8028cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028d0:	8b 34 24             	mov    (%esp),%esi
  8028d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8028d8:	89 e9                	mov    %ebp,%ecx
  8028da:	29 ef                	sub    %ebp,%edi
  8028dc:	d3 e0                	shl    %cl,%eax
  8028de:	89 f9                	mov    %edi,%ecx
  8028e0:	89 f2                	mov    %esi,%edx
  8028e2:	d3 ea                	shr    %cl,%edx
  8028e4:	89 e9                	mov    %ebp,%ecx
  8028e6:	09 c2                	or     %eax,%edx
  8028e8:	89 d8                	mov    %ebx,%eax
  8028ea:	89 14 24             	mov    %edx,(%esp)
  8028ed:	89 f2                	mov    %esi,%edx
  8028ef:	d3 e2                	shl    %cl,%edx
  8028f1:	89 f9                	mov    %edi,%ecx
  8028f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8028f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8028fb:	d3 e8                	shr    %cl,%eax
  8028fd:	89 e9                	mov    %ebp,%ecx
  8028ff:	89 c6                	mov    %eax,%esi
  802901:	d3 e3                	shl    %cl,%ebx
  802903:	89 f9                	mov    %edi,%ecx
  802905:	89 d0                	mov    %edx,%eax
  802907:	d3 e8                	shr    %cl,%eax
  802909:	89 e9                	mov    %ebp,%ecx
  80290b:	09 d8                	or     %ebx,%eax
  80290d:	89 d3                	mov    %edx,%ebx
  80290f:	89 f2                	mov    %esi,%edx
  802911:	f7 34 24             	divl   (%esp)
  802914:	89 d6                	mov    %edx,%esi
  802916:	d3 e3                	shl    %cl,%ebx
  802918:	f7 64 24 04          	mull   0x4(%esp)
  80291c:	39 d6                	cmp    %edx,%esi
  80291e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802922:	89 d1                	mov    %edx,%ecx
  802924:	89 c3                	mov    %eax,%ebx
  802926:	72 08                	jb     802930 <__umoddi3+0x110>
  802928:	75 11                	jne    80293b <__umoddi3+0x11b>
  80292a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80292e:	73 0b                	jae    80293b <__umoddi3+0x11b>
  802930:	2b 44 24 04          	sub    0x4(%esp),%eax
  802934:	1b 14 24             	sbb    (%esp),%edx
  802937:	89 d1                	mov    %edx,%ecx
  802939:	89 c3                	mov    %eax,%ebx
  80293b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80293f:	29 da                	sub    %ebx,%edx
  802941:	19 ce                	sbb    %ecx,%esi
  802943:	89 f9                	mov    %edi,%ecx
  802945:	89 f0                	mov    %esi,%eax
  802947:	d3 e0                	shl    %cl,%eax
  802949:	89 e9                	mov    %ebp,%ecx
  80294b:	d3 ea                	shr    %cl,%edx
  80294d:	89 e9                	mov    %ebp,%ecx
  80294f:	d3 ee                	shr    %cl,%esi
  802951:	09 d0                	or     %edx,%eax
  802953:	89 f2                	mov    %esi,%edx
  802955:	83 c4 1c             	add    $0x1c,%esp
  802958:	5b                   	pop    %ebx
  802959:	5e                   	pop    %esi
  80295a:	5f                   	pop    %edi
  80295b:	5d                   	pop    %ebp
  80295c:	c3                   	ret    
  80295d:	8d 76 00             	lea    0x0(%esi),%esi
  802960:	29 f9                	sub    %edi,%ecx
  802962:	19 d6                	sbb    %edx,%esi
  802964:	89 74 24 04          	mov    %esi,0x4(%esp)
  802968:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80296c:	e9 18 ff ff ff       	jmp    802889 <__umoddi3+0x69>
