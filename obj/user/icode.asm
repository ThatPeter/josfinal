
obj/user/icode.debug:     file format elf32-i386


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
  80002c:	e8 03 01 00 00       	call   800134 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	81 ec 1c 02 00 00    	sub    $0x21c,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003e:	c7 05 00 30 80 00 a0 	movl   $0x8028a0,0x803000
  800045:	28 80 00 

	cprintf("icode startup\n");
  800048:	68 a6 28 80 00       	push   $0x8028a6
  80004d:	e8 3e 02 00 00       	call   800290 <cprintf>

	cprintf("icode: open /motd\n");
  800052:	c7 04 24 b5 28 80 00 	movl   $0x8028b5,(%esp)
  800059:	e8 32 02 00 00       	call   800290 <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005e:	83 c4 08             	add    $0x8,%esp
  800061:	6a 00                	push   $0x0
  800063:	68 c8 28 80 00       	push   $0x8028c8
  800068:	e8 37 18 00 00       	call   8018a4 <open>
  80006d:	89 c6                	mov    %eax,%esi
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	85 c0                	test   %eax,%eax
  800074:	79 12                	jns    800088 <umain+0x55>
		panic("icode: open /motd: %e", fd);
  800076:	50                   	push   %eax
  800077:	68 ce 28 80 00       	push   $0x8028ce
  80007c:	6a 0f                	push   $0xf
  80007e:	68 e4 28 80 00       	push   $0x8028e4
  800083:	e8 2f 01 00 00       	call   8001b7 <_panic>

	cprintf("icode: read /motd\n");
  800088:	83 ec 0c             	sub    $0xc,%esp
  80008b:	68 f1 28 80 00       	push   $0x8028f1
  800090:	e8 fb 01 00 00       	call   800290 <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  80009e:	eb 0d                	jmp    8000ad <umain+0x7a>
		sys_cputs(buf, n);
  8000a0:	83 ec 08             	sub    $0x8,%esp
  8000a3:	50                   	push   %eax
  8000a4:	53                   	push   %ebx
  8000a5:	e8 b2 0a 00 00       	call   800b5c <sys_cputs>
  8000aa:	83 c4 10             	add    $0x10,%esp
	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0)
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000ad:	83 ec 04             	sub    $0x4,%esp
  8000b0:	68 00 02 00 00       	push   $0x200
  8000b5:	53                   	push   %ebx
  8000b6:	56                   	push   %esi
  8000b7:	e8 5d 13 00 00       	call   801419 <read>
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	7f dd                	jg     8000a0 <umain+0x6d>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	68 04 29 80 00       	push   $0x802904
  8000cb:	e8 c0 01 00 00       	call   800290 <cprintf>
	close(fd);
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 05 12 00 00       	call   8012dd <close>

	cprintf("icode: spawn /init\n");
  8000d8:	c7 04 24 18 29 80 00 	movl   $0x802918,(%esp)
  8000df:	e8 ac 01 00 00       	call   800290 <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000eb:	68 2c 29 80 00       	push   $0x80292c
  8000f0:	68 35 29 80 00       	push   $0x802935
  8000f5:	68 3f 29 80 00       	push   $0x80293f
  8000fa:	68 3e 29 80 00       	push   $0x80293e
  8000ff:	e8 b6 1d 00 00       	call   801eba <spawnl>
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	85 c0                	test   %eax,%eax
  800109:	79 12                	jns    80011d <umain+0xea>
		panic("icode: spawn /init: %e", r);
  80010b:	50                   	push   %eax
  80010c:	68 44 29 80 00       	push   $0x802944
  800111:	6a 1a                	push   $0x1a
  800113:	68 e4 28 80 00       	push   $0x8028e4
  800118:	e8 9a 00 00 00       	call   8001b7 <_panic>

	cprintf("icode: exiting\n");
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	68 5b 29 80 00       	push   $0x80295b
  800125:	e8 66 01 00 00       	call   800290 <cprintf>
}
  80012a:	83 c4 10             	add    $0x10,%esp
  80012d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800130:	5b                   	pop    %ebx
  800131:	5e                   	pop    %esi
  800132:	5d                   	pop    %ebp
  800133:	c3                   	ret    

00800134 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
  800139:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80013f:	e8 96 0a 00 00       	call   800bda <sys_getenvid>
  800144:	25 ff 03 00 00       	and    $0x3ff,%eax
  800149:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  80014f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800154:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800159:	85 db                	test   %ebx,%ebx
  80015b:	7e 07                	jle    800164 <libmain+0x30>
		binaryname = argv[0];
  80015d:	8b 06                	mov    (%esi),%eax
  80015f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800164:	83 ec 08             	sub    $0x8,%esp
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	e8 c5 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80016e:	e8 2a 00 00 00       	call   80019d <exit>
}
  800173:	83 c4 10             	add    $0x10,%esp
  800176:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800179:	5b                   	pop    %ebx
  80017a:	5e                   	pop    %esi
  80017b:	5d                   	pop    %ebp
  80017c:	c3                   	ret    

0080017d <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  80017d:	55                   	push   %ebp
  80017e:	89 e5                	mov    %esp,%ebp
  800180:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  800183:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  800188:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  80018a:	e8 4b 0a 00 00       	call   800bda <sys_getenvid>
  80018f:	83 ec 0c             	sub    $0xc,%esp
  800192:	50                   	push   %eax
  800193:	e8 91 0c 00 00       	call   800e29 <sys_thread_free>
}
  800198:	83 c4 10             	add    $0x10,%esp
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    

0080019d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001a3:	e8 60 11 00 00       	call   801308 <close_all>
	sys_env_destroy(0);
  8001a8:	83 ec 0c             	sub    $0xc,%esp
  8001ab:	6a 00                	push   $0x0
  8001ad:	e8 e7 09 00 00       	call   800b99 <sys_env_destroy>
}
  8001b2:	83 c4 10             	add    $0x10,%esp
  8001b5:	c9                   	leave  
  8001b6:	c3                   	ret    

008001b7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	56                   	push   %esi
  8001bb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001bc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001bf:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001c5:	e8 10 0a 00 00       	call   800bda <sys_getenvid>
  8001ca:	83 ec 0c             	sub    $0xc,%esp
  8001cd:	ff 75 0c             	pushl  0xc(%ebp)
  8001d0:	ff 75 08             	pushl  0x8(%ebp)
  8001d3:	56                   	push   %esi
  8001d4:	50                   	push   %eax
  8001d5:	68 78 29 80 00       	push   $0x802978
  8001da:	e8 b1 00 00 00       	call   800290 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001df:	83 c4 18             	add    $0x18,%esp
  8001e2:	53                   	push   %ebx
  8001e3:	ff 75 10             	pushl  0x10(%ebp)
  8001e6:	e8 54 00 00 00       	call   80023f <vcprintf>
	cprintf("\n");
  8001eb:	c7 04 24 d4 2e 80 00 	movl   $0x802ed4,(%esp)
  8001f2:	e8 99 00 00 00       	call   800290 <cprintf>
  8001f7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001fa:	cc                   	int3   
  8001fb:	eb fd                	jmp    8001fa <_panic+0x43>

008001fd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001fd:	55                   	push   %ebp
  8001fe:	89 e5                	mov    %esp,%ebp
  800200:	53                   	push   %ebx
  800201:	83 ec 04             	sub    $0x4,%esp
  800204:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800207:	8b 13                	mov    (%ebx),%edx
  800209:	8d 42 01             	lea    0x1(%edx),%eax
  80020c:	89 03                	mov    %eax,(%ebx)
  80020e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800211:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800215:	3d ff 00 00 00       	cmp    $0xff,%eax
  80021a:	75 1a                	jne    800236 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80021c:	83 ec 08             	sub    $0x8,%esp
  80021f:	68 ff 00 00 00       	push   $0xff
  800224:	8d 43 08             	lea    0x8(%ebx),%eax
  800227:	50                   	push   %eax
  800228:	e8 2f 09 00 00       	call   800b5c <sys_cputs>
		b->idx = 0;
  80022d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800233:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800236:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80023a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80023d:	c9                   	leave  
  80023e:	c3                   	ret    

0080023f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023f:	55                   	push   %ebp
  800240:	89 e5                	mov    %esp,%ebp
  800242:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800248:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024f:	00 00 00 
	b.cnt = 0;
  800252:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800259:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80025c:	ff 75 0c             	pushl  0xc(%ebp)
  80025f:	ff 75 08             	pushl  0x8(%ebp)
  800262:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800268:	50                   	push   %eax
  800269:	68 fd 01 80 00       	push   $0x8001fd
  80026e:	e8 54 01 00 00       	call   8003c7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800273:	83 c4 08             	add    $0x8,%esp
  800276:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80027c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800282:	50                   	push   %eax
  800283:	e8 d4 08 00 00       	call   800b5c <sys_cputs>

	return b.cnt;
}
  800288:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028e:	c9                   	leave  
  80028f:	c3                   	ret    

00800290 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800296:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800299:	50                   	push   %eax
  80029a:	ff 75 08             	pushl  0x8(%ebp)
  80029d:	e8 9d ff ff ff       	call   80023f <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a2:	c9                   	leave  
  8002a3:	c3                   	ret    

008002a4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	57                   	push   %edi
  8002a8:	56                   	push   %esi
  8002a9:	53                   	push   %ebx
  8002aa:	83 ec 1c             	sub    $0x1c,%esp
  8002ad:	89 c7                	mov    %eax,%edi
  8002af:	89 d6                	mov    %edx,%esi
  8002b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ba:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002c8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002cb:	39 d3                	cmp    %edx,%ebx
  8002cd:	72 05                	jb     8002d4 <printnum+0x30>
  8002cf:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002d2:	77 45                	ja     800319 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d4:	83 ec 0c             	sub    $0xc,%esp
  8002d7:	ff 75 18             	pushl  0x18(%ebp)
  8002da:	8b 45 14             	mov    0x14(%ebp),%eax
  8002dd:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002e0:	53                   	push   %ebx
  8002e1:	ff 75 10             	pushl  0x10(%ebp)
  8002e4:	83 ec 08             	sub    $0x8,%esp
  8002e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ed:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f0:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f3:	e8 08 23 00 00       	call   802600 <__udivdi3>
  8002f8:	83 c4 18             	add    $0x18,%esp
  8002fb:	52                   	push   %edx
  8002fc:	50                   	push   %eax
  8002fd:	89 f2                	mov    %esi,%edx
  8002ff:	89 f8                	mov    %edi,%eax
  800301:	e8 9e ff ff ff       	call   8002a4 <printnum>
  800306:	83 c4 20             	add    $0x20,%esp
  800309:	eb 18                	jmp    800323 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80030b:	83 ec 08             	sub    $0x8,%esp
  80030e:	56                   	push   %esi
  80030f:	ff 75 18             	pushl  0x18(%ebp)
  800312:	ff d7                	call   *%edi
  800314:	83 c4 10             	add    $0x10,%esp
  800317:	eb 03                	jmp    80031c <printnum+0x78>
  800319:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80031c:	83 eb 01             	sub    $0x1,%ebx
  80031f:	85 db                	test   %ebx,%ebx
  800321:	7f e8                	jg     80030b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800323:	83 ec 08             	sub    $0x8,%esp
  800326:	56                   	push   %esi
  800327:	83 ec 04             	sub    $0x4,%esp
  80032a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80032d:	ff 75 e0             	pushl  -0x20(%ebp)
  800330:	ff 75 dc             	pushl  -0x24(%ebp)
  800333:	ff 75 d8             	pushl  -0x28(%ebp)
  800336:	e8 f5 23 00 00       	call   802730 <__umoddi3>
  80033b:	83 c4 14             	add    $0x14,%esp
  80033e:	0f be 80 9b 29 80 00 	movsbl 0x80299b(%eax),%eax
  800345:	50                   	push   %eax
  800346:	ff d7                	call   *%edi
}
  800348:	83 c4 10             	add    $0x10,%esp
  80034b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034e:	5b                   	pop    %ebx
  80034f:	5e                   	pop    %esi
  800350:	5f                   	pop    %edi
  800351:	5d                   	pop    %ebp
  800352:	c3                   	ret    

00800353 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800353:	55                   	push   %ebp
  800354:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800356:	83 fa 01             	cmp    $0x1,%edx
  800359:	7e 0e                	jle    800369 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80035b:	8b 10                	mov    (%eax),%edx
  80035d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800360:	89 08                	mov    %ecx,(%eax)
  800362:	8b 02                	mov    (%edx),%eax
  800364:	8b 52 04             	mov    0x4(%edx),%edx
  800367:	eb 22                	jmp    80038b <getuint+0x38>
	else if (lflag)
  800369:	85 d2                	test   %edx,%edx
  80036b:	74 10                	je     80037d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80036d:	8b 10                	mov    (%eax),%edx
  80036f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800372:	89 08                	mov    %ecx,(%eax)
  800374:	8b 02                	mov    (%edx),%eax
  800376:	ba 00 00 00 00       	mov    $0x0,%edx
  80037b:	eb 0e                	jmp    80038b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80037d:	8b 10                	mov    (%eax),%edx
  80037f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800382:	89 08                	mov    %ecx,(%eax)
  800384:	8b 02                	mov    (%edx),%eax
  800386:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80038b:	5d                   	pop    %ebp
  80038c:	c3                   	ret    

0080038d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80038d:	55                   	push   %ebp
  80038e:	89 e5                	mov    %esp,%ebp
  800390:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800393:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800397:	8b 10                	mov    (%eax),%edx
  800399:	3b 50 04             	cmp    0x4(%eax),%edx
  80039c:	73 0a                	jae    8003a8 <sprintputch+0x1b>
		*b->buf++ = ch;
  80039e:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003a1:	89 08                	mov    %ecx,(%eax)
  8003a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a6:	88 02                	mov    %al,(%edx)
}
  8003a8:	5d                   	pop    %ebp
  8003a9:	c3                   	ret    

008003aa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003aa:	55                   	push   %ebp
  8003ab:	89 e5                	mov    %esp,%ebp
  8003ad:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003b0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003b3:	50                   	push   %eax
  8003b4:	ff 75 10             	pushl  0x10(%ebp)
  8003b7:	ff 75 0c             	pushl  0xc(%ebp)
  8003ba:	ff 75 08             	pushl  0x8(%ebp)
  8003bd:	e8 05 00 00 00       	call   8003c7 <vprintfmt>
	va_end(ap);
}
  8003c2:	83 c4 10             	add    $0x10,%esp
  8003c5:	c9                   	leave  
  8003c6:	c3                   	ret    

