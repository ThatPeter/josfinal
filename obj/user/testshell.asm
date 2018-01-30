
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
  80002c:	e8 f3 00 00 00       	call   800124 <libmain>
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
  80003a:	bb 14 00 00 00       	mov    $0x14,%ebx
	int i;
	for(i = 0; i < 20; i++)
	{
		mutex_lock(mtx);
  80003f:	83 ec 0c             	sub    $0xc,%esp
  800042:	ff 35 08 40 80 00    	pushl  0x804008
  800048:	e8 5c 11 00 00       	call   8011a9 <mutex_lock>
		cprintf("curenv: %d\n", sys_getenvid());
  80004d:	e8 32 0b 00 00       	call   800b84 <sys_getenvid>
  800052:	83 c4 08             	add    $0x8,%esp
  800055:	50                   	push   %eax
  800056:	68 e0 24 80 00       	push   $0x8024e0
  80005b:	e8 da 01 00 00       	call   80023a <cprintf>
		sys_yield();
  800060:	e8 3e 0b 00 00       	call   800ba3 <sys_yield>
		cprintf("curenv: %d\n", sys_getenvid());
  800065:	e8 1a 0b 00 00       	call   800b84 <sys_getenvid>
  80006a:	83 c4 08             	add    $0x8,%esp
  80006d:	50                   	push   %eax
  80006e:	68 e0 24 80 00       	push   $0x8024e0
  800073:	e8 c2 01 00 00       	call   80023a <cprintf>
		//cprintf("global++: %d\n", global++);
		//mutex_destroy(mtx);		
		mutex_unlock(mtx);
  800078:	83 c4 04             	add    $0x4,%esp
  80007b:	ff 35 08 40 80 00    	pushl  0x804008
  800081:	e8 8b 11 00 00       	call   801211 <mutex_unlock>
int global;

void func()
{	
	int i;
	for(i = 0; i < 20; i++)
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	83 eb 01             	sub    $0x1,%ebx
  80008c:	75 b1                	jne    80003f <func+0xc>
		cprintf("curenv: %d\n", sys_getenvid());
		//cprintf("global++: %d\n", global++);
		//mutex_destroy(mtx);		
		mutex_unlock(mtx);
	}
}
  80008e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800091:	c9                   	leave  
  800092:	c3                   	ret    

00800093 <test>:

void test()
{
  800093:	55                   	push   %ebp
  800094:	89 e5                	mov    %esp,%ebp
  800096:	53                   	push   %ebx
  800097:	83 ec 04             	sub    $0x4,%esp
  80009a:	bb 0a 00 00 00       	mov    $0xa,%ebx
	int i;
	for(i = 0; i < 10; i++)
	{
		cprintf("mY\n");
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	68 ec 24 80 00       	push   $0x8024ec
  8000a7:	e8 8e 01 00 00       	call   80023a <cprintf>
}

void test()
{
	int i;
	for(i = 0; i < 10; i++)
  8000ac:	83 c4 10             	add    $0x10,%esp
  8000af:	83 eb 01             	sub    $0x1,%ebx
  8000b2:	75 eb                	jne    80009f <test+0xc>
	{
		cprintf("mY\n");
	}
}
  8000b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b7:	c9                   	leave  
  8000b8:	c3                   	ret    

008000b9 <umain>:

void
umain(int argc, char **argv)
{	
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	57                   	push   %edi
  8000bd:	56                   	push   %esi
  8000be:	53                   	push   %ebx
  8000bf:	83 ec 18             	sub    $0x18,%esp
	global = 0;
  8000c2:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  8000c9:	00 00 00 
	mutex_init(mtx);
  8000cc:	ff 35 08 40 80 00    	pushl  0x804008
  8000d2:	e8 92 11 00 00       	call   801269 <mutex_init>
 	envid_t id = thread_create(func);
  8000d7:	c7 04 24 33 00 80 00 	movl   $0x800033,(%esp)
  8000de:	e8 e3 0f 00 00       	call   8010c6 <thread_create>
  8000e3:	89 c7                	mov    %eax,%edi
	envid_t id2 = thread_create(func);
  8000e5:	c7 04 24 33 00 80 00 	movl   $0x800033,(%esp)
  8000ec:	e8 d5 0f 00 00       	call   8010c6 <thread_create>
  8000f1:	89 c6                	mov    %eax,%esi
	envid_t id3 = thread_create(func);
  8000f3:	c7 04 24 33 00 80 00 	movl   $0x800033,(%esp)
  8000fa:	e8 c7 0f 00 00       	call   8010c6 <thread_create>
  8000ff:	89 c3                	mov    %eax,%ebx
	thread_join(id);
  800101:	89 3c 24             	mov    %edi,(%esp)
  800104:	e8 ea 0f 00 00       	call   8010f3 <thread_join>

	thread_join(id2);
  800109:	89 34 24             	mov    %esi,(%esp)
  80010c:	e8 e2 0f 00 00       	call   8010f3 <thread_join>
	thread_join(id3);
  800111:	89 1c 24             	mov    %ebx,(%esp)
  800114:	e8 da 0f 00 00       	call   8010f3 <thread_join>
	//mutex_destroy(mtx);
}
  800119:	83 c4 10             	add    $0x10,%esp
  80011c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011f:	5b                   	pop    %ebx
  800120:	5e                   	pop    %esi
  800121:	5f                   	pop    %edi
  800122:	5d                   	pop    %ebp
  800123:	c3                   	ret    

00800124 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	56                   	push   %esi
  800128:	53                   	push   %ebx
  800129:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80012c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80012f:	e8 50 0a 00 00       	call   800b84 <sys_getenvid>
  800134:	25 ff 03 00 00       	and    $0x3ff,%eax
  800139:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  80013f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800144:	a3 0c 40 80 00       	mov    %eax,0x80400c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800149:	85 db                	test   %ebx,%ebx
  80014b:	7e 07                	jle    800154 <libmain+0x30>
		binaryname = argv[0];
  80014d:	8b 06                	mov    (%esi),%eax
  80014f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800154:	83 ec 08             	sub    $0x8,%esp
  800157:	56                   	push   %esi
  800158:	53                   	push   %ebx
  800159:	e8 5b ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  80015e:	e8 2a 00 00 00       	call   80018d <exit>
}
  800163:	83 c4 10             	add    $0x10,%esp
  800166:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800169:	5b                   	pop    %ebx
  80016a:	5e                   	pop    %esi
  80016b:	5d                   	pop    %ebp
  80016c:	c3                   	ret    

0080016d <thread_main>:

/*Lab 7: Multithreading thread main routine*/
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	83 ec 08             	sub    $0x8,%esp
	void (*func)(void) = (void (*)(void))eip;
  800173:	a1 10 40 80 00       	mov    0x804010,%eax
	func();
  800178:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  80017a:	e8 05 0a 00 00       	call   800b84 <sys_getenvid>
  80017f:	83 ec 0c             	sub    $0xc,%esp
  800182:	50                   	push   %eax
  800183:	e8 4b 0c 00 00       	call   800dd3 <sys_thread_free>
}
  800188:	83 c4 10             	add    $0x10,%esp
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    

0080018d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800193:	e8 43 13 00 00       	call   8014db <close_all>
	sys_env_destroy(0);
  800198:	83 ec 0c             	sub    $0xc,%esp
  80019b:	6a 00                	push   $0x0
  80019d:	e8 a1 09 00 00       	call   800b43 <sys_env_destroy>
}
  8001a2:	83 c4 10             	add    $0x10,%esp
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	53                   	push   %ebx
  8001ab:	83 ec 04             	sub    $0x4,%esp
  8001ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b1:	8b 13                	mov    (%ebx),%edx
  8001b3:	8d 42 01             	lea    0x1(%edx),%eax
  8001b6:	89 03                	mov    %eax,(%ebx)
  8001b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001bb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001bf:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c4:	75 1a                	jne    8001e0 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001c6:	83 ec 08             	sub    $0x8,%esp
  8001c9:	68 ff 00 00 00       	push   $0xff
  8001ce:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d1:	50                   	push   %eax
  8001d2:	e8 2f 09 00 00       	call   800b06 <sys_cputs>
		b->idx = 0;
  8001d7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001dd:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001e0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001e7:	c9                   	leave  
  8001e8:	c3                   	ret    

008001e9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001f2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f9:	00 00 00 
	b.cnt = 0;
  8001fc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800203:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800206:	ff 75 0c             	pushl  0xc(%ebp)
  800209:	ff 75 08             	pushl  0x8(%ebp)
  80020c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800212:	50                   	push   %eax
  800213:	68 a7 01 80 00       	push   $0x8001a7
  800218:	e8 54 01 00 00       	call   800371 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80021d:	83 c4 08             	add    $0x8,%esp
  800220:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800226:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80022c:	50                   	push   %eax
  80022d:	e8 d4 08 00 00       	call   800b06 <sys_cputs>

	return b.cnt;
}
  800232:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800238:	c9                   	leave  
  800239:	c3                   	ret    

0080023a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800240:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800243:	50                   	push   %eax
  800244:	ff 75 08             	pushl  0x8(%ebp)
  800247:	e8 9d ff ff ff       	call   8001e9 <vcprintf>
	va_end(ap);

	return cnt;
}
  80024c:	c9                   	leave  
  80024d:	c3                   	ret    

0080024e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	57                   	push   %edi
  800252:	56                   	push   %esi
  800253:	53                   	push   %ebx
  800254:	83 ec 1c             	sub    $0x1c,%esp
  800257:	89 c7                	mov    %eax,%edi
  800259:	89 d6                	mov    %edx,%esi
  80025b:	8b 45 08             	mov    0x8(%ebp),%eax
  80025e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800261:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800264:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800267:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80026a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800272:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800275:	39 d3                	cmp    %edx,%ebx
  800277:	72 05                	jb     80027e <printnum+0x30>
  800279:	39 45 10             	cmp    %eax,0x10(%ebp)
  80027c:	77 45                	ja     8002c3 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	ff 75 18             	pushl  0x18(%ebp)
  800284:	8b 45 14             	mov    0x14(%ebp),%eax
  800287:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80028a:	53                   	push   %ebx
  80028b:	ff 75 10             	pushl  0x10(%ebp)
  80028e:	83 ec 08             	sub    $0x8,%esp
  800291:	ff 75 e4             	pushl  -0x1c(%ebp)
  800294:	ff 75 e0             	pushl  -0x20(%ebp)
  800297:	ff 75 dc             	pushl  -0x24(%ebp)
  80029a:	ff 75 d8             	pushl  -0x28(%ebp)
  80029d:	e8 9e 1f 00 00       	call   802240 <__udivdi3>
  8002a2:	83 c4 18             	add    $0x18,%esp
  8002a5:	52                   	push   %edx
  8002a6:	50                   	push   %eax
  8002a7:	89 f2                	mov    %esi,%edx
  8002a9:	89 f8                	mov    %edi,%eax
  8002ab:	e8 9e ff ff ff       	call   80024e <printnum>
  8002b0:	83 c4 20             	add    $0x20,%esp
  8002b3:	eb 18                	jmp    8002cd <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002b5:	83 ec 08             	sub    $0x8,%esp
  8002b8:	56                   	push   %esi
  8002b9:	ff 75 18             	pushl  0x18(%ebp)
  8002bc:	ff d7                	call   *%edi
  8002be:	83 c4 10             	add    $0x10,%esp
  8002c1:	eb 03                	jmp    8002c6 <printnum+0x78>
  8002c3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002c6:	83 eb 01             	sub    $0x1,%ebx
  8002c9:	85 db                	test   %ebx,%ebx
  8002cb:	7f e8                	jg     8002b5 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002cd:	83 ec 08             	sub    $0x8,%esp
  8002d0:	56                   	push   %esi
  8002d1:	83 ec 04             	sub    $0x4,%esp
  8002d4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002d7:	ff 75 e0             	pushl  -0x20(%ebp)
  8002da:	ff 75 dc             	pushl  -0x24(%ebp)
  8002dd:	ff 75 d8             	pushl  -0x28(%ebp)
  8002e0:	e8 8b 20 00 00       	call   802370 <__umoddi3>
  8002e5:	83 c4 14             	add    $0x14,%esp
  8002e8:	0f be 80 fa 24 80 00 	movsbl 0x8024fa(%eax),%eax
  8002ef:	50                   	push   %eax
  8002f0:	ff d7                	call   *%edi
}
  8002f2:	83 c4 10             	add    $0x10,%esp
  8002f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f8:	5b                   	pop    %ebx
  8002f9:	5e                   	pop    %esi
  8002fa:	5f                   	pop    %edi
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800300:	83 fa 01             	cmp    $0x1,%edx
  800303:	7e 0e                	jle    800313 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800305:	8b 10                	mov    (%eax),%edx
  800307:	8d 4a 08             	lea    0x8(%edx),%ecx
  80030a:	89 08                	mov    %ecx,(%eax)
  80030c:	8b 02                	mov    (%edx),%eax
  80030e:	8b 52 04             	mov    0x4(%edx),%edx
  800311:	eb 22                	jmp    800335 <getuint+0x38>
	else if (lflag)
  800313:	85 d2                	test   %edx,%edx
  800315:	74 10                	je     800327 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800317:	8b 10                	mov    (%eax),%edx
  800319:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031c:	89 08                	mov    %ecx,(%eax)
  80031e:	8b 02                	mov    (%edx),%eax
  800320:	ba 00 00 00 00       	mov    $0x0,%edx
  800325:	eb 0e                	jmp    800335 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800327:	8b 10                	mov    (%eax),%edx
  800329:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032c:	89 08                	mov    %ecx,(%eax)
  80032e:	8b 02                	mov    (%edx),%eax
  800330:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800335:	5d                   	pop    %ebp
  800336:	c3                   	ret    

00800337 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800337:	55                   	push   %ebp
  800338:	89 e5                	mov    %esp,%ebp
  80033a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80033d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800341:	8b 10                	mov    (%eax),%edx
  800343:	3b 50 04             	cmp    0x4(%eax),%edx
  800346:	73 0a                	jae    800352 <sprintputch+0x1b>
		*b->buf++ = ch;
  800348:	8d 4a 01             	lea    0x1(%edx),%ecx
  80034b:	89 08                	mov    %ecx,(%eax)
  80034d:	8b 45 08             	mov    0x8(%ebp),%eax
  800350:	88 02                	mov    %al,(%edx)
}
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80035a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80035d:	50                   	push   %eax
  80035e:	ff 75 10             	pushl  0x10(%ebp)
  800361:	ff 75 0c             	pushl  0xc(%ebp)
  800364:	ff 75 08             	pushl  0x8(%ebp)
  800367:	e8 05 00 00 00       	call   800371 <vprintfmt>
	va_end(ap);
}
  80036c:	83 c4 10             	add    $0x10,%esp
  80036f:	c9                   	leave  
  800370:	c3                   	ret    

