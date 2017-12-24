
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
  80003e:	c7 05 00 30 80 00 e0 	movl   $0x8024e0,0x803000
  800045:	24 80 00 

	cprintf("icode startup\n");
  800048:	68 e6 24 80 00       	push   $0x8024e6
  80004d:	e8 63 02 00 00       	call   8002b5 <cprintf>

	cprintf("icode: open /motd\n");
  800052:	c7 04 24 f5 24 80 00 	movl   $0x8024f5,(%esp)
  800059:	e8 57 02 00 00       	call   8002b5 <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005e:	83 c4 08             	add    $0x8,%esp
  800061:	6a 00                	push   $0x0
  800063:	68 08 25 80 00       	push   $0x802508
  800068:	e8 28 15 00 00       	call   801595 <open>
  80006d:	89 c6                	mov    %eax,%esi
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	85 c0                	test   %eax,%eax
  800074:	79 12                	jns    800088 <umain+0x55>
		panic("icode: open /motd: %e", fd);
  800076:	50                   	push   %eax
  800077:	68 0e 25 80 00       	push   $0x80250e
  80007c:	6a 0f                	push   $0xf
  80007e:	68 24 25 80 00       	push   $0x802524
  800083:	e8 54 01 00 00       	call   8001dc <_panic>

	cprintf("icode: read /motd\n");
  800088:	83 ec 0c             	sub    $0xc,%esp
  80008b:	68 31 25 80 00       	push   $0x802531
  800090:	e8 20 02 00 00       	call   8002b5 <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  80009e:	eb 0d                	jmp    8000ad <umain+0x7a>
		sys_cputs(buf, n);
  8000a0:	83 ec 08             	sub    $0x8,%esp
  8000a3:	50                   	push   %eax
  8000a4:	53                   	push   %ebx
  8000a5:	e8 d7 0a 00 00       	call   800b81 <sys_cputs>
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
  8000b7:	e8 4e 10 00 00       	call   80110a <read>
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	7f dd                	jg     8000a0 <umain+0x6d>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	68 44 25 80 00       	push   $0x802544
  8000cb:	e8 e5 01 00 00       	call   8002b5 <cprintf>
	close(fd);
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 f6 0e 00 00       	call   800fce <close>

	cprintf("icode: spawn /init\n");
  8000d8:	c7 04 24 58 25 80 00 	movl   $0x802558,(%esp)
  8000df:	e8 d1 01 00 00       	call   8002b5 <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000eb:	68 6c 25 80 00       	push   $0x80256c
  8000f0:	68 75 25 80 00       	push   $0x802575
  8000f5:	68 7f 25 80 00       	push   $0x80257f
  8000fa:	68 7e 25 80 00       	push   $0x80257e
  8000ff:	e8 a4 1a 00 00       	call   801ba8 <spawnl>
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	85 c0                	test   %eax,%eax
  800109:	79 12                	jns    80011d <umain+0xea>
		panic("icode: spawn /init: %e", r);
  80010b:	50                   	push   %eax
  80010c:	68 84 25 80 00       	push   $0x802584
  800111:	6a 1a                	push   $0x1a
  800113:	68 24 25 80 00       	push   $0x802524
  800118:	e8 bf 00 00 00       	call   8001dc <_panic>

	cprintf("icode: exiting\n");
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	68 9b 25 80 00       	push   $0x80259b
  800125:	e8 8b 01 00 00       	call   8002b5 <cprintf>
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
  800137:	57                   	push   %edi
  800138:	56                   	push   %esi
  800139:	53                   	push   %ebx
  80013a:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80013d:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800144:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  800147:	e8 b3 0a 00 00       	call   800bff <sys_getenvid>
  80014c:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  800152:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  800157:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  80015c:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  800161:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  800164:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  80016a:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  80016d:	39 c8                	cmp    %ecx,%eax
  80016f:	0f 44 fb             	cmove  %ebx,%edi
  800172:	b9 01 00 00 00       	mov    $0x1,%ecx
  800177:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  80017a:	83 c2 01             	add    $0x1,%edx
  80017d:	83 c3 7c             	add    $0x7c,%ebx
  800180:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  800186:	75 d9                	jne    800161 <libmain+0x2d>
  800188:	89 f0                	mov    %esi,%eax
  80018a:	84 c0                	test   %al,%al
  80018c:	74 06                	je     800194 <libmain+0x60>
  80018e:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800194:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800198:	7e 0a                	jle    8001a4 <libmain+0x70>
		binaryname = argv[0];
  80019a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80019d:	8b 00                	mov    (%eax),%eax
  80019f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001a4:	83 ec 08             	sub    $0x8,%esp
  8001a7:	ff 75 0c             	pushl  0xc(%ebp)
  8001aa:	ff 75 08             	pushl  0x8(%ebp)
  8001ad:	e8 81 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001b2:	e8 0b 00 00 00       	call   8001c2 <exit>
}
  8001b7:	83 c4 10             	add    $0x10,%esp
  8001ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bd:	5b                   	pop    %ebx
  8001be:	5e                   	pop    %esi
  8001bf:	5f                   	pop    %edi
  8001c0:	5d                   	pop    %ebp
  8001c1:	c3                   	ret    

008001c2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001c2:	55                   	push   %ebp
  8001c3:	89 e5                	mov    %esp,%ebp
  8001c5:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001c8:	e8 2c 0e 00 00       	call   800ff9 <close_all>
	sys_env_destroy(0);
  8001cd:	83 ec 0c             	sub    $0xc,%esp
  8001d0:	6a 00                	push   $0x0
  8001d2:	e8 e7 09 00 00       	call   800bbe <sys_env_destroy>
}
  8001d7:	83 c4 10             	add    $0x10,%esp
  8001da:	c9                   	leave  
  8001db:	c3                   	ret    

008001dc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001e1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001e4:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001ea:	e8 10 0a 00 00       	call   800bff <sys_getenvid>
  8001ef:	83 ec 0c             	sub    $0xc,%esp
  8001f2:	ff 75 0c             	pushl  0xc(%ebp)
  8001f5:	ff 75 08             	pushl  0x8(%ebp)
  8001f8:	56                   	push   %esi
  8001f9:	50                   	push   %eax
  8001fa:	68 b8 25 80 00       	push   $0x8025b8
  8001ff:	e8 b1 00 00 00       	call   8002b5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800204:	83 c4 18             	add    $0x18,%esp
  800207:	53                   	push   %ebx
  800208:	ff 75 10             	pushl  0x10(%ebp)
  80020b:	e8 54 00 00 00       	call   800264 <vcprintf>
	cprintf("\n");
  800210:	c7 04 24 98 2a 80 00 	movl   $0x802a98,(%esp)
  800217:	e8 99 00 00 00       	call   8002b5 <cprintf>
  80021c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80021f:	cc                   	int3   
  800220:	eb fd                	jmp    80021f <_panic+0x43>

00800222 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800222:	55                   	push   %ebp
  800223:	89 e5                	mov    %esp,%ebp
  800225:	53                   	push   %ebx
  800226:	83 ec 04             	sub    $0x4,%esp
  800229:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80022c:	8b 13                	mov    (%ebx),%edx
  80022e:	8d 42 01             	lea    0x1(%edx),%eax
  800231:	89 03                	mov    %eax,(%ebx)
  800233:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800236:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80023a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80023f:	75 1a                	jne    80025b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800241:	83 ec 08             	sub    $0x8,%esp
  800244:	68 ff 00 00 00       	push   $0xff
  800249:	8d 43 08             	lea    0x8(%ebx),%eax
  80024c:	50                   	push   %eax
  80024d:	e8 2f 09 00 00       	call   800b81 <sys_cputs>
		b->idx = 0;
  800252:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800258:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80025b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80025f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800262:	c9                   	leave  
  800263:	c3                   	ret    

00800264 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80026d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800274:	00 00 00 
	b.cnt = 0;
  800277:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80027e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800281:	ff 75 0c             	pushl  0xc(%ebp)
  800284:	ff 75 08             	pushl  0x8(%ebp)
  800287:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80028d:	50                   	push   %eax
  80028e:	68 22 02 80 00       	push   $0x800222
  800293:	e8 54 01 00 00       	call   8003ec <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800298:	83 c4 08             	add    $0x8,%esp
  80029b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002a1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002a7:	50                   	push   %eax
  8002a8:	e8 d4 08 00 00       	call   800b81 <sys_cputs>

	return b.cnt;
}
  8002ad:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002b3:	c9                   	leave  
  8002b4:	c3                   	ret    

008002b5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002bb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002be:	50                   	push   %eax
  8002bf:	ff 75 08             	pushl  0x8(%ebp)
  8002c2:	e8 9d ff ff ff       	call   800264 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c7:	c9                   	leave  
  8002c8:	c3                   	ret    

008002c9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	57                   	push   %edi
  8002cd:	56                   	push   %esi
  8002ce:	53                   	push   %ebx
  8002cf:	83 ec 1c             	sub    $0x1c,%esp
  8002d2:	89 c7                	mov    %eax,%edi
  8002d4:	89 d6                	mov    %edx,%esi
  8002d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002df:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ea:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002ed:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002f0:	39 d3                	cmp    %edx,%ebx
  8002f2:	72 05                	jb     8002f9 <printnum+0x30>
  8002f4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002f7:	77 45                	ja     80033e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f9:	83 ec 0c             	sub    $0xc,%esp
  8002fc:	ff 75 18             	pushl  0x18(%ebp)
  8002ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800302:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800305:	53                   	push   %ebx
  800306:	ff 75 10             	pushl  0x10(%ebp)
  800309:	83 ec 08             	sub    $0x8,%esp
  80030c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80030f:	ff 75 e0             	pushl  -0x20(%ebp)
  800312:	ff 75 dc             	pushl  -0x24(%ebp)
  800315:	ff 75 d8             	pushl  -0x28(%ebp)
  800318:	e8 33 1f 00 00       	call   802250 <__udivdi3>
  80031d:	83 c4 18             	add    $0x18,%esp
  800320:	52                   	push   %edx
  800321:	50                   	push   %eax
  800322:	89 f2                	mov    %esi,%edx
  800324:	89 f8                	mov    %edi,%eax
  800326:	e8 9e ff ff ff       	call   8002c9 <printnum>
  80032b:	83 c4 20             	add    $0x20,%esp
  80032e:	eb 18                	jmp    800348 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800330:	83 ec 08             	sub    $0x8,%esp
  800333:	56                   	push   %esi
  800334:	ff 75 18             	pushl  0x18(%ebp)
  800337:	ff d7                	call   *%edi
  800339:	83 c4 10             	add    $0x10,%esp
  80033c:	eb 03                	jmp    800341 <printnum+0x78>
  80033e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800341:	83 eb 01             	sub    $0x1,%ebx
  800344:	85 db                	test   %ebx,%ebx
  800346:	7f e8                	jg     800330 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800348:	83 ec 08             	sub    $0x8,%esp
  80034b:	56                   	push   %esi
  80034c:	83 ec 04             	sub    $0x4,%esp
  80034f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800352:	ff 75 e0             	pushl  -0x20(%ebp)
  800355:	ff 75 dc             	pushl  -0x24(%ebp)
  800358:	ff 75 d8             	pushl  -0x28(%ebp)
  80035b:	e8 20 20 00 00       	call   802380 <__umoddi3>
  800360:	83 c4 14             	add    $0x14,%esp
  800363:	0f be 80 db 25 80 00 	movsbl 0x8025db(%eax),%eax
  80036a:	50                   	push   %eax
  80036b:	ff d7                	call   *%edi
}
  80036d:	83 c4 10             	add    $0x10,%esp
  800370:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800373:	5b                   	pop    %ebx
  800374:	5e                   	pop    %esi
  800375:	5f                   	pop    %edi
  800376:	5d                   	pop    %ebp
  800377:	c3                   	ret    

00800378 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80037b:	83 fa 01             	cmp    $0x1,%edx
  80037e:	7e 0e                	jle    80038e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800380:	8b 10                	mov    (%eax),%edx
  800382:	8d 4a 08             	lea    0x8(%edx),%ecx
  800385:	89 08                	mov    %ecx,(%eax)
  800387:	8b 02                	mov    (%edx),%eax
  800389:	8b 52 04             	mov    0x4(%edx),%edx
  80038c:	eb 22                	jmp    8003b0 <getuint+0x38>
	else if (lflag)
  80038e:	85 d2                	test   %edx,%edx
  800390:	74 10                	je     8003a2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800392:	8b 10                	mov    (%eax),%edx
  800394:	8d 4a 04             	lea    0x4(%edx),%ecx
  800397:	89 08                	mov    %ecx,(%eax)
  800399:	8b 02                	mov    (%edx),%eax
  80039b:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a0:	eb 0e                	jmp    8003b0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003a2:	8b 10                	mov    (%eax),%edx
  8003a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a7:	89 08                	mov    %ecx,(%eax)
  8003a9:	8b 02                	mov    (%edx),%eax
  8003ab:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003b0:	5d                   	pop    %ebp
  8003b1:	c3                   	ret    

008003b2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003b2:	55                   	push   %ebp
  8003b3:	89 e5                	mov    %esp,%ebp
  8003b5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003bc:	8b 10                	mov    (%eax),%edx
  8003be:	3b 50 04             	cmp    0x4(%eax),%edx
  8003c1:	73 0a                	jae    8003cd <sprintputch+0x1b>
		*b->buf++ = ch;
  8003c3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003c6:	89 08                	mov    %ecx,(%eax)
  8003c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cb:	88 02                	mov    %al,(%edx)
}
  8003cd:	5d                   	pop    %ebp
  8003ce:	c3                   	ret    

008003cf <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
  8003d2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003d8:	50                   	push   %eax
  8003d9:	ff 75 10             	pushl  0x10(%ebp)
  8003dc:	ff 75 0c             	pushl  0xc(%ebp)
  8003df:	ff 75 08             	pushl  0x8(%ebp)
  8003e2:	e8 05 00 00 00       	call   8003ec <vprintfmt>
	va_end(ap);
}
  8003e7:	83 c4 10             	add    $0x10,%esp
  8003ea:	c9                   	leave  
  8003eb:	c3                   	ret    

