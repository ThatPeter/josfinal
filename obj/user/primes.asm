
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
  800047:	e8 60 13 00 00       	call   8013ac <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 40 80 00       	mov    0x804004,%eax
  800053:	8b 80 b8 00 00 00    	mov    0xb8(%eax),%eax
  800059:	83 c4 0c             	add    $0xc,%esp
  80005c:	53                   	push   %ebx
  80005d:	50                   	push   %eax
  80005e:	68 40 25 80 00       	push   $0x802540
  800063:	e8 ef 01 00 00       	call   800257 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800068:	e8 99 0e 00 00       	call   800f06 <fork>
  80006d:	89 c7                	mov    %eax,%edi
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	85 c0                	test   %eax,%eax
  800074:	79 12                	jns    800088 <primeproc+0x55>
		panic("fork: %e", id);
  800076:	50                   	push   %eax
  800077:	68 4c 25 80 00       	push   $0x80254c
  80007c:	6a 1a                	push   $0x1a
  80007e:	68 55 25 80 00       	push   $0x802555
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
  800097:	e8 10 13 00 00       	call   8013ac <ipc_recv>
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
  8000ae:	e8 74 13 00 00       	call   801427 <ipc_send>
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
  8000bd:	e8 44 0e 00 00       	call   800f06 <fork>
  8000c2:	89 c6                	mov    %eax,%esi
  8000c4:	85 c0                	test   %eax,%eax
  8000c6:	79 12                	jns    8000da <umain+0x22>
		panic("fork: %e", id);
  8000c8:	50                   	push   %eax
  8000c9:	68 4c 25 80 00       	push   $0x80254c
  8000ce:	6a 2d                	push   $0x2d
  8000d0:	68 55 25 80 00       	push   $0x802555
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
  8000ee:	e8 34 13 00 00       	call   801427 <ipc_send>
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
  800110:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  80016a:	e8 2d 15 00 00       	call   80169c <close_all>
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
  80019c:	68 70 25 80 00       	push   $0x802570
  8001a1:	e8 b1 00 00 00       	call   800257 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a6:	83 c4 18             	add    $0x18,%esp
  8001a9:	53                   	push   %ebx
  8001aa:	ff 75 10             	pushl  0x10(%ebp)
  8001ad:	e8 54 00 00 00       	call   800206 <vcprintf>
	cprintf("\n");
  8001b2:	c7 04 24 66 29 80 00 	movl   $0x802966,(%esp)
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
  8002ba:	e8 e1 1f 00 00       	call   8022a0 <__udivdi3>
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
  8002fd:	e8 ce 20 00 00       	call   8023d0 <__umoddi3>
  800302:	83 c4 14             	add    $0x14,%esp
  800305:	0f be 80 93 25 80 00 	movsbl 0x802593(%eax),%eax
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
  800401:	ff 24 85 e0 26 80 00 	jmp    *0x8026e0(,%eax,4)
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
  8004c5:	8b 14 85 40 28 80 00 	mov    0x802840(,%eax,4),%edx
  8004cc:	85 d2                	test   %edx,%edx
  8004ce:	75 18                	jne    8004e8 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004d0:	50                   	push   %eax
  8004d1:	68 ab 25 80 00       	push   $0x8025ab
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
  8004e9:	68 e9 2a 80 00       	push   $0x802ae9
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
  80050d:	b8 a4 25 80 00       	mov    $0x8025a4,%eax
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
  800b88:	68 9f 28 80 00       	push   $0x80289f
  800b8d:	6a 23                	push   $0x23
  800b8f:	68 bc 28 80 00       	push   $0x8028bc
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
  800c09:	68 9f 28 80 00       	push   $0x80289f
  800c0e:	6a 23                	push   $0x23
  800c10:	68 bc 28 80 00       	push   $0x8028bc
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
  800c4b:	68 9f 28 80 00       	push   $0x80289f
  800c50:	6a 23                	push   $0x23
  800c52:	68 bc 28 80 00       	push   $0x8028bc
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
  800c8d:	68 9f 28 80 00       	push   $0x80289f
  800c92:	6a 23                	push   $0x23
  800c94:	68 bc 28 80 00       	push   $0x8028bc
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
  800ccf:	68 9f 28 80 00       	push   $0x80289f
  800cd4:	6a 23                	push   $0x23
  800cd6:	68 bc 28 80 00       	push   $0x8028bc
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
  800d11:	68 9f 28 80 00       	push   $0x80289f
  800d16:	6a 23                	push   $0x23
  800d18:	68 bc 28 80 00       	push   $0x8028bc
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
  800d53:	68 9f 28 80 00       	push   $0x80289f
  800d58:	6a 23                	push   $0x23
  800d5a:	68 bc 28 80 00       	push   $0x8028bc
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
  800db7:	68 9f 28 80 00       	push   $0x80289f
  800dbc:	6a 23                	push   $0x23
  800dbe:	68 bc 28 80 00       	push   $0x8028bc
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

00800e10 <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	57                   	push   %edi
  800e14:	56                   	push   %esi
  800e15:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e16:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e1b:	b8 10 00 00 00       	mov    $0x10,%eax
  800e20:	8b 55 08             	mov    0x8(%ebp),%edx
  800e23:	89 cb                	mov    %ecx,%ebx
  800e25:	89 cf                	mov    %ecx,%edi
  800e27:	89 ce                	mov    %ecx,%esi
  800e29:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800e2b:	5b                   	pop    %ebx
  800e2c:	5e                   	pop    %esi
  800e2d:	5f                   	pop    %edi
  800e2e:	5d                   	pop    %ebp
  800e2f:	c3                   	ret    

