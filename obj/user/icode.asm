
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
  80003e:	c7 05 00 40 80 00 60 	movl   $0x802b60,0x804000
  800045:	2b 80 00 

	cprintf("icode startup\n");
  800048:	68 66 2b 80 00       	push   $0x802b66
  80004d:	e8 3e 02 00 00       	call   800290 <cprintf>

	cprintf("icode: open /motd\n");
  800052:	c7 04 24 75 2b 80 00 	movl   $0x802b75,(%esp)
  800059:	e8 32 02 00 00       	call   800290 <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005e:	83 c4 08             	add    $0x8,%esp
  800061:	6a 00                	push   $0x0
  800063:	68 88 2b 80 00       	push   $0x802b88
  800068:	e8 eb 1a 00 00       	call   801b58 <open>
  80006d:	89 c6                	mov    %eax,%esi
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	85 c0                	test   %eax,%eax
  800074:	79 12                	jns    800088 <umain+0x55>
		panic("icode: open /motd: %e", fd);
  800076:	50                   	push   %eax
  800077:	68 8e 2b 80 00       	push   $0x802b8e
  80007c:	6a 0f                	push   $0xf
  80007e:	68 a4 2b 80 00       	push   $0x802ba4
  800083:	e8 2f 01 00 00       	call   8001b7 <_panic>

	cprintf("icode: read /motd\n");
  800088:	83 ec 0c             	sub    $0xc,%esp
  80008b:	68 b1 2b 80 00       	push   $0x802bb1
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
  8000b7:	e8 08 16 00 00       	call   8016c4 <read>
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	7f dd                	jg     8000a0 <umain+0x6d>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	68 c4 2b 80 00       	push   $0x802bc4
  8000cb:	e8 c0 01 00 00       	call   800290 <cprintf>
	close(fd);
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 b0 14 00 00       	call   801588 <close>

	cprintf("icode: spawn /init\n");
  8000d8:	c7 04 24 d8 2b 80 00 	movl   $0x802bd8,(%esp)
  8000df:	e8 ac 01 00 00       	call   800290 <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000eb:	68 ec 2b 80 00       	push   $0x802bec
  8000f0:	68 f5 2b 80 00       	push   $0x802bf5
  8000f5:	68 ff 2b 80 00       	push   $0x802bff
  8000fa:	68 fe 2b 80 00       	push   $0x802bfe
  8000ff:	e8 6a 20 00 00       	call   80216e <spawnl>
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	85 c0                	test   %eax,%eax
  800109:	79 12                	jns    80011d <umain+0xea>
		panic("icode: spawn /init: %e", r);
  80010b:	50                   	push   %eax
  80010c:	68 04 2c 80 00       	push   $0x802c04
  800111:	6a 1a                	push   $0x1a
  800113:	68 a4 2b 80 00       	push   $0x802ba4
  800118:	e8 9a 00 00 00       	call   8001b7 <_panic>

	cprintf("icode: exiting\n");
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	68 1b 2c 80 00       	push   $0x802c1b
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
  800149:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  80014f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800154:	a3 04 50 80 00       	mov    %eax,0x805004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800159:	85 db                	test   %ebx,%ebx
  80015b:	7e 07                	jle    800164 <libmain+0x30>
		binaryname = argv[0];
  80015d:	8b 06                	mov    (%esi),%eax
  80015f:	a3 00 40 80 00       	mov    %eax,0x804000

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
  800183:	a1 08 50 80 00       	mov    0x805008,%eax
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
  8001a3:	e8 0b 14 00 00       	call   8015b3 <close_all>
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
  8001bf:	8b 35 00 40 80 00    	mov    0x804000,%esi
  8001c5:	e8 10 0a 00 00       	call   800bda <sys_getenvid>
  8001ca:	83 ec 0c             	sub    $0xc,%esp
  8001cd:	ff 75 0c             	pushl  0xc(%ebp)
  8001d0:	ff 75 08             	pushl  0x8(%ebp)
  8001d3:	56                   	push   %esi
  8001d4:	50                   	push   %eax
  8001d5:	68 38 2c 80 00       	push   $0x802c38
  8001da:	e8 b1 00 00 00       	call   800290 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001df:	83 c4 18             	add    $0x18,%esp
  8001e2:	53                   	push   %ebx
  8001e3:	ff 75 10             	pushl  0x10(%ebp)
  8001e6:	e8 54 00 00 00       	call   80023f <vcprintf>
	cprintf("\n");
  8001eb:	c7 04 24 26 30 80 00 	movl   $0x803026,(%esp)
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
  8002f3:	e8 c8 25 00 00       	call   8028c0 <__udivdi3>
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
  800336:	e8 b5 26 00 00       	call   8029f0 <__umoddi3>
  80033b:	83 c4 14             	add    $0x14,%esp
  80033e:	0f be 80 5b 2c 80 00 	movsbl 0x802c5b(%eax),%eax
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
  80043a:	ff 24 85 a0 2d 80 00 	jmp    *0x802da0(,%eax,4)
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
  8004fe:	8b 14 85 00 2f 80 00 	mov    0x802f00(,%eax,4),%edx
  800505:	85 d2                	test   %edx,%edx
  800507:	75 18                	jne    800521 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800509:	50                   	push   %eax
  80050a:	68 73 2c 80 00       	push   $0x802c73
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
  800522:	68 8d 31 80 00       	push   $0x80318d
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
  800546:	b8 6c 2c 80 00       	mov    $0x802c6c,%eax
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
  800bc1:	68 5f 2f 80 00       	push   $0x802f5f
  800bc6:	6a 23                	push   $0x23
  800bc8:	68 7c 2f 80 00       	push   $0x802f7c
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
  800c42:	68 5f 2f 80 00       	push   $0x802f5f
  800c47:	6a 23                	push   $0x23
  800c49:	68 7c 2f 80 00       	push   $0x802f7c
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
  800c84:	68 5f 2f 80 00       	push   $0x802f5f
  800c89:	6a 23                	push   $0x23
  800c8b:	68 7c 2f 80 00       	push   $0x802f7c
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
  800cc6:	68 5f 2f 80 00       	push   $0x802f5f
  800ccb:	6a 23                	push   $0x23
  800ccd:	68 7c 2f 80 00       	push   $0x802f7c
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
  800d08:	68 5f 2f 80 00       	push   $0x802f5f
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 7c 2f 80 00       	push   $0x802f7c
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
  800d4a:	68 5f 2f 80 00       	push   $0x802f5f
  800d4f:	6a 23                	push   $0x23
  800d51:	68 7c 2f 80 00       	push   $0x802f7c
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
  800d8c:	68 5f 2f 80 00       	push   $0x802f5f
  800d91:	6a 23                	push   $0x23
  800d93:	68 7c 2f 80 00       	push   $0x802f7c
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
  800df0:	68 5f 2f 80 00       	push   $0x802f5f
  800df5:	6a 23                	push   $0x23
  800df7:	68 7c 2f 80 00       	push   $0x802f7c
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

00800e49 <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	57                   	push   %edi
  800e4d:	56                   	push   %esi
  800e4e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e54:	b8 10 00 00 00       	mov    $0x10,%eax
  800e59:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5c:	89 cb                	mov    %ecx,%ebx
  800e5e:	89 cf                	mov    %ecx,%edi
  800e60:	89 ce                	mov    %ecx,%esi
  800e62:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800e64:	5b                   	pop    %ebx
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    

