
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
  800038:	e8 5b 0b 00 00       	call   800b98 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 94 0e 00 00       	call   800edd <fork>
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
  80005c:	e8 56 0b 00 00       	call   800bb7 <sys_yield>
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
  800076:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  80007d:	8b 42 60             	mov    0x60(%edx),%eax
  800080:	85 c0                	test   %eax,%eax
  800082:	75 e2                	jne    800066 <umain+0x33>
  800084:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800089:	e8 29 0b 00 00       	call   800bb7 <sys_yield>
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
  8000bc:	68 60 22 80 00       	push   $0x802260
  8000c1:	6a 21                	push   $0x21
  8000c3:	68 88 22 80 00       	push   $0x802288
  8000c8:	e8 a8 00 00 00       	call   800175 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000cd:	a1 08 40 80 00       	mov    0x804008,%eax
  8000d2:	8b 50 68             	mov    0x68(%eax),%edx
  8000d5:	8b 40 54             	mov    0x54(%eax),%eax
  8000d8:	83 ec 04             	sub    $0x4,%esp
  8000db:	52                   	push   %edx
  8000dc:	50                   	push   %eax
  8000dd:	68 9b 22 80 00       	push   $0x80229b
  8000e2:	e8 67 01 00 00       	call   80024e <cprintf>
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
  8000f4:	56                   	push   %esi
  8000f5:	53                   	push   %ebx
  8000f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000fc:	e8 97 0a 00 00       	call   800b98 <sys_getenvid>
  800101:	25 ff 03 00 00       	and    $0x3ff,%eax
  800106:	89 c2                	mov    %eax,%edx
  800108:	c1 e2 07             	shl    $0x7,%edx
  80010b:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800112:	a3 08 40 80 00       	mov    %eax,0x804008
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800117:	85 db                	test   %ebx,%ebx
  800119:	7e 07                	jle    800122 <libmain+0x31>
		binaryname = argv[0];
  80011b:	8b 06                	mov    (%esi),%eax
  80011d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800122:	83 ec 08             	sub    $0x8,%esp
  800125:	56                   	push   %esi
  800126:	53                   	push   %ebx
  800127:	e8 07 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80012c:	e8 2a 00 00 00       	call   80015b <exit>
}
  800131:	83 c4 10             	add    $0x10,%esp
  800134:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800137:	5b                   	pop    %ebx
  800138:	5e                   	pop    %esi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  800141:	a1 0c 40 80 00       	mov    0x80400c,%eax
	func();
  800146:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800148:	e8 4b 0a 00 00       	call   800b98 <sys_getenvid>
  80014d:	83 ec 0c             	sub    $0xc,%esp
  800150:	50                   	push   %eax
  800151:	e8 91 0c 00 00       	call   800de7 <sys_thread_free>
}
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	c9                   	leave  
  80015a:	c3                   	ret    

0080015b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800161:	e8 5e 11 00 00       	call   8012c4 <close_all>
	sys_env_destroy(0);
  800166:	83 ec 0c             	sub    $0xc,%esp
  800169:	6a 00                	push   $0x0
  80016b:	e8 e7 09 00 00       	call   800b57 <sys_env_destroy>
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	c9                   	leave  
  800174:	c3                   	ret    

00800175 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	56                   	push   %esi
  800179:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80017a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80017d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800183:	e8 10 0a 00 00       	call   800b98 <sys_getenvid>
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	ff 75 0c             	pushl  0xc(%ebp)
  80018e:	ff 75 08             	pushl  0x8(%ebp)
  800191:	56                   	push   %esi
  800192:	50                   	push   %eax
  800193:	68 c4 22 80 00       	push   $0x8022c4
  800198:	e8 b1 00 00 00       	call   80024e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80019d:	83 c4 18             	add    $0x18,%esp
  8001a0:	53                   	push   %ebx
  8001a1:	ff 75 10             	pushl  0x10(%ebp)
  8001a4:	e8 54 00 00 00       	call   8001fd <vcprintf>
	cprintf("\n");
  8001a9:	c7 04 24 b7 22 80 00 	movl   $0x8022b7,(%esp)
  8001b0:	e8 99 00 00 00       	call   80024e <cprintf>
  8001b5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b8:	cc                   	int3   
  8001b9:	eb fd                	jmp    8001b8 <_panic+0x43>

008001bb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	53                   	push   %ebx
  8001bf:	83 ec 04             	sub    $0x4,%esp
  8001c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001c5:	8b 13                	mov    (%ebx),%edx
  8001c7:	8d 42 01             	lea    0x1(%edx),%eax
  8001ca:	89 03                	mov    %eax,(%ebx)
  8001cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001cf:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001d3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d8:	75 1a                	jne    8001f4 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001da:	83 ec 08             	sub    $0x8,%esp
  8001dd:	68 ff 00 00 00       	push   $0xff
  8001e2:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e5:	50                   	push   %eax
  8001e6:	e8 2f 09 00 00       	call   800b1a <sys_cputs>
		b->idx = 0;
  8001eb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001f1:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001f4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001fb:	c9                   	leave  
  8001fc:	c3                   	ret    

008001fd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001fd:	55                   	push   %ebp
  8001fe:	89 e5                	mov    %esp,%ebp
  800200:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800206:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80020d:	00 00 00 
	b.cnt = 0;
  800210:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800217:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80021a:	ff 75 0c             	pushl  0xc(%ebp)
  80021d:	ff 75 08             	pushl  0x8(%ebp)
  800220:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800226:	50                   	push   %eax
  800227:	68 bb 01 80 00       	push   $0x8001bb
  80022c:	e8 54 01 00 00       	call   800385 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800231:	83 c4 08             	add    $0x8,%esp
  800234:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80023a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800240:	50                   	push   %eax
  800241:	e8 d4 08 00 00       	call   800b1a <sys_cputs>

	return b.cnt;
}
  800246:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80024c:	c9                   	leave  
  80024d:	c3                   	ret    

0080024e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800254:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800257:	50                   	push   %eax
  800258:	ff 75 08             	pushl  0x8(%ebp)
  80025b:	e8 9d ff ff ff       	call   8001fd <vcprintf>
	va_end(ap);

	return cnt;
}
  800260:	c9                   	leave  
  800261:	c3                   	ret    

00800262 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800262:	55                   	push   %ebp
  800263:	89 e5                	mov    %esp,%ebp
  800265:	57                   	push   %edi
  800266:	56                   	push   %esi
  800267:	53                   	push   %ebx
  800268:	83 ec 1c             	sub    $0x1c,%esp
  80026b:	89 c7                	mov    %eax,%edi
  80026d:	89 d6                	mov    %edx,%esi
  80026f:	8b 45 08             	mov    0x8(%ebp),%eax
  800272:	8b 55 0c             	mov    0xc(%ebp),%edx
  800275:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800278:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80027b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80027e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800283:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800286:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800289:	39 d3                	cmp    %edx,%ebx
  80028b:	72 05                	jb     800292 <printnum+0x30>
  80028d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800290:	77 45                	ja     8002d7 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800292:	83 ec 0c             	sub    $0xc,%esp
  800295:	ff 75 18             	pushl  0x18(%ebp)
  800298:	8b 45 14             	mov    0x14(%ebp),%eax
  80029b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80029e:	53                   	push   %ebx
  80029f:	ff 75 10             	pushl  0x10(%ebp)
  8002a2:	83 ec 08             	sub    $0x8,%esp
  8002a5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ab:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ae:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b1:	e8 1a 1d 00 00       	call   801fd0 <__udivdi3>
  8002b6:	83 c4 18             	add    $0x18,%esp
  8002b9:	52                   	push   %edx
  8002ba:	50                   	push   %eax
  8002bb:	89 f2                	mov    %esi,%edx
  8002bd:	89 f8                	mov    %edi,%eax
  8002bf:	e8 9e ff ff ff       	call   800262 <printnum>
  8002c4:	83 c4 20             	add    $0x20,%esp
  8002c7:	eb 18                	jmp    8002e1 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002c9:	83 ec 08             	sub    $0x8,%esp
  8002cc:	56                   	push   %esi
  8002cd:	ff 75 18             	pushl  0x18(%ebp)
  8002d0:	ff d7                	call   *%edi
  8002d2:	83 c4 10             	add    $0x10,%esp
  8002d5:	eb 03                	jmp    8002da <printnum+0x78>
  8002d7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002da:	83 eb 01             	sub    $0x1,%ebx
  8002dd:	85 db                	test   %ebx,%ebx
  8002df:	7f e8                	jg     8002c9 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002e1:	83 ec 08             	sub    $0x8,%esp
  8002e4:	56                   	push   %esi
  8002e5:	83 ec 04             	sub    $0x4,%esp
  8002e8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ee:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f4:	e8 07 1e 00 00       	call   802100 <__umoddi3>
  8002f9:	83 c4 14             	add    $0x14,%esp
  8002fc:	0f be 80 e7 22 80 00 	movsbl 0x8022e7(%eax),%eax
  800303:	50                   	push   %eax
  800304:	ff d7                	call   *%edi
}
  800306:	83 c4 10             	add    $0x10,%esp
  800309:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030c:	5b                   	pop    %ebx
  80030d:	5e                   	pop    %esi
  80030e:	5f                   	pop    %edi
  80030f:	5d                   	pop    %ebp
  800310:	c3                   	ret    

00800311 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800314:	83 fa 01             	cmp    $0x1,%edx
  800317:	7e 0e                	jle    800327 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800319:	8b 10                	mov    (%eax),%edx
  80031b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80031e:	89 08                	mov    %ecx,(%eax)
  800320:	8b 02                	mov    (%edx),%eax
  800322:	8b 52 04             	mov    0x4(%edx),%edx
  800325:	eb 22                	jmp    800349 <getuint+0x38>
	else if (lflag)
  800327:	85 d2                	test   %edx,%edx
  800329:	74 10                	je     80033b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80032b:	8b 10                	mov    (%eax),%edx
  80032d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800330:	89 08                	mov    %ecx,(%eax)
  800332:	8b 02                	mov    (%edx),%eax
  800334:	ba 00 00 00 00       	mov    $0x0,%edx
  800339:	eb 0e                	jmp    800349 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80033b:	8b 10                	mov    (%eax),%edx
  80033d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800340:	89 08                	mov    %ecx,(%eax)
  800342:	8b 02                	mov    (%edx),%eax
  800344:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800349:	5d                   	pop    %ebp
  80034a:	c3                   	ret    

0080034b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800351:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800355:	8b 10                	mov    (%eax),%edx
  800357:	3b 50 04             	cmp    0x4(%eax),%edx
  80035a:	73 0a                	jae    800366 <sprintputch+0x1b>
		*b->buf++ = ch;
  80035c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80035f:	89 08                	mov    %ecx,(%eax)
  800361:	8b 45 08             	mov    0x8(%ebp),%eax
  800364:	88 02                	mov    %al,(%edx)
}
  800366:	5d                   	pop    %ebp
  800367:	c3                   	ret    

00800368 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80036e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800371:	50                   	push   %eax
  800372:	ff 75 10             	pushl  0x10(%ebp)
  800375:	ff 75 0c             	pushl  0xc(%ebp)
  800378:	ff 75 08             	pushl  0x8(%ebp)
  80037b:	e8 05 00 00 00       	call   800385 <vprintfmt>
	va_end(ap);
}
  800380:	83 c4 10             	add    $0x10,%esp
  800383:	c9                   	leave  
  800384:	c3                   	ret    

