
obj/user/testshell.debug:     file format elf32-i386


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
  80002c:	e8 cc 00 00 00       	call   8000fd <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <func>:

struct Mutex* mtx;
int global;

void func()
{	
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	bb 0a 00 00 00       	mov    $0xa,%ebx
	int i;
	for(i = 0; i < 10; i++)
	{
		mutex_lock(mtx);
  80003f:	83 ec 0c             	sub    $0xc,%esp
  800042:	ff 35 08 40 80 00    	pushl  0x804008
  800048:	e8 35 11 00 00       	call   801182 <mutex_lock>
		//("curenv: %d\n", sys_getenvid());
		cprintf("global++: %d\n", global++);
  80004d:	a1 04 40 80 00       	mov    0x804004,%eax
  800052:	8d 50 01             	lea    0x1(%eax),%edx
  800055:	89 15 04 40 80 00    	mov    %edx,0x804004
  80005b:	83 c4 08             	add    $0x8,%esp
  80005e:	50                   	push   %eax
  80005f:	68 c0 24 80 00       	push   $0x8024c0
  800064:	e8 aa 01 00 00       	call   800213 <cprintf>
		//mutex_destroy(mtx);		
		mutex_unlock(mtx);
  800069:	83 c4 04             	add    $0x4,%esp
  80006c:	ff 35 08 40 80 00    	pushl  0x804008
  800072:	e8 78 11 00 00       	call   8011ef <mutex_unlock>
int global;

void func()
{	
	int i;
	for(i = 0; i < 10; i++)
  800077:	83 c4 10             	add    $0x10,%esp
  80007a:	83 eb 01             	sub    $0x1,%ebx
  80007d:	75 c0                	jne    80003f <func+0xc>
		//("curenv: %d\n", sys_getenvid());
		cprintf("global++: %d\n", global++);
		//mutex_destroy(mtx);		
		mutex_unlock(mtx);
	}
}
  80007f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800082:	c9                   	leave  
  800083:	c3                   	ret    

00800084 <test>:

void test()
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	53                   	push   %ebx
  800088:	83 ec 04             	sub    $0x4,%esp
  80008b:	bb 0a 00 00 00       	mov    $0xa,%ebx
	int i;
	for(i = 0; i < 10; i++)
	{
		cprintf("mY\n");
  800090:	83 ec 0c             	sub    $0xc,%esp
  800093:	68 ce 24 80 00       	push   $0x8024ce
  800098:	e8 76 01 00 00       	call   800213 <cprintf>
}

void test()
{
	int i;
	for(i = 0; i < 10; i++)
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	83 eb 01             	sub    $0x1,%ebx
  8000a3:	75 eb                	jne    800090 <test+0xc>
	{
		cprintf("mY\n");
	}
}
  8000a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <umain>:

void
umain(int argc, char **argv)
{	
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	56                   	push   %esi
  8000ae:	53                   	push   %ebx
	global = 0;
  8000af:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  8000b6:	00 00 00 
	mutex_init(mtx);
  8000b9:	83 ec 0c             	sub    $0xc,%esp
  8000bc:	ff 35 08 40 80 00    	pushl  0x804008
  8000c2:	e8 7a 11 00 00       	call   801241 <mutex_init>
 	envid_t id = thread_create(func);
  8000c7:	c7 04 24 33 00 80 00 	movl   $0x800033,(%esp)
  8000ce:	e8 cc 0f 00 00       	call   80109f <thread_create>
  8000d3:	89 c6                	mov    %eax,%esi
	envid_t id2 = thread_create(func);
  8000d5:	c7 04 24 33 00 80 00 	movl   $0x800033,(%esp)
  8000dc:	e8 be 0f 00 00       	call   80109f <thread_create>
  8000e1:	89 c3                	mov    %eax,%ebx
	thread_join(id);
  8000e3:	89 34 24             	mov    %esi,(%esp)
  8000e6:	e8 e1 0f 00 00       	call   8010cc <thread_join>
	thread_join(id2);
  8000eb:	89 1c 24             	mov    %ebx,(%esp)
  8000ee:	e8 d9 0f 00 00       	call   8010cc <thread_join>
	//mutex_destroy(mtx);
}
  8000f3:	83 c4 10             	add    $0x10,%esp
  8000f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5d                   	pop    %ebp
  8000fc:	c3                   	ret    

008000fd <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fd:	55                   	push   %ebp
  8000fe:	89 e5                	mov    %esp,%ebp
  800100:	56                   	push   %esi
  800101:	53                   	push   %ebx
  800102:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800105:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800108:	e8 50 0a 00 00       	call   800b5d <sys_getenvid>
  80010d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800112:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800118:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011d:	a3 0c 40 80 00       	mov    %eax,0x80400c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800122:	85 db                	test   %ebx,%ebx
  800124:	7e 07                	jle    80012d <libmain+0x30>
		binaryname = argv[0];
  800126:	8b 06                	mov    (%esi),%eax
  800128:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012d:	83 ec 08             	sub    $0x8,%esp
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
  800132:	e8 73 ff ff ff       	call   8000aa <umain>

	// exit gracefully
	exit();
  800137:	e8 2a 00 00 00       	call   800166 <exit>
}
  80013c:	83 c4 10             	add    $0x10,%esp
  80013f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5d                   	pop    %ebp
  800145:	c3                   	ret    

00800146 <thread_main>:

/*Lab 7: Multithreading thread main routine*/
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	83 ec 08             	sub    $0x8,%esp
	void (*func)(void) = (void (*)(void))eip;
  80014c:	a1 10 40 80 00       	mov    0x804010,%eax
	func();
  800151:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800153:	e8 05 0a 00 00       	call   800b5d <sys_getenvid>
  800158:	83 ec 0c             	sub    $0xc,%esp
  80015b:	50                   	push   %eax
  80015c:	e8 4b 0c 00 00       	call   800dac <sys_thread_free>
}
  800161:	83 c4 10             	add    $0x10,%esp
  800164:	c9                   	leave  
  800165:	c3                   	ret    

00800166 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80016c:	e8 47 13 00 00       	call   8014b8 <close_all>
	sys_env_destroy(0);
  800171:	83 ec 0c             	sub    $0xc,%esp
  800174:	6a 00                	push   $0x0
  800176:	e8 a1 09 00 00       	call   800b1c <sys_env_destroy>
}
  80017b:	83 c4 10             	add    $0x10,%esp
  80017e:	c9                   	leave  
  80017f:	c3                   	ret    

00800180 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	53                   	push   %ebx
  800184:	83 ec 04             	sub    $0x4,%esp
  800187:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018a:	8b 13                	mov    (%ebx),%edx
  80018c:	8d 42 01             	lea    0x1(%edx),%eax
  80018f:	89 03                	mov    %eax,(%ebx)
  800191:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800194:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800198:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019d:	75 1a                	jne    8001b9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80019f:	83 ec 08             	sub    $0x8,%esp
  8001a2:	68 ff 00 00 00       	push   $0xff
  8001a7:	8d 43 08             	lea    0x8(%ebx),%eax
  8001aa:	50                   	push   %eax
  8001ab:	e8 2f 09 00 00       	call   800adf <sys_cputs>
		b->idx = 0;
  8001b0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001b9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c0:	c9                   	leave  
  8001c1:	c3                   	ret    

008001c2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c2:	55                   	push   %ebp
  8001c3:	89 e5                	mov    %esp,%ebp
  8001c5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001cb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d2:	00 00 00 
	b.cnt = 0;
  8001d5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001dc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001df:	ff 75 0c             	pushl  0xc(%ebp)
  8001e2:	ff 75 08             	pushl  0x8(%ebp)
  8001e5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001eb:	50                   	push   %eax
  8001ec:	68 80 01 80 00       	push   $0x800180
  8001f1:	e8 54 01 00 00       	call   80034a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f6:	83 c4 08             	add    $0x8,%esp
  8001f9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ff:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800205:	50                   	push   %eax
  800206:	e8 d4 08 00 00       	call   800adf <sys_cputs>

	return b.cnt;
}
  80020b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800211:	c9                   	leave  
  800212:	c3                   	ret    

00800213 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800213:	55                   	push   %ebp
  800214:	89 e5                	mov    %esp,%ebp
  800216:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800219:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021c:	50                   	push   %eax
  80021d:	ff 75 08             	pushl  0x8(%ebp)
  800220:	e8 9d ff ff ff       	call   8001c2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800225:	c9                   	leave  
  800226:	c3                   	ret    

00800227 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	57                   	push   %edi
  80022b:	56                   	push   %esi
  80022c:	53                   	push   %ebx
  80022d:	83 ec 1c             	sub    $0x1c,%esp
  800230:	89 c7                	mov    %eax,%edi
  800232:	89 d6                	mov    %edx,%esi
  800234:	8b 45 08             	mov    0x8(%ebp),%eax
  800237:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800240:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800243:	bb 00 00 00 00       	mov    $0x0,%ebx
  800248:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80024b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80024e:	39 d3                	cmp    %edx,%ebx
  800250:	72 05                	jb     800257 <printnum+0x30>
  800252:	39 45 10             	cmp    %eax,0x10(%ebp)
  800255:	77 45                	ja     80029c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800257:	83 ec 0c             	sub    $0xc,%esp
  80025a:	ff 75 18             	pushl  0x18(%ebp)
  80025d:	8b 45 14             	mov    0x14(%ebp),%eax
  800260:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800263:	53                   	push   %ebx
  800264:	ff 75 10             	pushl  0x10(%ebp)
  800267:	83 ec 08             	sub    $0x8,%esp
  80026a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026d:	ff 75 e0             	pushl  -0x20(%ebp)
  800270:	ff 75 dc             	pushl  -0x24(%ebp)
  800273:	ff 75 d8             	pushl  -0x28(%ebp)
  800276:	e8 a5 1f 00 00       	call   802220 <__udivdi3>
  80027b:	83 c4 18             	add    $0x18,%esp
  80027e:	52                   	push   %edx
  80027f:	50                   	push   %eax
  800280:	89 f2                	mov    %esi,%edx
  800282:	89 f8                	mov    %edi,%eax
  800284:	e8 9e ff ff ff       	call   800227 <printnum>
  800289:	83 c4 20             	add    $0x20,%esp
  80028c:	eb 18                	jmp    8002a6 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80028e:	83 ec 08             	sub    $0x8,%esp
  800291:	56                   	push   %esi
  800292:	ff 75 18             	pushl  0x18(%ebp)
  800295:	ff d7                	call   *%edi
  800297:	83 c4 10             	add    $0x10,%esp
  80029a:	eb 03                	jmp    80029f <printnum+0x78>
  80029c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029f:	83 eb 01             	sub    $0x1,%ebx
  8002a2:	85 db                	test   %ebx,%ebx
  8002a4:	7f e8                	jg     80028e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a6:	83 ec 08             	sub    $0x8,%esp
  8002a9:	56                   	push   %esi
  8002aa:	83 ec 04             	sub    $0x4,%esp
  8002ad:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b9:	e8 92 20 00 00       	call   802350 <__umoddi3>
  8002be:	83 c4 14             	add    $0x14,%esp
  8002c1:	0f be 80 dc 24 80 00 	movsbl 0x8024dc(%eax),%eax
  8002c8:	50                   	push   %eax
  8002c9:	ff d7                	call   *%edi
}
  8002cb:	83 c4 10             	add    $0x10,%esp
  8002ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	5f                   	pop    %edi
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d9:	83 fa 01             	cmp    $0x1,%edx
  8002dc:	7e 0e                	jle    8002ec <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002de:	8b 10                	mov    (%eax),%edx
  8002e0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e3:	89 08                	mov    %ecx,(%eax)
  8002e5:	8b 02                	mov    (%edx),%eax
  8002e7:	8b 52 04             	mov    0x4(%edx),%edx
  8002ea:	eb 22                	jmp    80030e <getuint+0x38>
	else if (lflag)
  8002ec:	85 d2                	test   %edx,%edx
  8002ee:	74 10                	je     800300 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f5:	89 08                	mov    %ecx,(%eax)
  8002f7:	8b 02                	mov    (%edx),%eax
  8002f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fe:	eb 0e                	jmp    80030e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800300:	8b 10                	mov    (%eax),%edx
  800302:	8d 4a 04             	lea    0x4(%edx),%ecx
  800305:	89 08                	mov    %ecx,(%eax)
  800307:	8b 02                	mov    (%edx),%eax
  800309:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80030e:	5d                   	pop    %ebp
  80030f:	c3                   	ret    

00800310 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800316:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80031a:	8b 10                	mov    (%eax),%edx
  80031c:	3b 50 04             	cmp    0x4(%eax),%edx
  80031f:	73 0a                	jae    80032b <sprintputch+0x1b>
		*b->buf++ = ch;
  800321:	8d 4a 01             	lea    0x1(%edx),%ecx
  800324:	89 08                	mov    %ecx,(%eax)
  800326:	8b 45 08             	mov    0x8(%ebp),%eax
  800329:	88 02                	mov    %al,(%edx)
}
  80032b:	5d                   	pop    %ebp
  80032c:	c3                   	ret    

0080032d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
  800330:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800333:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800336:	50                   	push   %eax
  800337:	ff 75 10             	pushl  0x10(%ebp)
  80033a:	ff 75 0c             	pushl  0xc(%ebp)
  80033d:	ff 75 08             	pushl  0x8(%ebp)
  800340:	e8 05 00 00 00       	call   80034a <vprintfmt>
	va_end(ap);
}
  800345:	83 c4 10             	add    $0x10,%esp
  800348:	c9                   	leave  
  800349:	c3                   	ret    