00800371 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	57                   	push   %edi
  800375:	56                   	push   %esi
  800376:	53                   	push   %ebx
  800377:	83 ec 2c             	sub    $0x2c,%esp
  80037a:	8b 75 08             	mov    0x8(%ebp),%esi
  80037d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800380:	8b 7d 10             	mov    0x10(%ebp),%edi
  800383:	eb 12                	jmp    800397 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800385:	85 c0                	test   %eax,%eax
  800387:	0f 84 89 03 00 00    	je     800716 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80038d:	83 ec 08             	sub    $0x8,%esp
  800390:	53                   	push   %ebx
  800391:	50                   	push   %eax
  800392:	ff d6                	call   *%esi
  800394:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800397:	83 c7 01             	add    $0x1,%edi
  80039a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80039e:	83 f8 25             	cmp    $0x25,%eax
  8003a1:	75 e2                	jne    800385 <vprintfmt+0x14>
  8003a3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003a7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003ae:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003b5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c1:	eb 07                	jmp    8003ca <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003c6:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	8d 47 01             	lea    0x1(%edi),%eax
  8003cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003d0:	0f b6 07             	movzbl (%edi),%eax
  8003d3:	0f b6 c8             	movzbl %al,%ecx
  8003d6:	83 e8 23             	sub    $0x23,%eax
  8003d9:	3c 55                	cmp    $0x55,%al
  8003db:	0f 87 1a 03 00 00    	ja     8006fb <vprintfmt+0x38a>
  8003e1:	0f b6 c0             	movzbl %al,%eax
  8003e4:	ff 24 85 40 26 80 00 	jmp    *0x802640(,%eax,4)
  8003eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ee:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003f2:	eb d6                	jmp    8003ca <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ff:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800402:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800406:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800409:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80040c:	83 fa 09             	cmp    $0x9,%edx
  80040f:	77 39                	ja     80044a <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800411:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800414:	eb e9                	jmp    8003ff <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800416:	8b 45 14             	mov    0x14(%ebp),%eax
  800419:	8d 48 04             	lea    0x4(%eax),%ecx
  80041c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80041f:	8b 00                	mov    (%eax),%eax
  800421:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800424:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800427:	eb 27                	jmp    800450 <vprintfmt+0xdf>
  800429:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80042c:	85 c0                	test   %eax,%eax
  80042e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800433:	0f 49 c8             	cmovns %eax,%ecx
  800436:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800439:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80043c:	eb 8c                	jmp    8003ca <vprintfmt+0x59>
  80043e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800441:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800448:	eb 80                	jmp    8003ca <vprintfmt+0x59>
  80044a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80044d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800450:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800454:	0f 89 70 ff ff ff    	jns    8003ca <vprintfmt+0x59>
				width = precision, precision = -1;
  80045a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80045d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800460:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800467:	e9 5e ff ff ff       	jmp    8003ca <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80046c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800472:	e9 53 ff ff ff       	jmp    8003ca <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800477:	8b 45 14             	mov    0x14(%ebp),%eax
  80047a:	8d 50 04             	lea    0x4(%eax),%edx
  80047d:	89 55 14             	mov    %edx,0x14(%ebp)
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	53                   	push   %ebx
  800484:	ff 30                	pushl  (%eax)
  800486:	ff d6                	call   *%esi
			break;
  800488:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80048e:	e9 04 ff ff ff       	jmp    800397 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800493:	8b 45 14             	mov    0x14(%ebp),%eax
  800496:	8d 50 04             	lea    0x4(%eax),%edx
  800499:	89 55 14             	mov    %edx,0x14(%ebp)
  80049c:	8b 00                	mov    (%eax),%eax
  80049e:	99                   	cltd   
  80049f:	31 d0                	xor    %edx,%eax
  8004a1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a3:	83 f8 0f             	cmp    $0xf,%eax
  8004a6:	7f 0b                	jg     8004b3 <vprintfmt+0x142>
  8004a8:	8b 14 85 a0 27 80 00 	mov    0x8027a0(,%eax,4),%edx
  8004af:	85 d2                	test   %edx,%edx
  8004b1:	75 18                	jne    8004cb <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004b3:	50                   	push   %eax
  8004b4:	68 12 25 80 00       	push   $0x802512
  8004b9:	53                   	push   %ebx
  8004ba:	56                   	push   %esi
  8004bb:	e8 94 fe ff ff       	call   800354 <printfmt>
  8004c0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004c6:	e9 cc fe ff ff       	jmp    800397 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004cb:	52                   	push   %edx
  8004cc:	68 5d 29 80 00       	push   $0x80295d
  8004d1:	53                   	push   %ebx
  8004d2:	56                   	push   %esi
  8004d3:	e8 7c fe ff ff       	call   800354 <printfmt>
  8004d8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004de:	e9 b4 fe ff ff       	jmp    800397 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e6:	8d 50 04             	lea    0x4(%eax),%edx
  8004e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ec:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004ee:	85 ff                	test   %edi,%edi
  8004f0:	b8 0b 25 80 00       	mov    $0x80250b,%eax
  8004f5:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004f8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004fc:	0f 8e 94 00 00 00    	jle    800596 <vprintfmt+0x225>
  800502:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800506:	0f 84 98 00 00 00    	je     8005a4 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80050c:	83 ec 08             	sub    $0x8,%esp
  80050f:	ff 75 d0             	pushl  -0x30(%ebp)
  800512:	57                   	push   %edi
  800513:	e8 86 02 00 00       	call   80079e <strnlen>
  800518:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80051b:	29 c1                	sub    %eax,%ecx
  80051d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800520:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800523:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800527:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80052a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80052d:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052f:	eb 0f                	jmp    800540 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800531:	83 ec 08             	sub    $0x8,%esp
  800534:	53                   	push   %ebx
  800535:	ff 75 e0             	pushl  -0x20(%ebp)
  800538:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80053a:	83 ef 01             	sub    $0x1,%edi
  80053d:	83 c4 10             	add    $0x10,%esp
  800540:	85 ff                	test   %edi,%edi
  800542:	7f ed                	jg     800531 <vprintfmt+0x1c0>
  800544:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800547:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80054a:	85 c9                	test   %ecx,%ecx
  80054c:	b8 00 00 00 00       	mov    $0x0,%eax
  800551:	0f 49 c1             	cmovns %ecx,%eax
  800554:	29 c1                	sub    %eax,%ecx
  800556:	89 75 08             	mov    %esi,0x8(%ebp)
  800559:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055f:	89 cb                	mov    %ecx,%ebx
  800561:	eb 4d                	jmp    8005b0 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800563:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800567:	74 1b                	je     800584 <vprintfmt+0x213>
  800569:	0f be c0             	movsbl %al,%eax
  80056c:	83 e8 20             	sub    $0x20,%eax
  80056f:	83 f8 5e             	cmp    $0x5e,%eax
  800572:	76 10                	jbe    800584 <vprintfmt+0x213>
					putch('?', putdat);
  800574:	83 ec 08             	sub    $0x8,%esp
  800577:	ff 75 0c             	pushl  0xc(%ebp)
  80057a:	6a 3f                	push   $0x3f
  80057c:	ff 55 08             	call   *0x8(%ebp)
  80057f:	83 c4 10             	add    $0x10,%esp
  800582:	eb 0d                	jmp    800591 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800584:	83 ec 08             	sub    $0x8,%esp
  800587:	ff 75 0c             	pushl  0xc(%ebp)
  80058a:	52                   	push   %edx
  80058b:	ff 55 08             	call   *0x8(%ebp)
  80058e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800591:	83 eb 01             	sub    $0x1,%ebx
  800594:	eb 1a                	jmp    8005b0 <vprintfmt+0x23f>
  800596:	89 75 08             	mov    %esi,0x8(%ebp)
  800599:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80059c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80059f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a2:	eb 0c                	jmp    8005b0 <vprintfmt+0x23f>
  8005a4:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005aa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ad:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005b0:	83 c7 01             	add    $0x1,%edi
  8005b3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005b7:	0f be d0             	movsbl %al,%edx
  8005ba:	85 d2                	test   %edx,%edx
  8005bc:	74 23                	je     8005e1 <vprintfmt+0x270>
  8005be:	85 f6                	test   %esi,%esi
  8005c0:	78 a1                	js     800563 <vprintfmt+0x1f2>
  8005c2:	83 ee 01             	sub    $0x1,%esi
  8005c5:	79 9c                	jns    800563 <vprintfmt+0x1f2>
  8005c7:	89 df                	mov    %ebx,%edi
  8005c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8005cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005cf:	eb 18                	jmp    8005e9 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005d1:	83 ec 08             	sub    $0x8,%esp
  8005d4:	53                   	push   %ebx
  8005d5:	6a 20                	push   $0x20
  8005d7:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d9:	83 ef 01             	sub    $0x1,%edi
  8005dc:	83 c4 10             	add    $0x10,%esp
  8005df:	eb 08                	jmp    8005e9 <vprintfmt+0x278>
  8005e1:	89 df                	mov    %ebx,%edi
  8005e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e9:	85 ff                	test   %edi,%edi
  8005eb:	7f e4                	jg     8005d1 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f0:	e9 a2 fd ff ff       	jmp    800397 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005f5:	83 fa 01             	cmp    $0x1,%edx
  8005f8:	7e 16                	jle    800610 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8d 50 08             	lea    0x8(%eax),%edx
  800600:	89 55 14             	mov    %edx,0x14(%ebp)
  800603:	8b 50 04             	mov    0x4(%eax),%edx
  800606:	8b 00                	mov    (%eax),%eax
  800608:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80060e:	eb 32                	jmp    800642 <vprintfmt+0x2d1>
	else if (lflag)
  800610:	85 d2                	test   %edx,%edx
  800612:	74 18                	je     80062c <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8d 50 04             	lea    0x4(%eax),%edx
  80061a:	89 55 14             	mov    %edx,0x14(%ebp)
  80061d:	8b 00                	mov    (%eax),%eax
  80061f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800622:	89 c1                	mov    %eax,%ecx
  800624:	c1 f9 1f             	sar    $0x1f,%ecx
  800627:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80062a:	eb 16                	jmp    800642 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8d 50 04             	lea    0x4(%eax),%edx
  800632:	89 55 14             	mov    %edx,0x14(%ebp)
  800635:	8b 00                	mov    (%eax),%eax
  800637:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063a:	89 c1                	mov    %eax,%ecx
  80063c:	c1 f9 1f             	sar    $0x1f,%ecx
  80063f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800642:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800645:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800648:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80064d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800651:	79 74                	jns    8006c7 <vprintfmt+0x356>
				putch('-', putdat);
  800653:	83 ec 08             	sub    $0x8,%esp
  800656:	53                   	push   %ebx
  800657:	6a 2d                	push   $0x2d
  800659:	ff d6                	call   *%esi
				num = -(long long) num;
  80065b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80065e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800661:	f7 d8                	neg    %eax
  800663:	83 d2 00             	adc    $0x0,%edx
  800666:	f7 da                	neg    %edx
  800668:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80066b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800670:	eb 55                	jmp    8006c7 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800672:	8d 45 14             	lea    0x14(%ebp),%eax
  800675:	e8 83 fc ff ff       	call   8002fd <getuint>
			base = 10;
  80067a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80067f:	eb 46                	jmp    8006c7 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800681:	8d 45 14             	lea    0x14(%ebp),%eax
  800684:	e8 74 fc ff ff       	call   8002fd <getuint>
			base = 8;
  800689:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80068e:	eb 37                	jmp    8006c7 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800690:	83 ec 08             	sub    $0x8,%esp
  800693:	53                   	push   %ebx
  800694:	6a 30                	push   $0x30
  800696:	ff d6                	call   *%esi
			putch('x', putdat);
  800698:	83 c4 08             	add    $0x8,%esp
  80069b:	53                   	push   %ebx
  80069c:	6a 78                	push   $0x78
  80069e:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8d 50 04             	lea    0x4(%eax),%edx
  8006a6:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a9:	8b 00                	mov    (%eax),%eax
  8006ab:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006b0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006b3:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006b8:	eb 0d                	jmp    8006c7 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8006bd:	e8 3b fc ff ff       	call   8002fd <getuint>
			base = 16;
  8006c2:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c7:	83 ec 0c             	sub    $0xc,%esp
  8006ca:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006ce:	57                   	push   %edi
  8006cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d2:	51                   	push   %ecx
  8006d3:	52                   	push   %edx
  8006d4:	50                   	push   %eax
  8006d5:	89 da                	mov    %ebx,%edx
  8006d7:	89 f0                	mov    %esi,%eax
  8006d9:	e8 70 fb ff ff       	call   80024e <printnum>
			break;
  8006de:	83 c4 20             	add    $0x20,%esp
  8006e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e4:	e9 ae fc ff ff       	jmp    800397 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e9:	83 ec 08             	sub    $0x8,%esp
  8006ec:	53                   	push   %ebx
  8006ed:	51                   	push   %ecx
  8006ee:	ff d6                	call   *%esi
			break;
  8006f0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f6:	e9 9c fc ff ff       	jmp    800397 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006fb:	83 ec 08             	sub    $0x8,%esp
  8006fe:	53                   	push   %ebx
  8006ff:	6a 25                	push   $0x25
  800701:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800703:	83 c4 10             	add    $0x10,%esp
  800706:	eb 03                	jmp    80070b <vprintfmt+0x39a>
  800708:	83 ef 01             	sub    $0x1,%edi
  80070b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80070f:	75 f7                	jne    800708 <vprintfmt+0x397>
  800711:	e9 81 fc ff ff       	jmp    800397 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800716:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800719:	5b                   	pop    %ebx
  80071a:	5e                   	pop    %esi
  80071b:	5f                   	pop    %edi
  80071c:	5d                   	pop    %ebp
  80071d:	c3                   	ret    

0080071e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80071e:	55                   	push   %ebp
  80071f:	89 e5                	mov    %esp,%ebp
  800721:	83 ec 18             	sub    $0x18,%esp
  800724:	8b 45 08             	mov    0x8(%ebp),%eax
  800727:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80072a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80072d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800731:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800734:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80073b:	85 c0                	test   %eax,%eax
  80073d:	74 26                	je     800765 <vsnprintf+0x47>
  80073f:	85 d2                	test   %edx,%edx
  800741:	7e 22                	jle    800765 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800743:	ff 75 14             	pushl  0x14(%ebp)
  800746:	ff 75 10             	pushl  0x10(%ebp)
  800749:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80074c:	50                   	push   %eax
  80074d:	68 37 03 80 00       	push   $0x800337
  800752:	e8 1a fc ff ff       	call   800371 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800757:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80075a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80075d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800760:	83 c4 10             	add    $0x10,%esp
  800763:	eb 05                	jmp    80076a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800765:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80076a:	c9                   	leave  
  80076b:	c3                   	ret    

0080076c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800772:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800775:	50                   	push   %eax
  800776:	ff 75 10             	pushl  0x10(%ebp)
  800779:	ff 75 0c             	pushl  0xc(%ebp)
  80077c:	ff 75 08             	pushl  0x8(%ebp)
  80077f:	e8 9a ff ff ff       	call   80071e <vsnprintf>
	va_end(ap);

	return rc;
}
  800784:	c9                   	leave  
  800785:	c3                   	ret    

00800786 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800786:	55                   	push   %ebp
  800787:	89 e5                	mov    %esp,%ebp
  800789:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80078c:	b8 00 00 00 00       	mov    $0x0,%eax
  800791:	eb 03                	jmp    800796 <strlen+0x10>
		n++;
  800793:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800796:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80079a:	75 f7                	jne    800793 <strlen+0xd>
		n++;
	return n;
}
  80079c:	5d                   	pop    %ebp
  80079d:	c3                   	ret    

0080079e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a4:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ac:	eb 03                	jmp    8007b1 <strnlen+0x13>
		n++;
  8007ae:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b1:	39 c2                	cmp    %eax,%edx
  8007b3:	74 08                	je     8007bd <strnlen+0x1f>
  8007b5:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007b9:	75 f3                	jne    8007ae <strnlen+0x10>
  8007bb:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007bd:	5d                   	pop    %ebp
  8007be:	c3                   	ret    

008007bf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	53                   	push   %ebx
  8007c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c9:	89 c2                	mov    %eax,%edx
  8007cb:	83 c2 01             	add    $0x1,%edx
  8007ce:	83 c1 01             	add    $0x1,%ecx
  8007d1:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007d5:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d8:	84 db                	test   %bl,%bl
  8007da:	75 ef                	jne    8007cb <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007dc:	5b                   	pop    %ebx
  8007dd:	5d                   	pop    %ebp
  8007de:	c3                   	ret    

008007df <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	53                   	push   %ebx
  8007e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e6:	53                   	push   %ebx
  8007e7:	e8 9a ff ff ff       	call   800786 <strlen>
  8007ec:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ef:	ff 75 0c             	pushl  0xc(%ebp)
  8007f2:	01 d8                	add    %ebx,%eax
  8007f4:	50                   	push   %eax
  8007f5:	e8 c5 ff ff ff       	call   8007bf <strcpy>
	return dst;
}
  8007fa:	89 d8                	mov    %ebx,%eax
  8007fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ff:	c9                   	leave  
  800800:	c3                   	ret    

00800801 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	56                   	push   %esi
  800805:	53                   	push   %ebx
  800806:	8b 75 08             	mov    0x8(%ebp),%esi
  800809:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080c:	89 f3                	mov    %esi,%ebx
  80080e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800811:	89 f2                	mov    %esi,%edx
  800813:	eb 0f                	jmp    800824 <strncpy+0x23>
		*dst++ = *src;
  800815:	83 c2 01             	add    $0x1,%edx
  800818:	0f b6 01             	movzbl (%ecx),%eax
  80081b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80081e:	80 39 01             	cmpb   $0x1,(%ecx)
  800821:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800824:	39 da                	cmp    %ebx,%edx
  800826:	75 ed                	jne    800815 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800828:	89 f0                	mov    %esi,%eax
  80082a:	5b                   	pop    %ebx
  80082b:	5e                   	pop    %esi
  80082c:	5d                   	pop    %ebp
  80082d:	c3                   	ret    

0080082e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	56                   	push   %esi
  800832:	53                   	push   %ebx
  800833:	8b 75 08             	mov    0x8(%ebp),%esi
  800836:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800839:	8b 55 10             	mov    0x10(%ebp),%edx
  80083c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80083e:	85 d2                	test   %edx,%edx
  800840:	74 21                	je     800863 <strlcpy+0x35>
  800842:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800846:	89 f2                	mov    %esi,%edx
  800848:	eb 09                	jmp    800853 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80084a:	83 c2 01             	add    $0x1,%edx
  80084d:	83 c1 01             	add    $0x1,%ecx
  800850:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800853:	39 c2                	cmp    %eax,%edx
  800855:	74 09                	je     800860 <strlcpy+0x32>
  800857:	0f b6 19             	movzbl (%ecx),%ebx
  80085a:	84 db                	test   %bl,%bl
  80085c:	75 ec                	jne    80084a <strlcpy+0x1c>
  80085e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800860:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800863:	29 f0                	sub    %esi,%eax
}
  800865:	5b                   	pop    %ebx
  800866:	5e                   	pop    %esi
  800867:	5d                   	pop    %ebp
  800868:	c3                   	ret    

00800869 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800872:	eb 06                	jmp    80087a <strcmp+0x11>
		p++, q++;
  800874:	83 c1 01             	add    $0x1,%ecx
  800877:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80087a:	0f b6 01             	movzbl (%ecx),%eax
  80087d:	84 c0                	test   %al,%al
  80087f:	74 04                	je     800885 <strcmp+0x1c>
  800881:	3a 02                	cmp    (%edx),%al
  800883:	74 ef                	je     800874 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800885:	0f b6 c0             	movzbl %al,%eax
  800888:	0f b6 12             	movzbl (%edx),%edx
  80088b:	29 d0                	sub    %edx,%eax
}
  80088d:	5d                   	pop    %ebp
  80088e:	c3                   	ret    

0080088f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	53                   	push   %ebx
  800893:	8b 45 08             	mov    0x8(%ebp),%eax
  800896:	8b 55 0c             	mov    0xc(%ebp),%edx
  800899:	89 c3                	mov    %eax,%ebx
  80089b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80089e:	eb 06                	jmp    8008a6 <strncmp+0x17>
		n--, p++, q++;
  8008a0:	83 c0 01             	add    $0x1,%eax
  8008a3:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a6:	39 d8                	cmp    %ebx,%eax
  8008a8:	74 15                	je     8008bf <strncmp+0x30>
  8008aa:	0f b6 08             	movzbl (%eax),%ecx
  8008ad:	84 c9                	test   %cl,%cl
  8008af:	74 04                	je     8008b5 <strncmp+0x26>
  8008b1:	3a 0a                	cmp    (%edx),%cl
  8008b3:	74 eb                	je     8008a0 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b5:	0f b6 00             	movzbl (%eax),%eax
  8008b8:	0f b6 12             	movzbl (%edx),%edx
  8008bb:	29 d0                	sub    %edx,%eax
  8008bd:	eb 05                	jmp    8008c4 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008bf:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008c4:	5b                   	pop    %ebx
  8008c5:	5d                   	pop    %ebp
  8008c6:	c3                   	ret    

008008c7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d1:	eb 07                	jmp    8008da <strchr+0x13>
		if (*s == c)
  8008d3:	38 ca                	cmp    %cl,%dl
  8008d5:	74 0f                	je     8008e6 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d7:	83 c0 01             	add    $0x1,%eax
  8008da:	0f b6 10             	movzbl (%eax),%edx
  8008dd:	84 d2                	test   %dl,%dl
  8008df:	75 f2                	jne    8008d3 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    

008008e8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ee:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f2:	eb 03                	jmp    8008f7 <strfind+0xf>
  8008f4:	83 c0 01             	add    $0x1,%eax
  8008f7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008fa:	38 ca                	cmp    %cl,%dl
  8008fc:	74 04                	je     800902 <strfind+0x1a>
  8008fe:	84 d2                	test   %dl,%dl
  800900:	75 f2                	jne    8008f4 <strfind+0xc>
			break;
	return (char *) s;
}
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	57                   	push   %edi
  800908:	56                   	push   %esi
  800909:	53                   	push   %ebx
  80090a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800910:	85 c9                	test   %ecx,%ecx
  800912:	74 36                	je     80094a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800914:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80091a:	75 28                	jne    800944 <memset+0x40>
  80091c:	f6 c1 03             	test   $0x3,%cl
  80091f:	75 23                	jne    800944 <memset+0x40>
		c &= 0xFF;
  800921:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800925:	89 d3                	mov    %edx,%ebx
  800927:	c1 e3 08             	shl    $0x8,%ebx
  80092a:	89 d6                	mov    %edx,%esi
  80092c:	c1 e6 18             	shl    $0x18,%esi
  80092f:	89 d0                	mov    %edx,%eax
  800931:	c1 e0 10             	shl    $0x10,%eax
  800934:	09 f0                	or     %esi,%eax
  800936:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800938:	89 d8                	mov    %ebx,%eax
  80093a:	09 d0                	or     %edx,%eax
  80093c:	c1 e9 02             	shr    $0x2,%ecx
  80093f:	fc                   	cld    
  800940:	f3 ab                	rep stos %eax,%es:(%edi)
  800942:	eb 06                	jmp    80094a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800944:	8b 45 0c             	mov    0xc(%ebp),%eax
  800947:	fc                   	cld    
  800948:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80094a:	89 f8                	mov    %edi,%eax
  80094c:	5b                   	pop    %ebx
  80094d:	5e                   	pop    %esi
  80094e:	5f                   	pop    %edi
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	57                   	push   %edi
  800955:	56                   	push   %esi
  800956:	8b 45 08             	mov    0x8(%ebp),%eax
  800959:	8b 75 0c             	mov    0xc(%ebp),%esi
  80095c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80095f:	39 c6                	cmp    %eax,%esi
  800961:	73 35                	jae    800998 <memmove+0x47>
  800963:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800966:	39 d0                	cmp    %edx,%eax
  800968:	73 2e                	jae    800998 <memmove+0x47>
		s += n;
		d += n;
  80096a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096d:	89 d6                	mov    %edx,%esi
  80096f:	09 fe                	or     %edi,%esi
  800971:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800977:	75 13                	jne    80098c <memmove+0x3b>
  800979:	f6 c1 03             	test   $0x3,%cl
  80097c:	75 0e                	jne    80098c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80097e:	83 ef 04             	sub    $0x4,%edi
  800981:	8d 72 fc             	lea    -0x4(%edx),%esi
  800984:	c1 e9 02             	shr    $0x2,%ecx
  800987:	fd                   	std    
  800988:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098a:	eb 09                	jmp    800995 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80098c:	83 ef 01             	sub    $0x1,%edi
  80098f:	8d 72 ff             	lea    -0x1(%edx),%esi
  800992:	fd                   	std    
  800993:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800995:	fc                   	cld    
  800996:	eb 1d                	jmp    8009b5 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800998:	89 f2                	mov    %esi,%edx
  80099a:	09 c2                	or     %eax,%edx
  80099c:	f6 c2 03             	test   $0x3,%dl
  80099f:	75 0f                	jne    8009b0 <memmove+0x5f>
  8009a1:	f6 c1 03             	test   $0x3,%cl
  8009a4:	75 0a                	jne    8009b0 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009a6:	c1 e9 02             	shr    $0x2,%ecx
  8009a9:	89 c7                	mov    %eax,%edi
  8009ab:	fc                   	cld    
  8009ac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ae:	eb 05                	jmp    8009b5 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009b0:	89 c7                	mov    %eax,%edi
  8009b2:	fc                   	cld    
  8009b3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b5:	5e                   	pop    %esi
  8009b6:	5f                   	pop    %edi
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    

