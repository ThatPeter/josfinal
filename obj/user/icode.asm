
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
  80003e:	c7 05 00 40 80 00 e0 	movl   $0x802ae0,0x804000
  800045:	2a 80 00 

	cprintf("icode startup\n");
  800048:	68 e6 2a 80 00       	push   $0x802ae6
  80004d:	e8 3e 02 00 00       	call   800290 <cprintf>

	cprintf("icode: open /motd\n");
  800052:	c7 04 24 f5 2a 80 00 	movl   $0x802af5,(%esp)
  800059:	e8 32 02 00 00       	call   800290 <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005e:	83 c4 08             	add    $0x8,%esp
  800061:	6a 00                	push   $0x0
  800063:	68 08 2b 80 00       	push   $0x802b08
  800068:	e8 6d 1a 00 00       	call   801ada <open>
  80006d:	89 c6                	mov    %eax,%esi
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	85 c0                	test   %eax,%eax
  800074:	79 12                	jns    800088 <umain+0x55>
		panic("icode: open /motd: %e", fd);
  800076:	50                   	push   %eax
  800077:	68 0e 2b 80 00       	push   $0x802b0e
  80007c:	6a 0f                	push   $0xf
  80007e:	68 24 2b 80 00       	push   $0x802b24
  800083:	e8 2f 01 00 00       	call   8001b7 <_panic>

	cprintf("icode: read /motd\n");
  800088:	83 ec 0c             	sub    $0xc,%esp
  80008b:	68 31 2b 80 00       	push   $0x802b31
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
  8000b7:	e8 8a 15 00 00       	call   801646 <read>
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	7f dd                	jg     8000a0 <umain+0x6d>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	68 44 2b 80 00       	push   $0x802b44
  8000cb:	e8 c0 01 00 00       	call   800290 <cprintf>
	close(fd);
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 32 14 00 00       	call   80150a <close>

	cprintf("icode: spawn /init\n");
  8000d8:	c7 04 24 58 2b 80 00 	movl   $0x802b58,(%esp)
  8000df:	e8 ac 01 00 00       	call   800290 <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000eb:	68 6c 2b 80 00       	push   $0x802b6c
  8000f0:	68 75 2b 80 00       	push   $0x802b75
  8000f5:	68 7f 2b 80 00       	push   $0x802b7f
  8000fa:	68 7e 2b 80 00       	push   $0x802b7e
  8000ff:	e8 ec 1f 00 00       	call   8020f0 <spawnl>
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	85 c0                	test   %eax,%eax
  800109:	79 12                	jns    80011d <umain+0xea>
		panic("icode: spawn /init: %e", r);
  80010b:	50                   	push   %eax
  80010c:	68 84 2b 80 00       	push   $0x802b84
  800111:	6a 1a                	push   $0x1a
  800113:	68 24 2b 80 00       	push   $0x802b24
  800118:	e8 9a 00 00 00       	call   8001b7 <_panic>

	cprintf("icode: exiting\n");
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	68 9b 2b 80 00       	push   $0x802b9b
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
  800149:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  80014f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800154:	a3 04 50 80 00       	mov    %eax,0x805004

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
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  80017d:	55                   	push   %ebp
  80017e:	89 e5                	mov    %esp,%ebp
  800180:	83 ec 08             	sub    $0x8,%esp
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
  8001a3:	e8 8d 13 00 00       	call   801535 <close_all>
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
  8001d5:	68 b8 2b 80 00       	push   $0x802bb8
  8001da:	e8 b1 00 00 00       	call   800290 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001df:	83 c4 18             	add    $0x18,%esp
  8001e2:	53                   	push   %ebx
  8001e3:	ff 75 10             	pushl  0x10(%ebp)
  8001e6:	e8 54 00 00 00       	call   80023f <vcprintf>
	cprintf("\n");
  8001eb:	c7 04 24 7b 2f 80 00 	movl   $0x802f7b,(%esp)
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
  8002f3:	e8 48 25 00 00       	call   802840 <__udivdi3>
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
  800336:	e8 35 26 00 00       	call   802970 <__umoddi3>
  80033b:	83 c4 14             	add    $0x14,%esp
  80033e:	0f be 80 db 2b 80 00 	movsbl 0x802bdb(%eax),%eax
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
  80043a:	ff 24 85 20 2d 80 00 	jmp    *0x802d20(,%eax,4)
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
  8004fe:	8b 14 85 80 2e 80 00 	mov    0x802e80(,%eax,4),%edx
  800505:	85 d2                	test   %edx,%edx
  800507:	75 18                	jne    800521 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800509:	50                   	push   %eax
  80050a:	68 f3 2b 80 00       	push   $0x802bf3
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
  800522:	68 3d 30 80 00       	push   $0x80303d
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
  800546:	b8 ec 2b 80 00       	mov    $0x802bec,%eax
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
  800bc1:	68 df 2e 80 00       	push   $0x802edf
  800bc6:	6a 23                	push   $0x23
  800bc8:	68 fc 2e 80 00       	push   $0x802efc
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
  800c42:	68 df 2e 80 00       	push   $0x802edf
  800c47:	6a 23                	push   $0x23
  800c49:	68 fc 2e 80 00       	push   $0x802efc
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
  800c84:	68 df 2e 80 00       	push   $0x802edf
  800c89:	6a 23                	push   $0x23
  800c8b:	68 fc 2e 80 00       	push   $0x802efc
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
  800cc6:	68 df 2e 80 00       	push   $0x802edf
  800ccb:	6a 23                	push   $0x23
  800ccd:	68 fc 2e 80 00       	push   $0x802efc
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
  800d08:	68 df 2e 80 00       	push   $0x802edf
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 fc 2e 80 00       	push   $0x802efc
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
  800d4a:	68 df 2e 80 00       	push   $0x802edf
  800d4f:	6a 23                	push   $0x23
  800d51:	68 fc 2e 80 00       	push   $0x802efc
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
  800d8c:	68 df 2e 80 00       	push   $0x802edf
  800d91:	6a 23                	push   $0x23
  800d93:	68 fc 2e 80 00       	push   $0x802efc
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
  800df0:	68 df 2e 80 00       	push   $0x802edf
  800df5:	6a 23                	push   $0x23
  800df7:	68 fc 2e 80 00       	push   $0x802efc
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
  800e8f:	68 0a 2f 80 00       	push   $0x802f0a
  800e94:	6a 1f                	push   $0x1f
  800e96:	68 1a 2f 80 00       	push   $0x802f1a
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
  800eb9:	68 25 2f 80 00       	push   $0x802f25
  800ebe:	6a 2d                	push   $0x2d
  800ec0:	68 1a 2f 80 00       	push   $0x802f1a
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
  800f01:	68 25 2f 80 00       	push   $0x802f25
  800f06:	6a 34                	push   $0x34
  800f08:	68 1a 2f 80 00       	push   $0x802f1a
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
  800f29:	68 25 2f 80 00       	push   $0x802f25
  800f2e:	6a 38                	push   $0x38
  800f30:	68 1a 2f 80 00       	push   $0x802f1a
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
  800f4d:	e8 f9 16 00 00       	call   80264b <set_pgfault_handler>
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
  800f66:	68 3e 2f 80 00       	push   $0x802f3e
  800f6b:	68 85 00 00 00       	push   $0x85
  800f70:	68 1a 2f 80 00       	push   $0x802f1a
  800f75:	e8 3d f2 ff ff       	call   8001b7 <_panic>
  800f7a:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f7c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f80:	75 24                	jne    800fa6 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f82:	e8 53 fc ff ff       	call   800bda <sys_getenvid>
  800f87:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f8c:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
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
  801022:	68 4c 2f 80 00       	push   $0x802f4c
  801027:	6a 55                	push   $0x55
  801029:	68 1a 2f 80 00       	push   $0x802f1a
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
  801067:	68 4c 2f 80 00       	push   $0x802f4c
  80106c:	6a 5c                	push   $0x5c
  80106e:	68 1a 2f 80 00       	push   $0x802f1a
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
  801095:	68 4c 2f 80 00       	push   $0x802f4c
  80109a:	6a 60                	push   $0x60
  80109c:	68 1a 2f 80 00       	push   $0x802f1a
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
  8010bf:	68 4c 2f 80 00       	push   $0x802f4c
  8010c4:	6a 65                	push   $0x65
  8010c6:	68 1a 2f 80 00       	push   $0x802f1a
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
  8010e7:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
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

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  801122:	8b 45 08             	mov    0x8(%ebp),%eax
  801125:	a3 08 50 80 00       	mov    %eax,0x805008
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80112a:	68 7d 01 80 00       	push   $0x80017d
  80112f:	e8 d5 fc ff ff       	call   800e09 <sys_thread_create>

	return id;
}
  801134:	c9                   	leave  
  801135:	c3                   	ret    

00801136 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  80113c:	ff 75 08             	pushl  0x8(%ebp)
  80113f:	e8 e5 fc ff ff       	call   800e29 <sys_thread_free>
}
  801144:	83 c4 10             	add    $0x10,%esp
  801147:	c9                   	leave  
  801148:	c3                   	ret    

00801149 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  801149:	55                   	push   %ebp
  80114a:	89 e5                	mov    %esp,%ebp
  80114c:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  80114f:	ff 75 08             	pushl  0x8(%ebp)
  801152:	e8 f2 fc ff ff       	call   800e49 <sys_thread_join>
}
  801157:	83 c4 10             	add    $0x10,%esp
  80115a:	c9                   	leave  
  80115b:	c3                   	ret    

0080115c <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
  80115f:	56                   	push   %esi
  801160:	53                   	push   %ebx
  801161:	8b 75 08             	mov    0x8(%ebp),%esi
  801164:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  801167:	83 ec 04             	sub    $0x4,%esp
  80116a:	6a 07                	push   $0x7
  80116c:	6a 00                	push   $0x0
  80116e:	56                   	push   %esi
  80116f:	e8 a4 fa ff ff       	call   800c18 <sys_page_alloc>
	if (r < 0) {
  801174:	83 c4 10             	add    $0x10,%esp
  801177:	85 c0                	test   %eax,%eax
  801179:	79 15                	jns    801190 <queue_append+0x34>
		panic("%e\n", r);
  80117b:	50                   	push   %eax
  80117c:	68 92 2f 80 00       	push   $0x802f92
  801181:	68 d5 00 00 00       	push   $0xd5
  801186:	68 1a 2f 80 00       	push   $0x802f1a
  80118b:	e8 27 f0 ff ff       	call   8001b7 <_panic>
	}	

	wt->envid = envid;
  801190:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  801196:	83 3b 00             	cmpl   $0x0,(%ebx)
  801199:	75 13                	jne    8011ae <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  80119b:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  8011a2:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8011a9:	00 00 00 
  8011ac:	eb 1b                	jmp    8011c9 <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  8011ae:	8b 43 04             	mov    0x4(%ebx),%eax
  8011b1:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  8011b8:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8011bf:	00 00 00 
		queue->last = wt;
  8011c2:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8011c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011cc:	5b                   	pop    %ebx
  8011cd:	5e                   	pop    %esi
  8011ce:	5d                   	pop    %ebp
  8011cf:	c3                   	ret    

008011d0 <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
  8011d3:	83 ec 08             	sub    $0x8,%esp
  8011d6:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  8011d9:	8b 02                	mov    (%edx),%eax
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	75 17                	jne    8011f6 <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  8011df:	83 ec 04             	sub    $0x4,%esp
  8011e2:	68 62 2f 80 00       	push   $0x802f62
  8011e7:	68 ec 00 00 00       	push   $0xec
  8011ec:	68 1a 2f 80 00       	push   $0x802f1a
  8011f1:	e8 c1 ef ff ff       	call   8001b7 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  8011f6:	8b 48 04             	mov    0x4(%eax),%ecx
  8011f9:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  8011fb:	8b 00                	mov    (%eax),%eax
}
  8011fd:	c9                   	leave  
  8011fe:	c3                   	ret    

008011ff <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  8011ff:	55                   	push   %ebp
  801200:	89 e5                	mov    %esp,%ebp
  801202:	56                   	push   %esi
  801203:	53                   	push   %ebx
  801204:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801207:	b8 01 00 00 00       	mov    $0x1,%eax
  80120c:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  80120f:	85 c0                	test   %eax,%eax
  801211:	74 4a                	je     80125d <mutex_lock+0x5e>
  801213:	8b 73 04             	mov    0x4(%ebx),%esi
  801216:	83 3e 00             	cmpl   $0x0,(%esi)
  801219:	75 42                	jne    80125d <mutex_lock+0x5e>
		queue_append(sys_getenvid(), mtx->queue);		
  80121b:	e8 ba f9 ff ff       	call   800bda <sys_getenvid>
  801220:	83 ec 08             	sub    $0x8,%esp
  801223:	56                   	push   %esi
  801224:	50                   	push   %eax
  801225:	e8 32 ff ff ff       	call   80115c <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  80122a:	e8 ab f9 ff ff       	call   800bda <sys_getenvid>
  80122f:	83 c4 08             	add    $0x8,%esp
  801232:	6a 04                	push   $0x4
  801234:	50                   	push   %eax
  801235:	e8 a5 fa ff ff       	call   800cdf <sys_env_set_status>

		if (r < 0) {
  80123a:	83 c4 10             	add    $0x10,%esp
  80123d:	85 c0                	test   %eax,%eax
  80123f:	79 15                	jns    801256 <mutex_lock+0x57>
			panic("%e\n", r);
  801241:	50                   	push   %eax
  801242:	68 92 2f 80 00       	push   $0x802f92
  801247:	68 02 01 00 00       	push   $0x102
  80124c:	68 1a 2f 80 00       	push   $0x802f1a
  801251:	e8 61 ef ff ff       	call   8001b7 <_panic>
		}
		sys_yield();
  801256:	e8 9e f9 ff ff       	call   800bf9 <sys_yield>
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  80125b:	eb 08                	jmp    801265 <mutex_lock+0x66>
		if (r < 0) {
			panic("%e\n", r);
		}
		sys_yield();
	} else {
		mtx->owner = sys_getenvid();
  80125d:	e8 78 f9 ff ff       	call   800bda <sys_getenvid>
  801262:	89 43 08             	mov    %eax,0x8(%ebx)
	}
}
  801265:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801268:	5b                   	pop    %ebx
  801269:	5e                   	pop    %esi
  80126a:	5d                   	pop    %ebp
  80126b:	c3                   	ret    

