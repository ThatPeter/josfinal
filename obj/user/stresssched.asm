
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
  8000be:	68 40 25 80 00       	push   $0x802540
  8000c3:	6a 21                	push   $0x21
  8000c5:	68 68 25 80 00       	push   $0x802568
  8000ca:	e8 ad 00 00 00       	call   80017c <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000cf:	a1 08 40 80 00       	mov    0x804008,%eax
  8000d4:	8b 90 b8 00 00 00    	mov    0xb8(%eax),%edx
  8000da:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8000e0:	83 ec 04             	sub    $0x4,%esp
  8000e3:	52                   	push   %edx
  8000e4:	50                   	push   %eax
  8000e5:	68 7b 25 80 00       	push   $0x80257b
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
  800168:	e8 0b 14 00 00       	call   801578 <close_all>
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
  80019a:	68 a4 25 80 00       	push   $0x8025a4
  80019f:	e8 b1 00 00 00       	call   800255 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a4:	83 c4 18             	add    $0x18,%esp
  8001a7:	53                   	push   %ebx
  8001a8:	ff 75 10             	pushl  0x10(%ebp)
  8001ab:	e8 54 00 00 00       	call   800204 <vcprintf>
	cprintf("\n");
  8001b0:	c7 04 24 86 29 80 00 	movl   $0x802986,(%esp)
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
  8002b8:	e8 e3 1f 00 00       	call   8022a0 <__udivdi3>
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
  8002fb:	e8 d0 20 00 00       	call   8023d0 <__umoddi3>
  800300:	83 c4 14             	add    $0x14,%esp
  800303:	0f be 80 c7 25 80 00 	movsbl 0x8025c7(%eax),%eax
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
  8003ff:	ff 24 85 00 27 80 00 	jmp    *0x802700(,%eax,4)
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
  8004c3:	8b 14 85 60 28 80 00 	mov    0x802860(,%eax,4),%edx
  8004ca:	85 d2                	test   %edx,%edx
  8004cc:	75 18                	jne    8004e6 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004ce:	50                   	push   %eax
  8004cf:	68 df 25 80 00       	push   $0x8025df
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
  8004e7:	68 f1 2a 80 00       	push   $0x802af1
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
  80050b:	b8 d8 25 80 00       	mov    $0x8025d8,%eax
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
  800b86:	68 bf 28 80 00       	push   $0x8028bf
  800b8b:	6a 23                	push   $0x23
  800b8d:	68 dc 28 80 00       	push   $0x8028dc
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
  800c07:	68 bf 28 80 00       	push   $0x8028bf
  800c0c:	6a 23                	push   $0x23
  800c0e:	68 dc 28 80 00       	push   $0x8028dc
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
  800c49:	68 bf 28 80 00       	push   $0x8028bf
  800c4e:	6a 23                	push   $0x23
  800c50:	68 dc 28 80 00       	push   $0x8028dc
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
  800c8b:	68 bf 28 80 00       	push   $0x8028bf
  800c90:	6a 23                	push   $0x23
  800c92:	68 dc 28 80 00       	push   $0x8028dc
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
  800ccd:	68 bf 28 80 00       	push   $0x8028bf
  800cd2:	6a 23                	push   $0x23
  800cd4:	68 dc 28 80 00       	push   $0x8028dc
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
  800d0f:	68 bf 28 80 00       	push   $0x8028bf
  800d14:	6a 23                	push   $0x23
  800d16:	68 dc 28 80 00       	push   $0x8028dc
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
  800d51:	68 bf 28 80 00       	push   $0x8028bf
  800d56:	6a 23                	push   $0x23
  800d58:	68 dc 28 80 00       	push   $0x8028dc
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
  800db5:	68 bf 28 80 00       	push   $0x8028bf
  800dba:	6a 23                	push   $0x23
  800dbc:	68 dc 28 80 00       	push   $0x8028dc
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
  800e54:	68 ea 28 80 00       	push   $0x8028ea
  800e59:	6a 1f                	push   $0x1f
  800e5b:	68 fa 28 80 00       	push   $0x8028fa
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
  800e7e:	68 05 29 80 00       	push   $0x802905
  800e83:	6a 2d                	push   $0x2d
  800e85:	68 fa 28 80 00       	push   $0x8028fa
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
  800ec6:	68 05 29 80 00       	push   $0x802905
  800ecb:	6a 34                	push   $0x34
  800ecd:	68 fa 28 80 00       	push   $0x8028fa
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
  800eee:	68 05 29 80 00       	push   $0x802905
  800ef3:	6a 38                	push   $0x38
  800ef5:	68 fa 28 80 00       	push   $0x8028fa
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
  800f12:	e8 92 11 00 00       	call   8020a9 <set_pgfault_handler>
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
  800f2b:	68 1e 29 80 00       	push   $0x80291e
  800f30:	68 85 00 00 00       	push   $0x85
  800f35:	68 fa 28 80 00       	push   $0x8028fa
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
  800fe7:	68 2c 29 80 00       	push   $0x80292c
  800fec:	6a 55                	push   $0x55
  800fee:	68 fa 28 80 00       	push   $0x8028fa
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
  80102c:	68 2c 29 80 00       	push   $0x80292c
  801031:	6a 5c                	push   $0x5c
  801033:	68 fa 28 80 00       	push   $0x8028fa
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
  80105a:	68 2c 29 80 00       	push   $0x80292c
  80105f:	6a 60                	push   $0x60
  801061:	68 fa 28 80 00       	push   $0x8028fa
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
  801084:	68 2c 29 80 00       	push   $0x80292c
  801089:	6a 65                	push   $0x65
  80108b:	68 fa 28 80 00       	push   $0x8028fa
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
  8010f3:	68 bc 29 80 00       	push   $0x8029bc
  8010f8:	e8 58 f1 ff ff       	call   800255 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8010fd:	c7 04 24 42 01 80 00 	movl   $0x800142,(%esp)
  801104:	e8 c5 fc ff ff       	call   800dce <sys_thread_create>
  801109:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80110b:	83 c4 08             	add    $0x8,%esp
  80110e:	53                   	push   %ebx
  80110f:	68 bc 29 80 00       	push   $0x8029bc
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

00801148 <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  801148:	55                   	push   %ebp
  801149:	89 e5                	mov    %esp,%ebp
  80114b:	56                   	push   %esi
  80114c:	53                   	push   %ebx
  80114d:	8b 75 08             	mov    0x8(%ebp),%esi
  801150:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  801153:	83 ec 04             	sub    $0x4,%esp
  801156:	6a 07                	push   $0x7
  801158:	6a 00                	push   $0x0
  80115a:	56                   	push   %esi
  80115b:	e8 7d fa ff ff       	call   800bdd <sys_page_alloc>
	if (r < 0) {
  801160:	83 c4 10             	add    $0x10,%esp
  801163:	85 c0                	test   %eax,%eax
  801165:	79 15                	jns    80117c <queue_append+0x34>
		panic("%e\n", r);
  801167:	50                   	push   %eax
  801168:	68 b8 29 80 00       	push   $0x8029b8
  80116d:	68 c4 00 00 00       	push   $0xc4
  801172:	68 fa 28 80 00       	push   $0x8028fa
  801177:	e8 00 f0 ff ff       	call   80017c <_panic>
	}	
	wt->envid = envid;
  80117c:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  801182:	83 ec 04             	sub    $0x4,%esp
  801185:	ff 33                	pushl  (%ebx)
  801187:	56                   	push   %esi
  801188:	68 e0 29 80 00       	push   $0x8029e0
  80118d:	e8 c3 f0 ff ff       	call   800255 <cprintf>
	if (queue->first == NULL) {
  801192:	83 c4 10             	add    $0x10,%esp
  801195:	83 3b 00             	cmpl   $0x0,(%ebx)
  801198:	75 29                	jne    8011c3 <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  80119a:	83 ec 0c             	sub    $0xc,%esp
  80119d:	68 42 29 80 00       	push   $0x802942
  8011a2:	e8 ae f0 ff ff       	call   800255 <cprintf>
		queue->first = wt;
  8011a7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  8011ad:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  8011b4:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8011bb:	00 00 00 
  8011be:	83 c4 10             	add    $0x10,%esp
  8011c1:	eb 2b                	jmp    8011ee <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  8011c3:	83 ec 0c             	sub    $0xc,%esp
  8011c6:	68 5c 29 80 00       	push   $0x80295c
  8011cb:	e8 85 f0 ff ff       	call   800255 <cprintf>
		queue->last->next = wt;
  8011d0:	8b 43 04             	mov    0x4(%ebx),%eax
  8011d3:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  8011da:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8011e1:	00 00 00 
		queue->last = wt;
  8011e4:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  8011eb:	83 c4 10             	add    $0x10,%esp
	}
}
  8011ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011f1:	5b                   	pop    %ebx
  8011f2:	5e                   	pop    %esi
  8011f3:	5d                   	pop    %ebp
  8011f4:	c3                   	ret    

008011f5 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  8011f5:	55                   	push   %ebp
  8011f6:	89 e5                	mov    %esp,%ebp
  8011f8:	53                   	push   %ebx
  8011f9:	83 ec 04             	sub    $0x4,%esp
  8011fc:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  8011ff:	8b 02                	mov    (%edx),%eax
  801201:	85 c0                	test   %eax,%eax
  801203:	75 17                	jne    80121c <queue_pop+0x27>
		panic("queue empty!\n");
  801205:	83 ec 04             	sub    $0x4,%esp
  801208:	68 7a 29 80 00       	push   $0x80297a
  80120d:	68 d8 00 00 00       	push   $0xd8
  801212:	68 fa 28 80 00       	push   $0x8028fa
  801217:	e8 60 ef ff ff       	call   80017c <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  80121c:	8b 48 04             	mov    0x4(%eax),%ecx
  80121f:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  801221:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  801223:	83 ec 08             	sub    $0x8,%esp
  801226:	53                   	push   %ebx
  801227:	68 88 29 80 00       	push   $0x802988
  80122c:	e8 24 f0 ff ff       	call   800255 <cprintf>
	return envid;
}
  801231:	89 d8                	mov    %ebx,%eax
  801233:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801236:	c9                   	leave  
  801237:	c3                   	ret    

00801238 <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	53                   	push   %ebx
  80123c:	83 ec 04             	sub    $0x4,%esp
  80123f:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801242:	b8 01 00 00 00       	mov    $0x1,%eax
  801247:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  80124a:	85 c0                	test   %eax,%eax
  80124c:	74 5a                	je     8012a8 <mutex_lock+0x70>
  80124e:	8b 43 04             	mov    0x4(%ebx),%eax
  801251:	83 38 00             	cmpl   $0x0,(%eax)
  801254:	75 52                	jne    8012a8 <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  801256:	83 ec 0c             	sub    $0xc,%esp
  801259:	68 08 2a 80 00       	push   $0x802a08
  80125e:	e8 f2 ef ff ff       	call   800255 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  801263:	8b 5b 04             	mov    0x4(%ebx),%ebx
  801266:	e8 34 f9 ff ff       	call   800b9f <sys_getenvid>
  80126b:	83 c4 08             	add    $0x8,%esp
  80126e:	53                   	push   %ebx
  80126f:	50                   	push   %eax
  801270:	e8 d3 fe ff ff       	call   801148 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  801275:	e8 25 f9 ff ff       	call   800b9f <sys_getenvid>
  80127a:	83 c4 08             	add    $0x8,%esp
  80127d:	6a 04                	push   $0x4
  80127f:	50                   	push   %eax
  801280:	e8 1f fa ff ff       	call   800ca4 <sys_env_set_status>
		if (r < 0) {
  801285:	83 c4 10             	add    $0x10,%esp
  801288:	85 c0                	test   %eax,%eax
  80128a:	79 15                	jns    8012a1 <mutex_lock+0x69>
			panic("%e\n", r);
  80128c:	50                   	push   %eax
  80128d:	68 b8 29 80 00       	push   $0x8029b8
  801292:	68 eb 00 00 00       	push   $0xeb
  801297:	68 fa 28 80 00       	push   $0x8028fa
  80129c:	e8 db ee ff ff       	call   80017c <_panic>
		}
		sys_yield();
  8012a1:	e8 18 f9 ff ff       	call   800bbe <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8012a6:	eb 18                	jmp    8012c0 <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  8012a8:	83 ec 0c             	sub    $0xc,%esp
  8012ab:	68 28 2a 80 00       	push   $0x802a28
  8012b0:	e8 a0 ef ff ff       	call   800255 <cprintf>
	mtx->owner = sys_getenvid();}
  8012b5:	e8 e5 f8 ff ff       	call   800b9f <sys_getenvid>
  8012ba:	89 43 08             	mov    %eax,0x8(%ebx)
  8012bd:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  8012c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c3:	c9                   	leave  
  8012c4:	c3                   	ret    

