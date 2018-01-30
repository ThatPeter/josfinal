
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
#include <inc/lib.h>

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
  800048:	e8 a9 11 00 00       	call   8011f6 <mutex_lock>
		cprintf("global++: %d\n", global++);
  80004d:	a1 04 40 80 00       	mov    0x804004,%eax
  800052:	8d 50 01             	lea    0x1(%eax),%edx
  800055:	89 15 04 40 80 00    	mov    %edx,0x804004
  80005b:	83 c4 08             	add    $0x8,%esp
  80005e:	50                   	push   %eax
  80005f:	68 40 25 80 00       	push   $0x802540
  800064:	e8 aa 01 00 00       	call   800213 <cprintf>

	mutex_unlock(mtx);
  800069:	83 c4 04             	add    $0x4,%esp
  80006c:	ff 35 08 40 80 00    	pushl  0x804008
  800072:	e8 0c 12 00 00       	call   801283 <mutex_unlock>
struct Mutex* mtx;
int global;
void func()
{	
	int i;
	for(i = 0; i < 10; i++)
  800077:	83 c4 10             	add    $0x10,%esp
  80007a:	83 eb 01             	sub    $0x1,%ebx
  80007d:	75 c0                	jne    80003f <func+0xc>
	mutex_lock(mtx);
		cprintf("global++: %d\n", global++);

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
		cprintf("BYE\n");
  800090:	83 ec 0c             	sub    $0xc,%esp
  800093:	68 4e 25 80 00       	push   $0x80254e
  800098:	e8 76 01 00 00       	call   800213 <cprintf>


void test()
{
	int i;
	for(i = 0; i < 10; i++)
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	83 eb 01             	sub    $0x1,%ebx
  8000a3:	75 eb                	jne    800090 <test+0xc>
	{
		cprintf("BYE\n");
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
  8000c2:	e8 10 12 00 00       	call   8012d7 <mutex_init>
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
  8000e6:	e8 08 10 00 00       	call   8010f3 <thread_join>
	thread_join(id2);
  8000eb:	89 1c 24             	mov    %ebx,(%esp)
  8000ee:	e8 00 10 00 00       	call   8010f3 <thread_join>
	/*envid_t id2 = thread_create(test);
	thread_create(func);
	thread_create(test);
	
	cprintf("\nTHREAD CREATE RETURNED: %d\n\n", id2);*/
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
  800112:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  800118:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011d:	a3 0c 40 80 00       	mov    %eax,0x80400c
			thisenv = &envs[i];
		}
	}*/

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

void 
thread_main(/*uintptr_t eip*/)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

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
  80016c:	e8 c5 13 00 00       	call   801536 <close_all>
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
  800276:	e8 25 20 00 00       	call   8022a0 <__udivdi3>
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
  8002b9:	e8 12 21 00 00       	call   8023d0 <__umoddi3>
  8002be:	83 c4 14             	add    $0x14,%esp
  8002c1:	0f be 80 5d 25 80 00 	movsbl 0x80255d(%eax),%eax
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
  8003bd:	ff 24 85 a0 26 80 00 	jmp    *0x8026a0(,%eax,4)
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
  800481:	8b 14 85 00 28 80 00 	mov    0x802800(,%eax,4),%edx
  800488:	85 d2                	test   %edx,%edx
  80048a:	75 18                	jne    8004a4 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80048c:	50                   	push   %eax
  80048d:	68 75 25 80 00       	push   $0x802575
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
  8004a5:	68 8d 2a 80 00       	push   $0x802a8d
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
  8004c9:	b8 6e 25 80 00       	mov    $0x80256e,%eax
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
  800b44:	68 5f 28 80 00       	push   $0x80285f
  800b49:	6a 23                	push   $0x23
  800b4b:	68 7c 28 80 00       	push   $0x80287c
  800b50:	e8 12 15 00 00       	call   802067 <_panic>

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
  800bc5:	68 5f 28 80 00       	push   $0x80285f
  800bca:	6a 23                	push   $0x23
  800bcc:	68 7c 28 80 00       	push   $0x80287c
  800bd1:	e8 91 14 00 00       	call   802067 <_panic>

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
  800c07:	68 5f 28 80 00       	push   $0x80285f
  800c0c:	6a 23                	push   $0x23
  800c0e:	68 7c 28 80 00       	push   $0x80287c
  800c13:	e8 4f 14 00 00       	call   802067 <_panic>

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
  800c49:	68 5f 28 80 00       	push   $0x80285f
  800c4e:	6a 23                	push   $0x23
  800c50:	68 7c 28 80 00       	push   $0x80287c
  800c55:	e8 0d 14 00 00       	call   802067 <_panic>

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
  800c8b:	68 5f 28 80 00       	push   $0x80285f
  800c90:	6a 23                	push   $0x23
  800c92:	68 7c 28 80 00       	push   $0x80287c
  800c97:	e8 cb 13 00 00       	call   802067 <_panic>

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
  800ccd:	68 5f 28 80 00       	push   $0x80285f
  800cd2:	6a 23                	push   $0x23
  800cd4:	68 7c 28 80 00       	push   $0x80287c
  800cd9:	e8 89 13 00 00       	call   802067 <_panic>
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
  800d0f:	68 5f 28 80 00       	push   $0x80285f
  800d14:	6a 23                	push   $0x23
  800d16:	68 7c 28 80 00       	push   $0x80287c
  800d1b:	e8 47 13 00 00       	call   802067 <_panic>

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
  800d73:	68 5f 28 80 00       	push   $0x80285f
  800d78:	6a 23                	push   $0x23
  800d7a:	68 7c 28 80 00       	push   $0x80287c
  800d7f:	e8 e3 12 00 00       	call   802067 <_panic>

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
  800e12:	68 8a 28 80 00       	push   $0x80288a
  800e17:	6a 1f                	push   $0x1f
  800e19:	68 9a 28 80 00       	push   $0x80289a
  800e1e:	e8 44 12 00 00       	call   802067 <_panic>
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
  800e3c:	68 a5 28 80 00       	push   $0x8028a5
  800e41:	6a 2d                	push   $0x2d
  800e43:	68 9a 28 80 00       	push   $0x80289a
  800e48:	e8 1a 12 00 00       	call   802067 <_panic>
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
  800e84:	68 a5 28 80 00       	push   $0x8028a5
  800e89:	6a 34                	push   $0x34
  800e8b:	68 9a 28 80 00       	push   $0x80289a
  800e90:	e8 d2 11 00 00       	call   802067 <_panic>
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
  800eac:	68 a5 28 80 00       	push   $0x8028a5
  800eb1:	6a 38                	push   $0x38
  800eb3:	68 9a 28 80 00       	push   $0x80289a
  800eb8:	e8 aa 11 00 00       	call   802067 <_panic>
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
  800ed0:	e8 d8 11 00 00       	call   8020ad <set_pgfault_handler>
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
  800ee9:	68 be 28 80 00       	push   $0x8028be
  800eee:	68 85 00 00 00       	push   $0x85
  800ef3:	68 9a 28 80 00       	push   $0x80289a
  800ef8:	e8 6a 11 00 00       	call   802067 <_panic>
  800efd:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800eff:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f03:	75 24                	jne    800f29 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f05:	e8 53 fc ff ff       	call   800b5d <sys_getenvid>
  800f0a:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f0f:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  800fa5:	68 cc 28 80 00       	push   $0x8028cc
  800faa:	6a 55                	push   $0x55
  800fac:	68 9a 28 80 00       	push   $0x80289a
  800fb1:	e8 b1 10 00 00       	call   802067 <_panic>
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
  800fea:	68 cc 28 80 00       	push   $0x8028cc
  800fef:	6a 5c                	push   $0x5c
  800ff1:	68 9a 28 80 00       	push   $0x80289a
  800ff6:	e8 6c 10 00 00       	call   802067 <_panic>
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
  801018:	68 cc 28 80 00       	push   $0x8028cc
  80101d:	6a 60                	push   $0x60
  80101f:	68 9a 28 80 00       	push   $0x80289a
  801024:	e8 3e 10 00 00       	call   802067 <_panic>
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
  801042:	68 cc 28 80 00       	push   $0x8028cc
  801047:	6a 65                	push   $0x65
  801049:	68 9a 28 80 00       	push   $0x80289a
  80104e:	e8 14 10 00 00       	call   802067 <_panic>
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
  80106a:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
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
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80109f:	55                   	push   %ebp
  8010a0:	89 e5                	mov    %esp,%ebp
  8010a2:	56                   	push   %esi
  8010a3:	53                   	push   %ebx
  8010a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  8010a7:	89 1d 10 40 80 00    	mov    %ebx,0x804010
	cprintf("in fork.c thread create. func: %x\n", func);
  8010ad:	83 ec 08             	sub    $0x8,%esp
  8010b0:	53                   	push   %ebx
  8010b1:	68 5c 29 80 00       	push   $0x80295c
  8010b6:	e8 58 f1 ff ff       	call   800213 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8010bb:	c7 04 24 46 01 80 00 	movl   $0x800146,(%esp)
  8010c2:	e8 c5 fc ff ff       	call   800d8c <sys_thread_create>
  8010c7:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8010c9:	83 c4 08             	add    $0x8,%esp
  8010cc:	53                   	push   %ebx
  8010cd:	68 5c 29 80 00       	push   $0x80295c
  8010d2:	e8 3c f1 ff ff       	call   800213 <cprintf>
	return id;
}
  8010d7:	89 f0                	mov    %esi,%eax
  8010d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010dc:	5b                   	pop    %ebx
  8010dd:	5e                   	pop    %esi
  8010de:	5d                   	pop    %ebp
  8010df:	c3                   	ret    

008010e0 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  8010e6:	ff 75 08             	pushl  0x8(%ebp)
  8010e9:	e8 be fc ff ff       	call   800dac <sys_thread_free>
}
  8010ee:	83 c4 10             	add    $0x10,%esp
  8010f1:	c9                   	leave  
  8010f2:	c3                   	ret    

008010f3 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8010f3:	55                   	push   %ebp
  8010f4:	89 e5                	mov    %esp,%ebp
  8010f6:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  8010f9:	ff 75 08             	pushl  0x8(%ebp)
  8010fc:	e8 cb fc ff ff       	call   800dcc <sys_thread_join>
}
  801101:	83 c4 10             	add    $0x10,%esp
  801104:	c9                   	leave  
  801105:	c3                   	ret    