008003c7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c7:	55                   	push   %ebp
  8003c8:	89 e5                	mov    %esp,%ebp
  8003ca:	57                   	push   %edi
  8003cb:	56                   	push   %esi
  8003cc:	53                   	push   %ebx
  8003cd:	83 ec 2c             	sub    $0x2c,%esp
  8003d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8003d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003d6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003d9:	eb 12                	jmp    8003ed <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	0f 84 89 03 00 00    	je     80076c <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003e3:	83 ec 08             	sub    $0x8,%esp
  8003e6:	53                   	push   %ebx
  8003e7:	50                   	push   %eax
  8003e8:	ff d6                	call   *%esi
  8003ea:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ed:	83 c7 01             	add    $0x1,%edi
  8003f0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003f4:	83 f8 25             	cmp    $0x25,%eax
  8003f7:	75 e2                	jne    8003db <vprintfmt+0x14>
  8003f9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003fd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800404:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80040b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800412:	ba 00 00 00 00       	mov    $0x0,%edx
  800417:	eb 07                	jmp    800420 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800419:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80041c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8d 47 01             	lea    0x1(%edi),%eax
  800423:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800426:	0f b6 07             	movzbl (%edi),%eax
  800429:	0f b6 c8             	movzbl %al,%ecx
  80042c:	83 e8 23             	sub    $0x23,%eax
  80042f:	3c 55                	cmp    $0x55,%al
  800431:	0f 87 1a 03 00 00    	ja     800751 <vprintfmt+0x38a>
  800437:	0f b6 c0             	movzbl %al,%eax
  80043a:	ff 24 85 e0 2a 80 00 	jmp    *0x802ae0(,%eax,4)
  800441:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800444:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800448:	eb d6                	jmp    800420 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80044d:	b8 00 00 00 00       	mov    $0x0,%eax
  800452:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800455:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800458:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80045c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80045f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800462:	83 fa 09             	cmp    $0x9,%edx
  800465:	77 39                	ja     8004a0 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800467:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80046a:	eb e9                	jmp    800455 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80046c:	8b 45 14             	mov    0x14(%ebp),%eax
  80046f:	8d 48 04             	lea    0x4(%eax),%ecx
  800472:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800475:	8b 00                	mov    (%eax),%eax
  800477:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80047d:	eb 27                	jmp    8004a6 <vprintfmt+0xdf>
  80047f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800482:	85 c0                	test   %eax,%eax
  800484:	b9 00 00 00 00       	mov    $0x0,%ecx
  800489:	0f 49 c8             	cmovns %eax,%ecx
  80048c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800492:	eb 8c                	jmp    800420 <vprintfmt+0x59>
  800494:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800497:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80049e:	eb 80                	jmp    800420 <vprintfmt+0x59>
  8004a0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004a3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004a6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004aa:	0f 89 70 ff ff ff    	jns    800420 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004b0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004bd:	e9 5e ff ff ff       	jmp    800420 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004c2:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004c8:	e9 53 ff ff ff       	jmp    800420 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d0:	8d 50 04             	lea    0x4(%eax),%edx
  8004d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d6:	83 ec 08             	sub    $0x8,%esp
  8004d9:	53                   	push   %ebx
  8004da:	ff 30                	pushl  (%eax)
  8004dc:	ff d6                	call   *%esi
			break;
  8004de:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004e4:	e9 04 ff ff ff       	jmp    8003ed <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ec:	8d 50 04             	lea    0x4(%eax),%edx
  8004ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f2:	8b 00                	mov    (%eax),%eax
  8004f4:	99                   	cltd   
  8004f5:	31 d0                	xor    %edx,%eax
  8004f7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f9:	83 f8 0f             	cmp    $0xf,%eax
  8004fc:	7f 0b                	jg     800509 <vprintfmt+0x142>
  8004fe:	8b 14 85 40 2c 80 00 	mov    0x802c40(,%eax,4),%edx
  800505:	85 d2                	test   %edx,%edx
  800507:	75 18                	jne    800521 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800509:	50                   	push   %eax
  80050a:	68 b3 29 80 00       	push   $0x8029b3
  80050f:	53                   	push   %ebx
  800510:	56                   	push   %esi
  800511:	e8 94 fe ff ff       	call   8003aa <printfmt>
  800516:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800519:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80051c:	e9 cc fe ff ff       	jmp    8003ed <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800521:	52                   	push   %edx
  800522:	68 ed 2d 80 00       	push   $0x802ded
  800527:	53                   	push   %ebx
  800528:	56                   	push   %esi
  800529:	e8 7c fe ff ff       	call   8003aa <printfmt>
  80052e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800531:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800534:	e9 b4 fe ff ff       	jmp    8003ed <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800539:	8b 45 14             	mov    0x14(%ebp),%eax
  80053c:	8d 50 04             	lea    0x4(%eax),%edx
  80053f:	89 55 14             	mov    %edx,0x14(%ebp)
  800542:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800544:	85 ff                	test   %edi,%edi
  800546:	b8 ac 29 80 00       	mov    $0x8029ac,%eax
  80054b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80054e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800552:	0f 8e 94 00 00 00    	jle    8005ec <vprintfmt+0x225>
  800558:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80055c:	0f 84 98 00 00 00    	je     8005fa <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800562:	83 ec 08             	sub    $0x8,%esp
  800565:	ff 75 d0             	pushl  -0x30(%ebp)
  800568:	57                   	push   %edi
  800569:	e8 86 02 00 00       	call   8007f4 <strnlen>
  80056e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800571:	29 c1                	sub    %eax,%ecx
  800573:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800576:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800579:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80057d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800580:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800583:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800585:	eb 0f                	jmp    800596 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800587:	83 ec 08             	sub    $0x8,%esp
  80058a:	53                   	push   %ebx
  80058b:	ff 75 e0             	pushl  -0x20(%ebp)
  80058e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800590:	83 ef 01             	sub    $0x1,%edi
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	85 ff                	test   %edi,%edi
  800598:	7f ed                	jg     800587 <vprintfmt+0x1c0>
  80059a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80059d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005a0:	85 c9                	test   %ecx,%ecx
  8005a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a7:	0f 49 c1             	cmovns %ecx,%eax
  8005aa:	29 c1                	sub    %eax,%ecx
  8005ac:	89 75 08             	mov    %esi,0x8(%ebp)
  8005af:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005b2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005b5:	89 cb                	mov    %ecx,%ebx
  8005b7:	eb 4d                	jmp    800606 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005bd:	74 1b                	je     8005da <vprintfmt+0x213>
  8005bf:	0f be c0             	movsbl %al,%eax
  8005c2:	83 e8 20             	sub    $0x20,%eax
  8005c5:	83 f8 5e             	cmp    $0x5e,%eax
  8005c8:	76 10                	jbe    8005da <vprintfmt+0x213>
					putch('?', putdat);
  8005ca:	83 ec 08             	sub    $0x8,%esp
  8005cd:	ff 75 0c             	pushl  0xc(%ebp)
  8005d0:	6a 3f                	push   $0x3f
  8005d2:	ff 55 08             	call   *0x8(%ebp)
  8005d5:	83 c4 10             	add    $0x10,%esp
  8005d8:	eb 0d                	jmp    8005e7 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005da:	83 ec 08             	sub    $0x8,%esp
  8005dd:	ff 75 0c             	pushl  0xc(%ebp)
  8005e0:	52                   	push   %edx
  8005e1:	ff 55 08             	call   *0x8(%ebp)
  8005e4:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e7:	83 eb 01             	sub    $0x1,%ebx
  8005ea:	eb 1a                	jmp    800606 <vprintfmt+0x23f>
  8005ec:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ef:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005f2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005f8:	eb 0c                	jmp    800606 <vprintfmt+0x23f>
  8005fa:	89 75 08             	mov    %esi,0x8(%ebp)
  8005fd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800600:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800603:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800606:	83 c7 01             	add    $0x1,%edi
  800609:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80060d:	0f be d0             	movsbl %al,%edx
  800610:	85 d2                	test   %edx,%edx
  800612:	74 23                	je     800637 <vprintfmt+0x270>
  800614:	85 f6                	test   %esi,%esi
  800616:	78 a1                	js     8005b9 <vprintfmt+0x1f2>
  800618:	83 ee 01             	sub    $0x1,%esi
  80061b:	79 9c                	jns    8005b9 <vprintfmt+0x1f2>
  80061d:	89 df                	mov    %ebx,%edi
  80061f:	8b 75 08             	mov    0x8(%ebp),%esi
  800622:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800625:	eb 18                	jmp    80063f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800627:	83 ec 08             	sub    $0x8,%esp
  80062a:	53                   	push   %ebx
  80062b:	6a 20                	push   $0x20
  80062d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80062f:	83 ef 01             	sub    $0x1,%edi
  800632:	83 c4 10             	add    $0x10,%esp
  800635:	eb 08                	jmp    80063f <vprintfmt+0x278>
  800637:	89 df                	mov    %ebx,%edi
  800639:	8b 75 08             	mov    0x8(%ebp),%esi
  80063c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80063f:	85 ff                	test   %edi,%edi
  800641:	7f e4                	jg     800627 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800643:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800646:	e9 a2 fd ff ff       	jmp    8003ed <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80064b:	83 fa 01             	cmp    $0x1,%edx
  80064e:	7e 16                	jle    800666 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8d 50 08             	lea    0x8(%eax),%edx
  800656:	89 55 14             	mov    %edx,0x14(%ebp)
  800659:	8b 50 04             	mov    0x4(%eax),%edx
  80065c:	8b 00                	mov    (%eax),%eax
  80065e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800661:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800664:	eb 32                	jmp    800698 <vprintfmt+0x2d1>
	else if (lflag)
  800666:	85 d2                	test   %edx,%edx
  800668:	74 18                	je     800682 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8d 50 04             	lea    0x4(%eax),%edx
  800670:	89 55 14             	mov    %edx,0x14(%ebp)
  800673:	8b 00                	mov    (%eax),%eax
  800675:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800678:	89 c1                	mov    %eax,%ecx
  80067a:	c1 f9 1f             	sar    $0x1f,%ecx
  80067d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800680:	eb 16                	jmp    800698 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8d 50 04             	lea    0x4(%eax),%edx
  800688:	89 55 14             	mov    %edx,0x14(%ebp)
  80068b:	8b 00                	mov    (%eax),%eax
  80068d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800690:	89 c1                	mov    %eax,%ecx
  800692:	c1 f9 1f             	sar    $0x1f,%ecx
  800695:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800698:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80069b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80069e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006a3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006a7:	79 74                	jns    80071d <vprintfmt+0x356>
				putch('-', putdat);
  8006a9:	83 ec 08             	sub    $0x8,%esp
  8006ac:	53                   	push   %ebx
  8006ad:	6a 2d                	push   $0x2d
  8006af:	ff d6                	call   *%esi
				num = -(long long) num;
  8006b1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006b4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006b7:	f7 d8                	neg    %eax
  8006b9:	83 d2 00             	adc    $0x0,%edx
  8006bc:	f7 da                	neg    %edx
  8006be:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006c1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006c6:	eb 55                	jmp    80071d <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006c8:	8d 45 14             	lea    0x14(%ebp),%eax
  8006cb:	e8 83 fc ff ff       	call   800353 <getuint>
			base = 10;
  8006d0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006d5:	eb 46                	jmp    80071d <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006da:	e8 74 fc ff ff       	call   800353 <getuint>
			base = 8;
  8006df:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006e4:	eb 37                	jmp    80071d <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8006e6:	83 ec 08             	sub    $0x8,%esp
  8006e9:	53                   	push   %ebx
  8006ea:	6a 30                	push   $0x30
  8006ec:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ee:	83 c4 08             	add    $0x8,%esp
  8006f1:	53                   	push   %ebx
  8006f2:	6a 78                	push   $0x78
  8006f4:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f9:	8d 50 04             	lea    0x4(%eax),%edx
  8006fc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006ff:	8b 00                	mov    (%eax),%eax
  800701:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800706:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800709:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80070e:	eb 0d                	jmp    80071d <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800710:	8d 45 14             	lea    0x14(%ebp),%eax
  800713:	e8 3b fc ff ff       	call   800353 <getuint>
			base = 16;
  800718:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80071d:	83 ec 0c             	sub    $0xc,%esp
  800720:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800724:	57                   	push   %edi
  800725:	ff 75 e0             	pushl  -0x20(%ebp)
  800728:	51                   	push   %ecx
  800729:	52                   	push   %edx
  80072a:	50                   	push   %eax
  80072b:	89 da                	mov    %ebx,%edx
  80072d:	89 f0                	mov    %esi,%eax
  80072f:	e8 70 fb ff ff       	call   8002a4 <printnum>
			break;
  800734:	83 c4 20             	add    $0x20,%esp
  800737:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80073a:	e9 ae fc ff ff       	jmp    8003ed <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80073f:	83 ec 08             	sub    $0x8,%esp
  800742:	53                   	push   %ebx
  800743:	51                   	push   %ecx
  800744:	ff d6                	call   *%esi
			break;
  800746:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800749:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80074c:	e9 9c fc ff ff       	jmp    8003ed <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800751:	83 ec 08             	sub    $0x8,%esp
  800754:	53                   	push   %ebx
  800755:	6a 25                	push   $0x25
  800757:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	eb 03                	jmp    800761 <vprintfmt+0x39a>
  80075e:	83 ef 01             	sub    $0x1,%edi
  800761:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800765:	75 f7                	jne    80075e <vprintfmt+0x397>
  800767:	e9 81 fc ff ff       	jmp    8003ed <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80076c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076f:	5b                   	pop    %ebx
  800770:	5e                   	pop    %esi
  800771:	5f                   	pop    %edi
  800772:	5d                   	pop    %ebp
  800773:	c3                   	ret    

00800774 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	83 ec 18             	sub    $0x18,%esp
  80077a:	8b 45 08             	mov    0x8(%ebp),%eax
  80077d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800780:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800783:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800787:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80078a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800791:	85 c0                	test   %eax,%eax
  800793:	74 26                	je     8007bb <vsnprintf+0x47>
  800795:	85 d2                	test   %edx,%edx
  800797:	7e 22                	jle    8007bb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800799:	ff 75 14             	pushl  0x14(%ebp)
  80079c:	ff 75 10             	pushl  0x10(%ebp)
  80079f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a2:	50                   	push   %eax
  8007a3:	68 8d 03 80 00       	push   $0x80038d
  8007a8:	e8 1a fc ff ff       	call   8003c7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b6:	83 c4 10             	add    $0x10,%esp
  8007b9:	eb 05                	jmp    8007c0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007c0:	c9                   	leave  
  8007c1:	c3                   	ret    

008007c2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007cb:	50                   	push   %eax
  8007cc:	ff 75 10             	pushl  0x10(%ebp)
  8007cf:	ff 75 0c             	pushl  0xc(%ebp)
  8007d2:	ff 75 08             	pushl  0x8(%ebp)
  8007d5:	e8 9a ff ff ff       	call   800774 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007da:	c9                   	leave  
  8007db:	c3                   	ret    

008007dc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e7:	eb 03                	jmp    8007ec <strlen+0x10>
		n++;
  8007e9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ec:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f0:	75 f7                	jne    8007e9 <strlen+0xd>
		n++;
	return n;
}
  8007f2:	5d                   	pop    %ebp
  8007f3:	c3                   	ret    

008007f4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007fa:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800802:	eb 03                	jmp    800807 <strnlen+0x13>
		n++;
  800804:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800807:	39 c2                	cmp    %eax,%edx
  800809:	74 08                	je     800813 <strnlen+0x1f>
  80080b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80080f:	75 f3                	jne    800804 <strnlen+0x10>
  800811:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	53                   	push   %ebx
  800819:	8b 45 08             	mov    0x8(%ebp),%eax
  80081c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80081f:	89 c2                	mov    %eax,%edx
  800821:	83 c2 01             	add    $0x1,%edx
  800824:	83 c1 01             	add    $0x1,%ecx
  800827:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80082b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80082e:	84 db                	test   %bl,%bl
  800830:	75 ef                	jne    800821 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800832:	5b                   	pop    %ebx
  800833:	5d                   	pop    %ebp
  800834:	c3                   	ret    

00800835 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	53                   	push   %ebx
  800839:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80083c:	53                   	push   %ebx
  80083d:	e8 9a ff ff ff       	call   8007dc <strlen>
  800842:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800845:	ff 75 0c             	pushl  0xc(%ebp)
  800848:	01 d8                	add    %ebx,%eax
  80084a:	50                   	push   %eax
  80084b:	e8 c5 ff ff ff       	call   800815 <strcpy>
	return dst;
}
  800850:	89 d8                	mov    %ebx,%eax
  800852:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800855:	c9                   	leave  
  800856:	c3                   	ret    

00800857 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	56                   	push   %esi
  80085b:	53                   	push   %ebx
  80085c:	8b 75 08             	mov    0x8(%ebp),%esi
  80085f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800862:	89 f3                	mov    %esi,%ebx
  800864:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800867:	89 f2                	mov    %esi,%edx
  800869:	eb 0f                	jmp    80087a <strncpy+0x23>
		*dst++ = *src;
  80086b:	83 c2 01             	add    $0x1,%edx
  80086e:	0f b6 01             	movzbl (%ecx),%eax
  800871:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800874:	80 39 01             	cmpb   $0x1,(%ecx)
  800877:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80087a:	39 da                	cmp    %ebx,%edx
  80087c:	75 ed                	jne    80086b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80087e:	89 f0                	mov    %esi,%eax
  800880:	5b                   	pop    %ebx
  800881:	5e                   	pop    %esi
  800882:	5d                   	pop    %ebp
  800883:	c3                   	ret    

00800884 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	56                   	push   %esi
  800888:	53                   	push   %ebx
  800889:	8b 75 08             	mov    0x8(%ebp),%esi
  80088c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088f:	8b 55 10             	mov    0x10(%ebp),%edx
  800892:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800894:	85 d2                	test   %edx,%edx
  800896:	74 21                	je     8008b9 <strlcpy+0x35>
  800898:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80089c:	89 f2                	mov    %esi,%edx
  80089e:	eb 09                	jmp    8008a9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008a0:	83 c2 01             	add    $0x1,%edx
  8008a3:	83 c1 01             	add    $0x1,%ecx
  8008a6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a9:	39 c2                	cmp    %eax,%edx
  8008ab:	74 09                	je     8008b6 <strlcpy+0x32>
  8008ad:	0f b6 19             	movzbl (%ecx),%ebx
  8008b0:	84 db                	test   %bl,%bl
  8008b2:	75 ec                	jne    8008a0 <strlcpy+0x1c>
  8008b4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008b6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b9:	29 f0                	sub    %esi,%eax
}
  8008bb:	5b                   	pop    %ebx
  8008bc:	5e                   	pop    %esi
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c8:	eb 06                	jmp    8008d0 <strcmp+0x11>
		p++, q++;
  8008ca:	83 c1 01             	add    $0x1,%ecx
  8008cd:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008d0:	0f b6 01             	movzbl (%ecx),%eax
  8008d3:	84 c0                	test   %al,%al
  8008d5:	74 04                	je     8008db <strcmp+0x1c>
  8008d7:	3a 02                	cmp    (%edx),%al
  8008d9:	74 ef                	je     8008ca <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008db:	0f b6 c0             	movzbl %al,%eax
  8008de:	0f b6 12             	movzbl (%edx),%edx
  8008e1:	29 d0                	sub    %edx,%eax
}
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    

008008e5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	53                   	push   %ebx
  8008e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ef:	89 c3                	mov    %eax,%ebx
  8008f1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008f4:	eb 06                	jmp    8008fc <strncmp+0x17>
		n--, p++, q++;
  8008f6:	83 c0 01             	add    $0x1,%eax
  8008f9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008fc:	39 d8                	cmp    %ebx,%eax
  8008fe:	74 15                	je     800915 <strncmp+0x30>
  800900:	0f b6 08             	movzbl (%eax),%ecx
  800903:	84 c9                	test   %cl,%cl
  800905:	74 04                	je     80090b <strncmp+0x26>
  800907:	3a 0a                	cmp    (%edx),%cl
  800909:	74 eb                	je     8008f6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80090b:	0f b6 00             	movzbl (%eax),%eax
  80090e:	0f b6 12             	movzbl (%edx),%edx
  800911:	29 d0                	sub    %edx,%eax
  800913:	eb 05                	jmp    80091a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800915:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80091a:	5b                   	pop    %ebx
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
  800923:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800927:	eb 07                	jmp    800930 <strchr+0x13>
		if (*s == c)
  800929:	38 ca                	cmp    %cl,%dl
  80092b:	74 0f                	je     80093c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80092d:	83 c0 01             	add    $0x1,%eax
  800930:	0f b6 10             	movzbl (%eax),%edx
  800933:	84 d2                	test   %dl,%dl
  800935:	75 f2                	jne    800929 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800937:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	8b 45 08             	mov    0x8(%ebp),%eax
  800944:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800948:	eb 03                	jmp    80094d <strfind+0xf>
  80094a:	83 c0 01             	add    $0x1,%eax
  80094d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800950:	38 ca                	cmp    %cl,%dl
  800952:	74 04                	je     800958 <strfind+0x1a>
  800954:	84 d2                	test   %dl,%dl
  800956:	75 f2                	jne    80094a <strfind+0xc>
			break;
	return (char *) s;
}
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	57                   	push   %edi
  80095e:	56                   	push   %esi
  80095f:	53                   	push   %ebx
  800960:	8b 7d 08             	mov    0x8(%ebp),%edi
  800963:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800966:	85 c9                	test   %ecx,%ecx
  800968:	74 36                	je     8009a0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80096a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800970:	75 28                	jne    80099a <memset+0x40>
  800972:	f6 c1 03             	test   $0x3,%cl
  800975:	75 23                	jne    80099a <memset+0x40>
		c &= 0xFF;
  800977:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80097b:	89 d3                	mov    %edx,%ebx
  80097d:	c1 e3 08             	shl    $0x8,%ebx
  800980:	89 d6                	mov    %edx,%esi
  800982:	c1 e6 18             	shl    $0x18,%esi
  800985:	89 d0                	mov    %edx,%eax
  800987:	c1 e0 10             	shl    $0x10,%eax
  80098a:	09 f0                	or     %esi,%eax
  80098c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80098e:	89 d8                	mov    %ebx,%eax
  800990:	09 d0                	or     %edx,%eax
  800992:	c1 e9 02             	shr    $0x2,%ecx
  800995:	fc                   	cld    
  800996:	f3 ab                	rep stos %eax,%es:(%edi)
  800998:	eb 06                	jmp    8009a0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80099a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099d:	fc                   	cld    
  80099e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009a0:	89 f8                	mov    %edi,%eax
  8009a2:	5b                   	pop    %ebx
  8009a3:	5e                   	pop    %esi
  8009a4:	5f                   	pop    %edi
  8009a5:	5d                   	pop    %ebp
  8009a6:	c3                   	ret    

008009a7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	57                   	push   %edi
  8009ab:	56                   	push   %esi
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b5:	39 c6                	cmp    %eax,%esi
  8009b7:	73 35                	jae    8009ee <memmove+0x47>
  8009b9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009bc:	39 d0                	cmp    %edx,%eax
  8009be:	73 2e                	jae    8009ee <memmove+0x47>
		s += n;
		d += n;
  8009c0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c3:	89 d6                	mov    %edx,%esi
  8009c5:	09 fe                	or     %edi,%esi
  8009c7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009cd:	75 13                	jne    8009e2 <memmove+0x3b>
  8009cf:	f6 c1 03             	test   $0x3,%cl
  8009d2:	75 0e                	jne    8009e2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009d4:	83 ef 04             	sub    $0x4,%edi
  8009d7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009da:	c1 e9 02             	shr    $0x2,%ecx
  8009dd:	fd                   	std    
  8009de:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e0:	eb 09                	jmp    8009eb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009e2:	83 ef 01             	sub    $0x1,%edi
  8009e5:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009e8:	fd                   	std    
  8009e9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009eb:	fc                   	cld    
  8009ec:	eb 1d                	jmp    800a0b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ee:	89 f2                	mov    %esi,%edx
  8009f0:	09 c2                	or     %eax,%edx
  8009f2:	f6 c2 03             	test   $0x3,%dl
  8009f5:	75 0f                	jne    800a06 <memmove+0x5f>
  8009f7:	f6 c1 03             	test   $0x3,%cl
  8009fa:	75 0a                	jne    800a06 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009fc:	c1 e9 02             	shr    $0x2,%ecx
  8009ff:	89 c7                	mov    %eax,%edi
  800a01:	fc                   	cld    
  800a02:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a04:	eb 05                	jmp    800a0b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a06:	89 c7                	mov    %eax,%edi
  800a08:	fc                   	cld    
  800a09:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a0b:	5e                   	pop    %esi
  800a0c:	5f                   	pop    %edi
  800a0d:	5d                   	pop    %ebp
  800a0e:	c3                   	ret    

00800a0f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a12:	ff 75 10             	pushl  0x10(%ebp)
  800a15:	ff 75 0c             	pushl  0xc(%ebp)
  800a18:	ff 75 08             	pushl  0x8(%ebp)
  800a1b:	e8 87 ff ff ff       	call   8009a7 <memmove>
}
  800a20:	c9                   	leave  
  800a21:	c3                   	ret    

