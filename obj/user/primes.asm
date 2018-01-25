
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
  800047:	e8 b4 10 00 00       	call   801100 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 40 80 00       	mov    0x804004,%eax
  800053:	8b 40 68             	mov    0x68(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 60 22 80 00       	push   $0x802260
  800060:	e8 f0 01 00 00       	call   800255 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 7a 0e 00 00       	call   800ee4 <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 6c 22 80 00       	push   $0x80226c
  800079:	6a 1a                	push   $0x1a
  80007b:	68 75 22 80 00       	push   $0x802275
  800080:	e8 f7 00 00 00       	call   80017c <_panic>
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
  800094:	e8 67 10 00 00       	call   801100 <ipc_recv>
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
  8000ab:	e8 c8 10 00 00       	call   801178 <ipc_send>
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
  8000ba:	e8 25 0e 00 00       	call   800ee4 <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 6c 22 80 00       	push   $0x80226c
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 75 22 80 00       	push   $0x802275
  8000d2:	e8 a5 00 00 00       	call   80017c <_panic>
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
  8000eb:	e8 88 10 00 00       	call   801178 <ipc_send>
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
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800100:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800103:	e8 97 0a 00 00       	call   800b9f <sys_getenvid>
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	89 c2                	mov    %eax,%edx
  80010f:	c1 e2 07             	shl    $0x7,%edx
  800112:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800119:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011e:	85 db                	test   %ebx,%ebx
  800120:	7e 07                	jle    800129 <libmain+0x31>
		binaryname = argv[0];
  800122:	8b 06                	mov    (%esi),%eax
  800124:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800129:	83 ec 08             	sub    $0x8,%esp
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
  80012e:	e8 82 ff ff ff       	call   8000b5 <umain>

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
  800148:	a1 08 40 80 00       	mov    0x804008,%eax
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
  800168:	e8 78 12 00 00       	call   8013e5 <close_all>
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
  80019a:	68 90 22 80 00       	push   $0x802290
  80019f:	e8 b1 00 00 00       	call   800255 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a4:	83 c4 18             	add    $0x18,%esp
  8001a7:	53                   	push   %ebx
  8001a8:	ff 75 10             	pushl  0x10(%ebp)
  8001ab:	e8 54 00 00 00       	call   800204 <vcprintf>
	cprintf("\n");
  8001b0:	c7 04 24 5b 27 80 00 	movl   $0x80275b,(%esp)
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
  8002b8:	e8 13 1d 00 00       	call   801fd0 <__udivdi3>
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
  8002fb:	e8 00 1e 00 00       	call   802100 <__umoddi3>
  800300:	83 c4 14             	add    $0x14,%esp
  800303:	0f be 80 b3 22 80 00 	movsbl 0x8022b3(%eax),%eax
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
  8003ff:	ff 24 85 00 24 80 00 	jmp    *0x802400(,%eax,4)
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
  8004c3:	8b 14 85 60 25 80 00 	mov    0x802560(,%eax,4),%edx
  8004ca:	85 d2                	test   %edx,%edx
  8004cc:	75 18                	jne    8004e6 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004ce:	50                   	push   %eax
  8004cf:	68 cb 22 80 00       	push   $0x8022cb
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
  8004e7:	68 29 27 80 00       	push   $0x802729
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
  80050b:	b8 c4 22 80 00       	mov    $0x8022c4,%eax
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
  800b86:	68 bf 25 80 00       	push   $0x8025bf
  800b8b:	6a 23                	push   $0x23
  800b8d:	68 dc 25 80 00       	push   $0x8025dc
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
  800c07:	68 bf 25 80 00       	push   $0x8025bf
  800c0c:	6a 23                	push   $0x23
  800c0e:	68 dc 25 80 00       	push   $0x8025dc
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
  800c49:	68 bf 25 80 00       	push   $0x8025bf
  800c4e:	6a 23                	push   $0x23
  800c50:	68 dc 25 80 00       	push   $0x8025dc
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
  800c8b:	68 bf 25 80 00       	push   $0x8025bf
  800c90:	6a 23                	push   $0x23
  800c92:	68 dc 25 80 00       	push   $0x8025dc
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
  800ccd:	68 bf 25 80 00       	push   $0x8025bf
  800cd2:	6a 23                	push   $0x23
  800cd4:	68 dc 25 80 00       	push   $0x8025dc
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
  800d0f:	68 bf 25 80 00       	push   $0x8025bf
  800d14:	6a 23                	push   $0x23
  800d16:	68 dc 25 80 00       	push   $0x8025dc
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
  800d51:	68 bf 25 80 00       	push   $0x8025bf
  800d56:	6a 23                	push   $0x23
  800d58:	68 dc 25 80 00       	push   $0x8025dc
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
  800db5:	68 bf 25 80 00       	push   $0x8025bf
  800dba:	6a 23                	push   $0x23
  800dbc:	68 dc 25 80 00       	push   $0x8025dc
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

00800e0e <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	53                   	push   %ebx
  800e12:	83 ec 04             	sub    $0x4,%esp
  800e15:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e18:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800e1a:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e1e:	74 11                	je     800e31 <pgfault+0x23>
  800e20:	89 d8                	mov    %ebx,%eax
  800e22:	c1 e8 0c             	shr    $0xc,%eax
  800e25:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e2c:	f6 c4 08             	test   $0x8,%ah
  800e2f:	75 14                	jne    800e45 <pgfault+0x37>
		panic("faulting access");
  800e31:	83 ec 04             	sub    $0x4,%esp
  800e34:	68 ea 25 80 00       	push   $0x8025ea
  800e39:	6a 1e                	push   $0x1e
  800e3b:	68 fa 25 80 00       	push   $0x8025fa
  800e40:	e8 37 f3 ff ff       	call   80017c <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e45:	83 ec 04             	sub    $0x4,%esp
  800e48:	6a 07                	push   $0x7
  800e4a:	68 00 f0 7f 00       	push   $0x7ff000
  800e4f:	6a 00                	push   $0x0
  800e51:	e8 87 fd ff ff       	call   800bdd <sys_page_alloc>
	if (r < 0) {
  800e56:	83 c4 10             	add    $0x10,%esp
  800e59:	85 c0                	test   %eax,%eax
  800e5b:	79 12                	jns    800e6f <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e5d:	50                   	push   %eax
  800e5e:	68 05 26 80 00       	push   $0x802605
  800e63:	6a 2c                	push   $0x2c
  800e65:	68 fa 25 80 00       	push   $0x8025fa
  800e6a:	e8 0d f3 ff ff       	call   80017c <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e6f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e75:	83 ec 04             	sub    $0x4,%esp
  800e78:	68 00 10 00 00       	push   $0x1000
  800e7d:	53                   	push   %ebx
  800e7e:	68 00 f0 7f 00       	push   $0x7ff000
  800e83:	e8 4c fb ff ff       	call   8009d4 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e88:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e8f:	53                   	push   %ebx
  800e90:	6a 00                	push   $0x0
  800e92:	68 00 f0 7f 00       	push   $0x7ff000
  800e97:	6a 00                	push   $0x0
  800e99:	e8 82 fd ff ff       	call   800c20 <sys_page_map>
	if (r < 0) {
  800e9e:	83 c4 20             	add    $0x20,%esp
  800ea1:	85 c0                	test   %eax,%eax
  800ea3:	79 12                	jns    800eb7 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800ea5:	50                   	push   %eax
  800ea6:	68 05 26 80 00       	push   $0x802605
  800eab:	6a 33                	push   $0x33
  800ead:	68 fa 25 80 00       	push   $0x8025fa
  800eb2:	e8 c5 f2 ff ff       	call   80017c <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800eb7:	83 ec 08             	sub    $0x8,%esp
  800eba:	68 00 f0 7f 00       	push   $0x7ff000
  800ebf:	6a 00                	push   $0x0
  800ec1:	e8 9c fd ff ff       	call   800c62 <sys_page_unmap>
	if (r < 0) {
  800ec6:	83 c4 10             	add    $0x10,%esp
  800ec9:	85 c0                	test   %eax,%eax
  800ecb:	79 12                	jns    800edf <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800ecd:	50                   	push   %eax
  800ece:	68 05 26 80 00       	push   $0x802605
  800ed3:	6a 37                	push   $0x37
  800ed5:	68 fa 25 80 00       	push   $0x8025fa
  800eda:	e8 9d f2 ff ff       	call   80017c <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800edf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ee2:	c9                   	leave  
  800ee3:	c3                   	ret    

00800ee4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ee4:	55                   	push   %ebp
  800ee5:	89 e5                	mov    %esp,%ebp
  800ee7:	57                   	push   %edi
  800ee8:	56                   	push   %esi
  800ee9:	53                   	push   %ebx
  800eea:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800eed:	68 0e 0e 80 00       	push   $0x800e0e
  800ef2:	e8 0d 10 00 00       	call   801f04 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ef7:	b8 07 00 00 00       	mov    $0x7,%eax
  800efc:	cd 30                	int    $0x30
  800efe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800f01:	83 c4 10             	add    $0x10,%esp
  800f04:	85 c0                	test   %eax,%eax
  800f06:	79 17                	jns    800f1f <fork+0x3b>
		panic("fork fault %e");
  800f08:	83 ec 04             	sub    $0x4,%esp
  800f0b:	68 1e 26 80 00       	push   $0x80261e
  800f10:	68 84 00 00 00       	push   $0x84
  800f15:	68 fa 25 80 00       	push   $0x8025fa
  800f1a:	e8 5d f2 ff ff       	call   80017c <_panic>
  800f1f:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f21:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f25:	75 25                	jne    800f4c <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f27:	e8 73 fc ff ff       	call   800b9f <sys_getenvid>
  800f2c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f31:	89 c2                	mov    %eax,%edx
  800f33:	c1 e2 07             	shl    $0x7,%edx
  800f36:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800f3d:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f42:	b8 00 00 00 00       	mov    $0x0,%eax
  800f47:	e9 61 01 00 00       	jmp    8010ad <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f4c:	83 ec 04             	sub    $0x4,%esp
  800f4f:	6a 07                	push   $0x7
  800f51:	68 00 f0 bf ee       	push   $0xeebff000
  800f56:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f59:	e8 7f fc ff ff       	call   800bdd <sys_page_alloc>
  800f5e:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f61:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f66:	89 d8                	mov    %ebx,%eax
  800f68:	c1 e8 16             	shr    $0x16,%eax
  800f6b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f72:	a8 01                	test   $0x1,%al
  800f74:	0f 84 fc 00 00 00    	je     801076 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f7a:	89 d8                	mov    %ebx,%eax
  800f7c:	c1 e8 0c             	shr    $0xc,%eax
  800f7f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f86:	f6 c2 01             	test   $0x1,%dl
  800f89:	0f 84 e7 00 00 00    	je     801076 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f8f:	89 c6                	mov    %eax,%esi
  800f91:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f94:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f9b:	f6 c6 04             	test   $0x4,%dh
  800f9e:	74 39                	je     800fd9 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800fa0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fa7:	83 ec 0c             	sub    $0xc,%esp
  800faa:	25 07 0e 00 00       	and    $0xe07,%eax
  800faf:	50                   	push   %eax
  800fb0:	56                   	push   %esi
  800fb1:	57                   	push   %edi
  800fb2:	56                   	push   %esi
  800fb3:	6a 00                	push   $0x0
  800fb5:	e8 66 fc ff ff       	call   800c20 <sys_page_map>
		if (r < 0) {
  800fba:	83 c4 20             	add    $0x20,%esp
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	0f 89 b1 00 00 00    	jns    801076 <fork+0x192>
		    	panic("sys page map fault %e");
  800fc5:	83 ec 04             	sub    $0x4,%esp
  800fc8:	68 2c 26 80 00       	push   $0x80262c
  800fcd:	6a 54                	push   $0x54
  800fcf:	68 fa 25 80 00       	push   $0x8025fa
  800fd4:	e8 a3 f1 ff ff       	call   80017c <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800fd9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fe0:	f6 c2 02             	test   $0x2,%dl
  800fe3:	75 0c                	jne    800ff1 <fork+0x10d>
  800fe5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fec:	f6 c4 08             	test   $0x8,%ah
  800fef:	74 5b                	je     80104c <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800ff1:	83 ec 0c             	sub    $0xc,%esp
  800ff4:	68 05 08 00 00       	push   $0x805
  800ff9:	56                   	push   %esi
  800ffa:	57                   	push   %edi
  800ffb:	56                   	push   %esi
  800ffc:	6a 00                	push   $0x0
  800ffe:	e8 1d fc ff ff       	call   800c20 <sys_page_map>
		if (r < 0) {
  801003:	83 c4 20             	add    $0x20,%esp
  801006:	85 c0                	test   %eax,%eax
  801008:	79 14                	jns    80101e <fork+0x13a>
		    	panic("sys page map fault %e");
  80100a:	83 ec 04             	sub    $0x4,%esp
  80100d:	68 2c 26 80 00       	push   $0x80262c
  801012:	6a 5b                	push   $0x5b
  801014:	68 fa 25 80 00       	push   $0x8025fa
  801019:	e8 5e f1 ff ff       	call   80017c <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  80101e:	83 ec 0c             	sub    $0xc,%esp
  801021:	68 05 08 00 00       	push   $0x805
  801026:	56                   	push   %esi
  801027:	6a 00                	push   $0x0
  801029:	56                   	push   %esi
  80102a:	6a 00                	push   $0x0
  80102c:	e8 ef fb ff ff       	call   800c20 <sys_page_map>
		if (r < 0) {
  801031:	83 c4 20             	add    $0x20,%esp
  801034:	85 c0                	test   %eax,%eax
  801036:	79 3e                	jns    801076 <fork+0x192>
		    	panic("sys page map fault %e");
  801038:	83 ec 04             	sub    $0x4,%esp
  80103b:	68 2c 26 80 00       	push   $0x80262c
  801040:	6a 5f                	push   $0x5f
  801042:	68 fa 25 80 00       	push   $0x8025fa
  801047:	e8 30 f1 ff ff       	call   80017c <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80104c:	83 ec 0c             	sub    $0xc,%esp
  80104f:	6a 05                	push   $0x5
  801051:	56                   	push   %esi
  801052:	57                   	push   %edi
  801053:	56                   	push   %esi
  801054:	6a 00                	push   $0x0
  801056:	e8 c5 fb ff ff       	call   800c20 <sys_page_map>
		if (r < 0) {
  80105b:	83 c4 20             	add    $0x20,%esp
  80105e:	85 c0                	test   %eax,%eax
  801060:	79 14                	jns    801076 <fork+0x192>
		    	panic("sys page map fault %e");
  801062:	83 ec 04             	sub    $0x4,%esp
  801065:	68 2c 26 80 00       	push   $0x80262c
  80106a:	6a 64                	push   $0x64
  80106c:	68 fa 25 80 00       	push   $0x8025fa
  801071:	e8 06 f1 ff ff       	call   80017c <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801076:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80107c:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801082:	0f 85 de fe ff ff    	jne    800f66 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801088:	a1 04 40 80 00       	mov    0x804004,%eax
  80108d:	8b 40 70             	mov    0x70(%eax),%eax
  801090:	83 ec 08             	sub    $0x8,%esp
  801093:	50                   	push   %eax
  801094:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801097:	57                   	push   %edi
  801098:	e8 8b fc ff ff       	call   800d28 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80109d:	83 c4 08             	add    $0x8,%esp
  8010a0:	6a 02                	push   $0x2
  8010a2:	57                   	push   %edi
  8010a3:	e8 fc fb ff ff       	call   800ca4 <sys_env_set_status>
	
	return envid;
  8010a8:	83 c4 10             	add    $0x10,%esp
  8010ab:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8010ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b0:	5b                   	pop    %ebx
  8010b1:	5e                   	pop    %esi
  8010b2:	5f                   	pop    %edi
  8010b3:	5d                   	pop    %ebp
  8010b4:	c3                   	ret    

008010b5 <sfork>:

envid_t
sfork(void)
{
  8010b5:	55                   	push   %ebp
  8010b6:	89 e5                	mov    %esp,%ebp
	return 0;
}
  8010b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010bd:	5d                   	pop    %ebp
  8010be:	c3                   	ret    

008010bf <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	56                   	push   %esi
  8010c3:	53                   	push   %ebx
  8010c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  8010c7:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  8010cd:	83 ec 08             	sub    $0x8,%esp
  8010d0:	53                   	push   %ebx
  8010d1:	68 44 26 80 00       	push   $0x802644
  8010d6:	e8 7a f1 ff ff       	call   800255 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8010db:	c7 04 24 42 01 80 00 	movl   $0x800142,(%esp)
  8010e2:	e8 e7 fc ff ff       	call   800dce <sys_thread_create>
  8010e7:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8010e9:	83 c4 08             	add    $0x8,%esp
  8010ec:	53                   	push   %ebx
  8010ed:	68 44 26 80 00       	push   $0x802644
  8010f2:	e8 5e f1 ff ff       	call   800255 <cprintf>
	return id;
	//return 0;
}
  8010f7:	89 f0                	mov    %esi,%eax
  8010f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010fc:	5b                   	pop    %ebx
  8010fd:	5e                   	pop    %esi
  8010fe:	5d                   	pop    %ebp
  8010ff:	c3                   	ret    

00801100 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
  801103:	56                   	push   %esi
  801104:	53                   	push   %ebx
  801105:	8b 75 08             	mov    0x8(%ebp),%esi
  801108:	8b 45 0c             	mov    0xc(%ebp),%eax
  80110b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80110e:	85 c0                	test   %eax,%eax
  801110:	75 12                	jne    801124 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801112:	83 ec 0c             	sub    $0xc,%esp
  801115:	68 00 00 c0 ee       	push   $0xeec00000
  80111a:	e8 6e fc ff ff       	call   800d8d <sys_ipc_recv>
  80111f:	83 c4 10             	add    $0x10,%esp
  801122:	eb 0c                	jmp    801130 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801124:	83 ec 0c             	sub    $0xc,%esp
  801127:	50                   	push   %eax
  801128:	e8 60 fc ff ff       	call   800d8d <sys_ipc_recv>
  80112d:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801130:	85 f6                	test   %esi,%esi
  801132:	0f 95 c1             	setne  %cl
  801135:	85 db                	test   %ebx,%ebx
  801137:	0f 95 c2             	setne  %dl
  80113a:	84 d1                	test   %dl,%cl
  80113c:	74 09                	je     801147 <ipc_recv+0x47>
  80113e:	89 c2                	mov    %eax,%edx
  801140:	c1 ea 1f             	shr    $0x1f,%edx
  801143:	84 d2                	test   %dl,%dl
  801145:	75 2a                	jne    801171 <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801147:	85 f6                	test   %esi,%esi
  801149:	74 0d                	je     801158 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80114b:	a1 04 40 80 00       	mov    0x804004,%eax
  801150:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801156:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801158:	85 db                	test   %ebx,%ebx
  80115a:	74 0d                	je     801169 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80115c:	a1 04 40 80 00       	mov    0x804004,%eax
  801161:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  801167:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801169:	a1 04 40 80 00       	mov    0x804004,%eax
  80116e:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  801171:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801174:	5b                   	pop    %ebx
  801175:	5e                   	pop    %esi
  801176:	5d                   	pop    %ebp
  801177:	c3                   	ret    

00801178 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
  80117b:	57                   	push   %edi
  80117c:	56                   	push   %esi
  80117d:	53                   	push   %ebx
  80117e:	83 ec 0c             	sub    $0xc,%esp
  801181:	8b 7d 08             	mov    0x8(%ebp),%edi
  801184:	8b 75 0c             	mov    0xc(%ebp),%esi
  801187:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80118a:	85 db                	test   %ebx,%ebx
  80118c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801191:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801194:	ff 75 14             	pushl  0x14(%ebp)
  801197:	53                   	push   %ebx
  801198:	56                   	push   %esi
  801199:	57                   	push   %edi
  80119a:	e8 cb fb ff ff       	call   800d6a <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80119f:	89 c2                	mov    %eax,%edx
  8011a1:	c1 ea 1f             	shr    $0x1f,%edx
  8011a4:	83 c4 10             	add    $0x10,%esp
  8011a7:	84 d2                	test   %dl,%dl
  8011a9:	74 17                	je     8011c2 <ipc_send+0x4a>
  8011ab:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011ae:	74 12                	je     8011c2 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8011b0:	50                   	push   %eax
  8011b1:	68 67 26 80 00       	push   $0x802667
  8011b6:	6a 47                	push   $0x47
  8011b8:	68 75 26 80 00       	push   $0x802675
  8011bd:	e8 ba ef ff ff       	call   80017c <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8011c2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011c5:	75 07                	jne    8011ce <ipc_send+0x56>
			sys_yield();
  8011c7:	e8 f2 f9 ff ff       	call   800bbe <sys_yield>
  8011cc:	eb c6                	jmp    801194 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	75 c2                	jne    801194 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8011d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d5:	5b                   	pop    %ebx
  8011d6:	5e                   	pop    %esi
  8011d7:	5f                   	pop    %edi
  8011d8:	5d                   	pop    %ebp
  8011d9:	c3                   	ret    

008011da <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011e0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011e5:	89 c2                	mov    %eax,%edx
  8011e7:	c1 e2 07             	shl    $0x7,%edx
  8011ea:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  8011f1:	8b 52 5c             	mov    0x5c(%edx),%edx
  8011f4:	39 ca                	cmp    %ecx,%edx
  8011f6:	75 11                	jne    801209 <ipc_find_env+0x2f>
			return envs[i].env_id;
  8011f8:	89 c2                	mov    %eax,%edx
  8011fa:	c1 e2 07             	shl    $0x7,%edx
  8011fd:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801204:	8b 40 54             	mov    0x54(%eax),%eax
  801207:	eb 0f                	jmp    801218 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801209:	83 c0 01             	add    $0x1,%eax
  80120c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801211:	75 d2                	jne    8011e5 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801213:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801218:	5d                   	pop    %ebp
  801219:	c3                   	ret    

0080121a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80121d:	8b 45 08             	mov    0x8(%ebp),%eax
  801220:	05 00 00 00 30       	add    $0x30000000,%eax
  801225:	c1 e8 0c             	shr    $0xc,%eax
}
  801228:	5d                   	pop    %ebp
  801229:	c3                   	ret    

0080122a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80122a:	55                   	push   %ebp
  80122b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80122d:	8b 45 08             	mov    0x8(%ebp),%eax
  801230:	05 00 00 00 30       	add    $0x30000000,%eax
  801235:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80123a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80123f:	5d                   	pop    %ebp
  801240:	c3                   	ret    

00801241 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
  801244:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801247:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80124c:	89 c2                	mov    %eax,%edx
  80124e:	c1 ea 16             	shr    $0x16,%edx
  801251:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801258:	f6 c2 01             	test   $0x1,%dl
  80125b:	74 11                	je     80126e <fd_alloc+0x2d>
  80125d:	89 c2                	mov    %eax,%edx
  80125f:	c1 ea 0c             	shr    $0xc,%edx
  801262:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801269:	f6 c2 01             	test   $0x1,%dl
  80126c:	75 09                	jne    801277 <fd_alloc+0x36>
			*fd_store = fd;
  80126e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801270:	b8 00 00 00 00       	mov    $0x0,%eax
  801275:	eb 17                	jmp    80128e <fd_alloc+0x4d>
  801277:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80127c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801281:	75 c9                	jne    80124c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801283:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801289:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80128e:	5d                   	pop    %ebp
  80128f:	c3                   	ret    

00801290 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
  801293:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801296:	83 f8 1f             	cmp    $0x1f,%eax
  801299:	77 36                	ja     8012d1 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80129b:	c1 e0 0c             	shl    $0xc,%eax
  80129e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012a3:	89 c2                	mov    %eax,%edx
  8012a5:	c1 ea 16             	shr    $0x16,%edx
  8012a8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012af:	f6 c2 01             	test   $0x1,%dl
  8012b2:	74 24                	je     8012d8 <fd_lookup+0x48>
  8012b4:	89 c2                	mov    %eax,%edx
  8012b6:	c1 ea 0c             	shr    $0xc,%edx
  8012b9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012c0:	f6 c2 01             	test   $0x1,%dl
  8012c3:	74 1a                	je     8012df <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c8:	89 02                	mov    %eax,(%edx)
	return 0;
  8012ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8012cf:	eb 13                	jmp    8012e4 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d6:	eb 0c                	jmp    8012e4 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012dd:	eb 05                	jmp    8012e4 <fd_lookup+0x54>
  8012df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012e4:	5d                   	pop    %ebp
  8012e5:	c3                   	ret    

008012e6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012e6:	55                   	push   %ebp
  8012e7:	89 e5                	mov    %esp,%ebp
  8012e9:	83 ec 08             	sub    $0x8,%esp
  8012ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ef:	ba 00 27 80 00       	mov    $0x802700,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012f4:	eb 13                	jmp    801309 <dev_lookup+0x23>
  8012f6:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012f9:	39 08                	cmp    %ecx,(%eax)
  8012fb:	75 0c                	jne    801309 <dev_lookup+0x23>
			*dev = devtab[i];
  8012fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801300:	89 01                	mov    %eax,(%ecx)
			return 0;
  801302:	b8 00 00 00 00       	mov    $0x0,%eax
  801307:	eb 2e                	jmp    801337 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801309:	8b 02                	mov    (%edx),%eax
  80130b:	85 c0                	test   %eax,%eax
  80130d:	75 e7                	jne    8012f6 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80130f:	a1 04 40 80 00       	mov    0x804004,%eax
  801314:	8b 40 54             	mov    0x54(%eax),%eax
  801317:	83 ec 04             	sub    $0x4,%esp
  80131a:	51                   	push   %ecx
  80131b:	50                   	push   %eax
  80131c:	68 80 26 80 00       	push   $0x802680
  801321:	e8 2f ef ff ff       	call   800255 <cprintf>
	*dev = 0;
  801326:	8b 45 0c             	mov    0xc(%ebp),%eax
  801329:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80132f:	83 c4 10             	add    $0x10,%esp
  801332:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801337:	c9                   	leave  
  801338:	c3                   	ret    

00801339 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801339:	55                   	push   %ebp
  80133a:	89 e5                	mov    %esp,%ebp
  80133c:	56                   	push   %esi
  80133d:	53                   	push   %ebx
  80133e:	83 ec 10             	sub    $0x10,%esp
  801341:	8b 75 08             	mov    0x8(%ebp),%esi
  801344:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801347:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134a:	50                   	push   %eax
  80134b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801351:	c1 e8 0c             	shr    $0xc,%eax
  801354:	50                   	push   %eax
  801355:	e8 36 ff ff ff       	call   801290 <fd_lookup>
  80135a:	83 c4 08             	add    $0x8,%esp
  80135d:	85 c0                	test   %eax,%eax
  80135f:	78 05                	js     801366 <fd_close+0x2d>
	    || fd != fd2)
  801361:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801364:	74 0c                	je     801372 <fd_close+0x39>
		return (must_exist ? r : 0);
  801366:	84 db                	test   %bl,%bl
  801368:	ba 00 00 00 00       	mov    $0x0,%edx
  80136d:	0f 44 c2             	cmove  %edx,%eax
  801370:	eb 41                	jmp    8013b3 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801372:	83 ec 08             	sub    $0x8,%esp
  801375:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801378:	50                   	push   %eax
  801379:	ff 36                	pushl  (%esi)
  80137b:	e8 66 ff ff ff       	call   8012e6 <dev_lookup>
  801380:	89 c3                	mov    %eax,%ebx
  801382:	83 c4 10             	add    $0x10,%esp
  801385:	85 c0                	test   %eax,%eax
  801387:	78 1a                	js     8013a3 <fd_close+0x6a>
		if (dev->dev_close)
  801389:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80138f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801394:	85 c0                	test   %eax,%eax
  801396:	74 0b                	je     8013a3 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801398:	83 ec 0c             	sub    $0xc,%esp
  80139b:	56                   	push   %esi
  80139c:	ff d0                	call   *%eax
  80139e:	89 c3                	mov    %eax,%ebx
  8013a0:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013a3:	83 ec 08             	sub    $0x8,%esp
  8013a6:	56                   	push   %esi
  8013a7:	6a 00                	push   $0x0
  8013a9:	e8 b4 f8 ff ff       	call   800c62 <sys_page_unmap>
	return r;
  8013ae:	83 c4 10             	add    $0x10,%esp
  8013b1:	89 d8                	mov    %ebx,%eax
}
  8013b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013b6:	5b                   	pop    %ebx
  8013b7:	5e                   	pop    %esi
  8013b8:	5d                   	pop    %ebp
  8013b9:	c3                   	ret    

008013ba <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013ba:	55                   	push   %ebp
  8013bb:	89 e5                	mov    %esp,%ebp
  8013bd:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c3:	50                   	push   %eax
  8013c4:	ff 75 08             	pushl  0x8(%ebp)
  8013c7:	e8 c4 fe ff ff       	call   801290 <fd_lookup>
  8013cc:	83 c4 08             	add    $0x8,%esp
  8013cf:	85 c0                	test   %eax,%eax
  8013d1:	78 10                	js     8013e3 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013d3:	83 ec 08             	sub    $0x8,%esp
  8013d6:	6a 01                	push   $0x1
  8013d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8013db:	e8 59 ff ff ff       	call   801339 <fd_close>
  8013e0:	83 c4 10             	add    $0x10,%esp
}
  8013e3:	c9                   	leave  
  8013e4:	c3                   	ret    

008013e5 <close_all>:

void
close_all(void)
{
  8013e5:	55                   	push   %ebp
  8013e6:	89 e5                	mov    %esp,%ebp
  8013e8:	53                   	push   %ebx
  8013e9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013ec:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013f1:	83 ec 0c             	sub    $0xc,%esp
  8013f4:	53                   	push   %ebx
  8013f5:	e8 c0 ff ff ff       	call   8013ba <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013fa:	83 c3 01             	add    $0x1,%ebx
  8013fd:	83 c4 10             	add    $0x10,%esp
  801400:	83 fb 20             	cmp    $0x20,%ebx
  801403:	75 ec                	jne    8013f1 <close_all+0xc>
		close(i);
}
  801405:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801408:	c9                   	leave  
  801409:	c3                   	ret    

0080140a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	57                   	push   %edi
  80140e:	56                   	push   %esi
  80140f:	53                   	push   %ebx
  801410:	83 ec 2c             	sub    $0x2c,%esp
  801413:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801416:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801419:	50                   	push   %eax
  80141a:	ff 75 08             	pushl  0x8(%ebp)
  80141d:	e8 6e fe ff ff       	call   801290 <fd_lookup>
  801422:	83 c4 08             	add    $0x8,%esp
  801425:	85 c0                	test   %eax,%eax
  801427:	0f 88 c1 00 00 00    	js     8014ee <dup+0xe4>
		return r;
	close(newfdnum);
  80142d:	83 ec 0c             	sub    $0xc,%esp
  801430:	56                   	push   %esi
  801431:	e8 84 ff ff ff       	call   8013ba <close>

	newfd = INDEX2FD(newfdnum);
  801436:	89 f3                	mov    %esi,%ebx
  801438:	c1 e3 0c             	shl    $0xc,%ebx
  80143b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801441:	83 c4 04             	add    $0x4,%esp
  801444:	ff 75 e4             	pushl  -0x1c(%ebp)
  801447:	e8 de fd ff ff       	call   80122a <fd2data>
  80144c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80144e:	89 1c 24             	mov    %ebx,(%esp)
  801451:	e8 d4 fd ff ff       	call   80122a <fd2data>
  801456:	83 c4 10             	add    $0x10,%esp
  801459:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80145c:	89 f8                	mov    %edi,%eax
  80145e:	c1 e8 16             	shr    $0x16,%eax
  801461:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801468:	a8 01                	test   $0x1,%al
  80146a:	74 37                	je     8014a3 <dup+0x99>
  80146c:	89 f8                	mov    %edi,%eax
  80146e:	c1 e8 0c             	shr    $0xc,%eax
  801471:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801478:	f6 c2 01             	test   $0x1,%dl
  80147b:	74 26                	je     8014a3 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80147d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801484:	83 ec 0c             	sub    $0xc,%esp
  801487:	25 07 0e 00 00       	and    $0xe07,%eax
  80148c:	50                   	push   %eax
  80148d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801490:	6a 00                	push   $0x0
  801492:	57                   	push   %edi
  801493:	6a 00                	push   $0x0
  801495:	e8 86 f7 ff ff       	call   800c20 <sys_page_map>
  80149a:	89 c7                	mov    %eax,%edi
  80149c:	83 c4 20             	add    $0x20,%esp
  80149f:	85 c0                	test   %eax,%eax
  8014a1:	78 2e                	js     8014d1 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014a3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014a6:	89 d0                	mov    %edx,%eax
  8014a8:	c1 e8 0c             	shr    $0xc,%eax
  8014ab:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014b2:	83 ec 0c             	sub    $0xc,%esp
  8014b5:	25 07 0e 00 00       	and    $0xe07,%eax
  8014ba:	50                   	push   %eax
  8014bb:	53                   	push   %ebx
  8014bc:	6a 00                	push   $0x0
  8014be:	52                   	push   %edx
  8014bf:	6a 00                	push   $0x0
  8014c1:	e8 5a f7 ff ff       	call   800c20 <sys_page_map>
  8014c6:	89 c7                	mov    %eax,%edi
  8014c8:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014cb:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014cd:	85 ff                	test   %edi,%edi
  8014cf:	79 1d                	jns    8014ee <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014d1:	83 ec 08             	sub    $0x8,%esp
  8014d4:	53                   	push   %ebx
  8014d5:	6a 00                	push   $0x0
  8014d7:	e8 86 f7 ff ff       	call   800c62 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014dc:	83 c4 08             	add    $0x8,%esp
  8014df:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014e2:	6a 00                	push   $0x0
  8014e4:	e8 79 f7 ff ff       	call   800c62 <sys_page_unmap>
	return r;
  8014e9:	83 c4 10             	add    $0x10,%esp
  8014ec:	89 f8                	mov    %edi,%eax
}
  8014ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f1:	5b                   	pop    %ebx
  8014f2:	5e                   	pop    %esi
  8014f3:	5f                   	pop    %edi
  8014f4:	5d                   	pop    %ebp
  8014f5:	c3                   	ret    

008014f6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014f6:	55                   	push   %ebp
  8014f7:	89 e5                	mov    %esp,%ebp
  8014f9:	53                   	push   %ebx
  8014fa:	83 ec 14             	sub    $0x14,%esp
  8014fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801500:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801503:	50                   	push   %eax
  801504:	53                   	push   %ebx
  801505:	e8 86 fd ff ff       	call   801290 <fd_lookup>
  80150a:	83 c4 08             	add    $0x8,%esp
  80150d:	89 c2                	mov    %eax,%edx
  80150f:	85 c0                	test   %eax,%eax
  801511:	78 6d                	js     801580 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801513:	83 ec 08             	sub    $0x8,%esp
  801516:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801519:	50                   	push   %eax
  80151a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151d:	ff 30                	pushl  (%eax)
  80151f:	e8 c2 fd ff ff       	call   8012e6 <dev_lookup>
  801524:	83 c4 10             	add    $0x10,%esp
  801527:	85 c0                	test   %eax,%eax
  801529:	78 4c                	js     801577 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80152b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80152e:	8b 42 08             	mov    0x8(%edx),%eax
  801531:	83 e0 03             	and    $0x3,%eax
  801534:	83 f8 01             	cmp    $0x1,%eax
  801537:	75 21                	jne    80155a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801539:	a1 04 40 80 00       	mov    0x804004,%eax
  80153e:	8b 40 54             	mov    0x54(%eax),%eax
  801541:	83 ec 04             	sub    $0x4,%esp
  801544:	53                   	push   %ebx
  801545:	50                   	push   %eax
  801546:	68 c4 26 80 00       	push   $0x8026c4
  80154b:	e8 05 ed ff ff       	call   800255 <cprintf>
		return -E_INVAL;
  801550:	83 c4 10             	add    $0x10,%esp
  801553:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801558:	eb 26                	jmp    801580 <read+0x8a>
	}
	if (!dev->dev_read)
  80155a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80155d:	8b 40 08             	mov    0x8(%eax),%eax
  801560:	85 c0                	test   %eax,%eax
  801562:	74 17                	je     80157b <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801564:	83 ec 04             	sub    $0x4,%esp
  801567:	ff 75 10             	pushl  0x10(%ebp)
  80156a:	ff 75 0c             	pushl  0xc(%ebp)
  80156d:	52                   	push   %edx
  80156e:	ff d0                	call   *%eax
  801570:	89 c2                	mov    %eax,%edx
  801572:	83 c4 10             	add    $0x10,%esp
  801575:	eb 09                	jmp    801580 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801577:	89 c2                	mov    %eax,%edx
  801579:	eb 05                	jmp    801580 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80157b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801580:	89 d0                	mov    %edx,%eax
  801582:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801585:	c9                   	leave  
  801586:	c3                   	ret    

00801587 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801587:	55                   	push   %ebp
  801588:	89 e5                	mov    %esp,%ebp
  80158a:	57                   	push   %edi
  80158b:	56                   	push   %esi
  80158c:	53                   	push   %ebx
  80158d:	83 ec 0c             	sub    $0xc,%esp
  801590:	8b 7d 08             	mov    0x8(%ebp),%edi
  801593:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801596:	bb 00 00 00 00       	mov    $0x0,%ebx
  80159b:	eb 21                	jmp    8015be <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80159d:	83 ec 04             	sub    $0x4,%esp
  8015a0:	89 f0                	mov    %esi,%eax
  8015a2:	29 d8                	sub    %ebx,%eax
  8015a4:	50                   	push   %eax
  8015a5:	89 d8                	mov    %ebx,%eax
  8015a7:	03 45 0c             	add    0xc(%ebp),%eax
  8015aa:	50                   	push   %eax
  8015ab:	57                   	push   %edi
  8015ac:	e8 45 ff ff ff       	call   8014f6 <read>
		if (m < 0)
  8015b1:	83 c4 10             	add    $0x10,%esp
  8015b4:	85 c0                	test   %eax,%eax
  8015b6:	78 10                	js     8015c8 <readn+0x41>
			return m;
		if (m == 0)
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	74 0a                	je     8015c6 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015bc:	01 c3                	add    %eax,%ebx
  8015be:	39 f3                	cmp    %esi,%ebx
  8015c0:	72 db                	jb     80159d <readn+0x16>
  8015c2:	89 d8                	mov    %ebx,%eax
  8015c4:	eb 02                	jmp    8015c8 <readn+0x41>
  8015c6:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015cb:	5b                   	pop    %ebx
  8015cc:	5e                   	pop    %esi
  8015cd:	5f                   	pop    %edi
  8015ce:	5d                   	pop    %ebp
  8015cf:	c3                   	ret    

008015d0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	53                   	push   %ebx
  8015d4:	83 ec 14             	sub    $0x14,%esp
  8015d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015dd:	50                   	push   %eax
  8015de:	53                   	push   %ebx
  8015df:	e8 ac fc ff ff       	call   801290 <fd_lookup>
  8015e4:	83 c4 08             	add    $0x8,%esp
  8015e7:	89 c2                	mov    %eax,%edx
  8015e9:	85 c0                	test   %eax,%eax
  8015eb:	78 68                	js     801655 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ed:	83 ec 08             	sub    $0x8,%esp
  8015f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f3:	50                   	push   %eax
  8015f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f7:	ff 30                	pushl  (%eax)
  8015f9:	e8 e8 fc ff ff       	call   8012e6 <dev_lookup>
  8015fe:	83 c4 10             	add    $0x10,%esp
  801601:	85 c0                	test   %eax,%eax
  801603:	78 47                	js     80164c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801605:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801608:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80160c:	75 21                	jne    80162f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80160e:	a1 04 40 80 00       	mov    0x804004,%eax
  801613:	8b 40 54             	mov    0x54(%eax),%eax
  801616:	83 ec 04             	sub    $0x4,%esp
  801619:	53                   	push   %ebx
  80161a:	50                   	push   %eax
  80161b:	68 e0 26 80 00       	push   $0x8026e0
  801620:	e8 30 ec ff ff       	call   800255 <cprintf>
		return -E_INVAL;
  801625:	83 c4 10             	add    $0x10,%esp
  801628:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80162d:	eb 26                	jmp    801655 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80162f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801632:	8b 52 0c             	mov    0xc(%edx),%edx
  801635:	85 d2                	test   %edx,%edx
  801637:	74 17                	je     801650 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801639:	83 ec 04             	sub    $0x4,%esp
  80163c:	ff 75 10             	pushl  0x10(%ebp)
  80163f:	ff 75 0c             	pushl  0xc(%ebp)
  801642:	50                   	push   %eax
  801643:	ff d2                	call   *%edx
  801645:	89 c2                	mov    %eax,%edx
  801647:	83 c4 10             	add    $0x10,%esp
  80164a:	eb 09                	jmp    801655 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164c:	89 c2                	mov    %eax,%edx
  80164e:	eb 05                	jmp    801655 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801650:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801655:	89 d0                	mov    %edx,%eax
  801657:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165a:	c9                   	leave  
  80165b:	c3                   	ret    

0080165c <seek>:

int
seek(int fdnum, off_t offset)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801662:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801665:	50                   	push   %eax
  801666:	ff 75 08             	pushl  0x8(%ebp)
  801669:	e8 22 fc ff ff       	call   801290 <fd_lookup>
  80166e:	83 c4 08             	add    $0x8,%esp
  801671:	85 c0                	test   %eax,%eax
  801673:	78 0e                	js     801683 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801675:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801678:	8b 55 0c             	mov    0xc(%ebp),%edx
  80167b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80167e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801683:	c9                   	leave  
  801684:	c3                   	ret    

00801685 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801685:	55                   	push   %ebp
  801686:	89 e5                	mov    %esp,%ebp
  801688:	53                   	push   %ebx
  801689:	83 ec 14             	sub    $0x14,%esp
  80168c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801692:	50                   	push   %eax
  801693:	53                   	push   %ebx
  801694:	e8 f7 fb ff ff       	call   801290 <fd_lookup>
  801699:	83 c4 08             	add    $0x8,%esp
  80169c:	89 c2                	mov    %eax,%edx
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	78 65                	js     801707 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a2:	83 ec 08             	sub    $0x8,%esp
  8016a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a8:	50                   	push   %eax
  8016a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ac:	ff 30                	pushl  (%eax)
  8016ae:	e8 33 fc ff ff       	call   8012e6 <dev_lookup>
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	85 c0                	test   %eax,%eax
  8016b8:	78 44                	js     8016fe <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016bd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016c1:	75 21                	jne    8016e4 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016c3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016c8:	8b 40 54             	mov    0x54(%eax),%eax
  8016cb:	83 ec 04             	sub    $0x4,%esp
  8016ce:	53                   	push   %ebx
  8016cf:	50                   	push   %eax
  8016d0:	68 a0 26 80 00       	push   $0x8026a0
  8016d5:	e8 7b eb ff ff       	call   800255 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016da:	83 c4 10             	add    $0x10,%esp
  8016dd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016e2:	eb 23                	jmp    801707 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016e7:	8b 52 18             	mov    0x18(%edx),%edx
  8016ea:	85 d2                	test   %edx,%edx
  8016ec:	74 14                	je     801702 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016ee:	83 ec 08             	sub    $0x8,%esp
  8016f1:	ff 75 0c             	pushl  0xc(%ebp)
  8016f4:	50                   	push   %eax
  8016f5:	ff d2                	call   *%edx
  8016f7:	89 c2                	mov    %eax,%edx
  8016f9:	83 c4 10             	add    $0x10,%esp
  8016fc:	eb 09                	jmp    801707 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016fe:	89 c2                	mov    %eax,%edx
  801700:	eb 05                	jmp    801707 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801702:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801707:	89 d0                	mov    %edx,%eax
  801709:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170c:	c9                   	leave  
  80170d:	c3                   	ret    

0080170e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80170e:	55                   	push   %ebp
  80170f:	89 e5                	mov    %esp,%ebp
  801711:	53                   	push   %ebx
  801712:	83 ec 14             	sub    $0x14,%esp
  801715:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801718:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80171b:	50                   	push   %eax
  80171c:	ff 75 08             	pushl  0x8(%ebp)
  80171f:	e8 6c fb ff ff       	call   801290 <fd_lookup>
  801724:	83 c4 08             	add    $0x8,%esp
  801727:	89 c2                	mov    %eax,%edx
  801729:	85 c0                	test   %eax,%eax
  80172b:	78 58                	js     801785 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80172d:	83 ec 08             	sub    $0x8,%esp
  801730:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801733:	50                   	push   %eax
  801734:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801737:	ff 30                	pushl  (%eax)
  801739:	e8 a8 fb ff ff       	call   8012e6 <dev_lookup>
  80173e:	83 c4 10             	add    $0x10,%esp
  801741:	85 c0                	test   %eax,%eax
  801743:	78 37                	js     80177c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801745:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801748:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80174c:	74 32                	je     801780 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80174e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801751:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801758:	00 00 00 
	stat->st_isdir = 0;
  80175b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801762:	00 00 00 
	stat->st_dev = dev;
  801765:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80176b:	83 ec 08             	sub    $0x8,%esp
  80176e:	53                   	push   %ebx
  80176f:	ff 75 f0             	pushl  -0x10(%ebp)
  801772:	ff 50 14             	call   *0x14(%eax)
  801775:	89 c2                	mov    %eax,%edx
  801777:	83 c4 10             	add    $0x10,%esp
  80177a:	eb 09                	jmp    801785 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177c:	89 c2                	mov    %eax,%edx
  80177e:	eb 05                	jmp    801785 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801780:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801785:	89 d0                	mov    %edx,%eax
  801787:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80178a:	c9                   	leave  
  80178b:	c3                   	ret    

0080178c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	56                   	push   %esi
  801790:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801791:	83 ec 08             	sub    $0x8,%esp
  801794:	6a 00                	push   $0x0
  801796:	ff 75 08             	pushl  0x8(%ebp)
  801799:	e8 e3 01 00 00       	call   801981 <open>
  80179e:	89 c3                	mov    %eax,%ebx
  8017a0:	83 c4 10             	add    $0x10,%esp
  8017a3:	85 c0                	test   %eax,%eax
  8017a5:	78 1b                	js     8017c2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017a7:	83 ec 08             	sub    $0x8,%esp
  8017aa:	ff 75 0c             	pushl  0xc(%ebp)
  8017ad:	50                   	push   %eax
  8017ae:	e8 5b ff ff ff       	call   80170e <fstat>
  8017b3:	89 c6                	mov    %eax,%esi
	close(fd);
  8017b5:	89 1c 24             	mov    %ebx,(%esp)
  8017b8:	e8 fd fb ff ff       	call   8013ba <close>
	return r;
  8017bd:	83 c4 10             	add    $0x10,%esp
  8017c0:	89 f0                	mov    %esi,%eax
}
  8017c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c5:	5b                   	pop    %ebx
  8017c6:	5e                   	pop    %esi
  8017c7:	5d                   	pop    %ebp
  8017c8:	c3                   	ret    

