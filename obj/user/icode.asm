
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
  80003e:	c7 05 00 30 80 00 20 	movl   $0x802520,0x803000
  800045:	25 80 00 

	cprintf("icode startup\n");
  800048:	68 26 25 80 00       	push   $0x802526
  80004d:	e8 7b 02 00 00       	call   8002cd <cprintf>

	cprintf("icode: open /motd\n");
  800052:	c7 04 24 35 25 80 00 	movl   $0x802535,(%esp)
  800059:	e8 6f 02 00 00       	call   8002cd <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005e:	83 c4 08             	add    $0x8,%esp
  800061:	6a 00                	push   $0x0
  800063:	68 48 25 80 00       	push   $0x802548
  800068:	e8 60 15 00 00       	call   8015cd <open>
  80006d:	89 c6                	mov    %eax,%esi
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	85 c0                	test   %eax,%eax
  800074:	79 12                	jns    800088 <umain+0x55>
		panic("icode: open /motd: %e", fd);
  800076:	50                   	push   %eax
  800077:	68 4e 25 80 00       	push   $0x80254e
  80007c:	6a 0f                	push   $0xf
  80007e:	68 64 25 80 00       	push   $0x802564
  800083:	e8 6c 01 00 00       	call   8001f4 <_panic>

	cprintf("icode: read /motd\n");
  800088:	83 ec 0c             	sub    $0xc,%esp
  80008b:	68 71 25 80 00       	push   $0x802571
  800090:	e8 38 02 00 00       	call   8002cd <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  80009e:	eb 0d                	jmp    8000ad <umain+0x7a>
		sys_cputs(buf, n);
  8000a0:	83 ec 08             	sub    $0x8,%esp
  8000a3:	50                   	push   %eax
  8000a4:	53                   	push   %ebx
  8000a5:	e8 ef 0a 00 00       	call   800b99 <sys_cputs>
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
  8000b7:	e8 86 10 00 00       	call   801142 <read>
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	7f dd                	jg     8000a0 <umain+0x6d>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	68 84 25 80 00       	push   $0x802584
  8000cb:	e8 fd 01 00 00       	call   8002cd <cprintf>
	close(fd);
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 2e 0f 00 00       	call   801006 <close>

	cprintf("icode: spawn /init\n");
  8000d8:	c7 04 24 98 25 80 00 	movl   $0x802598,(%esp)
  8000df:	e8 e9 01 00 00       	call   8002cd <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000eb:	68 ac 25 80 00       	push   $0x8025ac
  8000f0:	68 b5 25 80 00       	push   $0x8025b5
  8000f5:	68 bf 25 80 00       	push   $0x8025bf
  8000fa:	68 be 25 80 00       	push   $0x8025be
  8000ff:	e8 dc 1a 00 00       	call   801be0 <spawnl>
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	85 c0                	test   %eax,%eax
  800109:	79 12                	jns    80011d <umain+0xea>
		panic("icode: spawn /init: %e", r);
  80010b:	50                   	push   %eax
  80010c:	68 c4 25 80 00       	push   $0x8025c4
  800111:	6a 1a                	push   $0x1a
  800113:	68 64 25 80 00       	push   $0x802564
  800118:	e8 d7 00 00 00       	call   8001f4 <_panic>

	cprintf("icode: exiting\n");
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	68 db 25 80 00       	push   $0x8025db
  800125:	e8 a3 01 00 00       	call   8002cd <cprintf>
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
  800147:	e8 cb 0a 00 00       	call   800c17 <sys_getenvid>
  80014c:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  80014e:	83 ec 08             	sub    $0x8,%esp
  800151:	50                   	push   %eax
  800152:	68 ec 25 80 00       	push   $0x8025ec
  800157:	e8 71 01 00 00       	call   8002cd <cprintf>
  80015c:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  800162:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800167:	83 c4 10             	add    $0x10,%esp
  80016a:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  80016f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  800174:	89 c1                	mov    %eax,%ecx
  800176:	c1 e1 07             	shl    $0x7,%ecx
  800179:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  800180:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  800183:	39 cb                	cmp    %ecx,%ebx
  800185:	0f 44 fa             	cmove  %edx,%edi
  800188:	b9 01 00 00 00       	mov    $0x1,%ecx
  80018d:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  800190:	83 c0 01             	add    $0x1,%eax
  800193:	81 c2 84 00 00 00    	add    $0x84,%edx
  800199:	3d 00 04 00 00       	cmp    $0x400,%eax
  80019e:	75 d4                	jne    800174 <libmain+0x40>
  8001a0:	89 f0                	mov    %esi,%eax
  8001a2:	84 c0                	test   %al,%al
  8001a4:	74 06                	je     8001ac <libmain+0x78>
  8001a6:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001ac:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8001b0:	7e 0a                	jle    8001bc <libmain+0x88>
		binaryname = argv[0];
  8001b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001b5:	8b 00                	mov    (%eax),%eax
  8001b7:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001bc:	83 ec 08             	sub    $0x8,%esp
  8001bf:	ff 75 0c             	pushl  0xc(%ebp)
  8001c2:	ff 75 08             	pushl  0x8(%ebp)
  8001c5:	e8 69 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001ca:	e8 0b 00 00 00       	call   8001da <exit>
}
  8001cf:	83 c4 10             	add    $0x10,%esp
  8001d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d5:	5b                   	pop    %ebx
  8001d6:	5e                   	pop    %esi
  8001d7:	5f                   	pop    %edi
  8001d8:	5d                   	pop    %ebp
  8001d9:	c3                   	ret    

008001da <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001e0:	e8 4c 0e 00 00       	call   801031 <close_all>
	sys_env_destroy(0);
  8001e5:	83 ec 0c             	sub    $0xc,%esp
  8001e8:	6a 00                	push   $0x0
  8001ea:	e8 e7 09 00 00       	call   800bd6 <sys_env_destroy>
}
  8001ef:	83 c4 10             	add    $0x10,%esp
  8001f2:	c9                   	leave  
  8001f3:	c3                   	ret    

008001f4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	56                   	push   %esi
  8001f8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001f9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001fc:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800202:	e8 10 0a 00 00       	call   800c17 <sys_getenvid>
  800207:	83 ec 0c             	sub    $0xc,%esp
  80020a:	ff 75 0c             	pushl  0xc(%ebp)
  80020d:	ff 75 08             	pushl  0x8(%ebp)
  800210:	56                   	push   %esi
  800211:	50                   	push   %eax
  800212:	68 18 26 80 00       	push   $0x802618
  800217:	e8 b1 00 00 00       	call   8002cd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80021c:	83 c4 18             	add    $0x18,%esp
  80021f:	53                   	push   %ebx
  800220:	ff 75 10             	pushl  0x10(%ebp)
  800223:	e8 54 00 00 00       	call   80027c <vcprintf>
	cprintf("\n");
  800228:	c7 04 24 f8 2a 80 00 	movl   $0x802af8,(%esp)
  80022f:	e8 99 00 00 00       	call   8002cd <cprintf>
  800234:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800237:	cc                   	int3   
  800238:	eb fd                	jmp    800237 <_panic+0x43>

0080023a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	53                   	push   %ebx
  80023e:	83 ec 04             	sub    $0x4,%esp
  800241:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800244:	8b 13                	mov    (%ebx),%edx
  800246:	8d 42 01             	lea    0x1(%edx),%eax
  800249:	89 03                	mov    %eax,(%ebx)
  80024b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80024e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800252:	3d ff 00 00 00       	cmp    $0xff,%eax
  800257:	75 1a                	jne    800273 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800259:	83 ec 08             	sub    $0x8,%esp
  80025c:	68 ff 00 00 00       	push   $0xff
  800261:	8d 43 08             	lea    0x8(%ebx),%eax
  800264:	50                   	push   %eax
  800265:	e8 2f 09 00 00       	call   800b99 <sys_cputs>
		b->idx = 0;
  80026a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800270:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800273:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800277:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80027a:	c9                   	leave  
  80027b:	c3                   	ret    

0080027c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800285:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80028c:	00 00 00 
	b.cnt = 0;
  80028f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800296:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800299:	ff 75 0c             	pushl  0xc(%ebp)
  80029c:	ff 75 08             	pushl  0x8(%ebp)
  80029f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002a5:	50                   	push   %eax
  8002a6:	68 3a 02 80 00       	push   $0x80023a
  8002ab:	e8 54 01 00 00       	call   800404 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002b0:	83 c4 08             	add    $0x8,%esp
  8002b3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002b9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002bf:	50                   	push   %eax
  8002c0:	e8 d4 08 00 00       	call   800b99 <sys_cputs>

	return b.cnt;
}
  8002c5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002cb:	c9                   	leave  
  8002cc:	c3                   	ret    

008002cd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002d3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002d6:	50                   	push   %eax
  8002d7:	ff 75 08             	pushl  0x8(%ebp)
  8002da:	e8 9d ff ff ff       	call   80027c <vcprintf>
	va_end(ap);

	return cnt;
}
  8002df:	c9                   	leave  
  8002e0:	c3                   	ret    

008002e1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e1:	55                   	push   %ebp
  8002e2:	89 e5                	mov    %esp,%ebp
  8002e4:	57                   	push   %edi
  8002e5:	56                   	push   %esi
  8002e6:	53                   	push   %ebx
  8002e7:	83 ec 1c             	sub    $0x1c,%esp
  8002ea:	89 c7                	mov    %eax,%edi
  8002ec:	89 d6                	mov    %edx,%esi
  8002ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002f7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002fd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800302:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800305:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800308:	39 d3                	cmp    %edx,%ebx
  80030a:	72 05                	jb     800311 <printnum+0x30>
  80030c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80030f:	77 45                	ja     800356 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800311:	83 ec 0c             	sub    $0xc,%esp
  800314:	ff 75 18             	pushl  0x18(%ebp)
  800317:	8b 45 14             	mov    0x14(%ebp),%eax
  80031a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80031d:	53                   	push   %ebx
  80031e:	ff 75 10             	pushl  0x10(%ebp)
  800321:	83 ec 08             	sub    $0x8,%esp
  800324:	ff 75 e4             	pushl  -0x1c(%ebp)
  800327:	ff 75 e0             	pushl  -0x20(%ebp)
  80032a:	ff 75 dc             	pushl  -0x24(%ebp)
  80032d:	ff 75 d8             	pushl  -0x28(%ebp)
  800330:	e8 5b 1f 00 00       	call   802290 <__udivdi3>
  800335:	83 c4 18             	add    $0x18,%esp
  800338:	52                   	push   %edx
  800339:	50                   	push   %eax
  80033a:	89 f2                	mov    %esi,%edx
  80033c:	89 f8                	mov    %edi,%eax
  80033e:	e8 9e ff ff ff       	call   8002e1 <printnum>
  800343:	83 c4 20             	add    $0x20,%esp
  800346:	eb 18                	jmp    800360 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800348:	83 ec 08             	sub    $0x8,%esp
  80034b:	56                   	push   %esi
  80034c:	ff 75 18             	pushl  0x18(%ebp)
  80034f:	ff d7                	call   *%edi
  800351:	83 c4 10             	add    $0x10,%esp
  800354:	eb 03                	jmp    800359 <printnum+0x78>
  800356:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800359:	83 eb 01             	sub    $0x1,%ebx
  80035c:	85 db                	test   %ebx,%ebx
  80035e:	7f e8                	jg     800348 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800360:	83 ec 08             	sub    $0x8,%esp
  800363:	56                   	push   %esi
  800364:	83 ec 04             	sub    $0x4,%esp
  800367:	ff 75 e4             	pushl  -0x1c(%ebp)
  80036a:	ff 75 e0             	pushl  -0x20(%ebp)
  80036d:	ff 75 dc             	pushl  -0x24(%ebp)
  800370:	ff 75 d8             	pushl  -0x28(%ebp)
  800373:	e8 48 20 00 00       	call   8023c0 <__umoddi3>
  800378:	83 c4 14             	add    $0x14,%esp
  80037b:	0f be 80 3b 26 80 00 	movsbl 0x80263b(%eax),%eax
  800382:	50                   	push   %eax
  800383:	ff d7                	call   *%edi
}
  800385:	83 c4 10             	add    $0x10,%esp
  800388:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80038b:	5b                   	pop    %ebx
  80038c:	5e                   	pop    %esi
  80038d:	5f                   	pop    %edi
  80038e:	5d                   	pop    %ebp
  80038f:	c3                   	ret    

00800390 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800393:	83 fa 01             	cmp    $0x1,%edx
  800396:	7e 0e                	jle    8003a6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800398:	8b 10                	mov    (%eax),%edx
  80039a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80039d:	89 08                	mov    %ecx,(%eax)
  80039f:	8b 02                	mov    (%edx),%eax
  8003a1:	8b 52 04             	mov    0x4(%edx),%edx
  8003a4:	eb 22                	jmp    8003c8 <getuint+0x38>
	else if (lflag)
  8003a6:	85 d2                	test   %edx,%edx
  8003a8:	74 10                	je     8003ba <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003aa:	8b 10                	mov    (%eax),%edx
  8003ac:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003af:	89 08                	mov    %ecx,(%eax)
  8003b1:	8b 02                	mov    (%edx),%eax
  8003b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b8:	eb 0e                	jmp    8003c8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003ba:	8b 10                	mov    (%eax),%edx
  8003bc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003bf:	89 08                	mov    %ecx,(%eax)
  8003c1:	8b 02                	mov    (%edx),%eax
  8003c3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003d0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003d4:	8b 10                	mov    (%eax),%edx
  8003d6:	3b 50 04             	cmp    0x4(%eax),%edx
  8003d9:	73 0a                	jae    8003e5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003db:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003de:	89 08                	mov    %ecx,(%eax)
  8003e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e3:	88 02                	mov    %al,(%edx)
}
  8003e5:	5d                   	pop    %ebp
  8003e6:	c3                   	ret    

008003e7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003e7:	55                   	push   %ebp
  8003e8:	89 e5                	mov    %esp,%ebp
  8003ea:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ed:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003f0:	50                   	push   %eax
  8003f1:	ff 75 10             	pushl  0x10(%ebp)
  8003f4:	ff 75 0c             	pushl  0xc(%ebp)
  8003f7:	ff 75 08             	pushl  0x8(%ebp)
  8003fa:	e8 05 00 00 00       	call   800404 <vprintfmt>
	va_end(ap);
}
  8003ff:	83 c4 10             	add    $0x10,%esp
  800402:	c9                   	leave  
  800403:	c3                   	ret    