0080034a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
  80034d:	57                   	push   %edi
  80034e:	56                   	push   %esi
  80034f:	53                   	push   %ebx
  800350:	83 ec 2c             	sub    $0x2c,%esp
  800353:	8b 75 08             	mov    0x8(%ebp),%esi
  800356:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800359:	8b 7d 10             	mov    0x10(%ebp),%edi
  80035c:	eb 12                	jmp    800370 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80035e:	85 c0                	test   %eax,%eax
  800360:	0f 84 89 03 00 00    	je     8006ef <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800366:	83 ec 08             	sub    $0x8,%esp
  800369:	53                   	push   %ebx
  80036a:	50                   	push   %eax
  80036b:	ff d6                	call   *%esi
  80036d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800370:	83 c7 01             	add    $0x1,%edi
  800373:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800377:	83 f8 25             	cmp    $0x25,%eax
  80037a:	75 e2                	jne    80035e <vprintfmt+0x14>
  80037c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800380:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800387:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80038e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800395:	ba 00 00 00 00       	mov    $0x0,%edx
  80039a:	eb 07                	jmp    8003a3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80039f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a3:	8d 47 01             	lea    0x1(%edi),%eax
  8003a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a9:	0f b6 07             	movzbl (%edi),%eax
  8003ac:	0f b6 c8             	movzbl %al,%ecx
  8003af:	83 e8 23             	sub    $0x23,%eax
  8003b2:	3c 55                	cmp    $0x55,%al
  8003b4:	0f 87 1a 03 00 00    	ja     8006d4 <vprintfmt+0x38a>
  8003ba:	0f b6 c0             	movzbl %al,%eax
  8003bd:	ff 24 85 20 26 80 00 	jmp    *0x802620(,%eax,4)
  8003c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003cb:	eb d6                	jmp    8003a3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003d8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003db:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003df:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003e2:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003e5:	83 fa 09             	cmp    $0x9,%edx
  8003e8:	77 39                	ja     800423 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ea:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ed:	eb e9                	jmp    8003d8 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f2:	8d 48 04             	lea    0x4(%eax),%ecx
  8003f5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003f8:	8b 00                	mov    (%eax),%eax
  8003fa:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800400:	eb 27                	jmp    800429 <vprintfmt+0xdf>
  800402:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800405:	85 c0                	test   %eax,%eax
  800407:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040c:	0f 49 c8             	cmovns %eax,%ecx
  80040f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800412:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800415:	eb 8c                	jmp    8003a3 <vprintfmt+0x59>
  800417:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80041a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800421:	eb 80                	jmp    8003a3 <vprintfmt+0x59>
  800423:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800426:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800429:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042d:	0f 89 70 ff ff ff    	jns    8003a3 <vprintfmt+0x59>
				width = precision, precision = -1;
  800433:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800436:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800439:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800440:	e9 5e ff ff ff       	jmp    8003a3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800445:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800448:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80044b:	e9 53 ff ff ff       	jmp    8003a3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800450:	8b 45 14             	mov    0x14(%ebp),%eax
  800453:	8d 50 04             	lea    0x4(%eax),%edx
  800456:	89 55 14             	mov    %edx,0x14(%ebp)
  800459:	83 ec 08             	sub    $0x8,%esp
  80045c:	53                   	push   %ebx
  80045d:	ff 30                	pushl  (%eax)
  80045f:	ff d6                	call   *%esi
			break;
  800461:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800464:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800467:	e9 04 ff ff ff       	jmp    800370 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046c:	8b 45 14             	mov    0x14(%ebp),%eax
  80046f:	8d 50 04             	lea    0x4(%eax),%edx
  800472:	89 55 14             	mov    %edx,0x14(%ebp)
  800475:	8b 00                	mov    (%eax),%eax
  800477:	99                   	cltd   
  800478:	31 d0                	xor    %edx,%eax
  80047a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80047c:	83 f8 0f             	cmp    $0xf,%eax
  80047f:	7f 0b                	jg     80048c <vprintfmt+0x142>
  800481:	8b 14 85 80 27 80 00 	mov    0x802780(,%eax,4),%edx
  800488:	85 d2                	test   %edx,%edx
  80048a:	75 18                	jne    8004a4 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80048c:	50                   	push   %eax
  80048d:	68 f4 24 80 00       	push   $0x8024f4
  800492:	53                   	push   %ebx
  800493:	56                   	push   %esi
  800494:	e8 94 fe ff ff       	call   80032d <printfmt>
  800499:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80049f:	e9 cc fe ff ff       	jmp    800370 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004a4:	52                   	push   %edx
  8004a5:	68 3d 29 80 00       	push   $0x80293d
  8004aa:	53                   	push   %ebx
  8004ab:	56                   	push   %esi
  8004ac:	e8 7c fe ff ff       	call   80032d <printfmt>
  8004b1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b7:	e9 b4 fe ff ff       	jmp    800370 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bf:	8d 50 04             	lea    0x4(%eax),%edx
  8004c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004c7:	85 ff                	test   %edi,%edi
  8004c9:	b8 ed 24 80 00       	mov    $0x8024ed,%eax
  8004ce:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004d1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d5:	0f 8e 94 00 00 00    	jle    80056f <vprintfmt+0x225>
  8004db:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004df:	0f 84 98 00 00 00    	je     80057d <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e5:	83 ec 08             	sub    $0x8,%esp
  8004e8:	ff 75 d0             	pushl  -0x30(%ebp)
  8004eb:	57                   	push   %edi
  8004ec:	e8 86 02 00 00       	call   800777 <strnlen>
  8004f1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f4:	29 c1                	sub    %eax,%ecx
  8004f6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004f9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004fc:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800500:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800503:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800506:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800508:	eb 0f                	jmp    800519 <vprintfmt+0x1cf>
					putch(padc, putdat);
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	53                   	push   %ebx
  80050e:	ff 75 e0             	pushl  -0x20(%ebp)
  800511:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800513:	83 ef 01             	sub    $0x1,%edi
  800516:	83 c4 10             	add    $0x10,%esp
  800519:	85 ff                	test   %edi,%edi
  80051b:	7f ed                	jg     80050a <vprintfmt+0x1c0>
  80051d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800520:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800523:	85 c9                	test   %ecx,%ecx
  800525:	b8 00 00 00 00       	mov    $0x0,%eax
  80052a:	0f 49 c1             	cmovns %ecx,%eax
  80052d:	29 c1                	sub    %eax,%ecx
  80052f:	89 75 08             	mov    %esi,0x8(%ebp)
  800532:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800535:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800538:	89 cb                	mov    %ecx,%ebx
  80053a:	eb 4d                	jmp    800589 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80053c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800540:	74 1b                	je     80055d <vprintfmt+0x213>
  800542:	0f be c0             	movsbl %al,%eax
  800545:	83 e8 20             	sub    $0x20,%eax
  800548:	83 f8 5e             	cmp    $0x5e,%eax
  80054b:	76 10                	jbe    80055d <vprintfmt+0x213>
					putch('?', putdat);
  80054d:	83 ec 08             	sub    $0x8,%esp
  800550:	ff 75 0c             	pushl  0xc(%ebp)
  800553:	6a 3f                	push   $0x3f
  800555:	ff 55 08             	call   *0x8(%ebp)
  800558:	83 c4 10             	add    $0x10,%esp
  80055b:	eb 0d                	jmp    80056a <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80055d:	83 ec 08             	sub    $0x8,%esp
  800560:	ff 75 0c             	pushl  0xc(%ebp)
  800563:	52                   	push   %edx
  800564:	ff 55 08             	call   *0x8(%ebp)
  800567:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056a:	83 eb 01             	sub    $0x1,%ebx
  80056d:	eb 1a                	jmp    800589 <vprintfmt+0x23f>
  80056f:	89 75 08             	mov    %esi,0x8(%ebp)
  800572:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800575:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800578:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057b:	eb 0c                	jmp    800589 <vprintfmt+0x23f>
  80057d:	89 75 08             	mov    %esi,0x8(%ebp)
  800580:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800583:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800586:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800589:	83 c7 01             	add    $0x1,%edi
  80058c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800590:	0f be d0             	movsbl %al,%edx
  800593:	85 d2                	test   %edx,%edx
  800595:	74 23                	je     8005ba <vprintfmt+0x270>
  800597:	85 f6                	test   %esi,%esi
  800599:	78 a1                	js     80053c <vprintfmt+0x1f2>
  80059b:	83 ee 01             	sub    $0x1,%esi
  80059e:	79 9c                	jns    80053c <vprintfmt+0x1f2>
  8005a0:	89 df                	mov    %ebx,%edi
  8005a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a8:	eb 18                	jmp    8005c2 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005aa:	83 ec 08             	sub    $0x8,%esp
  8005ad:	53                   	push   %ebx
  8005ae:	6a 20                	push   $0x20
  8005b0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b2:	83 ef 01             	sub    $0x1,%edi
  8005b5:	83 c4 10             	add    $0x10,%esp
  8005b8:	eb 08                	jmp    8005c2 <vprintfmt+0x278>
  8005ba:	89 df                	mov    %ebx,%edi
  8005bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8005bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c2:	85 ff                	test   %edi,%edi
  8005c4:	7f e4                	jg     8005aa <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c9:	e9 a2 fd ff ff       	jmp    800370 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ce:	83 fa 01             	cmp    $0x1,%edx
  8005d1:	7e 16                	jle    8005e9 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8d 50 08             	lea    0x8(%eax),%edx
  8005d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005dc:	8b 50 04             	mov    0x4(%eax),%edx
  8005df:	8b 00                	mov    (%eax),%eax
  8005e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e7:	eb 32                	jmp    80061b <vprintfmt+0x2d1>
	else if (lflag)
  8005e9:	85 d2                	test   %edx,%edx
  8005eb:	74 18                	je     800605 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8d 50 04             	lea    0x4(%eax),%edx
  8005f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f6:	8b 00                	mov    (%eax),%eax
  8005f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fb:	89 c1                	mov    %eax,%ecx
  8005fd:	c1 f9 1f             	sar    $0x1f,%ecx
  800600:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800603:	eb 16                	jmp    80061b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800605:	8b 45 14             	mov    0x14(%ebp),%eax
  800608:	8d 50 04             	lea    0x4(%eax),%edx
  80060b:	89 55 14             	mov    %edx,0x14(%ebp)
  80060e:	8b 00                	mov    (%eax),%eax
  800610:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800613:	89 c1                	mov    %eax,%ecx
  800615:	c1 f9 1f             	sar    $0x1f,%ecx
  800618:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80061e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800621:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800626:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80062a:	79 74                	jns    8006a0 <vprintfmt+0x356>
				putch('-', putdat);
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	53                   	push   %ebx
  800630:	6a 2d                	push   $0x2d
  800632:	ff d6                	call   *%esi
				num = -(long long) num;
  800634:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800637:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80063a:	f7 d8                	neg    %eax
  80063c:	83 d2 00             	adc    $0x0,%edx
  80063f:	f7 da                	neg    %edx
  800641:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800644:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800649:	eb 55                	jmp    8006a0 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80064b:	8d 45 14             	lea    0x14(%ebp),%eax
  80064e:	e8 83 fc ff ff       	call   8002d6 <getuint>
			base = 10;
  800653:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800658:	eb 46                	jmp    8006a0 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80065a:	8d 45 14             	lea    0x14(%ebp),%eax
  80065d:	e8 74 fc ff ff       	call   8002d6 <getuint>
			base = 8;
  800662:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800667:	eb 37                	jmp    8006a0 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800669:	83 ec 08             	sub    $0x8,%esp
  80066c:	53                   	push   %ebx
  80066d:	6a 30                	push   $0x30
  80066f:	ff d6                	call   *%esi
			putch('x', putdat);
  800671:	83 c4 08             	add    $0x8,%esp
  800674:	53                   	push   %ebx
  800675:	6a 78                	push   $0x78
  800677:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800679:	8b 45 14             	mov    0x14(%ebp),%eax
  80067c:	8d 50 04             	lea    0x4(%eax),%edx
  80067f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800682:	8b 00                	mov    (%eax),%eax
  800684:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800689:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80068c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800691:	eb 0d                	jmp    8006a0 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800693:	8d 45 14             	lea    0x14(%ebp),%eax
  800696:	e8 3b fc ff ff       	call   8002d6 <getuint>
			base = 16;
  80069b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a0:	83 ec 0c             	sub    $0xc,%esp
  8006a3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006a7:	57                   	push   %edi
  8006a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ab:	51                   	push   %ecx
  8006ac:	52                   	push   %edx
  8006ad:	50                   	push   %eax
  8006ae:	89 da                	mov    %ebx,%edx
  8006b0:	89 f0                	mov    %esi,%eax
  8006b2:	e8 70 fb ff ff       	call   800227 <printnum>
			break;
  8006b7:	83 c4 20             	add    $0x20,%esp
  8006ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006bd:	e9 ae fc ff ff       	jmp    800370 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c2:	83 ec 08             	sub    $0x8,%esp
  8006c5:	53                   	push   %ebx
  8006c6:	51                   	push   %ecx
  8006c7:	ff d6                	call   *%esi
			break;
  8006c9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006cf:	e9 9c fc ff ff       	jmp    800370 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d4:	83 ec 08             	sub    $0x8,%esp
  8006d7:	53                   	push   %ebx
  8006d8:	6a 25                	push   $0x25
  8006da:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006dc:	83 c4 10             	add    $0x10,%esp
  8006df:	eb 03                	jmp    8006e4 <vprintfmt+0x39a>
  8006e1:	83 ef 01             	sub    $0x1,%edi
  8006e4:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006e8:	75 f7                	jne    8006e1 <vprintfmt+0x397>
  8006ea:	e9 81 fc ff ff       	jmp    800370 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f2:	5b                   	pop    %ebx
  8006f3:	5e                   	pop    %esi
  8006f4:	5f                   	pop    %edi
  8006f5:	5d                   	pop    %ebp
  8006f6:	c3                   	ret    

008006f7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f7:	55                   	push   %ebp
  8006f8:	89 e5                	mov    %esp,%ebp
  8006fa:	83 ec 18             	sub    $0x18,%esp
  8006fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800700:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800703:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800706:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80070a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800714:	85 c0                	test   %eax,%eax
  800716:	74 26                	je     80073e <vsnprintf+0x47>
  800718:	85 d2                	test   %edx,%edx
  80071a:	7e 22                	jle    80073e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071c:	ff 75 14             	pushl  0x14(%ebp)
  80071f:	ff 75 10             	pushl  0x10(%ebp)
  800722:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800725:	50                   	push   %eax
  800726:	68 10 03 80 00       	push   $0x800310
  80072b:	e8 1a fc ff ff       	call   80034a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800730:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800733:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800736:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800739:	83 c4 10             	add    $0x10,%esp
  80073c:	eb 05                	jmp    800743 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800743:	c9                   	leave  
  800744:	c3                   	ret    

00800745 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074e:	50                   	push   %eax
  80074f:	ff 75 10             	pushl  0x10(%ebp)
  800752:	ff 75 0c             	pushl  0xc(%ebp)
  800755:	ff 75 08             	pushl  0x8(%ebp)
  800758:	e8 9a ff ff ff       	call   8006f7 <vsnprintf>
	va_end(ap);

	return rc;
}
  80075d:	c9                   	leave  
  80075e:	c3                   	ret    

0080075f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80075f:	55                   	push   %ebp
  800760:	89 e5                	mov    %esp,%ebp
  800762:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800765:	b8 00 00 00 00       	mov    $0x0,%eax
  80076a:	eb 03                	jmp    80076f <strlen+0x10>
		n++;
  80076c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80076f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800773:	75 f7                	jne    80076c <strlen+0xd>
		n++;
	return n;
}
  800775:	5d                   	pop    %ebp
  800776:	c3                   	ret    

00800777 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800780:	ba 00 00 00 00       	mov    $0x0,%edx
  800785:	eb 03                	jmp    80078a <strnlen+0x13>
		n++;
  800787:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078a:	39 c2                	cmp    %eax,%edx
  80078c:	74 08                	je     800796 <strnlen+0x1f>
  80078e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800792:	75 f3                	jne    800787 <strnlen+0x10>
  800794:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800796:	5d                   	pop    %ebp
  800797:	c3                   	ret    

00800798 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	53                   	push   %ebx
  80079c:	8b 45 08             	mov    0x8(%ebp),%eax
  80079f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a2:	89 c2                	mov    %eax,%edx
  8007a4:	83 c2 01             	add    $0x1,%edx
  8007a7:	83 c1 01             	add    $0x1,%ecx
  8007aa:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ae:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007b1:	84 db                	test   %bl,%bl
  8007b3:	75 ef                	jne    8007a4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b5:	5b                   	pop    %ebx
  8007b6:	5d                   	pop    %ebp
  8007b7:	c3                   	ret    

008007b8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	53                   	push   %ebx
  8007bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007bf:	53                   	push   %ebx
  8007c0:	e8 9a ff ff ff       	call   80075f <strlen>
  8007c5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c8:	ff 75 0c             	pushl  0xc(%ebp)
  8007cb:	01 d8                	add    %ebx,%eax
  8007cd:	50                   	push   %eax
  8007ce:	e8 c5 ff ff ff       	call   800798 <strcpy>
	return dst;
}
  8007d3:	89 d8                	mov    %ebx,%eax
  8007d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d8:	c9                   	leave  
  8007d9:	c3                   	ret    

008007da <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	56                   	push   %esi
  8007de:	53                   	push   %ebx
  8007df:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e5:	89 f3                	mov    %esi,%ebx
  8007e7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ea:	89 f2                	mov    %esi,%edx
  8007ec:	eb 0f                	jmp    8007fd <strncpy+0x23>
		*dst++ = *src;
  8007ee:	83 c2 01             	add    $0x1,%edx
  8007f1:	0f b6 01             	movzbl (%ecx),%eax
  8007f4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f7:	80 39 01             	cmpb   $0x1,(%ecx)
  8007fa:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fd:	39 da                	cmp    %ebx,%edx
  8007ff:	75 ed                	jne    8007ee <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800801:	89 f0                	mov    %esi,%eax
  800803:	5b                   	pop    %ebx
  800804:	5e                   	pop    %esi
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	56                   	push   %esi
  80080b:	53                   	push   %ebx
  80080c:	8b 75 08             	mov    0x8(%ebp),%esi
  80080f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800812:	8b 55 10             	mov    0x10(%ebp),%edx
  800815:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800817:	85 d2                	test   %edx,%edx
  800819:	74 21                	je     80083c <strlcpy+0x35>
  80081b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80081f:	89 f2                	mov    %esi,%edx
  800821:	eb 09                	jmp    80082c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800823:	83 c2 01             	add    $0x1,%edx
  800826:	83 c1 01             	add    $0x1,%ecx
  800829:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80082c:	39 c2                	cmp    %eax,%edx
  80082e:	74 09                	je     800839 <strlcpy+0x32>
  800830:	0f b6 19             	movzbl (%ecx),%ebx
  800833:	84 db                	test   %bl,%bl
  800835:	75 ec                	jne    800823 <strlcpy+0x1c>
  800837:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800839:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80083c:	29 f0                	sub    %esi,%eax
}
  80083e:	5b                   	pop    %ebx
  80083f:	5e                   	pop    %esi
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800848:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80084b:	eb 06                	jmp    800853 <strcmp+0x11>
		p++, q++;
  80084d:	83 c1 01             	add    $0x1,%ecx
  800850:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800853:	0f b6 01             	movzbl (%ecx),%eax
  800856:	84 c0                	test   %al,%al
  800858:	74 04                	je     80085e <strcmp+0x1c>
  80085a:	3a 02                	cmp    (%edx),%al
  80085c:	74 ef                	je     80084d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085e:	0f b6 c0             	movzbl %al,%eax
  800861:	0f b6 12             	movzbl (%edx),%edx
  800864:	29 d0                	sub    %edx,%eax
}
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	53                   	push   %ebx
  80086c:	8b 45 08             	mov    0x8(%ebp),%eax
  80086f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800872:	89 c3                	mov    %eax,%ebx
  800874:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800877:	eb 06                	jmp    80087f <strncmp+0x17>
		n--, p++, q++;
  800879:	83 c0 01             	add    $0x1,%eax
  80087c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80087f:	39 d8                	cmp    %ebx,%eax
  800881:	74 15                	je     800898 <strncmp+0x30>
  800883:	0f b6 08             	movzbl (%eax),%ecx
  800886:	84 c9                	test   %cl,%cl
  800888:	74 04                	je     80088e <strncmp+0x26>
  80088a:	3a 0a                	cmp    (%edx),%cl
  80088c:	74 eb                	je     800879 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088e:	0f b6 00             	movzbl (%eax),%eax
  800891:	0f b6 12             	movzbl (%edx),%edx
  800894:	29 d0                	sub    %edx,%eax
  800896:	eb 05                	jmp    80089d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800898:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80089d:	5b                   	pop    %ebx
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008aa:	eb 07                	jmp    8008b3 <strchr+0x13>
		if (*s == c)
  8008ac:	38 ca                	cmp    %cl,%dl
  8008ae:	74 0f                	je     8008bf <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b0:	83 c0 01             	add    $0x1,%eax
  8008b3:	0f b6 10             	movzbl (%eax),%edx
  8008b6:	84 d2                	test   %dl,%dl
  8008b8:	75 f2                	jne    8008ac <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cb:	eb 03                	jmp    8008d0 <strfind+0xf>
  8008cd:	83 c0 01             	add    $0x1,%eax
  8008d0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d3:	38 ca                	cmp    %cl,%dl
  8008d5:	74 04                	je     8008db <strfind+0x1a>
  8008d7:	84 d2                	test   %dl,%dl
  8008d9:	75 f2                	jne    8008cd <strfind+0xc>
			break;
	return (char *) s;
}
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    

008008dd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	57                   	push   %edi
  8008e1:	56                   	push   %esi
  8008e2:	53                   	push   %ebx
  8008e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e9:	85 c9                	test   %ecx,%ecx
  8008eb:	74 36                	je     800923 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ed:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f3:	75 28                	jne    80091d <memset+0x40>
  8008f5:	f6 c1 03             	test   $0x3,%cl
  8008f8:	75 23                	jne    80091d <memset+0x40>
		c &= 0xFF;
  8008fa:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008fe:	89 d3                	mov    %edx,%ebx
  800900:	c1 e3 08             	shl    $0x8,%ebx
  800903:	89 d6                	mov    %edx,%esi
  800905:	c1 e6 18             	shl    $0x18,%esi
  800908:	89 d0                	mov    %edx,%eax
  80090a:	c1 e0 10             	shl    $0x10,%eax
  80090d:	09 f0                	or     %esi,%eax
  80090f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800911:	89 d8                	mov    %ebx,%eax
  800913:	09 d0                	or     %edx,%eax
  800915:	c1 e9 02             	shr    $0x2,%ecx
  800918:	fc                   	cld    
  800919:	f3 ab                	rep stos %eax,%es:(%edi)
  80091b:	eb 06                	jmp    800923 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800920:	fc                   	cld    
  800921:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800923:	89 f8                	mov    %edi,%eax
  800925:	5b                   	pop    %ebx
  800926:	5e                   	pop    %esi
  800927:	5f                   	pop    %edi
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	57                   	push   %edi
  80092e:	56                   	push   %esi
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
  800932:	8b 75 0c             	mov    0xc(%ebp),%esi
  800935:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800938:	39 c6                	cmp    %eax,%esi
  80093a:	73 35                	jae    800971 <memmove+0x47>
  80093c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093f:	39 d0                	cmp    %edx,%eax
  800941:	73 2e                	jae    800971 <memmove+0x47>
		s += n;
		d += n;
  800943:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800946:	89 d6                	mov    %edx,%esi
  800948:	09 fe                	or     %edi,%esi
  80094a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800950:	75 13                	jne    800965 <memmove+0x3b>
  800952:	f6 c1 03             	test   $0x3,%cl
  800955:	75 0e                	jne    800965 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800957:	83 ef 04             	sub    $0x4,%edi
  80095a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80095d:	c1 e9 02             	shr    $0x2,%ecx
  800960:	fd                   	std    
  800961:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800963:	eb 09                	jmp    80096e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800965:	83 ef 01             	sub    $0x1,%edi
  800968:	8d 72 ff             	lea    -0x1(%edx),%esi
  80096b:	fd                   	std    
  80096c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096e:	fc                   	cld    
  80096f:	eb 1d                	jmp    80098e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800971:	89 f2                	mov    %esi,%edx
  800973:	09 c2                	or     %eax,%edx
  800975:	f6 c2 03             	test   $0x3,%dl
  800978:	75 0f                	jne    800989 <memmove+0x5f>
  80097a:	f6 c1 03             	test   $0x3,%cl
  80097d:	75 0a                	jne    800989 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80097f:	c1 e9 02             	shr    $0x2,%ecx
  800982:	89 c7                	mov    %eax,%edi
  800984:	fc                   	cld    
  800985:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800987:	eb 05                	jmp    80098e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800989:	89 c7                	mov    %eax,%edi
  80098b:	fc                   	cld    
  80098c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098e:	5e                   	pop    %esi
  80098f:	5f                   	pop    %edi
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800995:	ff 75 10             	pushl  0x10(%ebp)
  800998:	ff 75 0c             	pushl  0xc(%ebp)
  80099b:	ff 75 08             	pushl  0x8(%ebp)
  80099e:	e8 87 ff ff ff       	call   80092a <memmove>
}
  8009a3:	c9                   	leave  
  8009a4:	c3                   	ret    