008012c5 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  8012c5:	55                   	push   %ebp
  8012c6:	89 e5                	mov    %esp,%ebp
  8012c8:	53                   	push   %ebx
  8012c9:	83 ec 04             	sub    $0x4,%esp
  8012cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d4:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  8012d7:	8b 43 04             	mov    0x4(%ebx),%eax
  8012da:	83 38 00             	cmpl   $0x0,(%eax)
  8012dd:	74 33                	je     801312 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  8012df:	83 ec 0c             	sub    $0xc,%esp
  8012e2:	50                   	push   %eax
  8012e3:	e8 0d ff ff ff       	call   8011f5 <queue_pop>
  8012e8:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8012eb:	83 c4 08             	add    $0x8,%esp
  8012ee:	6a 02                	push   $0x2
  8012f0:	50                   	push   %eax
  8012f1:	e8 ae f9 ff ff       	call   800ca4 <sys_env_set_status>
		if (r < 0) {
  8012f6:	83 c4 10             	add    $0x10,%esp
  8012f9:	85 c0                	test   %eax,%eax
  8012fb:	79 15                	jns    801312 <mutex_unlock+0x4d>
			panic("%e\n", r);
  8012fd:	50                   	push   %eax
  8012fe:	68 b8 29 80 00       	push   $0x8029b8
  801303:	68 00 01 00 00       	push   $0x100
  801308:	68 fa 28 80 00       	push   $0x8028fa
  80130d:	e8 6a ee ff ff       	call   80017c <_panic>
		}
	}

	asm volatile("pause");
  801312:	f3 90                	pause  
	//sys_yield();
}
  801314:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801317:	c9                   	leave  
  801318:	c3                   	ret    

00801319 <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  801319:	55                   	push   %ebp
  80131a:	89 e5                	mov    %esp,%ebp
  80131c:	53                   	push   %ebx
  80131d:	83 ec 04             	sub    $0x4,%esp
  801320:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  801323:	e8 77 f8 ff ff       	call   800b9f <sys_getenvid>
  801328:	83 ec 04             	sub    $0x4,%esp
  80132b:	6a 07                	push   $0x7
  80132d:	53                   	push   %ebx
  80132e:	50                   	push   %eax
  80132f:	e8 a9 f8 ff ff       	call   800bdd <sys_page_alloc>
  801334:	83 c4 10             	add    $0x10,%esp
  801337:	85 c0                	test   %eax,%eax
  801339:	79 15                	jns    801350 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  80133b:	50                   	push   %eax
  80133c:	68 a3 29 80 00       	push   $0x8029a3
  801341:	68 0d 01 00 00       	push   $0x10d
  801346:	68 fa 28 80 00       	push   $0x8028fa
  80134b:	e8 2c ee ff ff       	call   80017c <_panic>
	}	
	mtx->locked = 0;
  801350:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  801356:	8b 43 04             	mov    0x4(%ebx),%eax
  801359:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  80135f:	8b 43 04             	mov    0x4(%ebx),%eax
  801362:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  801369:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  801370:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801373:	c9                   	leave  
  801374:	c3                   	ret    

00801375 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  801375:	55                   	push   %ebp
  801376:	89 e5                	mov    %esp,%ebp
  801378:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  80137b:	e8 1f f8 ff ff       	call   800b9f <sys_getenvid>
  801380:	83 ec 08             	sub    $0x8,%esp
  801383:	ff 75 08             	pushl  0x8(%ebp)
  801386:	50                   	push   %eax
  801387:	e8 d6 f8 ff ff       	call   800c62 <sys_page_unmap>
	if (r < 0) {
  80138c:	83 c4 10             	add    $0x10,%esp
  80138f:	85 c0                	test   %eax,%eax
  801391:	79 15                	jns    8013a8 <mutex_destroy+0x33>
		panic("%e\n", r);
  801393:	50                   	push   %eax
  801394:	68 b8 29 80 00       	push   $0x8029b8
  801399:	68 1a 01 00 00       	push   $0x11a
  80139e:	68 fa 28 80 00       	push   $0x8028fa
  8013a3:	e8 d4 ed ff ff       	call   80017c <_panic>
	}
}
  8013a8:	c9                   	leave  
  8013a9:	c3                   	ret    

008013aa <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013aa:	55                   	push   %ebp
  8013ab:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b0:	05 00 00 00 30       	add    $0x30000000,%eax
  8013b5:	c1 e8 0c             	shr    $0xc,%eax
}
  8013b8:	5d                   	pop    %ebp
  8013b9:	c3                   	ret    

008013ba <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013ba:	55                   	push   %ebp
  8013bb:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8013bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c0:	05 00 00 00 30       	add    $0x30000000,%eax
  8013c5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013ca:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013cf:	5d                   	pop    %ebp
  8013d0:	c3                   	ret    

008013d1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013d1:	55                   	push   %ebp
  8013d2:	89 e5                	mov    %esp,%ebp
  8013d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013d7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013dc:	89 c2                	mov    %eax,%edx
  8013de:	c1 ea 16             	shr    $0x16,%edx
  8013e1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013e8:	f6 c2 01             	test   $0x1,%dl
  8013eb:	74 11                	je     8013fe <fd_alloc+0x2d>
  8013ed:	89 c2                	mov    %eax,%edx
  8013ef:	c1 ea 0c             	shr    $0xc,%edx
  8013f2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013f9:	f6 c2 01             	test   $0x1,%dl
  8013fc:	75 09                	jne    801407 <fd_alloc+0x36>
			*fd_store = fd;
  8013fe:	89 01                	mov    %eax,(%ecx)
			return 0;
  801400:	b8 00 00 00 00       	mov    $0x0,%eax
  801405:	eb 17                	jmp    80141e <fd_alloc+0x4d>
  801407:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80140c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801411:	75 c9                	jne    8013dc <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801413:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801419:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80141e:	5d                   	pop    %ebp
  80141f:	c3                   	ret    

00801420 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801426:	83 f8 1f             	cmp    $0x1f,%eax
  801429:	77 36                	ja     801461 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80142b:	c1 e0 0c             	shl    $0xc,%eax
  80142e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801433:	89 c2                	mov    %eax,%edx
  801435:	c1 ea 16             	shr    $0x16,%edx
  801438:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80143f:	f6 c2 01             	test   $0x1,%dl
  801442:	74 24                	je     801468 <fd_lookup+0x48>
  801444:	89 c2                	mov    %eax,%edx
  801446:	c1 ea 0c             	shr    $0xc,%edx
  801449:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801450:	f6 c2 01             	test   $0x1,%dl
  801453:	74 1a                	je     80146f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801455:	8b 55 0c             	mov    0xc(%ebp),%edx
  801458:	89 02                	mov    %eax,(%edx)
	return 0;
  80145a:	b8 00 00 00 00       	mov    $0x0,%eax
  80145f:	eb 13                	jmp    801474 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801461:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801466:	eb 0c                	jmp    801474 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801468:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80146d:	eb 05                	jmp    801474 <fd_lookup+0x54>
  80146f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801474:	5d                   	pop    %ebp
  801475:	c3                   	ret    

00801476 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801476:	55                   	push   %ebp
  801477:	89 e5                	mov    %esp,%ebp
  801479:	83 ec 08             	sub    $0x8,%esp
  80147c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80147f:	ba c8 2a 80 00       	mov    $0x802ac8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801484:	eb 13                	jmp    801499 <dev_lookup+0x23>
  801486:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801489:	39 08                	cmp    %ecx,(%eax)
  80148b:	75 0c                	jne    801499 <dev_lookup+0x23>
			*dev = devtab[i];
  80148d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801490:	89 01                	mov    %eax,(%ecx)
			return 0;
  801492:	b8 00 00 00 00       	mov    $0x0,%eax
  801497:	eb 31                	jmp    8014ca <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801499:	8b 02                	mov    (%edx),%eax
  80149b:	85 c0                	test   %eax,%eax
  80149d:	75 e7                	jne    801486 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80149f:	a1 08 40 80 00       	mov    0x804008,%eax
  8014a4:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8014aa:	83 ec 04             	sub    $0x4,%esp
  8014ad:	51                   	push   %ecx
  8014ae:	50                   	push   %eax
  8014af:	68 48 2a 80 00       	push   $0x802a48
  8014b4:	e8 9c ed ff ff       	call   800255 <cprintf>
	*dev = 0;
  8014b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014bc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014c2:	83 c4 10             	add    $0x10,%esp
  8014c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014ca:	c9                   	leave  
  8014cb:	c3                   	ret    

008014cc <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	56                   	push   %esi
  8014d0:	53                   	push   %ebx
  8014d1:	83 ec 10             	sub    $0x10,%esp
  8014d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8014d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014dd:	50                   	push   %eax
  8014de:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014e4:	c1 e8 0c             	shr    $0xc,%eax
  8014e7:	50                   	push   %eax
  8014e8:	e8 33 ff ff ff       	call   801420 <fd_lookup>
  8014ed:	83 c4 08             	add    $0x8,%esp
  8014f0:	85 c0                	test   %eax,%eax
  8014f2:	78 05                	js     8014f9 <fd_close+0x2d>
	    || fd != fd2)
  8014f4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014f7:	74 0c                	je     801505 <fd_close+0x39>
		return (must_exist ? r : 0);
  8014f9:	84 db                	test   %bl,%bl
  8014fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801500:	0f 44 c2             	cmove  %edx,%eax
  801503:	eb 41                	jmp    801546 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801505:	83 ec 08             	sub    $0x8,%esp
  801508:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80150b:	50                   	push   %eax
  80150c:	ff 36                	pushl  (%esi)
  80150e:	e8 63 ff ff ff       	call   801476 <dev_lookup>
  801513:	89 c3                	mov    %eax,%ebx
  801515:	83 c4 10             	add    $0x10,%esp
  801518:	85 c0                	test   %eax,%eax
  80151a:	78 1a                	js     801536 <fd_close+0x6a>
		if (dev->dev_close)
  80151c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801522:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801527:	85 c0                	test   %eax,%eax
  801529:	74 0b                	je     801536 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80152b:	83 ec 0c             	sub    $0xc,%esp
  80152e:	56                   	push   %esi
  80152f:	ff d0                	call   *%eax
  801531:	89 c3                	mov    %eax,%ebx
  801533:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801536:	83 ec 08             	sub    $0x8,%esp
  801539:	56                   	push   %esi
  80153a:	6a 00                	push   $0x0
  80153c:	e8 21 f7 ff ff       	call   800c62 <sys_page_unmap>
	return r;
  801541:	83 c4 10             	add    $0x10,%esp
  801544:	89 d8                	mov    %ebx,%eax
}
  801546:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801549:	5b                   	pop    %ebx
  80154a:	5e                   	pop    %esi
  80154b:	5d                   	pop    %ebp
  80154c:	c3                   	ret    