00800385 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	57                   	push   %edi
  800389:	56                   	push   %esi
  80038a:	53                   	push   %ebx
  80038b:	83 ec 2c             	sub    $0x2c,%esp
  80038e:	8b 75 08             	mov    0x8(%ebp),%esi
  800391:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800394:	8b 7d 10             	mov    0x10(%ebp),%edi
  800397:	eb 12                	jmp    8003ab <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800399:	85 c0                	test   %eax,%eax
  80039b:	0f 84 89 03 00 00    	je     80072a <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003a1:	83 ec 08             	sub    $0x8,%esp
  8003a4:	53                   	push   %ebx
  8003a5:	50                   	push   %eax
  8003a6:	ff d6                	call   *%esi
  8003a8:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ab:	83 c7 01             	add    $0x1,%edi
  8003ae:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003b2:	83 f8 25             	cmp    $0x25,%eax
  8003b5:	75 e2                	jne    800399 <vprintfmt+0x14>
  8003b7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003bb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003c2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003c9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d5:	eb 07                	jmp    8003de <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003da:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8d 47 01             	lea    0x1(%edi),%eax
  8003e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e4:	0f b6 07             	movzbl (%edi),%eax
  8003e7:	0f b6 c8             	movzbl %al,%ecx
  8003ea:	83 e8 23             	sub    $0x23,%eax
  8003ed:	3c 55                	cmp    $0x55,%al
  8003ef:	0f 87 1a 03 00 00    	ja     80070f <vprintfmt+0x38a>
  8003f5:	0f b6 c0             	movzbl %al,%eax
  8003f8:	ff 24 85 20 24 80 00 	jmp    *0x802420(,%eax,4)
  8003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800402:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800406:	eb d6                	jmp    8003de <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800408:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80040b:	b8 00 00 00 00       	mov    $0x0,%eax
  800410:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800413:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800416:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80041a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80041d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800420:	83 fa 09             	cmp    $0x9,%edx
  800423:	77 39                	ja     80045e <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800425:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800428:	eb e9                	jmp    800413 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80042a:	8b 45 14             	mov    0x14(%ebp),%eax
  80042d:	8d 48 04             	lea    0x4(%eax),%ecx
  800430:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800433:	8b 00                	mov    (%eax),%eax
  800435:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800438:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80043b:	eb 27                	jmp    800464 <vprintfmt+0xdf>
  80043d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800440:	85 c0                	test   %eax,%eax
  800442:	b9 00 00 00 00       	mov    $0x0,%ecx
  800447:	0f 49 c8             	cmovns %eax,%ecx
  80044a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800450:	eb 8c                	jmp    8003de <vprintfmt+0x59>
  800452:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800455:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80045c:	eb 80                	jmp    8003de <vprintfmt+0x59>
  80045e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800461:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800464:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800468:	0f 89 70 ff ff ff    	jns    8003de <vprintfmt+0x59>
				width = precision, precision = -1;
  80046e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800471:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800474:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80047b:	e9 5e ff ff ff       	jmp    8003de <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800480:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800483:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800486:	e9 53 ff ff ff       	jmp    8003de <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80048b:	8b 45 14             	mov    0x14(%ebp),%eax
  80048e:	8d 50 04             	lea    0x4(%eax),%edx
  800491:	89 55 14             	mov    %edx,0x14(%ebp)
  800494:	83 ec 08             	sub    $0x8,%esp
  800497:	53                   	push   %ebx
  800498:	ff 30                	pushl  (%eax)
  80049a:	ff d6                	call   *%esi
			break;
  80049c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004a2:	e9 04 ff ff ff       	jmp    8003ab <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004aa:	8d 50 04             	lea    0x4(%eax),%edx
  8004ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b0:	8b 00                	mov    (%eax),%eax
  8004b2:	99                   	cltd   
  8004b3:	31 d0                	xor    %edx,%eax
  8004b5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b7:	83 f8 0f             	cmp    $0xf,%eax
  8004ba:	7f 0b                	jg     8004c7 <vprintfmt+0x142>
  8004bc:	8b 14 85 80 25 80 00 	mov    0x802580(,%eax,4),%edx
  8004c3:	85 d2                	test   %edx,%edx
  8004c5:	75 18                	jne    8004df <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004c7:	50                   	push   %eax
  8004c8:	68 ff 22 80 00       	push   $0x8022ff
  8004cd:	53                   	push   %ebx
  8004ce:	56                   	push   %esi
  8004cf:	e8 94 fe ff ff       	call   800368 <printfmt>
  8004d4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004da:	e9 cc fe ff ff       	jmp    8003ab <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004df:	52                   	push   %edx
  8004e0:	68 31 27 80 00       	push   $0x802731
  8004e5:	53                   	push   %ebx
  8004e6:	56                   	push   %esi
  8004e7:	e8 7c fe ff ff       	call   800368 <printfmt>
  8004ec:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f2:	e9 b4 fe ff ff       	jmp    8003ab <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fa:	8d 50 04             	lea    0x4(%eax),%edx
  8004fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800500:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800502:	85 ff                	test   %edi,%edi
  800504:	b8 f8 22 80 00       	mov    $0x8022f8,%eax
  800509:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80050c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800510:	0f 8e 94 00 00 00    	jle    8005aa <vprintfmt+0x225>
  800516:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80051a:	0f 84 98 00 00 00    	je     8005b8 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	ff 75 d0             	pushl  -0x30(%ebp)
  800526:	57                   	push   %edi
  800527:	e8 86 02 00 00       	call   8007b2 <strnlen>
  80052c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80052f:	29 c1                	sub    %eax,%ecx
  800531:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800534:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800537:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80053b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80053e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800541:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800543:	eb 0f                	jmp    800554 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800545:	83 ec 08             	sub    $0x8,%esp
  800548:	53                   	push   %ebx
  800549:	ff 75 e0             	pushl  -0x20(%ebp)
  80054c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80054e:	83 ef 01             	sub    $0x1,%edi
  800551:	83 c4 10             	add    $0x10,%esp
  800554:	85 ff                	test   %edi,%edi
  800556:	7f ed                	jg     800545 <vprintfmt+0x1c0>
  800558:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80055b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80055e:	85 c9                	test   %ecx,%ecx
  800560:	b8 00 00 00 00       	mov    $0x0,%eax
  800565:	0f 49 c1             	cmovns %ecx,%eax
  800568:	29 c1                	sub    %eax,%ecx
  80056a:	89 75 08             	mov    %esi,0x8(%ebp)
  80056d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800570:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800573:	89 cb                	mov    %ecx,%ebx
  800575:	eb 4d                	jmp    8005c4 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800577:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80057b:	74 1b                	je     800598 <vprintfmt+0x213>
  80057d:	0f be c0             	movsbl %al,%eax
  800580:	83 e8 20             	sub    $0x20,%eax
  800583:	83 f8 5e             	cmp    $0x5e,%eax
  800586:	76 10                	jbe    800598 <vprintfmt+0x213>
					putch('?', putdat);
  800588:	83 ec 08             	sub    $0x8,%esp
  80058b:	ff 75 0c             	pushl  0xc(%ebp)
  80058e:	6a 3f                	push   $0x3f
  800590:	ff 55 08             	call   *0x8(%ebp)
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	eb 0d                	jmp    8005a5 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800598:	83 ec 08             	sub    $0x8,%esp
  80059b:	ff 75 0c             	pushl  0xc(%ebp)
  80059e:	52                   	push   %edx
  80059f:	ff 55 08             	call   *0x8(%ebp)
  8005a2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a5:	83 eb 01             	sub    $0x1,%ebx
  8005a8:	eb 1a                	jmp    8005c4 <vprintfmt+0x23f>
  8005aa:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ad:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005b0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005b3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005b6:	eb 0c                	jmp    8005c4 <vprintfmt+0x23f>
  8005b8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005bb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005be:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005c1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005c4:	83 c7 01             	add    $0x1,%edi
  8005c7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005cb:	0f be d0             	movsbl %al,%edx
  8005ce:	85 d2                	test   %edx,%edx
  8005d0:	74 23                	je     8005f5 <vprintfmt+0x270>
  8005d2:	85 f6                	test   %esi,%esi
  8005d4:	78 a1                	js     800577 <vprintfmt+0x1f2>
  8005d6:	83 ee 01             	sub    $0x1,%esi
  8005d9:	79 9c                	jns    800577 <vprintfmt+0x1f2>
  8005db:	89 df                	mov    %ebx,%edi
  8005dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e3:	eb 18                	jmp    8005fd <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005e5:	83 ec 08             	sub    $0x8,%esp
  8005e8:	53                   	push   %ebx
  8005e9:	6a 20                	push   $0x20
  8005eb:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ed:	83 ef 01             	sub    $0x1,%edi
  8005f0:	83 c4 10             	add    $0x10,%esp
  8005f3:	eb 08                	jmp    8005fd <vprintfmt+0x278>
  8005f5:	89 df                	mov    %ebx,%edi
  8005f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8005fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005fd:	85 ff                	test   %edi,%edi
  8005ff:	7f e4                	jg     8005e5 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800601:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800604:	e9 a2 fd ff ff       	jmp    8003ab <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800609:	83 fa 01             	cmp    $0x1,%edx
  80060c:	7e 16                	jle    800624 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8d 50 08             	lea    0x8(%eax),%edx
  800614:	89 55 14             	mov    %edx,0x14(%ebp)
  800617:	8b 50 04             	mov    0x4(%eax),%edx
  80061a:	8b 00                	mov    (%eax),%eax
  80061c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800622:	eb 32                	jmp    800656 <vprintfmt+0x2d1>
	else if (lflag)
  800624:	85 d2                	test   %edx,%edx
  800626:	74 18                	je     800640 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8d 50 04             	lea    0x4(%eax),%edx
  80062e:	89 55 14             	mov    %edx,0x14(%ebp)
  800631:	8b 00                	mov    (%eax),%eax
  800633:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800636:	89 c1                	mov    %eax,%ecx
  800638:	c1 f9 1f             	sar    $0x1f,%ecx
  80063b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80063e:	eb 16                	jmp    800656 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8d 50 04             	lea    0x4(%eax),%edx
  800646:	89 55 14             	mov    %edx,0x14(%ebp)
  800649:	8b 00                	mov    (%eax),%eax
  80064b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80064e:	89 c1                	mov    %eax,%ecx
  800650:	c1 f9 1f             	sar    $0x1f,%ecx
  800653:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800656:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800659:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80065c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800661:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800665:	79 74                	jns    8006db <vprintfmt+0x356>
				putch('-', putdat);
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	53                   	push   %ebx
  80066b:	6a 2d                	push   $0x2d
  80066d:	ff d6                	call   *%esi
				num = -(long long) num;
  80066f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800672:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800675:	f7 d8                	neg    %eax
  800677:	83 d2 00             	adc    $0x0,%edx
  80067a:	f7 da                	neg    %edx
  80067c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80067f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800684:	eb 55                	jmp    8006db <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800686:	8d 45 14             	lea    0x14(%ebp),%eax
  800689:	e8 83 fc ff ff       	call   800311 <getuint>
			base = 10;
  80068e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800693:	eb 46                	jmp    8006db <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800695:	8d 45 14             	lea    0x14(%ebp),%eax
  800698:	e8 74 fc ff ff       	call   800311 <getuint>
			base = 8;
  80069d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006a2:	eb 37                	jmp    8006db <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8006a4:	83 ec 08             	sub    $0x8,%esp
  8006a7:	53                   	push   %ebx
  8006a8:	6a 30                	push   $0x30
  8006aa:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ac:	83 c4 08             	add    $0x8,%esp
  8006af:	53                   	push   %ebx
  8006b0:	6a 78                	push   $0x78
  8006b2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8d 50 04             	lea    0x4(%eax),%edx
  8006ba:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006bd:	8b 00                	mov    (%eax),%eax
  8006bf:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006c4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006c7:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006cc:	eb 0d                	jmp    8006db <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d1:	e8 3b fc ff ff       	call   800311 <getuint>
			base = 16;
  8006d6:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006db:	83 ec 0c             	sub    $0xc,%esp
  8006de:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006e2:	57                   	push   %edi
  8006e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e6:	51                   	push   %ecx
  8006e7:	52                   	push   %edx
  8006e8:	50                   	push   %eax
  8006e9:	89 da                	mov    %ebx,%edx
  8006eb:	89 f0                	mov    %esi,%eax
  8006ed:	e8 70 fb ff ff       	call   800262 <printnum>
			break;
  8006f2:	83 c4 20             	add    $0x20,%esp
  8006f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006f8:	e9 ae fc ff ff       	jmp    8003ab <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006fd:	83 ec 08             	sub    $0x8,%esp
  800700:	53                   	push   %ebx
  800701:	51                   	push   %ecx
  800702:	ff d6                	call   *%esi
			break;
  800704:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800707:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80070a:	e9 9c fc ff ff       	jmp    8003ab <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80070f:	83 ec 08             	sub    $0x8,%esp
  800712:	53                   	push   %ebx
  800713:	6a 25                	push   $0x25
  800715:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800717:	83 c4 10             	add    $0x10,%esp
  80071a:	eb 03                	jmp    80071f <vprintfmt+0x39a>
  80071c:	83 ef 01             	sub    $0x1,%edi
  80071f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800723:	75 f7                	jne    80071c <vprintfmt+0x397>
  800725:	e9 81 fc ff ff       	jmp    8003ab <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80072a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80072d:	5b                   	pop    %ebx
  80072e:	5e                   	pop    %esi
  80072f:	5f                   	pop    %edi
  800730:	5d                   	pop    %ebp
  800731:	c3                   	ret    

00800732 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	83 ec 18             	sub    $0x18,%esp
  800738:	8b 45 08             	mov    0x8(%ebp),%eax
  80073b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80073e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800741:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800745:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800748:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80074f:	85 c0                	test   %eax,%eax
  800751:	74 26                	je     800779 <vsnprintf+0x47>
  800753:	85 d2                	test   %edx,%edx
  800755:	7e 22                	jle    800779 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800757:	ff 75 14             	pushl  0x14(%ebp)
  80075a:	ff 75 10             	pushl  0x10(%ebp)
  80075d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800760:	50                   	push   %eax
  800761:	68 4b 03 80 00       	push   $0x80034b
  800766:	e8 1a fc ff ff       	call   800385 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80076b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80076e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800771:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800774:	83 c4 10             	add    $0x10,%esp
  800777:	eb 05                	jmp    80077e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800779:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80077e:	c9                   	leave  
  80077f:	c3                   	ret    

00800780 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800786:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800789:	50                   	push   %eax
  80078a:	ff 75 10             	pushl  0x10(%ebp)
  80078d:	ff 75 0c             	pushl  0xc(%ebp)
  800790:	ff 75 08             	pushl  0x8(%ebp)
  800793:	e8 9a ff ff ff       	call   800732 <vsnprintf>
	va_end(ap);

	return rc;
}
  800798:	c9                   	leave  
  800799:	c3                   	ret    

0080079a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a5:	eb 03                	jmp    8007aa <strlen+0x10>
		n++;
  8007a7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007aa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ae:	75 f7                	jne    8007a7 <strlen+0xd>
		n++;
	return n;
}
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c0:	eb 03                	jmp    8007c5 <strnlen+0x13>
		n++;
  8007c2:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c5:	39 c2                	cmp    %eax,%edx
  8007c7:	74 08                	je     8007d1 <strnlen+0x1f>
  8007c9:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007cd:	75 f3                	jne    8007c2 <strnlen+0x10>
  8007cf:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007d1:	5d                   	pop    %ebp
  8007d2:	c3                   	ret    

008007d3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	53                   	push   %ebx
  8007d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007dd:	89 c2                	mov    %eax,%edx
  8007df:	83 c2 01             	add    $0x1,%edx
  8007e2:	83 c1 01             	add    $0x1,%ecx
  8007e5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007e9:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ec:	84 db                	test   %bl,%bl
  8007ee:	75 ef                	jne    8007df <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007f0:	5b                   	pop    %ebx
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	53                   	push   %ebx
  8007f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007fa:	53                   	push   %ebx
  8007fb:	e8 9a ff ff ff       	call   80079a <strlen>
  800800:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800803:	ff 75 0c             	pushl  0xc(%ebp)
  800806:	01 d8                	add    %ebx,%eax
  800808:	50                   	push   %eax
  800809:	e8 c5 ff ff ff       	call   8007d3 <strcpy>
	return dst;
}
  80080e:	89 d8                	mov    %ebx,%eax
  800810:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800813:	c9                   	leave  
  800814:	c3                   	ret    

00800815 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	56                   	push   %esi
  800819:	53                   	push   %ebx
  80081a:	8b 75 08             	mov    0x8(%ebp),%esi
  80081d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800820:	89 f3                	mov    %esi,%ebx
  800822:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800825:	89 f2                	mov    %esi,%edx
  800827:	eb 0f                	jmp    800838 <strncpy+0x23>
		*dst++ = *src;
  800829:	83 c2 01             	add    $0x1,%edx
  80082c:	0f b6 01             	movzbl (%ecx),%eax
  80082f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800832:	80 39 01             	cmpb   $0x1,(%ecx)
  800835:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800838:	39 da                	cmp    %ebx,%edx
  80083a:	75 ed                	jne    800829 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80083c:	89 f0                	mov    %esi,%eax
  80083e:	5b                   	pop    %ebx
  80083f:	5e                   	pop    %esi
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	56                   	push   %esi
  800846:	53                   	push   %ebx
  800847:	8b 75 08             	mov    0x8(%ebp),%esi
  80084a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084d:	8b 55 10             	mov    0x10(%ebp),%edx
  800850:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800852:	85 d2                	test   %edx,%edx
  800854:	74 21                	je     800877 <strlcpy+0x35>
  800856:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80085a:	89 f2                	mov    %esi,%edx
  80085c:	eb 09                	jmp    800867 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80085e:	83 c2 01             	add    $0x1,%edx
  800861:	83 c1 01             	add    $0x1,%ecx
  800864:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800867:	39 c2                	cmp    %eax,%edx
  800869:	74 09                	je     800874 <strlcpy+0x32>
  80086b:	0f b6 19             	movzbl (%ecx),%ebx
  80086e:	84 db                	test   %bl,%bl
  800870:	75 ec                	jne    80085e <strlcpy+0x1c>
  800872:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800874:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800877:	29 f0                	sub    %esi,%eax
}
  800879:	5b                   	pop    %ebx
  80087a:	5e                   	pop    %esi
  80087b:	5d                   	pop    %ebp
  80087c:	c3                   	ret    

0080087d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800883:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800886:	eb 06                	jmp    80088e <strcmp+0x11>
		p++, q++;
  800888:	83 c1 01             	add    $0x1,%ecx
  80088b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80088e:	0f b6 01             	movzbl (%ecx),%eax
  800891:	84 c0                	test   %al,%al
  800893:	74 04                	je     800899 <strcmp+0x1c>
  800895:	3a 02                	cmp    (%edx),%al
  800897:	74 ef                	je     800888 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800899:	0f b6 c0             	movzbl %al,%eax
  80089c:	0f b6 12             	movzbl (%edx),%edx
  80089f:	29 d0                	sub    %edx,%eax
}
  8008a1:	5d                   	pop    %ebp
  8008a2:	c3                   	ret    

008008a3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	53                   	push   %ebx
  8008a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ad:	89 c3                	mov    %eax,%ebx
  8008af:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b2:	eb 06                	jmp    8008ba <strncmp+0x17>
		n--, p++, q++;
  8008b4:	83 c0 01             	add    $0x1,%eax
  8008b7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008ba:	39 d8                	cmp    %ebx,%eax
  8008bc:	74 15                	je     8008d3 <strncmp+0x30>
  8008be:	0f b6 08             	movzbl (%eax),%ecx
  8008c1:	84 c9                	test   %cl,%cl
  8008c3:	74 04                	je     8008c9 <strncmp+0x26>
  8008c5:	3a 0a                	cmp    (%edx),%cl
  8008c7:	74 eb                	je     8008b4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c9:	0f b6 00             	movzbl (%eax),%eax
  8008cc:	0f b6 12             	movzbl (%edx),%edx
  8008cf:	29 d0                	sub    %edx,%eax
  8008d1:	eb 05                	jmp    8008d8 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008d3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008d8:	5b                   	pop    %ebx
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e5:	eb 07                	jmp    8008ee <strchr+0x13>
		if (*s == c)
  8008e7:	38 ca                	cmp    %cl,%dl
  8008e9:	74 0f                	je     8008fa <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008eb:	83 c0 01             	add    $0x1,%eax
  8008ee:	0f b6 10             	movzbl (%eax),%edx
  8008f1:	84 d2                	test   %dl,%dl
  8008f3:	75 f2                	jne    8008e7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008fa:	5d                   	pop    %ebp
  8008fb:	c3                   	ret    

008008fc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800902:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800906:	eb 03                	jmp    80090b <strfind+0xf>
  800908:	83 c0 01             	add    $0x1,%eax
  80090b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80090e:	38 ca                	cmp    %cl,%dl
  800910:	74 04                	je     800916 <strfind+0x1a>
  800912:	84 d2                	test   %dl,%dl
  800914:	75 f2                	jne    800908 <strfind+0xc>
			break;
	return (char *) s;
}
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	57                   	push   %edi
  80091c:	56                   	push   %esi
  80091d:	53                   	push   %ebx
  80091e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800921:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800924:	85 c9                	test   %ecx,%ecx
  800926:	74 36                	je     80095e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800928:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80092e:	75 28                	jne    800958 <memset+0x40>
  800930:	f6 c1 03             	test   $0x3,%cl
  800933:	75 23                	jne    800958 <memset+0x40>
		c &= 0xFF;
  800935:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800939:	89 d3                	mov    %edx,%ebx
  80093b:	c1 e3 08             	shl    $0x8,%ebx
  80093e:	89 d6                	mov    %edx,%esi
  800940:	c1 e6 18             	shl    $0x18,%esi
  800943:	89 d0                	mov    %edx,%eax
  800945:	c1 e0 10             	shl    $0x10,%eax
  800948:	09 f0                	or     %esi,%eax
  80094a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80094c:	89 d8                	mov    %ebx,%eax
  80094e:	09 d0                	or     %edx,%eax
  800950:	c1 e9 02             	shr    $0x2,%ecx
  800953:	fc                   	cld    
  800954:	f3 ab                	rep stos %eax,%es:(%edi)
  800956:	eb 06                	jmp    80095e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800958:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095b:	fc                   	cld    
  80095c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80095e:	89 f8                	mov    %edi,%eax
  800960:	5b                   	pop    %ebx
  800961:	5e                   	pop    %esi
  800962:	5f                   	pop    %edi
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	57                   	push   %edi
  800969:	56                   	push   %esi
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800970:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800973:	39 c6                	cmp    %eax,%esi
  800975:	73 35                	jae    8009ac <memmove+0x47>
  800977:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80097a:	39 d0                	cmp    %edx,%eax
  80097c:	73 2e                	jae    8009ac <memmove+0x47>
		s += n;
		d += n;
  80097e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800981:	89 d6                	mov    %edx,%esi
  800983:	09 fe                	or     %edi,%esi
  800985:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80098b:	75 13                	jne    8009a0 <memmove+0x3b>
  80098d:	f6 c1 03             	test   $0x3,%cl
  800990:	75 0e                	jne    8009a0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800992:	83 ef 04             	sub    $0x4,%edi
  800995:	8d 72 fc             	lea    -0x4(%edx),%esi
  800998:	c1 e9 02             	shr    $0x2,%ecx
  80099b:	fd                   	std    
  80099c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099e:	eb 09                	jmp    8009a9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a0:	83 ef 01             	sub    $0x1,%edi
  8009a3:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009a6:	fd                   	std    
  8009a7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a9:	fc                   	cld    
  8009aa:	eb 1d                	jmp    8009c9 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ac:	89 f2                	mov    %esi,%edx
  8009ae:	09 c2                	or     %eax,%edx
  8009b0:	f6 c2 03             	test   $0x3,%dl
  8009b3:	75 0f                	jne    8009c4 <memmove+0x5f>
  8009b5:	f6 c1 03             	test   $0x3,%cl
  8009b8:	75 0a                	jne    8009c4 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009ba:	c1 e9 02             	shr    $0x2,%ecx
  8009bd:	89 c7                	mov    %eax,%edi
  8009bf:	fc                   	cld    
  8009c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c2:	eb 05                	jmp    8009c9 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c4:	89 c7                	mov    %eax,%edi
  8009c6:	fc                   	cld    
  8009c7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c9:	5e                   	pop    %esi
  8009ca:	5f                   	pop    %edi
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    

