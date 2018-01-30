
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
  800081:	68 0c 2c 80 00       	push   $0x802c0c
  800086:	6a 13                	push   $0x13
  800088:	68 1f 2c 80 00       	push   $0x802c1f
  80008d:	e8 69 01 00 00       	call   8001fb <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 ec 0e 00 00       	call   800f83 <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 33 2c 80 00       	push   $0x802c33
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 1f 2c 80 00       	push   $0x802c1f
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
  8000d2:	e8 b3 24 00 00       	call   80258a <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 40 80 00    	pushl  0x804004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 19 08 00 00       	call   800903 <strcmp>
  8000ea:	83 c4 08             	add    $0x8,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	ba 06 2c 80 00       	mov    $0x802c06,%edx
  8000f4:	b8 00 2c 80 00       	mov    $0x802c00,%eax
  8000f9:	0f 45 c2             	cmovne %edx,%eax
  8000fc:	50                   	push   %eax
  8000fd:	68 3c 2c 80 00       	push   $0x802c3c
  800102:	e8 cd 01 00 00       	call   8002d4 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800107:	6a 00                	push   $0x0
  800109:	68 57 2c 80 00       	push   $0x802c57
  80010e:	68 5c 2c 80 00       	push   $0x802c5c
  800113:	68 5b 2c 80 00       	push   $0x802c5b
  800118:	e8 95 20 00 00       	call   8021b2 <spawnl>
  80011d:	83 c4 20             	add    $0x20,%esp
  800120:	85 c0                	test   %eax,%eax
  800122:	79 12                	jns    800136 <umain+0xe3>
		panic("spawn: %e", r);
  800124:	50                   	push   %eax
  800125:	68 69 2c 80 00       	push   $0x802c69
  80012a:	6a 21                	push   $0x21
  80012c:	68 1f 2c 80 00       	push   $0x802c1f
  800131:	e8 c5 00 00 00       	call   8001fb <_panic>
	wait(r);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	e8 4b 24 00 00       	call   80258a <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff 35 00 40 80 00    	pushl  0x804000
  800148:	68 00 00 00 a0       	push   $0xa0000000
  80014d:	e8 b1 07 00 00       	call   800903 <strcmp>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba 06 2c 80 00       	mov    $0x802c06,%edx
  80015c:	b8 00 2c 80 00       	mov    $0x802c00,%eax
  800161:	0f 45 c2             	cmovne %edx,%eax
  800164:	50                   	push   %eax
  800165:	68 73 2c 80 00       	push   $0x802c73
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
  800198:	a3 04 50 80 00       	mov    %eax,0x805004
			thisenv = &envs[i];
		}
	}*/

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

void 
thread_main(/*uintptr_t eip*/)
{
  8001c1:	55                   	push   %ebp
  8001c2:	89 e5                	mov    %esp,%ebp
  8001c4:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

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
  8001e7:	e8 0b 14 00 00       	call   8015f7 <close_all>
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
  800219:	68 b8 2c 80 00       	push   $0x802cb8
  80021e:	e8 b1 00 00 00       	call   8002d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800223:	83 c4 18             	add    $0x18,%esp
  800226:	53                   	push   %ebx
  800227:	ff 75 10             	pushl  0x10(%ebp)
  80022a:	e8 54 00 00 00       	call   800283 <vcprintf>
	cprintf("\n");
  80022f:	c7 04 24 a6 30 80 00 	movl   $0x8030a6,(%esp)
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
  800337:	e8 24 26 00 00       	call   802960 <__udivdi3>
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
  80037a:	e8 11 27 00 00       	call   802a90 <__umoddi3>
  80037f:	83 c4 14             	add    $0x14,%esp
  800382:	0f be 80 db 2c 80 00 	movsbl 0x802cdb(%eax),%eax
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
  80047e:	ff 24 85 20 2e 80 00 	jmp    *0x802e20(,%eax,4)
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
  800542:	8b 14 85 80 2f 80 00 	mov    0x802f80(,%eax,4),%edx
  800549:	85 d2                	test   %edx,%edx
  80054b:	75 18                	jne    800565 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80054d:	50                   	push   %eax
  80054e:	68 f3 2c 80 00       	push   $0x802cf3
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
  800566:	68 0d 32 80 00       	push   $0x80320d
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
  80058a:	b8 ec 2c 80 00       	mov    $0x802cec,%eax
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
  800c05:	68 df 2f 80 00       	push   $0x802fdf
  800c0a:	6a 23                	push   $0x23
  800c0c:	68 fc 2f 80 00       	push   $0x802ffc
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
  800c86:	68 df 2f 80 00       	push   $0x802fdf
  800c8b:	6a 23                	push   $0x23
  800c8d:	68 fc 2f 80 00       	push   $0x802ffc
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
  800cc8:	68 df 2f 80 00       	push   $0x802fdf
  800ccd:	6a 23                	push   $0x23
  800ccf:	68 fc 2f 80 00       	push   $0x802ffc
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
  800d0a:	68 df 2f 80 00       	push   $0x802fdf
  800d0f:	6a 23                	push   $0x23
  800d11:	68 fc 2f 80 00       	push   $0x802ffc
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
  800d4c:	68 df 2f 80 00       	push   $0x802fdf
  800d51:	6a 23                	push   $0x23
  800d53:	68 fc 2f 80 00       	push   $0x802ffc
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
  800d8e:	68 df 2f 80 00       	push   $0x802fdf
  800d93:	6a 23                	push   $0x23
  800d95:	68 fc 2f 80 00       	push   $0x802ffc
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
  800dd0:	68 df 2f 80 00       	push   $0x802fdf
  800dd5:	6a 23                	push   $0x23
  800dd7:	68 fc 2f 80 00       	push   $0x802ffc
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
  800e34:	68 df 2f 80 00       	push   $0x802fdf
  800e39:	6a 23                	push   $0x23
  800e3b:	68 fc 2f 80 00       	push   $0x802ffc
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
  800ed3:	68 0a 30 80 00       	push   $0x80300a
  800ed8:	6a 1f                	push   $0x1f
  800eda:	68 1a 30 80 00       	push   $0x80301a
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
  800efd:	68 25 30 80 00       	push   $0x803025
  800f02:	6a 2d                	push   $0x2d
  800f04:	68 1a 30 80 00       	push   $0x80301a
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
  800f45:	68 25 30 80 00       	push   $0x803025
  800f4a:	6a 34                	push   $0x34
  800f4c:	68 1a 30 80 00       	push   $0x80301a
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
  800f6d:	68 25 30 80 00       	push   $0x803025
  800f72:	6a 38                	push   $0x38
  800f74:	68 1a 30 80 00       	push   $0x80301a
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
  800f91:	e8 cf 17 00 00       	call   802765 <set_pgfault_handler>
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
  800faa:	68 3e 30 80 00       	push   $0x80303e
  800faf:	68 85 00 00 00       	push   $0x85
  800fb4:	68 1a 30 80 00       	push   $0x80301a
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
  801066:	68 4c 30 80 00       	push   $0x80304c
  80106b:	6a 55                	push   $0x55
  80106d:	68 1a 30 80 00       	push   $0x80301a
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
  8010ab:	68 4c 30 80 00       	push   $0x80304c
  8010b0:	6a 5c                	push   $0x5c
  8010b2:	68 1a 30 80 00       	push   $0x80301a
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
  8010d9:	68 4c 30 80 00       	push   $0x80304c
  8010de:	6a 60                	push   $0x60
  8010e0:	68 1a 30 80 00       	push   $0x80301a
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
  801103:	68 4c 30 80 00       	push   $0x80304c
  801108:	6a 65                	push   $0x65
  80110a:	68 1a 30 80 00       	push   $0x80301a
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
  801168:	89 1d 08 50 80 00    	mov    %ebx,0x805008
	cprintf("in fork.c thread create. func: %x\n", func);
  80116e:	83 ec 08             	sub    $0x8,%esp
  801171:	53                   	push   %ebx
  801172:	68 dc 30 80 00       	push   $0x8030dc
  801177:	e8 58 f1 ff ff       	call   8002d4 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80117c:	c7 04 24 c1 01 80 00 	movl   $0x8001c1,(%esp)
  801183:	e8 c5 fc ff ff       	call   800e4d <sys_thread_create>
  801188:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80118a:	83 c4 08             	add    $0x8,%esp
  80118d:	53                   	push   %ebx
  80118e:	68 dc 30 80 00       	push   $0x8030dc
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

008011c7 <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	56                   	push   %esi
  8011cb:	53                   	push   %ebx
  8011cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8011cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8011d2:	83 ec 04             	sub    $0x4,%esp
  8011d5:	6a 07                	push   $0x7
  8011d7:	6a 00                	push   $0x0
  8011d9:	56                   	push   %esi
  8011da:	e8 7d fa ff ff       	call   800c5c <sys_page_alloc>
	if (r < 0) {
  8011df:	83 c4 10             	add    $0x10,%esp
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	79 15                	jns    8011fb <queue_append+0x34>
		panic("%e\n", r);
  8011e6:	50                   	push   %eax
  8011e7:	68 d8 30 80 00       	push   $0x8030d8
  8011ec:	68 c4 00 00 00       	push   $0xc4
  8011f1:	68 1a 30 80 00       	push   $0x80301a
  8011f6:	e8 00 f0 ff ff       	call   8001fb <_panic>
	}	
	wt->envid = envid;
  8011fb:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  801201:	83 ec 04             	sub    $0x4,%esp
  801204:	ff 33                	pushl  (%ebx)
  801206:	56                   	push   %esi
  801207:	68 00 31 80 00       	push   $0x803100
  80120c:	e8 c3 f0 ff ff       	call   8002d4 <cprintf>
	if (queue->first == NULL) {
  801211:	83 c4 10             	add    $0x10,%esp
  801214:	83 3b 00             	cmpl   $0x0,(%ebx)
  801217:	75 29                	jne    801242 <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  801219:	83 ec 0c             	sub    $0xc,%esp
  80121c:	68 62 30 80 00       	push   $0x803062
  801221:	e8 ae f0 ff ff       	call   8002d4 <cprintf>
		queue->first = wt;
  801226:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  80122c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  801233:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80123a:	00 00 00 
  80123d:	83 c4 10             	add    $0x10,%esp
  801240:	eb 2b                	jmp    80126d <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  801242:	83 ec 0c             	sub    $0xc,%esp
  801245:	68 7c 30 80 00       	push   $0x80307c
  80124a:	e8 85 f0 ff ff       	call   8002d4 <cprintf>
		queue->last->next = wt;
  80124f:	8b 43 04             	mov    0x4(%ebx),%eax
  801252:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  801259:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801260:	00 00 00 
		queue->last = wt;
  801263:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  80126a:	83 c4 10             	add    $0x10,%esp
	}
}
  80126d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801270:	5b                   	pop    %ebx
  801271:	5e                   	pop    %esi
  801272:	5d                   	pop    %ebp
  801273:	c3                   	ret    

00801274 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  801274:	55                   	push   %ebp
  801275:	89 e5                	mov    %esp,%ebp
  801277:	53                   	push   %ebx
  801278:	83 ec 04             	sub    $0x4,%esp
  80127b:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  80127e:	8b 02                	mov    (%edx),%eax
  801280:	85 c0                	test   %eax,%eax
  801282:	75 17                	jne    80129b <queue_pop+0x27>
		panic("queue empty!\n");
  801284:	83 ec 04             	sub    $0x4,%esp
  801287:	68 9a 30 80 00       	push   $0x80309a
  80128c:	68 d8 00 00 00       	push   $0xd8
  801291:	68 1a 30 80 00       	push   $0x80301a
  801296:	e8 60 ef ff ff       	call   8001fb <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  80129b:	8b 48 04             	mov    0x4(%eax),%ecx
  80129e:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  8012a0:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  8012a2:	83 ec 08             	sub    $0x8,%esp
  8012a5:	53                   	push   %ebx
  8012a6:	68 a8 30 80 00       	push   $0x8030a8
  8012ab:	e8 24 f0 ff ff       	call   8002d4 <cprintf>
	return envid;
}
  8012b0:	89 d8                	mov    %ebx,%eax
  8012b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b5:	c9                   	leave  
  8012b6:	c3                   	ret    

008012b7 <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  8012b7:	55                   	push   %ebp
  8012b8:	89 e5                	mov    %esp,%ebp
  8012ba:	53                   	push   %ebx
  8012bb:	83 ec 04             	sub    $0x4,%esp
  8012be:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  8012c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8012c6:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8012c9:	85 c0                	test   %eax,%eax
  8012cb:	74 5a                	je     801327 <mutex_lock+0x70>
  8012cd:	8b 43 04             	mov    0x4(%ebx),%eax
  8012d0:	83 38 00             	cmpl   $0x0,(%eax)
  8012d3:	75 52                	jne    801327 <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  8012d5:	83 ec 0c             	sub    $0xc,%esp
  8012d8:	68 28 31 80 00       	push   $0x803128
  8012dd:	e8 f2 ef ff ff       	call   8002d4 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  8012e2:	8b 5b 04             	mov    0x4(%ebx),%ebx
  8012e5:	e8 34 f9 ff ff       	call   800c1e <sys_getenvid>
  8012ea:	83 c4 08             	add    $0x8,%esp
  8012ed:	53                   	push   %ebx
  8012ee:	50                   	push   %eax
  8012ef:	e8 d3 fe ff ff       	call   8011c7 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  8012f4:	e8 25 f9 ff ff       	call   800c1e <sys_getenvid>
  8012f9:	83 c4 08             	add    $0x8,%esp
  8012fc:	6a 04                	push   $0x4
  8012fe:	50                   	push   %eax
  8012ff:	e8 1f fa ff ff       	call   800d23 <sys_env_set_status>
		if (r < 0) {
  801304:	83 c4 10             	add    $0x10,%esp
  801307:	85 c0                	test   %eax,%eax
  801309:	79 15                	jns    801320 <mutex_lock+0x69>
			panic("%e\n", r);
  80130b:	50                   	push   %eax
  80130c:	68 d8 30 80 00       	push   $0x8030d8
  801311:	68 eb 00 00 00       	push   $0xeb
  801316:	68 1a 30 80 00       	push   $0x80301a
  80131b:	e8 db ee ff ff       	call   8001fb <_panic>
		}
		sys_yield();
  801320:	e8 18 f9 ff ff       	call   800c3d <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801325:	eb 18                	jmp    80133f <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  801327:	83 ec 0c             	sub    $0xc,%esp
  80132a:	68 48 31 80 00       	push   $0x803148
  80132f:	e8 a0 ef ff ff       	call   8002d4 <cprintf>
	mtx->owner = sys_getenvid();}
  801334:	e8 e5 f8 ff ff       	call   800c1e <sys_getenvid>
  801339:	89 43 08             	mov    %eax,0x8(%ebx)
  80133c:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  80133f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801342:	c9                   	leave  
  801343:	c3                   	ret    

