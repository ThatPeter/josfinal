
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
  800044:	e8 11 08 00 00       	call   80085a <strcpy>
	exit();
  800049:	e8 94 01 00 00       	call   8001e2 <exit>
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
  800074:	e8 e4 0b 00 00       	call   800c5d <sys_page_alloc>
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	85 c0                	test   %eax,%eax
  80007e:	79 12                	jns    800092 <umain+0x3f>
		panic("sys_page_alloc: %e", r);
  800080:	50                   	push   %eax
  800081:	68 2c 29 80 00       	push   $0x80292c
  800086:	6a 13                	push   $0x13
  800088:	68 3f 29 80 00       	push   $0x80293f
  80008d:	e8 6a 01 00 00       	call   8001fc <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 cd 0e 00 00       	call   800f64 <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 53 29 80 00       	push   $0x802953
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 3f 29 80 00       	push   $0x80293f
  8000aa:	e8 4d 01 00 00       	call   8001fc <_panic>
	if (r == 0) {
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	75 1b                	jne    8000ce <umain+0x7b>
		strcpy(VA, msg);
  8000b3:	83 ec 08             	sub    $0x8,%esp
  8000b6:	ff 35 04 30 80 00    	pushl  0x803004
  8000bc:	68 00 00 00 a0       	push   $0xa0000000
  8000c1:	e8 94 07 00 00       	call   80085a <strcpy>
		exit();
  8000c6:	e8 17 01 00 00       	call   8001e2 <exit>
  8000cb:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	53                   	push   %ebx
  8000d2:	e8 f2 21 00 00       	call   8022c9 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 30 80 00    	pushl  0x803004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 1a 08 00 00       	call   800904 <strcmp>
  8000ea:	83 c4 08             	add    $0x8,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	ba 26 29 80 00       	mov    $0x802926,%edx
  8000f4:	b8 20 29 80 00       	mov    $0x802920,%eax
  8000f9:	0f 45 c2             	cmovne %edx,%eax
  8000fc:	50                   	push   %eax
  8000fd:	68 5c 29 80 00       	push   $0x80295c
  800102:	e8 ce 01 00 00       	call   8002d5 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800107:	6a 00                	push   $0x0
  800109:	68 77 29 80 00       	push   $0x802977
  80010e:	68 7c 29 80 00       	push   $0x80297c
  800113:	68 7b 29 80 00       	push   $0x80297b
  800118:	e8 dd 1d 00 00       	call   801efa <spawnl>
  80011d:	83 c4 20             	add    $0x20,%esp
  800120:	85 c0                	test   %eax,%eax
  800122:	79 12                	jns    800136 <umain+0xe3>
		panic("spawn: %e", r);
  800124:	50                   	push   %eax
  800125:	68 89 29 80 00       	push   $0x802989
  80012a:	6a 21                	push   $0x21
  80012c:	68 3f 29 80 00       	push   $0x80293f
  800131:	e8 c6 00 00 00       	call   8001fc <_panic>
	wait(r);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	e8 8a 21 00 00       	call   8022c9 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff 35 00 30 80 00    	pushl  0x803000
  800148:	68 00 00 00 a0       	push   $0xa0000000
  80014d:	e8 b2 07 00 00       	call   800904 <strcmp>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba 26 29 80 00       	mov    $0x802926,%edx
  80015c:	b8 20 29 80 00       	mov    $0x802920,%eax
  800161:	0f 45 c2             	cmovne %edx,%eax
  800164:	50                   	push   %eax
  800165:	68 93 29 80 00       	push   $0x802993
  80016a:	e8 66 01 00 00       	call   8002d5 <cprintf>
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
  800183:	e8 97 0a 00 00       	call   800c1f <sys_getenvid>
  800188:	25 ff 03 00 00       	and    $0x3ff,%eax
  80018d:	89 c2                	mov    %eax,%edx
  80018f:	c1 e2 07             	shl    $0x7,%edx
  800192:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800199:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80019e:	85 db                	test   %ebx,%ebx
  8001a0:	7e 07                	jle    8001a9 <libmain+0x31>
		binaryname = argv[0];
  8001a2:	8b 06                	mov    (%esi),%eax
  8001a4:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001a9:	83 ec 08             	sub    $0x8,%esp
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	e8 a0 fe ff ff       	call   800053 <umain>

	// exit gracefully
	exit();
  8001b3:	e8 2a 00 00 00       	call   8001e2 <exit>
}
  8001b8:	83 c4 10             	add    $0x10,%esp
  8001bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001be:	5b                   	pop    %ebx
  8001bf:	5e                   	pop    %esi
  8001c0:	5d                   	pop    %ebp
  8001c1:	c3                   	ret    

008001c2 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  8001c2:	55                   	push   %ebp
  8001c3:	89 e5                	mov    %esp,%ebp
  8001c5:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  8001c8:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  8001cd:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8001cf:	e8 4b 0a 00 00       	call   800c1f <sys_getenvid>
  8001d4:	83 ec 0c             	sub    $0xc,%esp
  8001d7:	50                   	push   %eax
  8001d8:	e8 91 0c 00 00       	call   800e6e <sys_thread_free>
}
  8001dd:	83 c4 10             	add    $0x10,%esp
  8001e0:	c9                   	leave  
  8001e1:	c3                   	ret    

008001e2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001e2:	55                   	push   %ebp
  8001e3:	89 e5                	mov    %esp,%ebp
  8001e5:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001e8:	e8 5e 11 00 00       	call   80134b <close_all>
	sys_env_destroy(0);
  8001ed:	83 ec 0c             	sub    $0xc,%esp
  8001f0:	6a 00                	push   $0x0
  8001f2:	e8 e7 09 00 00       	call   800bde <sys_env_destroy>
}
  8001f7:	83 c4 10             	add    $0x10,%esp
  8001fa:	c9                   	leave  
  8001fb:	c3                   	ret    

008001fc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	56                   	push   %esi
  800200:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800201:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800204:	8b 35 08 30 80 00    	mov    0x803008,%esi
  80020a:	e8 10 0a 00 00       	call   800c1f <sys_getenvid>
  80020f:	83 ec 0c             	sub    $0xc,%esp
  800212:	ff 75 0c             	pushl  0xc(%ebp)
  800215:	ff 75 08             	pushl  0x8(%ebp)
  800218:	56                   	push   %esi
  800219:	50                   	push   %eax
  80021a:	68 d8 29 80 00       	push   $0x8029d8
  80021f:	e8 b1 00 00 00       	call   8002d5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800224:	83 c4 18             	add    $0x18,%esp
  800227:	53                   	push   %ebx
  800228:	ff 75 10             	pushl  0x10(%ebp)
  80022b:	e8 54 00 00 00       	call   800284 <vcprintf>
	cprintf("\n");
  800230:	c7 04 24 34 2f 80 00 	movl   $0x802f34,(%esp)
  800237:	e8 99 00 00 00       	call   8002d5 <cprintf>
  80023c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80023f:	cc                   	int3   
  800240:	eb fd                	jmp    80023f <_panic+0x43>

00800242 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800242:	55                   	push   %ebp
  800243:	89 e5                	mov    %esp,%ebp
  800245:	53                   	push   %ebx
  800246:	83 ec 04             	sub    $0x4,%esp
  800249:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80024c:	8b 13                	mov    (%ebx),%edx
  80024e:	8d 42 01             	lea    0x1(%edx),%eax
  800251:	89 03                	mov    %eax,(%ebx)
  800253:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800256:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80025a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80025f:	75 1a                	jne    80027b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800261:	83 ec 08             	sub    $0x8,%esp
  800264:	68 ff 00 00 00       	push   $0xff
  800269:	8d 43 08             	lea    0x8(%ebx),%eax
  80026c:	50                   	push   %eax
  80026d:	e8 2f 09 00 00       	call   800ba1 <sys_cputs>
		b->idx = 0;
  800272:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800278:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80027b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80027f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800282:	c9                   	leave  
  800283:	c3                   	ret    

00800284 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80028d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800294:	00 00 00 
	b.cnt = 0;
  800297:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80029e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002a1:	ff 75 0c             	pushl  0xc(%ebp)
  8002a4:	ff 75 08             	pushl  0x8(%ebp)
  8002a7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002ad:	50                   	push   %eax
  8002ae:	68 42 02 80 00       	push   $0x800242
  8002b3:	e8 54 01 00 00       	call   80040c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002b8:	83 c4 08             	add    $0x8,%esp
  8002bb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002c1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002c7:	50                   	push   %eax
  8002c8:	e8 d4 08 00 00       	call   800ba1 <sys_cputs>

	return b.cnt;
}
  8002cd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002d3:	c9                   	leave  
  8002d4:	c3                   	ret    

008002d5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002db:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002de:	50                   	push   %eax
  8002df:	ff 75 08             	pushl  0x8(%ebp)
  8002e2:	e8 9d ff ff ff       	call   800284 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002e7:	c9                   	leave  
  8002e8:	c3                   	ret    

008002e9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
  8002ec:	57                   	push   %edi
  8002ed:	56                   	push   %esi
  8002ee:	53                   	push   %ebx
  8002ef:	83 ec 1c             	sub    $0x1c,%esp
  8002f2:	89 c7                	mov    %eax,%edi
  8002f4:	89 d6                	mov    %edx,%esi
  8002f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ff:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800302:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800305:	bb 00 00 00 00       	mov    $0x0,%ebx
  80030a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80030d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800310:	39 d3                	cmp    %edx,%ebx
  800312:	72 05                	jb     800319 <printnum+0x30>
  800314:	39 45 10             	cmp    %eax,0x10(%ebp)
  800317:	77 45                	ja     80035e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800319:	83 ec 0c             	sub    $0xc,%esp
  80031c:	ff 75 18             	pushl  0x18(%ebp)
  80031f:	8b 45 14             	mov    0x14(%ebp),%eax
  800322:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800325:	53                   	push   %ebx
  800326:	ff 75 10             	pushl  0x10(%ebp)
  800329:	83 ec 08             	sub    $0x8,%esp
  80032c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80032f:	ff 75 e0             	pushl  -0x20(%ebp)
  800332:	ff 75 dc             	pushl  -0x24(%ebp)
  800335:	ff 75 d8             	pushl  -0x28(%ebp)
  800338:	e8 53 23 00 00       	call   802690 <__udivdi3>
  80033d:	83 c4 18             	add    $0x18,%esp
  800340:	52                   	push   %edx
  800341:	50                   	push   %eax
  800342:	89 f2                	mov    %esi,%edx
  800344:	89 f8                	mov    %edi,%eax
  800346:	e8 9e ff ff ff       	call   8002e9 <printnum>
  80034b:	83 c4 20             	add    $0x20,%esp
  80034e:	eb 18                	jmp    800368 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800350:	83 ec 08             	sub    $0x8,%esp
  800353:	56                   	push   %esi
  800354:	ff 75 18             	pushl  0x18(%ebp)
  800357:	ff d7                	call   *%edi
  800359:	83 c4 10             	add    $0x10,%esp
  80035c:	eb 03                	jmp    800361 <printnum+0x78>
  80035e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800361:	83 eb 01             	sub    $0x1,%ebx
  800364:	85 db                	test   %ebx,%ebx
  800366:	7f e8                	jg     800350 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800368:	83 ec 08             	sub    $0x8,%esp
  80036b:	56                   	push   %esi
  80036c:	83 ec 04             	sub    $0x4,%esp
  80036f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800372:	ff 75 e0             	pushl  -0x20(%ebp)
  800375:	ff 75 dc             	pushl  -0x24(%ebp)
  800378:	ff 75 d8             	pushl  -0x28(%ebp)
  80037b:	e8 40 24 00 00       	call   8027c0 <__umoddi3>
  800380:	83 c4 14             	add    $0x14,%esp
  800383:	0f be 80 fb 29 80 00 	movsbl 0x8029fb(%eax),%eax
  80038a:	50                   	push   %eax
  80038b:	ff d7                	call   *%edi
}
  80038d:	83 c4 10             	add    $0x10,%esp
  800390:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800393:	5b                   	pop    %ebx
  800394:	5e                   	pop    %esi
  800395:	5f                   	pop    %edi
  800396:	5d                   	pop    %ebp
  800397:	c3                   	ret    

00800398 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80039b:	83 fa 01             	cmp    $0x1,%edx
  80039e:	7e 0e                	jle    8003ae <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003a0:	8b 10                	mov    (%eax),%edx
  8003a2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003a5:	89 08                	mov    %ecx,(%eax)
  8003a7:	8b 02                	mov    (%edx),%eax
  8003a9:	8b 52 04             	mov    0x4(%edx),%edx
  8003ac:	eb 22                	jmp    8003d0 <getuint+0x38>
	else if (lflag)
  8003ae:	85 d2                	test   %edx,%edx
  8003b0:	74 10                	je     8003c2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003b2:	8b 10                	mov    (%eax),%edx
  8003b4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b7:	89 08                	mov    %ecx,(%eax)
  8003b9:	8b 02                	mov    (%edx),%eax
  8003bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c0:	eb 0e                	jmp    8003d0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003c2:	8b 10                	mov    (%eax),%edx
  8003c4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c7:	89 08                	mov    %ecx,(%eax)
  8003c9:	8b 02                	mov    (%edx),%eax
  8003cb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003d0:	5d                   	pop    %ebp
  8003d1:	c3                   	ret    

008003d2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003d2:	55                   	push   %ebp
  8003d3:	89 e5                	mov    %esp,%ebp
  8003d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003d8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003dc:	8b 10                	mov    (%eax),%edx
  8003de:	3b 50 04             	cmp    0x4(%eax),%edx
  8003e1:	73 0a                	jae    8003ed <sprintputch+0x1b>
		*b->buf++ = ch;
  8003e3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003e6:	89 08                	mov    %ecx,(%eax)
  8003e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003eb:	88 02                	mov    %al,(%edx)
}
  8003ed:	5d                   	pop    %ebp
  8003ee:	c3                   	ret    

008003ef <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003ef:	55                   	push   %ebp
  8003f0:	89 e5                	mov    %esp,%ebp
  8003f2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003f5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003f8:	50                   	push   %eax
  8003f9:	ff 75 10             	pushl  0x10(%ebp)
  8003fc:	ff 75 0c             	pushl  0xc(%ebp)
  8003ff:	ff 75 08             	pushl  0x8(%ebp)
  800402:	e8 05 00 00 00       	call   80040c <vprintfmt>
	va_end(ap);
}
  800407:	83 c4 10             	add    $0x10,%esp
  80040a:	c9                   	leave  
  80040b:	c3                   	ret    

