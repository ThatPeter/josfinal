
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
  80002c:	e8 c8 00 00 00       	call   8000f9 <libmain>
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
  800038:	e8 62 0b 00 00       	call   800b9f <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 bb 0e 00 00       	call   800f04 <fork>
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
  80005c:	e8 5d 0b 00 00       	call   800bbe <sys_yield>
		return;
  800061:	e9 8c 00 00 00       	jmp    8000f2 <umain+0xbf>
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
  800070:	69 d6 d8 00 00 00    	imul   $0xd8,%esi,%edx
  800076:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80007c:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  800082:	85 c0                	test   %eax,%eax
  800084:	75 e0                	jne    800066 <umain+0x33>
  800086:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  80008b:	e8 2e 0b 00 00       	call   800bbe <sys_yield>
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
  8000be:	68 e0 22 80 00       	push   $0x8022e0
  8000c3:	6a 21                	push   $0x21
  8000c5:	68 08 23 80 00       	push   $0x802308
  8000ca:	e8 ad 00 00 00       	call   80017c <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000cf:	a1 08 40 80 00       	mov    0x804008,%eax
  8000d4:	8b 90 b8 00 00 00    	mov    0xb8(%eax),%edx
  8000da:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8000e0:	83 ec 04             	sub    $0x4,%esp
  8000e3:	52                   	push   %edx
  8000e4:	50                   	push   %eax
  8000e5:	68 1b 23 80 00       	push   $0x80231b
  8000ea:	e8 66 01 00 00       	call   800255 <cprintf>
  8000ef:	83 c4 10             	add    $0x10,%esp

}
  8000f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f5:	5b                   	pop    %ebx
  8000f6:	5e                   	pop    %esi
  8000f7:	5d                   	pop    %ebp
  8000f8:	c3                   	ret    

008000f9 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	56                   	push   %esi
  8000fd:	53                   	push   %ebx
  8000fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800101:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800104:	e8 96 0a 00 00       	call   800b9f <sys_getenvid>
  800109:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010e:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  800114:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800119:	a3 08 40 80 00       	mov    %eax,0x804008
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011e:	85 db                	test   %ebx,%ebx
  800120:	7e 07                	jle    800129 <libmain+0x30>
		binaryname = argv[0];
  800122:	8b 06                	mov    (%esi),%eax
  800124:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800129:	83 ec 08             	sub    $0x8,%esp
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
  80012e:	e8 00 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800133:	e8 2a 00 00 00       	call   800162 <exit>
}
  800138:	83 c4 10             	add    $0x10,%esp
  80013b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5d                   	pop    %ebp
  800141:	c3                   	ret    

00800142 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  800142:	55                   	push   %ebp
  800143:	89 e5                	mov    %esp,%ebp
  800145:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  800148:	a1 0c 40 80 00       	mov    0x80400c,%eax
	func();
  80014d:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  80014f:	e8 4b 0a 00 00       	call   800b9f <sys_getenvid>
  800154:	83 ec 0c             	sub    $0xc,%esp
  800157:	50                   	push   %eax
  800158:	e8 91 0c 00 00       	call   800dee <sys_thread_free>
}
  80015d:	83 c4 10             	add    $0x10,%esp
  800160:	c9                   	leave  
  800161:	c3                   	ret    

00800162 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800168:	e8 a9 11 00 00       	call   801316 <close_all>
	sys_env_destroy(0);
  80016d:	83 ec 0c             	sub    $0xc,%esp
  800170:	6a 00                	push   $0x0
  800172:	e8 e7 09 00 00       	call   800b5e <sys_env_destroy>
}
  800177:	83 c4 10             	add    $0x10,%esp
  80017a:	c9                   	leave  
  80017b:	c3                   	ret    

0080017c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	56                   	push   %esi
  800180:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800181:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800184:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80018a:	e8 10 0a 00 00       	call   800b9f <sys_getenvid>
  80018f:	83 ec 0c             	sub    $0xc,%esp
  800192:	ff 75 0c             	pushl  0xc(%ebp)
  800195:	ff 75 08             	pushl  0x8(%ebp)
  800198:	56                   	push   %esi
  800199:	50                   	push   %eax
  80019a:	68 44 23 80 00       	push   $0x802344
  80019f:	e8 b1 00 00 00       	call   800255 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a4:	83 c4 18             	add    $0x18,%esp
  8001a7:	53                   	push   %ebx
  8001a8:	ff 75 10             	pushl  0x10(%ebp)
  8001ab:	e8 54 00 00 00       	call   800204 <vcprintf>
	cprintf("\n");
  8001b0:	c7 04 24 37 23 80 00 	movl   $0x802337,(%esp)
  8001b7:	e8 99 00 00 00       	call   800255 <cprintf>
  8001bc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001bf:	cc                   	int3   
  8001c0:	eb fd                	jmp    8001bf <_panic+0x43>

008001c2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c2:	55                   	push   %ebp
  8001c3:	89 e5                	mov    %esp,%ebp
  8001c5:	53                   	push   %ebx
  8001c6:	83 ec 04             	sub    $0x4,%esp
  8001c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001cc:	8b 13                	mov    (%ebx),%edx
  8001ce:	8d 42 01             	lea    0x1(%edx),%eax
  8001d1:	89 03                	mov    %eax,(%ebx)
  8001d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001da:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001df:	75 1a                	jne    8001fb <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001e1:	83 ec 08             	sub    $0x8,%esp
  8001e4:	68 ff 00 00 00       	push   $0xff
  8001e9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ec:	50                   	push   %eax
  8001ed:	e8 2f 09 00 00       	call   800b21 <sys_cputs>
		b->idx = 0;
  8001f2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001f8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001fb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800202:	c9                   	leave  
  800203:	c3                   	ret    

00800204 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80020d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800214:	00 00 00 
	b.cnt = 0;
  800217:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80021e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800221:	ff 75 0c             	pushl  0xc(%ebp)
  800224:	ff 75 08             	pushl  0x8(%ebp)
  800227:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80022d:	50                   	push   %eax
  80022e:	68 c2 01 80 00       	push   $0x8001c2
  800233:	e8 54 01 00 00       	call   80038c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800238:	83 c4 08             	add    $0x8,%esp
  80023b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800241:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800247:	50                   	push   %eax
  800248:	e8 d4 08 00 00       	call   800b21 <sys_cputs>

	return b.cnt;
}
  80024d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800253:	c9                   	leave  
  800254:	c3                   	ret    

00800255 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800255:	55                   	push   %ebp
  800256:	89 e5                	mov    %esp,%ebp
  800258:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80025b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80025e:	50                   	push   %eax
  80025f:	ff 75 08             	pushl  0x8(%ebp)
  800262:	e8 9d ff ff ff       	call   800204 <vcprintf>
	va_end(ap);

	return cnt;
}
  800267:	c9                   	leave  
  800268:	c3                   	ret    

00800269 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800269:	55                   	push   %ebp
  80026a:	89 e5                	mov    %esp,%ebp
  80026c:	57                   	push   %edi
  80026d:	56                   	push   %esi
  80026e:	53                   	push   %ebx
  80026f:	83 ec 1c             	sub    $0x1c,%esp
  800272:	89 c7                	mov    %eax,%edi
  800274:	89 d6                	mov    %edx,%esi
  800276:	8b 45 08             	mov    0x8(%ebp),%eax
  800279:	8b 55 0c             	mov    0xc(%ebp),%edx
  80027c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80027f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800282:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800285:	bb 00 00 00 00       	mov    $0x0,%ebx
  80028a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80028d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800290:	39 d3                	cmp    %edx,%ebx
  800292:	72 05                	jb     800299 <printnum+0x30>
  800294:	39 45 10             	cmp    %eax,0x10(%ebp)
  800297:	77 45                	ja     8002de <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800299:	83 ec 0c             	sub    $0xc,%esp
  80029c:	ff 75 18             	pushl  0x18(%ebp)
  80029f:	8b 45 14             	mov    0x14(%ebp),%eax
  8002a2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002a5:	53                   	push   %ebx
  8002a6:	ff 75 10             	pushl  0x10(%ebp)
  8002a9:	83 ec 08             	sub    $0x8,%esp
  8002ac:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002af:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b8:	e8 83 1d 00 00       	call   802040 <__udivdi3>
  8002bd:	83 c4 18             	add    $0x18,%esp
  8002c0:	52                   	push   %edx
  8002c1:	50                   	push   %eax
  8002c2:	89 f2                	mov    %esi,%edx
  8002c4:	89 f8                	mov    %edi,%eax
  8002c6:	e8 9e ff ff ff       	call   800269 <printnum>
  8002cb:	83 c4 20             	add    $0x20,%esp
  8002ce:	eb 18                	jmp    8002e8 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002d0:	83 ec 08             	sub    $0x8,%esp
  8002d3:	56                   	push   %esi
  8002d4:	ff 75 18             	pushl  0x18(%ebp)
  8002d7:	ff d7                	call   *%edi
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	eb 03                	jmp    8002e1 <printnum+0x78>
  8002de:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e1:	83 eb 01             	sub    $0x1,%ebx
  8002e4:	85 db                	test   %ebx,%ebx
  8002e6:	7f e8                	jg     8002d0 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002e8:	83 ec 08             	sub    $0x8,%esp
  8002eb:	56                   	push   %esi
  8002ec:	83 ec 04             	sub    $0x4,%esp
  8002ef:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002f2:	ff 75 e0             	pushl  -0x20(%ebp)
  8002f5:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f8:	ff 75 d8             	pushl  -0x28(%ebp)
  8002fb:	e8 70 1e 00 00       	call   802170 <__umoddi3>
  800300:	83 c4 14             	add    $0x14,%esp
  800303:	0f be 80 67 23 80 00 	movsbl 0x802367(%eax),%eax
  80030a:	50                   	push   %eax
  80030b:	ff d7                	call   *%edi
}
  80030d:	83 c4 10             	add    $0x10,%esp
  800310:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800313:	5b                   	pop    %ebx
  800314:	5e                   	pop    %esi
  800315:	5f                   	pop    %edi
  800316:	5d                   	pop    %ebp
  800317:	c3                   	ret    

00800318 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80031b:	83 fa 01             	cmp    $0x1,%edx
  80031e:	7e 0e                	jle    80032e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800320:	8b 10                	mov    (%eax),%edx
  800322:	8d 4a 08             	lea    0x8(%edx),%ecx
  800325:	89 08                	mov    %ecx,(%eax)
  800327:	8b 02                	mov    (%edx),%eax
  800329:	8b 52 04             	mov    0x4(%edx),%edx
  80032c:	eb 22                	jmp    800350 <getuint+0x38>
	else if (lflag)
  80032e:	85 d2                	test   %edx,%edx
  800330:	74 10                	je     800342 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800332:	8b 10                	mov    (%eax),%edx
  800334:	8d 4a 04             	lea    0x4(%edx),%ecx
  800337:	89 08                	mov    %ecx,(%eax)
  800339:	8b 02                	mov    (%edx),%eax
  80033b:	ba 00 00 00 00       	mov    $0x0,%edx
  800340:	eb 0e                	jmp    800350 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800342:	8b 10                	mov    (%eax),%edx
  800344:	8d 4a 04             	lea    0x4(%edx),%ecx
  800347:	89 08                	mov    %ecx,(%eax)
  800349:	8b 02                	mov    (%edx),%eax
  80034b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800350:	5d                   	pop    %ebp
  800351:	c3                   	ret    

00800352 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800352:	55                   	push   %ebp
  800353:	89 e5                	mov    %esp,%ebp
  800355:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800358:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80035c:	8b 10                	mov    (%eax),%edx
  80035e:	3b 50 04             	cmp    0x4(%eax),%edx
  800361:	73 0a                	jae    80036d <sprintputch+0x1b>
		*b->buf++ = ch;
  800363:	8d 4a 01             	lea    0x1(%edx),%ecx
  800366:	89 08                	mov    %ecx,(%eax)
  800368:	8b 45 08             	mov    0x8(%ebp),%eax
  80036b:	88 02                	mov    %al,(%edx)
}
  80036d:	5d                   	pop    %ebp
  80036e:	c3                   	ret    

0080036f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80036f:	55                   	push   %ebp
  800370:	89 e5                	mov    %esp,%ebp
  800372:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800375:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800378:	50                   	push   %eax
  800379:	ff 75 10             	pushl  0x10(%ebp)
  80037c:	ff 75 0c             	pushl  0xc(%ebp)
  80037f:	ff 75 08             	pushl  0x8(%ebp)
  800382:	e8 05 00 00 00       	call   80038c <vprintfmt>
	va_end(ap);
}
  800387:	83 c4 10             	add    $0x10,%esp
  80038a:	c9                   	leave  
  80038b:	c3                   	ret    