008009b9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009bc:	ff 75 10             	pushl  0x10(%ebp)
  8009bf:	ff 75 0c             	pushl  0xc(%ebp)
  8009c2:	ff 75 08             	pushl  0x8(%ebp)
  8009c5:	e8 87 ff ff ff       	call   800951 <memmove>
}
  8009ca:	c9                   	leave  
  8009cb:	c3                   	ret    

008009cc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	56                   	push   %esi
  8009d0:	53                   	push   %ebx
  8009d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d7:	89 c6                	mov    %eax,%esi
  8009d9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009dc:	eb 1a                	jmp    8009f8 <memcmp+0x2c>
		if (*s1 != *s2)
  8009de:	0f b6 08             	movzbl (%eax),%ecx
  8009e1:	0f b6 1a             	movzbl (%edx),%ebx
  8009e4:	38 d9                	cmp    %bl,%cl
  8009e6:	74 0a                	je     8009f2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009e8:	0f b6 c1             	movzbl %cl,%eax
  8009eb:	0f b6 db             	movzbl %bl,%ebx
  8009ee:	29 d8                	sub    %ebx,%eax
  8009f0:	eb 0f                	jmp    800a01 <memcmp+0x35>
		s1++, s2++;
  8009f2:	83 c0 01             	add    $0x1,%eax
  8009f5:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f8:	39 f0                	cmp    %esi,%eax
  8009fa:	75 e2                	jne    8009de <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a01:	5b                   	pop    %ebx
  800a02:	5e                   	pop    %esi
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    

00800a05 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	53                   	push   %ebx
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a0c:	89 c1                	mov    %eax,%ecx
  800a0e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a11:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a15:	eb 0a                	jmp    800a21 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a17:	0f b6 10             	movzbl (%eax),%edx
  800a1a:	39 da                	cmp    %ebx,%edx
  800a1c:	74 07                	je     800a25 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a1e:	83 c0 01             	add    $0x1,%eax
  800a21:	39 c8                	cmp    %ecx,%eax
  800a23:	72 f2                	jb     800a17 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a25:	5b                   	pop    %ebx
  800a26:	5d                   	pop    %ebp
  800a27:	c3                   	ret    

00800a28 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	57                   	push   %edi
  800a2c:	56                   	push   %esi
  800a2d:	53                   	push   %ebx
  800a2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a31:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a34:	eb 03                	jmp    800a39 <strtol+0x11>
		s++;
  800a36:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a39:	0f b6 01             	movzbl (%ecx),%eax
  800a3c:	3c 20                	cmp    $0x20,%al
  800a3e:	74 f6                	je     800a36 <strtol+0xe>
  800a40:	3c 09                	cmp    $0x9,%al
  800a42:	74 f2                	je     800a36 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a44:	3c 2b                	cmp    $0x2b,%al
  800a46:	75 0a                	jne    800a52 <strtol+0x2a>
		s++;
  800a48:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a4b:	bf 00 00 00 00       	mov    $0x0,%edi
  800a50:	eb 11                	jmp    800a63 <strtol+0x3b>
  800a52:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a57:	3c 2d                	cmp    $0x2d,%al
  800a59:	75 08                	jne    800a63 <strtol+0x3b>
		s++, neg = 1;
  800a5b:	83 c1 01             	add    $0x1,%ecx
  800a5e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a63:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a69:	75 15                	jne    800a80 <strtol+0x58>
  800a6b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a6e:	75 10                	jne    800a80 <strtol+0x58>
  800a70:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a74:	75 7c                	jne    800af2 <strtol+0xca>
		s += 2, base = 16;
  800a76:	83 c1 02             	add    $0x2,%ecx
  800a79:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a7e:	eb 16                	jmp    800a96 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a80:	85 db                	test   %ebx,%ebx
  800a82:	75 12                	jne    800a96 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a84:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a89:	80 39 30             	cmpb   $0x30,(%ecx)
  800a8c:	75 08                	jne    800a96 <strtol+0x6e>
		s++, base = 8;
  800a8e:	83 c1 01             	add    $0x1,%ecx
  800a91:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a96:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a9e:	0f b6 11             	movzbl (%ecx),%edx
  800aa1:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aa4:	89 f3                	mov    %esi,%ebx
  800aa6:	80 fb 09             	cmp    $0x9,%bl
  800aa9:	77 08                	ja     800ab3 <strtol+0x8b>
			dig = *s - '0';
  800aab:	0f be d2             	movsbl %dl,%edx
  800aae:	83 ea 30             	sub    $0x30,%edx
  800ab1:	eb 22                	jmp    800ad5 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ab3:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab6:	89 f3                	mov    %esi,%ebx
  800ab8:	80 fb 19             	cmp    $0x19,%bl
  800abb:	77 08                	ja     800ac5 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800abd:	0f be d2             	movsbl %dl,%edx
  800ac0:	83 ea 57             	sub    $0x57,%edx
  800ac3:	eb 10                	jmp    800ad5 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ac5:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac8:	89 f3                	mov    %esi,%ebx
  800aca:	80 fb 19             	cmp    $0x19,%bl
  800acd:	77 16                	ja     800ae5 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800acf:	0f be d2             	movsbl %dl,%edx
  800ad2:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ad5:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad8:	7d 0b                	jge    800ae5 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ada:	83 c1 01             	add    $0x1,%ecx
  800add:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ae1:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ae3:	eb b9                	jmp    800a9e <strtol+0x76>

	if (endptr)
  800ae5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae9:	74 0d                	je     800af8 <strtol+0xd0>
		*endptr = (char *) s;
  800aeb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aee:	89 0e                	mov    %ecx,(%esi)
  800af0:	eb 06                	jmp    800af8 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800af2:	85 db                	test   %ebx,%ebx
  800af4:	74 98                	je     800a8e <strtol+0x66>
  800af6:	eb 9e                	jmp    800a96 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800af8:	89 c2                	mov    %eax,%edx
  800afa:	f7 da                	neg    %edx
  800afc:	85 ff                	test   %edi,%edi
  800afe:	0f 45 c2             	cmovne %edx,%eax
}
  800b01:	5b                   	pop    %ebx
  800b02:	5e                   	pop    %esi
  800b03:	5f                   	pop    %edi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	57                   	push   %edi
  800b0a:	56                   	push   %esi
  800b0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b14:	8b 55 08             	mov    0x8(%ebp),%edx
  800b17:	89 c3                	mov    %eax,%ebx
  800b19:	89 c7                	mov    %eax,%edi
  800b1b:	89 c6                	mov    %eax,%esi
  800b1d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b1f:	5b                   	pop    %ebx
  800b20:	5e                   	pop    %esi
  800b21:	5f                   	pop    %edi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b34:	89 d1                	mov    %edx,%ecx
  800b36:	89 d3                	mov    %edx,%ebx
  800b38:	89 d7                	mov    %edx,%edi
  800b3a:	89 d6                	mov    %edx,%esi
  800b3c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5f                   	pop    %edi
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	57                   	push   %edi
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
  800b49:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b51:	b8 03 00 00 00       	mov    $0x3,%eax
  800b56:	8b 55 08             	mov    0x8(%ebp),%edx
  800b59:	89 cb                	mov    %ecx,%ebx
  800b5b:	89 cf                	mov    %ecx,%edi
  800b5d:	89 ce                	mov    %ecx,%esi
  800b5f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b61:	85 c0                	test   %eax,%eax
  800b63:	7e 17                	jle    800b7c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b65:	83 ec 0c             	sub    $0xc,%esp
  800b68:	50                   	push   %eax
  800b69:	6a 03                	push   $0x3
  800b6b:	68 ff 27 80 00       	push   $0x8027ff
  800b70:	6a 23                	push   $0x23
  800b72:	68 1c 28 80 00       	push   $0x80281c
  800b77:	e8 90 14 00 00       	call   80200c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7f:	5b                   	pop    %ebx
  800b80:	5e                   	pop    %esi
  800b81:	5f                   	pop    %edi
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    

00800b84 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	57                   	push   %edi
  800b88:	56                   	push   %esi
  800b89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8f:	b8 02 00 00 00       	mov    $0x2,%eax
  800b94:	89 d1                	mov    %edx,%ecx
  800b96:	89 d3                	mov    %edx,%ebx
  800b98:	89 d7                	mov    %edx,%edi
  800b9a:	89 d6                	mov    %edx,%esi
  800b9c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5f                   	pop    %edi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    

00800ba3 <sys_yield>:

void
sys_yield(void)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	57                   	push   %edi
  800ba7:	56                   	push   %esi
  800ba8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bae:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bb3:	89 d1                	mov    %edx,%ecx
  800bb5:	89 d3                	mov    %edx,%ebx
  800bb7:	89 d7                	mov    %edx,%edi
  800bb9:	89 d6                	mov    %edx,%esi
  800bbb:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
  800bc8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcb:	be 00 00 00 00       	mov    $0x0,%esi
  800bd0:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bde:	89 f7                	mov    %esi,%edi
  800be0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be2:	85 c0                	test   %eax,%eax
  800be4:	7e 17                	jle    800bfd <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be6:	83 ec 0c             	sub    $0xc,%esp
  800be9:	50                   	push   %eax
  800bea:	6a 04                	push   $0x4
  800bec:	68 ff 27 80 00       	push   $0x8027ff
  800bf1:	6a 23                	push   $0x23
  800bf3:	68 1c 28 80 00       	push   $0x80281c
  800bf8:	e8 0f 14 00 00       	call   80200c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	57                   	push   %edi
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
  800c0b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c16:	8b 55 08             	mov    0x8(%ebp),%edx
  800c19:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c1f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c22:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c24:	85 c0                	test   %eax,%eax
  800c26:	7e 17                	jle    800c3f <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c28:	83 ec 0c             	sub    $0xc,%esp
  800c2b:	50                   	push   %eax
  800c2c:	6a 05                	push   $0x5
  800c2e:	68 ff 27 80 00       	push   $0x8027ff
  800c33:	6a 23                	push   $0x23
  800c35:	68 1c 28 80 00       	push   $0x80281c
  800c3a:	e8 cd 13 00 00       	call   80200c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c42:	5b                   	pop    %ebx
  800c43:	5e                   	pop    %esi
  800c44:	5f                   	pop    %edi
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    

00800c47 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
  800c4d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c55:	b8 06 00 00 00       	mov    $0x6,%eax
  800c5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c60:	89 df                	mov    %ebx,%edi
  800c62:	89 de                	mov    %ebx,%esi
  800c64:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c66:	85 c0                	test   %eax,%eax
  800c68:	7e 17                	jle    800c81 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6a:	83 ec 0c             	sub    $0xc,%esp
  800c6d:	50                   	push   %eax
  800c6e:	6a 06                	push   $0x6
  800c70:	68 ff 27 80 00       	push   $0x8027ff
  800c75:	6a 23                	push   $0x23
  800c77:	68 1c 28 80 00       	push   $0x80281c
  800c7c:	e8 8b 13 00 00       	call   80200c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c97:	b8 08 00 00 00       	mov    $0x8,%eax
  800c9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca2:	89 df                	mov    %ebx,%edi
  800ca4:	89 de                	mov    %ebx,%esi
  800ca6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca8:	85 c0                	test   %eax,%eax
  800caa:	7e 17                	jle    800cc3 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cac:	83 ec 0c             	sub    $0xc,%esp
  800caf:	50                   	push   %eax
  800cb0:	6a 08                	push   $0x8
  800cb2:	68 ff 27 80 00       	push   $0x8027ff
  800cb7:	6a 23                	push   $0x23
  800cb9:	68 1c 28 80 00       	push   $0x80281c
  800cbe:	e8 49 13 00 00       	call   80200c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc6:	5b                   	pop    %ebx
  800cc7:	5e                   	pop    %esi
  800cc8:	5f                   	pop    %edi
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	57                   	push   %edi
  800ccf:	56                   	push   %esi
  800cd0:	53                   	push   %ebx
  800cd1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd9:	b8 09 00 00 00       	mov    $0x9,%eax
  800cde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce4:	89 df                	mov    %ebx,%edi
  800ce6:	89 de                	mov    %ebx,%esi
  800ce8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cea:	85 c0                	test   %eax,%eax
  800cec:	7e 17                	jle    800d05 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cee:	83 ec 0c             	sub    $0xc,%esp
  800cf1:	50                   	push   %eax
  800cf2:	6a 09                	push   $0x9
  800cf4:	68 ff 27 80 00       	push   $0x8027ff
  800cf9:	6a 23                	push   $0x23
  800cfb:	68 1c 28 80 00       	push   $0x80281c
  800d00:	e8 07 13 00 00       	call   80200c <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
  800d13:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d23:	8b 55 08             	mov    0x8(%ebp),%edx
  800d26:	89 df                	mov    %ebx,%edi
  800d28:	89 de                	mov    %ebx,%esi
  800d2a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d2c:	85 c0                	test   %eax,%eax
  800d2e:	7e 17                	jle    800d47 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d30:	83 ec 0c             	sub    $0xc,%esp
  800d33:	50                   	push   %eax
  800d34:	6a 0a                	push   $0xa
  800d36:	68 ff 27 80 00       	push   $0x8027ff
  800d3b:	6a 23                	push   $0x23
  800d3d:	68 1c 28 80 00       	push   $0x80281c
  800d42:	e8 c5 12 00 00       	call   80200c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4a:	5b                   	pop    %ebx
  800d4b:	5e                   	pop    %esi
  800d4c:	5f                   	pop    %edi
  800d4d:	5d                   	pop    %ebp
  800d4e:	c3                   	ret    

00800d4f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	57                   	push   %edi
  800d53:	56                   	push   %esi
  800d54:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d55:	be 00 00 00 00       	mov    $0x0,%esi
  800d5a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d68:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d6b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d6d:	5b                   	pop    %ebx
  800d6e:	5e                   	pop    %esi
  800d6f:	5f                   	pop    %edi
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	57                   	push   %edi
  800d76:	56                   	push   %esi
  800d77:	53                   	push   %ebx
  800d78:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d80:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d85:	8b 55 08             	mov    0x8(%ebp),%edx
  800d88:	89 cb                	mov    %ecx,%ebx
  800d8a:	89 cf                	mov    %ecx,%edi
  800d8c:	89 ce                	mov    %ecx,%esi
  800d8e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d90:	85 c0                	test   %eax,%eax
  800d92:	7e 17                	jle    800dab <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d94:	83 ec 0c             	sub    $0xc,%esp
  800d97:	50                   	push   %eax
  800d98:	6a 0d                	push   $0xd
  800d9a:	68 ff 27 80 00       	push   $0x8027ff
  800d9f:	6a 23                	push   $0x23
  800da1:	68 1c 28 80 00       	push   $0x80281c
  800da6:	e8 61 12 00 00       	call   80200c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dae:	5b                   	pop    %ebx
  800daf:	5e                   	pop    %esi
  800db0:	5f                   	pop    %edi
  800db1:	5d                   	pop    %ebp
  800db2:	c3                   	ret    

00800db3 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
  800db6:	57                   	push   %edi
  800db7:	56                   	push   %esi
  800db8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dbe:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc6:	89 cb                	mov    %ecx,%ebx
  800dc8:	89 cf                	mov    %ecx,%edi
  800dca:	89 ce                	mov    %ecx,%esi
  800dcc:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800dce:	5b                   	pop    %ebx
  800dcf:	5e                   	pop    %esi
  800dd0:	5f                   	pop    %edi
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    

00800dd3 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	57                   	push   %edi
  800dd7:	56                   	push   %esi
  800dd8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dde:	b8 0f 00 00 00       	mov    $0xf,%eax
  800de3:	8b 55 08             	mov    0x8(%ebp),%edx
  800de6:	89 cb                	mov    %ecx,%ebx
  800de8:	89 cf                	mov    %ecx,%edi
  800dea:	89 ce                	mov    %ecx,%esi
  800dec:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800dee:	5b                   	pop    %ebx
  800def:	5e                   	pop    %esi
  800df0:	5f                   	pop    %edi
  800df1:	5d                   	pop    %ebp
  800df2:	c3                   	ret    

00800df3 <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	57                   	push   %edi
  800df7:	56                   	push   %esi
  800df8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dfe:	b8 10 00 00 00       	mov    $0x10,%eax
  800e03:	8b 55 08             	mov    0x8(%ebp),%edx
  800e06:	89 cb                	mov    %ecx,%ebx
  800e08:	89 cf                	mov    %ecx,%edi
  800e0a:	89 ce                	mov    %ecx,%esi
  800e0c:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800e0e:	5b                   	pop    %ebx
  800e0f:	5e                   	pop    %esi
  800e10:	5f                   	pop    %edi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    