008017c9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017c9:	55                   	push   %ebp
  8017ca:	89 e5                	mov    %esp,%ebp
  8017cc:	56                   	push   %esi
  8017cd:	53                   	push   %ebx
  8017ce:	89 c6                	mov    %eax,%esi
  8017d0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017d2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017d9:	75 12                	jne    8017ed <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017db:	83 ec 0c             	sub    $0xc,%esp
  8017de:	6a 01                	push   $0x1
  8017e0:	e8 f5 f9 ff ff       	call   8011da <ipc_find_env>
  8017e5:	a3 00 40 80 00       	mov    %eax,0x804000
  8017ea:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017ed:	6a 07                	push   $0x7
  8017ef:	68 00 50 80 00       	push   $0x805000
  8017f4:	56                   	push   %esi
  8017f5:	ff 35 00 40 80 00    	pushl  0x804000
  8017fb:	e8 78 f9 ff ff       	call   801178 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801800:	83 c4 0c             	add    $0xc,%esp
  801803:	6a 00                	push   $0x0
  801805:	53                   	push   %ebx
  801806:	6a 00                	push   $0x0
  801808:	e8 f3 f8 ff ff       	call   801100 <ipc_recv>
}
  80180d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801810:	5b                   	pop    %ebx
  801811:	5e                   	pop    %esi
  801812:	5d                   	pop    %ebp
  801813:	c3                   	ret    