00800e69 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	53                   	push   %ebx
  800e6d:	83 ec 04             	sub    $0x4,%esp
  800e70:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e73:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800e75:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e79:	74 11                	je     800e8c <pgfault+0x23>
  800e7b:	89 d8                	mov    %ebx,%eax
  800e7d:	c1 e8 0c             	shr    $0xc,%eax
  800e80:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e87:	f6 c4 08             	test   $0x8,%ah
  800e8a:	75 14                	jne    800ea0 <pgfault+0x37>
		panic("faulting access");
  800e8c:	83 ec 04             	sub    $0x4,%esp
  800e8f:	68 8a 2f 80 00       	push   $0x802f8a
  800e94:	6a 1f                	push   $0x1f
  800e96:	68 9a 2f 80 00       	push   $0x802f9a
  800e9b:	e8 17 f3 ff ff       	call   8001b7 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800ea0:	83 ec 04             	sub    $0x4,%esp
  800ea3:	6a 07                	push   $0x7
  800ea5:	68 00 f0 7f 00       	push   $0x7ff000
  800eaa:	6a 00                	push   $0x0
  800eac:	e8 67 fd ff ff       	call   800c18 <sys_page_alloc>
	if (r < 0) {
  800eb1:	83 c4 10             	add    $0x10,%esp
  800eb4:	85 c0                	test   %eax,%eax
  800eb6:	79 12                	jns    800eca <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800eb8:	50                   	push   %eax
  800eb9:	68 a5 2f 80 00       	push   $0x802fa5
  800ebe:	6a 2d                	push   $0x2d
  800ec0:	68 9a 2f 80 00       	push   $0x802f9a
  800ec5:	e8 ed f2 ff ff       	call   8001b7 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800eca:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800ed0:	83 ec 04             	sub    $0x4,%esp
  800ed3:	68 00 10 00 00       	push   $0x1000
  800ed8:	53                   	push   %ebx
  800ed9:	68 00 f0 7f 00       	push   $0x7ff000
  800ede:	e8 2c fb ff ff       	call   800a0f <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800ee3:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800eea:	53                   	push   %ebx
  800eeb:	6a 00                	push   $0x0
  800eed:	68 00 f0 7f 00       	push   $0x7ff000
  800ef2:	6a 00                	push   $0x0
  800ef4:	e8 62 fd ff ff       	call   800c5b <sys_page_map>
	if (r < 0) {
  800ef9:	83 c4 20             	add    $0x20,%esp
  800efc:	85 c0                	test   %eax,%eax
  800efe:	79 12                	jns    800f12 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800f00:	50                   	push   %eax
  800f01:	68 a5 2f 80 00       	push   $0x802fa5
  800f06:	6a 34                	push   $0x34
  800f08:	68 9a 2f 80 00       	push   $0x802f9a
  800f0d:	e8 a5 f2 ff ff       	call   8001b7 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800f12:	83 ec 08             	sub    $0x8,%esp
  800f15:	68 00 f0 7f 00       	push   $0x7ff000
  800f1a:	6a 00                	push   $0x0
  800f1c:	e8 7c fd ff ff       	call   800c9d <sys_page_unmap>
	if (r < 0) {
  800f21:	83 c4 10             	add    $0x10,%esp
  800f24:	85 c0                	test   %eax,%eax
  800f26:	79 12                	jns    800f3a <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800f28:	50                   	push   %eax
  800f29:	68 a5 2f 80 00       	push   $0x802fa5
  800f2e:	6a 38                	push   $0x38
  800f30:	68 9a 2f 80 00       	push   $0x802f9a
  800f35:	e8 7d f2 ff ff       	call   8001b7 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800f3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f3d:	c9                   	leave  
  800f3e:	c3                   	ret    

00800f3f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	57                   	push   %edi
  800f43:	56                   	push   %esi
  800f44:	53                   	push   %ebx
  800f45:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800f48:	68 69 0e 80 00       	push   $0x800e69
  800f4d:	e8 77 17 00 00       	call   8026c9 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f52:	b8 07 00 00 00       	mov    $0x7,%eax
  800f57:	cd 30                	int    $0x30
  800f59:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800f5c:	83 c4 10             	add    $0x10,%esp
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	79 17                	jns    800f7a <fork+0x3b>
		panic("fork fault %e");
  800f63:	83 ec 04             	sub    $0x4,%esp
  800f66:	68 be 2f 80 00       	push   $0x802fbe
  800f6b:	68 85 00 00 00       	push   $0x85
  800f70:	68 9a 2f 80 00       	push   $0x802f9a
  800f75:	e8 3d f2 ff ff       	call   8001b7 <_panic>
  800f7a:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f7c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f80:	75 24                	jne    800fa6 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f82:	e8 53 fc ff ff       	call   800bda <sys_getenvid>
  800f87:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f8c:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  800f92:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f97:	a3 04 50 80 00       	mov    %eax,0x805004
		return 0;
  800f9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa1:	e9 64 01 00 00       	jmp    80110a <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800fa6:	83 ec 04             	sub    $0x4,%esp
  800fa9:	6a 07                	push   $0x7
  800fab:	68 00 f0 bf ee       	push   $0xeebff000
  800fb0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fb3:	e8 60 fc ff ff       	call   800c18 <sys_page_alloc>
  800fb8:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fbb:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fc0:	89 d8                	mov    %ebx,%eax
  800fc2:	c1 e8 16             	shr    $0x16,%eax
  800fc5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fcc:	a8 01                	test   $0x1,%al
  800fce:	0f 84 fc 00 00 00    	je     8010d0 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800fd4:	89 d8                	mov    %ebx,%eax
  800fd6:	c1 e8 0c             	shr    $0xc,%eax
  800fd9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fe0:	f6 c2 01             	test   $0x1,%dl
  800fe3:	0f 84 e7 00 00 00    	je     8010d0 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800fe9:	89 c6                	mov    %eax,%esi
  800feb:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800fee:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ff5:	f6 c6 04             	test   $0x4,%dh
  800ff8:	74 39                	je     801033 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800ffa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801001:	83 ec 0c             	sub    $0xc,%esp
  801004:	25 07 0e 00 00       	and    $0xe07,%eax
  801009:	50                   	push   %eax
  80100a:	56                   	push   %esi
  80100b:	57                   	push   %edi
  80100c:	56                   	push   %esi
  80100d:	6a 00                	push   $0x0
  80100f:	e8 47 fc ff ff       	call   800c5b <sys_page_map>
		if (r < 0) {
  801014:	83 c4 20             	add    $0x20,%esp
  801017:	85 c0                	test   %eax,%eax
  801019:	0f 89 b1 00 00 00    	jns    8010d0 <fork+0x191>
		    	panic("sys page map fault %e");
  80101f:	83 ec 04             	sub    $0x4,%esp
  801022:	68 cc 2f 80 00       	push   $0x802fcc
  801027:	6a 55                	push   $0x55
  801029:	68 9a 2f 80 00       	push   $0x802f9a
  80102e:	e8 84 f1 ff ff       	call   8001b7 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801033:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80103a:	f6 c2 02             	test   $0x2,%dl
  80103d:	75 0c                	jne    80104b <fork+0x10c>
  80103f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801046:	f6 c4 08             	test   $0x8,%ah
  801049:	74 5b                	je     8010a6 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80104b:	83 ec 0c             	sub    $0xc,%esp
  80104e:	68 05 08 00 00       	push   $0x805
  801053:	56                   	push   %esi
  801054:	57                   	push   %edi
  801055:	56                   	push   %esi
  801056:	6a 00                	push   $0x0
  801058:	e8 fe fb ff ff       	call   800c5b <sys_page_map>
		if (r < 0) {
  80105d:	83 c4 20             	add    $0x20,%esp
  801060:	85 c0                	test   %eax,%eax
  801062:	79 14                	jns    801078 <fork+0x139>
		    	panic("sys page map fault %e");
  801064:	83 ec 04             	sub    $0x4,%esp
  801067:	68 cc 2f 80 00       	push   $0x802fcc
  80106c:	6a 5c                	push   $0x5c
  80106e:	68 9a 2f 80 00       	push   $0x802f9a
  801073:	e8 3f f1 ff ff       	call   8001b7 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  801078:	83 ec 0c             	sub    $0xc,%esp
  80107b:	68 05 08 00 00       	push   $0x805
  801080:	56                   	push   %esi
  801081:	6a 00                	push   $0x0
  801083:	56                   	push   %esi
  801084:	6a 00                	push   $0x0
  801086:	e8 d0 fb ff ff       	call   800c5b <sys_page_map>
		if (r < 0) {
  80108b:	83 c4 20             	add    $0x20,%esp
  80108e:	85 c0                	test   %eax,%eax
  801090:	79 3e                	jns    8010d0 <fork+0x191>
		    	panic("sys page map fault %e");
  801092:	83 ec 04             	sub    $0x4,%esp
  801095:	68 cc 2f 80 00       	push   $0x802fcc
  80109a:	6a 60                	push   $0x60
  80109c:	68 9a 2f 80 00       	push   $0x802f9a
  8010a1:	e8 11 f1 ff ff       	call   8001b7 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8010a6:	83 ec 0c             	sub    $0xc,%esp
  8010a9:	6a 05                	push   $0x5
  8010ab:	56                   	push   %esi
  8010ac:	57                   	push   %edi
  8010ad:	56                   	push   %esi
  8010ae:	6a 00                	push   $0x0
  8010b0:	e8 a6 fb ff ff       	call   800c5b <sys_page_map>
		if (r < 0) {
  8010b5:	83 c4 20             	add    $0x20,%esp
  8010b8:	85 c0                	test   %eax,%eax
  8010ba:	79 14                	jns    8010d0 <fork+0x191>
		    	panic("sys page map fault %e");
  8010bc:	83 ec 04             	sub    $0x4,%esp
  8010bf:	68 cc 2f 80 00       	push   $0x802fcc
  8010c4:	6a 65                	push   $0x65
  8010c6:	68 9a 2f 80 00       	push   $0x802f9a
  8010cb:	e8 e7 f0 ff ff       	call   8001b7 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8010d0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010d6:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8010dc:	0f 85 de fe ff ff    	jne    800fc0 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8010e2:	a1 04 50 80 00       	mov    0x805004,%eax
  8010e7:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
  8010ed:	83 ec 08             	sub    $0x8,%esp
  8010f0:	50                   	push   %eax
  8010f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010f4:	57                   	push   %edi
  8010f5:	e8 69 fc ff ff       	call   800d63 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8010fa:	83 c4 08             	add    $0x8,%esp
  8010fd:	6a 02                	push   $0x2
  8010ff:	57                   	push   %edi
  801100:	e8 da fb ff ff       	call   800cdf <sys_env_set_status>
	
	return envid;
  801105:	83 c4 10             	add    $0x10,%esp
  801108:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80110a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80110d:	5b                   	pop    %ebx
  80110e:	5e                   	pop    %esi
  80110f:	5f                   	pop    %edi
  801110:	5d                   	pop    %ebp
  801111:	c3                   	ret    

00801112 <sfork>:

envid_t
sfork(void)
{
  801112:	55                   	push   %ebp
  801113:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801115:	b8 00 00 00 00       	mov    $0x0,%eax
  80111a:	5d                   	pop    %ebp
  80111b:	c3                   	ret    

0080111c <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	56                   	push   %esi
  801120:	53                   	push   %ebx
  801121:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801124:	89 1d 08 50 80 00    	mov    %ebx,0x805008
	cprintf("in fork.c thread create. func: %x\n", func);
  80112a:	83 ec 08             	sub    $0x8,%esp
  80112d:	53                   	push   %ebx
  80112e:	68 5c 30 80 00       	push   $0x80305c
  801133:	e8 58 f1 ff ff       	call   800290 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801138:	c7 04 24 7d 01 80 00 	movl   $0x80017d,(%esp)
  80113f:	e8 c5 fc ff ff       	call   800e09 <sys_thread_create>
  801144:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801146:	83 c4 08             	add    $0x8,%esp
  801149:	53                   	push   %ebx
  80114a:	68 5c 30 80 00       	push   $0x80305c
  80114f:	e8 3c f1 ff ff       	call   800290 <cprintf>
	return id;
}
  801154:	89 f0                	mov    %esi,%eax
  801156:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801159:	5b                   	pop    %ebx
  80115a:	5e                   	pop    %esi
  80115b:	5d                   	pop    %ebp
  80115c:	c3                   	ret    

0080115d <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  80115d:	55                   	push   %ebp
  80115e:	89 e5                	mov    %esp,%ebp
  801160:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  801163:	ff 75 08             	pushl  0x8(%ebp)
  801166:	e8 be fc ff ff       	call   800e29 <sys_thread_free>
}
  80116b:	83 c4 10             	add    $0x10,%esp
  80116e:	c9                   	leave  
  80116f:	c3                   	ret    

00801170 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  801176:	ff 75 08             	pushl  0x8(%ebp)
  801179:	e8 cb fc ff ff       	call   800e49 <sys_thread_join>
}
  80117e:	83 c4 10             	add    $0x10,%esp
  801181:	c9                   	leave  
  801182:	c3                   	ret    

00801183 <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  801183:	55                   	push   %ebp
  801184:	89 e5                	mov    %esp,%ebp
  801186:	56                   	push   %esi
  801187:	53                   	push   %ebx
  801188:	8b 75 08             	mov    0x8(%ebp),%esi
  80118b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  80118e:	83 ec 04             	sub    $0x4,%esp
  801191:	6a 07                	push   $0x7
  801193:	6a 00                	push   $0x0
  801195:	56                   	push   %esi
  801196:	e8 7d fa ff ff       	call   800c18 <sys_page_alloc>
	if (r < 0) {
  80119b:	83 c4 10             	add    $0x10,%esp
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	79 15                	jns    8011b7 <queue_append+0x34>
		panic("%e\n", r);
  8011a2:	50                   	push   %eax
  8011a3:	68 58 30 80 00       	push   $0x803058
  8011a8:	68 c4 00 00 00       	push   $0xc4
  8011ad:	68 9a 2f 80 00       	push   $0x802f9a
  8011b2:	e8 00 f0 ff ff       	call   8001b7 <_panic>
	}	
	wt->envid = envid;
  8011b7:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  8011bd:	83 ec 04             	sub    $0x4,%esp
  8011c0:	ff 33                	pushl  (%ebx)
  8011c2:	56                   	push   %esi
  8011c3:	68 80 30 80 00       	push   $0x803080
  8011c8:	e8 c3 f0 ff ff       	call   800290 <cprintf>
	if (queue->first == NULL) {
  8011cd:	83 c4 10             	add    $0x10,%esp
  8011d0:	83 3b 00             	cmpl   $0x0,(%ebx)
  8011d3:	75 29                	jne    8011fe <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  8011d5:	83 ec 0c             	sub    $0xc,%esp
  8011d8:	68 e2 2f 80 00       	push   $0x802fe2
  8011dd:	e8 ae f0 ff ff       	call   800290 <cprintf>
		queue->first = wt;
  8011e2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  8011e8:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  8011ef:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8011f6:	00 00 00 
  8011f9:	83 c4 10             	add    $0x10,%esp
  8011fc:	eb 2b                	jmp    801229 <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  8011fe:	83 ec 0c             	sub    $0xc,%esp
  801201:	68 fc 2f 80 00       	push   $0x802ffc
  801206:	e8 85 f0 ff ff       	call   800290 <cprintf>
		queue->last->next = wt;
  80120b:	8b 43 04             	mov    0x4(%ebx),%eax
  80120e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  801215:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80121c:	00 00 00 
		queue->last = wt;
  80121f:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  801226:	83 c4 10             	add    $0x10,%esp
	}
}
  801229:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80122c:	5b                   	pop    %ebx
  80122d:	5e                   	pop    %esi
  80122e:	5d                   	pop    %ebp
  80122f:	c3                   	ret    

00801230 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	53                   	push   %ebx
  801234:	83 ec 04             	sub    $0x4,%esp
  801237:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  80123a:	8b 02                	mov    (%edx),%eax
  80123c:	85 c0                	test   %eax,%eax
  80123e:	75 17                	jne    801257 <queue_pop+0x27>
		panic("queue empty!\n");
  801240:	83 ec 04             	sub    $0x4,%esp
  801243:	68 1a 30 80 00       	push   $0x80301a
  801248:	68 d8 00 00 00       	push   $0xd8
  80124d:	68 9a 2f 80 00       	push   $0x802f9a
  801252:	e8 60 ef ff ff       	call   8001b7 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  801257:	8b 48 04             	mov    0x4(%eax),%ecx
  80125a:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  80125c:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  80125e:	83 ec 08             	sub    $0x8,%esp
  801261:	53                   	push   %ebx
  801262:	68 28 30 80 00       	push   $0x803028
  801267:	e8 24 f0 ff ff       	call   800290 <cprintf>
	return envid;
}
  80126c:	89 d8                	mov    %ebx,%eax
  80126e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801271:	c9                   	leave  
  801272:	c3                   	ret    

00801273 <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  801273:	55                   	push   %ebp
  801274:	89 e5                	mov    %esp,%ebp
  801276:	53                   	push   %ebx
  801277:	83 ec 04             	sub    $0x4,%esp
  80127a:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  80127d:	b8 01 00 00 00       	mov    $0x1,%eax
  801282:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801285:	85 c0                	test   %eax,%eax
  801287:	74 5a                	je     8012e3 <mutex_lock+0x70>
  801289:	8b 43 04             	mov    0x4(%ebx),%eax
  80128c:	83 38 00             	cmpl   $0x0,(%eax)
  80128f:	75 52                	jne    8012e3 <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  801291:	83 ec 0c             	sub    $0xc,%esp
  801294:	68 a8 30 80 00       	push   $0x8030a8
  801299:	e8 f2 ef ff ff       	call   800290 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  80129e:	8b 5b 04             	mov    0x4(%ebx),%ebx
  8012a1:	e8 34 f9 ff ff       	call   800bda <sys_getenvid>
  8012a6:	83 c4 08             	add    $0x8,%esp
  8012a9:	53                   	push   %ebx
  8012aa:	50                   	push   %eax
  8012ab:	e8 d3 fe ff ff       	call   801183 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  8012b0:	e8 25 f9 ff ff       	call   800bda <sys_getenvid>
  8012b5:	83 c4 08             	add    $0x8,%esp
  8012b8:	6a 04                	push   $0x4
  8012ba:	50                   	push   %eax
  8012bb:	e8 1f fa ff ff       	call   800cdf <sys_env_set_status>
		if (r < 0) {
  8012c0:	83 c4 10             	add    $0x10,%esp
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	79 15                	jns    8012dc <mutex_lock+0x69>
			panic("%e\n", r);
  8012c7:	50                   	push   %eax
  8012c8:	68 58 30 80 00       	push   $0x803058
  8012cd:	68 eb 00 00 00       	push   $0xeb
  8012d2:	68 9a 2f 80 00       	push   $0x802f9a
  8012d7:	e8 db ee ff ff       	call   8001b7 <_panic>
		}
		sys_yield();
  8012dc:	e8 18 f9 ff ff       	call   800bf9 <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8012e1:	eb 18                	jmp    8012fb <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  8012e3:	83 ec 0c             	sub    $0xc,%esp
  8012e6:	68 c8 30 80 00       	push   $0x8030c8
  8012eb:	e8 a0 ef ff ff       	call   800290 <cprintf>
	mtx->owner = sys_getenvid();}
  8012f0:	e8 e5 f8 ff ff       	call   800bda <sys_getenvid>
  8012f5:	89 43 08             	mov    %eax,0x8(%ebx)
  8012f8:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  8012fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012fe:	c9                   	leave  
  8012ff:	c3                   	ret    

00801300 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	53                   	push   %ebx
  801304:	83 ec 04             	sub    $0x4,%esp
  801307:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80130a:	b8 00 00 00 00       	mov    $0x0,%eax
  80130f:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  801312:	8b 43 04             	mov    0x4(%ebx),%eax
  801315:	83 38 00             	cmpl   $0x0,(%eax)
  801318:	74 33                	je     80134d <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  80131a:	83 ec 0c             	sub    $0xc,%esp
  80131d:	50                   	push   %eax
  80131e:	e8 0d ff ff ff       	call   801230 <queue_pop>
  801323:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  801326:	83 c4 08             	add    $0x8,%esp
  801329:	6a 02                	push   $0x2
  80132b:	50                   	push   %eax
  80132c:	e8 ae f9 ff ff       	call   800cdf <sys_env_set_status>
		if (r < 0) {
  801331:	83 c4 10             	add    $0x10,%esp
  801334:	85 c0                	test   %eax,%eax
  801336:	79 15                	jns    80134d <mutex_unlock+0x4d>
			panic("%e\n", r);
  801338:	50                   	push   %eax
  801339:	68 58 30 80 00       	push   $0x803058
  80133e:	68 00 01 00 00       	push   $0x100
  801343:	68 9a 2f 80 00       	push   $0x802f9a
  801348:	e8 6a ee ff ff       	call   8001b7 <_panic>
		}
	}

	asm volatile("pause");
  80134d:	f3 90                	pause  
	//sys_yield();
}
  80134f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801352:	c9                   	leave  
  801353:	c3                   	ret    

00801354 <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  801354:	55                   	push   %ebp
  801355:	89 e5                	mov    %esp,%ebp
  801357:	53                   	push   %ebx
  801358:	83 ec 04             	sub    $0x4,%esp
  80135b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  80135e:	e8 77 f8 ff ff       	call   800bda <sys_getenvid>
  801363:	83 ec 04             	sub    $0x4,%esp
  801366:	6a 07                	push   $0x7
  801368:	53                   	push   %ebx
  801369:	50                   	push   %eax
  80136a:	e8 a9 f8 ff ff       	call   800c18 <sys_page_alloc>
  80136f:	83 c4 10             	add    $0x10,%esp
  801372:	85 c0                	test   %eax,%eax
  801374:	79 15                	jns    80138b <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  801376:	50                   	push   %eax
  801377:	68 43 30 80 00       	push   $0x803043
  80137c:	68 0d 01 00 00       	push   $0x10d
  801381:	68 9a 2f 80 00       	push   $0x802f9a
  801386:	e8 2c ee ff ff       	call   8001b7 <_panic>
	}	
	mtx->locked = 0;
  80138b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  801391:	8b 43 04             	mov    0x4(%ebx),%eax
  801394:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  80139a:	8b 43 04             	mov    0x4(%ebx),%eax
  80139d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  8013a4:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  8013ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ae:	c9                   	leave  
  8013af:	c3                   	ret    

008013b0 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  8013b0:	55                   	push   %ebp
  8013b1:	89 e5                	mov    %esp,%ebp
  8013b3:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  8013b6:	e8 1f f8 ff ff       	call   800bda <sys_getenvid>
  8013bb:	83 ec 08             	sub    $0x8,%esp
  8013be:	ff 75 08             	pushl  0x8(%ebp)
  8013c1:	50                   	push   %eax
  8013c2:	e8 d6 f8 ff ff       	call   800c9d <sys_page_unmap>
	if (r < 0) {
  8013c7:	83 c4 10             	add    $0x10,%esp
  8013ca:	85 c0                	test   %eax,%eax
  8013cc:	79 15                	jns    8013e3 <mutex_destroy+0x33>
		panic("%e\n", r);
  8013ce:	50                   	push   %eax
  8013cf:	68 58 30 80 00       	push   $0x803058
  8013d4:	68 1a 01 00 00       	push   $0x11a
  8013d9:	68 9a 2f 80 00       	push   $0x802f9a
  8013de:	e8 d4 ed ff ff       	call   8001b7 <_panic>
	}
}
  8013e3:	c9                   	leave  
  8013e4:	c3                   	ret    

008013e5 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013e5:	55                   	push   %ebp
  8013e6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013eb:	05 00 00 00 30       	add    $0x30000000,%eax
  8013f0:	c1 e8 0c             	shr    $0xc,%eax
}
  8013f3:	5d                   	pop    %ebp
  8013f4:	c3                   	ret    

008013f5 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013f5:	55                   	push   %ebp
  8013f6:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8013f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fb:	05 00 00 00 30       	add    $0x30000000,%eax
  801400:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801405:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80140a:	5d                   	pop    %ebp
  80140b:	c3                   	ret    

0080140c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
  80140f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801412:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801417:	89 c2                	mov    %eax,%edx
  801419:	c1 ea 16             	shr    $0x16,%edx
  80141c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801423:	f6 c2 01             	test   $0x1,%dl
  801426:	74 11                	je     801439 <fd_alloc+0x2d>
  801428:	89 c2                	mov    %eax,%edx
  80142a:	c1 ea 0c             	shr    $0xc,%edx
  80142d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801434:	f6 c2 01             	test   $0x1,%dl
  801437:	75 09                	jne    801442 <fd_alloc+0x36>
			*fd_store = fd;
  801439:	89 01                	mov    %eax,(%ecx)
			return 0;
  80143b:	b8 00 00 00 00       	mov    $0x0,%eax
  801440:	eb 17                	jmp    801459 <fd_alloc+0x4d>
  801442:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801447:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80144c:	75 c9                	jne    801417 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80144e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801454:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801459:	5d                   	pop    %ebp
  80145a:	c3                   	ret    

