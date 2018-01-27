
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
  80002c:	e8 ca 00 00 00       	call   8000fb <libmain>
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
  800047:	e8 b8 10 00 00       	call   801104 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 40 80 00       	mov    0x804004,%eax
  800053:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
  800059:	83 c4 0c             	add    $0xc,%esp
  80005c:	53                   	push   %ebx
  80005d:	50                   	push   %eax
  80005e:	68 80 22 80 00       	push   $0x802280
  800063:	e8 ef 01 00 00       	call   800257 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800068:	e8 79 0e 00 00       	call   800ee6 <fork>
  80006d:	89 c7                	mov    %eax,%edi
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	85 c0                	test   %eax,%eax
  800074:	79 12                	jns    800088 <primeproc+0x55>
		panic("fork: %e", id);
  800076:	50                   	push   %eax
  800077:	68 8c 22 80 00       	push   $0x80228c
  80007c:	6a 1a                	push   $0x1a
  80007e:	68 95 22 80 00       	push   $0x802295
  800083:	e8 f6 00 00 00       	call   80017e <_panic>
	if (id == 0)
  800088:	85 c0                	test   %eax,%eax
  80008a:	74 b3                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  80008c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80008f:	83 ec 04             	sub    $0x4,%esp
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	56                   	push   %esi
  800097:	e8 68 10 00 00       	call   801104 <ipc_recv>
  80009c:	89 c1                	mov    %eax,%ecx
		if (i % p)
  80009e:	99                   	cltd   
  80009f:	f7 fb                	idiv   %ebx
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	85 d2                	test   %edx,%edx
  8000a6:	74 e7                	je     80008f <primeproc+0x5c>
			ipc_send(id, i, 0, 0);
  8000a8:	6a 00                	push   $0x0
  8000aa:	6a 00                	push   $0x0
  8000ac:	51                   	push   %ecx
  8000ad:	57                   	push   %edi
  8000ae:	e8 cc 10 00 00       	call   80117f <ipc_send>
  8000b3:	83 c4 10             	add    $0x10,%esp
  8000b6:	eb d7                	jmp    80008f <primeproc+0x5c>

008000b8 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000bd:	e8 24 0e 00 00       	call   800ee6 <fork>
  8000c2:	89 c6                	mov    %eax,%esi
  8000c4:	85 c0                	test   %eax,%eax
  8000c6:	79 12                	jns    8000da <umain+0x22>
		panic("fork: %e", id);
  8000c8:	50                   	push   %eax
  8000c9:	68 8c 22 80 00       	push   $0x80228c
  8000ce:	6a 2d                	push   $0x2d
  8000d0:	68 95 22 80 00       	push   $0x802295
  8000d5:	e8 a4 00 00 00       	call   80017e <_panic>
  8000da:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000df:	85 c0                	test   %eax,%eax
  8000e1:	75 05                	jne    8000e8 <umain+0x30>
		primeproc();
  8000e3:	e8 4b ff ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  8000e8:	6a 00                	push   $0x0
  8000ea:	6a 00                	push   $0x0
  8000ec:	53                   	push   %ebx
  8000ed:	56                   	push   %esi
  8000ee:	e8 8c 10 00 00       	call   80117f <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000f3:	83 c3 01             	add    $0x1,%ebx
  8000f6:	83 c4 10             	add    $0x10,%esp
  8000f9:	eb ed                	jmp    8000e8 <umain+0x30>

008000fb <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	56                   	push   %esi
  8000ff:	53                   	push   %ebx
  800100:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800103:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800106:	e8 96 0a 00 00       	call   800ba1 <sys_getenvid>
  80010b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800110:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800116:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011b:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800120:	85 db                	test   %ebx,%ebx
  800122:	7e 07                	jle    80012b <libmain+0x30>
		binaryname = argv[0];
  800124:	8b 06                	mov    (%esi),%eax
  800126:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012b:	83 ec 08             	sub    $0x8,%esp
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
  800130:	e8 83 ff ff ff       	call   8000b8 <umain>

	// exit gracefully
	exit();
  800135:	e8 2a 00 00 00       	call   800164 <exit>
}
  80013a:	83 c4 10             	add    $0x10,%esp
  80013d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800140:	5b                   	pop    %ebx
  800141:	5e                   	pop    %esi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  80014a:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  80014f:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800151:	e8 4b 0a 00 00       	call   800ba1 <sys_getenvid>
  800156:	83 ec 0c             	sub    $0xc,%esp
  800159:	50                   	push   %eax
  80015a:	e8 91 0c 00 00       	call   800df0 <sys_thread_free>
}
  80015f:	83 c4 10             	add    $0x10,%esp
  800162:	c9                   	leave  
  800163:	c3                   	ret    

00800164 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80016a:	e8 7f 12 00 00       	call   8013ee <close_all>
	sys_env_destroy(0);
  80016f:	83 ec 0c             	sub    $0xc,%esp
  800172:	6a 00                	push   $0x0
  800174:	e8 e7 09 00 00       	call   800b60 <sys_env_destroy>
}
  800179:	83 c4 10             	add    $0x10,%esp
  80017c:	c9                   	leave  
  80017d:	c3                   	ret    

0080017e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80017e:	55                   	push   %ebp
  80017f:	89 e5                	mov    %esp,%ebp
  800181:	56                   	push   %esi
  800182:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800183:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800186:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80018c:	e8 10 0a 00 00       	call   800ba1 <sys_getenvid>
  800191:	83 ec 0c             	sub    $0xc,%esp
  800194:	ff 75 0c             	pushl  0xc(%ebp)
  800197:	ff 75 08             	pushl  0x8(%ebp)
  80019a:	56                   	push   %esi
  80019b:	50                   	push   %eax
  80019c:	68 b0 22 80 00       	push   $0x8022b0
  8001a1:	e8 b1 00 00 00       	call   800257 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a6:	83 c4 18             	add    $0x18,%esp
  8001a9:	53                   	push   %ebx
  8001aa:	ff 75 10             	pushl  0x10(%ebp)
  8001ad:	e8 54 00 00 00       	call   800206 <vcprintf>
	cprintf("\n");
  8001b2:	c7 04 24 7b 27 80 00 	movl   $0x80277b,(%esp)
  8001b9:	e8 99 00 00 00       	call   800257 <cprintf>
  8001be:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001c1:	cc                   	int3   
  8001c2:	eb fd                	jmp    8001c1 <_panic+0x43>

008001c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	53                   	push   %ebx
  8001c8:	83 ec 04             	sub    $0x4,%esp
  8001cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ce:	8b 13                	mov    (%ebx),%edx
  8001d0:	8d 42 01             	lea    0x1(%edx),%eax
  8001d3:	89 03                	mov    %eax,(%ebx)
  8001d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001dc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001e1:	75 1a                	jne    8001fd <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001e3:	83 ec 08             	sub    $0x8,%esp
  8001e6:	68 ff 00 00 00       	push   $0xff
  8001eb:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ee:	50                   	push   %eax
  8001ef:	e8 2f 09 00 00       	call   800b23 <sys_cputs>
		b->idx = 0;
  8001f4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001fa:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001fd:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800201:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800204:	c9                   	leave  
  800205:	c3                   	ret    

00800206 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80020f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800216:	00 00 00 
	b.cnt = 0;
  800219:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800220:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800223:	ff 75 0c             	pushl  0xc(%ebp)
  800226:	ff 75 08             	pushl  0x8(%ebp)
  800229:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80022f:	50                   	push   %eax
  800230:	68 c4 01 80 00       	push   $0x8001c4
  800235:	e8 54 01 00 00       	call   80038e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80023a:	83 c4 08             	add    $0x8,%esp
  80023d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800243:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800249:	50                   	push   %eax
  80024a:	e8 d4 08 00 00       	call   800b23 <sys_cputs>

	return b.cnt;
}
  80024f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800255:	c9                   	leave  
  800256:	c3                   	ret    

00800257 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80025d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800260:	50                   	push   %eax
  800261:	ff 75 08             	pushl  0x8(%ebp)
  800264:	e8 9d ff ff ff       	call   800206 <vcprintf>
	va_end(ap);

	return cnt;
}
  800269:	c9                   	leave  
  80026a:	c3                   	ret    

0080026b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	57                   	push   %edi
  80026f:	56                   	push   %esi
  800270:	53                   	push   %ebx
  800271:	83 ec 1c             	sub    $0x1c,%esp
  800274:	89 c7                	mov    %eax,%edi
  800276:	89 d6                	mov    %edx,%esi
  800278:	8b 45 08             	mov    0x8(%ebp),%eax
  80027b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80027e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800281:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800284:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800287:	bb 00 00 00 00       	mov    $0x0,%ebx
  80028c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80028f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800292:	39 d3                	cmp    %edx,%ebx
  800294:	72 05                	jb     80029b <printnum+0x30>
  800296:	39 45 10             	cmp    %eax,0x10(%ebp)
  800299:	77 45                	ja     8002e0 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80029b:	83 ec 0c             	sub    $0xc,%esp
  80029e:	ff 75 18             	pushl  0x18(%ebp)
  8002a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8002a4:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002a7:	53                   	push   %ebx
  8002a8:	ff 75 10             	pushl  0x10(%ebp)
  8002ab:	83 ec 08             	sub    $0x8,%esp
  8002ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b4:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ba:	e8 21 1d 00 00       	call   801fe0 <__udivdi3>
  8002bf:	83 c4 18             	add    $0x18,%esp
  8002c2:	52                   	push   %edx
  8002c3:	50                   	push   %eax
  8002c4:	89 f2                	mov    %esi,%edx
  8002c6:	89 f8                	mov    %edi,%eax
  8002c8:	e8 9e ff ff ff       	call   80026b <printnum>
  8002cd:	83 c4 20             	add    $0x20,%esp
  8002d0:	eb 18                	jmp    8002ea <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002d2:	83 ec 08             	sub    $0x8,%esp
  8002d5:	56                   	push   %esi
  8002d6:	ff 75 18             	pushl  0x18(%ebp)
  8002d9:	ff d7                	call   *%edi
  8002db:	83 c4 10             	add    $0x10,%esp
  8002de:	eb 03                	jmp    8002e3 <printnum+0x78>
  8002e0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e3:	83 eb 01             	sub    $0x1,%ebx
  8002e6:	85 db                	test   %ebx,%ebx
  8002e8:	7f e8                	jg     8002d2 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ea:	83 ec 08             	sub    $0x8,%esp
  8002ed:	56                   	push   %esi
  8002ee:	83 ec 04             	sub    $0x4,%esp
  8002f1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002f4:	ff 75 e0             	pushl  -0x20(%ebp)
  8002f7:	ff 75 dc             	pushl  -0x24(%ebp)
  8002fa:	ff 75 d8             	pushl  -0x28(%ebp)
  8002fd:	e8 0e 1e 00 00       	call   802110 <__umoddi3>
  800302:	83 c4 14             	add    $0x14,%esp
  800305:	0f be 80 d3 22 80 00 	movsbl 0x8022d3(%eax),%eax
  80030c:	50                   	push   %eax
  80030d:	ff d7                	call   *%edi
}
  80030f:	83 c4 10             	add    $0x10,%esp
  800312:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5f                   	pop    %edi
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80031d:	83 fa 01             	cmp    $0x1,%edx
  800320:	7e 0e                	jle    800330 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800322:	8b 10                	mov    (%eax),%edx
  800324:	8d 4a 08             	lea    0x8(%edx),%ecx
  800327:	89 08                	mov    %ecx,(%eax)
  800329:	8b 02                	mov    (%edx),%eax
  80032b:	8b 52 04             	mov    0x4(%edx),%edx
  80032e:	eb 22                	jmp    800352 <getuint+0x38>
	else if (lflag)
  800330:	85 d2                	test   %edx,%edx
  800332:	74 10                	je     800344 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800334:	8b 10                	mov    (%eax),%edx
  800336:	8d 4a 04             	lea    0x4(%edx),%ecx
  800339:	89 08                	mov    %ecx,(%eax)
  80033b:	8b 02                	mov    (%edx),%eax
  80033d:	ba 00 00 00 00       	mov    $0x0,%edx
  800342:	eb 0e                	jmp    800352 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800344:	8b 10                	mov    (%eax),%edx
  800346:	8d 4a 04             	lea    0x4(%edx),%ecx
  800349:	89 08                	mov    %ecx,(%eax)
  80034b:	8b 02                	mov    (%edx),%eax
  80034d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80035a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80035e:	8b 10                	mov    (%eax),%edx
  800360:	3b 50 04             	cmp    0x4(%eax),%edx
  800363:	73 0a                	jae    80036f <sprintputch+0x1b>
		*b->buf++ = ch;
  800365:	8d 4a 01             	lea    0x1(%edx),%ecx
  800368:	89 08                	mov    %ecx,(%eax)
  80036a:	8b 45 08             	mov    0x8(%ebp),%eax
  80036d:	88 02                	mov    %al,(%edx)
}
  80036f:	5d                   	pop    %ebp
  800370:	c3                   	ret    

00800371 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800377:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80037a:	50                   	push   %eax
  80037b:	ff 75 10             	pushl  0x10(%ebp)
  80037e:	ff 75 0c             	pushl  0xc(%ebp)
  800381:	ff 75 08             	pushl  0x8(%ebp)
  800384:	e8 05 00 00 00       	call   80038e <vprintfmt>
	va_end(ap);
}
  800389:	83 c4 10             	add    $0x10,%esp
  80038c:	c9                   	leave  
  80038d:	c3                   	ret    