00800e30 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
  800e33:	53                   	push   %ebx
  800e34:	83 ec 04             	sub    $0x4,%esp
  800e37:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e3a:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800e3c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e40:	74 11                	je     800e53 <pgfault+0x23>
  800e42:	89 d8                	mov    %ebx,%eax
  800e44:	c1 e8 0c             	shr    $0xc,%eax
  800e47:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e4e:	f6 c4 08             	test   $0x8,%ah
  800e51:	75 14                	jne    800e67 <pgfault+0x37>
		panic("faulting access");
  800e53:	83 ec 04             	sub    $0x4,%esp
  800e56:	68 ca 28 80 00       	push   $0x8028ca
  800e5b:	6a 1f                	push   $0x1f
  800e5d:	68 da 28 80 00       	push   $0x8028da
  800e62:	e8 17 f3 ff ff       	call   80017e <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e67:	83 ec 04             	sub    $0x4,%esp
  800e6a:	6a 07                	push   $0x7
  800e6c:	68 00 f0 7f 00       	push   $0x7ff000
  800e71:	6a 00                	push   $0x0
  800e73:	e8 67 fd ff ff       	call   800bdf <sys_page_alloc>
	if (r < 0) {
  800e78:	83 c4 10             	add    $0x10,%esp
  800e7b:	85 c0                	test   %eax,%eax
  800e7d:	79 12                	jns    800e91 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e7f:	50                   	push   %eax
  800e80:	68 e5 28 80 00       	push   $0x8028e5
  800e85:	6a 2d                	push   $0x2d
  800e87:	68 da 28 80 00       	push   $0x8028da
  800e8c:	e8 ed f2 ff ff       	call   80017e <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e91:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e97:	83 ec 04             	sub    $0x4,%esp
  800e9a:	68 00 10 00 00       	push   $0x1000
  800e9f:	53                   	push   %ebx
  800ea0:	68 00 f0 7f 00       	push   $0x7ff000
  800ea5:	e8 2c fb ff ff       	call   8009d6 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800eaa:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800eb1:	53                   	push   %ebx
  800eb2:	6a 00                	push   $0x0
  800eb4:	68 00 f0 7f 00       	push   $0x7ff000
  800eb9:	6a 00                	push   $0x0
  800ebb:	e8 62 fd ff ff       	call   800c22 <sys_page_map>
	if (r < 0) {
  800ec0:	83 c4 20             	add    $0x20,%esp
  800ec3:	85 c0                	test   %eax,%eax
  800ec5:	79 12                	jns    800ed9 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800ec7:	50                   	push   %eax
  800ec8:	68 e5 28 80 00       	push   $0x8028e5
  800ecd:	6a 34                	push   $0x34
  800ecf:	68 da 28 80 00       	push   $0x8028da
  800ed4:	e8 a5 f2 ff ff       	call   80017e <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800ed9:	83 ec 08             	sub    $0x8,%esp
  800edc:	68 00 f0 7f 00       	push   $0x7ff000
  800ee1:	6a 00                	push   $0x0
  800ee3:	e8 7c fd ff ff       	call   800c64 <sys_page_unmap>
	if (r < 0) {
  800ee8:	83 c4 10             	add    $0x10,%esp
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	79 12                	jns    800f01 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800eef:	50                   	push   %eax
  800ef0:	68 e5 28 80 00       	push   $0x8028e5
  800ef5:	6a 38                	push   $0x38
  800ef7:	68 da 28 80 00       	push   $0x8028da
  800efc:	e8 7d f2 ff ff       	call   80017e <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800f01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f04:	c9                   	leave  
  800f05:	c3                   	ret    

00800f06 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	57                   	push   %edi
  800f0a:	56                   	push   %esi
  800f0b:	53                   	push   %ebx
  800f0c:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800f0f:	68 30 0e 80 00       	push   $0x800e30
  800f14:	e8 b4 12 00 00       	call   8021cd <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f19:	b8 07 00 00 00       	mov    $0x7,%eax
  800f1e:	cd 30                	int    $0x30
  800f20:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800f23:	83 c4 10             	add    $0x10,%esp
  800f26:	85 c0                	test   %eax,%eax
  800f28:	79 17                	jns    800f41 <fork+0x3b>
		panic("fork fault %e");
  800f2a:	83 ec 04             	sub    $0x4,%esp
  800f2d:	68 fe 28 80 00       	push   $0x8028fe
  800f32:	68 85 00 00 00       	push   $0x85
  800f37:	68 da 28 80 00       	push   $0x8028da
  800f3c:	e8 3d f2 ff ff       	call   80017e <_panic>
  800f41:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f43:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f47:	75 24                	jne    800f6d <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f49:	e8 53 fc ff ff       	call   800ba1 <sys_getenvid>
  800f4e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f53:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  800f59:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f5e:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f63:	b8 00 00 00 00       	mov    $0x0,%eax
  800f68:	e9 64 01 00 00       	jmp    8010d1 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f6d:	83 ec 04             	sub    $0x4,%esp
  800f70:	6a 07                	push   $0x7
  800f72:	68 00 f0 bf ee       	push   $0xeebff000
  800f77:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f7a:	e8 60 fc ff ff       	call   800bdf <sys_page_alloc>
  800f7f:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f82:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f87:	89 d8                	mov    %ebx,%eax
  800f89:	c1 e8 16             	shr    $0x16,%eax
  800f8c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f93:	a8 01                	test   $0x1,%al
  800f95:	0f 84 fc 00 00 00    	je     801097 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f9b:	89 d8                	mov    %ebx,%eax
  800f9d:	c1 e8 0c             	shr    $0xc,%eax
  800fa0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fa7:	f6 c2 01             	test   $0x1,%dl
  800faa:	0f 84 e7 00 00 00    	je     801097 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800fb0:	89 c6                	mov    %eax,%esi
  800fb2:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800fb5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fbc:	f6 c6 04             	test   $0x4,%dh
  800fbf:	74 39                	je     800ffa <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800fc1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fc8:	83 ec 0c             	sub    $0xc,%esp
  800fcb:	25 07 0e 00 00       	and    $0xe07,%eax
  800fd0:	50                   	push   %eax
  800fd1:	56                   	push   %esi
  800fd2:	57                   	push   %edi
  800fd3:	56                   	push   %esi
  800fd4:	6a 00                	push   $0x0
  800fd6:	e8 47 fc ff ff       	call   800c22 <sys_page_map>
		if (r < 0) {
  800fdb:	83 c4 20             	add    $0x20,%esp
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	0f 89 b1 00 00 00    	jns    801097 <fork+0x191>
		    	panic("sys page map fault %e");
  800fe6:	83 ec 04             	sub    $0x4,%esp
  800fe9:	68 0c 29 80 00       	push   $0x80290c
  800fee:	6a 55                	push   $0x55
  800ff0:	68 da 28 80 00       	push   $0x8028da
  800ff5:	e8 84 f1 ff ff       	call   80017e <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800ffa:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801001:	f6 c2 02             	test   $0x2,%dl
  801004:	75 0c                	jne    801012 <fork+0x10c>
  801006:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80100d:	f6 c4 08             	test   $0x8,%ah
  801010:	74 5b                	je     80106d <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  801012:	83 ec 0c             	sub    $0xc,%esp
  801015:	68 05 08 00 00       	push   $0x805
  80101a:	56                   	push   %esi
  80101b:	57                   	push   %edi
  80101c:	56                   	push   %esi
  80101d:	6a 00                	push   $0x0
  80101f:	e8 fe fb ff ff       	call   800c22 <sys_page_map>
		if (r < 0) {
  801024:	83 c4 20             	add    $0x20,%esp
  801027:	85 c0                	test   %eax,%eax
  801029:	79 14                	jns    80103f <fork+0x139>
		    	panic("sys page map fault %e");
  80102b:	83 ec 04             	sub    $0x4,%esp
  80102e:	68 0c 29 80 00       	push   $0x80290c
  801033:	6a 5c                	push   $0x5c
  801035:	68 da 28 80 00       	push   $0x8028da
  80103a:	e8 3f f1 ff ff       	call   80017e <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  80103f:	83 ec 0c             	sub    $0xc,%esp
  801042:	68 05 08 00 00       	push   $0x805
  801047:	56                   	push   %esi
  801048:	6a 00                	push   $0x0
  80104a:	56                   	push   %esi
  80104b:	6a 00                	push   $0x0
  80104d:	e8 d0 fb ff ff       	call   800c22 <sys_page_map>
		if (r < 0) {
  801052:	83 c4 20             	add    $0x20,%esp
  801055:	85 c0                	test   %eax,%eax
  801057:	79 3e                	jns    801097 <fork+0x191>
		    	panic("sys page map fault %e");
  801059:	83 ec 04             	sub    $0x4,%esp
  80105c:	68 0c 29 80 00       	push   $0x80290c
  801061:	6a 60                	push   $0x60
  801063:	68 da 28 80 00       	push   $0x8028da
  801068:	e8 11 f1 ff ff       	call   80017e <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80106d:	83 ec 0c             	sub    $0xc,%esp
  801070:	6a 05                	push   $0x5
  801072:	56                   	push   %esi
  801073:	57                   	push   %edi
  801074:	56                   	push   %esi
  801075:	6a 00                	push   $0x0
  801077:	e8 a6 fb ff ff       	call   800c22 <sys_page_map>
		if (r < 0) {
  80107c:	83 c4 20             	add    $0x20,%esp
  80107f:	85 c0                	test   %eax,%eax
  801081:	79 14                	jns    801097 <fork+0x191>
		    	panic("sys page map fault %e");
  801083:	83 ec 04             	sub    $0x4,%esp
  801086:	68 0c 29 80 00       	push   $0x80290c
  80108b:	6a 65                	push   $0x65
  80108d:	68 da 28 80 00       	push   $0x8028da
  801092:	e8 e7 f0 ff ff       	call   80017e <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801097:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80109d:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8010a3:	0f 85 de fe ff ff    	jne    800f87 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8010a9:	a1 04 40 80 00       	mov    0x804004,%eax
  8010ae:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
  8010b4:	83 ec 08             	sub    $0x8,%esp
  8010b7:	50                   	push   %eax
  8010b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010bb:	57                   	push   %edi
  8010bc:	e8 69 fc ff ff       	call   800d2a <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8010c1:	83 c4 08             	add    $0x8,%esp
  8010c4:	6a 02                	push   $0x2
  8010c6:	57                   	push   %edi
  8010c7:	e8 da fb ff ff       	call   800ca6 <sys_env_set_status>
	
	return envid;
  8010cc:	83 c4 10             	add    $0x10,%esp
  8010cf:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8010d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d4:	5b                   	pop    %ebx
  8010d5:	5e                   	pop    %esi
  8010d6:	5f                   	pop    %edi
  8010d7:	5d                   	pop    %ebp
  8010d8:	c3                   	ret    

008010d9 <sfork>:

envid_t
sfork(void)
{
  8010d9:	55                   	push   %ebp
  8010da:	89 e5                	mov    %esp,%ebp
	return 0;
}
  8010dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e1:	5d                   	pop    %ebp
  8010e2:	c3                   	ret    

008010e3 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	56                   	push   %esi
  8010e7:	53                   	push   %ebx
  8010e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  8010eb:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  8010f1:	83 ec 08             	sub    $0x8,%esp
  8010f4:	53                   	push   %ebx
  8010f5:	68 9c 29 80 00       	push   $0x80299c
  8010fa:	e8 58 f1 ff ff       	call   800257 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8010ff:	c7 04 24 44 01 80 00 	movl   $0x800144,(%esp)
  801106:	e8 c5 fc ff ff       	call   800dd0 <sys_thread_create>
  80110b:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80110d:	83 c4 08             	add    $0x8,%esp
  801110:	53                   	push   %ebx
  801111:	68 9c 29 80 00       	push   $0x80299c
  801116:	e8 3c f1 ff ff       	call   800257 <cprintf>
	return id;
}
  80111b:	89 f0                	mov    %esi,%eax
  80111d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801120:	5b                   	pop    %ebx
  801121:	5e                   	pop    %esi
  801122:	5d                   	pop    %ebp
  801123:	c3                   	ret    

00801124 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  80112a:	ff 75 08             	pushl  0x8(%ebp)
  80112d:	e8 be fc ff ff       	call   800df0 <sys_thread_free>
}
  801132:	83 c4 10             	add    $0x10,%esp
  801135:	c9                   	leave  
  801136:	c3                   	ret    

00801137 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  80113d:	ff 75 08             	pushl  0x8(%ebp)
  801140:	e8 cb fc ff ff       	call   800e10 <sys_thread_join>
}
  801145:	83 c4 10             	add    $0x10,%esp
  801148:	c9                   	leave  
  801149:	c3                   	ret    

0080114a <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  80114a:	55                   	push   %ebp
  80114b:	89 e5                	mov    %esp,%ebp
  80114d:	56                   	push   %esi
  80114e:	53                   	push   %ebx
  80114f:	8b 75 08             	mov    0x8(%ebp),%esi
  801152:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  801155:	83 ec 04             	sub    $0x4,%esp
  801158:	6a 07                	push   $0x7
  80115a:	6a 00                	push   $0x0
  80115c:	56                   	push   %esi
  80115d:	e8 7d fa ff ff       	call   800bdf <sys_page_alloc>
	if (r < 0) {
  801162:	83 c4 10             	add    $0x10,%esp
  801165:	85 c0                	test   %eax,%eax
  801167:	79 15                	jns    80117e <queue_append+0x34>
		panic("%e\n", r);
  801169:	50                   	push   %eax
  80116a:	68 98 29 80 00       	push   $0x802998
  80116f:	68 c4 00 00 00       	push   $0xc4
  801174:	68 da 28 80 00       	push   $0x8028da
  801179:	e8 00 f0 ff ff       	call   80017e <_panic>
	}	
	wt->envid = envid;
  80117e:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  801184:	83 ec 04             	sub    $0x4,%esp
  801187:	ff 33                	pushl  (%ebx)
  801189:	56                   	push   %esi
  80118a:	68 c0 29 80 00       	push   $0x8029c0
  80118f:	e8 c3 f0 ff ff       	call   800257 <cprintf>
	if (queue->first == NULL) {
  801194:	83 c4 10             	add    $0x10,%esp
  801197:	83 3b 00             	cmpl   $0x0,(%ebx)
  80119a:	75 29                	jne    8011c5 <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  80119c:	83 ec 0c             	sub    $0xc,%esp
  80119f:	68 22 29 80 00       	push   $0x802922
  8011a4:	e8 ae f0 ff ff       	call   800257 <cprintf>
		queue->first = wt;
  8011a9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  8011af:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  8011b6:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8011bd:	00 00 00 
  8011c0:	83 c4 10             	add    $0x10,%esp
  8011c3:	eb 2b                	jmp    8011f0 <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  8011c5:	83 ec 0c             	sub    $0xc,%esp
  8011c8:	68 3c 29 80 00       	push   $0x80293c
  8011cd:	e8 85 f0 ff ff       	call   800257 <cprintf>
		queue->last->next = wt;
  8011d2:	8b 43 04             	mov    0x4(%ebx),%eax
  8011d5:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  8011dc:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8011e3:	00 00 00 
		queue->last = wt;
  8011e6:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  8011ed:	83 c4 10             	add    $0x10,%esp
	}
}
  8011f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011f3:	5b                   	pop    %ebx
  8011f4:	5e                   	pop    %esi
  8011f5:	5d                   	pop    %ebp
  8011f6:	c3                   	ret    

008011f7 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	53                   	push   %ebx
  8011fb:	83 ec 04             	sub    $0x4,%esp
  8011fe:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  801201:	8b 02                	mov    (%edx),%eax
  801203:	85 c0                	test   %eax,%eax
  801205:	75 17                	jne    80121e <queue_pop+0x27>
		panic("queue empty!\n");
  801207:	83 ec 04             	sub    $0x4,%esp
  80120a:	68 5a 29 80 00       	push   $0x80295a
  80120f:	68 d8 00 00 00       	push   $0xd8
  801214:	68 da 28 80 00       	push   $0x8028da
  801219:	e8 60 ef ff ff       	call   80017e <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  80121e:	8b 48 04             	mov    0x4(%eax),%ecx
  801221:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  801223:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  801225:	83 ec 08             	sub    $0x8,%esp
  801228:	53                   	push   %ebx
  801229:	68 68 29 80 00       	push   $0x802968
  80122e:	e8 24 f0 ff ff       	call   800257 <cprintf>
	return envid;
}
  801233:	89 d8                	mov    %ebx,%eax
  801235:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801238:	c9                   	leave  
  801239:	c3                   	ret    

0080123a <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  80123a:	55                   	push   %ebp
  80123b:	89 e5                	mov    %esp,%ebp
  80123d:	53                   	push   %ebx
  80123e:	83 ec 04             	sub    $0x4,%esp
  801241:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801244:	b8 01 00 00 00       	mov    $0x1,%eax
  801249:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  80124c:	85 c0                	test   %eax,%eax
  80124e:	74 5a                	je     8012aa <mutex_lock+0x70>
  801250:	8b 43 04             	mov    0x4(%ebx),%eax
  801253:	83 38 00             	cmpl   $0x0,(%eax)
  801256:	75 52                	jne    8012aa <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  801258:	83 ec 0c             	sub    $0xc,%esp
  80125b:	68 e8 29 80 00       	push   $0x8029e8
  801260:	e8 f2 ef ff ff       	call   800257 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  801265:	8b 5b 04             	mov    0x4(%ebx),%ebx
  801268:	e8 34 f9 ff ff       	call   800ba1 <sys_getenvid>
  80126d:	83 c4 08             	add    $0x8,%esp
  801270:	53                   	push   %ebx
  801271:	50                   	push   %eax
  801272:	e8 d3 fe ff ff       	call   80114a <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  801277:	e8 25 f9 ff ff       	call   800ba1 <sys_getenvid>
  80127c:	83 c4 08             	add    $0x8,%esp
  80127f:	6a 04                	push   $0x4
  801281:	50                   	push   %eax
  801282:	e8 1f fa ff ff       	call   800ca6 <sys_env_set_status>
		if (r < 0) {
  801287:	83 c4 10             	add    $0x10,%esp
  80128a:	85 c0                	test   %eax,%eax
  80128c:	79 15                	jns    8012a3 <mutex_lock+0x69>
			panic("%e\n", r);
  80128e:	50                   	push   %eax
  80128f:	68 98 29 80 00       	push   $0x802998
  801294:	68 eb 00 00 00       	push   $0xeb
  801299:	68 da 28 80 00       	push   $0x8028da
  80129e:	e8 db ee ff ff       	call   80017e <_panic>
		}
		sys_yield();
  8012a3:	e8 18 f9 ff ff       	call   800bc0 <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8012a8:	eb 18                	jmp    8012c2 <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  8012aa:	83 ec 0c             	sub    $0xc,%esp
  8012ad:	68 08 2a 80 00       	push   $0x802a08
  8012b2:	e8 a0 ef ff ff       	call   800257 <cprintf>
	mtx->owner = sys_getenvid();}
  8012b7:	e8 e5 f8 ff ff       	call   800ba1 <sys_getenvid>
  8012bc:	89 43 08             	mov    %eax,0x8(%ebx)
  8012bf:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  8012c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c5:	c9                   	leave  
  8012c6:	c3                   	ret    

008012c7 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  8012c7:	55                   	push   %ebp
  8012c8:	89 e5                	mov    %esp,%ebp
  8012ca:	53                   	push   %ebx
  8012cb:	83 ec 04             	sub    $0x4,%esp
  8012ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d6:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  8012d9:	8b 43 04             	mov    0x4(%ebx),%eax
  8012dc:	83 38 00             	cmpl   $0x0,(%eax)
  8012df:	74 33                	je     801314 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  8012e1:	83 ec 0c             	sub    $0xc,%esp
  8012e4:	50                   	push   %eax
  8012e5:	e8 0d ff ff ff       	call   8011f7 <queue_pop>
  8012ea:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8012ed:	83 c4 08             	add    $0x8,%esp
  8012f0:	6a 02                	push   $0x2
  8012f2:	50                   	push   %eax
  8012f3:	e8 ae f9 ff ff       	call   800ca6 <sys_env_set_status>
		if (r < 0) {
  8012f8:	83 c4 10             	add    $0x10,%esp
  8012fb:	85 c0                	test   %eax,%eax
  8012fd:	79 15                	jns    801314 <mutex_unlock+0x4d>
			panic("%e\n", r);
  8012ff:	50                   	push   %eax
  801300:	68 98 29 80 00       	push   $0x802998
  801305:	68 00 01 00 00       	push   $0x100
  80130a:	68 da 28 80 00       	push   $0x8028da
  80130f:	e8 6a ee ff ff       	call   80017e <_panic>
		}
	}

	asm volatile("pause");
  801314:	f3 90                	pause  
	//sys_yield();
}
  801316:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801319:	c9                   	leave  
  80131a:	c3                   	ret    