0080154d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80154d:	55                   	push   %ebp
  80154e:	89 e5                	mov    %esp,%ebp
  801550:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801553:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801556:	50                   	push   %eax
  801557:	ff 75 08             	pushl  0x8(%ebp)
  80155a:	e8 c1 fe ff ff       	call   801420 <fd_lookup>
  80155f:	83 c4 08             	add    $0x8,%esp
  801562:	85 c0                	test   %eax,%eax
  801564:	78 10                	js     801576 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801566:	83 ec 08             	sub    $0x8,%esp
  801569:	6a 01                	push   $0x1
  80156b:	ff 75 f4             	pushl  -0xc(%ebp)
  80156e:	e8 59 ff ff ff       	call   8014cc <fd_close>
  801573:	83 c4 10             	add    $0x10,%esp
}
  801576:	c9                   	leave  
  801577:	c3                   	ret    

00801578 <close_all>:

void
close_all(void)
{
  801578:	55                   	push   %ebp
  801579:	89 e5                	mov    %esp,%ebp
  80157b:	53                   	push   %ebx
  80157c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80157f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801584:	83 ec 0c             	sub    $0xc,%esp
  801587:	53                   	push   %ebx
  801588:	e8 c0 ff ff ff       	call   80154d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80158d:	83 c3 01             	add    $0x1,%ebx
  801590:	83 c4 10             	add    $0x10,%esp
  801593:	83 fb 20             	cmp    $0x20,%ebx
  801596:	75 ec                	jne    801584 <close_all+0xc>
		close(i);
}
  801598:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159b:	c9                   	leave  
  80159c:	c3                   	ret    

0080159d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80159d:	55                   	push   %ebp
  80159e:	89 e5                	mov    %esp,%ebp
  8015a0:	57                   	push   %edi
  8015a1:	56                   	push   %esi
  8015a2:	53                   	push   %ebx
  8015a3:	83 ec 2c             	sub    $0x2c,%esp
  8015a6:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015a9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015ac:	50                   	push   %eax
  8015ad:	ff 75 08             	pushl  0x8(%ebp)
  8015b0:	e8 6b fe ff ff       	call   801420 <fd_lookup>
  8015b5:	83 c4 08             	add    $0x8,%esp
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	0f 88 c1 00 00 00    	js     801681 <dup+0xe4>
		return r;
	close(newfdnum);
  8015c0:	83 ec 0c             	sub    $0xc,%esp
  8015c3:	56                   	push   %esi
  8015c4:	e8 84 ff ff ff       	call   80154d <close>

	newfd = INDEX2FD(newfdnum);
  8015c9:	89 f3                	mov    %esi,%ebx
  8015cb:	c1 e3 0c             	shl    $0xc,%ebx
  8015ce:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8015d4:	83 c4 04             	add    $0x4,%esp
  8015d7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015da:	e8 db fd ff ff       	call   8013ba <fd2data>
  8015df:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8015e1:	89 1c 24             	mov    %ebx,(%esp)
  8015e4:	e8 d1 fd ff ff       	call   8013ba <fd2data>
  8015e9:	83 c4 10             	add    $0x10,%esp
  8015ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015ef:	89 f8                	mov    %edi,%eax
  8015f1:	c1 e8 16             	shr    $0x16,%eax
  8015f4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015fb:	a8 01                	test   $0x1,%al
  8015fd:	74 37                	je     801636 <dup+0x99>
  8015ff:	89 f8                	mov    %edi,%eax
  801601:	c1 e8 0c             	shr    $0xc,%eax
  801604:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80160b:	f6 c2 01             	test   $0x1,%dl
  80160e:	74 26                	je     801636 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801610:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801617:	83 ec 0c             	sub    $0xc,%esp
  80161a:	25 07 0e 00 00       	and    $0xe07,%eax
  80161f:	50                   	push   %eax
  801620:	ff 75 d4             	pushl  -0x2c(%ebp)
  801623:	6a 00                	push   $0x0
  801625:	57                   	push   %edi
  801626:	6a 00                	push   $0x0
  801628:	e8 f3 f5 ff ff       	call   800c20 <sys_page_map>
  80162d:	89 c7                	mov    %eax,%edi
  80162f:	83 c4 20             	add    $0x20,%esp
  801632:	85 c0                	test   %eax,%eax
  801634:	78 2e                	js     801664 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801636:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801639:	89 d0                	mov    %edx,%eax
  80163b:	c1 e8 0c             	shr    $0xc,%eax
  80163e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801645:	83 ec 0c             	sub    $0xc,%esp
  801648:	25 07 0e 00 00       	and    $0xe07,%eax
  80164d:	50                   	push   %eax
  80164e:	53                   	push   %ebx
  80164f:	6a 00                	push   $0x0
  801651:	52                   	push   %edx
  801652:	6a 00                	push   $0x0
  801654:	e8 c7 f5 ff ff       	call   800c20 <sys_page_map>
  801659:	89 c7                	mov    %eax,%edi
  80165b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80165e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801660:	85 ff                	test   %edi,%edi
  801662:	79 1d                	jns    801681 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801664:	83 ec 08             	sub    $0x8,%esp
  801667:	53                   	push   %ebx
  801668:	6a 00                	push   $0x0
  80166a:	e8 f3 f5 ff ff       	call   800c62 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80166f:	83 c4 08             	add    $0x8,%esp
  801672:	ff 75 d4             	pushl  -0x2c(%ebp)
  801675:	6a 00                	push   $0x0
  801677:	e8 e6 f5 ff ff       	call   800c62 <sys_page_unmap>
	return r;
  80167c:	83 c4 10             	add    $0x10,%esp
  80167f:	89 f8                	mov    %edi,%eax
}
  801681:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801684:	5b                   	pop    %ebx
  801685:	5e                   	pop    %esi
  801686:	5f                   	pop    %edi
  801687:	5d                   	pop    %ebp
  801688:	c3                   	ret    

00801689 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801689:	55                   	push   %ebp
  80168a:	89 e5                	mov    %esp,%ebp
  80168c:	53                   	push   %ebx
  80168d:	83 ec 14             	sub    $0x14,%esp
  801690:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801693:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801696:	50                   	push   %eax
  801697:	53                   	push   %ebx
  801698:	e8 83 fd ff ff       	call   801420 <fd_lookup>
  80169d:	83 c4 08             	add    $0x8,%esp
  8016a0:	89 c2                	mov    %eax,%edx
  8016a2:	85 c0                	test   %eax,%eax
  8016a4:	78 70                	js     801716 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a6:	83 ec 08             	sub    $0x8,%esp
  8016a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ac:	50                   	push   %eax
  8016ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b0:	ff 30                	pushl  (%eax)
  8016b2:	e8 bf fd ff ff       	call   801476 <dev_lookup>
  8016b7:	83 c4 10             	add    $0x10,%esp
  8016ba:	85 c0                	test   %eax,%eax
  8016bc:	78 4f                	js     80170d <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016be:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016c1:	8b 42 08             	mov    0x8(%edx),%eax
  8016c4:	83 e0 03             	and    $0x3,%eax
  8016c7:	83 f8 01             	cmp    $0x1,%eax
  8016ca:	75 24                	jne    8016f0 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016cc:	a1 08 40 80 00       	mov    0x804008,%eax
  8016d1:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8016d7:	83 ec 04             	sub    $0x4,%esp
  8016da:	53                   	push   %ebx
  8016db:	50                   	push   %eax
  8016dc:	68 8c 2a 80 00       	push   $0x802a8c
  8016e1:	e8 6f eb ff ff       	call   800255 <cprintf>
		return -E_INVAL;
  8016e6:	83 c4 10             	add    $0x10,%esp
  8016e9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016ee:	eb 26                	jmp    801716 <read+0x8d>
	}
	if (!dev->dev_read)
  8016f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016f3:	8b 40 08             	mov    0x8(%eax),%eax
  8016f6:	85 c0                	test   %eax,%eax
  8016f8:	74 17                	je     801711 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8016fa:	83 ec 04             	sub    $0x4,%esp
  8016fd:	ff 75 10             	pushl  0x10(%ebp)
  801700:	ff 75 0c             	pushl  0xc(%ebp)
  801703:	52                   	push   %edx
  801704:	ff d0                	call   *%eax
  801706:	89 c2                	mov    %eax,%edx
  801708:	83 c4 10             	add    $0x10,%esp
  80170b:	eb 09                	jmp    801716 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80170d:	89 c2                	mov    %eax,%edx
  80170f:	eb 05                	jmp    801716 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801711:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801716:	89 d0                	mov    %edx,%eax
  801718:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171b:	c9                   	leave  
  80171c:	c3                   	ret    

0080171d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	57                   	push   %edi
  801721:	56                   	push   %esi
  801722:	53                   	push   %ebx
  801723:	83 ec 0c             	sub    $0xc,%esp
  801726:	8b 7d 08             	mov    0x8(%ebp),%edi
  801729:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80172c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801731:	eb 21                	jmp    801754 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801733:	83 ec 04             	sub    $0x4,%esp
  801736:	89 f0                	mov    %esi,%eax
  801738:	29 d8                	sub    %ebx,%eax
  80173a:	50                   	push   %eax
  80173b:	89 d8                	mov    %ebx,%eax
  80173d:	03 45 0c             	add    0xc(%ebp),%eax
  801740:	50                   	push   %eax
  801741:	57                   	push   %edi
  801742:	e8 42 ff ff ff       	call   801689 <read>
		if (m < 0)
  801747:	83 c4 10             	add    $0x10,%esp
  80174a:	85 c0                	test   %eax,%eax
  80174c:	78 10                	js     80175e <readn+0x41>
			return m;
		if (m == 0)
  80174e:	85 c0                	test   %eax,%eax
  801750:	74 0a                	je     80175c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801752:	01 c3                	add    %eax,%ebx
  801754:	39 f3                	cmp    %esi,%ebx
  801756:	72 db                	jb     801733 <readn+0x16>
  801758:	89 d8                	mov    %ebx,%eax
  80175a:	eb 02                	jmp    80175e <readn+0x41>
  80175c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80175e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801761:	5b                   	pop    %ebx
  801762:	5e                   	pop    %esi
  801763:	5f                   	pop    %edi
  801764:	5d                   	pop    %ebp
  801765:	c3                   	ret    

00801766 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801766:	55                   	push   %ebp
  801767:	89 e5                	mov    %esp,%ebp
  801769:	53                   	push   %ebx
  80176a:	83 ec 14             	sub    $0x14,%esp
  80176d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801770:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801773:	50                   	push   %eax
  801774:	53                   	push   %ebx
  801775:	e8 a6 fc ff ff       	call   801420 <fd_lookup>
  80177a:	83 c4 08             	add    $0x8,%esp
  80177d:	89 c2                	mov    %eax,%edx
  80177f:	85 c0                	test   %eax,%eax
  801781:	78 6b                	js     8017ee <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801783:	83 ec 08             	sub    $0x8,%esp
  801786:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801789:	50                   	push   %eax
  80178a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80178d:	ff 30                	pushl  (%eax)
  80178f:	e8 e2 fc ff ff       	call   801476 <dev_lookup>
  801794:	83 c4 10             	add    $0x10,%esp
  801797:	85 c0                	test   %eax,%eax
  801799:	78 4a                	js     8017e5 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80179b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80179e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017a2:	75 24                	jne    8017c8 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017a4:	a1 08 40 80 00       	mov    0x804008,%eax
  8017a9:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8017af:	83 ec 04             	sub    $0x4,%esp
  8017b2:	53                   	push   %ebx
  8017b3:	50                   	push   %eax
  8017b4:	68 a8 2a 80 00       	push   $0x802aa8
  8017b9:	e8 97 ea ff ff       	call   800255 <cprintf>
		return -E_INVAL;
  8017be:	83 c4 10             	add    $0x10,%esp
  8017c1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017c6:	eb 26                	jmp    8017ee <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017cb:	8b 52 0c             	mov    0xc(%edx),%edx
  8017ce:	85 d2                	test   %edx,%edx
  8017d0:	74 17                	je     8017e9 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017d2:	83 ec 04             	sub    $0x4,%esp
  8017d5:	ff 75 10             	pushl  0x10(%ebp)
  8017d8:	ff 75 0c             	pushl  0xc(%ebp)
  8017db:	50                   	push   %eax
  8017dc:	ff d2                	call   *%edx
  8017de:	89 c2                	mov    %eax,%edx
  8017e0:	83 c4 10             	add    $0x10,%esp
  8017e3:	eb 09                	jmp    8017ee <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e5:	89 c2                	mov    %eax,%edx
  8017e7:	eb 05                	jmp    8017ee <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017e9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8017ee:	89 d0                	mov    %edx,%eax
  8017f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f3:	c9                   	leave  
  8017f4:	c3                   	ret    