00801344 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  801344:	55                   	push   %ebp
  801345:	89 e5                	mov    %esp,%ebp
  801347:	53                   	push   %ebx
  801348:	83 ec 04             	sub    $0x4,%esp
  80134b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80134e:	b8 00 00 00 00       	mov    $0x0,%eax
  801353:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  801356:	8b 43 04             	mov    0x4(%ebx),%eax
  801359:	83 38 00             	cmpl   $0x0,(%eax)
  80135c:	74 33                	je     801391 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  80135e:	83 ec 0c             	sub    $0xc,%esp
  801361:	50                   	push   %eax
  801362:	e8 0d ff ff ff       	call   801274 <queue_pop>
  801367:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  80136a:	83 c4 08             	add    $0x8,%esp
  80136d:	6a 02                	push   $0x2
  80136f:	50                   	push   %eax
  801370:	e8 ae f9 ff ff       	call   800d23 <sys_env_set_status>
		if (r < 0) {
  801375:	83 c4 10             	add    $0x10,%esp
  801378:	85 c0                	test   %eax,%eax
  80137a:	79 15                	jns    801391 <mutex_unlock+0x4d>
			panic("%e\n", r);
  80137c:	50                   	push   %eax
  80137d:	68 d8 30 80 00       	push   $0x8030d8
  801382:	68 00 01 00 00       	push   $0x100
  801387:	68 1a 30 80 00       	push   $0x80301a
  80138c:	e8 6a ee ff ff       	call   8001fb <_panic>
		}
	}

	asm volatile("pause");
  801391:	f3 90                	pause  
	//sys_yield();
}
  801393:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801396:	c9                   	leave  
  801397:	c3                   	ret    

00801398 <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  801398:	55                   	push   %ebp
  801399:	89 e5                	mov    %esp,%ebp
  80139b:	53                   	push   %ebx
  80139c:	83 ec 04             	sub    $0x4,%esp
  80139f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8013a2:	e8 77 f8 ff ff       	call   800c1e <sys_getenvid>
  8013a7:	83 ec 04             	sub    $0x4,%esp
  8013aa:	6a 07                	push   $0x7
  8013ac:	53                   	push   %ebx
  8013ad:	50                   	push   %eax
  8013ae:	e8 a9 f8 ff ff       	call   800c5c <sys_page_alloc>
  8013b3:	83 c4 10             	add    $0x10,%esp
  8013b6:	85 c0                	test   %eax,%eax
  8013b8:	79 15                	jns    8013cf <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  8013ba:	50                   	push   %eax
  8013bb:	68 c3 30 80 00       	push   $0x8030c3
  8013c0:	68 0d 01 00 00       	push   $0x10d
  8013c5:	68 1a 30 80 00       	push   $0x80301a
  8013ca:	e8 2c ee ff ff       	call   8001fb <_panic>
	}	
	mtx->locked = 0;
  8013cf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  8013d5:	8b 43 04             	mov    0x4(%ebx),%eax
  8013d8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  8013de:	8b 43 04             	mov    0x4(%ebx),%eax
  8013e1:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  8013e8:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  8013ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f2:	c9                   	leave  
  8013f3:	c3                   	ret    

008013f4 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  8013f4:	55                   	push   %ebp
  8013f5:	89 e5                	mov    %esp,%ebp
  8013f7:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  8013fa:	e8 1f f8 ff ff       	call   800c1e <sys_getenvid>
  8013ff:	83 ec 08             	sub    $0x8,%esp
  801402:	ff 75 08             	pushl  0x8(%ebp)
  801405:	50                   	push   %eax
  801406:	e8 d6 f8 ff ff       	call   800ce1 <sys_page_unmap>
	if (r < 0) {
  80140b:	83 c4 10             	add    $0x10,%esp
  80140e:	85 c0                	test   %eax,%eax
  801410:	79 15                	jns    801427 <mutex_destroy+0x33>
		panic("%e\n", r);
  801412:	50                   	push   %eax
  801413:	68 d8 30 80 00       	push   $0x8030d8
  801418:	68 1a 01 00 00       	push   $0x11a
  80141d:	68 1a 30 80 00       	push   $0x80301a
  801422:	e8 d4 ed ff ff       	call   8001fb <_panic>
	}
}
  801427:	c9                   	leave  
  801428:	c3                   	ret    

00801429 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801429:	55                   	push   %ebp
  80142a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80142c:	8b 45 08             	mov    0x8(%ebp),%eax
  80142f:	05 00 00 00 30       	add    $0x30000000,%eax
  801434:	c1 e8 0c             	shr    $0xc,%eax
}
  801437:	5d                   	pop    %ebp
  801438:	c3                   	ret    

00801439 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801439:	55                   	push   %ebp
  80143a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80143c:	8b 45 08             	mov    0x8(%ebp),%eax
  80143f:	05 00 00 00 30       	add    $0x30000000,%eax
  801444:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801449:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80144e:	5d                   	pop    %ebp
  80144f:	c3                   	ret    

00801450 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801456:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80145b:	89 c2                	mov    %eax,%edx
  80145d:	c1 ea 16             	shr    $0x16,%edx
  801460:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801467:	f6 c2 01             	test   $0x1,%dl
  80146a:	74 11                	je     80147d <fd_alloc+0x2d>
  80146c:	89 c2                	mov    %eax,%edx
  80146e:	c1 ea 0c             	shr    $0xc,%edx
  801471:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801478:	f6 c2 01             	test   $0x1,%dl
  80147b:	75 09                	jne    801486 <fd_alloc+0x36>
			*fd_store = fd;
  80147d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80147f:	b8 00 00 00 00       	mov    $0x0,%eax
  801484:	eb 17                	jmp    80149d <fd_alloc+0x4d>
  801486:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80148b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801490:	75 c9                	jne    80145b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801492:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801498:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80149d:	5d                   	pop    %ebp
  80149e:	c3                   	ret    

0080149f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80149f:	55                   	push   %ebp
  8014a0:	89 e5                	mov    %esp,%ebp
  8014a2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014a5:	83 f8 1f             	cmp    $0x1f,%eax
  8014a8:	77 36                	ja     8014e0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014aa:	c1 e0 0c             	shl    $0xc,%eax
  8014ad:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014b2:	89 c2                	mov    %eax,%edx
  8014b4:	c1 ea 16             	shr    $0x16,%edx
  8014b7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014be:	f6 c2 01             	test   $0x1,%dl
  8014c1:	74 24                	je     8014e7 <fd_lookup+0x48>
  8014c3:	89 c2                	mov    %eax,%edx
  8014c5:	c1 ea 0c             	shr    $0xc,%edx
  8014c8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014cf:	f6 c2 01             	test   $0x1,%dl
  8014d2:	74 1a                	je     8014ee <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014d7:	89 02                	mov    %eax,(%edx)
	return 0;
  8014d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8014de:	eb 13                	jmp    8014f3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014e0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014e5:	eb 0c                	jmp    8014f3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014ec:	eb 05                	jmp    8014f3 <fd_lookup+0x54>
  8014ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014f3:	5d                   	pop    %ebp
  8014f4:	c3                   	ret    

008014f5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014f5:	55                   	push   %ebp
  8014f6:	89 e5                	mov    %esp,%ebp
  8014f8:	83 ec 08             	sub    $0x8,%esp
  8014fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014fe:	ba e4 31 80 00       	mov    $0x8031e4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801503:	eb 13                	jmp    801518 <dev_lookup+0x23>
  801505:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801508:	39 08                	cmp    %ecx,(%eax)
  80150a:	75 0c                	jne    801518 <dev_lookup+0x23>
			*dev = devtab[i];
  80150c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80150f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801511:	b8 00 00 00 00       	mov    $0x0,%eax
  801516:	eb 31                	jmp    801549 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801518:	8b 02                	mov    (%edx),%eax
  80151a:	85 c0                	test   %eax,%eax
  80151c:	75 e7                	jne    801505 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80151e:	a1 04 50 80 00       	mov    0x805004,%eax
  801523:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801529:	83 ec 04             	sub    $0x4,%esp
  80152c:	51                   	push   %ecx
  80152d:	50                   	push   %eax
  80152e:	68 68 31 80 00       	push   $0x803168
  801533:	e8 9c ed ff ff       	call   8002d4 <cprintf>
	*dev = 0;
  801538:	8b 45 0c             	mov    0xc(%ebp),%eax
  80153b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801541:	83 c4 10             	add    $0x10,%esp
  801544:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801549:	c9                   	leave  
  80154a:	c3                   	ret    

0080154b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80154b:	55                   	push   %ebp
  80154c:	89 e5                	mov    %esp,%ebp
  80154e:	56                   	push   %esi
  80154f:	53                   	push   %ebx
  801550:	83 ec 10             	sub    $0x10,%esp
  801553:	8b 75 08             	mov    0x8(%ebp),%esi
  801556:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801559:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155c:	50                   	push   %eax
  80155d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801563:	c1 e8 0c             	shr    $0xc,%eax
  801566:	50                   	push   %eax
  801567:	e8 33 ff ff ff       	call   80149f <fd_lookup>
  80156c:	83 c4 08             	add    $0x8,%esp
  80156f:	85 c0                	test   %eax,%eax
  801571:	78 05                	js     801578 <fd_close+0x2d>
	    || fd != fd2)
  801573:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801576:	74 0c                	je     801584 <fd_close+0x39>
		return (must_exist ? r : 0);
  801578:	84 db                	test   %bl,%bl
  80157a:	ba 00 00 00 00       	mov    $0x0,%edx
  80157f:	0f 44 c2             	cmove  %edx,%eax
  801582:	eb 41                	jmp    8015c5 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801584:	83 ec 08             	sub    $0x8,%esp
  801587:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80158a:	50                   	push   %eax
  80158b:	ff 36                	pushl  (%esi)
  80158d:	e8 63 ff ff ff       	call   8014f5 <dev_lookup>
  801592:	89 c3                	mov    %eax,%ebx
  801594:	83 c4 10             	add    $0x10,%esp
  801597:	85 c0                	test   %eax,%eax
  801599:	78 1a                	js     8015b5 <fd_close+0x6a>
		if (dev->dev_close)
  80159b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8015a1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8015a6:	85 c0                	test   %eax,%eax
  8015a8:	74 0b                	je     8015b5 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8015aa:	83 ec 0c             	sub    $0xc,%esp
  8015ad:	56                   	push   %esi
  8015ae:	ff d0                	call   *%eax
  8015b0:	89 c3                	mov    %eax,%ebx
  8015b2:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015b5:	83 ec 08             	sub    $0x8,%esp
  8015b8:	56                   	push   %esi
  8015b9:	6a 00                	push   $0x0
  8015bb:	e8 21 f7 ff ff       	call   800ce1 <sys_page_unmap>
	return r;
  8015c0:	83 c4 10             	add    $0x10,%esp
  8015c3:	89 d8                	mov    %ebx,%eax
}
  8015c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c8:	5b                   	pop    %ebx
  8015c9:	5e                   	pop    %esi
  8015ca:	5d                   	pop    %ebp
  8015cb:	c3                   	ret    

008015cc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d5:	50                   	push   %eax
  8015d6:	ff 75 08             	pushl  0x8(%ebp)
  8015d9:	e8 c1 fe ff ff       	call   80149f <fd_lookup>
  8015de:	83 c4 08             	add    $0x8,%esp
  8015e1:	85 c0                	test   %eax,%eax
  8015e3:	78 10                	js     8015f5 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8015e5:	83 ec 08             	sub    $0x8,%esp
  8015e8:	6a 01                	push   $0x1
  8015ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8015ed:	e8 59 ff ff ff       	call   80154b <fd_close>
  8015f2:	83 c4 10             	add    $0x10,%esp
}
  8015f5:	c9                   	leave  
  8015f6:	c3                   	ret    

008015f7 <close_all>:

void
close_all(void)
{
  8015f7:	55                   	push   %ebp
  8015f8:	89 e5                	mov    %esp,%ebp
  8015fa:	53                   	push   %ebx
  8015fb:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015fe:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801603:	83 ec 0c             	sub    $0xc,%esp
  801606:	53                   	push   %ebx
  801607:	e8 c0 ff ff ff       	call   8015cc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80160c:	83 c3 01             	add    $0x1,%ebx
  80160f:	83 c4 10             	add    $0x10,%esp
  801612:	83 fb 20             	cmp    $0x20,%ebx
  801615:	75 ec                	jne    801603 <close_all+0xc>
		close(i);
}
  801617:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161a:	c9                   	leave  
  80161b:	c3                   	ret    

0080161c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	57                   	push   %edi
  801620:	56                   	push   %esi
  801621:	53                   	push   %ebx
  801622:	83 ec 2c             	sub    $0x2c,%esp
  801625:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801628:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80162b:	50                   	push   %eax
  80162c:	ff 75 08             	pushl  0x8(%ebp)
  80162f:	e8 6b fe ff ff       	call   80149f <fd_lookup>
  801634:	83 c4 08             	add    $0x8,%esp
  801637:	85 c0                	test   %eax,%eax
  801639:	0f 88 c1 00 00 00    	js     801700 <dup+0xe4>
		return r;
	close(newfdnum);
  80163f:	83 ec 0c             	sub    $0xc,%esp
  801642:	56                   	push   %esi
  801643:	e8 84 ff ff ff       	call   8015cc <close>

	newfd = INDEX2FD(newfdnum);
  801648:	89 f3                	mov    %esi,%ebx
  80164a:	c1 e3 0c             	shl    $0xc,%ebx
  80164d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801653:	83 c4 04             	add    $0x4,%esp
  801656:	ff 75 e4             	pushl  -0x1c(%ebp)
  801659:	e8 db fd ff ff       	call   801439 <fd2data>
  80165e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801660:	89 1c 24             	mov    %ebx,(%esp)
  801663:	e8 d1 fd ff ff       	call   801439 <fd2data>
  801668:	83 c4 10             	add    $0x10,%esp
  80166b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80166e:	89 f8                	mov    %edi,%eax
  801670:	c1 e8 16             	shr    $0x16,%eax
  801673:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80167a:	a8 01                	test   $0x1,%al
  80167c:	74 37                	je     8016b5 <dup+0x99>
  80167e:	89 f8                	mov    %edi,%eax
  801680:	c1 e8 0c             	shr    $0xc,%eax
  801683:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80168a:	f6 c2 01             	test   $0x1,%dl
  80168d:	74 26                	je     8016b5 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80168f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801696:	83 ec 0c             	sub    $0xc,%esp
  801699:	25 07 0e 00 00       	and    $0xe07,%eax
  80169e:	50                   	push   %eax
  80169f:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016a2:	6a 00                	push   $0x0
  8016a4:	57                   	push   %edi
  8016a5:	6a 00                	push   $0x0
  8016a7:	e8 f3 f5 ff ff       	call   800c9f <sys_page_map>
  8016ac:	89 c7                	mov    %eax,%edi
  8016ae:	83 c4 20             	add    $0x20,%esp
  8016b1:	85 c0                	test   %eax,%eax
  8016b3:	78 2e                	js     8016e3 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016b8:	89 d0                	mov    %edx,%eax
  8016ba:	c1 e8 0c             	shr    $0xc,%eax
  8016bd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016c4:	83 ec 0c             	sub    $0xc,%esp
  8016c7:	25 07 0e 00 00       	and    $0xe07,%eax
  8016cc:	50                   	push   %eax
  8016cd:	53                   	push   %ebx
  8016ce:	6a 00                	push   $0x0
  8016d0:	52                   	push   %edx
  8016d1:	6a 00                	push   $0x0
  8016d3:	e8 c7 f5 ff ff       	call   800c9f <sys_page_map>
  8016d8:	89 c7                	mov    %eax,%edi
  8016da:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8016dd:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016df:	85 ff                	test   %edi,%edi
  8016e1:	79 1d                	jns    801700 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016e3:	83 ec 08             	sub    $0x8,%esp
  8016e6:	53                   	push   %ebx
  8016e7:	6a 00                	push   $0x0
  8016e9:	e8 f3 f5 ff ff       	call   800ce1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016ee:	83 c4 08             	add    $0x8,%esp
  8016f1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016f4:	6a 00                	push   $0x0
  8016f6:	e8 e6 f5 ff ff       	call   800ce1 <sys_page_unmap>
	return r;
  8016fb:	83 c4 10             	add    $0x10,%esp
  8016fe:	89 f8                	mov    %edi,%eax
}
  801700:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801703:	5b                   	pop    %ebx
  801704:	5e                   	pop    %esi
  801705:	5f                   	pop    %edi
  801706:	5d                   	pop    %ebp
  801707:	c3                   	ret    

