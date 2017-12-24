
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
  800047:	e8 63 10 00 00       	call   8010af <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 40 80 00       	mov    0x804004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 00 22 80 00       	push   $0x802200
  800060:	e8 14 02 00 00       	call   800279 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 5e 0e 00 00       	call   800ec8 <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 0c 22 80 00       	push   $0x80220c
  800079:	6a 1a                	push   $0x1a
  80007b:	68 15 22 80 00       	push   $0x802215
  800080:	e8 1b 01 00 00       	call   8001a0 <_panic>
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
  800094:	e8 16 10 00 00       	call   8010af <ipc_recv>
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
  8000ab:	e8 71 10 00 00       	call   801121 <ipc_send>
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
  8000ba:	e8 09 0e 00 00       	call   800ec8 <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 0c 22 80 00       	push   $0x80220c
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 15 22 80 00       	push   $0x802215
  8000d2:	e8 c9 00 00 00       	call   8001a0 <_panic>
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
  8000eb:	e8 31 10 00 00       	call   801121 <ipc_send>
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
  80010b:	e8 b3 0a 00 00       	call   800bc3 <sys_getenvid>
  800110:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  800116:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80011b:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800120:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  800125:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  800128:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  80012e:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  800131:	39 c8                	cmp    %ecx,%eax
  800133:	0f 44 fb             	cmove  %ebx,%edi
  800136:	b9 01 00 00 00       	mov    $0x1,%ecx
  80013b:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  80013e:	83 c2 01             	add    $0x1,%edx
  800141:	83 c3 7c             	add    $0x7c,%ebx
  800144:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  80014a:	75 d9                	jne    800125 <libmain+0x2d>
  80014c:	89 f0                	mov    %esi,%eax
  80014e:	84 c0                	test   %al,%al
  800150:	74 06                	je     800158 <libmain+0x60>
  800152:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800158:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80015c:	7e 0a                	jle    800168 <libmain+0x70>
		binaryname = argv[0];
  80015e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800161:	8b 00                	mov    (%eax),%eax
  800163:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800168:	83 ec 08             	sub    $0x8,%esp
  80016b:	ff 75 0c             	pushl  0xc(%ebp)
  80016e:	ff 75 08             	pushl  0x8(%ebp)
  800171:	e8 3f ff ff ff       	call   8000b5 <umain>

	// exit gracefully
	exit();
  800176:	e8 0b 00 00 00       	call   800186 <exit>
}
  80017b:	83 c4 10             	add    $0x10,%esp
  80017e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800181:	5b                   	pop    %ebx
  800182:	5e                   	pop    %esi
  800183:	5f                   	pop    %edi
  800184:	5d                   	pop    %ebp
  800185:	c3                   	ret    

00800186 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800186:	55                   	push   %ebp
  800187:	89 e5                	mov    %esp,%ebp
  800189:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80018c:	e8 f6 11 00 00       	call   801387 <close_all>
	sys_env_destroy(0);
  800191:	83 ec 0c             	sub    $0xc,%esp
  800194:	6a 00                	push   $0x0
  800196:	e8 e7 09 00 00       	call   800b82 <sys_env_destroy>
}
  80019b:	83 c4 10             	add    $0x10,%esp
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	56                   	push   %esi
  8001a4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001a5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001a8:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001ae:	e8 10 0a 00 00       	call   800bc3 <sys_getenvid>
  8001b3:	83 ec 0c             	sub    $0xc,%esp
  8001b6:	ff 75 0c             	pushl  0xc(%ebp)
  8001b9:	ff 75 08             	pushl  0x8(%ebp)
  8001bc:	56                   	push   %esi
  8001bd:	50                   	push   %eax
  8001be:	68 30 22 80 00       	push   $0x802230
  8001c3:	e8 b1 00 00 00       	call   800279 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c8:	83 c4 18             	add    $0x18,%esp
  8001cb:	53                   	push   %ebx
  8001cc:	ff 75 10             	pushl  0x10(%ebp)
  8001cf:	e8 54 00 00 00       	call   800228 <vcprintf>
	cprintf("\n");
  8001d4:	c7 04 24 eb 26 80 00 	movl   $0x8026eb,(%esp)
  8001db:	e8 99 00 00 00       	call   800279 <cprintf>
  8001e0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001e3:	cc                   	int3   
  8001e4:	eb fd                	jmp    8001e3 <_panic+0x43>

008001e6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	53                   	push   %ebx
  8001ea:	83 ec 04             	sub    $0x4,%esp
  8001ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001f0:	8b 13                	mov    (%ebx),%edx
  8001f2:	8d 42 01             	lea    0x1(%edx),%eax
  8001f5:	89 03                	mov    %eax,(%ebx)
  8001f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001fa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001fe:	3d ff 00 00 00       	cmp    $0xff,%eax
  800203:	75 1a                	jne    80021f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	68 ff 00 00 00       	push   $0xff
  80020d:	8d 43 08             	lea    0x8(%ebx),%eax
  800210:	50                   	push   %eax
  800211:	e8 2f 09 00 00       	call   800b45 <sys_cputs>
		b->idx = 0;
  800216:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80021c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80021f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800223:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800226:	c9                   	leave  
  800227:	c3                   	ret    

00800228 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800231:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800238:	00 00 00 
	b.cnt = 0;
  80023b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800242:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800245:	ff 75 0c             	pushl  0xc(%ebp)
  800248:	ff 75 08             	pushl  0x8(%ebp)
  80024b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800251:	50                   	push   %eax
  800252:	68 e6 01 80 00       	push   $0x8001e6
  800257:	e8 54 01 00 00       	call   8003b0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80025c:	83 c4 08             	add    $0x8,%esp
  80025f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800265:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80026b:	50                   	push   %eax
  80026c:	e8 d4 08 00 00       	call   800b45 <sys_cputs>

	return b.cnt;
}
  800271:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800277:	c9                   	leave  
  800278:	c3                   	ret    

00800279 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80027f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800282:	50                   	push   %eax
  800283:	ff 75 08             	pushl  0x8(%ebp)
  800286:	e8 9d ff ff ff       	call   800228 <vcprintf>
	va_end(ap);

	return cnt;
}
  80028b:	c9                   	leave  
  80028c:	c3                   	ret    

0080028d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	57                   	push   %edi
  800291:	56                   	push   %esi
  800292:	53                   	push   %ebx
  800293:	83 ec 1c             	sub    $0x1c,%esp
  800296:	89 c7                	mov    %eax,%edi
  800298:	89 d6                	mov    %edx,%esi
  80029a:	8b 45 08             	mov    0x8(%ebp),%eax
  80029d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002a3:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ae:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002b1:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002b4:	39 d3                	cmp    %edx,%ebx
  8002b6:	72 05                	jb     8002bd <printnum+0x30>
  8002b8:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002bb:	77 45                	ja     800302 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	ff 75 18             	pushl  0x18(%ebp)
  8002c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8002c6:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002c9:	53                   	push   %ebx
  8002ca:	ff 75 10             	pushl  0x10(%ebp)
  8002cd:	83 ec 08             	sub    $0x8,%esp
  8002d0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002d3:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002dc:	e8 8f 1c 00 00       	call   801f70 <__udivdi3>
  8002e1:	83 c4 18             	add    $0x18,%esp
  8002e4:	52                   	push   %edx
  8002e5:	50                   	push   %eax
  8002e6:	89 f2                	mov    %esi,%edx
  8002e8:	89 f8                	mov    %edi,%eax
  8002ea:	e8 9e ff ff ff       	call   80028d <printnum>
  8002ef:	83 c4 20             	add    $0x20,%esp
  8002f2:	eb 18                	jmp    80030c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f4:	83 ec 08             	sub    $0x8,%esp
  8002f7:	56                   	push   %esi
  8002f8:	ff 75 18             	pushl  0x18(%ebp)
  8002fb:	ff d7                	call   *%edi
  8002fd:	83 c4 10             	add    $0x10,%esp
  800300:	eb 03                	jmp    800305 <printnum+0x78>
  800302:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800305:	83 eb 01             	sub    $0x1,%ebx
  800308:	85 db                	test   %ebx,%ebx
  80030a:	7f e8                	jg     8002f4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80030c:	83 ec 08             	sub    $0x8,%esp
  80030f:	56                   	push   %esi
  800310:	83 ec 04             	sub    $0x4,%esp
  800313:	ff 75 e4             	pushl  -0x1c(%ebp)
  800316:	ff 75 e0             	pushl  -0x20(%ebp)
  800319:	ff 75 dc             	pushl  -0x24(%ebp)
  80031c:	ff 75 d8             	pushl  -0x28(%ebp)
  80031f:	e8 7c 1d 00 00       	call   8020a0 <__umoddi3>
  800324:	83 c4 14             	add    $0x14,%esp
  800327:	0f be 80 53 22 80 00 	movsbl 0x802253(%eax),%eax
  80032e:	50                   	push   %eax
  80032f:	ff d7                	call   *%edi
}
  800331:	83 c4 10             	add    $0x10,%esp
  800334:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800337:	5b                   	pop    %ebx
  800338:	5e                   	pop    %esi
  800339:	5f                   	pop    %edi
  80033a:	5d                   	pop    %ebp
  80033b:	c3                   	ret    

0080033c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80033f:	83 fa 01             	cmp    $0x1,%edx
  800342:	7e 0e                	jle    800352 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800344:	8b 10                	mov    (%eax),%edx
  800346:	8d 4a 08             	lea    0x8(%edx),%ecx
  800349:	89 08                	mov    %ecx,(%eax)
  80034b:	8b 02                	mov    (%edx),%eax
  80034d:	8b 52 04             	mov    0x4(%edx),%edx
  800350:	eb 22                	jmp    800374 <getuint+0x38>
	else if (lflag)
  800352:	85 d2                	test   %edx,%edx
  800354:	74 10                	je     800366 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800356:	8b 10                	mov    (%eax),%edx
  800358:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035b:	89 08                	mov    %ecx,(%eax)
  80035d:	8b 02                	mov    (%edx),%eax
  80035f:	ba 00 00 00 00       	mov    $0x0,%edx
  800364:	eb 0e                	jmp    800374 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800366:	8b 10                	mov    (%eax),%edx
  800368:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036b:	89 08                	mov    %ecx,(%eax)
  80036d:	8b 02                	mov    (%edx),%eax
  80036f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
  800379:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80037c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800380:	8b 10                	mov    (%eax),%edx
  800382:	3b 50 04             	cmp    0x4(%eax),%edx
  800385:	73 0a                	jae    800391 <sprintputch+0x1b>
		*b->buf++ = ch;
  800387:	8d 4a 01             	lea    0x1(%edx),%ecx
  80038a:	89 08                	mov    %ecx,(%eax)
  80038c:	8b 45 08             	mov    0x8(%ebp),%eax
  80038f:	88 02                	mov    %al,(%edx)
}
  800391:	5d                   	pop    %ebp
  800392:	c3                   	ret    

00800393 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800393:	55                   	push   %ebp
  800394:	89 e5                	mov    %esp,%ebp
  800396:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800399:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80039c:	50                   	push   %eax
  80039d:	ff 75 10             	pushl  0x10(%ebp)
  8003a0:	ff 75 0c             	pushl  0xc(%ebp)
  8003a3:	ff 75 08             	pushl  0x8(%ebp)
  8003a6:	e8 05 00 00 00       	call   8003b0 <vprintfmt>
	va_end(ap);
}
  8003ab:	83 c4 10             	add    $0x10,%esp
  8003ae:	c9                   	leave  
  8003af:	c3                   	ret    