0080040c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	57                   	push   %edi
  800410:	56                   	push   %esi
  800411:	53                   	push   %ebx
  800412:	83 ec 2c             	sub    $0x2c,%esp
  800415:	8b 75 08             	mov    0x8(%ebp),%esi
  800418:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80041b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80041e:	eb 12                	jmp    800432 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800420:	85 c0                	test   %eax,%eax
  800422:	0f 84 89 03 00 00    	je     8007b1 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800428:	83 ec 08             	sub    $0x8,%esp
  80042b:	53                   	push   %ebx
  80042c:	50                   	push   %eax
  80042d:	ff d6                	call   *%esi
  80042f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800432:	83 c7 01             	add    $0x1,%edi
  800435:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800439:	83 f8 25             	cmp    $0x25,%eax
  80043c:	75 e2                	jne    800420 <vprintfmt+0x14>
  80043e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800442:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800449:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800450:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800457:	ba 00 00 00 00       	mov    $0x0,%edx
  80045c:	eb 07                	jmp    800465 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800461:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800465:	8d 47 01             	lea    0x1(%edi),%eax
  800468:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80046b:	0f b6 07             	movzbl (%edi),%eax
  80046e:	0f b6 c8             	movzbl %al,%ecx
  800471:	83 e8 23             	sub    $0x23,%eax
  800474:	3c 55                	cmp    $0x55,%al
  800476:	0f 87 1a 03 00 00    	ja     800796 <vprintfmt+0x38a>
  80047c:	0f b6 c0             	movzbl %al,%eax
  80047f:	ff 24 85 40 2b 80 00 	jmp    *0x802b40(,%eax,4)
  800486:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800489:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80048d:	eb d6                	jmp    800465 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800492:	b8 00 00 00 00       	mov    $0x0,%eax
  800497:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80049a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80049d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004a1:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004a4:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004a7:	83 fa 09             	cmp    $0x9,%edx
  8004aa:	77 39                	ja     8004e5 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004ac:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004af:	eb e9                	jmp    80049a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b4:	8d 48 04             	lea    0x4(%eax),%ecx
  8004b7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004ba:	8b 00                	mov    (%eax),%eax
  8004bc:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004c2:	eb 27                	jmp    8004eb <vprintfmt+0xdf>
  8004c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004c7:	85 c0                	test   %eax,%eax
  8004c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004ce:	0f 49 c8             	cmovns %eax,%ecx
  8004d1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d7:	eb 8c                	jmp    800465 <vprintfmt+0x59>
  8004d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004dc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004e3:	eb 80                	jmp    800465 <vprintfmt+0x59>
  8004e5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004e8:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004eb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ef:	0f 89 70 ff ff ff    	jns    800465 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004f5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004fb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800502:	e9 5e ff ff ff       	jmp    800465 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800507:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80050d:	e9 53 ff ff ff       	jmp    800465 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800512:	8b 45 14             	mov    0x14(%ebp),%eax
  800515:	8d 50 04             	lea    0x4(%eax),%edx
  800518:	89 55 14             	mov    %edx,0x14(%ebp)
  80051b:	83 ec 08             	sub    $0x8,%esp
  80051e:	53                   	push   %ebx
  80051f:	ff 30                	pushl  (%eax)
  800521:	ff d6                	call   *%esi
			break;
  800523:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800526:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800529:	e9 04 ff ff ff       	jmp    800432 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8d 50 04             	lea    0x4(%eax),%edx
  800534:	89 55 14             	mov    %edx,0x14(%ebp)
  800537:	8b 00                	mov    (%eax),%eax
  800539:	99                   	cltd   
  80053a:	31 d0                	xor    %edx,%eax
  80053c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80053e:	83 f8 0f             	cmp    $0xf,%eax
  800541:	7f 0b                	jg     80054e <vprintfmt+0x142>
  800543:	8b 14 85 a0 2c 80 00 	mov    0x802ca0(,%eax,4),%edx
  80054a:	85 d2                	test   %edx,%edx
  80054c:	75 18                	jne    800566 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80054e:	50                   	push   %eax
  80054f:	68 13 2a 80 00       	push   $0x802a13
  800554:	53                   	push   %ebx
  800555:	56                   	push   %esi
  800556:	e8 94 fe ff ff       	call   8003ef <printfmt>
  80055b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800561:	e9 cc fe ff ff       	jmp    800432 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800566:	52                   	push   %edx
  800567:	68 4d 2e 80 00       	push   $0x802e4d
  80056c:	53                   	push   %ebx
  80056d:	56                   	push   %esi
  80056e:	e8 7c fe ff ff       	call   8003ef <printfmt>
  800573:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800576:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800579:	e9 b4 fe ff ff       	jmp    800432 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80057e:	8b 45 14             	mov    0x14(%ebp),%eax
  800581:	8d 50 04             	lea    0x4(%eax),%edx
  800584:	89 55 14             	mov    %edx,0x14(%ebp)
  800587:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800589:	85 ff                	test   %edi,%edi
  80058b:	b8 0c 2a 80 00       	mov    $0x802a0c,%eax
  800590:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800593:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800597:	0f 8e 94 00 00 00    	jle    800631 <vprintfmt+0x225>
  80059d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005a1:	0f 84 98 00 00 00    	je     80063f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	ff 75 d0             	pushl  -0x30(%ebp)
  8005ad:	57                   	push   %edi
  8005ae:	e8 86 02 00 00       	call   800839 <strnlen>
  8005b3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005b6:	29 c1                	sub    %eax,%ecx
  8005b8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005bb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005be:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005c5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005c8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ca:	eb 0f                	jmp    8005db <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005cc:	83 ec 08             	sub    $0x8,%esp
  8005cf:	53                   	push   %ebx
  8005d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8005d3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d5:	83 ef 01             	sub    $0x1,%edi
  8005d8:	83 c4 10             	add    $0x10,%esp
  8005db:	85 ff                	test   %edi,%edi
  8005dd:	7f ed                	jg     8005cc <vprintfmt+0x1c0>
  8005df:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005e2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005e5:	85 c9                	test   %ecx,%ecx
  8005e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ec:	0f 49 c1             	cmovns %ecx,%eax
  8005ef:	29 c1                	sub    %eax,%ecx
  8005f1:	89 75 08             	mov    %esi,0x8(%ebp)
  8005f4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005f7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005fa:	89 cb                	mov    %ecx,%ebx
  8005fc:	eb 4d                	jmp    80064b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005fe:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800602:	74 1b                	je     80061f <vprintfmt+0x213>
  800604:	0f be c0             	movsbl %al,%eax
  800607:	83 e8 20             	sub    $0x20,%eax
  80060a:	83 f8 5e             	cmp    $0x5e,%eax
  80060d:	76 10                	jbe    80061f <vprintfmt+0x213>
					putch('?', putdat);
  80060f:	83 ec 08             	sub    $0x8,%esp
  800612:	ff 75 0c             	pushl  0xc(%ebp)
  800615:	6a 3f                	push   $0x3f
  800617:	ff 55 08             	call   *0x8(%ebp)
  80061a:	83 c4 10             	add    $0x10,%esp
  80061d:	eb 0d                	jmp    80062c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80061f:	83 ec 08             	sub    $0x8,%esp
  800622:	ff 75 0c             	pushl  0xc(%ebp)
  800625:	52                   	push   %edx
  800626:	ff 55 08             	call   *0x8(%ebp)
  800629:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80062c:	83 eb 01             	sub    $0x1,%ebx
  80062f:	eb 1a                	jmp    80064b <vprintfmt+0x23f>
  800631:	89 75 08             	mov    %esi,0x8(%ebp)
  800634:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800637:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80063a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80063d:	eb 0c                	jmp    80064b <vprintfmt+0x23f>
  80063f:	89 75 08             	mov    %esi,0x8(%ebp)
  800642:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800645:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800648:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80064b:	83 c7 01             	add    $0x1,%edi
  80064e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800652:	0f be d0             	movsbl %al,%edx
  800655:	85 d2                	test   %edx,%edx
  800657:	74 23                	je     80067c <vprintfmt+0x270>
  800659:	85 f6                	test   %esi,%esi
  80065b:	78 a1                	js     8005fe <vprintfmt+0x1f2>
  80065d:	83 ee 01             	sub    $0x1,%esi
  800660:	79 9c                	jns    8005fe <vprintfmt+0x1f2>
  800662:	89 df                	mov    %ebx,%edi
  800664:	8b 75 08             	mov    0x8(%ebp),%esi
  800667:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80066a:	eb 18                	jmp    800684 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80066c:	83 ec 08             	sub    $0x8,%esp
  80066f:	53                   	push   %ebx
  800670:	6a 20                	push   $0x20
  800672:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800674:	83 ef 01             	sub    $0x1,%edi
  800677:	83 c4 10             	add    $0x10,%esp
  80067a:	eb 08                	jmp    800684 <vprintfmt+0x278>
  80067c:	89 df                	mov    %ebx,%edi
  80067e:	8b 75 08             	mov    0x8(%ebp),%esi
  800681:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800684:	85 ff                	test   %edi,%edi
  800686:	7f e4                	jg     80066c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800688:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80068b:	e9 a2 fd ff ff       	jmp    800432 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800690:	83 fa 01             	cmp    $0x1,%edx
  800693:	7e 16                	jle    8006ab <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8d 50 08             	lea    0x8(%eax),%edx
  80069b:	89 55 14             	mov    %edx,0x14(%ebp)
  80069e:	8b 50 04             	mov    0x4(%eax),%edx
  8006a1:	8b 00                	mov    (%eax),%eax
  8006a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006a9:	eb 32                	jmp    8006dd <vprintfmt+0x2d1>
	else if (lflag)
  8006ab:	85 d2                	test   %edx,%edx
  8006ad:	74 18                	je     8006c7 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006af:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b2:	8d 50 04             	lea    0x4(%eax),%edx
  8006b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b8:	8b 00                	mov    (%eax),%eax
  8006ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006bd:	89 c1                	mov    %eax,%ecx
  8006bf:	c1 f9 1f             	sar    $0x1f,%ecx
  8006c2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006c5:	eb 16                	jmp    8006dd <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ca:	8d 50 04             	lea    0x4(%eax),%edx
  8006cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d0:	8b 00                	mov    (%eax),%eax
  8006d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d5:	89 c1                	mov    %eax,%ecx
  8006d7:	c1 f9 1f             	sar    $0x1f,%ecx
  8006da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006dd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006e0:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006e3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006e8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006ec:	79 74                	jns    800762 <vprintfmt+0x356>
				putch('-', putdat);
  8006ee:	83 ec 08             	sub    $0x8,%esp
  8006f1:	53                   	push   %ebx
  8006f2:	6a 2d                	push   $0x2d
  8006f4:	ff d6                	call   *%esi
				num = -(long long) num;
  8006f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006fc:	f7 d8                	neg    %eax
  8006fe:	83 d2 00             	adc    $0x0,%edx
  800701:	f7 da                	neg    %edx
  800703:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800706:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80070b:	eb 55                	jmp    800762 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80070d:	8d 45 14             	lea    0x14(%ebp),%eax
  800710:	e8 83 fc ff ff       	call   800398 <getuint>
			base = 10;
  800715:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80071a:	eb 46                	jmp    800762 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80071c:	8d 45 14             	lea    0x14(%ebp),%eax
  80071f:	e8 74 fc ff ff       	call   800398 <getuint>
			base = 8;
  800724:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800729:	eb 37                	jmp    800762 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80072b:	83 ec 08             	sub    $0x8,%esp
  80072e:	53                   	push   %ebx
  80072f:	6a 30                	push   $0x30
  800731:	ff d6                	call   *%esi
			putch('x', putdat);
  800733:	83 c4 08             	add    $0x8,%esp
  800736:	53                   	push   %ebx
  800737:	6a 78                	push   $0x78
  800739:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80073b:	8b 45 14             	mov    0x14(%ebp),%eax
  80073e:	8d 50 04             	lea    0x4(%eax),%edx
  800741:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800744:	8b 00                	mov    (%eax),%eax
  800746:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80074b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80074e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800753:	eb 0d                	jmp    800762 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800755:	8d 45 14             	lea    0x14(%ebp),%eax
  800758:	e8 3b fc ff ff       	call   800398 <getuint>
			base = 16;
  80075d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800762:	83 ec 0c             	sub    $0xc,%esp
  800765:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800769:	57                   	push   %edi
  80076a:	ff 75 e0             	pushl  -0x20(%ebp)
  80076d:	51                   	push   %ecx
  80076e:	52                   	push   %edx
  80076f:	50                   	push   %eax
  800770:	89 da                	mov    %ebx,%edx
  800772:	89 f0                	mov    %esi,%eax
  800774:	e8 70 fb ff ff       	call   8002e9 <printnum>
			break;
  800779:	83 c4 20             	add    $0x20,%esp
  80077c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80077f:	e9 ae fc ff ff       	jmp    800432 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800784:	83 ec 08             	sub    $0x8,%esp
  800787:	53                   	push   %ebx
  800788:	51                   	push   %ecx
  800789:	ff d6                	call   *%esi
			break;
  80078b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800791:	e9 9c fc ff ff       	jmp    800432 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800796:	83 ec 08             	sub    $0x8,%esp
  800799:	53                   	push   %ebx
  80079a:	6a 25                	push   $0x25
  80079c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80079e:	83 c4 10             	add    $0x10,%esp
  8007a1:	eb 03                	jmp    8007a6 <vprintfmt+0x39a>
  8007a3:	83 ef 01             	sub    $0x1,%edi
  8007a6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007aa:	75 f7                	jne    8007a3 <vprintfmt+0x397>
  8007ac:	e9 81 fc ff ff       	jmp    800432 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007b4:	5b                   	pop    %ebx
  8007b5:	5e                   	pop    %esi
  8007b6:	5f                   	pop    %edi
  8007b7:	5d                   	pop    %ebp
  8007b8:	c3                   	ret    

008007b9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	83 ec 18             	sub    $0x18,%esp
  8007bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007cc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007d6:	85 c0                	test   %eax,%eax
  8007d8:	74 26                	je     800800 <vsnprintf+0x47>
  8007da:	85 d2                	test   %edx,%edx
  8007dc:	7e 22                	jle    800800 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007de:	ff 75 14             	pushl  0x14(%ebp)
  8007e1:	ff 75 10             	pushl  0x10(%ebp)
  8007e4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e7:	50                   	push   %eax
  8007e8:	68 d2 03 80 00       	push   $0x8003d2
  8007ed:	e8 1a fc ff ff       	call   80040c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007f5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007fb:	83 c4 10             	add    $0x10,%esp
  8007fe:	eb 05                	jmp    800805 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800800:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800805:	c9                   	leave  
  800806:	c3                   	ret    

00800807 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80080d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800810:	50                   	push   %eax
  800811:	ff 75 10             	pushl  0x10(%ebp)
  800814:	ff 75 0c             	pushl  0xc(%ebp)
  800817:	ff 75 08             	pushl  0x8(%ebp)
  80081a:	e8 9a ff ff ff       	call   8007b9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80081f:	c9                   	leave  
  800820:	c3                   	ret    

00800821 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800827:	b8 00 00 00 00       	mov    $0x0,%eax
  80082c:	eb 03                	jmp    800831 <strlen+0x10>
		n++;
  80082e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800831:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800835:	75 f7                	jne    80082e <strlen+0xd>
		n++;
	return n;
}
  800837:	5d                   	pop    %ebp
  800838:	c3                   	ret    

00800839 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800842:	ba 00 00 00 00       	mov    $0x0,%edx
  800847:	eb 03                	jmp    80084c <strnlen+0x13>
		n++;
  800849:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80084c:	39 c2                	cmp    %eax,%edx
  80084e:	74 08                	je     800858 <strnlen+0x1f>
  800850:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800854:	75 f3                	jne    800849 <strnlen+0x10>
  800856:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	53                   	push   %ebx
  80085e:	8b 45 08             	mov    0x8(%ebp),%eax
  800861:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800864:	89 c2                	mov    %eax,%edx
  800866:	83 c2 01             	add    $0x1,%edx
  800869:	83 c1 01             	add    $0x1,%ecx
  80086c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800870:	88 5a ff             	mov    %bl,-0x1(%edx)
  800873:	84 db                	test   %bl,%bl
  800875:	75 ef                	jne    800866 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800877:	5b                   	pop    %ebx
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	53                   	push   %ebx
  80087e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800881:	53                   	push   %ebx
  800882:	e8 9a ff ff ff       	call   800821 <strlen>
  800887:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80088a:	ff 75 0c             	pushl  0xc(%ebp)
  80088d:	01 d8                	add    %ebx,%eax
  80088f:	50                   	push   %eax
  800890:	e8 c5 ff ff ff       	call   80085a <strcpy>
	return dst;
}
  800895:	89 d8                	mov    %ebx,%eax
  800897:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80089a:	c9                   	leave  
  80089b:	c3                   	ret    

0080089c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	56                   	push   %esi
  8008a0:	53                   	push   %ebx
  8008a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a7:	89 f3                	mov    %esi,%ebx
  8008a9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008ac:	89 f2                	mov    %esi,%edx
  8008ae:	eb 0f                	jmp    8008bf <strncpy+0x23>
		*dst++ = *src;
  8008b0:	83 c2 01             	add    $0x1,%edx
  8008b3:	0f b6 01             	movzbl (%ecx),%eax
  8008b6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b9:	80 39 01             	cmpb   $0x1,(%ecx)
  8008bc:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008bf:	39 da                	cmp    %ebx,%edx
  8008c1:	75 ed                	jne    8008b0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008c3:	89 f0                	mov    %esi,%eax
  8008c5:	5b                   	pop    %ebx
  8008c6:	5e                   	pop    %esi
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    

008008c9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	56                   	push   %esi
  8008cd:	53                   	push   %ebx
  8008ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d4:	8b 55 10             	mov    0x10(%ebp),%edx
  8008d7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d9:	85 d2                	test   %edx,%edx
  8008db:	74 21                	je     8008fe <strlcpy+0x35>
  8008dd:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008e1:	89 f2                	mov    %esi,%edx
  8008e3:	eb 09                	jmp    8008ee <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008e5:	83 c2 01             	add    $0x1,%edx
  8008e8:	83 c1 01             	add    $0x1,%ecx
  8008eb:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008ee:	39 c2                	cmp    %eax,%edx
  8008f0:	74 09                	je     8008fb <strlcpy+0x32>
  8008f2:	0f b6 19             	movzbl (%ecx),%ebx
  8008f5:	84 db                	test   %bl,%bl
  8008f7:	75 ec                	jne    8008e5 <strlcpy+0x1c>
  8008f9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008fb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008fe:	29 f0                	sub    %esi,%eax
}
  800900:	5b                   	pop    %ebx
  800901:	5e                   	pop    %esi
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80090a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80090d:	eb 06                	jmp    800915 <strcmp+0x11>
		p++, q++;
  80090f:	83 c1 01             	add    $0x1,%ecx
  800912:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800915:	0f b6 01             	movzbl (%ecx),%eax
  800918:	84 c0                	test   %al,%al
  80091a:	74 04                	je     800920 <strcmp+0x1c>
  80091c:	3a 02                	cmp    (%edx),%al
  80091e:	74 ef                	je     80090f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800920:	0f b6 c0             	movzbl %al,%eax
  800923:	0f b6 12             	movzbl (%edx),%edx
  800926:	29 d0                	sub    %edx,%eax
}
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	53                   	push   %ebx
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
  800931:	8b 55 0c             	mov    0xc(%ebp),%edx
  800934:	89 c3                	mov    %eax,%ebx
  800936:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800939:	eb 06                	jmp    800941 <strncmp+0x17>
		n--, p++, q++;
  80093b:	83 c0 01             	add    $0x1,%eax
  80093e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800941:	39 d8                	cmp    %ebx,%eax
  800943:	74 15                	je     80095a <strncmp+0x30>
  800945:	0f b6 08             	movzbl (%eax),%ecx
  800948:	84 c9                	test   %cl,%cl
  80094a:	74 04                	je     800950 <strncmp+0x26>
  80094c:	3a 0a                	cmp    (%edx),%cl
  80094e:	74 eb                	je     80093b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800950:	0f b6 00             	movzbl (%eax),%eax
  800953:	0f b6 12             	movzbl (%edx),%edx
  800956:	29 d0                	sub    %edx,%eax
  800958:	eb 05                	jmp    80095f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80095a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80095f:	5b                   	pop    %ebx
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
  800968:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80096c:	eb 07                	jmp    800975 <strchr+0x13>
		if (*s == c)
  80096e:	38 ca                	cmp    %cl,%dl
  800970:	74 0f                	je     800981 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800972:	83 c0 01             	add    $0x1,%eax
  800975:	0f b6 10             	movzbl (%eax),%edx
  800978:	84 d2                	test   %dl,%dl
  80097a:	75 f2                	jne    80096e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80097c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    

00800983 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
  800989:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80098d:	eb 03                	jmp    800992 <strfind+0xf>
  80098f:	83 c0 01             	add    $0x1,%eax
  800992:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800995:	38 ca                	cmp    %cl,%dl
  800997:	74 04                	je     80099d <strfind+0x1a>
  800999:	84 d2                	test   %dl,%dl
  80099b:	75 f2                	jne    80098f <strfind+0xc>
			break;
	return (char *) s;
}
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	57                   	push   %edi
  8009a3:	56                   	push   %esi
  8009a4:	53                   	push   %ebx
  8009a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009ab:	85 c9                	test   %ecx,%ecx
  8009ad:	74 36                	je     8009e5 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009af:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009b5:	75 28                	jne    8009df <memset+0x40>
  8009b7:	f6 c1 03             	test   $0x3,%cl
  8009ba:	75 23                	jne    8009df <memset+0x40>
		c &= 0xFF;
  8009bc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c0:	89 d3                	mov    %edx,%ebx
  8009c2:	c1 e3 08             	shl    $0x8,%ebx
  8009c5:	89 d6                	mov    %edx,%esi
  8009c7:	c1 e6 18             	shl    $0x18,%esi
  8009ca:	89 d0                	mov    %edx,%eax
  8009cc:	c1 e0 10             	shl    $0x10,%eax
  8009cf:	09 f0                	or     %esi,%eax
  8009d1:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009d3:	89 d8                	mov    %ebx,%eax
  8009d5:	09 d0                	or     %edx,%eax
  8009d7:	c1 e9 02             	shr    $0x2,%ecx
  8009da:	fc                   	cld    
  8009db:	f3 ab                	rep stos %eax,%es:(%edi)
  8009dd:	eb 06                	jmp    8009e5 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e2:	fc                   	cld    
  8009e3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009e5:	89 f8                	mov    %edi,%eax
  8009e7:	5b                   	pop    %ebx
  8009e8:	5e                   	pop    %esi
  8009e9:	5f                   	pop    %edi
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	57                   	push   %edi
  8009f0:	56                   	push   %esi
  8009f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009fa:	39 c6                	cmp    %eax,%esi
  8009fc:	73 35                	jae    800a33 <memmove+0x47>
  8009fe:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a01:	39 d0                	cmp    %edx,%eax
  800a03:	73 2e                	jae    800a33 <memmove+0x47>
		s += n;
		d += n;
  800a05:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a08:	89 d6                	mov    %edx,%esi
  800a0a:	09 fe                	or     %edi,%esi
  800a0c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a12:	75 13                	jne    800a27 <memmove+0x3b>
  800a14:	f6 c1 03             	test   $0x3,%cl
  800a17:	75 0e                	jne    800a27 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a19:	83 ef 04             	sub    $0x4,%edi
  800a1c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a1f:	c1 e9 02             	shr    $0x2,%ecx
  800a22:	fd                   	std    
  800a23:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a25:	eb 09                	jmp    800a30 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a27:	83 ef 01             	sub    $0x1,%edi
  800a2a:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a2d:	fd                   	std    
  800a2e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a30:	fc                   	cld    
  800a31:	eb 1d                	jmp    800a50 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a33:	89 f2                	mov    %esi,%edx
  800a35:	09 c2                	or     %eax,%edx
  800a37:	f6 c2 03             	test   $0x3,%dl
  800a3a:	75 0f                	jne    800a4b <memmove+0x5f>
  800a3c:	f6 c1 03             	test   $0x3,%cl
  800a3f:	75 0a                	jne    800a4b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a41:	c1 e9 02             	shr    $0x2,%ecx
  800a44:	89 c7                	mov    %eax,%edi
  800a46:	fc                   	cld    
  800a47:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a49:	eb 05                	jmp    800a50 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a4b:	89 c7                	mov    %eax,%edi
  800a4d:	fc                   	cld    
  800a4e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a50:	5e                   	pop    %esi
  800a51:	5f                   	pop    %edi
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a57:	ff 75 10             	pushl  0x10(%ebp)
  800a5a:	ff 75 0c             	pushl  0xc(%ebp)
  800a5d:	ff 75 08             	pushl  0x8(%ebp)
  800a60:	e8 87 ff ff ff       	call   8009ec <memmove>
}
  800a65:	c9                   	leave  
  800a66:	c3                   	ret    

00800a67 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	56                   	push   %esi
  800a6b:	53                   	push   %ebx
  800a6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a72:	89 c6                	mov    %eax,%esi
  800a74:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a77:	eb 1a                	jmp    800a93 <memcmp+0x2c>
		if (*s1 != *s2)
  800a79:	0f b6 08             	movzbl (%eax),%ecx
  800a7c:	0f b6 1a             	movzbl (%edx),%ebx
  800a7f:	38 d9                	cmp    %bl,%cl
  800a81:	74 0a                	je     800a8d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a83:	0f b6 c1             	movzbl %cl,%eax
  800a86:	0f b6 db             	movzbl %bl,%ebx
  800a89:	29 d8                	sub    %ebx,%eax
  800a8b:	eb 0f                	jmp    800a9c <memcmp+0x35>
		s1++, s2++;
  800a8d:	83 c0 01             	add    $0x1,%eax
  800a90:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a93:	39 f0                	cmp    %esi,%eax
  800a95:	75 e2                	jne    800a79 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a97:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	53                   	push   %ebx
  800aa4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800aa7:	89 c1                	mov    %eax,%ecx
  800aa9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800aac:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ab0:	eb 0a                	jmp    800abc <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ab2:	0f b6 10             	movzbl (%eax),%edx
  800ab5:	39 da                	cmp    %ebx,%edx
  800ab7:	74 07                	je     800ac0 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ab9:	83 c0 01             	add    $0x1,%eax
  800abc:	39 c8                	cmp    %ecx,%eax
  800abe:	72 f2                	jb     800ab2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ac0:	5b                   	pop    %ebx
  800ac1:	5d                   	pop    %ebp
  800ac2:	c3                   	ret    