0080038e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	57                   	push   %edi
  800392:	56                   	push   %esi
  800393:	53                   	push   %ebx
  800394:	83 ec 2c             	sub    $0x2c,%esp
  800397:	8b 75 08             	mov    0x8(%ebp),%esi
  80039a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80039d:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003a0:	eb 12                	jmp    8003b4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003a2:	85 c0                	test   %eax,%eax
  8003a4:	0f 84 89 03 00 00    	je     800733 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003aa:	83 ec 08             	sub    $0x8,%esp
  8003ad:	53                   	push   %ebx
  8003ae:	50                   	push   %eax
  8003af:	ff d6                	call   *%esi
  8003b1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003b4:	83 c7 01             	add    $0x1,%edi
  8003b7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003bb:	83 f8 25             	cmp    $0x25,%eax
  8003be:	75 e2                	jne    8003a2 <vprintfmt+0x14>
  8003c0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003c4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003cb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003d2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003de:	eb 07                	jmp    8003e7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003e3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e7:	8d 47 01             	lea    0x1(%edi),%eax
  8003ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ed:	0f b6 07             	movzbl (%edi),%eax
  8003f0:	0f b6 c8             	movzbl %al,%ecx
  8003f3:	83 e8 23             	sub    $0x23,%eax
  8003f6:	3c 55                	cmp    $0x55,%al
  8003f8:	0f 87 1a 03 00 00    	ja     800718 <vprintfmt+0x38a>
  8003fe:	0f b6 c0             	movzbl %al,%eax
  800401:	ff 24 85 20 24 80 00 	jmp    *0x802420(,%eax,4)
  800408:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80040b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80040f:	eb d6                	jmp    8003e7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800411:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800414:	b8 00 00 00 00       	mov    $0x0,%eax
  800419:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80041c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80041f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800423:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800426:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800429:	83 fa 09             	cmp    $0x9,%edx
  80042c:	77 39                	ja     800467 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80042e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800431:	eb e9                	jmp    80041c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800433:	8b 45 14             	mov    0x14(%ebp),%eax
  800436:	8d 48 04             	lea    0x4(%eax),%ecx
  800439:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80043c:	8b 00                	mov    (%eax),%eax
  80043e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800441:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800444:	eb 27                	jmp    80046d <vprintfmt+0xdf>
  800446:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800449:	85 c0                	test   %eax,%eax
  80044b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800450:	0f 49 c8             	cmovns %eax,%ecx
  800453:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800456:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800459:	eb 8c                	jmp    8003e7 <vprintfmt+0x59>
  80045b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80045e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800465:	eb 80                	jmp    8003e7 <vprintfmt+0x59>
  800467:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80046a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80046d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800471:	0f 89 70 ff ff ff    	jns    8003e7 <vprintfmt+0x59>
				width = precision, precision = -1;
  800477:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80047a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800484:	e9 5e ff ff ff       	jmp    8003e7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800489:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80048f:	e9 53 ff ff ff       	jmp    8003e7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800494:	8b 45 14             	mov    0x14(%ebp),%eax
  800497:	8d 50 04             	lea    0x4(%eax),%edx
  80049a:	89 55 14             	mov    %edx,0x14(%ebp)
  80049d:	83 ec 08             	sub    $0x8,%esp
  8004a0:	53                   	push   %ebx
  8004a1:	ff 30                	pushl  (%eax)
  8004a3:	ff d6                	call   *%esi
			break;
  8004a5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004ab:	e9 04 ff ff ff       	jmp    8003b4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b3:	8d 50 04             	lea    0x4(%eax),%edx
  8004b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b9:	8b 00                	mov    (%eax),%eax
  8004bb:	99                   	cltd   
  8004bc:	31 d0                	xor    %edx,%eax
  8004be:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c0:	83 f8 0f             	cmp    $0xf,%eax
  8004c3:	7f 0b                	jg     8004d0 <vprintfmt+0x142>
  8004c5:	8b 14 85 80 25 80 00 	mov    0x802580(,%eax,4),%edx
  8004cc:	85 d2                	test   %edx,%edx
  8004ce:	75 18                	jne    8004e8 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004d0:	50                   	push   %eax
  8004d1:	68 eb 22 80 00       	push   $0x8022eb
  8004d6:	53                   	push   %ebx
  8004d7:	56                   	push   %esi
  8004d8:	e8 94 fe ff ff       	call   800371 <printfmt>
  8004dd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004e3:	e9 cc fe ff ff       	jmp    8003b4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004e8:	52                   	push   %edx
  8004e9:	68 49 27 80 00       	push   $0x802749
  8004ee:	53                   	push   %ebx
  8004ef:	56                   	push   %esi
  8004f0:	e8 7c fe ff ff       	call   800371 <printfmt>
  8004f5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004fb:	e9 b4 fe ff ff       	jmp    8003b4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800500:	8b 45 14             	mov    0x14(%ebp),%eax
  800503:	8d 50 04             	lea    0x4(%eax),%edx
  800506:	89 55 14             	mov    %edx,0x14(%ebp)
  800509:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80050b:	85 ff                	test   %edi,%edi
  80050d:	b8 e4 22 80 00       	mov    $0x8022e4,%eax
  800512:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800515:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800519:	0f 8e 94 00 00 00    	jle    8005b3 <vprintfmt+0x225>
  80051f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800523:	0f 84 98 00 00 00    	je     8005c1 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800529:	83 ec 08             	sub    $0x8,%esp
  80052c:	ff 75 d0             	pushl  -0x30(%ebp)
  80052f:	57                   	push   %edi
  800530:	e8 86 02 00 00       	call   8007bb <strnlen>
  800535:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800538:	29 c1                	sub    %eax,%ecx
  80053a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80053d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800540:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800544:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800547:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80054a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80054c:	eb 0f                	jmp    80055d <vprintfmt+0x1cf>
					putch(padc, putdat);
  80054e:	83 ec 08             	sub    $0x8,%esp
  800551:	53                   	push   %ebx
  800552:	ff 75 e0             	pushl  -0x20(%ebp)
  800555:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800557:	83 ef 01             	sub    $0x1,%edi
  80055a:	83 c4 10             	add    $0x10,%esp
  80055d:	85 ff                	test   %edi,%edi
  80055f:	7f ed                	jg     80054e <vprintfmt+0x1c0>
  800561:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800564:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800567:	85 c9                	test   %ecx,%ecx
  800569:	b8 00 00 00 00       	mov    $0x0,%eax
  80056e:	0f 49 c1             	cmovns %ecx,%eax
  800571:	29 c1                	sub    %eax,%ecx
  800573:	89 75 08             	mov    %esi,0x8(%ebp)
  800576:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800579:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80057c:	89 cb                	mov    %ecx,%ebx
  80057e:	eb 4d                	jmp    8005cd <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800580:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800584:	74 1b                	je     8005a1 <vprintfmt+0x213>
  800586:	0f be c0             	movsbl %al,%eax
  800589:	83 e8 20             	sub    $0x20,%eax
  80058c:	83 f8 5e             	cmp    $0x5e,%eax
  80058f:	76 10                	jbe    8005a1 <vprintfmt+0x213>
					putch('?', putdat);
  800591:	83 ec 08             	sub    $0x8,%esp
  800594:	ff 75 0c             	pushl  0xc(%ebp)
  800597:	6a 3f                	push   $0x3f
  800599:	ff 55 08             	call   *0x8(%ebp)
  80059c:	83 c4 10             	add    $0x10,%esp
  80059f:	eb 0d                	jmp    8005ae <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005a1:	83 ec 08             	sub    $0x8,%esp
  8005a4:	ff 75 0c             	pushl  0xc(%ebp)
  8005a7:	52                   	push   %edx
  8005a8:	ff 55 08             	call   *0x8(%ebp)
  8005ab:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ae:	83 eb 01             	sub    $0x1,%ebx
  8005b1:	eb 1a                	jmp    8005cd <vprintfmt+0x23f>
  8005b3:	89 75 08             	mov    %esi,0x8(%ebp)
  8005b6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005b9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005bc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005bf:	eb 0c                	jmp    8005cd <vprintfmt+0x23f>
  8005c1:	89 75 08             	mov    %esi,0x8(%ebp)
  8005c4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005c7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ca:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005cd:	83 c7 01             	add    $0x1,%edi
  8005d0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005d4:	0f be d0             	movsbl %al,%edx
  8005d7:	85 d2                	test   %edx,%edx
  8005d9:	74 23                	je     8005fe <vprintfmt+0x270>
  8005db:	85 f6                	test   %esi,%esi
  8005dd:	78 a1                	js     800580 <vprintfmt+0x1f2>
  8005df:	83 ee 01             	sub    $0x1,%esi
  8005e2:	79 9c                	jns    800580 <vprintfmt+0x1f2>
  8005e4:	89 df                	mov    %ebx,%edi
  8005e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ec:	eb 18                	jmp    800606 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ee:	83 ec 08             	sub    $0x8,%esp
  8005f1:	53                   	push   %ebx
  8005f2:	6a 20                	push   $0x20
  8005f4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005f6:	83 ef 01             	sub    $0x1,%edi
  8005f9:	83 c4 10             	add    $0x10,%esp
  8005fc:	eb 08                	jmp    800606 <vprintfmt+0x278>
  8005fe:	89 df                	mov    %ebx,%edi
  800600:	8b 75 08             	mov    0x8(%ebp),%esi
  800603:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800606:	85 ff                	test   %edi,%edi
  800608:	7f e4                	jg     8005ee <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80060d:	e9 a2 fd ff ff       	jmp    8003b4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800612:	83 fa 01             	cmp    $0x1,%edx
  800615:	7e 16                	jle    80062d <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8d 50 08             	lea    0x8(%eax),%edx
  80061d:	89 55 14             	mov    %edx,0x14(%ebp)
  800620:	8b 50 04             	mov    0x4(%eax),%edx
  800623:	8b 00                	mov    (%eax),%eax
  800625:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800628:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80062b:	eb 32                	jmp    80065f <vprintfmt+0x2d1>
	else if (lflag)
  80062d:	85 d2                	test   %edx,%edx
  80062f:	74 18                	je     800649 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8d 50 04             	lea    0x4(%eax),%edx
  800637:	89 55 14             	mov    %edx,0x14(%ebp)
  80063a:	8b 00                	mov    (%eax),%eax
  80063c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063f:	89 c1                	mov    %eax,%ecx
  800641:	c1 f9 1f             	sar    $0x1f,%ecx
  800644:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800647:	eb 16                	jmp    80065f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800649:	8b 45 14             	mov    0x14(%ebp),%eax
  80064c:	8d 50 04             	lea    0x4(%eax),%edx
  80064f:	89 55 14             	mov    %edx,0x14(%ebp)
  800652:	8b 00                	mov    (%eax),%eax
  800654:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800657:	89 c1                	mov    %eax,%ecx
  800659:	c1 f9 1f             	sar    $0x1f,%ecx
  80065c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80065f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800662:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800665:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80066a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80066e:	79 74                	jns    8006e4 <vprintfmt+0x356>
				putch('-', putdat);
  800670:	83 ec 08             	sub    $0x8,%esp
  800673:	53                   	push   %ebx
  800674:	6a 2d                	push   $0x2d
  800676:	ff d6                	call   *%esi
				num = -(long long) num;
  800678:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80067b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80067e:	f7 d8                	neg    %eax
  800680:	83 d2 00             	adc    $0x0,%edx
  800683:	f7 da                	neg    %edx
  800685:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800688:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80068d:	eb 55                	jmp    8006e4 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80068f:	8d 45 14             	lea    0x14(%ebp),%eax
  800692:	e8 83 fc ff ff       	call   80031a <getuint>
			base = 10;
  800697:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80069c:	eb 46                	jmp    8006e4 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80069e:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a1:	e8 74 fc ff ff       	call   80031a <getuint>
			base = 8;
  8006a6:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006ab:	eb 37                	jmp    8006e4 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8006ad:	83 ec 08             	sub    $0x8,%esp
  8006b0:	53                   	push   %ebx
  8006b1:	6a 30                	push   $0x30
  8006b3:	ff d6                	call   *%esi
			putch('x', putdat);
  8006b5:	83 c4 08             	add    $0x8,%esp
  8006b8:	53                   	push   %ebx
  8006b9:	6a 78                	push   $0x78
  8006bb:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c0:	8d 50 04             	lea    0x4(%eax),%edx
  8006c3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006c6:	8b 00                	mov    (%eax),%eax
  8006c8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006cd:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006d0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006d5:	eb 0d                	jmp    8006e4 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006da:	e8 3b fc ff ff       	call   80031a <getuint>
			base = 16;
  8006df:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006e4:	83 ec 0c             	sub    $0xc,%esp
  8006e7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006eb:	57                   	push   %edi
  8006ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ef:	51                   	push   %ecx
  8006f0:	52                   	push   %edx
  8006f1:	50                   	push   %eax
  8006f2:	89 da                	mov    %ebx,%edx
  8006f4:	89 f0                	mov    %esi,%eax
  8006f6:	e8 70 fb ff ff       	call   80026b <printnum>
			break;
  8006fb:	83 c4 20             	add    $0x20,%esp
  8006fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800701:	e9 ae fc ff ff       	jmp    8003b4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800706:	83 ec 08             	sub    $0x8,%esp
  800709:	53                   	push   %ebx
  80070a:	51                   	push   %ecx
  80070b:	ff d6                	call   *%esi
			break;
  80070d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800710:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800713:	e9 9c fc ff ff       	jmp    8003b4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800718:	83 ec 08             	sub    $0x8,%esp
  80071b:	53                   	push   %ebx
  80071c:	6a 25                	push   $0x25
  80071e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800720:	83 c4 10             	add    $0x10,%esp
  800723:	eb 03                	jmp    800728 <vprintfmt+0x39a>
  800725:	83 ef 01             	sub    $0x1,%edi
  800728:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80072c:	75 f7                	jne    800725 <vprintfmt+0x397>
  80072e:	e9 81 fc ff ff       	jmp    8003b4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800733:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800736:	5b                   	pop    %ebx
  800737:	5e                   	pop    %esi
  800738:	5f                   	pop    %edi
  800739:	5d                   	pop    %ebp
  80073a:	c3                   	ret    

0080073b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	83 ec 18             	sub    $0x18,%esp
  800741:	8b 45 08             	mov    0x8(%ebp),%eax
  800744:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800747:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80074a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80074e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800751:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800758:	85 c0                	test   %eax,%eax
  80075a:	74 26                	je     800782 <vsnprintf+0x47>
  80075c:	85 d2                	test   %edx,%edx
  80075e:	7e 22                	jle    800782 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800760:	ff 75 14             	pushl  0x14(%ebp)
  800763:	ff 75 10             	pushl  0x10(%ebp)
  800766:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800769:	50                   	push   %eax
  80076a:	68 54 03 80 00       	push   $0x800354
  80076f:	e8 1a fc ff ff       	call   80038e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800774:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800777:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80077a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	eb 05                	jmp    800787 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800782:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800787:	c9                   	leave  
  800788:	c3                   	ret    

00800789 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800789:	55                   	push   %ebp
  80078a:	89 e5                	mov    %esp,%ebp
  80078c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80078f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800792:	50                   	push   %eax
  800793:	ff 75 10             	pushl  0x10(%ebp)
  800796:	ff 75 0c             	pushl  0xc(%ebp)
  800799:	ff 75 08             	pushl  0x8(%ebp)
  80079c:	e8 9a ff ff ff       	call   80073b <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a1:	c9                   	leave  
  8007a2:	c3                   	ret    

008007a3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a3:	55                   	push   %ebp
  8007a4:	89 e5                	mov    %esp,%ebp
  8007a6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ae:	eb 03                	jmp    8007b3 <strlen+0x10>
		n++;
  8007b0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b7:	75 f7                	jne    8007b0 <strlen+0xd>
		n++;
	return n;
}
  8007b9:	5d                   	pop    %ebp
  8007ba:	c3                   	ret    

008007bb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c9:	eb 03                	jmp    8007ce <strnlen+0x13>
		n++;
  8007cb:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ce:	39 c2                	cmp    %eax,%edx
  8007d0:	74 08                	je     8007da <strnlen+0x1f>
  8007d2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007d6:	75 f3                	jne    8007cb <strnlen+0x10>
  8007d8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007da:	5d                   	pop    %ebp
  8007db:	c3                   	ret    

008007dc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	53                   	push   %ebx
  8007e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e6:	89 c2                	mov    %eax,%edx
  8007e8:	83 c2 01             	add    $0x1,%edx
  8007eb:	83 c1 01             	add    $0x1,%ecx
  8007ee:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007f2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007f5:	84 db                	test   %bl,%bl
  8007f7:	75 ef                	jne    8007e8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007f9:	5b                   	pop    %ebx
  8007fa:	5d                   	pop    %ebp
  8007fb:	c3                   	ret    

008007fc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	53                   	push   %ebx
  800800:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800803:	53                   	push   %ebx
  800804:	e8 9a ff ff ff       	call   8007a3 <strlen>
  800809:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80080c:	ff 75 0c             	pushl  0xc(%ebp)
  80080f:	01 d8                	add    %ebx,%eax
  800811:	50                   	push   %eax
  800812:	e8 c5 ff ff ff       	call   8007dc <strcpy>
	return dst;
}
  800817:	89 d8                	mov    %ebx,%eax
  800819:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80081c:	c9                   	leave  
  80081d:	c3                   	ret    