00800404 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800404:	55                   	push   %ebp
  800405:	89 e5                	mov    %esp,%ebp
  800407:	57                   	push   %edi
  800408:	56                   	push   %esi
  800409:	53                   	push   %ebx
  80040a:	83 ec 2c             	sub    $0x2c,%esp
  80040d:	8b 75 08             	mov    0x8(%ebp),%esi
  800410:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800413:	8b 7d 10             	mov    0x10(%ebp),%edi
  800416:	eb 12                	jmp    80042a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800418:	85 c0                	test   %eax,%eax
  80041a:	0f 84 89 03 00 00    	je     8007a9 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800420:	83 ec 08             	sub    $0x8,%esp
  800423:	53                   	push   %ebx
  800424:	50                   	push   %eax
  800425:	ff d6                	call   *%esi
  800427:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80042a:	83 c7 01             	add    $0x1,%edi
  80042d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800431:	83 f8 25             	cmp    $0x25,%eax
  800434:	75 e2                	jne    800418 <vprintfmt+0x14>
  800436:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80043a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800441:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800448:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80044f:	ba 00 00 00 00       	mov    $0x0,%edx
  800454:	eb 07                	jmp    80045d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800456:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800459:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045d:	8d 47 01             	lea    0x1(%edi),%eax
  800460:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800463:	0f b6 07             	movzbl (%edi),%eax
  800466:	0f b6 c8             	movzbl %al,%ecx
  800469:	83 e8 23             	sub    $0x23,%eax
  80046c:	3c 55                	cmp    $0x55,%al
  80046e:	0f 87 1a 03 00 00    	ja     80078e <vprintfmt+0x38a>
  800474:	0f b6 c0             	movzbl %al,%eax
  800477:	ff 24 85 80 27 80 00 	jmp    *0x802780(,%eax,4)
  80047e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800481:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800485:	eb d6                	jmp    80045d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800487:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80048a:	b8 00 00 00 00       	mov    $0x0,%eax
  80048f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800492:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800495:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800499:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80049c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80049f:	83 fa 09             	cmp    $0x9,%edx
  8004a2:	77 39                	ja     8004dd <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004a4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004a7:	eb e9                	jmp    800492 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	8d 48 04             	lea    0x4(%eax),%ecx
  8004af:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004b2:	8b 00                	mov    (%eax),%eax
  8004b4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004ba:	eb 27                	jmp    8004e3 <vprintfmt+0xdf>
  8004bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004bf:	85 c0                	test   %eax,%eax
  8004c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004c6:	0f 49 c8             	cmovns %eax,%ecx
  8004c9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004cf:	eb 8c                	jmp    80045d <vprintfmt+0x59>
  8004d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004d4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004db:	eb 80                	jmp    80045d <vprintfmt+0x59>
  8004dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004e0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004e3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e7:	0f 89 70 ff ff ff    	jns    80045d <vprintfmt+0x59>
				width = precision, precision = -1;
  8004ed:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004fa:	e9 5e ff ff ff       	jmp    80045d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004ff:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800502:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800505:	e9 53 ff ff ff       	jmp    80045d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80050a:	8b 45 14             	mov    0x14(%ebp),%eax
  80050d:	8d 50 04             	lea    0x4(%eax),%edx
  800510:	89 55 14             	mov    %edx,0x14(%ebp)
  800513:	83 ec 08             	sub    $0x8,%esp
  800516:	53                   	push   %ebx
  800517:	ff 30                	pushl  (%eax)
  800519:	ff d6                	call   *%esi
			break;
  80051b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800521:	e9 04 ff ff ff       	jmp    80042a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800526:	8b 45 14             	mov    0x14(%ebp),%eax
  800529:	8d 50 04             	lea    0x4(%eax),%edx
  80052c:	89 55 14             	mov    %edx,0x14(%ebp)
  80052f:	8b 00                	mov    (%eax),%eax
  800531:	99                   	cltd   
  800532:	31 d0                	xor    %edx,%eax
  800534:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800536:	83 f8 0f             	cmp    $0xf,%eax
  800539:	7f 0b                	jg     800546 <vprintfmt+0x142>
  80053b:	8b 14 85 e0 28 80 00 	mov    0x8028e0(,%eax,4),%edx
  800542:	85 d2                	test   %edx,%edx
  800544:	75 18                	jne    80055e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800546:	50                   	push   %eax
  800547:	68 53 26 80 00       	push   $0x802653
  80054c:	53                   	push   %ebx
  80054d:	56                   	push   %esi
  80054e:	e8 94 fe ff ff       	call   8003e7 <printfmt>
  800553:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800556:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800559:	e9 cc fe ff ff       	jmp    80042a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80055e:	52                   	push   %edx
  80055f:	68 11 2a 80 00       	push   $0x802a11
  800564:	53                   	push   %ebx
  800565:	56                   	push   %esi
  800566:	e8 7c fe ff ff       	call   8003e7 <printfmt>
  80056b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800571:	e9 b4 fe ff ff       	jmp    80042a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8d 50 04             	lea    0x4(%eax),%edx
  80057c:	89 55 14             	mov    %edx,0x14(%ebp)
  80057f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800581:	85 ff                	test   %edi,%edi
  800583:	b8 4c 26 80 00       	mov    $0x80264c,%eax
  800588:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80058b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058f:	0f 8e 94 00 00 00    	jle    800629 <vprintfmt+0x225>
  800595:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800599:	0f 84 98 00 00 00    	je     800637 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80059f:	83 ec 08             	sub    $0x8,%esp
  8005a2:	ff 75 d0             	pushl  -0x30(%ebp)
  8005a5:	57                   	push   %edi
  8005a6:	e8 86 02 00 00       	call   800831 <strnlen>
  8005ab:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005ae:	29 c1                	sub    %eax,%ecx
  8005b0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005b3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005b6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005bd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005c0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c2:	eb 0f                	jmp    8005d3 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005c4:	83 ec 08             	sub    $0x8,%esp
  8005c7:	53                   	push   %ebx
  8005c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8005cb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cd:	83 ef 01             	sub    $0x1,%edi
  8005d0:	83 c4 10             	add    $0x10,%esp
  8005d3:	85 ff                	test   %edi,%edi
  8005d5:	7f ed                	jg     8005c4 <vprintfmt+0x1c0>
  8005d7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005da:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005dd:	85 c9                	test   %ecx,%ecx
  8005df:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e4:	0f 49 c1             	cmovns %ecx,%eax
  8005e7:	29 c1                	sub    %eax,%ecx
  8005e9:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ec:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ef:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f2:	89 cb                	mov    %ecx,%ebx
  8005f4:	eb 4d                	jmp    800643 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005f6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005fa:	74 1b                	je     800617 <vprintfmt+0x213>
  8005fc:	0f be c0             	movsbl %al,%eax
  8005ff:	83 e8 20             	sub    $0x20,%eax
  800602:	83 f8 5e             	cmp    $0x5e,%eax
  800605:	76 10                	jbe    800617 <vprintfmt+0x213>
					putch('?', putdat);
  800607:	83 ec 08             	sub    $0x8,%esp
  80060a:	ff 75 0c             	pushl  0xc(%ebp)
  80060d:	6a 3f                	push   $0x3f
  80060f:	ff 55 08             	call   *0x8(%ebp)
  800612:	83 c4 10             	add    $0x10,%esp
  800615:	eb 0d                	jmp    800624 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800617:	83 ec 08             	sub    $0x8,%esp
  80061a:	ff 75 0c             	pushl  0xc(%ebp)
  80061d:	52                   	push   %edx
  80061e:	ff 55 08             	call   *0x8(%ebp)
  800621:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800624:	83 eb 01             	sub    $0x1,%ebx
  800627:	eb 1a                	jmp    800643 <vprintfmt+0x23f>
  800629:	89 75 08             	mov    %esi,0x8(%ebp)
  80062c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80062f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800632:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800635:	eb 0c                	jmp    800643 <vprintfmt+0x23f>
  800637:	89 75 08             	mov    %esi,0x8(%ebp)
  80063a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80063d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800640:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800643:	83 c7 01             	add    $0x1,%edi
  800646:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80064a:	0f be d0             	movsbl %al,%edx
  80064d:	85 d2                	test   %edx,%edx
  80064f:	74 23                	je     800674 <vprintfmt+0x270>
  800651:	85 f6                	test   %esi,%esi
  800653:	78 a1                	js     8005f6 <vprintfmt+0x1f2>
  800655:	83 ee 01             	sub    $0x1,%esi
  800658:	79 9c                	jns    8005f6 <vprintfmt+0x1f2>
  80065a:	89 df                	mov    %ebx,%edi
  80065c:	8b 75 08             	mov    0x8(%ebp),%esi
  80065f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800662:	eb 18                	jmp    80067c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800664:	83 ec 08             	sub    $0x8,%esp
  800667:	53                   	push   %ebx
  800668:	6a 20                	push   $0x20
  80066a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80066c:	83 ef 01             	sub    $0x1,%edi
  80066f:	83 c4 10             	add    $0x10,%esp
  800672:	eb 08                	jmp    80067c <vprintfmt+0x278>
  800674:	89 df                	mov    %ebx,%edi
  800676:	8b 75 08             	mov    0x8(%ebp),%esi
  800679:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80067c:	85 ff                	test   %edi,%edi
  80067e:	7f e4                	jg     800664 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800680:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800683:	e9 a2 fd ff ff       	jmp    80042a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800688:	83 fa 01             	cmp    $0x1,%edx
  80068b:	7e 16                	jle    8006a3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80068d:	8b 45 14             	mov    0x14(%ebp),%eax
  800690:	8d 50 08             	lea    0x8(%eax),%edx
  800693:	89 55 14             	mov    %edx,0x14(%ebp)
  800696:	8b 50 04             	mov    0x4(%eax),%edx
  800699:	8b 00                	mov    (%eax),%eax
  80069b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006a1:	eb 32                	jmp    8006d5 <vprintfmt+0x2d1>
	else if (lflag)
  8006a3:	85 d2                	test   %edx,%edx
  8006a5:	74 18                	je     8006bf <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006aa:	8d 50 04             	lea    0x4(%eax),%edx
  8006ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b0:	8b 00                	mov    (%eax),%eax
  8006b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b5:	89 c1                	mov    %eax,%ecx
  8006b7:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006bd:	eb 16                	jmp    8006d5 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c2:	8d 50 04             	lea    0x4(%eax),%edx
  8006c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c8:	8b 00                	mov    (%eax),%eax
  8006ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006cd:	89 c1                	mov    %eax,%ecx
  8006cf:	c1 f9 1f             	sar    $0x1f,%ecx
  8006d2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006db:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006e0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006e4:	79 74                	jns    80075a <vprintfmt+0x356>
				putch('-', putdat);
  8006e6:	83 ec 08             	sub    $0x8,%esp
  8006e9:	53                   	push   %ebx
  8006ea:	6a 2d                	push   $0x2d
  8006ec:	ff d6                	call   *%esi
				num = -(long long) num;
  8006ee:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006f1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006f4:	f7 d8                	neg    %eax
  8006f6:	83 d2 00             	adc    $0x0,%edx
  8006f9:	f7 da                	neg    %edx
  8006fb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006fe:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800703:	eb 55                	jmp    80075a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800705:	8d 45 14             	lea    0x14(%ebp),%eax
  800708:	e8 83 fc ff ff       	call   800390 <getuint>
			base = 10;
  80070d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800712:	eb 46                	jmp    80075a <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800714:	8d 45 14             	lea    0x14(%ebp),%eax
  800717:	e8 74 fc ff ff       	call   800390 <getuint>
			base = 8;
  80071c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800721:	eb 37                	jmp    80075a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800723:	83 ec 08             	sub    $0x8,%esp
  800726:	53                   	push   %ebx
  800727:	6a 30                	push   $0x30
  800729:	ff d6                	call   *%esi
			putch('x', putdat);
  80072b:	83 c4 08             	add    $0x8,%esp
  80072e:	53                   	push   %ebx
  80072f:	6a 78                	push   $0x78
  800731:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800733:	8b 45 14             	mov    0x14(%ebp),%eax
  800736:	8d 50 04             	lea    0x4(%eax),%edx
  800739:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80073c:	8b 00                	mov    (%eax),%eax
  80073e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800743:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800746:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80074b:	eb 0d                	jmp    80075a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80074d:	8d 45 14             	lea    0x14(%ebp),%eax
  800750:	e8 3b fc ff ff       	call   800390 <getuint>
			base = 16;
  800755:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80075a:	83 ec 0c             	sub    $0xc,%esp
  80075d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800761:	57                   	push   %edi
  800762:	ff 75 e0             	pushl  -0x20(%ebp)
  800765:	51                   	push   %ecx
  800766:	52                   	push   %edx
  800767:	50                   	push   %eax
  800768:	89 da                	mov    %ebx,%edx
  80076a:	89 f0                	mov    %esi,%eax
  80076c:	e8 70 fb ff ff       	call   8002e1 <printnum>
			break;
  800771:	83 c4 20             	add    $0x20,%esp
  800774:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800777:	e9 ae fc ff ff       	jmp    80042a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80077c:	83 ec 08             	sub    $0x8,%esp
  80077f:	53                   	push   %ebx
  800780:	51                   	push   %ecx
  800781:	ff d6                	call   *%esi
			break;
  800783:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800786:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800789:	e9 9c fc ff ff       	jmp    80042a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80078e:	83 ec 08             	sub    $0x8,%esp
  800791:	53                   	push   %ebx
  800792:	6a 25                	push   $0x25
  800794:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800796:	83 c4 10             	add    $0x10,%esp
  800799:	eb 03                	jmp    80079e <vprintfmt+0x39a>
  80079b:	83 ef 01             	sub    $0x1,%edi
  80079e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007a2:	75 f7                	jne    80079b <vprintfmt+0x397>
  8007a4:	e9 81 fc ff ff       	jmp    80042a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ac:	5b                   	pop    %ebx
  8007ad:	5e                   	pop    %esi
  8007ae:	5f                   	pop    %edi
  8007af:	5d                   	pop    %ebp
  8007b0:	c3                   	ret    

008007b1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	83 ec 18             	sub    $0x18,%esp
  8007b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ba:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007c4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ce:	85 c0                	test   %eax,%eax
  8007d0:	74 26                	je     8007f8 <vsnprintf+0x47>
  8007d2:	85 d2                	test   %edx,%edx
  8007d4:	7e 22                	jle    8007f8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d6:	ff 75 14             	pushl  0x14(%ebp)
  8007d9:	ff 75 10             	pushl  0x10(%ebp)
  8007dc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007df:	50                   	push   %eax
  8007e0:	68 ca 03 80 00       	push   $0x8003ca
  8007e5:	e8 1a fc ff ff       	call   800404 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ed:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f3:	83 c4 10             	add    $0x10,%esp
  8007f6:	eb 05                	jmp    8007fd <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007f8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007fd:	c9                   	leave  
  8007fe:	c3                   	ret    

008007ff <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800805:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800808:	50                   	push   %eax
  800809:	ff 75 10             	pushl  0x10(%ebp)
  80080c:	ff 75 0c             	pushl  0xc(%ebp)
  80080f:	ff 75 08             	pushl  0x8(%ebp)
  800812:	e8 9a ff ff ff       	call   8007b1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800817:	c9                   	leave  
  800818:	c3                   	ret    

00800819 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80081f:	b8 00 00 00 00       	mov    $0x0,%eax
  800824:	eb 03                	jmp    800829 <strlen+0x10>
		n++;
  800826:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800829:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80082d:	75 f7                	jne    800826 <strlen+0xd>
		n++;
	return n;
}
  80082f:	5d                   	pop    %ebp
  800830:	c3                   	ret    

00800831 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800837:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083a:	ba 00 00 00 00       	mov    $0x0,%edx
  80083f:	eb 03                	jmp    800844 <strnlen+0x13>
		n++;
  800841:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800844:	39 c2                	cmp    %eax,%edx
  800846:	74 08                	je     800850 <strnlen+0x1f>
  800848:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80084c:	75 f3                	jne    800841 <strnlen+0x10>
  80084e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	53                   	push   %ebx
  800856:	8b 45 08             	mov    0x8(%ebp),%eax
  800859:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80085c:	89 c2                	mov    %eax,%edx
  80085e:	83 c2 01             	add    $0x1,%edx
  800861:	83 c1 01             	add    $0x1,%ecx
  800864:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800868:	88 5a ff             	mov    %bl,-0x1(%edx)
  80086b:	84 db                	test   %bl,%bl
  80086d:	75 ef                	jne    80085e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80086f:	5b                   	pop    %ebx
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	53                   	push   %ebx
  800876:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800879:	53                   	push   %ebx
  80087a:	e8 9a ff ff ff       	call   800819 <strlen>
  80087f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800882:	ff 75 0c             	pushl  0xc(%ebp)
  800885:	01 d8                	add    %ebx,%eax
  800887:	50                   	push   %eax
  800888:	e8 c5 ff ff ff       	call   800852 <strcpy>
	return dst;
}
  80088d:	89 d8                	mov    %ebx,%eax
  80088f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800892:	c9                   	leave  
  800893:	c3                   	ret    

00800894 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	56                   	push   %esi
  800898:	53                   	push   %ebx
  800899:	8b 75 08             	mov    0x8(%ebp),%esi
  80089c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80089f:	89 f3                	mov    %esi,%ebx
  8008a1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a4:	89 f2                	mov    %esi,%edx
  8008a6:	eb 0f                	jmp    8008b7 <strncpy+0x23>
		*dst++ = *src;
  8008a8:	83 c2 01             	add    $0x1,%edx
  8008ab:	0f b6 01             	movzbl (%ecx),%eax
  8008ae:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b1:	80 39 01             	cmpb   $0x1,(%ecx)
  8008b4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b7:	39 da                	cmp    %ebx,%edx
  8008b9:	75 ed                	jne    8008a8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008bb:	89 f0                	mov    %esi,%eax
  8008bd:	5b                   	pop    %ebx
  8008be:	5e                   	pop    %esi
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	56                   	push   %esi
  8008c5:	53                   	push   %ebx
  8008c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008cc:	8b 55 10             	mov    0x10(%ebp),%edx
  8008cf:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d1:	85 d2                	test   %edx,%edx
  8008d3:	74 21                	je     8008f6 <strlcpy+0x35>
  8008d5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008d9:	89 f2                	mov    %esi,%edx
  8008db:	eb 09                	jmp    8008e6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008dd:	83 c2 01             	add    $0x1,%edx
  8008e0:	83 c1 01             	add    $0x1,%ecx
  8008e3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008e6:	39 c2                	cmp    %eax,%edx
  8008e8:	74 09                	je     8008f3 <strlcpy+0x32>
  8008ea:	0f b6 19             	movzbl (%ecx),%ebx
  8008ed:	84 db                	test   %bl,%bl
  8008ef:	75 ec                	jne    8008dd <strlcpy+0x1c>
  8008f1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008f3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008f6:	29 f0                	sub    %esi,%eax
}
  8008f8:	5b                   	pop    %ebx
  8008f9:	5e                   	pop    %esi
  8008fa:	5d                   	pop    %ebp
  8008fb:	c3                   	ret    

008008fc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800902:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800905:	eb 06                	jmp    80090d <strcmp+0x11>
		p++, q++;
  800907:	83 c1 01             	add    $0x1,%ecx
  80090a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80090d:	0f b6 01             	movzbl (%ecx),%eax
  800910:	84 c0                	test   %al,%al
  800912:	74 04                	je     800918 <strcmp+0x1c>
  800914:	3a 02                	cmp    (%edx),%al
  800916:	74 ef                	je     800907 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800918:	0f b6 c0             	movzbl %al,%eax
  80091b:	0f b6 12             	movzbl (%edx),%edx
  80091e:	29 d0                	sub    %edx,%eax
}
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	53                   	push   %ebx
  800926:	8b 45 08             	mov    0x8(%ebp),%eax
  800929:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092c:	89 c3                	mov    %eax,%ebx
  80092e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800931:	eb 06                	jmp    800939 <strncmp+0x17>
		n--, p++, q++;
  800933:	83 c0 01             	add    $0x1,%eax
  800936:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800939:	39 d8                	cmp    %ebx,%eax
  80093b:	74 15                	je     800952 <strncmp+0x30>
  80093d:	0f b6 08             	movzbl (%eax),%ecx
  800940:	84 c9                	test   %cl,%cl
  800942:	74 04                	je     800948 <strncmp+0x26>
  800944:	3a 0a                	cmp    (%edx),%cl
  800946:	74 eb                	je     800933 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800948:	0f b6 00             	movzbl (%eax),%eax
  80094b:	0f b6 12             	movzbl (%edx),%edx
  80094e:	29 d0                	sub    %edx,%eax
  800950:	eb 05                	jmp    800957 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800952:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800957:	5b                   	pop    %ebx
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	8b 45 08             	mov    0x8(%ebp),%eax
  800960:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800964:	eb 07                	jmp    80096d <strchr+0x13>
		if (*s == c)
  800966:	38 ca                	cmp    %cl,%dl
  800968:	74 0f                	je     800979 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80096a:	83 c0 01             	add    $0x1,%eax
  80096d:	0f b6 10             	movzbl (%eax),%edx
  800970:	84 d2                	test   %dl,%dl
  800972:	75 f2                	jne    800966 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800974:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800985:	eb 03                	jmp    80098a <strfind+0xf>
  800987:	83 c0 01             	add    $0x1,%eax
  80098a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80098d:	38 ca                	cmp    %cl,%dl
  80098f:	74 04                	je     800995 <strfind+0x1a>
  800991:	84 d2                	test   %dl,%dl
  800993:	75 f2                	jne    800987 <strfind+0xc>
			break;
	return (char *) s;
}
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	57                   	push   %edi
  80099b:	56                   	push   %esi
  80099c:	53                   	push   %ebx
  80099d:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009a3:	85 c9                	test   %ecx,%ecx
  8009a5:	74 36                	je     8009dd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ad:	75 28                	jne    8009d7 <memset+0x40>
  8009af:	f6 c1 03             	test   $0x3,%cl
  8009b2:	75 23                	jne    8009d7 <memset+0x40>
		c &= 0xFF;
  8009b4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009b8:	89 d3                	mov    %edx,%ebx
  8009ba:	c1 e3 08             	shl    $0x8,%ebx
  8009bd:	89 d6                	mov    %edx,%esi
  8009bf:	c1 e6 18             	shl    $0x18,%esi
  8009c2:	89 d0                	mov    %edx,%eax
  8009c4:	c1 e0 10             	shl    $0x10,%eax
  8009c7:	09 f0                	or     %esi,%eax
  8009c9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009cb:	89 d8                	mov    %ebx,%eax
  8009cd:	09 d0                	or     %edx,%eax
  8009cf:	c1 e9 02             	shr    $0x2,%ecx
  8009d2:	fc                   	cld    
  8009d3:	f3 ab                	rep stos %eax,%es:(%edi)
  8009d5:	eb 06                	jmp    8009dd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009da:	fc                   	cld    
  8009db:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009dd:	89 f8                	mov    %edi,%eax
  8009df:	5b                   	pop    %ebx
  8009e0:	5e                   	pop    %esi
  8009e1:	5f                   	pop    %edi
  8009e2:	5d                   	pop    %ebp
  8009e3:	c3                   	ret    