00801106 <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  801106:	55                   	push   %ebp
  801107:	89 e5                	mov    %esp,%ebp
  801109:	56                   	push   %esi
  80110a:	53                   	push   %ebx
  80110b:	8b 75 08             	mov    0x8(%ebp),%esi
  80110e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  801111:	83 ec 04             	sub    $0x4,%esp
  801114:	6a 07                	push   $0x7
  801116:	6a 00                	push   $0x0
  801118:	56                   	push   %esi
  801119:	e8 7d fa ff ff       	call   800b9b <sys_page_alloc>
	if (r < 0) {
  80111e:	83 c4 10             	add    $0x10,%esp
  801121:	85 c0                	test   %eax,%eax
  801123:	79 15                	jns    80113a <queue_append+0x34>
		panic("%e\n", r);
  801125:	50                   	push   %eax
  801126:	68 58 29 80 00       	push   $0x802958
  80112b:	68 c4 00 00 00       	push   $0xc4
  801130:	68 9a 28 80 00       	push   $0x80289a
  801135:	e8 2d 0f 00 00       	call   802067 <_panic>
	}	
	wt->envid = envid;
  80113a:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  801140:	83 ec 04             	sub    $0x4,%esp
  801143:	ff 33                	pushl  (%ebx)
  801145:	56                   	push   %esi
  801146:	68 80 29 80 00       	push   $0x802980
  80114b:	e8 c3 f0 ff ff       	call   800213 <cprintf>
	if (queue->first == NULL) {
  801150:	83 c4 10             	add    $0x10,%esp
  801153:	83 3b 00             	cmpl   $0x0,(%ebx)
  801156:	75 29                	jne    801181 <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  801158:	83 ec 0c             	sub    $0xc,%esp
  80115b:	68 e2 28 80 00       	push   $0x8028e2
  801160:	e8 ae f0 ff ff       	call   800213 <cprintf>
		queue->first = wt;
  801165:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  80116b:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  801172:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801179:	00 00 00 
  80117c:	83 c4 10             	add    $0x10,%esp
  80117f:	eb 2b                	jmp    8011ac <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  801181:	83 ec 0c             	sub    $0xc,%esp
  801184:	68 fc 28 80 00       	push   $0x8028fc
  801189:	e8 85 f0 ff ff       	call   800213 <cprintf>
		queue->last->next = wt;
  80118e:	8b 43 04             	mov    0x4(%ebx),%eax
  801191:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  801198:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80119f:	00 00 00 
		queue->last = wt;
  8011a2:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  8011a9:	83 c4 10             	add    $0x10,%esp
	}
}
  8011ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011af:	5b                   	pop    %ebx
  8011b0:	5e                   	pop    %esi
  8011b1:	5d                   	pop    %ebp
  8011b2:	c3                   	ret    

008011b3 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  8011b3:	55                   	push   %ebp
  8011b4:	89 e5                	mov    %esp,%ebp
  8011b6:	53                   	push   %ebx
  8011b7:	83 ec 04             	sub    $0x4,%esp
  8011ba:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  8011bd:	8b 02                	mov    (%edx),%eax
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	75 17                	jne    8011da <queue_pop+0x27>
		panic("queue empty!\n");
  8011c3:	83 ec 04             	sub    $0x4,%esp
  8011c6:	68 1a 29 80 00       	push   $0x80291a
  8011cb:	68 d8 00 00 00       	push   $0xd8
  8011d0:	68 9a 28 80 00       	push   $0x80289a
  8011d5:	e8 8d 0e 00 00       	call   802067 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  8011da:	8b 48 04             	mov    0x4(%eax),%ecx
  8011dd:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  8011df:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  8011e1:	83 ec 08             	sub    $0x8,%esp
  8011e4:	53                   	push   %ebx
  8011e5:	68 28 29 80 00       	push   $0x802928
  8011ea:	e8 24 f0 ff ff       	call   800213 <cprintf>
	return envid;
}
  8011ef:	89 d8                	mov    %ebx,%eax
  8011f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f4:	c9                   	leave  
  8011f5:	c3                   	ret    

008011f6 <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  8011f6:	55                   	push   %ebp
  8011f7:	89 e5                	mov    %esp,%ebp
  8011f9:	53                   	push   %ebx
  8011fa:	83 ec 04             	sub    $0x4,%esp
  8011fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801200:	b8 01 00 00 00       	mov    $0x1,%eax
  801205:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801208:	85 c0                	test   %eax,%eax
  80120a:	74 5a                	je     801266 <mutex_lock+0x70>
  80120c:	8b 43 04             	mov    0x4(%ebx),%eax
  80120f:	83 38 00             	cmpl   $0x0,(%eax)
  801212:	75 52                	jne    801266 <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  801214:	83 ec 0c             	sub    $0xc,%esp
  801217:	68 a8 29 80 00       	push   $0x8029a8
  80121c:	e8 f2 ef ff ff       	call   800213 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  801221:	8b 5b 04             	mov    0x4(%ebx),%ebx
  801224:	e8 34 f9 ff ff       	call   800b5d <sys_getenvid>
  801229:	83 c4 08             	add    $0x8,%esp
  80122c:	53                   	push   %ebx
  80122d:	50                   	push   %eax
  80122e:	e8 d3 fe ff ff       	call   801106 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  801233:	e8 25 f9 ff ff       	call   800b5d <sys_getenvid>
  801238:	83 c4 08             	add    $0x8,%esp
  80123b:	6a 04                	push   $0x4
  80123d:	50                   	push   %eax
  80123e:	e8 1f fa ff ff       	call   800c62 <sys_env_set_status>
		if (r < 0) {
  801243:	83 c4 10             	add    $0x10,%esp
  801246:	85 c0                	test   %eax,%eax
  801248:	79 15                	jns    80125f <mutex_lock+0x69>
			panic("%e\n", r);
  80124a:	50                   	push   %eax
  80124b:	68 58 29 80 00       	push   $0x802958
  801250:	68 eb 00 00 00       	push   $0xeb
  801255:	68 9a 28 80 00       	push   $0x80289a
  80125a:	e8 08 0e 00 00       	call   802067 <_panic>
		}
		sys_yield();
  80125f:	e8 18 f9 ff ff       	call   800b7c <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801264:	eb 18                	jmp    80127e <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  801266:	83 ec 0c             	sub    $0xc,%esp
  801269:	68 c8 29 80 00       	push   $0x8029c8
  80126e:	e8 a0 ef ff ff       	call   800213 <cprintf>
	mtx->owner = sys_getenvid();}
  801273:	e8 e5 f8 ff ff       	call   800b5d <sys_getenvid>
  801278:	89 43 08             	mov    %eax,0x8(%ebx)
  80127b:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  80127e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801281:	c9                   	leave  
  801282:	c3                   	ret    

00801283 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  801283:	55                   	push   %ebp
  801284:	89 e5                	mov    %esp,%ebp
  801286:	53                   	push   %ebx
  801287:	83 ec 04             	sub    $0x4,%esp
  80128a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80128d:	b8 00 00 00 00       	mov    $0x0,%eax
  801292:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  801295:	8b 43 04             	mov    0x4(%ebx),%eax
  801298:	83 38 00             	cmpl   $0x0,(%eax)
  80129b:	74 33                	je     8012d0 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  80129d:	83 ec 0c             	sub    $0xc,%esp
  8012a0:	50                   	push   %eax
  8012a1:	e8 0d ff ff ff       	call   8011b3 <queue_pop>
  8012a6:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8012a9:	83 c4 08             	add    $0x8,%esp
  8012ac:	6a 02                	push   $0x2
  8012ae:	50                   	push   %eax
  8012af:	e8 ae f9 ff ff       	call   800c62 <sys_env_set_status>
		if (r < 0) {
  8012b4:	83 c4 10             	add    $0x10,%esp
  8012b7:	85 c0                	test   %eax,%eax
  8012b9:	79 15                	jns    8012d0 <mutex_unlock+0x4d>
			panic("%e\n", r);
  8012bb:	50                   	push   %eax
  8012bc:	68 58 29 80 00       	push   $0x802958
  8012c1:	68 00 01 00 00       	push   $0x100
  8012c6:	68 9a 28 80 00       	push   $0x80289a
  8012cb:	e8 97 0d 00 00       	call   802067 <_panic>
		}
	}

	asm volatile("pause");
  8012d0:	f3 90                	pause  
	//sys_yield();
}
  8012d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d5:	c9                   	leave  
  8012d6:	c3                   	ret    

008012d7 <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  8012d7:	55                   	push   %ebp
  8012d8:	89 e5                	mov    %esp,%ebp
  8012da:	53                   	push   %ebx
  8012db:	83 ec 04             	sub    $0x4,%esp
  8012de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8012e1:	e8 77 f8 ff ff       	call   800b5d <sys_getenvid>
  8012e6:	83 ec 04             	sub    $0x4,%esp
  8012e9:	6a 07                	push   $0x7
  8012eb:	53                   	push   %ebx
  8012ec:	50                   	push   %eax
  8012ed:	e8 a9 f8 ff ff       	call   800b9b <sys_page_alloc>
  8012f2:	83 c4 10             	add    $0x10,%esp
  8012f5:	85 c0                	test   %eax,%eax
  8012f7:	79 15                	jns    80130e <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  8012f9:	50                   	push   %eax
  8012fa:	68 43 29 80 00       	push   $0x802943
  8012ff:	68 0d 01 00 00       	push   $0x10d
  801304:	68 9a 28 80 00       	push   $0x80289a
  801309:	e8 59 0d 00 00       	call   802067 <_panic>
	}	
	mtx->locked = 0;
  80130e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  801314:	8b 43 04             	mov    0x4(%ebx),%eax
  801317:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  80131d:	8b 43 04             	mov    0x4(%ebx),%eax
  801320:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  801327:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  80132e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801331:	c9                   	leave  
  801332:	c3                   	ret    

00801333 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  801333:	55                   	push   %ebp
  801334:	89 e5                	mov    %esp,%ebp
  801336:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  801339:	e8 1f f8 ff ff       	call   800b5d <sys_getenvid>
  80133e:	83 ec 08             	sub    $0x8,%esp
  801341:	ff 75 08             	pushl  0x8(%ebp)
  801344:	50                   	push   %eax
  801345:	e8 d6 f8 ff ff       	call   800c20 <sys_page_unmap>
	if (r < 0) {
  80134a:	83 c4 10             	add    $0x10,%esp
  80134d:	85 c0                	test   %eax,%eax
  80134f:	79 15                	jns    801366 <mutex_destroy+0x33>
		panic("%e\n", r);
  801351:	50                   	push   %eax
  801352:	68 58 29 80 00       	push   $0x802958
  801357:	68 1a 01 00 00       	push   $0x11a
  80135c:	68 9a 28 80 00       	push   $0x80289a
  801361:	e8 01 0d 00 00       	call   802067 <_panic>
	}
}
  801366:	c9                   	leave  
  801367:	c3                   	ret    

00801368 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801368:	55                   	push   %ebp
  801369:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80136b:	8b 45 08             	mov    0x8(%ebp),%eax
  80136e:	05 00 00 00 30       	add    $0x30000000,%eax
  801373:	c1 e8 0c             	shr    $0xc,%eax
}
  801376:	5d                   	pop    %ebp
  801377:	c3                   	ret    

