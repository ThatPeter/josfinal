
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
  80003e:	c7 05 00 30 80 00 80 	movl   $0x802880,0x803000
  800045:	28 80 00 

	cprintf("icode startup\n");
  800048:	68 86 28 80 00       	push   $0x802886
  80004d:	e8 3f 02 00 00       	call   800291 <cprintf>

	cprintf("icode: open /motd\n");
  800052:	c7 04 24 95 28 80 00 	movl   $0x802895,(%esp)
  800059:	e8 33 02 00 00       	call   800291 <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005e:	83 c4 08             	add    $0x8,%esp
  800061:	6a 00                	push   $0x0
  800063:	68 a8 28 80 00       	push   $0x8028a8
  800068:	e8 36 18 00 00       	call   8018a3 <open>
  80006d:	89 c6                	mov    %eax,%esi
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	85 c0                	test   %eax,%eax
  800074:	79 12                	jns    800088 <umain+0x55>
		panic("icode: open /motd: %e", fd);
  800076:	50                   	push   %eax
  800077:	68 ae 28 80 00       	push   $0x8028ae
  80007c:	6a 0f                	push   $0xf
  80007e:	68 c4 28 80 00       	push   $0x8028c4
  800083:	e8 30 01 00 00       	call   8001b8 <_panic>

	cprintf("icode: read /motd\n");
  800088:	83 ec 0c             	sub    $0xc,%esp
  80008b:	68 d1 28 80 00       	push   $0x8028d1
  800090:	e8 fc 01 00 00       	call   800291 <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  80009e:	eb 0d                	jmp    8000ad <umain+0x7a>
		sys_cputs(buf, n);
  8000a0:	83 ec 08             	sub    $0x8,%esp
  8000a3:	50                   	push   %eax
  8000a4:	53                   	push   %ebx
  8000a5:	e8 b3 0a 00 00       	call   800b5d <sys_cputs>
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
  8000b7:	e8 5c 13 00 00       	call   801418 <read>
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	7f dd                	jg     8000a0 <umain+0x6d>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	68 e4 28 80 00       	push   $0x8028e4
  8000cb:	e8 c1 01 00 00       	call   800291 <cprintf>
	close(fd);
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 04 12 00 00       	call   8012dc <close>

	cprintf("icode: spawn /init\n");
  8000d8:	c7 04 24 f8 28 80 00 	movl   $0x8028f8,(%esp)
  8000df:	e8 ad 01 00 00       	call   800291 <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000eb:	68 0c 29 80 00       	push   $0x80290c
  8000f0:	68 15 29 80 00       	push   $0x802915
  8000f5:	68 1f 29 80 00       	push   $0x80291f
  8000fa:	68 1e 29 80 00       	push   $0x80291e
  8000ff:	e8 b2 1d 00 00       	call   801eb6 <spawnl>
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	85 c0                	test   %eax,%eax
  800109:	79 12                	jns    80011d <umain+0xea>
		panic("icode: spawn /init: %e", r);
  80010b:	50                   	push   %eax
  80010c:	68 24 29 80 00       	push   $0x802924
  800111:	6a 1a                	push   $0x1a
  800113:	68 c4 28 80 00       	push   $0x8028c4
  800118:	e8 9b 00 00 00       	call   8001b8 <_panic>

	cprintf("icode: exiting\n");
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	68 3b 29 80 00       	push   $0x80293b
  800125:	e8 67 01 00 00       	call   800291 <cprintf>
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
  80013f:	e8 97 0a 00 00       	call   800bdb <sys_getenvid>
  800144:	25 ff 03 00 00       	and    $0x3ff,%eax
  800149:	89 c2                	mov    %eax,%edx
  80014b:	c1 e2 07             	shl    $0x7,%edx
  80014e:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800155:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80015a:	85 db                	test   %ebx,%ebx
  80015c:	7e 07                	jle    800165 <libmain+0x31>
		binaryname = argv[0];
  80015e:	8b 06                	mov    (%esi),%eax
  800160:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800165:	83 ec 08             	sub    $0x8,%esp
  800168:	56                   	push   %esi
  800169:	53                   	push   %ebx
  80016a:	e8 c4 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80016f:	e8 2a 00 00 00       	call   80019e <exit>
}
  800174:	83 c4 10             	add    $0x10,%esp
  800177:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80017a:	5b                   	pop    %ebx
  80017b:	5e                   	pop    %esi
  80017c:	5d                   	pop    %ebp
  80017d:	c3                   	ret    

0080017e <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  80017e:	55                   	push   %ebp
  80017f:	89 e5                	mov    %esp,%ebp
  800181:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  800184:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  800189:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  80018b:	e8 4b 0a 00 00       	call   800bdb <sys_getenvid>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	50                   	push   %eax
  800194:	e8 91 0c 00 00       	call   800e2a <sys_thread_free>
}
  800199:	83 c4 10             	add    $0x10,%esp
  80019c:	c9                   	leave  
  80019d:	c3                   	ret    

0080019e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001a4:	e8 5e 11 00 00       	call   801307 <close_all>
	sys_env_destroy(0);
  8001a9:	83 ec 0c             	sub    $0xc,%esp
  8001ac:	6a 00                	push   $0x0
  8001ae:	e8 e7 09 00 00       	call   800b9a <sys_env_destroy>
}
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	c9                   	leave  
  8001b7:	c3                   	ret    

008001b8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001bd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001c0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001c6:	e8 10 0a 00 00       	call   800bdb <sys_getenvid>
  8001cb:	83 ec 0c             	sub    $0xc,%esp
  8001ce:	ff 75 0c             	pushl  0xc(%ebp)
  8001d1:	ff 75 08             	pushl  0x8(%ebp)
  8001d4:	56                   	push   %esi
  8001d5:	50                   	push   %eax
  8001d6:	68 58 29 80 00       	push   $0x802958
  8001db:	e8 b1 00 00 00       	call   800291 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001e0:	83 c4 18             	add    $0x18,%esp
  8001e3:	53                   	push   %ebx
  8001e4:	ff 75 10             	pushl  0x10(%ebp)
  8001e7:	e8 54 00 00 00       	call   800240 <vcprintf>
	cprintf("\n");
  8001ec:	c7 04 24 b4 2e 80 00 	movl   $0x802eb4,(%esp)
  8001f3:	e8 99 00 00 00       	call   800291 <cprintf>
  8001f8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001fb:	cc                   	int3   
  8001fc:	eb fd                	jmp    8001fb <_panic+0x43>

008001fe <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	53                   	push   %ebx
  800202:	83 ec 04             	sub    $0x4,%esp
  800205:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800208:	8b 13                	mov    (%ebx),%edx
  80020a:	8d 42 01             	lea    0x1(%edx),%eax
  80020d:	89 03                	mov    %eax,(%ebx)
  80020f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800212:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800216:	3d ff 00 00 00       	cmp    $0xff,%eax
  80021b:	75 1a                	jne    800237 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80021d:	83 ec 08             	sub    $0x8,%esp
  800220:	68 ff 00 00 00       	push   $0xff
  800225:	8d 43 08             	lea    0x8(%ebx),%eax
  800228:	50                   	push   %eax
  800229:	e8 2f 09 00 00       	call   800b5d <sys_cputs>
		b->idx = 0;
  80022e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800234:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800237:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80023b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800249:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800250:	00 00 00 
	b.cnt = 0;
  800253:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80025a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80025d:	ff 75 0c             	pushl  0xc(%ebp)
  800260:	ff 75 08             	pushl  0x8(%ebp)
  800263:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800269:	50                   	push   %eax
  80026a:	68 fe 01 80 00       	push   $0x8001fe
  80026f:	e8 54 01 00 00       	call   8003c8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800274:	83 c4 08             	add    $0x8,%esp
  800277:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80027d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800283:	50                   	push   %eax
  800284:	e8 d4 08 00 00       	call   800b5d <sys_cputs>

	return b.cnt;
}
  800289:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028f:	c9                   	leave  
  800290:	c3                   	ret    

00800291 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800297:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80029a:	50                   	push   %eax
  80029b:	ff 75 08             	pushl  0x8(%ebp)
  80029e:	e8 9d ff ff ff       	call   800240 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a3:	c9                   	leave  
  8002a4:	c3                   	ret    

008002a5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 1c             	sub    $0x1c,%esp
  8002ae:	89 c7                	mov    %eax,%edi
  8002b0:	89 d6                	mov    %edx,%esi
  8002b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002bb:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002be:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002c9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002cc:	39 d3                	cmp    %edx,%ebx
  8002ce:	72 05                	jb     8002d5 <printnum+0x30>
  8002d0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002d3:	77 45                	ja     80031a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d5:	83 ec 0c             	sub    $0xc,%esp
  8002d8:	ff 75 18             	pushl  0x18(%ebp)
  8002db:	8b 45 14             	mov    0x14(%ebp),%eax
  8002de:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002e1:	53                   	push   %ebx
  8002e2:	ff 75 10             	pushl  0x10(%ebp)
  8002e5:	83 ec 08             	sub    $0x8,%esp
  8002e8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ee:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f4:	e8 f7 22 00 00       	call   8025f0 <__udivdi3>
  8002f9:	83 c4 18             	add    $0x18,%esp
  8002fc:	52                   	push   %edx
  8002fd:	50                   	push   %eax
  8002fe:	89 f2                	mov    %esi,%edx
  800300:	89 f8                	mov    %edi,%eax
  800302:	e8 9e ff ff ff       	call   8002a5 <printnum>
  800307:	83 c4 20             	add    $0x20,%esp
  80030a:	eb 18                	jmp    800324 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80030c:	83 ec 08             	sub    $0x8,%esp
  80030f:	56                   	push   %esi
  800310:	ff 75 18             	pushl  0x18(%ebp)
  800313:	ff d7                	call   *%edi
  800315:	83 c4 10             	add    $0x10,%esp
  800318:	eb 03                	jmp    80031d <printnum+0x78>
  80031a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80031d:	83 eb 01             	sub    $0x1,%ebx
  800320:	85 db                	test   %ebx,%ebx
  800322:	7f e8                	jg     80030c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800324:	83 ec 08             	sub    $0x8,%esp
  800327:	56                   	push   %esi
  800328:	83 ec 04             	sub    $0x4,%esp
  80032b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80032e:	ff 75 e0             	pushl  -0x20(%ebp)
  800331:	ff 75 dc             	pushl  -0x24(%ebp)
  800334:	ff 75 d8             	pushl  -0x28(%ebp)
  800337:	e8 e4 23 00 00       	call   802720 <__umoddi3>
  80033c:	83 c4 14             	add    $0x14,%esp
  80033f:	0f be 80 7b 29 80 00 	movsbl 0x80297b(%eax),%eax
  800346:	50                   	push   %eax
  800347:	ff d7                	call   *%edi
}
  800349:	83 c4 10             	add    $0x10,%esp
  80034c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034f:	5b                   	pop    %ebx
  800350:	5e                   	pop    %esi
  800351:	5f                   	pop    %edi
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800357:	83 fa 01             	cmp    $0x1,%edx
  80035a:	7e 0e                	jle    80036a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80035c:	8b 10                	mov    (%eax),%edx
  80035e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800361:	89 08                	mov    %ecx,(%eax)
  800363:	8b 02                	mov    (%edx),%eax
  800365:	8b 52 04             	mov    0x4(%edx),%edx
  800368:	eb 22                	jmp    80038c <getuint+0x38>
	else if (lflag)
  80036a:	85 d2                	test   %edx,%edx
  80036c:	74 10                	je     80037e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80036e:	8b 10                	mov    (%eax),%edx
  800370:	8d 4a 04             	lea    0x4(%edx),%ecx
  800373:	89 08                	mov    %ecx,(%eax)
  800375:	8b 02                	mov    (%edx),%eax
  800377:	ba 00 00 00 00       	mov    $0x0,%edx
  80037c:	eb 0e                	jmp    80038c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80037e:	8b 10                	mov    (%eax),%edx
  800380:	8d 4a 04             	lea    0x4(%edx),%ecx
  800383:	89 08                	mov    %ecx,(%eax)
  800385:	8b 02                	mov    (%edx),%eax
  800387:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80038c:	5d                   	pop    %ebp
  80038d:	c3                   	ret    

0080038e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800394:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800398:	8b 10                	mov    (%eax),%edx
  80039a:	3b 50 04             	cmp    0x4(%eax),%edx
  80039d:	73 0a                	jae    8003a9 <sprintputch+0x1b>
		*b->buf++ = ch;
  80039f:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003a2:	89 08                	mov    %ecx,(%eax)
  8003a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a7:	88 02                	mov    %al,(%edx)
}
  8003a9:	5d                   	pop    %ebp
  8003aa:	c3                   	ret    

008003ab <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003ab:	55                   	push   %ebp
  8003ac:	89 e5                	mov    %esp,%ebp
  8003ae:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003b1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003b4:	50                   	push   %eax
  8003b5:	ff 75 10             	pushl  0x10(%ebp)
  8003b8:	ff 75 0c             	pushl  0xc(%ebp)
  8003bb:	ff 75 08             	pushl  0x8(%ebp)
  8003be:	e8 05 00 00 00       	call   8003c8 <vprintfmt>
	va_end(ap);
}
  8003c3:	83 c4 10             	add    $0x10,%esp
  8003c6:	c9                   	leave  
  8003c7:	c3                   	ret    