008009cd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009d0:	ff 75 10             	pushl  0x10(%ebp)
  8009d3:	ff 75 0c             	pushl  0xc(%ebp)
  8009d6:	ff 75 08             	pushl  0x8(%ebp)
  8009d9:	e8 87 ff ff ff       	call   800965 <memmove>
}
  8009de:	c9                   	leave  
  8009df:	c3                   	ret    

008009e0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	56                   	push   %esi
  8009e4:	53                   	push   %ebx
  8009e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009eb:	89 c6                	mov    %eax,%esi
  8009ed:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f0:	eb 1a                	jmp    800a0c <memcmp+0x2c>
		if (*s1 != *s2)
  8009f2:	0f b6 08             	movzbl (%eax),%ecx
  8009f5:	0f b6 1a             	movzbl (%edx),%ebx
  8009f8:	38 d9                	cmp    %bl,%cl
  8009fa:	74 0a                	je     800a06 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009fc:	0f b6 c1             	movzbl %cl,%eax
  8009ff:	0f b6 db             	movzbl %bl,%ebx
  800a02:	29 d8                	sub    %ebx,%eax
  800a04:	eb 0f                	jmp    800a15 <memcmp+0x35>
		s1++, s2++;
  800a06:	83 c0 01             	add    $0x1,%eax
  800a09:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0c:	39 f0                	cmp    %esi,%eax
  800a0e:	75 e2                	jne    8009f2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a10:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a15:	5b                   	pop    %ebx
  800a16:	5e                   	pop    %esi
  800a17:	5d                   	pop    %ebp
  800a18:	c3                   	ret    

00800a19 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	53                   	push   %ebx
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a20:	89 c1                	mov    %eax,%ecx
  800a22:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a25:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a29:	eb 0a                	jmp    800a35 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a2b:	0f b6 10             	movzbl (%eax),%edx
  800a2e:	39 da                	cmp    %ebx,%edx
  800a30:	74 07                	je     800a39 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a32:	83 c0 01             	add    $0x1,%eax
  800a35:	39 c8                	cmp    %ecx,%eax
  800a37:	72 f2                	jb     800a2b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a39:	5b                   	pop    %ebx
  800a3a:	5d                   	pop    %ebp
  800a3b:	c3                   	ret    

00800a3c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	57                   	push   %edi
  800a40:	56                   	push   %esi
  800a41:	53                   	push   %ebx
  800a42:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a45:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a48:	eb 03                	jmp    800a4d <strtol+0x11>
		s++;
  800a4a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4d:	0f b6 01             	movzbl (%ecx),%eax
  800a50:	3c 20                	cmp    $0x20,%al
  800a52:	74 f6                	je     800a4a <strtol+0xe>
  800a54:	3c 09                	cmp    $0x9,%al
  800a56:	74 f2                	je     800a4a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a58:	3c 2b                	cmp    $0x2b,%al
  800a5a:	75 0a                	jne    800a66 <strtol+0x2a>
		s++;
  800a5c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a5f:	bf 00 00 00 00       	mov    $0x0,%edi
  800a64:	eb 11                	jmp    800a77 <strtol+0x3b>
  800a66:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a6b:	3c 2d                	cmp    $0x2d,%al
  800a6d:	75 08                	jne    800a77 <strtol+0x3b>
		s++, neg = 1;
  800a6f:	83 c1 01             	add    $0x1,%ecx
  800a72:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a77:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a7d:	75 15                	jne    800a94 <strtol+0x58>
  800a7f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a82:	75 10                	jne    800a94 <strtol+0x58>
  800a84:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a88:	75 7c                	jne    800b06 <strtol+0xca>
		s += 2, base = 16;
  800a8a:	83 c1 02             	add    $0x2,%ecx
  800a8d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a92:	eb 16                	jmp    800aaa <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a94:	85 db                	test   %ebx,%ebx
  800a96:	75 12                	jne    800aaa <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a98:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a9d:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa0:	75 08                	jne    800aaa <strtol+0x6e>
		s++, base = 8;
  800aa2:	83 c1 01             	add    $0x1,%ecx
  800aa5:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aaa:	b8 00 00 00 00       	mov    $0x0,%eax
  800aaf:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ab2:	0f b6 11             	movzbl (%ecx),%edx
  800ab5:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ab8:	89 f3                	mov    %esi,%ebx
  800aba:	80 fb 09             	cmp    $0x9,%bl
  800abd:	77 08                	ja     800ac7 <strtol+0x8b>
			dig = *s - '0';
  800abf:	0f be d2             	movsbl %dl,%edx
  800ac2:	83 ea 30             	sub    $0x30,%edx
  800ac5:	eb 22                	jmp    800ae9 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ac7:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aca:	89 f3                	mov    %esi,%ebx
  800acc:	80 fb 19             	cmp    $0x19,%bl
  800acf:	77 08                	ja     800ad9 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ad1:	0f be d2             	movsbl %dl,%edx
  800ad4:	83 ea 57             	sub    $0x57,%edx
  800ad7:	eb 10                	jmp    800ae9 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ad9:	8d 72 bf             	lea    -0x41(%edx),%esi
  800adc:	89 f3                	mov    %esi,%ebx
  800ade:	80 fb 19             	cmp    $0x19,%bl
  800ae1:	77 16                	ja     800af9 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ae3:	0f be d2             	movsbl %dl,%edx
  800ae6:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ae9:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aec:	7d 0b                	jge    800af9 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800aee:	83 c1 01             	add    $0x1,%ecx
  800af1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800af5:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800af7:	eb b9                	jmp    800ab2 <strtol+0x76>

	if (endptr)
  800af9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800afd:	74 0d                	je     800b0c <strtol+0xd0>
		*endptr = (char *) s;
  800aff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b02:	89 0e                	mov    %ecx,(%esi)
  800b04:	eb 06                	jmp    800b0c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b06:	85 db                	test   %ebx,%ebx
  800b08:	74 98                	je     800aa2 <strtol+0x66>
  800b0a:	eb 9e                	jmp    800aaa <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b0c:	89 c2                	mov    %eax,%edx
  800b0e:	f7 da                	neg    %edx
  800b10:	85 ff                	test   %edi,%edi
  800b12:	0f 45 c2             	cmovne %edx,%eax
}
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	57                   	push   %edi
  800b1e:	56                   	push   %esi
  800b1f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b20:	b8 00 00 00 00       	mov    $0x0,%eax
  800b25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b28:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2b:	89 c3                	mov    %eax,%ebx
  800b2d:	89 c7                	mov    %eax,%edi
  800b2f:	89 c6                	mov    %eax,%esi
  800b31:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b33:	5b                   	pop    %ebx
  800b34:	5e                   	pop    %esi
  800b35:	5f                   	pop    %edi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b43:	b8 01 00 00 00       	mov    $0x1,%eax
  800b48:	89 d1                	mov    %edx,%ecx
  800b4a:	89 d3                	mov    %edx,%ebx
  800b4c:	89 d7                	mov    %edx,%edi
  800b4e:	89 d6                	mov    %edx,%esi
  800b50:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	57                   	push   %edi
  800b5b:	56                   	push   %esi
  800b5c:	53                   	push   %ebx
  800b5d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b60:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b65:	b8 03 00 00 00       	mov    $0x3,%eax
  800b6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6d:	89 cb                	mov    %ecx,%ebx
  800b6f:	89 cf                	mov    %ecx,%edi
  800b71:	89 ce                	mov    %ecx,%esi
  800b73:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b75:	85 c0                	test   %eax,%eax
  800b77:	7e 17                	jle    800b90 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b79:	83 ec 0c             	sub    $0xc,%esp
  800b7c:	50                   	push   %eax
  800b7d:	6a 03                	push   $0x3
  800b7f:	68 df 25 80 00       	push   $0x8025df
  800b84:	6a 23                	push   $0x23
  800b86:	68 fc 25 80 00       	push   $0x8025fc
  800b8b:	e8 e5 f5 ff ff       	call   800175 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b93:	5b                   	pop    %ebx
  800b94:	5e                   	pop    %esi
  800b95:	5f                   	pop    %edi
  800b96:	5d                   	pop    %ebp
  800b97:	c3                   	ret    

00800b98 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	57                   	push   %edi
  800b9c:	56                   	push   %esi
  800b9d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9e:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba3:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba8:	89 d1                	mov    %edx,%ecx
  800baa:	89 d3                	mov    %edx,%ebx
  800bac:	89 d7                	mov    %edx,%edi
  800bae:	89 d6                	mov    %edx,%esi
  800bb0:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <sys_yield>:

void
sys_yield(void)
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
  800bc2:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bc7:	89 d1                	mov    %edx,%ecx
  800bc9:	89 d3                	mov    %edx,%ebx
  800bcb:	89 d7                	mov    %edx,%edi
  800bcd:	89 d6                	mov    %edx,%esi
  800bcf:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800bdf:	be 00 00 00 00       	mov    $0x0,%esi
  800be4:	b8 04 00 00 00       	mov    $0x4,%eax
  800be9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bec:	8b 55 08             	mov    0x8(%ebp),%edx
  800bef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf2:	89 f7                	mov    %esi,%edi
  800bf4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf6:	85 c0                	test   %eax,%eax
  800bf8:	7e 17                	jle    800c11 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfa:	83 ec 0c             	sub    $0xc,%esp
  800bfd:	50                   	push   %eax
  800bfe:	6a 04                	push   $0x4
  800c00:	68 df 25 80 00       	push   $0x8025df
  800c05:	6a 23                	push   $0x23
  800c07:	68 fc 25 80 00       	push   $0x8025fc
  800c0c:	e8 64 f5 ff ff       	call   800175 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    

00800c19 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800c22:	b8 05 00 00 00       	mov    $0x5,%eax
  800c27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c30:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c33:	8b 75 18             	mov    0x18(%ebp),%esi
  800c36:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c38:	85 c0                	test   %eax,%eax
  800c3a:	7e 17                	jle    800c53 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3c:	83 ec 0c             	sub    $0xc,%esp
  800c3f:	50                   	push   %eax
  800c40:	6a 05                	push   $0x5
  800c42:	68 df 25 80 00       	push   $0x8025df
  800c47:	6a 23                	push   $0x23
  800c49:	68 fc 25 80 00       	push   $0x8025fc
  800c4e:	e8 22 f5 ff ff       	call   800175 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800c64:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c69:	b8 06 00 00 00       	mov    $0x6,%eax
  800c6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c71:	8b 55 08             	mov    0x8(%ebp),%edx
  800c74:	89 df                	mov    %ebx,%edi
  800c76:	89 de                	mov    %ebx,%esi
  800c78:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7a:	85 c0                	test   %eax,%eax
  800c7c:	7e 17                	jle    800c95 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7e:	83 ec 0c             	sub    $0xc,%esp
  800c81:	50                   	push   %eax
  800c82:	6a 06                	push   $0x6
  800c84:	68 df 25 80 00       	push   $0x8025df
  800c89:	6a 23                	push   $0x23
  800c8b:	68 fc 25 80 00       	push   $0x8025fc
  800c90:	e8 e0 f4 ff ff       	call   800175 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c98:	5b                   	pop    %ebx
  800c99:	5e                   	pop    %esi
  800c9a:	5f                   	pop    %edi
  800c9b:	5d                   	pop    %ebp
  800c9c:	c3                   	ret    

00800c9d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800cab:	b8 08 00 00 00       	mov    $0x8,%eax
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
  800cbe:	7e 17                	jle    800cd7 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc0:	83 ec 0c             	sub    $0xc,%esp
  800cc3:	50                   	push   %eax
  800cc4:	6a 08                	push   $0x8
  800cc6:	68 df 25 80 00       	push   $0x8025df
  800ccb:	6a 23                	push   $0x23
  800ccd:	68 fc 25 80 00       	push   $0x8025fc
  800cd2:	e8 9e f4 ff ff       	call   800175 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800ced:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800d00:	7e 17                	jle    800d19 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	50                   	push   %eax
  800d06:	6a 09                	push   $0x9
  800d08:	68 df 25 80 00       	push   $0x8025df
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 fc 25 80 00       	push   $0x8025fc
  800d14:	e8 5c f4 ff ff       	call   800175 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800d2f:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800d42:	7e 17                	jle    800d5b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d44:	83 ec 0c             	sub    $0xc,%esp
  800d47:	50                   	push   %eax
  800d48:	6a 0a                	push   $0xa
  800d4a:	68 df 25 80 00       	push   $0x8025df
  800d4f:	6a 23                	push   $0x23
  800d51:	68 fc 25 80 00       	push   $0x8025fc
  800d56:	e8 1a f4 ff ff       	call   800175 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	57                   	push   %edi
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d69:	be 00 00 00 00       	mov    $0x0,%esi
  800d6e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d76:	8b 55 08             	mov    0x8(%ebp),%edx
  800d79:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d7f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d81:	5b                   	pop    %ebx
  800d82:	5e                   	pop    %esi
  800d83:	5f                   	pop    %edi
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    

00800d86 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	57                   	push   %edi
  800d8a:	56                   	push   %esi
  800d8b:	53                   	push   %ebx
  800d8c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d94:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d99:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9c:	89 cb                	mov    %ecx,%ebx
  800d9e:	89 cf                	mov    %ecx,%edi
  800da0:	89 ce                	mov    %ecx,%esi
  800da2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da4:	85 c0                	test   %eax,%eax
  800da6:	7e 17                	jle    800dbf <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da8:	83 ec 0c             	sub    $0xc,%esp
  800dab:	50                   	push   %eax
  800dac:	6a 0d                	push   $0xd
  800dae:	68 df 25 80 00       	push   $0x8025df
  800db3:	6a 23                	push   $0x23
  800db5:	68 fc 25 80 00       	push   $0x8025fc
  800dba:	e8 b6 f3 ff ff       	call   800175 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc2:	5b                   	pop    %ebx
  800dc3:	5e                   	pop    %esi
  800dc4:	5f                   	pop    %edi
  800dc5:	5d                   	pop    %ebp
  800dc6:	c3                   	ret    

00800dc7 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800dc7:	55                   	push   %ebp
  800dc8:	89 e5                	mov    %esp,%ebp
  800dca:	57                   	push   %edi
  800dcb:	56                   	push   %esi
  800dcc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd2:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dda:	89 cb                	mov    %ecx,%ebx
  800ddc:	89 cf                	mov    %ecx,%edi
  800dde:	89 ce                	mov    %ecx,%esi
  800de0:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800de2:	5b                   	pop    %ebx
  800de3:	5e                   	pop    %esi
  800de4:	5f                   	pop    %edi
  800de5:	5d                   	pop    %ebp
  800de6:	c3                   	ret    

00800de7 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	57                   	push   %edi
  800deb:	56                   	push   %esi
  800dec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ded:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df2:	b8 0f 00 00 00       	mov    $0xf,%eax
  800df7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfa:	89 cb                	mov    %ecx,%ebx
  800dfc:	89 cf                	mov    %ecx,%edi
  800dfe:	89 ce                	mov    %ecx,%esi
  800e00:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800e02:	5b                   	pop    %ebx
  800e03:	5e                   	pop    %esi
  800e04:	5f                   	pop    %edi
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    