00801378 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801378:	55                   	push   %ebp
  801379:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80137b:	8b 45 08             	mov    0x8(%ebp),%eax
  80137e:	05 00 00 00 30       	add    $0x30000000,%eax
  801383:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801388:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80138d:	5d                   	pop    %ebp
  80138e:	c3                   	ret    

0080138f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
  801392:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801395:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80139a:	89 c2                	mov    %eax,%edx
  80139c:	c1 ea 16             	shr    $0x16,%edx
  80139f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013a6:	f6 c2 01             	test   $0x1,%dl
  8013a9:	74 11                	je     8013bc <fd_alloc+0x2d>
  8013ab:	89 c2                	mov    %eax,%edx
  8013ad:	c1 ea 0c             	shr    $0xc,%edx
  8013b0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013b7:	f6 c2 01             	test   $0x1,%dl
  8013ba:	75 09                	jne    8013c5 <fd_alloc+0x36>
			*fd_store = fd;
  8013bc:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013be:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c3:	eb 17                	jmp    8013dc <fd_alloc+0x4d>
  8013c5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013ca:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013cf:	75 c9                	jne    80139a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013d1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8013d7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013dc:	5d                   	pop    %ebp
  8013dd:	c3                   	ret    

008013de <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013e4:	83 f8 1f             	cmp    $0x1f,%eax
  8013e7:	77 36                	ja     80141f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013e9:	c1 e0 0c             	shl    $0xc,%eax
  8013ec:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013f1:	89 c2                	mov    %eax,%edx
  8013f3:	c1 ea 16             	shr    $0x16,%edx
  8013f6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013fd:	f6 c2 01             	test   $0x1,%dl
  801400:	74 24                	je     801426 <fd_lookup+0x48>
  801402:	89 c2                	mov    %eax,%edx
  801404:	c1 ea 0c             	shr    $0xc,%edx
  801407:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80140e:	f6 c2 01             	test   $0x1,%dl
  801411:	74 1a                	je     80142d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801413:	8b 55 0c             	mov    0xc(%ebp),%edx
  801416:	89 02                	mov    %eax,(%edx)
	return 0;
  801418:	b8 00 00 00 00       	mov    $0x0,%eax
  80141d:	eb 13                	jmp    801432 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80141f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801424:	eb 0c                	jmp    801432 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801426:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80142b:	eb 05                	jmp    801432 <fd_lookup+0x54>
  80142d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801432:	5d                   	pop    %ebp
  801433:	c3                   	ret    

00801434 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	83 ec 08             	sub    $0x8,%esp
  80143a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80143d:	ba 64 2a 80 00       	mov    $0x802a64,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801442:	eb 13                	jmp    801457 <dev_lookup+0x23>
  801444:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801447:	39 08                	cmp    %ecx,(%eax)
  801449:	75 0c                	jne    801457 <dev_lookup+0x23>
			*dev = devtab[i];
  80144b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80144e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801450:	b8 00 00 00 00       	mov    $0x0,%eax
  801455:	eb 31                	jmp    801488 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801457:	8b 02                	mov    (%edx),%eax
  801459:	85 c0                	test   %eax,%eax
  80145b:	75 e7                	jne    801444 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80145d:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801462:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801468:	83 ec 04             	sub    $0x4,%esp
  80146b:	51                   	push   %ecx
  80146c:	50                   	push   %eax
  80146d:	68 e8 29 80 00       	push   $0x8029e8
  801472:	e8 9c ed ff ff       	call   800213 <cprintf>
	*dev = 0;
  801477:	8b 45 0c             	mov    0xc(%ebp),%eax
  80147a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801480:	83 c4 10             	add    $0x10,%esp
  801483:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801488:	c9                   	leave  
  801489:	c3                   	ret    

0080148a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80148a:	55                   	push   %ebp
  80148b:	89 e5                	mov    %esp,%ebp
  80148d:	56                   	push   %esi
  80148e:	53                   	push   %ebx
  80148f:	83 ec 10             	sub    $0x10,%esp
  801492:	8b 75 08             	mov    0x8(%ebp),%esi
  801495:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801498:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149b:	50                   	push   %eax
  80149c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014a2:	c1 e8 0c             	shr    $0xc,%eax
  8014a5:	50                   	push   %eax
  8014a6:	e8 33 ff ff ff       	call   8013de <fd_lookup>
  8014ab:	83 c4 08             	add    $0x8,%esp
  8014ae:	85 c0                	test   %eax,%eax
  8014b0:	78 05                	js     8014b7 <fd_close+0x2d>
	    || fd != fd2)
  8014b2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014b5:	74 0c                	je     8014c3 <fd_close+0x39>
		return (must_exist ? r : 0);
  8014b7:	84 db                	test   %bl,%bl
  8014b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014be:	0f 44 c2             	cmove  %edx,%eax
  8014c1:	eb 41                	jmp    801504 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014c3:	83 ec 08             	sub    $0x8,%esp
  8014c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c9:	50                   	push   %eax
  8014ca:	ff 36                	pushl  (%esi)
  8014cc:	e8 63 ff ff ff       	call   801434 <dev_lookup>
  8014d1:	89 c3                	mov    %eax,%ebx
  8014d3:	83 c4 10             	add    $0x10,%esp
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	78 1a                	js     8014f4 <fd_close+0x6a>
		if (dev->dev_close)
  8014da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014dd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8014e0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8014e5:	85 c0                	test   %eax,%eax
  8014e7:	74 0b                	je     8014f4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014e9:	83 ec 0c             	sub    $0xc,%esp
  8014ec:	56                   	push   %esi
  8014ed:	ff d0                	call   *%eax
  8014ef:	89 c3                	mov    %eax,%ebx
  8014f1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014f4:	83 ec 08             	sub    $0x8,%esp
  8014f7:	56                   	push   %esi
  8014f8:	6a 00                	push   $0x0
  8014fa:	e8 21 f7 ff ff       	call   800c20 <sys_page_unmap>
	return r;
  8014ff:	83 c4 10             	add    $0x10,%esp
  801502:	89 d8                	mov    %ebx,%eax
}
  801504:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801507:	5b                   	pop    %ebx
  801508:	5e                   	pop    %esi
  801509:	5d                   	pop    %ebp
  80150a:	c3                   	ret    

0080150b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80150b:	55                   	push   %ebp
  80150c:	89 e5                	mov    %esp,%ebp
  80150e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801511:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801514:	50                   	push   %eax
  801515:	ff 75 08             	pushl  0x8(%ebp)
  801518:	e8 c1 fe ff ff       	call   8013de <fd_lookup>
  80151d:	83 c4 08             	add    $0x8,%esp
  801520:	85 c0                	test   %eax,%eax
  801522:	78 10                	js     801534 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801524:	83 ec 08             	sub    $0x8,%esp
  801527:	6a 01                	push   $0x1
  801529:	ff 75 f4             	pushl  -0xc(%ebp)
  80152c:	e8 59 ff ff ff       	call   80148a <fd_close>
  801531:	83 c4 10             	add    $0x10,%esp
}
  801534:	c9                   	leave  
  801535:	c3                   	ret    

00801536 <close_all>:

void
close_all(void)
{
  801536:	55                   	push   %ebp
  801537:	89 e5                	mov    %esp,%ebp
  801539:	53                   	push   %ebx
  80153a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80153d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801542:	83 ec 0c             	sub    $0xc,%esp
  801545:	53                   	push   %ebx
  801546:	e8 c0 ff ff ff       	call   80150b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80154b:	83 c3 01             	add    $0x1,%ebx
  80154e:	83 c4 10             	add    $0x10,%esp
  801551:	83 fb 20             	cmp    $0x20,%ebx
  801554:	75 ec                	jne    801542 <close_all+0xc>
		close(i);
}
  801556:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801559:	c9                   	leave  
  80155a:	c3                   	ret    

0080155b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	57                   	push   %edi
  80155f:	56                   	push   %esi
  801560:	53                   	push   %ebx
  801561:	83 ec 2c             	sub    $0x2c,%esp
  801564:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801567:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80156a:	50                   	push   %eax
  80156b:	ff 75 08             	pushl  0x8(%ebp)
  80156e:	e8 6b fe ff ff       	call   8013de <fd_lookup>
  801573:	83 c4 08             	add    $0x8,%esp
  801576:	85 c0                	test   %eax,%eax
  801578:	0f 88 c1 00 00 00    	js     80163f <dup+0xe4>
		return r;
	close(newfdnum);
  80157e:	83 ec 0c             	sub    $0xc,%esp
  801581:	56                   	push   %esi
  801582:	e8 84 ff ff ff       	call   80150b <close>

	newfd = INDEX2FD(newfdnum);
  801587:	89 f3                	mov    %esi,%ebx
  801589:	c1 e3 0c             	shl    $0xc,%ebx
  80158c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801592:	83 c4 04             	add    $0x4,%esp
  801595:	ff 75 e4             	pushl  -0x1c(%ebp)
  801598:	e8 db fd ff ff       	call   801378 <fd2data>
  80159d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80159f:	89 1c 24             	mov    %ebx,(%esp)
  8015a2:	e8 d1 fd ff ff       	call   801378 <fd2data>
  8015a7:	83 c4 10             	add    $0x10,%esp
  8015aa:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015ad:	89 f8                	mov    %edi,%eax
  8015af:	c1 e8 16             	shr    $0x16,%eax
  8015b2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015b9:	a8 01                	test   $0x1,%al
  8015bb:	74 37                	je     8015f4 <dup+0x99>
  8015bd:	89 f8                	mov    %edi,%eax
  8015bf:	c1 e8 0c             	shr    $0xc,%eax
  8015c2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015c9:	f6 c2 01             	test   $0x1,%dl
  8015cc:	74 26                	je     8015f4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015ce:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015d5:	83 ec 0c             	sub    $0xc,%esp
  8015d8:	25 07 0e 00 00       	and    $0xe07,%eax
  8015dd:	50                   	push   %eax
  8015de:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015e1:	6a 00                	push   $0x0
  8015e3:	57                   	push   %edi
  8015e4:	6a 00                	push   $0x0
  8015e6:	e8 f3 f5 ff ff       	call   800bde <sys_page_map>
  8015eb:	89 c7                	mov    %eax,%edi
  8015ed:	83 c4 20             	add    $0x20,%esp
  8015f0:	85 c0                	test   %eax,%eax
  8015f2:	78 2e                	js     801622 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015f7:	89 d0                	mov    %edx,%eax
  8015f9:	c1 e8 0c             	shr    $0xc,%eax
  8015fc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801603:	83 ec 0c             	sub    $0xc,%esp
  801606:	25 07 0e 00 00       	and    $0xe07,%eax
  80160b:	50                   	push   %eax
  80160c:	53                   	push   %ebx
  80160d:	6a 00                	push   $0x0
  80160f:	52                   	push   %edx
  801610:	6a 00                	push   $0x0
  801612:	e8 c7 f5 ff ff       	call   800bde <sys_page_map>
  801617:	89 c7                	mov    %eax,%edi
  801619:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80161c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80161e:	85 ff                	test   %edi,%edi
  801620:	79 1d                	jns    80163f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801622:	83 ec 08             	sub    $0x8,%esp
  801625:	53                   	push   %ebx
  801626:	6a 00                	push   $0x0
  801628:	e8 f3 f5 ff ff       	call   800c20 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80162d:	83 c4 08             	add    $0x8,%esp
  801630:	ff 75 d4             	pushl  -0x2c(%ebp)
  801633:	6a 00                	push   $0x0
  801635:	e8 e6 f5 ff ff       	call   800c20 <sys_page_unmap>
	return r;
  80163a:	83 c4 10             	add    $0x10,%esp
  80163d:	89 f8                	mov    %edi,%eax
}
  80163f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801642:	5b                   	pop    %ebx
  801643:	5e                   	pop    %esi
  801644:	5f                   	pop    %edi
  801645:	5d                   	pop    %ebp
  801646:	c3                   	ret    