008003c8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c8:	55                   	push   %ebp
  8003c9:	89 e5                	mov    %esp,%ebp
  8003cb:	57                   	push   %edi
  8003cc:	56                   	push   %esi
  8003cd:	53                   	push   %ebx
  8003ce:	83 ec 2c             	sub    $0x2c,%esp
  8003d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8003d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003d7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003da:	eb 12                	jmp    8003ee <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003dc:	85 c0                	test   %eax,%eax
  8003de:	0f 84 89 03 00 00    	je     80076d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003e4:	83 ec 08             	sub    $0x8,%esp
  8003e7:	53                   	push   %ebx
  8003e8:	50                   	push   %eax
  8003e9:	ff d6                	call   *%esi
  8003eb:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ee:	83 c7 01             	add    $0x1,%edi
  8003f1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003f5:	83 f8 25             	cmp    $0x25,%eax
  8003f8:	75 e2                	jne    8003dc <vprintfmt+0x14>
  8003fa:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003fe:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800405:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80040c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800413:	ba 00 00 00 00       	mov    $0x0,%edx
  800418:	eb 07                	jmp    800421 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80041d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800421:	8d 47 01             	lea    0x1(%edi),%eax
  800424:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800427:	0f b6 07             	movzbl (%edi),%eax
  80042a:	0f b6 c8             	movzbl %al,%ecx
  80042d:	83 e8 23             	sub    $0x23,%eax
  800430:	3c 55                	cmp    $0x55,%al
  800432:	0f 87 1a 03 00 00    	ja     800752 <vprintfmt+0x38a>
  800438:	0f b6 c0             	movzbl %al,%eax
  80043b:	ff 24 85 c0 2a 80 00 	jmp    *0x802ac0(,%eax,4)
  800442:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800445:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800449:	eb d6                	jmp    800421 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80044e:	b8 00 00 00 00       	mov    $0x0,%eax
  800453:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800456:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800459:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80045d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800460:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800463:	83 fa 09             	cmp    $0x9,%edx
  800466:	77 39                	ja     8004a1 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800468:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80046b:	eb e9                	jmp    800456 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80046d:	8b 45 14             	mov    0x14(%ebp),%eax
  800470:	8d 48 04             	lea    0x4(%eax),%ecx
  800473:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800476:	8b 00                	mov    (%eax),%eax
  800478:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80047e:	eb 27                	jmp    8004a7 <vprintfmt+0xdf>
  800480:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800483:	85 c0                	test   %eax,%eax
  800485:	b9 00 00 00 00       	mov    $0x0,%ecx
  80048a:	0f 49 c8             	cmovns %eax,%ecx
  80048d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800490:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800493:	eb 8c                	jmp    800421 <vprintfmt+0x59>
  800495:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800498:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80049f:	eb 80                	jmp    800421 <vprintfmt+0x59>
  8004a1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004a4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004a7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ab:	0f 89 70 ff ff ff    	jns    800421 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004b1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004be:	e9 5e ff ff ff       	jmp    800421 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004c3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004c9:	e9 53 ff ff ff       	jmp    800421 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d1:	8d 50 04             	lea    0x4(%eax),%edx
  8004d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	53                   	push   %ebx
  8004db:	ff 30                	pushl  (%eax)
  8004dd:	ff d6                	call   *%esi
			break;
  8004df:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004e5:	e9 04 ff ff ff       	jmp    8003ee <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ed:	8d 50 04             	lea    0x4(%eax),%edx
  8004f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f3:	8b 00                	mov    (%eax),%eax
  8004f5:	99                   	cltd   
  8004f6:	31 d0                	xor    %edx,%eax
  8004f8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004fa:	83 f8 0f             	cmp    $0xf,%eax
  8004fd:	7f 0b                	jg     80050a <vprintfmt+0x142>
  8004ff:	8b 14 85 20 2c 80 00 	mov    0x802c20(,%eax,4),%edx
  800506:	85 d2                	test   %edx,%edx
  800508:	75 18                	jne    800522 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80050a:	50                   	push   %eax
  80050b:	68 93 29 80 00       	push   $0x802993
  800510:	53                   	push   %ebx
  800511:	56                   	push   %esi
  800512:	e8 94 fe ff ff       	call   8003ab <printfmt>
  800517:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80051d:	e9 cc fe ff ff       	jmp    8003ee <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800522:	52                   	push   %edx
  800523:	68 cd 2d 80 00       	push   $0x802dcd
  800528:	53                   	push   %ebx
  800529:	56                   	push   %esi
  80052a:	e8 7c fe ff ff       	call   8003ab <printfmt>
  80052f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800532:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800535:	e9 b4 fe ff ff       	jmp    8003ee <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80053a:	8b 45 14             	mov    0x14(%ebp),%eax
  80053d:	8d 50 04             	lea    0x4(%eax),%edx
  800540:	89 55 14             	mov    %edx,0x14(%ebp)
  800543:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800545:	85 ff                	test   %edi,%edi
  800547:	b8 8c 29 80 00       	mov    $0x80298c,%eax
  80054c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80054f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800553:	0f 8e 94 00 00 00    	jle    8005ed <vprintfmt+0x225>
  800559:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80055d:	0f 84 98 00 00 00    	je     8005fb <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	ff 75 d0             	pushl  -0x30(%ebp)
  800569:	57                   	push   %edi
  80056a:	e8 86 02 00 00       	call   8007f5 <strnlen>
  80056f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800572:	29 c1                	sub    %eax,%ecx
  800574:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800577:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80057a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80057e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800581:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800584:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800586:	eb 0f                	jmp    800597 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800588:	83 ec 08             	sub    $0x8,%esp
  80058b:	53                   	push   %ebx
  80058c:	ff 75 e0             	pushl  -0x20(%ebp)
  80058f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800591:	83 ef 01             	sub    $0x1,%edi
  800594:	83 c4 10             	add    $0x10,%esp
  800597:	85 ff                	test   %edi,%edi
  800599:	7f ed                	jg     800588 <vprintfmt+0x1c0>
  80059b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80059e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005a1:	85 c9                	test   %ecx,%ecx
  8005a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a8:	0f 49 c1             	cmovns %ecx,%eax
  8005ab:	29 c1                	sub    %eax,%ecx
  8005ad:	89 75 08             	mov    %esi,0x8(%ebp)
  8005b0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005b3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005b6:	89 cb                	mov    %ecx,%ebx
  8005b8:	eb 4d                	jmp    800607 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005ba:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005be:	74 1b                	je     8005db <vprintfmt+0x213>
  8005c0:	0f be c0             	movsbl %al,%eax
  8005c3:	83 e8 20             	sub    $0x20,%eax
  8005c6:	83 f8 5e             	cmp    $0x5e,%eax
  8005c9:	76 10                	jbe    8005db <vprintfmt+0x213>
					putch('?', putdat);
  8005cb:	83 ec 08             	sub    $0x8,%esp
  8005ce:	ff 75 0c             	pushl  0xc(%ebp)
  8005d1:	6a 3f                	push   $0x3f
  8005d3:	ff 55 08             	call   *0x8(%ebp)
  8005d6:	83 c4 10             	add    $0x10,%esp
  8005d9:	eb 0d                	jmp    8005e8 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005db:	83 ec 08             	sub    $0x8,%esp
  8005de:	ff 75 0c             	pushl  0xc(%ebp)
  8005e1:	52                   	push   %edx
  8005e2:	ff 55 08             	call   *0x8(%ebp)
  8005e5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e8:	83 eb 01             	sub    $0x1,%ebx
  8005eb:	eb 1a                	jmp    800607 <vprintfmt+0x23f>
  8005ed:	89 75 08             	mov    %esi,0x8(%ebp)
  8005f0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005f3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005f9:	eb 0c                	jmp    800607 <vprintfmt+0x23f>
  8005fb:	89 75 08             	mov    %esi,0x8(%ebp)
  8005fe:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800601:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800604:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800607:	83 c7 01             	add    $0x1,%edi
  80060a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80060e:	0f be d0             	movsbl %al,%edx
  800611:	85 d2                	test   %edx,%edx
  800613:	74 23                	je     800638 <vprintfmt+0x270>
  800615:	85 f6                	test   %esi,%esi
  800617:	78 a1                	js     8005ba <vprintfmt+0x1f2>
  800619:	83 ee 01             	sub    $0x1,%esi
  80061c:	79 9c                	jns    8005ba <vprintfmt+0x1f2>
  80061e:	89 df                	mov    %ebx,%edi
  800620:	8b 75 08             	mov    0x8(%ebp),%esi
  800623:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800626:	eb 18                	jmp    800640 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800628:	83 ec 08             	sub    $0x8,%esp
  80062b:	53                   	push   %ebx
  80062c:	6a 20                	push   $0x20
  80062e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800630:	83 ef 01             	sub    $0x1,%edi
  800633:	83 c4 10             	add    $0x10,%esp
  800636:	eb 08                	jmp    800640 <vprintfmt+0x278>
  800638:	89 df                	mov    %ebx,%edi
  80063a:	8b 75 08             	mov    0x8(%ebp),%esi
  80063d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800640:	85 ff                	test   %edi,%edi
  800642:	7f e4                	jg     800628 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800644:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800647:	e9 a2 fd ff ff       	jmp    8003ee <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80064c:	83 fa 01             	cmp    $0x1,%edx
  80064f:	7e 16                	jle    800667 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8d 50 08             	lea    0x8(%eax),%edx
  800657:	89 55 14             	mov    %edx,0x14(%ebp)
  80065a:	8b 50 04             	mov    0x4(%eax),%edx
  80065d:	8b 00                	mov    (%eax),%eax
  80065f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800662:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800665:	eb 32                	jmp    800699 <vprintfmt+0x2d1>
	else if (lflag)
  800667:	85 d2                	test   %edx,%edx
  800669:	74 18                	je     800683 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80066b:	8b 45 14             	mov    0x14(%ebp),%eax
  80066e:	8d 50 04             	lea    0x4(%eax),%edx
  800671:	89 55 14             	mov    %edx,0x14(%ebp)
  800674:	8b 00                	mov    (%eax),%eax
  800676:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800679:	89 c1                	mov    %eax,%ecx
  80067b:	c1 f9 1f             	sar    $0x1f,%ecx
  80067e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800681:	eb 16                	jmp    800699 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8d 50 04             	lea    0x4(%eax),%edx
  800689:	89 55 14             	mov    %edx,0x14(%ebp)
  80068c:	8b 00                	mov    (%eax),%eax
  80068e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800691:	89 c1                	mov    %eax,%ecx
  800693:	c1 f9 1f             	sar    $0x1f,%ecx
  800696:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800699:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80069c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80069f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006a4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006a8:	79 74                	jns    80071e <vprintfmt+0x356>
				putch('-', putdat);
  8006aa:	83 ec 08             	sub    $0x8,%esp
  8006ad:	53                   	push   %ebx
  8006ae:	6a 2d                	push   $0x2d
  8006b0:	ff d6                	call   *%esi
				num = -(long long) num;
  8006b2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006b5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006b8:	f7 d8                	neg    %eax
  8006ba:	83 d2 00             	adc    $0x0,%edx
  8006bd:	f7 da                	neg    %edx
  8006bf:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006c2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006c7:	eb 55                	jmp    80071e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006c9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006cc:	e8 83 fc ff ff       	call   800354 <getuint>
			base = 10;
  8006d1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006d6:	eb 46                	jmp    80071e <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006d8:	8d 45 14             	lea    0x14(%ebp),%eax
  8006db:	e8 74 fc ff ff       	call   800354 <getuint>
			base = 8;
  8006e0:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006e5:	eb 37                	jmp    80071e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8006e7:	83 ec 08             	sub    $0x8,%esp
  8006ea:	53                   	push   %ebx
  8006eb:	6a 30                	push   $0x30
  8006ed:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ef:	83 c4 08             	add    $0x8,%esp
  8006f2:	53                   	push   %ebx
  8006f3:	6a 78                	push   $0x78
  8006f5:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	8d 50 04             	lea    0x4(%eax),%edx
  8006fd:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800700:	8b 00                	mov    (%eax),%eax
  800702:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800707:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80070a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80070f:	eb 0d                	jmp    80071e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800711:	8d 45 14             	lea    0x14(%ebp),%eax
  800714:	e8 3b fc ff ff       	call   800354 <getuint>
			base = 16;
  800719:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80071e:	83 ec 0c             	sub    $0xc,%esp
  800721:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800725:	57                   	push   %edi
  800726:	ff 75 e0             	pushl  -0x20(%ebp)
  800729:	51                   	push   %ecx
  80072a:	52                   	push   %edx
  80072b:	50                   	push   %eax
  80072c:	89 da                	mov    %ebx,%edx
  80072e:	89 f0                	mov    %esi,%eax
  800730:	e8 70 fb ff ff       	call   8002a5 <printnum>
			break;
  800735:	83 c4 20             	add    $0x20,%esp
  800738:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80073b:	e9 ae fc ff ff       	jmp    8003ee <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800740:	83 ec 08             	sub    $0x8,%esp
  800743:	53                   	push   %ebx
  800744:	51                   	push   %ecx
  800745:	ff d6                	call   *%esi
			break;
  800747:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80074d:	e9 9c fc ff ff       	jmp    8003ee <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800752:	83 ec 08             	sub    $0x8,%esp
  800755:	53                   	push   %ebx
  800756:	6a 25                	push   $0x25
  800758:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80075a:	83 c4 10             	add    $0x10,%esp
  80075d:	eb 03                	jmp    800762 <vprintfmt+0x39a>
  80075f:	83 ef 01             	sub    $0x1,%edi
  800762:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800766:	75 f7                	jne    80075f <vprintfmt+0x397>
  800768:	e9 81 fc ff ff       	jmp    8003ee <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80076d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800770:	5b                   	pop    %ebx
  800771:	5e                   	pop    %esi
  800772:	5f                   	pop    %edi
  800773:	5d                   	pop    %ebp
  800774:	c3                   	ret    

00800775 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	83 ec 18             	sub    $0x18,%esp
  80077b:	8b 45 08             	mov    0x8(%ebp),%eax
  80077e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800781:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800784:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800788:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80078b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800792:	85 c0                	test   %eax,%eax
  800794:	74 26                	je     8007bc <vsnprintf+0x47>
  800796:	85 d2                	test   %edx,%edx
  800798:	7e 22                	jle    8007bc <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80079a:	ff 75 14             	pushl  0x14(%ebp)
  80079d:	ff 75 10             	pushl  0x10(%ebp)
  8007a0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a3:	50                   	push   %eax
  8007a4:	68 8e 03 80 00       	push   $0x80038e
  8007a9:	e8 1a fc ff ff       	call   8003c8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b7:	83 c4 10             	add    $0x10,%esp
  8007ba:	eb 05                	jmp    8007c1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007c1:	c9                   	leave  
  8007c2:	c3                   	ret    

008007c3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007cc:	50                   	push   %eax
  8007cd:	ff 75 10             	pushl  0x10(%ebp)
  8007d0:	ff 75 0c             	pushl  0xc(%ebp)
  8007d3:	ff 75 08             	pushl  0x8(%ebp)
  8007d6:	e8 9a ff ff ff       	call   800775 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007db:	c9                   	leave  
  8007dc:	c3                   	ret    

008007dd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e8:	eb 03                	jmp    8007ed <strlen+0x10>
		n++;
  8007ea:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ed:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f1:	75 f7                	jne    8007ea <strlen+0xd>
		n++;
	return n;
}
  8007f3:	5d                   	pop    %ebp
  8007f4:	c3                   	ret    

008007f5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fe:	ba 00 00 00 00       	mov    $0x0,%edx
  800803:	eb 03                	jmp    800808 <strnlen+0x13>
		n++;
  800805:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800808:	39 c2                	cmp    %eax,%edx
  80080a:	74 08                	je     800814 <strnlen+0x1f>
  80080c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800810:	75 f3                	jne    800805 <strnlen+0x10>
  800812:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800814:	5d                   	pop    %ebp
  800815:	c3                   	ret    

00800816 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	53                   	push   %ebx
  80081a:	8b 45 08             	mov    0x8(%ebp),%eax
  80081d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800820:	89 c2                	mov    %eax,%edx
  800822:	83 c2 01             	add    $0x1,%edx
  800825:	83 c1 01             	add    $0x1,%ecx
  800828:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80082c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80082f:	84 db                	test   %bl,%bl
  800831:	75 ef                	jne    800822 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800833:	5b                   	pop    %ebx
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    

00800836 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	53                   	push   %ebx
  80083a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80083d:	53                   	push   %ebx
  80083e:	e8 9a ff ff ff       	call   8007dd <strlen>
  800843:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800846:	ff 75 0c             	pushl  0xc(%ebp)
  800849:	01 d8                	add    %ebx,%eax
  80084b:	50                   	push   %eax
  80084c:	e8 c5 ff ff ff       	call   800816 <strcpy>
	return dst;
}
  800851:	89 d8                	mov    %ebx,%eax
  800853:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800856:	c9                   	leave  
  800857:	c3                   	ret    

00800858 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	56                   	push   %esi
  80085c:	53                   	push   %ebx
  80085d:	8b 75 08             	mov    0x8(%ebp),%esi
  800860:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800863:	89 f3                	mov    %esi,%ebx
  800865:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800868:	89 f2                	mov    %esi,%edx
  80086a:	eb 0f                	jmp    80087b <strncpy+0x23>
		*dst++ = *src;
  80086c:	83 c2 01             	add    $0x1,%edx
  80086f:	0f b6 01             	movzbl (%ecx),%eax
  800872:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800875:	80 39 01             	cmpb   $0x1,(%ecx)
  800878:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80087b:	39 da                	cmp    %ebx,%edx
  80087d:	75 ed                	jne    80086c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80087f:	89 f0                	mov    %esi,%eax
  800881:	5b                   	pop    %ebx
  800882:	5e                   	pop    %esi
  800883:	5d                   	pop    %ebp
  800884:	c3                   	ret    

00800885 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	56                   	push   %esi
  800889:	53                   	push   %ebx
  80088a:	8b 75 08             	mov    0x8(%ebp),%esi
  80088d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800890:	8b 55 10             	mov    0x10(%ebp),%edx
  800893:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800895:	85 d2                	test   %edx,%edx
  800897:	74 21                	je     8008ba <strlcpy+0x35>
  800899:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80089d:	89 f2                	mov    %esi,%edx
  80089f:	eb 09                	jmp    8008aa <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008a1:	83 c2 01             	add    $0x1,%edx
  8008a4:	83 c1 01             	add    $0x1,%ecx
  8008a7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008aa:	39 c2                	cmp    %eax,%edx
  8008ac:	74 09                	je     8008b7 <strlcpy+0x32>
  8008ae:	0f b6 19             	movzbl (%ecx),%ebx
  8008b1:	84 db                	test   %bl,%bl
  8008b3:	75 ec                	jne    8008a1 <strlcpy+0x1c>
  8008b5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008b7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ba:	29 f0                	sub    %esi,%eax
}
  8008bc:	5b                   	pop    %ebx
  8008bd:	5e                   	pop    %esi
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c9:	eb 06                	jmp    8008d1 <strcmp+0x11>
		p++, q++;
  8008cb:	83 c1 01             	add    $0x1,%ecx
  8008ce:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008d1:	0f b6 01             	movzbl (%ecx),%eax
  8008d4:	84 c0                	test   %al,%al
  8008d6:	74 04                	je     8008dc <strcmp+0x1c>
  8008d8:	3a 02                	cmp    (%edx),%al
  8008da:	74 ef                	je     8008cb <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008dc:	0f b6 c0             	movzbl %al,%eax
  8008df:	0f b6 12             	movzbl (%edx),%edx
  8008e2:	29 d0                	sub    %edx,%eax
}
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    

