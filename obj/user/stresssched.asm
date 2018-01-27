
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
  80002c:	e8 c5 00 00 00       	call   8000f6 <libmain>
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
  800038:	e8 5f 0b 00 00       	call   800b9c <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 98 0e 00 00       	call   800ee1 <fork>
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
  80005c:	e8 5a 0b 00 00       	call   800bbb <sys_yield>
		return;
  800061:	e9 89 00 00 00       	jmp    8000ef <umain+0xbc>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800066:	f3 90                	pause  
  800068:	eb 12                	jmp    80007c <umain+0x49>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800070:	69 d6 b0 00 00 00    	imul   $0xb0,%esi,%edx
  800076:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80007c:	8b 82 88 00 00 00    	mov    0x88(%edx),%eax
  800082:	85 c0                	test   %eax,%eax
  800084:	75 e0                	jne    800066 <umain+0x33>
  800086:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  80008b:	e8 2b 0b 00 00       	call   800bbb <sys_yield>
  800090:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  800095:	a1 04 40 80 00       	mov    0x804004,%eax
  80009a:	83 c0 01             	add    $0x1,%eax
  80009d:	a3 04 40 80 00       	mov    %eax,0x804004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000a2:	83 ea 01             	sub    $0x1,%edx
  8000a5:	75 ee                	jne    800095 <umain+0x62>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000a7:	83 eb 01             	sub    $0x1,%ebx
  8000aa:	75 df                	jne    80008b <umain+0x58>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000ac:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b1:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b6:	74 17                	je     8000cf <umain+0x9c>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000b8:	a1 04 40 80 00       	mov    0x804004,%eax
  8000bd:	50                   	push   %eax
  8000be:	68 80 22 80 00       	push   $0x802280
  8000c3:	6a 21                	push   $0x21
  8000c5:	68 a8 22 80 00       	push   $0x8022a8
  8000ca:	e8 aa 00 00 00       	call   800179 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000cf:	a1 08 40 80 00       	mov    0x804008,%eax
  8000d4:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
  8000da:	8b 40 7c             	mov    0x7c(%eax),%eax
  8000dd:	83 ec 04             	sub    $0x4,%esp
  8000e0:	52                   	push   %edx
  8000e1:	50                   	push   %eax
  8000e2:	68 bb 22 80 00       	push   $0x8022bb
  8000e7:	e8 66 01 00 00       	call   800252 <cprintf>
  8000ec:	83 c4 10             	add    $0x10,%esp

}
  8000ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f2:	5b                   	pop    %ebx
  8000f3:	5e                   	pop    %esi
  8000f4:	5d                   	pop    %ebp
  8000f5:	c3                   	ret    

008000f6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f6:	55                   	push   %ebp
  8000f7:	89 e5                	mov    %esp,%ebp
  8000f9:	56                   	push   %esi
  8000fa:	53                   	push   %ebx
  8000fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000fe:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800101:	e8 96 0a 00 00       	call   800b9c <sys_getenvid>
  800106:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010b:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800111:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800116:	a3 08 40 80 00       	mov    %eax,0x804008
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011b:	85 db                	test   %ebx,%ebx
  80011d:	7e 07                	jle    800126 <libmain+0x30>
		binaryname = argv[0];
  80011f:	8b 06                	mov    (%esi),%eax
  800121:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800126:	83 ec 08             	sub    $0x8,%esp
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
  80012b:	e8 03 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800130:	e8 2a 00 00 00       	call   80015f <exit>
}
  800135:	83 c4 10             	add    $0x10,%esp
  800138:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013b:	5b                   	pop    %ebx
  80013c:	5e                   	pop    %esi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  800145:	a1 0c 40 80 00       	mov    0x80400c,%eax
	func();
  80014a:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  80014c:	e8 4b 0a 00 00       	call   800b9c <sys_getenvid>
  800151:	83 ec 0c             	sub    $0xc,%esp
  800154:	50                   	push   %eax
  800155:	e8 91 0c 00 00       	call   800deb <sys_thread_free>
}
  80015a:	83 c4 10             	add    $0x10,%esp
  80015d:	c9                   	leave  
  80015e:	c3                   	ret    

0080015f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800165:	e8 60 11 00 00       	call   8012ca <close_all>
	sys_env_destroy(0);
  80016a:	83 ec 0c             	sub    $0xc,%esp
  80016d:	6a 00                	push   $0x0
  80016f:	e8 e7 09 00 00       	call   800b5b <sys_env_destroy>
}
  800174:	83 c4 10             	add    $0x10,%esp
  800177:	c9                   	leave  
  800178:	c3                   	ret    

00800179 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	56                   	push   %esi
  80017d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80017e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800181:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800187:	e8 10 0a 00 00       	call   800b9c <sys_getenvid>
  80018c:	83 ec 0c             	sub    $0xc,%esp
  80018f:	ff 75 0c             	pushl  0xc(%ebp)
  800192:	ff 75 08             	pushl  0x8(%ebp)
  800195:	56                   	push   %esi
  800196:	50                   	push   %eax
  800197:	68 e4 22 80 00       	push   $0x8022e4
  80019c:	e8 b1 00 00 00       	call   800252 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a1:	83 c4 18             	add    $0x18,%esp
  8001a4:	53                   	push   %ebx
  8001a5:	ff 75 10             	pushl  0x10(%ebp)
  8001a8:	e8 54 00 00 00       	call   800201 <vcprintf>
	cprintf("\n");
  8001ad:	c7 04 24 d7 22 80 00 	movl   $0x8022d7,(%esp)
  8001b4:	e8 99 00 00 00       	call   800252 <cprintf>
  8001b9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001bc:	cc                   	int3   
  8001bd:	eb fd                	jmp    8001bc <_panic+0x43>

008001bf <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001bf:	55                   	push   %ebp
  8001c0:	89 e5                	mov    %esp,%ebp
  8001c2:	53                   	push   %ebx
  8001c3:	83 ec 04             	sub    $0x4,%esp
  8001c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001c9:	8b 13                	mov    (%ebx),%edx
  8001cb:	8d 42 01             	lea    0x1(%edx),%eax
  8001ce:	89 03                	mov    %eax,(%ebx)
  8001d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001d7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001dc:	75 1a                	jne    8001f8 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001de:	83 ec 08             	sub    $0x8,%esp
  8001e1:	68 ff 00 00 00       	push   $0xff
  8001e6:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e9:	50                   	push   %eax
  8001ea:	e8 2f 09 00 00       	call   800b1e <sys_cputs>
		b->idx = 0;
  8001ef:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001f5:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001f8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ff:	c9                   	leave  
  800200:	c3                   	ret    

00800201 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800201:	55                   	push   %ebp
  800202:	89 e5                	mov    %esp,%ebp
  800204:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80020a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800211:	00 00 00 
	b.cnt = 0;
  800214:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80021b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80021e:	ff 75 0c             	pushl  0xc(%ebp)
  800221:	ff 75 08             	pushl  0x8(%ebp)
  800224:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80022a:	50                   	push   %eax
  80022b:	68 bf 01 80 00       	push   $0x8001bf
  800230:	e8 54 01 00 00       	call   800389 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800235:	83 c4 08             	add    $0x8,%esp
  800238:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80023e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800244:	50                   	push   %eax
  800245:	e8 d4 08 00 00       	call   800b1e <sys_cputs>

	return b.cnt;
}
  80024a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800250:	c9                   	leave  
  800251:	c3                   	ret    

00800252 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800252:	55                   	push   %ebp
  800253:	89 e5                	mov    %esp,%ebp
  800255:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800258:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80025b:	50                   	push   %eax
  80025c:	ff 75 08             	pushl  0x8(%ebp)
  80025f:	e8 9d ff ff ff       	call   800201 <vcprintf>
	va_end(ap);

	return cnt;
}
  800264:	c9                   	leave  
  800265:	c3                   	ret    

00800266 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800266:	55                   	push   %ebp
  800267:	89 e5                	mov    %esp,%ebp
  800269:	57                   	push   %edi
  80026a:	56                   	push   %esi
  80026b:	53                   	push   %ebx
  80026c:	83 ec 1c             	sub    $0x1c,%esp
  80026f:	89 c7                	mov    %eax,%edi
  800271:	89 d6                	mov    %edx,%esi
  800273:	8b 45 08             	mov    0x8(%ebp),%eax
  800276:	8b 55 0c             	mov    0xc(%ebp),%edx
  800279:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80027c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80027f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800282:	bb 00 00 00 00       	mov    $0x0,%ebx
  800287:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80028a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80028d:	39 d3                	cmp    %edx,%ebx
  80028f:	72 05                	jb     800296 <printnum+0x30>
  800291:	39 45 10             	cmp    %eax,0x10(%ebp)
  800294:	77 45                	ja     8002db <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800296:	83 ec 0c             	sub    $0xc,%esp
  800299:	ff 75 18             	pushl  0x18(%ebp)
  80029c:	8b 45 14             	mov    0x14(%ebp),%eax
  80029f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002a2:	53                   	push   %ebx
  8002a3:	ff 75 10             	pushl  0x10(%ebp)
  8002a6:	83 ec 08             	sub    $0x8,%esp
  8002a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8002af:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b5:	e8 26 1d 00 00       	call   801fe0 <__udivdi3>
  8002ba:	83 c4 18             	add    $0x18,%esp
  8002bd:	52                   	push   %edx
  8002be:	50                   	push   %eax
  8002bf:	89 f2                	mov    %esi,%edx
  8002c1:	89 f8                	mov    %edi,%eax
  8002c3:	e8 9e ff ff ff       	call   800266 <printnum>
  8002c8:	83 c4 20             	add    $0x20,%esp
  8002cb:	eb 18                	jmp    8002e5 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002cd:	83 ec 08             	sub    $0x8,%esp
  8002d0:	56                   	push   %esi
  8002d1:	ff 75 18             	pushl  0x18(%ebp)
  8002d4:	ff d7                	call   *%edi
  8002d6:	83 c4 10             	add    $0x10,%esp
  8002d9:	eb 03                	jmp    8002de <printnum+0x78>
  8002db:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002de:	83 eb 01             	sub    $0x1,%ebx
  8002e1:	85 db                	test   %ebx,%ebx
  8002e3:	7f e8                	jg     8002cd <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002e5:	83 ec 08             	sub    $0x8,%esp
  8002e8:	56                   	push   %esi
  8002e9:	83 ec 04             	sub    $0x4,%esp
  8002ec:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8002f2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f8:	e8 13 1e 00 00       	call   802110 <__umoddi3>
  8002fd:	83 c4 14             	add    $0x14,%esp
  800300:	0f be 80 07 23 80 00 	movsbl 0x802307(%eax),%eax
  800307:	50                   	push   %eax
  800308:	ff d7                	call   *%edi
}
  80030a:	83 c4 10             	add    $0x10,%esp
  80030d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800310:	5b                   	pop    %ebx
  800311:	5e                   	pop    %esi
  800312:	5f                   	pop    %edi
  800313:	5d                   	pop    %ebp
  800314:	c3                   	ret    

00800315 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800318:	83 fa 01             	cmp    $0x1,%edx
  80031b:	7e 0e                	jle    80032b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80031d:	8b 10                	mov    (%eax),%edx
  80031f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800322:	89 08                	mov    %ecx,(%eax)
  800324:	8b 02                	mov    (%edx),%eax
  800326:	8b 52 04             	mov    0x4(%edx),%edx
  800329:	eb 22                	jmp    80034d <getuint+0x38>
	else if (lflag)
  80032b:	85 d2                	test   %edx,%edx
  80032d:	74 10                	je     80033f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80032f:	8b 10                	mov    (%eax),%edx
  800331:	8d 4a 04             	lea    0x4(%edx),%ecx
  800334:	89 08                	mov    %ecx,(%eax)
  800336:	8b 02                	mov    (%edx),%eax
  800338:	ba 00 00 00 00       	mov    $0x0,%edx
  80033d:	eb 0e                	jmp    80034d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80033f:	8b 10                	mov    (%eax),%edx
  800341:	8d 4a 04             	lea    0x4(%edx),%ecx
  800344:	89 08                	mov    %ecx,(%eax)
  800346:	8b 02                	mov    (%edx),%eax
  800348:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800355:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800359:	8b 10                	mov    (%eax),%edx
  80035b:	3b 50 04             	cmp    0x4(%eax),%edx
  80035e:	73 0a                	jae    80036a <sprintputch+0x1b>
		*b->buf++ = ch;
  800360:	8d 4a 01             	lea    0x1(%edx),%ecx
  800363:	89 08                	mov    %ecx,(%eax)
  800365:	8b 45 08             	mov    0x8(%ebp),%eax
  800368:	88 02                	mov    %al,(%edx)
}
  80036a:	5d                   	pop    %ebp
  80036b:	c3                   	ret    

0080036c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800372:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800375:	50                   	push   %eax
  800376:	ff 75 10             	pushl  0x10(%ebp)
  800379:	ff 75 0c             	pushl  0xc(%ebp)
  80037c:	ff 75 08             	pushl  0x8(%ebp)
  80037f:	e8 05 00 00 00       	call   800389 <vprintfmt>
	va_end(ap);
}
  800384:	83 c4 10             	add    $0x10,%esp
  800387:	c9                   	leave  
  800388:	c3                   	ret    