0080126c <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	53                   	push   %ebx
  801270:	83 ec 04             	sub    $0x4,%esp
  801273:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801276:	b8 00 00 00 00       	mov    $0x0,%eax
  80127b:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  80127e:	8b 43 04             	mov    0x4(%ebx),%eax
  801281:	83 38 00             	cmpl   $0x0,(%eax)
  801284:	74 33                	je     8012b9 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  801286:	83 ec 0c             	sub    $0xc,%esp
  801289:	50                   	push   %eax
  80128a:	e8 41 ff ff ff       	call   8011d0 <queue_pop>
  80128f:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  801292:	83 c4 08             	add    $0x8,%esp
  801295:	6a 02                	push   $0x2
  801297:	50                   	push   %eax
  801298:	e8 42 fa ff ff       	call   800cdf <sys_env_set_status>
		if (r < 0) {
  80129d:	83 c4 10             	add    $0x10,%esp
  8012a0:	85 c0                	test   %eax,%eax
  8012a2:	79 15                	jns    8012b9 <mutex_unlock+0x4d>
			panic("%e\n", r);
  8012a4:	50                   	push   %eax
  8012a5:	68 92 2f 80 00       	push   $0x802f92
  8012aa:	68 16 01 00 00       	push   $0x116
  8012af:	68 1a 2f 80 00       	push   $0x802f1a
  8012b4:	e8 fe ee ff ff       	call   8001b7 <_panic>
		}
	}

	//asm volatile("pause"); 	// might be useless here
}
  8012b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012bc:	c9                   	leave  
  8012bd:	c3                   	ret    

008012be <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  8012be:	55                   	push   %ebp
  8012bf:	89 e5                	mov    %esp,%ebp
  8012c1:	53                   	push   %ebx
  8012c2:	83 ec 04             	sub    $0x4,%esp
  8012c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8012c8:	e8 0d f9 ff ff       	call   800bda <sys_getenvid>
  8012cd:	83 ec 04             	sub    $0x4,%esp
  8012d0:	6a 07                	push   $0x7
  8012d2:	53                   	push   %ebx
  8012d3:	50                   	push   %eax
  8012d4:	e8 3f f9 ff ff       	call   800c18 <sys_page_alloc>
  8012d9:	83 c4 10             	add    $0x10,%esp
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	79 15                	jns    8012f5 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  8012e0:	50                   	push   %eax
  8012e1:	68 7d 2f 80 00       	push   $0x802f7d
  8012e6:	68 22 01 00 00       	push   $0x122
  8012eb:	68 1a 2f 80 00       	push   $0x802f1a
  8012f0:	e8 c2 ee ff ff       	call   8001b7 <_panic>
	}	
	mtx->locked = 0;
  8012f5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  8012fb:	8b 43 04             	mov    0x4(%ebx),%eax
  8012fe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  801304:	8b 43 04             	mov    0x4(%ebx),%eax
  801307:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  80130e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  801315:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801318:	c9                   	leave  
  801319:	c3                   	ret    

0080131a <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  80131a:	55                   	push   %ebp
  80131b:	89 e5                	mov    %esp,%ebp
  80131d:	53                   	push   %ebx
  80131e:	83 ec 04             	sub    $0x4,%esp
  801321:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue->first != NULL) {
  801324:	eb 21                	jmp    801347 <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
  801326:	83 ec 0c             	sub    $0xc,%esp
  801329:	50                   	push   %eax
  80132a:	e8 a1 fe ff ff       	call   8011d0 <queue_pop>
  80132f:	83 c4 08             	add    $0x8,%esp
  801332:	6a 02                	push   $0x2
  801334:	50                   	push   %eax
  801335:	e8 a5 f9 ff ff       	call   800cdf <sys_env_set_status>
		mtx->queue->first = mtx->queue->first->next;
  80133a:	8b 43 04             	mov    0x4(%ebx),%eax
  80133d:	8b 10                	mov    (%eax),%edx
  80133f:	8b 52 04             	mov    0x4(%edx),%edx
  801342:	89 10                	mov    %edx,(%eax)
  801344:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue->first != NULL) {
  801347:	8b 43 04             	mov    0x4(%ebx),%eax
  80134a:	83 38 00             	cmpl   $0x0,(%eax)
  80134d:	75 d7                	jne    801326 <mutex_destroy+0xc>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
		mtx->queue->first = mtx->queue->first->next;
	}

	memset(mtx, 0, PGSIZE);
  80134f:	83 ec 04             	sub    $0x4,%esp
  801352:	68 00 10 00 00       	push   $0x1000
  801357:	6a 00                	push   $0x0
  801359:	53                   	push   %ebx
  80135a:	e8 fb f5 ff ff       	call   80095a <memset>
	mtx = NULL;
}
  80135f:	83 c4 10             	add    $0x10,%esp
  801362:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801365:	c9                   	leave  
  801366:	c3                   	ret    

00801367 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801367:	55                   	push   %ebp
  801368:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80136a:	8b 45 08             	mov    0x8(%ebp),%eax
  80136d:	05 00 00 00 30       	add    $0x30000000,%eax
  801372:	c1 e8 0c             	shr    $0xc,%eax
}
  801375:	5d                   	pop    %ebp
  801376:	c3                   	ret    

00801377 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80137a:	8b 45 08             	mov    0x8(%ebp),%eax
  80137d:	05 00 00 00 30       	add    $0x30000000,%eax
  801382:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801387:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80138c:	5d                   	pop    %ebp
  80138d:	c3                   	ret    

0080138e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80138e:	55                   	push   %ebp
  80138f:	89 e5                	mov    %esp,%ebp
  801391:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801394:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801399:	89 c2                	mov    %eax,%edx
  80139b:	c1 ea 16             	shr    $0x16,%edx
  80139e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013a5:	f6 c2 01             	test   $0x1,%dl
  8013a8:	74 11                	je     8013bb <fd_alloc+0x2d>
  8013aa:	89 c2                	mov    %eax,%edx
  8013ac:	c1 ea 0c             	shr    $0xc,%edx
  8013af:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013b6:	f6 c2 01             	test   $0x1,%dl
  8013b9:	75 09                	jne    8013c4 <fd_alloc+0x36>
			*fd_store = fd;
  8013bb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c2:	eb 17                	jmp    8013db <fd_alloc+0x4d>
  8013c4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013c9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013ce:	75 c9                	jne    801399 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013d0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8013d6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013db:	5d                   	pop    %ebp
  8013dc:	c3                   	ret    

008013dd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013dd:	55                   	push   %ebp
  8013de:	89 e5                	mov    %esp,%ebp
  8013e0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013e3:	83 f8 1f             	cmp    $0x1f,%eax
  8013e6:	77 36                	ja     80141e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013e8:	c1 e0 0c             	shl    $0xc,%eax
  8013eb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013f0:	89 c2                	mov    %eax,%edx
  8013f2:	c1 ea 16             	shr    $0x16,%edx
  8013f5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013fc:	f6 c2 01             	test   $0x1,%dl
  8013ff:	74 24                	je     801425 <fd_lookup+0x48>
  801401:	89 c2                	mov    %eax,%edx
  801403:	c1 ea 0c             	shr    $0xc,%edx
  801406:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80140d:	f6 c2 01             	test   $0x1,%dl
  801410:	74 1a                	je     80142c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801412:	8b 55 0c             	mov    0xc(%ebp),%edx
  801415:	89 02                	mov    %eax,(%edx)
	return 0;
  801417:	b8 00 00 00 00       	mov    $0x0,%eax
  80141c:	eb 13                	jmp    801431 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80141e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801423:	eb 0c                	jmp    801431 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801425:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80142a:	eb 05                	jmp    801431 <fd_lookup+0x54>
  80142c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801431:	5d                   	pop    %ebp
  801432:	c3                   	ret    

00801433 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801433:	55                   	push   %ebp
  801434:	89 e5                	mov    %esp,%ebp
  801436:	83 ec 08             	sub    $0x8,%esp
  801439:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80143c:	ba 14 30 80 00       	mov    $0x803014,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801441:	eb 13                	jmp    801456 <dev_lookup+0x23>
  801443:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801446:	39 08                	cmp    %ecx,(%eax)
  801448:	75 0c                	jne    801456 <dev_lookup+0x23>
			*dev = devtab[i];
  80144a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80144d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80144f:	b8 00 00 00 00       	mov    $0x0,%eax
  801454:	eb 31                	jmp    801487 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801456:	8b 02                	mov    (%edx),%eax
  801458:	85 c0                	test   %eax,%eax
  80145a:	75 e7                	jne    801443 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80145c:	a1 04 50 80 00       	mov    0x805004,%eax
  801461:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801467:	83 ec 04             	sub    $0x4,%esp
  80146a:	51                   	push   %ecx
  80146b:	50                   	push   %eax
  80146c:	68 98 2f 80 00       	push   $0x802f98
  801471:	e8 1a ee ff ff       	call   800290 <cprintf>
	*dev = 0;
  801476:	8b 45 0c             	mov    0xc(%ebp),%eax
  801479:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80147f:	83 c4 10             	add    $0x10,%esp
  801482:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801487:	c9                   	leave  
  801488:	c3                   	ret    

00801489 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801489:	55                   	push   %ebp
  80148a:	89 e5                	mov    %esp,%ebp
  80148c:	56                   	push   %esi
  80148d:	53                   	push   %ebx
  80148e:	83 ec 10             	sub    $0x10,%esp
  801491:	8b 75 08             	mov    0x8(%ebp),%esi
  801494:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801497:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149a:	50                   	push   %eax
  80149b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014a1:	c1 e8 0c             	shr    $0xc,%eax
  8014a4:	50                   	push   %eax
  8014a5:	e8 33 ff ff ff       	call   8013dd <fd_lookup>
  8014aa:	83 c4 08             	add    $0x8,%esp
  8014ad:	85 c0                	test   %eax,%eax
  8014af:	78 05                	js     8014b6 <fd_close+0x2d>
	    || fd != fd2)
  8014b1:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014b4:	74 0c                	je     8014c2 <fd_close+0x39>
		return (must_exist ? r : 0);
  8014b6:	84 db                	test   %bl,%bl
  8014b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014bd:	0f 44 c2             	cmove  %edx,%eax
  8014c0:	eb 41                	jmp    801503 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014c2:	83 ec 08             	sub    $0x8,%esp
  8014c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c8:	50                   	push   %eax
  8014c9:	ff 36                	pushl  (%esi)
  8014cb:	e8 63 ff ff ff       	call   801433 <dev_lookup>
  8014d0:	89 c3                	mov    %eax,%ebx
  8014d2:	83 c4 10             	add    $0x10,%esp
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	78 1a                	js     8014f3 <fd_close+0x6a>
		if (dev->dev_close)
  8014d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014dc:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8014df:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8014e4:	85 c0                	test   %eax,%eax
  8014e6:	74 0b                	je     8014f3 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014e8:	83 ec 0c             	sub    $0xc,%esp
  8014eb:	56                   	push   %esi
  8014ec:	ff d0                	call   *%eax
  8014ee:	89 c3                	mov    %eax,%ebx
  8014f0:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014f3:	83 ec 08             	sub    $0x8,%esp
  8014f6:	56                   	push   %esi
  8014f7:	6a 00                	push   $0x0
  8014f9:	e8 9f f7 ff ff       	call   800c9d <sys_page_unmap>
	return r;
  8014fe:	83 c4 10             	add    $0x10,%esp
  801501:	89 d8                	mov    %ebx,%eax
}
  801503:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801506:	5b                   	pop    %ebx
  801507:	5e                   	pop    %esi
  801508:	5d                   	pop    %ebp
  801509:	c3                   	ret    

0080150a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80150a:	55                   	push   %ebp
  80150b:	89 e5                	mov    %esp,%ebp
  80150d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801510:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801513:	50                   	push   %eax
  801514:	ff 75 08             	pushl  0x8(%ebp)
  801517:	e8 c1 fe ff ff       	call   8013dd <fd_lookup>
  80151c:	83 c4 08             	add    $0x8,%esp
  80151f:	85 c0                	test   %eax,%eax
  801521:	78 10                	js     801533 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801523:	83 ec 08             	sub    $0x8,%esp
  801526:	6a 01                	push   $0x1
  801528:	ff 75 f4             	pushl  -0xc(%ebp)
  80152b:	e8 59 ff ff ff       	call   801489 <fd_close>
  801530:	83 c4 10             	add    $0x10,%esp
}
  801533:	c9                   	leave  
  801534:	c3                   	ret    

00801535 <close_all>:

void
close_all(void)
{
  801535:	55                   	push   %ebp
  801536:	89 e5                	mov    %esp,%ebp
  801538:	53                   	push   %ebx
  801539:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80153c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801541:	83 ec 0c             	sub    $0xc,%esp
  801544:	53                   	push   %ebx
  801545:	e8 c0 ff ff ff       	call   80150a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80154a:	83 c3 01             	add    $0x1,%ebx
  80154d:	83 c4 10             	add    $0x10,%esp
  801550:	83 fb 20             	cmp    $0x20,%ebx
  801553:	75 ec                	jne    801541 <close_all+0xc>
		close(i);
}
  801555:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801558:	c9                   	leave  
  801559:	c3                   	ret    