008009e4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	57                   	push   %edi
  8009e8:	56                   	push   %esi
  8009e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ec:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009f2:	39 c6                	cmp    %eax,%esi
  8009f4:	73 35                	jae    800a2b <memmove+0x47>
  8009f6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009f9:	39 d0                	cmp    %edx,%eax
  8009fb:	73 2e                	jae    800a2b <memmove+0x47>
		s += n;
		d += n;
  8009fd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a00:	89 d6                	mov    %edx,%esi
  800a02:	09 fe                	or     %edi,%esi
  800a04:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a0a:	75 13                	jne    800a1f <memmove+0x3b>
  800a0c:	f6 c1 03             	test   $0x3,%cl
  800a0f:	75 0e                	jne    800a1f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a11:	83 ef 04             	sub    $0x4,%edi
  800a14:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a17:	c1 e9 02             	shr    $0x2,%ecx
  800a1a:	fd                   	std    
  800a1b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a1d:	eb 09                	jmp    800a28 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a1f:	83 ef 01             	sub    $0x1,%edi
  800a22:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a25:	fd                   	std    
  800a26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a28:	fc                   	cld    
  800a29:	eb 1d                	jmp    800a48 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a2b:	89 f2                	mov    %esi,%edx
  800a2d:	09 c2                	or     %eax,%edx
  800a2f:	f6 c2 03             	test   $0x3,%dl
  800a32:	75 0f                	jne    800a43 <memmove+0x5f>
  800a34:	f6 c1 03             	test   $0x3,%cl
  800a37:	75 0a                	jne    800a43 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a39:	c1 e9 02             	shr    $0x2,%ecx
  800a3c:	89 c7                	mov    %eax,%edi
  800a3e:	fc                   	cld    
  800a3f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a41:	eb 05                	jmp    800a48 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a43:	89 c7                	mov    %eax,%edi
  800a45:	fc                   	cld    
  800a46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a48:	5e                   	pop    %esi
  800a49:	5f                   	pop    %edi
  800a4a:	5d                   	pop    %ebp
  800a4b:	c3                   	ret    

00800a4c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a4f:	ff 75 10             	pushl  0x10(%ebp)
  800a52:	ff 75 0c             	pushl  0xc(%ebp)
  800a55:	ff 75 08             	pushl  0x8(%ebp)
  800a58:	e8 87 ff ff ff       	call   8009e4 <memmove>
}
  800a5d:	c9                   	leave  
  800a5e:	c3                   	ret    

00800a5f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	56                   	push   %esi
  800a63:	53                   	push   %ebx
  800a64:	8b 45 08             	mov    0x8(%ebp),%eax
  800a67:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a6a:	89 c6                	mov    %eax,%esi
  800a6c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6f:	eb 1a                	jmp    800a8b <memcmp+0x2c>
		if (*s1 != *s2)
  800a71:	0f b6 08             	movzbl (%eax),%ecx
  800a74:	0f b6 1a             	movzbl (%edx),%ebx
  800a77:	38 d9                	cmp    %bl,%cl
  800a79:	74 0a                	je     800a85 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a7b:	0f b6 c1             	movzbl %cl,%eax
  800a7e:	0f b6 db             	movzbl %bl,%ebx
  800a81:	29 d8                	sub    %ebx,%eax
  800a83:	eb 0f                	jmp    800a94 <memcmp+0x35>
		s1++, s2++;
  800a85:	83 c0 01             	add    $0x1,%eax
  800a88:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8b:	39 f0                	cmp    %esi,%eax
  800a8d:	75 e2                	jne    800a71 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a94:	5b                   	pop    %ebx
  800a95:	5e                   	pop    %esi
  800a96:	5d                   	pop    %ebp
  800a97:	c3                   	ret    

00800a98 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	53                   	push   %ebx
  800a9c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a9f:	89 c1                	mov    %eax,%ecx
  800aa1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aa8:	eb 0a                	jmp    800ab4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aaa:	0f b6 10             	movzbl (%eax),%edx
  800aad:	39 da                	cmp    %ebx,%edx
  800aaf:	74 07                	je     800ab8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ab1:	83 c0 01             	add    $0x1,%eax
  800ab4:	39 c8                	cmp    %ecx,%eax
  800ab6:	72 f2                	jb     800aaa <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	57                   	push   %edi
  800abf:	56                   	push   %esi
  800ac0:	53                   	push   %ebx
  800ac1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ac4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac7:	eb 03                	jmp    800acc <strtol+0x11>
		s++;
  800ac9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800acc:	0f b6 01             	movzbl (%ecx),%eax
  800acf:	3c 20                	cmp    $0x20,%al
  800ad1:	74 f6                	je     800ac9 <strtol+0xe>
  800ad3:	3c 09                	cmp    $0x9,%al
  800ad5:	74 f2                	je     800ac9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ad7:	3c 2b                	cmp    $0x2b,%al
  800ad9:	75 0a                	jne    800ae5 <strtol+0x2a>
		s++;
  800adb:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ade:	bf 00 00 00 00       	mov    $0x0,%edi
  800ae3:	eb 11                	jmp    800af6 <strtol+0x3b>
  800ae5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aea:	3c 2d                	cmp    $0x2d,%al
  800aec:	75 08                	jne    800af6 <strtol+0x3b>
		s++, neg = 1;
  800aee:	83 c1 01             	add    $0x1,%ecx
  800af1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800afc:	75 15                	jne    800b13 <strtol+0x58>
  800afe:	80 39 30             	cmpb   $0x30,(%ecx)
  800b01:	75 10                	jne    800b13 <strtol+0x58>
  800b03:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b07:	75 7c                	jne    800b85 <strtol+0xca>
		s += 2, base = 16;
  800b09:	83 c1 02             	add    $0x2,%ecx
  800b0c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b11:	eb 16                	jmp    800b29 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b13:	85 db                	test   %ebx,%ebx
  800b15:	75 12                	jne    800b29 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b17:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b1c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b1f:	75 08                	jne    800b29 <strtol+0x6e>
		s++, base = 8;
  800b21:	83 c1 01             	add    $0x1,%ecx
  800b24:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b29:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b31:	0f b6 11             	movzbl (%ecx),%edx
  800b34:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b37:	89 f3                	mov    %esi,%ebx
  800b39:	80 fb 09             	cmp    $0x9,%bl
  800b3c:	77 08                	ja     800b46 <strtol+0x8b>
			dig = *s - '0';
  800b3e:	0f be d2             	movsbl %dl,%edx
  800b41:	83 ea 30             	sub    $0x30,%edx
  800b44:	eb 22                	jmp    800b68 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b46:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b49:	89 f3                	mov    %esi,%ebx
  800b4b:	80 fb 19             	cmp    $0x19,%bl
  800b4e:	77 08                	ja     800b58 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b50:	0f be d2             	movsbl %dl,%edx
  800b53:	83 ea 57             	sub    $0x57,%edx
  800b56:	eb 10                	jmp    800b68 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b58:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b5b:	89 f3                	mov    %esi,%ebx
  800b5d:	80 fb 19             	cmp    $0x19,%bl
  800b60:	77 16                	ja     800b78 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b62:	0f be d2             	movsbl %dl,%edx
  800b65:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b68:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b6b:	7d 0b                	jge    800b78 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b6d:	83 c1 01             	add    $0x1,%ecx
  800b70:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b74:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b76:	eb b9                	jmp    800b31 <strtol+0x76>

	if (endptr)
  800b78:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b7c:	74 0d                	je     800b8b <strtol+0xd0>
		*endptr = (char *) s;
  800b7e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b81:	89 0e                	mov    %ecx,(%esi)
  800b83:	eb 06                	jmp    800b8b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b85:	85 db                	test   %ebx,%ebx
  800b87:	74 98                	je     800b21 <strtol+0x66>
  800b89:	eb 9e                	jmp    800b29 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b8b:	89 c2                	mov    %eax,%edx
  800b8d:	f7 da                	neg    %edx
  800b8f:	85 ff                	test   %edi,%edi
  800b91:	0f 45 c2             	cmovne %edx,%eax
}
  800b94:	5b                   	pop    %ebx
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    

00800b99 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	57                   	push   %edi
  800b9d:	56                   	push   %esi
  800b9e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba7:	8b 55 08             	mov    0x8(%ebp),%edx
  800baa:	89 c3                	mov    %eax,%ebx
  800bac:	89 c7                	mov    %eax,%edi
  800bae:	89 c6                	mov    %eax,%esi
  800bb0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	57                   	push   %edi
  800bbb:	56                   	push   %esi
  800bbc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc2:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc7:	89 d1                	mov    %edx,%ecx
  800bc9:	89 d3                	mov    %edx,%ebx
  800bcb:	89 d7                	mov    %edx,%edi
  800bcd:	89 d6                	mov    %edx,%esi
  800bcf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
  800bdc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be4:	b8 03 00 00 00       	mov    $0x3,%eax
  800be9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bec:	89 cb                	mov    %ecx,%ebx
  800bee:	89 cf                	mov    %ecx,%edi
  800bf0:	89 ce                	mov    %ecx,%esi
  800bf2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf4:	85 c0                	test   %eax,%eax
  800bf6:	7e 17                	jle    800c0f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf8:	83 ec 0c             	sub    $0xc,%esp
  800bfb:	50                   	push   %eax
  800bfc:	6a 03                	push   $0x3
  800bfe:	68 3f 29 80 00       	push   $0x80293f
  800c03:	6a 23                	push   $0x23
  800c05:	68 5c 29 80 00       	push   $0x80295c
  800c0a:	e8 e5 f5 ff ff       	call   8001f4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c12:	5b                   	pop    %ebx
  800c13:	5e                   	pop    %esi
  800c14:	5f                   	pop    %edi
  800c15:	5d                   	pop    %ebp
  800c16:	c3                   	ret    

00800c17 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	57                   	push   %edi
  800c1b:	56                   	push   %esi
  800c1c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c22:	b8 02 00 00 00       	mov    $0x2,%eax
  800c27:	89 d1                	mov    %edx,%ecx
  800c29:	89 d3                	mov    %edx,%ebx
  800c2b:	89 d7                	mov    %edx,%edi
  800c2d:	89 d6                	mov    %edx,%esi
  800c2f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <sys_yield>:

void
sys_yield(void)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c41:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c46:	89 d1                	mov    %edx,%ecx
  800c48:	89 d3                	mov    %edx,%ebx
  800c4a:	89 d7                	mov    %edx,%edi
  800c4c:	89 d6                	mov    %edx,%esi
  800c4e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
  800c5b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5e:	be 00 00 00 00       	mov    $0x0,%esi
  800c63:	b8 04 00 00 00       	mov    $0x4,%eax
  800c68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c71:	89 f7                	mov    %esi,%edi
  800c73:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c75:	85 c0                	test   %eax,%eax
  800c77:	7e 17                	jle    800c90 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c79:	83 ec 0c             	sub    $0xc,%esp
  800c7c:	50                   	push   %eax
  800c7d:	6a 04                	push   $0x4
  800c7f:	68 3f 29 80 00       	push   $0x80293f
  800c84:	6a 23                	push   $0x23
  800c86:	68 5c 29 80 00       	push   $0x80295c
  800c8b:	e8 64 f5 ff ff       	call   8001f4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c93:	5b                   	pop    %ebx
  800c94:	5e                   	pop    %esi
  800c95:	5f                   	pop    %edi
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    

00800c98 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	57                   	push   %edi
  800c9c:	56                   	push   %esi
  800c9d:	53                   	push   %ebx
  800c9e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca1:	b8 05 00 00 00       	mov    $0x5,%eax
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800caf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cb2:	8b 75 18             	mov    0x18(%ebp),%esi
  800cb5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb7:	85 c0                	test   %eax,%eax
  800cb9:	7e 17                	jle    800cd2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbb:	83 ec 0c             	sub    $0xc,%esp
  800cbe:	50                   	push   %eax
  800cbf:	6a 05                	push   $0x5
  800cc1:	68 3f 29 80 00       	push   $0x80293f
  800cc6:	6a 23                	push   $0x23
  800cc8:	68 5c 29 80 00       	push   $0x80295c
  800ccd:	e8 22 f5 ff ff       	call   8001f4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
  800ce0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce8:	b8 06 00 00 00       	mov    $0x6,%eax
  800ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	89 df                	mov    %ebx,%edi
  800cf5:	89 de                	mov    %ebx,%esi
  800cf7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	7e 17                	jle    800d14 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfd:	83 ec 0c             	sub    $0xc,%esp
  800d00:	50                   	push   %eax
  800d01:	6a 06                	push   $0x6
  800d03:	68 3f 29 80 00       	push   $0x80293f
  800d08:	6a 23                	push   $0x23
  800d0a:	68 5c 29 80 00       	push   $0x80295c
  800d0f:	e8 e0 f4 ff ff       	call   8001f4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d17:	5b                   	pop    %ebx
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	57                   	push   %edi
  800d20:	56                   	push   %esi
  800d21:	53                   	push   %ebx
  800d22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d25:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2a:	b8 08 00 00 00       	mov    $0x8,%eax
  800d2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d32:	8b 55 08             	mov    0x8(%ebp),%edx
  800d35:	89 df                	mov    %ebx,%edi
  800d37:	89 de                	mov    %ebx,%esi
  800d39:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	7e 17                	jle    800d56 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3f:	83 ec 0c             	sub    $0xc,%esp
  800d42:	50                   	push   %eax
  800d43:	6a 08                	push   $0x8
  800d45:	68 3f 29 80 00       	push   $0x80293f
  800d4a:	6a 23                	push   $0x23
  800d4c:	68 5c 29 80 00       	push   $0x80295c
  800d51:	e8 9e f4 ff ff       	call   8001f4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6c:	b8 09 00 00 00       	mov    $0x9,%eax
  800d71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d74:	8b 55 08             	mov    0x8(%ebp),%edx
  800d77:	89 df                	mov    %ebx,%edi
  800d79:	89 de                	mov    %ebx,%esi
  800d7b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	7e 17                	jle    800d98 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d81:	83 ec 0c             	sub    $0xc,%esp
  800d84:	50                   	push   %eax
  800d85:	6a 09                	push   $0x9
  800d87:	68 3f 29 80 00       	push   $0x80293f
  800d8c:	6a 23                	push   $0x23
  800d8e:	68 5c 29 80 00       	push   $0x80295c
  800d93:	e8 5c f4 ff ff       	call   8001f4 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
  800da6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dae:	b8 0a 00 00 00       	mov    $0xa,%eax
  800db3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db6:	8b 55 08             	mov    0x8(%ebp),%edx
  800db9:	89 df                	mov    %ebx,%edi
  800dbb:	89 de                	mov    %ebx,%esi
  800dbd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	7e 17                	jle    800dda <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc3:	83 ec 0c             	sub    $0xc,%esp
  800dc6:	50                   	push   %eax
  800dc7:	6a 0a                	push   $0xa
  800dc9:	68 3f 29 80 00       	push   $0x80293f
  800dce:	6a 23                	push   $0x23
  800dd0:	68 5c 29 80 00       	push   $0x80295c
  800dd5:	e8 1a f4 ff ff       	call   8001f4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de8:	be 00 00 00 00       	mov    $0x0,%esi
  800ded:	b8 0c 00 00 00       	mov    $0xc,%eax
  800df2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df5:	8b 55 08             	mov    0x8(%ebp),%edx
  800df8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dfb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dfe:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	57                   	push   %edi
  800e09:	56                   	push   %esi
  800e0a:	53                   	push   %ebx
  800e0b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e13:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e18:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1b:	89 cb                	mov    %ecx,%ebx
  800e1d:	89 cf                	mov    %ecx,%edi
  800e1f:	89 ce                	mov    %ecx,%esi
  800e21:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e23:	85 c0                	test   %eax,%eax
  800e25:	7e 17                	jle    800e3e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e27:	83 ec 0c             	sub    $0xc,%esp
  800e2a:	50                   	push   %eax
  800e2b:	6a 0d                	push   $0xd
  800e2d:	68 3f 29 80 00       	push   $0x80293f
  800e32:	6a 23                	push   $0x23
  800e34:	68 5c 29 80 00       	push   $0x80295c
  800e39:	e8 b6 f3 ff ff       	call   8001f4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e41:	5b                   	pop    %ebx
  800e42:	5e                   	pop    %esi
  800e43:	5f                   	pop    %edi
  800e44:	5d                   	pop    %ebp
  800e45:	c3                   	ret    

00800e46 <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	57                   	push   %edi
  800e4a:	56                   	push   %esi
  800e4b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e51:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e56:	8b 55 08             	mov    0x8(%ebp),%edx
  800e59:	89 cb                	mov    %ecx,%ebx
  800e5b:	89 cf                	mov    %ecx,%edi
  800e5d:	89 ce                	mov    %ecx,%esi
  800e5f:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800e61:	5b                   	pop    %ebx
  800e62:	5e                   	pop    %esi
  800e63:	5f                   	pop    %edi
  800e64:	5d                   	pop    %ebp
  800e65:	c3                   	ret    

00800e66 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e69:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6c:	05 00 00 00 30       	add    $0x30000000,%eax
  800e71:	c1 e8 0c             	shr    $0xc,%eax
}
  800e74:	5d                   	pop    %ebp
  800e75:	c3                   	ret    

00800e76 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e76:	55                   	push   %ebp
  800e77:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e79:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7c:	05 00 00 00 30       	add    $0x30000000,%eax
  800e81:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e86:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e8b:	5d                   	pop    %ebp
  800e8c:	c3                   	ret    

00800e8d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
  800e90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e93:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e98:	89 c2                	mov    %eax,%edx
  800e9a:	c1 ea 16             	shr    $0x16,%edx
  800e9d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ea4:	f6 c2 01             	test   $0x1,%dl
  800ea7:	74 11                	je     800eba <fd_alloc+0x2d>
  800ea9:	89 c2                	mov    %eax,%edx
  800eab:	c1 ea 0c             	shr    $0xc,%edx
  800eae:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eb5:	f6 c2 01             	test   $0x1,%dl
  800eb8:	75 09                	jne    800ec3 <fd_alloc+0x36>
			*fd_store = fd;
  800eba:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ebc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec1:	eb 17                	jmp    800eda <fd_alloc+0x4d>
  800ec3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ec8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ecd:	75 c9                	jne    800e98 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ecf:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ed5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ee2:	83 f8 1f             	cmp    $0x1f,%eax
  800ee5:	77 36                	ja     800f1d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ee7:	c1 e0 0c             	shl    $0xc,%eax
  800eea:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eef:	89 c2                	mov    %eax,%edx
  800ef1:	c1 ea 16             	shr    $0x16,%edx
  800ef4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800efb:	f6 c2 01             	test   $0x1,%dl
  800efe:	74 24                	je     800f24 <fd_lookup+0x48>
  800f00:	89 c2                	mov    %eax,%edx
  800f02:	c1 ea 0c             	shr    $0xc,%edx
  800f05:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f0c:	f6 c2 01             	test   $0x1,%dl
  800f0f:	74 1a                	je     800f2b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f11:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f14:	89 02                	mov    %eax,(%edx)
	return 0;
  800f16:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1b:	eb 13                	jmp    800f30 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f1d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f22:	eb 0c                	jmp    800f30 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f24:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f29:	eb 05                	jmp    800f30 <fd_lookup+0x54>
  800f2b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f30:	5d                   	pop    %ebp
  800f31:	c3                   	ret    