008003ec <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
  8003ef:	57                   	push   %edi
  8003f0:	56                   	push   %esi
  8003f1:	53                   	push   %ebx
  8003f2:	83 ec 2c             	sub    $0x2c,%esp
  8003f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8003f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003fb:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003fe:	eb 12                	jmp    800412 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800400:	85 c0                	test   %eax,%eax
  800402:	0f 84 89 03 00 00    	je     800791 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800408:	83 ec 08             	sub    $0x8,%esp
  80040b:	53                   	push   %ebx
  80040c:	50                   	push   %eax
  80040d:	ff d6                	call   *%esi
  80040f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800412:	83 c7 01             	add    $0x1,%edi
  800415:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800419:	83 f8 25             	cmp    $0x25,%eax
  80041c:	75 e2                	jne    800400 <vprintfmt+0x14>
  80041e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800422:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800429:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800430:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800437:	ba 00 00 00 00       	mov    $0x0,%edx
  80043c:	eb 07                	jmp    800445 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800441:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800445:	8d 47 01             	lea    0x1(%edi),%eax
  800448:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80044b:	0f b6 07             	movzbl (%edi),%eax
  80044e:	0f b6 c8             	movzbl %al,%ecx
  800451:	83 e8 23             	sub    $0x23,%eax
  800454:	3c 55                	cmp    $0x55,%al
  800456:	0f 87 1a 03 00 00    	ja     800776 <vprintfmt+0x38a>
  80045c:	0f b6 c0             	movzbl %al,%eax
  80045f:	ff 24 85 20 27 80 00 	jmp    *0x802720(,%eax,4)
  800466:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800469:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80046d:	eb d6                	jmp    800445 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800472:	b8 00 00 00 00       	mov    $0x0,%eax
  800477:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80047a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80047d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800481:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800484:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800487:	83 fa 09             	cmp    $0x9,%edx
  80048a:	77 39                	ja     8004c5 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80048c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80048f:	eb e9                	jmp    80047a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800491:	8b 45 14             	mov    0x14(%ebp),%eax
  800494:	8d 48 04             	lea    0x4(%eax),%ecx
  800497:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80049a:	8b 00                	mov    (%eax),%eax
  80049c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004a2:	eb 27                	jmp    8004cb <vprintfmt+0xdf>
  8004a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a7:	85 c0                	test   %eax,%eax
  8004a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004ae:	0f 49 c8             	cmovns %eax,%ecx
  8004b1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b7:	eb 8c                	jmp    800445 <vprintfmt+0x59>
  8004b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004bc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004c3:	eb 80                	jmp    800445 <vprintfmt+0x59>
  8004c5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004c8:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004cb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004cf:	0f 89 70 ff ff ff    	jns    800445 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004d5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004db:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004e2:	e9 5e ff ff ff       	jmp    800445 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004e7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004ed:	e9 53 ff ff ff       	jmp    800445 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f5:	8d 50 04             	lea    0x4(%eax),%edx
  8004f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	53                   	push   %ebx
  8004ff:	ff 30                	pushl  (%eax)
  800501:	ff d6                	call   *%esi
			break;
  800503:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800506:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800509:	e9 04 ff ff ff       	jmp    800412 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80050e:	8b 45 14             	mov    0x14(%ebp),%eax
  800511:	8d 50 04             	lea    0x4(%eax),%edx
  800514:	89 55 14             	mov    %edx,0x14(%ebp)
  800517:	8b 00                	mov    (%eax),%eax
  800519:	99                   	cltd   
  80051a:	31 d0                	xor    %edx,%eax
  80051c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80051e:	83 f8 0f             	cmp    $0xf,%eax
  800521:	7f 0b                	jg     80052e <vprintfmt+0x142>
  800523:	8b 14 85 80 28 80 00 	mov    0x802880(,%eax,4),%edx
  80052a:	85 d2                	test   %edx,%edx
  80052c:	75 18                	jne    800546 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80052e:	50                   	push   %eax
  80052f:	68 f3 25 80 00       	push   $0x8025f3
  800534:	53                   	push   %ebx
  800535:	56                   	push   %esi
  800536:	e8 94 fe ff ff       	call   8003cf <printfmt>
  80053b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800541:	e9 cc fe ff ff       	jmp    800412 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800546:	52                   	push   %edx
  800547:	68 b1 29 80 00       	push   $0x8029b1
  80054c:	53                   	push   %ebx
  80054d:	56                   	push   %esi
  80054e:	e8 7c fe ff ff       	call   8003cf <printfmt>
  800553:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800556:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800559:	e9 b4 fe ff ff       	jmp    800412 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80055e:	8b 45 14             	mov    0x14(%ebp),%eax
  800561:	8d 50 04             	lea    0x4(%eax),%edx
  800564:	89 55 14             	mov    %edx,0x14(%ebp)
  800567:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800569:	85 ff                	test   %edi,%edi
  80056b:	b8 ec 25 80 00       	mov    $0x8025ec,%eax
  800570:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800573:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800577:	0f 8e 94 00 00 00    	jle    800611 <vprintfmt+0x225>
  80057d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800581:	0f 84 98 00 00 00    	je     80061f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800587:	83 ec 08             	sub    $0x8,%esp
  80058a:	ff 75 d0             	pushl  -0x30(%ebp)
  80058d:	57                   	push   %edi
  80058e:	e8 86 02 00 00       	call   800819 <strnlen>
  800593:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800596:	29 c1                	sub    %eax,%ecx
  800598:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80059b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80059e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005a8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005aa:	eb 0f                	jmp    8005bb <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005ac:	83 ec 08             	sub    $0x8,%esp
  8005af:	53                   	push   %ebx
  8005b0:	ff 75 e0             	pushl  -0x20(%ebp)
  8005b3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b5:	83 ef 01             	sub    $0x1,%edi
  8005b8:	83 c4 10             	add    $0x10,%esp
  8005bb:	85 ff                	test   %edi,%edi
  8005bd:	7f ed                	jg     8005ac <vprintfmt+0x1c0>
  8005bf:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005c2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005c5:	85 c9                	test   %ecx,%ecx
  8005c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8005cc:	0f 49 c1             	cmovns %ecx,%eax
  8005cf:	29 c1                	sub    %eax,%ecx
  8005d1:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005da:	89 cb                	mov    %ecx,%ebx
  8005dc:	eb 4d                	jmp    80062b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005de:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e2:	74 1b                	je     8005ff <vprintfmt+0x213>
  8005e4:	0f be c0             	movsbl %al,%eax
  8005e7:	83 e8 20             	sub    $0x20,%eax
  8005ea:	83 f8 5e             	cmp    $0x5e,%eax
  8005ed:	76 10                	jbe    8005ff <vprintfmt+0x213>
					putch('?', putdat);
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	ff 75 0c             	pushl  0xc(%ebp)
  8005f5:	6a 3f                	push   $0x3f
  8005f7:	ff 55 08             	call   *0x8(%ebp)
  8005fa:	83 c4 10             	add    $0x10,%esp
  8005fd:	eb 0d                	jmp    80060c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005ff:	83 ec 08             	sub    $0x8,%esp
  800602:	ff 75 0c             	pushl  0xc(%ebp)
  800605:	52                   	push   %edx
  800606:	ff 55 08             	call   *0x8(%ebp)
  800609:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80060c:	83 eb 01             	sub    $0x1,%ebx
  80060f:	eb 1a                	jmp    80062b <vprintfmt+0x23f>
  800611:	89 75 08             	mov    %esi,0x8(%ebp)
  800614:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800617:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80061a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80061d:	eb 0c                	jmp    80062b <vprintfmt+0x23f>
  80061f:	89 75 08             	mov    %esi,0x8(%ebp)
  800622:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800625:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800628:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80062b:	83 c7 01             	add    $0x1,%edi
  80062e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800632:	0f be d0             	movsbl %al,%edx
  800635:	85 d2                	test   %edx,%edx
  800637:	74 23                	je     80065c <vprintfmt+0x270>
  800639:	85 f6                	test   %esi,%esi
  80063b:	78 a1                	js     8005de <vprintfmt+0x1f2>
  80063d:	83 ee 01             	sub    $0x1,%esi
  800640:	79 9c                	jns    8005de <vprintfmt+0x1f2>
  800642:	89 df                	mov    %ebx,%edi
  800644:	8b 75 08             	mov    0x8(%ebp),%esi
  800647:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80064a:	eb 18                	jmp    800664 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80064c:	83 ec 08             	sub    $0x8,%esp
  80064f:	53                   	push   %ebx
  800650:	6a 20                	push   $0x20
  800652:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800654:	83 ef 01             	sub    $0x1,%edi
  800657:	83 c4 10             	add    $0x10,%esp
  80065a:	eb 08                	jmp    800664 <vprintfmt+0x278>
  80065c:	89 df                	mov    %ebx,%edi
  80065e:	8b 75 08             	mov    0x8(%ebp),%esi
  800661:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800664:	85 ff                	test   %edi,%edi
  800666:	7f e4                	jg     80064c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800668:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80066b:	e9 a2 fd ff ff       	jmp    800412 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800670:	83 fa 01             	cmp    $0x1,%edx
  800673:	7e 16                	jle    80068b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	8d 50 08             	lea    0x8(%eax),%edx
  80067b:	89 55 14             	mov    %edx,0x14(%ebp)
  80067e:	8b 50 04             	mov    0x4(%eax),%edx
  800681:	8b 00                	mov    (%eax),%eax
  800683:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800686:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800689:	eb 32                	jmp    8006bd <vprintfmt+0x2d1>
	else if (lflag)
  80068b:	85 d2                	test   %edx,%edx
  80068d:	74 18                	je     8006a7 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80068f:	8b 45 14             	mov    0x14(%ebp),%eax
  800692:	8d 50 04             	lea    0x4(%eax),%edx
  800695:	89 55 14             	mov    %edx,0x14(%ebp)
  800698:	8b 00                	mov    (%eax),%eax
  80069a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069d:	89 c1                	mov    %eax,%ecx
  80069f:	c1 f9 1f             	sar    $0x1f,%ecx
  8006a2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006a5:	eb 16                	jmp    8006bd <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006aa:	8d 50 04             	lea    0x4(%eax),%edx
  8006ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b0:	8b 00                	mov    (%eax),%eax
  8006b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b5:	89 c1                	mov    %eax,%ecx
  8006b7:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006bd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006c0:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006c3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006c8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006cc:	79 74                	jns    800742 <vprintfmt+0x356>
				putch('-', putdat);
  8006ce:	83 ec 08             	sub    $0x8,%esp
  8006d1:	53                   	push   %ebx
  8006d2:	6a 2d                	push   $0x2d
  8006d4:	ff d6                	call   *%esi
				num = -(long long) num;
  8006d6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006d9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006dc:	f7 d8                	neg    %eax
  8006de:	83 d2 00             	adc    $0x0,%edx
  8006e1:	f7 da                	neg    %edx
  8006e3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006e6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006eb:	eb 55                	jmp    800742 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006ed:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f0:	e8 83 fc ff ff       	call   800378 <getuint>
			base = 10;
  8006f5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006fa:	eb 46                	jmp    800742 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006fc:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ff:	e8 74 fc ff ff       	call   800378 <getuint>
			base = 8;
  800704:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800709:	eb 37                	jmp    800742 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80070b:	83 ec 08             	sub    $0x8,%esp
  80070e:	53                   	push   %ebx
  80070f:	6a 30                	push   $0x30
  800711:	ff d6                	call   *%esi
			putch('x', putdat);
  800713:	83 c4 08             	add    $0x8,%esp
  800716:	53                   	push   %ebx
  800717:	6a 78                	push   $0x78
  800719:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80071b:	8b 45 14             	mov    0x14(%ebp),%eax
  80071e:	8d 50 04             	lea    0x4(%eax),%edx
  800721:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800724:	8b 00                	mov    (%eax),%eax
  800726:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80072b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80072e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800733:	eb 0d                	jmp    800742 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800735:	8d 45 14             	lea    0x14(%ebp),%eax
  800738:	e8 3b fc ff ff       	call   800378 <getuint>
			base = 16;
  80073d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800742:	83 ec 0c             	sub    $0xc,%esp
  800745:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800749:	57                   	push   %edi
  80074a:	ff 75 e0             	pushl  -0x20(%ebp)
  80074d:	51                   	push   %ecx
  80074e:	52                   	push   %edx
  80074f:	50                   	push   %eax
  800750:	89 da                	mov    %ebx,%edx
  800752:	89 f0                	mov    %esi,%eax
  800754:	e8 70 fb ff ff       	call   8002c9 <printnum>
			break;
  800759:	83 c4 20             	add    $0x20,%esp
  80075c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80075f:	e9 ae fc ff ff       	jmp    800412 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800764:	83 ec 08             	sub    $0x8,%esp
  800767:	53                   	push   %ebx
  800768:	51                   	push   %ecx
  800769:	ff d6                	call   *%esi
			break;
  80076b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800771:	e9 9c fc ff ff       	jmp    800412 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800776:	83 ec 08             	sub    $0x8,%esp
  800779:	53                   	push   %ebx
  80077a:	6a 25                	push   $0x25
  80077c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80077e:	83 c4 10             	add    $0x10,%esp
  800781:	eb 03                	jmp    800786 <vprintfmt+0x39a>
  800783:	83 ef 01             	sub    $0x1,%edi
  800786:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80078a:	75 f7                	jne    800783 <vprintfmt+0x397>
  80078c:	e9 81 fc ff ff       	jmp    800412 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800791:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800794:	5b                   	pop    %ebx
  800795:	5e                   	pop    %esi
  800796:	5f                   	pop    %edi
  800797:	5d                   	pop    %ebp
  800798:	c3                   	ret    

00800799 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	83 ec 18             	sub    $0x18,%esp
  80079f:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007ac:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b6:	85 c0                	test   %eax,%eax
  8007b8:	74 26                	je     8007e0 <vsnprintf+0x47>
  8007ba:	85 d2                	test   %edx,%edx
  8007bc:	7e 22                	jle    8007e0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007be:	ff 75 14             	pushl  0x14(%ebp)
  8007c1:	ff 75 10             	pushl  0x10(%ebp)
  8007c4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c7:	50                   	push   %eax
  8007c8:	68 b2 03 80 00       	push   $0x8003b2
  8007cd:	e8 1a fc ff ff       	call   8003ec <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007db:	83 c4 10             	add    $0x10,%esp
  8007de:	eb 05                	jmp    8007e5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007e0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007e5:	c9                   	leave  
  8007e6:	c3                   	ret    

008007e7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ed:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007f0:	50                   	push   %eax
  8007f1:	ff 75 10             	pushl  0x10(%ebp)
  8007f4:	ff 75 0c             	pushl  0xc(%ebp)
  8007f7:	ff 75 08             	pushl  0x8(%ebp)
  8007fa:	e8 9a ff ff ff       	call   800799 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ff:	c9                   	leave  
  800800:	c3                   	ret    

00800801 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800807:	b8 00 00 00 00       	mov    $0x0,%eax
  80080c:	eb 03                	jmp    800811 <strlen+0x10>
		n++;
  80080e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800811:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800815:	75 f7                	jne    80080e <strlen+0xd>
		n++;
	return n;
}
  800817:	5d                   	pop    %ebp
  800818:	c3                   	ret    

00800819 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800822:	ba 00 00 00 00       	mov    $0x0,%edx
  800827:	eb 03                	jmp    80082c <strnlen+0x13>
		n++;
  800829:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082c:	39 c2                	cmp    %eax,%edx
  80082e:	74 08                	je     800838 <strnlen+0x1f>
  800830:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800834:	75 f3                	jne    800829 <strnlen+0x10>
  800836:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	53                   	push   %ebx
  80083e:	8b 45 08             	mov    0x8(%ebp),%eax
  800841:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800844:	89 c2                	mov    %eax,%edx
  800846:	83 c2 01             	add    $0x1,%edx
  800849:	83 c1 01             	add    $0x1,%ecx
  80084c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800850:	88 5a ff             	mov    %bl,-0x1(%edx)
  800853:	84 db                	test   %bl,%bl
  800855:	75 ef                	jne    800846 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800857:	5b                   	pop    %ebx
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	53                   	push   %ebx
  80085e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800861:	53                   	push   %ebx
  800862:	e8 9a ff ff ff       	call   800801 <strlen>
  800867:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80086a:	ff 75 0c             	pushl  0xc(%ebp)
  80086d:	01 d8                	add    %ebx,%eax
  80086f:	50                   	push   %eax
  800870:	e8 c5 ff ff ff       	call   80083a <strcpy>
	return dst;
}
  800875:	89 d8                	mov    %ebx,%eax
  800877:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80087a:	c9                   	leave  
  80087b:	c3                   	ret    

0080087c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	56                   	push   %esi
  800880:	53                   	push   %ebx
  800881:	8b 75 08             	mov    0x8(%ebp),%esi
  800884:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800887:	89 f3                	mov    %esi,%ebx
  800889:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80088c:	89 f2                	mov    %esi,%edx
  80088e:	eb 0f                	jmp    80089f <strncpy+0x23>
		*dst++ = *src;
  800890:	83 c2 01             	add    $0x1,%edx
  800893:	0f b6 01             	movzbl (%ecx),%eax
  800896:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800899:	80 39 01             	cmpb   $0x1,(%ecx)
  80089c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80089f:	39 da                	cmp    %ebx,%edx
  8008a1:	75 ed                	jne    800890 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008a3:	89 f0                	mov    %esi,%eax
  8008a5:	5b                   	pop    %ebx
  8008a6:	5e                   	pop    %esi
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	56                   	push   %esi
  8008ad:	53                   	push   %ebx
  8008ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b4:	8b 55 10             	mov    0x10(%ebp),%edx
  8008b7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b9:	85 d2                	test   %edx,%edx
  8008bb:	74 21                	je     8008de <strlcpy+0x35>
  8008bd:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008c1:	89 f2                	mov    %esi,%edx
  8008c3:	eb 09                	jmp    8008ce <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008c5:	83 c2 01             	add    $0x1,%edx
  8008c8:	83 c1 01             	add    $0x1,%ecx
  8008cb:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008ce:	39 c2                	cmp    %eax,%edx
  8008d0:	74 09                	je     8008db <strlcpy+0x32>
  8008d2:	0f b6 19             	movzbl (%ecx),%ebx
  8008d5:	84 db                	test   %bl,%bl
  8008d7:	75 ec                	jne    8008c5 <strlcpy+0x1c>
  8008d9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008db:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008de:	29 f0                	sub    %esi,%eax
}
  8008e0:	5b                   	pop    %ebx
  8008e1:	5e                   	pop    %esi
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ea:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ed:	eb 06                	jmp    8008f5 <strcmp+0x11>
		p++, q++;
  8008ef:	83 c1 01             	add    $0x1,%ecx
  8008f2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008f5:	0f b6 01             	movzbl (%ecx),%eax
  8008f8:	84 c0                	test   %al,%al
  8008fa:	74 04                	je     800900 <strcmp+0x1c>
  8008fc:	3a 02                	cmp    (%edx),%al
  8008fe:	74 ef                	je     8008ef <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800900:	0f b6 c0             	movzbl %al,%eax
  800903:	0f b6 12             	movzbl (%edx),%edx
  800906:	29 d0                	sub    %edx,%eax
}
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	53                   	push   %ebx
  80090e:	8b 45 08             	mov    0x8(%ebp),%eax
  800911:	8b 55 0c             	mov    0xc(%ebp),%edx
  800914:	89 c3                	mov    %eax,%ebx
  800916:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800919:	eb 06                	jmp    800921 <strncmp+0x17>
		n--, p++, q++;
  80091b:	83 c0 01             	add    $0x1,%eax
  80091e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800921:	39 d8                	cmp    %ebx,%eax
  800923:	74 15                	je     80093a <strncmp+0x30>
  800925:	0f b6 08             	movzbl (%eax),%ecx
  800928:	84 c9                	test   %cl,%cl
  80092a:	74 04                	je     800930 <strncmp+0x26>
  80092c:	3a 0a                	cmp    (%edx),%cl
  80092e:	74 eb                	je     80091b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800930:	0f b6 00             	movzbl (%eax),%eax
  800933:	0f b6 12             	movzbl (%edx),%edx
  800936:	29 d0                	sub    %edx,%eax
  800938:	eb 05                	jmp    80093f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80093a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80093f:	5b                   	pop    %ebx
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	8b 45 08             	mov    0x8(%ebp),%eax
  800948:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80094c:	eb 07                	jmp    800955 <strchr+0x13>
		if (*s == c)
  80094e:	38 ca                	cmp    %cl,%dl
  800950:	74 0f                	je     800961 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800952:	83 c0 01             	add    $0x1,%eax
  800955:	0f b6 10             	movzbl (%eax),%edx
  800958:	84 d2                	test   %dl,%dl
  80095a:	75 f2                	jne    80094e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80095c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800961:	5d                   	pop    %ebp
  800962:	c3                   	ret    

00800963 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
  800969:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80096d:	eb 03                	jmp    800972 <strfind+0xf>
  80096f:	83 c0 01             	add    $0x1,%eax
  800972:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800975:	38 ca                	cmp    %cl,%dl
  800977:	74 04                	je     80097d <strfind+0x1a>
  800979:	84 d2                	test   %dl,%dl
  80097b:	75 f2                	jne    80096f <strfind+0xc>
			break;
	return (char *) s;
}
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	57                   	push   %edi
  800983:	56                   	push   %esi
  800984:	53                   	push   %ebx
  800985:	8b 7d 08             	mov    0x8(%ebp),%edi
  800988:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80098b:	85 c9                	test   %ecx,%ecx
  80098d:	74 36                	je     8009c5 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80098f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800995:	75 28                	jne    8009bf <memset+0x40>
  800997:	f6 c1 03             	test   $0x3,%cl
  80099a:	75 23                	jne    8009bf <memset+0x40>
		c &= 0xFF;
  80099c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009a0:	89 d3                	mov    %edx,%ebx
  8009a2:	c1 e3 08             	shl    $0x8,%ebx
  8009a5:	89 d6                	mov    %edx,%esi
  8009a7:	c1 e6 18             	shl    $0x18,%esi
  8009aa:	89 d0                	mov    %edx,%eax
  8009ac:	c1 e0 10             	shl    $0x10,%eax
  8009af:	09 f0                	or     %esi,%eax
  8009b1:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009b3:	89 d8                	mov    %ebx,%eax
  8009b5:	09 d0                	or     %edx,%eax
  8009b7:	c1 e9 02             	shr    $0x2,%ecx
  8009ba:	fc                   	cld    
  8009bb:	f3 ab                	rep stos %eax,%es:(%edi)
  8009bd:	eb 06                	jmp    8009c5 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c2:	fc                   	cld    
  8009c3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009c5:	89 f8                	mov    %edi,%eax
  8009c7:	5b                   	pop    %ebx
  8009c8:	5e                   	pop    %esi
  8009c9:	5f                   	pop    %edi
  8009ca:	5d                   	pop    %ebp
  8009cb:	c3                   	ret    