00800e13 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	53                   	push   %ebx
  800e17:	83 ec 04             	sub    $0x4,%esp
  800e1a:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e1d:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800e1f:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e23:	74 11                	je     800e36 <pgfault+0x23>
  800e25:	89 d8                	mov    %ebx,%eax
  800e27:	c1 e8 0c             	shr    $0xc,%eax
  800e2a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e31:	f6 c4 08             	test   $0x8,%ah
  800e34:	75 14                	jne    800e4a <pgfault+0x37>
		panic("faulting access");
  800e36:	83 ec 04             	sub    $0x4,%esp
  800e39:	68 2a 28 80 00       	push   $0x80282a
  800e3e:	6a 1f                	push   $0x1f
  800e40:	68 3a 28 80 00       	push   $0x80283a
  800e45:	e8 c2 11 00 00       	call   80200c <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e4a:	83 ec 04             	sub    $0x4,%esp
  800e4d:	6a 07                	push   $0x7
  800e4f:	68 00 f0 7f 00       	push   $0x7ff000
  800e54:	6a 00                	push   $0x0
  800e56:	e8 67 fd ff ff       	call   800bc2 <sys_page_alloc>
	if (r < 0) {
  800e5b:	83 c4 10             	add    $0x10,%esp
  800e5e:	85 c0                	test   %eax,%eax
  800e60:	79 12                	jns    800e74 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e62:	50                   	push   %eax
  800e63:	68 45 28 80 00       	push   $0x802845
  800e68:	6a 2d                	push   $0x2d
  800e6a:	68 3a 28 80 00       	push   $0x80283a
  800e6f:	e8 98 11 00 00       	call   80200c <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e74:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e7a:	83 ec 04             	sub    $0x4,%esp
  800e7d:	68 00 10 00 00       	push   $0x1000
  800e82:	53                   	push   %ebx
  800e83:	68 00 f0 7f 00       	push   $0x7ff000
  800e88:	e8 2c fb ff ff       	call   8009b9 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e8d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e94:	53                   	push   %ebx
  800e95:	6a 00                	push   $0x0
  800e97:	68 00 f0 7f 00       	push   $0x7ff000
  800e9c:	6a 00                	push   $0x0
  800e9e:	e8 62 fd ff ff       	call   800c05 <sys_page_map>
	if (r < 0) {
  800ea3:	83 c4 20             	add    $0x20,%esp
  800ea6:	85 c0                	test   %eax,%eax
  800ea8:	79 12                	jns    800ebc <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800eaa:	50                   	push   %eax
  800eab:	68 45 28 80 00       	push   $0x802845
  800eb0:	6a 34                	push   $0x34
  800eb2:	68 3a 28 80 00       	push   $0x80283a
  800eb7:	e8 50 11 00 00       	call   80200c <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800ebc:	83 ec 08             	sub    $0x8,%esp
  800ebf:	68 00 f0 7f 00       	push   $0x7ff000
  800ec4:	6a 00                	push   $0x0
  800ec6:	e8 7c fd ff ff       	call   800c47 <sys_page_unmap>
	if (r < 0) {
  800ecb:	83 c4 10             	add    $0x10,%esp
  800ece:	85 c0                	test   %eax,%eax
  800ed0:	79 12                	jns    800ee4 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800ed2:	50                   	push   %eax
  800ed3:	68 45 28 80 00       	push   $0x802845
  800ed8:	6a 38                	push   $0x38
  800eda:	68 3a 28 80 00       	push   $0x80283a
  800edf:	e8 28 11 00 00       	call   80200c <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800ee4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ee7:	c9                   	leave  
  800ee8:	c3                   	ret    

00800ee9 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	57                   	push   %edi
  800eed:	56                   	push   %esi
  800eee:	53                   	push   %ebx
  800eef:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800ef2:	68 13 0e 80 00       	push   $0x800e13
  800ef7:	e8 56 11 00 00       	call   802052 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800efc:	b8 07 00 00 00       	mov    $0x7,%eax
  800f01:	cd 30                	int    $0x30
  800f03:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800f06:	83 c4 10             	add    $0x10,%esp
  800f09:	85 c0                	test   %eax,%eax
  800f0b:	79 17                	jns    800f24 <fork+0x3b>
		panic("fork fault %e");
  800f0d:	83 ec 04             	sub    $0x4,%esp
  800f10:	68 5e 28 80 00       	push   $0x80285e
  800f15:	68 85 00 00 00       	push   $0x85
  800f1a:	68 3a 28 80 00       	push   $0x80283a
  800f1f:	e8 e8 10 00 00       	call   80200c <_panic>
  800f24:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f26:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f2a:	75 24                	jne    800f50 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f2c:	e8 53 fc ff ff       	call   800b84 <sys_getenvid>
  800f31:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f36:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800f3c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f41:	a3 0c 40 80 00       	mov    %eax,0x80400c
		return 0;
  800f46:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4b:	e9 64 01 00 00       	jmp    8010b4 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f50:	83 ec 04             	sub    $0x4,%esp
  800f53:	6a 07                	push   $0x7
  800f55:	68 00 f0 bf ee       	push   $0xeebff000
  800f5a:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f5d:	e8 60 fc ff ff       	call   800bc2 <sys_page_alloc>
  800f62:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f65:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f6a:	89 d8                	mov    %ebx,%eax
  800f6c:	c1 e8 16             	shr    $0x16,%eax
  800f6f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f76:	a8 01                	test   $0x1,%al
  800f78:	0f 84 fc 00 00 00    	je     80107a <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f7e:	89 d8                	mov    %ebx,%eax
  800f80:	c1 e8 0c             	shr    $0xc,%eax
  800f83:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f8a:	f6 c2 01             	test   $0x1,%dl
  800f8d:	0f 84 e7 00 00 00    	je     80107a <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f93:	89 c6                	mov    %eax,%esi
  800f95:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f98:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f9f:	f6 c6 04             	test   $0x4,%dh
  800fa2:	74 39                	je     800fdd <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800fa4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fab:	83 ec 0c             	sub    $0xc,%esp
  800fae:	25 07 0e 00 00       	and    $0xe07,%eax
  800fb3:	50                   	push   %eax
  800fb4:	56                   	push   %esi
  800fb5:	57                   	push   %edi
  800fb6:	56                   	push   %esi
  800fb7:	6a 00                	push   $0x0
  800fb9:	e8 47 fc ff ff       	call   800c05 <sys_page_map>
		if (r < 0) {
  800fbe:	83 c4 20             	add    $0x20,%esp
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	0f 89 b1 00 00 00    	jns    80107a <fork+0x191>
		    	panic("sys page map fault %e");
  800fc9:	83 ec 04             	sub    $0x4,%esp
  800fcc:	68 6c 28 80 00       	push   $0x80286c
  800fd1:	6a 55                	push   $0x55
  800fd3:	68 3a 28 80 00       	push   $0x80283a
  800fd8:	e8 2f 10 00 00       	call   80200c <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800fdd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fe4:	f6 c2 02             	test   $0x2,%dl
  800fe7:	75 0c                	jne    800ff5 <fork+0x10c>
  800fe9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ff0:	f6 c4 08             	test   $0x8,%ah
  800ff3:	74 5b                	je     801050 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800ff5:	83 ec 0c             	sub    $0xc,%esp
  800ff8:	68 05 08 00 00       	push   $0x805
  800ffd:	56                   	push   %esi
  800ffe:	57                   	push   %edi
  800fff:	56                   	push   %esi
  801000:	6a 00                	push   $0x0
  801002:	e8 fe fb ff ff       	call   800c05 <sys_page_map>
		if (r < 0) {
  801007:	83 c4 20             	add    $0x20,%esp
  80100a:	85 c0                	test   %eax,%eax
  80100c:	79 14                	jns    801022 <fork+0x139>
		    	panic("sys page map fault %e");
  80100e:	83 ec 04             	sub    $0x4,%esp
  801011:	68 6c 28 80 00       	push   $0x80286c
  801016:	6a 5c                	push   $0x5c
  801018:	68 3a 28 80 00       	push   $0x80283a
  80101d:	e8 ea 0f 00 00       	call   80200c <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  801022:	83 ec 0c             	sub    $0xc,%esp
  801025:	68 05 08 00 00       	push   $0x805
  80102a:	56                   	push   %esi
  80102b:	6a 00                	push   $0x0
  80102d:	56                   	push   %esi
  80102e:	6a 00                	push   $0x0
  801030:	e8 d0 fb ff ff       	call   800c05 <sys_page_map>
		if (r < 0) {
  801035:	83 c4 20             	add    $0x20,%esp
  801038:	85 c0                	test   %eax,%eax
  80103a:	79 3e                	jns    80107a <fork+0x191>
		    	panic("sys page map fault %e");
  80103c:	83 ec 04             	sub    $0x4,%esp
  80103f:	68 6c 28 80 00       	push   $0x80286c
  801044:	6a 60                	push   $0x60
  801046:	68 3a 28 80 00       	push   $0x80283a
  80104b:	e8 bc 0f 00 00       	call   80200c <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801050:	83 ec 0c             	sub    $0xc,%esp
  801053:	6a 05                	push   $0x5
  801055:	56                   	push   %esi
  801056:	57                   	push   %edi
  801057:	56                   	push   %esi
  801058:	6a 00                	push   $0x0
  80105a:	e8 a6 fb ff ff       	call   800c05 <sys_page_map>
		if (r < 0) {
  80105f:	83 c4 20             	add    $0x20,%esp
  801062:	85 c0                	test   %eax,%eax
  801064:	79 14                	jns    80107a <fork+0x191>
		    	panic("sys page map fault %e");
  801066:	83 ec 04             	sub    $0x4,%esp
  801069:	68 6c 28 80 00       	push   $0x80286c
  80106e:	6a 65                	push   $0x65
  801070:	68 3a 28 80 00       	push   $0x80283a
  801075:	e8 92 0f 00 00       	call   80200c <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80107a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801080:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801086:	0f 85 de fe ff ff    	jne    800f6a <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80108c:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801091:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  801097:	83 ec 08             	sub    $0x8,%esp
  80109a:	50                   	push   %eax
  80109b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80109e:	57                   	push   %edi
  80109f:	e8 69 fc ff ff       	call   800d0d <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8010a4:	83 c4 08             	add    $0x8,%esp
  8010a7:	6a 02                	push   $0x2
  8010a9:	57                   	push   %edi
  8010aa:	e8 da fb ff ff       	call   800c89 <sys_env_set_status>
	
	return envid;
  8010af:	83 c4 10             	add    $0x10,%esp
  8010b2:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8010b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b7:	5b                   	pop    %ebx
  8010b8:	5e                   	pop    %esi
  8010b9:	5f                   	pop    %edi
  8010ba:	5d                   	pop    %ebp
  8010bb:	c3                   	ret    

008010bc <sfork>:

envid_t
sfork(void)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
	return 0;
}
  8010bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c4:	5d                   	pop    %ebp
  8010c5:	c3                   	ret    

008010c6 <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  8010c6:	55                   	push   %ebp
  8010c7:	89 e5                	mov    %esp,%ebp
  8010c9:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  8010cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cf:	a3 10 40 80 00       	mov    %eax,0x804010
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8010d4:	68 6d 01 80 00       	push   $0x80016d
  8010d9:	e8 d5 fc ff ff       	call   800db3 <sys_thread_create>

	return id;
}
  8010de:	c9                   	leave  
  8010df:	c3                   	ret    

008010e0 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  8010e6:	ff 75 08             	pushl  0x8(%ebp)
  8010e9:	e8 e5 fc ff ff       	call   800dd3 <sys_thread_free>
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
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  8010f9:	ff 75 08             	pushl  0x8(%ebp)
  8010fc:	e8 f2 fc ff ff       	call   800df3 <sys_thread_join>
}
  801101:	83 c4 10             	add    $0x10,%esp
  801104:	c9                   	leave  
  801105:	c3                   	ret    

00801106 <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  801106:	55                   	push   %ebp
  801107:	89 e5                	mov    %esp,%ebp
  801109:	56                   	push   %esi
  80110a:	53                   	push   %ebx
  80110b:	8b 75 08             	mov    0x8(%ebp),%esi
  80110e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  801111:	83 ec 04             	sub    $0x4,%esp
  801114:	6a 07                	push   $0x7
  801116:	6a 00                	push   $0x0
  801118:	56                   	push   %esi
  801119:	e8 a4 fa ff ff       	call   800bc2 <sys_page_alloc>
	if (r < 0) {
  80111e:	83 c4 10             	add    $0x10,%esp
  801121:	85 c0                	test   %eax,%eax
  801123:	79 15                	jns    80113a <queue_append+0x34>
		panic("%e\n", r);
  801125:	50                   	push   %eax
  801126:	68 b2 28 80 00       	push   $0x8028b2
  80112b:	68 d5 00 00 00       	push   $0xd5
  801130:	68 3a 28 80 00       	push   $0x80283a
  801135:	e8 d2 0e 00 00       	call   80200c <_panic>
	}	

	wt->envid = envid;
  80113a:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  801140:	83 3b 00             	cmpl   $0x0,(%ebx)
  801143:	75 13                	jne    801158 <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  801145:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  80114c:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801153:	00 00 00 
  801156:	eb 1b                	jmp    801173 <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  801158:	8b 43 04             	mov    0x4(%ebx),%eax
  80115b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  801162:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801169:	00 00 00 
		queue->last = wt;
  80116c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801173:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801176:	5b                   	pop    %ebx
  801177:	5e                   	pop    %esi
  801178:	5d                   	pop    %ebp
  801179:	c3                   	ret    

0080117a <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  80117a:	55                   	push   %ebp
  80117b:	89 e5                	mov    %esp,%ebp
  80117d:	83 ec 08             	sub    $0x8,%esp
  801180:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  801183:	8b 02                	mov    (%edx),%eax
  801185:	85 c0                	test   %eax,%eax
  801187:	75 17                	jne    8011a0 <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  801189:	83 ec 04             	sub    $0x4,%esp
  80118c:	68 82 28 80 00       	push   $0x802882
  801191:	68 ec 00 00 00       	push   $0xec
  801196:	68 3a 28 80 00       	push   $0x80283a
  80119b:	e8 6c 0e 00 00       	call   80200c <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  8011a0:	8b 48 04             	mov    0x4(%eax),%ecx
  8011a3:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  8011a5:	8b 00                	mov    (%eax),%eax
}
  8011a7:	c9                   	leave  
  8011a8:	c3                   	ret    

008011a9 <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  8011a9:	55                   	push   %ebp
  8011aa:	89 e5                	mov    %esp,%ebp
  8011ac:	53                   	push   %ebx
  8011ad:	83 ec 04             	sub    $0x4,%esp
  8011b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  8011b3:	b8 01 00 00 00       	mov    $0x1,%eax
  8011b8:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  8011bb:	85 c0                	test   %eax,%eax
  8011bd:	74 45                	je     801204 <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  8011bf:	e8 c0 f9 ff ff       	call   800b84 <sys_getenvid>
  8011c4:	83 ec 08             	sub    $0x8,%esp
  8011c7:	83 c3 04             	add    $0x4,%ebx
  8011ca:	53                   	push   %ebx
  8011cb:	50                   	push   %eax
  8011cc:	e8 35 ff ff ff       	call   801106 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  8011d1:	e8 ae f9 ff ff       	call   800b84 <sys_getenvid>
  8011d6:	83 c4 08             	add    $0x8,%esp
  8011d9:	6a 04                	push   $0x4
  8011db:	50                   	push   %eax
  8011dc:	e8 a8 fa ff ff       	call   800c89 <sys_env_set_status>

		if (r < 0) {
  8011e1:	83 c4 10             	add    $0x10,%esp
  8011e4:	85 c0                	test   %eax,%eax
  8011e6:	79 15                	jns    8011fd <mutex_lock+0x54>
			panic("%e\n", r);
  8011e8:	50                   	push   %eax
  8011e9:	68 b2 28 80 00       	push   $0x8028b2
  8011ee:	68 02 01 00 00       	push   $0x102
  8011f3:	68 3a 28 80 00       	push   $0x80283a
  8011f8:	e8 0f 0e 00 00       	call   80200c <_panic>
		}
		sys_yield();
  8011fd:	e8 a1 f9 ff ff       	call   800ba3 <sys_yield>
  801202:	eb 08                	jmp    80120c <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  801204:	e8 7b f9 ff ff       	call   800b84 <sys_getenvid>
  801209:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80120c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80120f:	c9                   	leave  
  801210:	c3                   	ret    

00801211 <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
  801214:	53                   	push   %ebx
  801215:	83 ec 04             	sub    $0x4,%esp
  801218:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  80121b:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  80121f:	74 36                	je     801257 <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  801221:	83 ec 0c             	sub    $0xc,%esp
  801224:	8d 43 04             	lea    0x4(%ebx),%eax
  801227:	50                   	push   %eax
  801228:	e8 4d ff ff ff       	call   80117a <queue_pop>
  80122d:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  801230:	83 c4 08             	add    $0x8,%esp
  801233:	6a 02                	push   $0x2
  801235:	50                   	push   %eax
  801236:	e8 4e fa ff ff       	call   800c89 <sys_env_set_status>
		if (r < 0) {
  80123b:	83 c4 10             	add    $0x10,%esp
  80123e:	85 c0                	test   %eax,%eax
  801240:	79 1d                	jns    80125f <mutex_unlock+0x4e>
			panic("%e\n", r);
  801242:	50                   	push   %eax
  801243:	68 b2 28 80 00       	push   $0x8028b2
  801248:	68 16 01 00 00       	push   $0x116
  80124d:	68 3a 28 80 00       	push   $0x80283a
  801252:	e8 b5 0d 00 00       	call   80200c <_panic>
  801257:	b8 00 00 00 00       	mov    $0x0,%eax
  80125c:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  80125f:	e8 3f f9 ff ff       	call   800ba3 <sys_yield>
}
  801264:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801267:	c9                   	leave  
  801268:	c3                   	ret    

00801269 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  801269:	55                   	push   %ebp
  80126a:	89 e5                	mov    %esp,%ebp
  80126c:	53                   	push   %ebx
  80126d:	83 ec 04             	sub    $0x4,%esp
  801270:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  801273:	e8 0c f9 ff ff       	call   800b84 <sys_getenvid>
  801278:	83 ec 04             	sub    $0x4,%esp
  80127b:	6a 07                	push   $0x7
  80127d:	53                   	push   %ebx
  80127e:	50                   	push   %eax
  80127f:	e8 3e f9 ff ff       	call   800bc2 <sys_page_alloc>
  801284:	83 c4 10             	add    $0x10,%esp
  801287:	85 c0                	test   %eax,%eax
  801289:	79 15                	jns    8012a0 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  80128b:	50                   	push   %eax
  80128c:	68 9d 28 80 00       	push   $0x80289d
  801291:	68 23 01 00 00       	push   $0x123
  801296:	68 3a 28 80 00       	push   $0x80283a
  80129b:	e8 6c 0d 00 00       	call   80200c <_panic>
	}	
	mtx->locked = 0;
  8012a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  8012a6:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  8012ad:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  8012b4:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  8012bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012be:	c9                   	leave  
  8012bf:	c3                   	ret    

008012c0 <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  8012c0:	55                   	push   %ebp
  8012c1:	89 e5                	mov    %esp,%ebp
  8012c3:	56                   	push   %esi
  8012c4:	53                   	push   %ebx
  8012c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  8012c8:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  8012cb:	eb 20                	jmp    8012ed <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  8012cd:	83 ec 0c             	sub    $0xc,%esp
  8012d0:	56                   	push   %esi
  8012d1:	e8 a4 fe ff ff       	call   80117a <queue_pop>
  8012d6:	83 c4 08             	add    $0x8,%esp
  8012d9:	6a 02                	push   $0x2
  8012db:	50                   	push   %eax
  8012dc:	e8 a8 f9 ff ff       	call   800c89 <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  8012e1:	8b 43 04             	mov    0x4(%ebx),%eax
  8012e4:	8b 40 04             	mov    0x4(%eax),%eax
  8012e7:	89 43 04             	mov    %eax,0x4(%ebx)
  8012ea:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  8012ed:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8012f1:	75 da                	jne    8012cd <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  8012f3:	83 ec 04             	sub    $0x4,%esp
  8012f6:	68 00 10 00 00       	push   $0x1000
  8012fb:	6a 00                	push   $0x0
  8012fd:	53                   	push   %ebx
  8012fe:	e8 01 f6 ff ff       	call   800904 <memset>
	mtx = NULL;
}
  801303:	83 c4 10             	add    $0x10,%esp
  801306:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801309:	5b                   	pop    %ebx
  80130a:	5e                   	pop    %esi
  80130b:	5d                   	pop    %ebp
  80130c:	c3                   	ret    

0080130d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80130d:	55                   	push   %ebp
  80130e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801310:	8b 45 08             	mov    0x8(%ebp),%eax
  801313:	05 00 00 00 30       	add    $0x30000000,%eax
  801318:	c1 e8 0c             	shr    $0xc,%eax
}
  80131b:	5d                   	pop    %ebp
  80131c:	c3                   	ret    

0080131d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80131d:	55                   	push   %ebp
  80131e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801320:	8b 45 08             	mov    0x8(%ebp),%eax
  801323:	05 00 00 00 30       	add    $0x30000000,%eax
  801328:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80132d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801332:	5d                   	pop    %ebp
  801333:	c3                   	ret    

