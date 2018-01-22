
obj/user/primes.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;
	
	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 c6 10 00 00       	call   801112 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 40 80 00       	mov    0x804004,%eax
  800053:	8b 40 64             	mov    0x64(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 80 22 80 00       	push   $0x802280
  800060:	e8 2c 02 00 00       	call   800291 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 96 0e 00 00       	call   800f00 <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 8c 22 80 00       	push   $0x80228c
  800079:	6a 1a                	push   $0x1a
  80007b:	68 95 22 80 00       	push   $0x802295
  800080:	e8 33 01 00 00       	call   8001b8 <_panic>
	if (id == 0)
  800085:	85 c0                	test   %eax,%eax
  800087:	74 b6                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800089:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80008c:	83 ec 04             	sub    $0x4,%esp
  80008f:	6a 00                	push   $0x0
  800091:	6a 00                	push   $0x0
  800093:	56                   	push   %esi
  800094:	e8 79 10 00 00       	call   801112 <ipc_recv>
  800099:	89 c1                	mov    %eax,%ecx
		if (i % p)
  80009b:	99                   	cltd   
  80009c:	f7 fb                	idiv   %ebx
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	85 d2                	test   %edx,%edx
  8000a3:	74 e7                	je     80008c <primeproc+0x59>
			ipc_send(id, i, 0, 0);
  8000a5:	6a 00                	push   $0x0
  8000a7:	6a 00                	push   $0x0
  8000a9:	51                   	push   %ecx
  8000aa:	57                   	push   %edi
  8000ab:	e8 d7 10 00 00       	call   801187 <ipc_send>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	eb d7                	jmp    80008c <primeproc+0x59>

008000b5 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ba:	e8 41 0e 00 00       	call   800f00 <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 8c 22 80 00       	push   $0x80228c
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 95 22 80 00       	push   $0x802295
  8000d2:	e8 e1 00 00 00       	call   8001b8 <_panic>
  8000d7:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000dc:	85 c0                	test   %eax,%eax
  8000de:	75 05                	jne    8000e5 <umain+0x30>
		primeproc();
  8000e0:	e8 4e ff ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  8000e5:	6a 00                	push   $0x0
  8000e7:	6a 00                	push   $0x0
  8000e9:	53                   	push   %ebx
  8000ea:	56                   	push   %esi
  8000eb:	e8 97 10 00 00       	call   801187 <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000f0:	83 c3 01             	add    $0x1,%ebx
  8000f3:	83 c4 10             	add    $0x10,%esp
  8000f6:	eb ed                	jmp    8000e5 <umain+0x30>

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	57                   	push   %edi
  8000fc:	56                   	push   %esi
  8000fd:	53                   	push   %ebx
  8000fe:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800101:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800108:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  80010b:	e8 cb 0a 00 00       	call   800bdb <sys_getenvid>
  800110:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  800112:	83 ec 08             	sub    $0x8,%esp
  800115:	50                   	push   %eax
  800116:	68 a4 22 80 00       	push   $0x8022a4
  80011b:	e8 71 01 00 00       	call   800291 <cprintf>
  800120:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  800126:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800133:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  800138:	89 c1                	mov    %eax,%ecx
  80013a:	c1 e1 07             	shl    $0x7,%ecx
  80013d:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  800144:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  800147:	39 cb                	cmp    %ecx,%ebx
  800149:	0f 44 fa             	cmove  %edx,%edi
  80014c:	b9 01 00 00 00       	mov    $0x1,%ecx
  800151:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  800154:	83 c0 01             	add    $0x1,%eax
  800157:	81 c2 84 00 00 00    	add    $0x84,%edx
  80015d:	3d 00 04 00 00       	cmp    $0x400,%eax
  800162:	75 d4                	jne    800138 <libmain+0x40>
  800164:	89 f0                	mov    %esi,%eax
  800166:	84 c0                	test   %al,%al
  800168:	74 06                	je     800170 <libmain+0x78>
  80016a:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800170:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800174:	7e 0a                	jle    800180 <libmain+0x88>
		binaryname = argv[0];
  800176:	8b 45 0c             	mov    0xc(%ebp),%eax
  800179:	8b 00                	mov    (%eax),%eax
  80017b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800180:	83 ec 08             	sub    $0x8,%esp
  800183:	ff 75 0c             	pushl  0xc(%ebp)
  800186:	ff 75 08             	pushl  0x8(%ebp)
  800189:	e8 27 ff ff ff       	call   8000b5 <umain>

	// exit gracefully
	exit();
  80018e:	e8 0b 00 00 00       	call   80019e <exit>
}
  800193:	83 c4 10             	add    $0x10,%esp
  800196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800199:	5b                   	pop    %ebx
  80019a:	5e                   	pop    %esi
  80019b:	5f                   	pop    %edi
  80019c:	5d                   	pop    %ebp
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
  8001a4:	e8 4b 12 00 00       	call   8013f4 <close_all>
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
  8001d6:	68 d0 22 80 00       	push   $0x8022d0
  8001db:	e8 b1 00 00 00       	call   800291 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001e0:	83 c4 18             	add    $0x18,%esp
  8001e3:	53                   	push   %ebx
  8001e4:	ff 75 10             	pushl  0x10(%ebp)
  8001e7:	e8 54 00 00 00       	call   800240 <vcprintf>
	cprintf("\n");
  8001ec:	c7 04 24 9b 27 80 00 	movl   $0x80279b,(%esp)
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
  8002f4:	e8 e7 1c 00 00       	call   801fe0 <__udivdi3>
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
  800337:	e8 d4 1d 00 00       	call   802110 <__umoddi3>
  80033c:	83 c4 14             	add    $0x14,%esp
  80033f:	0f be 80 f3 22 80 00 	movsbl 0x8022f3(%eax),%eax
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
  80043b:	ff 24 85 40 24 80 00 	jmp    *0x802440(,%eax,4)
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
  8004ff:	8b 14 85 a0 25 80 00 	mov    0x8025a0(,%eax,4),%edx
  800506:	85 d2                	test   %edx,%edx
  800508:	75 18                	jne    800522 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80050a:	50                   	push   %eax
  80050b:	68 0b 23 80 00       	push   $0x80230b
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
  800523:	68 69 27 80 00       	push   $0x802769
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
  800547:	b8 04 23 80 00       	mov    $0x802304,%eax
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
  800bc2:	68 ff 25 80 00       	push   $0x8025ff
  800bc7:	6a 23                	push   $0x23
  800bc9:	68 1c 26 80 00       	push   $0x80261c
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
  800c43:	68 ff 25 80 00       	push   $0x8025ff
  800c48:	6a 23                	push   $0x23
  800c4a:	68 1c 26 80 00       	push   $0x80261c
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
  800c85:	68 ff 25 80 00       	push   $0x8025ff
  800c8a:	6a 23                	push   $0x23
  800c8c:	68 1c 26 80 00       	push   $0x80261c
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
  800cc7:	68 ff 25 80 00       	push   $0x8025ff
  800ccc:	6a 23                	push   $0x23
  800cce:	68 1c 26 80 00       	push   $0x80261c
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
  800d09:	68 ff 25 80 00       	push   $0x8025ff
  800d0e:	6a 23                	push   $0x23
  800d10:	68 1c 26 80 00       	push   $0x80261c
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
  800d4b:	68 ff 25 80 00       	push   $0x8025ff
  800d50:	6a 23                	push   $0x23
  800d52:	68 1c 26 80 00       	push   $0x80261c
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
  800d8d:	68 ff 25 80 00       	push   $0x8025ff
  800d92:	6a 23                	push   $0x23
  800d94:	68 1c 26 80 00       	push   $0x80261c
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
  800df1:	68 ff 25 80 00       	push   $0x8025ff
  800df6:	6a 23                	push   $0x23
  800df8:	68 1c 26 80 00       	push   $0x80261c
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