008003b0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003b0:	55                   	push   %ebp
  8003b1:	89 e5                	mov    %esp,%ebp
  8003b3:	57                   	push   %edi
  8003b4:	56                   	push   %esi
  8003b5:	53                   	push   %ebx
  8003b6:	83 ec 2c             	sub    $0x2c,%esp
  8003b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8003bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003bf:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003c2:	eb 12                	jmp    8003d6 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003c4:	85 c0                	test   %eax,%eax
  8003c6:	0f 84 89 03 00 00    	je     800755 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003cc:	83 ec 08             	sub    $0x8,%esp
  8003cf:	53                   	push   %ebx
  8003d0:	50                   	push   %eax
  8003d1:	ff d6                	call   *%esi
  8003d3:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d6:	83 c7 01             	add    $0x1,%edi
  8003d9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003dd:	83 f8 25             	cmp    $0x25,%eax
  8003e0:	75 e2                	jne    8003c4 <vprintfmt+0x14>
  8003e2:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003e6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003ed:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003f4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800400:	eb 07                	jmp    800409 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800402:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800405:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8d 47 01             	lea    0x1(%edi),%eax
  80040c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80040f:	0f b6 07             	movzbl (%edi),%eax
  800412:	0f b6 c8             	movzbl %al,%ecx
  800415:	83 e8 23             	sub    $0x23,%eax
  800418:	3c 55                	cmp    $0x55,%al
  80041a:	0f 87 1a 03 00 00    	ja     80073a <vprintfmt+0x38a>
  800420:	0f b6 c0             	movzbl %al,%eax
  800423:	ff 24 85 a0 23 80 00 	jmp    *0x8023a0(,%eax,4)
  80042a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80042d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800431:	eb d6                	jmp    800409 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800433:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800436:	b8 00 00 00 00       	mov    $0x0,%eax
  80043b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80043e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800441:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800445:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800448:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80044b:	83 fa 09             	cmp    $0x9,%edx
  80044e:	77 39                	ja     800489 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800450:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800453:	eb e9                	jmp    80043e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800455:	8b 45 14             	mov    0x14(%ebp),%eax
  800458:	8d 48 04             	lea    0x4(%eax),%ecx
  80045b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80045e:	8b 00                	mov    (%eax),%eax
  800460:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800463:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800466:	eb 27                	jmp    80048f <vprintfmt+0xdf>
  800468:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80046b:	85 c0                	test   %eax,%eax
  80046d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800472:	0f 49 c8             	cmovns %eax,%ecx
  800475:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800478:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80047b:	eb 8c                	jmp    800409 <vprintfmt+0x59>
  80047d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800480:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800487:	eb 80                	jmp    800409 <vprintfmt+0x59>
  800489:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80048c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80048f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800493:	0f 89 70 ff ff ff    	jns    800409 <vprintfmt+0x59>
				width = precision, precision = -1;
  800499:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80049c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80049f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004a6:	e9 5e ff ff ff       	jmp    800409 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004ab:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004b1:	e9 53 ff ff ff       	jmp    800409 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b9:	8d 50 04             	lea    0x4(%eax),%edx
  8004bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bf:	83 ec 08             	sub    $0x8,%esp
  8004c2:	53                   	push   %ebx
  8004c3:	ff 30                	pushl  (%eax)
  8004c5:	ff d6                	call   *%esi
			break;
  8004c7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004cd:	e9 04 ff ff ff       	jmp    8003d6 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d5:	8d 50 04             	lea    0x4(%eax),%edx
  8004d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004db:	8b 00                	mov    (%eax),%eax
  8004dd:	99                   	cltd   
  8004de:	31 d0                	xor    %edx,%eax
  8004e0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e2:	83 f8 0f             	cmp    $0xf,%eax
  8004e5:	7f 0b                	jg     8004f2 <vprintfmt+0x142>
  8004e7:	8b 14 85 00 25 80 00 	mov    0x802500(,%eax,4),%edx
  8004ee:	85 d2                	test   %edx,%edx
  8004f0:	75 18                	jne    80050a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004f2:	50                   	push   %eax
  8004f3:	68 6b 22 80 00       	push   $0x80226b
  8004f8:	53                   	push   %ebx
  8004f9:	56                   	push   %esi
  8004fa:	e8 94 fe ff ff       	call   800393 <printfmt>
  8004ff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800502:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800505:	e9 cc fe ff ff       	jmp    8003d6 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80050a:	52                   	push   %edx
  80050b:	68 b9 26 80 00       	push   $0x8026b9
  800510:	53                   	push   %ebx
  800511:	56                   	push   %esi
  800512:	e8 7c fe ff ff       	call   800393 <printfmt>
  800517:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80051d:	e9 b4 fe ff ff       	jmp    8003d6 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8d 50 04             	lea    0x4(%eax),%edx
  800528:	89 55 14             	mov    %edx,0x14(%ebp)
  80052b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80052d:	85 ff                	test   %edi,%edi
  80052f:	b8 64 22 80 00       	mov    $0x802264,%eax
  800534:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800537:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80053b:	0f 8e 94 00 00 00    	jle    8005d5 <vprintfmt+0x225>
  800541:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800545:	0f 84 98 00 00 00    	je     8005e3 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	ff 75 d0             	pushl  -0x30(%ebp)
  800551:	57                   	push   %edi
  800552:	e8 86 02 00 00       	call   8007dd <strnlen>
  800557:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80055a:	29 c1                	sub    %eax,%ecx
  80055c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80055f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800562:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800566:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800569:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80056c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056e:	eb 0f                	jmp    80057f <vprintfmt+0x1cf>
					putch(padc, putdat);
  800570:	83 ec 08             	sub    $0x8,%esp
  800573:	53                   	push   %ebx
  800574:	ff 75 e0             	pushl  -0x20(%ebp)
  800577:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800579:	83 ef 01             	sub    $0x1,%edi
  80057c:	83 c4 10             	add    $0x10,%esp
  80057f:	85 ff                	test   %edi,%edi
  800581:	7f ed                	jg     800570 <vprintfmt+0x1c0>
  800583:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800586:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800589:	85 c9                	test   %ecx,%ecx
  80058b:	b8 00 00 00 00       	mov    $0x0,%eax
  800590:	0f 49 c1             	cmovns %ecx,%eax
  800593:	29 c1                	sub    %eax,%ecx
  800595:	89 75 08             	mov    %esi,0x8(%ebp)
  800598:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80059b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80059e:	89 cb                	mov    %ecx,%ebx
  8005a0:	eb 4d                	jmp    8005ef <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005a2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005a6:	74 1b                	je     8005c3 <vprintfmt+0x213>
  8005a8:	0f be c0             	movsbl %al,%eax
  8005ab:	83 e8 20             	sub    $0x20,%eax
  8005ae:	83 f8 5e             	cmp    $0x5e,%eax
  8005b1:	76 10                	jbe    8005c3 <vprintfmt+0x213>
					putch('?', putdat);
  8005b3:	83 ec 08             	sub    $0x8,%esp
  8005b6:	ff 75 0c             	pushl  0xc(%ebp)
  8005b9:	6a 3f                	push   $0x3f
  8005bb:	ff 55 08             	call   *0x8(%ebp)
  8005be:	83 c4 10             	add    $0x10,%esp
  8005c1:	eb 0d                	jmp    8005d0 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005c3:	83 ec 08             	sub    $0x8,%esp
  8005c6:	ff 75 0c             	pushl  0xc(%ebp)
  8005c9:	52                   	push   %edx
  8005ca:	ff 55 08             	call   *0x8(%ebp)
  8005cd:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d0:	83 eb 01             	sub    $0x1,%ebx
  8005d3:	eb 1a                	jmp    8005ef <vprintfmt+0x23f>
  8005d5:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005db:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005de:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005e1:	eb 0c                	jmp    8005ef <vprintfmt+0x23f>
  8005e3:	89 75 08             	mov    %esi,0x8(%ebp)
  8005e6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005e9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ec:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005ef:	83 c7 01             	add    $0x1,%edi
  8005f2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005f6:	0f be d0             	movsbl %al,%edx
  8005f9:	85 d2                	test   %edx,%edx
  8005fb:	74 23                	je     800620 <vprintfmt+0x270>
  8005fd:	85 f6                	test   %esi,%esi
  8005ff:	78 a1                	js     8005a2 <vprintfmt+0x1f2>
  800601:	83 ee 01             	sub    $0x1,%esi
  800604:	79 9c                	jns    8005a2 <vprintfmt+0x1f2>
  800606:	89 df                	mov    %ebx,%edi
  800608:	8b 75 08             	mov    0x8(%ebp),%esi
  80060b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80060e:	eb 18                	jmp    800628 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800610:	83 ec 08             	sub    $0x8,%esp
  800613:	53                   	push   %ebx
  800614:	6a 20                	push   $0x20
  800616:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800618:	83 ef 01             	sub    $0x1,%edi
  80061b:	83 c4 10             	add    $0x10,%esp
  80061e:	eb 08                	jmp    800628 <vprintfmt+0x278>
  800620:	89 df                	mov    %ebx,%edi
  800622:	8b 75 08             	mov    0x8(%ebp),%esi
  800625:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800628:	85 ff                	test   %edi,%edi
  80062a:	7f e4                	jg     800610 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80062f:	e9 a2 fd ff ff       	jmp    8003d6 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800634:	83 fa 01             	cmp    $0x1,%edx
  800637:	7e 16                	jle    80064f <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800639:	8b 45 14             	mov    0x14(%ebp),%eax
  80063c:	8d 50 08             	lea    0x8(%eax),%edx
  80063f:	89 55 14             	mov    %edx,0x14(%ebp)
  800642:	8b 50 04             	mov    0x4(%eax),%edx
  800645:	8b 00                	mov    (%eax),%eax
  800647:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80064a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80064d:	eb 32                	jmp    800681 <vprintfmt+0x2d1>
	else if (lflag)
  80064f:	85 d2                	test   %edx,%edx
  800651:	74 18                	je     80066b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800653:	8b 45 14             	mov    0x14(%ebp),%eax
  800656:	8d 50 04             	lea    0x4(%eax),%edx
  800659:	89 55 14             	mov    %edx,0x14(%ebp)
  80065c:	8b 00                	mov    (%eax),%eax
  80065e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800661:	89 c1                	mov    %eax,%ecx
  800663:	c1 f9 1f             	sar    $0x1f,%ecx
  800666:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800669:	eb 16                	jmp    800681 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80066b:	8b 45 14             	mov    0x14(%ebp),%eax
  80066e:	8d 50 04             	lea    0x4(%eax),%edx
  800671:	89 55 14             	mov    %edx,0x14(%ebp)
  800674:	8b 00                	mov    (%eax),%eax
  800676:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800679:	89 c1                	mov    %eax,%ecx
  80067b:	c1 f9 1f             	sar    $0x1f,%ecx
  80067e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800681:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800684:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800687:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80068c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800690:	79 74                	jns    800706 <vprintfmt+0x356>
				putch('-', putdat);
  800692:	83 ec 08             	sub    $0x8,%esp
  800695:	53                   	push   %ebx
  800696:	6a 2d                	push   $0x2d
  800698:	ff d6                	call   *%esi
				num = -(long long) num;
  80069a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80069d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006a0:	f7 d8                	neg    %eax
  8006a2:	83 d2 00             	adc    $0x0,%edx
  8006a5:	f7 da                	neg    %edx
  8006a7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006aa:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006af:	eb 55                	jmp    800706 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006b1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b4:	e8 83 fc ff ff       	call   80033c <getuint>
			base = 10;
  8006b9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006be:	eb 46                	jmp    800706 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006c0:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c3:	e8 74 fc ff ff       	call   80033c <getuint>
			base = 8;
  8006c8:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006cd:	eb 37                	jmp    800706 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8006cf:	83 ec 08             	sub    $0x8,%esp
  8006d2:	53                   	push   %ebx
  8006d3:	6a 30                	push   $0x30
  8006d5:	ff d6                	call   *%esi
			putch('x', putdat);
  8006d7:	83 c4 08             	add    $0x8,%esp
  8006da:	53                   	push   %ebx
  8006db:	6a 78                	push   $0x78
  8006dd:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006df:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e2:	8d 50 04             	lea    0x4(%eax),%edx
  8006e5:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006e8:	8b 00                	mov    (%eax),%eax
  8006ea:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006ef:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006f2:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006f7:	eb 0d                	jmp    800706 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006f9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fc:	e8 3b fc ff ff       	call   80033c <getuint>
			base = 16;
  800701:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800706:	83 ec 0c             	sub    $0xc,%esp
  800709:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80070d:	57                   	push   %edi
  80070e:	ff 75 e0             	pushl  -0x20(%ebp)
  800711:	51                   	push   %ecx
  800712:	52                   	push   %edx
  800713:	50                   	push   %eax
  800714:	89 da                	mov    %ebx,%edx
  800716:	89 f0                	mov    %esi,%eax
  800718:	e8 70 fb ff ff       	call   80028d <printnum>
			break;
  80071d:	83 c4 20             	add    $0x20,%esp
  800720:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800723:	e9 ae fc ff ff       	jmp    8003d6 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800728:	83 ec 08             	sub    $0x8,%esp
  80072b:	53                   	push   %ebx
  80072c:	51                   	push   %ecx
  80072d:	ff d6                	call   *%esi
			break;
  80072f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800732:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800735:	e9 9c fc ff ff       	jmp    8003d6 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80073a:	83 ec 08             	sub    $0x8,%esp
  80073d:	53                   	push   %ebx
  80073e:	6a 25                	push   $0x25
  800740:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800742:	83 c4 10             	add    $0x10,%esp
  800745:	eb 03                	jmp    80074a <vprintfmt+0x39a>
  800747:	83 ef 01             	sub    $0x1,%edi
  80074a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80074e:	75 f7                	jne    800747 <vprintfmt+0x397>
  800750:	e9 81 fc ff ff       	jmp    8003d6 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800755:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800758:	5b                   	pop    %ebx
  800759:	5e                   	pop    %esi
  80075a:	5f                   	pop    %edi
  80075b:	5d                   	pop    %ebp
  80075c:	c3                   	ret    

0080075d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	83 ec 18             	sub    $0x18,%esp
  800763:	8b 45 08             	mov    0x8(%ebp),%eax
  800766:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800769:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80076c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800770:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800773:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80077a:	85 c0                	test   %eax,%eax
  80077c:	74 26                	je     8007a4 <vsnprintf+0x47>
  80077e:	85 d2                	test   %edx,%edx
  800780:	7e 22                	jle    8007a4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800782:	ff 75 14             	pushl  0x14(%ebp)
  800785:	ff 75 10             	pushl  0x10(%ebp)
  800788:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80078b:	50                   	push   %eax
  80078c:	68 76 03 80 00       	push   $0x800376
  800791:	e8 1a fc ff ff       	call   8003b0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800796:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800799:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80079f:	83 c4 10             	add    $0x10,%esp
  8007a2:	eb 05                	jmp    8007a9 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007a9:	c9                   	leave  
  8007aa:	c3                   	ret    

008007ab <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b4:	50                   	push   %eax
  8007b5:	ff 75 10             	pushl  0x10(%ebp)
  8007b8:	ff 75 0c             	pushl  0xc(%ebp)
  8007bb:	ff 75 08             	pushl  0x8(%ebp)
  8007be:	e8 9a ff ff ff       	call   80075d <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c3:	c9                   	leave  
  8007c4:	c3                   	ret    

008007c5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d0:	eb 03                	jmp    8007d5 <strlen+0x10>
		n++;
  8007d2:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d9:	75 f7                	jne    8007d2 <strlen+0xd>
		n++;
	return n;
}
  8007db:	5d                   	pop    %ebp
  8007dc:	c3                   	ret    

008007dd <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e3:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8007eb:	eb 03                	jmp    8007f0 <strnlen+0x13>
		n++;
  8007ed:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f0:	39 c2                	cmp    %eax,%edx
  8007f2:	74 08                	je     8007fc <strnlen+0x1f>
  8007f4:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007f8:	75 f3                	jne    8007ed <strnlen+0x10>
  8007fa:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007fc:	5d                   	pop    %ebp
  8007fd:	c3                   	ret    

008007fe <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	53                   	push   %ebx
  800802:	8b 45 08             	mov    0x8(%ebp),%eax
  800805:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800808:	89 c2                	mov    %eax,%edx
  80080a:	83 c2 01             	add    $0x1,%edx
  80080d:	83 c1 01             	add    $0x1,%ecx
  800810:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800814:	88 5a ff             	mov    %bl,-0x1(%edx)
  800817:	84 db                	test   %bl,%bl
  800819:	75 ef                	jne    80080a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80081b:	5b                   	pop    %ebx
  80081c:	5d                   	pop    %ebp
  80081d:	c3                   	ret    

0080081e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	53                   	push   %ebx
  800822:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800825:	53                   	push   %ebx
  800826:	e8 9a ff ff ff       	call   8007c5 <strlen>
  80082b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80082e:	ff 75 0c             	pushl  0xc(%ebp)
  800831:	01 d8                	add    %ebx,%eax
  800833:	50                   	push   %eax
  800834:	e8 c5 ff ff ff       	call   8007fe <strcpy>
	return dst;
}
  800839:	89 d8                	mov    %ebx,%eax
  80083b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083e:	c9                   	leave  
  80083f:	c3                   	ret    

00800840 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	56                   	push   %esi
  800844:	53                   	push   %ebx
  800845:	8b 75 08             	mov    0x8(%ebp),%esi
  800848:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084b:	89 f3                	mov    %esi,%ebx
  80084d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800850:	89 f2                	mov    %esi,%edx
  800852:	eb 0f                	jmp    800863 <strncpy+0x23>
		*dst++ = *src;
  800854:	83 c2 01             	add    $0x1,%edx
  800857:	0f b6 01             	movzbl (%ecx),%eax
  80085a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80085d:	80 39 01             	cmpb   $0x1,(%ecx)
  800860:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800863:	39 da                	cmp    %ebx,%edx
  800865:	75 ed                	jne    800854 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800867:	89 f0                	mov    %esi,%eax
  800869:	5b                   	pop    %ebx
  80086a:	5e                   	pop    %esi
  80086b:	5d                   	pop    %ebp
  80086c:	c3                   	ret    

0080086d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	56                   	push   %esi
  800871:	53                   	push   %ebx
  800872:	8b 75 08             	mov    0x8(%ebp),%esi
  800875:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800878:	8b 55 10             	mov    0x10(%ebp),%edx
  80087b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087d:	85 d2                	test   %edx,%edx
  80087f:	74 21                	je     8008a2 <strlcpy+0x35>
  800881:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800885:	89 f2                	mov    %esi,%edx
  800887:	eb 09                	jmp    800892 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800889:	83 c2 01             	add    $0x1,%edx
  80088c:	83 c1 01             	add    $0x1,%ecx
  80088f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800892:	39 c2                	cmp    %eax,%edx
  800894:	74 09                	je     80089f <strlcpy+0x32>
  800896:	0f b6 19             	movzbl (%ecx),%ebx
  800899:	84 db                	test   %bl,%bl
  80089b:	75 ec                	jne    800889 <strlcpy+0x1c>
  80089d:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80089f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008a2:	29 f0                	sub    %esi,%eax
}
  8008a4:	5b                   	pop    %ebx
  8008a5:	5e                   	pop    %esi
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ae:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b1:	eb 06                	jmp    8008b9 <strcmp+0x11>
		p++, q++;
  8008b3:	83 c1 01             	add    $0x1,%ecx
  8008b6:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008b9:	0f b6 01             	movzbl (%ecx),%eax
  8008bc:	84 c0                	test   %al,%al
  8008be:	74 04                	je     8008c4 <strcmp+0x1c>
  8008c0:	3a 02                	cmp    (%edx),%al
  8008c2:	74 ef                	je     8008b3 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c4:	0f b6 c0             	movzbl %al,%eax
  8008c7:	0f b6 12             	movzbl (%edx),%edx
  8008ca:	29 d0                	sub    %edx,%eax
}
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	53                   	push   %ebx
  8008d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d8:	89 c3                	mov    %eax,%ebx
  8008da:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008dd:	eb 06                	jmp    8008e5 <strncmp+0x17>
		n--, p++, q++;
  8008df:	83 c0 01             	add    $0x1,%eax
  8008e2:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e5:	39 d8                	cmp    %ebx,%eax
  8008e7:	74 15                	je     8008fe <strncmp+0x30>
  8008e9:	0f b6 08             	movzbl (%eax),%ecx
  8008ec:	84 c9                	test   %cl,%cl
  8008ee:	74 04                	je     8008f4 <strncmp+0x26>
  8008f0:	3a 0a                	cmp    (%edx),%cl
  8008f2:	74 eb                	je     8008df <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f4:	0f b6 00             	movzbl (%eax),%eax
  8008f7:	0f b6 12             	movzbl (%edx),%edx
  8008fa:	29 d0                	sub    %edx,%eax
  8008fc:	eb 05                	jmp    800903 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008fe:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800903:	5b                   	pop    %ebx
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	8b 45 08             	mov    0x8(%ebp),%eax
  80090c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800910:	eb 07                	jmp    800919 <strchr+0x13>
		if (*s == c)
  800912:	38 ca                	cmp    %cl,%dl
  800914:	74 0f                	je     800925 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800916:	83 c0 01             	add    $0x1,%eax
  800919:	0f b6 10             	movzbl (%eax),%edx
  80091c:	84 d2                	test   %dl,%dl
  80091e:	75 f2                	jne    800912 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800920:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	8b 45 08             	mov    0x8(%ebp),%eax
  80092d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800931:	eb 03                	jmp    800936 <strfind+0xf>
  800933:	83 c0 01             	add    $0x1,%eax
  800936:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800939:	38 ca                	cmp    %cl,%dl
  80093b:	74 04                	je     800941 <strfind+0x1a>
  80093d:	84 d2                	test   %dl,%dl
  80093f:	75 f2                	jne    800933 <strfind+0xc>
			break;
	return (char *) s;
}
  800941:	5d                   	pop    %ebp
  800942:	c3                   	ret    

00800943 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	57                   	push   %edi
  800947:	56                   	push   %esi
  800948:	53                   	push   %ebx
  800949:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80094f:	85 c9                	test   %ecx,%ecx
  800951:	74 36                	je     800989 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800953:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800959:	75 28                	jne    800983 <memset+0x40>
  80095b:	f6 c1 03             	test   $0x3,%cl
  80095e:	75 23                	jne    800983 <memset+0x40>
		c &= 0xFF;
  800960:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800964:	89 d3                	mov    %edx,%ebx
  800966:	c1 e3 08             	shl    $0x8,%ebx
  800969:	89 d6                	mov    %edx,%esi
  80096b:	c1 e6 18             	shl    $0x18,%esi
  80096e:	89 d0                	mov    %edx,%eax
  800970:	c1 e0 10             	shl    $0x10,%eax
  800973:	09 f0                	or     %esi,%eax
  800975:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800977:	89 d8                	mov    %ebx,%eax
  800979:	09 d0                	or     %edx,%eax
  80097b:	c1 e9 02             	shr    $0x2,%ecx
  80097e:	fc                   	cld    
  80097f:	f3 ab                	rep stos %eax,%es:(%edi)
  800981:	eb 06                	jmp    800989 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800983:	8b 45 0c             	mov    0xc(%ebp),%eax
  800986:	fc                   	cld    
  800987:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800989:	89 f8                	mov    %edi,%eax
  80098b:	5b                   	pop    %ebx
  80098c:	5e                   	pop    %esi
  80098d:	5f                   	pop    %edi
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	57                   	push   %edi
  800994:	56                   	push   %esi
  800995:	8b 45 08             	mov    0x8(%ebp),%eax
  800998:	8b 75 0c             	mov    0xc(%ebp),%esi
  80099b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80099e:	39 c6                	cmp    %eax,%esi
  8009a0:	73 35                	jae    8009d7 <memmove+0x47>
  8009a2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a5:	39 d0                	cmp    %edx,%eax
  8009a7:	73 2e                	jae    8009d7 <memmove+0x47>
		s += n;
		d += n;
  8009a9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ac:	89 d6                	mov    %edx,%esi
  8009ae:	09 fe                	or     %edi,%esi
  8009b0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b6:	75 13                	jne    8009cb <memmove+0x3b>
  8009b8:	f6 c1 03             	test   $0x3,%cl
  8009bb:	75 0e                	jne    8009cb <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009bd:	83 ef 04             	sub    $0x4,%edi
  8009c0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c3:	c1 e9 02             	shr    $0x2,%ecx
  8009c6:	fd                   	std    
  8009c7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c9:	eb 09                	jmp    8009d4 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009cb:	83 ef 01             	sub    $0x1,%edi
  8009ce:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009d1:	fd                   	std    
  8009d2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d4:	fc                   	cld    
  8009d5:	eb 1d                	jmp    8009f4 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d7:	89 f2                	mov    %esi,%edx
  8009d9:	09 c2                	or     %eax,%edx
  8009db:	f6 c2 03             	test   $0x3,%dl
  8009de:	75 0f                	jne    8009ef <memmove+0x5f>
  8009e0:	f6 c1 03             	test   $0x3,%cl
  8009e3:	75 0a                	jne    8009ef <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009e5:	c1 e9 02             	shr    $0x2,%ecx
  8009e8:	89 c7                	mov    %eax,%edi
  8009ea:	fc                   	cld    
  8009eb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ed:	eb 05                	jmp    8009f4 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ef:	89 c7                	mov    %eax,%edi
  8009f1:	fc                   	cld    
  8009f2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f4:	5e                   	pop    %esi
  8009f5:	5f                   	pop    %edi
  8009f6:	5d                   	pop    %ebp
  8009f7:	c3                   	ret    