00801708 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801708:	55                   	push   %ebp
  801709:	89 e5                	mov    %esp,%ebp
  80170b:	53                   	push   %ebx
  80170c:	83 ec 14             	sub    $0x14,%esp
  80170f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801712:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801715:	50                   	push   %eax
  801716:	53                   	push   %ebx
  801717:	e8 83 fd ff ff       	call   80149f <fd_lookup>
  80171c:	83 c4 08             	add    $0x8,%esp
  80171f:	89 c2                	mov    %eax,%edx
  801721:	85 c0                	test   %eax,%eax
  801723:	78 70                	js     801795 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801725:	83 ec 08             	sub    $0x8,%esp
  801728:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80172b:	50                   	push   %eax
  80172c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80172f:	ff 30                	pushl  (%eax)
  801731:	e8 bf fd ff ff       	call   8014f5 <dev_lookup>
  801736:	83 c4 10             	add    $0x10,%esp
  801739:	85 c0                	test   %eax,%eax
  80173b:	78 4f                	js     80178c <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80173d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801740:	8b 42 08             	mov    0x8(%edx),%eax
  801743:	83 e0 03             	and    $0x3,%eax
  801746:	83 f8 01             	cmp    $0x1,%eax
  801749:	75 24                	jne    80176f <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80174b:	a1 04 50 80 00       	mov    0x805004,%eax
  801750:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801756:	83 ec 04             	sub    $0x4,%esp
  801759:	53                   	push   %ebx
  80175a:	50                   	push   %eax
  80175b:	68 a9 31 80 00       	push   $0x8031a9
  801760:	e8 6f eb ff ff       	call   8002d4 <cprintf>
		return -E_INVAL;
  801765:	83 c4 10             	add    $0x10,%esp
  801768:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80176d:	eb 26                	jmp    801795 <read+0x8d>
	}
	if (!dev->dev_read)
  80176f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801772:	8b 40 08             	mov    0x8(%eax),%eax
  801775:	85 c0                	test   %eax,%eax
  801777:	74 17                	je     801790 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801779:	83 ec 04             	sub    $0x4,%esp
  80177c:	ff 75 10             	pushl  0x10(%ebp)
  80177f:	ff 75 0c             	pushl  0xc(%ebp)
  801782:	52                   	push   %edx
  801783:	ff d0                	call   *%eax
  801785:	89 c2                	mov    %eax,%edx
  801787:	83 c4 10             	add    $0x10,%esp
  80178a:	eb 09                	jmp    801795 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80178c:	89 c2                	mov    %eax,%edx
  80178e:	eb 05                	jmp    801795 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801790:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801795:	89 d0                	mov    %edx,%eax
  801797:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179a:	c9                   	leave  
  80179b:	c3                   	ret    

0080179c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80179c:	55                   	push   %ebp
  80179d:	89 e5                	mov    %esp,%ebp
  80179f:	57                   	push   %edi
  8017a0:	56                   	push   %esi
  8017a1:	53                   	push   %ebx
  8017a2:	83 ec 0c             	sub    $0xc,%esp
  8017a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017a8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017b0:	eb 21                	jmp    8017d3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017b2:	83 ec 04             	sub    $0x4,%esp
  8017b5:	89 f0                	mov    %esi,%eax
  8017b7:	29 d8                	sub    %ebx,%eax
  8017b9:	50                   	push   %eax
  8017ba:	89 d8                	mov    %ebx,%eax
  8017bc:	03 45 0c             	add    0xc(%ebp),%eax
  8017bf:	50                   	push   %eax
  8017c0:	57                   	push   %edi
  8017c1:	e8 42 ff ff ff       	call   801708 <read>
		if (m < 0)
  8017c6:	83 c4 10             	add    $0x10,%esp
  8017c9:	85 c0                	test   %eax,%eax
  8017cb:	78 10                	js     8017dd <readn+0x41>
			return m;
		if (m == 0)
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	74 0a                	je     8017db <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017d1:	01 c3                	add    %eax,%ebx
  8017d3:	39 f3                	cmp    %esi,%ebx
  8017d5:	72 db                	jb     8017b2 <readn+0x16>
  8017d7:	89 d8                	mov    %ebx,%eax
  8017d9:	eb 02                	jmp    8017dd <readn+0x41>
  8017db:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8017dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017e0:	5b                   	pop    %ebx
  8017e1:	5e                   	pop    %esi
  8017e2:	5f                   	pop    %edi
  8017e3:	5d                   	pop    %ebp
  8017e4:	c3                   	ret    

008017e5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017e5:	55                   	push   %ebp
  8017e6:	89 e5                	mov    %esp,%ebp
  8017e8:	53                   	push   %ebx
  8017e9:	83 ec 14             	sub    $0x14,%esp
  8017ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017f2:	50                   	push   %eax
  8017f3:	53                   	push   %ebx
  8017f4:	e8 a6 fc ff ff       	call   80149f <fd_lookup>
  8017f9:	83 c4 08             	add    $0x8,%esp
  8017fc:	89 c2                	mov    %eax,%edx
  8017fe:	85 c0                	test   %eax,%eax
  801800:	78 6b                	js     80186d <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801802:	83 ec 08             	sub    $0x8,%esp
  801805:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801808:	50                   	push   %eax
  801809:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80180c:	ff 30                	pushl  (%eax)
  80180e:	e8 e2 fc ff ff       	call   8014f5 <dev_lookup>
  801813:	83 c4 10             	add    $0x10,%esp
  801816:	85 c0                	test   %eax,%eax
  801818:	78 4a                	js     801864 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80181a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80181d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801821:	75 24                	jne    801847 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801823:	a1 04 50 80 00       	mov    0x805004,%eax
  801828:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80182e:	83 ec 04             	sub    $0x4,%esp
  801831:	53                   	push   %ebx
  801832:	50                   	push   %eax
  801833:	68 c5 31 80 00       	push   $0x8031c5
  801838:	e8 97 ea ff ff       	call   8002d4 <cprintf>
		return -E_INVAL;
  80183d:	83 c4 10             	add    $0x10,%esp
  801840:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801845:	eb 26                	jmp    80186d <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801847:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80184a:	8b 52 0c             	mov    0xc(%edx),%edx
  80184d:	85 d2                	test   %edx,%edx
  80184f:	74 17                	je     801868 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801851:	83 ec 04             	sub    $0x4,%esp
  801854:	ff 75 10             	pushl  0x10(%ebp)
  801857:	ff 75 0c             	pushl  0xc(%ebp)
  80185a:	50                   	push   %eax
  80185b:	ff d2                	call   *%edx
  80185d:	89 c2                	mov    %eax,%edx
  80185f:	83 c4 10             	add    $0x10,%esp
  801862:	eb 09                	jmp    80186d <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801864:	89 c2                	mov    %eax,%edx
  801866:	eb 05                	jmp    80186d <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801868:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80186d:	89 d0                	mov    %edx,%eax
  80186f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801872:	c9                   	leave  
  801873:	c3                   	ret    

00801874 <seek>:

int
seek(int fdnum, off_t offset)
{
  801874:	55                   	push   %ebp
  801875:	89 e5                	mov    %esp,%ebp
  801877:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80187a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80187d:	50                   	push   %eax
  80187e:	ff 75 08             	pushl  0x8(%ebp)
  801881:	e8 19 fc ff ff       	call   80149f <fd_lookup>
  801886:	83 c4 08             	add    $0x8,%esp
  801889:	85 c0                	test   %eax,%eax
  80188b:	78 0e                	js     80189b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80188d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801890:	8b 55 0c             	mov    0xc(%ebp),%edx
  801893:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801896:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80189b:	c9                   	leave  
  80189c:	c3                   	ret    

0080189d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80189d:	55                   	push   %ebp
  80189e:	89 e5                	mov    %esp,%ebp
  8018a0:	53                   	push   %ebx
  8018a1:	83 ec 14             	sub    $0x14,%esp
  8018a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018aa:	50                   	push   %eax
  8018ab:	53                   	push   %ebx
  8018ac:	e8 ee fb ff ff       	call   80149f <fd_lookup>
  8018b1:	83 c4 08             	add    $0x8,%esp
  8018b4:	89 c2                	mov    %eax,%edx
  8018b6:	85 c0                	test   %eax,%eax
  8018b8:	78 68                	js     801922 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018ba:	83 ec 08             	sub    $0x8,%esp
  8018bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c0:	50                   	push   %eax
  8018c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c4:	ff 30                	pushl  (%eax)
  8018c6:	e8 2a fc ff ff       	call   8014f5 <dev_lookup>
  8018cb:	83 c4 10             	add    $0x10,%esp
  8018ce:	85 c0                	test   %eax,%eax
  8018d0:	78 47                	js     801919 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018d9:	75 24                	jne    8018ff <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018db:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018e0:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8018e6:	83 ec 04             	sub    $0x4,%esp
  8018e9:	53                   	push   %ebx
  8018ea:	50                   	push   %eax
  8018eb:	68 88 31 80 00       	push   $0x803188
  8018f0:	e8 df e9 ff ff       	call   8002d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018f5:	83 c4 10             	add    $0x10,%esp
  8018f8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018fd:	eb 23                	jmp    801922 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  8018ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801902:	8b 52 18             	mov    0x18(%edx),%edx
  801905:	85 d2                	test   %edx,%edx
  801907:	74 14                	je     80191d <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801909:	83 ec 08             	sub    $0x8,%esp
  80190c:	ff 75 0c             	pushl  0xc(%ebp)
  80190f:	50                   	push   %eax
  801910:	ff d2                	call   *%edx
  801912:	89 c2                	mov    %eax,%edx
  801914:	83 c4 10             	add    $0x10,%esp
  801917:	eb 09                	jmp    801922 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801919:	89 c2                	mov    %eax,%edx
  80191b:	eb 05                	jmp    801922 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80191d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801922:	89 d0                	mov    %edx,%eax
  801924:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801927:	c9                   	leave  
  801928:	c3                   	ret    

00801929 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801929:	55                   	push   %ebp
  80192a:	89 e5                	mov    %esp,%ebp
  80192c:	53                   	push   %ebx
  80192d:	83 ec 14             	sub    $0x14,%esp
  801930:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801933:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801936:	50                   	push   %eax
  801937:	ff 75 08             	pushl  0x8(%ebp)
  80193a:	e8 60 fb ff ff       	call   80149f <fd_lookup>
  80193f:	83 c4 08             	add    $0x8,%esp
  801942:	89 c2                	mov    %eax,%edx
  801944:	85 c0                	test   %eax,%eax
  801946:	78 58                	js     8019a0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801948:	83 ec 08             	sub    $0x8,%esp
  80194b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80194e:	50                   	push   %eax
  80194f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801952:	ff 30                	pushl  (%eax)
  801954:	e8 9c fb ff ff       	call   8014f5 <dev_lookup>
  801959:	83 c4 10             	add    $0x10,%esp
  80195c:	85 c0                	test   %eax,%eax
  80195e:	78 37                	js     801997 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801960:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801963:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801967:	74 32                	je     80199b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801969:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80196c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801973:	00 00 00 
	stat->st_isdir = 0;
  801976:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80197d:	00 00 00 
	stat->st_dev = dev;
  801980:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801986:	83 ec 08             	sub    $0x8,%esp
  801989:	53                   	push   %ebx
  80198a:	ff 75 f0             	pushl  -0x10(%ebp)
  80198d:	ff 50 14             	call   *0x14(%eax)
  801990:	89 c2                	mov    %eax,%edx
  801992:	83 c4 10             	add    $0x10,%esp
  801995:	eb 09                	jmp    8019a0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801997:	89 c2                	mov    %eax,%edx
  801999:	eb 05                	jmp    8019a0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80199b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019a0:	89 d0                	mov    %edx,%eax
  8019a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a5:	c9                   	leave  
  8019a6:	c3                   	ret    

008019a7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019a7:	55                   	push   %ebp
  8019a8:	89 e5                	mov    %esp,%ebp
  8019aa:	56                   	push   %esi
  8019ab:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019ac:	83 ec 08             	sub    $0x8,%esp
  8019af:	6a 00                	push   $0x0
  8019b1:	ff 75 08             	pushl  0x8(%ebp)
  8019b4:	e8 e3 01 00 00       	call   801b9c <open>
  8019b9:	89 c3                	mov    %eax,%ebx
  8019bb:	83 c4 10             	add    $0x10,%esp
  8019be:	85 c0                	test   %eax,%eax
  8019c0:	78 1b                	js     8019dd <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019c2:	83 ec 08             	sub    $0x8,%esp
  8019c5:	ff 75 0c             	pushl  0xc(%ebp)
  8019c8:	50                   	push   %eax
  8019c9:	e8 5b ff ff ff       	call   801929 <fstat>
  8019ce:	89 c6                	mov    %eax,%esi
	close(fd);
  8019d0:	89 1c 24             	mov    %ebx,(%esp)
  8019d3:	e8 f4 fb ff ff       	call   8015cc <close>
	return r;
  8019d8:	83 c4 10             	add    $0x10,%esp
  8019db:	89 f0                	mov    %esi,%eax
}
  8019dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019e0:	5b                   	pop    %ebx
  8019e1:	5e                   	pop    %esi
  8019e2:	5d                   	pop    %ebp
  8019e3:	c3                   	ret    