0080131b <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  80131b:	55                   	push   %ebp
  80131c:	89 e5                	mov    %esp,%ebp
  80131e:	53                   	push   %ebx
  80131f:	83 ec 04             	sub    $0x4,%esp
  801322:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  801325:	e8 77 f8 ff ff       	call   800ba1 <sys_getenvid>
  80132a:	83 ec 04             	sub    $0x4,%esp
  80132d:	6a 07                	push   $0x7
  80132f:	53                   	push   %ebx
  801330:	50                   	push   %eax
  801331:	e8 a9 f8 ff ff       	call   800bdf <sys_page_alloc>
  801336:	83 c4 10             	add    $0x10,%esp
  801339:	85 c0                	test   %eax,%eax
  80133b:	79 15                	jns    801352 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  80133d:	50                   	push   %eax
  80133e:	68 83 29 80 00       	push   $0x802983
  801343:	68 0d 01 00 00       	push   $0x10d
  801348:	68 da 28 80 00       	push   $0x8028da
  80134d:	e8 2c ee ff ff       	call   80017e <_panic>
	}	
	mtx->locked = 0;
  801352:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  801358:	8b 43 04             	mov    0x4(%ebx),%eax
  80135b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  801361:	8b 43 04             	mov    0x4(%ebx),%eax
  801364:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  80136b:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  801372:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801375:	c9                   	leave  
  801376:	c3                   	ret    

00801377 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  80137d:	e8 1f f8 ff ff       	call   800ba1 <sys_getenvid>
  801382:	83 ec 08             	sub    $0x8,%esp
  801385:	ff 75 08             	pushl  0x8(%ebp)
  801388:	50                   	push   %eax
  801389:	e8 d6 f8 ff ff       	call   800c64 <sys_page_unmap>
	if (r < 0) {
  80138e:	83 c4 10             	add    $0x10,%esp
  801391:	85 c0                	test   %eax,%eax
  801393:	79 15                	jns    8013aa <mutex_destroy+0x33>
		panic("%e\n", r);
  801395:	50                   	push   %eax
  801396:	68 98 29 80 00       	push   $0x802998
  80139b:	68 1a 01 00 00       	push   $0x11a
  8013a0:	68 da 28 80 00       	push   $0x8028da
  8013a5:	e8 d4 ed ff ff       	call   80017e <_panic>
	}
}
  8013aa:	c9                   	leave  
  8013ab:	c3                   	ret    

008013ac <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8013ac:	55                   	push   %ebp
  8013ad:	89 e5                	mov    %esp,%ebp
  8013af:	56                   	push   %esi
  8013b0:	53                   	push   %ebx
  8013b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8013b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8013ba:	85 c0                	test   %eax,%eax
  8013bc:	75 12                	jne    8013d0 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8013be:	83 ec 0c             	sub    $0xc,%esp
  8013c1:	68 00 00 c0 ee       	push   $0xeec00000
  8013c6:	e8 c4 f9 ff ff       	call   800d8f <sys_ipc_recv>
  8013cb:	83 c4 10             	add    $0x10,%esp
  8013ce:	eb 0c                	jmp    8013dc <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8013d0:	83 ec 0c             	sub    $0xc,%esp
  8013d3:	50                   	push   %eax
  8013d4:	e8 b6 f9 ff ff       	call   800d8f <sys_ipc_recv>
  8013d9:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8013dc:	85 f6                	test   %esi,%esi
  8013de:	0f 95 c1             	setne  %cl
  8013e1:	85 db                	test   %ebx,%ebx
  8013e3:	0f 95 c2             	setne  %dl
  8013e6:	84 d1                	test   %dl,%cl
  8013e8:	74 09                	je     8013f3 <ipc_recv+0x47>
  8013ea:	89 c2                	mov    %eax,%edx
  8013ec:	c1 ea 1f             	shr    $0x1f,%edx
  8013ef:	84 d2                	test   %dl,%dl
  8013f1:	75 2d                	jne    801420 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8013f3:	85 f6                	test   %esi,%esi
  8013f5:	74 0d                	je     801404 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8013f7:	a1 04 40 80 00       	mov    0x804004,%eax
  8013fc:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  801402:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801404:	85 db                	test   %ebx,%ebx
  801406:	74 0d                	je     801415 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801408:	a1 04 40 80 00       	mov    0x804004,%eax
  80140d:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  801413:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801415:	a1 04 40 80 00       	mov    0x804004,%eax
  80141a:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  801420:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801423:	5b                   	pop    %ebx
  801424:	5e                   	pop    %esi
  801425:	5d                   	pop    %ebp
  801426:	c3                   	ret    

00801427 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801427:	55                   	push   %ebp
  801428:	89 e5                	mov    %esp,%ebp
  80142a:	57                   	push   %edi
  80142b:	56                   	push   %esi
  80142c:	53                   	push   %ebx
  80142d:	83 ec 0c             	sub    $0xc,%esp
  801430:	8b 7d 08             	mov    0x8(%ebp),%edi
  801433:	8b 75 0c             	mov    0xc(%ebp),%esi
  801436:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801439:	85 db                	test   %ebx,%ebx
  80143b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801440:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801443:	ff 75 14             	pushl  0x14(%ebp)
  801446:	53                   	push   %ebx
  801447:	56                   	push   %esi
  801448:	57                   	push   %edi
  801449:	e8 1e f9 ff ff       	call   800d6c <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80144e:	89 c2                	mov    %eax,%edx
  801450:	c1 ea 1f             	shr    $0x1f,%edx
  801453:	83 c4 10             	add    $0x10,%esp
  801456:	84 d2                	test   %dl,%dl
  801458:	74 17                	je     801471 <ipc_send+0x4a>
  80145a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80145d:	74 12                	je     801471 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  80145f:	50                   	push   %eax
  801460:	68 28 2a 80 00       	push   $0x802a28
  801465:	6a 47                	push   $0x47
  801467:	68 36 2a 80 00       	push   $0x802a36
  80146c:	e8 0d ed ff ff       	call   80017e <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801471:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801474:	75 07                	jne    80147d <ipc_send+0x56>
			sys_yield();
  801476:	e8 45 f7 ff ff       	call   800bc0 <sys_yield>
  80147b:	eb c6                	jmp    801443 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80147d:	85 c0                	test   %eax,%eax
  80147f:	75 c2                	jne    801443 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801481:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801484:	5b                   	pop    %ebx
  801485:	5e                   	pop    %esi
  801486:	5f                   	pop    %edi
  801487:	5d                   	pop    %ebp
  801488:	c3                   	ret    

00801489 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801489:	55                   	push   %ebp
  80148a:	89 e5                	mov    %esp,%ebp
  80148c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80148f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801494:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  80149a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8014a0:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  8014a6:	39 ca                	cmp    %ecx,%edx
  8014a8:	75 13                	jne    8014bd <ipc_find_env+0x34>
			return envs[i].env_id;
  8014aa:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8014b0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8014b5:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8014bb:	eb 0f                	jmp    8014cc <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8014bd:	83 c0 01             	add    $0x1,%eax
  8014c0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8014c5:	75 cd                	jne    801494 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8014c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014cc:	5d                   	pop    %ebp
  8014cd:	c3                   	ret    

008014ce <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014ce:	55                   	push   %ebp
  8014cf:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d4:	05 00 00 00 30       	add    $0x30000000,%eax
  8014d9:	c1 e8 0c             	shr    $0xc,%eax
}
  8014dc:	5d                   	pop    %ebp
  8014dd:	c3                   	ret    

008014de <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014de:	55                   	push   %ebp
  8014df:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8014e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e4:	05 00 00 00 30       	add    $0x30000000,%eax
  8014e9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8014ee:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8014f3:	5d                   	pop    %ebp
  8014f4:	c3                   	ret    

008014f5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014f5:	55                   	push   %ebp
  8014f6:	89 e5                	mov    %esp,%ebp
  8014f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014fb:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801500:	89 c2                	mov    %eax,%edx
  801502:	c1 ea 16             	shr    $0x16,%edx
  801505:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80150c:	f6 c2 01             	test   $0x1,%dl
  80150f:	74 11                	je     801522 <fd_alloc+0x2d>
  801511:	89 c2                	mov    %eax,%edx
  801513:	c1 ea 0c             	shr    $0xc,%edx
  801516:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80151d:	f6 c2 01             	test   $0x1,%dl
  801520:	75 09                	jne    80152b <fd_alloc+0x36>
			*fd_store = fd;
  801522:	89 01                	mov    %eax,(%ecx)
			return 0;
  801524:	b8 00 00 00 00       	mov    $0x0,%eax
  801529:	eb 17                	jmp    801542 <fd_alloc+0x4d>
  80152b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801530:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801535:	75 c9                	jne    801500 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801537:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80153d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801542:	5d                   	pop    %ebp
  801543:	c3                   	ret    

