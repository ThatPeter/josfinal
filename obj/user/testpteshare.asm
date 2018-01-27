
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
  800081:	68 4c 29 80 00       	push   $0x80294c
  800086:	6a 13                	push   $0x13
  800088:	68 5f 29 80 00       	push   $0x80295f
  80008d:	e8 69 01 00 00       	call   8001fb <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 cc 0e 00 00       	call   800f63 <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 73 29 80 00       	push   $0x802973
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 5f 29 80 00       	push   $0x80295f
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
  8000d2:	e8 ff 21 00 00       	call   8022d6 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 30 80 00    	pushl  0x803004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 19 08 00 00       	call   800903 <strcmp>
  8000ea:	83 c4 08             	add    $0x8,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	ba 46 29 80 00       	mov    $0x802946,%edx
  8000f4:	b8 40 29 80 00       	mov    $0x802940,%eax
  8000f9:	0f 45 c2             	cmovne %edx,%eax
  8000fc:	50                   	push   %eax
  8000fd:	68 7c 29 80 00       	push   $0x80297c
  800102:	e8 cd 01 00 00       	call   8002d4 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800107:	6a 00                	push   $0x0
  800109:	68 97 29 80 00       	push   $0x802997
  80010e:	68 9c 29 80 00       	push   $0x80299c
  800113:	68 9b 29 80 00       	push   $0x80299b
  800118:	e8 e1 1d 00 00       	call   801efe <spawnl>
  80011d:	83 c4 20             	add    $0x20,%esp
  800120:	85 c0                	test   %eax,%eax
  800122:	79 12                	jns    800136 <umain+0xe3>
		panic("spawn: %e", r);
  800124:	50                   	push   %eax
  800125:	68 a9 29 80 00       	push   $0x8029a9
  80012a:	6a 21                	push   $0x21
  80012c:	68 5f 29 80 00       	push   $0x80295f
  800131:	e8 c5 00 00 00       	call   8001fb <_panic>
	wait(r);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	e8 97 21 00 00       	call   8022d6 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff 35 00 30 80 00    	pushl  0x803000
  800148:	68 00 00 00 a0       	push   $0xa0000000
  80014d:	e8 b1 07 00 00       	call   800903 <strcmp>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba 46 29 80 00       	mov    $0x802946,%edx
  80015c:	b8 40 29 80 00       	mov    $0x802940,%eax
  800161:	0f 45 c2             	cmovne %edx,%eax
  800164:	50                   	push   %eax
  800165:	68 b3 29 80 00       	push   $0x8029b3
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
  80018d:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
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
  8001e7:	e8 60 11 00 00       	call   80134c <close_all>
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
  800219:	68 f8 29 80 00       	push   $0x8029f8
  80021e:	e8 b1 00 00 00       	call   8002d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800223:	83 c4 18             	add    $0x18,%esp
  800226:	53                   	push   %ebx
  800227:	ff 75 10             	pushl  0x10(%ebp)
  80022a:	e8 54 00 00 00       	call   800283 <vcprintf>
	cprintf("\n");
  80022f:	c7 04 24 54 2f 80 00 	movl   $0x802f54,(%esp)
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
  800337:	e8 64 23 00 00       	call   8026a0 <__udivdi3>
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
  80037a:	e8 51 24 00 00       	call   8027d0 <__umoddi3>
  80037f:	83 c4 14             	add    $0x14,%esp
  800382:	0f be 80 1b 2a 80 00 	movsbl 0x802a1b(%eax),%eax
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
  80047e:	ff 24 85 60 2b 80 00 	jmp    *0x802b60(,%eax,4)
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
  800542:	8b 14 85 c0 2c 80 00 	mov    0x802cc0(,%eax,4),%edx
  800549:	85 d2                	test   %edx,%edx
  80054b:	75 18                	jne    800565 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80054d:	50                   	push   %eax
  80054e:	68 33 2a 80 00       	push   $0x802a33
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
  800566:	68 6d 2e 80 00       	push   $0x802e6d
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
  80058a:	b8 2c 2a 80 00       	mov    $0x802a2c,%eax
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
  800c05:	68 1f 2d 80 00       	push   $0x802d1f
  800c0a:	6a 23                	push   $0x23
  800c0c:	68 3c 2d 80 00       	push   $0x802d3c
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
  800c86:	68 1f 2d 80 00       	push   $0x802d1f
  800c8b:	6a 23                	push   $0x23
  800c8d:	68 3c 2d 80 00       	push   $0x802d3c
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
  800cc8:	68 1f 2d 80 00       	push   $0x802d1f
  800ccd:	6a 23                	push   $0x23
  800ccf:	68 3c 2d 80 00       	push   $0x802d3c
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
  800d0a:	68 1f 2d 80 00       	push   $0x802d1f
  800d0f:	6a 23                	push   $0x23
  800d11:	68 3c 2d 80 00       	push   $0x802d3c
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
  800d4c:	68 1f 2d 80 00       	push   $0x802d1f
  800d51:	6a 23                	push   $0x23
  800d53:	68 3c 2d 80 00       	push   $0x802d3c
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
  800d8e:	68 1f 2d 80 00       	push   $0x802d1f
  800d93:	6a 23                	push   $0x23
  800d95:	68 3c 2d 80 00       	push   $0x802d3c
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
  800dd0:	68 1f 2d 80 00       	push   $0x802d1f
  800dd5:	6a 23                	push   $0x23
  800dd7:	68 3c 2d 80 00       	push   $0x802d3c
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
  800e34:	68 1f 2d 80 00       	push   $0x802d1f
  800e39:	6a 23                	push   $0x23
  800e3b:	68 3c 2d 80 00       	push   $0x802d3c
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