0080081e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	56                   	push   %esi
  800822:	53                   	push   %ebx
  800823:	8b 75 08             	mov    0x8(%ebp),%esi
  800826:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800829:	89 f3                	mov    %esi,%ebx
  80082b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082e:	89 f2                	mov    %esi,%edx
  800830:	eb 0f                	jmp    800841 <strncpy+0x23>
		*dst++ = *src;
  800832:	83 c2 01             	add    $0x1,%edx
  800835:	0f b6 01             	movzbl (%ecx),%eax
  800838:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80083b:	80 39 01             	cmpb   $0x1,(%ecx)
  80083e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800841:	39 da                	cmp    %ebx,%edx
  800843:	75 ed                	jne    800832 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800845:	89 f0                	mov    %esi,%eax
  800847:	5b                   	pop    %ebx
  800848:	5e                   	pop    %esi
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	56                   	push   %esi
  80084f:	53                   	push   %ebx
  800850:	8b 75 08             	mov    0x8(%ebp),%esi
  800853:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800856:	8b 55 10             	mov    0x10(%ebp),%edx
  800859:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80085b:	85 d2                	test   %edx,%edx
  80085d:	74 21                	je     800880 <strlcpy+0x35>
  80085f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800863:	89 f2                	mov    %esi,%edx
  800865:	eb 09                	jmp    800870 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800867:	83 c2 01             	add    $0x1,%edx
  80086a:	83 c1 01             	add    $0x1,%ecx
  80086d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800870:	39 c2                	cmp    %eax,%edx
  800872:	74 09                	je     80087d <strlcpy+0x32>
  800874:	0f b6 19             	movzbl (%ecx),%ebx
  800877:	84 db                	test   %bl,%bl
  800879:	75 ec                	jne    800867 <strlcpy+0x1c>
  80087b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80087d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800880:	29 f0                	sub    %esi,%eax
}
  800882:	5b                   	pop    %ebx
  800883:	5e                   	pop    %esi
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80088f:	eb 06                	jmp    800897 <strcmp+0x11>
		p++, q++;
  800891:	83 c1 01             	add    $0x1,%ecx
  800894:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800897:	0f b6 01             	movzbl (%ecx),%eax
  80089a:	84 c0                	test   %al,%al
  80089c:	74 04                	je     8008a2 <strcmp+0x1c>
  80089e:	3a 02                	cmp    (%edx),%al
  8008a0:	74 ef                	je     800891 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a2:	0f b6 c0             	movzbl %al,%eax
  8008a5:	0f b6 12             	movzbl (%edx),%edx
  8008a8:	29 d0                	sub    %edx,%eax
}
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	53                   	push   %ebx
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b6:	89 c3                	mov    %eax,%ebx
  8008b8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008bb:	eb 06                	jmp    8008c3 <strncmp+0x17>
		n--, p++, q++;
  8008bd:	83 c0 01             	add    $0x1,%eax
  8008c0:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008c3:	39 d8                	cmp    %ebx,%eax
  8008c5:	74 15                	je     8008dc <strncmp+0x30>
  8008c7:	0f b6 08             	movzbl (%eax),%ecx
  8008ca:	84 c9                	test   %cl,%cl
  8008cc:	74 04                	je     8008d2 <strncmp+0x26>
  8008ce:	3a 0a                	cmp    (%edx),%cl
  8008d0:	74 eb                	je     8008bd <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d2:	0f b6 00             	movzbl (%eax),%eax
  8008d5:	0f b6 12             	movzbl (%edx),%edx
  8008d8:	29 d0                	sub    %edx,%eax
  8008da:	eb 05                	jmp    8008e1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008dc:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e1:	5b                   	pop    %ebx
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ee:	eb 07                	jmp    8008f7 <strchr+0x13>
		if (*s == c)
  8008f0:	38 ca                	cmp    %cl,%dl
  8008f2:	74 0f                	je     800903 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008f4:	83 c0 01             	add    $0x1,%eax
  8008f7:	0f b6 10             	movzbl (%eax),%edx
  8008fa:	84 d2                	test   %dl,%dl
  8008fc:	75 f2                	jne    8008f0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	8b 45 08             	mov    0x8(%ebp),%eax
  80090b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090f:	eb 03                	jmp    800914 <strfind+0xf>
  800911:	83 c0 01             	add    $0x1,%eax
  800914:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800917:	38 ca                	cmp    %cl,%dl
  800919:	74 04                	je     80091f <strfind+0x1a>
  80091b:	84 d2                	test   %dl,%dl
  80091d:	75 f2                	jne    800911 <strfind+0xc>
			break;
	return (char *) s;
}
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	57                   	push   %edi
  800925:	56                   	push   %esi
  800926:	53                   	push   %ebx
  800927:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80092d:	85 c9                	test   %ecx,%ecx
  80092f:	74 36                	je     800967 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800931:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800937:	75 28                	jne    800961 <memset+0x40>
  800939:	f6 c1 03             	test   $0x3,%cl
  80093c:	75 23                	jne    800961 <memset+0x40>
		c &= 0xFF;
  80093e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800942:	89 d3                	mov    %edx,%ebx
  800944:	c1 e3 08             	shl    $0x8,%ebx
  800947:	89 d6                	mov    %edx,%esi
  800949:	c1 e6 18             	shl    $0x18,%esi
  80094c:	89 d0                	mov    %edx,%eax
  80094e:	c1 e0 10             	shl    $0x10,%eax
  800951:	09 f0                	or     %esi,%eax
  800953:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800955:	89 d8                	mov    %ebx,%eax
  800957:	09 d0                	or     %edx,%eax
  800959:	c1 e9 02             	shr    $0x2,%ecx
  80095c:	fc                   	cld    
  80095d:	f3 ab                	rep stos %eax,%es:(%edi)
  80095f:	eb 06                	jmp    800967 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800961:	8b 45 0c             	mov    0xc(%ebp),%eax
  800964:	fc                   	cld    
  800965:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800967:	89 f8                	mov    %edi,%eax
  800969:	5b                   	pop    %ebx
  80096a:	5e                   	pop    %esi
  80096b:	5f                   	pop    %edi
  80096c:	5d                   	pop    %ebp
  80096d:	c3                   	ret    

0080096e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	57                   	push   %edi
  800972:	56                   	push   %esi
  800973:	8b 45 08             	mov    0x8(%ebp),%eax
  800976:	8b 75 0c             	mov    0xc(%ebp),%esi
  800979:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80097c:	39 c6                	cmp    %eax,%esi
  80097e:	73 35                	jae    8009b5 <memmove+0x47>
  800980:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800983:	39 d0                	cmp    %edx,%eax
  800985:	73 2e                	jae    8009b5 <memmove+0x47>
		s += n;
		d += n;
  800987:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098a:	89 d6                	mov    %edx,%esi
  80098c:	09 fe                	or     %edi,%esi
  80098e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800994:	75 13                	jne    8009a9 <memmove+0x3b>
  800996:	f6 c1 03             	test   $0x3,%cl
  800999:	75 0e                	jne    8009a9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80099b:	83 ef 04             	sub    $0x4,%edi
  80099e:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a1:	c1 e9 02             	shr    $0x2,%ecx
  8009a4:	fd                   	std    
  8009a5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a7:	eb 09                	jmp    8009b2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a9:	83 ef 01             	sub    $0x1,%edi
  8009ac:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009af:	fd                   	std    
  8009b0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b2:	fc                   	cld    
  8009b3:	eb 1d                	jmp    8009d2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b5:	89 f2                	mov    %esi,%edx
  8009b7:	09 c2                	or     %eax,%edx
  8009b9:	f6 c2 03             	test   $0x3,%dl
  8009bc:	75 0f                	jne    8009cd <memmove+0x5f>
  8009be:	f6 c1 03             	test   $0x3,%cl
  8009c1:	75 0a                	jne    8009cd <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009c3:	c1 e9 02             	shr    $0x2,%ecx
  8009c6:	89 c7                	mov    %eax,%edi
  8009c8:	fc                   	cld    
  8009c9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009cb:	eb 05                	jmp    8009d2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009cd:	89 c7                	mov    %eax,%edi
  8009cf:	fc                   	cld    
  8009d0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d2:	5e                   	pop    %esi
  8009d3:	5f                   	pop    %edi
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009d9:	ff 75 10             	pushl  0x10(%ebp)
  8009dc:	ff 75 0c             	pushl  0xc(%ebp)
  8009df:	ff 75 08             	pushl  0x8(%ebp)
  8009e2:	e8 87 ff ff ff       	call   80096e <memmove>
}
  8009e7:	c9                   	leave  
  8009e8:	c3                   	ret    

008009e9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	56                   	push   %esi
  8009ed:	53                   	push   %ebx
  8009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f4:	89 c6                	mov    %eax,%esi
  8009f6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f9:	eb 1a                	jmp    800a15 <memcmp+0x2c>
		if (*s1 != *s2)
  8009fb:	0f b6 08             	movzbl (%eax),%ecx
  8009fe:	0f b6 1a             	movzbl (%edx),%ebx
  800a01:	38 d9                	cmp    %bl,%cl
  800a03:	74 0a                	je     800a0f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a05:	0f b6 c1             	movzbl %cl,%eax
  800a08:	0f b6 db             	movzbl %bl,%ebx
  800a0b:	29 d8                	sub    %ebx,%eax
  800a0d:	eb 0f                	jmp    800a1e <memcmp+0x35>
		s1++, s2++;
  800a0f:	83 c0 01             	add    $0x1,%eax
  800a12:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a15:	39 f0                	cmp    %esi,%eax
  800a17:	75 e2                	jne    8009fb <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a19:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1e:	5b                   	pop    %ebx
  800a1f:	5e                   	pop    %esi
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	53                   	push   %ebx
  800a26:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a29:	89 c1                	mov    %eax,%ecx
  800a2b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a2e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a32:	eb 0a                	jmp    800a3e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a34:	0f b6 10             	movzbl (%eax),%edx
  800a37:	39 da                	cmp    %ebx,%edx
  800a39:	74 07                	je     800a42 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a3b:	83 c0 01             	add    $0x1,%eax
  800a3e:	39 c8                	cmp    %ecx,%eax
  800a40:	72 f2                	jb     800a34 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a42:	5b                   	pop    %ebx
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    

00800a45 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	57                   	push   %edi
  800a49:	56                   	push   %esi
  800a4a:	53                   	push   %ebx
  800a4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a51:	eb 03                	jmp    800a56 <strtol+0x11>
		s++;
  800a53:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a56:	0f b6 01             	movzbl (%ecx),%eax
  800a59:	3c 20                	cmp    $0x20,%al
  800a5b:	74 f6                	je     800a53 <strtol+0xe>
  800a5d:	3c 09                	cmp    $0x9,%al
  800a5f:	74 f2                	je     800a53 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a61:	3c 2b                	cmp    $0x2b,%al
  800a63:	75 0a                	jne    800a6f <strtol+0x2a>
		s++;
  800a65:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a68:	bf 00 00 00 00       	mov    $0x0,%edi
  800a6d:	eb 11                	jmp    800a80 <strtol+0x3b>
  800a6f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a74:	3c 2d                	cmp    $0x2d,%al
  800a76:	75 08                	jne    800a80 <strtol+0x3b>
		s++, neg = 1;
  800a78:	83 c1 01             	add    $0x1,%ecx
  800a7b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a80:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a86:	75 15                	jne    800a9d <strtol+0x58>
  800a88:	80 39 30             	cmpb   $0x30,(%ecx)
  800a8b:	75 10                	jne    800a9d <strtol+0x58>
  800a8d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a91:	75 7c                	jne    800b0f <strtol+0xca>
		s += 2, base = 16;
  800a93:	83 c1 02             	add    $0x2,%ecx
  800a96:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a9b:	eb 16                	jmp    800ab3 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a9d:	85 db                	test   %ebx,%ebx
  800a9f:	75 12                	jne    800ab3 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aa1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa6:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa9:	75 08                	jne    800ab3 <strtol+0x6e>
		s++, base = 8;
  800aab:	83 c1 01             	add    $0x1,%ecx
  800aae:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ab3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800abb:	0f b6 11             	movzbl (%ecx),%edx
  800abe:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ac1:	89 f3                	mov    %esi,%ebx
  800ac3:	80 fb 09             	cmp    $0x9,%bl
  800ac6:	77 08                	ja     800ad0 <strtol+0x8b>
			dig = *s - '0';
  800ac8:	0f be d2             	movsbl %dl,%edx
  800acb:	83 ea 30             	sub    $0x30,%edx
  800ace:	eb 22                	jmp    800af2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ad0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ad3:	89 f3                	mov    %esi,%ebx
  800ad5:	80 fb 19             	cmp    $0x19,%bl
  800ad8:	77 08                	ja     800ae2 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ada:	0f be d2             	movsbl %dl,%edx
  800add:	83 ea 57             	sub    $0x57,%edx
  800ae0:	eb 10                	jmp    800af2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ae2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ae5:	89 f3                	mov    %esi,%ebx
  800ae7:	80 fb 19             	cmp    $0x19,%bl
  800aea:	77 16                	ja     800b02 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aec:	0f be d2             	movsbl %dl,%edx
  800aef:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800af2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800af5:	7d 0b                	jge    800b02 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800af7:	83 c1 01             	add    $0x1,%ecx
  800afa:	0f af 45 10          	imul   0x10(%ebp),%eax
  800afe:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b00:	eb b9                	jmp    800abb <strtol+0x76>

	if (endptr)
  800b02:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b06:	74 0d                	je     800b15 <strtol+0xd0>
		*endptr = (char *) s;
  800b08:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b0b:	89 0e                	mov    %ecx,(%esi)
  800b0d:	eb 06                	jmp    800b15 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b0f:	85 db                	test   %ebx,%ebx
  800b11:	74 98                	je     800aab <strtol+0x66>
  800b13:	eb 9e                	jmp    800ab3 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b15:	89 c2                	mov    %eax,%edx
  800b17:	f7 da                	neg    %edx
  800b19:	85 ff                	test   %edi,%edi
  800b1b:	0f 45 c2             	cmovne %edx,%eax
}
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5f                   	pop    %edi
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	57                   	push   %edi
  800b27:	56                   	push   %esi
  800b28:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b29:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b31:	8b 55 08             	mov    0x8(%ebp),%edx
  800b34:	89 c3                	mov    %eax,%ebx
  800b36:	89 c7                	mov    %eax,%edi
  800b38:	89 c6                	mov    %eax,%esi
  800b3a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b3c:	5b                   	pop    %ebx
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	57                   	push   %edi
  800b45:	56                   	push   %esi
  800b46:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b47:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b51:	89 d1                	mov    %edx,%ecx
  800b53:	89 d3                	mov    %edx,%ebx
  800b55:	89 d7                	mov    %edx,%edi
  800b57:	89 d6                	mov    %edx,%esi
  800b59:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b5b:	5b                   	pop    %ebx
  800b5c:	5e                   	pop    %esi
  800b5d:	5f                   	pop    %edi
  800b5e:	5d                   	pop    %ebp
  800b5f:	c3                   	ret    

00800b60 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	57                   	push   %edi
  800b64:	56                   	push   %esi
  800b65:	53                   	push   %ebx
  800b66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b69:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6e:	b8 03 00 00 00       	mov    $0x3,%eax
  800b73:	8b 55 08             	mov    0x8(%ebp),%edx
  800b76:	89 cb                	mov    %ecx,%ebx
  800b78:	89 cf                	mov    %ecx,%edi
  800b7a:	89 ce                	mov    %ecx,%esi
  800b7c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b7e:	85 c0                	test   %eax,%eax
  800b80:	7e 17                	jle    800b99 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b82:	83 ec 0c             	sub    $0xc,%esp
  800b85:	50                   	push   %eax
  800b86:	6a 03                	push   $0x3
  800b88:	68 df 25 80 00       	push   $0x8025df
  800b8d:	6a 23                	push   $0x23
  800b8f:	68 fc 25 80 00       	push   $0x8025fc
  800b94:	e8 e5 f5 ff ff       	call   80017e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	57                   	push   %edi
  800ba5:	56                   	push   %esi
  800ba6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bac:	b8 02 00 00 00       	mov    $0x2,%eax
  800bb1:	89 d1                	mov    %edx,%ecx
  800bb3:	89 d3                	mov    %edx,%ebx
  800bb5:	89 d7                	mov    %edx,%edi
  800bb7:	89 d6                	mov    %edx,%esi
  800bb9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bbb:	5b                   	pop    %ebx
  800bbc:	5e                   	pop    %esi
  800bbd:	5f                   	pop    %edi
  800bbe:	5d                   	pop    %ebp
  800bbf:	c3                   	ret    

00800bc0 <sys_yield>:

void
sys_yield(void)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	57                   	push   %edi
  800bc4:	56                   	push   %esi
  800bc5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcb:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bd0:	89 d1                	mov    %edx,%ecx
  800bd2:	89 d3                	mov    %edx,%ebx
  800bd4:	89 d7                	mov    %edx,%edi
  800bd6:	89 d6                	mov    %edx,%esi
  800bd8:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bda:	5b                   	pop    %ebx
  800bdb:	5e                   	pop    %esi
  800bdc:	5f                   	pop    %edi
  800bdd:	5d                   	pop    %ebp
  800bde:	c3                   	ret    

00800bdf <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	57                   	push   %edi
  800be3:	56                   	push   %esi
  800be4:	53                   	push   %ebx
  800be5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be8:	be 00 00 00 00       	mov    $0x0,%esi
  800bed:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bfb:	89 f7                	mov    %esi,%edi
  800bfd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bff:	85 c0                	test   %eax,%eax
  800c01:	7e 17                	jle    800c1a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c03:	83 ec 0c             	sub    $0xc,%esp
  800c06:	50                   	push   %eax
  800c07:	6a 04                	push   $0x4
  800c09:	68 df 25 80 00       	push   $0x8025df
  800c0e:	6a 23                	push   $0x23
  800c10:	68 fc 25 80 00       	push   $0x8025fc
  800c15:	e8 64 f5 ff ff       	call   80017e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1d:	5b                   	pop    %ebx
  800c1e:	5e                   	pop    %esi
  800c1f:	5f                   	pop    %edi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
  800c28:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2b:	b8 05 00 00 00       	mov    $0x5,%eax
  800c30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c33:	8b 55 08             	mov    0x8(%ebp),%edx
  800c36:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c39:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c3c:	8b 75 18             	mov    0x18(%ebp),%esi
  800c3f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c41:	85 c0                	test   %eax,%eax
  800c43:	7e 17                	jle    800c5c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c45:	83 ec 0c             	sub    $0xc,%esp
  800c48:	50                   	push   %eax
  800c49:	6a 05                	push   $0x5
  800c4b:	68 df 25 80 00       	push   $0x8025df
  800c50:	6a 23                	push   $0x23
  800c52:	68 fc 25 80 00       	push   $0x8025fc
  800c57:	e8 22 f5 ff ff       	call   80017e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
  800c6a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c72:	b8 06 00 00 00       	mov    $0x6,%eax
  800c77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7d:	89 df                	mov    %ebx,%edi
  800c7f:	89 de                	mov    %ebx,%esi
  800c81:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c83:	85 c0                	test   %eax,%eax
  800c85:	7e 17                	jle    800c9e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c87:	83 ec 0c             	sub    $0xc,%esp
  800c8a:	50                   	push   %eax
  800c8b:	6a 06                	push   $0x6
  800c8d:	68 df 25 80 00       	push   $0x8025df
  800c92:	6a 23                	push   $0x23
  800c94:	68 fc 25 80 00       	push   $0x8025fc
  800c99:	e8 e0 f4 ff ff       	call   80017e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    