00801544 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801544:	55                   	push   %ebp
  801545:	89 e5                	mov    %esp,%ebp
  801547:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80154a:	83 f8 1f             	cmp    $0x1f,%eax
  80154d:	77 36                	ja     801585 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80154f:	c1 e0 0c             	shl    $0xc,%eax
  801552:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801557:	89 c2                	mov    %eax,%edx
  801559:	c1 ea 16             	shr    $0x16,%edx
  80155c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801563:	f6 c2 01             	test   $0x1,%dl
  801566:	74 24                	je     80158c <fd_lookup+0x48>
  801568:	89 c2                	mov    %eax,%edx
  80156a:	c1 ea 0c             	shr    $0xc,%edx
  80156d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801574:	f6 c2 01             	test   $0x1,%dl
  801577:	74 1a                	je     801593 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801579:	8b 55 0c             	mov    0xc(%ebp),%edx
  80157c:	89 02                	mov    %eax,(%edx)
	return 0;
  80157e:	b8 00 00 00 00       	mov    $0x0,%eax
  801583:	eb 13                	jmp    801598 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801585:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80158a:	eb 0c                	jmp    801598 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80158c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801591:	eb 05                	jmp    801598 <fd_lookup+0x54>
  801593:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801598:	5d                   	pop    %ebp
  801599:	c3                   	ret    

0080159a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80159a:	55                   	push   %ebp
  80159b:	89 e5                	mov    %esp,%ebp
  80159d:	83 ec 08             	sub    $0x8,%esp
  8015a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015a3:	ba c0 2a 80 00       	mov    $0x802ac0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8015a8:	eb 13                	jmp    8015bd <dev_lookup+0x23>
  8015aa:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8015ad:	39 08                	cmp    %ecx,(%eax)
  8015af:	75 0c                	jne    8015bd <dev_lookup+0x23>
			*dev = devtab[i];
  8015b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015b4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8015b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8015bb:	eb 31                	jmp    8015ee <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015bd:	8b 02                	mov    (%edx),%eax
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	75 e7                	jne    8015aa <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015c3:	a1 04 40 80 00       	mov    0x804004,%eax
  8015c8:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8015ce:	83 ec 04             	sub    $0x4,%esp
  8015d1:	51                   	push   %ecx
  8015d2:	50                   	push   %eax
  8015d3:	68 40 2a 80 00       	push   $0x802a40
  8015d8:	e8 7a ec ff ff       	call   800257 <cprintf>
	*dev = 0;
  8015dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015e0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8015e6:	83 c4 10             	add    $0x10,%esp
  8015e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015ee:	c9                   	leave  
  8015ef:	c3                   	ret    

008015f0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	56                   	push   %esi
  8015f4:	53                   	push   %ebx
  8015f5:	83 ec 10             	sub    $0x10,%esp
  8015f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8015fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801601:	50                   	push   %eax
  801602:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801608:	c1 e8 0c             	shr    $0xc,%eax
  80160b:	50                   	push   %eax
  80160c:	e8 33 ff ff ff       	call   801544 <fd_lookup>
  801611:	83 c4 08             	add    $0x8,%esp
  801614:	85 c0                	test   %eax,%eax
  801616:	78 05                	js     80161d <fd_close+0x2d>
	    || fd != fd2)
  801618:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80161b:	74 0c                	je     801629 <fd_close+0x39>
		return (must_exist ? r : 0);
  80161d:	84 db                	test   %bl,%bl
  80161f:	ba 00 00 00 00       	mov    $0x0,%edx
  801624:	0f 44 c2             	cmove  %edx,%eax
  801627:	eb 41                	jmp    80166a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801629:	83 ec 08             	sub    $0x8,%esp
  80162c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80162f:	50                   	push   %eax
  801630:	ff 36                	pushl  (%esi)
  801632:	e8 63 ff ff ff       	call   80159a <dev_lookup>
  801637:	89 c3                	mov    %eax,%ebx
  801639:	83 c4 10             	add    $0x10,%esp
  80163c:	85 c0                	test   %eax,%eax
  80163e:	78 1a                	js     80165a <fd_close+0x6a>
		if (dev->dev_close)
  801640:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801643:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801646:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80164b:	85 c0                	test   %eax,%eax
  80164d:	74 0b                	je     80165a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80164f:	83 ec 0c             	sub    $0xc,%esp
  801652:	56                   	push   %esi
  801653:	ff d0                	call   *%eax
  801655:	89 c3                	mov    %eax,%ebx
  801657:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80165a:	83 ec 08             	sub    $0x8,%esp
  80165d:	56                   	push   %esi
  80165e:	6a 00                	push   $0x0
  801660:	e8 ff f5 ff ff       	call   800c64 <sys_page_unmap>
	return r;
  801665:	83 c4 10             	add    $0x10,%esp
  801668:	89 d8                	mov    %ebx,%eax
}
  80166a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80166d:	5b                   	pop    %ebx
  80166e:	5e                   	pop    %esi
  80166f:	5d                   	pop    %ebp
  801670:	c3                   	ret    

00801671 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801677:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167a:	50                   	push   %eax
  80167b:	ff 75 08             	pushl  0x8(%ebp)
  80167e:	e8 c1 fe ff ff       	call   801544 <fd_lookup>
  801683:	83 c4 08             	add    $0x8,%esp
  801686:	85 c0                	test   %eax,%eax
  801688:	78 10                	js     80169a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80168a:	83 ec 08             	sub    $0x8,%esp
  80168d:	6a 01                	push   $0x1
  80168f:	ff 75 f4             	pushl  -0xc(%ebp)
  801692:	e8 59 ff ff ff       	call   8015f0 <fd_close>
  801697:	83 c4 10             	add    $0x10,%esp
}
  80169a:	c9                   	leave  
  80169b:	c3                   	ret    

0080169c <close_all>:

void
close_all(void)
{
  80169c:	55                   	push   %ebp
  80169d:	89 e5                	mov    %esp,%ebp
  80169f:	53                   	push   %ebx
  8016a0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016a3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016a8:	83 ec 0c             	sub    $0xc,%esp
  8016ab:	53                   	push   %ebx
  8016ac:	e8 c0 ff ff ff       	call   801671 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016b1:	83 c3 01             	add    $0x1,%ebx
  8016b4:	83 c4 10             	add    $0x10,%esp
  8016b7:	83 fb 20             	cmp    $0x20,%ebx
  8016ba:	75 ec                	jne    8016a8 <close_all+0xc>
		close(i);
}
  8016bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016bf:	c9                   	leave  
  8016c0:	c3                   	ret    

008016c1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	57                   	push   %edi
  8016c5:	56                   	push   %esi
  8016c6:	53                   	push   %ebx
  8016c7:	83 ec 2c             	sub    $0x2c,%esp
  8016ca:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016cd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016d0:	50                   	push   %eax
  8016d1:	ff 75 08             	pushl  0x8(%ebp)
  8016d4:	e8 6b fe ff ff       	call   801544 <fd_lookup>
  8016d9:	83 c4 08             	add    $0x8,%esp
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	0f 88 c1 00 00 00    	js     8017a5 <dup+0xe4>
		return r;
	close(newfdnum);
  8016e4:	83 ec 0c             	sub    $0xc,%esp
  8016e7:	56                   	push   %esi
  8016e8:	e8 84 ff ff ff       	call   801671 <close>

	newfd = INDEX2FD(newfdnum);
  8016ed:	89 f3                	mov    %esi,%ebx
  8016ef:	c1 e3 0c             	shl    $0xc,%ebx
  8016f2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8016f8:	83 c4 04             	add    $0x4,%esp
  8016fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016fe:	e8 db fd ff ff       	call   8014de <fd2data>
  801703:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801705:	89 1c 24             	mov    %ebx,(%esp)
  801708:	e8 d1 fd ff ff       	call   8014de <fd2data>
  80170d:	83 c4 10             	add    $0x10,%esp
  801710:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801713:	89 f8                	mov    %edi,%eax
  801715:	c1 e8 16             	shr    $0x16,%eax
  801718:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80171f:	a8 01                	test   $0x1,%al
  801721:	74 37                	je     80175a <dup+0x99>
  801723:	89 f8                	mov    %edi,%eax
  801725:	c1 e8 0c             	shr    $0xc,%eax
  801728:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80172f:	f6 c2 01             	test   $0x1,%dl
  801732:	74 26                	je     80175a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801734:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80173b:	83 ec 0c             	sub    $0xc,%esp
  80173e:	25 07 0e 00 00       	and    $0xe07,%eax
  801743:	50                   	push   %eax
  801744:	ff 75 d4             	pushl  -0x2c(%ebp)
  801747:	6a 00                	push   $0x0
  801749:	57                   	push   %edi
  80174a:	6a 00                	push   $0x0
  80174c:	e8 d1 f4 ff ff       	call   800c22 <sys_page_map>
  801751:	89 c7                	mov    %eax,%edi
  801753:	83 c4 20             	add    $0x20,%esp
  801756:	85 c0                	test   %eax,%eax
  801758:	78 2e                	js     801788 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80175a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80175d:	89 d0                	mov    %edx,%eax
  80175f:	c1 e8 0c             	shr    $0xc,%eax
  801762:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801769:	83 ec 0c             	sub    $0xc,%esp
  80176c:	25 07 0e 00 00       	and    $0xe07,%eax
  801771:	50                   	push   %eax
  801772:	53                   	push   %ebx
  801773:	6a 00                	push   $0x0
  801775:	52                   	push   %edx
  801776:	6a 00                	push   $0x0
  801778:	e8 a5 f4 ff ff       	call   800c22 <sys_page_map>
  80177d:	89 c7                	mov    %eax,%edi
  80177f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801782:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801784:	85 ff                	test   %edi,%edi
  801786:	79 1d                	jns    8017a5 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801788:	83 ec 08             	sub    $0x8,%esp
  80178b:	53                   	push   %ebx
  80178c:	6a 00                	push   $0x0
  80178e:	e8 d1 f4 ff ff       	call   800c64 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801793:	83 c4 08             	add    $0x8,%esp
  801796:	ff 75 d4             	pushl  -0x2c(%ebp)
  801799:	6a 00                	push   $0x0
  80179b:	e8 c4 f4 ff ff       	call   800c64 <sys_page_unmap>
	return r;
  8017a0:	83 c4 10             	add    $0x10,%esp
  8017a3:	89 f8                	mov    %edi,%eax
}
  8017a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017a8:	5b                   	pop    %ebx
  8017a9:	5e                   	pop    %esi
  8017aa:	5f                   	pop    %edi
  8017ab:	5d                   	pop    %ebp
  8017ac:	c3                   	ret    