00800e8d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
  800e90:	53                   	push   %ebx
  800e91:	83 ec 04             	sub    $0x4,%esp
  800e94:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e97:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800e99:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e9d:	74 11                	je     800eb0 <pgfault+0x23>
  800e9f:	89 d8                	mov    %ebx,%eax
  800ea1:	c1 e8 0c             	shr    $0xc,%eax
  800ea4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eab:	f6 c4 08             	test   $0x8,%ah
  800eae:	75 14                	jne    800ec4 <pgfault+0x37>
		panic("faulting access");
  800eb0:	83 ec 04             	sub    $0x4,%esp
  800eb3:	68 4a 2d 80 00       	push   $0x802d4a
  800eb8:	6a 1e                	push   $0x1e
  800eba:	68 5a 2d 80 00       	push   $0x802d5a
  800ebf:	e8 37 f3 ff ff       	call   8001fb <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800ec4:	83 ec 04             	sub    $0x4,%esp
  800ec7:	6a 07                	push   $0x7
  800ec9:	68 00 f0 7f 00       	push   $0x7ff000
  800ece:	6a 00                	push   $0x0
  800ed0:	e8 87 fd ff ff       	call   800c5c <sys_page_alloc>
	if (r < 0) {
  800ed5:	83 c4 10             	add    $0x10,%esp
  800ed8:	85 c0                	test   %eax,%eax
  800eda:	79 12                	jns    800eee <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800edc:	50                   	push   %eax
  800edd:	68 65 2d 80 00       	push   $0x802d65
  800ee2:	6a 2c                	push   $0x2c
  800ee4:	68 5a 2d 80 00       	push   $0x802d5a
  800ee9:	e8 0d f3 ff ff       	call   8001fb <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800eee:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800ef4:	83 ec 04             	sub    $0x4,%esp
  800ef7:	68 00 10 00 00       	push   $0x1000
  800efc:	53                   	push   %ebx
  800efd:	68 00 f0 7f 00       	push   $0x7ff000
  800f02:	e8 4c fb ff ff       	call   800a53 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800f07:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f0e:	53                   	push   %ebx
  800f0f:	6a 00                	push   $0x0
  800f11:	68 00 f0 7f 00       	push   $0x7ff000
  800f16:	6a 00                	push   $0x0
  800f18:	e8 82 fd ff ff       	call   800c9f <sys_page_map>
	if (r < 0) {
  800f1d:	83 c4 20             	add    $0x20,%esp
  800f20:	85 c0                	test   %eax,%eax
  800f22:	79 12                	jns    800f36 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800f24:	50                   	push   %eax
  800f25:	68 65 2d 80 00       	push   $0x802d65
  800f2a:	6a 33                	push   $0x33
  800f2c:	68 5a 2d 80 00       	push   $0x802d5a
  800f31:	e8 c5 f2 ff ff       	call   8001fb <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800f36:	83 ec 08             	sub    $0x8,%esp
  800f39:	68 00 f0 7f 00       	push   $0x7ff000
  800f3e:	6a 00                	push   $0x0
  800f40:	e8 9c fd ff ff       	call   800ce1 <sys_page_unmap>
	if (r < 0) {
  800f45:	83 c4 10             	add    $0x10,%esp
  800f48:	85 c0                	test   %eax,%eax
  800f4a:	79 12                	jns    800f5e <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800f4c:	50                   	push   %eax
  800f4d:	68 65 2d 80 00       	push   $0x802d65
  800f52:	6a 37                	push   $0x37
  800f54:	68 5a 2d 80 00       	push   $0x802d5a
  800f59:	e8 9d f2 ff ff       	call   8001fb <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800f5e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f61:	c9                   	leave  
  800f62:	c3                   	ret    

00800f63 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	57                   	push   %edi
  800f67:	56                   	push   %esi
  800f68:	53                   	push   %ebx
  800f69:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800f6c:	68 8d 0e 80 00       	push   $0x800e8d
  800f71:	e8 38 15 00 00       	call   8024ae <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f76:	b8 07 00 00 00       	mov    $0x7,%eax
  800f7b:	cd 30                	int    $0x30
  800f7d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800f80:	83 c4 10             	add    $0x10,%esp
  800f83:	85 c0                	test   %eax,%eax
  800f85:	79 17                	jns    800f9e <fork+0x3b>
		panic("fork fault %e");
  800f87:	83 ec 04             	sub    $0x4,%esp
  800f8a:	68 7e 2d 80 00       	push   $0x802d7e
  800f8f:	68 84 00 00 00       	push   $0x84
  800f94:	68 5a 2d 80 00       	push   $0x802d5a
  800f99:	e8 5d f2 ff ff       	call   8001fb <_panic>
  800f9e:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800fa0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fa4:	75 24                	jne    800fca <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fa6:	e8 73 fc ff ff       	call   800c1e <sys_getenvid>
  800fab:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fb0:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800fb6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fbb:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800fc0:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc5:	e9 64 01 00 00       	jmp    80112e <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800fca:	83 ec 04             	sub    $0x4,%esp
  800fcd:	6a 07                	push   $0x7
  800fcf:	68 00 f0 bf ee       	push   $0xeebff000
  800fd4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fd7:	e8 80 fc ff ff       	call   800c5c <sys_page_alloc>
  800fdc:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fdf:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fe4:	89 d8                	mov    %ebx,%eax
  800fe6:	c1 e8 16             	shr    $0x16,%eax
  800fe9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ff0:	a8 01                	test   $0x1,%al
  800ff2:	0f 84 fc 00 00 00    	je     8010f4 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800ff8:	89 d8                	mov    %ebx,%eax
  800ffa:	c1 e8 0c             	shr    $0xc,%eax
  800ffd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801004:	f6 c2 01             	test   $0x1,%dl
  801007:	0f 84 e7 00 00 00    	je     8010f4 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80100d:	89 c6                	mov    %eax,%esi
  80100f:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  801012:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801019:	f6 c6 04             	test   $0x4,%dh
  80101c:	74 39                	je     801057 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80101e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801025:	83 ec 0c             	sub    $0xc,%esp
  801028:	25 07 0e 00 00       	and    $0xe07,%eax
  80102d:	50                   	push   %eax
  80102e:	56                   	push   %esi
  80102f:	57                   	push   %edi
  801030:	56                   	push   %esi
  801031:	6a 00                	push   $0x0
  801033:	e8 67 fc ff ff       	call   800c9f <sys_page_map>
		if (r < 0) {
  801038:	83 c4 20             	add    $0x20,%esp
  80103b:	85 c0                	test   %eax,%eax
  80103d:	0f 89 b1 00 00 00    	jns    8010f4 <fork+0x191>
		    	panic("sys page map fault %e");
  801043:	83 ec 04             	sub    $0x4,%esp
  801046:	68 8c 2d 80 00       	push   $0x802d8c
  80104b:	6a 54                	push   $0x54
  80104d:	68 5a 2d 80 00       	push   $0x802d5a
  801052:	e8 a4 f1 ff ff       	call   8001fb <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801057:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80105e:	f6 c2 02             	test   $0x2,%dl
  801061:	75 0c                	jne    80106f <fork+0x10c>
  801063:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80106a:	f6 c4 08             	test   $0x8,%ah
  80106d:	74 5b                	je     8010ca <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80106f:	83 ec 0c             	sub    $0xc,%esp
  801072:	68 05 08 00 00       	push   $0x805
  801077:	56                   	push   %esi
  801078:	57                   	push   %edi
  801079:	56                   	push   %esi
  80107a:	6a 00                	push   $0x0
  80107c:	e8 1e fc ff ff       	call   800c9f <sys_page_map>
		if (r < 0) {
  801081:	83 c4 20             	add    $0x20,%esp
  801084:	85 c0                	test   %eax,%eax
  801086:	79 14                	jns    80109c <fork+0x139>
		    	panic("sys page map fault %e");
  801088:	83 ec 04             	sub    $0x4,%esp
  80108b:	68 8c 2d 80 00       	push   $0x802d8c
  801090:	6a 5b                	push   $0x5b
  801092:	68 5a 2d 80 00       	push   $0x802d5a
  801097:	e8 5f f1 ff ff       	call   8001fb <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  80109c:	83 ec 0c             	sub    $0xc,%esp
  80109f:	68 05 08 00 00       	push   $0x805
  8010a4:	56                   	push   %esi
  8010a5:	6a 00                	push   $0x0
  8010a7:	56                   	push   %esi
  8010a8:	6a 00                	push   $0x0
  8010aa:	e8 f0 fb ff ff       	call   800c9f <sys_page_map>
		if (r < 0) {
  8010af:	83 c4 20             	add    $0x20,%esp
  8010b2:	85 c0                	test   %eax,%eax
  8010b4:	79 3e                	jns    8010f4 <fork+0x191>
		    	panic("sys page map fault %e");
  8010b6:	83 ec 04             	sub    $0x4,%esp
  8010b9:	68 8c 2d 80 00       	push   $0x802d8c
  8010be:	6a 5f                	push   $0x5f
  8010c0:	68 5a 2d 80 00       	push   $0x802d5a
  8010c5:	e8 31 f1 ff ff       	call   8001fb <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8010ca:	83 ec 0c             	sub    $0xc,%esp
  8010cd:	6a 05                	push   $0x5
  8010cf:	56                   	push   %esi
  8010d0:	57                   	push   %edi
  8010d1:	56                   	push   %esi
  8010d2:	6a 00                	push   $0x0
  8010d4:	e8 c6 fb ff ff       	call   800c9f <sys_page_map>
		if (r < 0) {
  8010d9:	83 c4 20             	add    $0x20,%esp
  8010dc:	85 c0                	test   %eax,%eax
  8010de:	79 14                	jns    8010f4 <fork+0x191>
		    	panic("sys page map fault %e");
  8010e0:	83 ec 04             	sub    $0x4,%esp
  8010e3:	68 8c 2d 80 00       	push   $0x802d8c
  8010e8:	6a 64                	push   $0x64
  8010ea:	68 5a 2d 80 00       	push   $0x802d5a
  8010ef:	e8 07 f1 ff ff       	call   8001fb <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8010f4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010fa:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801100:	0f 85 de fe ff ff    	jne    800fe4 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801106:	a1 04 40 80 00       	mov    0x804004,%eax
  80110b:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  801111:	83 ec 08             	sub    $0x8,%esp
  801114:	50                   	push   %eax
  801115:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801118:	57                   	push   %edi
  801119:	e8 89 fc ff ff       	call   800da7 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80111e:	83 c4 08             	add    $0x8,%esp
  801121:	6a 02                	push   $0x2
  801123:	57                   	push   %edi
  801124:	e8 fa fb ff ff       	call   800d23 <sys_env_set_status>
	
	return envid;
  801129:	83 c4 10             	add    $0x10,%esp
  80112c:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80112e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801131:	5b                   	pop    %ebx
  801132:	5e                   	pop    %esi
  801133:	5f                   	pop    %edi
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    

00801136 <sfork>:

envid_t
sfork(void)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801139:	b8 00 00 00 00       	mov    $0x0,%eax
  80113e:	5d                   	pop    %ebp
  80113f:	c3                   	ret    

00801140 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	56                   	push   %esi
  801144:	53                   	push   %ebx
  801145:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801148:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  80114e:	83 ec 08             	sub    $0x8,%esp
  801151:	53                   	push   %ebx
  801152:	68 a4 2d 80 00       	push   $0x802da4
  801157:	e8 78 f1 ff ff       	call   8002d4 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80115c:	c7 04 24 c1 01 80 00 	movl   $0x8001c1,(%esp)
  801163:	e8 e5 fc ff ff       	call   800e4d <sys_thread_create>
  801168:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80116a:	83 c4 08             	add    $0x8,%esp
  80116d:	53                   	push   %ebx
  80116e:	68 a4 2d 80 00       	push   $0x802da4
  801173:	e8 5c f1 ff ff       	call   8002d4 <cprintf>
	return id;
}
  801178:	89 f0                	mov    %esi,%eax
  80117a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80117d:	5b                   	pop    %ebx
  80117e:	5e                   	pop    %esi
  80117f:	5d                   	pop    %ebp
  801180:	c3                   	ret    

00801181 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801181:	55                   	push   %ebp
  801182:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801184:	8b 45 08             	mov    0x8(%ebp),%eax
  801187:	05 00 00 00 30       	add    $0x30000000,%eax
  80118c:	c1 e8 0c             	shr    $0xc,%eax
}
  80118f:	5d                   	pop    %ebp
  801190:	c3                   	ret    

00801191 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801194:	8b 45 08             	mov    0x8(%ebp),%eax
  801197:	05 00 00 00 30       	add    $0x30000000,%eax
  80119c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011a1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011a6:	5d                   	pop    %ebp
  8011a7:	c3                   	ret    

008011a8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ae:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011b3:	89 c2                	mov    %eax,%edx
  8011b5:	c1 ea 16             	shr    $0x16,%edx
  8011b8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011bf:	f6 c2 01             	test   $0x1,%dl
  8011c2:	74 11                	je     8011d5 <fd_alloc+0x2d>
  8011c4:	89 c2                	mov    %eax,%edx
  8011c6:	c1 ea 0c             	shr    $0xc,%edx
  8011c9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011d0:	f6 c2 01             	test   $0x1,%dl
  8011d3:	75 09                	jne    8011de <fd_alloc+0x36>
			*fd_store = fd;
  8011d5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8011dc:	eb 17                	jmp    8011f5 <fd_alloc+0x4d>
  8011de:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011e3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011e8:	75 c9                	jne    8011b3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011ea:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011f0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011f5:	5d                   	pop    %ebp
  8011f6:	c3                   	ret    

008011f7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011fd:	83 f8 1f             	cmp    $0x1f,%eax
  801200:	77 36                	ja     801238 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801202:	c1 e0 0c             	shl    $0xc,%eax
  801205:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80120a:	89 c2                	mov    %eax,%edx
  80120c:	c1 ea 16             	shr    $0x16,%edx
  80120f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801216:	f6 c2 01             	test   $0x1,%dl
  801219:	74 24                	je     80123f <fd_lookup+0x48>
  80121b:	89 c2                	mov    %eax,%edx
  80121d:	c1 ea 0c             	shr    $0xc,%edx
  801220:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801227:	f6 c2 01             	test   $0x1,%dl
  80122a:	74 1a                	je     801246 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80122c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80122f:	89 02                	mov    %eax,(%edx)
	return 0;
  801231:	b8 00 00 00 00       	mov    $0x0,%eax
  801236:	eb 13                	jmp    80124b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801238:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80123d:	eb 0c                	jmp    80124b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80123f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801244:	eb 05                	jmp    80124b <fd_lookup+0x54>
  801246:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80124b:	5d                   	pop    %ebp
  80124c:	c3                   	ret    

0080124d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80124d:	55                   	push   %ebp
  80124e:	89 e5                	mov    %esp,%ebp
  801250:	83 ec 08             	sub    $0x8,%esp
  801253:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801256:	ba 44 2e 80 00       	mov    $0x802e44,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80125b:	eb 13                	jmp    801270 <dev_lookup+0x23>
  80125d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801260:	39 08                	cmp    %ecx,(%eax)
  801262:	75 0c                	jne    801270 <dev_lookup+0x23>
			*dev = devtab[i];
  801264:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801267:	89 01                	mov    %eax,(%ecx)
			return 0;
  801269:	b8 00 00 00 00       	mov    $0x0,%eax
  80126e:	eb 2e                	jmp    80129e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801270:	8b 02                	mov    (%edx),%eax
  801272:	85 c0                	test   %eax,%eax
  801274:	75 e7                	jne    80125d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801276:	a1 04 40 80 00       	mov    0x804004,%eax
  80127b:	8b 40 7c             	mov    0x7c(%eax),%eax
  80127e:	83 ec 04             	sub    $0x4,%esp
  801281:	51                   	push   %ecx
  801282:	50                   	push   %eax
  801283:	68 c8 2d 80 00       	push   $0x802dc8
  801288:	e8 47 f0 ff ff       	call   8002d4 <cprintf>
	*dev = 0;
  80128d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801290:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801296:	83 c4 10             	add    $0x10,%esp
  801299:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80129e:	c9                   	leave  
  80129f:	c3                   	ret    

008012a0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
  8012a3:	56                   	push   %esi
  8012a4:	53                   	push   %ebx
  8012a5:	83 ec 10             	sub    $0x10,%esp
  8012a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8012ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b1:	50                   	push   %eax
  8012b2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012b8:	c1 e8 0c             	shr    $0xc,%eax
  8012bb:	50                   	push   %eax
  8012bc:	e8 36 ff ff ff       	call   8011f7 <fd_lookup>
  8012c1:	83 c4 08             	add    $0x8,%esp
  8012c4:	85 c0                	test   %eax,%eax
  8012c6:	78 05                	js     8012cd <fd_close+0x2d>
	    || fd != fd2)
  8012c8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012cb:	74 0c                	je     8012d9 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012cd:	84 db                	test   %bl,%bl
  8012cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d4:	0f 44 c2             	cmove  %edx,%eax
  8012d7:	eb 41                	jmp    80131a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012d9:	83 ec 08             	sub    $0x8,%esp
  8012dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012df:	50                   	push   %eax
  8012e0:	ff 36                	pushl  (%esi)
  8012e2:	e8 66 ff ff ff       	call   80124d <dev_lookup>
  8012e7:	89 c3                	mov    %eax,%ebx
  8012e9:	83 c4 10             	add    $0x10,%esp
  8012ec:	85 c0                	test   %eax,%eax
  8012ee:	78 1a                	js     80130a <fd_close+0x6a>
		if (dev->dev_close)
  8012f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012f6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012fb:	85 c0                	test   %eax,%eax
  8012fd:	74 0b                	je     80130a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012ff:	83 ec 0c             	sub    $0xc,%esp
  801302:	56                   	push   %esi
  801303:	ff d0                	call   *%eax
  801305:	89 c3                	mov    %eax,%ebx
  801307:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80130a:	83 ec 08             	sub    $0x8,%esp
  80130d:	56                   	push   %esi
  80130e:	6a 00                	push   $0x0
  801310:	e8 cc f9 ff ff       	call   800ce1 <sys_page_unmap>
	return r;
  801315:	83 c4 10             	add    $0x10,%esp
  801318:	89 d8                	mov    %ebx,%eax
}
  80131a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80131d:	5b                   	pop    %ebx
  80131e:	5e                   	pop    %esi
  80131f:	5d                   	pop    %ebp
  801320:	c3                   	ret    

00801321 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801321:	55                   	push   %ebp
  801322:	89 e5                	mov    %esp,%ebp
  801324:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801327:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132a:	50                   	push   %eax
  80132b:	ff 75 08             	pushl  0x8(%ebp)
  80132e:	e8 c4 fe ff ff       	call   8011f7 <fd_lookup>
  801333:	83 c4 08             	add    $0x8,%esp
  801336:	85 c0                	test   %eax,%eax
  801338:	78 10                	js     80134a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80133a:	83 ec 08             	sub    $0x8,%esp
  80133d:	6a 01                	push   $0x1
  80133f:	ff 75 f4             	pushl  -0xc(%ebp)
  801342:	e8 59 ff ff ff       	call   8012a0 <fd_close>
  801347:	83 c4 10             	add    $0x10,%esp
}
  80134a:	c9                   	leave  
  80134b:	c3                   	ret    

0080134c <close_all>:

void
close_all(void)
{
  80134c:	55                   	push   %ebp
  80134d:	89 e5                	mov    %esp,%ebp
  80134f:	53                   	push   %ebx
  801350:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801353:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801358:	83 ec 0c             	sub    $0xc,%esp
  80135b:	53                   	push   %ebx
  80135c:	e8 c0 ff ff ff       	call   801321 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801361:	83 c3 01             	add    $0x1,%ebx
  801364:	83 c4 10             	add    $0x10,%esp
  801367:	83 fb 20             	cmp    $0x20,%ebx
  80136a:	75 ec                	jne    801358 <close_all+0xc>
		close(i);
}
  80136c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80136f:	c9                   	leave  
  801370:	c3                   	ret    

00801371 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801371:	55                   	push   %ebp
  801372:	89 e5                	mov    %esp,%ebp
  801374:	57                   	push   %edi
  801375:	56                   	push   %esi
  801376:	53                   	push   %ebx
  801377:	83 ec 2c             	sub    $0x2c,%esp
  80137a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80137d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801380:	50                   	push   %eax
  801381:	ff 75 08             	pushl  0x8(%ebp)
  801384:	e8 6e fe ff ff       	call   8011f7 <fd_lookup>
  801389:	83 c4 08             	add    $0x8,%esp
  80138c:	85 c0                	test   %eax,%eax
  80138e:	0f 88 c1 00 00 00    	js     801455 <dup+0xe4>
		return r;
	close(newfdnum);
  801394:	83 ec 0c             	sub    $0xc,%esp
  801397:	56                   	push   %esi
  801398:	e8 84 ff ff ff       	call   801321 <close>

	newfd = INDEX2FD(newfdnum);
  80139d:	89 f3                	mov    %esi,%ebx
  80139f:	c1 e3 0c             	shl    $0xc,%ebx
  8013a2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013a8:	83 c4 04             	add    $0x4,%esp
  8013ab:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013ae:	e8 de fd ff ff       	call   801191 <fd2data>
  8013b3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013b5:	89 1c 24             	mov    %ebx,(%esp)
  8013b8:	e8 d4 fd ff ff       	call   801191 <fd2data>
  8013bd:	83 c4 10             	add    $0x10,%esp
  8013c0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013c3:	89 f8                	mov    %edi,%eax
  8013c5:	c1 e8 16             	shr    $0x16,%eax
  8013c8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013cf:	a8 01                	test   $0x1,%al
  8013d1:	74 37                	je     80140a <dup+0x99>
  8013d3:	89 f8                	mov    %edi,%eax
  8013d5:	c1 e8 0c             	shr    $0xc,%eax
  8013d8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013df:	f6 c2 01             	test   $0x1,%dl
  8013e2:	74 26                	je     80140a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013e4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013eb:	83 ec 0c             	sub    $0xc,%esp
  8013ee:	25 07 0e 00 00       	and    $0xe07,%eax
  8013f3:	50                   	push   %eax
  8013f4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013f7:	6a 00                	push   $0x0
  8013f9:	57                   	push   %edi
  8013fa:	6a 00                	push   $0x0
  8013fc:	e8 9e f8 ff ff       	call   800c9f <sys_page_map>
  801401:	89 c7                	mov    %eax,%edi
  801403:	83 c4 20             	add    $0x20,%esp
  801406:	85 c0                	test   %eax,%eax
  801408:	78 2e                	js     801438 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80140a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80140d:	89 d0                	mov    %edx,%eax
  80140f:	c1 e8 0c             	shr    $0xc,%eax
  801412:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801419:	83 ec 0c             	sub    $0xc,%esp
  80141c:	25 07 0e 00 00       	and    $0xe07,%eax
  801421:	50                   	push   %eax
  801422:	53                   	push   %ebx
  801423:	6a 00                	push   $0x0
  801425:	52                   	push   %edx
  801426:	6a 00                	push   $0x0
  801428:	e8 72 f8 ff ff       	call   800c9f <sys_page_map>
  80142d:	89 c7                	mov    %eax,%edi
  80142f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801432:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801434:	85 ff                	test   %edi,%edi
  801436:	79 1d                	jns    801455 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801438:	83 ec 08             	sub    $0x8,%esp
  80143b:	53                   	push   %ebx
  80143c:	6a 00                	push   $0x0
  80143e:	e8 9e f8 ff ff       	call   800ce1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801443:	83 c4 08             	add    $0x8,%esp
  801446:	ff 75 d4             	pushl  -0x2c(%ebp)
  801449:	6a 00                	push   $0x0
  80144b:	e8 91 f8 ff ff       	call   800ce1 <sys_page_unmap>
	return r;
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	89 f8                	mov    %edi,%eax
}
  801455:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801458:	5b                   	pop    %ebx
  801459:	5e                   	pop    %esi
  80145a:	5f                   	pop    %edi
  80145b:	5d                   	pop    %ebp
  80145c:	c3                   	ret    

0080145d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80145d:	55                   	push   %ebp
  80145e:	89 e5                	mov    %esp,%ebp
  801460:	53                   	push   %ebx
  801461:	83 ec 14             	sub    $0x14,%esp
  801464:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801467:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80146a:	50                   	push   %eax
  80146b:	53                   	push   %ebx
  80146c:	e8 86 fd ff ff       	call   8011f7 <fd_lookup>
  801471:	83 c4 08             	add    $0x8,%esp
  801474:	89 c2                	mov    %eax,%edx
  801476:	85 c0                	test   %eax,%eax
  801478:	78 6d                	js     8014e7 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80147a:	83 ec 08             	sub    $0x8,%esp
  80147d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801480:	50                   	push   %eax
  801481:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801484:	ff 30                	pushl  (%eax)
  801486:	e8 c2 fd ff ff       	call   80124d <dev_lookup>
  80148b:	83 c4 10             	add    $0x10,%esp
  80148e:	85 c0                	test   %eax,%eax
  801490:	78 4c                	js     8014de <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801492:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801495:	8b 42 08             	mov    0x8(%edx),%eax
  801498:	83 e0 03             	and    $0x3,%eax
  80149b:	83 f8 01             	cmp    $0x1,%eax
  80149e:	75 21                	jne    8014c1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014a0:	a1 04 40 80 00       	mov    0x804004,%eax
  8014a5:	8b 40 7c             	mov    0x7c(%eax),%eax
  8014a8:	83 ec 04             	sub    $0x4,%esp
  8014ab:	53                   	push   %ebx
  8014ac:	50                   	push   %eax
  8014ad:	68 09 2e 80 00       	push   $0x802e09
  8014b2:	e8 1d ee ff ff       	call   8002d4 <cprintf>
		return -E_INVAL;
  8014b7:	83 c4 10             	add    $0x10,%esp
  8014ba:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014bf:	eb 26                	jmp    8014e7 <read+0x8a>
	}
	if (!dev->dev_read)
  8014c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c4:	8b 40 08             	mov    0x8(%eax),%eax
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	74 17                	je     8014e2 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8014cb:	83 ec 04             	sub    $0x4,%esp
  8014ce:	ff 75 10             	pushl  0x10(%ebp)
  8014d1:	ff 75 0c             	pushl  0xc(%ebp)
  8014d4:	52                   	push   %edx
  8014d5:	ff d0                	call   *%eax
  8014d7:	89 c2                	mov    %eax,%edx
  8014d9:	83 c4 10             	add    $0x10,%esp
  8014dc:	eb 09                	jmp    8014e7 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014de:	89 c2                	mov    %eax,%edx
  8014e0:	eb 05                	jmp    8014e7 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014e2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8014e7:	89 d0                	mov    %edx,%eax
  8014e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ec:	c9                   	leave  
  8014ed:	c3                   	ret    