0080145b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80145b:	55                   	push   %ebp
  80145c:	89 e5                	mov    %esp,%ebp
  80145e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801461:	83 f8 1f             	cmp    $0x1f,%eax
  801464:	77 36                	ja     80149c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801466:	c1 e0 0c             	shl    $0xc,%eax
  801469:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80146e:	89 c2                	mov    %eax,%edx
  801470:	c1 ea 16             	shr    $0x16,%edx
  801473:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80147a:	f6 c2 01             	test   $0x1,%dl
  80147d:	74 24                	je     8014a3 <fd_lookup+0x48>
  80147f:	89 c2                	mov    %eax,%edx
  801481:	c1 ea 0c             	shr    $0xc,%edx
  801484:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80148b:	f6 c2 01             	test   $0x1,%dl
  80148e:	74 1a                	je     8014aa <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801490:	8b 55 0c             	mov    0xc(%ebp),%edx
  801493:	89 02                	mov    %eax,(%edx)
	return 0;
  801495:	b8 00 00 00 00       	mov    $0x0,%eax
  80149a:	eb 13                	jmp    8014af <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80149c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014a1:	eb 0c                	jmp    8014af <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014a8:	eb 05                	jmp    8014af <fd_lookup+0x54>
  8014aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014af:	5d                   	pop    %ebp
  8014b0:	c3                   	ret    

008014b1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014b1:	55                   	push   %ebp
  8014b2:	89 e5                	mov    %esp,%ebp
  8014b4:	83 ec 08             	sub    $0x8,%esp
  8014b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014ba:	ba 64 31 80 00       	mov    $0x803164,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014bf:	eb 13                	jmp    8014d4 <dev_lookup+0x23>
  8014c1:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8014c4:	39 08                	cmp    %ecx,(%eax)
  8014c6:	75 0c                	jne    8014d4 <dev_lookup+0x23>
			*dev = devtab[i];
  8014c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014cb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8014d2:	eb 31                	jmp    801505 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014d4:	8b 02                	mov    (%edx),%eax
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	75 e7                	jne    8014c1 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014da:	a1 04 50 80 00       	mov    0x805004,%eax
  8014df:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8014e5:	83 ec 04             	sub    $0x4,%esp
  8014e8:	51                   	push   %ecx
  8014e9:	50                   	push   %eax
  8014ea:	68 e8 30 80 00       	push   $0x8030e8
  8014ef:	e8 9c ed ff ff       	call   800290 <cprintf>
	*dev = 0;
  8014f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014fd:	83 c4 10             	add    $0x10,%esp
  801500:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801505:	c9                   	leave  
  801506:	c3                   	ret    

00801507 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801507:	55                   	push   %ebp
  801508:	89 e5                	mov    %esp,%ebp
  80150a:	56                   	push   %esi
  80150b:	53                   	push   %ebx
  80150c:	83 ec 10             	sub    $0x10,%esp
  80150f:	8b 75 08             	mov    0x8(%ebp),%esi
  801512:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801515:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801518:	50                   	push   %eax
  801519:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80151f:	c1 e8 0c             	shr    $0xc,%eax
  801522:	50                   	push   %eax
  801523:	e8 33 ff ff ff       	call   80145b <fd_lookup>
  801528:	83 c4 08             	add    $0x8,%esp
  80152b:	85 c0                	test   %eax,%eax
  80152d:	78 05                	js     801534 <fd_close+0x2d>
	    || fd != fd2)
  80152f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801532:	74 0c                	je     801540 <fd_close+0x39>
		return (must_exist ? r : 0);
  801534:	84 db                	test   %bl,%bl
  801536:	ba 00 00 00 00       	mov    $0x0,%edx
  80153b:	0f 44 c2             	cmove  %edx,%eax
  80153e:	eb 41                	jmp    801581 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801540:	83 ec 08             	sub    $0x8,%esp
  801543:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801546:	50                   	push   %eax
  801547:	ff 36                	pushl  (%esi)
  801549:	e8 63 ff ff ff       	call   8014b1 <dev_lookup>
  80154e:	89 c3                	mov    %eax,%ebx
  801550:	83 c4 10             	add    $0x10,%esp
  801553:	85 c0                	test   %eax,%eax
  801555:	78 1a                	js     801571 <fd_close+0x6a>
		if (dev->dev_close)
  801557:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80155d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801562:	85 c0                	test   %eax,%eax
  801564:	74 0b                	je     801571 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801566:	83 ec 0c             	sub    $0xc,%esp
  801569:	56                   	push   %esi
  80156a:	ff d0                	call   *%eax
  80156c:	89 c3                	mov    %eax,%ebx
  80156e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801571:	83 ec 08             	sub    $0x8,%esp
  801574:	56                   	push   %esi
  801575:	6a 00                	push   $0x0
  801577:	e8 21 f7 ff ff       	call   800c9d <sys_page_unmap>
	return r;
  80157c:	83 c4 10             	add    $0x10,%esp
  80157f:	89 d8                	mov    %ebx,%eax
}
  801581:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801584:	5b                   	pop    %ebx
  801585:	5e                   	pop    %esi
  801586:	5d                   	pop    %ebp
  801587:	c3                   	ret    

00801588 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801588:	55                   	push   %ebp
  801589:	89 e5                	mov    %esp,%ebp
  80158b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80158e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801591:	50                   	push   %eax
  801592:	ff 75 08             	pushl  0x8(%ebp)
  801595:	e8 c1 fe ff ff       	call   80145b <fd_lookup>
  80159a:	83 c4 08             	add    $0x8,%esp
  80159d:	85 c0                	test   %eax,%eax
  80159f:	78 10                	js     8015b1 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8015a1:	83 ec 08             	sub    $0x8,%esp
  8015a4:	6a 01                	push   $0x1
  8015a6:	ff 75 f4             	pushl  -0xc(%ebp)
  8015a9:	e8 59 ff ff ff       	call   801507 <fd_close>
  8015ae:	83 c4 10             	add    $0x10,%esp
}
  8015b1:	c9                   	leave  
  8015b2:	c3                   	ret    

008015b3 <close_all>:

void
close_all(void)
{
  8015b3:	55                   	push   %ebp
  8015b4:	89 e5                	mov    %esp,%ebp
  8015b6:	53                   	push   %ebx
  8015b7:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015ba:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015bf:	83 ec 0c             	sub    $0xc,%esp
  8015c2:	53                   	push   %ebx
  8015c3:	e8 c0 ff ff ff       	call   801588 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015c8:	83 c3 01             	add    $0x1,%ebx
  8015cb:	83 c4 10             	add    $0x10,%esp
  8015ce:	83 fb 20             	cmp    $0x20,%ebx
  8015d1:	75 ec                	jne    8015bf <close_all+0xc>
		close(i);
}
  8015d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d6:	c9                   	leave  
  8015d7:	c3                   	ret    

008015d8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015d8:	55                   	push   %ebp
  8015d9:	89 e5                	mov    %esp,%ebp
  8015db:	57                   	push   %edi
  8015dc:	56                   	push   %esi
  8015dd:	53                   	push   %ebx
  8015de:	83 ec 2c             	sub    $0x2c,%esp
  8015e1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015e4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015e7:	50                   	push   %eax
  8015e8:	ff 75 08             	pushl  0x8(%ebp)
  8015eb:	e8 6b fe ff ff       	call   80145b <fd_lookup>
  8015f0:	83 c4 08             	add    $0x8,%esp
  8015f3:	85 c0                	test   %eax,%eax
  8015f5:	0f 88 c1 00 00 00    	js     8016bc <dup+0xe4>
		return r;
	close(newfdnum);
  8015fb:	83 ec 0c             	sub    $0xc,%esp
  8015fe:	56                   	push   %esi
  8015ff:	e8 84 ff ff ff       	call   801588 <close>

	newfd = INDEX2FD(newfdnum);
  801604:	89 f3                	mov    %esi,%ebx
  801606:	c1 e3 0c             	shl    $0xc,%ebx
  801609:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80160f:	83 c4 04             	add    $0x4,%esp
  801612:	ff 75 e4             	pushl  -0x1c(%ebp)
  801615:	e8 db fd ff ff       	call   8013f5 <fd2data>
  80161a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80161c:	89 1c 24             	mov    %ebx,(%esp)
  80161f:	e8 d1 fd ff ff       	call   8013f5 <fd2data>
  801624:	83 c4 10             	add    $0x10,%esp
  801627:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80162a:	89 f8                	mov    %edi,%eax
  80162c:	c1 e8 16             	shr    $0x16,%eax
  80162f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801636:	a8 01                	test   $0x1,%al
  801638:	74 37                	je     801671 <dup+0x99>
  80163a:	89 f8                	mov    %edi,%eax
  80163c:	c1 e8 0c             	shr    $0xc,%eax
  80163f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801646:	f6 c2 01             	test   $0x1,%dl
  801649:	74 26                	je     801671 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80164b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801652:	83 ec 0c             	sub    $0xc,%esp
  801655:	25 07 0e 00 00       	and    $0xe07,%eax
  80165a:	50                   	push   %eax
  80165b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80165e:	6a 00                	push   $0x0
  801660:	57                   	push   %edi
  801661:	6a 00                	push   $0x0
  801663:	e8 f3 f5 ff ff       	call   800c5b <sys_page_map>
  801668:	89 c7                	mov    %eax,%edi
  80166a:	83 c4 20             	add    $0x20,%esp
  80166d:	85 c0                	test   %eax,%eax
  80166f:	78 2e                	js     80169f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801671:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801674:	89 d0                	mov    %edx,%eax
  801676:	c1 e8 0c             	shr    $0xc,%eax
  801679:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801680:	83 ec 0c             	sub    $0xc,%esp
  801683:	25 07 0e 00 00       	and    $0xe07,%eax
  801688:	50                   	push   %eax
  801689:	53                   	push   %ebx
  80168a:	6a 00                	push   $0x0
  80168c:	52                   	push   %edx
  80168d:	6a 00                	push   $0x0
  80168f:	e8 c7 f5 ff ff       	call   800c5b <sys_page_map>
  801694:	89 c7                	mov    %eax,%edi
  801696:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801699:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80169b:	85 ff                	test   %edi,%edi
  80169d:	79 1d                	jns    8016bc <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80169f:	83 ec 08             	sub    $0x8,%esp
  8016a2:	53                   	push   %ebx
  8016a3:	6a 00                	push   $0x0
  8016a5:	e8 f3 f5 ff ff       	call   800c9d <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016aa:	83 c4 08             	add    $0x8,%esp
  8016ad:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016b0:	6a 00                	push   $0x0
  8016b2:	e8 e6 f5 ff ff       	call   800c9d <sys_page_unmap>
	return r;
  8016b7:	83 c4 10             	add    $0x10,%esp
  8016ba:	89 f8                	mov    %edi,%eax
}
  8016bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016bf:	5b                   	pop    %ebx
  8016c0:	5e                   	pop    %esi
  8016c1:	5f                   	pop    %edi
  8016c2:	5d                   	pop    %ebp
  8016c3:	c3                   	ret    

008016c4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016c4:	55                   	push   %ebp
  8016c5:	89 e5                	mov    %esp,%ebp
  8016c7:	53                   	push   %ebx
  8016c8:	83 ec 14             	sub    $0x14,%esp
  8016cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d1:	50                   	push   %eax
  8016d2:	53                   	push   %ebx
  8016d3:	e8 83 fd ff ff       	call   80145b <fd_lookup>
  8016d8:	83 c4 08             	add    $0x8,%esp
  8016db:	89 c2                	mov    %eax,%edx
  8016dd:	85 c0                	test   %eax,%eax
  8016df:	78 70                	js     801751 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e1:	83 ec 08             	sub    $0x8,%esp
  8016e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e7:	50                   	push   %eax
  8016e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016eb:	ff 30                	pushl  (%eax)
  8016ed:	e8 bf fd ff ff       	call   8014b1 <dev_lookup>
  8016f2:	83 c4 10             	add    $0x10,%esp
  8016f5:	85 c0                	test   %eax,%eax
  8016f7:	78 4f                	js     801748 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016f9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016fc:	8b 42 08             	mov    0x8(%edx),%eax
  8016ff:	83 e0 03             	and    $0x3,%eax
  801702:	83 f8 01             	cmp    $0x1,%eax
  801705:	75 24                	jne    80172b <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801707:	a1 04 50 80 00       	mov    0x805004,%eax
  80170c:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801712:	83 ec 04             	sub    $0x4,%esp
  801715:	53                   	push   %ebx
  801716:	50                   	push   %eax
  801717:	68 29 31 80 00       	push   $0x803129
  80171c:	e8 6f eb ff ff       	call   800290 <cprintf>
		return -E_INVAL;
  801721:	83 c4 10             	add    $0x10,%esp
  801724:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801729:	eb 26                	jmp    801751 <read+0x8d>
	}
	if (!dev->dev_read)
  80172b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80172e:	8b 40 08             	mov    0x8(%eax),%eax
  801731:	85 c0                	test   %eax,%eax
  801733:	74 17                	je     80174c <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801735:	83 ec 04             	sub    $0x4,%esp
  801738:	ff 75 10             	pushl  0x10(%ebp)
  80173b:	ff 75 0c             	pushl  0xc(%ebp)
  80173e:	52                   	push   %edx
  80173f:	ff d0                	call   *%eax
  801741:	89 c2                	mov    %eax,%edx
  801743:	83 c4 10             	add    $0x10,%esp
  801746:	eb 09                	jmp    801751 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801748:	89 c2                	mov    %eax,%edx
  80174a:	eb 05                	jmp    801751 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80174c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801751:	89 d0                	mov    %edx,%eax
  801753:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801756:	c9                   	leave  
  801757:	c3                   	ret    

00801758 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	57                   	push   %edi
  80175c:	56                   	push   %esi
  80175d:	53                   	push   %ebx
  80175e:	83 ec 0c             	sub    $0xc,%esp
  801761:	8b 7d 08             	mov    0x8(%ebp),%edi
  801764:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801767:	bb 00 00 00 00       	mov    $0x0,%ebx
  80176c:	eb 21                	jmp    80178f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80176e:	83 ec 04             	sub    $0x4,%esp
  801771:	89 f0                	mov    %esi,%eax
  801773:	29 d8                	sub    %ebx,%eax
  801775:	50                   	push   %eax
  801776:	89 d8                	mov    %ebx,%eax
  801778:	03 45 0c             	add    0xc(%ebp),%eax
  80177b:	50                   	push   %eax
  80177c:	57                   	push   %edi
  80177d:	e8 42 ff ff ff       	call   8016c4 <read>
		if (m < 0)
  801782:	83 c4 10             	add    $0x10,%esp
  801785:	85 c0                	test   %eax,%eax
  801787:	78 10                	js     801799 <readn+0x41>
			return m;
		if (m == 0)
  801789:	85 c0                	test   %eax,%eax
  80178b:	74 0a                	je     801797 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80178d:	01 c3                	add    %eax,%ebx
  80178f:	39 f3                	cmp    %esi,%ebx
  801791:	72 db                	jb     80176e <readn+0x16>
  801793:	89 d8                	mov    %ebx,%eax
  801795:	eb 02                	jmp    801799 <readn+0x41>
  801797:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801799:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80179c:	5b                   	pop    %ebx
  80179d:	5e                   	pop    %esi
  80179e:	5f                   	pop    %edi
  80179f:	5d                   	pop    %ebp
  8017a0:	c3                   	ret    