00800a22 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	56                   	push   %esi
  800a26:	53                   	push   %ebx
  800a27:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2d:	89 c6                	mov    %eax,%esi
  800a2f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a32:	eb 1a                	jmp    800a4e <memcmp+0x2c>
		if (*s1 != *s2)
  800a34:	0f b6 08             	movzbl (%eax),%ecx
  800a37:	0f b6 1a             	movzbl (%edx),%ebx
  800a3a:	38 d9                	cmp    %bl,%cl
  800a3c:	74 0a                	je     800a48 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a3e:	0f b6 c1             	movzbl %cl,%eax
  800a41:	0f b6 db             	movzbl %bl,%ebx
  800a44:	29 d8                	sub    %ebx,%eax
  800a46:	eb 0f                	jmp    800a57 <memcmp+0x35>
		s1++, s2++;
  800a48:	83 c0 01             	add    $0x1,%eax
  800a4b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4e:	39 f0                	cmp    %esi,%eax
  800a50:	75 e2                	jne    800a34 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a52:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a57:	5b                   	pop    %ebx
  800a58:	5e                   	pop    %esi
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	53                   	push   %ebx
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a62:	89 c1                	mov    %eax,%ecx
  800a64:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a67:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a6b:	eb 0a                	jmp    800a77 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a6d:	0f b6 10             	movzbl (%eax),%edx
  800a70:	39 da                	cmp    %ebx,%edx
  800a72:	74 07                	je     800a7b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a74:	83 c0 01             	add    $0x1,%eax
  800a77:	39 c8                	cmp    %ecx,%eax
  800a79:	72 f2                	jb     800a6d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a7b:	5b                   	pop    %ebx
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	57                   	push   %edi
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
  800a84:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8a:	eb 03                	jmp    800a8f <strtol+0x11>
		s++;
  800a8c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8f:	0f b6 01             	movzbl (%ecx),%eax
  800a92:	3c 20                	cmp    $0x20,%al
  800a94:	74 f6                	je     800a8c <strtol+0xe>
  800a96:	3c 09                	cmp    $0x9,%al
  800a98:	74 f2                	je     800a8c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a9a:	3c 2b                	cmp    $0x2b,%al
  800a9c:	75 0a                	jne    800aa8 <strtol+0x2a>
		s++;
  800a9e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa1:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa6:	eb 11                	jmp    800ab9 <strtol+0x3b>
  800aa8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aad:	3c 2d                	cmp    $0x2d,%al
  800aaf:	75 08                	jne    800ab9 <strtol+0x3b>
		s++, neg = 1;
  800ab1:	83 c1 01             	add    $0x1,%ecx
  800ab4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800abf:	75 15                	jne    800ad6 <strtol+0x58>
  800ac1:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac4:	75 10                	jne    800ad6 <strtol+0x58>
  800ac6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aca:	75 7c                	jne    800b48 <strtol+0xca>
		s += 2, base = 16;
  800acc:	83 c1 02             	add    $0x2,%ecx
  800acf:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad4:	eb 16                	jmp    800aec <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ad6:	85 db                	test   %ebx,%ebx
  800ad8:	75 12                	jne    800aec <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ada:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800adf:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae2:	75 08                	jne    800aec <strtol+0x6e>
		s++, base = 8;
  800ae4:	83 c1 01             	add    $0x1,%ecx
  800ae7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aec:	b8 00 00 00 00       	mov    $0x0,%eax
  800af1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af4:	0f b6 11             	movzbl (%ecx),%edx
  800af7:	8d 72 d0             	lea    -0x30(%edx),%esi
  800afa:	89 f3                	mov    %esi,%ebx
  800afc:	80 fb 09             	cmp    $0x9,%bl
  800aff:	77 08                	ja     800b09 <strtol+0x8b>
			dig = *s - '0';
  800b01:	0f be d2             	movsbl %dl,%edx
  800b04:	83 ea 30             	sub    $0x30,%edx
  800b07:	eb 22                	jmp    800b2b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b09:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b0c:	89 f3                	mov    %esi,%ebx
  800b0e:	80 fb 19             	cmp    $0x19,%bl
  800b11:	77 08                	ja     800b1b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b13:	0f be d2             	movsbl %dl,%edx
  800b16:	83 ea 57             	sub    $0x57,%edx
  800b19:	eb 10                	jmp    800b2b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b1b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b1e:	89 f3                	mov    %esi,%ebx
  800b20:	80 fb 19             	cmp    $0x19,%bl
  800b23:	77 16                	ja     800b3b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b25:	0f be d2             	movsbl %dl,%edx
  800b28:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b2b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b2e:	7d 0b                	jge    800b3b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b30:	83 c1 01             	add    $0x1,%ecx
  800b33:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b37:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b39:	eb b9                	jmp    800af4 <strtol+0x76>

	if (endptr)
  800b3b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b3f:	74 0d                	je     800b4e <strtol+0xd0>
		*endptr = (char *) s;
  800b41:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b44:	89 0e                	mov    %ecx,(%esi)
  800b46:	eb 06                	jmp    800b4e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b48:	85 db                	test   %ebx,%ebx
  800b4a:	74 98                	je     800ae4 <strtol+0x66>
  800b4c:	eb 9e                	jmp    800aec <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b4e:	89 c2                	mov    %eax,%edx
  800b50:	f7 da                	neg    %edx
  800b52:	85 ff                	test   %edi,%edi
  800b54:	0f 45 c2             	cmovne %edx,%eax
}
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b62:	b8 00 00 00 00       	mov    $0x0,%eax
  800b67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6d:	89 c3                	mov    %eax,%ebx
  800b6f:	89 c7                	mov    %eax,%edi
  800b71:	89 c6                	mov    %eax,%esi
  800b73:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b75:	5b                   	pop    %ebx
  800b76:	5e                   	pop    %esi
  800b77:	5f                   	pop    %edi
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	57                   	push   %edi
  800b7e:	56                   	push   %esi
  800b7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b80:	ba 00 00 00 00       	mov    $0x0,%edx
  800b85:	b8 01 00 00 00       	mov    $0x1,%eax
  800b8a:	89 d1                	mov    %edx,%ecx
  800b8c:	89 d3                	mov    %edx,%ebx
  800b8e:	89 d7                	mov    %edx,%edi
  800b90:	89 d6                	mov    %edx,%esi
  800b92:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b94:	5b                   	pop    %ebx
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    

00800b99 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	57                   	push   %edi
  800b9d:	56                   	push   %esi
  800b9e:	53                   	push   %ebx
  800b9f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba7:	b8 03 00 00 00       	mov    $0x3,%eax
  800bac:	8b 55 08             	mov    0x8(%ebp),%edx
  800baf:	89 cb                	mov    %ecx,%ebx
  800bb1:	89 cf                	mov    %ecx,%edi
  800bb3:	89 ce                	mov    %ecx,%esi
  800bb5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb7:	85 c0                	test   %eax,%eax
  800bb9:	7e 17                	jle    800bd2 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbb:	83 ec 0c             	sub    $0xc,%esp
  800bbe:	50                   	push   %eax
  800bbf:	6a 03                	push   $0x3
  800bc1:	68 9f 2c 80 00       	push   $0x802c9f
  800bc6:	6a 23                	push   $0x23
  800bc8:	68 bc 2c 80 00       	push   $0x802cbc
  800bcd:	e8 e5 f5 ff ff       	call   8001b7 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5f                   	pop    %edi
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	57                   	push   %edi
  800bde:	56                   	push   %esi
  800bdf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be0:	ba 00 00 00 00       	mov    $0x0,%edx
  800be5:	b8 02 00 00 00       	mov    $0x2,%eax
  800bea:	89 d1                	mov    %edx,%ecx
  800bec:	89 d3                	mov    %edx,%ebx
  800bee:	89 d7                	mov    %edx,%edi
  800bf0:	89 d6                	mov    %edx,%esi
  800bf2:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <sys_yield>:

void
sys_yield(void)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bff:	ba 00 00 00 00       	mov    $0x0,%edx
  800c04:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c09:	89 d1                	mov    %edx,%ecx
  800c0b:	89 d3                	mov    %edx,%ebx
  800c0d:	89 d7                	mov    %edx,%edi
  800c0f:	89 d6                	mov    %edx,%esi
  800c11:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5f                   	pop    %edi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	57                   	push   %edi
  800c1c:	56                   	push   %esi
  800c1d:	53                   	push   %ebx
  800c1e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c21:	be 00 00 00 00       	mov    $0x0,%esi
  800c26:	b8 04 00 00 00       	mov    $0x4,%eax
  800c2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c31:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c34:	89 f7                	mov    %esi,%edi
  800c36:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c38:	85 c0                	test   %eax,%eax
  800c3a:	7e 17                	jle    800c53 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3c:	83 ec 0c             	sub    $0xc,%esp
  800c3f:	50                   	push   %eax
  800c40:	6a 04                	push   $0x4
  800c42:	68 9f 2c 80 00       	push   $0x802c9f
  800c47:	6a 23                	push   $0x23
  800c49:	68 bc 2c 80 00       	push   $0x802cbc
  800c4e:	e8 64 f5 ff ff       	call   8001b7 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	57                   	push   %edi
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
  800c61:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c64:	b8 05 00 00 00       	mov    $0x5,%eax
  800c69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c72:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c75:	8b 75 18             	mov    0x18(%ebp),%esi
  800c78:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7a:	85 c0                	test   %eax,%eax
  800c7c:	7e 17                	jle    800c95 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7e:	83 ec 0c             	sub    $0xc,%esp
  800c81:	50                   	push   %eax
  800c82:	6a 05                	push   $0x5
  800c84:	68 9f 2c 80 00       	push   $0x802c9f
  800c89:	6a 23                	push   $0x23
  800c8b:	68 bc 2c 80 00       	push   $0x802cbc
  800c90:	e8 22 f5 ff ff       	call   8001b7 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c98:	5b                   	pop    %ebx
  800c99:	5e                   	pop    %esi
  800c9a:	5f                   	pop    %edi
  800c9b:	5d                   	pop    %ebp
  800c9c:	c3                   	ret    

00800c9d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	57                   	push   %edi
  800ca1:	56                   	push   %esi
  800ca2:	53                   	push   %ebx
  800ca3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cab:	b8 06 00 00 00       	mov    $0x6,%eax
  800cb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb6:	89 df                	mov    %ebx,%edi
  800cb8:	89 de                	mov    %ebx,%esi
  800cba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbc:	85 c0                	test   %eax,%eax
  800cbe:	7e 17                	jle    800cd7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc0:	83 ec 0c             	sub    $0xc,%esp
  800cc3:	50                   	push   %eax
  800cc4:	6a 06                	push   $0x6
  800cc6:	68 9f 2c 80 00       	push   $0x802c9f
  800ccb:	6a 23                	push   $0x23
  800ccd:	68 bc 2c 80 00       	push   $0x802cbc
  800cd2:	e8 e0 f4 ff ff       	call   8001b7 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	57                   	push   %edi
  800ce3:	56                   	push   %esi
  800ce4:	53                   	push   %ebx
  800ce5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ced:	b8 08 00 00 00       	mov    $0x8,%eax
  800cf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf8:	89 df                	mov    %ebx,%edi
  800cfa:	89 de                	mov    %ebx,%esi
  800cfc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	7e 17                	jle    800d19 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	50                   	push   %eax
  800d06:	6a 08                	push   $0x8
  800d08:	68 9f 2c 80 00       	push   $0x802c9f
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 bc 2c 80 00       	push   $0x802cbc
  800d14:	e8 9e f4 ff ff       	call   8001b7 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	57                   	push   %edi
  800d25:	56                   	push   %esi
  800d26:	53                   	push   %ebx
  800d27:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2f:	b8 09 00 00 00       	mov    $0x9,%eax
  800d34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d37:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3a:	89 df                	mov    %ebx,%edi
  800d3c:	89 de                	mov    %ebx,%esi
  800d3e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d40:	85 c0                	test   %eax,%eax
  800d42:	7e 17                	jle    800d5b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d44:	83 ec 0c             	sub    $0xc,%esp
  800d47:	50                   	push   %eax
  800d48:	6a 09                	push   $0x9
  800d4a:	68 9f 2c 80 00       	push   $0x802c9f
  800d4f:	6a 23                	push   $0x23
  800d51:	68 bc 2c 80 00       	push   $0x802cbc
  800d56:	e8 5c f4 ff ff       	call   8001b7 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	57                   	push   %edi
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
  800d69:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d71:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	89 df                	mov    %ebx,%edi
  800d7e:	89 de                	mov    %ebx,%esi
  800d80:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d82:	85 c0                	test   %eax,%eax
  800d84:	7e 17                	jle    800d9d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d86:	83 ec 0c             	sub    $0xc,%esp
  800d89:	50                   	push   %eax
  800d8a:	6a 0a                	push   $0xa
  800d8c:	68 9f 2c 80 00       	push   $0x802c9f
  800d91:	6a 23                	push   $0x23
  800d93:	68 bc 2c 80 00       	push   $0x802cbc
  800d98:	e8 1a f4 ff ff       	call   8001b7 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	57                   	push   %edi
  800da9:	56                   	push   %esi
  800daa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dab:	be 00 00 00 00       	mov    $0x0,%esi
  800db0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800db5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dbe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dc1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
  800dce:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd6:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ddb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dde:	89 cb                	mov    %ecx,%ebx
  800de0:	89 cf                	mov    %ecx,%edi
  800de2:	89 ce                	mov    %ecx,%esi
  800de4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de6:	85 c0                	test   %eax,%eax
  800de8:	7e 17                	jle    800e01 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dea:	83 ec 0c             	sub    $0xc,%esp
  800ded:	50                   	push   %eax
  800dee:	6a 0d                	push   $0xd
  800df0:	68 9f 2c 80 00       	push   $0x802c9f
  800df5:	6a 23                	push   $0x23
  800df7:	68 bc 2c 80 00       	push   $0x802cbc
  800dfc:	e8 b6 f3 ff ff       	call   8001b7 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e04:	5b                   	pop    %ebx
  800e05:	5e                   	pop    %esi
  800e06:	5f                   	pop    %edi
  800e07:	5d                   	pop    %ebp
  800e08:	c3                   	ret    