008019e4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019e4:	55                   	push   %ebp
  8019e5:	89 e5                	mov    %esp,%ebp
  8019e7:	56                   	push   %esi
  8019e8:	53                   	push   %ebx
  8019e9:	89 c6                	mov    %eax,%esi
  8019eb:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019ed:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8019f4:	75 12                	jne    801a08 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019f6:	83 ec 0c             	sub    $0xc,%esp
  8019f9:	6a 01                	push   $0x1
  8019fb:	e8 d1 0e 00 00       	call   8028d1 <ipc_find_env>
  801a00:	a3 00 50 80 00       	mov    %eax,0x805000
  801a05:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a08:	6a 07                	push   $0x7
  801a0a:	68 00 60 80 00       	push   $0x806000
  801a0f:	56                   	push   %esi
  801a10:	ff 35 00 50 80 00    	pushl  0x805000
  801a16:	e8 54 0e 00 00       	call   80286f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a1b:	83 c4 0c             	add    $0xc,%esp
  801a1e:	6a 00                	push   $0x0
  801a20:	53                   	push   %ebx
  801a21:	6a 00                	push   $0x0
  801a23:	e8 cc 0d 00 00       	call   8027f4 <ipc_recv>
}
  801a28:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a2b:	5b                   	pop    %ebx
  801a2c:	5e                   	pop    %esi
  801a2d:	5d                   	pop    %ebp
  801a2e:	c3                   	ret    

00801a2f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a2f:	55                   	push   %ebp
  801a30:	89 e5                	mov    %esp,%ebp
  801a32:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a35:	8b 45 08             	mov    0x8(%ebp),%eax
  801a38:	8b 40 0c             	mov    0xc(%eax),%eax
  801a3b:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801a40:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a43:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a48:	ba 00 00 00 00       	mov    $0x0,%edx
  801a4d:	b8 02 00 00 00       	mov    $0x2,%eax
  801a52:	e8 8d ff ff ff       	call   8019e4 <fsipc>
}
  801a57:	c9                   	leave  
  801a58:	c3                   	ret    

00801a59 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a59:	55                   	push   %ebp
  801a5a:	89 e5                	mov    %esp,%ebp
  801a5c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a62:	8b 40 0c             	mov    0xc(%eax),%eax
  801a65:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801a6a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a6f:	b8 06 00 00 00       	mov    $0x6,%eax
  801a74:	e8 6b ff ff ff       	call   8019e4 <fsipc>
}
  801a79:	c9                   	leave  
  801a7a:	c3                   	ret    

00801a7b <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a7b:	55                   	push   %ebp
  801a7c:	89 e5                	mov    %esp,%ebp
  801a7e:	53                   	push   %ebx
  801a7f:	83 ec 04             	sub    $0x4,%esp
  801a82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a85:	8b 45 08             	mov    0x8(%ebp),%eax
  801a88:	8b 40 0c             	mov    0xc(%eax),%eax
  801a8b:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a90:	ba 00 00 00 00       	mov    $0x0,%edx
  801a95:	b8 05 00 00 00       	mov    $0x5,%eax
  801a9a:	e8 45 ff ff ff       	call   8019e4 <fsipc>
  801a9f:	85 c0                	test   %eax,%eax
  801aa1:	78 2c                	js     801acf <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801aa3:	83 ec 08             	sub    $0x8,%esp
  801aa6:	68 00 60 80 00       	push   $0x806000
  801aab:	53                   	push   %ebx
  801aac:	e8 a8 ed ff ff       	call   800859 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ab1:	a1 80 60 80 00       	mov    0x806080,%eax
  801ab6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801abc:	a1 84 60 80 00       	mov    0x806084,%eax
  801ac1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ac7:	83 c4 10             	add    $0x10,%esp
  801aca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801acf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ad2:	c9                   	leave  
  801ad3:	c3                   	ret    

00801ad4 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801ad4:	55                   	push   %ebp
  801ad5:	89 e5                	mov    %esp,%ebp
  801ad7:	83 ec 0c             	sub    $0xc,%esp
  801ada:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801add:	8b 55 08             	mov    0x8(%ebp),%edx
  801ae0:	8b 52 0c             	mov    0xc(%edx),%edx
  801ae3:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801ae9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801aee:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801af3:	0f 47 c2             	cmova  %edx,%eax
  801af6:	a3 04 60 80 00       	mov    %eax,0x806004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801afb:	50                   	push   %eax
  801afc:	ff 75 0c             	pushl  0xc(%ebp)
  801aff:	68 08 60 80 00       	push   $0x806008
  801b04:	e8 e2 ee ff ff       	call   8009eb <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801b09:	ba 00 00 00 00       	mov    $0x0,%edx
  801b0e:	b8 04 00 00 00       	mov    $0x4,%eax
  801b13:	e8 cc fe ff ff       	call   8019e4 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801b18:	c9                   	leave  
  801b19:	c3                   	ret    

00801b1a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b1a:	55                   	push   %ebp
  801b1b:	89 e5                	mov    %esp,%ebp
  801b1d:	56                   	push   %esi
  801b1e:	53                   	push   %ebx
  801b1f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b22:	8b 45 08             	mov    0x8(%ebp),%eax
  801b25:	8b 40 0c             	mov    0xc(%eax),%eax
  801b28:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801b2d:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b33:	ba 00 00 00 00       	mov    $0x0,%edx
  801b38:	b8 03 00 00 00       	mov    $0x3,%eax
  801b3d:	e8 a2 fe ff ff       	call   8019e4 <fsipc>
  801b42:	89 c3                	mov    %eax,%ebx
  801b44:	85 c0                	test   %eax,%eax
  801b46:	78 4b                	js     801b93 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b48:	39 c6                	cmp    %eax,%esi
  801b4a:	73 16                	jae    801b62 <devfile_read+0x48>
  801b4c:	68 f4 31 80 00       	push   $0x8031f4
  801b51:	68 fb 31 80 00       	push   $0x8031fb
  801b56:	6a 7c                	push   $0x7c
  801b58:	68 10 32 80 00       	push   $0x803210
  801b5d:	e8 99 e6 ff ff       	call   8001fb <_panic>
	assert(r <= PGSIZE);
  801b62:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b67:	7e 16                	jle    801b7f <devfile_read+0x65>
  801b69:	68 1b 32 80 00       	push   $0x80321b
  801b6e:	68 fb 31 80 00       	push   $0x8031fb
  801b73:	6a 7d                	push   $0x7d
  801b75:	68 10 32 80 00       	push   $0x803210
  801b7a:	e8 7c e6 ff ff       	call   8001fb <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b7f:	83 ec 04             	sub    $0x4,%esp
  801b82:	50                   	push   %eax
  801b83:	68 00 60 80 00       	push   $0x806000
  801b88:	ff 75 0c             	pushl  0xc(%ebp)
  801b8b:	e8 5b ee ff ff       	call   8009eb <memmove>
	return r;
  801b90:	83 c4 10             	add    $0x10,%esp
}
  801b93:	89 d8                	mov    %ebx,%eax
  801b95:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b98:	5b                   	pop    %ebx
  801b99:	5e                   	pop    %esi
  801b9a:	5d                   	pop    %ebp
  801b9b:	c3                   	ret    

00801b9c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b9c:	55                   	push   %ebp
  801b9d:	89 e5                	mov    %esp,%ebp
  801b9f:	53                   	push   %ebx
  801ba0:	83 ec 20             	sub    $0x20,%esp
  801ba3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ba6:	53                   	push   %ebx
  801ba7:	e8 74 ec ff ff       	call   800820 <strlen>
  801bac:	83 c4 10             	add    $0x10,%esp
  801baf:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bb4:	7f 67                	jg     801c1d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bb6:	83 ec 0c             	sub    $0xc,%esp
  801bb9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bbc:	50                   	push   %eax
  801bbd:	e8 8e f8 ff ff       	call   801450 <fd_alloc>
  801bc2:	83 c4 10             	add    $0x10,%esp
		return r;
  801bc5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bc7:	85 c0                	test   %eax,%eax
  801bc9:	78 57                	js     801c22 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bcb:	83 ec 08             	sub    $0x8,%esp
  801bce:	53                   	push   %ebx
  801bcf:	68 00 60 80 00       	push   $0x806000
  801bd4:	e8 80 ec ff ff       	call   800859 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bdc:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801be1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801be4:	b8 01 00 00 00       	mov    $0x1,%eax
  801be9:	e8 f6 fd ff ff       	call   8019e4 <fsipc>
  801bee:	89 c3                	mov    %eax,%ebx
  801bf0:	83 c4 10             	add    $0x10,%esp
  801bf3:	85 c0                	test   %eax,%eax
  801bf5:	79 14                	jns    801c0b <open+0x6f>
		fd_close(fd, 0);
  801bf7:	83 ec 08             	sub    $0x8,%esp
  801bfa:	6a 00                	push   $0x0
  801bfc:	ff 75 f4             	pushl  -0xc(%ebp)
  801bff:	e8 47 f9 ff ff       	call   80154b <fd_close>
		return r;
  801c04:	83 c4 10             	add    $0x10,%esp
  801c07:	89 da                	mov    %ebx,%edx
  801c09:	eb 17                	jmp    801c22 <open+0x86>
	}

	return fd2num(fd);
  801c0b:	83 ec 0c             	sub    $0xc,%esp
  801c0e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c11:	e8 13 f8 ff ff       	call   801429 <fd2num>
  801c16:	89 c2                	mov    %eax,%edx
  801c18:	83 c4 10             	add    $0x10,%esp
  801c1b:	eb 05                	jmp    801c22 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c1d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c22:	89 d0                	mov    %edx,%eax
  801c24:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c27:	c9                   	leave  
  801c28:	c3                   	ret    

00801c29 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c29:	55                   	push   %ebp
  801c2a:	89 e5                	mov    %esp,%ebp
  801c2c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c2f:	ba 00 00 00 00       	mov    $0x0,%edx
  801c34:	b8 08 00 00 00       	mov    $0x8,%eax
  801c39:	e8 a6 fd ff ff       	call   8019e4 <fsipc>
}
  801c3e:	c9                   	leave  
  801c3f:	c3                   	ret    