00800f32 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	83 ec 08             	sub    $0x8,%esp
  800f38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f3b:	ba e8 29 80 00       	mov    $0x8029e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f40:	eb 13                	jmp    800f55 <dev_lookup+0x23>
  800f42:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f45:	39 08                	cmp    %ecx,(%eax)
  800f47:	75 0c                	jne    800f55 <dev_lookup+0x23>
			*dev = devtab[i];
  800f49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f4c:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f53:	eb 2e                	jmp    800f83 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f55:	8b 02                	mov    (%edx),%eax
  800f57:	85 c0                	test   %eax,%eax
  800f59:	75 e7                	jne    800f42 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f5b:	a1 04 40 80 00       	mov    0x804004,%eax
  800f60:	8b 40 50             	mov    0x50(%eax),%eax
  800f63:	83 ec 04             	sub    $0x4,%esp
  800f66:	51                   	push   %ecx
  800f67:	50                   	push   %eax
  800f68:	68 6c 29 80 00       	push   $0x80296c
  800f6d:	e8 5b f3 ff ff       	call   8002cd <cprintf>
	*dev = 0;
  800f72:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f75:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f7b:	83 c4 10             	add    $0x10,%esp
  800f7e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f83:	c9                   	leave  
  800f84:	c3                   	ret    

00800f85 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f85:	55                   	push   %ebp
  800f86:	89 e5                	mov    %esp,%ebp
  800f88:	56                   	push   %esi
  800f89:	53                   	push   %ebx
  800f8a:	83 ec 10             	sub    $0x10,%esp
  800f8d:	8b 75 08             	mov    0x8(%ebp),%esi
  800f90:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f93:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f96:	50                   	push   %eax
  800f97:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f9d:	c1 e8 0c             	shr    $0xc,%eax
  800fa0:	50                   	push   %eax
  800fa1:	e8 36 ff ff ff       	call   800edc <fd_lookup>
  800fa6:	83 c4 08             	add    $0x8,%esp
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	78 05                	js     800fb2 <fd_close+0x2d>
	    || fd != fd2)
  800fad:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fb0:	74 0c                	je     800fbe <fd_close+0x39>
		return (must_exist ? r : 0);
  800fb2:	84 db                	test   %bl,%bl
  800fb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb9:	0f 44 c2             	cmove  %edx,%eax
  800fbc:	eb 41                	jmp    800fff <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fbe:	83 ec 08             	sub    $0x8,%esp
  800fc1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fc4:	50                   	push   %eax
  800fc5:	ff 36                	pushl  (%esi)
  800fc7:	e8 66 ff ff ff       	call   800f32 <dev_lookup>
  800fcc:	89 c3                	mov    %eax,%ebx
  800fce:	83 c4 10             	add    $0x10,%esp
  800fd1:	85 c0                	test   %eax,%eax
  800fd3:	78 1a                	js     800fef <fd_close+0x6a>
		if (dev->dev_close)
  800fd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fd8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fdb:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fe0:	85 c0                	test   %eax,%eax
  800fe2:	74 0b                	je     800fef <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fe4:	83 ec 0c             	sub    $0xc,%esp
  800fe7:	56                   	push   %esi
  800fe8:	ff d0                	call   *%eax
  800fea:	89 c3                	mov    %eax,%ebx
  800fec:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fef:	83 ec 08             	sub    $0x8,%esp
  800ff2:	56                   	push   %esi
  800ff3:	6a 00                	push   $0x0
  800ff5:	e8 e0 fc ff ff       	call   800cda <sys_page_unmap>
	return r;
  800ffa:	83 c4 10             	add    $0x10,%esp
  800ffd:	89 d8                	mov    %ebx,%eax
}
  800fff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801002:	5b                   	pop    %ebx
  801003:	5e                   	pop    %esi
  801004:	5d                   	pop    %ebp
  801005:	c3                   	ret    

00801006 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801006:	55                   	push   %ebp
  801007:	89 e5                	mov    %esp,%ebp
  801009:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80100c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80100f:	50                   	push   %eax
  801010:	ff 75 08             	pushl  0x8(%ebp)
  801013:	e8 c4 fe ff ff       	call   800edc <fd_lookup>
  801018:	83 c4 08             	add    $0x8,%esp
  80101b:	85 c0                	test   %eax,%eax
  80101d:	78 10                	js     80102f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80101f:	83 ec 08             	sub    $0x8,%esp
  801022:	6a 01                	push   $0x1
  801024:	ff 75 f4             	pushl  -0xc(%ebp)
  801027:	e8 59 ff ff ff       	call   800f85 <fd_close>
  80102c:	83 c4 10             	add    $0x10,%esp
}
  80102f:	c9                   	leave  
  801030:	c3                   	ret    

00801031 <close_all>:

void
close_all(void)
{
  801031:	55                   	push   %ebp
  801032:	89 e5                	mov    %esp,%ebp
  801034:	53                   	push   %ebx
  801035:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801038:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80103d:	83 ec 0c             	sub    $0xc,%esp
  801040:	53                   	push   %ebx
  801041:	e8 c0 ff ff ff       	call   801006 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801046:	83 c3 01             	add    $0x1,%ebx
  801049:	83 c4 10             	add    $0x10,%esp
  80104c:	83 fb 20             	cmp    $0x20,%ebx
  80104f:	75 ec                	jne    80103d <close_all+0xc>
		close(i);
}
  801051:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801054:	c9                   	leave  
  801055:	c3                   	ret    

00801056 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	57                   	push   %edi
  80105a:	56                   	push   %esi
  80105b:	53                   	push   %ebx
  80105c:	83 ec 2c             	sub    $0x2c,%esp
  80105f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801062:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801065:	50                   	push   %eax
  801066:	ff 75 08             	pushl  0x8(%ebp)
  801069:	e8 6e fe ff ff       	call   800edc <fd_lookup>
  80106e:	83 c4 08             	add    $0x8,%esp
  801071:	85 c0                	test   %eax,%eax
  801073:	0f 88 c1 00 00 00    	js     80113a <dup+0xe4>
		return r;
	close(newfdnum);
  801079:	83 ec 0c             	sub    $0xc,%esp
  80107c:	56                   	push   %esi
  80107d:	e8 84 ff ff ff       	call   801006 <close>

	newfd = INDEX2FD(newfdnum);
  801082:	89 f3                	mov    %esi,%ebx
  801084:	c1 e3 0c             	shl    $0xc,%ebx
  801087:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80108d:	83 c4 04             	add    $0x4,%esp
  801090:	ff 75 e4             	pushl  -0x1c(%ebp)
  801093:	e8 de fd ff ff       	call   800e76 <fd2data>
  801098:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80109a:	89 1c 24             	mov    %ebx,(%esp)
  80109d:	e8 d4 fd ff ff       	call   800e76 <fd2data>
  8010a2:	83 c4 10             	add    $0x10,%esp
  8010a5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010a8:	89 f8                	mov    %edi,%eax
  8010aa:	c1 e8 16             	shr    $0x16,%eax
  8010ad:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010b4:	a8 01                	test   $0x1,%al
  8010b6:	74 37                	je     8010ef <dup+0x99>
  8010b8:	89 f8                	mov    %edi,%eax
  8010ba:	c1 e8 0c             	shr    $0xc,%eax
  8010bd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010c4:	f6 c2 01             	test   $0x1,%dl
  8010c7:	74 26                	je     8010ef <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010c9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010d0:	83 ec 0c             	sub    $0xc,%esp
  8010d3:	25 07 0e 00 00       	and    $0xe07,%eax
  8010d8:	50                   	push   %eax
  8010d9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010dc:	6a 00                	push   $0x0
  8010de:	57                   	push   %edi
  8010df:	6a 00                	push   $0x0
  8010e1:	e8 b2 fb ff ff       	call   800c98 <sys_page_map>
  8010e6:	89 c7                	mov    %eax,%edi
  8010e8:	83 c4 20             	add    $0x20,%esp
  8010eb:	85 c0                	test   %eax,%eax
  8010ed:	78 2e                	js     80111d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ef:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010f2:	89 d0                	mov    %edx,%eax
  8010f4:	c1 e8 0c             	shr    $0xc,%eax
  8010f7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010fe:	83 ec 0c             	sub    $0xc,%esp
  801101:	25 07 0e 00 00       	and    $0xe07,%eax
  801106:	50                   	push   %eax
  801107:	53                   	push   %ebx
  801108:	6a 00                	push   $0x0
  80110a:	52                   	push   %edx
  80110b:	6a 00                	push   $0x0
  80110d:	e8 86 fb ff ff       	call   800c98 <sys_page_map>
  801112:	89 c7                	mov    %eax,%edi
  801114:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801117:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801119:	85 ff                	test   %edi,%edi
  80111b:	79 1d                	jns    80113a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80111d:	83 ec 08             	sub    $0x8,%esp
  801120:	53                   	push   %ebx
  801121:	6a 00                	push   $0x0
  801123:	e8 b2 fb ff ff       	call   800cda <sys_page_unmap>
	sys_page_unmap(0, nva);
  801128:	83 c4 08             	add    $0x8,%esp
  80112b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80112e:	6a 00                	push   $0x0
  801130:	e8 a5 fb ff ff       	call   800cda <sys_page_unmap>
	return r;
  801135:	83 c4 10             	add    $0x10,%esp
  801138:	89 f8                	mov    %edi,%eax
}
  80113a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113d:	5b                   	pop    %ebx
  80113e:	5e                   	pop    %esi
  80113f:	5f                   	pop    %edi
  801140:	5d                   	pop    %ebp
  801141:	c3                   	ret    

00801142 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801142:	55                   	push   %ebp
  801143:	89 e5                	mov    %esp,%ebp
  801145:	53                   	push   %ebx
  801146:	83 ec 14             	sub    $0x14,%esp
  801149:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80114c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80114f:	50                   	push   %eax
  801150:	53                   	push   %ebx
  801151:	e8 86 fd ff ff       	call   800edc <fd_lookup>
  801156:	83 c4 08             	add    $0x8,%esp
  801159:	89 c2                	mov    %eax,%edx
  80115b:	85 c0                	test   %eax,%eax
  80115d:	78 6d                	js     8011cc <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80115f:	83 ec 08             	sub    $0x8,%esp
  801162:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801165:	50                   	push   %eax
  801166:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801169:	ff 30                	pushl  (%eax)
  80116b:	e8 c2 fd ff ff       	call   800f32 <dev_lookup>
  801170:	83 c4 10             	add    $0x10,%esp
  801173:	85 c0                	test   %eax,%eax
  801175:	78 4c                	js     8011c3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801177:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80117a:	8b 42 08             	mov    0x8(%edx),%eax
  80117d:	83 e0 03             	and    $0x3,%eax
  801180:	83 f8 01             	cmp    $0x1,%eax
  801183:	75 21                	jne    8011a6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801185:	a1 04 40 80 00       	mov    0x804004,%eax
  80118a:	8b 40 50             	mov    0x50(%eax),%eax
  80118d:	83 ec 04             	sub    $0x4,%esp
  801190:	53                   	push   %ebx
  801191:	50                   	push   %eax
  801192:	68 ad 29 80 00       	push   $0x8029ad
  801197:	e8 31 f1 ff ff       	call   8002cd <cprintf>
		return -E_INVAL;
  80119c:	83 c4 10             	add    $0x10,%esp
  80119f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011a4:	eb 26                	jmp    8011cc <read+0x8a>
	}
	if (!dev->dev_read)
  8011a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a9:	8b 40 08             	mov    0x8(%eax),%eax
  8011ac:	85 c0                	test   %eax,%eax
  8011ae:	74 17                	je     8011c7 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8011b0:	83 ec 04             	sub    $0x4,%esp
  8011b3:	ff 75 10             	pushl  0x10(%ebp)
  8011b6:	ff 75 0c             	pushl  0xc(%ebp)
  8011b9:	52                   	push   %edx
  8011ba:	ff d0                	call   *%eax
  8011bc:	89 c2                	mov    %eax,%edx
  8011be:	83 c4 10             	add    $0x10,%esp
  8011c1:	eb 09                	jmp    8011cc <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c3:	89 c2                	mov    %eax,%edx
  8011c5:	eb 05                	jmp    8011cc <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011c7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8011cc:	89 d0                	mov    %edx,%eax
  8011ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011d1:	c9                   	leave  
  8011d2:	c3                   	ret    

008011d3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011d3:	55                   	push   %ebp
  8011d4:	89 e5                	mov    %esp,%ebp
  8011d6:	57                   	push   %edi
  8011d7:	56                   	push   %esi
  8011d8:	53                   	push   %ebx
  8011d9:	83 ec 0c             	sub    $0xc,%esp
  8011dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011df:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e7:	eb 21                	jmp    80120a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011e9:	83 ec 04             	sub    $0x4,%esp
  8011ec:	89 f0                	mov    %esi,%eax
  8011ee:	29 d8                	sub    %ebx,%eax
  8011f0:	50                   	push   %eax
  8011f1:	89 d8                	mov    %ebx,%eax
  8011f3:	03 45 0c             	add    0xc(%ebp),%eax
  8011f6:	50                   	push   %eax
  8011f7:	57                   	push   %edi
  8011f8:	e8 45 ff ff ff       	call   801142 <read>
		if (m < 0)
  8011fd:	83 c4 10             	add    $0x10,%esp
  801200:	85 c0                	test   %eax,%eax
  801202:	78 10                	js     801214 <readn+0x41>
			return m;
		if (m == 0)
  801204:	85 c0                	test   %eax,%eax
  801206:	74 0a                	je     801212 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801208:	01 c3                	add    %eax,%ebx
  80120a:	39 f3                	cmp    %esi,%ebx
  80120c:	72 db                	jb     8011e9 <readn+0x16>
  80120e:	89 d8                	mov    %ebx,%eax
  801210:	eb 02                	jmp    801214 <readn+0x41>
  801212:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801214:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801217:	5b                   	pop    %ebx
  801218:	5e                   	pop    %esi
  801219:	5f                   	pop    %edi
  80121a:	5d                   	pop    %ebp
  80121b:	c3                   	ret    

0080121c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80121c:	55                   	push   %ebp
  80121d:	89 e5                	mov    %esp,%ebp
  80121f:	53                   	push   %ebx
  801220:	83 ec 14             	sub    $0x14,%esp
  801223:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801226:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801229:	50                   	push   %eax
  80122a:	53                   	push   %ebx
  80122b:	e8 ac fc ff ff       	call   800edc <fd_lookup>
  801230:	83 c4 08             	add    $0x8,%esp
  801233:	89 c2                	mov    %eax,%edx
  801235:	85 c0                	test   %eax,%eax
  801237:	78 68                	js     8012a1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801239:	83 ec 08             	sub    $0x8,%esp
  80123c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123f:	50                   	push   %eax
  801240:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801243:	ff 30                	pushl  (%eax)
  801245:	e8 e8 fc ff ff       	call   800f32 <dev_lookup>
  80124a:	83 c4 10             	add    $0x10,%esp
  80124d:	85 c0                	test   %eax,%eax
  80124f:	78 47                	js     801298 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801251:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801254:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801258:	75 21                	jne    80127b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80125a:	a1 04 40 80 00       	mov    0x804004,%eax
  80125f:	8b 40 50             	mov    0x50(%eax),%eax
  801262:	83 ec 04             	sub    $0x4,%esp
  801265:	53                   	push   %ebx
  801266:	50                   	push   %eax
  801267:	68 c9 29 80 00       	push   $0x8029c9
  80126c:	e8 5c f0 ff ff       	call   8002cd <cprintf>
		return -E_INVAL;
  801271:	83 c4 10             	add    $0x10,%esp
  801274:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801279:	eb 26                	jmp    8012a1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80127b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80127e:	8b 52 0c             	mov    0xc(%edx),%edx
  801281:	85 d2                	test   %edx,%edx
  801283:	74 17                	je     80129c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801285:	83 ec 04             	sub    $0x4,%esp
  801288:	ff 75 10             	pushl  0x10(%ebp)
  80128b:	ff 75 0c             	pushl  0xc(%ebp)
  80128e:	50                   	push   %eax
  80128f:	ff d2                	call   *%edx
  801291:	89 c2                	mov    %eax,%edx
  801293:	83 c4 10             	add    $0x10,%esp
  801296:	eb 09                	jmp    8012a1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801298:	89 c2                	mov    %eax,%edx
  80129a:	eb 05                	jmp    8012a1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80129c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012a1:	89 d0                	mov    %edx,%eax
  8012a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a6:	c9                   	leave  
  8012a7:	c3                   	ret    

008012a8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012a8:	55                   	push   %ebp
  8012a9:	89 e5                	mov    %esp,%ebp
  8012ab:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ae:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012b1:	50                   	push   %eax
  8012b2:	ff 75 08             	pushl  0x8(%ebp)
  8012b5:	e8 22 fc ff ff       	call   800edc <fd_lookup>
  8012ba:	83 c4 08             	add    $0x8,%esp
  8012bd:	85 c0                	test   %eax,%eax
  8012bf:	78 0e                	js     8012cf <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012cf:	c9                   	leave  
  8012d0:	c3                   	ret    