008017a1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017a1:	55                   	push   %ebp
  8017a2:	89 e5                	mov    %esp,%ebp
  8017a4:	53                   	push   %ebx
  8017a5:	83 ec 14             	sub    $0x14,%esp
  8017a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017ae:	50                   	push   %eax
  8017af:	53                   	push   %ebx
  8017b0:	e8 a6 fc ff ff       	call   80145b <fd_lookup>
  8017b5:	83 c4 08             	add    $0x8,%esp
  8017b8:	89 c2                	mov    %eax,%edx
  8017ba:	85 c0                	test   %eax,%eax
  8017bc:	78 6b                	js     801829 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017be:	83 ec 08             	sub    $0x8,%esp
  8017c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c4:	50                   	push   %eax
  8017c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c8:	ff 30                	pushl  (%eax)
  8017ca:	e8 e2 fc ff ff       	call   8014b1 <dev_lookup>
  8017cf:	83 c4 10             	add    $0x10,%esp
  8017d2:	85 c0                	test   %eax,%eax
  8017d4:	78 4a                	js     801820 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017dd:	75 24                	jne    801803 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017df:	a1 04 50 80 00       	mov    0x805004,%eax
  8017e4:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8017ea:	83 ec 04             	sub    $0x4,%esp
  8017ed:	53                   	push   %ebx
  8017ee:	50                   	push   %eax
  8017ef:	68 45 31 80 00       	push   $0x803145
  8017f4:	e8 97 ea ff ff       	call   800290 <cprintf>
		return -E_INVAL;
  8017f9:	83 c4 10             	add    $0x10,%esp
  8017fc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801801:	eb 26                	jmp    801829 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801803:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801806:	8b 52 0c             	mov    0xc(%edx),%edx
  801809:	85 d2                	test   %edx,%edx
  80180b:	74 17                	je     801824 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80180d:	83 ec 04             	sub    $0x4,%esp
  801810:	ff 75 10             	pushl  0x10(%ebp)
  801813:	ff 75 0c             	pushl  0xc(%ebp)
  801816:	50                   	push   %eax
  801817:	ff d2                	call   *%edx
  801819:	89 c2                	mov    %eax,%edx
  80181b:	83 c4 10             	add    $0x10,%esp
  80181e:	eb 09                	jmp    801829 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801820:	89 c2                	mov    %eax,%edx
  801822:	eb 05                	jmp    801829 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801824:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801829:	89 d0                	mov    %edx,%eax
  80182b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80182e:	c9                   	leave  
  80182f:	c3                   	ret    

00801830 <seek>:

int
seek(int fdnum, off_t offset)
{
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801836:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801839:	50                   	push   %eax
  80183a:	ff 75 08             	pushl  0x8(%ebp)
  80183d:	e8 19 fc ff ff       	call   80145b <fd_lookup>
  801842:	83 c4 08             	add    $0x8,%esp
  801845:	85 c0                	test   %eax,%eax
  801847:	78 0e                	js     801857 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801849:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80184c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80184f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801852:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801857:	c9                   	leave  
  801858:	c3                   	ret    

00801859 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801859:	55                   	push   %ebp
  80185a:	89 e5                	mov    %esp,%ebp
  80185c:	53                   	push   %ebx
  80185d:	83 ec 14             	sub    $0x14,%esp
  801860:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801863:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801866:	50                   	push   %eax
  801867:	53                   	push   %ebx
  801868:	e8 ee fb ff ff       	call   80145b <fd_lookup>
  80186d:	83 c4 08             	add    $0x8,%esp
  801870:	89 c2                	mov    %eax,%edx
  801872:	85 c0                	test   %eax,%eax
  801874:	78 68                	js     8018de <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801876:	83 ec 08             	sub    $0x8,%esp
  801879:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80187c:	50                   	push   %eax
  80187d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801880:	ff 30                	pushl  (%eax)
  801882:	e8 2a fc ff ff       	call   8014b1 <dev_lookup>
  801887:	83 c4 10             	add    $0x10,%esp
  80188a:	85 c0                	test   %eax,%eax
  80188c:	78 47                	js     8018d5 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80188e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801891:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801895:	75 24                	jne    8018bb <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801897:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80189c:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8018a2:	83 ec 04             	sub    $0x4,%esp
  8018a5:	53                   	push   %ebx
  8018a6:	50                   	push   %eax
  8018a7:	68 08 31 80 00       	push   $0x803108
  8018ac:	e8 df e9 ff ff       	call   800290 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018b1:	83 c4 10             	add    $0x10,%esp
  8018b4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018b9:	eb 23                	jmp    8018de <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  8018bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018be:	8b 52 18             	mov    0x18(%edx),%edx
  8018c1:	85 d2                	test   %edx,%edx
  8018c3:	74 14                	je     8018d9 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018c5:	83 ec 08             	sub    $0x8,%esp
  8018c8:	ff 75 0c             	pushl  0xc(%ebp)
  8018cb:	50                   	push   %eax
  8018cc:	ff d2                	call   *%edx
  8018ce:	89 c2                	mov    %eax,%edx
  8018d0:	83 c4 10             	add    $0x10,%esp
  8018d3:	eb 09                	jmp    8018de <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018d5:	89 c2                	mov    %eax,%edx
  8018d7:	eb 05                	jmp    8018de <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018d9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8018de:	89 d0                	mov    %edx,%eax
  8018e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e3:	c9                   	leave  
  8018e4:	c3                   	ret    

008018e5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018e5:	55                   	push   %ebp
  8018e6:	89 e5                	mov    %esp,%ebp
  8018e8:	53                   	push   %ebx
  8018e9:	83 ec 14             	sub    $0x14,%esp
  8018ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018f2:	50                   	push   %eax
  8018f3:	ff 75 08             	pushl  0x8(%ebp)
  8018f6:	e8 60 fb ff ff       	call   80145b <fd_lookup>
  8018fb:	83 c4 08             	add    $0x8,%esp
  8018fe:	89 c2                	mov    %eax,%edx
  801900:	85 c0                	test   %eax,%eax
  801902:	78 58                	js     80195c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801904:	83 ec 08             	sub    $0x8,%esp
  801907:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80190a:	50                   	push   %eax
  80190b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80190e:	ff 30                	pushl  (%eax)
  801910:	e8 9c fb ff ff       	call   8014b1 <dev_lookup>
  801915:	83 c4 10             	add    $0x10,%esp
  801918:	85 c0                	test   %eax,%eax
  80191a:	78 37                	js     801953 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80191c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80191f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801923:	74 32                	je     801957 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801925:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801928:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80192f:	00 00 00 
	stat->st_isdir = 0;
  801932:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801939:	00 00 00 
	stat->st_dev = dev;
  80193c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801942:	83 ec 08             	sub    $0x8,%esp
  801945:	53                   	push   %ebx
  801946:	ff 75 f0             	pushl  -0x10(%ebp)
  801949:	ff 50 14             	call   *0x14(%eax)
  80194c:	89 c2                	mov    %eax,%edx
  80194e:	83 c4 10             	add    $0x10,%esp
  801951:	eb 09                	jmp    80195c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801953:	89 c2                	mov    %eax,%edx
  801955:	eb 05                	jmp    80195c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801957:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80195c:	89 d0                	mov    %edx,%eax
  80195e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801961:	c9                   	leave  
  801962:	c3                   	ret    

00801963 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801963:	55                   	push   %ebp
  801964:	89 e5                	mov    %esp,%ebp
  801966:	56                   	push   %esi
  801967:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801968:	83 ec 08             	sub    $0x8,%esp
  80196b:	6a 00                	push   $0x0
  80196d:	ff 75 08             	pushl  0x8(%ebp)
  801970:	e8 e3 01 00 00       	call   801b58 <open>
  801975:	89 c3                	mov    %eax,%ebx
  801977:	83 c4 10             	add    $0x10,%esp
  80197a:	85 c0                	test   %eax,%eax
  80197c:	78 1b                	js     801999 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80197e:	83 ec 08             	sub    $0x8,%esp
  801981:	ff 75 0c             	pushl  0xc(%ebp)
  801984:	50                   	push   %eax
  801985:	e8 5b ff ff ff       	call   8018e5 <fstat>
  80198a:	89 c6                	mov    %eax,%esi
	close(fd);
  80198c:	89 1c 24             	mov    %ebx,(%esp)
  80198f:	e8 f4 fb ff ff       	call   801588 <close>
	return r;
  801994:	83 c4 10             	add    $0x10,%esp
  801997:	89 f0                	mov    %esi,%eax
}
  801999:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80199c:	5b                   	pop    %ebx
  80199d:	5e                   	pop    %esi
  80199e:	5d                   	pop    %ebp
  80199f:	c3                   	ret    

008019a0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	56                   	push   %esi
  8019a4:	53                   	push   %ebx
  8019a5:	89 c6                	mov    %eax,%esi
  8019a7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019a9:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8019b0:	75 12                	jne    8019c4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019b2:	83 ec 0c             	sub    $0xc,%esp
  8019b5:	6a 01                	push   $0x1
  8019b7:	e8 79 0e 00 00       	call   802835 <ipc_find_env>
  8019bc:	a3 00 50 80 00       	mov    %eax,0x805000
  8019c1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019c4:	6a 07                	push   $0x7
  8019c6:	68 00 60 80 00       	push   $0x806000
  8019cb:	56                   	push   %esi
  8019cc:	ff 35 00 50 80 00    	pushl  0x805000
  8019d2:	e8 fc 0d 00 00       	call   8027d3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019d7:	83 c4 0c             	add    $0xc,%esp
  8019da:	6a 00                	push   $0x0
  8019dc:	53                   	push   %ebx
  8019dd:	6a 00                	push   $0x0
  8019df:	e8 74 0d 00 00       	call   802758 <ipc_recv>
}
  8019e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019e7:	5b                   	pop    %ebx
  8019e8:	5e                   	pop    %esi
  8019e9:	5d                   	pop    %ebp
  8019ea:	c3                   	ret    

008019eb <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019eb:	55                   	push   %ebp
  8019ec:	89 e5                	mov    %esp,%ebp
  8019ee:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f4:	8b 40 0c             	mov    0xc(%eax),%eax
  8019f7:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8019fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ff:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a04:	ba 00 00 00 00       	mov    $0x0,%edx
  801a09:	b8 02 00 00 00       	mov    $0x2,%eax
  801a0e:	e8 8d ff ff ff       	call   8019a0 <fsipc>
}
  801a13:	c9                   	leave  
  801a14:	c3                   	ret    

00801a15 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a15:	55                   	push   %ebp
  801a16:	89 e5                	mov    %esp,%ebp
  801a18:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1e:	8b 40 0c             	mov    0xc(%eax),%eax
  801a21:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801a26:	ba 00 00 00 00       	mov    $0x0,%edx
  801a2b:	b8 06 00 00 00       	mov    $0x6,%eax
  801a30:	e8 6b ff ff ff       	call   8019a0 <fsipc>
}
  801a35:	c9                   	leave  
  801a36:	c3                   	ret    

00801a37 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a37:	55                   	push   %ebp
  801a38:	89 e5                	mov    %esp,%ebp
  801a3a:	53                   	push   %ebx
  801a3b:	83 ec 04             	sub    $0x4,%esp
  801a3e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a41:	8b 45 08             	mov    0x8(%ebp),%eax
  801a44:	8b 40 0c             	mov    0xc(%eax),%eax
  801a47:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a4c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a51:	b8 05 00 00 00       	mov    $0x5,%eax
  801a56:	e8 45 ff ff ff       	call   8019a0 <fsipc>
  801a5b:	85 c0                	test   %eax,%eax
  801a5d:	78 2c                	js     801a8b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a5f:	83 ec 08             	sub    $0x8,%esp
  801a62:	68 00 60 80 00       	push   $0x806000
  801a67:	53                   	push   %ebx
  801a68:	e8 a8 ed ff ff       	call   800815 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a6d:	a1 80 60 80 00       	mov    0x806080,%eax
  801a72:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a78:	a1 84 60 80 00       	mov    0x806084,%eax
  801a7d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a83:	83 c4 10             	add    $0x10,%esp
  801a86:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a8e:	c9                   	leave  
  801a8f:	c3                   	ret    

00801a90 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	83 ec 0c             	sub    $0xc,%esp
  801a96:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a99:	8b 55 08             	mov    0x8(%ebp),%edx
  801a9c:	8b 52 0c             	mov    0xc(%edx),%edx
  801a9f:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801aa5:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801aaa:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801aaf:	0f 47 c2             	cmova  %edx,%eax
  801ab2:	a3 04 60 80 00       	mov    %eax,0x806004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801ab7:	50                   	push   %eax
  801ab8:	ff 75 0c             	pushl  0xc(%ebp)
  801abb:	68 08 60 80 00       	push   $0x806008
  801ac0:	e8 e2 ee ff ff       	call   8009a7 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801ac5:	ba 00 00 00 00       	mov    $0x0,%edx
  801aca:	b8 04 00 00 00       	mov    $0x4,%eax
  801acf:	e8 cc fe ff ff       	call   8019a0 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801ad4:	c9                   	leave  
  801ad5:	c3                   	ret    

00801ad6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801ad6:	55                   	push   %ebp
  801ad7:	89 e5                	mov    %esp,%ebp
  801ad9:	56                   	push   %esi
  801ada:	53                   	push   %ebx
  801adb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ade:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae1:	8b 40 0c             	mov    0xc(%eax),%eax
  801ae4:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801ae9:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801aef:	ba 00 00 00 00       	mov    $0x0,%edx
  801af4:	b8 03 00 00 00       	mov    $0x3,%eax
  801af9:	e8 a2 fe ff ff       	call   8019a0 <fsipc>
  801afe:	89 c3                	mov    %eax,%ebx
  801b00:	85 c0                	test   %eax,%eax
  801b02:	78 4b                	js     801b4f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b04:	39 c6                	cmp    %eax,%esi
  801b06:	73 16                	jae    801b1e <devfile_read+0x48>
  801b08:	68 74 31 80 00       	push   $0x803174
  801b0d:	68 7b 31 80 00       	push   $0x80317b
  801b12:	6a 7c                	push   $0x7c
  801b14:	68 90 31 80 00       	push   $0x803190
  801b19:	e8 99 e6 ff ff       	call   8001b7 <_panic>
	assert(r <= PGSIZE);
  801b1e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b23:	7e 16                	jle    801b3b <devfile_read+0x65>
  801b25:	68 9b 31 80 00       	push   $0x80319b
  801b2a:	68 7b 31 80 00       	push   $0x80317b
  801b2f:	6a 7d                	push   $0x7d
  801b31:	68 90 31 80 00       	push   $0x803190
  801b36:	e8 7c e6 ff ff       	call   8001b7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b3b:	83 ec 04             	sub    $0x4,%esp
  801b3e:	50                   	push   %eax
  801b3f:	68 00 60 80 00       	push   $0x806000
  801b44:	ff 75 0c             	pushl  0xc(%ebp)
  801b47:	e8 5b ee ff ff       	call   8009a7 <memmove>
	return r;
  801b4c:	83 c4 10             	add    $0x10,%esp
}
  801b4f:	89 d8                	mov    %ebx,%eax
  801b51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b54:	5b                   	pop    %ebx
  801b55:	5e                   	pop    %esi
  801b56:	5d                   	pop    %ebp
  801b57:	c3                   	ret    

00801b58 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b58:	55                   	push   %ebp
  801b59:	89 e5                	mov    %esp,%ebp
  801b5b:	53                   	push   %ebx
  801b5c:	83 ec 20             	sub    $0x20,%esp
  801b5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b62:	53                   	push   %ebx
  801b63:	e8 74 ec ff ff       	call   8007dc <strlen>
  801b68:	83 c4 10             	add    $0x10,%esp
  801b6b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b70:	7f 67                	jg     801bd9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b72:	83 ec 0c             	sub    $0xc,%esp
  801b75:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b78:	50                   	push   %eax
  801b79:	e8 8e f8 ff ff       	call   80140c <fd_alloc>
  801b7e:	83 c4 10             	add    $0x10,%esp
		return r;
  801b81:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b83:	85 c0                	test   %eax,%eax
  801b85:	78 57                	js     801bde <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b87:	83 ec 08             	sub    $0x8,%esp
  801b8a:	53                   	push   %ebx
  801b8b:	68 00 60 80 00       	push   $0x806000
  801b90:	e8 80 ec ff ff       	call   800815 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b95:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b98:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ba0:	b8 01 00 00 00       	mov    $0x1,%eax
  801ba5:	e8 f6 fd ff ff       	call   8019a0 <fsipc>
  801baa:	89 c3                	mov    %eax,%ebx
  801bac:	83 c4 10             	add    $0x10,%esp
  801baf:	85 c0                	test   %eax,%eax
  801bb1:	79 14                	jns    801bc7 <open+0x6f>
		fd_close(fd, 0);
  801bb3:	83 ec 08             	sub    $0x8,%esp
  801bb6:	6a 00                	push   $0x0
  801bb8:	ff 75 f4             	pushl  -0xc(%ebp)
  801bbb:	e8 47 f9 ff ff       	call   801507 <fd_close>
		return r;
  801bc0:	83 c4 10             	add    $0x10,%esp
  801bc3:	89 da                	mov    %ebx,%edx
  801bc5:	eb 17                	jmp    801bde <open+0x86>
	}

	return fd2num(fd);
  801bc7:	83 ec 0c             	sub    $0xc,%esp
  801bca:	ff 75 f4             	pushl  -0xc(%ebp)
  801bcd:	e8 13 f8 ff ff       	call   8013e5 <fd2num>
  801bd2:	89 c2                	mov    %eax,%edx
  801bd4:	83 c4 10             	add    $0x10,%esp
  801bd7:	eb 05                	jmp    801bde <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801bd9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801bde:	89 d0                	mov    %edx,%eax
  801be0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be3:	c9                   	leave  
  801be4:	c3                   	ret    