00801c40 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	57                   	push   %edi
  801c44:	56                   	push   %esi
  801c45:	53                   	push   %ebx
  801c46:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801c4c:	6a 00                	push   $0x0
  801c4e:	ff 75 08             	pushl  0x8(%ebp)
  801c51:	e8 46 ff ff ff       	call   801b9c <open>
  801c56:	89 c7                	mov    %eax,%edi
  801c58:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801c5e:	83 c4 10             	add    $0x10,%esp
  801c61:	85 c0                	test   %eax,%eax
  801c63:	0f 88 8c 04 00 00    	js     8020f5 <spawn+0x4b5>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801c69:	83 ec 04             	sub    $0x4,%esp
  801c6c:	68 00 02 00 00       	push   $0x200
  801c71:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801c77:	50                   	push   %eax
  801c78:	57                   	push   %edi
  801c79:	e8 1e fb ff ff       	call   80179c <readn>
  801c7e:	83 c4 10             	add    $0x10,%esp
  801c81:	3d 00 02 00 00       	cmp    $0x200,%eax
  801c86:	75 0c                	jne    801c94 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801c88:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801c8f:	45 4c 46 
  801c92:	74 33                	je     801cc7 <spawn+0x87>
		close(fd);
  801c94:	83 ec 0c             	sub    $0xc,%esp
  801c97:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c9d:	e8 2a f9 ff ff       	call   8015cc <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801ca2:	83 c4 0c             	add    $0xc,%esp
  801ca5:	68 7f 45 4c 46       	push   $0x464c457f
  801caa:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801cb0:	68 27 32 80 00       	push   $0x803227
  801cb5:	e8 1a e6 ff ff       	call   8002d4 <cprintf>
		return -E_NOT_EXEC;
  801cba:	83 c4 10             	add    $0x10,%esp
  801cbd:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801cc2:	e9 e1 04 00 00       	jmp    8021a8 <spawn+0x568>
  801cc7:	b8 07 00 00 00       	mov    $0x7,%eax
  801ccc:	cd 30                	int    $0x30
  801cce:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801cd4:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801cda:	85 c0                	test   %eax,%eax
  801cdc:	0f 88 1e 04 00 00    	js     802100 <spawn+0x4c0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801ce2:	89 c6                	mov    %eax,%esi
  801ce4:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801cea:	69 f6 d8 00 00 00    	imul   $0xd8,%esi,%esi
  801cf0:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801cf6:	81 c6 59 00 c0 ee    	add    $0xeec00059,%esi
  801cfc:	b9 11 00 00 00       	mov    $0x11,%ecx
  801d01:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801d03:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801d09:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d0f:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801d14:	be 00 00 00 00       	mov    $0x0,%esi
  801d19:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d1c:	eb 13                	jmp    801d31 <spawn+0xf1>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801d1e:	83 ec 0c             	sub    $0xc,%esp
  801d21:	50                   	push   %eax
  801d22:	e8 f9 ea ff ff       	call   800820 <strlen>
  801d27:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d2b:	83 c3 01             	add    $0x1,%ebx
  801d2e:	83 c4 10             	add    $0x10,%esp
  801d31:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801d38:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801d3b:	85 c0                	test   %eax,%eax
  801d3d:	75 df                	jne    801d1e <spawn+0xde>
  801d3f:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801d45:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801d4b:	bf 00 10 40 00       	mov    $0x401000,%edi
  801d50:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801d52:	89 fa                	mov    %edi,%edx
  801d54:	83 e2 fc             	and    $0xfffffffc,%edx
  801d57:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801d5e:	29 c2                	sub    %eax,%edx
  801d60:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801d66:	8d 42 f8             	lea    -0x8(%edx),%eax
  801d69:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801d6e:	0f 86 a2 03 00 00    	jbe    802116 <spawn+0x4d6>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d74:	83 ec 04             	sub    $0x4,%esp
  801d77:	6a 07                	push   $0x7
  801d79:	68 00 00 40 00       	push   $0x400000
  801d7e:	6a 00                	push   $0x0
  801d80:	e8 d7 ee ff ff       	call   800c5c <sys_page_alloc>
  801d85:	83 c4 10             	add    $0x10,%esp
  801d88:	85 c0                	test   %eax,%eax
  801d8a:	0f 88 90 03 00 00    	js     802120 <spawn+0x4e0>
  801d90:	be 00 00 00 00       	mov    $0x0,%esi
  801d95:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801d9b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d9e:	eb 30                	jmp    801dd0 <spawn+0x190>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801da0:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801da6:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801dac:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801daf:	83 ec 08             	sub    $0x8,%esp
  801db2:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801db5:	57                   	push   %edi
  801db6:	e8 9e ea ff ff       	call   800859 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801dbb:	83 c4 04             	add    $0x4,%esp
  801dbe:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801dc1:	e8 5a ea ff ff       	call   800820 <strlen>
  801dc6:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801dca:	83 c6 01             	add    $0x1,%esi
  801dcd:	83 c4 10             	add    $0x10,%esp
  801dd0:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801dd6:	7f c8                	jg     801da0 <spawn+0x160>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801dd8:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801dde:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801de4:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801deb:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801df1:	74 19                	je     801e0c <spawn+0x1cc>
  801df3:	68 b4 32 80 00       	push   $0x8032b4
  801df8:	68 fb 31 80 00       	push   $0x8031fb
  801dfd:	68 f2 00 00 00       	push   $0xf2
  801e02:	68 41 32 80 00       	push   $0x803241
  801e07:	e8 ef e3 ff ff       	call   8001fb <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801e0c:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801e12:	89 f8                	mov    %edi,%eax
  801e14:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801e19:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801e1c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e22:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801e25:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801e2b:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801e31:	83 ec 0c             	sub    $0xc,%esp
  801e34:	6a 07                	push   $0x7
  801e36:	68 00 d0 bf ee       	push   $0xeebfd000
  801e3b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e41:	68 00 00 40 00       	push   $0x400000
  801e46:	6a 00                	push   $0x0
  801e48:	e8 52 ee ff ff       	call   800c9f <sys_page_map>
  801e4d:	89 c3                	mov    %eax,%ebx
  801e4f:	83 c4 20             	add    $0x20,%esp
  801e52:	85 c0                	test   %eax,%eax
  801e54:	0f 88 3c 03 00 00    	js     802196 <spawn+0x556>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801e5a:	83 ec 08             	sub    $0x8,%esp
  801e5d:	68 00 00 40 00       	push   $0x400000
  801e62:	6a 00                	push   $0x0
  801e64:	e8 78 ee ff ff       	call   800ce1 <sys_page_unmap>
  801e69:	89 c3                	mov    %eax,%ebx
  801e6b:	83 c4 10             	add    $0x10,%esp
  801e6e:	85 c0                	test   %eax,%eax
  801e70:	0f 88 20 03 00 00    	js     802196 <spawn+0x556>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801e76:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801e7c:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801e83:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801e89:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801e90:	00 00 00 
  801e93:	e9 88 01 00 00       	jmp    802020 <spawn+0x3e0>
		if (ph->p_type != ELF_PROG_LOAD)
  801e98:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801e9e:	83 38 01             	cmpl   $0x1,(%eax)
  801ea1:	0f 85 6b 01 00 00    	jne    802012 <spawn+0x3d2>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801ea7:	89 c2                	mov    %eax,%edx
  801ea9:	8b 40 18             	mov    0x18(%eax),%eax
  801eac:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801eb2:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801eb5:	83 f8 01             	cmp    $0x1,%eax
  801eb8:	19 c0                	sbb    %eax,%eax
  801eba:	83 e0 fe             	and    $0xfffffffe,%eax
  801ebd:	83 c0 07             	add    $0x7,%eax
  801ec0:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801ec6:	89 d0                	mov    %edx,%eax
  801ec8:	8b 7a 04             	mov    0x4(%edx),%edi
  801ecb:	89 f9                	mov    %edi,%ecx
  801ecd:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801ed3:	8b 7a 10             	mov    0x10(%edx),%edi
  801ed6:	8b 52 14             	mov    0x14(%edx),%edx
  801ed9:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801edf:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801ee2:	89 f0                	mov    %esi,%eax
  801ee4:	25 ff 0f 00 00       	and    $0xfff,%eax
  801ee9:	74 14                	je     801eff <spawn+0x2bf>
		va -= i;
  801eeb:	29 c6                	sub    %eax,%esi
		memsz += i;
  801eed:	01 c2                	add    %eax,%edx
  801eef:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801ef5:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801ef7:	29 c1                	sub    %eax,%ecx
  801ef9:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801eff:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f04:	e9 f7 00 00 00       	jmp    802000 <spawn+0x3c0>
		if (i >= filesz) {
  801f09:	39 fb                	cmp    %edi,%ebx
  801f0b:	72 27                	jb     801f34 <spawn+0x2f4>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801f0d:	83 ec 04             	sub    $0x4,%esp
  801f10:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801f16:	56                   	push   %esi
  801f17:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801f1d:	e8 3a ed ff ff       	call   800c5c <sys_page_alloc>
  801f22:	83 c4 10             	add    $0x10,%esp
  801f25:	85 c0                	test   %eax,%eax
  801f27:	0f 89 c7 00 00 00    	jns    801ff4 <spawn+0x3b4>
  801f2d:	89 c3                	mov    %eax,%ebx
  801f2f:	e9 fd 01 00 00       	jmp    802131 <spawn+0x4f1>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801f34:	83 ec 04             	sub    $0x4,%esp
  801f37:	6a 07                	push   $0x7
  801f39:	68 00 00 40 00       	push   $0x400000
  801f3e:	6a 00                	push   $0x0
  801f40:	e8 17 ed ff ff       	call   800c5c <sys_page_alloc>
  801f45:	83 c4 10             	add    $0x10,%esp
  801f48:	85 c0                	test   %eax,%eax
  801f4a:	0f 88 d7 01 00 00    	js     802127 <spawn+0x4e7>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801f50:	83 ec 08             	sub    $0x8,%esp
  801f53:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801f59:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801f5f:	50                   	push   %eax
  801f60:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801f66:	e8 09 f9 ff ff       	call   801874 <seek>
  801f6b:	83 c4 10             	add    $0x10,%esp
  801f6e:	85 c0                	test   %eax,%eax
  801f70:	0f 88 b5 01 00 00    	js     80212b <spawn+0x4eb>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801f76:	83 ec 04             	sub    $0x4,%esp
  801f79:	89 f8                	mov    %edi,%eax
  801f7b:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801f81:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801f86:	ba 00 10 00 00       	mov    $0x1000,%edx
  801f8b:	0f 47 c2             	cmova  %edx,%eax
  801f8e:	50                   	push   %eax
  801f8f:	68 00 00 40 00       	push   $0x400000
  801f94:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801f9a:	e8 fd f7 ff ff       	call   80179c <readn>
  801f9f:	83 c4 10             	add    $0x10,%esp
  801fa2:	85 c0                	test   %eax,%eax
  801fa4:	0f 88 85 01 00 00    	js     80212f <spawn+0x4ef>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801faa:	83 ec 0c             	sub    $0xc,%esp
  801fad:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801fb3:	56                   	push   %esi
  801fb4:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801fba:	68 00 00 40 00       	push   $0x400000
  801fbf:	6a 00                	push   $0x0
  801fc1:	e8 d9 ec ff ff       	call   800c9f <sys_page_map>
  801fc6:	83 c4 20             	add    $0x20,%esp
  801fc9:	85 c0                	test   %eax,%eax
  801fcb:	79 15                	jns    801fe2 <spawn+0x3a2>
				panic("spawn: sys_page_map data: %e", r);
  801fcd:	50                   	push   %eax
  801fce:	68 4d 32 80 00       	push   $0x80324d
  801fd3:	68 25 01 00 00       	push   $0x125
  801fd8:	68 41 32 80 00       	push   $0x803241
  801fdd:	e8 19 e2 ff ff       	call   8001fb <_panic>
			sys_page_unmap(0, UTEMP);
  801fe2:	83 ec 08             	sub    $0x8,%esp
  801fe5:	68 00 00 40 00       	push   $0x400000
  801fea:	6a 00                	push   $0x0
  801fec:	e8 f0 ec ff ff       	call   800ce1 <sys_page_unmap>
  801ff1:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801ff4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801ffa:	81 c6 00 10 00 00    	add    $0x1000,%esi
  802000:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  802006:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  80200c:	0f 82 f7 fe ff ff    	jb     801f09 <spawn+0x2c9>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802012:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  802019:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  802020:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802027:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  80202d:	0f 8c 65 fe ff ff    	jl     801e98 <spawn+0x258>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802033:	83 ec 0c             	sub    $0xc,%esp
  802036:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80203c:	e8 8b f5 ff ff       	call   8015cc <close>
  802041:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  802044:	bb 00 00 00 00       	mov    $0x0,%ebx
  802049:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  80204f:	89 d8                	mov    %ebx,%eax
  802051:	c1 e8 16             	shr    $0x16,%eax
  802054:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80205b:	a8 01                	test   $0x1,%al
  80205d:	74 42                	je     8020a1 <spawn+0x461>
  80205f:	89 d8                	mov    %ebx,%eax
  802061:	c1 e8 0c             	shr    $0xc,%eax
  802064:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80206b:	f6 c2 01             	test   $0x1,%dl
  80206e:	74 31                	je     8020a1 <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  802070:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  802077:	f6 c6 04             	test   $0x4,%dh
  80207a:	74 25                	je     8020a1 <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  80207c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802083:	83 ec 0c             	sub    $0xc,%esp
  802086:	25 07 0e 00 00       	and    $0xe07,%eax
  80208b:	50                   	push   %eax
  80208c:	53                   	push   %ebx
  80208d:	56                   	push   %esi
  80208e:	53                   	push   %ebx
  80208f:	6a 00                	push   $0x0
  802091:	e8 09 ec ff ff       	call   800c9f <sys_page_map>
			if (r < 0) {
  802096:	83 c4 20             	add    $0x20,%esp
  802099:	85 c0                	test   %eax,%eax
  80209b:	0f 88 b1 00 00 00    	js     802152 <spawn+0x512>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  8020a1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8020a7:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8020ad:	75 a0                	jne    80204f <spawn+0x40f>
  8020af:	e9 b3 00 00 00       	jmp    802167 <spawn+0x527>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  8020b4:	50                   	push   %eax
  8020b5:	68 6a 32 80 00       	push   $0x80326a
  8020ba:	68 86 00 00 00       	push   $0x86
  8020bf:	68 41 32 80 00       	push   $0x803241
  8020c4:	e8 32 e1 ff ff       	call   8001fb <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8020c9:	83 ec 08             	sub    $0x8,%esp
  8020cc:	6a 02                	push   $0x2
  8020ce:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8020d4:	e8 4a ec ff ff       	call   800d23 <sys_env_set_status>
  8020d9:	83 c4 10             	add    $0x10,%esp
  8020dc:	85 c0                	test   %eax,%eax
  8020de:	79 2b                	jns    80210b <spawn+0x4cb>
		panic("sys_env_set_status: %e", r);
  8020e0:	50                   	push   %eax
  8020e1:	68 84 32 80 00       	push   $0x803284
  8020e6:	68 89 00 00 00       	push   $0x89
  8020eb:	68 41 32 80 00       	push   $0x803241
  8020f0:	e8 06 e1 ff ff       	call   8001fb <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8020f5:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  8020fb:	e9 a8 00 00 00       	jmp    8021a8 <spawn+0x568>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802100:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802106:	e9 9d 00 00 00       	jmp    8021a8 <spawn+0x568>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  80210b:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802111:	e9 92 00 00 00       	jmp    8021a8 <spawn+0x568>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802116:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  80211b:	e9 88 00 00 00       	jmp    8021a8 <spawn+0x568>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  802120:	89 c3                	mov    %eax,%ebx
  802122:	e9 81 00 00 00       	jmp    8021a8 <spawn+0x568>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802127:	89 c3                	mov    %eax,%ebx
  802129:	eb 06                	jmp    802131 <spawn+0x4f1>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80212b:	89 c3                	mov    %eax,%ebx
  80212d:	eb 02                	jmp    802131 <spawn+0x4f1>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80212f:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802131:	83 ec 0c             	sub    $0xc,%esp
  802134:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80213a:	e8 9e ea ff ff       	call   800bdd <sys_env_destroy>
	close(fd);
  80213f:	83 c4 04             	add    $0x4,%esp
  802142:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802148:	e8 7f f4 ff ff       	call   8015cc <close>
	return r;
  80214d:	83 c4 10             	add    $0x10,%esp
  802150:	eb 56                	jmp    8021a8 <spawn+0x568>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  802152:	50                   	push   %eax
  802153:	68 9b 32 80 00       	push   $0x80329b
  802158:	68 82 00 00 00       	push   $0x82
  80215d:	68 41 32 80 00       	push   $0x803241
  802162:	e8 94 e0 ff ff       	call   8001fb <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802167:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  80216e:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802171:	83 ec 08             	sub    $0x8,%esp
  802174:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  80217a:	50                   	push   %eax
  80217b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802181:	e8 df eb ff ff       	call   800d65 <sys_env_set_trapframe>
  802186:	83 c4 10             	add    $0x10,%esp
  802189:	85 c0                	test   %eax,%eax
  80218b:	0f 89 38 ff ff ff    	jns    8020c9 <spawn+0x489>
  802191:	e9 1e ff ff ff       	jmp    8020b4 <spawn+0x474>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802196:	83 ec 08             	sub    $0x8,%esp
  802199:	68 00 00 40 00       	push   $0x400000
  80219e:	6a 00                	push   $0x0
  8021a0:	e8 3c eb ff ff       	call   800ce1 <sys_page_unmap>
  8021a5:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8021a8:	89 d8                	mov    %ebx,%eax
  8021aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021ad:	5b                   	pop    %ebx
  8021ae:	5e                   	pop    %esi
  8021af:	5f                   	pop    %edi
  8021b0:	5d                   	pop    %ebp
  8021b1:	c3                   	ret    

008021b2 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8021b2:	55                   	push   %ebp
  8021b3:	89 e5                	mov    %esp,%ebp
  8021b5:	56                   	push   %esi
  8021b6:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021b7:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8021ba:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021bf:	eb 03                	jmp    8021c4 <spawnl+0x12>
		argc++;
  8021c1:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021c4:	83 c2 04             	add    $0x4,%edx
  8021c7:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  8021cb:	75 f4                	jne    8021c1 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8021cd:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  8021d4:	83 e2 f0             	and    $0xfffffff0,%edx
  8021d7:	29 d4                	sub    %edx,%esp
  8021d9:	8d 54 24 03          	lea    0x3(%esp),%edx
  8021dd:	c1 ea 02             	shr    $0x2,%edx
  8021e0:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  8021e7:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  8021e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021ec:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  8021f3:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  8021fa:	00 
  8021fb:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8021fd:	b8 00 00 00 00       	mov    $0x0,%eax
  802202:	eb 0a                	jmp    80220e <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802204:	83 c0 01             	add    $0x1,%eax
  802207:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  80220b:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  80220e:	39 d0                	cmp    %edx,%eax
  802210:	75 f2                	jne    802204 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802212:	83 ec 08             	sub    $0x8,%esp
  802215:	56                   	push   %esi
  802216:	ff 75 08             	pushl  0x8(%ebp)
  802219:	e8 22 fa ff ff       	call   801c40 <spawn>
}
  80221e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802221:	5b                   	pop    %ebx
  802222:	5e                   	pop    %esi
  802223:	5d                   	pop    %ebp
  802224:	c3                   	ret    

00802225 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802225:	55                   	push   %ebp
  802226:	89 e5                	mov    %esp,%ebp
  802228:	56                   	push   %esi
  802229:	53                   	push   %ebx
  80222a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80222d:	83 ec 0c             	sub    $0xc,%esp
  802230:	ff 75 08             	pushl  0x8(%ebp)
  802233:	e8 01 f2 ff ff       	call   801439 <fd2data>
  802238:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80223a:	83 c4 08             	add    $0x8,%esp
  80223d:	68 dc 32 80 00       	push   $0x8032dc
  802242:	53                   	push   %ebx
  802243:	e8 11 e6 ff ff       	call   800859 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802248:	8b 46 04             	mov    0x4(%esi),%eax
  80224b:	2b 06                	sub    (%esi),%eax
  80224d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802253:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80225a:	00 00 00 
	stat->st_dev = &devpipe;
  80225d:	c7 83 88 00 00 00 28 	movl   $0x804028,0x88(%ebx)
  802264:	40 80 00 
	return 0;
}
  802267:	b8 00 00 00 00       	mov    $0x0,%eax
  80226c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80226f:	5b                   	pop    %ebx
  802270:	5e                   	pop    %esi
  802271:	5d                   	pop    %ebp
  802272:	c3                   	ret    