008012d1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012d1:	55                   	push   %ebp
  8012d2:	89 e5                	mov    %esp,%ebp
  8012d4:	53                   	push   %ebx
  8012d5:	83 ec 14             	sub    $0x14,%esp
  8012d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012de:	50                   	push   %eax
  8012df:	53                   	push   %ebx
  8012e0:	e8 f7 fb ff ff       	call   800edc <fd_lookup>
  8012e5:	83 c4 08             	add    $0x8,%esp
  8012e8:	89 c2                	mov    %eax,%edx
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	78 65                	js     801353 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ee:	83 ec 08             	sub    $0x8,%esp
  8012f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f4:	50                   	push   %eax
  8012f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f8:	ff 30                	pushl  (%eax)
  8012fa:	e8 33 fc ff ff       	call   800f32 <dev_lookup>
  8012ff:	83 c4 10             	add    $0x10,%esp
  801302:	85 c0                	test   %eax,%eax
  801304:	78 44                	js     80134a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801306:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801309:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80130d:	75 21                	jne    801330 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80130f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801314:	8b 40 50             	mov    0x50(%eax),%eax
  801317:	83 ec 04             	sub    $0x4,%esp
  80131a:	53                   	push   %ebx
  80131b:	50                   	push   %eax
  80131c:	68 8c 29 80 00       	push   $0x80298c
  801321:	e8 a7 ef ff ff       	call   8002cd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801326:	83 c4 10             	add    $0x10,%esp
  801329:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80132e:	eb 23                	jmp    801353 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801330:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801333:	8b 52 18             	mov    0x18(%edx),%edx
  801336:	85 d2                	test   %edx,%edx
  801338:	74 14                	je     80134e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80133a:	83 ec 08             	sub    $0x8,%esp
  80133d:	ff 75 0c             	pushl  0xc(%ebp)
  801340:	50                   	push   %eax
  801341:	ff d2                	call   *%edx
  801343:	89 c2                	mov    %eax,%edx
  801345:	83 c4 10             	add    $0x10,%esp
  801348:	eb 09                	jmp    801353 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80134a:	89 c2                	mov    %eax,%edx
  80134c:	eb 05                	jmp    801353 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80134e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801353:	89 d0                	mov    %edx,%eax
  801355:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801358:	c9                   	leave  
  801359:	c3                   	ret    

0080135a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80135a:	55                   	push   %ebp
  80135b:	89 e5                	mov    %esp,%ebp
  80135d:	53                   	push   %ebx
  80135e:	83 ec 14             	sub    $0x14,%esp
  801361:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801364:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801367:	50                   	push   %eax
  801368:	ff 75 08             	pushl  0x8(%ebp)
  80136b:	e8 6c fb ff ff       	call   800edc <fd_lookup>
  801370:	83 c4 08             	add    $0x8,%esp
  801373:	89 c2                	mov    %eax,%edx
  801375:	85 c0                	test   %eax,%eax
  801377:	78 58                	js     8013d1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801379:	83 ec 08             	sub    $0x8,%esp
  80137c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137f:	50                   	push   %eax
  801380:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801383:	ff 30                	pushl  (%eax)
  801385:	e8 a8 fb ff ff       	call   800f32 <dev_lookup>
  80138a:	83 c4 10             	add    $0x10,%esp
  80138d:	85 c0                	test   %eax,%eax
  80138f:	78 37                	js     8013c8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801391:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801394:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801398:	74 32                	je     8013cc <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80139a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80139d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013a4:	00 00 00 
	stat->st_isdir = 0;
  8013a7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013ae:	00 00 00 
	stat->st_dev = dev;
  8013b1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013b7:	83 ec 08             	sub    $0x8,%esp
  8013ba:	53                   	push   %ebx
  8013bb:	ff 75 f0             	pushl  -0x10(%ebp)
  8013be:	ff 50 14             	call   *0x14(%eax)
  8013c1:	89 c2                	mov    %eax,%edx
  8013c3:	83 c4 10             	add    $0x10,%esp
  8013c6:	eb 09                	jmp    8013d1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c8:	89 c2                	mov    %eax,%edx
  8013ca:	eb 05                	jmp    8013d1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013cc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013d1:	89 d0                	mov    %edx,%eax
  8013d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d6:	c9                   	leave  
  8013d7:	c3                   	ret    

008013d8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013d8:	55                   	push   %ebp
  8013d9:	89 e5                	mov    %esp,%ebp
  8013db:	56                   	push   %esi
  8013dc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013dd:	83 ec 08             	sub    $0x8,%esp
  8013e0:	6a 00                	push   $0x0
  8013e2:	ff 75 08             	pushl  0x8(%ebp)
  8013e5:	e8 e3 01 00 00       	call   8015cd <open>
  8013ea:	89 c3                	mov    %eax,%ebx
  8013ec:	83 c4 10             	add    $0x10,%esp
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	78 1b                	js     80140e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013f3:	83 ec 08             	sub    $0x8,%esp
  8013f6:	ff 75 0c             	pushl  0xc(%ebp)
  8013f9:	50                   	push   %eax
  8013fa:	e8 5b ff ff ff       	call   80135a <fstat>
  8013ff:	89 c6                	mov    %eax,%esi
	close(fd);
  801401:	89 1c 24             	mov    %ebx,(%esp)
  801404:	e8 fd fb ff ff       	call   801006 <close>
	return r;
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	89 f0                	mov    %esi,%eax
}
  80140e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801411:	5b                   	pop    %ebx
  801412:	5e                   	pop    %esi
  801413:	5d                   	pop    %ebp
  801414:	c3                   	ret    

00801415 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
  801418:	56                   	push   %esi
  801419:	53                   	push   %ebx
  80141a:	89 c6                	mov    %eax,%esi
  80141c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80141e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801425:	75 12                	jne    801439 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801427:	83 ec 0c             	sub    $0xc,%esp
  80142a:	6a 01                	push   $0x1
  80142c:	e8 d8 0d 00 00       	call   802209 <ipc_find_env>
  801431:	a3 00 40 80 00       	mov    %eax,0x804000
  801436:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801439:	6a 07                	push   $0x7
  80143b:	68 00 50 80 00       	push   $0x805000
  801440:	56                   	push   %esi
  801441:	ff 35 00 40 80 00    	pushl  0x804000
  801447:	e8 5b 0d 00 00       	call   8021a7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80144c:	83 c4 0c             	add    $0xc,%esp
  80144f:	6a 00                	push   $0x0
  801451:	53                   	push   %ebx
  801452:	6a 00                	push   $0x0
  801454:	e8 d9 0c 00 00       	call   802132 <ipc_recv>
}
  801459:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80145c:	5b                   	pop    %ebx
  80145d:	5e                   	pop    %esi
  80145e:	5d                   	pop    %ebp
  80145f:	c3                   	ret    

00801460 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
  801463:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801466:	8b 45 08             	mov    0x8(%ebp),%eax
  801469:	8b 40 0c             	mov    0xc(%eax),%eax
  80146c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801471:	8b 45 0c             	mov    0xc(%ebp),%eax
  801474:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801479:	ba 00 00 00 00       	mov    $0x0,%edx
  80147e:	b8 02 00 00 00       	mov    $0x2,%eax
  801483:	e8 8d ff ff ff       	call   801415 <fsipc>
}
  801488:	c9                   	leave  
  801489:	c3                   	ret    

0080148a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80148a:	55                   	push   %ebp
  80148b:	89 e5                	mov    %esp,%ebp
  80148d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801490:	8b 45 08             	mov    0x8(%ebp),%eax
  801493:	8b 40 0c             	mov    0xc(%eax),%eax
  801496:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80149b:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a0:	b8 06 00 00 00       	mov    $0x6,%eax
  8014a5:	e8 6b ff ff ff       	call   801415 <fsipc>
}
  8014aa:	c9                   	leave  
  8014ab:	c3                   	ret    

008014ac <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014ac:	55                   	push   %ebp
  8014ad:	89 e5                	mov    %esp,%ebp
  8014af:	53                   	push   %ebx
  8014b0:	83 ec 04             	sub    $0x4,%esp
  8014b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b9:	8b 40 0c             	mov    0xc(%eax),%eax
  8014bc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c6:	b8 05 00 00 00       	mov    $0x5,%eax
  8014cb:	e8 45 ff ff ff       	call   801415 <fsipc>
  8014d0:	85 c0                	test   %eax,%eax
  8014d2:	78 2c                	js     801500 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014d4:	83 ec 08             	sub    $0x8,%esp
  8014d7:	68 00 50 80 00       	push   $0x805000
  8014dc:	53                   	push   %ebx
  8014dd:	e8 70 f3 ff ff       	call   800852 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014e2:	a1 80 50 80 00       	mov    0x805080,%eax
  8014e7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014ed:	a1 84 50 80 00       	mov    0x805084,%eax
  8014f2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014f8:	83 c4 10             	add    $0x10,%esp
  8014fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801500:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801503:	c9                   	leave  
  801504:	c3                   	ret    

00801505 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
  801508:	83 ec 0c             	sub    $0xc,%esp
  80150b:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80150e:	8b 55 08             	mov    0x8(%ebp),%edx
  801511:	8b 52 0c             	mov    0xc(%edx),%edx
  801514:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80151a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80151f:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801524:	0f 47 c2             	cmova  %edx,%eax
  801527:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80152c:	50                   	push   %eax
  80152d:	ff 75 0c             	pushl  0xc(%ebp)
  801530:	68 08 50 80 00       	push   $0x805008
  801535:	e8 aa f4 ff ff       	call   8009e4 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80153a:	ba 00 00 00 00       	mov    $0x0,%edx
  80153f:	b8 04 00 00 00       	mov    $0x4,%eax
  801544:	e8 cc fe ff ff       	call   801415 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801549:	c9                   	leave  
  80154a:	c3                   	ret    

0080154b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80154b:	55                   	push   %ebp
  80154c:	89 e5                	mov    %esp,%ebp
  80154e:	56                   	push   %esi
  80154f:	53                   	push   %ebx
  801550:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801553:	8b 45 08             	mov    0x8(%ebp),%eax
  801556:	8b 40 0c             	mov    0xc(%eax),%eax
  801559:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80155e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801564:	ba 00 00 00 00       	mov    $0x0,%edx
  801569:	b8 03 00 00 00       	mov    $0x3,%eax
  80156e:	e8 a2 fe ff ff       	call   801415 <fsipc>
  801573:	89 c3                	mov    %eax,%ebx
  801575:	85 c0                	test   %eax,%eax
  801577:	78 4b                	js     8015c4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801579:	39 c6                	cmp    %eax,%esi
  80157b:	73 16                	jae    801593 <devfile_read+0x48>
  80157d:	68 f8 29 80 00       	push   $0x8029f8
  801582:	68 ff 29 80 00       	push   $0x8029ff
  801587:	6a 7c                	push   $0x7c
  801589:	68 14 2a 80 00       	push   $0x802a14
  80158e:	e8 61 ec ff ff       	call   8001f4 <_panic>
	assert(r <= PGSIZE);
  801593:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801598:	7e 16                	jle    8015b0 <devfile_read+0x65>
  80159a:	68 1f 2a 80 00       	push   $0x802a1f
  80159f:	68 ff 29 80 00       	push   $0x8029ff
  8015a4:	6a 7d                	push   $0x7d
  8015a6:	68 14 2a 80 00       	push   $0x802a14
  8015ab:	e8 44 ec ff ff       	call   8001f4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015b0:	83 ec 04             	sub    $0x4,%esp
  8015b3:	50                   	push   %eax
  8015b4:	68 00 50 80 00       	push   $0x805000
  8015b9:	ff 75 0c             	pushl  0xc(%ebp)
  8015bc:	e8 23 f4 ff ff       	call   8009e4 <memmove>
	return r;
  8015c1:	83 c4 10             	add    $0x10,%esp
}
  8015c4:	89 d8                	mov    %ebx,%eax
  8015c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c9:	5b                   	pop    %ebx
  8015ca:	5e                   	pop    %esi
  8015cb:	5d                   	pop    %ebp
  8015cc:	c3                   	ret    

008015cd <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015cd:	55                   	push   %ebp
  8015ce:	89 e5                	mov    %esp,%ebp
  8015d0:	53                   	push   %ebx
  8015d1:	83 ec 20             	sub    $0x20,%esp
  8015d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015d7:	53                   	push   %ebx
  8015d8:	e8 3c f2 ff ff       	call   800819 <strlen>
  8015dd:	83 c4 10             	add    $0x10,%esp
  8015e0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015e5:	7f 67                	jg     80164e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015e7:	83 ec 0c             	sub    $0xc,%esp
  8015ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ed:	50                   	push   %eax
  8015ee:	e8 9a f8 ff ff       	call   800e8d <fd_alloc>
  8015f3:	83 c4 10             	add    $0x10,%esp
		return r;
  8015f6:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015f8:	85 c0                	test   %eax,%eax
  8015fa:	78 57                	js     801653 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015fc:	83 ec 08             	sub    $0x8,%esp
  8015ff:	53                   	push   %ebx
  801600:	68 00 50 80 00       	push   $0x805000
  801605:	e8 48 f2 ff ff       	call   800852 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80160a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80160d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801612:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801615:	b8 01 00 00 00       	mov    $0x1,%eax
  80161a:	e8 f6 fd ff ff       	call   801415 <fsipc>
  80161f:	89 c3                	mov    %eax,%ebx
  801621:	83 c4 10             	add    $0x10,%esp
  801624:	85 c0                	test   %eax,%eax
  801626:	79 14                	jns    80163c <open+0x6f>
		fd_close(fd, 0);
  801628:	83 ec 08             	sub    $0x8,%esp
  80162b:	6a 00                	push   $0x0
  80162d:	ff 75 f4             	pushl  -0xc(%ebp)
  801630:	e8 50 f9 ff ff       	call   800f85 <fd_close>
		return r;
  801635:	83 c4 10             	add    $0x10,%esp
  801638:	89 da                	mov    %ebx,%edx
  80163a:	eb 17                	jmp    801653 <open+0x86>
	}

	return fd2num(fd);
  80163c:	83 ec 0c             	sub    $0xc,%esp
  80163f:	ff 75 f4             	pushl  -0xc(%ebp)
  801642:	e8 1f f8 ff ff       	call   800e66 <fd2num>
  801647:	89 c2                	mov    %eax,%edx
  801649:	83 c4 10             	add    $0x10,%esp
  80164c:	eb 05                	jmp    801653 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80164e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801653:	89 d0                	mov    %edx,%eax
  801655:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801658:	c9                   	leave  
  801659:	c3                   	ret    

0080165a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801660:	ba 00 00 00 00       	mov    $0x0,%edx
  801665:	b8 08 00 00 00       	mov    $0x8,%eax
  80166a:	e8 a6 fd ff ff       	call   801415 <fsipc>
}
  80166f:	c9                   	leave  
  801670:	c3                   	ret    