008014ee <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014ee:	55                   	push   %ebp
  8014ef:	89 e5                	mov    %esp,%ebp
  8014f1:	57                   	push   %edi
  8014f2:	56                   	push   %esi
  8014f3:	53                   	push   %ebx
  8014f4:	83 ec 0c             	sub    $0xc,%esp
  8014f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014fa:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014fd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801502:	eb 21                	jmp    801525 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801504:	83 ec 04             	sub    $0x4,%esp
  801507:	89 f0                	mov    %esi,%eax
  801509:	29 d8                	sub    %ebx,%eax
  80150b:	50                   	push   %eax
  80150c:	89 d8                	mov    %ebx,%eax
  80150e:	03 45 0c             	add    0xc(%ebp),%eax
  801511:	50                   	push   %eax
  801512:	57                   	push   %edi
  801513:	e8 45 ff ff ff       	call   80145d <read>
		if (m < 0)
  801518:	83 c4 10             	add    $0x10,%esp
  80151b:	85 c0                	test   %eax,%eax
  80151d:	78 10                	js     80152f <readn+0x41>
			return m;
		if (m == 0)
  80151f:	85 c0                	test   %eax,%eax
  801521:	74 0a                	je     80152d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801523:	01 c3                	add    %eax,%ebx
  801525:	39 f3                	cmp    %esi,%ebx
  801527:	72 db                	jb     801504 <readn+0x16>
  801529:	89 d8                	mov    %ebx,%eax
  80152b:	eb 02                	jmp    80152f <readn+0x41>
  80152d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80152f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801532:	5b                   	pop    %ebx
  801533:	5e                   	pop    %esi
  801534:	5f                   	pop    %edi
  801535:	5d                   	pop    %ebp
  801536:	c3                   	ret    

00801537 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801537:	55                   	push   %ebp
  801538:	89 e5                	mov    %esp,%ebp
  80153a:	53                   	push   %ebx
  80153b:	83 ec 14             	sub    $0x14,%esp
  80153e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801541:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801544:	50                   	push   %eax
  801545:	53                   	push   %ebx
  801546:	e8 ac fc ff ff       	call   8011f7 <fd_lookup>
  80154b:	83 c4 08             	add    $0x8,%esp
  80154e:	89 c2                	mov    %eax,%edx
  801550:	85 c0                	test   %eax,%eax
  801552:	78 68                	js     8015bc <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801554:	83 ec 08             	sub    $0x8,%esp
  801557:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155a:	50                   	push   %eax
  80155b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155e:	ff 30                	pushl  (%eax)
  801560:	e8 e8 fc ff ff       	call   80124d <dev_lookup>
  801565:	83 c4 10             	add    $0x10,%esp
  801568:	85 c0                	test   %eax,%eax
  80156a:	78 47                	js     8015b3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80156c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801573:	75 21                	jne    801596 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801575:	a1 04 40 80 00       	mov    0x804004,%eax
  80157a:	8b 40 7c             	mov    0x7c(%eax),%eax
  80157d:	83 ec 04             	sub    $0x4,%esp
  801580:	53                   	push   %ebx
  801581:	50                   	push   %eax
  801582:	68 25 2e 80 00       	push   $0x802e25
  801587:	e8 48 ed ff ff       	call   8002d4 <cprintf>
		return -E_INVAL;
  80158c:	83 c4 10             	add    $0x10,%esp
  80158f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801594:	eb 26                	jmp    8015bc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801596:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801599:	8b 52 0c             	mov    0xc(%edx),%edx
  80159c:	85 d2                	test   %edx,%edx
  80159e:	74 17                	je     8015b7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015a0:	83 ec 04             	sub    $0x4,%esp
  8015a3:	ff 75 10             	pushl  0x10(%ebp)
  8015a6:	ff 75 0c             	pushl  0xc(%ebp)
  8015a9:	50                   	push   %eax
  8015aa:	ff d2                	call   *%edx
  8015ac:	89 c2                	mov    %eax,%edx
  8015ae:	83 c4 10             	add    $0x10,%esp
  8015b1:	eb 09                	jmp    8015bc <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b3:	89 c2                	mov    %eax,%edx
  8015b5:	eb 05                	jmp    8015bc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015b7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015bc:	89 d0                	mov    %edx,%eax
  8015be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c1:	c9                   	leave  
  8015c2:	c3                   	ret    

008015c3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015c3:	55                   	push   %ebp
  8015c4:	89 e5                	mov    %esp,%ebp
  8015c6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015c9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015cc:	50                   	push   %eax
  8015cd:	ff 75 08             	pushl  0x8(%ebp)
  8015d0:	e8 22 fc ff ff       	call   8011f7 <fd_lookup>
  8015d5:	83 c4 08             	add    $0x8,%esp
  8015d8:	85 c0                	test   %eax,%eax
  8015da:	78 0e                	js     8015ea <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015e2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015ea:	c9                   	leave  
  8015eb:	c3                   	ret    

008015ec <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
  8015ef:	53                   	push   %ebx
  8015f0:	83 ec 14             	sub    $0x14,%esp
  8015f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f9:	50                   	push   %eax
  8015fa:	53                   	push   %ebx
  8015fb:	e8 f7 fb ff ff       	call   8011f7 <fd_lookup>
  801600:	83 c4 08             	add    $0x8,%esp
  801603:	89 c2                	mov    %eax,%edx
  801605:	85 c0                	test   %eax,%eax
  801607:	78 65                	js     80166e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801609:	83 ec 08             	sub    $0x8,%esp
  80160c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160f:	50                   	push   %eax
  801610:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801613:	ff 30                	pushl  (%eax)
  801615:	e8 33 fc ff ff       	call   80124d <dev_lookup>
  80161a:	83 c4 10             	add    $0x10,%esp
  80161d:	85 c0                	test   %eax,%eax
  80161f:	78 44                	js     801665 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801621:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801624:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801628:	75 21                	jne    80164b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80162a:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80162f:	8b 40 7c             	mov    0x7c(%eax),%eax
  801632:	83 ec 04             	sub    $0x4,%esp
  801635:	53                   	push   %ebx
  801636:	50                   	push   %eax
  801637:	68 e8 2d 80 00       	push   $0x802de8
  80163c:	e8 93 ec ff ff       	call   8002d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801641:	83 c4 10             	add    $0x10,%esp
  801644:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801649:	eb 23                	jmp    80166e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80164b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80164e:	8b 52 18             	mov    0x18(%edx),%edx
  801651:	85 d2                	test   %edx,%edx
  801653:	74 14                	je     801669 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801655:	83 ec 08             	sub    $0x8,%esp
  801658:	ff 75 0c             	pushl  0xc(%ebp)
  80165b:	50                   	push   %eax
  80165c:	ff d2                	call   *%edx
  80165e:	89 c2                	mov    %eax,%edx
  801660:	83 c4 10             	add    $0x10,%esp
  801663:	eb 09                	jmp    80166e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801665:	89 c2                	mov    %eax,%edx
  801667:	eb 05                	jmp    80166e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801669:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80166e:	89 d0                	mov    %edx,%eax
  801670:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801673:	c9                   	leave  
  801674:	c3                   	ret    

00801675 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
  801678:	53                   	push   %ebx
  801679:	83 ec 14             	sub    $0x14,%esp
  80167c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80167f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801682:	50                   	push   %eax
  801683:	ff 75 08             	pushl  0x8(%ebp)
  801686:	e8 6c fb ff ff       	call   8011f7 <fd_lookup>
  80168b:	83 c4 08             	add    $0x8,%esp
  80168e:	89 c2                	mov    %eax,%edx
  801690:	85 c0                	test   %eax,%eax
  801692:	78 58                	js     8016ec <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801694:	83 ec 08             	sub    $0x8,%esp
  801697:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80169a:	50                   	push   %eax
  80169b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169e:	ff 30                	pushl  (%eax)
  8016a0:	e8 a8 fb ff ff       	call   80124d <dev_lookup>
  8016a5:	83 c4 10             	add    $0x10,%esp
  8016a8:	85 c0                	test   %eax,%eax
  8016aa:	78 37                	js     8016e3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016af:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016b3:	74 32                	je     8016e7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016b5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016b8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016bf:	00 00 00 
	stat->st_isdir = 0;
  8016c2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016c9:	00 00 00 
	stat->st_dev = dev;
  8016cc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016d2:	83 ec 08             	sub    $0x8,%esp
  8016d5:	53                   	push   %ebx
  8016d6:	ff 75 f0             	pushl  -0x10(%ebp)
  8016d9:	ff 50 14             	call   *0x14(%eax)
  8016dc:	89 c2                	mov    %eax,%edx
  8016de:	83 c4 10             	add    $0x10,%esp
  8016e1:	eb 09                	jmp    8016ec <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e3:	89 c2                	mov    %eax,%edx
  8016e5:	eb 05                	jmp    8016ec <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016e7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016ec:	89 d0                	mov    %edx,%eax
  8016ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f1:	c9                   	leave  
  8016f2:	c3                   	ret    

008016f3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016f3:	55                   	push   %ebp
  8016f4:	89 e5                	mov    %esp,%ebp
  8016f6:	56                   	push   %esi
  8016f7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016f8:	83 ec 08             	sub    $0x8,%esp
  8016fb:	6a 00                	push   $0x0
  8016fd:	ff 75 08             	pushl  0x8(%ebp)
  801700:	e8 e3 01 00 00       	call   8018e8 <open>
  801705:	89 c3                	mov    %eax,%ebx
  801707:	83 c4 10             	add    $0x10,%esp
  80170a:	85 c0                	test   %eax,%eax
  80170c:	78 1b                	js     801729 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80170e:	83 ec 08             	sub    $0x8,%esp
  801711:	ff 75 0c             	pushl  0xc(%ebp)
  801714:	50                   	push   %eax
  801715:	e8 5b ff ff ff       	call   801675 <fstat>
  80171a:	89 c6                	mov    %eax,%esi
	close(fd);
  80171c:	89 1c 24             	mov    %ebx,(%esp)
  80171f:	e8 fd fb ff ff       	call   801321 <close>
	return r;
  801724:	83 c4 10             	add    $0x10,%esp
  801727:	89 f0                	mov    %esi,%eax
}
  801729:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80172c:	5b                   	pop    %ebx
  80172d:	5e                   	pop    %esi
  80172e:	5d                   	pop    %ebp
  80172f:	c3                   	ret    

00801730 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	56                   	push   %esi
  801734:	53                   	push   %ebx
  801735:	89 c6                	mov    %eax,%esi
  801737:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801739:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801740:	75 12                	jne    801754 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801742:	83 ec 0c             	sub    $0xc,%esp
  801745:	6a 01                	push   $0x1
  801747:	e8 ce 0e 00 00       	call   80261a <ipc_find_env>
  80174c:	a3 00 40 80 00       	mov    %eax,0x804000
  801751:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801754:	6a 07                	push   $0x7
  801756:	68 00 50 80 00       	push   $0x805000
  80175b:	56                   	push   %esi
  80175c:	ff 35 00 40 80 00    	pushl  0x804000
  801762:	e8 51 0e 00 00       	call   8025b8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801767:	83 c4 0c             	add    $0xc,%esp
  80176a:	6a 00                	push   $0x0
  80176c:	53                   	push   %ebx
  80176d:	6a 00                	push   $0x0
  80176f:	e8 c9 0d 00 00       	call   80253d <ipc_recv>
}
  801774:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801777:	5b                   	pop    %ebx
  801778:	5e                   	pop    %esi
  801779:	5d                   	pop    %ebp
  80177a:	c3                   	ret    