008008e6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	53                   	push   %ebx
  8008ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f0:	89 c3                	mov    %eax,%ebx
  8008f2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008f5:	eb 06                	jmp    8008fd <strncmp+0x17>
		n--, p++, q++;
  8008f7:	83 c0 01             	add    $0x1,%eax
  8008fa:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008fd:	39 d8                	cmp    %ebx,%eax
  8008ff:	74 15                	je     800916 <strncmp+0x30>
  800901:	0f b6 08             	movzbl (%eax),%ecx
  800904:	84 c9                	test   %cl,%cl
  800906:	74 04                	je     80090c <strncmp+0x26>
  800908:	3a 0a                	cmp    (%edx),%cl
  80090a:	74 eb                	je     8008f7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80090c:	0f b6 00             	movzbl (%eax),%eax
  80090f:	0f b6 12             	movzbl (%edx),%edx
  800912:	29 d0                	sub    %edx,%eax
  800914:	eb 05                	jmp    80091b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800916:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80091b:	5b                   	pop    %ebx
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	8b 45 08             	mov    0x8(%ebp),%eax
  800924:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800928:	eb 07                	jmp    800931 <strchr+0x13>
		if (*s == c)
  80092a:	38 ca                	cmp    %cl,%dl
  80092c:	74 0f                	je     80093d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80092e:	83 c0 01             	add    $0x1,%eax
  800931:	0f b6 10             	movzbl (%eax),%edx
  800934:	84 d2                	test   %dl,%dl
  800936:	75 f2                	jne    80092a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800938:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800949:	eb 03                	jmp    80094e <strfind+0xf>
  80094b:	83 c0 01             	add    $0x1,%eax
  80094e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800951:	38 ca                	cmp    %cl,%dl
  800953:	74 04                	je     800959 <strfind+0x1a>
  800955:	84 d2                	test   %dl,%dl
  800957:	75 f2                	jne    80094b <strfind+0xc>
			break;
	return (char *) s;
}
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	57                   	push   %edi
  80095f:	56                   	push   %esi
  800960:	53                   	push   %ebx
  800961:	8b 7d 08             	mov    0x8(%ebp),%edi
  800964:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800967:	85 c9                	test   %ecx,%ecx
  800969:	74 36                	je     8009a1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80096b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800971:	75 28                	jne    80099b <memset+0x40>
  800973:	f6 c1 03             	test   $0x3,%cl
  800976:	75 23                	jne    80099b <memset+0x40>
		c &= 0xFF;
  800978:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80097c:	89 d3                	mov    %edx,%ebx
  80097e:	c1 e3 08             	shl    $0x8,%ebx
  800981:	89 d6                	mov    %edx,%esi
  800983:	c1 e6 18             	shl    $0x18,%esi
  800986:	89 d0                	mov    %edx,%eax
  800988:	c1 e0 10             	shl    $0x10,%eax
  80098b:	09 f0                	or     %esi,%eax
  80098d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80098f:	89 d8                	mov    %ebx,%eax
  800991:	09 d0                	or     %edx,%eax
  800993:	c1 e9 02             	shr    $0x2,%ecx
  800996:	fc                   	cld    
  800997:	f3 ab                	rep stos %eax,%es:(%edi)
  800999:	eb 06                	jmp    8009a1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80099b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099e:	fc                   	cld    
  80099f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009a1:	89 f8                	mov    %edi,%eax
  8009a3:	5b                   	pop    %ebx
  8009a4:	5e                   	pop    %esi
  8009a5:	5f                   	pop    %edi
  8009a6:	5d                   	pop    %ebp
  8009a7:	c3                   	ret    

008009a8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	57                   	push   %edi
  8009ac:	56                   	push   %esi
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b6:	39 c6                	cmp    %eax,%esi
  8009b8:	73 35                	jae    8009ef <memmove+0x47>
  8009ba:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009bd:	39 d0                	cmp    %edx,%eax
  8009bf:	73 2e                	jae    8009ef <memmove+0x47>
		s += n;
		d += n;
  8009c1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c4:	89 d6                	mov    %edx,%esi
  8009c6:	09 fe                	or     %edi,%esi
  8009c8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ce:	75 13                	jne    8009e3 <memmove+0x3b>
  8009d0:	f6 c1 03             	test   $0x3,%cl
  8009d3:	75 0e                	jne    8009e3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009d5:	83 ef 04             	sub    $0x4,%edi
  8009d8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009db:	c1 e9 02             	shr    $0x2,%ecx
  8009de:	fd                   	std    
  8009df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e1:	eb 09                	jmp    8009ec <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009e3:	83 ef 01             	sub    $0x1,%edi
  8009e6:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009e9:	fd                   	std    
  8009ea:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ec:	fc                   	cld    
  8009ed:	eb 1d                	jmp    800a0c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ef:	89 f2                	mov    %esi,%edx
  8009f1:	09 c2                	or     %eax,%edx
  8009f3:	f6 c2 03             	test   $0x3,%dl
  8009f6:	75 0f                	jne    800a07 <memmove+0x5f>
  8009f8:	f6 c1 03             	test   $0x3,%cl
  8009fb:	75 0a                	jne    800a07 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009fd:	c1 e9 02             	shr    $0x2,%ecx
  800a00:	89 c7                	mov    %eax,%edi
  800a02:	fc                   	cld    
  800a03:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a05:	eb 05                	jmp    800a0c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a07:	89 c7                	mov    %eax,%edi
  800a09:	fc                   	cld    
  800a0a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a0c:	5e                   	pop    %esi
  800a0d:	5f                   	pop    %edi
  800a0e:	5d                   	pop    %ebp
  800a0f:	c3                   	ret    

00800a10 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a13:	ff 75 10             	pushl  0x10(%ebp)
  800a16:	ff 75 0c             	pushl  0xc(%ebp)
  800a19:	ff 75 08             	pushl  0x8(%ebp)
  800a1c:	e8 87 ff ff ff       	call   8009a8 <memmove>
}
  800a21:	c9                   	leave  
  800a22:	c3                   	ret    

00800a23 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	56                   	push   %esi
  800a27:	53                   	push   %ebx
  800a28:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2e:	89 c6                	mov    %eax,%esi
  800a30:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a33:	eb 1a                	jmp    800a4f <memcmp+0x2c>
		if (*s1 != *s2)
  800a35:	0f b6 08             	movzbl (%eax),%ecx
  800a38:	0f b6 1a             	movzbl (%edx),%ebx
  800a3b:	38 d9                	cmp    %bl,%cl
  800a3d:	74 0a                	je     800a49 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a3f:	0f b6 c1             	movzbl %cl,%eax
  800a42:	0f b6 db             	movzbl %bl,%ebx
  800a45:	29 d8                	sub    %ebx,%eax
  800a47:	eb 0f                	jmp    800a58 <memcmp+0x35>
		s1++, s2++;
  800a49:	83 c0 01             	add    $0x1,%eax
  800a4c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4f:	39 f0                	cmp    %esi,%eax
  800a51:	75 e2                	jne    800a35 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a53:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a58:	5b                   	pop    %ebx
  800a59:	5e                   	pop    %esi
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	53                   	push   %ebx
  800a60:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a63:	89 c1                	mov    %eax,%ecx
  800a65:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a68:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a6c:	eb 0a                	jmp    800a78 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a6e:	0f b6 10             	movzbl (%eax),%edx
  800a71:	39 da                	cmp    %ebx,%edx
  800a73:	74 07                	je     800a7c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a75:	83 c0 01             	add    $0x1,%eax
  800a78:	39 c8                	cmp    %ecx,%eax
  800a7a:	72 f2                	jb     800a6e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a7c:	5b                   	pop    %ebx
  800a7d:	5d                   	pop    %ebp
  800a7e:	c3                   	ret    

00800a7f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	57                   	push   %edi
  800a83:	56                   	push   %esi
  800a84:	53                   	push   %ebx
  800a85:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a88:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8b:	eb 03                	jmp    800a90 <strtol+0x11>
		s++;
  800a8d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a90:	0f b6 01             	movzbl (%ecx),%eax
  800a93:	3c 20                	cmp    $0x20,%al
  800a95:	74 f6                	je     800a8d <strtol+0xe>
  800a97:	3c 09                	cmp    $0x9,%al
  800a99:	74 f2                	je     800a8d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a9b:	3c 2b                	cmp    $0x2b,%al
  800a9d:	75 0a                	jne    800aa9 <strtol+0x2a>
		s++;
  800a9f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa2:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa7:	eb 11                	jmp    800aba <strtol+0x3b>
  800aa9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aae:	3c 2d                	cmp    $0x2d,%al
  800ab0:	75 08                	jne    800aba <strtol+0x3b>
		s++, neg = 1;
  800ab2:	83 c1 01             	add    $0x1,%ecx
  800ab5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aba:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ac0:	75 15                	jne    800ad7 <strtol+0x58>
  800ac2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac5:	75 10                	jne    800ad7 <strtol+0x58>
  800ac7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800acb:	75 7c                	jne    800b49 <strtol+0xca>
		s += 2, base = 16;
  800acd:	83 c1 02             	add    $0x2,%ecx
  800ad0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad5:	eb 16                	jmp    800aed <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ad7:	85 db                	test   %ebx,%ebx
  800ad9:	75 12                	jne    800aed <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800adb:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae0:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae3:	75 08                	jne    800aed <strtol+0x6e>
		s++, base = 8;
  800ae5:	83 c1 01             	add    $0x1,%ecx
  800ae8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aed:	b8 00 00 00 00       	mov    $0x0,%eax
  800af2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af5:	0f b6 11             	movzbl (%ecx),%edx
  800af8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800afb:	89 f3                	mov    %esi,%ebx
  800afd:	80 fb 09             	cmp    $0x9,%bl
  800b00:	77 08                	ja     800b0a <strtol+0x8b>
			dig = *s - '0';
  800b02:	0f be d2             	movsbl %dl,%edx
  800b05:	83 ea 30             	sub    $0x30,%edx
  800b08:	eb 22                	jmp    800b2c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b0a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b0d:	89 f3                	mov    %esi,%ebx
  800b0f:	80 fb 19             	cmp    $0x19,%bl
  800b12:	77 08                	ja     800b1c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b14:	0f be d2             	movsbl %dl,%edx
  800b17:	83 ea 57             	sub    $0x57,%edx
  800b1a:	eb 10                	jmp    800b2c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b1c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b1f:	89 f3                	mov    %esi,%ebx
  800b21:	80 fb 19             	cmp    $0x19,%bl
  800b24:	77 16                	ja     800b3c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b26:	0f be d2             	movsbl %dl,%edx
  800b29:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b2c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b2f:	7d 0b                	jge    800b3c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b31:	83 c1 01             	add    $0x1,%ecx
  800b34:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b38:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b3a:	eb b9                	jmp    800af5 <strtol+0x76>

	if (endptr)
  800b3c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b40:	74 0d                	je     800b4f <strtol+0xd0>
		*endptr = (char *) s;
  800b42:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b45:	89 0e                	mov    %ecx,(%esi)
  800b47:	eb 06                	jmp    800b4f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b49:	85 db                	test   %ebx,%ebx
  800b4b:	74 98                	je     800ae5 <strtol+0x66>
  800b4d:	eb 9e                	jmp    800aed <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b4f:	89 c2                	mov    %eax,%edx
  800b51:	f7 da                	neg    %edx
  800b53:	85 ff                	test   %edi,%edi
  800b55:	0f 45 c2             	cmovne %edx,%eax
}
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	57                   	push   %edi
  800b61:	56                   	push   %esi
  800b62:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b63:	b8 00 00 00 00       	mov    $0x0,%eax
  800b68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6e:	89 c3                	mov    %eax,%ebx
  800b70:	89 c7                	mov    %eax,%edi
  800b72:	89 c6                	mov    %eax,%esi
  800b74:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5f                   	pop    %edi
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	57                   	push   %edi
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b81:	ba 00 00 00 00       	mov    $0x0,%edx
  800b86:	b8 01 00 00 00       	mov    $0x1,%eax
  800b8b:	89 d1                	mov    %edx,%ecx
  800b8d:	89 d3                	mov    %edx,%ebx
  800b8f:	89 d7                	mov    %edx,%edi
  800b91:	89 d6                	mov    %edx,%esi
  800b93:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
  800ba0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba8:	b8 03 00 00 00       	mov    $0x3,%eax
  800bad:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb0:	89 cb                	mov    %ecx,%ebx
  800bb2:	89 cf                	mov    %ecx,%edi
  800bb4:	89 ce                	mov    %ecx,%esi
  800bb6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb8:	85 c0                	test   %eax,%eax
  800bba:	7e 17                	jle    800bd3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbc:	83 ec 0c             	sub    $0xc,%esp
  800bbf:	50                   	push   %eax
  800bc0:	6a 03                	push   $0x3
  800bc2:	68 7f 2c 80 00       	push   $0x802c7f
  800bc7:	6a 23                	push   $0x23
  800bc9:	68 9c 2c 80 00       	push   $0x802c9c
  800bce:	e8 e5 f5 ff ff       	call   8001b8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be1:	ba 00 00 00 00       	mov    $0x0,%edx
  800be6:	b8 02 00 00 00       	mov    $0x2,%eax
  800beb:	89 d1                	mov    %edx,%ecx
  800bed:	89 d3                	mov    %edx,%ebx
  800bef:	89 d7                	mov    %edx,%edi
  800bf1:	89 d6                	mov    %edx,%esi
  800bf3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <sys_yield>:

void
sys_yield(void)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	57                   	push   %edi
  800bfe:	56                   	push   %esi
  800bff:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c00:	ba 00 00 00 00       	mov    $0x0,%edx
  800c05:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c0a:	89 d1                	mov    %edx,%ecx
  800c0c:	89 d3                	mov    %edx,%ebx
  800c0e:	89 d7                	mov    %edx,%edi
  800c10:	89 d6                	mov    %edx,%esi
  800c12:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    

00800c19 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	57                   	push   %edi
  800c1d:	56                   	push   %esi
  800c1e:	53                   	push   %ebx
  800c1f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c22:	be 00 00 00 00       	mov    $0x0,%esi
  800c27:	b8 04 00 00 00       	mov    $0x4,%eax
  800c2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c32:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c35:	89 f7                	mov    %esi,%edi
  800c37:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c39:	85 c0                	test   %eax,%eax
  800c3b:	7e 17                	jle    800c54 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3d:	83 ec 0c             	sub    $0xc,%esp
  800c40:	50                   	push   %eax
  800c41:	6a 04                	push   $0x4
  800c43:	68 7f 2c 80 00       	push   $0x802c7f
  800c48:	6a 23                	push   $0x23
  800c4a:	68 9c 2c 80 00       	push   $0x802c9c
  800c4f:	e8 64 f5 ff ff       	call   8001b8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c57:	5b                   	pop    %ebx
  800c58:	5e                   	pop    %esi
  800c59:	5f                   	pop    %edi
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    

00800c5c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800c65:	b8 05 00 00 00       	mov    $0x5,%eax
  800c6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c70:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c73:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c76:	8b 75 18             	mov    0x18(%ebp),%esi
  800c79:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7b:	85 c0                	test   %eax,%eax
  800c7d:	7e 17                	jle    800c96 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7f:	83 ec 0c             	sub    $0xc,%esp
  800c82:	50                   	push   %eax
  800c83:	6a 05                	push   $0x5
  800c85:	68 7f 2c 80 00       	push   $0x802c7f
  800c8a:	6a 23                	push   $0x23
  800c8c:	68 9c 2c 80 00       	push   $0x802c9c
  800c91:	e8 22 f5 ff ff       	call   8001b8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c99:	5b                   	pop    %ebx
  800c9a:	5e                   	pop    %esi
  800c9b:	5f                   	pop    %edi
  800c9c:	5d                   	pop    %ebp
  800c9d:	c3                   	ret    

00800c9e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	53                   	push   %ebx
  800ca4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cac:	b8 06 00 00 00       	mov    $0x6,%eax
  800cb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb7:	89 df                	mov    %ebx,%edi
  800cb9:	89 de                	mov    %ebx,%esi
  800cbb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbd:	85 c0                	test   %eax,%eax
  800cbf:	7e 17                	jle    800cd8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc1:	83 ec 0c             	sub    $0xc,%esp
  800cc4:	50                   	push   %eax
  800cc5:	6a 06                	push   $0x6
  800cc7:	68 7f 2c 80 00       	push   $0x802c7f
  800ccc:	6a 23                	push   $0x23
  800cce:	68 9c 2c 80 00       	push   $0x802c9c
  800cd3:	e8 e0 f4 ff ff       	call   8001b8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	57                   	push   %edi
  800ce4:	56                   	push   %esi
  800ce5:	53                   	push   %ebx
  800ce6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cee:	b8 08 00 00 00       	mov    $0x8,%eax
  800cf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf9:	89 df                	mov    %ebx,%edi
  800cfb:	89 de                	mov    %ebx,%esi
  800cfd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cff:	85 c0                	test   %eax,%eax
  800d01:	7e 17                	jle    800d1a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d03:	83 ec 0c             	sub    $0xc,%esp
  800d06:	50                   	push   %eax
  800d07:	6a 08                	push   $0x8
  800d09:	68 7f 2c 80 00       	push   $0x802c7f
  800d0e:	6a 23                	push   $0x23
  800d10:	68 9c 2c 80 00       	push   $0x802c9c
  800d15:	e8 9e f4 ff ff       	call   8001b8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1d:	5b                   	pop    %ebx
  800d1e:	5e                   	pop    %esi
  800d1f:	5f                   	pop    %edi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    