00800e07 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
  800e0a:	53                   	push   %ebx
  800e0b:	83 ec 04             	sub    $0x4,%esp
  800e0e:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e11:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800e13:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e17:	74 11                	je     800e2a <pgfault+0x23>
  800e19:	89 d8                	mov    %ebx,%eax
  800e1b:	c1 e8 0c             	shr    $0xc,%eax
  800e1e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e25:	f6 c4 08             	test   $0x8,%ah
  800e28:	75 14                	jne    800e3e <pgfault+0x37>
		panic("faulting access");
  800e2a:	83 ec 04             	sub    $0x4,%esp
  800e2d:	68 0a 26 80 00       	push   $0x80260a
  800e32:	6a 1e                	push   $0x1e
  800e34:	68 1a 26 80 00       	push   $0x80261a
  800e39:	e8 37 f3 ff ff       	call   800175 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e3e:	83 ec 04             	sub    $0x4,%esp
  800e41:	6a 07                	push   $0x7
  800e43:	68 00 f0 7f 00       	push   $0x7ff000
  800e48:	6a 00                	push   $0x0
  800e4a:	e8 87 fd ff ff       	call   800bd6 <sys_page_alloc>
	if (r < 0) {
  800e4f:	83 c4 10             	add    $0x10,%esp
  800e52:	85 c0                	test   %eax,%eax
  800e54:	79 12                	jns    800e68 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e56:	50                   	push   %eax
  800e57:	68 25 26 80 00       	push   $0x802625
  800e5c:	6a 2c                	push   $0x2c
  800e5e:	68 1a 26 80 00       	push   $0x80261a
  800e63:	e8 0d f3 ff ff       	call   800175 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e68:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e6e:	83 ec 04             	sub    $0x4,%esp
  800e71:	68 00 10 00 00       	push   $0x1000
  800e76:	53                   	push   %ebx
  800e77:	68 00 f0 7f 00       	push   $0x7ff000
  800e7c:	e8 4c fb ff ff       	call   8009cd <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e81:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e88:	53                   	push   %ebx
  800e89:	6a 00                	push   $0x0
  800e8b:	68 00 f0 7f 00       	push   $0x7ff000
  800e90:	6a 00                	push   $0x0
  800e92:	e8 82 fd ff ff       	call   800c19 <sys_page_map>
	if (r < 0) {
  800e97:	83 c4 20             	add    $0x20,%esp
  800e9a:	85 c0                	test   %eax,%eax
  800e9c:	79 12                	jns    800eb0 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e9e:	50                   	push   %eax
  800e9f:	68 25 26 80 00       	push   $0x802625
  800ea4:	6a 33                	push   $0x33
  800ea6:	68 1a 26 80 00       	push   $0x80261a
  800eab:	e8 c5 f2 ff ff       	call   800175 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800eb0:	83 ec 08             	sub    $0x8,%esp
  800eb3:	68 00 f0 7f 00       	push   $0x7ff000
  800eb8:	6a 00                	push   $0x0
  800eba:	e8 9c fd ff ff       	call   800c5b <sys_page_unmap>
	if (r < 0) {
  800ebf:	83 c4 10             	add    $0x10,%esp
  800ec2:	85 c0                	test   %eax,%eax
  800ec4:	79 12                	jns    800ed8 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800ec6:	50                   	push   %eax
  800ec7:	68 25 26 80 00       	push   $0x802625
  800ecc:	6a 37                	push   $0x37
  800ece:	68 1a 26 80 00       	push   $0x80261a
  800ed3:	e8 9d f2 ff ff       	call   800175 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800ed8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800edb:	c9                   	leave  
  800edc:	c3                   	ret    

00800edd <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800edd:	55                   	push   %ebp
  800ede:	89 e5                	mov    %esp,%ebp
  800ee0:	57                   	push   %edi
  800ee1:	56                   	push   %esi
  800ee2:	53                   	push   %ebx
  800ee3:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800ee6:	68 07 0e 80 00       	push   $0x800e07
  800eeb:	e8 f3 0e 00 00       	call   801de3 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ef0:	b8 07 00 00 00       	mov    $0x7,%eax
  800ef5:	cd 30                	int    $0x30
  800ef7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800efa:	83 c4 10             	add    $0x10,%esp
  800efd:	85 c0                	test   %eax,%eax
  800eff:	79 17                	jns    800f18 <fork+0x3b>
		panic("fork fault %e");
  800f01:	83 ec 04             	sub    $0x4,%esp
  800f04:	68 3e 26 80 00       	push   $0x80263e
  800f09:	68 84 00 00 00       	push   $0x84
  800f0e:	68 1a 26 80 00       	push   $0x80261a
  800f13:	e8 5d f2 ff ff       	call   800175 <_panic>
  800f18:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f1a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f1e:	75 25                	jne    800f45 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f20:	e8 73 fc ff ff       	call   800b98 <sys_getenvid>
  800f25:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f2a:	89 c2                	mov    %eax,%edx
  800f2c:	c1 e2 07             	shl    $0x7,%edx
  800f2f:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800f36:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800f3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f40:	e9 61 01 00 00       	jmp    8010a6 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f45:	83 ec 04             	sub    $0x4,%esp
  800f48:	6a 07                	push   $0x7
  800f4a:	68 00 f0 bf ee       	push   $0xeebff000
  800f4f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f52:	e8 7f fc ff ff       	call   800bd6 <sys_page_alloc>
  800f57:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f5a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f5f:	89 d8                	mov    %ebx,%eax
  800f61:	c1 e8 16             	shr    $0x16,%eax
  800f64:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f6b:	a8 01                	test   $0x1,%al
  800f6d:	0f 84 fc 00 00 00    	je     80106f <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f73:	89 d8                	mov    %ebx,%eax
  800f75:	c1 e8 0c             	shr    $0xc,%eax
  800f78:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f7f:	f6 c2 01             	test   $0x1,%dl
  800f82:	0f 84 e7 00 00 00    	je     80106f <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f88:	89 c6                	mov    %eax,%esi
  800f8a:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f8d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f94:	f6 c6 04             	test   $0x4,%dh
  800f97:	74 39                	je     800fd2 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f99:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fa0:	83 ec 0c             	sub    $0xc,%esp
  800fa3:	25 07 0e 00 00       	and    $0xe07,%eax
  800fa8:	50                   	push   %eax
  800fa9:	56                   	push   %esi
  800faa:	57                   	push   %edi
  800fab:	56                   	push   %esi
  800fac:	6a 00                	push   $0x0
  800fae:	e8 66 fc ff ff       	call   800c19 <sys_page_map>
		if (r < 0) {
  800fb3:	83 c4 20             	add    $0x20,%esp
  800fb6:	85 c0                	test   %eax,%eax
  800fb8:	0f 89 b1 00 00 00    	jns    80106f <fork+0x192>
		    	panic("sys page map fault %e");
  800fbe:	83 ec 04             	sub    $0x4,%esp
  800fc1:	68 4c 26 80 00       	push   $0x80264c
  800fc6:	6a 54                	push   $0x54
  800fc8:	68 1a 26 80 00       	push   $0x80261a
  800fcd:	e8 a3 f1 ff ff       	call   800175 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800fd2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fd9:	f6 c2 02             	test   $0x2,%dl
  800fdc:	75 0c                	jne    800fea <fork+0x10d>
  800fde:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fe5:	f6 c4 08             	test   $0x8,%ah
  800fe8:	74 5b                	je     801045 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800fea:	83 ec 0c             	sub    $0xc,%esp
  800fed:	68 05 08 00 00       	push   $0x805
  800ff2:	56                   	push   %esi
  800ff3:	57                   	push   %edi
  800ff4:	56                   	push   %esi
  800ff5:	6a 00                	push   $0x0
  800ff7:	e8 1d fc ff ff       	call   800c19 <sys_page_map>
		if (r < 0) {
  800ffc:	83 c4 20             	add    $0x20,%esp
  800fff:	85 c0                	test   %eax,%eax
  801001:	79 14                	jns    801017 <fork+0x13a>
		    	panic("sys page map fault %e");
  801003:	83 ec 04             	sub    $0x4,%esp
  801006:	68 4c 26 80 00       	push   $0x80264c
  80100b:	6a 5b                	push   $0x5b
  80100d:	68 1a 26 80 00       	push   $0x80261a
  801012:	e8 5e f1 ff ff       	call   800175 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  801017:	83 ec 0c             	sub    $0xc,%esp
  80101a:	68 05 08 00 00       	push   $0x805
  80101f:	56                   	push   %esi
  801020:	6a 00                	push   $0x0
  801022:	56                   	push   %esi
  801023:	6a 00                	push   $0x0
  801025:	e8 ef fb ff ff       	call   800c19 <sys_page_map>
		if (r < 0) {
  80102a:	83 c4 20             	add    $0x20,%esp
  80102d:	85 c0                	test   %eax,%eax
  80102f:	79 3e                	jns    80106f <fork+0x192>
		    	panic("sys page map fault %e");
  801031:	83 ec 04             	sub    $0x4,%esp
  801034:	68 4c 26 80 00       	push   $0x80264c
  801039:	6a 5f                	push   $0x5f
  80103b:	68 1a 26 80 00       	push   $0x80261a
  801040:	e8 30 f1 ff ff       	call   800175 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801045:	83 ec 0c             	sub    $0xc,%esp
  801048:	6a 05                	push   $0x5
  80104a:	56                   	push   %esi
  80104b:	57                   	push   %edi
  80104c:	56                   	push   %esi
  80104d:	6a 00                	push   $0x0
  80104f:	e8 c5 fb ff ff       	call   800c19 <sys_page_map>
		if (r < 0) {
  801054:	83 c4 20             	add    $0x20,%esp
  801057:	85 c0                	test   %eax,%eax
  801059:	79 14                	jns    80106f <fork+0x192>
		    	panic("sys page map fault %e");
  80105b:	83 ec 04             	sub    $0x4,%esp
  80105e:	68 4c 26 80 00       	push   $0x80264c
  801063:	6a 64                	push   $0x64
  801065:	68 1a 26 80 00       	push   $0x80261a
  80106a:	e8 06 f1 ff ff       	call   800175 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80106f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801075:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80107b:	0f 85 de fe ff ff    	jne    800f5f <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801081:	a1 08 40 80 00       	mov    0x804008,%eax
  801086:	8b 40 70             	mov    0x70(%eax),%eax
  801089:	83 ec 08             	sub    $0x8,%esp
  80108c:	50                   	push   %eax
  80108d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801090:	57                   	push   %edi
  801091:	e8 8b fc ff ff       	call   800d21 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801096:	83 c4 08             	add    $0x8,%esp
  801099:	6a 02                	push   $0x2
  80109b:	57                   	push   %edi
  80109c:	e8 fc fb ff ff       	call   800c9d <sys_env_set_status>
	
	return envid;
  8010a1:	83 c4 10             	add    $0x10,%esp
  8010a4:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8010a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a9:	5b                   	pop    %ebx
  8010aa:	5e                   	pop    %esi
  8010ab:	5f                   	pop    %edi
  8010ac:	5d                   	pop    %ebp
  8010ad:	c3                   	ret    

008010ae <sfork>:

envid_t
sfork(void)
{
  8010ae:	55                   	push   %ebp
  8010af:	89 e5                	mov    %esp,%ebp
	return 0;
}
  8010b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010b6:	5d                   	pop    %ebp
  8010b7:	c3                   	ret    

008010b8 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	56                   	push   %esi
  8010bc:	53                   	push   %ebx
  8010bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  8010c0:	89 1d 0c 40 80 00    	mov    %ebx,0x80400c
	cprintf("in fork.c thread create. func: %x\n", func);
  8010c6:	83 ec 08             	sub    $0x8,%esp
  8010c9:	53                   	push   %ebx
  8010ca:	68 64 26 80 00       	push   $0x802664
  8010cf:	e8 7a f1 ff ff       	call   80024e <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8010d4:	c7 04 24 3b 01 80 00 	movl   $0x80013b,(%esp)
  8010db:	e8 e7 fc ff ff       	call   800dc7 <sys_thread_create>
  8010e0:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8010e2:	83 c4 08             	add    $0x8,%esp
  8010e5:	53                   	push   %ebx
  8010e6:	68 64 26 80 00       	push   $0x802664
  8010eb:	e8 5e f1 ff ff       	call   80024e <cprintf>
	return id;
	//return 0;
}
  8010f0:	89 f0                	mov    %esi,%eax
  8010f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010f5:	5b                   	pop    %ebx
  8010f6:	5e                   	pop    %esi
  8010f7:	5d                   	pop    %ebp
  8010f8:	c3                   	ret    

008010f9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010f9:	55                   	push   %ebp
  8010fa:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ff:	05 00 00 00 30       	add    $0x30000000,%eax
  801104:	c1 e8 0c             	shr    $0xc,%eax
}
  801107:	5d                   	pop    %ebp
  801108:	c3                   	ret    

00801109 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801109:	55                   	push   %ebp
  80110a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80110c:	8b 45 08             	mov    0x8(%ebp),%eax
  80110f:	05 00 00 00 30       	add    $0x30000000,%eax
  801114:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801119:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80111e:	5d                   	pop    %ebp
  80111f:	c3                   	ret    

00801120 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
  801123:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801126:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80112b:	89 c2                	mov    %eax,%edx
  80112d:	c1 ea 16             	shr    $0x16,%edx
  801130:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801137:	f6 c2 01             	test   $0x1,%dl
  80113a:	74 11                	je     80114d <fd_alloc+0x2d>
  80113c:	89 c2                	mov    %eax,%edx
  80113e:	c1 ea 0c             	shr    $0xc,%edx
  801141:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801148:	f6 c2 01             	test   $0x1,%dl
  80114b:	75 09                	jne    801156 <fd_alloc+0x36>
			*fd_store = fd;
  80114d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80114f:	b8 00 00 00 00       	mov    $0x0,%eax
  801154:	eb 17                	jmp    80116d <fd_alloc+0x4d>
  801156:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80115b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801160:	75 c9                	jne    80112b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801162:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801168:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80116d:	5d                   	pop    %ebp
  80116e:	c3                   	ret    

0080116f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80116f:	55                   	push   %ebp
  801170:	89 e5                	mov    %esp,%ebp
  801172:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801175:	83 f8 1f             	cmp    $0x1f,%eax
  801178:	77 36                	ja     8011b0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80117a:	c1 e0 0c             	shl    $0xc,%eax
  80117d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801182:	89 c2                	mov    %eax,%edx
  801184:	c1 ea 16             	shr    $0x16,%edx
  801187:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80118e:	f6 c2 01             	test   $0x1,%dl
  801191:	74 24                	je     8011b7 <fd_lookup+0x48>
  801193:	89 c2                	mov    %eax,%edx
  801195:	c1 ea 0c             	shr    $0xc,%edx
  801198:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80119f:	f6 c2 01             	test   $0x1,%dl
  8011a2:	74 1a                	je     8011be <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011a7:	89 02                	mov    %eax,(%edx)
	return 0;
  8011a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ae:	eb 13                	jmp    8011c3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011b0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b5:	eb 0c                	jmp    8011c3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011bc:	eb 05                	jmp    8011c3 <fd_lookup+0x54>
  8011be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011c3:	5d                   	pop    %ebp
  8011c4:	c3                   	ret    

008011c5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011c5:	55                   	push   %ebp
  8011c6:	89 e5                	mov    %esp,%ebp
  8011c8:	83 ec 08             	sub    $0x8,%esp
  8011cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ce:	ba 08 27 80 00       	mov    $0x802708,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011d3:	eb 13                	jmp    8011e8 <dev_lookup+0x23>
  8011d5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011d8:	39 08                	cmp    %ecx,(%eax)
  8011da:	75 0c                	jne    8011e8 <dev_lookup+0x23>
			*dev = devtab[i];
  8011dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011df:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e6:	eb 2e                	jmp    801216 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011e8:	8b 02                	mov    (%edx),%eax
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	75 e7                	jne    8011d5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011ee:	a1 08 40 80 00       	mov    0x804008,%eax
  8011f3:	8b 40 54             	mov    0x54(%eax),%eax
  8011f6:	83 ec 04             	sub    $0x4,%esp
  8011f9:	51                   	push   %ecx
  8011fa:	50                   	push   %eax
  8011fb:	68 88 26 80 00       	push   $0x802688
  801200:	e8 49 f0 ff ff       	call   80024e <cprintf>
	*dev = 0;
  801205:	8b 45 0c             	mov    0xc(%ebp),%eax
  801208:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80120e:	83 c4 10             	add    $0x10,%esp
  801211:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801216:	c9                   	leave  
  801217:	c3                   	ret    

00801218 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
  80121b:	56                   	push   %esi
  80121c:	53                   	push   %ebx
  80121d:	83 ec 10             	sub    $0x10,%esp
  801220:	8b 75 08             	mov    0x8(%ebp),%esi
  801223:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801226:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801229:	50                   	push   %eax
  80122a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801230:	c1 e8 0c             	shr    $0xc,%eax
  801233:	50                   	push   %eax
  801234:	e8 36 ff ff ff       	call   80116f <fd_lookup>
  801239:	83 c4 08             	add    $0x8,%esp
  80123c:	85 c0                	test   %eax,%eax
  80123e:	78 05                	js     801245 <fd_close+0x2d>
	    || fd != fd2)
  801240:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801243:	74 0c                	je     801251 <fd_close+0x39>
		return (must_exist ? r : 0);
  801245:	84 db                	test   %bl,%bl
  801247:	ba 00 00 00 00       	mov    $0x0,%edx
  80124c:	0f 44 c2             	cmove  %edx,%eax
  80124f:	eb 41                	jmp    801292 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801251:	83 ec 08             	sub    $0x8,%esp
  801254:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801257:	50                   	push   %eax
  801258:	ff 36                	pushl  (%esi)
  80125a:	e8 66 ff ff ff       	call   8011c5 <dev_lookup>
  80125f:	89 c3                	mov    %eax,%ebx
  801261:	83 c4 10             	add    $0x10,%esp
  801264:	85 c0                	test   %eax,%eax
  801266:	78 1a                	js     801282 <fd_close+0x6a>
		if (dev->dev_close)
  801268:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80126e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801273:	85 c0                	test   %eax,%eax
  801275:	74 0b                	je     801282 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801277:	83 ec 0c             	sub    $0xc,%esp
  80127a:	56                   	push   %esi
  80127b:	ff d0                	call   *%eax
  80127d:	89 c3                	mov    %eax,%ebx
  80127f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801282:	83 ec 08             	sub    $0x8,%esp
  801285:	56                   	push   %esi
  801286:	6a 00                	push   $0x0
  801288:	e8 ce f9 ff ff       	call   800c5b <sys_page_unmap>
	return r;
  80128d:	83 c4 10             	add    $0x10,%esp
  801290:	89 d8                	mov    %ebx,%eax
}
  801292:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801295:	5b                   	pop    %ebx
  801296:	5e                   	pop    %esi
  801297:	5d                   	pop    %ebp
  801298:	c3                   	ret    

00801299 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801299:	55                   	push   %ebp
  80129a:	89 e5                	mov    %esp,%ebp
  80129c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80129f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a2:	50                   	push   %eax
  8012a3:	ff 75 08             	pushl  0x8(%ebp)
  8012a6:	e8 c4 fe ff ff       	call   80116f <fd_lookup>
  8012ab:	83 c4 08             	add    $0x8,%esp
  8012ae:	85 c0                	test   %eax,%eax
  8012b0:	78 10                	js     8012c2 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012b2:	83 ec 08             	sub    $0x8,%esp
  8012b5:	6a 01                	push   $0x1
  8012b7:	ff 75 f4             	pushl  -0xc(%ebp)
  8012ba:	e8 59 ff ff ff       	call   801218 <fd_close>
  8012bf:	83 c4 10             	add    $0x10,%esp
}
  8012c2:	c9                   	leave  
  8012c3:	c3                   	ret    

008012c4 <close_all>:

void
close_all(void)
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	53                   	push   %ebx
  8012c8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012cb:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012d0:	83 ec 0c             	sub    $0xc,%esp
  8012d3:	53                   	push   %ebx
  8012d4:	e8 c0 ff ff ff       	call   801299 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012d9:	83 c3 01             	add    $0x1,%ebx
  8012dc:	83 c4 10             	add    $0x10,%esp
  8012df:	83 fb 20             	cmp    $0x20,%ebx
  8012e2:	75 ec                	jne    8012d0 <close_all+0xc>
		close(i);
}
  8012e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e7:	c9                   	leave  
  8012e8:	c3                   	ret    

008012e9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	57                   	push   %edi
  8012ed:	56                   	push   %esi
  8012ee:	53                   	push   %ebx
  8012ef:	83 ec 2c             	sub    $0x2c,%esp
  8012f2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012f5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012f8:	50                   	push   %eax
  8012f9:	ff 75 08             	pushl  0x8(%ebp)
  8012fc:	e8 6e fe ff ff       	call   80116f <fd_lookup>
  801301:	83 c4 08             	add    $0x8,%esp
  801304:	85 c0                	test   %eax,%eax
  801306:	0f 88 c1 00 00 00    	js     8013cd <dup+0xe4>
		return r;
	close(newfdnum);
  80130c:	83 ec 0c             	sub    $0xc,%esp
  80130f:	56                   	push   %esi
  801310:	e8 84 ff ff ff       	call   801299 <close>

	newfd = INDEX2FD(newfdnum);
  801315:	89 f3                	mov    %esi,%ebx
  801317:	c1 e3 0c             	shl    $0xc,%ebx
  80131a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801320:	83 c4 04             	add    $0x4,%esp
  801323:	ff 75 e4             	pushl  -0x1c(%ebp)
  801326:	e8 de fd ff ff       	call   801109 <fd2data>
  80132b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80132d:	89 1c 24             	mov    %ebx,(%esp)
  801330:	e8 d4 fd ff ff       	call   801109 <fd2data>
  801335:	83 c4 10             	add    $0x10,%esp
  801338:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80133b:	89 f8                	mov    %edi,%eax
  80133d:	c1 e8 16             	shr    $0x16,%eax
  801340:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801347:	a8 01                	test   $0x1,%al
  801349:	74 37                	je     801382 <dup+0x99>
  80134b:	89 f8                	mov    %edi,%eax
  80134d:	c1 e8 0c             	shr    $0xc,%eax
  801350:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801357:	f6 c2 01             	test   $0x1,%dl
  80135a:	74 26                	je     801382 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80135c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801363:	83 ec 0c             	sub    $0xc,%esp
  801366:	25 07 0e 00 00       	and    $0xe07,%eax
  80136b:	50                   	push   %eax
  80136c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80136f:	6a 00                	push   $0x0
  801371:	57                   	push   %edi
  801372:	6a 00                	push   $0x0
  801374:	e8 a0 f8 ff ff       	call   800c19 <sys_page_map>
  801379:	89 c7                	mov    %eax,%edi
  80137b:	83 c4 20             	add    $0x20,%esp
  80137e:	85 c0                	test   %eax,%eax
  801380:	78 2e                	js     8013b0 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801382:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801385:	89 d0                	mov    %edx,%eax
  801387:	c1 e8 0c             	shr    $0xc,%eax
  80138a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801391:	83 ec 0c             	sub    $0xc,%esp
  801394:	25 07 0e 00 00       	and    $0xe07,%eax
  801399:	50                   	push   %eax
  80139a:	53                   	push   %ebx
  80139b:	6a 00                	push   $0x0
  80139d:	52                   	push   %edx
  80139e:	6a 00                	push   $0x0
  8013a0:	e8 74 f8 ff ff       	call   800c19 <sys_page_map>
  8013a5:	89 c7                	mov    %eax,%edi
  8013a7:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013aa:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013ac:	85 ff                	test   %edi,%edi
  8013ae:	79 1d                	jns    8013cd <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013b0:	83 ec 08             	sub    $0x8,%esp
  8013b3:	53                   	push   %ebx
  8013b4:	6a 00                	push   $0x0
  8013b6:	e8 a0 f8 ff ff       	call   800c5b <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013bb:	83 c4 08             	add    $0x8,%esp
  8013be:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013c1:	6a 00                	push   $0x0
  8013c3:	e8 93 f8 ff ff       	call   800c5b <sys_page_unmap>
	return r;
  8013c8:	83 c4 10             	add    $0x10,%esp
  8013cb:	89 f8                	mov    %edi,%eax
}
  8013cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d0:	5b                   	pop    %ebx
  8013d1:	5e                   	pop    %esi
  8013d2:	5f                   	pop    %edi
  8013d3:	5d                   	pop    %ebp
  8013d4:	c3                   	ret    