00801be5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801be5:	55                   	push   %ebp
  801be6:	89 e5                	mov    %esp,%ebp
  801be8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801beb:	ba 00 00 00 00       	mov    $0x0,%edx
  801bf0:	b8 08 00 00 00       	mov    $0x8,%eax
  801bf5:	e8 a6 fd ff ff       	call   8019a0 <fsipc>
}
  801bfa:	c9                   	leave  
  801bfb:	c3                   	ret    

00801bfc <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	57                   	push   %edi
  801c00:	56                   	push   %esi
  801c01:	53                   	push   %ebx
  801c02:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801c08:	6a 00                	push   $0x0
  801c0a:	ff 75 08             	pushl  0x8(%ebp)
  801c0d:	e8 46 ff ff ff       	call   801b58 <open>
  801c12:	89 c7                	mov    %eax,%edi
  801c14:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801c1a:	83 c4 10             	add    $0x10,%esp
  801c1d:	85 c0                	test   %eax,%eax
  801c1f:	0f 88 8c 04 00 00    	js     8020b1 <spawn+0x4b5>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801c25:	83 ec 04             	sub    $0x4,%esp
  801c28:	68 00 02 00 00       	push   $0x200
  801c2d:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801c33:	50                   	push   %eax
  801c34:	57                   	push   %edi
  801c35:	e8 1e fb ff ff       	call   801758 <readn>
  801c3a:	83 c4 10             	add    $0x10,%esp
  801c3d:	3d 00 02 00 00       	cmp    $0x200,%eax
  801c42:	75 0c                	jne    801c50 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801c44:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801c4b:	45 4c 46 
  801c4e:	74 33                	je     801c83 <spawn+0x87>
		close(fd);
  801c50:	83 ec 0c             	sub    $0xc,%esp
  801c53:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c59:	e8 2a f9 ff ff       	call   801588 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801c5e:	83 c4 0c             	add    $0xc,%esp
  801c61:	68 7f 45 4c 46       	push   $0x464c457f
  801c66:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801c6c:	68 a7 31 80 00       	push   $0x8031a7
  801c71:	e8 1a e6 ff ff       	call   800290 <cprintf>
		return -E_NOT_EXEC;
  801c76:	83 c4 10             	add    $0x10,%esp
  801c79:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801c7e:	e9 e1 04 00 00       	jmp    802164 <spawn+0x568>
  801c83:	b8 07 00 00 00       	mov    $0x7,%eax
  801c88:	cd 30                	int    $0x30
  801c8a:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801c90:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801c96:	85 c0                	test   %eax,%eax
  801c98:	0f 88 1e 04 00 00    	js     8020bc <spawn+0x4c0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801c9e:	89 c6                	mov    %eax,%esi
  801ca0:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801ca6:	69 f6 d8 00 00 00    	imul   $0xd8,%esi,%esi
  801cac:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801cb2:	81 c6 59 00 c0 ee    	add    $0xeec00059,%esi
  801cb8:	b9 11 00 00 00       	mov    $0x11,%ecx
  801cbd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801cbf:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801cc5:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801ccb:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801cd0:	be 00 00 00 00       	mov    $0x0,%esi
  801cd5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801cd8:	eb 13                	jmp    801ced <spawn+0xf1>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801cda:	83 ec 0c             	sub    $0xc,%esp
  801cdd:	50                   	push   %eax
  801cde:	e8 f9 ea ff ff       	call   8007dc <strlen>
  801ce3:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801ce7:	83 c3 01             	add    $0x1,%ebx
  801cea:	83 c4 10             	add    $0x10,%esp
  801ced:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801cf4:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801cf7:	85 c0                	test   %eax,%eax
  801cf9:	75 df                	jne    801cda <spawn+0xde>
  801cfb:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801d01:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801d07:	bf 00 10 40 00       	mov    $0x401000,%edi
  801d0c:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801d0e:	89 fa                	mov    %edi,%edx
  801d10:	83 e2 fc             	and    $0xfffffffc,%edx
  801d13:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801d1a:	29 c2                	sub    %eax,%edx
  801d1c:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801d22:	8d 42 f8             	lea    -0x8(%edx),%eax
  801d25:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801d2a:	0f 86 a2 03 00 00    	jbe    8020d2 <spawn+0x4d6>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d30:	83 ec 04             	sub    $0x4,%esp
  801d33:	6a 07                	push   $0x7
  801d35:	68 00 00 40 00       	push   $0x400000
  801d3a:	6a 00                	push   $0x0
  801d3c:	e8 d7 ee ff ff       	call   800c18 <sys_page_alloc>
  801d41:	83 c4 10             	add    $0x10,%esp
  801d44:	85 c0                	test   %eax,%eax
  801d46:	0f 88 90 03 00 00    	js     8020dc <spawn+0x4e0>
  801d4c:	be 00 00 00 00       	mov    $0x0,%esi
  801d51:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801d57:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d5a:	eb 30                	jmp    801d8c <spawn+0x190>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801d5c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801d62:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801d68:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801d6b:	83 ec 08             	sub    $0x8,%esp
  801d6e:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801d71:	57                   	push   %edi
  801d72:	e8 9e ea ff ff       	call   800815 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801d77:	83 c4 04             	add    $0x4,%esp
  801d7a:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801d7d:	e8 5a ea ff ff       	call   8007dc <strlen>
  801d82:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801d86:	83 c6 01             	add    $0x1,%esi
  801d89:	83 c4 10             	add    $0x10,%esp
  801d8c:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801d92:	7f c8                	jg     801d5c <spawn+0x160>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801d94:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801d9a:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801da0:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801da7:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801dad:	74 19                	je     801dc8 <spawn+0x1cc>
  801daf:	68 34 32 80 00       	push   $0x803234
  801db4:	68 7b 31 80 00       	push   $0x80317b
  801db9:	68 f2 00 00 00       	push   $0xf2
  801dbe:	68 c1 31 80 00       	push   $0x8031c1
  801dc3:	e8 ef e3 ff ff       	call   8001b7 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801dc8:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801dce:	89 f8                	mov    %edi,%eax
  801dd0:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801dd5:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801dd8:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801dde:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801de1:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801de7:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801ded:	83 ec 0c             	sub    $0xc,%esp
  801df0:	6a 07                	push   $0x7
  801df2:	68 00 d0 bf ee       	push   $0xeebfd000
  801df7:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801dfd:	68 00 00 40 00       	push   $0x400000
  801e02:	6a 00                	push   $0x0
  801e04:	e8 52 ee ff ff       	call   800c5b <sys_page_map>
  801e09:	89 c3                	mov    %eax,%ebx
  801e0b:	83 c4 20             	add    $0x20,%esp
  801e0e:	85 c0                	test   %eax,%eax
  801e10:	0f 88 3c 03 00 00    	js     802152 <spawn+0x556>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801e16:	83 ec 08             	sub    $0x8,%esp
  801e19:	68 00 00 40 00       	push   $0x400000
  801e1e:	6a 00                	push   $0x0
  801e20:	e8 78 ee ff ff       	call   800c9d <sys_page_unmap>
  801e25:	89 c3                	mov    %eax,%ebx
  801e27:	83 c4 10             	add    $0x10,%esp
  801e2a:	85 c0                	test   %eax,%eax
  801e2c:	0f 88 20 03 00 00    	js     802152 <spawn+0x556>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801e32:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801e38:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801e3f:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801e45:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801e4c:	00 00 00 
  801e4f:	e9 88 01 00 00       	jmp    801fdc <spawn+0x3e0>
		if (ph->p_type != ELF_PROG_LOAD)
  801e54:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801e5a:	83 38 01             	cmpl   $0x1,(%eax)
  801e5d:	0f 85 6b 01 00 00    	jne    801fce <spawn+0x3d2>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801e63:	89 c2                	mov    %eax,%edx
  801e65:	8b 40 18             	mov    0x18(%eax),%eax
  801e68:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801e6e:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801e71:	83 f8 01             	cmp    $0x1,%eax
  801e74:	19 c0                	sbb    %eax,%eax
  801e76:	83 e0 fe             	and    $0xfffffffe,%eax
  801e79:	83 c0 07             	add    $0x7,%eax
  801e7c:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801e82:	89 d0                	mov    %edx,%eax
  801e84:	8b 7a 04             	mov    0x4(%edx),%edi
  801e87:	89 f9                	mov    %edi,%ecx
  801e89:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801e8f:	8b 7a 10             	mov    0x10(%edx),%edi
  801e92:	8b 52 14             	mov    0x14(%edx),%edx
  801e95:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801e9b:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801e9e:	89 f0                	mov    %esi,%eax
  801ea0:	25 ff 0f 00 00       	and    $0xfff,%eax
  801ea5:	74 14                	je     801ebb <spawn+0x2bf>
		va -= i;
  801ea7:	29 c6                	sub    %eax,%esi
		memsz += i;
  801ea9:	01 c2                	add    %eax,%edx
  801eab:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801eb1:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801eb3:	29 c1                	sub    %eax,%ecx
  801eb5:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801ebb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ec0:	e9 f7 00 00 00       	jmp    801fbc <spawn+0x3c0>
		if (i >= filesz) {
  801ec5:	39 fb                	cmp    %edi,%ebx
  801ec7:	72 27                	jb     801ef0 <spawn+0x2f4>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801ec9:	83 ec 04             	sub    $0x4,%esp
  801ecc:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801ed2:	56                   	push   %esi
  801ed3:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801ed9:	e8 3a ed ff ff       	call   800c18 <sys_page_alloc>
  801ede:	83 c4 10             	add    $0x10,%esp
  801ee1:	85 c0                	test   %eax,%eax
  801ee3:	0f 89 c7 00 00 00    	jns    801fb0 <spawn+0x3b4>
  801ee9:	89 c3                	mov    %eax,%ebx
  801eeb:	e9 fd 01 00 00       	jmp    8020ed <spawn+0x4f1>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ef0:	83 ec 04             	sub    $0x4,%esp
  801ef3:	6a 07                	push   $0x7
  801ef5:	68 00 00 40 00       	push   $0x400000
  801efa:	6a 00                	push   $0x0
  801efc:	e8 17 ed ff ff       	call   800c18 <sys_page_alloc>
  801f01:	83 c4 10             	add    $0x10,%esp
  801f04:	85 c0                	test   %eax,%eax
  801f06:	0f 88 d7 01 00 00    	js     8020e3 <spawn+0x4e7>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801f0c:	83 ec 08             	sub    $0x8,%esp
  801f0f:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801f15:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801f1b:	50                   	push   %eax
  801f1c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801f22:	e8 09 f9 ff ff       	call   801830 <seek>
  801f27:	83 c4 10             	add    $0x10,%esp
  801f2a:	85 c0                	test   %eax,%eax
  801f2c:	0f 88 b5 01 00 00    	js     8020e7 <spawn+0x4eb>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801f32:	83 ec 04             	sub    $0x4,%esp
  801f35:	89 f8                	mov    %edi,%eax
  801f37:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801f3d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801f42:	ba 00 10 00 00       	mov    $0x1000,%edx
  801f47:	0f 47 c2             	cmova  %edx,%eax
  801f4a:	50                   	push   %eax
  801f4b:	68 00 00 40 00       	push   $0x400000
  801f50:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801f56:	e8 fd f7 ff ff       	call   801758 <readn>
  801f5b:	83 c4 10             	add    $0x10,%esp
  801f5e:	85 c0                	test   %eax,%eax
  801f60:	0f 88 85 01 00 00    	js     8020eb <spawn+0x4ef>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801f66:	83 ec 0c             	sub    $0xc,%esp
  801f69:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801f6f:	56                   	push   %esi
  801f70:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801f76:	68 00 00 40 00       	push   $0x400000
  801f7b:	6a 00                	push   $0x0
  801f7d:	e8 d9 ec ff ff       	call   800c5b <sys_page_map>
  801f82:	83 c4 20             	add    $0x20,%esp
  801f85:	85 c0                	test   %eax,%eax
  801f87:	79 15                	jns    801f9e <spawn+0x3a2>
				panic("spawn: sys_page_map data: %e", r);
  801f89:	50                   	push   %eax
  801f8a:	68 cd 31 80 00       	push   $0x8031cd
  801f8f:	68 25 01 00 00       	push   $0x125
  801f94:	68 c1 31 80 00       	push   $0x8031c1
  801f99:	e8 19 e2 ff ff       	call   8001b7 <_panic>
			sys_page_unmap(0, UTEMP);
  801f9e:	83 ec 08             	sub    $0x8,%esp
  801fa1:	68 00 00 40 00       	push   $0x400000
  801fa6:	6a 00                	push   $0x0
  801fa8:	e8 f0 ec ff ff       	call   800c9d <sys_page_unmap>
  801fad:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801fb0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801fb6:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801fbc:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801fc2:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801fc8:	0f 82 f7 fe ff ff    	jb     801ec5 <spawn+0x2c9>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801fce:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801fd5:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801fdc:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801fe3:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801fe9:	0f 8c 65 fe ff ff    	jl     801e54 <spawn+0x258>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801fef:	83 ec 0c             	sub    $0xc,%esp
  801ff2:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ff8:	e8 8b f5 ff ff       	call   801588 <close>
  801ffd:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  802000:	bb 00 00 00 00       	mov    $0x0,%ebx
  802005:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  80200b:	89 d8                	mov    %ebx,%eax
  80200d:	c1 e8 16             	shr    $0x16,%eax
  802010:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802017:	a8 01                	test   $0x1,%al
  802019:	74 42                	je     80205d <spawn+0x461>
  80201b:	89 d8                	mov    %ebx,%eax
  80201d:	c1 e8 0c             	shr    $0xc,%eax
  802020:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802027:	f6 c2 01             	test   $0x1,%dl
  80202a:	74 31                	je     80205d <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  80202c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  802033:	f6 c6 04             	test   $0x4,%dh
  802036:	74 25                	je     80205d <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  802038:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80203f:	83 ec 0c             	sub    $0xc,%esp
  802042:	25 07 0e 00 00       	and    $0xe07,%eax
  802047:	50                   	push   %eax
  802048:	53                   	push   %ebx
  802049:	56                   	push   %esi
  80204a:	53                   	push   %ebx
  80204b:	6a 00                	push   $0x0
  80204d:	e8 09 ec ff ff       	call   800c5b <sys_page_map>
			if (r < 0) {
  802052:	83 c4 20             	add    $0x20,%esp
  802055:	85 c0                	test   %eax,%eax
  802057:	0f 88 b1 00 00 00    	js     80210e <spawn+0x512>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  80205d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802063:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  802069:	75 a0                	jne    80200b <spawn+0x40f>
  80206b:	e9 b3 00 00 00       	jmp    802123 <spawn+0x527>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  802070:	50                   	push   %eax
  802071:	68 ea 31 80 00       	push   $0x8031ea
  802076:	68 86 00 00 00       	push   $0x86
  80207b:	68 c1 31 80 00       	push   $0x8031c1
  802080:	e8 32 e1 ff ff       	call   8001b7 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802085:	83 ec 08             	sub    $0x8,%esp
  802088:	6a 02                	push   $0x2
  80208a:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802090:	e8 4a ec ff ff       	call   800cdf <sys_env_set_status>
  802095:	83 c4 10             	add    $0x10,%esp
  802098:	85 c0                	test   %eax,%eax
  80209a:	79 2b                	jns    8020c7 <spawn+0x4cb>
		panic("sys_env_set_status: %e", r);
  80209c:	50                   	push   %eax
  80209d:	68 04 32 80 00       	push   $0x803204
  8020a2:	68 89 00 00 00       	push   $0x89
  8020a7:	68 c1 31 80 00       	push   $0x8031c1
  8020ac:	e8 06 e1 ff ff       	call   8001b7 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8020b1:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  8020b7:	e9 a8 00 00 00       	jmp    802164 <spawn+0x568>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  8020bc:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8020c2:	e9 9d 00 00 00       	jmp    802164 <spawn+0x568>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  8020c7:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8020cd:	e9 92 00 00 00       	jmp    802164 <spawn+0x568>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8020d2:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  8020d7:	e9 88 00 00 00       	jmp    802164 <spawn+0x568>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  8020dc:	89 c3                	mov    %eax,%ebx
  8020de:	e9 81 00 00 00       	jmp    802164 <spawn+0x568>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8020e3:	89 c3                	mov    %eax,%ebx
  8020e5:	eb 06                	jmp    8020ed <spawn+0x4f1>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8020e7:	89 c3                	mov    %eax,%ebx
  8020e9:	eb 02                	jmp    8020ed <spawn+0x4f1>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8020eb:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  8020ed:	83 ec 0c             	sub    $0xc,%esp
  8020f0:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8020f6:	e8 9e ea ff ff       	call   800b99 <sys_env_destroy>
	close(fd);
  8020fb:	83 c4 04             	add    $0x4,%esp
  8020fe:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802104:	e8 7f f4 ff ff       	call   801588 <close>
	return r;
  802109:	83 c4 10             	add    $0x10,%esp
  80210c:	eb 56                	jmp    802164 <spawn+0x568>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  80210e:	50                   	push   %eax
  80210f:	68 1b 32 80 00       	push   $0x80321b
  802114:	68 82 00 00 00       	push   $0x82
  802119:	68 c1 31 80 00       	push   $0x8031c1
  80211e:	e8 94 e0 ff ff       	call   8001b7 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802123:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  80212a:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  80212d:	83 ec 08             	sub    $0x8,%esp
  802130:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802136:	50                   	push   %eax
  802137:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80213d:	e8 df eb ff ff       	call   800d21 <sys_env_set_trapframe>
  802142:	83 c4 10             	add    $0x10,%esp
  802145:	85 c0                	test   %eax,%eax
  802147:	0f 89 38 ff ff ff    	jns    802085 <spawn+0x489>
  80214d:	e9 1e ff ff ff       	jmp    802070 <spawn+0x474>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802152:	83 ec 08             	sub    $0x8,%esp
  802155:	68 00 00 40 00       	push   $0x400000
  80215a:	6a 00                	push   $0x0
  80215c:	e8 3c eb ff ff       	call   800c9d <sys_page_unmap>
  802161:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802164:	89 d8                	mov    %ebx,%eax
  802166:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802169:	5b                   	pop    %ebx
  80216a:	5e                   	pop    %esi
  80216b:	5f                   	pop    %edi
  80216c:	5d                   	pop    %ebp
  80216d:	c3                   	ret    

0080216e <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  80216e:	55                   	push   %ebp
  80216f:	89 e5                	mov    %esp,%ebp
  802171:	56                   	push   %esi
  802172:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802173:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802176:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80217b:	eb 03                	jmp    802180 <spawnl+0x12>
		argc++;
  80217d:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802180:	83 c2 04             	add    $0x4,%edx
  802183:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802187:	75 f4                	jne    80217d <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802189:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802190:	83 e2 f0             	and    $0xfffffff0,%edx
  802193:	29 d4                	sub    %edx,%esp
  802195:	8d 54 24 03          	lea    0x3(%esp),%edx
  802199:	c1 ea 02             	shr    $0x2,%edx
  80219c:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  8021a3:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  8021a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021a8:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  8021af:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  8021b6:	00 
  8021b7:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8021b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8021be:	eb 0a                	jmp    8021ca <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  8021c0:	83 c0 01             	add    $0x1,%eax
  8021c3:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  8021c7:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8021ca:	39 d0                	cmp    %edx,%eax
  8021cc:	75 f2                	jne    8021c0 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  8021ce:	83 ec 08             	sub    $0x8,%esp
  8021d1:	56                   	push   %esi
  8021d2:	ff 75 08             	pushl  0x8(%ebp)
  8021d5:	e8 22 fa ff ff       	call   801bfc <spawn>
}
  8021da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021dd:	5b                   	pop    %ebx
  8021de:	5e                   	pop    %esi
  8021df:	5d                   	pop    %ebp
  8021e0:	c3                   	ret    

008021e1 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8021e1:	55                   	push   %ebp
  8021e2:	89 e5                	mov    %esp,%ebp
  8021e4:	56                   	push   %esi
  8021e5:	53                   	push   %ebx
  8021e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8021e9:	83 ec 0c             	sub    $0xc,%esp
  8021ec:	ff 75 08             	pushl  0x8(%ebp)
  8021ef:	e8 01 f2 ff ff       	call   8013f5 <fd2data>
  8021f4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8021f6:	83 c4 08             	add    $0x8,%esp
  8021f9:	68 5c 32 80 00       	push   $0x80325c
  8021fe:	53                   	push   %ebx
  8021ff:	e8 11 e6 ff ff       	call   800815 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802204:	8b 46 04             	mov    0x4(%esi),%eax
  802207:	2b 06                	sub    (%esi),%eax
  802209:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80220f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802216:	00 00 00 
	stat->st_dev = &devpipe;
  802219:	c7 83 88 00 00 00 20 	movl   $0x804020,0x88(%ebx)
  802220:	40 80 00 
	return 0;
}
  802223:	b8 00 00 00 00       	mov    $0x0,%eax
  802228:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80222b:	5b                   	pop    %ebx
  80222c:	5e                   	pop    %esi
  80222d:	5d                   	pop    %ebp
  80222e:	c3                   	ret    