008009a5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	56                   	push   %esi
  8009a9:	53                   	push   %ebx
  8009aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b0:	89 c6                	mov    %eax,%esi
  8009b2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b5:	eb 1a                	jmp    8009d1 <memcmp+0x2c>
		if (*s1 != *s2)
  8009b7:	0f b6 08             	movzbl (%eax),%ecx
  8009ba:	0f b6 1a             	movzbl (%edx),%ebx
  8009bd:	38 d9                	cmp    %bl,%cl
  8009bf:	74 0a                	je     8009cb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009c1:	0f b6 c1             	movzbl %cl,%eax
  8009c4:	0f b6 db             	movzbl %bl,%ebx
  8009c7:	29 d8                	sub    %ebx,%eax
  8009c9:	eb 0f                	jmp    8009da <memcmp+0x35>
		s1++, s2++;
  8009cb:	83 c0 01             	add    $0x1,%eax
  8009ce:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d1:	39 f0                	cmp    %esi,%eax
  8009d3:	75 e2                	jne    8009b7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009da:	5b                   	pop    %ebx
  8009db:	5e                   	pop    %esi
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	53                   	push   %ebx
  8009e2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009e5:	89 c1                	mov    %eax,%ecx
  8009e7:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ea:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ee:	eb 0a                	jmp    8009fa <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f0:	0f b6 10             	movzbl (%eax),%edx
  8009f3:	39 da                	cmp    %ebx,%edx
  8009f5:	74 07                	je     8009fe <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f7:	83 c0 01             	add    $0x1,%eax
  8009fa:	39 c8                	cmp    %ecx,%eax
  8009fc:	72 f2                	jb     8009f0 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009fe:	5b                   	pop    %ebx
  8009ff:	5d                   	pop    %ebp
  800a00:	c3                   	ret    

00800a01 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	57                   	push   %edi
  800a05:	56                   	push   %esi
  800a06:	53                   	push   %ebx
  800a07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0d:	eb 03                	jmp    800a12 <strtol+0x11>
		s++;
  800a0f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a12:	0f b6 01             	movzbl (%ecx),%eax
  800a15:	3c 20                	cmp    $0x20,%al
  800a17:	74 f6                	je     800a0f <strtol+0xe>
  800a19:	3c 09                	cmp    $0x9,%al
  800a1b:	74 f2                	je     800a0f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a1d:	3c 2b                	cmp    $0x2b,%al
  800a1f:	75 0a                	jne    800a2b <strtol+0x2a>
		s++;
  800a21:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a24:	bf 00 00 00 00       	mov    $0x0,%edi
  800a29:	eb 11                	jmp    800a3c <strtol+0x3b>
  800a2b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a30:	3c 2d                	cmp    $0x2d,%al
  800a32:	75 08                	jne    800a3c <strtol+0x3b>
		s++, neg = 1;
  800a34:	83 c1 01             	add    $0x1,%ecx
  800a37:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a42:	75 15                	jne    800a59 <strtol+0x58>
  800a44:	80 39 30             	cmpb   $0x30,(%ecx)
  800a47:	75 10                	jne    800a59 <strtol+0x58>
  800a49:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a4d:	75 7c                	jne    800acb <strtol+0xca>
		s += 2, base = 16;
  800a4f:	83 c1 02             	add    $0x2,%ecx
  800a52:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a57:	eb 16                	jmp    800a6f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a59:	85 db                	test   %ebx,%ebx
  800a5b:	75 12                	jne    800a6f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a62:	80 39 30             	cmpb   $0x30,(%ecx)
  800a65:	75 08                	jne    800a6f <strtol+0x6e>
		s++, base = 8;
  800a67:	83 c1 01             	add    $0x1,%ecx
  800a6a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a74:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a77:	0f b6 11             	movzbl (%ecx),%edx
  800a7a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a7d:	89 f3                	mov    %esi,%ebx
  800a7f:	80 fb 09             	cmp    $0x9,%bl
  800a82:	77 08                	ja     800a8c <strtol+0x8b>
			dig = *s - '0';
  800a84:	0f be d2             	movsbl %dl,%edx
  800a87:	83 ea 30             	sub    $0x30,%edx
  800a8a:	eb 22                	jmp    800aae <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a8c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a8f:	89 f3                	mov    %esi,%ebx
  800a91:	80 fb 19             	cmp    $0x19,%bl
  800a94:	77 08                	ja     800a9e <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a96:	0f be d2             	movsbl %dl,%edx
  800a99:	83 ea 57             	sub    $0x57,%edx
  800a9c:	eb 10                	jmp    800aae <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a9e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa1:	89 f3                	mov    %esi,%ebx
  800aa3:	80 fb 19             	cmp    $0x19,%bl
  800aa6:	77 16                	ja     800abe <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aa8:	0f be d2             	movsbl %dl,%edx
  800aab:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aae:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ab1:	7d 0b                	jge    800abe <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ab3:	83 c1 01             	add    $0x1,%ecx
  800ab6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aba:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800abc:	eb b9                	jmp    800a77 <strtol+0x76>

	if (endptr)
  800abe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac2:	74 0d                	je     800ad1 <strtol+0xd0>
		*endptr = (char *) s;
  800ac4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac7:	89 0e                	mov    %ecx,(%esi)
  800ac9:	eb 06                	jmp    800ad1 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800acb:	85 db                	test   %ebx,%ebx
  800acd:	74 98                	je     800a67 <strtol+0x66>
  800acf:	eb 9e                	jmp    800a6f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ad1:	89 c2                	mov    %eax,%edx
  800ad3:	f7 da                	neg    %edx
  800ad5:	85 ff                	test   %edi,%edi
  800ad7:	0f 45 c2             	cmovne %edx,%eax
}
  800ada:	5b                   	pop    %ebx
  800adb:	5e                   	pop    %esi
  800adc:	5f                   	pop    %edi
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	57                   	push   %edi
  800ae3:	56                   	push   %esi
  800ae4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aed:	8b 55 08             	mov    0x8(%ebp),%edx
  800af0:	89 c3                	mov    %eax,%ebx
  800af2:	89 c7                	mov    %eax,%edi
  800af4:	89 c6                	mov    %eax,%esi
  800af6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <sys_cgetc>:

int
sys_cgetc(void)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b03:	ba 00 00 00 00       	mov    $0x0,%edx
  800b08:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0d:	89 d1                	mov    %edx,%ecx
  800b0f:	89 d3                	mov    %edx,%ebx
  800b11:	89 d7                	mov    %edx,%edi
  800b13:	89 d6                	mov    %edx,%esi
  800b15:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b17:	5b                   	pop    %ebx
  800b18:	5e                   	pop    %esi
  800b19:	5f                   	pop    %edi
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
  800b22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b25:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b2a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b32:	89 cb                	mov    %ecx,%ebx
  800b34:	89 cf                	mov    %ecx,%edi
  800b36:	89 ce                	mov    %ecx,%esi
  800b38:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b3a:	85 c0                	test   %eax,%eax
  800b3c:	7e 17                	jle    800b55 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3e:	83 ec 0c             	sub    $0xc,%esp
  800b41:	50                   	push   %eax
  800b42:	6a 03                	push   $0x3
  800b44:	68 df 27 80 00       	push   $0x8027df
  800b49:	6a 23                	push   $0x23
  800b4b:	68 fc 27 80 00       	push   $0x8027fc
  800b50:	e8 94 14 00 00       	call   801fe9 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	57                   	push   %edi
  800b61:	56                   	push   %esi
  800b62:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b63:	ba 00 00 00 00       	mov    $0x0,%edx
  800b68:	b8 02 00 00 00       	mov    $0x2,%eax
  800b6d:	89 d1                	mov    %edx,%ecx
  800b6f:	89 d3                	mov    %edx,%ebx
  800b71:	89 d7                	mov    %edx,%edi
  800b73:	89 d6                	mov    %edx,%esi
  800b75:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b77:	5b                   	pop    %ebx
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <sys_yield>:

void
sys_yield(void)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b82:	ba 00 00 00 00       	mov    $0x0,%edx
  800b87:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b8c:	89 d1                	mov    %edx,%ecx
  800b8e:	89 d3                	mov    %edx,%ebx
  800b90:	89 d7                	mov    %edx,%edi
  800b92:	89 d6                	mov    %edx,%esi
  800b94:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	57                   	push   %edi
  800b9f:	56                   	push   %esi
  800ba0:	53                   	push   %ebx
  800ba1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba4:	be 00 00 00 00       	mov    $0x0,%esi
  800ba9:	b8 04 00 00 00       	mov    $0x4,%eax
  800bae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb7:	89 f7                	mov    %esi,%edi
  800bb9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bbb:	85 c0                	test   %eax,%eax
  800bbd:	7e 17                	jle    800bd6 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbf:	83 ec 0c             	sub    $0xc,%esp
  800bc2:	50                   	push   %eax
  800bc3:	6a 04                	push   $0x4
  800bc5:	68 df 27 80 00       	push   $0x8027df
  800bca:	6a 23                	push   $0x23
  800bcc:	68 fc 27 80 00       	push   $0x8027fc
  800bd1:	e8 13 14 00 00       	call   801fe9 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be7:	b8 05 00 00 00       	mov    $0x5,%eax
  800bec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bef:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bf8:	8b 75 18             	mov    0x18(%ebp),%esi
  800bfb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfd:	85 c0                	test   %eax,%eax
  800bff:	7e 17                	jle    800c18 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c01:	83 ec 0c             	sub    $0xc,%esp
  800c04:	50                   	push   %eax
  800c05:	6a 05                	push   $0x5
  800c07:	68 df 27 80 00       	push   $0x8027df
  800c0c:	6a 23                	push   $0x23
  800c0e:	68 fc 27 80 00       	push   $0x8027fc
  800c13:	e8 d1 13 00 00       	call   801fe9 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1b:	5b                   	pop    %ebx
  800c1c:	5e                   	pop    %esi
  800c1d:	5f                   	pop    %edi
  800c1e:	5d                   	pop    %ebp
  800c1f:	c3                   	ret    

00800c20 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800c29:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c36:	8b 55 08             	mov    0x8(%ebp),%edx
  800c39:	89 df                	mov    %ebx,%edi
  800c3b:	89 de                	mov    %ebx,%esi
  800c3d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3f:	85 c0                	test   %eax,%eax
  800c41:	7e 17                	jle    800c5a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c43:	83 ec 0c             	sub    $0xc,%esp
  800c46:	50                   	push   %eax
  800c47:	6a 06                	push   $0x6
  800c49:	68 df 27 80 00       	push   $0x8027df
  800c4e:	6a 23                	push   $0x23
  800c50:	68 fc 27 80 00       	push   $0x8027fc
  800c55:	e8 8f 13 00 00       	call   801fe9 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5d:	5b                   	pop    %ebx
  800c5e:	5e                   	pop    %esi
  800c5f:	5f                   	pop    %edi
  800c60:	5d                   	pop    %ebp
  800c61:	c3                   	ret    

00800c62 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800c70:	b8 08 00 00 00       	mov    $0x8,%eax
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
  800c83:	7e 17                	jle    800c9c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c85:	83 ec 0c             	sub    $0xc,%esp
  800c88:	50                   	push   %eax
  800c89:	6a 08                	push   $0x8
  800c8b:	68 df 27 80 00       	push   $0x8027df
  800c90:	6a 23                	push   $0x23
  800c92:	68 fc 27 80 00       	push   $0x8027fc
  800c97:	e8 4d 13 00 00       	call   801fe9 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5f                   	pop    %edi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800cb2:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800cc5:	7e 17                	jle    800cde <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc7:	83 ec 0c             	sub    $0xc,%esp
  800cca:	50                   	push   %eax
  800ccb:	6a 09                	push   $0x9
  800ccd:	68 df 27 80 00       	push   $0x8027df
  800cd2:	6a 23                	push   $0x23
  800cd4:	68 fc 27 80 00       	push   $0x8027fc
  800cd9:	e8 0b 13 00 00       	call   801fe9 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800cf4:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800d07:	7e 17                	jle    800d20 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d09:	83 ec 0c             	sub    $0xc,%esp
  800d0c:	50                   	push   %eax
  800d0d:	6a 0a                	push   $0xa
  800d0f:	68 df 27 80 00       	push   $0x8027df
  800d14:	6a 23                	push   $0x23
  800d16:	68 fc 27 80 00       	push   $0x8027fc
  800d1b:	e8 c9 12 00 00       	call   801fe9 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d23:	5b                   	pop    %ebx
  800d24:	5e                   	pop    %esi
  800d25:	5f                   	pop    %edi
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    

00800d28 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	57                   	push   %edi
  800d2c:	56                   	push   %esi
  800d2d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2e:	be 00 00 00 00       	mov    $0x0,%esi
  800d33:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d41:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d44:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d46:	5b                   	pop    %ebx
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    

00800d4b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	57                   	push   %edi
  800d4f:	56                   	push   %esi
  800d50:	53                   	push   %ebx
  800d51:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d54:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d59:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d61:	89 cb                	mov    %ecx,%ebx
  800d63:	89 cf                	mov    %ecx,%edi
  800d65:	89 ce                	mov    %ecx,%esi
  800d67:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	7e 17                	jle    800d84 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6d:	83 ec 0c             	sub    $0xc,%esp
  800d70:	50                   	push   %eax
  800d71:	6a 0d                	push   $0xd
  800d73:	68 df 27 80 00       	push   $0x8027df
  800d78:	6a 23                	push   $0x23
  800d7a:	68 fc 27 80 00       	push   $0x8027fc
  800d7f:	e8 65 12 00 00       	call   801fe9 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d87:	5b                   	pop    %ebx
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	57                   	push   %edi
  800d90:	56                   	push   %esi
  800d91:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d92:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d97:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9f:	89 cb                	mov    %ecx,%ebx
  800da1:	89 cf                	mov    %ecx,%edi
  800da3:	89 ce                	mov    %ecx,%esi
  800da5:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800da7:	5b                   	pop    %ebx
  800da8:	5e                   	pop    %esi
  800da9:	5f                   	pop    %edi
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    

00800dac <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	57                   	push   %edi
  800db0:	56                   	push   %esi
  800db1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db7:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbf:	89 cb                	mov    %ecx,%ebx
  800dc1:	89 cf                	mov    %ecx,%edi
  800dc3:	89 ce                	mov    %ecx,%esi
  800dc5:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800dc7:	5b                   	pop    %ebx
  800dc8:	5e                   	pop    %esi
  800dc9:	5f                   	pop    %edi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	57                   	push   %edi
  800dd0:	56                   	push   %esi
  800dd1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd7:	b8 10 00 00 00       	mov    $0x10,%eax
  800ddc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddf:	89 cb                	mov    %ecx,%ebx
  800de1:	89 cf                	mov    %ecx,%edi
  800de3:	89 ce                	mov    %ecx,%esi
  800de5:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800de7:	5b                   	pop    %ebx
  800de8:	5e                   	pop    %esi
  800de9:	5f                   	pop    %edi
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    