008013d5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013d5:	55                   	push   %ebp
  8013d6:	89 e5                	mov    %esp,%ebp
  8013d8:	53                   	push   %ebx
  8013d9:	83 ec 14             	sub    $0x14,%esp
  8013dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e2:	50                   	push   %eax
  8013e3:	53                   	push   %ebx
  8013e4:	e8 86 fd ff ff       	call   80116f <fd_lookup>
  8013e9:	83 c4 08             	add    $0x8,%esp
  8013ec:	89 c2                	mov    %eax,%edx
  8013ee:	85 c0                	test   %eax,%eax
  8013f0:	78 6d                	js     80145f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f2:	83 ec 08             	sub    $0x8,%esp
  8013f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f8:	50                   	push   %eax
  8013f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013fc:	ff 30                	pushl  (%eax)
  8013fe:	e8 c2 fd ff ff       	call   8011c5 <dev_lookup>
  801403:	83 c4 10             	add    $0x10,%esp
  801406:	85 c0                	test   %eax,%eax
  801408:	78 4c                	js     801456 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80140a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80140d:	8b 42 08             	mov    0x8(%edx),%eax
  801410:	83 e0 03             	and    $0x3,%eax
  801413:	83 f8 01             	cmp    $0x1,%eax
  801416:	75 21                	jne    801439 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801418:	a1 08 40 80 00       	mov    0x804008,%eax
  80141d:	8b 40 54             	mov    0x54(%eax),%eax
  801420:	83 ec 04             	sub    $0x4,%esp
  801423:	53                   	push   %ebx
  801424:	50                   	push   %eax
  801425:	68 cc 26 80 00       	push   $0x8026cc
  80142a:	e8 1f ee ff ff       	call   80024e <cprintf>
		return -E_INVAL;
  80142f:	83 c4 10             	add    $0x10,%esp
  801432:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801437:	eb 26                	jmp    80145f <read+0x8a>
	}
	if (!dev->dev_read)
  801439:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80143c:	8b 40 08             	mov    0x8(%eax),%eax
  80143f:	85 c0                	test   %eax,%eax
  801441:	74 17                	je     80145a <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801443:	83 ec 04             	sub    $0x4,%esp
  801446:	ff 75 10             	pushl  0x10(%ebp)
  801449:	ff 75 0c             	pushl  0xc(%ebp)
  80144c:	52                   	push   %edx
  80144d:	ff d0                	call   *%eax
  80144f:	89 c2                	mov    %eax,%edx
  801451:	83 c4 10             	add    $0x10,%esp
  801454:	eb 09                	jmp    80145f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801456:	89 c2                	mov    %eax,%edx
  801458:	eb 05                	jmp    80145f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80145a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80145f:	89 d0                	mov    %edx,%eax
  801461:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801464:	c9                   	leave  
  801465:	c3                   	ret    

00801466 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801466:	55                   	push   %ebp
  801467:	89 e5                	mov    %esp,%ebp
  801469:	57                   	push   %edi
  80146a:	56                   	push   %esi
  80146b:	53                   	push   %ebx
  80146c:	83 ec 0c             	sub    $0xc,%esp
  80146f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801472:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801475:	bb 00 00 00 00       	mov    $0x0,%ebx
  80147a:	eb 21                	jmp    80149d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80147c:	83 ec 04             	sub    $0x4,%esp
  80147f:	89 f0                	mov    %esi,%eax
  801481:	29 d8                	sub    %ebx,%eax
  801483:	50                   	push   %eax
  801484:	89 d8                	mov    %ebx,%eax
  801486:	03 45 0c             	add    0xc(%ebp),%eax
  801489:	50                   	push   %eax
  80148a:	57                   	push   %edi
  80148b:	e8 45 ff ff ff       	call   8013d5 <read>
		if (m < 0)
  801490:	83 c4 10             	add    $0x10,%esp
  801493:	85 c0                	test   %eax,%eax
  801495:	78 10                	js     8014a7 <readn+0x41>
			return m;
		if (m == 0)
  801497:	85 c0                	test   %eax,%eax
  801499:	74 0a                	je     8014a5 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80149b:	01 c3                	add    %eax,%ebx
  80149d:	39 f3                	cmp    %esi,%ebx
  80149f:	72 db                	jb     80147c <readn+0x16>
  8014a1:	89 d8                	mov    %ebx,%eax
  8014a3:	eb 02                	jmp    8014a7 <readn+0x41>
  8014a5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014aa:	5b                   	pop    %ebx
  8014ab:	5e                   	pop    %esi
  8014ac:	5f                   	pop    %edi
  8014ad:	5d                   	pop    %ebp
  8014ae:	c3                   	ret    

008014af <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014af:	55                   	push   %ebp
  8014b0:	89 e5                	mov    %esp,%ebp
  8014b2:	53                   	push   %ebx
  8014b3:	83 ec 14             	sub    $0x14,%esp
  8014b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014bc:	50                   	push   %eax
  8014bd:	53                   	push   %ebx
  8014be:	e8 ac fc ff ff       	call   80116f <fd_lookup>
  8014c3:	83 c4 08             	add    $0x8,%esp
  8014c6:	89 c2                	mov    %eax,%edx
  8014c8:	85 c0                	test   %eax,%eax
  8014ca:	78 68                	js     801534 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014cc:	83 ec 08             	sub    $0x8,%esp
  8014cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d2:	50                   	push   %eax
  8014d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d6:	ff 30                	pushl  (%eax)
  8014d8:	e8 e8 fc ff ff       	call   8011c5 <dev_lookup>
  8014dd:	83 c4 10             	add    $0x10,%esp
  8014e0:	85 c0                	test   %eax,%eax
  8014e2:	78 47                	js     80152b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014eb:	75 21                	jne    80150e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ed:	a1 08 40 80 00       	mov    0x804008,%eax
  8014f2:	8b 40 54             	mov    0x54(%eax),%eax
  8014f5:	83 ec 04             	sub    $0x4,%esp
  8014f8:	53                   	push   %ebx
  8014f9:	50                   	push   %eax
  8014fa:	68 e8 26 80 00       	push   $0x8026e8
  8014ff:	e8 4a ed ff ff       	call   80024e <cprintf>
		return -E_INVAL;
  801504:	83 c4 10             	add    $0x10,%esp
  801507:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80150c:	eb 26                	jmp    801534 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80150e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801511:	8b 52 0c             	mov    0xc(%edx),%edx
  801514:	85 d2                	test   %edx,%edx
  801516:	74 17                	je     80152f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801518:	83 ec 04             	sub    $0x4,%esp
  80151b:	ff 75 10             	pushl  0x10(%ebp)
  80151e:	ff 75 0c             	pushl  0xc(%ebp)
  801521:	50                   	push   %eax
  801522:	ff d2                	call   *%edx
  801524:	89 c2                	mov    %eax,%edx
  801526:	83 c4 10             	add    $0x10,%esp
  801529:	eb 09                	jmp    801534 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152b:	89 c2                	mov    %eax,%edx
  80152d:	eb 05                	jmp    801534 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80152f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801534:	89 d0                	mov    %edx,%eax
  801536:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801539:	c9                   	leave  
  80153a:	c3                   	ret    

0080153b <seek>:

int
seek(int fdnum, off_t offset)
{
  80153b:	55                   	push   %ebp
  80153c:	89 e5                	mov    %esp,%ebp
  80153e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801541:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801544:	50                   	push   %eax
  801545:	ff 75 08             	pushl  0x8(%ebp)
  801548:	e8 22 fc ff ff       	call   80116f <fd_lookup>
  80154d:	83 c4 08             	add    $0x8,%esp
  801550:	85 c0                	test   %eax,%eax
  801552:	78 0e                	js     801562 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801554:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801557:	8b 55 0c             	mov    0xc(%ebp),%edx
  80155a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80155d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801562:	c9                   	leave  
  801563:	c3                   	ret    

00801564 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801564:	55                   	push   %ebp
  801565:	89 e5                	mov    %esp,%ebp
  801567:	53                   	push   %ebx
  801568:	83 ec 14             	sub    $0x14,%esp
  80156b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80156e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801571:	50                   	push   %eax
  801572:	53                   	push   %ebx
  801573:	e8 f7 fb ff ff       	call   80116f <fd_lookup>
  801578:	83 c4 08             	add    $0x8,%esp
  80157b:	89 c2                	mov    %eax,%edx
  80157d:	85 c0                	test   %eax,%eax
  80157f:	78 65                	js     8015e6 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801581:	83 ec 08             	sub    $0x8,%esp
  801584:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801587:	50                   	push   %eax
  801588:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158b:	ff 30                	pushl  (%eax)
  80158d:	e8 33 fc ff ff       	call   8011c5 <dev_lookup>
  801592:	83 c4 10             	add    $0x10,%esp
  801595:	85 c0                	test   %eax,%eax
  801597:	78 44                	js     8015dd <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801599:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015a0:	75 21                	jne    8015c3 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015a2:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015a7:	8b 40 54             	mov    0x54(%eax),%eax
  8015aa:	83 ec 04             	sub    $0x4,%esp
  8015ad:	53                   	push   %ebx
  8015ae:	50                   	push   %eax
  8015af:	68 a8 26 80 00       	push   $0x8026a8
  8015b4:	e8 95 ec ff ff       	call   80024e <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015b9:	83 c4 10             	add    $0x10,%esp
  8015bc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015c1:	eb 23                	jmp    8015e6 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015c6:	8b 52 18             	mov    0x18(%edx),%edx
  8015c9:	85 d2                	test   %edx,%edx
  8015cb:	74 14                	je     8015e1 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015cd:	83 ec 08             	sub    $0x8,%esp
  8015d0:	ff 75 0c             	pushl  0xc(%ebp)
  8015d3:	50                   	push   %eax
  8015d4:	ff d2                	call   *%edx
  8015d6:	89 c2                	mov    %eax,%edx
  8015d8:	83 c4 10             	add    $0x10,%esp
  8015db:	eb 09                	jmp    8015e6 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015dd:	89 c2                	mov    %eax,%edx
  8015df:	eb 05                	jmp    8015e6 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015e1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015e6:	89 d0                	mov    %edx,%eax
  8015e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015eb:	c9                   	leave  
  8015ec:	c3                   	ret    

008015ed <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015ed:	55                   	push   %ebp
  8015ee:	89 e5                	mov    %esp,%ebp
  8015f0:	53                   	push   %ebx
  8015f1:	83 ec 14             	sub    $0x14,%esp
  8015f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015fa:	50                   	push   %eax
  8015fb:	ff 75 08             	pushl  0x8(%ebp)
  8015fe:	e8 6c fb ff ff       	call   80116f <fd_lookup>
  801603:	83 c4 08             	add    $0x8,%esp
  801606:	89 c2                	mov    %eax,%edx
  801608:	85 c0                	test   %eax,%eax
  80160a:	78 58                	js     801664 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160c:	83 ec 08             	sub    $0x8,%esp
  80160f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801612:	50                   	push   %eax
  801613:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801616:	ff 30                	pushl  (%eax)
  801618:	e8 a8 fb ff ff       	call   8011c5 <dev_lookup>
  80161d:	83 c4 10             	add    $0x10,%esp
  801620:	85 c0                	test   %eax,%eax
  801622:	78 37                	js     80165b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801624:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801627:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80162b:	74 32                	je     80165f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80162d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801630:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801637:	00 00 00 
	stat->st_isdir = 0;
  80163a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801641:	00 00 00 
	stat->st_dev = dev;
  801644:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80164a:	83 ec 08             	sub    $0x8,%esp
  80164d:	53                   	push   %ebx
  80164e:	ff 75 f0             	pushl  -0x10(%ebp)
  801651:	ff 50 14             	call   *0x14(%eax)
  801654:	89 c2                	mov    %eax,%edx
  801656:	83 c4 10             	add    $0x10,%esp
  801659:	eb 09                	jmp    801664 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165b:	89 c2                	mov    %eax,%edx
  80165d:	eb 05                	jmp    801664 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80165f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801664:	89 d0                	mov    %edx,%eax
  801666:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801669:	c9                   	leave  
  80166a:	c3                   	ret    

0080166b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80166b:	55                   	push   %ebp
  80166c:	89 e5                	mov    %esp,%ebp
  80166e:	56                   	push   %esi
  80166f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801670:	83 ec 08             	sub    $0x8,%esp
  801673:	6a 00                	push   $0x0
  801675:	ff 75 08             	pushl  0x8(%ebp)
  801678:	e8 e3 01 00 00       	call   801860 <open>
  80167d:	89 c3                	mov    %eax,%ebx
  80167f:	83 c4 10             	add    $0x10,%esp
  801682:	85 c0                	test   %eax,%eax
  801684:	78 1b                	js     8016a1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801686:	83 ec 08             	sub    $0x8,%esp
  801689:	ff 75 0c             	pushl  0xc(%ebp)
  80168c:	50                   	push   %eax
  80168d:	e8 5b ff ff ff       	call   8015ed <fstat>
  801692:	89 c6                	mov    %eax,%esi
	close(fd);
  801694:	89 1c 24             	mov    %ebx,(%esp)
  801697:	e8 fd fb ff ff       	call   801299 <close>
	return r;
  80169c:	83 c4 10             	add    $0x10,%esp
  80169f:	89 f0                	mov    %esi,%eax
}
  8016a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a4:	5b                   	pop    %ebx
  8016a5:	5e                   	pop    %esi
  8016a6:	5d                   	pop    %ebp
  8016a7:	c3                   	ret    