008017ad <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017ad:	55                   	push   %ebp
  8017ae:	89 e5                	mov    %esp,%ebp
  8017b0:	53                   	push   %ebx
  8017b1:	83 ec 14             	sub    $0x14,%esp
  8017b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017ba:	50                   	push   %eax
  8017bb:	53                   	push   %ebx
  8017bc:	e8 83 fd ff ff       	call   801544 <fd_lookup>
  8017c1:	83 c4 08             	add    $0x8,%esp
  8017c4:	89 c2                	mov    %eax,%edx
  8017c6:	85 c0                	test   %eax,%eax
  8017c8:	78 70                	js     80183a <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ca:	83 ec 08             	sub    $0x8,%esp
  8017cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d0:	50                   	push   %eax
  8017d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d4:	ff 30                	pushl  (%eax)
  8017d6:	e8 bf fd ff ff       	call   80159a <dev_lookup>
  8017db:	83 c4 10             	add    $0x10,%esp
  8017de:	85 c0                	test   %eax,%eax
  8017e0:	78 4f                	js     801831 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017e2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017e5:	8b 42 08             	mov    0x8(%edx),%eax
  8017e8:	83 e0 03             	and    $0x3,%eax
  8017eb:	83 f8 01             	cmp    $0x1,%eax
  8017ee:	75 24                	jne    801814 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017f0:	a1 04 40 80 00       	mov    0x804004,%eax
  8017f5:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8017fb:	83 ec 04             	sub    $0x4,%esp
  8017fe:	53                   	push   %ebx
  8017ff:	50                   	push   %eax
  801800:	68 84 2a 80 00       	push   $0x802a84
  801805:	e8 4d ea ff ff       	call   800257 <cprintf>
		return -E_INVAL;
  80180a:	83 c4 10             	add    $0x10,%esp
  80180d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801812:	eb 26                	jmp    80183a <read+0x8d>
	}
	if (!dev->dev_read)
  801814:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801817:	8b 40 08             	mov    0x8(%eax),%eax
  80181a:	85 c0                	test   %eax,%eax
  80181c:	74 17                	je     801835 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80181e:	83 ec 04             	sub    $0x4,%esp
  801821:	ff 75 10             	pushl  0x10(%ebp)
  801824:	ff 75 0c             	pushl  0xc(%ebp)
  801827:	52                   	push   %edx
  801828:	ff d0                	call   *%eax
  80182a:	89 c2                	mov    %eax,%edx
  80182c:	83 c4 10             	add    $0x10,%esp
  80182f:	eb 09                	jmp    80183a <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801831:	89 c2                	mov    %eax,%edx
  801833:	eb 05                	jmp    80183a <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801835:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80183a:	89 d0                	mov    %edx,%eax
  80183c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80183f:	c9                   	leave  
  801840:	c3                   	ret    

00801841 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801841:	55                   	push   %ebp
  801842:	89 e5                	mov    %esp,%ebp
  801844:	57                   	push   %edi
  801845:	56                   	push   %esi
  801846:	53                   	push   %ebx
  801847:	83 ec 0c             	sub    $0xc,%esp
  80184a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80184d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801850:	bb 00 00 00 00       	mov    $0x0,%ebx
  801855:	eb 21                	jmp    801878 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801857:	83 ec 04             	sub    $0x4,%esp
  80185a:	89 f0                	mov    %esi,%eax
  80185c:	29 d8                	sub    %ebx,%eax
  80185e:	50                   	push   %eax
  80185f:	89 d8                	mov    %ebx,%eax
  801861:	03 45 0c             	add    0xc(%ebp),%eax
  801864:	50                   	push   %eax
  801865:	57                   	push   %edi
  801866:	e8 42 ff ff ff       	call   8017ad <read>
		if (m < 0)
  80186b:	83 c4 10             	add    $0x10,%esp
  80186e:	85 c0                	test   %eax,%eax
  801870:	78 10                	js     801882 <readn+0x41>
			return m;
		if (m == 0)
  801872:	85 c0                	test   %eax,%eax
  801874:	74 0a                	je     801880 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801876:	01 c3                	add    %eax,%ebx
  801878:	39 f3                	cmp    %esi,%ebx
  80187a:	72 db                	jb     801857 <readn+0x16>
  80187c:	89 d8                	mov    %ebx,%eax
  80187e:	eb 02                	jmp    801882 <readn+0x41>
  801880:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801882:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801885:	5b                   	pop    %ebx
  801886:	5e                   	pop    %esi
  801887:	5f                   	pop    %edi
  801888:	5d                   	pop    %ebp
  801889:	c3                   	ret    

0080188a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80188a:	55                   	push   %ebp
  80188b:	89 e5                	mov    %esp,%ebp
  80188d:	53                   	push   %ebx
  80188e:	83 ec 14             	sub    $0x14,%esp
  801891:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801894:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801897:	50                   	push   %eax
  801898:	53                   	push   %ebx
  801899:	e8 a6 fc ff ff       	call   801544 <fd_lookup>
  80189e:	83 c4 08             	add    $0x8,%esp
  8018a1:	89 c2                	mov    %eax,%edx
  8018a3:	85 c0                	test   %eax,%eax
  8018a5:	78 6b                	js     801912 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a7:	83 ec 08             	sub    $0x8,%esp
  8018aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ad:	50                   	push   %eax
  8018ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b1:	ff 30                	pushl  (%eax)
  8018b3:	e8 e2 fc ff ff       	call   80159a <dev_lookup>
  8018b8:	83 c4 10             	add    $0x10,%esp
  8018bb:	85 c0                	test   %eax,%eax
  8018bd:	78 4a                	js     801909 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018c6:	75 24                	jne    8018ec <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018c8:	a1 04 40 80 00       	mov    0x804004,%eax
  8018cd:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8018d3:	83 ec 04             	sub    $0x4,%esp
  8018d6:	53                   	push   %ebx
  8018d7:	50                   	push   %eax
  8018d8:	68 a0 2a 80 00       	push   $0x802aa0
  8018dd:	e8 75 e9 ff ff       	call   800257 <cprintf>
		return -E_INVAL;
  8018e2:	83 c4 10             	add    $0x10,%esp
  8018e5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018ea:	eb 26                	jmp    801912 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ef:	8b 52 0c             	mov    0xc(%edx),%edx
  8018f2:	85 d2                	test   %edx,%edx
  8018f4:	74 17                	je     80190d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018f6:	83 ec 04             	sub    $0x4,%esp
  8018f9:	ff 75 10             	pushl  0x10(%ebp)
  8018fc:	ff 75 0c             	pushl  0xc(%ebp)
  8018ff:	50                   	push   %eax
  801900:	ff d2                	call   *%edx
  801902:	89 c2                	mov    %eax,%edx
  801904:	83 c4 10             	add    $0x10,%esp
  801907:	eb 09                	jmp    801912 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801909:	89 c2                	mov    %eax,%edx
  80190b:	eb 05                	jmp    801912 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80190d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801912:	89 d0                	mov    %edx,%eax
  801914:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801917:	c9                   	leave  
  801918:	c3                   	ret    

00801919 <seek>:

int
seek(int fdnum, off_t offset)
{
  801919:	55                   	push   %ebp
  80191a:	89 e5                	mov    %esp,%ebp
  80191c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80191f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801922:	50                   	push   %eax
  801923:	ff 75 08             	pushl  0x8(%ebp)
  801926:	e8 19 fc ff ff       	call   801544 <fd_lookup>
  80192b:	83 c4 08             	add    $0x8,%esp
  80192e:	85 c0                	test   %eax,%eax
  801930:	78 0e                	js     801940 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801932:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801935:	8b 55 0c             	mov    0xc(%ebp),%edx
  801938:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80193b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801940:	c9                   	leave  
  801941:	c3                   	ret    

00801942 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801942:	55                   	push   %ebp
  801943:	89 e5                	mov    %esp,%ebp
  801945:	53                   	push   %ebx
  801946:	83 ec 14             	sub    $0x14,%esp
  801949:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80194c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80194f:	50                   	push   %eax
  801950:	53                   	push   %ebx
  801951:	e8 ee fb ff ff       	call   801544 <fd_lookup>
  801956:	83 c4 08             	add    $0x8,%esp
  801959:	89 c2                	mov    %eax,%edx
  80195b:	85 c0                	test   %eax,%eax
  80195d:	78 68                	js     8019c7 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80195f:	83 ec 08             	sub    $0x8,%esp
  801962:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801965:	50                   	push   %eax
  801966:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801969:	ff 30                	pushl  (%eax)
  80196b:	e8 2a fc ff ff       	call   80159a <dev_lookup>
  801970:	83 c4 10             	add    $0x10,%esp
  801973:	85 c0                	test   %eax,%eax
  801975:	78 47                	js     8019be <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801977:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80197a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80197e:	75 24                	jne    8019a4 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801980:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801985:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80198b:	83 ec 04             	sub    $0x4,%esp
  80198e:	53                   	push   %ebx
  80198f:	50                   	push   %eax
  801990:	68 60 2a 80 00       	push   $0x802a60
  801995:	e8 bd e8 ff ff       	call   800257 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80199a:	83 c4 10             	add    $0x10,%esp
  80199d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8019a2:	eb 23                	jmp    8019c7 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  8019a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019a7:	8b 52 18             	mov    0x18(%edx),%edx
  8019aa:	85 d2                	test   %edx,%edx
  8019ac:	74 14                	je     8019c2 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019ae:	83 ec 08             	sub    $0x8,%esp
  8019b1:	ff 75 0c             	pushl  0xc(%ebp)
  8019b4:	50                   	push   %eax
  8019b5:	ff d2                	call   *%edx
  8019b7:	89 c2                	mov    %eax,%edx
  8019b9:	83 c4 10             	add    $0x10,%esp
  8019bc:	eb 09                	jmp    8019c7 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019be:	89 c2                	mov    %eax,%edx
  8019c0:	eb 05                	jmp    8019c7 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8019c2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8019c7:	89 d0                	mov    %edx,%eax
  8019c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019cc:	c9                   	leave  
  8019cd:	c3                   	ret    

008019ce <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019ce:	55                   	push   %ebp
  8019cf:	89 e5                	mov    %esp,%ebp
  8019d1:	53                   	push   %ebx
  8019d2:	83 ec 14             	sub    $0x14,%esp
  8019d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019db:	50                   	push   %eax
  8019dc:	ff 75 08             	pushl  0x8(%ebp)
  8019df:	e8 60 fb ff ff       	call   801544 <fd_lookup>
  8019e4:	83 c4 08             	add    $0x8,%esp
  8019e7:	89 c2                	mov    %eax,%edx
  8019e9:	85 c0                	test   %eax,%eax
  8019eb:	78 58                	js     801a45 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019ed:	83 ec 08             	sub    $0x8,%esp
  8019f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f3:	50                   	push   %eax
  8019f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019f7:	ff 30                	pushl  (%eax)
  8019f9:	e8 9c fb ff ff       	call   80159a <dev_lookup>
  8019fe:	83 c4 10             	add    $0x10,%esp
  801a01:	85 c0                	test   %eax,%eax
  801a03:	78 37                	js     801a3c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a08:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a0c:	74 32                	je     801a40 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a0e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a11:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a18:	00 00 00 
	stat->st_isdir = 0;
  801a1b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a22:	00 00 00 
	stat->st_dev = dev;
  801a25:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a2b:	83 ec 08             	sub    $0x8,%esp
  801a2e:	53                   	push   %ebx
  801a2f:	ff 75 f0             	pushl  -0x10(%ebp)
  801a32:	ff 50 14             	call   *0x14(%eax)
  801a35:	89 c2                	mov    %eax,%edx
  801a37:	83 c4 10             	add    $0x10,%esp
  801a3a:	eb 09                	jmp    801a45 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a3c:	89 c2                	mov    %eax,%edx
  801a3e:	eb 05                	jmp    801a45 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a40:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a45:	89 d0                	mov    %edx,%eax
  801a47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a4a:	c9                   	leave  
  801a4b:	c3                   	ret    

00801a4c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a4c:	55                   	push   %ebp
  801a4d:	89 e5                	mov    %esp,%ebp
  801a4f:	56                   	push   %esi
  801a50:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a51:	83 ec 08             	sub    $0x8,%esp
  801a54:	6a 00                	push   $0x0
  801a56:	ff 75 08             	pushl  0x8(%ebp)
  801a59:	e8 e3 01 00 00       	call   801c41 <open>
  801a5e:	89 c3                	mov    %eax,%ebx
  801a60:	83 c4 10             	add    $0x10,%esp
  801a63:	85 c0                	test   %eax,%eax
  801a65:	78 1b                	js     801a82 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a67:	83 ec 08             	sub    $0x8,%esp
  801a6a:	ff 75 0c             	pushl  0xc(%ebp)
  801a6d:	50                   	push   %eax
  801a6e:	e8 5b ff ff ff       	call   8019ce <fstat>
  801a73:	89 c6                	mov    %eax,%esi
	close(fd);
  801a75:	89 1c 24             	mov    %ebx,(%esp)
  801a78:	e8 f4 fb ff ff       	call   801671 <close>
	return r;
  801a7d:	83 c4 10             	add    $0x10,%esp
  801a80:	89 f0                	mov    %esi,%eax
}
  801a82:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a85:	5b                   	pop    %ebx
  801a86:	5e                   	pop    %esi
  801a87:	5d                   	pop    %ebp
  801a88:	c3                   	ret    