00801671 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	57                   	push   %edi
  801675:	56                   	push   %esi
  801676:	53                   	push   %ebx
  801677:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80167d:	6a 00                	push   $0x0
  80167f:	ff 75 08             	pushl  0x8(%ebp)
  801682:	e8 46 ff ff ff       	call   8015cd <open>
  801687:	89 c7                	mov    %eax,%edi
  801689:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80168f:	83 c4 10             	add    $0x10,%esp
  801692:	85 c0                	test   %eax,%eax
  801694:	0f 88 89 04 00 00    	js     801b23 <spawn+0x4b2>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80169a:	83 ec 04             	sub    $0x4,%esp
  80169d:	68 00 02 00 00       	push   $0x200
  8016a2:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8016a8:	50                   	push   %eax
  8016a9:	57                   	push   %edi
  8016aa:	e8 24 fb ff ff       	call   8011d3 <readn>
  8016af:	83 c4 10             	add    $0x10,%esp
  8016b2:	3d 00 02 00 00       	cmp    $0x200,%eax
  8016b7:	75 0c                	jne    8016c5 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8016b9:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8016c0:	45 4c 46 
  8016c3:	74 33                	je     8016f8 <spawn+0x87>
		close(fd);
  8016c5:	83 ec 0c             	sub    $0xc,%esp
  8016c8:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8016ce:	e8 33 f9 ff ff       	call   801006 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8016d3:	83 c4 0c             	add    $0xc,%esp
  8016d6:	68 7f 45 4c 46       	push   $0x464c457f
  8016db:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8016e1:	68 2b 2a 80 00       	push   $0x802a2b
  8016e6:	e8 e2 eb ff ff       	call   8002cd <cprintf>
		return -E_NOT_EXEC;
  8016eb:	83 c4 10             	add    $0x10,%esp
  8016ee:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8016f3:	e9 de 04 00 00       	jmp    801bd6 <spawn+0x565>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8016f8:	b8 07 00 00 00       	mov    $0x7,%eax
  8016fd:	cd 30                	int    $0x30
  8016ff:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801705:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80170b:	85 c0                	test   %eax,%eax
  80170d:	0f 88 1b 04 00 00    	js     801b2e <spawn+0x4bd>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801713:	25 ff 03 00 00       	and    $0x3ff,%eax
  801718:	89 c2                	mov    %eax,%edx
  80171a:	c1 e2 07             	shl    $0x7,%edx
  80171d:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801723:	8d b4 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%esi
  80172a:	b9 11 00 00 00       	mov    $0x11,%ecx
  80172f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801731:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801737:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80173d:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801742:	be 00 00 00 00       	mov    $0x0,%esi
  801747:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80174a:	eb 13                	jmp    80175f <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  80174c:	83 ec 0c             	sub    $0xc,%esp
  80174f:	50                   	push   %eax
  801750:	e8 c4 f0 ff ff       	call   800819 <strlen>
  801755:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801759:	83 c3 01             	add    $0x1,%ebx
  80175c:	83 c4 10             	add    $0x10,%esp
  80175f:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801766:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801769:	85 c0                	test   %eax,%eax
  80176b:	75 df                	jne    80174c <spawn+0xdb>
  80176d:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801773:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801779:	bf 00 10 40 00       	mov    $0x401000,%edi
  80177e:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801780:	89 fa                	mov    %edi,%edx
  801782:	83 e2 fc             	and    $0xfffffffc,%edx
  801785:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80178c:	29 c2                	sub    %eax,%edx
  80178e:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801794:	8d 42 f8             	lea    -0x8(%edx),%eax
  801797:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80179c:	0f 86 a2 03 00 00    	jbe    801b44 <spawn+0x4d3>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8017a2:	83 ec 04             	sub    $0x4,%esp
  8017a5:	6a 07                	push   $0x7
  8017a7:	68 00 00 40 00       	push   $0x400000
  8017ac:	6a 00                	push   $0x0
  8017ae:	e8 a2 f4 ff ff       	call   800c55 <sys_page_alloc>
  8017b3:	83 c4 10             	add    $0x10,%esp
  8017b6:	85 c0                	test   %eax,%eax
  8017b8:	0f 88 90 03 00 00    	js     801b4e <spawn+0x4dd>
  8017be:	be 00 00 00 00       	mov    $0x0,%esi
  8017c3:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8017c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017cc:	eb 30                	jmp    8017fe <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8017ce:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8017d4:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8017da:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  8017dd:	83 ec 08             	sub    $0x8,%esp
  8017e0:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8017e3:	57                   	push   %edi
  8017e4:	e8 69 f0 ff ff       	call   800852 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8017e9:	83 c4 04             	add    $0x4,%esp
  8017ec:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8017ef:	e8 25 f0 ff ff       	call   800819 <strlen>
  8017f4:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8017f8:	83 c6 01             	add    $0x1,%esi
  8017fb:	83 c4 10             	add    $0x10,%esp
  8017fe:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801804:	7f c8                	jg     8017ce <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801806:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80180c:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801812:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801819:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80181f:	74 19                	je     80183a <spawn+0x1c9>
  801821:	68 b8 2a 80 00       	push   $0x802ab8
  801826:	68 ff 29 80 00       	push   $0x8029ff
  80182b:	68 f2 00 00 00       	push   $0xf2
  801830:	68 45 2a 80 00       	push   $0x802a45
  801835:	e8 ba e9 ff ff       	call   8001f4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80183a:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801840:	89 f8                	mov    %edi,%eax
  801842:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801847:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  80184a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801850:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801853:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801859:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80185f:	83 ec 0c             	sub    $0xc,%esp
  801862:	6a 07                	push   $0x7
  801864:	68 00 d0 bf ee       	push   $0xeebfd000
  801869:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80186f:	68 00 00 40 00       	push   $0x400000
  801874:	6a 00                	push   $0x0
  801876:	e8 1d f4 ff ff       	call   800c98 <sys_page_map>
  80187b:	89 c3                	mov    %eax,%ebx
  80187d:	83 c4 20             	add    $0x20,%esp
  801880:	85 c0                	test   %eax,%eax
  801882:	0f 88 3c 03 00 00    	js     801bc4 <spawn+0x553>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801888:	83 ec 08             	sub    $0x8,%esp
  80188b:	68 00 00 40 00       	push   $0x400000
  801890:	6a 00                	push   $0x0
  801892:	e8 43 f4 ff ff       	call   800cda <sys_page_unmap>
  801897:	89 c3                	mov    %eax,%ebx
  801899:	83 c4 10             	add    $0x10,%esp
  80189c:	85 c0                	test   %eax,%eax
  80189e:	0f 88 20 03 00 00    	js     801bc4 <spawn+0x553>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8018a4:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8018aa:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8018b1:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8018b7:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  8018be:	00 00 00 
  8018c1:	e9 88 01 00 00       	jmp    801a4e <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  8018c6:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8018cc:	83 38 01             	cmpl   $0x1,(%eax)
  8018cf:	0f 85 6b 01 00 00    	jne    801a40 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8018d5:	89 c2                	mov    %eax,%edx
  8018d7:	8b 40 18             	mov    0x18(%eax),%eax
  8018da:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8018e0:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8018e3:	83 f8 01             	cmp    $0x1,%eax
  8018e6:	19 c0                	sbb    %eax,%eax
  8018e8:	83 e0 fe             	and    $0xfffffffe,%eax
  8018eb:	83 c0 07             	add    $0x7,%eax
  8018ee:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8018f4:	89 d0                	mov    %edx,%eax
  8018f6:	8b 7a 04             	mov    0x4(%edx),%edi
  8018f9:	89 f9                	mov    %edi,%ecx
  8018fb:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801901:	8b 7a 10             	mov    0x10(%edx),%edi
  801904:	8b 52 14             	mov    0x14(%edx),%edx
  801907:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  80190d:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801910:	89 f0                	mov    %esi,%eax
  801912:	25 ff 0f 00 00       	and    $0xfff,%eax
  801917:	74 14                	je     80192d <spawn+0x2bc>
		va -= i;
  801919:	29 c6                	sub    %eax,%esi
		memsz += i;
  80191b:	01 c2                	add    %eax,%edx
  80191d:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801923:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801925:	29 c1                	sub    %eax,%ecx
  801927:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80192d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801932:	e9 f7 00 00 00       	jmp    801a2e <spawn+0x3bd>
		if (i >= filesz) {
  801937:	39 fb                	cmp    %edi,%ebx
  801939:	72 27                	jb     801962 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  80193b:	83 ec 04             	sub    $0x4,%esp
  80193e:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801944:	56                   	push   %esi
  801945:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80194b:	e8 05 f3 ff ff       	call   800c55 <sys_page_alloc>
  801950:	83 c4 10             	add    $0x10,%esp
  801953:	85 c0                	test   %eax,%eax
  801955:	0f 89 c7 00 00 00    	jns    801a22 <spawn+0x3b1>
  80195b:	89 c3                	mov    %eax,%ebx
  80195d:	e9 fd 01 00 00       	jmp    801b5f <spawn+0x4ee>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801962:	83 ec 04             	sub    $0x4,%esp
  801965:	6a 07                	push   $0x7
  801967:	68 00 00 40 00       	push   $0x400000
  80196c:	6a 00                	push   $0x0
  80196e:	e8 e2 f2 ff ff       	call   800c55 <sys_page_alloc>
  801973:	83 c4 10             	add    $0x10,%esp
  801976:	85 c0                	test   %eax,%eax
  801978:	0f 88 d7 01 00 00    	js     801b55 <spawn+0x4e4>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80197e:	83 ec 08             	sub    $0x8,%esp
  801981:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801987:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  80198d:	50                   	push   %eax
  80198e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801994:	e8 0f f9 ff ff       	call   8012a8 <seek>
  801999:	83 c4 10             	add    $0x10,%esp
  80199c:	85 c0                	test   %eax,%eax
  80199e:	0f 88 b5 01 00 00    	js     801b59 <spawn+0x4e8>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8019a4:	83 ec 04             	sub    $0x4,%esp
  8019a7:	89 f8                	mov    %edi,%eax
  8019a9:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  8019af:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019b4:	ba 00 10 00 00       	mov    $0x1000,%edx
  8019b9:	0f 47 c2             	cmova  %edx,%eax
  8019bc:	50                   	push   %eax
  8019bd:	68 00 00 40 00       	push   $0x400000
  8019c2:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019c8:	e8 06 f8 ff ff       	call   8011d3 <readn>
  8019cd:	83 c4 10             	add    $0x10,%esp
  8019d0:	85 c0                	test   %eax,%eax
  8019d2:	0f 88 85 01 00 00    	js     801b5d <spawn+0x4ec>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8019d8:	83 ec 0c             	sub    $0xc,%esp
  8019db:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8019e1:	56                   	push   %esi
  8019e2:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8019e8:	68 00 00 40 00       	push   $0x400000
  8019ed:	6a 00                	push   $0x0
  8019ef:	e8 a4 f2 ff ff       	call   800c98 <sys_page_map>
  8019f4:	83 c4 20             	add    $0x20,%esp
  8019f7:	85 c0                	test   %eax,%eax
  8019f9:	79 15                	jns    801a10 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  8019fb:	50                   	push   %eax
  8019fc:	68 51 2a 80 00       	push   $0x802a51
  801a01:	68 25 01 00 00       	push   $0x125
  801a06:	68 45 2a 80 00       	push   $0x802a45
  801a0b:	e8 e4 e7 ff ff       	call   8001f4 <_panic>
			sys_page_unmap(0, UTEMP);
  801a10:	83 ec 08             	sub    $0x8,%esp
  801a13:	68 00 00 40 00       	push   $0x400000
  801a18:	6a 00                	push   $0x0
  801a1a:	e8 bb f2 ff ff       	call   800cda <sys_page_unmap>
  801a1f:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801a22:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a28:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801a2e:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801a34:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801a3a:	0f 82 f7 fe ff ff    	jb     801937 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801a40:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801a47:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801a4e:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801a55:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801a5b:	0f 8c 65 fe ff ff    	jl     8018c6 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801a61:	83 ec 0c             	sub    $0xc,%esp
  801a64:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a6a:	e8 97 f5 ff ff       	call   801006 <close>
  801a6f:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801a72:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a77:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801a7d:	89 d8                	mov    %ebx,%eax
  801a7f:	c1 e8 16             	shr    $0x16,%eax
  801a82:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a89:	a8 01                	test   $0x1,%al
  801a8b:	74 42                	je     801acf <spawn+0x45e>
  801a8d:	89 d8                	mov    %ebx,%eax
  801a8f:	c1 e8 0c             	shr    $0xc,%eax
  801a92:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a99:	f6 c2 01             	test   $0x1,%dl
  801a9c:	74 31                	je     801acf <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  801a9e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801aa5:	f6 c6 04             	test   $0x4,%dh
  801aa8:	74 25                	je     801acf <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  801aaa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ab1:	83 ec 0c             	sub    $0xc,%esp
  801ab4:	25 07 0e 00 00       	and    $0xe07,%eax
  801ab9:	50                   	push   %eax
  801aba:	53                   	push   %ebx
  801abb:	56                   	push   %esi
  801abc:	53                   	push   %ebx
  801abd:	6a 00                	push   $0x0
  801abf:	e8 d4 f1 ff ff       	call   800c98 <sys_page_map>
			if (r < 0) {
  801ac4:	83 c4 20             	add    $0x20,%esp
  801ac7:	85 c0                	test   %eax,%eax
  801ac9:	0f 88 b1 00 00 00    	js     801b80 <spawn+0x50f>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801acf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801ad5:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801adb:	75 a0                	jne    801a7d <spawn+0x40c>
  801add:	e9 b3 00 00 00       	jmp    801b95 <spawn+0x524>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801ae2:	50                   	push   %eax
  801ae3:	68 6e 2a 80 00       	push   $0x802a6e
  801ae8:	68 86 00 00 00       	push   $0x86
  801aed:	68 45 2a 80 00       	push   $0x802a45
  801af2:	e8 fd e6 ff ff       	call   8001f4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801af7:	83 ec 08             	sub    $0x8,%esp
  801afa:	6a 02                	push   $0x2
  801afc:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b02:	e8 15 f2 ff ff       	call   800d1c <sys_env_set_status>
  801b07:	83 c4 10             	add    $0x10,%esp
  801b0a:	85 c0                	test   %eax,%eax
  801b0c:	79 2b                	jns    801b39 <spawn+0x4c8>
		panic("sys_env_set_status: %e", r);
  801b0e:	50                   	push   %eax
  801b0f:	68 88 2a 80 00       	push   $0x802a88
  801b14:	68 89 00 00 00       	push   $0x89
  801b19:	68 45 2a 80 00       	push   $0x802a45
  801b1e:	e8 d1 e6 ff ff       	call   8001f4 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801b23:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801b29:	e9 a8 00 00 00       	jmp    801bd6 <spawn+0x565>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801b2e:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801b34:	e9 9d 00 00 00       	jmp    801bd6 <spawn+0x565>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801b39:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801b3f:	e9 92 00 00 00       	jmp    801bd6 <spawn+0x565>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801b44:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801b49:	e9 88 00 00 00       	jmp    801bd6 <spawn+0x565>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801b4e:	89 c3                	mov    %eax,%ebx
  801b50:	e9 81 00 00 00       	jmp    801bd6 <spawn+0x565>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b55:	89 c3                	mov    %eax,%ebx
  801b57:	eb 06                	jmp    801b5f <spawn+0x4ee>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b59:	89 c3                	mov    %eax,%ebx
  801b5b:	eb 02                	jmp    801b5f <spawn+0x4ee>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801b5d:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801b5f:	83 ec 0c             	sub    $0xc,%esp
  801b62:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b68:	e8 69 f0 ff ff       	call   800bd6 <sys_env_destroy>
	close(fd);
  801b6d:	83 c4 04             	add    $0x4,%esp
  801b70:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801b76:	e8 8b f4 ff ff       	call   801006 <close>
	return r;
  801b7b:	83 c4 10             	add    $0x10,%esp
  801b7e:	eb 56                	jmp    801bd6 <spawn+0x565>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801b80:	50                   	push   %eax
  801b81:	68 9f 2a 80 00       	push   $0x802a9f
  801b86:	68 82 00 00 00       	push   $0x82
  801b8b:	68 45 2a 80 00       	push   $0x802a45
  801b90:	e8 5f e6 ff ff       	call   8001f4 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801b95:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801b9c:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801b9f:	83 ec 08             	sub    $0x8,%esp
  801ba2:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801ba8:	50                   	push   %eax
  801ba9:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801baf:	e8 aa f1 ff ff       	call   800d5e <sys_env_set_trapframe>
  801bb4:	83 c4 10             	add    $0x10,%esp
  801bb7:	85 c0                	test   %eax,%eax
  801bb9:	0f 89 38 ff ff ff    	jns    801af7 <spawn+0x486>
  801bbf:	e9 1e ff ff ff       	jmp    801ae2 <spawn+0x471>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801bc4:	83 ec 08             	sub    $0x8,%esp
  801bc7:	68 00 00 40 00       	push   $0x400000
  801bcc:	6a 00                	push   $0x0
  801bce:	e8 07 f1 ff ff       	call   800cda <sys_page_unmap>
  801bd3:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801bd6:	89 d8                	mov    %ebx,%eax
  801bd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bdb:	5b                   	pop    %ebx
  801bdc:	5e                   	pop    %esi
  801bdd:	5f                   	pop    %edi
  801bde:	5d                   	pop    %ebp
  801bdf:	c3                   	ret    

00801be0 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801be0:	55                   	push   %ebp
  801be1:	89 e5                	mov    %esp,%ebp
  801be3:	56                   	push   %esi
  801be4:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801be5:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801be8:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801bed:	eb 03                	jmp    801bf2 <spawnl+0x12>
		argc++;
  801bef:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801bf2:	83 c2 04             	add    $0x4,%edx
  801bf5:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801bf9:	75 f4                	jne    801bef <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801bfb:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801c02:	83 e2 f0             	and    $0xfffffff0,%edx
  801c05:	29 d4                	sub    %edx,%esp
  801c07:	8d 54 24 03          	lea    0x3(%esp),%edx
  801c0b:	c1 ea 02             	shr    $0x2,%edx
  801c0e:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801c15:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801c17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c1a:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801c21:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801c28:	00 
  801c29:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801c2b:	b8 00 00 00 00       	mov    $0x0,%eax
  801c30:	eb 0a                	jmp    801c3c <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801c32:	83 c0 01             	add    $0x1,%eax
  801c35:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801c39:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801c3c:	39 d0                	cmp    %edx,%eax
  801c3e:	75 f2                	jne    801c32 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801c40:	83 ec 08             	sub    $0x8,%esp
  801c43:	56                   	push   %esi
  801c44:	ff 75 08             	pushl  0x8(%ebp)
  801c47:	e8 25 fa ff ff       	call   801671 <spawn>
}
  801c4c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c4f:	5b                   	pop    %ebx
  801c50:	5e                   	pop    %esi
  801c51:	5d                   	pop    %ebp
  801c52:	c3                   	ret    

00801c53 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c53:	55                   	push   %ebp
  801c54:	89 e5                	mov    %esp,%ebp
  801c56:	56                   	push   %esi
  801c57:	53                   	push   %ebx
  801c58:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c5b:	83 ec 0c             	sub    $0xc,%esp
  801c5e:	ff 75 08             	pushl  0x8(%ebp)
  801c61:	e8 10 f2 ff ff       	call   800e76 <fd2data>
  801c66:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c68:	83 c4 08             	add    $0x8,%esp
  801c6b:	68 e0 2a 80 00       	push   $0x802ae0
  801c70:	53                   	push   %ebx
  801c71:	e8 dc eb ff ff       	call   800852 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c76:	8b 46 04             	mov    0x4(%esi),%eax
  801c79:	2b 06                	sub    (%esi),%eax
  801c7b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c81:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c88:	00 00 00 
	stat->st_dev = &devpipe;
  801c8b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c92:	30 80 00 
	return 0;
}
  801c95:	b8 00 00 00 00       	mov    $0x0,%eax
  801c9a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c9d:	5b                   	pop    %ebx
  801c9e:	5e                   	pop    %esi
  801c9f:	5d                   	pop    %ebp
  801ca0:	c3                   	ret    

00801ca1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ca1:	55                   	push   %ebp
  801ca2:	89 e5                	mov    %esp,%ebp
  801ca4:	53                   	push   %ebx
  801ca5:	83 ec 0c             	sub    $0xc,%esp
  801ca8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cab:	53                   	push   %ebx
  801cac:	6a 00                	push   $0x0
  801cae:	e8 27 f0 ff ff       	call   800cda <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cb3:	89 1c 24             	mov    %ebx,(%esp)
  801cb6:	e8 bb f1 ff ff       	call   800e76 <fd2data>
  801cbb:	83 c4 08             	add    $0x8,%esp
  801cbe:	50                   	push   %eax
  801cbf:	6a 00                	push   $0x0
  801cc1:	e8 14 f0 ff ff       	call   800cda <sys_page_unmap>
}
  801cc6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cc9:	c9                   	leave  
  801cca:	c3                   	ret    

00801ccb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ccb:	55                   	push   %ebp
  801ccc:	89 e5                	mov    %esp,%ebp
  801cce:	57                   	push   %edi
  801ccf:	56                   	push   %esi
  801cd0:	53                   	push   %ebx
  801cd1:	83 ec 1c             	sub    $0x1c,%esp
  801cd4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801cd7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801cd9:	a1 04 40 80 00       	mov    0x804004,%eax
  801cde:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ce1:	83 ec 0c             	sub    $0xc,%esp
  801ce4:	ff 75 e0             	pushl  -0x20(%ebp)
  801ce7:	e8 5d 05 00 00       	call   802249 <pageref>
  801cec:	89 c3                	mov    %eax,%ebx
  801cee:	89 3c 24             	mov    %edi,(%esp)
  801cf1:	e8 53 05 00 00       	call   802249 <pageref>
  801cf6:	83 c4 10             	add    $0x10,%esp
  801cf9:	39 c3                	cmp    %eax,%ebx
  801cfb:	0f 94 c1             	sete   %cl
  801cfe:	0f b6 c9             	movzbl %cl,%ecx
  801d01:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d04:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d0a:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  801d0d:	39 ce                	cmp    %ecx,%esi
  801d0f:	74 1b                	je     801d2c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801d11:	39 c3                	cmp    %eax,%ebx
  801d13:	75 c4                	jne    801cd9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d15:	8b 42 60             	mov    0x60(%edx),%eax
  801d18:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d1b:	50                   	push   %eax
  801d1c:	56                   	push   %esi
  801d1d:	68 e7 2a 80 00       	push   $0x802ae7
  801d22:	e8 a6 e5 ff ff       	call   8002cd <cprintf>
  801d27:	83 c4 10             	add    $0x10,%esp
  801d2a:	eb ad                	jmp    801cd9 <_pipeisclosed+0xe>
	}
}
  801d2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d32:	5b                   	pop    %ebx
  801d33:	5e                   	pop    %esi
  801d34:	5f                   	pop    %edi
  801d35:	5d                   	pop    %ebp
  801d36:	c3                   	ret    