0080177b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80177b:	55                   	push   %ebp
  80177c:	89 e5                	mov    %esp,%ebp
  80177e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801781:	8b 45 08             	mov    0x8(%ebp),%eax
  801784:	8b 40 0c             	mov    0xc(%eax),%eax
  801787:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80178c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80178f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801794:	ba 00 00 00 00       	mov    $0x0,%edx
  801799:	b8 02 00 00 00       	mov    $0x2,%eax
  80179e:	e8 8d ff ff ff       	call   801730 <fsipc>
}
  8017a3:	c9                   	leave  
  8017a4:	c3                   	ret    

008017a5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017a5:	55                   	push   %ebp
  8017a6:	89 e5                	mov    %esp,%ebp
  8017a8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017bb:	b8 06 00 00 00       	mov    $0x6,%eax
  8017c0:	e8 6b ff ff ff       	call   801730 <fsipc>
}
  8017c5:	c9                   	leave  
  8017c6:	c3                   	ret    

008017c7 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	53                   	push   %ebx
  8017cb:	83 ec 04             	sub    $0x4,%esp
  8017ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d4:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e1:	b8 05 00 00 00       	mov    $0x5,%eax
  8017e6:	e8 45 ff ff ff       	call   801730 <fsipc>
  8017eb:	85 c0                	test   %eax,%eax
  8017ed:	78 2c                	js     80181b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017ef:	83 ec 08             	sub    $0x8,%esp
  8017f2:	68 00 50 80 00       	push   $0x805000
  8017f7:	53                   	push   %ebx
  8017f8:	e8 5c f0 ff ff       	call   800859 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017fd:	a1 80 50 80 00       	mov    0x805080,%eax
  801802:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801808:	a1 84 50 80 00       	mov    0x805084,%eax
  80180d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801813:	83 c4 10             	add    $0x10,%esp
  801816:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80181b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80181e:	c9                   	leave  
  80181f:	c3                   	ret    

00801820 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	83 ec 0c             	sub    $0xc,%esp
  801826:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801829:	8b 55 08             	mov    0x8(%ebp),%edx
  80182c:	8b 52 0c             	mov    0xc(%edx),%edx
  80182f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801835:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80183a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80183f:	0f 47 c2             	cmova  %edx,%eax
  801842:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801847:	50                   	push   %eax
  801848:	ff 75 0c             	pushl  0xc(%ebp)
  80184b:	68 08 50 80 00       	push   $0x805008
  801850:	e8 96 f1 ff ff       	call   8009eb <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801855:	ba 00 00 00 00       	mov    $0x0,%edx
  80185a:	b8 04 00 00 00       	mov    $0x4,%eax
  80185f:	e8 cc fe ff ff       	call   801730 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801864:	c9                   	leave  
  801865:	c3                   	ret    

00801866 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801866:	55                   	push   %ebp
  801867:	89 e5                	mov    %esp,%ebp
  801869:	56                   	push   %esi
  80186a:	53                   	push   %ebx
  80186b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80186e:	8b 45 08             	mov    0x8(%ebp),%eax
  801871:	8b 40 0c             	mov    0xc(%eax),%eax
  801874:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801879:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80187f:	ba 00 00 00 00       	mov    $0x0,%edx
  801884:	b8 03 00 00 00       	mov    $0x3,%eax
  801889:	e8 a2 fe ff ff       	call   801730 <fsipc>
  80188e:	89 c3                	mov    %eax,%ebx
  801890:	85 c0                	test   %eax,%eax
  801892:	78 4b                	js     8018df <devfile_read+0x79>
		return r;
	assert(r <= n);
  801894:	39 c6                	cmp    %eax,%esi
  801896:	73 16                	jae    8018ae <devfile_read+0x48>
  801898:	68 54 2e 80 00       	push   $0x802e54
  80189d:	68 5b 2e 80 00       	push   $0x802e5b
  8018a2:	6a 7c                	push   $0x7c
  8018a4:	68 70 2e 80 00       	push   $0x802e70
  8018a9:	e8 4d e9 ff ff       	call   8001fb <_panic>
	assert(r <= PGSIZE);
  8018ae:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018b3:	7e 16                	jle    8018cb <devfile_read+0x65>
  8018b5:	68 7b 2e 80 00       	push   $0x802e7b
  8018ba:	68 5b 2e 80 00       	push   $0x802e5b
  8018bf:	6a 7d                	push   $0x7d
  8018c1:	68 70 2e 80 00       	push   $0x802e70
  8018c6:	e8 30 e9 ff ff       	call   8001fb <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018cb:	83 ec 04             	sub    $0x4,%esp
  8018ce:	50                   	push   %eax
  8018cf:	68 00 50 80 00       	push   $0x805000
  8018d4:	ff 75 0c             	pushl  0xc(%ebp)
  8018d7:	e8 0f f1 ff ff       	call   8009eb <memmove>
	return r;
  8018dc:	83 c4 10             	add    $0x10,%esp
}
  8018df:	89 d8                	mov    %ebx,%eax
  8018e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e4:	5b                   	pop    %ebx
  8018e5:	5e                   	pop    %esi
  8018e6:	5d                   	pop    %ebp
  8018e7:	c3                   	ret    

008018e8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018e8:	55                   	push   %ebp
  8018e9:	89 e5                	mov    %esp,%ebp
  8018eb:	53                   	push   %ebx
  8018ec:	83 ec 20             	sub    $0x20,%esp
  8018ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018f2:	53                   	push   %ebx
  8018f3:	e8 28 ef ff ff       	call   800820 <strlen>
  8018f8:	83 c4 10             	add    $0x10,%esp
  8018fb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801900:	7f 67                	jg     801969 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801902:	83 ec 0c             	sub    $0xc,%esp
  801905:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801908:	50                   	push   %eax
  801909:	e8 9a f8 ff ff       	call   8011a8 <fd_alloc>
  80190e:	83 c4 10             	add    $0x10,%esp
		return r;
  801911:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801913:	85 c0                	test   %eax,%eax
  801915:	78 57                	js     80196e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801917:	83 ec 08             	sub    $0x8,%esp
  80191a:	53                   	push   %ebx
  80191b:	68 00 50 80 00       	push   $0x805000
  801920:	e8 34 ef ff ff       	call   800859 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801925:	8b 45 0c             	mov    0xc(%ebp),%eax
  801928:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80192d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801930:	b8 01 00 00 00       	mov    $0x1,%eax
  801935:	e8 f6 fd ff ff       	call   801730 <fsipc>
  80193a:	89 c3                	mov    %eax,%ebx
  80193c:	83 c4 10             	add    $0x10,%esp
  80193f:	85 c0                	test   %eax,%eax
  801941:	79 14                	jns    801957 <open+0x6f>
		fd_close(fd, 0);
  801943:	83 ec 08             	sub    $0x8,%esp
  801946:	6a 00                	push   $0x0
  801948:	ff 75 f4             	pushl  -0xc(%ebp)
  80194b:	e8 50 f9 ff ff       	call   8012a0 <fd_close>
		return r;
  801950:	83 c4 10             	add    $0x10,%esp
  801953:	89 da                	mov    %ebx,%edx
  801955:	eb 17                	jmp    80196e <open+0x86>
	}

	return fd2num(fd);
  801957:	83 ec 0c             	sub    $0xc,%esp
  80195a:	ff 75 f4             	pushl  -0xc(%ebp)
  80195d:	e8 1f f8 ff ff       	call   801181 <fd2num>
  801962:	89 c2                	mov    %eax,%edx
  801964:	83 c4 10             	add    $0x10,%esp
  801967:	eb 05                	jmp    80196e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801969:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80196e:	89 d0                	mov    %edx,%eax
  801970:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801973:	c9                   	leave  
  801974:	c3                   	ret    

00801975 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801975:	55                   	push   %ebp
  801976:	89 e5                	mov    %esp,%ebp
  801978:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80197b:	ba 00 00 00 00       	mov    $0x0,%edx
  801980:	b8 08 00 00 00       	mov    $0x8,%eax
  801985:	e8 a6 fd ff ff       	call   801730 <fsipc>
}
  80198a:	c9                   	leave  
  80198b:	c3                   	ret    