0080155a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80155a:	55                   	push   %ebp
  80155b:	89 e5                	mov    %esp,%ebp
  80155d:	57                   	push   %edi
  80155e:	56                   	push   %esi
  80155f:	53                   	push   %ebx
  801560:	83 ec 2c             	sub    $0x2c,%esp
  801563:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801566:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801569:	50                   	push   %eax
  80156a:	ff 75 08             	pushl  0x8(%ebp)
  80156d:	e8 6b fe ff ff       	call   8013dd <fd_lookup>
  801572:	83 c4 08             	add    $0x8,%esp
  801575:	85 c0                	test   %eax,%eax
  801577:	0f 88 c1 00 00 00    	js     80163e <dup+0xe4>
		return r;
	close(newfdnum);
  80157d:	83 ec 0c             	sub    $0xc,%esp
  801580:	56                   	push   %esi
  801581:	e8 84 ff ff ff       	call   80150a <close>

	newfd = INDEX2FD(newfdnum);
  801586:	89 f3                	mov    %esi,%ebx
  801588:	c1 e3 0c             	shl    $0xc,%ebx
  80158b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801591:	83 c4 04             	add    $0x4,%esp
  801594:	ff 75 e4             	pushl  -0x1c(%ebp)
  801597:	e8 db fd ff ff       	call   801377 <fd2data>
  80159c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80159e:	89 1c 24             	mov    %ebx,(%esp)
  8015a1:	e8 d1 fd ff ff       	call   801377 <fd2data>
  8015a6:	83 c4 10             	add    $0x10,%esp
  8015a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015ac:	89 f8                	mov    %edi,%eax
  8015ae:	c1 e8 16             	shr    $0x16,%eax
  8015b1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015b8:	a8 01                	test   $0x1,%al
  8015ba:	74 37                	je     8015f3 <dup+0x99>
  8015bc:	89 f8                	mov    %edi,%eax
  8015be:	c1 e8 0c             	shr    $0xc,%eax
  8015c1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015c8:	f6 c2 01             	test   $0x1,%dl
  8015cb:	74 26                	je     8015f3 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015cd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015d4:	83 ec 0c             	sub    $0xc,%esp
  8015d7:	25 07 0e 00 00       	and    $0xe07,%eax
  8015dc:	50                   	push   %eax
  8015dd:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015e0:	6a 00                	push   $0x0
  8015e2:	57                   	push   %edi
  8015e3:	6a 00                	push   $0x0
  8015e5:	e8 71 f6 ff ff       	call   800c5b <sys_page_map>
  8015ea:	89 c7                	mov    %eax,%edi
  8015ec:	83 c4 20             	add    $0x20,%esp
  8015ef:	85 c0                	test   %eax,%eax
  8015f1:	78 2e                	js     801621 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015f3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015f6:	89 d0                	mov    %edx,%eax
  8015f8:	c1 e8 0c             	shr    $0xc,%eax
  8015fb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801602:	83 ec 0c             	sub    $0xc,%esp
  801605:	25 07 0e 00 00       	and    $0xe07,%eax
  80160a:	50                   	push   %eax
  80160b:	53                   	push   %ebx
  80160c:	6a 00                	push   $0x0
  80160e:	52                   	push   %edx
  80160f:	6a 00                	push   $0x0
  801611:	e8 45 f6 ff ff       	call   800c5b <sys_page_map>
  801616:	89 c7                	mov    %eax,%edi
  801618:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80161b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80161d:	85 ff                	test   %edi,%edi
  80161f:	79 1d                	jns    80163e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801621:	83 ec 08             	sub    $0x8,%esp
  801624:	53                   	push   %ebx
  801625:	6a 00                	push   $0x0
  801627:	e8 71 f6 ff ff       	call   800c9d <sys_page_unmap>
	sys_page_unmap(0, nva);
  80162c:	83 c4 08             	add    $0x8,%esp
  80162f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801632:	6a 00                	push   $0x0
  801634:	e8 64 f6 ff ff       	call   800c9d <sys_page_unmap>
	return r;
  801639:	83 c4 10             	add    $0x10,%esp
  80163c:	89 f8                	mov    %edi,%eax
}
  80163e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801641:	5b                   	pop    %ebx
  801642:	5e                   	pop    %esi
  801643:	5f                   	pop    %edi
  801644:	5d                   	pop    %ebp
  801645:	c3                   	ret    

00801646 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	53                   	push   %ebx
  80164a:	83 ec 14             	sub    $0x14,%esp
  80164d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801650:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801653:	50                   	push   %eax
  801654:	53                   	push   %ebx
  801655:	e8 83 fd ff ff       	call   8013dd <fd_lookup>
  80165a:	83 c4 08             	add    $0x8,%esp
  80165d:	89 c2                	mov    %eax,%edx
  80165f:	85 c0                	test   %eax,%eax
  801661:	78 70                	js     8016d3 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801663:	83 ec 08             	sub    $0x8,%esp
  801666:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801669:	50                   	push   %eax
  80166a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166d:	ff 30                	pushl  (%eax)
  80166f:	e8 bf fd ff ff       	call   801433 <dev_lookup>
  801674:	83 c4 10             	add    $0x10,%esp
  801677:	85 c0                	test   %eax,%eax
  801679:	78 4f                	js     8016ca <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80167b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80167e:	8b 42 08             	mov    0x8(%edx),%eax
  801681:	83 e0 03             	and    $0x3,%eax
  801684:	83 f8 01             	cmp    $0x1,%eax
  801687:	75 24                	jne    8016ad <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801689:	a1 04 50 80 00       	mov    0x805004,%eax
  80168e:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801694:	83 ec 04             	sub    $0x4,%esp
  801697:	53                   	push   %ebx
  801698:	50                   	push   %eax
  801699:	68 d9 2f 80 00       	push   $0x802fd9
  80169e:	e8 ed eb ff ff       	call   800290 <cprintf>
		return -E_INVAL;
  8016a3:	83 c4 10             	add    $0x10,%esp
  8016a6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016ab:	eb 26                	jmp    8016d3 <read+0x8d>
	}
	if (!dev->dev_read)
  8016ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b0:	8b 40 08             	mov    0x8(%eax),%eax
  8016b3:	85 c0                	test   %eax,%eax
  8016b5:	74 17                	je     8016ce <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8016b7:	83 ec 04             	sub    $0x4,%esp
  8016ba:	ff 75 10             	pushl  0x10(%ebp)
  8016bd:	ff 75 0c             	pushl  0xc(%ebp)
  8016c0:	52                   	push   %edx
  8016c1:	ff d0                	call   *%eax
  8016c3:	89 c2                	mov    %eax,%edx
  8016c5:	83 c4 10             	add    $0x10,%esp
  8016c8:	eb 09                	jmp    8016d3 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ca:	89 c2                	mov    %eax,%edx
  8016cc:	eb 05                	jmp    8016d3 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016ce:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8016d3:	89 d0                	mov    %edx,%eax
  8016d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d8:	c9                   	leave  
  8016d9:	c3                   	ret    

008016da <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016da:	55                   	push   %ebp
  8016db:	89 e5                	mov    %esp,%ebp
  8016dd:	57                   	push   %edi
  8016de:	56                   	push   %esi
  8016df:	53                   	push   %ebx
  8016e0:	83 ec 0c             	sub    $0xc,%esp
  8016e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016e6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016ee:	eb 21                	jmp    801711 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016f0:	83 ec 04             	sub    $0x4,%esp
  8016f3:	89 f0                	mov    %esi,%eax
  8016f5:	29 d8                	sub    %ebx,%eax
  8016f7:	50                   	push   %eax
  8016f8:	89 d8                	mov    %ebx,%eax
  8016fa:	03 45 0c             	add    0xc(%ebp),%eax
  8016fd:	50                   	push   %eax
  8016fe:	57                   	push   %edi
  8016ff:	e8 42 ff ff ff       	call   801646 <read>
		if (m < 0)
  801704:	83 c4 10             	add    $0x10,%esp
  801707:	85 c0                	test   %eax,%eax
  801709:	78 10                	js     80171b <readn+0x41>
			return m;
		if (m == 0)
  80170b:	85 c0                	test   %eax,%eax
  80170d:	74 0a                	je     801719 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80170f:	01 c3                	add    %eax,%ebx
  801711:	39 f3                	cmp    %esi,%ebx
  801713:	72 db                	jb     8016f0 <readn+0x16>
  801715:	89 d8                	mov    %ebx,%eax
  801717:	eb 02                	jmp    80171b <readn+0x41>
  801719:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80171b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80171e:	5b                   	pop    %ebx
  80171f:	5e                   	pop    %esi
  801720:	5f                   	pop    %edi
  801721:	5d                   	pop    %ebp
  801722:	c3                   	ret    

00801723 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801723:	55                   	push   %ebp
  801724:	89 e5                	mov    %esp,%ebp
  801726:	53                   	push   %ebx
  801727:	83 ec 14             	sub    $0x14,%esp
  80172a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80172d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801730:	50                   	push   %eax
  801731:	53                   	push   %ebx
  801732:	e8 a6 fc ff ff       	call   8013dd <fd_lookup>
  801737:	83 c4 08             	add    $0x8,%esp
  80173a:	89 c2                	mov    %eax,%edx
  80173c:	85 c0                	test   %eax,%eax
  80173e:	78 6b                	js     8017ab <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801740:	83 ec 08             	sub    $0x8,%esp
  801743:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801746:	50                   	push   %eax
  801747:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80174a:	ff 30                	pushl  (%eax)
  80174c:	e8 e2 fc ff ff       	call   801433 <dev_lookup>
  801751:	83 c4 10             	add    $0x10,%esp
  801754:	85 c0                	test   %eax,%eax
  801756:	78 4a                	js     8017a2 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801758:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80175b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80175f:	75 24                	jne    801785 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801761:	a1 04 50 80 00       	mov    0x805004,%eax
  801766:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80176c:	83 ec 04             	sub    $0x4,%esp
  80176f:	53                   	push   %ebx
  801770:	50                   	push   %eax
  801771:	68 f5 2f 80 00       	push   $0x802ff5
  801776:	e8 15 eb ff ff       	call   800290 <cprintf>
		return -E_INVAL;
  80177b:	83 c4 10             	add    $0x10,%esp
  80177e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801783:	eb 26                	jmp    8017ab <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801785:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801788:	8b 52 0c             	mov    0xc(%edx),%edx
  80178b:	85 d2                	test   %edx,%edx
  80178d:	74 17                	je     8017a6 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80178f:	83 ec 04             	sub    $0x4,%esp
  801792:	ff 75 10             	pushl  0x10(%ebp)
  801795:	ff 75 0c             	pushl  0xc(%ebp)
  801798:	50                   	push   %eax
  801799:	ff d2                	call   *%edx
  80179b:	89 c2                	mov    %eax,%edx
  80179d:	83 c4 10             	add    $0x10,%esp
  8017a0:	eb 09                	jmp    8017ab <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a2:	89 c2                	mov    %eax,%edx
  8017a4:	eb 05                	jmp    8017ab <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017a6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8017ab:	89 d0                	mov    %edx,%eax
  8017ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b0:	c9                   	leave  
  8017b1:	c3                   	ret    

008017b2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017b2:	55                   	push   %ebp
  8017b3:	89 e5                	mov    %esp,%ebp
  8017b5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017b8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017bb:	50                   	push   %eax
  8017bc:	ff 75 08             	pushl  0x8(%ebp)
  8017bf:	e8 19 fc ff ff       	call   8013dd <fd_lookup>
  8017c4:	83 c4 08             	add    $0x8,%esp
  8017c7:	85 c0                	test   %eax,%eax
  8017c9:	78 0e                	js     8017d9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017d1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d9:	c9                   	leave  
  8017da:	c3                   	ret    

008017db <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017db:	55                   	push   %ebp
  8017dc:	89 e5                	mov    %esp,%ebp
  8017de:	53                   	push   %ebx
  8017df:	83 ec 14             	sub    $0x14,%esp
  8017e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e8:	50                   	push   %eax
  8017e9:	53                   	push   %ebx
  8017ea:	e8 ee fb ff ff       	call   8013dd <fd_lookup>
  8017ef:	83 c4 08             	add    $0x8,%esp
  8017f2:	89 c2                	mov    %eax,%edx
  8017f4:	85 c0                	test   %eax,%eax
  8017f6:	78 68                	js     801860 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f8:	83 ec 08             	sub    $0x8,%esp
  8017fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017fe:	50                   	push   %eax
  8017ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801802:	ff 30                	pushl  (%eax)
  801804:	e8 2a fc ff ff       	call   801433 <dev_lookup>
  801809:	83 c4 10             	add    $0x10,%esp
  80180c:	85 c0                	test   %eax,%eax
  80180e:	78 47                	js     801857 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801810:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801813:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801817:	75 24                	jne    80183d <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801819:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80181e:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801824:	83 ec 04             	sub    $0x4,%esp
  801827:	53                   	push   %ebx
  801828:	50                   	push   %eax
  801829:	68 b8 2f 80 00       	push   $0x802fb8
  80182e:	e8 5d ea ff ff       	call   800290 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801833:	83 c4 10             	add    $0x10,%esp
  801836:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80183b:	eb 23                	jmp    801860 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  80183d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801840:	8b 52 18             	mov    0x18(%edx),%edx
  801843:	85 d2                	test   %edx,%edx
  801845:	74 14                	je     80185b <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801847:	83 ec 08             	sub    $0x8,%esp
  80184a:	ff 75 0c             	pushl  0xc(%ebp)
  80184d:	50                   	push   %eax
  80184e:	ff d2                	call   *%edx
  801850:	89 c2                	mov    %eax,%edx
  801852:	83 c4 10             	add    $0x10,%esp
  801855:	eb 09                	jmp    801860 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801857:	89 c2                	mov    %eax,%edx
  801859:	eb 05                	jmp    801860 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80185b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801860:	89 d0                	mov    %edx,%eax
  801862:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801865:	c9                   	leave  
  801866:	c3                   	ret    

00801867 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	53                   	push   %ebx
  80186b:	83 ec 14             	sub    $0x14,%esp
  80186e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801871:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801874:	50                   	push   %eax
  801875:	ff 75 08             	pushl  0x8(%ebp)
  801878:	e8 60 fb ff ff       	call   8013dd <fd_lookup>
  80187d:	83 c4 08             	add    $0x8,%esp
  801880:	89 c2                	mov    %eax,%edx
  801882:	85 c0                	test   %eax,%eax
  801884:	78 58                	js     8018de <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801886:	83 ec 08             	sub    $0x8,%esp
  801889:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80188c:	50                   	push   %eax
  80188d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801890:	ff 30                	pushl  (%eax)
  801892:	e8 9c fb ff ff       	call   801433 <dev_lookup>
  801897:	83 c4 10             	add    $0x10,%esp
  80189a:	85 c0                	test   %eax,%eax
  80189c:	78 37                	js     8018d5 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80189e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018a5:	74 32                	je     8018d9 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018a7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018aa:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018b1:	00 00 00 
	stat->st_isdir = 0;
  8018b4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018bb:	00 00 00 
	stat->st_dev = dev;
  8018be:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018c4:	83 ec 08             	sub    $0x8,%esp
  8018c7:	53                   	push   %ebx
  8018c8:	ff 75 f0             	pushl  -0x10(%ebp)
  8018cb:	ff 50 14             	call   *0x14(%eax)
  8018ce:	89 c2                	mov    %eax,%edx
  8018d0:	83 c4 10             	add    $0x10,%esp
  8018d3:	eb 09                	jmp    8018de <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018d5:	89 c2                	mov    %eax,%edx
  8018d7:	eb 05                	jmp    8018de <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018d9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018de:	89 d0                	mov    %edx,%eax
  8018e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e3:	c9                   	leave  
  8018e4:	c3                   	ret    

008018e5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018e5:	55                   	push   %ebp
  8018e6:	89 e5                	mov    %esp,%ebp
  8018e8:	56                   	push   %esi
  8018e9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018ea:	83 ec 08             	sub    $0x8,%esp
  8018ed:	6a 00                	push   $0x0
  8018ef:	ff 75 08             	pushl  0x8(%ebp)
  8018f2:	e8 e3 01 00 00       	call   801ada <open>
  8018f7:	89 c3                	mov    %eax,%ebx
  8018f9:	83 c4 10             	add    $0x10,%esp
  8018fc:	85 c0                	test   %eax,%eax
  8018fe:	78 1b                	js     80191b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801900:	83 ec 08             	sub    $0x8,%esp
  801903:	ff 75 0c             	pushl  0xc(%ebp)
  801906:	50                   	push   %eax
  801907:	e8 5b ff ff ff       	call   801867 <fstat>
  80190c:	89 c6                	mov    %eax,%esi
	close(fd);
  80190e:	89 1c 24             	mov    %ebx,(%esp)
  801911:	e8 f4 fb ff ff       	call   80150a <close>
	return r;
  801916:	83 c4 10             	add    $0x10,%esp
  801919:	89 f0                	mov    %esi,%eax
}
  80191b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80191e:	5b                   	pop    %ebx
  80191f:	5e                   	pop    %esi
  801920:	5d                   	pop    %ebp
  801921:	c3                   	ret    