00800ac3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	57                   	push   %edi
  800ac7:	56                   	push   %esi
  800ac8:	53                   	push   %ebx
  800ac9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800acc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800acf:	eb 03                	jmp    800ad4 <strtol+0x11>
		s++;
  800ad1:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad4:	0f b6 01             	movzbl (%ecx),%eax
  800ad7:	3c 20                	cmp    $0x20,%al
  800ad9:	74 f6                	je     800ad1 <strtol+0xe>
  800adb:	3c 09                	cmp    $0x9,%al
  800add:	74 f2                	je     800ad1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800adf:	3c 2b                	cmp    $0x2b,%al
  800ae1:	75 0a                	jne    800aed <strtol+0x2a>
		s++;
  800ae3:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ae6:	bf 00 00 00 00       	mov    $0x0,%edi
  800aeb:	eb 11                	jmp    800afe <strtol+0x3b>
  800aed:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800af2:	3c 2d                	cmp    $0x2d,%al
  800af4:	75 08                	jne    800afe <strtol+0x3b>
		s++, neg = 1;
  800af6:	83 c1 01             	add    $0x1,%ecx
  800af9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800afe:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b04:	75 15                	jne    800b1b <strtol+0x58>
  800b06:	80 39 30             	cmpb   $0x30,(%ecx)
  800b09:	75 10                	jne    800b1b <strtol+0x58>
  800b0b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b0f:	75 7c                	jne    800b8d <strtol+0xca>
		s += 2, base = 16;
  800b11:	83 c1 02             	add    $0x2,%ecx
  800b14:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b19:	eb 16                	jmp    800b31 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b1b:	85 db                	test   %ebx,%ebx
  800b1d:	75 12                	jne    800b31 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b1f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b24:	80 39 30             	cmpb   $0x30,(%ecx)
  800b27:	75 08                	jne    800b31 <strtol+0x6e>
		s++, base = 8;
  800b29:	83 c1 01             	add    $0x1,%ecx
  800b2c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b31:	b8 00 00 00 00       	mov    $0x0,%eax
  800b36:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b39:	0f b6 11             	movzbl (%ecx),%edx
  800b3c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b3f:	89 f3                	mov    %esi,%ebx
  800b41:	80 fb 09             	cmp    $0x9,%bl
  800b44:	77 08                	ja     800b4e <strtol+0x8b>
			dig = *s - '0';
  800b46:	0f be d2             	movsbl %dl,%edx
  800b49:	83 ea 30             	sub    $0x30,%edx
  800b4c:	eb 22                	jmp    800b70 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b4e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b51:	89 f3                	mov    %esi,%ebx
  800b53:	80 fb 19             	cmp    $0x19,%bl
  800b56:	77 08                	ja     800b60 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b58:	0f be d2             	movsbl %dl,%edx
  800b5b:	83 ea 57             	sub    $0x57,%edx
  800b5e:	eb 10                	jmp    800b70 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b60:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b63:	89 f3                	mov    %esi,%ebx
  800b65:	80 fb 19             	cmp    $0x19,%bl
  800b68:	77 16                	ja     800b80 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b6a:	0f be d2             	movsbl %dl,%edx
  800b6d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b70:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b73:	7d 0b                	jge    800b80 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b75:	83 c1 01             	add    $0x1,%ecx
  800b78:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b7c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b7e:	eb b9                	jmp    800b39 <strtol+0x76>

	if (endptr)
  800b80:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b84:	74 0d                	je     800b93 <strtol+0xd0>
		*endptr = (char *) s;
  800b86:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b89:	89 0e                	mov    %ecx,(%esi)
  800b8b:	eb 06                	jmp    800b93 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b8d:	85 db                	test   %ebx,%ebx
  800b8f:	74 98                	je     800b29 <strtol+0x66>
  800b91:	eb 9e                	jmp    800b31 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b93:	89 c2                	mov    %eax,%edx
  800b95:	f7 da                	neg    %edx
  800b97:	85 ff                	test   %edi,%edi
  800b99:	0f 45 c2             	cmovne %edx,%eax
}
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	57                   	push   %edi
  800ba5:	56                   	push   %esi
  800ba6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800baf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb2:	89 c3                	mov    %eax,%ebx
  800bb4:	89 c7                	mov    %eax,%edi
  800bb6:	89 c6                	mov    %eax,%esi
  800bb8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bba:	5b                   	pop    %ebx
  800bbb:	5e                   	pop    %esi
  800bbc:	5f                   	pop    %edi
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <sys_cgetc>:

int
sys_cgetc(void)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	57                   	push   %edi
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bca:	b8 01 00 00 00       	mov    $0x1,%eax
  800bcf:	89 d1                	mov    %edx,%ecx
  800bd1:	89 d3                	mov    %edx,%ebx
  800bd3:	89 d7                	mov    %edx,%edi
  800bd5:	89 d6                	mov    %edx,%esi
  800bd7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bec:	b8 03 00 00 00       	mov    $0x3,%eax
  800bf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf4:	89 cb                	mov    %ecx,%ebx
  800bf6:	89 cf                	mov    %ecx,%edi
  800bf8:	89 ce                	mov    %ecx,%esi
  800bfa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfc:	85 c0                	test   %eax,%eax
  800bfe:	7e 17                	jle    800c17 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c00:	83 ec 0c             	sub    $0xc,%esp
  800c03:	50                   	push   %eax
  800c04:	6a 03                	push   $0x3
  800c06:	68 ff 2c 80 00       	push   $0x802cff
  800c0b:	6a 23                	push   $0x23
  800c0d:	68 1c 2d 80 00       	push   $0x802d1c
  800c12:	e8 e5 f5 ff ff       	call   8001fc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1a:	5b                   	pop    %ebx
  800c1b:	5e                   	pop    %esi
  800c1c:	5f                   	pop    %edi
  800c1d:	5d                   	pop    %ebp
  800c1e:	c3                   	ret    

00800c1f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	57                   	push   %edi
  800c23:	56                   	push   %esi
  800c24:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c25:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2a:	b8 02 00 00 00       	mov    $0x2,%eax
  800c2f:	89 d1                	mov    %edx,%ecx
  800c31:	89 d3                	mov    %edx,%ebx
  800c33:	89 d7                	mov    %edx,%edi
  800c35:	89 d6                	mov    %edx,%esi
  800c37:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    

00800c3e <sys_yield>:

void
sys_yield(void)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c44:	ba 00 00 00 00       	mov    $0x0,%edx
  800c49:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c4e:	89 d1                	mov    %edx,%ecx
  800c50:	89 d3                	mov    %edx,%ebx
  800c52:	89 d7                	mov    %edx,%edi
  800c54:	89 d6                	mov    %edx,%esi
  800c56:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c58:	5b                   	pop    %ebx
  800c59:	5e                   	pop    %esi
  800c5a:	5f                   	pop    %edi
  800c5b:	5d                   	pop    %ebp
  800c5c:	c3                   	ret    

00800c5d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c5d:	55                   	push   %ebp
  800c5e:	89 e5                	mov    %esp,%ebp
  800c60:	57                   	push   %edi
  800c61:	56                   	push   %esi
  800c62:	53                   	push   %ebx
  800c63:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c66:	be 00 00 00 00       	mov    $0x0,%esi
  800c6b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c73:	8b 55 08             	mov    0x8(%ebp),%edx
  800c76:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c79:	89 f7                	mov    %esi,%edi
  800c7b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7d:	85 c0                	test   %eax,%eax
  800c7f:	7e 17                	jle    800c98 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c81:	83 ec 0c             	sub    $0xc,%esp
  800c84:	50                   	push   %eax
  800c85:	6a 04                	push   $0x4
  800c87:	68 ff 2c 80 00       	push   $0x802cff
  800c8c:	6a 23                	push   $0x23
  800c8e:	68 1c 2d 80 00       	push   $0x802d1c
  800c93:	e8 64 f5 ff ff       	call   8001fc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    

00800ca0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	57                   	push   %edi
  800ca4:	56                   	push   %esi
  800ca5:	53                   	push   %ebx
  800ca6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca9:	b8 05 00 00 00       	mov    $0x5,%eax
  800cae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cba:	8b 75 18             	mov    0x18(%ebp),%esi
  800cbd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbf:	85 c0                	test   %eax,%eax
  800cc1:	7e 17                	jle    800cda <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc3:	83 ec 0c             	sub    $0xc,%esp
  800cc6:	50                   	push   %eax
  800cc7:	6a 05                	push   $0x5
  800cc9:	68 ff 2c 80 00       	push   $0x802cff
  800cce:	6a 23                	push   $0x23
  800cd0:	68 1c 2d 80 00       	push   $0x802d1c
  800cd5:	e8 22 f5 ff ff       	call   8001fc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdd:	5b                   	pop    %ebx
  800cde:	5e                   	pop    %esi
  800cdf:	5f                   	pop    %edi
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    

00800ce2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	57                   	push   %edi
  800ce6:	56                   	push   %esi
  800ce7:	53                   	push   %ebx
  800ce8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ceb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf0:	b8 06 00 00 00       	mov    $0x6,%eax
  800cf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	89 df                	mov    %ebx,%edi
  800cfd:	89 de                	mov    %ebx,%esi
  800cff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d01:	85 c0                	test   %eax,%eax
  800d03:	7e 17                	jle    800d1c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d05:	83 ec 0c             	sub    $0xc,%esp
  800d08:	50                   	push   %eax
  800d09:	6a 06                	push   $0x6
  800d0b:	68 ff 2c 80 00       	push   $0x802cff
  800d10:	6a 23                	push   $0x23
  800d12:	68 1c 2d 80 00       	push   $0x802d1c
  800d17:	e8 e0 f4 ff ff       	call   8001fc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	57                   	push   %edi
  800d28:	56                   	push   %esi
  800d29:	53                   	push   %ebx
  800d2a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d32:	b8 08 00 00 00       	mov    $0x8,%eax
  800d37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3d:	89 df                	mov    %ebx,%edi
  800d3f:	89 de                	mov    %ebx,%esi
  800d41:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d43:	85 c0                	test   %eax,%eax
  800d45:	7e 17                	jle    800d5e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d47:	83 ec 0c             	sub    $0xc,%esp
  800d4a:	50                   	push   %eax
  800d4b:	6a 08                	push   $0x8
  800d4d:	68 ff 2c 80 00       	push   $0x802cff
  800d52:	6a 23                	push   $0x23
  800d54:	68 1c 2d 80 00       	push   $0x802d1c
  800d59:	e8 9e f4 ff ff       	call   8001fc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	57                   	push   %edi
  800d6a:	56                   	push   %esi
  800d6b:	53                   	push   %ebx
  800d6c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d74:	b8 09 00 00 00       	mov    $0x9,%eax
  800d79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7f:	89 df                	mov    %ebx,%edi
  800d81:	89 de                	mov    %ebx,%esi
  800d83:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d85:	85 c0                	test   %eax,%eax
  800d87:	7e 17                	jle    800da0 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d89:	83 ec 0c             	sub    $0xc,%esp
  800d8c:	50                   	push   %eax
  800d8d:	6a 09                	push   $0x9
  800d8f:	68 ff 2c 80 00       	push   $0x802cff
  800d94:	6a 23                	push   $0x23
  800d96:	68 1c 2d 80 00       	push   $0x802d1c
  800d9b:	e8 5c f4 ff ff       	call   8001fc <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800da0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da3:	5b                   	pop    %ebx
  800da4:	5e                   	pop    %esi
  800da5:	5f                   	pop    %edi
  800da6:	5d                   	pop    %ebp
  800da7:	c3                   	ret    

00800da8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	57                   	push   %edi
  800dac:	56                   	push   %esi
  800dad:	53                   	push   %ebx
  800dae:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc1:	89 df                	mov    %ebx,%edi
  800dc3:	89 de                	mov    %ebx,%esi
  800dc5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc7:	85 c0                	test   %eax,%eax
  800dc9:	7e 17                	jle    800de2 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcb:	83 ec 0c             	sub    $0xc,%esp
  800dce:	50                   	push   %eax
  800dcf:	6a 0a                	push   $0xa
  800dd1:	68 ff 2c 80 00       	push   $0x802cff
  800dd6:	6a 23                	push   $0x23
  800dd8:	68 1c 2d 80 00       	push   $0x802d1c
  800ddd:	e8 1a f4 ff ff       	call   8001fc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800de2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    

00800dea <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	57                   	push   %edi
  800dee:	56                   	push   %esi
  800def:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df0:	be 00 00 00 00       	mov    $0x0,%esi
  800df5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800e00:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e03:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e06:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e08:	5b                   	pop    %ebx
  800e09:	5e                   	pop    %esi
  800e0a:	5f                   	pop    %edi
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    

00800e0d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	57                   	push   %edi
  800e11:	56                   	push   %esi
  800e12:	53                   	push   %ebx
  800e13:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e16:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e1b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e20:	8b 55 08             	mov    0x8(%ebp),%edx
  800e23:	89 cb                	mov    %ecx,%ebx
  800e25:	89 cf                	mov    %ecx,%edi
  800e27:	89 ce                	mov    %ecx,%esi
  800e29:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e2b:	85 c0                	test   %eax,%eax
  800e2d:	7e 17                	jle    800e46 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2f:	83 ec 0c             	sub    $0xc,%esp
  800e32:	50                   	push   %eax
  800e33:	6a 0d                	push   $0xd
  800e35:	68 ff 2c 80 00       	push   $0x802cff
  800e3a:	6a 23                	push   $0x23
  800e3c:	68 1c 2d 80 00       	push   $0x802d1c
  800e41:	e8 b6 f3 ff ff       	call   8001fc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e49:	5b                   	pop    %ebx
  800e4a:	5e                   	pop    %esi
  800e4b:	5f                   	pop    %edi
  800e4c:	5d                   	pop    %ebp
  800e4d:	c3                   	ret    

00800e4e <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e54:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e59:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e61:	89 cb                	mov    %ecx,%ebx
  800e63:	89 cf                	mov    %ecx,%edi
  800e65:	89 ce                	mov    %ecx,%esi
  800e67:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800e69:	5b                   	pop    %ebx
  800e6a:	5e                   	pop    %esi
  800e6b:	5f                   	pop    %edi
  800e6c:	5d                   	pop    %ebp
  800e6d:	c3                   	ret    

00800e6e <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
  800e71:	57                   	push   %edi
  800e72:	56                   	push   %esi
  800e73:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e74:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e79:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e81:	89 cb                	mov    %ecx,%ebx
  800e83:	89 cf                	mov    %ecx,%edi
  800e85:	89 ce                	mov    %ecx,%esi
  800e87:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800e89:	5b                   	pop    %ebx
  800e8a:	5e                   	pop    %esi
  800e8b:	5f                   	pop    %edi
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    

