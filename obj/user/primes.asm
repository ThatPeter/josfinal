
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
  800047:	e8 fe 10 00 00       	call   80114a <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 40 80 00       	mov    0x804004,%eax
  800053:	8b 80 b8 00 00 00    	mov    0xb8(%eax),%eax
  800059:	83 c4 0c             	add    $0xc,%esp
  80005c:	53                   	push   %ebx
  80005d:	50                   	push   %eax
  80005e:	68 e0 22 80 00       	push   $0x8022e0
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
  800077:	68 ec 22 80 00       	push   $0x8022ec
  80007c:	6a 1a                	push   $0x1a
  80007e:	68 f5 22 80 00       	push   $0x8022f5
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
  800097:	e8 ae 10 00 00       	call   80114a <ipc_recv>
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
  8000ae:	e8 12 11 00 00       	call   8011c5 <ipc_send>
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
  8000c9:	68 ec 22 80 00       	push   $0x8022ec
  8000ce:	6a 2d                	push   $0x2d
  8000d0:	68 f5 22 80 00       	push   $0x8022f5
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
  8000ee:	e8 d2 10 00 00       	call   8011c5 <ipc_send>
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
  80016a:	e8 cb 12 00 00       	call   80143a <close_all>
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
  80019c:	68 10 23 80 00       	push   $0x802310
  8001a1:	e8 b1 00 00 00       	call   800257 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a6:	83 c4 18             	add    $0x18,%esp
  8001a9:	53                   	push   %ebx
  8001aa:	ff 75 10             	pushl  0x10(%ebp)
  8001ad:	e8 54 00 00 00       	call   800206 <vcprintf>
	cprintf("\n");
  8001b2:	c7 04 24 db 27 80 00 	movl   $0x8027db,(%esp)
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
  8002ba:	e8 81 1d 00 00       	call   802040 <__udivdi3>
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
  8002fd:	e8 6e 1e 00 00       	call   802170 <__umoddi3>
  800302:	83 c4 14             	add    $0x14,%esp
  800305:	0f be 80 33 23 80 00 	movsbl 0x802333(%eax),%eax
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
  800401:	ff 24 85 80 24 80 00 	jmp    *0x802480(,%eax,4)
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
  8004c5:	8b 14 85 e0 25 80 00 	mov    0x8025e0(,%eax,4),%edx
  8004cc:	85 d2                	test   %edx,%edx
  8004ce:	75 18                	jne    8004e8 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004d0:	50                   	push   %eax
  8004d1:	68 4b 23 80 00       	push   $0x80234b
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
  8004e9:	68 a9 27 80 00       	push   $0x8027a9
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
  80050d:	b8 44 23 80 00       	mov    $0x802344,%eax
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
  800b88:	68 3f 26 80 00       	push   $0x80263f
  800b8d:	6a 23                	push   $0x23
  800b8f:	68 5c 26 80 00       	push   $0x80265c
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
  800c09:	68 3f 26 80 00       	push   $0x80263f
  800c0e:	6a 23                	push   $0x23
  800c10:	68 5c 26 80 00       	push   $0x80265c
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
  800c4b:	68 3f 26 80 00       	push   $0x80263f
  800c50:	6a 23                	push   $0x23
  800c52:	68 5c 26 80 00       	push   $0x80265c
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
  800c8d:	68 3f 26 80 00       	push   $0x80263f
  800c92:	6a 23                	push   $0x23
  800c94:	68 5c 26 80 00       	push   $0x80265c
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
  800ccf:	68 3f 26 80 00       	push   $0x80263f
  800cd4:	6a 23                	push   $0x23
  800cd6:	68 5c 26 80 00       	push   $0x80265c
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
  800d11:	68 3f 26 80 00       	push   $0x80263f
  800d16:	6a 23                	push   $0x23
  800d18:	68 5c 26 80 00       	push   $0x80265c
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
  800d53:	68 3f 26 80 00       	push   $0x80263f
  800d58:	6a 23                	push   $0x23
  800d5a:	68 5c 26 80 00       	push   $0x80265c
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
  800db7:	68 3f 26 80 00       	push   $0x80263f
  800dbc:	6a 23                	push   $0x23
  800dbe:	68 5c 26 80 00       	push   $0x80265c
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
  800e56:	68 6a 26 80 00       	push   $0x80266a
  800e5b:	6a 1e                	push   $0x1e
  800e5d:	68 7a 26 80 00       	push   $0x80267a
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
  800e80:	68 85 26 80 00       	push   $0x802685
  800e85:	6a 2c                	push   $0x2c
  800e87:	68 7a 26 80 00       	push   $0x80267a
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
  800ec8:	68 85 26 80 00       	push   $0x802685
  800ecd:	6a 33                	push   $0x33
  800ecf:	68 7a 26 80 00       	push   $0x80267a
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
  800ef0:	68 85 26 80 00       	push   $0x802685
  800ef5:	6a 37                	push   $0x37
  800ef7:	68 7a 26 80 00       	push   $0x80267a
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
  800f14:	e8 52 10 00 00       	call   801f6b <set_pgfault_handler>
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
  800f2d:	68 9e 26 80 00       	push   $0x80269e
  800f32:	68 84 00 00 00       	push   $0x84
  800f37:	68 7a 26 80 00       	push   $0x80267a
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
  800fe9:	68 ac 26 80 00       	push   $0x8026ac
  800fee:	6a 54                	push   $0x54
  800ff0:	68 7a 26 80 00       	push   $0x80267a
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
  80102e:	68 ac 26 80 00       	push   $0x8026ac
  801033:	6a 5b                	push   $0x5b
  801035:	68 7a 26 80 00       	push   $0x80267a
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
  80105c:	68 ac 26 80 00       	push   $0x8026ac
  801061:	6a 5f                	push   $0x5f
  801063:	68 7a 26 80 00       	push   $0x80267a
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
  801086:	68 ac 26 80 00       	push   $0x8026ac
  80108b:	6a 64                	push   $0x64
  80108d:	68 7a 26 80 00       	push   $0x80267a
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
  8010f5:	68 c4 26 80 00       	push   $0x8026c4
  8010fa:	e8 58 f1 ff ff       	call   800257 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8010ff:	c7 04 24 44 01 80 00 	movl   $0x800144,(%esp)
  801106:	e8 c5 fc ff ff       	call   800dd0 <sys_thread_create>
  80110b:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80110d:	83 c4 08             	add    $0x8,%esp
  801110:	53                   	push   %ebx
  801111:	68 c4 26 80 00       	push   $0x8026c4
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

0080114a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80114a:	55                   	push   %ebp
  80114b:	89 e5                	mov    %esp,%ebp
  80114d:	56                   	push   %esi
  80114e:	53                   	push   %ebx
  80114f:	8b 75 08             	mov    0x8(%ebp),%esi
  801152:	8b 45 0c             	mov    0xc(%ebp),%eax
  801155:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801158:	85 c0                	test   %eax,%eax
  80115a:	75 12                	jne    80116e <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80115c:	83 ec 0c             	sub    $0xc,%esp
  80115f:	68 00 00 c0 ee       	push   $0xeec00000
  801164:	e8 26 fc ff ff       	call   800d8f <sys_ipc_recv>
  801169:	83 c4 10             	add    $0x10,%esp
  80116c:	eb 0c                	jmp    80117a <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80116e:	83 ec 0c             	sub    $0xc,%esp
  801171:	50                   	push   %eax
  801172:	e8 18 fc ff ff       	call   800d8f <sys_ipc_recv>
  801177:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80117a:	85 f6                	test   %esi,%esi
  80117c:	0f 95 c1             	setne  %cl
  80117f:	85 db                	test   %ebx,%ebx
  801181:	0f 95 c2             	setne  %dl
  801184:	84 d1                	test   %dl,%cl
  801186:	74 09                	je     801191 <ipc_recv+0x47>
  801188:	89 c2                	mov    %eax,%edx
  80118a:	c1 ea 1f             	shr    $0x1f,%edx
  80118d:	84 d2                	test   %dl,%dl
  80118f:	75 2d                	jne    8011be <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801191:	85 f6                	test   %esi,%esi
  801193:	74 0d                	je     8011a2 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801195:	a1 04 40 80 00       	mov    0x804004,%eax
  80119a:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8011a0:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8011a2:	85 db                	test   %ebx,%ebx
  8011a4:	74 0d                	je     8011b3 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8011a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8011ab:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  8011b1:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8011b3:	a1 04 40 80 00       	mov    0x804004,%eax
  8011b8:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  8011be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011c1:	5b                   	pop    %ebx
  8011c2:	5e                   	pop    %esi
  8011c3:	5d                   	pop    %ebp
  8011c4:	c3                   	ret    