00800389 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	57                   	push   %edi
  80038d:	56                   	push   %esi
  80038e:	53                   	push   %ebx
  80038f:	83 ec 2c             	sub    $0x2c,%esp
  800392:	8b 75 08             	mov    0x8(%ebp),%esi
  800395:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800398:	8b 7d 10             	mov    0x10(%ebp),%edi
  80039b:	eb 12                	jmp    8003af <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80039d:	85 c0                	test   %eax,%eax
  80039f:	0f 84 89 03 00 00    	je     80072e <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003a5:	83 ec 08             	sub    $0x8,%esp
  8003a8:	53                   	push   %ebx
  8003a9:	50                   	push   %eax
  8003aa:	ff d6                	call   *%esi
  8003ac:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003af:	83 c7 01             	add    $0x1,%edi
  8003b2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003b6:	83 f8 25             	cmp    $0x25,%eax
  8003b9:	75 e2                	jne    80039d <vprintfmt+0x14>
  8003bb:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003bf:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003c6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003cd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d9:	eb 07                	jmp    8003e2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003db:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003de:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	8d 47 01             	lea    0x1(%edi),%eax
  8003e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e8:	0f b6 07             	movzbl (%edi),%eax
  8003eb:	0f b6 c8             	movzbl %al,%ecx
  8003ee:	83 e8 23             	sub    $0x23,%eax
  8003f1:	3c 55                	cmp    $0x55,%al
  8003f3:	0f 87 1a 03 00 00    	ja     800713 <vprintfmt+0x38a>
  8003f9:	0f b6 c0             	movzbl %al,%eax
  8003fc:	ff 24 85 40 24 80 00 	jmp    *0x802440(,%eax,4)
  800403:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800406:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80040a:	eb d6                	jmp    8003e2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80040f:	b8 00 00 00 00       	mov    $0x0,%eax
  800414:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800417:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80041a:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80041e:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800421:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800424:	83 fa 09             	cmp    $0x9,%edx
  800427:	77 39                	ja     800462 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800429:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80042c:	eb e9                	jmp    800417 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8d 48 04             	lea    0x4(%eax),%ecx
  800434:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800437:	8b 00                	mov    (%eax),%eax
  800439:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80043f:	eb 27                	jmp    800468 <vprintfmt+0xdf>
  800441:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800444:	85 c0                	test   %eax,%eax
  800446:	b9 00 00 00 00       	mov    $0x0,%ecx
  80044b:	0f 49 c8             	cmovns %eax,%ecx
  80044e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800451:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800454:	eb 8c                	jmp    8003e2 <vprintfmt+0x59>
  800456:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800459:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800460:	eb 80                	jmp    8003e2 <vprintfmt+0x59>
  800462:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800465:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800468:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80046c:	0f 89 70 ff ff ff    	jns    8003e2 <vprintfmt+0x59>
				width = precision, precision = -1;
  800472:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800475:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800478:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80047f:	e9 5e ff ff ff       	jmp    8003e2 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800484:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800487:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80048a:	e9 53 ff ff ff       	jmp    8003e2 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80048f:	8b 45 14             	mov    0x14(%ebp),%eax
  800492:	8d 50 04             	lea    0x4(%eax),%edx
  800495:	89 55 14             	mov    %edx,0x14(%ebp)
  800498:	83 ec 08             	sub    $0x8,%esp
  80049b:	53                   	push   %ebx
  80049c:	ff 30                	pushl  (%eax)
  80049e:	ff d6                	call   *%esi
			break;
  8004a0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004a6:	e9 04 ff ff ff       	jmp    8003af <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ae:	8d 50 04             	lea    0x4(%eax),%edx
  8004b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b4:	8b 00                	mov    (%eax),%eax
  8004b6:	99                   	cltd   
  8004b7:	31 d0                	xor    %edx,%eax
  8004b9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004bb:	83 f8 0f             	cmp    $0xf,%eax
  8004be:	7f 0b                	jg     8004cb <vprintfmt+0x142>
  8004c0:	8b 14 85 a0 25 80 00 	mov    0x8025a0(,%eax,4),%edx
  8004c7:	85 d2                	test   %edx,%edx
  8004c9:	75 18                	jne    8004e3 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004cb:	50                   	push   %eax
  8004cc:	68 1f 23 80 00       	push   $0x80231f
  8004d1:	53                   	push   %ebx
  8004d2:	56                   	push   %esi
  8004d3:	e8 94 fe ff ff       	call   80036c <printfmt>
  8004d8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004de:	e9 cc fe ff ff       	jmp    8003af <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004e3:	52                   	push   %edx
  8004e4:	68 51 27 80 00       	push   $0x802751
  8004e9:	53                   	push   %ebx
  8004ea:	56                   	push   %esi
  8004eb:	e8 7c fe ff ff       	call   80036c <printfmt>
  8004f0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f6:	e9 b4 fe ff ff       	jmp    8003af <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fe:	8d 50 04             	lea    0x4(%eax),%edx
  800501:	89 55 14             	mov    %edx,0x14(%ebp)
  800504:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800506:	85 ff                	test   %edi,%edi
  800508:	b8 18 23 80 00       	mov    $0x802318,%eax
  80050d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800510:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800514:	0f 8e 94 00 00 00    	jle    8005ae <vprintfmt+0x225>
  80051a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80051e:	0f 84 98 00 00 00    	je     8005bc <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800524:	83 ec 08             	sub    $0x8,%esp
  800527:	ff 75 d0             	pushl  -0x30(%ebp)
  80052a:	57                   	push   %edi
  80052b:	e8 86 02 00 00       	call   8007b6 <strnlen>
  800530:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800533:	29 c1                	sub    %eax,%ecx
  800535:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800538:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80053b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80053f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800542:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800545:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800547:	eb 0f                	jmp    800558 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	53                   	push   %ebx
  80054d:	ff 75 e0             	pushl  -0x20(%ebp)
  800550:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800552:	83 ef 01             	sub    $0x1,%edi
  800555:	83 c4 10             	add    $0x10,%esp
  800558:	85 ff                	test   %edi,%edi
  80055a:	7f ed                	jg     800549 <vprintfmt+0x1c0>
  80055c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80055f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800562:	85 c9                	test   %ecx,%ecx
  800564:	b8 00 00 00 00       	mov    $0x0,%eax
  800569:	0f 49 c1             	cmovns %ecx,%eax
  80056c:	29 c1                	sub    %eax,%ecx
  80056e:	89 75 08             	mov    %esi,0x8(%ebp)
  800571:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800574:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800577:	89 cb                	mov    %ecx,%ebx
  800579:	eb 4d                	jmp    8005c8 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80057b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80057f:	74 1b                	je     80059c <vprintfmt+0x213>
  800581:	0f be c0             	movsbl %al,%eax
  800584:	83 e8 20             	sub    $0x20,%eax
  800587:	83 f8 5e             	cmp    $0x5e,%eax
  80058a:	76 10                	jbe    80059c <vprintfmt+0x213>
					putch('?', putdat);
  80058c:	83 ec 08             	sub    $0x8,%esp
  80058f:	ff 75 0c             	pushl  0xc(%ebp)
  800592:	6a 3f                	push   $0x3f
  800594:	ff 55 08             	call   *0x8(%ebp)
  800597:	83 c4 10             	add    $0x10,%esp
  80059a:	eb 0d                	jmp    8005a9 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80059c:	83 ec 08             	sub    $0x8,%esp
  80059f:	ff 75 0c             	pushl  0xc(%ebp)
  8005a2:	52                   	push   %edx
  8005a3:	ff 55 08             	call   *0x8(%ebp)
  8005a6:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a9:	83 eb 01             	sub    $0x1,%ebx
  8005ac:	eb 1a                	jmp    8005c8 <vprintfmt+0x23f>
  8005ae:	89 75 08             	mov    %esi,0x8(%ebp)
  8005b1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005b4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005b7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005ba:	eb 0c                	jmp    8005c8 <vprintfmt+0x23f>
  8005bc:	89 75 08             	mov    %esi,0x8(%ebp)
  8005bf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005c2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005c5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005c8:	83 c7 01             	add    $0x1,%edi
  8005cb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005cf:	0f be d0             	movsbl %al,%edx
  8005d2:	85 d2                	test   %edx,%edx
  8005d4:	74 23                	je     8005f9 <vprintfmt+0x270>
  8005d6:	85 f6                	test   %esi,%esi
  8005d8:	78 a1                	js     80057b <vprintfmt+0x1f2>
  8005da:	83 ee 01             	sub    $0x1,%esi
  8005dd:	79 9c                	jns    80057b <vprintfmt+0x1f2>
  8005df:	89 df                	mov    %ebx,%edi
  8005e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e7:	eb 18                	jmp    800601 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005e9:	83 ec 08             	sub    $0x8,%esp
  8005ec:	53                   	push   %ebx
  8005ed:	6a 20                	push   $0x20
  8005ef:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005f1:	83 ef 01             	sub    $0x1,%edi
  8005f4:	83 c4 10             	add    $0x10,%esp
  8005f7:	eb 08                	jmp    800601 <vprintfmt+0x278>
  8005f9:	89 df                	mov    %ebx,%edi
  8005fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8005fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800601:	85 ff                	test   %edi,%edi
  800603:	7f e4                	jg     8005e9 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800605:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800608:	e9 a2 fd ff ff       	jmp    8003af <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80060d:	83 fa 01             	cmp    $0x1,%edx
  800610:	7e 16                	jle    800628 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8d 50 08             	lea    0x8(%eax),%edx
  800618:	89 55 14             	mov    %edx,0x14(%ebp)
  80061b:	8b 50 04             	mov    0x4(%eax),%edx
  80061e:	8b 00                	mov    (%eax),%eax
  800620:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800623:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800626:	eb 32                	jmp    80065a <vprintfmt+0x2d1>
	else if (lflag)
  800628:	85 d2                	test   %edx,%edx
  80062a:	74 18                	je     800644 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8d 50 04             	lea    0x4(%eax),%edx
  800632:	89 55 14             	mov    %edx,0x14(%ebp)
  800635:	8b 00                	mov    (%eax),%eax
  800637:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063a:	89 c1                	mov    %eax,%ecx
  80063c:	c1 f9 1f             	sar    $0x1f,%ecx
  80063f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800642:	eb 16                	jmp    80065a <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8d 50 04             	lea    0x4(%eax),%edx
  80064a:	89 55 14             	mov    %edx,0x14(%ebp)
  80064d:	8b 00                	mov    (%eax),%eax
  80064f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800652:	89 c1                	mov    %eax,%ecx
  800654:	c1 f9 1f             	sar    $0x1f,%ecx
  800657:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80065a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80065d:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800660:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800665:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800669:	79 74                	jns    8006df <vprintfmt+0x356>
				putch('-', putdat);
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	53                   	push   %ebx
  80066f:	6a 2d                	push   $0x2d
  800671:	ff d6                	call   *%esi
				num = -(long long) num;
  800673:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800676:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800679:	f7 d8                	neg    %eax
  80067b:	83 d2 00             	adc    $0x0,%edx
  80067e:	f7 da                	neg    %edx
  800680:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800683:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800688:	eb 55                	jmp    8006df <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80068a:	8d 45 14             	lea    0x14(%ebp),%eax
  80068d:	e8 83 fc ff ff       	call   800315 <getuint>
			base = 10;
  800692:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800697:	eb 46                	jmp    8006df <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800699:	8d 45 14             	lea    0x14(%ebp),%eax
  80069c:	e8 74 fc ff ff       	call   800315 <getuint>
			base = 8;
  8006a1:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006a6:	eb 37                	jmp    8006df <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8006a8:	83 ec 08             	sub    $0x8,%esp
  8006ab:	53                   	push   %ebx
  8006ac:	6a 30                	push   $0x30
  8006ae:	ff d6                	call   *%esi
			putch('x', putdat);
  8006b0:	83 c4 08             	add    $0x8,%esp
  8006b3:	53                   	push   %ebx
  8006b4:	6a 78                	push   $0x78
  8006b6:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bb:	8d 50 04             	lea    0x4(%eax),%edx
  8006be:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006c1:	8b 00                	mov    (%eax),%eax
  8006c3:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006c8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006cb:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006d0:	eb 0d                	jmp    8006df <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d5:	e8 3b fc ff ff       	call   800315 <getuint>
			base = 16;
  8006da:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006df:	83 ec 0c             	sub    $0xc,%esp
  8006e2:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006e6:	57                   	push   %edi
  8006e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ea:	51                   	push   %ecx
  8006eb:	52                   	push   %edx
  8006ec:	50                   	push   %eax
  8006ed:	89 da                	mov    %ebx,%edx
  8006ef:	89 f0                	mov    %esi,%eax
  8006f1:	e8 70 fb ff ff       	call   800266 <printnum>
			break;
  8006f6:	83 c4 20             	add    $0x20,%esp
  8006f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006fc:	e9 ae fc ff ff       	jmp    8003af <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800701:	83 ec 08             	sub    $0x8,%esp
  800704:	53                   	push   %ebx
  800705:	51                   	push   %ecx
  800706:	ff d6                	call   *%esi
			break;
  800708:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80070e:	e9 9c fc ff ff       	jmp    8003af <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800713:	83 ec 08             	sub    $0x8,%esp
  800716:	53                   	push   %ebx
  800717:	6a 25                	push   $0x25
  800719:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80071b:	83 c4 10             	add    $0x10,%esp
  80071e:	eb 03                	jmp    800723 <vprintfmt+0x39a>
  800720:	83 ef 01             	sub    $0x1,%edi
  800723:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800727:	75 f7                	jne    800720 <vprintfmt+0x397>
  800729:	e9 81 fc ff ff       	jmp    8003af <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80072e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800731:	5b                   	pop    %ebx
  800732:	5e                   	pop    %esi
  800733:	5f                   	pop    %edi
  800734:	5d                   	pop    %ebp
  800735:	c3                   	ret    

00800736 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	83 ec 18             	sub    $0x18,%esp
  80073c:	8b 45 08             	mov    0x8(%ebp),%eax
  80073f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800742:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800745:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800749:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80074c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800753:	85 c0                	test   %eax,%eax
  800755:	74 26                	je     80077d <vsnprintf+0x47>
  800757:	85 d2                	test   %edx,%edx
  800759:	7e 22                	jle    80077d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80075b:	ff 75 14             	pushl  0x14(%ebp)
  80075e:	ff 75 10             	pushl  0x10(%ebp)
  800761:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800764:	50                   	push   %eax
  800765:	68 4f 03 80 00       	push   $0x80034f
  80076a:	e8 1a fc ff ff       	call   800389 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80076f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800772:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800775:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800778:	83 c4 10             	add    $0x10,%esp
  80077b:	eb 05                	jmp    800782 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80077d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800782:	c9                   	leave  
  800783:	c3                   	ret    

00800784 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80078a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80078d:	50                   	push   %eax
  80078e:	ff 75 10             	pushl  0x10(%ebp)
  800791:	ff 75 0c             	pushl  0xc(%ebp)
  800794:	ff 75 08             	pushl  0x8(%ebp)
  800797:	e8 9a ff ff ff       	call   800736 <vsnprintf>
	va_end(ap);

	return rc;
}
  80079c:	c9                   	leave  
  80079d:	c3                   	ret    

0080079e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a9:	eb 03                	jmp    8007ae <strlen+0x10>
		n++;
  8007ab:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ae:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b2:	75 f7                	jne    8007ab <strlen+0xd>
		n++;
	return n;
}
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007bc:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c4:	eb 03                	jmp    8007c9 <strnlen+0x13>
		n++;
  8007c6:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c9:	39 c2                	cmp    %eax,%edx
  8007cb:	74 08                	je     8007d5 <strnlen+0x1f>
  8007cd:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007d1:	75 f3                	jne    8007c6 <strnlen+0x10>
  8007d3:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	53                   	push   %ebx
  8007db:	8b 45 08             	mov    0x8(%ebp),%eax
  8007de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e1:	89 c2                	mov    %eax,%edx
  8007e3:	83 c2 01             	add    $0x1,%edx
  8007e6:	83 c1 01             	add    $0x1,%ecx
  8007e9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ed:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007f0:	84 db                	test   %bl,%bl
  8007f2:	75 ef                	jne    8007e3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007f4:	5b                   	pop    %ebx
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	53                   	push   %ebx
  8007fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007fe:	53                   	push   %ebx
  8007ff:	e8 9a ff ff ff       	call   80079e <strlen>
  800804:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800807:	ff 75 0c             	pushl  0xc(%ebp)
  80080a:	01 d8                	add    %ebx,%eax
  80080c:	50                   	push   %eax
  80080d:	e8 c5 ff ff ff       	call   8007d7 <strcpy>
	return dst;
}
  800812:	89 d8                	mov    %ebx,%eax
  800814:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800817:	c9                   	leave  
  800818:	c3                   	ret    

00800819 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	56                   	push   %esi
  80081d:	53                   	push   %ebx
  80081e:	8b 75 08             	mov    0x8(%ebp),%esi
  800821:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800824:	89 f3                	mov    %esi,%ebx
  800826:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800829:	89 f2                	mov    %esi,%edx
  80082b:	eb 0f                	jmp    80083c <strncpy+0x23>
		*dst++ = *src;
  80082d:	83 c2 01             	add    $0x1,%edx
  800830:	0f b6 01             	movzbl (%ecx),%eax
  800833:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800836:	80 39 01             	cmpb   $0x1,(%ecx)
  800839:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083c:	39 da                	cmp    %ebx,%edx
  80083e:	75 ed                	jne    80082d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800840:	89 f0                	mov    %esi,%eax
  800842:	5b                   	pop    %ebx
  800843:	5e                   	pop    %esi
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	56                   	push   %esi
  80084a:	53                   	push   %ebx
  80084b:	8b 75 08             	mov    0x8(%ebp),%esi
  80084e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800851:	8b 55 10             	mov    0x10(%ebp),%edx
  800854:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800856:	85 d2                	test   %edx,%edx
  800858:	74 21                	je     80087b <strlcpy+0x35>
  80085a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80085e:	89 f2                	mov    %esi,%edx
  800860:	eb 09                	jmp    80086b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800862:	83 c2 01             	add    $0x1,%edx
  800865:	83 c1 01             	add    $0x1,%ecx
  800868:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80086b:	39 c2                	cmp    %eax,%edx
  80086d:	74 09                	je     800878 <strlcpy+0x32>
  80086f:	0f b6 19             	movzbl (%ecx),%ebx
  800872:	84 db                	test   %bl,%bl
  800874:	75 ec                	jne    800862 <strlcpy+0x1c>
  800876:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800878:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80087b:	29 f0                	sub    %esi,%eax
}
  80087d:	5b                   	pop    %ebx
  80087e:	5e                   	pop    %esi
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800887:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80088a:	eb 06                	jmp    800892 <strcmp+0x11>
		p++, q++;
  80088c:	83 c1 01             	add    $0x1,%ecx
  80088f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800892:	0f b6 01             	movzbl (%ecx),%eax
  800895:	84 c0                	test   %al,%al
  800897:	74 04                	je     80089d <strcmp+0x1c>
  800899:	3a 02                	cmp    (%edx),%al
  80089b:	74 ef                	je     80088c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80089d:	0f b6 c0             	movzbl %al,%eax
  8008a0:	0f b6 12             	movzbl (%edx),%edx
  8008a3:	29 d0                	sub    %edx,%eax
}
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	53                   	push   %ebx
  8008ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b1:	89 c3                	mov    %eax,%ebx
  8008b3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b6:	eb 06                	jmp    8008be <strncmp+0x17>
		n--, p++, q++;
  8008b8:	83 c0 01             	add    $0x1,%eax
  8008bb:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008be:	39 d8                	cmp    %ebx,%eax
  8008c0:	74 15                	je     8008d7 <strncmp+0x30>
  8008c2:	0f b6 08             	movzbl (%eax),%ecx
  8008c5:	84 c9                	test   %cl,%cl
  8008c7:	74 04                	je     8008cd <strncmp+0x26>
  8008c9:	3a 0a                	cmp    (%edx),%cl
  8008cb:	74 eb                	je     8008b8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cd:	0f b6 00             	movzbl (%eax),%eax
  8008d0:	0f b6 12             	movzbl (%edx),%edx
  8008d3:	29 d0                	sub    %edx,%eax
  8008d5:	eb 05                	jmp    8008dc <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008d7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008dc:	5b                   	pop    %ebx
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e9:	eb 07                	jmp    8008f2 <strchr+0x13>
		if (*s == c)
  8008eb:	38 ca                	cmp    %cl,%dl
  8008ed:	74 0f                	je     8008fe <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ef:	83 c0 01             	add    $0x1,%eax
  8008f2:	0f b6 10             	movzbl (%eax),%edx
  8008f5:	84 d2                	test   %dl,%dl
  8008f7:	75 f2                	jne    8008eb <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    