00800dec <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	53                   	push   %ebx
  800df0:	83 ec 04             	sub    $0x4,%esp
  800df3:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800df6:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800df8:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dfc:	74 11                	je     800e0f <pgfault+0x23>
  800dfe:	89 d8                	mov    %ebx,%eax
  800e00:	c1 e8 0c             	shr    $0xc,%eax
  800e03:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e0a:	f6 c4 08             	test   $0x8,%ah
  800e0d:	75 14                	jne    800e23 <pgfault+0x37>
		panic("faulting access");
  800e0f:	83 ec 04             	sub    $0x4,%esp
  800e12:	68 0a 28 80 00       	push   $0x80280a
  800e17:	6a 1f                	push   $0x1f
  800e19:	68 1a 28 80 00       	push   $0x80281a
  800e1e:	e8 c6 11 00 00       	call   801fe9 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e23:	83 ec 04             	sub    $0x4,%esp
  800e26:	6a 07                	push   $0x7
  800e28:	68 00 f0 7f 00       	push   $0x7ff000
  800e2d:	6a 00                	push   $0x0
  800e2f:	e8 67 fd ff ff       	call   800b9b <sys_page_alloc>
	if (r < 0) {
  800e34:	83 c4 10             	add    $0x10,%esp
  800e37:	85 c0                	test   %eax,%eax
  800e39:	79 12                	jns    800e4d <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e3b:	50                   	push   %eax
  800e3c:	68 25 28 80 00       	push   $0x802825
  800e41:	6a 2d                	push   $0x2d
  800e43:	68 1a 28 80 00       	push   $0x80281a
  800e48:	e8 9c 11 00 00       	call   801fe9 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e4d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e53:	83 ec 04             	sub    $0x4,%esp
  800e56:	68 00 10 00 00       	push   $0x1000
  800e5b:	53                   	push   %ebx
  800e5c:	68 00 f0 7f 00       	push   $0x7ff000
  800e61:	e8 2c fb ff ff       	call   800992 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e66:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e6d:	53                   	push   %ebx
  800e6e:	6a 00                	push   $0x0
  800e70:	68 00 f0 7f 00       	push   $0x7ff000
  800e75:	6a 00                	push   $0x0
  800e77:	e8 62 fd ff ff       	call   800bde <sys_page_map>
	if (r < 0) {
  800e7c:	83 c4 20             	add    $0x20,%esp
  800e7f:	85 c0                	test   %eax,%eax
  800e81:	79 12                	jns    800e95 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e83:	50                   	push   %eax
  800e84:	68 25 28 80 00       	push   $0x802825
  800e89:	6a 34                	push   $0x34
  800e8b:	68 1a 28 80 00       	push   $0x80281a
  800e90:	e8 54 11 00 00       	call   801fe9 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e95:	83 ec 08             	sub    $0x8,%esp
  800e98:	68 00 f0 7f 00       	push   $0x7ff000
  800e9d:	6a 00                	push   $0x0
  800e9f:	e8 7c fd ff ff       	call   800c20 <sys_page_unmap>
	if (r < 0) {
  800ea4:	83 c4 10             	add    $0x10,%esp
  800ea7:	85 c0                	test   %eax,%eax
  800ea9:	79 12                	jns    800ebd <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800eab:	50                   	push   %eax
  800eac:	68 25 28 80 00       	push   $0x802825
  800eb1:	6a 38                	push   $0x38
  800eb3:	68 1a 28 80 00       	push   $0x80281a
  800eb8:	e8 2c 11 00 00       	call   801fe9 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800ebd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ec0:	c9                   	leave  
  800ec1:	c3                   	ret    

00800ec2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ec2:	55                   	push   %ebp
  800ec3:	89 e5                	mov    %esp,%ebp
  800ec5:	57                   	push   %edi
  800ec6:	56                   	push   %esi
  800ec7:	53                   	push   %ebx
  800ec8:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800ecb:	68 ec 0d 80 00       	push   $0x800dec
  800ed0:	e8 5a 11 00 00       	call   80202f <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ed5:	b8 07 00 00 00       	mov    $0x7,%eax
  800eda:	cd 30                	int    $0x30
  800edc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800edf:	83 c4 10             	add    $0x10,%esp
  800ee2:	85 c0                	test   %eax,%eax
  800ee4:	79 17                	jns    800efd <fork+0x3b>
		panic("fork fault %e");
  800ee6:	83 ec 04             	sub    $0x4,%esp
  800ee9:	68 3e 28 80 00       	push   $0x80283e
  800eee:	68 85 00 00 00       	push   $0x85
  800ef3:	68 1a 28 80 00       	push   $0x80281a
  800ef8:	e8 ec 10 00 00       	call   801fe9 <_panic>
  800efd:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800eff:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f03:	75 24                	jne    800f29 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f05:	e8 53 fc ff ff       	call   800b5d <sys_getenvid>
  800f0a:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f0f:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800f15:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f1a:	a3 0c 40 80 00       	mov    %eax,0x80400c
		return 0;
  800f1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f24:	e9 64 01 00 00       	jmp    80108d <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f29:	83 ec 04             	sub    $0x4,%esp
  800f2c:	6a 07                	push   $0x7
  800f2e:	68 00 f0 bf ee       	push   $0xeebff000
  800f33:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f36:	e8 60 fc ff ff       	call   800b9b <sys_page_alloc>
  800f3b:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f3e:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f43:	89 d8                	mov    %ebx,%eax
  800f45:	c1 e8 16             	shr    $0x16,%eax
  800f48:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f4f:	a8 01                	test   $0x1,%al
  800f51:	0f 84 fc 00 00 00    	je     801053 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f57:	89 d8                	mov    %ebx,%eax
  800f59:	c1 e8 0c             	shr    $0xc,%eax
  800f5c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f63:	f6 c2 01             	test   $0x1,%dl
  800f66:	0f 84 e7 00 00 00    	je     801053 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f6c:	89 c6                	mov    %eax,%esi
  800f6e:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f71:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f78:	f6 c6 04             	test   $0x4,%dh
  800f7b:	74 39                	je     800fb6 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f7d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f84:	83 ec 0c             	sub    $0xc,%esp
  800f87:	25 07 0e 00 00       	and    $0xe07,%eax
  800f8c:	50                   	push   %eax
  800f8d:	56                   	push   %esi
  800f8e:	57                   	push   %edi
  800f8f:	56                   	push   %esi
  800f90:	6a 00                	push   $0x0
  800f92:	e8 47 fc ff ff       	call   800bde <sys_page_map>
		if (r < 0) {
  800f97:	83 c4 20             	add    $0x20,%esp
  800f9a:	85 c0                	test   %eax,%eax
  800f9c:	0f 89 b1 00 00 00    	jns    801053 <fork+0x191>
		    	panic("sys page map fault %e");
  800fa2:	83 ec 04             	sub    $0x4,%esp
  800fa5:	68 4c 28 80 00       	push   $0x80284c
  800faa:	6a 55                	push   $0x55
  800fac:	68 1a 28 80 00       	push   $0x80281a
  800fb1:	e8 33 10 00 00       	call   801fe9 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800fb6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fbd:	f6 c2 02             	test   $0x2,%dl
  800fc0:	75 0c                	jne    800fce <fork+0x10c>
  800fc2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fc9:	f6 c4 08             	test   $0x8,%ah
  800fcc:	74 5b                	je     801029 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800fce:	83 ec 0c             	sub    $0xc,%esp
  800fd1:	68 05 08 00 00       	push   $0x805
  800fd6:	56                   	push   %esi
  800fd7:	57                   	push   %edi
  800fd8:	56                   	push   %esi
  800fd9:	6a 00                	push   $0x0
  800fdb:	e8 fe fb ff ff       	call   800bde <sys_page_map>
		if (r < 0) {
  800fe0:	83 c4 20             	add    $0x20,%esp
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	79 14                	jns    800ffb <fork+0x139>
		    	panic("sys page map fault %e");
  800fe7:	83 ec 04             	sub    $0x4,%esp
  800fea:	68 4c 28 80 00       	push   $0x80284c
  800fef:	6a 5c                	push   $0x5c
  800ff1:	68 1a 28 80 00       	push   $0x80281a
  800ff6:	e8 ee 0f 00 00       	call   801fe9 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800ffb:	83 ec 0c             	sub    $0xc,%esp
  800ffe:	68 05 08 00 00       	push   $0x805
  801003:	56                   	push   %esi
  801004:	6a 00                	push   $0x0
  801006:	56                   	push   %esi
  801007:	6a 00                	push   $0x0
  801009:	e8 d0 fb ff ff       	call   800bde <sys_page_map>
		if (r < 0) {
  80100e:	83 c4 20             	add    $0x20,%esp
  801011:	85 c0                	test   %eax,%eax
  801013:	79 3e                	jns    801053 <fork+0x191>
		    	panic("sys page map fault %e");
  801015:	83 ec 04             	sub    $0x4,%esp
  801018:	68 4c 28 80 00       	push   $0x80284c
  80101d:	6a 60                	push   $0x60
  80101f:	68 1a 28 80 00       	push   $0x80281a
  801024:	e8 c0 0f 00 00       	call   801fe9 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801029:	83 ec 0c             	sub    $0xc,%esp
  80102c:	6a 05                	push   $0x5
  80102e:	56                   	push   %esi
  80102f:	57                   	push   %edi
  801030:	56                   	push   %esi
  801031:	6a 00                	push   $0x0
  801033:	e8 a6 fb ff ff       	call   800bde <sys_page_map>
		if (r < 0) {
  801038:	83 c4 20             	add    $0x20,%esp
  80103b:	85 c0                	test   %eax,%eax
  80103d:	79 14                	jns    801053 <fork+0x191>
		    	panic("sys page map fault %e");
  80103f:	83 ec 04             	sub    $0x4,%esp
  801042:	68 4c 28 80 00       	push   $0x80284c
  801047:	6a 65                	push   $0x65
  801049:	68 1a 28 80 00       	push   $0x80281a
  80104e:	e8 96 0f 00 00       	call   801fe9 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801053:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801059:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80105f:	0f 85 de fe ff ff    	jne    800f43 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801065:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80106a:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  801070:	83 ec 08             	sub    $0x8,%esp
  801073:	50                   	push   %eax
  801074:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801077:	57                   	push   %edi
  801078:	e8 69 fc ff ff       	call   800ce6 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80107d:	83 c4 08             	add    $0x8,%esp
  801080:	6a 02                	push   $0x2
  801082:	57                   	push   %edi
  801083:	e8 da fb ff ff       	call   800c62 <sys_env_set_status>
	
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

envid_t
sfork(void)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801098:	b8 00 00 00 00       	mov    $0x0,%eax
  80109d:	5d                   	pop    %ebp
  80109e:	c3                   	ret    

0080109f <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  80109f:	55                   	push   %ebp
  8010a0:	89 e5                	mov    %esp,%ebp
  8010a2:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  8010a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a8:	a3 10 40 80 00       	mov    %eax,0x804010
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8010ad:	68 46 01 80 00       	push   $0x800146
  8010b2:	e8 d5 fc ff ff       	call   800d8c <sys_thread_create>

	return id;
}
  8010b7:	c9                   	leave  
  8010b8:	c3                   	ret    

008010b9 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8010b9:	55                   	push   %ebp
  8010ba:	89 e5                	mov    %esp,%ebp
  8010bc:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  8010bf:	ff 75 08             	pushl  0x8(%ebp)
  8010c2:	e8 e5 fc ff ff       	call   800dac <sys_thread_free>
}
  8010c7:	83 c4 10             	add    $0x10,%esp
  8010ca:	c9                   	leave  
  8010cb:	c3                   	ret    

008010cc <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8010cc:	55                   	push   %ebp
  8010cd:	89 e5                	mov    %esp,%ebp
  8010cf:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  8010d2:	ff 75 08             	pushl  0x8(%ebp)
  8010d5:	e8 f2 fc ff ff       	call   800dcc <sys_thread_join>
}
  8010da:	83 c4 10             	add    $0x10,%esp
  8010dd:	c9                   	leave  
  8010de:	c3                   	ret    

008010df <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  8010df:	55                   	push   %ebp
  8010e0:	89 e5                	mov    %esp,%ebp
  8010e2:	56                   	push   %esi
  8010e3:	53                   	push   %ebx
  8010e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8010e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8010ea:	83 ec 04             	sub    $0x4,%esp
  8010ed:	6a 07                	push   $0x7
  8010ef:	6a 00                	push   $0x0
  8010f1:	56                   	push   %esi
  8010f2:	e8 a4 fa ff ff       	call   800b9b <sys_page_alloc>
	if (r < 0) {
  8010f7:	83 c4 10             	add    $0x10,%esp
  8010fa:	85 c0                	test   %eax,%eax
  8010fc:	79 15                	jns    801113 <queue_append+0x34>
		panic("%e\n", r);
  8010fe:	50                   	push   %eax
  8010ff:	68 92 28 80 00       	push   $0x802892
  801104:	68 d5 00 00 00       	push   $0xd5
  801109:	68 1a 28 80 00       	push   $0x80281a
  80110e:	e8 d6 0e 00 00       	call   801fe9 <_panic>
	}	

	wt->envid = envid;
  801113:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  801119:	83 3b 00             	cmpl   $0x0,(%ebx)
  80111c:	75 13                	jne    801131 <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  80111e:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  801125:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80112c:	00 00 00 
  80112f:	eb 1b                	jmp    80114c <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  801131:	8b 43 04             	mov    0x4(%ebx),%eax
  801134:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  80113b:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801142:	00 00 00 
		queue->last = wt;
  801145:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80114c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80114f:	5b                   	pop    %ebx
  801150:	5e                   	pop    %esi
  801151:	5d                   	pop    %ebp
  801152:	c3                   	ret    

00801153 <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	83 ec 08             	sub    $0x8,%esp
  801159:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  80115c:	8b 02                	mov    (%edx),%eax
  80115e:	85 c0                	test   %eax,%eax
  801160:	75 17                	jne    801179 <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  801162:	83 ec 04             	sub    $0x4,%esp
  801165:	68 62 28 80 00       	push   $0x802862
  80116a:	68 ec 00 00 00       	push   $0xec
  80116f:	68 1a 28 80 00       	push   $0x80281a
  801174:	e8 70 0e 00 00       	call   801fe9 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  801179:	8b 48 04             	mov    0x4(%eax),%ecx
  80117c:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  80117e:	8b 00                	mov    (%eax),%eax
}
  801180:	c9                   	leave  
  801181:	c3                   	ret    

00801182 <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  801182:	55                   	push   %ebp
  801183:	89 e5                	mov    %esp,%ebp
  801185:	56                   	push   %esi
  801186:	53                   	push   %ebx
  801187:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  80118a:	b8 01 00 00 00       	mov    $0x1,%eax
  80118f:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801192:	85 c0                	test   %eax,%eax
  801194:	74 4a                	je     8011e0 <mutex_lock+0x5e>
  801196:	8b 73 04             	mov    0x4(%ebx),%esi
  801199:	83 3e 00             	cmpl   $0x0,(%esi)
  80119c:	75 42                	jne    8011e0 <mutex_lock+0x5e>
		queue_append(sys_getenvid(), mtx->queue);		
  80119e:	e8 ba f9 ff ff       	call   800b5d <sys_getenvid>
  8011a3:	83 ec 08             	sub    $0x8,%esp
  8011a6:	56                   	push   %esi
  8011a7:	50                   	push   %eax
  8011a8:	e8 32 ff ff ff       	call   8010df <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  8011ad:	e8 ab f9 ff ff       	call   800b5d <sys_getenvid>
  8011b2:	83 c4 08             	add    $0x8,%esp
  8011b5:	6a 04                	push   $0x4
  8011b7:	50                   	push   %eax
  8011b8:	e8 a5 fa ff ff       	call   800c62 <sys_env_set_status>

		if (r < 0) {
  8011bd:	83 c4 10             	add    $0x10,%esp
  8011c0:	85 c0                	test   %eax,%eax
  8011c2:	79 15                	jns    8011d9 <mutex_lock+0x57>
			panic("%e\n", r);
  8011c4:	50                   	push   %eax
  8011c5:	68 92 28 80 00       	push   $0x802892
  8011ca:	68 02 01 00 00       	push   $0x102
  8011cf:	68 1a 28 80 00       	push   $0x80281a
  8011d4:	e8 10 0e 00 00       	call   801fe9 <_panic>
		}
		sys_yield();
  8011d9:	e8 9e f9 ff ff       	call   800b7c <sys_yield>
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8011de:	eb 08                	jmp    8011e8 <mutex_lock+0x66>
		if (r < 0) {
			panic("%e\n", r);
		}
		sys_yield();
	} else {
		mtx->owner = sys_getenvid();
  8011e0:	e8 78 f9 ff ff       	call   800b5d <sys_getenvid>
  8011e5:	89 43 08             	mov    %eax,0x8(%ebx)
	}
}
  8011e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011eb:	5b                   	pop    %ebx
  8011ec:	5e                   	pop    %esi
  8011ed:	5d                   	pop    %ebp
  8011ee:	c3                   	ret    

008011ef <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
  8011f2:	53                   	push   %ebx
  8011f3:	83 ec 04             	sub    $0x4,%esp
  8011f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8011f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011fe:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  801201:	8b 43 04             	mov    0x4(%ebx),%eax
  801204:	83 38 00             	cmpl   $0x0,(%eax)
  801207:	74 33                	je     80123c <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  801209:	83 ec 0c             	sub    $0xc,%esp
  80120c:	50                   	push   %eax
  80120d:	e8 41 ff ff ff       	call   801153 <queue_pop>
  801212:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  801215:	83 c4 08             	add    $0x8,%esp
  801218:	6a 02                	push   $0x2
  80121a:	50                   	push   %eax
  80121b:	e8 42 fa ff ff       	call   800c62 <sys_env_set_status>
		if (r < 0) {
  801220:	83 c4 10             	add    $0x10,%esp
  801223:	85 c0                	test   %eax,%eax
  801225:	79 15                	jns    80123c <mutex_unlock+0x4d>
			panic("%e\n", r);
  801227:	50                   	push   %eax
  801228:	68 92 28 80 00       	push   $0x802892
  80122d:	68 16 01 00 00       	push   $0x116
  801232:	68 1a 28 80 00       	push   $0x80281a
  801237:	e8 ad 0d 00 00       	call   801fe9 <_panic>
		}
	}

	//asm volatile("pause"); 	// might be useless here
}
  80123c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80123f:	c9                   	leave  
  801240:	c3                   	ret    

00801241 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
  801244:	53                   	push   %ebx
  801245:	83 ec 04             	sub    $0x4,%esp
  801248:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  80124b:	e8 0d f9 ff ff       	call   800b5d <sys_getenvid>
  801250:	83 ec 04             	sub    $0x4,%esp
  801253:	6a 07                	push   $0x7
  801255:	53                   	push   %ebx
  801256:	50                   	push   %eax
  801257:	e8 3f f9 ff ff       	call   800b9b <sys_page_alloc>
  80125c:	83 c4 10             	add    $0x10,%esp
  80125f:	85 c0                	test   %eax,%eax
  801261:	79 15                	jns    801278 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  801263:	50                   	push   %eax
  801264:	68 7d 28 80 00       	push   $0x80287d
  801269:	68 22 01 00 00       	push   $0x122
  80126e:	68 1a 28 80 00       	push   $0x80281a
  801273:	e8 71 0d 00 00       	call   801fe9 <_panic>
	}	
	mtx->locked = 0;
  801278:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  80127e:	8b 43 04             	mov    0x4(%ebx),%eax
  801281:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  801287:	8b 43 04             	mov    0x4(%ebx),%eax
  80128a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  801291:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  801298:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80129b:	c9                   	leave  
  80129c:	c3                   	ret    

0080129d <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
  8012a0:	53                   	push   %ebx
  8012a1:	83 ec 04             	sub    $0x4,%esp
  8012a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue->first != NULL) {
  8012a7:	eb 21                	jmp    8012ca <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
  8012a9:	83 ec 0c             	sub    $0xc,%esp
  8012ac:	50                   	push   %eax
  8012ad:	e8 a1 fe ff ff       	call   801153 <queue_pop>
  8012b2:	83 c4 08             	add    $0x8,%esp
  8012b5:	6a 02                	push   $0x2
  8012b7:	50                   	push   %eax
  8012b8:	e8 a5 f9 ff ff       	call   800c62 <sys_env_set_status>
		mtx->queue->first = mtx->queue->first->next;
  8012bd:	8b 43 04             	mov    0x4(%ebx),%eax
  8012c0:	8b 10                	mov    (%eax),%edx
  8012c2:	8b 52 04             	mov    0x4(%edx),%edx
  8012c5:	89 10                	mov    %edx,(%eax)
  8012c7:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue->first != NULL) {
  8012ca:	8b 43 04             	mov    0x4(%ebx),%eax
  8012cd:	83 38 00             	cmpl   $0x0,(%eax)
  8012d0:	75 d7                	jne    8012a9 <mutex_destroy+0xc>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
		mtx->queue->first = mtx->queue->first->next;
	}

	memset(mtx, 0, PGSIZE);
  8012d2:	83 ec 04             	sub    $0x4,%esp
  8012d5:	68 00 10 00 00       	push   $0x1000
  8012da:	6a 00                	push   $0x0
  8012dc:	53                   	push   %ebx
  8012dd:	e8 fb f5 ff ff       	call   8008dd <memset>
	mtx = NULL;
}
  8012e2:	83 c4 10             	add    $0x10,%esp
  8012e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e8:	c9                   	leave  
  8012e9:	c3                   	ret    

008012ea <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012ea:	55                   	push   %ebp
  8012eb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f0:	05 00 00 00 30       	add    $0x30000000,%eax
  8012f5:	c1 e8 0c             	shr    $0xc,%eax
}
  8012f8:	5d                   	pop    %ebp
  8012f9:	c3                   	ret    

008012fa <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012fa:	55                   	push   %ebp
  8012fb:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801300:	05 00 00 00 30       	add    $0x30000000,%eax
  801305:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80130a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80130f:	5d                   	pop    %ebp
  801310:	c3                   	ret    

00801311 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801311:	55                   	push   %ebp
  801312:	89 e5                	mov    %esp,%ebp
  801314:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801317:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80131c:	89 c2                	mov    %eax,%edx
  80131e:	c1 ea 16             	shr    $0x16,%edx
  801321:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801328:	f6 c2 01             	test   $0x1,%dl
  80132b:	74 11                	je     80133e <fd_alloc+0x2d>
  80132d:	89 c2                	mov    %eax,%edx
  80132f:	c1 ea 0c             	shr    $0xc,%edx
  801332:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801339:	f6 c2 01             	test   $0x1,%dl
  80133c:	75 09                	jne    801347 <fd_alloc+0x36>
			*fd_store = fd;
  80133e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801340:	b8 00 00 00 00       	mov    $0x0,%eax
  801345:	eb 17                	jmp    80135e <fd_alloc+0x4d>
  801347:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80134c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801351:	75 c9                	jne    80131c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801353:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801359:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80135e:	5d                   	pop    %ebp
  80135f:	c3                   	ret    