00801d37 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d37:	55                   	push   %ebp
  801d38:	89 e5                	mov    %esp,%ebp
  801d3a:	57                   	push   %edi
  801d3b:	56                   	push   %esi
  801d3c:	53                   	push   %ebx
  801d3d:	83 ec 28             	sub    $0x28,%esp
  801d40:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d43:	56                   	push   %esi
  801d44:	e8 2d f1 ff ff       	call   800e76 <fd2data>
  801d49:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d4b:	83 c4 10             	add    $0x10,%esp
  801d4e:	bf 00 00 00 00       	mov    $0x0,%edi
  801d53:	eb 4b                	jmp    801da0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d55:	89 da                	mov    %ebx,%edx
  801d57:	89 f0                	mov    %esi,%eax
  801d59:	e8 6d ff ff ff       	call   801ccb <_pipeisclosed>
  801d5e:	85 c0                	test   %eax,%eax
  801d60:	75 48                	jne    801daa <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d62:	e8 cf ee ff ff       	call   800c36 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d67:	8b 43 04             	mov    0x4(%ebx),%eax
  801d6a:	8b 0b                	mov    (%ebx),%ecx
  801d6c:	8d 51 20             	lea    0x20(%ecx),%edx
  801d6f:	39 d0                	cmp    %edx,%eax
  801d71:	73 e2                	jae    801d55 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d76:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d7a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d7d:	89 c2                	mov    %eax,%edx
  801d7f:	c1 fa 1f             	sar    $0x1f,%edx
  801d82:	89 d1                	mov    %edx,%ecx
  801d84:	c1 e9 1b             	shr    $0x1b,%ecx
  801d87:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d8a:	83 e2 1f             	and    $0x1f,%edx
  801d8d:	29 ca                	sub    %ecx,%edx
  801d8f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d93:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d97:	83 c0 01             	add    $0x1,%eax
  801d9a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d9d:	83 c7 01             	add    $0x1,%edi
  801da0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801da3:	75 c2                	jne    801d67 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801da5:	8b 45 10             	mov    0x10(%ebp),%eax
  801da8:	eb 05                	jmp    801daf <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801daa:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801daf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801db2:	5b                   	pop    %ebx
  801db3:	5e                   	pop    %esi
  801db4:	5f                   	pop    %edi
  801db5:	5d                   	pop    %ebp
  801db6:	c3                   	ret    

00801db7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801db7:	55                   	push   %ebp
  801db8:	89 e5                	mov    %esp,%ebp
  801dba:	57                   	push   %edi
  801dbb:	56                   	push   %esi
  801dbc:	53                   	push   %ebx
  801dbd:	83 ec 18             	sub    $0x18,%esp
  801dc0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801dc3:	57                   	push   %edi
  801dc4:	e8 ad f0 ff ff       	call   800e76 <fd2data>
  801dc9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dcb:	83 c4 10             	add    $0x10,%esp
  801dce:	bb 00 00 00 00       	mov    $0x0,%ebx
  801dd3:	eb 3d                	jmp    801e12 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801dd5:	85 db                	test   %ebx,%ebx
  801dd7:	74 04                	je     801ddd <devpipe_read+0x26>
				return i;
  801dd9:	89 d8                	mov    %ebx,%eax
  801ddb:	eb 44                	jmp    801e21 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ddd:	89 f2                	mov    %esi,%edx
  801ddf:	89 f8                	mov    %edi,%eax
  801de1:	e8 e5 fe ff ff       	call   801ccb <_pipeisclosed>
  801de6:	85 c0                	test   %eax,%eax
  801de8:	75 32                	jne    801e1c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801dea:	e8 47 ee ff ff       	call   800c36 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801def:	8b 06                	mov    (%esi),%eax
  801df1:	3b 46 04             	cmp    0x4(%esi),%eax
  801df4:	74 df                	je     801dd5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801df6:	99                   	cltd   
  801df7:	c1 ea 1b             	shr    $0x1b,%edx
  801dfa:	01 d0                	add    %edx,%eax
  801dfc:	83 e0 1f             	and    $0x1f,%eax
  801dff:	29 d0                	sub    %edx,%eax
  801e01:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e09:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e0c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e0f:	83 c3 01             	add    $0x1,%ebx
  801e12:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e15:	75 d8                	jne    801def <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e17:	8b 45 10             	mov    0x10(%ebp),%eax
  801e1a:	eb 05                	jmp    801e21 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e1c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e24:	5b                   	pop    %ebx
  801e25:	5e                   	pop    %esi
  801e26:	5f                   	pop    %edi
  801e27:	5d                   	pop    %ebp
  801e28:	c3                   	ret    

00801e29 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e29:	55                   	push   %ebp
  801e2a:	89 e5                	mov    %esp,%ebp
  801e2c:	56                   	push   %esi
  801e2d:	53                   	push   %ebx
  801e2e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e34:	50                   	push   %eax
  801e35:	e8 53 f0 ff ff       	call   800e8d <fd_alloc>
  801e3a:	83 c4 10             	add    $0x10,%esp
  801e3d:	89 c2                	mov    %eax,%edx
  801e3f:	85 c0                	test   %eax,%eax
  801e41:	0f 88 2c 01 00 00    	js     801f73 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e47:	83 ec 04             	sub    $0x4,%esp
  801e4a:	68 07 04 00 00       	push   $0x407
  801e4f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e52:	6a 00                	push   $0x0
  801e54:	e8 fc ed ff ff       	call   800c55 <sys_page_alloc>
  801e59:	83 c4 10             	add    $0x10,%esp
  801e5c:	89 c2                	mov    %eax,%edx
  801e5e:	85 c0                	test   %eax,%eax
  801e60:	0f 88 0d 01 00 00    	js     801f73 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e66:	83 ec 0c             	sub    $0xc,%esp
  801e69:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e6c:	50                   	push   %eax
  801e6d:	e8 1b f0 ff ff       	call   800e8d <fd_alloc>
  801e72:	89 c3                	mov    %eax,%ebx
  801e74:	83 c4 10             	add    $0x10,%esp
  801e77:	85 c0                	test   %eax,%eax
  801e79:	0f 88 e2 00 00 00    	js     801f61 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e7f:	83 ec 04             	sub    $0x4,%esp
  801e82:	68 07 04 00 00       	push   $0x407
  801e87:	ff 75 f0             	pushl  -0x10(%ebp)
  801e8a:	6a 00                	push   $0x0
  801e8c:	e8 c4 ed ff ff       	call   800c55 <sys_page_alloc>
  801e91:	89 c3                	mov    %eax,%ebx
  801e93:	83 c4 10             	add    $0x10,%esp
  801e96:	85 c0                	test   %eax,%eax
  801e98:	0f 88 c3 00 00 00    	js     801f61 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e9e:	83 ec 0c             	sub    $0xc,%esp
  801ea1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ea4:	e8 cd ef ff ff       	call   800e76 <fd2data>
  801ea9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eab:	83 c4 0c             	add    $0xc,%esp
  801eae:	68 07 04 00 00       	push   $0x407
  801eb3:	50                   	push   %eax
  801eb4:	6a 00                	push   $0x0
  801eb6:	e8 9a ed ff ff       	call   800c55 <sys_page_alloc>
  801ebb:	89 c3                	mov    %eax,%ebx
  801ebd:	83 c4 10             	add    $0x10,%esp
  801ec0:	85 c0                	test   %eax,%eax
  801ec2:	0f 88 89 00 00 00    	js     801f51 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ec8:	83 ec 0c             	sub    $0xc,%esp
  801ecb:	ff 75 f0             	pushl  -0x10(%ebp)
  801ece:	e8 a3 ef ff ff       	call   800e76 <fd2data>
  801ed3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801eda:	50                   	push   %eax
  801edb:	6a 00                	push   $0x0
  801edd:	56                   	push   %esi
  801ede:	6a 00                	push   $0x0
  801ee0:	e8 b3 ed ff ff       	call   800c98 <sys_page_map>
  801ee5:	89 c3                	mov    %eax,%ebx
  801ee7:	83 c4 20             	add    $0x20,%esp
  801eea:	85 c0                	test   %eax,%eax
  801eec:	78 55                	js     801f43 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801eee:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ef4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801efc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f03:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f0c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f11:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f18:	83 ec 0c             	sub    $0xc,%esp
  801f1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801f1e:	e8 43 ef ff ff       	call   800e66 <fd2num>
  801f23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f26:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f28:	83 c4 04             	add    $0x4,%esp
  801f2b:	ff 75 f0             	pushl  -0x10(%ebp)
  801f2e:	e8 33 ef ff ff       	call   800e66 <fd2num>
  801f33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f36:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801f39:	83 c4 10             	add    $0x10,%esp
  801f3c:	ba 00 00 00 00       	mov    $0x0,%edx
  801f41:	eb 30                	jmp    801f73 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f43:	83 ec 08             	sub    $0x8,%esp
  801f46:	56                   	push   %esi
  801f47:	6a 00                	push   $0x0
  801f49:	e8 8c ed ff ff       	call   800cda <sys_page_unmap>
  801f4e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f51:	83 ec 08             	sub    $0x8,%esp
  801f54:	ff 75 f0             	pushl  -0x10(%ebp)
  801f57:	6a 00                	push   $0x0
  801f59:	e8 7c ed ff ff       	call   800cda <sys_page_unmap>
  801f5e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f61:	83 ec 08             	sub    $0x8,%esp
  801f64:	ff 75 f4             	pushl  -0xc(%ebp)
  801f67:	6a 00                	push   $0x0
  801f69:	e8 6c ed ff ff       	call   800cda <sys_page_unmap>
  801f6e:	83 c4 10             	add    $0x10,%esp
  801f71:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f73:	89 d0                	mov    %edx,%eax
  801f75:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f78:	5b                   	pop    %ebx
  801f79:	5e                   	pop    %esi
  801f7a:	5d                   	pop    %ebp
  801f7b:	c3                   	ret    

00801f7c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f7c:	55                   	push   %ebp
  801f7d:	89 e5                	mov    %esp,%ebp
  801f7f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f82:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f85:	50                   	push   %eax
  801f86:	ff 75 08             	pushl  0x8(%ebp)
  801f89:	e8 4e ef ff ff       	call   800edc <fd_lookup>
  801f8e:	83 c4 10             	add    $0x10,%esp
  801f91:	85 c0                	test   %eax,%eax
  801f93:	78 18                	js     801fad <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f95:	83 ec 0c             	sub    $0xc,%esp
  801f98:	ff 75 f4             	pushl  -0xc(%ebp)
  801f9b:	e8 d6 ee ff ff       	call   800e76 <fd2data>
	return _pipeisclosed(fd, p);
  801fa0:	89 c2                	mov    %eax,%edx
  801fa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa5:	e8 21 fd ff ff       	call   801ccb <_pipeisclosed>
  801faa:	83 c4 10             	add    $0x10,%esp
}
  801fad:	c9                   	leave  
  801fae:	c3                   	ret    

00801faf <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801faf:	55                   	push   %ebp
  801fb0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fb2:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb7:	5d                   	pop    %ebp
  801fb8:	c3                   	ret    

00801fb9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fb9:	55                   	push   %ebp
  801fba:	89 e5                	mov    %esp,%ebp
  801fbc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801fbf:	68 ff 2a 80 00       	push   $0x802aff
  801fc4:	ff 75 0c             	pushl  0xc(%ebp)
  801fc7:	e8 86 e8 ff ff       	call   800852 <strcpy>
	return 0;
}
  801fcc:	b8 00 00 00 00       	mov    $0x0,%eax
  801fd1:	c9                   	leave  
  801fd2:	c3                   	ret    

00801fd3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fd3:	55                   	push   %ebp
  801fd4:	89 e5                	mov    %esp,%ebp
  801fd6:	57                   	push   %edi
  801fd7:	56                   	push   %esi
  801fd8:	53                   	push   %ebx
  801fd9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fdf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fe4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fea:	eb 2d                	jmp    802019 <devcons_write+0x46>
		m = n - tot;
  801fec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fef:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ff1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ff4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ff9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ffc:	83 ec 04             	sub    $0x4,%esp
  801fff:	53                   	push   %ebx
  802000:	03 45 0c             	add    0xc(%ebp),%eax
  802003:	50                   	push   %eax
  802004:	57                   	push   %edi
  802005:	e8 da e9 ff ff       	call   8009e4 <memmove>
		sys_cputs(buf, m);
  80200a:	83 c4 08             	add    $0x8,%esp
  80200d:	53                   	push   %ebx
  80200e:	57                   	push   %edi
  80200f:	e8 85 eb ff ff       	call   800b99 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802014:	01 de                	add    %ebx,%esi
  802016:	83 c4 10             	add    $0x10,%esp
  802019:	89 f0                	mov    %esi,%eax
  80201b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80201e:	72 cc                	jb     801fec <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802020:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802023:	5b                   	pop    %ebx
  802024:	5e                   	pop    %esi
  802025:	5f                   	pop    %edi
  802026:	5d                   	pop    %ebp
  802027:	c3                   	ret    

00802028 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802028:	55                   	push   %ebp
  802029:	89 e5                	mov    %esp,%ebp
  80202b:	83 ec 08             	sub    $0x8,%esp
  80202e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802033:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802037:	74 2a                	je     802063 <devcons_read+0x3b>
  802039:	eb 05                	jmp    802040 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80203b:	e8 f6 eb ff ff       	call   800c36 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802040:	e8 72 eb ff ff       	call   800bb7 <sys_cgetc>
  802045:	85 c0                	test   %eax,%eax
  802047:	74 f2                	je     80203b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802049:	85 c0                	test   %eax,%eax
  80204b:	78 16                	js     802063 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80204d:	83 f8 04             	cmp    $0x4,%eax
  802050:	74 0c                	je     80205e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802052:	8b 55 0c             	mov    0xc(%ebp),%edx
  802055:	88 02                	mov    %al,(%edx)
	return 1;
  802057:	b8 01 00 00 00       	mov    $0x1,%eax
  80205c:	eb 05                	jmp    802063 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80205e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802063:	c9                   	leave  
  802064:	c3                   	ret    

00802065 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802065:	55                   	push   %ebp
  802066:	89 e5                	mov    %esp,%ebp
  802068:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80206b:	8b 45 08             	mov    0x8(%ebp),%eax
  80206e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802071:	6a 01                	push   $0x1
  802073:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802076:	50                   	push   %eax
  802077:	e8 1d eb ff ff       	call   800b99 <sys_cputs>
}
  80207c:	83 c4 10             	add    $0x10,%esp
  80207f:	c9                   	leave  
  802080:	c3                   	ret    

00802081 <getchar>:

int
getchar(void)
{
  802081:	55                   	push   %ebp
  802082:	89 e5                	mov    %esp,%ebp
  802084:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802087:	6a 01                	push   $0x1
  802089:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80208c:	50                   	push   %eax
  80208d:	6a 00                	push   $0x0
  80208f:	e8 ae f0 ff ff       	call   801142 <read>
	if (r < 0)
  802094:	83 c4 10             	add    $0x10,%esp
  802097:	85 c0                	test   %eax,%eax
  802099:	78 0f                	js     8020aa <getchar+0x29>
		return r;
	if (r < 1)
  80209b:	85 c0                	test   %eax,%eax
  80209d:	7e 06                	jle    8020a5 <getchar+0x24>
		return -E_EOF;
	return c;
  80209f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020a3:	eb 05                	jmp    8020aa <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020a5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020aa:	c9                   	leave  
  8020ab:	c3                   	ret    

008020ac <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020ac:	55                   	push   %ebp
  8020ad:	89 e5                	mov    %esp,%ebp
  8020af:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020b5:	50                   	push   %eax
  8020b6:	ff 75 08             	pushl  0x8(%ebp)
  8020b9:	e8 1e ee ff ff       	call   800edc <fd_lookup>
  8020be:	83 c4 10             	add    $0x10,%esp
  8020c1:	85 c0                	test   %eax,%eax
  8020c3:	78 11                	js     8020d6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020ce:	39 10                	cmp    %edx,(%eax)
  8020d0:	0f 94 c0             	sete   %al
  8020d3:	0f b6 c0             	movzbl %al,%eax
}
  8020d6:	c9                   	leave  
  8020d7:	c3                   	ret    

008020d8 <opencons>:

int
opencons(void)
{
  8020d8:	55                   	push   %ebp
  8020d9:	89 e5                	mov    %esp,%ebp
  8020db:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020e1:	50                   	push   %eax
  8020e2:	e8 a6 ed ff ff       	call   800e8d <fd_alloc>
  8020e7:	83 c4 10             	add    $0x10,%esp
		return r;
  8020ea:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020ec:	85 c0                	test   %eax,%eax
  8020ee:	78 3e                	js     80212e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020f0:	83 ec 04             	sub    $0x4,%esp
  8020f3:	68 07 04 00 00       	push   $0x407
  8020f8:	ff 75 f4             	pushl  -0xc(%ebp)
  8020fb:	6a 00                	push   $0x0
  8020fd:	e8 53 eb ff ff       	call   800c55 <sys_page_alloc>
  802102:	83 c4 10             	add    $0x10,%esp
		return r;
  802105:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802107:	85 c0                	test   %eax,%eax
  802109:	78 23                	js     80212e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80210b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802111:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802114:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802116:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802119:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802120:	83 ec 0c             	sub    $0xc,%esp
  802123:	50                   	push   %eax
  802124:	e8 3d ed ff ff       	call   800e66 <fd2num>
  802129:	89 c2                	mov    %eax,%edx
  80212b:	83 c4 10             	add    $0x10,%esp
}
  80212e:	89 d0                	mov    %edx,%eax
  802130:	c9                   	leave  
  802131:	c3                   	ret    

00802132 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802132:	55                   	push   %ebp
  802133:	89 e5                	mov    %esp,%ebp
  802135:	56                   	push   %esi
  802136:	53                   	push   %ebx
  802137:	8b 75 08             	mov    0x8(%ebp),%esi
  80213a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80213d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802140:	85 c0                	test   %eax,%eax
  802142:	75 12                	jne    802156 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802144:	83 ec 0c             	sub    $0xc,%esp
  802147:	68 00 00 c0 ee       	push   $0xeec00000
  80214c:	e8 b4 ec ff ff       	call   800e05 <sys_ipc_recv>
  802151:	83 c4 10             	add    $0x10,%esp
  802154:	eb 0c                	jmp    802162 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802156:	83 ec 0c             	sub    $0xc,%esp
  802159:	50                   	push   %eax
  80215a:	e8 a6 ec ff ff       	call   800e05 <sys_ipc_recv>
  80215f:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802162:	85 f6                	test   %esi,%esi
  802164:	0f 95 c1             	setne  %cl
  802167:	85 db                	test   %ebx,%ebx
  802169:	0f 95 c2             	setne  %dl
  80216c:	84 d1                	test   %dl,%cl
  80216e:	74 09                	je     802179 <ipc_recv+0x47>
  802170:	89 c2                	mov    %eax,%edx
  802172:	c1 ea 1f             	shr    $0x1f,%edx
  802175:	84 d2                	test   %dl,%dl
  802177:	75 27                	jne    8021a0 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802179:	85 f6                	test   %esi,%esi
  80217b:	74 0a                	je     802187 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  80217d:	a1 04 40 80 00       	mov    0x804004,%eax
  802182:	8b 40 7c             	mov    0x7c(%eax),%eax
  802185:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802187:	85 db                	test   %ebx,%ebx
  802189:	74 0d                	je     802198 <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  80218b:	a1 04 40 80 00       	mov    0x804004,%eax
  802190:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  802196:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802198:	a1 04 40 80 00       	mov    0x804004,%eax
  80219d:	8b 40 78             	mov    0x78(%eax),%eax
}
  8021a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021a3:	5b                   	pop    %ebx
  8021a4:	5e                   	pop    %esi
  8021a5:	5d                   	pop    %ebp
  8021a6:	c3                   	ret    