008009f8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009fb:	ff 75 10             	pushl  0x10(%ebp)
  8009fe:	ff 75 0c             	pushl  0xc(%ebp)
  800a01:	ff 75 08             	pushl  0x8(%ebp)
  800a04:	e8 87 ff ff ff       	call   800990 <memmove>
}
  800a09:	c9                   	leave  
  800a0a:	c3                   	ret    

00800a0b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	56                   	push   %esi
  800a0f:	53                   	push   %ebx
  800a10:	8b 45 08             	mov    0x8(%ebp),%eax
  800a13:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a16:	89 c6                	mov    %eax,%esi
  800a18:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1b:	eb 1a                	jmp    800a37 <memcmp+0x2c>
		if (*s1 != *s2)
  800a1d:	0f b6 08             	movzbl (%eax),%ecx
  800a20:	0f b6 1a             	movzbl (%edx),%ebx
  800a23:	38 d9                	cmp    %bl,%cl
  800a25:	74 0a                	je     800a31 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a27:	0f b6 c1             	movzbl %cl,%eax
  800a2a:	0f b6 db             	movzbl %bl,%ebx
  800a2d:	29 d8                	sub    %ebx,%eax
  800a2f:	eb 0f                	jmp    800a40 <memcmp+0x35>
		s1++, s2++;
  800a31:	83 c0 01             	add    $0x1,%eax
  800a34:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a37:	39 f0                	cmp    %esi,%eax
  800a39:	75 e2                	jne    800a1d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a40:	5b                   	pop    %ebx
  800a41:	5e                   	pop    %esi
  800a42:	5d                   	pop    %ebp
  800a43:	c3                   	ret    

00800a44 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	53                   	push   %ebx
  800a48:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a4b:	89 c1                	mov    %eax,%ecx
  800a4d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a50:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a54:	eb 0a                	jmp    800a60 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a56:	0f b6 10             	movzbl (%eax),%edx
  800a59:	39 da                	cmp    %ebx,%edx
  800a5b:	74 07                	je     800a64 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a5d:	83 c0 01             	add    $0x1,%eax
  800a60:	39 c8                	cmp    %ecx,%eax
  800a62:	72 f2                	jb     800a56 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a64:	5b                   	pop    %ebx
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	57                   	push   %edi
  800a6b:	56                   	push   %esi
  800a6c:	53                   	push   %ebx
  800a6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a70:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a73:	eb 03                	jmp    800a78 <strtol+0x11>
		s++;
  800a75:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a78:	0f b6 01             	movzbl (%ecx),%eax
  800a7b:	3c 20                	cmp    $0x20,%al
  800a7d:	74 f6                	je     800a75 <strtol+0xe>
  800a7f:	3c 09                	cmp    $0x9,%al
  800a81:	74 f2                	je     800a75 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a83:	3c 2b                	cmp    $0x2b,%al
  800a85:	75 0a                	jne    800a91 <strtol+0x2a>
		s++;
  800a87:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a8a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8f:	eb 11                	jmp    800aa2 <strtol+0x3b>
  800a91:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a96:	3c 2d                	cmp    $0x2d,%al
  800a98:	75 08                	jne    800aa2 <strtol+0x3b>
		s++, neg = 1;
  800a9a:	83 c1 01             	add    $0x1,%ecx
  800a9d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aa8:	75 15                	jne    800abf <strtol+0x58>
  800aaa:	80 39 30             	cmpb   $0x30,(%ecx)
  800aad:	75 10                	jne    800abf <strtol+0x58>
  800aaf:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ab3:	75 7c                	jne    800b31 <strtol+0xca>
		s += 2, base = 16;
  800ab5:	83 c1 02             	add    $0x2,%ecx
  800ab8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800abd:	eb 16                	jmp    800ad5 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800abf:	85 db                	test   %ebx,%ebx
  800ac1:	75 12                	jne    800ad5 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ac3:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac8:	80 39 30             	cmpb   $0x30,(%ecx)
  800acb:	75 08                	jne    800ad5 <strtol+0x6e>
		s++, base = 8;
  800acd:	83 c1 01             	add    $0x1,%ecx
  800ad0:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ad5:	b8 00 00 00 00       	mov    $0x0,%eax
  800ada:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800add:	0f b6 11             	movzbl (%ecx),%edx
  800ae0:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ae3:	89 f3                	mov    %esi,%ebx
  800ae5:	80 fb 09             	cmp    $0x9,%bl
  800ae8:	77 08                	ja     800af2 <strtol+0x8b>
			dig = *s - '0';
  800aea:	0f be d2             	movsbl %dl,%edx
  800aed:	83 ea 30             	sub    $0x30,%edx
  800af0:	eb 22                	jmp    800b14 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800af2:	8d 72 9f             	lea    -0x61(%edx),%esi
  800af5:	89 f3                	mov    %esi,%ebx
  800af7:	80 fb 19             	cmp    $0x19,%bl
  800afa:	77 08                	ja     800b04 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800afc:	0f be d2             	movsbl %dl,%edx
  800aff:	83 ea 57             	sub    $0x57,%edx
  800b02:	eb 10                	jmp    800b14 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b04:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b07:	89 f3                	mov    %esi,%ebx
  800b09:	80 fb 19             	cmp    $0x19,%bl
  800b0c:	77 16                	ja     800b24 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b0e:	0f be d2             	movsbl %dl,%edx
  800b11:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b14:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b17:	7d 0b                	jge    800b24 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b19:	83 c1 01             	add    $0x1,%ecx
  800b1c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b20:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b22:	eb b9                	jmp    800add <strtol+0x76>

	if (endptr)
  800b24:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b28:	74 0d                	je     800b37 <strtol+0xd0>
		*endptr = (char *) s;
  800b2a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b2d:	89 0e                	mov    %ecx,(%esi)
  800b2f:	eb 06                	jmp    800b37 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b31:	85 db                	test   %ebx,%ebx
  800b33:	74 98                	je     800acd <strtol+0x66>
  800b35:	eb 9e                	jmp    800ad5 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b37:	89 c2                	mov    %eax,%edx
  800b39:	f7 da                	neg    %edx
  800b3b:	85 ff                	test   %edi,%edi
  800b3d:	0f 45 c2             	cmovne %edx,%eax
}
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5f                   	pop    %edi
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	57                   	push   %edi
  800b49:	56                   	push   %esi
  800b4a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b53:	8b 55 08             	mov    0x8(%ebp),%edx
  800b56:	89 c3                	mov    %eax,%ebx
  800b58:	89 c7                	mov    %eax,%edi
  800b5a:	89 c6                	mov    %eax,%esi
  800b5c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b5e:	5b                   	pop    %ebx
  800b5f:	5e                   	pop    %esi
  800b60:	5f                   	pop    %edi
  800b61:	5d                   	pop    %ebp
  800b62:	c3                   	ret    

00800b63 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	57                   	push   %edi
  800b67:	56                   	push   %esi
  800b68:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b69:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b73:	89 d1                	mov    %edx,%ecx
  800b75:	89 d3                	mov    %edx,%ebx
  800b77:	89 d7                	mov    %edx,%edi
  800b79:	89 d6                	mov    %edx,%esi
  800b7b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5f                   	pop    %edi
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	57                   	push   %edi
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
  800b88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b90:	b8 03 00 00 00       	mov    $0x3,%eax
  800b95:	8b 55 08             	mov    0x8(%ebp),%edx
  800b98:	89 cb                	mov    %ecx,%ebx
  800b9a:	89 cf                	mov    %ecx,%edi
  800b9c:	89 ce                	mov    %ecx,%esi
  800b9e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba0:	85 c0                	test   %eax,%eax
  800ba2:	7e 17                	jle    800bbb <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba4:	83 ec 0c             	sub    $0xc,%esp
  800ba7:	50                   	push   %eax
  800ba8:	6a 03                	push   $0x3
  800baa:	68 5f 25 80 00       	push   $0x80255f
  800baf:	6a 23                	push   $0x23
  800bb1:	68 7c 25 80 00       	push   $0x80257c
  800bb6:	e8 e5 f5 ff ff       	call   8001a0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bce:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd3:	89 d1                	mov    %edx,%ecx
  800bd5:	89 d3                	mov    %edx,%ebx
  800bd7:	89 d7                	mov    %edx,%edi
  800bd9:	89 d6                	mov    %edx,%esi
  800bdb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <sys_yield>:

void
sys_yield(void)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bed:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bf2:	89 d1                	mov    %edx,%ecx
  800bf4:	89 d3                	mov    %edx,%ebx
  800bf6:	89 d7                	mov    %edx,%edi
  800bf8:	89 d6                	mov    %edx,%esi
  800bfa:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5f                   	pop    %edi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	57                   	push   %edi
  800c05:	56                   	push   %esi
  800c06:	53                   	push   %ebx
  800c07:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0a:	be 00 00 00 00       	mov    $0x0,%esi
  800c0f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c17:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1d:	89 f7                	mov    %esi,%edi
  800c1f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c21:	85 c0                	test   %eax,%eax
  800c23:	7e 17                	jle    800c3c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c25:	83 ec 0c             	sub    $0xc,%esp
  800c28:	50                   	push   %eax
  800c29:	6a 04                	push   $0x4
  800c2b:	68 5f 25 80 00       	push   $0x80255f
  800c30:	6a 23                	push   $0x23
  800c32:	68 7c 25 80 00       	push   $0x80257c
  800c37:	e8 64 f5 ff ff       	call   8001a0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	57                   	push   %edi
  800c48:	56                   	push   %esi
  800c49:	53                   	push   %ebx
  800c4a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4d:	b8 05 00 00 00       	mov    $0x5,%eax
  800c52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c55:	8b 55 08             	mov    0x8(%ebp),%edx
  800c58:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c5b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c5e:	8b 75 18             	mov    0x18(%ebp),%esi
  800c61:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c63:	85 c0                	test   %eax,%eax
  800c65:	7e 17                	jle    800c7e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c67:	83 ec 0c             	sub    $0xc,%esp
  800c6a:	50                   	push   %eax
  800c6b:	6a 05                	push   $0x5
  800c6d:	68 5f 25 80 00       	push   $0x80255f
  800c72:	6a 23                	push   $0x23
  800c74:	68 7c 25 80 00       	push   $0x80257c
  800c79:	e8 22 f5 ff ff       	call   8001a0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
  800c8c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c94:	b8 06 00 00 00       	mov    $0x6,%eax
  800c99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9f:	89 df                	mov    %ebx,%edi
  800ca1:	89 de                	mov    %ebx,%esi
  800ca3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca5:	85 c0                	test   %eax,%eax
  800ca7:	7e 17                	jle    800cc0 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca9:	83 ec 0c             	sub    $0xc,%esp
  800cac:	50                   	push   %eax
  800cad:	6a 06                	push   $0x6
  800caf:	68 5f 25 80 00       	push   $0x80255f
  800cb4:	6a 23                	push   $0x23
  800cb6:	68 7c 25 80 00       	push   $0x80257c
  800cbb:	e8 e0 f4 ff ff       	call   8001a0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc3:	5b                   	pop    %ebx
  800cc4:	5e                   	pop    %esi
  800cc5:	5f                   	pop    %edi
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    

00800cc8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	57                   	push   %edi
  800ccc:	56                   	push   %esi
  800ccd:	53                   	push   %ebx
  800cce:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd6:	b8 08 00 00 00       	mov    $0x8,%eax
  800cdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cde:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce1:	89 df                	mov    %ebx,%edi
  800ce3:	89 de                	mov    %ebx,%esi
  800ce5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce7:	85 c0                	test   %eax,%eax
  800ce9:	7e 17                	jle    800d02 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ceb:	83 ec 0c             	sub    $0xc,%esp
  800cee:	50                   	push   %eax
  800cef:	6a 08                	push   $0x8
  800cf1:	68 5f 25 80 00       	push   $0x80255f
  800cf6:	6a 23                	push   $0x23
  800cf8:	68 7c 25 80 00       	push   $0x80257c
  800cfd:	e8 9e f4 ff ff       	call   8001a0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d05:	5b                   	pop    %ebx
  800d06:	5e                   	pop    %esi
  800d07:	5f                   	pop    %edi
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    

00800d0a <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	57                   	push   %edi
  800d0e:	56                   	push   %esi
  800d0f:	53                   	push   %ebx
  800d10:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d18:	b8 09 00 00 00       	mov    $0x9,%eax
  800d1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d20:	8b 55 08             	mov    0x8(%ebp),%edx
  800d23:	89 df                	mov    %ebx,%edi
  800d25:	89 de                	mov    %ebx,%esi
  800d27:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d29:	85 c0                	test   %eax,%eax
  800d2b:	7e 17                	jle    800d44 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2d:	83 ec 0c             	sub    $0xc,%esp
  800d30:	50                   	push   %eax
  800d31:	6a 09                	push   $0x9
  800d33:	68 5f 25 80 00       	push   $0x80255f
  800d38:	6a 23                	push   $0x23
  800d3a:	68 7c 25 80 00       	push   $0x80257c
  800d3f:	e8 5c f4 ff ff       	call   8001a0 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	57                   	push   %edi
  800d50:	56                   	push   %esi
  800d51:	53                   	push   %ebx
  800d52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	89 df                	mov    %ebx,%edi
  800d67:	89 de                	mov    %ebx,%esi
  800d69:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	7e 17                	jle    800d86 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6f:	83 ec 0c             	sub    $0xc,%esp
  800d72:	50                   	push   %eax
  800d73:	6a 0a                	push   $0xa
  800d75:	68 5f 25 80 00       	push   $0x80255f
  800d7a:	6a 23                	push   $0x23
  800d7c:	68 7c 25 80 00       	push   $0x80257c
  800d81:	e8 1a f4 ff ff       	call   8001a0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d89:	5b                   	pop    %ebx
  800d8a:	5e                   	pop    %esi
  800d8b:	5f                   	pop    %edi
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    

00800d8e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	57                   	push   %edi
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d94:	be 00 00 00 00       	mov    $0x0,%esi
  800d99:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da1:	8b 55 08             	mov    0x8(%ebp),%edx
  800da4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800daa:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dac:	5b                   	pop    %ebx
  800dad:	5e                   	pop    %esi
  800dae:	5f                   	pop    %edi
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    

00800db1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	57                   	push   %edi
  800db5:	56                   	push   %esi
  800db6:	53                   	push   %ebx
  800db7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dba:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dbf:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc7:	89 cb                	mov    %ecx,%ebx
  800dc9:	89 cf                	mov    %ecx,%edi
  800dcb:	89 ce                	mov    %ecx,%esi
  800dcd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dcf:	85 c0                	test   %eax,%eax
  800dd1:	7e 17                	jle    800dea <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd3:	83 ec 0c             	sub    $0xc,%esp
  800dd6:	50                   	push   %eax
  800dd7:	6a 0d                	push   $0xd
  800dd9:	68 5f 25 80 00       	push   $0x80255f
  800dde:	6a 23                	push   $0x23
  800de0:	68 7c 25 80 00       	push   $0x80257c
  800de5:	e8 b6 f3 ff ff       	call   8001a0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ded:	5b                   	pop    %ebx
  800dee:	5e                   	pop    %esi
  800def:	5f                   	pop    %edi
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    