00800900 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	8b 45 08             	mov    0x8(%ebp),%eax
  800906:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090a:	eb 03                	jmp    80090f <strfind+0xf>
  80090c:	83 c0 01             	add    $0x1,%eax
  80090f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800912:	38 ca                	cmp    %cl,%dl
  800914:	74 04                	je     80091a <strfind+0x1a>
  800916:	84 d2                	test   %dl,%dl
  800918:	75 f2                	jne    80090c <strfind+0xc>
			break;
	return (char *) s;
}
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	57                   	push   %edi
  800920:	56                   	push   %esi
  800921:	53                   	push   %ebx
  800922:	8b 7d 08             	mov    0x8(%ebp),%edi
  800925:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800928:	85 c9                	test   %ecx,%ecx
  80092a:	74 36                	je     800962 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80092c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800932:	75 28                	jne    80095c <memset+0x40>
  800934:	f6 c1 03             	test   $0x3,%cl
  800937:	75 23                	jne    80095c <memset+0x40>
		c &= 0xFF;
  800939:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80093d:	89 d3                	mov    %edx,%ebx
  80093f:	c1 e3 08             	shl    $0x8,%ebx
  800942:	89 d6                	mov    %edx,%esi
  800944:	c1 e6 18             	shl    $0x18,%esi
  800947:	89 d0                	mov    %edx,%eax
  800949:	c1 e0 10             	shl    $0x10,%eax
  80094c:	09 f0                	or     %esi,%eax
  80094e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800950:	89 d8                	mov    %ebx,%eax
  800952:	09 d0                	or     %edx,%eax
  800954:	c1 e9 02             	shr    $0x2,%ecx
  800957:	fc                   	cld    
  800958:	f3 ab                	rep stos %eax,%es:(%edi)
  80095a:	eb 06                	jmp    800962 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80095c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095f:	fc                   	cld    
  800960:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800962:	89 f8                	mov    %edi,%eax
  800964:	5b                   	pop    %ebx
  800965:	5e                   	pop    %esi
  800966:	5f                   	pop    %edi
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	57                   	push   %edi
  80096d:	56                   	push   %esi
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	8b 75 0c             	mov    0xc(%ebp),%esi
  800974:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800977:	39 c6                	cmp    %eax,%esi
  800979:	73 35                	jae    8009b0 <memmove+0x47>
  80097b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80097e:	39 d0                	cmp    %edx,%eax
  800980:	73 2e                	jae    8009b0 <memmove+0x47>
		s += n;
		d += n;
  800982:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800985:	89 d6                	mov    %edx,%esi
  800987:	09 fe                	or     %edi,%esi
  800989:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80098f:	75 13                	jne    8009a4 <memmove+0x3b>
  800991:	f6 c1 03             	test   $0x3,%cl
  800994:	75 0e                	jne    8009a4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800996:	83 ef 04             	sub    $0x4,%edi
  800999:	8d 72 fc             	lea    -0x4(%edx),%esi
  80099c:	c1 e9 02             	shr    $0x2,%ecx
  80099f:	fd                   	std    
  8009a0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a2:	eb 09                	jmp    8009ad <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a4:	83 ef 01             	sub    $0x1,%edi
  8009a7:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009aa:	fd                   	std    
  8009ab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ad:	fc                   	cld    
  8009ae:	eb 1d                	jmp    8009cd <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b0:	89 f2                	mov    %esi,%edx
  8009b2:	09 c2                	or     %eax,%edx
  8009b4:	f6 c2 03             	test   $0x3,%dl
  8009b7:	75 0f                	jne    8009c8 <memmove+0x5f>
  8009b9:	f6 c1 03             	test   $0x3,%cl
  8009bc:	75 0a                	jne    8009c8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009be:	c1 e9 02             	shr    $0x2,%ecx
  8009c1:	89 c7                	mov    %eax,%edi
  8009c3:	fc                   	cld    
  8009c4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c6:	eb 05                	jmp    8009cd <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c8:	89 c7                	mov    %eax,%edi
  8009ca:	fc                   	cld    
  8009cb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009cd:	5e                   	pop    %esi
  8009ce:	5f                   	pop    %edi
  8009cf:	5d                   	pop    %ebp
  8009d0:	c3                   	ret    

008009d1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009d4:	ff 75 10             	pushl  0x10(%ebp)
  8009d7:	ff 75 0c             	pushl  0xc(%ebp)
  8009da:	ff 75 08             	pushl  0x8(%ebp)
  8009dd:	e8 87 ff ff ff       	call   800969 <memmove>
}
  8009e2:	c9                   	leave  
  8009e3:	c3                   	ret    

008009e4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	56                   	push   %esi
  8009e8:	53                   	push   %ebx
  8009e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ef:	89 c6                	mov    %eax,%esi
  8009f1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f4:	eb 1a                	jmp    800a10 <memcmp+0x2c>
		if (*s1 != *s2)
  8009f6:	0f b6 08             	movzbl (%eax),%ecx
  8009f9:	0f b6 1a             	movzbl (%edx),%ebx
  8009fc:	38 d9                	cmp    %bl,%cl
  8009fe:	74 0a                	je     800a0a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a00:	0f b6 c1             	movzbl %cl,%eax
  800a03:	0f b6 db             	movzbl %bl,%ebx
  800a06:	29 d8                	sub    %ebx,%eax
  800a08:	eb 0f                	jmp    800a19 <memcmp+0x35>
		s1++, s2++;
  800a0a:	83 c0 01             	add    $0x1,%eax
  800a0d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a10:	39 f0                	cmp    %esi,%eax
  800a12:	75 e2                	jne    8009f6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a14:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a19:	5b                   	pop    %ebx
  800a1a:	5e                   	pop    %esi
  800a1b:	5d                   	pop    %ebp
  800a1c:	c3                   	ret    

00800a1d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	53                   	push   %ebx
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a24:	89 c1                	mov    %eax,%ecx
  800a26:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a29:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a2d:	eb 0a                	jmp    800a39 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a2f:	0f b6 10             	movzbl (%eax),%edx
  800a32:	39 da                	cmp    %ebx,%edx
  800a34:	74 07                	je     800a3d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a36:	83 c0 01             	add    $0x1,%eax
  800a39:	39 c8                	cmp    %ecx,%eax
  800a3b:	72 f2                	jb     800a2f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a3d:	5b                   	pop    %ebx
  800a3e:	5d                   	pop    %ebp
  800a3f:	c3                   	ret    

00800a40 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	57                   	push   %edi
  800a44:	56                   	push   %esi
  800a45:	53                   	push   %ebx
  800a46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a49:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4c:	eb 03                	jmp    800a51 <strtol+0x11>
		s++;
  800a4e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a51:	0f b6 01             	movzbl (%ecx),%eax
  800a54:	3c 20                	cmp    $0x20,%al
  800a56:	74 f6                	je     800a4e <strtol+0xe>
  800a58:	3c 09                	cmp    $0x9,%al
  800a5a:	74 f2                	je     800a4e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a5c:	3c 2b                	cmp    $0x2b,%al
  800a5e:	75 0a                	jne    800a6a <strtol+0x2a>
		s++;
  800a60:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a63:	bf 00 00 00 00       	mov    $0x0,%edi
  800a68:	eb 11                	jmp    800a7b <strtol+0x3b>
  800a6a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a6f:	3c 2d                	cmp    $0x2d,%al
  800a71:	75 08                	jne    800a7b <strtol+0x3b>
		s++, neg = 1;
  800a73:	83 c1 01             	add    $0x1,%ecx
  800a76:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a7b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a81:	75 15                	jne    800a98 <strtol+0x58>
  800a83:	80 39 30             	cmpb   $0x30,(%ecx)
  800a86:	75 10                	jne    800a98 <strtol+0x58>
  800a88:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a8c:	75 7c                	jne    800b0a <strtol+0xca>
		s += 2, base = 16;
  800a8e:	83 c1 02             	add    $0x2,%ecx
  800a91:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a96:	eb 16                	jmp    800aae <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a98:	85 db                	test   %ebx,%ebx
  800a9a:	75 12                	jne    800aae <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a9c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa1:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa4:	75 08                	jne    800aae <strtol+0x6e>
		s++, base = 8;
  800aa6:	83 c1 01             	add    $0x1,%ecx
  800aa9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aae:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ab6:	0f b6 11             	movzbl (%ecx),%edx
  800ab9:	8d 72 d0             	lea    -0x30(%edx),%esi
  800abc:	89 f3                	mov    %esi,%ebx
  800abe:	80 fb 09             	cmp    $0x9,%bl
  800ac1:	77 08                	ja     800acb <strtol+0x8b>
			dig = *s - '0';
  800ac3:	0f be d2             	movsbl %dl,%edx
  800ac6:	83 ea 30             	sub    $0x30,%edx
  800ac9:	eb 22                	jmp    800aed <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800acb:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ace:	89 f3                	mov    %esi,%ebx
  800ad0:	80 fb 19             	cmp    $0x19,%bl
  800ad3:	77 08                	ja     800add <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ad5:	0f be d2             	movsbl %dl,%edx
  800ad8:	83 ea 57             	sub    $0x57,%edx
  800adb:	eb 10                	jmp    800aed <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800add:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ae0:	89 f3                	mov    %esi,%ebx
  800ae2:	80 fb 19             	cmp    $0x19,%bl
  800ae5:	77 16                	ja     800afd <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ae7:	0f be d2             	movsbl %dl,%edx
  800aea:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aed:	3b 55 10             	cmp    0x10(%ebp),%edx
  800af0:	7d 0b                	jge    800afd <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800af2:	83 c1 01             	add    $0x1,%ecx
  800af5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800af9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800afb:	eb b9                	jmp    800ab6 <strtol+0x76>

	if (endptr)
  800afd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b01:	74 0d                	je     800b10 <strtol+0xd0>
		*endptr = (char *) s;
  800b03:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b06:	89 0e                	mov    %ecx,(%esi)
  800b08:	eb 06                	jmp    800b10 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b0a:	85 db                	test   %ebx,%ebx
  800b0c:	74 98                	je     800aa6 <strtol+0x66>
  800b0e:	eb 9e                	jmp    800aae <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b10:	89 c2                	mov    %eax,%edx
  800b12:	f7 da                	neg    %edx
  800b14:	85 ff                	test   %edi,%edi
  800b16:	0f 45 c2             	cmovne %edx,%eax
}
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b24:	b8 00 00 00 00       	mov    $0x0,%eax
  800b29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2f:	89 c3                	mov    %eax,%ebx
  800b31:	89 c7                	mov    %eax,%edi
  800b33:	89 c6                	mov    %eax,%esi
  800b35:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <sys_cgetc>:

int
sys_cgetc(void)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b42:	ba 00 00 00 00       	mov    $0x0,%edx
  800b47:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4c:	89 d1                	mov    %edx,%ecx
  800b4e:	89 d3                	mov    %edx,%ebx
  800b50:	89 d7                	mov    %edx,%edi
  800b52:	89 d6                	mov    %edx,%esi
  800b54:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b56:	5b                   	pop    %ebx
  800b57:	5e                   	pop    %esi
  800b58:	5f                   	pop    %edi
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	57                   	push   %edi
  800b5f:	56                   	push   %esi
  800b60:	53                   	push   %ebx
  800b61:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b64:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b69:	b8 03 00 00 00       	mov    $0x3,%eax
  800b6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b71:	89 cb                	mov    %ecx,%ebx
  800b73:	89 cf                	mov    %ecx,%edi
  800b75:	89 ce                	mov    %ecx,%esi
  800b77:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b79:	85 c0                	test   %eax,%eax
  800b7b:	7e 17                	jle    800b94 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7d:	83 ec 0c             	sub    $0xc,%esp
  800b80:	50                   	push   %eax
  800b81:	6a 03                	push   $0x3
  800b83:	68 ff 25 80 00       	push   $0x8025ff
  800b88:	6a 23                	push   $0x23
  800b8a:	68 1c 26 80 00       	push   $0x80261c
  800b8f:	e8 e5 f5 ff ff       	call   800179 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b97:	5b                   	pop    %ebx
  800b98:	5e                   	pop    %esi
  800b99:	5f                   	pop    %edi
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	57                   	push   %edi
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba7:	b8 02 00 00 00       	mov    $0x2,%eax
  800bac:	89 d1                	mov    %edx,%ecx
  800bae:	89 d3                	mov    %edx,%ebx
  800bb0:	89 d7                	mov    %edx,%edi
  800bb2:	89 d6                	mov    %edx,%esi
  800bb4:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bb6:	5b                   	pop    %ebx
  800bb7:	5e                   	pop    %esi
  800bb8:	5f                   	pop    %edi
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <sys_yield>:

void
sys_yield(void)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	57                   	push   %edi
  800bbf:	56                   	push   %esi
  800bc0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc1:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bcb:	89 d1                	mov    %edx,%ecx
  800bcd:	89 d3                	mov    %edx,%ebx
  800bcf:	89 d7                	mov    %edx,%edi
  800bd1:	89 d6                	mov    %edx,%esi
  800bd3:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5f                   	pop    %edi
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	57                   	push   %edi
  800bde:	56                   	push   %esi
  800bdf:	53                   	push   %ebx
  800be0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be3:	be 00 00 00 00       	mov    $0x0,%esi
  800be8:	b8 04 00 00 00       	mov    $0x4,%eax
  800bed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf6:	89 f7                	mov    %esi,%edi
  800bf8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfa:	85 c0                	test   %eax,%eax
  800bfc:	7e 17                	jle    800c15 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfe:	83 ec 0c             	sub    $0xc,%esp
  800c01:	50                   	push   %eax
  800c02:	6a 04                	push   $0x4
  800c04:	68 ff 25 80 00       	push   $0x8025ff
  800c09:	6a 23                	push   $0x23
  800c0b:	68 1c 26 80 00       	push   $0x80261c
  800c10:	e8 64 f5 ff ff       	call   800179 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	57                   	push   %edi
  800c21:	56                   	push   %esi
  800c22:	53                   	push   %ebx
  800c23:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c26:	b8 05 00 00 00       	mov    $0x5,%eax
  800c2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c31:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c34:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c37:	8b 75 18             	mov    0x18(%ebp),%esi
  800c3a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3c:	85 c0                	test   %eax,%eax
  800c3e:	7e 17                	jle    800c57 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c40:	83 ec 0c             	sub    $0xc,%esp
  800c43:	50                   	push   %eax
  800c44:	6a 05                	push   $0x5
  800c46:	68 ff 25 80 00       	push   $0x8025ff
  800c4b:	6a 23                	push   $0x23
  800c4d:	68 1c 26 80 00       	push   $0x80261c
  800c52:	e8 22 f5 ff ff       	call   800179 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5a:	5b                   	pop    %ebx
  800c5b:	5e                   	pop    %esi
  800c5c:	5f                   	pop    %edi
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    