008011c5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011c5:	55                   	push   %ebp
  8011c6:	89 e5                	mov    %esp,%ebp
  8011c8:	57                   	push   %edi
  8011c9:	56                   	push   %esi
  8011ca:	53                   	push   %ebx
  8011cb:	83 ec 0c             	sub    $0xc,%esp
  8011ce:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011d1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011d4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8011d7:	85 db                	test   %ebx,%ebx
  8011d9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8011de:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8011e1:	ff 75 14             	pushl  0x14(%ebp)
  8011e4:	53                   	push   %ebx
  8011e5:	56                   	push   %esi
  8011e6:	57                   	push   %edi
  8011e7:	e8 80 fb ff ff       	call   800d6c <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8011ec:	89 c2                	mov    %eax,%edx
  8011ee:	c1 ea 1f             	shr    $0x1f,%edx
  8011f1:	83 c4 10             	add    $0x10,%esp
  8011f4:	84 d2                	test   %dl,%dl
  8011f6:	74 17                	je     80120f <ipc_send+0x4a>
  8011f8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011fb:	74 12                	je     80120f <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8011fd:	50                   	push   %eax
  8011fe:	68 e7 26 80 00       	push   $0x8026e7
  801203:	6a 47                	push   $0x47
  801205:	68 f5 26 80 00       	push   $0x8026f5
  80120a:	e8 6f ef ff ff       	call   80017e <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80120f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801212:	75 07                	jne    80121b <ipc_send+0x56>
			sys_yield();
  801214:	e8 a7 f9 ff ff       	call   800bc0 <sys_yield>
  801219:	eb c6                	jmp    8011e1 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80121b:	85 c0                	test   %eax,%eax
  80121d:	75 c2                	jne    8011e1 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80121f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801222:	5b                   	pop    %ebx
  801223:	5e                   	pop    %esi
  801224:	5f                   	pop    %edi
  801225:	5d                   	pop    %ebp
  801226:	c3                   	ret    

00801227 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801227:	55                   	push   %ebp
  801228:	89 e5                	mov    %esp,%ebp
  80122a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80122d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801232:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  801238:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80123e:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  801244:	39 ca                	cmp    %ecx,%edx
  801246:	75 13                	jne    80125b <ipc_find_env+0x34>
			return envs[i].env_id;
  801248:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  80124e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801253:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801259:	eb 0f                	jmp    80126a <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80125b:	83 c0 01             	add    $0x1,%eax
  80125e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801263:	75 cd                	jne    801232 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801265:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80126a:	5d                   	pop    %ebp
  80126b:	c3                   	ret    

0080126c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80126f:	8b 45 08             	mov    0x8(%ebp),%eax
  801272:	05 00 00 00 30       	add    $0x30000000,%eax
  801277:	c1 e8 0c             	shr    $0xc,%eax
}
  80127a:	5d                   	pop    %ebp
  80127b:	c3                   	ret    

0080127c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80127f:	8b 45 08             	mov    0x8(%ebp),%eax
  801282:	05 00 00 00 30       	add    $0x30000000,%eax
  801287:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80128c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801291:	5d                   	pop    %ebp
  801292:	c3                   	ret    

00801293 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801293:	55                   	push   %ebp
  801294:	89 e5                	mov    %esp,%ebp
  801296:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801299:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80129e:	89 c2                	mov    %eax,%edx
  8012a0:	c1 ea 16             	shr    $0x16,%edx
  8012a3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012aa:	f6 c2 01             	test   $0x1,%dl
  8012ad:	74 11                	je     8012c0 <fd_alloc+0x2d>
  8012af:	89 c2                	mov    %eax,%edx
  8012b1:	c1 ea 0c             	shr    $0xc,%edx
  8012b4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012bb:	f6 c2 01             	test   $0x1,%dl
  8012be:	75 09                	jne    8012c9 <fd_alloc+0x36>
			*fd_store = fd;
  8012c0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c7:	eb 17                	jmp    8012e0 <fd_alloc+0x4d>
  8012c9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012ce:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012d3:	75 c9                	jne    80129e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012d5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012db:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012e0:	5d                   	pop    %ebp
  8012e1:	c3                   	ret    

008012e2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012e8:	83 f8 1f             	cmp    $0x1f,%eax
  8012eb:	77 36                	ja     801323 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012ed:	c1 e0 0c             	shl    $0xc,%eax
  8012f0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012f5:	89 c2                	mov    %eax,%edx
  8012f7:	c1 ea 16             	shr    $0x16,%edx
  8012fa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801301:	f6 c2 01             	test   $0x1,%dl
  801304:	74 24                	je     80132a <fd_lookup+0x48>
  801306:	89 c2                	mov    %eax,%edx
  801308:	c1 ea 0c             	shr    $0xc,%edx
  80130b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801312:	f6 c2 01             	test   $0x1,%dl
  801315:	74 1a                	je     801331 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801317:	8b 55 0c             	mov    0xc(%ebp),%edx
  80131a:	89 02                	mov    %eax,(%edx)
	return 0;
  80131c:	b8 00 00 00 00       	mov    $0x0,%eax
  801321:	eb 13                	jmp    801336 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801323:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801328:	eb 0c                	jmp    801336 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80132a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80132f:	eb 05                	jmp    801336 <fd_lookup+0x54>
  801331:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801336:	5d                   	pop    %ebp
  801337:	c3                   	ret    

00801338 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	83 ec 08             	sub    $0x8,%esp
  80133e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801341:	ba 80 27 80 00       	mov    $0x802780,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801346:	eb 13                	jmp    80135b <dev_lookup+0x23>
  801348:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80134b:	39 08                	cmp    %ecx,(%eax)
  80134d:	75 0c                	jne    80135b <dev_lookup+0x23>
			*dev = devtab[i];
  80134f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801352:	89 01                	mov    %eax,(%ecx)
			return 0;
  801354:	b8 00 00 00 00       	mov    $0x0,%eax
  801359:	eb 31                	jmp    80138c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80135b:	8b 02                	mov    (%edx),%eax
  80135d:	85 c0                	test   %eax,%eax
  80135f:	75 e7                	jne    801348 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801361:	a1 04 40 80 00       	mov    0x804004,%eax
  801366:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80136c:	83 ec 04             	sub    $0x4,%esp
  80136f:	51                   	push   %ecx
  801370:	50                   	push   %eax
  801371:	68 00 27 80 00       	push   $0x802700
  801376:	e8 dc ee ff ff       	call   800257 <cprintf>
	*dev = 0;
  80137b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80137e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801384:	83 c4 10             	add    $0x10,%esp
  801387:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80138c:	c9                   	leave  
  80138d:	c3                   	ret    

0080138e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80138e:	55                   	push   %ebp
  80138f:	89 e5                	mov    %esp,%ebp
  801391:	56                   	push   %esi
  801392:	53                   	push   %ebx
  801393:	83 ec 10             	sub    $0x10,%esp
  801396:	8b 75 08             	mov    0x8(%ebp),%esi
  801399:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80139c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139f:	50                   	push   %eax
  8013a0:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013a6:	c1 e8 0c             	shr    $0xc,%eax
  8013a9:	50                   	push   %eax
  8013aa:	e8 33 ff ff ff       	call   8012e2 <fd_lookup>
  8013af:	83 c4 08             	add    $0x8,%esp
  8013b2:	85 c0                	test   %eax,%eax
  8013b4:	78 05                	js     8013bb <fd_close+0x2d>
	    || fd != fd2)
  8013b6:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013b9:	74 0c                	je     8013c7 <fd_close+0x39>
		return (must_exist ? r : 0);
  8013bb:	84 db                	test   %bl,%bl
  8013bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c2:	0f 44 c2             	cmove  %edx,%eax
  8013c5:	eb 41                	jmp    801408 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013c7:	83 ec 08             	sub    $0x8,%esp
  8013ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013cd:	50                   	push   %eax
  8013ce:	ff 36                	pushl  (%esi)
  8013d0:	e8 63 ff ff ff       	call   801338 <dev_lookup>
  8013d5:	89 c3                	mov    %eax,%ebx
  8013d7:	83 c4 10             	add    $0x10,%esp
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	78 1a                	js     8013f8 <fd_close+0x6a>
		if (dev->dev_close)
  8013de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013e4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013e9:	85 c0                	test   %eax,%eax
  8013eb:	74 0b                	je     8013f8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013ed:	83 ec 0c             	sub    $0xc,%esp
  8013f0:	56                   	push   %esi
  8013f1:	ff d0                	call   *%eax
  8013f3:	89 c3                	mov    %eax,%ebx
  8013f5:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013f8:	83 ec 08             	sub    $0x8,%esp
  8013fb:	56                   	push   %esi
  8013fc:	6a 00                	push   $0x0
  8013fe:	e8 61 f8 ff ff       	call   800c64 <sys_page_unmap>
	return r;
  801403:	83 c4 10             	add    $0x10,%esp
  801406:	89 d8                	mov    %ebx,%eax
}
  801408:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80140b:	5b                   	pop    %ebx
  80140c:	5e                   	pop    %esi
  80140d:	5d                   	pop    %ebp
  80140e:	c3                   	ret    