00800ca6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
  800cac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb4:	b8 08 00 00 00       	mov    $0x8,%eax
  800cb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbf:	89 df                	mov    %ebx,%edi
  800cc1:	89 de                	mov    %ebx,%esi
  800cc3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc5:	85 c0                	test   %eax,%eax
  800cc7:	7e 17                	jle    800ce0 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc9:	83 ec 0c             	sub    $0xc,%esp
  800ccc:	50                   	push   %eax
  800ccd:	6a 08                	push   $0x8
  800ccf:	68 df 25 80 00       	push   $0x8025df
  800cd4:	6a 23                	push   $0x23
  800cd6:	68 fc 25 80 00       	push   $0x8025fc
  800cdb:	e8 9e f4 ff ff       	call   80017e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ce0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce3:	5b                   	pop    %ebx
  800ce4:	5e                   	pop    %esi
  800ce5:	5f                   	pop    %edi
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	57                   	push   %edi
  800cec:	56                   	push   %esi
  800ced:	53                   	push   %ebx
  800cee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf6:	b8 09 00 00 00       	mov    $0x9,%eax
  800cfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800d01:	89 df                	mov    %ebx,%edi
  800d03:	89 de                	mov    %ebx,%esi
  800d05:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d07:	85 c0                	test   %eax,%eax
  800d09:	7e 17                	jle    800d22 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0b:	83 ec 0c             	sub    $0xc,%esp
  800d0e:	50                   	push   %eax
  800d0f:	6a 09                	push   $0x9
  800d11:	68 df 25 80 00       	push   $0x8025df
  800d16:	6a 23                	push   $0x23
  800d18:	68 fc 25 80 00       	push   $0x8025fc
  800d1d:	e8 5c f4 ff ff       	call   80017e <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
  800d30:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d38:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d40:	8b 55 08             	mov    0x8(%ebp),%edx
  800d43:	89 df                	mov    %ebx,%edi
  800d45:	89 de                	mov    %ebx,%esi
  800d47:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	7e 17                	jle    800d64 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4d:	83 ec 0c             	sub    $0xc,%esp
  800d50:	50                   	push   %eax
  800d51:	6a 0a                	push   $0xa
  800d53:	68 df 25 80 00       	push   $0x8025df
  800d58:	6a 23                	push   $0x23
  800d5a:	68 fc 25 80 00       	push   $0x8025fc
  800d5f:	e8 1a f4 ff ff       	call   80017e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d67:	5b                   	pop    %ebx
  800d68:	5e                   	pop    %esi
  800d69:	5f                   	pop    %edi
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	57                   	push   %edi
  800d70:	56                   	push   %esi
  800d71:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d72:	be 00 00 00 00       	mov    $0x0,%esi
  800d77:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d82:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d85:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d88:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d8a:	5b                   	pop    %ebx
  800d8b:	5e                   	pop    %esi
  800d8c:	5f                   	pop    %edi
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    

00800d8f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	57                   	push   %edi
  800d93:	56                   	push   %esi
  800d94:	53                   	push   %ebx
  800d95:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d98:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d9d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800da2:	8b 55 08             	mov    0x8(%ebp),%edx
  800da5:	89 cb                	mov    %ecx,%ebx
  800da7:	89 cf                	mov    %ecx,%edi
  800da9:	89 ce                	mov    %ecx,%esi
  800dab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dad:	85 c0                	test   %eax,%eax
  800daf:	7e 17                	jle    800dc8 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db1:	83 ec 0c             	sub    $0xc,%esp
  800db4:	50                   	push   %eax
  800db5:	6a 0d                	push   $0xd
  800db7:	68 df 25 80 00       	push   $0x8025df
  800dbc:	6a 23                	push   $0x23
  800dbe:	68 fc 25 80 00       	push   $0x8025fc
  800dc3:	e8 b6 f3 ff ff       	call   80017e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcb:	5b                   	pop    %ebx
  800dcc:	5e                   	pop    %esi
  800dcd:	5f                   	pop    %edi
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	57                   	push   %edi
  800dd4:	56                   	push   %esi
  800dd5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ddb:	b8 0e 00 00 00       	mov    $0xe,%eax
  800de0:	8b 55 08             	mov    0x8(%ebp),%edx
  800de3:	89 cb                	mov    %ecx,%ebx
  800de5:	89 cf                	mov    %ecx,%edi
  800de7:	89 ce                	mov    %ecx,%esi
  800de9:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800deb:	5b                   	pop    %ebx
  800dec:	5e                   	pop    %esi
  800ded:	5f                   	pop    %edi
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	57                   	push   %edi
  800df4:	56                   	push   %esi
  800df5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dfb:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e00:	8b 55 08             	mov    0x8(%ebp),%edx
  800e03:	89 cb                	mov    %ecx,%ebx
  800e05:	89 cf                	mov    %ecx,%edi
  800e07:	89 ce                	mov    %ecx,%esi
  800e09:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800e0b:	5b                   	pop    %ebx
  800e0c:	5e                   	pop    %esi
  800e0d:	5f                   	pop    %edi
  800e0e:	5d                   	pop    %ebp
  800e0f:	c3                   	ret    