00801647 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	53                   	push   %ebx
  80164b:	83 ec 14             	sub    $0x14,%esp
  80164e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801651:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801654:	50                   	push   %eax
  801655:	53                   	push   %ebx
  801656:	e8 83 fd ff ff       	call   8013de <fd_lookup>
  80165b:	83 c4 08             	add    $0x8,%esp
  80165e:	89 c2                	mov    %eax,%edx
  801660:	85 c0                	test   %eax,%eax
  801662:	78 70                	js     8016d4 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801664:	83 ec 08             	sub    $0x8,%esp
  801667:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166a:	50                   	push   %eax
  80166b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166e:	ff 30                	pushl  (%eax)
  801670:	e8 bf fd ff ff       	call   801434 <dev_lookup>
  801675:	83 c4 10             	add    $0x10,%esp
  801678:	85 c0                	test   %eax,%eax
  80167a:	78 4f                	js     8016cb <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80167c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80167f:	8b 42 08             	mov    0x8(%edx),%eax
  801682:	83 e0 03             	and    $0x3,%eax
  801685:	83 f8 01             	cmp    $0x1,%eax
  801688:	75 24                	jne    8016ae <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80168a:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80168f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801695:	83 ec 04             	sub    $0x4,%esp
  801698:	53                   	push   %ebx
  801699:	50                   	push   %eax
  80169a:	68 29 2a 80 00       	push   $0x802a29
  80169f:	e8 6f eb ff ff       	call   800213 <cprintf>
		return -E_INVAL;
  8016a4:	83 c4 10             	add    $0x10,%esp
  8016a7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016ac:	eb 26                	jmp    8016d4 <read+0x8d>
	}
	if (!dev->dev_read)
  8016ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b1:	8b 40 08             	mov    0x8(%eax),%eax
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	74 17                	je     8016cf <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8016b8:	83 ec 04             	sub    $0x4,%esp
  8016bb:	ff 75 10             	pushl  0x10(%ebp)
  8016be:	ff 75 0c             	pushl  0xc(%ebp)
  8016c1:	52                   	push   %edx
  8016c2:	ff d0                	call   *%eax
  8016c4:	89 c2                	mov    %eax,%edx
  8016c6:	83 c4 10             	add    $0x10,%esp
  8016c9:	eb 09                	jmp    8016d4 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016cb:	89 c2                	mov    %eax,%edx
  8016cd:	eb 05                	jmp    8016d4 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016cf:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8016d4:	89 d0                	mov    %edx,%eax
  8016d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d9:	c9                   	leave  
  8016da:	c3                   	ret    

008016db <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016db:	55                   	push   %ebp
  8016dc:	89 e5                	mov    %esp,%ebp
  8016de:	57                   	push   %edi
  8016df:	56                   	push   %esi
  8016e0:	53                   	push   %ebx
  8016e1:	83 ec 0c             	sub    $0xc,%esp
  8016e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016e7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016ef:	eb 21                	jmp    801712 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016f1:	83 ec 04             	sub    $0x4,%esp
  8016f4:	89 f0                	mov    %esi,%eax
  8016f6:	29 d8                	sub    %ebx,%eax
  8016f8:	50                   	push   %eax
  8016f9:	89 d8                	mov    %ebx,%eax
  8016fb:	03 45 0c             	add    0xc(%ebp),%eax
  8016fe:	50                   	push   %eax
  8016ff:	57                   	push   %edi
  801700:	e8 42 ff ff ff       	call   801647 <read>
		if (m < 0)
  801705:	83 c4 10             	add    $0x10,%esp
  801708:	85 c0                	test   %eax,%eax
  80170a:	78 10                	js     80171c <readn+0x41>
			return m;
		if (m == 0)
  80170c:	85 c0                	test   %eax,%eax
  80170e:	74 0a                	je     80171a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801710:	01 c3                	add    %eax,%ebx
  801712:	39 f3                	cmp    %esi,%ebx
  801714:	72 db                	jb     8016f1 <readn+0x16>
  801716:	89 d8                	mov    %ebx,%eax
  801718:	eb 02                	jmp    80171c <readn+0x41>
  80171a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80171c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80171f:	5b                   	pop    %ebx
  801720:	5e                   	pop    %esi
  801721:	5f                   	pop    %edi
  801722:	5d                   	pop    %ebp
  801723:	c3                   	ret    

00801724 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801724:	55                   	push   %ebp
  801725:	89 e5                	mov    %esp,%ebp
  801727:	53                   	push   %ebx
  801728:	83 ec 14             	sub    $0x14,%esp
  80172b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80172e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801731:	50                   	push   %eax
  801732:	53                   	push   %ebx
  801733:	e8 a6 fc ff ff       	call   8013de <fd_lookup>
  801738:	83 c4 08             	add    $0x8,%esp
  80173b:	89 c2                	mov    %eax,%edx
  80173d:	85 c0                	test   %eax,%eax
  80173f:	78 6b                	js     8017ac <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801741:	83 ec 08             	sub    $0x8,%esp
  801744:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801747:	50                   	push   %eax
  801748:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80174b:	ff 30                	pushl  (%eax)
  80174d:	e8 e2 fc ff ff       	call   801434 <dev_lookup>
  801752:	83 c4 10             	add    $0x10,%esp
  801755:	85 c0                	test   %eax,%eax
  801757:	78 4a                	js     8017a3 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801759:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80175c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801760:	75 24                	jne    801786 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801762:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801767:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80176d:	83 ec 04             	sub    $0x4,%esp
  801770:	53                   	push   %ebx
  801771:	50                   	push   %eax
  801772:	68 45 2a 80 00       	push   $0x802a45
  801777:	e8 97 ea ff ff       	call   800213 <cprintf>
		return -E_INVAL;
  80177c:	83 c4 10             	add    $0x10,%esp
  80177f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801784:	eb 26                	jmp    8017ac <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801786:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801789:	8b 52 0c             	mov    0xc(%edx),%edx
  80178c:	85 d2                	test   %edx,%edx
  80178e:	74 17                	je     8017a7 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801790:	83 ec 04             	sub    $0x4,%esp
  801793:	ff 75 10             	pushl  0x10(%ebp)
  801796:	ff 75 0c             	pushl  0xc(%ebp)
  801799:	50                   	push   %eax
  80179a:	ff d2                	call   *%edx
  80179c:	89 c2                	mov    %eax,%edx
  80179e:	83 c4 10             	add    $0x10,%esp
  8017a1:	eb 09                	jmp    8017ac <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a3:	89 c2                	mov    %eax,%edx
  8017a5:	eb 05                	jmp    8017ac <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017a7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8017ac:	89 d0                	mov    %edx,%eax
  8017ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b1:	c9                   	leave  
  8017b2:	c3                   	ret    

008017b3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017b9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017bc:	50                   	push   %eax
  8017bd:	ff 75 08             	pushl  0x8(%ebp)
  8017c0:	e8 19 fc ff ff       	call   8013de <fd_lookup>
  8017c5:	83 c4 08             	add    $0x8,%esp
  8017c8:	85 c0                	test   %eax,%eax
  8017ca:	78 0e                	js     8017da <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017d2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017da:	c9                   	leave  
  8017db:	c3                   	ret    

008017dc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017dc:	55                   	push   %ebp
  8017dd:	89 e5                	mov    %esp,%ebp
  8017df:	53                   	push   %ebx
  8017e0:	83 ec 14             	sub    $0x14,%esp
  8017e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e9:	50                   	push   %eax
  8017ea:	53                   	push   %ebx
  8017eb:	e8 ee fb ff ff       	call   8013de <fd_lookup>
  8017f0:	83 c4 08             	add    $0x8,%esp
  8017f3:	89 c2                	mov    %eax,%edx
  8017f5:	85 c0                	test   %eax,%eax
  8017f7:	78 68                	js     801861 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f9:	83 ec 08             	sub    $0x8,%esp
  8017fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ff:	50                   	push   %eax
  801800:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801803:	ff 30                	pushl  (%eax)
  801805:	e8 2a fc ff ff       	call   801434 <dev_lookup>
  80180a:	83 c4 10             	add    $0x10,%esp
  80180d:	85 c0                	test   %eax,%eax
  80180f:	78 47                	js     801858 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801811:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801814:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801818:	75 24                	jne    80183e <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80181a:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80181f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801825:	83 ec 04             	sub    $0x4,%esp
  801828:	53                   	push   %ebx
  801829:	50                   	push   %eax
  80182a:	68 08 2a 80 00       	push   $0x802a08
  80182f:	e8 df e9 ff ff       	call   800213 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801834:	83 c4 10             	add    $0x10,%esp
  801837:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80183c:	eb 23                	jmp    801861 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  80183e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801841:	8b 52 18             	mov    0x18(%edx),%edx
  801844:	85 d2                	test   %edx,%edx
  801846:	74 14                	je     80185c <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801848:	83 ec 08             	sub    $0x8,%esp
  80184b:	ff 75 0c             	pushl  0xc(%ebp)
  80184e:	50                   	push   %eax
  80184f:	ff d2                	call   *%edx
  801851:	89 c2                	mov    %eax,%edx
  801853:	83 c4 10             	add    $0x10,%esp
  801856:	eb 09                	jmp    801861 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801858:	89 c2                	mov    %eax,%edx
  80185a:	eb 05                	jmp    801861 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80185c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801861:	89 d0                	mov    %edx,%eax
  801863:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801866:	c9                   	leave  
  801867:	c3                   	ret    