00801922 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801922:	55                   	push   %ebp
  801923:	89 e5                	mov    %esp,%ebp
  801925:	56                   	push   %esi
  801926:	53                   	push   %ebx
  801927:	89 c6                	mov    %eax,%esi
  801929:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80192b:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801932:	75 12                	jne    801946 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801934:	83 ec 0c             	sub    $0xc,%esp
  801937:	6a 01                	push   $0x1
  801939:	e8 79 0e 00 00       	call   8027b7 <ipc_find_env>
  80193e:	a3 00 50 80 00       	mov    %eax,0x805000
  801943:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801946:	6a 07                	push   $0x7
  801948:	68 00 60 80 00       	push   $0x806000
  80194d:	56                   	push   %esi
  80194e:	ff 35 00 50 80 00    	pushl  0x805000
  801954:	e8 fc 0d 00 00       	call   802755 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801959:	83 c4 0c             	add    $0xc,%esp
  80195c:	6a 00                	push   $0x0
  80195e:	53                   	push   %ebx
  80195f:	6a 00                	push   $0x0
  801961:	e8 74 0d 00 00       	call   8026da <ipc_recv>
}
  801966:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801969:	5b                   	pop    %ebx
  80196a:	5e                   	pop    %esi
  80196b:	5d                   	pop    %ebp
  80196c:	c3                   	ret    

0080196d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80196d:	55                   	push   %ebp
  80196e:	89 e5                	mov    %esp,%ebp
  801970:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801973:	8b 45 08             	mov    0x8(%ebp),%eax
  801976:	8b 40 0c             	mov    0xc(%eax),%eax
  801979:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  80197e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801981:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801986:	ba 00 00 00 00       	mov    $0x0,%edx
  80198b:	b8 02 00 00 00       	mov    $0x2,%eax
  801990:	e8 8d ff ff ff       	call   801922 <fsipc>
}
  801995:	c9                   	leave  
  801996:	c3                   	ret    

00801997 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801997:	55                   	push   %ebp
  801998:	89 e5                	mov    %esp,%ebp
  80199a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80199d:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a0:	8b 40 0c             	mov    0xc(%eax),%eax
  8019a3:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8019a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ad:	b8 06 00 00 00       	mov    $0x6,%eax
  8019b2:	e8 6b ff ff ff       	call   801922 <fsipc>
}
  8019b7:	c9                   	leave  
  8019b8:	c3                   	ret    

008019b9 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019b9:	55                   	push   %ebp
  8019ba:	89 e5                	mov    %esp,%ebp
  8019bc:	53                   	push   %ebx
  8019bd:	83 ec 04             	sub    $0x4,%esp
  8019c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c6:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c9:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d3:	b8 05 00 00 00       	mov    $0x5,%eax
  8019d8:	e8 45 ff ff ff       	call   801922 <fsipc>
  8019dd:	85 c0                	test   %eax,%eax
  8019df:	78 2c                	js     801a0d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019e1:	83 ec 08             	sub    $0x8,%esp
  8019e4:	68 00 60 80 00       	push   $0x806000
  8019e9:	53                   	push   %ebx
  8019ea:	e8 26 ee ff ff       	call   800815 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019ef:	a1 80 60 80 00       	mov    0x806080,%eax
  8019f4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019fa:	a1 84 60 80 00       	mov    0x806084,%eax
  8019ff:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a05:	83 c4 10             	add    $0x10,%esp
  801a08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a10:	c9                   	leave  
  801a11:	c3                   	ret    

00801a12 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	83 ec 0c             	sub    $0xc,%esp
  801a18:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a1b:	8b 55 08             	mov    0x8(%ebp),%edx
  801a1e:	8b 52 0c             	mov    0xc(%edx),%edx
  801a21:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801a27:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a2c:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a31:	0f 47 c2             	cmova  %edx,%eax
  801a34:	a3 04 60 80 00       	mov    %eax,0x806004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801a39:	50                   	push   %eax
  801a3a:	ff 75 0c             	pushl  0xc(%ebp)
  801a3d:	68 08 60 80 00       	push   $0x806008
  801a42:	e8 60 ef ff ff       	call   8009a7 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801a47:	ba 00 00 00 00       	mov    $0x0,%edx
  801a4c:	b8 04 00 00 00       	mov    $0x4,%eax
  801a51:	e8 cc fe ff ff       	call   801922 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801a56:	c9                   	leave  
  801a57:	c3                   	ret    

00801a58 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a58:	55                   	push   %ebp
  801a59:	89 e5                	mov    %esp,%ebp
  801a5b:	56                   	push   %esi
  801a5c:	53                   	push   %ebx
  801a5d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a60:	8b 45 08             	mov    0x8(%ebp),%eax
  801a63:	8b 40 0c             	mov    0xc(%eax),%eax
  801a66:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801a6b:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a71:	ba 00 00 00 00       	mov    $0x0,%edx
  801a76:	b8 03 00 00 00       	mov    $0x3,%eax
  801a7b:	e8 a2 fe ff ff       	call   801922 <fsipc>
  801a80:	89 c3                	mov    %eax,%ebx
  801a82:	85 c0                	test   %eax,%eax
  801a84:	78 4b                	js     801ad1 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a86:	39 c6                	cmp    %eax,%esi
  801a88:	73 16                	jae    801aa0 <devfile_read+0x48>
  801a8a:	68 24 30 80 00       	push   $0x803024
  801a8f:	68 2b 30 80 00       	push   $0x80302b
  801a94:	6a 7c                	push   $0x7c
  801a96:	68 40 30 80 00       	push   $0x803040
  801a9b:	e8 17 e7 ff ff       	call   8001b7 <_panic>
	assert(r <= PGSIZE);
  801aa0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801aa5:	7e 16                	jle    801abd <devfile_read+0x65>
  801aa7:	68 4b 30 80 00       	push   $0x80304b
  801aac:	68 2b 30 80 00       	push   $0x80302b
  801ab1:	6a 7d                	push   $0x7d
  801ab3:	68 40 30 80 00       	push   $0x803040
  801ab8:	e8 fa e6 ff ff       	call   8001b7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801abd:	83 ec 04             	sub    $0x4,%esp
  801ac0:	50                   	push   %eax
  801ac1:	68 00 60 80 00       	push   $0x806000
  801ac6:	ff 75 0c             	pushl  0xc(%ebp)
  801ac9:	e8 d9 ee ff ff       	call   8009a7 <memmove>
	return r;
  801ace:	83 c4 10             	add    $0x10,%esp
}
  801ad1:	89 d8                	mov    %ebx,%eax
  801ad3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad6:	5b                   	pop    %ebx
  801ad7:	5e                   	pop    %esi
  801ad8:	5d                   	pop    %ebp
  801ad9:	c3                   	ret    

00801ada <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	53                   	push   %ebx
  801ade:	83 ec 20             	sub    $0x20,%esp
  801ae1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ae4:	53                   	push   %ebx
  801ae5:	e8 f2 ec ff ff       	call   8007dc <strlen>
  801aea:	83 c4 10             	add    $0x10,%esp
  801aed:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801af2:	7f 67                	jg     801b5b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801af4:	83 ec 0c             	sub    $0xc,%esp
  801af7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801afa:	50                   	push   %eax
  801afb:	e8 8e f8 ff ff       	call   80138e <fd_alloc>
  801b00:	83 c4 10             	add    $0x10,%esp
		return r;
  801b03:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b05:	85 c0                	test   %eax,%eax
  801b07:	78 57                	js     801b60 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b09:	83 ec 08             	sub    $0x8,%esp
  801b0c:	53                   	push   %ebx
  801b0d:	68 00 60 80 00       	push   $0x806000
  801b12:	e8 fe ec ff ff       	call   800815 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b17:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b1a:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b22:	b8 01 00 00 00       	mov    $0x1,%eax
  801b27:	e8 f6 fd ff ff       	call   801922 <fsipc>
  801b2c:	89 c3                	mov    %eax,%ebx
  801b2e:	83 c4 10             	add    $0x10,%esp
  801b31:	85 c0                	test   %eax,%eax
  801b33:	79 14                	jns    801b49 <open+0x6f>
		fd_close(fd, 0);
  801b35:	83 ec 08             	sub    $0x8,%esp
  801b38:	6a 00                	push   $0x0
  801b3a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b3d:	e8 47 f9 ff ff       	call   801489 <fd_close>
		return r;
  801b42:	83 c4 10             	add    $0x10,%esp
  801b45:	89 da                	mov    %ebx,%edx
  801b47:	eb 17                	jmp    801b60 <open+0x86>
	}

	return fd2num(fd);
  801b49:	83 ec 0c             	sub    $0xc,%esp
  801b4c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b4f:	e8 13 f8 ff ff       	call   801367 <fd2num>
  801b54:	89 c2                	mov    %eax,%edx
  801b56:	83 c4 10             	add    $0x10,%esp
  801b59:	eb 05                	jmp    801b60 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b5b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b60:	89 d0                	mov    %edx,%eax
  801b62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b65:	c9                   	leave  
  801b66:	c3                   	ret    

00801b67 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b67:	55                   	push   %ebp
  801b68:	89 e5                	mov    %esp,%ebp
  801b6a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b6d:	ba 00 00 00 00       	mov    $0x0,%edx
  801b72:	b8 08 00 00 00       	mov    $0x8,%eax
  801b77:	e8 a6 fd ff ff       	call   801922 <fsipc>
}
  801b7c:	c9                   	leave  
  801b7d:	c3                   	ret    