0080140f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80140f:	55                   	push   %ebp
  801410:	89 e5                	mov    %esp,%ebp
  801412:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801415:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801418:	50                   	push   %eax
  801419:	ff 75 08             	pushl  0x8(%ebp)
  80141c:	e8 c1 fe ff ff       	call   8012e2 <fd_lookup>
  801421:	83 c4 08             	add    $0x8,%esp
  801424:	85 c0                	test   %eax,%eax
  801426:	78 10                	js     801438 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801428:	83 ec 08             	sub    $0x8,%esp
  80142b:	6a 01                	push   $0x1
  80142d:	ff 75 f4             	pushl  -0xc(%ebp)
  801430:	e8 59 ff ff ff       	call   80138e <fd_close>
  801435:	83 c4 10             	add    $0x10,%esp
}
  801438:	c9                   	leave  
  801439:	c3                   	ret    

0080143a <close_all>:

void
close_all(void)
{
  80143a:	55                   	push   %ebp
  80143b:	89 e5                	mov    %esp,%ebp
  80143d:	53                   	push   %ebx
  80143e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801441:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801446:	83 ec 0c             	sub    $0xc,%esp
  801449:	53                   	push   %ebx
  80144a:	e8 c0 ff ff ff       	call   80140f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80144f:	83 c3 01             	add    $0x1,%ebx
  801452:	83 c4 10             	add    $0x10,%esp
  801455:	83 fb 20             	cmp    $0x20,%ebx
  801458:	75 ec                	jne    801446 <close_all+0xc>
		close(i);
}
  80145a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80145d:	c9                   	leave  
  80145e:	c3                   	ret    

0080145f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80145f:	55                   	push   %ebp
  801460:	89 e5                	mov    %esp,%ebp
  801462:	57                   	push   %edi
  801463:	56                   	push   %esi
  801464:	53                   	push   %ebx
  801465:	83 ec 2c             	sub    $0x2c,%esp
  801468:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80146b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80146e:	50                   	push   %eax
  80146f:	ff 75 08             	pushl  0x8(%ebp)
  801472:	e8 6b fe ff ff       	call   8012e2 <fd_lookup>
  801477:	83 c4 08             	add    $0x8,%esp
  80147a:	85 c0                	test   %eax,%eax
  80147c:	0f 88 c1 00 00 00    	js     801543 <dup+0xe4>
		return r;
	close(newfdnum);
  801482:	83 ec 0c             	sub    $0xc,%esp
  801485:	56                   	push   %esi
  801486:	e8 84 ff ff ff       	call   80140f <close>

	newfd = INDEX2FD(newfdnum);
  80148b:	89 f3                	mov    %esi,%ebx
  80148d:	c1 e3 0c             	shl    $0xc,%ebx
  801490:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801496:	83 c4 04             	add    $0x4,%esp
  801499:	ff 75 e4             	pushl  -0x1c(%ebp)
  80149c:	e8 db fd ff ff       	call   80127c <fd2data>
  8014a1:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014a3:	89 1c 24             	mov    %ebx,(%esp)
  8014a6:	e8 d1 fd ff ff       	call   80127c <fd2data>
  8014ab:	83 c4 10             	add    $0x10,%esp
  8014ae:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014b1:	89 f8                	mov    %edi,%eax
  8014b3:	c1 e8 16             	shr    $0x16,%eax
  8014b6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014bd:	a8 01                	test   $0x1,%al
  8014bf:	74 37                	je     8014f8 <dup+0x99>
  8014c1:	89 f8                	mov    %edi,%eax
  8014c3:	c1 e8 0c             	shr    $0xc,%eax
  8014c6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014cd:	f6 c2 01             	test   $0x1,%dl
  8014d0:	74 26                	je     8014f8 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014d2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014d9:	83 ec 0c             	sub    $0xc,%esp
  8014dc:	25 07 0e 00 00       	and    $0xe07,%eax
  8014e1:	50                   	push   %eax
  8014e2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014e5:	6a 00                	push   $0x0
  8014e7:	57                   	push   %edi
  8014e8:	6a 00                	push   $0x0
  8014ea:	e8 33 f7 ff ff       	call   800c22 <sys_page_map>
  8014ef:	89 c7                	mov    %eax,%edi
  8014f1:	83 c4 20             	add    $0x20,%esp
  8014f4:	85 c0                	test   %eax,%eax
  8014f6:	78 2e                	js     801526 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014fb:	89 d0                	mov    %edx,%eax
  8014fd:	c1 e8 0c             	shr    $0xc,%eax
  801500:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801507:	83 ec 0c             	sub    $0xc,%esp
  80150a:	25 07 0e 00 00       	and    $0xe07,%eax
  80150f:	50                   	push   %eax
  801510:	53                   	push   %ebx
  801511:	6a 00                	push   $0x0
  801513:	52                   	push   %edx
  801514:	6a 00                	push   $0x0
  801516:	e8 07 f7 ff ff       	call   800c22 <sys_page_map>
  80151b:	89 c7                	mov    %eax,%edi
  80151d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801520:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801522:	85 ff                	test   %edi,%edi
  801524:	79 1d                	jns    801543 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801526:	83 ec 08             	sub    $0x8,%esp
  801529:	53                   	push   %ebx
  80152a:	6a 00                	push   $0x0
  80152c:	e8 33 f7 ff ff       	call   800c64 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801531:	83 c4 08             	add    $0x8,%esp
  801534:	ff 75 d4             	pushl  -0x2c(%ebp)
  801537:	6a 00                	push   $0x0
  801539:	e8 26 f7 ff ff       	call   800c64 <sys_page_unmap>
	return r;
  80153e:	83 c4 10             	add    $0x10,%esp
  801541:	89 f8                	mov    %edi,%eax
}
  801543:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801546:	5b                   	pop    %ebx
  801547:	5e                   	pop    %esi
  801548:	5f                   	pop    %edi
  801549:	5d                   	pop    %ebp
  80154a:	c3                   	ret    

0080154b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80154b:	55                   	push   %ebp
  80154c:	89 e5                	mov    %esp,%ebp
  80154e:	53                   	push   %ebx
  80154f:	83 ec 14             	sub    $0x14,%esp
  801552:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801555:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801558:	50                   	push   %eax
  801559:	53                   	push   %ebx
  80155a:	e8 83 fd ff ff       	call   8012e2 <fd_lookup>
  80155f:	83 c4 08             	add    $0x8,%esp
  801562:	89 c2                	mov    %eax,%edx
  801564:	85 c0                	test   %eax,%eax
  801566:	78 70                	js     8015d8 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801568:	83 ec 08             	sub    $0x8,%esp
  80156b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156e:	50                   	push   %eax
  80156f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801572:	ff 30                	pushl  (%eax)
  801574:	e8 bf fd ff ff       	call   801338 <dev_lookup>
  801579:	83 c4 10             	add    $0x10,%esp
  80157c:	85 c0                	test   %eax,%eax
  80157e:	78 4f                	js     8015cf <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801580:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801583:	8b 42 08             	mov    0x8(%edx),%eax
  801586:	83 e0 03             	and    $0x3,%eax
  801589:	83 f8 01             	cmp    $0x1,%eax
  80158c:	75 24                	jne    8015b2 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80158e:	a1 04 40 80 00       	mov    0x804004,%eax
  801593:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801599:	83 ec 04             	sub    $0x4,%esp
  80159c:	53                   	push   %ebx
  80159d:	50                   	push   %eax
  80159e:	68 44 27 80 00       	push   $0x802744
  8015a3:	e8 af ec ff ff       	call   800257 <cprintf>
		return -E_INVAL;
  8015a8:	83 c4 10             	add    $0x10,%esp
  8015ab:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015b0:	eb 26                	jmp    8015d8 <read+0x8d>
	}
	if (!dev->dev_read)
  8015b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b5:	8b 40 08             	mov    0x8(%eax),%eax
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	74 17                	je     8015d3 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8015bc:	83 ec 04             	sub    $0x4,%esp
  8015bf:	ff 75 10             	pushl  0x10(%ebp)
  8015c2:	ff 75 0c             	pushl  0xc(%ebp)
  8015c5:	52                   	push   %edx
  8015c6:	ff d0                	call   *%eax
  8015c8:	89 c2                	mov    %eax,%edx
  8015ca:	83 c4 10             	add    $0x10,%esp
  8015cd:	eb 09                	jmp    8015d8 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015cf:	89 c2                	mov    %eax,%edx
  8015d1:	eb 05                	jmp    8015d8 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015d3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8015d8:	89 d0                	mov    %edx,%eax
  8015da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015dd:	c9                   	leave  
  8015de:	c3                   	ret    