008017f5 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017f5:	55                   	push   %ebp
  8017f6:	89 e5                	mov    %esp,%ebp
  8017f8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017fb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017fe:	50                   	push   %eax
  8017ff:	ff 75 08             	pushl  0x8(%ebp)
  801802:	e8 19 fc ff ff       	call   801420 <fd_lookup>
  801807:	83 c4 08             	add    $0x8,%esp
  80180a:	85 c0                	test   %eax,%eax
  80180c:	78 0e                	js     80181c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80180e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801811:	8b 55 0c             	mov    0xc(%ebp),%edx
  801814:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801817:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80181c:	c9                   	leave  
  80181d:	c3                   	ret    

0080181e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80181e:	55                   	push   %ebp
  80181f:	89 e5                	mov    %esp,%ebp
  801821:	53                   	push   %ebx
  801822:	83 ec 14             	sub    $0x14,%esp
  801825:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801828:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80182b:	50                   	push   %eax
  80182c:	53                   	push   %ebx
  80182d:	e8 ee fb ff ff       	call   801420 <fd_lookup>
  801832:	83 c4 08             	add    $0x8,%esp
  801835:	89 c2                	mov    %eax,%edx
  801837:	85 c0                	test   %eax,%eax
  801839:	78 68                	js     8018a3 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80183b:	83 ec 08             	sub    $0x8,%esp
  80183e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801841:	50                   	push   %eax
  801842:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801845:	ff 30                	pushl  (%eax)
  801847:	e8 2a fc ff ff       	call   801476 <dev_lookup>
  80184c:	83 c4 10             	add    $0x10,%esp
  80184f:	85 c0                	test   %eax,%eax
  801851:	78 47                	js     80189a <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801853:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801856:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80185a:	75 24                	jne    801880 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80185c:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801861:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801867:	83 ec 04             	sub    $0x4,%esp
  80186a:	53                   	push   %ebx
  80186b:	50                   	push   %eax
  80186c:	68 68 2a 80 00       	push   $0x802a68
  801871:	e8 df e9 ff ff       	call   800255 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801876:	83 c4 10             	add    $0x10,%esp
  801879:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80187e:	eb 23                	jmp    8018a3 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801880:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801883:	8b 52 18             	mov    0x18(%edx),%edx
  801886:	85 d2                	test   %edx,%edx
  801888:	74 14                	je     80189e <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80188a:	83 ec 08             	sub    $0x8,%esp
  80188d:	ff 75 0c             	pushl  0xc(%ebp)
  801890:	50                   	push   %eax
  801891:	ff d2                	call   *%edx
  801893:	89 c2                	mov    %eax,%edx
  801895:	83 c4 10             	add    $0x10,%esp
  801898:	eb 09                	jmp    8018a3 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80189a:	89 c2                	mov    %eax,%edx
  80189c:	eb 05                	jmp    8018a3 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80189e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8018a3:	89 d0                	mov    %edx,%eax
  8018a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a8:	c9                   	leave  
  8018a9:	c3                   	ret    

008018aa <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018aa:	55                   	push   %ebp
  8018ab:	89 e5                	mov    %esp,%ebp
  8018ad:	53                   	push   %ebx
  8018ae:	83 ec 14             	sub    $0x14,%esp
  8018b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018b7:	50                   	push   %eax
  8018b8:	ff 75 08             	pushl  0x8(%ebp)
  8018bb:	e8 60 fb ff ff       	call   801420 <fd_lookup>
  8018c0:	83 c4 08             	add    $0x8,%esp
  8018c3:	89 c2                	mov    %eax,%edx
  8018c5:	85 c0                	test   %eax,%eax
  8018c7:	78 58                	js     801921 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018c9:	83 ec 08             	sub    $0x8,%esp
  8018cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018cf:	50                   	push   %eax
  8018d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d3:	ff 30                	pushl  (%eax)
  8018d5:	e8 9c fb ff ff       	call   801476 <dev_lookup>
  8018da:	83 c4 10             	add    $0x10,%esp
  8018dd:	85 c0                	test   %eax,%eax
  8018df:	78 37                	js     801918 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8018e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018e8:	74 32                	je     80191c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018ea:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018ed:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018f4:	00 00 00 
	stat->st_isdir = 0;
  8018f7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018fe:	00 00 00 
	stat->st_dev = dev;
  801901:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801907:	83 ec 08             	sub    $0x8,%esp
  80190a:	53                   	push   %ebx
  80190b:	ff 75 f0             	pushl  -0x10(%ebp)
  80190e:	ff 50 14             	call   *0x14(%eax)
  801911:	89 c2                	mov    %eax,%edx
  801913:	83 c4 10             	add    $0x10,%esp
  801916:	eb 09                	jmp    801921 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801918:	89 c2                	mov    %eax,%edx
  80191a:	eb 05                	jmp    801921 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80191c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801921:	89 d0                	mov    %edx,%eax
  801923:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801926:	c9                   	leave  
  801927:	c3                   	ret    

00801928 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801928:	55                   	push   %ebp
  801929:	89 e5                	mov    %esp,%ebp
  80192b:	56                   	push   %esi
  80192c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80192d:	83 ec 08             	sub    $0x8,%esp
  801930:	6a 00                	push   $0x0
  801932:	ff 75 08             	pushl  0x8(%ebp)
  801935:	e8 e3 01 00 00       	call   801b1d <open>
  80193a:	89 c3                	mov    %eax,%ebx
  80193c:	83 c4 10             	add    $0x10,%esp
  80193f:	85 c0                	test   %eax,%eax
  801941:	78 1b                	js     80195e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801943:	83 ec 08             	sub    $0x8,%esp
  801946:	ff 75 0c             	pushl  0xc(%ebp)
  801949:	50                   	push   %eax
  80194a:	e8 5b ff ff ff       	call   8018aa <fstat>
  80194f:	89 c6                	mov    %eax,%esi
	close(fd);
  801951:	89 1c 24             	mov    %ebx,(%esp)
  801954:	e8 f4 fb ff ff       	call   80154d <close>
	return r;
  801959:	83 c4 10             	add    $0x10,%esp
  80195c:	89 f0                	mov    %esi,%eax
}
  80195e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801961:	5b                   	pop    %ebx
  801962:	5e                   	pop    %esi
  801963:	5d                   	pop    %ebp
  801964:	c3                   	ret    

00801965 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801965:	55                   	push   %ebp
  801966:	89 e5                	mov    %esp,%ebp
  801968:	56                   	push   %esi
  801969:	53                   	push   %ebx
  80196a:	89 c6                	mov    %eax,%esi
  80196c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80196e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801975:	75 12                	jne    801989 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801977:	83 ec 0c             	sub    $0xc,%esp
  80197a:	6a 01                	push   $0x1
  80197c:	e8 94 08 00 00       	call   802215 <ipc_find_env>
  801981:	a3 00 40 80 00       	mov    %eax,0x804000
  801986:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801989:	6a 07                	push   $0x7
  80198b:	68 00 50 80 00       	push   $0x805000
  801990:	56                   	push   %esi
  801991:	ff 35 00 40 80 00    	pushl  0x804000
  801997:	e8 17 08 00 00       	call   8021b3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80199c:	83 c4 0c             	add    $0xc,%esp
  80199f:	6a 00                	push   $0x0
  8019a1:	53                   	push   %ebx
  8019a2:	6a 00                	push   $0x0
  8019a4:	e8 8f 07 00 00       	call   802138 <ipc_recv>
}
  8019a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ac:	5b                   	pop    %ebx
  8019ad:	5e                   	pop    %esi
  8019ae:	5d                   	pop    %ebp
  8019af:	c3                   	ret    

008019b0 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b9:	8b 40 0c             	mov    0xc(%eax),%eax
  8019bc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8019c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c4:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ce:	b8 02 00 00 00       	mov    $0x2,%eax
  8019d3:	e8 8d ff ff ff       	call   801965 <fsipc>
}
  8019d8:	c9                   	leave  
  8019d9:	c3                   	ret    

008019da <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019da:	55                   	push   %ebp
  8019db:	89 e5                	mov    %esp,%ebp
  8019dd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8019e6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f0:	b8 06 00 00 00       	mov    $0x6,%eax
  8019f5:	e8 6b ff ff ff       	call   801965 <fsipc>
}
  8019fa:	c9                   	leave  
  8019fb:	c3                   	ret    

008019fc <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	53                   	push   %ebx
  801a00:	83 ec 04             	sub    $0x4,%esp
  801a03:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a06:	8b 45 08             	mov    0x8(%ebp),%eax
  801a09:	8b 40 0c             	mov    0xc(%eax),%eax
  801a0c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a11:	ba 00 00 00 00       	mov    $0x0,%edx
  801a16:	b8 05 00 00 00       	mov    $0x5,%eax
  801a1b:	e8 45 ff ff ff       	call   801965 <fsipc>
  801a20:	85 c0                	test   %eax,%eax
  801a22:	78 2c                	js     801a50 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a24:	83 ec 08             	sub    $0x8,%esp
  801a27:	68 00 50 80 00       	push   $0x805000
  801a2c:	53                   	push   %ebx
  801a2d:	e8 a8 ed ff ff       	call   8007da <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a32:	a1 80 50 80 00       	mov    0x805080,%eax
  801a37:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a3d:	a1 84 50 80 00       	mov    0x805084,%eax
  801a42:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a48:	83 c4 10             	add    $0x10,%esp
  801a4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a50:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a53:	c9                   	leave  
  801a54:	c3                   	ret    

00801a55 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a55:	55                   	push   %ebp
  801a56:	89 e5                	mov    %esp,%ebp
  801a58:	83 ec 0c             	sub    $0xc,%esp
  801a5b:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a5e:	8b 55 08             	mov    0x8(%ebp),%edx
  801a61:	8b 52 0c             	mov    0xc(%edx),%edx
  801a64:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801a6a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a6f:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a74:	0f 47 c2             	cmova  %edx,%eax
  801a77:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801a7c:	50                   	push   %eax
  801a7d:	ff 75 0c             	pushl  0xc(%ebp)
  801a80:	68 08 50 80 00       	push   $0x805008
  801a85:	e8 e2 ee ff ff       	call   80096c <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801a8a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a8f:	b8 04 00 00 00       	mov    $0x4,%eax
  801a94:	e8 cc fe ff ff       	call   801965 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801a99:	c9                   	leave  
  801a9a:	c3                   	ret    

00801a9b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a9b:	55                   	push   %ebp
  801a9c:	89 e5                	mov    %esp,%ebp
  801a9e:	56                   	push   %esi
  801a9f:	53                   	push   %ebx
  801aa0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801aa3:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa6:	8b 40 0c             	mov    0xc(%eax),%eax
  801aa9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801aae:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ab4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab9:	b8 03 00 00 00       	mov    $0x3,%eax
  801abe:	e8 a2 fe ff ff       	call   801965 <fsipc>
  801ac3:	89 c3                	mov    %eax,%ebx
  801ac5:	85 c0                	test   %eax,%eax
  801ac7:	78 4b                	js     801b14 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801ac9:	39 c6                	cmp    %eax,%esi
  801acb:	73 16                	jae    801ae3 <devfile_read+0x48>
  801acd:	68 d8 2a 80 00       	push   $0x802ad8
  801ad2:	68 df 2a 80 00       	push   $0x802adf
  801ad7:	6a 7c                	push   $0x7c
  801ad9:	68 f4 2a 80 00       	push   $0x802af4
  801ade:	e8 99 e6 ff ff       	call   80017c <_panic>
	assert(r <= PGSIZE);
  801ae3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ae8:	7e 16                	jle    801b00 <devfile_read+0x65>
  801aea:	68 ff 2a 80 00       	push   $0x802aff
  801aef:	68 df 2a 80 00       	push   $0x802adf
  801af4:	6a 7d                	push   $0x7d
  801af6:	68 f4 2a 80 00       	push   $0x802af4
  801afb:	e8 7c e6 ff ff       	call   80017c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b00:	83 ec 04             	sub    $0x4,%esp
  801b03:	50                   	push   %eax
  801b04:	68 00 50 80 00       	push   $0x805000
  801b09:	ff 75 0c             	pushl  0xc(%ebp)
  801b0c:	e8 5b ee ff ff       	call   80096c <memmove>
	return r;
  801b11:	83 c4 10             	add    $0x10,%esp
}
  801b14:	89 d8                	mov    %ebx,%eax
  801b16:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b19:	5b                   	pop    %ebx
  801b1a:	5e                   	pop    %esi
  801b1b:	5d                   	pop    %ebp
  801b1c:	c3                   	ret    