00801b7e <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	57                   	push   %edi
  801b82:	56                   	push   %esi
  801b83:	53                   	push   %ebx
  801b84:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801b8a:	6a 00                	push   $0x0
  801b8c:	ff 75 08             	pushl  0x8(%ebp)
  801b8f:	e8 46 ff ff ff       	call   801ada <open>
  801b94:	89 c7                	mov    %eax,%edi
  801b96:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801b9c:	83 c4 10             	add    $0x10,%esp
  801b9f:	85 c0                	test   %eax,%eax
  801ba1:	0f 88 8c 04 00 00    	js     802033 <spawn+0x4b5>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801ba7:	83 ec 04             	sub    $0x4,%esp
  801baa:	68 00 02 00 00       	push   $0x200
  801baf:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801bb5:	50                   	push   %eax
  801bb6:	57                   	push   %edi
  801bb7:	e8 1e fb ff ff       	call   8016da <readn>
  801bbc:	83 c4 10             	add    $0x10,%esp
  801bbf:	3d 00 02 00 00       	cmp    $0x200,%eax
  801bc4:	75 0c                	jne    801bd2 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801bc6:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801bcd:	45 4c 46 
  801bd0:	74 33                	je     801c05 <spawn+0x87>
		close(fd);
  801bd2:	83 ec 0c             	sub    $0xc,%esp
  801bd5:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801bdb:	e8 2a f9 ff ff       	call   80150a <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801be0:	83 c4 0c             	add    $0xc,%esp
  801be3:	68 7f 45 4c 46       	push   $0x464c457f
  801be8:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801bee:	68 57 30 80 00       	push   $0x803057
  801bf3:	e8 98 e6 ff ff       	call   800290 <cprintf>
		return -E_NOT_EXEC;
  801bf8:	83 c4 10             	add    $0x10,%esp
  801bfb:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801c00:	e9 e1 04 00 00       	jmp    8020e6 <spawn+0x568>
  801c05:	b8 07 00 00 00       	mov    $0x7,%eax
  801c0a:	cd 30                	int    $0x30
  801c0c:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801c12:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801c18:	85 c0                	test   %eax,%eax
  801c1a:	0f 88 1e 04 00 00    	js     80203e <spawn+0x4c0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801c20:	89 c6                	mov    %eax,%esi
  801c22:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801c28:	69 f6 d4 00 00 00    	imul   $0xd4,%esi,%esi
  801c2e:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801c34:	81 c6 58 00 c0 ee    	add    $0xeec00058,%esi
  801c3a:	b9 11 00 00 00       	mov    $0x11,%ecx
  801c3f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801c41:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801c47:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801c4d:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801c52:	be 00 00 00 00       	mov    $0x0,%esi
  801c57:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c5a:	eb 13                	jmp    801c6f <spawn+0xf1>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801c5c:	83 ec 0c             	sub    $0xc,%esp
  801c5f:	50                   	push   %eax
  801c60:	e8 77 eb ff ff       	call   8007dc <strlen>
  801c65:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801c69:	83 c3 01             	add    $0x1,%ebx
  801c6c:	83 c4 10             	add    $0x10,%esp
  801c6f:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801c76:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801c79:	85 c0                	test   %eax,%eax
  801c7b:	75 df                	jne    801c5c <spawn+0xde>
  801c7d:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801c83:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801c89:	bf 00 10 40 00       	mov    $0x401000,%edi
  801c8e:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801c90:	89 fa                	mov    %edi,%edx
  801c92:	83 e2 fc             	and    $0xfffffffc,%edx
  801c95:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801c9c:	29 c2                	sub    %eax,%edx
  801c9e:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801ca4:	8d 42 f8             	lea    -0x8(%edx),%eax
  801ca7:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801cac:	0f 86 a2 03 00 00    	jbe    802054 <spawn+0x4d6>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801cb2:	83 ec 04             	sub    $0x4,%esp
  801cb5:	6a 07                	push   $0x7
  801cb7:	68 00 00 40 00       	push   $0x400000
  801cbc:	6a 00                	push   $0x0
  801cbe:	e8 55 ef ff ff       	call   800c18 <sys_page_alloc>
  801cc3:	83 c4 10             	add    $0x10,%esp
  801cc6:	85 c0                	test   %eax,%eax
  801cc8:	0f 88 90 03 00 00    	js     80205e <spawn+0x4e0>
  801cce:	be 00 00 00 00       	mov    $0x0,%esi
  801cd3:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801cd9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801cdc:	eb 30                	jmp    801d0e <spawn+0x190>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801cde:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801ce4:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801cea:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801ced:	83 ec 08             	sub    $0x8,%esp
  801cf0:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801cf3:	57                   	push   %edi
  801cf4:	e8 1c eb ff ff       	call   800815 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801cf9:	83 c4 04             	add    $0x4,%esp
  801cfc:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801cff:	e8 d8 ea ff ff       	call   8007dc <strlen>
  801d04:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801d08:	83 c6 01             	add    $0x1,%esi
  801d0b:	83 c4 10             	add    $0x10,%esp
  801d0e:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801d14:	7f c8                	jg     801cde <spawn+0x160>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801d16:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801d1c:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801d22:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801d29:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801d2f:	74 19                	je     801d4a <spawn+0x1cc>
  801d31:	68 e4 30 80 00       	push   $0x8030e4
  801d36:	68 2b 30 80 00       	push   $0x80302b
  801d3b:	68 f2 00 00 00       	push   $0xf2
  801d40:	68 71 30 80 00       	push   $0x803071
  801d45:	e8 6d e4 ff ff       	call   8001b7 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801d4a:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801d50:	89 f8                	mov    %edi,%eax
  801d52:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801d57:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801d5a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801d60:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801d63:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801d69:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801d6f:	83 ec 0c             	sub    $0xc,%esp
  801d72:	6a 07                	push   $0x7
  801d74:	68 00 d0 bf ee       	push   $0xeebfd000
  801d79:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d7f:	68 00 00 40 00       	push   $0x400000
  801d84:	6a 00                	push   $0x0
  801d86:	e8 d0 ee ff ff       	call   800c5b <sys_page_map>
  801d8b:	89 c3                	mov    %eax,%ebx
  801d8d:	83 c4 20             	add    $0x20,%esp
  801d90:	85 c0                	test   %eax,%eax
  801d92:	0f 88 3c 03 00 00    	js     8020d4 <spawn+0x556>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801d98:	83 ec 08             	sub    $0x8,%esp
  801d9b:	68 00 00 40 00       	push   $0x400000
  801da0:	6a 00                	push   $0x0
  801da2:	e8 f6 ee ff ff       	call   800c9d <sys_page_unmap>
  801da7:	89 c3                	mov    %eax,%ebx
  801da9:	83 c4 10             	add    $0x10,%esp
  801dac:	85 c0                	test   %eax,%eax
  801dae:	0f 88 20 03 00 00    	js     8020d4 <spawn+0x556>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801db4:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801dba:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801dc1:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801dc7:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801dce:	00 00 00 
  801dd1:	e9 88 01 00 00       	jmp    801f5e <spawn+0x3e0>
		if (ph->p_type != ELF_PROG_LOAD)
  801dd6:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801ddc:	83 38 01             	cmpl   $0x1,(%eax)
  801ddf:	0f 85 6b 01 00 00    	jne    801f50 <spawn+0x3d2>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801de5:	89 c2                	mov    %eax,%edx
  801de7:	8b 40 18             	mov    0x18(%eax),%eax
  801dea:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801df0:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801df3:	83 f8 01             	cmp    $0x1,%eax
  801df6:	19 c0                	sbb    %eax,%eax
  801df8:	83 e0 fe             	and    $0xfffffffe,%eax
  801dfb:	83 c0 07             	add    $0x7,%eax
  801dfe:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801e04:	89 d0                	mov    %edx,%eax
  801e06:	8b 7a 04             	mov    0x4(%edx),%edi
  801e09:	89 f9                	mov    %edi,%ecx
  801e0b:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801e11:	8b 7a 10             	mov    0x10(%edx),%edi
  801e14:	8b 52 14             	mov    0x14(%edx),%edx
  801e17:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801e1d:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801e20:	89 f0                	mov    %esi,%eax
  801e22:	25 ff 0f 00 00       	and    $0xfff,%eax
  801e27:	74 14                	je     801e3d <spawn+0x2bf>
		va -= i;
  801e29:	29 c6                	sub    %eax,%esi
		memsz += i;
  801e2b:	01 c2                	add    %eax,%edx
  801e2d:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801e33:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801e35:	29 c1                	sub    %eax,%ecx
  801e37:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801e3d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e42:	e9 f7 00 00 00       	jmp    801f3e <spawn+0x3c0>
		if (i >= filesz) {
  801e47:	39 fb                	cmp    %edi,%ebx
  801e49:	72 27                	jb     801e72 <spawn+0x2f4>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801e4b:	83 ec 04             	sub    $0x4,%esp
  801e4e:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801e54:	56                   	push   %esi
  801e55:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801e5b:	e8 b8 ed ff ff       	call   800c18 <sys_page_alloc>
  801e60:	83 c4 10             	add    $0x10,%esp
  801e63:	85 c0                	test   %eax,%eax
  801e65:	0f 89 c7 00 00 00    	jns    801f32 <spawn+0x3b4>
  801e6b:	89 c3                	mov    %eax,%ebx
  801e6d:	e9 fd 01 00 00       	jmp    80206f <spawn+0x4f1>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e72:	83 ec 04             	sub    $0x4,%esp
  801e75:	6a 07                	push   $0x7
  801e77:	68 00 00 40 00       	push   $0x400000
  801e7c:	6a 00                	push   $0x0
  801e7e:	e8 95 ed ff ff       	call   800c18 <sys_page_alloc>
  801e83:	83 c4 10             	add    $0x10,%esp
  801e86:	85 c0                	test   %eax,%eax
  801e88:	0f 88 d7 01 00 00    	js     802065 <spawn+0x4e7>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801e8e:	83 ec 08             	sub    $0x8,%esp
  801e91:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801e97:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801e9d:	50                   	push   %eax
  801e9e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ea4:	e8 09 f9 ff ff       	call   8017b2 <seek>
  801ea9:	83 c4 10             	add    $0x10,%esp
  801eac:	85 c0                	test   %eax,%eax
  801eae:	0f 88 b5 01 00 00    	js     802069 <spawn+0x4eb>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801eb4:	83 ec 04             	sub    $0x4,%esp
  801eb7:	89 f8                	mov    %edi,%eax
  801eb9:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801ebf:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ec4:	ba 00 10 00 00       	mov    $0x1000,%edx
  801ec9:	0f 47 c2             	cmova  %edx,%eax
  801ecc:	50                   	push   %eax
  801ecd:	68 00 00 40 00       	push   $0x400000
  801ed2:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ed8:	e8 fd f7 ff ff       	call   8016da <readn>
  801edd:	83 c4 10             	add    $0x10,%esp
  801ee0:	85 c0                	test   %eax,%eax
  801ee2:	0f 88 85 01 00 00    	js     80206d <spawn+0x4ef>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801ee8:	83 ec 0c             	sub    $0xc,%esp
  801eeb:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801ef1:	56                   	push   %esi
  801ef2:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801ef8:	68 00 00 40 00       	push   $0x400000
  801efd:	6a 00                	push   $0x0
  801eff:	e8 57 ed ff ff       	call   800c5b <sys_page_map>
  801f04:	83 c4 20             	add    $0x20,%esp
  801f07:	85 c0                	test   %eax,%eax
  801f09:	79 15                	jns    801f20 <spawn+0x3a2>
				panic("spawn: sys_page_map data: %e", r);
  801f0b:	50                   	push   %eax
  801f0c:	68 7d 30 80 00       	push   $0x80307d
  801f11:	68 25 01 00 00       	push   $0x125
  801f16:	68 71 30 80 00       	push   $0x803071
  801f1b:	e8 97 e2 ff ff       	call   8001b7 <_panic>
			sys_page_unmap(0, UTEMP);
  801f20:	83 ec 08             	sub    $0x8,%esp
  801f23:	68 00 00 40 00       	push   $0x400000
  801f28:	6a 00                	push   $0x0
  801f2a:	e8 6e ed ff ff       	call   800c9d <sys_page_unmap>
  801f2f:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801f32:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801f38:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801f3e:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801f44:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801f4a:	0f 82 f7 fe ff ff    	jb     801e47 <spawn+0x2c9>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f50:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801f57:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801f5e:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801f65:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801f6b:	0f 8c 65 fe ff ff    	jl     801dd6 <spawn+0x258>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801f71:	83 ec 0c             	sub    $0xc,%esp
  801f74:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801f7a:	e8 8b f5 ff ff       	call   80150a <close>
  801f7f:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801f82:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f87:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801f8d:	89 d8                	mov    %ebx,%eax
  801f8f:	c1 e8 16             	shr    $0x16,%eax
  801f92:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801f99:	a8 01                	test   $0x1,%al
  801f9b:	74 42                	je     801fdf <spawn+0x461>
  801f9d:	89 d8                	mov    %ebx,%eax
  801f9f:	c1 e8 0c             	shr    $0xc,%eax
  801fa2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801fa9:	f6 c2 01             	test   $0x1,%dl
  801fac:	74 31                	je     801fdf <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  801fae:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801fb5:	f6 c6 04             	test   $0x4,%dh
  801fb8:	74 25                	je     801fdf <spawn+0x461>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  801fba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801fc1:	83 ec 0c             	sub    $0xc,%esp
  801fc4:	25 07 0e 00 00       	and    $0xe07,%eax
  801fc9:	50                   	push   %eax
  801fca:	53                   	push   %ebx
  801fcb:	56                   	push   %esi
  801fcc:	53                   	push   %ebx
  801fcd:	6a 00                	push   $0x0
  801fcf:	e8 87 ec ff ff       	call   800c5b <sys_page_map>
			if (r < 0) {
  801fd4:	83 c4 20             	add    $0x20,%esp
  801fd7:	85 c0                	test   %eax,%eax
  801fd9:	0f 88 b1 00 00 00    	js     802090 <spawn+0x512>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801fdf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801fe5:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801feb:	75 a0                	jne    801f8d <spawn+0x40f>
  801fed:	e9 b3 00 00 00       	jmp    8020a5 <spawn+0x527>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801ff2:	50                   	push   %eax
  801ff3:	68 9a 30 80 00       	push   $0x80309a
  801ff8:	68 86 00 00 00       	push   $0x86
  801ffd:	68 71 30 80 00       	push   $0x803071
  802002:	e8 b0 e1 ff ff       	call   8001b7 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802007:	83 ec 08             	sub    $0x8,%esp
  80200a:	6a 02                	push   $0x2
  80200c:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802012:	e8 c8 ec ff ff       	call   800cdf <sys_env_set_status>
  802017:	83 c4 10             	add    $0x10,%esp
  80201a:	85 c0                	test   %eax,%eax
  80201c:	79 2b                	jns    802049 <spawn+0x4cb>
		panic("sys_env_set_status: %e", r);
  80201e:	50                   	push   %eax
  80201f:	68 b4 30 80 00       	push   $0x8030b4
  802024:	68 89 00 00 00       	push   $0x89
  802029:	68 71 30 80 00       	push   $0x803071
  80202e:	e8 84 e1 ff ff       	call   8001b7 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802033:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  802039:	e9 a8 00 00 00       	jmp    8020e6 <spawn+0x568>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  80203e:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802044:	e9 9d 00 00 00       	jmp    8020e6 <spawn+0x568>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  802049:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  80204f:	e9 92 00 00 00       	jmp    8020e6 <spawn+0x568>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802054:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  802059:	e9 88 00 00 00       	jmp    8020e6 <spawn+0x568>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  80205e:	89 c3                	mov    %eax,%ebx
  802060:	e9 81 00 00 00       	jmp    8020e6 <spawn+0x568>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802065:	89 c3                	mov    %eax,%ebx
  802067:	eb 06                	jmp    80206f <spawn+0x4f1>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802069:	89 c3                	mov    %eax,%ebx
  80206b:	eb 02                	jmp    80206f <spawn+0x4f1>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80206d:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  80206f:	83 ec 0c             	sub    $0xc,%esp
  802072:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802078:	e8 1c eb ff ff       	call   800b99 <sys_env_destroy>
	close(fd);
  80207d:	83 c4 04             	add    $0x4,%esp
  802080:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802086:	e8 7f f4 ff ff       	call   80150a <close>
	return r;
  80208b:	83 c4 10             	add    $0x10,%esp
  80208e:	eb 56                	jmp    8020e6 <spawn+0x568>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  802090:	50                   	push   %eax
  802091:	68 cb 30 80 00       	push   $0x8030cb
  802096:	68 82 00 00 00       	push   $0x82
  80209b:	68 71 30 80 00       	push   $0x803071
  8020a0:	e8 12 e1 ff ff       	call   8001b7 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  8020a5:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  8020ac:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8020af:	83 ec 08             	sub    $0x8,%esp
  8020b2:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8020b8:	50                   	push   %eax
  8020b9:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8020bf:	e8 5d ec ff ff       	call   800d21 <sys_env_set_trapframe>
  8020c4:	83 c4 10             	add    $0x10,%esp
  8020c7:	85 c0                	test   %eax,%eax
  8020c9:	0f 89 38 ff ff ff    	jns    802007 <spawn+0x489>
  8020cf:	e9 1e ff ff ff       	jmp    801ff2 <spawn+0x474>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8020d4:	83 ec 08             	sub    $0x8,%esp
  8020d7:	68 00 00 40 00       	push   $0x400000
  8020dc:	6a 00                	push   $0x0
  8020de:	e8 ba eb ff ff       	call   800c9d <sys_page_unmap>
  8020e3:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8020e6:	89 d8                	mov    %ebx,%eax
  8020e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020eb:	5b                   	pop    %ebx
  8020ec:	5e                   	pop    %esi
  8020ed:	5f                   	pop    %edi
  8020ee:	5d                   	pop    %ebp
  8020ef:	c3                   	ret    

008020f0 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8020f0:	55                   	push   %ebp
  8020f1:	89 e5                	mov    %esp,%ebp
  8020f3:	56                   	push   %esi
  8020f4:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8020f5:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8020f8:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8020fd:	eb 03                	jmp    802102 <spawnl+0x12>
		argc++;
  8020ff:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802102:	83 c2 04             	add    $0x4,%edx
  802105:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802109:	75 f4                	jne    8020ff <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80210b:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802112:	83 e2 f0             	and    $0xfffffff0,%edx
  802115:	29 d4                	sub    %edx,%esp
  802117:	8d 54 24 03          	lea    0x3(%esp),%edx
  80211b:	c1 ea 02             	shr    $0x2,%edx
  80211e:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802125:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802127:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80212a:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802131:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802138:	00 
  802139:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  80213b:	b8 00 00 00 00       	mov    $0x0,%eax
  802140:	eb 0a                	jmp    80214c <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802142:	83 c0 01             	add    $0x1,%eax
  802145:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802149:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  80214c:	39 d0                	cmp    %edx,%eax
  80214e:	75 f2                	jne    802142 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802150:	83 ec 08             	sub    $0x8,%esp
  802153:	56                   	push   %esi
  802154:	ff 75 08             	pushl  0x8(%ebp)
  802157:	e8 22 fa ff ff       	call   801b7e <spawn>
}
  80215c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80215f:	5b                   	pop    %ebx
  802160:	5e                   	pop    %esi
  802161:	5d                   	pop    %ebp
  802162:	c3                   	ret    

00802163 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802163:	55                   	push   %ebp
  802164:	89 e5                	mov    %esp,%ebp
  802166:	56                   	push   %esi
  802167:	53                   	push   %ebx
  802168:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80216b:	83 ec 0c             	sub    $0xc,%esp
  80216e:	ff 75 08             	pushl  0x8(%ebp)
  802171:	e8 01 f2 ff ff       	call   801377 <fd2data>
  802176:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802178:	83 c4 08             	add    $0x8,%esp
  80217b:	68 0c 31 80 00       	push   $0x80310c
  802180:	53                   	push   %ebx
  802181:	e8 8f e6 ff ff       	call   800815 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802186:	8b 46 04             	mov    0x4(%esi),%eax
  802189:	2b 06                	sub    (%esi),%eax
  80218b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802191:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802198:	00 00 00 
	stat->st_dev = &devpipe;
  80219b:	c7 83 88 00 00 00 20 	movl   $0x804020,0x88(%ebx)
  8021a2:	40 80 00 
	return 0;
}
  8021a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8021aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021ad:	5b                   	pop    %ebx
  8021ae:	5e                   	pop    %esi
  8021af:	5d                   	pop    %ebp
  8021b0:	c3                   	ret    