0080222f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80222f:	55                   	push   %ebp
  802230:	89 e5                	mov    %esp,%ebp
  802232:	53                   	push   %ebx
  802233:	83 ec 0c             	sub    $0xc,%esp
  802236:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802239:	53                   	push   %ebx
  80223a:	6a 00                	push   $0x0
  80223c:	e8 5c ea ff ff       	call   800c9d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802241:	89 1c 24             	mov    %ebx,(%esp)
  802244:	e8 ac f1 ff ff       	call   8013f5 <fd2data>
  802249:	83 c4 08             	add    $0x8,%esp
  80224c:	50                   	push   %eax
  80224d:	6a 00                	push   $0x0
  80224f:	e8 49 ea ff ff       	call   800c9d <sys_page_unmap>
}
  802254:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802257:	c9                   	leave  
  802258:	c3                   	ret    

00802259 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802259:	55                   	push   %ebp
  80225a:	89 e5                	mov    %esp,%ebp
  80225c:	57                   	push   %edi
  80225d:	56                   	push   %esi
  80225e:	53                   	push   %ebx
  80225f:	83 ec 1c             	sub    $0x1c,%esp
  802262:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802265:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802267:	a1 04 50 80 00       	mov    0x805004,%eax
  80226c:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802272:	83 ec 0c             	sub    $0xc,%esp
  802275:	ff 75 e0             	pushl  -0x20(%ebp)
  802278:	e8 fd 05 00 00       	call   80287a <pageref>
  80227d:	89 c3                	mov    %eax,%ebx
  80227f:	89 3c 24             	mov    %edi,(%esp)
  802282:	e8 f3 05 00 00       	call   80287a <pageref>
  802287:	83 c4 10             	add    $0x10,%esp
  80228a:	39 c3                	cmp    %eax,%ebx
  80228c:	0f 94 c1             	sete   %cl
  80228f:	0f b6 c9             	movzbl %cl,%ecx
  802292:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802295:	8b 15 04 50 80 00    	mov    0x805004,%edx
  80229b:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  8022a1:	39 ce                	cmp    %ecx,%esi
  8022a3:	74 1e                	je     8022c3 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  8022a5:	39 c3                	cmp    %eax,%ebx
  8022a7:	75 be                	jne    802267 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8022a9:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  8022af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8022b2:	50                   	push   %eax
  8022b3:	56                   	push   %esi
  8022b4:	68 63 32 80 00       	push   $0x803263
  8022b9:	e8 d2 df ff ff       	call   800290 <cprintf>
  8022be:	83 c4 10             	add    $0x10,%esp
  8022c1:	eb a4                	jmp    802267 <_pipeisclosed+0xe>
	}
}
  8022c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022c9:	5b                   	pop    %ebx
  8022ca:	5e                   	pop    %esi
  8022cb:	5f                   	pop    %edi
  8022cc:	5d                   	pop    %ebp
  8022cd:	c3                   	ret    

008022ce <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022ce:	55                   	push   %ebp
  8022cf:	89 e5                	mov    %esp,%ebp
  8022d1:	57                   	push   %edi
  8022d2:	56                   	push   %esi
  8022d3:	53                   	push   %ebx
  8022d4:	83 ec 28             	sub    $0x28,%esp
  8022d7:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8022da:	56                   	push   %esi
  8022db:	e8 15 f1 ff ff       	call   8013f5 <fd2data>
  8022e0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022e2:	83 c4 10             	add    $0x10,%esp
  8022e5:	bf 00 00 00 00       	mov    $0x0,%edi
  8022ea:	eb 4b                	jmp    802337 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8022ec:	89 da                	mov    %ebx,%edx
  8022ee:	89 f0                	mov    %esi,%eax
  8022f0:	e8 64 ff ff ff       	call   802259 <_pipeisclosed>
  8022f5:	85 c0                	test   %eax,%eax
  8022f7:	75 48                	jne    802341 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8022f9:	e8 fb e8 ff ff       	call   800bf9 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8022fe:	8b 43 04             	mov    0x4(%ebx),%eax
  802301:	8b 0b                	mov    (%ebx),%ecx
  802303:	8d 51 20             	lea    0x20(%ecx),%edx
  802306:	39 d0                	cmp    %edx,%eax
  802308:	73 e2                	jae    8022ec <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80230a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80230d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802311:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802314:	89 c2                	mov    %eax,%edx
  802316:	c1 fa 1f             	sar    $0x1f,%edx
  802319:	89 d1                	mov    %edx,%ecx
  80231b:	c1 e9 1b             	shr    $0x1b,%ecx
  80231e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802321:	83 e2 1f             	and    $0x1f,%edx
  802324:	29 ca                	sub    %ecx,%edx
  802326:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80232a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80232e:	83 c0 01             	add    $0x1,%eax
  802331:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802334:	83 c7 01             	add    $0x1,%edi
  802337:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80233a:	75 c2                	jne    8022fe <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80233c:	8b 45 10             	mov    0x10(%ebp),%eax
  80233f:	eb 05                	jmp    802346 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802341:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802346:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802349:	5b                   	pop    %ebx
  80234a:	5e                   	pop    %esi
  80234b:	5f                   	pop    %edi
  80234c:	5d                   	pop    %ebp
  80234d:	c3                   	ret    

0080234e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80234e:	55                   	push   %ebp
  80234f:	89 e5                	mov    %esp,%ebp
  802351:	57                   	push   %edi
  802352:	56                   	push   %esi
  802353:	53                   	push   %ebx
  802354:	83 ec 18             	sub    $0x18,%esp
  802357:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80235a:	57                   	push   %edi
  80235b:	e8 95 f0 ff ff       	call   8013f5 <fd2data>
  802360:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802362:	83 c4 10             	add    $0x10,%esp
  802365:	bb 00 00 00 00       	mov    $0x0,%ebx
  80236a:	eb 3d                	jmp    8023a9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80236c:	85 db                	test   %ebx,%ebx
  80236e:	74 04                	je     802374 <devpipe_read+0x26>
				return i;
  802370:	89 d8                	mov    %ebx,%eax
  802372:	eb 44                	jmp    8023b8 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802374:	89 f2                	mov    %esi,%edx
  802376:	89 f8                	mov    %edi,%eax
  802378:	e8 dc fe ff ff       	call   802259 <_pipeisclosed>
  80237d:	85 c0                	test   %eax,%eax
  80237f:	75 32                	jne    8023b3 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802381:	e8 73 e8 ff ff       	call   800bf9 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802386:	8b 06                	mov    (%esi),%eax
  802388:	3b 46 04             	cmp    0x4(%esi),%eax
  80238b:	74 df                	je     80236c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80238d:	99                   	cltd   
  80238e:	c1 ea 1b             	shr    $0x1b,%edx
  802391:	01 d0                	add    %edx,%eax
  802393:	83 e0 1f             	and    $0x1f,%eax
  802396:	29 d0                	sub    %edx,%eax
  802398:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80239d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023a0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8023a3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023a6:	83 c3 01             	add    $0x1,%ebx
  8023a9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8023ac:	75 d8                	jne    802386 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8023ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8023b1:	eb 05                	jmp    8023b8 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8023b3:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8023b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023bb:	5b                   	pop    %ebx
  8023bc:	5e                   	pop    %esi
  8023bd:	5f                   	pop    %edi
  8023be:	5d                   	pop    %ebp
  8023bf:	c3                   	ret    

008023c0 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8023c0:	55                   	push   %ebp
  8023c1:	89 e5                	mov    %esp,%ebp
  8023c3:	56                   	push   %esi
  8023c4:	53                   	push   %ebx
  8023c5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8023c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023cb:	50                   	push   %eax
  8023cc:	e8 3b f0 ff ff       	call   80140c <fd_alloc>
  8023d1:	83 c4 10             	add    $0x10,%esp
  8023d4:	89 c2                	mov    %eax,%edx
  8023d6:	85 c0                	test   %eax,%eax
  8023d8:	0f 88 2c 01 00 00    	js     80250a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023de:	83 ec 04             	sub    $0x4,%esp
  8023e1:	68 07 04 00 00       	push   $0x407
  8023e6:	ff 75 f4             	pushl  -0xc(%ebp)
  8023e9:	6a 00                	push   $0x0
  8023eb:	e8 28 e8 ff ff       	call   800c18 <sys_page_alloc>
  8023f0:	83 c4 10             	add    $0x10,%esp
  8023f3:	89 c2                	mov    %eax,%edx
  8023f5:	85 c0                	test   %eax,%eax
  8023f7:	0f 88 0d 01 00 00    	js     80250a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8023fd:	83 ec 0c             	sub    $0xc,%esp
  802400:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802403:	50                   	push   %eax
  802404:	e8 03 f0 ff ff       	call   80140c <fd_alloc>
  802409:	89 c3                	mov    %eax,%ebx
  80240b:	83 c4 10             	add    $0x10,%esp
  80240e:	85 c0                	test   %eax,%eax
  802410:	0f 88 e2 00 00 00    	js     8024f8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802416:	83 ec 04             	sub    $0x4,%esp
  802419:	68 07 04 00 00       	push   $0x407
  80241e:	ff 75 f0             	pushl  -0x10(%ebp)
  802421:	6a 00                	push   $0x0
  802423:	e8 f0 e7 ff ff       	call   800c18 <sys_page_alloc>
  802428:	89 c3                	mov    %eax,%ebx
  80242a:	83 c4 10             	add    $0x10,%esp
  80242d:	85 c0                	test   %eax,%eax
  80242f:	0f 88 c3 00 00 00    	js     8024f8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802435:	83 ec 0c             	sub    $0xc,%esp
  802438:	ff 75 f4             	pushl  -0xc(%ebp)
  80243b:	e8 b5 ef ff ff       	call   8013f5 <fd2data>
  802440:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802442:	83 c4 0c             	add    $0xc,%esp
  802445:	68 07 04 00 00       	push   $0x407
  80244a:	50                   	push   %eax
  80244b:	6a 00                	push   $0x0
  80244d:	e8 c6 e7 ff ff       	call   800c18 <sys_page_alloc>
  802452:	89 c3                	mov    %eax,%ebx
  802454:	83 c4 10             	add    $0x10,%esp
  802457:	85 c0                	test   %eax,%eax
  802459:	0f 88 89 00 00 00    	js     8024e8 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80245f:	83 ec 0c             	sub    $0xc,%esp
  802462:	ff 75 f0             	pushl  -0x10(%ebp)
  802465:	e8 8b ef ff ff       	call   8013f5 <fd2data>
  80246a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802471:	50                   	push   %eax
  802472:	6a 00                	push   $0x0
  802474:	56                   	push   %esi
  802475:	6a 00                	push   $0x0
  802477:	e8 df e7 ff ff       	call   800c5b <sys_page_map>
  80247c:	89 c3                	mov    %eax,%ebx
  80247e:	83 c4 20             	add    $0x20,%esp
  802481:	85 c0                	test   %eax,%eax
  802483:	78 55                	js     8024da <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802485:	8b 15 20 40 80 00    	mov    0x804020,%edx
  80248b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80248e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802490:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802493:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80249a:	8b 15 20 40 80 00    	mov    0x804020,%edx
  8024a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024a3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8024a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024a8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8024af:	83 ec 0c             	sub    $0xc,%esp
  8024b2:	ff 75 f4             	pushl  -0xc(%ebp)
  8024b5:	e8 2b ef ff ff       	call   8013e5 <fd2num>
  8024ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024bd:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8024bf:	83 c4 04             	add    $0x4,%esp
  8024c2:	ff 75 f0             	pushl  -0x10(%ebp)
  8024c5:	e8 1b ef ff ff       	call   8013e5 <fd2num>
  8024ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024cd:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8024d0:	83 c4 10             	add    $0x10,%esp
  8024d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8024d8:	eb 30                	jmp    80250a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8024da:	83 ec 08             	sub    $0x8,%esp
  8024dd:	56                   	push   %esi
  8024de:	6a 00                	push   $0x0
  8024e0:	e8 b8 e7 ff ff       	call   800c9d <sys_page_unmap>
  8024e5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8024e8:	83 ec 08             	sub    $0x8,%esp
  8024eb:	ff 75 f0             	pushl  -0x10(%ebp)
  8024ee:	6a 00                	push   $0x0
  8024f0:	e8 a8 e7 ff ff       	call   800c9d <sys_page_unmap>
  8024f5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8024f8:	83 ec 08             	sub    $0x8,%esp
  8024fb:	ff 75 f4             	pushl  -0xc(%ebp)
  8024fe:	6a 00                	push   $0x0
  802500:	e8 98 e7 ff ff       	call   800c9d <sys_page_unmap>
  802505:	83 c4 10             	add    $0x10,%esp
  802508:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80250a:	89 d0                	mov    %edx,%eax
  80250c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80250f:	5b                   	pop    %ebx
  802510:	5e                   	pop    %esi
  802511:	5d                   	pop    %ebp
  802512:	c3                   	ret    