00801a89 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	56                   	push   %esi
  801a8d:	53                   	push   %ebx
  801a8e:	89 c6                	mov    %eax,%esi
  801a90:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a92:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a99:	75 12                	jne    801aad <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a9b:	83 ec 0c             	sub    $0xc,%esp
  801a9e:	6a 01                	push   $0x1
  801aa0:	e8 e4 f9 ff ff       	call   801489 <ipc_find_env>
  801aa5:	a3 00 40 80 00       	mov    %eax,0x804000
  801aaa:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801aad:	6a 07                	push   $0x7
  801aaf:	68 00 50 80 00       	push   $0x805000
  801ab4:	56                   	push   %esi
  801ab5:	ff 35 00 40 80 00    	pushl  0x804000
  801abb:	e8 67 f9 ff ff       	call   801427 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801ac0:	83 c4 0c             	add    $0xc,%esp
  801ac3:	6a 00                	push   $0x0
  801ac5:	53                   	push   %ebx
  801ac6:	6a 00                	push   $0x0
  801ac8:	e8 df f8 ff ff       	call   8013ac <ipc_recv>
}
  801acd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad0:	5b                   	pop    %ebx
  801ad1:	5e                   	pop    %esi
  801ad2:	5d                   	pop    %ebp
  801ad3:	c3                   	ret    

00801ad4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ad4:	55                   	push   %ebp
  801ad5:	89 e5                	mov    %esp,%ebp
  801ad7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801ada:	8b 45 08             	mov    0x8(%ebp),%eax
  801add:	8b 40 0c             	mov    0xc(%eax),%eax
  801ae0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801ae5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801aed:	ba 00 00 00 00       	mov    $0x0,%edx
  801af2:	b8 02 00 00 00       	mov    $0x2,%eax
  801af7:	e8 8d ff ff ff       	call   801a89 <fsipc>
}
  801afc:	c9                   	leave  
  801afd:	c3                   	ret    

00801afe <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801afe:	55                   	push   %ebp
  801aff:	89 e5                	mov    %esp,%ebp
  801b01:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b04:	8b 45 08             	mov    0x8(%ebp),%eax
  801b07:	8b 40 0c             	mov    0xc(%eax),%eax
  801b0a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801b0f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b14:	b8 06 00 00 00       	mov    $0x6,%eax
  801b19:	e8 6b ff ff ff       	call   801a89 <fsipc>
}
  801b1e:	c9                   	leave  
  801b1f:	c3                   	ret    

00801b20 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	53                   	push   %ebx
  801b24:	83 ec 04             	sub    $0x4,%esp
  801b27:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2d:	8b 40 0c             	mov    0xc(%eax),%eax
  801b30:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b35:	ba 00 00 00 00       	mov    $0x0,%edx
  801b3a:	b8 05 00 00 00       	mov    $0x5,%eax
  801b3f:	e8 45 ff ff ff       	call   801a89 <fsipc>
  801b44:	85 c0                	test   %eax,%eax
  801b46:	78 2c                	js     801b74 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b48:	83 ec 08             	sub    $0x8,%esp
  801b4b:	68 00 50 80 00       	push   $0x805000
  801b50:	53                   	push   %ebx
  801b51:	e8 86 ec ff ff       	call   8007dc <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b56:	a1 80 50 80 00       	mov    0x805080,%eax
  801b5b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b61:	a1 84 50 80 00       	mov    0x805084,%eax
  801b66:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b6c:	83 c4 10             	add    $0x10,%esp
  801b6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b77:	c9                   	leave  
  801b78:	c3                   	ret    

00801b79 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b79:	55                   	push   %ebp
  801b7a:	89 e5                	mov    %esp,%ebp
  801b7c:	83 ec 0c             	sub    $0xc,%esp
  801b7f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b82:	8b 55 08             	mov    0x8(%ebp),%edx
  801b85:	8b 52 0c             	mov    0xc(%edx),%edx
  801b88:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801b8e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b93:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801b98:	0f 47 c2             	cmova  %edx,%eax
  801b9b:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801ba0:	50                   	push   %eax
  801ba1:	ff 75 0c             	pushl  0xc(%ebp)
  801ba4:	68 08 50 80 00       	push   $0x805008
  801ba9:	e8 c0 ed ff ff       	call   80096e <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801bae:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb3:	b8 04 00 00 00       	mov    $0x4,%eax
  801bb8:	e8 cc fe ff ff       	call   801a89 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801bbd:	c9                   	leave  
  801bbe:	c3                   	ret    

00801bbf <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801bbf:	55                   	push   %ebp
  801bc0:	89 e5                	mov    %esp,%ebp
  801bc2:	56                   	push   %esi
  801bc3:	53                   	push   %ebx
  801bc4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801bc7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bca:	8b 40 0c             	mov    0xc(%eax),%eax
  801bcd:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801bd2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801bd8:	ba 00 00 00 00       	mov    $0x0,%edx
  801bdd:	b8 03 00 00 00       	mov    $0x3,%eax
  801be2:	e8 a2 fe ff ff       	call   801a89 <fsipc>
  801be7:	89 c3                	mov    %eax,%ebx
  801be9:	85 c0                	test   %eax,%eax
  801beb:	78 4b                	js     801c38 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801bed:	39 c6                	cmp    %eax,%esi
  801bef:	73 16                	jae    801c07 <devfile_read+0x48>
  801bf1:	68 d0 2a 80 00       	push   $0x802ad0
  801bf6:	68 d7 2a 80 00       	push   $0x802ad7
  801bfb:	6a 7c                	push   $0x7c
  801bfd:	68 ec 2a 80 00       	push   $0x802aec
  801c02:	e8 77 e5 ff ff       	call   80017e <_panic>
	assert(r <= PGSIZE);
  801c07:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c0c:	7e 16                	jle    801c24 <devfile_read+0x65>
  801c0e:	68 f7 2a 80 00       	push   $0x802af7
  801c13:	68 d7 2a 80 00       	push   $0x802ad7
  801c18:	6a 7d                	push   $0x7d
  801c1a:	68 ec 2a 80 00       	push   $0x802aec
  801c1f:	e8 5a e5 ff ff       	call   80017e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c24:	83 ec 04             	sub    $0x4,%esp
  801c27:	50                   	push   %eax
  801c28:	68 00 50 80 00       	push   $0x805000
  801c2d:	ff 75 0c             	pushl  0xc(%ebp)
  801c30:	e8 39 ed ff ff       	call   80096e <memmove>
	return r;
  801c35:	83 c4 10             	add    $0x10,%esp
}
  801c38:	89 d8                	mov    %ebx,%eax
  801c3a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c3d:	5b                   	pop    %ebx
  801c3e:	5e                   	pop    %esi
  801c3f:	5d                   	pop    %ebp
  801c40:	c3                   	ret    

00801c41 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c41:	55                   	push   %ebp
  801c42:	89 e5                	mov    %esp,%ebp
  801c44:	53                   	push   %ebx
  801c45:	83 ec 20             	sub    $0x20,%esp
  801c48:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c4b:	53                   	push   %ebx
  801c4c:	e8 52 eb ff ff       	call   8007a3 <strlen>
  801c51:	83 c4 10             	add    $0x10,%esp
  801c54:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c59:	7f 67                	jg     801cc2 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c5b:	83 ec 0c             	sub    $0xc,%esp
  801c5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c61:	50                   	push   %eax
  801c62:	e8 8e f8 ff ff       	call   8014f5 <fd_alloc>
  801c67:	83 c4 10             	add    $0x10,%esp
		return r;
  801c6a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c6c:	85 c0                	test   %eax,%eax
  801c6e:	78 57                	js     801cc7 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c70:	83 ec 08             	sub    $0x8,%esp
  801c73:	53                   	push   %ebx
  801c74:	68 00 50 80 00       	push   $0x805000
  801c79:	e8 5e eb ff ff       	call   8007dc <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c81:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c86:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c89:	b8 01 00 00 00       	mov    $0x1,%eax
  801c8e:	e8 f6 fd ff ff       	call   801a89 <fsipc>
  801c93:	89 c3                	mov    %eax,%ebx
  801c95:	83 c4 10             	add    $0x10,%esp
  801c98:	85 c0                	test   %eax,%eax
  801c9a:	79 14                	jns    801cb0 <open+0x6f>
		fd_close(fd, 0);
  801c9c:	83 ec 08             	sub    $0x8,%esp
  801c9f:	6a 00                	push   $0x0
  801ca1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca4:	e8 47 f9 ff ff       	call   8015f0 <fd_close>
		return r;
  801ca9:	83 c4 10             	add    $0x10,%esp
  801cac:	89 da                	mov    %ebx,%edx
  801cae:	eb 17                	jmp    801cc7 <open+0x86>
	}

	return fd2num(fd);
  801cb0:	83 ec 0c             	sub    $0xc,%esp
  801cb3:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb6:	e8 13 f8 ff ff       	call   8014ce <fd2num>
  801cbb:	89 c2                	mov    %eax,%edx
  801cbd:	83 c4 10             	add    $0x10,%esp
  801cc0:	eb 05                	jmp    801cc7 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801cc2:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801cc7:	89 d0                	mov    %edx,%eax
  801cc9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ccc:	c9                   	leave  
  801ccd:	c3                   	ret    

00801cce <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801cce:	55                   	push   %ebp
  801ccf:	89 e5                	mov    %esp,%ebp
  801cd1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801cd4:	ba 00 00 00 00       	mov    $0x0,%edx
  801cd9:	b8 08 00 00 00       	mov    $0x8,%eax
  801cde:	e8 a6 fd ff ff       	call   801a89 <fsipc>
}
  801ce3:	c9                   	leave  
  801ce4:	c3                   	ret    

00801ce5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ce5:	55                   	push   %ebp
  801ce6:	89 e5                	mov    %esp,%ebp
  801ce8:	56                   	push   %esi
  801ce9:	53                   	push   %ebx
  801cea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ced:	83 ec 0c             	sub    $0xc,%esp
  801cf0:	ff 75 08             	pushl  0x8(%ebp)
  801cf3:	e8 e6 f7 ff ff       	call   8014de <fd2data>
  801cf8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801cfa:	83 c4 08             	add    $0x8,%esp
  801cfd:	68 03 2b 80 00       	push   $0x802b03
  801d02:	53                   	push   %ebx
  801d03:	e8 d4 ea ff ff       	call   8007dc <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d08:	8b 46 04             	mov    0x4(%esi),%eax
  801d0b:	2b 06                	sub    (%esi),%eax
  801d0d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d13:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d1a:	00 00 00 
	stat->st_dev = &devpipe;
  801d1d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801d24:	30 80 00 
	return 0;
}
  801d27:	b8 00 00 00 00       	mov    $0x0,%eax
  801d2c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d2f:	5b                   	pop    %ebx
  801d30:	5e                   	pop    %esi
  801d31:	5d                   	pop    %ebp
  801d32:	c3                   	ret    