008021b1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8021b1:	55                   	push   %ebp
  8021b2:	89 e5                	mov    %esp,%ebp
  8021b4:	53                   	push   %ebx
  8021b5:	83 ec 0c             	sub    $0xc,%esp
  8021b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8021bb:	53                   	push   %ebx
  8021bc:	6a 00                	push   $0x0
  8021be:	e8 da ea ff ff       	call   800c9d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8021c3:	89 1c 24             	mov    %ebx,(%esp)
  8021c6:	e8 ac f1 ff ff       	call   801377 <fd2data>
  8021cb:	83 c4 08             	add    $0x8,%esp
  8021ce:	50                   	push   %eax
  8021cf:	6a 00                	push   $0x0
  8021d1:	e8 c7 ea ff ff       	call   800c9d <sys_page_unmap>
}
  8021d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021d9:	c9                   	leave  
  8021da:	c3                   	ret    

008021db <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8021db:	55                   	push   %ebp
  8021dc:	89 e5                	mov    %esp,%ebp
  8021de:	57                   	push   %edi
  8021df:	56                   	push   %esi
  8021e0:	53                   	push   %ebx
  8021e1:	83 ec 1c             	sub    $0x1c,%esp
  8021e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8021e7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8021e9:	a1 04 50 80 00       	mov    0x805004,%eax
  8021ee:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8021f4:	83 ec 0c             	sub    $0xc,%esp
  8021f7:	ff 75 e0             	pushl  -0x20(%ebp)
  8021fa:	e8 fd 05 00 00       	call   8027fc <pageref>
  8021ff:	89 c3                	mov    %eax,%ebx
  802201:	89 3c 24             	mov    %edi,(%esp)
  802204:	e8 f3 05 00 00       	call   8027fc <pageref>
  802209:	83 c4 10             	add    $0x10,%esp
  80220c:	39 c3                	cmp    %eax,%ebx
  80220e:	0f 94 c1             	sete   %cl
  802211:	0f b6 c9             	movzbl %cl,%ecx
  802214:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802217:	8b 15 04 50 80 00    	mov    0x805004,%edx
  80221d:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  802223:	39 ce                	cmp    %ecx,%esi
  802225:	74 1e                	je     802245 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  802227:	39 c3                	cmp    %eax,%ebx
  802229:	75 be                	jne    8021e9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80222b:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  802231:	ff 75 e4             	pushl  -0x1c(%ebp)
  802234:	50                   	push   %eax
  802235:	56                   	push   %esi
  802236:	68 13 31 80 00       	push   $0x803113
  80223b:	e8 50 e0 ff ff       	call   800290 <cprintf>
  802240:	83 c4 10             	add    $0x10,%esp
  802243:	eb a4                	jmp    8021e9 <_pipeisclosed+0xe>
	}
}
  802245:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802248:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80224b:	5b                   	pop    %ebx
  80224c:	5e                   	pop    %esi
  80224d:	5f                   	pop    %edi
  80224e:	5d                   	pop    %ebp
  80224f:	c3                   	ret    

00802250 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802250:	55                   	push   %ebp
  802251:	89 e5                	mov    %esp,%ebp
  802253:	57                   	push   %edi
  802254:	56                   	push   %esi
  802255:	53                   	push   %ebx
  802256:	83 ec 28             	sub    $0x28,%esp
  802259:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80225c:	56                   	push   %esi
  80225d:	e8 15 f1 ff ff       	call   801377 <fd2data>
  802262:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802264:	83 c4 10             	add    $0x10,%esp
  802267:	bf 00 00 00 00       	mov    $0x0,%edi
  80226c:	eb 4b                	jmp    8022b9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80226e:	89 da                	mov    %ebx,%edx
  802270:	89 f0                	mov    %esi,%eax
  802272:	e8 64 ff ff ff       	call   8021db <_pipeisclosed>
  802277:	85 c0                	test   %eax,%eax
  802279:	75 48                	jne    8022c3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80227b:	e8 79 e9 ff ff       	call   800bf9 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802280:	8b 43 04             	mov    0x4(%ebx),%eax
  802283:	8b 0b                	mov    (%ebx),%ecx
  802285:	8d 51 20             	lea    0x20(%ecx),%edx
  802288:	39 d0                	cmp    %edx,%eax
  80228a:	73 e2                	jae    80226e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80228c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80228f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802293:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802296:	89 c2                	mov    %eax,%edx
  802298:	c1 fa 1f             	sar    $0x1f,%edx
  80229b:	89 d1                	mov    %edx,%ecx
  80229d:	c1 e9 1b             	shr    $0x1b,%ecx
  8022a0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8022a3:	83 e2 1f             	and    $0x1f,%edx
  8022a6:	29 ca                	sub    %ecx,%edx
  8022a8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8022ac:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8022b0:	83 c0 01             	add    $0x1,%eax
  8022b3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022b6:	83 c7 01             	add    $0x1,%edi
  8022b9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8022bc:	75 c2                	jne    802280 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8022be:	8b 45 10             	mov    0x10(%ebp),%eax
  8022c1:	eb 05                	jmp    8022c8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022c3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8022c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022cb:	5b                   	pop    %ebx
  8022cc:	5e                   	pop    %esi
  8022cd:	5f                   	pop    %edi
  8022ce:	5d                   	pop    %ebp
  8022cf:	c3                   	ret    

008022d0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022d0:	55                   	push   %ebp
  8022d1:	89 e5                	mov    %esp,%ebp
  8022d3:	57                   	push   %edi
  8022d4:	56                   	push   %esi
  8022d5:	53                   	push   %ebx
  8022d6:	83 ec 18             	sub    $0x18,%esp
  8022d9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8022dc:	57                   	push   %edi
  8022dd:	e8 95 f0 ff ff       	call   801377 <fd2data>
  8022e2:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022e4:	83 c4 10             	add    $0x10,%esp
  8022e7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8022ec:	eb 3d                	jmp    80232b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8022ee:	85 db                	test   %ebx,%ebx
  8022f0:	74 04                	je     8022f6 <devpipe_read+0x26>
				return i;
  8022f2:	89 d8                	mov    %ebx,%eax
  8022f4:	eb 44                	jmp    80233a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8022f6:	89 f2                	mov    %esi,%edx
  8022f8:	89 f8                	mov    %edi,%eax
  8022fa:	e8 dc fe ff ff       	call   8021db <_pipeisclosed>
  8022ff:	85 c0                	test   %eax,%eax
  802301:	75 32                	jne    802335 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802303:	e8 f1 e8 ff ff       	call   800bf9 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802308:	8b 06                	mov    (%esi),%eax
  80230a:	3b 46 04             	cmp    0x4(%esi),%eax
  80230d:	74 df                	je     8022ee <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80230f:	99                   	cltd   
  802310:	c1 ea 1b             	shr    $0x1b,%edx
  802313:	01 d0                	add    %edx,%eax
  802315:	83 e0 1f             	and    $0x1f,%eax
  802318:	29 d0                	sub    %edx,%eax
  80231a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80231f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802322:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802325:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802328:	83 c3 01             	add    $0x1,%ebx
  80232b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80232e:	75 d8                	jne    802308 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802330:	8b 45 10             	mov    0x10(%ebp),%eax
  802333:	eb 05                	jmp    80233a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802335:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80233a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80233d:	5b                   	pop    %ebx
  80233e:	5e                   	pop    %esi
  80233f:	5f                   	pop    %edi
  802340:	5d                   	pop    %ebp
  802341:	c3                   	ret    

00802342 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802342:	55                   	push   %ebp
  802343:	89 e5                	mov    %esp,%ebp
  802345:	56                   	push   %esi
  802346:	53                   	push   %ebx
  802347:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80234a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80234d:	50                   	push   %eax
  80234e:	e8 3b f0 ff ff       	call   80138e <fd_alloc>
  802353:	83 c4 10             	add    $0x10,%esp
  802356:	89 c2                	mov    %eax,%edx
  802358:	85 c0                	test   %eax,%eax
  80235a:	0f 88 2c 01 00 00    	js     80248c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802360:	83 ec 04             	sub    $0x4,%esp
  802363:	68 07 04 00 00       	push   $0x407
  802368:	ff 75 f4             	pushl  -0xc(%ebp)
  80236b:	6a 00                	push   $0x0
  80236d:	e8 a6 e8 ff ff       	call   800c18 <sys_page_alloc>
  802372:	83 c4 10             	add    $0x10,%esp
  802375:	89 c2                	mov    %eax,%edx
  802377:	85 c0                	test   %eax,%eax
  802379:	0f 88 0d 01 00 00    	js     80248c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80237f:	83 ec 0c             	sub    $0xc,%esp
  802382:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802385:	50                   	push   %eax
  802386:	e8 03 f0 ff ff       	call   80138e <fd_alloc>
  80238b:	89 c3                	mov    %eax,%ebx
  80238d:	83 c4 10             	add    $0x10,%esp
  802390:	85 c0                	test   %eax,%eax
  802392:	0f 88 e2 00 00 00    	js     80247a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802398:	83 ec 04             	sub    $0x4,%esp
  80239b:	68 07 04 00 00       	push   $0x407
  8023a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8023a3:	6a 00                	push   $0x0
  8023a5:	e8 6e e8 ff ff       	call   800c18 <sys_page_alloc>
  8023aa:	89 c3                	mov    %eax,%ebx
  8023ac:	83 c4 10             	add    $0x10,%esp
  8023af:	85 c0                	test   %eax,%eax
  8023b1:	0f 88 c3 00 00 00    	js     80247a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8023b7:	83 ec 0c             	sub    $0xc,%esp
  8023ba:	ff 75 f4             	pushl  -0xc(%ebp)
  8023bd:	e8 b5 ef ff ff       	call   801377 <fd2data>
  8023c2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023c4:	83 c4 0c             	add    $0xc,%esp
  8023c7:	68 07 04 00 00       	push   $0x407
  8023cc:	50                   	push   %eax
  8023cd:	6a 00                	push   $0x0
  8023cf:	e8 44 e8 ff ff       	call   800c18 <sys_page_alloc>
  8023d4:	89 c3                	mov    %eax,%ebx
  8023d6:	83 c4 10             	add    $0x10,%esp
  8023d9:	85 c0                	test   %eax,%eax
  8023db:	0f 88 89 00 00 00    	js     80246a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023e1:	83 ec 0c             	sub    $0xc,%esp
  8023e4:	ff 75 f0             	pushl  -0x10(%ebp)
  8023e7:	e8 8b ef ff ff       	call   801377 <fd2data>
  8023ec:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8023f3:	50                   	push   %eax
  8023f4:	6a 00                	push   $0x0
  8023f6:	56                   	push   %esi
  8023f7:	6a 00                	push   $0x0
  8023f9:	e8 5d e8 ff ff       	call   800c5b <sys_page_map>
  8023fe:	89 c3                	mov    %eax,%ebx
  802400:	83 c4 20             	add    $0x20,%esp
  802403:	85 c0                	test   %eax,%eax
  802405:	78 55                	js     80245c <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802407:	8b 15 20 40 80 00    	mov    0x804020,%edx
  80240d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802410:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802412:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802415:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80241c:	8b 15 20 40 80 00    	mov    0x804020,%edx
  802422:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802425:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802427:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80242a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802431:	83 ec 0c             	sub    $0xc,%esp
  802434:	ff 75 f4             	pushl  -0xc(%ebp)
  802437:	e8 2b ef ff ff       	call   801367 <fd2num>
  80243c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80243f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802441:	83 c4 04             	add    $0x4,%esp
  802444:	ff 75 f0             	pushl  -0x10(%ebp)
  802447:	e8 1b ef ff ff       	call   801367 <fd2num>
  80244c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80244f:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  802452:	83 c4 10             	add    $0x10,%esp
  802455:	ba 00 00 00 00       	mov    $0x0,%edx
  80245a:	eb 30                	jmp    80248c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80245c:	83 ec 08             	sub    $0x8,%esp
  80245f:	56                   	push   %esi
  802460:	6a 00                	push   $0x0
  802462:	e8 36 e8 ff ff       	call   800c9d <sys_page_unmap>
  802467:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80246a:	83 ec 08             	sub    $0x8,%esp
  80246d:	ff 75 f0             	pushl  -0x10(%ebp)
  802470:	6a 00                	push   $0x0
  802472:	e8 26 e8 ff ff       	call   800c9d <sys_page_unmap>
  802477:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80247a:	83 ec 08             	sub    $0x8,%esp
  80247d:	ff 75 f4             	pushl  -0xc(%ebp)
  802480:	6a 00                	push   $0x0
  802482:	e8 16 e8 ff ff       	call   800c9d <sys_page_unmap>
  802487:	83 c4 10             	add    $0x10,%esp
  80248a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80248c:	89 d0                	mov    %edx,%eax
  80248e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802491:	5b                   	pop    %ebx
  802492:	5e                   	pop    %esi
  802493:	5d                   	pop    %ebp
  802494:	c3                   	ret    

00802495 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802495:	55                   	push   %ebp
  802496:	89 e5                	mov    %esp,%ebp
  802498:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80249b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80249e:	50                   	push   %eax
  80249f:	ff 75 08             	pushl  0x8(%ebp)
  8024a2:	e8 36 ef ff ff       	call   8013dd <fd_lookup>
  8024a7:	83 c4 10             	add    $0x10,%esp
  8024aa:	85 c0                	test   %eax,%eax
  8024ac:	78 18                	js     8024c6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8024ae:	83 ec 0c             	sub    $0xc,%esp
  8024b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8024b4:	e8 be ee ff ff       	call   801377 <fd2data>
	return _pipeisclosed(fd, p);
  8024b9:	89 c2                	mov    %eax,%edx
  8024bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024be:	e8 18 fd ff ff       	call   8021db <_pipeisclosed>
  8024c3:	83 c4 10             	add    $0x10,%esp
}
  8024c6:	c9                   	leave  
  8024c7:	c3                   	ret    