00800c5f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	57                   	push   %edi
  800c63:	56                   	push   %esi
  800c64:	53                   	push   %ebx
  800c65:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c68:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6d:	b8 06 00 00 00       	mov    $0x6,%eax
  800c72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c75:	8b 55 08             	mov    0x8(%ebp),%edx
  800c78:	89 df                	mov    %ebx,%edi
  800c7a:	89 de                	mov    %ebx,%esi
  800c7c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7e:	85 c0                	test   %eax,%eax
  800c80:	7e 17                	jle    800c99 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c82:	83 ec 0c             	sub    $0xc,%esp
  800c85:	50                   	push   %eax
  800c86:	6a 06                	push   $0x6
  800c88:	68 ff 25 80 00       	push   $0x8025ff
  800c8d:	6a 23                	push   $0x23
  800c8f:	68 1c 26 80 00       	push   $0x80261c
  800c94:	e8 e0 f4 ff ff       	call   800179 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9c:	5b                   	pop    %ebx
  800c9d:	5e                   	pop    %esi
  800c9e:	5f                   	pop    %edi
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    

00800ca1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	57                   	push   %edi
  800ca5:	56                   	push   %esi
  800ca6:	53                   	push   %ebx
  800ca7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800caf:	b8 08 00 00 00       	mov    $0x8,%eax
  800cb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cba:	89 df                	mov    %ebx,%edi
  800cbc:	89 de                	mov    %ebx,%esi
  800cbe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc0:	85 c0                	test   %eax,%eax
  800cc2:	7e 17                	jle    800cdb <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc4:	83 ec 0c             	sub    $0xc,%esp
  800cc7:	50                   	push   %eax
  800cc8:	6a 08                	push   $0x8
  800cca:	68 ff 25 80 00       	push   $0x8025ff
  800ccf:	6a 23                	push   $0x23
  800cd1:	68 1c 26 80 00       	push   $0x80261c
  800cd6:	e8 9e f4 ff ff       	call   800179 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cde:	5b                   	pop    %ebx
  800cdf:	5e                   	pop    %esi
  800ce0:	5f                   	pop    %edi
  800ce1:	5d                   	pop    %ebp
  800ce2:	c3                   	ret    

00800ce3 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	57                   	push   %edi
  800ce7:	56                   	push   %esi
  800ce8:	53                   	push   %ebx
  800ce9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cec:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf1:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfc:	89 df                	mov    %ebx,%edi
  800cfe:	89 de                	mov    %ebx,%esi
  800d00:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d02:	85 c0                	test   %eax,%eax
  800d04:	7e 17                	jle    800d1d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d06:	83 ec 0c             	sub    $0xc,%esp
  800d09:	50                   	push   %eax
  800d0a:	6a 09                	push   $0x9
  800d0c:	68 ff 25 80 00       	push   $0x8025ff
  800d11:	6a 23                	push   $0x23
  800d13:	68 1c 26 80 00       	push   $0x80261c
  800d18:	e8 5c f4 ff ff       	call   800179 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    

00800d25 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	57                   	push   %edi
  800d29:	56                   	push   %esi
  800d2a:	53                   	push   %ebx
  800d2b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d33:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3e:	89 df                	mov    %ebx,%edi
  800d40:	89 de                	mov    %ebx,%esi
  800d42:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d44:	85 c0                	test   %eax,%eax
  800d46:	7e 17                	jle    800d5f <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d48:	83 ec 0c             	sub    $0xc,%esp
  800d4b:	50                   	push   %eax
  800d4c:	6a 0a                	push   $0xa
  800d4e:	68 ff 25 80 00       	push   $0x8025ff
  800d53:	6a 23                	push   $0x23
  800d55:	68 1c 26 80 00       	push   $0x80261c
  800d5a:	e8 1a f4 ff ff       	call   800179 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	57                   	push   %edi
  800d6b:	56                   	push   %esi
  800d6c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6d:	be 00 00 00 00       	mov    $0x0,%esi
  800d72:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d80:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d83:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5f                   	pop    %edi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	57                   	push   %edi
  800d8e:	56                   	push   %esi
  800d8f:	53                   	push   %ebx
  800d90:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d93:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d98:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800da0:	89 cb                	mov    %ecx,%ebx
  800da2:	89 cf                	mov    %ecx,%edi
  800da4:	89 ce                	mov    %ecx,%esi
  800da6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da8:	85 c0                	test   %eax,%eax
  800daa:	7e 17                	jle    800dc3 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dac:	83 ec 0c             	sub    $0xc,%esp
  800daf:	50                   	push   %eax
  800db0:	6a 0d                	push   $0xd
  800db2:	68 ff 25 80 00       	push   $0x8025ff
  800db7:	6a 23                	push   $0x23
  800db9:	68 1c 26 80 00       	push   $0x80261c
  800dbe:	e8 b6 f3 ff ff       	call   800179 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc6:	5b                   	pop    %ebx
  800dc7:	5e                   	pop    %esi
  800dc8:	5f                   	pop    %edi
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    

00800dcb <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	57                   	push   %edi
  800dcf:	56                   	push   %esi
  800dd0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd6:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ddb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dde:	89 cb                	mov    %ecx,%ebx
  800de0:	89 cf                	mov    %ecx,%edi
  800de2:	89 ce                	mov    %ecx,%esi
  800de4:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800de6:	5b                   	pop    %ebx
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	57                   	push   %edi
  800def:	56                   	push   %esi
  800df0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df6:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfe:	89 cb                	mov    %ecx,%ebx
  800e00:	89 cf                	mov    %ecx,%edi
  800e02:	89 ce                	mov    %ecx,%esi
  800e04:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800e06:	5b                   	pop    %ebx
  800e07:	5e                   	pop    %esi
  800e08:	5f                   	pop    %edi
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    

