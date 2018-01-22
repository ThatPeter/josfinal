
obj/user/stresssched.debug:     file format elf32-i386


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
  80002c:	e8 c0 00 00 00       	call   8000f1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 97 0b 00 00       	call   800bd4 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 b0 0e 00 00       	call   800ef9 <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0a                	je     800057 <umain+0x24>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
  800055:	eb 05                	jmp    80005c <umain+0x29>
		if (fork() == 0)
			break;
	if (i == 20) {
  800057:	83 fb 14             	cmp    $0x14,%ebx
  80005a:	75 0e                	jne    80006a <umain+0x37>
		sys_yield();
  80005c:	e8 92 0b 00 00       	call   800bf3 <sys_yield>
		return;
  800061:	e9 84 00 00 00       	jmp    8000ea <umain+0xb7>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800066:	f3 90                	pause  
  800068:	eb 13                	jmp    80007d <umain+0x4a>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006a:	89 f0                	mov    %esi,%eax
  80006c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800071:	89 c2                	mov    %eax,%edx
  800073:	c1 e2 07             	shl    $0x7,%edx
  800076:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  80007d:	8b 42 5c             	mov    0x5c(%edx),%eax
  800080:	85 c0                	test   %eax,%eax
  800082:	75 e2                	jne    800066 <umain+0x33>
  800084:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800089:	e8 65 0b 00 00       	call   800bf3 <sys_yield>
  80008e:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  800093:	a1 04 40 80 00       	mov    0x804004,%eax
  800098:	83 c0 01             	add    $0x1,%eax
  80009b:	a3 04 40 80 00       	mov    %eax,0x804004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000a0:	83 ea 01             	sub    $0x1,%edx
  8000a3:	75 ee                	jne    800093 <umain+0x60>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000a5:	83 eb 01             	sub    $0x1,%ebx
  8000a8:	75 df                	jne    800089 <umain+0x56>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000aa:	a1 04 40 80 00       	mov    0x804004,%eax
  8000af:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b4:	74 17                	je     8000cd <umain+0x9a>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000b6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000bb:	50                   	push   %eax
  8000bc:	68 80 22 80 00       	push   $0x802280
  8000c1:	6a 21                	push   $0x21
  8000c3:	68 a8 22 80 00       	push   $0x8022a8
  8000c8:	e8 e4 00 00 00       	call   8001b1 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000cd:	a1 08 40 80 00       	mov    0x804008,%eax
  8000d2:	8b 50 64             	mov    0x64(%eax),%edx
  8000d5:	8b 40 50             	mov    0x50(%eax),%eax
  8000d8:	83 ec 04             	sub    $0x4,%esp
  8000db:	52                   	push   %edx
  8000dc:	50                   	push   %eax
  8000dd:	68 bb 22 80 00       	push   $0x8022bb
  8000e2:	e8 a3 01 00 00       	call   80028a <cprintf>
  8000e7:	83 c4 10             	add    $0x10,%esp

}
  8000ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ed:	5b                   	pop    %ebx
  8000ee:	5e                   	pop    %esi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	57                   	push   %edi
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000fa:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  800101:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  800104:	e8 cb 0a 00 00       	call   800bd4 <sys_getenvid>
  800109:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  80010b:	83 ec 08             	sub    $0x8,%esp
  80010e:	50                   	push   %eax
  80010f:	68 dc 22 80 00       	push   $0x8022dc
  800114:	e8 71 01 00 00       	call   80028a <cprintf>
  800119:	8b 3d 08 40 80 00    	mov    0x804008,%edi
  80011f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800124:	83 c4 10             	add    $0x10,%esp
  800127:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  80012c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  800131:	89 c1                	mov    %eax,%ecx
  800133:	c1 e1 07             	shl    $0x7,%ecx
  800136:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  80013d:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  800140:	39 cb                	cmp    %ecx,%ebx
  800142:	0f 44 fa             	cmove  %edx,%edi
  800145:	b9 01 00 00 00       	mov    $0x1,%ecx
  80014a:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  80014d:	83 c0 01             	add    $0x1,%eax
  800150:	81 c2 84 00 00 00    	add    $0x84,%edx
  800156:	3d 00 04 00 00       	cmp    $0x400,%eax
  80015b:	75 d4                	jne    800131 <libmain+0x40>
  80015d:	89 f0                	mov    %esi,%eax
  80015f:	84 c0                	test   %al,%al
  800161:	74 06                	je     800169 <libmain+0x78>
  800163:	89 3d 08 40 80 00    	mov    %edi,0x804008
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800169:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80016d:	7e 0a                	jle    800179 <libmain+0x88>
		binaryname = argv[0];
  80016f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800172:	8b 00                	mov    (%eax),%eax
  800174:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800179:	83 ec 08             	sub    $0x8,%esp
  80017c:	ff 75 0c             	pushl  0xc(%ebp)
  80017f:	ff 75 08             	pushl  0x8(%ebp)
  800182:	e8 ac fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800187:	e8 0b 00 00 00       	call   800197 <exit>
}
  80018c:	83 c4 10             	add    $0x10,%esp
  80018f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800192:	5b                   	pop    %ebx
  800193:	5e                   	pop    %esi
  800194:	5f                   	pop    %edi
  800195:	5d                   	pop    %ebp
  800196:	c3                   	ret    

00800197 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80019d:	e8 34 11 00 00       	call   8012d6 <close_all>
	sys_env_destroy(0);
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	6a 00                	push   $0x0
  8001a7:	e8 e7 09 00 00       	call   800b93 <sys_env_destroy>
}
  8001ac:	83 c4 10             	add    $0x10,%esp
  8001af:	c9                   	leave  
  8001b0:	c3                   	ret    

008001b1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001b6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001b9:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001bf:	e8 10 0a 00 00       	call   800bd4 <sys_getenvid>
  8001c4:	83 ec 0c             	sub    $0xc,%esp
  8001c7:	ff 75 0c             	pushl  0xc(%ebp)
  8001ca:	ff 75 08             	pushl  0x8(%ebp)
  8001cd:	56                   	push   %esi
  8001ce:	50                   	push   %eax
  8001cf:	68 08 23 80 00       	push   $0x802308
  8001d4:	e8 b1 00 00 00       	call   80028a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001d9:	83 c4 18             	add    $0x18,%esp
  8001dc:	53                   	push   %ebx
  8001dd:	ff 75 10             	pushl  0x10(%ebp)
  8001e0:	e8 54 00 00 00       	call   800239 <vcprintf>
	cprintf("\n");
  8001e5:	c7 04 24 d7 22 80 00 	movl   $0x8022d7,(%esp)
  8001ec:	e8 99 00 00 00       	call   80028a <cprintf>
  8001f1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001f4:	cc                   	int3   
  8001f5:	eb fd                	jmp    8001f4 <_panic+0x43>

008001f7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	53                   	push   %ebx
  8001fb:	83 ec 04             	sub    $0x4,%esp
  8001fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800201:	8b 13                	mov    (%ebx),%edx
  800203:	8d 42 01             	lea    0x1(%edx),%eax
  800206:	89 03                	mov    %eax,(%ebx)
  800208:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80020f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800214:	75 1a                	jne    800230 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800216:	83 ec 08             	sub    $0x8,%esp
  800219:	68 ff 00 00 00       	push   $0xff
  80021e:	8d 43 08             	lea    0x8(%ebx),%eax
  800221:	50                   	push   %eax
  800222:	e8 2f 09 00 00       	call   800b56 <sys_cputs>
		b->idx = 0;
  800227:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80022d:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800230:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800234:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800237:	c9                   	leave  
  800238:	c3                   	ret    

00800239 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800242:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800249:	00 00 00 
	b.cnt = 0;
  80024c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800253:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800256:	ff 75 0c             	pushl  0xc(%ebp)
  800259:	ff 75 08             	pushl  0x8(%ebp)
  80025c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800262:	50                   	push   %eax
  800263:	68 f7 01 80 00       	push   $0x8001f7
  800268:	e8 54 01 00 00       	call   8003c1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026d:	83 c4 08             	add    $0x8,%esp
  800270:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800276:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027c:	50                   	push   %eax
  80027d:	e8 d4 08 00 00       	call   800b56 <sys_cputs>

	return b.cnt;
}
  800282:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800288:	c9                   	leave  
  800289:	c3                   	ret    

0080028a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800290:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800293:	50                   	push   %eax
  800294:	ff 75 08             	pushl  0x8(%ebp)
  800297:	e8 9d ff ff ff       	call   800239 <vcprintf>
	va_end(ap);

	return cnt;
}
  80029c:	c9                   	leave  
  80029d:	c3                   	ret    

0080029e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80029e:	55                   	push   %ebp
  80029f:	89 e5                	mov    %esp,%ebp
  8002a1:	57                   	push   %edi
  8002a2:	56                   	push   %esi
  8002a3:	53                   	push   %ebx
  8002a4:	83 ec 1c             	sub    $0x1c,%esp
  8002a7:	89 c7                	mov    %eax,%edi
  8002a9:	89 d6                	mov    %edx,%esi
  8002ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002b4:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002c2:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002c5:	39 d3                	cmp    %edx,%ebx
  8002c7:	72 05                	jb     8002ce <printnum+0x30>
  8002c9:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002cc:	77 45                	ja     800313 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ce:	83 ec 0c             	sub    $0xc,%esp
  8002d1:	ff 75 18             	pushl  0x18(%ebp)
  8002d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d7:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002da:	53                   	push   %ebx
  8002db:	ff 75 10             	pushl  0x10(%ebp)
  8002de:	83 ec 08             	sub    $0x8,%esp
  8002e1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e4:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e7:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ea:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ed:	e8 ee 1c 00 00       	call   801fe0 <__udivdi3>
  8002f2:	83 c4 18             	add    $0x18,%esp
  8002f5:	52                   	push   %edx
  8002f6:	50                   	push   %eax
  8002f7:	89 f2                	mov    %esi,%edx
  8002f9:	89 f8                	mov    %edi,%eax
  8002fb:	e8 9e ff ff ff       	call   80029e <printnum>
  800300:	83 c4 20             	add    $0x20,%esp
  800303:	eb 18                	jmp    80031d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800305:	83 ec 08             	sub    $0x8,%esp
  800308:	56                   	push   %esi
  800309:	ff 75 18             	pushl  0x18(%ebp)
  80030c:	ff d7                	call   *%edi
  80030e:	83 c4 10             	add    $0x10,%esp
  800311:	eb 03                	jmp    800316 <printnum+0x78>
  800313:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800316:	83 eb 01             	sub    $0x1,%ebx
  800319:	85 db                	test   %ebx,%ebx
  80031b:	7f e8                	jg     800305 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031d:	83 ec 08             	sub    $0x8,%esp
  800320:	56                   	push   %esi
  800321:	83 ec 04             	sub    $0x4,%esp
  800324:	ff 75 e4             	pushl  -0x1c(%ebp)
  800327:	ff 75 e0             	pushl  -0x20(%ebp)
  80032a:	ff 75 dc             	pushl  -0x24(%ebp)
  80032d:	ff 75 d8             	pushl  -0x28(%ebp)
  800330:	e8 db 1d 00 00       	call   802110 <__umoddi3>
  800335:	83 c4 14             	add    $0x14,%esp
  800338:	0f be 80 2b 23 80 00 	movsbl 0x80232b(%eax),%eax
  80033f:	50                   	push   %eax
  800340:	ff d7                	call   *%edi
}
  800342:	83 c4 10             	add    $0x10,%esp
  800345:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800348:	5b                   	pop    %ebx
  800349:	5e                   	pop    %esi
  80034a:	5f                   	pop    %edi
  80034b:	5d                   	pop    %ebp
  80034c:	c3                   	ret    

0080034d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80034d:	55                   	push   %ebp
  80034e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800350:	83 fa 01             	cmp    $0x1,%edx
  800353:	7e 0e                	jle    800363 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800355:	8b 10                	mov    (%eax),%edx
  800357:	8d 4a 08             	lea    0x8(%edx),%ecx
  80035a:	89 08                	mov    %ecx,(%eax)
  80035c:	8b 02                	mov    (%edx),%eax
  80035e:	8b 52 04             	mov    0x4(%edx),%edx
  800361:	eb 22                	jmp    800385 <getuint+0x38>
	else if (lflag)
  800363:	85 d2                	test   %edx,%edx
  800365:	74 10                	je     800377 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800367:	8b 10                	mov    (%eax),%edx
  800369:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036c:	89 08                	mov    %ecx,(%eax)
  80036e:	8b 02                	mov    (%edx),%eax
  800370:	ba 00 00 00 00       	mov    $0x0,%edx
  800375:	eb 0e                	jmp    800385 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800377:	8b 10                	mov    (%eax),%edx
  800379:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037c:	89 08                	mov    %ecx,(%eax)
  80037e:	8b 02                	mov    (%edx),%eax
  800380:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800385:	5d                   	pop    %ebp
  800386:	c3                   	ret    

00800387 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
  80038a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80038d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800391:	8b 10                	mov    (%eax),%edx
  800393:	3b 50 04             	cmp    0x4(%eax),%edx
  800396:	73 0a                	jae    8003a2 <sprintputch+0x1b>
		*b->buf++ = ch;
  800398:	8d 4a 01             	lea    0x1(%edx),%ecx
  80039b:	89 08                	mov    %ecx,(%eax)
  80039d:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a0:	88 02                	mov    %al,(%edx)
}
  8003a2:	5d                   	pop    %ebp
  8003a3:	c3                   	ret    

008003a4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003a4:	55                   	push   %ebp
  8003a5:	89 e5                	mov    %esp,%ebp
  8003a7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003aa:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003ad:	50                   	push   %eax
  8003ae:	ff 75 10             	pushl  0x10(%ebp)
  8003b1:	ff 75 0c             	pushl  0xc(%ebp)
  8003b4:	ff 75 08             	pushl  0x8(%ebp)
  8003b7:	e8 05 00 00 00       	call   8003c1 <vprintfmt>
	va_end(ap);
}
  8003bc:	83 c4 10             	add    $0x10,%esp
  8003bf:	c9                   	leave  
  8003c0:	c3                   	ret    