00801814 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80181a:	8b 45 08             	mov    0x8(%ebp),%eax
  80181d:	8b 40 0c             	mov    0xc(%eax),%eax
  801820:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801825:	8b 45 0c             	mov    0xc(%ebp),%eax
  801828:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80182d:	ba 00 00 00 00       	mov    $0x0,%edx
  801832:	b8 02 00 00 00       	mov    $0x2,%eax
  801837:	e8 8d ff ff ff       	call   8017c9 <fsipc>
}
  80183c:	c9                   	leave  
  80183d:	c3                   	ret    

0080183e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80183e:	55                   	push   %ebp
  80183f:	89 e5                	mov    %esp,%ebp
  801841:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801844:	8b 45 08             	mov    0x8(%ebp),%eax
  801847:	8b 40 0c             	mov    0xc(%eax),%eax
  80184a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80184f:	ba 00 00 00 00       	mov    $0x0,%edx
  801854:	b8 06 00 00 00       	mov    $0x6,%eax
  801859:	e8 6b ff ff ff       	call   8017c9 <fsipc>
}
  80185e:	c9                   	leave  
  80185f:	c3                   	ret    

00801860 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801860:	55                   	push   %ebp
  801861:	89 e5                	mov    %esp,%ebp
  801863:	53                   	push   %ebx
  801864:	83 ec 04             	sub    $0x4,%esp
  801867:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80186a:	8b 45 08             	mov    0x8(%ebp),%eax
  80186d:	8b 40 0c             	mov    0xc(%eax),%eax
  801870:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801875:	ba 00 00 00 00       	mov    $0x0,%edx
  80187a:	b8 05 00 00 00       	mov    $0x5,%eax
  80187f:	e8 45 ff ff ff       	call   8017c9 <fsipc>
  801884:	85 c0                	test   %eax,%eax
  801886:	78 2c                	js     8018b4 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801888:	83 ec 08             	sub    $0x8,%esp
  80188b:	68 00 50 80 00       	push   $0x805000
  801890:	53                   	push   %ebx
  801891:	e8 44 ef ff ff       	call   8007da <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801896:	a1 80 50 80 00       	mov    0x805080,%eax
  80189b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018a1:	a1 84 50 80 00       	mov    0x805084,%eax
  8018a6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b7:	c9                   	leave  
  8018b8:	c3                   	ret    