00800e0b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	53                   	push   %ebx
  800e0f:	83 ec 04             	sub    $0x4,%esp
  800e12:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e15:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800e17:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e1b:	74 11                	je     800e2e <pgfault+0x23>
  800e1d:	89 d8                	mov    %ebx,%eax
  800e1f:	c1 e8 0c             	shr    $0xc,%eax
  800e22:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e29:	f6 c4 08             	test   $0x8,%ah
  800e2c:	75 14                	jne    800e42 <pgfault+0x37>
		panic("faulting access");
  800e2e:	83 ec 04             	sub    $0x4,%esp
  800e31:	68 2a 26 80 00       	push   $0x80262a
  800e36:	6a 1e                	push   $0x1e
  800e38:	68 3a 26 80 00       	push   $0x80263a
  800e3d:	e8 37 f3 ff ff       	call   800179 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e42:	83 ec 04             	sub    $0x4,%esp
  800e45:	6a 07                	push   $0x7
  800e47:	68 00 f0 7f 00       	push   $0x7ff000
  800e4c:	6a 00                	push   $0x0
  800e4e:	e8 87 fd ff ff       	call   800bda <sys_page_alloc>
	if (r < 0) {
  800e53:	83 c4 10             	add    $0x10,%esp
  800e56:	85 c0                	test   %eax,%eax
  800e58:	79 12                	jns    800e6c <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e5a:	50                   	push   %eax
  800e5b:	68 45 26 80 00       	push   $0x802645
  800e60:	6a 2c                	push   $0x2c
  800e62:	68 3a 26 80 00       	push   $0x80263a
  800e67:	e8 0d f3 ff ff       	call   800179 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e6c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e72:	83 ec 04             	sub    $0x4,%esp
  800e75:	68 00 10 00 00       	push   $0x1000
  800e7a:	53                   	push   %ebx
  800e7b:	68 00 f0 7f 00       	push   $0x7ff000
  800e80:	e8 4c fb ff ff       	call   8009d1 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e85:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e8c:	53                   	push   %ebx
  800e8d:	6a 00                	push   $0x0
  800e8f:	68 00 f0 7f 00       	push   $0x7ff000
  800e94:	6a 00                	push   $0x0
  800e96:	e8 82 fd ff ff       	call   800c1d <sys_page_map>
	if (r < 0) {
  800e9b:	83 c4 20             	add    $0x20,%esp
  800e9e:	85 c0                	test   %eax,%eax
  800ea0:	79 12                	jns    800eb4 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800ea2:	50                   	push   %eax
  800ea3:	68 45 26 80 00       	push   $0x802645
  800ea8:	6a 33                	push   $0x33
  800eaa:	68 3a 26 80 00       	push   $0x80263a
  800eaf:	e8 c5 f2 ff ff       	call   800179 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800eb4:	83 ec 08             	sub    $0x8,%esp
  800eb7:	68 00 f0 7f 00       	push   $0x7ff000
  800ebc:	6a 00                	push   $0x0
  800ebe:	e8 9c fd ff ff       	call   800c5f <sys_page_unmap>
	if (r < 0) {
  800ec3:	83 c4 10             	add    $0x10,%esp
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	79 12                	jns    800edc <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800eca:	50                   	push   %eax
  800ecb:	68 45 26 80 00       	push   $0x802645
  800ed0:	6a 37                	push   $0x37
  800ed2:	68 3a 26 80 00       	push   $0x80263a
  800ed7:	e8 9d f2 ff ff       	call   800179 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800edc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800edf:	c9                   	leave  
  800ee0:	c3                   	ret    

00800ee1 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
  800ee4:	57                   	push   %edi
  800ee5:	56                   	push   %esi
  800ee6:	53                   	push   %ebx
  800ee7:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800eea:	68 0b 0e 80 00       	push   $0x800e0b
  800eef:	e8 fe 0e 00 00       	call   801df2 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ef4:	b8 07 00 00 00       	mov    $0x7,%eax
  800ef9:	cd 30                	int    $0x30
  800efb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800efe:	83 c4 10             	add    $0x10,%esp
  800f01:	85 c0                	test   %eax,%eax
  800f03:	79 17                	jns    800f1c <fork+0x3b>
		panic("fork fault %e");
  800f05:	83 ec 04             	sub    $0x4,%esp
  800f08:	68 5e 26 80 00       	push   $0x80265e
  800f0d:	68 84 00 00 00       	push   $0x84
  800f12:	68 3a 26 80 00       	push   $0x80263a
  800f17:	e8 5d f2 ff ff       	call   800179 <_panic>
  800f1c:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f1e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f22:	75 24                	jne    800f48 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f24:	e8 73 fc ff ff       	call   800b9c <sys_getenvid>
  800f29:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f2e:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800f34:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f39:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800f3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f43:	e9 64 01 00 00       	jmp    8010ac <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f48:	83 ec 04             	sub    $0x4,%esp
  800f4b:	6a 07                	push   $0x7
  800f4d:	68 00 f0 bf ee       	push   $0xeebff000
  800f52:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f55:	e8 80 fc ff ff       	call   800bda <sys_page_alloc>
  800f5a:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f5d:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f62:	89 d8                	mov    %ebx,%eax
  800f64:	c1 e8 16             	shr    $0x16,%eax
  800f67:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f6e:	a8 01                	test   $0x1,%al
  800f70:	0f 84 fc 00 00 00    	je     801072 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f76:	89 d8                	mov    %ebx,%eax
  800f78:	c1 e8 0c             	shr    $0xc,%eax
  800f7b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f82:	f6 c2 01             	test   $0x1,%dl
  800f85:	0f 84 e7 00 00 00    	je     801072 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f8b:	89 c6                	mov    %eax,%esi
  800f8d:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f90:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f97:	f6 c6 04             	test   $0x4,%dh
  800f9a:	74 39                	je     800fd5 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f9c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fa3:	83 ec 0c             	sub    $0xc,%esp
  800fa6:	25 07 0e 00 00       	and    $0xe07,%eax
  800fab:	50                   	push   %eax
  800fac:	56                   	push   %esi
  800fad:	57                   	push   %edi
  800fae:	56                   	push   %esi
  800faf:	6a 00                	push   $0x0
  800fb1:	e8 67 fc ff ff       	call   800c1d <sys_page_map>
		if (r < 0) {
  800fb6:	83 c4 20             	add    $0x20,%esp
  800fb9:	85 c0                	test   %eax,%eax
  800fbb:	0f 89 b1 00 00 00    	jns    801072 <fork+0x191>
		    	panic("sys page map fault %e");
  800fc1:	83 ec 04             	sub    $0x4,%esp
  800fc4:	68 6c 26 80 00       	push   $0x80266c
  800fc9:	6a 54                	push   $0x54
  800fcb:	68 3a 26 80 00       	push   $0x80263a
  800fd0:	e8 a4 f1 ff ff       	call   800179 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800fd5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fdc:	f6 c2 02             	test   $0x2,%dl
  800fdf:	75 0c                	jne    800fed <fork+0x10c>
  800fe1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fe8:	f6 c4 08             	test   $0x8,%ah
  800feb:	74 5b                	je     801048 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800fed:	83 ec 0c             	sub    $0xc,%esp
  800ff0:	68 05 08 00 00       	push   $0x805
  800ff5:	56                   	push   %esi
  800ff6:	57                   	push   %edi
  800ff7:	56                   	push   %esi
  800ff8:	6a 00                	push   $0x0
  800ffa:	e8 1e fc ff ff       	call   800c1d <sys_page_map>
		if (r < 0) {
  800fff:	83 c4 20             	add    $0x20,%esp
  801002:	85 c0                	test   %eax,%eax
  801004:	79 14                	jns    80101a <fork+0x139>
		    	panic("sys page map fault %e");
  801006:	83 ec 04             	sub    $0x4,%esp
  801009:	68 6c 26 80 00       	push   $0x80266c
  80100e:	6a 5b                	push   $0x5b
  801010:	68 3a 26 80 00       	push   $0x80263a
  801015:	e8 5f f1 ff ff       	call   800179 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  80101a:	83 ec 0c             	sub    $0xc,%esp
  80101d:	68 05 08 00 00       	push   $0x805
  801022:	56                   	push   %esi
  801023:	6a 00                	push   $0x0
  801025:	56                   	push   %esi
  801026:	6a 00                	push   $0x0
  801028:	e8 f0 fb ff ff       	call   800c1d <sys_page_map>
		if (r < 0) {
  80102d:	83 c4 20             	add    $0x20,%esp
  801030:	85 c0                	test   %eax,%eax
  801032:	79 3e                	jns    801072 <fork+0x191>
		    	panic("sys page map fault %e");
  801034:	83 ec 04             	sub    $0x4,%esp
  801037:	68 6c 26 80 00       	push   $0x80266c
  80103c:	6a 5f                	push   $0x5f
  80103e:	68 3a 26 80 00       	push   $0x80263a
  801043:	e8 31 f1 ff ff       	call   800179 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801048:	83 ec 0c             	sub    $0xc,%esp
  80104b:	6a 05                	push   $0x5
  80104d:	56                   	push   %esi
  80104e:	57                   	push   %edi
  80104f:	56                   	push   %esi
  801050:	6a 00                	push   $0x0
  801052:	e8 c6 fb ff ff       	call   800c1d <sys_page_map>
		if (r < 0) {
  801057:	83 c4 20             	add    $0x20,%esp
  80105a:	85 c0                	test   %eax,%eax
  80105c:	79 14                	jns    801072 <fork+0x191>
		    	panic("sys page map fault %e");
  80105e:	83 ec 04             	sub    $0x4,%esp
  801061:	68 6c 26 80 00       	push   $0x80266c
  801066:	6a 64                	push   $0x64
  801068:	68 3a 26 80 00       	push   $0x80263a
  80106d:	e8 07 f1 ff ff       	call   800179 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801072:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801078:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80107e:	0f 85 de fe ff ff    	jne    800f62 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801084:	a1 08 40 80 00       	mov    0x804008,%eax
  801089:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  80108f:	83 ec 08             	sub    $0x8,%esp
  801092:	50                   	push   %eax
  801093:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801096:	57                   	push   %edi
  801097:	e8 89 fc ff ff       	call   800d25 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80109c:	83 c4 08             	add    $0x8,%esp
  80109f:	6a 02                	push   $0x2
  8010a1:	57                   	push   %edi
  8010a2:	e8 fa fb ff ff       	call   800ca1 <sys_env_set_status>
	
	return envid;
  8010a7:	83 c4 10             	add    $0x10,%esp
  8010aa:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8010ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010af:	5b                   	pop    %ebx
  8010b0:	5e                   	pop    %esi
  8010b1:	5f                   	pop    %edi
  8010b2:	5d                   	pop    %ebp
  8010b3:	c3                   	ret    

008010b4 <sfork>:

envid_t
sfork(void)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
	return 0;
}
  8010b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8010bc:	5d                   	pop    %ebp
  8010bd:	c3                   	ret    

008010be <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8010be:	55                   	push   %ebp
  8010bf:	89 e5                	mov    %esp,%ebp
  8010c1:	56                   	push   %esi
  8010c2:	53                   	push   %ebx
  8010c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  8010c6:	89 1d 0c 40 80 00    	mov    %ebx,0x80400c
	cprintf("in fork.c thread create. func: %x\n", func);
  8010cc:	83 ec 08             	sub    $0x8,%esp
  8010cf:	53                   	push   %ebx
  8010d0:	68 84 26 80 00       	push   $0x802684
  8010d5:	e8 78 f1 ff ff       	call   800252 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8010da:	c7 04 24 3f 01 80 00 	movl   $0x80013f,(%esp)
  8010e1:	e8 e5 fc ff ff       	call   800dcb <sys_thread_create>
  8010e6:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8010e8:	83 c4 08             	add    $0x8,%esp
  8010eb:	53                   	push   %ebx
  8010ec:	68 84 26 80 00       	push   $0x802684
  8010f1:	e8 5c f1 ff ff       	call   800252 <cprintf>
	return id;
}
  8010f6:	89 f0                	mov    %esi,%eax
  8010f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010fb:	5b                   	pop    %ebx
  8010fc:	5e                   	pop    %esi
  8010fd:	5d                   	pop    %ebp
  8010fe:	c3                   	ret    

008010ff <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801102:	8b 45 08             	mov    0x8(%ebp),%eax
  801105:	05 00 00 00 30       	add    $0x30000000,%eax
  80110a:	c1 e8 0c             	shr    $0xc,%eax
}
  80110d:	5d                   	pop    %ebp
  80110e:	c3                   	ret    

0080110f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80110f:	55                   	push   %ebp
  801110:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801112:	8b 45 08             	mov    0x8(%ebp),%eax
  801115:	05 00 00 00 30       	add    $0x30000000,%eax
  80111a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80111f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801124:	5d                   	pop    %ebp
  801125:	c3                   	ret    

00801126 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801126:	55                   	push   %ebp
  801127:	89 e5                	mov    %esp,%ebp
  801129:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80112c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801131:	89 c2                	mov    %eax,%edx
  801133:	c1 ea 16             	shr    $0x16,%edx
  801136:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80113d:	f6 c2 01             	test   $0x1,%dl
  801140:	74 11                	je     801153 <fd_alloc+0x2d>
  801142:	89 c2                	mov    %eax,%edx
  801144:	c1 ea 0c             	shr    $0xc,%edx
  801147:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80114e:	f6 c2 01             	test   $0x1,%dl
  801151:	75 09                	jne    80115c <fd_alloc+0x36>
			*fd_store = fd;
  801153:	89 01                	mov    %eax,(%ecx)
			return 0;
  801155:	b8 00 00 00 00       	mov    $0x0,%eax
  80115a:	eb 17                	jmp    801173 <fd_alloc+0x4d>
  80115c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801161:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801166:	75 c9                	jne    801131 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801168:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80116e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801173:	5d                   	pop    %ebp
  801174:	c3                   	ret    

00801175 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801175:	55                   	push   %ebp
  801176:	89 e5                	mov    %esp,%ebp
  801178:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80117b:	83 f8 1f             	cmp    $0x1f,%eax
  80117e:	77 36                	ja     8011b6 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801180:	c1 e0 0c             	shl    $0xc,%eax
  801183:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801188:	89 c2                	mov    %eax,%edx
  80118a:	c1 ea 16             	shr    $0x16,%edx
  80118d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801194:	f6 c2 01             	test   $0x1,%dl
  801197:	74 24                	je     8011bd <fd_lookup+0x48>
  801199:	89 c2                	mov    %eax,%edx
  80119b:	c1 ea 0c             	shr    $0xc,%edx
  80119e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011a5:	f6 c2 01             	test   $0x1,%dl
  8011a8:	74 1a                	je     8011c4 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ad:	89 02                	mov    %eax,(%edx)
	return 0;
  8011af:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b4:	eb 13                	jmp    8011c9 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011bb:	eb 0c                	jmp    8011c9 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011c2:	eb 05                	jmp    8011c9 <fd_lookup+0x54>
  8011c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011c9:	5d                   	pop    %ebp
  8011ca:	c3                   	ret    

008011cb <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011cb:	55                   	push   %ebp
  8011cc:	89 e5                	mov    %esp,%ebp
  8011ce:	83 ec 08             	sub    $0x8,%esp
  8011d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011d4:	ba 28 27 80 00       	mov    $0x802728,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011d9:	eb 13                	jmp    8011ee <dev_lookup+0x23>
  8011db:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011de:	39 08                	cmp    %ecx,(%eax)
  8011e0:	75 0c                	jne    8011ee <dev_lookup+0x23>
			*dev = devtab[i];
  8011e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ec:	eb 2e                	jmp    80121c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011ee:	8b 02                	mov    (%edx),%eax
  8011f0:	85 c0                	test   %eax,%eax
  8011f2:	75 e7                	jne    8011db <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011f4:	a1 08 40 80 00       	mov    0x804008,%eax
  8011f9:	8b 40 7c             	mov    0x7c(%eax),%eax
  8011fc:	83 ec 04             	sub    $0x4,%esp
  8011ff:	51                   	push   %ecx
  801200:	50                   	push   %eax
  801201:	68 a8 26 80 00       	push   $0x8026a8
  801206:	e8 47 f0 ff ff       	call   800252 <cprintf>
	*dev = 0;
  80120b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80120e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801214:	83 c4 10             	add    $0x10,%esp
  801217:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80121c:	c9                   	leave  
  80121d:	c3                   	ret    

0080121e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80121e:	55                   	push   %ebp
  80121f:	89 e5                	mov    %esp,%ebp
  801221:	56                   	push   %esi
  801222:	53                   	push   %ebx
  801223:	83 ec 10             	sub    $0x10,%esp
  801226:	8b 75 08             	mov    0x8(%ebp),%esi
  801229:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80122c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122f:	50                   	push   %eax
  801230:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801236:	c1 e8 0c             	shr    $0xc,%eax
  801239:	50                   	push   %eax
  80123a:	e8 36 ff ff ff       	call   801175 <fd_lookup>
  80123f:	83 c4 08             	add    $0x8,%esp
  801242:	85 c0                	test   %eax,%eax
  801244:	78 05                	js     80124b <fd_close+0x2d>
	    || fd != fd2)
  801246:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801249:	74 0c                	je     801257 <fd_close+0x39>
		return (must_exist ? r : 0);
  80124b:	84 db                	test   %bl,%bl
  80124d:	ba 00 00 00 00       	mov    $0x0,%edx
  801252:	0f 44 c2             	cmove  %edx,%eax
  801255:	eb 41                	jmp    801298 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801257:	83 ec 08             	sub    $0x8,%esp
  80125a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80125d:	50                   	push   %eax
  80125e:	ff 36                	pushl  (%esi)
  801260:	e8 66 ff ff ff       	call   8011cb <dev_lookup>
  801265:	89 c3                	mov    %eax,%ebx
  801267:	83 c4 10             	add    $0x10,%esp
  80126a:	85 c0                	test   %eax,%eax
  80126c:	78 1a                	js     801288 <fd_close+0x6a>
		if (dev->dev_close)
  80126e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801271:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801274:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801279:	85 c0                	test   %eax,%eax
  80127b:	74 0b                	je     801288 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80127d:	83 ec 0c             	sub    $0xc,%esp
  801280:	56                   	push   %esi
  801281:	ff d0                	call   *%eax
  801283:	89 c3                	mov    %eax,%ebx
  801285:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801288:	83 ec 08             	sub    $0x8,%esp
  80128b:	56                   	push   %esi
  80128c:	6a 00                	push   $0x0
  80128e:	e8 cc f9 ff ff       	call   800c5f <sys_page_unmap>
	return r;
  801293:	83 c4 10             	add    $0x10,%esp
  801296:	89 d8                	mov    %ebx,%eax
}
  801298:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80129b:	5b                   	pop    %ebx
  80129c:	5e                   	pop    %esi
  80129d:	5d                   	pop    %ebp
  80129e:	c3                   	ret    

0080129f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a8:	50                   	push   %eax
  8012a9:	ff 75 08             	pushl  0x8(%ebp)
  8012ac:	e8 c4 fe ff ff       	call   801175 <fd_lookup>
  8012b1:	83 c4 08             	add    $0x8,%esp
  8012b4:	85 c0                	test   %eax,%eax
  8012b6:	78 10                	js     8012c8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012b8:	83 ec 08             	sub    $0x8,%esp
  8012bb:	6a 01                	push   $0x1
  8012bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8012c0:	e8 59 ff ff ff       	call   80121e <fd_close>
  8012c5:	83 c4 10             	add    $0x10,%esp
}
  8012c8:	c9                   	leave  
  8012c9:	c3                   	ret    

008012ca <close_all>:

void
close_all(void)
{
  8012ca:	55                   	push   %ebp
  8012cb:	89 e5                	mov    %esp,%ebp
  8012cd:	53                   	push   %ebx
  8012ce:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012d1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012d6:	83 ec 0c             	sub    $0xc,%esp
  8012d9:	53                   	push   %ebx
  8012da:	e8 c0 ff ff ff       	call   80129f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012df:	83 c3 01             	add    $0x1,%ebx
  8012e2:	83 c4 10             	add    $0x10,%esp
  8012e5:	83 fb 20             	cmp    $0x20,%ebx
  8012e8:	75 ec                	jne    8012d6 <close_all+0xc>
		close(i);
}
  8012ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ed:	c9                   	leave  
  8012ee:	c3                   	ret    

008012ef <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012ef:	55                   	push   %ebp
  8012f0:	89 e5                	mov    %esp,%ebp
  8012f2:	57                   	push   %edi
  8012f3:	56                   	push   %esi
  8012f4:	53                   	push   %ebx
  8012f5:	83 ec 2c             	sub    $0x2c,%esp
  8012f8:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012fb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012fe:	50                   	push   %eax
  8012ff:	ff 75 08             	pushl  0x8(%ebp)
  801302:	e8 6e fe ff ff       	call   801175 <fd_lookup>
  801307:	83 c4 08             	add    $0x8,%esp
  80130a:	85 c0                	test   %eax,%eax
  80130c:	0f 88 c1 00 00 00    	js     8013d3 <dup+0xe4>
		return r;
	close(newfdnum);
  801312:	83 ec 0c             	sub    $0xc,%esp
  801315:	56                   	push   %esi
  801316:	e8 84 ff ff ff       	call   80129f <close>

	newfd = INDEX2FD(newfdnum);
  80131b:	89 f3                	mov    %esi,%ebx
  80131d:	c1 e3 0c             	shl    $0xc,%ebx
  801320:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801326:	83 c4 04             	add    $0x4,%esp
  801329:	ff 75 e4             	pushl  -0x1c(%ebp)
  80132c:	e8 de fd ff ff       	call   80110f <fd2data>
  801331:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801333:	89 1c 24             	mov    %ebx,(%esp)
  801336:	e8 d4 fd ff ff       	call   80110f <fd2data>
  80133b:	83 c4 10             	add    $0x10,%esp
  80133e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801341:	89 f8                	mov    %edi,%eax
  801343:	c1 e8 16             	shr    $0x16,%eax
  801346:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80134d:	a8 01                	test   $0x1,%al
  80134f:	74 37                	je     801388 <dup+0x99>
  801351:	89 f8                	mov    %edi,%eax
  801353:	c1 e8 0c             	shr    $0xc,%eax
  801356:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80135d:	f6 c2 01             	test   $0x1,%dl
  801360:	74 26                	je     801388 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801362:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801369:	83 ec 0c             	sub    $0xc,%esp
  80136c:	25 07 0e 00 00       	and    $0xe07,%eax
  801371:	50                   	push   %eax
  801372:	ff 75 d4             	pushl  -0x2c(%ebp)
  801375:	6a 00                	push   $0x0
  801377:	57                   	push   %edi
  801378:	6a 00                	push   $0x0
  80137a:	e8 9e f8 ff ff       	call   800c1d <sys_page_map>
  80137f:	89 c7                	mov    %eax,%edi
  801381:	83 c4 20             	add    $0x20,%esp
  801384:	85 c0                	test   %eax,%eax
  801386:	78 2e                	js     8013b6 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801388:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80138b:	89 d0                	mov    %edx,%eax
  80138d:	c1 e8 0c             	shr    $0xc,%eax
  801390:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801397:	83 ec 0c             	sub    $0xc,%esp
  80139a:	25 07 0e 00 00       	and    $0xe07,%eax
  80139f:	50                   	push   %eax
  8013a0:	53                   	push   %ebx
  8013a1:	6a 00                	push   $0x0
  8013a3:	52                   	push   %edx
  8013a4:	6a 00                	push   $0x0
  8013a6:	e8 72 f8 ff ff       	call   800c1d <sys_page_map>
  8013ab:	89 c7                	mov    %eax,%edi
  8013ad:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013b0:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013b2:	85 ff                	test   %edi,%edi
  8013b4:	79 1d                	jns    8013d3 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013b6:	83 ec 08             	sub    $0x8,%esp
  8013b9:	53                   	push   %ebx
  8013ba:	6a 00                	push   $0x0
  8013bc:	e8 9e f8 ff ff       	call   800c5f <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013c1:	83 c4 08             	add    $0x8,%esp
  8013c4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013c7:	6a 00                	push   $0x0
  8013c9:	e8 91 f8 ff ff       	call   800c5f <sys_page_unmap>
	return r;
  8013ce:	83 c4 10             	add    $0x10,%esp
  8013d1:	89 f8                	mov    %edi,%eax
}
  8013d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d6:	5b                   	pop    %ebx
  8013d7:	5e                   	pop    %esi
  8013d8:	5f                   	pop    %edi
  8013d9:	5d                   	pop    %ebp
  8013da:	c3                   	ret    

008013db <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013db:	55                   	push   %ebp
  8013dc:	89 e5                	mov    %esp,%ebp
  8013de:	53                   	push   %ebx
  8013df:	83 ec 14             	sub    $0x14,%esp
  8013e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e8:	50                   	push   %eax
  8013e9:	53                   	push   %ebx
  8013ea:	e8 86 fd ff ff       	call   801175 <fd_lookup>
  8013ef:	83 c4 08             	add    $0x8,%esp
  8013f2:	89 c2                	mov    %eax,%edx
  8013f4:	85 c0                	test   %eax,%eax
  8013f6:	78 6d                	js     801465 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f8:	83 ec 08             	sub    $0x8,%esp
  8013fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fe:	50                   	push   %eax
  8013ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801402:	ff 30                	pushl  (%eax)
  801404:	e8 c2 fd ff ff       	call   8011cb <dev_lookup>
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	85 c0                	test   %eax,%eax
  80140e:	78 4c                	js     80145c <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801410:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801413:	8b 42 08             	mov    0x8(%edx),%eax
  801416:	83 e0 03             	and    $0x3,%eax
  801419:	83 f8 01             	cmp    $0x1,%eax
  80141c:	75 21                	jne    80143f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80141e:	a1 08 40 80 00       	mov    0x804008,%eax
  801423:	8b 40 7c             	mov    0x7c(%eax),%eax
  801426:	83 ec 04             	sub    $0x4,%esp
  801429:	53                   	push   %ebx
  80142a:	50                   	push   %eax
  80142b:	68 ec 26 80 00       	push   $0x8026ec
  801430:	e8 1d ee ff ff       	call   800252 <cprintf>
		return -E_INVAL;
  801435:	83 c4 10             	add    $0x10,%esp
  801438:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80143d:	eb 26                	jmp    801465 <read+0x8a>
	}
	if (!dev->dev_read)
  80143f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801442:	8b 40 08             	mov    0x8(%eax),%eax
  801445:	85 c0                	test   %eax,%eax
  801447:	74 17                	je     801460 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801449:	83 ec 04             	sub    $0x4,%esp
  80144c:	ff 75 10             	pushl  0x10(%ebp)
  80144f:	ff 75 0c             	pushl  0xc(%ebp)
  801452:	52                   	push   %edx
  801453:	ff d0                	call   *%eax
  801455:	89 c2                	mov    %eax,%edx
  801457:	83 c4 10             	add    $0x10,%esp
  80145a:	eb 09                	jmp    801465 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80145c:	89 c2                	mov    %eax,%edx
  80145e:	eb 05                	jmp    801465 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801460:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801465:	89 d0                	mov    %edx,%eax
  801467:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80146a:	c9                   	leave  
  80146b:	c3                   	ret    