0080038c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	57                   	push   %edi
  800390:	56                   	push   %esi
  800391:	53                   	push   %ebx
  800392:	83 ec 2c             	sub    $0x2c,%esp
  800395:	8b 75 08             	mov    0x8(%ebp),%esi
  800398:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80039b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80039e:	eb 12                	jmp    8003b2 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003a0:	85 c0                	test   %eax,%eax
  8003a2:	0f 84 89 03 00 00    	je     800731 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003a8:	83 ec 08             	sub    $0x8,%esp
  8003ab:	53                   	push   %ebx
  8003ac:	50                   	push   %eax
  8003ad:	ff d6                	call   *%esi
  8003af:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003b2:	83 c7 01             	add    $0x1,%edi
  8003b5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003b9:	83 f8 25             	cmp    $0x25,%eax
  8003bc:	75 e2                	jne    8003a0 <vprintfmt+0x14>
  8003be:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003c2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003c9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003d0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003dc:	eb 07                	jmp    8003e5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003e1:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8d 47 01             	lea    0x1(%edi),%eax
  8003e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003eb:	0f b6 07             	movzbl (%edi),%eax
  8003ee:	0f b6 c8             	movzbl %al,%ecx
  8003f1:	83 e8 23             	sub    $0x23,%eax
  8003f4:	3c 55                	cmp    $0x55,%al
  8003f6:	0f 87 1a 03 00 00    	ja     800716 <vprintfmt+0x38a>
  8003fc:	0f b6 c0             	movzbl %al,%eax
  8003ff:	ff 24 85 a0 24 80 00 	jmp    *0x8024a0(,%eax,4)
  800406:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800409:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80040d:	eb d6                	jmp    8003e5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800412:	b8 00 00 00 00       	mov    $0x0,%eax
  800417:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80041a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80041d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800421:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800424:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800427:	83 fa 09             	cmp    $0x9,%edx
  80042a:	77 39                	ja     800465 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80042c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80042f:	eb e9                	jmp    80041a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800431:	8b 45 14             	mov    0x14(%ebp),%eax
  800434:	8d 48 04             	lea    0x4(%eax),%ecx
  800437:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80043a:	8b 00                	mov    (%eax),%eax
  80043c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800442:	eb 27                	jmp    80046b <vprintfmt+0xdf>
  800444:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800447:	85 c0                	test   %eax,%eax
  800449:	b9 00 00 00 00       	mov    $0x0,%ecx
  80044e:	0f 49 c8             	cmovns %eax,%ecx
  800451:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800454:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800457:	eb 8c                	jmp    8003e5 <vprintfmt+0x59>
  800459:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80045c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800463:	eb 80                	jmp    8003e5 <vprintfmt+0x59>
  800465:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800468:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80046b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80046f:	0f 89 70 ff ff ff    	jns    8003e5 <vprintfmt+0x59>
				width = precision, precision = -1;
  800475:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800478:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800482:	e9 5e ff ff ff       	jmp    8003e5 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800487:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80048d:	e9 53 ff ff ff       	jmp    8003e5 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800492:	8b 45 14             	mov    0x14(%ebp),%eax
  800495:	8d 50 04             	lea    0x4(%eax),%edx
  800498:	89 55 14             	mov    %edx,0x14(%ebp)
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	53                   	push   %ebx
  80049f:	ff 30                	pushl  (%eax)
  8004a1:	ff d6                	call   *%esi
			break;
  8004a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004a9:	e9 04 ff ff ff       	jmp    8003b2 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b1:	8d 50 04             	lea    0x4(%eax),%edx
  8004b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b7:	8b 00                	mov    (%eax),%eax
  8004b9:	99                   	cltd   
  8004ba:	31 d0                	xor    %edx,%eax
  8004bc:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004be:	83 f8 0f             	cmp    $0xf,%eax
  8004c1:	7f 0b                	jg     8004ce <vprintfmt+0x142>
  8004c3:	8b 14 85 00 26 80 00 	mov    0x802600(,%eax,4),%edx
  8004ca:	85 d2                	test   %edx,%edx
  8004cc:	75 18                	jne    8004e6 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004ce:	50                   	push   %eax
  8004cf:	68 7f 23 80 00       	push   $0x80237f
  8004d4:	53                   	push   %ebx
  8004d5:	56                   	push   %esi
  8004d6:	e8 94 fe ff ff       	call   80036f <printfmt>
  8004db:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004e1:	e9 cc fe ff ff       	jmp    8003b2 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004e6:	52                   	push   %edx
  8004e7:	68 b1 27 80 00       	push   $0x8027b1
  8004ec:	53                   	push   %ebx
  8004ed:	56                   	push   %esi
  8004ee:	e8 7c fe ff ff       	call   80036f <printfmt>
  8004f3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f9:	e9 b4 fe ff ff       	jmp    8003b2 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800501:	8d 50 04             	lea    0x4(%eax),%edx
  800504:	89 55 14             	mov    %edx,0x14(%ebp)
  800507:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800509:	85 ff                	test   %edi,%edi
  80050b:	b8 78 23 80 00       	mov    $0x802378,%eax
  800510:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800513:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800517:	0f 8e 94 00 00 00    	jle    8005b1 <vprintfmt+0x225>
  80051d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800521:	0f 84 98 00 00 00    	je     8005bf <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800527:	83 ec 08             	sub    $0x8,%esp
  80052a:	ff 75 d0             	pushl  -0x30(%ebp)
  80052d:	57                   	push   %edi
  80052e:	e8 86 02 00 00       	call   8007b9 <strnlen>
  800533:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800536:	29 c1                	sub    %eax,%ecx
  800538:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80053b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80053e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800542:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800545:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800548:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80054a:	eb 0f                	jmp    80055b <vprintfmt+0x1cf>
					putch(padc, putdat);
  80054c:	83 ec 08             	sub    $0x8,%esp
  80054f:	53                   	push   %ebx
  800550:	ff 75 e0             	pushl  -0x20(%ebp)
  800553:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800555:	83 ef 01             	sub    $0x1,%edi
  800558:	83 c4 10             	add    $0x10,%esp
  80055b:	85 ff                	test   %edi,%edi
  80055d:	7f ed                	jg     80054c <vprintfmt+0x1c0>
  80055f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800562:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800565:	85 c9                	test   %ecx,%ecx
  800567:	b8 00 00 00 00       	mov    $0x0,%eax
  80056c:	0f 49 c1             	cmovns %ecx,%eax
  80056f:	29 c1                	sub    %eax,%ecx
  800571:	89 75 08             	mov    %esi,0x8(%ebp)
  800574:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800577:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80057a:	89 cb                	mov    %ecx,%ebx
  80057c:	eb 4d                	jmp    8005cb <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80057e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800582:	74 1b                	je     80059f <vprintfmt+0x213>
  800584:	0f be c0             	movsbl %al,%eax
  800587:	83 e8 20             	sub    $0x20,%eax
  80058a:	83 f8 5e             	cmp    $0x5e,%eax
  80058d:	76 10                	jbe    80059f <vprintfmt+0x213>
					putch('?', putdat);
  80058f:	83 ec 08             	sub    $0x8,%esp
  800592:	ff 75 0c             	pushl  0xc(%ebp)
  800595:	6a 3f                	push   $0x3f
  800597:	ff 55 08             	call   *0x8(%ebp)
  80059a:	83 c4 10             	add    $0x10,%esp
  80059d:	eb 0d                	jmp    8005ac <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80059f:	83 ec 08             	sub    $0x8,%esp
  8005a2:	ff 75 0c             	pushl  0xc(%ebp)
  8005a5:	52                   	push   %edx
  8005a6:	ff 55 08             	call   *0x8(%ebp)
  8005a9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ac:	83 eb 01             	sub    $0x1,%ebx
  8005af:	eb 1a                	jmp    8005cb <vprintfmt+0x23f>
  8005b1:	89 75 08             	mov    %esi,0x8(%ebp)
  8005b4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005b7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ba:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005bd:	eb 0c                	jmp    8005cb <vprintfmt+0x23f>
  8005bf:	89 75 08             	mov    %esi,0x8(%ebp)
  8005c2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005c5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005c8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005cb:	83 c7 01             	add    $0x1,%edi
  8005ce:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005d2:	0f be d0             	movsbl %al,%edx
  8005d5:	85 d2                	test   %edx,%edx
  8005d7:	74 23                	je     8005fc <vprintfmt+0x270>
  8005d9:	85 f6                	test   %esi,%esi
  8005db:	78 a1                	js     80057e <vprintfmt+0x1f2>
  8005dd:	83 ee 01             	sub    $0x1,%esi
  8005e0:	79 9c                	jns    80057e <vprintfmt+0x1f2>
  8005e2:	89 df                	mov    %ebx,%edi
  8005e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ea:	eb 18                	jmp    800604 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ec:	83 ec 08             	sub    $0x8,%esp
  8005ef:	53                   	push   %ebx
  8005f0:	6a 20                	push   $0x20
  8005f2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005f4:	83 ef 01             	sub    $0x1,%edi
  8005f7:	83 c4 10             	add    $0x10,%esp
  8005fa:	eb 08                	jmp    800604 <vprintfmt+0x278>
  8005fc:	89 df                	mov    %ebx,%edi
  8005fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800601:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800604:	85 ff                	test   %edi,%edi
  800606:	7f e4                	jg     8005ec <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800608:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80060b:	e9 a2 fd ff ff       	jmp    8003b2 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800610:	83 fa 01             	cmp    $0x1,%edx
  800613:	7e 16                	jle    80062b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8d 50 08             	lea    0x8(%eax),%edx
  80061b:	89 55 14             	mov    %edx,0x14(%ebp)
  80061e:	8b 50 04             	mov    0x4(%eax),%edx
  800621:	8b 00                	mov    (%eax),%eax
  800623:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800626:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800629:	eb 32                	jmp    80065d <vprintfmt+0x2d1>
	else if (lflag)
  80062b:	85 d2                	test   %edx,%edx
  80062d:	74 18                	je     800647 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80062f:	8b 45 14             	mov    0x14(%ebp),%eax
  800632:	8d 50 04             	lea    0x4(%eax),%edx
  800635:	89 55 14             	mov    %edx,0x14(%ebp)
  800638:	8b 00                	mov    (%eax),%eax
  80063a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063d:	89 c1                	mov    %eax,%ecx
  80063f:	c1 f9 1f             	sar    $0x1f,%ecx
  800642:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800645:	eb 16                	jmp    80065d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800647:	8b 45 14             	mov    0x14(%ebp),%eax
  80064a:	8d 50 04             	lea    0x4(%eax),%edx
  80064d:	89 55 14             	mov    %edx,0x14(%ebp)
  800650:	8b 00                	mov    (%eax),%eax
  800652:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800655:	89 c1                	mov    %eax,%ecx
  800657:	c1 f9 1f             	sar    $0x1f,%ecx
  80065a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80065d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800660:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800663:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800668:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80066c:	79 74                	jns    8006e2 <vprintfmt+0x356>
				putch('-', putdat);
  80066e:	83 ec 08             	sub    $0x8,%esp
  800671:	53                   	push   %ebx
  800672:	6a 2d                	push   $0x2d
  800674:	ff d6                	call   *%esi
				num = -(long long) num;
  800676:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800679:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80067c:	f7 d8                	neg    %eax
  80067e:	83 d2 00             	adc    $0x0,%edx
  800681:	f7 da                	neg    %edx
  800683:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800686:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80068b:	eb 55                	jmp    8006e2 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80068d:	8d 45 14             	lea    0x14(%ebp),%eax
  800690:	e8 83 fc ff ff       	call   800318 <getuint>
			base = 10;
  800695:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80069a:	eb 46                	jmp    8006e2 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80069c:	8d 45 14             	lea    0x14(%ebp),%eax
  80069f:	e8 74 fc ff ff       	call   800318 <getuint>
			base = 8;
  8006a4:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006a9:	eb 37                	jmp    8006e2 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	53                   	push   %ebx
  8006af:	6a 30                	push   $0x30
  8006b1:	ff d6                	call   *%esi
			putch('x', putdat);
  8006b3:	83 c4 08             	add    $0x8,%esp
  8006b6:	53                   	push   %ebx
  8006b7:	6a 78                	push   $0x78
  8006b9:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006be:	8d 50 04             	lea    0x4(%eax),%edx
  8006c1:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006c4:	8b 00                	mov    (%eax),%eax
  8006c6:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006cb:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ce:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006d3:	eb 0d                	jmp    8006e2 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006d5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d8:	e8 3b fc ff ff       	call   800318 <getuint>
			base = 16;
  8006dd:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006e2:	83 ec 0c             	sub    $0xc,%esp
  8006e5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006e9:	57                   	push   %edi
  8006ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ed:	51                   	push   %ecx
  8006ee:	52                   	push   %edx
  8006ef:	50                   	push   %eax
  8006f0:	89 da                	mov    %ebx,%edx
  8006f2:	89 f0                	mov    %esi,%eax
  8006f4:	e8 70 fb ff ff       	call   800269 <printnum>
			break;
  8006f9:	83 c4 20             	add    $0x20,%esp
  8006fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ff:	e9 ae fc ff ff       	jmp    8003b2 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800704:	83 ec 08             	sub    $0x8,%esp
  800707:	53                   	push   %ebx
  800708:	51                   	push   %ecx
  800709:	ff d6                	call   *%esi
			break;
  80070b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800711:	e9 9c fc ff ff       	jmp    8003b2 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800716:	83 ec 08             	sub    $0x8,%esp
  800719:	53                   	push   %ebx
  80071a:	6a 25                	push   $0x25
  80071c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80071e:	83 c4 10             	add    $0x10,%esp
  800721:	eb 03                	jmp    800726 <vprintfmt+0x39a>
  800723:	83 ef 01             	sub    $0x1,%edi
  800726:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80072a:	75 f7                	jne    800723 <vprintfmt+0x397>
  80072c:	e9 81 fc ff ff       	jmp    8003b2 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800731:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800734:	5b                   	pop    %ebx
  800735:	5e                   	pop    %esi
  800736:	5f                   	pop    %edi
  800737:	5d                   	pop    %ebp
  800738:	c3                   	ret    

00800739 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800739:	55                   	push   %ebp
  80073a:	89 e5                	mov    %esp,%ebp
  80073c:	83 ec 18             	sub    $0x18,%esp
  80073f:	8b 45 08             	mov    0x8(%ebp),%eax
  800742:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800745:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800748:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80074c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80074f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800756:	85 c0                	test   %eax,%eax
  800758:	74 26                	je     800780 <vsnprintf+0x47>
  80075a:	85 d2                	test   %edx,%edx
  80075c:	7e 22                	jle    800780 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80075e:	ff 75 14             	pushl  0x14(%ebp)
  800761:	ff 75 10             	pushl  0x10(%ebp)
  800764:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800767:	50                   	push   %eax
  800768:	68 52 03 80 00       	push   $0x800352
  80076d:	e8 1a fc ff ff       	call   80038c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800772:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800775:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800778:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80077b:	83 c4 10             	add    $0x10,%esp
  80077e:	eb 05                	jmp    800785 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800780:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800785:	c9                   	leave  
  800786:	c3                   	ret    

00800787 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80078d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800790:	50                   	push   %eax
  800791:	ff 75 10             	pushl  0x10(%ebp)
  800794:	ff 75 0c             	pushl  0xc(%ebp)
  800797:	ff 75 08             	pushl  0x8(%ebp)
  80079a:	e8 9a ff ff ff       	call   800739 <vsnprintf>
	va_end(ap);

	return rc;
}
  80079f:	c9                   	leave  
  8007a0:	c3                   	ret    

008007a1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a1:	55                   	push   %ebp
  8007a2:	89 e5                	mov    %esp,%ebp
  8007a4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ac:	eb 03                	jmp    8007b1 <strlen+0x10>
		n++;
  8007ae:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b5:	75 f7                	jne    8007ae <strlen+0xd>
		n++;
	return n;
}
  8007b7:	5d                   	pop    %ebp
  8007b8:	c3                   	ret    

008007b9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007bf:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c7:	eb 03                	jmp    8007cc <strnlen+0x13>
		n++;
  8007c9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cc:	39 c2                	cmp    %eax,%edx
  8007ce:	74 08                	je     8007d8 <strnlen+0x1f>
  8007d0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007d4:	75 f3                	jne    8007c9 <strnlen+0x10>
  8007d6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007d8:	5d                   	pop    %ebp
  8007d9:	c3                   	ret    

008007da <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	53                   	push   %ebx
  8007de:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e4:	89 c2                	mov    %eax,%edx
  8007e6:	83 c2 01             	add    $0x1,%edx
  8007e9:	83 c1 01             	add    $0x1,%ecx
  8007ec:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007f0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007f3:	84 db                	test   %bl,%bl
  8007f5:	75 ef                	jne    8007e6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007f7:	5b                   	pop    %ebx
  8007f8:	5d                   	pop    %ebp
  8007f9:	c3                   	ret    

008007fa <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	53                   	push   %ebx
  8007fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800801:	53                   	push   %ebx
  800802:	e8 9a ff ff ff       	call   8007a1 <strlen>
  800807:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80080a:	ff 75 0c             	pushl  0xc(%ebp)
  80080d:	01 d8                	add    %ebx,%eax
  80080f:	50                   	push   %eax
  800810:	e8 c5 ff ff ff       	call   8007da <strcpy>
	return dst;
}
  800815:	89 d8                	mov    %ebx,%eax
  800817:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80081a:	c9                   	leave  
  80081b:	c3                   	ret    

0080081c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	56                   	push   %esi
  800820:	53                   	push   %ebx
  800821:	8b 75 08             	mov    0x8(%ebp),%esi
  800824:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800827:	89 f3                	mov    %esi,%ebx
  800829:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082c:	89 f2                	mov    %esi,%edx
  80082e:	eb 0f                	jmp    80083f <strncpy+0x23>
		*dst++ = *src;
  800830:	83 c2 01             	add    $0x1,%edx
  800833:	0f b6 01             	movzbl (%ecx),%eax
  800836:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800839:	80 39 01             	cmpb   $0x1,(%ecx)
  80083c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083f:	39 da                	cmp    %ebx,%edx
  800841:	75 ed                	jne    800830 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800843:	89 f0                	mov    %esi,%eax
  800845:	5b                   	pop    %ebx
  800846:	5e                   	pop    %esi
  800847:	5d                   	pop    %ebp
  800848:	c3                   	ret    

00800849 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	56                   	push   %esi
  80084d:	53                   	push   %ebx
  80084e:	8b 75 08             	mov    0x8(%ebp),%esi
  800851:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800854:	8b 55 10             	mov    0x10(%ebp),%edx
  800857:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800859:	85 d2                	test   %edx,%edx
  80085b:	74 21                	je     80087e <strlcpy+0x35>
  80085d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800861:	89 f2                	mov    %esi,%edx
  800863:	eb 09                	jmp    80086e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800865:	83 c2 01             	add    $0x1,%edx
  800868:	83 c1 01             	add    $0x1,%ecx
  80086b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80086e:	39 c2                	cmp    %eax,%edx
  800870:	74 09                	je     80087b <strlcpy+0x32>
  800872:	0f b6 19             	movzbl (%ecx),%ebx
  800875:	84 db                	test   %bl,%bl
  800877:	75 ec                	jne    800865 <strlcpy+0x1c>
  800879:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80087b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80087e:	29 f0                	sub    %esi,%eax
}
  800880:	5b                   	pop    %ebx
  800881:	5e                   	pop    %esi
  800882:	5d                   	pop    %ebp
  800883:	c3                   	ret    

00800884 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80088d:	eb 06                	jmp    800895 <strcmp+0x11>
		p++, q++;
  80088f:	83 c1 01             	add    $0x1,%ecx
  800892:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800895:	0f b6 01             	movzbl (%ecx),%eax
  800898:	84 c0                	test   %al,%al
  80089a:	74 04                	je     8008a0 <strcmp+0x1c>
  80089c:	3a 02                	cmp    (%edx),%al
  80089e:	74 ef                	je     80088f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a0:	0f b6 c0             	movzbl %al,%eax
  8008a3:	0f b6 12             	movzbl (%edx),%edx
  8008a6:	29 d0                	sub    %edx,%eax
}
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	53                   	push   %ebx
  8008ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b4:	89 c3                	mov    %eax,%ebx
  8008b6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b9:	eb 06                	jmp    8008c1 <strncmp+0x17>
		n--, p++, q++;
  8008bb:	83 c0 01             	add    $0x1,%eax
  8008be:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008c1:	39 d8                	cmp    %ebx,%eax
  8008c3:	74 15                	je     8008da <strncmp+0x30>
  8008c5:	0f b6 08             	movzbl (%eax),%ecx
  8008c8:	84 c9                	test   %cl,%cl
  8008ca:	74 04                	je     8008d0 <strncmp+0x26>
  8008cc:	3a 0a                	cmp    (%edx),%cl
  8008ce:	74 eb                	je     8008bb <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d0:	0f b6 00             	movzbl (%eax),%eax
  8008d3:	0f b6 12             	movzbl (%edx),%edx
  8008d6:	29 d0                	sub    %edx,%eax
  8008d8:	eb 05                	jmp    8008df <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008da:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008df:	5b                   	pop    %ebx
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ec:	eb 07                	jmp    8008f5 <strchr+0x13>
		if (*s == c)
  8008ee:	38 ca                	cmp    %cl,%dl
  8008f0:	74 0f                	je     800901 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008f2:	83 c0 01             	add    $0x1,%eax
  8008f5:	0f b6 10             	movzbl (%eax),%edx
  8008f8:	84 d2                	test   %dl,%dl
  8008fa:	75 f2                	jne    8008ee <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090d:	eb 03                	jmp    800912 <strfind+0xf>
  80090f:	83 c0 01             	add    $0x1,%eax
  800912:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800915:	38 ca                	cmp    %cl,%dl
  800917:	74 04                	je     80091d <strfind+0x1a>
  800919:	84 d2                	test   %dl,%dl
  80091b:	75 f2                	jne    80090f <strfind+0xc>
			break;
	return (char *) s;
}
  80091d:	5d                   	pop    %ebp
  80091e:	c3                   	ret    