00800e2a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	53                   	push   %ebx
  800e2e:	83 ec 04             	sub    $0x4,%esp
  800e31:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e34:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800e36:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e3a:	74 11                	je     800e4d <pgfault+0x23>
  800e3c:	89 d8                	mov    %ebx,%eax
  800e3e:	c1 e8 0c             	shr    $0xc,%eax
  800e41:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e48:	f6 c4 08             	test   $0x8,%ah
  800e4b:	75 14                	jne    800e61 <pgfault+0x37>
		panic("faulting access");
  800e4d:	83 ec 04             	sub    $0x4,%esp
  800e50:	68 2a 26 80 00       	push   $0x80262a
  800e55:	6a 1d                	push   $0x1d
  800e57:	68 3a 26 80 00       	push   $0x80263a
  800e5c:	e8 57 f3 ff ff       	call   8001b8 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e61:	83 ec 04             	sub    $0x4,%esp
  800e64:	6a 07                	push   $0x7
  800e66:	68 00 f0 7f 00       	push   $0x7ff000
  800e6b:	6a 00                	push   $0x0
  800e6d:	e8 a7 fd ff ff       	call   800c19 <sys_page_alloc>
	if (r < 0) {
  800e72:	83 c4 10             	add    $0x10,%esp
  800e75:	85 c0                	test   %eax,%eax
  800e77:	79 12                	jns    800e8b <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e79:	50                   	push   %eax
  800e7a:	68 45 26 80 00       	push   $0x802645
  800e7f:	6a 2b                	push   $0x2b
  800e81:	68 3a 26 80 00       	push   $0x80263a
  800e86:	e8 2d f3 ff ff       	call   8001b8 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e8b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e91:	83 ec 04             	sub    $0x4,%esp
  800e94:	68 00 10 00 00       	push   $0x1000
  800e99:	53                   	push   %ebx
  800e9a:	68 00 f0 7f 00       	push   $0x7ff000
  800e9f:	e8 6c fb ff ff       	call   800a10 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800ea4:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800eab:	53                   	push   %ebx
  800eac:	6a 00                	push   $0x0
  800eae:	68 00 f0 7f 00       	push   $0x7ff000
  800eb3:	6a 00                	push   $0x0
  800eb5:	e8 a2 fd ff ff       	call   800c5c <sys_page_map>
	if (r < 0) {
  800eba:	83 c4 20             	add    $0x20,%esp
  800ebd:	85 c0                	test   %eax,%eax
  800ebf:	79 12                	jns    800ed3 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800ec1:	50                   	push   %eax
  800ec2:	68 45 26 80 00       	push   $0x802645
  800ec7:	6a 32                	push   $0x32
  800ec9:	68 3a 26 80 00       	push   $0x80263a
  800ece:	e8 e5 f2 ff ff       	call   8001b8 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800ed3:	83 ec 08             	sub    $0x8,%esp
  800ed6:	68 00 f0 7f 00       	push   $0x7ff000
  800edb:	6a 00                	push   $0x0
  800edd:	e8 bc fd ff ff       	call   800c9e <sys_page_unmap>
	if (r < 0) {
  800ee2:	83 c4 10             	add    $0x10,%esp
  800ee5:	85 c0                	test   %eax,%eax
  800ee7:	79 12                	jns    800efb <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800ee9:	50                   	push   %eax
  800eea:	68 45 26 80 00       	push   $0x802645
  800eef:	6a 36                	push   $0x36
  800ef1:	68 3a 26 80 00       	push   $0x80263a
  800ef6:	e8 bd f2 ff ff       	call   8001b8 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800efb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800efe:	c9                   	leave  
  800eff:	c3                   	ret    

00800f00 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	57                   	push   %edi
  800f04:	56                   	push   %esi
  800f05:	53                   	push   %ebx
  800f06:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800f09:	68 2a 0e 80 00       	push   $0x800e2a
  800f0e:	e8 00 10 00 00       	call   801f13 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f13:	b8 07 00 00 00       	mov    $0x7,%eax
  800f18:	cd 30                	int    $0x30
  800f1a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800f1d:	83 c4 10             	add    $0x10,%esp
  800f20:	85 c0                	test   %eax,%eax
  800f22:	79 17                	jns    800f3b <fork+0x3b>
		panic("fork fault %e");
  800f24:	83 ec 04             	sub    $0x4,%esp
  800f27:	68 5e 26 80 00       	push   $0x80265e
  800f2c:	68 83 00 00 00       	push   $0x83
  800f31:	68 3a 26 80 00       	push   $0x80263a
  800f36:	e8 7d f2 ff ff       	call   8001b8 <_panic>
  800f3b:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f3d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f41:	75 25                	jne    800f68 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f43:	e8 93 fc ff ff       	call   800bdb <sys_getenvid>
  800f48:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f4d:	89 c2                	mov    %eax,%edx
  800f4f:	c1 e2 07             	shl    $0x7,%edx
  800f52:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800f59:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f63:	e9 61 01 00 00       	jmp    8010c9 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f68:	83 ec 04             	sub    $0x4,%esp
  800f6b:	6a 07                	push   $0x7
  800f6d:	68 00 f0 bf ee       	push   $0xeebff000
  800f72:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f75:	e8 9f fc ff ff       	call   800c19 <sys_page_alloc>
  800f7a:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f7d:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f82:	89 d8                	mov    %ebx,%eax
  800f84:	c1 e8 16             	shr    $0x16,%eax
  800f87:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f8e:	a8 01                	test   $0x1,%al
  800f90:	0f 84 fc 00 00 00    	je     801092 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f96:	89 d8                	mov    %ebx,%eax
  800f98:	c1 e8 0c             	shr    $0xc,%eax
  800f9b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fa2:	f6 c2 01             	test   $0x1,%dl
  800fa5:	0f 84 e7 00 00 00    	je     801092 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800fab:	89 c6                	mov    %eax,%esi
  800fad:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800fb0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fb7:	f6 c6 04             	test   $0x4,%dh
  800fba:	74 39                	je     800ff5 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800fbc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fc3:	83 ec 0c             	sub    $0xc,%esp
  800fc6:	25 07 0e 00 00       	and    $0xe07,%eax
  800fcb:	50                   	push   %eax
  800fcc:	56                   	push   %esi
  800fcd:	57                   	push   %edi
  800fce:	56                   	push   %esi
  800fcf:	6a 00                	push   $0x0
  800fd1:	e8 86 fc ff ff       	call   800c5c <sys_page_map>
		if (r < 0) {
  800fd6:	83 c4 20             	add    $0x20,%esp
  800fd9:	85 c0                	test   %eax,%eax
  800fdb:	0f 89 b1 00 00 00    	jns    801092 <fork+0x192>
		    	panic("sys page map fault %e");
  800fe1:	83 ec 04             	sub    $0x4,%esp
  800fe4:	68 6c 26 80 00       	push   $0x80266c
  800fe9:	6a 53                	push   $0x53
  800feb:	68 3a 26 80 00       	push   $0x80263a
  800ff0:	e8 c3 f1 ff ff       	call   8001b8 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800ff5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ffc:	f6 c2 02             	test   $0x2,%dl
  800fff:	75 0c                	jne    80100d <fork+0x10d>
  801001:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801008:	f6 c4 08             	test   $0x8,%ah
  80100b:	74 5b                	je     801068 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80100d:	83 ec 0c             	sub    $0xc,%esp
  801010:	68 05 08 00 00       	push   $0x805
  801015:	56                   	push   %esi
  801016:	57                   	push   %edi
  801017:	56                   	push   %esi
  801018:	6a 00                	push   $0x0
  80101a:	e8 3d fc ff ff       	call   800c5c <sys_page_map>
		if (r < 0) {
  80101f:	83 c4 20             	add    $0x20,%esp
  801022:	85 c0                	test   %eax,%eax
  801024:	79 14                	jns    80103a <fork+0x13a>
		    	panic("sys page map fault %e");
  801026:	83 ec 04             	sub    $0x4,%esp
  801029:	68 6c 26 80 00       	push   $0x80266c
  80102e:	6a 5a                	push   $0x5a
  801030:	68 3a 26 80 00       	push   $0x80263a
  801035:	e8 7e f1 ff ff       	call   8001b8 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  80103a:	83 ec 0c             	sub    $0xc,%esp
  80103d:	68 05 08 00 00       	push   $0x805
  801042:	56                   	push   %esi
  801043:	6a 00                	push   $0x0
  801045:	56                   	push   %esi
  801046:	6a 00                	push   $0x0
  801048:	e8 0f fc ff ff       	call   800c5c <sys_page_map>
		if (r < 0) {
  80104d:	83 c4 20             	add    $0x20,%esp
  801050:	85 c0                	test   %eax,%eax
  801052:	79 3e                	jns    801092 <fork+0x192>
		    	panic("sys page map fault %e");
  801054:	83 ec 04             	sub    $0x4,%esp
  801057:	68 6c 26 80 00       	push   $0x80266c
  80105c:	6a 5e                	push   $0x5e
  80105e:	68 3a 26 80 00       	push   $0x80263a
  801063:	e8 50 f1 ff ff       	call   8001b8 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801068:	83 ec 0c             	sub    $0xc,%esp
  80106b:	6a 05                	push   $0x5
  80106d:	56                   	push   %esi
  80106e:	57                   	push   %edi
  80106f:	56                   	push   %esi
  801070:	6a 00                	push   $0x0
  801072:	e8 e5 fb ff ff       	call   800c5c <sys_page_map>
		if (r < 0) {
  801077:	83 c4 20             	add    $0x20,%esp
  80107a:	85 c0                	test   %eax,%eax
  80107c:	79 14                	jns    801092 <fork+0x192>
		    	panic("sys page map fault %e");
  80107e:	83 ec 04             	sub    $0x4,%esp
  801081:	68 6c 26 80 00       	push   $0x80266c
  801086:	6a 63                	push   $0x63
  801088:	68 3a 26 80 00       	push   $0x80263a
  80108d:	e8 26 f1 ff ff       	call   8001b8 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801092:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801098:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80109e:	0f 85 de fe ff ff    	jne    800f82 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8010a4:	a1 04 40 80 00       	mov    0x804004,%eax
  8010a9:	8b 40 6c             	mov    0x6c(%eax),%eax
  8010ac:	83 ec 08             	sub    $0x8,%esp
  8010af:	50                   	push   %eax
  8010b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010b3:	57                   	push   %edi
  8010b4:	e8 ab fc ff ff       	call   800d64 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8010b9:	83 c4 08             	add    $0x8,%esp
  8010bc:	6a 02                	push   $0x2
  8010be:	57                   	push   %edi
  8010bf:	e8 1c fc ff ff       	call   800ce0 <sys_env_set_status>
	
	return envid;
  8010c4:	83 c4 10             	add    $0x10,%esp
  8010c7:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8010c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010cc:	5b                   	pop    %ebx
  8010cd:	5e                   	pop    %esi
  8010ce:	5f                   	pop    %edi
  8010cf:	5d                   	pop    %ebp
  8010d0:	c3                   	ret    

008010d1 <sfork>:

envid_t
sfork(void)
{
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
	return 0;
}
  8010d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d9:	5d                   	pop    %ebp
  8010da:	c3                   	ret    

008010db <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	56                   	push   %esi
  8010df:	53                   	push   %ebx
  8010e0:	8b 5d 08             	mov    0x8(%ebp),%ebx

	cprintf("in fork.c thread create. func: %x\n", func);
  8010e3:	83 ec 08             	sub    $0x8,%esp
  8010e6:	53                   	push   %ebx
  8010e7:	68 84 26 80 00       	push   $0x802684
  8010ec:	e8 a0 f1 ff ff       	call   800291 <cprintf>
	envid_t id = sys_thread_create((uintptr_t )func);
  8010f1:	89 1c 24             	mov    %ebx,(%esp)
  8010f4:	e8 11 fd ff ff       	call   800e0a <sys_thread_create>
  8010f9:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8010fb:	83 c4 08             	add    $0x8,%esp
  8010fe:	53                   	push   %ebx
  8010ff:	68 84 26 80 00       	push   $0x802684
  801104:	e8 88 f1 ff ff       	call   800291 <cprintf>
	return id;
}
  801109:	89 f0                	mov    %esi,%eax
  80110b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80110e:	5b                   	pop    %ebx
  80110f:	5e                   	pop    %esi
  801110:	5d                   	pop    %ebp
  801111:	c3                   	ret    

00801112 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801112:	55                   	push   %ebp
  801113:	89 e5                	mov    %esp,%ebp
  801115:	56                   	push   %esi
  801116:	53                   	push   %ebx
  801117:	8b 75 08             	mov    0x8(%ebp),%esi
  80111a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80111d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801120:	85 c0                	test   %eax,%eax
  801122:	75 12                	jne    801136 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801124:	83 ec 0c             	sub    $0xc,%esp
  801127:	68 00 00 c0 ee       	push   $0xeec00000
  80112c:	e8 98 fc ff ff       	call   800dc9 <sys_ipc_recv>
  801131:	83 c4 10             	add    $0x10,%esp
  801134:	eb 0c                	jmp    801142 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801136:	83 ec 0c             	sub    $0xc,%esp
  801139:	50                   	push   %eax
  80113a:	e8 8a fc ff ff       	call   800dc9 <sys_ipc_recv>
  80113f:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801142:	85 f6                	test   %esi,%esi
  801144:	0f 95 c1             	setne  %cl
  801147:	85 db                	test   %ebx,%ebx
  801149:	0f 95 c2             	setne  %dl
  80114c:	84 d1                	test   %dl,%cl
  80114e:	74 09                	je     801159 <ipc_recv+0x47>
  801150:	89 c2                	mov    %eax,%edx
  801152:	c1 ea 1f             	shr    $0x1f,%edx
  801155:	84 d2                	test   %dl,%dl
  801157:	75 27                	jne    801180 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801159:	85 f6                	test   %esi,%esi
  80115b:	74 0a                	je     801167 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  80115d:	a1 04 40 80 00       	mov    0x804004,%eax
  801162:	8b 40 7c             	mov    0x7c(%eax),%eax
  801165:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801167:	85 db                	test   %ebx,%ebx
  801169:	74 0d                	je     801178 <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  80116b:	a1 04 40 80 00       	mov    0x804004,%eax
  801170:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801176:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801178:	a1 04 40 80 00       	mov    0x804004,%eax
  80117d:	8b 40 78             	mov    0x78(%eax),%eax
}
  801180:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801183:	5b                   	pop    %ebx
  801184:	5e                   	pop    %esi
  801185:	5d                   	pop    %ebp
  801186:	c3                   	ret    

00801187 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	57                   	push   %edi
  80118b:	56                   	push   %esi
  80118c:	53                   	push   %ebx
  80118d:	83 ec 0c             	sub    $0xc,%esp
  801190:	8b 7d 08             	mov    0x8(%ebp),%edi
  801193:	8b 75 0c             	mov    0xc(%ebp),%esi
  801196:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801199:	85 db                	test   %ebx,%ebx
  80119b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8011a0:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8011a3:	ff 75 14             	pushl  0x14(%ebp)
  8011a6:	53                   	push   %ebx
  8011a7:	56                   	push   %esi
  8011a8:	57                   	push   %edi
  8011a9:	e8 f8 fb ff ff       	call   800da6 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8011ae:	89 c2                	mov    %eax,%edx
  8011b0:	c1 ea 1f             	shr    $0x1f,%edx
  8011b3:	83 c4 10             	add    $0x10,%esp
  8011b6:	84 d2                	test   %dl,%dl
  8011b8:	74 17                	je     8011d1 <ipc_send+0x4a>
  8011ba:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011bd:	74 12                	je     8011d1 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8011bf:	50                   	push   %eax
  8011c0:	68 a7 26 80 00       	push   $0x8026a7
  8011c5:	6a 47                	push   $0x47
  8011c7:	68 b5 26 80 00       	push   $0x8026b5
  8011cc:	e8 e7 ef ff ff       	call   8001b8 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8011d1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011d4:	75 07                	jne    8011dd <ipc_send+0x56>
			sys_yield();
  8011d6:	e8 1f fa ff ff       	call   800bfa <sys_yield>
  8011db:	eb c6                	jmp    8011a3 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8011dd:	85 c0                	test   %eax,%eax
  8011df:	75 c2                	jne    8011a3 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8011e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e4:	5b                   	pop    %ebx
  8011e5:	5e                   	pop    %esi
  8011e6:	5f                   	pop    %edi
  8011e7:	5d                   	pop    %ebp
  8011e8:	c3                   	ret    

008011e9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011e9:	55                   	push   %ebp
  8011ea:	89 e5                	mov    %esp,%ebp
  8011ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011ef:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011f4:	89 c2                	mov    %eax,%edx
  8011f6:	c1 e2 07             	shl    $0x7,%edx
  8011f9:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801200:	8b 52 58             	mov    0x58(%edx),%edx
  801203:	39 ca                	cmp    %ecx,%edx
  801205:	75 11                	jne    801218 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801207:	89 c2                	mov    %eax,%edx
  801209:	c1 e2 07             	shl    $0x7,%edx
  80120c:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801213:	8b 40 50             	mov    0x50(%eax),%eax
  801216:	eb 0f                	jmp    801227 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801218:	83 c0 01             	add    $0x1,%eax
  80121b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801220:	75 d2                	jne    8011f4 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801222:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801227:	5d                   	pop    %ebp
  801228:	c3                   	ret    

00801229 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801229:	55                   	push   %ebp
  80122a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80122c:	8b 45 08             	mov    0x8(%ebp),%eax
  80122f:	05 00 00 00 30       	add    $0x30000000,%eax
  801234:	c1 e8 0c             	shr    $0xc,%eax
}
  801237:	5d                   	pop    %ebp
  801238:	c3                   	ret    

00801239 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801239:	55                   	push   %ebp
  80123a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80123c:	8b 45 08             	mov    0x8(%ebp),%eax
  80123f:	05 00 00 00 30       	add    $0x30000000,%eax
  801244:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801249:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80124e:	5d                   	pop    %ebp
  80124f:	c3                   	ret    

00801250 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801256:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80125b:	89 c2                	mov    %eax,%edx
  80125d:	c1 ea 16             	shr    $0x16,%edx
  801260:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801267:	f6 c2 01             	test   $0x1,%dl
  80126a:	74 11                	je     80127d <fd_alloc+0x2d>
  80126c:	89 c2                	mov    %eax,%edx
  80126e:	c1 ea 0c             	shr    $0xc,%edx
  801271:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801278:	f6 c2 01             	test   $0x1,%dl
  80127b:	75 09                	jne    801286 <fd_alloc+0x36>
			*fd_store = fd;
  80127d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80127f:	b8 00 00 00 00       	mov    $0x0,%eax
  801284:	eb 17                	jmp    80129d <fd_alloc+0x4d>
  801286:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80128b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801290:	75 c9                	jne    80125b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801292:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801298:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80129d:	5d                   	pop    %ebp
  80129e:	c3                   	ret    

0080129f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012a5:	83 f8 1f             	cmp    $0x1f,%eax
  8012a8:	77 36                	ja     8012e0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012aa:	c1 e0 0c             	shl    $0xc,%eax
  8012ad:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012b2:	89 c2                	mov    %eax,%edx
  8012b4:	c1 ea 16             	shr    $0x16,%edx
  8012b7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012be:	f6 c2 01             	test   $0x1,%dl
  8012c1:	74 24                	je     8012e7 <fd_lookup+0x48>
  8012c3:	89 c2                	mov    %eax,%edx
  8012c5:	c1 ea 0c             	shr    $0xc,%edx
  8012c8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012cf:	f6 c2 01             	test   $0x1,%dl
  8012d2:	74 1a                	je     8012ee <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012d7:	89 02                	mov    %eax,(%edx)
	return 0;
  8012d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012de:	eb 13                	jmp    8012f3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012e0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e5:	eb 0c                	jmp    8012f3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ec:	eb 05                	jmp    8012f3 <fd_lookup+0x54>
  8012ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012f3:	5d                   	pop    %ebp
  8012f4:	c3                   	ret    

008012f5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012f5:	55                   	push   %ebp
  8012f6:	89 e5                	mov    %esp,%ebp
  8012f8:	83 ec 08             	sub    $0x8,%esp
  8012fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012fe:	ba 40 27 80 00       	mov    $0x802740,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801303:	eb 13                	jmp    801318 <dev_lookup+0x23>
  801305:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801308:	39 08                	cmp    %ecx,(%eax)
  80130a:	75 0c                	jne    801318 <dev_lookup+0x23>
			*dev = devtab[i];
  80130c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80130f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801311:	b8 00 00 00 00       	mov    $0x0,%eax
  801316:	eb 2e                	jmp    801346 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801318:	8b 02                	mov    (%edx),%eax
  80131a:	85 c0                	test   %eax,%eax
  80131c:	75 e7                	jne    801305 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80131e:	a1 04 40 80 00       	mov    0x804004,%eax
  801323:	8b 40 50             	mov    0x50(%eax),%eax
  801326:	83 ec 04             	sub    $0x4,%esp
  801329:	51                   	push   %ecx
  80132a:	50                   	push   %eax
  80132b:	68 c0 26 80 00       	push   $0x8026c0
  801330:	e8 5c ef ff ff       	call   800291 <cprintf>
	*dev = 0;
  801335:	8b 45 0c             	mov    0xc(%ebp),%eax
  801338:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80133e:	83 c4 10             	add    $0x10,%esp
  801341:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801346:	c9                   	leave  
  801347:	c3                   	ret    

00801348 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801348:	55                   	push   %ebp
  801349:	89 e5                	mov    %esp,%ebp
  80134b:	56                   	push   %esi
  80134c:	53                   	push   %ebx
  80134d:	83 ec 10             	sub    $0x10,%esp
  801350:	8b 75 08             	mov    0x8(%ebp),%esi
  801353:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801356:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801359:	50                   	push   %eax
  80135a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801360:	c1 e8 0c             	shr    $0xc,%eax
  801363:	50                   	push   %eax
  801364:	e8 36 ff ff ff       	call   80129f <fd_lookup>
  801369:	83 c4 08             	add    $0x8,%esp
  80136c:	85 c0                	test   %eax,%eax
  80136e:	78 05                	js     801375 <fd_close+0x2d>
	    || fd != fd2)
  801370:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801373:	74 0c                	je     801381 <fd_close+0x39>
		return (must_exist ? r : 0);
  801375:	84 db                	test   %bl,%bl
  801377:	ba 00 00 00 00       	mov    $0x0,%edx
  80137c:	0f 44 c2             	cmove  %edx,%eax
  80137f:	eb 41                	jmp    8013c2 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801381:	83 ec 08             	sub    $0x8,%esp
  801384:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801387:	50                   	push   %eax
  801388:	ff 36                	pushl  (%esi)
  80138a:	e8 66 ff ff ff       	call   8012f5 <dev_lookup>
  80138f:	89 c3                	mov    %eax,%ebx
  801391:	83 c4 10             	add    $0x10,%esp
  801394:	85 c0                	test   %eax,%eax
  801396:	78 1a                	js     8013b2 <fd_close+0x6a>
		if (dev->dev_close)
  801398:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80139e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013a3:	85 c0                	test   %eax,%eax
  8013a5:	74 0b                	je     8013b2 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013a7:	83 ec 0c             	sub    $0xc,%esp
  8013aa:	56                   	push   %esi
  8013ab:	ff d0                	call   *%eax
  8013ad:	89 c3                	mov    %eax,%ebx
  8013af:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013b2:	83 ec 08             	sub    $0x8,%esp
  8013b5:	56                   	push   %esi
  8013b6:	6a 00                	push   $0x0
  8013b8:	e8 e1 f8 ff ff       	call   800c9e <sys_page_unmap>
	return r;
  8013bd:	83 c4 10             	add    $0x10,%esp
  8013c0:	89 d8                	mov    %ebx,%eax
}
  8013c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013c5:	5b                   	pop    %ebx
  8013c6:	5e                   	pop    %esi
  8013c7:	5d                   	pop    %ebp
  8013c8:	c3                   	ret    

008013c9 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013c9:	55                   	push   %ebp
  8013ca:	89 e5                	mov    %esp,%ebp
  8013cc:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d2:	50                   	push   %eax
  8013d3:	ff 75 08             	pushl  0x8(%ebp)
  8013d6:	e8 c4 fe ff ff       	call   80129f <fd_lookup>
  8013db:	83 c4 08             	add    $0x8,%esp
  8013de:	85 c0                	test   %eax,%eax
  8013e0:	78 10                	js     8013f2 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013e2:	83 ec 08             	sub    $0x8,%esp
  8013e5:	6a 01                	push   $0x1
  8013e7:	ff 75 f4             	pushl  -0xc(%ebp)
  8013ea:	e8 59 ff ff ff       	call   801348 <fd_close>
  8013ef:	83 c4 10             	add    $0x10,%esp
}
  8013f2:	c9                   	leave  
  8013f3:	c3                   	ret    

008013f4 <close_all>:

void
close_all(void)
{
  8013f4:	55                   	push   %ebp
  8013f5:	89 e5                	mov    %esp,%ebp
  8013f7:	53                   	push   %ebx
  8013f8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013fb:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801400:	83 ec 0c             	sub    $0xc,%esp
  801403:	53                   	push   %ebx
  801404:	e8 c0 ff ff ff       	call   8013c9 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801409:	83 c3 01             	add    $0x1,%ebx
  80140c:	83 c4 10             	add    $0x10,%esp
  80140f:	83 fb 20             	cmp    $0x20,%ebx
  801412:	75 ec                	jne    801400 <close_all+0xc>
		close(i);
}
  801414:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801417:	c9                   	leave  
  801418:	c3                   	ret    

00801419 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801419:	55                   	push   %ebp
  80141a:	89 e5                	mov    %esp,%ebp
  80141c:	57                   	push   %edi
  80141d:	56                   	push   %esi
  80141e:	53                   	push   %ebx
  80141f:	83 ec 2c             	sub    $0x2c,%esp
  801422:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801425:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801428:	50                   	push   %eax
  801429:	ff 75 08             	pushl  0x8(%ebp)
  80142c:	e8 6e fe ff ff       	call   80129f <fd_lookup>
  801431:	83 c4 08             	add    $0x8,%esp
  801434:	85 c0                	test   %eax,%eax
  801436:	0f 88 c1 00 00 00    	js     8014fd <dup+0xe4>
		return r;
	close(newfdnum);
  80143c:	83 ec 0c             	sub    $0xc,%esp
  80143f:	56                   	push   %esi
  801440:	e8 84 ff ff ff       	call   8013c9 <close>

	newfd = INDEX2FD(newfdnum);
  801445:	89 f3                	mov    %esi,%ebx
  801447:	c1 e3 0c             	shl    $0xc,%ebx
  80144a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801450:	83 c4 04             	add    $0x4,%esp
  801453:	ff 75 e4             	pushl  -0x1c(%ebp)
  801456:	e8 de fd ff ff       	call   801239 <fd2data>
  80145b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80145d:	89 1c 24             	mov    %ebx,(%esp)
  801460:	e8 d4 fd ff ff       	call   801239 <fd2data>
  801465:	83 c4 10             	add    $0x10,%esp
  801468:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80146b:	89 f8                	mov    %edi,%eax
  80146d:	c1 e8 16             	shr    $0x16,%eax
  801470:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801477:	a8 01                	test   $0x1,%al
  801479:	74 37                	je     8014b2 <dup+0x99>
  80147b:	89 f8                	mov    %edi,%eax
  80147d:	c1 e8 0c             	shr    $0xc,%eax
  801480:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801487:	f6 c2 01             	test   $0x1,%dl
  80148a:	74 26                	je     8014b2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80148c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801493:	83 ec 0c             	sub    $0xc,%esp
  801496:	25 07 0e 00 00       	and    $0xe07,%eax
  80149b:	50                   	push   %eax
  80149c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80149f:	6a 00                	push   $0x0
  8014a1:	57                   	push   %edi
  8014a2:	6a 00                	push   $0x0
  8014a4:	e8 b3 f7 ff ff       	call   800c5c <sys_page_map>
  8014a9:	89 c7                	mov    %eax,%edi
  8014ab:	83 c4 20             	add    $0x20,%esp
  8014ae:	85 c0                	test   %eax,%eax
  8014b0:	78 2e                	js     8014e0 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014b2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014b5:	89 d0                	mov    %edx,%eax
  8014b7:	c1 e8 0c             	shr    $0xc,%eax
  8014ba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014c1:	83 ec 0c             	sub    $0xc,%esp
  8014c4:	25 07 0e 00 00       	and    $0xe07,%eax
  8014c9:	50                   	push   %eax
  8014ca:	53                   	push   %ebx
  8014cb:	6a 00                	push   $0x0
  8014cd:	52                   	push   %edx
  8014ce:	6a 00                	push   $0x0
  8014d0:	e8 87 f7 ff ff       	call   800c5c <sys_page_map>
  8014d5:	89 c7                	mov    %eax,%edi
  8014d7:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014da:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014dc:	85 ff                	test   %edi,%edi
  8014de:	79 1d                	jns    8014fd <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014e0:	83 ec 08             	sub    $0x8,%esp
  8014e3:	53                   	push   %ebx
  8014e4:	6a 00                	push   $0x0
  8014e6:	e8 b3 f7 ff ff       	call   800c9e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014eb:	83 c4 08             	add    $0x8,%esp
  8014ee:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014f1:	6a 00                	push   $0x0
  8014f3:	e8 a6 f7 ff ff       	call   800c9e <sys_page_unmap>
	return r;
  8014f8:	83 c4 10             	add    $0x10,%esp
  8014fb:	89 f8                	mov    %edi,%eax
}
  8014fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801500:	5b                   	pop    %ebx
  801501:	5e                   	pop    %esi
  801502:	5f                   	pop    %edi
  801503:	5d                   	pop    %ebp
  801504:	c3                   	ret    