00800df2 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	53                   	push   %ebx
  800df6:	83 ec 04             	sub    $0x4,%esp
  800df9:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dfc:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800dfe:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e02:	74 11                	je     800e15 <pgfault+0x23>
  800e04:	89 d8                	mov    %ebx,%eax
  800e06:	c1 e8 0c             	shr    $0xc,%eax
  800e09:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e10:	f6 c4 08             	test   $0x8,%ah
  800e13:	75 14                	jne    800e29 <pgfault+0x37>
		panic("faulting access");
  800e15:	83 ec 04             	sub    $0x4,%esp
  800e18:	68 8a 25 80 00       	push   $0x80258a
  800e1d:	6a 1d                	push   $0x1d
  800e1f:	68 9a 25 80 00       	push   $0x80259a
  800e24:	e8 77 f3 ff ff       	call   8001a0 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e29:	83 ec 04             	sub    $0x4,%esp
  800e2c:	6a 07                	push   $0x7
  800e2e:	68 00 f0 7f 00       	push   $0x7ff000
  800e33:	6a 00                	push   $0x0
  800e35:	e8 c7 fd ff ff       	call   800c01 <sys_page_alloc>
	if (r < 0) {
  800e3a:	83 c4 10             	add    $0x10,%esp
  800e3d:	85 c0                	test   %eax,%eax
  800e3f:	79 12                	jns    800e53 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e41:	50                   	push   %eax
  800e42:	68 a5 25 80 00       	push   $0x8025a5
  800e47:	6a 2b                	push   $0x2b
  800e49:	68 9a 25 80 00       	push   $0x80259a
  800e4e:	e8 4d f3 ff ff       	call   8001a0 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e53:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e59:	83 ec 04             	sub    $0x4,%esp
  800e5c:	68 00 10 00 00       	push   $0x1000
  800e61:	53                   	push   %ebx
  800e62:	68 00 f0 7f 00       	push   $0x7ff000
  800e67:	e8 8c fb ff ff       	call   8009f8 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e6c:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e73:	53                   	push   %ebx
  800e74:	6a 00                	push   $0x0
  800e76:	68 00 f0 7f 00       	push   $0x7ff000
  800e7b:	6a 00                	push   $0x0
  800e7d:	e8 c2 fd ff ff       	call   800c44 <sys_page_map>
	if (r < 0) {
  800e82:	83 c4 20             	add    $0x20,%esp
  800e85:	85 c0                	test   %eax,%eax
  800e87:	79 12                	jns    800e9b <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e89:	50                   	push   %eax
  800e8a:	68 a5 25 80 00       	push   $0x8025a5
  800e8f:	6a 32                	push   $0x32
  800e91:	68 9a 25 80 00       	push   $0x80259a
  800e96:	e8 05 f3 ff ff       	call   8001a0 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e9b:	83 ec 08             	sub    $0x8,%esp
  800e9e:	68 00 f0 7f 00       	push   $0x7ff000
  800ea3:	6a 00                	push   $0x0
  800ea5:	e8 dc fd ff ff       	call   800c86 <sys_page_unmap>
	if (r < 0) {
  800eaa:	83 c4 10             	add    $0x10,%esp
  800ead:	85 c0                	test   %eax,%eax
  800eaf:	79 12                	jns    800ec3 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800eb1:	50                   	push   %eax
  800eb2:	68 a5 25 80 00       	push   $0x8025a5
  800eb7:	6a 36                	push   $0x36
  800eb9:	68 9a 25 80 00       	push   $0x80259a
  800ebe:	e8 dd f2 ff ff       	call   8001a0 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800ec3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ec6:	c9                   	leave  
  800ec7:	c3                   	ret    

00800ec8 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	57                   	push   %edi
  800ecc:	56                   	push   %esi
  800ecd:	53                   	push   %ebx
  800ece:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800ed1:	68 f2 0d 80 00       	push   $0x800df2
  800ed6:	e8 cb 0f 00 00       	call   801ea6 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800edb:	b8 07 00 00 00       	mov    $0x7,%eax
  800ee0:	cd 30                	int    $0x30
  800ee2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800ee5:	83 c4 10             	add    $0x10,%esp
  800ee8:	85 c0                	test   %eax,%eax
  800eea:	79 17                	jns    800f03 <fork+0x3b>
		panic("fork fault %e");
  800eec:	83 ec 04             	sub    $0x4,%esp
  800eef:	68 be 25 80 00       	push   $0x8025be
  800ef4:	68 83 00 00 00       	push   $0x83
  800ef9:	68 9a 25 80 00       	push   $0x80259a
  800efe:	e8 9d f2 ff ff       	call   8001a0 <_panic>
  800f03:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f05:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f09:	75 21                	jne    800f2c <fork+0x64>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f0b:	e8 b3 fc ff ff       	call   800bc3 <sys_getenvid>
  800f10:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f15:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f18:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f1d:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f22:	b8 00 00 00 00       	mov    $0x0,%eax
  800f27:	e9 61 01 00 00       	jmp    80108d <fork+0x1c5>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f2c:	83 ec 04             	sub    $0x4,%esp
  800f2f:	6a 07                	push   $0x7
  800f31:	68 00 f0 bf ee       	push   $0xeebff000
  800f36:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f39:	e8 c3 fc ff ff       	call   800c01 <sys_page_alloc>
  800f3e:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f41:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f46:	89 d8                	mov    %ebx,%eax
  800f48:	c1 e8 16             	shr    $0x16,%eax
  800f4b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f52:	a8 01                	test   $0x1,%al
  800f54:	0f 84 fc 00 00 00    	je     801056 <fork+0x18e>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f5a:	89 d8                	mov    %ebx,%eax
  800f5c:	c1 e8 0c             	shr    $0xc,%eax
  800f5f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f66:	f6 c2 01             	test   $0x1,%dl
  800f69:	0f 84 e7 00 00 00    	je     801056 <fork+0x18e>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f6f:	89 c6                	mov    %eax,%esi
  800f71:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f74:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f7b:	f6 c6 04             	test   $0x4,%dh
  800f7e:	74 39                	je     800fb9 <fork+0xf1>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f80:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f87:	83 ec 0c             	sub    $0xc,%esp
  800f8a:	25 07 0e 00 00       	and    $0xe07,%eax
  800f8f:	50                   	push   %eax
  800f90:	56                   	push   %esi
  800f91:	57                   	push   %edi
  800f92:	56                   	push   %esi
  800f93:	6a 00                	push   $0x0
  800f95:	e8 aa fc ff ff       	call   800c44 <sys_page_map>
		if (r < 0) {
  800f9a:	83 c4 20             	add    $0x20,%esp
  800f9d:	85 c0                	test   %eax,%eax
  800f9f:	0f 89 b1 00 00 00    	jns    801056 <fork+0x18e>
		    	panic("sys page map fault %e");
  800fa5:	83 ec 04             	sub    $0x4,%esp
  800fa8:	68 cc 25 80 00       	push   $0x8025cc
  800fad:	6a 53                	push   $0x53
  800faf:	68 9a 25 80 00       	push   $0x80259a
  800fb4:	e8 e7 f1 ff ff       	call   8001a0 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800fb9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fc0:	f6 c2 02             	test   $0x2,%dl
  800fc3:	75 0c                	jne    800fd1 <fork+0x109>
  800fc5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fcc:	f6 c4 08             	test   $0x8,%ah
  800fcf:	74 5b                	je     80102c <fork+0x164>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800fd1:	83 ec 0c             	sub    $0xc,%esp
  800fd4:	68 05 08 00 00       	push   $0x805
  800fd9:	56                   	push   %esi
  800fda:	57                   	push   %edi
  800fdb:	56                   	push   %esi
  800fdc:	6a 00                	push   $0x0
  800fde:	e8 61 fc ff ff       	call   800c44 <sys_page_map>
		if (r < 0) {
  800fe3:	83 c4 20             	add    $0x20,%esp
  800fe6:	85 c0                	test   %eax,%eax
  800fe8:	79 14                	jns    800ffe <fork+0x136>
		    	panic("sys page map fault %e");
  800fea:	83 ec 04             	sub    $0x4,%esp
  800fed:	68 cc 25 80 00       	push   $0x8025cc
  800ff2:	6a 5a                	push   $0x5a
  800ff4:	68 9a 25 80 00       	push   $0x80259a
  800ff9:	e8 a2 f1 ff ff       	call   8001a0 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800ffe:	83 ec 0c             	sub    $0xc,%esp
  801001:	68 05 08 00 00       	push   $0x805
  801006:	56                   	push   %esi
  801007:	6a 00                	push   $0x0
  801009:	56                   	push   %esi
  80100a:	6a 00                	push   $0x0
  80100c:	e8 33 fc ff ff       	call   800c44 <sys_page_map>
		if (r < 0) {
  801011:	83 c4 20             	add    $0x20,%esp
  801014:	85 c0                	test   %eax,%eax
  801016:	79 3e                	jns    801056 <fork+0x18e>
		    	panic("sys page map fault %e");
  801018:	83 ec 04             	sub    $0x4,%esp
  80101b:	68 cc 25 80 00       	push   $0x8025cc
  801020:	6a 5e                	push   $0x5e
  801022:	68 9a 25 80 00       	push   $0x80259a
  801027:	e8 74 f1 ff ff       	call   8001a0 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80102c:	83 ec 0c             	sub    $0xc,%esp
  80102f:	6a 05                	push   $0x5
  801031:	56                   	push   %esi
  801032:	57                   	push   %edi
  801033:	56                   	push   %esi
  801034:	6a 00                	push   $0x0
  801036:	e8 09 fc ff ff       	call   800c44 <sys_page_map>
		if (r < 0) {
  80103b:	83 c4 20             	add    $0x20,%esp
  80103e:	85 c0                	test   %eax,%eax
  801040:	79 14                	jns    801056 <fork+0x18e>
		    	panic("sys page map fault %e");
  801042:	83 ec 04             	sub    $0x4,%esp
  801045:	68 cc 25 80 00       	push   $0x8025cc
  80104a:	6a 63                	push   $0x63
  80104c:	68 9a 25 80 00       	push   $0x80259a
  801051:	e8 4a f1 ff ff       	call   8001a0 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801056:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80105c:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801062:	0f 85 de fe ff ff    	jne    800f46 <fork+0x7e>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801068:	a1 04 40 80 00       	mov    0x804004,%eax
  80106d:	8b 40 64             	mov    0x64(%eax),%eax
  801070:	83 ec 08             	sub    $0x8,%esp
  801073:	50                   	push   %eax
  801074:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801077:	57                   	push   %edi
  801078:	e8 cf fc ff ff       	call   800d4c <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80107d:	83 c4 08             	add    $0x8,%esp
  801080:	6a 02                	push   $0x2
  801082:	57                   	push   %edi
  801083:	e8 40 fc ff ff       	call   800cc8 <sys_env_set_status>
	
	return envid;
  801088:	83 c4 10             	add    $0x10,%esp
  80108b:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80108d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801090:	5b                   	pop    %ebx
  801091:	5e                   	pop    %esi
  801092:	5f                   	pop    %edi
  801093:	5d                   	pop    %ebp
  801094:	c3                   	ret    

00801095 <sfork>:

// Challenge!
int
sfork(void)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80109b:	68 e2 25 80 00       	push   $0x8025e2
  8010a0:	68 a1 00 00 00       	push   $0xa1
  8010a5:	68 9a 25 80 00       	push   $0x80259a
  8010aa:	e8 f1 f0 ff ff       	call   8001a0 <_panic>

008010af <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010af:	55                   	push   %ebp
  8010b0:	89 e5                	mov    %esp,%ebp
  8010b2:	56                   	push   %esi
  8010b3:	53                   	push   %ebx
  8010b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8010b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8010bd:	85 c0                	test   %eax,%eax
  8010bf:	75 12                	jne    8010d3 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8010c1:	83 ec 0c             	sub    $0xc,%esp
  8010c4:	68 00 00 c0 ee       	push   $0xeec00000
  8010c9:	e8 e3 fc ff ff       	call   800db1 <sys_ipc_recv>
  8010ce:	83 c4 10             	add    $0x10,%esp
  8010d1:	eb 0c                	jmp    8010df <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8010d3:	83 ec 0c             	sub    $0xc,%esp
  8010d6:	50                   	push   %eax
  8010d7:	e8 d5 fc ff ff       	call   800db1 <sys_ipc_recv>
  8010dc:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8010df:	85 f6                	test   %esi,%esi
  8010e1:	0f 95 c1             	setne  %cl
  8010e4:	85 db                	test   %ebx,%ebx
  8010e6:	0f 95 c2             	setne  %dl
  8010e9:	84 d1                	test   %dl,%cl
  8010eb:	74 09                	je     8010f6 <ipc_recv+0x47>
  8010ed:	89 c2                	mov    %eax,%edx
  8010ef:	c1 ea 1f             	shr    $0x1f,%edx
  8010f2:	84 d2                	test   %dl,%dl
  8010f4:	75 24                	jne    80111a <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8010f6:	85 f6                	test   %esi,%esi
  8010f8:	74 0a                	je     801104 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  8010fa:	a1 04 40 80 00       	mov    0x804004,%eax
  8010ff:	8b 40 74             	mov    0x74(%eax),%eax
  801102:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801104:	85 db                	test   %ebx,%ebx
  801106:	74 0a                	je     801112 <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  801108:	a1 04 40 80 00       	mov    0x804004,%eax
  80110d:	8b 40 78             	mov    0x78(%eax),%eax
  801110:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801112:	a1 04 40 80 00       	mov    0x804004,%eax
  801117:	8b 40 70             	mov    0x70(%eax),%eax
}
  80111a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80111d:	5b                   	pop    %ebx
  80111e:	5e                   	pop    %esi
  80111f:	5d                   	pop    %ebp
  801120:	c3                   	ret    

00801121 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801121:	55                   	push   %ebp
  801122:	89 e5                	mov    %esp,%ebp
  801124:	57                   	push   %edi
  801125:	56                   	push   %esi
  801126:	53                   	push   %ebx
  801127:	83 ec 0c             	sub    $0xc,%esp
  80112a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80112d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801130:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801133:	85 db                	test   %ebx,%ebx
  801135:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80113a:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80113d:	ff 75 14             	pushl  0x14(%ebp)
  801140:	53                   	push   %ebx
  801141:	56                   	push   %esi
  801142:	57                   	push   %edi
  801143:	e8 46 fc ff ff       	call   800d8e <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801148:	89 c2                	mov    %eax,%edx
  80114a:	c1 ea 1f             	shr    $0x1f,%edx
  80114d:	83 c4 10             	add    $0x10,%esp
  801150:	84 d2                	test   %dl,%dl
  801152:	74 17                	je     80116b <ipc_send+0x4a>
  801154:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801157:	74 12                	je     80116b <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801159:	50                   	push   %eax
  80115a:	68 f8 25 80 00       	push   $0x8025f8
  80115f:	6a 47                	push   $0x47
  801161:	68 06 26 80 00       	push   $0x802606
  801166:	e8 35 f0 ff ff       	call   8001a0 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80116b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80116e:	75 07                	jne    801177 <ipc_send+0x56>
			sys_yield();
  801170:	e8 6d fa ff ff       	call   800be2 <sys_yield>
  801175:	eb c6                	jmp    80113d <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801177:	85 c0                	test   %eax,%eax
  801179:	75 c2                	jne    80113d <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80117b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117e:	5b                   	pop    %ebx
  80117f:	5e                   	pop    %esi
  801180:	5f                   	pop    %edi
  801181:	5d                   	pop    %ebp
  801182:	c3                   	ret    

00801183 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801183:	55                   	push   %ebp
  801184:	89 e5                	mov    %esp,%ebp
  801186:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801189:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80118e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801191:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801197:	8b 52 50             	mov    0x50(%edx),%edx
  80119a:	39 ca                	cmp    %ecx,%edx
  80119c:	75 0d                	jne    8011ab <ipc_find_env+0x28>
			return envs[i].env_id;
  80119e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011a1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011a6:	8b 40 48             	mov    0x48(%eax),%eax
  8011a9:	eb 0f                	jmp    8011ba <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011ab:	83 c0 01             	add    $0x1,%eax
  8011ae:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011b3:	75 d9                	jne    80118e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011ba:	5d                   	pop    %ebp
  8011bb:	c3                   	ret    

008011bc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011bc:	55                   	push   %ebp
  8011bd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c2:	05 00 00 00 30       	add    $0x30000000,%eax
  8011c7:	c1 e8 0c             	shr    $0xc,%eax
}
  8011ca:	5d                   	pop    %ebp
  8011cb:	c3                   	ret    

008011cc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d2:	05 00 00 00 30       	add    $0x30000000,%eax
  8011d7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011dc:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011e1:	5d                   	pop    %ebp
  8011e2:	c3                   	ret    

008011e3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011e3:	55                   	push   %ebp
  8011e4:	89 e5                	mov    %esp,%ebp
  8011e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011e9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011ee:	89 c2                	mov    %eax,%edx
  8011f0:	c1 ea 16             	shr    $0x16,%edx
  8011f3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011fa:	f6 c2 01             	test   $0x1,%dl
  8011fd:	74 11                	je     801210 <fd_alloc+0x2d>
  8011ff:	89 c2                	mov    %eax,%edx
  801201:	c1 ea 0c             	shr    $0xc,%edx
  801204:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80120b:	f6 c2 01             	test   $0x1,%dl
  80120e:	75 09                	jne    801219 <fd_alloc+0x36>
			*fd_store = fd;
  801210:	89 01                	mov    %eax,(%ecx)
			return 0;
  801212:	b8 00 00 00 00       	mov    $0x0,%eax
  801217:	eb 17                	jmp    801230 <fd_alloc+0x4d>
  801219:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80121e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801223:	75 c9                	jne    8011ee <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801225:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80122b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801230:	5d                   	pop    %ebp
  801231:	c3                   	ret    

00801232 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801238:	83 f8 1f             	cmp    $0x1f,%eax
  80123b:	77 36                	ja     801273 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80123d:	c1 e0 0c             	shl    $0xc,%eax
  801240:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801245:	89 c2                	mov    %eax,%edx
  801247:	c1 ea 16             	shr    $0x16,%edx
  80124a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801251:	f6 c2 01             	test   $0x1,%dl
  801254:	74 24                	je     80127a <fd_lookup+0x48>
  801256:	89 c2                	mov    %eax,%edx
  801258:	c1 ea 0c             	shr    $0xc,%edx
  80125b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801262:	f6 c2 01             	test   $0x1,%dl
  801265:	74 1a                	je     801281 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801267:	8b 55 0c             	mov    0xc(%ebp),%edx
  80126a:	89 02                	mov    %eax,(%edx)
	return 0;
  80126c:	b8 00 00 00 00       	mov    $0x0,%eax
  801271:	eb 13                	jmp    801286 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801273:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801278:	eb 0c                	jmp    801286 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80127a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80127f:	eb 05                	jmp    801286 <fd_lookup+0x54>
  801281:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801286:	5d                   	pop    %ebp
  801287:	c3                   	ret    

00801288 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
  80128b:	83 ec 08             	sub    $0x8,%esp
  80128e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801291:	ba 90 26 80 00       	mov    $0x802690,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801296:	eb 13                	jmp    8012ab <dev_lookup+0x23>
  801298:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80129b:	39 08                	cmp    %ecx,(%eax)
  80129d:	75 0c                	jne    8012ab <dev_lookup+0x23>
			*dev = devtab[i];
  80129f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a9:	eb 2e                	jmp    8012d9 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012ab:	8b 02                	mov    (%edx),%eax
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	75 e7                	jne    801298 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012b1:	a1 04 40 80 00       	mov    0x804004,%eax
  8012b6:	8b 40 48             	mov    0x48(%eax),%eax
  8012b9:	83 ec 04             	sub    $0x4,%esp
  8012bc:	51                   	push   %ecx
  8012bd:	50                   	push   %eax
  8012be:	68 10 26 80 00       	push   $0x802610
  8012c3:	e8 b1 ef ff ff       	call   800279 <cprintf>
	*dev = 0;
  8012c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012cb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012d1:	83 c4 10             	add    $0x10,%esp
  8012d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012d9:	c9                   	leave  
  8012da:	c3                   	ret    

008012db <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012db:	55                   	push   %ebp
  8012dc:	89 e5                	mov    %esp,%ebp
  8012de:	56                   	push   %esi
  8012df:	53                   	push   %ebx
  8012e0:	83 ec 10             	sub    $0x10,%esp
  8012e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8012e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ec:	50                   	push   %eax
  8012ed:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012f3:	c1 e8 0c             	shr    $0xc,%eax
  8012f6:	50                   	push   %eax
  8012f7:	e8 36 ff ff ff       	call   801232 <fd_lookup>
  8012fc:	83 c4 08             	add    $0x8,%esp
  8012ff:	85 c0                	test   %eax,%eax
  801301:	78 05                	js     801308 <fd_close+0x2d>
	    || fd != fd2)
  801303:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801306:	74 0c                	je     801314 <fd_close+0x39>
		return (must_exist ? r : 0);
  801308:	84 db                	test   %bl,%bl
  80130a:	ba 00 00 00 00       	mov    $0x0,%edx
  80130f:	0f 44 c2             	cmove  %edx,%eax
  801312:	eb 41                	jmp    801355 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801314:	83 ec 08             	sub    $0x8,%esp
  801317:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80131a:	50                   	push   %eax
  80131b:	ff 36                	pushl  (%esi)
  80131d:	e8 66 ff ff ff       	call   801288 <dev_lookup>
  801322:	89 c3                	mov    %eax,%ebx
  801324:	83 c4 10             	add    $0x10,%esp
  801327:	85 c0                	test   %eax,%eax
  801329:	78 1a                	js     801345 <fd_close+0x6a>
		if (dev->dev_close)
  80132b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80132e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801331:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801336:	85 c0                	test   %eax,%eax
  801338:	74 0b                	je     801345 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80133a:	83 ec 0c             	sub    $0xc,%esp
  80133d:	56                   	push   %esi
  80133e:	ff d0                	call   *%eax
  801340:	89 c3                	mov    %eax,%ebx
  801342:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801345:	83 ec 08             	sub    $0x8,%esp
  801348:	56                   	push   %esi
  801349:	6a 00                	push   $0x0
  80134b:	e8 36 f9 ff ff       	call   800c86 <sys_page_unmap>
	return r;
  801350:	83 c4 10             	add    $0x10,%esp
  801353:	89 d8                	mov    %ebx,%eax
}
  801355:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801358:	5b                   	pop    %ebx
  801359:	5e                   	pop    %esi
  80135a:	5d                   	pop    %ebp
  80135b:	c3                   	ret    

0080135c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80135c:	55                   	push   %ebp
  80135d:	89 e5                	mov    %esp,%ebp
  80135f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801362:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801365:	50                   	push   %eax
  801366:	ff 75 08             	pushl  0x8(%ebp)
  801369:	e8 c4 fe ff ff       	call   801232 <fd_lookup>
  80136e:	83 c4 08             	add    $0x8,%esp
  801371:	85 c0                	test   %eax,%eax
  801373:	78 10                	js     801385 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801375:	83 ec 08             	sub    $0x8,%esp
  801378:	6a 01                	push   $0x1
  80137a:	ff 75 f4             	pushl  -0xc(%ebp)
  80137d:	e8 59 ff ff ff       	call   8012db <fd_close>
  801382:	83 c4 10             	add    $0x10,%esp
}
  801385:	c9                   	leave  
  801386:	c3                   	ret    

00801387 <close_all>:

void
close_all(void)
{
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
  80138a:	53                   	push   %ebx
  80138b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80138e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801393:	83 ec 0c             	sub    $0xc,%esp
  801396:	53                   	push   %ebx
  801397:	e8 c0 ff ff ff       	call   80135c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80139c:	83 c3 01             	add    $0x1,%ebx
  80139f:	83 c4 10             	add    $0x10,%esp
  8013a2:	83 fb 20             	cmp    $0x20,%ebx
  8013a5:	75 ec                	jne    801393 <close_all+0xc>
		close(i);
}
  8013a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013aa:	c9                   	leave  
  8013ab:	c3                   	ret    

008013ac <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013ac:	55                   	push   %ebp
  8013ad:	89 e5                	mov    %esp,%ebp
  8013af:	57                   	push   %edi
  8013b0:	56                   	push   %esi
  8013b1:	53                   	push   %ebx
  8013b2:	83 ec 2c             	sub    $0x2c,%esp
  8013b5:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013b8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013bb:	50                   	push   %eax
  8013bc:	ff 75 08             	pushl  0x8(%ebp)
  8013bf:	e8 6e fe ff ff       	call   801232 <fd_lookup>
  8013c4:	83 c4 08             	add    $0x8,%esp
  8013c7:	85 c0                	test   %eax,%eax
  8013c9:	0f 88 c1 00 00 00    	js     801490 <dup+0xe4>
		return r;
	close(newfdnum);
  8013cf:	83 ec 0c             	sub    $0xc,%esp
  8013d2:	56                   	push   %esi
  8013d3:	e8 84 ff ff ff       	call   80135c <close>

	newfd = INDEX2FD(newfdnum);
  8013d8:	89 f3                	mov    %esi,%ebx
  8013da:	c1 e3 0c             	shl    $0xc,%ebx
  8013dd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013e3:	83 c4 04             	add    $0x4,%esp
  8013e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013e9:	e8 de fd ff ff       	call   8011cc <fd2data>
  8013ee:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013f0:	89 1c 24             	mov    %ebx,(%esp)
  8013f3:	e8 d4 fd ff ff       	call   8011cc <fd2data>
  8013f8:	83 c4 10             	add    $0x10,%esp
  8013fb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013fe:	89 f8                	mov    %edi,%eax
  801400:	c1 e8 16             	shr    $0x16,%eax
  801403:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80140a:	a8 01                	test   $0x1,%al
  80140c:	74 37                	je     801445 <dup+0x99>
  80140e:	89 f8                	mov    %edi,%eax
  801410:	c1 e8 0c             	shr    $0xc,%eax
  801413:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80141a:	f6 c2 01             	test   $0x1,%dl
  80141d:	74 26                	je     801445 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80141f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801426:	83 ec 0c             	sub    $0xc,%esp
  801429:	25 07 0e 00 00       	and    $0xe07,%eax
  80142e:	50                   	push   %eax
  80142f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801432:	6a 00                	push   $0x0
  801434:	57                   	push   %edi
  801435:	6a 00                	push   $0x0
  801437:	e8 08 f8 ff ff       	call   800c44 <sys_page_map>
  80143c:	89 c7                	mov    %eax,%edi
  80143e:	83 c4 20             	add    $0x20,%esp
  801441:	85 c0                	test   %eax,%eax
  801443:	78 2e                	js     801473 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801445:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801448:	89 d0                	mov    %edx,%eax
  80144a:	c1 e8 0c             	shr    $0xc,%eax
  80144d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801454:	83 ec 0c             	sub    $0xc,%esp
  801457:	25 07 0e 00 00       	and    $0xe07,%eax
  80145c:	50                   	push   %eax
  80145d:	53                   	push   %ebx
  80145e:	6a 00                	push   $0x0
  801460:	52                   	push   %edx
  801461:	6a 00                	push   $0x0
  801463:	e8 dc f7 ff ff       	call   800c44 <sys_page_map>
  801468:	89 c7                	mov    %eax,%edi
  80146a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80146d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80146f:	85 ff                	test   %edi,%edi
  801471:	79 1d                	jns    801490 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801473:	83 ec 08             	sub    $0x8,%esp
  801476:	53                   	push   %ebx
  801477:	6a 00                	push   $0x0
  801479:	e8 08 f8 ff ff       	call   800c86 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80147e:	83 c4 08             	add    $0x8,%esp
  801481:	ff 75 d4             	pushl  -0x2c(%ebp)
  801484:	6a 00                	push   $0x0
  801486:	e8 fb f7 ff ff       	call   800c86 <sys_page_unmap>
	return r;
  80148b:	83 c4 10             	add    $0x10,%esp
  80148e:	89 f8                	mov    %edi,%eax
}
  801490:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801493:	5b                   	pop    %ebx
  801494:	5e                   	pop    %esi
  801495:	5f                   	pop    %edi
  801496:	5d                   	pop    %ebp
  801497:	c3                   	ret    

00801498 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801498:	55                   	push   %ebp
  801499:	89 e5                	mov    %esp,%ebp
  80149b:	53                   	push   %ebx
  80149c:	83 ec 14             	sub    $0x14,%esp
  80149f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a5:	50                   	push   %eax
  8014a6:	53                   	push   %ebx
  8014a7:	e8 86 fd ff ff       	call   801232 <fd_lookup>
  8014ac:	83 c4 08             	add    $0x8,%esp
  8014af:	89 c2                	mov    %eax,%edx
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	78 6d                	js     801522 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b5:	83 ec 08             	sub    $0x8,%esp
  8014b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014bb:	50                   	push   %eax
  8014bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014bf:	ff 30                	pushl  (%eax)
  8014c1:	e8 c2 fd ff ff       	call   801288 <dev_lookup>
  8014c6:	83 c4 10             	add    $0x10,%esp
  8014c9:	85 c0                	test   %eax,%eax
  8014cb:	78 4c                	js     801519 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014cd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014d0:	8b 42 08             	mov    0x8(%edx),%eax
  8014d3:	83 e0 03             	and    $0x3,%eax
  8014d6:	83 f8 01             	cmp    $0x1,%eax
  8014d9:	75 21                	jne    8014fc <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014db:	a1 04 40 80 00       	mov    0x804004,%eax
  8014e0:	8b 40 48             	mov    0x48(%eax),%eax
  8014e3:	83 ec 04             	sub    $0x4,%esp
  8014e6:	53                   	push   %ebx
  8014e7:	50                   	push   %eax
  8014e8:	68 54 26 80 00       	push   $0x802654
  8014ed:	e8 87 ed ff ff       	call   800279 <cprintf>
		return -E_INVAL;
  8014f2:	83 c4 10             	add    $0x10,%esp
  8014f5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014fa:	eb 26                	jmp    801522 <read+0x8a>
	}
	if (!dev->dev_read)
  8014fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ff:	8b 40 08             	mov    0x8(%eax),%eax
  801502:	85 c0                	test   %eax,%eax
  801504:	74 17                	je     80151d <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801506:	83 ec 04             	sub    $0x4,%esp
  801509:	ff 75 10             	pushl  0x10(%ebp)
  80150c:	ff 75 0c             	pushl  0xc(%ebp)
  80150f:	52                   	push   %edx
  801510:	ff d0                	call   *%eax
  801512:	89 c2                	mov    %eax,%edx
  801514:	83 c4 10             	add    $0x10,%esp
  801517:	eb 09                	jmp    801522 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801519:	89 c2                	mov    %eax,%edx
  80151b:	eb 05                	jmp    801522 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80151d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801522:	89 d0                	mov    %edx,%eax
  801524:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801527:	c9                   	leave  
  801528:	c3                   	ret    