008003c1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c1:	55                   	push   %ebp
  8003c2:	89 e5                	mov    %esp,%ebp
  8003c4:	57                   	push   %edi
  8003c5:	56                   	push   %esi
  8003c6:	53                   	push   %ebx
  8003c7:	83 ec 2c             	sub    $0x2c,%esp
  8003ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8003cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003d0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003d3:	eb 12                	jmp    8003e7 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d5:	85 c0                	test   %eax,%eax
  8003d7:	0f 84 89 03 00 00    	je     800766 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003dd:	83 ec 08             	sub    $0x8,%esp
  8003e0:	53                   	push   %ebx
  8003e1:	50                   	push   %eax
  8003e2:	ff d6                	call   *%esi
  8003e4:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e7:	83 c7 01             	add    $0x1,%edi
  8003ea:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003ee:	83 f8 25             	cmp    $0x25,%eax
  8003f1:	75 e2                	jne    8003d5 <vprintfmt+0x14>
  8003f3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003f7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003fe:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800405:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80040c:	ba 00 00 00 00       	mov    $0x0,%edx
  800411:	eb 07                	jmp    80041a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800413:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800416:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	8d 47 01             	lea    0x1(%edi),%eax
  80041d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800420:	0f b6 07             	movzbl (%edi),%eax
  800423:	0f b6 c8             	movzbl %al,%ecx
  800426:	83 e8 23             	sub    $0x23,%eax
  800429:	3c 55                	cmp    $0x55,%al
  80042b:	0f 87 1a 03 00 00    	ja     80074b <vprintfmt+0x38a>
  800431:	0f b6 c0             	movzbl %al,%eax
  800434:	ff 24 85 60 24 80 00 	jmp    *0x802460(,%eax,4)
  80043b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80043e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800442:	eb d6                	jmp    80041a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800447:	b8 00 00 00 00       	mov    $0x0,%eax
  80044c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80044f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800452:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800456:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800459:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80045c:	83 fa 09             	cmp    $0x9,%edx
  80045f:	77 39                	ja     80049a <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800461:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800464:	eb e9                	jmp    80044f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800466:	8b 45 14             	mov    0x14(%ebp),%eax
  800469:	8d 48 04             	lea    0x4(%eax),%ecx
  80046c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80046f:	8b 00                	mov    (%eax),%eax
  800471:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800474:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800477:	eb 27                	jmp    8004a0 <vprintfmt+0xdf>
  800479:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80047c:	85 c0                	test   %eax,%eax
  80047e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800483:	0f 49 c8             	cmovns %eax,%ecx
  800486:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800489:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80048c:	eb 8c                	jmp    80041a <vprintfmt+0x59>
  80048e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800491:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800498:	eb 80                	jmp    80041a <vprintfmt+0x59>
  80049a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80049d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004a0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a4:	0f 89 70 ff ff ff    	jns    80041a <vprintfmt+0x59>
				width = precision, precision = -1;
  8004aa:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004b7:	e9 5e ff ff ff       	jmp    80041a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004bc:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004c2:	e9 53 ff ff ff       	jmp    80041a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ca:	8d 50 04             	lea    0x4(%eax),%edx
  8004cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d0:	83 ec 08             	sub    $0x8,%esp
  8004d3:	53                   	push   %ebx
  8004d4:	ff 30                	pushl  (%eax)
  8004d6:	ff d6                	call   *%esi
			break;
  8004d8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004de:	e9 04 ff ff ff       	jmp    8003e7 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e6:	8d 50 04             	lea    0x4(%eax),%edx
  8004e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ec:	8b 00                	mov    (%eax),%eax
  8004ee:	99                   	cltd   
  8004ef:	31 d0                	xor    %edx,%eax
  8004f1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f3:	83 f8 0f             	cmp    $0xf,%eax
  8004f6:	7f 0b                	jg     800503 <vprintfmt+0x142>
  8004f8:	8b 14 85 c0 25 80 00 	mov    0x8025c0(,%eax,4),%edx
  8004ff:	85 d2                	test   %edx,%edx
  800501:	75 18                	jne    80051b <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800503:	50                   	push   %eax
  800504:	68 43 23 80 00       	push   $0x802343
  800509:	53                   	push   %ebx
  80050a:	56                   	push   %esi
  80050b:	e8 94 fe ff ff       	call   8003a4 <printfmt>
  800510:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800513:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800516:	e9 cc fe ff ff       	jmp    8003e7 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80051b:	52                   	push   %edx
  80051c:	68 71 27 80 00       	push   $0x802771
  800521:	53                   	push   %ebx
  800522:	56                   	push   %esi
  800523:	e8 7c fe ff ff       	call   8003a4 <printfmt>
  800528:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80052e:	e9 b4 fe ff ff       	jmp    8003e7 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8d 50 04             	lea    0x4(%eax),%edx
  800539:	89 55 14             	mov    %edx,0x14(%ebp)
  80053c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80053e:	85 ff                	test   %edi,%edi
  800540:	b8 3c 23 80 00       	mov    $0x80233c,%eax
  800545:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800548:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80054c:	0f 8e 94 00 00 00    	jle    8005e6 <vprintfmt+0x225>
  800552:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800556:	0f 84 98 00 00 00    	je     8005f4 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80055c:	83 ec 08             	sub    $0x8,%esp
  80055f:	ff 75 d0             	pushl  -0x30(%ebp)
  800562:	57                   	push   %edi
  800563:	e8 86 02 00 00       	call   8007ee <strnlen>
  800568:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80056b:	29 c1                	sub    %eax,%ecx
  80056d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800570:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800573:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800577:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80057a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80057d:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80057f:	eb 0f                	jmp    800590 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800581:	83 ec 08             	sub    $0x8,%esp
  800584:	53                   	push   %ebx
  800585:	ff 75 e0             	pushl  -0x20(%ebp)
  800588:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058a:	83 ef 01             	sub    $0x1,%edi
  80058d:	83 c4 10             	add    $0x10,%esp
  800590:	85 ff                	test   %edi,%edi
  800592:	7f ed                	jg     800581 <vprintfmt+0x1c0>
  800594:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800597:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80059a:	85 c9                	test   %ecx,%ecx
  80059c:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a1:	0f 49 c1             	cmovns %ecx,%eax
  8005a4:	29 c1                	sub    %eax,%ecx
  8005a6:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ac:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005af:	89 cb                	mov    %ecx,%ebx
  8005b1:	eb 4d                	jmp    800600 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005b7:	74 1b                	je     8005d4 <vprintfmt+0x213>
  8005b9:	0f be c0             	movsbl %al,%eax
  8005bc:	83 e8 20             	sub    $0x20,%eax
  8005bf:	83 f8 5e             	cmp    $0x5e,%eax
  8005c2:	76 10                	jbe    8005d4 <vprintfmt+0x213>
					putch('?', putdat);
  8005c4:	83 ec 08             	sub    $0x8,%esp
  8005c7:	ff 75 0c             	pushl  0xc(%ebp)
  8005ca:	6a 3f                	push   $0x3f
  8005cc:	ff 55 08             	call   *0x8(%ebp)
  8005cf:	83 c4 10             	add    $0x10,%esp
  8005d2:	eb 0d                	jmp    8005e1 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005d4:	83 ec 08             	sub    $0x8,%esp
  8005d7:	ff 75 0c             	pushl  0xc(%ebp)
  8005da:	52                   	push   %edx
  8005db:	ff 55 08             	call   *0x8(%ebp)
  8005de:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e1:	83 eb 01             	sub    $0x1,%ebx
  8005e4:	eb 1a                	jmp    800600 <vprintfmt+0x23f>
  8005e6:	89 75 08             	mov    %esi,0x8(%ebp)
  8005e9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ec:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ef:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005f2:	eb 0c                	jmp    800600 <vprintfmt+0x23f>
  8005f4:	89 75 08             	mov    %esi,0x8(%ebp)
  8005f7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005fa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005fd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800600:	83 c7 01             	add    $0x1,%edi
  800603:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800607:	0f be d0             	movsbl %al,%edx
  80060a:	85 d2                	test   %edx,%edx
  80060c:	74 23                	je     800631 <vprintfmt+0x270>
  80060e:	85 f6                	test   %esi,%esi
  800610:	78 a1                	js     8005b3 <vprintfmt+0x1f2>
  800612:	83 ee 01             	sub    $0x1,%esi
  800615:	79 9c                	jns    8005b3 <vprintfmt+0x1f2>
  800617:	89 df                	mov    %ebx,%edi
  800619:	8b 75 08             	mov    0x8(%ebp),%esi
  80061c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061f:	eb 18                	jmp    800639 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800621:	83 ec 08             	sub    $0x8,%esp
  800624:	53                   	push   %ebx
  800625:	6a 20                	push   $0x20
  800627:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800629:	83 ef 01             	sub    $0x1,%edi
  80062c:	83 c4 10             	add    $0x10,%esp
  80062f:	eb 08                	jmp    800639 <vprintfmt+0x278>
  800631:	89 df                	mov    %ebx,%edi
  800633:	8b 75 08             	mov    0x8(%ebp),%esi
  800636:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800639:	85 ff                	test   %edi,%edi
  80063b:	7f e4                	jg     800621 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800640:	e9 a2 fd ff ff       	jmp    8003e7 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800645:	83 fa 01             	cmp    $0x1,%edx
  800648:	7e 16                	jle    800660 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80064a:	8b 45 14             	mov    0x14(%ebp),%eax
  80064d:	8d 50 08             	lea    0x8(%eax),%edx
  800650:	89 55 14             	mov    %edx,0x14(%ebp)
  800653:	8b 50 04             	mov    0x4(%eax),%edx
  800656:	8b 00                	mov    (%eax),%eax
  800658:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80065e:	eb 32                	jmp    800692 <vprintfmt+0x2d1>
	else if (lflag)
  800660:	85 d2                	test   %edx,%edx
  800662:	74 18                	je     80067c <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800664:	8b 45 14             	mov    0x14(%ebp),%eax
  800667:	8d 50 04             	lea    0x4(%eax),%edx
  80066a:	89 55 14             	mov    %edx,0x14(%ebp)
  80066d:	8b 00                	mov    (%eax),%eax
  80066f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800672:	89 c1                	mov    %eax,%ecx
  800674:	c1 f9 1f             	sar    $0x1f,%ecx
  800677:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80067a:	eb 16                	jmp    800692 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8d 50 04             	lea    0x4(%eax),%edx
  800682:	89 55 14             	mov    %edx,0x14(%ebp)
  800685:	8b 00                	mov    (%eax),%eax
  800687:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068a:	89 c1                	mov    %eax,%ecx
  80068c:	c1 f9 1f             	sar    $0x1f,%ecx
  80068f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800692:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800695:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800698:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80069d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006a1:	79 74                	jns    800717 <vprintfmt+0x356>
				putch('-', putdat);
  8006a3:	83 ec 08             	sub    $0x8,%esp
  8006a6:	53                   	push   %ebx
  8006a7:	6a 2d                	push   $0x2d
  8006a9:	ff d6                	call   *%esi
				num = -(long long) num;
  8006ab:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006ae:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006b1:	f7 d8                	neg    %eax
  8006b3:	83 d2 00             	adc    $0x0,%edx
  8006b6:	f7 da                	neg    %edx
  8006b8:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006bb:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006c0:	eb 55                	jmp    800717 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006c2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c5:	e8 83 fc ff ff       	call   80034d <getuint>
			base = 10;
  8006ca:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006cf:	eb 46                	jmp    800717 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006d1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d4:	e8 74 fc ff ff       	call   80034d <getuint>
			base = 8;
  8006d9:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006de:	eb 37                	jmp    800717 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8006e0:	83 ec 08             	sub    $0x8,%esp
  8006e3:	53                   	push   %ebx
  8006e4:	6a 30                	push   $0x30
  8006e6:	ff d6                	call   *%esi
			putch('x', putdat);
  8006e8:	83 c4 08             	add    $0x8,%esp
  8006eb:	53                   	push   %ebx
  8006ec:	6a 78                	push   $0x78
  8006ee:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f3:	8d 50 04             	lea    0x4(%eax),%edx
  8006f6:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006f9:	8b 00                	mov    (%eax),%eax
  8006fb:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800700:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800703:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800708:	eb 0d                	jmp    800717 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80070a:	8d 45 14             	lea    0x14(%ebp),%eax
  80070d:	e8 3b fc ff ff       	call   80034d <getuint>
			base = 16;
  800712:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800717:	83 ec 0c             	sub    $0xc,%esp
  80071a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80071e:	57                   	push   %edi
  80071f:	ff 75 e0             	pushl  -0x20(%ebp)
  800722:	51                   	push   %ecx
  800723:	52                   	push   %edx
  800724:	50                   	push   %eax
  800725:	89 da                	mov    %ebx,%edx
  800727:	89 f0                	mov    %esi,%eax
  800729:	e8 70 fb ff ff       	call   80029e <printnum>
			break;
  80072e:	83 c4 20             	add    $0x20,%esp
  800731:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800734:	e9 ae fc ff ff       	jmp    8003e7 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800739:	83 ec 08             	sub    $0x8,%esp
  80073c:	53                   	push   %ebx
  80073d:	51                   	push   %ecx
  80073e:	ff d6                	call   *%esi
			break;
  800740:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800743:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800746:	e9 9c fc ff ff       	jmp    8003e7 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80074b:	83 ec 08             	sub    $0x8,%esp
  80074e:	53                   	push   %ebx
  80074f:	6a 25                	push   $0x25
  800751:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800753:	83 c4 10             	add    $0x10,%esp
  800756:	eb 03                	jmp    80075b <vprintfmt+0x39a>
  800758:	83 ef 01             	sub    $0x1,%edi
  80075b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80075f:	75 f7                	jne    800758 <vprintfmt+0x397>
  800761:	e9 81 fc ff ff       	jmp    8003e7 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800766:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800769:	5b                   	pop    %ebx
  80076a:	5e                   	pop    %esi
  80076b:	5f                   	pop    %edi
  80076c:	5d                   	pop    %ebp
  80076d:	c3                   	ret    

0080076e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	83 ec 18             	sub    $0x18,%esp
  800774:	8b 45 08             	mov    0x8(%ebp),%eax
  800777:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80077a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80077d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800781:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800784:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80078b:	85 c0                	test   %eax,%eax
  80078d:	74 26                	je     8007b5 <vsnprintf+0x47>
  80078f:	85 d2                	test   %edx,%edx
  800791:	7e 22                	jle    8007b5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800793:	ff 75 14             	pushl  0x14(%ebp)
  800796:	ff 75 10             	pushl  0x10(%ebp)
  800799:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80079c:	50                   	push   %eax
  80079d:	68 87 03 80 00       	push   $0x800387
  8007a2:	e8 1a fc ff ff       	call   8003c1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007aa:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b0:	83 c4 10             	add    $0x10,%esp
  8007b3:	eb 05                	jmp    8007ba <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007ba:	c9                   	leave  
  8007bb:	c3                   	ret    

008007bc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c5:	50                   	push   %eax
  8007c6:	ff 75 10             	pushl  0x10(%ebp)
  8007c9:	ff 75 0c             	pushl  0xc(%ebp)
  8007cc:	ff 75 08             	pushl  0x8(%ebp)
  8007cf:	e8 9a ff ff ff       	call   80076e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d4:	c9                   	leave  
  8007d5:	c3                   	ret    

008007d6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e1:	eb 03                	jmp    8007e6 <strlen+0x10>
		n++;
  8007e3:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ea:	75 f7                	jne    8007e3 <strlen+0xd>
		n++;
	return n;
}
  8007ec:	5d                   	pop    %ebp
  8007ed:	c3                   	ret    

008007ee <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f4:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8007fc:	eb 03                	jmp    800801 <strnlen+0x13>
		n++;
  8007fe:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800801:	39 c2                	cmp    %eax,%edx
  800803:	74 08                	je     80080d <strnlen+0x1f>
  800805:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800809:	75 f3                	jne    8007fe <strnlen+0x10>
  80080b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	53                   	push   %ebx
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800819:	89 c2                	mov    %eax,%edx
  80081b:	83 c2 01             	add    $0x1,%edx
  80081e:	83 c1 01             	add    $0x1,%ecx
  800821:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800825:	88 5a ff             	mov    %bl,-0x1(%edx)
  800828:	84 db                	test   %bl,%bl
  80082a:	75 ef                	jne    80081b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80082c:	5b                   	pop    %ebx
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	53                   	push   %ebx
  800833:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800836:	53                   	push   %ebx
  800837:	e8 9a ff ff ff       	call   8007d6 <strlen>
  80083c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80083f:	ff 75 0c             	pushl  0xc(%ebp)
  800842:	01 d8                	add    %ebx,%eax
  800844:	50                   	push   %eax
  800845:	e8 c5 ff ff ff       	call   80080f <strcpy>
	return dst;
}
  80084a:	89 d8                	mov    %ebx,%eax
  80084c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80084f:	c9                   	leave  
  800850:	c3                   	ret    

00800851 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	56                   	push   %esi
  800855:	53                   	push   %ebx
  800856:	8b 75 08             	mov    0x8(%ebp),%esi
  800859:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085c:	89 f3                	mov    %esi,%ebx
  80085e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800861:	89 f2                	mov    %esi,%edx
  800863:	eb 0f                	jmp    800874 <strncpy+0x23>
		*dst++ = *src;
  800865:	83 c2 01             	add    $0x1,%edx
  800868:	0f b6 01             	movzbl (%ecx),%eax
  80086b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80086e:	80 39 01             	cmpb   $0x1,(%ecx)
  800871:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800874:	39 da                	cmp    %ebx,%edx
  800876:	75 ed                	jne    800865 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800878:	89 f0                	mov    %esi,%eax
  80087a:	5b                   	pop    %ebx
  80087b:	5e                   	pop    %esi
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	56                   	push   %esi
  800882:	53                   	push   %ebx
  800883:	8b 75 08             	mov    0x8(%ebp),%esi
  800886:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800889:	8b 55 10             	mov    0x10(%ebp),%edx
  80088c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80088e:	85 d2                	test   %edx,%edx
  800890:	74 21                	je     8008b3 <strlcpy+0x35>
  800892:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800896:	89 f2                	mov    %esi,%edx
  800898:	eb 09                	jmp    8008a3 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80089a:	83 c2 01             	add    $0x1,%edx
  80089d:	83 c1 01             	add    $0x1,%ecx
  8008a0:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a3:	39 c2                	cmp    %eax,%edx
  8008a5:	74 09                	je     8008b0 <strlcpy+0x32>
  8008a7:	0f b6 19             	movzbl (%ecx),%ebx
  8008aa:	84 db                	test   %bl,%bl
  8008ac:	75 ec                	jne    80089a <strlcpy+0x1c>
  8008ae:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008b0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b3:	29 f0                	sub    %esi,%eax
}
  8008b5:	5b                   	pop    %ebx
  8008b6:	5e                   	pop    %esi
  8008b7:	5d                   	pop    %ebp
  8008b8:	c3                   	ret    