00801b1d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	53                   	push   %ebx
  801b21:	83 ec 20             	sub    $0x20,%esp
  801b24:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b27:	53                   	push   %ebx
  801b28:	e8 74 ec ff ff       	call   8007a1 <strlen>
  801b2d:	83 c4 10             	add    $0x10,%esp
  801b30:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b35:	7f 67                	jg     801b9e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b37:	83 ec 0c             	sub    $0xc,%esp
  801b3a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b3d:	50                   	push   %eax
  801b3e:	e8 8e f8 ff ff       	call   8013d1 <fd_alloc>
  801b43:	83 c4 10             	add    $0x10,%esp
		return r;
  801b46:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b48:	85 c0                	test   %eax,%eax
  801b4a:	78 57                	js     801ba3 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b4c:	83 ec 08             	sub    $0x8,%esp
  801b4f:	53                   	push   %ebx
  801b50:	68 00 50 80 00       	push   $0x805000
  801b55:	e8 80 ec ff ff       	call   8007da <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b5d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b62:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b65:	b8 01 00 00 00       	mov    $0x1,%eax
  801b6a:	e8 f6 fd ff ff       	call   801965 <fsipc>
  801b6f:	89 c3                	mov    %eax,%ebx
  801b71:	83 c4 10             	add    $0x10,%esp
  801b74:	85 c0                	test   %eax,%eax
  801b76:	79 14                	jns    801b8c <open+0x6f>
		fd_close(fd, 0);
  801b78:	83 ec 08             	sub    $0x8,%esp
  801b7b:	6a 00                	push   $0x0
  801b7d:	ff 75 f4             	pushl  -0xc(%ebp)
  801b80:	e8 47 f9 ff ff       	call   8014cc <fd_close>
		return r;
  801b85:	83 c4 10             	add    $0x10,%esp
  801b88:	89 da                	mov    %ebx,%edx
  801b8a:	eb 17                	jmp    801ba3 <open+0x86>
	}

	return fd2num(fd);
  801b8c:	83 ec 0c             	sub    $0xc,%esp
  801b8f:	ff 75 f4             	pushl  -0xc(%ebp)
  801b92:	e8 13 f8 ff ff       	call   8013aa <fd2num>
  801b97:	89 c2                	mov    %eax,%edx
  801b99:	83 c4 10             	add    $0x10,%esp
  801b9c:	eb 05                	jmp    801ba3 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b9e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ba3:	89 d0                	mov    %edx,%eax
  801ba5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ba8:	c9                   	leave  
  801ba9:	c3                   	ret    

00801baa <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801baa:	55                   	push   %ebp
  801bab:	89 e5                	mov    %esp,%ebp
  801bad:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bb0:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb5:	b8 08 00 00 00       	mov    $0x8,%eax
  801bba:	e8 a6 fd ff ff       	call   801965 <fsipc>
}
  801bbf:	c9                   	leave  
  801bc0:	c3                   	ret    

00801bc1 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bc1:	55                   	push   %ebp
  801bc2:	89 e5                	mov    %esp,%ebp
  801bc4:	56                   	push   %esi
  801bc5:	53                   	push   %ebx
  801bc6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bc9:	83 ec 0c             	sub    $0xc,%esp
  801bcc:	ff 75 08             	pushl  0x8(%ebp)
  801bcf:	e8 e6 f7 ff ff       	call   8013ba <fd2data>
  801bd4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801bd6:	83 c4 08             	add    $0x8,%esp
  801bd9:	68 0b 2b 80 00       	push   $0x802b0b
  801bde:	53                   	push   %ebx
  801bdf:	e8 f6 eb ff ff       	call   8007da <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801be4:	8b 46 04             	mov    0x4(%esi),%eax
  801be7:	2b 06                	sub    (%esi),%eax
  801be9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bef:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bf6:	00 00 00 
	stat->st_dev = &devpipe;
  801bf9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c00:	30 80 00 
	return 0;
}
  801c03:	b8 00 00 00 00       	mov    $0x0,%eax
  801c08:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c0b:	5b                   	pop    %ebx
  801c0c:	5e                   	pop    %esi
  801c0d:	5d                   	pop    %ebp
  801c0e:	c3                   	ret    

00801c0f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c0f:	55                   	push   %ebp
  801c10:	89 e5                	mov    %esp,%ebp
  801c12:	53                   	push   %ebx
  801c13:	83 ec 0c             	sub    $0xc,%esp
  801c16:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c19:	53                   	push   %ebx
  801c1a:	6a 00                	push   $0x0
  801c1c:	e8 41 f0 ff ff       	call   800c62 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c21:	89 1c 24             	mov    %ebx,(%esp)
  801c24:	e8 91 f7 ff ff       	call   8013ba <fd2data>
  801c29:	83 c4 08             	add    $0x8,%esp
  801c2c:	50                   	push   %eax
  801c2d:	6a 00                	push   $0x0
  801c2f:	e8 2e f0 ff ff       	call   800c62 <sys_page_unmap>
}
  801c34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c37:	c9                   	leave  
  801c38:	c3                   	ret    

00801c39 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c39:	55                   	push   %ebp
  801c3a:	89 e5                	mov    %esp,%ebp
  801c3c:	57                   	push   %edi
  801c3d:	56                   	push   %esi
  801c3e:	53                   	push   %ebx
  801c3f:	83 ec 1c             	sub    $0x1c,%esp
  801c42:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c45:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c47:	a1 08 40 80 00       	mov    0x804008,%eax
  801c4c:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c52:	83 ec 0c             	sub    $0xc,%esp
  801c55:	ff 75 e0             	pushl  -0x20(%ebp)
  801c58:	e8 fd 05 00 00       	call   80225a <pageref>
  801c5d:	89 c3                	mov    %eax,%ebx
  801c5f:	89 3c 24             	mov    %edi,(%esp)
  801c62:	e8 f3 05 00 00       	call   80225a <pageref>
  801c67:	83 c4 10             	add    $0x10,%esp
  801c6a:	39 c3                	cmp    %eax,%ebx
  801c6c:	0f 94 c1             	sete   %cl
  801c6f:	0f b6 c9             	movzbl %cl,%ecx
  801c72:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c75:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801c7b:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801c81:	39 ce                	cmp    %ecx,%esi
  801c83:	74 1e                	je     801ca3 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801c85:	39 c3                	cmp    %eax,%ebx
  801c87:	75 be                	jne    801c47 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c89:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801c8f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c92:	50                   	push   %eax
  801c93:	56                   	push   %esi
  801c94:	68 12 2b 80 00       	push   $0x802b12
  801c99:	e8 b7 e5 ff ff       	call   800255 <cprintf>
  801c9e:	83 c4 10             	add    $0x10,%esp
  801ca1:	eb a4                	jmp    801c47 <_pipeisclosed+0xe>
	}
}
  801ca3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ca6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ca9:	5b                   	pop    %ebx
  801caa:	5e                   	pop    %esi
  801cab:	5f                   	pop    %edi
  801cac:	5d                   	pop    %ebp
  801cad:	c3                   	ret    

00801cae <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cae:	55                   	push   %ebp
  801caf:	89 e5                	mov    %esp,%ebp
  801cb1:	57                   	push   %edi
  801cb2:	56                   	push   %esi
  801cb3:	53                   	push   %ebx
  801cb4:	83 ec 28             	sub    $0x28,%esp
  801cb7:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801cba:	56                   	push   %esi
  801cbb:	e8 fa f6 ff ff       	call   8013ba <fd2data>
  801cc0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cc2:	83 c4 10             	add    $0x10,%esp
  801cc5:	bf 00 00 00 00       	mov    $0x0,%edi
  801cca:	eb 4b                	jmp    801d17 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ccc:	89 da                	mov    %ebx,%edx
  801cce:	89 f0                	mov    %esi,%eax
  801cd0:	e8 64 ff ff ff       	call   801c39 <_pipeisclosed>
  801cd5:	85 c0                	test   %eax,%eax
  801cd7:	75 48                	jne    801d21 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801cd9:	e8 e0 ee ff ff       	call   800bbe <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cde:	8b 43 04             	mov    0x4(%ebx),%eax
  801ce1:	8b 0b                	mov    (%ebx),%ecx
  801ce3:	8d 51 20             	lea    0x20(%ecx),%edx
  801ce6:	39 d0                	cmp    %edx,%eax
  801ce8:	73 e2                	jae    801ccc <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ced:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801cf1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801cf4:	89 c2                	mov    %eax,%edx
  801cf6:	c1 fa 1f             	sar    $0x1f,%edx
  801cf9:	89 d1                	mov    %edx,%ecx
  801cfb:	c1 e9 1b             	shr    $0x1b,%ecx
  801cfe:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d01:	83 e2 1f             	and    $0x1f,%edx
  801d04:	29 ca                	sub    %ecx,%edx
  801d06:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d0a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d0e:	83 c0 01             	add    $0x1,%eax
  801d11:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d14:	83 c7 01             	add    $0x1,%edi
  801d17:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d1a:	75 c2                	jne    801cde <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d1c:	8b 45 10             	mov    0x10(%ebp),%eax
  801d1f:	eb 05                	jmp    801d26 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d21:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d29:	5b                   	pop    %ebx
  801d2a:	5e                   	pop    %esi
  801d2b:	5f                   	pop    %edi
  801d2c:	5d                   	pop    %ebp
  801d2d:	c3                   	ret    

00801d2e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d2e:	55                   	push   %ebp
  801d2f:	89 e5                	mov    %esp,%ebp
  801d31:	57                   	push   %edi
  801d32:	56                   	push   %esi
  801d33:	53                   	push   %ebx
  801d34:	83 ec 18             	sub    $0x18,%esp
  801d37:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d3a:	57                   	push   %edi
  801d3b:	e8 7a f6 ff ff       	call   8013ba <fd2data>
  801d40:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d42:	83 c4 10             	add    $0x10,%esp
  801d45:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d4a:	eb 3d                	jmp    801d89 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d4c:	85 db                	test   %ebx,%ebx
  801d4e:	74 04                	je     801d54 <devpipe_read+0x26>
				return i;
  801d50:	89 d8                	mov    %ebx,%eax
  801d52:	eb 44                	jmp    801d98 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d54:	89 f2                	mov    %esi,%edx
  801d56:	89 f8                	mov    %edi,%eax
  801d58:	e8 dc fe ff ff       	call   801c39 <_pipeisclosed>
  801d5d:	85 c0                	test   %eax,%eax
  801d5f:	75 32                	jne    801d93 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d61:	e8 58 ee ff ff       	call   800bbe <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d66:	8b 06                	mov    (%esi),%eax
  801d68:	3b 46 04             	cmp    0x4(%esi),%eax
  801d6b:	74 df                	je     801d4c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d6d:	99                   	cltd   
  801d6e:	c1 ea 1b             	shr    $0x1b,%edx
  801d71:	01 d0                	add    %edx,%eax
  801d73:	83 e0 1f             	and    $0x1f,%eax
  801d76:	29 d0                	sub    %edx,%eax
  801d78:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d80:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d83:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d86:	83 c3 01             	add    $0x1,%ebx
  801d89:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d8c:	75 d8                	jne    801d66 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d8e:	8b 45 10             	mov    0x10(%ebp),%eax
  801d91:	eb 05                	jmp    801d98 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d93:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d9b:	5b                   	pop    %ebx
  801d9c:	5e                   	pop    %esi
  801d9d:	5f                   	pop    %edi
  801d9e:	5d                   	pop    %ebp
  801d9f:	c3                   	ret    