00802273 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802273:	55                   	push   %ebp
  802274:	89 e5                	mov    %esp,%ebp
  802276:	53                   	push   %ebx
  802277:	83 ec 0c             	sub    $0xc,%esp
  80227a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80227d:	53                   	push   %ebx
  80227e:	6a 00                	push   $0x0
  802280:	e8 5c ea ff ff       	call   800ce1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802285:	89 1c 24             	mov    %ebx,(%esp)
  802288:	e8 ac f1 ff ff       	call   801439 <fd2data>
  80228d:	83 c4 08             	add    $0x8,%esp
  802290:	50                   	push   %eax
  802291:	6a 00                	push   $0x0
  802293:	e8 49 ea ff ff       	call   800ce1 <sys_page_unmap>
}
  802298:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80229b:	c9                   	leave  
  80229c:	c3                   	ret    

0080229d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80229d:	55                   	push   %ebp
  80229e:	89 e5                	mov    %esp,%ebp
  8022a0:	57                   	push   %edi
  8022a1:	56                   	push   %esi
  8022a2:	53                   	push   %ebx
  8022a3:	83 ec 1c             	sub    $0x1c,%esp
  8022a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8022a9:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8022ab:	a1 04 50 80 00       	mov    0x805004,%eax
  8022b0:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8022b6:	83 ec 0c             	sub    $0xc,%esp
  8022b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8022bc:	e8 55 06 00 00       	call   802916 <pageref>
  8022c1:	89 c3                	mov    %eax,%ebx
  8022c3:	89 3c 24             	mov    %edi,(%esp)
  8022c6:	e8 4b 06 00 00       	call   802916 <pageref>
  8022cb:	83 c4 10             	add    $0x10,%esp
  8022ce:	39 c3                	cmp    %eax,%ebx
  8022d0:	0f 94 c1             	sete   %cl
  8022d3:	0f b6 c9             	movzbl %cl,%ecx
  8022d6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8022d9:	8b 15 04 50 80 00    	mov    0x805004,%edx
  8022df:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  8022e5:	39 ce                	cmp    %ecx,%esi
  8022e7:	74 1e                	je     802307 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  8022e9:	39 c3                	cmp    %eax,%ebx
  8022eb:	75 be                	jne    8022ab <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8022ed:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  8022f3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8022f6:	50                   	push   %eax
  8022f7:	56                   	push   %esi
  8022f8:	68 e3 32 80 00       	push   $0x8032e3
  8022fd:	e8 d2 df ff ff       	call   8002d4 <cprintf>
  802302:	83 c4 10             	add    $0x10,%esp
  802305:	eb a4                	jmp    8022ab <_pipeisclosed+0xe>
	}
}
  802307:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80230a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80230d:	5b                   	pop    %ebx
  80230e:	5e                   	pop    %esi
  80230f:	5f                   	pop    %edi
  802310:	5d                   	pop    %ebp
  802311:	c3                   	ret    

00802312 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802312:	55                   	push   %ebp
  802313:	89 e5                	mov    %esp,%ebp
  802315:	57                   	push   %edi
  802316:	56                   	push   %esi
  802317:	53                   	push   %ebx
  802318:	83 ec 28             	sub    $0x28,%esp
  80231b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80231e:	56                   	push   %esi
  80231f:	e8 15 f1 ff ff       	call   801439 <fd2data>
  802324:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802326:	83 c4 10             	add    $0x10,%esp
  802329:	bf 00 00 00 00       	mov    $0x0,%edi
  80232e:	eb 4b                	jmp    80237b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802330:	89 da                	mov    %ebx,%edx
  802332:	89 f0                	mov    %esi,%eax
  802334:	e8 64 ff ff ff       	call   80229d <_pipeisclosed>
  802339:	85 c0                	test   %eax,%eax
  80233b:	75 48                	jne    802385 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80233d:	e8 fb e8 ff ff       	call   800c3d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802342:	8b 43 04             	mov    0x4(%ebx),%eax
  802345:	8b 0b                	mov    (%ebx),%ecx
  802347:	8d 51 20             	lea    0x20(%ecx),%edx
  80234a:	39 d0                	cmp    %edx,%eax
  80234c:	73 e2                	jae    802330 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80234e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802351:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802355:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802358:	89 c2                	mov    %eax,%edx
  80235a:	c1 fa 1f             	sar    $0x1f,%edx
  80235d:	89 d1                	mov    %edx,%ecx
  80235f:	c1 e9 1b             	shr    $0x1b,%ecx
  802362:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802365:	83 e2 1f             	and    $0x1f,%edx
  802368:	29 ca                	sub    %ecx,%edx
  80236a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80236e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802372:	83 c0 01             	add    $0x1,%eax
  802375:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802378:	83 c7 01             	add    $0x1,%edi
  80237b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80237e:	75 c2                	jne    802342 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802380:	8b 45 10             	mov    0x10(%ebp),%eax
  802383:	eb 05                	jmp    80238a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802385:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80238a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80238d:	5b                   	pop    %ebx
  80238e:	5e                   	pop    %esi
  80238f:	5f                   	pop    %edi
  802390:	5d                   	pop    %ebp
  802391:	c3                   	ret    

00802392 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802392:	55                   	push   %ebp
  802393:	89 e5                	mov    %esp,%ebp
  802395:	57                   	push   %edi
  802396:	56                   	push   %esi
  802397:	53                   	push   %ebx
  802398:	83 ec 18             	sub    $0x18,%esp
  80239b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80239e:	57                   	push   %edi
  80239f:	e8 95 f0 ff ff       	call   801439 <fd2data>
  8023a4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023a6:	83 c4 10             	add    $0x10,%esp
  8023a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8023ae:	eb 3d                	jmp    8023ed <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8023b0:	85 db                	test   %ebx,%ebx
  8023b2:	74 04                	je     8023b8 <devpipe_read+0x26>
				return i;
  8023b4:	89 d8                	mov    %ebx,%eax
  8023b6:	eb 44                	jmp    8023fc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8023b8:	89 f2                	mov    %esi,%edx
  8023ba:	89 f8                	mov    %edi,%eax
  8023bc:	e8 dc fe ff ff       	call   80229d <_pipeisclosed>
  8023c1:	85 c0                	test   %eax,%eax
  8023c3:	75 32                	jne    8023f7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8023c5:	e8 73 e8 ff ff       	call   800c3d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8023ca:	8b 06                	mov    (%esi),%eax
  8023cc:	3b 46 04             	cmp    0x4(%esi),%eax
  8023cf:	74 df                	je     8023b0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8023d1:	99                   	cltd   
  8023d2:	c1 ea 1b             	shr    $0x1b,%edx
  8023d5:	01 d0                	add    %edx,%eax
  8023d7:	83 e0 1f             	and    $0x1f,%eax
  8023da:	29 d0                	sub    %edx,%eax
  8023dc:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8023e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023e4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8023e7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023ea:	83 c3 01             	add    $0x1,%ebx
  8023ed:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8023f0:	75 d8                	jne    8023ca <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8023f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8023f5:	eb 05                	jmp    8023fc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8023f7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8023fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023ff:	5b                   	pop    %ebx
  802400:	5e                   	pop    %esi
  802401:	5f                   	pop    %edi
  802402:	5d                   	pop    %ebp
  802403:	c3                   	ret    

00802404 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802404:	55                   	push   %ebp
  802405:	89 e5                	mov    %esp,%ebp
  802407:	56                   	push   %esi
  802408:	53                   	push   %ebx
  802409:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80240c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80240f:	50                   	push   %eax
  802410:	e8 3b f0 ff ff       	call   801450 <fd_alloc>
  802415:	83 c4 10             	add    $0x10,%esp
  802418:	89 c2                	mov    %eax,%edx
  80241a:	85 c0                	test   %eax,%eax
  80241c:	0f 88 2c 01 00 00    	js     80254e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802422:	83 ec 04             	sub    $0x4,%esp
  802425:	68 07 04 00 00       	push   $0x407
  80242a:	ff 75 f4             	pushl  -0xc(%ebp)
  80242d:	6a 00                	push   $0x0
  80242f:	e8 28 e8 ff ff       	call   800c5c <sys_page_alloc>
  802434:	83 c4 10             	add    $0x10,%esp
  802437:	89 c2                	mov    %eax,%edx
  802439:	85 c0                	test   %eax,%eax
  80243b:	0f 88 0d 01 00 00    	js     80254e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802441:	83 ec 0c             	sub    $0xc,%esp
  802444:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802447:	50                   	push   %eax
  802448:	e8 03 f0 ff ff       	call   801450 <fd_alloc>
  80244d:	89 c3                	mov    %eax,%ebx
  80244f:	83 c4 10             	add    $0x10,%esp
  802452:	85 c0                	test   %eax,%eax
  802454:	0f 88 e2 00 00 00    	js     80253c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80245a:	83 ec 04             	sub    $0x4,%esp
  80245d:	68 07 04 00 00       	push   $0x407
  802462:	ff 75 f0             	pushl  -0x10(%ebp)
  802465:	6a 00                	push   $0x0
  802467:	e8 f0 e7 ff ff       	call   800c5c <sys_page_alloc>
  80246c:	89 c3                	mov    %eax,%ebx
  80246e:	83 c4 10             	add    $0x10,%esp
  802471:	85 c0                	test   %eax,%eax
  802473:	0f 88 c3 00 00 00    	js     80253c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802479:	83 ec 0c             	sub    $0xc,%esp
  80247c:	ff 75 f4             	pushl  -0xc(%ebp)
  80247f:	e8 b5 ef ff ff       	call   801439 <fd2data>
  802484:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802486:	83 c4 0c             	add    $0xc,%esp
  802489:	68 07 04 00 00       	push   $0x407
  80248e:	50                   	push   %eax
  80248f:	6a 00                	push   $0x0
  802491:	e8 c6 e7 ff ff       	call   800c5c <sys_page_alloc>
  802496:	89 c3                	mov    %eax,%ebx
  802498:	83 c4 10             	add    $0x10,%esp
  80249b:	85 c0                	test   %eax,%eax
  80249d:	0f 88 89 00 00 00    	js     80252c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024a3:	83 ec 0c             	sub    $0xc,%esp
  8024a6:	ff 75 f0             	pushl  -0x10(%ebp)
  8024a9:	e8 8b ef ff ff       	call   801439 <fd2data>
  8024ae:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8024b5:	50                   	push   %eax
  8024b6:	6a 00                	push   $0x0
  8024b8:	56                   	push   %esi
  8024b9:	6a 00                	push   $0x0
  8024bb:	e8 df e7 ff ff       	call   800c9f <sys_page_map>
  8024c0:	89 c3                	mov    %eax,%ebx
  8024c2:	83 c4 20             	add    $0x20,%esp
  8024c5:	85 c0                	test   %eax,%eax
  8024c7:	78 55                	js     80251e <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8024c9:	8b 15 28 40 80 00    	mov    0x804028,%edx
  8024cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024d2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8024d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024d7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8024de:	8b 15 28 40 80 00    	mov    0x804028,%edx
  8024e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024e7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8024e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024ec:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8024f3:	83 ec 0c             	sub    $0xc,%esp
  8024f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8024f9:	e8 2b ef ff ff       	call   801429 <fd2num>
  8024fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802501:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802503:	83 c4 04             	add    $0x4,%esp
  802506:	ff 75 f0             	pushl  -0x10(%ebp)
  802509:	e8 1b ef ff ff       	call   801429 <fd2num>
  80250e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802511:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  802514:	83 c4 10             	add    $0x10,%esp
  802517:	ba 00 00 00 00       	mov    $0x0,%edx
  80251c:	eb 30                	jmp    80254e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80251e:	83 ec 08             	sub    $0x8,%esp
  802521:	56                   	push   %esi
  802522:	6a 00                	push   $0x0
  802524:	e8 b8 e7 ff ff       	call   800ce1 <sys_page_unmap>
  802529:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80252c:	83 ec 08             	sub    $0x8,%esp
  80252f:	ff 75 f0             	pushl  -0x10(%ebp)
  802532:	6a 00                	push   $0x0
  802534:	e8 a8 e7 ff ff       	call   800ce1 <sys_page_unmap>
  802539:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80253c:	83 ec 08             	sub    $0x8,%esp
  80253f:	ff 75 f4             	pushl  -0xc(%ebp)
  802542:	6a 00                	push   $0x0
  802544:	e8 98 e7 ff ff       	call   800ce1 <sys_page_unmap>
  802549:	83 c4 10             	add    $0x10,%esp
  80254c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80254e:	89 d0                	mov    %edx,%eax
  802550:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802553:	5b                   	pop    %ebx
  802554:	5e                   	pop    %esi
  802555:	5d                   	pop    %ebp
  802556:	c3                   	ret    

00802557 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802557:	55                   	push   %ebp
  802558:	89 e5                	mov    %esp,%ebp
  80255a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80255d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802560:	50                   	push   %eax
  802561:	ff 75 08             	pushl  0x8(%ebp)
  802564:	e8 36 ef ff ff       	call   80149f <fd_lookup>
  802569:	83 c4 10             	add    $0x10,%esp
  80256c:	85 c0                	test   %eax,%eax
  80256e:	78 18                	js     802588 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802570:	83 ec 0c             	sub    $0xc,%esp
  802573:	ff 75 f4             	pushl  -0xc(%ebp)
  802576:	e8 be ee ff ff       	call   801439 <fd2data>
	return _pipeisclosed(fd, p);
  80257b:	89 c2                	mov    %eax,%edx
  80257d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802580:	e8 18 fd ff ff       	call   80229d <_pipeisclosed>
  802585:	83 c4 10             	add    $0x10,%esp
}
  802588:	c9                   	leave  
  802589:	c3                   	ret    

0080258a <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80258a:	55                   	push   %ebp
  80258b:	89 e5                	mov    %esp,%ebp
  80258d:	56                   	push   %esi
  80258e:	53                   	push   %ebx
  80258f:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802592:	85 f6                	test   %esi,%esi
  802594:	75 16                	jne    8025ac <wait+0x22>
  802596:	68 fb 32 80 00       	push   $0x8032fb
  80259b:	68 fb 31 80 00       	push   $0x8031fb
  8025a0:	6a 09                	push   $0x9
  8025a2:	68 06 33 80 00       	push   $0x803306
  8025a7:	e8 4f dc ff ff       	call   8001fb <_panic>
	e = &envs[ENVX(envid)];
  8025ac:	89 f3                	mov    %esi,%ebx
  8025ae:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8025b4:	69 db d8 00 00 00    	imul   $0xd8,%ebx,%ebx
  8025ba:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8025c0:	eb 05                	jmp    8025c7 <wait+0x3d>
		sys_yield();
  8025c2:	e8 76 e6 ff ff       	call   800c3d <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8025c7:	8b 83 a4 00 00 00    	mov    0xa4(%ebx),%eax
  8025cd:	39 c6                	cmp    %eax,%esi
  8025cf:	75 0a                	jne    8025db <wait+0x51>
  8025d1:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  8025d7:	85 c0                	test   %eax,%eax
  8025d9:	75 e7                	jne    8025c2 <wait+0x38>
		sys_yield();
}
  8025db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025de:	5b                   	pop    %ebx
  8025df:	5e                   	pop    %esi
  8025e0:	5d                   	pop    %ebp
  8025e1:	c3                   	ret    