008009cc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	57                   	push   %edi
  8009d0:	56                   	push   %esi
  8009d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009da:	39 c6                	cmp    %eax,%esi
  8009dc:	73 35                	jae    800a13 <memmove+0x47>
  8009de:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009e1:	39 d0                	cmp    %edx,%eax
  8009e3:	73 2e                	jae    800a13 <memmove+0x47>
		s += n;
		d += n;
  8009e5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e8:	89 d6                	mov    %edx,%esi
  8009ea:	09 fe                	or     %edi,%esi
  8009ec:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009f2:	75 13                	jne    800a07 <memmove+0x3b>
  8009f4:	f6 c1 03             	test   $0x3,%cl
  8009f7:	75 0e                	jne    800a07 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009f9:	83 ef 04             	sub    $0x4,%edi
  8009fc:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009ff:	c1 e9 02             	shr    $0x2,%ecx
  800a02:	fd                   	std    
  800a03:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a05:	eb 09                	jmp    800a10 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a07:	83 ef 01             	sub    $0x1,%edi
  800a0a:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a0d:	fd                   	std    
  800a0e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a10:	fc                   	cld    
  800a11:	eb 1d                	jmp    800a30 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a13:	89 f2                	mov    %esi,%edx
  800a15:	09 c2                	or     %eax,%edx
  800a17:	f6 c2 03             	test   $0x3,%dl
  800a1a:	75 0f                	jne    800a2b <memmove+0x5f>
  800a1c:	f6 c1 03             	test   $0x3,%cl
  800a1f:	75 0a                	jne    800a2b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a21:	c1 e9 02             	shr    $0x2,%ecx
  800a24:	89 c7                	mov    %eax,%edi
  800a26:	fc                   	cld    
  800a27:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a29:	eb 05                	jmp    800a30 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a2b:	89 c7                	mov    %eax,%edi
  800a2d:	fc                   	cld    
  800a2e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a30:	5e                   	pop    %esi
  800a31:	5f                   	pop    %edi
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a37:	ff 75 10             	pushl  0x10(%ebp)
  800a3a:	ff 75 0c             	pushl  0xc(%ebp)
  800a3d:	ff 75 08             	pushl  0x8(%ebp)
  800a40:	e8 87 ff ff ff       	call   8009cc <memmove>
}
  800a45:	c9                   	leave  
  800a46:	c3                   	ret    

00800a47 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	56                   	push   %esi
  800a4b:	53                   	push   %ebx
  800a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a52:	89 c6                	mov    %eax,%esi
  800a54:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a57:	eb 1a                	jmp    800a73 <memcmp+0x2c>
		if (*s1 != *s2)
  800a59:	0f b6 08             	movzbl (%eax),%ecx
  800a5c:	0f b6 1a             	movzbl (%edx),%ebx
  800a5f:	38 d9                	cmp    %bl,%cl
  800a61:	74 0a                	je     800a6d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a63:	0f b6 c1             	movzbl %cl,%eax
  800a66:	0f b6 db             	movzbl %bl,%ebx
  800a69:	29 d8                	sub    %ebx,%eax
  800a6b:	eb 0f                	jmp    800a7c <memcmp+0x35>
		s1++, s2++;
  800a6d:	83 c0 01             	add    $0x1,%eax
  800a70:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a73:	39 f0                	cmp    %esi,%eax
  800a75:	75 e2                	jne    800a59 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a7c:	5b                   	pop    %ebx
  800a7d:	5e                   	pop    %esi
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    

00800a80 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	53                   	push   %ebx
  800a84:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a87:	89 c1                	mov    %eax,%ecx
  800a89:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a8c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a90:	eb 0a                	jmp    800a9c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a92:	0f b6 10             	movzbl (%eax),%edx
  800a95:	39 da                	cmp    %ebx,%edx
  800a97:	74 07                	je     800aa0 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a99:	83 c0 01             	add    $0x1,%eax
  800a9c:	39 c8                	cmp    %ecx,%eax
  800a9e:	72 f2                	jb     800a92 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aa0:	5b                   	pop    %ebx
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	57                   	push   %edi
  800aa7:	56                   	push   %esi
  800aa8:	53                   	push   %ebx
  800aa9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aac:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aaf:	eb 03                	jmp    800ab4 <strtol+0x11>
		s++;
  800ab1:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab4:	0f b6 01             	movzbl (%ecx),%eax
  800ab7:	3c 20                	cmp    $0x20,%al
  800ab9:	74 f6                	je     800ab1 <strtol+0xe>
  800abb:	3c 09                	cmp    $0x9,%al
  800abd:	74 f2                	je     800ab1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800abf:	3c 2b                	cmp    $0x2b,%al
  800ac1:	75 0a                	jne    800acd <strtol+0x2a>
		s++;
  800ac3:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ac6:	bf 00 00 00 00       	mov    $0x0,%edi
  800acb:	eb 11                	jmp    800ade <strtol+0x3b>
  800acd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ad2:	3c 2d                	cmp    $0x2d,%al
  800ad4:	75 08                	jne    800ade <strtol+0x3b>
		s++, neg = 1;
  800ad6:	83 c1 01             	add    $0x1,%ecx
  800ad9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ade:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ae4:	75 15                	jne    800afb <strtol+0x58>
  800ae6:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae9:	75 10                	jne    800afb <strtol+0x58>
  800aeb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aef:	75 7c                	jne    800b6d <strtol+0xca>
		s += 2, base = 16;
  800af1:	83 c1 02             	add    $0x2,%ecx
  800af4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800af9:	eb 16                	jmp    800b11 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800afb:	85 db                	test   %ebx,%ebx
  800afd:	75 12                	jne    800b11 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aff:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b04:	80 39 30             	cmpb   $0x30,(%ecx)
  800b07:	75 08                	jne    800b11 <strtol+0x6e>
		s++, base = 8;
  800b09:	83 c1 01             	add    $0x1,%ecx
  800b0c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b11:	b8 00 00 00 00       	mov    $0x0,%eax
  800b16:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b19:	0f b6 11             	movzbl (%ecx),%edx
  800b1c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b1f:	89 f3                	mov    %esi,%ebx
  800b21:	80 fb 09             	cmp    $0x9,%bl
  800b24:	77 08                	ja     800b2e <strtol+0x8b>
			dig = *s - '0';
  800b26:	0f be d2             	movsbl %dl,%edx
  800b29:	83 ea 30             	sub    $0x30,%edx
  800b2c:	eb 22                	jmp    800b50 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b2e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b31:	89 f3                	mov    %esi,%ebx
  800b33:	80 fb 19             	cmp    $0x19,%bl
  800b36:	77 08                	ja     800b40 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b38:	0f be d2             	movsbl %dl,%edx
  800b3b:	83 ea 57             	sub    $0x57,%edx
  800b3e:	eb 10                	jmp    800b50 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b40:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b43:	89 f3                	mov    %esi,%ebx
  800b45:	80 fb 19             	cmp    $0x19,%bl
  800b48:	77 16                	ja     800b60 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b4a:	0f be d2             	movsbl %dl,%edx
  800b4d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b50:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b53:	7d 0b                	jge    800b60 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b55:	83 c1 01             	add    $0x1,%ecx
  800b58:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b5c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b5e:	eb b9                	jmp    800b19 <strtol+0x76>

	if (endptr)
  800b60:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b64:	74 0d                	je     800b73 <strtol+0xd0>
		*endptr = (char *) s;
  800b66:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b69:	89 0e                	mov    %ecx,(%esi)
  800b6b:	eb 06                	jmp    800b73 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b6d:	85 db                	test   %ebx,%ebx
  800b6f:	74 98                	je     800b09 <strtol+0x66>
  800b71:	eb 9e                	jmp    800b11 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b73:	89 c2                	mov    %eax,%edx
  800b75:	f7 da                	neg    %edx
  800b77:	85 ff                	test   %edi,%edi
  800b79:	0f 45 c2             	cmovne %edx,%eax
}
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	57                   	push   %edi
  800b85:	56                   	push   %esi
  800b86:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b87:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b92:	89 c3                	mov    %eax,%ebx
  800b94:	89 c7                	mov    %eax,%edi
  800b96:	89 c6                	mov    %eax,%esi
  800b98:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b9a:	5b                   	pop    %ebx
  800b9b:	5e                   	pop    %esi
  800b9c:	5f                   	pop    %edi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	57                   	push   %edi
  800ba3:	56                   	push   %esi
  800ba4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba5:	ba 00 00 00 00       	mov    $0x0,%edx
  800baa:	b8 01 00 00 00       	mov    $0x1,%eax
  800baf:	89 d1                	mov    %edx,%ecx
  800bb1:	89 d3                	mov    %edx,%ebx
  800bb3:	89 d7                	mov    %edx,%edi
  800bb5:	89 d6                	mov    %edx,%esi
  800bb7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
  800bc4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bcc:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd4:	89 cb                	mov    %ecx,%ebx
  800bd6:	89 cf                	mov    %ecx,%edi
  800bd8:	89 ce                	mov    %ecx,%esi
  800bda:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bdc:	85 c0                	test   %eax,%eax
  800bde:	7e 17                	jle    800bf7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be0:	83 ec 0c             	sub    $0xc,%esp
  800be3:	50                   	push   %eax
  800be4:	6a 03                	push   $0x3
  800be6:	68 df 28 80 00       	push   $0x8028df
  800beb:	6a 23                	push   $0x23
  800bed:	68 fc 28 80 00       	push   $0x8028fc
  800bf2:	e8 e5 f5 ff ff       	call   8001dc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bf7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5f                   	pop    %edi
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    

00800bff <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	57                   	push   %edi
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c05:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0a:	b8 02 00 00 00       	mov    $0x2,%eax
  800c0f:	89 d1                	mov    %edx,%ecx
  800c11:	89 d3                	mov    %edx,%ebx
  800c13:	89 d7                	mov    %edx,%edi
  800c15:	89 d6                	mov    %edx,%esi
  800c17:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <sys_yield>:

void
sys_yield(void)
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
  800c29:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c2e:	89 d1                	mov    %edx,%ecx
  800c30:	89 d3                	mov    %edx,%ebx
  800c32:	89 d7                	mov    %edx,%edi
  800c34:	89 d6                	mov    %edx,%esi
  800c36:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
  800c43:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c46:	be 00 00 00 00       	mov    $0x0,%esi
  800c4b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c53:	8b 55 08             	mov    0x8(%ebp),%edx
  800c56:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c59:	89 f7                	mov    %esi,%edi
  800c5b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5d:	85 c0                	test   %eax,%eax
  800c5f:	7e 17                	jle    800c78 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c61:	83 ec 0c             	sub    $0xc,%esp
  800c64:	50                   	push   %eax
  800c65:	6a 04                	push   $0x4
  800c67:	68 df 28 80 00       	push   $0x8028df
  800c6c:	6a 23                	push   $0x23
  800c6e:	68 fc 28 80 00       	push   $0x8028fc
  800c73:	e8 64 f5 ff ff       	call   8001dc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7b:	5b                   	pop    %ebx
  800c7c:	5e                   	pop    %esi
  800c7d:	5f                   	pop    %edi
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	57                   	push   %edi
  800c84:	56                   	push   %esi
  800c85:	53                   	push   %ebx
  800c86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c89:	b8 05 00 00 00       	mov    $0x5,%eax
  800c8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c91:	8b 55 08             	mov    0x8(%ebp),%edx
  800c94:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c97:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c9a:	8b 75 18             	mov    0x18(%ebp),%esi
  800c9d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9f:	85 c0                	test   %eax,%eax
  800ca1:	7e 17                	jle    800cba <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca3:	83 ec 0c             	sub    $0xc,%esp
  800ca6:	50                   	push   %eax
  800ca7:	6a 05                	push   $0x5
  800ca9:	68 df 28 80 00       	push   $0x8028df
  800cae:	6a 23                	push   $0x23
  800cb0:	68 fc 28 80 00       	push   $0x8028fc
  800cb5:	e8 22 f5 ff ff       	call   8001dc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
  800cc8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd0:	b8 06 00 00 00       	mov    $0x6,%eax
  800cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	89 df                	mov    %ebx,%edi
  800cdd:	89 de                	mov    %ebx,%esi
  800cdf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	7e 17                	jle    800cfc <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce5:	83 ec 0c             	sub    $0xc,%esp
  800ce8:	50                   	push   %eax
  800ce9:	6a 06                	push   $0x6
  800ceb:	68 df 28 80 00       	push   $0x8028df
  800cf0:	6a 23                	push   $0x23
  800cf2:	68 fc 28 80 00       	push   $0x8028fc
  800cf7:	e8 e0 f4 ff ff       	call   8001dc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	57                   	push   %edi
  800d08:	56                   	push   %esi
  800d09:	53                   	push   %ebx
  800d0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d12:	b8 08 00 00 00       	mov    $0x8,%eax
  800d17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1d:	89 df                	mov    %ebx,%edi
  800d1f:	89 de                	mov    %ebx,%esi
  800d21:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d23:	85 c0                	test   %eax,%eax
  800d25:	7e 17                	jle    800d3e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d27:	83 ec 0c             	sub    $0xc,%esp
  800d2a:	50                   	push   %eax
  800d2b:	6a 08                	push   $0x8
  800d2d:	68 df 28 80 00       	push   $0x8028df
  800d32:	6a 23                	push   $0x23
  800d34:	68 fc 28 80 00       	push   $0x8028fc
  800d39:	e8 9e f4 ff ff       	call   8001dc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	57                   	push   %edi
  800d4a:	56                   	push   %esi
  800d4b:	53                   	push   %ebx
  800d4c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d54:	b8 09 00 00 00       	mov    $0x9,%eax
  800d59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5f:	89 df                	mov    %ebx,%edi
  800d61:	89 de                	mov    %ebx,%esi
  800d63:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d65:	85 c0                	test   %eax,%eax
  800d67:	7e 17                	jle    800d80 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d69:	83 ec 0c             	sub    $0xc,%esp
  800d6c:	50                   	push   %eax
  800d6d:	6a 09                	push   $0x9
  800d6f:	68 df 28 80 00       	push   $0x8028df
  800d74:	6a 23                	push   $0x23
  800d76:	68 fc 28 80 00       	push   $0x8028fc
  800d7b:	e8 5c f4 ff ff       	call   8001dc <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	57                   	push   %edi
  800d8c:	56                   	push   %esi
  800d8d:	53                   	push   %ebx
  800d8e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d91:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d96:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800da1:	89 df                	mov    %ebx,%edi
  800da3:	89 de                	mov    %ebx,%esi
  800da5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da7:	85 c0                	test   %eax,%eax
  800da9:	7e 17                	jle    800dc2 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dab:	83 ec 0c             	sub    $0xc,%esp
  800dae:	50                   	push   %eax
  800daf:	6a 0a                	push   $0xa
  800db1:	68 df 28 80 00       	push   $0x8028df
  800db6:	6a 23                	push   $0x23
  800db8:	68 fc 28 80 00       	push   $0x8028fc
  800dbd:	e8 1a f4 ff ff       	call   8001dc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc5:	5b                   	pop    %ebx
  800dc6:	5e                   	pop    %esi
  800dc7:	5f                   	pop    %edi
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    

00800dca <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	57                   	push   %edi
  800dce:	56                   	push   %esi
  800dcf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd0:	be 00 00 00 00       	mov    $0x0,%esi
  800dd5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddd:	8b 55 08             	mov    0x8(%ebp),%edx
  800de0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800de8:	5b                   	pop    %ebx
  800de9:	5e                   	pop    %esi
  800dea:	5f                   	pop    %edi
  800deb:	5d                   	pop    %ebp
  800dec:	c3                   	ret    

00800ded <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ded:	55                   	push   %ebp
  800dee:	89 e5                	mov    %esp,%ebp
  800df0:	57                   	push   %edi
  800df1:	56                   	push   %esi
  800df2:	53                   	push   %ebx
  800df3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dfb:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e00:	8b 55 08             	mov    0x8(%ebp),%edx
  800e03:	89 cb                	mov    %ecx,%ebx
  800e05:	89 cf                	mov    %ecx,%edi
  800e07:	89 ce                	mov    %ecx,%esi
  800e09:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e0b:	85 c0                	test   %eax,%eax
  800e0d:	7e 17                	jle    800e26 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0f:	83 ec 0c             	sub    $0xc,%esp
  800e12:	50                   	push   %eax
  800e13:	6a 0d                	push   $0xd
  800e15:	68 df 28 80 00       	push   $0x8028df
  800e1a:	6a 23                	push   $0x23
  800e1c:	68 fc 28 80 00       	push   $0x8028fc
  800e21:	e8 b6 f3 ff ff       	call   8001dc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e29:	5b                   	pop    %ebx
  800e2a:	5e                   	pop    %esi
  800e2b:	5f                   	pop    %edi
  800e2c:	5d                   	pop    %ebp
  800e2d:	c3                   	ret    

00800e2e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e2e:	55                   	push   %ebp
  800e2f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e31:	8b 45 08             	mov    0x8(%ebp),%eax
  800e34:	05 00 00 00 30       	add    $0x30000000,%eax
  800e39:	c1 e8 0c             	shr    $0xc,%eax
}
  800e3c:	5d                   	pop    %ebp
  800e3d:	c3                   	ret    

00800e3e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e3e:	55                   	push   %ebp
  800e3f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e41:	8b 45 08             	mov    0x8(%ebp),%eax
  800e44:	05 00 00 00 30       	add    $0x30000000,%eax
  800e49:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e4e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    

00800e55 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
  800e58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e60:	89 c2                	mov    %eax,%edx
  800e62:	c1 ea 16             	shr    $0x16,%edx
  800e65:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e6c:	f6 c2 01             	test   $0x1,%dl
  800e6f:	74 11                	je     800e82 <fd_alloc+0x2d>
  800e71:	89 c2                	mov    %eax,%edx
  800e73:	c1 ea 0c             	shr    $0xc,%edx
  800e76:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e7d:	f6 c2 01             	test   $0x1,%dl
  800e80:	75 09                	jne    800e8b <fd_alloc+0x36>
			*fd_store = fd;
  800e82:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e84:	b8 00 00 00 00       	mov    $0x0,%eax
  800e89:	eb 17                	jmp    800ea2 <fd_alloc+0x4d>
  800e8b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e90:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e95:	75 c9                	jne    800e60 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e97:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e9d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    

00800ea4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800eaa:	83 f8 1f             	cmp    $0x1f,%eax
  800ead:	77 36                	ja     800ee5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800eaf:	c1 e0 0c             	shl    $0xc,%eax
  800eb2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eb7:	89 c2                	mov    %eax,%edx
  800eb9:	c1 ea 16             	shr    $0x16,%edx
  800ebc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ec3:	f6 c2 01             	test   $0x1,%dl
  800ec6:	74 24                	je     800eec <fd_lookup+0x48>
  800ec8:	89 c2                	mov    %eax,%edx
  800eca:	c1 ea 0c             	shr    $0xc,%edx
  800ecd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ed4:	f6 c2 01             	test   $0x1,%dl
  800ed7:	74 1a                	je     800ef3 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ed9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800edc:	89 02                	mov    %eax,(%edx)
	return 0;
  800ede:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee3:	eb 13                	jmp    800ef8 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ee5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eea:	eb 0c                	jmp    800ef8 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ef1:	eb 05                	jmp    800ef8 <fd_lookup+0x54>
  800ef3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ef8:	5d                   	pop    %ebp
  800ef9:	c3                   	ret    