00801505 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
  801508:	53                   	push   %ebx
  801509:	83 ec 14             	sub    $0x14,%esp
  80150c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80150f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801512:	50                   	push   %eax
  801513:	53                   	push   %ebx
  801514:	e8 86 fd ff ff       	call   80129f <fd_lookup>
  801519:	83 c4 08             	add    $0x8,%esp
  80151c:	89 c2                	mov    %eax,%edx
  80151e:	85 c0                	test   %eax,%eax
  801520:	78 6d                	js     80158f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801522:	83 ec 08             	sub    $0x8,%esp
  801525:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801528:	50                   	push   %eax
  801529:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152c:	ff 30                	pushl  (%eax)
  80152e:	e8 c2 fd ff ff       	call   8012f5 <dev_lookup>
  801533:	83 c4 10             	add    $0x10,%esp
  801536:	85 c0                	test   %eax,%eax
  801538:	78 4c                	js     801586 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80153a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80153d:	8b 42 08             	mov    0x8(%edx),%eax
  801540:	83 e0 03             	and    $0x3,%eax
  801543:	83 f8 01             	cmp    $0x1,%eax
  801546:	75 21                	jne    801569 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801548:	a1 04 40 80 00       	mov    0x804004,%eax
  80154d:	8b 40 50             	mov    0x50(%eax),%eax
  801550:	83 ec 04             	sub    $0x4,%esp
  801553:	53                   	push   %ebx
  801554:	50                   	push   %eax
  801555:	68 04 27 80 00       	push   $0x802704
  80155a:	e8 32 ed ff ff       	call   800291 <cprintf>
		return -E_INVAL;
  80155f:	83 c4 10             	add    $0x10,%esp
  801562:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801567:	eb 26                	jmp    80158f <read+0x8a>
	}
	if (!dev->dev_read)
  801569:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80156c:	8b 40 08             	mov    0x8(%eax),%eax
  80156f:	85 c0                	test   %eax,%eax
  801571:	74 17                	je     80158a <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801573:	83 ec 04             	sub    $0x4,%esp
  801576:	ff 75 10             	pushl  0x10(%ebp)
  801579:	ff 75 0c             	pushl  0xc(%ebp)
  80157c:	52                   	push   %edx
  80157d:	ff d0                	call   *%eax
  80157f:	89 c2                	mov    %eax,%edx
  801581:	83 c4 10             	add    $0x10,%esp
  801584:	eb 09                	jmp    80158f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801586:	89 c2                	mov    %eax,%edx
  801588:	eb 05                	jmp    80158f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80158a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80158f:	89 d0                	mov    %edx,%eax
  801591:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801594:	c9                   	leave  
  801595:	c3                   	ret    