0080091f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	57                   	push   %edi
  800923:	56                   	push   %esi
  800924:	53                   	push   %ebx
  800925:	8b 7d 08             	mov    0x8(%ebp),%edi
  800928:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80092b:	85 c9                	test   %ecx,%ecx
  80092d:	74 36                	je     800965 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80092f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800935:	75 28                	jne    80095f <memset+0x40>
  800937:	f6 c1 03             	test   $0x3,%cl
  80093a:	75 23                	jne    80095f <memset+0x40>
		c &= 0xFF;
  80093c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800940:	89 d3                	mov    %edx,%ebx
  800942:	c1 e3 08             	shl    $0x8,%ebx
  800945:	89 d6                	mov    %edx,%esi
  800947:	c1 e6 18             	shl    $0x18,%esi
  80094a:	89 d0                	mov    %edx,%eax
  80094c:	c1 e0 10             	shl    $0x10,%eax
  80094f:	09 f0                	or     %esi,%eax
  800951:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800953:	89 d8                	mov    %ebx,%eax
  800955:	09 d0                	or     %edx,%eax
  800957:	c1 e9 02             	shr    $0x2,%ecx
  80095a:	fc                   	cld    
  80095b:	f3 ab                	rep stos %eax,%es:(%edi)
  80095d:	eb 06                	jmp    800965 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80095f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800962:	fc                   	cld    
  800963:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800965:	89 f8                	mov    %edi,%eax
  800967:	5b                   	pop    %ebx
  800968:	5e                   	pop    %esi
  800969:	5f                   	pop    %edi
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	57                   	push   %edi
  800970:	56                   	push   %esi
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
  800974:	8b 75 0c             	mov    0xc(%ebp),%esi
  800977:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80097a:	39 c6                	cmp    %eax,%esi
  80097c:	73 35                	jae    8009b3 <memmove+0x47>
  80097e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800981:	39 d0                	cmp    %edx,%eax
  800983:	73 2e                	jae    8009b3 <memmove+0x47>
		s += n;
		d += n;
  800985:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800988:	89 d6                	mov    %edx,%esi
  80098a:	09 fe                	or     %edi,%esi
  80098c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800992:	75 13                	jne    8009a7 <memmove+0x3b>
  800994:	f6 c1 03             	test   $0x3,%cl
  800997:	75 0e                	jne    8009a7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800999:	83 ef 04             	sub    $0x4,%edi
  80099c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80099f:	c1 e9 02             	shr    $0x2,%ecx
  8009a2:	fd                   	std    
  8009a3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a5:	eb 09                	jmp    8009b0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a7:	83 ef 01             	sub    $0x1,%edi
  8009aa:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009ad:	fd                   	std    
  8009ae:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b0:	fc                   	cld    
  8009b1:	eb 1d                	jmp    8009d0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b3:	89 f2                	mov    %esi,%edx
  8009b5:	09 c2                	or     %eax,%edx
  8009b7:	f6 c2 03             	test   $0x3,%dl
  8009ba:	75 0f                	jne    8009cb <memmove+0x5f>
  8009bc:	f6 c1 03             	test   $0x3,%cl
  8009bf:	75 0a                	jne    8009cb <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009c1:	c1 e9 02             	shr    $0x2,%ecx
  8009c4:	89 c7                	mov    %eax,%edi
  8009c6:	fc                   	cld    
  8009c7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c9:	eb 05                	jmp    8009d0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009cb:	89 c7                	mov    %eax,%edi
  8009cd:	fc                   	cld    
  8009ce:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d0:	5e                   	pop    %esi
  8009d1:	5f                   	pop    %edi
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009d7:	ff 75 10             	pushl  0x10(%ebp)
  8009da:	ff 75 0c             	pushl  0xc(%ebp)
  8009dd:	ff 75 08             	pushl  0x8(%ebp)
  8009e0:	e8 87 ff ff ff       	call   80096c <memmove>
}
  8009e5:	c9                   	leave  
  8009e6:	c3                   	ret    

008009e7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	56                   	push   %esi
  8009eb:	53                   	push   %ebx
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f2:	89 c6                	mov    %eax,%esi
  8009f4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f7:	eb 1a                	jmp    800a13 <memcmp+0x2c>
		if (*s1 != *s2)
  8009f9:	0f b6 08             	movzbl (%eax),%ecx
  8009fc:	0f b6 1a             	movzbl (%edx),%ebx
  8009ff:	38 d9                	cmp    %bl,%cl
  800a01:	74 0a                	je     800a0d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a03:	0f b6 c1             	movzbl %cl,%eax
  800a06:	0f b6 db             	movzbl %bl,%ebx
  800a09:	29 d8                	sub    %ebx,%eax
  800a0b:	eb 0f                	jmp    800a1c <memcmp+0x35>
		s1++, s2++;
  800a0d:	83 c0 01             	add    $0x1,%eax
  800a10:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a13:	39 f0                	cmp    %esi,%eax
  800a15:	75 e2                	jne    8009f9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a17:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1c:	5b                   	pop    %ebx
  800a1d:	5e                   	pop    %esi
  800a1e:	5d                   	pop    %ebp
  800a1f:	c3                   	ret    

00800a20 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	53                   	push   %ebx
  800a24:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a27:	89 c1                	mov    %eax,%ecx
  800a29:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a2c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a30:	eb 0a                	jmp    800a3c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a32:	0f b6 10             	movzbl (%eax),%edx
  800a35:	39 da                	cmp    %ebx,%edx
  800a37:	74 07                	je     800a40 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a39:	83 c0 01             	add    $0x1,%eax
  800a3c:	39 c8                	cmp    %ecx,%eax
  800a3e:	72 f2                	jb     800a32 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a40:	5b                   	pop    %ebx
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    

00800a43 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	57                   	push   %edi
  800a47:	56                   	push   %esi
  800a48:	53                   	push   %ebx
  800a49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4f:	eb 03                	jmp    800a54 <strtol+0x11>
		s++;
  800a51:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a54:	0f b6 01             	movzbl (%ecx),%eax
  800a57:	3c 20                	cmp    $0x20,%al
  800a59:	74 f6                	je     800a51 <strtol+0xe>
  800a5b:	3c 09                	cmp    $0x9,%al
  800a5d:	74 f2                	je     800a51 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a5f:	3c 2b                	cmp    $0x2b,%al
  800a61:	75 0a                	jne    800a6d <strtol+0x2a>
		s++;
  800a63:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a66:	bf 00 00 00 00       	mov    $0x0,%edi
  800a6b:	eb 11                	jmp    800a7e <strtol+0x3b>
  800a6d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a72:	3c 2d                	cmp    $0x2d,%al
  800a74:	75 08                	jne    800a7e <strtol+0x3b>
		s++, neg = 1;
  800a76:	83 c1 01             	add    $0x1,%ecx
  800a79:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a7e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a84:	75 15                	jne    800a9b <strtol+0x58>
  800a86:	80 39 30             	cmpb   $0x30,(%ecx)
  800a89:	75 10                	jne    800a9b <strtol+0x58>
  800a8b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a8f:	75 7c                	jne    800b0d <strtol+0xca>
		s += 2, base = 16;
  800a91:	83 c1 02             	add    $0x2,%ecx
  800a94:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a99:	eb 16                	jmp    800ab1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a9b:	85 db                	test   %ebx,%ebx
  800a9d:	75 12                	jne    800ab1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a9f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa4:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa7:	75 08                	jne    800ab1 <strtol+0x6e>
		s++, base = 8;
  800aa9:	83 c1 01             	add    $0x1,%ecx
  800aac:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ab1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ab9:	0f b6 11             	movzbl (%ecx),%edx
  800abc:	8d 72 d0             	lea    -0x30(%edx),%esi
  800abf:	89 f3                	mov    %esi,%ebx
  800ac1:	80 fb 09             	cmp    $0x9,%bl
  800ac4:	77 08                	ja     800ace <strtol+0x8b>
			dig = *s - '0';
  800ac6:	0f be d2             	movsbl %dl,%edx
  800ac9:	83 ea 30             	sub    $0x30,%edx
  800acc:	eb 22                	jmp    800af0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ace:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ad1:	89 f3                	mov    %esi,%ebx
  800ad3:	80 fb 19             	cmp    $0x19,%bl
  800ad6:	77 08                	ja     800ae0 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ad8:	0f be d2             	movsbl %dl,%edx
  800adb:	83 ea 57             	sub    $0x57,%edx
  800ade:	eb 10                	jmp    800af0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ae0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ae3:	89 f3                	mov    %esi,%ebx
  800ae5:	80 fb 19             	cmp    $0x19,%bl
  800ae8:	77 16                	ja     800b00 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aea:	0f be d2             	movsbl %dl,%edx
  800aed:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800af0:	3b 55 10             	cmp    0x10(%ebp),%edx
  800af3:	7d 0b                	jge    800b00 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800af5:	83 c1 01             	add    $0x1,%ecx
  800af8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800afc:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800afe:	eb b9                	jmp    800ab9 <strtol+0x76>

	if (endptr)
  800b00:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b04:	74 0d                	je     800b13 <strtol+0xd0>
		*endptr = (char *) s;
  800b06:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b09:	89 0e                	mov    %ecx,(%esi)
  800b0b:	eb 06                	jmp    800b13 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b0d:	85 db                	test   %ebx,%ebx
  800b0f:	74 98                	je     800aa9 <strtol+0x66>
  800b11:	eb 9e                	jmp    800ab1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b13:	89 c2                	mov    %eax,%edx
  800b15:	f7 da                	neg    %edx
  800b17:	85 ff                	test   %edi,%edi
  800b19:	0f 45 c2             	cmovne %edx,%eax
}
  800b1c:	5b                   	pop    %ebx
  800b1d:	5e                   	pop    %esi
  800b1e:	5f                   	pop    %edi
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	57                   	push   %edi
  800b25:	56                   	push   %esi
  800b26:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b27:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b32:	89 c3                	mov    %eax,%ebx
  800b34:	89 c7                	mov    %eax,%edi
  800b36:	89 c6                	mov    %eax,%esi
  800b38:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5f                   	pop    %edi
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	57                   	push   %edi
  800b43:	56                   	push   %esi
  800b44:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b45:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4f:	89 d1                	mov    %edx,%ecx
  800b51:	89 d3                	mov    %edx,%ebx
  800b53:	89 d7                	mov    %edx,%edi
  800b55:	89 d6                	mov    %edx,%esi
  800b57:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
  800b64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b67:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6c:	b8 03 00 00 00       	mov    $0x3,%eax
  800b71:	8b 55 08             	mov    0x8(%ebp),%edx
  800b74:	89 cb                	mov    %ecx,%ebx
  800b76:	89 cf                	mov    %ecx,%edi
  800b78:	89 ce                	mov    %ecx,%esi
  800b7a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b7c:	85 c0                	test   %eax,%eax
  800b7e:	7e 17                	jle    800b97 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b80:	83 ec 0c             	sub    $0xc,%esp
  800b83:	50                   	push   %eax
  800b84:	6a 03                	push   $0x3
  800b86:	68 5f 26 80 00       	push   $0x80265f
  800b8b:	6a 23                	push   $0x23
  800b8d:	68 7c 26 80 00       	push   $0x80267c
  800b92:	e8 e5 f5 ff ff       	call   80017c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9a:	5b                   	pop    %ebx
  800b9b:	5e                   	pop    %esi
  800b9c:	5f                   	pop    %edi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800baa:	b8 02 00 00 00       	mov    $0x2,%eax
  800baf:	89 d1                	mov    %edx,%ecx
  800bb1:	89 d3                	mov    %edx,%ebx
  800bb3:	89 d7                	mov    %edx,%edi
  800bb5:	89 d6                	mov    %edx,%esi
  800bb7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <sys_yield>:

void
sys_yield(void)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bce:	89 d1                	mov    %edx,%ecx
  800bd0:	89 d3                	mov    %edx,%ebx
  800bd2:	89 d7                	mov    %edx,%edi
  800bd4:	89 d6                	mov    %edx,%esi
  800bd6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bd8:	5b                   	pop    %ebx
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    

00800bdd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	57                   	push   %edi
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
  800be3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be6:	be 00 00 00 00       	mov    $0x0,%esi
  800beb:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf9:	89 f7                	mov    %esi,%edi
  800bfb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfd:	85 c0                	test   %eax,%eax
  800bff:	7e 17                	jle    800c18 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c01:	83 ec 0c             	sub    $0xc,%esp
  800c04:	50                   	push   %eax
  800c05:	6a 04                	push   $0x4
  800c07:	68 5f 26 80 00       	push   $0x80265f
  800c0c:	6a 23                	push   $0x23
  800c0e:	68 7c 26 80 00       	push   $0x80267c
  800c13:	e8 64 f5 ff ff       	call   80017c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1b:	5b                   	pop    %ebx
  800c1c:	5e                   	pop    %esi
  800c1d:	5f                   	pop    %edi
  800c1e:	5d                   	pop    %ebp
  800c1f:	c3                   	ret    

00800c20 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	57                   	push   %edi
  800c24:	56                   	push   %esi
  800c25:	53                   	push   %ebx
  800c26:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c29:	b8 05 00 00 00       	mov    $0x5,%eax
  800c2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c31:	8b 55 08             	mov    0x8(%ebp),%edx
  800c34:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c37:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c3a:	8b 75 18             	mov    0x18(%ebp),%esi
  800c3d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3f:	85 c0                	test   %eax,%eax
  800c41:	7e 17                	jle    800c5a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c43:	83 ec 0c             	sub    $0xc,%esp
  800c46:	50                   	push   %eax
  800c47:	6a 05                	push   $0x5
  800c49:	68 5f 26 80 00       	push   $0x80265f
  800c4e:	6a 23                	push   $0x23
  800c50:	68 7c 26 80 00       	push   $0x80267c
  800c55:	e8 22 f5 ff ff       	call   80017c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5d:	5b                   	pop    %ebx
  800c5e:	5e                   	pop    %esi
  800c5f:	5f                   	pop    %edi
  800c60:	5d                   	pop    %ebp
  800c61:	c3                   	ret    

00800c62 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	57                   	push   %edi
  800c66:	56                   	push   %esi
  800c67:	53                   	push   %ebx
  800c68:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c70:	b8 06 00 00 00       	mov    $0x6,%eax
  800c75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c78:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7b:	89 df                	mov    %ebx,%edi
  800c7d:	89 de                	mov    %ebx,%esi
  800c7f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c81:	85 c0                	test   %eax,%eax
  800c83:	7e 17                	jle    800c9c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c85:	83 ec 0c             	sub    $0xc,%esp
  800c88:	50                   	push   %eax
  800c89:	6a 06                	push   $0x6
  800c8b:	68 5f 26 80 00       	push   $0x80265f
  800c90:	6a 23                	push   $0x23
  800c92:	68 7c 26 80 00       	push   $0x80267c
  800c97:	e8 e0 f4 ff ff       	call   80017c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5f                   	pop    %edi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
  800caa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb2:	b8 08 00 00 00       	mov    $0x8,%eax
  800cb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cba:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbd:	89 df                	mov    %ebx,%edi
  800cbf:	89 de                	mov    %ebx,%esi
  800cc1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc3:	85 c0                	test   %eax,%eax
  800cc5:	7e 17                	jle    800cde <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc7:	83 ec 0c             	sub    $0xc,%esp
  800cca:	50                   	push   %eax
  800ccb:	6a 08                	push   $0x8
  800ccd:	68 5f 26 80 00       	push   $0x80265f
  800cd2:	6a 23                	push   $0x23
  800cd4:	68 7c 26 80 00       	push   $0x80267c
  800cd9:	e8 9e f4 ff ff       	call   80017c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	57                   	push   %edi
  800cea:	56                   	push   %esi
  800ceb:	53                   	push   %ebx
  800cec:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cef:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf4:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cff:	89 df                	mov    %ebx,%edi
  800d01:	89 de                	mov    %ebx,%esi
  800d03:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d05:	85 c0                	test   %eax,%eax
  800d07:	7e 17                	jle    800d20 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d09:	83 ec 0c             	sub    $0xc,%esp
  800d0c:	50                   	push   %eax
  800d0d:	6a 09                	push   $0x9
  800d0f:	68 5f 26 80 00       	push   $0x80265f
  800d14:	6a 23                	push   $0x23
  800d16:	68 7c 26 80 00       	push   $0x80267c
  800d1b:	e8 5c f4 ff ff       	call   80017c <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d23:	5b                   	pop    %ebx
  800d24:	5e                   	pop    %esi
  800d25:	5f                   	pop    %edi
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    

00800d28 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	57                   	push   %edi
  800d2c:	56                   	push   %esi
  800d2d:	53                   	push   %ebx
  800d2e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d31:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d36:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d41:	89 df                	mov    %ebx,%edi
  800d43:	89 de                	mov    %ebx,%esi
  800d45:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d47:	85 c0                	test   %eax,%eax
  800d49:	7e 17                	jle    800d62 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4b:	83 ec 0c             	sub    $0xc,%esp
  800d4e:	50                   	push   %eax
  800d4f:	6a 0a                	push   $0xa
  800d51:	68 5f 26 80 00       	push   $0x80265f
  800d56:	6a 23                	push   $0x23
  800d58:	68 7c 26 80 00       	push   $0x80267c
  800d5d:	e8 1a f4 ff ff       	call   80017c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d65:	5b                   	pop    %ebx
  800d66:	5e                   	pop    %esi
  800d67:	5f                   	pop    %edi
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    

00800d6a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	57                   	push   %edi
  800d6e:	56                   	push   %esi
  800d6f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d70:	be 00 00 00 00       	mov    $0x0,%esi
  800d75:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d80:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d83:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d86:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d88:	5b                   	pop    %ebx
  800d89:	5e                   	pop    %esi
  800d8a:	5f                   	pop    %edi
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    

00800d8d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	57                   	push   %edi
  800d91:	56                   	push   %esi
  800d92:	53                   	push   %ebx
  800d93:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d96:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d9b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800da0:	8b 55 08             	mov    0x8(%ebp),%edx
  800da3:	89 cb                	mov    %ecx,%ebx
  800da5:	89 cf                	mov    %ecx,%edi
  800da7:	89 ce                	mov    %ecx,%esi
  800da9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dab:	85 c0                	test   %eax,%eax
  800dad:	7e 17                	jle    800dc6 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800daf:	83 ec 0c             	sub    $0xc,%esp
  800db2:	50                   	push   %eax
  800db3:	6a 0d                	push   $0xd
  800db5:	68 5f 26 80 00       	push   $0x80265f
  800dba:	6a 23                	push   $0x23
  800dbc:	68 7c 26 80 00       	push   $0x80267c
  800dc1:	e8 b6 f3 ff ff       	call   80017c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc9:	5b                   	pop    %ebx
  800dca:	5e                   	pop    %esi
  800dcb:	5f                   	pop    %edi
  800dcc:	5d                   	pop    %ebp
  800dcd:	c3                   	ret    

00800dce <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
  800dd1:	57                   	push   %edi
  800dd2:	56                   	push   %esi
  800dd3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd9:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dde:	8b 55 08             	mov    0x8(%ebp),%edx
  800de1:	89 cb                	mov    %ecx,%ebx
  800de3:	89 cf                	mov    %ecx,%edi
  800de5:	89 ce                	mov    %ecx,%esi
  800de7:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800de9:	5b                   	pop    %ebx
  800dea:	5e                   	pop    %esi
  800deb:	5f                   	pop    %edi
  800dec:	5d                   	pop    %ebp
  800ded:	c3                   	ret    

00800dee <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
  800df1:	57                   	push   %edi
  800df2:	56                   	push   %esi
  800df3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df9:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800e01:	89 cb                	mov    %ecx,%ebx
  800e03:	89 cf                	mov    %ecx,%edi
  800e05:	89 ce                	mov    %ecx,%esi
  800e07:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800e09:	5b                   	pop    %ebx
  800e0a:	5e                   	pop    %esi
  800e0b:	5f                   	pop    %edi
  800e0c:	5d                   	pop    %ebp
  800e0d:	c3                   	ret    