00800e8e <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	53                   	push   %ebx
  800e92:	83 ec 04             	sub    $0x4,%esp
  800e95:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e98:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800e9a:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e9e:	74 11                	je     800eb1 <pgfault+0x23>
  800ea0:	89 d8                	mov    %ebx,%eax
  800ea2:	c1 e8 0c             	shr    $0xc,%eax
  800ea5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eac:	f6 c4 08             	test   $0x8,%ah
  800eaf:	75 14                	jne    800ec5 <pgfault+0x37>
		panic("faulting access");
  800eb1:	83 ec 04             	sub    $0x4,%esp
  800eb4:	68 2a 2d 80 00       	push   $0x802d2a
  800eb9:	6a 1e                	push   $0x1e
  800ebb:	68 3a 2d 80 00       	push   $0x802d3a
  800ec0:	e8 37 f3 ff ff       	call   8001fc <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800ec5:	83 ec 04             	sub    $0x4,%esp
  800ec8:	6a 07                	push   $0x7
  800eca:	68 00 f0 7f 00       	push   $0x7ff000
  800ecf:	6a 00                	push   $0x0
  800ed1:	e8 87 fd ff ff       	call   800c5d <sys_page_alloc>
	if (r < 0) {
  800ed6:	83 c4 10             	add    $0x10,%esp
  800ed9:	85 c0                	test   %eax,%eax
  800edb:	79 12                	jns    800eef <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800edd:	50                   	push   %eax
  800ede:	68 45 2d 80 00       	push   $0x802d45
  800ee3:	6a 2c                	push   $0x2c
  800ee5:	68 3a 2d 80 00       	push   $0x802d3a
  800eea:	e8 0d f3 ff ff       	call   8001fc <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800eef:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800ef5:	83 ec 04             	sub    $0x4,%esp
  800ef8:	68 00 10 00 00       	push   $0x1000
  800efd:	53                   	push   %ebx
  800efe:	68 00 f0 7f 00       	push   $0x7ff000
  800f03:	e8 4c fb ff ff       	call   800a54 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800f08:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f0f:	53                   	push   %ebx
  800f10:	6a 00                	push   $0x0
  800f12:	68 00 f0 7f 00       	push   $0x7ff000
  800f17:	6a 00                	push   $0x0
  800f19:	e8 82 fd ff ff       	call   800ca0 <sys_page_map>
	if (r < 0) {
  800f1e:	83 c4 20             	add    $0x20,%esp
  800f21:	85 c0                	test   %eax,%eax
  800f23:	79 12                	jns    800f37 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800f25:	50                   	push   %eax
  800f26:	68 45 2d 80 00       	push   $0x802d45
  800f2b:	6a 33                	push   $0x33
  800f2d:	68 3a 2d 80 00       	push   $0x802d3a
  800f32:	e8 c5 f2 ff ff       	call   8001fc <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800f37:	83 ec 08             	sub    $0x8,%esp
  800f3a:	68 00 f0 7f 00       	push   $0x7ff000
  800f3f:	6a 00                	push   $0x0
  800f41:	e8 9c fd ff ff       	call   800ce2 <sys_page_unmap>
	if (r < 0) {
  800f46:	83 c4 10             	add    $0x10,%esp
  800f49:	85 c0                	test   %eax,%eax
  800f4b:	79 12                	jns    800f5f <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800f4d:	50                   	push   %eax
  800f4e:	68 45 2d 80 00       	push   $0x802d45
  800f53:	6a 37                	push   $0x37
  800f55:	68 3a 2d 80 00       	push   $0x802d3a
  800f5a:	e8 9d f2 ff ff       	call   8001fc <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800f5f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f62:	c9                   	leave  
  800f63:	c3                   	ret    

00800f64 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	57                   	push   %edi
  800f68:	56                   	push   %esi
  800f69:	53                   	push   %ebx
  800f6a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800f6d:	68 8e 0e 80 00       	push   $0x800e8e
  800f72:	e8 26 15 00 00       	call   80249d <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f77:	b8 07 00 00 00       	mov    $0x7,%eax
  800f7c:	cd 30                	int    $0x30
  800f7e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800f81:	83 c4 10             	add    $0x10,%esp
  800f84:	85 c0                	test   %eax,%eax
  800f86:	79 17                	jns    800f9f <fork+0x3b>
		panic("fork fault %e");
  800f88:	83 ec 04             	sub    $0x4,%esp
  800f8b:	68 5e 2d 80 00       	push   $0x802d5e
  800f90:	68 84 00 00 00       	push   $0x84
  800f95:	68 3a 2d 80 00       	push   $0x802d3a
  800f9a:	e8 5d f2 ff ff       	call   8001fc <_panic>
  800f9f:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800fa1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fa5:	75 25                	jne    800fcc <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fa7:	e8 73 fc ff ff       	call   800c1f <sys_getenvid>
  800fac:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fb1:	89 c2                	mov    %eax,%edx
  800fb3:	c1 e2 07             	shl    $0x7,%edx
  800fb6:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800fbd:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800fc2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc7:	e9 61 01 00 00       	jmp    80112d <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800fcc:	83 ec 04             	sub    $0x4,%esp
  800fcf:	6a 07                	push   $0x7
  800fd1:	68 00 f0 bf ee       	push   $0xeebff000
  800fd6:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fd9:	e8 7f fc ff ff       	call   800c5d <sys_page_alloc>
  800fde:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fe1:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fe6:	89 d8                	mov    %ebx,%eax
  800fe8:	c1 e8 16             	shr    $0x16,%eax
  800feb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ff2:	a8 01                	test   $0x1,%al
  800ff4:	0f 84 fc 00 00 00    	je     8010f6 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800ffa:	89 d8                	mov    %ebx,%eax
  800ffc:	c1 e8 0c             	shr    $0xc,%eax
  800fff:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801006:	f6 c2 01             	test   $0x1,%dl
  801009:	0f 84 e7 00 00 00    	je     8010f6 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80100f:	89 c6                	mov    %eax,%esi
  801011:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  801014:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80101b:	f6 c6 04             	test   $0x4,%dh
  80101e:	74 39                	je     801059 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  801020:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801027:	83 ec 0c             	sub    $0xc,%esp
  80102a:	25 07 0e 00 00       	and    $0xe07,%eax
  80102f:	50                   	push   %eax
  801030:	56                   	push   %esi
  801031:	57                   	push   %edi
  801032:	56                   	push   %esi
  801033:	6a 00                	push   $0x0
  801035:	e8 66 fc ff ff       	call   800ca0 <sys_page_map>
		if (r < 0) {
  80103a:	83 c4 20             	add    $0x20,%esp
  80103d:	85 c0                	test   %eax,%eax
  80103f:	0f 89 b1 00 00 00    	jns    8010f6 <fork+0x192>
		    	panic("sys page map fault %e");
  801045:	83 ec 04             	sub    $0x4,%esp
  801048:	68 6c 2d 80 00       	push   $0x802d6c
  80104d:	6a 54                	push   $0x54
  80104f:	68 3a 2d 80 00       	push   $0x802d3a
  801054:	e8 a3 f1 ff ff       	call   8001fc <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801059:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801060:	f6 c2 02             	test   $0x2,%dl
  801063:	75 0c                	jne    801071 <fork+0x10d>
  801065:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80106c:	f6 c4 08             	test   $0x8,%ah
  80106f:	74 5b                	je     8010cc <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  801071:	83 ec 0c             	sub    $0xc,%esp
  801074:	68 05 08 00 00       	push   $0x805
  801079:	56                   	push   %esi
  80107a:	57                   	push   %edi
  80107b:	56                   	push   %esi
  80107c:	6a 00                	push   $0x0
  80107e:	e8 1d fc ff ff       	call   800ca0 <sys_page_map>
		if (r < 0) {
  801083:	83 c4 20             	add    $0x20,%esp
  801086:	85 c0                	test   %eax,%eax
  801088:	79 14                	jns    80109e <fork+0x13a>
		    	panic("sys page map fault %e");
  80108a:	83 ec 04             	sub    $0x4,%esp
  80108d:	68 6c 2d 80 00       	push   $0x802d6c
  801092:	6a 5b                	push   $0x5b
  801094:	68 3a 2d 80 00       	push   $0x802d3a
  801099:	e8 5e f1 ff ff       	call   8001fc <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  80109e:	83 ec 0c             	sub    $0xc,%esp
  8010a1:	68 05 08 00 00       	push   $0x805
  8010a6:	56                   	push   %esi
  8010a7:	6a 00                	push   $0x0
  8010a9:	56                   	push   %esi
  8010aa:	6a 00                	push   $0x0
  8010ac:	e8 ef fb ff ff       	call   800ca0 <sys_page_map>
		if (r < 0) {
  8010b1:	83 c4 20             	add    $0x20,%esp
  8010b4:	85 c0                	test   %eax,%eax
  8010b6:	79 3e                	jns    8010f6 <fork+0x192>
		    	panic("sys page map fault %e");
  8010b8:	83 ec 04             	sub    $0x4,%esp
  8010bb:	68 6c 2d 80 00       	push   $0x802d6c
  8010c0:	6a 5f                	push   $0x5f
  8010c2:	68 3a 2d 80 00       	push   $0x802d3a
  8010c7:	e8 30 f1 ff ff       	call   8001fc <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8010cc:	83 ec 0c             	sub    $0xc,%esp
  8010cf:	6a 05                	push   $0x5
  8010d1:	56                   	push   %esi
  8010d2:	57                   	push   %edi
  8010d3:	56                   	push   %esi
  8010d4:	6a 00                	push   $0x0
  8010d6:	e8 c5 fb ff ff       	call   800ca0 <sys_page_map>
		if (r < 0) {
  8010db:	83 c4 20             	add    $0x20,%esp
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	79 14                	jns    8010f6 <fork+0x192>
		    	panic("sys page map fault %e");
  8010e2:	83 ec 04             	sub    $0x4,%esp
  8010e5:	68 6c 2d 80 00       	push   $0x802d6c
  8010ea:	6a 64                	push   $0x64
  8010ec:	68 3a 2d 80 00       	push   $0x802d3a
  8010f1:	e8 06 f1 ff ff       	call   8001fc <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8010f6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010fc:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801102:	0f 85 de fe ff ff    	jne    800fe6 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801108:	a1 04 40 80 00       	mov    0x804004,%eax
  80110d:	8b 40 70             	mov    0x70(%eax),%eax
  801110:	83 ec 08             	sub    $0x8,%esp
  801113:	50                   	push   %eax
  801114:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801117:	57                   	push   %edi
  801118:	e8 8b fc ff ff       	call   800da8 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80111d:	83 c4 08             	add    $0x8,%esp
  801120:	6a 02                	push   $0x2
  801122:	57                   	push   %edi
  801123:	e8 fc fb ff ff       	call   800d24 <sys_env_set_status>
	
	return envid;
  801128:	83 c4 10             	add    $0x10,%esp
  80112b:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80112d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801130:	5b                   	pop    %ebx
  801131:	5e                   	pop    %esi
  801132:	5f                   	pop    %edi
  801133:	5d                   	pop    %ebp
  801134:	c3                   	ret    

00801135 <sfork>:

envid_t
sfork(void)
{
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801138:	b8 00 00 00 00       	mov    $0x0,%eax
  80113d:	5d                   	pop    %ebp
  80113e:	c3                   	ret    

0080113f <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80113f:	55                   	push   %ebp
  801140:	89 e5                	mov    %esp,%ebp
  801142:	56                   	push   %esi
  801143:	53                   	push   %ebx
  801144:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801147:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  80114d:	83 ec 08             	sub    $0x8,%esp
  801150:	53                   	push   %ebx
  801151:	68 84 2d 80 00       	push   $0x802d84
  801156:	e8 7a f1 ff ff       	call   8002d5 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80115b:	c7 04 24 c2 01 80 00 	movl   $0x8001c2,(%esp)
  801162:	e8 e7 fc ff ff       	call   800e4e <sys_thread_create>
  801167:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801169:	83 c4 08             	add    $0x8,%esp
  80116c:	53                   	push   %ebx
  80116d:	68 84 2d 80 00       	push   $0x802d84
  801172:	e8 5e f1 ff ff       	call   8002d5 <cprintf>
	return id;
	//return 0;
}
  801177:	89 f0                	mov    %esi,%eax
  801179:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80117c:	5b                   	pop    %ebx
  80117d:	5e                   	pop    %esi
  80117e:	5d                   	pop    %ebp
  80117f:	c3                   	ret    

00801180 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801183:	8b 45 08             	mov    0x8(%ebp),%eax
  801186:	05 00 00 00 30       	add    $0x30000000,%eax
  80118b:	c1 e8 0c             	shr    $0xc,%eax
}
  80118e:	5d                   	pop    %ebp
  80118f:	c3                   	ret    

00801190 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801193:	8b 45 08             	mov    0x8(%ebp),%eax
  801196:	05 00 00 00 30       	add    $0x30000000,%eax
  80119b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011a0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011a5:	5d                   	pop    %ebp
  8011a6:	c3                   	ret    

008011a7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011a7:	55                   	push   %ebp
  8011a8:	89 e5                	mov    %esp,%ebp
  8011aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ad:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011b2:	89 c2                	mov    %eax,%edx
  8011b4:	c1 ea 16             	shr    $0x16,%edx
  8011b7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011be:	f6 c2 01             	test   $0x1,%dl
  8011c1:	74 11                	je     8011d4 <fd_alloc+0x2d>
  8011c3:	89 c2                	mov    %eax,%edx
  8011c5:	c1 ea 0c             	shr    $0xc,%edx
  8011c8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011cf:	f6 c2 01             	test   $0x1,%dl
  8011d2:	75 09                	jne    8011dd <fd_alloc+0x36>
			*fd_store = fd;
  8011d4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011db:	eb 17                	jmp    8011f4 <fd_alloc+0x4d>
  8011dd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011e2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011e7:	75 c9                	jne    8011b2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011e9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011ef:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011f4:	5d                   	pop    %ebp
  8011f5:	c3                   	ret    

008011f6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011f6:	55                   	push   %ebp
  8011f7:	89 e5                	mov    %esp,%ebp
  8011f9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011fc:	83 f8 1f             	cmp    $0x1f,%eax
  8011ff:	77 36                	ja     801237 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801201:	c1 e0 0c             	shl    $0xc,%eax
  801204:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801209:	89 c2                	mov    %eax,%edx
  80120b:	c1 ea 16             	shr    $0x16,%edx
  80120e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801215:	f6 c2 01             	test   $0x1,%dl
  801218:	74 24                	je     80123e <fd_lookup+0x48>
  80121a:	89 c2                	mov    %eax,%edx
  80121c:	c1 ea 0c             	shr    $0xc,%edx
  80121f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801226:	f6 c2 01             	test   $0x1,%dl
  801229:	74 1a                	je     801245 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80122b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80122e:	89 02                	mov    %eax,(%edx)
	return 0;
  801230:	b8 00 00 00 00       	mov    $0x0,%eax
  801235:	eb 13                	jmp    80124a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801237:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80123c:	eb 0c                	jmp    80124a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80123e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801243:	eb 05                	jmp    80124a <fd_lookup+0x54>
  801245:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80124a:	5d                   	pop    %ebp
  80124b:	c3                   	ret    

0080124c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80124c:	55                   	push   %ebp
  80124d:	89 e5                	mov    %esp,%ebp
  80124f:	83 ec 08             	sub    $0x8,%esp
  801252:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801255:	ba 24 2e 80 00       	mov    $0x802e24,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80125a:	eb 13                	jmp    80126f <dev_lookup+0x23>
  80125c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80125f:	39 08                	cmp    %ecx,(%eax)
  801261:	75 0c                	jne    80126f <dev_lookup+0x23>
			*dev = devtab[i];
  801263:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801266:	89 01                	mov    %eax,(%ecx)
			return 0;
  801268:	b8 00 00 00 00       	mov    $0x0,%eax
  80126d:	eb 2e                	jmp    80129d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80126f:	8b 02                	mov    (%edx),%eax
  801271:	85 c0                	test   %eax,%eax
  801273:	75 e7                	jne    80125c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801275:	a1 04 40 80 00       	mov    0x804004,%eax
  80127a:	8b 40 54             	mov    0x54(%eax),%eax
  80127d:	83 ec 04             	sub    $0x4,%esp
  801280:	51                   	push   %ecx
  801281:	50                   	push   %eax
  801282:	68 a8 2d 80 00       	push   $0x802da8
  801287:	e8 49 f0 ff ff       	call   8002d5 <cprintf>
	*dev = 0;
  80128c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80128f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801295:	83 c4 10             	add    $0x10,%esp
  801298:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80129d:	c9                   	leave  
  80129e:	c3                   	ret    

0080129f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	56                   	push   %esi
  8012a3:	53                   	push   %ebx
  8012a4:	83 ec 10             	sub    $0x10,%esp
  8012a7:	8b 75 08             	mov    0x8(%ebp),%esi
  8012aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b0:	50                   	push   %eax
  8012b1:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012b7:	c1 e8 0c             	shr    $0xc,%eax
  8012ba:	50                   	push   %eax
  8012bb:	e8 36 ff ff ff       	call   8011f6 <fd_lookup>
  8012c0:	83 c4 08             	add    $0x8,%esp
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	78 05                	js     8012cc <fd_close+0x2d>
	    || fd != fd2)
  8012c7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012ca:	74 0c                	je     8012d8 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012cc:	84 db                	test   %bl,%bl
  8012ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d3:	0f 44 c2             	cmove  %edx,%eax
  8012d6:	eb 41                	jmp    801319 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012d8:	83 ec 08             	sub    $0x8,%esp
  8012db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012de:	50                   	push   %eax
  8012df:	ff 36                	pushl  (%esi)
  8012e1:	e8 66 ff ff ff       	call   80124c <dev_lookup>
  8012e6:	89 c3                	mov    %eax,%ebx
  8012e8:	83 c4 10             	add    $0x10,%esp
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	78 1a                	js     801309 <fd_close+0x6a>
		if (dev->dev_close)
  8012ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f2:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012f5:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	74 0b                	je     801309 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012fe:	83 ec 0c             	sub    $0xc,%esp
  801301:	56                   	push   %esi
  801302:	ff d0                	call   *%eax
  801304:	89 c3                	mov    %eax,%ebx
  801306:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801309:	83 ec 08             	sub    $0x8,%esp
  80130c:	56                   	push   %esi
  80130d:	6a 00                	push   $0x0
  80130f:	e8 ce f9 ff ff       	call   800ce2 <sys_page_unmap>
	return r;
  801314:	83 c4 10             	add    $0x10,%esp
  801317:	89 d8                	mov    %ebx,%eax
}
  801319:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80131c:	5b                   	pop    %ebx
  80131d:	5e                   	pop    %esi
  80131e:	5d                   	pop    %ebp
  80131f:	c3                   	ret    

00801320 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
  801323:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801326:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801329:	50                   	push   %eax
  80132a:	ff 75 08             	pushl  0x8(%ebp)
  80132d:	e8 c4 fe ff ff       	call   8011f6 <fd_lookup>
  801332:	83 c4 08             	add    $0x8,%esp
  801335:	85 c0                	test   %eax,%eax
  801337:	78 10                	js     801349 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801339:	83 ec 08             	sub    $0x8,%esp
  80133c:	6a 01                	push   $0x1
  80133e:	ff 75 f4             	pushl  -0xc(%ebp)
  801341:	e8 59 ff ff ff       	call   80129f <fd_close>
  801346:	83 c4 10             	add    $0x10,%esp
}
  801349:	c9                   	leave  
  80134a:	c3                   	ret    

0080134b <close_all>:

void
close_all(void)
{
  80134b:	55                   	push   %ebp
  80134c:	89 e5                	mov    %esp,%ebp
  80134e:	53                   	push   %ebx
  80134f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801352:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801357:	83 ec 0c             	sub    $0xc,%esp
  80135a:	53                   	push   %ebx
  80135b:	e8 c0 ff ff ff       	call   801320 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801360:	83 c3 01             	add    $0x1,%ebx
  801363:	83 c4 10             	add    $0x10,%esp
  801366:	83 fb 20             	cmp    $0x20,%ebx
  801369:	75 ec                	jne    801357 <close_all+0xc>
		close(i);
}
  80136b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80136e:	c9                   	leave  
  80136f:	c3                   	ret    

00801370 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801370:	55                   	push   %ebp
  801371:	89 e5                	mov    %esp,%ebp
  801373:	57                   	push   %edi
  801374:	56                   	push   %esi
  801375:	53                   	push   %ebx
  801376:	83 ec 2c             	sub    $0x2c,%esp
  801379:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80137c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80137f:	50                   	push   %eax
  801380:	ff 75 08             	pushl  0x8(%ebp)
  801383:	e8 6e fe ff ff       	call   8011f6 <fd_lookup>
  801388:	83 c4 08             	add    $0x8,%esp
  80138b:	85 c0                	test   %eax,%eax
  80138d:	0f 88 c1 00 00 00    	js     801454 <dup+0xe4>
		return r;
	close(newfdnum);
  801393:	83 ec 0c             	sub    $0xc,%esp
  801396:	56                   	push   %esi
  801397:	e8 84 ff ff ff       	call   801320 <close>

	newfd = INDEX2FD(newfdnum);
  80139c:	89 f3                	mov    %esi,%ebx
  80139e:	c1 e3 0c             	shl    $0xc,%ebx
  8013a1:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013a7:	83 c4 04             	add    $0x4,%esp
  8013aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013ad:	e8 de fd ff ff       	call   801190 <fd2data>
  8013b2:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013b4:	89 1c 24             	mov    %ebx,(%esp)
  8013b7:	e8 d4 fd ff ff       	call   801190 <fd2data>
  8013bc:	83 c4 10             	add    $0x10,%esp
  8013bf:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013c2:	89 f8                	mov    %edi,%eax
  8013c4:	c1 e8 16             	shr    $0x16,%eax
  8013c7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013ce:	a8 01                	test   $0x1,%al
  8013d0:	74 37                	je     801409 <dup+0x99>
  8013d2:	89 f8                	mov    %edi,%eax
  8013d4:	c1 e8 0c             	shr    $0xc,%eax
  8013d7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013de:	f6 c2 01             	test   $0x1,%dl
  8013e1:	74 26                	je     801409 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013e3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ea:	83 ec 0c             	sub    $0xc,%esp
  8013ed:	25 07 0e 00 00       	and    $0xe07,%eax
  8013f2:	50                   	push   %eax
  8013f3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013f6:	6a 00                	push   $0x0
  8013f8:	57                   	push   %edi
  8013f9:	6a 00                	push   $0x0
  8013fb:	e8 a0 f8 ff ff       	call   800ca0 <sys_page_map>
  801400:	89 c7                	mov    %eax,%edi
  801402:	83 c4 20             	add    $0x20,%esp
  801405:	85 c0                	test   %eax,%eax
  801407:	78 2e                	js     801437 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801409:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80140c:	89 d0                	mov    %edx,%eax
  80140e:	c1 e8 0c             	shr    $0xc,%eax
  801411:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801418:	83 ec 0c             	sub    $0xc,%esp
  80141b:	25 07 0e 00 00       	and    $0xe07,%eax
  801420:	50                   	push   %eax
  801421:	53                   	push   %ebx
  801422:	6a 00                	push   $0x0
  801424:	52                   	push   %edx
  801425:	6a 00                	push   $0x0
  801427:	e8 74 f8 ff ff       	call   800ca0 <sys_page_map>
  80142c:	89 c7                	mov    %eax,%edi
  80142e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801431:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801433:	85 ff                	test   %edi,%edi
  801435:	79 1d                	jns    801454 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801437:	83 ec 08             	sub    $0x8,%esp
  80143a:	53                   	push   %ebx
  80143b:	6a 00                	push   $0x0
  80143d:	e8 a0 f8 ff ff       	call   800ce2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801442:	83 c4 08             	add    $0x8,%esp
  801445:	ff 75 d4             	pushl  -0x2c(%ebp)
  801448:	6a 00                	push   $0x0
  80144a:	e8 93 f8 ff ff       	call   800ce2 <sys_page_unmap>
	return r;
  80144f:	83 c4 10             	add    $0x10,%esp
  801452:	89 f8                	mov    %edi,%eax
}
  801454:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801457:	5b                   	pop    %ebx
  801458:	5e                   	pop    %esi
  801459:	5f                   	pop    %edi
  80145a:	5d                   	pop    %ebp
  80145b:	c3                   	ret    

0080145c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80145c:	55                   	push   %ebp
  80145d:	89 e5                	mov    %esp,%ebp
  80145f:	53                   	push   %ebx
  801460:	83 ec 14             	sub    $0x14,%esp
  801463:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801466:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801469:	50                   	push   %eax
  80146a:	53                   	push   %ebx
  80146b:	e8 86 fd ff ff       	call   8011f6 <fd_lookup>
  801470:	83 c4 08             	add    $0x8,%esp
  801473:	89 c2                	mov    %eax,%edx
  801475:	85 c0                	test   %eax,%eax
  801477:	78 6d                	js     8014e6 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801479:	83 ec 08             	sub    $0x8,%esp
  80147c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147f:	50                   	push   %eax
  801480:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801483:	ff 30                	pushl  (%eax)
  801485:	e8 c2 fd ff ff       	call   80124c <dev_lookup>
  80148a:	83 c4 10             	add    $0x10,%esp
  80148d:	85 c0                	test   %eax,%eax
  80148f:	78 4c                	js     8014dd <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801491:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801494:	8b 42 08             	mov    0x8(%edx),%eax
  801497:	83 e0 03             	and    $0x3,%eax
  80149a:	83 f8 01             	cmp    $0x1,%eax
  80149d:	75 21                	jne    8014c0 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80149f:	a1 04 40 80 00       	mov    0x804004,%eax
  8014a4:	8b 40 54             	mov    0x54(%eax),%eax
  8014a7:	83 ec 04             	sub    $0x4,%esp
  8014aa:	53                   	push   %ebx
  8014ab:	50                   	push   %eax
  8014ac:	68 e9 2d 80 00       	push   $0x802de9
  8014b1:	e8 1f ee ff ff       	call   8002d5 <cprintf>
		return -E_INVAL;
  8014b6:	83 c4 10             	add    $0x10,%esp
  8014b9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014be:	eb 26                	jmp    8014e6 <read+0x8a>
	}
	if (!dev->dev_read)
  8014c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c3:	8b 40 08             	mov    0x8(%eax),%eax
  8014c6:	85 c0                	test   %eax,%eax
  8014c8:	74 17                	je     8014e1 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8014ca:	83 ec 04             	sub    $0x4,%esp
  8014cd:	ff 75 10             	pushl  0x10(%ebp)
  8014d0:	ff 75 0c             	pushl  0xc(%ebp)
  8014d3:	52                   	push   %edx
  8014d4:	ff d0                	call   *%eax
  8014d6:	89 c2                	mov    %eax,%edx
  8014d8:	83 c4 10             	add    $0x10,%esp
  8014db:	eb 09                	jmp    8014e6 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014dd:	89 c2                	mov    %eax,%edx
  8014df:	eb 05                	jmp    8014e6 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014e1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8014e6:	89 d0                	mov    %edx,%eax
  8014e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014eb:	c9                   	leave  
  8014ec:	c3                   	ret    

008014ed <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014ed:	55                   	push   %ebp
  8014ee:	89 e5                	mov    %esp,%ebp
  8014f0:	57                   	push   %edi
  8014f1:	56                   	push   %esi
  8014f2:	53                   	push   %ebx
  8014f3:	83 ec 0c             	sub    $0xc,%esp
  8014f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014f9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801501:	eb 21                	jmp    801524 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801503:	83 ec 04             	sub    $0x4,%esp
  801506:	89 f0                	mov    %esi,%eax
  801508:	29 d8                	sub    %ebx,%eax
  80150a:	50                   	push   %eax
  80150b:	89 d8                	mov    %ebx,%eax
  80150d:	03 45 0c             	add    0xc(%ebp),%eax
  801510:	50                   	push   %eax
  801511:	57                   	push   %edi
  801512:	e8 45 ff ff ff       	call   80145c <read>
		if (m < 0)
  801517:	83 c4 10             	add    $0x10,%esp
  80151a:	85 c0                	test   %eax,%eax
  80151c:	78 10                	js     80152e <readn+0x41>
			return m;
		if (m == 0)
  80151e:	85 c0                	test   %eax,%eax
  801520:	74 0a                	je     80152c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801522:	01 c3                	add    %eax,%ebx
  801524:	39 f3                	cmp    %esi,%ebx
  801526:	72 db                	jb     801503 <readn+0x16>
  801528:	89 d8                	mov    %ebx,%eax
  80152a:	eb 02                	jmp    80152e <readn+0x41>
  80152c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80152e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801531:	5b                   	pop    %ebx
  801532:	5e                   	pop    %esi
  801533:	5f                   	pop    %edi
  801534:	5d                   	pop    %ebp
  801535:	c3                   	ret    

00801536 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801536:	55                   	push   %ebp
  801537:	89 e5                	mov    %esp,%ebp
  801539:	53                   	push   %ebx
  80153a:	83 ec 14             	sub    $0x14,%esp
  80153d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801540:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801543:	50                   	push   %eax
  801544:	53                   	push   %ebx
  801545:	e8 ac fc ff ff       	call   8011f6 <fd_lookup>
  80154a:	83 c4 08             	add    $0x8,%esp
  80154d:	89 c2                	mov    %eax,%edx
  80154f:	85 c0                	test   %eax,%eax
  801551:	78 68                	js     8015bb <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801553:	83 ec 08             	sub    $0x8,%esp
  801556:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801559:	50                   	push   %eax
  80155a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155d:	ff 30                	pushl  (%eax)
  80155f:	e8 e8 fc ff ff       	call   80124c <dev_lookup>
  801564:	83 c4 10             	add    $0x10,%esp
  801567:	85 c0                	test   %eax,%eax
  801569:	78 47                	js     8015b2 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80156b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801572:	75 21                	jne    801595 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801574:	a1 04 40 80 00       	mov    0x804004,%eax
  801579:	8b 40 54             	mov    0x54(%eax),%eax
  80157c:	83 ec 04             	sub    $0x4,%esp
  80157f:	53                   	push   %ebx
  801580:	50                   	push   %eax
  801581:	68 05 2e 80 00       	push   $0x802e05
  801586:	e8 4a ed ff ff       	call   8002d5 <cprintf>
		return -E_INVAL;
  80158b:	83 c4 10             	add    $0x10,%esp
  80158e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801593:	eb 26                	jmp    8015bb <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801595:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801598:	8b 52 0c             	mov    0xc(%edx),%edx
  80159b:	85 d2                	test   %edx,%edx
  80159d:	74 17                	je     8015b6 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80159f:	83 ec 04             	sub    $0x4,%esp
  8015a2:	ff 75 10             	pushl  0x10(%ebp)
  8015a5:	ff 75 0c             	pushl  0xc(%ebp)
  8015a8:	50                   	push   %eax
  8015a9:	ff d2                	call   *%edx
  8015ab:	89 c2                	mov    %eax,%edx
  8015ad:	83 c4 10             	add    $0x10,%esp
  8015b0:	eb 09                	jmp    8015bb <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b2:	89 c2                	mov    %eax,%edx
  8015b4:	eb 05                	jmp    8015bb <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015b6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015bb:	89 d0                	mov    %edx,%eax
  8015bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c0:	c9                   	leave  
  8015c1:	c3                   	ret    

008015c2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015c2:	55                   	push   %ebp
  8015c3:	89 e5                	mov    %esp,%ebp
  8015c5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015c8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015cb:	50                   	push   %eax
  8015cc:	ff 75 08             	pushl  0x8(%ebp)
  8015cf:	e8 22 fc ff ff       	call   8011f6 <fd_lookup>
  8015d4:	83 c4 08             	add    $0x8,%esp
  8015d7:	85 c0                	test   %eax,%eax
  8015d9:	78 0e                	js     8015e9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015db:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015e1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015e9:	c9                   	leave  
  8015ea:	c3                   	ret    

008015eb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015eb:	55                   	push   %ebp
  8015ec:	89 e5                	mov    %esp,%ebp
  8015ee:	53                   	push   %ebx
  8015ef:	83 ec 14             	sub    $0x14,%esp
  8015f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f8:	50                   	push   %eax
  8015f9:	53                   	push   %ebx
  8015fa:	e8 f7 fb ff ff       	call   8011f6 <fd_lookup>
  8015ff:	83 c4 08             	add    $0x8,%esp
  801602:	89 c2                	mov    %eax,%edx
  801604:	85 c0                	test   %eax,%eax
  801606:	78 65                	js     80166d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801608:	83 ec 08             	sub    $0x8,%esp
  80160b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160e:	50                   	push   %eax
  80160f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801612:	ff 30                	pushl  (%eax)
  801614:	e8 33 fc ff ff       	call   80124c <dev_lookup>
  801619:	83 c4 10             	add    $0x10,%esp
  80161c:	85 c0                	test   %eax,%eax
  80161e:	78 44                	js     801664 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801620:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801623:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801627:	75 21                	jne    80164a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801629:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80162e:	8b 40 54             	mov    0x54(%eax),%eax
  801631:	83 ec 04             	sub    $0x4,%esp
  801634:	53                   	push   %ebx
  801635:	50                   	push   %eax
  801636:	68 c8 2d 80 00       	push   $0x802dc8
  80163b:	e8 95 ec ff ff       	call   8002d5 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801640:	83 c4 10             	add    $0x10,%esp
  801643:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801648:	eb 23                	jmp    80166d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80164a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80164d:	8b 52 18             	mov    0x18(%edx),%edx
  801650:	85 d2                	test   %edx,%edx
  801652:	74 14                	je     801668 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801654:	83 ec 08             	sub    $0x8,%esp
  801657:	ff 75 0c             	pushl  0xc(%ebp)
  80165a:	50                   	push   %eax
  80165b:	ff d2                	call   *%edx
  80165d:	89 c2                	mov    %eax,%edx
  80165f:	83 c4 10             	add    $0x10,%esp
  801662:	eb 09                	jmp    80166d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801664:	89 c2                	mov    %eax,%edx
  801666:	eb 05                	jmp    80166d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801668:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80166d:	89 d0                	mov    %edx,%eax
  80166f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801672:	c9                   	leave  
  801673:	c3                   	ret    

00801674 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801674:	55                   	push   %ebp
  801675:	89 e5                	mov    %esp,%ebp
  801677:	53                   	push   %ebx
  801678:	83 ec 14             	sub    $0x14,%esp
  80167b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80167e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801681:	50                   	push   %eax
  801682:	ff 75 08             	pushl  0x8(%ebp)
  801685:	e8 6c fb ff ff       	call   8011f6 <fd_lookup>
  80168a:	83 c4 08             	add    $0x8,%esp
  80168d:	89 c2                	mov    %eax,%edx
  80168f:	85 c0                	test   %eax,%eax
  801691:	78 58                	js     8016eb <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801693:	83 ec 08             	sub    $0x8,%esp
  801696:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801699:	50                   	push   %eax
  80169a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169d:	ff 30                	pushl  (%eax)
  80169f:	e8 a8 fb ff ff       	call   80124c <dev_lookup>
  8016a4:	83 c4 10             	add    $0x10,%esp
  8016a7:	85 c0                	test   %eax,%eax
  8016a9:	78 37                	js     8016e2 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ae:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016b2:	74 32                	je     8016e6 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016b4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016b7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016be:	00 00 00 
	stat->st_isdir = 0;
  8016c1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016c8:	00 00 00 
	stat->st_dev = dev;
  8016cb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016d1:	83 ec 08             	sub    $0x8,%esp
  8016d4:	53                   	push   %ebx
  8016d5:	ff 75 f0             	pushl  -0x10(%ebp)
  8016d8:	ff 50 14             	call   *0x14(%eax)
  8016db:	89 c2                	mov    %eax,%edx
  8016dd:	83 c4 10             	add    $0x10,%esp
  8016e0:	eb 09                	jmp    8016eb <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e2:	89 c2                	mov    %eax,%edx
  8016e4:	eb 05                	jmp    8016eb <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016e6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016eb:	89 d0                	mov    %edx,%eax
  8016ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f0:	c9                   	leave  
  8016f1:	c3                   	ret    

008016f2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016f2:	55                   	push   %ebp
  8016f3:	89 e5                	mov    %esp,%ebp
  8016f5:	56                   	push   %esi
  8016f6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016f7:	83 ec 08             	sub    $0x8,%esp
  8016fa:	6a 00                	push   $0x0
  8016fc:	ff 75 08             	pushl  0x8(%ebp)
  8016ff:	e8 e3 01 00 00       	call   8018e7 <open>
  801704:	89 c3                	mov    %eax,%ebx
  801706:	83 c4 10             	add    $0x10,%esp
  801709:	85 c0                	test   %eax,%eax
  80170b:	78 1b                	js     801728 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80170d:	83 ec 08             	sub    $0x8,%esp
  801710:	ff 75 0c             	pushl  0xc(%ebp)
  801713:	50                   	push   %eax
  801714:	e8 5b ff ff ff       	call   801674 <fstat>
  801719:	89 c6                	mov    %eax,%esi
	close(fd);
  80171b:	89 1c 24             	mov    %ebx,(%esp)
  80171e:	e8 fd fb ff ff       	call   801320 <close>
	return r;
  801723:	83 c4 10             	add    $0x10,%esp
  801726:	89 f0                	mov    %esi,%eax
}
  801728:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80172b:	5b                   	pop    %ebx
  80172c:	5e                   	pop    %esi
  80172d:	5d                   	pop    %ebp
  80172e:	c3                   	ret    