008024c8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8024c8:	55                   	push   %ebp
  8024c9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8024cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8024d0:	5d                   	pop    %ebp
  8024d1:	c3                   	ret    

008024d2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8024d2:	55                   	push   %ebp
  8024d3:	89 e5                	mov    %esp,%ebp
  8024d5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8024d8:	68 2b 31 80 00       	push   $0x80312b
  8024dd:	ff 75 0c             	pushl  0xc(%ebp)
  8024e0:	e8 30 e3 ff ff       	call   800815 <strcpy>
	return 0;
}
  8024e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8024ea:	c9                   	leave  
  8024eb:	c3                   	ret    

008024ec <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8024ec:	55                   	push   %ebp
  8024ed:	89 e5                	mov    %esp,%ebp
  8024ef:	57                   	push   %edi
  8024f0:	56                   	push   %esi
  8024f1:	53                   	push   %ebx
  8024f2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024f8:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8024fd:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802503:	eb 2d                	jmp    802532 <devcons_write+0x46>
		m = n - tot;
  802505:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802508:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80250a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80250d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802512:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802515:	83 ec 04             	sub    $0x4,%esp
  802518:	53                   	push   %ebx
  802519:	03 45 0c             	add    0xc(%ebp),%eax
  80251c:	50                   	push   %eax
  80251d:	57                   	push   %edi
  80251e:	e8 84 e4 ff ff       	call   8009a7 <memmove>
		sys_cputs(buf, m);
  802523:	83 c4 08             	add    $0x8,%esp
  802526:	53                   	push   %ebx
  802527:	57                   	push   %edi
  802528:	e8 2f e6 ff ff       	call   800b5c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80252d:	01 de                	add    %ebx,%esi
  80252f:	83 c4 10             	add    $0x10,%esp
  802532:	89 f0                	mov    %esi,%eax
  802534:	3b 75 10             	cmp    0x10(%ebp),%esi
  802537:	72 cc                	jb     802505 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802539:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80253c:	5b                   	pop    %ebx
  80253d:	5e                   	pop    %esi
  80253e:	5f                   	pop    %edi
  80253f:	5d                   	pop    %ebp
  802540:	c3                   	ret    

00802541 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802541:	55                   	push   %ebp
  802542:	89 e5                	mov    %esp,%ebp
  802544:	83 ec 08             	sub    $0x8,%esp
  802547:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80254c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802550:	74 2a                	je     80257c <devcons_read+0x3b>
  802552:	eb 05                	jmp    802559 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802554:	e8 a0 e6 ff ff       	call   800bf9 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802559:	e8 1c e6 ff ff       	call   800b7a <sys_cgetc>
  80255e:	85 c0                	test   %eax,%eax
  802560:	74 f2                	je     802554 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802562:	85 c0                	test   %eax,%eax
  802564:	78 16                	js     80257c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802566:	83 f8 04             	cmp    $0x4,%eax
  802569:	74 0c                	je     802577 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80256b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80256e:	88 02                	mov    %al,(%edx)
	return 1;
  802570:	b8 01 00 00 00       	mov    $0x1,%eax
  802575:	eb 05                	jmp    80257c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802577:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80257c:	c9                   	leave  
  80257d:	c3                   	ret    

0080257e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80257e:	55                   	push   %ebp
  80257f:	89 e5                	mov    %esp,%ebp
  802581:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802584:	8b 45 08             	mov    0x8(%ebp),%eax
  802587:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80258a:	6a 01                	push   $0x1
  80258c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80258f:	50                   	push   %eax
  802590:	e8 c7 e5 ff ff       	call   800b5c <sys_cputs>
}
  802595:	83 c4 10             	add    $0x10,%esp
  802598:	c9                   	leave  
  802599:	c3                   	ret    

0080259a <getchar>:

int
getchar(void)
{
  80259a:	55                   	push   %ebp
  80259b:	89 e5                	mov    %esp,%ebp
  80259d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8025a0:	6a 01                	push   $0x1
  8025a2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8025a5:	50                   	push   %eax
  8025a6:	6a 00                	push   $0x0
  8025a8:	e8 99 f0 ff ff       	call   801646 <read>
	if (r < 0)
  8025ad:	83 c4 10             	add    $0x10,%esp
  8025b0:	85 c0                	test   %eax,%eax
  8025b2:	78 0f                	js     8025c3 <getchar+0x29>
		return r;
	if (r < 1)
  8025b4:	85 c0                	test   %eax,%eax
  8025b6:	7e 06                	jle    8025be <getchar+0x24>
		return -E_EOF;
	return c;
  8025b8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8025bc:	eb 05                	jmp    8025c3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8025be:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8025c3:	c9                   	leave  
  8025c4:	c3                   	ret    

008025c5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8025c5:	55                   	push   %ebp
  8025c6:	89 e5                	mov    %esp,%ebp
  8025c8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025ce:	50                   	push   %eax
  8025cf:	ff 75 08             	pushl  0x8(%ebp)
  8025d2:	e8 06 ee ff ff       	call   8013dd <fd_lookup>
  8025d7:	83 c4 10             	add    $0x10,%esp
  8025da:	85 c0                	test   %eax,%eax
  8025dc:	78 11                	js     8025ef <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8025de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025e1:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8025e7:	39 10                	cmp    %edx,(%eax)
  8025e9:	0f 94 c0             	sete   %al
  8025ec:	0f b6 c0             	movzbl %al,%eax
}
  8025ef:	c9                   	leave  
  8025f0:	c3                   	ret    

008025f1 <opencons>:

int
opencons(void)
{
  8025f1:	55                   	push   %ebp
  8025f2:	89 e5                	mov    %esp,%ebp
  8025f4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8025f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025fa:	50                   	push   %eax
  8025fb:	e8 8e ed ff ff       	call   80138e <fd_alloc>
  802600:	83 c4 10             	add    $0x10,%esp
		return r;
  802603:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802605:	85 c0                	test   %eax,%eax
  802607:	78 3e                	js     802647 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802609:	83 ec 04             	sub    $0x4,%esp
  80260c:	68 07 04 00 00       	push   $0x407
  802611:	ff 75 f4             	pushl  -0xc(%ebp)
  802614:	6a 00                	push   $0x0
  802616:	e8 fd e5 ff ff       	call   800c18 <sys_page_alloc>
  80261b:	83 c4 10             	add    $0x10,%esp
		return r;
  80261e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802620:	85 c0                	test   %eax,%eax
  802622:	78 23                	js     802647 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802624:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80262a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80262d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80262f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802632:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802639:	83 ec 0c             	sub    $0xc,%esp
  80263c:	50                   	push   %eax
  80263d:	e8 25 ed ff ff       	call   801367 <fd2num>
  802642:	89 c2                	mov    %eax,%edx
  802644:	83 c4 10             	add    $0x10,%esp
}
  802647:	89 d0                	mov    %edx,%eax
  802649:	c9                   	leave  
  80264a:	c3                   	ret    

0080264b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80264b:	55                   	push   %ebp
  80264c:	89 e5                	mov    %esp,%ebp
  80264e:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802651:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802658:	75 2a                	jne    802684 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  80265a:	83 ec 04             	sub    $0x4,%esp
  80265d:	6a 07                	push   $0x7
  80265f:	68 00 f0 bf ee       	push   $0xeebff000
  802664:	6a 00                	push   $0x0
  802666:	e8 ad e5 ff ff       	call   800c18 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  80266b:	83 c4 10             	add    $0x10,%esp
  80266e:	85 c0                	test   %eax,%eax
  802670:	79 12                	jns    802684 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802672:	50                   	push   %eax
  802673:	68 92 2f 80 00       	push   $0x802f92
  802678:	6a 23                	push   $0x23
  80267a:	68 37 31 80 00       	push   $0x803137
  80267f:	e8 33 db ff ff       	call   8001b7 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802684:	8b 45 08             	mov    0x8(%ebp),%eax
  802687:	a3 00 70 80 00       	mov    %eax,0x807000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80268c:	83 ec 08             	sub    $0x8,%esp
  80268f:	68 b6 26 80 00       	push   $0x8026b6
  802694:	6a 00                	push   $0x0
  802696:	e8 c8 e6 ff ff       	call   800d63 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  80269b:	83 c4 10             	add    $0x10,%esp
  80269e:	85 c0                	test   %eax,%eax
  8026a0:	79 12                	jns    8026b4 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8026a2:	50                   	push   %eax
  8026a3:	68 92 2f 80 00       	push   $0x802f92
  8026a8:	6a 2c                	push   $0x2c
  8026aa:	68 37 31 80 00       	push   $0x803137
  8026af:	e8 03 db ff ff       	call   8001b7 <_panic>
	}
}
  8026b4:	c9                   	leave  
  8026b5:	c3                   	ret    

008026b6 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8026b6:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8026b7:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8026bc:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8026be:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8026c1:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8026c5:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8026ca:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8026ce:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8026d0:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8026d3:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8026d4:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8026d7:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8026d8:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8026d9:	c3                   	ret    

008026da <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8026da:	55                   	push   %ebp
  8026db:	89 e5                	mov    %esp,%ebp
  8026dd:	56                   	push   %esi
  8026de:	53                   	push   %ebx
  8026df:	8b 75 08             	mov    0x8(%ebp),%esi
  8026e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8026e8:	85 c0                	test   %eax,%eax
  8026ea:	75 12                	jne    8026fe <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8026ec:	83 ec 0c             	sub    $0xc,%esp
  8026ef:	68 00 00 c0 ee       	push   $0xeec00000
  8026f4:	e8 cf e6 ff ff       	call   800dc8 <sys_ipc_recv>
  8026f9:	83 c4 10             	add    $0x10,%esp
  8026fc:	eb 0c                	jmp    80270a <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8026fe:	83 ec 0c             	sub    $0xc,%esp
  802701:	50                   	push   %eax
  802702:	e8 c1 e6 ff ff       	call   800dc8 <sys_ipc_recv>
  802707:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80270a:	85 f6                	test   %esi,%esi
  80270c:	0f 95 c1             	setne  %cl
  80270f:	85 db                	test   %ebx,%ebx
  802711:	0f 95 c2             	setne  %dl
  802714:	84 d1                	test   %dl,%cl
  802716:	74 09                	je     802721 <ipc_recv+0x47>
  802718:	89 c2                	mov    %eax,%edx
  80271a:	c1 ea 1f             	shr    $0x1f,%edx
  80271d:	84 d2                	test   %dl,%dl
  80271f:	75 2d                	jne    80274e <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802721:	85 f6                	test   %esi,%esi
  802723:	74 0d                	je     802732 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802725:	a1 04 50 80 00       	mov    0x805004,%eax
  80272a:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  802730:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802732:	85 db                	test   %ebx,%ebx
  802734:	74 0d                	je     802743 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802736:	a1 04 50 80 00       	mov    0x805004,%eax
  80273b:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802741:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802743:	a1 04 50 80 00       	mov    0x805004,%eax
  802748:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  80274e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802751:	5b                   	pop    %ebx
  802752:	5e                   	pop    %esi
  802753:	5d                   	pop    %ebp
  802754:	c3                   	ret    

00802755 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802755:	55                   	push   %ebp
  802756:	89 e5                	mov    %esp,%ebp
  802758:	57                   	push   %edi
  802759:	56                   	push   %esi
  80275a:	53                   	push   %ebx
  80275b:	83 ec 0c             	sub    $0xc,%esp
  80275e:	8b 7d 08             	mov    0x8(%ebp),%edi
  802761:	8b 75 0c             	mov    0xc(%ebp),%esi
  802764:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802767:	85 db                	test   %ebx,%ebx
  802769:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80276e:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802771:	ff 75 14             	pushl  0x14(%ebp)
  802774:	53                   	push   %ebx
  802775:	56                   	push   %esi
  802776:	57                   	push   %edi
  802777:	e8 29 e6 ff ff       	call   800da5 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80277c:	89 c2                	mov    %eax,%edx
  80277e:	c1 ea 1f             	shr    $0x1f,%edx
  802781:	83 c4 10             	add    $0x10,%esp
  802784:	84 d2                	test   %dl,%dl
  802786:	74 17                	je     80279f <ipc_send+0x4a>
  802788:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80278b:	74 12                	je     80279f <ipc_send+0x4a>
			panic("failed ipc %e", r);
  80278d:	50                   	push   %eax
  80278e:	68 45 31 80 00       	push   $0x803145
  802793:	6a 47                	push   $0x47
  802795:	68 53 31 80 00       	push   $0x803153
  80279a:	e8 18 da ff ff       	call   8001b7 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80279f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8027a2:	75 07                	jne    8027ab <ipc_send+0x56>
			sys_yield();
  8027a4:	e8 50 e4 ff ff       	call   800bf9 <sys_yield>
  8027a9:	eb c6                	jmp    802771 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8027ab:	85 c0                	test   %eax,%eax
  8027ad:	75 c2                	jne    802771 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8027af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027b2:	5b                   	pop    %ebx
  8027b3:	5e                   	pop    %esi
  8027b4:	5f                   	pop    %edi
  8027b5:	5d                   	pop    %ebp
  8027b6:	c3                   	ret    

008027b7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8027b7:	55                   	push   %ebp
  8027b8:	89 e5                	mov    %esp,%ebp
  8027ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8027bd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8027c2:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  8027c8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8027ce:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  8027d4:	39 ca                	cmp    %ecx,%edx
  8027d6:	75 13                	jne    8027eb <ipc_find_env+0x34>
			return envs[i].env_id;
  8027d8:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8027de:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8027e3:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8027e9:	eb 0f                	jmp    8027fa <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8027eb:	83 c0 01             	add    $0x1,%eax
  8027ee:	3d 00 04 00 00       	cmp    $0x400,%eax
  8027f3:	75 cd                	jne    8027c2 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8027f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8027fa:	5d                   	pop    %ebp
  8027fb:	c3                   	ret    