00801334 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801334:	55                   	push   %ebp
  801335:	89 e5                	mov    %esp,%ebp
  801337:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80133a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80133f:	89 c2                	mov    %eax,%edx
  801341:	c1 ea 16             	shr    $0x16,%edx
  801344:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80134b:	f6 c2 01             	test   $0x1,%dl
  80134e:	74 11                	je     801361 <fd_alloc+0x2d>
  801350:	89 c2                	mov    %eax,%edx
  801352:	c1 ea 0c             	shr    $0xc,%edx
  801355:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80135c:	f6 c2 01             	test   $0x1,%dl
  80135f:	75 09                	jne    80136a <fd_alloc+0x36>
			*fd_store = fd;
  801361:	89 01                	mov    %eax,(%ecx)
			return 0;
  801363:	b8 00 00 00 00       	mov    $0x0,%eax
  801368:	eb 17                	jmp    801381 <fd_alloc+0x4d>
  80136a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80136f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801374:	75 c9                	jne    80133f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801376:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80137c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801381:	5d                   	pop    %ebp
  801382:	c3                   	ret    

00801383 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801383:	55                   	push   %ebp
  801384:	89 e5                	mov    %esp,%ebp
  801386:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801389:	83 f8 1f             	cmp    $0x1f,%eax
  80138c:	77 36                	ja     8013c4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80138e:	c1 e0 0c             	shl    $0xc,%eax
  801391:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801396:	89 c2                	mov    %eax,%edx
  801398:	c1 ea 16             	shr    $0x16,%edx
  80139b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013a2:	f6 c2 01             	test   $0x1,%dl
  8013a5:	74 24                	je     8013cb <fd_lookup+0x48>
  8013a7:	89 c2                	mov    %eax,%edx
  8013a9:	c1 ea 0c             	shr    $0xc,%edx
  8013ac:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013b3:	f6 c2 01             	test   $0x1,%dl
  8013b6:	74 1a                	je     8013d2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013bb:	89 02                	mov    %eax,(%edx)
	return 0;
  8013bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c2:	eb 13                	jmp    8013d7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013c9:	eb 0c                	jmp    8013d7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013d0:	eb 05                	jmp    8013d7 <fd_lookup+0x54>
  8013d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013d7:	5d                   	pop    %ebp
  8013d8:	c3                   	ret    

008013d9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013d9:	55                   	push   %ebp
  8013da:	89 e5                	mov    %esp,%ebp
  8013dc:	83 ec 08             	sub    $0x8,%esp
  8013df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013e2:	ba 34 29 80 00       	mov    $0x802934,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013e7:	eb 13                	jmp    8013fc <dev_lookup+0x23>
  8013e9:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013ec:	39 08                	cmp    %ecx,(%eax)
  8013ee:	75 0c                	jne    8013fc <dev_lookup+0x23>
			*dev = devtab[i];
  8013f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013f3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8013fa:	eb 31                	jmp    80142d <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013fc:	8b 02                	mov    (%edx),%eax
  8013fe:	85 c0                	test   %eax,%eax
  801400:	75 e7                	jne    8013e9 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801402:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801407:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80140d:	83 ec 04             	sub    $0x4,%esp
  801410:	51                   	push   %ecx
  801411:	50                   	push   %eax
  801412:	68 b8 28 80 00       	push   $0x8028b8
  801417:	e8 1e ee ff ff       	call   80023a <cprintf>
	*dev = 0;
  80141c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80141f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801425:	83 c4 10             	add    $0x10,%esp
  801428:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80142d:	c9                   	leave  
  80142e:	c3                   	ret    

0080142f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80142f:	55                   	push   %ebp
  801430:	89 e5                	mov    %esp,%ebp
  801432:	56                   	push   %esi
  801433:	53                   	push   %ebx
  801434:	83 ec 10             	sub    $0x10,%esp
  801437:	8b 75 08             	mov    0x8(%ebp),%esi
  80143a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80143d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801440:	50                   	push   %eax
  801441:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801447:	c1 e8 0c             	shr    $0xc,%eax
  80144a:	50                   	push   %eax
  80144b:	e8 33 ff ff ff       	call   801383 <fd_lookup>
  801450:	83 c4 08             	add    $0x8,%esp
  801453:	85 c0                	test   %eax,%eax
  801455:	78 05                	js     80145c <fd_close+0x2d>
	    || fd != fd2)
  801457:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80145a:	74 0c                	je     801468 <fd_close+0x39>
		return (must_exist ? r : 0);
  80145c:	84 db                	test   %bl,%bl
  80145e:	ba 00 00 00 00       	mov    $0x0,%edx
  801463:	0f 44 c2             	cmove  %edx,%eax
  801466:	eb 41                	jmp    8014a9 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801468:	83 ec 08             	sub    $0x8,%esp
  80146b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80146e:	50                   	push   %eax
  80146f:	ff 36                	pushl  (%esi)
  801471:	e8 63 ff ff ff       	call   8013d9 <dev_lookup>
  801476:	89 c3                	mov    %eax,%ebx
  801478:	83 c4 10             	add    $0x10,%esp
  80147b:	85 c0                	test   %eax,%eax
  80147d:	78 1a                	js     801499 <fd_close+0x6a>
		if (dev->dev_close)
  80147f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801482:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801485:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80148a:	85 c0                	test   %eax,%eax
  80148c:	74 0b                	je     801499 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80148e:	83 ec 0c             	sub    $0xc,%esp
  801491:	56                   	push   %esi
  801492:	ff d0                	call   *%eax
  801494:	89 c3                	mov    %eax,%ebx
  801496:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801499:	83 ec 08             	sub    $0x8,%esp
  80149c:	56                   	push   %esi
  80149d:	6a 00                	push   $0x0
  80149f:	e8 a3 f7 ff ff       	call   800c47 <sys_page_unmap>
	return r;
  8014a4:	83 c4 10             	add    $0x10,%esp
  8014a7:	89 d8                	mov    %ebx,%eax
}
  8014a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ac:	5b                   	pop    %ebx
  8014ad:	5e                   	pop    %esi
  8014ae:	5d                   	pop    %ebp
  8014af:	c3                   	ret    

008014b0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014b0:	55                   	push   %ebp
  8014b1:	89 e5                	mov    %esp,%ebp
  8014b3:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b9:	50                   	push   %eax
  8014ba:	ff 75 08             	pushl  0x8(%ebp)
  8014bd:	e8 c1 fe ff ff       	call   801383 <fd_lookup>
  8014c2:	83 c4 08             	add    $0x8,%esp
  8014c5:	85 c0                	test   %eax,%eax
  8014c7:	78 10                	js     8014d9 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014c9:	83 ec 08             	sub    $0x8,%esp
  8014cc:	6a 01                	push   $0x1
  8014ce:	ff 75 f4             	pushl  -0xc(%ebp)
  8014d1:	e8 59 ff ff ff       	call   80142f <fd_close>
  8014d6:	83 c4 10             	add    $0x10,%esp
}
  8014d9:	c9                   	leave  
  8014da:	c3                   	ret    

008014db <close_all>:

void
close_all(void)
{
  8014db:	55                   	push   %ebp
  8014dc:	89 e5                	mov    %esp,%ebp
  8014de:	53                   	push   %ebx
  8014df:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014e2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014e7:	83 ec 0c             	sub    $0xc,%esp
  8014ea:	53                   	push   %ebx
  8014eb:	e8 c0 ff ff ff       	call   8014b0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014f0:	83 c3 01             	add    $0x1,%ebx
  8014f3:	83 c4 10             	add    $0x10,%esp
  8014f6:	83 fb 20             	cmp    $0x20,%ebx
  8014f9:	75 ec                	jne    8014e7 <close_all+0xc>
		close(i);
}
  8014fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014fe:	c9                   	leave  
  8014ff:	c3                   	ret    

00801500 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801500:	55                   	push   %ebp
  801501:	89 e5                	mov    %esp,%ebp
  801503:	57                   	push   %edi
  801504:	56                   	push   %esi
  801505:	53                   	push   %ebx
  801506:	83 ec 2c             	sub    $0x2c,%esp
  801509:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80150c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80150f:	50                   	push   %eax
  801510:	ff 75 08             	pushl  0x8(%ebp)
  801513:	e8 6b fe ff ff       	call   801383 <fd_lookup>
  801518:	83 c4 08             	add    $0x8,%esp
  80151b:	85 c0                	test   %eax,%eax
  80151d:	0f 88 c1 00 00 00    	js     8015e4 <dup+0xe4>
		return r;
	close(newfdnum);
  801523:	83 ec 0c             	sub    $0xc,%esp
  801526:	56                   	push   %esi
  801527:	e8 84 ff ff ff       	call   8014b0 <close>

	newfd = INDEX2FD(newfdnum);
  80152c:	89 f3                	mov    %esi,%ebx
  80152e:	c1 e3 0c             	shl    $0xc,%ebx
  801531:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801537:	83 c4 04             	add    $0x4,%esp
  80153a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80153d:	e8 db fd ff ff       	call   80131d <fd2data>
  801542:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801544:	89 1c 24             	mov    %ebx,(%esp)
  801547:	e8 d1 fd ff ff       	call   80131d <fd2data>
  80154c:	83 c4 10             	add    $0x10,%esp
  80154f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801552:	89 f8                	mov    %edi,%eax
  801554:	c1 e8 16             	shr    $0x16,%eax
  801557:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80155e:	a8 01                	test   $0x1,%al
  801560:	74 37                	je     801599 <dup+0x99>
  801562:	89 f8                	mov    %edi,%eax
  801564:	c1 e8 0c             	shr    $0xc,%eax
  801567:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80156e:	f6 c2 01             	test   $0x1,%dl
  801571:	74 26                	je     801599 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801573:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80157a:	83 ec 0c             	sub    $0xc,%esp
  80157d:	25 07 0e 00 00       	and    $0xe07,%eax
  801582:	50                   	push   %eax
  801583:	ff 75 d4             	pushl  -0x2c(%ebp)
  801586:	6a 00                	push   $0x0
  801588:	57                   	push   %edi
  801589:	6a 00                	push   $0x0
  80158b:	e8 75 f6 ff ff       	call   800c05 <sys_page_map>
  801590:	89 c7                	mov    %eax,%edi
  801592:	83 c4 20             	add    $0x20,%esp
  801595:	85 c0                	test   %eax,%eax
  801597:	78 2e                	js     8015c7 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801599:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80159c:	89 d0                	mov    %edx,%eax
  80159e:	c1 e8 0c             	shr    $0xc,%eax
  8015a1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015a8:	83 ec 0c             	sub    $0xc,%esp
  8015ab:	25 07 0e 00 00       	and    $0xe07,%eax
  8015b0:	50                   	push   %eax
  8015b1:	53                   	push   %ebx
  8015b2:	6a 00                	push   $0x0
  8015b4:	52                   	push   %edx
  8015b5:	6a 00                	push   $0x0
  8015b7:	e8 49 f6 ff ff       	call   800c05 <sys_page_map>
  8015bc:	89 c7                	mov    %eax,%edi
  8015be:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8015c1:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015c3:	85 ff                	test   %edi,%edi
  8015c5:	79 1d                	jns    8015e4 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015c7:	83 ec 08             	sub    $0x8,%esp
  8015ca:	53                   	push   %ebx
  8015cb:	6a 00                	push   $0x0
  8015cd:	e8 75 f6 ff ff       	call   800c47 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015d2:	83 c4 08             	add    $0x8,%esp
  8015d5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015d8:	6a 00                	push   $0x0
  8015da:	e8 68 f6 ff ff       	call   800c47 <sys_page_unmap>
	return r;
  8015df:	83 c4 10             	add    $0x10,%esp
  8015e2:	89 f8                	mov    %edi,%eax
}
  8015e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015e7:	5b                   	pop    %ebx
  8015e8:	5e                   	pop    %esi
  8015e9:	5f                   	pop    %edi
  8015ea:	5d                   	pop    %ebp
  8015eb:	c3                   	ret    

008015ec <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
  8015ef:	53                   	push   %ebx
  8015f0:	83 ec 14             	sub    $0x14,%esp
  8015f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f9:	50                   	push   %eax
  8015fa:	53                   	push   %ebx
  8015fb:	e8 83 fd ff ff       	call   801383 <fd_lookup>
  801600:	83 c4 08             	add    $0x8,%esp
  801603:	89 c2                	mov    %eax,%edx
  801605:	85 c0                	test   %eax,%eax
  801607:	78 70                	js     801679 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801609:	83 ec 08             	sub    $0x8,%esp
  80160c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160f:	50                   	push   %eax
  801610:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801613:	ff 30                	pushl  (%eax)
  801615:	e8 bf fd ff ff       	call   8013d9 <dev_lookup>
  80161a:	83 c4 10             	add    $0x10,%esp
  80161d:	85 c0                	test   %eax,%eax
  80161f:	78 4f                	js     801670 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801621:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801624:	8b 42 08             	mov    0x8(%edx),%eax
  801627:	83 e0 03             	and    $0x3,%eax
  80162a:	83 f8 01             	cmp    $0x1,%eax
  80162d:	75 24                	jne    801653 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80162f:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801634:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80163a:	83 ec 04             	sub    $0x4,%esp
  80163d:	53                   	push   %ebx
  80163e:	50                   	push   %eax
  80163f:	68 f9 28 80 00       	push   $0x8028f9
  801644:	e8 f1 eb ff ff       	call   80023a <cprintf>
		return -E_INVAL;
  801649:	83 c4 10             	add    $0x10,%esp
  80164c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801651:	eb 26                	jmp    801679 <read+0x8d>
	}
	if (!dev->dev_read)
  801653:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801656:	8b 40 08             	mov    0x8(%eax),%eax
  801659:	85 c0                	test   %eax,%eax
  80165b:	74 17                	je     801674 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80165d:	83 ec 04             	sub    $0x4,%esp
  801660:	ff 75 10             	pushl  0x10(%ebp)
  801663:	ff 75 0c             	pushl  0xc(%ebp)
  801666:	52                   	push   %edx
  801667:	ff d0                	call   *%eax
  801669:	89 c2                	mov    %eax,%edx
  80166b:	83 c4 10             	add    $0x10,%esp
  80166e:	eb 09                	jmp    801679 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801670:	89 c2                	mov    %eax,%edx
  801672:	eb 05                	jmp    801679 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801674:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801679:	89 d0                	mov    %edx,%eax
  80167b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167e:	c9                   	leave  
  80167f:	c3                   	ret    

00801680 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
  801683:	57                   	push   %edi
  801684:	56                   	push   %esi
  801685:	53                   	push   %ebx
  801686:	83 ec 0c             	sub    $0xc,%esp
  801689:	8b 7d 08             	mov    0x8(%ebp),%edi
  80168c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80168f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801694:	eb 21                	jmp    8016b7 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801696:	83 ec 04             	sub    $0x4,%esp
  801699:	89 f0                	mov    %esi,%eax
  80169b:	29 d8                	sub    %ebx,%eax
  80169d:	50                   	push   %eax
  80169e:	89 d8                	mov    %ebx,%eax
  8016a0:	03 45 0c             	add    0xc(%ebp),%eax
  8016a3:	50                   	push   %eax
  8016a4:	57                   	push   %edi
  8016a5:	e8 42 ff ff ff       	call   8015ec <read>
		if (m < 0)
  8016aa:	83 c4 10             	add    $0x10,%esp
  8016ad:	85 c0                	test   %eax,%eax
  8016af:	78 10                	js     8016c1 <readn+0x41>
			return m;
		if (m == 0)
  8016b1:	85 c0                	test   %eax,%eax
  8016b3:	74 0a                	je     8016bf <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016b5:	01 c3                	add    %eax,%ebx
  8016b7:	39 f3                	cmp    %esi,%ebx
  8016b9:	72 db                	jb     801696 <readn+0x16>
  8016bb:	89 d8                	mov    %ebx,%eax
  8016bd:	eb 02                	jmp    8016c1 <readn+0x41>
  8016bf:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8016c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c4:	5b                   	pop    %ebx
  8016c5:	5e                   	pop    %esi
  8016c6:	5f                   	pop    %edi
  8016c7:	5d                   	pop    %ebp
  8016c8:	c3                   	ret    

008016c9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016c9:	55                   	push   %ebp
  8016ca:	89 e5                	mov    %esp,%ebp
  8016cc:	53                   	push   %ebx
  8016cd:	83 ec 14             	sub    $0x14,%esp
  8016d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d6:	50                   	push   %eax
  8016d7:	53                   	push   %ebx
  8016d8:	e8 a6 fc ff ff       	call   801383 <fd_lookup>
  8016dd:	83 c4 08             	add    $0x8,%esp
  8016e0:	89 c2                	mov    %eax,%edx
  8016e2:	85 c0                	test   %eax,%eax
  8016e4:	78 6b                	js     801751 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e6:	83 ec 08             	sub    $0x8,%esp
  8016e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ec:	50                   	push   %eax
  8016ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f0:	ff 30                	pushl  (%eax)
  8016f2:	e8 e2 fc ff ff       	call   8013d9 <dev_lookup>
  8016f7:	83 c4 10             	add    $0x10,%esp
  8016fa:	85 c0                	test   %eax,%eax
  8016fc:	78 4a                	js     801748 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801701:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801705:	75 24                	jne    80172b <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801707:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80170c:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801712:	83 ec 04             	sub    $0x4,%esp
  801715:	53                   	push   %ebx
  801716:	50                   	push   %eax
  801717:	68 15 29 80 00       	push   $0x802915
  80171c:	e8 19 eb ff ff       	call   80023a <cprintf>
		return -E_INVAL;
  801721:	83 c4 10             	add    $0x10,%esp
  801724:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801729:	eb 26                	jmp    801751 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80172b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80172e:	8b 52 0c             	mov    0xc(%edx),%edx
  801731:	85 d2                	test   %edx,%edx
  801733:	74 17                	je     80174c <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801735:	83 ec 04             	sub    $0x4,%esp
  801738:	ff 75 10             	pushl  0x10(%ebp)
  80173b:	ff 75 0c             	pushl  0xc(%ebp)
  80173e:	50                   	push   %eax
  80173f:	ff d2                	call   *%edx
  801741:	89 c2                	mov    %eax,%edx
  801743:	83 c4 10             	add    $0x10,%esp
  801746:	eb 09                	jmp    801751 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801748:	89 c2                	mov    %eax,%edx
  80174a:	eb 05                	jmp    801751 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80174c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801751:	89 d0                	mov    %edx,%eax
  801753:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801756:	c9                   	leave  
  801757:	c3                   	ret    

00801758 <seek>:

int
seek(int fdnum, off_t offset)
{
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80175e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801761:	50                   	push   %eax
  801762:	ff 75 08             	pushl  0x8(%ebp)
  801765:	e8 19 fc ff ff       	call   801383 <fd_lookup>
  80176a:	83 c4 08             	add    $0x8,%esp
  80176d:	85 c0                	test   %eax,%eax
  80176f:	78 0e                	js     80177f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801771:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801774:	8b 55 0c             	mov    0xc(%ebp),%edx
  801777:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80177a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80177f:	c9                   	leave  
  801780:	c3                   	ret    

00801781 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
  801784:	53                   	push   %ebx
  801785:	83 ec 14             	sub    $0x14,%esp
  801788:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80178b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80178e:	50                   	push   %eax
  80178f:	53                   	push   %ebx
  801790:	e8 ee fb ff ff       	call   801383 <fd_lookup>
  801795:	83 c4 08             	add    $0x8,%esp
  801798:	89 c2                	mov    %eax,%edx
  80179a:	85 c0                	test   %eax,%eax
  80179c:	78 68                	js     801806 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179e:	83 ec 08             	sub    $0x8,%esp
  8017a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a4:	50                   	push   %eax
  8017a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a8:	ff 30                	pushl  (%eax)
  8017aa:	e8 2a fc ff ff       	call   8013d9 <dev_lookup>
  8017af:	83 c4 10             	add    $0x10,%esp
  8017b2:	85 c0                	test   %eax,%eax
  8017b4:	78 47                	js     8017fd <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017bd:	75 24                	jne    8017e3 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017bf:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017c4:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8017ca:	83 ec 04             	sub    $0x4,%esp
  8017cd:	53                   	push   %ebx
  8017ce:	50                   	push   %eax
  8017cf:	68 d8 28 80 00       	push   $0x8028d8
  8017d4:	e8 61 ea ff ff       	call   80023a <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017d9:	83 c4 10             	add    $0x10,%esp
  8017dc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017e1:	eb 23                	jmp    801806 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  8017e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017e6:	8b 52 18             	mov    0x18(%edx),%edx
  8017e9:	85 d2                	test   %edx,%edx
  8017eb:	74 14                	je     801801 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017ed:	83 ec 08             	sub    $0x8,%esp
  8017f0:	ff 75 0c             	pushl  0xc(%ebp)
  8017f3:	50                   	push   %eax
  8017f4:	ff d2                	call   *%edx
  8017f6:	89 c2                	mov    %eax,%edx
  8017f8:	83 c4 10             	add    $0x10,%esp
  8017fb:	eb 09                	jmp    801806 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017fd:	89 c2                	mov    %eax,%edx
  8017ff:	eb 05                	jmp    801806 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801801:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801806:	89 d0                	mov    %edx,%eax
  801808:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180b:	c9                   	leave  
  80180c:	c3                   	ret    

0080180d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80180d:	55                   	push   %ebp
  80180e:	89 e5                	mov    %esp,%ebp
  801810:	53                   	push   %ebx
  801811:	83 ec 14             	sub    $0x14,%esp
  801814:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801817:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80181a:	50                   	push   %eax
  80181b:	ff 75 08             	pushl  0x8(%ebp)
  80181e:	e8 60 fb ff ff       	call   801383 <fd_lookup>
  801823:	83 c4 08             	add    $0x8,%esp
  801826:	89 c2                	mov    %eax,%edx
  801828:	85 c0                	test   %eax,%eax
  80182a:	78 58                	js     801884 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80182c:	83 ec 08             	sub    $0x8,%esp
  80182f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801832:	50                   	push   %eax
  801833:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801836:	ff 30                	pushl  (%eax)
  801838:	e8 9c fb ff ff       	call   8013d9 <dev_lookup>
  80183d:	83 c4 10             	add    $0x10,%esp
  801840:	85 c0                	test   %eax,%eax
  801842:	78 37                	js     80187b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801844:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801847:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80184b:	74 32                	je     80187f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80184d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801850:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801857:	00 00 00 
	stat->st_isdir = 0;
  80185a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801861:	00 00 00 
	stat->st_dev = dev;
  801864:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80186a:	83 ec 08             	sub    $0x8,%esp
  80186d:	53                   	push   %ebx
  80186e:	ff 75 f0             	pushl  -0x10(%ebp)
  801871:	ff 50 14             	call   *0x14(%eax)
  801874:	89 c2                	mov    %eax,%edx
  801876:	83 c4 10             	add    $0x10,%esp
  801879:	eb 09                	jmp    801884 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80187b:	89 c2                	mov    %eax,%edx
  80187d:	eb 05                	jmp    801884 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80187f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801884:	89 d0                	mov    %edx,%eax
  801886:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801889:	c9                   	leave  
  80188a:	c3                   	ret    

0080188b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80188b:	55                   	push   %ebp
  80188c:	89 e5                	mov    %esp,%ebp
  80188e:	56                   	push   %esi
  80188f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801890:	83 ec 08             	sub    $0x8,%esp
  801893:	6a 00                	push   $0x0
  801895:	ff 75 08             	pushl  0x8(%ebp)
  801898:	e8 e3 01 00 00       	call   801a80 <open>
  80189d:	89 c3                	mov    %eax,%ebx
  80189f:	83 c4 10             	add    $0x10,%esp
  8018a2:	85 c0                	test   %eax,%eax
  8018a4:	78 1b                	js     8018c1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018a6:	83 ec 08             	sub    $0x8,%esp
  8018a9:	ff 75 0c             	pushl  0xc(%ebp)
  8018ac:	50                   	push   %eax
  8018ad:	e8 5b ff ff ff       	call   80180d <fstat>
  8018b2:	89 c6                	mov    %eax,%esi
	close(fd);
  8018b4:	89 1c 24             	mov    %ebx,(%esp)
  8018b7:	e8 f4 fb ff ff       	call   8014b0 <close>
	return r;
  8018bc:	83 c4 10             	add    $0x10,%esp
  8018bf:	89 f0                	mov    %esi,%eax
}
  8018c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c4:	5b                   	pop    %ebx
  8018c5:	5e                   	pop    %esi
  8018c6:	5d                   	pop    %ebp
  8018c7:	c3                   	ret    

008018c8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	56                   	push   %esi
  8018cc:	53                   	push   %ebx
  8018cd:	89 c6                	mov    %eax,%esi
  8018cf:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018d1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018d8:	75 12                	jne    8018ec <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018da:	83 ec 0c             	sub    $0xc,%esp
  8018dd:	6a 01                	push   $0x1
  8018df:	e8 da 08 00 00       	call   8021be <ipc_find_env>
  8018e4:	a3 00 40 80 00       	mov    %eax,0x804000
  8018e9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018ec:	6a 07                	push   $0x7
  8018ee:	68 00 50 80 00       	push   $0x805000
  8018f3:	56                   	push   %esi
  8018f4:	ff 35 00 40 80 00    	pushl  0x804000
  8018fa:	e8 5d 08 00 00       	call   80215c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018ff:	83 c4 0c             	add    $0xc,%esp
  801902:	6a 00                	push   $0x0
  801904:	53                   	push   %ebx
  801905:	6a 00                	push   $0x0
  801907:	e8 d5 07 00 00       	call   8020e1 <ipc_recv>
}
  80190c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80190f:	5b                   	pop    %ebx
  801910:	5e                   	pop    %esi
  801911:	5d                   	pop    %ebp
  801912:	c3                   	ret    

00801913 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801913:	55                   	push   %ebp
  801914:	89 e5                	mov    %esp,%ebp
  801916:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801919:	8b 45 08             	mov    0x8(%ebp),%eax
  80191c:	8b 40 0c             	mov    0xc(%eax),%eax
  80191f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801924:	8b 45 0c             	mov    0xc(%ebp),%eax
  801927:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80192c:	ba 00 00 00 00       	mov    $0x0,%edx
  801931:	b8 02 00 00 00       	mov    $0x2,%eax
  801936:	e8 8d ff ff ff       	call   8018c8 <fsipc>
}
  80193b:	c9                   	leave  
  80193c:	c3                   	ret    

0080193d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80193d:	55                   	push   %ebp
  80193e:	89 e5                	mov    %esp,%ebp
  801940:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801943:	8b 45 08             	mov    0x8(%ebp),%eax
  801946:	8b 40 0c             	mov    0xc(%eax),%eax
  801949:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80194e:	ba 00 00 00 00       	mov    $0x0,%edx
  801953:	b8 06 00 00 00       	mov    $0x6,%eax
  801958:	e8 6b ff ff ff       	call   8018c8 <fsipc>
}
  80195d:	c9                   	leave  
  80195e:	c3                   	ret    

0080195f <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80195f:	55                   	push   %ebp
  801960:	89 e5                	mov    %esp,%ebp
  801962:	53                   	push   %ebx
  801963:	83 ec 04             	sub    $0x4,%esp
  801966:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801969:	8b 45 08             	mov    0x8(%ebp),%eax
  80196c:	8b 40 0c             	mov    0xc(%eax),%eax
  80196f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801974:	ba 00 00 00 00       	mov    $0x0,%edx
  801979:	b8 05 00 00 00       	mov    $0x5,%eax
  80197e:	e8 45 ff ff ff       	call   8018c8 <fsipc>
  801983:	85 c0                	test   %eax,%eax
  801985:	78 2c                	js     8019b3 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801987:	83 ec 08             	sub    $0x8,%esp
  80198a:	68 00 50 80 00       	push   $0x805000
  80198f:	53                   	push   %ebx
  801990:	e8 2a ee ff ff       	call   8007bf <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801995:	a1 80 50 80 00       	mov    0x805080,%eax
  80199a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019a0:	a1 84 50 80 00       	mov    0x805084,%eax
  8019a5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019ab:	83 c4 10             	add    $0x10,%esp
  8019ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b6:	c9                   	leave  
  8019b7:	c3                   	ret    

008019b8 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019b8:	55                   	push   %ebp
  8019b9:	89 e5                	mov    %esp,%ebp
  8019bb:	83 ec 0c             	sub    $0xc,%esp
  8019be:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8019c4:	8b 52 0c             	mov    0xc(%edx),%edx
  8019c7:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8019cd:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8019d2:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8019d7:	0f 47 c2             	cmova  %edx,%eax
  8019da:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8019df:	50                   	push   %eax
  8019e0:	ff 75 0c             	pushl  0xc(%ebp)
  8019e3:	68 08 50 80 00       	push   $0x805008
  8019e8:	e8 64 ef ff ff       	call   800951 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8019ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f2:	b8 04 00 00 00       	mov    $0x4,%eax
  8019f7:	e8 cc fe ff ff       	call   8018c8 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8019fc:	c9                   	leave  
  8019fd:	c3                   	ret    

008019fe <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019fe:	55                   	push   %ebp
  8019ff:	89 e5                	mov    %esp,%ebp
  801a01:	56                   	push   %esi
  801a02:	53                   	push   %ebx
  801a03:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a06:	8b 45 08             	mov    0x8(%ebp),%eax
  801a09:	8b 40 0c             	mov    0xc(%eax),%eax
  801a0c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a11:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a17:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1c:	b8 03 00 00 00       	mov    $0x3,%eax
  801a21:	e8 a2 fe ff ff       	call   8018c8 <fsipc>
  801a26:	89 c3                	mov    %eax,%ebx
  801a28:	85 c0                	test   %eax,%eax
  801a2a:	78 4b                	js     801a77 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a2c:	39 c6                	cmp    %eax,%esi
  801a2e:	73 16                	jae    801a46 <devfile_read+0x48>
  801a30:	68 44 29 80 00       	push   $0x802944
  801a35:	68 4b 29 80 00       	push   $0x80294b
  801a3a:	6a 7c                	push   $0x7c
  801a3c:	68 60 29 80 00       	push   $0x802960
  801a41:	e8 c6 05 00 00       	call   80200c <_panic>
	assert(r <= PGSIZE);
  801a46:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a4b:	7e 16                	jle    801a63 <devfile_read+0x65>
  801a4d:	68 6b 29 80 00       	push   $0x80296b
  801a52:	68 4b 29 80 00       	push   $0x80294b
  801a57:	6a 7d                	push   $0x7d
  801a59:	68 60 29 80 00       	push   $0x802960
  801a5e:	e8 a9 05 00 00       	call   80200c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a63:	83 ec 04             	sub    $0x4,%esp
  801a66:	50                   	push   %eax
  801a67:	68 00 50 80 00       	push   $0x805000
  801a6c:	ff 75 0c             	pushl  0xc(%ebp)
  801a6f:	e8 dd ee ff ff       	call   800951 <memmove>
	return r;
  801a74:	83 c4 10             	add    $0x10,%esp
}
  801a77:	89 d8                	mov    %ebx,%eax
  801a79:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7c:	5b                   	pop    %ebx
  801a7d:	5e                   	pop    %esi
  801a7e:	5d                   	pop    %ebp
  801a7f:	c3                   	ret    

00801a80 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	53                   	push   %ebx
  801a84:	83 ec 20             	sub    $0x20,%esp
  801a87:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a8a:	53                   	push   %ebx
  801a8b:	e8 f6 ec ff ff       	call   800786 <strlen>
  801a90:	83 c4 10             	add    $0x10,%esp
  801a93:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a98:	7f 67                	jg     801b01 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a9a:	83 ec 0c             	sub    $0xc,%esp
  801a9d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa0:	50                   	push   %eax
  801aa1:	e8 8e f8 ff ff       	call   801334 <fd_alloc>
  801aa6:	83 c4 10             	add    $0x10,%esp
		return r;
  801aa9:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801aab:	85 c0                	test   %eax,%eax
  801aad:	78 57                	js     801b06 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801aaf:	83 ec 08             	sub    $0x8,%esp
  801ab2:	53                   	push   %ebx
  801ab3:	68 00 50 80 00       	push   $0x805000
  801ab8:	e8 02 ed ff ff       	call   8007bf <strcpy>
	fsipcbuf.open.req_omode = mode;
  801abd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac0:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ac5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ac8:	b8 01 00 00 00       	mov    $0x1,%eax
  801acd:	e8 f6 fd ff ff       	call   8018c8 <fsipc>
  801ad2:	89 c3                	mov    %eax,%ebx
  801ad4:	83 c4 10             	add    $0x10,%esp
  801ad7:	85 c0                	test   %eax,%eax
  801ad9:	79 14                	jns    801aef <open+0x6f>
		fd_close(fd, 0);
  801adb:	83 ec 08             	sub    $0x8,%esp
  801ade:	6a 00                	push   $0x0
  801ae0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae3:	e8 47 f9 ff ff       	call   80142f <fd_close>
		return r;
  801ae8:	83 c4 10             	add    $0x10,%esp
  801aeb:	89 da                	mov    %ebx,%edx
  801aed:	eb 17                	jmp    801b06 <open+0x86>
	}

	return fd2num(fd);
  801aef:	83 ec 0c             	sub    $0xc,%esp
  801af2:	ff 75 f4             	pushl  -0xc(%ebp)
  801af5:	e8 13 f8 ff ff       	call   80130d <fd2num>
  801afa:	89 c2                	mov    %eax,%edx
  801afc:	83 c4 10             	add    $0x10,%esp
  801aff:	eb 05                	jmp    801b06 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b01:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b06:	89 d0                	mov    %edx,%eax
  801b08:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b0b:	c9                   	leave  
  801b0c:	c3                   	ret    

00801b0d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b0d:	55                   	push   %ebp
  801b0e:	89 e5                	mov    %esp,%ebp
  801b10:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b13:	ba 00 00 00 00       	mov    $0x0,%edx
  801b18:	b8 08 00 00 00       	mov    $0x8,%eax
  801b1d:	e8 a6 fd ff ff       	call   8018c8 <fsipc>
}
  801b22:	c9                   	leave  
  801b23:	c3                   	ret    

00801b24 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	56                   	push   %esi
  801b28:	53                   	push   %ebx
  801b29:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b2c:	83 ec 0c             	sub    $0xc,%esp
  801b2f:	ff 75 08             	pushl  0x8(%ebp)
  801b32:	e8 e6 f7 ff ff       	call   80131d <fd2data>
  801b37:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b39:	83 c4 08             	add    $0x8,%esp
  801b3c:	68 77 29 80 00       	push   $0x802977
  801b41:	53                   	push   %ebx
  801b42:	e8 78 ec ff ff       	call   8007bf <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b47:	8b 46 04             	mov    0x4(%esi),%eax
  801b4a:	2b 06                	sub    (%esi),%eax
  801b4c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b52:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b59:	00 00 00 
	stat->st_dev = &devpipe;
  801b5c:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b63:	30 80 00 
	return 0;
}
  801b66:	b8 00 00 00 00       	mov    $0x0,%eax
  801b6b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b6e:	5b                   	pop    %ebx
  801b6f:	5e                   	pop    %esi
  801b70:	5d                   	pop    %ebp
  801b71:	c3                   	ret    

00801b72 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b72:	55                   	push   %ebp
  801b73:	89 e5                	mov    %esp,%ebp
  801b75:	53                   	push   %ebx
  801b76:	83 ec 0c             	sub    $0xc,%esp
  801b79:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b7c:	53                   	push   %ebx
  801b7d:	6a 00                	push   $0x0
  801b7f:	e8 c3 f0 ff ff       	call   800c47 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b84:	89 1c 24             	mov    %ebx,(%esp)
  801b87:	e8 91 f7 ff ff       	call   80131d <fd2data>
  801b8c:	83 c4 08             	add    $0x8,%esp
  801b8f:	50                   	push   %eax
  801b90:	6a 00                	push   $0x0
  801b92:	e8 b0 f0 ff ff       	call   800c47 <sys_page_unmap>
}
  801b97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b9a:	c9                   	leave  
  801b9b:	c3                   	ret    

00801b9c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b9c:	55                   	push   %ebp
  801b9d:	89 e5                	mov    %esp,%ebp
  801b9f:	57                   	push   %edi
  801ba0:	56                   	push   %esi
  801ba1:	53                   	push   %ebx
  801ba2:	83 ec 1c             	sub    $0x1c,%esp
  801ba5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ba8:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801baa:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801baf:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bb5:	83 ec 0c             	sub    $0xc,%esp
  801bb8:	ff 75 e0             	pushl  -0x20(%ebp)
  801bbb:	e8 43 06 00 00       	call   802203 <pageref>
  801bc0:	89 c3                	mov    %eax,%ebx
  801bc2:	89 3c 24             	mov    %edi,(%esp)
  801bc5:	e8 39 06 00 00       	call   802203 <pageref>
  801bca:	83 c4 10             	add    $0x10,%esp
  801bcd:	39 c3                	cmp    %eax,%ebx
  801bcf:	0f 94 c1             	sete   %cl
  801bd2:	0f b6 c9             	movzbl %cl,%ecx
  801bd5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801bd8:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801bde:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  801be4:	39 ce                	cmp    %ecx,%esi
  801be6:	74 1e                	je     801c06 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801be8:	39 c3                	cmp    %eax,%ebx
  801bea:	75 be                	jne    801baa <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bec:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  801bf2:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bf5:	50                   	push   %eax
  801bf6:	56                   	push   %esi
  801bf7:	68 7e 29 80 00       	push   $0x80297e
  801bfc:	e8 39 e6 ff ff       	call   80023a <cprintf>
  801c01:	83 c4 10             	add    $0x10,%esp
  801c04:	eb a4                	jmp    801baa <_pipeisclosed+0xe>
	}
}
  801c06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c0c:	5b                   	pop    %ebx
  801c0d:	5e                   	pop    %esi
  801c0e:	5f                   	pop    %edi
  801c0f:	5d                   	pop    %ebp
  801c10:	c3                   	ret    

00801c11 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c11:	55                   	push   %ebp
  801c12:	89 e5                	mov    %esp,%ebp
  801c14:	57                   	push   %edi
  801c15:	56                   	push   %esi
  801c16:	53                   	push   %ebx
  801c17:	83 ec 28             	sub    $0x28,%esp
  801c1a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c1d:	56                   	push   %esi
  801c1e:	e8 fa f6 ff ff       	call   80131d <fd2data>
  801c23:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c25:	83 c4 10             	add    $0x10,%esp
  801c28:	bf 00 00 00 00       	mov    $0x0,%edi
  801c2d:	eb 4b                	jmp    801c7a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c2f:	89 da                	mov    %ebx,%edx
  801c31:	89 f0                	mov    %esi,%eax
  801c33:	e8 64 ff ff ff       	call   801b9c <_pipeisclosed>
  801c38:	85 c0                	test   %eax,%eax
  801c3a:	75 48                	jne    801c84 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c3c:	e8 62 ef ff ff       	call   800ba3 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c41:	8b 43 04             	mov    0x4(%ebx),%eax
  801c44:	8b 0b                	mov    (%ebx),%ecx
  801c46:	8d 51 20             	lea    0x20(%ecx),%edx
  801c49:	39 d0                	cmp    %edx,%eax
  801c4b:	73 e2                	jae    801c2f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c50:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c54:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c57:	89 c2                	mov    %eax,%edx
  801c59:	c1 fa 1f             	sar    $0x1f,%edx
  801c5c:	89 d1                	mov    %edx,%ecx
  801c5e:	c1 e9 1b             	shr    $0x1b,%ecx
  801c61:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c64:	83 e2 1f             	and    $0x1f,%edx
  801c67:	29 ca                	sub    %ecx,%edx
  801c69:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c6d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c71:	83 c0 01             	add    $0x1,%eax
  801c74:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c77:	83 c7 01             	add    $0x1,%edi
  801c7a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c7d:	75 c2                	jne    801c41 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c7f:	8b 45 10             	mov    0x10(%ebp),%eax
  801c82:	eb 05                	jmp    801c89 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c84:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c8c:	5b                   	pop    %ebx
  801c8d:	5e                   	pop    %esi
  801c8e:	5f                   	pop    %edi
  801c8f:	5d                   	pop    %ebp
  801c90:	c3                   	ret    