00801360 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801360:	55                   	push   %ebp
  801361:	89 e5                	mov    %esp,%ebp
  801363:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801366:	83 f8 1f             	cmp    $0x1f,%eax
  801369:	77 36                	ja     8013a1 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80136b:	c1 e0 0c             	shl    $0xc,%eax
  80136e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801373:	89 c2                	mov    %eax,%edx
  801375:	c1 ea 16             	shr    $0x16,%edx
  801378:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80137f:	f6 c2 01             	test   $0x1,%dl
  801382:	74 24                	je     8013a8 <fd_lookup+0x48>
  801384:	89 c2                	mov    %eax,%edx
  801386:	c1 ea 0c             	shr    $0xc,%edx
  801389:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801390:	f6 c2 01             	test   $0x1,%dl
  801393:	74 1a                	je     8013af <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801395:	8b 55 0c             	mov    0xc(%ebp),%edx
  801398:	89 02                	mov    %eax,(%edx)
	return 0;
  80139a:	b8 00 00 00 00       	mov    $0x0,%eax
  80139f:	eb 13                	jmp    8013b4 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013a6:	eb 0c                	jmp    8013b4 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013ad:	eb 05                	jmp    8013b4 <fd_lookup+0x54>
  8013af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013b4:	5d                   	pop    %ebp
  8013b5:	c3                   	ret    

008013b6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013b6:	55                   	push   %ebp
  8013b7:	89 e5                	mov    %esp,%ebp
  8013b9:	83 ec 08             	sub    $0x8,%esp
  8013bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013bf:	ba 14 29 80 00       	mov    $0x802914,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013c4:	eb 13                	jmp    8013d9 <dev_lookup+0x23>
  8013c6:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013c9:	39 08                	cmp    %ecx,(%eax)
  8013cb:	75 0c                	jne    8013d9 <dev_lookup+0x23>
			*dev = devtab[i];
  8013cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013d0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d7:	eb 31                	jmp    80140a <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013d9:	8b 02                	mov    (%edx),%eax
  8013db:	85 c0                	test   %eax,%eax
  8013dd:	75 e7                	jne    8013c6 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013df:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8013e4:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8013ea:	83 ec 04             	sub    $0x4,%esp
  8013ed:	51                   	push   %ecx
  8013ee:	50                   	push   %eax
  8013ef:	68 98 28 80 00       	push   $0x802898
  8013f4:	e8 1a ee ff ff       	call   800213 <cprintf>
	*dev = 0;
  8013f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013fc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801402:	83 c4 10             	add    $0x10,%esp
  801405:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80140a:	c9                   	leave  
  80140b:	c3                   	ret    

0080140c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
  80140f:	56                   	push   %esi
  801410:	53                   	push   %ebx
  801411:	83 ec 10             	sub    $0x10,%esp
  801414:	8b 75 08             	mov    0x8(%ebp),%esi
  801417:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80141a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80141d:	50                   	push   %eax
  80141e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801424:	c1 e8 0c             	shr    $0xc,%eax
  801427:	50                   	push   %eax
  801428:	e8 33 ff ff ff       	call   801360 <fd_lookup>
  80142d:	83 c4 08             	add    $0x8,%esp
  801430:	85 c0                	test   %eax,%eax
  801432:	78 05                	js     801439 <fd_close+0x2d>
	    || fd != fd2)
  801434:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801437:	74 0c                	je     801445 <fd_close+0x39>
		return (must_exist ? r : 0);
  801439:	84 db                	test   %bl,%bl
  80143b:	ba 00 00 00 00       	mov    $0x0,%edx
  801440:	0f 44 c2             	cmove  %edx,%eax
  801443:	eb 41                	jmp    801486 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801445:	83 ec 08             	sub    $0x8,%esp
  801448:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80144b:	50                   	push   %eax
  80144c:	ff 36                	pushl  (%esi)
  80144e:	e8 63 ff ff ff       	call   8013b6 <dev_lookup>
  801453:	89 c3                	mov    %eax,%ebx
  801455:	83 c4 10             	add    $0x10,%esp
  801458:	85 c0                	test   %eax,%eax
  80145a:	78 1a                	js     801476 <fd_close+0x6a>
		if (dev->dev_close)
  80145c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80145f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801462:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801467:	85 c0                	test   %eax,%eax
  801469:	74 0b                	je     801476 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80146b:	83 ec 0c             	sub    $0xc,%esp
  80146e:	56                   	push   %esi
  80146f:	ff d0                	call   *%eax
  801471:	89 c3                	mov    %eax,%ebx
  801473:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801476:	83 ec 08             	sub    $0x8,%esp
  801479:	56                   	push   %esi
  80147a:	6a 00                	push   $0x0
  80147c:	e8 9f f7 ff ff       	call   800c20 <sys_page_unmap>
	return r;
  801481:	83 c4 10             	add    $0x10,%esp
  801484:	89 d8                	mov    %ebx,%eax
}
  801486:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801489:	5b                   	pop    %ebx
  80148a:	5e                   	pop    %esi
  80148b:	5d                   	pop    %ebp
  80148c:	c3                   	ret    

0080148d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80148d:	55                   	push   %ebp
  80148e:	89 e5                	mov    %esp,%ebp
  801490:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801493:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801496:	50                   	push   %eax
  801497:	ff 75 08             	pushl  0x8(%ebp)
  80149a:	e8 c1 fe ff ff       	call   801360 <fd_lookup>
  80149f:	83 c4 08             	add    $0x8,%esp
  8014a2:	85 c0                	test   %eax,%eax
  8014a4:	78 10                	js     8014b6 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014a6:	83 ec 08             	sub    $0x8,%esp
  8014a9:	6a 01                	push   $0x1
  8014ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8014ae:	e8 59 ff ff ff       	call   80140c <fd_close>
  8014b3:	83 c4 10             	add    $0x10,%esp
}
  8014b6:	c9                   	leave  
  8014b7:	c3                   	ret    

008014b8 <close_all>:

void
close_all(void)
{
  8014b8:	55                   	push   %ebp
  8014b9:	89 e5                	mov    %esp,%ebp
  8014bb:	53                   	push   %ebx
  8014bc:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014bf:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014c4:	83 ec 0c             	sub    $0xc,%esp
  8014c7:	53                   	push   %ebx
  8014c8:	e8 c0 ff ff ff       	call   80148d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014cd:	83 c3 01             	add    $0x1,%ebx
  8014d0:	83 c4 10             	add    $0x10,%esp
  8014d3:	83 fb 20             	cmp    $0x20,%ebx
  8014d6:	75 ec                	jne    8014c4 <close_all+0xc>
		close(i);
}
  8014d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014db:	c9                   	leave  
  8014dc:	c3                   	ret    

008014dd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014dd:	55                   	push   %ebp
  8014de:	89 e5                	mov    %esp,%ebp
  8014e0:	57                   	push   %edi
  8014e1:	56                   	push   %esi
  8014e2:	53                   	push   %ebx
  8014e3:	83 ec 2c             	sub    $0x2c,%esp
  8014e6:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014e9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014ec:	50                   	push   %eax
  8014ed:	ff 75 08             	pushl  0x8(%ebp)
  8014f0:	e8 6b fe ff ff       	call   801360 <fd_lookup>
  8014f5:	83 c4 08             	add    $0x8,%esp
  8014f8:	85 c0                	test   %eax,%eax
  8014fa:	0f 88 c1 00 00 00    	js     8015c1 <dup+0xe4>
		return r;
	close(newfdnum);
  801500:	83 ec 0c             	sub    $0xc,%esp
  801503:	56                   	push   %esi
  801504:	e8 84 ff ff ff       	call   80148d <close>

	newfd = INDEX2FD(newfdnum);
  801509:	89 f3                	mov    %esi,%ebx
  80150b:	c1 e3 0c             	shl    $0xc,%ebx
  80150e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801514:	83 c4 04             	add    $0x4,%esp
  801517:	ff 75 e4             	pushl  -0x1c(%ebp)
  80151a:	e8 db fd ff ff       	call   8012fa <fd2data>
  80151f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801521:	89 1c 24             	mov    %ebx,(%esp)
  801524:	e8 d1 fd ff ff       	call   8012fa <fd2data>
  801529:	83 c4 10             	add    $0x10,%esp
  80152c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80152f:	89 f8                	mov    %edi,%eax
  801531:	c1 e8 16             	shr    $0x16,%eax
  801534:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80153b:	a8 01                	test   $0x1,%al
  80153d:	74 37                	je     801576 <dup+0x99>
  80153f:	89 f8                	mov    %edi,%eax
  801541:	c1 e8 0c             	shr    $0xc,%eax
  801544:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80154b:	f6 c2 01             	test   $0x1,%dl
  80154e:	74 26                	je     801576 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801550:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801557:	83 ec 0c             	sub    $0xc,%esp
  80155a:	25 07 0e 00 00       	and    $0xe07,%eax
  80155f:	50                   	push   %eax
  801560:	ff 75 d4             	pushl  -0x2c(%ebp)
  801563:	6a 00                	push   $0x0
  801565:	57                   	push   %edi
  801566:	6a 00                	push   $0x0
  801568:	e8 71 f6 ff ff       	call   800bde <sys_page_map>
  80156d:	89 c7                	mov    %eax,%edi
  80156f:	83 c4 20             	add    $0x20,%esp
  801572:	85 c0                	test   %eax,%eax
  801574:	78 2e                	js     8015a4 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801576:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801579:	89 d0                	mov    %edx,%eax
  80157b:	c1 e8 0c             	shr    $0xc,%eax
  80157e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801585:	83 ec 0c             	sub    $0xc,%esp
  801588:	25 07 0e 00 00       	and    $0xe07,%eax
  80158d:	50                   	push   %eax
  80158e:	53                   	push   %ebx
  80158f:	6a 00                	push   $0x0
  801591:	52                   	push   %edx
  801592:	6a 00                	push   $0x0
  801594:	e8 45 f6 ff ff       	call   800bde <sys_page_map>
  801599:	89 c7                	mov    %eax,%edi
  80159b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80159e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015a0:	85 ff                	test   %edi,%edi
  8015a2:	79 1d                	jns    8015c1 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015a4:	83 ec 08             	sub    $0x8,%esp
  8015a7:	53                   	push   %ebx
  8015a8:	6a 00                	push   $0x0
  8015aa:	e8 71 f6 ff ff       	call   800c20 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015af:	83 c4 08             	add    $0x8,%esp
  8015b2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015b5:	6a 00                	push   $0x0
  8015b7:	e8 64 f6 ff ff       	call   800c20 <sys_page_unmap>
	return r;
  8015bc:	83 c4 10             	add    $0x10,%esp
  8015bf:	89 f8                	mov    %edi,%eax
}
  8015c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015c4:	5b                   	pop    %ebx
  8015c5:	5e                   	pop    %esi
  8015c6:	5f                   	pop    %edi
  8015c7:	5d                   	pop    %ebp
  8015c8:	c3                   	ret    

008015c9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015c9:	55                   	push   %ebp
  8015ca:	89 e5                	mov    %esp,%ebp
  8015cc:	53                   	push   %ebx
  8015cd:	83 ec 14             	sub    $0x14,%esp
  8015d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d6:	50                   	push   %eax
  8015d7:	53                   	push   %ebx
  8015d8:	e8 83 fd ff ff       	call   801360 <fd_lookup>
  8015dd:	83 c4 08             	add    $0x8,%esp
  8015e0:	89 c2                	mov    %eax,%edx
  8015e2:	85 c0                	test   %eax,%eax
  8015e4:	78 70                	js     801656 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e6:	83 ec 08             	sub    $0x8,%esp
  8015e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ec:	50                   	push   %eax
  8015ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f0:	ff 30                	pushl  (%eax)
  8015f2:	e8 bf fd ff ff       	call   8013b6 <dev_lookup>
  8015f7:	83 c4 10             	add    $0x10,%esp
  8015fa:	85 c0                	test   %eax,%eax
  8015fc:	78 4f                	js     80164d <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015fe:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801601:	8b 42 08             	mov    0x8(%edx),%eax
  801604:	83 e0 03             	and    $0x3,%eax
  801607:	83 f8 01             	cmp    $0x1,%eax
  80160a:	75 24                	jne    801630 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80160c:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801611:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801617:	83 ec 04             	sub    $0x4,%esp
  80161a:	53                   	push   %ebx
  80161b:	50                   	push   %eax
  80161c:	68 d9 28 80 00       	push   $0x8028d9
  801621:	e8 ed eb ff ff       	call   800213 <cprintf>
		return -E_INVAL;
  801626:	83 c4 10             	add    $0x10,%esp
  801629:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80162e:	eb 26                	jmp    801656 <read+0x8d>
	}
	if (!dev->dev_read)
  801630:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801633:	8b 40 08             	mov    0x8(%eax),%eax
  801636:	85 c0                	test   %eax,%eax
  801638:	74 17                	je     801651 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80163a:	83 ec 04             	sub    $0x4,%esp
  80163d:	ff 75 10             	pushl  0x10(%ebp)
  801640:	ff 75 0c             	pushl  0xc(%ebp)
  801643:	52                   	push   %edx
  801644:	ff d0                	call   *%eax
  801646:	89 c2                	mov    %eax,%edx
  801648:	83 c4 10             	add    $0x10,%esp
  80164b:	eb 09                	jmp    801656 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164d:	89 c2                	mov    %eax,%edx
  80164f:	eb 05                	jmp    801656 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801651:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801656:	89 d0                	mov    %edx,%eax
  801658:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165b:	c9                   	leave  
  80165c:	c3                   	ret    

0080165d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80165d:	55                   	push   %ebp
  80165e:	89 e5                	mov    %esp,%ebp
  801660:	57                   	push   %edi
  801661:	56                   	push   %esi
  801662:	53                   	push   %ebx
  801663:	83 ec 0c             	sub    $0xc,%esp
  801666:	8b 7d 08             	mov    0x8(%ebp),%edi
  801669:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80166c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801671:	eb 21                	jmp    801694 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801673:	83 ec 04             	sub    $0x4,%esp
  801676:	89 f0                	mov    %esi,%eax
  801678:	29 d8                	sub    %ebx,%eax
  80167a:	50                   	push   %eax
  80167b:	89 d8                	mov    %ebx,%eax
  80167d:	03 45 0c             	add    0xc(%ebp),%eax
  801680:	50                   	push   %eax
  801681:	57                   	push   %edi
  801682:	e8 42 ff ff ff       	call   8015c9 <read>
		if (m < 0)
  801687:	83 c4 10             	add    $0x10,%esp
  80168a:	85 c0                	test   %eax,%eax
  80168c:	78 10                	js     80169e <readn+0x41>
			return m;
		if (m == 0)
  80168e:	85 c0                	test   %eax,%eax
  801690:	74 0a                	je     80169c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801692:	01 c3                	add    %eax,%ebx
  801694:	39 f3                	cmp    %esi,%ebx
  801696:	72 db                	jb     801673 <readn+0x16>
  801698:	89 d8                	mov    %ebx,%eax
  80169a:	eb 02                	jmp    80169e <readn+0x41>
  80169c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80169e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016a1:	5b                   	pop    %ebx
  8016a2:	5e                   	pop    %esi
  8016a3:	5f                   	pop    %edi
  8016a4:	5d                   	pop    %ebp
  8016a5:	c3                   	ret    

008016a6 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016a6:	55                   	push   %ebp
  8016a7:	89 e5                	mov    %esp,%ebp
  8016a9:	53                   	push   %ebx
  8016aa:	83 ec 14             	sub    $0x14,%esp
  8016ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b3:	50                   	push   %eax
  8016b4:	53                   	push   %ebx
  8016b5:	e8 a6 fc ff ff       	call   801360 <fd_lookup>
  8016ba:	83 c4 08             	add    $0x8,%esp
  8016bd:	89 c2                	mov    %eax,%edx
  8016bf:	85 c0                	test   %eax,%eax
  8016c1:	78 6b                	js     80172e <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c3:	83 ec 08             	sub    $0x8,%esp
  8016c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c9:	50                   	push   %eax
  8016ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016cd:	ff 30                	pushl  (%eax)
  8016cf:	e8 e2 fc ff ff       	call   8013b6 <dev_lookup>
  8016d4:	83 c4 10             	add    $0x10,%esp
  8016d7:	85 c0                	test   %eax,%eax
  8016d9:	78 4a                	js     801725 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016de:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016e2:	75 24                	jne    801708 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016e4:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8016e9:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8016ef:	83 ec 04             	sub    $0x4,%esp
  8016f2:	53                   	push   %ebx
  8016f3:	50                   	push   %eax
  8016f4:	68 f5 28 80 00       	push   $0x8028f5
  8016f9:	e8 15 eb ff ff       	call   800213 <cprintf>
		return -E_INVAL;
  8016fe:	83 c4 10             	add    $0x10,%esp
  801701:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801706:	eb 26                	jmp    80172e <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801708:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80170b:	8b 52 0c             	mov    0xc(%edx),%edx
  80170e:	85 d2                	test   %edx,%edx
  801710:	74 17                	je     801729 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801712:	83 ec 04             	sub    $0x4,%esp
  801715:	ff 75 10             	pushl  0x10(%ebp)
  801718:	ff 75 0c             	pushl  0xc(%ebp)
  80171b:	50                   	push   %eax
  80171c:	ff d2                	call   *%edx
  80171e:	89 c2                	mov    %eax,%edx
  801720:	83 c4 10             	add    $0x10,%esp
  801723:	eb 09                	jmp    80172e <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801725:	89 c2                	mov    %eax,%edx
  801727:	eb 05                	jmp    80172e <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801729:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80172e:	89 d0                	mov    %edx,%eax
  801730:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801733:	c9                   	leave  
  801734:	c3                   	ret    

00801735 <seek>:

int
seek(int fdnum, off_t offset)
{
  801735:	55                   	push   %ebp
  801736:	89 e5                	mov    %esp,%ebp
  801738:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80173b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80173e:	50                   	push   %eax
  80173f:	ff 75 08             	pushl  0x8(%ebp)
  801742:	e8 19 fc ff ff       	call   801360 <fd_lookup>
  801747:	83 c4 08             	add    $0x8,%esp
  80174a:	85 c0                	test   %eax,%eax
  80174c:	78 0e                	js     80175c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80174e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801751:	8b 55 0c             	mov    0xc(%ebp),%edx
  801754:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801757:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80175c:	c9                   	leave  
  80175d:	c3                   	ret    

0080175e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80175e:	55                   	push   %ebp
  80175f:	89 e5                	mov    %esp,%ebp
  801761:	53                   	push   %ebx
  801762:	83 ec 14             	sub    $0x14,%esp
  801765:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801768:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80176b:	50                   	push   %eax
  80176c:	53                   	push   %ebx
  80176d:	e8 ee fb ff ff       	call   801360 <fd_lookup>
  801772:	83 c4 08             	add    $0x8,%esp
  801775:	89 c2                	mov    %eax,%edx
  801777:	85 c0                	test   %eax,%eax
  801779:	78 68                	js     8017e3 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177b:	83 ec 08             	sub    $0x8,%esp
  80177e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801781:	50                   	push   %eax
  801782:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801785:	ff 30                	pushl  (%eax)
  801787:	e8 2a fc ff ff       	call   8013b6 <dev_lookup>
  80178c:	83 c4 10             	add    $0x10,%esp
  80178f:	85 c0                	test   %eax,%eax
  801791:	78 47                	js     8017da <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801793:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801796:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80179a:	75 24                	jne    8017c0 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80179c:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017a1:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8017a7:	83 ec 04             	sub    $0x4,%esp
  8017aa:	53                   	push   %ebx
  8017ab:	50                   	push   %eax
  8017ac:	68 b8 28 80 00       	push   $0x8028b8
  8017b1:	e8 5d ea ff ff       	call   800213 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017b6:	83 c4 10             	add    $0x10,%esp
  8017b9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017be:	eb 23                	jmp    8017e3 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  8017c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017c3:	8b 52 18             	mov    0x18(%edx),%edx
  8017c6:	85 d2                	test   %edx,%edx
  8017c8:	74 14                	je     8017de <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017ca:	83 ec 08             	sub    $0x8,%esp
  8017cd:	ff 75 0c             	pushl  0xc(%ebp)
  8017d0:	50                   	push   %eax
  8017d1:	ff d2                	call   *%edx
  8017d3:	89 c2                	mov    %eax,%edx
  8017d5:	83 c4 10             	add    $0x10,%esp
  8017d8:	eb 09                	jmp    8017e3 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017da:	89 c2                	mov    %eax,%edx
  8017dc:	eb 05                	jmp    8017e3 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017de:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017e3:	89 d0                	mov    %edx,%eax
  8017e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e8:	c9                   	leave  
  8017e9:	c3                   	ret    

008017ea <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017ea:	55                   	push   %ebp
  8017eb:	89 e5                	mov    %esp,%ebp
  8017ed:	53                   	push   %ebx
  8017ee:	83 ec 14             	sub    $0x14,%esp
  8017f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017f7:	50                   	push   %eax
  8017f8:	ff 75 08             	pushl  0x8(%ebp)
  8017fb:	e8 60 fb ff ff       	call   801360 <fd_lookup>
  801800:	83 c4 08             	add    $0x8,%esp
  801803:	89 c2                	mov    %eax,%edx
  801805:	85 c0                	test   %eax,%eax
  801807:	78 58                	js     801861 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801809:	83 ec 08             	sub    $0x8,%esp
  80180c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80180f:	50                   	push   %eax
  801810:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801813:	ff 30                	pushl  (%eax)
  801815:	e8 9c fb ff ff       	call   8013b6 <dev_lookup>
  80181a:	83 c4 10             	add    $0x10,%esp
  80181d:	85 c0                	test   %eax,%eax
  80181f:	78 37                	js     801858 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801821:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801824:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801828:	74 32                	je     80185c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80182a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80182d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801834:	00 00 00 
	stat->st_isdir = 0;
  801837:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80183e:	00 00 00 
	stat->st_dev = dev;
  801841:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801847:	83 ec 08             	sub    $0x8,%esp
  80184a:	53                   	push   %ebx
  80184b:	ff 75 f0             	pushl  -0x10(%ebp)
  80184e:	ff 50 14             	call   *0x14(%eax)
  801851:	89 c2                	mov    %eax,%edx
  801853:	83 c4 10             	add    $0x10,%esp
  801856:	eb 09                	jmp    801861 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801858:	89 c2                	mov    %eax,%edx
  80185a:	eb 05                	jmp    801861 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80185c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801861:	89 d0                	mov    %edx,%eax
  801863:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801866:	c9                   	leave  
  801867:	c3                   	ret    

00801868 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	56                   	push   %esi
  80186c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80186d:	83 ec 08             	sub    $0x8,%esp
  801870:	6a 00                	push   $0x0
  801872:	ff 75 08             	pushl  0x8(%ebp)
  801875:	e8 e3 01 00 00       	call   801a5d <open>
  80187a:	89 c3                	mov    %eax,%ebx
  80187c:	83 c4 10             	add    $0x10,%esp
  80187f:	85 c0                	test   %eax,%eax
  801881:	78 1b                	js     80189e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801883:	83 ec 08             	sub    $0x8,%esp
  801886:	ff 75 0c             	pushl  0xc(%ebp)
  801889:	50                   	push   %eax
  80188a:	e8 5b ff ff ff       	call   8017ea <fstat>
  80188f:	89 c6                	mov    %eax,%esi
	close(fd);
  801891:	89 1c 24             	mov    %ebx,(%esp)
  801894:	e8 f4 fb ff ff       	call   80148d <close>
	return r;
  801899:	83 c4 10             	add    $0x10,%esp
  80189c:	89 f0                	mov    %esi,%eax
}
  80189e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a1:	5b                   	pop    %ebx
  8018a2:	5e                   	pop    %esi
  8018a3:	5d                   	pop    %ebp
  8018a4:	c3                   	ret    

008018a5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018a5:	55                   	push   %ebp
  8018a6:	89 e5                	mov    %esp,%ebp
  8018a8:	56                   	push   %esi
  8018a9:	53                   	push   %ebx
  8018aa:	89 c6                	mov    %eax,%esi
  8018ac:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018ae:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018b5:	75 12                	jne    8018c9 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018b7:	83 ec 0c             	sub    $0xc,%esp
  8018ba:	6a 01                	push   $0x1
  8018bc:	e8 da 08 00 00       	call   80219b <ipc_find_env>
  8018c1:	a3 00 40 80 00       	mov    %eax,0x804000
  8018c6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018c9:	6a 07                	push   $0x7
  8018cb:	68 00 50 80 00       	push   $0x805000
  8018d0:	56                   	push   %esi
  8018d1:	ff 35 00 40 80 00    	pushl  0x804000
  8018d7:	e8 5d 08 00 00       	call   802139 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018dc:	83 c4 0c             	add    $0xc,%esp
  8018df:	6a 00                	push   $0x0
  8018e1:	53                   	push   %ebx
  8018e2:	6a 00                	push   $0x0
  8018e4:	e8 d5 07 00 00       	call   8020be <ipc_recv>
}
  8018e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ec:	5b                   	pop    %ebx
  8018ed:	5e                   	pop    %esi
  8018ee:	5d                   	pop    %ebp
  8018ef:	c3                   	ret    

008018f0 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018f0:	55                   	push   %ebp
  8018f1:	89 e5                	mov    %esp,%ebp
  8018f3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f9:	8b 40 0c             	mov    0xc(%eax),%eax
  8018fc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801901:	8b 45 0c             	mov    0xc(%ebp),%eax
  801904:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801909:	ba 00 00 00 00       	mov    $0x0,%edx
  80190e:	b8 02 00 00 00       	mov    $0x2,%eax
  801913:	e8 8d ff ff ff       	call   8018a5 <fsipc>
}
  801918:	c9                   	leave  
  801919:	c3                   	ret    

0080191a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80191a:	55                   	push   %ebp
  80191b:	89 e5                	mov    %esp,%ebp
  80191d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801920:	8b 45 08             	mov    0x8(%ebp),%eax
  801923:	8b 40 0c             	mov    0xc(%eax),%eax
  801926:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80192b:	ba 00 00 00 00       	mov    $0x0,%edx
  801930:	b8 06 00 00 00       	mov    $0x6,%eax
  801935:	e8 6b ff ff ff       	call   8018a5 <fsipc>
}
  80193a:	c9                   	leave  
  80193b:	c3                   	ret    

0080193c <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80193c:	55                   	push   %ebp
  80193d:	89 e5                	mov    %esp,%ebp
  80193f:	53                   	push   %ebx
  801940:	83 ec 04             	sub    $0x4,%esp
  801943:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801946:	8b 45 08             	mov    0x8(%ebp),%eax
  801949:	8b 40 0c             	mov    0xc(%eax),%eax
  80194c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801951:	ba 00 00 00 00       	mov    $0x0,%edx
  801956:	b8 05 00 00 00       	mov    $0x5,%eax
  80195b:	e8 45 ff ff ff       	call   8018a5 <fsipc>
  801960:	85 c0                	test   %eax,%eax
  801962:	78 2c                	js     801990 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801964:	83 ec 08             	sub    $0x8,%esp
  801967:	68 00 50 80 00       	push   $0x805000
  80196c:	53                   	push   %ebx
  80196d:	e8 26 ee ff ff       	call   800798 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801972:	a1 80 50 80 00       	mov    0x805080,%eax
  801977:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80197d:	a1 84 50 80 00       	mov    0x805084,%eax
  801982:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801988:	83 c4 10             	add    $0x10,%esp
  80198b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801990:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801993:	c9                   	leave  
  801994:	c3                   	ret    

00801995 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801995:	55                   	push   %ebp
  801996:	89 e5                	mov    %esp,%ebp
  801998:	83 ec 0c             	sub    $0xc,%esp
  80199b:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80199e:	8b 55 08             	mov    0x8(%ebp),%edx
  8019a1:	8b 52 0c             	mov    0xc(%edx),%edx
  8019a4:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8019aa:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8019af:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8019b4:	0f 47 c2             	cmova  %edx,%eax
  8019b7:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8019bc:	50                   	push   %eax
  8019bd:	ff 75 0c             	pushl  0xc(%ebp)
  8019c0:	68 08 50 80 00       	push   $0x805008
  8019c5:	e8 60 ef ff ff       	call   80092a <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8019ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8019cf:	b8 04 00 00 00       	mov    $0x4,%eax
  8019d4:	e8 cc fe ff ff       	call   8018a5 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8019d9:	c9                   	leave  
  8019da:	c3                   	ret    

008019db <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
  8019de:	56                   	push   %esi
  8019df:	53                   	push   %ebx
  8019e0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e6:	8b 40 0c             	mov    0xc(%eax),%eax
  8019e9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019ee:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f9:	b8 03 00 00 00       	mov    $0x3,%eax
  8019fe:	e8 a2 fe ff ff       	call   8018a5 <fsipc>
  801a03:	89 c3                	mov    %eax,%ebx
  801a05:	85 c0                	test   %eax,%eax
  801a07:	78 4b                	js     801a54 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a09:	39 c6                	cmp    %eax,%esi
  801a0b:	73 16                	jae    801a23 <devfile_read+0x48>
  801a0d:	68 24 29 80 00       	push   $0x802924
  801a12:	68 2b 29 80 00       	push   $0x80292b
  801a17:	6a 7c                	push   $0x7c
  801a19:	68 40 29 80 00       	push   $0x802940
  801a1e:	e8 c6 05 00 00       	call   801fe9 <_panic>
	assert(r <= PGSIZE);
  801a23:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a28:	7e 16                	jle    801a40 <devfile_read+0x65>
  801a2a:	68 4b 29 80 00       	push   $0x80294b
  801a2f:	68 2b 29 80 00       	push   $0x80292b
  801a34:	6a 7d                	push   $0x7d
  801a36:	68 40 29 80 00       	push   $0x802940
  801a3b:	e8 a9 05 00 00       	call   801fe9 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a40:	83 ec 04             	sub    $0x4,%esp
  801a43:	50                   	push   %eax
  801a44:	68 00 50 80 00       	push   $0x805000
  801a49:	ff 75 0c             	pushl  0xc(%ebp)
  801a4c:	e8 d9 ee ff ff       	call   80092a <memmove>
	return r;
  801a51:	83 c4 10             	add    $0x10,%esp
}
  801a54:	89 d8                	mov    %ebx,%eax
  801a56:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a59:	5b                   	pop    %ebx
  801a5a:	5e                   	pop    %esi
  801a5b:	5d                   	pop    %ebp
  801a5c:	c3                   	ret    

00801a5d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a5d:	55                   	push   %ebp
  801a5e:	89 e5                	mov    %esp,%ebp
  801a60:	53                   	push   %ebx
  801a61:	83 ec 20             	sub    $0x20,%esp
  801a64:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a67:	53                   	push   %ebx
  801a68:	e8 f2 ec ff ff       	call   80075f <strlen>
  801a6d:	83 c4 10             	add    $0x10,%esp
  801a70:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a75:	7f 67                	jg     801ade <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a77:	83 ec 0c             	sub    $0xc,%esp
  801a7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a7d:	50                   	push   %eax
  801a7e:	e8 8e f8 ff ff       	call   801311 <fd_alloc>
  801a83:	83 c4 10             	add    $0x10,%esp
		return r;
  801a86:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a88:	85 c0                	test   %eax,%eax
  801a8a:	78 57                	js     801ae3 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a8c:	83 ec 08             	sub    $0x8,%esp
  801a8f:	53                   	push   %ebx
  801a90:	68 00 50 80 00       	push   $0x805000
  801a95:	e8 fe ec ff ff       	call   800798 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a9d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801aa2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801aa5:	b8 01 00 00 00       	mov    $0x1,%eax
  801aaa:	e8 f6 fd ff ff       	call   8018a5 <fsipc>
  801aaf:	89 c3                	mov    %eax,%ebx
  801ab1:	83 c4 10             	add    $0x10,%esp
  801ab4:	85 c0                	test   %eax,%eax
  801ab6:	79 14                	jns    801acc <open+0x6f>
		fd_close(fd, 0);
  801ab8:	83 ec 08             	sub    $0x8,%esp
  801abb:	6a 00                	push   $0x0
  801abd:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac0:	e8 47 f9 ff ff       	call   80140c <fd_close>
		return r;
  801ac5:	83 c4 10             	add    $0x10,%esp
  801ac8:	89 da                	mov    %ebx,%edx
  801aca:	eb 17                	jmp    801ae3 <open+0x86>
	}

	return fd2num(fd);
  801acc:	83 ec 0c             	sub    $0xc,%esp
  801acf:	ff 75 f4             	pushl  -0xc(%ebp)
  801ad2:	e8 13 f8 ff ff       	call   8012ea <fd2num>
  801ad7:	89 c2                	mov    %eax,%edx
  801ad9:	83 c4 10             	add    $0x10,%esp
  801adc:	eb 05                	jmp    801ae3 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ade:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ae3:	89 d0                	mov    %edx,%eax
  801ae5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ae8:	c9                   	leave  
  801ae9:	c3                   	ret    

00801aea <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801af0:	ba 00 00 00 00       	mov    $0x0,%edx
  801af5:	b8 08 00 00 00       	mov    $0x8,%eax
  801afa:	e8 a6 fd ff ff       	call   8018a5 <fsipc>
}
  801aff:	c9                   	leave  
  801b00:	c3                   	ret    

00801b01 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b01:	55                   	push   %ebp
  801b02:	89 e5                	mov    %esp,%ebp
  801b04:	56                   	push   %esi
  801b05:	53                   	push   %ebx
  801b06:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b09:	83 ec 0c             	sub    $0xc,%esp
  801b0c:	ff 75 08             	pushl  0x8(%ebp)
  801b0f:	e8 e6 f7 ff ff       	call   8012fa <fd2data>
  801b14:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b16:	83 c4 08             	add    $0x8,%esp
  801b19:	68 57 29 80 00       	push   $0x802957
  801b1e:	53                   	push   %ebx
  801b1f:	e8 74 ec ff ff       	call   800798 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b24:	8b 46 04             	mov    0x4(%esi),%eax
  801b27:	2b 06                	sub    (%esi),%eax
  801b29:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b2f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b36:	00 00 00 
	stat->st_dev = &devpipe;
  801b39:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b40:	30 80 00 
	return 0;
}
  801b43:	b8 00 00 00 00       	mov    $0x0,%eax
  801b48:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b4b:	5b                   	pop    %ebx
  801b4c:	5e                   	pop    %esi
  801b4d:	5d                   	pop    %ebp
  801b4e:	c3                   	ret    

00801b4f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b4f:	55                   	push   %ebp
  801b50:	89 e5                	mov    %esp,%ebp
  801b52:	53                   	push   %ebx
  801b53:	83 ec 0c             	sub    $0xc,%esp
  801b56:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b59:	53                   	push   %ebx
  801b5a:	6a 00                	push   $0x0
  801b5c:	e8 bf f0 ff ff       	call   800c20 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b61:	89 1c 24             	mov    %ebx,(%esp)
  801b64:	e8 91 f7 ff ff       	call   8012fa <fd2data>
  801b69:	83 c4 08             	add    $0x8,%esp
  801b6c:	50                   	push   %eax
  801b6d:	6a 00                	push   $0x0
  801b6f:	e8 ac f0 ff ff       	call   800c20 <sys_page_unmap>
}
  801b74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b77:	c9                   	leave  
  801b78:	c3                   	ret    

00801b79 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b79:	55                   	push   %ebp
  801b7a:	89 e5                	mov    %esp,%ebp
  801b7c:	57                   	push   %edi
  801b7d:	56                   	push   %esi
  801b7e:	53                   	push   %ebx
  801b7f:	83 ec 1c             	sub    $0x1c,%esp
  801b82:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b85:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b87:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801b8c:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b92:	83 ec 0c             	sub    $0xc,%esp
  801b95:	ff 75 e0             	pushl  -0x20(%ebp)
  801b98:	e8 43 06 00 00       	call   8021e0 <pageref>
  801b9d:	89 c3                	mov    %eax,%ebx
  801b9f:	89 3c 24             	mov    %edi,(%esp)
  801ba2:	e8 39 06 00 00       	call   8021e0 <pageref>
  801ba7:	83 c4 10             	add    $0x10,%esp
  801baa:	39 c3                	cmp    %eax,%ebx
  801bac:	0f 94 c1             	sete   %cl
  801baf:	0f b6 c9             	movzbl %cl,%ecx
  801bb2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801bb5:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801bbb:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  801bc1:	39 ce                	cmp    %ecx,%esi
  801bc3:	74 1e                	je     801be3 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801bc5:	39 c3                	cmp    %eax,%ebx
  801bc7:	75 be                	jne    801b87 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bc9:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  801bcf:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bd2:	50                   	push   %eax
  801bd3:	56                   	push   %esi
  801bd4:	68 5e 29 80 00       	push   $0x80295e
  801bd9:	e8 35 e6 ff ff       	call   800213 <cprintf>
  801bde:	83 c4 10             	add    $0x10,%esp
  801be1:	eb a4                	jmp    801b87 <_pipeisclosed+0xe>
	}
}
  801be3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801be6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801be9:	5b                   	pop    %ebx
  801bea:	5e                   	pop    %esi
  801beb:	5f                   	pop    %edi
  801bec:	5d                   	pop    %ebp
  801bed:	c3                   	ret    

00801bee <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bee:	55                   	push   %ebp
  801bef:	89 e5                	mov    %esp,%ebp
  801bf1:	57                   	push   %edi
  801bf2:	56                   	push   %esi
  801bf3:	53                   	push   %ebx
  801bf4:	83 ec 28             	sub    $0x28,%esp
  801bf7:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bfa:	56                   	push   %esi
  801bfb:	e8 fa f6 ff ff       	call   8012fa <fd2data>
  801c00:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c02:	83 c4 10             	add    $0x10,%esp
  801c05:	bf 00 00 00 00       	mov    $0x0,%edi
  801c0a:	eb 4b                	jmp    801c57 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c0c:	89 da                	mov    %ebx,%edx
  801c0e:	89 f0                	mov    %esi,%eax
  801c10:	e8 64 ff ff ff       	call   801b79 <_pipeisclosed>
  801c15:	85 c0                	test   %eax,%eax
  801c17:	75 48                	jne    801c61 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c19:	e8 5e ef ff ff       	call   800b7c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c1e:	8b 43 04             	mov    0x4(%ebx),%eax
  801c21:	8b 0b                	mov    (%ebx),%ecx
  801c23:	8d 51 20             	lea    0x20(%ecx),%edx
  801c26:	39 d0                	cmp    %edx,%eax
  801c28:	73 e2                	jae    801c0c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c2d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c31:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c34:	89 c2                	mov    %eax,%edx
  801c36:	c1 fa 1f             	sar    $0x1f,%edx
  801c39:	89 d1                	mov    %edx,%ecx
  801c3b:	c1 e9 1b             	shr    $0x1b,%ecx
  801c3e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c41:	83 e2 1f             	and    $0x1f,%edx
  801c44:	29 ca                	sub    %ecx,%edx
  801c46:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c4a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c4e:	83 c0 01             	add    $0x1,%eax
  801c51:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c54:	83 c7 01             	add    $0x1,%edi
  801c57:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c5a:	75 c2                	jne    801c1e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c5c:	8b 45 10             	mov    0x10(%ebp),%eax
  801c5f:	eb 05                	jmp    801c66 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c61:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c69:	5b                   	pop    %ebx
  801c6a:	5e                   	pop    %esi
  801c6b:	5f                   	pop    %edi
  801c6c:	5d                   	pop    %ebp
  801c6d:	c3                   	ret    