008018b9 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018b9:	55                   	push   %ebp
  8018ba:	89 e5                	mov    %esp,%ebp
  8018bc:	83 ec 0c             	sub    $0xc,%esp
  8018bf:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8018c5:	8b 52 0c             	mov    0xc(%edx),%edx
  8018c8:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8018ce:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018d3:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018d8:	0f 47 c2             	cmova  %edx,%eax
  8018db:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8018e0:	50                   	push   %eax
  8018e1:	ff 75 0c             	pushl  0xc(%ebp)
  8018e4:	68 08 50 80 00       	push   $0x805008
  8018e9:	e8 7e f0 ff ff       	call   80096c <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8018ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f3:	b8 04 00 00 00       	mov    $0x4,%eax
  8018f8:	e8 cc fe ff ff       	call   8017c9 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8018fd:	c9                   	leave  
  8018fe:	c3                   	ret    

008018ff <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	56                   	push   %esi
  801903:	53                   	push   %ebx
  801904:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801907:	8b 45 08             	mov    0x8(%ebp),%eax
  80190a:	8b 40 0c             	mov    0xc(%eax),%eax
  80190d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801912:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801918:	ba 00 00 00 00       	mov    $0x0,%edx
  80191d:	b8 03 00 00 00       	mov    $0x3,%eax
  801922:	e8 a2 fe ff ff       	call   8017c9 <fsipc>
  801927:	89 c3                	mov    %eax,%ebx
  801929:	85 c0                	test   %eax,%eax
  80192b:	78 4b                	js     801978 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80192d:	39 c6                	cmp    %eax,%esi
  80192f:	73 16                	jae    801947 <devfile_read+0x48>
  801931:	68 10 27 80 00       	push   $0x802710
  801936:	68 17 27 80 00       	push   $0x802717
  80193b:	6a 7c                	push   $0x7c
  80193d:	68 2c 27 80 00       	push   $0x80272c
  801942:	e8 35 e8 ff ff       	call   80017c <_panic>
	assert(r <= PGSIZE);
  801947:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80194c:	7e 16                	jle    801964 <devfile_read+0x65>
  80194e:	68 37 27 80 00       	push   $0x802737
  801953:	68 17 27 80 00       	push   $0x802717
  801958:	6a 7d                	push   $0x7d
  80195a:	68 2c 27 80 00       	push   $0x80272c
  80195f:	e8 18 e8 ff ff       	call   80017c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801964:	83 ec 04             	sub    $0x4,%esp
  801967:	50                   	push   %eax
  801968:	68 00 50 80 00       	push   $0x805000
  80196d:	ff 75 0c             	pushl  0xc(%ebp)
  801970:	e8 f7 ef ff ff       	call   80096c <memmove>
	return r;
  801975:	83 c4 10             	add    $0x10,%esp
}
  801978:	89 d8                	mov    %ebx,%eax
  80197a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80197d:	5b                   	pop    %ebx
  80197e:	5e                   	pop    %esi
  80197f:	5d                   	pop    %ebp
  801980:	c3                   	ret    