00801868 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	53                   	push   %ebx
  80186c:	83 ec 14             	sub    $0x14,%esp
  80186f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801872:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801875:	50                   	push   %eax
  801876:	ff 75 08             	pushl  0x8(%ebp)
  801879:	e8 60 fb ff ff       	call   8013de <fd_lookup>
  80187e:	83 c4 08             	add    $0x8,%esp
  801881:	89 c2                	mov    %eax,%edx
  801883:	85 c0                	test   %eax,%eax
  801885:	78 58                	js     8018df <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801887:	83 ec 08             	sub    $0x8,%esp
  80188a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80188d:	50                   	push   %eax
  80188e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801891:	ff 30                	pushl  (%eax)
  801893:	e8 9c fb ff ff       	call   801434 <dev_lookup>
  801898:	83 c4 10             	add    $0x10,%esp
  80189b:	85 c0                	test   %eax,%eax
  80189d:	78 37                	js     8018d6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80189f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018a6:	74 32                	je     8018da <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018a8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018ab:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018b2:	00 00 00 
	stat->st_isdir = 0;
  8018b5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018bc:	00 00 00 
	stat->st_dev = dev;
  8018bf:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018c5:	83 ec 08             	sub    $0x8,%esp
  8018c8:	53                   	push   %ebx
  8018c9:	ff 75 f0             	pushl  -0x10(%ebp)
  8018cc:	ff 50 14             	call   *0x14(%eax)
  8018cf:	89 c2                	mov    %eax,%edx
  8018d1:	83 c4 10             	add    $0x10,%esp
  8018d4:	eb 09                	jmp    8018df <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018d6:	89 c2                	mov    %eax,%edx
  8018d8:	eb 05                	jmp    8018df <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018da:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018df:	89 d0                	mov    %edx,%eax
  8018e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e4:	c9                   	leave  
  8018e5:	c3                   	ret    

008018e6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018e6:	55                   	push   %ebp
  8018e7:	89 e5                	mov    %esp,%ebp
  8018e9:	56                   	push   %esi
  8018ea:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018eb:	83 ec 08             	sub    $0x8,%esp
  8018ee:	6a 00                	push   $0x0
  8018f0:	ff 75 08             	pushl  0x8(%ebp)
  8018f3:	e8 e3 01 00 00       	call   801adb <open>
  8018f8:	89 c3                	mov    %eax,%ebx
  8018fa:	83 c4 10             	add    $0x10,%esp
  8018fd:	85 c0                	test   %eax,%eax
  8018ff:	78 1b                	js     80191c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801901:	83 ec 08             	sub    $0x8,%esp
  801904:	ff 75 0c             	pushl  0xc(%ebp)
  801907:	50                   	push   %eax
  801908:	e8 5b ff ff ff       	call   801868 <fstat>
  80190d:	89 c6                	mov    %eax,%esi
	close(fd);
  80190f:	89 1c 24             	mov    %ebx,(%esp)
  801912:	e8 f4 fb ff ff       	call   80150b <close>
	return r;
  801917:	83 c4 10             	add    $0x10,%esp
  80191a:	89 f0                	mov    %esi,%eax
}
  80191c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80191f:	5b                   	pop    %ebx
  801920:	5e                   	pop    %esi
  801921:	5d                   	pop    %ebp
  801922:	c3                   	ret    

00801923 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801923:	55                   	push   %ebp
  801924:	89 e5                	mov    %esp,%ebp
  801926:	56                   	push   %esi
  801927:	53                   	push   %ebx
  801928:	89 c6                	mov    %eax,%esi
  80192a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80192c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801933:	75 12                	jne    801947 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801935:	83 ec 0c             	sub    $0xc,%esp
  801938:	6a 01                	push   $0x1
  80193a:	e8 da 08 00 00       	call   802219 <ipc_find_env>
  80193f:	a3 00 40 80 00       	mov    %eax,0x804000
  801944:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801947:	6a 07                	push   $0x7
  801949:	68 00 50 80 00       	push   $0x805000
  80194e:	56                   	push   %esi
  80194f:	ff 35 00 40 80 00    	pushl  0x804000
  801955:	e8 5d 08 00 00       	call   8021b7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80195a:	83 c4 0c             	add    $0xc,%esp
  80195d:	6a 00                	push   $0x0
  80195f:	53                   	push   %ebx
  801960:	6a 00                	push   $0x0
  801962:	e8 d5 07 00 00       	call   80213c <ipc_recv>
}
  801967:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80196a:	5b                   	pop    %ebx
  80196b:	5e                   	pop    %esi
  80196c:	5d                   	pop    %ebp
  80196d:	c3                   	ret    

0080196e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80196e:	55                   	push   %ebp
  80196f:	89 e5                	mov    %esp,%ebp
  801971:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801974:	8b 45 08             	mov    0x8(%ebp),%eax
  801977:	8b 40 0c             	mov    0xc(%eax),%eax
  80197a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80197f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801982:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801987:	ba 00 00 00 00       	mov    $0x0,%edx
  80198c:	b8 02 00 00 00       	mov    $0x2,%eax
  801991:	e8 8d ff ff ff       	call   801923 <fsipc>
}
  801996:	c9                   	leave  
  801997:	c3                   	ret    

00801998 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801998:	55                   	push   %ebp
  801999:	89 e5                	mov    %esp,%ebp
  80199b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80199e:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a1:	8b 40 0c             	mov    0xc(%eax),%eax
  8019a4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ae:	b8 06 00 00 00       	mov    $0x6,%eax
  8019b3:	e8 6b ff ff ff       	call   801923 <fsipc>
}
  8019b8:	c9                   	leave  
  8019b9:	c3                   	ret    

008019ba <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	53                   	push   %ebx
  8019be:	83 ec 04             	sub    $0x4,%esp
  8019c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c7:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ca:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d4:	b8 05 00 00 00       	mov    $0x5,%eax
  8019d9:	e8 45 ff ff ff       	call   801923 <fsipc>
  8019de:	85 c0                	test   %eax,%eax
  8019e0:	78 2c                	js     801a0e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019e2:	83 ec 08             	sub    $0x8,%esp
  8019e5:	68 00 50 80 00       	push   $0x805000
  8019ea:	53                   	push   %ebx
  8019eb:	e8 a8 ed ff ff       	call   800798 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019f0:	a1 80 50 80 00       	mov    0x805080,%eax
  8019f5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019fb:	a1 84 50 80 00       	mov    0x805084,%eax
  801a00:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a06:	83 c4 10             	add    $0x10,%esp
  801a09:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a11:	c9                   	leave  
  801a12:	c3                   	ret    

00801a13 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a13:	55                   	push   %ebp
  801a14:	89 e5                	mov    %esp,%ebp
  801a16:	83 ec 0c             	sub    $0xc,%esp
  801a19:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a1c:	8b 55 08             	mov    0x8(%ebp),%edx
  801a1f:	8b 52 0c             	mov    0xc(%edx),%edx
  801a22:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801a28:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a2d:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a32:	0f 47 c2             	cmova  %edx,%eax
  801a35:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801a3a:	50                   	push   %eax
  801a3b:	ff 75 0c             	pushl  0xc(%ebp)
  801a3e:	68 08 50 80 00       	push   $0x805008
  801a43:	e8 e2 ee ff ff       	call   80092a <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801a48:	ba 00 00 00 00       	mov    $0x0,%edx
  801a4d:	b8 04 00 00 00       	mov    $0x4,%eax
  801a52:	e8 cc fe ff ff       	call   801923 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801a57:	c9                   	leave  
  801a58:	c3                   	ret    

00801a59 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a59:	55                   	push   %ebp
  801a5a:	89 e5                	mov    %esp,%ebp
  801a5c:	56                   	push   %esi
  801a5d:	53                   	push   %ebx
  801a5e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a61:	8b 45 08             	mov    0x8(%ebp),%eax
  801a64:	8b 40 0c             	mov    0xc(%eax),%eax
  801a67:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a6c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a72:	ba 00 00 00 00       	mov    $0x0,%edx
  801a77:	b8 03 00 00 00       	mov    $0x3,%eax
  801a7c:	e8 a2 fe ff ff       	call   801923 <fsipc>
  801a81:	89 c3                	mov    %eax,%ebx
  801a83:	85 c0                	test   %eax,%eax
  801a85:	78 4b                	js     801ad2 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a87:	39 c6                	cmp    %eax,%esi
  801a89:	73 16                	jae    801aa1 <devfile_read+0x48>
  801a8b:	68 74 2a 80 00       	push   $0x802a74
  801a90:	68 7b 2a 80 00       	push   $0x802a7b
  801a95:	6a 7c                	push   $0x7c
  801a97:	68 90 2a 80 00       	push   $0x802a90
  801a9c:	e8 c6 05 00 00       	call   802067 <_panic>
	assert(r <= PGSIZE);
  801aa1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801aa6:	7e 16                	jle    801abe <devfile_read+0x65>
  801aa8:	68 9b 2a 80 00       	push   $0x802a9b
  801aad:	68 7b 2a 80 00       	push   $0x802a7b
  801ab2:	6a 7d                	push   $0x7d
  801ab4:	68 90 2a 80 00       	push   $0x802a90
  801ab9:	e8 a9 05 00 00       	call   802067 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801abe:	83 ec 04             	sub    $0x4,%esp
  801ac1:	50                   	push   %eax
  801ac2:	68 00 50 80 00       	push   $0x805000
  801ac7:	ff 75 0c             	pushl  0xc(%ebp)
  801aca:	e8 5b ee ff ff       	call   80092a <memmove>
	return r;
  801acf:	83 c4 10             	add    $0x10,%esp
}
  801ad2:	89 d8                	mov    %ebx,%eax
  801ad4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad7:	5b                   	pop    %ebx
  801ad8:	5e                   	pop    %esi
  801ad9:	5d                   	pop    %ebp
  801ada:	c3                   	ret    