008016a8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016a8:	55                   	push   %ebp
  8016a9:	89 e5                	mov    %esp,%ebp
  8016ab:	56                   	push   %esi
  8016ac:	53                   	push   %ebx
  8016ad:	89 c6                	mov    %eax,%esi
  8016af:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016b1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016b8:	75 12                	jne    8016cc <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016ba:	83 ec 0c             	sub    $0xc,%esp
  8016bd:	6a 01                	push   $0x1
  8016bf:	e8 88 08 00 00       	call   801f4c <ipc_find_env>
  8016c4:	a3 00 40 80 00       	mov    %eax,0x804000
  8016c9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016cc:	6a 07                	push   $0x7
  8016ce:	68 00 50 80 00       	push   $0x805000
  8016d3:	56                   	push   %esi
  8016d4:	ff 35 00 40 80 00    	pushl  0x804000
  8016da:	e8 0b 08 00 00       	call   801eea <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016df:	83 c4 0c             	add    $0xc,%esp
  8016e2:	6a 00                	push   $0x0
  8016e4:	53                   	push   %ebx
  8016e5:	6a 00                	push   $0x0
  8016e7:	e8 86 07 00 00       	call   801e72 <ipc_recv>
}
  8016ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ef:	5b                   	pop    %ebx
  8016f0:	5e                   	pop    %esi
  8016f1:	5d                   	pop    %ebp
  8016f2:	c3                   	ret    

008016f3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016f3:	55                   	push   %ebp
  8016f4:	89 e5                	mov    %esp,%ebp
  8016f6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fc:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ff:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801704:	8b 45 0c             	mov    0xc(%ebp),%eax
  801707:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80170c:	ba 00 00 00 00       	mov    $0x0,%edx
  801711:	b8 02 00 00 00       	mov    $0x2,%eax
  801716:	e8 8d ff ff ff       	call   8016a8 <fsipc>
}
  80171b:	c9                   	leave  
  80171c:	c3                   	ret    

0080171d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801723:	8b 45 08             	mov    0x8(%ebp),%eax
  801726:	8b 40 0c             	mov    0xc(%eax),%eax
  801729:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80172e:	ba 00 00 00 00       	mov    $0x0,%edx
  801733:	b8 06 00 00 00       	mov    $0x6,%eax
  801738:	e8 6b ff ff ff       	call   8016a8 <fsipc>
}
  80173d:	c9                   	leave  
  80173e:	c3                   	ret    

0080173f <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80173f:	55                   	push   %ebp
  801740:	89 e5                	mov    %esp,%ebp
  801742:	53                   	push   %ebx
  801743:	83 ec 04             	sub    $0x4,%esp
  801746:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801749:	8b 45 08             	mov    0x8(%ebp),%eax
  80174c:	8b 40 0c             	mov    0xc(%eax),%eax
  80174f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801754:	ba 00 00 00 00       	mov    $0x0,%edx
  801759:	b8 05 00 00 00       	mov    $0x5,%eax
  80175e:	e8 45 ff ff ff       	call   8016a8 <fsipc>
  801763:	85 c0                	test   %eax,%eax
  801765:	78 2c                	js     801793 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801767:	83 ec 08             	sub    $0x8,%esp
  80176a:	68 00 50 80 00       	push   $0x805000
  80176f:	53                   	push   %ebx
  801770:	e8 5e f0 ff ff       	call   8007d3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801775:	a1 80 50 80 00       	mov    0x805080,%eax
  80177a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801780:	a1 84 50 80 00       	mov    0x805084,%eax
  801785:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80178b:	83 c4 10             	add    $0x10,%esp
  80178e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801793:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801796:	c9                   	leave  
  801797:	c3                   	ret    

00801798 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801798:	55                   	push   %ebp
  801799:	89 e5                	mov    %esp,%ebp
  80179b:	83 ec 0c             	sub    $0xc,%esp
  80179e:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8017a4:	8b 52 0c             	mov    0xc(%edx),%edx
  8017a7:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8017ad:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017b2:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017b7:	0f 47 c2             	cmova  %edx,%eax
  8017ba:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8017bf:	50                   	push   %eax
  8017c0:	ff 75 0c             	pushl  0xc(%ebp)
  8017c3:	68 08 50 80 00       	push   $0x805008
  8017c8:	e8 98 f1 ff ff       	call   800965 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8017cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d2:	b8 04 00 00 00       	mov    $0x4,%eax
  8017d7:	e8 cc fe ff ff       	call   8016a8 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8017dc:	c9                   	leave  
  8017dd:	c3                   	ret    

008017de <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	56                   	push   %esi
  8017e2:	53                   	push   %ebx
  8017e3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e9:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ec:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017f1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017fc:	b8 03 00 00 00       	mov    $0x3,%eax
  801801:	e8 a2 fe ff ff       	call   8016a8 <fsipc>
  801806:	89 c3                	mov    %eax,%ebx
  801808:	85 c0                	test   %eax,%eax
  80180a:	78 4b                	js     801857 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80180c:	39 c6                	cmp    %eax,%esi
  80180e:	73 16                	jae    801826 <devfile_read+0x48>
  801810:	68 18 27 80 00       	push   $0x802718
  801815:	68 1f 27 80 00       	push   $0x80271f
  80181a:	6a 7c                	push   $0x7c
  80181c:	68 34 27 80 00       	push   $0x802734
  801821:	e8 4f e9 ff ff       	call   800175 <_panic>
	assert(r <= PGSIZE);
  801826:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80182b:	7e 16                	jle    801843 <devfile_read+0x65>
  80182d:	68 3f 27 80 00       	push   $0x80273f
  801832:	68 1f 27 80 00       	push   $0x80271f
  801837:	6a 7d                	push   $0x7d
  801839:	68 34 27 80 00       	push   $0x802734
  80183e:	e8 32 e9 ff ff       	call   800175 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801843:	83 ec 04             	sub    $0x4,%esp
  801846:	50                   	push   %eax
  801847:	68 00 50 80 00       	push   $0x805000
  80184c:	ff 75 0c             	pushl  0xc(%ebp)
  80184f:	e8 11 f1 ff ff       	call   800965 <memmove>
	return r;
  801854:	83 c4 10             	add    $0x10,%esp
}
  801857:	89 d8                	mov    %ebx,%eax
  801859:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80185c:	5b                   	pop    %ebx
  80185d:	5e                   	pop    %esi
  80185e:	5d                   	pop    %ebp
  80185f:	c3                   	ret    

00801860 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801860:	55                   	push   %ebp
  801861:	89 e5                	mov    %esp,%ebp
  801863:	53                   	push   %ebx
  801864:	83 ec 20             	sub    $0x20,%esp
  801867:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80186a:	53                   	push   %ebx
  80186b:	e8 2a ef ff ff       	call   80079a <strlen>
  801870:	83 c4 10             	add    $0x10,%esp
  801873:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801878:	7f 67                	jg     8018e1 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80187a:	83 ec 0c             	sub    $0xc,%esp
  80187d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801880:	50                   	push   %eax
  801881:	e8 9a f8 ff ff       	call   801120 <fd_alloc>
  801886:	83 c4 10             	add    $0x10,%esp
		return r;
  801889:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80188b:	85 c0                	test   %eax,%eax
  80188d:	78 57                	js     8018e6 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80188f:	83 ec 08             	sub    $0x8,%esp
  801892:	53                   	push   %ebx
  801893:	68 00 50 80 00       	push   $0x805000
  801898:	e8 36 ef ff ff       	call   8007d3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80189d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a0:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018a8:	b8 01 00 00 00       	mov    $0x1,%eax
  8018ad:	e8 f6 fd ff ff       	call   8016a8 <fsipc>
  8018b2:	89 c3                	mov    %eax,%ebx
  8018b4:	83 c4 10             	add    $0x10,%esp
  8018b7:	85 c0                	test   %eax,%eax
  8018b9:	79 14                	jns    8018cf <open+0x6f>
		fd_close(fd, 0);
  8018bb:	83 ec 08             	sub    $0x8,%esp
  8018be:	6a 00                	push   $0x0
  8018c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c3:	e8 50 f9 ff ff       	call   801218 <fd_close>
		return r;
  8018c8:	83 c4 10             	add    $0x10,%esp
  8018cb:	89 da                	mov    %ebx,%edx
  8018cd:	eb 17                	jmp    8018e6 <open+0x86>
	}

	return fd2num(fd);
  8018cf:	83 ec 0c             	sub    $0xc,%esp
  8018d2:	ff 75 f4             	pushl  -0xc(%ebp)
  8018d5:	e8 1f f8 ff ff       	call   8010f9 <fd2num>
  8018da:	89 c2                	mov    %eax,%edx
  8018dc:	83 c4 10             	add    $0x10,%esp
  8018df:	eb 05                	jmp    8018e6 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018e1:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018e6:	89 d0                	mov    %edx,%eax
  8018e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018eb:	c9                   	leave  
  8018ec:	c3                   	ret    

008018ed <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018ed:	55                   	push   %ebp
  8018ee:	89 e5                	mov    %esp,%ebp
  8018f0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f8:	b8 08 00 00 00       	mov    $0x8,%eax
  8018fd:	e8 a6 fd ff ff       	call   8016a8 <fsipc>
}
  801902:	c9                   	leave  
  801903:	c3                   	ret    

00801904 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801904:	55                   	push   %ebp
  801905:	89 e5                	mov    %esp,%ebp
  801907:	56                   	push   %esi
  801908:	53                   	push   %ebx
  801909:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80190c:	83 ec 0c             	sub    $0xc,%esp
  80190f:	ff 75 08             	pushl  0x8(%ebp)
  801912:	e8 f2 f7 ff ff       	call   801109 <fd2data>
  801917:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801919:	83 c4 08             	add    $0x8,%esp
  80191c:	68 4b 27 80 00       	push   $0x80274b
  801921:	53                   	push   %ebx
  801922:	e8 ac ee ff ff       	call   8007d3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801927:	8b 46 04             	mov    0x4(%esi),%eax
  80192a:	2b 06                	sub    (%esi),%eax
  80192c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801932:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801939:	00 00 00 
	stat->st_dev = &devpipe;
  80193c:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801943:	30 80 00 
	return 0;
}
  801946:	b8 00 00 00 00       	mov    $0x0,%eax
  80194b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80194e:	5b                   	pop    %ebx
  80194f:	5e                   	pop    %esi
  801950:	5d                   	pop    %ebp
  801951:	c3                   	ret    

00801952 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801952:	55                   	push   %ebp
  801953:	89 e5                	mov    %esp,%ebp
  801955:	53                   	push   %ebx
  801956:	83 ec 0c             	sub    $0xc,%esp
  801959:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80195c:	53                   	push   %ebx
  80195d:	6a 00                	push   $0x0
  80195f:	e8 f7 f2 ff ff       	call   800c5b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801964:	89 1c 24             	mov    %ebx,(%esp)
  801967:	e8 9d f7 ff ff       	call   801109 <fd2data>
  80196c:	83 c4 08             	add    $0x8,%esp
  80196f:	50                   	push   %eax
  801970:	6a 00                	push   $0x0
  801972:	e8 e4 f2 ff ff       	call   800c5b <sys_page_unmap>
}
  801977:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80197a:	c9                   	leave  
  80197b:	c3                   	ret    

0080197c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80197c:	55                   	push   %ebp
  80197d:	89 e5                	mov    %esp,%ebp
  80197f:	57                   	push   %edi
  801980:	56                   	push   %esi
  801981:	53                   	push   %ebx
  801982:	83 ec 1c             	sub    $0x1c,%esp
  801985:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801988:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80198a:	a1 08 40 80 00       	mov    0x804008,%eax
  80198f:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801992:	83 ec 0c             	sub    $0xc,%esp
  801995:	ff 75 e0             	pushl  -0x20(%ebp)
  801998:	e8 ef 05 00 00       	call   801f8c <pageref>
  80199d:	89 c3                	mov    %eax,%ebx
  80199f:	89 3c 24             	mov    %edi,(%esp)
  8019a2:	e8 e5 05 00 00       	call   801f8c <pageref>
  8019a7:	83 c4 10             	add    $0x10,%esp
  8019aa:	39 c3                	cmp    %eax,%ebx
  8019ac:	0f 94 c1             	sete   %cl
  8019af:	0f b6 c9             	movzbl %cl,%ecx
  8019b2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019b5:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8019bb:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  8019be:	39 ce                	cmp    %ecx,%esi
  8019c0:	74 1b                	je     8019dd <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8019c2:	39 c3                	cmp    %eax,%ebx
  8019c4:	75 c4                	jne    80198a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019c6:	8b 42 64             	mov    0x64(%edx),%eax
  8019c9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019cc:	50                   	push   %eax
  8019cd:	56                   	push   %esi
  8019ce:	68 52 27 80 00       	push   $0x802752
  8019d3:	e8 76 e8 ff ff       	call   80024e <cprintf>
  8019d8:	83 c4 10             	add    $0x10,%esp
  8019db:	eb ad                	jmp    80198a <_pipeisclosed+0xe>
	}
}
  8019dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019e3:	5b                   	pop    %ebx
  8019e4:	5e                   	pop    %esi
  8019e5:	5f                   	pop    %edi
  8019e6:	5d                   	pop    %ebp
  8019e7:	c3                   	ret    

008019e8 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019e8:	55                   	push   %ebp
  8019e9:	89 e5                	mov    %esp,%ebp
  8019eb:	57                   	push   %edi
  8019ec:	56                   	push   %esi
  8019ed:	53                   	push   %ebx
  8019ee:	83 ec 28             	sub    $0x28,%esp
  8019f1:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019f4:	56                   	push   %esi
  8019f5:	e8 0f f7 ff ff       	call   801109 <fd2data>
  8019fa:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019fc:	83 c4 10             	add    $0x10,%esp
  8019ff:	bf 00 00 00 00       	mov    $0x0,%edi
  801a04:	eb 4b                	jmp    801a51 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a06:	89 da                	mov    %ebx,%edx
  801a08:	89 f0                	mov    %esi,%eax
  801a0a:	e8 6d ff ff ff       	call   80197c <_pipeisclosed>
  801a0f:	85 c0                	test   %eax,%eax
  801a11:	75 48                	jne    801a5b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a13:	e8 9f f1 ff ff       	call   800bb7 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a18:	8b 43 04             	mov    0x4(%ebx),%eax
  801a1b:	8b 0b                	mov    (%ebx),%ecx
  801a1d:	8d 51 20             	lea    0x20(%ecx),%edx
  801a20:	39 d0                	cmp    %edx,%eax
  801a22:	73 e2                	jae    801a06 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a27:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a2b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a2e:	89 c2                	mov    %eax,%edx
  801a30:	c1 fa 1f             	sar    $0x1f,%edx
  801a33:	89 d1                	mov    %edx,%ecx
  801a35:	c1 e9 1b             	shr    $0x1b,%ecx
  801a38:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a3b:	83 e2 1f             	and    $0x1f,%edx
  801a3e:	29 ca                	sub    %ecx,%edx
  801a40:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a44:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a48:	83 c0 01             	add    $0x1,%eax
  801a4b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a4e:	83 c7 01             	add    $0x1,%edi
  801a51:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a54:	75 c2                	jne    801a18 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a56:	8b 45 10             	mov    0x10(%ebp),%eax
  801a59:	eb 05                	jmp    801a60 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a5b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a63:	5b                   	pop    %ebx
  801a64:	5e                   	pop    %esi
  801a65:	5f                   	pop    %edi
  801a66:	5d                   	pop    %ebp
  801a67:	c3                   	ret    

00801a68 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a68:	55                   	push   %ebp
  801a69:	89 e5                	mov    %esp,%ebp
  801a6b:	57                   	push   %edi
  801a6c:	56                   	push   %esi
  801a6d:	53                   	push   %ebx
  801a6e:	83 ec 18             	sub    $0x18,%esp
  801a71:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a74:	57                   	push   %edi
  801a75:	e8 8f f6 ff ff       	call   801109 <fd2data>
  801a7a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a7c:	83 c4 10             	add    $0x10,%esp
  801a7f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a84:	eb 3d                	jmp    801ac3 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a86:	85 db                	test   %ebx,%ebx
  801a88:	74 04                	je     801a8e <devpipe_read+0x26>
				return i;
  801a8a:	89 d8                	mov    %ebx,%eax
  801a8c:	eb 44                	jmp    801ad2 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a8e:	89 f2                	mov    %esi,%edx
  801a90:	89 f8                	mov    %edi,%eax
  801a92:	e8 e5 fe ff ff       	call   80197c <_pipeisclosed>
  801a97:	85 c0                	test   %eax,%eax
  801a99:	75 32                	jne    801acd <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a9b:	e8 17 f1 ff ff       	call   800bb7 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801aa0:	8b 06                	mov    (%esi),%eax
  801aa2:	3b 46 04             	cmp    0x4(%esi),%eax
  801aa5:	74 df                	je     801a86 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801aa7:	99                   	cltd   
  801aa8:	c1 ea 1b             	shr    $0x1b,%edx
  801aab:	01 d0                	add    %edx,%eax
  801aad:	83 e0 1f             	and    $0x1f,%eax
  801ab0:	29 d0                	sub    %edx,%eax
  801ab2:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ab7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aba:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801abd:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac0:	83 c3 01             	add    $0x1,%ebx
  801ac3:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ac6:	75 d8                	jne    801aa0 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ac8:	8b 45 10             	mov    0x10(%ebp),%eax
  801acb:	eb 05                	jmp    801ad2 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801acd:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ad2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad5:	5b                   	pop    %ebx
  801ad6:	5e                   	pop    %esi
  801ad7:	5f                   	pop    %edi
  801ad8:	5d                   	pop    %ebp
  801ad9:	c3                   	ret    