00800d22 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	57                   	push   %edi
  800d26:	56                   	push   %esi
  800d27:	53                   	push   %ebx
  800d28:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d30:	b8 09 00 00 00       	mov    $0x9,%eax
  800d35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d38:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3b:	89 df                	mov    %ebx,%edi
  800d3d:	89 de                	mov    %ebx,%esi
  800d3f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d41:	85 c0                	test   %eax,%eax
  800d43:	7e 17                	jle    800d5c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d45:	83 ec 0c             	sub    $0xc,%esp
  800d48:	50                   	push   %eax
  800d49:	6a 09                	push   $0x9
  800d4b:	68 7f 2c 80 00       	push   $0x802c7f
  800d50:	6a 23                	push   $0x23
  800d52:	68 9c 2c 80 00       	push   $0x802c9c
  800d57:	e8 5c f4 ff ff       	call   8001b8 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5f:	5b                   	pop    %ebx
  800d60:	5e                   	pop    %esi
  800d61:	5f                   	pop    %edi
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    

00800d64 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	57                   	push   %edi
  800d68:	56                   	push   %esi
  800d69:	53                   	push   %ebx
  800d6a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d72:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7d:	89 df                	mov    %ebx,%edi
  800d7f:	89 de                	mov    %ebx,%esi
  800d81:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d83:	85 c0                	test   %eax,%eax
  800d85:	7e 17                	jle    800d9e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d87:	83 ec 0c             	sub    $0xc,%esp
  800d8a:	50                   	push   %eax
  800d8b:	6a 0a                	push   $0xa
  800d8d:	68 7f 2c 80 00       	push   $0x802c7f
  800d92:	6a 23                	push   $0x23
  800d94:	68 9c 2c 80 00       	push   $0x802c9c
  800d99:	e8 1a f4 ff ff       	call   8001b8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da1:	5b                   	pop    %ebx
  800da2:	5e                   	pop    %esi
  800da3:	5f                   	pop    %edi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    

00800da6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	57                   	push   %edi
  800daa:	56                   	push   %esi
  800dab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dac:	be 00 00 00 00       	mov    $0x0,%esi
  800db1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800db6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dbf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dc2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dc4:	5b                   	pop    %ebx
  800dc5:	5e                   	pop    %esi
  800dc6:	5f                   	pop    %edi
  800dc7:	5d                   	pop    %ebp
  800dc8:	c3                   	ret    

00800dc9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc9:	55                   	push   %ebp
  800dca:	89 e5                	mov    %esp,%ebp
  800dcc:	57                   	push   %edi
  800dcd:	56                   	push   %esi
  800dce:	53                   	push   %ebx
  800dcf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ddc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddf:	89 cb                	mov    %ecx,%ebx
  800de1:	89 cf                	mov    %ecx,%edi
  800de3:	89 ce                	mov    %ecx,%esi
  800de5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de7:	85 c0                	test   %eax,%eax
  800de9:	7e 17                	jle    800e02 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800deb:	83 ec 0c             	sub    $0xc,%esp
  800dee:	50                   	push   %eax
  800def:	6a 0d                	push   $0xd
  800df1:	68 7f 2c 80 00       	push   $0x802c7f
  800df6:	6a 23                	push   $0x23
  800df8:	68 9c 2c 80 00       	push   $0x802c9c
  800dfd:	e8 b6 f3 ff ff       	call   8001b8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e10:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e15:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1d:	89 cb                	mov    %ecx,%ebx
  800e1f:	89 cf                	mov    %ecx,%edi
  800e21:	89 ce                	mov    %ecx,%esi
  800e23:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	57                   	push   %edi
  800e2e:	56                   	push   %esi
  800e2f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e30:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e35:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3d:	89 cb                	mov    %ecx,%ebx
  800e3f:	89 cf                	mov    %ecx,%edi
  800e41:	89 ce                	mov    %ecx,%esi
  800e43:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800e45:	5b                   	pop    %ebx
  800e46:	5e                   	pop    %esi
  800e47:	5f                   	pop    %edi
  800e48:	5d                   	pop    %ebp
  800e49:	c3                   	ret    