0080198c <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80198c:	55                   	push   %ebp
  80198d:	89 e5                	mov    %esp,%ebp
  80198f:	57                   	push   %edi
  801990:	56                   	push   %esi
  801991:	53                   	push   %ebx
  801992:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801998:	6a 00                	push   $0x0
  80199a:	ff 75 08             	pushl  0x8(%ebp)
  80199d:	e8 46 ff ff ff       	call   8018e8 <open>
  8019a2:	89 c7                	mov    %eax,%edi
  8019a4:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8019aa:	83 c4 10             	add    $0x10,%esp
  8019ad:	85 c0                	test   %eax,%eax
  8019af:	0f 88 8c 04 00 00    	js     801e41 <spawn+0x4b5>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8019b5:	83 ec 04             	sub    $0x4,%esp
  8019b8:	68 00 02 00 00       	push   $0x200
  8019bd:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8019c3:	50                   	push   %eax
  8019c4:	57                   	push   %edi
  8019c5:	e8 24 fb ff ff       	call   8014ee <readn>
  8019ca:	83 c4 10             	add    $0x10,%esp
  8019cd:	3d 00 02 00 00       	cmp    $0x200,%eax
  8019d2:	75 0c                	jne    8019e0 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8019d4:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8019db:	45 4c 46 
  8019de:	74 33                	je     801a13 <spawn+0x87>
		close(fd);
  8019e0:	83 ec 0c             	sub    $0xc,%esp
  8019e3:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019e9:	e8 33 f9 ff ff       	call   801321 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8019ee:	83 c4 0c             	add    $0xc,%esp
  8019f1:	68 7f 45 4c 46       	push   $0x464c457f
  8019f6:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8019fc:	68 87 2e 80 00       	push   $0x802e87
  801a01:	e8 ce e8 ff ff       	call   8002d4 <cprintf>
		return -E_NOT_EXEC;
  801a06:	83 c4 10             	add    $0x10,%esp
  801a09:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801a0e:	e9 e1 04 00 00       	jmp    801ef4 <spawn+0x568>
  801a13:	b8 07 00 00 00       	mov    $0x7,%eax
  801a18:	cd 30                	int    $0x30
  801a1a:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801a20:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801a26:	85 c0                	test   %eax,%eax
  801a28:	0f 88 1e 04 00 00    	js     801e4c <spawn+0x4c0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801a2e:	89 c6                	mov    %eax,%esi
  801a30:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801a36:	69 f6 b0 00 00 00    	imul   $0xb0,%esi,%esi
  801a3c:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801a42:	81 c6 34 00 c0 ee    	add    $0xeec00034,%esi
  801a48:	b9 11 00 00 00       	mov    $0x11,%ecx
  801a4d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801a4f:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801a55:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a5b:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801a60:	be 00 00 00 00       	mov    $0x0,%esi
  801a65:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a68:	eb 13                	jmp    801a7d <spawn+0xf1>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801a6a:	83 ec 0c             	sub    $0xc,%esp
  801a6d:	50                   	push   %eax
  801a6e:	e8 ad ed ff ff       	call   800820 <strlen>
  801a73:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a77:	83 c3 01             	add    $0x1,%ebx
  801a7a:	83 c4 10             	add    $0x10,%esp
  801a7d:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801a84:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801a87:	85 c0                	test   %eax,%eax
  801a89:	75 df                	jne    801a6a <spawn+0xde>
  801a8b:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801a91:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801a97:	bf 00 10 40 00       	mov    $0x401000,%edi
  801a9c:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801a9e:	89 fa                	mov    %edi,%edx
  801aa0:	83 e2 fc             	and    $0xfffffffc,%edx
  801aa3:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801aaa:	29 c2                	sub    %eax,%edx
  801aac:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801ab2:	8d 42 f8             	lea    -0x8(%edx),%eax
  801ab5:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801aba:	0f 86 a2 03 00 00    	jbe    801e62 <spawn+0x4d6>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ac0:	83 ec 04             	sub    $0x4,%esp
  801ac3:	6a 07                	push   $0x7
  801ac5:	68 00 00 40 00       	push   $0x400000
  801aca:	6a 00                	push   $0x0
  801acc:	e8 8b f1 ff ff       	call   800c5c <sys_page_alloc>
  801ad1:	83 c4 10             	add    $0x10,%esp
  801ad4:	85 c0                	test   %eax,%eax
  801ad6:	0f 88 90 03 00 00    	js     801e6c <spawn+0x4e0>
  801adc:	be 00 00 00 00       	mov    $0x0,%esi
  801ae1:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801ae7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801aea:	eb 30                	jmp    801b1c <spawn+0x190>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801aec:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801af2:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801af8:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801afb:	83 ec 08             	sub    $0x8,%esp
  801afe:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801b01:	57                   	push   %edi
  801b02:	e8 52 ed ff ff       	call   800859 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801b07:	83 c4 04             	add    $0x4,%esp
  801b0a:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801b0d:	e8 0e ed ff ff       	call   800820 <strlen>
  801b12:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801b16:	83 c6 01             	add    $0x1,%esi
  801b19:	83 c4 10             	add    $0x10,%esp
  801b1c:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801b22:	7f c8                	jg     801aec <spawn+0x160>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801b24:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801b2a:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801b30:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801b37:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801b3d:	74 19                	je     801b58 <spawn+0x1cc>
  801b3f:	68 14 2f 80 00       	push   $0x802f14
  801b44:	68 5b 2e 80 00       	push   $0x802e5b
  801b49:	68 f2 00 00 00       	push   $0xf2
  801b4e:	68 a1 2e 80 00       	push   $0x802ea1
  801b53:	e8 a3 e6 ff ff       	call   8001fb <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801b58:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801b5e:	89 f8                	mov    %edi,%eax
  801b60:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801b65:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801b68:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b6e:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801b71:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801b77:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801b7d:	83 ec 0c             	sub    $0xc,%esp
  801b80:	6a 07                	push   $0x7
  801b82:	68 00 d0 bf ee       	push   $0xeebfd000
  801b87:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b8d:	68 00 00 40 00       	push   $0x400000
  801b92:	6a 00                	push   $0x0
  801b94:	e8 06 f1 ff ff       	call   800c9f <sys_page_map>
  801b99:	89 c3                	mov    %eax,%ebx
  801b9b:	83 c4 20             	add    $0x20,%esp
  801b9e:	85 c0                	test   %eax,%eax
  801ba0:	0f 88 3c 03 00 00    	js     801ee2 <spawn+0x556>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801ba6:	83 ec 08             	sub    $0x8,%esp
  801ba9:	68 00 00 40 00       	push   $0x400000
  801bae:	6a 00                	push   $0x0
  801bb0:	e8 2c f1 ff ff       	call   800ce1 <sys_page_unmap>
  801bb5:	89 c3                	mov    %eax,%ebx
  801bb7:	83 c4 10             	add    $0x10,%esp
  801bba:	85 c0                	test   %eax,%eax
  801bbc:	0f 88 20 03 00 00    	js     801ee2 <spawn+0x556>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801bc2:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801bc8:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801bcf:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801bd5:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801bdc:	00 00 00 
  801bdf:	e9 88 01 00 00       	jmp    801d6c <spawn+0x3e0>
		if (ph->p_type != ELF_PROG_LOAD)
  801be4:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801bea:	83 38 01             	cmpl   $0x1,(%eax)
  801bed:	0f 85 6b 01 00 00    	jne    801d5e <spawn+0x3d2>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801bf3:	89 c2                	mov    %eax,%edx
  801bf5:	8b 40 18             	mov    0x18(%eax),%eax
  801bf8:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801bfe:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801c01:	83 f8 01             	cmp    $0x1,%eax
  801c04:	19 c0                	sbb    %eax,%eax
  801c06:	83 e0 fe             	and    $0xfffffffe,%eax
  801c09:	83 c0 07             	add    $0x7,%eax
  801c0c:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801c12:	89 d0                	mov    %edx,%eax
  801c14:	8b 7a 04             	mov    0x4(%edx),%edi
  801c17:	89 f9                	mov    %edi,%ecx
  801c19:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801c1f:	8b 7a 10             	mov    0x10(%edx),%edi
  801c22:	8b 52 14             	mov    0x14(%edx),%edx
  801c25:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801c2b:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801c2e:	89 f0                	mov    %esi,%eax
  801c30:	25 ff 0f 00 00       	and    $0xfff,%eax
  801c35:	74 14                	je     801c4b <spawn+0x2bf>
		va -= i;
  801c37:	29 c6                	sub    %eax,%esi
		memsz += i;
  801c39:	01 c2                	add    %eax,%edx
  801c3b:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801c41:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801c43:	29 c1                	sub    %eax,%ecx
  801c45:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c50:	e9 f7 00 00 00       	jmp    801d4c <spawn+0x3c0>
		if (i >= filesz) {
  801c55:	39 fb                	cmp    %edi,%ebx
  801c57:	72 27                	jb     801c80 <spawn+0x2f4>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801c59:	83 ec 04             	sub    $0x4,%esp
  801c5c:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c62:	56                   	push   %esi
  801c63:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c69:	e8 ee ef ff ff       	call   800c5c <sys_page_alloc>
  801c6e:	83 c4 10             	add    $0x10,%esp
  801c71:	85 c0                	test   %eax,%eax
  801c73:	0f 89 c7 00 00 00    	jns    801d40 <spawn+0x3b4>
  801c79:	89 c3                	mov    %eax,%ebx
  801c7b:	e9 fd 01 00 00       	jmp    801e7d <spawn+0x4f1>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801c80:	83 ec 04             	sub    $0x4,%esp
  801c83:	6a 07                	push   $0x7
  801c85:	68 00 00 40 00       	push   $0x400000
  801c8a:	6a 00                	push   $0x0
  801c8c:	e8 cb ef ff ff       	call   800c5c <sys_page_alloc>
  801c91:	83 c4 10             	add    $0x10,%esp
  801c94:	85 c0                	test   %eax,%eax
  801c96:	0f 88 d7 01 00 00    	js     801e73 <spawn+0x4e7>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801c9c:	83 ec 08             	sub    $0x8,%esp
  801c9f:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801ca5:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801cab:	50                   	push   %eax
  801cac:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801cb2:	e8 0c f9 ff ff       	call   8015c3 <seek>
  801cb7:	83 c4 10             	add    $0x10,%esp
  801cba:	85 c0                	test   %eax,%eax
  801cbc:	0f 88 b5 01 00 00    	js     801e77 <spawn+0x4eb>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801cc2:	83 ec 04             	sub    $0x4,%esp
  801cc5:	89 f8                	mov    %edi,%eax
  801cc7:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801ccd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801cd2:	ba 00 10 00 00       	mov    $0x1000,%edx
  801cd7:	0f 47 c2             	cmova  %edx,%eax
  801cda:	50                   	push   %eax
  801cdb:	68 00 00 40 00       	push   $0x400000
  801ce0:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ce6:	e8 03 f8 ff ff       	call   8014ee <readn>
  801ceb:	83 c4 10             	add    $0x10,%esp
  801cee:	85 c0                	test   %eax,%eax
  801cf0:	0f 88 85 01 00 00    	js     801e7b <spawn+0x4ef>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801cf6:	83 ec 0c             	sub    $0xc,%esp
  801cf9:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801cff:	56                   	push   %esi
  801d00:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801d06:	68 00 00 40 00       	push   $0x400000
  801d0b:	6a 00                	push   $0x0
  801d0d:	e8 8d ef ff ff       	call   800c9f <sys_page_map>
  801d12:	83 c4 20             	add    $0x20,%esp
  801d15:	85 c0                	test   %eax,%eax
  801d17:	79 15                	jns    801d2e <spawn+0x3a2>
				panic("spawn: sys_page_map data: %e", r);
  801d19:	50                   	push   %eax
  801d1a:	68 ad 2e 80 00       	push   $0x802ead
  801d1f:	68 25 01 00 00       	push   $0x125
  801d24:	68 a1 2e 80 00       	push   $0x802ea1
  801d29:	e8 cd e4 ff ff       	call   8001fb <_panic>
			sys_page_unmap(0, UTEMP);
  801d2e:	83 ec 08             	sub    $0x8,%esp
  801d31:	68 00 00 40 00       	push   $0x400000
  801d36:	6a 00                	push   $0x0
  801d38:	e8 a4 ef ff ff       	call   800ce1 <sys_page_unmap>
  801d3d:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801d40:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d46:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801d4c:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801d52:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801d58:	0f 82 f7 fe ff ff    	jb     801c55 <spawn+0x2c9>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d5e:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801d65:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801d6c:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801d73:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801d79:	0f 8c 65 fe ff ff    	jl     801be4 <spawn+0x258>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801d7f:	83 ec 0c             	sub    $0xc,%esp
  801d82:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d88:	e8 94 f5 ff ff       	call   801321 <close>
  801d8d:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801d90:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d95:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801d9b:	89 d8                	mov    %ebx,%eax
  801d9d:	c1 e8 16             	shr    $0x16,%eax
  801da0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801da7:	a8 01                	test   $0x1,%al
  801da9:	74 42                	je     801ded <spawn+0x461>
  801dab:	89 d8                	mov    %ebx,%eax
  801dad:	c1 e8 0c             	shr    $0xc,%eax
  801db0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801db7:	f6 c2 01             	test   $0x1,%dl
  801dba:	74 31                	je     801ded <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  801dbc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801dc3:	f6 c6 04             	test   $0x4,%dh
  801dc6:	74 25                	je     801ded <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  801dc8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801dcf:	83 ec 0c             	sub    $0xc,%esp
  801dd2:	25 07 0e 00 00       	and    $0xe07,%eax
  801dd7:	50                   	push   %eax
  801dd8:	53                   	push   %ebx
  801dd9:	56                   	push   %esi
  801dda:	53                   	push   %ebx
  801ddb:	6a 00                	push   $0x0
  801ddd:	e8 bd ee ff ff       	call   800c9f <sys_page_map>
			if (r < 0) {
  801de2:	83 c4 20             	add    $0x20,%esp
  801de5:	85 c0                	test   %eax,%eax
  801de7:	0f 88 b1 00 00 00    	js     801e9e <spawn+0x512>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801ded:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801df3:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801df9:	75 a0                	jne    801d9b <spawn+0x40f>
  801dfb:	e9 b3 00 00 00       	jmp    801eb3 <spawn+0x527>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801e00:	50                   	push   %eax
  801e01:	68 ca 2e 80 00       	push   $0x802eca
  801e06:	68 86 00 00 00       	push   $0x86
  801e0b:	68 a1 2e 80 00       	push   $0x802ea1
  801e10:	e8 e6 e3 ff ff       	call   8001fb <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801e15:	83 ec 08             	sub    $0x8,%esp
  801e18:	6a 02                	push   $0x2
  801e1a:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e20:	e8 fe ee ff ff       	call   800d23 <sys_env_set_status>
  801e25:	83 c4 10             	add    $0x10,%esp
  801e28:	85 c0                	test   %eax,%eax
  801e2a:	79 2b                	jns    801e57 <spawn+0x4cb>
		panic("sys_env_set_status: %e", r);
  801e2c:	50                   	push   %eax
  801e2d:	68 e4 2e 80 00       	push   $0x802ee4
  801e32:	68 89 00 00 00       	push   $0x89
  801e37:	68 a1 2e 80 00       	push   $0x802ea1
  801e3c:	e8 ba e3 ff ff       	call   8001fb <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801e41:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801e47:	e9 a8 00 00 00       	jmp    801ef4 <spawn+0x568>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801e4c:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e52:	e9 9d 00 00 00       	jmp    801ef4 <spawn+0x568>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801e57:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e5d:	e9 92 00 00 00       	jmp    801ef4 <spawn+0x568>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801e62:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801e67:	e9 88 00 00 00       	jmp    801ef4 <spawn+0x568>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801e6c:	89 c3                	mov    %eax,%ebx
  801e6e:	e9 81 00 00 00       	jmp    801ef4 <spawn+0x568>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e73:	89 c3                	mov    %eax,%ebx
  801e75:	eb 06                	jmp    801e7d <spawn+0x4f1>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801e77:	89 c3                	mov    %eax,%ebx
  801e79:	eb 02                	jmp    801e7d <spawn+0x4f1>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801e7b:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801e7d:	83 ec 0c             	sub    $0xc,%esp
  801e80:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e86:	e8 52 ed ff ff       	call   800bdd <sys_env_destroy>
	close(fd);
  801e8b:	83 c4 04             	add    $0x4,%esp
  801e8e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e94:	e8 88 f4 ff ff       	call   801321 <close>
	return r;
  801e99:	83 c4 10             	add    $0x10,%esp
  801e9c:	eb 56                	jmp    801ef4 <spawn+0x568>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801e9e:	50                   	push   %eax
  801e9f:	68 fb 2e 80 00       	push   $0x802efb
  801ea4:	68 82 00 00 00       	push   $0x82
  801ea9:	68 a1 2e 80 00       	push   $0x802ea1
  801eae:	e8 48 e3 ff ff       	call   8001fb <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801eb3:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801eba:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801ebd:	83 ec 08             	sub    $0x8,%esp
  801ec0:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801ec6:	50                   	push   %eax
  801ec7:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ecd:	e8 93 ee ff ff       	call   800d65 <sys_env_set_trapframe>
  801ed2:	83 c4 10             	add    $0x10,%esp
  801ed5:	85 c0                	test   %eax,%eax
  801ed7:	0f 89 38 ff ff ff    	jns    801e15 <spawn+0x489>
  801edd:	e9 1e ff ff ff       	jmp    801e00 <spawn+0x474>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801ee2:	83 ec 08             	sub    $0x8,%esp
  801ee5:	68 00 00 40 00       	push   $0x400000
  801eea:	6a 00                	push   $0x0
  801eec:	e8 f0 ed ff ff       	call   800ce1 <sys_page_unmap>
  801ef1:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801ef4:	89 d8                	mov    %ebx,%eax
  801ef6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ef9:	5b                   	pop    %ebx
  801efa:	5e                   	pop    %esi
  801efb:	5f                   	pop    %edi
  801efc:	5d                   	pop    %ebp
  801efd:	c3                   	ret    

00801efe <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801efe:	55                   	push   %ebp
  801eff:	89 e5                	mov    %esp,%ebp
  801f01:	56                   	push   %esi
  801f02:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f03:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801f06:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f0b:	eb 03                	jmp    801f10 <spawnl+0x12>
		argc++;
  801f0d:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f10:	83 c2 04             	add    $0x4,%edx
  801f13:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801f17:	75 f4                	jne    801f0d <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801f19:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801f20:	83 e2 f0             	and    $0xfffffff0,%edx
  801f23:	29 d4                	sub    %edx,%esp
  801f25:	8d 54 24 03          	lea    0x3(%esp),%edx
  801f29:	c1 ea 02             	shr    $0x2,%edx
  801f2c:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801f33:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801f35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f38:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801f3f:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801f46:	00 
  801f47:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f49:	b8 00 00 00 00       	mov    $0x0,%eax
  801f4e:	eb 0a                	jmp    801f5a <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801f50:	83 c0 01             	add    $0x1,%eax
  801f53:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801f57:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f5a:	39 d0                	cmp    %edx,%eax
  801f5c:	75 f2                	jne    801f50 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801f5e:	83 ec 08             	sub    $0x8,%esp
  801f61:	56                   	push   %esi
  801f62:	ff 75 08             	pushl  0x8(%ebp)
  801f65:	e8 22 fa ff ff       	call   80198c <spawn>
}
  801f6a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f6d:	5b                   	pop    %ebx
  801f6e:	5e                   	pop    %esi
  801f6f:	5d                   	pop    %ebp
  801f70:	c3                   	ret    

00801f71 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f71:	55                   	push   %ebp
  801f72:	89 e5                	mov    %esp,%ebp
  801f74:	56                   	push   %esi
  801f75:	53                   	push   %ebx
  801f76:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f79:	83 ec 0c             	sub    $0xc,%esp
  801f7c:	ff 75 08             	pushl  0x8(%ebp)
  801f7f:	e8 0d f2 ff ff       	call   801191 <fd2data>
  801f84:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f86:	83 c4 08             	add    $0x8,%esp
  801f89:	68 3c 2f 80 00       	push   $0x802f3c
  801f8e:	53                   	push   %ebx
  801f8f:	e8 c5 e8 ff ff       	call   800859 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f94:	8b 46 04             	mov    0x4(%esi),%eax
  801f97:	2b 06                	sub    (%esi),%eax
  801f99:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f9f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801fa6:	00 00 00 
	stat->st_dev = &devpipe;
  801fa9:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801fb0:	30 80 00 
	return 0;
}
  801fb3:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fbb:	5b                   	pop    %ebx
  801fbc:	5e                   	pop    %esi
  801fbd:	5d                   	pop    %ebp
  801fbe:	c3                   	ret    