00800e09 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	57                   	push   %edi
  800e0d:	56                   	push   %esi
  800e0e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e14:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e19:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1c:	89 cb                	mov    %ecx,%ebx
  800e1e:	89 cf                	mov    %ecx,%edi
  800e20:	89 ce                	mov    %ecx,%esi
  800e22:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e34:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e39:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3c:	89 cb                	mov    %ecx,%ebx
  800e3e:	89 cf                	mov    %ecx,%edi
  800e40:	89 ce                	mov    %ecx,%esi
  800e42:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800e44:	5b                   	pop    %ebx
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	53                   	push   %ebx
  800e4d:	83 ec 04             	sub    $0x4,%esp
  800e50:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e53:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800e55:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e59:	74 11                	je     800e6c <pgfault+0x23>
  800e5b:	89 d8                	mov    %ebx,%eax
  800e5d:	c1 e8 0c             	shr    $0xc,%eax
  800e60:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e67:	f6 c4 08             	test   $0x8,%ah
  800e6a:	75 14                	jne    800e80 <pgfault+0x37>
		panic("faulting access");
  800e6c:	83 ec 04             	sub    $0x4,%esp
  800e6f:	68 ca 2c 80 00       	push   $0x802cca
  800e74:	6a 1e                	push   $0x1e
  800e76:	68 da 2c 80 00       	push   $0x802cda
  800e7b:	e8 37 f3 ff ff       	call   8001b7 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e80:	83 ec 04             	sub    $0x4,%esp
  800e83:	6a 07                	push   $0x7
  800e85:	68 00 f0 7f 00       	push   $0x7ff000
  800e8a:	6a 00                	push   $0x0
  800e8c:	e8 87 fd ff ff       	call   800c18 <sys_page_alloc>
	if (r < 0) {
  800e91:	83 c4 10             	add    $0x10,%esp
  800e94:	85 c0                	test   %eax,%eax
  800e96:	79 12                	jns    800eaa <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e98:	50                   	push   %eax
  800e99:	68 e5 2c 80 00       	push   $0x802ce5
  800e9e:	6a 2c                	push   $0x2c
  800ea0:	68 da 2c 80 00       	push   $0x802cda
  800ea5:	e8 0d f3 ff ff       	call   8001b7 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800eaa:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800eb0:	83 ec 04             	sub    $0x4,%esp
  800eb3:	68 00 10 00 00       	push   $0x1000
  800eb8:	53                   	push   %ebx
  800eb9:	68 00 f0 7f 00       	push   $0x7ff000
  800ebe:	e8 4c fb ff ff       	call   800a0f <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800ec3:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800eca:	53                   	push   %ebx
  800ecb:	6a 00                	push   $0x0
  800ecd:	68 00 f0 7f 00       	push   $0x7ff000
  800ed2:	6a 00                	push   $0x0
  800ed4:	e8 82 fd ff ff       	call   800c5b <sys_page_map>
	if (r < 0) {
  800ed9:	83 c4 20             	add    $0x20,%esp
  800edc:	85 c0                	test   %eax,%eax
  800ede:	79 12                	jns    800ef2 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800ee0:	50                   	push   %eax
  800ee1:	68 e5 2c 80 00       	push   $0x802ce5
  800ee6:	6a 33                	push   $0x33
  800ee8:	68 da 2c 80 00       	push   $0x802cda
  800eed:	e8 c5 f2 ff ff       	call   8001b7 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800ef2:	83 ec 08             	sub    $0x8,%esp
  800ef5:	68 00 f0 7f 00       	push   $0x7ff000
  800efa:	6a 00                	push   $0x0
  800efc:	e8 9c fd ff ff       	call   800c9d <sys_page_unmap>
	if (r < 0) {
  800f01:	83 c4 10             	add    $0x10,%esp
  800f04:	85 c0                	test   %eax,%eax
  800f06:	79 12                	jns    800f1a <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800f08:	50                   	push   %eax
  800f09:	68 e5 2c 80 00       	push   $0x802ce5
  800f0e:	6a 37                	push   $0x37
  800f10:	68 da 2c 80 00       	push   $0x802cda
  800f15:	e8 9d f2 ff ff       	call   8001b7 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800f1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f1d:	c9                   	leave  
  800f1e:	c3                   	ret    

00800f1f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
  800f22:	57                   	push   %edi
  800f23:	56                   	push   %esi
  800f24:	53                   	push   %ebx
  800f25:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800f28:	68 49 0e 80 00       	push   $0x800e49
  800f2d:	e8 e3 14 00 00       	call   802415 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f32:	b8 07 00 00 00       	mov    $0x7,%eax
  800f37:	cd 30                	int    $0x30
  800f39:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800f3c:	83 c4 10             	add    $0x10,%esp
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	79 17                	jns    800f5a <fork+0x3b>
		panic("fork fault %e");
  800f43:	83 ec 04             	sub    $0x4,%esp
  800f46:	68 fe 2c 80 00       	push   $0x802cfe
  800f4b:	68 84 00 00 00       	push   $0x84
  800f50:	68 da 2c 80 00       	push   $0x802cda
  800f55:	e8 5d f2 ff ff       	call   8001b7 <_panic>
  800f5a:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f5c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f60:	75 24                	jne    800f86 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f62:	e8 73 fc ff ff       	call   800bda <sys_getenvid>
  800f67:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f6c:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800f72:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f77:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f81:	e9 64 01 00 00       	jmp    8010ea <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f86:	83 ec 04             	sub    $0x4,%esp
  800f89:	6a 07                	push   $0x7
  800f8b:	68 00 f0 bf ee       	push   $0xeebff000
  800f90:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f93:	e8 80 fc ff ff       	call   800c18 <sys_page_alloc>
  800f98:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f9b:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fa0:	89 d8                	mov    %ebx,%eax
  800fa2:	c1 e8 16             	shr    $0x16,%eax
  800fa5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fac:	a8 01                	test   $0x1,%al
  800fae:	0f 84 fc 00 00 00    	je     8010b0 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800fb4:	89 d8                	mov    %ebx,%eax
  800fb6:	c1 e8 0c             	shr    $0xc,%eax
  800fb9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fc0:	f6 c2 01             	test   $0x1,%dl
  800fc3:	0f 84 e7 00 00 00    	je     8010b0 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800fc9:	89 c6                	mov    %eax,%esi
  800fcb:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800fce:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fd5:	f6 c6 04             	test   $0x4,%dh
  800fd8:	74 39                	je     801013 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800fda:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fe1:	83 ec 0c             	sub    $0xc,%esp
  800fe4:	25 07 0e 00 00       	and    $0xe07,%eax
  800fe9:	50                   	push   %eax
  800fea:	56                   	push   %esi
  800feb:	57                   	push   %edi
  800fec:	56                   	push   %esi
  800fed:	6a 00                	push   $0x0
  800fef:	e8 67 fc ff ff       	call   800c5b <sys_page_map>
		if (r < 0) {
  800ff4:	83 c4 20             	add    $0x20,%esp
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	0f 89 b1 00 00 00    	jns    8010b0 <fork+0x191>
		    	panic("sys page map fault %e");
  800fff:	83 ec 04             	sub    $0x4,%esp
  801002:	68 0c 2d 80 00       	push   $0x802d0c
  801007:	6a 54                	push   $0x54
  801009:	68 da 2c 80 00       	push   $0x802cda
  80100e:	e8 a4 f1 ff ff       	call   8001b7 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801013:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80101a:	f6 c2 02             	test   $0x2,%dl
  80101d:	75 0c                	jne    80102b <fork+0x10c>
  80101f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801026:	f6 c4 08             	test   $0x8,%ah
  801029:	74 5b                	je     801086 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80102b:	83 ec 0c             	sub    $0xc,%esp
  80102e:	68 05 08 00 00       	push   $0x805
  801033:	56                   	push   %esi
  801034:	57                   	push   %edi
  801035:	56                   	push   %esi
  801036:	6a 00                	push   $0x0
  801038:	e8 1e fc ff ff       	call   800c5b <sys_page_map>
		if (r < 0) {
  80103d:	83 c4 20             	add    $0x20,%esp
  801040:	85 c0                	test   %eax,%eax
  801042:	79 14                	jns    801058 <fork+0x139>
		    	panic("sys page map fault %e");
  801044:	83 ec 04             	sub    $0x4,%esp
  801047:	68 0c 2d 80 00       	push   $0x802d0c
  80104c:	6a 5b                	push   $0x5b
  80104e:	68 da 2c 80 00       	push   $0x802cda
  801053:	e8 5f f1 ff ff       	call   8001b7 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  801058:	83 ec 0c             	sub    $0xc,%esp
  80105b:	68 05 08 00 00       	push   $0x805
  801060:	56                   	push   %esi
  801061:	6a 00                	push   $0x0
  801063:	56                   	push   %esi
  801064:	6a 00                	push   $0x0
  801066:	e8 f0 fb ff ff       	call   800c5b <sys_page_map>
		if (r < 0) {
  80106b:	83 c4 20             	add    $0x20,%esp
  80106e:	85 c0                	test   %eax,%eax
  801070:	79 3e                	jns    8010b0 <fork+0x191>
		    	panic("sys page map fault %e");
  801072:	83 ec 04             	sub    $0x4,%esp
  801075:	68 0c 2d 80 00       	push   $0x802d0c
  80107a:	6a 5f                	push   $0x5f
  80107c:	68 da 2c 80 00       	push   $0x802cda
  801081:	e8 31 f1 ff ff       	call   8001b7 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801086:	83 ec 0c             	sub    $0xc,%esp
  801089:	6a 05                	push   $0x5
  80108b:	56                   	push   %esi
  80108c:	57                   	push   %edi
  80108d:	56                   	push   %esi
  80108e:	6a 00                	push   $0x0
  801090:	e8 c6 fb ff ff       	call   800c5b <sys_page_map>
		if (r < 0) {
  801095:	83 c4 20             	add    $0x20,%esp
  801098:	85 c0                	test   %eax,%eax
  80109a:	79 14                	jns    8010b0 <fork+0x191>
		    	panic("sys page map fault %e");
  80109c:	83 ec 04             	sub    $0x4,%esp
  80109f:	68 0c 2d 80 00       	push   $0x802d0c
  8010a4:	6a 64                	push   $0x64
  8010a6:	68 da 2c 80 00       	push   $0x802cda
  8010ab:	e8 07 f1 ff ff       	call   8001b7 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8010b0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010b6:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8010bc:	0f 85 de fe ff ff    	jne    800fa0 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8010c2:	a1 04 40 80 00       	mov    0x804004,%eax
  8010c7:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  8010cd:	83 ec 08             	sub    $0x8,%esp
  8010d0:	50                   	push   %eax
  8010d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010d4:	57                   	push   %edi
  8010d5:	e8 89 fc ff ff       	call   800d63 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8010da:	83 c4 08             	add    $0x8,%esp
  8010dd:	6a 02                	push   $0x2
  8010df:	57                   	push   %edi
  8010e0:	e8 fa fb ff ff       	call   800cdf <sys_env_set_status>
	
	return envid;
  8010e5:	83 c4 10             	add    $0x10,%esp
  8010e8:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8010ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ed:	5b                   	pop    %ebx
  8010ee:	5e                   	pop    %esi
  8010ef:	5f                   	pop    %edi
  8010f0:	5d                   	pop    %ebp
  8010f1:	c3                   	ret    

008010f2 <sfork>:

envid_t
sfork(void)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
	return 0;
}
  8010f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8010fa:	5d                   	pop    %ebp
  8010fb:	c3                   	ret    

008010fc <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8010fc:	55                   	push   %ebp
  8010fd:	89 e5                	mov    %esp,%ebp
  8010ff:	56                   	push   %esi
  801100:	53                   	push   %ebx
  801101:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801104:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  80110a:	83 ec 08             	sub    $0x8,%esp
  80110d:	53                   	push   %ebx
  80110e:	68 24 2d 80 00       	push   $0x802d24
  801113:	e8 78 f1 ff ff       	call   800290 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801118:	c7 04 24 7d 01 80 00 	movl   $0x80017d,(%esp)
  80111f:	e8 e5 fc ff ff       	call   800e09 <sys_thread_create>
  801124:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801126:	83 c4 08             	add    $0x8,%esp
  801129:	53                   	push   %ebx
  80112a:	68 24 2d 80 00       	push   $0x802d24
  80112f:	e8 5c f1 ff ff       	call   800290 <cprintf>
	return id;
}
  801134:	89 f0                	mov    %esi,%eax
  801136:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801139:	5b                   	pop    %ebx
  80113a:	5e                   	pop    %esi
  80113b:	5d                   	pop    %ebp
  80113c:	c3                   	ret    

0080113d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80113d:	55                   	push   %ebp
  80113e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801140:	8b 45 08             	mov    0x8(%ebp),%eax
  801143:	05 00 00 00 30       	add    $0x30000000,%eax
  801148:	c1 e8 0c             	shr    $0xc,%eax
}
  80114b:	5d                   	pop    %ebp
  80114c:	c3                   	ret    

0080114d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80114d:	55                   	push   %ebp
  80114e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801150:	8b 45 08             	mov    0x8(%ebp),%eax
  801153:	05 00 00 00 30       	add    $0x30000000,%eax
  801158:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80115d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801162:	5d                   	pop    %ebp
  801163:	c3                   	ret    

00801164 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80116a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80116f:	89 c2                	mov    %eax,%edx
  801171:	c1 ea 16             	shr    $0x16,%edx
  801174:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80117b:	f6 c2 01             	test   $0x1,%dl
  80117e:	74 11                	je     801191 <fd_alloc+0x2d>
  801180:	89 c2                	mov    %eax,%edx
  801182:	c1 ea 0c             	shr    $0xc,%edx
  801185:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80118c:	f6 c2 01             	test   $0x1,%dl
  80118f:	75 09                	jne    80119a <fd_alloc+0x36>
			*fd_store = fd;
  801191:	89 01                	mov    %eax,(%ecx)
			return 0;
  801193:	b8 00 00 00 00       	mov    $0x0,%eax
  801198:	eb 17                	jmp    8011b1 <fd_alloc+0x4d>
  80119a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80119f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011a4:	75 c9                	jne    80116f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011a6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011ac:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011b1:	5d                   	pop    %ebp
  8011b2:	c3                   	ret    

008011b3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011b3:	55                   	push   %ebp
  8011b4:	89 e5                	mov    %esp,%ebp
  8011b6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011b9:	83 f8 1f             	cmp    $0x1f,%eax
  8011bc:	77 36                	ja     8011f4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011be:	c1 e0 0c             	shl    $0xc,%eax
  8011c1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011c6:	89 c2                	mov    %eax,%edx
  8011c8:	c1 ea 16             	shr    $0x16,%edx
  8011cb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011d2:	f6 c2 01             	test   $0x1,%dl
  8011d5:	74 24                	je     8011fb <fd_lookup+0x48>
  8011d7:	89 c2                	mov    %eax,%edx
  8011d9:	c1 ea 0c             	shr    $0xc,%edx
  8011dc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011e3:	f6 c2 01             	test   $0x1,%dl
  8011e6:	74 1a                	je     801202 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011eb:	89 02                	mov    %eax,(%edx)
	return 0;
  8011ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f2:	eb 13                	jmp    801207 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f9:	eb 0c                	jmp    801207 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801200:	eb 05                	jmp    801207 <fd_lookup+0x54>
  801202:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801207:	5d                   	pop    %ebp
  801208:	c3                   	ret    

00801209 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801209:	55                   	push   %ebp
  80120a:	89 e5                	mov    %esp,%ebp
  80120c:	83 ec 08             	sub    $0x8,%esp
  80120f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801212:	ba c4 2d 80 00       	mov    $0x802dc4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801217:	eb 13                	jmp    80122c <dev_lookup+0x23>
  801219:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80121c:	39 08                	cmp    %ecx,(%eax)
  80121e:	75 0c                	jne    80122c <dev_lookup+0x23>
			*dev = devtab[i];
  801220:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801223:	89 01                	mov    %eax,(%ecx)
			return 0;
  801225:	b8 00 00 00 00       	mov    $0x0,%eax
  80122a:	eb 2e                	jmp    80125a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80122c:	8b 02                	mov    (%edx),%eax
  80122e:	85 c0                	test   %eax,%eax
  801230:	75 e7                	jne    801219 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801232:	a1 04 40 80 00       	mov    0x804004,%eax
  801237:	8b 40 7c             	mov    0x7c(%eax),%eax
  80123a:	83 ec 04             	sub    $0x4,%esp
  80123d:	51                   	push   %ecx
  80123e:	50                   	push   %eax
  80123f:	68 48 2d 80 00       	push   $0x802d48
  801244:	e8 47 f0 ff ff       	call   800290 <cprintf>
	*dev = 0;
  801249:	8b 45 0c             	mov    0xc(%ebp),%eax
  80124c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801252:	83 c4 10             	add    $0x10,%esp
  801255:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80125a:	c9                   	leave  
  80125b:	c3                   	ret    

0080125c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80125c:	55                   	push   %ebp
  80125d:	89 e5                	mov    %esp,%ebp
  80125f:	56                   	push   %esi
  801260:	53                   	push   %ebx
  801261:	83 ec 10             	sub    $0x10,%esp
  801264:	8b 75 08             	mov    0x8(%ebp),%esi
  801267:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80126a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126d:	50                   	push   %eax
  80126e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801274:	c1 e8 0c             	shr    $0xc,%eax
  801277:	50                   	push   %eax
  801278:	e8 36 ff ff ff       	call   8011b3 <fd_lookup>
  80127d:	83 c4 08             	add    $0x8,%esp
  801280:	85 c0                	test   %eax,%eax
  801282:	78 05                	js     801289 <fd_close+0x2d>
	    || fd != fd2)
  801284:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801287:	74 0c                	je     801295 <fd_close+0x39>
		return (must_exist ? r : 0);
  801289:	84 db                	test   %bl,%bl
  80128b:	ba 00 00 00 00       	mov    $0x0,%edx
  801290:	0f 44 c2             	cmove  %edx,%eax
  801293:	eb 41                	jmp    8012d6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801295:	83 ec 08             	sub    $0x8,%esp
  801298:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80129b:	50                   	push   %eax
  80129c:	ff 36                	pushl  (%esi)
  80129e:	e8 66 ff ff ff       	call   801209 <dev_lookup>
  8012a3:	89 c3                	mov    %eax,%ebx
  8012a5:	83 c4 10             	add    $0x10,%esp
  8012a8:	85 c0                	test   %eax,%eax
  8012aa:	78 1a                	js     8012c6 <fd_close+0x6a>
		if (dev->dev_close)
  8012ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012af:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012b2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012b7:	85 c0                	test   %eax,%eax
  8012b9:	74 0b                	je     8012c6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012bb:	83 ec 0c             	sub    $0xc,%esp
  8012be:	56                   	push   %esi
  8012bf:	ff d0                	call   *%eax
  8012c1:	89 c3                	mov    %eax,%ebx
  8012c3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012c6:	83 ec 08             	sub    $0x8,%esp
  8012c9:	56                   	push   %esi
  8012ca:	6a 00                	push   $0x0
  8012cc:	e8 cc f9 ff ff       	call   800c9d <sys_page_unmap>
	return r;
  8012d1:	83 c4 10             	add    $0x10,%esp
  8012d4:	89 d8                	mov    %ebx,%eax
}
  8012d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d9:	5b                   	pop    %ebx
  8012da:	5e                   	pop    %esi
  8012db:	5d                   	pop    %ebp
  8012dc:	c3                   	ret    

008012dd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012dd:	55                   	push   %ebp
  8012de:	89 e5                	mov    %esp,%ebp
  8012e0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e6:	50                   	push   %eax
  8012e7:	ff 75 08             	pushl  0x8(%ebp)
  8012ea:	e8 c4 fe ff ff       	call   8011b3 <fd_lookup>
  8012ef:	83 c4 08             	add    $0x8,%esp
  8012f2:	85 c0                	test   %eax,%eax
  8012f4:	78 10                	js     801306 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012f6:	83 ec 08             	sub    $0x8,%esp
  8012f9:	6a 01                	push   $0x1
  8012fb:	ff 75 f4             	pushl  -0xc(%ebp)
  8012fe:	e8 59 ff ff ff       	call   80125c <fd_close>
  801303:	83 c4 10             	add    $0x10,%esp
}
  801306:	c9                   	leave  
  801307:	c3                   	ret    

00801308 <close_all>:

void
close_all(void)
{
  801308:	55                   	push   %ebp
  801309:	89 e5                	mov    %esp,%ebp
  80130b:	53                   	push   %ebx
  80130c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80130f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801314:	83 ec 0c             	sub    $0xc,%esp
  801317:	53                   	push   %ebx
  801318:	e8 c0 ff ff ff       	call   8012dd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80131d:	83 c3 01             	add    $0x1,%ebx
  801320:	83 c4 10             	add    $0x10,%esp
  801323:	83 fb 20             	cmp    $0x20,%ebx
  801326:	75 ec                	jne    801314 <close_all+0xc>
		close(i);
}
  801328:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80132b:	c9                   	leave  
  80132c:	c3                   	ret    

0080132d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80132d:	55                   	push   %ebp
  80132e:	89 e5                	mov    %esp,%ebp
  801330:	57                   	push   %edi
  801331:	56                   	push   %esi
  801332:	53                   	push   %ebx
  801333:	83 ec 2c             	sub    $0x2c,%esp
  801336:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801339:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80133c:	50                   	push   %eax
  80133d:	ff 75 08             	pushl  0x8(%ebp)
  801340:	e8 6e fe ff ff       	call   8011b3 <fd_lookup>
  801345:	83 c4 08             	add    $0x8,%esp
  801348:	85 c0                	test   %eax,%eax
  80134a:	0f 88 c1 00 00 00    	js     801411 <dup+0xe4>
		return r;
	close(newfdnum);
  801350:	83 ec 0c             	sub    $0xc,%esp
  801353:	56                   	push   %esi
  801354:	e8 84 ff ff ff       	call   8012dd <close>

	newfd = INDEX2FD(newfdnum);
  801359:	89 f3                	mov    %esi,%ebx
  80135b:	c1 e3 0c             	shl    $0xc,%ebx
  80135e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801364:	83 c4 04             	add    $0x4,%esp
  801367:	ff 75 e4             	pushl  -0x1c(%ebp)
  80136a:	e8 de fd ff ff       	call   80114d <fd2data>
  80136f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801371:	89 1c 24             	mov    %ebx,(%esp)
  801374:	e8 d4 fd ff ff       	call   80114d <fd2data>
  801379:	83 c4 10             	add    $0x10,%esp
  80137c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80137f:	89 f8                	mov    %edi,%eax
  801381:	c1 e8 16             	shr    $0x16,%eax
  801384:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80138b:	a8 01                	test   $0x1,%al
  80138d:	74 37                	je     8013c6 <dup+0x99>
  80138f:	89 f8                	mov    %edi,%eax
  801391:	c1 e8 0c             	shr    $0xc,%eax
  801394:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80139b:	f6 c2 01             	test   $0x1,%dl
  80139e:	74 26                	je     8013c6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013a0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013a7:	83 ec 0c             	sub    $0xc,%esp
  8013aa:	25 07 0e 00 00       	and    $0xe07,%eax
  8013af:	50                   	push   %eax
  8013b0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013b3:	6a 00                	push   $0x0
  8013b5:	57                   	push   %edi
  8013b6:	6a 00                	push   $0x0
  8013b8:	e8 9e f8 ff ff       	call   800c5b <sys_page_map>
  8013bd:	89 c7                	mov    %eax,%edi
  8013bf:	83 c4 20             	add    $0x20,%esp
  8013c2:	85 c0                	test   %eax,%eax
  8013c4:	78 2e                	js     8013f4 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013c6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013c9:	89 d0                	mov    %edx,%eax
  8013cb:	c1 e8 0c             	shr    $0xc,%eax
  8013ce:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013d5:	83 ec 0c             	sub    $0xc,%esp
  8013d8:	25 07 0e 00 00       	and    $0xe07,%eax
  8013dd:	50                   	push   %eax
  8013de:	53                   	push   %ebx
  8013df:	6a 00                	push   $0x0
  8013e1:	52                   	push   %edx
  8013e2:	6a 00                	push   $0x0
  8013e4:	e8 72 f8 ff ff       	call   800c5b <sys_page_map>
  8013e9:	89 c7                	mov    %eax,%edi
  8013eb:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013ee:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013f0:	85 ff                	test   %edi,%edi
  8013f2:	79 1d                	jns    801411 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013f4:	83 ec 08             	sub    $0x8,%esp
  8013f7:	53                   	push   %ebx
  8013f8:	6a 00                	push   $0x0
  8013fa:	e8 9e f8 ff ff       	call   800c9d <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013ff:	83 c4 08             	add    $0x8,%esp
  801402:	ff 75 d4             	pushl  -0x2c(%ebp)
  801405:	6a 00                	push   $0x0
  801407:	e8 91 f8 ff ff       	call   800c9d <sys_page_unmap>
	return r;
  80140c:	83 c4 10             	add    $0x10,%esp
  80140f:	89 f8                	mov    %edi,%eax
}
  801411:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801414:	5b                   	pop    %ebx
  801415:	5e                   	pop    %esi
  801416:	5f                   	pop    %edi
  801417:	5d                   	pop    %ebp
  801418:	c3                   	ret    

00801419 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801419:	55                   	push   %ebp
  80141a:	89 e5                	mov    %esp,%ebp
  80141c:	53                   	push   %ebx
  80141d:	83 ec 14             	sub    $0x14,%esp
  801420:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801423:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801426:	50                   	push   %eax
  801427:	53                   	push   %ebx
  801428:	e8 86 fd ff ff       	call   8011b3 <fd_lookup>
  80142d:	83 c4 08             	add    $0x8,%esp
  801430:	89 c2                	mov    %eax,%edx
  801432:	85 c0                	test   %eax,%eax
  801434:	78 6d                	js     8014a3 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801436:	83 ec 08             	sub    $0x8,%esp
  801439:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80143c:	50                   	push   %eax
  80143d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801440:	ff 30                	pushl  (%eax)
  801442:	e8 c2 fd ff ff       	call   801209 <dev_lookup>
  801447:	83 c4 10             	add    $0x10,%esp
  80144a:	85 c0                	test   %eax,%eax
  80144c:	78 4c                	js     80149a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80144e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801451:	8b 42 08             	mov    0x8(%edx),%eax
  801454:	83 e0 03             	and    $0x3,%eax
  801457:	83 f8 01             	cmp    $0x1,%eax
  80145a:	75 21                	jne    80147d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80145c:	a1 04 40 80 00       	mov    0x804004,%eax
  801461:	8b 40 7c             	mov    0x7c(%eax),%eax
  801464:	83 ec 04             	sub    $0x4,%esp
  801467:	53                   	push   %ebx
  801468:	50                   	push   %eax
  801469:	68 89 2d 80 00       	push   $0x802d89
  80146e:	e8 1d ee ff ff       	call   800290 <cprintf>
		return -E_INVAL;
  801473:	83 c4 10             	add    $0x10,%esp
  801476:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80147b:	eb 26                	jmp    8014a3 <read+0x8a>
	}
	if (!dev->dev_read)
  80147d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801480:	8b 40 08             	mov    0x8(%eax),%eax
  801483:	85 c0                	test   %eax,%eax
  801485:	74 17                	je     80149e <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801487:	83 ec 04             	sub    $0x4,%esp
  80148a:	ff 75 10             	pushl  0x10(%ebp)
  80148d:	ff 75 0c             	pushl  0xc(%ebp)
  801490:	52                   	push   %edx
  801491:	ff d0                	call   *%eax
  801493:	89 c2                	mov    %eax,%edx
  801495:	83 c4 10             	add    $0x10,%esp
  801498:	eb 09                	jmp    8014a3 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80149a:	89 c2                	mov    %eax,%edx
  80149c:	eb 05                	jmp    8014a3 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80149e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8014a3:	89 d0                	mov    %edx,%eax
  8014a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a8:	c9                   	leave  
  8014a9:	c3                   	ret    