00800e4a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	53                   	push   %ebx
  800e4e:	83 ec 04             	sub    $0x4,%esp
  800e51:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e54:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800e56:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e5a:	74 11                	je     800e6d <pgfault+0x23>
  800e5c:	89 d8                	mov    %ebx,%eax
  800e5e:	c1 e8 0c             	shr    $0xc,%eax
  800e61:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e68:	f6 c4 08             	test   $0x8,%ah
  800e6b:	75 14                	jne    800e81 <pgfault+0x37>
		panic("faulting access");
  800e6d:	83 ec 04             	sub    $0x4,%esp
  800e70:	68 aa 2c 80 00       	push   $0x802caa
  800e75:	6a 1e                	push   $0x1e
  800e77:	68 ba 2c 80 00       	push   $0x802cba
  800e7c:	e8 37 f3 ff ff       	call   8001b8 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e81:	83 ec 04             	sub    $0x4,%esp
  800e84:	6a 07                	push   $0x7
  800e86:	68 00 f0 7f 00       	push   $0x7ff000
  800e8b:	6a 00                	push   $0x0
  800e8d:	e8 87 fd ff ff       	call   800c19 <sys_page_alloc>
	if (r < 0) {
  800e92:	83 c4 10             	add    $0x10,%esp
  800e95:	85 c0                	test   %eax,%eax
  800e97:	79 12                	jns    800eab <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e99:	50                   	push   %eax
  800e9a:	68 c5 2c 80 00       	push   $0x802cc5
  800e9f:	6a 2c                	push   $0x2c
  800ea1:	68 ba 2c 80 00       	push   $0x802cba
  800ea6:	e8 0d f3 ff ff       	call   8001b8 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800eab:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800eb1:	83 ec 04             	sub    $0x4,%esp
  800eb4:	68 00 10 00 00       	push   $0x1000
  800eb9:	53                   	push   %ebx
  800eba:	68 00 f0 7f 00       	push   $0x7ff000
  800ebf:	e8 4c fb ff ff       	call   800a10 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800ec4:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ecb:	53                   	push   %ebx
  800ecc:	6a 00                	push   $0x0
  800ece:	68 00 f0 7f 00       	push   $0x7ff000
  800ed3:	6a 00                	push   $0x0
  800ed5:	e8 82 fd ff ff       	call   800c5c <sys_page_map>
	if (r < 0) {
  800eda:	83 c4 20             	add    $0x20,%esp
  800edd:	85 c0                	test   %eax,%eax
  800edf:	79 12                	jns    800ef3 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800ee1:	50                   	push   %eax
  800ee2:	68 c5 2c 80 00       	push   $0x802cc5
  800ee7:	6a 33                	push   $0x33
  800ee9:	68 ba 2c 80 00       	push   $0x802cba
  800eee:	e8 c5 f2 ff ff       	call   8001b8 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800ef3:	83 ec 08             	sub    $0x8,%esp
  800ef6:	68 00 f0 7f 00       	push   $0x7ff000
  800efb:	6a 00                	push   $0x0
  800efd:	e8 9c fd ff ff       	call   800c9e <sys_page_unmap>
	if (r < 0) {
  800f02:	83 c4 10             	add    $0x10,%esp
  800f05:	85 c0                	test   %eax,%eax
  800f07:	79 12                	jns    800f1b <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800f09:	50                   	push   %eax
  800f0a:	68 c5 2c 80 00       	push   $0x802cc5
  800f0f:	6a 37                	push   $0x37
  800f11:	68 ba 2c 80 00       	push   $0x802cba
  800f16:	e8 9d f2 ff ff       	call   8001b8 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800f1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f1e:	c9                   	leave  
  800f1f:	c3                   	ret    

00800f20 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	57                   	push   %edi
  800f24:	56                   	push   %esi
  800f25:	53                   	push   %ebx
  800f26:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800f29:	68 4a 0e 80 00       	push   $0x800e4a
  800f2e:	e8 d5 14 00 00       	call   802408 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f33:	b8 07 00 00 00       	mov    $0x7,%eax
  800f38:	cd 30                	int    $0x30
  800f3a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800f3d:	83 c4 10             	add    $0x10,%esp
  800f40:	85 c0                	test   %eax,%eax
  800f42:	79 17                	jns    800f5b <fork+0x3b>
		panic("fork fault %e");
  800f44:	83 ec 04             	sub    $0x4,%esp
  800f47:	68 de 2c 80 00       	push   $0x802cde
  800f4c:	68 84 00 00 00       	push   $0x84
  800f51:	68 ba 2c 80 00       	push   $0x802cba
  800f56:	e8 5d f2 ff ff       	call   8001b8 <_panic>
  800f5b:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f5d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f61:	75 25                	jne    800f88 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f63:	e8 73 fc ff ff       	call   800bdb <sys_getenvid>
  800f68:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f6d:	89 c2                	mov    %eax,%edx
  800f6f:	c1 e2 07             	shl    $0x7,%edx
  800f72:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800f79:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f83:	e9 61 01 00 00       	jmp    8010e9 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f88:	83 ec 04             	sub    $0x4,%esp
  800f8b:	6a 07                	push   $0x7
  800f8d:	68 00 f0 bf ee       	push   $0xeebff000
  800f92:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f95:	e8 7f fc ff ff       	call   800c19 <sys_page_alloc>
  800f9a:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f9d:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fa2:	89 d8                	mov    %ebx,%eax
  800fa4:	c1 e8 16             	shr    $0x16,%eax
  800fa7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fae:	a8 01                	test   $0x1,%al
  800fb0:	0f 84 fc 00 00 00    	je     8010b2 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800fb6:	89 d8                	mov    %ebx,%eax
  800fb8:	c1 e8 0c             	shr    $0xc,%eax
  800fbb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fc2:	f6 c2 01             	test   $0x1,%dl
  800fc5:	0f 84 e7 00 00 00    	je     8010b2 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800fcb:	89 c6                	mov    %eax,%esi
  800fcd:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800fd0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fd7:	f6 c6 04             	test   $0x4,%dh
  800fda:	74 39                	je     801015 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800fdc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fe3:	83 ec 0c             	sub    $0xc,%esp
  800fe6:	25 07 0e 00 00       	and    $0xe07,%eax
  800feb:	50                   	push   %eax
  800fec:	56                   	push   %esi
  800fed:	57                   	push   %edi
  800fee:	56                   	push   %esi
  800fef:	6a 00                	push   $0x0
  800ff1:	e8 66 fc ff ff       	call   800c5c <sys_page_map>
		if (r < 0) {
  800ff6:	83 c4 20             	add    $0x20,%esp
  800ff9:	85 c0                	test   %eax,%eax
  800ffb:	0f 89 b1 00 00 00    	jns    8010b2 <fork+0x192>
		    	panic("sys page map fault %e");
  801001:	83 ec 04             	sub    $0x4,%esp
  801004:	68 ec 2c 80 00       	push   $0x802cec
  801009:	6a 54                	push   $0x54
  80100b:	68 ba 2c 80 00       	push   $0x802cba
  801010:	e8 a3 f1 ff ff       	call   8001b8 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801015:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80101c:	f6 c2 02             	test   $0x2,%dl
  80101f:	75 0c                	jne    80102d <fork+0x10d>
  801021:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801028:	f6 c4 08             	test   $0x8,%ah
  80102b:	74 5b                	je     801088 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80102d:	83 ec 0c             	sub    $0xc,%esp
  801030:	68 05 08 00 00       	push   $0x805
  801035:	56                   	push   %esi
  801036:	57                   	push   %edi
  801037:	56                   	push   %esi
  801038:	6a 00                	push   $0x0
  80103a:	e8 1d fc ff ff       	call   800c5c <sys_page_map>
		if (r < 0) {
  80103f:	83 c4 20             	add    $0x20,%esp
  801042:	85 c0                	test   %eax,%eax
  801044:	79 14                	jns    80105a <fork+0x13a>
		    	panic("sys page map fault %e");
  801046:	83 ec 04             	sub    $0x4,%esp
  801049:	68 ec 2c 80 00       	push   $0x802cec
  80104e:	6a 5b                	push   $0x5b
  801050:	68 ba 2c 80 00       	push   $0x802cba
  801055:	e8 5e f1 ff ff       	call   8001b8 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  80105a:	83 ec 0c             	sub    $0xc,%esp
  80105d:	68 05 08 00 00       	push   $0x805
  801062:	56                   	push   %esi
  801063:	6a 00                	push   $0x0
  801065:	56                   	push   %esi
  801066:	6a 00                	push   $0x0
  801068:	e8 ef fb ff ff       	call   800c5c <sys_page_map>
		if (r < 0) {
  80106d:	83 c4 20             	add    $0x20,%esp
  801070:	85 c0                	test   %eax,%eax
  801072:	79 3e                	jns    8010b2 <fork+0x192>
		    	panic("sys page map fault %e");
  801074:	83 ec 04             	sub    $0x4,%esp
  801077:	68 ec 2c 80 00       	push   $0x802cec
  80107c:	6a 5f                	push   $0x5f
  80107e:	68 ba 2c 80 00       	push   $0x802cba
  801083:	e8 30 f1 ff ff       	call   8001b8 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801088:	83 ec 0c             	sub    $0xc,%esp
  80108b:	6a 05                	push   $0x5
  80108d:	56                   	push   %esi
  80108e:	57                   	push   %edi
  80108f:	56                   	push   %esi
  801090:	6a 00                	push   $0x0
  801092:	e8 c5 fb ff ff       	call   800c5c <sys_page_map>
		if (r < 0) {
  801097:	83 c4 20             	add    $0x20,%esp
  80109a:	85 c0                	test   %eax,%eax
  80109c:	79 14                	jns    8010b2 <fork+0x192>
		    	panic("sys page map fault %e");
  80109e:	83 ec 04             	sub    $0x4,%esp
  8010a1:	68 ec 2c 80 00       	push   $0x802cec
  8010a6:	6a 64                	push   $0x64
  8010a8:	68 ba 2c 80 00       	push   $0x802cba
  8010ad:	e8 06 f1 ff ff       	call   8001b8 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8010b2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010b8:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8010be:	0f 85 de fe ff ff    	jne    800fa2 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8010c4:	a1 04 40 80 00       	mov    0x804004,%eax
  8010c9:	8b 40 70             	mov    0x70(%eax),%eax
  8010cc:	83 ec 08             	sub    $0x8,%esp
  8010cf:	50                   	push   %eax
  8010d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010d3:	57                   	push   %edi
  8010d4:	e8 8b fc ff ff       	call   800d64 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8010d9:	83 c4 08             	add    $0x8,%esp
  8010dc:	6a 02                	push   $0x2
  8010de:	57                   	push   %edi
  8010df:	e8 fc fb ff ff       	call   800ce0 <sys_env_set_status>
	
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
  801103:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  801109:	83 ec 08             	sub    $0x8,%esp
  80110c:	53                   	push   %ebx
  80110d:	68 04 2d 80 00       	push   $0x802d04
  801112:	e8 7a f1 ff ff       	call   800291 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801117:	c7 04 24 7e 01 80 00 	movl   $0x80017e,(%esp)
  80111e:	e8 e7 fc ff ff       	call   800e0a <sys_thread_create>
  801123:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801125:	83 c4 08             	add    $0x8,%esp
  801128:	53                   	push   %ebx
  801129:	68 04 2d 80 00       	push   $0x802d04
  80112e:	e8 5e f1 ff ff       	call   800291 <cprintf>
	return id;
	//return 0;
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
  801211:	ba a4 2d 80 00       	mov    $0x802da4,%edx
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
  801231:	a1 04 40 80 00       	mov    0x804004,%eax
  801236:	8b 40 54             	mov    0x54(%eax),%eax
  801239:	83 ec 04             	sub    $0x4,%esp
  80123c:	51                   	push   %ecx
  80123d:	50                   	push   %eax
  80123e:	68 28 2d 80 00       	push   $0x802d28
  801243:	e8 49 f0 ff ff       	call   800291 <cprintf>
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
  8012cb:	e8 ce f9 ff ff       	call   800c9e <sys_page_unmap>
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
  8013b7:	e8 a0 f8 ff ff       	call   800c5c <sys_page_map>
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
  8013e3:	e8 74 f8 ff ff       	call   800c5c <sys_page_map>
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
  8013f9:	e8 a0 f8 ff ff       	call   800c9e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013fe:	83 c4 08             	add    $0x8,%esp
  801401:	ff 75 d4             	pushl  -0x2c(%ebp)
  801404:	6a 00                	push   $0x0
  801406:	e8 93 f8 ff ff       	call   800c9e <sys_page_unmap>
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
  80145b:	a1 04 40 80 00       	mov    0x804004,%eax
  801460:	8b 40 54             	mov    0x54(%eax),%eax
  801463:	83 ec 04             	sub    $0x4,%esp
  801466:	53                   	push   %ebx
  801467:	50                   	push   %eax
  801468:	68 69 2d 80 00       	push   $0x802d69
  80146d:	e8 1f ee ff ff       	call   800291 <cprintf>
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
  801530:	a1 04 40 80 00       	mov    0x804004,%eax
  801535:	8b 40 54             	mov    0x54(%eax),%eax
  801538:	83 ec 04             	sub    $0x4,%esp
  80153b:	53                   	push   %ebx
  80153c:	50                   	push   %eax
  80153d:	68 85 2d 80 00       	push   $0x802d85
  801542:	e8 4a ed ff ff       	call   800291 <cprintf>
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
  8015e5:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015ea:	8b 40 54             	mov    0x54(%eax),%eax
  8015ed:	83 ec 04             	sub    $0x4,%esp
  8015f0:	53                   	push   %ebx
  8015f1:	50                   	push   %eax
  8015f2:	68 48 2d 80 00       	push   $0x802d48
  8015f7:	e8 95 ec ff ff       	call   800291 <cprintf>
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
  801702:	e8 6a 0e 00 00       	call   802571 <ipc_find_env>
  801707:	a3 00 40 80 00       	mov    %eax,0x804000
  80170c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80170f:	6a 07                	push   $0x7
  801711:	68 00 50 80 00       	push   $0x805000
  801716:	56                   	push   %esi
  801717:	ff 35 00 40 80 00    	pushl  0x804000
  80171d:	e8 ed 0d 00 00       	call   80250f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801722:	83 c4 0c             	add    $0xc,%esp
  801725:	6a 00                	push   $0x0
  801727:	53                   	push   %ebx
  801728:	6a 00                	push   $0x0
  80172a:	e8 68 0d 00 00       	call   802497 <ipc_recv>
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
  801742:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801747:	8b 45 0c             	mov    0xc(%ebp),%eax
  80174a:	a3 04 50 80 00       	mov    %eax,0x805004
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
  80176c:	a3 00 50 80 00       	mov    %eax,0x805000
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
  801792:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801797:	ba 00 00 00 00       	mov    $0x0,%edx
  80179c:	b8 05 00 00 00       	mov    $0x5,%eax
  8017a1:	e8 45 ff ff ff       	call   8016eb <fsipc>
  8017a6:	85 c0                	test   %eax,%eax
  8017a8:	78 2c                	js     8017d6 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017aa:	83 ec 08             	sub    $0x8,%esp
  8017ad:	68 00 50 80 00       	push   $0x805000
  8017b2:	53                   	push   %ebx
  8017b3:	e8 5e f0 ff ff       	call   800816 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017b8:	a1 80 50 80 00       	mov    0x805080,%eax
  8017bd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017c3:	a1 84 50 80 00       	mov    0x805084,%eax
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
  8017ea:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8017f0:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017f5:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017fa:	0f 47 c2             	cmova  %edx,%eax
  8017fd:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801802:	50                   	push   %eax
  801803:	ff 75 0c             	pushl  0xc(%ebp)
  801806:	68 08 50 80 00       	push   $0x805008
  80180b:	e8 98 f1 ff ff       	call   8009a8 <memmove>

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
  80182f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801834:	89 35 04 50 80 00    	mov    %esi,0x805004
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
  801853:	68 b4 2d 80 00       	push   $0x802db4
  801858:	68 bb 2d 80 00       	push   $0x802dbb
  80185d:	6a 7c                	push   $0x7c
  80185f:	68 d0 2d 80 00       	push   $0x802dd0
  801864:	e8 4f e9 ff ff       	call   8001b8 <_panic>
	assert(r <= PGSIZE);
  801869:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80186e:	7e 16                	jle    801886 <devfile_read+0x65>
  801870:	68 db 2d 80 00       	push   $0x802ddb
  801875:	68 bb 2d 80 00       	push   $0x802dbb
  80187a:	6a 7d                	push   $0x7d
  80187c:	68 d0 2d 80 00       	push   $0x802dd0
  801881:	e8 32 e9 ff ff       	call   8001b8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801886:	83 ec 04             	sub    $0x4,%esp
  801889:	50                   	push   %eax
  80188a:	68 00 50 80 00       	push   $0x805000
  80188f:	ff 75 0c             	pushl  0xc(%ebp)
  801892:	e8 11 f1 ff ff       	call   8009a8 <memmove>
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
  8018ae:	e8 2a ef ff ff       	call   8007dd <strlen>
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
  8018d6:	68 00 50 80 00       	push   $0x805000
  8018db:	e8 36 ef ff ff       	call   800816 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e3:	a3 00 54 80 00       	mov    %eax,0x805400

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

00801947 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801947:	55                   	push   %ebp
  801948:	89 e5                	mov    %esp,%ebp
  80194a:	57                   	push   %edi
  80194b:	56                   	push   %esi
  80194c:	53                   	push   %ebx
  80194d:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801953:	6a 00                	push   $0x0
  801955:	ff 75 08             	pushl  0x8(%ebp)
  801958:	e8 46 ff ff ff       	call   8018a3 <open>
  80195d:	89 c7                	mov    %eax,%edi
  80195f:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801965:	83 c4 10             	add    $0x10,%esp
  801968:	85 c0                	test   %eax,%eax
  80196a:	0f 88 89 04 00 00    	js     801df9 <spawn+0x4b2>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801970:	83 ec 04             	sub    $0x4,%esp
  801973:	68 00 02 00 00       	push   $0x200
  801978:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80197e:	50                   	push   %eax
  80197f:	57                   	push   %edi
  801980:	e8 24 fb ff ff       	call   8014a9 <readn>
  801985:	83 c4 10             	add    $0x10,%esp
  801988:	3d 00 02 00 00       	cmp    $0x200,%eax
  80198d:	75 0c                	jne    80199b <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  80198f:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801996:	45 4c 46 
  801999:	74 33                	je     8019ce <spawn+0x87>
		close(fd);
  80199b:	83 ec 0c             	sub    $0xc,%esp
  80199e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019a4:	e8 33 f9 ff ff       	call   8012dc <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8019a9:	83 c4 0c             	add    $0xc,%esp
  8019ac:	68 7f 45 4c 46       	push   $0x464c457f
  8019b1:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8019b7:	68 e7 2d 80 00       	push   $0x802de7
  8019bc:	e8 d0 e8 ff ff       	call   800291 <cprintf>
		return -E_NOT_EXEC;
  8019c1:	83 c4 10             	add    $0x10,%esp
  8019c4:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8019c9:	e9 de 04 00 00       	jmp    801eac <spawn+0x565>
  8019ce:	b8 07 00 00 00       	mov    $0x7,%eax
  8019d3:	cd 30                	int    $0x30
  8019d5:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8019db:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8019e1:	85 c0                	test   %eax,%eax
  8019e3:	0f 88 1b 04 00 00    	js     801e04 <spawn+0x4bd>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8019e9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8019ee:	89 c2                	mov    %eax,%edx
  8019f0:	c1 e2 07             	shl    $0x7,%edx
  8019f3:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8019f9:	8d b4 c2 0c 00 c0 ee 	lea    -0x113ffff4(%edx,%eax,8),%esi
  801a00:	b9 11 00 00 00       	mov    $0x11,%ecx
  801a05:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801a07:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801a0d:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a13:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801a18:	be 00 00 00 00       	mov    $0x0,%esi
  801a1d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a20:	eb 13                	jmp    801a35 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801a22:	83 ec 0c             	sub    $0xc,%esp
  801a25:	50                   	push   %eax
  801a26:	e8 b2 ed ff ff       	call   8007dd <strlen>
  801a2b:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a2f:	83 c3 01             	add    $0x1,%ebx
  801a32:	83 c4 10             	add    $0x10,%esp
  801a35:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801a3c:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801a3f:	85 c0                	test   %eax,%eax
  801a41:	75 df                	jne    801a22 <spawn+0xdb>
  801a43:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801a49:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801a4f:	bf 00 10 40 00       	mov    $0x401000,%edi
  801a54:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801a56:	89 fa                	mov    %edi,%edx
  801a58:	83 e2 fc             	and    $0xfffffffc,%edx
  801a5b:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801a62:	29 c2                	sub    %eax,%edx
  801a64:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801a6a:	8d 42 f8             	lea    -0x8(%edx),%eax
  801a6d:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801a72:	0f 86 a2 03 00 00    	jbe    801e1a <spawn+0x4d3>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a78:	83 ec 04             	sub    $0x4,%esp
  801a7b:	6a 07                	push   $0x7
  801a7d:	68 00 00 40 00       	push   $0x400000
  801a82:	6a 00                	push   $0x0
  801a84:	e8 90 f1 ff ff       	call   800c19 <sys_page_alloc>
  801a89:	83 c4 10             	add    $0x10,%esp
  801a8c:	85 c0                	test   %eax,%eax
  801a8e:	0f 88 90 03 00 00    	js     801e24 <spawn+0x4dd>
  801a94:	be 00 00 00 00       	mov    $0x0,%esi
  801a99:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801a9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801aa2:	eb 30                	jmp    801ad4 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801aa4:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801aaa:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801ab0:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801ab3:	83 ec 08             	sub    $0x8,%esp
  801ab6:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801ab9:	57                   	push   %edi
  801aba:	e8 57 ed ff ff       	call   800816 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801abf:	83 c4 04             	add    $0x4,%esp
  801ac2:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801ac5:	e8 13 ed ff ff       	call   8007dd <strlen>
  801aca:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801ace:	83 c6 01             	add    $0x1,%esi
  801ad1:	83 c4 10             	add    $0x10,%esp
  801ad4:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801ada:	7f c8                	jg     801aa4 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801adc:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801ae2:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801ae8:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801aef:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801af5:	74 19                	je     801b10 <spawn+0x1c9>
  801af7:	68 74 2e 80 00       	push   $0x802e74
  801afc:	68 bb 2d 80 00       	push   $0x802dbb
  801b01:	68 f2 00 00 00       	push   $0xf2
  801b06:	68 01 2e 80 00       	push   $0x802e01
  801b0b:	e8 a8 e6 ff ff       	call   8001b8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801b10:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801b16:	89 f8                	mov    %edi,%eax
  801b18:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801b1d:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801b20:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b26:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801b29:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801b2f:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801b35:	83 ec 0c             	sub    $0xc,%esp
  801b38:	6a 07                	push   $0x7
  801b3a:	68 00 d0 bf ee       	push   $0xeebfd000
  801b3f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b45:	68 00 00 40 00       	push   $0x400000
  801b4a:	6a 00                	push   $0x0
  801b4c:	e8 0b f1 ff ff       	call   800c5c <sys_page_map>
  801b51:	89 c3                	mov    %eax,%ebx
  801b53:	83 c4 20             	add    $0x20,%esp
  801b56:	85 c0                	test   %eax,%eax
  801b58:	0f 88 3c 03 00 00    	js     801e9a <spawn+0x553>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801b5e:	83 ec 08             	sub    $0x8,%esp
  801b61:	68 00 00 40 00       	push   $0x400000
  801b66:	6a 00                	push   $0x0
  801b68:	e8 31 f1 ff ff       	call   800c9e <sys_page_unmap>
  801b6d:	89 c3                	mov    %eax,%ebx
  801b6f:	83 c4 10             	add    $0x10,%esp
  801b72:	85 c0                	test   %eax,%eax
  801b74:	0f 88 20 03 00 00    	js     801e9a <spawn+0x553>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b7a:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801b80:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801b87:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b8d:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801b94:	00 00 00 
  801b97:	e9 88 01 00 00       	jmp    801d24 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801b9c:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801ba2:	83 38 01             	cmpl   $0x1,(%eax)
  801ba5:	0f 85 6b 01 00 00    	jne    801d16 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801bab:	89 c2                	mov    %eax,%edx
  801bad:	8b 40 18             	mov    0x18(%eax),%eax
  801bb0:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801bb6:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801bb9:	83 f8 01             	cmp    $0x1,%eax
  801bbc:	19 c0                	sbb    %eax,%eax
  801bbe:	83 e0 fe             	and    $0xfffffffe,%eax
  801bc1:	83 c0 07             	add    $0x7,%eax
  801bc4:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801bca:	89 d0                	mov    %edx,%eax
  801bcc:	8b 7a 04             	mov    0x4(%edx),%edi
  801bcf:	89 f9                	mov    %edi,%ecx
  801bd1:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801bd7:	8b 7a 10             	mov    0x10(%edx),%edi
  801bda:	8b 52 14             	mov    0x14(%edx),%edx
  801bdd:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801be3:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801be6:	89 f0                	mov    %esi,%eax
  801be8:	25 ff 0f 00 00       	and    $0xfff,%eax
  801bed:	74 14                	je     801c03 <spawn+0x2bc>
		va -= i;
  801bef:	29 c6                	sub    %eax,%esi
		memsz += i;
  801bf1:	01 c2                	add    %eax,%edx
  801bf3:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801bf9:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801bfb:	29 c1                	sub    %eax,%ecx
  801bfd:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c03:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c08:	e9 f7 00 00 00       	jmp    801d04 <spawn+0x3bd>
		if (i >= filesz) {
  801c0d:	39 fb                	cmp    %edi,%ebx
  801c0f:	72 27                	jb     801c38 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801c11:	83 ec 04             	sub    $0x4,%esp
  801c14:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c1a:	56                   	push   %esi
  801c1b:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c21:	e8 f3 ef ff ff       	call   800c19 <sys_page_alloc>
  801c26:	83 c4 10             	add    $0x10,%esp
  801c29:	85 c0                	test   %eax,%eax
  801c2b:	0f 89 c7 00 00 00    	jns    801cf8 <spawn+0x3b1>
  801c31:	89 c3                	mov    %eax,%ebx
  801c33:	e9 fd 01 00 00       	jmp    801e35 <spawn+0x4ee>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801c38:	83 ec 04             	sub    $0x4,%esp
  801c3b:	6a 07                	push   $0x7
  801c3d:	68 00 00 40 00       	push   $0x400000
  801c42:	6a 00                	push   $0x0
  801c44:	e8 d0 ef ff ff       	call   800c19 <sys_page_alloc>
  801c49:	83 c4 10             	add    $0x10,%esp
  801c4c:	85 c0                	test   %eax,%eax
  801c4e:	0f 88 d7 01 00 00    	js     801e2b <spawn+0x4e4>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801c54:	83 ec 08             	sub    $0x8,%esp
  801c57:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801c5d:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801c63:	50                   	push   %eax
  801c64:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c6a:	e8 0f f9 ff ff       	call   80157e <seek>
  801c6f:	83 c4 10             	add    $0x10,%esp
  801c72:	85 c0                	test   %eax,%eax
  801c74:	0f 88 b5 01 00 00    	js     801e2f <spawn+0x4e8>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801c7a:	83 ec 04             	sub    $0x4,%esp
  801c7d:	89 f8                	mov    %edi,%eax
  801c7f:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801c85:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c8a:	ba 00 10 00 00       	mov    $0x1000,%edx
  801c8f:	0f 47 c2             	cmova  %edx,%eax
  801c92:	50                   	push   %eax
  801c93:	68 00 00 40 00       	push   $0x400000
  801c98:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c9e:	e8 06 f8 ff ff       	call   8014a9 <readn>
  801ca3:	83 c4 10             	add    $0x10,%esp
  801ca6:	85 c0                	test   %eax,%eax
  801ca8:	0f 88 85 01 00 00    	js     801e33 <spawn+0x4ec>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801cae:	83 ec 0c             	sub    $0xc,%esp
  801cb1:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801cb7:	56                   	push   %esi
  801cb8:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801cbe:	68 00 00 40 00       	push   $0x400000
  801cc3:	6a 00                	push   $0x0
  801cc5:	e8 92 ef ff ff       	call   800c5c <sys_page_map>
  801cca:	83 c4 20             	add    $0x20,%esp
  801ccd:	85 c0                	test   %eax,%eax
  801ccf:	79 15                	jns    801ce6 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801cd1:	50                   	push   %eax
  801cd2:	68 0d 2e 80 00       	push   $0x802e0d
  801cd7:	68 25 01 00 00       	push   $0x125
  801cdc:	68 01 2e 80 00       	push   $0x802e01
  801ce1:	e8 d2 e4 ff ff       	call   8001b8 <_panic>
			sys_page_unmap(0, UTEMP);
  801ce6:	83 ec 08             	sub    $0x8,%esp
  801ce9:	68 00 00 40 00       	push   $0x400000
  801cee:	6a 00                	push   $0x0
  801cf0:	e8 a9 ef ff ff       	call   800c9e <sys_page_unmap>
  801cf5:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801cf8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801cfe:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801d04:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801d0a:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801d10:	0f 82 f7 fe ff ff    	jb     801c0d <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d16:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801d1d:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801d24:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801d2b:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801d31:	0f 8c 65 fe ff ff    	jl     801b9c <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801d37:	83 ec 0c             	sub    $0xc,%esp
  801d3a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d40:	e8 97 f5 ff ff       	call   8012dc <close>
  801d45:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801d48:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d4d:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801d53:	89 d8                	mov    %ebx,%eax
  801d55:	c1 e8 16             	shr    $0x16,%eax
  801d58:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801d5f:	a8 01                	test   $0x1,%al
  801d61:	74 42                	je     801da5 <spawn+0x45e>
  801d63:	89 d8                	mov    %ebx,%eax
  801d65:	c1 e8 0c             	shr    $0xc,%eax
  801d68:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d6f:	f6 c2 01             	test   $0x1,%dl
  801d72:	74 31                	je     801da5 <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  801d74:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801d7b:	f6 c6 04             	test   $0x4,%dh
  801d7e:	74 25                	je     801da5 <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  801d80:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801d87:	83 ec 0c             	sub    $0xc,%esp
  801d8a:	25 07 0e 00 00       	and    $0xe07,%eax
  801d8f:	50                   	push   %eax
  801d90:	53                   	push   %ebx
  801d91:	56                   	push   %esi
  801d92:	53                   	push   %ebx
  801d93:	6a 00                	push   $0x0
  801d95:	e8 c2 ee ff ff       	call   800c5c <sys_page_map>
			if (r < 0) {
  801d9a:	83 c4 20             	add    $0x20,%esp
  801d9d:	85 c0                	test   %eax,%eax
  801d9f:	0f 88 b1 00 00 00    	js     801e56 <spawn+0x50f>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801da5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801dab:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801db1:	75 a0                	jne    801d53 <spawn+0x40c>
  801db3:	e9 b3 00 00 00       	jmp    801e6b <spawn+0x524>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801db8:	50                   	push   %eax
  801db9:	68 2a 2e 80 00       	push   $0x802e2a
  801dbe:	68 86 00 00 00       	push   $0x86
  801dc3:	68 01 2e 80 00       	push   $0x802e01
  801dc8:	e8 eb e3 ff ff       	call   8001b8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801dcd:	83 ec 08             	sub    $0x8,%esp
  801dd0:	6a 02                	push   $0x2
  801dd2:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801dd8:	e8 03 ef ff ff       	call   800ce0 <sys_env_set_status>
  801ddd:	83 c4 10             	add    $0x10,%esp
  801de0:	85 c0                	test   %eax,%eax
  801de2:	79 2b                	jns    801e0f <spawn+0x4c8>
		panic("sys_env_set_status: %e", r);
  801de4:	50                   	push   %eax
  801de5:	68 44 2e 80 00       	push   $0x802e44
  801dea:	68 89 00 00 00       	push   $0x89
  801def:	68 01 2e 80 00       	push   $0x802e01
  801df4:	e8 bf e3 ff ff       	call   8001b8 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801df9:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801dff:	e9 a8 00 00 00       	jmp    801eac <spawn+0x565>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801e04:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e0a:	e9 9d 00 00 00       	jmp    801eac <spawn+0x565>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801e0f:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e15:	e9 92 00 00 00       	jmp    801eac <spawn+0x565>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801e1a:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801e1f:	e9 88 00 00 00       	jmp    801eac <spawn+0x565>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801e24:	89 c3                	mov    %eax,%ebx
  801e26:	e9 81 00 00 00       	jmp    801eac <spawn+0x565>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e2b:	89 c3                	mov    %eax,%ebx
  801e2d:	eb 06                	jmp    801e35 <spawn+0x4ee>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801e2f:	89 c3                	mov    %eax,%ebx
  801e31:	eb 02                	jmp    801e35 <spawn+0x4ee>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801e33:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801e35:	83 ec 0c             	sub    $0xc,%esp
  801e38:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e3e:	e8 57 ed ff ff       	call   800b9a <sys_env_destroy>
	close(fd);
  801e43:	83 c4 04             	add    $0x4,%esp
  801e46:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e4c:	e8 8b f4 ff ff       	call   8012dc <close>
	return r;
  801e51:	83 c4 10             	add    $0x10,%esp
  801e54:	eb 56                	jmp    801eac <spawn+0x565>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801e56:	50                   	push   %eax
  801e57:	68 5b 2e 80 00       	push   $0x802e5b
  801e5c:	68 82 00 00 00       	push   $0x82
  801e61:	68 01 2e 80 00       	push   $0x802e01
  801e66:	e8 4d e3 ff ff       	call   8001b8 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801e6b:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801e72:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801e75:	83 ec 08             	sub    $0x8,%esp
  801e78:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801e7e:	50                   	push   %eax
  801e7f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e85:	e8 98 ee ff ff       	call   800d22 <sys_env_set_trapframe>
  801e8a:	83 c4 10             	add    $0x10,%esp
  801e8d:	85 c0                	test   %eax,%eax
  801e8f:	0f 89 38 ff ff ff    	jns    801dcd <spawn+0x486>
  801e95:	e9 1e ff ff ff       	jmp    801db8 <spawn+0x471>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801e9a:	83 ec 08             	sub    $0x8,%esp
  801e9d:	68 00 00 40 00       	push   $0x400000
  801ea2:	6a 00                	push   $0x0
  801ea4:	e8 f5 ed ff ff       	call   800c9e <sys_page_unmap>
  801ea9:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801eac:	89 d8                	mov    %ebx,%eax
  801eae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eb1:	5b                   	pop    %ebx
  801eb2:	5e                   	pop    %esi
  801eb3:	5f                   	pop    %edi
  801eb4:	5d                   	pop    %ebp
  801eb5:	c3                   	ret    

00801eb6 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801eb6:	55                   	push   %ebp
  801eb7:	89 e5                	mov    %esp,%ebp
  801eb9:	56                   	push   %esi
  801eba:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ebb:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801ebe:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ec3:	eb 03                	jmp    801ec8 <spawnl+0x12>
		argc++;
  801ec5:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ec8:	83 c2 04             	add    $0x4,%edx
  801ecb:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801ecf:	75 f4                	jne    801ec5 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801ed1:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801ed8:	83 e2 f0             	and    $0xfffffff0,%edx
  801edb:	29 d4                	sub    %edx,%esp
  801edd:	8d 54 24 03          	lea    0x3(%esp),%edx
  801ee1:	c1 ea 02             	shr    $0x2,%edx
  801ee4:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801eeb:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801eed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ef0:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801ef7:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801efe:	00 
  801eff:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f01:	b8 00 00 00 00       	mov    $0x0,%eax
  801f06:	eb 0a                	jmp    801f12 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801f08:	83 c0 01             	add    $0x1,%eax
  801f0b:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801f0f:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f12:	39 d0                	cmp    %edx,%eax
  801f14:	75 f2                	jne    801f08 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801f16:	83 ec 08             	sub    $0x8,%esp
  801f19:	56                   	push   %esi
  801f1a:	ff 75 08             	pushl  0x8(%ebp)
  801f1d:	e8 25 fa ff ff       	call   801947 <spawn>
}
  801f22:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f25:	5b                   	pop    %ebx
  801f26:	5e                   	pop    %esi
  801f27:	5d                   	pop    %ebp
  801f28:	c3                   	ret    

00801f29 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f29:	55                   	push   %ebp
  801f2a:	89 e5                	mov    %esp,%ebp
  801f2c:	56                   	push   %esi
  801f2d:	53                   	push   %ebx
  801f2e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f31:	83 ec 0c             	sub    $0xc,%esp
  801f34:	ff 75 08             	pushl  0x8(%ebp)
  801f37:	e8 10 f2 ff ff       	call   80114c <fd2data>
  801f3c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f3e:	83 c4 08             	add    $0x8,%esp
  801f41:	68 9c 2e 80 00       	push   $0x802e9c
  801f46:	53                   	push   %ebx
  801f47:	e8 ca e8 ff ff       	call   800816 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f4c:	8b 46 04             	mov    0x4(%esi),%eax
  801f4f:	2b 06                	sub    (%esi),%eax
  801f51:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f57:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f5e:	00 00 00 
	stat->st_dev = &devpipe;
  801f61:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801f68:	30 80 00 
	return 0;
}
  801f6b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f70:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f73:	5b                   	pop    %ebx
  801f74:	5e                   	pop    %esi
  801f75:	5d                   	pop    %ebp
  801f76:	c3                   	ret    

00801f77 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f77:	55                   	push   %ebp
  801f78:	89 e5                	mov    %esp,%ebp
  801f7a:	53                   	push   %ebx
  801f7b:	83 ec 0c             	sub    $0xc,%esp
  801f7e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f81:	53                   	push   %ebx
  801f82:	6a 00                	push   $0x0
  801f84:	e8 15 ed ff ff       	call   800c9e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f89:	89 1c 24             	mov    %ebx,(%esp)
  801f8c:	e8 bb f1 ff ff       	call   80114c <fd2data>
  801f91:	83 c4 08             	add    $0x8,%esp
  801f94:	50                   	push   %eax
  801f95:	6a 00                	push   $0x0
  801f97:	e8 02 ed ff ff       	call   800c9e <sys_page_unmap>
}
  801f9c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f9f:	c9                   	leave  
  801fa0:	c3                   	ret    

00801fa1 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801fa1:	55                   	push   %ebp
  801fa2:	89 e5                	mov    %esp,%ebp
  801fa4:	57                   	push   %edi
  801fa5:	56                   	push   %esi
  801fa6:	53                   	push   %ebx
  801fa7:	83 ec 1c             	sub    $0x1c,%esp
  801faa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801fad:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801faf:	a1 04 40 80 00       	mov    0x804004,%eax
  801fb4:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801fb7:	83 ec 0c             	sub    $0xc,%esp
  801fba:	ff 75 e0             	pushl  -0x20(%ebp)
  801fbd:	e8 ef 05 00 00       	call   8025b1 <pageref>
  801fc2:	89 c3                	mov    %eax,%ebx
  801fc4:	89 3c 24             	mov    %edi,(%esp)
  801fc7:	e8 e5 05 00 00       	call   8025b1 <pageref>
  801fcc:	83 c4 10             	add    $0x10,%esp
  801fcf:	39 c3                	cmp    %eax,%ebx
  801fd1:	0f 94 c1             	sete   %cl
  801fd4:	0f b6 c9             	movzbl %cl,%ecx
  801fd7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801fda:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801fe0:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  801fe3:	39 ce                	cmp    %ecx,%esi
  801fe5:	74 1b                	je     802002 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801fe7:	39 c3                	cmp    %eax,%ebx
  801fe9:	75 c4                	jne    801faf <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801feb:	8b 42 64             	mov    0x64(%edx),%eax
  801fee:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ff1:	50                   	push   %eax
  801ff2:	56                   	push   %esi
  801ff3:	68 a3 2e 80 00       	push   $0x802ea3
  801ff8:	e8 94 e2 ff ff       	call   800291 <cprintf>
  801ffd:	83 c4 10             	add    $0x10,%esp
  802000:	eb ad                	jmp    801faf <_pipeisclosed+0xe>
	}
}
  802002:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802005:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802008:	5b                   	pop    %ebx
  802009:	5e                   	pop    %esi
  80200a:	5f                   	pop    %edi
  80200b:	5d                   	pop    %ebp
  80200c:	c3                   	ret    

0080200d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80200d:	55                   	push   %ebp
  80200e:	89 e5                	mov    %esp,%ebp
  802010:	57                   	push   %edi
  802011:	56                   	push   %esi
  802012:	53                   	push   %ebx
  802013:	83 ec 28             	sub    $0x28,%esp
  802016:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802019:	56                   	push   %esi
  80201a:	e8 2d f1 ff ff       	call   80114c <fd2data>
  80201f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802021:	83 c4 10             	add    $0x10,%esp
  802024:	bf 00 00 00 00       	mov    $0x0,%edi
  802029:	eb 4b                	jmp    802076 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80202b:	89 da                	mov    %ebx,%edx
  80202d:	89 f0                	mov    %esi,%eax
  80202f:	e8 6d ff ff ff       	call   801fa1 <_pipeisclosed>
  802034:	85 c0                	test   %eax,%eax
  802036:	75 48                	jne    802080 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802038:	e8 bd eb ff ff       	call   800bfa <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80203d:	8b 43 04             	mov    0x4(%ebx),%eax
  802040:	8b 0b                	mov    (%ebx),%ecx
  802042:	8d 51 20             	lea    0x20(%ecx),%edx
  802045:	39 d0                	cmp    %edx,%eax
  802047:	73 e2                	jae    80202b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802049:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80204c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802050:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802053:	89 c2                	mov    %eax,%edx
  802055:	c1 fa 1f             	sar    $0x1f,%edx
  802058:	89 d1                	mov    %edx,%ecx
  80205a:	c1 e9 1b             	shr    $0x1b,%ecx
  80205d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802060:	83 e2 1f             	and    $0x1f,%edx
  802063:	29 ca                	sub    %ecx,%edx
  802065:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802069:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80206d:	83 c0 01             	add    $0x1,%eax
  802070:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802073:	83 c7 01             	add    $0x1,%edi
  802076:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802079:	75 c2                	jne    80203d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80207b:	8b 45 10             	mov    0x10(%ebp),%eax
  80207e:	eb 05                	jmp    802085 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802080:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802085:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802088:	5b                   	pop    %ebx
  802089:	5e                   	pop    %esi
  80208a:	5f                   	pop    %edi
  80208b:	5d                   	pop    %ebp
  80208c:	c3                   	ret    

0080208d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80208d:	55                   	push   %ebp
  80208e:	89 e5                	mov    %esp,%ebp
  802090:	57                   	push   %edi
  802091:	56                   	push   %esi
  802092:	53                   	push   %ebx
  802093:	83 ec 18             	sub    $0x18,%esp
  802096:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802099:	57                   	push   %edi
  80209a:	e8 ad f0 ff ff       	call   80114c <fd2data>
  80209f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020a1:	83 c4 10             	add    $0x10,%esp
  8020a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020a9:	eb 3d                	jmp    8020e8 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8020ab:	85 db                	test   %ebx,%ebx
  8020ad:	74 04                	je     8020b3 <devpipe_read+0x26>
				return i;
  8020af:	89 d8                	mov    %ebx,%eax
  8020b1:	eb 44                	jmp    8020f7 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8020b3:	89 f2                	mov    %esi,%edx
  8020b5:	89 f8                	mov    %edi,%eax
  8020b7:	e8 e5 fe ff ff       	call   801fa1 <_pipeisclosed>
  8020bc:	85 c0                	test   %eax,%eax
  8020be:	75 32                	jne    8020f2 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8020c0:	e8 35 eb ff ff       	call   800bfa <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8020c5:	8b 06                	mov    (%esi),%eax
  8020c7:	3b 46 04             	cmp    0x4(%esi),%eax
  8020ca:	74 df                	je     8020ab <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020cc:	99                   	cltd   
  8020cd:	c1 ea 1b             	shr    $0x1b,%edx
  8020d0:	01 d0                	add    %edx,%eax
  8020d2:	83 e0 1f             	and    $0x1f,%eax
  8020d5:	29 d0                	sub    %edx,%eax
  8020d7:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8020dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020df:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8020e2:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020e5:	83 c3 01             	add    $0x1,%ebx
  8020e8:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020eb:	75 d8                	jne    8020c5 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8020ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8020f0:	eb 05                	jmp    8020f7 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020f2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8020f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020fa:	5b                   	pop    %ebx
  8020fb:	5e                   	pop    %esi
  8020fc:	5f                   	pop    %edi
  8020fd:	5d                   	pop    %ebp
  8020fe:	c3                   	ret    

008020ff <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8020ff:	55                   	push   %ebp
  802100:	89 e5                	mov    %esp,%ebp
  802102:	56                   	push   %esi
  802103:	53                   	push   %ebx
  802104:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802107:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80210a:	50                   	push   %eax
  80210b:	e8 53 f0 ff ff       	call   801163 <fd_alloc>
  802110:	83 c4 10             	add    $0x10,%esp
  802113:	89 c2                	mov    %eax,%edx
  802115:	85 c0                	test   %eax,%eax
  802117:	0f 88 2c 01 00 00    	js     802249 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80211d:	83 ec 04             	sub    $0x4,%esp
  802120:	68 07 04 00 00       	push   $0x407
  802125:	ff 75 f4             	pushl  -0xc(%ebp)
  802128:	6a 00                	push   $0x0
  80212a:	e8 ea ea ff ff       	call   800c19 <sys_page_alloc>
  80212f:	83 c4 10             	add    $0x10,%esp
  802132:	89 c2                	mov    %eax,%edx
  802134:	85 c0                	test   %eax,%eax
  802136:	0f 88 0d 01 00 00    	js     802249 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80213c:	83 ec 0c             	sub    $0xc,%esp
  80213f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802142:	50                   	push   %eax
  802143:	e8 1b f0 ff ff       	call   801163 <fd_alloc>
  802148:	89 c3                	mov    %eax,%ebx
  80214a:	83 c4 10             	add    $0x10,%esp
  80214d:	85 c0                	test   %eax,%eax
  80214f:	0f 88 e2 00 00 00    	js     802237 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802155:	83 ec 04             	sub    $0x4,%esp
  802158:	68 07 04 00 00       	push   $0x407
  80215d:	ff 75 f0             	pushl  -0x10(%ebp)
  802160:	6a 00                	push   $0x0
  802162:	e8 b2 ea ff ff       	call   800c19 <sys_page_alloc>
  802167:	89 c3                	mov    %eax,%ebx
  802169:	83 c4 10             	add    $0x10,%esp
  80216c:	85 c0                	test   %eax,%eax
  80216e:	0f 88 c3 00 00 00    	js     802237 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802174:	83 ec 0c             	sub    $0xc,%esp
  802177:	ff 75 f4             	pushl  -0xc(%ebp)
  80217a:	e8 cd ef ff ff       	call   80114c <fd2data>
  80217f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802181:	83 c4 0c             	add    $0xc,%esp
  802184:	68 07 04 00 00       	push   $0x407
  802189:	50                   	push   %eax
  80218a:	6a 00                	push   $0x0
  80218c:	e8 88 ea ff ff       	call   800c19 <sys_page_alloc>
  802191:	89 c3                	mov    %eax,%ebx
  802193:	83 c4 10             	add    $0x10,%esp
  802196:	85 c0                	test   %eax,%eax
  802198:	0f 88 89 00 00 00    	js     802227 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80219e:	83 ec 0c             	sub    $0xc,%esp
  8021a1:	ff 75 f0             	pushl  -0x10(%ebp)
  8021a4:	e8 a3 ef ff ff       	call   80114c <fd2data>
  8021a9:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021b0:	50                   	push   %eax
  8021b1:	6a 00                	push   $0x0
  8021b3:	56                   	push   %esi
  8021b4:	6a 00                	push   $0x0
  8021b6:	e8 a1 ea ff ff       	call   800c5c <sys_page_map>
  8021bb:	89 c3                	mov    %eax,%ebx
  8021bd:	83 c4 20             	add    $0x20,%esp
  8021c0:	85 c0                	test   %eax,%eax
  8021c2:	78 55                	js     802219 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8021c4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8021ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021cd:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8021cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021d2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8021d9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8021df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021e2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8021e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021e7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8021ee:	83 ec 0c             	sub    $0xc,%esp
  8021f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8021f4:	e8 43 ef ff ff       	call   80113c <fd2num>
  8021f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021fc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021fe:	83 c4 04             	add    $0x4,%esp
  802201:	ff 75 f0             	pushl  -0x10(%ebp)
  802204:	e8 33 ef ff ff       	call   80113c <fd2num>
  802209:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80220c:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80220f:	83 c4 10             	add    $0x10,%esp
  802212:	ba 00 00 00 00       	mov    $0x0,%edx
  802217:	eb 30                	jmp    802249 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802219:	83 ec 08             	sub    $0x8,%esp
  80221c:	56                   	push   %esi
  80221d:	6a 00                	push   $0x0
  80221f:	e8 7a ea ff ff       	call   800c9e <sys_page_unmap>
  802224:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802227:	83 ec 08             	sub    $0x8,%esp
  80222a:	ff 75 f0             	pushl  -0x10(%ebp)
  80222d:	6a 00                	push   $0x0
  80222f:	e8 6a ea ff ff       	call   800c9e <sys_page_unmap>
  802234:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802237:	83 ec 08             	sub    $0x8,%esp
  80223a:	ff 75 f4             	pushl  -0xc(%ebp)
  80223d:	6a 00                	push   $0x0
  80223f:	e8 5a ea ff ff       	call   800c9e <sys_page_unmap>
  802244:	83 c4 10             	add    $0x10,%esp
  802247:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802249:	89 d0                	mov    %edx,%eax
  80224b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80224e:	5b                   	pop    %ebx
  80224f:	5e                   	pop    %esi
  802250:	5d                   	pop    %ebp
  802251:	c3                   	ret    

00802252 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802252:	55                   	push   %ebp
  802253:	89 e5                	mov    %esp,%ebp
  802255:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802258:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80225b:	50                   	push   %eax
  80225c:	ff 75 08             	pushl  0x8(%ebp)
  80225f:	e8 4e ef ff ff       	call   8011b2 <fd_lookup>
  802264:	83 c4 10             	add    $0x10,%esp
  802267:	85 c0                	test   %eax,%eax
  802269:	78 18                	js     802283 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80226b:	83 ec 0c             	sub    $0xc,%esp
  80226e:	ff 75 f4             	pushl  -0xc(%ebp)
  802271:	e8 d6 ee ff ff       	call   80114c <fd2data>
	return _pipeisclosed(fd, p);
  802276:	89 c2                	mov    %eax,%edx
  802278:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80227b:	e8 21 fd ff ff       	call   801fa1 <_pipeisclosed>
  802280:	83 c4 10             	add    $0x10,%esp
}
  802283:	c9                   	leave  
  802284:	c3                   	ret    

00802285 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802285:	55                   	push   %ebp
  802286:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802288:	b8 00 00 00 00       	mov    $0x0,%eax
  80228d:	5d                   	pop    %ebp
  80228e:	c3                   	ret    

0080228f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80228f:	55                   	push   %ebp
  802290:	89 e5                	mov    %esp,%ebp
  802292:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802295:	68 bb 2e 80 00       	push   $0x802ebb
  80229a:	ff 75 0c             	pushl  0xc(%ebp)
  80229d:	e8 74 e5 ff ff       	call   800816 <strcpy>
	return 0;
}
  8022a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8022a7:	c9                   	leave  
  8022a8:	c3                   	ret    

008022a9 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022a9:	55                   	push   %ebp
  8022aa:	89 e5                	mov    %esp,%ebp
  8022ac:	57                   	push   %edi
  8022ad:	56                   	push   %esi
  8022ae:	53                   	push   %ebx
  8022af:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022b5:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022ba:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022c0:	eb 2d                	jmp    8022ef <devcons_write+0x46>
		m = n - tot;
  8022c2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022c5:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8022c7:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8022ca:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8022cf:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022d2:	83 ec 04             	sub    $0x4,%esp
  8022d5:	53                   	push   %ebx
  8022d6:	03 45 0c             	add    0xc(%ebp),%eax
  8022d9:	50                   	push   %eax
  8022da:	57                   	push   %edi
  8022db:	e8 c8 e6 ff ff       	call   8009a8 <memmove>
		sys_cputs(buf, m);
  8022e0:	83 c4 08             	add    $0x8,%esp
  8022e3:	53                   	push   %ebx
  8022e4:	57                   	push   %edi
  8022e5:	e8 73 e8 ff ff       	call   800b5d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022ea:	01 de                	add    %ebx,%esi
  8022ec:	83 c4 10             	add    $0x10,%esp
  8022ef:	89 f0                	mov    %esi,%eax
  8022f1:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022f4:	72 cc                	jb     8022c2 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8022f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022f9:	5b                   	pop    %ebx
  8022fa:	5e                   	pop    %esi
  8022fb:	5f                   	pop    %edi
  8022fc:	5d                   	pop    %ebp
  8022fd:	c3                   	ret    

008022fe <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022fe:	55                   	push   %ebp
  8022ff:	89 e5                	mov    %esp,%ebp
  802301:	83 ec 08             	sub    $0x8,%esp
  802304:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802309:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80230d:	74 2a                	je     802339 <devcons_read+0x3b>
  80230f:	eb 05                	jmp    802316 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802311:	e8 e4 e8 ff ff       	call   800bfa <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802316:	e8 60 e8 ff ff       	call   800b7b <sys_cgetc>
  80231b:	85 c0                	test   %eax,%eax
  80231d:	74 f2                	je     802311 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80231f:	85 c0                	test   %eax,%eax
  802321:	78 16                	js     802339 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802323:	83 f8 04             	cmp    $0x4,%eax
  802326:	74 0c                	je     802334 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802328:	8b 55 0c             	mov    0xc(%ebp),%edx
  80232b:	88 02                	mov    %al,(%edx)
	return 1;
  80232d:	b8 01 00 00 00       	mov    $0x1,%eax
  802332:	eb 05                	jmp    802339 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802334:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802339:	c9                   	leave  
  80233a:	c3                   	ret    

0080233b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80233b:	55                   	push   %ebp
  80233c:	89 e5                	mov    %esp,%ebp
  80233e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802341:	8b 45 08             	mov    0x8(%ebp),%eax
  802344:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802347:	6a 01                	push   $0x1
  802349:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80234c:	50                   	push   %eax
  80234d:	e8 0b e8 ff ff       	call   800b5d <sys_cputs>
}
  802352:	83 c4 10             	add    $0x10,%esp
  802355:	c9                   	leave  
  802356:	c3                   	ret    

00802357 <getchar>:

int
getchar(void)
{
  802357:	55                   	push   %ebp
  802358:	89 e5                	mov    %esp,%ebp
  80235a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80235d:	6a 01                	push   $0x1
  80235f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802362:	50                   	push   %eax
  802363:	6a 00                	push   $0x0
  802365:	e8 ae f0 ff ff       	call   801418 <read>
	if (r < 0)
  80236a:	83 c4 10             	add    $0x10,%esp
  80236d:	85 c0                	test   %eax,%eax
  80236f:	78 0f                	js     802380 <getchar+0x29>
		return r;
	if (r < 1)
  802371:	85 c0                	test   %eax,%eax
  802373:	7e 06                	jle    80237b <getchar+0x24>
		return -E_EOF;
	return c;
  802375:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802379:	eb 05                	jmp    802380 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80237b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802380:	c9                   	leave  
  802381:	c3                   	ret    

00802382 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802382:	55                   	push   %ebp
  802383:	89 e5                	mov    %esp,%ebp
  802385:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802388:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80238b:	50                   	push   %eax
  80238c:	ff 75 08             	pushl  0x8(%ebp)
  80238f:	e8 1e ee ff ff       	call   8011b2 <fd_lookup>
  802394:	83 c4 10             	add    $0x10,%esp
  802397:	85 c0                	test   %eax,%eax
  802399:	78 11                	js     8023ac <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80239b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80239e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8023a4:	39 10                	cmp    %edx,(%eax)
  8023a6:	0f 94 c0             	sete   %al
  8023a9:	0f b6 c0             	movzbl %al,%eax
}
  8023ac:	c9                   	leave  
  8023ad:	c3                   	ret    

008023ae <opencons>:

int
opencons(void)
{
  8023ae:	55                   	push   %ebp
  8023af:	89 e5                	mov    %esp,%ebp
  8023b1:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023b7:	50                   	push   %eax
  8023b8:	e8 a6 ed ff ff       	call   801163 <fd_alloc>
  8023bd:	83 c4 10             	add    $0x10,%esp
		return r;
  8023c0:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023c2:	85 c0                	test   %eax,%eax
  8023c4:	78 3e                	js     802404 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023c6:	83 ec 04             	sub    $0x4,%esp
  8023c9:	68 07 04 00 00       	push   $0x407
  8023ce:	ff 75 f4             	pushl  -0xc(%ebp)
  8023d1:	6a 00                	push   $0x0
  8023d3:	e8 41 e8 ff ff       	call   800c19 <sys_page_alloc>
  8023d8:	83 c4 10             	add    $0x10,%esp
		return r;
  8023db:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023dd:	85 c0                	test   %eax,%eax
  8023df:	78 23                	js     802404 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8023e1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8023e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ea:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ef:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8023f6:	83 ec 0c             	sub    $0xc,%esp
  8023f9:	50                   	push   %eax
  8023fa:	e8 3d ed ff ff       	call   80113c <fd2num>
  8023ff:	89 c2                	mov    %eax,%edx
  802401:	83 c4 10             	add    $0x10,%esp
}
  802404:	89 d0                	mov    %edx,%eax
  802406:	c9                   	leave  
  802407:	c3                   	ret    

00802408 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802408:	55                   	push   %ebp
  802409:	89 e5                	mov    %esp,%ebp
  80240b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80240e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802415:	75 2a                	jne    802441 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802417:	83 ec 04             	sub    $0x4,%esp
  80241a:	6a 07                	push   $0x7
  80241c:	68 00 f0 bf ee       	push   $0xeebff000
  802421:	6a 00                	push   $0x0
  802423:	e8 f1 e7 ff ff       	call   800c19 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802428:	83 c4 10             	add    $0x10,%esp
  80242b:	85 c0                	test   %eax,%eax
  80242d:	79 12                	jns    802441 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80242f:	50                   	push   %eax
  802430:	68 c7 2e 80 00       	push   $0x802ec7
  802435:	6a 23                	push   $0x23
  802437:	68 cb 2e 80 00       	push   $0x802ecb
  80243c:	e8 77 dd ff ff       	call   8001b8 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802441:	8b 45 08             	mov    0x8(%ebp),%eax
  802444:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802449:	83 ec 08             	sub    $0x8,%esp
  80244c:	68 73 24 80 00       	push   $0x802473
  802451:	6a 00                	push   $0x0
  802453:	e8 0c e9 ff ff       	call   800d64 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802458:	83 c4 10             	add    $0x10,%esp
  80245b:	85 c0                	test   %eax,%eax
  80245d:	79 12                	jns    802471 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  80245f:	50                   	push   %eax
  802460:	68 c7 2e 80 00       	push   $0x802ec7
  802465:	6a 2c                	push   $0x2c
  802467:	68 cb 2e 80 00       	push   $0x802ecb
  80246c:	e8 47 dd ff ff       	call   8001b8 <_panic>
	}
}
  802471:	c9                   	leave  
  802472:	c3                   	ret    