00800efa <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800efa:	55                   	push   %ebp
  800efb:	89 e5                	mov    %esp,%ebp
  800efd:	83 ec 08             	sub    $0x8,%esp
  800f00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f03:	ba 88 29 80 00       	mov    $0x802988,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f08:	eb 13                	jmp    800f1d <dev_lookup+0x23>
  800f0a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f0d:	39 08                	cmp    %ecx,(%eax)
  800f0f:	75 0c                	jne    800f1d <dev_lookup+0x23>
			*dev = devtab[i];
  800f11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f14:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f16:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1b:	eb 2e                	jmp    800f4b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f1d:	8b 02                	mov    (%edx),%eax
  800f1f:	85 c0                	test   %eax,%eax
  800f21:	75 e7                	jne    800f0a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f23:	a1 04 40 80 00       	mov    0x804004,%eax
  800f28:	8b 40 48             	mov    0x48(%eax),%eax
  800f2b:	83 ec 04             	sub    $0x4,%esp
  800f2e:	51                   	push   %ecx
  800f2f:	50                   	push   %eax
  800f30:	68 0c 29 80 00       	push   $0x80290c
  800f35:	e8 7b f3 ff ff       	call   8002b5 <cprintf>
	*dev = 0;
  800f3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f3d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f43:	83 c4 10             	add    $0x10,%esp
  800f46:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f4b:	c9                   	leave  
  800f4c:	c3                   	ret    

00800f4d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f4d:	55                   	push   %ebp
  800f4e:	89 e5                	mov    %esp,%ebp
  800f50:	56                   	push   %esi
  800f51:	53                   	push   %ebx
  800f52:	83 ec 10             	sub    $0x10,%esp
  800f55:	8b 75 08             	mov    0x8(%ebp),%esi
  800f58:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f5e:	50                   	push   %eax
  800f5f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f65:	c1 e8 0c             	shr    $0xc,%eax
  800f68:	50                   	push   %eax
  800f69:	e8 36 ff ff ff       	call   800ea4 <fd_lookup>
  800f6e:	83 c4 08             	add    $0x8,%esp
  800f71:	85 c0                	test   %eax,%eax
  800f73:	78 05                	js     800f7a <fd_close+0x2d>
	    || fd != fd2)
  800f75:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f78:	74 0c                	je     800f86 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f7a:	84 db                	test   %bl,%bl
  800f7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f81:	0f 44 c2             	cmove  %edx,%eax
  800f84:	eb 41                	jmp    800fc7 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f86:	83 ec 08             	sub    $0x8,%esp
  800f89:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f8c:	50                   	push   %eax
  800f8d:	ff 36                	pushl  (%esi)
  800f8f:	e8 66 ff ff ff       	call   800efa <dev_lookup>
  800f94:	89 c3                	mov    %eax,%ebx
  800f96:	83 c4 10             	add    $0x10,%esp
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	78 1a                	js     800fb7 <fd_close+0x6a>
		if (dev->dev_close)
  800f9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fa0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fa3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	74 0b                	je     800fb7 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fac:	83 ec 0c             	sub    $0xc,%esp
  800faf:	56                   	push   %esi
  800fb0:	ff d0                	call   *%eax
  800fb2:	89 c3                	mov    %eax,%ebx
  800fb4:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fb7:	83 ec 08             	sub    $0x8,%esp
  800fba:	56                   	push   %esi
  800fbb:	6a 00                	push   $0x0
  800fbd:	e8 00 fd ff ff       	call   800cc2 <sys_page_unmap>
	return r;
  800fc2:	83 c4 10             	add    $0x10,%esp
  800fc5:	89 d8                	mov    %ebx,%eax
}
  800fc7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fca:	5b                   	pop    %ebx
  800fcb:	5e                   	pop    %esi
  800fcc:	5d                   	pop    %ebp
  800fcd:	c3                   	ret    

00800fce <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd7:	50                   	push   %eax
  800fd8:	ff 75 08             	pushl  0x8(%ebp)
  800fdb:	e8 c4 fe ff ff       	call   800ea4 <fd_lookup>
  800fe0:	83 c4 08             	add    $0x8,%esp
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	78 10                	js     800ff7 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fe7:	83 ec 08             	sub    $0x8,%esp
  800fea:	6a 01                	push   $0x1
  800fec:	ff 75 f4             	pushl  -0xc(%ebp)
  800fef:	e8 59 ff ff ff       	call   800f4d <fd_close>
  800ff4:	83 c4 10             	add    $0x10,%esp
}
  800ff7:	c9                   	leave  
  800ff8:	c3                   	ret    

00800ff9 <close_all>:

void
close_all(void)
{
  800ff9:	55                   	push   %ebp
  800ffa:	89 e5                	mov    %esp,%ebp
  800ffc:	53                   	push   %ebx
  800ffd:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801000:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801005:	83 ec 0c             	sub    $0xc,%esp
  801008:	53                   	push   %ebx
  801009:	e8 c0 ff ff ff       	call   800fce <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80100e:	83 c3 01             	add    $0x1,%ebx
  801011:	83 c4 10             	add    $0x10,%esp
  801014:	83 fb 20             	cmp    $0x20,%ebx
  801017:	75 ec                	jne    801005 <close_all+0xc>
		close(i);
}
  801019:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80101c:	c9                   	leave  
  80101d:	c3                   	ret    

0080101e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80101e:	55                   	push   %ebp
  80101f:	89 e5                	mov    %esp,%ebp
  801021:	57                   	push   %edi
  801022:	56                   	push   %esi
  801023:	53                   	push   %ebx
  801024:	83 ec 2c             	sub    $0x2c,%esp
  801027:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80102a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80102d:	50                   	push   %eax
  80102e:	ff 75 08             	pushl  0x8(%ebp)
  801031:	e8 6e fe ff ff       	call   800ea4 <fd_lookup>
  801036:	83 c4 08             	add    $0x8,%esp
  801039:	85 c0                	test   %eax,%eax
  80103b:	0f 88 c1 00 00 00    	js     801102 <dup+0xe4>
		return r;
	close(newfdnum);
  801041:	83 ec 0c             	sub    $0xc,%esp
  801044:	56                   	push   %esi
  801045:	e8 84 ff ff ff       	call   800fce <close>

	newfd = INDEX2FD(newfdnum);
  80104a:	89 f3                	mov    %esi,%ebx
  80104c:	c1 e3 0c             	shl    $0xc,%ebx
  80104f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801055:	83 c4 04             	add    $0x4,%esp
  801058:	ff 75 e4             	pushl  -0x1c(%ebp)
  80105b:	e8 de fd ff ff       	call   800e3e <fd2data>
  801060:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801062:	89 1c 24             	mov    %ebx,(%esp)
  801065:	e8 d4 fd ff ff       	call   800e3e <fd2data>
  80106a:	83 c4 10             	add    $0x10,%esp
  80106d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801070:	89 f8                	mov    %edi,%eax
  801072:	c1 e8 16             	shr    $0x16,%eax
  801075:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80107c:	a8 01                	test   $0x1,%al
  80107e:	74 37                	je     8010b7 <dup+0x99>
  801080:	89 f8                	mov    %edi,%eax
  801082:	c1 e8 0c             	shr    $0xc,%eax
  801085:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80108c:	f6 c2 01             	test   $0x1,%dl
  80108f:	74 26                	je     8010b7 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801091:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801098:	83 ec 0c             	sub    $0xc,%esp
  80109b:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a0:	50                   	push   %eax
  8010a1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010a4:	6a 00                	push   $0x0
  8010a6:	57                   	push   %edi
  8010a7:	6a 00                	push   $0x0
  8010a9:	e8 d2 fb ff ff       	call   800c80 <sys_page_map>
  8010ae:	89 c7                	mov    %eax,%edi
  8010b0:	83 c4 20             	add    $0x20,%esp
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	78 2e                	js     8010e5 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010b7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010ba:	89 d0                	mov    %edx,%eax
  8010bc:	c1 e8 0c             	shr    $0xc,%eax
  8010bf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c6:	83 ec 0c             	sub    $0xc,%esp
  8010c9:	25 07 0e 00 00       	and    $0xe07,%eax
  8010ce:	50                   	push   %eax
  8010cf:	53                   	push   %ebx
  8010d0:	6a 00                	push   $0x0
  8010d2:	52                   	push   %edx
  8010d3:	6a 00                	push   $0x0
  8010d5:	e8 a6 fb ff ff       	call   800c80 <sys_page_map>
  8010da:	89 c7                	mov    %eax,%edi
  8010dc:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010df:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010e1:	85 ff                	test   %edi,%edi
  8010e3:	79 1d                	jns    801102 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010e5:	83 ec 08             	sub    $0x8,%esp
  8010e8:	53                   	push   %ebx
  8010e9:	6a 00                	push   $0x0
  8010eb:	e8 d2 fb ff ff       	call   800cc2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010f0:	83 c4 08             	add    $0x8,%esp
  8010f3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010f6:	6a 00                	push   $0x0
  8010f8:	e8 c5 fb ff ff       	call   800cc2 <sys_page_unmap>
	return r;
  8010fd:	83 c4 10             	add    $0x10,%esp
  801100:	89 f8                	mov    %edi,%eax
}
  801102:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801105:	5b                   	pop    %ebx
  801106:	5e                   	pop    %esi
  801107:	5f                   	pop    %edi
  801108:	5d                   	pop    %ebp
  801109:	c3                   	ret    

0080110a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80110a:	55                   	push   %ebp
  80110b:	89 e5                	mov    %esp,%ebp
  80110d:	53                   	push   %ebx
  80110e:	83 ec 14             	sub    $0x14,%esp
  801111:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801114:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801117:	50                   	push   %eax
  801118:	53                   	push   %ebx
  801119:	e8 86 fd ff ff       	call   800ea4 <fd_lookup>
  80111e:	83 c4 08             	add    $0x8,%esp
  801121:	89 c2                	mov    %eax,%edx
  801123:	85 c0                	test   %eax,%eax
  801125:	78 6d                	js     801194 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801127:	83 ec 08             	sub    $0x8,%esp
  80112a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80112d:	50                   	push   %eax
  80112e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801131:	ff 30                	pushl  (%eax)
  801133:	e8 c2 fd ff ff       	call   800efa <dev_lookup>
  801138:	83 c4 10             	add    $0x10,%esp
  80113b:	85 c0                	test   %eax,%eax
  80113d:	78 4c                	js     80118b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80113f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801142:	8b 42 08             	mov    0x8(%edx),%eax
  801145:	83 e0 03             	and    $0x3,%eax
  801148:	83 f8 01             	cmp    $0x1,%eax
  80114b:	75 21                	jne    80116e <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80114d:	a1 04 40 80 00       	mov    0x804004,%eax
  801152:	8b 40 48             	mov    0x48(%eax),%eax
  801155:	83 ec 04             	sub    $0x4,%esp
  801158:	53                   	push   %ebx
  801159:	50                   	push   %eax
  80115a:	68 4d 29 80 00       	push   $0x80294d
  80115f:	e8 51 f1 ff ff       	call   8002b5 <cprintf>
		return -E_INVAL;
  801164:	83 c4 10             	add    $0x10,%esp
  801167:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80116c:	eb 26                	jmp    801194 <read+0x8a>
	}
	if (!dev->dev_read)
  80116e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801171:	8b 40 08             	mov    0x8(%eax),%eax
  801174:	85 c0                	test   %eax,%eax
  801176:	74 17                	je     80118f <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801178:	83 ec 04             	sub    $0x4,%esp
  80117b:	ff 75 10             	pushl  0x10(%ebp)
  80117e:	ff 75 0c             	pushl  0xc(%ebp)
  801181:	52                   	push   %edx
  801182:	ff d0                	call   *%eax
  801184:	89 c2                	mov    %eax,%edx
  801186:	83 c4 10             	add    $0x10,%esp
  801189:	eb 09                	jmp    801194 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118b:	89 c2                	mov    %eax,%edx
  80118d:	eb 05                	jmp    801194 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80118f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801194:	89 d0                	mov    %edx,%eax
  801196:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801199:	c9                   	leave  
  80119a:	c3                   	ret    

0080119b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80119b:	55                   	push   %ebp
  80119c:	89 e5                	mov    %esp,%ebp
  80119e:	57                   	push   %edi
  80119f:	56                   	push   %esi
  8011a0:	53                   	push   %ebx
  8011a1:	83 ec 0c             	sub    $0xc,%esp
  8011a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011a7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011af:	eb 21                	jmp    8011d2 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011b1:	83 ec 04             	sub    $0x4,%esp
  8011b4:	89 f0                	mov    %esi,%eax
  8011b6:	29 d8                	sub    %ebx,%eax
  8011b8:	50                   	push   %eax
  8011b9:	89 d8                	mov    %ebx,%eax
  8011bb:	03 45 0c             	add    0xc(%ebp),%eax
  8011be:	50                   	push   %eax
  8011bf:	57                   	push   %edi
  8011c0:	e8 45 ff ff ff       	call   80110a <read>
		if (m < 0)
  8011c5:	83 c4 10             	add    $0x10,%esp
  8011c8:	85 c0                	test   %eax,%eax
  8011ca:	78 10                	js     8011dc <readn+0x41>
			return m;
		if (m == 0)
  8011cc:	85 c0                	test   %eax,%eax
  8011ce:	74 0a                	je     8011da <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011d0:	01 c3                	add    %eax,%ebx
  8011d2:	39 f3                	cmp    %esi,%ebx
  8011d4:	72 db                	jb     8011b1 <readn+0x16>
  8011d6:	89 d8                	mov    %ebx,%eax
  8011d8:	eb 02                	jmp    8011dc <readn+0x41>
  8011da:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011df:	5b                   	pop    %ebx
  8011e0:	5e                   	pop    %esi
  8011e1:	5f                   	pop    %edi
  8011e2:	5d                   	pop    %ebp
  8011e3:	c3                   	ret    

008011e4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
  8011e7:	53                   	push   %ebx
  8011e8:	83 ec 14             	sub    $0x14,%esp
  8011eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f1:	50                   	push   %eax
  8011f2:	53                   	push   %ebx
  8011f3:	e8 ac fc ff ff       	call   800ea4 <fd_lookup>
  8011f8:	83 c4 08             	add    $0x8,%esp
  8011fb:	89 c2                	mov    %eax,%edx
  8011fd:	85 c0                	test   %eax,%eax
  8011ff:	78 68                	js     801269 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801201:	83 ec 08             	sub    $0x8,%esp
  801204:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801207:	50                   	push   %eax
  801208:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120b:	ff 30                	pushl  (%eax)
  80120d:	e8 e8 fc ff ff       	call   800efa <dev_lookup>
  801212:	83 c4 10             	add    $0x10,%esp
  801215:	85 c0                	test   %eax,%eax
  801217:	78 47                	js     801260 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801219:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801220:	75 21                	jne    801243 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801222:	a1 04 40 80 00       	mov    0x804004,%eax
  801227:	8b 40 48             	mov    0x48(%eax),%eax
  80122a:	83 ec 04             	sub    $0x4,%esp
  80122d:	53                   	push   %ebx
  80122e:	50                   	push   %eax
  80122f:	68 69 29 80 00       	push   $0x802969
  801234:	e8 7c f0 ff ff       	call   8002b5 <cprintf>
		return -E_INVAL;
  801239:	83 c4 10             	add    $0x10,%esp
  80123c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801241:	eb 26                	jmp    801269 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801243:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801246:	8b 52 0c             	mov    0xc(%edx),%edx
  801249:	85 d2                	test   %edx,%edx
  80124b:	74 17                	je     801264 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80124d:	83 ec 04             	sub    $0x4,%esp
  801250:	ff 75 10             	pushl  0x10(%ebp)
  801253:	ff 75 0c             	pushl  0xc(%ebp)
  801256:	50                   	push   %eax
  801257:	ff d2                	call   *%edx
  801259:	89 c2                	mov    %eax,%edx
  80125b:	83 c4 10             	add    $0x10,%esp
  80125e:	eb 09                	jmp    801269 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801260:	89 c2                	mov    %eax,%edx
  801262:	eb 05                	jmp    801269 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801264:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801269:	89 d0                	mov    %edx,%eax
  80126b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80126e:	c9                   	leave  
  80126f:	c3                   	ret    

00801270 <seek>:

int
seek(int fdnum, off_t offset)
{
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
  801273:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801276:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801279:	50                   	push   %eax
  80127a:	ff 75 08             	pushl  0x8(%ebp)
  80127d:	e8 22 fc ff ff       	call   800ea4 <fd_lookup>
  801282:	83 c4 08             	add    $0x8,%esp
  801285:	85 c0                	test   %eax,%eax
  801287:	78 0e                	js     801297 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801289:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80128c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80128f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801292:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801297:	c9                   	leave  
  801298:	c3                   	ret    

00801299 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801299:	55                   	push   %ebp
  80129a:	89 e5                	mov    %esp,%ebp
  80129c:	53                   	push   %ebx
  80129d:	83 ec 14             	sub    $0x14,%esp
  8012a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a6:	50                   	push   %eax
  8012a7:	53                   	push   %ebx
  8012a8:	e8 f7 fb ff ff       	call   800ea4 <fd_lookup>
  8012ad:	83 c4 08             	add    $0x8,%esp
  8012b0:	89 c2                	mov    %eax,%edx
  8012b2:	85 c0                	test   %eax,%eax
  8012b4:	78 65                	js     80131b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b6:	83 ec 08             	sub    $0x8,%esp
  8012b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012bc:	50                   	push   %eax
  8012bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c0:	ff 30                	pushl  (%eax)
  8012c2:	e8 33 fc ff ff       	call   800efa <dev_lookup>
  8012c7:	83 c4 10             	add    $0x10,%esp
  8012ca:	85 c0                	test   %eax,%eax
  8012cc:	78 44                	js     801312 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012d5:	75 21                	jne    8012f8 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012d7:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012dc:	8b 40 48             	mov    0x48(%eax),%eax
  8012df:	83 ec 04             	sub    $0x4,%esp
  8012e2:	53                   	push   %ebx
  8012e3:	50                   	push   %eax
  8012e4:	68 2c 29 80 00       	push   $0x80292c
  8012e9:	e8 c7 ef ff ff       	call   8002b5 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ee:	83 c4 10             	add    $0x10,%esp
  8012f1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012f6:	eb 23                	jmp    80131b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012fb:	8b 52 18             	mov    0x18(%edx),%edx
  8012fe:	85 d2                	test   %edx,%edx
  801300:	74 14                	je     801316 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801302:	83 ec 08             	sub    $0x8,%esp
  801305:	ff 75 0c             	pushl  0xc(%ebp)
  801308:	50                   	push   %eax
  801309:	ff d2                	call   *%edx
  80130b:	89 c2                	mov    %eax,%edx
  80130d:	83 c4 10             	add    $0x10,%esp
  801310:	eb 09                	jmp    80131b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801312:	89 c2                	mov    %eax,%edx
  801314:	eb 05                	jmp    80131b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801316:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80131b:	89 d0                	mov    %edx,%eax
  80131d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801320:	c9                   	leave  
  801321:	c3                   	ret    

00801322 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801322:	55                   	push   %ebp
  801323:	89 e5                	mov    %esp,%ebp
  801325:	53                   	push   %ebx
  801326:	83 ec 14             	sub    $0x14,%esp
  801329:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80132c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80132f:	50                   	push   %eax
  801330:	ff 75 08             	pushl  0x8(%ebp)
  801333:	e8 6c fb ff ff       	call   800ea4 <fd_lookup>
  801338:	83 c4 08             	add    $0x8,%esp
  80133b:	89 c2                	mov    %eax,%edx
  80133d:	85 c0                	test   %eax,%eax
  80133f:	78 58                	js     801399 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801341:	83 ec 08             	sub    $0x8,%esp
  801344:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801347:	50                   	push   %eax
  801348:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134b:	ff 30                	pushl  (%eax)
  80134d:	e8 a8 fb ff ff       	call   800efa <dev_lookup>
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	85 c0                	test   %eax,%eax
  801357:	78 37                	js     801390 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801359:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801360:	74 32                	je     801394 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801362:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801365:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80136c:	00 00 00 
	stat->st_isdir = 0;
  80136f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801376:	00 00 00 
	stat->st_dev = dev;
  801379:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80137f:	83 ec 08             	sub    $0x8,%esp
  801382:	53                   	push   %ebx
  801383:	ff 75 f0             	pushl  -0x10(%ebp)
  801386:	ff 50 14             	call   *0x14(%eax)
  801389:	89 c2                	mov    %eax,%edx
  80138b:	83 c4 10             	add    $0x10,%esp
  80138e:	eb 09                	jmp    801399 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801390:	89 c2                	mov    %eax,%edx
  801392:	eb 05                	jmp    801399 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801394:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801399:	89 d0                	mov    %edx,%eax
  80139b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139e:	c9                   	leave  
  80139f:	c3                   	ret    

008013a0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013a0:	55                   	push   %ebp
  8013a1:	89 e5                	mov    %esp,%ebp
  8013a3:	56                   	push   %esi
  8013a4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013a5:	83 ec 08             	sub    $0x8,%esp
  8013a8:	6a 00                	push   $0x0
  8013aa:	ff 75 08             	pushl  0x8(%ebp)
  8013ad:	e8 e3 01 00 00       	call   801595 <open>
  8013b2:	89 c3                	mov    %eax,%ebx
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	85 c0                	test   %eax,%eax
  8013b9:	78 1b                	js     8013d6 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013bb:	83 ec 08             	sub    $0x8,%esp
  8013be:	ff 75 0c             	pushl  0xc(%ebp)
  8013c1:	50                   	push   %eax
  8013c2:	e8 5b ff ff ff       	call   801322 <fstat>
  8013c7:	89 c6                	mov    %eax,%esi
	close(fd);
  8013c9:	89 1c 24             	mov    %ebx,(%esp)
  8013cc:	e8 fd fb ff ff       	call   800fce <close>
	return r;
  8013d1:	83 c4 10             	add    $0x10,%esp
  8013d4:	89 f0                	mov    %esi,%eax
}
  8013d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d9:	5b                   	pop    %ebx
  8013da:	5e                   	pop    %esi
  8013db:	5d                   	pop    %ebp
  8013dc:	c3                   	ret    

008013dd <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013dd:	55                   	push   %ebp
  8013de:	89 e5                	mov    %esp,%ebp
  8013e0:	56                   	push   %esi
  8013e1:	53                   	push   %ebx
  8013e2:	89 c6                	mov    %eax,%esi
  8013e4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013e6:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013ed:	75 12                	jne    801401 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013ef:	83 ec 0c             	sub    $0xc,%esp
  8013f2:	6a 01                	push   $0x1
  8013f4:	e8 d5 0d 00 00       	call   8021ce <ipc_find_env>
  8013f9:	a3 00 40 80 00       	mov    %eax,0x804000
  8013fe:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801401:	6a 07                	push   $0x7
  801403:	68 00 50 80 00       	push   $0x805000
  801408:	56                   	push   %esi
  801409:	ff 35 00 40 80 00    	pushl  0x804000
  80140f:	e8 58 0d 00 00       	call   80216c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801414:	83 c4 0c             	add    $0xc,%esp
  801417:	6a 00                	push   $0x0
  801419:	53                   	push   %ebx
  80141a:	6a 00                	push   $0x0
  80141c:	e8 d9 0c 00 00       	call   8020fa <ipc_recv>
}
  801421:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801424:	5b                   	pop    %ebx
  801425:	5e                   	pop    %esi
  801426:	5d                   	pop    %ebp
  801427:	c3                   	ret    

00801428 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801428:	55                   	push   %ebp
  801429:	89 e5                	mov    %esp,%ebp
  80142b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80142e:	8b 45 08             	mov    0x8(%ebp),%eax
  801431:	8b 40 0c             	mov    0xc(%eax),%eax
  801434:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801439:	8b 45 0c             	mov    0xc(%ebp),%eax
  80143c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801441:	ba 00 00 00 00       	mov    $0x0,%edx
  801446:	b8 02 00 00 00       	mov    $0x2,%eax
  80144b:	e8 8d ff ff ff       	call   8013dd <fsipc>
}
  801450:	c9                   	leave  
  801451:	c3                   	ret    

00801452 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801452:	55                   	push   %ebp
  801453:	89 e5                	mov    %esp,%ebp
  801455:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801458:	8b 45 08             	mov    0x8(%ebp),%eax
  80145b:	8b 40 0c             	mov    0xc(%eax),%eax
  80145e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801463:	ba 00 00 00 00       	mov    $0x0,%edx
  801468:	b8 06 00 00 00       	mov    $0x6,%eax
  80146d:	e8 6b ff ff ff       	call   8013dd <fsipc>
}
  801472:	c9                   	leave  
  801473:	c3                   	ret    

00801474 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
  801477:	53                   	push   %ebx
  801478:	83 ec 04             	sub    $0x4,%esp
  80147b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80147e:	8b 45 08             	mov    0x8(%ebp),%eax
  801481:	8b 40 0c             	mov    0xc(%eax),%eax
  801484:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801489:	ba 00 00 00 00       	mov    $0x0,%edx
  80148e:	b8 05 00 00 00       	mov    $0x5,%eax
  801493:	e8 45 ff ff ff       	call   8013dd <fsipc>
  801498:	85 c0                	test   %eax,%eax
  80149a:	78 2c                	js     8014c8 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80149c:	83 ec 08             	sub    $0x8,%esp
  80149f:	68 00 50 80 00       	push   $0x805000
  8014a4:	53                   	push   %ebx
  8014a5:	e8 90 f3 ff ff       	call   80083a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014aa:	a1 80 50 80 00       	mov    0x805080,%eax
  8014af:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014b5:	a1 84 50 80 00       	mov    0x805084,%eax
  8014ba:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014c0:	83 c4 10             	add    $0x10,%esp
  8014c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014cb:	c9                   	leave  
  8014cc:	c3                   	ret    

008014cd <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014cd:	55                   	push   %ebp
  8014ce:	89 e5                	mov    %esp,%ebp
  8014d0:	83 ec 0c             	sub    $0xc,%esp
  8014d3:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8014d9:	8b 52 0c             	mov    0xc(%edx),%edx
  8014dc:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8014e2:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014e7:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014ec:	0f 47 c2             	cmova  %edx,%eax
  8014ef:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8014f4:	50                   	push   %eax
  8014f5:	ff 75 0c             	pushl  0xc(%ebp)
  8014f8:	68 08 50 80 00       	push   $0x805008
  8014fd:	e8 ca f4 ff ff       	call   8009cc <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801502:	ba 00 00 00 00       	mov    $0x0,%edx
  801507:	b8 04 00 00 00       	mov    $0x4,%eax
  80150c:	e8 cc fe ff ff       	call   8013dd <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801511:	c9                   	leave  
  801512:	c3                   	ret    

00801513 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801513:	55                   	push   %ebp
  801514:	89 e5                	mov    %esp,%ebp
  801516:	56                   	push   %esi
  801517:	53                   	push   %ebx
  801518:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80151b:	8b 45 08             	mov    0x8(%ebp),%eax
  80151e:	8b 40 0c             	mov    0xc(%eax),%eax
  801521:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801526:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80152c:	ba 00 00 00 00       	mov    $0x0,%edx
  801531:	b8 03 00 00 00       	mov    $0x3,%eax
  801536:	e8 a2 fe ff ff       	call   8013dd <fsipc>
  80153b:	89 c3                	mov    %eax,%ebx
  80153d:	85 c0                	test   %eax,%eax
  80153f:	78 4b                	js     80158c <devfile_read+0x79>
		return r;
	assert(r <= n);
  801541:	39 c6                	cmp    %eax,%esi
  801543:	73 16                	jae    80155b <devfile_read+0x48>
  801545:	68 98 29 80 00       	push   $0x802998
  80154a:	68 9f 29 80 00       	push   $0x80299f
  80154f:	6a 7c                	push   $0x7c
  801551:	68 b4 29 80 00       	push   $0x8029b4
  801556:	e8 81 ec ff ff       	call   8001dc <_panic>
	assert(r <= PGSIZE);
  80155b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801560:	7e 16                	jle    801578 <devfile_read+0x65>
  801562:	68 bf 29 80 00       	push   $0x8029bf
  801567:	68 9f 29 80 00       	push   $0x80299f
  80156c:	6a 7d                	push   $0x7d
  80156e:	68 b4 29 80 00       	push   $0x8029b4
  801573:	e8 64 ec ff ff       	call   8001dc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801578:	83 ec 04             	sub    $0x4,%esp
  80157b:	50                   	push   %eax
  80157c:	68 00 50 80 00       	push   $0x805000
  801581:	ff 75 0c             	pushl  0xc(%ebp)
  801584:	e8 43 f4 ff ff       	call   8009cc <memmove>
	return r;
  801589:	83 c4 10             	add    $0x10,%esp
}
  80158c:	89 d8                	mov    %ebx,%eax
  80158e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801591:	5b                   	pop    %ebx
  801592:	5e                   	pop    %esi
  801593:	5d                   	pop    %ebp
  801594:	c3                   	ret    

00801595 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801595:	55                   	push   %ebp
  801596:	89 e5                	mov    %esp,%ebp
  801598:	53                   	push   %ebx
  801599:	83 ec 20             	sub    $0x20,%esp
  80159c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80159f:	53                   	push   %ebx
  8015a0:	e8 5c f2 ff ff       	call   800801 <strlen>
  8015a5:	83 c4 10             	add    $0x10,%esp
  8015a8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015ad:	7f 67                	jg     801616 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015af:	83 ec 0c             	sub    $0xc,%esp
  8015b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b5:	50                   	push   %eax
  8015b6:	e8 9a f8 ff ff       	call   800e55 <fd_alloc>
  8015bb:	83 c4 10             	add    $0x10,%esp
		return r;
  8015be:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015c0:	85 c0                	test   %eax,%eax
  8015c2:	78 57                	js     80161b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015c4:	83 ec 08             	sub    $0x8,%esp
  8015c7:	53                   	push   %ebx
  8015c8:	68 00 50 80 00       	push   $0x805000
  8015cd:	e8 68 f2 ff ff       	call   80083a <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015d5:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015da:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8015e2:	e8 f6 fd ff ff       	call   8013dd <fsipc>
  8015e7:	89 c3                	mov    %eax,%ebx
  8015e9:	83 c4 10             	add    $0x10,%esp
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	79 14                	jns    801604 <open+0x6f>
		fd_close(fd, 0);
  8015f0:	83 ec 08             	sub    $0x8,%esp
  8015f3:	6a 00                	push   $0x0
  8015f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8015f8:	e8 50 f9 ff ff       	call   800f4d <fd_close>
		return r;
  8015fd:	83 c4 10             	add    $0x10,%esp
  801600:	89 da                	mov    %ebx,%edx
  801602:	eb 17                	jmp    80161b <open+0x86>
	}

	return fd2num(fd);
  801604:	83 ec 0c             	sub    $0xc,%esp
  801607:	ff 75 f4             	pushl  -0xc(%ebp)
  80160a:	e8 1f f8 ff ff       	call   800e2e <fd2num>
  80160f:	89 c2                	mov    %eax,%edx
  801611:	83 c4 10             	add    $0x10,%esp
  801614:	eb 05                	jmp    80161b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801616:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80161b:	89 d0                	mov    %edx,%eax
  80161d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801620:	c9                   	leave  
  801621:	c3                   	ret    

00801622 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801622:	55                   	push   %ebp
  801623:	89 e5                	mov    %esp,%ebp
  801625:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801628:	ba 00 00 00 00       	mov    $0x0,%edx
  80162d:	b8 08 00 00 00       	mov    $0x8,%eax
  801632:	e8 a6 fd ff ff       	call   8013dd <fsipc>
}
  801637:	c9                   	leave  
  801638:	c3                   	ret    