00801981 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801981:	55                   	push   %ebp
  801982:	89 e5                	mov    %esp,%ebp
  801984:	53                   	push   %ebx
  801985:	83 ec 20             	sub    $0x20,%esp
  801988:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80198b:	53                   	push   %ebx
  80198c:	e8 10 ee ff ff       	call   8007a1 <strlen>
  801991:	83 c4 10             	add    $0x10,%esp
  801994:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801999:	7f 67                	jg     801a02 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80199b:	83 ec 0c             	sub    $0xc,%esp
  80199e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a1:	50                   	push   %eax
  8019a2:	e8 9a f8 ff ff       	call   801241 <fd_alloc>
  8019a7:	83 c4 10             	add    $0x10,%esp
		return r;
  8019aa:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019ac:	85 c0                	test   %eax,%eax
  8019ae:	78 57                	js     801a07 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019b0:	83 ec 08             	sub    $0x8,%esp
  8019b3:	53                   	push   %ebx
  8019b4:	68 00 50 80 00       	push   $0x805000
  8019b9:	e8 1c ee ff ff       	call   8007da <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019c9:	b8 01 00 00 00       	mov    $0x1,%eax
  8019ce:	e8 f6 fd ff ff       	call   8017c9 <fsipc>
  8019d3:	89 c3                	mov    %eax,%ebx
  8019d5:	83 c4 10             	add    $0x10,%esp
  8019d8:	85 c0                	test   %eax,%eax
  8019da:	79 14                	jns    8019f0 <open+0x6f>
		fd_close(fd, 0);
  8019dc:	83 ec 08             	sub    $0x8,%esp
  8019df:	6a 00                	push   $0x0
  8019e1:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e4:	e8 50 f9 ff ff       	call   801339 <fd_close>
		return r;
  8019e9:	83 c4 10             	add    $0x10,%esp
  8019ec:	89 da                	mov    %ebx,%edx
  8019ee:	eb 17                	jmp    801a07 <open+0x86>
	}

	return fd2num(fd);
  8019f0:	83 ec 0c             	sub    $0xc,%esp
  8019f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8019f6:	e8 1f f8 ff ff       	call   80121a <fd2num>
  8019fb:	89 c2                	mov    %eax,%edx
  8019fd:	83 c4 10             	add    $0x10,%esp
  801a00:	eb 05                	jmp    801a07 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a02:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a07:	89 d0                	mov    %edx,%eax
  801a09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a0c:	c9                   	leave  
  801a0d:	c3                   	ret    