008025e2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8025e2:	55                   	push   %ebp
  8025e3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8025e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8025ea:	5d                   	pop    %ebp
  8025eb:	c3                   	ret    

008025ec <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8025ec:	55                   	push   %ebp
  8025ed:	89 e5                	mov    %esp,%ebp
  8025ef:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8025f2:	68 11 33 80 00       	push   $0x803311
  8025f7:	ff 75 0c             	pushl  0xc(%ebp)
  8025fa:	e8 5a e2 ff ff       	call   800859 <strcpy>
	return 0;
}
  8025ff:	b8 00 00 00 00       	mov    $0x0,%eax
  802604:	c9                   	leave  
  802605:	c3                   	ret    

00802606 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802606:	55                   	push   %ebp
  802607:	89 e5                	mov    %esp,%ebp
  802609:	57                   	push   %edi
  80260a:	56                   	push   %esi
  80260b:	53                   	push   %ebx
  80260c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802612:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802617:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80261d:	eb 2d                	jmp    80264c <devcons_write+0x46>
		m = n - tot;
  80261f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802622:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802624:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802627:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80262c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80262f:	83 ec 04             	sub    $0x4,%esp
  802632:	53                   	push   %ebx
  802633:	03 45 0c             	add    0xc(%ebp),%eax
  802636:	50                   	push   %eax
  802637:	57                   	push   %edi
  802638:	e8 ae e3 ff ff       	call   8009eb <memmove>
		sys_cputs(buf, m);
  80263d:	83 c4 08             	add    $0x8,%esp
  802640:	53                   	push   %ebx
  802641:	57                   	push   %edi
  802642:	e8 59 e5 ff ff       	call   800ba0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802647:	01 de                	add    %ebx,%esi
  802649:	83 c4 10             	add    $0x10,%esp
  80264c:	89 f0                	mov    %esi,%eax
  80264e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802651:	72 cc                	jb     80261f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802653:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802656:	5b                   	pop    %ebx
  802657:	5e                   	pop    %esi
  802658:	5f                   	pop    %edi
  802659:	5d                   	pop    %ebp
  80265a:	c3                   	ret    

0080265b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80265b:	55                   	push   %ebp
  80265c:	89 e5                	mov    %esp,%ebp
  80265e:	83 ec 08             	sub    $0x8,%esp
  802661:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802666:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80266a:	74 2a                	je     802696 <devcons_read+0x3b>
  80266c:	eb 05                	jmp    802673 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80266e:	e8 ca e5 ff ff       	call   800c3d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802673:	e8 46 e5 ff ff       	call   800bbe <sys_cgetc>
  802678:	85 c0                	test   %eax,%eax
  80267a:	74 f2                	je     80266e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80267c:	85 c0                	test   %eax,%eax
  80267e:	78 16                	js     802696 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802680:	83 f8 04             	cmp    $0x4,%eax
  802683:	74 0c                	je     802691 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802685:	8b 55 0c             	mov    0xc(%ebp),%edx
  802688:	88 02                	mov    %al,(%edx)
	return 1;
  80268a:	b8 01 00 00 00       	mov    $0x1,%eax
  80268f:	eb 05                	jmp    802696 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802691:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802696:	c9                   	leave  
  802697:	c3                   	ret    

00802698 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802698:	55                   	push   %ebp
  802699:	89 e5                	mov    %esp,%ebp
  80269b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80269e:	8b 45 08             	mov    0x8(%ebp),%eax
  8026a1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8026a4:	6a 01                	push   $0x1
  8026a6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8026a9:	50                   	push   %eax
  8026aa:	e8 f1 e4 ff ff       	call   800ba0 <sys_cputs>
}
  8026af:	83 c4 10             	add    $0x10,%esp
  8026b2:	c9                   	leave  
  8026b3:	c3                   	ret    

008026b4 <getchar>:

int
getchar(void)
{
  8026b4:	55                   	push   %ebp
  8026b5:	89 e5                	mov    %esp,%ebp
  8026b7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8026ba:	6a 01                	push   $0x1
  8026bc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8026bf:	50                   	push   %eax
  8026c0:	6a 00                	push   $0x0
  8026c2:	e8 41 f0 ff ff       	call   801708 <read>
	if (r < 0)
  8026c7:	83 c4 10             	add    $0x10,%esp
  8026ca:	85 c0                	test   %eax,%eax
  8026cc:	78 0f                	js     8026dd <getchar+0x29>
		return r;
	if (r < 1)
  8026ce:	85 c0                	test   %eax,%eax
  8026d0:	7e 06                	jle    8026d8 <getchar+0x24>
		return -E_EOF;
	return c;
  8026d2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8026d6:	eb 05                	jmp    8026dd <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8026d8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8026dd:	c9                   	leave  
  8026de:	c3                   	ret    

008026df <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8026df:	55                   	push   %ebp
  8026e0:	89 e5                	mov    %esp,%ebp
  8026e2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8026e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026e8:	50                   	push   %eax
  8026e9:	ff 75 08             	pushl  0x8(%ebp)
  8026ec:	e8 ae ed ff ff       	call   80149f <fd_lookup>
  8026f1:	83 c4 10             	add    $0x10,%esp
  8026f4:	85 c0                	test   %eax,%eax
  8026f6:	78 11                	js     802709 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8026f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026fb:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802701:	39 10                	cmp    %edx,(%eax)
  802703:	0f 94 c0             	sete   %al
  802706:	0f b6 c0             	movzbl %al,%eax
}
  802709:	c9                   	leave  
  80270a:	c3                   	ret    

0080270b <opencons>:

int
opencons(void)
{
  80270b:	55                   	push   %ebp
  80270c:	89 e5                	mov    %esp,%ebp
  80270e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802711:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802714:	50                   	push   %eax
  802715:	e8 36 ed ff ff       	call   801450 <fd_alloc>
  80271a:	83 c4 10             	add    $0x10,%esp
		return r;
  80271d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80271f:	85 c0                	test   %eax,%eax
  802721:	78 3e                	js     802761 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802723:	83 ec 04             	sub    $0x4,%esp
  802726:	68 07 04 00 00       	push   $0x407
  80272b:	ff 75 f4             	pushl  -0xc(%ebp)
  80272e:	6a 00                	push   $0x0
  802730:	e8 27 e5 ff ff       	call   800c5c <sys_page_alloc>
  802735:	83 c4 10             	add    $0x10,%esp
		return r;
  802738:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80273a:	85 c0                	test   %eax,%eax
  80273c:	78 23                	js     802761 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80273e:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802744:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802747:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802749:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80274c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802753:	83 ec 0c             	sub    $0xc,%esp
  802756:	50                   	push   %eax
  802757:	e8 cd ec ff ff       	call   801429 <fd2num>
  80275c:	89 c2                	mov    %eax,%edx
  80275e:	83 c4 10             	add    $0x10,%esp
}
  802761:	89 d0                	mov    %edx,%eax
  802763:	c9                   	leave  
  802764:	c3                   	ret    

00802765 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802765:	55                   	push   %ebp
  802766:	89 e5                	mov    %esp,%ebp
  802768:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80276b:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802772:	75 2a                	jne    80279e <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802774:	83 ec 04             	sub    $0x4,%esp
  802777:	6a 07                	push   $0x7
  802779:	68 00 f0 bf ee       	push   $0xeebff000
  80277e:	6a 00                	push   $0x0
  802780:	e8 d7 e4 ff ff       	call   800c5c <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802785:	83 c4 10             	add    $0x10,%esp
  802788:	85 c0                	test   %eax,%eax
  80278a:	79 12                	jns    80279e <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80278c:	50                   	push   %eax
  80278d:	68 d8 30 80 00       	push   $0x8030d8
  802792:	6a 23                	push   $0x23
  802794:	68 1d 33 80 00       	push   $0x80331d
  802799:	e8 5d da ff ff       	call   8001fb <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80279e:	8b 45 08             	mov    0x8(%ebp),%eax
  8027a1:	a3 00 70 80 00       	mov    %eax,0x807000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8027a6:	83 ec 08             	sub    $0x8,%esp
  8027a9:	68 d0 27 80 00       	push   $0x8027d0
  8027ae:	6a 00                	push   $0x0
  8027b0:	e8 f2 e5 ff ff       	call   800da7 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8027b5:	83 c4 10             	add    $0x10,%esp
  8027b8:	85 c0                	test   %eax,%eax
  8027ba:	79 12                	jns    8027ce <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8027bc:	50                   	push   %eax
  8027bd:	68 d8 30 80 00       	push   $0x8030d8
  8027c2:	6a 2c                	push   $0x2c
  8027c4:	68 1d 33 80 00       	push   $0x80331d
  8027c9:	e8 2d da ff ff       	call   8001fb <_panic>
	}
}
  8027ce:	c9                   	leave  
  8027cf:	c3                   	ret    

008027d0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8027d0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8027d1:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8027d6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8027d8:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8027db:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8027df:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8027e4:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8027e8:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8027ea:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8027ed:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8027ee:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8027f1:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8027f2:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8027f3:	c3                   	ret    

008027f4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8027f4:	55                   	push   %ebp
  8027f5:	89 e5                	mov    %esp,%ebp
  8027f7:	56                   	push   %esi
  8027f8:	53                   	push   %ebx
  8027f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8027fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802802:	85 c0                	test   %eax,%eax
  802804:	75 12                	jne    802818 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802806:	83 ec 0c             	sub    $0xc,%esp
  802809:	68 00 00 c0 ee       	push   $0xeec00000
  80280e:	e8 f9 e5 ff ff       	call   800e0c <sys_ipc_recv>
  802813:	83 c4 10             	add    $0x10,%esp
  802816:	eb 0c                	jmp    802824 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802818:	83 ec 0c             	sub    $0xc,%esp
  80281b:	50                   	push   %eax
  80281c:	e8 eb e5 ff ff       	call   800e0c <sys_ipc_recv>
  802821:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802824:	85 f6                	test   %esi,%esi
  802826:	0f 95 c1             	setne  %cl
  802829:	85 db                	test   %ebx,%ebx
  80282b:	0f 95 c2             	setne  %dl
  80282e:	84 d1                	test   %dl,%cl
  802830:	74 09                	je     80283b <ipc_recv+0x47>
  802832:	89 c2                	mov    %eax,%edx
  802834:	c1 ea 1f             	shr    $0x1f,%edx
  802837:	84 d2                	test   %dl,%dl
  802839:	75 2d                	jne    802868 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80283b:	85 f6                	test   %esi,%esi
  80283d:	74 0d                	je     80284c <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80283f:	a1 04 50 80 00       	mov    0x805004,%eax
  802844:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  80284a:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80284c:	85 db                	test   %ebx,%ebx
  80284e:	74 0d                	je     80285d <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802850:	a1 04 50 80 00       	mov    0x805004,%eax
  802855:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  80285b:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80285d:	a1 04 50 80 00       	mov    0x805004,%eax
  802862:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  802868:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80286b:	5b                   	pop    %ebx
  80286c:	5e                   	pop    %esi
  80286d:	5d                   	pop    %ebp
  80286e:	c3                   	ret    

0080286f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80286f:	55                   	push   %ebp
  802870:	89 e5                	mov    %esp,%ebp
  802872:	57                   	push   %edi
  802873:	56                   	push   %esi
  802874:	53                   	push   %ebx
  802875:	83 ec 0c             	sub    $0xc,%esp
  802878:	8b 7d 08             	mov    0x8(%ebp),%edi
  80287b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80287e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802881:	85 db                	test   %ebx,%ebx
  802883:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802888:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80288b:	ff 75 14             	pushl  0x14(%ebp)
  80288e:	53                   	push   %ebx
  80288f:	56                   	push   %esi
  802890:	57                   	push   %edi
  802891:	e8 53 e5 ff ff       	call   800de9 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802896:	89 c2                	mov    %eax,%edx
  802898:	c1 ea 1f             	shr    $0x1f,%edx
  80289b:	83 c4 10             	add    $0x10,%esp
  80289e:	84 d2                	test   %dl,%dl
  8028a0:	74 17                	je     8028b9 <ipc_send+0x4a>
  8028a2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8028a5:	74 12                	je     8028b9 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8028a7:	50                   	push   %eax
  8028a8:	68 2b 33 80 00       	push   $0x80332b
  8028ad:	6a 47                	push   $0x47
  8028af:	68 39 33 80 00       	push   $0x803339
  8028b4:	e8 42 d9 ff ff       	call   8001fb <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8028b9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8028bc:	75 07                	jne    8028c5 <ipc_send+0x56>
			sys_yield();
  8028be:	e8 7a e3 ff ff       	call   800c3d <sys_yield>
  8028c3:	eb c6                	jmp    80288b <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8028c5:	85 c0                	test   %eax,%eax
  8028c7:	75 c2                	jne    80288b <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8028c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8028cc:	5b                   	pop    %ebx
  8028cd:	5e                   	pop    %esi
  8028ce:	5f                   	pop    %edi
  8028cf:	5d                   	pop    %ebp
  8028d0:	c3                   	ret    

008028d1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8028d1:	55                   	push   %ebp
  8028d2:	89 e5                	mov    %esp,%ebp
  8028d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8028d7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8028dc:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  8028e2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8028e8:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  8028ee:	39 ca                	cmp    %ecx,%edx
  8028f0:	75 13                	jne    802905 <ipc_find_env+0x34>
			return envs[i].env_id;
  8028f2:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8028f8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8028fd:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  802903:	eb 0f                	jmp    802914 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802905:	83 c0 01             	add    $0x1,%eax
  802908:	3d 00 04 00 00       	cmp    $0x400,%eax
  80290d:	75 cd                	jne    8028dc <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80290f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802914:	5d                   	pop    %ebp
  802915:	c3                   	ret    

00802916 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802916:	55                   	push   %ebp
  802917:	89 e5                	mov    %esp,%ebp
  802919:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80291c:	89 d0                	mov    %edx,%eax
  80291e:	c1 e8 16             	shr    $0x16,%eax
  802921:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802928:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80292d:	f6 c1 01             	test   $0x1,%cl
  802930:	74 1d                	je     80294f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802932:	c1 ea 0c             	shr    $0xc,%edx
  802935:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80293c:	f6 c2 01             	test   $0x1,%dl
  80293f:	74 0e                	je     80294f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802941:	c1 ea 0c             	shr    $0xc,%edx
  802944:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80294b:	ef 
  80294c:	0f b7 c0             	movzwl %ax,%eax
}
  80294f:	5d                   	pop    %ebp
  802950:	c3                   	ret    
  802951:	66 90                	xchg   %ax,%ax
  802953:	66 90                	xchg   %ax,%ax
  802955:	66 90                	xchg   %ax,%ax
  802957:	66 90                	xchg   %ax,%ax
  802959:	66 90                	xchg   %ax,%ax
  80295b:	66 90                	xchg   %ax,%ax
  80295d:	66 90                	xchg   %ax,%ax
  80295f:	90                   	nop