008008b9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bf:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c2:	eb 06                	jmp    8008ca <strcmp+0x11>
		p++, q++;
  8008c4:	83 c1 01             	add    $0x1,%ecx
  8008c7:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ca:	0f b6 01             	movzbl (%ecx),%eax
  8008cd:	84 c0                	test   %al,%al
  8008cf:	74 04                	je     8008d5 <strcmp+0x1c>
  8008d1:	3a 02                	cmp    (%edx),%al
  8008d3:	74 ef                	je     8008c4 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d5:	0f b6 c0             	movzbl %al,%eax
  8008d8:	0f b6 12             	movzbl (%edx),%edx
  8008db:	29 d0                	sub    %edx,%eax
}
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	53                   	push   %ebx
  8008e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e9:	89 c3                	mov    %eax,%ebx
  8008eb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ee:	eb 06                	jmp    8008f6 <strncmp+0x17>
		n--, p++, q++;
  8008f0:	83 c0 01             	add    $0x1,%eax
  8008f3:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f6:	39 d8                	cmp    %ebx,%eax
  8008f8:	74 15                	je     80090f <strncmp+0x30>
  8008fa:	0f b6 08             	movzbl (%eax),%ecx
  8008fd:	84 c9                	test   %cl,%cl
  8008ff:	74 04                	je     800905 <strncmp+0x26>
  800901:	3a 0a                	cmp    (%edx),%cl
  800903:	74 eb                	je     8008f0 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800905:	0f b6 00             	movzbl (%eax),%eax
  800908:	0f b6 12             	movzbl (%edx),%edx
  80090b:	29 d0                	sub    %edx,%eax
  80090d:	eb 05                	jmp    800914 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80090f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800914:	5b                   	pop    %ebx
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    

00800917 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	8b 45 08             	mov    0x8(%ebp),%eax
  80091d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800921:	eb 07                	jmp    80092a <strchr+0x13>
		if (*s == c)
  800923:	38 ca                	cmp    %cl,%dl
  800925:	74 0f                	je     800936 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800927:	83 c0 01             	add    $0x1,%eax
  80092a:	0f b6 10             	movzbl (%eax),%edx
  80092d:	84 d2                	test   %dl,%dl
  80092f:	75 f2                	jne    800923 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800931:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	8b 45 08             	mov    0x8(%ebp),%eax
  80093e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800942:	eb 03                	jmp    800947 <strfind+0xf>
  800944:	83 c0 01             	add    $0x1,%eax
  800947:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80094a:	38 ca                	cmp    %cl,%dl
  80094c:	74 04                	je     800952 <strfind+0x1a>
  80094e:	84 d2                	test   %dl,%dl
  800950:	75 f2                	jne    800944 <strfind+0xc>
			break;
	return (char *) s;
}
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	57                   	push   %edi
  800958:	56                   	push   %esi
  800959:	53                   	push   %ebx
  80095a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800960:	85 c9                	test   %ecx,%ecx
  800962:	74 36                	je     80099a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800964:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096a:	75 28                	jne    800994 <memset+0x40>
  80096c:	f6 c1 03             	test   $0x3,%cl
  80096f:	75 23                	jne    800994 <memset+0x40>
		c &= 0xFF;
  800971:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800975:	89 d3                	mov    %edx,%ebx
  800977:	c1 e3 08             	shl    $0x8,%ebx
  80097a:	89 d6                	mov    %edx,%esi
  80097c:	c1 e6 18             	shl    $0x18,%esi
  80097f:	89 d0                	mov    %edx,%eax
  800981:	c1 e0 10             	shl    $0x10,%eax
  800984:	09 f0                	or     %esi,%eax
  800986:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800988:	89 d8                	mov    %ebx,%eax
  80098a:	09 d0                	or     %edx,%eax
  80098c:	c1 e9 02             	shr    $0x2,%ecx
  80098f:	fc                   	cld    
  800990:	f3 ab                	rep stos %eax,%es:(%edi)
  800992:	eb 06                	jmp    80099a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800994:	8b 45 0c             	mov    0xc(%ebp),%eax
  800997:	fc                   	cld    
  800998:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80099a:	89 f8                	mov    %edi,%eax
  80099c:	5b                   	pop    %ebx
  80099d:	5e                   	pop    %esi
  80099e:	5f                   	pop    %edi
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	57                   	push   %edi
  8009a5:	56                   	push   %esi
  8009a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ac:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009af:	39 c6                	cmp    %eax,%esi
  8009b1:	73 35                	jae    8009e8 <memmove+0x47>
  8009b3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b6:	39 d0                	cmp    %edx,%eax
  8009b8:	73 2e                	jae    8009e8 <memmove+0x47>
		s += n;
		d += n;
  8009ba:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bd:	89 d6                	mov    %edx,%esi
  8009bf:	09 fe                	or     %edi,%esi
  8009c1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c7:	75 13                	jne    8009dc <memmove+0x3b>
  8009c9:	f6 c1 03             	test   $0x3,%cl
  8009cc:	75 0e                	jne    8009dc <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009ce:	83 ef 04             	sub    $0x4,%edi
  8009d1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d4:	c1 e9 02             	shr    $0x2,%ecx
  8009d7:	fd                   	std    
  8009d8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009da:	eb 09                	jmp    8009e5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009dc:	83 ef 01             	sub    $0x1,%edi
  8009df:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009e2:	fd                   	std    
  8009e3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009e5:	fc                   	cld    
  8009e6:	eb 1d                	jmp    800a05 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e8:	89 f2                	mov    %esi,%edx
  8009ea:	09 c2                	or     %eax,%edx
  8009ec:	f6 c2 03             	test   $0x3,%dl
  8009ef:	75 0f                	jne    800a00 <memmove+0x5f>
  8009f1:	f6 c1 03             	test   $0x3,%cl
  8009f4:	75 0a                	jne    800a00 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009f6:	c1 e9 02             	shr    $0x2,%ecx
  8009f9:	89 c7                	mov    %eax,%edi
  8009fb:	fc                   	cld    
  8009fc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009fe:	eb 05                	jmp    800a05 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a00:	89 c7                	mov    %eax,%edi
  800a02:	fc                   	cld    
  800a03:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a05:	5e                   	pop    %esi
  800a06:	5f                   	pop    %edi
  800a07:	5d                   	pop    %ebp
  800a08:	c3                   	ret    

00800a09 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a0c:	ff 75 10             	pushl  0x10(%ebp)
  800a0f:	ff 75 0c             	pushl  0xc(%ebp)
  800a12:	ff 75 08             	pushl  0x8(%ebp)
  800a15:	e8 87 ff ff ff       	call   8009a1 <memmove>
}
  800a1a:	c9                   	leave  
  800a1b:	c3                   	ret    

00800a1c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	56                   	push   %esi
  800a20:	53                   	push   %ebx
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
  800a24:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a27:	89 c6                	mov    %eax,%esi
  800a29:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2c:	eb 1a                	jmp    800a48 <memcmp+0x2c>
		if (*s1 != *s2)
  800a2e:	0f b6 08             	movzbl (%eax),%ecx
  800a31:	0f b6 1a             	movzbl (%edx),%ebx
  800a34:	38 d9                	cmp    %bl,%cl
  800a36:	74 0a                	je     800a42 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a38:	0f b6 c1             	movzbl %cl,%eax
  800a3b:	0f b6 db             	movzbl %bl,%ebx
  800a3e:	29 d8                	sub    %ebx,%eax
  800a40:	eb 0f                	jmp    800a51 <memcmp+0x35>
		s1++, s2++;
  800a42:	83 c0 01             	add    $0x1,%eax
  800a45:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a48:	39 f0                	cmp    %esi,%eax
  800a4a:	75 e2                	jne    800a2e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a51:	5b                   	pop    %ebx
  800a52:	5e                   	pop    %esi
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    

00800a55 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	53                   	push   %ebx
  800a59:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a5c:	89 c1                	mov    %eax,%ecx
  800a5e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a61:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a65:	eb 0a                	jmp    800a71 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a67:	0f b6 10             	movzbl (%eax),%edx
  800a6a:	39 da                	cmp    %ebx,%edx
  800a6c:	74 07                	je     800a75 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a6e:	83 c0 01             	add    $0x1,%eax
  800a71:	39 c8                	cmp    %ecx,%eax
  800a73:	72 f2                	jb     800a67 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a75:	5b                   	pop    %ebx
  800a76:	5d                   	pop    %ebp
  800a77:	c3                   	ret    

00800a78 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	57                   	push   %edi
  800a7c:	56                   	push   %esi
  800a7d:	53                   	push   %ebx
  800a7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a81:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a84:	eb 03                	jmp    800a89 <strtol+0x11>
		s++;
  800a86:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a89:	0f b6 01             	movzbl (%ecx),%eax
  800a8c:	3c 20                	cmp    $0x20,%al
  800a8e:	74 f6                	je     800a86 <strtol+0xe>
  800a90:	3c 09                	cmp    $0x9,%al
  800a92:	74 f2                	je     800a86 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a94:	3c 2b                	cmp    $0x2b,%al
  800a96:	75 0a                	jne    800aa2 <strtol+0x2a>
		s++;
  800a98:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9b:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa0:	eb 11                	jmp    800ab3 <strtol+0x3b>
  800aa2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aa7:	3c 2d                	cmp    $0x2d,%al
  800aa9:	75 08                	jne    800ab3 <strtol+0x3b>
		s++, neg = 1;
  800aab:	83 c1 01             	add    $0x1,%ecx
  800aae:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ab9:	75 15                	jne    800ad0 <strtol+0x58>
  800abb:	80 39 30             	cmpb   $0x30,(%ecx)
  800abe:	75 10                	jne    800ad0 <strtol+0x58>
  800ac0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ac4:	75 7c                	jne    800b42 <strtol+0xca>
		s += 2, base = 16;
  800ac6:	83 c1 02             	add    $0x2,%ecx
  800ac9:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ace:	eb 16                	jmp    800ae6 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ad0:	85 db                	test   %ebx,%ebx
  800ad2:	75 12                	jne    800ae6 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ad4:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad9:	80 39 30             	cmpb   $0x30,(%ecx)
  800adc:	75 08                	jne    800ae6 <strtol+0x6e>
		s++, base = 8;
  800ade:	83 c1 01             	add    $0x1,%ecx
  800ae1:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ae6:	b8 00 00 00 00       	mov    $0x0,%eax
  800aeb:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aee:	0f b6 11             	movzbl (%ecx),%edx
  800af1:	8d 72 d0             	lea    -0x30(%edx),%esi
  800af4:	89 f3                	mov    %esi,%ebx
  800af6:	80 fb 09             	cmp    $0x9,%bl
  800af9:	77 08                	ja     800b03 <strtol+0x8b>
			dig = *s - '0';
  800afb:	0f be d2             	movsbl %dl,%edx
  800afe:	83 ea 30             	sub    $0x30,%edx
  800b01:	eb 22                	jmp    800b25 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b03:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b06:	89 f3                	mov    %esi,%ebx
  800b08:	80 fb 19             	cmp    $0x19,%bl
  800b0b:	77 08                	ja     800b15 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b0d:	0f be d2             	movsbl %dl,%edx
  800b10:	83 ea 57             	sub    $0x57,%edx
  800b13:	eb 10                	jmp    800b25 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b15:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b18:	89 f3                	mov    %esi,%ebx
  800b1a:	80 fb 19             	cmp    $0x19,%bl
  800b1d:	77 16                	ja     800b35 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b1f:	0f be d2             	movsbl %dl,%edx
  800b22:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b25:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b28:	7d 0b                	jge    800b35 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b2a:	83 c1 01             	add    $0x1,%ecx
  800b2d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b31:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b33:	eb b9                	jmp    800aee <strtol+0x76>

	if (endptr)
  800b35:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b39:	74 0d                	je     800b48 <strtol+0xd0>
		*endptr = (char *) s;
  800b3b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b3e:	89 0e                	mov    %ecx,(%esi)
  800b40:	eb 06                	jmp    800b48 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b42:	85 db                	test   %ebx,%ebx
  800b44:	74 98                	je     800ade <strtol+0x66>
  800b46:	eb 9e                	jmp    800ae6 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b48:	89 c2                	mov    %eax,%edx
  800b4a:	f7 da                	neg    %edx
  800b4c:	85 ff                	test   %edi,%edi
  800b4e:	0f 45 c2             	cmovne %edx,%eax
}
  800b51:	5b                   	pop    %ebx
  800b52:	5e                   	pop    %esi
  800b53:	5f                   	pop    %edi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	57                   	push   %edi
  800b5a:	56                   	push   %esi
  800b5b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b64:	8b 55 08             	mov    0x8(%ebp),%edx
  800b67:	89 c3                	mov    %eax,%ebx
  800b69:	89 c7                	mov    %eax,%edi
  800b6b:	89 c6                	mov    %eax,%esi
  800b6d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5f                   	pop    %edi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	57                   	push   %edi
  800b78:	56                   	push   %esi
  800b79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b84:	89 d1                	mov    %edx,%ecx
  800b86:	89 d3                	mov    %edx,%ebx
  800b88:	89 d7                	mov    %edx,%edi
  800b8a:	89 d6                	mov    %edx,%esi
  800b8c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b8e:	5b                   	pop    %ebx
  800b8f:	5e                   	pop    %esi
  800b90:	5f                   	pop    %edi
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    

00800b93 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	57                   	push   %edi
  800b97:	56                   	push   %esi
  800b98:	53                   	push   %ebx
  800b99:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba1:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba9:	89 cb                	mov    %ecx,%ebx
  800bab:	89 cf                	mov    %ecx,%edi
  800bad:	89 ce                	mov    %ecx,%esi
  800baf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb1:	85 c0                	test   %eax,%eax
  800bb3:	7e 17                	jle    800bcc <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb5:	83 ec 0c             	sub    $0xc,%esp
  800bb8:	50                   	push   %eax
  800bb9:	6a 03                	push   $0x3
  800bbb:	68 1f 26 80 00       	push   $0x80261f
  800bc0:	6a 23                	push   $0x23
  800bc2:	68 3c 26 80 00       	push   $0x80263c
  800bc7:	e8 e5 f5 ff ff       	call   8001b1 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	57                   	push   %edi
  800bd8:	56                   	push   %esi
  800bd9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bda:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdf:	b8 02 00 00 00       	mov    $0x2,%eax
  800be4:	89 d1                	mov    %edx,%ecx
  800be6:	89 d3                	mov    %edx,%ebx
  800be8:	89 d7                	mov    %edx,%edi
  800bea:	89 d6                	mov    %edx,%esi
  800bec:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bee:	5b                   	pop    %ebx
  800bef:	5e                   	pop    %esi
  800bf0:	5f                   	pop    %edi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <sys_yield>:

void
sys_yield(void)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	57                   	push   %edi
  800bf7:	56                   	push   %esi
  800bf8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfe:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c03:	89 d1                	mov    %edx,%ecx
  800c05:	89 d3                	mov    %edx,%ebx
  800c07:	89 d7                	mov    %edx,%edi
  800c09:	89 d6                	mov    %edx,%esi
  800c0b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c0d:	5b                   	pop    %ebx
  800c0e:	5e                   	pop    %esi
  800c0f:	5f                   	pop    %edi
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
  800c18:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1b:	be 00 00 00 00       	mov    $0x0,%esi
  800c20:	b8 04 00 00 00       	mov    $0x4,%eax
  800c25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c28:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c2e:	89 f7                	mov    %esi,%edi
  800c30:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c32:	85 c0                	test   %eax,%eax
  800c34:	7e 17                	jle    800c4d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c36:	83 ec 0c             	sub    $0xc,%esp
  800c39:	50                   	push   %eax
  800c3a:	6a 04                	push   $0x4
  800c3c:	68 1f 26 80 00       	push   $0x80261f
  800c41:	6a 23                	push   $0x23
  800c43:	68 3c 26 80 00       	push   $0x80263c
  800c48:	e8 64 f5 ff ff       	call   8001b1 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800c5e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c66:	8b 55 08             	mov    0x8(%ebp),%edx
  800c69:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c6f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c72:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c74:	85 c0                	test   %eax,%eax
  800c76:	7e 17                	jle    800c8f <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c78:	83 ec 0c             	sub    $0xc,%esp
  800c7b:	50                   	push   %eax
  800c7c:	6a 05                	push   $0x5
  800c7e:	68 1f 26 80 00       	push   $0x80261f
  800c83:	6a 23                	push   $0x23
  800c85:	68 3c 26 80 00       	push   $0x80263c
  800c8a:	e8 22 f5 ff ff       	call   8001b1 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca5:	b8 06 00 00 00       	mov    $0x6,%eax
  800caa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cad:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb0:	89 df                	mov    %ebx,%edi
  800cb2:	89 de                	mov    %ebx,%esi
  800cb4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb6:	85 c0                	test   %eax,%eax
  800cb8:	7e 17                	jle    800cd1 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cba:	83 ec 0c             	sub    $0xc,%esp
  800cbd:	50                   	push   %eax
  800cbe:	6a 06                	push   $0x6
  800cc0:	68 1f 26 80 00       	push   $0x80261f
  800cc5:	6a 23                	push   $0x23
  800cc7:	68 3c 26 80 00       	push   $0x80263c
  800ccc:	e8 e0 f4 ff ff       	call   8001b1 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	57                   	push   %edi
  800cdd:	56                   	push   %esi
  800cde:	53                   	push   %ebx
  800cdf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce7:	b8 08 00 00 00       	mov    $0x8,%eax
  800cec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cef:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf2:	89 df                	mov    %ebx,%edi
  800cf4:	89 de                	mov    %ebx,%esi
  800cf6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf8:	85 c0                	test   %eax,%eax
  800cfa:	7e 17                	jle    800d13 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfc:	83 ec 0c             	sub    $0xc,%esp
  800cff:	50                   	push   %eax
  800d00:	6a 08                	push   $0x8
  800d02:	68 1f 26 80 00       	push   $0x80261f
  800d07:	6a 23                	push   $0x23
  800d09:	68 3c 26 80 00       	push   $0x80263c
  800d0e:	e8 9e f4 ff ff       	call   8001b1 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5f                   	pop    %edi
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	57                   	push   %edi
  800d1f:	56                   	push   %esi
  800d20:	53                   	push   %ebx
  800d21:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d24:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d29:	b8 09 00 00 00       	mov    $0x9,%eax
  800d2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d31:	8b 55 08             	mov    0x8(%ebp),%edx
  800d34:	89 df                	mov    %ebx,%edi
  800d36:	89 de                	mov    %ebx,%esi
  800d38:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3a:	85 c0                	test   %eax,%eax
  800d3c:	7e 17                	jle    800d55 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3e:	83 ec 0c             	sub    $0xc,%esp
  800d41:	50                   	push   %eax
  800d42:	6a 09                	push   $0x9
  800d44:	68 1f 26 80 00       	push   $0x80261f
  800d49:	6a 23                	push   $0x23
  800d4b:	68 3c 26 80 00       	push   $0x80263c
  800d50:	e8 5c f4 ff ff       	call   8001b1 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d58:	5b                   	pop    %ebx
  800d59:	5e                   	pop    %esi
  800d5a:	5f                   	pop    %edi
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    

00800d5d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	57                   	push   %edi
  800d61:	56                   	push   %esi
  800d62:	53                   	push   %ebx
  800d63:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d66:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d73:	8b 55 08             	mov    0x8(%ebp),%edx
  800d76:	89 df                	mov    %ebx,%edi
  800d78:	89 de                	mov    %ebx,%esi
  800d7a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	7e 17                	jle    800d97 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d80:	83 ec 0c             	sub    $0xc,%esp
  800d83:	50                   	push   %eax
  800d84:	6a 0a                	push   $0xa
  800d86:	68 1f 26 80 00       	push   $0x80261f
  800d8b:	6a 23                	push   $0x23
  800d8d:	68 3c 26 80 00       	push   $0x80263c
  800d92:	e8 1a f4 ff ff       	call   8001b1 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9a:	5b                   	pop    %ebx
  800d9b:	5e                   	pop    %esi
  800d9c:	5f                   	pop    %edi
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	57                   	push   %edi
  800da3:	56                   	push   %esi
  800da4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da5:	be 00 00 00 00       	mov    $0x0,%esi
  800daa:	b8 0c 00 00 00       	mov    $0xc,%eax
  800daf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db2:	8b 55 08             	mov    0x8(%ebp),%edx
  800db5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dbb:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dbd:	5b                   	pop    %ebx
  800dbe:	5e                   	pop    %esi
  800dbf:	5f                   	pop    %edi
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    

00800dc2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	57                   	push   %edi
  800dc6:	56                   	push   %esi
  800dc7:	53                   	push   %ebx
  800dc8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd0:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd8:	89 cb                	mov    %ecx,%ebx
  800dda:	89 cf                	mov    %ecx,%edi
  800ddc:	89 ce                	mov    %ecx,%esi
  800dde:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de0:	85 c0                	test   %eax,%eax
  800de2:	7e 17                	jle    800dfb <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de4:	83 ec 0c             	sub    $0xc,%esp
  800de7:	50                   	push   %eax
  800de8:	6a 0d                	push   $0xd
  800dea:	68 1f 26 80 00       	push   $0x80261f
  800def:	6a 23                	push   $0x23
  800df1:	68 3c 26 80 00       	push   $0x80263c
  800df6:	e8 b6 f3 ff ff       	call   8001b1 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfe:	5b                   	pop    %ebx
  800dff:	5e                   	pop    %esi
  800e00:	5f                   	pop    %edi
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    

00800e03 <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
  800e06:	57                   	push   %edi
  800e07:	56                   	push   %esi
  800e08:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e09:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e0e:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e13:	8b 55 08             	mov    0x8(%ebp),%edx
  800e16:	89 cb                	mov    %ecx,%ebx
  800e18:	89 cf                	mov    %ecx,%edi
  800e1a:	89 ce                	mov    %ecx,%esi
  800e1c:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800e1e:	5b                   	pop    %ebx
  800e1f:	5e                   	pop    %esi
  800e20:	5f                   	pop    %edi
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    