00801639 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801639:	55                   	push   %ebp
  80163a:	89 e5                	mov    %esp,%ebp
  80163c:	57                   	push   %edi
  80163d:	56                   	push   %esi
  80163e:	53                   	push   %ebx
  80163f:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801645:	6a 00                	push   $0x0
  801647:	ff 75 08             	pushl  0x8(%ebp)
  80164a:	e8 46 ff ff ff       	call   801595 <open>
  80164f:	89 c7                	mov    %eax,%edi
  801651:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801657:	83 c4 10             	add    $0x10,%esp
  80165a:	85 c0                	test   %eax,%eax
  80165c:	0f 88 89 04 00 00    	js     801aeb <spawn+0x4b2>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801662:	83 ec 04             	sub    $0x4,%esp
  801665:	68 00 02 00 00       	push   $0x200
  80166a:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801670:	50                   	push   %eax
  801671:	57                   	push   %edi
  801672:	e8 24 fb ff ff       	call   80119b <readn>
  801677:	83 c4 10             	add    $0x10,%esp
  80167a:	3d 00 02 00 00       	cmp    $0x200,%eax
  80167f:	75 0c                	jne    80168d <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801681:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801688:	45 4c 46 
  80168b:	74 33                	je     8016c0 <spawn+0x87>
		close(fd);
  80168d:	83 ec 0c             	sub    $0xc,%esp
  801690:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801696:	e8 33 f9 ff ff       	call   800fce <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80169b:	83 c4 0c             	add    $0xc,%esp
  80169e:	68 7f 45 4c 46       	push   $0x464c457f
  8016a3:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8016a9:	68 cb 29 80 00       	push   $0x8029cb
  8016ae:	e8 02 ec ff ff       	call   8002b5 <cprintf>
		return -E_NOT_EXEC;
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8016bb:	e9 de 04 00 00       	jmp    801b9e <spawn+0x565>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8016c0:	b8 07 00 00 00       	mov    $0x7,%eax
  8016c5:	cd 30                	int    $0x30
  8016c7:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8016cd:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8016d3:	85 c0                	test   %eax,%eax
  8016d5:	0f 88 1b 04 00 00    	js     801af6 <spawn+0x4bd>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8016db:	89 c6                	mov    %eax,%esi
  8016dd:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8016e3:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8016e6:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8016ec:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8016f2:	b9 11 00 00 00       	mov    $0x11,%ecx
  8016f7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8016f9:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8016ff:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801705:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80170a:	be 00 00 00 00       	mov    $0x0,%esi
  80170f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801712:	eb 13                	jmp    801727 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801714:	83 ec 0c             	sub    $0xc,%esp
  801717:	50                   	push   %eax
  801718:	e8 e4 f0 ff ff       	call   800801 <strlen>
  80171d:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801721:	83 c3 01             	add    $0x1,%ebx
  801724:	83 c4 10             	add    $0x10,%esp
  801727:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80172e:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801731:	85 c0                	test   %eax,%eax
  801733:	75 df                	jne    801714 <spawn+0xdb>
  801735:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  80173b:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801741:	bf 00 10 40 00       	mov    $0x401000,%edi
  801746:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801748:	89 fa                	mov    %edi,%edx
  80174a:	83 e2 fc             	and    $0xfffffffc,%edx
  80174d:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801754:	29 c2                	sub    %eax,%edx
  801756:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80175c:	8d 42 f8             	lea    -0x8(%edx),%eax
  80175f:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801764:	0f 86 a2 03 00 00    	jbe    801b0c <spawn+0x4d3>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80176a:	83 ec 04             	sub    $0x4,%esp
  80176d:	6a 07                	push   $0x7
  80176f:	68 00 00 40 00       	push   $0x400000
  801774:	6a 00                	push   $0x0
  801776:	e8 c2 f4 ff ff       	call   800c3d <sys_page_alloc>
  80177b:	83 c4 10             	add    $0x10,%esp
  80177e:	85 c0                	test   %eax,%eax
  801780:	0f 88 90 03 00 00    	js     801b16 <spawn+0x4dd>
  801786:	be 00 00 00 00       	mov    $0x0,%esi
  80178b:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801791:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801794:	eb 30                	jmp    8017c6 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801796:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  80179c:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8017a2:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  8017a5:	83 ec 08             	sub    $0x8,%esp
  8017a8:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8017ab:	57                   	push   %edi
  8017ac:	e8 89 f0 ff ff       	call   80083a <strcpy>
		string_store += strlen(argv[i]) + 1;
  8017b1:	83 c4 04             	add    $0x4,%esp
  8017b4:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8017b7:	e8 45 f0 ff ff       	call   800801 <strlen>
  8017bc:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8017c0:	83 c6 01             	add    $0x1,%esi
  8017c3:	83 c4 10             	add    $0x10,%esp
  8017c6:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8017cc:	7f c8                	jg     801796 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8017ce:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8017d4:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  8017da:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8017e1:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8017e7:	74 19                	je     801802 <spawn+0x1c9>
  8017e9:	68 58 2a 80 00       	push   $0x802a58
  8017ee:	68 9f 29 80 00       	push   $0x80299f
  8017f3:	68 f2 00 00 00       	push   $0xf2
  8017f8:	68 e5 29 80 00       	push   $0x8029e5
  8017fd:	e8 da e9 ff ff       	call   8001dc <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801802:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801808:	89 f8                	mov    %edi,%eax
  80180a:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80180f:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801812:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801818:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  80181b:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801821:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801827:	83 ec 0c             	sub    $0xc,%esp
  80182a:	6a 07                	push   $0x7
  80182c:	68 00 d0 bf ee       	push   $0xeebfd000
  801831:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801837:	68 00 00 40 00       	push   $0x400000
  80183c:	6a 00                	push   $0x0
  80183e:	e8 3d f4 ff ff       	call   800c80 <sys_page_map>
  801843:	89 c3                	mov    %eax,%ebx
  801845:	83 c4 20             	add    $0x20,%esp
  801848:	85 c0                	test   %eax,%eax
  80184a:	0f 88 3c 03 00 00    	js     801b8c <spawn+0x553>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801850:	83 ec 08             	sub    $0x8,%esp
  801853:	68 00 00 40 00       	push   $0x400000
  801858:	6a 00                	push   $0x0
  80185a:	e8 63 f4 ff ff       	call   800cc2 <sys_page_unmap>
  80185f:	89 c3                	mov    %eax,%ebx
  801861:	83 c4 10             	add    $0x10,%esp
  801864:	85 c0                	test   %eax,%eax
  801866:	0f 88 20 03 00 00    	js     801b8c <spawn+0x553>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80186c:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801872:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801879:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80187f:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801886:	00 00 00 
  801889:	e9 88 01 00 00       	jmp    801a16 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  80188e:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801894:	83 38 01             	cmpl   $0x1,(%eax)
  801897:	0f 85 6b 01 00 00    	jne    801a08 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80189d:	89 c2                	mov    %eax,%edx
  80189f:	8b 40 18             	mov    0x18(%eax),%eax
  8018a2:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8018a8:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8018ab:	83 f8 01             	cmp    $0x1,%eax
  8018ae:	19 c0                	sbb    %eax,%eax
  8018b0:	83 e0 fe             	and    $0xfffffffe,%eax
  8018b3:	83 c0 07             	add    $0x7,%eax
  8018b6:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8018bc:	89 d0                	mov    %edx,%eax
  8018be:	8b 7a 04             	mov    0x4(%edx),%edi
  8018c1:	89 f9                	mov    %edi,%ecx
  8018c3:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  8018c9:	8b 7a 10             	mov    0x10(%edx),%edi
  8018cc:	8b 52 14             	mov    0x14(%edx),%edx
  8018cf:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  8018d5:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8018d8:	89 f0                	mov    %esi,%eax
  8018da:	25 ff 0f 00 00       	and    $0xfff,%eax
  8018df:	74 14                	je     8018f5 <spawn+0x2bc>
		va -= i;
  8018e1:	29 c6                	sub    %eax,%esi
		memsz += i;
  8018e3:	01 c2                	add    %eax,%edx
  8018e5:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  8018eb:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8018ed:	29 c1                	sub    %eax,%ecx
  8018ef:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8018f5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018fa:	e9 f7 00 00 00       	jmp    8019f6 <spawn+0x3bd>
		if (i >= filesz) {
  8018ff:	39 fb                	cmp    %edi,%ebx
  801901:	72 27                	jb     80192a <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801903:	83 ec 04             	sub    $0x4,%esp
  801906:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80190c:	56                   	push   %esi
  80190d:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801913:	e8 25 f3 ff ff       	call   800c3d <sys_page_alloc>
  801918:	83 c4 10             	add    $0x10,%esp
  80191b:	85 c0                	test   %eax,%eax
  80191d:	0f 89 c7 00 00 00    	jns    8019ea <spawn+0x3b1>
  801923:	89 c3                	mov    %eax,%ebx
  801925:	e9 fd 01 00 00       	jmp    801b27 <spawn+0x4ee>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80192a:	83 ec 04             	sub    $0x4,%esp
  80192d:	6a 07                	push   $0x7
  80192f:	68 00 00 40 00       	push   $0x400000
  801934:	6a 00                	push   $0x0
  801936:	e8 02 f3 ff ff       	call   800c3d <sys_page_alloc>
  80193b:	83 c4 10             	add    $0x10,%esp
  80193e:	85 c0                	test   %eax,%eax
  801940:	0f 88 d7 01 00 00    	js     801b1d <spawn+0x4e4>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801946:	83 ec 08             	sub    $0x8,%esp
  801949:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80194f:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801955:	50                   	push   %eax
  801956:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80195c:	e8 0f f9 ff ff       	call   801270 <seek>
  801961:	83 c4 10             	add    $0x10,%esp
  801964:	85 c0                	test   %eax,%eax
  801966:	0f 88 b5 01 00 00    	js     801b21 <spawn+0x4e8>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80196c:	83 ec 04             	sub    $0x4,%esp
  80196f:	89 f8                	mov    %edi,%eax
  801971:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801977:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80197c:	ba 00 10 00 00       	mov    $0x1000,%edx
  801981:	0f 47 c2             	cmova  %edx,%eax
  801984:	50                   	push   %eax
  801985:	68 00 00 40 00       	push   $0x400000
  80198a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801990:	e8 06 f8 ff ff       	call   80119b <readn>
  801995:	83 c4 10             	add    $0x10,%esp
  801998:	85 c0                	test   %eax,%eax
  80199a:	0f 88 85 01 00 00    	js     801b25 <spawn+0x4ec>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8019a0:	83 ec 0c             	sub    $0xc,%esp
  8019a3:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8019a9:	56                   	push   %esi
  8019aa:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8019b0:	68 00 00 40 00       	push   $0x400000
  8019b5:	6a 00                	push   $0x0
  8019b7:	e8 c4 f2 ff ff       	call   800c80 <sys_page_map>
  8019bc:	83 c4 20             	add    $0x20,%esp
  8019bf:	85 c0                	test   %eax,%eax
  8019c1:	79 15                	jns    8019d8 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  8019c3:	50                   	push   %eax
  8019c4:	68 f1 29 80 00       	push   $0x8029f1
  8019c9:	68 25 01 00 00       	push   $0x125
  8019ce:	68 e5 29 80 00       	push   $0x8029e5
  8019d3:	e8 04 e8 ff ff       	call   8001dc <_panic>
			sys_page_unmap(0, UTEMP);
  8019d8:	83 ec 08             	sub    $0x8,%esp
  8019db:	68 00 00 40 00       	push   $0x400000
  8019e0:	6a 00                	push   $0x0
  8019e2:	e8 db f2 ff ff       	call   800cc2 <sys_page_unmap>
  8019e7:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8019ea:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019f0:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8019f6:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  8019fc:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801a02:	0f 82 f7 fe ff ff    	jb     8018ff <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801a08:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801a0f:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801a16:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801a1d:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801a23:	0f 8c 65 fe ff ff    	jl     80188e <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801a29:	83 ec 0c             	sub    $0xc,%esp
  801a2c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a32:	e8 97 f5 ff ff       	call   800fce <close>
  801a37:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801a3a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a3f:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801a45:	89 d8                	mov    %ebx,%eax
  801a47:	c1 e8 16             	shr    $0x16,%eax
  801a4a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a51:	a8 01                	test   $0x1,%al
  801a53:	74 42                	je     801a97 <spawn+0x45e>
  801a55:	89 d8                	mov    %ebx,%eax
  801a57:	c1 e8 0c             	shr    $0xc,%eax
  801a5a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a61:	f6 c2 01             	test   $0x1,%dl
  801a64:	74 31                	je     801a97 <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  801a66:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801a6d:	f6 c6 04             	test   $0x4,%dh
  801a70:	74 25                	je     801a97 <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  801a72:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a79:	83 ec 0c             	sub    $0xc,%esp
  801a7c:	25 07 0e 00 00       	and    $0xe07,%eax
  801a81:	50                   	push   %eax
  801a82:	53                   	push   %ebx
  801a83:	56                   	push   %esi
  801a84:	53                   	push   %ebx
  801a85:	6a 00                	push   $0x0
  801a87:	e8 f4 f1 ff ff       	call   800c80 <sys_page_map>
			if (r < 0) {
  801a8c:	83 c4 20             	add    $0x20,%esp
  801a8f:	85 c0                	test   %eax,%eax
  801a91:	0f 88 b1 00 00 00    	js     801b48 <spawn+0x50f>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801a97:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a9d:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801aa3:	75 a0                	jne    801a45 <spawn+0x40c>
  801aa5:	e9 b3 00 00 00       	jmp    801b5d <spawn+0x524>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801aaa:	50                   	push   %eax
  801aab:	68 0e 2a 80 00       	push   $0x802a0e
  801ab0:	68 86 00 00 00       	push   $0x86
  801ab5:	68 e5 29 80 00       	push   $0x8029e5
  801aba:	e8 1d e7 ff ff       	call   8001dc <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801abf:	83 ec 08             	sub    $0x8,%esp
  801ac2:	6a 02                	push   $0x2
  801ac4:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801aca:	e8 35 f2 ff ff       	call   800d04 <sys_env_set_status>
  801acf:	83 c4 10             	add    $0x10,%esp
  801ad2:	85 c0                	test   %eax,%eax
  801ad4:	79 2b                	jns    801b01 <spawn+0x4c8>
		panic("sys_env_set_status: %e", r);
  801ad6:	50                   	push   %eax
  801ad7:	68 28 2a 80 00       	push   $0x802a28
  801adc:	68 89 00 00 00       	push   $0x89
  801ae1:	68 e5 29 80 00       	push   $0x8029e5
  801ae6:	e8 f1 e6 ff ff       	call   8001dc <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801aeb:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801af1:	e9 a8 00 00 00       	jmp    801b9e <spawn+0x565>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801af6:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801afc:	e9 9d 00 00 00       	jmp    801b9e <spawn+0x565>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801b01:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801b07:	e9 92 00 00 00       	jmp    801b9e <spawn+0x565>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801b0c:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801b11:	e9 88 00 00 00       	jmp    801b9e <spawn+0x565>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801b16:	89 c3                	mov    %eax,%ebx
  801b18:	e9 81 00 00 00       	jmp    801b9e <spawn+0x565>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b1d:	89 c3                	mov    %eax,%ebx
  801b1f:	eb 06                	jmp    801b27 <spawn+0x4ee>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b21:	89 c3                	mov    %eax,%ebx
  801b23:	eb 02                	jmp    801b27 <spawn+0x4ee>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801b25:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801b27:	83 ec 0c             	sub    $0xc,%esp
  801b2a:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b30:	e8 89 f0 ff ff       	call   800bbe <sys_env_destroy>
	close(fd);
  801b35:	83 c4 04             	add    $0x4,%esp
  801b38:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801b3e:	e8 8b f4 ff ff       	call   800fce <close>
	return r;
  801b43:	83 c4 10             	add    $0x10,%esp
  801b46:	eb 56                	jmp    801b9e <spawn+0x565>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801b48:	50                   	push   %eax
  801b49:	68 3f 2a 80 00       	push   $0x802a3f
  801b4e:	68 82 00 00 00       	push   $0x82
  801b53:	68 e5 29 80 00       	push   $0x8029e5
  801b58:	e8 7f e6 ff ff       	call   8001dc <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801b5d:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801b64:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801b67:	83 ec 08             	sub    $0x8,%esp
  801b6a:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801b70:	50                   	push   %eax
  801b71:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b77:	e8 ca f1 ff ff       	call   800d46 <sys_env_set_trapframe>
  801b7c:	83 c4 10             	add    $0x10,%esp
  801b7f:	85 c0                	test   %eax,%eax
  801b81:	0f 89 38 ff ff ff    	jns    801abf <spawn+0x486>
  801b87:	e9 1e ff ff ff       	jmp    801aaa <spawn+0x471>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801b8c:	83 ec 08             	sub    $0x8,%esp
  801b8f:	68 00 00 40 00       	push   $0x400000
  801b94:	6a 00                	push   $0x0
  801b96:	e8 27 f1 ff ff       	call   800cc2 <sys_page_unmap>
  801b9b:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801b9e:	89 d8                	mov    %ebx,%eax
  801ba0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ba3:	5b                   	pop    %ebx
  801ba4:	5e                   	pop    %esi
  801ba5:	5f                   	pop    %edi
  801ba6:	5d                   	pop    %ebp
  801ba7:	c3                   	ret    

00801ba8 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801ba8:	55                   	push   %ebp
  801ba9:	89 e5                	mov    %esp,%ebp
  801bab:	56                   	push   %esi
  801bac:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801bad:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801bb0:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801bb5:	eb 03                	jmp    801bba <spawnl+0x12>
		argc++;
  801bb7:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801bba:	83 c2 04             	add    $0x4,%edx
  801bbd:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801bc1:	75 f4                	jne    801bb7 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801bc3:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801bca:	83 e2 f0             	and    $0xfffffff0,%edx
  801bcd:	29 d4                	sub    %edx,%esp
  801bcf:	8d 54 24 03          	lea    0x3(%esp),%edx
  801bd3:	c1 ea 02             	shr    $0x2,%edx
  801bd6:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801bdd:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801bdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801be2:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801be9:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801bf0:	00 
  801bf1:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801bf3:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf8:	eb 0a                	jmp    801c04 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801bfa:	83 c0 01             	add    $0x1,%eax
  801bfd:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801c01:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801c04:	39 d0                	cmp    %edx,%eax
  801c06:	75 f2                	jne    801bfa <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801c08:	83 ec 08             	sub    $0x8,%esp
  801c0b:	56                   	push   %esi
  801c0c:	ff 75 08             	pushl  0x8(%ebp)
  801c0f:	e8 25 fa ff ff       	call   801639 <spawn>
}
  801c14:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c17:	5b                   	pop    %ebx
  801c18:	5e                   	pop    %esi
  801c19:	5d                   	pop    %ebp
  801c1a:	c3                   	ret    

00801c1b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c1b:	55                   	push   %ebp
  801c1c:	89 e5                	mov    %esp,%ebp
  801c1e:	56                   	push   %esi
  801c1f:	53                   	push   %ebx
  801c20:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c23:	83 ec 0c             	sub    $0xc,%esp
  801c26:	ff 75 08             	pushl  0x8(%ebp)
  801c29:	e8 10 f2 ff ff       	call   800e3e <fd2data>
  801c2e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c30:	83 c4 08             	add    $0x8,%esp
  801c33:	68 80 2a 80 00       	push   $0x802a80
  801c38:	53                   	push   %ebx
  801c39:	e8 fc eb ff ff       	call   80083a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c3e:	8b 46 04             	mov    0x4(%esi),%eax
  801c41:	2b 06                	sub    (%esi),%eax
  801c43:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c49:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c50:	00 00 00 
	stat->st_dev = &devpipe;
  801c53:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c5a:	30 80 00 
	return 0;
}
  801c5d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c62:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c65:	5b                   	pop    %ebx
  801c66:	5e                   	pop    %esi
  801c67:	5d                   	pop    %ebp
  801c68:	c3                   	ret    

00801c69 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c69:	55                   	push   %ebp
  801c6a:	89 e5                	mov    %esp,%ebp
  801c6c:	53                   	push   %ebx
  801c6d:	83 ec 0c             	sub    $0xc,%esp
  801c70:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c73:	53                   	push   %ebx
  801c74:	6a 00                	push   $0x0
  801c76:	e8 47 f0 ff ff       	call   800cc2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c7b:	89 1c 24             	mov    %ebx,(%esp)
  801c7e:	e8 bb f1 ff ff       	call   800e3e <fd2data>
  801c83:	83 c4 08             	add    $0x8,%esp
  801c86:	50                   	push   %eax
  801c87:	6a 00                	push   $0x0
  801c89:	e8 34 f0 ff ff       	call   800cc2 <sys_page_unmap>
}
  801c8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c91:	c9                   	leave  
  801c92:	c3                   	ret    

00801c93 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c93:	55                   	push   %ebp
  801c94:	89 e5                	mov    %esp,%ebp
  801c96:	57                   	push   %edi
  801c97:	56                   	push   %esi
  801c98:	53                   	push   %ebx
  801c99:	83 ec 1c             	sub    $0x1c,%esp
  801c9c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c9f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ca1:	a1 04 40 80 00       	mov    0x804004,%eax
  801ca6:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ca9:	83 ec 0c             	sub    $0xc,%esp
  801cac:	ff 75 e0             	pushl  -0x20(%ebp)
  801caf:	e8 53 05 00 00       	call   802207 <pageref>
  801cb4:	89 c3                	mov    %eax,%ebx
  801cb6:	89 3c 24             	mov    %edi,(%esp)
  801cb9:	e8 49 05 00 00       	call   802207 <pageref>
  801cbe:	83 c4 10             	add    $0x10,%esp
  801cc1:	39 c3                	cmp    %eax,%ebx
  801cc3:	0f 94 c1             	sete   %cl
  801cc6:	0f b6 c9             	movzbl %cl,%ecx
  801cc9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ccc:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801cd2:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801cd5:	39 ce                	cmp    %ecx,%esi
  801cd7:	74 1b                	je     801cf4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801cd9:	39 c3                	cmp    %eax,%ebx
  801cdb:	75 c4                	jne    801ca1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cdd:	8b 42 58             	mov    0x58(%edx),%eax
  801ce0:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ce3:	50                   	push   %eax
  801ce4:	56                   	push   %esi
  801ce5:	68 87 2a 80 00       	push   $0x802a87
  801cea:	e8 c6 e5 ff ff       	call   8002b5 <cprintf>
  801cef:	83 c4 10             	add    $0x10,%esp
  801cf2:	eb ad                	jmp    801ca1 <_pipeisclosed+0xe>
	}
}
  801cf4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cf7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cfa:	5b                   	pop    %ebx
  801cfb:	5e                   	pop    %esi
  801cfc:	5f                   	pop    %edi
  801cfd:	5d                   	pop    %ebp
  801cfe:	c3                   	ret    