00802960 <__udivdi3>:
  802960:	55                   	push   %ebp
  802961:	57                   	push   %edi
  802962:	56                   	push   %esi
  802963:	53                   	push   %ebx
  802964:	83 ec 1c             	sub    $0x1c,%esp
  802967:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80296b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80296f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802973:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802977:	85 f6                	test   %esi,%esi
  802979:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80297d:	89 ca                	mov    %ecx,%edx
  80297f:	89 f8                	mov    %edi,%eax
  802981:	75 3d                	jne    8029c0 <__udivdi3+0x60>
  802983:	39 cf                	cmp    %ecx,%edi
  802985:	0f 87 c5 00 00 00    	ja     802a50 <__udivdi3+0xf0>
  80298b:	85 ff                	test   %edi,%edi
  80298d:	89 fd                	mov    %edi,%ebp
  80298f:	75 0b                	jne    80299c <__udivdi3+0x3c>
  802991:	b8 01 00 00 00       	mov    $0x1,%eax
  802996:	31 d2                	xor    %edx,%edx
  802998:	f7 f7                	div    %edi
  80299a:	89 c5                	mov    %eax,%ebp
  80299c:	89 c8                	mov    %ecx,%eax
  80299e:	31 d2                	xor    %edx,%edx
  8029a0:	f7 f5                	div    %ebp
  8029a2:	89 c1                	mov    %eax,%ecx
  8029a4:	89 d8                	mov    %ebx,%eax
  8029a6:	89 cf                	mov    %ecx,%edi
  8029a8:	f7 f5                	div    %ebp
  8029aa:	89 c3                	mov    %eax,%ebx
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
  8029c0:	39 ce                	cmp    %ecx,%esi
  8029c2:	77 74                	ja     802a38 <__udivdi3+0xd8>
  8029c4:	0f bd fe             	bsr    %esi,%edi
  8029c7:	83 f7 1f             	xor    $0x1f,%edi
  8029ca:	0f 84 98 00 00 00    	je     802a68 <__udivdi3+0x108>
  8029d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8029d5:	89 f9                	mov    %edi,%ecx
  8029d7:	89 c5                	mov    %eax,%ebp
  8029d9:	29 fb                	sub    %edi,%ebx
  8029db:	d3 e6                	shl    %cl,%esi
  8029dd:	89 d9                	mov    %ebx,%ecx
  8029df:	d3 ed                	shr    %cl,%ebp
  8029e1:	89 f9                	mov    %edi,%ecx
  8029e3:	d3 e0                	shl    %cl,%eax
  8029e5:	09 ee                	or     %ebp,%esi
  8029e7:	89 d9                	mov    %ebx,%ecx
  8029e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8029ed:	89 d5                	mov    %edx,%ebp
  8029ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8029f3:	d3 ed                	shr    %cl,%ebp
  8029f5:	89 f9                	mov    %edi,%ecx
  8029f7:	d3 e2                	shl    %cl,%edx
  8029f9:	89 d9                	mov    %ebx,%ecx
  8029fb:	d3 e8                	shr    %cl,%eax
  8029fd:	09 c2                	or     %eax,%edx
  8029ff:	89 d0                	mov    %edx,%eax
  802a01:	89 ea                	mov    %ebp,%edx
  802a03:	f7 f6                	div    %esi
  802a05:	89 d5                	mov    %edx,%ebp
  802a07:	89 c3                	mov    %eax,%ebx
  802a09:	f7 64 24 0c          	mull   0xc(%esp)
  802a0d:	39 d5                	cmp    %edx,%ebp
  802a0f:	72 10                	jb     802a21 <__udivdi3+0xc1>
  802a11:	8b 74 24 08          	mov    0x8(%esp),%esi
  802a15:	89 f9                	mov    %edi,%ecx
  802a17:	d3 e6                	shl    %cl,%esi
  802a19:	39 c6                	cmp    %eax,%esi
  802a1b:	73 07                	jae    802a24 <__udivdi3+0xc4>
  802a1d:	39 d5                	cmp    %edx,%ebp
  802a1f:	75 03                	jne    802a24 <__udivdi3+0xc4>
  802a21:	83 eb 01             	sub    $0x1,%ebx
  802a24:	31 ff                	xor    %edi,%edi
  802a26:	89 d8                	mov    %ebx,%eax
  802a28:	89 fa                	mov    %edi,%edx
  802a2a:	83 c4 1c             	add    $0x1c,%esp
  802a2d:	5b                   	pop    %ebx
  802a2e:	5e                   	pop    %esi
  802a2f:	5f                   	pop    %edi
  802a30:	5d                   	pop    %ebp
  802a31:	c3                   	ret    
  802a32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802a38:	31 ff                	xor    %edi,%edi
  802a3a:	31 db                	xor    %ebx,%ebx
  802a3c:	89 d8                	mov    %ebx,%eax
  802a3e:	89 fa                	mov    %edi,%edx
  802a40:	83 c4 1c             	add    $0x1c,%esp
  802a43:	5b                   	pop    %ebx
  802a44:	5e                   	pop    %esi
  802a45:	5f                   	pop    %edi
  802a46:	5d                   	pop    %ebp
  802a47:	c3                   	ret    
  802a48:	90                   	nop
  802a49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802a50:	89 d8                	mov    %ebx,%eax
  802a52:	f7 f7                	div    %edi
  802a54:	31 ff                	xor    %edi,%edi
  802a56:	89 c3                	mov    %eax,%ebx
  802a58:	89 d8                	mov    %ebx,%eax
  802a5a:	89 fa                	mov    %edi,%edx
  802a5c:	83 c4 1c             	add    $0x1c,%esp
  802a5f:	5b                   	pop    %ebx
  802a60:	5e                   	pop    %esi
  802a61:	5f                   	pop    %edi
  802a62:	5d                   	pop    %ebp
  802a63:	c3                   	ret    
  802a64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a68:	39 ce                	cmp    %ecx,%esi
  802a6a:	72 0c                	jb     802a78 <__udivdi3+0x118>
  802a6c:	31 db                	xor    %ebx,%ebx
  802a6e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802a72:	0f 87 34 ff ff ff    	ja     8029ac <__udivdi3+0x4c>
  802a78:	bb 01 00 00 00       	mov    $0x1,%ebx
  802a7d:	e9 2a ff ff ff       	jmp    8029ac <__udivdi3+0x4c>
  802a82:	66 90                	xchg   %ax,%ax
  802a84:	66 90                	xchg   %ax,%ax
  802a86:	66 90                	xchg   %ax,%ax
  802a88:	66 90                	xchg   %ax,%ax
  802a8a:	66 90                	xchg   %ax,%ax
  802a8c:	66 90                	xchg   %ax,%ax
  802a8e:	66 90                	xchg   %ax,%ax

00802a90 <__umoddi3>:
  802a90:	55                   	push   %ebp
  802a91:	57                   	push   %edi
  802a92:	56                   	push   %esi
  802a93:	53                   	push   %ebx
  802a94:	83 ec 1c             	sub    $0x1c,%esp
  802a97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802a9b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802a9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802aa3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802aa7:	85 d2                	test   %edx,%edx
  802aa9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802aad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802ab1:	89 f3                	mov    %esi,%ebx
  802ab3:	89 3c 24             	mov    %edi,(%esp)
  802ab6:	89 74 24 04          	mov    %esi,0x4(%esp)
  802aba:	75 1c                	jne    802ad8 <__umoddi3+0x48>
  802abc:	39 f7                	cmp    %esi,%edi
  802abe:	76 50                	jbe    802b10 <__umoddi3+0x80>
  802ac0:	89 c8                	mov    %ecx,%eax
  802ac2:	89 f2                	mov    %esi,%edx
  802ac4:	f7 f7                	div    %edi
  802ac6:	89 d0                	mov    %edx,%eax
  802ac8:	31 d2                	xor    %edx,%edx
  802aca:	83 c4 1c             	add    $0x1c,%esp
  802acd:	5b                   	pop    %ebx
  802ace:	5e                   	pop    %esi
  802acf:	5f                   	pop    %edi
  802ad0:	5d                   	pop    %ebp
  802ad1:	c3                   	ret    
  802ad2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802ad8:	39 f2                	cmp    %esi,%edx
  802ada:	89 d0                	mov    %edx,%eax
  802adc:	77 52                	ja     802b30 <__umoddi3+0xa0>
  802ade:	0f bd ea             	bsr    %edx,%ebp
  802ae1:	83 f5 1f             	xor    $0x1f,%ebp
  802ae4:	75 5a                	jne    802b40 <__umoddi3+0xb0>
  802ae6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  802aea:	0f 82 e0 00 00 00    	jb     802bd0 <__umoddi3+0x140>
  802af0:	39 0c 24             	cmp    %ecx,(%esp)
  802af3:	0f 86 d7 00 00 00    	jbe    802bd0 <__umoddi3+0x140>
  802af9:	8b 44 24 08          	mov    0x8(%esp),%eax
  802afd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802b01:	83 c4 1c             	add    $0x1c,%esp
  802b04:	5b                   	pop    %ebx
  802b05:	5e                   	pop    %esi
  802b06:	5f                   	pop    %edi
  802b07:	5d                   	pop    %ebp
  802b08:	c3                   	ret    
  802b09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b10:	85 ff                	test   %edi,%edi
  802b12:	89 fd                	mov    %edi,%ebp
  802b14:	75 0b                	jne    802b21 <__umoddi3+0x91>
  802b16:	b8 01 00 00 00       	mov    $0x1,%eax
  802b1b:	31 d2                	xor    %edx,%edx
  802b1d:	f7 f7                	div    %edi
  802b1f:	89 c5                	mov    %eax,%ebp
  802b21:	89 f0                	mov    %esi,%eax
  802b23:	31 d2                	xor    %edx,%edx
  802b25:	f7 f5                	div    %ebp
  802b27:	89 c8                	mov    %ecx,%eax
  802b29:	f7 f5                	div    %ebp
  802b2b:	89 d0                	mov    %edx,%eax
  802b2d:	eb 99                	jmp    802ac8 <__umoddi3+0x38>
  802b2f:	90                   	nop
  802b30:	89 c8                	mov    %ecx,%eax
  802b32:	89 f2                	mov    %esi,%edx
  802b34:	83 c4 1c             	add    $0x1c,%esp
  802b37:	5b                   	pop    %ebx
  802b38:	5e                   	pop    %esi
  802b39:	5f                   	pop    %edi
  802b3a:	5d                   	pop    %ebp
  802b3b:	c3                   	ret    
  802b3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b40:	8b 34 24             	mov    (%esp),%esi
  802b43:	bf 20 00 00 00       	mov    $0x20,%edi
  802b48:	89 e9                	mov    %ebp,%ecx
  802b4a:	29 ef                	sub    %ebp,%edi
  802b4c:	d3 e0                	shl    %cl,%eax
  802b4e:	89 f9                	mov    %edi,%ecx
  802b50:	89 f2                	mov    %esi,%edx
  802b52:	d3 ea                	shr    %cl,%edx
  802b54:	89 e9                	mov    %ebp,%ecx
  802b56:	09 c2                	or     %eax,%edx
  802b58:	89 d8                	mov    %ebx,%eax
  802b5a:	89 14 24             	mov    %edx,(%esp)
  802b5d:	89 f2                	mov    %esi,%edx
  802b5f:	d3 e2                	shl    %cl,%edx
  802b61:	89 f9                	mov    %edi,%ecx
  802b63:	89 54 24 04          	mov    %edx,0x4(%esp)
  802b67:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802b6b:	d3 e8                	shr    %cl,%eax
  802b6d:	89 e9                	mov    %ebp,%ecx
  802b6f:	89 c6                	mov    %eax,%esi
  802b71:	d3 e3                	shl    %cl,%ebx
  802b73:	89 f9                	mov    %edi,%ecx
  802b75:	89 d0                	mov    %edx,%eax
  802b77:	d3 e8                	shr    %cl,%eax
  802b79:	89 e9                	mov    %ebp,%ecx
  802b7b:	09 d8                	or     %ebx,%eax
  802b7d:	89 d3                	mov    %edx,%ebx
  802b7f:	89 f2                	mov    %esi,%edx
  802b81:	f7 34 24             	divl   (%esp)
  802b84:	89 d6                	mov    %edx,%esi
  802b86:	d3 e3                	shl    %cl,%ebx
  802b88:	f7 64 24 04          	mull   0x4(%esp)
  802b8c:	39 d6                	cmp    %edx,%esi
  802b8e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802b92:	89 d1                	mov    %edx,%ecx
  802b94:	89 c3                	mov    %eax,%ebx
  802b96:	72 08                	jb     802ba0 <__umoddi3+0x110>
  802b98:	75 11                	jne    802bab <__umoddi3+0x11b>
  802b9a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802b9e:	73 0b                	jae    802bab <__umoddi3+0x11b>
  802ba0:	2b 44 24 04          	sub    0x4(%esp),%eax
  802ba4:	1b 14 24             	sbb    (%esp),%edx
  802ba7:	89 d1                	mov    %edx,%ecx
  802ba9:	89 c3                	mov    %eax,%ebx
  802bab:	8b 54 24 08          	mov    0x8(%esp),%edx
  802baf:	29 da                	sub    %ebx,%edx
  802bb1:	19 ce                	sbb    %ecx,%esi
  802bb3:	89 f9                	mov    %edi,%ecx
  802bb5:	89 f0                	mov    %esi,%eax
  802bb7:	d3 e0                	shl    %cl,%eax
  802bb9:	89 e9                	mov    %ebp,%ecx
  802bbb:	d3 ea                	shr    %cl,%edx
  802bbd:	89 e9                	mov    %ebp,%ecx
  802bbf:	d3 ee                	shr    %cl,%esi
  802bc1:	09 d0                	or     %edx,%eax
  802bc3:	89 f2                	mov    %esi,%edx
  802bc5:	83 c4 1c             	add    $0x1c,%esp
  802bc8:	5b                   	pop    %ebx
  802bc9:	5e                   	pop    %esi
  802bca:	5f                   	pop    %edi
  802bcb:	5d                   	pop    %ebp
  802bcc:	c3                   	ret    
  802bcd:	8d 76 00             	lea    0x0(%esi),%esi
  802bd0:	29 f9                	sub    %edi,%ecx
  802bd2:	19 d6                	sbb    %edx,%esi
  802bd4:	89 74 24 04          	mov    %esi,0x4(%esp)
  802bd8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802bdc:	e9 18 ff ff ff       	jmp    802af9 <__umoddi3+0x69>