00801c6e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c6e:	55                   	push   %ebp
  801c6f:	89 e5                	mov    %esp,%ebp
  801c71:	57                   	push   %edi
  801c72:	56                   	push   %esi
  801c73:	53                   	push   %ebx
  801c74:	83 ec 18             	sub    $0x18,%esp
  801c77:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c7a:	57                   	push   %edi
  801c7b:	e8 7a f6 ff ff       	call   8012fa <fd2data>
  801c80:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c82:	83 c4 10             	add    $0x10,%esp
  801c85:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c8a:	eb 3d                	jmp    801cc9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c8c:	85 db                	test   %ebx,%ebx
  801c8e:	74 04                	je     801c94 <devpipe_read+0x26>
				return i;
  801c90:	89 d8                	mov    %ebx,%eax
  801c92:	eb 44                	jmp    801cd8 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c94:	89 f2                	mov    %esi,%edx
  801c96:	89 f8                	mov    %edi,%eax
  801c98:	e8 dc fe ff ff       	call   801b79 <_pipeisclosed>
  801c9d:	85 c0                	test   %eax,%eax
  801c9f:	75 32                	jne    801cd3 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ca1:	e8 d6 ee ff ff       	call   800b7c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ca6:	8b 06                	mov    (%esi),%eax
  801ca8:	3b 46 04             	cmp    0x4(%esi),%eax
  801cab:	74 df                	je     801c8c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cad:	99                   	cltd   
  801cae:	c1 ea 1b             	shr    $0x1b,%edx
  801cb1:	01 d0                	add    %edx,%eax
  801cb3:	83 e0 1f             	and    $0x1f,%eax
  801cb6:	29 d0                	sub    %edx,%eax
  801cb8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cc0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801cc3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cc6:	83 c3 01             	add    $0x1,%ebx
  801cc9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ccc:	75 d8                	jne    801ca6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cce:	8b 45 10             	mov    0x10(%ebp),%eax
  801cd1:	eb 05                	jmp    801cd8 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cd3:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cdb:	5b                   	pop    %ebx
  801cdc:	5e                   	pop    %esi
  801cdd:	5f                   	pop    %edi
  801cde:	5d                   	pop    %ebp
  801cdf:	c3                   	ret    

00801ce0 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	56                   	push   %esi
  801ce4:	53                   	push   %ebx
  801ce5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ce8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ceb:	50                   	push   %eax
  801cec:	e8 20 f6 ff ff       	call   801311 <fd_alloc>
  801cf1:	83 c4 10             	add    $0x10,%esp
  801cf4:	89 c2                	mov    %eax,%edx
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	0f 88 2c 01 00 00    	js     801e2a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cfe:	83 ec 04             	sub    $0x4,%esp
  801d01:	68 07 04 00 00       	push   $0x407
  801d06:	ff 75 f4             	pushl  -0xc(%ebp)
  801d09:	6a 00                	push   $0x0
  801d0b:	e8 8b ee ff ff       	call   800b9b <sys_page_alloc>
  801d10:	83 c4 10             	add    $0x10,%esp
  801d13:	89 c2                	mov    %eax,%edx
  801d15:	85 c0                	test   %eax,%eax
  801d17:	0f 88 0d 01 00 00    	js     801e2a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d1d:	83 ec 0c             	sub    $0xc,%esp
  801d20:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d23:	50                   	push   %eax
  801d24:	e8 e8 f5 ff ff       	call   801311 <fd_alloc>
  801d29:	89 c3                	mov    %eax,%ebx
  801d2b:	83 c4 10             	add    $0x10,%esp
  801d2e:	85 c0                	test   %eax,%eax
  801d30:	0f 88 e2 00 00 00    	js     801e18 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d36:	83 ec 04             	sub    $0x4,%esp
  801d39:	68 07 04 00 00       	push   $0x407
  801d3e:	ff 75 f0             	pushl  -0x10(%ebp)
  801d41:	6a 00                	push   $0x0
  801d43:	e8 53 ee ff ff       	call   800b9b <sys_page_alloc>
  801d48:	89 c3                	mov    %eax,%ebx
  801d4a:	83 c4 10             	add    $0x10,%esp
  801d4d:	85 c0                	test   %eax,%eax
  801d4f:	0f 88 c3 00 00 00    	js     801e18 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d55:	83 ec 0c             	sub    $0xc,%esp
  801d58:	ff 75 f4             	pushl  -0xc(%ebp)
  801d5b:	e8 9a f5 ff ff       	call   8012fa <fd2data>
  801d60:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d62:	83 c4 0c             	add    $0xc,%esp
  801d65:	68 07 04 00 00       	push   $0x407
  801d6a:	50                   	push   %eax
  801d6b:	6a 00                	push   $0x0
  801d6d:	e8 29 ee ff ff       	call   800b9b <sys_page_alloc>
  801d72:	89 c3                	mov    %eax,%ebx
  801d74:	83 c4 10             	add    $0x10,%esp
  801d77:	85 c0                	test   %eax,%eax
  801d79:	0f 88 89 00 00 00    	js     801e08 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d7f:	83 ec 0c             	sub    $0xc,%esp
  801d82:	ff 75 f0             	pushl  -0x10(%ebp)
  801d85:	e8 70 f5 ff ff       	call   8012fa <fd2data>
  801d8a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d91:	50                   	push   %eax
  801d92:	6a 00                	push   $0x0
  801d94:	56                   	push   %esi
  801d95:	6a 00                	push   $0x0
  801d97:	e8 42 ee ff ff       	call   800bde <sys_page_map>
  801d9c:	89 c3                	mov    %eax,%ebx
  801d9e:	83 c4 20             	add    $0x20,%esp
  801da1:	85 c0                	test   %eax,%eax
  801da3:	78 55                	js     801dfa <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801da5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dae:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801dba:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dc3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801dc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dc8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801dcf:	83 ec 0c             	sub    $0xc,%esp
  801dd2:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd5:	e8 10 f5 ff ff       	call   8012ea <fd2num>
  801dda:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ddd:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ddf:	83 c4 04             	add    $0x4,%esp
  801de2:	ff 75 f0             	pushl  -0x10(%ebp)
  801de5:	e8 00 f5 ff ff       	call   8012ea <fd2num>
  801dea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ded:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801df0:	83 c4 10             	add    $0x10,%esp
  801df3:	ba 00 00 00 00       	mov    $0x0,%edx
  801df8:	eb 30                	jmp    801e2a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801dfa:	83 ec 08             	sub    $0x8,%esp
  801dfd:	56                   	push   %esi
  801dfe:	6a 00                	push   $0x0
  801e00:	e8 1b ee ff ff       	call   800c20 <sys_page_unmap>
  801e05:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e08:	83 ec 08             	sub    $0x8,%esp
  801e0b:	ff 75 f0             	pushl  -0x10(%ebp)
  801e0e:	6a 00                	push   $0x0
  801e10:	e8 0b ee ff ff       	call   800c20 <sys_page_unmap>
  801e15:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e18:	83 ec 08             	sub    $0x8,%esp
  801e1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801e1e:	6a 00                	push   $0x0
  801e20:	e8 fb ed ff ff       	call   800c20 <sys_page_unmap>
  801e25:	83 c4 10             	add    $0x10,%esp
  801e28:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e2a:	89 d0                	mov    %edx,%eax
  801e2c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e2f:	5b                   	pop    %ebx
  801e30:	5e                   	pop    %esi
  801e31:	5d                   	pop    %ebp
  801e32:	c3                   	ret    

00801e33 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e33:	55                   	push   %ebp
  801e34:	89 e5                	mov    %esp,%ebp
  801e36:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e39:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e3c:	50                   	push   %eax
  801e3d:	ff 75 08             	pushl  0x8(%ebp)
  801e40:	e8 1b f5 ff ff       	call   801360 <fd_lookup>
  801e45:	83 c4 10             	add    $0x10,%esp
  801e48:	85 c0                	test   %eax,%eax
  801e4a:	78 18                	js     801e64 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e4c:	83 ec 0c             	sub    $0xc,%esp
  801e4f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e52:	e8 a3 f4 ff ff       	call   8012fa <fd2data>
	return _pipeisclosed(fd, p);
  801e57:	89 c2                	mov    %eax,%edx
  801e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5c:	e8 18 fd ff ff       	call   801b79 <_pipeisclosed>
  801e61:	83 c4 10             	add    $0x10,%esp
}
  801e64:	c9                   	leave  
  801e65:	c3                   	ret    

00801e66 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e66:	55                   	push   %ebp
  801e67:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e69:	b8 00 00 00 00       	mov    $0x0,%eax
  801e6e:	5d                   	pop    %ebp
  801e6f:	c3                   	ret    

00801e70 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e70:	55                   	push   %ebp
  801e71:	89 e5                	mov    %esp,%ebp
  801e73:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e76:	68 76 29 80 00       	push   $0x802976
  801e7b:	ff 75 0c             	pushl  0xc(%ebp)
  801e7e:	e8 15 e9 ff ff       	call   800798 <strcpy>
	return 0;
}
  801e83:	b8 00 00 00 00       	mov    $0x0,%eax
  801e88:	c9                   	leave  
  801e89:	c3                   	ret    

00801e8a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e8a:	55                   	push   %ebp
  801e8b:	89 e5                	mov    %esp,%ebp
  801e8d:	57                   	push   %edi
  801e8e:	56                   	push   %esi
  801e8f:	53                   	push   %ebx
  801e90:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e96:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e9b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ea1:	eb 2d                	jmp    801ed0 <devcons_write+0x46>
		m = n - tot;
  801ea3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ea6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ea8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801eab:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801eb0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801eb3:	83 ec 04             	sub    $0x4,%esp
  801eb6:	53                   	push   %ebx
  801eb7:	03 45 0c             	add    0xc(%ebp),%eax
  801eba:	50                   	push   %eax
  801ebb:	57                   	push   %edi
  801ebc:	e8 69 ea ff ff       	call   80092a <memmove>
		sys_cputs(buf, m);
  801ec1:	83 c4 08             	add    $0x8,%esp
  801ec4:	53                   	push   %ebx
  801ec5:	57                   	push   %edi
  801ec6:	e8 14 ec ff ff       	call   800adf <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ecb:	01 de                	add    %ebx,%esi
  801ecd:	83 c4 10             	add    $0x10,%esp
  801ed0:	89 f0                	mov    %esi,%eax
  801ed2:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ed5:	72 cc                	jb     801ea3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ed7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eda:	5b                   	pop    %ebx
  801edb:	5e                   	pop    %esi
  801edc:	5f                   	pop    %edi
  801edd:	5d                   	pop    %ebp
  801ede:	c3                   	ret    

00801edf <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801edf:	55                   	push   %ebp
  801ee0:	89 e5                	mov    %esp,%ebp
  801ee2:	83 ec 08             	sub    $0x8,%esp
  801ee5:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801eea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801eee:	74 2a                	je     801f1a <devcons_read+0x3b>
  801ef0:	eb 05                	jmp    801ef7 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ef2:	e8 85 ec ff ff       	call   800b7c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ef7:	e8 01 ec ff ff       	call   800afd <sys_cgetc>
  801efc:	85 c0                	test   %eax,%eax
  801efe:	74 f2                	je     801ef2 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f00:	85 c0                	test   %eax,%eax
  801f02:	78 16                	js     801f1a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f04:	83 f8 04             	cmp    $0x4,%eax
  801f07:	74 0c                	je     801f15 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f09:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f0c:	88 02                	mov    %al,(%edx)
	return 1;
  801f0e:	b8 01 00 00 00       	mov    $0x1,%eax
  801f13:	eb 05                	jmp    801f1a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f15:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f1a:	c9                   	leave  
  801f1b:	c3                   	ret    

00801f1c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f1c:	55                   	push   %ebp
  801f1d:	89 e5                	mov    %esp,%ebp
  801f1f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f22:	8b 45 08             	mov    0x8(%ebp),%eax
  801f25:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f28:	6a 01                	push   $0x1
  801f2a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f2d:	50                   	push   %eax
  801f2e:	e8 ac eb ff ff       	call   800adf <sys_cputs>
}
  801f33:	83 c4 10             	add    $0x10,%esp
  801f36:	c9                   	leave  
  801f37:	c3                   	ret    

00801f38 <getchar>:

int
getchar(void)
{
  801f38:	55                   	push   %ebp
  801f39:	89 e5                	mov    %esp,%ebp
  801f3b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f3e:	6a 01                	push   $0x1
  801f40:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f43:	50                   	push   %eax
  801f44:	6a 00                	push   $0x0
  801f46:	e8 7e f6 ff ff       	call   8015c9 <read>
	if (r < 0)
  801f4b:	83 c4 10             	add    $0x10,%esp
  801f4e:	85 c0                	test   %eax,%eax
  801f50:	78 0f                	js     801f61 <getchar+0x29>
		return r;
	if (r < 1)
  801f52:	85 c0                	test   %eax,%eax
  801f54:	7e 06                	jle    801f5c <getchar+0x24>
		return -E_EOF;
	return c;
  801f56:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f5a:	eb 05                	jmp    801f61 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f5c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f61:	c9                   	leave  
  801f62:	c3                   	ret    

00801f63 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f63:	55                   	push   %ebp
  801f64:	89 e5                	mov    %esp,%ebp
  801f66:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f69:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f6c:	50                   	push   %eax
  801f6d:	ff 75 08             	pushl  0x8(%ebp)
  801f70:	e8 eb f3 ff ff       	call   801360 <fd_lookup>
  801f75:	83 c4 10             	add    $0x10,%esp
  801f78:	85 c0                	test   %eax,%eax
  801f7a:	78 11                	js     801f8d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f7f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f85:	39 10                	cmp    %edx,(%eax)
  801f87:	0f 94 c0             	sete   %al
  801f8a:	0f b6 c0             	movzbl %al,%eax
}
  801f8d:	c9                   	leave  
  801f8e:	c3                   	ret    

00801f8f <opencons>:

int
opencons(void)
{
  801f8f:	55                   	push   %ebp
  801f90:	89 e5                	mov    %esp,%ebp
  801f92:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f95:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f98:	50                   	push   %eax
  801f99:	e8 73 f3 ff ff       	call   801311 <fd_alloc>
  801f9e:	83 c4 10             	add    $0x10,%esp
		return r;
  801fa1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fa3:	85 c0                	test   %eax,%eax
  801fa5:	78 3e                	js     801fe5 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fa7:	83 ec 04             	sub    $0x4,%esp
  801faa:	68 07 04 00 00       	push   $0x407
  801faf:	ff 75 f4             	pushl  -0xc(%ebp)
  801fb2:	6a 00                	push   $0x0
  801fb4:	e8 e2 eb ff ff       	call   800b9b <sys_page_alloc>
  801fb9:	83 c4 10             	add    $0x10,%esp
		return r;
  801fbc:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fbe:	85 c0                	test   %eax,%eax
  801fc0:	78 23                	js     801fe5 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fc2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fcb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fd7:	83 ec 0c             	sub    $0xc,%esp
  801fda:	50                   	push   %eax
  801fdb:	e8 0a f3 ff ff       	call   8012ea <fd2num>
  801fe0:	89 c2                	mov    %eax,%edx
  801fe2:	83 c4 10             	add    $0x10,%esp
}
  801fe5:	89 d0                	mov    %edx,%eax
  801fe7:	c9                   	leave  
  801fe8:	c3                   	ret    

00801fe9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801fe9:	55                   	push   %ebp
  801fea:	89 e5                	mov    %esp,%ebp
  801fec:	56                   	push   %esi
  801fed:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801fee:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ff1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ff7:	e8 61 eb ff ff       	call   800b5d <sys_getenvid>
  801ffc:	83 ec 0c             	sub    $0xc,%esp
  801fff:	ff 75 0c             	pushl  0xc(%ebp)
  802002:	ff 75 08             	pushl  0x8(%ebp)
  802005:	56                   	push   %esi
  802006:	50                   	push   %eax
  802007:	68 84 29 80 00       	push   $0x802984
  80200c:	e8 02 e2 ff ff       	call   800213 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802011:	83 c4 18             	add    $0x18,%esp
  802014:	53                   	push   %ebx
  802015:	ff 75 10             	pushl  0x10(%ebp)
  802018:	e8 a5 e1 ff ff       	call   8001c2 <vcprintf>
	cprintf("\n");
  80201d:	c7 04 24 7b 28 80 00 	movl   $0x80287b,(%esp)
  802024:	e8 ea e1 ff ff       	call   800213 <cprintf>
  802029:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80202c:	cc                   	int3   
  80202d:	eb fd                	jmp    80202c <_panic+0x43>

0080202f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80202f:	55                   	push   %ebp
  802030:	89 e5                	mov    %esp,%ebp
  802032:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802035:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80203c:	75 2a                	jne    802068 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  80203e:	83 ec 04             	sub    $0x4,%esp
  802041:	6a 07                	push   $0x7
  802043:	68 00 f0 bf ee       	push   $0xeebff000
  802048:	6a 00                	push   $0x0
  80204a:	e8 4c eb ff ff       	call   800b9b <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  80204f:	83 c4 10             	add    $0x10,%esp
  802052:	85 c0                	test   %eax,%eax
  802054:	79 12                	jns    802068 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802056:	50                   	push   %eax
  802057:	68 92 28 80 00       	push   $0x802892
  80205c:	6a 23                	push   $0x23
  80205e:	68 a8 29 80 00       	push   $0x8029a8
  802063:	e8 81 ff ff ff       	call   801fe9 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802068:	8b 45 08             	mov    0x8(%ebp),%eax
  80206b:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802070:	83 ec 08             	sub    $0x8,%esp
  802073:	68 9a 20 80 00       	push   $0x80209a
  802078:	6a 00                	push   $0x0
  80207a:	e8 67 ec ff ff       	call   800ce6 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  80207f:	83 c4 10             	add    $0x10,%esp
  802082:	85 c0                	test   %eax,%eax
  802084:	79 12                	jns    802098 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802086:	50                   	push   %eax
  802087:	68 92 28 80 00       	push   $0x802892
  80208c:	6a 2c                	push   $0x2c
  80208e:	68 a8 29 80 00       	push   $0x8029a8
  802093:	e8 51 ff ff ff       	call   801fe9 <_panic>
	}
}
  802098:	c9                   	leave  
  802099:	c3                   	ret    

0080209a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80209a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80209b:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8020a0:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8020a2:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8020a5:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8020a9:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8020ae:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8020b2:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8020b4:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8020b7:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8020b8:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8020bb:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8020bc:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8020bd:	c3                   	ret    