00801596 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801596:	55                   	push   %ebp
  801597:	89 e5                	mov    %esp,%ebp
  801599:	57                   	push   %edi
  80159a:	56                   	push   %esi
  80159b:	53                   	push   %ebx
  80159c:	83 ec 0c             	sub    $0xc,%esp
  80159f:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015a2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015aa:	eb 21                	jmp    8015cd <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015ac:	83 ec 04             	sub    $0x4,%esp
  8015af:	89 f0                	mov    %esi,%eax
  8015b1:	29 d8                	sub    %ebx,%eax
  8015b3:	50                   	push   %eax
  8015b4:	89 d8                	mov    %ebx,%eax
  8015b6:	03 45 0c             	add    0xc(%ebp),%eax
  8015b9:	50                   	push   %eax
  8015ba:	57                   	push   %edi
  8015bb:	e8 45 ff ff ff       	call   801505 <read>
		if (m < 0)
  8015c0:	83 c4 10             	add    $0x10,%esp
  8015c3:	85 c0                	test   %eax,%eax
  8015c5:	78 10                	js     8015d7 <readn+0x41>
			return m;
		if (m == 0)
  8015c7:	85 c0                	test   %eax,%eax
  8015c9:	74 0a                	je     8015d5 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015cb:	01 c3                	add    %eax,%ebx
  8015cd:	39 f3                	cmp    %esi,%ebx
  8015cf:	72 db                	jb     8015ac <readn+0x16>
  8015d1:	89 d8                	mov    %ebx,%eax
  8015d3:	eb 02                	jmp    8015d7 <readn+0x41>
  8015d5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015da:	5b                   	pop    %ebx
  8015db:	5e                   	pop    %esi
  8015dc:	5f                   	pop    %edi
  8015dd:	5d                   	pop    %ebp
  8015de:	c3                   	ret    

008015df <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015df:	55                   	push   %ebp
  8015e0:	89 e5                	mov    %esp,%ebp
  8015e2:	53                   	push   %ebx
  8015e3:	83 ec 14             	sub    $0x14,%esp
  8015e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ec:	50                   	push   %eax
  8015ed:	53                   	push   %ebx
  8015ee:	e8 ac fc ff ff       	call   80129f <fd_lookup>
  8015f3:	83 c4 08             	add    $0x8,%esp
  8015f6:	89 c2                	mov    %eax,%edx
  8015f8:	85 c0                	test   %eax,%eax
  8015fa:	78 68                	js     801664 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015fc:	83 ec 08             	sub    $0x8,%esp
  8015ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801602:	50                   	push   %eax
  801603:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801606:	ff 30                	pushl  (%eax)
  801608:	e8 e8 fc ff ff       	call   8012f5 <dev_lookup>
  80160d:	83 c4 10             	add    $0x10,%esp
  801610:	85 c0                	test   %eax,%eax
  801612:	78 47                	js     80165b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801614:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801617:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80161b:	75 21                	jne    80163e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80161d:	a1 04 40 80 00       	mov    0x804004,%eax
  801622:	8b 40 50             	mov    0x50(%eax),%eax
  801625:	83 ec 04             	sub    $0x4,%esp
  801628:	53                   	push   %ebx
  801629:	50                   	push   %eax
  80162a:	68 20 27 80 00       	push   $0x802720
  80162f:	e8 5d ec ff ff       	call   800291 <cprintf>
		return -E_INVAL;
  801634:	83 c4 10             	add    $0x10,%esp
  801637:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80163c:	eb 26                	jmp    801664 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80163e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801641:	8b 52 0c             	mov    0xc(%edx),%edx
  801644:	85 d2                	test   %edx,%edx
  801646:	74 17                	je     80165f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801648:	83 ec 04             	sub    $0x4,%esp
  80164b:	ff 75 10             	pushl  0x10(%ebp)
  80164e:	ff 75 0c             	pushl  0xc(%ebp)
  801651:	50                   	push   %eax
  801652:	ff d2                	call   *%edx
  801654:	89 c2                	mov    %eax,%edx
  801656:	83 c4 10             	add    $0x10,%esp
  801659:	eb 09                	jmp    801664 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165b:	89 c2                	mov    %eax,%edx
  80165d:	eb 05                	jmp    801664 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80165f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801664:	89 d0                	mov    %edx,%eax
  801666:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801669:	c9                   	leave  
  80166a:	c3                   	ret    

0080166b <seek>:

int
seek(int fdnum, off_t offset)
{
  80166b:	55                   	push   %ebp
  80166c:	89 e5                	mov    %esp,%ebp
  80166e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801671:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801674:	50                   	push   %eax
  801675:	ff 75 08             	pushl  0x8(%ebp)
  801678:	e8 22 fc ff ff       	call   80129f <fd_lookup>
  80167d:	83 c4 08             	add    $0x8,%esp
  801680:	85 c0                	test   %eax,%eax
  801682:	78 0e                	js     801692 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801684:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801687:	8b 55 0c             	mov    0xc(%ebp),%edx
  80168a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80168d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801692:	c9                   	leave  
  801693:	c3                   	ret    

00801694 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801694:	55                   	push   %ebp
  801695:	89 e5                	mov    %esp,%ebp
  801697:	53                   	push   %ebx
  801698:	83 ec 14             	sub    $0x14,%esp
  80169b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80169e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016a1:	50                   	push   %eax
  8016a2:	53                   	push   %ebx
  8016a3:	e8 f7 fb ff ff       	call   80129f <fd_lookup>
  8016a8:	83 c4 08             	add    $0x8,%esp
  8016ab:	89 c2                	mov    %eax,%edx
  8016ad:	85 c0                	test   %eax,%eax
  8016af:	78 65                	js     801716 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b1:	83 ec 08             	sub    $0x8,%esp
  8016b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b7:	50                   	push   %eax
  8016b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016bb:	ff 30                	pushl  (%eax)
  8016bd:	e8 33 fc ff ff       	call   8012f5 <dev_lookup>
  8016c2:	83 c4 10             	add    $0x10,%esp
  8016c5:	85 c0                	test   %eax,%eax
  8016c7:	78 44                	js     80170d <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016cc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016d0:	75 21                	jne    8016f3 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016d2:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016d7:	8b 40 50             	mov    0x50(%eax),%eax
  8016da:	83 ec 04             	sub    $0x4,%esp
  8016dd:	53                   	push   %ebx
  8016de:	50                   	push   %eax
  8016df:	68 e0 26 80 00       	push   $0x8026e0
  8016e4:	e8 a8 eb ff ff       	call   800291 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016e9:	83 c4 10             	add    $0x10,%esp
  8016ec:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016f1:	eb 23                	jmp    801716 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f6:	8b 52 18             	mov    0x18(%edx),%edx
  8016f9:	85 d2                	test   %edx,%edx
  8016fb:	74 14                	je     801711 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016fd:	83 ec 08             	sub    $0x8,%esp
  801700:	ff 75 0c             	pushl  0xc(%ebp)
  801703:	50                   	push   %eax
  801704:	ff d2                	call   *%edx
  801706:	89 c2                	mov    %eax,%edx
  801708:	83 c4 10             	add    $0x10,%esp
  80170b:	eb 09                	jmp    801716 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80170d:	89 c2                	mov    %eax,%edx
  80170f:	eb 05                	jmp    801716 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801711:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801716:	89 d0                	mov    %edx,%eax
  801718:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171b:	c9                   	leave  
  80171c:	c3                   	ret    

0080171d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	53                   	push   %ebx
  801721:	83 ec 14             	sub    $0x14,%esp
  801724:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801727:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80172a:	50                   	push   %eax
  80172b:	ff 75 08             	pushl  0x8(%ebp)
  80172e:	e8 6c fb ff ff       	call   80129f <fd_lookup>
  801733:	83 c4 08             	add    $0x8,%esp
  801736:	89 c2                	mov    %eax,%edx
  801738:	85 c0                	test   %eax,%eax
  80173a:	78 58                	js     801794 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173c:	83 ec 08             	sub    $0x8,%esp
  80173f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801742:	50                   	push   %eax
  801743:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801746:	ff 30                	pushl  (%eax)
  801748:	e8 a8 fb ff ff       	call   8012f5 <dev_lookup>
  80174d:	83 c4 10             	add    $0x10,%esp
  801750:	85 c0                	test   %eax,%eax
  801752:	78 37                	js     80178b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801754:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801757:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80175b:	74 32                	je     80178f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80175d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801760:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801767:	00 00 00 
	stat->st_isdir = 0;
  80176a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801771:	00 00 00 
	stat->st_dev = dev;
  801774:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80177a:	83 ec 08             	sub    $0x8,%esp
  80177d:	53                   	push   %ebx
  80177e:	ff 75 f0             	pushl  -0x10(%ebp)
  801781:	ff 50 14             	call   *0x14(%eax)
  801784:	89 c2                	mov    %eax,%edx
  801786:	83 c4 10             	add    $0x10,%esp
  801789:	eb 09                	jmp    801794 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80178b:	89 c2                	mov    %eax,%edx
  80178d:	eb 05                	jmp    801794 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80178f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801794:	89 d0                	mov    %edx,%eax
  801796:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801799:	c9                   	leave  
  80179a:	c3                   	ret    

0080179b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80179b:	55                   	push   %ebp
  80179c:	89 e5                	mov    %esp,%ebp
  80179e:	56                   	push   %esi
  80179f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017a0:	83 ec 08             	sub    $0x8,%esp
  8017a3:	6a 00                	push   $0x0
  8017a5:	ff 75 08             	pushl  0x8(%ebp)
  8017a8:	e8 e3 01 00 00       	call   801990 <open>
  8017ad:	89 c3                	mov    %eax,%ebx
  8017af:	83 c4 10             	add    $0x10,%esp
  8017b2:	85 c0                	test   %eax,%eax
  8017b4:	78 1b                	js     8017d1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017b6:	83 ec 08             	sub    $0x8,%esp
  8017b9:	ff 75 0c             	pushl  0xc(%ebp)
  8017bc:	50                   	push   %eax
  8017bd:	e8 5b ff ff ff       	call   80171d <fstat>
  8017c2:	89 c6                	mov    %eax,%esi
	close(fd);
  8017c4:	89 1c 24             	mov    %ebx,(%esp)
  8017c7:	e8 fd fb ff ff       	call   8013c9 <close>
	return r;
  8017cc:	83 c4 10             	add    $0x10,%esp
  8017cf:	89 f0                	mov    %esi,%eax
}
  8017d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d4:	5b                   	pop    %ebx
  8017d5:	5e                   	pop    %esi
  8017d6:	5d                   	pop    %ebp
  8017d7:	c3                   	ret    