008014aa <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014aa:	55                   	push   %ebp
  8014ab:	89 e5                	mov    %esp,%ebp
  8014ad:	57                   	push   %edi
  8014ae:	56                   	push   %esi
  8014af:	53                   	push   %ebx
  8014b0:	83 ec 0c             	sub    $0xc,%esp
  8014b3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014b6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014be:	eb 21                	jmp    8014e1 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014c0:	83 ec 04             	sub    $0x4,%esp
  8014c3:	89 f0                	mov    %esi,%eax
  8014c5:	29 d8                	sub    %ebx,%eax
  8014c7:	50                   	push   %eax
  8014c8:	89 d8                	mov    %ebx,%eax
  8014ca:	03 45 0c             	add    0xc(%ebp),%eax
  8014cd:	50                   	push   %eax
  8014ce:	57                   	push   %edi
  8014cf:	e8 45 ff ff ff       	call   801419 <read>
		if (m < 0)
  8014d4:	83 c4 10             	add    $0x10,%esp
  8014d7:	85 c0                	test   %eax,%eax
  8014d9:	78 10                	js     8014eb <readn+0x41>
			return m;
		if (m == 0)
  8014db:	85 c0                	test   %eax,%eax
  8014dd:	74 0a                	je     8014e9 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014df:	01 c3                	add    %eax,%ebx
  8014e1:	39 f3                	cmp    %esi,%ebx
  8014e3:	72 db                	jb     8014c0 <readn+0x16>
  8014e5:	89 d8                	mov    %ebx,%eax
  8014e7:	eb 02                	jmp    8014eb <readn+0x41>
  8014e9:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ee:	5b                   	pop    %ebx
  8014ef:	5e                   	pop    %esi
  8014f0:	5f                   	pop    %edi
  8014f1:	5d                   	pop    %ebp
  8014f2:	c3                   	ret    

008014f3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014f3:	55                   	push   %ebp
  8014f4:	89 e5                	mov    %esp,%ebp
  8014f6:	53                   	push   %ebx
  8014f7:	83 ec 14             	sub    $0x14,%esp
  8014fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801500:	50                   	push   %eax
  801501:	53                   	push   %ebx
  801502:	e8 ac fc ff ff       	call   8011b3 <fd_lookup>
  801507:	83 c4 08             	add    $0x8,%esp
  80150a:	89 c2                	mov    %eax,%edx
  80150c:	85 c0                	test   %eax,%eax
  80150e:	78 68                	js     801578 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801510:	83 ec 08             	sub    $0x8,%esp
  801513:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801516:	50                   	push   %eax
  801517:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151a:	ff 30                	pushl  (%eax)
  80151c:	e8 e8 fc ff ff       	call   801209 <dev_lookup>
  801521:	83 c4 10             	add    $0x10,%esp
  801524:	85 c0                	test   %eax,%eax
  801526:	78 47                	js     80156f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801528:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80152f:	75 21                	jne    801552 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801531:	a1 04 40 80 00       	mov    0x804004,%eax
  801536:	8b 40 7c             	mov    0x7c(%eax),%eax
  801539:	83 ec 04             	sub    $0x4,%esp
  80153c:	53                   	push   %ebx
  80153d:	50                   	push   %eax
  80153e:	68 a5 2d 80 00       	push   $0x802da5
  801543:	e8 48 ed ff ff       	call   800290 <cprintf>
		return -E_INVAL;
  801548:	83 c4 10             	add    $0x10,%esp
  80154b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801550:	eb 26                	jmp    801578 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801552:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801555:	8b 52 0c             	mov    0xc(%edx),%edx
  801558:	85 d2                	test   %edx,%edx
  80155a:	74 17                	je     801573 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80155c:	83 ec 04             	sub    $0x4,%esp
  80155f:	ff 75 10             	pushl  0x10(%ebp)
  801562:	ff 75 0c             	pushl  0xc(%ebp)
  801565:	50                   	push   %eax
  801566:	ff d2                	call   *%edx
  801568:	89 c2                	mov    %eax,%edx
  80156a:	83 c4 10             	add    $0x10,%esp
  80156d:	eb 09                	jmp    801578 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156f:	89 c2                	mov    %eax,%edx
  801571:	eb 05                	jmp    801578 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801573:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801578:	89 d0                	mov    %edx,%eax
  80157a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157d:	c9                   	leave  
  80157e:	c3                   	ret    

0080157f <seek>:

int
seek(int fdnum, off_t offset)
{
  80157f:	55                   	push   %ebp
  801580:	89 e5                	mov    %esp,%ebp
  801582:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801585:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801588:	50                   	push   %eax
  801589:	ff 75 08             	pushl  0x8(%ebp)
  80158c:	e8 22 fc ff ff       	call   8011b3 <fd_lookup>
  801591:	83 c4 08             	add    $0x8,%esp
  801594:	85 c0                	test   %eax,%eax
  801596:	78 0e                	js     8015a6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801598:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80159b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80159e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015a6:	c9                   	leave  
  8015a7:	c3                   	ret    

008015a8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015a8:	55                   	push   %ebp
  8015a9:	89 e5                	mov    %esp,%ebp
  8015ab:	53                   	push   %ebx
  8015ac:	83 ec 14             	sub    $0x14,%esp
  8015af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b5:	50                   	push   %eax
  8015b6:	53                   	push   %ebx
  8015b7:	e8 f7 fb ff ff       	call   8011b3 <fd_lookup>
  8015bc:	83 c4 08             	add    $0x8,%esp
  8015bf:	89 c2                	mov    %eax,%edx
  8015c1:	85 c0                	test   %eax,%eax
  8015c3:	78 65                	js     80162a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c5:	83 ec 08             	sub    $0x8,%esp
  8015c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015cb:	50                   	push   %eax
  8015cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015cf:	ff 30                	pushl  (%eax)
  8015d1:	e8 33 fc ff ff       	call   801209 <dev_lookup>
  8015d6:	83 c4 10             	add    $0x10,%esp
  8015d9:	85 c0                	test   %eax,%eax
  8015db:	78 44                	js     801621 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015e4:	75 21                	jne    801607 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015e6:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015eb:	8b 40 7c             	mov    0x7c(%eax),%eax
  8015ee:	83 ec 04             	sub    $0x4,%esp
  8015f1:	53                   	push   %ebx
  8015f2:	50                   	push   %eax
  8015f3:	68 68 2d 80 00       	push   $0x802d68
  8015f8:	e8 93 ec ff ff       	call   800290 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015fd:	83 c4 10             	add    $0x10,%esp
  801600:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801605:	eb 23                	jmp    80162a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801607:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80160a:	8b 52 18             	mov    0x18(%edx),%edx
  80160d:	85 d2                	test   %edx,%edx
  80160f:	74 14                	je     801625 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801611:	83 ec 08             	sub    $0x8,%esp
  801614:	ff 75 0c             	pushl  0xc(%ebp)
  801617:	50                   	push   %eax
  801618:	ff d2                	call   *%edx
  80161a:	89 c2                	mov    %eax,%edx
  80161c:	83 c4 10             	add    $0x10,%esp
  80161f:	eb 09                	jmp    80162a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801621:	89 c2                	mov    %eax,%edx
  801623:	eb 05                	jmp    80162a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801625:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80162a:	89 d0                	mov    %edx,%eax
  80162c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80162f:	c9                   	leave  
  801630:	c3                   	ret    

00801631 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801631:	55                   	push   %ebp
  801632:	89 e5                	mov    %esp,%ebp
  801634:	53                   	push   %ebx
  801635:	83 ec 14             	sub    $0x14,%esp
  801638:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80163b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80163e:	50                   	push   %eax
  80163f:	ff 75 08             	pushl  0x8(%ebp)
  801642:	e8 6c fb ff ff       	call   8011b3 <fd_lookup>
  801647:	83 c4 08             	add    $0x8,%esp
  80164a:	89 c2                	mov    %eax,%edx
  80164c:	85 c0                	test   %eax,%eax
  80164e:	78 58                	js     8016a8 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801650:	83 ec 08             	sub    $0x8,%esp
  801653:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801656:	50                   	push   %eax
  801657:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165a:	ff 30                	pushl  (%eax)
  80165c:	e8 a8 fb ff ff       	call   801209 <dev_lookup>
  801661:	83 c4 10             	add    $0x10,%esp
  801664:	85 c0                	test   %eax,%eax
  801666:	78 37                	js     80169f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801668:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80166b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80166f:	74 32                	je     8016a3 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801671:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801674:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80167b:	00 00 00 
	stat->st_isdir = 0;
  80167e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801685:	00 00 00 
	stat->st_dev = dev;
  801688:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80168e:	83 ec 08             	sub    $0x8,%esp
  801691:	53                   	push   %ebx
  801692:	ff 75 f0             	pushl  -0x10(%ebp)
  801695:	ff 50 14             	call   *0x14(%eax)
  801698:	89 c2                	mov    %eax,%edx
  80169a:	83 c4 10             	add    $0x10,%esp
  80169d:	eb 09                	jmp    8016a8 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169f:	89 c2                	mov    %eax,%edx
  8016a1:	eb 05                	jmp    8016a8 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016a3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016a8:	89 d0                	mov    %edx,%eax
  8016aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ad:	c9                   	leave  
  8016ae:	c3                   	ret    

008016af <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	56                   	push   %esi
  8016b3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016b4:	83 ec 08             	sub    $0x8,%esp
  8016b7:	6a 00                	push   $0x0
  8016b9:	ff 75 08             	pushl  0x8(%ebp)
  8016bc:	e8 e3 01 00 00       	call   8018a4 <open>
  8016c1:	89 c3                	mov    %eax,%ebx
  8016c3:	83 c4 10             	add    $0x10,%esp
  8016c6:	85 c0                	test   %eax,%eax
  8016c8:	78 1b                	js     8016e5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016ca:	83 ec 08             	sub    $0x8,%esp
  8016cd:	ff 75 0c             	pushl  0xc(%ebp)
  8016d0:	50                   	push   %eax
  8016d1:	e8 5b ff ff ff       	call   801631 <fstat>
  8016d6:	89 c6                	mov    %eax,%esi
	close(fd);
  8016d8:	89 1c 24             	mov    %ebx,(%esp)
  8016db:	e8 fd fb ff ff       	call   8012dd <close>
	return r;
  8016e0:	83 c4 10             	add    $0x10,%esp
  8016e3:	89 f0                	mov    %esi,%eax
}
  8016e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016e8:	5b                   	pop    %ebx
  8016e9:	5e                   	pop    %esi
  8016ea:	5d                   	pop    %ebp
  8016eb:	c3                   	ret    

008016ec <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016ec:	55                   	push   %ebp
  8016ed:	89 e5                	mov    %esp,%ebp
  8016ef:	56                   	push   %esi
  8016f0:	53                   	push   %ebx
  8016f1:	89 c6                	mov    %eax,%esi
  8016f3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016f5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016fc:	75 12                	jne    801710 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016fe:	83 ec 0c             	sub    $0xc,%esp
  801701:	6a 01                	push   $0x1
  801703:	e8 79 0e 00 00       	call   802581 <ipc_find_env>
  801708:	a3 00 40 80 00       	mov    %eax,0x804000
  80170d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801710:	6a 07                	push   $0x7
  801712:	68 00 50 80 00       	push   $0x805000
  801717:	56                   	push   %esi
  801718:	ff 35 00 40 80 00    	pushl  0x804000
  80171e:	e8 fc 0d 00 00       	call   80251f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801723:	83 c4 0c             	add    $0xc,%esp
  801726:	6a 00                	push   $0x0
  801728:	53                   	push   %ebx
  801729:	6a 00                	push   $0x0
  80172b:	e8 74 0d 00 00       	call   8024a4 <ipc_recv>
}
  801730:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801733:	5b                   	pop    %ebx
  801734:	5e                   	pop    %esi
  801735:	5d                   	pop    %ebp
  801736:	c3                   	ret    

00801737 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80173d:	8b 45 08             	mov    0x8(%ebp),%eax
  801740:	8b 40 0c             	mov    0xc(%eax),%eax
  801743:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801748:	8b 45 0c             	mov    0xc(%ebp),%eax
  80174b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801750:	ba 00 00 00 00       	mov    $0x0,%edx
  801755:	b8 02 00 00 00       	mov    $0x2,%eax
  80175a:	e8 8d ff ff ff       	call   8016ec <fsipc>
}
  80175f:	c9                   	leave  
  801760:	c3                   	ret    

00801761 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801767:	8b 45 08             	mov    0x8(%ebp),%eax
  80176a:	8b 40 0c             	mov    0xc(%eax),%eax
  80176d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801772:	ba 00 00 00 00       	mov    $0x0,%edx
  801777:	b8 06 00 00 00       	mov    $0x6,%eax
  80177c:	e8 6b ff ff ff       	call   8016ec <fsipc>
}
  801781:	c9                   	leave  
  801782:	c3                   	ret    

00801783 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801783:	55                   	push   %ebp
  801784:	89 e5                	mov    %esp,%ebp
  801786:	53                   	push   %ebx
  801787:	83 ec 04             	sub    $0x4,%esp
  80178a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80178d:	8b 45 08             	mov    0x8(%ebp),%eax
  801790:	8b 40 0c             	mov    0xc(%eax),%eax
  801793:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801798:	ba 00 00 00 00       	mov    $0x0,%edx
  80179d:	b8 05 00 00 00       	mov    $0x5,%eax
  8017a2:	e8 45 ff ff ff       	call   8016ec <fsipc>
  8017a7:	85 c0                	test   %eax,%eax
  8017a9:	78 2c                	js     8017d7 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017ab:	83 ec 08             	sub    $0x8,%esp
  8017ae:	68 00 50 80 00       	push   $0x805000
  8017b3:	53                   	push   %ebx
  8017b4:	e8 5c f0 ff ff       	call   800815 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017b9:	a1 80 50 80 00       	mov    0x805080,%eax
  8017be:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017c4:	a1 84 50 80 00       	mov    0x805084,%eax
  8017c9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017cf:	83 c4 10             	add    $0x10,%esp
  8017d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017da:	c9                   	leave  
  8017db:	c3                   	ret    

008017dc <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017dc:	55                   	push   %ebp
  8017dd:	89 e5                	mov    %esp,%ebp
  8017df:	83 ec 0c             	sub    $0xc,%esp
  8017e2:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8017e8:	8b 52 0c             	mov    0xc(%edx),%edx
  8017eb:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8017f1:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017f6:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017fb:	0f 47 c2             	cmova  %edx,%eax
  8017fe:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801803:	50                   	push   %eax
  801804:	ff 75 0c             	pushl  0xc(%ebp)
  801807:	68 08 50 80 00       	push   $0x805008
  80180c:	e8 96 f1 ff ff       	call   8009a7 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801811:	ba 00 00 00 00       	mov    $0x0,%edx
  801816:	b8 04 00 00 00       	mov    $0x4,%eax
  80181b:	e8 cc fe ff ff       	call   8016ec <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801820:	c9                   	leave  
  801821:	c3                   	ret    

00801822 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801822:	55                   	push   %ebp
  801823:	89 e5                	mov    %esp,%ebp
  801825:	56                   	push   %esi
  801826:	53                   	push   %ebx
  801827:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80182a:	8b 45 08             	mov    0x8(%ebp),%eax
  80182d:	8b 40 0c             	mov    0xc(%eax),%eax
  801830:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801835:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80183b:	ba 00 00 00 00       	mov    $0x0,%edx
  801840:	b8 03 00 00 00       	mov    $0x3,%eax
  801845:	e8 a2 fe ff ff       	call   8016ec <fsipc>
  80184a:	89 c3                	mov    %eax,%ebx
  80184c:	85 c0                	test   %eax,%eax
  80184e:	78 4b                	js     80189b <devfile_read+0x79>
		return r;
	assert(r <= n);
  801850:	39 c6                	cmp    %eax,%esi
  801852:	73 16                	jae    80186a <devfile_read+0x48>
  801854:	68 d4 2d 80 00       	push   $0x802dd4
  801859:	68 db 2d 80 00       	push   $0x802ddb
  80185e:	6a 7c                	push   $0x7c
  801860:	68 f0 2d 80 00       	push   $0x802df0
  801865:	e8 4d e9 ff ff       	call   8001b7 <_panic>
	assert(r <= PGSIZE);
  80186a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80186f:	7e 16                	jle    801887 <devfile_read+0x65>
  801871:	68 fb 2d 80 00       	push   $0x802dfb
  801876:	68 db 2d 80 00       	push   $0x802ddb
  80187b:	6a 7d                	push   $0x7d
  80187d:	68 f0 2d 80 00       	push   $0x802df0
  801882:	e8 30 e9 ff ff       	call   8001b7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801887:	83 ec 04             	sub    $0x4,%esp
  80188a:	50                   	push   %eax
  80188b:	68 00 50 80 00       	push   $0x805000
  801890:	ff 75 0c             	pushl  0xc(%ebp)
  801893:	e8 0f f1 ff ff       	call   8009a7 <memmove>
	return r;
  801898:	83 c4 10             	add    $0x10,%esp
}
  80189b:	89 d8                	mov    %ebx,%eax
  80189d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a0:	5b                   	pop    %ebx
  8018a1:	5e                   	pop    %esi
  8018a2:	5d                   	pop    %ebp
  8018a3:	c3                   	ret    

008018a4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018a4:	55                   	push   %ebp
  8018a5:	89 e5                	mov    %esp,%ebp
  8018a7:	53                   	push   %ebx
  8018a8:	83 ec 20             	sub    $0x20,%esp
  8018ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018ae:	53                   	push   %ebx
  8018af:	e8 28 ef ff ff       	call   8007dc <strlen>
  8018b4:	83 c4 10             	add    $0x10,%esp
  8018b7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018bc:	7f 67                	jg     801925 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018be:	83 ec 0c             	sub    $0xc,%esp
  8018c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c4:	50                   	push   %eax
  8018c5:	e8 9a f8 ff ff       	call   801164 <fd_alloc>
  8018ca:	83 c4 10             	add    $0x10,%esp
		return r;
  8018cd:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018cf:	85 c0                	test   %eax,%eax
  8018d1:	78 57                	js     80192a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018d3:	83 ec 08             	sub    $0x8,%esp
  8018d6:	53                   	push   %ebx
  8018d7:	68 00 50 80 00       	push   $0x805000
  8018dc:	e8 34 ef ff ff       	call   800815 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e4:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ec:	b8 01 00 00 00       	mov    $0x1,%eax
  8018f1:	e8 f6 fd ff ff       	call   8016ec <fsipc>
  8018f6:	89 c3                	mov    %eax,%ebx
  8018f8:	83 c4 10             	add    $0x10,%esp
  8018fb:	85 c0                	test   %eax,%eax
  8018fd:	79 14                	jns    801913 <open+0x6f>
		fd_close(fd, 0);
  8018ff:	83 ec 08             	sub    $0x8,%esp
  801902:	6a 00                	push   $0x0
  801904:	ff 75 f4             	pushl  -0xc(%ebp)
  801907:	e8 50 f9 ff ff       	call   80125c <fd_close>
		return r;
  80190c:	83 c4 10             	add    $0x10,%esp
  80190f:	89 da                	mov    %ebx,%edx
  801911:	eb 17                	jmp    80192a <open+0x86>
	}

	return fd2num(fd);
  801913:	83 ec 0c             	sub    $0xc,%esp
  801916:	ff 75 f4             	pushl  -0xc(%ebp)
  801919:	e8 1f f8 ff ff       	call   80113d <fd2num>
  80191e:	89 c2                	mov    %eax,%edx
  801920:	83 c4 10             	add    $0x10,%esp
  801923:	eb 05                	jmp    80192a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801925:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80192a:	89 d0                	mov    %edx,%eax
  80192c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80192f:	c9                   	leave  
  801930:	c3                   	ret    

00801931 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801931:	55                   	push   %ebp
  801932:	89 e5                	mov    %esp,%ebp
  801934:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801937:	ba 00 00 00 00       	mov    $0x0,%edx
  80193c:	b8 08 00 00 00       	mov    $0x8,%eax
  801941:	e8 a6 fd ff ff       	call   8016ec <fsipc>
}
  801946:	c9                   	leave  
  801947:	c3                   	ret    