008020be <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020be:	55                   	push   %ebp
  8020bf:	89 e5                	mov    %esp,%ebp
  8020c1:	56                   	push   %esi
  8020c2:	53                   	push   %ebx
  8020c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8020c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8020cc:	85 c0                	test   %eax,%eax
  8020ce:	75 12                	jne    8020e2 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8020d0:	83 ec 0c             	sub    $0xc,%esp
  8020d3:	68 00 00 c0 ee       	push   $0xeec00000
  8020d8:	e8 6e ec ff ff       	call   800d4b <sys_ipc_recv>
  8020dd:	83 c4 10             	add    $0x10,%esp
  8020e0:	eb 0c                	jmp    8020ee <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8020e2:	83 ec 0c             	sub    $0xc,%esp
  8020e5:	50                   	push   %eax
  8020e6:	e8 60 ec ff ff       	call   800d4b <sys_ipc_recv>
  8020eb:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8020ee:	85 f6                	test   %esi,%esi
  8020f0:	0f 95 c1             	setne  %cl
  8020f3:	85 db                	test   %ebx,%ebx
  8020f5:	0f 95 c2             	setne  %dl
  8020f8:	84 d1                	test   %dl,%cl
  8020fa:	74 09                	je     802105 <ipc_recv+0x47>
  8020fc:	89 c2                	mov    %eax,%edx
  8020fe:	c1 ea 1f             	shr    $0x1f,%edx
  802101:	84 d2                	test   %dl,%dl
  802103:	75 2d                	jne    802132 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802105:	85 f6                	test   %esi,%esi
  802107:	74 0d                	je     802116 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802109:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80210e:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  802114:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802116:	85 db                	test   %ebx,%ebx
  802118:	74 0d                	je     802127 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80211a:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80211f:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802125:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802127:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80212c:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  802132:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802135:	5b                   	pop    %ebx
  802136:	5e                   	pop    %esi
  802137:	5d                   	pop    %ebp
  802138:	c3                   	ret    

00802139 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802139:	55                   	push   %ebp
  80213a:	89 e5                	mov    %esp,%ebp
  80213c:	57                   	push   %edi
  80213d:	56                   	push   %esi
  80213e:	53                   	push   %ebx
  80213f:	83 ec 0c             	sub    $0xc,%esp
  802142:	8b 7d 08             	mov    0x8(%ebp),%edi
  802145:	8b 75 0c             	mov    0xc(%ebp),%esi
  802148:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80214b:	85 db                	test   %ebx,%ebx
  80214d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802152:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802155:	ff 75 14             	pushl  0x14(%ebp)
  802158:	53                   	push   %ebx
  802159:	56                   	push   %esi
  80215a:	57                   	push   %edi
  80215b:	e8 c8 eb ff ff       	call   800d28 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802160:	89 c2                	mov    %eax,%edx
  802162:	c1 ea 1f             	shr    $0x1f,%edx
  802165:	83 c4 10             	add    $0x10,%esp
  802168:	84 d2                	test   %dl,%dl
  80216a:	74 17                	je     802183 <ipc_send+0x4a>
  80216c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80216f:	74 12                	je     802183 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802171:	50                   	push   %eax
  802172:	68 b6 29 80 00       	push   $0x8029b6
  802177:	6a 47                	push   $0x47
  802179:	68 c4 29 80 00       	push   $0x8029c4
  80217e:	e8 66 fe ff ff       	call   801fe9 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802183:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802186:	75 07                	jne    80218f <ipc_send+0x56>
			sys_yield();
  802188:	e8 ef e9 ff ff       	call   800b7c <sys_yield>
  80218d:	eb c6                	jmp    802155 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80218f:	85 c0                	test   %eax,%eax
  802191:	75 c2                	jne    802155 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802193:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802196:	5b                   	pop    %ebx
  802197:	5e                   	pop    %esi
  802198:	5f                   	pop    %edi
  802199:	5d                   	pop    %ebp
  80219a:	c3                   	ret    

0080219b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80219b:	55                   	push   %ebp
  80219c:	89 e5                	mov    %esp,%ebp
  80219e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8021a1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021a6:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  8021ac:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021b2:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  8021b8:	39 ca                	cmp    %ecx,%edx
  8021ba:	75 13                	jne    8021cf <ipc_find_env+0x34>
			return envs[i].env_id;
  8021bc:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8021c2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021c7:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8021cd:	eb 0f                	jmp    8021de <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021cf:	83 c0 01             	add    $0x1,%eax
  8021d2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021d7:	75 cd                	jne    8021a6 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021de:	5d                   	pop    %ebp
  8021df:	c3                   	ret    

008021e0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021e0:	55                   	push   %ebp
  8021e1:	89 e5                	mov    %esp,%ebp
  8021e3:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021e6:	89 d0                	mov    %edx,%eax
  8021e8:	c1 e8 16             	shr    $0x16,%eax
  8021eb:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021f2:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021f7:	f6 c1 01             	test   $0x1,%cl
  8021fa:	74 1d                	je     802219 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021fc:	c1 ea 0c             	shr    $0xc,%edx
  8021ff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802206:	f6 c2 01             	test   $0x1,%dl
  802209:	74 0e                	je     802219 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80220b:	c1 ea 0c             	shr    $0xc,%edx
  80220e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802215:	ef 
  802216:	0f b7 c0             	movzwl %ax,%eax
}
  802219:	5d                   	pop    %ebp
  80221a:	c3                   	ret    
  80221b:	66 90                	xchg   %ax,%ax
  80221d:	66 90                	xchg   %ax,%ax
  80221f:	90                   	nop

00802220 <__udivdi3>:
  802220:	55                   	push   %ebp
  802221:	57                   	push   %edi
  802222:	56                   	push   %esi
  802223:	53                   	push   %ebx
  802224:	83 ec 1c             	sub    $0x1c,%esp
  802227:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80222b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80222f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802233:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802237:	85 f6                	test   %esi,%esi
  802239:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80223d:	89 ca                	mov    %ecx,%edx
  80223f:	89 f8                	mov    %edi,%eax
  802241:	75 3d                	jne    802280 <__udivdi3+0x60>
  802243:	39 cf                	cmp    %ecx,%edi
  802245:	0f 87 c5 00 00 00    	ja     802310 <__udivdi3+0xf0>
  80224b:	85 ff                	test   %edi,%edi
  80224d:	89 fd                	mov    %edi,%ebp
  80224f:	75 0b                	jne    80225c <__udivdi3+0x3c>
  802251:	b8 01 00 00 00       	mov    $0x1,%eax
  802256:	31 d2                	xor    %edx,%edx
  802258:	f7 f7                	div    %edi
  80225a:	89 c5                	mov    %eax,%ebp
  80225c:	89 c8                	mov    %ecx,%eax
  80225e:	31 d2                	xor    %edx,%edx
  802260:	f7 f5                	div    %ebp
  802262:	89 c1                	mov    %eax,%ecx
  802264:	89 d8                	mov    %ebx,%eax
  802266:	89 cf                	mov    %ecx,%edi
  802268:	f7 f5                	div    %ebp
  80226a:	89 c3                	mov    %eax,%ebx
  80226c:	89 d8                	mov    %ebx,%eax
  80226e:	89 fa                	mov    %edi,%edx
  802270:	83 c4 1c             	add    $0x1c,%esp
  802273:	5b                   	pop    %ebx
  802274:	5e                   	pop    %esi
  802275:	5f                   	pop    %edi
  802276:	5d                   	pop    %ebp
  802277:	c3                   	ret    
  802278:	90                   	nop
  802279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802280:	39 ce                	cmp    %ecx,%esi
  802282:	77 74                	ja     8022f8 <__udivdi3+0xd8>
  802284:	0f bd fe             	bsr    %esi,%edi
  802287:	83 f7 1f             	xor    $0x1f,%edi
  80228a:	0f 84 98 00 00 00    	je     802328 <__udivdi3+0x108>
  802290:	bb 20 00 00 00       	mov    $0x20,%ebx
  802295:	89 f9                	mov    %edi,%ecx
  802297:	89 c5                	mov    %eax,%ebp
  802299:	29 fb                	sub    %edi,%ebx
  80229b:	d3 e6                	shl    %cl,%esi
  80229d:	89 d9                	mov    %ebx,%ecx
  80229f:	d3 ed                	shr    %cl,%ebp
  8022a1:	89 f9                	mov    %edi,%ecx
  8022a3:	d3 e0                	shl    %cl,%eax
  8022a5:	09 ee                	or     %ebp,%esi
  8022a7:	89 d9                	mov    %ebx,%ecx
  8022a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022ad:	89 d5                	mov    %edx,%ebp
  8022af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022b3:	d3 ed                	shr    %cl,%ebp
  8022b5:	89 f9                	mov    %edi,%ecx
  8022b7:	d3 e2                	shl    %cl,%edx
  8022b9:	89 d9                	mov    %ebx,%ecx
  8022bb:	d3 e8                	shr    %cl,%eax
  8022bd:	09 c2                	or     %eax,%edx
  8022bf:	89 d0                	mov    %edx,%eax
  8022c1:	89 ea                	mov    %ebp,%edx
  8022c3:	f7 f6                	div    %esi
  8022c5:	89 d5                	mov    %edx,%ebp
  8022c7:	89 c3                	mov    %eax,%ebx
  8022c9:	f7 64 24 0c          	mull   0xc(%esp)
  8022cd:	39 d5                	cmp    %edx,%ebp
  8022cf:	72 10                	jb     8022e1 <__udivdi3+0xc1>
  8022d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8022d5:	89 f9                	mov    %edi,%ecx
  8022d7:	d3 e6                	shl    %cl,%esi
  8022d9:	39 c6                	cmp    %eax,%esi
  8022db:	73 07                	jae    8022e4 <__udivdi3+0xc4>
  8022dd:	39 d5                	cmp    %edx,%ebp
  8022df:	75 03                	jne    8022e4 <__udivdi3+0xc4>
  8022e1:	83 eb 01             	sub    $0x1,%ebx
  8022e4:	31 ff                	xor    %edi,%edi
  8022e6:	89 d8                	mov    %ebx,%eax
  8022e8:	89 fa                	mov    %edi,%edx
  8022ea:	83 c4 1c             	add    $0x1c,%esp
  8022ed:	5b                   	pop    %ebx
  8022ee:	5e                   	pop    %esi
  8022ef:	5f                   	pop    %edi
  8022f0:	5d                   	pop    %ebp
  8022f1:	c3                   	ret    
  8022f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022f8:	31 ff                	xor    %edi,%edi
  8022fa:	31 db                	xor    %ebx,%ebx
  8022fc:	89 d8                	mov    %ebx,%eax
  8022fe:	89 fa                	mov    %edi,%edx
  802300:	83 c4 1c             	add    $0x1c,%esp
  802303:	5b                   	pop    %ebx
  802304:	5e                   	pop    %esi
  802305:	5f                   	pop    %edi
  802306:	5d                   	pop    %ebp
  802307:	c3                   	ret    
  802308:	90                   	nop
  802309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802310:	89 d8                	mov    %ebx,%eax
  802312:	f7 f7                	div    %edi
  802314:	31 ff                	xor    %edi,%edi
  802316:	89 c3                	mov    %eax,%ebx
  802318:	89 d8                	mov    %ebx,%eax
  80231a:	89 fa                	mov    %edi,%edx
  80231c:	83 c4 1c             	add    $0x1c,%esp
  80231f:	5b                   	pop    %ebx
  802320:	5e                   	pop    %esi
  802321:	5f                   	pop    %edi
  802322:	5d                   	pop    %ebp
  802323:	c3                   	ret    
  802324:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802328:	39 ce                	cmp    %ecx,%esi
  80232a:	72 0c                	jb     802338 <__udivdi3+0x118>
  80232c:	31 db                	xor    %ebx,%ebx
  80232e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802332:	0f 87 34 ff ff ff    	ja     80226c <__udivdi3+0x4c>
  802338:	bb 01 00 00 00       	mov    $0x1,%ebx
  80233d:	e9 2a ff ff ff       	jmp    80226c <__udivdi3+0x4c>
  802342:	66 90                	xchg   %ax,%ax
  802344:	66 90                	xchg   %ax,%ax
  802346:	66 90                	xchg   %ax,%ax
  802348:	66 90                	xchg   %ax,%ax
  80234a:	66 90                	xchg   %ax,%ax
  80234c:	66 90                	xchg   %ax,%ax
  80234e:	66 90                	xchg   %ax,%ax

00802350 <__umoddi3>:
  802350:	55                   	push   %ebp
  802351:	57                   	push   %edi
  802352:	56                   	push   %esi
  802353:	53                   	push   %ebx
  802354:	83 ec 1c             	sub    $0x1c,%esp
  802357:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80235b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80235f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802363:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802367:	85 d2                	test   %edx,%edx
  802369:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80236d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802371:	89 f3                	mov    %esi,%ebx
  802373:	89 3c 24             	mov    %edi,(%esp)
  802376:	89 74 24 04          	mov    %esi,0x4(%esp)
  80237a:	75 1c                	jne    802398 <__umoddi3+0x48>
  80237c:	39 f7                	cmp    %esi,%edi
  80237e:	76 50                	jbe    8023d0 <__umoddi3+0x80>
  802380:	89 c8                	mov    %ecx,%eax
  802382:	89 f2                	mov    %esi,%edx
  802384:	f7 f7                	div    %edi
  802386:	89 d0                	mov    %edx,%eax
  802388:	31 d2                	xor    %edx,%edx
  80238a:	83 c4 1c             	add    $0x1c,%esp
  80238d:	5b                   	pop    %ebx
  80238e:	5e                   	pop    %esi
  80238f:	5f                   	pop    %edi
  802390:	5d                   	pop    %ebp
  802391:	c3                   	ret    
  802392:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802398:	39 f2                	cmp    %esi,%edx
  80239a:	89 d0                	mov    %edx,%eax
  80239c:	77 52                	ja     8023f0 <__umoddi3+0xa0>
  80239e:	0f bd ea             	bsr    %edx,%ebp
  8023a1:	83 f5 1f             	xor    $0x1f,%ebp
  8023a4:	75 5a                	jne    802400 <__umoddi3+0xb0>
  8023a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8023aa:	0f 82 e0 00 00 00    	jb     802490 <__umoddi3+0x140>
  8023b0:	39 0c 24             	cmp    %ecx,(%esp)
  8023b3:	0f 86 d7 00 00 00    	jbe    802490 <__umoddi3+0x140>
  8023b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023c1:	83 c4 1c             	add    $0x1c,%esp
  8023c4:	5b                   	pop    %ebx
  8023c5:	5e                   	pop    %esi
  8023c6:	5f                   	pop    %edi
  8023c7:	5d                   	pop    %ebp
  8023c8:	c3                   	ret    
  8023c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023d0:	85 ff                	test   %edi,%edi
  8023d2:	89 fd                	mov    %edi,%ebp
  8023d4:	75 0b                	jne    8023e1 <__umoddi3+0x91>
  8023d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023db:	31 d2                	xor    %edx,%edx
  8023dd:	f7 f7                	div    %edi
  8023df:	89 c5                	mov    %eax,%ebp
  8023e1:	89 f0                	mov    %esi,%eax
  8023e3:	31 d2                	xor    %edx,%edx
  8023e5:	f7 f5                	div    %ebp
  8023e7:	89 c8                	mov    %ecx,%eax
  8023e9:	f7 f5                	div    %ebp
  8023eb:	89 d0                	mov    %edx,%eax
  8023ed:	eb 99                	jmp    802388 <__umoddi3+0x38>
  8023ef:	90                   	nop
  8023f0:	89 c8                	mov    %ecx,%eax
  8023f2:	89 f2                	mov    %esi,%edx
  8023f4:	83 c4 1c             	add    $0x1c,%esp
  8023f7:	5b                   	pop    %ebx
  8023f8:	5e                   	pop    %esi
  8023f9:	5f                   	pop    %edi
  8023fa:	5d                   	pop    %ebp
  8023fb:	c3                   	ret    
  8023fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802400:	8b 34 24             	mov    (%esp),%esi
  802403:	bf 20 00 00 00       	mov    $0x20,%edi
  802408:	89 e9                	mov    %ebp,%ecx
  80240a:	29 ef                	sub    %ebp,%edi
  80240c:	d3 e0                	shl    %cl,%eax
  80240e:	89 f9                	mov    %edi,%ecx
  802410:	89 f2                	mov    %esi,%edx
  802412:	d3 ea                	shr    %cl,%edx
  802414:	89 e9                	mov    %ebp,%ecx
  802416:	09 c2                	or     %eax,%edx
  802418:	89 d8                	mov    %ebx,%eax
  80241a:	89 14 24             	mov    %edx,(%esp)
  80241d:	89 f2                	mov    %esi,%edx
  80241f:	d3 e2                	shl    %cl,%edx
  802421:	89 f9                	mov    %edi,%ecx
  802423:	89 54 24 04          	mov    %edx,0x4(%esp)
  802427:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80242b:	d3 e8                	shr    %cl,%eax
  80242d:	89 e9                	mov    %ebp,%ecx
  80242f:	89 c6                	mov    %eax,%esi
  802431:	d3 e3                	shl    %cl,%ebx
  802433:	89 f9                	mov    %edi,%ecx
  802435:	89 d0                	mov    %edx,%eax
  802437:	d3 e8                	shr    %cl,%eax
  802439:	89 e9                	mov    %ebp,%ecx
  80243b:	09 d8                	or     %ebx,%eax
  80243d:	89 d3                	mov    %edx,%ebx
  80243f:	89 f2                	mov    %esi,%edx
  802441:	f7 34 24             	divl   (%esp)
  802444:	89 d6                	mov    %edx,%esi
  802446:	d3 e3                	shl    %cl,%ebx
  802448:	f7 64 24 04          	mull   0x4(%esp)
  80244c:	39 d6                	cmp    %edx,%esi
  80244e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802452:	89 d1                	mov    %edx,%ecx
  802454:	89 c3                	mov    %eax,%ebx
  802456:	72 08                	jb     802460 <__umoddi3+0x110>
  802458:	75 11                	jne    80246b <__umoddi3+0x11b>
  80245a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80245e:	73 0b                	jae    80246b <__umoddi3+0x11b>
  802460:	2b 44 24 04          	sub    0x4(%esp),%eax
  802464:	1b 14 24             	sbb    (%esp),%edx
  802467:	89 d1                	mov    %edx,%ecx
  802469:	89 c3                	mov    %eax,%ebx
  80246b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80246f:	29 da                	sub    %ebx,%edx
  802471:	19 ce                	sbb    %ecx,%esi
  802473:	89 f9                	mov    %edi,%ecx
  802475:	89 f0                	mov    %esi,%eax
  802477:	d3 e0                	shl    %cl,%eax
  802479:	89 e9                	mov    %ebp,%ecx
  80247b:	d3 ea                	shr    %cl,%edx
  80247d:	89 e9                	mov    %ebp,%ecx
  80247f:	d3 ee                	shr    %cl,%esi
  802481:	09 d0                	or     %edx,%eax
  802483:	89 f2                	mov    %esi,%edx
  802485:	83 c4 1c             	add    $0x1c,%esp
  802488:	5b                   	pop    %ebx
  802489:	5e                   	pop    %esi
  80248a:	5f                   	pop    %edi
  80248b:	5d                   	pop    %ebp
  80248c:	c3                   	ret    
  80248d:	8d 76 00             	lea    0x0(%esi),%esi
  802490:	29 f9                	sub    %edi,%ecx
  802492:	19 d6                	sbb    %edx,%esi
  802494:	89 74 24 04          	mov    %esi,0x4(%esp)
  802498:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80249c:	e9 18 ff ff ff       	jmp    8023b9 <__umoddi3+0x69>