00800e23 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	53                   	push   %ebx
  800e27:	83 ec 04             	sub    $0x4,%esp
  800e2a:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e2d:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800e2f:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e33:	74 11                	je     800e46 <pgfault+0x23>
  800e35:	89 d8                	mov    %ebx,%eax
  800e37:	c1 e8 0c             	shr    $0xc,%eax
  800e3a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e41:	f6 c4 08             	test   $0x8,%ah
  800e44:	75 14                	jne    800e5a <pgfault+0x37>
		panic("faulting access");
  800e46:	83 ec 04             	sub    $0x4,%esp
  800e49:	68 4a 26 80 00       	push   $0x80264a
  800e4e:	6a 1d                	push   $0x1d
  800e50:	68 5a 26 80 00       	push   $0x80265a
  800e55:	e8 57 f3 ff ff       	call   8001b1 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e5a:	83 ec 04             	sub    $0x4,%esp
  800e5d:	6a 07                	push   $0x7
  800e5f:	68 00 f0 7f 00       	push   $0x7ff000
  800e64:	6a 00                	push   $0x0
  800e66:	e8 a7 fd ff ff       	call   800c12 <sys_page_alloc>
	if (r < 0) {
  800e6b:	83 c4 10             	add    $0x10,%esp
  800e6e:	85 c0                	test   %eax,%eax
  800e70:	79 12                	jns    800e84 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e72:	50                   	push   %eax
  800e73:	68 65 26 80 00       	push   $0x802665
  800e78:	6a 2b                	push   $0x2b
  800e7a:	68 5a 26 80 00       	push   $0x80265a
  800e7f:	e8 2d f3 ff ff       	call   8001b1 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e84:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e8a:	83 ec 04             	sub    $0x4,%esp
  800e8d:	68 00 10 00 00       	push   $0x1000
  800e92:	53                   	push   %ebx
  800e93:	68 00 f0 7f 00       	push   $0x7ff000
  800e98:	e8 6c fb ff ff       	call   800a09 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e9d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ea4:	53                   	push   %ebx
  800ea5:	6a 00                	push   $0x0
  800ea7:	68 00 f0 7f 00       	push   $0x7ff000
  800eac:	6a 00                	push   $0x0
  800eae:	e8 a2 fd ff ff       	call   800c55 <sys_page_map>
	if (r < 0) {
  800eb3:	83 c4 20             	add    $0x20,%esp
  800eb6:	85 c0                	test   %eax,%eax
  800eb8:	79 12                	jns    800ecc <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800eba:	50                   	push   %eax
  800ebb:	68 65 26 80 00       	push   $0x802665
  800ec0:	6a 32                	push   $0x32
  800ec2:	68 5a 26 80 00       	push   $0x80265a
  800ec7:	e8 e5 f2 ff ff       	call   8001b1 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800ecc:	83 ec 08             	sub    $0x8,%esp
  800ecf:	68 00 f0 7f 00       	push   $0x7ff000
  800ed4:	6a 00                	push   $0x0
  800ed6:	e8 bc fd ff ff       	call   800c97 <sys_page_unmap>
	if (r < 0) {
  800edb:	83 c4 10             	add    $0x10,%esp
  800ede:	85 c0                	test   %eax,%eax
  800ee0:	79 12                	jns    800ef4 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800ee2:	50                   	push   %eax
  800ee3:	68 65 26 80 00       	push   $0x802665
  800ee8:	6a 36                	push   $0x36
  800eea:	68 5a 26 80 00       	push   $0x80265a
  800eef:	e8 bd f2 ff ff       	call   8001b1 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800ef4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef7:	c9                   	leave  
  800ef8:	c3                   	ret    

00800ef9 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ef9:	55                   	push   %ebp
  800efa:	89 e5                	mov    %esp,%ebp
  800efc:	57                   	push   %edi
  800efd:	56                   	push   %esi
  800efe:	53                   	push   %ebx
  800eff:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800f02:	68 23 0e 80 00       	push   $0x800e23
  800f07:	e8 e9 0e 00 00       	call   801df5 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f0c:	b8 07 00 00 00       	mov    $0x7,%eax
  800f11:	cd 30                	int    $0x30
  800f13:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800f16:	83 c4 10             	add    $0x10,%esp
  800f19:	85 c0                	test   %eax,%eax
  800f1b:	79 17                	jns    800f34 <fork+0x3b>
		panic("fork fault %e");
  800f1d:	83 ec 04             	sub    $0x4,%esp
  800f20:	68 7e 26 80 00       	push   $0x80267e
  800f25:	68 83 00 00 00       	push   $0x83
  800f2a:	68 5a 26 80 00       	push   $0x80265a
  800f2f:	e8 7d f2 ff ff       	call   8001b1 <_panic>
  800f34:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f36:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f3a:	75 25                	jne    800f61 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f3c:	e8 93 fc ff ff       	call   800bd4 <sys_getenvid>
  800f41:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f46:	89 c2                	mov    %eax,%edx
  800f48:	c1 e2 07             	shl    $0x7,%edx
  800f4b:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800f52:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800f57:	b8 00 00 00 00       	mov    $0x0,%eax
  800f5c:	e9 61 01 00 00       	jmp    8010c2 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f61:	83 ec 04             	sub    $0x4,%esp
  800f64:	6a 07                	push   $0x7
  800f66:	68 00 f0 bf ee       	push   $0xeebff000
  800f6b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f6e:	e8 9f fc ff ff       	call   800c12 <sys_page_alloc>
  800f73:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f76:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f7b:	89 d8                	mov    %ebx,%eax
  800f7d:	c1 e8 16             	shr    $0x16,%eax
  800f80:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f87:	a8 01                	test   $0x1,%al
  800f89:	0f 84 fc 00 00 00    	je     80108b <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f8f:	89 d8                	mov    %ebx,%eax
  800f91:	c1 e8 0c             	shr    $0xc,%eax
  800f94:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f9b:	f6 c2 01             	test   $0x1,%dl
  800f9e:	0f 84 e7 00 00 00    	je     80108b <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800fa4:	89 c6                	mov    %eax,%esi
  800fa6:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800fa9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fb0:	f6 c6 04             	test   $0x4,%dh
  800fb3:	74 39                	je     800fee <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800fb5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fbc:	83 ec 0c             	sub    $0xc,%esp
  800fbf:	25 07 0e 00 00       	and    $0xe07,%eax
  800fc4:	50                   	push   %eax
  800fc5:	56                   	push   %esi
  800fc6:	57                   	push   %edi
  800fc7:	56                   	push   %esi
  800fc8:	6a 00                	push   $0x0
  800fca:	e8 86 fc ff ff       	call   800c55 <sys_page_map>
		if (r < 0) {
  800fcf:	83 c4 20             	add    $0x20,%esp
  800fd2:	85 c0                	test   %eax,%eax
  800fd4:	0f 89 b1 00 00 00    	jns    80108b <fork+0x192>
		    	panic("sys page map fault %e");
  800fda:	83 ec 04             	sub    $0x4,%esp
  800fdd:	68 8c 26 80 00       	push   $0x80268c
  800fe2:	6a 53                	push   $0x53
  800fe4:	68 5a 26 80 00       	push   $0x80265a
  800fe9:	e8 c3 f1 ff ff       	call   8001b1 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800fee:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ff5:	f6 c2 02             	test   $0x2,%dl
  800ff8:	75 0c                	jne    801006 <fork+0x10d>
  800ffa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801001:	f6 c4 08             	test   $0x8,%ah
  801004:	74 5b                	je     801061 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  801006:	83 ec 0c             	sub    $0xc,%esp
  801009:	68 05 08 00 00       	push   $0x805
  80100e:	56                   	push   %esi
  80100f:	57                   	push   %edi
  801010:	56                   	push   %esi
  801011:	6a 00                	push   $0x0
  801013:	e8 3d fc ff ff       	call   800c55 <sys_page_map>
		if (r < 0) {
  801018:	83 c4 20             	add    $0x20,%esp
  80101b:	85 c0                	test   %eax,%eax
  80101d:	79 14                	jns    801033 <fork+0x13a>
		    	panic("sys page map fault %e");
  80101f:	83 ec 04             	sub    $0x4,%esp
  801022:	68 8c 26 80 00       	push   $0x80268c
  801027:	6a 5a                	push   $0x5a
  801029:	68 5a 26 80 00       	push   $0x80265a
  80102e:	e8 7e f1 ff ff       	call   8001b1 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  801033:	83 ec 0c             	sub    $0xc,%esp
  801036:	68 05 08 00 00       	push   $0x805
  80103b:	56                   	push   %esi
  80103c:	6a 00                	push   $0x0
  80103e:	56                   	push   %esi
  80103f:	6a 00                	push   $0x0
  801041:	e8 0f fc ff ff       	call   800c55 <sys_page_map>
		if (r < 0) {
  801046:	83 c4 20             	add    $0x20,%esp
  801049:	85 c0                	test   %eax,%eax
  80104b:	79 3e                	jns    80108b <fork+0x192>
		    	panic("sys page map fault %e");
  80104d:	83 ec 04             	sub    $0x4,%esp
  801050:	68 8c 26 80 00       	push   $0x80268c
  801055:	6a 5e                	push   $0x5e
  801057:	68 5a 26 80 00       	push   $0x80265a
  80105c:	e8 50 f1 ff ff       	call   8001b1 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801061:	83 ec 0c             	sub    $0xc,%esp
  801064:	6a 05                	push   $0x5
  801066:	56                   	push   %esi
  801067:	57                   	push   %edi
  801068:	56                   	push   %esi
  801069:	6a 00                	push   $0x0
  80106b:	e8 e5 fb ff ff       	call   800c55 <sys_page_map>
		if (r < 0) {
  801070:	83 c4 20             	add    $0x20,%esp
  801073:	85 c0                	test   %eax,%eax
  801075:	79 14                	jns    80108b <fork+0x192>
		    	panic("sys page map fault %e");
  801077:	83 ec 04             	sub    $0x4,%esp
  80107a:	68 8c 26 80 00       	push   $0x80268c
  80107f:	6a 63                	push   $0x63
  801081:	68 5a 26 80 00       	push   $0x80265a
  801086:	e8 26 f1 ff ff       	call   8001b1 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80108b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801091:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801097:	0f 85 de fe ff ff    	jne    800f7b <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80109d:	a1 08 40 80 00       	mov    0x804008,%eax
  8010a2:	8b 40 6c             	mov    0x6c(%eax),%eax
  8010a5:	83 ec 08             	sub    $0x8,%esp
  8010a8:	50                   	push   %eax
  8010a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010ac:	57                   	push   %edi
  8010ad:	e8 ab fc ff ff       	call   800d5d <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8010b2:	83 c4 08             	add    $0x8,%esp
  8010b5:	6a 02                	push   $0x2
  8010b7:	57                   	push   %edi
  8010b8:	e8 1c fc ff ff       	call   800cd9 <sys_env_set_status>
	
	return envid;
  8010bd:	83 c4 10             	add    $0x10,%esp
  8010c0:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8010c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c5:	5b                   	pop    %ebx
  8010c6:	5e                   	pop    %esi
  8010c7:	5f                   	pop    %edi
  8010c8:	5d                   	pop    %ebp
  8010c9:	c3                   	ret    

008010ca <sfork>:

envid_t
sfork(void)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
	return 0;
}
  8010cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d2:	5d                   	pop    %ebp
  8010d3:	c3                   	ret    

008010d4 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
  8010d7:	56                   	push   %esi
  8010d8:	53                   	push   %ebx
  8010d9:	8b 5d 08             	mov    0x8(%ebp),%ebx

	cprintf("in fork.c thread create. func: %x\n", func);
  8010dc:	83 ec 08             	sub    $0x8,%esp
  8010df:	53                   	push   %ebx
  8010e0:	68 a4 26 80 00       	push   $0x8026a4
  8010e5:	e8 a0 f1 ff ff       	call   80028a <cprintf>
	envid_t id = sys_thread_create((uintptr_t )func);
  8010ea:	89 1c 24             	mov    %ebx,(%esp)
  8010ed:	e8 11 fd ff ff       	call   800e03 <sys_thread_create>
  8010f2:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8010f4:	83 c4 08             	add    $0x8,%esp
  8010f7:	53                   	push   %ebx
  8010f8:	68 a4 26 80 00       	push   $0x8026a4
  8010fd:	e8 88 f1 ff ff       	call   80028a <cprintf>
	return id;
}
  801102:	89 f0                	mov    %esi,%eax
  801104:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801107:	5b                   	pop    %ebx
  801108:	5e                   	pop    %esi
  801109:	5d                   	pop    %ebp
  80110a:	c3                   	ret    

0080110b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80110e:	8b 45 08             	mov    0x8(%ebp),%eax
  801111:	05 00 00 00 30       	add    $0x30000000,%eax
  801116:	c1 e8 0c             	shr    $0xc,%eax
}
  801119:	5d                   	pop    %ebp
  80111a:	c3                   	ret    

0080111b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80111e:	8b 45 08             	mov    0x8(%ebp),%eax
  801121:	05 00 00 00 30       	add    $0x30000000,%eax
  801126:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80112b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801130:	5d                   	pop    %ebp
  801131:	c3                   	ret    

00801132 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801132:	55                   	push   %ebp
  801133:	89 e5                	mov    %esp,%ebp
  801135:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801138:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80113d:	89 c2                	mov    %eax,%edx
  80113f:	c1 ea 16             	shr    $0x16,%edx
  801142:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801149:	f6 c2 01             	test   $0x1,%dl
  80114c:	74 11                	je     80115f <fd_alloc+0x2d>
  80114e:	89 c2                	mov    %eax,%edx
  801150:	c1 ea 0c             	shr    $0xc,%edx
  801153:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80115a:	f6 c2 01             	test   $0x1,%dl
  80115d:	75 09                	jne    801168 <fd_alloc+0x36>
			*fd_store = fd;
  80115f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801161:	b8 00 00 00 00       	mov    $0x0,%eax
  801166:	eb 17                	jmp    80117f <fd_alloc+0x4d>
  801168:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80116d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801172:	75 c9                	jne    80113d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801174:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80117a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80117f:	5d                   	pop    %ebp
  801180:	c3                   	ret    

00801181 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801181:	55                   	push   %ebp
  801182:	89 e5                	mov    %esp,%ebp
  801184:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801187:	83 f8 1f             	cmp    $0x1f,%eax
  80118a:	77 36                	ja     8011c2 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80118c:	c1 e0 0c             	shl    $0xc,%eax
  80118f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801194:	89 c2                	mov    %eax,%edx
  801196:	c1 ea 16             	shr    $0x16,%edx
  801199:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011a0:	f6 c2 01             	test   $0x1,%dl
  8011a3:	74 24                	je     8011c9 <fd_lookup+0x48>
  8011a5:	89 c2                	mov    %eax,%edx
  8011a7:	c1 ea 0c             	shr    $0xc,%edx
  8011aa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011b1:	f6 c2 01             	test   $0x1,%dl
  8011b4:	74 1a                	je     8011d0 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011b9:	89 02                	mov    %eax,(%edx)
	return 0;
  8011bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c0:	eb 13                	jmp    8011d5 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011c7:	eb 0c                	jmp    8011d5 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ce:	eb 05                	jmp    8011d5 <fd_lookup+0x54>
  8011d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011d5:	5d                   	pop    %ebp
  8011d6:	c3                   	ret    

008011d7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011d7:	55                   	push   %ebp
  8011d8:	89 e5                	mov    %esp,%ebp
  8011da:	83 ec 08             	sub    $0x8,%esp
  8011dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011e0:	ba 48 27 80 00       	mov    $0x802748,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011e5:	eb 13                	jmp    8011fa <dev_lookup+0x23>
  8011e7:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011ea:	39 08                	cmp    %ecx,(%eax)
  8011ec:	75 0c                	jne    8011fa <dev_lookup+0x23>
			*dev = devtab[i];
  8011ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f8:	eb 2e                	jmp    801228 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011fa:	8b 02                	mov    (%edx),%eax
  8011fc:	85 c0                	test   %eax,%eax
  8011fe:	75 e7                	jne    8011e7 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801200:	a1 08 40 80 00       	mov    0x804008,%eax
  801205:	8b 40 50             	mov    0x50(%eax),%eax
  801208:	83 ec 04             	sub    $0x4,%esp
  80120b:	51                   	push   %ecx
  80120c:	50                   	push   %eax
  80120d:	68 c8 26 80 00       	push   $0x8026c8
  801212:	e8 73 f0 ff ff       	call   80028a <cprintf>
	*dev = 0;
  801217:	8b 45 0c             	mov    0xc(%ebp),%eax
  80121a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801220:	83 c4 10             	add    $0x10,%esp
  801223:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801228:	c9                   	leave  
  801229:	c3                   	ret    

0080122a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80122a:	55                   	push   %ebp
  80122b:	89 e5                	mov    %esp,%ebp
  80122d:	56                   	push   %esi
  80122e:	53                   	push   %ebx
  80122f:	83 ec 10             	sub    $0x10,%esp
  801232:	8b 75 08             	mov    0x8(%ebp),%esi
  801235:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801238:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123b:	50                   	push   %eax
  80123c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801242:	c1 e8 0c             	shr    $0xc,%eax
  801245:	50                   	push   %eax
  801246:	e8 36 ff ff ff       	call   801181 <fd_lookup>
  80124b:	83 c4 08             	add    $0x8,%esp
  80124e:	85 c0                	test   %eax,%eax
  801250:	78 05                	js     801257 <fd_close+0x2d>
	    || fd != fd2)
  801252:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801255:	74 0c                	je     801263 <fd_close+0x39>
		return (must_exist ? r : 0);
  801257:	84 db                	test   %bl,%bl
  801259:	ba 00 00 00 00       	mov    $0x0,%edx
  80125e:	0f 44 c2             	cmove  %edx,%eax
  801261:	eb 41                	jmp    8012a4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801263:	83 ec 08             	sub    $0x8,%esp
  801266:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801269:	50                   	push   %eax
  80126a:	ff 36                	pushl  (%esi)
  80126c:	e8 66 ff ff ff       	call   8011d7 <dev_lookup>
  801271:	89 c3                	mov    %eax,%ebx
  801273:	83 c4 10             	add    $0x10,%esp
  801276:	85 c0                	test   %eax,%eax
  801278:	78 1a                	js     801294 <fd_close+0x6a>
		if (dev->dev_close)
  80127a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801280:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801285:	85 c0                	test   %eax,%eax
  801287:	74 0b                	je     801294 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801289:	83 ec 0c             	sub    $0xc,%esp
  80128c:	56                   	push   %esi
  80128d:	ff d0                	call   *%eax
  80128f:	89 c3                	mov    %eax,%ebx
  801291:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801294:	83 ec 08             	sub    $0x8,%esp
  801297:	56                   	push   %esi
  801298:	6a 00                	push   $0x0
  80129a:	e8 f8 f9 ff ff       	call   800c97 <sys_page_unmap>
	return r;
  80129f:	83 c4 10             	add    $0x10,%esp
  8012a2:	89 d8                	mov    %ebx,%eax
}
  8012a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012a7:	5b                   	pop    %ebx
  8012a8:	5e                   	pop    %esi
  8012a9:	5d                   	pop    %ebp
  8012aa:	c3                   	ret    

008012ab <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012ab:	55                   	push   %ebp
  8012ac:	89 e5                	mov    %esp,%ebp
  8012ae:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b4:	50                   	push   %eax
  8012b5:	ff 75 08             	pushl  0x8(%ebp)
  8012b8:	e8 c4 fe ff ff       	call   801181 <fd_lookup>
  8012bd:	83 c4 08             	add    $0x8,%esp
  8012c0:	85 c0                	test   %eax,%eax
  8012c2:	78 10                	js     8012d4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012c4:	83 ec 08             	sub    $0x8,%esp
  8012c7:	6a 01                	push   $0x1
  8012c9:	ff 75 f4             	pushl  -0xc(%ebp)
  8012cc:	e8 59 ff ff ff       	call   80122a <fd_close>
  8012d1:	83 c4 10             	add    $0x10,%esp
}
  8012d4:	c9                   	leave  
  8012d5:	c3                   	ret    

008012d6 <close_all>:

void
close_all(void)
{
  8012d6:	55                   	push   %ebp
  8012d7:	89 e5                	mov    %esp,%ebp
  8012d9:	53                   	push   %ebx
  8012da:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012dd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012e2:	83 ec 0c             	sub    $0xc,%esp
  8012e5:	53                   	push   %ebx
  8012e6:	e8 c0 ff ff ff       	call   8012ab <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012eb:	83 c3 01             	add    $0x1,%ebx
  8012ee:	83 c4 10             	add    $0x10,%esp
  8012f1:	83 fb 20             	cmp    $0x20,%ebx
  8012f4:	75 ec                	jne    8012e2 <close_all+0xc>
		close(i);
}
  8012f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f9:	c9                   	leave  
  8012fa:	c3                   	ret    

008012fb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012fb:	55                   	push   %ebp
  8012fc:	89 e5                	mov    %esp,%ebp
  8012fe:	57                   	push   %edi
  8012ff:	56                   	push   %esi
  801300:	53                   	push   %ebx
  801301:	83 ec 2c             	sub    $0x2c,%esp
  801304:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801307:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80130a:	50                   	push   %eax
  80130b:	ff 75 08             	pushl  0x8(%ebp)
  80130e:	e8 6e fe ff ff       	call   801181 <fd_lookup>
  801313:	83 c4 08             	add    $0x8,%esp
  801316:	85 c0                	test   %eax,%eax
  801318:	0f 88 c1 00 00 00    	js     8013df <dup+0xe4>
		return r;
	close(newfdnum);
  80131e:	83 ec 0c             	sub    $0xc,%esp
  801321:	56                   	push   %esi
  801322:	e8 84 ff ff ff       	call   8012ab <close>

	newfd = INDEX2FD(newfdnum);
  801327:	89 f3                	mov    %esi,%ebx
  801329:	c1 e3 0c             	shl    $0xc,%ebx
  80132c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801332:	83 c4 04             	add    $0x4,%esp
  801335:	ff 75 e4             	pushl  -0x1c(%ebp)
  801338:	e8 de fd ff ff       	call   80111b <fd2data>
  80133d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80133f:	89 1c 24             	mov    %ebx,(%esp)
  801342:	e8 d4 fd ff ff       	call   80111b <fd2data>
  801347:	83 c4 10             	add    $0x10,%esp
  80134a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80134d:	89 f8                	mov    %edi,%eax
  80134f:	c1 e8 16             	shr    $0x16,%eax
  801352:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801359:	a8 01                	test   $0x1,%al
  80135b:	74 37                	je     801394 <dup+0x99>
  80135d:	89 f8                	mov    %edi,%eax
  80135f:	c1 e8 0c             	shr    $0xc,%eax
  801362:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801369:	f6 c2 01             	test   $0x1,%dl
  80136c:	74 26                	je     801394 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80136e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801375:	83 ec 0c             	sub    $0xc,%esp
  801378:	25 07 0e 00 00       	and    $0xe07,%eax
  80137d:	50                   	push   %eax
  80137e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801381:	6a 00                	push   $0x0
  801383:	57                   	push   %edi
  801384:	6a 00                	push   $0x0
  801386:	e8 ca f8 ff ff       	call   800c55 <sys_page_map>
  80138b:	89 c7                	mov    %eax,%edi
  80138d:	83 c4 20             	add    $0x20,%esp
  801390:	85 c0                	test   %eax,%eax
  801392:	78 2e                	js     8013c2 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801394:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801397:	89 d0                	mov    %edx,%eax
  801399:	c1 e8 0c             	shr    $0xc,%eax
  80139c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013a3:	83 ec 0c             	sub    $0xc,%esp
  8013a6:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ab:	50                   	push   %eax
  8013ac:	53                   	push   %ebx
  8013ad:	6a 00                	push   $0x0
  8013af:	52                   	push   %edx
  8013b0:	6a 00                	push   $0x0
  8013b2:	e8 9e f8 ff ff       	call   800c55 <sys_page_map>
  8013b7:	89 c7                	mov    %eax,%edi
  8013b9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013bc:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013be:	85 ff                	test   %edi,%edi
  8013c0:	79 1d                	jns    8013df <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013c2:	83 ec 08             	sub    $0x8,%esp
  8013c5:	53                   	push   %ebx
  8013c6:	6a 00                	push   $0x0
  8013c8:	e8 ca f8 ff ff       	call   800c97 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013cd:	83 c4 08             	add    $0x8,%esp
  8013d0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013d3:	6a 00                	push   $0x0
  8013d5:	e8 bd f8 ff ff       	call   800c97 <sys_page_unmap>
	return r;
  8013da:	83 c4 10             	add    $0x10,%esp
  8013dd:	89 f8                	mov    %edi,%eax
}
  8013df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e2:	5b                   	pop    %ebx
  8013e3:	5e                   	pop    %esi
  8013e4:	5f                   	pop    %edi
  8013e5:	5d                   	pop    %ebp
  8013e6:	c3                   	ret    

008013e7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013e7:	55                   	push   %ebp
  8013e8:	89 e5                	mov    %esp,%ebp
  8013ea:	53                   	push   %ebx
  8013eb:	83 ec 14             	sub    $0x14,%esp
  8013ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013f4:	50                   	push   %eax
  8013f5:	53                   	push   %ebx
  8013f6:	e8 86 fd ff ff       	call   801181 <fd_lookup>
  8013fb:	83 c4 08             	add    $0x8,%esp
  8013fe:	89 c2                	mov    %eax,%edx
  801400:	85 c0                	test   %eax,%eax
  801402:	78 6d                	js     801471 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801404:	83 ec 08             	sub    $0x8,%esp
  801407:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80140a:	50                   	push   %eax
  80140b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140e:	ff 30                	pushl  (%eax)
  801410:	e8 c2 fd ff ff       	call   8011d7 <dev_lookup>
  801415:	83 c4 10             	add    $0x10,%esp
  801418:	85 c0                	test   %eax,%eax
  80141a:	78 4c                	js     801468 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80141c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80141f:	8b 42 08             	mov    0x8(%edx),%eax
  801422:	83 e0 03             	and    $0x3,%eax
  801425:	83 f8 01             	cmp    $0x1,%eax
  801428:	75 21                	jne    80144b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80142a:	a1 08 40 80 00       	mov    0x804008,%eax
  80142f:	8b 40 50             	mov    0x50(%eax),%eax
  801432:	83 ec 04             	sub    $0x4,%esp
  801435:	53                   	push   %ebx
  801436:	50                   	push   %eax
  801437:	68 0c 27 80 00       	push   $0x80270c
  80143c:	e8 49 ee ff ff       	call   80028a <cprintf>
		return -E_INVAL;
  801441:	83 c4 10             	add    $0x10,%esp
  801444:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801449:	eb 26                	jmp    801471 <read+0x8a>
	}
	if (!dev->dev_read)
  80144b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80144e:	8b 40 08             	mov    0x8(%eax),%eax
  801451:	85 c0                	test   %eax,%eax
  801453:	74 17                	je     80146c <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801455:	83 ec 04             	sub    $0x4,%esp
  801458:	ff 75 10             	pushl  0x10(%ebp)
  80145b:	ff 75 0c             	pushl  0xc(%ebp)
  80145e:	52                   	push   %edx
  80145f:	ff d0                	call   *%eax
  801461:	89 c2                	mov    %eax,%edx
  801463:	83 c4 10             	add    $0x10,%esp
  801466:	eb 09                	jmp    801471 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801468:	89 c2                	mov    %eax,%edx
  80146a:	eb 05                	jmp    801471 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80146c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801471:	89 d0                	mov    %edx,%eax
  801473:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801476:	c9                   	leave  
  801477:	c3                   	ret    