008021a7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021a7:	55                   	push   %ebp
  8021a8:	89 e5                	mov    %esp,%ebp
  8021aa:	57                   	push   %edi
  8021ab:	56                   	push   %esi
  8021ac:	53                   	push   %ebx
  8021ad:	83 ec 0c             	sub    $0xc,%esp
  8021b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021b3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8021b9:	85 db                	test   %ebx,%ebx
  8021bb:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8021c0:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8021c3:	ff 75 14             	pushl  0x14(%ebp)
  8021c6:	53                   	push   %ebx
  8021c7:	56                   	push   %esi
  8021c8:	57                   	push   %edi
  8021c9:	e8 14 ec ff ff       	call   800de2 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8021ce:	89 c2                	mov    %eax,%edx
  8021d0:	c1 ea 1f             	shr    $0x1f,%edx
  8021d3:	83 c4 10             	add    $0x10,%esp
  8021d6:	84 d2                	test   %dl,%dl
  8021d8:	74 17                	je     8021f1 <ipc_send+0x4a>
  8021da:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021dd:	74 12                	je     8021f1 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8021df:	50                   	push   %eax
  8021e0:	68 0b 2b 80 00       	push   $0x802b0b
  8021e5:	6a 47                	push   $0x47
  8021e7:	68 19 2b 80 00       	push   $0x802b19
  8021ec:	e8 03 e0 ff ff       	call   8001f4 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8021f1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021f4:	75 07                	jne    8021fd <ipc_send+0x56>
			sys_yield();
  8021f6:	e8 3b ea ff ff       	call   800c36 <sys_yield>
  8021fb:	eb c6                	jmp    8021c3 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8021fd:	85 c0                	test   %eax,%eax
  8021ff:	75 c2                	jne    8021c3 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802201:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802204:	5b                   	pop    %ebx
  802205:	5e                   	pop    %esi
  802206:	5f                   	pop    %edi
  802207:	5d                   	pop    %ebp
  802208:	c3                   	ret    

00802209 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802209:	55                   	push   %ebp
  80220a:	89 e5                	mov    %esp,%ebp
  80220c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80220f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802214:	89 c2                	mov    %eax,%edx
  802216:	c1 e2 07             	shl    $0x7,%edx
  802219:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  802220:	8b 52 58             	mov    0x58(%edx),%edx
  802223:	39 ca                	cmp    %ecx,%edx
  802225:	75 11                	jne    802238 <ipc_find_env+0x2f>
			return envs[i].env_id;
  802227:	89 c2                	mov    %eax,%edx
  802229:	c1 e2 07             	shl    $0x7,%edx
  80222c:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  802233:	8b 40 50             	mov    0x50(%eax),%eax
  802236:	eb 0f                	jmp    802247 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802238:	83 c0 01             	add    $0x1,%eax
  80223b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802240:	75 d2                	jne    802214 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802242:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802247:	5d                   	pop    %ebp
  802248:	c3                   	ret    

00802249 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802249:	55                   	push   %ebp
  80224a:	89 e5                	mov    %esp,%ebp
  80224c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80224f:	89 d0                	mov    %edx,%eax
  802251:	c1 e8 16             	shr    $0x16,%eax
  802254:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80225b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802260:	f6 c1 01             	test   $0x1,%cl
  802263:	74 1d                	je     802282 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802265:	c1 ea 0c             	shr    $0xc,%edx
  802268:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80226f:	f6 c2 01             	test   $0x1,%dl
  802272:	74 0e                	je     802282 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802274:	c1 ea 0c             	shr    $0xc,%edx
  802277:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80227e:	ef 
  80227f:	0f b7 c0             	movzwl %ax,%eax
}
  802282:	5d                   	pop    %ebp
  802283:	c3                   	ret    
  802284:	66 90                	xchg   %ax,%ax
  802286:	66 90                	xchg   %ax,%ax
  802288:	66 90                	xchg   %ax,%ax
  80228a:	66 90                	xchg   %ax,%ax
  80228c:	66 90                	xchg   %ax,%ax
  80228e:	66 90                	xchg   %ax,%ax

00802290 <__udivdi3>:
  802290:	55                   	push   %ebp
  802291:	57                   	push   %edi
  802292:	56                   	push   %esi
  802293:	53                   	push   %ebx
  802294:	83 ec 1c             	sub    $0x1c,%esp
  802297:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80229b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80229f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8022a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022a7:	85 f6                	test   %esi,%esi
  8022a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022ad:	89 ca                	mov    %ecx,%edx
  8022af:	89 f8                	mov    %edi,%eax
  8022b1:	75 3d                	jne    8022f0 <__udivdi3+0x60>
  8022b3:	39 cf                	cmp    %ecx,%edi
  8022b5:	0f 87 c5 00 00 00    	ja     802380 <__udivdi3+0xf0>
  8022bb:	85 ff                	test   %edi,%edi
  8022bd:	89 fd                	mov    %edi,%ebp
  8022bf:	75 0b                	jne    8022cc <__udivdi3+0x3c>
  8022c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8022c6:	31 d2                	xor    %edx,%edx
  8022c8:	f7 f7                	div    %edi
  8022ca:	89 c5                	mov    %eax,%ebp
  8022cc:	89 c8                	mov    %ecx,%eax
  8022ce:	31 d2                	xor    %edx,%edx
  8022d0:	f7 f5                	div    %ebp
  8022d2:	89 c1                	mov    %eax,%ecx
  8022d4:	89 d8                	mov    %ebx,%eax
  8022d6:	89 cf                	mov    %ecx,%edi
  8022d8:	f7 f5                	div    %ebp
  8022da:	89 c3                	mov    %eax,%ebx
  8022dc:	89 d8                	mov    %ebx,%eax
  8022de:	89 fa                	mov    %edi,%edx
  8022e0:	83 c4 1c             	add    $0x1c,%esp
  8022e3:	5b                   	pop    %ebx
  8022e4:	5e                   	pop    %esi
  8022e5:	5f                   	pop    %edi
  8022e6:	5d                   	pop    %ebp
  8022e7:	c3                   	ret    
  8022e8:	90                   	nop
  8022e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022f0:	39 ce                	cmp    %ecx,%esi
  8022f2:	77 74                	ja     802368 <__udivdi3+0xd8>
  8022f4:	0f bd fe             	bsr    %esi,%edi
  8022f7:	83 f7 1f             	xor    $0x1f,%edi
  8022fa:	0f 84 98 00 00 00    	je     802398 <__udivdi3+0x108>
  802300:	bb 20 00 00 00       	mov    $0x20,%ebx
  802305:	89 f9                	mov    %edi,%ecx
  802307:	89 c5                	mov    %eax,%ebp
  802309:	29 fb                	sub    %edi,%ebx
  80230b:	d3 e6                	shl    %cl,%esi
  80230d:	89 d9                	mov    %ebx,%ecx
  80230f:	d3 ed                	shr    %cl,%ebp
  802311:	89 f9                	mov    %edi,%ecx
  802313:	d3 e0                	shl    %cl,%eax
  802315:	09 ee                	or     %ebp,%esi
  802317:	89 d9                	mov    %ebx,%ecx
  802319:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80231d:	89 d5                	mov    %edx,%ebp
  80231f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802323:	d3 ed                	shr    %cl,%ebp
  802325:	89 f9                	mov    %edi,%ecx
  802327:	d3 e2                	shl    %cl,%edx
  802329:	89 d9                	mov    %ebx,%ecx
  80232b:	d3 e8                	shr    %cl,%eax
  80232d:	09 c2                	or     %eax,%edx
  80232f:	89 d0                	mov    %edx,%eax
  802331:	89 ea                	mov    %ebp,%edx
  802333:	f7 f6                	div    %esi
  802335:	89 d5                	mov    %edx,%ebp
  802337:	89 c3                	mov    %eax,%ebx
  802339:	f7 64 24 0c          	mull   0xc(%esp)
  80233d:	39 d5                	cmp    %edx,%ebp
  80233f:	72 10                	jb     802351 <__udivdi3+0xc1>
  802341:	8b 74 24 08          	mov    0x8(%esp),%esi
  802345:	89 f9                	mov    %edi,%ecx
  802347:	d3 e6                	shl    %cl,%esi
  802349:	39 c6                	cmp    %eax,%esi
  80234b:	73 07                	jae    802354 <__udivdi3+0xc4>
  80234d:	39 d5                	cmp    %edx,%ebp
  80234f:	75 03                	jne    802354 <__udivdi3+0xc4>
  802351:	83 eb 01             	sub    $0x1,%ebx
  802354:	31 ff                	xor    %edi,%edi
  802356:	89 d8                	mov    %ebx,%eax
  802358:	89 fa                	mov    %edi,%edx
  80235a:	83 c4 1c             	add    $0x1c,%esp
  80235d:	5b                   	pop    %ebx
  80235e:	5e                   	pop    %esi
  80235f:	5f                   	pop    %edi
  802360:	5d                   	pop    %ebp
  802361:	c3                   	ret    
  802362:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802368:	31 ff                	xor    %edi,%edi
  80236a:	31 db                	xor    %ebx,%ebx
  80236c:	89 d8                	mov    %ebx,%eax
  80236e:	89 fa                	mov    %edi,%edx
  802370:	83 c4 1c             	add    $0x1c,%esp
  802373:	5b                   	pop    %ebx
  802374:	5e                   	pop    %esi
  802375:	5f                   	pop    %edi
  802376:	5d                   	pop    %ebp
  802377:	c3                   	ret    
  802378:	90                   	nop
  802379:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802380:	89 d8                	mov    %ebx,%eax
  802382:	f7 f7                	div    %edi
  802384:	31 ff                	xor    %edi,%edi
  802386:	89 c3                	mov    %eax,%ebx
  802388:	89 d8                	mov    %ebx,%eax
  80238a:	89 fa                	mov    %edi,%edx
  80238c:	83 c4 1c             	add    $0x1c,%esp
  80238f:	5b                   	pop    %ebx
  802390:	5e                   	pop    %esi
  802391:	5f                   	pop    %edi
  802392:	5d                   	pop    %ebp
  802393:	c3                   	ret    
  802394:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802398:	39 ce                	cmp    %ecx,%esi
  80239a:	72 0c                	jb     8023a8 <__udivdi3+0x118>
  80239c:	31 db                	xor    %ebx,%ebx
  80239e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8023a2:	0f 87 34 ff ff ff    	ja     8022dc <__udivdi3+0x4c>
  8023a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8023ad:	e9 2a ff ff ff       	jmp    8022dc <__udivdi3+0x4c>
  8023b2:	66 90                	xchg   %ax,%ax
  8023b4:	66 90                	xchg   %ax,%ax
  8023b6:	66 90                	xchg   %ax,%ax
  8023b8:	66 90                	xchg   %ax,%ax
  8023ba:	66 90                	xchg   %ax,%ax
  8023bc:	66 90                	xchg   %ax,%ax
  8023be:	66 90                	xchg   %ax,%ax

008023c0 <__umoddi3>:
  8023c0:	55                   	push   %ebp
  8023c1:	57                   	push   %edi
  8023c2:	56                   	push   %esi
  8023c3:	53                   	push   %ebx
  8023c4:	83 ec 1c             	sub    $0x1c,%esp
  8023c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8023cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8023cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023d7:	85 d2                	test   %edx,%edx
  8023d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8023dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023e1:	89 f3                	mov    %esi,%ebx
  8023e3:	89 3c 24             	mov    %edi,(%esp)
  8023e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023ea:	75 1c                	jne    802408 <__umoddi3+0x48>
  8023ec:	39 f7                	cmp    %esi,%edi
  8023ee:	76 50                	jbe    802440 <__umoddi3+0x80>
  8023f0:	89 c8                	mov    %ecx,%eax
  8023f2:	89 f2                	mov    %esi,%edx
  8023f4:	f7 f7                	div    %edi
  8023f6:	89 d0                	mov    %edx,%eax
  8023f8:	31 d2                	xor    %edx,%edx
  8023fa:	83 c4 1c             	add    $0x1c,%esp
  8023fd:	5b                   	pop    %ebx
  8023fe:	5e                   	pop    %esi
  8023ff:	5f                   	pop    %edi
  802400:	5d                   	pop    %ebp
  802401:	c3                   	ret    
  802402:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802408:	39 f2                	cmp    %esi,%edx
  80240a:	89 d0                	mov    %edx,%eax
  80240c:	77 52                	ja     802460 <__umoddi3+0xa0>
  80240e:	0f bd ea             	bsr    %edx,%ebp
  802411:	83 f5 1f             	xor    $0x1f,%ebp
  802414:	75 5a                	jne    802470 <__umoddi3+0xb0>
  802416:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80241a:	0f 82 e0 00 00 00    	jb     802500 <__umoddi3+0x140>
  802420:	39 0c 24             	cmp    %ecx,(%esp)
  802423:	0f 86 d7 00 00 00    	jbe    802500 <__umoddi3+0x140>
  802429:	8b 44 24 08          	mov    0x8(%esp),%eax
  80242d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802431:	83 c4 1c             	add    $0x1c,%esp
  802434:	5b                   	pop    %ebx
  802435:	5e                   	pop    %esi
  802436:	5f                   	pop    %edi
  802437:	5d                   	pop    %ebp
  802438:	c3                   	ret    
  802439:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802440:	85 ff                	test   %edi,%edi
  802442:	89 fd                	mov    %edi,%ebp
  802444:	75 0b                	jne    802451 <__umoddi3+0x91>
  802446:	b8 01 00 00 00       	mov    $0x1,%eax
  80244b:	31 d2                	xor    %edx,%edx
  80244d:	f7 f7                	div    %edi
  80244f:	89 c5                	mov    %eax,%ebp
  802451:	89 f0                	mov    %esi,%eax
  802453:	31 d2                	xor    %edx,%edx
  802455:	f7 f5                	div    %ebp
  802457:	89 c8                	mov    %ecx,%eax
  802459:	f7 f5                	div    %ebp
  80245b:	89 d0                	mov    %edx,%eax
  80245d:	eb 99                	jmp    8023f8 <__umoddi3+0x38>
  80245f:	90                   	nop
  802460:	89 c8                	mov    %ecx,%eax
  802462:	89 f2                	mov    %esi,%edx
  802464:	83 c4 1c             	add    $0x1c,%esp
  802467:	5b                   	pop    %ebx
  802468:	5e                   	pop    %esi
  802469:	5f                   	pop    %edi
  80246a:	5d                   	pop    %ebp
  80246b:	c3                   	ret    
  80246c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802470:	8b 34 24             	mov    (%esp),%esi
  802473:	bf 20 00 00 00       	mov    $0x20,%edi
  802478:	89 e9                	mov    %ebp,%ecx
  80247a:	29 ef                	sub    %ebp,%edi
  80247c:	d3 e0                	shl    %cl,%eax
  80247e:	89 f9                	mov    %edi,%ecx
  802480:	89 f2                	mov    %esi,%edx
  802482:	d3 ea                	shr    %cl,%edx
  802484:	89 e9                	mov    %ebp,%ecx
  802486:	09 c2                	or     %eax,%edx
  802488:	89 d8                	mov    %ebx,%eax
  80248a:	89 14 24             	mov    %edx,(%esp)
  80248d:	89 f2                	mov    %esi,%edx
  80248f:	d3 e2                	shl    %cl,%edx
  802491:	89 f9                	mov    %edi,%ecx
  802493:	89 54 24 04          	mov    %edx,0x4(%esp)
  802497:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80249b:	d3 e8                	shr    %cl,%eax
  80249d:	89 e9                	mov    %ebp,%ecx
  80249f:	89 c6                	mov    %eax,%esi
  8024a1:	d3 e3                	shl    %cl,%ebx
  8024a3:	89 f9                	mov    %edi,%ecx
  8024a5:	89 d0                	mov    %edx,%eax
  8024a7:	d3 e8                	shr    %cl,%eax
  8024a9:	89 e9                	mov    %ebp,%ecx
  8024ab:	09 d8                	or     %ebx,%eax
  8024ad:	89 d3                	mov    %edx,%ebx
  8024af:	89 f2                	mov    %esi,%edx
  8024b1:	f7 34 24             	divl   (%esp)
  8024b4:	89 d6                	mov    %edx,%esi
  8024b6:	d3 e3                	shl    %cl,%ebx
  8024b8:	f7 64 24 04          	mull   0x4(%esp)
  8024bc:	39 d6                	cmp    %edx,%esi
  8024be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024c2:	89 d1                	mov    %edx,%ecx
  8024c4:	89 c3                	mov    %eax,%ebx
  8024c6:	72 08                	jb     8024d0 <__umoddi3+0x110>
  8024c8:	75 11                	jne    8024db <__umoddi3+0x11b>
  8024ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8024ce:	73 0b                	jae    8024db <__umoddi3+0x11b>
  8024d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8024d4:	1b 14 24             	sbb    (%esp),%edx
  8024d7:	89 d1                	mov    %edx,%ecx
  8024d9:	89 c3                	mov    %eax,%ebx
  8024db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8024df:	29 da                	sub    %ebx,%edx
  8024e1:	19 ce                	sbb    %ecx,%esi
  8024e3:	89 f9                	mov    %edi,%ecx
  8024e5:	89 f0                	mov    %esi,%eax
  8024e7:	d3 e0                	shl    %cl,%eax
  8024e9:	89 e9                	mov    %ebp,%ecx
  8024eb:	d3 ea                	shr    %cl,%edx
  8024ed:	89 e9                	mov    %ebp,%ecx
  8024ef:	d3 ee                	shr    %cl,%esi
  8024f1:	09 d0                	or     %edx,%eax
  8024f3:	89 f2                	mov    %esi,%edx
  8024f5:	83 c4 1c             	add    $0x1c,%esp
  8024f8:	5b                   	pop    %ebx
  8024f9:	5e                   	pop    %esi
  8024fa:	5f                   	pop    %edi
  8024fb:	5d                   	pop    %ebp
  8024fc:	c3                   	ret    
  8024fd:	8d 76 00             	lea    0x0(%esi),%esi
  802500:	29 f9                	sub    %edi,%ecx
  802502:	19 d6                	sbb    %edx,%esi
  802504:	89 74 24 04          	mov    %esi,0x4(%esp)
  802508:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80250c:	e9 18 ff ff ff       	jmp    802429 <__umoddi3+0x69>