00800e0e <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	57                   	push   %edi
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e14:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e19:	b8 10 00 00 00       	mov    $0x10,%eax
  800e1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e21:	89 cb                	mov    %ecx,%ebx
  800e23:	89 cf                	mov    %ecx,%edi
  800e25:	89 ce                	mov    %ecx,%esi
  800e27:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800e29:	5b                   	pop    %ebx
  800e2a:	5e                   	pop    %esi
  800e2b:	5f                   	pop    %edi
  800e2c:	5d                   	pop    %ebp
  800e2d:	c3                   	ret    

00800e2e <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e2e:	55                   	push   %ebp
  800e2f:	89 e5                	mov    %esp,%ebp
  800e31:	53                   	push   %ebx
  800e32:	83 ec 04             	sub    $0x4,%esp
  800e35:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e38:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800e3a:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e3e:	74 11                	je     800e51 <pgfault+0x23>
  800e40:	89 d8                	mov    %ebx,%eax
  800e42:	c1 e8 0c             	shr    $0xc,%eax
  800e45:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e4c:	f6 c4 08             	test   $0x8,%ah
  800e4f:	75 14                	jne    800e65 <pgfault+0x37>
		panic("faulting access");
  800e51:	83 ec 04             	sub    $0x4,%esp
  800e54:	68 8a 26 80 00       	push   $0x80268a
  800e59:	6a 1e                	push   $0x1e
  800e5b:	68 9a 26 80 00       	push   $0x80269a
  800e60:	e8 17 f3 ff ff       	call   80017c <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e65:	83 ec 04             	sub    $0x4,%esp
  800e68:	6a 07                	push   $0x7
  800e6a:	68 00 f0 7f 00       	push   $0x7ff000
  800e6f:	6a 00                	push   $0x0
  800e71:	e8 67 fd ff ff       	call   800bdd <sys_page_alloc>
	if (r < 0) {
  800e76:	83 c4 10             	add    $0x10,%esp
  800e79:	85 c0                	test   %eax,%eax
  800e7b:	79 12                	jns    800e8f <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e7d:	50                   	push   %eax
  800e7e:	68 a5 26 80 00       	push   $0x8026a5
  800e83:	6a 2c                	push   $0x2c
  800e85:	68 9a 26 80 00       	push   $0x80269a
  800e8a:	e8 ed f2 ff ff       	call   80017c <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e8f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e95:	83 ec 04             	sub    $0x4,%esp
  800e98:	68 00 10 00 00       	push   $0x1000
  800e9d:	53                   	push   %ebx
  800e9e:	68 00 f0 7f 00       	push   $0x7ff000
  800ea3:	e8 2c fb ff ff       	call   8009d4 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800ea8:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800eaf:	53                   	push   %ebx
  800eb0:	6a 00                	push   $0x0
  800eb2:	68 00 f0 7f 00       	push   $0x7ff000
  800eb7:	6a 00                	push   $0x0
  800eb9:	e8 62 fd ff ff       	call   800c20 <sys_page_map>
	if (r < 0) {
  800ebe:	83 c4 20             	add    $0x20,%esp
  800ec1:	85 c0                	test   %eax,%eax
  800ec3:	79 12                	jns    800ed7 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800ec5:	50                   	push   %eax
  800ec6:	68 a5 26 80 00       	push   $0x8026a5
  800ecb:	6a 33                	push   $0x33
  800ecd:	68 9a 26 80 00       	push   $0x80269a
  800ed2:	e8 a5 f2 ff ff       	call   80017c <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800ed7:	83 ec 08             	sub    $0x8,%esp
  800eda:	68 00 f0 7f 00       	push   $0x7ff000
  800edf:	6a 00                	push   $0x0
  800ee1:	e8 7c fd ff ff       	call   800c62 <sys_page_unmap>
	if (r < 0) {
  800ee6:	83 c4 10             	add    $0x10,%esp
  800ee9:	85 c0                	test   %eax,%eax
  800eeb:	79 12                	jns    800eff <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800eed:	50                   	push   %eax
  800eee:	68 a5 26 80 00       	push   $0x8026a5
  800ef3:	6a 37                	push   $0x37
  800ef5:	68 9a 26 80 00       	push   $0x80269a
  800efa:	e8 7d f2 ff ff       	call   80017c <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800eff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f02:	c9                   	leave  
  800f03:	c3                   	ret    

00800f04 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	57                   	push   %edi
  800f08:	56                   	push   %esi
  800f09:	53                   	push   %ebx
  800f0a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800f0d:	68 2e 0e 80 00       	push   $0x800e2e
  800f12:	e8 30 0f 00 00       	call   801e47 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f17:	b8 07 00 00 00       	mov    $0x7,%eax
  800f1c:	cd 30                	int    $0x30
  800f1e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800f21:	83 c4 10             	add    $0x10,%esp
  800f24:	85 c0                	test   %eax,%eax
  800f26:	79 17                	jns    800f3f <fork+0x3b>
		panic("fork fault %e");
  800f28:	83 ec 04             	sub    $0x4,%esp
  800f2b:	68 be 26 80 00       	push   $0x8026be
  800f30:	68 84 00 00 00       	push   $0x84
  800f35:	68 9a 26 80 00       	push   $0x80269a
  800f3a:	e8 3d f2 ff ff       	call   80017c <_panic>
  800f3f:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f41:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f45:	75 24                	jne    800f6b <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f47:	e8 53 fc ff ff       	call   800b9f <sys_getenvid>
  800f4c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f51:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  800f57:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f5c:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800f61:	b8 00 00 00 00       	mov    $0x0,%eax
  800f66:	e9 64 01 00 00       	jmp    8010cf <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f6b:	83 ec 04             	sub    $0x4,%esp
  800f6e:	6a 07                	push   $0x7
  800f70:	68 00 f0 bf ee       	push   $0xeebff000
  800f75:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f78:	e8 60 fc ff ff       	call   800bdd <sys_page_alloc>
  800f7d:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f80:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f85:	89 d8                	mov    %ebx,%eax
  800f87:	c1 e8 16             	shr    $0x16,%eax
  800f8a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f91:	a8 01                	test   $0x1,%al
  800f93:	0f 84 fc 00 00 00    	je     801095 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f99:	89 d8                	mov    %ebx,%eax
  800f9b:	c1 e8 0c             	shr    $0xc,%eax
  800f9e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fa5:	f6 c2 01             	test   $0x1,%dl
  800fa8:	0f 84 e7 00 00 00    	je     801095 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800fae:	89 c6                	mov    %eax,%esi
  800fb0:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800fb3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fba:	f6 c6 04             	test   $0x4,%dh
  800fbd:	74 39                	je     800ff8 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800fbf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fc6:	83 ec 0c             	sub    $0xc,%esp
  800fc9:	25 07 0e 00 00       	and    $0xe07,%eax
  800fce:	50                   	push   %eax
  800fcf:	56                   	push   %esi
  800fd0:	57                   	push   %edi
  800fd1:	56                   	push   %esi
  800fd2:	6a 00                	push   $0x0
  800fd4:	e8 47 fc ff ff       	call   800c20 <sys_page_map>
		if (r < 0) {
  800fd9:	83 c4 20             	add    $0x20,%esp
  800fdc:	85 c0                	test   %eax,%eax
  800fde:	0f 89 b1 00 00 00    	jns    801095 <fork+0x191>
		    	panic("sys page map fault %e");
  800fe4:	83 ec 04             	sub    $0x4,%esp
  800fe7:	68 cc 26 80 00       	push   $0x8026cc
  800fec:	6a 54                	push   $0x54
  800fee:	68 9a 26 80 00       	push   $0x80269a
  800ff3:	e8 84 f1 ff ff       	call   80017c <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800ff8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fff:	f6 c2 02             	test   $0x2,%dl
  801002:	75 0c                	jne    801010 <fork+0x10c>
  801004:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80100b:	f6 c4 08             	test   $0x8,%ah
  80100e:	74 5b                	je     80106b <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  801010:	83 ec 0c             	sub    $0xc,%esp
  801013:	68 05 08 00 00       	push   $0x805
  801018:	56                   	push   %esi
  801019:	57                   	push   %edi
  80101a:	56                   	push   %esi
  80101b:	6a 00                	push   $0x0
  80101d:	e8 fe fb ff ff       	call   800c20 <sys_page_map>
		if (r < 0) {
  801022:	83 c4 20             	add    $0x20,%esp
  801025:	85 c0                	test   %eax,%eax
  801027:	79 14                	jns    80103d <fork+0x139>
		    	panic("sys page map fault %e");
  801029:	83 ec 04             	sub    $0x4,%esp
  80102c:	68 cc 26 80 00       	push   $0x8026cc
  801031:	6a 5b                	push   $0x5b
  801033:	68 9a 26 80 00       	push   $0x80269a
  801038:	e8 3f f1 ff ff       	call   80017c <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  80103d:	83 ec 0c             	sub    $0xc,%esp
  801040:	68 05 08 00 00       	push   $0x805
  801045:	56                   	push   %esi
  801046:	6a 00                	push   $0x0
  801048:	56                   	push   %esi
  801049:	6a 00                	push   $0x0
  80104b:	e8 d0 fb ff ff       	call   800c20 <sys_page_map>
		if (r < 0) {
  801050:	83 c4 20             	add    $0x20,%esp
  801053:	85 c0                	test   %eax,%eax
  801055:	79 3e                	jns    801095 <fork+0x191>
		    	panic("sys page map fault %e");
  801057:	83 ec 04             	sub    $0x4,%esp
  80105a:	68 cc 26 80 00       	push   $0x8026cc
  80105f:	6a 5f                	push   $0x5f
  801061:	68 9a 26 80 00       	push   $0x80269a
  801066:	e8 11 f1 ff ff       	call   80017c <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80106b:	83 ec 0c             	sub    $0xc,%esp
  80106e:	6a 05                	push   $0x5
  801070:	56                   	push   %esi
  801071:	57                   	push   %edi
  801072:	56                   	push   %esi
  801073:	6a 00                	push   $0x0
  801075:	e8 a6 fb ff ff       	call   800c20 <sys_page_map>
		if (r < 0) {
  80107a:	83 c4 20             	add    $0x20,%esp
  80107d:	85 c0                	test   %eax,%eax
  80107f:	79 14                	jns    801095 <fork+0x191>
		    	panic("sys page map fault %e");
  801081:	83 ec 04             	sub    $0x4,%esp
  801084:	68 cc 26 80 00       	push   $0x8026cc
  801089:	6a 64                	push   $0x64
  80108b:	68 9a 26 80 00       	push   $0x80269a
  801090:	e8 e7 f0 ff ff       	call   80017c <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801095:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80109b:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8010a1:	0f 85 de fe ff ff    	jne    800f85 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8010a7:	a1 08 40 80 00       	mov    0x804008,%eax
  8010ac:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
  8010b2:	83 ec 08             	sub    $0x8,%esp
  8010b5:	50                   	push   %eax
  8010b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010b9:	57                   	push   %edi
  8010ba:	e8 69 fc ff ff       	call   800d28 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8010bf:	83 c4 08             	add    $0x8,%esp
  8010c2:	6a 02                	push   $0x2
  8010c4:	57                   	push   %edi
  8010c5:	e8 da fb ff ff       	call   800ca4 <sys_env_set_status>
	
	return envid;
  8010ca:	83 c4 10             	add    $0x10,%esp
  8010cd:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8010cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d2:	5b                   	pop    %ebx
  8010d3:	5e                   	pop    %esi
  8010d4:	5f                   	pop    %edi
  8010d5:	5d                   	pop    %ebp
  8010d6:	c3                   	ret    

008010d7 <sfork>:

envid_t
sfork(void)
{
  8010d7:	55                   	push   %ebp
  8010d8:	89 e5                	mov    %esp,%ebp
	return 0;
}
  8010da:	b8 00 00 00 00       	mov    $0x0,%eax
  8010df:	5d                   	pop    %ebp
  8010e0:	c3                   	ret    

008010e1 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	56                   	push   %esi
  8010e5:	53                   	push   %ebx
  8010e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  8010e9:	89 1d 0c 40 80 00    	mov    %ebx,0x80400c
	cprintf("in fork.c thread create. func: %x\n", func);
  8010ef:	83 ec 08             	sub    $0x8,%esp
  8010f2:	53                   	push   %ebx
  8010f3:	68 e4 26 80 00       	push   $0x8026e4
  8010f8:	e8 58 f1 ff ff       	call   800255 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8010fd:	c7 04 24 42 01 80 00 	movl   $0x800142,(%esp)
  801104:	e8 c5 fc ff ff       	call   800dce <sys_thread_create>
  801109:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80110b:	83 c4 08             	add    $0x8,%esp
  80110e:	53                   	push   %ebx
  80110f:	68 e4 26 80 00       	push   $0x8026e4
  801114:	e8 3c f1 ff ff       	call   800255 <cprintf>
	return id;
}
  801119:	89 f0                	mov    %esi,%eax
  80111b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80111e:	5b                   	pop    %ebx
  80111f:	5e                   	pop    %esi
  801120:	5d                   	pop    %ebp
  801121:	c3                   	ret    

00801122 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  801122:	55                   	push   %ebp
  801123:	89 e5                	mov    %esp,%ebp
  801125:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  801128:	ff 75 08             	pushl  0x8(%ebp)
  80112b:	e8 be fc ff ff       	call   800dee <sys_thread_free>
}
  801130:	83 c4 10             	add    $0x10,%esp
  801133:	c9                   	leave  
  801134:	c3                   	ret    

00801135 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  80113b:	ff 75 08             	pushl  0x8(%ebp)
  80113e:	e8 cb fc ff ff       	call   800e0e <sys_thread_join>
}
  801143:	83 c4 10             	add    $0x10,%esp
  801146:	c9                   	leave  
  801147:	c3                   	ret    

00801148 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801148:	55                   	push   %ebp
  801149:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80114b:	8b 45 08             	mov    0x8(%ebp),%eax
  80114e:	05 00 00 00 30       	add    $0x30000000,%eax
  801153:	c1 e8 0c             	shr    $0xc,%eax
}
  801156:	5d                   	pop    %ebp
  801157:	c3                   	ret    

00801158 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801158:	55                   	push   %ebp
  801159:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80115b:	8b 45 08             	mov    0x8(%ebp),%eax
  80115e:	05 00 00 00 30       	add    $0x30000000,%eax
  801163:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801168:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80116d:	5d                   	pop    %ebp
  80116e:	c3                   	ret    

0080116f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80116f:	55                   	push   %ebp
  801170:	89 e5                	mov    %esp,%ebp
  801172:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801175:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80117a:	89 c2                	mov    %eax,%edx
  80117c:	c1 ea 16             	shr    $0x16,%edx
  80117f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801186:	f6 c2 01             	test   $0x1,%dl
  801189:	74 11                	je     80119c <fd_alloc+0x2d>
  80118b:	89 c2                	mov    %eax,%edx
  80118d:	c1 ea 0c             	shr    $0xc,%edx
  801190:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801197:	f6 c2 01             	test   $0x1,%dl
  80119a:	75 09                	jne    8011a5 <fd_alloc+0x36>
			*fd_store = fd;
  80119c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80119e:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a3:	eb 17                	jmp    8011bc <fd_alloc+0x4d>
  8011a5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011aa:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011af:	75 c9                	jne    80117a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011b1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011b7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011bc:	5d                   	pop    %ebp
  8011bd:	c3                   	ret    

008011be <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
  8011c1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011c4:	83 f8 1f             	cmp    $0x1f,%eax
  8011c7:	77 36                	ja     8011ff <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011c9:	c1 e0 0c             	shl    $0xc,%eax
  8011cc:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011d1:	89 c2                	mov    %eax,%edx
  8011d3:	c1 ea 16             	shr    $0x16,%edx
  8011d6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011dd:	f6 c2 01             	test   $0x1,%dl
  8011e0:	74 24                	je     801206 <fd_lookup+0x48>
  8011e2:	89 c2                	mov    %eax,%edx
  8011e4:	c1 ea 0c             	shr    $0xc,%edx
  8011e7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011ee:	f6 c2 01             	test   $0x1,%dl
  8011f1:	74 1a                	je     80120d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011f6:	89 02                	mov    %eax,(%edx)
	return 0;
  8011f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8011fd:	eb 13                	jmp    801212 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801204:	eb 0c                	jmp    801212 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801206:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80120b:	eb 05                	jmp    801212 <fd_lookup+0x54>
  80120d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801212:	5d                   	pop    %ebp
  801213:	c3                   	ret    

00801214 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801214:	55                   	push   %ebp
  801215:	89 e5                	mov    %esp,%ebp
  801217:	83 ec 08             	sub    $0x8,%esp
  80121a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80121d:	ba 88 27 80 00       	mov    $0x802788,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801222:	eb 13                	jmp    801237 <dev_lookup+0x23>
  801224:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801227:	39 08                	cmp    %ecx,(%eax)
  801229:	75 0c                	jne    801237 <dev_lookup+0x23>
			*dev = devtab[i];
  80122b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80122e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801230:	b8 00 00 00 00       	mov    $0x0,%eax
  801235:	eb 31                	jmp    801268 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801237:	8b 02                	mov    (%edx),%eax
  801239:	85 c0                	test   %eax,%eax
  80123b:	75 e7                	jne    801224 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80123d:	a1 08 40 80 00       	mov    0x804008,%eax
  801242:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801248:	83 ec 04             	sub    $0x4,%esp
  80124b:	51                   	push   %ecx
  80124c:	50                   	push   %eax
  80124d:	68 08 27 80 00       	push   $0x802708
  801252:	e8 fe ef ff ff       	call   800255 <cprintf>
	*dev = 0;
  801257:	8b 45 0c             	mov    0xc(%ebp),%eax
  80125a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801260:	83 c4 10             	add    $0x10,%esp
  801263:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801268:	c9                   	leave  
  801269:	c3                   	ret    

0080126a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
  80126d:	56                   	push   %esi
  80126e:	53                   	push   %ebx
  80126f:	83 ec 10             	sub    $0x10,%esp
  801272:	8b 75 08             	mov    0x8(%ebp),%esi
  801275:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801278:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127b:	50                   	push   %eax
  80127c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801282:	c1 e8 0c             	shr    $0xc,%eax
  801285:	50                   	push   %eax
  801286:	e8 33 ff ff ff       	call   8011be <fd_lookup>
  80128b:	83 c4 08             	add    $0x8,%esp
  80128e:	85 c0                	test   %eax,%eax
  801290:	78 05                	js     801297 <fd_close+0x2d>
	    || fd != fd2)
  801292:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801295:	74 0c                	je     8012a3 <fd_close+0x39>
		return (must_exist ? r : 0);
  801297:	84 db                	test   %bl,%bl
  801299:	ba 00 00 00 00       	mov    $0x0,%edx
  80129e:	0f 44 c2             	cmove  %edx,%eax
  8012a1:	eb 41                	jmp    8012e4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012a3:	83 ec 08             	sub    $0x8,%esp
  8012a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a9:	50                   	push   %eax
  8012aa:	ff 36                	pushl  (%esi)
  8012ac:	e8 63 ff ff ff       	call   801214 <dev_lookup>
  8012b1:	89 c3                	mov    %eax,%ebx
  8012b3:	83 c4 10             	add    $0x10,%esp
  8012b6:	85 c0                	test   %eax,%eax
  8012b8:	78 1a                	js     8012d4 <fd_close+0x6a>
		if (dev->dev_close)
  8012ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012bd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012c0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012c5:	85 c0                	test   %eax,%eax
  8012c7:	74 0b                	je     8012d4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012c9:	83 ec 0c             	sub    $0xc,%esp
  8012cc:	56                   	push   %esi
  8012cd:	ff d0                	call   *%eax
  8012cf:	89 c3                	mov    %eax,%ebx
  8012d1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012d4:	83 ec 08             	sub    $0x8,%esp
  8012d7:	56                   	push   %esi
  8012d8:	6a 00                	push   $0x0
  8012da:	e8 83 f9 ff ff       	call   800c62 <sys_page_unmap>
	return r;
  8012df:	83 c4 10             	add    $0x10,%esp
  8012e2:	89 d8                	mov    %ebx,%eax
}
  8012e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e7:	5b                   	pop    %ebx
  8012e8:	5e                   	pop    %esi
  8012e9:	5d                   	pop    %ebp
  8012ea:	c3                   	ret    

008012eb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012eb:	55                   	push   %ebp
  8012ec:	89 e5                	mov    %esp,%ebp
  8012ee:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f4:	50                   	push   %eax
  8012f5:	ff 75 08             	pushl  0x8(%ebp)
  8012f8:	e8 c1 fe ff ff       	call   8011be <fd_lookup>
  8012fd:	83 c4 08             	add    $0x8,%esp
  801300:	85 c0                	test   %eax,%eax
  801302:	78 10                	js     801314 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801304:	83 ec 08             	sub    $0x8,%esp
  801307:	6a 01                	push   $0x1
  801309:	ff 75 f4             	pushl  -0xc(%ebp)
  80130c:	e8 59 ff ff ff       	call   80126a <fd_close>
  801311:	83 c4 10             	add    $0x10,%esp
}
  801314:	c9                   	leave  
  801315:	c3                   	ret    