00801529 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801529:	55                   	push   %ebp
  80152a:	89 e5                	mov    %esp,%ebp
  80152c:	57                   	push   %edi
  80152d:	56                   	push   %esi
  80152e:	53                   	push   %ebx
  80152f:	83 ec 0c             	sub    $0xc,%esp
  801532:	8b 7d 08             	mov    0x8(%ebp),%edi
  801535:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801538:	bb 00 00 00 00       	mov    $0x0,%ebx
  80153d:	eb 21                	jmp    801560 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80153f:	83 ec 04             	sub    $0x4,%esp
  801542:	89 f0                	mov    %esi,%eax
  801544:	29 d8                	sub    %ebx,%eax
  801546:	50                   	push   %eax
  801547:	89 d8                	mov    %ebx,%eax
  801549:	03 45 0c             	add    0xc(%ebp),%eax
  80154c:	50                   	push   %eax
  80154d:	57                   	push   %edi
  80154e:	e8 45 ff ff ff       	call   801498 <read>
		if (m < 0)
  801553:	83 c4 10             	add    $0x10,%esp
  801556:	85 c0                	test   %eax,%eax
  801558:	78 10                	js     80156a <readn+0x41>
			return m;
		if (m == 0)
  80155a:	85 c0                	test   %eax,%eax
  80155c:	74 0a                	je     801568 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80155e:	01 c3                	add    %eax,%ebx
  801560:	39 f3                	cmp    %esi,%ebx
  801562:	72 db                	jb     80153f <readn+0x16>
  801564:	89 d8                	mov    %ebx,%eax
  801566:	eb 02                	jmp    80156a <readn+0x41>
  801568:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80156a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80156d:	5b                   	pop    %ebx
  80156e:	5e                   	pop    %esi
  80156f:	5f                   	pop    %edi
  801570:	5d                   	pop    %ebp
  801571:	c3                   	ret    

00801572 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801572:	55                   	push   %ebp
  801573:	89 e5                	mov    %esp,%ebp
  801575:	53                   	push   %ebx
  801576:	83 ec 14             	sub    $0x14,%esp
  801579:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80157c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80157f:	50                   	push   %eax
  801580:	53                   	push   %ebx
  801581:	e8 ac fc ff ff       	call   801232 <fd_lookup>
  801586:	83 c4 08             	add    $0x8,%esp
  801589:	89 c2                	mov    %eax,%edx
  80158b:	85 c0                	test   %eax,%eax
  80158d:	78 68                	js     8015f7 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80158f:	83 ec 08             	sub    $0x8,%esp
  801592:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801595:	50                   	push   %eax
  801596:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801599:	ff 30                	pushl  (%eax)
  80159b:	e8 e8 fc ff ff       	call   801288 <dev_lookup>
  8015a0:	83 c4 10             	add    $0x10,%esp
  8015a3:	85 c0                	test   %eax,%eax
  8015a5:	78 47                	js     8015ee <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015aa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015ae:	75 21                	jne    8015d1 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015b0:	a1 04 40 80 00       	mov    0x804004,%eax
  8015b5:	8b 40 48             	mov    0x48(%eax),%eax
  8015b8:	83 ec 04             	sub    $0x4,%esp
  8015bb:	53                   	push   %ebx
  8015bc:	50                   	push   %eax
  8015bd:	68 70 26 80 00       	push   $0x802670
  8015c2:	e8 b2 ec ff ff       	call   800279 <cprintf>
		return -E_INVAL;
  8015c7:	83 c4 10             	add    $0x10,%esp
  8015ca:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015cf:	eb 26                	jmp    8015f7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d4:	8b 52 0c             	mov    0xc(%edx),%edx
  8015d7:	85 d2                	test   %edx,%edx
  8015d9:	74 17                	je     8015f2 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015db:	83 ec 04             	sub    $0x4,%esp
  8015de:	ff 75 10             	pushl  0x10(%ebp)
  8015e1:	ff 75 0c             	pushl  0xc(%ebp)
  8015e4:	50                   	push   %eax
  8015e5:	ff d2                	call   *%edx
  8015e7:	89 c2                	mov    %eax,%edx
  8015e9:	83 c4 10             	add    $0x10,%esp
  8015ec:	eb 09                	jmp    8015f7 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ee:	89 c2                	mov    %eax,%edx
  8015f0:	eb 05                	jmp    8015f7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015f2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015f7:	89 d0                	mov    %edx,%eax
  8015f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015fc:	c9                   	leave  
  8015fd:	c3                   	ret    

008015fe <seek>:

int
seek(int fdnum, off_t offset)
{
  8015fe:	55                   	push   %ebp
  8015ff:	89 e5                	mov    %esp,%ebp
  801601:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801604:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801607:	50                   	push   %eax
  801608:	ff 75 08             	pushl  0x8(%ebp)
  80160b:	e8 22 fc ff ff       	call   801232 <fd_lookup>
  801610:	83 c4 08             	add    $0x8,%esp
  801613:	85 c0                	test   %eax,%eax
  801615:	78 0e                	js     801625 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801617:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80161a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80161d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801620:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801625:	c9                   	leave  
  801626:	c3                   	ret    

00801627 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801627:	55                   	push   %ebp
  801628:	89 e5                	mov    %esp,%ebp
  80162a:	53                   	push   %ebx
  80162b:	83 ec 14             	sub    $0x14,%esp
  80162e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801631:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801634:	50                   	push   %eax
  801635:	53                   	push   %ebx
  801636:	e8 f7 fb ff ff       	call   801232 <fd_lookup>
  80163b:	83 c4 08             	add    $0x8,%esp
  80163e:	89 c2                	mov    %eax,%edx
  801640:	85 c0                	test   %eax,%eax
  801642:	78 65                	js     8016a9 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801644:	83 ec 08             	sub    $0x8,%esp
  801647:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164a:	50                   	push   %eax
  80164b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164e:	ff 30                	pushl  (%eax)
  801650:	e8 33 fc ff ff       	call   801288 <dev_lookup>
  801655:	83 c4 10             	add    $0x10,%esp
  801658:	85 c0                	test   %eax,%eax
  80165a:	78 44                	js     8016a0 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80165c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801663:	75 21                	jne    801686 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801665:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80166a:	8b 40 48             	mov    0x48(%eax),%eax
  80166d:	83 ec 04             	sub    $0x4,%esp
  801670:	53                   	push   %ebx
  801671:	50                   	push   %eax
  801672:	68 30 26 80 00       	push   $0x802630
  801677:	e8 fd eb ff ff       	call   800279 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80167c:	83 c4 10             	add    $0x10,%esp
  80167f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801684:	eb 23                	jmp    8016a9 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801686:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801689:	8b 52 18             	mov    0x18(%edx),%edx
  80168c:	85 d2                	test   %edx,%edx
  80168e:	74 14                	je     8016a4 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801690:	83 ec 08             	sub    $0x8,%esp
  801693:	ff 75 0c             	pushl  0xc(%ebp)
  801696:	50                   	push   %eax
  801697:	ff d2                	call   *%edx
  801699:	89 c2                	mov    %eax,%edx
  80169b:	83 c4 10             	add    $0x10,%esp
  80169e:	eb 09                	jmp    8016a9 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a0:	89 c2                	mov    %eax,%edx
  8016a2:	eb 05                	jmp    8016a9 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016a4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016a9:	89 d0                	mov    %edx,%eax
  8016ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ae:	c9                   	leave  
  8016af:	c3                   	ret    

008016b0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	53                   	push   %ebx
  8016b4:	83 ec 14             	sub    $0x14,%esp
  8016b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016bd:	50                   	push   %eax
  8016be:	ff 75 08             	pushl  0x8(%ebp)
  8016c1:	e8 6c fb ff ff       	call   801232 <fd_lookup>
  8016c6:	83 c4 08             	add    $0x8,%esp
  8016c9:	89 c2                	mov    %eax,%edx
  8016cb:	85 c0                	test   %eax,%eax
  8016cd:	78 58                	js     801727 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016cf:	83 ec 08             	sub    $0x8,%esp
  8016d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d5:	50                   	push   %eax
  8016d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d9:	ff 30                	pushl  (%eax)
  8016db:	e8 a8 fb ff ff       	call   801288 <dev_lookup>
  8016e0:	83 c4 10             	add    $0x10,%esp
  8016e3:	85 c0                	test   %eax,%eax
  8016e5:	78 37                	js     80171e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ea:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016ee:	74 32                	je     801722 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016f0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016f3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016fa:	00 00 00 
	stat->st_isdir = 0;
  8016fd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801704:	00 00 00 
	stat->st_dev = dev;
  801707:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80170d:	83 ec 08             	sub    $0x8,%esp
  801710:	53                   	push   %ebx
  801711:	ff 75 f0             	pushl  -0x10(%ebp)
  801714:	ff 50 14             	call   *0x14(%eax)
  801717:	89 c2                	mov    %eax,%edx
  801719:	83 c4 10             	add    $0x10,%esp
  80171c:	eb 09                	jmp    801727 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80171e:	89 c2                	mov    %eax,%edx
  801720:	eb 05                	jmp    801727 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801722:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801727:	89 d0                	mov    %edx,%eax
  801729:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172c:	c9                   	leave  
  80172d:	c3                   	ret    

0080172e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80172e:	55                   	push   %ebp
  80172f:	89 e5                	mov    %esp,%ebp
  801731:	56                   	push   %esi
  801732:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801733:	83 ec 08             	sub    $0x8,%esp
  801736:	6a 00                	push   $0x0
  801738:	ff 75 08             	pushl  0x8(%ebp)
  80173b:	e8 e3 01 00 00       	call   801923 <open>
  801740:	89 c3                	mov    %eax,%ebx
  801742:	83 c4 10             	add    $0x10,%esp
  801745:	85 c0                	test   %eax,%eax
  801747:	78 1b                	js     801764 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801749:	83 ec 08             	sub    $0x8,%esp
  80174c:	ff 75 0c             	pushl  0xc(%ebp)
  80174f:	50                   	push   %eax
  801750:	e8 5b ff ff ff       	call   8016b0 <fstat>
  801755:	89 c6                	mov    %eax,%esi
	close(fd);
  801757:	89 1c 24             	mov    %ebx,(%esp)
  80175a:	e8 fd fb ff ff       	call   80135c <close>
	return r;
  80175f:	83 c4 10             	add    $0x10,%esp
  801762:	89 f0                	mov    %esi,%eax
}
  801764:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801767:	5b                   	pop    %ebx
  801768:	5e                   	pop    %esi
  801769:	5d                   	pop    %ebp
  80176a:	c3                   	ret    

0080176b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80176b:	55                   	push   %ebp
  80176c:	89 e5                	mov    %esp,%ebp
  80176e:	56                   	push   %esi
  80176f:	53                   	push   %ebx
  801770:	89 c6                	mov    %eax,%esi
  801772:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801774:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80177b:	75 12                	jne    80178f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80177d:	83 ec 0c             	sub    $0xc,%esp
  801780:	6a 01                	push   $0x1
  801782:	e8 fc f9 ff ff       	call   801183 <ipc_find_env>
  801787:	a3 00 40 80 00       	mov    %eax,0x804000
  80178c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80178f:	6a 07                	push   $0x7
  801791:	68 00 50 80 00       	push   $0x805000
  801796:	56                   	push   %esi
  801797:	ff 35 00 40 80 00    	pushl  0x804000
  80179d:	e8 7f f9 ff ff       	call   801121 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017a2:	83 c4 0c             	add    $0xc,%esp
  8017a5:	6a 00                	push   $0x0
  8017a7:	53                   	push   %ebx
  8017a8:	6a 00                	push   $0x0
  8017aa:	e8 00 f9 ff ff       	call   8010af <ipc_recv>
}
  8017af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b2:	5b                   	pop    %ebx
  8017b3:	5e                   	pop    %esi
  8017b4:	5d                   	pop    %ebp
  8017b5:	c3                   	ret    

008017b6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017b6:	55                   	push   %ebp
  8017b7:	89 e5                	mov    %esp,%ebp
  8017b9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bf:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ca:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d4:	b8 02 00 00 00       	mov    $0x2,%eax
  8017d9:	e8 8d ff ff ff       	call   80176b <fsipc>
}
  8017de:	c9                   	leave  
  8017df:	c3                   	ret    

008017e0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017e0:	55                   	push   %ebp
  8017e1:	89 e5                	mov    %esp,%ebp
  8017e3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e9:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ec:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8017fb:	e8 6b ff ff ff       	call   80176b <fsipc>
}
  801800:	c9                   	leave  
  801801:	c3                   	ret    

00801802 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801802:	55                   	push   %ebp
  801803:	89 e5                	mov    %esp,%ebp
  801805:	53                   	push   %ebx
  801806:	83 ec 04             	sub    $0x4,%esp
  801809:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80180c:	8b 45 08             	mov    0x8(%ebp),%eax
  80180f:	8b 40 0c             	mov    0xc(%eax),%eax
  801812:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801817:	ba 00 00 00 00       	mov    $0x0,%edx
  80181c:	b8 05 00 00 00       	mov    $0x5,%eax
  801821:	e8 45 ff ff ff       	call   80176b <fsipc>
  801826:	85 c0                	test   %eax,%eax
  801828:	78 2c                	js     801856 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80182a:	83 ec 08             	sub    $0x8,%esp
  80182d:	68 00 50 80 00       	push   $0x805000
  801832:	53                   	push   %ebx
  801833:	e8 c6 ef ff ff       	call   8007fe <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801838:	a1 80 50 80 00       	mov    0x805080,%eax
  80183d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801843:	a1 84 50 80 00       	mov    0x805084,%eax
  801848:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80184e:	83 c4 10             	add    $0x10,%esp
  801851:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801856:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801859:	c9                   	leave  
  80185a:	c3                   	ret    

0080185b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80185b:	55                   	push   %ebp
  80185c:	89 e5                	mov    %esp,%ebp
  80185e:	83 ec 0c             	sub    $0xc,%esp
  801861:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801864:	8b 55 08             	mov    0x8(%ebp),%edx
  801867:	8b 52 0c             	mov    0xc(%edx),%edx
  80186a:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801870:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801875:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80187a:	0f 47 c2             	cmova  %edx,%eax
  80187d:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801882:	50                   	push   %eax
  801883:	ff 75 0c             	pushl  0xc(%ebp)
  801886:	68 08 50 80 00       	push   $0x805008
  80188b:	e8 00 f1 ff ff       	call   800990 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801890:	ba 00 00 00 00       	mov    $0x0,%edx
  801895:	b8 04 00 00 00       	mov    $0x4,%eax
  80189a:	e8 cc fe ff ff       	call   80176b <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80189f:	c9                   	leave  
  8018a0:	c3                   	ret    

008018a1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018a1:	55                   	push   %ebp
  8018a2:	89 e5                	mov    %esp,%ebp
  8018a4:	56                   	push   %esi
  8018a5:	53                   	push   %ebx
  8018a6:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ac:	8b 40 0c             	mov    0xc(%eax),%eax
  8018af:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018b4:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8018bf:	b8 03 00 00 00       	mov    $0x3,%eax
  8018c4:	e8 a2 fe ff ff       	call   80176b <fsipc>
  8018c9:	89 c3                	mov    %eax,%ebx
  8018cb:	85 c0                	test   %eax,%eax
  8018cd:	78 4b                	js     80191a <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018cf:	39 c6                	cmp    %eax,%esi
  8018d1:	73 16                	jae    8018e9 <devfile_read+0x48>
  8018d3:	68 a0 26 80 00       	push   $0x8026a0
  8018d8:	68 a7 26 80 00       	push   $0x8026a7
  8018dd:	6a 7c                	push   $0x7c
  8018df:	68 bc 26 80 00       	push   $0x8026bc
  8018e4:	e8 b7 e8 ff ff       	call   8001a0 <_panic>
	assert(r <= PGSIZE);
  8018e9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018ee:	7e 16                	jle    801906 <devfile_read+0x65>
  8018f0:	68 c7 26 80 00       	push   $0x8026c7
  8018f5:	68 a7 26 80 00       	push   $0x8026a7
  8018fa:	6a 7d                	push   $0x7d
  8018fc:	68 bc 26 80 00       	push   $0x8026bc
  801901:	e8 9a e8 ff ff       	call   8001a0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801906:	83 ec 04             	sub    $0x4,%esp
  801909:	50                   	push   %eax
  80190a:	68 00 50 80 00       	push   $0x805000
  80190f:	ff 75 0c             	pushl  0xc(%ebp)
  801912:	e8 79 f0 ff ff       	call   800990 <memmove>
	return r;
  801917:	83 c4 10             	add    $0x10,%esp
}
  80191a:	89 d8                	mov    %ebx,%eax
  80191c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80191f:	5b                   	pop    %ebx
  801920:	5e                   	pop    %esi
  801921:	5d                   	pop    %ebp
  801922:	c3                   	ret    

00801923 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801923:	55                   	push   %ebp
  801924:	89 e5                	mov    %esp,%ebp
  801926:	53                   	push   %ebx
  801927:	83 ec 20             	sub    $0x20,%esp
  80192a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80192d:	53                   	push   %ebx
  80192e:	e8 92 ee ff ff       	call   8007c5 <strlen>
  801933:	83 c4 10             	add    $0x10,%esp
  801936:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80193b:	7f 67                	jg     8019a4 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80193d:	83 ec 0c             	sub    $0xc,%esp
  801940:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801943:	50                   	push   %eax
  801944:	e8 9a f8 ff ff       	call   8011e3 <fd_alloc>
  801949:	83 c4 10             	add    $0x10,%esp
		return r;
  80194c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80194e:	85 c0                	test   %eax,%eax
  801950:	78 57                	js     8019a9 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801952:	83 ec 08             	sub    $0x8,%esp
  801955:	53                   	push   %ebx
  801956:	68 00 50 80 00       	push   $0x805000
  80195b:	e8 9e ee ff ff       	call   8007fe <strcpy>
	fsipcbuf.open.req_omode = mode;
  801960:	8b 45 0c             	mov    0xc(%ebp),%eax
  801963:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801968:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80196b:	b8 01 00 00 00       	mov    $0x1,%eax
  801970:	e8 f6 fd ff ff       	call   80176b <fsipc>
  801975:	89 c3                	mov    %eax,%ebx
  801977:	83 c4 10             	add    $0x10,%esp
  80197a:	85 c0                	test   %eax,%eax
  80197c:	79 14                	jns    801992 <open+0x6f>
		fd_close(fd, 0);
  80197e:	83 ec 08             	sub    $0x8,%esp
  801981:	6a 00                	push   $0x0
  801983:	ff 75 f4             	pushl  -0xc(%ebp)
  801986:	e8 50 f9 ff ff       	call   8012db <fd_close>
		return r;
  80198b:	83 c4 10             	add    $0x10,%esp
  80198e:	89 da                	mov    %ebx,%edx
  801990:	eb 17                	jmp    8019a9 <open+0x86>
	}

	return fd2num(fd);
  801992:	83 ec 0c             	sub    $0xc,%esp
  801995:	ff 75 f4             	pushl  -0xc(%ebp)
  801998:	e8 1f f8 ff ff       	call   8011bc <fd2num>
  80199d:	89 c2                	mov    %eax,%edx
  80199f:	83 c4 10             	add    $0x10,%esp
  8019a2:	eb 05                	jmp    8019a9 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019a4:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019a9:	89 d0                	mov    %edx,%eax
  8019ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ae:	c9                   	leave  
  8019af:	c3                   	ret    

008019b0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8019bb:	b8 08 00 00 00       	mov    $0x8,%eax
  8019c0:	e8 a6 fd ff ff       	call   80176b <fsipc>
}
  8019c5:	c9                   	leave  
  8019c6:	c3                   	ret    

008019c7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019c7:	55                   	push   %ebp
  8019c8:	89 e5                	mov    %esp,%ebp
  8019ca:	56                   	push   %esi
  8019cb:	53                   	push   %ebx
  8019cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019cf:	83 ec 0c             	sub    $0xc,%esp
  8019d2:	ff 75 08             	pushl  0x8(%ebp)
  8019d5:	e8 f2 f7 ff ff       	call   8011cc <fd2data>
  8019da:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019dc:	83 c4 08             	add    $0x8,%esp
  8019df:	68 d3 26 80 00       	push   $0x8026d3
  8019e4:	53                   	push   %ebx
  8019e5:	e8 14 ee ff ff       	call   8007fe <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019ea:	8b 46 04             	mov    0x4(%esi),%eax
  8019ed:	2b 06                	sub    (%esi),%eax
  8019ef:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019f5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019fc:	00 00 00 
	stat->st_dev = &devpipe;
  8019ff:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a06:	30 80 00 
	return 0;
}
  801a09:	b8 00 00 00 00       	mov    $0x0,%eax
  801a0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a11:	5b                   	pop    %ebx
  801a12:	5e                   	pop    %esi
  801a13:	5d                   	pop    %ebp
  801a14:	c3                   	ret    

00801a15 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a15:	55                   	push   %ebp
  801a16:	89 e5                	mov    %esp,%ebp
  801a18:	53                   	push   %ebx
  801a19:	83 ec 0c             	sub    $0xc,%esp
  801a1c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a1f:	53                   	push   %ebx
  801a20:	6a 00                	push   $0x0
  801a22:	e8 5f f2 ff ff       	call   800c86 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a27:	89 1c 24             	mov    %ebx,(%esp)
  801a2a:	e8 9d f7 ff ff       	call   8011cc <fd2data>
  801a2f:	83 c4 08             	add    $0x8,%esp
  801a32:	50                   	push   %eax
  801a33:	6a 00                	push   $0x0
  801a35:	e8 4c f2 ff ff       	call   800c86 <sys_page_unmap>
}
  801a3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a3d:	c9                   	leave  
  801a3e:	c3                   	ret    

00801a3f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a3f:	55                   	push   %ebp
  801a40:	89 e5                	mov    %esp,%ebp
  801a42:	57                   	push   %edi
  801a43:	56                   	push   %esi
  801a44:	53                   	push   %ebx
  801a45:	83 ec 1c             	sub    $0x1c,%esp
  801a48:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a4b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a4d:	a1 04 40 80 00       	mov    0x804004,%eax
  801a52:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a55:	83 ec 0c             	sub    $0xc,%esp
  801a58:	ff 75 e0             	pushl  -0x20(%ebp)
  801a5b:	e8 d5 04 00 00       	call   801f35 <pageref>
  801a60:	89 c3                	mov    %eax,%ebx
  801a62:	89 3c 24             	mov    %edi,(%esp)
  801a65:	e8 cb 04 00 00       	call   801f35 <pageref>
  801a6a:	83 c4 10             	add    $0x10,%esp
  801a6d:	39 c3                	cmp    %eax,%ebx
  801a6f:	0f 94 c1             	sete   %cl
  801a72:	0f b6 c9             	movzbl %cl,%ecx
  801a75:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a78:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a7e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a81:	39 ce                	cmp    %ecx,%esi
  801a83:	74 1b                	je     801aa0 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a85:	39 c3                	cmp    %eax,%ebx
  801a87:	75 c4                	jne    801a4d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a89:	8b 42 58             	mov    0x58(%edx),%eax
  801a8c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a8f:	50                   	push   %eax
  801a90:	56                   	push   %esi
  801a91:	68 da 26 80 00       	push   $0x8026da
  801a96:	e8 de e7 ff ff       	call   800279 <cprintf>
  801a9b:	83 c4 10             	add    $0x10,%esp
  801a9e:	eb ad                	jmp    801a4d <_pipeisclosed+0xe>
	}
}
  801aa0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801aa3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa6:	5b                   	pop    %ebx
  801aa7:	5e                   	pop    %esi
  801aa8:	5f                   	pop    %edi
  801aa9:	5d                   	pop    %ebp
  801aaa:	c3                   	ret    