00801ada <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	56                   	push   %esi
  801ade:	53                   	push   %ebx
  801adf:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ae2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ae5:	50                   	push   %eax
  801ae6:	e8 35 f6 ff ff       	call   801120 <fd_alloc>
  801aeb:	83 c4 10             	add    $0x10,%esp
  801aee:	89 c2                	mov    %eax,%edx
  801af0:	85 c0                	test   %eax,%eax
  801af2:	0f 88 2c 01 00 00    	js     801c24 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801af8:	83 ec 04             	sub    $0x4,%esp
  801afb:	68 07 04 00 00       	push   $0x407
  801b00:	ff 75 f4             	pushl  -0xc(%ebp)
  801b03:	6a 00                	push   $0x0
  801b05:	e8 cc f0 ff ff       	call   800bd6 <sys_page_alloc>
  801b0a:	83 c4 10             	add    $0x10,%esp
  801b0d:	89 c2                	mov    %eax,%edx
  801b0f:	85 c0                	test   %eax,%eax
  801b11:	0f 88 0d 01 00 00    	js     801c24 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b17:	83 ec 0c             	sub    $0xc,%esp
  801b1a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b1d:	50                   	push   %eax
  801b1e:	e8 fd f5 ff ff       	call   801120 <fd_alloc>
  801b23:	89 c3                	mov    %eax,%ebx
  801b25:	83 c4 10             	add    $0x10,%esp
  801b28:	85 c0                	test   %eax,%eax
  801b2a:	0f 88 e2 00 00 00    	js     801c12 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b30:	83 ec 04             	sub    $0x4,%esp
  801b33:	68 07 04 00 00       	push   $0x407
  801b38:	ff 75 f0             	pushl  -0x10(%ebp)
  801b3b:	6a 00                	push   $0x0
  801b3d:	e8 94 f0 ff ff       	call   800bd6 <sys_page_alloc>
  801b42:	89 c3                	mov    %eax,%ebx
  801b44:	83 c4 10             	add    $0x10,%esp
  801b47:	85 c0                	test   %eax,%eax
  801b49:	0f 88 c3 00 00 00    	js     801c12 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b4f:	83 ec 0c             	sub    $0xc,%esp
  801b52:	ff 75 f4             	pushl  -0xc(%ebp)
  801b55:	e8 af f5 ff ff       	call   801109 <fd2data>
  801b5a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b5c:	83 c4 0c             	add    $0xc,%esp
  801b5f:	68 07 04 00 00       	push   $0x407
  801b64:	50                   	push   %eax
  801b65:	6a 00                	push   $0x0
  801b67:	e8 6a f0 ff ff       	call   800bd6 <sys_page_alloc>
  801b6c:	89 c3                	mov    %eax,%ebx
  801b6e:	83 c4 10             	add    $0x10,%esp
  801b71:	85 c0                	test   %eax,%eax
  801b73:	0f 88 89 00 00 00    	js     801c02 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b79:	83 ec 0c             	sub    $0xc,%esp
  801b7c:	ff 75 f0             	pushl  -0x10(%ebp)
  801b7f:	e8 85 f5 ff ff       	call   801109 <fd2data>
  801b84:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b8b:	50                   	push   %eax
  801b8c:	6a 00                	push   $0x0
  801b8e:	56                   	push   %esi
  801b8f:	6a 00                	push   $0x0
  801b91:	e8 83 f0 ff ff       	call   800c19 <sys_page_map>
  801b96:	89 c3                	mov    %eax,%ebx
  801b98:	83 c4 20             	add    $0x20,%esp
  801b9b:	85 c0                	test   %eax,%eax
  801b9d:	78 55                	js     801bf4 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b9f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bad:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bb4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bbd:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801bbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bc2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801bc9:	83 ec 0c             	sub    $0xc,%esp
  801bcc:	ff 75 f4             	pushl  -0xc(%ebp)
  801bcf:	e8 25 f5 ff ff       	call   8010f9 <fd2num>
  801bd4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bd7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bd9:	83 c4 04             	add    $0x4,%esp
  801bdc:	ff 75 f0             	pushl  -0x10(%ebp)
  801bdf:	e8 15 f5 ff ff       	call   8010f9 <fd2num>
  801be4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801be7:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801bea:	83 c4 10             	add    $0x10,%esp
  801bed:	ba 00 00 00 00       	mov    $0x0,%edx
  801bf2:	eb 30                	jmp    801c24 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801bf4:	83 ec 08             	sub    $0x8,%esp
  801bf7:	56                   	push   %esi
  801bf8:	6a 00                	push   $0x0
  801bfa:	e8 5c f0 ff ff       	call   800c5b <sys_page_unmap>
  801bff:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c02:	83 ec 08             	sub    $0x8,%esp
  801c05:	ff 75 f0             	pushl  -0x10(%ebp)
  801c08:	6a 00                	push   $0x0
  801c0a:	e8 4c f0 ff ff       	call   800c5b <sys_page_unmap>
  801c0f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c12:	83 ec 08             	sub    $0x8,%esp
  801c15:	ff 75 f4             	pushl  -0xc(%ebp)
  801c18:	6a 00                	push   $0x0
  801c1a:	e8 3c f0 ff ff       	call   800c5b <sys_page_unmap>
  801c1f:	83 c4 10             	add    $0x10,%esp
  801c22:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c24:	89 d0                	mov    %edx,%eax
  801c26:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c29:	5b                   	pop    %ebx
  801c2a:	5e                   	pop    %esi
  801c2b:	5d                   	pop    %ebp
  801c2c:	c3                   	ret    

00801c2d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c2d:	55                   	push   %ebp
  801c2e:	89 e5                	mov    %esp,%ebp
  801c30:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c33:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c36:	50                   	push   %eax
  801c37:	ff 75 08             	pushl  0x8(%ebp)
  801c3a:	e8 30 f5 ff ff       	call   80116f <fd_lookup>
  801c3f:	83 c4 10             	add    $0x10,%esp
  801c42:	85 c0                	test   %eax,%eax
  801c44:	78 18                	js     801c5e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c46:	83 ec 0c             	sub    $0xc,%esp
  801c49:	ff 75 f4             	pushl  -0xc(%ebp)
  801c4c:	e8 b8 f4 ff ff       	call   801109 <fd2data>
	return _pipeisclosed(fd, p);
  801c51:	89 c2                	mov    %eax,%edx
  801c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c56:	e8 21 fd ff ff       	call   80197c <_pipeisclosed>
  801c5b:	83 c4 10             	add    $0x10,%esp
}
  801c5e:	c9                   	leave  
  801c5f:	c3                   	ret    

00801c60 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c60:	55                   	push   %ebp
  801c61:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c63:	b8 00 00 00 00       	mov    $0x0,%eax
  801c68:	5d                   	pop    %ebp
  801c69:	c3                   	ret    

00801c6a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c6a:	55                   	push   %ebp
  801c6b:	89 e5                	mov    %esp,%ebp
  801c6d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c70:	68 6a 27 80 00       	push   $0x80276a
  801c75:	ff 75 0c             	pushl  0xc(%ebp)
  801c78:	e8 56 eb ff ff       	call   8007d3 <strcpy>
	return 0;
}
  801c7d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c82:	c9                   	leave  
  801c83:	c3                   	ret    

00801c84 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c84:	55                   	push   %ebp
  801c85:	89 e5                	mov    %esp,%ebp
  801c87:	57                   	push   %edi
  801c88:	56                   	push   %esi
  801c89:	53                   	push   %ebx
  801c8a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c90:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c95:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c9b:	eb 2d                	jmp    801cca <devcons_write+0x46>
		m = n - tot;
  801c9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ca0:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ca2:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ca5:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801caa:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cad:	83 ec 04             	sub    $0x4,%esp
  801cb0:	53                   	push   %ebx
  801cb1:	03 45 0c             	add    0xc(%ebp),%eax
  801cb4:	50                   	push   %eax
  801cb5:	57                   	push   %edi
  801cb6:	e8 aa ec ff ff       	call   800965 <memmove>
		sys_cputs(buf, m);
  801cbb:	83 c4 08             	add    $0x8,%esp
  801cbe:	53                   	push   %ebx
  801cbf:	57                   	push   %edi
  801cc0:	e8 55 ee ff ff       	call   800b1a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cc5:	01 de                	add    %ebx,%esi
  801cc7:	83 c4 10             	add    $0x10,%esp
  801cca:	89 f0                	mov    %esi,%eax
  801ccc:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ccf:	72 cc                	jb     801c9d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801cd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cd4:	5b                   	pop    %ebx
  801cd5:	5e                   	pop    %esi
  801cd6:	5f                   	pop    %edi
  801cd7:	5d                   	pop    %ebp
  801cd8:	c3                   	ret    

00801cd9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cd9:	55                   	push   %ebp
  801cda:	89 e5                	mov    %esp,%ebp
  801cdc:	83 ec 08             	sub    $0x8,%esp
  801cdf:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ce4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ce8:	74 2a                	je     801d14 <devcons_read+0x3b>
  801cea:	eb 05                	jmp    801cf1 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801cec:	e8 c6 ee ff ff       	call   800bb7 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801cf1:	e8 42 ee ff ff       	call   800b38 <sys_cgetc>
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	74 f2                	je     801cec <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801cfa:	85 c0                	test   %eax,%eax
  801cfc:	78 16                	js     801d14 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801cfe:	83 f8 04             	cmp    $0x4,%eax
  801d01:	74 0c                	je     801d0f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d03:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d06:	88 02                	mov    %al,(%edx)
	return 1;
  801d08:	b8 01 00 00 00       	mov    $0x1,%eax
  801d0d:	eb 05                	jmp    801d14 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d0f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d14:	c9                   	leave  
  801d15:	c3                   	ret    

00801d16 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d16:	55                   	push   %ebp
  801d17:	89 e5                	mov    %esp,%ebp
  801d19:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d22:	6a 01                	push   $0x1
  801d24:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d27:	50                   	push   %eax
  801d28:	e8 ed ed ff ff       	call   800b1a <sys_cputs>
}
  801d2d:	83 c4 10             	add    $0x10,%esp
  801d30:	c9                   	leave  
  801d31:	c3                   	ret    

00801d32 <getchar>:

int
getchar(void)
{
  801d32:	55                   	push   %ebp
  801d33:	89 e5                	mov    %esp,%ebp
  801d35:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d38:	6a 01                	push   $0x1
  801d3a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d3d:	50                   	push   %eax
  801d3e:	6a 00                	push   $0x0
  801d40:	e8 90 f6 ff ff       	call   8013d5 <read>
	if (r < 0)
  801d45:	83 c4 10             	add    $0x10,%esp
  801d48:	85 c0                	test   %eax,%eax
  801d4a:	78 0f                	js     801d5b <getchar+0x29>
		return r;
	if (r < 1)
  801d4c:	85 c0                	test   %eax,%eax
  801d4e:	7e 06                	jle    801d56 <getchar+0x24>
		return -E_EOF;
	return c;
  801d50:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d54:	eb 05                	jmp    801d5b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d56:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d5b:	c9                   	leave  
  801d5c:	c3                   	ret    

00801d5d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d5d:	55                   	push   %ebp
  801d5e:	89 e5                	mov    %esp,%ebp
  801d60:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d63:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d66:	50                   	push   %eax
  801d67:	ff 75 08             	pushl  0x8(%ebp)
  801d6a:	e8 00 f4 ff ff       	call   80116f <fd_lookup>
  801d6f:	83 c4 10             	add    $0x10,%esp
  801d72:	85 c0                	test   %eax,%eax
  801d74:	78 11                	js     801d87 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d79:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d7f:	39 10                	cmp    %edx,(%eax)
  801d81:	0f 94 c0             	sete   %al
  801d84:	0f b6 c0             	movzbl %al,%eax
}
  801d87:	c9                   	leave  
  801d88:	c3                   	ret    

00801d89 <opencons>:

int
opencons(void)
{
  801d89:	55                   	push   %ebp
  801d8a:	89 e5                	mov    %esp,%ebp
  801d8c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d92:	50                   	push   %eax
  801d93:	e8 88 f3 ff ff       	call   801120 <fd_alloc>
  801d98:	83 c4 10             	add    $0x10,%esp
		return r;
  801d9b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d9d:	85 c0                	test   %eax,%eax
  801d9f:	78 3e                	js     801ddf <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801da1:	83 ec 04             	sub    $0x4,%esp
  801da4:	68 07 04 00 00       	push   $0x407
  801da9:	ff 75 f4             	pushl  -0xc(%ebp)
  801dac:	6a 00                	push   $0x0
  801dae:	e8 23 ee ff ff       	call   800bd6 <sys_page_alloc>
  801db3:	83 c4 10             	add    $0x10,%esp
		return r;
  801db6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801db8:	85 c0                	test   %eax,%eax
  801dba:	78 23                	js     801ddf <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801dbc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801dc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dca:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801dd1:	83 ec 0c             	sub    $0xc,%esp
  801dd4:	50                   	push   %eax
  801dd5:	e8 1f f3 ff ff       	call   8010f9 <fd2num>
  801dda:	89 c2                	mov    %eax,%edx
  801ddc:	83 c4 10             	add    $0x10,%esp
}
  801ddf:	89 d0                	mov    %edx,%eax
  801de1:	c9                   	leave  
  801de2:	c3                   	ret    

00801de3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801de3:	55                   	push   %ebp
  801de4:	89 e5                	mov    %esp,%ebp
  801de6:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801de9:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801df0:	75 2a                	jne    801e1c <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801df2:	83 ec 04             	sub    $0x4,%esp
  801df5:	6a 07                	push   $0x7
  801df7:	68 00 f0 bf ee       	push   $0xeebff000
  801dfc:	6a 00                	push   $0x0
  801dfe:	e8 d3 ed ff ff       	call   800bd6 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801e03:	83 c4 10             	add    $0x10,%esp
  801e06:	85 c0                	test   %eax,%eax
  801e08:	79 12                	jns    801e1c <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801e0a:	50                   	push   %eax
  801e0b:	68 76 27 80 00       	push   $0x802776
  801e10:	6a 23                	push   $0x23
  801e12:	68 7a 27 80 00       	push   $0x80277a
  801e17:	e8 59 e3 ff ff       	call   800175 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1f:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801e24:	83 ec 08             	sub    $0x8,%esp
  801e27:	68 4e 1e 80 00       	push   $0x801e4e
  801e2c:	6a 00                	push   $0x0
  801e2e:	e8 ee ee ff ff       	call   800d21 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801e33:	83 c4 10             	add    $0x10,%esp
  801e36:	85 c0                	test   %eax,%eax
  801e38:	79 12                	jns    801e4c <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801e3a:	50                   	push   %eax
  801e3b:	68 76 27 80 00       	push   $0x802776
  801e40:	6a 2c                	push   $0x2c
  801e42:	68 7a 27 80 00       	push   $0x80277a
  801e47:	e8 29 e3 ff ff       	call   800175 <_panic>
	}
}
  801e4c:	c9                   	leave  
  801e4d:	c3                   	ret    

00801e4e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e4e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e4f:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e54:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e56:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801e59:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801e5d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801e62:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801e66:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801e68:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801e6b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801e6c:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801e6f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801e70:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e71:	c3                   	ret    

00801e72 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e72:	55                   	push   %ebp
  801e73:	89 e5                	mov    %esp,%ebp
  801e75:	56                   	push   %esi
  801e76:	53                   	push   %ebx
  801e77:	8b 75 08             	mov    0x8(%ebp),%esi
  801e7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e80:	85 c0                	test   %eax,%eax
  801e82:	75 12                	jne    801e96 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e84:	83 ec 0c             	sub    $0xc,%esp
  801e87:	68 00 00 c0 ee       	push   $0xeec00000
  801e8c:	e8 f5 ee ff ff       	call   800d86 <sys_ipc_recv>
  801e91:	83 c4 10             	add    $0x10,%esp
  801e94:	eb 0c                	jmp    801ea2 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e96:	83 ec 0c             	sub    $0xc,%esp
  801e99:	50                   	push   %eax
  801e9a:	e8 e7 ee ff ff       	call   800d86 <sys_ipc_recv>
  801e9f:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801ea2:	85 f6                	test   %esi,%esi
  801ea4:	0f 95 c1             	setne  %cl
  801ea7:	85 db                	test   %ebx,%ebx
  801ea9:	0f 95 c2             	setne  %dl
  801eac:	84 d1                	test   %dl,%cl
  801eae:	74 09                	je     801eb9 <ipc_recv+0x47>
  801eb0:	89 c2                	mov    %eax,%edx
  801eb2:	c1 ea 1f             	shr    $0x1f,%edx
  801eb5:	84 d2                	test   %dl,%dl
  801eb7:	75 2a                	jne    801ee3 <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801eb9:	85 f6                	test   %esi,%esi
  801ebb:	74 0d                	je     801eca <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801ebd:	a1 08 40 80 00       	mov    0x804008,%eax
  801ec2:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801ec8:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801eca:	85 db                	test   %ebx,%ebx
  801ecc:	74 0d                	je     801edb <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801ece:	a1 08 40 80 00       	mov    0x804008,%eax
  801ed3:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  801ed9:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801edb:	a1 08 40 80 00       	mov    0x804008,%eax
  801ee0:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  801ee3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ee6:	5b                   	pop    %ebx
  801ee7:	5e                   	pop    %esi
  801ee8:	5d                   	pop    %ebp
  801ee9:	c3                   	ret    