00801adb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
  801ade:	53                   	push   %ebx
  801adf:	83 ec 20             	sub    $0x20,%esp
  801ae2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ae5:	53                   	push   %ebx
  801ae6:	e8 74 ec ff ff       	call   80075f <strlen>
  801aeb:	83 c4 10             	add    $0x10,%esp
  801aee:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801af3:	7f 67                	jg     801b5c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801af5:	83 ec 0c             	sub    $0xc,%esp
  801af8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801afb:	50                   	push   %eax
  801afc:	e8 8e f8 ff ff       	call   80138f <fd_alloc>
  801b01:	83 c4 10             	add    $0x10,%esp
		return r;
  801b04:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b06:	85 c0                	test   %eax,%eax
  801b08:	78 57                	js     801b61 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b0a:	83 ec 08             	sub    $0x8,%esp
  801b0d:	53                   	push   %ebx
  801b0e:	68 00 50 80 00       	push   $0x805000
  801b13:	e8 80 ec ff ff       	call   800798 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b18:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b1b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b20:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b23:	b8 01 00 00 00       	mov    $0x1,%eax
  801b28:	e8 f6 fd ff ff       	call   801923 <fsipc>
  801b2d:	89 c3                	mov    %eax,%ebx
  801b2f:	83 c4 10             	add    $0x10,%esp
  801b32:	85 c0                	test   %eax,%eax
  801b34:	79 14                	jns    801b4a <open+0x6f>
		fd_close(fd, 0);
  801b36:	83 ec 08             	sub    $0x8,%esp
  801b39:	6a 00                	push   $0x0
  801b3b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b3e:	e8 47 f9 ff ff       	call   80148a <fd_close>
		return r;
  801b43:	83 c4 10             	add    $0x10,%esp
  801b46:	89 da                	mov    %ebx,%edx
  801b48:	eb 17                	jmp    801b61 <open+0x86>
	}

	return fd2num(fd);
  801b4a:	83 ec 0c             	sub    $0xc,%esp
  801b4d:	ff 75 f4             	pushl  -0xc(%ebp)
  801b50:	e8 13 f8 ff ff       	call   801368 <fd2num>
  801b55:	89 c2                	mov    %eax,%edx
  801b57:	83 c4 10             	add    $0x10,%esp
  801b5a:	eb 05                	jmp    801b61 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b5c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b61:	89 d0                	mov    %edx,%eax
  801b63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b66:	c9                   	leave  
  801b67:	c3                   	ret    

00801b68 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b68:	55                   	push   %ebp
  801b69:	89 e5                	mov    %esp,%ebp
  801b6b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b6e:	ba 00 00 00 00       	mov    $0x0,%edx
  801b73:	b8 08 00 00 00       	mov    $0x8,%eax
  801b78:	e8 a6 fd ff ff       	call   801923 <fsipc>
}
  801b7d:	c9                   	leave  
  801b7e:	c3                   	ret    

00801b7f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b7f:	55                   	push   %ebp
  801b80:	89 e5                	mov    %esp,%ebp
  801b82:	56                   	push   %esi
  801b83:	53                   	push   %ebx
  801b84:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b87:	83 ec 0c             	sub    $0xc,%esp
  801b8a:	ff 75 08             	pushl  0x8(%ebp)
  801b8d:	e8 e6 f7 ff ff       	call   801378 <fd2data>
  801b92:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b94:	83 c4 08             	add    $0x8,%esp
  801b97:	68 a7 2a 80 00       	push   $0x802aa7
  801b9c:	53                   	push   %ebx
  801b9d:	e8 f6 eb ff ff       	call   800798 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ba2:	8b 46 04             	mov    0x4(%esi),%eax
  801ba5:	2b 06                	sub    (%esi),%eax
  801ba7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bad:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bb4:	00 00 00 
	stat->st_dev = &devpipe;
  801bb7:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801bbe:	30 80 00 
	return 0;
}
  801bc1:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bc9:	5b                   	pop    %ebx
  801bca:	5e                   	pop    %esi
  801bcb:	5d                   	pop    %ebp
  801bcc:	c3                   	ret    

00801bcd <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bcd:	55                   	push   %ebp
  801bce:	89 e5                	mov    %esp,%ebp
  801bd0:	53                   	push   %ebx
  801bd1:	83 ec 0c             	sub    $0xc,%esp
  801bd4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bd7:	53                   	push   %ebx
  801bd8:	6a 00                	push   $0x0
  801bda:	e8 41 f0 ff ff       	call   800c20 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bdf:	89 1c 24             	mov    %ebx,(%esp)
  801be2:	e8 91 f7 ff ff       	call   801378 <fd2data>
  801be7:	83 c4 08             	add    $0x8,%esp
  801bea:	50                   	push   %eax
  801beb:	6a 00                	push   $0x0
  801bed:	e8 2e f0 ff ff       	call   800c20 <sys_page_unmap>
}
  801bf2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bf5:	c9                   	leave  
  801bf6:	c3                   	ret    

00801bf7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bf7:	55                   	push   %ebp
  801bf8:	89 e5                	mov    %esp,%ebp
  801bfa:	57                   	push   %edi
  801bfb:	56                   	push   %esi
  801bfc:	53                   	push   %ebx
  801bfd:	83 ec 1c             	sub    $0x1c,%esp
  801c00:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c03:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c05:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801c0a:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c10:	83 ec 0c             	sub    $0xc,%esp
  801c13:	ff 75 e0             	pushl  -0x20(%ebp)
  801c16:	e8 43 06 00 00       	call   80225e <pageref>
  801c1b:	89 c3                	mov    %eax,%ebx
  801c1d:	89 3c 24             	mov    %edi,(%esp)
  801c20:	e8 39 06 00 00       	call   80225e <pageref>
  801c25:	83 c4 10             	add    $0x10,%esp
  801c28:	39 c3                	cmp    %eax,%ebx
  801c2a:	0f 94 c1             	sete   %cl
  801c2d:	0f b6 c9             	movzbl %cl,%ecx
  801c30:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c33:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801c39:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801c3f:	39 ce                	cmp    %ecx,%esi
  801c41:	74 1e                	je     801c61 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801c43:	39 c3                	cmp    %eax,%ebx
  801c45:	75 be                	jne    801c05 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c47:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801c4d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c50:	50                   	push   %eax
  801c51:	56                   	push   %esi
  801c52:	68 ae 2a 80 00       	push   $0x802aae
  801c57:	e8 b7 e5 ff ff       	call   800213 <cprintf>
  801c5c:	83 c4 10             	add    $0x10,%esp
  801c5f:	eb a4                	jmp    801c05 <_pipeisclosed+0xe>
	}
}
  801c61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c67:	5b                   	pop    %ebx
  801c68:	5e                   	pop    %esi
  801c69:	5f                   	pop    %edi
  801c6a:	5d                   	pop    %ebp
  801c6b:	c3                   	ret    

00801c6c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c6c:	55                   	push   %ebp
  801c6d:	89 e5                	mov    %esp,%ebp
  801c6f:	57                   	push   %edi
  801c70:	56                   	push   %esi
  801c71:	53                   	push   %ebx
  801c72:	83 ec 28             	sub    $0x28,%esp
  801c75:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c78:	56                   	push   %esi
  801c79:	e8 fa f6 ff ff       	call   801378 <fd2data>
  801c7e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c80:	83 c4 10             	add    $0x10,%esp
  801c83:	bf 00 00 00 00       	mov    $0x0,%edi
  801c88:	eb 4b                	jmp    801cd5 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c8a:	89 da                	mov    %ebx,%edx
  801c8c:	89 f0                	mov    %esi,%eax
  801c8e:	e8 64 ff ff ff       	call   801bf7 <_pipeisclosed>
  801c93:	85 c0                	test   %eax,%eax
  801c95:	75 48                	jne    801cdf <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c97:	e8 e0 ee ff ff       	call   800b7c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c9c:	8b 43 04             	mov    0x4(%ebx),%eax
  801c9f:	8b 0b                	mov    (%ebx),%ecx
  801ca1:	8d 51 20             	lea    0x20(%ecx),%edx
  801ca4:	39 d0                	cmp    %edx,%eax
  801ca6:	73 e2                	jae    801c8a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ca8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cab:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801caf:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801cb2:	89 c2                	mov    %eax,%edx
  801cb4:	c1 fa 1f             	sar    $0x1f,%edx
  801cb7:	89 d1                	mov    %edx,%ecx
  801cb9:	c1 e9 1b             	shr    $0x1b,%ecx
  801cbc:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801cbf:	83 e2 1f             	and    $0x1f,%edx
  801cc2:	29 ca                	sub    %ecx,%edx
  801cc4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801cc8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ccc:	83 c0 01             	add    $0x1,%eax
  801ccf:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cd2:	83 c7 01             	add    $0x1,%edi
  801cd5:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cd8:	75 c2                	jne    801c9c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801cda:	8b 45 10             	mov    0x10(%ebp),%eax
  801cdd:	eb 05                	jmp    801ce4 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cdf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ce4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ce7:	5b                   	pop    %ebx
  801ce8:	5e                   	pop    %esi
  801ce9:	5f                   	pop    %edi
  801cea:	5d                   	pop    %ebp
  801ceb:	c3                   	ret    

00801cec <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cec:	55                   	push   %ebp
  801ced:	89 e5                	mov    %esp,%ebp
  801cef:	57                   	push   %edi
  801cf0:	56                   	push   %esi
  801cf1:	53                   	push   %ebx
  801cf2:	83 ec 18             	sub    $0x18,%esp
  801cf5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cf8:	57                   	push   %edi
  801cf9:	e8 7a f6 ff ff       	call   801378 <fd2data>
  801cfe:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d00:	83 c4 10             	add    $0x10,%esp
  801d03:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d08:	eb 3d                	jmp    801d47 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d0a:	85 db                	test   %ebx,%ebx
  801d0c:	74 04                	je     801d12 <devpipe_read+0x26>
				return i;
  801d0e:	89 d8                	mov    %ebx,%eax
  801d10:	eb 44                	jmp    801d56 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d12:	89 f2                	mov    %esi,%edx
  801d14:	89 f8                	mov    %edi,%eax
  801d16:	e8 dc fe ff ff       	call   801bf7 <_pipeisclosed>
  801d1b:	85 c0                	test   %eax,%eax
  801d1d:	75 32                	jne    801d51 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d1f:	e8 58 ee ff ff       	call   800b7c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d24:	8b 06                	mov    (%esi),%eax
  801d26:	3b 46 04             	cmp    0x4(%esi),%eax
  801d29:	74 df                	je     801d0a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d2b:	99                   	cltd   
  801d2c:	c1 ea 1b             	shr    $0x1b,%edx
  801d2f:	01 d0                	add    %edx,%eax
  801d31:	83 e0 1f             	and    $0x1f,%eax
  801d34:	29 d0                	sub    %edx,%eax
  801d36:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d3e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d41:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d44:	83 c3 01             	add    $0x1,%ebx
  801d47:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d4a:	75 d8                	jne    801d24 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d4c:	8b 45 10             	mov    0x10(%ebp),%eax
  801d4f:	eb 05                	jmp    801d56 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d51:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d59:	5b                   	pop    %ebx
  801d5a:	5e                   	pop    %esi
  801d5b:	5f                   	pop    %edi
  801d5c:	5d                   	pop    %ebp
  801d5d:	c3                   	ret    