0080146c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80146c:	55                   	push   %ebp
  80146d:	89 e5                	mov    %esp,%ebp
  80146f:	57                   	push   %edi
  801470:	56                   	push   %esi
  801471:	53                   	push   %ebx
  801472:	83 ec 0c             	sub    $0xc,%esp
  801475:	8b 7d 08             	mov    0x8(%ebp),%edi
  801478:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80147b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801480:	eb 21                	jmp    8014a3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801482:	83 ec 04             	sub    $0x4,%esp
  801485:	89 f0                	mov    %esi,%eax
  801487:	29 d8                	sub    %ebx,%eax
  801489:	50                   	push   %eax
  80148a:	89 d8                	mov    %ebx,%eax
  80148c:	03 45 0c             	add    0xc(%ebp),%eax
  80148f:	50                   	push   %eax
  801490:	57                   	push   %edi
  801491:	e8 45 ff ff ff       	call   8013db <read>
		if (m < 0)
  801496:	83 c4 10             	add    $0x10,%esp
  801499:	85 c0                	test   %eax,%eax
  80149b:	78 10                	js     8014ad <readn+0x41>
			return m;
		if (m == 0)
  80149d:	85 c0                	test   %eax,%eax
  80149f:	74 0a                	je     8014ab <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014a1:	01 c3                	add    %eax,%ebx
  8014a3:	39 f3                	cmp    %esi,%ebx
  8014a5:	72 db                	jb     801482 <readn+0x16>
  8014a7:	89 d8                	mov    %ebx,%eax
  8014a9:	eb 02                	jmp    8014ad <readn+0x41>
  8014ab:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b0:	5b                   	pop    %ebx
  8014b1:	5e                   	pop    %esi
  8014b2:	5f                   	pop    %edi
  8014b3:	5d                   	pop    %ebp
  8014b4:	c3                   	ret    

008014b5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014b5:	55                   	push   %ebp
  8014b6:	89 e5                	mov    %esp,%ebp
  8014b8:	53                   	push   %ebx
  8014b9:	83 ec 14             	sub    $0x14,%esp
  8014bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c2:	50                   	push   %eax
  8014c3:	53                   	push   %ebx
  8014c4:	e8 ac fc ff ff       	call   801175 <fd_lookup>
  8014c9:	83 c4 08             	add    $0x8,%esp
  8014cc:	89 c2                	mov    %eax,%edx
  8014ce:	85 c0                	test   %eax,%eax
  8014d0:	78 68                	js     80153a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d2:	83 ec 08             	sub    $0x8,%esp
  8014d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d8:	50                   	push   %eax
  8014d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014dc:	ff 30                	pushl  (%eax)
  8014de:	e8 e8 fc ff ff       	call   8011cb <dev_lookup>
  8014e3:	83 c4 10             	add    $0x10,%esp
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	78 47                	js     801531 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ed:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014f1:	75 21                	jne    801514 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f3:	a1 08 40 80 00       	mov    0x804008,%eax
  8014f8:	8b 40 7c             	mov    0x7c(%eax),%eax
  8014fb:	83 ec 04             	sub    $0x4,%esp
  8014fe:	53                   	push   %ebx
  8014ff:	50                   	push   %eax
  801500:	68 08 27 80 00       	push   $0x802708
  801505:	e8 48 ed ff ff       	call   800252 <cprintf>
		return -E_INVAL;
  80150a:	83 c4 10             	add    $0x10,%esp
  80150d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801512:	eb 26                	jmp    80153a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801514:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801517:	8b 52 0c             	mov    0xc(%edx),%edx
  80151a:	85 d2                	test   %edx,%edx
  80151c:	74 17                	je     801535 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80151e:	83 ec 04             	sub    $0x4,%esp
  801521:	ff 75 10             	pushl  0x10(%ebp)
  801524:	ff 75 0c             	pushl  0xc(%ebp)
  801527:	50                   	push   %eax
  801528:	ff d2                	call   *%edx
  80152a:	89 c2                	mov    %eax,%edx
  80152c:	83 c4 10             	add    $0x10,%esp
  80152f:	eb 09                	jmp    80153a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801531:	89 c2                	mov    %eax,%edx
  801533:	eb 05                	jmp    80153a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801535:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80153a:	89 d0                	mov    %edx,%eax
  80153c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153f:	c9                   	leave  
  801540:	c3                   	ret    

00801541 <seek>:

int
seek(int fdnum, off_t offset)
{
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
  801544:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801547:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80154a:	50                   	push   %eax
  80154b:	ff 75 08             	pushl  0x8(%ebp)
  80154e:	e8 22 fc ff ff       	call   801175 <fd_lookup>
  801553:	83 c4 08             	add    $0x8,%esp
  801556:	85 c0                	test   %eax,%eax
  801558:	78 0e                	js     801568 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80155a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80155d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801560:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801563:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801568:	c9                   	leave  
  801569:	c3                   	ret    

0080156a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	53                   	push   %ebx
  80156e:	83 ec 14             	sub    $0x14,%esp
  801571:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801574:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801577:	50                   	push   %eax
  801578:	53                   	push   %ebx
  801579:	e8 f7 fb ff ff       	call   801175 <fd_lookup>
  80157e:	83 c4 08             	add    $0x8,%esp
  801581:	89 c2                	mov    %eax,%edx
  801583:	85 c0                	test   %eax,%eax
  801585:	78 65                	js     8015ec <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801587:	83 ec 08             	sub    $0x8,%esp
  80158a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158d:	50                   	push   %eax
  80158e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801591:	ff 30                	pushl  (%eax)
  801593:	e8 33 fc ff ff       	call   8011cb <dev_lookup>
  801598:	83 c4 10             	add    $0x10,%esp
  80159b:	85 c0                	test   %eax,%eax
  80159d:	78 44                	js     8015e3 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80159f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015a6:	75 21                	jne    8015c9 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015a8:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015ad:	8b 40 7c             	mov    0x7c(%eax),%eax
  8015b0:	83 ec 04             	sub    $0x4,%esp
  8015b3:	53                   	push   %ebx
  8015b4:	50                   	push   %eax
  8015b5:	68 c8 26 80 00       	push   $0x8026c8
  8015ba:	e8 93 ec ff ff       	call   800252 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015bf:	83 c4 10             	add    $0x10,%esp
  8015c2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015c7:	eb 23                	jmp    8015ec <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015cc:	8b 52 18             	mov    0x18(%edx),%edx
  8015cf:	85 d2                	test   %edx,%edx
  8015d1:	74 14                	je     8015e7 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015d3:	83 ec 08             	sub    $0x8,%esp
  8015d6:	ff 75 0c             	pushl  0xc(%ebp)
  8015d9:	50                   	push   %eax
  8015da:	ff d2                	call   *%edx
  8015dc:	89 c2                	mov    %eax,%edx
  8015de:	83 c4 10             	add    $0x10,%esp
  8015e1:	eb 09                	jmp    8015ec <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e3:	89 c2                	mov    %eax,%edx
  8015e5:	eb 05                	jmp    8015ec <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015e7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015ec:	89 d0                	mov    %edx,%eax
  8015ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f1:	c9                   	leave  
  8015f2:	c3                   	ret    

008015f3 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015f3:	55                   	push   %ebp
  8015f4:	89 e5                	mov    %esp,%ebp
  8015f6:	53                   	push   %ebx
  8015f7:	83 ec 14             	sub    $0x14,%esp
  8015fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801600:	50                   	push   %eax
  801601:	ff 75 08             	pushl  0x8(%ebp)
  801604:	e8 6c fb ff ff       	call   801175 <fd_lookup>
  801609:	83 c4 08             	add    $0x8,%esp
  80160c:	89 c2                	mov    %eax,%edx
  80160e:	85 c0                	test   %eax,%eax
  801610:	78 58                	js     80166a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801612:	83 ec 08             	sub    $0x8,%esp
  801615:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801618:	50                   	push   %eax
  801619:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161c:	ff 30                	pushl  (%eax)
  80161e:	e8 a8 fb ff ff       	call   8011cb <dev_lookup>
  801623:	83 c4 10             	add    $0x10,%esp
  801626:	85 c0                	test   %eax,%eax
  801628:	78 37                	js     801661 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80162a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801631:	74 32                	je     801665 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801633:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801636:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80163d:	00 00 00 
	stat->st_isdir = 0;
  801640:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801647:	00 00 00 
	stat->st_dev = dev;
  80164a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801650:	83 ec 08             	sub    $0x8,%esp
  801653:	53                   	push   %ebx
  801654:	ff 75 f0             	pushl  -0x10(%ebp)
  801657:	ff 50 14             	call   *0x14(%eax)
  80165a:	89 c2                	mov    %eax,%edx
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	eb 09                	jmp    80166a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801661:	89 c2                	mov    %eax,%edx
  801663:	eb 05                	jmp    80166a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801665:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80166a:	89 d0                	mov    %edx,%eax
  80166c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166f:	c9                   	leave  
  801670:	c3                   	ret    

00801671 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	56                   	push   %esi
  801675:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801676:	83 ec 08             	sub    $0x8,%esp
  801679:	6a 00                	push   $0x0
  80167b:	ff 75 08             	pushl  0x8(%ebp)
  80167e:	e8 e3 01 00 00       	call   801866 <open>
  801683:	89 c3                	mov    %eax,%ebx
  801685:	83 c4 10             	add    $0x10,%esp
  801688:	85 c0                	test   %eax,%eax
  80168a:	78 1b                	js     8016a7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80168c:	83 ec 08             	sub    $0x8,%esp
  80168f:	ff 75 0c             	pushl  0xc(%ebp)
  801692:	50                   	push   %eax
  801693:	e8 5b ff ff ff       	call   8015f3 <fstat>
  801698:	89 c6                	mov    %eax,%esi
	close(fd);
  80169a:	89 1c 24             	mov    %ebx,(%esp)
  80169d:	e8 fd fb ff ff       	call   80129f <close>
	return r;
  8016a2:	83 c4 10             	add    $0x10,%esp
  8016a5:	89 f0                	mov    %esi,%eax
}
  8016a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016aa:	5b                   	pop    %ebx
  8016ab:	5e                   	pop    %esi
  8016ac:	5d                   	pop    %ebp
  8016ad:	c3                   	ret    

008016ae <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	56                   	push   %esi
  8016b2:	53                   	push   %ebx
  8016b3:	89 c6                	mov    %eax,%esi
  8016b5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016b7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016be:	75 12                	jne    8016d2 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016c0:	83 ec 0c             	sub    $0xc,%esp
  8016c3:	6a 01                	push   $0x1
  8016c5:	e8 94 08 00 00       	call   801f5e <ipc_find_env>
  8016ca:	a3 00 40 80 00       	mov    %eax,0x804000
  8016cf:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016d2:	6a 07                	push   $0x7
  8016d4:	68 00 50 80 00       	push   $0x805000
  8016d9:	56                   	push   %esi
  8016da:	ff 35 00 40 80 00    	pushl  0x804000
  8016e0:	e8 17 08 00 00       	call   801efc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016e5:	83 c4 0c             	add    $0xc,%esp
  8016e8:	6a 00                	push   $0x0
  8016ea:	53                   	push   %ebx
  8016eb:	6a 00                	push   $0x0
  8016ed:	e8 8f 07 00 00       	call   801e81 <ipc_recv>
}
  8016f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f5:	5b                   	pop    %ebx
  8016f6:	5e                   	pop    %esi
  8016f7:	5d                   	pop    %ebp
  8016f8:	c3                   	ret    

008016f9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016f9:	55                   	push   %ebp
  8016fa:	89 e5                	mov    %esp,%ebp
  8016fc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801702:	8b 40 0c             	mov    0xc(%eax),%eax
  801705:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80170a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80170d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801712:	ba 00 00 00 00       	mov    $0x0,%edx
  801717:	b8 02 00 00 00       	mov    $0x2,%eax
  80171c:	e8 8d ff ff ff       	call   8016ae <fsipc>
}
  801721:	c9                   	leave  
  801722:	c3                   	ret    

00801723 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801723:	55                   	push   %ebp
  801724:	89 e5                	mov    %esp,%ebp
  801726:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801729:	8b 45 08             	mov    0x8(%ebp),%eax
  80172c:	8b 40 0c             	mov    0xc(%eax),%eax
  80172f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801734:	ba 00 00 00 00       	mov    $0x0,%edx
  801739:	b8 06 00 00 00       	mov    $0x6,%eax
  80173e:	e8 6b ff ff ff       	call   8016ae <fsipc>
}
  801743:	c9                   	leave  
  801744:	c3                   	ret    

00801745 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	53                   	push   %ebx
  801749:	83 ec 04             	sub    $0x4,%esp
  80174c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80174f:	8b 45 08             	mov    0x8(%ebp),%eax
  801752:	8b 40 0c             	mov    0xc(%eax),%eax
  801755:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80175a:	ba 00 00 00 00       	mov    $0x0,%edx
  80175f:	b8 05 00 00 00       	mov    $0x5,%eax
  801764:	e8 45 ff ff ff       	call   8016ae <fsipc>
  801769:	85 c0                	test   %eax,%eax
  80176b:	78 2c                	js     801799 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80176d:	83 ec 08             	sub    $0x8,%esp
  801770:	68 00 50 80 00       	push   $0x805000
  801775:	53                   	push   %ebx
  801776:	e8 5c f0 ff ff       	call   8007d7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80177b:	a1 80 50 80 00       	mov    0x805080,%eax
  801780:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801786:	a1 84 50 80 00       	mov    0x805084,%eax
  80178b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801791:	83 c4 10             	add    $0x10,%esp
  801794:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801799:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179c:	c9                   	leave  
  80179d:	c3                   	ret    

0080179e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80179e:	55                   	push   %ebp
  80179f:	89 e5                	mov    %esp,%ebp
  8017a1:	83 ec 0c             	sub    $0xc,%esp
  8017a4:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8017aa:	8b 52 0c             	mov    0xc(%edx),%edx
  8017ad:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8017b3:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017b8:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017bd:	0f 47 c2             	cmova  %edx,%eax
  8017c0:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8017c5:	50                   	push   %eax
  8017c6:	ff 75 0c             	pushl  0xc(%ebp)
  8017c9:	68 08 50 80 00       	push   $0x805008
  8017ce:	e8 96 f1 ff ff       	call   800969 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8017d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d8:	b8 04 00 00 00       	mov    $0x4,%eax
  8017dd:	e8 cc fe ff ff       	call   8016ae <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8017e2:	c9                   	leave  
  8017e3:	c3                   	ret    

008017e4 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017e4:	55                   	push   %ebp
  8017e5:	89 e5                	mov    %esp,%ebp
  8017e7:	56                   	push   %esi
  8017e8:	53                   	push   %ebx
  8017e9:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ef:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017f7:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801802:	b8 03 00 00 00       	mov    $0x3,%eax
  801807:	e8 a2 fe ff ff       	call   8016ae <fsipc>
  80180c:	89 c3                	mov    %eax,%ebx
  80180e:	85 c0                	test   %eax,%eax
  801810:	78 4b                	js     80185d <devfile_read+0x79>
		return r;
	assert(r <= n);
  801812:	39 c6                	cmp    %eax,%esi
  801814:	73 16                	jae    80182c <devfile_read+0x48>
  801816:	68 38 27 80 00       	push   $0x802738
  80181b:	68 3f 27 80 00       	push   $0x80273f
  801820:	6a 7c                	push   $0x7c
  801822:	68 54 27 80 00       	push   $0x802754
  801827:	e8 4d e9 ff ff       	call   800179 <_panic>
	assert(r <= PGSIZE);
  80182c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801831:	7e 16                	jle    801849 <devfile_read+0x65>
  801833:	68 5f 27 80 00       	push   $0x80275f
  801838:	68 3f 27 80 00       	push   $0x80273f
  80183d:	6a 7d                	push   $0x7d
  80183f:	68 54 27 80 00       	push   $0x802754
  801844:	e8 30 e9 ff ff       	call   800179 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801849:	83 ec 04             	sub    $0x4,%esp
  80184c:	50                   	push   %eax
  80184d:	68 00 50 80 00       	push   $0x805000
  801852:	ff 75 0c             	pushl  0xc(%ebp)
  801855:	e8 0f f1 ff ff       	call   800969 <memmove>
	return r;
  80185a:	83 c4 10             	add    $0x10,%esp
}
  80185d:	89 d8                	mov    %ebx,%eax
  80185f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801862:	5b                   	pop    %ebx
  801863:	5e                   	pop    %esi
  801864:	5d                   	pop    %ebp
  801865:	c3                   	ret    