008017d8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017d8:	55                   	push   %ebp
  8017d9:	89 e5                	mov    %esp,%ebp
  8017db:	56                   	push   %esi
  8017dc:	53                   	push   %ebx
  8017dd:	89 c6                	mov    %eax,%esi
  8017df:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017e1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017e8:	75 12                	jne    8017fc <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017ea:	83 ec 0c             	sub    $0xc,%esp
  8017ed:	6a 01                	push   $0x1
  8017ef:	e8 f5 f9 ff ff       	call   8011e9 <ipc_find_env>
  8017f4:	a3 00 40 80 00       	mov    %eax,0x804000
  8017f9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017fc:	6a 07                	push   $0x7
  8017fe:	68 00 50 80 00       	push   $0x805000
  801803:	56                   	push   %esi
  801804:	ff 35 00 40 80 00    	pushl  0x804000
  80180a:	e8 78 f9 ff ff       	call   801187 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80180f:	83 c4 0c             	add    $0xc,%esp
  801812:	6a 00                	push   $0x0
  801814:	53                   	push   %ebx
  801815:	6a 00                	push   $0x0
  801817:	e8 f6 f8 ff ff       	call   801112 <ipc_recv>
}
  80181c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80181f:	5b                   	pop    %ebx
  801820:	5e                   	pop    %esi
  801821:	5d                   	pop    %ebp
  801822:	c3                   	ret    

00801823 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801823:	55                   	push   %ebp
  801824:	89 e5                	mov    %esp,%ebp
  801826:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801829:	8b 45 08             	mov    0x8(%ebp),%eax
  80182c:	8b 40 0c             	mov    0xc(%eax),%eax
  80182f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801834:	8b 45 0c             	mov    0xc(%ebp),%eax
  801837:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80183c:	ba 00 00 00 00       	mov    $0x0,%edx
  801841:	b8 02 00 00 00       	mov    $0x2,%eax
  801846:	e8 8d ff ff ff       	call   8017d8 <fsipc>
}
  80184b:	c9                   	leave  
  80184c:	c3                   	ret    

0080184d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80184d:	55                   	push   %ebp
  80184e:	89 e5                	mov    %esp,%ebp
  801850:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801853:	8b 45 08             	mov    0x8(%ebp),%eax
  801856:	8b 40 0c             	mov    0xc(%eax),%eax
  801859:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80185e:	ba 00 00 00 00       	mov    $0x0,%edx
  801863:	b8 06 00 00 00       	mov    $0x6,%eax
  801868:	e8 6b ff ff ff       	call   8017d8 <fsipc>
}
  80186d:	c9                   	leave  
  80186e:	c3                   	ret    

0080186f <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80186f:	55                   	push   %ebp
  801870:	89 e5                	mov    %esp,%ebp
  801872:	53                   	push   %ebx
  801873:	83 ec 04             	sub    $0x4,%esp
  801876:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801879:	8b 45 08             	mov    0x8(%ebp),%eax
  80187c:	8b 40 0c             	mov    0xc(%eax),%eax
  80187f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801884:	ba 00 00 00 00       	mov    $0x0,%edx
  801889:	b8 05 00 00 00       	mov    $0x5,%eax
  80188e:	e8 45 ff ff ff       	call   8017d8 <fsipc>
  801893:	85 c0                	test   %eax,%eax
  801895:	78 2c                	js     8018c3 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801897:	83 ec 08             	sub    $0x8,%esp
  80189a:	68 00 50 80 00       	push   $0x805000
  80189f:	53                   	push   %ebx
  8018a0:	e8 71 ef ff ff       	call   800816 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018a5:	a1 80 50 80 00       	mov    0x805080,%eax
  8018aa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018b0:	a1 84 50 80 00       	mov    0x805084,%eax
  8018b5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018bb:	83 c4 10             	add    $0x10,%esp
  8018be:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c6:	c9                   	leave  
  8018c7:	c3                   	ret    

008018c8 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	83 ec 0c             	sub    $0xc,%esp
  8018ce:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8018d4:	8b 52 0c             	mov    0xc(%edx),%edx
  8018d7:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8018dd:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018e2:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018e7:	0f 47 c2             	cmova  %edx,%eax
  8018ea:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8018ef:	50                   	push   %eax
  8018f0:	ff 75 0c             	pushl  0xc(%ebp)
  8018f3:	68 08 50 80 00       	push   $0x805008
  8018f8:	e8 ab f0 ff ff       	call   8009a8 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8018fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801902:	b8 04 00 00 00       	mov    $0x4,%eax
  801907:	e8 cc fe ff ff       	call   8017d8 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80190c:	c9                   	leave  
  80190d:	c3                   	ret    

0080190e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	56                   	push   %esi
  801912:	53                   	push   %ebx
  801913:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801916:	8b 45 08             	mov    0x8(%ebp),%eax
  801919:	8b 40 0c             	mov    0xc(%eax),%eax
  80191c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801921:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801927:	ba 00 00 00 00       	mov    $0x0,%edx
  80192c:	b8 03 00 00 00       	mov    $0x3,%eax
  801931:	e8 a2 fe ff ff       	call   8017d8 <fsipc>
  801936:	89 c3                	mov    %eax,%ebx
  801938:	85 c0                	test   %eax,%eax
  80193a:	78 4b                	js     801987 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80193c:	39 c6                	cmp    %eax,%esi
  80193e:	73 16                	jae    801956 <devfile_read+0x48>
  801940:	68 50 27 80 00       	push   $0x802750
  801945:	68 57 27 80 00       	push   $0x802757
  80194a:	6a 7c                	push   $0x7c
  80194c:	68 6c 27 80 00       	push   $0x80276c
  801951:	e8 62 e8 ff ff       	call   8001b8 <_panic>
	assert(r <= PGSIZE);
  801956:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80195b:	7e 16                	jle    801973 <devfile_read+0x65>
  80195d:	68 77 27 80 00       	push   $0x802777
  801962:	68 57 27 80 00       	push   $0x802757
  801967:	6a 7d                	push   $0x7d
  801969:	68 6c 27 80 00       	push   $0x80276c
  80196e:	e8 45 e8 ff ff       	call   8001b8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801973:	83 ec 04             	sub    $0x4,%esp
  801976:	50                   	push   %eax
  801977:	68 00 50 80 00       	push   $0x805000
  80197c:	ff 75 0c             	pushl  0xc(%ebp)
  80197f:	e8 24 f0 ff ff       	call   8009a8 <memmove>
	return r;
  801984:	83 c4 10             	add    $0x10,%esp
}
  801987:	89 d8                	mov    %ebx,%eax
  801989:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80198c:	5b                   	pop    %ebx
  80198d:	5e                   	pop    %esi
  80198e:	5d                   	pop    %ebp
  80198f:	c3                   	ret    

00801990 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	53                   	push   %ebx
  801994:	83 ec 20             	sub    $0x20,%esp
  801997:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80199a:	53                   	push   %ebx
  80199b:	e8 3d ee ff ff       	call   8007dd <strlen>
  8019a0:	83 c4 10             	add    $0x10,%esp
  8019a3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019a8:	7f 67                	jg     801a11 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019aa:	83 ec 0c             	sub    $0xc,%esp
  8019ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b0:	50                   	push   %eax
  8019b1:	e8 9a f8 ff ff       	call   801250 <fd_alloc>
  8019b6:	83 c4 10             	add    $0x10,%esp
		return r;
  8019b9:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019bb:	85 c0                	test   %eax,%eax
  8019bd:	78 57                	js     801a16 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019bf:	83 ec 08             	sub    $0x8,%esp
  8019c2:	53                   	push   %ebx
  8019c3:	68 00 50 80 00       	push   $0x805000
  8019c8:	e8 49 ee ff ff       	call   800816 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d0:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019d8:	b8 01 00 00 00       	mov    $0x1,%eax
  8019dd:	e8 f6 fd ff ff       	call   8017d8 <fsipc>
  8019e2:	89 c3                	mov    %eax,%ebx
  8019e4:	83 c4 10             	add    $0x10,%esp
  8019e7:	85 c0                	test   %eax,%eax
  8019e9:	79 14                	jns    8019ff <open+0x6f>
		fd_close(fd, 0);
  8019eb:	83 ec 08             	sub    $0x8,%esp
  8019ee:	6a 00                	push   $0x0
  8019f0:	ff 75 f4             	pushl  -0xc(%ebp)
  8019f3:	e8 50 f9 ff ff       	call   801348 <fd_close>
		return r;
  8019f8:	83 c4 10             	add    $0x10,%esp
  8019fb:	89 da                	mov    %ebx,%edx
  8019fd:	eb 17                	jmp    801a16 <open+0x86>
	}

	return fd2num(fd);
  8019ff:	83 ec 0c             	sub    $0xc,%esp
  801a02:	ff 75 f4             	pushl  -0xc(%ebp)
  801a05:	e8 1f f8 ff ff       	call   801229 <fd2num>
  801a0a:	89 c2                	mov    %eax,%edx
  801a0c:	83 c4 10             	add    $0x10,%esp
  801a0f:	eb 05                	jmp    801a16 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a11:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a16:	89 d0                	mov    %edx,%eax
  801a18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a1b:	c9                   	leave  
  801a1c:	c3                   	ret    

00801a1d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
  801a20:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a23:	ba 00 00 00 00       	mov    $0x0,%edx
  801a28:	b8 08 00 00 00       	mov    $0x8,%eax
  801a2d:	e8 a6 fd ff ff       	call   8017d8 <fsipc>
}
  801a32:	c9                   	leave  
  801a33:	c3                   	ret    

00801a34 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a34:	55                   	push   %ebp
  801a35:	89 e5                	mov    %esp,%ebp
  801a37:	56                   	push   %esi
  801a38:	53                   	push   %ebx
  801a39:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a3c:	83 ec 0c             	sub    $0xc,%esp
  801a3f:	ff 75 08             	pushl  0x8(%ebp)
  801a42:	e8 f2 f7 ff ff       	call   801239 <fd2data>
  801a47:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a49:	83 c4 08             	add    $0x8,%esp
  801a4c:	68 83 27 80 00       	push   $0x802783
  801a51:	53                   	push   %ebx
  801a52:	e8 bf ed ff ff       	call   800816 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a57:	8b 46 04             	mov    0x4(%esi),%eax
  801a5a:	2b 06                	sub    (%esi),%eax
  801a5c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a62:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a69:	00 00 00 
	stat->st_dev = &devpipe;
  801a6c:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a73:	30 80 00 
	return 0;
}
  801a76:	b8 00 00 00 00       	mov    $0x0,%eax
  801a7b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7e:	5b                   	pop    %ebx
  801a7f:	5e                   	pop    %esi
  801a80:	5d                   	pop    %ebp
  801a81:	c3                   	ret    

00801a82 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	53                   	push   %ebx
  801a86:	83 ec 0c             	sub    $0xc,%esp
  801a89:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a8c:	53                   	push   %ebx
  801a8d:	6a 00                	push   $0x0
  801a8f:	e8 0a f2 ff ff       	call   800c9e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a94:	89 1c 24             	mov    %ebx,(%esp)
  801a97:	e8 9d f7 ff ff       	call   801239 <fd2data>
  801a9c:	83 c4 08             	add    $0x8,%esp
  801a9f:	50                   	push   %eax
  801aa0:	6a 00                	push   $0x0
  801aa2:	e8 f7 f1 ff ff       	call   800c9e <sys_page_unmap>
}
  801aa7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aaa:	c9                   	leave  
  801aab:	c3                   	ret    