008027fc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8027fc:	55                   	push   %ebp
  8027fd:	89 e5                	mov    %esp,%ebp
  8027ff:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802802:	89 d0                	mov    %edx,%eax
  802804:	c1 e8 16             	shr    $0x16,%eax
  802807:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80280e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802813:	f6 c1 01             	test   $0x1,%cl
  802816:	74 1d                	je     802835 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802818:	c1 ea 0c             	shr    $0xc,%edx
  80281b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802822:	f6 c2 01             	test   $0x1,%dl
  802825:	74 0e                	je     802835 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802827:	c1 ea 0c             	shr    $0xc,%edx
  80282a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802831:	ef 
  802832:	0f b7 c0             	movzwl %ax,%eax
}
  802835:	5d                   	pop    %ebp
  802836:	c3                   	ret    
  802837:	66 90                	xchg   %ax,%ax
  802839:	66 90                	xchg   %ax,%ax
  80283b:	66 90                	xchg   %ax,%ax
  80283d:	66 90                	xchg   %ax,%ax
  80283f:	90                   	nop

00802840 <__udivdi3>:
  802840:	55                   	push   %ebp
  802841:	57                   	push   %edi
  802842:	56                   	push   %esi
  802843:	53                   	push   %ebx
  802844:	83 ec 1c             	sub    $0x1c,%esp
  802847:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80284b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80284f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802853:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802857:	85 f6                	test   %esi,%esi
  802859:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80285d:	89 ca                	mov    %ecx,%edx
  80285f:	89 f8                	mov    %edi,%eax
  802861:	75 3d                	jne    8028a0 <__udivdi3+0x60>
  802863:	39 cf                	cmp    %ecx,%edi
  802865:	0f 87 c5 00 00 00    	ja     802930 <__udivdi3+0xf0>
  80286b:	85 ff                	test   %edi,%edi
  80286d:	89 fd                	mov    %edi,%ebp
  80286f:	75 0b                	jne    80287c <__udivdi3+0x3c>
  802871:	b8 01 00 00 00       	mov    $0x1,%eax
  802876:	31 d2                	xor    %edx,%edx
  802878:	f7 f7                	div    %edi
  80287a:	89 c5                	mov    %eax,%ebp
  80287c:	89 c8                	mov    %ecx,%eax
  80287e:	31 d2                	xor    %edx,%edx
  802880:	f7 f5                	div    %ebp
  802882:	89 c1                	mov    %eax,%ecx
  802884:	89 d8                	mov    %ebx,%eax
  802886:	89 cf                	mov    %ecx,%edi
  802888:	f7 f5                	div    %ebp
  80288a:	89 c3                	mov    %eax,%ebx
  80288c:	89 d8                	mov    %ebx,%eax
  80288e:	89 fa                	mov    %edi,%edx
  802890:	83 c4 1c             	add    $0x1c,%esp
  802893:	5b                   	pop    %ebx
  802894:	5e                   	pop    %esi
  802895:	5f                   	pop    %edi
  802896:	5d                   	pop    %ebp
  802897:	c3                   	ret    
  802898:	90                   	nop
  802899:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028a0:	39 ce                	cmp    %ecx,%esi
  8028a2:	77 74                	ja     802918 <__udivdi3+0xd8>
  8028a4:	0f bd fe             	bsr    %esi,%edi
  8028a7:	83 f7 1f             	xor    $0x1f,%edi
  8028aa:	0f 84 98 00 00 00    	je     802948 <__udivdi3+0x108>
  8028b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8028b5:	89 f9                	mov    %edi,%ecx
  8028b7:	89 c5                	mov    %eax,%ebp
  8028b9:	29 fb                	sub    %edi,%ebx
  8028bb:	d3 e6                	shl    %cl,%esi
  8028bd:	89 d9                	mov    %ebx,%ecx
  8028bf:	d3 ed                	shr    %cl,%ebp
  8028c1:	89 f9                	mov    %edi,%ecx
  8028c3:	d3 e0                	shl    %cl,%eax
  8028c5:	09 ee                	or     %ebp,%esi
  8028c7:	89 d9                	mov    %ebx,%ecx
  8028c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8028cd:	89 d5                	mov    %edx,%ebp
  8028cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8028d3:	d3 ed                	shr    %cl,%ebp
  8028d5:	89 f9                	mov    %edi,%ecx
  8028d7:	d3 e2                	shl    %cl,%edx
  8028d9:	89 d9                	mov    %ebx,%ecx
  8028db:	d3 e8                	shr    %cl,%eax
  8028dd:	09 c2                	or     %eax,%edx
  8028df:	89 d0                	mov    %edx,%eax
  8028e1:	89 ea                	mov    %ebp,%edx
  8028e3:	f7 f6                	div    %esi
  8028e5:	89 d5                	mov    %edx,%ebp
  8028e7:	89 c3                	mov    %eax,%ebx
  8028e9:	f7 64 24 0c          	mull   0xc(%esp)
  8028ed:	39 d5                	cmp    %edx,%ebp
  8028ef:	72 10                	jb     802901 <__udivdi3+0xc1>
  8028f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8028f5:	89 f9                	mov    %edi,%ecx
  8028f7:	d3 e6                	shl    %cl,%esi
  8028f9:	39 c6                	cmp    %eax,%esi
  8028fb:	73 07                	jae    802904 <__udivdi3+0xc4>
  8028fd:	39 d5                	cmp    %edx,%ebp
  8028ff:	75 03                	jne    802904 <__udivdi3+0xc4>
  802901:	83 eb 01             	sub    $0x1,%ebx
  802904:	31 ff                	xor    %edi,%edi
  802906:	89 d8                	mov    %ebx,%eax
  802908:	89 fa                	mov    %edi,%edx
  80290a:	83 c4 1c             	add    $0x1c,%esp
  80290d:	5b                   	pop    %ebx
  80290e:	5e                   	pop    %esi
  80290f:	5f                   	pop    %edi
  802910:	5d                   	pop    %ebp
  802911:	c3                   	ret    
  802912:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802918:	31 ff                	xor    %edi,%edi
  80291a:	31 db                	xor    %ebx,%ebx
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
  802930:	89 d8                	mov    %ebx,%eax
  802932:	f7 f7                	div    %edi
  802934:	31 ff                	xor    %edi,%edi
  802936:	89 c3                	mov    %eax,%ebx
  802938:	89 d8                	mov    %ebx,%eax
  80293a:	89 fa                	mov    %edi,%edx
  80293c:	83 c4 1c             	add    $0x1c,%esp
  80293f:	5b                   	pop    %ebx
  802940:	5e                   	pop    %esi
  802941:	5f                   	pop    %edi
  802942:	5d                   	pop    %ebp
  802943:	c3                   	ret    
  802944:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802948:	39 ce                	cmp    %ecx,%esi
  80294a:	72 0c                	jb     802958 <__udivdi3+0x118>
  80294c:	31 db                	xor    %ebx,%ebx
  80294e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802952:	0f 87 34 ff ff ff    	ja     80288c <__udivdi3+0x4c>
  802958:	bb 01 00 00 00       	mov    $0x1,%ebx
  80295d:	e9 2a ff ff ff       	jmp    80288c <__udivdi3+0x4c>
  802962:	66 90                	xchg   %ax,%ax
  802964:	66 90                	xchg   %ax,%ax
  802966:	66 90                	xchg   %ax,%ax
  802968:	66 90                	xchg   %ax,%ax
  80296a:	66 90                	xchg   %ax,%ax
  80296c:	66 90                	xchg   %ax,%ax
  80296e:	66 90                	xchg   %ax,%ax

00802970 <__umoddi3>:
  802970:	55                   	push   %ebp
  802971:	57                   	push   %edi
  802972:	56                   	push   %esi
  802973:	53                   	push   %ebx
  802974:	83 ec 1c             	sub    $0x1c,%esp
  802977:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80297b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80297f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802983:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802987:	85 d2                	test   %edx,%edx
  802989:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80298d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802991:	89 f3                	mov    %esi,%ebx
  802993:	89 3c 24             	mov    %edi,(%esp)
  802996:	89 74 24 04          	mov    %esi,0x4(%esp)
  80299a:	75 1c                	jne    8029b8 <__umoddi3+0x48>
  80299c:	39 f7                	cmp    %esi,%edi
  80299e:	76 50                	jbe    8029f0 <__umoddi3+0x80>
  8029a0:	89 c8                	mov    %ecx,%eax
  8029a2:	89 f2                	mov    %esi,%edx
  8029a4:	f7 f7                	div    %edi
  8029a6:	89 d0                	mov    %edx,%eax
  8029a8:	31 d2                	xor    %edx,%edx
  8029aa:	83 c4 1c             	add    $0x1c,%esp
  8029ad:	5b                   	pop    %ebx
  8029ae:	5e                   	pop    %esi
  8029af:	5f                   	pop    %edi
  8029b0:	5d                   	pop    %ebp
  8029b1:	c3                   	ret    
  8029b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8029b8:	39 f2                	cmp    %esi,%edx
  8029ba:	89 d0                	mov    %edx,%eax
  8029bc:	77 52                	ja     802a10 <__umoddi3+0xa0>
  8029be:	0f bd ea             	bsr    %edx,%ebp
  8029c1:	83 f5 1f             	xor    $0x1f,%ebp
  8029c4:	75 5a                	jne    802a20 <__umoddi3+0xb0>
  8029c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8029ca:	0f 82 e0 00 00 00    	jb     802ab0 <__umoddi3+0x140>
  8029d0:	39 0c 24             	cmp    %ecx,(%esp)
  8029d3:	0f 86 d7 00 00 00    	jbe    802ab0 <__umoddi3+0x140>
  8029d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8029dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8029e1:	83 c4 1c             	add    $0x1c,%esp
  8029e4:	5b                   	pop    %ebx
  8029e5:	5e                   	pop    %esi
  8029e6:	5f                   	pop    %edi
  8029e7:	5d                   	pop    %ebp
  8029e8:	c3                   	ret    
  8029e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8029f0:	85 ff                	test   %edi,%edi
  8029f2:	89 fd                	mov    %edi,%ebp
  8029f4:	75 0b                	jne    802a01 <__umoddi3+0x91>
  8029f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8029fb:	31 d2                	xor    %edx,%edx
  8029fd:	f7 f7                	div    %edi
  8029ff:	89 c5                	mov    %eax,%ebp
  802a01:	89 f0                	mov    %esi,%eax
  802a03:	31 d2                	xor    %edx,%edx
  802a05:	f7 f5                	div    %ebp
  802a07:	89 c8                	mov    %ecx,%eax
  802a09:	f7 f5                	div    %ebp
  802a0b:	89 d0                	mov    %edx,%eax
  802a0d:	eb 99                	jmp    8029a8 <__umoddi3+0x38>
  802a0f:	90                   	nop
  802a10:	89 c8                	mov    %ecx,%eax
  802a12:	89 f2                	mov    %esi,%edx
  802a14:	83 c4 1c             	add    $0x1c,%esp
  802a17:	5b                   	pop    %ebx
  802a18:	5e                   	pop    %esi
  802a19:	5f                   	pop    %edi
  802a1a:	5d                   	pop    %ebp
  802a1b:	c3                   	ret    
  802a1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a20:	8b 34 24             	mov    (%esp),%esi
  802a23:	bf 20 00 00 00       	mov    $0x20,%edi
  802a28:	89 e9                	mov    %ebp,%ecx
  802a2a:	29 ef                	sub    %ebp,%edi
  802a2c:	d3 e0                	shl    %cl,%eax
  802a2e:	89 f9                	mov    %edi,%ecx
  802a30:	89 f2                	mov    %esi,%edx
  802a32:	d3 ea                	shr    %cl,%edx
  802a34:	89 e9                	mov    %ebp,%ecx
  802a36:	09 c2                	or     %eax,%edx
  802a38:	89 d8                	mov    %ebx,%eax
  802a3a:	89 14 24             	mov    %edx,(%esp)
  802a3d:	89 f2                	mov    %esi,%edx
  802a3f:	d3 e2                	shl    %cl,%edx
  802a41:	89 f9                	mov    %edi,%ecx
  802a43:	89 54 24 04          	mov    %edx,0x4(%esp)
  802a47:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802a4b:	d3 e8                	shr    %cl,%eax
  802a4d:	89 e9                	mov    %ebp,%ecx
  802a4f:	89 c6                	mov    %eax,%esi
  802a51:	d3 e3                	shl    %cl,%ebx
  802a53:	89 f9                	mov    %edi,%ecx
  802a55:	89 d0                	mov    %edx,%eax
  802a57:	d3 e8                	shr    %cl,%eax
  802a59:	89 e9                	mov    %ebp,%ecx
  802a5b:	09 d8                	or     %ebx,%eax
  802a5d:	89 d3                	mov    %edx,%ebx
  802a5f:	89 f2                	mov    %esi,%edx
  802a61:	f7 34 24             	divl   (%esp)
  802a64:	89 d6                	mov    %edx,%esi
  802a66:	d3 e3                	shl    %cl,%ebx
  802a68:	f7 64 24 04          	mull   0x4(%esp)
  802a6c:	39 d6                	cmp    %edx,%esi
  802a6e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802a72:	89 d1                	mov    %edx,%ecx
  802a74:	89 c3                	mov    %eax,%ebx
  802a76:	72 08                	jb     802a80 <__umoddi3+0x110>
  802a78:	75 11                	jne    802a8b <__umoddi3+0x11b>
  802a7a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802a7e:	73 0b                	jae    802a8b <__umoddi3+0x11b>
  802a80:	2b 44 24 04          	sub    0x4(%esp),%eax
  802a84:	1b 14 24             	sbb    (%esp),%edx
  802a87:	89 d1                	mov    %edx,%ecx
  802a89:	89 c3                	mov    %eax,%ebx
  802a8b:	8b 54 24 08          	mov    0x8(%esp),%edx
  802a8f:	29 da                	sub    %ebx,%edx
  802a91:	19 ce                	sbb    %ecx,%esi
  802a93:	89 f9                	mov    %edi,%ecx
  802a95:	89 f0                	mov    %esi,%eax
  802a97:	d3 e0                	shl    %cl,%eax
  802a99:	89 e9                	mov    %ebp,%ecx
  802a9b:	d3 ea                	shr    %cl,%edx
  802a9d:	89 e9                	mov    %ebp,%ecx
  802a9f:	d3 ee                	shr    %cl,%esi
  802aa1:	09 d0                	or     %edx,%eax
  802aa3:	89 f2                	mov    %esi,%edx
  802aa5:	83 c4 1c             	add    $0x1c,%esp
  802aa8:	5b                   	pop    %ebx
  802aa9:	5e                   	pop    %esi
  802aaa:	5f                   	pop    %edi
  802aab:	5d                   	pop    %ebp
  802aac:	c3                   	ret    
  802aad:	8d 76 00             	lea    0x0(%esi),%esi
  802ab0:	29 f9                	sub    %edi,%ecx
  802ab2:	19 d6                	sbb    %edx,%esi
  802ab4:	89 74 24 04          	mov    %esi,0x4(%esp)
  802ab8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802abc:	e9 18 ff ff ff       	jmp    8029d9 <__umoddi3+0x69>