00801316 <close_all>:

void
close_all(void)
{
  801316:	55                   	push   %ebp
  801317:	89 e5                	mov    %esp,%ebp
  801319:	53                   	push   %ebx
  80131a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80131d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801322:	83 ec 0c             	sub    $0xc,%esp
  801325:	53                   	push   %ebx
  801326:	e8 c0 ff ff ff       	call   8012eb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80132b:	83 c3 01             	add    $0x1,%ebx
  80132e:	83 c4 10             	add    $0x10,%esp
  801331:	83 fb 20             	cmp    $0x20,%ebx
  801334:	75 ec                	jne    801322 <close_all+0xc>
		close(i);
}
  801336:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801339:	c9                   	leave  
  80133a:	c3                   	ret    

0080133b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80133b:	55                   	push   %ebp
  80133c:	89 e5                	mov    %esp,%ebp
  80133e:	57                   	push   %edi
  80133f:	56                   	push   %esi
  801340:	53                   	push   %ebx
  801341:	83 ec 2c             	sub    $0x2c,%esp
  801344:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801347:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80134a:	50                   	push   %eax
  80134b:	ff 75 08             	pushl  0x8(%ebp)
  80134e:	e8 6b fe ff ff       	call   8011be <fd_lookup>
  801353:	83 c4 08             	add    $0x8,%esp
  801356:	85 c0                	test   %eax,%eax
  801358:	0f 88 c1 00 00 00    	js     80141f <dup+0xe4>
		return r;
	close(newfdnum);
  80135e:	83 ec 0c             	sub    $0xc,%esp
  801361:	56                   	push   %esi
  801362:	e8 84 ff ff ff       	call   8012eb <close>

	newfd = INDEX2FD(newfdnum);
  801367:	89 f3                	mov    %esi,%ebx
  801369:	c1 e3 0c             	shl    $0xc,%ebx
  80136c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801372:	83 c4 04             	add    $0x4,%esp
  801375:	ff 75 e4             	pushl  -0x1c(%ebp)
  801378:	e8 db fd ff ff       	call   801158 <fd2data>
  80137d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80137f:	89 1c 24             	mov    %ebx,(%esp)
  801382:	e8 d1 fd ff ff       	call   801158 <fd2data>
  801387:	83 c4 10             	add    $0x10,%esp
  80138a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80138d:	89 f8                	mov    %edi,%eax
  80138f:	c1 e8 16             	shr    $0x16,%eax
  801392:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801399:	a8 01                	test   $0x1,%al
  80139b:	74 37                	je     8013d4 <dup+0x99>
  80139d:	89 f8                	mov    %edi,%eax
  80139f:	c1 e8 0c             	shr    $0xc,%eax
  8013a2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013a9:	f6 c2 01             	test   $0x1,%dl
  8013ac:	74 26                	je     8013d4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013b5:	83 ec 0c             	sub    $0xc,%esp
  8013b8:	25 07 0e 00 00       	and    $0xe07,%eax
  8013bd:	50                   	push   %eax
  8013be:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013c1:	6a 00                	push   $0x0
  8013c3:	57                   	push   %edi
  8013c4:	6a 00                	push   $0x0
  8013c6:	e8 55 f8 ff ff       	call   800c20 <sys_page_map>
  8013cb:	89 c7                	mov    %eax,%edi
  8013cd:	83 c4 20             	add    $0x20,%esp
  8013d0:	85 c0                	test   %eax,%eax
  8013d2:	78 2e                	js     801402 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013d7:	89 d0                	mov    %edx,%eax
  8013d9:	c1 e8 0c             	shr    $0xc,%eax
  8013dc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e3:	83 ec 0c             	sub    $0xc,%esp
  8013e6:	25 07 0e 00 00       	and    $0xe07,%eax
  8013eb:	50                   	push   %eax
  8013ec:	53                   	push   %ebx
  8013ed:	6a 00                	push   $0x0
  8013ef:	52                   	push   %edx
  8013f0:	6a 00                	push   $0x0
  8013f2:	e8 29 f8 ff ff       	call   800c20 <sys_page_map>
  8013f7:	89 c7                	mov    %eax,%edi
  8013f9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013fc:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013fe:	85 ff                	test   %edi,%edi
  801400:	79 1d                	jns    80141f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801402:	83 ec 08             	sub    $0x8,%esp
  801405:	53                   	push   %ebx
  801406:	6a 00                	push   $0x0
  801408:	e8 55 f8 ff ff       	call   800c62 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80140d:	83 c4 08             	add    $0x8,%esp
  801410:	ff 75 d4             	pushl  -0x2c(%ebp)
  801413:	6a 00                	push   $0x0
  801415:	e8 48 f8 ff ff       	call   800c62 <sys_page_unmap>
	return r;
  80141a:	83 c4 10             	add    $0x10,%esp
  80141d:	89 f8                	mov    %edi,%eax
}
  80141f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801422:	5b                   	pop    %ebx
  801423:	5e                   	pop    %esi
  801424:	5f                   	pop    %edi
  801425:	5d                   	pop    %ebp
  801426:	c3                   	ret    

00801427 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801427:	55                   	push   %ebp
  801428:	89 e5                	mov    %esp,%ebp
  80142a:	53                   	push   %ebx
  80142b:	83 ec 14             	sub    $0x14,%esp
  80142e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801431:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801434:	50                   	push   %eax
  801435:	53                   	push   %ebx
  801436:	e8 83 fd ff ff       	call   8011be <fd_lookup>
  80143b:	83 c4 08             	add    $0x8,%esp
  80143e:	89 c2                	mov    %eax,%edx
  801440:	85 c0                	test   %eax,%eax
  801442:	78 70                	js     8014b4 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801444:	83 ec 08             	sub    $0x8,%esp
  801447:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144a:	50                   	push   %eax
  80144b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144e:	ff 30                	pushl  (%eax)
  801450:	e8 bf fd ff ff       	call   801214 <dev_lookup>
  801455:	83 c4 10             	add    $0x10,%esp
  801458:	85 c0                	test   %eax,%eax
  80145a:	78 4f                	js     8014ab <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80145c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80145f:	8b 42 08             	mov    0x8(%edx),%eax
  801462:	83 e0 03             	and    $0x3,%eax
  801465:	83 f8 01             	cmp    $0x1,%eax
  801468:	75 24                	jne    80148e <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80146a:	a1 08 40 80 00       	mov    0x804008,%eax
  80146f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801475:	83 ec 04             	sub    $0x4,%esp
  801478:	53                   	push   %ebx
  801479:	50                   	push   %eax
  80147a:	68 4c 27 80 00       	push   $0x80274c
  80147f:	e8 d1 ed ff ff       	call   800255 <cprintf>
		return -E_INVAL;
  801484:	83 c4 10             	add    $0x10,%esp
  801487:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80148c:	eb 26                	jmp    8014b4 <read+0x8d>
	}
	if (!dev->dev_read)
  80148e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801491:	8b 40 08             	mov    0x8(%eax),%eax
  801494:	85 c0                	test   %eax,%eax
  801496:	74 17                	je     8014af <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801498:	83 ec 04             	sub    $0x4,%esp
  80149b:	ff 75 10             	pushl  0x10(%ebp)
  80149e:	ff 75 0c             	pushl  0xc(%ebp)
  8014a1:	52                   	push   %edx
  8014a2:	ff d0                	call   *%eax
  8014a4:	89 c2                	mov    %eax,%edx
  8014a6:	83 c4 10             	add    $0x10,%esp
  8014a9:	eb 09                	jmp    8014b4 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ab:	89 c2                	mov    %eax,%edx
  8014ad:	eb 05                	jmp    8014b4 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014af:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8014b4:	89 d0                	mov    %edx,%eax
  8014b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b9:	c9                   	leave  
  8014ba:	c3                   	ret    

008014bb <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
  8014be:	57                   	push   %edi
  8014bf:	56                   	push   %esi
  8014c0:	53                   	push   %ebx
  8014c1:	83 ec 0c             	sub    $0xc,%esp
  8014c4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014c7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ca:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014cf:	eb 21                	jmp    8014f2 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014d1:	83 ec 04             	sub    $0x4,%esp
  8014d4:	89 f0                	mov    %esi,%eax
  8014d6:	29 d8                	sub    %ebx,%eax
  8014d8:	50                   	push   %eax
  8014d9:	89 d8                	mov    %ebx,%eax
  8014db:	03 45 0c             	add    0xc(%ebp),%eax
  8014de:	50                   	push   %eax
  8014df:	57                   	push   %edi
  8014e0:	e8 42 ff ff ff       	call   801427 <read>
		if (m < 0)
  8014e5:	83 c4 10             	add    $0x10,%esp
  8014e8:	85 c0                	test   %eax,%eax
  8014ea:	78 10                	js     8014fc <readn+0x41>
			return m;
		if (m == 0)
  8014ec:	85 c0                	test   %eax,%eax
  8014ee:	74 0a                	je     8014fa <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f0:	01 c3                	add    %eax,%ebx
  8014f2:	39 f3                	cmp    %esi,%ebx
  8014f4:	72 db                	jb     8014d1 <readn+0x16>
  8014f6:	89 d8                	mov    %ebx,%eax
  8014f8:	eb 02                	jmp    8014fc <readn+0x41>
  8014fa:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ff:	5b                   	pop    %ebx
  801500:	5e                   	pop    %esi
  801501:	5f                   	pop    %edi
  801502:	5d                   	pop    %ebp
  801503:	c3                   	ret    

00801504 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801504:	55                   	push   %ebp
  801505:	89 e5                	mov    %esp,%ebp
  801507:	53                   	push   %ebx
  801508:	83 ec 14             	sub    $0x14,%esp
  80150b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80150e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801511:	50                   	push   %eax
  801512:	53                   	push   %ebx
  801513:	e8 a6 fc ff ff       	call   8011be <fd_lookup>
  801518:	83 c4 08             	add    $0x8,%esp
  80151b:	89 c2                	mov    %eax,%edx
  80151d:	85 c0                	test   %eax,%eax
  80151f:	78 6b                	js     80158c <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801521:	83 ec 08             	sub    $0x8,%esp
  801524:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801527:	50                   	push   %eax
  801528:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152b:	ff 30                	pushl  (%eax)
  80152d:	e8 e2 fc ff ff       	call   801214 <dev_lookup>
  801532:	83 c4 10             	add    $0x10,%esp
  801535:	85 c0                	test   %eax,%eax
  801537:	78 4a                	js     801583 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801539:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801540:	75 24                	jne    801566 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801542:	a1 08 40 80 00       	mov    0x804008,%eax
  801547:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80154d:	83 ec 04             	sub    $0x4,%esp
  801550:	53                   	push   %ebx
  801551:	50                   	push   %eax
  801552:	68 68 27 80 00       	push   $0x802768
  801557:	e8 f9 ec ff ff       	call   800255 <cprintf>
		return -E_INVAL;
  80155c:	83 c4 10             	add    $0x10,%esp
  80155f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801564:	eb 26                	jmp    80158c <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801566:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801569:	8b 52 0c             	mov    0xc(%edx),%edx
  80156c:	85 d2                	test   %edx,%edx
  80156e:	74 17                	je     801587 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801570:	83 ec 04             	sub    $0x4,%esp
  801573:	ff 75 10             	pushl  0x10(%ebp)
  801576:	ff 75 0c             	pushl  0xc(%ebp)
  801579:	50                   	push   %eax
  80157a:	ff d2                	call   *%edx
  80157c:	89 c2                	mov    %eax,%edx
  80157e:	83 c4 10             	add    $0x10,%esp
  801581:	eb 09                	jmp    80158c <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801583:	89 c2                	mov    %eax,%edx
  801585:	eb 05                	jmp    80158c <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801587:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80158c:	89 d0                	mov    %edx,%eax
  80158e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801591:	c9                   	leave  
  801592:	c3                   	ret    

00801593 <seek>:

int
seek(int fdnum, off_t offset)
{
  801593:	55                   	push   %ebp
  801594:	89 e5                	mov    %esp,%ebp
  801596:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801599:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80159c:	50                   	push   %eax
  80159d:	ff 75 08             	pushl  0x8(%ebp)
  8015a0:	e8 19 fc ff ff       	call   8011be <fd_lookup>
  8015a5:	83 c4 08             	add    $0x8,%esp
  8015a8:	85 c0                	test   %eax,%eax
  8015aa:	78 0e                	js     8015ba <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015b2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015ba:	c9                   	leave  
  8015bb:	c3                   	ret    

008015bc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015bc:	55                   	push   %ebp
  8015bd:	89 e5                	mov    %esp,%ebp
  8015bf:	53                   	push   %ebx
  8015c0:	83 ec 14             	sub    $0x14,%esp
  8015c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c9:	50                   	push   %eax
  8015ca:	53                   	push   %ebx
  8015cb:	e8 ee fb ff ff       	call   8011be <fd_lookup>
  8015d0:	83 c4 08             	add    $0x8,%esp
  8015d3:	89 c2                	mov    %eax,%edx
  8015d5:	85 c0                	test   %eax,%eax
  8015d7:	78 68                	js     801641 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d9:	83 ec 08             	sub    $0x8,%esp
  8015dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015df:	50                   	push   %eax
  8015e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e3:	ff 30                	pushl  (%eax)
  8015e5:	e8 2a fc ff ff       	call   801214 <dev_lookup>
  8015ea:	83 c4 10             	add    $0x10,%esp
  8015ed:	85 c0                	test   %eax,%eax
  8015ef:	78 47                	js     801638 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015f8:	75 24                	jne    80161e <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015fa:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015ff:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801605:	83 ec 04             	sub    $0x4,%esp
  801608:	53                   	push   %ebx
  801609:	50                   	push   %eax
  80160a:	68 28 27 80 00       	push   $0x802728
  80160f:	e8 41 ec ff ff       	call   800255 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801614:	83 c4 10             	add    $0x10,%esp
  801617:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80161c:	eb 23                	jmp    801641 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  80161e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801621:	8b 52 18             	mov    0x18(%edx),%edx
  801624:	85 d2                	test   %edx,%edx
  801626:	74 14                	je     80163c <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801628:	83 ec 08             	sub    $0x8,%esp
  80162b:	ff 75 0c             	pushl  0xc(%ebp)
  80162e:	50                   	push   %eax
  80162f:	ff d2                	call   *%edx
  801631:	89 c2                	mov    %eax,%edx
  801633:	83 c4 10             	add    $0x10,%esp
  801636:	eb 09                	jmp    801641 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801638:	89 c2                	mov    %eax,%edx
  80163a:	eb 05                	jmp    801641 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80163c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801641:	89 d0                	mov    %edx,%eax
  801643:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801646:	c9                   	leave  
  801647:	c3                   	ret    

00801648 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	53                   	push   %ebx
  80164c:	83 ec 14             	sub    $0x14,%esp
  80164f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801652:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801655:	50                   	push   %eax
  801656:	ff 75 08             	pushl  0x8(%ebp)
  801659:	e8 60 fb ff ff       	call   8011be <fd_lookup>
  80165e:	83 c4 08             	add    $0x8,%esp
  801661:	89 c2                	mov    %eax,%edx
  801663:	85 c0                	test   %eax,%eax
  801665:	78 58                	js     8016bf <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801667:	83 ec 08             	sub    $0x8,%esp
  80166a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166d:	50                   	push   %eax
  80166e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801671:	ff 30                	pushl  (%eax)
  801673:	e8 9c fb ff ff       	call   801214 <dev_lookup>
  801678:	83 c4 10             	add    $0x10,%esp
  80167b:	85 c0                	test   %eax,%eax
  80167d:	78 37                	js     8016b6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80167f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801682:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801686:	74 32                	je     8016ba <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801688:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80168b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801692:	00 00 00 
	stat->st_isdir = 0;
  801695:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80169c:	00 00 00 
	stat->st_dev = dev;
  80169f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016a5:	83 ec 08             	sub    $0x8,%esp
  8016a8:	53                   	push   %ebx
  8016a9:	ff 75 f0             	pushl  -0x10(%ebp)
  8016ac:	ff 50 14             	call   *0x14(%eax)
  8016af:	89 c2                	mov    %eax,%edx
  8016b1:	83 c4 10             	add    $0x10,%esp
  8016b4:	eb 09                	jmp    8016bf <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b6:	89 c2                	mov    %eax,%edx
  8016b8:	eb 05                	jmp    8016bf <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016bf:	89 d0                	mov    %edx,%eax
  8016c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c4:	c9                   	leave  
  8016c5:	c3                   	ret    

008016c6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016c6:	55                   	push   %ebp
  8016c7:	89 e5                	mov    %esp,%ebp
  8016c9:	56                   	push   %esi
  8016ca:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016cb:	83 ec 08             	sub    $0x8,%esp
  8016ce:	6a 00                	push   $0x0
  8016d0:	ff 75 08             	pushl  0x8(%ebp)
  8016d3:	e8 e3 01 00 00       	call   8018bb <open>
  8016d8:	89 c3                	mov    %eax,%ebx
  8016da:	83 c4 10             	add    $0x10,%esp
  8016dd:	85 c0                	test   %eax,%eax
  8016df:	78 1b                	js     8016fc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016e1:	83 ec 08             	sub    $0x8,%esp
  8016e4:	ff 75 0c             	pushl  0xc(%ebp)
  8016e7:	50                   	push   %eax
  8016e8:	e8 5b ff ff ff       	call   801648 <fstat>
  8016ed:	89 c6                	mov    %eax,%esi
	close(fd);
  8016ef:	89 1c 24             	mov    %ebx,(%esp)
  8016f2:	e8 f4 fb ff ff       	call   8012eb <close>
	return r;
  8016f7:	83 c4 10             	add    $0x10,%esp
  8016fa:	89 f0                	mov    %esi,%eax
}
  8016fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ff:	5b                   	pop    %ebx
  801700:	5e                   	pop    %esi
  801701:	5d                   	pop    %ebp
  801702:	c3                   	ret    