0080172f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80172f:	55                   	push   %ebp
  801730:	89 e5                	mov    %esp,%ebp
  801732:	56                   	push   %esi
  801733:	53                   	push   %ebx
  801734:	89 c6                	mov    %eax,%esi
  801736:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801738:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80173f:	75 12                	jne    801753 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801741:	83 ec 0c             	sub    $0xc,%esp
  801744:	6a 01                	push   $0x1
  801746:	e8 bb 0e 00 00       	call   802606 <ipc_find_env>
  80174b:	a3 00 40 80 00       	mov    %eax,0x804000
  801750:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801753:	6a 07                	push   $0x7
  801755:	68 00 50 80 00       	push   $0x805000
  80175a:	56                   	push   %esi
  80175b:	ff 35 00 40 80 00    	pushl  0x804000
  801761:	e8 3e 0e 00 00       	call   8025a4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801766:	83 c4 0c             	add    $0xc,%esp
  801769:	6a 00                	push   $0x0
  80176b:	53                   	push   %ebx
  80176c:	6a 00                	push   $0x0
  80176e:	e8 b9 0d 00 00       	call   80252c <ipc_recv>
}
  801773:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801776:	5b                   	pop    %ebx
  801777:	5e                   	pop    %esi
  801778:	5d                   	pop    %ebp
  801779:	c3                   	ret    

0080177a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80177a:	55                   	push   %ebp
  80177b:	89 e5                	mov    %esp,%ebp
  80177d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801780:	8b 45 08             	mov    0x8(%ebp),%eax
  801783:	8b 40 0c             	mov    0xc(%eax),%eax
  801786:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80178b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80178e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801793:	ba 00 00 00 00       	mov    $0x0,%edx
  801798:	b8 02 00 00 00       	mov    $0x2,%eax
  80179d:	e8 8d ff ff ff       	call   80172f <fsipc>
}
  8017a2:	c9                   	leave  
  8017a3:	c3                   	ret    

008017a4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017a4:	55                   	push   %ebp
  8017a5:	89 e5                	mov    %esp,%ebp
  8017a7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ba:	b8 06 00 00 00       	mov    $0x6,%eax
  8017bf:	e8 6b ff ff ff       	call   80172f <fsipc>
}
  8017c4:	c9                   	leave  
  8017c5:	c3                   	ret    

008017c6 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017c6:	55                   	push   %ebp
  8017c7:	89 e5                	mov    %esp,%ebp
  8017c9:	53                   	push   %ebx
  8017ca:	83 ec 04             	sub    $0x4,%esp
  8017cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d3:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017db:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e0:	b8 05 00 00 00       	mov    $0x5,%eax
  8017e5:	e8 45 ff ff ff       	call   80172f <fsipc>
  8017ea:	85 c0                	test   %eax,%eax
  8017ec:	78 2c                	js     80181a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017ee:	83 ec 08             	sub    $0x8,%esp
  8017f1:	68 00 50 80 00       	push   $0x805000
  8017f6:	53                   	push   %ebx
  8017f7:	e8 5e f0 ff ff       	call   80085a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017fc:	a1 80 50 80 00       	mov    0x805080,%eax
  801801:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801807:	a1 84 50 80 00       	mov    0x805084,%eax
  80180c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801812:	83 c4 10             	add    $0x10,%esp
  801815:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80181a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80181d:	c9                   	leave  
  80181e:	c3                   	ret    

0080181f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80181f:	55                   	push   %ebp
  801820:	89 e5                	mov    %esp,%ebp
  801822:	83 ec 0c             	sub    $0xc,%esp
  801825:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801828:	8b 55 08             	mov    0x8(%ebp),%edx
  80182b:	8b 52 0c             	mov    0xc(%edx),%edx
  80182e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801834:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801839:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80183e:	0f 47 c2             	cmova  %edx,%eax
  801841:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801846:	50                   	push   %eax
  801847:	ff 75 0c             	pushl  0xc(%ebp)
  80184a:	68 08 50 80 00       	push   $0x805008
  80184f:	e8 98 f1 ff ff       	call   8009ec <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801854:	ba 00 00 00 00       	mov    $0x0,%edx
  801859:	b8 04 00 00 00       	mov    $0x4,%eax
  80185e:	e8 cc fe ff ff       	call   80172f <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801863:	c9                   	leave  
  801864:	c3                   	ret    

00801865 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801865:	55                   	push   %ebp
  801866:	89 e5                	mov    %esp,%ebp
  801868:	56                   	push   %esi
  801869:	53                   	push   %ebx
  80186a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80186d:	8b 45 08             	mov    0x8(%ebp),%eax
  801870:	8b 40 0c             	mov    0xc(%eax),%eax
  801873:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801878:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80187e:	ba 00 00 00 00       	mov    $0x0,%edx
  801883:	b8 03 00 00 00       	mov    $0x3,%eax
  801888:	e8 a2 fe ff ff       	call   80172f <fsipc>
  80188d:	89 c3                	mov    %eax,%ebx
  80188f:	85 c0                	test   %eax,%eax
  801891:	78 4b                	js     8018de <devfile_read+0x79>
		return r;
	assert(r <= n);
  801893:	39 c6                	cmp    %eax,%esi
  801895:	73 16                	jae    8018ad <devfile_read+0x48>
  801897:	68 34 2e 80 00       	push   $0x802e34
  80189c:	68 3b 2e 80 00       	push   $0x802e3b
  8018a1:	6a 7c                	push   $0x7c
  8018a3:	68 50 2e 80 00       	push   $0x802e50
  8018a8:	e8 4f e9 ff ff       	call   8001fc <_panic>
	assert(r <= PGSIZE);
  8018ad:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018b2:	7e 16                	jle    8018ca <devfile_read+0x65>
  8018b4:	68 5b 2e 80 00       	push   $0x802e5b
  8018b9:	68 3b 2e 80 00       	push   $0x802e3b
  8018be:	6a 7d                	push   $0x7d
  8018c0:	68 50 2e 80 00       	push   $0x802e50
  8018c5:	e8 32 e9 ff ff       	call   8001fc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018ca:	83 ec 04             	sub    $0x4,%esp
  8018cd:	50                   	push   %eax
  8018ce:	68 00 50 80 00       	push   $0x805000
  8018d3:	ff 75 0c             	pushl  0xc(%ebp)
  8018d6:	e8 11 f1 ff ff       	call   8009ec <memmove>
	return r;
  8018db:	83 c4 10             	add    $0x10,%esp
}
  8018de:	89 d8                	mov    %ebx,%eax
  8018e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e3:	5b                   	pop    %ebx
  8018e4:	5e                   	pop    %esi
  8018e5:	5d                   	pop    %ebp
  8018e6:	c3                   	ret    

008018e7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018e7:	55                   	push   %ebp
  8018e8:	89 e5                	mov    %esp,%ebp
  8018ea:	53                   	push   %ebx
  8018eb:	83 ec 20             	sub    $0x20,%esp
  8018ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018f1:	53                   	push   %ebx
  8018f2:	e8 2a ef ff ff       	call   800821 <strlen>
  8018f7:	83 c4 10             	add    $0x10,%esp
  8018fa:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018ff:	7f 67                	jg     801968 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801901:	83 ec 0c             	sub    $0xc,%esp
  801904:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801907:	50                   	push   %eax
  801908:	e8 9a f8 ff ff       	call   8011a7 <fd_alloc>
  80190d:	83 c4 10             	add    $0x10,%esp
		return r;
  801910:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801912:	85 c0                	test   %eax,%eax
  801914:	78 57                	js     80196d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801916:	83 ec 08             	sub    $0x8,%esp
  801919:	53                   	push   %ebx
  80191a:	68 00 50 80 00       	push   $0x805000
  80191f:	e8 36 ef ff ff       	call   80085a <strcpy>
	fsipcbuf.open.req_omode = mode;
  801924:	8b 45 0c             	mov    0xc(%ebp),%eax
  801927:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80192c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80192f:	b8 01 00 00 00       	mov    $0x1,%eax
  801934:	e8 f6 fd ff ff       	call   80172f <fsipc>
  801939:	89 c3                	mov    %eax,%ebx
  80193b:	83 c4 10             	add    $0x10,%esp
  80193e:	85 c0                	test   %eax,%eax
  801940:	79 14                	jns    801956 <open+0x6f>
		fd_close(fd, 0);
  801942:	83 ec 08             	sub    $0x8,%esp
  801945:	6a 00                	push   $0x0
  801947:	ff 75 f4             	pushl  -0xc(%ebp)
  80194a:	e8 50 f9 ff ff       	call   80129f <fd_close>
		return r;
  80194f:	83 c4 10             	add    $0x10,%esp
  801952:	89 da                	mov    %ebx,%edx
  801954:	eb 17                	jmp    80196d <open+0x86>
	}

	return fd2num(fd);
  801956:	83 ec 0c             	sub    $0xc,%esp
  801959:	ff 75 f4             	pushl  -0xc(%ebp)
  80195c:	e8 1f f8 ff ff       	call   801180 <fd2num>
  801961:	89 c2                	mov    %eax,%edx
  801963:	83 c4 10             	add    $0x10,%esp
  801966:	eb 05                	jmp    80196d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801968:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80196d:	89 d0                	mov    %edx,%eax
  80196f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801972:	c9                   	leave  
  801973:	c3                   	ret    

00801974 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801974:	55                   	push   %ebp
  801975:	89 e5                	mov    %esp,%ebp
  801977:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80197a:	ba 00 00 00 00       	mov    $0x0,%edx
  80197f:	b8 08 00 00 00       	mov    $0x8,%eax
  801984:	e8 a6 fd ff ff       	call   80172f <fsipc>
}
  801989:	c9                   	leave  
  80198a:	c3                   	ret    