00801da0 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801da0:	55                   	push   %ebp
  801da1:	89 e5                	mov    %esp,%ebp
  801da3:	56                   	push   %esi
  801da4:	53                   	push   %ebx
  801da5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801da8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dab:	50                   	push   %eax
  801dac:	e8 20 f6 ff ff       	call   8013d1 <fd_alloc>
  801db1:	83 c4 10             	add    $0x10,%esp
  801db4:	89 c2                	mov    %eax,%edx
  801db6:	85 c0                	test   %eax,%eax
  801db8:	0f 88 2c 01 00 00    	js     801eea <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dbe:	83 ec 04             	sub    $0x4,%esp
  801dc1:	68 07 04 00 00       	push   $0x407
  801dc6:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc9:	6a 00                	push   $0x0
  801dcb:	e8 0d ee ff ff       	call   800bdd <sys_page_alloc>
  801dd0:	83 c4 10             	add    $0x10,%esp
  801dd3:	89 c2                	mov    %eax,%edx
  801dd5:	85 c0                	test   %eax,%eax
  801dd7:	0f 88 0d 01 00 00    	js     801eea <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ddd:	83 ec 0c             	sub    $0xc,%esp
  801de0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801de3:	50                   	push   %eax
  801de4:	e8 e8 f5 ff ff       	call   8013d1 <fd_alloc>
  801de9:	89 c3                	mov    %eax,%ebx
  801deb:	83 c4 10             	add    $0x10,%esp
  801dee:	85 c0                	test   %eax,%eax
  801df0:	0f 88 e2 00 00 00    	js     801ed8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801df6:	83 ec 04             	sub    $0x4,%esp
  801df9:	68 07 04 00 00       	push   $0x407
  801dfe:	ff 75 f0             	pushl  -0x10(%ebp)
  801e01:	6a 00                	push   $0x0
  801e03:	e8 d5 ed ff ff       	call   800bdd <sys_page_alloc>
  801e08:	89 c3                	mov    %eax,%ebx
  801e0a:	83 c4 10             	add    $0x10,%esp
  801e0d:	85 c0                	test   %eax,%eax
  801e0f:	0f 88 c3 00 00 00    	js     801ed8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e15:	83 ec 0c             	sub    $0xc,%esp
  801e18:	ff 75 f4             	pushl  -0xc(%ebp)
  801e1b:	e8 9a f5 ff ff       	call   8013ba <fd2data>
  801e20:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e22:	83 c4 0c             	add    $0xc,%esp
  801e25:	68 07 04 00 00       	push   $0x407
  801e2a:	50                   	push   %eax
  801e2b:	6a 00                	push   $0x0
  801e2d:	e8 ab ed ff ff       	call   800bdd <sys_page_alloc>
  801e32:	89 c3                	mov    %eax,%ebx
  801e34:	83 c4 10             	add    $0x10,%esp
  801e37:	85 c0                	test   %eax,%eax
  801e39:	0f 88 89 00 00 00    	js     801ec8 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e3f:	83 ec 0c             	sub    $0xc,%esp
  801e42:	ff 75 f0             	pushl  -0x10(%ebp)
  801e45:	e8 70 f5 ff ff       	call   8013ba <fd2data>
  801e4a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e51:	50                   	push   %eax
  801e52:	6a 00                	push   $0x0
  801e54:	56                   	push   %esi
  801e55:	6a 00                	push   $0x0
  801e57:	e8 c4 ed ff ff       	call   800c20 <sys_page_map>
  801e5c:	89 c3                	mov    %eax,%ebx
  801e5e:	83 c4 20             	add    $0x20,%esp
  801e61:	85 c0                	test   %eax,%eax
  801e63:	78 55                	js     801eba <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e65:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e73:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e7a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e80:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e83:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e85:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e88:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e8f:	83 ec 0c             	sub    $0xc,%esp
  801e92:	ff 75 f4             	pushl  -0xc(%ebp)
  801e95:	e8 10 f5 ff ff       	call   8013aa <fd2num>
  801e9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e9d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e9f:	83 c4 04             	add    $0x4,%esp
  801ea2:	ff 75 f0             	pushl  -0x10(%ebp)
  801ea5:	e8 00 f5 ff ff       	call   8013aa <fd2num>
  801eaa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ead:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801eb0:	83 c4 10             	add    $0x10,%esp
  801eb3:	ba 00 00 00 00       	mov    $0x0,%edx
  801eb8:	eb 30                	jmp    801eea <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801eba:	83 ec 08             	sub    $0x8,%esp
  801ebd:	56                   	push   %esi
  801ebe:	6a 00                	push   $0x0
  801ec0:	e8 9d ed ff ff       	call   800c62 <sys_page_unmap>
  801ec5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ec8:	83 ec 08             	sub    $0x8,%esp
  801ecb:	ff 75 f0             	pushl  -0x10(%ebp)
  801ece:	6a 00                	push   $0x0
  801ed0:	e8 8d ed ff ff       	call   800c62 <sys_page_unmap>
  801ed5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ed8:	83 ec 08             	sub    $0x8,%esp
  801edb:	ff 75 f4             	pushl  -0xc(%ebp)
  801ede:	6a 00                	push   $0x0
  801ee0:	e8 7d ed ff ff       	call   800c62 <sys_page_unmap>
  801ee5:	83 c4 10             	add    $0x10,%esp
  801ee8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801eea:	89 d0                	mov    %edx,%eax
  801eec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eef:	5b                   	pop    %ebx
  801ef0:	5e                   	pop    %esi
  801ef1:	5d                   	pop    %ebp
  801ef2:	c3                   	ret    

00801ef3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ef3:	55                   	push   %ebp
  801ef4:	89 e5                	mov    %esp,%ebp
  801ef6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ef9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801efc:	50                   	push   %eax
  801efd:	ff 75 08             	pushl  0x8(%ebp)
  801f00:	e8 1b f5 ff ff       	call   801420 <fd_lookup>
  801f05:	83 c4 10             	add    $0x10,%esp
  801f08:	85 c0                	test   %eax,%eax
  801f0a:	78 18                	js     801f24 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f0c:	83 ec 0c             	sub    $0xc,%esp
  801f0f:	ff 75 f4             	pushl  -0xc(%ebp)
  801f12:	e8 a3 f4 ff ff       	call   8013ba <fd2data>
	return _pipeisclosed(fd, p);
  801f17:	89 c2                	mov    %eax,%edx
  801f19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f1c:	e8 18 fd ff ff       	call   801c39 <_pipeisclosed>
  801f21:	83 c4 10             	add    $0x10,%esp
}
  801f24:	c9                   	leave  
  801f25:	c3                   	ret    

00801f26 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f26:	55                   	push   %ebp
  801f27:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f29:	b8 00 00 00 00       	mov    $0x0,%eax
  801f2e:	5d                   	pop    %ebp
  801f2f:	c3                   	ret    

00801f30 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f30:	55                   	push   %ebp
  801f31:	89 e5                	mov    %esp,%ebp
  801f33:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f36:	68 2a 2b 80 00       	push   $0x802b2a
  801f3b:	ff 75 0c             	pushl  0xc(%ebp)
  801f3e:	e8 97 e8 ff ff       	call   8007da <strcpy>
	return 0;
}
  801f43:	b8 00 00 00 00       	mov    $0x0,%eax
  801f48:	c9                   	leave  
  801f49:	c3                   	ret    

00801f4a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f4a:	55                   	push   %ebp
  801f4b:	89 e5                	mov    %esp,%ebp
  801f4d:	57                   	push   %edi
  801f4e:	56                   	push   %esi
  801f4f:	53                   	push   %ebx
  801f50:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f56:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f5b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f61:	eb 2d                	jmp    801f90 <devcons_write+0x46>
		m = n - tot;
  801f63:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f66:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f68:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f6b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f70:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f73:	83 ec 04             	sub    $0x4,%esp
  801f76:	53                   	push   %ebx
  801f77:	03 45 0c             	add    0xc(%ebp),%eax
  801f7a:	50                   	push   %eax
  801f7b:	57                   	push   %edi
  801f7c:	e8 eb e9 ff ff       	call   80096c <memmove>
		sys_cputs(buf, m);
  801f81:	83 c4 08             	add    $0x8,%esp
  801f84:	53                   	push   %ebx
  801f85:	57                   	push   %edi
  801f86:	e8 96 eb ff ff       	call   800b21 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f8b:	01 de                	add    %ebx,%esi
  801f8d:	83 c4 10             	add    $0x10,%esp
  801f90:	89 f0                	mov    %esi,%eax
  801f92:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f95:	72 cc                	jb     801f63 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f9a:	5b                   	pop    %ebx
  801f9b:	5e                   	pop    %esi
  801f9c:	5f                   	pop    %edi
  801f9d:	5d                   	pop    %ebp
  801f9e:	c3                   	ret    

00801f9f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f9f:	55                   	push   %ebp
  801fa0:	89 e5                	mov    %esp,%ebp
  801fa2:	83 ec 08             	sub    $0x8,%esp
  801fa5:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801faa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fae:	74 2a                	je     801fda <devcons_read+0x3b>
  801fb0:	eb 05                	jmp    801fb7 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801fb2:	e8 07 ec ff ff       	call   800bbe <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801fb7:	e8 83 eb ff ff       	call   800b3f <sys_cgetc>
  801fbc:	85 c0                	test   %eax,%eax
  801fbe:	74 f2                	je     801fb2 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801fc0:	85 c0                	test   %eax,%eax
  801fc2:	78 16                	js     801fda <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801fc4:	83 f8 04             	cmp    $0x4,%eax
  801fc7:	74 0c                	je     801fd5 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801fc9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fcc:	88 02                	mov    %al,(%edx)
	return 1;
  801fce:	b8 01 00 00 00       	mov    $0x1,%eax
  801fd3:	eb 05                	jmp    801fda <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fd5:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fda:	c9                   	leave  
  801fdb:	c3                   	ret    

00801fdc <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fdc:	55                   	push   %ebp
  801fdd:	89 e5                	mov    %esp,%ebp
  801fdf:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fe2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fe8:	6a 01                	push   $0x1
  801fea:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fed:	50                   	push   %eax
  801fee:	e8 2e eb ff ff       	call   800b21 <sys_cputs>
}
  801ff3:	83 c4 10             	add    $0x10,%esp
  801ff6:	c9                   	leave  
  801ff7:	c3                   	ret    

00801ff8 <getchar>:

int
getchar(void)
{
  801ff8:	55                   	push   %ebp
  801ff9:	89 e5                	mov    %esp,%ebp
  801ffb:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ffe:	6a 01                	push   $0x1
  802000:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802003:	50                   	push   %eax
  802004:	6a 00                	push   $0x0
  802006:	e8 7e f6 ff ff       	call   801689 <read>
	if (r < 0)
  80200b:	83 c4 10             	add    $0x10,%esp
  80200e:	85 c0                	test   %eax,%eax
  802010:	78 0f                	js     802021 <getchar+0x29>
		return r;
	if (r < 1)
  802012:	85 c0                	test   %eax,%eax
  802014:	7e 06                	jle    80201c <getchar+0x24>
		return -E_EOF;
	return c;
  802016:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80201a:	eb 05                	jmp    802021 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80201c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802021:	c9                   	leave  
  802022:	c3                   	ret    

00802023 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802023:	55                   	push   %ebp
  802024:	89 e5                	mov    %esp,%ebp
  802026:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802029:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80202c:	50                   	push   %eax
  80202d:	ff 75 08             	pushl  0x8(%ebp)
  802030:	e8 eb f3 ff ff       	call   801420 <fd_lookup>
  802035:	83 c4 10             	add    $0x10,%esp
  802038:	85 c0                	test   %eax,%eax
  80203a:	78 11                	js     80204d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80203c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80203f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802045:	39 10                	cmp    %edx,(%eax)
  802047:	0f 94 c0             	sete   %al
  80204a:	0f b6 c0             	movzbl %al,%eax
}
  80204d:	c9                   	leave  
  80204e:	c3                   	ret    