00800e10 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	53                   	push   %ebx
  800e14:	83 ec 04             	sub    $0x4,%esp
  800e17:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e1a:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800e1c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e20:	74 11                	je     800e33 <pgfault+0x23>
  800e22:	89 d8                	mov    %ebx,%eax
  800e24:	c1 e8 0c             	shr    $0xc,%eax
  800e27:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e2e:	f6 c4 08             	test   $0x8,%ah
  800e31:	75 14                	jne    800e47 <pgfault+0x37>
		panic("faulting access");
  800e33:	83 ec 04             	sub    $0x4,%esp
  800e36:	68 0a 26 80 00       	push   $0x80260a
  800e3b:	6a 1e                	push   $0x1e
  800e3d:	68 1a 26 80 00       	push   $0x80261a
  800e42:	e8 37 f3 ff ff       	call   80017e <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e47:	83 ec 04             	sub    $0x4,%esp
  800e4a:	6a 07                	push   $0x7
  800e4c:	68 00 f0 7f 00       	push   $0x7ff000
  800e51:	6a 00                	push   $0x0
  800e53:	e8 87 fd ff ff       	call   800bdf <sys_page_alloc>
	if (r < 0) {
  800e58:	83 c4 10             	add    $0x10,%esp
  800e5b:	85 c0                	test   %eax,%eax
  800e5d:	79 12                	jns    800e71 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e5f:	50                   	push   %eax
  800e60:	68 25 26 80 00       	push   $0x802625
  800e65:	6a 2c                	push   $0x2c
  800e67:	68 1a 26 80 00       	push   $0x80261a
  800e6c:	e8 0d f3 ff ff       	call   80017e <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e71:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e77:	83 ec 04             	sub    $0x4,%esp
  800e7a:	68 00 10 00 00       	push   $0x1000
  800e7f:	53                   	push   %ebx
  800e80:	68 00 f0 7f 00       	push   $0x7ff000
  800e85:	e8 4c fb ff ff       	call   8009d6 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e8a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e91:	53                   	push   %ebx
  800e92:	6a 00                	push   $0x0
  800e94:	68 00 f0 7f 00       	push   $0x7ff000
  800e99:	6a 00                	push   $0x0
  800e9b:	e8 82 fd ff ff       	call   800c22 <sys_page_map>
	if (r < 0) {
  800ea0:	83 c4 20             	add    $0x20,%esp
  800ea3:	85 c0                	test   %eax,%eax
  800ea5:	79 12                	jns    800eb9 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800ea7:	50                   	push   %eax
  800ea8:	68 25 26 80 00       	push   $0x802625
  800ead:	6a 33                	push   $0x33
  800eaf:	68 1a 26 80 00       	push   $0x80261a
  800eb4:	e8 c5 f2 ff ff       	call   80017e <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800eb9:	83 ec 08             	sub    $0x8,%esp
  800ebc:	68 00 f0 7f 00       	push   $0x7ff000
  800ec1:	6a 00                	push   $0x0
  800ec3:	e8 9c fd ff ff       	call   800c64 <sys_page_unmap>
	if (r < 0) {
  800ec8:	83 c4 10             	add    $0x10,%esp
  800ecb:	85 c0                	test   %eax,%eax
  800ecd:	79 12                	jns    800ee1 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800ecf:	50                   	push   %eax
  800ed0:	68 25 26 80 00       	push   $0x802625
  800ed5:	6a 37                	push   $0x37
  800ed7:	68 1a 26 80 00       	push   $0x80261a
  800edc:	e8 9d f2 ff ff       	call   80017e <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800ee1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ee4:	c9                   	leave  
  800ee5:	c3                   	ret    

00800ee6 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	57                   	push   %edi
  800eea:	56                   	push   %esi
  800eeb:	53                   	push   %ebx
  800eec:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800eef:	68 10 0e 80 00       	push   $0x800e10
  800ef4:	e8 1d 10 00 00       	call   801f16 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ef9:	b8 07 00 00 00       	mov    $0x7,%eax
  800efe:	cd 30                	int    $0x30
  800f00:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800f03:	83 c4 10             	add    $0x10,%esp
  800f06:	85 c0                	test   %eax,%eax
  800f08:	79 17                	jns    800f21 <fork+0x3b>
		panic("fork fault %e");
  800f0a:	83 ec 04             	sub    $0x4,%esp
  800f0d:	68 3e 26 80 00       	push   $0x80263e
  800f12:	68 84 00 00 00       	push   $0x84
  800f17:	68 1a 26 80 00       	push   $0x80261a
  800f1c:	e8 5d f2 ff ff       	call   80017e <_panic>
  800f21:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f23:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f27:	75 24                	jne    800f4d <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f29:	e8 73 fc ff ff       	call   800ba1 <sys_getenvid>
  800f2e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f33:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800f39:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f3e:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f43:	b8 00 00 00 00       	mov    $0x0,%eax
  800f48:	e9 64 01 00 00       	jmp    8010b1 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f4d:	83 ec 04             	sub    $0x4,%esp
  800f50:	6a 07                	push   $0x7
  800f52:	68 00 f0 bf ee       	push   $0xeebff000
  800f57:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f5a:	e8 80 fc ff ff       	call   800bdf <sys_page_alloc>
  800f5f:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f62:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f67:	89 d8                	mov    %ebx,%eax
  800f69:	c1 e8 16             	shr    $0x16,%eax
  800f6c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f73:	a8 01                	test   $0x1,%al
  800f75:	0f 84 fc 00 00 00    	je     801077 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f7b:	89 d8                	mov    %ebx,%eax
  800f7d:	c1 e8 0c             	shr    $0xc,%eax
  800f80:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f87:	f6 c2 01             	test   $0x1,%dl
  800f8a:	0f 84 e7 00 00 00    	je     801077 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f90:	89 c6                	mov    %eax,%esi
  800f92:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f95:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f9c:	f6 c6 04             	test   $0x4,%dh
  800f9f:	74 39                	je     800fda <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800fa1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fa8:	83 ec 0c             	sub    $0xc,%esp
  800fab:	25 07 0e 00 00       	and    $0xe07,%eax
  800fb0:	50                   	push   %eax
  800fb1:	56                   	push   %esi
  800fb2:	57                   	push   %edi
  800fb3:	56                   	push   %esi
  800fb4:	6a 00                	push   $0x0
  800fb6:	e8 67 fc ff ff       	call   800c22 <sys_page_map>
		if (r < 0) {
  800fbb:	83 c4 20             	add    $0x20,%esp
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	0f 89 b1 00 00 00    	jns    801077 <fork+0x191>
		    	panic("sys page map fault %e");
  800fc6:	83 ec 04             	sub    $0x4,%esp
  800fc9:	68 4c 26 80 00       	push   $0x80264c
  800fce:	6a 54                	push   $0x54
  800fd0:	68 1a 26 80 00       	push   $0x80261a
  800fd5:	e8 a4 f1 ff ff       	call   80017e <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800fda:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fe1:	f6 c2 02             	test   $0x2,%dl
  800fe4:	75 0c                	jne    800ff2 <fork+0x10c>
  800fe6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fed:	f6 c4 08             	test   $0x8,%ah
  800ff0:	74 5b                	je     80104d <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800ff2:	83 ec 0c             	sub    $0xc,%esp
  800ff5:	68 05 08 00 00       	push   $0x805
  800ffa:	56                   	push   %esi
  800ffb:	57                   	push   %edi
  800ffc:	56                   	push   %esi
  800ffd:	6a 00                	push   $0x0
  800fff:	e8 1e fc ff ff       	call   800c22 <sys_page_map>
		if (r < 0) {
  801004:	83 c4 20             	add    $0x20,%esp
  801007:	85 c0                	test   %eax,%eax
  801009:	79 14                	jns    80101f <fork+0x139>
		    	panic("sys page map fault %e");
  80100b:	83 ec 04             	sub    $0x4,%esp
  80100e:	68 4c 26 80 00       	push   $0x80264c
  801013:	6a 5b                	push   $0x5b
  801015:	68 1a 26 80 00       	push   $0x80261a
  80101a:	e8 5f f1 ff ff       	call   80017e <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  80101f:	83 ec 0c             	sub    $0xc,%esp
  801022:	68 05 08 00 00       	push   $0x805
  801027:	56                   	push   %esi
  801028:	6a 00                	push   $0x0
  80102a:	56                   	push   %esi
  80102b:	6a 00                	push   $0x0
  80102d:	e8 f0 fb ff ff       	call   800c22 <sys_page_map>
		if (r < 0) {
  801032:	83 c4 20             	add    $0x20,%esp
  801035:	85 c0                	test   %eax,%eax
  801037:	79 3e                	jns    801077 <fork+0x191>
		    	panic("sys page map fault %e");
  801039:	83 ec 04             	sub    $0x4,%esp
  80103c:	68 4c 26 80 00       	push   $0x80264c
  801041:	6a 5f                	push   $0x5f
  801043:	68 1a 26 80 00       	push   $0x80261a
  801048:	e8 31 f1 ff ff       	call   80017e <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80104d:	83 ec 0c             	sub    $0xc,%esp
  801050:	6a 05                	push   $0x5
  801052:	56                   	push   %esi
  801053:	57                   	push   %edi
  801054:	56                   	push   %esi
  801055:	6a 00                	push   $0x0
  801057:	e8 c6 fb ff ff       	call   800c22 <sys_page_map>
		if (r < 0) {
  80105c:	83 c4 20             	add    $0x20,%esp
  80105f:	85 c0                	test   %eax,%eax
  801061:	79 14                	jns    801077 <fork+0x191>
		    	panic("sys page map fault %e");
  801063:	83 ec 04             	sub    $0x4,%esp
  801066:	68 4c 26 80 00       	push   $0x80264c
  80106b:	6a 64                	push   $0x64
  80106d:	68 1a 26 80 00       	push   $0x80261a
  801072:	e8 07 f1 ff ff       	call   80017e <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801077:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80107d:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801083:	0f 85 de fe ff ff    	jne    800f67 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801089:	a1 04 40 80 00       	mov    0x804004,%eax
  80108e:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  801094:	83 ec 08             	sub    $0x8,%esp
  801097:	50                   	push   %eax
  801098:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80109b:	57                   	push   %edi
  80109c:	e8 89 fc ff ff       	call   800d2a <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8010a1:	83 c4 08             	add    $0x8,%esp
  8010a4:	6a 02                	push   $0x2
  8010a6:	57                   	push   %edi
  8010a7:	e8 fa fb ff ff       	call   800ca6 <sys_env_set_status>
	
	return envid;
  8010ac:	83 c4 10             	add    $0x10,%esp
  8010af:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8010b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b4:	5b                   	pop    %ebx
  8010b5:	5e                   	pop    %esi
  8010b6:	5f                   	pop    %edi
  8010b7:	5d                   	pop    %ebp
  8010b8:	c3                   	ret    

008010b9 <sfork>:

envid_t
sfork(void)
{
  8010b9:	55                   	push   %ebp
  8010ba:	89 e5                	mov    %esp,%ebp
	return 0;
}
  8010bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c1:	5d                   	pop    %ebp
  8010c2:	c3                   	ret    

008010c3 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8010c3:	55                   	push   %ebp
  8010c4:	89 e5                	mov    %esp,%ebp
  8010c6:	56                   	push   %esi
  8010c7:	53                   	push   %ebx
  8010c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  8010cb:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  8010d1:	83 ec 08             	sub    $0x8,%esp
  8010d4:	53                   	push   %ebx
  8010d5:	68 64 26 80 00       	push   $0x802664
  8010da:	e8 78 f1 ff ff       	call   800257 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8010df:	c7 04 24 44 01 80 00 	movl   $0x800144,(%esp)
  8010e6:	e8 e5 fc ff ff       	call   800dd0 <sys_thread_create>
  8010eb:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8010ed:	83 c4 08             	add    $0x8,%esp
  8010f0:	53                   	push   %ebx
  8010f1:	68 64 26 80 00       	push   $0x802664
  8010f6:	e8 5c f1 ff ff       	call   800257 <cprintf>
	return id;
}
  8010fb:	89 f0                	mov    %esi,%eax
  8010fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801100:	5b                   	pop    %ebx
  801101:	5e                   	pop    %esi
  801102:	5d                   	pop    %ebp
  801103:	c3                   	ret    

00801104 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
  801107:	56                   	push   %esi
  801108:	53                   	push   %ebx
  801109:	8b 75 08             	mov    0x8(%ebp),%esi
  80110c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80110f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801112:	85 c0                	test   %eax,%eax
  801114:	75 12                	jne    801128 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801116:	83 ec 0c             	sub    $0xc,%esp
  801119:	68 00 00 c0 ee       	push   $0xeec00000
  80111e:	e8 6c fc ff ff       	call   800d8f <sys_ipc_recv>
  801123:	83 c4 10             	add    $0x10,%esp
  801126:	eb 0c                	jmp    801134 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801128:	83 ec 0c             	sub    $0xc,%esp
  80112b:	50                   	push   %eax
  80112c:	e8 5e fc ff ff       	call   800d8f <sys_ipc_recv>
  801131:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801134:	85 f6                	test   %esi,%esi
  801136:	0f 95 c1             	setne  %cl
  801139:	85 db                	test   %ebx,%ebx
  80113b:	0f 95 c2             	setne  %dl
  80113e:	84 d1                	test   %dl,%cl
  801140:	74 09                	je     80114b <ipc_recv+0x47>
  801142:	89 c2                	mov    %eax,%edx
  801144:	c1 ea 1f             	shr    $0x1f,%edx
  801147:	84 d2                	test   %dl,%dl
  801149:	75 2d                	jne    801178 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80114b:	85 f6                	test   %esi,%esi
  80114d:	74 0d                	je     80115c <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80114f:	a1 04 40 80 00       	mov    0x804004,%eax
  801154:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  80115a:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80115c:	85 db                	test   %ebx,%ebx
  80115e:	74 0d                	je     80116d <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801160:	a1 04 40 80 00       	mov    0x804004,%eax
  801165:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  80116b:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80116d:	a1 04 40 80 00       	mov    0x804004,%eax
  801172:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  801178:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80117b:	5b                   	pop    %ebx
  80117c:	5e                   	pop    %esi
  80117d:	5d                   	pop    %ebp
  80117e:	c3                   	ret    

0080117f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
  801182:	57                   	push   %edi
  801183:	56                   	push   %esi
  801184:	53                   	push   %ebx
  801185:	83 ec 0c             	sub    $0xc,%esp
  801188:	8b 7d 08             	mov    0x8(%ebp),%edi
  80118b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80118e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801191:	85 db                	test   %ebx,%ebx
  801193:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801198:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80119b:	ff 75 14             	pushl  0x14(%ebp)
  80119e:	53                   	push   %ebx
  80119f:	56                   	push   %esi
  8011a0:	57                   	push   %edi
  8011a1:	e8 c6 fb ff ff       	call   800d6c <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8011a6:	89 c2                	mov    %eax,%edx
  8011a8:	c1 ea 1f             	shr    $0x1f,%edx
  8011ab:	83 c4 10             	add    $0x10,%esp
  8011ae:	84 d2                	test   %dl,%dl
  8011b0:	74 17                	je     8011c9 <ipc_send+0x4a>
  8011b2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011b5:	74 12                	je     8011c9 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8011b7:	50                   	push   %eax
  8011b8:	68 87 26 80 00       	push   $0x802687
  8011bd:	6a 47                	push   $0x47
  8011bf:	68 95 26 80 00       	push   $0x802695
  8011c4:	e8 b5 ef ff ff       	call   80017e <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8011c9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011cc:	75 07                	jne    8011d5 <ipc_send+0x56>
			sys_yield();
  8011ce:	e8 ed f9 ff ff       	call   800bc0 <sys_yield>
  8011d3:	eb c6                	jmp    80119b <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8011d5:	85 c0                	test   %eax,%eax
  8011d7:	75 c2                	jne    80119b <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8011d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011dc:	5b                   	pop    %ebx
  8011dd:	5e                   	pop    %esi
  8011de:	5f                   	pop    %edi
  8011df:	5d                   	pop    %ebp
  8011e0:	c3                   	ret    

008011e1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011e1:	55                   	push   %ebp
  8011e2:	89 e5                	mov    %esp,%ebp
  8011e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011e7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011ec:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  8011f2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011f8:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  8011fe:	39 ca                	cmp    %ecx,%edx
  801200:	75 10                	jne    801212 <ipc_find_env+0x31>
			return envs[i].env_id;
  801202:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  801208:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80120d:	8b 40 7c             	mov    0x7c(%eax),%eax
  801210:	eb 0f                	jmp    801221 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801212:	83 c0 01             	add    $0x1,%eax
  801215:	3d 00 04 00 00       	cmp    $0x400,%eax
  80121a:	75 d0                	jne    8011ec <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80121c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801221:	5d                   	pop    %ebp
  801222:	c3                   	ret    

00801223 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801223:	55                   	push   %ebp
  801224:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801226:	8b 45 08             	mov    0x8(%ebp),%eax
  801229:	05 00 00 00 30       	add    $0x30000000,%eax
  80122e:	c1 e8 0c             	shr    $0xc,%eax
}
  801231:	5d                   	pop    %ebp
  801232:	c3                   	ret    

00801233 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801233:	55                   	push   %ebp
  801234:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801236:	8b 45 08             	mov    0x8(%ebp),%eax
  801239:	05 00 00 00 30       	add    $0x30000000,%eax
  80123e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801243:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801248:	5d                   	pop    %ebp
  801249:	c3                   	ret    

0080124a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801250:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801255:	89 c2                	mov    %eax,%edx
  801257:	c1 ea 16             	shr    $0x16,%edx
  80125a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801261:	f6 c2 01             	test   $0x1,%dl
  801264:	74 11                	je     801277 <fd_alloc+0x2d>
  801266:	89 c2                	mov    %eax,%edx
  801268:	c1 ea 0c             	shr    $0xc,%edx
  80126b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801272:	f6 c2 01             	test   $0x1,%dl
  801275:	75 09                	jne    801280 <fd_alloc+0x36>
			*fd_store = fd;
  801277:	89 01                	mov    %eax,(%ecx)
			return 0;
  801279:	b8 00 00 00 00       	mov    $0x0,%eax
  80127e:	eb 17                	jmp    801297 <fd_alloc+0x4d>
  801280:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801285:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80128a:	75 c9                	jne    801255 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80128c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801292:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801297:	5d                   	pop    %ebp
  801298:	c3                   	ret    

00801299 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801299:	55                   	push   %ebp
  80129a:	89 e5                	mov    %esp,%ebp
  80129c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80129f:	83 f8 1f             	cmp    $0x1f,%eax
  8012a2:	77 36                	ja     8012da <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012a4:	c1 e0 0c             	shl    $0xc,%eax
  8012a7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012ac:	89 c2                	mov    %eax,%edx
  8012ae:	c1 ea 16             	shr    $0x16,%edx
  8012b1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012b8:	f6 c2 01             	test   $0x1,%dl
  8012bb:	74 24                	je     8012e1 <fd_lookup+0x48>
  8012bd:	89 c2                	mov    %eax,%edx
  8012bf:	c1 ea 0c             	shr    $0xc,%edx
  8012c2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012c9:	f6 c2 01             	test   $0x1,%dl
  8012cc:	74 1a                	je     8012e8 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012d1:	89 02                	mov    %eax,(%edx)
	return 0;
  8012d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d8:	eb 13                	jmp    8012ed <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012df:	eb 0c                	jmp    8012ed <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e6:	eb 05                	jmp    8012ed <fd_lookup+0x54>
  8012e8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012ed:	5d                   	pop    %ebp
  8012ee:	c3                   	ret    

008012ef <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012ef:	55                   	push   %ebp
  8012f0:	89 e5                	mov    %esp,%ebp
  8012f2:	83 ec 08             	sub    $0x8,%esp
  8012f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f8:	ba 20 27 80 00       	mov    $0x802720,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012fd:	eb 13                	jmp    801312 <dev_lookup+0x23>
  8012ff:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801302:	39 08                	cmp    %ecx,(%eax)
  801304:	75 0c                	jne    801312 <dev_lookup+0x23>
			*dev = devtab[i];
  801306:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801309:	89 01                	mov    %eax,(%ecx)
			return 0;
  80130b:	b8 00 00 00 00       	mov    $0x0,%eax
  801310:	eb 2e                	jmp    801340 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801312:	8b 02                	mov    (%edx),%eax
  801314:	85 c0                	test   %eax,%eax
  801316:	75 e7                	jne    8012ff <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801318:	a1 04 40 80 00       	mov    0x804004,%eax
  80131d:	8b 40 7c             	mov    0x7c(%eax),%eax
  801320:	83 ec 04             	sub    $0x4,%esp
  801323:	51                   	push   %ecx
  801324:	50                   	push   %eax
  801325:	68 a0 26 80 00       	push   $0x8026a0
  80132a:	e8 28 ef ff ff       	call   800257 <cprintf>
	*dev = 0;
  80132f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801332:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801338:	83 c4 10             	add    $0x10,%esp
  80133b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801340:	c9                   	leave  
  801341:	c3                   	ret    

00801342 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801342:	55                   	push   %ebp
  801343:	89 e5                	mov    %esp,%ebp
  801345:	56                   	push   %esi
  801346:	53                   	push   %ebx
  801347:	83 ec 10             	sub    $0x10,%esp
  80134a:	8b 75 08             	mov    0x8(%ebp),%esi
  80134d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801350:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801353:	50                   	push   %eax
  801354:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80135a:	c1 e8 0c             	shr    $0xc,%eax
  80135d:	50                   	push   %eax
  80135e:	e8 36 ff ff ff       	call   801299 <fd_lookup>
  801363:	83 c4 08             	add    $0x8,%esp
  801366:	85 c0                	test   %eax,%eax
  801368:	78 05                	js     80136f <fd_close+0x2d>
	    || fd != fd2)
  80136a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80136d:	74 0c                	je     80137b <fd_close+0x39>
		return (must_exist ? r : 0);
  80136f:	84 db                	test   %bl,%bl
  801371:	ba 00 00 00 00       	mov    $0x0,%edx
  801376:	0f 44 c2             	cmove  %edx,%eax
  801379:	eb 41                	jmp    8013bc <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80137b:	83 ec 08             	sub    $0x8,%esp
  80137e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801381:	50                   	push   %eax
  801382:	ff 36                	pushl  (%esi)
  801384:	e8 66 ff ff ff       	call   8012ef <dev_lookup>
  801389:	89 c3                	mov    %eax,%ebx
  80138b:	83 c4 10             	add    $0x10,%esp
  80138e:	85 c0                	test   %eax,%eax
  801390:	78 1a                	js     8013ac <fd_close+0x6a>
		if (dev->dev_close)
  801392:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801395:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801398:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80139d:	85 c0                	test   %eax,%eax
  80139f:	74 0b                	je     8013ac <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013a1:	83 ec 0c             	sub    $0xc,%esp
  8013a4:	56                   	push   %esi
  8013a5:	ff d0                	call   *%eax
  8013a7:	89 c3                	mov    %eax,%ebx
  8013a9:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013ac:	83 ec 08             	sub    $0x8,%esp
  8013af:	56                   	push   %esi
  8013b0:	6a 00                	push   $0x0
  8013b2:	e8 ad f8 ff ff       	call   800c64 <sys_page_unmap>
	return r;
  8013b7:	83 c4 10             	add    $0x10,%esp
  8013ba:	89 d8                	mov    %ebx,%eax
}
  8013bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013bf:	5b                   	pop    %ebx
  8013c0:	5e                   	pop    %esi
  8013c1:	5d                   	pop    %ebp
  8013c2:	c3                   	ret    

008013c3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013c3:	55                   	push   %ebp
  8013c4:	89 e5                	mov    %esp,%ebp
  8013c6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013cc:	50                   	push   %eax
  8013cd:	ff 75 08             	pushl  0x8(%ebp)
  8013d0:	e8 c4 fe ff ff       	call   801299 <fd_lookup>
  8013d5:	83 c4 08             	add    $0x8,%esp
  8013d8:	85 c0                	test   %eax,%eax
  8013da:	78 10                	js     8013ec <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013dc:	83 ec 08             	sub    $0x8,%esp
  8013df:	6a 01                	push   $0x1
  8013e1:	ff 75 f4             	pushl  -0xc(%ebp)
  8013e4:	e8 59 ff ff ff       	call   801342 <fd_close>
  8013e9:	83 c4 10             	add    $0x10,%esp
}
  8013ec:	c9                   	leave  
  8013ed:	c3                   	ret    

008013ee <close_all>:

void
close_all(void)
{
  8013ee:	55                   	push   %ebp
  8013ef:	89 e5                	mov    %esp,%ebp
  8013f1:	53                   	push   %ebx
  8013f2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013f5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013fa:	83 ec 0c             	sub    $0xc,%esp
  8013fd:	53                   	push   %ebx
  8013fe:	e8 c0 ff ff ff       	call   8013c3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801403:	83 c3 01             	add    $0x1,%ebx
  801406:	83 c4 10             	add    $0x10,%esp
  801409:	83 fb 20             	cmp    $0x20,%ebx
  80140c:	75 ec                	jne    8013fa <close_all+0xc>
		close(i);
}
  80140e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801411:	c9                   	leave  
  801412:	c3                   	ret    

00801413 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801413:	55                   	push   %ebp
  801414:	89 e5                	mov    %esp,%ebp
  801416:	57                   	push   %edi
  801417:	56                   	push   %esi
  801418:	53                   	push   %ebx
  801419:	83 ec 2c             	sub    $0x2c,%esp
  80141c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80141f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801422:	50                   	push   %eax
  801423:	ff 75 08             	pushl  0x8(%ebp)
  801426:	e8 6e fe ff ff       	call   801299 <fd_lookup>
  80142b:	83 c4 08             	add    $0x8,%esp
  80142e:	85 c0                	test   %eax,%eax
  801430:	0f 88 c1 00 00 00    	js     8014f7 <dup+0xe4>
		return r;
	close(newfdnum);
  801436:	83 ec 0c             	sub    $0xc,%esp
  801439:	56                   	push   %esi
  80143a:	e8 84 ff ff ff       	call   8013c3 <close>

	newfd = INDEX2FD(newfdnum);
  80143f:	89 f3                	mov    %esi,%ebx
  801441:	c1 e3 0c             	shl    $0xc,%ebx
  801444:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80144a:	83 c4 04             	add    $0x4,%esp
  80144d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801450:	e8 de fd ff ff       	call   801233 <fd2data>
  801455:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801457:	89 1c 24             	mov    %ebx,(%esp)
  80145a:	e8 d4 fd ff ff       	call   801233 <fd2data>
  80145f:	83 c4 10             	add    $0x10,%esp
  801462:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801465:	89 f8                	mov    %edi,%eax
  801467:	c1 e8 16             	shr    $0x16,%eax
  80146a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801471:	a8 01                	test   $0x1,%al
  801473:	74 37                	je     8014ac <dup+0x99>
  801475:	89 f8                	mov    %edi,%eax
  801477:	c1 e8 0c             	shr    $0xc,%eax
  80147a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801481:	f6 c2 01             	test   $0x1,%dl
  801484:	74 26                	je     8014ac <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801486:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80148d:	83 ec 0c             	sub    $0xc,%esp
  801490:	25 07 0e 00 00       	and    $0xe07,%eax
  801495:	50                   	push   %eax
  801496:	ff 75 d4             	pushl  -0x2c(%ebp)
  801499:	6a 00                	push   $0x0
  80149b:	57                   	push   %edi
  80149c:	6a 00                	push   $0x0
  80149e:	e8 7f f7 ff ff       	call   800c22 <sys_page_map>
  8014a3:	89 c7                	mov    %eax,%edi
  8014a5:	83 c4 20             	add    $0x20,%esp
  8014a8:	85 c0                	test   %eax,%eax
  8014aa:	78 2e                	js     8014da <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014af:	89 d0                	mov    %edx,%eax
  8014b1:	c1 e8 0c             	shr    $0xc,%eax
  8014b4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014bb:	83 ec 0c             	sub    $0xc,%esp
  8014be:	25 07 0e 00 00       	and    $0xe07,%eax
  8014c3:	50                   	push   %eax
  8014c4:	53                   	push   %ebx
  8014c5:	6a 00                	push   $0x0
  8014c7:	52                   	push   %edx
  8014c8:	6a 00                	push   $0x0
  8014ca:	e8 53 f7 ff ff       	call   800c22 <sys_page_map>
  8014cf:	89 c7                	mov    %eax,%edi
  8014d1:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014d4:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014d6:	85 ff                	test   %edi,%edi
  8014d8:	79 1d                	jns    8014f7 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014da:	83 ec 08             	sub    $0x8,%esp
  8014dd:	53                   	push   %ebx
  8014de:	6a 00                	push   $0x0
  8014e0:	e8 7f f7 ff ff       	call   800c64 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014e5:	83 c4 08             	add    $0x8,%esp
  8014e8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014eb:	6a 00                	push   $0x0
  8014ed:	e8 72 f7 ff ff       	call   800c64 <sys_page_unmap>
	return r;
  8014f2:	83 c4 10             	add    $0x10,%esp
  8014f5:	89 f8                	mov    %edi,%eax
}
  8014f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014fa:	5b                   	pop    %ebx
  8014fb:	5e                   	pop    %esi
  8014fc:	5f                   	pop    %edi
  8014fd:	5d                   	pop    %ebp
  8014fe:	c3                   	ret    

008014ff <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014ff:	55                   	push   %ebp
  801500:	89 e5                	mov    %esp,%ebp
  801502:	53                   	push   %ebx
  801503:	83 ec 14             	sub    $0x14,%esp
  801506:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801509:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80150c:	50                   	push   %eax
  80150d:	53                   	push   %ebx
  80150e:	e8 86 fd ff ff       	call   801299 <fd_lookup>
  801513:	83 c4 08             	add    $0x8,%esp
  801516:	89 c2                	mov    %eax,%edx
  801518:	85 c0                	test   %eax,%eax
  80151a:	78 6d                	js     801589 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151c:	83 ec 08             	sub    $0x8,%esp
  80151f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801522:	50                   	push   %eax
  801523:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801526:	ff 30                	pushl  (%eax)
  801528:	e8 c2 fd ff ff       	call   8012ef <dev_lookup>
  80152d:	83 c4 10             	add    $0x10,%esp
  801530:	85 c0                	test   %eax,%eax
  801532:	78 4c                	js     801580 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801534:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801537:	8b 42 08             	mov    0x8(%edx),%eax
  80153a:	83 e0 03             	and    $0x3,%eax
  80153d:	83 f8 01             	cmp    $0x1,%eax
  801540:	75 21                	jne    801563 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801542:	a1 04 40 80 00       	mov    0x804004,%eax
  801547:	8b 40 7c             	mov    0x7c(%eax),%eax
  80154a:	83 ec 04             	sub    $0x4,%esp
  80154d:	53                   	push   %ebx
  80154e:	50                   	push   %eax
  80154f:	68 e4 26 80 00       	push   $0x8026e4
  801554:	e8 fe ec ff ff       	call   800257 <cprintf>
		return -E_INVAL;
  801559:	83 c4 10             	add    $0x10,%esp
  80155c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801561:	eb 26                	jmp    801589 <read+0x8a>
	}
	if (!dev->dev_read)
  801563:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801566:	8b 40 08             	mov    0x8(%eax),%eax
  801569:	85 c0                	test   %eax,%eax
  80156b:	74 17                	je     801584 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80156d:	83 ec 04             	sub    $0x4,%esp
  801570:	ff 75 10             	pushl  0x10(%ebp)
  801573:	ff 75 0c             	pushl  0xc(%ebp)
  801576:	52                   	push   %edx
  801577:	ff d0                	call   *%eax
  801579:	89 c2                	mov    %eax,%edx
  80157b:	83 c4 10             	add    $0x10,%esp
  80157e:	eb 09                	jmp    801589 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801580:	89 c2                	mov    %eax,%edx
  801582:	eb 05                	jmp    801589 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801584:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801589:	89 d0                	mov    %edx,%eax
  80158b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80158e:	c9                   	leave  
  80158f:	c3                   	ret    