00801aab <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801aab:	55                   	push   %ebp
  801aac:	89 e5                	mov    %esp,%ebp
  801aae:	57                   	push   %edi
  801aaf:	56                   	push   %esi
  801ab0:	53                   	push   %ebx
  801ab1:	83 ec 28             	sub    $0x28,%esp
  801ab4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ab7:	56                   	push   %esi
  801ab8:	e8 0f f7 ff ff       	call   8011cc <fd2data>
  801abd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801abf:	83 c4 10             	add    $0x10,%esp
  801ac2:	bf 00 00 00 00       	mov    $0x0,%edi
  801ac7:	eb 4b                	jmp    801b14 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ac9:	89 da                	mov    %ebx,%edx
  801acb:	89 f0                	mov    %esi,%eax
  801acd:	e8 6d ff ff ff       	call   801a3f <_pipeisclosed>
  801ad2:	85 c0                	test   %eax,%eax
  801ad4:	75 48                	jne    801b1e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ad6:	e8 07 f1 ff ff       	call   800be2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801adb:	8b 43 04             	mov    0x4(%ebx),%eax
  801ade:	8b 0b                	mov    (%ebx),%ecx
  801ae0:	8d 51 20             	lea    0x20(%ecx),%edx
  801ae3:	39 d0                	cmp    %edx,%eax
  801ae5:	73 e2                	jae    801ac9 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ae7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aea:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801aee:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801af1:	89 c2                	mov    %eax,%edx
  801af3:	c1 fa 1f             	sar    $0x1f,%edx
  801af6:	89 d1                	mov    %edx,%ecx
  801af8:	c1 e9 1b             	shr    $0x1b,%ecx
  801afb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801afe:	83 e2 1f             	and    $0x1f,%edx
  801b01:	29 ca                	sub    %ecx,%edx
  801b03:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b07:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b0b:	83 c0 01             	add    $0x1,%eax
  801b0e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b11:	83 c7 01             	add    $0x1,%edi
  801b14:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b17:	75 c2                	jne    801adb <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b19:	8b 45 10             	mov    0x10(%ebp),%eax
  801b1c:	eb 05                	jmp    801b23 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b1e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b26:	5b                   	pop    %ebx
  801b27:	5e                   	pop    %esi
  801b28:	5f                   	pop    %edi
  801b29:	5d                   	pop    %ebp
  801b2a:	c3                   	ret    

00801b2b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	57                   	push   %edi
  801b2f:	56                   	push   %esi
  801b30:	53                   	push   %ebx
  801b31:	83 ec 18             	sub    $0x18,%esp
  801b34:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b37:	57                   	push   %edi
  801b38:	e8 8f f6 ff ff       	call   8011cc <fd2data>
  801b3d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b3f:	83 c4 10             	add    $0x10,%esp
  801b42:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b47:	eb 3d                	jmp    801b86 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b49:	85 db                	test   %ebx,%ebx
  801b4b:	74 04                	je     801b51 <devpipe_read+0x26>
				return i;
  801b4d:	89 d8                	mov    %ebx,%eax
  801b4f:	eb 44                	jmp    801b95 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b51:	89 f2                	mov    %esi,%edx
  801b53:	89 f8                	mov    %edi,%eax
  801b55:	e8 e5 fe ff ff       	call   801a3f <_pipeisclosed>
  801b5a:	85 c0                	test   %eax,%eax
  801b5c:	75 32                	jne    801b90 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b5e:	e8 7f f0 ff ff       	call   800be2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b63:	8b 06                	mov    (%esi),%eax
  801b65:	3b 46 04             	cmp    0x4(%esi),%eax
  801b68:	74 df                	je     801b49 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b6a:	99                   	cltd   
  801b6b:	c1 ea 1b             	shr    $0x1b,%edx
  801b6e:	01 d0                	add    %edx,%eax
  801b70:	83 e0 1f             	and    $0x1f,%eax
  801b73:	29 d0                	sub    %edx,%eax
  801b75:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b7d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b80:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b83:	83 c3 01             	add    $0x1,%ebx
  801b86:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b89:	75 d8                	jne    801b63 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b8b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b8e:	eb 05                	jmp    801b95 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b90:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b98:	5b                   	pop    %ebx
  801b99:	5e                   	pop    %esi
  801b9a:	5f                   	pop    %edi
  801b9b:	5d                   	pop    %ebp
  801b9c:	c3                   	ret    

00801b9d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b9d:	55                   	push   %ebp
  801b9e:	89 e5                	mov    %esp,%ebp
  801ba0:	56                   	push   %esi
  801ba1:	53                   	push   %ebx
  801ba2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ba5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba8:	50                   	push   %eax
  801ba9:	e8 35 f6 ff ff       	call   8011e3 <fd_alloc>
  801bae:	83 c4 10             	add    $0x10,%esp
  801bb1:	89 c2                	mov    %eax,%edx
  801bb3:	85 c0                	test   %eax,%eax
  801bb5:	0f 88 2c 01 00 00    	js     801ce7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bbb:	83 ec 04             	sub    $0x4,%esp
  801bbe:	68 07 04 00 00       	push   $0x407
  801bc3:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc6:	6a 00                	push   $0x0
  801bc8:	e8 34 f0 ff ff       	call   800c01 <sys_page_alloc>
  801bcd:	83 c4 10             	add    $0x10,%esp
  801bd0:	89 c2                	mov    %eax,%edx
  801bd2:	85 c0                	test   %eax,%eax
  801bd4:	0f 88 0d 01 00 00    	js     801ce7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bda:	83 ec 0c             	sub    $0xc,%esp
  801bdd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801be0:	50                   	push   %eax
  801be1:	e8 fd f5 ff ff       	call   8011e3 <fd_alloc>
  801be6:	89 c3                	mov    %eax,%ebx
  801be8:	83 c4 10             	add    $0x10,%esp
  801beb:	85 c0                	test   %eax,%eax
  801bed:	0f 88 e2 00 00 00    	js     801cd5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf3:	83 ec 04             	sub    $0x4,%esp
  801bf6:	68 07 04 00 00       	push   $0x407
  801bfb:	ff 75 f0             	pushl  -0x10(%ebp)
  801bfe:	6a 00                	push   $0x0
  801c00:	e8 fc ef ff ff       	call   800c01 <sys_page_alloc>
  801c05:	89 c3                	mov    %eax,%ebx
  801c07:	83 c4 10             	add    $0x10,%esp
  801c0a:	85 c0                	test   %eax,%eax
  801c0c:	0f 88 c3 00 00 00    	js     801cd5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c12:	83 ec 0c             	sub    $0xc,%esp
  801c15:	ff 75 f4             	pushl  -0xc(%ebp)
  801c18:	e8 af f5 ff ff       	call   8011cc <fd2data>
  801c1d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c1f:	83 c4 0c             	add    $0xc,%esp
  801c22:	68 07 04 00 00       	push   $0x407
  801c27:	50                   	push   %eax
  801c28:	6a 00                	push   $0x0
  801c2a:	e8 d2 ef ff ff       	call   800c01 <sys_page_alloc>
  801c2f:	89 c3                	mov    %eax,%ebx
  801c31:	83 c4 10             	add    $0x10,%esp
  801c34:	85 c0                	test   %eax,%eax
  801c36:	0f 88 89 00 00 00    	js     801cc5 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c3c:	83 ec 0c             	sub    $0xc,%esp
  801c3f:	ff 75 f0             	pushl  -0x10(%ebp)
  801c42:	e8 85 f5 ff ff       	call   8011cc <fd2data>
  801c47:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c4e:	50                   	push   %eax
  801c4f:	6a 00                	push   $0x0
  801c51:	56                   	push   %esi
  801c52:	6a 00                	push   $0x0
  801c54:	e8 eb ef ff ff       	call   800c44 <sys_page_map>
  801c59:	89 c3                	mov    %eax,%ebx
  801c5b:	83 c4 20             	add    $0x20,%esp
  801c5e:	85 c0                	test   %eax,%eax
  801c60:	78 55                	js     801cb7 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c62:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c70:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c77:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c80:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c85:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c8c:	83 ec 0c             	sub    $0xc,%esp
  801c8f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c92:	e8 25 f5 ff ff       	call   8011bc <fd2num>
  801c97:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c9a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c9c:	83 c4 04             	add    $0x4,%esp
  801c9f:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca2:	e8 15 f5 ff ff       	call   8011bc <fd2num>
  801ca7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801caa:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801cad:	83 c4 10             	add    $0x10,%esp
  801cb0:	ba 00 00 00 00       	mov    $0x0,%edx
  801cb5:	eb 30                	jmp    801ce7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cb7:	83 ec 08             	sub    $0x8,%esp
  801cba:	56                   	push   %esi
  801cbb:	6a 00                	push   $0x0
  801cbd:	e8 c4 ef ff ff       	call   800c86 <sys_page_unmap>
  801cc2:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cc5:	83 ec 08             	sub    $0x8,%esp
  801cc8:	ff 75 f0             	pushl  -0x10(%ebp)
  801ccb:	6a 00                	push   $0x0
  801ccd:	e8 b4 ef ff ff       	call   800c86 <sys_page_unmap>
  801cd2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cd5:	83 ec 08             	sub    $0x8,%esp
  801cd8:	ff 75 f4             	pushl  -0xc(%ebp)
  801cdb:	6a 00                	push   $0x0
  801cdd:	e8 a4 ef ff ff       	call   800c86 <sys_page_unmap>
  801ce2:	83 c4 10             	add    $0x10,%esp
  801ce5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ce7:	89 d0                	mov    %edx,%eax
  801ce9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cec:	5b                   	pop    %ebx
  801ced:	5e                   	pop    %esi
  801cee:	5d                   	pop    %ebp
  801cef:	c3                   	ret    

00801cf0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cf0:	55                   	push   %ebp
  801cf1:	89 e5                	mov    %esp,%ebp
  801cf3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cf6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cf9:	50                   	push   %eax
  801cfa:	ff 75 08             	pushl  0x8(%ebp)
  801cfd:	e8 30 f5 ff ff       	call   801232 <fd_lookup>
  801d02:	83 c4 10             	add    $0x10,%esp
  801d05:	85 c0                	test   %eax,%eax
  801d07:	78 18                	js     801d21 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d09:	83 ec 0c             	sub    $0xc,%esp
  801d0c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d0f:	e8 b8 f4 ff ff       	call   8011cc <fd2data>
	return _pipeisclosed(fd, p);
  801d14:	89 c2                	mov    %eax,%edx
  801d16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d19:	e8 21 fd ff ff       	call   801a3f <_pipeisclosed>
  801d1e:	83 c4 10             	add    $0x10,%esp
}
  801d21:	c9                   	leave  
  801d22:	c3                   	ret    

00801d23 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d23:	55                   	push   %ebp
  801d24:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d26:	b8 00 00 00 00       	mov    $0x0,%eax
  801d2b:	5d                   	pop    %ebp
  801d2c:	c3                   	ret    

00801d2d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d2d:	55                   	push   %ebp
  801d2e:	89 e5                	mov    %esp,%ebp
  801d30:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d33:	68 f2 26 80 00       	push   $0x8026f2
  801d38:	ff 75 0c             	pushl  0xc(%ebp)
  801d3b:	e8 be ea ff ff       	call   8007fe <strcpy>
	return 0;
}
  801d40:	b8 00 00 00 00       	mov    $0x0,%eax
  801d45:	c9                   	leave  
  801d46:	c3                   	ret    

00801d47 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d47:	55                   	push   %ebp
  801d48:	89 e5                	mov    %esp,%ebp
  801d4a:	57                   	push   %edi
  801d4b:	56                   	push   %esi
  801d4c:	53                   	push   %ebx
  801d4d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d53:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d58:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d5e:	eb 2d                	jmp    801d8d <devcons_write+0x46>
		m = n - tot;
  801d60:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d63:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d65:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d68:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d6d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d70:	83 ec 04             	sub    $0x4,%esp
  801d73:	53                   	push   %ebx
  801d74:	03 45 0c             	add    0xc(%ebp),%eax
  801d77:	50                   	push   %eax
  801d78:	57                   	push   %edi
  801d79:	e8 12 ec ff ff       	call   800990 <memmove>
		sys_cputs(buf, m);
  801d7e:	83 c4 08             	add    $0x8,%esp
  801d81:	53                   	push   %ebx
  801d82:	57                   	push   %edi
  801d83:	e8 bd ed ff ff       	call   800b45 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d88:	01 de                	add    %ebx,%esi
  801d8a:	83 c4 10             	add    $0x10,%esp
  801d8d:	89 f0                	mov    %esi,%eax
  801d8f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d92:	72 cc                	jb     801d60 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d97:	5b                   	pop    %ebx
  801d98:	5e                   	pop    %esi
  801d99:	5f                   	pop    %edi
  801d9a:	5d                   	pop    %ebp
  801d9b:	c3                   	ret    

00801d9c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d9c:	55                   	push   %ebp
  801d9d:	89 e5                	mov    %esp,%ebp
  801d9f:	83 ec 08             	sub    $0x8,%esp
  801da2:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801da7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dab:	74 2a                	je     801dd7 <devcons_read+0x3b>
  801dad:	eb 05                	jmp    801db4 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801daf:	e8 2e ee ff ff       	call   800be2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801db4:	e8 aa ed ff ff       	call   800b63 <sys_cgetc>
  801db9:	85 c0                	test   %eax,%eax
  801dbb:	74 f2                	je     801daf <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801dbd:	85 c0                	test   %eax,%eax
  801dbf:	78 16                	js     801dd7 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dc1:	83 f8 04             	cmp    $0x4,%eax
  801dc4:	74 0c                	je     801dd2 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801dc6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dc9:	88 02                	mov    %al,(%edx)
	return 1;
  801dcb:	b8 01 00 00 00       	mov    $0x1,%eax
  801dd0:	eb 05                	jmp    801dd7 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dd2:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801dd7:	c9                   	leave  
  801dd8:	c3                   	ret    

00801dd9 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801dd9:	55                   	push   %ebp
  801dda:	89 e5                	mov    %esp,%ebp
  801ddc:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ddf:	8b 45 08             	mov    0x8(%ebp),%eax
  801de2:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801de5:	6a 01                	push   $0x1
  801de7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dea:	50                   	push   %eax
  801deb:	e8 55 ed ff ff       	call   800b45 <sys_cputs>
}
  801df0:	83 c4 10             	add    $0x10,%esp
  801df3:	c9                   	leave  
  801df4:	c3                   	ret    

00801df5 <getchar>:

int
getchar(void)
{
  801df5:	55                   	push   %ebp
  801df6:	89 e5                	mov    %esp,%ebp
  801df8:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dfb:	6a 01                	push   $0x1
  801dfd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e00:	50                   	push   %eax
  801e01:	6a 00                	push   $0x0
  801e03:	e8 90 f6 ff ff       	call   801498 <read>
	if (r < 0)
  801e08:	83 c4 10             	add    $0x10,%esp
  801e0b:	85 c0                	test   %eax,%eax
  801e0d:	78 0f                	js     801e1e <getchar+0x29>
		return r;
	if (r < 1)
  801e0f:	85 c0                	test   %eax,%eax
  801e11:	7e 06                	jle    801e19 <getchar+0x24>
		return -E_EOF;
	return c;
  801e13:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e17:	eb 05                	jmp    801e1e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e19:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e1e:	c9                   	leave  
  801e1f:	c3                   	ret    

00801e20 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e20:	55                   	push   %ebp
  801e21:	89 e5                	mov    %esp,%ebp
  801e23:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e26:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e29:	50                   	push   %eax
  801e2a:	ff 75 08             	pushl  0x8(%ebp)
  801e2d:	e8 00 f4 ff ff       	call   801232 <fd_lookup>
  801e32:	83 c4 10             	add    $0x10,%esp
  801e35:	85 c0                	test   %eax,%eax
  801e37:	78 11                	js     801e4a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e42:	39 10                	cmp    %edx,(%eax)
  801e44:	0f 94 c0             	sete   %al
  801e47:	0f b6 c0             	movzbl %al,%eax
}
  801e4a:	c9                   	leave  
  801e4b:	c3                   	ret    

00801e4c <opencons>:

int
opencons(void)
{
  801e4c:	55                   	push   %ebp
  801e4d:	89 e5                	mov    %esp,%ebp
  801e4f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e55:	50                   	push   %eax
  801e56:	e8 88 f3 ff ff       	call   8011e3 <fd_alloc>
  801e5b:	83 c4 10             	add    $0x10,%esp
		return r;
  801e5e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e60:	85 c0                	test   %eax,%eax
  801e62:	78 3e                	js     801ea2 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e64:	83 ec 04             	sub    $0x4,%esp
  801e67:	68 07 04 00 00       	push   $0x407
  801e6c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e6f:	6a 00                	push   $0x0
  801e71:	e8 8b ed ff ff       	call   800c01 <sys_page_alloc>
  801e76:	83 c4 10             	add    $0x10,%esp
		return r;
  801e79:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e7b:	85 c0                	test   %eax,%eax
  801e7d:	78 23                	js     801ea2 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e7f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e88:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e94:	83 ec 0c             	sub    $0xc,%esp
  801e97:	50                   	push   %eax
  801e98:	e8 1f f3 ff ff       	call   8011bc <fd2num>
  801e9d:	89 c2                	mov    %eax,%edx
  801e9f:	83 c4 10             	add    $0x10,%esp
}
  801ea2:	89 d0                	mov    %edx,%eax
  801ea4:	c9                   	leave  
  801ea5:	c3                   	ret    

00801ea6 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ea6:	55                   	push   %ebp
  801ea7:	89 e5                	mov    %esp,%ebp
  801ea9:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801eac:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801eb3:	75 2a                	jne    801edf <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801eb5:	83 ec 04             	sub    $0x4,%esp
  801eb8:	6a 07                	push   $0x7
  801eba:	68 00 f0 bf ee       	push   $0xeebff000
  801ebf:	6a 00                	push   $0x0
  801ec1:	e8 3b ed ff ff       	call   800c01 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801ec6:	83 c4 10             	add    $0x10,%esp
  801ec9:	85 c0                	test   %eax,%eax
  801ecb:	79 12                	jns    801edf <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801ecd:	50                   	push   %eax
  801ece:	68 fe 26 80 00       	push   $0x8026fe
  801ed3:	6a 23                	push   $0x23
  801ed5:	68 02 27 80 00       	push   $0x802702
  801eda:	e8 c1 e2 ff ff       	call   8001a0 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801edf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee2:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801ee7:	83 ec 08             	sub    $0x8,%esp
  801eea:	68 11 1f 80 00       	push   $0x801f11
  801eef:	6a 00                	push   $0x0
  801ef1:	e8 56 ee ff ff       	call   800d4c <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801ef6:	83 c4 10             	add    $0x10,%esp
  801ef9:	85 c0                	test   %eax,%eax
  801efb:	79 12                	jns    801f0f <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801efd:	50                   	push   %eax
  801efe:	68 fe 26 80 00       	push   $0x8026fe
  801f03:	6a 2c                	push   $0x2c
  801f05:	68 02 27 80 00       	push   $0x802702
  801f0a:	e8 91 e2 ff ff       	call   8001a0 <_panic>
	}
}
  801f0f:	c9                   	leave  
  801f10:	c3                   	ret    

00801f11 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f11:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f12:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f17:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f19:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801f1c:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801f20:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801f25:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801f29:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801f2b:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801f2e:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801f2f:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801f32:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801f33:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f34:	c3                   	ret    

00801f35 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f35:	55                   	push   %ebp
  801f36:	89 e5                	mov    %esp,%ebp
  801f38:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f3b:	89 d0                	mov    %edx,%eax
  801f3d:	c1 e8 16             	shr    $0x16,%eax
  801f40:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f47:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f4c:	f6 c1 01             	test   $0x1,%cl
  801f4f:	74 1d                	je     801f6e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f51:	c1 ea 0c             	shr    $0xc,%edx
  801f54:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f5b:	f6 c2 01             	test   $0x1,%dl
  801f5e:	74 0e                	je     801f6e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f60:	c1 ea 0c             	shr    $0xc,%edx
  801f63:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f6a:	ef 
  801f6b:	0f b7 c0             	movzwl %ax,%eax
}
  801f6e:	5d                   	pop    %ebp
  801f6f:	c3                   	ret    

00801f70 <__udivdi3>:
  801f70:	55                   	push   %ebp
  801f71:	57                   	push   %edi
  801f72:	56                   	push   %esi
  801f73:	53                   	push   %ebx
  801f74:	83 ec 1c             	sub    $0x1c,%esp
  801f77:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f7b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f7f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f87:	85 f6                	test   %esi,%esi
  801f89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f8d:	89 ca                	mov    %ecx,%edx
  801f8f:	89 f8                	mov    %edi,%eax
  801f91:	75 3d                	jne    801fd0 <__udivdi3+0x60>
  801f93:	39 cf                	cmp    %ecx,%edi
  801f95:	0f 87 c5 00 00 00    	ja     802060 <__udivdi3+0xf0>
  801f9b:	85 ff                	test   %edi,%edi
  801f9d:	89 fd                	mov    %edi,%ebp
  801f9f:	75 0b                	jne    801fac <__udivdi3+0x3c>
  801fa1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fa6:	31 d2                	xor    %edx,%edx
  801fa8:	f7 f7                	div    %edi
  801faa:	89 c5                	mov    %eax,%ebp
  801fac:	89 c8                	mov    %ecx,%eax
  801fae:	31 d2                	xor    %edx,%edx
  801fb0:	f7 f5                	div    %ebp
  801fb2:	89 c1                	mov    %eax,%ecx
  801fb4:	89 d8                	mov    %ebx,%eax
  801fb6:	89 cf                	mov    %ecx,%edi
  801fb8:	f7 f5                	div    %ebp
  801fba:	89 c3                	mov    %eax,%ebx
  801fbc:	89 d8                	mov    %ebx,%eax
  801fbe:	89 fa                	mov    %edi,%edx
  801fc0:	83 c4 1c             	add    $0x1c,%esp
  801fc3:	5b                   	pop    %ebx
  801fc4:	5e                   	pop    %esi
  801fc5:	5f                   	pop    %edi
  801fc6:	5d                   	pop    %ebp
  801fc7:	c3                   	ret    
  801fc8:	90                   	nop
  801fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fd0:	39 ce                	cmp    %ecx,%esi
  801fd2:	77 74                	ja     802048 <__udivdi3+0xd8>
  801fd4:	0f bd fe             	bsr    %esi,%edi
  801fd7:	83 f7 1f             	xor    $0x1f,%edi
  801fda:	0f 84 98 00 00 00    	je     802078 <__udivdi3+0x108>
  801fe0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fe5:	89 f9                	mov    %edi,%ecx
  801fe7:	89 c5                	mov    %eax,%ebp
  801fe9:	29 fb                	sub    %edi,%ebx
  801feb:	d3 e6                	shl    %cl,%esi
  801fed:	89 d9                	mov    %ebx,%ecx
  801fef:	d3 ed                	shr    %cl,%ebp
  801ff1:	89 f9                	mov    %edi,%ecx
  801ff3:	d3 e0                	shl    %cl,%eax
  801ff5:	09 ee                	or     %ebp,%esi
  801ff7:	89 d9                	mov    %ebx,%ecx
  801ff9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ffd:	89 d5                	mov    %edx,%ebp
  801fff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802003:	d3 ed                	shr    %cl,%ebp
  802005:	89 f9                	mov    %edi,%ecx
  802007:	d3 e2                	shl    %cl,%edx
  802009:	89 d9                	mov    %ebx,%ecx
  80200b:	d3 e8                	shr    %cl,%eax
  80200d:	09 c2                	or     %eax,%edx
  80200f:	89 d0                	mov    %edx,%eax
  802011:	89 ea                	mov    %ebp,%edx
  802013:	f7 f6                	div    %esi
  802015:	89 d5                	mov    %edx,%ebp
  802017:	89 c3                	mov    %eax,%ebx
  802019:	f7 64 24 0c          	mull   0xc(%esp)
  80201d:	39 d5                	cmp    %edx,%ebp
  80201f:	72 10                	jb     802031 <__udivdi3+0xc1>
  802021:	8b 74 24 08          	mov    0x8(%esp),%esi
  802025:	89 f9                	mov    %edi,%ecx
  802027:	d3 e6                	shl    %cl,%esi
  802029:	39 c6                	cmp    %eax,%esi
  80202b:	73 07                	jae    802034 <__udivdi3+0xc4>
  80202d:	39 d5                	cmp    %edx,%ebp
  80202f:	75 03                	jne    802034 <__udivdi3+0xc4>
  802031:	83 eb 01             	sub    $0x1,%ebx
  802034:	31 ff                	xor    %edi,%edi
  802036:	89 d8                	mov    %ebx,%eax
  802038:	89 fa                	mov    %edi,%edx
  80203a:	83 c4 1c             	add    $0x1c,%esp
  80203d:	5b                   	pop    %ebx
  80203e:	5e                   	pop    %esi
  80203f:	5f                   	pop    %edi
  802040:	5d                   	pop    %ebp
  802041:	c3                   	ret    
  802042:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802048:	31 ff                	xor    %edi,%edi
  80204a:	31 db                	xor    %ebx,%ebx
  80204c:	89 d8                	mov    %ebx,%eax
  80204e:	89 fa                	mov    %edi,%edx
  802050:	83 c4 1c             	add    $0x1c,%esp
  802053:	5b                   	pop    %ebx
  802054:	5e                   	pop    %esi
  802055:	5f                   	pop    %edi
  802056:	5d                   	pop    %ebp
  802057:	c3                   	ret    
  802058:	90                   	nop
  802059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802060:	89 d8                	mov    %ebx,%eax
  802062:	f7 f7                	div    %edi
  802064:	31 ff                	xor    %edi,%edi
  802066:	89 c3                	mov    %eax,%ebx
  802068:	89 d8                	mov    %ebx,%eax
  80206a:	89 fa                	mov    %edi,%edx
  80206c:	83 c4 1c             	add    $0x1c,%esp
  80206f:	5b                   	pop    %ebx
  802070:	5e                   	pop    %esi
  802071:	5f                   	pop    %edi
  802072:	5d                   	pop    %ebp
  802073:	c3                   	ret    
  802074:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802078:	39 ce                	cmp    %ecx,%esi
  80207a:	72 0c                	jb     802088 <__udivdi3+0x118>
  80207c:	31 db                	xor    %ebx,%ebx
  80207e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802082:	0f 87 34 ff ff ff    	ja     801fbc <__udivdi3+0x4c>
  802088:	bb 01 00 00 00       	mov    $0x1,%ebx
  80208d:	e9 2a ff ff ff       	jmp    801fbc <__udivdi3+0x4c>
  802092:	66 90                	xchg   %ax,%ax
  802094:	66 90                	xchg   %ax,%ax
  802096:	66 90                	xchg   %ax,%ax
  802098:	66 90                	xchg   %ax,%ax
  80209a:	66 90                	xchg   %ax,%ax
  80209c:	66 90                	xchg   %ax,%ax
  80209e:	66 90                	xchg   %ax,%ax

008020a0 <__umoddi3>:
  8020a0:	55                   	push   %ebp
  8020a1:	57                   	push   %edi
  8020a2:	56                   	push   %esi
  8020a3:	53                   	push   %ebx
  8020a4:	83 ec 1c             	sub    $0x1c,%esp
  8020a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020b7:	85 d2                	test   %edx,%edx
  8020b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020c1:	89 f3                	mov    %esi,%ebx
  8020c3:	89 3c 24             	mov    %edi,(%esp)
  8020c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ca:	75 1c                	jne    8020e8 <__umoddi3+0x48>
  8020cc:	39 f7                	cmp    %esi,%edi
  8020ce:	76 50                	jbe    802120 <__umoddi3+0x80>
  8020d0:	89 c8                	mov    %ecx,%eax
  8020d2:	89 f2                	mov    %esi,%edx
  8020d4:	f7 f7                	div    %edi
  8020d6:	89 d0                	mov    %edx,%eax
  8020d8:	31 d2                	xor    %edx,%edx
  8020da:	83 c4 1c             	add    $0x1c,%esp
  8020dd:	5b                   	pop    %ebx
  8020de:	5e                   	pop    %esi
  8020df:	5f                   	pop    %edi
  8020e0:	5d                   	pop    %ebp
  8020e1:	c3                   	ret    
  8020e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020e8:	39 f2                	cmp    %esi,%edx
  8020ea:	89 d0                	mov    %edx,%eax
  8020ec:	77 52                	ja     802140 <__umoddi3+0xa0>
  8020ee:	0f bd ea             	bsr    %edx,%ebp
  8020f1:	83 f5 1f             	xor    $0x1f,%ebp
  8020f4:	75 5a                	jne    802150 <__umoddi3+0xb0>
  8020f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020fa:	0f 82 e0 00 00 00    	jb     8021e0 <__umoddi3+0x140>
  802100:	39 0c 24             	cmp    %ecx,(%esp)
  802103:	0f 86 d7 00 00 00    	jbe    8021e0 <__umoddi3+0x140>
  802109:	8b 44 24 08          	mov    0x8(%esp),%eax
  80210d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802111:	83 c4 1c             	add    $0x1c,%esp
  802114:	5b                   	pop    %ebx
  802115:	5e                   	pop    %esi
  802116:	5f                   	pop    %edi
  802117:	5d                   	pop    %ebp
  802118:	c3                   	ret    
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	85 ff                	test   %edi,%edi
  802122:	89 fd                	mov    %edi,%ebp
  802124:	75 0b                	jne    802131 <__umoddi3+0x91>
  802126:	b8 01 00 00 00       	mov    $0x1,%eax
  80212b:	31 d2                	xor    %edx,%edx
  80212d:	f7 f7                	div    %edi
  80212f:	89 c5                	mov    %eax,%ebp
  802131:	89 f0                	mov    %esi,%eax
  802133:	31 d2                	xor    %edx,%edx
  802135:	f7 f5                	div    %ebp
  802137:	89 c8                	mov    %ecx,%eax
  802139:	f7 f5                	div    %ebp
  80213b:	89 d0                	mov    %edx,%eax
  80213d:	eb 99                	jmp    8020d8 <__umoddi3+0x38>
  80213f:	90                   	nop
  802140:	89 c8                	mov    %ecx,%eax
  802142:	89 f2                	mov    %esi,%edx
  802144:	83 c4 1c             	add    $0x1c,%esp
  802147:	5b                   	pop    %ebx
  802148:	5e                   	pop    %esi
  802149:	5f                   	pop    %edi
  80214a:	5d                   	pop    %ebp
  80214b:	c3                   	ret    
  80214c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802150:	8b 34 24             	mov    (%esp),%esi
  802153:	bf 20 00 00 00       	mov    $0x20,%edi
  802158:	89 e9                	mov    %ebp,%ecx
  80215a:	29 ef                	sub    %ebp,%edi
  80215c:	d3 e0                	shl    %cl,%eax
  80215e:	89 f9                	mov    %edi,%ecx
  802160:	89 f2                	mov    %esi,%edx
  802162:	d3 ea                	shr    %cl,%edx
  802164:	89 e9                	mov    %ebp,%ecx
  802166:	09 c2                	or     %eax,%edx
  802168:	89 d8                	mov    %ebx,%eax
  80216a:	89 14 24             	mov    %edx,(%esp)
  80216d:	89 f2                	mov    %esi,%edx
  80216f:	d3 e2                	shl    %cl,%edx
  802171:	89 f9                	mov    %edi,%ecx
  802173:	89 54 24 04          	mov    %edx,0x4(%esp)
  802177:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80217b:	d3 e8                	shr    %cl,%eax
  80217d:	89 e9                	mov    %ebp,%ecx
  80217f:	89 c6                	mov    %eax,%esi
  802181:	d3 e3                	shl    %cl,%ebx
  802183:	89 f9                	mov    %edi,%ecx
  802185:	89 d0                	mov    %edx,%eax
  802187:	d3 e8                	shr    %cl,%eax
  802189:	89 e9                	mov    %ebp,%ecx
  80218b:	09 d8                	or     %ebx,%eax
  80218d:	89 d3                	mov    %edx,%ebx
  80218f:	89 f2                	mov    %esi,%edx
  802191:	f7 34 24             	divl   (%esp)
  802194:	89 d6                	mov    %edx,%esi
  802196:	d3 e3                	shl    %cl,%ebx
  802198:	f7 64 24 04          	mull   0x4(%esp)
  80219c:	39 d6                	cmp    %edx,%esi
  80219e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021a2:	89 d1                	mov    %edx,%ecx
  8021a4:	89 c3                	mov    %eax,%ebx
  8021a6:	72 08                	jb     8021b0 <__umoddi3+0x110>
  8021a8:	75 11                	jne    8021bb <__umoddi3+0x11b>
  8021aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021ae:	73 0b                	jae    8021bb <__umoddi3+0x11b>
  8021b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021b4:	1b 14 24             	sbb    (%esp),%edx
  8021b7:	89 d1                	mov    %edx,%ecx
  8021b9:	89 c3                	mov    %eax,%ebx
  8021bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021bf:	29 da                	sub    %ebx,%edx
  8021c1:	19 ce                	sbb    %ecx,%esi
  8021c3:	89 f9                	mov    %edi,%ecx
  8021c5:	89 f0                	mov    %esi,%eax
  8021c7:	d3 e0                	shl    %cl,%eax
  8021c9:	89 e9                	mov    %ebp,%ecx
  8021cb:	d3 ea                	shr    %cl,%edx
  8021cd:	89 e9                	mov    %ebp,%ecx
  8021cf:	d3 ee                	shr    %cl,%esi
  8021d1:	09 d0                	or     %edx,%eax
  8021d3:	89 f2                	mov    %esi,%edx
  8021d5:	83 c4 1c             	add    $0x1c,%esp
  8021d8:	5b                   	pop    %ebx
  8021d9:	5e                   	pop    %esi
  8021da:	5f                   	pop    %edi
  8021db:	5d                   	pop    %ebp
  8021dc:	c3                   	ret    
  8021dd:	8d 76 00             	lea    0x0(%esi),%esi
  8021e0:	29 f9                	sub    %edi,%ecx
  8021e2:	19 d6                	sbb    %edx,%esi
  8021e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021ec:	e9 18 ff ff ff       	jmp    802109 <__umoddi3+0x69>