0080204f <opencons>:

int
opencons(void)
{
  80204f:	55                   	push   %ebp
  802050:	89 e5                	mov    %esp,%ebp
  802052:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802055:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802058:	50                   	push   %eax
  802059:	e8 73 f3 ff ff       	call   8013d1 <fd_alloc>
  80205e:	83 c4 10             	add    $0x10,%esp
		return r;
  802061:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802063:	85 c0                	test   %eax,%eax
  802065:	78 3e                	js     8020a5 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802067:	83 ec 04             	sub    $0x4,%esp
  80206a:	68 07 04 00 00       	push   $0x407
  80206f:	ff 75 f4             	pushl  -0xc(%ebp)
  802072:	6a 00                	push   $0x0
  802074:	e8 64 eb ff ff       	call   800bdd <sys_page_alloc>
  802079:	83 c4 10             	add    $0x10,%esp
		return r;
  80207c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80207e:	85 c0                	test   %eax,%eax
  802080:	78 23                	js     8020a5 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802082:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802088:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80208b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80208d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802090:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802097:	83 ec 0c             	sub    $0xc,%esp
  80209a:	50                   	push   %eax
  80209b:	e8 0a f3 ff ff       	call   8013aa <fd2num>
  8020a0:	89 c2                	mov    %eax,%edx
  8020a2:	83 c4 10             	add    $0x10,%esp
}
  8020a5:	89 d0                	mov    %edx,%eax
  8020a7:	c9                   	leave  
  8020a8:	c3                   	ret    

008020a9 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8020a9:	55                   	push   %ebp
  8020aa:	89 e5                	mov    %esp,%ebp
  8020ac:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8020af:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8020b6:	75 2a                	jne    8020e2 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  8020b8:	83 ec 04             	sub    $0x4,%esp
  8020bb:	6a 07                	push   $0x7
  8020bd:	68 00 f0 bf ee       	push   $0xeebff000
  8020c2:	6a 00                	push   $0x0
  8020c4:	e8 14 eb ff ff       	call   800bdd <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8020c9:	83 c4 10             	add    $0x10,%esp
  8020cc:	85 c0                	test   %eax,%eax
  8020ce:	79 12                	jns    8020e2 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8020d0:	50                   	push   %eax
  8020d1:	68 b8 29 80 00       	push   $0x8029b8
  8020d6:	6a 23                	push   $0x23
  8020d8:	68 36 2b 80 00       	push   $0x802b36
  8020dd:	e8 9a e0 ff ff       	call   80017c <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8020e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e5:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8020ea:	83 ec 08             	sub    $0x8,%esp
  8020ed:	68 14 21 80 00       	push   $0x802114
  8020f2:	6a 00                	push   $0x0
  8020f4:	e8 2f ec ff ff       	call   800d28 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8020f9:	83 c4 10             	add    $0x10,%esp
  8020fc:	85 c0                	test   %eax,%eax
  8020fe:	79 12                	jns    802112 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802100:	50                   	push   %eax
  802101:	68 b8 29 80 00       	push   $0x8029b8
  802106:	6a 2c                	push   $0x2c
  802108:	68 36 2b 80 00       	push   $0x802b36
  80210d:	e8 6a e0 ff ff       	call   80017c <_panic>
	}
}
  802112:	c9                   	leave  
  802113:	c3                   	ret    

00802114 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802114:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802115:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80211a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80211c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  80211f:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802123:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802128:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80212c:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  80212e:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802131:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802132:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802135:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802136:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802137:	c3                   	ret    

00802138 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802138:	55                   	push   %ebp
  802139:	89 e5                	mov    %esp,%ebp
  80213b:	56                   	push   %esi
  80213c:	53                   	push   %ebx
  80213d:	8b 75 08             	mov    0x8(%ebp),%esi
  802140:	8b 45 0c             	mov    0xc(%ebp),%eax
  802143:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802146:	85 c0                	test   %eax,%eax
  802148:	75 12                	jne    80215c <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80214a:	83 ec 0c             	sub    $0xc,%esp
  80214d:	68 00 00 c0 ee       	push   $0xeec00000
  802152:	e8 36 ec ff ff       	call   800d8d <sys_ipc_recv>
  802157:	83 c4 10             	add    $0x10,%esp
  80215a:	eb 0c                	jmp    802168 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80215c:	83 ec 0c             	sub    $0xc,%esp
  80215f:	50                   	push   %eax
  802160:	e8 28 ec ff ff       	call   800d8d <sys_ipc_recv>
  802165:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802168:	85 f6                	test   %esi,%esi
  80216a:	0f 95 c1             	setne  %cl
  80216d:	85 db                	test   %ebx,%ebx
  80216f:	0f 95 c2             	setne  %dl
  802172:	84 d1                	test   %dl,%cl
  802174:	74 09                	je     80217f <ipc_recv+0x47>
  802176:	89 c2                	mov    %eax,%edx
  802178:	c1 ea 1f             	shr    $0x1f,%edx
  80217b:	84 d2                	test   %dl,%dl
  80217d:	75 2d                	jne    8021ac <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80217f:	85 f6                	test   %esi,%esi
  802181:	74 0d                	je     802190 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802183:	a1 08 40 80 00       	mov    0x804008,%eax
  802188:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  80218e:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802190:	85 db                	test   %ebx,%ebx
  802192:	74 0d                	je     8021a1 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802194:	a1 08 40 80 00       	mov    0x804008,%eax
  802199:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  80219f:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8021a1:	a1 08 40 80 00       	mov    0x804008,%eax
  8021a6:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  8021ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021af:	5b                   	pop    %ebx
  8021b0:	5e                   	pop    %esi
  8021b1:	5d                   	pop    %ebp
  8021b2:	c3                   	ret    

008021b3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021b3:	55                   	push   %ebp
  8021b4:	89 e5                	mov    %esp,%ebp
  8021b6:	57                   	push   %edi
  8021b7:	56                   	push   %esi
  8021b8:	53                   	push   %ebx
  8021b9:	83 ec 0c             	sub    $0xc,%esp
  8021bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021bf:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021c2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8021c5:	85 db                	test   %ebx,%ebx
  8021c7:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8021cc:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8021cf:	ff 75 14             	pushl  0x14(%ebp)
  8021d2:	53                   	push   %ebx
  8021d3:	56                   	push   %esi
  8021d4:	57                   	push   %edi
  8021d5:	e8 90 eb ff ff       	call   800d6a <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8021da:	89 c2                	mov    %eax,%edx
  8021dc:	c1 ea 1f             	shr    $0x1f,%edx
  8021df:	83 c4 10             	add    $0x10,%esp
  8021e2:	84 d2                	test   %dl,%dl
  8021e4:	74 17                	je     8021fd <ipc_send+0x4a>
  8021e6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021e9:	74 12                	je     8021fd <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8021eb:	50                   	push   %eax
  8021ec:	68 44 2b 80 00       	push   $0x802b44
  8021f1:	6a 47                	push   $0x47
  8021f3:	68 52 2b 80 00       	push   $0x802b52
  8021f8:	e8 7f df ff ff       	call   80017c <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8021fd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802200:	75 07                	jne    802209 <ipc_send+0x56>
			sys_yield();
  802202:	e8 b7 e9 ff ff       	call   800bbe <sys_yield>
  802207:	eb c6                	jmp    8021cf <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802209:	85 c0                	test   %eax,%eax
  80220b:	75 c2                	jne    8021cf <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80220d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802210:	5b                   	pop    %ebx
  802211:	5e                   	pop    %esi
  802212:	5f                   	pop    %edi
  802213:	5d                   	pop    %ebp
  802214:	c3                   	ret    

00802215 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802215:	55                   	push   %ebp
  802216:	89 e5                	mov    %esp,%ebp
  802218:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80221b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802220:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  802226:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80222c:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  802232:	39 ca                	cmp    %ecx,%edx
  802234:	75 13                	jne    802249 <ipc_find_env+0x34>
			return envs[i].env_id;
  802236:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  80223c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802241:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  802247:	eb 0f                	jmp    802258 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802249:	83 c0 01             	add    $0x1,%eax
  80224c:	3d 00 04 00 00       	cmp    $0x400,%eax
  802251:	75 cd                	jne    802220 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802253:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802258:	5d                   	pop    %ebp
  802259:	c3                   	ret    

0080225a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80225a:	55                   	push   %ebp
  80225b:	89 e5                	mov    %esp,%ebp
  80225d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802260:	89 d0                	mov    %edx,%eax
  802262:	c1 e8 16             	shr    $0x16,%eax
  802265:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80226c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802271:	f6 c1 01             	test   $0x1,%cl
  802274:	74 1d                	je     802293 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802276:	c1 ea 0c             	shr    $0xc,%edx
  802279:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802280:	f6 c2 01             	test   $0x1,%dl
  802283:	74 0e                	je     802293 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802285:	c1 ea 0c             	shr    $0xc,%edx
  802288:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80228f:	ef 
  802290:	0f b7 c0             	movzwl %ax,%eax
}
  802293:	5d                   	pop    %ebp
  802294:	c3                   	ret    
  802295:	66 90                	xchg   %ax,%ax
  802297:	66 90                	xchg   %ax,%ax
  802299:	66 90                	xchg   %ax,%ax
  80229b:	66 90                	xchg   %ax,%ax
  80229d:	66 90                	xchg   %ax,%ax
  80229f:	90                   	nop