00801590 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	57                   	push   %edi
  801594:	56                   	push   %esi
  801595:	53                   	push   %ebx
  801596:	83 ec 0c             	sub    $0xc,%esp
  801599:	8b 7d 08             	mov    0x8(%ebp),%edi
  80159c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80159f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015a4:	eb 21                	jmp    8015c7 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015a6:	83 ec 04             	sub    $0x4,%esp
  8015a9:	89 f0                	mov    %esi,%eax
  8015ab:	29 d8                	sub    %ebx,%eax
  8015ad:	50                   	push   %eax
  8015ae:	89 d8                	mov    %ebx,%eax
  8015b0:	03 45 0c             	add    0xc(%ebp),%eax
  8015b3:	50                   	push   %eax
  8015b4:	57                   	push   %edi
  8015b5:	e8 45 ff ff ff       	call   8014ff <read>
		if (m < 0)
  8015ba:	83 c4 10             	add    $0x10,%esp
  8015bd:	85 c0                	test   %eax,%eax
  8015bf:	78 10                	js     8015d1 <readn+0x41>
			return m;
		if (m == 0)
  8015c1:	85 c0                	test   %eax,%eax
  8015c3:	74 0a                	je     8015cf <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015c5:	01 c3                	add    %eax,%ebx
  8015c7:	39 f3                	cmp    %esi,%ebx
  8015c9:	72 db                	jb     8015a6 <readn+0x16>
  8015cb:	89 d8                	mov    %ebx,%eax
  8015cd:	eb 02                	jmp    8015d1 <readn+0x41>
  8015cf:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d4:	5b                   	pop    %ebx
  8015d5:	5e                   	pop    %esi
  8015d6:	5f                   	pop    %edi
  8015d7:	5d                   	pop    %ebp
  8015d8:	c3                   	ret    

008015d9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015d9:	55                   	push   %ebp
  8015da:	89 e5                	mov    %esp,%ebp
  8015dc:	53                   	push   %ebx
  8015dd:	83 ec 14             	sub    $0x14,%esp
  8015e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e6:	50                   	push   %eax
  8015e7:	53                   	push   %ebx
  8015e8:	e8 ac fc ff ff       	call   801299 <fd_lookup>
  8015ed:	83 c4 08             	add    $0x8,%esp
  8015f0:	89 c2                	mov    %eax,%edx
  8015f2:	85 c0                	test   %eax,%eax
  8015f4:	78 68                	js     80165e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f6:	83 ec 08             	sub    $0x8,%esp
  8015f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fc:	50                   	push   %eax
  8015fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801600:	ff 30                	pushl  (%eax)
  801602:	e8 e8 fc ff ff       	call   8012ef <dev_lookup>
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	85 c0                	test   %eax,%eax
  80160c:	78 47                	js     801655 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80160e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801611:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801615:	75 21                	jne    801638 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801617:	a1 04 40 80 00       	mov    0x804004,%eax
  80161c:	8b 40 7c             	mov    0x7c(%eax),%eax
  80161f:	83 ec 04             	sub    $0x4,%esp
  801622:	53                   	push   %ebx
  801623:	50                   	push   %eax
  801624:	68 00 27 80 00       	push   $0x802700
  801629:	e8 29 ec ff ff       	call   800257 <cprintf>
		return -E_INVAL;
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801636:	eb 26                	jmp    80165e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801638:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80163b:	8b 52 0c             	mov    0xc(%edx),%edx
  80163e:	85 d2                	test   %edx,%edx
  801640:	74 17                	je     801659 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801642:	83 ec 04             	sub    $0x4,%esp
  801645:	ff 75 10             	pushl  0x10(%ebp)
  801648:	ff 75 0c             	pushl  0xc(%ebp)
  80164b:	50                   	push   %eax
  80164c:	ff d2                	call   *%edx
  80164e:	89 c2                	mov    %eax,%edx
  801650:	83 c4 10             	add    $0x10,%esp
  801653:	eb 09                	jmp    80165e <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801655:	89 c2                	mov    %eax,%edx
  801657:	eb 05                	jmp    80165e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801659:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80165e:	89 d0                	mov    %edx,%eax
  801660:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801663:	c9                   	leave  
  801664:	c3                   	ret    

00801665 <seek>:

int
seek(int fdnum, off_t offset)
{
  801665:	55                   	push   %ebp
  801666:	89 e5                	mov    %esp,%ebp
  801668:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80166b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80166e:	50                   	push   %eax
  80166f:	ff 75 08             	pushl  0x8(%ebp)
  801672:	e8 22 fc ff ff       	call   801299 <fd_lookup>
  801677:	83 c4 08             	add    $0x8,%esp
  80167a:	85 c0                	test   %eax,%eax
  80167c:	78 0e                	js     80168c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80167e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801681:	8b 55 0c             	mov    0xc(%ebp),%edx
  801684:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801687:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80168c:	c9                   	leave  
  80168d:	c3                   	ret    

0080168e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80168e:	55                   	push   %ebp
  80168f:	89 e5                	mov    %esp,%ebp
  801691:	53                   	push   %ebx
  801692:	83 ec 14             	sub    $0x14,%esp
  801695:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801698:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80169b:	50                   	push   %eax
  80169c:	53                   	push   %ebx
  80169d:	e8 f7 fb ff ff       	call   801299 <fd_lookup>
  8016a2:	83 c4 08             	add    $0x8,%esp
  8016a5:	89 c2                	mov    %eax,%edx
  8016a7:	85 c0                	test   %eax,%eax
  8016a9:	78 65                	js     801710 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ab:	83 ec 08             	sub    $0x8,%esp
  8016ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b1:	50                   	push   %eax
  8016b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b5:	ff 30                	pushl  (%eax)
  8016b7:	e8 33 fc ff ff       	call   8012ef <dev_lookup>
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	85 c0                	test   %eax,%eax
  8016c1:	78 44                	js     801707 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016ca:	75 21                	jne    8016ed <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016cc:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016d1:	8b 40 7c             	mov    0x7c(%eax),%eax
  8016d4:	83 ec 04             	sub    $0x4,%esp
  8016d7:	53                   	push   %ebx
  8016d8:	50                   	push   %eax
  8016d9:	68 c0 26 80 00       	push   $0x8026c0
  8016de:	e8 74 eb ff ff       	call   800257 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016e3:	83 c4 10             	add    $0x10,%esp
  8016e6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016eb:	eb 23                	jmp    801710 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f0:	8b 52 18             	mov    0x18(%edx),%edx
  8016f3:	85 d2                	test   %edx,%edx
  8016f5:	74 14                	je     80170b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016f7:	83 ec 08             	sub    $0x8,%esp
  8016fa:	ff 75 0c             	pushl  0xc(%ebp)
  8016fd:	50                   	push   %eax
  8016fe:	ff d2                	call   *%edx
  801700:	89 c2                	mov    %eax,%edx
  801702:	83 c4 10             	add    $0x10,%esp
  801705:	eb 09                	jmp    801710 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801707:	89 c2                	mov    %eax,%edx
  801709:	eb 05                	jmp    801710 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80170b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801710:	89 d0                	mov    %edx,%eax
  801712:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801715:	c9                   	leave  
  801716:	c3                   	ret    

00801717 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	53                   	push   %ebx
  80171b:	83 ec 14             	sub    $0x14,%esp
  80171e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801721:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801724:	50                   	push   %eax
  801725:	ff 75 08             	pushl  0x8(%ebp)
  801728:	e8 6c fb ff ff       	call   801299 <fd_lookup>
  80172d:	83 c4 08             	add    $0x8,%esp
  801730:	89 c2                	mov    %eax,%edx
  801732:	85 c0                	test   %eax,%eax
  801734:	78 58                	js     80178e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801736:	83 ec 08             	sub    $0x8,%esp
  801739:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80173c:	50                   	push   %eax
  80173d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801740:	ff 30                	pushl  (%eax)
  801742:	e8 a8 fb ff ff       	call   8012ef <dev_lookup>
  801747:	83 c4 10             	add    $0x10,%esp
  80174a:	85 c0                	test   %eax,%eax
  80174c:	78 37                	js     801785 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80174e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801751:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801755:	74 32                	je     801789 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801757:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80175a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801761:	00 00 00 
	stat->st_isdir = 0;
  801764:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80176b:	00 00 00 
	stat->st_dev = dev;
  80176e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801774:	83 ec 08             	sub    $0x8,%esp
  801777:	53                   	push   %ebx
  801778:	ff 75 f0             	pushl  -0x10(%ebp)
  80177b:	ff 50 14             	call   *0x14(%eax)
  80177e:	89 c2                	mov    %eax,%edx
  801780:	83 c4 10             	add    $0x10,%esp
  801783:	eb 09                	jmp    80178e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801785:	89 c2                	mov    %eax,%edx
  801787:	eb 05                	jmp    80178e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801789:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80178e:	89 d0                	mov    %edx,%eax
  801790:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801793:	c9                   	leave  
  801794:	c3                   	ret    

00801795 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	56                   	push   %esi
  801799:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80179a:	83 ec 08             	sub    $0x8,%esp
  80179d:	6a 00                	push   $0x0
  80179f:	ff 75 08             	pushl  0x8(%ebp)
  8017a2:	e8 e3 01 00 00       	call   80198a <open>
  8017a7:	89 c3                	mov    %eax,%ebx
  8017a9:	83 c4 10             	add    $0x10,%esp
  8017ac:	85 c0                	test   %eax,%eax
  8017ae:	78 1b                	js     8017cb <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017b0:	83 ec 08             	sub    $0x8,%esp
  8017b3:	ff 75 0c             	pushl  0xc(%ebp)
  8017b6:	50                   	push   %eax
  8017b7:	e8 5b ff ff ff       	call   801717 <fstat>
  8017bc:	89 c6                	mov    %eax,%esi
	close(fd);
  8017be:	89 1c 24             	mov    %ebx,(%esp)
  8017c1:	e8 fd fb ff ff       	call   8013c3 <close>
	return r;
  8017c6:	83 c4 10             	add    $0x10,%esp
  8017c9:	89 f0                	mov    %esi,%eax
}
  8017cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ce:	5b                   	pop    %ebx
  8017cf:	5e                   	pop    %esi
  8017d0:	5d                   	pop    %ebp
  8017d1:	c3                   	ret    

008017d2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017d2:	55                   	push   %ebp
  8017d3:	89 e5                	mov    %esp,%ebp
  8017d5:	56                   	push   %esi
  8017d6:	53                   	push   %ebx
  8017d7:	89 c6                	mov    %eax,%esi
  8017d9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017db:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017e2:	75 12                	jne    8017f6 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017e4:	83 ec 0c             	sub    $0xc,%esp
  8017e7:	6a 01                	push   $0x1
  8017e9:	e8 f3 f9 ff ff       	call   8011e1 <ipc_find_env>
  8017ee:	a3 00 40 80 00       	mov    %eax,0x804000
  8017f3:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017f6:	6a 07                	push   $0x7
  8017f8:	68 00 50 80 00       	push   $0x805000
  8017fd:	56                   	push   %esi
  8017fe:	ff 35 00 40 80 00    	pushl  0x804000
  801804:	e8 76 f9 ff ff       	call   80117f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801809:	83 c4 0c             	add    $0xc,%esp
  80180c:	6a 00                	push   $0x0
  80180e:	53                   	push   %ebx
  80180f:	6a 00                	push   $0x0
  801811:	e8 ee f8 ff ff       	call   801104 <ipc_recv>
}
  801816:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801819:	5b                   	pop    %ebx
  80181a:	5e                   	pop    %esi
  80181b:	5d                   	pop    %ebp
  80181c:	c3                   	ret    