00801478 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801478:	55                   	push   %ebp
  801479:	89 e5                	mov    %esp,%ebp
  80147b:	57                   	push   %edi
  80147c:	56                   	push   %esi
  80147d:	53                   	push   %ebx
  80147e:	83 ec 0c             	sub    $0xc,%esp
  801481:	8b 7d 08             	mov    0x8(%ebp),%edi
  801484:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801487:	bb 00 00 00 00       	mov    $0x0,%ebx
  80148c:	eb 21                	jmp    8014af <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80148e:	83 ec 04             	sub    $0x4,%esp
  801491:	89 f0                	mov    %esi,%eax
  801493:	29 d8                	sub    %ebx,%eax
  801495:	50                   	push   %eax
  801496:	89 d8                	mov    %ebx,%eax
  801498:	03 45 0c             	add    0xc(%ebp),%eax
  80149b:	50                   	push   %eax
  80149c:	57                   	push   %edi
  80149d:	e8 45 ff ff ff       	call   8013e7 <read>
		if (m < 0)
  8014a2:	83 c4 10             	add    $0x10,%esp
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	78 10                	js     8014b9 <readn+0x41>
			return m;
		if (m == 0)
  8014a9:	85 c0                	test   %eax,%eax
  8014ab:	74 0a                	je     8014b7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ad:	01 c3                	add    %eax,%ebx
  8014af:	39 f3                	cmp    %esi,%ebx
  8014b1:	72 db                	jb     80148e <readn+0x16>
  8014b3:	89 d8                	mov    %ebx,%eax
  8014b5:	eb 02                	jmp    8014b9 <readn+0x41>
  8014b7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014bc:	5b                   	pop    %ebx
  8014bd:	5e                   	pop    %esi
  8014be:	5f                   	pop    %edi
  8014bf:	5d                   	pop    %ebp
  8014c0:	c3                   	ret    

008014c1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014c1:	55                   	push   %ebp
  8014c2:	89 e5                	mov    %esp,%ebp
  8014c4:	53                   	push   %ebx
  8014c5:	83 ec 14             	sub    $0x14,%esp
  8014c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ce:	50                   	push   %eax
  8014cf:	53                   	push   %ebx
  8014d0:	e8 ac fc ff ff       	call   801181 <fd_lookup>
  8014d5:	83 c4 08             	add    $0x8,%esp
  8014d8:	89 c2                	mov    %eax,%edx
  8014da:	85 c0                	test   %eax,%eax
  8014dc:	78 68                	js     801546 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014de:	83 ec 08             	sub    $0x8,%esp
  8014e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e4:	50                   	push   %eax
  8014e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e8:	ff 30                	pushl  (%eax)
  8014ea:	e8 e8 fc ff ff       	call   8011d7 <dev_lookup>
  8014ef:	83 c4 10             	add    $0x10,%esp
  8014f2:	85 c0                	test   %eax,%eax
  8014f4:	78 47                	js     80153d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014fd:	75 21                	jne    801520 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ff:	a1 08 40 80 00       	mov    0x804008,%eax
  801504:	8b 40 50             	mov    0x50(%eax),%eax
  801507:	83 ec 04             	sub    $0x4,%esp
  80150a:	53                   	push   %ebx
  80150b:	50                   	push   %eax
  80150c:	68 28 27 80 00       	push   $0x802728
  801511:	e8 74 ed ff ff       	call   80028a <cprintf>
		return -E_INVAL;
  801516:	83 c4 10             	add    $0x10,%esp
  801519:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80151e:	eb 26                	jmp    801546 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801520:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801523:	8b 52 0c             	mov    0xc(%edx),%edx
  801526:	85 d2                	test   %edx,%edx
  801528:	74 17                	je     801541 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80152a:	83 ec 04             	sub    $0x4,%esp
  80152d:	ff 75 10             	pushl  0x10(%ebp)
  801530:	ff 75 0c             	pushl  0xc(%ebp)
  801533:	50                   	push   %eax
  801534:	ff d2                	call   *%edx
  801536:	89 c2                	mov    %eax,%edx
  801538:	83 c4 10             	add    $0x10,%esp
  80153b:	eb 09                	jmp    801546 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153d:	89 c2                	mov    %eax,%edx
  80153f:	eb 05                	jmp    801546 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801541:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801546:	89 d0                	mov    %edx,%eax
  801548:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80154b:	c9                   	leave  
  80154c:	c3                   	ret    

0080154d <seek>:

int
seek(int fdnum, off_t offset)
{
  80154d:	55                   	push   %ebp
  80154e:	89 e5                	mov    %esp,%ebp
  801550:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801553:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801556:	50                   	push   %eax
  801557:	ff 75 08             	pushl  0x8(%ebp)
  80155a:	e8 22 fc ff ff       	call   801181 <fd_lookup>
  80155f:	83 c4 08             	add    $0x8,%esp
  801562:	85 c0                	test   %eax,%eax
  801564:	78 0e                	js     801574 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801566:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801569:	8b 55 0c             	mov    0xc(%ebp),%edx
  80156c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80156f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801574:	c9                   	leave  
  801575:	c3                   	ret    

00801576 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801576:	55                   	push   %ebp
  801577:	89 e5                	mov    %esp,%ebp
  801579:	53                   	push   %ebx
  80157a:	83 ec 14             	sub    $0x14,%esp
  80157d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801580:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801583:	50                   	push   %eax
  801584:	53                   	push   %ebx
  801585:	e8 f7 fb ff ff       	call   801181 <fd_lookup>
  80158a:	83 c4 08             	add    $0x8,%esp
  80158d:	89 c2                	mov    %eax,%edx
  80158f:	85 c0                	test   %eax,%eax
  801591:	78 65                	js     8015f8 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801593:	83 ec 08             	sub    $0x8,%esp
  801596:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801599:	50                   	push   %eax
  80159a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159d:	ff 30                	pushl  (%eax)
  80159f:	e8 33 fc ff ff       	call   8011d7 <dev_lookup>
  8015a4:	83 c4 10             	add    $0x10,%esp
  8015a7:	85 c0                	test   %eax,%eax
  8015a9:	78 44                	js     8015ef <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ae:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015b2:	75 21                	jne    8015d5 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015b4:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015b9:	8b 40 50             	mov    0x50(%eax),%eax
  8015bc:	83 ec 04             	sub    $0x4,%esp
  8015bf:	53                   	push   %ebx
  8015c0:	50                   	push   %eax
  8015c1:	68 e8 26 80 00       	push   $0x8026e8
  8015c6:	e8 bf ec ff ff       	call   80028a <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015cb:	83 c4 10             	add    $0x10,%esp
  8015ce:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015d3:	eb 23                	jmp    8015f8 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d8:	8b 52 18             	mov    0x18(%edx),%edx
  8015db:	85 d2                	test   %edx,%edx
  8015dd:	74 14                	je     8015f3 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015df:	83 ec 08             	sub    $0x8,%esp
  8015e2:	ff 75 0c             	pushl  0xc(%ebp)
  8015e5:	50                   	push   %eax
  8015e6:	ff d2                	call   *%edx
  8015e8:	89 c2                	mov    %eax,%edx
  8015ea:	83 c4 10             	add    $0x10,%esp
  8015ed:	eb 09                	jmp    8015f8 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ef:	89 c2                	mov    %eax,%edx
  8015f1:	eb 05                	jmp    8015f8 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015f3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015f8:	89 d0                	mov    %edx,%eax
  8015fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015fd:	c9                   	leave  
  8015fe:	c3                   	ret    

008015ff <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015ff:	55                   	push   %ebp
  801600:	89 e5                	mov    %esp,%ebp
  801602:	53                   	push   %ebx
  801603:	83 ec 14             	sub    $0x14,%esp
  801606:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801609:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80160c:	50                   	push   %eax
  80160d:	ff 75 08             	pushl  0x8(%ebp)
  801610:	e8 6c fb ff ff       	call   801181 <fd_lookup>
  801615:	83 c4 08             	add    $0x8,%esp
  801618:	89 c2                	mov    %eax,%edx
  80161a:	85 c0                	test   %eax,%eax
  80161c:	78 58                	js     801676 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161e:	83 ec 08             	sub    $0x8,%esp
  801621:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801624:	50                   	push   %eax
  801625:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801628:	ff 30                	pushl  (%eax)
  80162a:	e8 a8 fb ff ff       	call   8011d7 <dev_lookup>
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	85 c0                	test   %eax,%eax
  801634:	78 37                	js     80166d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801636:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801639:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80163d:	74 32                	je     801671 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80163f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801642:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801649:	00 00 00 
	stat->st_isdir = 0;
  80164c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801653:	00 00 00 
	stat->st_dev = dev;
  801656:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80165c:	83 ec 08             	sub    $0x8,%esp
  80165f:	53                   	push   %ebx
  801660:	ff 75 f0             	pushl  -0x10(%ebp)
  801663:	ff 50 14             	call   *0x14(%eax)
  801666:	89 c2                	mov    %eax,%edx
  801668:	83 c4 10             	add    $0x10,%esp
  80166b:	eb 09                	jmp    801676 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166d:	89 c2                	mov    %eax,%edx
  80166f:	eb 05                	jmp    801676 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801671:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801676:	89 d0                	mov    %edx,%eax
  801678:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167b:	c9                   	leave  
  80167c:	c3                   	ret    

0080167d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80167d:	55                   	push   %ebp
  80167e:	89 e5                	mov    %esp,%ebp
  801680:	56                   	push   %esi
  801681:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801682:	83 ec 08             	sub    $0x8,%esp
  801685:	6a 00                	push   $0x0
  801687:	ff 75 08             	pushl  0x8(%ebp)
  80168a:	e8 e3 01 00 00       	call   801872 <open>
  80168f:	89 c3                	mov    %eax,%ebx
  801691:	83 c4 10             	add    $0x10,%esp
  801694:	85 c0                	test   %eax,%eax
  801696:	78 1b                	js     8016b3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801698:	83 ec 08             	sub    $0x8,%esp
  80169b:	ff 75 0c             	pushl  0xc(%ebp)
  80169e:	50                   	push   %eax
  80169f:	e8 5b ff ff ff       	call   8015ff <fstat>
  8016a4:	89 c6                	mov    %eax,%esi
	close(fd);
  8016a6:	89 1c 24             	mov    %ebx,(%esp)
  8016a9:	e8 fd fb ff ff       	call   8012ab <close>
	return r;
  8016ae:	83 c4 10             	add    $0x10,%esp
  8016b1:	89 f0                	mov    %esi,%eax
}
  8016b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016b6:	5b                   	pop    %ebx
  8016b7:	5e                   	pop    %esi
  8016b8:	5d                   	pop    %ebp
  8016b9:	c3                   	ret    

008016ba <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016ba:	55                   	push   %ebp
  8016bb:	89 e5                	mov    %esp,%ebp
  8016bd:	56                   	push   %esi
  8016be:	53                   	push   %ebx
  8016bf:	89 c6                	mov    %eax,%esi
  8016c1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016c3:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016ca:	75 12                	jne    8016de <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016cc:	83 ec 0c             	sub    $0xc,%esp
  8016cf:	6a 01                	push   $0x1
  8016d1:	e8 85 08 00 00       	call   801f5b <ipc_find_env>
  8016d6:	a3 00 40 80 00       	mov    %eax,0x804000
  8016db:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016de:	6a 07                	push   $0x7
  8016e0:	68 00 50 80 00       	push   $0x805000
  8016e5:	56                   	push   %esi
  8016e6:	ff 35 00 40 80 00    	pushl  0x804000
  8016ec:	e8 08 08 00 00       	call   801ef9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016f1:	83 c4 0c             	add    $0xc,%esp
  8016f4:	6a 00                	push   $0x0
  8016f6:	53                   	push   %ebx
  8016f7:	6a 00                	push   $0x0
  8016f9:	e8 86 07 00 00       	call   801e84 <ipc_recv>
}
  8016fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801701:	5b                   	pop    %ebx
  801702:	5e                   	pop    %esi
  801703:	5d                   	pop    %ebp
  801704:	c3                   	ret    

00801705 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801705:	55                   	push   %ebp
  801706:	89 e5                	mov    %esp,%ebp
  801708:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80170b:	8b 45 08             	mov    0x8(%ebp),%eax
  80170e:	8b 40 0c             	mov    0xc(%eax),%eax
  801711:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801716:	8b 45 0c             	mov    0xc(%ebp),%eax
  801719:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80171e:	ba 00 00 00 00       	mov    $0x0,%edx
  801723:	b8 02 00 00 00       	mov    $0x2,%eax
  801728:	e8 8d ff ff ff       	call   8016ba <fsipc>
}
  80172d:	c9                   	leave  
  80172e:	c3                   	ret    

0080172f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80172f:	55                   	push   %ebp
  801730:	89 e5                	mov    %esp,%ebp
  801732:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801735:	8b 45 08             	mov    0x8(%ebp),%eax
  801738:	8b 40 0c             	mov    0xc(%eax),%eax
  80173b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801740:	ba 00 00 00 00       	mov    $0x0,%edx
  801745:	b8 06 00 00 00       	mov    $0x6,%eax
  80174a:	e8 6b ff ff ff       	call   8016ba <fsipc>
}
  80174f:	c9                   	leave  
  801750:	c3                   	ret    

00801751 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801751:	55                   	push   %ebp
  801752:	89 e5                	mov    %esp,%ebp
  801754:	53                   	push   %ebx
  801755:	83 ec 04             	sub    $0x4,%esp
  801758:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80175b:	8b 45 08             	mov    0x8(%ebp),%eax
  80175e:	8b 40 0c             	mov    0xc(%eax),%eax
  801761:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801766:	ba 00 00 00 00       	mov    $0x0,%edx
  80176b:	b8 05 00 00 00       	mov    $0x5,%eax
  801770:	e8 45 ff ff ff       	call   8016ba <fsipc>
  801775:	85 c0                	test   %eax,%eax
  801777:	78 2c                	js     8017a5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801779:	83 ec 08             	sub    $0x8,%esp
  80177c:	68 00 50 80 00       	push   $0x805000
  801781:	53                   	push   %ebx
  801782:	e8 88 f0 ff ff       	call   80080f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801787:	a1 80 50 80 00       	mov    0x805080,%eax
  80178c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801792:	a1 84 50 80 00       	mov    0x805084,%eax
  801797:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80179d:	83 c4 10             	add    $0x10,%esp
  8017a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a8:	c9                   	leave  
  8017a9:	c3                   	ret    

008017aa <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017aa:	55                   	push   %ebp
  8017ab:	89 e5                	mov    %esp,%ebp
  8017ad:	83 ec 0c             	sub    $0xc,%esp
  8017b0:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8017b6:	8b 52 0c             	mov    0xc(%edx),%edx
  8017b9:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8017bf:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017c4:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017c9:	0f 47 c2             	cmova  %edx,%eax
  8017cc:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8017d1:	50                   	push   %eax
  8017d2:	ff 75 0c             	pushl  0xc(%ebp)
  8017d5:	68 08 50 80 00       	push   $0x805008
  8017da:	e8 c2 f1 ff ff       	call   8009a1 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8017df:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e4:	b8 04 00 00 00       	mov    $0x4,%eax
  8017e9:	e8 cc fe ff ff       	call   8016ba <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8017ee:	c9                   	leave  
  8017ef:	c3                   	ret    

008017f0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
  8017f3:	56                   	push   %esi
  8017f4:	53                   	push   %ebx
  8017f5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8017fe:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801803:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801809:	ba 00 00 00 00       	mov    $0x0,%edx
  80180e:	b8 03 00 00 00       	mov    $0x3,%eax
  801813:	e8 a2 fe ff ff       	call   8016ba <fsipc>
  801818:	89 c3                	mov    %eax,%ebx
  80181a:	85 c0                	test   %eax,%eax
  80181c:	78 4b                	js     801869 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80181e:	39 c6                	cmp    %eax,%esi
  801820:	73 16                	jae    801838 <devfile_read+0x48>
  801822:	68 58 27 80 00       	push   $0x802758
  801827:	68 5f 27 80 00       	push   $0x80275f
  80182c:	6a 7c                	push   $0x7c
  80182e:	68 74 27 80 00       	push   $0x802774
  801833:	e8 79 e9 ff ff       	call   8001b1 <_panic>
	assert(r <= PGSIZE);
  801838:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80183d:	7e 16                	jle    801855 <devfile_read+0x65>
  80183f:	68 7f 27 80 00       	push   $0x80277f
  801844:	68 5f 27 80 00       	push   $0x80275f
  801849:	6a 7d                	push   $0x7d
  80184b:	68 74 27 80 00       	push   $0x802774
  801850:	e8 5c e9 ff ff       	call   8001b1 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801855:	83 ec 04             	sub    $0x4,%esp
  801858:	50                   	push   %eax
  801859:	68 00 50 80 00       	push   $0x805000
  80185e:	ff 75 0c             	pushl  0xc(%ebp)
  801861:	e8 3b f1 ff ff       	call   8009a1 <memmove>
	return r;
  801866:	83 c4 10             	add    $0x10,%esp
}
  801869:	89 d8                	mov    %ebx,%eax
  80186b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80186e:	5b                   	pop    %ebx
  80186f:	5e                   	pop    %esi
  801870:	5d                   	pop    %ebp
  801871:	c3                   	ret    