00801866 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801866:	55                   	push   %ebp
  801867:	89 e5                	mov    %esp,%ebp
  801869:	53                   	push   %ebx
  80186a:	83 ec 20             	sub    $0x20,%esp
  80186d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801870:	53                   	push   %ebx
  801871:	e8 28 ef ff ff       	call   80079e <strlen>
  801876:	83 c4 10             	add    $0x10,%esp
  801879:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80187e:	7f 67                	jg     8018e7 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801880:	83 ec 0c             	sub    $0xc,%esp
  801883:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801886:	50                   	push   %eax
  801887:	e8 9a f8 ff ff       	call   801126 <fd_alloc>
  80188c:	83 c4 10             	add    $0x10,%esp
		return r;
  80188f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801891:	85 c0                	test   %eax,%eax
  801893:	78 57                	js     8018ec <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801895:	83 ec 08             	sub    $0x8,%esp
  801898:	53                   	push   %ebx
  801899:	68 00 50 80 00       	push   $0x805000
  80189e:	e8 34 ef ff ff       	call   8007d7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a6:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8018b3:	e8 f6 fd ff ff       	call   8016ae <fsipc>
  8018b8:	89 c3                	mov    %eax,%ebx
  8018ba:	83 c4 10             	add    $0x10,%esp
  8018bd:	85 c0                	test   %eax,%eax
  8018bf:	79 14                	jns    8018d5 <open+0x6f>
		fd_close(fd, 0);
  8018c1:	83 ec 08             	sub    $0x8,%esp
  8018c4:	6a 00                	push   $0x0
  8018c6:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c9:	e8 50 f9 ff ff       	call   80121e <fd_close>
		return r;
  8018ce:	83 c4 10             	add    $0x10,%esp
  8018d1:	89 da                	mov    %ebx,%edx
  8018d3:	eb 17                	jmp    8018ec <open+0x86>
	}

	return fd2num(fd);
  8018d5:	83 ec 0c             	sub    $0xc,%esp
  8018d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8018db:	e8 1f f8 ff ff       	call   8010ff <fd2num>
  8018e0:	89 c2                	mov    %eax,%edx
  8018e2:	83 c4 10             	add    $0x10,%esp
  8018e5:	eb 05                	jmp    8018ec <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018e7:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018ec:	89 d0                	mov    %edx,%eax
  8018ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f1:	c9                   	leave  
  8018f2:	c3                   	ret    

008018f3 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018f3:	55                   	push   %ebp
  8018f4:	89 e5                	mov    %esp,%ebp
  8018f6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018fe:	b8 08 00 00 00       	mov    $0x8,%eax
  801903:	e8 a6 fd ff ff       	call   8016ae <fsipc>
}
  801908:	c9                   	leave  
  801909:	c3                   	ret    

0080190a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80190a:	55                   	push   %ebp
  80190b:	89 e5                	mov    %esp,%ebp
  80190d:	56                   	push   %esi
  80190e:	53                   	push   %ebx
  80190f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801912:	83 ec 0c             	sub    $0xc,%esp
  801915:	ff 75 08             	pushl  0x8(%ebp)
  801918:	e8 f2 f7 ff ff       	call   80110f <fd2data>
  80191d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80191f:	83 c4 08             	add    $0x8,%esp
  801922:	68 6b 27 80 00       	push   $0x80276b
  801927:	53                   	push   %ebx
  801928:	e8 aa ee ff ff       	call   8007d7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80192d:	8b 46 04             	mov    0x4(%esi),%eax
  801930:	2b 06                	sub    (%esi),%eax
  801932:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801938:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80193f:	00 00 00 
	stat->st_dev = &devpipe;
  801942:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801949:	30 80 00 
	return 0;
}
  80194c:	b8 00 00 00 00       	mov    $0x0,%eax
  801951:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801954:	5b                   	pop    %ebx
  801955:	5e                   	pop    %esi
  801956:	5d                   	pop    %ebp
  801957:	c3                   	ret    

00801958 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801958:	55                   	push   %ebp
  801959:	89 e5                	mov    %esp,%ebp
  80195b:	53                   	push   %ebx
  80195c:	83 ec 0c             	sub    $0xc,%esp
  80195f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801962:	53                   	push   %ebx
  801963:	6a 00                	push   $0x0
  801965:	e8 f5 f2 ff ff       	call   800c5f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80196a:	89 1c 24             	mov    %ebx,(%esp)
  80196d:	e8 9d f7 ff ff       	call   80110f <fd2data>
  801972:	83 c4 08             	add    $0x8,%esp
  801975:	50                   	push   %eax
  801976:	6a 00                	push   $0x0
  801978:	e8 e2 f2 ff ff       	call   800c5f <sys_page_unmap>
}
  80197d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801980:	c9                   	leave  
  801981:	c3                   	ret    

00801982 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801982:	55                   	push   %ebp
  801983:	89 e5                	mov    %esp,%ebp
  801985:	57                   	push   %edi
  801986:	56                   	push   %esi
  801987:	53                   	push   %ebx
  801988:	83 ec 1c             	sub    $0x1c,%esp
  80198b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80198e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801990:	a1 08 40 80 00       	mov    0x804008,%eax
  801995:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80199b:	83 ec 0c             	sub    $0xc,%esp
  80199e:	ff 75 e0             	pushl  -0x20(%ebp)
  8019a1:	e8 fa 05 00 00       	call   801fa0 <pageref>
  8019a6:	89 c3                	mov    %eax,%ebx
  8019a8:	89 3c 24             	mov    %edi,(%esp)
  8019ab:	e8 f0 05 00 00       	call   801fa0 <pageref>
  8019b0:	83 c4 10             	add    $0x10,%esp
  8019b3:	39 c3                	cmp    %eax,%ebx
  8019b5:	0f 94 c1             	sete   %cl
  8019b8:	0f b6 c9             	movzbl %cl,%ecx
  8019bb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019be:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8019c4:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  8019ca:	39 ce                	cmp    %ecx,%esi
  8019cc:	74 1e                	je     8019ec <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  8019ce:	39 c3                	cmp    %eax,%ebx
  8019d0:	75 be                	jne    801990 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019d2:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  8019d8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019db:	50                   	push   %eax
  8019dc:	56                   	push   %esi
  8019dd:	68 72 27 80 00       	push   $0x802772
  8019e2:	e8 6b e8 ff ff       	call   800252 <cprintf>
  8019e7:	83 c4 10             	add    $0x10,%esp
  8019ea:	eb a4                	jmp    801990 <_pipeisclosed+0xe>
	}
}
  8019ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019f2:	5b                   	pop    %ebx
  8019f3:	5e                   	pop    %esi
  8019f4:	5f                   	pop    %edi
  8019f5:	5d                   	pop    %ebp
  8019f6:	c3                   	ret    

008019f7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019f7:	55                   	push   %ebp
  8019f8:	89 e5                	mov    %esp,%ebp
  8019fa:	57                   	push   %edi
  8019fb:	56                   	push   %esi
  8019fc:	53                   	push   %ebx
  8019fd:	83 ec 28             	sub    $0x28,%esp
  801a00:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a03:	56                   	push   %esi
  801a04:	e8 06 f7 ff ff       	call   80110f <fd2data>
  801a09:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a0b:	83 c4 10             	add    $0x10,%esp
  801a0e:	bf 00 00 00 00       	mov    $0x0,%edi
  801a13:	eb 4b                	jmp    801a60 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a15:	89 da                	mov    %ebx,%edx
  801a17:	89 f0                	mov    %esi,%eax
  801a19:	e8 64 ff ff ff       	call   801982 <_pipeisclosed>
  801a1e:	85 c0                	test   %eax,%eax
  801a20:	75 48                	jne    801a6a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a22:	e8 94 f1 ff ff       	call   800bbb <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a27:	8b 43 04             	mov    0x4(%ebx),%eax
  801a2a:	8b 0b                	mov    (%ebx),%ecx
  801a2c:	8d 51 20             	lea    0x20(%ecx),%edx
  801a2f:	39 d0                	cmp    %edx,%eax
  801a31:	73 e2                	jae    801a15 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a36:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a3a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a3d:	89 c2                	mov    %eax,%edx
  801a3f:	c1 fa 1f             	sar    $0x1f,%edx
  801a42:	89 d1                	mov    %edx,%ecx
  801a44:	c1 e9 1b             	shr    $0x1b,%ecx
  801a47:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a4a:	83 e2 1f             	and    $0x1f,%edx
  801a4d:	29 ca                	sub    %ecx,%edx
  801a4f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a53:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a57:	83 c0 01             	add    $0x1,%eax
  801a5a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a5d:	83 c7 01             	add    $0x1,%edi
  801a60:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a63:	75 c2                	jne    801a27 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a65:	8b 45 10             	mov    0x10(%ebp),%eax
  801a68:	eb 05                	jmp    801a6f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a6a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a72:	5b                   	pop    %ebx
  801a73:	5e                   	pop    %esi
  801a74:	5f                   	pop    %edi
  801a75:	5d                   	pop    %ebp
  801a76:	c3                   	ret    

00801a77 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a77:	55                   	push   %ebp
  801a78:	89 e5                	mov    %esp,%ebp
  801a7a:	57                   	push   %edi
  801a7b:	56                   	push   %esi
  801a7c:	53                   	push   %ebx
  801a7d:	83 ec 18             	sub    $0x18,%esp
  801a80:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a83:	57                   	push   %edi
  801a84:	e8 86 f6 ff ff       	call   80110f <fd2data>
  801a89:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a8b:	83 c4 10             	add    $0x10,%esp
  801a8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a93:	eb 3d                	jmp    801ad2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a95:	85 db                	test   %ebx,%ebx
  801a97:	74 04                	je     801a9d <devpipe_read+0x26>
				return i;
  801a99:	89 d8                	mov    %ebx,%eax
  801a9b:	eb 44                	jmp    801ae1 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a9d:	89 f2                	mov    %esi,%edx
  801a9f:	89 f8                	mov    %edi,%eax
  801aa1:	e8 dc fe ff ff       	call   801982 <_pipeisclosed>
  801aa6:	85 c0                	test   %eax,%eax
  801aa8:	75 32                	jne    801adc <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801aaa:	e8 0c f1 ff ff       	call   800bbb <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801aaf:	8b 06                	mov    (%esi),%eax
  801ab1:	3b 46 04             	cmp    0x4(%esi),%eax
  801ab4:	74 df                	je     801a95 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ab6:	99                   	cltd   
  801ab7:	c1 ea 1b             	shr    $0x1b,%edx
  801aba:	01 d0                	add    %edx,%eax
  801abc:	83 e0 1f             	and    $0x1f,%eax
  801abf:	29 d0                	sub    %edx,%eax
  801ac1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ac6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ac9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801acc:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801acf:	83 c3 01             	add    $0x1,%ebx
  801ad2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ad5:	75 d8                	jne    801aaf <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ad7:	8b 45 10             	mov    0x10(%ebp),%eax
  801ada:	eb 05                	jmp    801ae1 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801adc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ae1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae4:	5b                   	pop    %ebx
  801ae5:	5e                   	pop    %esi
  801ae6:	5f                   	pop    %edi
  801ae7:	5d                   	pop    %ebp
  801ae8:	c3                   	ret    

00801ae9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ae9:	55                   	push   %ebp
  801aea:	89 e5                	mov    %esp,%ebp
  801aec:	56                   	push   %esi
  801aed:	53                   	push   %ebx
  801aee:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801af1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801af4:	50                   	push   %eax
  801af5:	e8 2c f6 ff ff       	call   801126 <fd_alloc>
  801afa:	83 c4 10             	add    $0x10,%esp
  801afd:	89 c2                	mov    %eax,%edx
  801aff:	85 c0                	test   %eax,%eax
  801b01:	0f 88 2c 01 00 00    	js     801c33 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b07:	83 ec 04             	sub    $0x4,%esp
  801b0a:	68 07 04 00 00       	push   $0x407
  801b0f:	ff 75 f4             	pushl  -0xc(%ebp)
  801b12:	6a 00                	push   $0x0
  801b14:	e8 c1 f0 ff ff       	call   800bda <sys_page_alloc>
  801b19:	83 c4 10             	add    $0x10,%esp
  801b1c:	89 c2                	mov    %eax,%edx
  801b1e:	85 c0                	test   %eax,%eax
  801b20:	0f 88 0d 01 00 00    	js     801c33 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b26:	83 ec 0c             	sub    $0xc,%esp
  801b29:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b2c:	50                   	push   %eax
  801b2d:	e8 f4 f5 ff ff       	call   801126 <fd_alloc>
  801b32:	89 c3                	mov    %eax,%ebx
  801b34:	83 c4 10             	add    $0x10,%esp
  801b37:	85 c0                	test   %eax,%eax
  801b39:	0f 88 e2 00 00 00    	js     801c21 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b3f:	83 ec 04             	sub    $0x4,%esp
  801b42:	68 07 04 00 00       	push   $0x407
  801b47:	ff 75 f0             	pushl  -0x10(%ebp)
  801b4a:	6a 00                	push   $0x0
  801b4c:	e8 89 f0 ff ff       	call   800bda <sys_page_alloc>
  801b51:	89 c3                	mov    %eax,%ebx
  801b53:	83 c4 10             	add    $0x10,%esp
  801b56:	85 c0                	test   %eax,%eax
  801b58:	0f 88 c3 00 00 00    	js     801c21 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b5e:	83 ec 0c             	sub    $0xc,%esp
  801b61:	ff 75 f4             	pushl  -0xc(%ebp)
  801b64:	e8 a6 f5 ff ff       	call   80110f <fd2data>
  801b69:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b6b:	83 c4 0c             	add    $0xc,%esp
  801b6e:	68 07 04 00 00       	push   $0x407
  801b73:	50                   	push   %eax
  801b74:	6a 00                	push   $0x0
  801b76:	e8 5f f0 ff ff       	call   800bda <sys_page_alloc>
  801b7b:	89 c3                	mov    %eax,%ebx
  801b7d:	83 c4 10             	add    $0x10,%esp
  801b80:	85 c0                	test   %eax,%eax
  801b82:	0f 88 89 00 00 00    	js     801c11 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b88:	83 ec 0c             	sub    $0xc,%esp
  801b8b:	ff 75 f0             	pushl  -0x10(%ebp)
  801b8e:	e8 7c f5 ff ff       	call   80110f <fd2data>
  801b93:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b9a:	50                   	push   %eax
  801b9b:	6a 00                	push   $0x0
  801b9d:	56                   	push   %esi
  801b9e:	6a 00                	push   $0x0
  801ba0:	e8 78 f0 ff ff       	call   800c1d <sys_page_map>
  801ba5:	89 c3                	mov    %eax,%ebx
  801ba7:	83 c4 20             	add    $0x20,%esp
  801baa:	85 c0                	test   %eax,%eax
  801bac:	78 55                	js     801c03 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bae:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bbc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bc3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bcc:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801bce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bd1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801bd8:	83 ec 0c             	sub    $0xc,%esp
  801bdb:	ff 75 f4             	pushl  -0xc(%ebp)
  801bde:	e8 1c f5 ff ff       	call   8010ff <fd2num>
  801be3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801be6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801be8:	83 c4 04             	add    $0x4,%esp
  801beb:	ff 75 f0             	pushl  -0x10(%ebp)
  801bee:	e8 0c f5 ff ff       	call   8010ff <fd2num>
  801bf3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bf6:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801bf9:	83 c4 10             	add    $0x10,%esp
  801bfc:	ba 00 00 00 00       	mov    $0x0,%edx
  801c01:	eb 30                	jmp    801c33 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c03:	83 ec 08             	sub    $0x8,%esp
  801c06:	56                   	push   %esi
  801c07:	6a 00                	push   $0x0
  801c09:	e8 51 f0 ff ff       	call   800c5f <sys_page_unmap>
  801c0e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c11:	83 ec 08             	sub    $0x8,%esp
  801c14:	ff 75 f0             	pushl  -0x10(%ebp)
  801c17:	6a 00                	push   $0x0
  801c19:	e8 41 f0 ff ff       	call   800c5f <sys_page_unmap>
  801c1e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c21:	83 ec 08             	sub    $0x8,%esp
  801c24:	ff 75 f4             	pushl  -0xc(%ebp)
  801c27:	6a 00                	push   $0x0
  801c29:	e8 31 f0 ff ff       	call   800c5f <sys_page_unmap>
  801c2e:	83 c4 10             	add    $0x10,%esp
  801c31:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c33:	89 d0                	mov    %edx,%eax
  801c35:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c38:	5b                   	pop    %ebx
  801c39:	5e                   	pop    %esi
  801c3a:	5d                   	pop    %ebp
  801c3b:	c3                   	ret    