00801948 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
  80194b:	57                   	push   %edi
  80194c:	56                   	push   %esi
  80194d:	53                   	push   %ebx
  80194e:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801954:	6a 00                	push   $0x0
  801956:	ff 75 08             	pushl  0x8(%ebp)
  801959:	e8 46 ff ff ff       	call   8018a4 <open>
  80195e:	89 c7                	mov    %eax,%edi
  801960:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801966:	83 c4 10             	add    $0x10,%esp
  801969:	85 c0                	test   %eax,%eax
  80196b:	0f 88 8c 04 00 00    	js     801dfd <spawn+0x4b5>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801971:	83 ec 04             	sub    $0x4,%esp
  801974:	68 00 02 00 00       	push   $0x200
  801979:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80197f:	50                   	push   %eax
  801980:	57                   	push   %edi
  801981:	e8 24 fb ff ff       	call   8014aa <readn>
  801986:	83 c4 10             	add    $0x10,%esp
  801989:	3d 00 02 00 00       	cmp    $0x200,%eax
  80198e:	75 0c                	jne    80199c <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801990:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801997:	45 4c 46 
  80199a:	74 33                	je     8019cf <spawn+0x87>
		close(fd);
  80199c:	83 ec 0c             	sub    $0xc,%esp
  80199f:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019a5:	e8 33 f9 ff ff       	call   8012dd <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8019aa:	83 c4 0c             	add    $0xc,%esp
  8019ad:	68 7f 45 4c 46       	push   $0x464c457f
  8019b2:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8019b8:	68 07 2e 80 00       	push   $0x802e07
  8019bd:	e8 ce e8 ff ff       	call   800290 <cprintf>
		return -E_NOT_EXEC;
  8019c2:	83 c4 10             	add    $0x10,%esp
  8019c5:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8019ca:	e9 e1 04 00 00       	jmp    801eb0 <spawn+0x568>
  8019cf:	b8 07 00 00 00       	mov    $0x7,%eax
  8019d4:	cd 30                	int    $0x30
  8019d6:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8019dc:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8019e2:	85 c0                	test   %eax,%eax
  8019e4:	0f 88 1e 04 00 00    	js     801e08 <spawn+0x4c0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8019ea:	89 c6                	mov    %eax,%esi
  8019ec:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8019f2:	69 f6 b0 00 00 00    	imul   $0xb0,%esi,%esi
  8019f8:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8019fe:	81 c6 34 00 c0 ee    	add    $0xeec00034,%esi
  801a04:	b9 11 00 00 00       	mov    $0x11,%ecx
  801a09:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801a0b:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801a11:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a17:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801a1c:	be 00 00 00 00       	mov    $0x0,%esi
  801a21:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a24:	eb 13                	jmp    801a39 <spawn+0xf1>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801a26:	83 ec 0c             	sub    $0xc,%esp
  801a29:	50                   	push   %eax
  801a2a:	e8 ad ed ff ff       	call   8007dc <strlen>
  801a2f:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a33:	83 c3 01             	add    $0x1,%ebx
  801a36:	83 c4 10             	add    $0x10,%esp
  801a39:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801a40:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801a43:	85 c0                	test   %eax,%eax
  801a45:	75 df                	jne    801a26 <spawn+0xde>
  801a47:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801a4d:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801a53:	bf 00 10 40 00       	mov    $0x401000,%edi
  801a58:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801a5a:	89 fa                	mov    %edi,%edx
  801a5c:	83 e2 fc             	and    $0xfffffffc,%edx
  801a5f:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801a66:	29 c2                	sub    %eax,%edx
  801a68:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801a6e:	8d 42 f8             	lea    -0x8(%edx),%eax
  801a71:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801a76:	0f 86 a2 03 00 00    	jbe    801e1e <spawn+0x4d6>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a7c:	83 ec 04             	sub    $0x4,%esp
  801a7f:	6a 07                	push   $0x7
  801a81:	68 00 00 40 00       	push   $0x400000
  801a86:	6a 00                	push   $0x0
  801a88:	e8 8b f1 ff ff       	call   800c18 <sys_page_alloc>
  801a8d:	83 c4 10             	add    $0x10,%esp
  801a90:	85 c0                	test   %eax,%eax
  801a92:	0f 88 90 03 00 00    	js     801e28 <spawn+0x4e0>
  801a98:	be 00 00 00 00       	mov    $0x0,%esi
  801a9d:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801aa3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801aa6:	eb 30                	jmp    801ad8 <spawn+0x190>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801aa8:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801aae:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801ab4:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801ab7:	83 ec 08             	sub    $0x8,%esp
  801aba:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801abd:	57                   	push   %edi
  801abe:	e8 52 ed ff ff       	call   800815 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801ac3:	83 c4 04             	add    $0x4,%esp
  801ac6:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801ac9:	e8 0e ed ff ff       	call   8007dc <strlen>
  801ace:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801ad2:	83 c6 01             	add    $0x1,%esi
  801ad5:	83 c4 10             	add    $0x10,%esp
  801ad8:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801ade:	7f c8                	jg     801aa8 <spawn+0x160>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801ae0:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801ae6:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801aec:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801af3:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801af9:	74 19                	je     801b14 <spawn+0x1cc>
  801afb:	68 94 2e 80 00       	push   $0x802e94
  801b00:	68 db 2d 80 00       	push   $0x802ddb
  801b05:	68 f2 00 00 00       	push   $0xf2
  801b0a:	68 21 2e 80 00       	push   $0x802e21
  801b0f:	e8 a3 e6 ff ff       	call   8001b7 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801b14:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801b1a:	89 f8                	mov    %edi,%eax
  801b1c:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801b21:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801b24:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b2a:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801b2d:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801b33:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801b39:	83 ec 0c             	sub    $0xc,%esp
  801b3c:	6a 07                	push   $0x7
  801b3e:	68 00 d0 bf ee       	push   $0xeebfd000
  801b43:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b49:	68 00 00 40 00       	push   $0x400000
  801b4e:	6a 00                	push   $0x0
  801b50:	e8 06 f1 ff ff       	call   800c5b <sys_page_map>
  801b55:	89 c3                	mov    %eax,%ebx
  801b57:	83 c4 20             	add    $0x20,%esp
  801b5a:	85 c0                	test   %eax,%eax
  801b5c:	0f 88 3c 03 00 00    	js     801e9e <spawn+0x556>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801b62:	83 ec 08             	sub    $0x8,%esp
  801b65:	68 00 00 40 00       	push   $0x400000
  801b6a:	6a 00                	push   $0x0
  801b6c:	e8 2c f1 ff ff       	call   800c9d <sys_page_unmap>
  801b71:	89 c3                	mov    %eax,%ebx
  801b73:	83 c4 10             	add    $0x10,%esp
  801b76:	85 c0                	test   %eax,%eax
  801b78:	0f 88 20 03 00 00    	js     801e9e <spawn+0x556>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b7e:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801b84:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801b8b:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b91:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801b98:	00 00 00 
  801b9b:	e9 88 01 00 00       	jmp    801d28 <spawn+0x3e0>
		if (ph->p_type != ELF_PROG_LOAD)
  801ba0:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801ba6:	83 38 01             	cmpl   $0x1,(%eax)
  801ba9:	0f 85 6b 01 00 00    	jne    801d1a <spawn+0x3d2>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801baf:	89 c2                	mov    %eax,%edx
  801bb1:	8b 40 18             	mov    0x18(%eax),%eax
  801bb4:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801bba:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801bbd:	83 f8 01             	cmp    $0x1,%eax
  801bc0:	19 c0                	sbb    %eax,%eax
  801bc2:	83 e0 fe             	and    $0xfffffffe,%eax
  801bc5:	83 c0 07             	add    $0x7,%eax
  801bc8:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801bce:	89 d0                	mov    %edx,%eax
  801bd0:	8b 7a 04             	mov    0x4(%edx),%edi
  801bd3:	89 f9                	mov    %edi,%ecx
  801bd5:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801bdb:	8b 7a 10             	mov    0x10(%edx),%edi
  801bde:	8b 52 14             	mov    0x14(%edx),%edx
  801be1:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801be7:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801bea:	89 f0                	mov    %esi,%eax
  801bec:	25 ff 0f 00 00       	and    $0xfff,%eax
  801bf1:	74 14                	je     801c07 <spawn+0x2bf>
		va -= i;
  801bf3:	29 c6                	sub    %eax,%esi
		memsz += i;
  801bf5:	01 c2                	add    %eax,%edx
  801bf7:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801bfd:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801bff:	29 c1                	sub    %eax,%ecx
  801c01:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c07:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c0c:	e9 f7 00 00 00       	jmp    801d08 <spawn+0x3c0>
		if (i >= filesz) {
  801c11:	39 fb                	cmp    %edi,%ebx
  801c13:	72 27                	jb     801c3c <spawn+0x2f4>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801c15:	83 ec 04             	sub    $0x4,%esp
  801c18:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c1e:	56                   	push   %esi
  801c1f:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c25:	e8 ee ef ff ff       	call   800c18 <sys_page_alloc>
  801c2a:	83 c4 10             	add    $0x10,%esp
  801c2d:	85 c0                	test   %eax,%eax
  801c2f:	0f 89 c7 00 00 00    	jns    801cfc <spawn+0x3b4>
  801c35:	89 c3                	mov    %eax,%ebx
  801c37:	e9 fd 01 00 00       	jmp    801e39 <spawn+0x4f1>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801c3c:	83 ec 04             	sub    $0x4,%esp
  801c3f:	6a 07                	push   $0x7
  801c41:	68 00 00 40 00       	push   $0x400000
  801c46:	6a 00                	push   $0x0
  801c48:	e8 cb ef ff ff       	call   800c18 <sys_page_alloc>
  801c4d:	83 c4 10             	add    $0x10,%esp
  801c50:	85 c0                	test   %eax,%eax
  801c52:	0f 88 d7 01 00 00    	js     801e2f <spawn+0x4e7>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801c58:	83 ec 08             	sub    $0x8,%esp
  801c5b:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801c61:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801c67:	50                   	push   %eax
  801c68:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c6e:	e8 0c f9 ff ff       	call   80157f <seek>
  801c73:	83 c4 10             	add    $0x10,%esp
  801c76:	85 c0                	test   %eax,%eax
  801c78:	0f 88 b5 01 00 00    	js     801e33 <spawn+0x4eb>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801c7e:	83 ec 04             	sub    $0x4,%esp
  801c81:	89 f8                	mov    %edi,%eax
  801c83:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801c89:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c8e:	ba 00 10 00 00       	mov    $0x1000,%edx
  801c93:	0f 47 c2             	cmova  %edx,%eax
  801c96:	50                   	push   %eax
  801c97:	68 00 00 40 00       	push   $0x400000
  801c9c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ca2:	e8 03 f8 ff ff       	call   8014aa <readn>
  801ca7:	83 c4 10             	add    $0x10,%esp
  801caa:	85 c0                	test   %eax,%eax
  801cac:	0f 88 85 01 00 00    	js     801e37 <spawn+0x4ef>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801cb2:	83 ec 0c             	sub    $0xc,%esp
  801cb5:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801cbb:	56                   	push   %esi
  801cbc:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801cc2:	68 00 00 40 00       	push   $0x400000
  801cc7:	6a 00                	push   $0x0
  801cc9:	e8 8d ef ff ff       	call   800c5b <sys_page_map>
  801cce:	83 c4 20             	add    $0x20,%esp
  801cd1:	85 c0                	test   %eax,%eax
  801cd3:	79 15                	jns    801cea <spawn+0x3a2>
				panic("spawn: sys_page_map data: %e", r);
  801cd5:	50                   	push   %eax
  801cd6:	68 2d 2e 80 00       	push   $0x802e2d
  801cdb:	68 25 01 00 00       	push   $0x125
  801ce0:	68 21 2e 80 00       	push   $0x802e21
  801ce5:	e8 cd e4 ff ff       	call   8001b7 <_panic>
			sys_page_unmap(0, UTEMP);
  801cea:	83 ec 08             	sub    $0x8,%esp
  801ced:	68 00 00 40 00       	push   $0x400000
  801cf2:	6a 00                	push   $0x0
  801cf4:	e8 a4 ef ff ff       	call   800c9d <sys_page_unmap>
  801cf9:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801cfc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d02:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801d08:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801d0e:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801d14:	0f 82 f7 fe ff ff    	jb     801c11 <spawn+0x2c9>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d1a:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801d21:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801d28:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801d2f:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801d35:	0f 8c 65 fe ff ff    	jl     801ba0 <spawn+0x258>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801d3b:	83 ec 0c             	sub    $0xc,%esp
  801d3e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d44:	e8 94 f5 ff ff       	call   8012dd <close>
  801d49:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801d4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d51:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801d57:	89 d8                	mov    %ebx,%eax
  801d59:	c1 e8 16             	shr    $0x16,%eax
  801d5c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801d63:	a8 01                	test   $0x1,%al
  801d65:	74 42                	je     801da9 <spawn+0x461>
  801d67:	89 d8                	mov    %ebx,%eax
  801d69:	c1 e8 0c             	shr    $0xc,%eax
  801d6c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d73:	f6 c2 01             	test   $0x1,%dl
  801d76:	74 31                	je     801da9 <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  801d78:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801d7f:	f6 c6 04             	test   $0x4,%dh
  801d82:	74 25                	je     801da9 <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  801d84:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801d8b:	83 ec 0c             	sub    $0xc,%esp
  801d8e:	25 07 0e 00 00       	and    $0xe07,%eax
  801d93:	50                   	push   %eax
  801d94:	53                   	push   %ebx
  801d95:	56                   	push   %esi
  801d96:	53                   	push   %ebx
  801d97:	6a 00                	push   $0x0
  801d99:	e8 bd ee ff ff       	call   800c5b <sys_page_map>
			if (r < 0) {
  801d9e:	83 c4 20             	add    $0x20,%esp
  801da1:	85 c0                	test   %eax,%eax
  801da3:	0f 88 b1 00 00 00    	js     801e5a <spawn+0x512>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801da9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801daf:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801db5:	75 a0                	jne    801d57 <spawn+0x40f>
  801db7:	e9 b3 00 00 00       	jmp    801e6f <spawn+0x527>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801dbc:	50                   	push   %eax
  801dbd:	68 4a 2e 80 00       	push   $0x802e4a
  801dc2:	68 86 00 00 00       	push   $0x86
  801dc7:	68 21 2e 80 00       	push   $0x802e21
  801dcc:	e8 e6 e3 ff ff       	call   8001b7 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801dd1:	83 ec 08             	sub    $0x8,%esp
  801dd4:	6a 02                	push   $0x2
  801dd6:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ddc:	e8 fe ee ff ff       	call   800cdf <sys_env_set_status>
  801de1:	83 c4 10             	add    $0x10,%esp
  801de4:	85 c0                	test   %eax,%eax
  801de6:	79 2b                	jns    801e13 <spawn+0x4cb>
		panic("sys_env_set_status: %e", r);
  801de8:	50                   	push   %eax
  801de9:	68 64 2e 80 00       	push   $0x802e64
  801dee:	68 89 00 00 00       	push   $0x89
  801df3:	68 21 2e 80 00       	push   $0x802e21
  801df8:	e8 ba e3 ff ff       	call   8001b7 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801dfd:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801e03:	e9 a8 00 00 00       	jmp    801eb0 <spawn+0x568>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801e08:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e0e:	e9 9d 00 00 00       	jmp    801eb0 <spawn+0x568>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801e13:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e19:	e9 92 00 00 00       	jmp    801eb0 <spawn+0x568>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801e1e:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801e23:	e9 88 00 00 00       	jmp    801eb0 <spawn+0x568>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801e28:	89 c3                	mov    %eax,%ebx
  801e2a:	e9 81 00 00 00       	jmp    801eb0 <spawn+0x568>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e2f:	89 c3                	mov    %eax,%ebx
  801e31:	eb 06                	jmp    801e39 <spawn+0x4f1>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801e33:	89 c3                	mov    %eax,%ebx
  801e35:	eb 02                	jmp    801e39 <spawn+0x4f1>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801e37:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801e39:	83 ec 0c             	sub    $0xc,%esp
  801e3c:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e42:	e8 52 ed ff ff       	call   800b99 <sys_env_destroy>
	close(fd);
  801e47:	83 c4 04             	add    $0x4,%esp
  801e4a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e50:	e8 88 f4 ff ff       	call   8012dd <close>
	return r;
  801e55:	83 c4 10             	add    $0x10,%esp
  801e58:	eb 56                	jmp    801eb0 <spawn+0x568>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801e5a:	50                   	push   %eax
  801e5b:	68 7b 2e 80 00       	push   $0x802e7b
  801e60:	68 82 00 00 00       	push   $0x82
  801e65:	68 21 2e 80 00       	push   $0x802e21
  801e6a:	e8 48 e3 ff ff       	call   8001b7 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801e6f:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801e76:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801e79:	83 ec 08             	sub    $0x8,%esp
  801e7c:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801e82:	50                   	push   %eax
  801e83:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e89:	e8 93 ee ff ff       	call   800d21 <sys_env_set_trapframe>
  801e8e:	83 c4 10             	add    $0x10,%esp
  801e91:	85 c0                	test   %eax,%eax
  801e93:	0f 89 38 ff ff ff    	jns    801dd1 <spawn+0x489>
  801e99:	e9 1e ff ff ff       	jmp    801dbc <spawn+0x474>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801e9e:	83 ec 08             	sub    $0x8,%esp
  801ea1:	68 00 00 40 00       	push   $0x400000
  801ea6:	6a 00                	push   $0x0
  801ea8:	e8 f0 ed ff ff       	call   800c9d <sys_page_unmap>
  801ead:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801eb0:	89 d8                	mov    %ebx,%eax
  801eb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eb5:	5b                   	pop    %ebx
  801eb6:	5e                   	pop    %esi
  801eb7:	5f                   	pop    %edi
  801eb8:	5d                   	pop    %ebp
  801eb9:	c3                   	ret    

00801eba <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801eba:	55                   	push   %ebp
  801ebb:	89 e5                	mov    %esp,%ebp
  801ebd:	56                   	push   %esi
  801ebe:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ebf:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801ec2:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ec7:	eb 03                	jmp    801ecc <spawnl+0x12>
		argc++;
  801ec9:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ecc:	83 c2 04             	add    $0x4,%edx
  801ecf:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801ed3:	75 f4                	jne    801ec9 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801ed5:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801edc:	83 e2 f0             	and    $0xfffffff0,%edx
  801edf:	29 d4                	sub    %edx,%esp
  801ee1:	8d 54 24 03          	lea    0x3(%esp),%edx
  801ee5:	c1 ea 02             	shr    $0x2,%edx
  801ee8:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801eef:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801ef1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ef4:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801efb:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801f02:	00 
  801f03:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f05:	b8 00 00 00 00       	mov    $0x0,%eax
  801f0a:	eb 0a                	jmp    801f16 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801f0c:	83 c0 01             	add    $0x1,%eax
  801f0f:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801f13:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f16:	39 d0                	cmp    %edx,%eax
  801f18:	75 f2                	jne    801f0c <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801f1a:	83 ec 08             	sub    $0x8,%esp
  801f1d:	56                   	push   %esi
  801f1e:	ff 75 08             	pushl  0x8(%ebp)
  801f21:	e8 22 fa ff ff       	call   801948 <spawn>
}
  801f26:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f29:	5b                   	pop    %ebx
  801f2a:	5e                   	pop    %esi
  801f2b:	5d                   	pop    %ebp
  801f2c:	c3                   	ret    

00801f2d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f2d:	55                   	push   %ebp
  801f2e:	89 e5                	mov    %esp,%ebp
  801f30:	56                   	push   %esi
  801f31:	53                   	push   %ebx
  801f32:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f35:	83 ec 0c             	sub    $0xc,%esp
  801f38:	ff 75 08             	pushl  0x8(%ebp)
  801f3b:	e8 0d f2 ff ff       	call   80114d <fd2data>
  801f40:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f42:	83 c4 08             	add    $0x8,%esp
  801f45:	68 bc 2e 80 00       	push   $0x802ebc
  801f4a:	53                   	push   %ebx
  801f4b:	e8 c5 e8 ff ff       	call   800815 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f50:	8b 46 04             	mov    0x4(%esi),%eax
  801f53:	2b 06                	sub    (%esi),%eax
  801f55:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f5b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f62:	00 00 00 
	stat->st_dev = &devpipe;
  801f65:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801f6c:	30 80 00 
	return 0;
}
  801f6f:	b8 00 00 00 00       	mov    $0x0,%eax
  801f74:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f77:	5b                   	pop    %ebx
  801f78:	5e                   	pop    %esi
  801f79:	5d                   	pop    %ebp
  801f7a:	c3                   	ret    

00801f7b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f7b:	55                   	push   %ebp
  801f7c:	89 e5                	mov    %esp,%ebp
  801f7e:	53                   	push   %ebx
  801f7f:	83 ec 0c             	sub    $0xc,%esp
  801f82:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f85:	53                   	push   %ebx
  801f86:	6a 00                	push   $0x0
  801f88:	e8 10 ed ff ff       	call   800c9d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f8d:	89 1c 24             	mov    %ebx,(%esp)
  801f90:	e8 b8 f1 ff ff       	call   80114d <fd2data>
  801f95:	83 c4 08             	add    $0x8,%esp
  801f98:	50                   	push   %eax
  801f99:	6a 00                	push   $0x0
  801f9b:	e8 fd ec ff ff       	call   800c9d <sys_page_unmap>
}
  801fa0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fa3:	c9                   	leave  
  801fa4:	c3                   	ret    