00801872 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	53                   	push   %ebx
  801876:	83 ec 20             	sub    $0x20,%esp
  801879:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80187c:	53                   	push   %ebx
  80187d:	e8 54 ef ff ff       	call   8007d6 <strlen>
  801882:	83 c4 10             	add    $0x10,%esp
  801885:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80188a:	7f 67                	jg     8018f3 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80188c:	83 ec 0c             	sub    $0xc,%esp
  80188f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801892:	50                   	push   %eax
  801893:	e8 9a f8 ff ff       	call   801132 <fd_alloc>
  801898:	83 c4 10             	add    $0x10,%esp
		return r;
  80189b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80189d:	85 c0                	test   %eax,%eax
  80189f:	78 57                	js     8018f8 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018a1:	83 ec 08             	sub    $0x8,%esp
  8018a4:	53                   	push   %ebx
  8018a5:	68 00 50 80 00       	push   $0x805000
  8018aa:	e8 60 ef ff ff       	call   80080f <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b2:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8018bf:	e8 f6 fd ff ff       	call   8016ba <fsipc>
  8018c4:	89 c3                	mov    %eax,%ebx
  8018c6:	83 c4 10             	add    $0x10,%esp
  8018c9:	85 c0                	test   %eax,%eax
  8018cb:	79 14                	jns    8018e1 <open+0x6f>
		fd_close(fd, 0);
  8018cd:	83 ec 08             	sub    $0x8,%esp
  8018d0:	6a 00                	push   $0x0
  8018d2:	ff 75 f4             	pushl  -0xc(%ebp)
  8018d5:	e8 50 f9 ff ff       	call   80122a <fd_close>
		return r;
  8018da:	83 c4 10             	add    $0x10,%esp
  8018dd:	89 da                	mov    %ebx,%edx
  8018df:	eb 17                	jmp    8018f8 <open+0x86>
	}

	return fd2num(fd);
  8018e1:	83 ec 0c             	sub    $0xc,%esp
  8018e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e7:	e8 1f f8 ff ff       	call   80110b <fd2num>
  8018ec:	89 c2                	mov    %eax,%edx
  8018ee:	83 c4 10             	add    $0x10,%esp
  8018f1:	eb 05                	jmp    8018f8 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018f3:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018f8:	89 d0                	mov    %edx,%eax
  8018fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018fd:	c9                   	leave  
  8018fe:	c3                   	ret    

008018ff <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801905:	ba 00 00 00 00       	mov    $0x0,%edx
  80190a:	b8 08 00 00 00       	mov    $0x8,%eax
  80190f:	e8 a6 fd ff ff       	call   8016ba <fsipc>
}
  801914:	c9                   	leave  
  801915:	c3                   	ret    

00801916 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	56                   	push   %esi
  80191a:	53                   	push   %ebx
  80191b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80191e:	83 ec 0c             	sub    $0xc,%esp
  801921:	ff 75 08             	pushl  0x8(%ebp)
  801924:	e8 f2 f7 ff ff       	call   80111b <fd2data>
  801929:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80192b:	83 c4 08             	add    $0x8,%esp
  80192e:	68 8b 27 80 00       	push   $0x80278b
  801933:	53                   	push   %ebx
  801934:	e8 d6 ee ff ff       	call   80080f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801939:	8b 46 04             	mov    0x4(%esi),%eax
  80193c:	2b 06                	sub    (%esi),%eax
  80193e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801944:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80194b:	00 00 00 
	stat->st_dev = &devpipe;
  80194e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801955:	30 80 00 
	return 0;
}
  801958:	b8 00 00 00 00       	mov    $0x0,%eax
  80195d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801960:	5b                   	pop    %ebx
  801961:	5e                   	pop    %esi
  801962:	5d                   	pop    %ebp
  801963:	c3                   	ret    

00801964 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	53                   	push   %ebx
  801968:	83 ec 0c             	sub    $0xc,%esp
  80196b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80196e:	53                   	push   %ebx
  80196f:	6a 00                	push   $0x0
  801971:	e8 21 f3 ff ff       	call   800c97 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801976:	89 1c 24             	mov    %ebx,(%esp)
  801979:	e8 9d f7 ff ff       	call   80111b <fd2data>
  80197e:	83 c4 08             	add    $0x8,%esp
  801981:	50                   	push   %eax
  801982:	6a 00                	push   $0x0
  801984:	e8 0e f3 ff ff       	call   800c97 <sys_page_unmap>
}
  801989:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198c:	c9                   	leave  
  80198d:	c3                   	ret    

0080198e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80198e:	55                   	push   %ebp
  80198f:	89 e5                	mov    %esp,%ebp
  801991:	57                   	push   %edi
  801992:	56                   	push   %esi
  801993:	53                   	push   %ebx
  801994:	83 ec 1c             	sub    $0x1c,%esp
  801997:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80199a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80199c:	a1 08 40 80 00       	mov    0x804008,%eax
  8019a1:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019a4:	83 ec 0c             	sub    $0xc,%esp
  8019a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8019aa:	e8 ec 05 00 00       	call   801f9b <pageref>
  8019af:	89 c3                	mov    %eax,%ebx
  8019b1:	89 3c 24             	mov    %edi,(%esp)
  8019b4:	e8 e2 05 00 00       	call   801f9b <pageref>
  8019b9:	83 c4 10             	add    $0x10,%esp
  8019bc:	39 c3                	cmp    %eax,%ebx
  8019be:	0f 94 c1             	sete   %cl
  8019c1:	0f b6 c9             	movzbl %cl,%ecx
  8019c4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019c7:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8019cd:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  8019d0:	39 ce                	cmp    %ecx,%esi
  8019d2:	74 1b                	je     8019ef <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8019d4:	39 c3                	cmp    %eax,%ebx
  8019d6:	75 c4                	jne    80199c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019d8:	8b 42 60             	mov    0x60(%edx),%eax
  8019db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019de:	50                   	push   %eax
  8019df:	56                   	push   %esi
  8019e0:	68 92 27 80 00       	push   $0x802792
  8019e5:	e8 a0 e8 ff ff       	call   80028a <cprintf>
  8019ea:	83 c4 10             	add    $0x10,%esp
  8019ed:	eb ad                	jmp    80199c <_pipeisclosed+0xe>
	}
}
  8019ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019f5:	5b                   	pop    %ebx
  8019f6:	5e                   	pop    %esi
  8019f7:	5f                   	pop    %edi
  8019f8:	5d                   	pop    %ebp
  8019f9:	c3                   	ret    

008019fa <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019fa:	55                   	push   %ebp
  8019fb:	89 e5                	mov    %esp,%ebp
  8019fd:	57                   	push   %edi
  8019fe:	56                   	push   %esi
  8019ff:	53                   	push   %ebx
  801a00:	83 ec 28             	sub    $0x28,%esp
  801a03:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a06:	56                   	push   %esi
  801a07:	e8 0f f7 ff ff       	call   80111b <fd2data>
  801a0c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a0e:	83 c4 10             	add    $0x10,%esp
  801a11:	bf 00 00 00 00       	mov    $0x0,%edi
  801a16:	eb 4b                	jmp    801a63 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a18:	89 da                	mov    %ebx,%edx
  801a1a:	89 f0                	mov    %esi,%eax
  801a1c:	e8 6d ff ff ff       	call   80198e <_pipeisclosed>
  801a21:	85 c0                	test   %eax,%eax
  801a23:	75 48                	jne    801a6d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a25:	e8 c9 f1 ff ff       	call   800bf3 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a2a:	8b 43 04             	mov    0x4(%ebx),%eax
  801a2d:	8b 0b                	mov    (%ebx),%ecx
  801a2f:	8d 51 20             	lea    0x20(%ecx),%edx
  801a32:	39 d0                	cmp    %edx,%eax
  801a34:	73 e2                	jae    801a18 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a39:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a3d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a40:	89 c2                	mov    %eax,%edx
  801a42:	c1 fa 1f             	sar    $0x1f,%edx
  801a45:	89 d1                	mov    %edx,%ecx
  801a47:	c1 e9 1b             	shr    $0x1b,%ecx
  801a4a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a4d:	83 e2 1f             	and    $0x1f,%edx
  801a50:	29 ca                	sub    %ecx,%edx
  801a52:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a56:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a5a:	83 c0 01             	add    $0x1,%eax
  801a5d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a60:	83 c7 01             	add    $0x1,%edi
  801a63:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a66:	75 c2                	jne    801a2a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a68:	8b 45 10             	mov    0x10(%ebp),%eax
  801a6b:	eb 05                	jmp    801a72 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a6d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a75:	5b                   	pop    %ebx
  801a76:	5e                   	pop    %esi
  801a77:	5f                   	pop    %edi
  801a78:	5d                   	pop    %ebp
  801a79:	c3                   	ret    

00801a7a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a7a:	55                   	push   %ebp
  801a7b:	89 e5                	mov    %esp,%ebp
  801a7d:	57                   	push   %edi
  801a7e:	56                   	push   %esi
  801a7f:	53                   	push   %ebx
  801a80:	83 ec 18             	sub    $0x18,%esp
  801a83:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a86:	57                   	push   %edi
  801a87:	e8 8f f6 ff ff       	call   80111b <fd2data>
  801a8c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a8e:	83 c4 10             	add    $0x10,%esp
  801a91:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a96:	eb 3d                	jmp    801ad5 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a98:	85 db                	test   %ebx,%ebx
  801a9a:	74 04                	je     801aa0 <devpipe_read+0x26>
				return i;
  801a9c:	89 d8                	mov    %ebx,%eax
  801a9e:	eb 44                	jmp    801ae4 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801aa0:	89 f2                	mov    %esi,%edx
  801aa2:	89 f8                	mov    %edi,%eax
  801aa4:	e8 e5 fe ff ff       	call   80198e <_pipeisclosed>
  801aa9:	85 c0                	test   %eax,%eax
  801aab:	75 32                	jne    801adf <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801aad:	e8 41 f1 ff ff       	call   800bf3 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ab2:	8b 06                	mov    (%esi),%eax
  801ab4:	3b 46 04             	cmp    0x4(%esi),%eax
  801ab7:	74 df                	je     801a98 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ab9:	99                   	cltd   
  801aba:	c1 ea 1b             	shr    $0x1b,%edx
  801abd:	01 d0                	add    %edx,%eax
  801abf:	83 e0 1f             	and    $0x1f,%eax
  801ac2:	29 d0                	sub    %edx,%eax
  801ac4:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ac9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801acc:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801acf:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ad2:	83 c3 01             	add    $0x1,%ebx
  801ad5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ad8:	75 d8                	jne    801ab2 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ada:	8b 45 10             	mov    0x10(%ebp),%eax
  801add:	eb 05                	jmp    801ae4 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801adf:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ae4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae7:	5b                   	pop    %ebx
  801ae8:	5e                   	pop    %esi
  801ae9:	5f                   	pop    %edi
  801aea:	5d                   	pop    %ebp
  801aeb:	c3                   	ret    

00801aec <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801aec:	55                   	push   %ebp
  801aed:	89 e5                	mov    %esp,%ebp
  801aef:	56                   	push   %esi
  801af0:	53                   	push   %ebx
  801af1:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801af4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801af7:	50                   	push   %eax
  801af8:	e8 35 f6 ff ff       	call   801132 <fd_alloc>
  801afd:	83 c4 10             	add    $0x10,%esp
  801b00:	89 c2                	mov    %eax,%edx
  801b02:	85 c0                	test   %eax,%eax
  801b04:	0f 88 2c 01 00 00    	js     801c36 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b0a:	83 ec 04             	sub    $0x4,%esp
  801b0d:	68 07 04 00 00       	push   $0x407
  801b12:	ff 75 f4             	pushl  -0xc(%ebp)
  801b15:	6a 00                	push   $0x0
  801b17:	e8 f6 f0 ff ff       	call   800c12 <sys_page_alloc>
  801b1c:	83 c4 10             	add    $0x10,%esp
  801b1f:	89 c2                	mov    %eax,%edx
  801b21:	85 c0                	test   %eax,%eax
  801b23:	0f 88 0d 01 00 00    	js     801c36 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b29:	83 ec 0c             	sub    $0xc,%esp
  801b2c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b2f:	50                   	push   %eax
  801b30:	e8 fd f5 ff ff       	call   801132 <fd_alloc>
  801b35:	89 c3                	mov    %eax,%ebx
  801b37:	83 c4 10             	add    $0x10,%esp
  801b3a:	85 c0                	test   %eax,%eax
  801b3c:	0f 88 e2 00 00 00    	js     801c24 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b42:	83 ec 04             	sub    $0x4,%esp
  801b45:	68 07 04 00 00       	push   $0x407
  801b4a:	ff 75 f0             	pushl  -0x10(%ebp)
  801b4d:	6a 00                	push   $0x0
  801b4f:	e8 be f0 ff ff       	call   800c12 <sys_page_alloc>
  801b54:	89 c3                	mov    %eax,%ebx
  801b56:	83 c4 10             	add    $0x10,%esp
  801b59:	85 c0                	test   %eax,%eax
  801b5b:	0f 88 c3 00 00 00    	js     801c24 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b61:	83 ec 0c             	sub    $0xc,%esp
  801b64:	ff 75 f4             	pushl  -0xc(%ebp)
  801b67:	e8 af f5 ff ff       	call   80111b <fd2data>
  801b6c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b6e:	83 c4 0c             	add    $0xc,%esp
  801b71:	68 07 04 00 00       	push   $0x407
  801b76:	50                   	push   %eax
  801b77:	6a 00                	push   $0x0
  801b79:	e8 94 f0 ff ff       	call   800c12 <sys_page_alloc>
  801b7e:	89 c3                	mov    %eax,%ebx
  801b80:	83 c4 10             	add    $0x10,%esp
  801b83:	85 c0                	test   %eax,%eax
  801b85:	0f 88 89 00 00 00    	js     801c14 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b8b:	83 ec 0c             	sub    $0xc,%esp
  801b8e:	ff 75 f0             	pushl  -0x10(%ebp)
  801b91:	e8 85 f5 ff ff       	call   80111b <fd2data>
  801b96:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b9d:	50                   	push   %eax
  801b9e:	6a 00                	push   $0x0
  801ba0:	56                   	push   %esi
  801ba1:	6a 00                	push   $0x0
  801ba3:	e8 ad f0 ff ff       	call   800c55 <sys_page_map>
  801ba8:	89 c3                	mov    %eax,%ebx
  801baa:	83 c4 20             	add    $0x20,%esp
  801bad:	85 c0                	test   %eax,%eax
  801baf:	78 55                	js     801c06 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bb1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bba:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bbf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bc6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bcf:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801bd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bd4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801bdb:	83 ec 0c             	sub    $0xc,%esp
  801bde:	ff 75 f4             	pushl  -0xc(%ebp)
  801be1:	e8 25 f5 ff ff       	call   80110b <fd2num>
  801be6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801be9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801beb:	83 c4 04             	add    $0x4,%esp
  801bee:	ff 75 f0             	pushl  -0x10(%ebp)
  801bf1:	e8 15 f5 ff ff       	call   80110b <fd2num>
  801bf6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bf9:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801bfc:	83 c4 10             	add    $0x10,%esp
  801bff:	ba 00 00 00 00       	mov    $0x0,%edx
  801c04:	eb 30                	jmp    801c36 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c06:	83 ec 08             	sub    $0x8,%esp
  801c09:	56                   	push   %esi
  801c0a:	6a 00                	push   $0x0
  801c0c:	e8 86 f0 ff ff       	call   800c97 <sys_page_unmap>
  801c11:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c14:	83 ec 08             	sub    $0x8,%esp
  801c17:	ff 75 f0             	pushl  -0x10(%ebp)
  801c1a:	6a 00                	push   $0x0
  801c1c:	e8 76 f0 ff ff       	call   800c97 <sys_page_unmap>
  801c21:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c24:	83 ec 08             	sub    $0x8,%esp
  801c27:	ff 75 f4             	pushl  -0xc(%ebp)
  801c2a:	6a 00                	push   $0x0
  801c2c:	e8 66 f0 ff ff       	call   800c97 <sys_page_unmap>
  801c31:	83 c4 10             	add    $0x10,%esp
  801c34:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c36:	89 d0                	mov    %edx,%eax
  801c38:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c3b:	5b                   	pop    %ebx
  801c3c:	5e                   	pop    %esi
  801c3d:	5d                   	pop    %ebp
  801c3e:	c3                   	ret    