00801703 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	56                   	push   %esi
  801707:	53                   	push   %ebx
  801708:	89 c6                	mov    %eax,%esi
  80170a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80170c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801713:	75 12                	jne    801727 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801715:	83 ec 0c             	sub    $0xc,%esp
  801718:	6a 01                	push   $0x1
  80171a:	e8 94 08 00 00       	call   801fb3 <ipc_find_env>
  80171f:	a3 00 40 80 00       	mov    %eax,0x804000
  801724:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801727:	6a 07                	push   $0x7
  801729:	68 00 50 80 00       	push   $0x805000
  80172e:	56                   	push   %esi
  80172f:	ff 35 00 40 80 00    	pushl  0x804000
  801735:	e8 17 08 00 00       	call   801f51 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80173a:	83 c4 0c             	add    $0xc,%esp
  80173d:	6a 00                	push   $0x0
  80173f:	53                   	push   %ebx
  801740:	6a 00                	push   $0x0
  801742:	e8 8f 07 00 00       	call   801ed6 <ipc_recv>
}
  801747:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80174a:	5b                   	pop    %ebx
  80174b:	5e                   	pop    %esi
  80174c:	5d                   	pop    %ebp
  80174d:	c3                   	ret    

0080174e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80174e:	55                   	push   %ebp
  80174f:	89 e5                	mov    %esp,%ebp
  801751:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801754:	8b 45 08             	mov    0x8(%ebp),%eax
  801757:	8b 40 0c             	mov    0xc(%eax),%eax
  80175a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80175f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801762:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801767:	ba 00 00 00 00       	mov    $0x0,%edx
  80176c:	b8 02 00 00 00       	mov    $0x2,%eax
  801771:	e8 8d ff ff ff       	call   801703 <fsipc>
}
  801776:	c9                   	leave  
  801777:	c3                   	ret    

00801778 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80177e:	8b 45 08             	mov    0x8(%ebp),%eax
  801781:	8b 40 0c             	mov    0xc(%eax),%eax
  801784:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801789:	ba 00 00 00 00       	mov    $0x0,%edx
  80178e:	b8 06 00 00 00       	mov    $0x6,%eax
  801793:	e8 6b ff ff ff       	call   801703 <fsipc>
}
  801798:	c9                   	leave  
  801799:	c3                   	ret    

0080179a <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80179a:	55                   	push   %ebp
  80179b:	89 e5                	mov    %esp,%ebp
  80179d:	53                   	push   %ebx
  80179e:	83 ec 04             	sub    $0x4,%esp
  8017a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8017aa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017af:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8017b9:	e8 45 ff ff ff       	call   801703 <fsipc>
  8017be:	85 c0                	test   %eax,%eax
  8017c0:	78 2c                	js     8017ee <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017c2:	83 ec 08             	sub    $0x8,%esp
  8017c5:	68 00 50 80 00       	push   $0x805000
  8017ca:	53                   	push   %ebx
  8017cb:	e8 0a f0 ff ff       	call   8007da <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017d0:	a1 80 50 80 00       	mov    0x805080,%eax
  8017d5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017db:	a1 84 50 80 00       	mov    0x805084,%eax
  8017e0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017e6:	83 c4 10             	add    $0x10,%esp
  8017e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f1:	c9                   	leave  
  8017f2:	c3                   	ret    

008017f3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017f3:	55                   	push   %ebp
  8017f4:	89 e5                	mov    %esp,%ebp
  8017f6:	83 ec 0c             	sub    $0xc,%esp
  8017f9:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8017ff:	8b 52 0c             	mov    0xc(%edx),%edx
  801802:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801808:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80180d:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801812:	0f 47 c2             	cmova  %edx,%eax
  801815:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80181a:	50                   	push   %eax
  80181b:	ff 75 0c             	pushl  0xc(%ebp)
  80181e:	68 08 50 80 00       	push   $0x805008
  801823:	e8 44 f1 ff ff       	call   80096c <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801828:	ba 00 00 00 00       	mov    $0x0,%edx
  80182d:	b8 04 00 00 00       	mov    $0x4,%eax
  801832:	e8 cc fe ff ff       	call   801703 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801837:	c9                   	leave  
  801838:	c3                   	ret    

00801839 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801839:	55                   	push   %ebp
  80183a:	89 e5                	mov    %esp,%ebp
  80183c:	56                   	push   %esi
  80183d:	53                   	push   %ebx
  80183e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801841:	8b 45 08             	mov    0x8(%ebp),%eax
  801844:	8b 40 0c             	mov    0xc(%eax),%eax
  801847:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80184c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801852:	ba 00 00 00 00       	mov    $0x0,%edx
  801857:	b8 03 00 00 00       	mov    $0x3,%eax
  80185c:	e8 a2 fe ff ff       	call   801703 <fsipc>
  801861:	89 c3                	mov    %eax,%ebx
  801863:	85 c0                	test   %eax,%eax
  801865:	78 4b                	js     8018b2 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801867:	39 c6                	cmp    %eax,%esi
  801869:	73 16                	jae    801881 <devfile_read+0x48>
  80186b:	68 98 27 80 00       	push   $0x802798
  801870:	68 9f 27 80 00       	push   $0x80279f
  801875:	6a 7c                	push   $0x7c
  801877:	68 b4 27 80 00       	push   $0x8027b4
  80187c:	e8 fb e8 ff ff       	call   80017c <_panic>
	assert(r <= PGSIZE);
  801881:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801886:	7e 16                	jle    80189e <devfile_read+0x65>
  801888:	68 bf 27 80 00       	push   $0x8027bf
  80188d:	68 9f 27 80 00       	push   $0x80279f
  801892:	6a 7d                	push   $0x7d
  801894:	68 b4 27 80 00       	push   $0x8027b4
  801899:	e8 de e8 ff ff       	call   80017c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80189e:	83 ec 04             	sub    $0x4,%esp
  8018a1:	50                   	push   %eax
  8018a2:	68 00 50 80 00       	push   $0x805000
  8018a7:	ff 75 0c             	pushl  0xc(%ebp)
  8018aa:	e8 bd f0 ff ff       	call   80096c <memmove>
	return r;
  8018af:	83 c4 10             	add    $0x10,%esp
}
  8018b2:	89 d8                	mov    %ebx,%eax
  8018b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b7:	5b                   	pop    %ebx
  8018b8:	5e                   	pop    %esi
  8018b9:	5d                   	pop    %ebp
  8018ba:	c3                   	ret    

008018bb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
  8018be:	53                   	push   %ebx
  8018bf:	83 ec 20             	sub    $0x20,%esp
  8018c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018c5:	53                   	push   %ebx
  8018c6:	e8 d6 ee ff ff       	call   8007a1 <strlen>
  8018cb:	83 c4 10             	add    $0x10,%esp
  8018ce:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018d3:	7f 67                	jg     80193c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018d5:	83 ec 0c             	sub    $0xc,%esp
  8018d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018db:	50                   	push   %eax
  8018dc:	e8 8e f8 ff ff       	call   80116f <fd_alloc>
  8018e1:	83 c4 10             	add    $0x10,%esp
		return r;
  8018e4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018e6:	85 c0                	test   %eax,%eax
  8018e8:	78 57                	js     801941 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018ea:	83 ec 08             	sub    $0x8,%esp
  8018ed:	53                   	push   %ebx
  8018ee:	68 00 50 80 00       	push   $0x805000
  8018f3:	e8 e2 ee ff ff       	call   8007da <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018fb:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801900:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801903:	b8 01 00 00 00       	mov    $0x1,%eax
  801908:	e8 f6 fd ff ff       	call   801703 <fsipc>
  80190d:	89 c3                	mov    %eax,%ebx
  80190f:	83 c4 10             	add    $0x10,%esp
  801912:	85 c0                	test   %eax,%eax
  801914:	79 14                	jns    80192a <open+0x6f>
		fd_close(fd, 0);
  801916:	83 ec 08             	sub    $0x8,%esp
  801919:	6a 00                	push   $0x0
  80191b:	ff 75 f4             	pushl  -0xc(%ebp)
  80191e:	e8 47 f9 ff ff       	call   80126a <fd_close>
		return r;
  801923:	83 c4 10             	add    $0x10,%esp
  801926:	89 da                	mov    %ebx,%edx
  801928:	eb 17                	jmp    801941 <open+0x86>
	}

	return fd2num(fd);
  80192a:	83 ec 0c             	sub    $0xc,%esp
  80192d:	ff 75 f4             	pushl  -0xc(%ebp)
  801930:	e8 13 f8 ff ff       	call   801148 <fd2num>
  801935:	89 c2                	mov    %eax,%edx
  801937:	83 c4 10             	add    $0x10,%esp
  80193a:	eb 05                	jmp    801941 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80193c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801941:	89 d0                	mov    %edx,%eax
  801943:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801946:	c9                   	leave  
  801947:	c3                   	ret    

00801948 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
  80194b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80194e:	ba 00 00 00 00       	mov    $0x0,%edx
  801953:	b8 08 00 00 00       	mov    $0x8,%eax
  801958:	e8 a6 fd ff ff       	call   801703 <fsipc>
}
  80195d:	c9                   	leave  
  80195e:	c3                   	ret    

0080195f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80195f:	55                   	push   %ebp
  801960:	89 e5                	mov    %esp,%ebp
  801962:	56                   	push   %esi
  801963:	53                   	push   %ebx
  801964:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801967:	83 ec 0c             	sub    $0xc,%esp
  80196a:	ff 75 08             	pushl  0x8(%ebp)
  80196d:	e8 e6 f7 ff ff       	call   801158 <fd2data>
  801972:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801974:	83 c4 08             	add    $0x8,%esp
  801977:	68 cb 27 80 00       	push   $0x8027cb
  80197c:	53                   	push   %ebx
  80197d:	e8 58 ee ff ff       	call   8007da <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801982:	8b 46 04             	mov    0x4(%esi),%eax
  801985:	2b 06                	sub    (%esi),%eax
  801987:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80198d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801994:	00 00 00 
	stat->st_dev = &devpipe;
  801997:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80199e:	30 80 00 
	return 0;
}
  8019a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a9:	5b                   	pop    %ebx
  8019aa:	5e                   	pop    %esi
  8019ab:	5d                   	pop    %ebp
  8019ac:	c3                   	ret    

008019ad <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019ad:	55                   	push   %ebp
  8019ae:	89 e5                	mov    %esp,%ebp
  8019b0:	53                   	push   %ebx
  8019b1:	83 ec 0c             	sub    $0xc,%esp
  8019b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019b7:	53                   	push   %ebx
  8019b8:	6a 00                	push   $0x0
  8019ba:	e8 a3 f2 ff ff       	call   800c62 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019bf:	89 1c 24             	mov    %ebx,(%esp)
  8019c2:	e8 91 f7 ff ff       	call   801158 <fd2data>
  8019c7:	83 c4 08             	add    $0x8,%esp
  8019ca:	50                   	push   %eax
  8019cb:	6a 00                	push   $0x0
  8019cd:	e8 90 f2 ff ff       	call   800c62 <sys_page_unmap>
}
  8019d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d5:	c9                   	leave  
  8019d6:	c3                   	ret    

008019d7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019d7:	55                   	push   %ebp
  8019d8:	89 e5                	mov    %esp,%ebp
  8019da:	57                   	push   %edi
  8019db:	56                   	push   %esi
  8019dc:	53                   	push   %ebx
  8019dd:	83 ec 1c             	sub    $0x1c,%esp
  8019e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019e3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019e5:	a1 08 40 80 00       	mov    0x804008,%eax
  8019ea:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019f0:	83 ec 0c             	sub    $0xc,%esp
  8019f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8019f6:	e8 fd 05 00 00       	call   801ff8 <pageref>
  8019fb:	89 c3                	mov    %eax,%ebx
  8019fd:	89 3c 24             	mov    %edi,(%esp)
  801a00:	e8 f3 05 00 00       	call   801ff8 <pageref>
  801a05:	83 c4 10             	add    $0x10,%esp
  801a08:	39 c3                	cmp    %eax,%ebx
  801a0a:	0f 94 c1             	sete   %cl
  801a0d:	0f b6 c9             	movzbl %cl,%ecx
  801a10:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a13:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a19:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801a1f:	39 ce                	cmp    %ecx,%esi
  801a21:	74 1e                	je     801a41 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801a23:	39 c3                	cmp    %eax,%ebx
  801a25:	75 be                	jne    8019e5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a27:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801a2d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a30:	50                   	push   %eax
  801a31:	56                   	push   %esi
  801a32:	68 d2 27 80 00       	push   $0x8027d2
  801a37:	e8 19 e8 ff ff       	call   800255 <cprintf>
  801a3c:	83 c4 10             	add    $0x10,%esp
  801a3f:	eb a4                	jmp    8019e5 <_pipeisclosed+0xe>
	}
}
  801a41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a47:	5b                   	pop    %ebx
  801a48:	5e                   	pop    %esi
  801a49:	5f                   	pop    %edi
  801a4a:	5d                   	pop    %ebp
  801a4b:	c3                   	ret    

00801a4c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a4c:	55                   	push   %ebp
  801a4d:	89 e5                	mov    %esp,%ebp
  801a4f:	57                   	push   %edi
  801a50:	56                   	push   %esi
  801a51:	53                   	push   %ebx
  801a52:	83 ec 28             	sub    $0x28,%esp
  801a55:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a58:	56                   	push   %esi
  801a59:	e8 fa f6 ff ff       	call   801158 <fd2data>
  801a5e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a60:	83 c4 10             	add    $0x10,%esp
  801a63:	bf 00 00 00 00       	mov    $0x0,%edi
  801a68:	eb 4b                	jmp    801ab5 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a6a:	89 da                	mov    %ebx,%edx
  801a6c:	89 f0                	mov    %esi,%eax
  801a6e:	e8 64 ff ff ff       	call   8019d7 <_pipeisclosed>
  801a73:	85 c0                	test   %eax,%eax
  801a75:	75 48                	jne    801abf <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a77:	e8 42 f1 ff ff       	call   800bbe <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a7c:	8b 43 04             	mov    0x4(%ebx),%eax
  801a7f:	8b 0b                	mov    (%ebx),%ecx
  801a81:	8d 51 20             	lea    0x20(%ecx),%edx
  801a84:	39 d0                	cmp    %edx,%eax
  801a86:	73 e2                	jae    801a6a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a8b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a8f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a92:	89 c2                	mov    %eax,%edx
  801a94:	c1 fa 1f             	sar    $0x1f,%edx
  801a97:	89 d1                	mov    %edx,%ecx
  801a99:	c1 e9 1b             	shr    $0x1b,%ecx
  801a9c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a9f:	83 e2 1f             	and    $0x1f,%edx
  801aa2:	29 ca                	sub    %ecx,%edx
  801aa4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801aa8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801aac:	83 c0 01             	add    $0x1,%eax
  801aaf:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ab2:	83 c7 01             	add    $0x1,%edi
  801ab5:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ab8:	75 c2                	jne    801a7c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801aba:	8b 45 10             	mov    0x10(%ebp),%eax
  801abd:	eb 05                	jmp    801ac4 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801abf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ac4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac7:	5b                   	pop    %ebx
  801ac8:	5e                   	pop    %esi
  801ac9:	5f                   	pop    %edi
  801aca:	5d                   	pop    %ebp
  801acb:	c3                   	ret    