00801fa5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801fa5:	55                   	push   %ebp
  801fa6:	89 e5                	mov    %esp,%ebp
  801fa8:	57                   	push   %edi
  801fa9:	56                   	push   %esi
  801faa:	53                   	push   %ebx
  801fab:	83 ec 1c             	sub    $0x1c,%esp
  801fae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801fb1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801fb3:	a1 04 40 80 00       	mov    0x804004,%eax
  801fb8:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801fbe:	83 ec 0c             	sub    $0xc,%esp
  801fc1:	ff 75 e0             	pushl  -0x20(%ebp)
  801fc4:	e8 fa 05 00 00       	call   8025c3 <pageref>
  801fc9:	89 c3                	mov    %eax,%ebx
  801fcb:	89 3c 24             	mov    %edi,(%esp)
  801fce:	e8 f0 05 00 00       	call   8025c3 <pageref>
  801fd3:	83 c4 10             	add    $0x10,%esp
  801fd6:	39 c3                	cmp    %eax,%ebx
  801fd8:	0f 94 c1             	sete   %cl
  801fdb:	0f b6 c9             	movzbl %cl,%ecx
  801fde:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801fe1:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801fe7:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  801fed:	39 ce                	cmp    %ecx,%esi
  801fef:	74 1e                	je     80200f <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801ff1:	39 c3                	cmp    %eax,%ebx
  801ff3:	75 be                	jne    801fb3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ff5:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  801ffb:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ffe:	50                   	push   %eax
  801fff:	56                   	push   %esi
  802000:	68 c3 2e 80 00       	push   $0x802ec3
  802005:	e8 86 e2 ff ff       	call   800290 <cprintf>
  80200a:	83 c4 10             	add    $0x10,%esp
  80200d:	eb a4                	jmp    801fb3 <_pipeisclosed+0xe>
	}
}
  80200f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802012:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802015:	5b                   	pop    %ebx
  802016:	5e                   	pop    %esi
  802017:	5f                   	pop    %edi
  802018:	5d                   	pop    %ebp
  802019:	c3                   	ret    

0080201a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80201a:	55                   	push   %ebp
  80201b:	89 e5                	mov    %esp,%ebp
  80201d:	57                   	push   %edi
  80201e:	56                   	push   %esi
  80201f:	53                   	push   %ebx
  802020:	83 ec 28             	sub    $0x28,%esp
  802023:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802026:	56                   	push   %esi
  802027:	e8 21 f1 ff ff       	call   80114d <fd2data>
  80202c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80202e:	83 c4 10             	add    $0x10,%esp
  802031:	bf 00 00 00 00       	mov    $0x0,%edi
  802036:	eb 4b                	jmp    802083 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802038:	89 da                	mov    %ebx,%edx
  80203a:	89 f0                	mov    %esi,%eax
  80203c:	e8 64 ff ff ff       	call   801fa5 <_pipeisclosed>
  802041:	85 c0                	test   %eax,%eax
  802043:	75 48                	jne    80208d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802045:	e8 af eb ff ff       	call   800bf9 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80204a:	8b 43 04             	mov    0x4(%ebx),%eax
  80204d:	8b 0b                	mov    (%ebx),%ecx
  80204f:	8d 51 20             	lea    0x20(%ecx),%edx
  802052:	39 d0                	cmp    %edx,%eax
  802054:	73 e2                	jae    802038 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802056:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802059:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80205d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802060:	89 c2                	mov    %eax,%edx
  802062:	c1 fa 1f             	sar    $0x1f,%edx
  802065:	89 d1                	mov    %edx,%ecx
  802067:	c1 e9 1b             	shr    $0x1b,%ecx
  80206a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80206d:	83 e2 1f             	and    $0x1f,%edx
  802070:	29 ca                	sub    %ecx,%edx
  802072:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802076:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80207a:	83 c0 01             	add    $0x1,%eax
  80207d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802080:	83 c7 01             	add    $0x1,%edi
  802083:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802086:	75 c2                	jne    80204a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802088:	8b 45 10             	mov    0x10(%ebp),%eax
  80208b:	eb 05                	jmp    802092 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80208d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802092:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802095:	5b                   	pop    %ebx
  802096:	5e                   	pop    %esi
  802097:	5f                   	pop    %edi
  802098:	5d                   	pop    %ebp
  802099:	c3                   	ret    

0080209a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80209a:	55                   	push   %ebp
  80209b:	89 e5                	mov    %esp,%ebp
  80209d:	57                   	push   %edi
  80209e:	56                   	push   %esi
  80209f:	53                   	push   %ebx
  8020a0:	83 ec 18             	sub    $0x18,%esp
  8020a3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8020a6:	57                   	push   %edi
  8020a7:	e8 a1 f0 ff ff       	call   80114d <fd2data>
  8020ac:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020ae:	83 c4 10             	add    $0x10,%esp
  8020b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020b6:	eb 3d                	jmp    8020f5 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8020b8:	85 db                	test   %ebx,%ebx
  8020ba:	74 04                	je     8020c0 <devpipe_read+0x26>
				return i;
  8020bc:	89 d8                	mov    %ebx,%eax
  8020be:	eb 44                	jmp    802104 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8020c0:	89 f2                	mov    %esi,%edx
  8020c2:	89 f8                	mov    %edi,%eax
  8020c4:	e8 dc fe ff ff       	call   801fa5 <_pipeisclosed>
  8020c9:	85 c0                	test   %eax,%eax
  8020cb:	75 32                	jne    8020ff <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8020cd:	e8 27 eb ff ff       	call   800bf9 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8020d2:	8b 06                	mov    (%esi),%eax
  8020d4:	3b 46 04             	cmp    0x4(%esi),%eax
  8020d7:	74 df                	je     8020b8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020d9:	99                   	cltd   
  8020da:	c1 ea 1b             	shr    $0x1b,%edx
  8020dd:	01 d0                	add    %edx,%eax
  8020df:	83 e0 1f             	and    $0x1f,%eax
  8020e2:	29 d0                	sub    %edx,%eax
  8020e4:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8020e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020ec:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8020ef:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020f2:	83 c3 01             	add    $0x1,%ebx
  8020f5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020f8:	75 d8                	jne    8020d2 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8020fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8020fd:	eb 05                	jmp    802104 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020ff:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802104:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802107:	5b                   	pop    %ebx
  802108:	5e                   	pop    %esi
  802109:	5f                   	pop    %edi
  80210a:	5d                   	pop    %ebp
  80210b:	c3                   	ret    

0080210c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80210c:	55                   	push   %ebp
  80210d:	89 e5                	mov    %esp,%ebp
  80210f:	56                   	push   %esi
  802110:	53                   	push   %ebx
  802111:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802114:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802117:	50                   	push   %eax
  802118:	e8 47 f0 ff ff       	call   801164 <fd_alloc>
  80211d:	83 c4 10             	add    $0x10,%esp
  802120:	89 c2                	mov    %eax,%edx
  802122:	85 c0                	test   %eax,%eax
  802124:	0f 88 2c 01 00 00    	js     802256 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80212a:	83 ec 04             	sub    $0x4,%esp
  80212d:	68 07 04 00 00       	push   $0x407
  802132:	ff 75 f4             	pushl  -0xc(%ebp)
  802135:	6a 00                	push   $0x0
  802137:	e8 dc ea ff ff       	call   800c18 <sys_page_alloc>
  80213c:	83 c4 10             	add    $0x10,%esp
  80213f:	89 c2                	mov    %eax,%edx
  802141:	85 c0                	test   %eax,%eax
  802143:	0f 88 0d 01 00 00    	js     802256 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802149:	83 ec 0c             	sub    $0xc,%esp
  80214c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80214f:	50                   	push   %eax
  802150:	e8 0f f0 ff ff       	call   801164 <fd_alloc>
  802155:	89 c3                	mov    %eax,%ebx
  802157:	83 c4 10             	add    $0x10,%esp
  80215a:	85 c0                	test   %eax,%eax
  80215c:	0f 88 e2 00 00 00    	js     802244 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802162:	83 ec 04             	sub    $0x4,%esp
  802165:	68 07 04 00 00       	push   $0x407
  80216a:	ff 75 f0             	pushl  -0x10(%ebp)
  80216d:	6a 00                	push   $0x0
  80216f:	e8 a4 ea ff ff       	call   800c18 <sys_page_alloc>
  802174:	89 c3                	mov    %eax,%ebx
  802176:	83 c4 10             	add    $0x10,%esp
  802179:	85 c0                	test   %eax,%eax
  80217b:	0f 88 c3 00 00 00    	js     802244 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802181:	83 ec 0c             	sub    $0xc,%esp
  802184:	ff 75 f4             	pushl  -0xc(%ebp)
  802187:	e8 c1 ef ff ff       	call   80114d <fd2data>
  80218c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80218e:	83 c4 0c             	add    $0xc,%esp
  802191:	68 07 04 00 00       	push   $0x407
  802196:	50                   	push   %eax
  802197:	6a 00                	push   $0x0
  802199:	e8 7a ea ff ff       	call   800c18 <sys_page_alloc>
  80219e:	89 c3                	mov    %eax,%ebx
  8021a0:	83 c4 10             	add    $0x10,%esp
  8021a3:	85 c0                	test   %eax,%eax
  8021a5:	0f 88 89 00 00 00    	js     802234 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021ab:	83 ec 0c             	sub    $0xc,%esp
  8021ae:	ff 75 f0             	pushl  -0x10(%ebp)
  8021b1:	e8 97 ef ff ff       	call   80114d <fd2data>
  8021b6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021bd:	50                   	push   %eax
  8021be:	6a 00                	push   $0x0
  8021c0:	56                   	push   %esi
  8021c1:	6a 00                	push   $0x0
  8021c3:	e8 93 ea ff ff       	call   800c5b <sys_page_map>
  8021c8:	89 c3                	mov    %eax,%ebx
  8021ca:	83 c4 20             	add    $0x20,%esp
  8021cd:	85 c0                	test   %eax,%eax
  8021cf:	78 55                	js     802226 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8021d1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8021d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021da:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8021dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021df:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8021e6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8021ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021ef:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8021f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021f4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8021fb:	83 ec 0c             	sub    $0xc,%esp
  8021fe:	ff 75 f4             	pushl  -0xc(%ebp)
  802201:	e8 37 ef ff ff       	call   80113d <fd2num>
  802206:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802209:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80220b:	83 c4 04             	add    $0x4,%esp
  80220e:	ff 75 f0             	pushl  -0x10(%ebp)
  802211:	e8 27 ef ff ff       	call   80113d <fd2num>
  802216:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802219:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80221c:	83 c4 10             	add    $0x10,%esp
  80221f:	ba 00 00 00 00       	mov    $0x0,%edx
  802224:	eb 30                	jmp    802256 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802226:	83 ec 08             	sub    $0x8,%esp
  802229:	56                   	push   %esi
  80222a:	6a 00                	push   $0x0
  80222c:	e8 6c ea ff ff       	call   800c9d <sys_page_unmap>
  802231:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802234:	83 ec 08             	sub    $0x8,%esp
  802237:	ff 75 f0             	pushl  -0x10(%ebp)
  80223a:	6a 00                	push   $0x0
  80223c:	e8 5c ea ff ff       	call   800c9d <sys_page_unmap>
  802241:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802244:	83 ec 08             	sub    $0x8,%esp
  802247:	ff 75 f4             	pushl  -0xc(%ebp)
  80224a:	6a 00                	push   $0x0
  80224c:	e8 4c ea ff ff       	call   800c9d <sys_page_unmap>
  802251:	83 c4 10             	add    $0x10,%esp
  802254:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802256:	89 d0                	mov    %edx,%eax
  802258:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80225b:	5b                   	pop    %ebx
  80225c:	5e                   	pop    %esi
  80225d:	5d                   	pop    %ebp
  80225e:	c3                   	ret    

0080225f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80225f:	55                   	push   %ebp
  802260:	89 e5                	mov    %esp,%ebp
  802262:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802265:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802268:	50                   	push   %eax
  802269:	ff 75 08             	pushl  0x8(%ebp)
  80226c:	e8 42 ef ff ff       	call   8011b3 <fd_lookup>
  802271:	83 c4 10             	add    $0x10,%esp
  802274:	85 c0                	test   %eax,%eax
  802276:	78 18                	js     802290 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802278:	83 ec 0c             	sub    $0xc,%esp
  80227b:	ff 75 f4             	pushl  -0xc(%ebp)
  80227e:	e8 ca ee ff ff       	call   80114d <fd2data>
	return _pipeisclosed(fd, p);
  802283:	89 c2                	mov    %eax,%edx
  802285:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802288:	e8 18 fd ff ff       	call   801fa5 <_pipeisclosed>
  80228d:	83 c4 10             	add    $0x10,%esp
}
  802290:	c9                   	leave  
  802291:	c3                   	ret    

00802292 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802292:	55                   	push   %ebp
  802293:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802295:	b8 00 00 00 00       	mov    $0x0,%eax
  80229a:	5d                   	pop    %ebp
  80229b:	c3                   	ret    

0080229c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80229c:	55                   	push   %ebp
  80229d:	89 e5                	mov    %esp,%ebp
  80229f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8022a2:	68 db 2e 80 00       	push   $0x802edb
  8022a7:	ff 75 0c             	pushl  0xc(%ebp)
  8022aa:	e8 66 e5 ff ff       	call   800815 <strcpy>
	return 0;
}
  8022af:	b8 00 00 00 00       	mov    $0x0,%eax
  8022b4:	c9                   	leave  
  8022b5:	c3                   	ret    

008022b6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022b6:	55                   	push   %ebp
  8022b7:	89 e5                	mov    %esp,%ebp
  8022b9:	57                   	push   %edi
  8022ba:	56                   	push   %esi
  8022bb:	53                   	push   %ebx
  8022bc:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022c2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022c7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022cd:	eb 2d                	jmp    8022fc <devcons_write+0x46>
		m = n - tot;
  8022cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022d2:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8022d4:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8022d7:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8022dc:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022df:	83 ec 04             	sub    $0x4,%esp
  8022e2:	53                   	push   %ebx
  8022e3:	03 45 0c             	add    0xc(%ebp),%eax
  8022e6:	50                   	push   %eax
  8022e7:	57                   	push   %edi
  8022e8:	e8 ba e6 ff ff       	call   8009a7 <memmove>
		sys_cputs(buf, m);
  8022ed:	83 c4 08             	add    $0x8,%esp
  8022f0:	53                   	push   %ebx
  8022f1:	57                   	push   %edi
  8022f2:	e8 65 e8 ff ff       	call   800b5c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022f7:	01 de                	add    %ebx,%esi
  8022f9:	83 c4 10             	add    $0x10,%esp
  8022fc:	89 f0                	mov    %esi,%eax
  8022fe:	3b 75 10             	cmp    0x10(%ebp),%esi
  802301:	72 cc                	jb     8022cf <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802303:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802306:	5b                   	pop    %ebx
  802307:	5e                   	pop    %esi
  802308:	5f                   	pop    %edi
  802309:	5d                   	pop    %ebp
  80230a:	c3                   	ret    

0080230b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80230b:	55                   	push   %ebp
  80230c:	89 e5                	mov    %esp,%ebp
  80230e:	83 ec 08             	sub    $0x8,%esp
  802311:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802316:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80231a:	74 2a                	je     802346 <devcons_read+0x3b>
  80231c:	eb 05                	jmp    802323 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80231e:	e8 d6 e8 ff ff       	call   800bf9 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802323:	e8 52 e8 ff ff       	call   800b7a <sys_cgetc>
  802328:	85 c0                	test   %eax,%eax
  80232a:	74 f2                	je     80231e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80232c:	85 c0                	test   %eax,%eax
  80232e:	78 16                	js     802346 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802330:	83 f8 04             	cmp    $0x4,%eax
  802333:	74 0c                	je     802341 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802335:	8b 55 0c             	mov    0xc(%ebp),%edx
  802338:	88 02                	mov    %al,(%edx)
	return 1;
  80233a:	b8 01 00 00 00       	mov    $0x1,%eax
  80233f:	eb 05                	jmp    802346 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802341:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802346:	c9                   	leave  
  802347:	c3                   	ret    

00802348 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802348:	55                   	push   %ebp
  802349:	89 e5                	mov    %esp,%ebp
  80234b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80234e:	8b 45 08             	mov    0x8(%ebp),%eax
  802351:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802354:	6a 01                	push   $0x1
  802356:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802359:	50                   	push   %eax
  80235a:	e8 fd e7 ff ff       	call   800b5c <sys_cputs>
}
  80235f:	83 c4 10             	add    $0x10,%esp
  802362:	c9                   	leave  
  802363:	c3                   	ret    

00802364 <getchar>:

int
getchar(void)
{
  802364:	55                   	push   %ebp
  802365:	89 e5                	mov    %esp,%ebp
  802367:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80236a:	6a 01                	push   $0x1
  80236c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80236f:	50                   	push   %eax
  802370:	6a 00                	push   $0x0
  802372:	e8 a2 f0 ff ff       	call   801419 <read>
	if (r < 0)
  802377:	83 c4 10             	add    $0x10,%esp
  80237a:	85 c0                	test   %eax,%eax
  80237c:	78 0f                	js     80238d <getchar+0x29>
		return r;
	if (r < 1)
  80237e:	85 c0                	test   %eax,%eax
  802380:	7e 06                	jle    802388 <getchar+0x24>
		return -E_EOF;
	return c;
  802382:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802386:	eb 05                	jmp    80238d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802388:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80238d:	c9                   	leave  
  80238e:	c3                   	ret    

0080238f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80238f:	55                   	push   %ebp
  802390:	89 e5                	mov    %esp,%ebp
  802392:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802395:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802398:	50                   	push   %eax
  802399:	ff 75 08             	pushl  0x8(%ebp)
  80239c:	e8 12 ee ff ff       	call   8011b3 <fd_lookup>
  8023a1:	83 c4 10             	add    $0x10,%esp
  8023a4:	85 c0                	test   %eax,%eax
  8023a6:	78 11                	js     8023b9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8023a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ab:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8023b1:	39 10                	cmp    %edx,(%eax)
  8023b3:	0f 94 c0             	sete   %al
  8023b6:	0f b6 c0             	movzbl %al,%eax
}
  8023b9:	c9                   	leave  
  8023ba:	c3                   	ret    

008023bb <opencons>:

int
opencons(void)
{
  8023bb:	55                   	push   %ebp
  8023bc:	89 e5                	mov    %esp,%ebp
  8023be:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023c4:	50                   	push   %eax
  8023c5:	e8 9a ed ff ff       	call   801164 <fd_alloc>
  8023ca:	83 c4 10             	add    $0x10,%esp
		return r;
  8023cd:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023cf:	85 c0                	test   %eax,%eax
  8023d1:	78 3e                	js     802411 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023d3:	83 ec 04             	sub    $0x4,%esp
  8023d6:	68 07 04 00 00       	push   $0x407
  8023db:	ff 75 f4             	pushl  -0xc(%ebp)
  8023de:	6a 00                	push   $0x0
  8023e0:	e8 33 e8 ff ff       	call   800c18 <sys_page_alloc>
  8023e5:	83 c4 10             	add    $0x10,%esp
		return r;
  8023e8:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023ea:	85 c0                	test   %eax,%eax
  8023ec:	78 23                	js     802411 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8023ee:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8023f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023f7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023fc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802403:	83 ec 0c             	sub    $0xc,%esp
  802406:	50                   	push   %eax
  802407:	e8 31 ed ff ff       	call   80113d <fd2num>
  80240c:	89 c2                	mov    %eax,%edx
  80240e:	83 c4 10             	add    $0x10,%esp
}
  802411:	89 d0                	mov    %edx,%eax
  802413:	c9                   	leave  
  802414:	c3                   	ret    

00802415 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802415:	55                   	push   %ebp
  802416:	89 e5                	mov    %esp,%ebp
  802418:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80241b:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802422:	75 2a                	jne    80244e <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802424:	83 ec 04             	sub    $0x4,%esp
  802427:	6a 07                	push   $0x7
  802429:	68 00 f0 bf ee       	push   $0xeebff000
  80242e:	6a 00                	push   $0x0
  802430:	e8 e3 e7 ff ff       	call   800c18 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802435:	83 c4 10             	add    $0x10,%esp
  802438:	85 c0                	test   %eax,%eax
  80243a:	79 12                	jns    80244e <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80243c:	50                   	push   %eax
  80243d:	68 e7 2e 80 00       	push   $0x802ee7
  802442:	6a 23                	push   $0x23
  802444:	68 eb 2e 80 00       	push   $0x802eeb
  802449:	e8 69 dd ff ff       	call   8001b7 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80244e:	8b 45 08             	mov    0x8(%ebp),%eax
  802451:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802456:	83 ec 08             	sub    $0x8,%esp
  802459:	68 80 24 80 00       	push   $0x802480
  80245e:	6a 00                	push   $0x0
  802460:	e8 fe e8 ff ff       	call   800d63 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802465:	83 c4 10             	add    $0x10,%esp
  802468:	85 c0                	test   %eax,%eax
  80246a:	79 12                	jns    80247e <set_pgfault_handler+0x69>
		panic("%e\n", r);
  80246c:	50                   	push   %eax
  80246d:	68 e7 2e 80 00       	push   $0x802ee7
  802472:	6a 2c                	push   $0x2c
  802474:	68 eb 2e 80 00       	push   $0x802eeb
  802479:	e8 39 dd ff ff       	call   8001b7 <_panic>
	}
}
  80247e:	c9                   	leave  
  80247f:	c3                   	ret    