00801a0e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a0e:	55                   	push   %ebp
  801a0f:	89 e5                	mov    %esp,%ebp
  801a11:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a14:	ba 00 00 00 00       	mov    $0x0,%edx
  801a19:	b8 08 00 00 00       	mov    $0x8,%eax
  801a1e:	e8 a6 fd ff ff       	call   8017c9 <fsipc>
}
  801a23:	c9                   	leave  
  801a24:	c3                   	ret    

00801a25 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a25:	55                   	push   %ebp
  801a26:	89 e5                	mov    %esp,%ebp
  801a28:	56                   	push   %esi
  801a29:	53                   	push   %ebx
  801a2a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a2d:	83 ec 0c             	sub    $0xc,%esp
  801a30:	ff 75 08             	pushl  0x8(%ebp)
  801a33:	e8 f2 f7 ff ff       	call   80122a <fd2data>
  801a38:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a3a:	83 c4 08             	add    $0x8,%esp
  801a3d:	68 43 27 80 00       	push   $0x802743
  801a42:	53                   	push   %ebx
  801a43:	e8 92 ed ff ff       	call   8007da <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a48:	8b 46 04             	mov    0x4(%esi),%eax
  801a4b:	2b 06                	sub    (%esi),%eax
  801a4d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a53:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a5a:	00 00 00 
	stat->st_dev = &devpipe;
  801a5d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a64:	30 80 00 
	return 0;
}
  801a67:	b8 00 00 00 00       	mov    $0x0,%eax
  801a6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a6f:	5b                   	pop    %ebx
  801a70:	5e                   	pop    %esi
  801a71:	5d                   	pop    %ebp
  801a72:	c3                   	ret    

00801a73 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a73:	55                   	push   %ebp
  801a74:	89 e5                	mov    %esp,%ebp
  801a76:	53                   	push   %ebx
  801a77:	83 ec 0c             	sub    $0xc,%esp
  801a7a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a7d:	53                   	push   %ebx
  801a7e:	6a 00                	push   $0x0
  801a80:	e8 dd f1 ff ff       	call   800c62 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a85:	89 1c 24             	mov    %ebx,(%esp)
  801a88:	e8 9d f7 ff ff       	call   80122a <fd2data>
  801a8d:	83 c4 08             	add    $0x8,%esp
  801a90:	50                   	push   %eax
  801a91:	6a 00                	push   $0x0
  801a93:	e8 ca f1 ff ff       	call   800c62 <sys_page_unmap>
}
  801a98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a9b:	c9                   	leave  
  801a9c:	c3                   	ret    

00801a9d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a9d:	55                   	push   %ebp
  801a9e:	89 e5                	mov    %esp,%ebp
  801aa0:	57                   	push   %edi
  801aa1:	56                   	push   %esi
  801aa2:	53                   	push   %ebx
  801aa3:	83 ec 1c             	sub    $0x1c,%esp
  801aa6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801aa9:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801aab:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab0:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ab3:	83 ec 0c             	sub    $0xc,%esp
  801ab6:	ff 75 e0             	pushl  -0x20(%ebp)
  801ab9:	e8 d5 04 00 00       	call   801f93 <pageref>
  801abe:	89 c3                	mov    %eax,%ebx
  801ac0:	89 3c 24             	mov    %edi,(%esp)
  801ac3:	e8 cb 04 00 00       	call   801f93 <pageref>
  801ac8:	83 c4 10             	add    $0x10,%esp
  801acb:	39 c3                	cmp    %eax,%ebx
  801acd:	0f 94 c1             	sete   %cl
  801ad0:	0f b6 c9             	movzbl %cl,%ecx
  801ad3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ad6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801adc:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  801adf:	39 ce                	cmp    %ecx,%esi
  801ae1:	74 1b                	je     801afe <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ae3:	39 c3                	cmp    %eax,%ebx
  801ae5:	75 c4                	jne    801aab <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ae7:	8b 42 64             	mov    0x64(%edx),%eax
  801aea:	ff 75 e4             	pushl  -0x1c(%ebp)
  801aed:	50                   	push   %eax
  801aee:	56                   	push   %esi
  801aef:	68 4a 27 80 00       	push   $0x80274a
  801af4:	e8 5c e7 ff ff       	call   800255 <cprintf>
  801af9:	83 c4 10             	add    $0x10,%esp
  801afc:	eb ad                	jmp    801aab <_pipeisclosed+0xe>
	}
}
  801afe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b04:	5b                   	pop    %ebx
  801b05:	5e                   	pop    %esi
  801b06:	5f                   	pop    %edi
  801b07:	5d                   	pop    %ebp
  801b08:	c3                   	ret    