00801aac <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801aac:	55                   	push   %ebp
  801aad:	89 e5                	mov    %esp,%ebp
  801aaf:	57                   	push   %edi
  801ab0:	56                   	push   %esi
  801ab1:	53                   	push   %ebx
  801ab2:	83 ec 1c             	sub    $0x1c,%esp
  801ab5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ab8:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801aba:	a1 04 40 80 00       	mov    0x804004,%eax
  801abf:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ac2:	83 ec 0c             	sub    $0xc,%esp
  801ac5:	ff 75 e0             	pushl  -0x20(%ebp)
  801ac8:	e8 d5 04 00 00       	call   801fa2 <pageref>
  801acd:	89 c3                	mov    %eax,%ebx
  801acf:	89 3c 24             	mov    %edi,(%esp)
  801ad2:	e8 cb 04 00 00       	call   801fa2 <pageref>
  801ad7:	83 c4 10             	add    $0x10,%esp
  801ada:	39 c3                	cmp    %eax,%ebx
  801adc:	0f 94 c1             	sete   %cl
  801adf:	0f b6 c9             	movzbl %cl,%ecx
  801ae2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ae5:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801aeb:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  801aee:	39 ce                	cmp    %ecx,%esi
  801af0:	74 1b                	je     801b0d <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801af2:	39 c3                	cmp    %eax,%ebx
  801af4:	75 c4                	jne    801aba <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801af6:	8b 42 60             	mov    0x60(%edx),%eax
  801af9:	ff 75 e4             	pushl  -0x1c(%ebp)
  801afc:	50                   	push   %eax
  801afd:	56                   	push   %esi
  801afe:	68 8a 27 80 00       	push   $0x80278a
  801b03:	e8 89 e7 ff ff       	call   800291 <cprintf>
  801b08:	83 c4 10             	add    $0x10,%esp
  801b0b:	eb ad                	jmp    801aba <_pipeisclosed+0xe>
	}
}
  801b0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b13:	5b                   	pop    %ebx
  801b14:	5e                   	pop    %esi
  801b15:	5f                   	pop    %edi
  801b16:	5d                   	pop    %ebp
  801b17:	c3                   	ret    

00801b18 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b18:	55                   	push   %ebp
  801b19:	89 e5                	mov    %esp,%ebp
  801b1b:	57                   	push   %edi
  801b1c:	56                   	push   %esi
  801b1d:	53                   	push   %ebx
  801b1e:	83 ec 28             	sub    $0x28,%esp
  801b21:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b24:	56                   	push   %esi
  801b25:	e8 0f f7 ff ff       	call   801239 <fd2data>
  801b2a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b2c:	83 c4 10             	add    $0x10,%esp
  801b2f:	bf 00 00 00 00       	mov    $0x0,%edi
  801b34:	eb 4b                	jmp    801b81 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b36:	89 da                	mov    %ebx,%edx
  801b38:	89 f0                	mov    %esi,%eax
  801b3a:	e8 6d ff ff ff       	call   801aac <_pipeisclosed>
  801b3f:	85 c0                	test   %eax,%eax
  801b41:	75 48                	jne    801b8b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b43:	e8 b2 f0 ff ff       	call   800bfa <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b48:	8b 43 04             	mov    0x4(%ebx),%eax
  801b4b:	8b 0b                	mov    (%ebx),%ecx
  801b4d:	8d 51 20             	lea    0x20(%ecx),%edx
  801b50:	39 d0                	cmp    %edx,%eax
  801b52:	73 e2                	jae    801b36 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b57:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b5b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b5e:	89 c2                	mov    %eax,%edx
  801b60:	c1 fa 1f             	sar    $0x1f,%edx
  801b63:	89 d1                	mov    %edx,%ecx
  801b65:	c1 e9 1b             	shr    $0x1b,%ecx
  801b68:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b6b:	83 e2 1f             	and    $0x1f,%edx
  801b6e:	29 ca                	sub    %ecx,%edx
  801b70:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b74:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b78:	83 c0 01             	add    $0x1,%eax
  801b7b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b7e:	83 c7 01             	add    $0x1,%edi
  801b81:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b84:	75 c2                	jne    801b48 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b86:	8b 45 10             	mov    0x10(%ebp),%eax
  801b89:	eb 05                	jmp    801b90 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b8b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b93:	5b                   	pop    %ebx
  801b94:	5e                   	pop    %esi
  801b95:	5f                   	pop    %edi
  801b96:	5d                   	pop    %ebp
  801b97:	c3                   	ret    

00801b98 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b98:	55                   	push   %ebp
  801b99:	89 e5                	mov    %esp,%ebp
  801b9b:	57                   	push   %edi
  801b9c:	56                   	push   %esi
  801b9d:	53                   	push   %ebx
  801b9e:	83 ec 18             	sub    $0x18,%esp
  801ba1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ba4:	57                   	push   %edi
  801ba5:	e8 8f f6 ff ff       	call   801239 <fd2data>
  801baa:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bac:	83 c4 10             	add    $0x10,%esp
  801baf:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bb4:	eb 3d                	jmp    801bf3 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bb6:	85 db                	test   %ebx,%ebx
  801bb8:	74 04                	je     801bbe <devpipe_read+0x26>
				return i;
  801bba:	89 d8                	mov    %ebx,%eax
  801bbc:	eb 44                	jmp    801c02 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bbe:	89 f2                	mov    %esi,%edx
  801bc0:	89 f8                	mov    %edi,%eax
  801bc2:	e8 e5 fe ff ff       	call   801aac <_pipeisclosed>
  801bc7:	85 c0                	test   %eax,%eax
  801bc9:	75 32                	jne    801bfd <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bcb:	e8 2a f0 ff ff       	call   800bfa <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bd0:	8b 06                	mov    (%esi),%eax
  801bd2:	3b 46 04             	cmp    0x4(%esi),%eax
  801bd5:	74 df                	je     801bb6 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bd7:	99                   	cltd   
  801bd8:	c1 ea 1b             	shr    $0x1b,%edx
  801bdb:	01 d0                	add    %edx,%eax
  801bdd:	83 e0 1f             	and    $0x1f,%eax
  801be0:	29 d0                	sub    %edx,%eax
  801be2:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801be7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bea:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bed:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bf0:	83 c3 01             	add    $0x1,%ebx
  801bf3:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bf6:	75 d8                	jne    801bd0 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bf8:	8b 45 10             	mov    0x10(%ebp),%eax
  801bfb:	eb 05                	jmp    801c02 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bfd:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c05:	5b                   	pop    %ebx
  801c06:	5e                   	pop    %esi
  801c07:	5f                   	pop    %edi
  801c08:	5d                   	pop    %ebp
  801c09:	c3                   	ret    

00801c0a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c0a:	55                   	push   %ebp
  801c0b:	89 e5                	mov    %esp,%ebp
  801c0d:	56                   	push   %esi
  801c0e:	53                   	push   %ebx
  801c0f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c15:	50                   	push   %eax
  801c16:	e8 35 f6 ff ff       	call   801250 <fd_alloc>
  801c1b:	83 c4 10             	add    $0x10,%esp
  801c1e:	89 c2                	mov    %eax,%edx
  801c20:	85 c0                	test   %eax,%eax
  801c22:	0f 88 2c 01 00 00    	js     801d54 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c28:	83 ec 04             	sub    $0x4,%esp
  801c2b:	68 07 04 00 00       	push   $0x407
  801c30:	ff 75 f4             	pushl  -0xc(%ebp)
  801c33:	6a 00                	push   $0x0
  801c35:	e8 df ef ff ff       	call   800c19 <sys_page_alloc>
  801c3a:	83 c4 10             	add    $0x10,%esp
  801c3d:	89 c2                	mov    %eax,%edx
  801c3f:	85 c0                	test   %eax,%eax
  801c41:	0f 88 0d 01 00 00    	js     801d54 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c47:	83 ec 0c             	sub    $0xc,%esp
  801c4a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c4d:	50                   	push   %eax
  801c4e:	e8 fd f5 ff ff       	call   801250 <fd_alloc>
  801c53:	89 c3                	mov    %eax,%ebx
  801c55:	83 c4 10             	add    $0x10,%esp
  801c58:	85 c0                	test   %eax,%eax
  801c5a:	0f 88 e2 00 00 00    	js     801d42 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c60:	83 ec 04             	sub    $0x4,%esp
  801c63:	68 07 04 00 00       	push   $0x407
  801c68:	ff 75 f0             	pushl  -0x10(%ebp)
  801c6b:	6a 00                	push   $0x0
  801c6d:	e8 a7 ef ff ff       	call   800c19 <sys_page_alloc>
  801c72:	89 c3                	mov    %eax,%ebx
  801c74:	83 c4 10             	add    $0x10,%esp
  801c77:	85 c0                	test   %eax,%eax
  801c79:	0f 88 c3 00 00 00    	js     801d42 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c7f:	83 ec 0c             	sub    $0xc,%esp
  801c82:	ff 75 f4             	pushl  -0xc(%ebp)
  801c85:	e8 af f5 ff ff       	call   801239 <fd2data>
  801c8a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c8c:	83 c4 0c             	add    $0xc,%esp
  801c8f:	68 07 04 00 00       	push   $0x407
  801c94:	50                   	push   %eax
  801c95:	6a 00                	push   $0x0
  801c97:	e8 7d ef ff ff       	call   800c19 <sys_page_alloc>
  801c9c:	89 c3                	mov    %eax,%ebx
  801c9e:	83 c4 10             	add    $0x10,%esp
  801ca1:	85 c0                	test   %eax,%eax
  801ca3:	0f 88 89 00 00 00    	js     801d32 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ca9:	83 ec 0c             	sub    $0xc,%esp
  801cac:	ff 75 f0             	pushl  -0x10(%ebp)
  801caf:	e8 85 f5 ff ff       	call   801239 <fd2data>
  801cb4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cbb:	50                   	push   %eax
  801cbc:	6a 00                	push   $0x0
  801cbe:	56                   	push   %esi
  801cbf:	6a 00                	push   $0x0
  801cc1:	e8 96 ef ff ff       	call   800c5c <sys_page_map>
  801cc6:	89 c3                	mov    %eax,%ebx
  801cc8:	83 c4 20             	add    $0x20,%esp
  801ccb:	85 c0                	test   %eax,%eax
  801ccd:	78 55                	js     801d24 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ccf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cdd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ce4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ced:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cf2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cf9:	83 ec 0c             	sub    $0xc,%esp
  801cfc:	ff 75 f4             	pushl  -0xc(%ebp)
  801cff:	e8 25 f5 ff ff       	call   801229 <fd2num>
  801d04:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d07:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d09:	83 c4 04             	add    $0x4,%esp
  801d0c:	ff 75 f0             	pushl  -0x10(%ebp)
  801d0f:	e8 15 f5 ff ff       	call   801229 <fd2num>
  801d14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d17:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801d1a:	83 c4 10             	add    $0x10,%esp
  801d1d:	ba 00 00 00 00       	mov    $0x0,%edx
  801d22:	eb 30                	jmp    801d54 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d24:	83 ec 08             	sub    $0x8,%esp
  801d27:	56                   	push   %esi
  801d28:	6a 00                	push   $0x0
  801d2a:	e8 6f ef ff ff       	call   800c9e <sys_page_unmap>
  801d2f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d32:	83 ec 08             	sub    $0x8,%esp
  801d35:	ff 75 f0             	pushl  -0x10(%ebp)
  801d38:	6a 00                	push   $0x0
  801d3a:	e8 5f ef ff ff       	call   800c9e <sys_page_unmap>
  801d3f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d42:	83 ec 08             	sub    $0x8,%esp
  801d45:	ff 75 f4             	pushl  -0xc(%ebp)
  801d48:	6a 00                	push   $0x0
  801d4a:	e8 4f ef ff ff       	call   800c9e <sys_page_unmap>
  801d4f:	83 c4 10             	add    $0x10,%esp
  801d52:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d54:	89 d0                	mov    %edx,%eax
  801d56:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d59:	5b                   	pop    %ebx
  801d5a:	5e                   	pop    %esi
  801d5b:	5d                   	pop    %ebp
  801d5c:	c3                   	ret    