0080198b <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80198b:	55                   	push   %ebp
  80198c:	89 e5                	mov    %esp,%ebp
  80198e:	57                   	push   %edi
  80198f:	56                   	push   %esi
  801990:	53                   	push   %ebx
  801991:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801997:	6a 00                	push   $0x0
  801999:	ff 75 08             	pushl  0x8(%ebp)
  80199c:	e8 46 ff ff ff       	call   8018e7 <open>
  8019a1:	89 c7                	mov    %eax,%edi
  8019a3:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8019a9:	83 c4 10             	add    $0x10,%esp
  8019ac:	85 c0                	test   %eax,%eax
  8019ae:	0f 88 89 04 00 00    	js     801e3d <spawn+0x4b2>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8019b4:	83 ec 04             	sub    $0x4,%esp
  8019b7:	68 00 02 00 00       	push   $0x200
  8019bc:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8019c2:	50                   	push   %eax
  8019c3:	57                   	push   %edi
  8019c4:	e8 24 fb ff ff       	call   8014ed <readn>
  8019c9:	83 c4 10             	add    $0x10,%esp
  8019cc:	3d 00 02 00 00       	cmp    $0x200,%eax
  8019d1:	75 0c                	jne    8019df <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8019d3:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8019da:	45 4c 46 
  8019dd:	74 33                	je     801a12 <spawn+0x87>
		close(fd);
  8019df:	83 ec 0c             	sub    $0xc,%esp
  8019e2:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019e8:	e8 33 f9 ff ff       	call   801320 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8019ed:	83 c4 0c             	add    $0xc,%esp
  8019f0:	68 7f 45 4c 46       	push   $0x464c457f
  8019f5:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8019fb:	68 67 2e 80 00       	push   $0x802e67
  801a00:	e8 d0 e8 ff ff       	call   8002d5 <cprintf>
		return -E_NOT_EXEC;
  801a05:	83 c4 10             	add    $0x10,%esp
  801a08:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801a0d:	e9 de 04 00 00       	jmp    801ef0 <spawn+0x565>
  801a12:	b8 07 00 00 00       	mov    $0x7,%eax
  801a17:	cd 30                	int    $0x30
  801a19:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801a1f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801a25:	85 c0                	test   %eax,%eax
  801a27:	0f 88 1b 04 00 00    	js     801e48 <spawn+0x4bd>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801a2d:	25 ff 03 00 00       	and    $0x3ff,%eax
  801a32:	89 c2                	mov    %eax,%edx
  801a34:	c1 e2 07             	shl    $0x7,%edx
  801a37:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801a3d:	8d b4 c2 0c 00 c0 ee 	lea    -0x113ffff4(%edx,%eax,8),%esi
  801a44:	b9 11 00 00 00       	mov    $0x11,%ecx
  801a49:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801a4b:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801a51:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a57:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801a5c:	be 00 00 00 00       	mov    $0x0,%esi
  801a61:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a64:	eb 13                	jmp    801a79 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801a66:	83 ec 0c             	sub    $0xc,%esp
  801a69:	50                   	push   %eax
  801a6a:	e8 b2 ed ff ff       	call   800821 <strlen>
  801a6f:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a73:	83 c3 01             	add    $0x1,%ebx
  801a76:	83 c4 10             	add    $0x10,%esp
  801a79:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801a80:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801a83:	85 c0                	test   %eax,%eax
  801a85:	75 df                	jne    801a66 <spawn+0xdb>
  801a87:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801a8d:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801a93:	bf 00 10 40 00       	mov    $0x401000,%edi
  801a98:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801a9a:	89 fa                	mov    %edi,%edx
  801a9c:	83 e2 fc             	and    $0xfffffffc,%edx
  801a9f:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801aa6:	29 c2                	sub    %eax,%edx
  801aa8:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801aae:	8d 42 f8             	lea    -0x8(%edx),%eax
  801ab1:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801ab6:	0f 86 a2 03 00 00    	jbe    801e5e <spawn+0x4d3>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801abc:	83 ec 04             	sub    $0x4,%esp
  801abf:	6a 07                	push   $0x7
  801ac1:	68 00 00 40 00       	push   $0x400000
  801ac6:	6a 00                	push   $0x0
  801ac8:	e8 90 f1 ff ff       	call   800c5d <sys_page_alloc>
  801acd:	83 c4 10             	add    $0x10,%esp
  801ad0:	85 c0                	test   %eax,%eax
  801ad2:	0f 88 90 03 00 00    	js     801e68 <spawn+0x4dd>
  801ad8:	be 00 00 00 00       	mov    $0x0,%esi
  801add:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801ae3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ae6:	eb 30                	jmp    801b18 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801ae8:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801aee:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801af4:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801af7:	83 ec 08             	sub    $0x8,%esp
  801afa:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801afd:	57                   	push   %edi
  801afe:	e8 57 ed ff ff       	call   80085a <strcpy>
		string_store += strlen(argv[i]) + 1;
  801b03:	83 c4 04             	add    $0x4,%esp
  801b06:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801b09:	e8 13 ed ff ff       	call   800821 <strlen>
  801b0e:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801b12:	83 c6 01             	add    $0x1,%esi
  801b15:	83 c4 10             	add    $0x10,%esp
  801b18:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801b1e:	7f c8                	jg     801ae8 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801b20:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801b26:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801b2c:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801b33:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801b39:	74 19                	je     801b54 <spawn+0x1c9>
  801b3b:	68 f4 2e 80 00       	push   $0x802ef4
  801b40:	68 3b 2e 80 00       	push   $0x802e3b
  801b45:	68 f2 00 00 00       	push   $0xf2
  801b4a:	68 81 2e 80 00       	push   $0x802e81
  801b4f:	e8 a8 e6 ff ff       	call   8001fc <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801b54:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801b5a:	89 f8                	mov    %edi,%eax
  801b5c:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801b61:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801b64:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b6a:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801b6d:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801b73:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801b79:	83 ec 0c             	sub    $0xc,%esp
  801b7c:	6a 07                	push   $0x7
  801b7e:	68 00 d0 bf ee       	push   $0xeebfd000
  801b83:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b89:	68 00 00 40 00       	push   $0x400000
  801b8e:	6a 00                	push   $0x0
  801b90:	e8 0b f1 ff ff       	call   800ca0 <sys_page_map>
  801b95:	89 c3                	mov    %eax,%ebx
  801b97:	83 c4 20             	add    $0x20,%esp
  801b9a:	85 c0                	test   %eax,%eax
  801b9c:	0f 88 3c 03 00 00    	js     801ede <spawn+0x553>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801ba2:	83 ec 08             	sub    $0x8,%esp
  801ba5:	68 00 00 40 00       	push   $0x400000
  801baa:	6a 00                	push   $0x0
  801bac:	e8 31 f1 ff ff       	call   800ce2 <sys_page_unmap>
  801bb1:	89 c3                	mov    %eax,%ebx
  801bb3:	83 c4 10             	add    $0x10,%esp
  801bb6:	85 c0                	test   %eax,%eax
  801bb8:	0f 88 20 03 00 00    	js     801ede <spawn+0x553>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801bbe:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801bc4:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801bcb:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801bd1:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801bd8:	00 00 00 
  801bdb:	e9 88 01 00 00       	jmp    801d68 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801be0:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801be6:	83 38 01             	cmpl   $0x1,(%eax)
  801be9:	0f 85 6b 01 00 00    	jne    801d5a <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801bef:	89 c2                	mov    %eax,%edx
  801bf1:	8b 40 18             	mov    0x18(%eax),%eax
  801bf4:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801bfa:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801bfd:	83 f8 01             	cmp    $0x1,%eax
  801c00:	19 c0                	sbb    %eax,%eax
  801c02:	83 e0 fe             	and    $0xfffffffe,%eax
  801c05:	83 c0 07             	add    $0x7,%eax
  801c08:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801c0e:	89 d0                	mov    %edx,%eax
  801c10:	8b 7a 04             	mov    0x4(%edx),%edi
  801c13:	89 f9                	mov    %edi,%ecx
  801c15:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801c1b:	8b 7a 10             	mov    0x10(%edx),%edi
  801c1e:	8b 52 14             	mov    0x14(%edx),%edx
  801c21:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801c27:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801c2a:	89 f0                	mov    %esi,%eax
  801c2c:	25 ff 0f 00 00       	and    $0xfff,%eax
  801c31:	74 14                	je     801c47 <spawn+0x2bc>
		va -= i;
  801c33:	29 c6                	sub    %eax,%esi
		memsz += i;
  801c35:	01 c2                	add    %eax,%edx
  801c37:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801c3d:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801c3f:	29 c1                	sub    %eax,%ecx
  801c41:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c47:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c4c:	e9 f7 00 00 00       	jmp    801d48 <spawn+0x3bd>
		if (i >= filesz) {
  801c51:	39 fb                	cmp    %edi,%ebx
  801c53:	72 27                	jb     801c7c <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801c55:	83 ec 04             	sub    $0x4,%esp
  801c58:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c5e:	56                   	push   %esi
  801c5f:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c65:	e8 f3 ef ff ff       	call   800c5d <sys_page_alloc>
  801c6a:	83 c4 10             	add    $0x10,%esp
  801c6d:	85 c0                	test   %eax,%eax
  801c6f:	0f 89 c7 00 00 00    	jns    801d3c <spawn+0x3b1>
  801c75:	89 c3                	mov    %eax,%ebx
  801c77:	e9 fd 01 00 00       	jmp    801e79 <spawn+0x4ee>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801c7c:	83 ec 04             	sub    $0x4,%esp
  801c7f:	6a 07                	push   $0x7
  801c81:	68 00 00 40 00       	push   $0x400000
  801c86:	6a 00                	push   $0x0
  801c88:	e8 d0 ef ff ff       	call   800c5d <sys_page_alloc>
  801c8d:	83 c4 10             	add    $0x10,%esp
  801c90:	85 c0                	test   %eax,%eax
  801c92:	0f 88 d7 01 00 00    	js     801e6f <spawn+0x4e4>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801c98:	83 ec 08             	sub    $0x8,%esp
  801c9b:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801ca1:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801ca7:	50                   	push   %eax
  801ca8:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801cae:	e8 0f f9 ff ff       	call   8015c2 <seek>
  801cb3:	83 c4 10             	add    $0x10,%esp
  801cb6:	85 c0                	test   %eax,%eax
  801cb8:	0f 88 b5 01 00 00    	js     801e73 <spawn+0x4e8>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801cbe:	83 ec 04             	sub    $0x4,%esp
  801cc1:	89 f8                	mov    %edi,%eax
  801cc3:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801cc9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801cce:	ba 00 10 00 00       	mov    $0x1000,%edx
  801cd3:	0f 47 c2             	cmova  %edx,%eax
  801cd6:	50                   	push   %eax
  801cd7:	68 00 00 40 00       	push   $0x400000
  801cdc:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ce2:	e8 06 f8 ff ff       	call   8014ed <readn>
  801ce7:	83 c4 10             	add    $0x10,%esp
  801cea:	85 c0                	test   %eax,%eax
  801cec:	0f 88 85 01 00 00    	js     801e77 <spawn+0x4ec>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801cf2:	83 ec 0c             	sub    $0xc,%esp
  801cf5:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801cfb:	56                   	push   %esi
  801cfc:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801d02:	68 00 00 40 00       	push   $0x400000
  801d07:	6a 00                	push   $0x0
  801d09:	e8 92 ef ff ff       	call   800ca0 <sys_page_map>
  801d0e:	83 c4 20             	add    $0x20,%esp
  801d11:	85 c0                	test   %eax,%eax
  801d13:	79 15                	jns    801d2a <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801d15:	50                   	push   %eax
  801d16:	68 8d 2e 80 00       	push   $0x802e8d
  801d1b:	68 25 01 00 00       	push   $0x125
  801d20:	68 81 2e 80 00       	push   $0x802e81
  801d25:	e8 d2 e4 ff ff       	call   8001fc <_panic>
			sys_page_unmap(0, UTEMP);
  801d2a:	83 ec 08             	sub    $0x8,%esp
  801d2d:	68 00 00 40 00       	push   $0x400000
  801d32:	6a 00                	push   $0x0
  801d34:	e8 a9 ef ff ff       	call   800ce2 <sys_page_unmap>
  801d39:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801d3c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d42:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801d48:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801d4e:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801d54:	0f 82 f7 fe ff ff    	jb     801c51 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d5a:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801d61:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801d68:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801d6f:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801d75:	0f 8c 65 fe ff ff    	jl     801be0 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801d7b:	83 ec 0c             	sub    $0xc,%esp
  801d7e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d84:	e8 97 f5 ff ff       	call   801320 <close>
  801d89:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801d8c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d91:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801d97:	89 d8                	mov    %ebx,%eax
  801d99:	c1 e8 16             	shr    $0x16,%eax
  801d9c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801da3:	a8 01                	test   $0x1,%al
  801da5:	74 42                	je     801de9 <spawn+0x45e>
  801da7:	89 d8                	mov    %ebx,%eax
  801da9:	c1 e8 0c             	shr    $0xc,%eax
  801dac:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801db3:	f6 c2 01             	test   $0x1,%dl
  801db6:	74 31                	je     801de9 <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  801db8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801dbf:	f6 c6 04             	test   $0x4,%dh
  801dc2:	74 25                	je     801de9 <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  801dc4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801dcb:	83 ec 0c             	sub    $0xc,%esp
  801dce:	25 07 0e 00 00       	and    $0xe07,%eax
  801dd3:	50                   	push   %eax
  801dd4:	53                   	push   %ebx
  801dd5:	56                   	push   %esi
  801dd6:	53                   	push   %ebx
  801dd7:	6a 00                	push   $0x0
  801dd9:	e8 c2 ee ff ff       	call   800ca0 <sys_page_map>
			if (r < 0) {
  801dde:	83 c4 20             	add    $0x20,%esp
  801de1:	85 c0                	test   %eax,%eax
  801de3:	0f 88 b1 00 00 00    	js     801e9a <spawn+0x50f>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801de9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801def:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801df5:	75 a0                	jne    801d97 <spawn+0x40c>
  801df7:	e9 b3 00 00 00       	jmp    801eaf <spawn+0x524>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801dfc:	50                   	push   %eax
  801dfd:	68 aa 2e 80 00       	push   $0x802eaa
  801e02:	68 86 00 00 00       	push   $0x86
  801e07:	68 81 2e 80 00       	push   $0x802e81
  801e0c:	e8 eb e3 ff ff       	call   8001fc <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801e11:	83 ec 08             	sub    $0x8,%esp
  801e14:	6a 02                	push   $0x2
  801e16:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e1c:	e8 03 ef ff ff       	call   800d24 <sys_env_set_status>
  801e21:	83 c4 10             	add    $0x10,%esp
  801e24:	85 c0                	test   %eax,%eax
  801e26:	79 2b                	jns    801e53 <spawn+0x4c8>
		panic("sys_env_set_status: %e", r);
  801e28:	50                   	push   %eax
  801e29:	68 c4 2e 80 00       	push   $0x802ec4
  801e2e:	68 89 00 00 00       	push   $0x89
  801e33:	68 81 2e 80 00       	push   $0x802e81
  801e38:	e8 bf e3 ff ff       	call   8001fc <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801e3d:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801e43:	e9 a8 00 00 00       	jmp    801ef0 <spawn+0x565>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801e48:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e4e:	e9 9d 00 00 00       	jmp    801ef0 <spawn+0x565>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801e53:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e59:	e9 92 00 00 00       	jmp    801ef0 <spawn+0x565>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801e5e:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801e63:	e9 88 00 00 00       	jmp    801ef0 <spawn+0x565>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801e68:	89 c3                	mov    %eax,%ebx
  801e6a:	e9 81 00 00 00       	jmp    801ef0 <spawn+0x565>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e6f:	89 c3                	mov    %eax,%ebx
  801e71:	eb 06                	jmp    801e79 <spawn+0x4ee>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801e73:	89 c3                	mov    %eax,%ebx
  801e75:	eb 02                	jmp    801e79 <spawn+0x4ee>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801e77:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801e79:	83 ec 0c             	sub    $0xc,%esp
  801e7c:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e82:	e8 57 ed ff ff       	call   800bde <sys_env_destroy>
	close(fd);
  801e87:	83 c4 04             	add    $0x4,%esp
  801e8a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e90:	e8 8b f4 ff ff       	call   801320 <close>
	return r;
  801e95:	83 c4 10             	add    $0x10,%esp
  801e98:	eb 56                	jmp    801ef0 <spawn+0x565>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801e9a:	50                   	push   %eax
  801e9b:	68 db 2e 80 00       	push   $0x802edb
  801ea0:	68 82 00 00 00       	push   $0x82
  801ea5:	68 81 2e 80 00       	push   $0x802e81
  801eaa:	e8 4d e3 ff ff       	call   8001fc <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801eaf:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801eb6:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801eb9:	83 ec 08             	sub    $0x8,%esp
  801ebc:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801ec2:	50                   	push   %eax
  801ec3:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ec9:	e8 98 ee ff ff       	call   800d66 <sys_env_set_trapframe>
  801ece:	83 c4 10             	add    $0x10,%esp
  801ed1:	85 c0                	test   %eax,%eax
  801ed3:	0f 89 38 ff ff ff    	jns    801e11 <spawn+0x486>
  801ed9:	e9 1e ff ff ff       	jmp    801dfc <spawn+0x471>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801ede:	83 ec 08             	sub    $0x8,%esp
  801ee1:	68 00 00 40 00       	push   $0x400000
  801ee6:	6a 00                	push   $0x0
  801ee8:	e8 f5 ed ff ff       	call   800ce2 <sys_page_unmap>
  801eed:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801ef0:	89 d8                	mov    %ebx,%eax
  801ef2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ef5:	5b                   	pop    %ebx
  801ef6:	5e                   	pop    %esi
  801ef7:	5f                   	pop    %edi
  801ef8:	5d                   	pop    %ebp
  801ef9:	c3                   	ret    

00801efa <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801efa:	55                   	push   %ebp
  801efb:	89 e5                	mov    %esp,%ebp
  801efd:	56                   	push   %esi
  801efe:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801eff:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801f02:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f07:	eb 03                	jmp    801f0c <spawnl+0x12>
		argc++;
  801f09:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f0c:	83 c2 04             	add    $0x4,%edx
  801f0f:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801f13:	75 f4                	jne    801f09 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801f15:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801f1c:	83 e2 f0             	and    $0xfffffff0,%edx
  801f1f:	29 d4                	sub    %edx,%esp
  801f21:	8d 54 24 03          	lea    0x3(%esp),%edx
  801f25:	c1 ea 02             	shr    $0x2,%edx
  801f28:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801f2f:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801f31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f34:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801f3b:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801f42:	00 
  801f43:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f45:	b8 00 00 00 00       	mov    $0x0,%eax
  801f4a:	eb 0a                	jmp    801f56 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801f4c:	83 c0 01             	add    $0x1,%eax
  801f4f:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801f53:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f56:	39 d0                	cmp    %edx,%eax
  801f58:	75 f2                	jne    801f4c <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801f5a:	83 ec 08             	sub    $0x8,%esp
  801f5d:	56                   	push   %esi
  801f5e:	ff 75 08             	pushl  0x8(%ebp)
  801f61:	e8 25 fa ff ff       	call   80198b <spawn>
}
  801f66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f69:	5b                   	pop    %ebx
  801f6a:	5e                   	pop    %esi
  801f6b:	5d                   	pop    %ebp
  801f6c:	c3                   	ret    

00801f6d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f6d:	55                   	push   %ebp
  801f6e:	89 e5                	mov    %esp,%ebp
  801f70:	56                   	push   %esi
  801f71:	53                   	push   %ebx
  801f72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f75:	83 ec 0c             	sub    $0xc,%esp
  801f78:	ff 75 08             	pushl  0x8(%ebp)
  801f7b:	e8 10 f2 ff ff       	call   801190 <fd2data>
  801f80:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f82:	83 c4 08             	add    $0x8,%esp
  801f85:	68 1c 2f 80 00       	push   $0x802f1c
  801f8a:	53                   	push   %ebx
  801f8b:	e8 ca e8 ff ff       	call   80085a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f90:	8b 46 04             	mov    0x4(%esi),%eax
  801f93:	2b 06                	sub    (%esi),%eax
  801f95:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f9b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801fa2:	00 00 00 
	stat->st_dev = &devpipe;
  801fa5:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801fac:	30 80 00 
	return 0;
}
  801faf:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fb7:	5b                   	pop    %ebx
  801fb8:	5e                   	pop    %esi
  801fb9:	5d                   	pop    %ebp
  801fba:	c3                   	ret    

00801fbb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801fbb:	55                   	push   %ebp
  801fbc:	89 e5                	mov    %esp,%ebp
  801fbe:	53                   	push   %ebx
  801fbf:	83 ec 0c             	sub    $0xc,%esp
  801fc2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801fc5:	53                   	push   %ebx
  801fc6:	6a 00                	push   $0x0
  801fc8:	e8 15 ed ff ff       	call   800ce2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801fcd:	89 1c 24             	mov    %ebx,(%esp)
  801fd0:	e8 bb f1 ff ff       	call   801190 <fd2data>
  801fd5:	83 c4 08             	add    $0x8,%esp
  801fd8:	50                   	push   %eax
  801fd9:	6a 00                	push   $0x0
  801fdb:	e8 02 ed ff ff       	call   800ce2 <sys_page_unmap>
}
  801fe0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fe3:	c9                   	leave  
  801fe4:	c3                   	ret    

00801fe5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801fe5:	55                   	push   %ebp
  801fe6:	89 e5                	mov    %esp,%ebp
  801fe8:	57                   	push   %edi
  801fe9:	56                   	push   %esi
  801fea:	53                   	push   %ebx
  801feb:	83 ec 1c             	sub    $0x1c,%esp
  801fee:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ff1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ff3:	a1 04 40 80 00       	mov    0x804004,%eax
  801ff8:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ffb:	83 ec 0c             	sub    $0xc,%esp
  801ffe:	ff 75 e0             	pushl  -0x20(%ebp)
  802001:	e8 40 06 00 00       	call   802646 <pageref>
  802006:	89 c3                	mov    %eax,%ebx
  802008:	89 3c 24             	mov    %edi,(%esp)
  80200b:	e8 36 06 00 00       	call   802646 <pageref>
  802010:	83 c4 10             	add    $0x10,%esp
  802013:	39 c3                	cmp    %eax,%ebx
  802015:	0f 94 c1             	sete   %cl
  802018:	0f b6 c9             	movzbl %cl,%ecx
  80201b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80201e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  802024:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  802027:	39 ce                	cmp    %ecx,%esi
  802029:	74 1b                	je     802046 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80202b:	39 c3                	cmp    %eax,%ebx
  80202d:	75 c4                	jne    801ff3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80202f:	8b 42 64             	mov    0x64(%edx),%eax
  802032:	ff 75 e4             	pushl  -0x1c(%ebp)
  802035:	50                   	push   %eax
  802036:	56                   	push   %esi
  802037:	68 23 2f 80 00       	push   $0x802f23
  80203c:	e8 94 e2 ff ff       	call   8002d5 <cprintf>
  802041:	83 c4 10             	add    $0x10,%esp
  802044:	eb ad                	jmp    801ff3 <_pipeisclosed+0xe>
	}
}
  802046:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802049:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80204c:	5b                   	pop    %ebx
  80204d:	5e                   	pop    %esi
  80204e:	5f                   	pop    %edi
  80204f:	5d                   	pop    %ebp
  802050:	c3                   	ret    