00802513 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802513:	55                   	push   %ebp
  802514:	89 e5                	mov    %esp,%ebp
  802516:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802519:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80251c:	50                   	push   %eax
  80251d:	ff 75 08             	pushl  0x8(%ebp)
  802520:	e8 36 ef ff ff       	call   80145b <fd_lookup>
  802525:	83 c4 10             	add    $0x10,%esp
  802528:	85 c0                	test   %eax,%eax
  80252a:	78 18                	js     802544 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80252c:	83 ec 0c             	sub    $0xc,%esp
  80252f:	ff 75 f4             	pushl  -0xc(%ebp)
  802532:	e8 be ee ff ff       	call   8013f5 <fd2data>
	return _pipeisclosed(fd, p);
  802537:	89 c2                	mov    %eax,%edx
  802539:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80253c:	e8 18 fd ff ff       	call   802259 <_pipeisclosed>
  802541:	83 c4 10             	add    $0x10,%esp
}
  802544:	c9                   	leave  
  802545:	c3                   	ret    

00802546 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802546:	55                   	push   %ebp
  802547:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802549:	b8 00 00 00 00       	mov    $0x0,%eax
  80254e:	5d                   	pop    %ebp
  80254f:	c3                   	ret    

00802550 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802550:	55                   	push   %ebp
  802551:	89 e5                	mov    %esp,%ebp
  802553:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802556:	68 7b 32 80 00       	push   $0x80327b
  80255b:	ff 75 0c             	pushl  0xc(%ebp)
  80255e:	e8 b2 e2 ff ff       	call   800815 <strcpy>
	return 0;
}
  802563:	b8 00 00 00 00       	mov    $0x0,%eax
  802568:	c9                   	leave  
  802569:	c3                   	ret    

0080256a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80256a:	55                   	push   %ebp
  80256b:	89 e5                	mov    %esp,%ebp
  80256d:	57                   	push   %edi
  80256e:	56                   	push   %esi
  80256f:	53                   	push   %ebx
  802570:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802576:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80257b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802581:	eb 2d                	jmp    8025b0 <devcons_write+0x46>
		m = n - tot;
  802583:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802586:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802588:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80258b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802590:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802593:	83 ec 04             	sub    $0x4,%esp
  802596:	53                   	push   %ebx
  802597:	03 45 0c             	add    0xc(%ebp),%eax
  80259a:	50                   	push   %eax
  80259b:	57                   	push   %edi
  80259c:	e8 06 e4 ff ff       	call   8009a7 <memmove>
		sys_cputs(buf, m);
  8025a1:	83 c4 08             	add    $0x8,%esp
  8025a4:	53                   	push   %ebx
  8025a5:	57                   	push   %edi
  8025a6:	e8 b1 e5 ff ff       	call   800b5c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8025ab:	01 de                	add    %ebx,%esi
  8025ad:	83 c4 10             	add    $0x10,%esp
  8025b0:	89 f0                	mov    %esi,%eax
  8025b2:	3b 75 10             	cmp    0x10(%ebp),%esi
  8025b5:	72 cc                	jb     802583 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8025b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025ba:	5b                   	pop    %ebx
  8025bb:	5e                   	pop    %esi
  8025bc:	5f                   	pop    %edi
  8025bd:	5d                   	pop    %ebp
  8025be:	c3                   	ret    

008025bf <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8025bf:	55                   	push   %ebp
  8025c0:	89 e5                	mov    %esp,%ebp
  8025c2:	83 ec 08             	sub    $0x8,%esp
  8025c5:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8025ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8025ce:	74 2a                	je     8025fa <devcons_read+0x3b>
  8025d0:	eb 05                	jmp    8025d7 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8025d2:	e8 22 e6 ff ff       	call   800bf9 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8025d7:	e8 9e e5 ff ff       	call   800b7a <sys_cgetc>
  8025dc:	85 c0                	test   %eax,%eax
  8025de:	74 f2                	je     8025d2 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8025e0:	85 c0                	test   %eax,%eax
  8025e2:	78 16                	js     8025fa <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8025e4:	83 f8 04             	cmp    $0x4,%eax
  8025e7:	74 0c                	je     8025f5 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8025e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8025ec:	88 02                	mov    %al,(%edx)
	return 1;
  8025ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8025f3:	eb 05                	jmp    8025fa <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8025f5:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8025fa:	c9                   	leave  
  8025fb:	c3                   	ret    

008025fc <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8025fc:	55                   	push   %ebp
  8025fd:	89 e5                	mov    %esp,%ebp
  8025ff:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802602:	8b 45 08             	mov    0x8(%ebp),%eax
  802605:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802608:	6a 01                	push   $0x1
  80260a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80260d:	50                   	push   %eax
  80260e:	e8 49 e5 ff ff       	call   800b5c <sys_cputs>
}
  802613:	83 c4 10             	add    $0x10,%esp
  802616:	c9                   	leave  
  802617:	c3                   	ret    

00802618 <getchar>:

int
getchar(void)
{
  802618:	55                   	push   %ebp
  802619:	89 e5                	mov    %esp,%ebp
  80261b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80261e:	6a 01                	push   $0x1
  802620:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802623:	50                   	push   %eax
  802624:	6a 00                	push   $0x0
  802626:	e8 99 f0 ff ff       	call   8016c4 <read>
	if (r < 0)
  80262b:	83 c4 10             	add    $0x10,%esp
  80262e:	85 c0                	test   %eax,%eax
  802630:	78 0f                	js     802641 <getchar+0x29>
		return r;
	if (r < 1)
  802632:	85 c0                	test   %eax,%eax
  802634:	7e 06                	jle    80263c <getchar+0x24>
		return -E_EOF;
	return c;
  802636:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80263a:	eb 05                	jmp    802641 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80263c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802641:	c9                   	leave  
  802642:	c3                   	ret    

00802643 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802643:	55                   	push   %ebp
  802644:	89 e5                	mov    %esp,%ebp
  802646:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802649:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80264c:	50                   	push   %eax
  80264d:	ff 75 08             	pushl  0x8(%ebp)
  802650:	e8 06 ee ff ff       	call   80145b <fd_lookup>
  802655:	83 c4 10             	add    $0x10,%esp
  802658:	85 c0                	test   %eax,%eax
  80265a:	78 11                	js     80266d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80265c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80265f:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802665:	39 10                	cmp    %edx,(%eax)
  802667:	0f 94 c0             	sete   %al
  80266a:	0f b6 c0             	movzbl %al,%eax
}
  80266d:	c9                   	leave  
  80266e:	c3                   	ret    

0080266f <opencons>:

int
opencons(void)
{
  80266f:	55                   	push   %ebp
  802670:	89 e5                	mov    %esp,%ebp
  802672:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802675:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802678:	50                   	push   %eax
  802679:	e8 8e ed ff ff       	call   80140c <fd_alloc>
  80267e:	83 c4 10             	add    $0x10,%esp
		return r;
  802681:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802683:	85 c0                	test   %eax,%eax
  802685:	78 3e                	js     8026c5 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802687:	83 ec 04             	sub    $0x4,%esp
  80268a:	68 07 04 00 00       	push   $0x407
  80268f:	ff 75 f4             	pushl  -0xc(%ebp)
  802692:	6a 00                	push   $0x0
  802694:	e8 7f e5 ff ff       	call   800c18 <sys_page_alloc>
  802699:	83 c4 10             	add    $0x10,%esp
		return r;
  80269c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80269e:	85 c0                	test   %eax,%eax
  8026a0:	78 23                	js     8026c5 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8026a2:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8026a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026ab:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8026ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026b0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8026b7:	83 ec 0c             	sub    $0xc,%esp
  8026ba:	50                   	push   %eax
  8026bb:	e8 25 ed ff ff       	call   8013e5 <fd2num>
  8026c0:	89 c2                	mov    %eax,%edx
  8026c2:	83 c4 10             	add    $0x10,%esp
}
  8026c5:	89 d0                	mov    %edx,%eax
  8026c7:	c9                   	leave  
  8026c8:	c3                   	ret    

008026c9 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8026c9:	55                   	push   %ebp
  8026ca:	89 e5                	mov    %esp,%ebp
  8026cc:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8026cf:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8026d6:	75 2a                	jne    802702 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  8026d8:	83 ec 04             	sub    $0x4,%esp
  8026db:	6a 07                	push   $0x7
  8026dd:	68 00 f0 bf ee       	push   $0xeebff000
  8026e2:	6a 00                	push   $0x0
  8026e4:	e8 2f e5 ff ff       	call   800c18 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8026e9:	83 c4 10             	add    $0x10,%esp
  8026ec:	85 c0                	test   %eax,%eax
  8026ee:	79 12                	jns    802702 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8026f0:	50                   	push   %eax
  8026f1:	68 58 30 80 00       	push   $0x803058
  8026f6:	6a 23                	push   $0x23
  8026f8:	68 87 32 80 00       	push   $0x803287
  8026fd:	e8 b5 da ff ff       	call   8001b7 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802702:	8b 45 08             	mov    0x8(%ebp),%eax
  802705:	a3 00 70 80 00       	mov    %eax,0x807000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80270a:	83 ec 08             	sub    $0x8,%esp
  80270d:	68 34 27 80 00       	push   $0x802734
  802712:	6a 00                	push   $0x0
  802714:	e8 4a e6 ff ff       	call   800d63 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802719:	83 c4 10             	add    $0x10,%esp
  80271c:	85 c0                	test   %eax,%eax
  80271e:	79 12                	jns    802732 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802720:	50                   	push   %eax
  802721:	68 58 30 80 00       	push   $0x803058
  802726:	6a 2c                	push   $0x2c
  802728:	68 87 32 80 00       	push   $0x803287
  80272d:	e8 85 da ff ff       	call   8001b7 <_panic>
	}
}
  802732:	c9                   	leave  
  802733:	c3                   	ret    

00802734 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802734:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802735:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80273a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80273c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  80273f:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802743:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802748:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80274c:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  80274e:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802751:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802752:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802755:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802756:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802757:	c3                   	ret    

00802758 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802758:	55                   	push   %ebp
  802759:	89 e5                	mov    %esp,%ebp
  80275b:	56                   	push   %esi
  80275c:	53                   	push   %ebx
  80275d:	8b 75 08             	mov    0x8(%ebp),%esi
  802760:	8b 45 0c             	mov    0xc(%ebp),%eax
  802763:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802766:	85 c0                	test   %eax,%eax
  802768:	75 12                	jne    80277c <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80276a:	83 ec 0c             	sub    $0xc,%esp
  80276d:	68 00 00 c0 ee       	push   $0xeec00000
  802772:	e8 51 e6 ff ff       	call   800dc8 <sys_ipc_recv>
  802777:	83 c4 10             	add    $0x10,%esp
  80277a:	eb 0c                	jmp    802788 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80277c:	83 ec 0c             	sub    $0xc,%esp
  80277f:	50                   	push   %eax
  802780:	e8 43 e6 ff ff       	call   800dc8 <sys_ipc_recv>
  802785:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802788:	85 f6                	test   %esi,%esi
  80278a:	0f 95 c1             	setne  %cl
  80278d:	85 db                	test   %ebx,%ebx
  80278f:	0f 95 c2             	setne  %dl
  802792:	84 d1                	test   %dl,%cl
  802794:	74 09                	je     80279f <ipc_recv+0x47>
  802796:	89 c2                	mov    %eax,%edx
  802798:	c1 ea 1f             	shr    $0x1f,%edx
  80279b:	84 d2                	test   %dl,%dl
  80279d:	75 2d                	jne    8027cc <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80279f:	85 f6                	test   %esi,%esi
  8027a1:	74 0d                	je     8027b0 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8027a3:	a1 04 50 80 00       	mov    0x805004,%eax
  8027a8:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8027ae:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8027b0:	85 db                	test   %ebx,%ebx
  8027b2:	74 0d                	je     8027c1 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8027b4:	a1 04 50 80 00       	mov    0x805004,%eax
  8027b9:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  8027bf:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8027c1:	a1 04 50 80 00       	mov    0x805004,%eax
  8027c6:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  8027cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8027cf:	5b                   	pop    %ebx
  8027d0:	5e                   	pop    %esi
  8027d1:	5d                   	pop    %ebp
  8027d2:	c3                   	ret    

008027d3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8027d3:	55                   	push   %ebp
  8027d4:	89 e5                	mov    %esp,%ebp
  8027d6:	57                   	push   %edi
  8027d7:	56                   	push   %esi
  8027d8:	53                   	push   %ebx
  8027d9:	83 ec 0c             	sub    $0xc,%esp
  8027dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8027df:	8b 75 0c             	mov    0xc(%ebp),%esi
  8027e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8027e5:	85 db                	test   %ebx,%ebx
  8027e7:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8027ec:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8027ef:	ff 75 14             	pushl  0x14(%ebp)
  8027f2:	53                   	push   %ebx
  8027f3:	56                   	push   %esi
  8027f4:	57                   	push   %edi
  8027f5:	e8 ab e5 ff ff       	call   800da5 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8027fa:	89 c2                	mov    %eax,%edx
  8027fc:	c1 ea 1f             	shr    $0x1f,%edx
  8027ff:	83 c4 10             	add    $0x10,%esp
  802802:	84 d2                	test   %dl,%dl
  802804:	74 17                	je     80281d <ipc_send+0x4a>
  802806:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802809:	74 12                	je     80281d <ipc_send+0x4a>
			panic("failed ipc %e", r);
  80280b:	50                   	push   %eax
  80280c:	68 95 32 80 00       	push   $0x803295
  802811:	6a 47                	push   $0x47
  802813:	68 a3 32 80 00       	push   $0x8032a3
  802818:	e8 9a d9 ff ff       	call   8001b7 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80281d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802820:	75 07                	jne    802829 <ipc_send+0x56>
			sys_yield();
  802822:	e8 d2 e3 ff ff       	call   800bf9 <sys_yield>
  802827:	eb c6                	jmp    8027ef <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802829:	85 c0                	test   %eax,%eax
  80282b:	75 c2                	jne    8027ef <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80282d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802830:	5b                   	pop    %ebx
  802831:	5e                   	pop    %esi
  802832:	5f                   	pop    %edi
  802833:	5d                   	pop    %ebp
  802834:	c3                   	ret    