00801c91 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c91:	55                   	push   %ebp
  801c92:	89 e5                	mov    %esp,%ebp
  801c94:	57                   	push   %edi
  801c95:	56                   	push   %esi
  801c96:	53                   	push   %ebx
  801c97:	83 ec 18             	sub    $0x18,%esp
  801c9a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c9d:	57                   	push   %edi
  801c9e:	e8 7a f6 ff ff       	call   80131d <fd2data>
  801ca3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ca5:	83 c4 10             	add    $0x10,%esp
  801ca8:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cad:	eb 3d                	jmp    801cec <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801caf:	85 db                	test   %ebx,%ebx
  801cb1:	74 04                	je     801cb7 <devpipe_read+0x26>
				return i;
  801cb3:	89 d8                	mov    %ebx,%eax
  801cb5:	eb 44                	jmp    801cfb <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cb7:	89 f2                	mov    %esi,%edx
  801cb9:	89 f8                	mov    %edi,%eax
  801cbb:	e8 dc fe ff ff       	call   801b9c <_pipeisclosed>
  801cc0:	85 c0                	test   %eax,%eax
  801cc2:	75 32                	jne    801cf6 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cc4:	e8 da ee ff ff       	call   800ba3 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cc9:	8b 06                	mov    (%esi),%eax
  801ccb:	3b 46 04             	cmp    0x4(%esi),%eax
  801cce:	74 df                	je     801caf <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cd0:	99                   	cltd   
  801cd1:	c1 ea 1b             	shr    $0x1b,%edx
  801cd4:	01 d0                	add    %edx,%eax
  801cd6:	83 e0 1f             	and    $0x1f,%eax
  801cd9:	29 d0                	sub    %edx,%eax
  801cdb:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ce0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ce3:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ce6:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ce9:	83 c3 01             	add    $0x1,%ebx
  801cec:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cef:	75 d8                	jne    801cc9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cf1:	8b 45 10             	mov    0x10(%ebp),%eax
  801cf4:	eb 05                	jmp    801cfb <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cf6:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cfe:	5b                   	pop    %ebx
  801cff:	5e                   	pop    %esi
  801d00:	5f                   	pop    %edi
  801d01:	5d                   	pop    %ebp
  801d02:	c3                   	ret    

00801d03 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d03:	55                   	push   %ebp
  801d04:	89 e5                	mov    %esp,%ebp
  801d06:	56                   	push   %esi
  801d07:	53                   	push   %ebx
  801d08:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d0b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d0e:	50                   	push   %eax
  801d0f:	e8 20 f6 ff ff       	call   801334 <fd_alloc>
  801d14:	83 c4 10             	add    $0x10,%esp
  801d17:	89 c2                	mov    %eax,%edx
  801d19:	85 c0                	test   %eax,%eax
  801d1b:	0f 88 2c 01 00 00    	js     801e4d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d21:	83 ec 04             	sub    $0x4,%esp
  801d24:	68 07 04 00 00       	push   $0x407
  801d29:	ff 75 f4             	pushl  -0xc(%ebp)
  801d2c:	6a 00                	push   $0x0
  801d2e:	e8 8f ee ff ff       	call   800bc2 <sys_page_alloc>
  801d33:	83 c4 10             	add    $0x10,%esp
  801d36:	89 c2                	mov    %eax,%edx
  801d38:	85 c0                	test   %eax,%eax
  801d3a:	0f 88 0d 01 00 00    	js     801e4d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d40:	83 ec 0c             	sub    $0xc,%esp
  801d43:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d46:	50                   	push   %eax
  801d47:	e8 e8 f5 ff ff       	call   801334 <fd_alloc>
  801d4c:	89 c3                	mov    %eax,%ebx
  801d4e:	83 c4 10             	add    $0x10,%esp
  801d51:	85 c0                	test   %eax,%eax
  801d53:	0f 88 e2 00 00 00    	js     801e3b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d59:	83 ec 04             	sub    $0x4,%esp
  801d5c:	68 07 04 00 00       	push   $0x407
  801d61:	ff 75 f0             	pushl  -0x10(%ebp)
  801d64:	6a 00                	push   $0x0
  801d66:	e8 57 ee ff ff       	call   800bc2 <sys_page_alloc>
  801d6b:	89 c3                	mov    %eax,%ebx
  801d6d:	83 c4 10             	add    $0x10,%esp
  801d70:	85 c0                	test   %eax,%eax
  801d72:	0f 88 c3 00 00 00    	js     801e3b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d78:	83 ec 0c             	sub    $0xc,%esp
  801d7b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d7e:	e8 9a f5 ff ff       	call   80131d <fd2data>
  801d83:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d85:	83 c4 0c             	add    $0xc,%esp
  801d88:	68 07 04 00 00       	push   $0x407
  801d8d:	50                   	push   %eax
  801d8e:	6a 00                	push   $0x0
  801d90:	e8 2d ee ff ff       	call   800bc2 <sys_page_alloc>
  801d95:	89 c3                	mov    %eax,%ebx
  801d97:	83 c4 10             	add    $0x10,%esp
  801d9a:	85 c0                	test   %eax,%eax
  801d9c:	0f 88 89 00 00 00    	js     801e2b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da2:	83 ec 0c             	sub    $0xc,%esp
  801da5:	ff 75 f0             	pushl  -0x10(%ebp)
  801da8:	e8 70 f5 ff ff       	call   80131d <fd2data>
  801dad:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801db4:	50                   	push   %eax
  801db5:	6a 00                	push   $0x0
  801db7:	56                   	push   %esi
  801db8:	6a 00                	push   $0x0
  801dba:	e8 46 ee ff ff       	call   800c05 <sys_page_map>
  801dbf:	89 c3                	mov    %eax,%ebx
  801dc1:	83 c4 20             	add    $0x20,%esp
  801dc4:	85 c0                	test   %eax,%eax
  801dc6:	78 55                	js     801e1d <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801dc8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801dd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ddd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801de3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801de6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801de8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801deb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801df2:	83 ec 0c             	sub    $0xc,%esp
  801df5:	ff 75 f4             	pushl  -0xc(%ebp)
  801df8:	e8 10 f5 ff ff       	call   80130d <fd2num>
  801dfd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e00:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e02:	83 c4 04             	add    $0x4,%esp
  801e05:	ff 75 f0             	pushl  -0x10(%ebp)
  801e08:	e8 00 f5 ff ff       	call   80130d <fd2num>
  801e0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e10:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801e13:	83 c4 10             	add    $0x10,%esp
  801e16:	ba 00 00 00 00       	mov    $0x0,%edx
  801e1b:	eb 30                	jmp    801e4d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e1d:	83 ec 08             	sub    $0x8,%esp
  801e20:	56                   	push   %esi
  801e21:	6a 00                	push   $0x0
  801e23:	e8 1f ee ff ff       	call   800c47 <sys_page_unmap>
  801e28:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e2b:	83 ec 08             	sub    $0x8,%esp
  801e2e:	ff 75 f0             	pushl  -0x10(%ebp)
  801e31:	6a 00                	push   $0x0
  801e33:	e8 0f ee ff ff       	call   800c47 <sys_page_unmap>
  801e38:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e3b:	83 ec 08             	sub    $0x8,%esp
  801e3e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e41:	6a 00                	push   $0x0
  801e43:	e8 ff ed ff ff       	call   800c47 <sys_page_unmap>
  801e48:	83 c4 10             	add    $0x10,%esp
  801e4b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e4d:	89 d0                	mov    %edx,%eax
  801e4f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e52:	5b                   	pop    %ebx
  801e53:	5e                   	pop    %esi
  801e54:	5d                   	pop    %ebp
  801e55:	c3                   	ret    

00801e56 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e56:	55                   	push   %ebp
  801e57:	89 e5                	mov    %esp,%ebp
  801e59:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e5f:	50                   	push   %eax
  801e60:	ff 75 08             	pushl  0x8(%ebp)
  801e63:	e8 1b f5 ff ff       	call   801383 <fd_lookup>
  801e68:	83 c4 10             	add    $0x10,%esp
  801e6b:	85 c0                	test   %eax,%eax
  801e6d:	78 18                	js     801e87 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e6f:	83 ec 0c             	sub    $0xc,%esp
  801e72:	ff 75 f4             	pushl  -0xc(%ebp)
  801e75:	e8 a3 f4 ff ff       	call   80131d <fd2data>
	return _pipeisclosed(fd, p);
  801e7a:	89 c2                	mov    %eax,%edx
  801e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7f:	e8 18 fd ff ff       	call   801b9c <_pipeisclosed>
  801e84:	83 c4 10             	add    $0x10,%esp
}
  801e87:	c9                   	leave  
  801e88:	c3                   	ret    

00801e89 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e89:	55                   	push   %ebp
  801e8a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e8c:	b8 00 00 00 00       	mov    $0x0,%eax
  801e91:	5d                   	pop    %ebp
  801e92:	c3                   	ret    

00801e93 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e93:	55                   	push   %ebp
  801e94:	89 e5                	mov    %esp,%ebp
  801e96:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e99:	68 96 29 80 00       	push   $0x802996
  801e9e:	ff 75 0c             	pushl  0xc(%ebp)
  801ea1:	e8 19 e9 ff ff       	call   8007bf <strcpy>
	return 0;
}
  801ea6:	b8 00 00 00 00       	mov    $0x0,%eax
  801eab:	c9                   	leave  
  801eac:	c3                   	ret    

00801ead <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ead:	55                   	push   %ebp
  801eae:	89 e5                	mov    %esp,%ebp
  801eb0:	57                   	push   %edi
  801eb1:	56                   	push   %esi
  801eb2:	53                   	push   %ebx
  801eb3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eb9:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ebe:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ec4:	eb 2d                	jmp    801ef3 <devcons_write+0x46>
		m = n - tot;
  801ec6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ec9:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ecb:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ece:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ed3:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ed6:	83 ec 04             	sub    $0x4,%esp
  801ed9:	53                   	push   %ebx
  801eda:	03 45 0c             	add    0xc(%ebp),%eax
  801edd:	50                   	push   %eax
  801ede:	57                   	push   %edi
  801edf:	e8 6d ea ff ff       	call   800951 <memmove>
		sys_cputs(buf, m);
  801ee4:	83 c4 08             	add    $0x8,%esp
  801ee7:	53                   	push   %ebx
  801ee8:	57                   	push   %edi
  801ee9:	e8 18 ec ff ff       	call   800b06 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eee:	01 de                	add    %ebx,%esi
  801ef0:	83 c4 10             	add    $0x10,%esp
  801ef3:	89 f0                	mov    %esi,%eax
  801ef5:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ef8:	72 cc                	jb     801ec6 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801efa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801efd:	5b                   	pop    %ebx
  801efe:	5e                   	pop    %esi
  801eff:	5f                   	pop    %edi
  801f00:	5d                   	pop    %ebp
  801f01:	c3                   	ret    

00801f02 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f02:	55                   	push   %ebp
  801f03:	89 e5                	mov    %esp,%ebp
  801f05:	83 ec 08             	sub    $0x8,%esp
  801f08:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f0d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f11:	74 2a                	je     801f3d <devcons_read+0x3b>
  801f13:	eb 05                	jmp    801f1a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f15:	e8 89 ec ff ff       	call   800ba3 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f1a:	e8 05 ec ff ff       	call   800b24 <sys_cgetc>
  801f1f:	85 c0                	test   %eax,%eax
  801f21:	74 f2                	je     801f15 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f23:	85 c0                	test   %eax,%eax
  801f25:	78 16                	js     801f3d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f27:	83 f8 04             	cmp    $0x4,%eax
  801f2a:	74 0c                	je     801f38 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f2f:	88 02                	mov    %al,(%edx)
	return 1;
  801f31:	b8 01 00 00 00       	mov    $0x1,%eax
  801f36:	eb 05                	jmp    801f3d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f38:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f3d:	c9                   	leave  
  801f3e:	c3                   	ret    

00801f3f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f3f:	55                   	push   %ebp
  801f40:	89 e5                	mov    %esp,%ebp
  801f42:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f45:	8b 45 08             	mov    0x8(%ebp),%eax
  801f48:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f4b:	6a 01                	push   $0x1
  801f4d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f50:	50                   	push   %eax
  801f51:	e8 b0 eb ff ff       	call   800b06 <sys_cputs>
}
  801f56:	83 c4 10             	add    $0x10,%esp
  801f59:	c9                   	leave  
  801f5a:	c3                   	ret    

00801f5b <getchar>:

int
getchar(void)
{
  801f5b:	55                   	push   %ebp
  801f5c:	89 e5                	mov    %esp,%ebp
  801f5e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f61:	6a 01                	push   $0x1
  801f63:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f66:	50                   	push   %eax
  801f67:	6a 00                	push   $0x0
  801f69:	e8 7e f6 ff ff       	call   8015ec <read>
	if (r < 0)
  801f6e:	83 c4 10             	add    $0x10,%esp
  801f71:	85 c0                	test   %eax,%eax
  801f73:	78 0f                	js     801f84 <getchar+0x29>
		return r;
	if (r < 1)
  801f75:	85 c0                	test   %eax,%eax
  801f77:	7e 06                	jle    801f7f <getchar+0x24>
		return -E_EOF;
	return c;
  801f79:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f7d:	eb 05                	jmp    801f84 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f7f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f84:	c9                   	leave  
  801f85:	c3                   	ret    

00801f86 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f86:	55                   	push   %ebp
  801f87:	89 e5                	mov    %esp,%ebp
  801f89:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f8f:	50                   	push   %eax
  801f90:	ff 75 08             	pushl  0x8(%ebp)
  801f93:	e8 eb f3 ff ff       	call   801383 <fd_lookup>
  801f98:	83 c4 10             	add    $0x10,%esp
  801f9b:	85 c0                	test   %eax,%eax
  801f9d:	78 11                	js     801fb0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fa8:	39 10                	cmp    %edx,(%eax)
  801faa:	0f 94 c0             	sete   %al
  801fad:	0f b6 c0             	movzbl %al,%eax
}
  801fb0:	c9                   	leave  
  801fb1:	c3                   	ret    

00801fb2 <opencons>:

int
opencons(void)
{
  801fb2:	55                   	push   %ebp
  801fb3:	89 e5                	mov    %esp,%ebp
  801fb5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fbb:	50                   	push   %eax
  801fbc:	e8 73 f3 ff ff       	call   801334 <fd_alloc>
  801fc1:	83 c4 10             	add    $0x10,%esp
		return r;
  801fc4:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fc6:	85 c0                	test   %eax,%eax
  801fc8:	78 3e                	js     802008 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fca:	83 ec 04             	sub    $0x4,%esp
  801fcd:	68 07 04 00 00       	push   $0x407
  801fd2:	ff 75 f4             	pushl  -0xc(%ebp)
  801fd5:	6a 00                	push   $0x0
  801fd7:	e8 e6 eb ff ff       	call   800bc2 <sys_page_alloc>
  801fdc:	83 c4 10             	add    $0x10,%esp
		return r;
  801fdf:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fe1:	85 c0                	test   %eax,%eax
  801fe3:	78 23                	js     802008 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fe5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801feb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fee:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ff0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ff3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ffa:	83 ec 0c             	sub    $0xc,%esp
  801ffd:	50                   	push   %eax
  801ffe:	e8 0a f3 ff ff       	call   80130d <fd2num>
  802003:	89 c2                	mov    %eax,%edx
  802005:	83 c4 10             	add    $0x10,%esp
}
  802008:	89 d0                	mov    %edx,%eax
  80200a:	c9                   	leave  
  80200b:	c3                   	ret    

0080200c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80200c:	55                   	push   %ebp
  80200d:	89 e5                	mov    %esp,%ebp
  80200f:	56                   	push   %esi
  802010:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802011:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802014:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80201a:	e8 65 eb ff ff       	call   800b84 <sys_getenvid>
  80201f:	83 ec 0c             	sub    $0xc,%esp
  802022:	ff 75 0c             	pushl  0xc(%ebp)
  802025:	ff 75 08             	pushl  0x8(%ebp)
  802028:	56                   	push   %esi
  802029:	50                   	push   %eax
  80202a:	68 a4 29 80 00       	push   $0x8029a4
  80202f:	e8 06 e2 ff ff       	call   80023a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802034:	83 c4 18             	add    $0x18,%esp
  802037:	53                   	push   %ebx
  802038:	ff 75 10             	pushl  0x10(%ebp)
  80203b:	e8 a9 e1 ff ff       	call   8001e9 <vcprintf>
	cprintf("\n");
  802040:	c7 04 24 9b 28 80 00 	movl   $0x80289b,(%esp)
  802047:	e8 ee e1 ff ff       	call   80023a <cprintf>
  80204c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80204f:	cc                   	int3   
  802050:	eb fd                	jmp    80204f <_panic+0x43>

00802052 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802052:	55                   	push   %ebp
  802053:	89 e5                	mov    %esp,%ebp
  802055:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802058:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80205f:	75 2a                	jne    80208b <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802061:	83 ec 04             	sub    $0x4,%esp
  802064:	6a 07                	push   $0x7
  802066:	68 00 f0 bf ee       	push   $0xeebff000
  80206b:	6a 00                	push   $0x0
  80206d:	e8 50 eb ff ff       	call   800bc2 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802072:	83 c4 10             	add    $0x10,%esp
  802075:	85 c0                	test   %eax,%eax
  802077:	79 12                	jns    80208b <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802079:	50                   	push   %eax
  80207a:	68 b2 28 80 00       	push   $0x8028b2
  80207f:	6a 23                	push   $0x23
  802081:	68 c8 29 80 00       	push   $0x8029c8
  802086:	e8 81 ff ff ff       	call   80200c <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80208b:	8b 45 08             	mov    0x8(%ebp),%eax
  80208e:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802093:	83 ec 08             	sub    $0x8,%esp
  802096:	68 bd 20 80 00       	push   $0x8020bd
  80209b:	6a 00                	push   $0x0
  80209d:	e8 6b ec ff ff       	call   800d0d <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8020a2:	83 c4 10             	add    $0x10,%esp
  8020a5:	85 c0                	test   %eax,%eax
  8020a7:	79 12                	jns    8020bb <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8020a9:	50                   	push   %eax
  8020aa:	68 b2 28 80 00       	push   $0x8028b2
  8020af:	6a 2c                	push   $0x2c
  8020b1:	68 c8 29 80 00       	push   $0x8029c8
  8020b6:	e8 51 ff ff ff       	call   80200c <_panic>
	}
}
  8020bb:	c9                   	leave  
  8020bc:	c3                   	ret    