00801d5e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d5e:	55                   	push   %ebp
  801d5f:	89 e5                	mov    %esp,%ebp
  801d61:	56                   	push   %esi
  801d62:	53                   	push   %ebx
  801d63:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d66:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d69:	50                   	push   %eax
  801d6a:	e8 20 f6 ff ff       	call   80138f <fd_alloc>
  801d6f:	83 c4 10             	add    $0x10,%esp
  801d72:	89 c2                	mov    %eax,%edx
  801d74:	85 c0                	test   %eax,%eax
  801d76:	0f 88 2c 01 00 00    	js     801ea8 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d7c:	83 ec 04             	sub    $0x4,%esp
  801d7f:	68 07 04 00 00       	push   $0x407
  801d84:	ff 75 f4             	pushl  -0xc(%ebp)
  801d87:	6a 00                	push   $0x0
  801d89:	e8 0d ee ff ff       	call   800b9b <sys_page_alloc>
  801d8e:	83 c4 10             	add    $0x10,%esp
  801d91:	89 c2                	mov    %eax,%edx
  801d93:	85 c0                	test   %eax,%eax
  801d95:	0f 88 0d 01 00 00    	js     801ea8 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d9b:	83 ec 0c             	sub    $0xc,%esp
  801d9e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801da1:	50                   	push   %eax
  801da2:	e8 e8 f5 ff ff       	call   80138f <fd_alloc>
  801da7:	89 c3                	mov    %eax,%ebx
  801da9:	83 c4 10             	add    $0x10,%esp
  801dac:	85 c0                	test   %eax,%eax
  801dae:	0f 88 e2 00 00 00    	js     801e96 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801db4:	83 ec 04             	sub    $0x4,%esp
  801db7:	68 07 04 00 00       	push   $0x407
  801dbc:	ff 75 f0             	pushl  -0x10(%ebp)
  801dbf:	6a 00                	push   $0x0
  801dc1:	e8 d5 ed ff ff       	call   800b9b <sys_page_alloc>
  801dc6:	89 c3                	mov    %eax,%ebx
  801dc8:	83 c4 10             	add    $0x10,%esp
  801dcb:	85 c0                	test   %eax,%eax
  801dcd:	0f 88 c3 00 00 00    	js     801e96 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801dd3:	83 ec 0c             	sub    $0xc,%esp
  801dd6:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd9:	e8 9a f5 ff ff       	call   801378 <fd2data>
  801dde:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801de0:	83 c4 0c             	add    $0xc,%esp
  801de3:	68 07 04 00 00       	push   $0x407
  801de8:	50                   	push   %eax
  801de9:	6a 00                	push   $0x0
  801deb:	e8 ab ed ff ff       	call   800b9b <sys_page_alloc>
  801df0:	89 c3                	mov    %eax,%ebx
  801df2:	83 c4 10             	add    $0x10,%esp
  801df5:	85 c0                	test   %eax,%eax
  801df7:	0f 88 89 00 00 00    	js     801e86 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dfd:	83 ec 0c             	sub    $0xc,%esp
  801e00:	ff 75 f0             	pushl  -0x10(%ebp)
  801e03:	e8 70 f5 ff ff       	call   801378 <fd2data>
  801e08:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e0f:	50                   	push   %eax
  801e10:	6a 00                	push   $0x0
  801e12:	56                   	push   %esi
  801e13:	6a 00                	push   $0x0
  801e15:	e8 c4 ed ff ff       	call   800bde <sys_page_map>
  801e1a:	89 c3                	mov    %eax,%ebx
  801e1c:	83 c4 20             	add    $0x20,%esp
  801e1f:	85 c0                	test   %eax,%eax
  801e21:	78 55                	js     801e78 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e23:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e2c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e31:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e38:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e41:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e46:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e4d:	83 ec 0c             	sub    $0xc,%esp
  801e50:	ff 75 f4             	pushl  -0xc(%ebp)
  801e53:	e8 10 f5 ff ff       	call   801368 <fd2num>
  801e58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e5b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e5d:	83 c4 04             	add    $0x4,%esp
  801e60:	ff 75 f0             	pushl  -0x10(%ebp)
  801e63:	e8 00 f5 ff ff       	call   801368 <fd2num>
  801e68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e6b:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801e6e:	83 c4 10             	add    $0x10,%esp
  801e71:	ba 00 00 00 00       	mov    $0x0,%edx
  801e76:	eb 30                	jmp    801ea8 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e78:	83 ec 08             	sub    $0x8,%esp
  801e7b:	56                   	push   %esi
  801e7c:	6a 00                	push   $0x0
  801e7e:	e8 9d ed ff ff       	call   800c20 <sys_page_unmap>
  801e83:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e86:	83 ec 08             	sub    $0x8,%esp
  801e89:	ff 75 f0             	pushl  -0x10(%ebp)
  801e8c:	6a 00                	push   $0x0
  801e8e:	e8 8d ed ff ff       	call   800c20 <sys_page_unmap>
  801e93:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e96:	83 ec 08             	sub    $0x8,%esp
  801e99:	ff 75 f4             	pushl  -0xc(%ebp)
  801e9c:	6a 00                	push   $0x0
  801e9e:	e8 7d ed ff ff       	call   800c20 <sys_page_unmap>
  801ea3:	83 c4 10             	add    $0x10,%esp
  801ea6:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ea8:	89 d0                	mov    %edx,%eax
  801eaa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ead:	5b                   	pop    %ebx
  801eae:	5e                   	pop    %esi
  801eaf:	5d                   	pop    %ebp
  801eb0:	c3                   	ret    

00801eb1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
  801eb4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eb7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eba:	50                   	push   %eax
  801ebb:	ff 75 08             	pushl  0x8(%ebp)
  801ebe:	e8 1b f5 ff ff       	call   8013de <fd_lookup>
  801ec3:	83 c4 10             	add    $0x10,%esp
  801ec6:	85 c0                	test   %eax,%eax
  801ec8:	78 18                	js     801ee2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801eca:	83 ec 0c             	sub    $0xc,%esp
  801ecd:	ff 75 f4             	pushl  -0xc(%ebp)
  801ed0:	e8 a3 f4 ff ff       	call   801378 <fd2data>
	return _pipeisclosed(fd, p);
  801ed5:	89 c2                	mov    %eax,%edx
  801ed7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eda:	e8 18 fd ff ff       	call   801bf7 <_pipeisclosed>
  801edf:	83 c4 10             	add    $0x10,%esp
}
  801ee2:	c9                   	leave  
  801ee3:	c3                   	ret    

00801ee4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ee4:	55                   	push   %ebp
  801ee5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ee7:	b8 00 00 00 00       	mov    $0x0,%eax
  801eec:	5d                   	pop    %ebp
  801eed:	c3                   	ret    

00801eee <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801eee:	55                   	push   %ebp
  801eef:	89 e5                	mov    %esp,%ebp
  801ef1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ef4:	68 c6 2a 80 00       	push   $0x802ac6
  801ef9:	ff 75 0c             	pushl  0xc(%ebp)
  801efc:	e8 97 e8 ff ff       	call   800798 <strcpy>
	return 0;
}
  801f01:	b8 00 00 00 00       	mov    $0x0,%eax
  801f06:	c9                   	leave  
  801f07:	c3                   	ret    

00801f08 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f08:	55                   	push   %ebp
  801f09:	89 e5                	mov    %esp,%ebp
  801f0b:	57                   	push   %edi
  801f0c:	56                   	push   %esi
  801f0d:	53                   	push   %ebx
  801f0e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f14:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f19:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f1f:	eb 2d                	jmp    801f4e <devcons_write+0x46>
		m = n - tot;
  801f21:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f24:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f26:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f29:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f2e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f31:	83 ec 04             	sub    $0x4,%esp
  801f34:	53                   	push   %ebx
  801f35:	03 45 0c             	add    0xc(%ebp),%eax
  801f38:	50                   	push   %eax
  801f39:	57                   	push   %edi
  801f3a:	e8 eb e9 ff ff       	call   80092a <memmove>
		sys_cputs(buf, m);
  801f3f:	83 c4 08             	add    $0x8,%esp
  801f42:	53                   	push   %ebx
  801f43:	57                   	push   %edi
  801f44:	e8 96 eb ff ff       	call   800adf <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f49:	01 de                	add    %ebx,%esi
  801f4b:	83 c4 10             	add    $0x10,%esp
  801f4e:	89 f0                	mov    %esi,%eax
  801f50:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f53:	72 cc                	jb     801f21 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f58:	5b                   	pop    %ebx
  801f59:	5e                   	pop    %esi
  801f5a:	5f                   	pop    %edi
  801f5b:	5d                   	pop    %ebp
  801f5c:	c3                   	ret    

00801f5d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f5d:	55                   	push   %ebp
  801f5e:	89 e5                	mov    %esp,%ebp
  801f60:	83 ec 08             	sub    $0x8,%esp
  801f63:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f68:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f6c:	74 2a                	je     801f98 <devcons_read+0x3b>
  801f6e:	eb 05                	jmp    801f75 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f70:	e8 07 ec ff ff       	call   800b7c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f75:	e8 83 eb ff ff       	call   800afd <sys_cgetc>
  801f7a:	85 c0                	test   %eax,%eax
  801f7c:	74 f2                	je     801f70 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f7e:	85 c0                	test   %eax,%eax
  801f80:	78 16                	js     801f98 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f82:	83 f8 04             	cmp    $0x4,%eax
  801f85:	74 0c                	je     801f93 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f87:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f8a:	88 02                	mov    %al,(%edx)
	return 1;
  801f8c:	b8 01 00 00 00       	mov    $0x1,%eax
  801f91:	eb 05                	jmp    801f98 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f93:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f98:	c9                   	leave  
  801f99:	c3                   	ret    

00801f9a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f9a:	55                   	push   %ebp
  801f9b:	89 e5                	mov    %esp,%ebp
  801f9d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fa0:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fa6:	6a 01                	push   $0x1
  801fa8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fab:	50                   	push   %eax
  801fac:	e8 2e eb ff ff       	call   800adf <sys_cputs>
}
  801fb1:	83 c4 10             	add    $0x10,%esp
  801fb4:	c9                   	leave  
  801fb5:	c3                   	ret    

00801fb6 <getchar>:

int
getchar(void)
{
  801fb6:	55                   	push   %ebp
  801fb7:	89 e5                	mov    %esp,%ebp
  801fb9:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801fbc:	6a 01                	push   $0x1
  801fbe:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fc1:	50                   	push   %eax
  801fc2:	6a 00                	push   $0x0
  801fc4:	e8 7e f6 ff ff       	call   801647 <read>
	if (r < 0)
  801fc9:	83 c4 10             	add    $0x10,%esp
  801fcc:	85 c0                	test   %eax,%eax
  801fce:	78 0f                	js     801fdf <getchar+0x29>
		return r;
	if (r < 1)
  801fd0:	85 c0                	test   %eax,%eax
  801fd2:	7e 06                	jle    801fda <getchar+0x24>
		return -E_EOF;
	return c;
  801fd4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fd8:	eb 05                	jmp    801fdf <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fda:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801fdf:	c9                   	leave  
  801fe0:	c3                   	ret    

00801fe1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fe1:	55                   	push   %ebp
  801fe2:	89 e5                	mov    %esp,%ebp
  801fe4:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fe7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fea:	50                   	push   %eax
  801feb:	ff 75 08             	pushl  0x8(%ebp)
  801fee:	e8 eb f3 ff ff       	call   8013de <fd_lookup>
  801ff3:	83 c4 10             	add    $0x10,%esp
  801ff6:	85 c0                	test   %eax,%eax
  801ff8:	78 11                	js     80200b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ffa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ffd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802003:	39 10                	cmp    %edx,(%eax)
  802005:	0f 94 c0             	sete   %al
  802008:	0f b6 c0             	movzbl %al,%eax
}
  80200b:	c9                   	leave  
  80200c:	c3                   	ret    