00801acc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801acc:	55                   	push   %ebp
  801acd:	89 e5                	mov    %esp,%ebp
  801acf:	57                   	push   %edi
  801ad0:	56                   	push   %esi
  801ad1:	53                   	push   %ebx
  801ad2:	83 ec 18             	sub    $0x18,%esp
  801ad5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ad8:	57                   	push   %edi
  801ad9:	e8 7a f6 ff ff       	call   801158 <fd2data>
  801ade:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae0:	83 c4 10             	add    $0x10,%esp
  801ae3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ae8:	eb 3d                	jmp    801b27 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801aea:	85 db                	test   %ebx,%ebx
  801aec:	74 04                	je     801af2 <devpipe_read+0x26>
				return i;
  801aee:	89 d8                	mov    %ebx,%eax
  801af0:	eb 44                	jmp    801b36 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801af2:	89 f2                	mov    %esi,%edx
  801af4:	89 f8                	mov    %edi,%eax
  801af6:	e8 dc fe ff ff       	call   8019d7 <_pipeisclosed>
  801afb:	85 c0                	test   %eax,%eax
  801afd:	75 32                	jne    801b31 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801aff:	e8 ba f0 ff ff       	call   800bbe <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b04:	8b 06                	mov    (%esi),%eax
  801b06:	3b 46 04             	cmp    0x4(%esi),%eax
  801b09:	74 df                	je     801aea <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b0b:	99                   	cltd   
  801b0c:	c1 ea 1b             	shr    $0x1b,%edx
  801b0f:	01 d0                	add    %edx,%eax
  801b11:	83 e0 1f             	and    $0x1f,%eax
  801b14:	29 d0                	sub    %edx,%eax
  801b16:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b1e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b21:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b24:	83 c3 01             	add    $0x1,%ebx
  801b27:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b2a:	75 d8                	jne    801b04 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b2c:	8b 45 10             	mov    0x10(%ebp),%eax
  801b2f:	eb 05                	jmp    801b36 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b31:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b39:	5b                   	pop    %ebx
  801b3a:	5e                   	pop    %esi
  801b3b:	5f                   	pop    %edi
  801b3c:	5d                   	pop    %ebp
  801b3d:	c3                   	ret    

00801b3e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	56                   	push   %esi
  801b42:	53                   	push   %ebx
  801b43:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b46:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b49:	50                   	push   %eax
  801b4a:	e8 20 f6 ff ff       	call   80116f <fd_alloc>
  801b4f:	83 c4 10             	add    $0x10,%esp
  801b52:	89 c2                	mov    %eax,%edx
  801b54:	85 c0                	test   %eax,%eax
  801b56:	0f 88 2c 01 00 00    	js     801c88 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b5c:	83 ec 04             	sub    $0x4,%esp
  801b5f:	68 07 04 00 00       	push   $0x407
  801b64:	ff 75 f4             	pushl  -0xc(%ebp)
  801b67:	6a 00                	push   $0x0
  801b69:	e8 6f f0 ff ff       	call   800bdd <sys_page_alloc>
  801b6e:	83 c4 10             	add    $0x10,%esp
  801b71:	89 c2                	mov    %eax,%edx
  801b73:	85 c0                	test   %eax,%eax
  801b75:	0f 88 0d 01 00 00    	js     801c88 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b7b:	83 ec 0c             	sub    $0xc,%esp
  801b7e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b81:	50                   	push   %eax
  801b82:	e8 e8 f5 ff ff       	call   80116f <fd_alloc>
  801b87:	89 c3                	mov    %eax,%ebx
  801b89:	83 c4 10             	add    $0x10,%esp
  801b8c:	85 c0                	test   %eax,%eax
  801b8e:	0f 88 e2 00 00 00    	js     801c76 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b94:	83 ec 04             	sub    $0x4,%esp
  801b97:	68 07 04 00 00       	push   $0x407
  801b9c:	ff 75 f0             	pushl  -0x10(%ebp)
  801b9f:	6a 00                	push   $0x0
  801ba1:	e8 37 f0 ff ff       	call   800bdd <sys_page_alloc>
  801ba6:	89 c3                	mov    %eax,%ebx
  801ba8:	83 c4 10             	add    $0x10,%esp
  801bab:	85 c0                	test   %eax,%eax
  801bad:	0f 88 c3 00 00 00    	js     801c76 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bb3:	83 ec 0c             	sub    $0xc,%esp
  801bb6:	ff 75 f4             	pushl  -0xc(%ebp)
  801bb9:	e8 9a f5 ff ff       	call   801158 <fd2data>
  801bbe:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc0:	83 c4 0c             	add    $0xc,%esp
  801bc3:	68 07 04 00 00       	push   $0x407
  801bc8:	50                   	push   %eax
  801bc9:	6a 00                	push   $0x0
  801bcb:	e8 0d f0 ff ff       	call   800bdd <sys_page_alloc>
  801bd0:	89 c3                	mov    %eax,%ebx
  801bd2:	83 c4 10             	add    $0x10,%esp
  801bd5:	85 c0                	test   %eax,%eax
  801bd7:	0f 88 89 00 00 00    	js     801c66 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bdd:	83 ec 0c             	sub    $0xc,%esp
  801be0:	ff 75 f0             	pushl  -0x10(%ebp)
  801be3:	e8 70 f5 ff ff       	call   801158 <fd2data>
  801be8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bef:	50                   	push   %eax
  801bf0:	6a 00                	push   $0x0
  801bf2:	56                   	push   %esi
  801bf3:	6a 00                	push   $0x0
  801bf5:	e8 26 f0 ff ff       	call   800c20 <sys_page_map>
  801bfa:	89 c3                	mov    %eax,%ebx
  801bfc:	83 c4 20             	add    $0x20,%esp
  801bff:	85 c0                	test   %eax,%eax
  801c01:	78 55                	js     801c58 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c03:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c0c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c11:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c18:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c21:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c23:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c26:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c2d:	83 ec 0c             	sub    $0xc,%esp
  801c30:	ff 75 f4             	pushl  -0xc(%ebp)
  801c33:	e8 10 f5 ff ff       	call   801148 <fd2num>
  801c38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c3b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c3d:	83 c4 04             	add    $0x4,%esp
  801c40:	ff 75 f0             	pushl  -0x10(%ebp)
  801c43:	e8 00 f5 ff ff       	call   801148 <fd2num>
  801c48:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c4b:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801c4e:	83 c4 10             	add    $0x10,%esp
  801c51:	ba 00 00 00 00       	mov    $0x0,%edx
  801c56:	eb 30                	jmp    801c88 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c58:	83 ec 08             	sub    $0x8,%esp
  801c5b:	56                   	push   %esi
  801c5c:	6a 00                	push   $0x0
  801c5e:	e8 ff ef ff ff       	call   800c62 <sys_page_unmap>
  801c63:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c66:	83 ec 08             	sub    $0x8,%esp
  801c69:	ff 75 f0             	pushl  -0x10(%ebp)
  801c6c:	6a 00                	push   $0x0
  801c6e:	e8 ef ef ff ff       	call   800c62 <sys_page_unmap>
  801c73:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c76:	83 ec 08             	sub    $0x8,%esp
  801c79:	ff 75 f4             	pushl  -0xc(%ebp)
  801c7c:	6a 00                	push   $0x0
  801c7e:	e8 df ef ff ff       	call   800c62 <sys_page_unmap>
  801c83:	83 c4 10             	add    $0x10,%esp
  801c86:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c88:	89 d0                	mov    %edx,%eax
  801c8a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c8d:	5b                   	pop    %ebx
  801c8e:	5e                   	pop    %esi
  801c8f:	5d                   	pop    %ebp
  801c90:	c3                   	ret    

00801c91 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c91:	55                   	push   %ebp
  801c92:	89 e5                	mov    %esp,%ebp
  801c94:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c9a:	50                   	push   %eax
  801c9b:	ff 75 08             	pushl  0x8(%ebp)
  801c9e:	e8 1b f5 ff ff       	call   8011be <fd_lookup>
  801ca3:	83 c4 10             	add    $0x10,%esp
  801ca6:	85 c0                	test   %eax,%eax
  801ca8:	78 18                	js     801cc2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801caa:	83 ec 0c             	sub    $0xc,%esp
  801cad:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb0:	e8 a3 f4 ff ff       	call   801158 <fd2data>
	return _pipeisclosed(fd, p);
  801cb5:	89 c2                	mov    %eax,%edx
  801cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cba:	e8 18 fd ff ff       	call   8019d7 <_pipeisclosed>
  801cbf:	83 c4 10             	add    $0x10,%esp
}
  801cc2:	c9                   	leave  
  801cc3:	c3                   	ret    

00801cc4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cc4:	55                   	push   %ebp
  801cc5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cc7:	b8 00 00 00 00       	mov    $0x0,%eax
  801ccc:	5d                   	pop    %ebp
  801ccd:	c3                   	ret    

00801cce <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cce:	55                   	push   %ebp
  801ccf:	89 e5                	mov    %esp,%ebp
  801cd1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cd4:	68 ea 27 80 00       	push   $0x8027ea
  801cd9:	ff 75 0c             	pushl  0xc(%ebp)
  801cdc:	e8 f9 ea ff ff       	call   8007da <strcpy>
	return 0;
}
  801ce1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ce6:	c9                   	leave  
  801ce7:	c3                   	ret    

00801ce8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	57                   	push   %edi
  801cec:	56                   	push   %esi
  801ced:	53                   	push   %ebx
  801cee:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cf4:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cf9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cff:	eb 2d                	jmp    801d2e <devcons_write+0x46>
		m = n - tot;
  801d01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d04:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d06:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d09:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d0e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d11:	83 ec 04             	sub    $0x4,%esp
  801d14:	53                   	push   %ebx
  801d15:	03 45 0c             	add    0xc(%ebp),%eax
  801d18:	50                   	push   %eax
  801d19:	57                   	push   %edi
  801d1a:	e8 4d ec ff ff       	call   80096c <memmove>
		sys_cputs(buf, m);
  801d1f:	83 c4 08             	add    $0x8,%esp
  801d22:	53                   	push   %ebx
  801d23:	57                   	push   %edi
  801d24:	e8 f8 ed ff ff       	call   800b21 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d29:	01 de                	add    %ebx,%esi
  801d2b:	83 c4 10             	add    $0x10,%esp
  801d2e:	89 f0                	mov    %esi,%eax
  801d30:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d33:	72 cc                	jb     801d01 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d38:	5b                   	pop    %ebx
  801d39:	5e                   	pop    %esi
  801d3a:	5f                   	pop    %edi
  801d3b:	5d                   	pop    %ebp
  801d3c:	c3                   	ret    

00801d3d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d3d:	55                   	push   %ebp
  801d3e:	89 e5                	mov    %esp,%ebp
  801d40:	83 ec 08             	sub    $0x8,%esp
  801d43:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d48:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d4c:	74 2a                	je     801d78 <devcons_read+0x3b>
  801d4e:	eb 05                	jmp    801d55 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d50:	e8 69 ee ff ff       	call   800bbe <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d55:	e8 e5 ed ff ff       	call   800b3f <sys_cgetc>
  801d5a:	85 c0                	test   %eax,%eax
  801d5c:	74 f2                	je     801d50 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d5e:	85 c0                	test   %eax,%eax
  801d60:	78 16                	js     801d78 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d62:	83 f8 04             	cmp    $0x4,%eax
  801d65:	74 0c                	je     801d73 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d67:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d6a:	88 02                	mov    %al,(%edx)
	return 1;
  801d6c:	b8 01 00 00 00       	mov    $0x1,%eax
  801d71:	eb 05                	jmp    801d78 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d73:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d78:	c9                   	leave  
  801d79:	c3                   	ret    

00801d7a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d7a:	55                   	push   %ebp
  801d7b:	89 e5                	mov    %esp,%ebp
  801d7d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d80:	8b 45 08             	mov    0x8(%ebp),%eax
  801d83:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d86:	6a 01                	push   $0x1
  801d88:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d8b:	50                   	push   %eax
  801d8c:	e8 90 ed ff ff       	call   800b21 <sys_cputs>
}
  801d91:	83 c4 10             	add    $0x10,%esp
  801d94:	c9                   	leave  
  801d95:	c3                   	ret    

00801d96 <getchar>:

int
getchar(void)
{
  801d96:	55                   	push   %ebp
  801d97:	89 e5                	mov    %esp,%ebp
  801d99:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d9c:	6a 01                	push   $0x1
  801d9e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801da1:	50                   	push   %eax
  801da2:	6a 00                	push   $0x0
  801da4:	e8 7e f6 ff ff       	call   801427 <read>
	if (r < 0)
  801da9:	83 c4 10             	add    $0x10,%esp
  801dac:	85 c0                	test   %eax,%eax
  801dae:	78 0f                	js     801dbf <getchar+0x29>
		return r;
	if (r < 1)
  801db0:	85 c0                	test   %eax,%eax
  801db2:	7e 06                	jle    801dba <getchar+0x24>
		return -E_EOF;
	return c;
  801db4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801db8:	eb 05                	jmp    801dbf <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801dba:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801dbf:	c9                   	leave  
  801dc0:	c3                   	ret    

00801dc1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801dc1:	55                   	push   %ebp
  801dc2:	89 e5                	mov    %esp,%ebp
  801dc4:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dc7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dca:	50                   	push   %eax
  801dcb:	ff 75 08             	pushl  0x8(%ebp)
  801dce:	e8 eb f3 ff ff       	call   8011be <fd_lookup>
  801dd3:	83 c4 10             	add    $0x10,%esp
  801dd6:	85 c0                	test   %eax,%eax
  801dd8:	78 11                	js     801deb <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801dda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ddd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801de3:	39 10                	cmp    %edx,(%eax)
  801de5:	0f 94 c0             	sete   %al
  801de8:	0f b6 c0             	movzbl %al,%eax
}
  801deb:	c9                   	leave  
  801dec:	c3                   	ret    

00801ded <opencons>:

int
opencons(void)
{
  801ded:	55                   	push   %ebp
  801dee:	89 e5                	mov    %esp,%ebp
  801df0:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801df3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df6:	50                   	push   %eax
  801df7:	e8 73 f3 ff ff       	call   80116f <fd_alloc>
  801dfc:	83 c4 10             	add    $0x10,%esp
		return r;
  801dff:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e01:	85 c0                	test   %eax,%eax
  801e03:	78 3e                	js     801e43 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e05:	83 ec 04             	sub    $0x4,%esp
  801e08:	68 07 04 00 00       	push   $0x407
  801e0d:	ff 75 f4             	pushl  -0xc(%ebp)
  801e10:	6a 00                	push   $0x0
  801e12:	e8 c6 ed ff ff       	call   800bdd <sys_page_alloc>
  801e17:	83 c4 10             	add    $0x10,%esp
		return r;
  801e1a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e1c:	85 c0                	test   %eax,%eax
  801e1e:	78 23                	js     801e43 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e20:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e29:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e2e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e35:	83 ec 0c             	sub    $0xc,%esp
  801e38:	50                   	push   %eax
  801e39:	e8 0a f3 ff ff       	call   801148 <fd2num>
  801e3e:	89 c2                	mov    %eax,%edx
  801e40:	83 c4 10             	add    $0x10,%esp
}
  801e43:	89 d0                	mov    %edx,%eax
  801e45:	c9                   	leave  
  801e46:	c3                   	ret    

00801e47 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e47:	55                   	push   %ebp
  801e48:	89 e5                	mov    %esp,%ebp
  801e4a:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e4d:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e54:	75 2a                	jne    801e80 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801e56:	83 ec 04             	sub    $0x4,%esp
  801e59:	6a 07                	push   $0x7
  801e5b:	68 00 f0 bf ee       	push   $0xeebff000
  801e60:	6a 00                	push   $0x0
  801e62:	e8 76 ed ff ff       	call   800bdd <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801e67:	83 c4 10             	add    $0x10,%esp
  801e6a:	85 c0                	test   %eax,%eax
  801e6c:	79 12                	jns    801e80 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801e6e:	50                   	push   %eax
  801e6f:	68 f6 27 80 00       	push   $0x8027f6
  801e74:	6a 23                	push   $0x23
  801e76:	68 fa 27 80 00       	push   $0x8027fa
  801e7b:	e8 fc e2 ff ff       	call   80017c <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e80:	8b 45 08             	mov    0x8(%ebp),%eax
  801e83:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801e88:	83 ec 08             	sub    $0x8,%esp
  801e8b:	68 b2 1e 80 00       	push   $0x801eb2
  801e90:	6a 00                	push   $0x0
  801e92:	e8 91 ee ff ff       	call   800d28 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801e97:	83 c4 10             	add    $0x10,%esp
  801e9a:	85 c0                	test   %eax,%eax
  801e9c:	79 12                	jns    801eb0 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801e9e:	50                   	push   %eax
  801e9f:	68 f6 27 80 00       	push   $0x8027f6
  801ea4:	6a 2c                	push   $0x2c
  801ea6:	68 fa 27 80 00       	push   $0x8027fa
  801eab:	e8 cc e2 ff ff       	call   80017c <_panic>
	}
}
  801eb0:	c9                   	leave  
  801eb1:	c3                   	ret    

00801eb2 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801eb2:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801eb3:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801eb8:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801eba:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801ebd:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801ec1:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801ec6:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801eca:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801ecc:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801ecf:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801ed0:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801ed3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801ed4:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801ed5:	c3                   	ret    

00801ed6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ed6:	55                   	push   %ebp
  801ed7:	89 e5                	mov    %esp,%ebp
  801ed9:	56                   	push   %esi
  801eda:	53                   	push   %ebx
  801edb:	8b 75 08             	mov    0x8(%ebp),%esi
  801ede:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801ee4:	85 c0                	test   %eax,%eax
  801ee6:	75 12                	jne    801efa <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801ee8:	83 ec 0c             	sub    $0xc,%esp
  801eeb:	68 00 00 c0 ee       	push   $0xeec00000
  801ef0:	e8 98 ee ff ff       	call   800d8d <sys_ipc_recv>
  801ef5:	83 c4 10             	add    $0x10,%esp
  801ef8:	eb 0c                	jmp    801f06 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801efa:	83 ec 0c             	sub    $0xc,%esp
  801efd:	50                   	push   %eax
  801efe:	e8 8a ee ff ff       	call   800d8d <sys_ipc_recv>
  801f03:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801f06:	85 f6                	test   %esi,%esi
  801f08:	0f 95 c1             	setne  %cl
  801f0b:	85 db                	test   %ebx,%ebx
  801f0d:	0f 95 c2             	setne  %dl
  801f10:	84 d1                	test   %dl,%cl
  801f12:	74 09                	je     801f1d <ipc_recv+0x47>
  801f14:	89 c2                	mov    %eax,%edx
  801f16:	c1 ea 1f             	shr    $0x1f,%edx
  801f19:	84 d2                	test   %dl,%dl
  801f1b:	75 2d                	jne    801f4a <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801f1d:	85 f6                	test   %esi,%esi
  801f1f:	74 0d                	je     801f2e <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801f21:	a1 08 40 80 00       	mov    0x804008,%eax
  801f26:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  801f2c:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801f2e:	85 db                	test   %ebx,%ebx
  801f30:	74 0d                	je     801f3f <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801f32:	a1 08 40 80 00       	mov    0x804008,%eax
  801f37:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  801f3d:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801f3f:	a1 08 40 80 00       	mov    0x804008,%eax
  801f44:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  801f4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f4d:	5b                   	pop    %ebx
  801f4e:	5e                   	pop    %esi
  801f4f:	5d                   	pop    %ebp
  801f50:	c3                   	ret    