00802473 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802473:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802474:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802479:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80247b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  80247e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802482:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802487:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80248b:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  80248d:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802490:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802491:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802494:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802495:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802496:	c3                   	ret    

00802497 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802497:	55                   	push   %ebp
  802498:	89 e5                	mov    %esp,%ebp
  80249a:	56                   	push   %esi
  80249b:	53                   	push   %ebx
  80249c:	8b 75 08             	mov    0x8(%ebp),%esi
  80249f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8024a5:	85 c0                	test   %eax,%eax
  8024a7:	75 12                	jne    8024bb <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8024a9:	83 ec 0c             	sub    $0xc,%esp
  8024ac:	68 00 00 c0 ee       	push   $0xeec00000
  8024b1:	e8 13 e9 ff ff       	call   800dc9 <sys_ipc_recv>
  8024b6:	83 c4 10             	add    $0x10,%esp
  8024b9:	eb 0c                	jmp    8024c7 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8024bb:	83 ec 0c             	sub    $0xc,%esp
  8024be:	50                   	push   %eax
  8024bf:	e8 05 e9 ff ff       	call   800dc9 <sys_ipc_recv>
  8024c4:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8024c7:	85 f6                	test   %esi,%esi
  8024c9:	0f 95 c1             	setne  %cl
  8024cc:	85 db                	test   %ebx,%ebx
  8024ce:	0f 95 c2             	setne  %dl
  8024d1:	84 d1                	test   %dl,%cl
  8024d3:	74 09                	je     8024de <ipc_recv+0x47>
  8024d5:	89 c2                	mov    %eax,%edx
  8024d7:	c1 ea 1f             	shr    $0x1f,%edx
  8024da:	84 d2                	test   %dl,%dl
  8024dc:	75 2a                	jne    802508 <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8024de:	85 f6                	test   %esi,%esi
  8024e0:	74 0d                	je     8024ef <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8024e2:	a1 04 40 80 00       	mov    0x804004,%eax
  8024e7:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  8024ed:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8024ef:	85 db                	test   %ebx,%ebx
  8024f1:	74 0d                	je     802500 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8024f3:	a1 04 40 80 00       	mov    0x804004,%eax
  8024f8:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  8024fe:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802500:	a1 04 40 80 00       	mov    0x804004,%eax
  802505:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  802508:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80250b:	5b                   	pop    %ebx
  80250c:	5e                   	pop    %esi
  80250d:	5d                   	pop    %ebp
  80250e:	c3                   	ret    