00801eea <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801eea:	55                   	push   %ebp
  801eeb:	89 e5                	mov    %esp,%ebp
  801eed:	57                   	push   %edi
  801eee:	56                   	push   %esi
  801eef:	53                   	push   %ebx
  801ef0:	83 ec 0c             	sub    $0xc,%esp
  801ef3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ef6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ef9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801efc:	85 db                	test   %ebx,%ebx
  801efe:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f03:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801f06:	ff 75 14             	pushl  0x14(%ebp)
  801f09:	53                   	push   %ebx
  801f0a:	56                   	push   %esi
  801f0b:	57                   	push   %edi
  801f0c:	e8 52 ee ff ff       	call   800d63 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801f11:	89 c2                	mov    %eax,%edx
  801f13:	c1 ea 1f             	shr    $0x1f,%edx
  801f16:	83 c4 10             	add    $0x10,%esp
  801f19:	84 d2                	test   %dl,%dl
  801f1b:	74 17                	je     801f34 <ipc_send+0x4a>
  801f1d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f20:	74 12                	je     801f34 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801f22:	50                   	push   %eax
  801f23:	68 88 27 80 00       	push   $0x802788
  801f28:	6a 47                	push   $0x47
  801f2a:	68 96 27 80 00       	push   $0x802796
  801f2f:	e8 41 e2 ff ff       	call   800175 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801f34:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f37:	75 07                	jne    801f40 <ipc_send+0x56>
			sys_yield();
  801f39:	e8 79 ec ff ff       	call   800bb7 <sys_yield>
  801f3e:	eb c6                	jmp    801f06 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801f40:	85 c0                	test   %eax,%eax
  801f42:	75 c2                	jne    801f06 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801f44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f47:	5b                   	pop    %ebx
  801f48:	5e                   	pop    %esi
  801f49:	5f                   	pop    %edi
  801f4a:	5d                   	pop    %ebp
  801f4b:	c3                   	ret    

00801f4c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f4c:	55                   	push   %ebp
  801f4d:	89 e5                	mov    %esp,%ebp
  801f4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f52:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f57:	89 c2                	mov    %eax,%edx
  801f59:	c1 e2 07             	shl    $0x7,%edx
  801f5c:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  801f63:	8b 52 5c             	mov    0x5c(%edx),%edx
  801f66:	39 ca                	cmp    %ecx,%edx
  801f68:	75 11                	jne    801f7b <ipc_find_env+0x2f>
			return envs[i].env_id;
  801f6a:	89 c2                	mov    %eax,%edx
  801f6c:	c1 e2 07             	shl    $0x7,%edx
  801f6f:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801f76:	8b 40 54             	mov    0x54(%eax),%eax
  801f79:	eb 0f                	jmp    801f8a <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f7b:	83 c0 01             	add    $0x1,%eax
  801f7e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f83:	75 d2                	jne    801f57 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f85:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f8a:	5d                   	pop    %ebp
  801f8b:	c3                   	ret    

00801f8c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f8c:	55                   	push   %ebp
  801f8d:	89 e5                	mov    %esp,%ebp
  801f8f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f92:	89 d0                	mov    %edx,%eax
  801f94:	c1 e8 16             	shr    $0x16,%eax
  801f97:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f9e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa3:	f6 c1 01             	test   $0x1,%cl
  801fa6:	74 1d                	je     801fc5 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fa8:	c1 ea 0c             	shr    $0xc,%edx
  801fab:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fb2:	f6 c2 01             	test   $0x1,%dl
  801fb5:	74 0e                	je     801fc5 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fb7:	c1 ea 0c             	shr    $0xc,%edx
  801fba:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fc1:	ef 
  801fc2:	0f b7 c0             	movzwl %ax,%eax
}
  801fc5:	5d                   	pop    %ebp
  801fc6:	c3                   	ret    
  801fc7:	66 90                	xchg   %ax,%ax
  801fc9:	66 90                	xchg   %ax,%ax
  801fcb:	66 90                	xchg   %ax,%ax
  801fcd:	66 90                	xchg   %ax,%ax
  801fcf:	90                   	nop

00801fd0 <__udivdi3>:
  801fd0:	55                   	push   %ebp
  801fd1:	57                   	push   %edi
  801fd2:	56                   	push   %esi
  801fd3:	53                   	push   %ebx
  801fd4:	83 ec 1c             	sub    $0x1c,%esp
  801fd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fdb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fdf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fe3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fe7:	85 f6                	test   %esi,%esi
  801fe9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fed:	89 ca                	mov    %ecx,%edx
  801fef:	89 f8                	mov    %edi,%eax
  801ff1:	75 3d                	jne    802030 <__udivdi3+0x60>
  801ff3:	39 cf                	cmp    %ecx,%edi
  801ff5:	0f 87 c5 00 00 00    	ja     8020c0 <__udivdi3+0xf0>
  801ffb:	85 ff                	test   %edi,%edi
  801ffd:	89 fd                	mov    %edi,%ebp
  801fff:	75 0b                	jne    80200c <__udivdi3+0x3c>
  802001:	b8 01 00 00 00       	mov    $0x1,%eax
  802006:	31 d2                	xor    %edx,%edx
  802008:	f7 f7                	div    %edi
  80200a:	89 c5                	mov    %eax,%ebp
  80200c:	89 c8                	mov    %ecx,%eax
  80200e:	31 d2                	xor    %edx,%edx
  802010:	f7 f5                	div    %ebp
  802012:	89 c1                	mov    %eax,%ecx
  802014:	89 d8                	mov    %ebx,%eax
  802016:	89 cf                	mov    %ecx,%edi
  802018:	f7 f5                	div    %ebp
  80201a:	89 c3                	mov    %eax,%ebx
  80201c:	89 d8                	mov    %ebx,%eax
  80201e:	89 fa                	mov    %edi,%edx
  802020:	83 c4 1c             	add    $0x1c,%esp
  802023:	5b                   	pop    %ebx
  802024:	5e                   	pop    %esi
  802025:	5f                   	pop    %edi
  802026:	5d                   	pop    %ebp
  802027:	c3                   	ret    
  802028:	90                   	nop
  802029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802030:	39 ce                	cmp    %ecx,%esi
  802032:	77 74                	ja     8020a8 <__udivdi3+0xd8>
  802034:	0f bd fe             	bsr    %esi,%edi
  802037:	83 f7 1f             	xor    $0x1f,%edi
  80203a:	0f 84 98 00 00 00    	je     8020d8 <__udivdi3+0x108>
  802040:	bb 20 00 00 00       	mov    $0x20,%ebx
  802045:	89 f9                	mov    %edi,%ecx
  802047:	89 c5                	mov    %eax,%ebp
  802049:	29 fb                	sub    %edi,%ebx
  80204b:	d3 e6                	shl    %cl,%esi
  80204d:	89 d9                	mov    %ebx,%ecx
  80204f:	d3 ed                	shr    %cl,%ebp
  802051:	89 f9                	mov    %edi,%ecx
  802053:	d3 e0                	shl    %cl,%eax
  802055:	09 ee                	or     %ebp,%esi
  802057:	89 d9                	mov    %ebx,%ecx
  802059:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80205d:	89 d5                	mov    %edx,%ebp
  80205f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802063:	d3 ed                	shr    %cl,%ebp
  802065:	89 f9                	mov    %edi,%ecx
  802067:	d3 e2                	shl    %cl,%edx
  802069:	89 d9                	mov    %ebx,%ecx
  80206b:	d3 e8                	shr    %cl,%eax
  80206d:	09 c2                	or     %eax,%edx
  80206f:	89 d0                	mov    %edx,%eax
  802071:	89 ea                	mov    %ebp,%edx
  802073:	f7 f6                	div    %esi
  802075:	89 d5                	mov    %edx,%ebp
  802077:	89 c3                	mov    %eax,%ebx
  802079:	f7 64 24 0c          	mull   0xc(%esp)
  80207d:	39 d5                	cmp    %edx,%ebp
  80207f:	72 10                	jb     802091 <__udivdi3+0xc1>
  802081:	8b 74 24 08          	mov    0x8(%esp),%esi
  802085:	89 f9                	mov    %edi,%ecx
  802087:	d3 e6                	shl    %cl,%esi
  802089:	39 c6                	cmp    %eax,%esi
  80208b:	73 07                	jae    802094 <__udivdi3+0xc4>
  80208d:	39 d5                	cmp    %edx,%ebp
  80208f:	75 03                	jne    802094 <__udivdi3+0xc4>
  802091:	83 eb 01             	sub    $0x1,%ebx
  802094:	31 ff                	xor    %edi,%edi
  802096:	89 d8                	mov    %ebx,%eax
  802098:	89 fa                	mov    %edi,%edx
  80209a:	83 c4 1c             	add    $0x1c,%esp
  80209d:	5b                   	pop    %ebx
  80209e:	5e                   	pop    %esi
  80209f:	5f                   	pop    %edi
  8020a0:	5d                   	pop    %ebp
  8020a1:	c3                   	ret    
  8020a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020a8:	31 ff                	xor    %edi,%edi
  8020aa:	31 db                	xor    %ebx,%ebx
  8020ac:	89 d8                	mov    %ebx,%eax
  8020ae:	89 fa                	mov    %edi,%edx
  8020b0:	83 c4 1c             	add    $0x1c,%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5e                   	pop    %esi
  8020b5:	5f                   	pop    %edi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    
  8020b8:	90                   	nop
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	89 d8                	mov    %ebx,%eax
  8020c2:	f7 f7                	div    %edi
  8020c4:	31 ff                	xor    %edi,%edi
  8020c6:	89 c3                	mov    %eax,%ebx
  8020c8:	89 d8                	mov    %ebx,%eax
  8020ca:	89 fa                	mov    %edi,%edx
  8020cc:	83 c4 1c             	add    $0x1c,%esp
  8020cf:	5b                   	pop    %ebx
  8020d0:	5e                   	pop    %esi
  8020d1:	5f                   	pop    %edi
  8020d2:	5d                   	pop    %ebp
  8020d3:	c3                   	ret    
  8020d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020d8:	39 ce                	cmp    %ecx,%esi
  8020da:	72 0c                	jb     8020e8 <__udivdi3+0x118>
  8020dc:	31 db                	xor    %ebx,%ebx
  8020de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020e2:	0f 87 34 ff ff ff    	ja     80201c <__udivdi3+0x4c>
  8020e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020ed:	e9 2a ff ff ff       	jmp    80201c <__udivdi3+0x4c>
  8020f2:	66 90                	xchg   %ax,%ax
  8020f4:	66 90                	xchg   %ax,%ax
  8020f6:	66 90                	xchg   %ax,%ax
  8020f8:	66 90                	xchg   %ax,%ax
  8020fa:	66 90                	xchg   %ax,%ax
  8020fc:	66 90                	xchg   %ax,%ax
  8020fe:	66 90                	xchg   %ax,%ax

00802100 <__umoddi3>:
  802100:	55                   	push   %ebp
  802101:	57                   	push   %edi
  802102:	56                   	push   %esi
  802103:	53                   	push   %ebx
  802104:	83 ec 1c             	sub    $0x1c,%esp
  802107:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80210b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80210f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802113:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802117:	85 d2                	test   %edx,%edx
  802119:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80211d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802121:	89 f3                	mov    %esi,%ebx
  802123:	89 3c 24             	mov    %edi,(%esp)
  802126:	89 74 24 04          	mov    %esi,0x4(%esp)
  80212a:	75 1c                	jne    802148 <__umoddi3+0x48>
  80212c:	39 f7                	cmp    %esi,%edi
  80212e:	76 50                	jbe    802180 <__umoddi3+0x80>
  802130:	89 c8                	mov    %ecx,%eax
  802132:	89 f2                	mov    %esi,%edx
  802134:	f7 f7                	div    %edi
  802136:	89 d0                	mov    %edx,%eax
  802138:	31 d2                	xor    %edx,%edx
  80213a:	83 c4 1c             	add    $0x1c,%esp
  80213d:	5b                   	pop    %ebx
  80213e:	5e                   	pop    %esi
  80213f:	5f                   	pop    %edi
  802140:	5d                   	pop    %ebp
  802141:	c3                   	ret    
  802142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802148:	39 f2                	cmp    %esi,%edx
  80214a:	89 d0                	mov    %edx,%eax
  80214c:	77 52                	ja     8021a0 <__umoddi3+0xa0>
  80214e:	0f bd ea             	bsr    %edx,%ebp
  802151:	83 f5 1f             	xor    $0x1f,%ebp
  802154:	75 5a                	jne    8021b0 <__umoddi3+0xb0>
  802156:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80215a:	0f 82 e0 00 00 00    	jb     802240 <__umoddi3+0x140>
  802160:	39 0c 24             	cmp    %ecx,(%esp)
  802163:	0f 86 d7 00 00 00    	jbe    802240 <__umoddi3+0x140>
  802169:	8b 44 24 08          	mov    0x8(%esp),%eax
  80216d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802171:	83 c4 1c             	add    $0x1c,%esp
  802174:	5b                   	pop    %ebx
  802175:	5e                   	pop    %esi
  802176:	5f                   	pop    %edi
  802177:	5d                   	pop    %ebp
  802178:	c3                   	ret    
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	85 ff                	test   %edi,%edi
  802182:	89 fd                	mov    %edi,%ebp
  802184:	75 0b                	jne    802191 <__umoddi3+0x91>
  802186:	b8 01 00 00 00       	mov    $0x1,%eax
  80218b:	31 d2                	xor    %edx,%edx
  80218d:	f7 f7                	div    %edi
  80218f:	89 c5                	mov    %eax,%ebp
  802191:	89 f0                	mov    %esi,%eax
  802193:	31 d2                	xor    %edx,%edx
  802195:	f7 f5                	div    %ebp
  802197:	89 c8                	mov    %ecx,%eax
  802199:	f7 f5                	div    %ebp
  80219b:	89 d0                	mov    %edx,%eax
  80219d:	eb 99                	jmp    802138 <__umoddi3+0x38>
  80219f:	90                   	nop
  8021a0:	89 c8                	mov    %ecx,%eax
  8021a2:	89 f2                	mov    %esi,%edx
  8021a4:	83 c4 1c             	add    $0x1c,%esp
  8021a7:	5b                   	pop    %ebx
  8021a8:	5e                   	pop    %esi
  8021a9:	5f                   	pop    %edi
  8021aa:	5d                   	pop    %ebp
  8021ab:	c3                   	ret    
  8021ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	8b 34 24             	mov    (%esp),%esi
  8021b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021b8:	89 e9                	mov    %ebp,%ecx
  8021ba:	29 ef                	sub    %ebp,%edi
  8021bc:	d3 e0                	shl    %cl,%eax
  8021be:	89 f9                	mov    %edi,%ecx
  8021c0:	89 f2                	mov    %esi,%edx
  8021c2:	d3 ea                	shr    %cl,%edx
  8021c4:	89 e9                	mov    %ebp,%ecx
  8021c6:	09 c2                	or     %eax,%edx
  8021c8:	89 d8                	mov    %ebx,%eax
  8021ca:	89 14 24             	mov    %edx,(%esp)
  8021cd:	89 f2                	mov    %esi,%edx
  8021cf:	d3 e2                	shl    %cl,%edx
  8021d1:	89 f9                	mov    %edi,%ecx
  8021d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021db:	d3 e8                	shr    %cl,%eax
  8021dd:	89 e9                	mov    %ebp,%ecx
  8021df:	89 c6                	mov    %eax,%esi
  8021e1:	d3 e3                	shl    %cl,%ebx
  8021e3:	89 f9                	mov    %edi,%ecx
  8021e5:	89 d0                	mov    %edx,%eax
  8021e7:	d3 e8                	shr    %cl,%eax
  8021e9:	89 e9                	mov    %ebp,%ecx
  8021eb:	09 d8                	or     %ebx,%eax
  8021ed:	89 d3                	mov    %edx,%ebx
  8021ef:	89 f2                	mov    %esi,%edx
  8021f1:	f7 34 24             	divl   (%esp)
  8021f4:	89 d6                	mov    %edx,%esi
  8021f6:	d3 e3                	shl    %cl,%ebx
  8021f8:	f7 64 24 04          	mull   0x4(%esp)
  8021fc:	39 d6                	cmp    %edx,%esi
  8021fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802202:	89 d1                	mov    %edx,%ecx
  802204:	89 c3                	mov    %eax,%ebx
  802206:	72 08                	jb     802210 <__umoddi3+0x110>
  802208:	75 11                	jne    80221b <__umoddi3+0x11b>
  80220a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80220e:	73 0b                	jae    80221b <__umoddi3+0x11b>
  802210:	2b 44 24 04          	sub    0x4(%esp),%eax
  802214:	1b 14 24             	sbb    (%esp),%edx
  802217:	89 d1                	mov    %edx,%ecx
  802219:	89 c3                	mov    %eax,%ebx
  80221b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80221f:	29 da                	sub    %ebx,%edx
  802221:	19 ce                	sbb    %ecx,%esi
  802223:	89 f9                	mov    %edi,%ecx
  802225:	89 f0                	mov    %esi,%eax
  802227:	d3 e0                	shl    %cl,%eax
  802229:	89 e9                	mov    %ebp,%ecx
  80222b:	d3 ea                	shr    %cl,%edx
  80222d:	89 e9                	mov    %ebp,%ecx
  80222f:	d3 ee                	shr    %cl,%esi
  802231:	09 d0                	or     %edx,%eax
  802233:	89 f2                	mov    %esi,%edx
  802235:	83 c4 1c             	add    $0x1c,%esp
  802238:	5b                   	pop    %ebx
  802239:	5e                   	pop    %esi
  80223a:	5f                   	pop    %edi
  80223b:	5d                   	pop    %ebp
  80223c:	c3                   	ret    
  80223d:	8d 76 00             	lea    0x0(%esi),%esi
  802240:	29 f9                	sub    %edi,%ecx
  802242:	19 d6                	sbb    %edx,%esi
  802244:	89 74 24 04          	mov    %esi,0x4(%esp)
  802248:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80224c:	e9 18 ff ff ff       	jmp    802169 <__umoddi3+0x69>