008015df <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015df:	55                   	push   %ebp
  8015e0:	89 e5                	mov    %esp,%ebp
  8015e2:	57                   	push   %edi
  8015e3:	56                   	push   %esi
  8015e4:	53                   	push   %ebx
  8015e5:	83 ec 0c             	sub    $0xc,%esp
  8015e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015eb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015f3:	eb 21                	jmp    801616 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015f5:	83 ec 04             	sub    $0x4,%esp
  8015f8:	89 f0                	mov    %esi,%eax
  8015fa:	29 d8                	sub    %ebx,%eax
  8015fc:	50                   	push   %eax
  8015fd:	89 d8                	mov    %ebx,%eax
  8015ff:	03 45 0c             	add    0xc(%ebp),%eax
  801602:	50                   	push   %eax
  801603:	57                   	push   %edi
  801604:	e8 42 ff ff ff       	call   80154b <read>
		if (m < 0)
  801609:	83 c4 10             	add    $0x10,%esp
  80160c:	85 c0                	test   %eax,%eax
  80160e:	78 10                	js     801620 <readn+0x41>
			return m;
		if (m == 0)
  801610:	85 c0                	test   %eax,%eax
  801612:	74 0a                	je     80161e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801614:	01 c3                	add    %eax,%ebx
  801616:	39 f3                	cmp    %esi,%ebx
  801618:	72 db                	jb     8015f5 <readn+0x16>
  80161a:	89 d8                	mov    %ebx,%eax
  80161c:	eb 02                	jmp    801620 <readn+0x41>
  80161e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801620:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801623:	5b                   	pop    %ebx
  801624:	5e                   	pop    %esi
  801625:	5f                   	pop    %edi
  801626:	5d                   	pop    %ebp
  801627:	c3                   	ret    

00801628 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801628:	55                   	push   %ebp
  801629:	89 e5                	mov    %esp,%ebp
  80162b:	53                   	push   %ebx
  80162c:	83 ec 14             	sub    $0x14,%esp
  80162f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801632:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801635:	50                   	push   %eax
  801636:	53                   	push   %ebx
  801637:	e8 a6 fc ff ff       	call   8012e2 <fd_lookup>
  80163c:	83 c4 08             	add    $0x8,%esp
  80163f:	89 c2                	mov    %eax,%edx
  801641:	85 c0                	test   %eax,%eax
  801643:	78 6b                	js     8016b0 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801645:	83 ec 08             	sub    $0x8,%esp
  801648:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164b:	50                   	push   %eax
  80164c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164f:	ff 30                	pushl  (%eax)
  801651:	e8 e2 fc ff ff       	call   801338 <dev_lookup>
  801656:	83 c4 10             	add    $0x10,%esp
  801659:	85 c0                	test   %eax,%eax
  80165b:	78 4a                	js     8016a7 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80165d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801660:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801664:	75 24                	jne    80168a <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801666:	a1 04 40 80 00       	mov    0x804004,%eax
  80166b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801671:	83 ec 04             	sub    $0x4,%esp
  801674:	53                   	push   %ebx
  801675:	50                   	push   %eax
  801676:	68 60 27 80 00       	push   $0x802760
  80167b:	e8 d7 eb ff ff       	call   800257 <cprintf>
		return -E_INVAL;
  801680:	83 c4 10             	add    $0x10,%esp
  801683:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801688:	eb 26                	jmp    8016b0 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80168a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80168d:	8b 52 0c             	mov    0xc(%edx),%edx
  801690:	85 d2                	test   %edx,%edx
  801692:	74 17                	je     8016ab <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801694:	83 ec 04             	sub    $0x4,%esp
  801697:	ff 75 10             	pushl  0x10(%ebp)
  80169a:	ff 75 0c             	pushl  0xc(%ebp)
  80169d:	50                   	push   %eax
  80169e:	ff d2                	call   *%edx
  8016a0:	89 c2                	mov    %eax,%edx
  8016a2:	83 c4 10             	add    $0x10,%esp
  8016a5:	eb 09                	jmp    8016b0 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a7:	89 c2                	mov    %eax,%edx
  8016a9:	eb 05                	jmp    8016b0 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016ab:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016b0:	89 d0                	mov    %edx,%eax
  8016b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b5:	c9                   	leave  
  8016b6:	c3                   	ret    

008016b7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016b7:	55                   	push   %ebp
  8016b8:	89 e5                	mov    %esp,%ebp
  8016ba:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016bd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016c0:	50                   	push   %eax
  8016c1:	ff 75 08             	pushl  0x8(%ebp)
  8016c4:	e8 19 fc ff ff       	call   8012e2 <fd_lookup>
  8016c9:	83 c4 08             	add    $0x8,%esp
  8016cc:	85 c0                	test   %eax,%eax
  8016ce:	78 0e                	js     8016de <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016d6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016de:	c9                   	leave  
  8016df:	c3                   	ret    

008016e0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	53                   	push   %ebx
  8016e4:	83 ec 14             	sub    $0x14,%esp
  8016e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ed:	50                   	push   %eax
  8016ee:	53                   	push   %ebx
  8016ef:	e8 ee fb ff ff       	call   8012e2 <fd_lookup>
  8016f4:	83 c4 08             	add    $0x8,%esp
  8016f7:	89 c2                	mov    %eax,%edx
  8016f9:	85 c0                	test   %eax,%eax
  8016fb:	78 68                	js     801765 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016fd:	83 ec 08             	sub    $0x8,%esp
  801700:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801703:	50                   	push   %eax
  801704:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801707:	ff 30                	pushl  (%eax)
  801709:	e8 2a fc ff ff       	call   801338 <dev_lookup>
  80170e:	83 c4 10             	add    $0x10,%esp
  801711:	85 c0                	test   %eax,%eax
  801713:	78 47                	js     80175c <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801715:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801718:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80171c:	75 24                	jne    801742 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80171e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801723:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801729:	83 ec 04             	sub    $0x4,%esp
  80172c:	53                   	push   %ebx
  80172d:	50                   	push   %eax
  80172e:	68 20 27 80 00       	push   $0x802720
  801733:	e8 1f eb ff ff       	call   800257 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801738:	83 c4 10             	add    $0x10,%esp
  80173b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801740:	eb 23                	jmp    801765 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801742:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801745:	8b 52 18             	mov    0x18(%edx),%edx
  801748:	85 d2                	test   %edx,%edx
  80174a:	74 14                	je     801760 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80174c:	83 ec 08             	sub    $0x8,%esp
  80174f:	ff 75 0c             	pushl  0xc(%ebp)
  801752:	50                   	push   %eax
  801753:	ff d2                	call   *%edx
  801755:	89 c2                	mov    %eax,%edx
  801757:	83 c4 10             	add    $0x10,%esp
  80175a:	eb 09                	jmp    801765 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80175c:	89 c2                	mov    %eax,%edx
  80175e:	eb 05                	jmp    801765 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801760:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801765:	89 d0                	mov    %edx,%eax
  801767:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176a:	c9                   	leave  
  80176b:	c3                   	ret    

0080176c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80176c:	55                   	push   %ebp
  80176d:	89 e5                	mov    %esp,%ebp
  80176f:	53                   	push   %ebx
  801770:	83 ec 14             	sub    $0x14,%esp
  801773:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801776:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801779:	50                   	push   %eax
  80177a:	ff 75 08             	pushl  0x8(%ebp)
  80177d:	e8 60 fb ff ff       	call   8012e2 <fd_lookup>
  801782:	83 c4 08             	add    $0x8,%esp
  801785:	89 c2                	mov    %eax,%edx
  801787:	85 c0                	test   %eax,%eax
  801789:	78 58                	js     8017e3 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80178b:	83 ec 08             	sub    $0x8,%esp
  80178e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801791:	50                   	push   %eax
  801792:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801795:	ff 30                	pushl  (%eax)
  801797:	e8 9c fb ff ff       	call   801338 <dev_lookup>
  80179c:	83 c4 10             	add    $0x10,%esp
  80179f:	85 c0                	test   %eax,%eax
  8017a1:	78 37                	js     8017da <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017aa:	74 32                	je     8017de <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017ac:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017af:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017b6:	00 00 00 
	stat->st_isdir = 0;
  8017b9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017c0:	00 00 00 
	stat->st_dev = dev;
  8017c3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017c9:	83 ec 08             	sub    $0x8,%esp
  8017cc:	53                   	push   %ebx
  8017cd:	ff 75 f0             	pushl  -0x10(%ebp)
  8017d0:	ff 50 14             	call   *0x14(%eax)
  8017d3:	89 c2                	mov    %eax,%edx
  8017d5:	83 c4 10             	add    $0x10,%esp
  8017d8:	eb 09                	jmp    8017e3 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017da:	89 c2                	mov    %eax,%edx
  8017dc:	eb 05                	jmp    8017e3 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017de:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017e3:	89 d0                	mov    %edx,%eax
  8017e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e8:	c9                   	leave  
  8017e9:	c3                   	ret    