0080250f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80250f:	55                   	push   %ebp
  802510:	89 e5                	mov    %esp,%ebp
  802512:	57                   	push   %edi
  802513:	56                   	push   %esi
  802514:	53                   	push   %ebx
  802515:	83 ec 0c             	sub    $0xc,%esp
  802518:	8b 7d 08             	mov    0x8(%ebp),%edi
  80251b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80251e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802521:	85 db                	test   %ebx,%ebx
  802523:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802528:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80252b:	ff 75 14             	pushl  0x14(%ebp)
  80252e:	53                   	push   %ebx
  80252f:	56                   	push   %esi
  802530:	57                   	push   %edi
  802531:	e8 70 e8 ff ff       	call   800da6 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802536:	89 c2                	mov    %eax,%edx
  802538:	c1 ea 1f             	shr    $0x1f,%edx
  80253b:	83 c4 10             	add    $0x10,%esp
  80253e:	84 d2                	test   %dl,%dl
  802540:	74 17                	je     802559 <ipc_send+0x4a>
  802542:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802545:	74 12                	je     802559 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802547:	50                   	push   %eax
  802548:	68 d9 2e 80 00       	push   $0x802ed9
  80254d:	6a 47                	push   $0x47
  80254f:	68 e7 2e 80 00       	push   $0x802ee7
  802554:	e8 5f dc ff ff       	call   8001b8 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802559:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80255c:	75 07                	jne    802565 <ipc_send+0x56>
			sys_yield();
  80255e:	e8 97 e6 ff ff       	call   800bfa <sys_yield>
  802563:	eb c6                	jmp    80252b <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802565:	85 c0                	test   %eax,%eax
  802567:	75 c2                	jne    80252b <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802569:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80256c:	5b                   	pop    %ebx
  80256d:	5e                   	pop    %esi
  80256e:	5f                   	pop    %edi
  80256f:	5d                   	pop    %ebp
  802570:	c3                   	ret    