00801f51 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f51:	55                   	push   %ebp
  801f52:	89 e5                	mov    %esp,%ebp
  801f54:	57                   	push   %edi
  801f55:	56                   	push   %esi
  801f56:	53                   	push   %ebx
  801f57:	83 ec 0c             	sub    $0xc,%esp
  801f5a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f5d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f60:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801f63:	85 db                	test   %ebx,%ebx
  801f65:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f6a:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801f6d:	ff 75 14             	pushl  0x14(%ebp)
  801f70:	53                   	push   %ebx
  801f71:	56                   	push   %esi
  801f72:	57                   	push   %edi
  801f73:	e8 f2 ed ff ff       	call   800d6a <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801f78:	89 c2                	mov    %eax,%edx
  801f7a:	c1 ea 1f             	shr    $0x1f,%edx
  801f7d:	83 c4 10             	add    $0x10,%esp
  801f80:	84 d2                	test   %dl,%dl
  801f82:	74 17                	je     801f9b <ipc_send+0x4a>
  801f84:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f87:	74 12                	je     801f9b <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801f89:	50                   	push   %eax
  801f8a:	68 08 28 80 00       	push   $0x802808
  801f8f:	6a 47                	push   $0x47
  801f91:	68 16 28 80 00       	push   $0x802816
  801f96:	e8 e1 e1 ff ff       	call   80017c <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801f9b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f9e:	75 07                	jne    801fa7 <ipc_send+0x56>
			sys_yield();
  801fa0:	e8 19 ec ff ff       	call   800bbe <sys_yield>
  801fa5:	eb c6                	jmp    801f6d <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801fa7:	85 c0                	test   %eax,%eax
  801fa9:	75 c2                	jne    801f6d <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801fab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fae:	5b                   	pop    %ebx
  801faf:	5e                   	pop    %esi
  801fb0:	5f                   	pop    %edi
  801fb1:	5d                   	pop    %ebp
  801fb2:	c3                   	ret    

00801fb3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fb3:	55                   	push   %ebp
  801fb4:	89 e5                	mov    %esp,%ebp
  801fb6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fb9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fbe:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  801fc4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fca:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  801fd0:	39 ca                	cmp    %ecx,%edx
  801fd2:	75 13                	jne    801fe7 <ipc_find_env+0x34>
			return envs[i].env_id;
  801fd4:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  801fda:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fdf:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801fe5:	eb 0f                	jmp    801ff6 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fe7:	83 c0 01             	add    $0x1,%eax
  801fea:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fef:	75 cd                	jne    801fbe <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ff1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ff6:	5d                   	pop    %ebp
  801ff7:	c3                   	ret    

00801ff8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ff8:	55                   	push   %ebp
  801ff9:	89 e5                	mov    %esp,%ebp
  801ffb:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ffe:	89 d0                	mov    %edx,%eax
  802000:	c1 e8 16             	shr    $0x16,%eax
  802003:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80200a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80200f:	f6 c1 01             	test   $0x1,%cl
  802012:	74 1d                	je     802031 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802014:	c1 ea 0c             	shr    $0xc,%edx
  802017:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80201e:	f6 c2 01             	test   $0x1,%dl
  802021:	74 0e                	je     802031 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802023:	c1 ea 0c             	shr    $0xc,%edx
  802026:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80202d:	ef 
  80202e:	0f b7 c0             	movzwl %ax,%eax
}
  802031:	5d                   	pop    %ebp
  802032:	c3                   	ret    
  802033:	66 90                	xchg   %ax,%ax
  802035:	66 90                	xchg   %ax,%ax
  802037:	66 90                	xchg   %ax,%ax
  802039:	66 90                	xchg   %ax,%ax
  80203b:	66 90                	xchg   %ax,%ax
  80203d:	66 90                	xchg   %ax,%ax
  80203f:	90                   	nop

00802040 <__udivdi3>:
  802040:	55                   	push   %ebp
  802041:	57                   	push   %edi
  802042:	56                   	push   %esi
  802043:	53                   	push   %ebx
  802044:	83 ec 1c             	sub    $0x1c,%esp
  802047:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80204b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80204f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802053:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802057:	85 f6                	test   %esi,%esi
  802059:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80205d:	89 ca                	mov    %ecx,%edx
  80205f:	89 f8                	mov    %edi,%eax
  802061:	75 3d                	jne    8020a0 <__udivdi3+0x60>
  802063:	39 cf                	cmp    %ecx,%edi
  802065:	0f 87 c5 00 00 00    	ja     802130 <__udivdi3+0xf0>
  80206b:	85 ff                	test   %edi,%edi
  80206d:	89 fd                	mov    %edi,%ebp
  80206f:	75 0b                	jne    80207c <__udivdi3+0x3c>
  802071:	b8 01 00 00 00       	mov    $0x1,%eax
  802076:	31 d2                	xor    %edx,%edx
  802078:	f7 f7                	div    %edi
  80207a:	89 c5                	mov    %eax,%ebp
  80207c:	89 c8                	mov    %ecx,%eax
  80207e:	31 d2                	xor    %edx,%edx
  802080:	f7 f5                	div    %ebp
  802082:	89 c1                	mov    %eax,%ecx
  802084:	89 d8                	mov    %ebx,%eax
  802086:	89 cf                	mov    %ecx,%edi
  802088:	f7 f5                	div    %ebp
  80208a:	89 c3                	mov    %eax,%ebx
  80208c:	89 d8                	mov    %ebx,%eax
  80208e:	89 fa                	mov    %edi,%edx
  802090:	83 c4 1c             	add    $0x1c,%esp
  802093:	5b                   	pop    %ebx
  802094:	5e                   	pop    %esi
  802095:	5f                   	pop    %edi
  802096:	5d                   	pop    %ebp
  802097:	c3                   	ret    
  802098:	90                   	nop
  802099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020a0:	39 ce                	cmp    %ecx,%esi
  8020a2:	77 74                	ja     802118 <__udivdi3+0xd8>
  8020a4:	0f bd fe             	bsr    %esi,%edi
  8020a7:	83 f7 1f             	xor    $0x1f,%edi
  8020aa:	0f 84 98 00 00 00    	je     802148 <__udivdi3+0x108>
  8020b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020b5:	89 f9                	mov    %edi,%ecx
  8020b7:	89 c5                	mov    %eax,%ebp
  8020b9:	29 fb                	sub    %edi,%ebx
  8020bb:	d3 e6                	shl    %cl,%esi
  8020bd:	89 d9                	mov    %ebx,%ecx
  8020bf:	d3 ed                	shr    %cl,%ebp
  8020c1:	89 f9                	mov    %edi,%ecx
  8020c3:	d3 e0                	shl    %cl,%eax
  8020c5:	09 ee                	or     %ebp,%esi
  8020c7:	89 d9                	mov    %ebx,%ecx
  8020c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020cd:	89 d5                	mov    %edx,%ebp
  8020cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020d3:	d3 ed                	shr    %cl,%ebp
  8020d5:	89 f9                	mov    %edi,%ecx
  8020d7:	d3 e2                	shl    %cl,%edx
  8020d9:	89 d9                	mov    %ebx,%ecx
  8020db:	d3 e8                	shr    %cl,%eax
  8020dd:	09 c2                	or     %eax,%edx
  8020df:	89 d0                	mov    %edx,%eax
  8020e1:	89 ea                	mov    %ebp,%edx
  8020e3:	f7 f6                	div    %esi
  8020e5:	89 d5                	mov    %edx,%ebp
  8020e7:	89 c3                	mov    %eax,%ebx
  8020e9:	f7 64 24 0c          	mull   0xc(%esp)
  8020ed:	39 d5                	cmp    %edx,%ebp
  8020ef:	72 10                	jb     802101 <__udivdi3+0xc1>
  8020f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020f5:	89 f9                	mov    %edi,%ecx
  8020f7:	d3 e6                	shl    %cl,%esi
  8020f9:	39 c6                	cmp    %eax,%esi
  8020fb:	73 07                	jae    802104 <__udivdi3+0xc4>
  8020fd:	39 d5                	cmp    %edx,%ebp
  8020ff:	75 03                	jne    802104 <__udivdi3+0xc4>
  802101:	83 eb 01             	sub    $0x1,%ebx
  802104:	31 ff                	xor    %edi,%edi
  802106:	89 d8                	mov    %ebx,%eax
  802108:	89 fa                	mov    %edi,%edx
  80210a:	83 c4 1c             	add    $0x1c,%esp
  80210d:	5b                   	pop    %ebx
  80210e:	5e                   	pop    %esi
  80210f:	5f                   	pop    %edi
  802110:	5d                   	pop    %ebp
  802111:	c3                   	ret    
  802112:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802118:	31 ff                	xor    %edi,%edi
  80211a:	31 db                	xor    %ebx,%ebx
  80211c:	89 d8                	mov    %ebx,%eax
  80211e:	89 fa                	mov    %edi,%edx
  802120:	83 c4 1c             	add    $0x1c,%esp
  802123:	5b                   	pop    %ebx
  802124:	5e                   	pop    %esi
  802125:	5f                   	pop    %edi
  802126:	5d                   	pop    %ebp
  802127:	c3                   	ret    
  802128:	90                   	nop
  802129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802130:	89 d8                	mov    %ebx,%eax
  802132:	f7 f7                	div    %edi
  802134:	31 ff                	xor    %edi,%edi
  802136:	89 c3                	mov    %eax,%ebx
  802138:	89 d8                	mov    %ebx,%eax
  80213a:	89 fa                	mov    %edi,%edx
  80213c:	83 c4 1c             	add    $0x1c,%esp
  80213f:	5b                   	pop    %ebx
  802140:	5e                   	pop    %esi
  802141:	5f                   	pop    %edi
  802142:	5d                   	pop    %ebp
  802143:	c3                   	ret    
  802144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802148:	39 ce                	cmp    %ecx,%esi
  80214a:	72 0c                	jb     802158 <__udivdi3+0x118>
  80214c:	31 db                	xor    %ebx,%ebx
  80214e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802152:	0f 87 34 ff ff ff    	ja     80208c <__udivdi3+0x4c>
  802158:	bb 01 00 00 00       	mov    $0x1,%ebx
  80215d:	e9 2a ff ff ff       	jmp    80208c <__udivdi3+0x4c>
  802162:	66 90                	xchg   %ax,%ax
  802164:	66 90                	xchg   %ax,%ax
  802166:	66 90                	xchg   %ax,%ax
  802168:	66 90                	xchg   %ax,%ax
  80216a:	66 90                	xchg   %ax,%ax
  80216c:	66 90                	xchg   %ax,%ax
  80216e:	66 90                	xchg   %ax,%ax

00802170 <__umoddi3>:
  802170:	55                   	push   %ebp
  802171:	57                   	push   %edi
  802172:	56                   	push   %esi
  802173:	53                   	push   %ebx
  802174:	83 ec 1c             	sub    $0x1c,%esp
  802177:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80217b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80217f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802183:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802187:	85 d2                	test   %edx,%edx
  802189:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80218d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802191:	89 f3                	mov    %esi,%ebx
  802193:	89 3c 24             	mov    %edi,(%esp)
  802196:	89 74 24 04          	mov    %esi,0x4(%esp)
  80219a:	75 1c                	jne    8021b8 <__umoddi3+0x48>
  80219c:	39 f7                	cmp    %esi,%edi
  80219e:	76 50                	jbe    8021f0 <__umoddi3+0x80>
  8021a0:	89 c8                	mov    %ecx,%eax
  8021a2:	89 f2                	mov    %esi,%edx
  8021a4:	f7 f7                	div    %edi
  8021a6:	89 d0                	mov    %edx,%eax
  8021a8:	31 d2                	xor    %edx,%edx
  8021aa:	83 c4 1c             	add    $0x1c,%esp
  8021ad:	5b                   	pop    %ebx
  8021ae:	5e                   	pop    %esi
  8021af:	5f                   	pop    %edi
  8021b0:	5d                   	pop    %ebp
  8021b1:	c3                   	ret    
  8021b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021b8:	39 f2                	cmp    %esi,%edx
  8021ba:	89 d0                	mov    %edx,%eax
  8021bc:	77 52                	ja     802210 <__umoddi3+0xa0>
  8021be:	0f bd ea             	bsr    %edx,%ebp
  8021c1:	83 f5 1f             	xor    $0x1f,%ebp
  8021c4:	75 5a                	jne    802220 <__umoddi3+0xb0>
  8021c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021ca:	0f 82 e0 00 00 00    	jb     8022b0 <__umoddi3+0x140>
  8021d0:	39 0c 24             	cmp    %ecx,(%esp)
  8021d3:	0f 86 d7 00 00 00    	jbe    8022b0 <__umoddi3+0x140>
  8021d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021e1:	83 c4 1c             	add    $0x1c,%esp
  8021e4:	5b                   	pop    %ebx
  8021e5:	5e                   	pop    %esi
  8021e6:	5f                   	pop    %edi
  8021e7:	5d                   	pop    %ebp
  8021e8:	c3                   	ret    
  8021e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	85 ff                	test   %edi,%edi
  8021f2:	89 fd                	mov    %edi,%ebp
  8021f4:	75 0b                	jne    802201 <__umoddi3+0x91>
  8021f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021fb:	31 d2                	xor    %edx,%edx
  8021fd:	f7 f7                	div    %edi
  8021ff:	89 c5                	mov    %eax,%ebp
  802201:	89 f0                	mov    %esi,%eax
  802203:	31 d2                	xor    %edx,%edx
  802205:	f7 f5                	div    %ebp
  802207:	89 c8                	mov    %ecx,%eax
  802209:	f7 f5                	div    %ebp
  80220b:	89 d0                	mov    %edx,%eax
  80220d:	eb 99                	jmp    8021a8 <__umoddi3+0x38>
  80220f:	90                   	nop
  802210:	89 c8                	mov    %ecx,%eax
  802212:	89 f2                	mov    %esi,%edx
  802214:	83 c4 1c             	add    $0x1c,%esp
  802217:	5b                   	pop    %ebx
  802218:	5e                   	pop    %esi
  802219:	5f                   	pop    %edi
  80221a:	5d                   	pop    %ebp
  80221b:	c3                   	ret    
  80221c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802220:	8b 34 24             	mov    (%esp),%esi
  802223:	bf 20 00 00 00       	mov    $0x20,%edi
  802228:	89 e9                	mov    %ebp,%ecx
  80222a:	29 ef                	sub    %ebp,%edi
  80222c:	d3 e0                	shl    %cl,%eax
  80222e:	89 f9                	mov    %edi,%ecx
  802230:	89 f2                	mov    %esi,%edx
  802232:	d3 ea                	shr    %cl,%edx
  802234:	89 e9                	mov    %ebp,%ecx
  802236:	09 c2                	or     %eax,%edx
  802238:	89 d8                	mov    %ebx,%eax
  80223a:	89 14 24             	mov    %edx,(%esp)
  80223d:	89 f2                	mov    %esi,%edx
  80223f:	d3 e2                	shl    %cl,%edx
  802241:	89 f9                	mov    %edi,%ecx
  802243:	89 54 24 04          	mov    %edx,0x4(%esp)
  802247:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80224b:	d3 e8                	shr    %cl,%eax
  80224d:	89 e9                	mov    %ebp,%ecx
  80224f:	89 c6                	mov    %eax,%esi
  802251:	d3 e3                	shl    %cl,%ebx
  802253:	89 f9                	mov    %edi,%ecx
  802255:	89 d0                	mov    %edx,%eax
  802257:	d3 e8                	shr    %cl,%eax
  802259:	89 e9                	mov    %ebp,%ecx
  80225b:	09 d8                	or     %ebx,%eax
  80225d:	89 d3                	mov    %edx,%ebx
  80225f:	89 f2                	mov    %esi,%edx
  802261:	f7 34 24             	divl   (%esp)
  802264:	89 d6                	mov    %edx,%esi
  802266:	d3 e3                	shl    %cl,%ebx
  802268:	f7 64 24 04          	mull   0x4(%esp)
  80226c:	39 d6                	cmp    %edx,%esi
  80226e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802272:	89 d1                	mov    %edx,%ecx
  802274:	89 c3                	mov    %eax,%ebx
  802276:	72 08                	jb     802280 <__umoddi3+0x110>
  802278:	75 11                	jne    80228b <__umoddi3+0x11b>
  80227a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80227e:	73 0b                	jae    80228b <__umoddi3+0x11b>
  802280:	2b 44 24 04          	sub    0x4(%esp),%eax
  802284:	1b 14 24             	sbb    (%esp),%edx
  802287:	89 d1                	mov    %edx,%ecx
  802289:	89 c3                	mov    %eax,%ebx
  80228b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80228f:	29 da                	sub    %ebx,%edx
  802291:	19 ce                	sbb    %ecx,%esi
  802293:	89 f9                	mov    %edi,%ecx
  802295:	89 f0                	mov    %esi,%eax
  802297:	d3 e0                	shl    %cl,%eax
  802299:	89 e9                	mov    %ebp,%ecx
  80229b:	d3 ea                	shr    %cl,%edx
  80229d:	89 e9                	mov    %ebp,%ecx
  80229f:	d3 ee                	shr    %cl,%esi
  8022a1:	09 d0                	or     %edx,%eax
  8022a3:	89 f2                	mov    %esi,%edx
  8022a5:	83 c4 1c             	add    $0x1c,%esp
  8022a8:	5b                   	pop    %ebx
  8022a9:	5e                   	pop    %esi
  8022aa:	5f                   	pop    %edi
  8022ab:	5d                   	pop    %ebp
  8022ac:	c3                   	ret    
  8022ad:	8d 76 00             	lea    0x0(%esi),%esi
  8022b0:	29 f9                	sub    %edi,%ecx
  8022b2:	19 d6                	sbb    %edx,%esi
  8022b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022bc:	e9 18 ff ff ff       	jmp    8021d9 <__umoddi3+0x69>