008017ea <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017ea:	55                   	push   %ebp
  8017eb:	89 e5                	mov    %esp,%ebp
  8017ed:	56                   	push   %esi
  8017ee:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017ef:	83 ec 08             	sub    $0x8,%esp
  8017f2:	6a 00                	push   $0x0
  8017f4:	ff 75 08             	pushl  0x8(%ebp)
  8017f7:	e8 e3 01 00 00       	call   8019df <open>
  8017fc:	89 c3                	mov    %eax,%ebx
  8017fe:	83 c4 10             	add    $0x10,%esp
  801801:	85 c0                	test   %eax,%eax
  801803:	78 1b                	js     801820 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801805:	83 ec 08             	sub    $0x8,%esp
  801808:	ff 75 0c             	pushl  0xc(%ebp)
  80180b:	50                   	push   %eax
  80180c:	e8 5b ff ff ff       	call   80176c <fstat>
  801811:	89 c6                	mov    %eax,%esi
	close(fd);
  801813:	89 1c 24             	mov    %ebx,(%esp)
  801816:	e8 f4 fb ff ff       	call   80140f <close>
	return r;
  80181b:	83 c4 10             	add    $0x10,%esp
  80181e:	89 f0                	mov    %esi,%eax
}
  801820:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801823:	5b                   	pop    %ebx
  801824:	5e                   	pop    %esi
  801825:	5d                   	pop    %ebp
  801826:	c3                   	ret    

00801827 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801827:	55                   	push   %ebp
  801828:	89 e5                	mov    %esp,%ebp
  80182a:	56                   	push   %esi
  80182b:	53                   	push   %ebx
  80182c:	89 c6                	mov    %eax,%esi
  80182e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801830:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801837:	75 12                	jne    80184b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801839:	83 ec 0c             	sub    $0xc,%esp
  80183c:	6a 01                	push   $0x1
  80183e:	e8 e4 f9 ff ff       	call   801227 <ipc_find_env>
  801843:	a3 00 40 80 00       	mov    %eax,0x804000
  801848:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80184b:	6a 07                	push   $0x7
  80184d:	68 00 50 80 00       	push   $0x805000
  801852:	56                   	push   %esi
  801853:	ff 35 00 40 80 00    	pushl  0x804000
  801859:	e8 67 f9 ff ff       	call   8011c5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80185e:	83 c4 0c             	add    $0xc,%esp
  801861:	6a 00                	push   $0x0
  801863:	53                   	push   %ebx
  801864:	6a 00                	push   $0x0
  801866:	e8 df f8 ff ff       	call   80114a <ipc_recv>
}
  80186b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80186e:	5b                   	pop    %ebx
  80186f:	5e                   	pop    %esi
  801870:	5d                   	pop    %ebp
  801871:	c3                   	ret    

00801872 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801878:	8b 45 08             	mov    0x8(%ebp),%eax
  80187b:	8b 40 0c             	mov    0xc(%eax),%eax
  80187e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801883:	8b 45 0c             	mov    0xc(%ebp),%eax
  801886:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80188b:	ba 00 00 00 00       	mov    $0x0,%edx
  801890:	b8 02 00 00 00       	mov    $0x2,%eax
  801895:	e8 8d ff ff ff       	call   801827 <fsipc>
}
  80189a:	c9                   	leave  
  80189b:	c3                   	ret    

0080189c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80189c:	55                   	push   %ebp
  80189d:	89 e5                	mov    %esp,%ebp
  80189f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b2:	b8 06 00 00 00       	mov    $0x6,%eax
  8018b7:	e8 6b ff ff ff       	call   801827 <fsipc>
}
  8018bc:	c9                   	leave  
  8018bd:	c3                   	ret    

008018be <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018be:	55                   	push   %ebp
  8018bf:	89 e5                	mov    %esp,%ebp
  8018c1:	53                   	push   %ebx
  8018c2:	83 ec 04             	sub    $0x4,%esp
  8018c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ce:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d8:	b8 05 00 00 00       	mov    $0x5,%eax
  8018dd:	e8 45 ff ff ff       	call   801827 <fsipc>
  8018e2:	85 c0                	test   %eax,%eax
  8018e4:	78 2c                	js     801912 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018e6:	83 ec 08             	sub    $0x8,%esp
  8018e9:	68 00 50 80 00       	push   $0x805000
  8018ee:	53                   	push   %ebx
  8018ef:	e8 e8 ee ff ff       	call   8007dc <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018f4:	a1 80 50 80 00       	mov    0x805080,%eax
  8018f9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018ff:	a1 84 50 80 00       	mov    0x805084,%eax
  801904:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80190a:	83 c4 10             	add    $0x10,%esp
  80190d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801912:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801915:	c9                   	leave  
  801916:	c3                   	ret    

00801917 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801917:	55                   	push   %ebp
  801918:	89 e5                	mov    %esp,%ebp
  80191a:	83 ec 0c             	sub    $0xc,%esp
  80191d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801920:	8b 55 08             	mov    0x8(%ebp),%edx
  801923:	8b 52 0c             	mov    0xc(%edx),%edx
  801926:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80192c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801931:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801936:	0f 47 c2             	cmova  %edx,%eax
  801939:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80193e:	50                   	push   %eax
  80193f:	ff 75 0c             	pushl  0xc(%ebp)
  801942:	68 08 50 80 00       	push   $0x805008
  801947:	e8 22 f0 ff ff       	call   80096e <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80194c:	ba 00 00 00 00       	mov    $0x0,%edx
  801951:	b8 04 00 00 00       	mov    $0x4,%eax
  801956:	e8 cc fe ff ff       	call   801827 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80195b:	c9                   	leave  
  80195c:	c3                   	ret    

0080195d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80195d:	55                   	push   %ebp
  80195e:	89 e5                	mov    %esp,%ebp
  801960:	56                   	push   %esi
  801961:	53                   	push   %ebx
  801962:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801965:	8b 45 08             	mov    0x8(%ebp),%eax
  801968:	8b 40 0c             	mov    0xc(%eax),%eax
  80196b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801970:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801976:	ba 00 00 00 00       	mov    $0x0,%edx
  80197b:	b8 03 00 00 00       	mov    $0x3,%eax
  801980:	e8 a2 fe ff ff       	call   801827 <fsipc>
  801985:	89 c3                	mov    %eax,%ebx
  801987:	85 c0                	test   %eax,%eax
  801989:	78 4b                	js     8019d6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80198b:	39 c6                	cmp    %eax,%esi
  80198d:	73 16                	jae    8019a5 <devfile_read+0x48>
  80198f:	68 90 27 80 00       	push   $0x802790
  801994:	68 97 27 80 00       	push   $0x802797
  801999:	6a 7c                	push   $0x7c
  80199b:	68 ac 27 80 00       	push   $0x8027ac
  8019a0:	e8 d9 e7 ff ff       	call   80017e <_panic>
	assert(r <= PGSIZE);
  8019a5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019aa:	7e 16                	jle    8019c2 <devfile_read+0x65>
  8019ac:	68 b7 27 80 00       	push   $0x8027b7
  8019b1:	68 97 27 80 00       	push   $0x802797
  8019b6:	6a 7d                	push   $0x7d
  8019b8:	68 ac 27 80 00       	push   $0x8027ac
  8019bd:	e8 bc e7 ff ff       	call   80017e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019c2:	83 ec 04             	sub    $0x4,%esp
  8019c5:	50                   	push   %eax
  8019c6:	68 00 50 80 00       	push   $0x805000
  8019cb:	ff 75 0c             	pushl  0xc(%ebp)
  8019ce:	e8 9b ef ff ff       	call   80096e <memmove>
	return r;
  8019d3:	83 c4 10             	add    $0x10,%esp
}
  8019d6:	89 d8                	mov    %ebx,%eax
  8019d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019db:	5b                   	pop    %ebx
  8019dc:	5e                   	pop    %esi
  8019dd:	5d                   	pop    %ebp
  8019de:	c3                   	ret    