00801cff <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cff:	55                   	push   %ebp
  801d00:	89 e5                	mov    %esp,%ebp
  801d02:	57                   	push   %edi
  801d03:	56                   	push   %esi
  801d04:	53                   	push   %ebx
  801d05:	83 ec 28             	sub    $0x28,%esp
  801d08:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d0b:	56                   	push   %esi
  801d0c:	e8 2d f1 ff ff       	call   800e3e <fd2data>
  801d11:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d13:	83 c4 10             	add    $0x10,%esp
  801d16:	bf 00 00 00 00       	mov    $0x0,%edi
  801d1b:	eb 4b                	jmp    801d68 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d1d:	89 da                	mov    %ebx,%edx
  801d1f:	89 f0                	mov    %esi,%eax
  801d21:	e8 6d ff ff ff       	call   801c93 <_pipeisclosed>
  801d26:	85 c0                	test   %eax,%eax
  801d28:	75 48                	jne    801d72 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d2a:	e8 ef ee ff ff       	call   800c1e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d2f:	8b 43 04             	mov    0x4(%ebx),%eax
  801d32:	8b 0b                	mov    (%ebx),%ecx
  801d34:	8d 51 20             	lea    0x20(%ecx),%edx
  801d37:	39 d0                	cmp    %edx,%eax
  801d39:	73 e2                	jae    801d1d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d3e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d42:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d45:	89 c2                	mov    %eax,%edx
  801d47:	c1 fa 1f             	sar    $0x1f,%edx
  801d4a:	89 d1                	mov    %edx,%ecx
  801d4c:	c1 e9 1b             	shr    $0x1b,%ecx
  801d4f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d52:	83 e2 1f             	and    $0x1f,%edx
  801d55:	29 ca                	sub    %ecx,%edx
  801d57:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d5b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d5f:	83 c0 01             	add    $0x1,%eax
  801d62:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d65:	83 c7 01             	add    $0x1,%edi
  801d68:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d6b:	75 c2                	jne    801d2f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d6d:	8b 45 10             	mov    0x10(%ebp),%eax
  801d70:	eb 05                	jmp    801d77 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d72:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d7a:	5b                   	pop    %ebx
  801d7b:	5e                   	pop    %esi
  801d7c:	5f                   	pop    %edi
  801d7d:	5d                   	pop    %ebp
  801d7e:	c3                   	ret    

00801d7f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d7f:	55                   	push   %ebp
  801d80:	89 e5                	mov    %esp,%ebp
  801d82:	57                   	push   %edi
  801d83:	56                   	push   %esi
  801d84:	53                   	push   %ebx
  801d85:	83 ec 18             	sub    $0x18,%esp
  801d88:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d8b:	57                   	push   %edi
  801d8c:	e8 ad f0 ff ff       	call   800e3e <fd2data>
  801d91:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d93:	83 c4 10             	add    $0x10,%esp
  801d96:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d9b:	eb 3d                	jmp    801dda <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d9d:	85 db                	test   %ebx,%ebx
  801d9f:	74 04                	je     801da5 <devpipe_read+0x26>
				return i;
  801da1:	89 d8                	mov    %ebx,%eax
  801da3:	eb 44                	jmp    801de9 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801da5:	89 f2                	mov    %esi,%edx
  801da7:	89 f8                	mov    %edi,%eax
  801da9:	e8 e5 fe ff ff       	call   801c93 <_pipeisclosed>
  801dae:	85 c0                	test   %eax,%eax
  801db0:	75 32                	jne    801de4 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801db2:	e8 67 ee ff ff       	call   800c1e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801db7:	8b 06                	mov    (%esi),%eax
  801db9:	3b 46 04             	cmp    0x4(%esi),%eax
  801dbc:	74 df                	je     801d9d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801dbe:	99                   	cltd   
  801dbf:	c1 ea 1b             	shr    $0x1b,%edx
  801dc2:	01 d0                	add    %edx,%eax
  801dc4:	83 e0 1f             	and    $0x1f,%eax
  801dc7:	29 d0                	sub    %edx,%eax
  801dc9:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801dce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dd1:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801dd4:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dd7:	83 c3 01             	add    $0x1,%ebx
  801dda:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ddd:	75 d8                	jne    801db7 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ddf:	8b 45 10             	mov    0x10(%ebp),%eax
  801de2:	eb 05                	jmp    801de9 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801de4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801de9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dec:	5b                   	pop    %ebx
  801ded:	5e                   	pop    %esi
  801dee:	5f                   	pop    %edi
  801def:	5d                   	pop    %ebp
  801df0:	c3                   	ret    

00801df1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801df1:	55                   	push   %ebp
  801df2:	89 e5                	mov    %esp,%ebp
  801df4:	56                   	push   %esi
  801df5:	53                   	push   %ebx
  801df6:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801df9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dfc:	50                   	push   %eax
  801dfd:	e8 53 f0 ff ff       	call   800e55 <fd_alloc>
  801e02:	83 c4 10             	add    $0x10,%esp
  801e05:	89 c2                	mov    %eax,%edx
  801e07:	85 c0                	test   %eax,%eax
  801e09:	0f 88 2c 01 00 00    	js     801f3b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e0f:	83 ec 04             	sub    $0x4,%esp
  801e12:	68 07 04 00 00       	push   $0x407
  801e17:	ff 75 f4             	pushl  -0xc(%ebp)
  801e1a:	6a 00                	push   $0x0
  801e1c:	e8 1c ee ff ff       	call   800c3d <sys_page_alloc>
  801e21:	83 c4 10             	add    $0x10,%esp
  801e24:	89 c2                	mov    %eax,%edx
  801e26:	85 c0                	test   %eax,%eax
  801e28:	0f 88 0d 01 00 00    	js     801f3b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e2e:	83 ec 0c             	sub    $0xc,%esp
  801e31:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e34:	50                   	push   %eax
  801e35:	e8 1b f0 ff ff       	call   800e55 <fd_alloc>
  801e3a:	89 c3                	mov    %eax,%ebx
  801e3c:	83 c4 10             	add    $0x10,%esp
  801e3f:	85 c0                	test   %eax,%eax
  801e41:	0f 88 e2 00 00 00    	js     801f29 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e47:	83 ec 04             	sub    $0x4,%esp
  801e4a:	68 07 04 00 00       	push   $0x407
  801e4f:	ff 75 f0             	pushl  -0x10(%ebp)
  801e52:	6a 00                	push   $0x0
  801e54:	e8 e4 ed ff ff       	call   800c3d <sys_page_alloc>
  801e59:	89 c3                	mov    %eax,%ebx
  801e5b:	83 c4 10             	add    $0x10,%esp
  801e5e:	85 c0                	test   %eax,%eax
  801e60:	0f 88 c3 00 00 00    	js     801f29 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e66:	83 ec 0c             	sub    $0xc,%esp
  801e69:	ff 75 f4             	pushl  -0xc(%ebp)
  801e6c:	e8 cd ef ff ff       	call   800e3e <fd2data>
  801e71:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e73:	83 c4 0c             	add    $0xc,%esp
  801e76:	68 07 04 00 00       	push   $0x407
  801e7b:	50                   	push   %eax
  801e7c:	6a 00                	push   $0x0
  801e7e:	e8 ba ed ff ff       	call   800c3d <sys_page_alloc>
  801e83:	89 c3                	mov    %eax,%ebx
  801e85:	83 c4 10             	add    $0x10,%esp
  801e88:	85 c0                	test   %eax,%eax
  801e8a:	0f 88 89 00 00 00    	js     801f19 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e90:	83 ec 0c             	sub    $0xc,%esp
  801e93:	ff 75 f0             	pushl  -0x10(%ebp)
  801e96:	e8 a3 ef ff ff       	call   800e3e <fd2data>
  801e9b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ea2:	50                   	push   %eax
  801ea3:	6a 00                	push   $0x0
  801ea5:	56                   	push   %esi
  801ea6:	6a 00                	push   $0x0
  801ea8:	e8 d3 ed ff ff       	call   800c80 <sys_page_map>
  801ead:	89 c3                	mov    %eax,%ebx
  801eaf:	83 c4 20             	add    $0x20,%esp
  801eb2:	85 c0                	test   %eax,%eax
  801eb4:	78 55                	js     801f0b <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801eb6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ebc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebf:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ec1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ecb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ed1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ed4:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ed6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ed9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ee0:	83 ec 0c             	sub    $0xc,%esp
  801ee3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ee6:	e8 43 ef ff ff       	call   800e2e <fd2num>
  801eeb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801eee:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ef0:	83 c4 04             	add    $0x4,%esp
  801ef3:	ff 75 f0             	pushl  -0x10(%ebp)
  801ef6:	e8 33 ef ff ff       	call   800e2e <fd2num>
  801efb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801efe:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801f01:	83 c4 10             	add    $0x10,%esp
  801f04:	ba 00 00 00 00       	mov    $0x0,%edx
  801f09:	eb 30                	jmp    801f3b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f0b:	83 ec 08             	sub    $0x8,%esp
  801f0e:	56                   	push   %esi
  801f0f:	6a 00                	push   $0x0
  801f11:	e8 ac ed ff ff       	call   800cc2 <sys_page_unmap>
  801f16:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f19:	83 ec 08             	sub    $0x8,%esp
  801f1c:	ff 75 f0             	pushl  -0x10(%ebp)
  801f1f:	6a 00                	push   $0x0
  801f21:	e8 9c ed ff ff       	call   800cc2 <sys_page_unmap>
  801f26:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f29:	83 ec 08             	sub    $0x8,%esp
  801f2c:	ff 75 f4             	pushl  -0xc(%ebp)
  801f2f:	6a 00                	push   $0x0
  801f31:	e8 8c ed ff ff       	call   800cc2 <sys_page_unmap>
  801f36:	83 c4 10             	add    $0x10,%esp
  801f39:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f3b:	89 d0                	mov    %edx,%eax
  801f3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f40:	5b                   	pop    %ebx
  801f41:	5e                   	pop    %esi
  801f42:	5d                   	pop    %ebp
  801f43:	c3                   	ret    

00801f44 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f44:	55                   	push   %ebp
  801f45:	89 e5                	mov    %esp,%ebp
  801f47:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f4d:	50                   	push   %eax
  801f4e:	ff 75 08             	pushl  0x8(%ebp)
  801f51:	e8 4e ef ff ff       	call   800ea4 <fd_lookup>
  801f56:	83 c4 10             	add    $0x10,%esp
  801f59:	85 c0                	test   %eax,%eax
  801f5b:	78 18                	js     801f75 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f5d:	83 ec 0c             	sub    $0xc,%esp
  801f60:	ff 75 f4             	pushl  -0xc(%ebp)
  801f63:	e8 d6 ee ff ff       	call   800e3e <fd2data>
	return _pipeisclosed(fd, p);
  801f68:	89 c2                	mov    %eax,%edx
  801f6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f6d:	e8 21 fd ff ff       	call   801c93 <_pipeisclosed>
  801f72:	83 c4 10             	add    $0x10,%esp
}
  801f75:	c9                   	leave  
  801f76:	c3                   	ret    

00801f77 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f77:	55                   	push   %ebp
  801f78:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f7a:	b8 00 00 00 00       	mov    $0x0,%eax
  801f7f:	5d                   	pop    %ebp
  801f80:	c3                   	ret    

00801f81 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f81:	55                   	push   %ebp
  801f82:	89 e5                	mov    %esp,%ebp
  801f84:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f87:	68 9f 2a 80 00       	push   $0x802a9f
  801f8c:	ff 75 0c             	pushl  0xc(%ebp)
  801f8f:	e8 a6 e8 ff ff       	call   80083a <strcpy>
	return 0;
}
  801f94:	b8 00 00 00 00       	mov    $0x0,%eax
  801f99:	c9                   	leave  
  801f9a:	c3                   	ret    

00801f9b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f9b:	55                   	push   %ebp
  801f9c:	89 e5                	mov    %esp,%ebp
  801f9e:	57                   	push   %edi
  801f9f:	56                   	push   %esi
  801fa0:	53                   	push   %ebx
  801fa1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fa7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fac:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fb2:	eb 2d                	jmp    801fe1 <devcons_write+0x46>
		m = n - tot;
  801fb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fb7:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801fb9:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801fbc:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801fc1:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fc4:	83 ec 04             	sub    $0x4,%esp
  801fc7:	53                   	push   %ebx
  801fc8:	03 45 0c             	add    0xc(%ebp),%eax
  801fcb:	50                   	push   %eax
  801fcc:	57                   	push   %edi
  801fcd:	e8 fa e9 ff ff       	call   8009cc <memmove>
		sys_cputs(buf, m);
  801fd2:	83 c4 08             	add    $0x8,%esp
  801fd5:	53                   	push   %ebx
  801fd6:	57                   	push   %edi
  801fd7:	e8 a5 eb ff ff       	call   800b81 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fdc:	01 de                	add    %ebx,%esi
  801fde:	83 c4 10             	add    $0x10,%esp
  801fe1:	89 f0                	mov    %esi,%eax
  801fe3:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fe6:	72 cc                	jb     801fb4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801fe8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801feb:	5b                   	pop    %ebx
  801fec:	5e                   	pop    %esi
  801fed:	5f                   	pop    %edi
  801fee:	5d                   	pop    %ebp
  801fef:	c3                   	ret    

00801ff0 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
  801ff3:	83 ec 08             	sub    $0x8,%esp
  801ff6:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ffb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fff:	74 2a                	je     80202b <devcons_read+0x3b>
  802001:	eb 05                	jmp    802008 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802003:	e8 16 ec ff ff       	call   800c1e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802008:	e8 92 eb ff ff       	call   800b9f <sys_cgetc>
  80200d:	85 c0                	test   %eax,%eax
  80200f:	74 f2                	je     802003 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802011:	85 c0                	test   %eax,%eax
  802013:	78 16                	js     80202b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802015:	83 f8 04             	cmp    $0x4,%eax
  802018:	74 0c                	je     802026 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80201a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80201d:	88 02                	mov    %al,(%edx)
	return 1;
  80201f:	b8 01 00 00 00       	mov    $0x1,%eax
  802024:	eb 05                	jmp    80202b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802026:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80202b:	c9                   	leave  
  80202c:	c3                   	ret    

0080202d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80202d:	55                   	push   %ebp
  80202e:	89 e5                	mov    %esp,%ebp
  802030:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802033:	8b 45 08             	mov    0x8(%ebp),%eax
  802036:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802039:	6a 01                	push   $0x1
  80203b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80203e:	50                   	push   %eax
  80203f:	e8 3d eb ff ff       	call   800b81 <sys_cputs>
}
  802044:	83 c4 10             	add    $0x10,%esp
  802047:	c9                   	leave  
  802048:	c3                   	ret    

00802049 <getchar>:

int
getchar(void)
{
  802049:	55                   	push   %ebp
  80204a:	89 e5                	mov    %esp,%ebp
  80204c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80204f:	6a 01                	push   $0x1
  802051:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802054:	50                   	push   %eax
  802055:	6a 00                	push   $0x0
  802057:	e8 ae f0 ff ff       	call   80110a <read>
	if (r < 0)
  80205c:	83 c4 10             	add    $0x10,%esp
  80205f:	85 c0                	test   %eax,%eax
  802061:	78 0f                	js     802072 <getchar+0x29>
		return r;
	if (r < 1)
  802063:	85 c0                	test   %eax,%eax
  802065:	7e 06                	jle    80206d <getchar+0x24>
		return -E_EOF;
	return c;
  802067:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80206b:	eb 05                	jmp    802072 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80206d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802072:	c9                   	leave  
  802073:	c3                   	ret    

00802074 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802074:	55                   	push   %ebp
  802075:	89 e5                	mov    %esp,%ebp
  802077:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80207a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80207d:	50                   	push   %eax
  80207e:	ff 75 08             	pushl  0x8(%ebp)
  802081:	e8 1e ee ff ff       	call   800ea4 <fd_lookup>
  802086:	83 c4 10             	add    $0x10,%esp
  802089:	85 c0                	test   %eax,%eax
  80208b:	78 11                	js     80209e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80208d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802090:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802096:	39 10                	cmp    %edx,(%eax)
  802098:	0f 94 c0             	sete   %al
  80209b:	0f b6 c0             	movzbl %al,%eax
}
  80209e:	c9                   	leave  
  80209f:	c3                   	ret    

008020a0 <opencons>:

int
opencons(void)
{
  8020a0:	55                   	push   %ebp
  8020a1:	89 e5                	mov    %esp,%ebp
  8020a3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020a9:	50                   	push   %eax
  8020aa:	e8 a6 ed ff ff       	call   800e55 <fd_alloc>
  8020af:	83 c4 10             	add    $0x10,%esp
		return r;
  8020b2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020b4:	85 c0                	test   %eax,%eax
  8020b6:	78 3e                	js     8020f6 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020b8:	83 ec 04             	sub    $0x4,%esp
  8020bb:	68 07 04 00 00       	push   $0x407
  8020c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8020c3:	6a 00                	push   $0x0
  8020c5:	e8 73 eb ff ff       	call   800c3d <sys_page_alloc>
  8020ca:	83 c4 10             	add    $0x10,%esp
		return r;
  8020cd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020cf:	85 c0                	test   %eax,%eax
  8020d1:	78 23                	js     8020f6 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020d3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020dc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020e8:	83 ec 0c             	sub    $0xc,%esp
  8020eb:	50                   	push   %eax
  8020ec:	e8 3d ed ff ff       	call   800e2e <fd2num>
  8020f1:	89 c2                	mov    %eax,%edx
  8020f3:	83 c4 10             	add    $0x10,%esp
}
  8020f6:	89 d0                	mov    %edx,%eax
  8020f8:	c9                   	leave  
  8020f9:	c3                   	ret    

008020fa <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020fa:	55                   	push   %ebp
  8020fb:	89 e5                	mov    %esp,%ebp
  8020fd:	56                   	push   %esi
  8020fe:	53                   	push   %ebx
  8020ff:	8b 75 08             	mov    0x8(%ebp),%esi
  802102:	8b 45 0c             	mov    0xc(%ebp),%eax
  802105:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802108:	85 c0                	test   %eax,%eax
  80210a:	75 12                	jne    80211e <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80210c:	83 ec 0c             	sub    $0xc,%esp
  80210f:	68 00 00 c0 ee       	push   $0xeec00000
  802114:	e8 d4 ec ff ff       	call   800ded <sys_ipc_recv>
  802119:	83 c4 10             	add    $0x10,%esp
  80211c:	eb 0c                	jmp    80212a <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80211e:	83 ec 0c             	sub    $0xc,%esp
  802121:	50                   	push   %eax
  802122:	e8 c6 ec ff ff       	call   800ded <sys_ipc_recv>
  802127:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80212a:	85 f6                	test   %esi,%esi
  80212c:	0f 95 c1             	setne  %cl
  80212f:	85 db                	test   %ebx,%ebx
  802131:	0f 95 c2             	setne  %dl
  802134:	84 d1                	test   %dl,%cl
  802136:	74 09                	je     802141 <ipc_recv+0x47>
  802138:	89 c2                	mov    %eax,%edx
  80213a:	c1 ea 1f             	shr    $0x1f,%edx
  80213d:	84 d2                	test   %dl,%dl
  80213f:	75 24                	jne    802165 <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802141:	85 f6                	test   %esi,%esi
  802143:	74 0a                	je     80214f <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  802145:	a1 04 40 80 00       	mov    0x804004,%eax
  80214a:	8b 40 74             	mov    0x74(%eax),%eax
  80214d:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80214f:	85 db                	test   %ebx,%ebx
  802151:	74 0a                	je     80215d <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  802153:	a1 04 40 80 00       	mov    0x804004,%eax
  802158:	8b 40 78             	mov    0x78(%eax),%eax
  80215b:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80215d:	a1 04 40 80 00       	mov    0x804004,%eax
  802162:	8b 40 70             	mov    0x70(%eax),%eax
}
  802165:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802168:	5b                   	pop    %ebx
  802169:	5e                   	pop    %esi
  80216a:	5d                   	pop    %ebp
  80216b:	c3                   	ret    