00801c3c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c3c:	55                   	push   %ebp
  801c3d:	89 e5                	mov    %esp,%ebp
  801c3f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c42:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c45:	50                   	push   %eax
  801c46:	ff 75 08             	pushl  0x8(%ebp)
  801c49:	e8 27 f5 ff ff       	call   801175 <fd_lookup>
  801c4e:	83 c4 10             	add    $0x10,%esp
  801c51:	85 c0                	test   %eax,%eax
  801c53:	78 18                	js     801c6d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c55:	83 ec 0c             	sub    $0xc,%esp
  801c58:	ff 75 f4             	pushl  -0xc(%ebp)
  801c5b:	e8 af f4 ff ff       	call   80110f <fd2data>
	return _pipeisclosed(fd, p);
  801c60:	89 c2                	mov    %eax,%edx
  801c62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c65:	e8 18 fd ff ff       	call   801982 <_pipeisclosed>
  801c6a:	83 c4 10             	add    $0x10,%esp
}
  801c6d:	c9                   	leave  
  801c6e:	c3                   	ret    

00801c6f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c6f:	55                   	push   %ebp
  801c70:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c72:	b8 00 00 00 00       	mov    $0x0,%eax
  801c77:	5d                   	pop    %ebp
  801c78:	c3                   	ret    

00801c79 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c79:	55                   	push   %ebp
  801c7a:	89 e5                	mov    %esp,%ebp
  801c7c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c7f:	68 8a 27 80 00       	push   $0x80278a
  801c84:	ff 75 0c             	pushl  0xc(%ebp)
  801c87:	e8 4b eb ff ff       	call   8007d7 <strcpy>
	return 0;
}
  801c8c:	b8 00 00 00 00       	mov    $0x0,%eax
  801c91:	c9                   	leave  
  801c92:	c3                   	ret    

00801c93 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c93:	55                   	push   %ebp
  801c94:	89 e5                	mov    %esp,%ebp
  801c96:	57                   	push   %edi
  801c97:	56                   	push   %esi
  801c98:	53                   	push   %ebx
  801c99:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c9f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ca4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801caa:	eb 2d                	jmp    801cd9 <devcons_write+0x46>
		m = n - tot;
  801cac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801caf:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801cb1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801cb4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801cb9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cbc:	83 ec 04             	sub    $0x4,%esp
  801cbf:	53                   	push   %ebx
  801cc0:	03 45 0c             	add    0xc(%ebp),%eax
  801cc3:	50                   	push   %eax
  801cc4:	57                   	push   %edi
  801cc5:	e8 9f ec ff ff       	call   800969 <memmove>
		sys_cputs(buf, m);
  801cca:	83 c4 08             	add    $0x8,%esp
  801ccd:	53                   	push   %ebx
  801cce:	57                   	push   %edi
  801ccf:	e8 4a ee ff ff       	call   800b1e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cd4:	01 de                	add    %ebx,%esi
  801cd6:	83 c4 10             	add    $0x10,%esp
  801cd9:	89 f0                	mov    %esi,%eax
  801cdb:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cde:	72 cc                	jb     801cac <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ce0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ce3:	5b                   	pop    %ebx
  801ce4:	5e                   	pop    %esi
  801ce5:	5f                   	pop    %edi
  801ce6:	5d                   	pop    %ebp
  801ce7:	c3                   	ret    

00801ce8 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	83 ec 08             	sub    $0x8,%esp
  801cee:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801cf3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cf7:	74 2a                	je     801d23 <devcons_read+0x3b>
  801cf9:	eb 05                	jmp    801d00 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801cfb:	e8 bb ee ff ff       	call   800bbb <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d00:	e8 37 ee ff ff       	call   800b3c <sys_cgetc>
  801d05:	85 c0                	test   %eax,%eax
  801d07:	74 f2                	je     801cfb <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d09:	85 c0                	test   %eax,%eax
  801d0b:	78 16                	js     801d23 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d0d:	83 f8 04             	cmp    $0x4,%eax
  801d10:	74 0c                	je     801d1e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d12:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d15:	88 02                	mov    %al,(%edx)
	return 1;
  801d17:	b8 01 00 00 00       	mov    $0x1,%eax
  801d1c:	eb 05                	jmp    801d23 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d1e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d23:	c9                   	leave  
  801d24:	c3                   	ret    

00801d25 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d25:	55                   	push   %ebp
  801d26:	89 e5                	mov    %esp,%ebp
  801d28:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d31:	6a 01                	push   $0x1
  801d33:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d36:	50                   	push   %eax
  801d37:	e8 e2 ed ff ff       	call   800b1e <sys_cputs>
}
  801d3c:	83 c4 10             	add    $0x10,%esp
  801d3f:	c9                   	leave  
  801d40:	c3                   	ret    

00801d41 <getchar>:

int
getchar(void)
{
  801d41:	55                   	push   %ebp
  801d42:	89 e5                	mov    %esp,%ebp
  801d44:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d47:	6a 01                	push   $0x1
  801d49:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d4c:	50                   	push   %eax
  801d4d:	6a 00                	push   $0x0
  801d4f:	e8 87 f6 ff ff       	call   8013db <read>
	if (r < 0)
  801d54:	83 c4 10             	add    $0x10,%esp
  801d57:	85 c0                	test   %eax,%eax
  801d59:	78 0f                	js     801d6a <getchar+0x29>
		return r;
	if (r < 1)
  801d5b:	85 c0                	test   %eax,%eax
  801d5d:	7e 06                	jle    801d65 <getchar+0x24>
		return -E_EOF;
	return c;
  801d5f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d63:	eb 05                	jmp    801d6a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d65:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d6a:	c9                   	leave  
  801d6b:	c3                   	ret    

00801d6c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d6c:	55                   	push   %ebp
  801d6d:	89 e5                	mov    %esp,%ebp
  801d6f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d75:	50                   	push   %eax
  801d76:	ff 75 08             	pushl  0x8(%ebp)
  801d79:	e8 f7 f3 ff ff       	call   801175 <fd_lookup>
  801d7e:	83 c4 10             	add    $0x10,%esp
  801d81:	85 c0                	test   %eax,%eax
  801d83:	78 11                	js     801d96 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d88:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d8e:	39 10                	cmp    %edx,(%eax)
  801d90:	0f 94 c0             	sete   %al
  801d93:	0f b6 c0             	movzbl %al,%eax
}
  801d96:	c9                   	leave  
  801d97:	c3                   	ret    

00801d98 <opencons>:

int
opencons(void)
{
  801d98:	55                   	push   %ebp
  801d99:	89 e5                	mov    %esp,%ebp
  801d9b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da1:	50                   	push   %eax
  801da2:	e8 7f f3 ff ff       	call   801126 <fd_alloc>
  801da7:	83 c4 10             	add    $0x10,%esp
		return r;
  801daa:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801dac:	85 c0                	test   %eax,%eax
  801dae:	78 3e                	js     801dee <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801db0:	83 ec 04             	sub    $0x4,%esp
  801db3:	68 07 04 00 00       	push   $0x407
  801db8:	ff 75 f4             	pushl  -0xc(%ebp)
  801dbb:	6a 00                	push   $0x0
  801dbd:	e8 18 ee ff ff       	call   800bda <sys_page_alloc>
  801dc2:	83 c4 10             	add    $0x10,%esp
		return r;
  801dc5:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dc7:	85 c0                	test   %eax,%eax
  801dc9:	78 23                	js     801dee <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801dcb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801dd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801de0:	83 ec 0c             	sub    $0xc,%esp
  801de3:	50                   	push   %eax
  801de4:	e8 16 f3 ff ff       	call   8010ff <fd2num>
  801de9:	89 c2                	mov    %eax,%edx
  801deb:	83 c4 10             	add    $0x10,%esp
}
  801dee:	89 d0                	mov    %edx,%eax
  801df0:	c9                   	leave  
  801df1:	c3                   	ret    

00801df2 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801df2:	55                   	push   %ebp
  801df3:	89 e5                	mov    %esp,%ebp
  801df5:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801df8:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801dff:	75 2a                	jne    801e2b <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801e01:	83 ec 04             	sub    $0x4,%esp
  801e04:	6a 07                	push   $0x7
  801e06:	68 00 f0 bf ee       	push   $0xeebff000
  801e0b:	6a 00                	push   $0x0
  801e0d:	e8 c8 ed ff ff       	call   800bda <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801e12:	83 c4 10             	add    $0x10,%esp
  801e15:	85 c0                	test   %eax,%eax
  801e17:	79 12                	jns    801e2b <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801e19:	50                   	push   %eax
  801e1a:	68 96 27 80 00       	push   $0x802796
  801e1f:	6a 23                	push   $0x23
  801e21:	68 9a 27 80 00       	push   $0x80279a
  801e26:	e8 4e e3 ff ff       	call   800179 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2e:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801e33:	83 ec 08             	sub    $0x8,%esp
  801e36:	68 5d 1e 80 00       	push   $0x801e5d
  801e3b:	6a 00                	push   $0x0
  801e3d:	e8 e3 ee ff ff       	call   800d25 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801e42:	83 c4 10             	add    $0x10,%esp
  801e45:	85 c0                	test   %eax,%eax
  801e47:	79 12                	jns    801e5b <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801e49:	50                   	push   %eax
  801e4a:	68 96 27 80 00       	push   $0x802796
  801e4f:	6a 2c                	push   $0x2c
  801e51:	68 9a 27 80 00       	push   $0x80279a
  801e56:	e8 1e e3 ff ff       	call   800179 <_panic>
	}
}
  801e5b:	c9                   	leave  
  801e5c:	c3                   	ret    

00801e5d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e5d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e5e:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e63:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e65:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801e68:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801e6c:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801e71:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801e75:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801e77:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801e7a:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801e7b:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801e7e:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801e7f:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e80:	c3                   	ret    

00801e81 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e81:	55                   	push   %ebp
  801e82:	89 e5                	mov    %esp,%ebp
  801e84:	56                   	push   %esi
  801e85:	53                   	push   %ebx
  801e86:	8b 75 08             	mov    0x8(%ebp),%esi
  801e89:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e8f:	85 c0                	test   %eax,%eax
  801e91:	75 12                	jne    801ea5 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e93:	83 ec 0c             	sub    $0xc,%esp
  801e96:	68 00 00 c0 ee       	push   $0xeec00000
  801e9b:	e8 ea ee ff ff       	call   800d8a <sys_ipc_recv>
  801ea0:	83 c4 10             	add    $0x10,%esp
  801ea3:	eb 0c                	jmp    801eb1 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801ea5:	83 ec 0c             	sub    $0xc,%esp
  801ea8:	50                   	push   %eax
  801ea9:	e8 dc ee ff ff       	call   800d8a <sys_ipc_recv>
  801eae:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801eb1:	85 f6                	test   %esi,%esi
  801eb3:	0f 95 c1             	setne  %cl
  801eb6:	85 db                	test   %ebx,%ebx
  801eb8:	0f 95 c2             	setne  %dl
  801ebb:	84 d1                	test   %dl,%cl
  801ebd:	74 09                	je     801ec8 <ipc_recv+0x47>
  801ebf:	89 c2                	mov    %eax,%edx
  801ec1:	c1 ea 1f             	shr    $0x1f,%edx
  801ec4:	84 d2                	test   %dl,%dl
  801ec6:	75 2d                	jne    801ef5 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801ec8:	85 f6                	test   %esi,%esi
  801eca:	74 0d                	je     801ed9 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801ecc:	a1 08 40 80 00       	mov    0x804008,%eax
  801ed1:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  801ed7:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801ed9:	85 db                	test   %ebx,%ebx
  801edb:	74 0d                	je     801eea <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801edd:	a1 08 40 80 00       	mov    0x804008,%eax
  801ee2:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  801ee8:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801eea:	a1 08 40 80 00       	mov    0x804008,%eax
  801eef:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  801ef5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ef8:	5b                   	pop    %ebx
  801ef9:	5e                   	pop    %esi
  801efa:	5d                   	pop    %ebp
  801efb:	c3                   	ret    

00801efc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801efc:	55                   	push   %ebp
  801efd:	89 e5                	mov    %esp,%ebp
  801eff:	57                   	push   %edi
  801f00:	56                   	push   %esi
  801f01:	53                   	push   %ebx
  801f02:	83 ec 0c             	sub    $0xc,%esp
  801f05:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f08:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801f0e:	85 db                	test   %ebx,%ebx
  801f10:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f15:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801f18:	ff 75 14             	pushl  0x14(%ebp)
  801f1b:	53                   	push   %ebx
  801f1c:	56                   	push   %esi
  801f1d:	57                   	push   %edi
  801f1e:	e8 44 ee ff ff       	call   800d67 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801f23:	89 c2                	mov    %eax,%edx
  801f25:	c1 ea 1f             	shr    $0x1f,%edx
  801f28:	83 c4 10             	add    $0x10,%esp
  801f2b:	84 d2                	test   %dl,%dl
  801f2d:	74 17                	je     801f46 <ipc_send+0x4a>
  801f2f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f32:	74 12                	je     801f46 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801f34:	50                   	push   %eax
  801f35:	68 a8 27 80 00       	push   $0x8027a8
  801f3a:	6a 47                	push   $0x47
  801f3c:	68 b6 27 80 00       	push   $0x8027b6
  801f41:	e8 33 e2 ff ff       	call   800179 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801f46:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f49:	75 07                	jne    801f52 <ipc_send+0x56>
			sys_yield();
  801f4b:	e8 6b ec ff ff       	call   800bbb <sys_yield>
  801f50:	eb c6                	jmp    801f18 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801f52:	85 c0                	test   %eax,%eax
  801f54:	75 c2                	jne    801f18 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801f56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f59:	5b                   	pop    %ebx
  801f5a:	5e                   	pop    %esi
  801f5b:	5f                   	pop    %edi
  801f5c:	5d                   	pop    %ebp
  801f5d:	c3                   	ret    

00801f5e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f5e:	55                   	push   %ebp
  801f5f:	89 e5                	mov    %esp,%ebp
  801f61:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f64:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f69:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  801f6f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f75:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801f7b:	39 ca                	cmp    %ecx,%edx
  801f7d:	75 10                	jne    801f8f <ipc_find_env+0x31>
			return envs[i].env_id;
  801f7f:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  801f85:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f8a:	8b 40 7c             	mov    0x7c(%eax),%eax
  801f8d:	eb 0f                	jmp    801f9e <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f8f:	83 c0 01             	add    $0x1,%eax
  801f92:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f97:	75 d0                	jne    801f69 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f99:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f9e:	5d                   	pop    %ebp
  801f9f:	c3                   	ret    

00801fa0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fa0:	55                   	push   %ebp
  801fa1:	89 e5                	mov    %esp,%ebp
  801fa3:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa6:	89 d0                	mov    %edx,%eax
  801fa8:	c1 e8 16             	shr    $0x16,%eax
  801fab:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fb2:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fb7:	f6 c1 01             	test   $0x1,%cl
  801fba:	74 1d                	je     801fd9 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fbc:	c1 ea 0c             	shr    $0xc,%edx
  801fbf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fc6:	f6 c2 01             	test   $0x1,%dl
  801fc9:	74 0e                	je     801fd9 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fcb:	c1 ea 0c             	shr    $0xc,%edx
  801fce:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fd5:	ef 
  801fd6:	0f b7 c0             	movzwl %ax,%eax
}
  801fd9:	5d                   	pop    %ebp
  801fda:	c3                   	ret    
  801fdb:	66 90                	xchg   %ax,%ax
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