00801d5d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d5d:	55                   	push   %ebp
  801d5e:	89 e5                	mov    %esp,%ebp
  801d60:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d63:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d66:	50                   	push   %eax
  801d67:	ff 75 08             	pushl  0x8(%ebp)
  801d6a:	e8 30 f5 ff ff       	call   80129f <fd_lookup>
  801d6f:	83 c4 10             	add    $0x10,%esp
  801d72:	85 c0                	test   %eax,%eax
  801d74:	78 18                	js     801d8e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d76:	83 ec 0c             	sub    $0xc,%esp
  801d79:	ff 75 f4             	pushl  -0xc(%ebp)
  801d7c:	e8 b8 f4 ff ff       	call   801239 <fd2data>
	return _pipeisclosed(fd, p);
  801d81:	89 c2                	mov    %eax,%edx
  801d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d86:	e8 21 fd ff ff       	call   801aac <_pipeisclosed>
  801d8b:	83 c4 10             	add    $0x10,%esp
}
  801d8e:	c9                   	leave  
  801d8f:	c3                   	ret    

00801d90 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d90:	55                   	push   %ebp
  801d91:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d93:	b8 00 00 00 00       	mov    $0x0,%eax
  801d98:	5d                   	pop    %ebp
  801d99:	c3                   	ret    

00801d9a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d9a:	55                   	push   %ebp
  801d9b:	89 e5                	mov    %esp,%ebp
  801d9d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801da0:	68 a2 27 80 00       	push   $0x8027a2
  801da5:	ff 75 0c             	pushl  0xc(%ebp)
  801da8:	e8 69 ea ff ff       	call   800816 <strcpy>
	return 0;
}
  801dad:	b8 00 00 00 00       	mov    $0x0,%eax
  801db2:	c9                   	leave  
  801db3:	c3                   	ret    

00801db4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801db4:	55                   	push   %ebp
  801db5:	89 e5                	mov    %esp,%ebp
  801db7:	57                   	push   %edi
  801db8:	56                   	push   %esi
  801db9:	53                   	push   %ebx
  801dba:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dc0:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dc5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dcb:	eb 2d                	jmp    801dfa <devcons_write+0x46>
		m = n - tot;
  801dcd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dd0:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801dd2:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dd5:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801dda:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ddd:	83 ec 04             	sub    $0x4,%esp
  801de0:	53                   	push   %ebx
  801de1:	03 45 0c             	add    0xc(%ebp),%eax
  801de4:	50                   	push   %eax
  801de5:	57                   	push   %edi
  801de6:	e8 bd eb ff ff       	call   8009a8 <memmove>
		sys_cputs(buf, m);
  801deb:	83 c4 08             	add    $0x8,%esp
  801dee:	53                   	push   %ebx
  801def:	57                   	push   %edi
  801df0:	e8 68 ed ff ff       	call   800b5d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801df5:	01 de                	add    %ebx,%esi
  801df7:	83 c4 10             	add    $0x10,%esp
  801dfa:	89 f0                	mov    %esi,%eax
  801dfc:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dff:	72 cc                	jb     801dcd <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e04:	5b                   	pop    %ebx
  801e05:	5e                   	pop    %esi
  801e06:	5f                   	pop    %edi
  801e07:	5d                   	pop    %ebp
  801e08:	c3                   	ret    

00801e09 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e09:	55                   	push   %ebp
  801e0a:	89 e5                	mov    %esp,%ebp
  801e0c:	83 ec 08             	sub    $0x8,%esp
  801e0f:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e14:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e18:	74 2a                	je     801e44 <devcons_read+0x3b>
  801e1a:	eb 05                	jmp    801e21 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e1c:	e8 d9 ed ff ff       	call   800bfa <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e21:	e8 55 ed ff ff       	call   800b7b <sys_cgetc>
  801e26:	85 c0                	test   %eax,%eax
  801e28:	74 f2                	je     801e1c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e2a:	85 c0                	test   %eax,%eax
  801e2c:	78 16                	js     801e44 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e2e:	83 f8 04             	cmp    $0x4,%eax
  801e31:	74 0c                	je     801e3f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e33:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e36:	88 02                	mov    %al,(%edx)
	return 1;
  801e38:	b8 01 00 00 00       	mov    $0x1,%eax
  801e3d:	eb 05                	jmp    801e44 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e3f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e44:	c9                   	leave  
  801e45:	c3                   	ret    

00801e46 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e46:	55                   	push   %ebp
  801e47:	89 e5                	mov    %esp,%ebp
  801e49:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e52:	6a 01                	push   $0x1
  801e54:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e57:	50                   	push   %eax
  801e58:	e8 00 ed ff ff       	call   800b5d <sys_cputs>
}
  801e5d:	83 c4 10             	add    $0x10,%esp
  801e60:	c9                   	leave  
  801e61:	c3                   	ret    

00801e62 <getchar>:

int
getchar(void)
{
  801e62:	55                   	push   %ebp
  801e63:	89 e5                	mov    %esp,%ebp
  801e65:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e68:	6a 01                	push   $0x1
  801e6a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e6d:	50                   	push   %eax
  801e6e:	6a 00                	push   $0x0
  801e70:	e8 90 f6 ff ff       	call   801505 <read>
	if (r < 0)
  801e75:	83 c4 10             	add    $0x10,%esp
  801e78:	85 c0                	test   %eax,%eax
  801e7a:	78 0f                	js     801e8b <getchar+0x29>
		return r;
	if (r < 1)
  801e7c:	85 c0                	test   %eax,%eax
  801e7e:	7e 06                	jle    801e86 <getchar+0x24>
		return -E_EOF;
	return c;
  801e80:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e84:	eb 05                	jmp    801e8b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e86:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e8b:	c9                   	leave  
  801e8c:	c3                   	ret    

00801e8d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e8d:	55                   	push   %ebp
  801e8e:	89 e5                	mov    %esp,%ebp
  801e90:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e93:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e96:	50                   	push   %eax
  801e97:	ff 75 08             	pushl  0x8(%ebp)
  801e9a:	e8 00 f4 ff ff       	call   80129f <fd_lookup>
  801e9f:	83 c4 10             	add    $0x10,%esp
  801ea2:	85 c0                	test   %eax,%eax
  801ea4:	78 11                	js     801eb7 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ea6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801eaf:	39 10                	cmp    %edx,(%eax)
  801eb1:	0f 94 c0             	sete   %al
  801eb4:	0f b6 c0             	movzbl %al,%eax
}
  801eb7:	c9                   	leave  
  801eb8:	c3                   	ret    

00801eb9 <opencons>:

int
opencons(void)
{
  801eb9:	55                   	push   %ebp
  801eba:	89 e5                	mov    %esp,%ebp
  801ebc:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ebf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ec2:	50                   	push   %eax
  801ec3:	e8 88 f3 ff ff       	call   801250 <fd_alloc>
  801ec8:	83 c4 10             	add    $0x10,%esp
		return r;
  801ecb:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ecd:	85 c0                	test   %eax,%eax
  801ecf:	78 3e                	js     801f0f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ed1:	83 ec 04             	sub    $0x4,%esp
  801ed4:	68 07 04 00 00       	push   $0x407
  801ed9:	ff 75 f4             	pushl  -0xc(%ebp)
  801edc:	6a 00                	push   $0x0
  801ede:	e8 36 ed ff ff       	call   800c19 <sys_page_alloc>
  801ee3:	83 c4 10             	add    $0x10,%esp
		return r;
  801ee6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ee8:	85 c0                	test   %eax,%eax
  801eea:	78 23                	js     801f0f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801eec:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ef7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801efa:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f01:	83 ec 0c             	sub    $0xc,%esp
  801f04:	50                   	push   %eax
  801f05:	e8 1f f3 ff ff       	call   801229 <fd2num>
  801f0a:	89 c2                	mov    %eax,%edx
  801f0c:	83 c4 10             	add    $0x10,%esp
}
  801f0f:	89 d0                	mov    %edx,%eax
  801f11:	c9                   	leave  
  801f12:	c3                   	ret    

00801f13 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f13:	55                   	push   %ebp
  801f14:	89 e5                	mov    %esp,%ebp
  801f16:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f19:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f20:	75 2a                	jne    801f4c <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801f22:	83 ec 04             	sub    $0x4,%esp
  801f25:	6a 07                	push   $0x7
  801f27:	68 00 f0 bf ee       	push   $0xeebff000
  801f2c:	6a 00                	push   $0x0
  801f2e:	e8 e6 ec ff ff       	call   800c19 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801f33:	83 c4 10             	add    $0x10,%esp
  801f36:	85 c0                	test   %eax,%eax
  801f38:	79 12                	jns    801f4c <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801f3a:	50                   	push   %eax
  801f3b:	68 ae 27 80 00       	push   $0x8027ae
  801f40:	6a 23                	push   $0x23
  801f42:	68 b2 27 80 00       	push   $0x8027b2
  801f47:	e8 6c e2 ff ff       	call   8001b8 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f4f:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801f54:	83 ec 08             	sub    $0x8,%esp
  801f57:	68 7e 1f 80 00       	push   $0x801f7e
  801f5c:	6a 00                	push   $0x0
  801f5e:	e8 01 ee ff ff       	call   800d64 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801f63:	83 c4 10             	add    $0x10,%esp
  801f66:	85 c0                	test   %eax,%eax
  801f68:	79 12                	jns    801f7c <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801f6a:	50                   	push   %eax
  801f6b:	68 ae 27 80 00       	push   $0x8027ae
  801f70:	6a 2c                	push   $0x2c
  801f72:	68 b2 27 80 00       	push   $0x8027b2
  801f77:	e8 3c e2 ff ff       	call   8001b8 <_panic>
	}
}
  801f7c:	c9                   	leave  
  801f7d:	c3                   	ret    

00801f7e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f7e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f7f:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f84:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f86:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801f89:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801f8d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801f92:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801f96:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801f98:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801f9b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801f9c:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801f9f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801fa0:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801fa1:	c3                   	ret    

00801fa2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fa2:	55                   	push   %ebp
  801fa3:	89 e5                	mov    %esp,%ebp
  801fa5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa8:	89 d0                	mov    %edx,%eax
  801faa:	c1 e8 16             	shr    $0x16,%eax
  801fad:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fb4:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fb9:	f6 c1 01             	test   $0x1,%cl
  801fbc:	74 1d                	je     801fdb <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fbe:	c1 ea 0c             	shr    $0xc,%edx
  801fc1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fc8:	f6 c2 01             	test   $0x1,%dl
  801fcb:	74 0e                	je     801fdb <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fcd:	c1 ea 0c             	shr    $0xc,%edx
  801fd0:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fd7:	ef 
  801fd8:	0f b7 c0             	movzwl %ax,%eax
}
  801fdb:	5d                   	pop    %ebp
  801fdc:	c3                   	ret    
  801fdd:	66 90                	xchg   %ax,%ax
  801fdf:	90                   	nop