008020bd <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8020bd:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8020be:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8020c3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8020c5:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8020c8:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8020cc:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8020d1:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8020d5:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8020d7:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8020da:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8020db:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8020de:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8020df:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8020e0:	c3                   	ret    

008020e1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020e1:	55                   	push   %ebp
  8020e2:	89 e5                	mov    %esp,%ebp
  8020e4:	56                   	push   %esi
  8020e5:	53                   	push   %ebx
  8020e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8020e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8020ef:	85 c0                	test   %eax,%eax
  8020f1:	75 12                	jne    802105 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8020f3:	83 ec 0c             	sub    $0xc,%esp
  8020f6:	68 00 00 c0 ee       	push   $0xeec00000
  8020fb:	e8 72 ec ff ff       	call   800d72 <sys_ipc_recv>
  802100:	83 c4 10             	add    $0x10,%esp
  802103:	eb 0c                	jmp    802111 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802105:	83 ec 0c             	sub    $0xc,%esp
  802108:	50                   	push   %eax
  802109:	e8 64 ec ff ff       	call   800d72 <sys_ipc_recv>
  80210e:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802111:	85 f6                	test   %esi,%esi
  802113:	0f 95 c1             	setne  %cl
  802116:	85 db                	test   %ebx,%ebx
  802118:	0f 95 c2             	setne  %dl
  80211b:	84 d1                	test   %dl,%cl
  80211d:	74 09                	je     802128 <ipc_recv+0x47>
  80211f:	89 c2                	mov    %eax,%edx
  802121:	c1 ea 1f             	shr    $0x1f,%edx
  802124:	84 d2                	test   %dl,%dl
  802126:	75 2d                	jne    802155 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802128:	85 f6                	test   %esi,%esi
  80212a:	74 0d                	je     802139 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80212c:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802131:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  802137:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802139:	85 db                	test   %ebx,%ebx
  80213b:	74 0d                	je     80214a <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80213d:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802142:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802148:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80214a:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80214f:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  802155:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802158:	5b                   	pop    %ebx
  802159:	5e                   	pop    %esi
  80215a:	5d                   	pop    %ebp
  80215b:	c3                   	ret    

0080215c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80215c:	55                   	push   %ebp
  80215d:	89 e5                	mov    %esp,%ebp
  80215f:	57                   	push   %edi
  802160:	56                   	push   %esi
  802161:	53                   	push   %ebx
  802162:	83 ec 0c             	sub    $0xc,%esp
  802165:	8b 7d 08             	mov    0x8(%ebp),%edi
  802168:	8b 75 0c             	mov    0xc(%ebp),%esi
  80216b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80216e:	85 db                	test   %ebx,%ebx
  802170:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802175:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802178:	ff 75 14             	pushl  0x14(%ebp)
  80217b:	53                   	push   %ebx
  80217c:	56                   	push   %esi
  80217d:	57                   	push   %edi
  80217e:	e8 cc eb ff ff       	call   800d4f <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802183:	89 c2                	mov    %eax,%edx
  802185:	c1 ea 1f             	shr    $0x1f,%edx
  802188:	83 c4 10             	add    $0x10,%esp
  80218b:	84 d2                	test   %dl,%dl
  80218d:	74 17                	je     8021a6 <ipc_send+0x4a>
  80218f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802192:	74 12                	je     8021a6 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802194:	50                   	push   %eax
  802195:	68 d6 29 80 00       	push   $0x8029d6
  80219a:	6a 47                	push   $0x47
  80219c:	68 e4 29 80 00       	push   $0x8029e4
  8021a1:	e8 66 fe ff ff       	call   80200c <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8021a6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021a9:	75 07                	jne    8021b2 <ipc_send+0x56>
			sys_yield();
  8021ab:	e8 f3 e9 ff ff       	call   800ba3 <sys_yield>
  8021b0:	eb c6                	jmp    802178 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8021b2:	85 c0                	test   %eax,%eax
  8021b4:	75 c2                	jne    802178 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8021b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021b9:	5b                   	pop    %ebx
  8021ba:	5e                   	pop    %esi
  8021bb:	5f                   	pop    %edi
  8021bc:	5d                   	pop    %ebp
  8021bd:	c3                   	ret    

008021be <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021be:	55                   	push   %ebp
  8021bf:	89 e5                	mov    %esp,%ebp
  8021c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8021c4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021c9:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  8021cf:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021d5:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  8021db:	39 ca                	cmp    %ecx,%edx
  8021dd:	75 13                	jne    8021f2 <ipc_find_env+0x34>
			return envs[i].env_id;
  8021df:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8021e5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021ea:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8021f0:	eb 0f                	jmp    802201 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021f2:	83 c0 01             	add    $0x1,%eax
  8021f5:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021fa:	75 cd                	jne    8021c9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802201:	5d                   	pop    %ebp
  802202:	c3                   	ret    

00802203 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802203:	55                   	push   %ebp
  802204:	89 e5                	mov    %esp,%ebp
  802206:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802209:	89 d0                	mov    %edx,%eax
  80220b:	c1 e8 16             	shr    $0x16,%eax
  80220e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802215:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80221a:	f6 c1 01             	test   $0x1,%cl
  80221d:	74 1d                	je     80223c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80221f:	c1 ea 0c             	shr    $0xc,%edx
  802222:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802229:	f6 c2 01             	test   $0x1,%dl
  80222c:	74 0e                	je     80223c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80222e:	c1 ea 0c             	shr    $0xc,%edx
  802231:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802238:	ef 
  802239:	0f b7 c0             	movzwl %ax,%eax
}
  80223c:	5d                   	pop    %ebp
  80223d:	c3                   	ret    
  80223e:	66 90                	xchg   %ax,%ax

00802240 <__udivdi3>:
  802240:	55                   	push   %ebp
  802241:	57                   	push   %edi
  802242:	56                   	push   %esi
  802243:	53                   	push   %ebx
  802244:	83 ec 1c             	sub    $0x1c,%esp
  802247:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80224b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80224f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802253:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802257:	85 f6                	test   %esi,%esi
  802259:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80225d:	89 ca                	mov    %ecx,%edx
  80225f:	89 f8                	mov    %edi,%eax
  802261:	75 3d                	jne    8022a0 <__udivdi3+0x60>
  802263:	39 cf                	cmp    %ecx,%edi
  802265:	0f 87 c5 00 00 00    	ja     802330 <__udivdi3+0xf0>
  80226b:	85 ff                	test   %edi,%edi
  80226d:	89 fd                	mov    %edi,%ebp
  80226f:	75 0b                	jne    80227c <__udivdi3+0x3c>
  802271:	b8 01 00 00 00       	mov    $0x1,%eax
  802276:	31 d2                	xor    %edx,%edx
  802278:	f7 f7                	div    %edi
  80227a:	89 c5                	mov    %eax,%ebp
  80227c:	89 c8                	mov    %ecx,%eax
  80227e:	31 d2                	xor    %edx,%edx
  802280:	f7 f5                	div    %ebp
  802282:	89 c1                	mov    %eax,%ecx
  802284:	89 d8                	mov    %ebx,%eax
  802286:	89 cf                	mov    %ecx,%edi
  802288:	f7 f5                	div    %ebp
  80228a:	89 c3                	mov    %eax,%ebx
  80228c:	89 d8                	mov    %ebx,%eax
  80228e:	89 fa                	mov    %edi,%edx
  802290:	83 c4 1c             	add    $0x1c,%esp
  802293:	5b                   	pop    %ebx
  802294:	5e                   	pop    %esi
  802295:	5f                   	pop    %edi
  802296:	5d                   	pop    %ebp
  802297:	c3                   	ret    
  802298:	90                   	nop
  802299:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022a0:	39 ce                	cmp    %ecx,%esi
  8022a2:	77 74                	ja     802318 <__udivdi3+0xd8>
  8022a4:	0f bd fe             	bsr    %esi,%edi
  8022a7:	83 f7 1f             	xor    $0x1f,%edi
  8022aa:	0f 84 98 00 00 00    	je     802348 <__udivdi3+0x108>
  8022b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8022b5:	89 f9                	mov    %edi,%ecx
  8022b7:	89 c5                	mov    %eax,%ebp
  8022b9:	29 fb                	sub    %edi,%ebx
  8022bb:	d3 e6                	shl    %cl,%esi
  8022bd:	89 d9                	mov    %ebx,%ecx
  8022bf:	d3 ed                	shr    %cl,%ebp
  8022c1:	89 f9                	mov    %edi,%ecx
  8022c3:	d3 e0                	shl    %cl,%eax
  8022c5:	09 ee                	or     %ebp,%esi
  8022c7:	89 d9                	mov    %ebx,%ecx
  8022c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022cd:	89 d5                	mov    %edx,%ebp
  8022cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022d3:	d3 ed                	shr    %cl,%ebp
  8022d5:	89 f9                	mov    %edi,%ecx
  8022d7:	d3 e2                	shl    %cl,%edx
  8022d9:	89 d9                	mov    %ebx,%ecx
  8022db:	d3 e8                	shr    %cl,%eax
  8022dd:	09 c2                	or     %eax,%edx
  8022df:	89 d0                	mov    %edx,%eax
  8022e1:	89 ea                	mov    %ebp,%edx
  8022e3:	f7 f6                	div    %esi
  8022e5:	89 d5                	mov    %edx,%ebp
  8022e7:	89 c3                	mov    %eax,%ebx
  8022e9:	f7 64 24 0c          	mull   0xc(%esp)
  8022ed:	39 d5                	cmp    %edx,%ebp
  8022ef:	72 10                	jb     802301 <__udivdi3+0xc1>
  8022f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8022f5:	89 f9                	mov    %edi,%ecx
  8022f7:	d3 e6                	shl    %cl,%esi
  8022f9:	39 c6                	cmp    %eax,%esi
  8022fb:	73 07                	jae    802304 <__udivdi3+0xc4>
  8022fd:	39 d5                	cmp    %edx,%ebp
  8022ff:	75 03                	jne    802304 <__udivdi3+0xc4>
  802301:	83 eb 01             	sub    $0x1,%ebx
  802304:	31 ff                	xor    %edi,%edi
  802306:	89 d8                	mov    %ebx,%eax
  802308:	89 fa                	mov    %edi,%edx
  80230a:	83 c4 1c             	add    $0x1c,%esp
  80230d:	5b                   	pop    %ebx
  80230e:	5e                   	pop    %esi
  80230f:	5f                   	pop    %edi
  802310:	5d                   	pop    %ebp
  802311:	c3                   	ret    
  802312:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802318:	31 ff                	xor    %edi,%edi
  80231a:	31 db                	xor    %ebx,%ebx
  80231c:	89 d8                	mov    %ebx,%eax
  80231e:	89 fa                	mov    %edi,%edx
  802320:	83 c4 1c             	add    $0x1c,%esp
  802323:	5b                   	pop    %ebx
  802324:	5e                   	pop    %esi
  802325:	5f                   	pop    %edi
  802326:	5d                   	pop    %ebp
  802327:	c3                   	ret    
  802328:	90                   	nop
  802329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802330:	89 d8                	mov    %ebx,%eax
  802332:	f7 f7                	div    %edi
  802334:	31 ff                	xor    %edi,%edi
  802336:	89 c3                	mov    %eax,%ebx
  802338:	89 d8                	mov    %ebx,%eax
  80233a:	89 fa                	mov    %edi,%edx
  80233c:	83 c4 1c             	add    $0x1c,%esp
  80233f:	5b                   	pop    %ebx
  802340:	5e                   	pop    %esi
  802341:	5f                   	pop    %edi
  802342:	5d                   	pop    %ebp
  802343:	c3                   	ret    
  802344:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802348:	39 ce                	cmp    %ecx,%esi
  80234a:	72 0c                	jb     802358 <__udivdi3+0x118>
  80234c:	31 db                	xor    %ebx,%ebx
  80234e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802352:	0f 87 34 ff ff ff    	ja     80228c <__udivdi3+0x4c>
  802358:	bb 01 00 00 00       	mov    $0x1,%ebx
  80235d:	e9 2a ff ff ff       	jmp    80228c <__udivdi3+0x4c>
  802362:	66 90                	xchg   %ax,%ax
  802364:	66 90                	xchg   %ax,%ax
  802366:	66 90                	xchg   %ax,%ax
  802368:	66 90                	xchg   %ax,%ax
  80236a:	66 90                	xchg   %ax,%ax
  80236c:	66 90                	xchg   %ax,%ax
  80236e:	66 90                	xchg   %ax,%ax

00802370 <__umoddi3>:
  802370:	55                   	push   %ebp
  802371:	57                   	push   %edi
  802372:	56                   	push   %esi
  802373:	53                   	push   %ebx
  802374:	83 ec 1c             	sub    $0x1c,%esp
  802377:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80237b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80237f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802383:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802387:	85 d2                	test   %edx,%edx
  802389:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80238d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802391:	89 f3                	mov    %esi,%ebx
  802393:	89 3c 24             	mov    %edi,(%esp)
  802396:	89 74 24 04          	mov    %esi,0x4(%esp)
  80239a:	75 1c                	jne    8023b8 <__umoddi3+0x48>
  80239c:	39 f7                	cmp    %esi,%edi
  80239e:	76 50                	jbe    8023f0 <__umoddi3+0x80>
  8023a0:	89 c8                	mov    %ecx,%eax
  8023a2:	89 f2                	mov    %esi,%edx
  8023a4:	f7 f7                	div    %edi
  8023a6:	89 d0                	mov    %edx,%eax
  8023a8:	31 d2                	xor    %edx,%edx
  8023aa:	83 c4 1c             	add    $0x1c,%esp
  8023ad:	5b                   	pop    %ebx
  8023ae:	5e                   	pop    %esi
  8023af:	5f                   	pop    %edi
  8023b0:	5d                   	pop    %ebp
  8023b1:	c3                   	ret    
  8023b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023b8:	39 f2                	cmp    %esi,%edx
  8023ba:	89 d0                	mov    %edx,%eax
  8023bc:	77 52                	ja     802410 <__umoddi3+0xa0>
  8023be:	0f bd ea             	bsr    %edx,%ebp
  8023c1:	83 f5 1f             	xor    $0x1f,%ebp
  8023c4:	75 5a                	jne    802420 <__umoddi3+0xb0>
  8023c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8023ca:	0f 82 e0 00 00 00    	jb     8024b0 <__umoddi3+0x140>
  8023d0:	39 0c 24             	cmp    %ecx,(%esp)
  8023d3:	0f 86 d7 00 00 00    	jbe    8024b0 <__umoddi3+0x140>
  8023d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023e1:	83 c4 1c             	add    $0x1c,%esp
  8023e4:	5b                   	pop    %ebx
  8023e5:	5e                   	pop    %esi
  8023e6:	5f                   	pop    %edi
  8023e7:	5d                   	pop    %ebp
  8023e8:	c3                   	ret    
  8023e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023f0:	85 ff                	test   %edi,%edi
  8023f2:	89 fd                	mov    %edi,%ebp
  8023f4:	75 0b                	jne    802401 <__umoddi3+0x91>
  8023f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023fb:	31 d2                	xor    %edx,%edx
  8023fd:	f7 f7                	div    %edi
  8023ff:	89 c5                	mov    %eax,%ebp
  802401:	89 f0                	mov    %esi,%eax
  802403:	31 d2                	xor    %edx,%edx
  802405:	f7 f5                	div    %ebp
  802407:	89 c8                	mov    %ecx,%eax
  802409:	f7 f5                	div    %ebp
  80240b:	89 d0                	mov    %edx,%eax
  80240d:	eb 99                	jmp    8023a8 <__umoddi3+0x38>
  80240f:	90                   	nop
  802410:	89 c8                	mov    %ecx,%eax
  802412:	89 f2                	mov    %esi,%edx
  802414:	83 c4 1c             	add    $0x1c,%esp
  802417:	5b                   	pop    %ebx
  802418:	5e                   	pop    %esi
  802419:	5f                   	pop    %edi
  80241a:	5d                   	pop    %ebp
  80241b:	c3                   	ret    
  80241c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802420:	8b 34 24             	mov    (%esp),%esi
  802423:	bf 20 00 00 00       	mov    $0x20,%edi
  802428:	89 e9                	mov    %ebp,%ecx
  80242a:	29 ef                	sub    %ebp,%edi
  80242c:	d3 e0                	shl    %cl,%eax
  80242e:	89 f9                	mov    %edi,%ecx
  802430:	89 f2                	mov    %esi,%edx
  802432:	d3 ea                	shr    %cl,%edx
  802434:	89 e9                	mov    %ebp,%ecx
  802436:	09 c2                	or     %eax,%edx
  802438:	89 d8                	mov    %ebx,%eax
  80243a:	89 14 24             	mov    %edx,(%esp)
  80243d:	89 f2                	mov    %esi,%edx
  80243f:	d3 e2                	shl    %cl,%edx
  802441:	89 f9                	mov    %edi,%ecx
  802443:	89 54 24 04          	mov    %edx,0x4(%esp)
  802447:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80244b:	d3 e8                	shr    %cl,%eax
  80244d:	89 e9                	mov    %ebp,%ecx
  80244f:	89 c6                	mov    %eax,%esi
  802451:	d3 e3                	shl    %cl,%ebx
  802453:	89 f9                	mov    %edi,%ecx
  802455:	89 d0                	mov    %edx,%eax
  802457:	d3 e8                	shr    %cl,%eax
  802459:	89 e9                	mov    %ebp,%ecx
  80245b:	09 d8                	or     %ebx,%eax
  80245d:	89 d3                	mov    %edx,%ebx
  80245f:	89 f2                	mov    %esi,%edx
  802461:	f7 34 24             	divl   (%esp)
  802464:	89 d6                	mov    %edx,%esi
  802466:	d3 e3                	shl    %cl,%ebx
  802468:	f7 64 24 04          	mull   0x4(%esp)
  80246c:	39 d6                	cmp    %edx,%esi
  80246e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802472:	89 d1                	mov    %edx,%ecx
  802474:	89 c3                	mov    %eax,%ebx
  802476:	72 08                	jb     802480 <__umoddi3+0x110>
  802478:	75 11                	jne    80248b <__umoddi3+0x11b>
  80247a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80247e:	73 0b                	jae    80248b <__umoddi3+0x11b>
  802480:	2b 44 24 04          	sub    0x4(%esp),%eax
  802484:	1b 14 24             	sbb    (%esp),%edx
  802487:	89 d1                	mov    %edx,%ecx
  802489:	89 c3                	mov    %eax,%ebx
  80248b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80248f:	29 da                	sub    %ebx,%edx
  802491:	19 ce                	sbb    %ecx,%esi
  802493:	89 f9                	mov    %edi,%ecx
  802495:	89 f0                	mov    %esi,%eax
  802497:	d3 e0                	shl    %cl,%eax
  802499:	89 e9                	mov    %ebp,%ecx
  80249b:	d3 ea                	shr    %cl,%edx
  80249d:	89 e9                	mov    %ebp,%ecx
  80249f:	d3 ee                	shr    %cl,%esi
  8024a1:	09 d0                	or     %edx,%eax
  8024a3:	89 f2                	mov    %esi,%edx
  8024a5:	83 c4 1c             	add    $0x1c,%esp
  8024a8:	5b                   	pop    %ebx
  8024a9:	5e                   	pop    %esi
  8024aa:	5f                   	pop    %edi
  8024ab:	5d                   	pop    %ebp
  8024ac:	c3                   	ret    
  8024ad:	8d 76 00             	lea    0x0(%esi),%esi
  8024b0:	29 f9                	sub    %edi,%ecx
  8024b2:	19 d6                	sbb    %edx,%esi
  8024b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024bc:	e9 18 ff ff ff       	jmp    8023d9 <__umoddi3+0x69>