00802051 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802051:	55                   	push   %ebp
  802052:	89 e5                	mov    %esp,%ebp
  802054:	57                   	push   %edi
  802055:	56                   	push   %esi
  802056:	53                   	push   %ebx
  802057:	83 ec 28             	sub    $0x28,%esp
  80205a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80205d:	56                   	push   %esi
  80205e:	e8 2d f1 ff ff       	call   801190 <fd2data>
  802063:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802065:	83 c4 10             	add    $0x10,%esp
  802068:	bf 00 00 00 00       	mov    $0x0,%edi
  80206d:	eb 4b                	jmp    8020ba <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80206f:	89 da                	mov    %ebx,%edx
  802071:	89 f0                	mov    %esi,%eax
  802073:	e8 6d ff ff ff       	call   801fe5 <_pipeisclosed>
  802078:	85 c0                	test   %eax,%eax
  80207a:	75 48                	jne    8020c4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80207c:	e8 bd eb ff ff       	call   800c3e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802081:	8b 43 04             	mov    0x4(%ebx),%eax
  802084:	8b 0b                	mov    (%ebx),%ecx
  802086:	8d 51 20             	lea    0x20(%ecx),%edx
  802089:	39 d0                	cmp    %edx,%eax
  80208b:	73 e2                	jae    80206f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80208d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802090:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802094:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802097:	89 c2                	mov    %eax,%edx
  802099:	c1 fa 1f             	sar    $0x1f,%edx
  80209c:	89 d1                	mov    %edx,%ecx
  80209e:	c1 e9 1b             	shr    $0x1b,%ecx
  8020a1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8020a4:	83 e2 1f             	and    $0x1f,%edx
  8020a7:	29 ca                	sub    %ecx,%edx
  8020a9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8020ad:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8020b1:	83 c0 01             	add    $0x1,%eax
  8020b4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020b7:	83 c7 01             	add    $0x1,%edi
  8020ba:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8020bd:	75 c2                	jne    802081 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8020bf:	8b 45 10             	mov    0x10(%ebp),%eax
  8020c2:	eb 05                	jmp    8020c9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020c4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8020c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020cc:	5b                   	pop    %ebx
  8020cd:	5e                   	pop    %esi
  8020ce:	5f                   	pop    %edi
  8020cf:	5d                   	pop    %ebp
  8020d0:	c3                   	ret    

008020d1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020d1:	55                   	push   %ebp
  8020d2:	89 e5                	mov    %esp,%ebp
  8020d4:	57                   	push   %edi
  8020d5:	56                   	push   %esi
  8020d6:	53                   	push   %ebx
  8020d7:	83 ec 18             	sub    $0x18,%esp
  8020da:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8020dd:	57                   	push   %edi
  8020de:	e8 ad f0 ff ff       	call   801190 <fd2data>
  8020e3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020e5:	83 c4 10             	add    $0x10,%esp
  8020e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020ed:	eb 3d                	jmp    80212c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8020ef:	85 db                	test   %ebx,%ebx
  8020f1:	74 04                	je     8020f7 <devpipe_read+0x26>
				return i;
  8020f3:	89 d8                	mov    %ebx,%eax
  8020f5:	eb 44                	jmp    80213b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8020f7:	89 f2                	mov    %esi,%edx
  8020f9:	89 f8                	mov    %edi,%eax
  8020fb:	e8 e5 fe ff ff       	call   801fe5 <_pipeisclosed>
  802100:	85 c0                	test   %eax,%eax
  802102:	75 32                	jne    802136 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802104:	e8 35 eb ff ff       	call   800c3e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802109:	8b 06                	mov    (%esi),%eax
  80210b:	3b 46 04             	cmp    0x4(%esi),%eax
  80210e:	74 df                	je     8020ef <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802110:	99                   	cltd   
  802111:	c1 ea 1b             	shr    $0x1b,%edx
  802114:	01 d0                	add    %edx,%eax
  802116:	83 e0 1f             	and    $0x1f,%eax
  802119:	29 d0                	sub    %edx,%eax
  80211b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802120:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802123:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802126:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802129:	83 c3 01             	add    $0x1,%ebx
  80212c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80212f:	75 d8                	jne    802109 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802131:	8b 45 10             	mov    0x10(%ebp),%eax
  802134:	eb 05                	jmp    80213b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802136:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80213b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80213e:	5b                   	pop    %ebx
  80213f:	5e                   	pop    %esi
  802140:	5f                   	pop    %edi
  802141:	5d                   	pop    %ebp
  802142:	c3                   	ret    

00802143 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802143:	55                   	push   %ebp
  802144:	89 e5                	mov    %esp,%ebp
  802146:	56                   	push   %esi
  802147:	53                   	push   %ebx
  802148:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80214b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80214e:	50                   	push   %eax
  80214f:	e8 53 f0 ff ff       	call   8011a7 <fd_alloc>
  802154:	83 c4 10             	add    $0x10,%esp
  802157:	89 c2                	mov    %eax,%edx
  802159:	85 c0                	test   %eax,%eax
  80215b:	0f 88 2c 01 00 00    	js     80228d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802161:	83 ec 04             	sub    $0x4,%esp
  802164:	68 07 04 00 00       	push   $0x407
  802169:	ff 75 f4             	pushl  -0xc(%ebp)
  80216c:	6a 00                	push   $0x0
  80216e:	e8 ea ea ff ff       	call   800c5d <sys_page_alloc>
  802173:	83 c4 10             	add    $0x10,%esp
  802176:	89 c2                	mov    %eax,%edx
  802178:	85 c0                	test   %eax,%eax
  80217a:	0f 88 0d 01 00 00    	js     80228d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802180:	83 ec 0c             	sub    $0xc,%esp
  802183:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802186:	50                   	push   %eax
  802187:	e8 1b f0 ff ff       	call   8011a7 <fd_alloc>
  80218c:	89 c3                	mov    %eax,%ebx
  80218e:	83 c4 10             	add    $0x10,%esp
  802191:	85 c0                	test   %eax,%eax
  802193:	0f 88 e2 00 00 00    	js     80227b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802199:	83 ec 04             	sub    $0x4,%esp
  80219c:	68 07 04 00 00       	push   $0x407
  8021a1:	ff 75 f0             	pushl  -0x10(%ebp)
  8021a4:	6a 00                	push   $0x0
  8021a6:	e8 b2 ea ff ff       	call   800c5d <sys_page_alloc>
  8021ab:	89 c3                	mov    %eax,%ebx
  8021ad:	83 c4 10             	add    $0x10,%esp
  8021b0:	85 c0                	test   %eax,%eax
  8021b2:	0f 88 c3 00 00 00    	js     80227b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8021b8:	83 ec 0c             	sub    $0xc,%esp
  8021bb:	ff 75 f4             	pushl  -0xc(%ebp)
  8021be:	e8 cd ef ff ff       	call   801190 <fd2data>
  8021c3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021c5:	83 c4 0c             	add    $0xc,%esp
  8021c8:	68 07 04 00 00       	push   $0x407
  8021cd:	50                   	push   %eax
  8021ce:	6a 00                	push   $0x0
  8021d0:	e8 88 ea ff ff       	call   800c5d <sys_page_alloc>
  8021d5:	89 c3                	mov    %eax,%ebx
  8021d7:	83 c4 10             	add    $0x10,%esp
  8021da:	85 c0                	test   %eax,%eax
  8021dc:	0f 88 89 00 00 00    	js     80226b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021e2:	83 ec 0c             	sub    $0xc,%esp
  8021e5:	ff 75 f0             	pushl  -0x10(%ebp)
  8021e8:	e8 a3 ef ff ff       	call   801190 <fd2data>
  8021ed:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021f4:	50                   	push   %eax
  8021f5:	6a 00                	push   $0x0
  8021f7:	56                   	push   %esi
  8021f8:	6a 00                	push   $0x0
  8021fa:	e8 a1 ea ff ff       	call   800ca0 <sys_page_map>
  8021ff:	89 c3                	mov    %eax,%ebx
  802201:	83 c4 20             	add    $0x20,%esp
  802204:	85 c0                	test   %eax,%eax
  802206:	78 55                	js     80225d <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802208:	8b 15 28 30 80 00    	mov    0x803028,%edx
  80220e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802211:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802213:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802216:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80221d:	8b 15 28 30 80 00    	mov    0x803028,%edx
  802223:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802226:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802228:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80222b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802232:	83 ec 0c             	sub    $0xc,%esp
  802235:	ff 75 f4             	pushl  -0xc(%ebp)
  802238:	e8 43 ef ff ff       	call   801180 <fd2num>
  80223d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802240:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802242:	83 c4 04             	add    $0x4,%esp
  802245:	ff 75 f0             	pushl  -0x10(%ebp)
  802248:	e8 33 ef ff ff       	call   801180 <fd2num>
  80224d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802250:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  802253:	83 c4 10             	add    $0x10,%esp
  802256:	ba 00 00 00 00       	mov    $0x0,%edx
  80225b:	eb 30                	jmp    80228d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80225d:	83 ec 08             	sub    $0x8,%esp
  802260:	56                   	push   %esi
  802261:	6a 00                	push   $0x0
  802263:	e8 7a ea ff ff       	call   800ce2 <sys_page_unmap>
  802268:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80226b:	83 ec 08             	sub    $0x8,%esp
  80226e:	ff 75 f0             	pushl  -0x10(%ebp)
  802271:	6a 00                	push   $0x0
  802273:	e8 6a ea ff ff       	call   800ce2 <sys_page_unmap>
  802278:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80227b:	83 ec 08             	sub    $0x8,%esp
  80227e:	ff 75 f4             	pushl  -0xc(%ebp)
  802281:	6a 00                	push   $0x0
  802283:	e8 5a ea ff ff       	call   800ce2 <sys_page_unmap>
  802288:	83 c4 10             	add    $0x10,%esp
  80228b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80228d:	89 d0                	mov    %edx,%eax
  80228f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802292:	5b                   	pop    %ebx
  802293:	5e                   	pop    %esi
  802294:	5d                   	pop    %ebp
  802295:	c3                   	ret    

00802296 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802296:	55                   	push   %ebp
  802297:	89 e5                	mov    %esp,%ebp
  802299:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80229c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80229f:	50                   	push   %eax
  8022a0:	ff 75 08             	pushl  0x8(%ebp)
  8022a3:	e8 4e ef ff ff       	call   8011f6 <fd_lookup>
  8022a8:	83 c4 10             	add    $0x10,%esp
  8022ab:	85 c0                	test   %eax,%eax
  8022ad:	78 18                	js     8022c7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8022af:	83 ec 0c             	sub    $0xc,%esp
  8022b2:	ff 75 f4             	pushl  -0xc(%ebp)
  8022b5:	e8 d6 ee ff ff       	call   801190 <fd2data>
	return _pipeisclosed(fd, p);
  8022ba:	89 c2                	mov    %eax,%edx
  8022bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022bf:	e8 21 fd ff ff       	call   801fe5 <_pipeisclosed>
  8022c4:	83 c4 10             	add    $0x10,%esp
}
  8022c7:	c9                   	leave  
  8022c8:	c3                   	ret    

008022c9 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8022c9:	55                   	push   %ebp
  8022ca:	89 e5                	mov    %esp,%ebp
  8022cc:	56                   	push   %esi
  8022cd:	53                   	push   %ebx
  8022ce:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8022d1:	85 f6                	test   %esi,%esi
  8022d3:	75 16                	jne    8022eb <wait+0x22>
  8022d5:	68 3b 2f 80 00       	push   $0x802f3b
  8022da:	68 3b 2e 80 00       	push   $0x802e3b
  8022df:	6a 09                	push   $0x9
  8022e1:	68 46 2f 80 00       	push   $0x802f46
  8022e6:	e8 11 df ff ff       	call   8001fc <_panic>
	e = &envs[ENVX(envid)];
  8022eb:	89 f0                	mov    %esi,%eax
  8022ed:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8022f2:	89 c2                	mov    %eax,%edx
  8022f4:	c1 e2 07             	shl    $0x7,%edx
  8022f7:	8d 9c c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%ebx
  8022fe:	eb 05                	jmp    802305 <wait+0x3c>
		sys_yield();
  802300:	e8 39 e9 ff ff       	call   800c3e <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802305:	8b 43 54             	mov    0x54(%ebx),%eax
  802308:	39 c6                	cmp    %eax,%esi
  80230a:	75 07                	jne    802313 <wait+0x4a>
  80230c:	8b 43 60             	mov    0x60(%ebx),%eax
  80230f:	85 c0                	test   %eax,%eax
  802311:	75 ed                	jne    802300 <wait+0x37>
		sys_yield();
}
  802313:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802316:	5b                   	pop    %ebx
  802317:	5e                   	pop    %esi
  802318:	5d                   	pop    %ebp
  802319:	c3                   	ret    

0080231a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80231a:	55                   	push   %ebp
  80231b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80231d:	b8 00 00 00 00       	mov    $0x0,%eax
  802322:	5d                   	pop    %ebp
  802323:	c3                   	ret    

00802324 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802324:	55                   	push   %ebp
  802325:	89 e5                	mov    %esp,%ebp
  802327:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80232a:	68 51 2f 80 00       	push   $0x802f51
  80232f:	ff 75 0c             	pushl  0xc(%ebp)
  802332:	e8 23 e5 ff ff       	call   80085a <strcpy>
	return 0;
}
  802337:	b8 00 00 00 00       	mov    $0x0,%eax
  80233c:	c9                   	leave  
  80233d:	c3                   	ret    

0080233e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80233e:	55                   	push   %ebp
  80233f:	89 e5                	mov    %esp,%ebp
  802341:	57                   	push   %edi
  802342:	56                   	push   %esi
  802343:	53                   	push   %ebx
  802344:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80234a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80234f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802355:	eb 2d                	jmp    802384 <devcons_write+0x46>
		m = n - tot;
  802357:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80235a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80235c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80235f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802364:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802367:	83 ec 04             	sub    $0x4,%esp
  80236a:	53                   	push   %ebx
  80236b:	03 45 0c             	add    0xc(%ebp),%eax
  80236e:	50                   	push   %eax
  80236f:	57                   	push   %edi
  802370:	e8 77 e6 ff ff       	call   8009ec <memmove>
		sys_cputs(buf, m);
  802375:	83 c4 08             	add    $0x8,%esp
  802378:	53                   	push   %ebx
  802379:	57                   	push   %edi
  80237a:	e8 22 e8 ff ff       	call   800ba1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80237f:	01 de                	add    %ebx,%esi
  802381:	83 c4 10             	add    $0x10,%esp
  802384:	89 f0                	mov    %esi,%eax
  802386:	3b 75 10             	cmp    0x10(%ebp),%esi
  802389:	72 cc                	jb     802357 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80238b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80238e:	5b                   	pop    %ebx
  80238f:	5e                   	pop    %esi
  802390:	5f                   	pop    %edi
  802391:	5d                   	pop    %ebp
  802392:	c3                   	ret    

00802393 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802393:	55                   	push   %ebp
  802394:	89 e5                	mov    %esp,%ebp
  802396:	83 ec 08             	sub    $0x8,%esp
  802399:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80239e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8023a2:	74 2a                	je     8023ce <devcons_read+0x3b>
  8023a4:	eb 05                	jmp    8023ab <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8023a6:	e8 93 e8 ff ff       	call   800c3e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8023ab:	e8 0f e8 ff ff       	call   800bbf <sys_cgetc>
  8023b0:	85 c0                	test   %eax,%eax
  8023b2:	74 f2                	je     8023a6 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8023b4:	85 c0                	test   %eax,%eax
  8023b6:	78 16                	js     8023ce <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8023b8:	83 f8 04             	cmp    $0x4,%eax
  8023bb:	74 0c                	je     8023c9 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8023bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023c0:	88 02                	mov    %al,(%edx)
	return 1;
  8023c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8023c7:	eb 05                	jmp    8023ce <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8023c9:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8023ce:	c9                   	leave  
  8023cf:	c3                   	ret    

008023d0 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8023d0:	55                   	push   %ebp
  8023d1:	89 e5                	mov    %esp,%ebp
  8023d3:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8023d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8023d9:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8023dc:	6a 01                	push   $0x1
  8023de:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023e1:	50                   	push   %eax
  8023e2:	e8 ba e7 ff ff       	call   800ba1 <sys_cputs>
}
  8023e7:	83 c4 10             	add    $0x10,%esp
  8023ea:	c9                   	leave  
  8023eb:	c3                   	ret    

008023ec <getchar>:

int
getchar(void)
{
  8023ec:	55                   	push   %ebp
  8023ed:	89 e5                	mov    %esp,%ebp
  8023ef:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8023f2:	6a 01                	push   $0x1
  8023f4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023f7:	50                   	push   %eax
  8023f8:	6a 00                	push   $0x0
  8023fa:	e8 5d f0 ff ff       	call   80145c <read>
	if (r < 0)
  8023ff:	83 c4 10             	add    $0x10,%esp
  802402:	85 c0                	test   %eax,%eax
  802404:	78 0f                	js     802415 <getchar+0x29>
		return r;
	if (r < 1)
  802406:	85 c0                	test   %eax,%eax
  802408:	7e 06                	jle    802410 <getchar+0x24>
		return -E_EOF;
	return c;
  80240a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80240e:	eb 05                	jmp    802415 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802410:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802415:	c9                   	leave  
  802416:	c3                   	ret    

00802417 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802417:	55                   	push   %ebp
  802418:	89 e5                	mov    %esp,%ebp
  80241a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80241d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802420:	50                   	push   %eax
  802421:	ff 75 08             	pushl  0x8(%ebp)
  802424:	e8 cd ed ff ff       	call   8011f6 <fd_lookup>
  802429:	83 c4 10             	add    $0x10,%esp
  80242c:	85 c0                	test   %eax,%eax
  80242e:	78 11                	js     802441 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802430:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802433:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802439:	39 10                	cmp    %edx,(%eax)
  80243b:	0f 94 c0             	sete   %al
  80243e:	0f b6 c0             	movzbl %al,%eax
}
  802441:	c9                   	leave  
  802442:	c3                   	ret    

00802443 <opencons>:

int
opencons(void)
{
  802443:	55                   	push   %ebp
  802444:	89 e5                	mov    %esp,%ebp
  802446:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802449:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80244c:	50                   	push   %eax
  80244d:	e8 55 ed ff ff       	call   8011a7 <fd_alloc>
  802452:	83 c4 10             	add    $0x10,%esp
		return r;
  802455:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802457:	85 c0                	test   %eax,%eax
  802459:	78 3e                	js     802499 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80245b:	83 ec 04             	sub    $0x4,%esp
  80245e:	68 07 04 00 00       	push   $0x407
  802463:	ff 75 f4             	pushl  -0xc(%ebp)
  802466:	6a 00                	push   $0x0
  802468:	e8 f0 e7 ff ff       	call   800c5d <sys_page_alloc>
  80246d:	83 c4 10             	add    $0x10,%esp
		return r;
  802470:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802472:	85 c0                	test   %eax,%eax
  802474:	78 23                	js     802499 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802476:	8b 15 44 30 80 00    	mov    0x803044,%edx
  80247c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80247f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802481:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802484:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80248b:	83 ec 0c             	sub    $0xc,%esp
  80248e:	50                   	push   %eax
  80248f:	e8 ec ec ff ff       	call   801180 <fd2num>
  802494:	89 c2                	mov    %eax,%edx
  802496:	83 c4 10             	add    $0x10,%esp
}
  802499:	89 d0                	mov    %edx,%eax
  80249b:	c9                   	leave  
  80249c:	c3                   	ret    

0080249d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80249d:	55                   	push   %ebp
  80249e:	89 e5                	mov    %esp,%ebp
  8024a0:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8024a3:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8024aa:	75 2a                	jne    8024d6 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  8024ac:	83 ec 04             	sub    $0x4,%esp
  8024af:	6a 07                	push   $0x7
  8024b1:	68 00 f0 bf ee       	push   $0xeebff000
  8024b6:	6a 00                	push   $0x0
  8024b8:	e8 a0 e7 ff ff       	call   800c5d <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8024bd:	83 c4 10             	add    $0x10,%esp
  8024c0:	85 c0                	test   %eax,%eax
  8024c2:	79 12                	jns    8024d6 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8024c4:	50                   	push   %eax
  8024c5:	68 5d 2f 80 00       	push   $0x802f5d
  8024ca:	6a 23                	push   $0x23
  8024cc:	68 61 2f 80 00       	push   $0x802f61
  8024d1:	e8 26 dd ff ff       	call   8001fc <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8024d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8024d9:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8024de:	83 ec 08             	sub    $0x8,%esp
  8024e1:	68 08 25 80 00       	push   $0x802508
  8024e6:	6a 00                	push   $0x0
  8024e8:	e8 bb e8 ff ff       	call   800da8 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8024ed:	83 c4 10             	add    $0x10,%esp
  8024f0:	85 c0                	test   %eax,%eax
  8024f2:	79 12                	jns    802506 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8024f4:	50                   	push   %eax
  8024f5:	68 5d 2f 80 00       	push   $0x802f5d
  8024fa:	6a 2c                	push   $0x2c
  8024fc:	68 61 2f 80 00       	push   $0x802f61
  802501:	e8 f6 dc ff ff       	call   8001fc <_panic>
	}
}
  802506:	c9                   	leave  
  802507:	c3                   	ret    