00802571 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802571:	55                   	push   %ebp
  802572:	89 e5                	mov    %esp,%ebp
  802574:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802577:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80257c:	89 c2                	mov    %eax,%edx
  80257e:	c1 e2 07             	shl    $0x7,%edx
  802581:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  802588:	8b 52 5c             	mov    0x5c(%edx),%edx
  80258b:	39 ca                	cmp    %ecx,%edx
  80258d:	75 11                	jne    8025a0 <ipc_find_env+0x2f>
			return envs[i].env_id;
  80258f:	89 c2                	mov    %eax,%edx
  802591:	c1 e2 07             	shl    $0x7,%edx
  802594:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  80259b:	8b 40 54             	mov    0x54(%eax),%eax
  80259e:	eb 0f                	jmp    8025af <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8025a0:	83 c0 01             	add    $0x1,%eax
  8025a3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8025a8:	75 d2                	jne    80257c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8025aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8025af:	5d                   	pop    %ebp
  8025b0:	c3                   	ret    

008025b1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025b1:	55                   	push   %ebp
  8025b2:	89 e5                	mov    %esp,%ebp
  8025b4:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025b7:	89 d0                	mov    %edx,%eax
  8025b9:	c1 e8 16             	shr    $0x16,%eax
  8025bc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8025c3:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025c8:	f6 c1 01             	test   $0x1,%cl
  8025cb:	74 1d                	je     8025ea <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8025cd:	c1 ea 0c             	shr    $0xc,%edx
  8025d0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8025d7:	f6 c2 01             	test   $0x1,%dl
  8025da:	74 0e                	je     8025ea <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025dc:	c1 ea 0c             	shr    $0xc,%edx
  8025df:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8025e6:	ef 
  8025e7:	0f b7 c0             	movzwl %ax,%eax
}
  8025ea:	5d                   	pop    %ebp
  8025eb:	c3                   	ret    
  8025ec:	66 90                	xchg   %ax,%ax
  8025ee:	66 90                	xchg   %ax,%ax

008025f0 <__udivdi3>:
  8025f0:	55                   	push   %ebp
  8025f1:	57                   	push   %edi
  8025f2:	56                   	push   %esi
  8025f3:	53                   	push   %ebx
  8025f4:	83 ec 1c             	sub    $0x1c,%esp
  8025f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8025fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8025ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802603:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802607:	85 f6                	test   %esi,%esi
  802609:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80260d:	89 ca                	mov    %ecx,%edx
  80260f:	89 f8                	mov    %edi,%eax
  802611:	75 3d                	jne    802650 <__udivdi3+0x60>
  802613:	39 cf                	cmp    %ecx,%edi
  802615:	0f 87 c5 00 00 00    	ja     8026e0 <__udivdi3+0xf0>
  80261b:	85 ff                	test   %edi,%edi
  80261d:	89 fd                	mov    %edi,%ebp
  80261f:	75 0b                	jne    80262c <__udivdi3+0x3c>
  802621:	b8 01 00 00 00       	mov    $0x1,%eax
  802626:	31 d2                	xor    %edx,%edx
  802628:	f7 f7                	div    %edi
  80262a:	89 c5                	mov    %eax,%ebp
  80262c:	89 c8                	mov    %ecx,%eax
  80262e:	31 d2                	xor    %edx,%edx
  802630:	f7 f5                	div    %ebp
  802632:	89 c1                	mov    %eax,%ecx
  802634:	89 d8                	mov    %ebx,%eax
  802636:	89 cf                	mov    %ecx,%edi
  802638:	f7 f5                	div    %ebp
  80263a:	89 c3                	mov    %eax,%ebx
  80263c:	89 d8                	mov    %ebx,%eax
  80263e:	89 fa                	mov    %edi,%edx
  802640:	83 c4 1c             	add    $0x1c,%esp
  802643:	5b                   	pop    %ebx
  802644:	5e                   	pop    %esi
  802645:	5f                   	pop    %edi
  802646:	5d                   	pop    %ebp
  802647:	c3                   	ret    
  802648:	90                   	nop
  802649:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802650:	39 ce                	cmp    %ecx,%esi
  802652:	77 74                	ja     8026c8 <__udivdi3+0xd8>
  802654:	0f bd fe             	bsr    %esi,%edi
  802657:	83 f7 1f             	xor    $0x1f,%edi
  80265a:	0f 84 98 00 00 00    	je     8026f8 <__udivdi3+0x108>
  802660:	bb 20 00 00 00       	mov    $0x20,%ebx
  802665:	89 f9                	mov    %edi,%ecx
  802667:	89 c5                	mov    %eax,%ebp
  802669:	29 fb                	sub    %edi,%ebx
  80266b:	d3 e6                	shl    %cl,%esi
  80266d:	89 d9                	mov    %ebx,%ecx
  80266f:	d3 ed                	shr    %cl,%ebp
  802671:	89 f9                	mov    %edi,%ecx
  802673:	d3 e0                	shl    %cl,%eax
  802675:	09 ee                	or     %ebp,%esi
  802677:	89 d9                	mov    %ebx,%ecx
  802679:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80267d:	89 d5                	mov    %edx,%ebp
  80267f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802683:	d3 ed                	shr    %cl,%ebp
  802685:	89 f9                	mov    %edi,%ecx
  802687:	d3 e2                	shl    %cl,%edx
  802689:	89 d9                	mov    %ebx,%ecx
  80268b:	d3 e8                	shr    %cl,%eax
  80268d:	09 c2                	or     %eax,%edx
  80268f:	89 d0                	mov    %edx,%eax
  802691:	89 ea                	mov    %ebp,%edx
  802693:	f7 f6                	div    %esi
  802695:	89 d5                	mov    %edx,%ebp
  802697:	89 c3                	mov    %eax,%ebx
  802699:	f7 64 24 0c          	mull   0xc(%esp)
  80269d:	39 d5                	cmp    %edx,%ebp
  80269f:	72 10                	jb     8026b1 <__udivdi3+0xc1>
  8026a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8026a5:	89 f9                	mov    %edi,%ecx
  8026a7:	d3 e6                	shl    %cl,%esi
  8026a9:	39 c6                	cmp    %eax,%esi
  8026ab:	73 07                	jae    8026b4 <__udivdi3+0xc4>
  8026ad:	39 d5                	cmp    %edx,%ebp
  8026af:	75 03                	jne    8026b4 <__udivdi3+0xc4>
  8026b1:	83 eb 01             	sub    $0x1,%ebx
  8026b4:	31 ff                	xor    %edi,%edi
  8026b6:	89 d8                	mov    %ebx,%eax
  8026b8:	89 fa                	mov    %edi,%edx
  8026ba:	83 c4 1c             	add    $0x1c,%esp
  8026bd:	5b                   	pop    %ebx
  8026be:	5e                   	pop    %esi
  8026bf:	5f                   	pop    %edi
  8026c0:	5d                   	pop    %ebp
  8026c1:	c3                   	ret    
  8026c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026c8:	31 ff                	xor    %edi,%edi
  8026ca:	31 db                	xor    %ebx,%ebx
  8026cc:	89 d8                	mov    %ebx,%eax
  8026ce:	89 fa                	mov    %edi,%edx
  8026d0:	83 c4 1c             	add    $0x1c,%esp
  8026d3:	5b                   	pop    %ebx
  8026d4:	5e                   	pop    %esi
  8026d5:	5f                   	pop    %edi
  8026d6:	5d                   	pop    %ebp
  8026d7:	c3                   	ret    
  8026d8:	90                   	nop
  8026d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026e0:	89 d8                	mov    %ebx,%eax
  8026e2:	f7 f7                	div    %edi
  8026e4:	31 ff                	xor    %edi,%edi
  8026e6:	89 c3                	mov    %eax,%ebx
  8026e8:	89 d8                	mov    %ebx,%eax
  8026ea:	89 fa                	mov    %edi,%edx
  8026ec:	83 c4 1c             	add    $0x1c,%esp
  8026ef:	5b                   	pop    %ebx
  8026f0:	5e                   	pop    %esi
  8026f1:	5f                   	pop    %edi
  8026f2:	5d                   	pop    %ebp
  8026f3:	c3                   	ret    
  8026f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026f8:	39 ce                	cmp    %ecx,%esi
  8026fa:	72 0c                	jb     802708 <__udivdi3+0x118>
  8026fc:	31 db                	xor    %ebx,%ebx
  8026fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802702:	0f 87 34 ff ff ff    	ja     80263c <__udivdi3+0x4c>
  802708:	bb 01 00 00 00       	mov    $0x1,%ebx
  80270d:	e9 2a ff ff ff       	jmp    80263c <__udivdi3+0x4c>
  802712:	66 90                	xchg   %ax,%ax
  802714:	66 90                	xchg   %ax,%ax
  802716:	66 90                	xchg   %ax,%ax
  802718:	66 90                	xchg   %ax,%ax
  80271a:	66 90                	xchg   %ax,%ax
  80271c:	66 90                	xchg   %ax,%ax
  80271e:	66 90                	xchg   %ax,%ax

00802720 <__umoddi3>:
  802720:	55                   	push   %ebp
  802721:	57                   	push   %edi
  802722:	56                   	push   %esi
  802723:	53                   	push   %ebx
  802724:	83 ec 1c             	sub    $0x1c,%esp
  802727:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80272b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80272f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802733:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802737:	85 d2                	test   %edx,%edx
  802739:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80273d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802741:	89 f3                	mov    %esi,%ebx
  802743:	89 3c 24             	mov    %edi,(%esp)
  802746:	89 74 24 04          	mov    %esi,0x4(%esp)
  80274a:	75 1c                	jne    802768 <__umoddi3+0x48>
  80274c:	39 f7                	cmp    %esi,%edi
  80274e:	76 50                	jbe    8027a0 <__umoddi3+0x80>
  802750:	89 c8                	mov    %ecx,%eax
  802752:	89 f2                	mov    %esi,%edx
  802754:	f7 f7                	div    %edi
  802756:	89 d0                	mov    %edx,%eax
  802758:	31 d2                	xor    %edx,%edx
  80275a:	83 c4 1c             	add    $0x1c,%esp
  80275d:	5b                   	pop    %ebx
  80275e:	5e                   	pop    %esi
  80275f:	5f                   	pop    %edi
  802760:	5d                   	pop    %ebp
  802761:	c3                   	ret    
  802762:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802768:	39 f2                	cmp    %esi,%edx
  80276a:	89 d0                	mov    %edx,%eax
  80276c:	77 52                	ja     8027c0 <__umoddi3+0xa0>
  80276e:	0f bd ea             	bsr    %edx,%ebp
  802771:	83 f5 1f             	xor    $0x1f,%ebp
  802774:	75 5a                	jne    8027d0 <__umoddi3+0xb0>
  802776:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80277a:	0f 82 e0 00 00 00    	jb     802860 <__umoddi3+0x140>
  802780:	39 0c 24             	cmp    %ecx,(%esp)
  802783:	0f 86 d7 00 00 00    	jbe    802860 <__umoddi3+0x140>
  802789:	8b 44 24 08          	mov    0x8(%esp),%eax
  80278d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802791:	83 c4 1c             	add    $0x1c,%esp
  802794:	5b                   	pop    %ebx
  802795:	5e                   	pop    %esi
  802796:	5f                   	pop    %edi
  802797:	5d                   	pop    %ebp
  802798:	c3                   	ret    
  802799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027a0:	85 ff                	test   %edi,%edi
  8027a2:	89 fd                	mov    %edi,%ebp
  8027a4:	75 0b                	jne    8027b1 <__umoddi3+0x91>
  8027a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8027ab:	31 d2                	xor    %edx,%edx
  8027ad:	f7 f7                	div    %edi
  8027af:	89 c5                	mov    %eax,%ebp
  8027b1:	89 f0                	mov    %esi,%eax
  8027b3:	31 d2                	xor    %edx,%edx
  8027b5:	f7 f5                	div    %ebp
  8027b7:	89 c8                	mov    %ecx,%eax
  8027b9:	f7 f5                	div    %ebp
  8027bb:	89 d0                	mov    %edx,%eax
  8027bd:	eb 99                	jmp    802758 <__umoddi3+0x38>
  8027bf:	90                   	nop
  8027c0:	89 c8                	mov    %ecx,%eax
  8027c2:	89 f2                	mov    %esi,%edx
  8027c4:	83 c4 1c             	add    $0x1c,%esp
  8027c7:	5b                   	pop    %ebx
  8027c8:	5e                   	pop    %esi
  8027c9:	5f                   	pop    %edi
  8027ca:	5d                   	pop    %ebp
  8027cb:	c3                   	ret    
  8027cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027d0:	8b 34 24             	mov    (%esp),%esi
  8027d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8027d8:	89 e9                	mov    %ebp,%ecx
  8027da:	29 ef                	sub    %ebp,%edi
  8027dc:	d3 e0                	shl    %cl,%eax
  8027de:	89 f9                	mov    %edi,%ecx
  8027e0:	89 f2                	mov    %esi,%edx
  8027e2:	d3 ea                	shr    %cl,%edx
  8027e4:	89 e9                	mov    %ebp,%ecx
  8027e6:	09 c2                	or     %eax,%edx
  8027e8:	89 d8                	mov    %ebx,%eax
  8027ea:	89 14 24             	mov    %edx,(%esp)
  8027ed:	89 f2                	mov    %esi,%edx
  8027ef:	d3 e2                	shl    %cl,%edx
  8027f1:	89 f9                	mov    %edi,%ecx
  8027f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8027f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8027fb:	d3 e8                	shr    %cl,%eax
  8027fd:	89 e9                	mov    %ebp,%ecx
  8027ff:	89 c6                	mov    %eax,%esi
  802801:	d3 e3                	shl    %cl,%ebx
  802803:	89 f9                	mov    %edi,%ecx
  802805:	89 d0                	mov    %edx,%eax
  802807:	d3 e8                	shr    %cl,%eax
  802809:	89 e9                	mov    %ebp,%ecx
  80280b:	09 d8                	or     %ebx,%eax
  80280d:	89 d3                	mov    %edx,%ebx
  80280f:	89 f2                	mov    %esi,%edx
  802811:	f7 34 24             	divl   (%esp)
  802814:	89 d6                	mov    %edx,%esi
  802816:	d3 e3                	shl    %cl,%ebx
  802818:	f7 64 24 04          	mull   0x4(%esp)
  80281c:	39 d6                	cmp    %edx,%esi
  80281e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802822:	89 d1                	mov    %edx,%ecx
  802824:	89 c3                	mov    %eax,%ebx
  802826:	72 08                	jb     802830 <__umoddi3+0x110>
  802828:	75 11                	jne    80283b <__umoddi3+0x11b>
  80282a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80282e:	73 0b                	jae    80283b <__umoddi3+0x11b>
  802830:	2b 44 24 04          	sub    0x4(%esp),%eax
  802834:	1b 14 24             	sbb    (%esp),%edx
  802837:	89 d1                	mov    %edx,%ecx
  802839:	89 c3                	mov    %eax,%ebx
  80283b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80283f:	29 da                	sub    %ebx,%edx
  802841:	19 ce                	sbb    %ecx,%esi
  802843:	89 f9                	mov    %edi,%ecx
  802845:	89 f0                	mov    %esi,%eax
  802847:	d3 e0                	shl    %cl,%eax
  802849:	89 e9                	mov    %ebp,%ecx
  80284b:	d3 ea                	shr    %cl,%edx
  80284d:	89 e9                	mov    %ebp,%ecx
  80284f:	d3 ee                	shr    %cl,%esi
  802851:	09 d0                	or     %edx,%eax
  802853:	89 f2                	mov    %esi,%edx
  802855:	83 c4 1c             	add    $0x1c,%esp
  802858:	5b                   	pop    %ebx
  802859:	5e                   	pop    %esi
  80285a:	5f                   	pop    %edi
  80285b:	5d                   	pop    %ebp
  80285c:	c3                   	ret    
  80285d:	8d 76 00             	lea    0x0(%esi),%esi
  802860:	29 f9                	sub    %edi,%ecx
  802862:	19 d6                	sbb    %edx,%esi
  802864:	89 74 24 04          	mov    %esi,0x4(%esp)
  802868:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80286c:	e9 18 ff ff ff       	jmp    802789 <__umoddi3+0x69>