008022a0 <__udivdi3>:
  8022a0:	55                   	push   %ebp
  8022a1:	57                   	push   %edi
  8022a2:	56                   	push   %esi
  8022a3:	53                   	push   %ebx
  8022a4:	83 ec 1c             	sub    $0x1c,%esp
  8022a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8022ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8022af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8022b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022b7:	85 f6                	test   %esi,%esi
  8022b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022bd:	89 ca                	mov    %ecx,%edx
  8022bf:	89 f8                	mov    %edi,%eax
  8022c1:	75 3d                	jne    802300 <__udivdi3+0x60>
  8022c3:	39 cf                	cmp    %ecx,%edi
  8022c5:	0f 87 c5 00 00 00    	ja     802390 <__udivdi3+0xf0>
  8022cb:	85 ff                	test   %edi,%edi
  8022cd:	89 fd                	mov    %edi,%ebp
  8022cf:	75 0b                	jne    8022dc <__udivdi3+0x3c>
  8022d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8022d6:	31 d2                	xor    %edx,%edx
  8022d8:	f7 f7                	div    %edi
  8022da:	89 c5                	mov    %eax,%ebp
  8022dc:	89 c8                	mov    %ecx,%eax
  8022de:	31 d2                	xor    %edx,%edx
  8022e0:	f7 f5                	div    %ebp
  8022e2:	89 c1                	mov    %eax,%ecx
  8022e4:	89 d8                	mov    %ebx,%eax
  8022e6:	89 cf                	mov    %ecx,%edi
  8022e8:	f7 f5                	div    %ebp
  8022ea:	89 c3                	mov    %eax,%ebx
  8022ec:	89 d8                	mov    %ebx,%eax
  8022ee:	89 fa                	mov    %edi,%edx
  8022f0:	83 c4 1c             	add    $0x1c,%esp
  8022f3:	5b                   	pop    %ebx
  8022f4:	5e                   	pop    %esi
  8022f5:	5f                   	pop    %edi
  8022f6:	5d                   	pop    %ebp
  8022f7:	c3                   	ret    
  8022f8:	90                   	nop
  8022f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802300:	39 ce                	cmp    %ecx,%esi
  802302:	77 74                	ja     802378 <__udivdi3+0xd8>
  802304:	0f bd fe             	bsr    %esi,%edi
  802307:	83 f7 1f             	xor    $0x1f,%edi
  80230a:	0f 84 98 00 00 00    	je     8023a8 <__udivdi3+0x108>
  802310:	bb 20 00 00 00       	mov    $0x20,%ebx
  802315:	89 f9                	mov    %edi,%ecx
  802317:	89 c5                	mov    %eax,%ebp
  802319:	29 fb                	sub    %edi,%ebx
  80231b:	d3 e6                	shl    %cl,%esi
  80231d:	89 d9                	mov    %ebx,%ecx
  80231f:	d3 ed                	shr    %cl,%ebp
  802321:	89 f9                	mov    %edi,%ecx
  802323:	d3 e0                	shl    %cl,%eax
  802325:	09 ee                	or     %ebp,%esi
  802327:	89 d9                	mov    %ebx,%ecx
  802329:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80232d:	89 d5                	mov    %edx,%ebp
  80232f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802333:	d3 ed                	shr    %cl,%ebp
  802335:	89 f9                	mov    %edi,%ecx
  802337:	d3 e2                	shl    %cl,%edx
  802339:	89 d9                	mov    %ebx,%ecx
  80233b:	d3 e8                	shr    %cl,%eax
  80233d:	09 c2                	or     %eax,%edx
  80233f:	89 d0                	mov    %edx,%eax
  802341:	89 ea                	mov    %ebp,%edx
  802343:	f7 f6                	div    %esi
  802345:	89 d5                	mov    %edx,%ebp
  802347:	89 c3                	mov    %eax,%ebx
  802349:	f7 64 24 0c          	mull   0xc(%esp)
  80234d:	39 d5                	cmp    %edx,%ebp
  80234f:	72 10                	jb     802361 <__udivdi3+0xc1>
  802351:	8b 74 24 08          	mov    0x8(%esp),%esi
  802355:	89 f9                	mov    %edi,%ecx
  802357:	d3 e6                	shl    %cl,%esi
  802359:	39 c6                	cmp    %eax,%esi
  80235b:	73 07                	jae    802364 <__udivdi3+0xc4>
  80235d:	39 d5                	cmp    %edx,%ebp
  80235f:	75 03                	jne    802364 <__udivdi3+0xc4>
  802361:	83 eb 01             	sub    $0x1,%ebx
  802364:	31 ff                	xor    %edi,%edi
  802366:	89 d8                	mov    %ebx,%eax
  802368:	89 fa                	mov    %edi,%edx
  80236a:	83 c4 1c             	add    $0x1c,%esp
  80236d:	5b                   	pop    %ebx
  80236e:	5e                   	pop    %esi
  80236f:	5f                   	pop    %edi
  802370:	5d                   	pop    %ebp
  802371:	c3                   	ret    
  802372:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802378:	31 ff                	xor    %edi,%edi
  80237a:	31 db                	xor    %ebx,%ebx
  80237c:	89 d8                	mov    %ebx,%eax
  80237e:	89 fa                	mov    %edi,%edx
  802380:	83 c4 1c             	add    $0x1c,%esp
  802383:	5b                   	pop    %ebx
  802384:	5e                   	pop    %esi
  802385:	5f                   	pop    %edi
  802386:	5d                   	pop    %ebp
  802387:	c3                   	ret    
  802388:	90                   	nop
  802389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802390:	89 d8                	mov    %ebx,%eax
  802392:	f7 f7                	div    %edi
  802394:	31 ff                	xor    %edi,%edi
  802396:	89 c3                	mov    %eax,%ebx
  802398:	89 d8                	mov    %ebx,%eax
  80239a:	89 fa                	mov    %edi,%edx
  80239c:	83 c4 1c             	add    $0x1c,%esp
  80239f:	5b                   	pop    %ebx
  8023a0:	5e                   	pop    %esi
  8023a1:	5f                   	pop    %edi
  8023a2:	5d                   	pop    %ebp
  8023a3:	c3                   	ret    
  8023a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023a8:	39 ce                	cmp    %ecx,%esi
  8023aa:	72 0c                	jb     8023b8 <__udivdi3+0x118>
  8023ac:	31 db                	xor    %ebx,%ebx
  8023ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8023b2:	0f 87 34 ff ff ff    	ja     8022ec <__udivdi3+0x4c>
  8023b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8023bd:	e9 2a ff ff ff       	jmp    8022ec <__udivdi3+0x4c>
  8023c2:	66 90                	xchg   %ax,%ax
  8023c4:	66 90                	xchg   %ax,%ax
  8023c6:	66 90                	xchg   %ax,%ax
  8023c8:	66 90                	xchg   %ax,%ax
  8023ca:	66 90                	xchg   %ax,%ax
  8023cc:	66 90                	xchg   %ax,%ax
  8023ce:	66 90                	xchg   %ax,%ax

008023d0 <__umoddi3>:
  8023d0:	55                   	push   %ebp
  8023d1:	57                   	push   %edi
  8023d2:	56                   	push   %esi
  8023d3:	53                   	push   %ebx
  8023d4:	83 ec 1c             	sub    $0x1c,%esp
  8023d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8023db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8023df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023e7:	85 d2                	test   %edx,%edx
  8023e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8023ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023f1:	89 f3                	mov    %esi,%ebx
  8023f3:	89 3c 24             	mov    %edi,(%esp)
  8023f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023fa:	75 1c                	jne    802418 <__umoddi3+0x48>
  8023fc:	39 f7                	cmp    %esi,%edi
  8023fe:	76 50                	jbe    802450 <__umoddi3+0x80>
  802400:	89 c8                	mov    %ecx,%eax
  802402:	89 f2                	mov    %esi,%edx
  802404:	f7 f7                	div    %edi
  802406:	89 d0                	mov    %edx,%eax
  802408:	31 d2                	xor    %edx,%edx
  80240a:	83 c4 1c             	add    $0x1c,%esp
  80240d:	5b                   	pop    %ebx
  80240e:	5e                   	pop    %esi
  80240f:	5f                   	pop    %edi
  802410:	5d                   	pop    %ebp
  802411:	c3                   	ret    
  802412:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802418:	39 f2                	cmp    %esi,%edx
  80241a:	89 d0                	mov    %edx,%eax
  80241c:	77 52                	ja     802470 <__umoddi3+0xa0>
  80241e:	0f bd ea             	bsr    %edx,%ebp
  802421:	83 f5 1f             	xor    $0x1f,%ebp
  802424:	75 5a                	jne    802480 <__umoddi3+0xb0>
  802426:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80242a:	0f 82 e0 00 00 00    	jb     802510 <__umoddi3+0x140>
  802430:	39 0c 24             	cmp    %ecx,(%esp)
  802433:	0f 86 d7 00 00 00    	jbe    802510 <__umoddi3+0x140>
  802439:	8b 44 24 08          	mov    0x8(%esp),%eax
  80243d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802441:	83 c4 1c             	add    $0x1c,%esp
  802444:	5b                   	pop    %ebx
  802445:	5e                   	pop    %esi
  802446:	5f                   	pop    %edi
  802447:	5d                   	pop    %ebp
  802448:	c3                   	ret    
  802449:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802450:	85 ff                	test   %edi,%edi
  802452:	89 fd                	mov    %edi,%ebp
  802454:	75 0b                	jne    802461 <__umoddi3+0x91>
  802456:	b8 01 00 00 00       	mov    $0x1,%eax
  80245b:	31 d2                	xor    %edx,%edx
  80245d:	f7 f7                	div    %edi
  80245f:	89 c5                	mov    %eax,%ebp
  802461:	89 f0                	mov    %esi,%eax
  802463:	31 d2                	xor    %edx,%edx
  802465:	f7 f5                	div    %ebp
  802467:	89 c8                	mov    %ecx,%eax
  802469:	f7 f5                	div    %ebp
  80246b:	89 d0                	mov    %edx,%eax
  80246d:	eb 99                	jmp    802408 <__umoddi3+0x38>
  80246f:	90                   	nop
  802470:	89 c8                	mov    %ecx,%eax
  802472:	89 f2                	mov    %esi,%edx
  802474:	83 c4 1c             	add    $0x1c,%esp
  802477:	5b                   	pop    %ebx
  802478:	5e                   	pop    %esi
  802479:	5f                   	pop    %edi
  80247a:	5d                   	pop    %ebp
  80247b:	c3                   	ret    
  80247c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802480:	8b 34 24             	mov    (%esp),%esi
  802483:	bf 20 00 00 00       	mov    $0x20,%edi
  802488:	89 e9                	mov    %ebp,%ecx
  80248a:	29 ef                	sub    %ebp,%edi
  80248c:	d3 e0                	shl    %cl,%eax
  80248e:	89 f9                	mov    %edi,%ecx
  802490:	89 f2                	mov    %esi,%edx
  802492:	d3 ea                	shr    %cl,%edx
  802494:	89 e9                	mov    %ebp,%ecx
  802496:	09 c2                	or     %eax,%edx
  802498:	89 d8                	mov    %ebx,%eax
  80249a:	89 14 24             	mov    %edx,(%esp)
  80249d:	89 f2                	mov    %esi,%edx
  80249f:	d3 e2                	shl    %cl,%edx
  8024a1:	89 f9                	mov    %edi,%ecx
  8024a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8024a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8024ab:	d3 e8                	shr    %cl,%eax
  8024ad:	89 e9                	mov    %ebp,%ecx
  8024af:	89 c6                	mov    %eax,%esi
  8024b1:	d3 e3                	shl    %cl,%ebx
  8024b3:	89 f9                	mov    %edi,%ecx
  8024b5:	89 d0                	mov    %edx,%eax
  8024b7:	d3 e8                	shr    %cl,%eax
  8024b9:	89 e9                	mov    %ebp,%ecx
  8024bb:	09 d8                	or     %ebx,%eax
  8024bd:	89 d3                	mov    %edx,%ebx
  8024bf:	89 f2                	mov    %esi,%edx
  8024c1:	f7 34 24             	divl   (%esp)
  8024c4:	89 d6                	mov    %edx,%esi
  8024c6:	d3 e3                	shl    %cl,%ebx
  8024c8:	f7 64 24 04          	mull   0x4(%esp)
  8024cc:	39 d6                	cmp    %edx,%esi
  8024ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024d2:	89 d1                	mov    %edx,%ecx
  8024d4:	89 c3                	mov    %eax,%ebx
  8024d6:	72 08                	jb     8024e0 <__umoddi3+0x110>
  8024d8:	75 11                	jne    8024eb <__umoddi3+0x11b>
  8024da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8024de:	73 0b                	jae    8024eb <__umoddi3+0x11b>
  8024e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8024e4:	1b 14 24             	sbb    (%esp),%edx
  8024e7:	89 d1                	mov    %edx,%ecx
  8024e9:	89 c3                	mov    %eax,%ebx
  8024eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8024ef:	29 da                	sub    %ebx,%edx
  8024f1:	19 ce                	sbb    %ecx,%esi
  8024f3:	89 f9                	mov    %edi,%ecx
  8024f5:	89 f0                	mov    %esi,%eax
  8024f7:	d3 e0                	shl    %cl,%eax
  8024f9:	89 e9                	mov    %ebp,%ecx
  8024fb:	d3 ea                	shr    %cl,%edx
  8024fd:	89 e9                	mov    %ebp,%ecx
  8024ff:	d3 ee                	shr    %cl,%esi
  802501:	09 d0                	or     %edx,%eax
  802503:	89 f2                	mov    %esi,%edx
  802505:	83 c4 1c             	add    $0x1c,%esp
  802508:	5b                   	pop    %ebx
  802509:	5e                   	pop    %esi
  80250a:	5f                   	pop    %edi
  80250b:	5d                   	pop    %ebp
  80250c:	c3                   	ret    
  80250d:	8d 76 00             	lea    0x0(%esi),%esi
  802510:	29 f9                	sub    %edi,%ecx
  802512:	19 d6                	sbb    %edx,%esi
  802514:	89 74 24 04          	mov    %esi,0x4(%esp)
  802518:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80251c:	e9 18 ff ff ff       	jmp    802439 <__umoddi3+0x69>