008019df <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019df:	55                   	push   %ebp
  8019e0:	89 e5                	mov    %esp,%ebp
  8019e2:	53                   	push   %ebx
  8019e3:	83 ec 20             	sub    $0x20,%esp
  8019e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019e9:	53                   	push   %ebx
  8019ea:	e8 b4 ed ff ff       	call   8007a3 <strlen>
  8019ef:	83 c4 10             	add    $0x10,%esp
  8019f2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019f7:	7f 67                	jg     801a60 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019f9:	83 ec 0c             	sub    $0xc,%esp
  8019fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ff:	50                   	push   %eax
  801a00:	e8 8e f8 ff ff       	call   801293 <fd_alloc>
  801a05:	83 c4 10             	add    $0x10,%esp
		return r;
  801a08:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a0a:	85 c0                	test   %eax,%eax
  801a0c:	78 57                	js     801a65 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a0e:	83 ec 08             	sub    $0x8,%esp
  801a11:	53                   	push   %ebx
  801a12:	68 00 50 80 00       	push   $0x805000
  801a17:	e8 c0 ed ff ff       	call   8007dc <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a24:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a27:	b8 01 00 00 00       	mov    $0x1,%eax
  801a2c:	e8 f6 fd ff ff       	call   801827 <fsipc>
  801a31:	89 c3                	mov    %eax,%ebx
  801a33:	83 c4 10             	add    $0x10,%esp
  801a36:	85 c0                	test   %eax,%eax
  801a38:	79 14                	jns    801a4e <open+0x6f>
		fd_close(fd, 0);
  801a3a:	83 ec 08             	sub    $0x8,%esp
  801a3d:	6a 00                	push   $0x0
  801a3f:	ff 75 f4             	pushl  -0xc(%ebp)
  801a42:	e8 47 f9 ff ff       	call   80138e <fd_close>
		return r;
  801a47:	83 c4 10             	add    $0x10,%esp
  801a4a:	89 da                	mov    %ebx,%edx
  801a4c:	eb 17                	jmp    801a65 <open+0x86>
	}

	return fd2num(fd);
  801a4e:	83 ec 0c             	sub    $0xc,%esp
  801a51:	ff 75 f4             	pushl  -0xc(%ebp)
  801a54:	e8 13 f8 ff ff       	call   80126c <fd2num>
  801a59:	89 c2                	mov    %eax,%edx
  801a5b:	83 c4 10             	add    $0x10,%esp
  801a5e:	eb 05                	jmp    801a65 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a60:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a65:	89 d0                	mov    %edx,%eax
  801a67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a6a:	c9                   	leave  
  801a6b:	c3                   	ret    

00801a6c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a72:	ba 00 00 00 00       	mov    $0x0,%edx
  801a77:	b8 08 00 00 00       	mov    $0x8,%eax
  801a7c:	e8 a6 fd ff ff       	call   801827 <fsipc>
}
  801a81:	c9                   	leave  
  801a82:	c3                   	ret    

00801a83 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a83:	55                   	push   %ebp
  801a84:	89 e5                	mov    %esp,%ebp
  801a86:	56                   	push   %esi
  801a87:	53                   	push   %ebx
  801a88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a8b:	83 ec 0c             	sub    $0xc,%esp
  801a8e:	ff 75 08             	pushl  0x8(%ebp)
  801a91:	e8 e6 f7 ff ff       	call   80127c <fd2data>
  801a96:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a98:	83 c4 08             	add    $0x8,%esp
  801a9b:	68 c3 27 80 00       	push   $0x8027c3
  801aa0:	53                   	push   %ebx
  801aa1:	e8 36 ed ff ff       	call   8007dc <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801aa6:	8b 46 04             	mov    0x4(%esi),%eax
  801aa9:	2b 06                	sub    (%esi),%eax
  801aab:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ab1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ab8:	00 00 00 
	stat->st_dev = &devpipe;
  801abb:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801ac2:	30 80 00 
	return 0;
}
  801ac5:	b8 00 00 00 00       	mov    $0x0,%eax
  801aca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801acd:	5b                   	pop    %ebx
  801ace:	5e                   	pop    %esi
  801acf:	5d                   	pop    %ebp
  801ad0:	c3                   	ret    

00801ad1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ad1:	55                   	push   %ebp
  801ad2:	89 e5                	mov    %esp,%ebp
  801ad4:	53                   	push   %ebx
  801ad5:	83 ec 0c             	sub    $0xc,%esp
  801ad8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801adb:	53                   	push   %ebx
  801adc:	6a 00                	push   $0x0
  801ade:	e8 81 f1 ff ff       	call   800c64 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ae3:	89 1c 24             	mov    %ebx,(%esp)
  801ae6:	e8 91 f7 ff ff       	call   80127c <fd2data>
  801aeb:	83 c4 08             	add    $0x8,%esp
  801aee:	50                   	push   %eax
  801aef:	6a 00                	push   $0x0
  801af1:	e8 6e f1 ff ff       	call   800c64 <sys_page_unmap>
}
  801af6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801af9:	c9                   	leave  
  801afa:	c3                   	ret    

00801afb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801afb:	55                   	push   %ebp
  801afc:	89 e5                	mov    %esp,%ebp
  801afe:	57                   	push   %edi
  801aff:	56                   	push   %esi
  801b00:	53                   	push   %ebx
  801b01:	83 ec 1c             	sub    $0x1c,%esp
  801b04:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b07:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b09:	a1 04 40 80 00       	mov    0x804004,%eax
  801b0e:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b14:	83 ec 0c             	sub    $0xc,%esp
  801b17:	ff 75 e0             	pushl  -0x20(%ebp)
  801b1a:	e8 db 04 00 00       	call   801ffa <pageref>
  801b1f:	89 c3                	mov    %eax,%ebx
  801b21:	89 3c 24             	mov    %edi,(%esp)
  801b24:	e8 d1 04 00 00       	call   801ffa <pageref>
  801b29:	83 c4 10             	add    $0x10,%esp
  801b2c:	39 c3                	cmp    %eax,%ebx
  801b2e:	0f 94 c1             	sete   %cl
  801b31:	0f b6 c9             	movzbl %cl,%ecx
  801b34:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b37:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b3d:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801b43:	39 ce                	cmp    %ecx,%esi
  801b45:	74 1e                	je     801b65 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801b47:	39 c3                	cmp    %eax,%ebx
  801b49:	75 be                	jne    801b09 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b4b:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801b51:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b54:	50                   	push   %eax
  801b55:	56                   	push   %esi
  801b56:	68 ca 27 80 00       	push   $0x8027ca
  801b5b:	e8 f7 e6 ff ff       	call   800257 <cprintf>
  801b60:	83 c4 10             	add    $0x10,%esp
  801b63:	eb a4                	jmp    801b09 <_pipeisclosed+0xe>
	}
}
  801b65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b6b:	5b                   	pop    %ebx
  801b6c:	5e                   	pop    %esi
  801b6d:	5f                   	pop    %edi
  801b6e:	5d                   	pop    %ebp
  801b6f:	c3                   	ret    

00801b70 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b70:	55                   	push   %ebp
  801b71:	89 e5                	mov    %esp,%ebp
  801b73:	57                   	push   %edi
  801b74:	56                   	push   %esi
  801b75:	53                   	push   %ebx
  801b76:	83 ec 28             	sub    $0x28,%esp
  801b79:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b7c:	56                   	push   %esi
  801b7d:	e8 fa f6 ff ff       	call   80127c <fd2data>
  801b82:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b84:	83 c4 10             	add    $0x10,%esp
  801b87:	bf 00 00 00 00       	mov    $0x0,%edi
  801b8c:	eb 4b                	jmp    801bd9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b8e:	89 da                	mov    %ebx,%edx
  801b90:	89 f0                	mov    %esi,%eax
  801b92:	e8 64 ff ff ff       	call   801afb <_pipeisclosed>
  801b97:	85 c0                	test   %eax,%eax
  801b99:	75 48                	jne    801be3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b9b:	e8 20 f0 ff ff       	call   800bc0 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ba0:	8b 43 04             	mov    0x4(%ebx),%eax
  801ba3:	8b 0b                	mov    (%ebx),%ecx
  801ba5:	8d 51 20             	lea    0x20(%ecx),%edx
  801ba8:	39 d0                	cmp    %edx,%eax
  801baa:	73 e2                	jae    801b8e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801baf:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bb3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bb6:	89 c2                	mov    %eax,%edx
  801bb8:	c1 fa 1f             	sar    $0x1f,%edx
  801bbb:	89 d1                	mov    %edx,%ecx
  801bbd:	c1 e9 1b             	shr    $0x1b,%ecx
  801bc0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bc3:	83 e2 1f             	and    $0x1f,%edx
  801bc6:	29 ca                	sub    %ecx,%edx
  801bc8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bcc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bd0:	83 c0 01             	add    $0x1,%eax
  801bd3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bd6:	83 c7 01             	add    $0x1,%edi
  801bd9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bdc:	75 c2                	jne    801ba0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bde:	8b 45 10             	mov    0x10(%ebp),%eax
  801be1:	eb 05                	jmp    801be8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801be3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801be8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801beb:	5b                   	pop    %ebx
  801bec:	5e                   	pop    %esi
  801bed:	5f                   	pop    %edi
  801bee:	5d                   	pop    %ebp
  801bef:	c3                   	ret    