00801fbf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801fbf:	55                   	push   %ebp
  801fc0:	89 e5                	mov    %esp,%ebp
  801fc2:	53                   	push   %ebx
  801fc3:	83 ec 0c             	sub    $0xc,%esp
  801fc6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801fc9:	53                   	push   %ebx
  801fca:	6a 00                	push   $0x0
  801fcc:	e8 10 ed ff ff       	call   800ce1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801fd1:	89 1c 24             	mov    %ebx,(%esp)
  801fd4:	e8 b8 f1 ff ff       	call   801191 <fd2data>
  801fd9:	83 c4 08             	add    $0x8,%esp
  801fdc:	50                   	push   %eax
  801fdd:	6a 00                	push   $0x0
  801fdf:	e8 fd ec ff ff       	call   800ce1 <sys_page_unmap>
}
  801fe4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fe7:	c9                   	leave  
  801fe8:	c3                   	ret    

00801fe9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801fe9:	55                   	push   %ebp
  801fea:	89 e5                	mov    %esp,%ebp
  801fec:	57                   	push   %edi
  801fed:	56                   	push   %esi
  801fee:	53                   	push   %ebx
  801fef:	83 ec 1c             	sub    $0x1c,%esp
  801ff2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ff5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ff7:	a1 04 40 80 00       	mov    0x804004,%eax
  801ffc:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802002:	83 ec 0c             	sub    $0xc,%esp
  802005:	ff 75 e0             	pushl  -0x20(%ebp)
  802008:	e8 4f 06 00 00       	call   80265c <pageref>
  80200d:	89 c3                	mov    %eax,%ebx
  80200f:	89 3c 24             	mov    %edi,(%esp)
  802012:	e8 45 06 00 00       	call   80265c <pageref>
  802017:	83 c4 10             	add    $0x10,%esp
  80201a:	39 c3                	cmp    %eax,%ebx
  80201c:	0f 94 c1             	sete   %cl
  80201f:	0f b6 c9             	movzbl %cl,%ecx
  802022:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802025:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80202b:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  802031:	39 ce                	cmp    %ecx,%esi
  802033:	74 1e                	je     802053 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  802035:	39 c3                	cmp    %eax,%ebx
  802037:	75 be                	jne    801ff7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802039:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  80203f:	ff 75 e4             	pushl  -0x1c(%ebp)
  802042:	50                   	push   %eax
  802043:	56                   	push   %esi
  802044:	68 43 2f 80 00       	push   $0x802f43
  802049:	e8 86 e2 ff ff       	call   8002d4 <cprintf>
  80204e:	83 c4 10             	add    $0x10,%esp
  802051:	eb a4                	jmp    801ff7 <_pipeisclosed+0xe>
	}
}
  802053:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802056:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802059:	5b                   	pop    %ebx
  80205a:	5e                   	pop    %esi
  80205b:	5f                   	pop    %edi
  80205c:	5d                   	pop    %ebp
  80205d:	c3                   	ret    

0080205e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80205e:	55                   	push   %ebp
  80205f:	89 e5                	mov    %esp,%ebp
  802061:	57                   	push   %edi
  802062:	56                   	push   %esi
  802063:	53                   	push   %ebx
  802064:	83 ec 28             	sub    $0x28,%esp
  802067:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80206a:	56                   	push   %esi
  80206b:	e8 21 f1 ff ff       	call   801191 <fd2data>
  802070:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802072:	83 c4 10             	add    $0x10,%esp
  802075:	bf 00 00 00 00       	mov    $0x0,%edi
  80207a:	eb 4b                	jmp    8020c7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80207c:	89 da                	mov    %ebx,%edx
  80207e:	89 f0                	mov    %esi,%eax
  802080:	e8 64 ff ff ff       	call   801fe9 <_pipeisclosed>
  802085:	85 c0                	test   %eax,%eax
  802087:	75 48                	jne    8020d1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802089:	e8 af eb ff ff       	call   800c3d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80208e:	8b 43 04             	mov    0x4(%ebx),%eax
  802091:	8b 0b                	mov    (%ebx),%ecx
  802093:	8d 51 20             	lea    0x20(%ecx),%edx
  802096:	39 d0                	cmp    %edx,%eax
  802098:	73 e2                	jae    80207c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80209a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80209d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8020a1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8020a4:	89 c2                	mov    %eax,%edx
  8020a6:	c1 fa 1f             	sar    $0x1f,%edx
  8020a9:	89 d1                	mov    %edx,%ecx
  8020ab:	c1 e9 1b             	shr    $0x1b,%ecx
  8020ae:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8020b1:	83 e2 1f             	and    $0x1f,%edx
  8020b4:	29 ca                	sub    %ecx,%edx
  8020b6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8020ba:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8020be:	83 c0 01             	add    $0x1,%eax
  8020c1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020c4:	83 c7 01             	add    $0x1,%edi
  8020c7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8020ca:	75 c2                	jne    80208e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8020cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8020cf:	eb 05                	jmp    8020d6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020d1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8020d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020d9:	5b                   	pop    %ebx
  8020da:	5e                   	pop    %esi
  8020db:	5f                   	pop    %edi
  8020dc:	5d                   	pop    %ebp
  8020dd:	c3                   	ret    

008020de <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020de:	55                   	push   %ebp
  8020df:	89 e5                	mov    %esp,%ebp
  8020e1:	57                   	push   %edi
  8020e2:	56                   	push   %esi
  8020e3:	53                   	push   %ebx
  8020e4:	83 ec 18             	sub    $0x18,%esp
  8020e7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8020ea:	57                   	push   %edi
  8020eb:	e8 a1 f0 ff ff       	call   801191 <fd2data>
  8020f0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020f2:	83 c4 10             	add    $0x10,%esp
  8020f5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020fa:	eb 3d                	jmp    802139 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8020fc:	85 db                	test   %ebx,%ebx
  8020fe:	74 04                	je     802104 <devpipe_read+0x26>
				return i;
  802100:	89 d8                	mov    %ebx,%eax
  802102:	eb 44                	jmp    802148 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802104:	89 f2                	mov    %esi,%edx
  802106:	89 f8                	mov    %edi,%eax
  802108:	e8 dc fe ff ff       	call   801fe9 <_pipeisclosed>
  80210d:	85 c0                	test   %eax,%eax
  80210f:	75 32                	jne    802143 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802111:	e8 27 eb ff ff       	call   800c3d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802116:	8b 06                	mov    (%esi),%eax
  802118:	3b 46 04             	cmp    0x4(%esi),%eax
  80211b:	74 df                	je     8020fc <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80211d:	99                   	cltd   
  80211e:	c1 ea 1b             	shr    $0x1b,%edx
  802121:	01 d0                	add    %edx,%eax
  802123:	83 e0 1f             	and    $0x1f,%eax
  802126:	29 d0                	sub    %edx,%eax
  802128:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80212d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802130:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802133:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802136:	83 c3 01             	add    $0x1,%ebx
  802139:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80213c:	75 d8                	jne    802116 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80213e:	8b 45 10             	mov    0x10(%ebp),%eax
  802141:	eb 05                	jmp    802148 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802143:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802148:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80214b:	5b                   	pop    %ebx
  80214c:	5e                   	pop    %esi
  80214d:	5f                   	pop    %edi
  80214e:	5d                   	pop    %ebp
  80214f:	c3                   	ret    

00802150 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802150:	55                   	push   %ebp
  802151:	89 e5                	mov    %esp,%ebp
  802153:	56                   	push   %esi
  802154:	53                   	push   %ebx
  802155:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802158:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80215b:	50                   	push   %eax
  80215c:	e8 47 f0 ff ff       	call   8011a8 <fd_alloc>
  802161:	83 c4 10             	add    $0x10,%esp
  802164:	89 c2                	mov    %eax,%edx
  802166:	85 c0                	test   %eax,%eax
  802168:	0f 88 2c 01 00 00    	js     80229a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80216e:	83 ec 04             	sub    $0x4,%esp
  802171:	68 07 04 00 00       	push   $0x407
  802176:	ff 75 f4             	pushl  -0xc(%ebp)
  802179:	6a 00                	push   $0x0
  80217b:	e8 dc ea ff ff       	call   800c5c <sys_page_alloc>
  802180:	83 c4 10             	add    $0x10,%esp
  802183:	89 c2                	mov    %eax,%edx
  802185:	85 c0                	test   %eax,%eax
  802187:	0f 88 0d 01 00 00    	js     80229a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80218d:	83 ec 0c             	sub    $0xc,%esp
  802190:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802193:	50                   	push   %eax
  802194:	e8 0f f0 ff ff       	call   8011a8 <fd_alloc>
  802199:	89 c3                	mov    %eax,%ebx
  80219b:	83 c4 10             	add    $0x10,%esp
  80219e:	85 c0                	test   %eax,%eax
  8021a0:	0f 88 e2 00 00 00    	js     802288 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021a6:	83 ec 04             	sub    $0x4,%esp
  8021a9:	68 07 04 00 00       	push   $0x407
  8021ae:	ff 75 f0             	pushl  -0x10(%ebp)
  8021b1:	6a 00                	push   $0x0
  8021b3:	e8 a4 ea ff ff       	call   800c5c <sys_page_alloc>
  8021b8:	89 c3                	mov    %eax,%ebx
  8021ba:	83 c4 10             	add    $0x10,%esp
  8021bd:	85 c0                	test   %eax,%eax
  8021bf:	0f 88 c3 00 00 00    	js     802288 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8021c5:	83 ec 0c             	sub    $0xc,%esp
  8021c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8021cb:	e8 c1 ef ff ff       	call   801191 <fd2data>
  8021d0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021d2:	83 c4 0c             	add    $0xc,%esp
  8021d5:	68 07 04 00 00       	push   $0x407
  8021da:	50                   	push   %eax
  8021db:	6a 00                	push   $0x0
  8021dd:	e8 7a ea ff ff       	call   800c5c <sys_page_alloc>
  8021e2:	89 c3                	mov    %eax,%ebx
  8021e4:	83 c4 10             	add    $0x10,%esp
  8021e7:	85 c0                	test   %eax,%eax
  8021e9:	0f 88 89 00 00 00    	js     802278 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021ef:	83 ec 0c             	sub    $0xc,%esp
  8021f2:	ff 75 f0             	pushl  -0x10(%ebp)
  8021f5:	e8 97 ef ff ff       	call   801191 <fd2data>
  8021fa:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802201:	50                   	push   %eax
  802202:	6a 00                	push   $0x0
  802204:	56                   	push   %esi
  802205:	6a 00                	push   $0x0
  802207:	e8 93 ea ff ff       	call   800c9f <sys_page_map>
  80220c:	89 c3                	mov    %eax,%ebx
  80220e:	83 c4 20             	add    $0x20,%esp
  802211:	85 c0                	test   %eax,%eax
  802213:	78 55                	js     80226a <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802215:	8b 15 28 30 80 00    	mov    0x803028,%edx
  80221b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80221e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802220:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802223:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80222a:	8b 15 28 30 80 00    	mov    0x803028,%edx
  802230:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802233:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802235:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802238:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80223f:	83 ec 0c             	sub    $0xc,%esp
  802242:	ff 75 f4             	pushl  -0xc(%ebp)
  802245:	e8 37 ef ff ff       	call   801181 <fd2num>
  80224a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80224d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80224f:	83 c4 04             	add    $0x4,%esp
  802252:	ff 75 f0             	pushl  -0x10(%ebp)
  802255:	e8 27 ef ff ff       	call   801181 <fd2num>
  80225a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80225d:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  802260:	83 c4 10             	add    $0x10,%esp
  802263:	ba 00 00 00 00       	mov    $0x0,%edx
  802268:	eb 30                	jmp    80229a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80226a:	83 ec 08             	sub    $0x8,%esp
  80226d:	56                   	push   %esi
  80226e:	6a 00                	push   $0x0
  802270:	e8 6c ea ff ff       	call   800ce1 <sys_page_unmap>
  802275:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802278:	83 ec 08             	sub    $0x8,%esp
  80227b:	ff 75 f0             	pushl  -0x10(%ebp)
  80227e:	6a 00                	push   $0x0
  802280:	e8 5c ea ff ff       	call   800ce1 <sys_page_unmap>
  802285:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802288:	83 ec 08             	sub    $0x8,%esp
  80228b:	ff 75 f4             	pushl  -0xc(%ebp)
  80228e:	6a 00                	push   $0x0
  802290:	e8 4c ea ff ff       	call   800ce1 <sys_page_unmap>
  802295:	83 c4 10             	add    $0x10,%esp
  802298:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80229a:	89 d0                	mov    %edx,%eax
  80229c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80229f:	5b                   	pop    %ebx
  8022a0:	5e                   	pop    %esi
  8022a1:	5d                   	pop    %ebp
  8022a2:	c3                   	ret    

008022a3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8022a3:	55                   	push   %ebp
  8022a4:	89 e5                	mov    %esp,%ebp
  8022a6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022ac:	50                   	push   %eax
  8022ad:	ff 75 08             	pushl  0x8(%ebp)
  8022b0:	e8 42 ef ff ff       	call   8011f7 <fd_lookup>
  8022b5:	83 c4 10             	add    $0x10,%esp
  8022b8:	85 c0                	test   %eax,%eax
  8022ba:	78 18                	js     8022d4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8022bc:	83 ec 0c             	sub    $0xc,%esp
  8022bf:	ff 75 f4             	pushl  -0xc(%ebp)
  8022c2:	e8 ca ee ff ff       	call   801191 <fd2data>
	return _pipeisclosed(fd, p);
  8022c7:	89 c2                	mov    %eax,%edx
  8022c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022cc:	e8 18 fd ff ff       	call   801fe9 <_pipeisclosed>
  8022d1:	83 c4 10             	add    $0x10,%esp
}
  8022d4:	c9                   	leave  
  8022d5:	c3                   	ret    

008022d6 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8022d6:	55                   	push   %ebp
  8022d7:	89 e5                	mov    %esp,%ebp
  8022d9:	56                   	push   %esi
  8022da:	53                   	push   %ebx
  8022db:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8022de:	85 f6                	test   %esi,%esi
  8022e0:	75 16                	jne    8022f8 <wait+0x22>
  8022e2:	68 5b 2f 80 00       	push   $0x802f5b
  8022e7:	68 5b 2e 80 00       	push   $0x802e5b
  8022ec:	6a 09                	push   $0x9
  8022ee:	68 66 2f 80 00       	push   $0x802f66
  8022f3:	e8 03 df ff ff       	call   8001fb <_panic>
	e = &envs[ENVX(envid)];
  8022f8:	89 f3                	mov    %esi,%ebx
  8022fa:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802300:	69 db b0 00 00 00    	imul   $0xb0,%ebx,%ebx
  802306:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80230c:	eb 05                	jmp    802313 <wait+0x3d>
		sys_yield();
  80230e:	e8 2a e9 ff ff       	call   800c3d <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802313:	8b 43 7c             	mov    0x7c(%ebx),%eax
  802316:	39 c6                	cmp    %eax,%esi
  802318:	75 0a                	jne    802324 <wait+0x4e>
  80231a:	8b 83 88 00 00 00    	mov    0x88(%ebx),%eax
  802320:	85 c0                	test   %eax,%eax
  802322:	75 ea                	jne    80230e <wait+0x38>
		sys_yield();
}
  802324:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802327:	5b                   	pop    %ebx
  802328:	5e                   	pop    %esi
  802329:	5d                   	pop    %ebp
  80232a:	c3                   	ret    