0080181d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80181d:	55                   	push   %ebp
  80181e:	89 e5                	mov    %esp,%ebp
  801820:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801823:	8b 45 08             	mov    0x8(%ebp),%eax
  801826:	8b 40 0c             	mov    0xc(%eax),%eax
  801829:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80182e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801831:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801836:	ba 00 00 00 00       	mov    $0x0,%edx
  80183b:	b8 02 00 00 00       	mov    $0x2,%eax
  801840:	e8 8d ff ff ff       	call   8017d2 <fsipc>
}
  801845:	c9                   	leave  
  801846:	c3                   	ret    

00801847 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801847:	55                   	push   %ebp
  801848:	89 e5                	mov    %esp,%ebp
  80184a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80184d:	8b 45 08             	mov    0x8(%ebp),%eax
  801850:	8b 40 0c             	mov    0xc(%eax),%eax
  801853:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801858:	ba 00 00 00 00       	mov    $0x0,%edx
  80185d:	b8 06 00 00 00       	mov    $0x6,%eax
  801862:	e8 6b ff ff ff       	call   8017d2 <fsipc>
}
  801867:	c9                   	leave  
  801868:	c3                   	ret    

00801869 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801869:	55                   	push   %ebp
  80186a:	89 e5                	mov    %esp,%ebp
  80186c:	53                   	push   %ebx
  80186d:	83 ec 04             	sub    $0x4,%esp
  801870:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801873:	8b 45 08             	mov    0x8(%ebp),%eax
  801876:	8b 40 0c             	mov    0xc(%eax),%eax
  801879:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80187e:	ba 00 00 00 00       	mov    $0x0,%edx
  801883:	b8 05 00 00 00       	mov    $0x5,%eax
  801888:	e8 45 ff ff ff       	call   8017d2 <fsipc>
  80188d:	85 c0                	test   %eax,%eax
  80188f:	78 2c                	js     8018bd <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801891:	83 ec 08             	sub    $0x8,%esp
  801894:	68 00 50 80 00       	push   $0x805000
  801899:	53                   	push   %ebx
  80189a:	e8 3d ef ff ff       	call   8007dc <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80189f:	a1 80 50 80 00       	mov    0x805080,%eax
  8018a4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018aa:	a1 84 50 80 00       	mov    0x805084,%eax
  8018af:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018b5:	83 c4 10             	add    $0x10,%esp
  8018b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c0:	c9                   	leave  
  8018c1:	c3                   	ret    

008018c2 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018c2:	55                   	push   %ebp
  8018c3:	89 e5                	mov    %esp,%ebp
  8018c5:	83 ec 0c             	sub    $0xc,%esp
  8018c8:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8018ce:	8b 52 0c             	mov    0xc(%edx),%edx
  8018d1:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8018d7:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018dc:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018e1:	0f 47 c2             	cmova  %edx,%eax
  8018e4:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8018e9:	50                   	push   %eax
  8018ea:	ff 75 0c             	pushl  0xc(%ebp)
  8018ed:	68 08 50 80 00       	push   $0x805008
  8018f2:	e8 77 f0 ff ff       	call   80096e <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8018f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018fc:	b8 04 00 00 00       	mov    $0x4,%eax
  801901:	e8 cc fe ff ff       	call   8017d2 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801906:	c9                   	leave  
  801907:	c3                   	ret    

00801908 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801908:	55                   	push   %ebp
  801909:	89 e5                	mov    %esp,%ebp
  80190b:	56                   	push   %esi
  80190c:	53                   	push   %ebx
  80190d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801910:	8b 45 08             	mov    0x8(%ebp),%eax
  801913:	8b 40 0c             	mov    0xc(%eax),%eax
  801916:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80191b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801921:	ba 00 00 00 00       	mov    $0x0,%edx
  801926:	b8 03 00 00 00       	mov    $0x3,%eax
  80192b:	e8 a2 fe ff ff       	call   8017d2 <fsipc>
  801930:	89 c3                	mov    %eax,%ebx
  801932:	85 c0                	test   %eax,%eax
  801934:	78 4b                	js     801981 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801936:	39 c6                	cmp    %eax,%esi
  801938:	73 16                	jae    801950 <devfile_read+0x48>
  80193a:	68 30 27 80 00       	push   $0x802730
  80193f:	68 37 27 80 00       	push   $0x802737
  801944:	6a 7c                	push   $0x7c
  801946:	68 4c 27 80 00       	push   $0x80274c
  80194b:	e8 2e e8 ff ff       	call   80017e <_panic>
	assert(r <= PGSIZE);
  801950:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801955:	7e 16                	jle    80196d <devfile_read+0x65>
  801957:	68 57 27 80 00       	push   $0x802757
  80195c:	68 37 27 80 00       	push   $0x802737
  801961:	6a 7d                	push   $0x7d
  801963:	68 4c 27 80 00       	push   $0x80274c
  801968:	e8 11 e8 ff ff       	call   80017e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80196d:	83 ec 04             	sub    $0x4,%esp
  801970:	50                   	push   %eax
  801971:	68 00 50 80 00       	push   $0x805000
  801976:	ff 75 0c             	pushl  0xc(%ebp)
  801979:	e8 f0 ef ff ff       	call   80096e <memmove>
	return r;
  80197e:	83 c4 10             	add    $0x10,%esp
}
  801981:	89 d8                	mov    %ebx,%eax
  801983:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801986:	5b                   	pop    %ebx
  801987:	5e                   	pop    %esi
  801988:	5d                   	pop    %ebp
  801989:	c3                   	ret    

0080198a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	53                   	push   %ebx
  80198e:	83 ec 20             	sub    $0x20,%esp
  801991:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801994:	53                   	push   %ebx
  801995:	e8 09 ee ff ff       	call   8007a3 <strlen>
  80199a:	83 c4 10             	add    $0x10,%esp
  80199d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019a2:	7f 67                	jg     801a0b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019a4:	83 ec 0c             	sub    $0xc,%esp
  8019a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019aa:	50                   	push   %eax
  8019ab:	e8 9a f8 ff ff       	call   80124a <fd_alloc>
  8019b0:	83 c4 10             	add    $0x10,%esp
		return r;
  8019b3:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019b5:	85 c0                	test   %eax,%eax
  8019b7:	78 57                	js     801a10 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019b9:	83 ec 08             	sub    $0x8,%esp
  8019bc:	53                   	push   %ebx
  8019bd:	68 00 50 80 00       	push   $0x805000
  8019c2:	e8 15 ee ff ff       	call   8007dc <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ca:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8019d7:	e8 f6 fd ff ff       	call   8017d2 <fsipc>
  8019dc:	89 c3                	mov    %eax,%ebx
  8019de:	83 c4 10             	add    $0x10,%esp
  8019e1:	85 c0                	test   %eax,%eax
  8019e3:	79 14                	jns    8019f9 <open+0x6f>
		fd_close(fd, 0);
  8019e5:	83 ec 08             	sub    $0x8,%esp
  8019e8:	6a 00                	push   $0x0
  8019ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ed:	e8 50 f9 ff ff       	call   801342 <fd_close>
		return r;
  8019f2:	83 c4 10             	add    $0x10,%esp
  8019f5:	89 da                	mov    %ebx,%edx
  8019f7:	eb 17                	jmp    801a10 <open+0x86>
	}

	return fd2num(fd);
  8019f9:	83 ec 0c             	sub    $0xc,%esp
  8019fc:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ff:	e8 1f f8 ff ff       	call   801223 <fd2num>
  801a04:	89 c2                	mov    %eax,%edx
  801a06:	83 c4 10             	add    $0x10,%esp
  801a09:	eb 05                	jmp    801a10 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a0b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a10:	89 d0                	mov    %edx,%eax
  801a12:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a15:	c9                   	leave  
  801a16:	c3                   	ret    

00801a17 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a17:	55                   	push   %ebp
  801a18:	89 e5                	mov    %esp,%ebp
  801a1a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a1d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a22:	b8 08 00 00 00       	mov    $0x8,%eax
  801a27:	e8 a6 fd ff ff       	call   8017d2 <fsipc>
}
  801a2c:	c9                   	leave  
  801a2d:	c3                   	ret    

00801a2e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a2e:	55                   	push   %ebp
  801a2f:	89 e5                	mov    %esp,%ebp
  801a31:	56                   	push   %esi
  801a32:	53                   	push   %ebx
  801a33:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a36:	83 ec 0c             	sub    $0xc,%esp
  801a39:	ff 75 08             	pushl  0x8(%ebp)
  801a3c:	e8 f2 f7 ff ff       	call   801233 <fd2data>
  801a41:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a43:	83 c4 08             	add    $0x8,%esp
  801a46:	68 63 27 80 00       	push   $0x802763
  801a4b:	53                   	push   %ebx
  801a4c:	e8 8b ed ff ff       	call   8007dc <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a51:	8b 46 04             	mov    0x4(%esi),%eax
  801a54:	2b 06                	sub    (%esi),%eax
  801a56:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a5c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a63:	00 00 00 
	stat->st_dev = &devpipe;
  801a66:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a6d:	30 80 00 
	return 0;
}
  801a70:	b8 00 00 00 00       	mov    $0x0,%eax
  801a75:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a78:	5b                   	pop    %ebx
  801a79:	5e                   	pop    %esi
  801a7a:	5d                   	pop    %ebp
  801a7b:	c3                   	ret    

00801a7c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a7c:	55                   	push   %ebp
  801a7d:	89 e5                	mov    %esp,%ebp
  801a7f:	53                   	push   %ebx
  801a80:	83 ec 0c             	sub    $0xc,%esp
  801a83:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a86:	53                   	push   %ebx
  801a87:	6a 00                	push   $0x0
  801a89:	e8 d6 f1 ff ff       	call   800c64 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a8e:	89 1c 24             	mov    %ebx,(%esp)
  801a91:	e8 9d f7 ff ff       	call   801233 <fd2data>
  801a96:	83 c4 08             	add    $0x8,%esp
  801a99:	50                   	push   %eax
  801a9a:	6a 00                	push   $0x0
  801a9c:	e8 c3 f1 ff ff       	call   800c64 <sys_page_unmap>
}
  801aa1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aa4:	c9                   	leave  
  801aa5:	c3                   	ret    

00801aa6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801aa6:	55                   	push   %ebp
  801aa7:	89 e5                	mov    %esp,%ebp
  801aa9:	57                   	push   %edi
  801aaa:	56                   	push   %esi
  801aab:	53                   	push   %ebx
  801aac:	83 ec 1c             	sub    $0x1c,%esp
  801aaf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ab2:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ab4:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab9:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801abf:	83 ec 0c             	sub    $0xc,%esp
  801ac2:	ff 75 e0             	pushl  -0x20(%ebp)
  801ac5:	e8 db 04 00 00       	call   801fa5 <pageref>
  801aca:	89 c3                	mov    %eax,%ebx
  801acc:	89 3c 24             	mov    %edi,(%esp)
  801acf:	e8 d1 04 00 00       	call   801fa5 <pageref>
  801ad4:	83 c4 10             	add    $0x10,%esp
  801ad7:	39 c3                	cmp    %eax,%ebx
  801ad9:	0f 94 c1             	sete   %cl
  801adc:	0f b6 c9             	movzbl %cl,%ecx
  801adf:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ae2:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ae8:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  801aee:	39 ce                	cmp    %ecx,%esi
  801af0:	74 1e                	je     801b10 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801af2:	39 c3                	cmp    %eax,%ebx
  801af4:	75 be                	jne    801ab4 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801af6:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  801afc:	ff 75 e4             	pushl  -0x1c(%ebp)
  801aff:	50                   	push   %eax
  801b00:	56                   	push   %esi
  801b01:	68 6a 27 80 00       	push   $0x80276a
  801b06:	e8 4c e7 ff ff       	call   800257 <cprintf>
  801b0b:	83 c4 10             	add    $0x10,%esp
  801b0e:	eb a4                	jmp    801ab4 <_pipeisclosed+0xe>
	}
}
  801b10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b16:	5b                   	pop    %ebx
  801b17:	5e                   	pop    %esi
  801b18:	5f                   	pop    %edi
  801b19:	5d                   	pop    %ebp
  801b1a:	c3                   	ret    

00801b1b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b1b:	55                   	push   %ebp
  801b1c:	89 e5                	mov    %esp,%ebp
  801b1e:	57                   	push   %edi
  801b1f:	56                   	push   %esi
  801b20:	53                   	push   %ebx
  801b21:	83 ec 28             	sub    $0x28,%esp
  801b24:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b27:	56                   	push   %esi
  801b28:	e8 06 f7 ff ff       	call   801233 <fd2data>
  801b2d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b2f:	83 c4 10             	add    $0x10,%esp
  801b32:	bf 00 00 00 00       	mov    $0x0,%edi
  801b37:	eb 4b                	jmp    801b84 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b39:	89 da                	mov    %ebx,%edx
  801b3b:	89 f0                	mov    %esi,%eax
  801b3d:	e8 64 ff ff ff       	call   801aa6 <_pipeisclosed>
  801b42:	85 c0                	test   %eax,%eax
  801b44:	75 48                	jne    801b8e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b46:	e8 75 f0 ff ff       	call   800bc0 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b4b:	8b 43 04             	mov    0x4(%ebx),%eax
  801b4e:	8b 0b                	mov    (%ebx),%ecx
  801b50:	8d 51 20             	lea    0x20(%ecx),%edx
  801b53:	39 d0                	cmp    %edx,%eax
  801b55:	73 e2                	jae    801b39 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b5a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b5e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b61:	89 c2                	mov    %eax,%edx
  801b63:	c1 fa 1f             	sar    $0x1f,%edx
  801b66:	89 d1                	mov    %edx,%ecx
  801b68:	c1 e9 1b             	shr    $0x1b,%ecx
  801b6b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b6e:	83 e2 1f             	and    $0x1f,%edx
  801b71:	29 ca                	sub    %ecx,%edx
  801b73:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b77:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b7b:	83 c0 01             	add    $0x1,%eax
  801b7e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b81:	83 c7 01             	add    $0x1,%edi
  801b84:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b87:	75 c2                	jne    801b4b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b89:	8b 45 10             	mov    0x10(%ebp),%eax
  801b8c:	eb 05                	jmp    801b93 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b8e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b96:	5b                   	pop    %ebx
  801b97:	5e                   	pop    %esi
  801b98:	5f                   	pop    %edi
  801b99:	5d                   	pop    %ebp
  801b9a:	c3                   	ret    

00801b9b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b9b:	55                   	push   %ebp
  801b9c:	89 e5                	mov    %esp,%ebp
  801b9e:	57                   	push   %edi
  801b9f:	56                   	push   %esi
  801ba0:	53                   	push   %ebx
  801ba1:	83 ec 18             	sub    $0x18,%esp
  801ba4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ba7:	57                   	push   %edi
  801ba8:	e8 86 f6 ff ff       	call   801233 <fd2data>
  801bad:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801baf:	83 c4 10             	add    $0x10,%esp
  801bb2:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bb7:	eb 3d                	jmp    801bf6 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bb9:	85 db                	test   %ebx,%ebx
  801bbb:	74 04                	je     801bc1 <devpipe_read+0x26>
				return i;
  801bbd:	89 d8                	mov    %ebx,%eax
  801bbf:	eb 44                	jmp    801c05 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bc1:	89 f2                	mov    %esi,%edx
  801bc3:	89 f8                	mov    %edi,%eax
  801bc5:	e8 dc fe ff ff       	call   801aa6 <_pipeisclosed>
  801bca:	85 c0                	test   %eax,%eax
  801bcc:	75 32                	jne    801c00 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bce:	e8 ed ef ff ff       	call   800bc0 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bd3:	8b 06                	mov    (%esi),%eax
  801bd5:	3b 46 04             	cmp    0x4(%esi),%eax
  801bd8:	74 df                	je     801bb9 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bda:	99                   	cltd   
  801bdb:	c1 ea 1b             	shr    $0x1b,%edx
  801bde:	01 d0                	add    %edx,%eax
  801be0:	83 e0 1f             	and    $0x1f,%eax
  801be3:	29 d0                	sub    %edx,%eax
  801be5:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bed:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bf0:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bf3:	83 c3 01             	add    $0x1,%ebx
  801bf6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bf9:	75 d8                	jne    801bd3 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bfb:	8b 45 10             	mov    0x10(%ebp),%eax
  801bfe:	eb 05                	jmp    801c05 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c00:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c08:	5b                   	pop    %ebx
  801c09:	5e                   	pop    %esi
  801c0a:	5f                   	pop    %edi
  801c0b:	5d                   	pop    %ebp
  801c0c:	c3                   	ret    