00802835 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802835:	55                   	push   %ebp
  802836:	89 e5                	mov    %esp,%ebp
  802838:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80283b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802840:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  802846:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80284c:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  802852:	39 ca                	cmp    %ecx,%edx
  802854:	75 13                	jne    802869 <ipc_find_env+0x34>
			return envs[i].env_id;
  802856:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  80285c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802861:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  802867:	eb 0f                	jmp    802878 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802869:	83 c0 01             	add    $0x1,%eax
  80286c:	3d 00 04 00 00       	cmp    $0x400,%eax
  802871:	75 cd                	jne    802840 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802873:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802878:	5d                   	pop    %ebp
  802879:	c3                   	ret    

0080287a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80287a:	55                   	push   %ebp
  80287b:	89 e5                	mov    %esp,%ebp
  80287d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802880:	89 d0                	mov    %edx,%eax
  802882:	c1 e8 16             	shr    $0x16,%eax
  802885:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80288c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802891:	f6 c1 01             	test   $0x1,%cl
  802894:	74 1d                	je     8028b3 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802896:	c1 ea 0c             	shr    $0xc,%edx
  802899:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8028a0:	f6 c2 01             	test   $0x1,%dl
  8028a3:	74 0e                	je     8028b3 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8028a5:	c1 ea 0c             	shr    $0xc,%edx
  8028a8:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8028af:	ef 
  8028b0:	0f b7 c0             	movzwl %ax,%eax
}
  8028b3:	5d                   	pop    %ebp
  8028b4:	c3                   	ret    
  8028b5:	66 90                	xchg   %ax,%ax
  8028b7:	66 90                	xchg   %ax,%ax
  8028b9:	66 90                	xchg   %ax,%ax
  8028bb:	66 90                	xchg   %ax,%ax
  8028bd:	66 90                	xchg   %ax,%ax
  8028bf:	90                   	nop

008028c0 <__udivdi3>:
  8028c0:	55                   	push   %ebp
  8028c1:	57                   	push   %edi
  8028c2:	56                   	push   %esi
  8028c3:	53                   	push   %ebx
  8028c4:	83 ec 1c             	sub    $0x1c,%esp
  8028c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8028cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8028cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8028d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8028d7:	85 f6                	test   %esi,%esi
  8028d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8028dd:	89 ca                	mov    %ecx,%edx
  8028df:	89 f8                	mov    %edi,%eax
  8028e1:	75 3d                	jne    802920 <__udivdi3+0x60>
  8028e3:	39 cf                	cmp    %ecx,%edi
  8028e5:	0f 87 c5 00 00 00    	ja     8029b0 <__udivdi3+0xf0>
  8028eb:	85 ff                	test   %edi,%edi
  8028ed:	89 fd                	mov    %edi,%ebp
  8028ef:	75 0b                	jne    8028fc <__udivdi3+0x3c>
  8028f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8028f6:	31 d2                	xor    %edx,%edx
  8028f8:	f7 f7                	div    %edi
  8028fa:	89 c5                	mov    %eax,%ebp
  8028fc:	89 c8                	mov    %ecx,%eax
  8028fe:	31 d2                	xor    %edx,%edx
  802900:	f7 f5                	div    %ebp
  802902:	89 c1                	mov    %eax,%ecx
  802904:	89 d8                	mov    %ebx,%eax
  802906:	89 cf                	mov    %ecx,%edi
  802908:	f7 f5                	div    %ebp
  80290a:	89 c3                	mov    %eax,%ebx
  80290c:	89 d8                	mov    %ebx,%eax
  80290e:	89 fa                	mov    %edi,%edx
  802910:	83 c4 1c             	add    $0x1c,%esp
  802913:	5b                   	pop    %ebx
  802914:	5e                   	pop    %esi
  802915:	5f                   	pop    %edi
  802916:	5d                   	pop    %ebp
  802917:	c3                   	ret    
  802918:	90                   	nop
  802919:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802920:	39 ce                	cmp    %ecx,%esi
  802922:	77 74                	ja     802998 <__udivdi3+0xd8>
  802924:	0f bd fe             	bsr    %esi,%edi
  802927:	83 f7 1f             	xor    $0x1f,%edi
  80292a:	0f 84 98 00 00 00    	je     8029c8 <__udivdi3+0x108>
  802930:	bb 20 00 00 00       	mov    $0x20,%ebx
  802935:	89 f9                	mov    %edi,%ecx
  802937:	89 c5                	mov    %eax,%ebp
  802939:	29 fb                	sub    %edi,%ebx
  80293b:	d3 e6                	shl    %cl,%esi
  80293d:	89 d9                	mov    %ebx,%ecx
  80293f:	d3 ed                	shr    %cl,%ebp
  802941:	89 f9                	mov    %edi,%ecx
  802943:	d3 e0                	shl    %cl,%eax
  802945:	09 ee                	or     %ebp,%esi
  802947:	89 d9                	mov    %ebx,%ecx
  802949:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80294d:	89 d5                	mov    %edx,%ebp
  80294f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802953:	d3 ed                	shr    %cl,%ebp
  802955:	89 f9                	mov    %edi,%ecx
  802957:	d3 e2                	shl    %cl,%edx
  802959:	89 d9                	mov    %ebx,%ecx
  80295b:	d3 e8                	shr    %cl,%eax
  80295d:	09 c2                	or     %eax,%edx
  80295f:	89 d0                	mov    %edx,%eax
  802961:	89 ea                	mov    %ebp,%edx
  802963:	f7 f6                	div    %esi
  802965:	89 d5                	mov    %edx,%ebp
  802967:	89 c3                	mov    %eax,%ebx
  802969:	f7 64 24 0c          	mull   0xc(%esp)
  80296d:	39 d5                	cmp    %edx,%ebp
  80296f:	72 10                	jb     802981 <__udivdi3+0xc1>
  802971:	8b 74 24 08          	mov    0x8(%esp),%esi
  802975:	89 f9                	mov    %edi,%ecx
  802977:	d3 e6                	shl    %cl,%esi
  802979:	39 c6                	cmp    %eax,%esi
  80297b:	73 07                	jae    802984 <__udivdi3+0xc4>
  80297d:	39 d5                	cmp    %edx,%ebp
  80297f:	75 03                	jne    802984 <__udivdi3+0xc4>
  802981:	83 eb 01             	sub    $0x1,%ebx
  802984:	31 ff                	xor    %edi,%edi
  802986:	89 d8                	mov    %ebx,%eax
  802988:	89 fa                	mov    %edi,%edx
  80298a:	83 c4 1c             	add    $0x1c,%esp
  80298d:	5b                   	pop    %ebx
  80298e:	5e                   	pop    %esi
  80298f:	5f                   	pop    %edi
  802990:	5d                   	pop    %ebp
  802991:	c3                   	ret    
  802992:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802998:	31 ff                	xor    %edi,%edi
  80299a:	31 db                	xor    %ebx,%ebx
  80299c:	89 d8                	mov    %ebx,%eax
  80299e:	89 fa                	mov    %edi,%edx
  8029a0:	83 c4 1c             	add    $0x1c,%esp
  8029a3:	5b                   	pop    %ebx
  8029a4:	5e                   	pop    %esi
  8029a5:	5f                   	pop    %edi
  8029a6:	5d                   	pop    %ebp
  8029a7:	c3                   	ret    
  8029a8:	90                   	nop
  8029a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8029b0:	89 d8                	mov    %ebx,%eax
  8029b2:	f7 f7                	div    %edi
  8029b4:	31 ff                	xor    %edi,%edi
  8029b6:	89 c3                	mov    %eax,%ebx
  8029b8:	89 d8                	mov    %ebx,%eax
  8029ba:	89 fa                	mov    %edi,%edx
  8029bc:	83 c4 1c             	add    $0x1c,%esp
  8029bf:	5b                   	pop    %ebx
  8029c0:	5e                   	pop    %esi
  8029c1:	5f                   	pop    %edi
  8029c2:	5d                   	pop    %ebp
  8029c3:	c3                   	ret    
  8029c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8029c8:	39 ce                	cmp    %ecx,%esi
  8029ca:	72 0c                	jb     8029d8 <__udivdi3+0x118>
  8029cc:	31 db                	xor    %ebx,%ebx
  8029ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8029d2:	0f 87 34 ff ff ff    	ja     80290c <__udivdi3+0x4c>
  8029d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8029dd:	e9 2a ff ff ff       	jmp    80290c <__udivdi3+0x4c>
  8029e2:	66 90                	xchg   %ax,%ax
  8029e4:	66 90                	xchg   %ax,%ax
  8029e6:	66 90                	xchg   %ax,%ax
  8029e8:	66 90                	xchg   %ax,%ax
  8029ea:	66 90                	xchg   %ax,%ax
  8029ec:	66 90                	xchg   %ax,%ax
  8029ee:	66 90                	xchg   %ax,%ax

008029f0 <__umoddi3>:
  8029f0:	55                   	push   %ebp
  8029f1:	57                   	push   %edi
  8029f2:	56                   	push   %esi
  8029f3:	53                   	push   %ebx
  8029f4:	83 ec 1c             	sub    $0x1c,%esp
  8029f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8029fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8029ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802a03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802a07:	85 d2                	test   %edx,%edx
  802a09:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802a0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802a11:	89 f3                	mov    %esi,%ebx
  802a13:	89 3c 24             	mov    %edi,(%esp)
  802a16:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a1a:	75 1c                	jne    802a38 <__umoddi3+0x48>
  802a1c:	39 f7                	cmp    %esi,%edi
  802a1e:	76 50                	jbe    802a70 <__umoddi3+0x80>
  802a20:	89 c8                	mov    %ecx,%eax
  802a22:	89 f2                	mov    %esi,%edx
  802a24:	f7 f7                	div    %edi
  802a26:	89 d0                	mov    %edx,%eax
  802a28:	31 d2                	xor    %edx,%edx
  802a2a:	83 c4 1c             	add    $0x1c,%esp
  802a2d:	5b                   	pop    %ebx
  802a2e:	5e                   	pop    %esi
  802a2f:	5f                   	pop    %edi
  802a30:	5d                   	pop    %ebp
  802a31:	c3                   	ret    
  802a32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802a38:	39 f2                	cmp    %esi,%edx
  802a3a:	89 d0                	mov    %edx,%eax
  802a3c:	77 52                	ja     802a90 <__umoddi3+0xa0>
  802a3e:	0f bd ea             	bsr    %edx,%ebp
  802a41:	83 f5 1f             	xor    $0x1f,%ebp
  802a44:	75 5a                	jne    802aa0 <__umoddi3+0xb0>
  802a46:	3b 54 24 04          	cmp    0x4(%esp),%edx
  802a4a:	0f 82 e0 00 00 00    	jb     802b30 <__umoddi3+0x140>
  802a50:	39 0c 24             	cmp    %ecx,(%esp)
  802a53:	0f 86 d7 00 00 00    	jbe    802b30 <__umoddi3+0x140>
  802a59:	8b 44 24 08          	mov    0x8(%esp),%eax
  802a5d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802a61:	83 c4 1c             	add    $0x1c,%esp
  802a64:	5b                   	pop    %ebx
  802a65:	5e                   	pop    %esi
  802a66:	5f                   	pop    %edi
  802a67:	5d                   	pop    %ebp
  802a68:	c3                   	ret    
  802a69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802a70:	85 ff                	test   %edi,%edi
  802a72:	89 fd                	mov    %edi,%ebp
  802a74:	75 0b                	jne    802a81 <__umoddi3+0x91>
  802a76:	b8 01 00 00 00       	mov    $0x1,%eax
  802a7b:	31 d2                	xor    %edx,%edx
  802a7d:	f7 f7                	div    %edi
  802a7f:	89 c5                	mov    %eax,%ebp
  802a81:	89 f0                	mov    %esi,%eax
  802a83:	31 d2                	xor    %edx,%edx
  802a85:	f7 f5                	div    %ebp
  802a87:	89 c8                	mov    %ecx,%eax
  802a89:	f7 f5                	div    %ebp
  802a8b:	89 d0                	mov    %edx,%eax
  802a8d:	eb 99                	jmp    802a28 <__umoddi3+0x38>
  802a8f:	90                   	nop
  802a90:	89 c8                	mov    %ecx,%eax
  802a92:	89 f2                	mov    %esi,%edx
  802a94:	83 c4 1c             	add    $0x1c,%esp
  802a97:	5b                   	pop    %ebx
  802a98:	5e                   	pop    %esi
  802a99:	5f                   	pop    %edi
  802a9a:	5d                   	pop    %ebp
  802a9b:	c3                   	ret    
  802a9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802aa0:	8b 34 24             	mov    (%esp),%esi
  802aa3:	bf 20 00 00 00       	mov    $0x20,%edi
  802aa8:	89 e9                	mov    %ebp,%ecx
  802aaa:	29 ef                	sub    %ebp,%edi
  802aac:	d3 e0                	shl    %cl,%eax
  802aae:	89 f9                	mov    %edi,%ecx
  802ab0:	89 f2                	mov    %esi,%edx
  802ab2:	d3 ea                	shr    %cl,%edx
  802ab4:	89 e9                	mov    %ebp,%ecx
  802ab6:	09 c2                	or     %eax,%edx
  802ab8:	89 d8                	mov    %ebx,%eax
  802aba:	89 14 24             	mov    %edx,(%esp)
  802abd:	89 f2                	mov    %esi,%edx
  802abf:	d3 e2                	shl    %cl,%edx
  802ac1:	89 f9                	mov    %edi,%ecx
  802ac3:	89 54 24 04          	mov    %edx,0x4(%esp)
  802ac7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802acb:	d3 e8                	shr    %cl,%eax
  802acd:	89 e9                	mov    %ebp,%ecx
  802acf:	89 c6                	mov    %eax,%esi
  802ad1:	d3 e3                	shl    %cl,%ebx
  802ad3:	89 f9                	mov    %edi,%ecx
  802ad5:	89 d0                	mov    %edx,%eax
  802ad7:	d3 e8                	shr    %cl,%eax
  802ad9:	89 e9                	mov    %ebp,%ecx
  802adb:	09 d8                	or     %ebx,%eax
  802add:	89 d3                	mov    %edx,%ebx
  802adf:	89 f2                	mov    %esi,%edx
  802ae1:	f7 34 24             	divl   (%esp)
  802ae4:	89 d6                	mov    %edx,%esi
  802ae6:	d3 e3                	shl    %cl,%ebx
  802ae8:	f7 64 24 04          	mull   0x4(%esp)
  802aec:	39 d6                	cmp    %edx,%esi
  802aee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802af2:	89 d1                	mov    %edx,%ecx
  802af4:	89 c3                	mov    %eax,%ebx
  802af6:	72 08                	jb     802b00 <__umoddi3+0x110>
  802af8:	75 11                	jne    802b0b <__umoddi3+0x11b>
  802afa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802afe:	73 0b                	jae    802b0b <__umoddi3+0x11b>
  802b00:	2b 44 24 04          	sub    0x4(%esp),%eax
  802b04:	1b 14 24             	sbb    (%esp),%edx
  802b07:	89 d1                	mov    %edx,%ecx
  802b09:	89 c3                	mov    %eax,%ebx
  802b0b:	8b 54 24 08          	mov    0x8(%esp),%edx
  802b0f:	29 da                	sub    %ebx,%edx
  802b11:	19 ce                	sbb    %ecx,%esi
  802b13:	89 f9                	mov    %edi,%ecx
  802b15:	89 f0                	mov    %esi,%eax
  802b17:	d3 e0                	shl    %cl,%eax
  802b19:	89 e9                	mov    %ebp,%ecx
  802b1b:	d3 ea                	shr    %cl,%edx
  802b1d:	89 e9                	mov    %ebp,%ecx
  802b1f:	d3 ee                	shr    %cl,%esi
  802b21:	09 d0                	or     %edx,%eax
  802b23:	89 f2                	mov    %esi,%edx
  802b25:	83 c4 1c             	add    $0x1c,%esp
  802b28:	5b                   	pop    %ebx
  802b29:	5e                   	pop    %esi
  802b2a:	5f                   	pop    %edi
  802b2b:	5d                   	pop    %ebp
  802b2c:	c3                   	ret    
  802b2d:	8d 76 00             	lea    0x0(%esi),%esi
  802b30:	29 f9                	sub    %edi,%ecx
  802b32:	19 d6                	sbb    %edx,%esi
  802b34:	89 74 24 04          	mov    %esi,0x4(%esp)
  802b38:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802b3c:	e9 18 ff ff ff       	jmp    802a59 <__umoddi3+0x69>