0080232b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80232b:	55                   	push   %ebp
  80232c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80232e:	b8 00 00 00 00       	mov    $0x0,%eax
  802333:	5d                   	pop    %ebp
  802334:	c3                   	ret    

00802335 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802335:	55                   	push   %ebp
  802336:	89 e5                	mov    %esp,%ebp
  802338:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80233b:	68 71 2f 80 00       	push   $0x802f71
  802340:	ff 75 0c             	pushl  0xc(%ebp)
  802343:	e8 11 e5 ff ff       	call   800859 <strcpy>
	return 0;
}
  802348:	b8 00 00 00 00       	mov    $0x0,%eax
  80234d:	c9                   	leave  
  80234e:	c3                   	ret    

0080234f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80234f:	55                   	push   %ebp
  802350:	89 e5                	mov    %esp,%ebp
  802352:	57                   	push   %edi
  802353:	56                   	push   %esi
  802354:	53                   	push   %ebx
  802355:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80235b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802360:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802366:	eb 2d                	jmp    802395 <devcons_write+0x46>
		m = n - tot;
  802368:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80236b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80236d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802370:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802375:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802378:	83 ec 04             	sub    $0x4,%esp
  80237b:	53                   	push   %ebx
  80237c:	03 45 0c             	add    0xc(%ebp),%eax
  80237f:	50                   	push   %eax
  802380:	57                   	push   %edi
  802381:	e8 65 e6 ff ff       	call   8009eb <memmove>
		sys_cputs(buf, m);
  802386:	83 c4 08             	add    $0x8,%esp
  802389:	53                   	push   %ebx
  80238a:	57                   	push   %edi
  80238b:	e8 10 e8 ff ff       	call   800ba0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802390:	01 de                	add    %ebx,%esi
  802392:	83 c4 10             	add    $0x10,%esp
  802395:	89 f0                	mov    %esi,%eax
  802397:	3b 75 10             	cmp    0x10(%ebp),%esi
  80239a:	72 cc                	jb     802368 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80239c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80239f:	5b                   	pop    %ebx
  8023a0:	5e                   	pop    %esi
  8023a1:	5f                   	pop    %edi
  8023a2:	5d                   	pop    %ebp
  8023a3:	c3                   	ret    

008023a4 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8023a4:	55                   	push   %ebp
  8023a5:	89 e5                	mov    %esp,%ebp
  8023a7:	83 ec 08             	sub    $0x8,%esp
  8023aa:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8023af:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8023b3:	74 2a                	je     8023df <devcons_read+0x3b>
  8023b5:	eb 05                	jmp    8023bc <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8023b7:	e8 81 e8 ff ff       	call   800c3d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8023bc:	e8 fd e7 ff ff       	call   800bbe <sys_cgetc>
  8023c1:	85 c0                	test   %eax,%eax
  8023c3:	74 f2                	je     8023b7 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8023c5:	85 c0                	test   %eax,%eax
  8023c7:	78 16                	js     8023df <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8023c9:	83 f8 04             	cmp    $0x4,%eax
  8023cc:	74 0c                	je     8023da <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8023ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023d1:	88 02                	mov    %al,(%edx)
	return 1;
  8023d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8023d8:	eb 05                	jmp    8023df <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8023da:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8023df:	c9                   	leave  
  8023e0:	c3                   	ret    

008023e1 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8023e1:	55                   	push   %ebp
  8023e2:	89 e5                	mov    %esp,%ebp
  8023e4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8023e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ea:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8023ed:	6a 01                	push   $0x1
  8023ef:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023f2:	50                   	push   %eax
  8023f3:	e8 a8 e7 ff ff       	call   800ba0 <sys_cputs>
}
  8023f8:	83 c4 10             	add    $0x10,%esp
  8023fb:	c9                   	leave  
  8023fc:	c3                   	ret    

008023fd <getchar>:

int
getchar(void)
{
  8023fd:	55                   	push   %ebp
  8023fe:	89 e5                	mov    %esp,%ebp
  802400:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802403:	6a 01                	push   $0x1
  802405:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802408:	50                   	push   %eax
  802409:	6a 00                	push   $0x0
  80240b:	e8 4d f0 ff ff       	call   80145d <read>
	if (r < 0)
  802410:	83 c4 10             	add    $0x10,%esp
  802413:	85 c0                	test   %eax,%eax
  802415:	78 0f                	js     802426 <getchar+0x29>
		return r;
	if (r < 1)
  802417:	85 c0                	test   %eax,%eax
  802419:	7e 06                	jle    802421 <getchar+0x24>
		return -E_EOF;
	return c;
  80241b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80241f:	eb 05                	jmp    802426 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802421:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802426:	c9                   	leave  
  802427:	c3                   	ret    

00802428 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802428:	55                   	push   %ebp
  802429:	89 e5                	mov    %esp,%ebp
  80242b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80242e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802431:	50                   	push   %eax
  802432:	ff 75 08             	pushl  0x8(%ebp)
  802435:	e8 bd ed ff ff       	call   8011f7 <fd_lookup>
  80243a:	83 c4 10             	add    $0x10,%esp
  80243d:	85 c0                	test   %eax,%eax
  80243f:	78 11                	js     802452 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802441:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802444:	8b 15 44 30 80 00    	mov    0x803044,%edx
  80244a:	39 10                	cmp    %edx,(%eax)
  80244c:	0f 94 c0             	sete   %al
  80244f:	0f b6 c0             	movzbl %al,%eax
}
  802452:	c9                   	leave  
  802453:	c3                   	ret    

00802454 <opencons>:

int
opencons(void)
{
  802454:	55                   	push   %ebp
  802455:	89 e5                	mov    %esp,%ebp
  802457:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80245a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80245d:	50                   	push   %eax
  80245e:	e8 45 ed ff ff       	call   8011a8 <fd_alloc>
  802463:	83 c4 10             	add    $0x10,%esp
		return r;
  802466:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802468:	85 c0                	test   %eax,%eax
  80246a:	78 3e                	js     8024aa <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80246c:	83 ec 04             	sub    $0x4,%esp
  80246f:	68 07 04 00 00       	push   $0x407
  802474:	ff 75 f4             	pushl  -0xc(%ebp)
  802477:	6a 00                	push   $0x0
  802479:	e8 de e7 ff ff       	call   800c5c <sys_page_alloc>
  80247e:	83 c4 10             	add    $0x10,%esp
		return r;
  802481:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802483:	85 c0                	test   %eax,%eax
  802485:	78 23                	js     8024aa <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802487:	8b 15 44 30 80 00    	mov    0x803044,%edx
  80248d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802490:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802492:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802495:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80249c:	83 ec 0c             	sub    $0xc,%esp
  80249f:	50                   	push   %eax
  8024a0:	e8 dc ec ff ff       	call   801181 <fd2num>
  8024a5:	89 c2                	mov    %eax,%edx
  8024a7:	83 c4 10             	add    $0x10,%esp
}
  8024aa:	89 d0                	mov    %edx,%eax
  8024ac:	c9                   	leave  
  8024ad:	c3                   	ret    

008024ae <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8024ae:	55                   	push   %ebp
  8024af:	89 e5                	mov    %esp,%ebp
  8024b1:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8024b4:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8024bb:	75 2a                	jne    8024e7 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  8024bd:	83 ec 04             	sub    $0x4,%esp
  8024c0:	6a 07                	push   $0x7
  8024c2:	68 00 f0 bf ee       	push   $0xeebff000
  8024c7:	6a 00                	push   $0x0
  8024c9:	e8 8e e7 ff ff       	call   800c5c <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8024ce:	83 c4 10             	add    $0x10,%esp
  8024d1:	85 c0                	test   %eax,%eax
  8024d3:	79 12                	jns    8024e7 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8024d5:	50                   	push   %eax
  8024d6:	68 7d 2f 80 00       	push   $0x802f7d
  8024db:	6a 23                	push   $0x23
  8024dd:	68 81 2f 80 00       	push   $0x802f81
  8024e2:	e8 14 dd ff ff       	call   8001fb <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8024e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8024ea:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8024ef:	83 ec 08             	sub    $0x8,%esp
  8024f2:	68 19 25 80 00       	push   $0x802519
  8024f7:	6a 00                	push   $0x0
  8024f9:	e8 a9 e8 ff ff       	call   800da7 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8024fe:	83 c4 10             	add    $0x10,%esp
  802501:	85 c0                	test   %eax,%eax
  802503:	79 12                	jns    802517 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802505:	50                   	push   %eax
  802506:	68 7d 2f 80 00       	push   $0x802f7d
  80250b:	6a 2c                	push   $0x2c
  80250d:	68 81 2f 80 00       	push   $0x802f81
  802512:	e8 e4 dc ff ff       	call   8001fb <_panic>
	}
}
  802517:	c9                   	leave  
  802518:	c3                   	ret    

00802519 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802519:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80251a:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80251f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802521:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802524:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802528:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80252d:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802531:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802533:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802536:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802537:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80253a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80253b:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80253c:	c3                   	ret    

0080253d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80253d:	55                   	push   %ebp
  80253e:	89 e5                	mov    %esp,%ebp
  802540:	56                   	push   %esi
  802541:	53                   	push   %ebx
  802542:	8b 75 08             	mov    0x8(%ebp),%esi
  802545:	8b 45 0c             	mov    0xc(%ebp),%eax
  802548:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80254b:	85 c0                	test   %eax,%eax
  80254d:	75 12                	jne    802561 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80254f:	83 ec 0c             	sub    $0xc,%esp
  802552:	68 00 00 c0 ee       	push   $0xeec00000
  802557:	e8 b0 e8 ff ff       	call   800e0c <sys_ipc_recv>
  80255c:	83 c4 10             	add    $0x10,%esp
  80255f:	eb 0c                	jmp    80256d <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802561:	83 ec 0c             	sub    $0xc,%esp
  802564:	50                   	push   %eax
  802565:	e8 a2 e8 ff ff       	call   800e0c <sys_ipc_recv>
  80256a:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80256d:	85 f6                	test   %esi,%esi
  80256f:	0f 95 c1             	setne  %cl
  802572:	85 db                	test   %ebx,%ebx
  802574:	0f 95 c2             	setne  %dl
  802577:	84 d1                	test   %dl,%cl
  802579:	74 09                	je     802584 <ipc_recv+0x47>
  80257b:	89 c2                	mov    %eax,%edx
  80257d:	c1 ea 1f             	shr    $0x1f,%edx
  802580:	84 d2                	test   %dl,%dl
  802582:	75 2d                	jne    8025b1 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802584:	85 f6                	test   %esi,%esi
  802586:	74 0d                	je     802595 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802588:	a1 04 40 80 00       	mov    0x804004,%eax
  80258d:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  802593:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802595:	85 db                	test   %ebx,%ebx
  802597:	74 0d                	je     8025a6 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802599:	a1 04 40 80 00       	mov    0x804004,%eax
  80259e:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  8025a4:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8025a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8025ab:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  8025b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025b4:	5b                   	pop    %ebx
  8025b5:	5e                   	pop    %esi
  8025b6:	5d                   	pop    %ebp
  8025b7:	c3                   	ret    

008025b8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8025b8:	55                   	push   %ebp
  8025b9:	89 e5                	mov    %esp,%ebp
  8025bb:	57                   	push   %edi
  8025bc:	56                   	push   %esi
  8025bd:	53                   	push   %ebx
  8025be:	83 ec 0c             	sub    $0xc,%esp
  8025c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8025c4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8025c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8025ca:	85 db                	test   %ebx,%ebx
  8025cc:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8025d1:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8025d4:	ff 75 14             	pushl  0x14(%ebp)
  8025d7:	53                   	push   %ebx
  8025d8:	56                   	push   %esi
  8025d9:	57                   	push   %edi
  8025da:	e8 0a e8 ff ff       	call   800de9 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8025df:	89 c2                	mov    %eax,%edx
  8025e1:	c1 ea 1f             	shr    $0x1f,%edx
  8025e4:	83 c4 10             	add    $0x10,%esp
  8025e7:	84 d2                	test   %dl,%dl
  8025e9:	74 17                	je     802602 <ipc_send+0x4a>
  8025eb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8025ee:	74 12                	je     802602 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8025f0:	50                   	push   %eax
  8025f1:	68 8f 2f 80 00       	push   $0x802f8f
  8025f6:	6a 47                	push   $0x47
  8025f8:	68 9d 2f 80 00       	push   $0x802f9d
  8025fd:	e8 f9 db ff ff       	call   8001fb <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802602:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802605:	75 07                	jne    80260e <ipc_send+0x56>
			sys_yield();
  802607:	e8 31 e6 ff ff       	call   800c3d <sys_yield>
  80260c:	eb c6                	jmp    8025d4 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80260e:	85 c0                	test   %eax,%eax
  802610:	75 c2                	jne    8025d4 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802612:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802615:	5b                   	pop    %ebx
  802616:	5e                   	pop    %esi
  802617:	5f                   	pop    %edi
  802618:	5d                   	pop    %ebp
  802619:	c3                   	ret    

0080261a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80261a:	55                   	push   %ebp
  80261b:	89 e5                	mov    %esp,%ebp
  80261d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802620:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802625:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  80262b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802631:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  802637:	39 ca                	cmp    %ecx,%edx
  802639:	75 10                	jne    80264b <ipc_find_env+0x31>
			return envs[i].env_id;
  80263b:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  802641:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802646:	8b 40 7c             	mov    0x7c(%eax),%eax
  802649:	eb 0f                	jmp    80265a <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80264b:	83 c0 01             	add    $0x1,%eax
  80264e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802653:	75 d0                	jne    802625 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802655:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80265a:	5d                   	pop    %ebp
  80265b:	c3                   	ret    

0080265c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80265c:	55                   	push   %ebp
  80265d:	89 e5                	mov    %esp,%ebp
  80265f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802662:	89 d0                	mov    %edx,%eax
  802664:	c1 e8 16             	shr    $0x16,%eax
  802667:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80266e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802673:	f6 c1 01             	test   $0x1,%cl
  802676:	74 1d                	je     802695 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802678:	c1 ea 0c             	shr    $0xc,%edx
  80267b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802682:	f6 c2 01             	test   $0x1,%dl
  802685:	74 0e                	je     802695 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802687:	c1 ea 0c             	shr    $0xc,%edx
  80268a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802691:	ef 
  802692:	0f b7 c0             	movzwl %ax,%eax
}
  802695:	5d                   	pop    %ebp
  802696:	c3                   	ret    
  802697:	66 90                	xchg   %ax,%ax
  802699:	66 90                	xchg   %ax,%ax
  80269b:	66 90                	xchg   %ax,%ax
  80269d:	66 90                	xchg   %ax,%ax
  80269f:	90                   	nop