00801c0d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c0d:	55                   	push   %ebp
  801c0e:	89 e5                	mov    %esp,%ebp
  801c10:	56                   	push   %esi
  801c11:	53                   	push   %ebx
  801c12:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c15:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c18:	50                   	push   %eax
  801c19:	e8 2c f6 ff ff       	call   80124a <fd_alloc>
  801c1e:	83 c4 10             	add    $0x10,%esp
  801c21:	89 c2                	mov    %eax,%edx
  801c23:	85 c0                	test   %eax,%eax
  801c25:	0f 88 2c 01 00 00    	js     801d57 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c2b:	83 ec 04             	sub    $0x4,%esp
  801c2e:	68 07 04 00 00       	push   $0x407
  801c33:	ff 75 f4             	pushl  -0xc(%ebp)
  801c36:	6a 00                	push   $0x0
  801c38:	e8 a2 ef ff ff       	call   800bdf <sys_page_alloc>
  801c3d:	83 c4 10             	add    $0x10,%esp
  801c40:	89 c2                	mov    %eax,%edx
  801c42:	85 c0                	test   %eax,%eax
  801c44:	0f 88 0d 01 00 00    	js     801d57 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c4a:	83 ec 0c             	sub    $0xc,%esp
  801c4d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c50:	50                   	push   %eax
  801c51:	e8 f4 f5 ff ff       	call   80124a <fd_alloc>
  801c56:	89 c3                	mov    %eax,%ebx
  801c58:	83 c4 10             	add    $0x10,%esp
  801c5b:	85 c0                	test   %eax,%eax
  801c5d:	0f 88 e2 00 00 00    	js     801d45 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c63:	83 ec 04             	sub    $0x4,%esp
  801c66:	68 07 04 00 00       	push   $0x407
  801c6b:	ff 75 f0             	pushl  -0x10(%ebp)
  801c6e:	6a 00                	push   $0x0
  801c70:	e8 6a ef ff ff       	call   800bdf <sys_page_alloc>
  801c75:	89 c3                	mov    %eax,%ebx
  801c77:	83 c4 10             	add    $0x10,%esp
  801c7a:	85 c0                	test   %eax,%eax
  801c7c:	0f 88 c3 00 00 00    	js     801d45 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c82:	83 ec 0c             	sub    $0xc,%esp
  801c85:	ff 75 f4             	pushl  -0xc(%ebp)
  801c88:	e8 a6 f5 ff ff       	call   801233 <fd2data>
  801c8d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c8f:	83 c4 0c             	add    $0xc,%esp
  801c92:	68 07 04 00 00       	push   $0x407
  801c97:	50                   	push   %eax
  801c98:	6a 00                	push   $0x0
  801c9a:	e8 40 ef ff ff       	call   800bdf <sys_page_alloc>
  801c9f:	89 c3                	mov    %eax,%ebx
  801ca1:	83 c4 10             	add    $0x10,%esp
  801ca4:	85 c0                	test   %eax,%eax
  801ca6:	0f 88 89 00 00 00    	js     801d35 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cac:	83 ec 0c             	sub    $0xc,%esp
  801caf:	ff 75 f0             	pushl  -0x10(%ebp)
  801cb2:	e8 7c f5 ff ff       	call   801233 <fd2data>
  801cb7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cbe:	50                   	push   %eax
  801cbf:	6a 00                	push   $0x0
  801cc1:	56                   	push   %esi
  801cc2:	6a 00                	push   $0x0
  801cc4:	e8 59 ef ff ff       	call   800c22 <sys_page_map>
  801cc9:	89 c3                	mov    %eax,%ebx
  801ccb:	83 c4 20             	add    $0x20,%esp
  801cce:	85 c0                	test   %eax,%eax
  801cd0:	78 55                	js     801d27 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cd2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cdb:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ce7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ced:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cf0:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cf2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cf5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cfc:	83 ec 0c             	sub    $0xc,%esp
  801cff:	ff 75 f4             	pushl  -0xc(%ebp)
  801d02:	e8 1c f5 ff ff       	call   801223 <fd2num>
  801d07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d0a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d0c:	83 c4 04             	add    $0x4,%esp
  801d0f:	ff 75 f0             	pushl  -0x10(%ebp)
  801d12:	e8 0c f5 ff ff       	call   801223 <fd2num>
  801d17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d1a:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801d1d:	83 c4 10             	add    $0x10,%esp
  801d20:	ba 00 00 00 00       	mov    $0x0,%edx
  801d25:	eb 30                	jmp    801d57 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d27:	83 ec 08             	sub    $0x8,%esp
  801d2a:	56                   	push   %esi
  801d2b:	6a 00                	push   $0x0
  801d2d:	e8 32 ef ff ff       	call   800c64 <sys_page_unmap>
  801d32:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d35:	83 ec 08             	sub    $0x8,%esp
  801d38:	ff 75 f0             	pushl  -0x10(%ebp)
  801d3b:	6a 00                	push   $0x0
  801d3d:	e8 22 ef ff ff       	call   800c64 <sys_page_unmap>
  801d42:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d45:	83 ec 08             	sub    $0x8,%esp
  801d48:	ff 75 f4             	pushl  -0xc(%ebp)
  801d4b:	6a 00                	push   $0x0
  801d4d:	e8 12 ef ff ff       	call   800c64 <sys_page_unmap>
  801d52:	83 c4 10             	add    $0x10,%esp
  801d55:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d57:	89 d0                	mov    %edx,%eax
  801d59:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d5c:	5b                   	pop    %ebx
  801d5d:	5e                   	pop    %esi
  801d5e:	5d                   	pop    %ebp
  801d5f:	c3                   	ret    

00801d60 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d60:	55                   	push   %ebp
  801d61:	89 e5                	mov    %esp,%ebp
  801d63:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d66:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d69:	50                   	push   %eax
  801d6a:	ff 75 08             	pushl  0x8(%ebp)
  801d6d:	e8 27 f5 ff ff       	call   801299 <fd_lookup>
  801d72:	83 c4 10             	add    $0x10,%esp
  801d75:	85 c0                	test   %eax,%eax
  801d77:	78 18                	js     801d91 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d79:	83 ec 0c             	sub    $0xc,%esp
  801d7c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d7f:	e8 af f4 ff ff       	call   801233 <fd2data>
	return _pipeisclosed(fd, p);
  801d84:	89 c2                	mov    %eax,%edx
  801d86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d89:	e8 18 fd ff ff       	call   801aa6 <_pipeisclosed>
  801d8e:	83 c4 10             	add    $0x10,%esp
}
  801d91:	c9                   	leave  
  801d92:	c3                   	ret    

00801d93 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d93:	55                   	push   %ebp
  801d94:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d96:	b8 00 00 00 00       	mov    $0x0,%eax
  801d9b:	5d                   	pop    %ebp
  801d9c:	c3                   	ret    

00801d9d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d9d:	55                   	push   %ebp
  801d9e:	89 e5                	mov    %esp,%ebp
  801da0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801da3:	68 82 27 80 00       	push   $0x802782
  801da8:	ff 75 0c             	pushl  0xc(%ebp)
  801dab:	e8 2c ea ff ff       	call   8007dc <strcpy>
	return 0;
}
  801db0:	b8 00 00 00 00       	mov    $0x0,%eax
  801db5:	c9                   	leave  
  801db6:	c3                   	ret    

00801db7 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801db7:	55                   	push   %ebp
  801db8:	89 e5                	mov    %esp,%ebp
  801dba:	57                   	push   %edi
  801dbb:	56                   	push   %esi
  801dbc:	53                   	push   %ebx
  801dbd:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dc3:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dc8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dce:	eb 2d                	jmp    801dfd <devcons_write+0x46>
		m = n - tot;
  801dd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dd3:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801dd5:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dd8:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ddd:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801de0:	83 ec 04             	sub    $0x4,%esp
  801de3:	53                   	push   %ebx
  801de4:	03 45 0c             	add    0xc(%ebp),%eax
  801de7:	50                   	push   %eax
  801de8:	57                   	push   %edi
  801de9:	e8 80 eb ff ff       	call   80096e <memmove>
		sys_cputs(buf, m);
  801dee:	83 c4 08             	add    $0x8,%esp
  801df1:	53                   	push   %ebx
  801df2:	57                   	push   %edi
  801df3:	e8 2b ed ff ff       	call   800b23 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801df8:	01 de                	add    %ebx,%esi
  801dfa:	83 c4 10             	add    $0x10,%esp
  801dfd:	89 f0                	mov    %esi,%eax
  801dff:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e02:	72 cc                	jb     801dd0 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e07:	5b                   	pop    %ebx
  801e08:	5e                   	pop    %esi
  801e09:	5f                   	pop    %edi
  801e0a:	5d                   	pop    %ebp
  801e0b:	c3                   	ret    

00801e0c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e0c:	55                   	push   %ebp
  801e0d:	89 e5                	mov    %esp,%ebp
  801e0f:	83 ec 08             	sub    $0x8,%esp
  801e12:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e17:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e1b:	74 2a                	je     801e47 <devcons_read+0x3b>
  801e1d:	eb 05                	jmp    801e24 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e1f:	e8 9c ed ff ff       	call   800bc0 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e24:	e8 18 ed ff ff       	call   800b41 <sys_cgetc>
  801e29:	85 c0                	test   %eax,%eax
  801e2b:	74 f2                	je     801e1f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e2d:	85 c0                	test   %eax,%eax
  801e2f:	78 16                	js     801e47 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e31:	83 f8 04             	cmp    $0x4,%eax
  801e34:	74 0c                	je     801e42 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e36:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e39:	88 02                	mov    %al,(%edx)
	return 1;
  801e3b:	b8 01 00 00 00       	mov    $0x1,%eax
  801e40:	eb 05                	jmp    801e47 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e42:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e47:	c9                   	leave  
  801e48:	c3                   	ret    

00801e49 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e49:	55                   	push   %ebp
  801e4a:	89 e5                	mov    %esp,%ebp
  801e4c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e52:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e55:	6a 01                	push   $0x1
  801e57:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e5a:	50                   	push   %eax
  801e5b:	e8 c3 ec ff ff       	call   800b23 <sys_cputs>
}
  801e60:	83 c4 10             	add    $0x10,%esp
  801e63:	c9                   	leave  
  801e64:	c3                   	ret    

00801e65 <getchar>:

int
getchar(void)
{
  801e65:	55                   	push   %ebp
  801e66:	89 e5                	mov    %esp,%ebp
  801e68:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e6b:	6a 01                	push   $0x1
  801e6d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e70:	50                   	push   %eax
  801e71:	6a 00                	push   $0x0
  801e73:	e8 87 f6 ff ff       	call   8014ff <read>
	if (r < 0)
  801e78:	83 c4 10             	add    $0x10,%esp
  801e7b:	85 c0                	test   %eax,%eax
  801e7d:	78 0f                	js     801e8e <getchar+0x29>
		return r;
	if (r < 1)
  801e7f:	85 c0                	test   %eax,%eax
  801e81:	7e 06                	jle    801e89 <getchar+0x24>
		return -E_EOF;
	return c;
  801e83:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e87:	eb 05                	jmp    801e8e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e89:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e8e:	c9                   	leave  
  801e8f:	c3                   	ret    

00801e90 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e90:	55                   	push   %ebp
  801e91:	89 e5                	mov    %esp,%ebp
  801e93:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e96:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e99:	50                   	push   %eax
  801e9a:	ff 75 08             	pushl  0x8(%ebp)
  801e9d:	e8 f7 f3 ff ff       	call   801299 <fd_lookup>
  801ea2:	83 c4 10             	add    $0x10,%esp
  801ea5:	85 c0                	test   %eax,%eax
  801ea7:	78 11                	js     801eba <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ea9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eac:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801eb2:	39 10                	cmp    %edx,(%eax)
  801eb4:	0f 94 c0             	sete   %al
  801eb7:	0f b6 c0             	movzbl %al,%eax
}
  801eba:	c9                   	leave  
  801ebb:	c3                   	ret    

00801ebc <opencons>:

int
opencons(void)
{
  801ebc:	55                   	push   %ebp
  801ebd:	89 e5                	mov    %esp,%ebp
  801ebf:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ec2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ec5:	50                   	push   %eax
  801ec6:	e8 7f f3 ff ff       	call   80124a <fd_alloc>
  801ecb:	83 c4 10             	add    $0x10,%esp
		return r;
  801ece:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ed0:	85 c0                	test   %eax,%eax
  801ed2:	78 3e                	js     801f12 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ed4:	83 ec 04             	sub    $0x4,%esp
  801ed7:	68 07 04 00 00       	push   $0x407
  801edc:	ff 75 f4             	pushl  -0xc(%ebp)
  801edf:	6a 00                	push   $0x0
  801ee1:	e8 f9 ec ff ff       	call   800bdf <sys_page_alloc>
  801ee6:	83 c4 10             	add    $0x10,%esp
		return r;
  801ee9:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eeb:	85 c0                	test   %eax,%eax
  801eed:	78 23                	js     801f12 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801eef:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801efa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801efd:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f04:	83 ec 0c             	sub    $0xc,%esp
  801f07:	50                   	push   %eax
  801f08:	e8 16 f3 ff ff       	call   801223 <fd2num>
  801f0d:	89 c2                	mov    %eax,%edx
  801f0f:	83 c4 10             	add    $0x10,%esp
}
  801f12:	89 d0                	mov    %edx,%eax
  801f14:	c9                   	leave  
  801f15:	c3                   	ret    

00801f16 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f16:	55                   	push   %ebp
  801f17:	89 e5                	mov    %esp,%ebp
  801f19:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f1c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f23:	75 2a                	jne    801f4f <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801f25:	83 ec 04             	sub    $0x4,%esp
  801f28:	6a 07                	push   $0x7
  801f2a:	68 00 f0 bf ee       	push   $0xeebff000
  801f2f:	6a 00                	push   $0x0
  801f31:	e8 a9 ec ff ff       	call   800bdf <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801f36:	83 c4 10             	add    $0x10,%esp
  801f39:	85 c0                	test   %eax,%eax
  801f3b:	79 12                	jns    801f4f <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801f3d:	50                   	push   %eax
  801f3e:	68 8e 27 80 00       	push   $0x80278e
  801f43:	6a 23                	push   $0x23
  801f45:	68 92 27 80 00       	push   $0x802792
  801f4a:	e8 2f e2 ff ff       	call   80017e <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f52:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801f57:	83 ec 08             	sub    $0x8,%esp
  801f5a:	68 81 1f 80 00       	push   $0x801f81
  801f5f:	6a 00                	push   $0x0
  801f61:	e8 c4 ed ff ff       	call   800d2a <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801f66:	83 c4 10             	add    $0x10,%esp
  801f69:	85 c0                	test   %eax,%eax
  801f6b:	79 12                	jns    801f7f <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801f6d:	50                   	push   %eax
  801f6e:	68 8e 27 80 00       	push   $0x80278e
  801f73:	6a 2c                	push   $0x2c
  801f75:	68 92 27 80 00       	push   $0x802792
  801f7a:	e8 ff e1 ff ff       	call   80017e <_panic>
	}
}
  801f7f:	c9                   	leave  
  801f80:	c3                   	ret    

00801f81 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f81:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f82:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f87:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f89:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801f8c:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801f90:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801f95:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801f99:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801f9b:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801f9e:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801f9f:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801fa2:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801fa3:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801fa4:	c3                   	ret    

00801fa5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fa5:	55                   	push   %ebp
  801fa6:	89 e5                	mov    %esp,%ebp
  801fa8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fab:	89 d0                	mov    %edx,%eax
  801fad:	c1 e8 16             	shr    $0x16,%eax
  801fb0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fb7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fbc:	f6 c1 01             	test   $0x1,%cl
  801fbf:	74 1d                	je     801fde <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fc1:	c1 ea 0c             	shr    $0xc,%edx
  801fc4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fcb:	f6 c2 01             	test   $0x1,%dl
  801fce:	74 0e                	je     801fde <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fd0:	c1 ea 0c             	shr    $0xc,%edx
  801fd3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fda:	ef 
  801fdb:	0f b7 c0             	movzwl %ax,%eax
}
  801fde:	5d                   	pop    %ebp
  801fdf:	c3                   	ret    

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