00801fe0 <__udivdi3>:
  801fe0:	55                   	push   %ebp
  801fe1:	57                   	push   %edi
  801fe2:	56                   	push   %esi
  801fe3:	53                   	push   %ebx
  801fe4:	83 ec 1c             	sub    $0x1c,%esp
  801fe7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801feb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ff3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ff7:	85 f6                	test   %esi,%esi
  801ff9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ffd:	89 ca                	mov    %ecx,%edx
  801fff:	89 f8                	mov    %edi,%eax
  802001:	75 3d                	jne    802040 <__udivdi3+0x60>
  802003:	39 cf                	cmp    %ecx,%edi
  802005:	0f 87 c5 00 00 00    	ja     8020d0 <__udivdi3+0xf0>
  80200b:	85 ff                	test   %edi,%edi
  80200d:	89 fd                	mov    %edi,%ebp
  80200f:	75 0b                	jne    80201c <__udivdi3+0x3c>
  802011:	b8 01 00 00 00       	mov    $0x1,%eax
  802016:	31 d2                	xor    %edx,%edx
  802018:	f7 f7                	div    %edi
  80201a:	89 c5                	mov    %eax,%ebp
  80201c:	89 c8                	mov    %ecx,%eax
  80201e:	31 d2                	xor    %edx,%edx
  802020:	f7 f5                	div    %ebp
  802022:	89 c1                	mov    %eax,%ecx
  802024:	89 d8                	mov    %ebx,%eax
  802026:	89 cf                	mov    %ecx,%edi
  802028:	f7 f5                	div    %ebp
  80202a:	89 c3                	mov    %eax,%ebx
  80202c:	89 d8                	mov    %ebx,%eax
  80202e:	89 fa                	mov    %edi,%edx
  802030:	83 c4 1c             	add    $0x1c,%esp
  802033:	5b                   	pop    %ebx
  802034:	5e                   	pop    %esi
  802035:	5f                   	pop    %edi
  802036:	5d                   	pop    %ebp
  802037:	c3                   	ret    
  802038:	90                   	nop
  802039:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802040:	39 ce                	cmp    %ecx,%esi
  802042:	77 74                	ja     8020b8 <__udivdi3+0xd8>
  802044:	0f bd fe             	bsr    %esi,%edi
  802047:	83 f7 1f             	xor    $0x1f,%edi
  80204a:	0f 84 98 00 00 00    	je     8020e8 <__udivdi3+0x108>
  802050:	bb 20 00 00 00       	mov    $0x20,%ebx
  802055:	89 f9                	mov    %edi,%ecx
  802057:	89 c5                	mov    %eax,%ebp
  802059:	29 fb                	sub    %edi,%ebx
  80205b:	d3 e6                	shl    %cl,%esi
  80205d:	89 d9                	mov    %ebx,%ecx
  80205f:	d3 ed                	shr    %cl,%ebp
  802061:	89 f9                	mov    %edi,%ecx
  802063:	d3 e0                	shl    %cl,%eax
  802065:	09 ee                	or     %ebp,%esi
  802067:	89 d9                	mov    %ebx,%ecx
  802069:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80206d:	89 d5                	mov    %edx,%ebp
  80206f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802073:	d3 ed                	shr    %cl,%ebp
  802075:	89 f9                	mov    %edi,%ecx
  802077:	d3 e2                	shl    %cl,%edx
  802079:	89 d9                	mov    %ebx,%ecx
  80207b:	d3 e8                	shr    %cl,%eax
  80207d:	09 c2                	or     %eax,%edx
  80207f:	89 d0                	mov    %edx,%eax
  802081:	89 ea                	mov    %ebp,%edx
  802083:	f7 f6                	div    %esi
  802085:	89 d5                	mov    %edx,%ebp
  802087:	89 c3                	mov    %eax,%ebx
  802089:	f7 64 24 0c          	mull   0xc(%esp)
  80208d:	39 d5                	cmp    %edx,%ebp
  80208f:	72 10                	jb     8020a1 <__udivdi3+0xc1>
  802091:	8b 74 24 08          	mov    0x8(%esp),%esi
  802095:	89 f9                	mov    %edi,%ecx
  802097:	d3 e6                	shl    %cl,%esi
  802099:	39 c6                	cmp    %eax,%esi
  80209b:	73 07                	jae    8020a4 <__udivdi3+0xc4>
  80209d:	39 d5                	cmp    %edx,%ebp
  80209f:	75 03                	jne    8020a4 <__udivdi3+0xc4>
  8020a1:	83 eb 01             	sub    $0x1,%ebx
  8020a4:	31 ff                	xor    %edi,%edi
  8020a6:	89 d8                	mov    %ebx,%eax
  8020a8:	89 fa                	mov    %edi,%edx
  8020aa:	83 c4 1c             	add    $0x1c,%esp
  8020ad:	5b                   	pop    %ebx
  8020ae:	5e                   	pop    %esi
  8020af:	5f                   	pop    %edi
  8020b0:	5d                   	pop    %ebp
  8020b1:	c3                   	ret    
  8020b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020b8:	31 ff                	xor    %edi,%edi
  8020ba:	31 db                	xor    %ebx,%ebx
  8020bc:	89 d8                	mov    %ebx,%eax
  8020be:	89 fa                	mov    %edi,%edx
  8020c0:	83 c4 1c             	add    $0x1c,%esp
  8020c3:	5b                   	pop    %ebx
  8020c4:	5e                   	pop    %esi
  8020c5:	5f                   	pop    %edi
  8020c6:	5d                   	pop    %ebp
  8020c7:	c3                   	ret    
  8020c8:	90                   	nop
  8020c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d0:	89 d8                	mov    %ebx,%eax
  8020d2:	f7 f7                	div    %edi
  8020d4:	31 ff                	xor    %edi,%edi
  8020d6:	89 c3                	mov    %eax,%ebx
  8020d8:	89 d8                	mov    %ebx,%eax
  8020da:	89 fa                	mov    %edi,%edx
  8020dc:	83 c4 1c             	add    $0x1c,%esp
  8020df:	5b                   	pop    %ebx
  8020e0:	5e                   	pop    %esi
  8020e1:	5f                   	pop    %edi
  8020e2:	5d                   	pop    %ebp
  8020e3:	c3                   	ret    
  8020e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020e8:	39 ce                	cmp    %ecx,%esi
  8020ea:	72 0c                	jb     8020f8 <__udivdi3+0x118>
  8020ec:	31 db                	xor    %ebx,%ebx
  8020ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020f2:	0f 87 34 ff ff ff    	ja     80202c <__udivdi3+0x4c>
  8020f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020fd:	e9 2a ff ff ff       	jmp    80202c <__udivdi3+0x4c>
  802102:	66 90                	xchg   %ax,%ax
  802104:	66 90                	xchg   %ax,%ax
  802106:	66 90                	xchg   %ax,%ax
  802108:	66 90                	xchg   %ax,%ax
  80210a:	66 90                	xchg   %ax,%ax
  80210c:	66 90                	xchg   %ax,%ax
  80210e:	66 90                	xchg   %ax,%ax

00802110 <__umoddi3>:
  802110:	55                   	push   %ebp
  802111:	57                   	push   %edi
  802112:	56                   	push   %esi
  802113:	53                   	push   %ebx
  802114:	83 ec 1c             	sub    $0x1c,%esp
  802117:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80211b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80211f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802123:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802127:	85 d2                	test   %edx,%edx
  802129:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80212d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802131:	89 f3                	mov    %esi,%ebx
  802133:	89 3c 24             	mov    %edi,(%esp)
  802136:	89 74 24 04          	mov    %esi,0x4(%esp)
  80213a:	75 1c                	jne    802158 <__umoddi3+0x48>
  80213c:	39 f7                	cmp    %esi,%edi
  80213e:	76 50                	jbe    802190 <__umoddi3+0x80>
  802140:	89 c8                	mov    %ecx,%eax
  802142:	89 f2                	mov    %esi,%edx
  802144:	f7 f7                	div    %edi
  802146:	89 d0                	mov    %edx,%eax
  802148:	31 d2                	xor    %edx,%edx
  80214a:	83 c4 1c             	add    $0x1c,%esp
  80214d:	5b                   	pop    %ebx
  80214e:	5e                   	pop    %esi
  80214f:	5f                   	pop    %edi
  802150:	5d                   	pop    %ebp
  802151:	c3                   	ret    
  802152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802158:	39 f2                	cmp    %esi,%edx
  80215a:	89 d0                	mov    %edx,%eax
  80215c:	77 52                	ja     8021b0 <__umoddi3+0xa0>
  80215e:	0f bd ea             	bsr    %edx,%ebp
  802161:	83 f5 1f             	xor    $0x1f,%ebp
  802164:	75 5a                	jne    8021c0 <__umoddi3+0xb0>
  802166:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80216a:	0f 82 e0 00 00 00    	jb     802250 <__umoddi3+0x140>
  802170:	39 0c 24             	cmp    %ecx,(%esp)
  802173:	0f 86 d7 00 00 00    	jbe    802250 <__umoddi3+0x140>
  802179:	8b 44 24 08          	mov    0x8(%esp),%eax
  80217d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802181:	83 c4 1c             	add    $0x1c,%esp
  802184:	5b                   	pop    %ebx
  802185:	5e                   	pop    %esi
  802186:	5f                   	pop    %edi
  802187:	5d                   	pop    %ebp
  802188:	c3                   	ret    
  802189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802190:	85 ff                	test   %edi,%edi
  802192:	89 fd                	mov    %edi,%ebp
  802194:	75 0b                	jne    8021a1 <__umoddi3+0x91>
  802196:	b8 01 00 00 00       	mov    $0x1,%eax
  80219b:	31 d2                	xor    %edx,%edx
  80219d:	f7 f7                	div    %edi
  80219f:	89 c5                	mov    %eax,%ebp
  8021a1:	89 f0                	mov    %esi,%eax
  8021a3:	31 d2                	xor    %edx,%edx
  8021a5:	f7 f5                	div    %ebp
  8021a7:	89 c8                	mov    %ecx,%eax
  8021a9:	f7 f5                	div    %ebp
  8021ab:	89 d0                	mov    %edx,%eax
  8021ad:	eb 99                	jmp    802148 <__umoddi3+0x38>
  8021af:	90                   	nop
  8021b0:	89 c8                	mov    %ecx,%eax
  8021b2:	89 f2                	mov    %esi,%edx
  8021b4:	83 c4 1c             	add    $0x1c,%esp
  8021b7:	5b                   	pop    %ebx
  8021b8:	5e                   	pop    %esi
  8021b9:	5f                   	pop    %edi
  8021ba:	5d                   	pop    %ebp
  8021bb:	c3                   	ret    
  8021bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	8b 34 24             	mov    (%esp),%esi
  8021c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021c8:	89 e9                	mov    %ebp,%ecx
  8021ca:	29 ef                	sub    %ebp,%edi
  8021cc:	d3 e0                	shl    %cl,%eax
  8021ce:	89 f9                	mov    %edi,%ecx
  8021d0:	89 f2                	mov    %esi,%edx
  8021d2:	d3 ea                	shr    %cl,%edx
  8021d4:	89 e9                	mov    %ebp,%ecx
  8021d6:	09 c2                	or     %eax,%edx
  8021d8:	89 d8                	mov    %ebx,%eax
  8021da:	89 14 24             	mov    %edx,(%esp)
  8021dd:	89 f2                	mov    %esi,%edx
  8021df:	d3 e2                	shl    %cl,%edx
  8021e1:	89 f9                	mov    %edi,%ecx
  8021e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021eb:	d3 e8                	shr    %cl,%eax
  8021ed:	89 e9                	mov    %ebp,%ecx
  8021ef:	89 c6                	mov    %eax,%esi
  8021f1:	d3 e3                	shl    %cl,%ebx
  8021f3:	89 f9                	mov    %edi,%ecx
  8021f5:	89 d0                	mov    %edx,%eax
  8021f7:	d3 e8                	shr    %cl,%eax
  8021f9:	89 e9                	mov    %ebp,%ecx
  8021fb:	09 d8                	or     %ebx,%eax
  8021fd:	89 d3                	mov    %edx,%ebx
  8021ff:	89 f2                	mov    %esi,%edx
  802201:	f7 34 24             	divl   (%esp)
  802204:	89 d6                	mov    %edx,%esi
  802206:	d3 e3                	shl    %cl,%ebx
  802208:	f7 64 24 04          	mull   0x4(%esp)
  80220c:	39 d6                	cmp    %edx,%esi
  80220e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802212:	89 d1                	mov    %edx,%ecx
  802214:	89 c3                	mov    %eax,%ebx
  802216:	72 08                	jb     802220 <__umoddi3+0x110>
  802218:	75 11                	jne    80222b <__umoddi3+0x11b>
  80221a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80221e:	73 0b                	jae    80222b <__umoddi3+0x11b>
  802220:	2b 44 24 04          	sub    0x4(%esp),%eax
  802224:	1b 14 24             	sbb    (%esp),%edx
  802227:	89 d1                	mov    %edx,%ecx
  802229:	89 c3                	mov    %eax,%ebx
  80222b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80222f:	29 da                	sub    %ebx,%edx
  802231:	19 ce                	sbb    %ecx,%esi
  802233:	89 f9                	mov    %edi,%ecx
  802235:	89 f0                	mov    %esi,%eax
  802237:	d3 e0                	shl    %cl,%eax
  802239:	89 e9                	mov    %ebp,%ecx
  80223b:	d3 ea                	shr    %cl,%edx
  80223d:	89 e9                	mov    %ebp,%ecx
  80223f:	d3 ee                	shr    %cl,%esi
  802241:	09 d0                	or     %edx,%eax
  802243:	89 f2                	mov    %esi,%edx
  802245:	83 c4 1c             	add    $0x1c,%esp
  802248:	5b                   	pop    %ebx
  802249:	5e                   	pop    %esi
  80224a:	5f                   	pop    %edi
  80224b:	5d                   	pop    %ebp
  80224c:	c3                   	ret    
  80224d:	8d 76 00             	lea    0x0(%esi),%esi
  802250:	29 f9                	sub    %edi,%ecx
  802252:	19 d6                	sbb    %edx,%esi
  802254:	89 74 24 04          	mov    %esi,0x4(%esp)
  802258:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80225c:	e9 18 ff ff ff       	jmp    802179 <__umoddi3+0x69>