00802508 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802508:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802509:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80250e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802510:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802513:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802517:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80251c:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802520:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802522:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802525:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802526:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802529:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80252a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80252b:	c3                   	ret    

0080252c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80252c:	55                   	push   %ebp
  80252d:	89 e5                	mov    %esp,%ebp
  80252f:	56                   	push   %esi
  802530:	53                   	push   %ebx
  802531:	8b 75 08             	mov    0x8(%ebp),%esi
  802534:	8b 45 0c             	mov    0xc(%ebp),%eax
  802537:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80253a:	85 c0                	test   %eax,%eax
  80253c:	75 12                	jne    802550 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80253e:	83 ec 0c             	sub    $0xc,%esp
  802541:	68 00 00 c0 ee       	push   $0xeec00000
  802546:	e8 c2 e8 ff ff       	call   800e0d <sys_ipc_recv>
  80254b:	83 c4 10             	add    $0x10,%esp
  80254e:	eb 0c                	jmp    80255c <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802550:	83 ec 0c             	sub    $0xc,%esp
  802553:	50                   	push   %eax
  802554:	e8 b4 e8 ff ff       	call   800e0d <sys_ipc_recv>
  802559:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80255c:	85 f6                	test   %esi,%esi
  80255e:	0f 95 c1             	setne  %cl
  802561:	85 db                	test   %ebx,%ebx
  802563:	0f 95 c2             	setne  %dl
  802566:	84 d1                	test   %dl,%cl
  802568:	74 09                	je     802573 <ipc_recv+0x47>
  80256a:	89 c2                	mov    %eax,%edx
  80256c:	c1 ea 1f             	shr    $0x1f,%edx
  80256f:	84 d2                	test   %dl,%dl
  802571:	75 2a                	jne    80259d <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802573:	85 f6                	test   %esi,%esi
  802575:	74 0d                	je     802584 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802577:	a1 04 40 80 00       	mov    0x804004,%eax
  80257c:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  802582:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802584:	85 db                	test   %ebx,%ebx
  802586:	74 0d                	je     802595 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802588:	a1 04 40 80 00       	mov    0x804004,%eax
  80258d:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  802593:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802595:	a1 04 40 80 00       	mov    0x804004,%eax
  80259a:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  80259d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025a0:	5b                   	pop    %ebx
  8025a1:	5e                   	pop    %esi
  8025a2:	5d                   	pop    %ebp
  8025a3:	c3                   	ret    

008025a4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8025a4:	55                   	push   %ebp
  8025a5:	89 e5                	mov    %esp,%ebp
  8025a7:	57                   	push   %edi
  8025a8:	56                   	push   %esi
  8025a9:	53                   	push   %ebx
  8025aa:	83 ec 0c             	sub    $0xc,%esp
  8025ad:	8b 7d 08             	mov    0x8(%ebp),%edi
  8025b0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8025b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8025b6:	85 db                	test   %ebx,%ebx
  8025b8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8025bd:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8025c0:	ff 75 14             	pushl  0x14(%ebp)
  8025c3:	53                   	push   %ebx
  8025c4:	56                   	push   %esi
  8025c5:	57                   	push   %edi
  8025c6:	e8 1f e8 ff ff       	call   800dea <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8025cb:	89 c2                	mov    %eax,%edx
  8025cd:	c1 ea 1f             	shr    $0x1f,%edx
  8025d0:	83 c4 10             	add    $0x10,%esp
  8025d3:	84 d2                	test   %dl,%dl
  8025d5:	74 17                	je     8025ee <ipc_send+0x4a>
  8025d7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8025da:	74 12                	je     8025ee <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8025dc:	50                   	push   %eax
  8025dd:	68 6f 2f 80 00       	push   $0x802f6f
  8025e2:	6a 47                	push   $0x47
  8025e4:	68 7d 2f 80 00       	push   $0x802f7d
  8025e9:	e8 0e dc ff ff       	call   8001fc <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8025ee:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8025f1:	75 07                	jne    8025fa <ipc_send+0x56>
			sys_yield();
  8025f3:	e8 46 e6 ff ff       	call   800c3e <sys_yield>
  8025f8:	eb c6                	jmp    8025c0 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8025fa:	85 c0                	test   %eax,%eax
  8025fc:	75 c2                	jne    8025c0 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8025fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802601:	5b                   	pop    %ebx
  802602:	5e                   	pop    %esi
  802603:	5f                   	pop    %edi
  802604:	5d                   	pop    %ebp
  802605:	c3                   	ret    

00802606 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802606:	55                   	push   %ebp
  802607:	89 e5                	mov    %esp,%ebp
  802609:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80260c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802611:	89 c2                	mov    %eax,%edx
  802613:	c1 e2 07             	shl    $0x7,%edx
  802616:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  80261d:	8b 52 5c             	mov    0x5c(%edx),%edx
  802620:	39 ca                	cmp    %ecx,%edx
  802622:	75 11                	jne    802635 <ipc_find_env+0x2f>
			return envs[i].env_id;
  802624:	89 c2                	mov    %eax,%edx
  802626:	c1 e2 07             	shl    $0x7,%edx
  802629:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  802630:	8b 40 54             	mov    0x54(%eax),%eax
  802633:	eb 0f                	jmp    802644 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802635:	83 c0 01             	add    $0x1,%eax
  802638:	3d 00 04 00 00       	cmp    $0x400,%eax
  80263d:	75 d2                	jne    802611 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80263f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802644:	5d                   	pop    %ebp
  802645:	c3                   	ret    

00802646 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802646:	55                   	push   %ebp
  802647:	89 e5                	mov    %esp,%ebp
  802649:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80264c:	89 d0                	mov    %edx,%eax
  80264e:	c1 e8 16             	shr    $0x16,%eax
  802651:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802658:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80265d:	f6 c1 01             	test   $0x1,%cl
  802660:	74 1d                	je     80267f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802662:	c1 ea 0c             	shr    $0xc,%edx
  802665:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80266c:	f6 c2 01             	test   $0x1,%dl
  80266f:	74 0e                	je     80267f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802671:	c1 ea 0c             	shr    $0xc,%edx
  802674:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80267b:	ef 
  80267c:	0f b7 c0             	movzwl %ax,%eax
}
  80267f:	5d                   	pop    %ebp
  802680:	c3                   	ret    
  802681:	66 90                	xchg   %ax,%ax
  802683:	66 90                	xchg   %ax,%ax
  802685:	66 90                	xchg   %ax,%ax
  802687:	66 90                	xchg   %ax,%ax
  802689:	66 90                	xchg   %ax,%ax
  80268b:	66 90                	xchg   %ax,%ax
  80268d:	66 90                	xchg   %ax,%ax
  80268f:	90                   	nop

00802690 <__udivdi3>:
  802690:	55                   	push   %ebp
  802691:	57                   	push   %edi
  802692:	56                   	push   %esi
  802693:	53                   	push   %ebx
  802694:	83 ec 1c             	sub    $0x1c,%esp
  802697:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80269b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80269f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8026a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026a7:	85 f6                	test   %esi,%esi
  8026a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026ad:	89 ca                	mov    %ecx,%edx
  8026af:	89 f8                	mov    %edi,%eax
  8026b1:	75 3d                	jne    8026f0 <__udivdi3+0x60>
  8026b3:	39 cf                	cmp    %ecx,%edi
  8026b5:	0f 87 c5 00 00 00    	ja     802780 <__udivdi3+0xf0>
  8026bb:	85 ff                	test   %edi,%edi
  8026bd:	89 fd                	mov    %edi,%ebp
  8026bf:	75 0b                	jne    8026cc <__udivdi3+0x3c>
  8026c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8026c6:	31 d2                	xor    %edx,%edx
  8026c8:	f7 f7                	div    %edi
  8026ca:	89 c5                	mov    %eax,%ebp
  8026cc:	89 c8                	mov    %ecx,%eax
  8026ce:	31 d2                	xor    %edx,%edx
  8026d0:	f7 f5                	div    %ebp
  8026d2:	89 c1                	mov    %eax,%ecx
  8026d4:	89 d8                	mov    %ebx,%eax
  8026d6:	89 cf                	mov    %ecx,%edi
  8026d8:	f7 f5                	div    %ebp
  8026da:	89 c3                	mov    %eax,%ebx
  8026dc:	89 d8                	mov    %ebx,%eax
  8026de:	89 fa                	mov    %edi,%edx
  8026e0:	83 c4 1c             	add    $0x1c,%esp
  8026e3:	5b                   	pop    %ebx
  8026e4:	5e                   	pop    %esi
  8026e5:	5f                   	pop    %edi
  8026e6:	5d                   	pop    %ebp
  8026e7:	c3                   	ret    
  8026e8:	90                   	nop
  8026e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026f0:	39 ce                	cmp    %ecx,%esi
  8026f2:	77 74                	ja     802768 <__udivdi3+0xd8>
  8026f4:	0f bd fe             	bsr    %esi,%edi
  8026f7:	83 f7 1f             	xor    $0x1f,%edi
  8026fa:	0f 84 98 00 00 00    	je     802798 <__udivdi3+0x108>
  802700:	bb 20 00 00 00       	mov    $0x20,%ebx
  802705:	89 f9                	mov    %edi,%ecx
  802707:	89 c5                	mov    %eax,%ebp
  802709:	29 fb                	sub    %edi,%ebx
  80270b:	d3 e6                	shl    %cl,%esi
  80270d:	89 d9                	mov    %ebx,%ecx
  80270f:	d3 ed                	shr    %cl,%ebp
  802711:	89 f9                	mov    %edi,%ecx
  802713:	d3 e0                	shl    %cl,%eax
  802715:	09 ee                	or     %ebp,%esi
  802717:	89 d9                	mov    %ebx,%ecx
  802719:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80271d:	89 d5                	mov    %edx,%ebp
  80271f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802723:	d3 ed                	shr    %cl,%ebp
  802725:	89 f9                	mov    %edi,%ecx
  802727:	d3 e2                	shl    %cl,%edx
  802729:	89 d9                	mov    %ebx,%ecx
  80272b:	d3 e8                	shr    %cl,%eax
  80272d:	09 c2                	or     %eax,%edx
  80272f:	89 d0                	mov    %edx,%eax
  802731:	89 ea                	mov    %ebp,%edx
  802733:	f7 f6                	div    %esi
  802735:	89 d5                	mov    %edx,%ebp
  802737:	89 c3                	mov    %eax,%ebx
  802739:	f7 64 24 0c          	mull   0xc(%esp)
  80273d:	39 d5                	cmp    %edx,%ebp
  80273f:	72 10                	jb     802751 <__udivdi3+0xc1>
  802741:	8b 74 24 08          	mov    0x8(%esp),%esi
  802745:	89 f9                	mov    %edi,%ecx
  802747:	d3 e6                	shl    %cl,%esi
  802749:	39 c6                	cmp    %eax,%esi
  80274b:	73 07                	jae    802754 <__udivdi3+0xc4>
  80274d:	39 d5                	cmp    %edx,%ebp
  80274f:	75 03                	jne    802754 <__udivdi3+0xc4>
  802751:	83 eb 01             	sub    $0x1,%ebx
  802754:	31 ff                	xor    %edi,%edi
  802756:	89 d8                	mov    %ebx,%eax
  802758:	89 fa                	mov    %edi,%edx
  80275a:	83 c4 1c             	add    $0x1c,%esp
  80275d:	5b                   	pop    %ebx
  80275e:	5e                   	pop    %esi
  80275f:	5f                   	pop    %edi
  802760:	5d                   	pop    %ebp
  802761:	c3                   	ret    
  802762:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802768:	31 ff                	xor    %edi,%edi
  80276a:	31 db                	xor    %ebx,%ebx
  80276c:	89 d8                	mov    %ebx,%eax
  80276e:	89 fa                	mov    %edi,%edx
  802770:	83 c4 1c             	add    $0x1c,%esp
  802773:	5b                   	pop    %ebx
  802774:	5e                   	pop    %esi
  802775:	5f                   	pop    %edi
  802776:	5d                   	pop    %ebp
  802777:	c3                   	ret    
  802778:	90                   	nop
  802779:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802780:	89 d8                	mov    %ebx,%eax
  802782:	f7 f7                	div    %edi
  802784:	31 ff                	xor    %edi,%edi
  802786:	89 c3                	mov    %eax,%ebx
  802788:	89 d8                	mov    %ebx,%eax
  80278a:	89 fa                	mov    %edi,%edx
  80278c:	83 c4 1c             	add    $0x1c,%esp
  80278f:	5b                   	pop    %ebx
  802790:	5e                   	pop    %esi
  802791:	5f                   	pop    %edi
  802792:	5d                   	pop    %ebp
  802793:	c3                   	ret    
  802794:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802798:	39 ce                	cmp    %ecx,%esi
  80279a:	72 0c                	jb     8027a8 <__udivdi3+0x118>
  80279c:	31 db                	xor    %ebx,%ebx
  80279e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8027a2:	0f 87 34 ff ff ff    	ja     8026dc <__udivdi3+0x4c>
  8027a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8027ad:	e9 2a ff ff ff       	jmp    8026dc <__udivdi3+0x4c>
  8027b2:	66 90                	xchg   %ax,%ax
  8027b4:	66 90                	xchg   %ax,%ax
  8027b6:	66 90                	xchg   %ax,%ax
  8027b8:	66 90                	xchg   %ax,%ax
  8027ba:	66 90                	xchg   %ax,%ax
  8027bc:	66 90                	xchg   %ax,%ax
  8027be:	66 90                	xchg   %ax,%ax

008027c0 <__umoddi3>:
  8027c0:	55                   	push   %ebp
  8027c1:	57                   	push   %edi
  8027c2:	56                   	push   %esi
  8027c3:	53                   	push   %ebx
  8027c4:	83 ec 1c             	sub    $0x1c,%esp
  8027c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8027cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8027cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8027d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8027d7:	85 d2                	test   %edx,%edx
  8027d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8027dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027e1:	89 f3                	mov    %esi,%ebx
  8027e3:	89 3c 24             	mov    %edi,(%esp)
  8027e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027ea:	75 1c                	jne    802808 <__umoddi3+0x48>
  8027ec:	39 f7                	cmp    %esi,%edi
  8027ee:	76 50                	jbe    802840 <__umoddi3+0x80>
  8027f0:	89 c8                	mov    %ecx,%eax
  8027f2:	89 f2                	mov    %esi,%edx
  8027f4:	f7 f7                	div    %edi
  8027f6:	89 d0                	mov    %edx,%eax
  8027f8:	31 d2                	xor    %edx,%edx
  8027fa:	83 c4 1c             	add    $0x1c,%esp
  8027fd:	5b                   	pop    %ebx
  8027fe:	5e                   	pop    %esi
  8027ff:	5f                   	pop    %edi
  802800:	5d                   	pop    %ebp
  802801:	c3                   	ret    
  802802:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802808:	39 f2                	cmp    %esi,%edx
  80280a:	89 d0                	mov    %edx,%eax
  80280c:	77 52                	ja     802860 <__umoddi3+0xa0>
  80280e:	0f bd ea             	bsr    %edx,%ebp
  802811:	83 f5 1f             	xor    $0x1f,%ebp
  802814:	75 5a                	jne    802870 <__umoddi3+0xb0>
  802816:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80281a:	0f 82 e0 00 00 00    	jb     802900 <__umoddi3+0x140>
  802820:	39 0c 24             	cmp    %ecx,(%esp)
  802823:	0f 86 d7 00 00 00    	jbe    802900 <__umoddi3+0x140>
  802829:	8b 44 24 08          	mov    0x8(%esp),%eax
  80282d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802831:	83 c4 1c             	add    $0x1c,%esp
  802834:	5b                   	pop    %ebx
  802835:	5e                   	pop    %esi
  802836:	5f                   	pop    %edi
  802837:	5d                   	pop    %ebp
  802838:	c3                   	ret    
  802839:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802840:	85 ff                	test   %edi,%edi
  802842:	89 fd                	mov    %edi,%ebp
  802844:	75 0b                	jne    802851 <__umoddi3+0x91>
  802846:	b8 01 00 00 00       	mov    $0x1,%eax
  80284b:	31 d2                	xor    %edx,%edx
  80284d:	f7 f7                	div    %edi
  80284f:	89 c5                	mov    %eax,%ebp
  802851:	89 f0                	mov    %esi,%eax
  802853:	31 d2                	xor    %edx,%edx
  802855:	f7 f5                	div    %ebp
  802857:	89 c8                	mov    %ecx,%eax
  802859:	f7 f5                	div    %ebp
  80285b:	89 d0                	mov    %edx,%eax
  80285d:	eb 99                	jmp    8027f8 <__umoddi3+0x38>
  80285f:	90                   	nop
  802860:	89 c8                	mov    %ecx,%eax
  802862:	89 f2                	mov    %esi,%edx
  802864:	83 c4 1c             	add    $0x1c,%esp
  802867:	5b                   	pop    %ebx
  802868:	5e                   	pop    %esi
  802869:	5f                   	pop    %edi
  80286a:	5d                   	pop    %ebp
  80286b:	c3                   	ret    
  80286c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802870:	8b 34 24             	mov    (%esp),%esi
  802873:	bf 20 00 00 00       	mov    $0x20,%edi
  802878:	89 e9                	mov    %ebp,%ecx
  80287a:	29 ef                	sub    %ebp,%edi
  80287c:	d3 e0                	shl    %cl,%eax
  80287e:	89 f9                	mov    %edi,%ecx
  802880:	89 f2                	mov    %esi,%edx
  802882:	d3 ea                	shr    %cl,%edx
  802884:	89 e9                	mov    %ebp,%ecx
  802886:	09 c2                	or     %eax,%edx
  802888:	89 d8                	mov    %ebx,%eax
  80288a:	89 14 24             	mov    %edx,(%esp)
  80288d:	89 f2                	mov    %esi,%edx
  80288f:	d3 e2                	shl    %cl,%edx
  802891:	89 f9                	mov    %edi,%ecx
  802893:	89 54 24 04          	mov    %edx,0x4(%esp)
  802897:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80289b:	d3 e8                	shr    %cl,%eax
  80289d:	89 e9                	mov    %ebp,%ecx
  80289f:	89 c6                	mov    %eax,%esi
  8028a1:	d3 e3                	shl    %cl,%ebx
  8028a3:	89 f9                	mov    %edi,%ecx
  8028a5:	89 d0                	mov    %edx,%eax
  8028a7:	d3 e8                	shr    %cl,%eax
  8028a9:	89 e9                	mov    %ebp,%ecx
  8028ab:	09 d8                	or     %ebx,%eax
  8028ad:	89 d3                	mov    %edx,%ebx
  8028af:	89 f2                	mov    %esi,%edx
  8028b1:	f7 34 24             	divl   (%esp)
  8028b4:	89 d6                	mov    %edx,%esi
  8028b6:	d3 e3                	shl    %cl,%ebx
  8028b8:	f7 64 24 04          	mull   0x4(%esp)
  8028bc:	39 d6                	cmp    %edx,%esi
  8028be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8028c2:	89 d1                	mov    %edx,%ecx
  8028c4:	89 c3                	mov    %eax,%ebx
  8028c6:	72 08                	jb     8028d0 <__umoddi3+0x110>
  8028c8:	75 11                	jne    8028db <__umoddi3+0x11b>
  8028ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8028ce:	73 0b                	jae    8028db <__umoddi3+0x11b>
  8028d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8028d4:	1b 14 24             	sbb    (%esp),%edx
  8028d7:	89 d1                	mov    %edx,%ecx
  8028d9:	89 c3                	mov    %eax,%ebx
  8028db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8028df:	29 da                	sub    %ebx,%edx
  8028e1:	19 ce                	sbb    %ecx,%esi
  8028e3:	89 f9                	mov    %edi,%ecx
  8028e5:	89 f0                	mov    %esi,%eax
  8028e7:	d3 e0                	shl    %cl,%eax
  8028e9:	89 e9                	mov    %ebp,%ecx
  8028eb:	d3 ea                	shr    %cl,%edx
  8028ed:	89 e9                	mov    %ebp,%ecx
  8028ef:	d3 ee                	shr    %cl,%esi
  8028f1:	09 d0                	or     %edx,%eax
  8028f3:	89 f2                	mov    %esi,%edx
  8028f5:	83 c4 1c             	add    $0x1c,%esp
  8028f8:	5b                   	pop    %ebx
  8028f9:	5e                   	pop    %esi
  8028fa:	5f                   	pop    %edi
  8028fb:	5d                   	pop    %ebp
  8028fc:	c3                   	ret    
  8028fd:	8d 76 00             	lea    0x0(%esi),%esi
  802900:	29 f9                	sub    %edi,%ecx
  802902:	19 d6                	sbb    %edx,%esi
  802904:	89 74 24 04          	mov    %esi,0x4(%esp)
  802908:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80290c:	e9 18 ff ff ff       	jmp    802829 <__umoddi3+0x69>