00801d33 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d33:	55                   	push   %ebp
  801d34:	89 e5                	mov    %esp,%ebp
  801d36:	53                   	push   %ebx
  801d37:	83 ec 0c             	sub    $0xc,%esp
  801d3a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d3d:	53                   	push   %ebx
  801d3e:	6a 00                	push   $0x0
  801d40:	e8 1f ef ff ff       	call   800c64 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d45:	89 1c 24             	mov    %ebx,(%esp)
  801d48:	e8 91 f7 ff ff       	call   8014de <fd2data>
  801d4d:	83 c4 08             	add    $0x8,%esp
  801d50:	50                   	push   %eax
  801d51:	6a 00                	push   $0x0
  801d53:	e8 0c ef ff ff       	call   800c64 <sys_page_unmap>
}
  801d58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d5b:	c9                   	leave  
  801d5c:	c3                   	ret    

00801d5d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d5d:	55                   	push   %ebp
  801d5e:	89 e5                	mov    %esp,%ebp
  801d60:	57                   	push   %edi
  801d61:	56                   	push   %esi
  801d62:	53                   	push   %ebx
  801d63:	83 ec 1c             	sub    $0x1c,%esp
  801d66:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d69:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d6b:	a1 04 40 80 00       	mov    0x804004,%eax
  801d70:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d76:	83 ec 0c             	sub    $0xc,%esp
  801d79:	ff 75 e0             	pushl  -0x20(%ebp)
  801d7c:	e8 db 04 00 00       	call   80225c <pageref>
  801d81:	89 c3                	mov    %eax,%ebx
  801d83:	89 3c 24             	mov    %edi,(%esp)
  801d86:	e8 d1 04 00 00       	call   80225c <pageref>
  801d8b:	83 c4 10             	add    $0x10,%esp
  801d8e:	39 c3                	cmp    %eax,%ebx
  801d90:	0f 94 c1             	sete   %cl
  801d93:	0f b6 c9             	movzbl %cl,%ecx
  801d96:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d99:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d9f:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801da5:	39 ce                	cmp    %ecx,%esi
  801da7:	74 1e                	je     801dc7 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801da9:	39 c3                	cmp    %eax,%ebx
  801dab:	75 be                	jne    801d6b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801dad:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801db3:	ff 75 e4             	pushl  -0x1c(%ebp)
  801db6:	50                   	push   %eax
  801db7:	56                   	push   %esi
  801db8:	68 0a 2b 80 00       	push   $0x802b0a
  801dbd:	e8 95 e4 ff ff       	call   800257 <cprintf>
  801dc2:	83 c4 10             	add    $0x10,%esp
  801dc5:	eb a4                	jmp    801d6b <_pipeisclosed+0xe>
	}
}
  801dc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dcd:	5b                   	pop    %ebx
  801dce:	5e                   	pop    %esi
  801dcf:	5f                   	pop    %edi
  801dd0:	5d                   	pop    %ebp
  801dd1:	c3                   	ret    

00801dd2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dd2:	55                   	push   %ebp
  801dd3:	89 e5                	mov    %esp,%ebp
  801dd5:	57                   	push   %edi
  801dd6:	56                   	push   %esi
  801dd7:	53                   	push   %ebx
  801dd8:	83 ec 28             	sub    $0x28,%esp
  801ddb:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801dde:	56                   	push   %esi
  801ddf:	e8 fa f6 ff ff       	call   8014de <fd2data>
  801de4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801de6:	83 c4 10             	add    $0x10,%esp
  801de9:	bf 00 00 00 00       	mov    $0x0,%edi
  801dee:	eb 4b                	jmp    801e3b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801df0:	89 da                	mov    %ebx,%edx
  801df2:	89 f0                	mov    %esi,%eax
  801df4:	e8 64 ff ff ff       	call   801d5d <_pipeisclosed>
  801df9:	85 c0                	test   %eax,%eax
  801dfb:	75 48                	jne    801e45 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801dfd:	e8 be ed ff ff       	call   800bc0 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e02:	8b 43 04             	mov    0x4(%ebx),%eax
  801e05:	8b 0b                	mov    (%ebx),%ecx
  801e07:	8d 51 20             	lea    0x20(%ecx),%edx
  801e0a:	39 d0                	cmp    %edx,%eax
  801e0c:	73 e2                	jae    801df0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e11:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e15:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e18:	89 c2                	mov    %eax,%edx
  801e1a:	c1 fa 1f             	sar    $0x1f,%edx
  801e1d:	89 d1                	mov    %edx,%ecx
  801e1f:	c1 e9 1b             	shr    $0x1b,%ecx
  801e22:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e25:	83 e2 1f             	and    $0x1f,%edx
  801e28:	29 ca                	sub    %ecx,%edx
  801e2a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e2e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e32:	83 c0 01             	add    $0x1,%eax
  801e35:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e38:	83 c7 01             	add    $0x1,%edi
  801e3b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e3e:	75 c2                	jne    801e02 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e40:	8b 45 10             	mov    0x10(%ebp),%eax
  801e43:	eb 05                	jmp    801e4a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e45:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e4d:	5b                   	pop    %ebx
  801e4e:	5e                   	pop    %esi
  801e4f:	5f                   	pop    %edi
  801e50:	5d                   	pop    %ebp
  801e51:	c3                   	ret    

00801e52 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e52:	55                   	push   %ebp
  801e53:	89 e5                	mov    %esp,%ebp
  801e55:	57                   	push   %edi
  801e56:	56                   	push   %esi
  801e57:	53                   	push   %ebx
  801e58:	83 ec 18             	sub    $0x18,%esp
  801e5b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e5e:	57                   	push   %edi
  801e5f:	e8 7a f6 ff ff       	call   8014de <fd2data>
  801e64:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e66:	83 c4 10             	add    $0x10,%esp
  801e69:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e6e:	eb 3d                	jmp    801ead <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e70:	85 db                	test   %ebx,%ebx
  801e72:	74 04                	je     801e78 <devpipe_read+0x26>
				return i;
  801e74:	89 d8                	mov    %ebx,%eax
  801e76:	eb 44                	jmp    801ebc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e78:	89 f2                	mov    %esi,%edx
  801e7a:	89 f8                	mov    %edi,%eax
  801e7c:	e8 dc fe ff ff       	call   801d5d <_pipeisclosed>
  801e81:	85 c0                	test   %eax,%eax
  801e83:	75 32                	jne    801eb7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e85:	e8 36 ed ff ff       	call   800bc0 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e8a:	8b 06                	mov    (%esi),%eax
  801e8c:	3b 46 04             	cmp    0x4(%esi),%eax
  801e8f:	74 df                	je     801e70 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e91:	99                   	cltd   
  801e92:	c1 ea 1b             	shr    $0x1b,%edx
  801e95:	01 d0                	add    %edx,%eax
  801e97:	83 e0 1f             	and    $0x1f,%eax
  801e9a:	29 d0                	sub    %edx,%eax
  801e9c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ea1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ea4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ea7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801eaa:	83 c3 01             	add    $0x1,%ebx
  801ead:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801eb0:	75 d8                	jne    801e8a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801eb2:	8b 45 10             	mov    0x10(%ebp),%eax
  801eb5:	eb 05                	jmp    801ebc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801eb7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ebc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ebf:	5b                   	pop    %ebx
  801ec0:	5e                   	pop    %esi
  801ec1:	5f                   	pop    %edi
  801ec2:	5d                   	pop    %ebp
  801ec3:	c3                   	ret    

00801ec4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ec4:	55                   	push   %ebp
  801ec5:	89 e5                	mov    %esp,%ebp
  801ec7:	56                   	push   %esi
  801ec8:	53                   	push   %ebx
  801ec9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ecc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ecf:	50                   	push   %eax
  801ed0:	e8 20 f6 ff ff       	call   8014f5 <fd_alloc>
  801ed5:	83 c4 10             	add    $0x10,%esp
  801ed8:	89 c2                	mov    %eax,%edx
  801eda:	85 c0                	test   %eax,%eax
  801edc:	0f 88 2c 01 00 00    	js     80200e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ee2:	83 ec 04             	sub    $0x4,%esp
  801ee5:	68 07 04 00 00       	push   $0x407
  801eea:	ff 75 f4             	pushl  -0xc(%ebp)
  801eed:	6a 00                	push   $0x0
  801eef:	e8 eb ec ff ff       	call   800bdf <sys_page_alloc>
  801ef4:	83 c4 10             	add    $0x10,%esp
  801ef7:	89 c2                	mov    %eax,%edx
  801ef9:	85 c0                	test   %eax,%eax
  801efb:	0f 88 0d 01 00 00    	js     80200e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f01:	83 ec 0c             	sub    $0xc,%esp
  801f04:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f07:	50                   	push   %eax
  801f08:	e8 e8 f5 ff ff       	call   8014f5 <fd_alloc>
  801f0d:	89 c3                	mov    %eax,%ebx
  801f0f:	83 c4 10             	add    $0x10,%esp
  801f12:	85 c0                	test   %eax,%eax
  801f14:	0f 88 e2 00 00 00    	js     801ffc <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f1a:	83 ec 04             	sub    $0x4,%esp
  801f1d:	68 07 04 00 00       	push   $0x407
  801f22:	ff 75 f0             	pushl  -0x10(%ebp)
  801f25:	6a 00                	push   $0x0
  801f27:	e8 b3 ec ff ff       	call   800bdf <sys_page_alloc>
  801f2c:	89 c3                	mov    %eax,%ebx
  801f2e:	83 c4 10             	add    $0x10,%esp
  801f31:	85 c0                	test   %eax,%eax
  801f33:	0f 88 c3 00 00 00    	js     801ffc <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f39:	83 ec 0c             	sub    $0xc,%esp
  801f3c:	ff 75 f4             	pushl  -0xc(%ebp)
  801f3f:	e8 9a f5 ff ff       	call   8014de <fd2data>
  801f44:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f46:	83 c4 0c             	add    $0xc,%esp
  801f49:	68 07 04 00 00       	push   $0x407
  801f4e:	50                   	push   %eax
  801f4f:	6a 00                	push   $0x0
  801f51:	e8 89 ec ff ff       	call   800bdf <sys_page_alloc>
  801f56:	89 c3                	mov    %eax,%ebx
  801f58:	83 c4 10             	add    $0x10,%esp
  801f5b:	85 c0                	test   %eax,%eax
  801f5d:	0f 88 89 00 00 00    	js     801fec <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f63:	83 ec 0c             	sub    $0xc,%esp
  801f66:	ff 75 f0             	pushl  -0x10(%ebp)
  801f69:	e8 70 f5 ff ff       	call   8014de <fd2data>
  801f6e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f75:	50                   	push   %eax
  801f76:	6a 00                	push   $0x0
  801f78:	56                   	push   %esi
  801f79:	6a 00                	push   $0x0
  801f7b:	e8 a2 ec ff ff       	call   800c22 <sys_page_map>
  801f80:	89 c3                	mov    %eax,%ebx
  801f82:	83 c4 20             	add    $0x20,%esp
  801f85:	85 c0                	test   %eax,%eax
  801f87:	78 55                	js     801fde <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f89:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f92:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f97:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f9e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801fa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fa7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801fa9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fac:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801fb3:	83 ec 0c             	sub    $0xc,%esp
  801fb6:	ff 75 f4             	pushl  -0xc(%ebp)
  801fb9:	e8 10 f5 ff ff       	call   8014ce <fd2num>
  801fbe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fc1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801fc3:	83 c4 04             	add    $0x4,%esp
  801fc6:	ff 75 f0             	pushl  -0x10(%ebp)
  801fc9:	e8 00 f5 ff ff       	call   8014ce <fd2num>
  801fce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fd1:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801fd4:	83 c4 10             	add    $0x10,%esp
  801fd7:	ba 00 00 00 00       	mov    $0x0,%edx
  801fdc:	eb 30                	jmp    80200e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801fde:	83 ec 08             	sub    $0x8,%esp
  801fe1:	56                   	push   %esi
  801fe2:	6a 00                	push   $0x0
  801fe4:	e8 7b ec ff ff       	call   800c64 <sys_page_unmap>
  801fe9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801fec:	83 ec 08             	sub    $0x8,%esp
  801fef:	ff 75 f0             	pushl  -0x10(%ebp)
  801ff2:	6a 00                	push   $0x0
  801ff4:	e8 6b ec ff ff       	call   800c64 <sys_page_unmap>
  801ff9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ffc:	83 ec 08             	sub    $0x8,%esp
  801fff:	ff 75 f4             	pushl  -0xc(%ebp)
  802002:	6a 00                	push   $0x0
  802004:	e8 5b ec ff ff       	call   800c64 <sys_page_unmap>
  802009:	83 c4 10             	add    $0x10,%esp
  80200c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80200e:	89 d0                	mov    %edx,%eax
  802010:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802013:	5b                   	pop    %ebx
  802014:	5e                   	pop    %esi
  802015:	5d                   	pop    %ebp
  802016:	c3                   	ret    