00801bf0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bf0:	55                   	push   %ebp
  801bf1:	89 e5                	mov    %esp,%ebp
  801bf3:	57                   	push   %edi
  801bf4:	56                   	push   %esi
  801bf5:	53                   	push   %ebx
  801bf6:	83 ec 18             	sub    $0x18,%esp
  801bf9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bfc:	57                   	push   %edi
  801bfd:	e8 7a f6 ff ff       	call   80127c <fd2data>
  801c02:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c04:	83 c4 10             	add    $0x10,%esp
  801c07:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c0c:	eb 3d                	jmp    801c4b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c0e:	85 db                	test   %ebx,%ebx
  801c10:	74 04                	je     801c16 <devpipe_read+0x26>
				return i;
  801c12:	89 d8                	mov    %ebx,%eax
  801c14:	eb 44                	jmp    801c5a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c16:	89 f2                	mov    %esi,%edx
  801c18:	89 f8                	mov    %edi,%eax
  801c1a:	e8 dc fe ff ff       	call   801afb <_pipeisclosed>
  801c1f:	85 c0                	test   %eax,%eax
  801c21:	75 32                	jne    801c55 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c23:	e8 98 ef ff ff       	call   800bc0 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c28:	8b 06                	mov    (%esi),%eax
  801c2a:	3b 46 04             	cmp    0x4(%esi),%eax
  801c2d:	74 df                	je     801c0e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c2f:	99                   	cltd   
  801c30:	c1 ea 1b             	shr    $0x1b,%edx
  801c33:	01 d0                	add    %edx,%eax
  801c35:	83 e0 1f             	and    $0x1f,%eax
  801c38:	29 d0                	sub    %edx,%eax
  801c3a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c42:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c45:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c48:	83 c3 01             	add    $0x1,%ebx
  801c4b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c4e:	75 d8                	jne    801c28 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c50:	8b 45 10             	mov    0x10(%ebp),%eax
  801c53:	eb 05                	jmp    801c5a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c55:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c5d:	5b                   	pop    %ebx
  801c5e:	5e                   	pop    %esi
  801c5f:	5f                   	pop    %edi
  801c60:	5d                   	pop    %ebp
  801c61:	c3                   	ret    

00801c62 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c62:	55                   	push   %ebp
  801c63:	89 e5                	mov    %esp,%ebp
  801c65:	56                   	push   %esi
  801c66:	53                   	push   %ebx
  801c67:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c6a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c6d:	50                   	push   %eax
  801c6e:	e8 20 f6 ff ff       	call   801293 <fd_alloc>
  801c73:	83 c4 10             	add    $0x10,%esp
  801c76:	89 c2                	mov    %eax,%edx
  801c78:	85 c0                	test   %eax,%eax
  801c7a:	0f 88 2c 01 00 00    	js     801dac <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c80:	83 ec 04             	sub    $0x4,%esp
  801c83:	68 07 04 00 00       	push   $0x407
  801c88:	ff 75 f4             	pushl  -0xc(%ebp)
  801c8b:	6a 00                	push   $0x0
  801c8d:	e8 4d ef ff ff       	call   800bdf <sys_page_alloc>
  801c92:	83 c4 10             	add    $0x10,%esp
  801c95:	89 c2                	mov    %eax,%edx
  801c97:	85 c0                	test   %eax,%eax
  801c99:	0f 88 0d 01 00 00    	js     801dac <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c9f:	83 ec 0c             	sub    $0xc,%esp
  801ca2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ca5:	50                   	push   %eax
  801ca6:	e8 e8 f5 ff ff       	call   801293 <fd_alloc>
  801cab:	89 c3                	mov    %eax,%ebx
  801cad:	83 c4 10             	add    $0x10,%esp
  801cb0:	85 c0                	test   %eax,%eax
  801cb2:	0f 88 e2 00 00 00    	js     801d9a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cb8:	83 ec 04             	sub    $0x4,%esp
  801cbb:	68 07 04 00 00       	push   $0x407
  801cc0:	ff 75 f0             	pushl  -0x10(%ebp)
  801cc3:	6a 00                	push   $0x0
  801cc5:	e8 15 ef ff ff       	call   800bdf <sys_page_alloc>
  801cca:	89 c3                	mov    %eax,%ebx
  801ccc:	83 c4 10             	add    $0x10,%esp
  801ccf:	85 c0                	test   %eax,%eax
  801cd1:	0f 88 c3 00 00 00    	js     801d9a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cd7:	83 ec 0c             	sub    $0xc,%esp
  801cda:	ff 75 f4             	pushl  -0xc(%ebp)
  801cdd:	e8 9a f5 ff ff       	call   80127c <fd2data>
  801ce2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce4:	83 c4 0c             	add    $0xc,%esp
  801ce7:	68 07 04 00 00       	push   $0x407
  801cec:	50                   	push   %eax
  801ced:	6a 00                	push   $0x0
  801cef:	e8 eb ee ff ff       	call   800bdf <sys_page_alloc>
  801cf4:	89 c3                	mov    %eax,%ebx
  801cf6:	83 c4 10             	add    $0x10,%esp
  801cf9:	85 c0                	test   %eax,%eax
  801cfb:	0f 88 89 00 00 00    	js     801d8a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d01:	83 ec 0c             	sub    $0xc,%esp
  801d04:	ff 75 f0             	pushl  -0x10(%ebp)
  801d07:	e8 70 f5 ff ff       	call   80127c <fd2data>
  801d0c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d13:	50                   	push   %eax
  801d14:	6a 00                	push   $0x0
  801d16:	56                   	push   %esi
  801d17:	6a 00                	push   $0x0
  801d19:	e8 04 ef ff ff       	call   800c22 <sys_page_map>
  801d1e:	89 c3                	mov    %eax,%ebx
  801d20:	83 c4 20             	add    $0x20,%esp
  801d23:	85 c0                	test   %eax,%eax
  801d25:	78 55                	js     801d7c <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d27:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d30:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d35:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d3c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d42:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d45:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d4a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d51:	83 ec 0c             	sub    $0xc,%esp
  801d54:	ff 75 f4             	pushl  -0xc(%ebp)
  801d57:	e8 10 f5 ff ff       	call   80126c <fd2num>
  801d5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d5f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d61:	83 c4 04             	add    $0x4,%esp
  801d64:	ff 75 f0             	pushl  -0x10(%ebp)
  801d67:	e8 00 f5 ff ff       	call   80126c <fd2num>
  801d6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d6f:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801d72:	83 c4 10             	add    $0x10,%esp
  801d75:	ba 00 00 00 00       	mov    $0x0,%edx
  801d7a:	eb 30                	jmp    801dac <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d7c:	83 ec 08             	sub    $0x8,%esp
  801d7f:	56                   	push   %esi
  801d80:	6a 00                	push   $0x0
  801d82:	e8 dd ee ff ff       	call   800c64 <sys_page_unmap>
  801d87:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d8a:	83 ec 08             	sub    $0x8,%esp
  801d8d:	ff 75 f0             	pushl  -0x10(%ebp)
  801d90:	6a 00                	push   $0x0
  801d92:	e8 cd ee ff ff       	call   800c64 <sys_page_unmap>
  801d97:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d9a:	83 ec 08             	sub    $0x8,%esp
  801d9d:	ff 75 f4             	pushl  -0xc(%ebp)
  801da0:	6a 00                	push   $0x0
  801da2:	e8 bd ee ff ff       	call   800c64 <sys_page_unmap>
  801da7:	83 c4 10             	add    $0x10,%esp
  801daa:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801dac:	89 d0                	mov    %edx,%eax
  801dae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801db1:	5b                   	pop    %ebx
  801db2:	5e                   	pop    %esi
  801db3:	5d                   	pop    %ebp
  801db4:	c3                   	ret    

00801db5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801db5:	55                   	push   %ebp
  801db6:	89 e5                	mov    %esp,%ebp
  801db8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dbb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dbe:	50                   	push   %eax
  801dbf:	ff 75 08             	pushl  0x8(%ebp)
  801dc2:	e8 1b f5 ff ff       	call   8012e2 <fd_lookup>
  801dc7:	83 c4 10             	add    $0x10,%esp
  801dca:	85 c0                	test   %eax,%eax
  801dcc:	78 18                	js     801de6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801dce:	83 ec 0c             	sub    $0xc,%esp
  801dd1:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd4:	e8 a3 f4 ff ff       	call   80127c <fd2data>
	return _pipeisclosed(fd, p);
  801dd9:	89 c2                	mov    %eax,%edx
  801ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dde:	e8 18 fd ff ff       	call   801afb <_pipeisclosed>
  801de3:	83 c4 10             	add    $0x10,%esp
}
  801de6:	c9                   	leave  
  801de7:	c3                   	ret    

00801de8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801de8:	55                   	push   %ebp
  801de9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801deb:	b8 00 00 00 00       	mov    $0x0,%eax
  801df0:	5d                   	pop    %ebp
  801df1:	c3                   	ret    

00801df2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801df2:	55                   	push   %ebp
  801df3:	89 e5                	mov    %esp,%ebp
  801df5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801df8:	68 e2 27 80 00       	push   $0x8027e2
  801dfd:	ff 75 0c             	pushl  0xc(%ebp)
  801e00:	e8 d7 e9 ff ff       	call   8007dc <strcpy>
	return 0;
}
  801e05:	b8 00 00 00 00       	mov    $0x0,%eax
  801e0a:	c9                   	leave  
  801e0b:	c3                   	ret    