00801c3f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c3f:	55                   	push   %ebp
  801c40:	89 e5                	mov    %esp,%ebp
  801c42:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c45:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c48:	50                   	push   %eax
  801c49:	ff 75 08             	pushl  0x8(%ebp)
  801c4c:	e8 30 f5 ff ff       	call   801181 <fd_lookup>
  801c51:	83 c4 10             	add    $0x10,%esp
  801c54:	85 c0                	test   %eax,%eax
  801c56:	78 18                	js     801c70 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c58:	83 ec 0c             	sub    $0xc,%esp
  801c5b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c5e:	e8 b8 f4 ff ff       	call   80111b <fd2data>
	return _pipeisclosed(fd, p);
  801c63:	89 c2                	mov    %eax,%edx
  801c65:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c68:	e8 21 fd ff ff       	call   80198e <_pipeisclosed>
  801c6d:	83 c4 10             	add    $0x10,%esp
}
  801c70:	c9                   	leave  
  801c71:	c3                   	ret    

00801c72 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c72:	55                   	push   %ebp
  801c73:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c75:	b8 00 00 00 00       	mov    $0x0,%eax
  801c7a:	5d                   	pop    %ebp
  801c7b:	c3                   	ret    

00801c7c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c7c:	55                   	push   %ebp
  801c7d:	89 e5                	mov    %esp,%ebp
  801c7f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c82:	68 aa 27 80 00       	push   $0x8027aa
  801c87:	ff 75 0c             	pushl  0xc(%ebp)
  801c8a:	e8 80 eb ff ff       	call   80080f <strcpy>
	return 0;
}
  801c8f:	b8 00 00 00 00       	mov    $0x0,%eax
  801c94:	c9                   	leave  
  801c95:	c3                   	ret    

00801c96 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c96:	55                   	push   %ebp
  801c97:	89 e5                	mov    %esp,%ebp
  801c99:	57                   	push   %edi
  801c9a:	56                   	push   %esi
  801c9b:	53                   	push   %ebx
  801c9c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ca2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ca7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cad:	eb 2d                	jmp    801cdc <devcons_write+0x46>
		m = n - tot;
  801caf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cb2:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801cb4:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801cb7:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801cbc:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cbf:	83 ec 04             	sub    $0x4,%esp
  801cc2:	53                   	push   %ebx
  801cc3:	03 45 0c             	add    0xc(%ebp),%eax
  801cc6:	50                   	push   %eax
  801cc7:	57                   	push   %edi
  801cc8:	e8 d4 ec ff ff       	call   8009a1 <memmove>
		sys_cputs(buf, m);
  801ccd:	83 c4 08             	add    $0x8,%esp
  801cd0:	53                   	push   %ebx
  801cd1:	57                   	push   %edi
  801cd2:	e8 7f ee ff ff       	call   800b56 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cd7:	01 de                	add    %ebx,%esi
  801cd9:	83 c4 10             	add    $0x10,%esp
  801cdc:	89 f0                	mov    %esi,%eax
  801cde:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ce1:	72 cc                	jb     801caf <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ce3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ce6:	5b                   	pop    %ebx
  801ce7:	5e                   	pop    %esi
  801ce8:	5f                   	pop    %edi
  801ce9:	5d                   	pop    %ebp
  801cea:	c3                   	ret    

00801ceb <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ceb:	55                   	push   %ebp
  801cec:	89 e5                	mov    %esp,%ebp
  801cee:	83 ec 08             	sub    $0x8,%esp
  801cf1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801cf6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cfa:	74 2a                	je     801d26 <devcons_read+0x3b>
  801cfc:	eb 05                	jmp    801d03 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801cfe:	e8 f0 ee ff ff       	call   800bf3 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d03:	e8 6c ee ff ff       	call   800b74 <sys_cgetc>
  801d08:	85 c0                	test   %eax,%eax
  801d0a:	74 f2                	je     801cfe <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d0c:	85 c0                	test   %eax,%eax
  801d0e:	78 16                	js     801d26 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d10:	83 f8 04             	cmp    $0x4,%eax
  801d13:	74 0c                	je     801d21 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d15:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d18:	88 02                	mov    %al,(%edx)
	return 1;
  801d1a:	b8 01 00 00 00       	mov    $0x1,%eax
  801d1f:	eb 05                	jmp    801d26 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d21:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d26:	c9                   	leave  
  801d27:	c3                   	ret    

00801d28 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d28:	55                   	push   %ebp
  801d29:	89 e5                	mov    %esp,%ebp
  801d2b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d31:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d34:	6a 01                	push   $0x1
  801d36:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d39:	50                   	push   %eax
  801d3a:	e8 17 ee ff ff       	call   800b56 <sys_cputs>
}
  801d3f:	83 c4 10             	add    $0x10,%esp
  801d42:	c9                   	leave  
  801d43:	c3                   	ret    

00801d44 <getchar>:

int
getchar(void)
{
  801d44:	55                   	push   %ebp
  801d45:	89 e5                	mov    %esp,%ebp
  801d47:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d4a:	6a 01                	push   $0x1
  801d4c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d4f:	50                   	push   %eax
  801d50:	6a 00                	push   $0x0
  801d52:	e8 90 f6 ff ff       	call   8013e7 <read>
	if (r < 0)
  801d57:	83 c4 10             	add    $0x10,%esp
  801d5a:	85 c0                	test   %eax,%eax
  801d5c:	78 0f                	js     801d6d <getchar+0x29>
		return r;
	if (r < 1)
  801d5e:	85 c0                	test   %eax,%eax
  801d60:	7e 06                	jle    801d68 <getchar+0x24>
		return -E_EOF;
	return c;
  801d62:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d66:	eb 05                	jmp    801d6d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d68:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d6d:	c9                   	leave  
  801d6e:	c3                   	ret    

00801d6f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d6f:	55                   	push   %ebp
  801d70:	89 e5                	mov    %esp,%ebp
  801d72:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d75:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d78:	50                   	push   %eax
  801d79:	ff 75 08             	pushl  0x8(%ebp)
  801d7c:	e8 00 f4 ff ff       	call   801181 <fd_lookup>
  801d81:	83 c4 10             	add    $0x10,%esp
  801d84:	85 c0                	test   %eax,%eax
  801d86:	78 11                	js     801d99 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d8b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d91:	39 10                	cmp    %edx,(%eax)
  801d93:	0f 94 c0             	sete   %al
  801d96:	0f b6 c0             	movzbl %al,%eax
}
  801d99:	c9                   	leave  
  801d9a:	c3                   	ret    

00801d9b <opencons>:

int
opencons(void)
{
  801d9b:	55                   	push   %ebp
  801d9c:	89 e5                	mov    %esp,%ebp
  801d9e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801da1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da4:	50                   	push   %eax
  801da5:	e8 88 f3 ff ff       	call   801132 <fd_alloc>
  801daa:	83 c4 10             	add    $0x10,%esp
		return r;
  801dad:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801daf:	85 c0                	test   %eax,%eax
  801db1:	78 3e                	js     801df1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801db3:	83 ec 04             	sub    $0x4,%esp
  801db6:	68 07 04 00 00       	push   $0x407
  801dbb:	ff 75 f4             	pushl  -0xc(%ebp)
  801dbe:	6a 00                	push   $0x0
  801dc0:	e8 4d ee ff ff       	call   800c12 <sys_page_alloc>
  801dc5:	83 c4 10             	add    $0x10,%esp
		return r;
  801dc8:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dca:	85 c0                	test   %eax,%eax
  801dcc:	78 23                	js     801df1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801dce:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ddc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801de3:	83 ec 0c             	sub    $0xc,%esp
  801de6:	50                   	push   %eax
  801de7:	e8 1f f3 ff ff       	call   80110b <fd2num>
  801dec:	89 c2                	mov    %eax,%edx
  801dee:	83 c4 10             	add    $0x10,%esp
}
  801df1:	89 d0                	mov    %edx,%eax
  801df3:	c9                   	leave  
  801df4:	c3                   	ret    

00801df5 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801df5:	55                   	push   %ebp
  801df6:	89 e5                	mov    %esp,%ebp
  801df8:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801dfb:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e02:	75 2a                	jne    801e2e <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801e04:	83 ec 04             	sub    $0x4,%esp
  801e07:	6a 07                	push   $0x7
  801e09:	68 00 f0 bf ee       	push   $0xeebff000
  801e0e:	6a 00                	push   $0x0
  801e10:	e8 fd ed ff ff       	call   800c12 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801e15:	83 c4 10             	add    $0x10,%esp
  801e18:	85 c0                	test   %eax,%eax
  801e1a:	79 12                	jns    801e2e <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801e1c:	50                   	push   %eax
  801e1d:	68 b6 27 80 00       	push   $0x8027b6
  801e22:	6a 23                	push   $0x23
  801e24:	68 ba 27 80 00       	push   $0x8027ba
  801e29:	e8 83 e3 ff ff       	call   8001b1 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e31:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801e36:	83 ec 08             	sub    $0x8,%esp
  801e39:	68 60 1e 80 00       	push   $0x801e60
  801e3e:	6a 00                	push   $0x0
  801e40:	e8 18 ef ff ff       	call   800d5d <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801e45:	83 c4 10             	add    $0x10,%esp
  801e48:	85 c0                	test   %eax,%eax
  801e4a:	79 12                	jns    801e5e <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801e4c:	50                   	push   %eax
  801e4d:	68 b6 27 80 00       	push   $0x8027b6
  801e52:	6a 2c                	push   $0x2c
  801e54:	68 ba 27 80 00       	push   $0x8027ba
  801e59:	e8 53 e3 ff ff       	call   8001b1 <_panic>
	}
}
  801e5e:	c9                   	leave  
  801e5f:	c3                   	ret    

00801e60 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e60:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e61:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e66:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e68:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801e6b:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801e6f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801e74:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801e78:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801e7a:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801e7d:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801e7e:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801e81:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801e82:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e83:	c3                   	ret    

00801e84 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e84:	55                   	push   %ebp
  801e85:	89 e5                	mov    %esp,%ebp
  801e87:	56                   	push   %esi
  801e88:	53                   	push   %ebx
  801e89:	8b 75 08             	mov    0x8(%ebp),%esi
  801e8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e92:	85 c0                	test   %eax,%eax
  801e94:	75 12                	jne    801ea8 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e96:	83 ec 0c             	sub    $0xc,%esp
  801e99:	68 00 00 c0 ee       	push   $0xeec00000
  801e9e:	e8 1f ef ff ff       	call   800dc2 <sys_ipc_recv>
  801ea3:	83 c4 10             	add    $0x10,%esp
  801ea6:	eb 0c                	jmp    801eb4 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801ea8:	83 ec 0c             	sub    $0xc,%esp
  801eab:	50                   	push   %eax
  801eac:	e8 11 ef ff ff       	call   800dc2 <sys_ipc_recv>
  801eb1:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801eb4:	85 f6                	test   %esi,%esi
  801eb6:	0f 95 c1             	setne  %cl
  801eb9:	85 db                	test   %ebx,%ebx
  801ebb:	0f 95 c2             	setne  %dl
  801ebe:	84 d1                	test   %dl,%cl
  801ec0:	74 09                	je     801ecb <ipc_recv+0x47>
  801ec2:	89 c2                	mov    %eax,%edx
  801ec4:	c1 ea 1f             	shr    $0x1f,%edx
  801ec7:	84 d2                	test   %dl,%dl
  801ec9:	75 27                	jne    801ef2 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801ecb:	85 f6                	test   %esi,%esi
  801ecd:	74 0a                	je     801ed9 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801ecf:	a1 08 40 80 00       	mov    0x804008,%eax
  801ed4:	8b 40 7c             	mov    0x7c(%eax),%eax
  801ed7:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801ed9:	85 db                	test   %ebx,%ebx
  801edb:	74 0d                	je     801eea <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  801edd:	a1 08 40 80 00       	mov    0x804008,%eax
  801ee2:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801ee8:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801eea:	a1 08 40 80 00       	mov    0x804008,%eax
  801eef:	8b 40 78             	mov    0x78(%eax),%eax
}
  801ef2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ef5:	5b                   	pop    %ebx
  801ef6:	5e                   	pop    %esi
  801ef7:	5d                   	pop    %ebp
  801ef8:	c3                   	ret    

00801ef9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ef9:	55                   	push   %ebp
  801efa:	89 e5                	mov    %esp,%ebp
  801efc:	57                   	push   %edi
  801efd:	56                   	push   %esi
  801efe:	53                   	push   %ebx
  801eff:	83 ec 0c             	sub    $0xc,%esp
  801f02:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f05:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f08:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801f0b:	85 db                	test   %ebx,%ebx
  801f0d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f12:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801f15:	ff 75 14             	pushl  0x14(%ebp)
  801f18:	53                   	push   %ebx
  801f19:	56                   	push   %esi
  801f1a:	57                   	push   %edi
  801f1b:	e8 7f ee ff ff       	call   800d9f <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801f20:	89 c2                	mov    %eax,%edx
  801f22:	c1 ea 1f             	shr    $0x1f,%edx
  801f25:	83 c4 10             	add    $0x10,%esp
  801f28:	84 d2                	test   %dl,%dl
  801f2a:	74 17                	je     801f43 <ipc_send+0x4a>
  801f2c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f2f:	74 12                	je     801f43 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801f31:	50                   	push   %eax
  801f32:	68 c8 27 80 00       	push   $0x8027c8
  801f37:	6a 47                	push   $0x47
  801f39:	68 d6 27 80 00       	push   $0x8027d6
  801f3e:	e8 6e e2 ff ff       	call   8001b1 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801f43:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f46:	75 07                	jne    801f4f <ipc_send+0x56>
			sys_yield();
  801f48:	e8 a6 ec ff ff       	call   800bf3 <sys_yield>
  801f4d:	eb c6                	jmp    801f15 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801f4f:	85 c0                	test   %eax,%eax
  801f51:	75 c2                	jne    801f15 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801f53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f56:	5b                   	pop    %ebx
  801f57:	5e                   	pop    %esi
  801f58:	5f                   	pop    %edi
  801f59:	5d                   	pop    %ebp
  801f5a:	c3                   	ret    

00801f5b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f5b:	55                   	push   %ebp
  801f5c:	89 e5                	mov    %esp,%ebp
  801f5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f61:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f66:	89 c2                	mov    %eax,%edx
  801f68:	c1 e2 07             	shl    $0x7,%edx
  801f6b:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801f72:	8b 52 58             	mov    0x58(%edx),%edx
  801f75:	39 ca                	cmp    %ecx,%edx
  801f77:	75 11                	jne    801f8a <ipc_find_env+0x2f>
			return envs[i].env_id;
  801f79:	89 c2                	mov    %eax,%edx
  801f7b:	c1 e2 07             	shl    $0x7,%edx
  801f7e:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801f85:	8b 40 50             	mov    0x50(%eax),%eax
  801f88:	eb 0f                	jmp    801f99 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f8a:	83 c0 01             	add    $0x1,%eax
  801f8d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f92:	75 d2                	jne    801f66 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f94:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f99:	5d                   	pop    %ebp
  801f9a:	c3                   	ret    

00801f9b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f9b:	55                   	push   %ebp
  801f9c:	89 e5                	mov    %esp,%ebp
  801f9e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa1:	89 d0                	mov    %edx,%eax
  801fa3:	c1 e8 16             	shr    $0x16,%eax
  801fa6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fad:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fb2:	f6 c1 01             	test   $0x1,%cl
  801fb5:	74 1d                	je     801fd4 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fb7:	c1 ea 0c             	shr    $0xc,%edx
  801fba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fc1:	f6 c2 01             	test   $0x1,%dl
  801fc4:	74 0e                	je     801fd4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fc6:	c1 ea 0c             	shr    $0xc,%edx
  801fc9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fd0:	ef 
  801fd1:	0f b7 c0             	movzwl %ax,%eax
}
  801fd4:	5d                   	pop    %ebp
  801fd5:	c3                   	ret    
  801fd6:	66 90                	xchg   %ax,%ax
  801fd8:	66 90                	xchg   %ax,%ax
  801fda:	66 90                	xchg   %ax,%ax
  801fdc:	66 90                	xchg   %ax,%ax
  801fde:	66 90                	xchg   %ax,%ax

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