00802017 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802017:	55                   	push   %ebp
  802018:	89 e5                	mov    %esp,%ebp
  80201a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80201d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802020:	50                   	push   %eax
  802021:	ff 75 08             	pushl  0x8(%ebp)
  802024:	e8 1b f5 ff ff       	call   801544 <fd_lookup>
  802029:	83 c4 10             	add    $0x10,%esp
  80202c:	85 c0                	test   %eax,%eax
  80202e:	78 18                	js     802048 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802030:	83 ec 0c             	sub    $0xc,%esp
  802033:	ff 75 f4             	pushl  -0xc(%ebp)
  802036:	e8 a3 f4 ff ff       	call   8014de <fd2data>
	return _pipeisclosed(fd, p);
  80203b:	89 c2                	mov    %eax,%edx
  80203d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802040:	e8 18 fd ff ff       	call   801d5d <_pipeisclosed>
  802045:	83 c4 10             	add    $0x10,%esp
}
  802048:	c9                   	leave  
  802049:	c3                   	ret    

0080204a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80204a:	55                   	push   %ebp
  80204b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80204d:	b8 00 00 00 00       	mov    $0x0,%eax
  802052:	5d                   	pop    %ebp
  802053:	c3                   	ret    

00802054 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802054:	55                   	push   %ebp
  802055:	89 e5                	mov    %esp,%ebp
  802057:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80205a:	68 22 2b 80 00       	push   $0x802b22
  80205f:	ff 75 0c             	pushl  0xc(%ebp)
  802062:	e8 75 e7 ff ff       	call   8007dc <strcpy>
	return 0;
}
  802067:	b8 00 00 00 00       	mov    $0x0,%eax
  80206c:	c9                   	leave  
  80206d:	c3                   	ret    

0080206e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80206e:	55                   	push   %ebp
  80206f:	89 e5                	mov    %esp,%ebp
  802071:	57                   	push   %edi
  802072:	56                   	push   %esi
  802073:	53                   	push   %ebx
  802074:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80207a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80207f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802085:	eb 2d                	jmp    8020b4 <devcons_write+0x46>
		m = n - tot;
  802087:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80208a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80208c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80208f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802094:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802097:	83 ec 04             	sub    $0x4,%esp
  80209a:	53                   	push   %ebx
  80209b:	03 45 0c             	add    0xc(%ebp),%eax
  80209e:	50                   	push   %eax
  80209f:	57                   	push   %edi
  8020a0:	e8 c9 e8 ff ff       	call   80096e <memmove>
		sys_cputs(buf, m);
  8020a5:	83 c4 08             	add    $0x8,%esp
  8020a8:	53                   	push   %ebx
  8020a9:	57                   	push   %edi
  8020aa:	e8 74 ea ff ff       	call   800b23 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020af:	01 de                	add    %ebx,%esi
  8020b1:	83 c4 10             	add    $0x10,%esp
  8020b4:	89 f0                	mov    %esi,%eax
  8020b6:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020b9:	72 cc                	jb     802087 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8020bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020be:	5b                   	pop    %ebx
  8020bf:	5e                   	pop    %esi
  8020c0:	5f                   	pop    %edi
  8020c1:	5d                   	pop    %ebp
  8020c2:	c3                   	ret    

008020c3 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020c3:	55                   	push   %ebp
  8020c4:	89 e5                	mov    %esp,%ebp
  8020c6:	83 ec 08             	sub    $0x8,%esp
  8020c9:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8020ce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020d2:	74 2a                	je     8020fe <devcons_read+0x3b>
  8020d4:	eb 05                	jmp    8020db <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8020d6:	e8 e5 ea ff ff       	call   800bc0 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8020db:	e8 61 ea ff ff       	call   800b41 <sys_cgetc>
  8020e0:	85 c0                	test   %eax,%eax
  8020e2:	74 f2                	je     8020d6 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8020e4:	85 c0                	test   %eax,%eax
  8020e6:	78 16                	js     8020fe <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8020e8:	83 f8 04             	cmp    $0x4,%eax
  8020eb:	74 0c                	je     8020f9 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8020ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020f0:	88 02                	mov    %al,(%edx)
	return 1;
  8020f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8020f7:	eb 05                	jmp    8020fe <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020f9:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020fe:	c9                   	leave  
  8020ff:	c3                   	ret    

00802100 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802100:	55                   	push   %ebp
  802101:	89 e5                	mov    %esp,%ebp
  802103:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802106:	8b 45 08             	mov    0x8(%ebp),%eax
  802109:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80210c:	6a 01                	push   $0x1
  80210e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802111:	50                   	push   %eax
  802112:	e8 0c ea ff ff       	call   800b23 <sys_cputs>
}
  802117:	83 c4 10             	add    $0x10,%esp
  80211a:	c9                   	leave  
  80211b:	c3                   	ret    

0080211c <getchar>:

int
getchar(void)
{
  80211c:	55                   	push   %ebp
  80211d:	89 e5                	mov    %esp,%ebp
  80211f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802122:	6a 01                	push   $0x1
  802124:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802127:	50                   	push   %eax
  802128:	6a 00                	push   $0x0
  80212a:	e8 7e f6 ff ff       	call   8017ad <read>
	if (r < 0)
  80212f:	83 c4 10             	add    $0x10,%esp
  802132:	85 c0                	test   %eax,%eax
  802134:	78 0f                	js     802145 <getchar+0x29>
		return r;
	if (r < 1)
  802136:	85 c0                	test   %eax,%eax
  802138:	7e 06                	jle    802140 <getchar+0x24>
		return -E_EOF;
	return c;
  80213a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80213e:	eb 05                	jmp    802145 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802140:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802145:	c9                   	leave  
  802146:	c3                   	ret    

00802147 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802147:	55                   	push   %ebp
  802148:	89 e5                	mov    %esp,%ebp
  80214a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80214d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802150:	50                   	push   %eax
  802151:	ff 75 08             	pushl  0x8(%ebp)
  802154:	e8 eb f3 ff ff       	call   801544 <fd_lookup>
  802159:	83 c4 10             	add    $0x10,%esp
  80215c:	85 c0                	test   %eax,%eax
  80215e:	78 11                	js     802171 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802160:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802163:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802169:	39 10                	cmp    %edx,(%eax)
  80216b:	0f 94 c0             	sete   %al
  80216e:	0f b6 c0             	movzbl %al,%eax
}
  802171:	c9                   	leave  
  802172:	c3                   	ret    

00802173 <opencons>:

int
opencons(void)
{
  802173:	55                   	push   %ebp
  802174:	89 e5                	mov    %esp,%ebp
  802176:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802179:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80217c:	50                   	push   %eax
  80217d:	e8 73 f3 ff ff       	call   8014f5 <fd_alloc>
  802182:	83 c4 10             	add    $0x10,%esp
		return r;
  802185:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802187:	85 c0                	test   %eax,%eax
  802189:	78 3e                	js     8021c9 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80218b:	83 ec 04             	sub    $0x4,%esp
  80218e:	68 07 04 00 00       	push   $0x407
  802193:	ff 75 f4             	pushl  -0xc(%ebp)
  802196:	6a 00                	push   $0x0
  802198:	e8 42 ea ff ff       	call   800bdf <sys_page_alloc>
  80219d:	83 c4 10             	add    $0x10,%esp
		return r;
  8021a0:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021a2:	85 c0                	test   %eax,%eax
  8021a4:	78 23                	js     8021c9 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8021a6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021af:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021b4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021bb:	83 ec 0c             	sub    $0xc,%esp
  8021be:	50                   	push   %eax
  8021bf:	e8 0a f3 ff ff       	call   8014ce <fd2num>
  8021c4:	89 c2                	mov    %eax,%edx
  8021c6:	83 c4 10             	add    $0x10,%esp
}
  8021c9:	89 d0                	mov    %edx,%eax
  8021cb:	c9                   	leave  
  8021cc:	c3                   	ret    

008021cd <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8021cd:	55                   	push   %ebp
  8021ce:	89 e5                	mov    %esp,%ebp
  8021d0:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8021d3:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8021da:	75 2a                	jne    802206 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  8021dc:	83 ec 04             	sub    $0x4,%esp
  8021df:	6a 07                	push   $0x7
  8021e1:	68 00 f0 bf ee       	push   $0xeebff000
  8021e6:	6a 00                	push   $0x0
  8021e8:	e8 f2 e9 ff ff       	call   800bdf <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8021ed:	83 c4 10             	add    $0x10,%esp
  8021f0:	85 c0                	test   %eax,%eax
  8021f2:	79 12                	jns    802206 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8021f4:	50                   	push   %eax
  8021f5:	68 98 29 80 00       	push   $0x802998
  8021fa:	6a 23                	push   $0x23
  8021fc:	68 2e 2b 80 00       	push   $0x802b2e
  802201:	e8 78 df ff ff       	call   80017e <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802206:	8b 45 08             	mov    0x8(%ebp),%eax
  802209:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80220e:	83 ec 08             	sub    $0x8,%esp
  802211:	68 38 22 80 00       	push   $0x802238
  802216:	6a 00                	push   $0x0
  802218:	e8 0d eb ff ff       	call   800d2a <sys_env_set_pgfault_upcall>
	if (r < 0) {
  80221d:	83 c4 10             	add    $0x10,%esp
  802220:	85 c0                	test   %eax,%eax
  802222:	79 12                	jns    802236 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802224:	50                   	push   %eax
  802225:	68 98 29 80 00       	push   $0x802998
  80222a:	6a 2c                	push   $0x2c
  80222c:	68 2e 2b 80 00       	push   $0x802b2e
  802231:	e8 48 df ff ff       	call   80017e <_panic>
	}
}
  802236:	c9                   	leave  
  802237:	c3                   	ret    

00802238 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802238:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802239:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80223e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802240:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802243:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802247:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80224c:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802250:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802252:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802255:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802256:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802259:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80225a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80225b:	c3                   	ret    

0080225c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80225c:	55                   	push   %ebp
  80225d:	89 e5                	mov    %esp,%ebp
  80225f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802262:	89 d0                	mov    %edx,%eax
  802264:	c1 e8 16             	shr    $0x16,%eax
  802267:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80226e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802273:	f6 c1 01             	test   $0x1,%cl
  802276:	74 1d                	je     802295 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802278:	c1 ea 0c             	shr    $0xc,%edx
  80227b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802282:	f6 c2 01             	test   $0x1,%dl
  802285:	74 0e                	je     802295 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802287:	c1 ea 0c             	shr    $0xc,%edx
  80228a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802291:	ef 
  802292:	0f b7 c0             	movzwl %ax,%eax
}
  802295:	5d                   	pop    %ebp
  802296:	c3                   	ret    
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