008026a0 <__udivdi3>:
  8026a0:	55                   	push   %ebp
  8026a1:	57                   	push   %edi
  8026a2:	56                   	push   %esi
  8026a3:	53                   	push   %ebx
  8026a4:	83 ec 1c             	sub    $0x1c,%esp
  8026a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8026ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8026af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8026b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026b7:	85 f6                	test   %esi,%esi
  8026b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026bd:	89 ca                	mov    %ecx,%edx
  8026bf:	89 f8                	mov    %edi,%eax
  8026c1:	75 3d                	jne    802700 <__udivdi3+0x60>
  8026c3:	39 cf                	cmp    %ecx,%edi
  8026c5:	0f 87 c5 00 00 00    	ja     802790 <__udivdi3+0xf0>
  8026cb:	85 ff                	test   %edi,%edi
  8026cd:	89 fd                	mov    %edi,%ebp
  8026cf:	75 0b                	jne    8026dc <__udivdi3+0x3c>
  8026d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8026d6:	31 d2                	xor    %edx,%edx
  8026d8:	f7 f7                	div    %edi
  8026da:	89 c5                	mov    %eax,%ebp
  8026dc:	89 c8                	mov    %ecx,%eax
  8026de:	31 d2                	xor    %edx,%edx
  8026e0:	f7 f5                	div    %ebp
  8026e2:	89 c1                	mov    %eax,%ecx
  8026e4:	89 d8                	mov    %ebx,%eax
  8026e6:	89 cf                	mov    %ecx,%edi
  8026e8:	f7 f5                	div    %ebp
  8026ea:	89 c3                	mov    %eax,%ebx
  8026ec:	89 d8                	mov    %ebx,%eax
  8026ee:	89 fa                	mov    %edi,%edx
  8026f0:	83 c4 1c             	add    $0x1c,%esp
  8026f3:	5b                   	pop    %ebx
  8026f4:	5e                   	pop    %esi
  8026f5:	5f                   	pop    %edi
  8026f6:	5d                   	pop    %ebp
  8026f7:	c3                   	ret    
  8026f8:	90                   	nop
  8026f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802700:	39 ce                	cmp    %ecx,%esi
  802702:	77 74                	ja     802778 <__udivdi3+0xd8>
  802704:	0f bd fe             	bsr    %esi,%edi
  802707:	83 f7 1f             	xor    $0x1f,%edi
  80270a:	0f 84 98 00 00 00    	je     8027a8 <__udivdi3+0x108>
  802710:	bb 20 00 00 00       	mov    $0x20,%ebx
  802715:	89 f9                	mov    %edi,%ecx
  802717:	89 c5                	mov    %eax,%ebp
  802719:	29 fb                	sub    %edi,%ebx
  80271b:	d3 e6                	shl    %cl,%esi
  80271d:	89 d9                	mov    %ebx,%ecx
  80271f:	d3 ed                	shr    %cl,%ebp
  802721:	89 f9                	mov    %edi,%ecx
  802723:	d3 e0                	shl    %cl,%eax
  802725:	09 ee                	or     %ebp,%esi
  802727:	89 d9                	mov    %ebx,%ecx
  802729:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80272d:	89 d5                	mov    %edx,%ebp
  80272f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802733:	d3 ed                	shr    %cl,%ebp
  802735:	89 f9                	mov    %edi,%ecx
  802737:	d3 e2                	shl    %cl,%edx
  802739:	89 d9                	mov    %ebx,%ecx
  80273b:	d3 e8                	shr    %cl,%eax
  80273d:	09 c2                	or     %eax,%edx
  80273f:	89 d0                	mov    %edx,%eax
  802741:	89 ea                	mov    %ebp,%edx
  802743:	f7 f6                	div    %esi
  802745:	89 d5                	mov    %edx,%ebp
  802747:	89 c3                	mov    %eax,%ebx
  802749:	f7 64 24 0c          	mull   0xc(%esp)
  80274d:	39 d5                	cmp    %edx,%ebp
  80274f:	72 10                	jb     802761 <__udivdi3+0xc1>
  802751:	8b 74 24 08          	mov    0x8(%esp),%esi
  802755:	89 f9                	mov    %edi,%ecx
  802757:	d3 e6                	shl    %cl,%esi
  802759:	39 c6                	cmp    %eax,%esi
  80275b:	73 07                	jae    802764 <__udivdi3+0xc4>
  80275d:	39 d5                	cmp    %edx,%ebp
  80275f:	75 03                	jne    802764 <__udivdi3+0xc4>
  802761:	83 eb 01             	sub    $0x1,%ebx
  802764:	31 ff                	xor    %edi,%edi
  802766:	89 d8                	mov    %ebx,%eax
  802768:	89 fa                	mov    %edi,%edx
  80276a:	83 c4 1c             	add    $0x1c,%esp
  80276d:	5b                   	pop    %ebx
  80276e:	5e                   	pop    %esi
  80276f:	5f                   	pop    %edi
  802770:	5d                   	pop    %ebp
  802771:	c3                   	ret    
  802772:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802778:	31 ff                	xor    %edi,%edi
  80277a:	31 db                	xor    %ebx,%ebx
  80277c:	89 d8                	mov    %ebx,%eax
  80277e:	89 fa                	mov    %edi,%edx
  802780:	83 c4 1c             	add    $0x1c,%esp
  802783:	5b                   	pop    %ebx
  802784:	5e                   	pop    %esi
  802785:	5f                   	pop    %edi
  802786:	5d                   	pop    %ebp
  802787:	c3                   	ret    
  802788:	90                   	nop
  802789:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802790:	89 d8                	mov    %ebx,%eax
  802792:	f7 f7                	div    %edi
  802794:	31 ff                	xor    %edi,%edi
  802796:	89 c3                	mov    %eax,%ebx
  802798:	89 d8                	mov    %ebx,%eax
  80279a:	89 fa                	mov    %edi,%edx
  80279c:	83 c4 1c             	add    $0x1c,%esp
  80279f:	5b                   	pop    %ebx
  8027a0:	5e                   	pop    %esi
  8027a1:	5f                   	pop    %edi
  8027a2:	5d                   	pop    %ebp
  8027a3:	c3                   	ret    
  8027a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027a8:	39 ce                	cmp    %ecx,%esi
  8027aa:	72 0c                	jb     8027b8 <__udivdi3+0x118>
  8027ac:	31 db                	xor    %ebx,%ebx
  8027ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8027b2:	0f 87 34 ff ff ff    	ja     8026ec <__udivdi3+0x4c>
  8027b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8027bd:	e9 2a ff ff ff       	jmp    8026ec <__udivdi3+0x4c>
  8027c2:	66 90                	xchg   %ax,%ax
  8027c4:	66 90                	xchg   %ax,%ax
  8027c6:	66 90                	xchg   %ax,%ax
  8027c8:	66 90                	xchg   %ax,%ax
  8027ca:	66 90                	xchg   %ax,%ax
  8027cc:	66 90                	xchg   %ax,%ax
  8027ce:	66 90                	xchg   %ax,%ax

008027d0 <__umoddi3>:
  8027d0:	55                   	push   %ebp
  8027d1:	57                   	push   %edi
  8027d2:	56                   	push   %esi
  8027d3:	53                   	push   %ebx
  8027d4:	83 ec 1c             	sub    $0x1c,%esp
  8027d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8027db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8027df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8027e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8027e7:	85 d2                	test   %edx,%edx
  8027e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8027ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027f1:	89 f3                	mov    %esi,%ebx
  8027f3:	89 3c 24             	mov    %edi,(%esp)
  8027f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027fa:	75 1c                	jne    802818 <__umoddi3+0x48>
  8027fc:	39 f7                	cmp    %esi,%edi
  8027fe:	76 50                	jbe    802850 <__umoddi3+0x80>
  802800:	89 c8                	mov    %ecx,%eax
  802802:	89 f2                	mov    %esi,%edx
  802804:	f7 f7                	div    %edi
  802806:	89 d0                	mov    %edx,%eax
  802808:	31 d2                	xor    %edx,%edx
  80280a:	83 c4 1c             	add    $0x1c,%esp
  80280d:	5b                   	pop    %ebx
  80280e:	5e                   	pop    %esi
  80280f:	5f                   	pop    %edi
  802810:	5d                   	pop    %ebp
  802811:	c3                   	ret    
  802812:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802818:	39 f2                	cmp    %esi,%edx
  80281a:	89 d0                	mov    %edx,%eax
  80281c:	77 52                	ja     802870 <__umoddi3+0xa0>
  80281e:	0f bd ea             	bsr    %edx,%ebp
  802821:	83 f5 1f             	xor    $0x1f,%ebp
  802824:	75 5a                	jne    802880 <__umoddi3+0xb0>
  802826:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80282a:	0f 82 e0 00 00 00    	jb     802910 <__umoddi3+0x140>
  802830:	39 0c 24             	cmp    %ecx,(%esp)
  802833:	0f 86 d7 00 00 00    	jbe    802910 <__umoddi3+0x140>
  802839:	8b 44 24 08          	mov    0x8(%esp),%eax
  80283d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802841:	83 c4 1c             	add    $0x1c,%esp
  802844:	5b                   	pop    %ebx
  802845:	5e                   	pop    %esi
  802846:	5f                   	pop    %edi
  802847:	5d                   	pop    %ebp
  802848:	c3                   	ret    
  802849:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802850:	85 ff                	test   %edi,%edi
  802852:	89 fd                	mov    %edi,%ebp
  802854:	75 0b                	jne    802861 <__umoddi3+0x91>
  802856:	b8 01 00 00 00       	mov    $0x1,%eax
  80285b:	31 d2                	xor    %edx,%edx
  80285d:	f7 f7                	div    %edi
  80285f:	89 c5                	mov    %eax,%ebp
  802861:	89 f0                	mov    %esi,%eax
  802863:	31 d2                	xor    %edx,%edx
  802865:	f7 f5                	div    %ebp
  802867:	89 c8                	mov    %ecx,%eax
  802869:	f7 f5                	div    %ebp
  80286b:	89 d0                	mov    %edx,%eax
  80286d:	eb 99                	jmp    802808 <__umoddi3+0x38>
  80286f:	90                   	nop
  802870:	89 c8                	mov    %ecx,%eax
  802872:	89 f2                	mov    %esi,%edx
  802874:	83 c4 1c             	add    $0x1c,%esp
  802877:	5b                   	pop    %ebx
  802878:	5e                   	pop    %esi
  802879:	5f                   	pop    %edi
  80287a:	5d                   	pop    %ebp
  80287b:	c3                   	ret    
  80287c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802880:	8b 34 24             	mov    (%esp),%esi
  802883:	bf 20 00 00 00       	mov    $0x20,%edi
  802888:	89 e9                	mov    %ebp,%ecx
  80288a:	29 ef                	sub    %ebp,%edi
  80288c:	d3 e0                	shl    %cl,%eax
  80288e:	89 f9                	mov    %edi,%ecx
  802890:	89 f2                	mov    %esi,%edx
  802892:	d3 ea                	shr    %cl,%edx
  802894:	89 e9                	mov    %ebp,%ecx
  802896:	09 c2                	or     %eax,%edx
  802898:	89 d8                	mov    %ebx,%eax
  80289a:	89 14 24             	mov    %edx,(%esp)
  80289d:	89 f2                	mov    %esi,%edx
  80289f:	d3 e2                	shl    %cl,%edx
  8028a1:	89 f9                	mov    %edi,%ecx
  8028a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8028a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8028ab:	d3 e8                	shr    %cl,%eax
  8028ad:	89 e9                	mov    %ebp,%ecx
  8028af:	89 c6                	mov    %eax,%esi
  8028b1:	d3 e3                	shl    %cl,%ebx
  8028b3:	89 f9                	mov    %edi,%ecx
  8028b5:	89 d0                	mov    %edx,%eax
  8028b7:	d3 e8                	shr    %cl,%eax
  8028b9:	89 e9                	mov    %ebp,%ecx
  8028bb:	09 d8                	or     %ebx,%eax
  8028bd:	89 d3                	mov    %edx,%ebx
  8028bf:	89 f2                	mov    %esi,%edx
  8028c1:	f7 34 24             	divl   (%esp)
  8028c4:	89 d6                	mov    %edx,%esi
  8028c6:	d3 e3                	shl    %cl,%ebx
  8028c8:	f7 64 24 04          	mull   0x4(%esp)
  8028cc:	39 d6                	cmp    %edx,%esi
  8028ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8028d2:	89 d1                	mov    %edx,%ecx
  8028d4:	89 c3                	mov    %eax,%ebx
  8028d6:	72 08                	jb     8028e0 <__umoddi3+0x110>
  8028d8:	75 11                	jne    8028eb <__umoddi3+0x11b>
  8028da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8028de:	73 0b                	jae    8028eb <__umoddi3+0x11b>
  8028e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8028e4:	1b 14 24             	sbb    (%esp),%edx
  8028e7:	89 d1                	mov    %edx,%ecx
  8028e9:	89 c3                	mov    %eax,%ebx
  8028eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8028ef:	29 da                	sub    %ebx,%edx
  8028f1:	19 ce                	sbb    %ecx,%esi
  8028f3:	89 f9                	mov    %edi,%ecx
  8028f5:	89 f0                	mov    %esi,%eax
  8028f7:	d3 e0                	shl    %cl,%eax
  8028f9:	89 e9                	mov    %ebp,%ecx
  8028fb:	d3 ea                	shr    %cl,%edx
  8028fd:	89 e9                	mov    %ebp,%ecx
  8028ff:	d3 ee                	shr    %cl,%esi
  802901:	09 d0                	or     %edx,%eax
  802903:	89 f2                	mov    %esi,%edx
  802905:	83 c4 1c             	add    $0x1c,%esp
  802908:	5b                   	pop    %ebx
  802909:	5e                   	pop    %esi
  80290a:	5f                   	pop    %edi
  80290b:	5d                   	pop    %ebp
  80290c:	c3                   	ret    
  80290d:	8d 76 00             	lea    0x0(%esi),%esi
  802910:	29 f9                	sub    %edi,%ecx
  802912:	19 d6                	sbb    %edx,%esi
  802914:	89 74 24 04          	mov    %esi,0x4(%esp)
  802918:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80291c:	e9 18 ff ff ff       	jmp    802839 <__umoddi3+0x69>