0080200d <opencons>:

int
opencons(void)
{
  80200d:	55                   	push   %ebp
  80200e:	89 e5                	mov    %esp,%ebp
  802010:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802013:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802016:	50                   	push   %eax
  802017:	e8 73 f3 ff ff       	call   80138f <fd_alloc>
  80201c:	83 c4 10             	add    $0x10,%esp
		return r;
  80201f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802021:	85 c0                	test   %eax,%eax
  802023:	78 3e                	js     802063 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802025:	83 ec 04             	sub    $0x4,%esp
  802028:	68 07 04 00 00       	push   $0x407
  80202d:	ff 75 f4             	pushl  -0xc(%ebp)
  802030:	6a 00                	push   $0x0
  802032:	e8 64 eb ff ff       	call   800b9b <sys_page_alloc>
  802037:	83 c4 10             	add    $0x10,%esp
		return r;
  80203a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80203c:	85 c0                	test   %eax,%eax
  80203e:	78 23                	js     802063 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802040:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802046:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802049:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80204b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80204e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802055:	83 ec 0c             	sub    $0xc,%esp
  802058:	50                   	push   %eax
  802059:	e8 0a f3 ff ff       	call   801368 <fd2num>
  80205e:	89 c2                	mov    %eax,%edx
  802060:	83 c4 10             	add    $0x10,%esp
}
  802063:	89 d0                	mov    %edx,%eax
  802065:	c9                   	leave  
  802066:	c3                   	ret    

00802067 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802067:	55                   	push   %ebp
  802068:	89 e5                	mov    %esp,%ebp
  80206a:	56                   	push   %esi
  80206b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80206c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80206f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802075:	e8 e3 ea ff ff       	call   800b5d <sys_getenvid>
  80207a:	83 ec 0c             	sub    $0xc,%esp
  80207d:	ff 75 0c             	pushl  0xc(%ebp)
  802080:	ff 75 08             	pushl  0x8(%ebp)
  802083:	56                   	push   %esi
  802084:	50                   	push   %eax
  802085:	68 d4 2a 80 00       	push   $0x802ad4
  80208a:	e8 84 e1 ff ff       	call   800213 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80208f:	83 c4 18             	add    $0x18,%esp
  802092:	53                   	push   %ebx
  802093:	ff 75 10             	pushl  0x10(%ebp)
  802096:	e8 27 e1 ff ff       	call   8001c2 <vcprintf>
	cprintf("\n");
  80209b:	c7 04 24 26 29 80 00 	movl   $0x802926,(%esp)
  8020a2:	e8 6c e1 ff ff       	call   800213 <cprintf>
  8020a7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8020aa:	cc                   	int3   
  8020ab:	eb fd                	jmp    8020aa <_panic+0x43>

008020ad <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8020ad:	55                   	push   %ebp
  8020ae:	89 e5                	mov    %esp,%ebp
  8020b0:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8020b3:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8020ba:	75 2a                	jne    8020e6 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  8020bc:	83 ec 04             	sub    $0x4,%esp
  8020bf:	6a 07                	push   $0x7
  8020c1:	68 00 f0 bf ee       	push   $0xeebff000
  8020c6:	6a 00                	push   $0x0
  8020c8:	e8 ce ea ff ff       	call   800b9b <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8020cd:	83 c4 10             	add    $0x10,%esp
  8020d0:	85 c0                	test   %eax,%eax
  8020d2:	79 12                	jns    8020e6 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8020d4:	50                   	push   %eax
  8020d5:	68 58 29 80 00       	push   $0x802958
  8020da:	6a 23                	push   $0x23
  8020dc:	68 f8 2a 80 00       	push   $0x802af8
  8020e1:	e8 81 ff ff ff       	call   802067 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8020e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e9:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8020ee:	83 ec 08             	sub    $0x8,%esp
  8020f1:	68 18 21 80 00       	push   $0x802118
  8020f6:	6a 00                	push   $0x0
  8020f8:	e8 e9 eb ff ff       	call   800ce6 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8020fd:	83 c4 10             	add    $0x10,%esp
  802100:	85 c0                	test   %eax,%eax
  802102:	79 12                	jns    802116 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802104:	50                   	push   %eax
  802105:	68 58 29 80 00       	push   $0x802958
  80210a:	6a 2c                	push   $0x2c
  80210c:	68 f8 2a 80 00       	push   $0x802af8
  802111:	e8 51 ff ff ff       	call   802067 <_panic>
	}
}
  802116:	c9                   	leave  
  802117:	c3                   	ret    

00802118 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802118:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802119:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80211e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802120:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802123:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802127:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80212c:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802130:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802132:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802135:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802136:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802139:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80213a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80213b:	c3                   	ret    

0080213c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80213c:	55                   	push   %ebp
  80213d:	89 e5                	mov    %esp,%ebp
  80213f:	56                   	push   %esi
  802140:	53                   	push   %ebx
  802141:	8b 75 08             	mov    0x8(%ebp),%esi
  802144:	8b 45 0c             	mov    0xc(%ebp),%eax
  802147:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80214a:	85 c0                	test   %eax,%eax
  80214c:	75 12                	jne    802160 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80214e:	83 ec 0c             	sub    $0xc,%esp
  802151:	68 00 00 c0 ee       	push   $0xeec00000
  802156:	e8 f0 eb ff ff       	call   800d4b <sys_ipc_recv>
  80215b:	83 c4 10             	add    $0x10,%esp
  80215e:	eb 0c                	jmp    80216c <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802160:	83 ec 0c             	sub    $0xc,%esp
  802163:	50                   	push   %eax
  802164:	e8 e2 eb ff ff       	call   800d4b <sys_ipc_recv>
  802169:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80216c:	85 f6                	test   %esi,%esi
  80216e:	0f 95 c1             	setne  %cl
  802171:	85 db                	test   %ebx,%ebx
  802173:	0f 95 c2             	setne  %dl
  802176:	84 d1                	test   %dl,%cl
  802178:	74 09                	je     802183 <ipc_recv+0x47>
  80217a:	89 c2                	mov    %eax,%edx
  80217c:	c1 ea 1f             	shr    $0x1f,%edx
  80217f:	84 d2                	test   %dl,%dl
  802181:	75 2d                	jne    8021b0 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802183:	85 f6                	test   %esi,%esi
  802185:	74 0d                	je     802194 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802187:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80218c:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802192:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802194:	85 db                	test   %ebx,%ebx
  802196:	74 0d                	je     8021a5 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802198:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80219d:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  8021a3:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8021a5:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8021aa:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  8021b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021b3:	5b                   	pop    %ebx
  8021b4:	5e                   	pop    %esi
  8021b5:	5d                   	pop    %ebp
  8021b6:	c3                   	ret    

008021b7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021b7:	55                   	push   %ebp
  8021b8:	89 e5                	mov    %esp,%ebp
  8021ba:	57                   	push   %edi
  8021bb:	56                   	push   %esi
  8021bc:	53                   	push   %ebx
  8021bd:	83 ec 0c             	sub    $0xc,%esp
  8021c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021c3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8021c9:	85 db                	test   %ebx,%ebx
  8021cb:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8021d0:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8021d3:	ff 75 14             	pushl  0x14(%ebp)
  8021d6:	53                   	push   %ebx
  8021d7:	56                   	push   %esi
  8021d8:	57                   	push   %edi
  8021d9:	e8 4a eb ff ff       	call   800d28 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8021de:	89 c2                	mov    %eax,%edx
  8021e0:	c1 ea 1f             	shr    $0x1f,%edx
  8021e3:	83 c4 10             	add    $0x10,%esp
  8021e6:	84 d2                	test   %dl,%dl
  8021e8:	74 17                	je     802201 <ipc_send+0x4a>
  8021ea:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021ed:	74 12                	je     802201 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8021ef:	50                   	push   %eax
  8021f0:	68 06 2b 80 00       	push   $0x802b06
  8021f5:	6a 47                	push   $0x47
  8021f7:	68 14 2b 80 00       	push   $0x802b14
  8021fc:	e8 66 fe ff ff       	call   802067 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802201:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802204:	75 07                	jne    80220d <ipc_send+0x56>
			sys_yield();
  802206:	e8 71 e9 ff ff       	call   800b7c <sys_yield>
  80220b:	eb c6                	jmp    8021d3 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80220d:	85 c0                	test   %eax,%eax
  80220f:	75 c2                	jne    8021d3 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802211:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802214:	5b                   	pop    %ebx
  802215:	5e                   	pop    %esi
  802216:	5f                   	pop    %edi
  802217:	5d                   	pop    %ebp
  802218:	c3                   	ret    

00802219 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802219:	55                   	push   %ebp
  80221a:	89 e5                	mov    %esp,%ebp
  80221c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80221f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802224:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  80222a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802230:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  802236:	39 ca                	cmp    %ecx,%edx
  802238:	75 13                	jne    80224d <ipc_find_env+0x34>
			return envs[i].env_id;
  80223a:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  802240:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802245:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80224b:	eb 0f                	jmp    80225c <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80224d:	83 c0 01             	add    $0x1,%eax
  802250:	3d 00 04 00 00       	cmp    $0x400,%eax
  802255:	75 cd                	jne    802224 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802257:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80225c:	5d                   	pop    %ebp
  80225d:	c3                   	ret    

0080225e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80225e:	55                   	push   %ebp
  80225f:	89 e5                	mov    %esp,%ebp
  802261:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802264:	89 d0                	mov    %edx,%eax
  802266:	c1 e8 16             	shr    $0x16,%eax
  802269:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802270:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802275:	f6 c1 01             	test   $0x1,%cl
  802278:	74 1d                	je     802297 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80227a:	c1 ea 0c             	shr    $0xc,%edx
  80227d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802284:	f6 c2 01             	test   $0x1,%dl
  802287:	74 0e                	je     802297 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802289:	c1 ea 0c             	shr    $0xc,%edx
  80228c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802293:	ef 
  802294:	0f b7 c0             	movzwl %ax,%eax
}
  802297:	5d                   	pop    %ebp
  802298:	c3                   	ret    
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