00801b09 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b09:	55                   	push   %ebp
  801b0a:	89 e5                	mov    %esp,%ebp
  801b0c:	57                   	push   %edi
  801b0d:	56                   	push   %esi
  801b0e:	53                   	push   %ebx
  801b0f:	83 ec 28             	sub    $0x28,%esp
  801b12:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b15:	56                   	push   %esi
  801b16:	e8 0f f7 ff ff       	call   80122a <fd2data>
  801b1b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b1d:	83 c4 10             	add    $0x10,%esp
  801b20:	bf 00 00 00 00       	mov    $0x0,%edi
  801b25:	eb 4b                	jmp    801b72 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b27:	89 da                	mov    %ebx,%edx
  801b29:	89 f0                	mov    %esi,%eax
  801b2b:	e8 6d ff ff ff       	call   801a9d <_pipeisclosed>
  801b30:	85 c0                	test   %eax,%eax
  801b32:	75 48                	jne    801b7c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b34:	e8 85 f0 ff ff       	call   800bbe <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b39:	8b 43 04             	mov    0x4(%ebx),%eax
  801b3c:	8b 0b                	mov    (%ebx),%ecx
  801b3e:	8d 51 20             	lea    0x20(%ecx),%edx
  801b41:	39 d0                	cmp    %edx,%eax
  801b43:	73 e2                	jae    801b27 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b48:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b4c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b4f:	89 c2                	mov    %eax,%edx
  801b51:	c1 fa 1f             	sar    $0x1f,%edx
  801b54:	89 d1                	mov    %edx,%ecx
  801b56:	c1 e9 1b             	shr    $0x1b,%ecx
  801b59:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b5c:	83 e2 1f             	and    $0x1f,%edx
  801b5f:	29 ca                	sub    %ecx,%edx
  801b61:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b65:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b69:	83 c0 01             	add    $0x1,%eax
  801b6c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b6f:	83 c7 01             	add    $0x1,%edi
  801b72:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b75:	75 c2                	jne    801b39 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b77:	8b 45 10             	mov    0x10(%ebp),%eax
  801b7a:	eb 05                	jmp    801b81 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b7c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b84:	5b                   	pop    %ebx
  801b85:	5e                   	pop    %esi
  801b86:	5f                   	pop    %edi
  801b87:	5d                   	pop    %ebp
  801b88:	c3                   	ret    

00801b89 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b89:	55                   	push   %ebp
  801b8a:	89 e5                	mov    %esp,%ebp
  801b8c:	57                   	push   %edi
  801b8d:	56                   	push   %esi
  801b8e:	53                   	push   %ebx
  801b8f:	83 ec 18             	sub    $0x18,%esp
  801b92:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b95:	57                   	push   %edi
  801b96:	e8 8f f6 ff ff       	call   80122a <fd2data>
  801b9b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b9d:	83 c4 10             	add    $0x10,%esp
  801ba0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ba5:	eb 3d                	jmp    801be4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ba7:	85 db                	test   %ebx,%ebx
  801ba9:	74 04                	je     801baf <devpipe_read+0x26>
				return i;
  801bab:	89 d8                	mov    %ebx,%eax
  801bad:	eb 44                	jmp    801bf3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801baf:	89 f2                	mov    %esi,%edx
  801bb1:	89 f8                	mov    %edi,%eax
  801bb3:	e8 e5 fe ff ff       	call   801a9d <_pipeisclosed>
  801bb8:	85 c0                	test   %eax,%eax
  801bba:	75 32                	jne    801bee <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bbc:	e8 fd ef ff ff       	call   800bbe <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bc1:	8b 06                	mov    (%esi),%eax
  801bc3:	3b 46 04             	cmp    0x4(%esi),%eax
  801bc6:	74 df                	je     801ba7 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bc8:	99                   	cltd   
  801bc9:	c1 ea 1b             	shr    $0x1b,%edx
  801bcc:	01 d0                	add    %edx,%eax
  801bce:	83 e0 1f             	and    $0x1f,%eax
  801bd1:	29 d0                	sub    %edx,%eax
  801bd3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bdb:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bde:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be1:	83 c3 01             	add    $0x1,%ebx
  801be4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801be7:	75 d8                	jne    801bc1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801be9:	8b 45 10             	mov    0x10(%ebp),%eax
  801bec:	eb 05                	jmp    801bf3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bee:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf6:	5b                   	pop    %ebx
  801bf7:	5e                   	pop    %esi
  801bf8:	5f                   	pop    %edi
  801bf9:	5d                   	pop    %ebp
  801bfa:	c3                   	ret    

00801bfb <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bfb:	55                   	push   %ebp
  801bfc:	89 e5                	mov    %esp,%ebp
  801bfe:	56                   	push   %esi
  801bff:	53                   	push   %ebx
  801c00:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c03:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c06:	50                   	push   %eax
  801c07:	e8 35 f6 ff ff       	call   801241 <fd_alloc>
  801c0c:	83 c4 10             	add    $0x10,%esp
  801c0f:	89 c2                	mov    %eax,%edx
  801c11:	85 c0                	test   %eax,%eax
  801c13:	0f 88 2c 01 00 00    	js     801d45 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c19:	83 ec 04             	sub    $0x4,%esp
  801c1c:	68 07 04 00 00       	push   $0x407
  801c21:	ff 75 f4             	pushl  -0xc(%ebp)
  801c24:	6a 00                	push   $0x0
  801c26:	e8 b2 ef ff ff       	call   800bdd <sys_page_alloc>
  801c2b:	83 c4 10             	add    $0x10,%esp
  801c2e:	89 c2                	mov    %eax,%edx
  801c30:	85 c0                	test   %eax,%eax
  801c32:	0f 88 0d 01 00 00    	js     801d45 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c38:	83 ec 0c             	sub    $0xc,%esp
  801c3b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c3e:	50                   	push   %eax
  801c3f:	e8 fd f5 ff ff       	call   801241 <fd_alloc>
  801c44:	89 c3                	mov    %eax,%ebx
  801c46:	83 c4 10             	add    $0x10,%esp
  801c49:	85 c0                	test   %eax,%eax
  801c4b:	0f 88 e2 00 00 00    	js     801d33 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c51:	83 ec 04             	sub    $0x4,%esp
  801c54:	68 07 04 00 00       	push   $0x407
  801c59:	ff 75 f0             	pushl  -0x10(%ebp)
  801c5c:	6a 00                	push   $0x0
  801c5e:	e8 7a ef ff ff       	call   800bdd <sys_page_alloc>
  801c63:	89 c3                	mov    %eax,%ebx
  801c65:	83 c4 10             	add    $0x10,%esp
  801c68:	85 c0                	test   %eax,%eax
  801c6a:	0f 88 c3 00 00 00    	js     801d33 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c70:	83 ec 0c             	sub    $0xc,%esp
  801c73:	ff 75 f4             	pushl  -0xc(%ebp)
  801c76:	e8 af f5 ff ff       	call   80122a <fd2data>
  801c7b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c7d:	83 c4 0c             	add    $0xc,%esp
  801c80:	68 07 04 00 00       	push   $0x407
  801c85:	50                   	push   %eax
  801c86:	6a 00                	push   $0x0
  801c88:	e8 50 ef ff ff       	call   800bdd <sys_page_alloc>
  801c8d:	89 c3                	mov    %eax,%ebx
  801c8f:	83 c4 10             	add    $0x10,%esp
  801c92:	85 c0                	test   %eax,%eax
  801c94:	0f 88 89 00 00 00    	js     801d23 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c9a:	83 ec 0c             	sub    $0xc,%esp
  801c9d:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca0:	e8 85 f5 ff ff       	call   80122a <fd2data>
  801ca5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cac:	50                   	push   %eax
  801cad:	6a 00                	push   $0x0
  801caf:	56                   	push   %esi
  801cb0:	6a 00                	push   $0x0
  801cb2:	e8 69 ef ff ff       	call   800c20 <sys_page_map>
  801cb7:	89 c3                	mov    %eax,%ebx
  801cb9:	83 c4 20             	add    $0x20,%esp
  801cbc:	85 c0                	test   %eax,%eax
  801cbe:	78 55                	js     801d15 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cc0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ccb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cce:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cd5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cde:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ce0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ce3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cea:	83 ec 0c             	sub    $0xc,%esp
  801ced:	ff 75 f4             	pushl  -0xc(%ebp)
  801cf0:	e8 25 f5 ff ff       	call   80121a <fd2num>
  801cf5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cf8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cfa:	83 c4 04             	add    $0x4,%esp
  801cfd:	ff 75 f0             	pushl  -0x10(%ebp)
  801d00:	e8 15 f5 ff ff       	call   80121a <fd2num>
  801d05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d08:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801d0b:	83 c4 10             	add    $0x10,%esp
  801d0e:	ba 00 00 00 00       	mov    $0x0,%edx
  801d13:	eb 30                	jmp    801d45 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d15:	83 ec 08             	sub    $0x8,%esp
  801d18:	56                   	push   %esi
  801d19:	6a 00                	push   $0x0
  801d1b:	e8 42 ef ff ff       	call   800c62 <sys_page_unmap>
  801d20:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d23:	83 ec 08             	sub    $0x8,%esp
  801d26:	ff 75 f0             	pushl  -0x10(%ebp)
  801d29:	6a 00                	push   $0x0
  801d2b:	e8 32 ef ff ff       	call   800c62 <sys_page_unmap>
  801d30:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d33:	83 ec 08             	sub    $0x8,%esp
  801d36:	ff 75 f4             	pushl  -0xc(%ebp)
  801d39:	6a 00                	push   $0x0
  801d3b:	e8 22 ef ff ff       	call   800c62 <sys_page_unmap>
  801d40:	83 c4 10             	add    $0x10,%esp
  801d43:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d45:	89 d0                	mov    %edx,%eax
  801d47:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d4a:	5b                   	pop    %ebx
  801d4b:	5e                   	pop    %esi
  801d4c:	5d                   	pop    %ebp
  801d4d:	c3                   	ret    

00801d4e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d4e:	55                   	push   %ebp
  801d4f:	89 e5                	mov    %esp,%ebp
  801d51:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d57:	50                   	push   %eax
  801d58:	ff 75 08             	pushl  0x8(%ebp)
  801d5b:	e8 30 f5 ff ff       	call   801290 <fd_lookup>
  801d60:	83 c4 10             	add    $0x10,%esp
  801d63:	85 c0                	test   %eax,%eax
  801d65:	78 18                	js     801d7f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d67:	83 ec 0c             	sub    $0xc,%esp
  801d6a:	ff 75 f4             	pushl  -0xc(%ebp)
  801d6d:	e8 b8 f4 ff ff       	call   80122a <fd2data>
	return _pipeisclosed(fd, p);
  801d72:	89 c2                	mov    %eax,%edx
  801d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d77:	e8 21 fd ff ff       	call   801a9d <_pipeisclosed>
  801d7c:	83 c4 10             	add    $0x10,%esp
}
  801d7f:	c9                   	leave  
  801d80:	c3                   	ret    