00801e0c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e0c:	55                   	push   %ebp
  801e0d:	89 e5                	mov    %esp,%ebp
  801e0f:	57                   	push   %edi
  801e10:	56                   	push   %esi
  801e11:	53                   	push   %ebx
  801e12:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e18:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e1d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e23:	eb 2d                	jmp    801e52 <devcons_write+0x46>
		m = n - tot;
  801e25:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e28:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e2a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e2d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e32:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e35:	83 ec 04             	sub    $0x4,%esp
  801e38:	53                   	push   %ebx
  801e39:	03 45 0c             	add    0xc(%ebp),%eax
  801e3c:	50                   	push   %eax
  801e3d:	57                   	push   %edi
  801e3e:	e8 2b eb ff ff       	call   80096e <memmove>
		sys_cputs(buf, m);
  801e43:	83 c4 08             	add    $0x8,%esp
  801e46:	53                   	push   %ebx
  801e47:	57                   	push   %edi
  801e48:	e8 d6 ec ff ff       	call   800b23 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e4d:	01 de                	add    %ebx,%esi
  801e4f:	83 c4 10             	add    $0x10,%esp
  801e52:	89 f0                	mov    %esi,%eax
  801e54:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e57:	72 cc                	jb     801e25 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e5c:	5b                   	pop    %ebx
  801e5d:	5e                   	pop    %esi
  801e5e:	5f                   	pop    %edi
  801e5f:	5d                   	pop    %ebp
  801e60:	c3                   	ret    

00801e61 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e61:	55                   	push   %ebp
  801e62:	89 e5                	mov    %esp,%ebp
  801e64:	83 ec 08             	sub    $0x8,%esp
  801e67:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e6c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e70:	74 2a                	je     801e9c <devcons_read+0x3b>
  801e72:	eb 05                	jmp    801e79 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e74:	e8 47 ed ff ff       	call   800bc0 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e79:	e8 c3 ec ff ff       	call   800b41 <sys_cgetc>
  801e7e:	85 c0                	test   %eax,%eax
  801e80:	74 f2                	je     801e74 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e82:	85 c0                	test   %eax,%eax
  801e84:	78 16                	js     801e9c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e86:	83 f8 04             	cmp    $0x4,%eax
  801e89:	74 0c                	je     801e97 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e8e:	88 02                	mov    %al,(%edx)
	return 1;
  801e90:	b8 01 00 00 00       	mov    $0x1,%eax
  801e95:	eb 05                	jmp    801e9c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e97:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e9c:	c9                   	leave  
  801e9d:	c3                   	ret    

00801e9e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e9e:	55                   	push   %ebp
  801e9f:	89 e5                	mov    %esp,%ebp
  801ea1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ea4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801eaa:	6a 01                	push   $0x1
  801eac:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eaf:	50                   	push   %eax
  801eb0:	e8 6e ec ff ff       	call   800b23 <sys_cputs>
}
  801eb5:	83 c4 10             	add    $0x10,%esp
  801eb8:	c9                   	leave  
  801eb9:	c3                   	ret    

00801eba <getchar>:

int
getchar(void)
{
  801eba:	55                   	push   %ebp
  801ebb:	89 e5                	mov    %esp,%ebp
  801ebd:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ec0:	6a 01                	push   $0x1
  801ec2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ec5:	50                   	push   %eax
  801ec6:	6a 00                	push   $0x0
  801ec8:	e8 7e f6 ff ff       	call   80154b <read>
	if (r < 0)
  801ecd:	83 c4 10             	add    $0x10,%esp
  801ed0:	85 c0                	test   %eax,%eax
  801ed2:	78 0f                	js     801ee3 <getchar+0x29>
		return r;
	if (r < 1)
  801ed4:	85 c0                	test   %eax,%eax
  801ed6:	7e 06                	jle    801ede <getchar+0x24>
		return -E_EOF;
	return c;
  801ed8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801edc:	eb 05                	jmp    801ee3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ede:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ee3:	c9                   	leave  
  801ee4:	c3                   	ret    

00801ee5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ee5:	55                   	push   %ebp
  801ee6:	89 e5                	mov    %esp,%ebp
  801ee8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eeb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eee:	50                   	push   %eax
  801eef:	ff 75 08             	pushl  0x8(%ebp)
  801ef2:	e8 eb f3 ff ff       	call   8012e2 <fd_lookup>
  801ef7:	83 c4 10             	add    $0x10,%esp
  801efa:	85 c0                	test   %eax,%eax
  801efc:	78 11                	js     801f0f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801efe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f01:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f07:	39 10                	cmp    %edx,(%eax)
  801f09:	0f 94 c0             	sete   %al
  801f0c:	0f b6 c0             	movzbl %al,%eax
}
  801f0f:	c9                   	leave  
  801f10:	c3                   	ret    

00801f11 <opencons>:

int
opencons(void)
{
  801f11:	55                   	push   %ebp
  801f12:	89 e5                	mov    %esp,%ebp
  801f14:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f17:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f1a:	50                   	push   %eax
  801f1b:	e8 73 f3 ff ff       	call   801293 <fd_alloc>
  801f20:	83 c4 10             	add    $0x10,%esp
		return r;
  801f23:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f25:	85 c0                	test   %eax,%eax
  801f27:	78 3e                	js     801f67 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f29:	83 ec 04             	sub    $0x4,%esp
  801f2c:	68 07 04 00 00       	push   $0x407
  801f31:	ff 75 f4             	pushl  -0xc(%ebp)
  801f34:	6a 00                	push   $0x0
  801f36:	e8 a4 ec ff ff       	call   800bdf <sys_page_alloc>
  801f3b:	83 c4 10             	add    $0x10,%esp
		return r;
  801f3e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f40:	85 c0                	test   %eax,%eax
  801f42:	78 23                	js     801f67 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f44:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f4d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f52:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f59:	83 ec 0c             	sub    $0xc,%esp
  801f5c:	50                   	push   %eax
  801f5d:	e8 0a f3 ff ff       	call   80126c <fd2num>
  801f62:	89 c2                	mov    %eax,%edx
  801f64:	83 c4 10             	add    $0x10,%esp
}
  801f67:	89 d0                	mov    %edx,%eax
  801f69:	c9                   	leave  
  801f6a:	c3                   	ret    

00801f6b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f6b:	55                   	push   %ebp
  801f6c:	89 e5                	mov    %esp,%ebp
  801f6e:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f71:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f78:	75 2a                	jne    801fa4 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801f7a:	83 ec 04             	sub    $0x4,%esp
  801f7d:	6a 07                	push   $0x7
  801f7f:	68 00 f0 bf ee       	push   $0xeebff000
  801f84:	6a 00                	push   $0x0
  801f86:	e8 54 ec ff ff       	call   800bdf <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801f8b:	83 c4 10             	add    $0x10,%esp
  801f8e:	85 c0                	test   %eax,%eax
  801f90:	79 12                	jns    801fa4 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801f92:	50                   	push   %eax
  801f93:	68 ee 27 80 00       	push   $0x8027ee
  801f98:	6a 23                	push   $0x23
  801f9a:	68 f2 27 80 00       	push   $0x8027f2
  801f9f:	e8 da e1 ff ff       	call   80017e <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fa4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa7:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801fac:	83 ec 08             	sub    $0x8,%esp
  801faf:	68 d6 1f 80 00       	push   $0x801fd6
  801fb4:	6a 00                	push   $0x0
  801fb6:	e8 6f ed ff ff       	call   800d2a <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801fbb:	83 c4 10             	add    $0x10,%esp
  801fbe:	85 c0                	test   %eax,%eax
  801fc0:	79 12                	jns    801fd4 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801fc2:	50                   	push   %eax
  801fc3:	68 ee 27 80 00       	push   $0x8027ee
  801fc8:	6a 2c                	push   $0x2c
  801fca:	68 f2 27 80 00       	push   $0x8027f2
  801fcf:	e8 aa e1 ff ff       	call   80017e <_panic>
	}
}
  801fd4:	c9                   	leave  
  801fd5:	c3                   	ret    

00801fd6 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fd6:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fd7:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fdc:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fde:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801fe1:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801fe5:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801fea:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801fee:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801ff0:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801ff3:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801ff4:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801ff7:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801ff8:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801ff9:	c3                   	ret    

00801ffa <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ffa:	55                   	push   %ebp
  801ffb:	89 e5                	mov    %esp,%ebp
  801ffd:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802000:	89 d0                	mov    %edx,%eax
  802002:	c1 e8 16             	shr    $0x16,%eax
  802005:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80200c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802011:	f6 c1 01             	test   $0x1,%cl
  802014:	74 1d                	je     802033 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802016:	c1 ea 0c             	shr    $0xc,%edx
  802019:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802020:	f6 c2 01             	test   $0x1,%dl
  802023:	74 0e                	je     802033 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802025:	c1 ea 0c             	shr    $0xc,%edx
  802028:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80202f:	ef 
  802030:	0f b7 c0             	movzwl %ax,%eax
}
  802033:	5d                   	pop    %ebp
  802034:	c3                   	ret    
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