00802480 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802480:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802481:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802486:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802488:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  80248b:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  80248f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802494:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802498:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  80249a:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  80249d:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  80249e:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8024a1:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8024a2:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8024a3:	c3                   	ret    

008024a4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8024a4:	55                   	push   %ebp
  8024a5:	89 e5                	mov    %esp,%ebp
  8024a7:	56                   	push   %esi
  8024a8:	53                   	push   %ebx
  8024a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8024ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024af:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8024b2:	85 c0                	test   %eax,%eax
  8024b4:	75 12                	jne    8024c8 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8024b6:	83 ec 0c             	sub    $0xc,%esp
  8024b9:	68 00 00 c0 ee       	push   $0xeec00000
  8024be:	e8 05 e9 ff ff       	call   800dc8 <sys_ipc_recv>
  8024c3:	83 c4 10             	add    $0x10,%esp
  8024c6:	eb 0c                	jmp    8024d4 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8024c8:	83 ec 0c             	sub    $0xc,%esp
  8024cb:	50                   	push   %eax
  8024cc:	e8 f7 e8 ff ff       	call   800dc8 <sys_ipc_recv>
  8024d1:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8024d4:	85 f6                	test   %esi,%esi
  8024d6:	0f 95 c1             	setne  %cl
  8024d9:	85 db                	test   %ebx,%ebx
  8024db:	0f 95 c2             	setne  %dl
  8024de:	84 d1                	test   %dl,%cl
  8024e0:	74 09                	je     8024eb <ipc_recv+0x47>
  8024e2:	89 c2                	mov    %eax,%edx
  8024e4:	c1 ea 1f             	shr    $0x1f,%edx
  8024e7:	84 d2                	test   %dl,%dl
  8024e9:	75 2d                	jne    802518 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8024eb:	85 f6                	test   %esi,%esi
  8024ed:	74 0d                	je     8024fc <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8024ef:	a1 04 40 80 00       	mov    0x804004,%eax
  8024f4:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  8024fa:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8024fc:	85 db                	test   %ebx,%ebx
  8024fe:	74 0d                	je     80250d <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802500:	a1 04 40 80 00       	mov    0x804004,%eax
  802505:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  80250b:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80250d:	a1 04 40 80 00       	mov    0x804004,%eax
  802512:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  802518:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80251b:	5b                   	pop    %ebx
  80251c:	5e                   	pop    %esi
  80251d:	5d                   	pop    %ebp
  80251e:	c3                   	ret    

0080251f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80251f:	55                   	push   %ebp
  802520:	89 e5                	mov    %esp,%ebp
  802522:	57                   	push   %edi
  802523:	56                   	push   %esi
  802524:	53                   	push   %ebx
  802525:	83 ec 0c             	sub    $0xc,%esp
  802528:	8b 7d 08             	mov    0x8(%ebp),%edi
  80252b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80252e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802531:	85 db                	test   %ebx,%ebx
  802533:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802538:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80253b:	ff 75 14             	pushl  0x14(%ebp)
  80253e:	53                   	push   %ebx
  80253f:	56                   	push   %esi
  802540:	57                   	push   %edi
  802541:	e8 5f e8 ff ff       	call   800da5 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802546:	89 c2                	mov    %eax,%edx
  802548:	c1 ea 1f             	shr    $0x1f,%edx
  80254b:	83 c4 10             	add    $0x10,%esp
  80254e:	84 d2                	test   %dl,%dl
  802550:	74 17                	je     802569 <ipc_send+0x4a>
  802552:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802555:	74 12                	je     802569 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802557:	50                   	push   %eax
  802558:	68 f9 2e 80 00       	push   $0x802ef9
  80255d:	6a 47                	push   $0x47
  80255f:	68 07 2f 80 00       	push   $0x802f07
  802564:	e8 4e dc ff ff       	call   8001b7 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802569:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80256c:	75 07                	jne    802575 <ipc_send+0x56>
			sys_yield();
  80256e:	e8 86 e6 ff ff       	call   800bf9 <sys_yield>
  802573:	eb c6                	jmp    80253b <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802575:	85 c0                	test   %eax,%eax
  802577:	75 c2                	jne    80253b <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802579:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80257c:	5b                   	pop    %ebx
  80257d:	5e                   	pop    %esi
  80257e:	5f                   	pop    %edi
  80257f:	5d                   	pop    %ebp
  802580:	c3                   	ret    

00802581 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802581:	55                   	push   %ebp
  802582:	89 e5                	mov    %esp,%ebp
  802584:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802587:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80258c:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  802592:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802598:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  80259e:	39 ca                	cmp    %ecx,%edx
  8025a0:	75 10                	jne    8025b2 <ipc_find_env+0x31>
			return envs[i].env_id;
  8025a2:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  8025a8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8025ad:	8b 40 7c             	mov    0x7c(%eax),%eax
  8025b0:	eb 0f                	jmp    8025c1 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8025b2:	83 c0 01             	add    $0x1,%eax
  8025b5:	3d 00 04 00 00       	cmp    $0x400,%eax
  8025ba:	75 d0                	jne    80258c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8025bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8025c1:	5d                   	pop    %ebp
  8025c2:	c3                   	ret    

008025c3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025c3:	55                   	push   %ebp
  8025c4:	89 e5                	mov    %esp,%ebp
  8025c6:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025c9:	89 d0                	mov    %edx,%eax
  8025cb:	c1 e8 16             	shr    $0x16,%eax
  8025ce:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8025d5:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025da:	f6 c1 01             	test   $0x1,%cl
  8025dd:	74 1d                	je     8025fc <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8025df:	c1 ea 0c             	shr    $0xc,%edx
  8025e2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8025e9:	f6 c2 01             	test   $0x1,%dl
  8025ec:	74 0e                	je     8025fc <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025ee:	c1 ea 0c             	shr    $0xc,%edx
  8025f1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8025f8:	ef 
  8025f9:	0f b7 c0             	movzwl %ax,%eax
}
  8025fc:	5d                   	pop    %ebp
  8025fd:	c3                   	ret    
  8025fe:	66 90                	xchg   %ax,%ax

00802600 <__udivdi3>:
  802600:	55                   	push   %ebp
  802601:	57                   	push   %edi
  802602:	56                   	push   %esi
  802603:	53                   	push   %ebx
  802604:	83 ec 1c             	sub    $0x1c,%esp
  802607:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80260b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80260f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802613:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802617:	85 f6                	test   %esi,%esi
  802619:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80261d:	89 ca                	mov    %ecx,%edx
  80261f:	89 f8                	mov    %edi,%eax
  802621:	75 3d                	jne    802660 <__udivdi3+0x60>
  802623:	39 cf                	cmp    %ecx,%edi
  802625:	0f 87 c5 00 00 00    	ja     8026f0 <__udivdi3+0xf0>
  80262b:	85 ff                	test   %edi,%edi
  80262d:	89 fd                	mov    %edi,%ebp
  80262f:	75 0b                	jne    80263c <__udivdi3+0x3c>
  802631:	b8 01 00 00 00       	mov    $0x1,%eax
  802636:	31 d2                	xor    %edx,%edx
  802638:	f7 f7                	div    %edi
  80263a:	89 c5                	mov    %eax,%ebp
  80263c:	89 c8                	mov    %ecx,%eax
  80263e:	31 d2                	xor    %edx,%edx
  802640:	f7 f5                	div    %ebp
  802642:	89 c1                	mov    %eax,%ecx
  802644:	89 d8                	mov    %ebx,%eax
  802646:	89 cf                	mov    %ecx,%edi
  802648:	f7 f5                	div    %ebp
  80264a:	89 c3                	mov    %eax,%ebx
  80264c:	89 d8                	mov    %ebx,%eax
  80264e:	89 fa                	mov    %edi,%edx
  802650:	83 c4 1c             	add    $0x1c,%esp
  802653:	5b                   	pop    %ebx
  802654:	5e                   	pop    %esi
  802655:	5f                   	pop    %edi
  802656:	5d                   	pop    %ebp
  802657:	c3                   	ret    
  802658:	90                   	nop
  802659:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802660:	39 ce                	cmp    %ecx,%esi
  802662:	77 74                	ja     8026d8 <__udivdi3+0xd8>
  802664:	0f bd fe             	bsr    %esi,%edi
  802667:	83 f7 1f             	xor    $0x1f,%edi
  80266a:	0f 84 98 00 00 00    	je     802708 <__udivdi3+0x108>
  802670:	bb 20 00 00 00       	mov    $0x20,%ebx
  802675:	89 f9                	mov    %edi,%ecx
  802677:	89 c5                	mov    %eax,%ebp
  802679:	29 fb                	sub    %edi,%ebx
  80267b:	d3 e6                	shl    %cl,%esi
  80267d:	89 d9                	mov    %ebx,%ecx
  80267f:	d3 ed                	shr    %cl,%ebp
  802681:	89 f9                	mov    %edi,%ecx
  802683:	d3 e0                	shl    %cl,%eax
  802685:	09 ee                	or     %ebp,%esi
  802687:	89 d9                	mov    %ebx,%ecx
  802689:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80268d:	89 d5                	mov    %edx,%ebp
  80268f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802693:	d3 ed                	shr    %cl,%ebp
  802695:	89 f9                	mov    %edi,%ecx
  802697:	d3 e2                	shl    %cl,%edx
  802699:	89 d9                	mov    %ebx,%ecx
  80269b:	d3 e8                	shr    %cl,%eax
  80269d:	09 c2                	or     %eax,%edx
  80269f:	89 d0                	mov    %edx,%eax
  8026a1:	89 ea                	mov    %ebp,%edx
  8026a3:	f7 f6                	div    %esi
  8026a5:	89 d5                	mov    %edx,%ebp
  8026a7:	89 c3                	mov    %eax,%ebx
  8026a9:	f7 64 24 0c          	mull   0xc(%esp)
  8026ad:	39 d5                	cmp    %edx,%ebp
  8026af:	72 10                	jb     8026c1 <__udivdi3+0xc1>
  8026b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8026b5:	89 f9                	mov    %edi,%ecx
  8026b7:	d3 e6                	shl    %cl,%esi
  8026b9:	39 c6                	cmp    %eax,%esi
  8026bb:	73 07                	jae    8026c4 <__udivdi3+0xc4>
  8026bd:	39 d5                	cmp    %edx,%ebp
  8026bf:	75 03                	jne    8026c4 <__udivdi3+0xc4>
  8026c1:	83 eb 01             	sub    $0x1,%ebx
  8026c4:	31 ff                	xor    %edi,%edi
  8026c6:	89 d8                	mov    %ebx,%eax
  8026c8:	89 fa                	mov    %edi,%edx
  8026ca:	83 c4 1c             	add    $0x1c,%esp
  8026cd:	5b                   	pop    %ebx
  8026ce:	5e                   	pop    %esi
  8026cf:	5f                   	pop    %edi
  8026d0:	5d                   	pop    %ebp
  8026d1:	c3                   	ret    
  8026d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026d8:	31 ff                	xor    %edi,%edi
  8026da:	31 db                	xor    %ebx,%ebx
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
  8026f0:	89 d8                	mov    %ebx,%eax
  8026f2:	f7 f7                	div    %edi
  8026f4:	31 ff                	xor    %edi,%edi
  8026f6:	89 c3                	mov    %eax,%ebx
  8026f8:	89 d8                	mov    %ebx,%eax
  8026fa:	89 fa                	mov    %edi,%edx
  8026fc:	83 c4 1c             	add    $0x1c,%esp
  8026ff:	5b                   	pop    %ebx
  802700:	5e                   	pop    %esi
  802701:	5f                   	pop    %edi
  802702:	5d                   	pop    %ebp
  802703:	c3                   	ret    
  802704:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802708:	39 ce                	cmp    %ecx,%esi
  80270a:	72 0c                	jb     802718 <__udivdi3+0x118>
  80270c:	31 db                	xor    %ebx,%ebx
  80270e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802712:	0f 87 34 ff ff ff    	ja     80264c <__udivdi3+0x4c>
  802718:	bb 01 00 00 00       	mov    $0x1,%ebx
  80271d:	e9 2a ff ff ff       	jmp    80264c <__udivdi3+0x4c>
  802722:	66 90                	xchg   %ax,%ax
  802724:	66 90                	xchg   %ax,%ax
  802726:	66 90                	xchg   %ax,%ax
  802728:	66 90                	xchg   %ax,%ax
  80272a:	66 90                	xchg   %ax,%ax
  80272c:	66 90                	xchg   %ax,%ax
  80272e:	66 90                	xchg   %ax,%ax

00802730 <__umoddi3>:
  802730:	55                   	push   %ebp
  802731:	57                   	push   %edi
  802732:	56                   	push   %esi
  802733:	53                   	push   %ebx
  802734:	83 ec 1c             	sub    $0x1c,%esp
  802737:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80273b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80273f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802743:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802747:	85 d2                	test   %edx,%edx
  802749:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80274d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802751:	89 f3                	mov    %esi,%ebx
  802753:	89 3c 24             	mov    %edi,(%esp)
  802756:	89 74 24 04          	mov    %esi,0x4(%esp)
  80275a:	75 1c                	jne    802778 <__umoddi3+0x48>
  80275c:	39 f7                	cmp    %esi,%edi
  80275e:	76 50                	jbe    8027b0 <__umoddi3+0x80>
  802760:	89 c8                	mov    %ecx,%eax
  802762:	89 f2                	mov    %esi,%edx
  802764:	f7 f7                	div    %edi
  802766:	89 d0                	mov    %edx,%eax
  802768:	31 d2                	xor    %edx,%edx
  80276a:	83 c4 1c             	add    $0x1c,%esp
  80276d:	5b                   	pop    %ebx
  80276e:	5e                   	pop    %esi
  80276f:	5f                   	pop    %edi
  802770:	5d                   	pop    %ebp
  802771:	c3                   	ret    
  802772:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802778:	39 f2                	cmp    %esi,%edx
  80277a:	89 d0                	mov    %edx,%eax
  80277c:	77 52                	ja     8027d0 <__umoddi3+0xa0>
  80277e:	0f bd ea             	bsr    %edx,%ebp
  802781:	83 f5 1f             	xor    $0x1f,%ebp
  802784:	75 5a                	jne    8027e0 <__umoddi3+0xb0>
  802786:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80278a:	0f 82 e0 00 00 00    	jb     802870 <__umoddi3+0x140>
  802790:	39 0c 24             	cmp    %ecx,(%esp)
  802793:	0f 86 d7 00 00 00    	jbe    802870 <__umoddi3+0x140>
  802799:	8b 44 24 08          	mov    0x8(%esp),%eax
  80279d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8027a1:	83 c4 1c             	add    $0x1c,%esp
  8027a4:	5b                   	pop    %ebx
  8027a5:	5e                   	pop    %esi
  8027a6:	5f                   	pop    %edi
  8027a7:	5d                   	pop    %ebp
  8027a8:	c3                   	ret    
  8027a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027b0:	85 ff                	test   %edi,%edi
  8027b2:	89 fd                	mov    %edi,%ebp
  8027b4:	75 0b                	jne    8027c1 <__umoddi3+0x91>
  8027b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8027bb:	31 d2                	xor    %edx,%edx
  8027bd:	f7 f7                	div    %edi
  8027bf:	89 c5                	mov    %eax,%ebp
  8027c1:	89 f0                	mov    %esi,%eax
  8027c3:	31 d2                	xor    %edx,%edx
  8027c5:	f7 f5                	div    %ebp
  8027c7:	89 c8                	mov    %ecx,%eax
  8027c9:	f7 f5                	div    %ebp
  8027cb:	89 d0                	mov    %edx,%eax
  8027cd:	eb 99                	jmp    802768 <__umoddi3+0x38>
  8027cf:	90                   	nop
  8027d0:	89 c8                	mov    %ecx,%eax
  8027d2:	89 f2                	mov    %esi,%edx
  8027d4:	83 c4 1c             	add    $0x1c,%esp
  8027d7:	5b                   	pop    %ebx
  8027d8:	5e                   	pop    %esi
  8027d9:	5f                   	pop    %edi
  8027da:	5d                   	pop    %ebp
  8027db:	c3                   	ret    
  8027dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027e0:	8b 34 24             	mov    (%esp),%esi
  8027e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8027e8:	89 e9                	mov    %ebp,%ecx
  8027ea:	29 ef                	sub    %ebp,%edi
  8027ec:	d3 e0                	shl    %cl,%eax
  8027ee:	89 f9                	mov    %edi,%ecx
  8027f0:	89 f2                	mov    %esi,%edx
  8027f2:	d3 ea                	shr    %cl,%edx
  8027f4:	89 e9                	mov    %ebp,%ecx
  8027f6:	09 c2                	or     %eax,%edx
  8027f8:	89 d8                	mov    %ebx,%eax
  8027fa:	89 14 24             	mov    %edx,(%esp)
  8027fd:	89 f2                	mov    %esi,%edx
  8027ff:	d3 e2                	shl    %cl,%edx
  802801:	89 f9                	mov    %edi,%ecx
  802803:	89 54 24 04          	mov    %edx,0x4(%esp)
  802807:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80280b:	d3 e8                	shr    %cl,%eax
  80280d:	89 e9                	mov    %ebp,%ecx
  80280f:	89 c6                	mov    %eax,%esi
  802811:	d3 e3                	shl    %cl,%ebx
  802813:	89 f9                	mov    %edi,%ecx
  802815:	89 d0                	mov    %edx,%eax
  802817:	d3 e8                	shr    %cl,%eax
  802819:	89 e9                	mov    %ebp,%ecx
  80281b:	09 d8                	or     %ebx,%eax
  80281d:	89 d3                	mov    %edx,%ebx
  80281f:	89 f2                	mov    %esi,%edx
  802821:	f7 34 24             	divl   (%esp)
  802824:	89 d6                	mov    %edx,%esi
  802826:	d3 e3                	shl    %cl,%ebx
  802828:	f7 64 24 04          	mull   0x4(%esp)
  80282c:	39 d6                	cmp    %edx,%esi
  80282e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802832:	89 d1                	mov    %edx,%ecx
  802834:	89 c3                	mov    %eax,%ebx
  802836:	72 08                	jb     802840 <__umoddi3+0x110>
  802838:	75 11                	jne    80284b <__umoddi3+0x11b>
  80283a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80283e:	73 0b                	jae    80284b <__umoddi3+0x11b>
  802840:	2b 44 24 04          	sub    0x4(%esp),%eax
  802844:	1b 14 24             	sbb    (%esp),%edx
  802847:	89 d1                	mov    %edx,%ecx
  802849:	89 c3                	mov    %eax,%ebx
  80284b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80284f:	29 da                	sub    %ebx,%edx
  802851:	19 ce                	sbb    %ecx,%esi
  802853:	89 f9                	mov    %edi,%ecx
  802855:	89 f0                	mov    %esi,%eax
  802857:	d3 e0                	shl    %cl,%eax
  802859:	89 e9                	mov    %ebp,%ecx
  80285b:	d3 ea                	shr    %cl,%edx
  80285d:	89 e9                	mov    %ebp,%ecx
  80285f:	d3 ee                	shr    %cl,%esi
  802861:	09 d0                	or     %edx,%eax
  802863:	89 f2                	mov    %esi,%edx
  802865:	83 c4 1c             	add    $0x1c,%esp
  802868:	5b                   	pop    %ebx
  802869:	5e                   	pop    %esi
  80286a:	5f                   	pop    %edi
  80286b:	5d                   	pop    %ebp
  80286c:	c3                   	ret    
  80286d:	8d 76 00             	lea    0x0(%esi),%esi
  802870:	29 f9                	sub    %edi,%ecx
  802872:	19 d6                	sbb    %edx,%esi
  802874:	89 74 24 04          	mov    %esi,0x4(%esp)
  802878:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80287c:	e9 18 ff ff ff       	jmp    802799 <__umoddi3+0x69>