00801d81 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d81:	55                   	push   %ebp
  801d82:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d84:	b8 00 00 00 00       	mov    $0x0,%eax
  801d89:	5d                   	pop    %ebp
  801d8a:	c3                   	ret    

00801d8b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d8b:	55                   	push   %ebp
  801d8c:	89 e5                	mov    %esp,%ebp
  801d8e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d91:	68 62 27 80 00       	push   $0x802762
  801d96:	ff 75 0c             	pushl  0xc(%ebp)
  801d99:	e8 3c ea ff ff       	call   8007da <strcpy>
	return 0;
}
  801d9e:	b8 00 00 00 00       	mov    $0x0,%eax
  801da3:	c9                   	leave  
  801da4:	c3                   	ret    

00801da5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801da5:	55                   	push   %ebp
  801da6:	89 e5                	mov    %esp,%ebp
  801da8:	57                   	push   %edi
  801da9:	56                   	push   %esi
  801daa:	53                   	push   %ebx
  801dab:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801db1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801db6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dbc:	eb 2d                	jmp    801deb <devcons_write+0x46>
		m = n - tot;
  801dbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dc1:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801dc3:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dc6:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801dcb:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dce:	83 ec 04             	sub    $0x4,%esp
  801dd1:	53                   	push   %ebx
  801dd2:	03 45 0c             	add    0xc(%ebp),%eax
  801dd5:	50                   	push   %eax
  801dd6:	57                   	push   %edi
  801dd7:	e8 90 eb ff ff       	call   80096c <memmove>
		sys_cputs(buf, m);
  801ddc:	83 c4 08             	add    $0x8,%esp
  801ddf:	53                   	push   %ebx
  801de0:	57                   	push   %edi
  801de1:	e8 3b ed ff ff       	call   800b21 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801de6:	01 de                	add    %ebx,%esi
  801de8:	83 c4 10             	add    $0x10,%esp
  801deb:	89 f0                	mov    %esi,%eax
  801ded:	3b 75 10             	cmp    0x10(%ebp),%esi
  801df0:	72 cc                	jb     801dbe <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801df2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801df5:	5b                   	pop    %ebx
  801df6:	5e                   	pop    %esi
  801df7:	5f                   	pop    %edi
  801df8:	5d                   	pop    %ebp
  801df9:	c3                   	ret    

00801dfa <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dfa:	55                   	push   %ebp
  801dfb:	89 e5                	mov    %esp,%ebp
  801dfd:	83 ec 08             	sub    $0x8,%esp
  801e00:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e05:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e09:	74 2a                	je     801e35 <devcons_read+0x3b>
  801e0b:	eb 05                	jmp    801e12 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e0d:	e8 ac ed ff ff       	call   800bbe <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e12:	e8 28 ed ff ff       	call   800b3f <sys_cgetc>
  801e17:	85 c0                	test   %eax,%eax
  801e19:	74 f2                	je     801e0d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e1b:	85 c0                	test   %eax,%eax
  801e1d:	78 16                	js     801e35 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e1f:	83 f8 04             	cmp    $0x4,%eax
  801e22:	74 0c                	je     801e30 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e24:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e27:	88 02                	mov    %al,(%edx)
	return 1;
  801e29:	b8 01 00 00 00       	mov    $0x1,%eax
  801e2e:	eb 05                	jmp    801e35 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e30:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e35:	c9                   	leave  
  801e36:	c3                   	ret    

00801e37 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e37:	55                   	push   %ebp
  801e38:	89 e5                	mov    %esp,%ebp
  801e3a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e40:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e43:	6a 01                	push   $0x1
  801e45:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e48:	50                   	push   %eax
  801e49:	e8 d3 ec ff ff       	call   800b21 <sys_cputs>
}
  801e4e:	83 c4 10             	add    $0x10,%esp
  801e51:	c9                   	leave  
  801e52:	c3                   	ret    

00801e53 <getchar>:

int
getchar(void)
{
  801e53:	55                   	push   %ebp
  801e54:	89 e5                	mov    %esp,%ebp
  801e56:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e59:	6a 01                	push   $0x1
  801e5b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e5e:	50                   	push   %eax
  801e5f:	6a 00                	push   $0x0
  801e61:	e8 90 f6 ff ff       	call   8014f6 <read>
	if (r < 0)
  801e66:	83 c4 10             	add    $0x10,%esp
  801e69:	85 c0                	test   %eax,%eax
  801e6b:	78 0f                	js     801e7c <getchar+0x29>
		return r;
	if (r < 1)
  801e6d:	85 c0                	test   %eax,%eax
  801e6f:	7e 06                	jle    801e77 <getchar+0x24>
		return -E_EOF;
	return c;
  801e71:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e75:	eb 05                	jmp    801e7c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e77:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e7c:	c9                   	leave  
  801e7d:	c3                   	ret    

00801e7e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e7e:	55                   	push   %ebp
  801e7f:	89 e5                	mov    %esp,%ebp
  801e81:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e87:	50                   	push   %eax
  801e88:	ff 75 08             	pushl  0x8(%ebp)
  801e8b:	e8 00 f4 ff ff       	call   801290 <fd_lookup>
  801e90:	83 c4 10             	add    $0x10,%esp
  801e93:	85 c0                	test   %eax,%eax
  801e95:	78 11                	js     801ea8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e9a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ea0:	39 10                	cmp    %edx,(%eax)
  801ea2:	0f 94 c0             	sete   %al
  801ea5:	0f b6 c0             	movzbl %al,%eax
}
  801ea8:	c9                   	leave  
  801ea9:	c3                   	ret    

00801eaa <opencons>:

int
opencons(void)
{
  801eaa:	55                   	push   %ebp
  801eab:	89 e5                	mov    %esp,%ebp
  801ead:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb3:	50                   	push   %eax
  801eb4:	e8 88 f3 ff ff       	call   801241 <fd_alloc>
  801eb9:	83 c4 10             	add    $0x10,%esp
		return r;
  801ebc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ebe:	85 c0                	test   %eax,%eax
  801ec0:	78 3e                	js     801f00 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ec2:	83 ec 04             	sub    $0x4,%esp
  801ec5:	68 07 04 00 00       	push   $0x407
  801eca:	ff 75 f4             	pushl  -0xc(%ebp)
  801ecd:	6a 00                	push   $0x0
  801ecf:	e8 09 ed ff ff       	call   800bdd <sys_page_alloc>
  801ed4:	83 c4 10             	add    $0x10,%esp
		return r;
  801ed7:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ed9:	85 c0                	test   %eax,%eax
  801edb:	78 23                	js     801f00 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801edd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ee3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eeb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ef2:	83 ec 0c             	sub    $0xc,%esp
  801ef5:	50                   	push   %eax
  801ef6:	e8 1f f3 ff ff       	call   80121a <fd2num>
  801efb:	89 c2                	mov    %eax,%edx
  801efd:	83 c4 10             	add    $0x10,%esp
}
  801f00:	89 d0                	mov    %edx,%eax
  801f02:	c9                   	leave  
  801f03:	c3                   	ret    

00801f04 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f04:	55                   	push   %ebp
  801f05:	89 e5                	mov    %esp,%ebp
  801f07:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f0a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f11:	75 2a                	jne    801f3d <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801f13:	83 ec 04             	sub    $0x4,%esp
  801f16:	6a 07                	push   $0x7
  801f18:	68 00 f0 bf ee       	push   $0xeebff000
  801f1d:	6a 00                	push   $0x0
  801f1f:	e8 b9 ec ff ff       	call   800bdd <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801f24:	83 c4 10             	add    $0x10,%esp
  801f27:	85 c0                	test   %eax,%eax
  801f29:	79 12                	jns    801f3d <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801f2b:	50                   	push   %eax
  801f2c:	68 6e 27 80 00       	push   $0x80276e
  801f31:	6a 23                	push   $0x23
  801f33:	68 72 27 80 00       	push   $0x802772
  801f38:	e8 3f e2 ff ff       	call   80017c <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f40:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801f45:	83 ec 08             	sub    $0x8,%esp
  801f48:	68 6f 1f 80 00       	push   $0x801f6f
  801f4d:	6a 00                	push   $0x0
  801f4f:	e8 d4 ed ff ff       	call   800d28 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801f54:	83 c4 10             	add    $0x10,%esp
  801f57:	85 c0                	test   %eax,%eax
  801f59:	79 12                	jns    801f6d <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801f5b:	50                   	push   %eax
  801f5c:	68 6e 27 80 00       	push   $0x80276e
  801f61:	6a 2c                	push   $0x2c
  801f63:	68 72 27 80 00       	push   $0x802772
  801f68:	e8 0f e2 ff ff       	call   80017c <_panic>
	}
}
  801f6d:	c9                   	leave  
  801f6e:	c3                   	ret    

00801f6f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f6f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f70:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f75:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f77:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801f7a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801f7e:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801f83:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801f87:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801f89:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801f8c:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801f8d:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801f90:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801f91:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f92:	c3                   	ret    

00801f93 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f93:	55                   	push   %ebp
  801f94:	89 e5                	mov    %esp,%ebp
  801f96:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f99:	89 d0                	mov    %edx,%eax
  801f9b:	c1 e8 16             	shr    $0x16,%eax
  801f9e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fa5:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801faa:	f6 c1 01             	test   $0x1,%cl
  801fad:	74 1d                	je     801fcc <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801faf:	c1 ea 0c             	shr    $0xc,%edx
  801fb2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fb9:	f6 c2 01             	test   $0x1,%dl
  801fbc:	74 0e                	je     801fcc <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fbe:	c1 ea 0c             	shr    $0xc,%edx
  801fc1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fc8:	ef 
  801fc9:	0f b7 c0             	movzwl %ax,%eax
}
  801fcc:	5d                   	pop    %ebp
  801fcd:	c3                   	ret    
  801fce:	66 90                	xchg   %ax,%ax

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