0080216c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80216c:	55                   	push   %ebp
  80216d:	89 e5                	mov    %esp,%ebp
  80216f:	57                   	push   %edi
  802170:	56                   	push   %esi
  802171:	53                   	push   %ebx
  802172:	83 ec 0c             	sub    $0xc,%esp
  802175:	8b 7d 08             	mov    0x8(%ebp),%edi
  802178:	8b 75 0c             	mov    0xc(%ebp),%esi
  80217b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80217e:	85 db                	test   %ebx,%ebx
  802180:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802185:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802188:	ff 75 14             	pushl  0x14(%ebp)
  80218b:	53                   	push   %ebx
  80218c:	56                   	push   %esi
  80218d:	57                   	push   %edi
  80218e:	e8 37 ec ff ff       	call   800dca <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802193:	89 c2                	mov    %eax,%edx
  802195:	c1 ea 1f             	shr    $0x1f,%edx
  802198:	83 c4 10             	add    $0x10,%esp
  80219b:	84 d2                	test   %dl,%dl
  80219d:	74 17                	je     8021b6 <ipc_send+0x4a>
  80219f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021a2:	74 12                	je     8021b6 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8021a4:	50                   	push   %eax
  8021a5:	68 ab 2a 80 00       	push   $0x802aab
  8021aa:	6a 47                	push   $0x47
  8021ac:	68 b9 2a 80 00       	push   $0x802ab9
  8021b1:	e8 26 e0 ff ff       	call   8001dc <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8021b6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021b9:	75 07                	jne    8021c2 <ipc_send+0x56>
			sys_yield();
  8021bb:	e8 5e ea ff ff       	call   800c1e <sys_yield>
  8021c0:	eb c6                	jmp    802188 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8021c2:	85 c0                	test   %eax,%eax
  8021c4:	75 c2                	jne    802188 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8021c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021c9:	5b                   	pop    %ebx
  8021ca:	5e                   	pop    %esi
  8021cb:	5f                   	pop    %edi
  8021cc:	5d                   	pop    %ebp
  8021cd:	c3                   	ret    

008021ce <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021ce:	55                   	push   %ebp
  8021cf:	89 e5                	mov    %esp,%ebp
  8021d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8021d4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021d9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8021dc:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021e2:	8b 52 50             	mov    0x50(%edx),%edx
  8021e5:	39 ca                	cmp    %ecx,%edx
  8021e7:	75 0d                	jne    8021f6 <ipc_find_env+0x28>
			return envs[i].env_id;
  8021e9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8021ec:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021f1:	8b 40 48             	mov    0x48(%eax),%eax
  8021f4:	eb 0f                	jmp    802205 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021f6:	83 c0 01             	add    $0x1,%eax
  8021f9:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021fe:	75 d9                	jne    8021d9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802200:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802205:	5d                   	pop    %ebp
  802206:	c3                   	ret    

00802207 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802207:	55                   	push   %ebp
  802208:	89 e5                	mov    %esp,%ebp
  80220a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80220d:	89 d0                	mov    %edx,%eax
  80220f:	c1 e8 16             	shr    $0x16,%eax
  802212:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802219:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80221e:	f6 c1 01             	test   $0x1,%cl
  802221:	74 1d                	je     802240 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802223:	c1 ea 0c             	shr    $0xc,%edx
  802226:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80222d:	f6 c2 01             	test   $0x1,%dl
  802230:	74 0e                	je     802240 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802232:	c1 ea 0c             	shr    $0xc,%edx
  802235:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80223c:	ef 
  80223d:	0f b7 c0             	movzwl %ax,%eax
}
  802240:	5d                   	pop    %ebp
  802241:	c3                   	ret    
  802242:	66 90                	xchg   %ax,%ax
  802244:	66 90                	xchg   %ax,%ax
  802246:	66 90                	xchg   %ax,%ax
  802248:	66 90                	xchg   %ax,%ax
  80224a:	66 90                	xchg   %ax,%ax
  80224c:	66 90                	xchg   %ax,%ax
  80224e:	66 90                	xchg   %ax,%ax

00802250 <__udivdi3>:
  802250:	55                   	push   %ebp
  802251:	57                   	push   %edi
  802252:	56                   	push   %esi
  802253:	53                   	push   %ebx
  802254:	83 ec 1c             	sub    $0x1c,%esp
  802257:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80225b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80225f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802263:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802267:	85 f6                	test   %esi,%esi
  802269:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80226d:	89 ca                	mov    %ecx,%edx
  80226f:	89 f8                	mov    %edi,%eax
  802271:	75 3d                	jne    8022b0 <__udivdi3+0x60>
  802273:	39 cf                	cmp    %ecx,%edi
  802275:	0f 87 c5 00 00 00    	ja     802340 <__udivdi3+0xf0>
  80227b:	85 ff                	test   %edi,%edi
  80227d:	89 fd                	mov    %edi,%ebp
  80227f:	75 0b                	jne    80228c <__udivdi3+0x3c>
  802281:	b8 01 00 00 00       	mov    $0x1,%eax
  802286:	31 d2                	xor    %edx,%edx
  802288:	f7 f7                	div    %edi
  80228a:	89 c5                	mov    %eax,%ebp
  80228c:	89 c8                	mov    %ecx,%eax
  80228e:	31 d2                	xor    %edx,%edx
  802290:	f7 f5                	div    %ebp
  802292:	89 c1                	mov    %eax,%ecx
  802294:	89 d8                	mov    %ebx,%eax
  802296:	89 cf                	mov    %ecx,%edi
  802298:	f7 f5                	div    %ebp
  80229a:	89 c3                	mov    %eax,%ebx
  80229c:	89 d8                	mov    %ebx,%eax
  80229e:	89 fa                	mov    %edi,%edx
  8022a0:	83 c4 1c             	add    $0x1c,%esp
  8022a3:	5b                   	pop    %ebx
  8022a4:	5e                   	pop    %esi
  8022a5:	5f                   	pop    %edi
  8022a6:	5d                   	pop    %ebp
  8022a7:	c3                   	ret    
  8022a8:	90                   	nop
  8022a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022b0:	39 ce                	cmp    %ecx,%esi
  8022b2:	77 74                	ja     802328 <__udivdi3+0xd8>
  8022b4:	0f bd fe             	bsr    %esi,%edi
  8022b7:	83 f7 1f             	xor    $0x1f,%edi
  8022ba:	0f 84 98 00 00 00    	je     802358 <__udivdi3+0x108>
  8022c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8022c5:	89 f9                	mov    %edi,%ecx
  8022c7:	89 c5                	mov    %eax,%ebp
  8022c9:	29 fb                	sub    %edi,%ebx
  8022cb:	d3 e6                	shl    %cl,%esi
  8022cd:	89 d9                	mov    %ebx,%ecx
  8022cf:	d3 ed                	shr    %cl,%ebp
  8022d1:	89 f9                	mov    %edi,%ecx
  8022d3:	d3 e0                	shl    %cl,%eax
  8022d5:	09 ee                	or     %ebp,%esi
  8022d7:	89 d9                	mov    %ebx,%ecx
  8022d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022dd:	89 d5                	mov    %edx,%ebp
  8022df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022e3:	d3 ed                	shr    %cl,%ebp
  8022e5:	89 f9                	mov    %edi,%ecx
  8022e7:	d3 e2                	shl    %cl,%edx
  8022e9:	89 d9                	mov    %ebx,%ecx
  8022eb:	d3 e8                	shr    %cl,%eax
  8022ed:	09 c2                	or     %eax,%edx
  8022ef:	89 d0                	mov    %edx,%eax
  8022f1:	89 ea                	mov    %ebp,%edx
  8022f3:	f7 f6                	div    %esi
  8022f5:	89 d5                	mov    %edx,%ebp
  8022f7:	89 c3                	mov    %eax,%ebx
  8022f9:	f7 64 24 0c          	mull   0xc(%esp)
  8022fd:	39 d5                	cmp    %edx,%ebp
  8022ff:	72 10                	jb     802311 <__udivdi3+0xc1>
  802301:	8b 74 24 08          	mov    0x8(%esp),%esi
  802305:	89 f9                	mov    %edi,%ecx
  802307:	d3 e6                	shl    %cl,%esi
  802309:	39 c6                	cmp    %eax,%esi
  80230b:	73 07                	jae    802314 <__udivdi3+0xc4>
  80230d:	39 d5                	cmp    %edx,%ebp
  80230f:	75 03                	jne    802314 <__udivdi3+0xc4>
  802311:	83 eb 01             	sub    $0x1,%ebx
  802314:	31 ff                	xor    %edi,%edi
  802316:	89 d8                	mov    %ebx,%eax
  802318:	89 fa                	mov    %edi,%edx
  80231a:	83 c4 1c             	add    $0x1c,%esp
  80231d:	5b                   	pop    %ebx
  80231e:	5e                   	pop    %esi
  80231f:	5f                   	pop    %edi
  802320:	5d                   	pop    %ebp
  802321:	c3                   	ret    
  802322:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802328:	31 ff                	xor    %edi,%edi
  80232a:	31 db                	xor    %ebx,%ebx
  80232c:	89 d8                	mov    %ebx,%eax
  80232e:	89 fa                	mov    %edi,%edx
  802330:	83 c4 1c             	add    $0x1c,%esp
  802333:	5b                   	pop    %ebx
  802334:	5e                   	pop    %esi
  802335:	5f                   	pop    %edi
  802336:	5d                   	pop    %ebp
  802337:	c3                   	ret    
  802338:	90                   	nop
  802339:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802340:	89 d8                	mov    %ebx,%eax
  802342:	f7 f7                	div    %edi
  802344:	31 ff                	xor    %edi,%edi
  802346:	89 c3                	mov    %eax,%ebx
  802348:	89 d8                	mov    %ebx,%eax
  80234a:	89 fa                	mov    %edi,%edx
  80234c:	83 c4 1c             	add    $0x1c,%esp
  80234f:	5b                   	pop    %ebx
  802350:	5e                   	pop    %esi
  802351:	5f                   	pop    %edi
  802352:	5d                   	pop    %ebp
  802353:	c3                   	ret    
  802354:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802358:	39 ce                	cmp    %ecx,%esi
  80235a:	72 0c                	jb     802368 <__udivdi3+0x118>
  80235c:	31 db                	xor    %ebx,%ebx
  80235e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802362:	0f 87 34 ff ff ff    	ja     80229c <__udivdi3+0x4c>
  802368:	bb 01 00 00 00       	mov    $0x1,%ebx
  80236d:	e9 2a ff ff ff       	jmp    80229c <__udivdi3+0x4c>
  802372:	66 90                	xchg   %ax,%ax
  802374:	66 90                	xchg   %ax,%ax
  802376:	66 90                	xchg   %ax,%ax
  802378:	66 90                	xchg   %ax,%ax
  80237a:	66 90                	xchg   %ax,%ax
  80237c:	66 90                	xchg   %ax,%ax
  80237e:	66 90                	xchg   %ax,%ax

00802380 <__umoddi3>:
  802380:	55                   	push   %ebp
  802381:	57                   	push   %edi
  802382:	56                   	push   %esi
  802383:	53                   	push   %ebx
  802384:	83 ec 1c             	sub    $0x1c,%esp
  802387:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80238b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80238f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802393:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802397:	85 d2                	test   %edx,%edx
  802399:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80239d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023a1:	89 f3                	mov    %esi,%ebx
  8023a3:	89 3c 24             	mov    %edi,(%esp)
  8023a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023aa:	75 1c                	jne    8023c8 <__umoddi3+0x48>
  8023ac:	39 f7                	cmp    %esi,%edi
  8023ae:	76 50                	jbe    802400 <__umoddi3+0x80>
  8023b0:	89 c8                	mov    %ecx,%eax
  8023b2:	89 f2                	mov    %esi,%edx
  8023b4:	f7 f7                	div    %edi
  8023b6:	89 d0                	mov    %edx,%eax
  8023b8:	31 d2                	xor    %edx,%edx
  8023ba:	83 c4 1c             	add    $0x1c,%esp
  8023bd:	5b                   	pop    %ebx
  8023be:	5e                   	pop    %esi
  8023bf:	5f                   	pop    %edi
  8023c0:	5d                   	pop    %ebp
  8023c1:	c3                   	ret    
  8023c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023c8:	39 f2                	cmp    %esi,%edx
  8023ca:	89 d0                	mov    %edx,%eax
  8023cc:	77 52                	ja     802420 <__umoddi3+0xa0>
  8023ce:	0f bd ea             	bsr    %edx,%ebp
  8023d1:	83 f5 1f             	xor    $0x1f,%ebp
  8023d4:	75 5a                	jne    802430 <__umoddi3+0xb0>
  8023d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8023da:	0f 82 e0 00 00 00    	jb     8024c0 <__umoddi3+0x140>
  8023e0:	39 0c 24             	cmp    %ecx,(%esp)
  8023e3:	0f 86 d7 00 00 00    	jbe    8024c0 <__umoddi3+0x140>
  8023e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023f1:	83 c4 1c             	add    $0x1c,%esp
  8023f4:	5b                   	pop    %ebx
  8023f5:	5e                   	pop    %esi
  8023f6:	5f                   	pop    %edi
  8023f7:	5d                   	pop    %ebp
  8023f8:	c3                   	ret    
  8023f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802400:	85 ff                	test   %edi,%edi
  802402:	89 fd                	mov    %edi,%ebp
  802404:	75 0b                	jne    802411 <__umoddi3+0x91>
  802406:	b8 01 00 00 00       	mov    $0x1,%eax
  80240b:	31 d2                	xor    %edx,%edx
  80240d:	f7 f7                	div    %edi
  80240f:	89 c5                	mov    %eax,%ebp
  802411:	89 f0                	mov    %esi,%eax
  802413:	31 d2                	xor    %edx,%edx
  802415:	f7 f5                	div    %ebp
  802417:	89 c8                	mov    %ecx,%eax
  802419:	f7 f5                	div    %ebp
  80241b:	89 d0                	mov    %edx,%eax
  80241d:	eb 99                	jmp    8023b8 <__umoddi3+0x38>
  80241f:	90                   	nop
  802420:	89 c8                	mov    %ecx,%eax
  802422:	89 f2                	mov    %esi,%edx
  802424:	83 c4 1c             	add    $0x1c,%esp
  802427:	5b                   	pop    %ebx
  802428:	5e                   	pop    %esi
  802429:	5f                   	pop    %edi
  80242a:	5d                   	pop    %ebp
  80242b:	c3                   	ret    
  80242c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802430:	8b 34 24             	mov    (%esp),%esi
  802433:	bf 20 00 00 00       	mov    $0x20,%edi
  802438:	89 e9                	mov    %ebp,%ecx
  80243a:	29 ef                	sub    %ebp,%edi
  80243c:	d3 e0                	shl    %cl,%eax
  80243e:	89 f9                	mov    %edi,%ecx
  802440:	89 f2                	mov    %esi,%edx
  802442:	d3 ea                	shr    %cl,%edx
  802444:	89 e9                	mov    %ebp,%ecx
  802446:	09 c2                	or     %eax,%edx
  802448:	89 d8                	mov    %ebx,%eax
  80244a:	89 14 24             	mov    %edx,(%esp)
  80244d:	89 f2                	mov    %esi,%edx
  80244f:	d3 e2                	shl    %cl,%edx
  802451:	89 f9                	mov    %edi,%ecx
  802453:	89 54 24 04          	mov    %edx,0x4(%esp)
  802457:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80245b:	d3 e8                	shr    %cl,%eax
  80245d:	89 e9                	mov    %ebp,%ecx
  80245f:	89 c6                	mov    %eax,%esi
  802461:	d3 e3                	shl    %cl,%ebx
  802463:	89 f9                	mov    %edi,%ecx
  802465:	89 d0                	mov    %edx,%eax
  802467:	d3 e8                	shr    %cl,%eax
  802469:	89 e9                	mov    %ebp,%ecx
  80246b:	09 d8                	or     %ebx,%eax
  80246d:	89 d3                	mov    %edx,%ebx
  80246f:	89 f2                	mov    %esi,%edx
  802471:	f7 34 24             	divl   (%esp)
  802474:	89 d6                	mov    %edx,%esi
  802476:	d3 e3                	shl    %cl,%ebx
  802478:	f7 64 24 04          	mull   0x4(%esp)
  80247c:	39 d6                	cmp    %edx,%esi
  80247e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802482:	89 d1                	mov    %edx,%ecx
  802484:	89 c3                	mov    %eax,%ebx
  802486:	72 08                	jb     802490 <__umoddi3+0x110>
  802488:	75 11                	jne    80249b <__umoddi3+0x11b>
  80248a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80248e:	73 0b                	jae    80249b <__umoddi3+0x11b>
  802490:	2b 44 24 04          	sub    0x4(%esp),%eax
  802494:	1b 14 24             	sbb    (%esp),%edx
  802497:	89 d1                	mov    %edx,%ecx
  802499:	89 c3                	mov    %eax,%ebx
  80249b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80249f:	29 da                	sub    %ebx,%edx
  8024a1:	19 ce                	sbb    %ecx,%esi
  8024a3:	89 f9                	mov    %edi,%ecx
  8024a5:	89 f0                	mov    %esi,%eax
  8024a7:	d3 e0                	shl    %cl,%eax
  8024a9:	89 e9                	mov    %ebp,%ecx
  8024ab:	d3 ea                	shr    %cl,%edx
  8024ad:	89 e9                	mov    %ebp,%ecx
  8024af:	d3 ee                	shr    %cl,%esi
  8024b1:	09 d0                	or     %edx,%eax
  8024b3:	89 f2                	mov    %esi,%edx
  8024b5:	83 c4 1c             	add    $0x1c,%esp
  8024b8:	5b                   	pop    %ebx
  8024b9:	5e                   	pop    %esi
  8024ba:	5f                   	pop    %edi
  8024bb:	5d                   	pop    %ebp
  8024bc:	c3                   	ret    
  8024bd:	8d 76 00             	lea    0x0(%esi),%esi
  8024c0:	29 f9                	sub    %edi,%ecx
  8024c2:	19 d6                	sbb    %edx,%esi
  8024c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024cc:	e9 18 ff ff ff       	jmp    8023e9 <__umoddi3+0x69>
