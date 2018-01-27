
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
  80002c:	e8 ae 00 00 00       	call   8000df <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <func>:
#include <inc/lib.h>

//TESTING THREADS CUZ I CANT DO MAKEFILES

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
		cprintf("HI\n");
  80003f:	83 ec 0c             	sub    $0xc,%esp
  800042:	68 60 22 80 00       	push   $0x802260
  800047:	e8 a9 01 00 00       	call   8001f5 <cprintf>
//TESTING THREADS CUZ I CANT DO MAKEFILES

void func()
{	
	int i;
	for(i = 0; i < 10; i++)
  80004c:	83 c4 10             	add    $0x10,%esp
  80004f:	83 eb 01             	sub    $0x1,%ebx
  800052:	75 eb                	jne    80003f <func+0xc>
	{
		cprintf("HI\n");
	}
}
  800054:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800057:	c9                   	leave  
  800058:	c3                   	ret    

00800059 <test>:


void test()
{
  800059:	55                   	push   %ebp
  80005a:	89 e5                	mov    %esp,%ebp
  80005c:	53                   	push   %ebx
  80005d:	83 ec 04             	sub    $0x4,%esp
  800060:	bb 0a 00 00 00       	mov    $0xa,%ebx
	int i;
	for(i = 0; i < 10; i++)
	{
		cprintf("BYE\n");
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	68 64 22 80 00       	push   $0x802264
  80006d:	e8 83 01 00 00       	call   8001f5 <cprintf>


void test()
{
	int i;
	for(i = 0; i < 10; i++)
  800072:	83 c4 10             	add    $0x10,%esp
  800075:	83 eb 01             	sub    $0x1,%ebx
  800078:	75 eb                	jne    800065 <test+0xc>
	{
		cprintf("BYE\n");
	}
}
  80007a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007d:	c9                   	leave  
  80007e:	c3                   	ret    

0080007f <umain>:

void
umain(int argc, char **argv)
{
  80007f:	55                   	push   %ebp
  800080:	89 e5                	mov    %esp,%ebp
  800082:	56                   	push   %esi
  800083:	53                   	push   %ebx
	envid_t id = thread_create(func);
  800084:	83 ec 0c             	sub    $0xc,%esp
  800087:	68 33 00 80 00       	push   $0x800033
  80008c:	e8 d0 0f 00 00       	call   801061 <thread_create>
  800091:	89 c6                	mov    %eax,%esi
	envid_t id2 = thread_create(test);
  800093:	c7 04 24 59 00 80 00 	movl   $0x800059,(%esp)
  80009a:	e8 c2 0f 00 00       	call   801061 <thread_create>
  80009f:	89 c3                	mov    %eax,%ebx
	thread_create(func);
  8000a1:	c7 04 24 33 00 80 00 	movl   $0x800033,(%esp)
  8000a8:	e8 b4 0f 00 00       	call   801061 <thread_create>
	thread_create(test);
  8000ad:	c7 04 24 59 00 80 00 	movl   $0x800059,(%esp)
  8000b4:	e8 a8 0f 00 00       	call   801061 <thread_create>
	cprintf("\nTHREAD CREATE RETURNED: %d\n\n", id);
  8000b9:	83 c4 08             	add    $0x8,%esp
  8000bc:	56                   	push   %esi
  8000bd:	68 69 22 80 00       	push   $0x802269
  8000c2:	e8 2e 01 00 00       	call   8001f5 <cprintf>
	cprintf("\nTHREAD CREATE RETURNED: %d\n\n", id2);
  8000c7:	83 c4 08             	add    $0x8,%esp
  8000ca:	53                   	push   %ebx
  8000cb:	68 69 22 80 00       	push   $0x802269
  8000d0:	e8 20 01 00 00       	call   8001f5 <cprintf>
}
  8000d5:	83 c4 10             	add    $0x10,%esp
  8000d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000db:	5b                   	pop    %ebx
  8000dc:	5e                   	pop    %esi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	56                   	push   %esi
  8000e3:	53                   	push   %ebx
  8000e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ea:	e8 50 0a 00 00       	call   800b3f <sys_getenvid>
  8000ef:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f4:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  8000fa:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ff:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800104:	85 db                	test   %ebx,%ebx
  800106:	7e 07                	jle    80010f <libmain+0x30>
		binaryname = argv[0];
  800108:	8b 06                	mov    (%esi),%eax
  80010a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80010f:	83 ec 08             	sub    $0x8,%esp
  800112:	56                   	push   %esi
  800113:	53                   	push   %ebx
  800114:	e8 66 ff ff ff       	call   80007f <umain>

	// exit gracefully
	exit();
  800119:	e8 2a 00 00 00       	call   800148 <exit>
}
  80011e:	83 c4 10             	add    $0x10,%esp
  800121:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800124:	5b                   	pop    %ebx
  800125:	5e                   	pop    %esi
  800126:	5d                   	pop    %ebp
  800127:	c3                   	ret    

00800128 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  80012e:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  800133:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800135:	e8 05 0a 00 00       	call   800b3f <sys_getenvid>
  80013a:	83 ec 0c             	sub    $0xc,%esp
  80013d:	50                   	push   %eax
  80013e:	e8 4b 0c 00 00       	call   800d8e <sys_thread_free>
}
  800143:	83 c4 10             	add    $0x10,%esp
  800146:	c9                   	leave  
  800147:	c3                   	ret    

00800148 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014e:	e8 1a 11 00 00       	call   80126d <close_all>
	sys_env_destroy(0);
  800153:	83 ec 0c             	sub    $0xc,%esp
  800156:	6a 00                	push   $0x0
  800158:	e8 a1 09 00 00       	call   800afe <sys_env_destroy>
}
  80015d:	83 c4 10             	add    $0x10,%esp
  800160:	c9                   	leave  
  800161:	c3                   	ret    

00800162 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	53                   	push   %ebx
  800166:	83 ec 04             	sub    $0x4,%esp
  800169:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016c:	8b 13                	mov    (%ebx),%edx
  80016e:	8d 42 01             	lea    0x1(%edx),%eax
  800171:	89 03                	mov    %eax,(%ebx)
  800173:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800176:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80017a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017f:	75 1a                	jne    80019b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800181:	83 ec 08             	sub    $0x8,%esp
  800184:	68 ff 00 00 00       	push   $0xff
  800189:	8d 43 08             	lea    0x8(%ebx),%eax
  80018c:	50                   	push   %eax
  80018d:	e8 2f 09 00 00       	call   800ac1 <sys_cputs>
		b->idx = 0;
  800192:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800198:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80019b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80019f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a2:	c9                   	leave  
  8001a3:	c3                   	ret    

008001a4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ad:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b4:	00 00 00 
	b.cnt = 0;
  8001b7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001be:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c1:	ff 75 0c             	pushl  0xc(%ebp)
  8001c4:	ff 75 08             	pushl  0x8(%ebp)
  8001c7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001cd:	50                   	push   %eax
  8001ce:	68 62 01 80 00       	push   $0x800162
  8001d3:	e8 54 01 00 00       	call   80032c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d8:	83 c4 08             	add    $0x8,%esp
  8001db:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e7:	50                   	push   %eax
  8001e8:	e8 d4 08 00 00       	call   800ac1 <sys_cputs>

	return b.cnt;
}
  8001ed:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f3:	c9                   	leave  
  8001f4:	c3                   	ret    

008001f5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f5:	55                   	push   %ebp
  8001f6:	89 e5                	mov    %esp,%ebp
  8001f8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001fb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001fe:	50                   	push   %eax
  8001ff:	ff 75 08             	pushl  0x8(%ebp)
  800202:	e8 9d ff ff ff       	call   8001a4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800207:	c9                   	leave  
  800208:	c3                   	ret    

00800209 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	57                   	push   %edi
  80020d:	56                   	push   %esi
  80020e:	53                   	push   %ebx
  80020f:	83 ec 1c             	sub    $0x1c,%esp
  800212:	89 c7                	mov    %eax,%edi
  800214:	89 d6                	mov    %edx,%esi
  800216:	8b 45 08             	mov    0x8(%ebp),%eax
  800219:	8b 55 0c             	mov    0xc(%ebp),%edx
  80021c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800222:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800225:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80022d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800230:	39 d3                	cmp    %edx,%ebx
  800232:	72 05                	jb     800239 <printnum+0x30>
  800234:	39 45 10             	cmp    %eax,0x10(%ebp)
  800237:	77 45                	ja     80027e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800239:	83 ec 0c             	sub    $0xc,%esp
  80023c:	ff 75 18             	pushl  0x18(%ebp)
  80023f:	8b 45 14             	mov    0x14(%ebp),%eax
  800242:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800245:	53                   	push   %ebx
  800246:	ff 75 10             	pushl  0x10(%ebp)
  800249:	83 ec 08             	sub    $0x8,%esp
  80024c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024f:	ff 75 e0             	pushl  -0x20(%ebp)
  800252:	ff 75 dc             	pushl  -0x24(%ebp)
  800255:	ff 75 d8             	pushl  -0x28(%ebp)
  800258:	e8 73 1d 00 00       	call   801fd0 <__udivdi3>
  80025d:	83 c4 18             	add    $0x18,%esp
  800260:	52                   	push   %edx
  800261:	50                   	push   %eax
  800262:	89 f2                	mov    %esi,%edx
  800264:	89 f8                	mov    %edi,%eax
  800266:	e8 9e ff ff ff       	call   800209 <printnum>
  80026b:	83 c4 20             	add    $0x20,%esp
  80026e:	eb 18                	jmp    800288 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800270:	83 ec 08             	sub    $0x8,%esp
  800273:	56                   	push   %esi
  800274:	ff 75 18             	pushl  0x18(%ebp)
  800277:	ff d7                	call   *%edi
  800279:	83 c4 10             	add    $0x10,%esp
  80027c:	eb 03                	jmp    800281 <printnum+0x78>
  80027e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800281:	83 eb 01             	sub    $0x1,%ebx
  800284:	85 db                	test   %ebx,%ebx
  800286:	7f e8                	jg     800270 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800288:	83 ec 08             	sub    $0x8,%esp
  80028b:	56                   	push   %esi
  80028c:	83 ec 04             	sub    $0x4,%esp
  80028f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800292:	ff 75 e0             	pushl  -0x20(%ebp)
  800295:	ff 75 dc             	pushl  -0x24(%ebp)
  800298:	ff 75 d8             	pushl  -0x28(%ebp)
  80029b:	e8 60 1e 00 00       	call   802100 <__umoddi3>
  8002a0:	83 c4 14             	add    $0x14,%esp
  8002a3:	0f be 80 91 22 80 00 	movsbl 0x802291(%eax),%eax
  8002aa:	50                   	push   %eax
  8002ab:	ff d7                	call   *%edi
}
  8002ad:	83 c4 10             	add    $0x10,%esp
  8002b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b3:	5b                   	pop    %ebx
  8002b4:	5e                   	pop    %esi
  8002b5:	5f                   	pop    %edi
  8002b6:	5d                   	pop    %ebp
  8002b7:	c3                   	ret    

008002b8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002bb:	83 fa 01             	cmp    $0x1,%edx
  8002be:	7e 0e                	jle    8002ce <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c0:	8b 10                	mov    (%eax),%edx
  8002c2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 02                	mov    (%edx),%eax
  8002c9:	8b 52 04             	mov    0x4(%edx),%edx
  8002cc:	eb 22                	jmp    8002f0 <getuint+0x38>
	else if (lflag)
  8002ce:	85 d2                	test   %edx,%edx
  8002d0:	74 10                	je     8002e2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d2:	8b 10                	mov    (%eax),%edx
  8002d4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d7:	89 08                	mov    %ecx,(%eax)
  8002d9:	8b 02                	mov    (%edx),%eax
  8002db:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e0:	eb 0e                	jmp    8002f0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e2:	8b 10                	mov    (%eax),%edx
  8002e4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e7:	89 08                	mov    %ecx,(%eax)
  8002e9:	8b 02                	mov    (%edx),%eax
  8002eb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f0:	5d                   	pop    %ebp
  8002f1:	c3                   	ret    

008002f2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f2:	55                   	push   %ebp
  8002f3:	89 e5                	mov    %esp,%ebp
  8002f5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002fc:	8b 10                	mov    (%eax),%edx
  8002fe:	3b 50 04             	cmp    0x4(%eax),%edx
  800301:	73 0a                	jae    80030d <sprintputch+0x1b>
		*b->buf++ = ch;
  800303:	8d 4a 01             	lea    0x1(%edx),%ecx
  800306:	89 08                	mov    %ecx,(%eax)
  800308:	8b 45 08             	mov    0x8(%ebp),%eax
  80030b:	88 02                	mov    %al,(%edx)
}
  80030d:	5d                   	pop    %ebp
  80030e:	c3                   	ret    

0080030f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800315:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800318:	50                   	push   %eax
  800319:	ff 75 10             	pushl  0x10(%ebp)
  80031c:	ff 75 0c             	pushl  0xc(%ebp)
  80031f:	ff 75 08             	pushl  0x8(%ebp)
  800322:	e8 05 00 00 00       	call   80032c <vprintfmt>
	va_end(ap);
}
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	c9                   	leave  
  80032b:	c3                   	ret    

0080032c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
  80032f:	57                   	push   %edi
  800330:	56                   	push   %esi
  800331:	53                   	push   %ebx
  800332:	83 ec 2c             	sub    $0x2c,%esp
  800335:	8b 75 08             	mov    0x8(%ebp),%esi
  800338:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80033b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80033e:	eb 12                	jmp    800352 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800340:	85 c0                	test   %eax,%eax
  800342:	0f 84 89 03 00 00    	je     8006d1 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800348:	83 ec 08             	sub    $0x8,%esp
  80034b:	53                   	push   %ebx
  80034c:	50                   	push   %eax
  80034d:	ff d6                	call   *%esi
  80034f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800352:	83 c7 01             	add    $0x1,%edi
  800355:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800359:	83 f8 25             	cmp    $0x25,%eax
  80035c:	75 e2                	jne    800340 <vprintfmt+0x14>
  80035e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800362:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800369:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800370:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800377:	ba 00 00 00 00       	mov    $0x0,%edx
  80037c:	eb 07                	jmp    800385 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800381:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800385:	8d 47 01             	lea    0x1(%edi),%eax
  800388:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80038b:	0f b6 07             	movzbl (%edi),%eax
  80038e:	0f b6 c8             	movzbl %al,%ecx
  800391:	83 e8 23             	sub    $0x23,%eax
  800394:	3c 55                	cmp    $0x55,%al
  800396:	0f 87 1a 03 00 00    	ja     8006b6 <vprintfmt+0x38a>
  80039c:	0f b6 c0             	movzbl %al,%eax
  80039f:	ff 24 85 e0 23 80 00 	jmp    *0x8023e0(,%eax,4)
  8003a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003ad:	eb d6                	jmp    800385 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ba:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003bd:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003c1:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003c4:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003c7:	83 fa 09             	cmp    $0x9,%edx
  8003ca:	77 39                	ja     800405 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003cc:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003cf:	eb e9                	jmp    8003ba <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d4:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003da:	8b 00                	mov    (%eax),%eax
  8003dc:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e2:	eb 27                	jmp    80040b <vprintfmt+0xdf>
  8003e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e7:	85 c0                	test   %eax,%eax
  8003e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ee:	0f 49 c8             	cmovns %eax,%ecx
  8003f1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f7:	eb 8c                	jmp    800385 <vprintfmt+0x59>
  8003f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003fc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800403:	eb 80                	jmp    800385 <vprintfmt+0x59>
  800405:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800408:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80040b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80040f:	0f 89 70 ff ff ff    	jns    800385 <vprintfmt+0x59>
				width = precision, precision = -1;
  800415:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800418:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80041b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800422:	e9 5e ff ff ff       	jmp    800385 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800427:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80042d:	e9 53 ff ff ff       	jmp    800385 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800432:	8b 45 14             	mov    0x14(%ebp),%eax
  800435:	8d 50 04             	lea    0x4(%eax),%edx
  800438:	89 55 14             	mov    %edx,0x14(%ebp)
  80043b:	83 ec 08             	sub    $0x8,%esp
  80043e:	53                   	push   %ebx
  80043f:	ff 30                	pushl  (%eax)
  800441:	ff d6                	call   *%esi
			break;
  800443:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800446:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800449:	e9 04 ff ff ff       	jmp    800352 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80044e:	8b 45 14             	mov    0x14(%ebp),%eax
  800451:	8d 50 04             	lea    0x4(%eax),%edx
  800454:	89 55 14             	mov    %edx,0x14(%ebp)
  800457:	8b 00                	mov    (%eax),%eax
  800459:	99                   	cltd   
  80045a:	31 d0                	xor    %edx,%eax
  80045c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045e:	83 f8 0f             	cmp    $0xf,%eax
  800461:	7f 0b                	jg     80046e <vprintfmt+0x142>
  800463:	8b 14 85 40 25 80 00 	mov    0x802540(,%eax,4),%edx
  80046a:	85 d2                	test   %edx,%edx
  80046c:	75 18                	jne    800486 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80046e:	50                   	push   %eax
  80046f:	68 a9 22 80 00       	push   $0x8022a9
  800474:	53                   	push   %ebx
  800475:	56                   	push   %esi
  800476:	e8 94 fe ff ff       	call   80030f <printfmt>
  80047b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800481:	e9 cc fe ff ff       	jmp    800352 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800486:	52                   	push   %edx
  800487:	68 ed 26 80 00       	push   $0x8026ed
  80048c:	53                   	push   %ebx
  80048d:	56                   	push   %esi
  80048e:	e8 7c fe ff ff       	call   80030f <printfmt>
  800493:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800496:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800499:	e9 b4 fe ff ff       	jmp    800352 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80049e:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a1:	8d 50 04             	lea    0x4(%eax),%edx
  8004a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a9:	85 ff                	test   %edi,%edi
  8004ab:	b8 a2 22 80 00       	mov    $0x8022a2,%eax
  8004b0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004b3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b7:	0f 8e 94 00 00 00    	jle    800551 <vprintfmt+0x225>
  8004bd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004c1:	0f 84 98 00 00 00    	je     80055f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c7:	83 ec 08             	sub    $0x8,%esp
  8004ca:	ff 75 d0             	pushl  -0x30(%ebp)
  8004cd:	57                   	push   %edi
  8004ce:	e8 86 02 00 00       	call   800759 <strnlen>
  8004d3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d6:	29 c1                	sub    %eax,%ecx
  8004d8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004db:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004de:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ea:	eb 0f                	jmp    8004fb <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004ec:	83 ec 08             	sub    $0x8,%esp
  8004ef:	53                   	push   %ebx
  8004f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f5:	83 ef 01             	sub    $0x1,%edi
  8004f8:	83 c4 10             	add    $0x10,%esp
  8004fb:	85 ff                	test   %edi,%edi
  8004fd:	7f ed                	jg     8004ec <vprintfmt+0x1c0>
  8004ff:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800502:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800505:	85 c9                	test   %ecx,%ecx
  800507:	b8 00 00 00 00       	mov    $0x0,%eax
  80050c:	0f 49 c1             	cmovns %ecx,%eax
  80050f:	29 c1                	sub    %eax,%ecx
  800511:	89 75 08             	mov    %esi,0x8(%ebp)
  800514:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800517:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051a:	89 cb                	mov    %ecx,%ebx
  80051c:	eb 4d                	jmp    80056b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80051e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800522:	74 1b                	je     80053f <vprintfmt+0x213>
  800524:	0f be c0             	movsbl %al,%eax
  800527:	83 e8 20             	sub    $0x20,%eax
  80052a:	83 f8 5e             	cmp    $0x5e,%eax
  80052d:	76 10                	jbe    80053f <vprintfmt+0x213>
					putch('?', putdat);
  80052f:	83 ec 08             	sub    $0x8,%esp
  800532:	ff 75 0c             	pushl  0xc(%ebp)
  800535:	6a 3f                	push   $0x3f
  800537:	ff 55 08             	call   *0x8(%ebp)
  80053a:	83 c4 10             	add    $0x10,%esp
  80053d:	eb 0d                	jmp    80054c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	ff 75 0c             	pushl  0xc(%ebp)
  800545:	52                   	push   %edx
  800546:	ff 55 08             	call   *0x8(%ebp)
  800549:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054c:	83 eb 01             	sub    $0x1,%ebx
  80054f:	eb 1a                	jmp    80056b <vprintfmt+0x23f>
  800551:	89 75 08             	mov    %esi,0x8(%ebp)
  800554:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800557:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80055d:	eb 0c                	jmp    80056b <vprintfmt+0x23f>
  80055f:	89 75 08             	mov    %esi,0x8(%ebp)
  800562:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800565:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800568:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056b:	83 c7 01             	add    $0x1,%edi
  80056e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800572:	0f be d0             	movsbl %al,%edx
  800575:	85 d2                	test   %edx,%edx
  800577:	74 23                	je     80059c <vprintfmt+0x270>
  800579:	85 f6                	test   %esi,%esi
  80057b:	78 a1                	js     80051e <vprintfmt+0x1f2>
  80057d:	83 ee 01             	sub    $0x1,%esi
  800580:	79 9c                	jns    80051e <vprintfmt+0x1f2>
  800582:	89 df                	mov    %ebx,%edi
  800584:	8b 75 08             	mov    0x8(%ebp),%esi
  800587:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80058a:	eb 18                	jmp    8005a4 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058c:	83 ec 08             	sub    $0x8,%esp
  80058f:	53                   	push   %ebx
  800590:	6a 20                	push   $0x20
  800592:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800594:	83 ef 01             	sub    $0x1,%edi
  800597:	83 c4 10             	add    $0x10,%esp
  80059a:	eb 08                	jmp    8005a4 <vprintfmt+0x278>
  80059c:	89 df                	mov    %ebx,%edi
  80059e:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a4:	85 ff                	test   %edi,%edi
  8005a6:	7f e4                	jg     80058c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ab:	e9 a2 fd ff ff       	jmp    800352 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b0:	83 fa 01             	cmp    $0x1,%edx
  8005b3:	7e 16                	jle    8005cb <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8d 50 08             	lea    0x8(%eax),%edx
  8005bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005be:	8b 50 04             	mov    0x4(%eax),%edx
  8005c1:	8b 00                	mov    (%eax),%eax
  8005c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c9:	eb 32                	jmp    8005fd <vprintfmt+0x2d1>
	else if (lflag)
  8005cb:	85 d2                	test   %edx,%edx
  8005cd:	74 18                	je     8005e7 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d2:	8d 50 04             	lea    0x4(%eax),%edx
  8005d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d8:	8b 00                	mov    (%eax),%eax
  8005da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005dd:	89 c1                	mov    %eax,%ecx
  8005df:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e5:	eb 16                	jmp    8005fd <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8d 50 04             	lea    0x4(%eax),%edx
  8005ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f0:	8b 00                	mov    (%eax),%eax
  8005f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f5:	89 c1                	mov    %eax,%ecx
  8005f7:	c1 f9 1f             	sar    $0x1f,%ecx
  8005fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005fd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800600:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800603:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800608:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80060c:	79 74                	jns    800682 <vprintfmt+0x356>
				putch('-', putdat);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	6a 2d                	push   $0x2d
  800614:	ff d6                	call   *%esi
				num = -(long long) num;
  800616:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800619:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80061c:	f7 d8                	neg    %eax
  80061e:	83 d2 00             	adc    $0x0,%edx
  800621:	f7 da                	neg    %edx
  800623:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800626:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80062b:	eb 55                	jmp    800682 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80062d:	8d 45 14             	lea    0x14(%ebp),%eax
  800630:	e8 83 fc ff ff       	call   8002b8 <getuint>
			base = 10;
  800635:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80063a:	eb 46                	jmp    800682 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80063c:	8d 45 14             	lea    0x14(%ebp),%eax
  80063f:	e8 74 fc ff ff       	call   8002b8 <getuint>
			base = 8;
  800644:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800649:	eb 37                	jmp    800682 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80064b:	83 ec 08             	sub    $0x8,%esp
  80064e:	53                   	push   %ebx
  80064f:	6a 30                	push   $0x30
  800651:	ff d6                	call   *%esi
			putch('x', putdat);
  800653:	83 c4 08             	add    $0x8,%esp
  800656:	53                   	push   %ebx
  800657:	6a 78                	push   $0x78
  800659:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80065b:	8b 45 14             	mov    0x14(%ebp),%eax
  80065e:	8d 50 04             	lea    0x4(%eax),%edx
  800661:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800664:	8b 00                	mov    (%eax),%eax
  800666:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80066b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80066e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800673:	eb 0d                	jmp    800682 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800675:	8d 45 14             	lea    0x14(%ebp),%eax
  800678:	e8 3b fc ff ff       	call   8002b8 <getuint>
			base = 16;
  80067d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800682:	83 ec 0c             	sub    $0xc,%esp
  800685:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800689:	57                   	push   %edi
  80068a:	ff 75 e0             	pushl  -0x20(%ebp)
  80068d:	51                   	push   %ecx
  80068e:	52                   	push   %edx
  80068f:	50                   	push   %eax
  800690:	89 da                	mov    %ebx,%edx
  800692:	89 f0                	mov    %esi,%eax
  800694:	e8 70 fb ff ff       	call   800209 <printnum>
			break;
  800699:	83 c4 20             	add    $0x20,%esp
  80069c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069f:	e9 ae fc ff ff       	jmp    800352 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a4:	83 ec 08             	sub    $0x8,%esp
  8006a7:	53                   	push   %ebx
  8006a8:	51                   	push   %ecx
  8006a9:	ff d6                	call   *%esi
			break;
  8006ab:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006b1:	e9 9c fc ff ff       	jmp    800352 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b6:	83 ec 08             	sub    $0x8,%esp
  8006b9:	53                   	push   %ebx
  8006ba:	6a 25                	push   $0x25
  8006bc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006be:	83 c4 10             	add    $0x10,%esp
  8006c1:	eb 03                	jmp    8006c6 <vprintfmt+0x39a>
  8006c3:	83 ef 01             	sub    $0x1,%edi
  8006c6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006ca:	75 f7                	jne    8006c3 <vprintfmt+0x397>
  8006cc:	e9 81 fc ff ff       	jmp    800352 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d4:	5b                   	pop    %ebx
  8006d5:	5e                   	pop    %esi
  8006d6:	5f                   	pop    %edi
  8006d7:	5d                   	pop    %ebp
  8006d8:	c3                   	ret    

008006d9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d9:	55                   	push   %ebp
  8006da:	89 e5                	mov    %esp,%ebp
  8006dc:	83 ec 18             	sub    $0x18,%esp
  8006df:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ec:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f6:	85 c0                	test   %eax,%eax
  8006f8:	74 26                	je     800720 <vsnprintf+0x47>
  8006fa:	85 d2                	test   %edx,%edx
  8006fc:	7e 22                	jle    800720 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006fe:	ff 75 14             	pushl  0x14(%ebp)
  800701:	ff 75 10             	pushl  0x10(%ebp)
  800704:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800707:	50                   	push   %eax
  800708:	68 f2 02 80 00       	push   $0x8002f2
  80070d:	e8 1a fc ff ff       	call   80032c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800712:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800715:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800718:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80071b:	83 c4 10             	add    $0x10,%esp
  80071e:	eb 05                	jmp    800725 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800720:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800725:	c9                   	leave  
  800726:	c3                   	ret    

00800727 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80072d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800730:	50                   	push   %eax
  800731:	ff 75 10             	pushl  0x10(%ebp)
  800734:	ff 75 0c             	pushl  0xc(%ebp)
  800737:	ff 75 08             	pushl  0x8(%ebp)
  80073a:	e8 9a ff ff ff       	call   8006d9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80073f:	c9                   	leave  
  800740:	c3                   	ret    

00800741 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800741:	55                   	push   %ebp
  800742:	89 e5                	mov    %esp,%ebp
  800744:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800747:	b8 00 00 00 00       	mov    $0x0,%eax
  80074c:	eb 03                	jmp    800751 <strlen+0x10>
		n++;
  80074e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800751:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800755:	75 f7                	jne    80074e <strlen+0xd>
		n++;
	return n;
}
  800757:	5d                   	pop    %ebp
  800758:	c3                   	ret    

00800759 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800762:	ba 00 00 00 00       	mov    $0x0,%edx
  800767:	eb 03                	jmp    80076c <strnlen+0x13>
		n++;
  800769:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076c:	39 c2                	cmp    %eax,%edx
  80076e:	74 08                	je     800778 <strnlen+0x1f>
  800770:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800774:	75 f3                	jne    800769 <strnlen+0x10>
  800776:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800778:	5d                   	pop    %ebp
  800779:	c3                   	ret    

0080077a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	53                   	push   %ebx
  80077e:	8b 45 08             	mov    0x8(%ebp),%eax
  800781:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800784:	89 c2                	mov    %eax,%edx
  800786:	83 c2 01             	add    $0x1,%edx
  800789:	83 c1 01             	add    $0x1,%ecx
  80078c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800790:	88 5a ff             	mov    %bl,-0x1(%edx)
  800793:	84 db                	test   %bl,%bl
  800795:	75 ef                	jne    800786 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800797:	5b                   	pop    %ebx
  800798:	5d                   	pop    %ebp
  800799:	c3                   	ret    

0080079a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	53                   	push   %ebx
  80079e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a1:	53                   	push   %ebx
  8007a2:	e8 9a ff ff ff       	call   800741 <strlen>
  8007a7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007aa:	ff 75 0c             	pushl  0xc(%ebp)
  8007ad:	01 d8                	add    %ebx,%eax
  8007af:	50                   	push   %eax
  8007b0:	e8 c5 ff ff ff       	call   80077a <strcpy>
	return dst;
}
  8007b5:	89 d8                	mov    %ebx,%eax
  8007b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ba:	c9                   	leave  
  8007bb:	c3                   	ret    

008007bc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	56                   	push   %esi
  8007c0:	53                   	push   %ebx
  8007c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c7:	89 f3                	mov    %esi,%ebx
  8007c9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007cc:	89 f2                	mov    %esi,%edx
  8007ce:	eb 0f                	jmp    8007df <strncpy+0x23>
		*dst++ = *src;
  8007d0:	83 c2 01             	add    $0x1,%edx
  8007d3:	0f b6 01             	movzbl (%ecx),%eax
  8007d6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d9:	80 39 01             	cmpb   $0x1,(%ecx)
  8007dc:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007df:	39 da                	cmp    %ebx,%edx
  8007e1:	75 ed                	jne    8007d0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e3:	89 f0                	mov    %esi,%eax
  8007e5:	5b                   	pop    %ebx
  8007e6:	5e                   	pop    %esi
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	56                   	push   %esi
  8007ed:	53                   	push   %ebx
  8007ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f4:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f9:	85 d2                	test   %edx,%edx
  8007fb:	74 21                	je     80081e <strlcpy+0x35>
  8007fd:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800801:	89 f2                	mov    %esi,%edx
  800803:	eb 09                	jmp    80080e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800805:	83 c2 01             	add    $0x1,%edx
  800808:	83 c1 01             	add    $0x1,%ecx
  80080b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80080e:	39 c2                	cmp    %eax,%edx
  800810:	74 09                	je     80081b <strlcpy+0x32>
  800812:	0f b6 19             	movzbl (%ecx),%ebx
  800815:	84 db                	test   %bl,%bl
  800817:	75 ec                	jne    800805 <strlcpy+0x1c>
  800819:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80081b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80081e:	29 f0                	sub    %esi,%eax
}
  800820:	5b                   	pop    %ebx
  800821:	5e                   	pop    %esi
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80082d:	eb 06                	jmp    800835 <strcmp+0x11>
		p++, q++;
  80082f:	83 c1 01             	add    $0x1,%ecx
  800832:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800835:	0f b6 01             	movzbl (%ecx),%eax
  800838:	84 c0                	test   %al,%al
  80083a:	74 04                	je     800840 <strcmp+0x1c>
  80083c:	3a 02                	cmp    (%edx),%al
  80083e:	74 ef                	je     80082f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800840:	0f b6 c0             	movzbl %al,%eax
  800843:	0f b6 12             	movzbl (%edx),%edx
  800846:	29 d0                	sub    %edx,%eax
}
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	53                   	push   %ebx
  80084e:	8b 45 08             	mov    0x8(%ebp),%eax
  800851:	8b 55 0c             	mov    0xc(%ebp),%edx
  800854:	89 c3                	mov    %eax,%ebx
  800856:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800859:	eb 06                	jmp    800861 <strncmp+0x17>
		n--, p++, q++;
  80085b:	83 c0 01             	add    $0x1,%eax
  80085e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800861:	39 d8                	cmp    %ebx,%eax
  800863:	74 15                	je     80087a <strncmp+0x30>
  800865:	0f b6 08             	movzbl (%eax),%ecx
  800868:	84 c9                	test   %cl,%cl
  80086a:	74 04                	je     800870 <strncmp+0x26>
  80086c:	3a 0a                	cmp    (%edx),%cl
  80086e:	74 eb                	je     80085b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800870:	0f b6 00             	movzbl (%eax),%eax
  800873:	0f b6 12             	movzbl (%edx),%edx
  800876:	29 d0                	sub    %edx,%eax
  800878:	eb 05                	jmp    80087f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80087a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80087f:	5b                   	pop    %ebx
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	8b 45 08             	mov    0x8(%ebp),%eax
  800888:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088c:	eb 07                	jmp    800895 <strchr+0x13>
		if (*s == c)
  80088e:	38 ca                	cmp    %cl,%dl
  800890:	74 0f                	je     8008a1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800892:	83 c0 01             	add    $0x1,%eax
  800895:	0f b6 10             	movzbl (%eax),%edx
  800898:	84 d2                	test   %dl,%dl
  80089a:	75 f2                	jne    80088e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80089c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a1:	5d                   	pop    %ebp
  8008a2:	c3                   	ret    

008008a3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ad:	eb 03                	jmp    8008b2 <strfind+0xf>
  8008af:	83 c0 01             	add    $0x1,%eax
  8008b2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008b5:	38 ca                	cmp    %cl,%dl
  8008b7:	74 04                	je     8008bd <strfind+0x1a>
  8008b9:	84 d2                	test   %dl,%dl
  8008bb:	75 f2                	jne    8008af <strfind+0xc>
			break;
	return (char *) s;
}
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	57                   	push   %edi
  8008c3:	56                   	push   %esi
  8008c4:	53                   	push   %ebx
  8008c5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008cb:	85 c9                	test   %ecx,%ecx
  8008cd:	74 36                	je     800905 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008cf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d5:	75 28                	jne    8008ff <memset+0x40>
  8008d7:	f6 c1 03             	test   $0x3,%cl
  8008da:	75 23                	jne    8008ff <memset+0x40>
		c &= 0xFF;
  8008dc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e0:	89 d3                	mov    %edx,%ebx
  8008e2:	c1 e3 08             	shl    $0x8,%ebx
  8008e5:	89 d6                	mov    %edx,%esi
  8008e7:	c1 e6 18             	shl    $0x18,%esi
  8008ea:	89 d0                	mov    %edx,%eax
  8008ec:	c1 e0 10             	shl    $0x10,%eax
  8008ef:	09 f0                	or     %esi,%eax
  8008f1:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008f3:	89 d8                	mov    %ebx,%eax
  8008f5:	09 d0                	or     %edx,%eax
  8008f7:	c1 e9 02             	shr    $0x2,%ecx
  8008fa:	fc                   	cld    
  8008fb:	f3 ab                	rep stos %eax,%es:(%edi)
  8008fd:	eb 06                	jmp    800905 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800902:	fc                   	cld    
  800903:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800905:	89 f8                	mov    %edi,%eax
  800907:	5b                   	pop    %ebx
  800908:	5e                   	pop    %esi
  800909:	5f                   	pop    %edi
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    

0080090c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	57                   	push   %edi
  800910:	56                   	push   %esi
  800911:	8b 45 08             	mov    0x8(%ebp),%eax
  800914:	8b 75 0c             	mov    0xc(%ebp),%esi
  800917:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80091a:	39 c6                	cmp    %eax,%esi
  80091c:	73 35                	jae    800953 <memmove+0x47>
  80091e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800921:	39 d0                	cmp    %edx,%eax
  800923:	73 2e                	jae    800953 <memmove+0x47>
		s += n;
		d += n;
  800925:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800928:	89 d6                	mov    %edx,%esi
  80092a:	09 fe                	or     %edi,%esi
  80092c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800932:	75 13                	jne    800947 <memmove+0x3b>
  800934:	f6 c1 03             	test   $0x3,%cl
  800937:	75 0e                	jne    800947 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800939:	83 ef 04             	sub    $0x4,%edi
  80093c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80093f:	c1 e9 02             	shr    $0x2,%ecx
  800942:	fd                   	std    
  800943:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800945:	eb 09                	jmp    800950 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800947:	83 ef 01             	sub    $0x1,%edi
  80094a:	8d 72 ff             	lea    -0x1(%edx),%esi
  80094d:	fd                   	std    
  80094e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800950:	fc                   	cld    
  800951:	eb 1d                	jmp    800970 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800953:	89 f2                	mov    %esi,%edx
  800955:	09 c2                	or     %eax,%edx
  800957:	f6 c2 03             	test   $0x3,%dl
  80095a:	75 0f                	jne    80096b <memmove+0x5f>
  80095c:	f6 c1 03             	test   $0x3,%cl
  80095f:	75 0a                	jne    80096b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800961:	c1 e9 02             	shr    $0x2,%ecx
  800964:	89 c7                	mov    %eax,%edi
  800966:	fc                   	cld    
  800967:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800969:	eb 05                	jmp    800970 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80096b:	89 c7                	mov    %eax,%edi
  80096d:	fc                   	cld    
  80096e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800970:	5e                   	pop    %esi
  800971:	5f                   	pop    %edi
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800977:	ff 75 10             	pushl  0x10(%ebp)
  80097a:	ff 75 0c             	pushl  0xc(%ebp)
  80097d:	ff 75 08             	pushl  0x8(%ebp)
  800980:	e8 87 ff ff ff       	call   80090c <memmove>
}
  800985:	c9                   	leave  
  800986:	c3                   	ret    

00800987 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	56                   	push   %esi
  80098b:	53                   	push   %ebx
  80098c:	8b 45 08             	mov    0x8(%ebp),%eax
  80098f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800992:	89 c6                	mov    %eax,%esi
  800994:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800997:	eb 1a                	jmp    8009b3 <memcmp+0x2c>
		if (*s1 != *s2)
  800999:	0f b6 08             	movzbl (%eax),%ecx
  80099c:	0f b6 1a             	movzbl (%edx),%ebx
  80099f:	38 d9                	cmp    %bl,%cl
  8009a1:	74 0a                	je     8009ad <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009a3:	0f b6 c1             	movzbl %cl,%eax
  8009a6:	0f b6 db             	movzbl %bl,%ebx
  8009a9:	29 d8                	sub    %ebx,%eax
  8009ab:	eb 0f                	jmp    8009bc <memcmp+0x35>
		s1++, s2++;
  8009ad:	83 c0 01             	add    $0x1,%eax
  8009b0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b3:	39 f0                	cmp    %esi,%eax
  8009b5:	75 e2                	jne    800999 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bc:	5b                   	pop    %ebx
  8009bd:	5e                   	pop    %esi
  8009be:	5d                   	pop    %ebp
  8009bf:	c3                   	ret    

008009c0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	53                   	push   %ebx
  8009c4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009c7:	89 c1                	mov    %eax,%ecx
  8009c9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009cc:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d0:	eb 0a                	jmp    8009dc <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d2:	0f b6 10             	movzbl (%eax),%edx
  8009d5:	39 da                	cmp    %ebx,%edx
  8009d7:	74 07                	je     8009e0 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d9:	83 c0 01             	add    $0x1,%eax
  8009dc:	39 c8                	cmp    %ecx,%eax
  8009de:	72 f2                	jb     8009d2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009e0:	5b                   	pop    %ebx
  8009e1:	5d                   	pop    %ebp
  8009e2:	c3                   	ret    

008009e3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	57                   	push   %edi
  8009e7:	56                   	push   %esi
  8009e8:	53                   	push   %ebx
  8009e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ef:	eb 03                	jmp    8009f4 <strtol+0x11>
		s++;
  8009f1:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f4:	0f b6 01             	movzbl (%ecx),%eax
  8009f7:	3c 20                	cmp    $0x20,%al
  8009f9:	74 f6                	je     8009f1 <strtol+0xe>
  8009fb:	3c 09                	cmp    $0x9,%al
  8009fd:	74 f2                	je     8009f1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009ff:	3c 2b                	cmp    $0x2b,%al
  800a01:	75 0a                	jne    800a0d <strtol+0x2a>
		s++;
  800a03:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a06:	bf 00 00 00 00       	mov    $0x0,%edi
  800a0b:	eb 11                	jmp    800a1e <strtol+0x3b>
  800a0d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a12:	3c 2d                	cmp    $0x2d,%al
  800a14:	75 08                	jne    800a1e <strtol+0x3b>
		s++, neg = 1;
  800a16:	83 c1 01             	add    $0x1,%ecx
  800a19:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a24:	75 15                	jne    800a3b <strtol+0x58>
  800a26:	80 39 30             	cmpb   $0x30,(%ecx)
  800a29:	75 10                	jne    800a3b <strtol+0x58>
  800a2b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a2f:	75 7c                	jne    800aad <strtol+0xca>
		s += 2, base = 16;
  800a31:	83 c1 02             	add    $0x2,%ecx
  800a34:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a39:	eb 16                	jmp    800a51 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a3b:	85 db                	test   %ebx,%ebx
  800a3d:	75 12                	jne    800a51 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a3f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a44:	80 39 30             	cmpb   $0x30,(%ecx)
  800a47:	75 08                	jne    800a51 <strtol+0x6e>
		s++, base = 8;
  800a49:	83 c1 01             	add    $0x1,%ecx
  800a4c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a51:	b8 00 00 00 00       	mov    $0x0,%eax
  800a56:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a59:	0f b6 11             	movzbl (%ecx),%edx
  800a5c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a5f:	89 f3                	mov    %esi,%ebx
  800a61:	80 fb 09             	cmp    $0x9,%bl
  800a64:	77 08                	ja     800a6e <strtol+0x8b>
			dig = *s - '0';
  800a66:	0f be d2             	movsbl %dl,%edx
  800a69:	83 ea 30             	sub    $0x30,%edx
  800a6c:	eb 22                	jmp    800a90 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a6e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a71:	89 f3                	mov    %esi,%ebx
  800a73:	80 fb 19             	cmp    $0x19,%bl
  800a76:	77 08                	ja     800a80 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a78:	0f be d2             	movsbl %dl,%edx
  800a7b:	83 ea 57             	sub    $0x57,%edx
  800a7e:	eb 10                	jmp    800a90 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a80:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a83:	89 f3                	mov    %esi,%ebx
  800a85:	80 fb 19             	cmp    $0x19,%bl
  800a88:	77 16                	ja     800aa0 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a8a:	0f be d2             	movsbl %dl,%edx
  800a8d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a90:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a93:	7d 0b                	jge    800aa0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a95:	83 c1 01             	add    $0x1,%ecx
  800a98:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a9c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a9e:	eb b9                	jmp    800a59 <strtol+0x76>

	if (endptr)
  800aa0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa4:	74 0d                	je     800ab3 <strtol+0xd0>
		*endptr = (char *) s;
  800aa6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa9:	89 0e                	mov    %ecx,(%esi)
  800aab:	eb 06                	jmp    800ab3 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aad:	85 db                	test   %ebx,%ebx
  800aaf:	74 98                	je     800a49 <strtol+0x66>
  800ab1:	eb 9e                	jmp    800a51 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ab3:	89 c2                	mov    %eax,%edx
  800ab5:	f7 da                	neg    %edx
  800ab7:	85 ff                	test   %edi,%edi
  800ab9:	0f 45 c2             	cmovne %edx,%eax
}
  800abc:	5b                   	pop    %ebx
  800abd:	5e                   	pop    %esi
  800abe:	5f                   	pop    %edi
  800abf:	5d                   	pop    %ebp
  800ac0:	c3                   	ret    

00800ac1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	57                   	push   %edi
  800ac5:	56                   	push   %esi
  800ac6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac7:	b8 00 00 00 00       	mov    $0x0,%eax
  800acc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800acf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad2:	89 c3                	mov    %eax,%ebx
  800ad4:	89 c7                	mov    %eax,%edi
  800ad6:	89 c6                	mov    %eax,%esi
  800ad8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ada:	5b                   	pop    %ebx
  800adb:	5e                   	pop    %esi
  800adc:	5f                   	pop    %edi
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <sys_cgetc>:

int
sys_cgetc(void)
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
  800ae5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aea:	b8 01 00 00 00       	mov    $0x1,%eax
  800aef:	89 d1                	mov    %edx,%ecx
  800af1:	89 d3                	mov    %edx,%ebx
  800af3:	89 d7                	mov    %edx,%edi
  800af5:	89 d6                	mov    %edx,%esi
  800af7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5f                   	pop    %edi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	57                   	push   %edi
  800b02:	56                   	push   %esi
  800b03:	53                   	push   %ebx
  800b04:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b07:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b0c:	b8 03 00 00 00       	mov    $0x3,%eax
  800b11:	8b 55 08             	mov    0x8(%ebp),%edx
  800b14:	89 cb                	mov    %ecx,%ebx
  800b16:	89 cf                	mov    %ecx,%edi
  800b18:	89 ce                	mov    %ecx,%esi
  800b1a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b1c:	85 c0                	test   %eax,%eax
  800b1e:	7e 17                	jle    800b37 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b20:	83 ec 0c             	sub    $0xc,%esp
  800b23:	50                   	push   %eax
  800b24:	6a 03                	push   $0x3
  800b26:	68 9f 25 80 00       	push   $0x80259f
  800b2b:	6a 23                	push   $0x23
  800b2d:	68 bc 25 80 00       	push   $0x8025bc
  800b32:	e8 5e 12 00 00       	call   801d95 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5f                   	pop    %edi
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800b4a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b4f:	89 d1                	mov    %edx,%ecx
  800b51:	89 d3                	mov    %edx,%ebx
  800b53:	89 d7                	mov    %edx,%edi
  800b55:	89 d6                	mov    %edx,%esi
  800b57:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <sys_yield>:

void
sys_yield(void)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b64:	ba 00 00 00 00       	mov    $0x0,%edx
  800b69:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b6e:	89 d1                	mov    %edx,%ecx
  800b70:	89 d3                	mov    %edx,%ebx
  800b72:	89 d7                	mov    %edx,%edi
  800b74:	89 d6                	mov    %edx,%esi
  800b76:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
  800b83:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b86:	be 00 00 00 00       	mov    $0x0,%esi
  800b8b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b93:	8b 55 08             	mov    0x8(%ebp),%edx
  800b96:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b99:	89 f7                	mov    %esi,%edi
  800b9b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9d:	85 c0                	test   %eax,%eax
  800b9f:	7e 17                	jle    800bb8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba1:	83 ec 0c             	sub    $0xc,%esp
  800ba4:	50                   	push   %eax
  800ba5:	6a 04                	push   $0x4
  800ba7:	68 9f 25 80 00       	push   $0x80259f
  800bac:	6a 23                	push   $0x23
  800bae:	68 bc 25 80 00       	push   $0x8025bc
  800bb3:	e8 dd 11 00 00       	call   801d95 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbb:	5b                   	pop    %ebx
  800bbc:	5e                   	pop    %esi
  800bbd:	5f                   	pop    %edi
  800bbe:	5d                   	pop    %ebp
  800bbf:	c3                   	ret    

00800bc0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	57                   	push   %edi
  800bc4:	56                   	push   %esi
  800bc5:	53                   	push   %ebx
  800bc6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc9:	b8 05 00 00 00       	mov    $0x5,%eax
  800bce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bda:	8b 75 18             	mov    0x18(%ebp),%esi
  800bdd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bdf:	85 c0                	test   %eax,%eax
  800be1:	7e 17                	jle    800bfa <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be3:	83 ec 0c             	sub    $0xc,%esp
  800be6:	50                   	push   %eax
  800be7:	6a 05                	push   $0x5
  800be9:	68 9f 25 80 00       	push   $0x80259f
  800bee:	6a 23                	push   $0x23
  800bf0:	68 bc 25 80 00       	push   $0x8025bc
  800bf5:	e8 9b 11 00 00       	call   801d95 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfd:	5b                   	pop    %ebx
  800bfe:	5e                   	pop    %esi
  800bff:	5f                   	pop    %edi
  800c00:	5d                   	pop    %ebp
  800c01:	c3                   	ret    

00800c02 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	57                   	push   %edi
  800c06:	56                   	push   %esi
  800c07:	53                   	push   %ebx
  800c08:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c10:	b8 06 00 00 00       	mov    $0x6,%eax
  800c15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c18:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1b:	89 df                	mov    %ebx,%edi
  800c1d:	89 de                	mov    %ebx,%esi
  800c1f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c21:	85 c0                	test   %eax,%eax
  800c23:	7e 17                	jle    800c3c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c25:	83 ec 0c             	sub    $0xc,%esp
  800c28:	50                   	push   %eax
  800c29:	6a 06                	push   $0x6
  800c2b:	68 9f 25 80 00       	push   $0x80259f
  800c30:	6a 23                	push   $0x23
  800c32:	68 bc 25 80 00       	push   $0x8025bc
  800c37:	e8 59 11 00 00       	call   801d95 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	57                   	push   %edi
  800c48:	56                   	push   %esi
  800c49:	53                   	push   %ebx
  800c4a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c52:	b8 08 00 00 00       	mov    $0x8,%eax
  800c57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5d:	89 df                	mov    %ebx,%edi
  800c5f:	89 de                	mov    %ebx,%esi
  800c61:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c63:	85 c0                	test   %eax,%eax
  800c65:	7e 17                	jle    800c7e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c67:	83 ec 0c             	sub    $0xc,%esp
  800c6a:	50                   	push   %eax
  800c6b:	6a 08                	push   $0x8
  800c6d:	68 9f 25 80 00       	push   $0x80259f
  800c72:	6a 23                	push   $0x23
  800c74:	68 bc 25 80 00       	push   $0x8025bc
  800c79:	e8 17 11 00 00       	call   801d95 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
  800c8c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c94:	b8 09 00 00 00       	mov    $0x9,%eax
  800c99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9f:	89 df                	mov    %ebx,%edi
  800ca1:	89 de                	mov    %ebx,%esi
  800ca3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca5:	85 c0                	test   %eax,%eax
  800ca7:	7e 17                	jle    800cc0 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca9:	83 ec 0c             	sub    $0xc,%esp
  800cac:	50                   	push   %eax
  800cad:	6a 09                	push   $0x9
  800caf:	68 9f 25 80 00       	push   $0x80259f
  800cb4:	6a 23                	push   $0x23
  800cb6:	68 bc 25 80 00       	push   $0x8025bc
  800cbb:	e8 d5 10 00 00       	call   801d95 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc3:	5b                   	pop    %ebx
  800cc4:	5e                   	pop    %esi
  800cc5:	5f                   	pop    %edi
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    

00800cc8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	57                   	push   %edi
  800ccc:	56                   	push   %esi
  800ccd:	53                   	push   %ebx
  800cce:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cde:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce1:	89 df                	mov    %ebx,%edi
  800ce3:	89 de                	mov    %ebx,%esi
  800ce5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce7:	85 c0                	test   %eax,%eax
  800ce9:	7e 17                	jle    800d02 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ceb:	83 ec 0c             	sub    $0xc,%esp
  800cee:	50                   	push   %eax
  800cef:	6a 0a                	push   $0xa
  800cf1:	68 9f 25 80 00       	push   $0x80259f
  800cf6:	6a 23                	push   $0x23
  800cf8:	68 bc 25 80 00       	push   $0x8025bc
  800cfd:	e8 93 10 00 00       	call   801d95 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d05:	5b                   	pop    %ebx
  800d06:	5e                   	pop    %esi
  800d07:	5f                   	pop    %edi
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    

00800d0a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	57                   	push   %edi
  800d0e:	56                   	push   %esi
  800d0f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d10:	be 00 00 00 00       	mov    $0x0,%esi
  800d15:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d20:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d23:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d26:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5f                   	pop    %edi
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    

00800d2d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	57                   	push   %edi
  800d31:	56                   	push   %esi
  800d32:	53                   	push   %ebx
  800d33:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d36:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d40:	8b 55 08             	mov    0x8(%ebp),%edx
  800d43:	89 cb                	mov    %ecx,%ebx
  800d45:	89 cf                	mov    %ecx,%edi
  800d47:	89 ce                	mov    %ecx,%esi
  800d49:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d4b:	85 c0                	test   %eax,%eax
  800d4d:	7e 17                	jle    800d66 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4f:	83 ec 0c             	sub    $0xc,%esp
  800d52:	50                   	push   %eax
  800d53:	6a 0d                	push   $0xd
  800d55:	68 9f 25 80 00       	push   $0x80259f
  800d5a:	6a 23                	push   $0x23
  800d5c:	68 bc 25 80 00       	push   $0x8025bc
  800d61:	e8 2f 10 00 00       	call   801d95 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d69:	5b                   	pop    %ebx
  800d6a:	5e                   	pop    %esi
  800d6b:	5f                   	pop    %edi
  800d6c:	5d                   	pop    %ebp
  800d6d:	c3                   	ret    

00800d6e <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d74:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d79:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d81:	89 cb                	mov    %ecx,%ebx
  800d83:	89 cf                	mov    %ecx,%edi
  800d85:	89 ce                	mov    %ecx,%esi
  800d87:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d89:	5b                   	pop    %ebx
  800d8a:	5e                   	pop    %esi
  800d8b:	5f                   	pop    %edi
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    

00800d8e <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	57                   	push   %edi
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d94:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d99:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800da1:	89 cb                	mov    %ecx,%ebx
  800da3:	89 cf                	mov    %ecx,%edi
  800da5:	89 ce                	mov    %ecx,%esi
  800da7:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5f                   	pop    %edi
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    

00800dae <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	53                   	push   %ebx
  800db2:	83 ec 04             	sub    $0x4,%esp
  800db5:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800db8:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800dba:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dbe:	74 11                	je     800dd1 <pgfault+0x23>
  800dc0:	89 d8                	mov    %ebx,%eax
  800dc2:	c1 e8 0c             	shr    $0xc,%eax
  800dc5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dcc:	f6 c4 08             	test   $0x8,%ah
  800dcf:	75 14                	jne    800de5 <pgfault+0x37>
		panic("faulting access");
  800dd1:	83 ec 04             	sub    $0x4,%esp
  800dd4:	68 ca 25 80 00       	push   $0x8025ca
  800dd9:	6a 1e                	push   $0x1e
  800ddb:	68 da 25 80 00       	push   $0x8025da
  800de0:	e8 b0 0f 00 00       	call   801d95 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800de5:	83 ec 04             	sub    $0x4,%esp
  800de8:	6a 07                	push   $0x7
  800dea:	68 00 f0 7f 00       	push   $0x7ff000
  800def:	6a 00                	push   $0x0
  800df1:	e8 87 fd ff ff       	call   800b7d <sys_page_alloc>
	if (r < 0) {
  800df6:	83 c4 10             	add    $0x10,%esp
  800df9:	85 c0                	test   %eax,%eax
  800dfb:	79 12                	jns    800e0f <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800dfd:	50                   	push   %eax
  800dfe:	68 e5 25 80 00       	push   $0x8025e5
  800e03:	6a 2c                	push   $0x2c
  800e05:	68 da 25 80 00       	push   $0x8025da
  800e0a:	e8 86 0f 00 00       	call   801d95 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e0f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e15:	83 ec 04             	sub    $0x4,%esp
  800e18:	68 00 10 00 00       	push   $0x1000
  800e1d:	53                   	push   %ebx
  800e1e:	68 00 f0 7f 00       	push   $0x7ff000
  800e23:	e8 4c fb ff ff       	call   800974 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e28:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e2f:	53                   	push   %ebx
  800e30:	6a 00                	push   $0x0
  800e32:	68 00 f0 7f 00       	push   $0x7ff000
  800e37:	6a 00                	push   $0x0
  800e39:	e8 82 fd ff ff       	call   800bc0 <sys_page_map>
	if (r < 0) {
  800e3e:	83 c4 20             	add    $0x20,%esp
  800e41:	85 c0                	test   %eax,%eax
  800e43:	79 12                	jns    800e57 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e45:	50                   	push   %eax
  800e46:	68 e5 25 80 00       	push   $0x8025e5
  800e4b:	6a 33                	push   $0x33
  800e4d:	68 da 25 80 00       	push   $0x8025da
  800e52:	e8 3e 0f 00 00       	call   801d95 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e57:	83 ec 08             	sub    $0x8,%esp
  800e5a:	68 00 f0 7f 00       	push   $0x7ff000
  800e5f:	6a 00                	push   $0x0
  800e61:	e8 9c fd ff ff       	call   800c02 <sys_page_unmap>
	if (r < 0) {
  800e66:	83 c4 10             	add    $0x10,%esp
  800e69:	85 c0                	test   %eax,%eax
  800e6b:	79 12                	jns    800e7f <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e6d:	50                   	push   %eax
  800e6e:	68 e5 25 80 00       	push   $0x8025e5
  800e73:	6a 37                	push   $0x37
  800e75:	68 da 25 80 00       	push   $0x8025da
  800e7a:	e8 16 0f 00 00       	call   801d95 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e82:	c9                   	leave  
  800e83:	c3                   	ret    

00800e84 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	57                   	push   %edi
  800e88:	56                   	push   %esi
  800e89:	53                   	push   %ebx
  800e8a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e8d:	68 ae 0d 80 00       	push   $0x800dae
  800e92:	e8 44 0f 00 00       	call   801ddb <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e97:	b8 07 00 00 00       	mov    $0x7,%eax
  800e9c:	cd 30                	int    $0x30
  800e9e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800ea1:	83 c4 10             	add    $0x10,%esp
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	79 17                	jns    800ebf <fork+0x3b>
		panic("fork fault %e");
  800ea8:	83 ec 04             	sub    $0x4,%esp
  800eab:	68 fe 25 80 00       	push   $0x8025fe
  800eb0:	68 84 00 00 00       	push   $0x84
  800eb5:	68 da 25 80 00       	push   $0x8025da
  800eba:	e8 d6 0e 00 00       	call   801d95 <_panic>
  800ebf:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800ec1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ec5:	75 24                	jne    800eeb <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ec7:	e8 73 fc ff ff       	call   800b3f <sys_getenvid>
  800ecc:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ed1:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800ed7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800edc:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800ee1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee6:	e9 64 01 00 00       	jmp    80104f <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800eeb:	83 ec 04             	sub    $0x4,%esp
  800eee:	6a 07                	push   $0x7
  800ef0:	68 00 f0 bf ee       	push   $0xeebff000
  800ef5:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ef8:	e8 80 fc ff ff       	call   800b7d <sys_page_alloc>
  800efd:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f00:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f05:	89 d8                	mov    %ebx,%eax
  800f07:	c1 e8 16             	shr    $0x16,%eax
  800f0a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f11:	a8 01                	test   $0x1,%al
  800f13:	0f 84 fc 00 00 00    	je     801015 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f19:	89 d8                	mov    %ebx,%eax
  800f1b:	c1 e8 0c             	shr    $0xc,%eax
  800f1e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f25:	f6 c2 01             	test   $0x1,%dl
  800f28:	0f 84 e7 00 00 00    	je     801015 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f2e:	89 c6                	mov    %eax,%esi
  800f30:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f33:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f3a:	f6 c6 04             	test   $0x4,%dh
  800f3d:	74 39                	je     800f78 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f3f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f46:	83 ec 0c             	sub    $0xc,%esp
  800f49:	25 07 0e 00 00       	and    $0xe07,%eax
  800f4e:	50                   	push   %eax
  800f4f:	56                   	push   %esi
  800f50:	57                   	push   %edi
  800f51:	56                   	push   %esi
  800f52:	6a 00                	push   $0x0
  800f54:	e8 67 fc ff ff       	call   800bc0 <sys_page_map>
		if (r < 0) {
  800f59:	83 c4 20             	add    $0x20,%esp
  800f5c:	85 c0                	test   %eax,%eax
  800f5e:	0f 89 b1 00 00 00    	jns    801015 <fork+0x191>
		    	panic("sys page map fault %e");
  800f64:	83 ec 04             	sub    $0x4,%esp
  800f67:	68 0c 26 80 00       	push   $0x80260c
  800f6c:	6a 54                	push   $0x54
  800f6e:	68 da 25 80 00       	push   $0x8025da
  800f73:	e8 1d 0e 00 00       	call   801d95 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f78:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f7f:	f6 c2 02             	test   $0x2,%dl
  800f82:	75 0c                	jne    800f90 <fork+0x10c>
  800f84:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f8b:	f6 c4 08             	test   $0x8,%ah
  800f8e:	74 5b                	je     800feb <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f90:	83 ec 0c             	sub    $0xc,%esp
  800f93:	68 05 08 00 00       	push   $0x805
  800f98:	56                   	push   %esi
  800f99:	57                   	push   %edi
  800f9a:	56                   	push   %esi
  800f9b:	6a 00                	push   $0x0
  800f9d:	e8 1e fc ff ff       	call   800bc0 <sys_page_map>
		if (r < 0) {
  800fa2:	83 c4 20             	add    $0x20,%esp
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	79 14                	jns    800fbd <fork+0x139>
		    	panic("sys page map fault %e");
  800fa9:	83 ec 04             	sub    $0x4,%esp
  800fac:	68 0c 26 80 00       	push   $0x80260c
  800fb1:	6a 5b                	push   $0x5b
  800fb3:	68 da 25 80 00       	push   $0x8025da
  800fb8:	e8 d8 0d 00 00       	call   801d95 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800fbd:	83 ec 0c             	sub    $0xc,%esp
  800fc0:	68 05 08 00 00       	push   $0x805
  800fc5:	56                   	push   %esi
  800fc6:	6a 00                	push   $0x0
  800fc8:	56                   	push   %esi
  800fc9:	6a 00                	push   $0x0
  800fcb:	e8 f0 fb ff ff       	call   800bc0 <sys_page_map>
		if (r < 0) {
  800fd0:	83 c4 20             	add    $0x20,%esp
  800fd3:	85 c0                	test   %eax,%eax
  800fd5:	79 3e                	jns    801015 <fork+0x191>
		    	panic("sys page map fault %e");
  800fd7:	83 ec 04             	sub    $0x4,%esp
  800fda:	68 0c 26 80 00       	push   $0x80260c
  800fdf:	6a 5f                	push   $0x5f
  800fe1:	68 da 25 80 00       	push   $0x8025da
  800fe6:	e8 aa 0d 00 00       	call   801d95 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800feb:	83 ec 0c             	sub    $0xc,%esp
  800fee:	6a 05                	push   $0x5
  800ff0:	56                   	push   %esi
  800ff1:	57                   	push   %edi
  800ff2:	56                   	push   %esi
  800ff3:	6a 00                	push   $0x0
  800ff5:	e8 c6 fb ff ff       	call   800bc0 <sys_page_map>
		if (r < 0) {
  800ffa:	83 c4 20             	add    $0x20,%esp
  800ffd:	85 c0                	test   %eax,%eax
  800fff:	79 14                	jns    801015 <fork+0x191>
		    	panic("sys page map fault %e");
  801001:	83 ec 04             	sub    $0x4,%esp
  801004:	68 0c 26 80 00       	push   $0x80260c
  801009:	6a 64                	push   $0x64
  80100b:	68 da 25 80 00       	push   $0x8025da
  801010:	e8 80 0d 00 00       	call   801d95 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801015:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80101b:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801021:	0f 85 de fe ff ff    	jne    800f05 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801027:	a1 04 40 80 00       	mov    0x804004,%eax
  80102c:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  801032:	83 ec 08             	sub    $0x8,%esp
  801035:	50                   	push   %eax
  801036:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801039:	57                   	push   %edi
  80103a:	e8 89 fc ff ff       	call   800cc8 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80103f:	83 c4 08             	add    $0x8,%esp
  801042:	6a 02                	push   $0x2
  801044:	57                   	push   %edi
  801045:	e8 fa fb ff ff       	call   800c44 <sys_env_set_status>
	
	return envid;
  80104a:	83 c4 10             	add    $0x10,%esp
  80104d:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80104f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801052:	5b                   	pop    %ebx
  801053:	5e                   	pop    %esi
  801054:	5f                   	pop    %edi
  801055:	5d                   	pop    %ebp
  801056:	c3                   	ret    

00801057 <sfork>:

envid_t
sfork(void)
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80105a:	b8 00 00 00 00       	mov    $0x0,%eax
  80105f:	5d                   	pop    %ebp
  801060:	c3                   	ret    

00801061 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
  801064:	56                   	push   %esi
  801065:	53                   	push   %ebx
  801066:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801069:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  80106f:	83 ec 08             	sub    $0x8,%esp
  801072:	53                   	push   %ebx
  801073:	68 24 26 80 00       	push   $0x802624
  801078:	e8 78 f1 ff ff       	call   8001f5 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80107d:	c7 04 24 28 01 80 00 	movl   $0x800128,(%esp)
  801084:	e8 e5 fc ff ff       	call   800d6e <sys_thread_create>
  801089:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80108b:	83 c4 08             	add    $0x8,%esp
  80108e:	53                   	push   %ebx
  80108f:	68 24 26 80 00       	push   $0x802624
  801094:	e8 5c f1 ff ff       	call   8001f5 <cprintf>
	return id;
}
  801099:	89 f0                	mov    %esi,%eax
  80109b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80109e:	5b                   	pop    %ebx
  80109f:	5e                   	pop    %esi
  8010a0:	5d                   	pop    %ebp
  8010a1:	c3                   	ret    

008010a2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a8:	05 00 00 00 30       	add    $0x30000000,%eax
  8010ad:	c1 e8 0c             	shr    $0xc,%eax
}
  8010b0:	5d                   	pop    %ebp
  8010b1:	c3                   	ret    

008010b2 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b8:	05 00 00 00 30       	add    $0x30000000,%eax
  8010bd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010c2:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010c7:	5d                   	pop    %ebp
  8010c8:	c3                   	ret    

008010c9 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010c9:	55                   	push   %ebp
  8010ca:	89 e5                	mov    %esp,%ebp
  8010cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010cf:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010d4:	89 c2                	mov    %eax,%edx
  8010d6:	c1 ea 16             	shr    $0x16,%edx
  8010d9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010e0:	f6 c2 01             	test   $0x1,%dl
  8010e3:	74 11                	je     8010f6 <fd_alloc+0x2d>
  8010e5:	89 c2                	mov    %eax,%edx
  8010e7:	c1 ea 0c             	shr    $0xc,%edx
  8010ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010f1:	f6 c2 01             	test   $0x1,%dl
  8010f4:	75 09                	jne    8010ff <fd_alloc+0x36>
			*fd_store = fd;
  8010f6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010fd:	eb 17                	jmp    801116 <fd_alloc+0x4d>
  8010ff:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801104:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801109:	75 c9                	jne    8010d4 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80110b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801111:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801116:	5d                   	pop    %ebp
  801117:	c3                   	ret    

00801118 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801118:	55                   	push   %ebp
  801119:	89 e5                	mov    %esp,%ebp
  80111b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80111e:	83 f8 1f             	cmp    $0x1f,%eax
  801121:	77 36                	ja     801159 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801123:	c1 e0 0c             	shl    $0xc,%eax
  801126:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80112b:	89 c2                	mov    %eax,%edx
  80112d:	c1 ea 16             	shr    $0x16,%edx
  801130:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801137:	f6 c2 01             	test   $0x1,%dl
  80113a:	74 24                	je     801160 <fd_lookup+0x48>
  80113c:	89 c2                	mov    %eax,%edx
  80113e:	c1 ea 0c             	shr    $0xc,%edx
  801141:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801148:	f6 c2 01             	test   $0x1,%dl
  80114b:	74 1a                	je     801167 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80114d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801150:	89 02                	mov    %eax,(%edx)
	return 0;
  801152:	b8 00 00 00 00       	mov    $0x0,%eax
  801157:	eb 13                	jmp    80116c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801159:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80115e:	eb 0c                	jmp    80116c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801160:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801165:	eb 05                	jmp    80116c <fd_lookup+0x54>
  801167:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80116c:	5d                   	pop    %ebp
  80116d:	c3                   	ret    

0080116e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
  801171:	83 ec 08             	sub    $0x8,%esp
  801174:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801177:	ba c4 26 80 00       	mov    $0x8026c4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80117c:	eb 13                	jmp    801191 <dev_lookup+0x23>
  80117e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801181:	39 08                	cmp    %ecx,(%eax)
  801183:	75 0c                	jne    801191 <dev_lookup+0x23>
			*dev = devtab[i];
  801185:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801188:	89 01                	mov    %eax,(%ecx)
			return 0;
  80118a:	b8 00 00 00 00       	mov    $0x0,%eax
  80118f:	eb 2e                	jmp    8011bf <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801191:	8b 02                	mov    (%edx),%eax
  801193:	85 c0                	test   %eax,%eax
  801195:	75 e7                	jne    80117e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801197:	a1 04 40 80 00       	mov    0x804004,%eax
  80119c:	8b 40 7c             	mov    0x7c(%eax),%eax
  80119f:	83 ec 04             	sub    $0x4,%esp
  8011a2:	51                   	push   %ecx
  8011a3:	50                   	push   %eax
  8011a4:	68 48 26 80 00       	push   $0x802648
  8011a9:	e8 47 f0 ff ff       	call   8001f5 <cprintf>
	*dev = 0;
  8011ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011b1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011b7:	83 c4 10             	add    $0x10,%esp
  8011ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011bf:	c9                   	leave  
  8011c0:	c3                   	ret    

008011c1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011c1:	55                   	push   %ebp
  8011c2:	89 e5                	mov    %esp,%ebp
  8011c4:	56                   	push   %esi
  8011c5:	53                   	push   %ebx
  8011c6:	83 ec 10             	sub    $0x10,%esp
  8011c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8011cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d2:	50                   	push   %eax
  8011d3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011d9:	c1 e8 0c             	shr    $0xc,%eax
  8011dc:	50                   	push   %eax
  8011dd:	e8 36 ff ff ff       	call   801118 <fd_lookup>
  8011e2:	83 c4 08             	add    $0x8,%esp
  8011e5:	85 c0                	test   %eax,%eax
  8011e7:	78 05                	js     8011ee <fd_close+0x2d>
	    || fd != fd2)
  8011e9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011ec:	74 0c                	je     8011fa <fd_close+0x39>
		return (must_exist ? r : 0);
  8011ee:	84 db                	test   %bl,%bl
  8011f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8011f5:	0f 44 c2             	cmove  %edx,%eax
  8011f8:	eb 41                	jmp    80123b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011fa:	83 ec 08             	sub    $0x8,%esp
  8011fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801200:	50                   	push   %eax
  801201:	ff 36                	pushl  (%esi)
  801203:	e8 66 ff ff ff       	call   80116e <dev_lookup>
  801208:	89 c3                	mov    %eax,%ebx
  80120a:	83 c4 10             	add    $0x10,%esp
  80120d:	85 c0                	test   %eax,%eax
  80120f:	78 1a                	js     80122b <fd_close+0x6a>
		if (dev->dev_close)
  801211:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801214:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801217:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80121c:	85 c0                	test   %eax,%eax
  80121e:	74 0b                	je     80122b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801220:	83 ec 0c             	sub    $0xc,%esp
  801223:	56                   	push   %esi
  801224:	ff d0                	call   *%eax
  801226:	89 c3                	mov    %eax,%ebx
  801228:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80122b:	83 ec 08             	sub    $0x8,%esp
  80122e:	56                   	push   %esi
  80122f:	6a 00                	push   $0x0
  801231:	e8 cc f9 ff ff       	call   800c02 <sys_page_unmap>
	return r;
  801236:	83 c4 10             	add    $0x10,%esp
  801239:	89 d8                	mov    %ebx,%eax
}
  80123b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80123e:	5b                   	pop    %ebx
  80123f:	5e                   	pop    %esi
  801240:	5d                   	pop    %ebp
  801241:	c3                   	ret    

00801242 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801242:	55                   	push   %ebp
  801243:	89 e5                	mov    %esp,%ebp
  801245:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801248:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80124b:	50                   	push   %eax
  80124c:	ff 75 08             	pushl  0x8(%ebp)
  80124f:	e8 c4 fe ff ff       	call   801118 <fd_lookup>
  801254:	83 c4 08             	add    $0x8,%esp
  801257:	85 c0                	test   %eax,%eax
  801259:	78 10                	js     80126b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80125b:	83 ec 08             	sub    $0x8,%esp
  80125e:	6a 01                	push   $0x1
  801260:	ff 75 f4             	pushl  -0xc(%ebp)
  801263:	e8 59 ff ff ff       	call   8011c1 <fd_close>
  801268:	83 c4 10             	add    $0x10,%esp
}
  80126b:	c9                   	leave  
  80126c:	c3                   	ret    

0080126d <close_all>:

void
close_all(void)
{
  80126d:	55                   	push   %ebp
  80126e:	89 e5                	mov    %esp,%ebp
  801270:	53                   	push   %ebx
  801271:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801274:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801279:	83 ec 0c             	sub    $0xc,%esp
  80127c:	53                   	push   %ebx
  80127d:	e8 c0 ff ff ff       	call   801242 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801282:	83 c3 01             	add    $0x1,%ebx
  801285:	83 c4 10             	add    $0x10,%esp
  801288:	83 fb 20             	cmp    $0x20,%ebx
  80128b:	75 ec                	jne    801279 <close_all+0xc>
		close(i);
}
  80128d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801290:	c9                   	leave  
  801291:	c3                   	ret    

00801292 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801292:	55                   	push   %ebp
  801293:	89 e5                	mov    %esp,%ebp
  801295:	57                   	push   %edi
  801296:	56                   	push   %esi
  801297:	53                   	push   %ebx
  801298:	83 ec 2c             	sub    $0x2c,%esp
  80129b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80129e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012a1:	50                   	push   %eax
  8012a2:	ff 75 08             	pushl  0x8(%ebp)
  8012a5:	e8 6e fe ff ff       	call   801118 <fd_lookup>
  8012aa:	83 c4 08             	add    $0x8,%esp
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	0f 88 c1 00 00 00    	js     801376 <dup+0xe4>
		return r;
	close(newfdnum);
  8012b5:	83 ec 0c             	sub    $0xc,%esp
  8012b8:	56                   	push   %esi
  8012b9:	e8 84 ff ff ff       	call   801242 <close>

	newfd = INDEX2FD(newfdnum);
  8012be:	89 f3                	mov    %esi,%ebx
  8012c0:	c1 e3 0c             	shl    $0xc,%ebx
  8012c3:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012c9:	83 c4 04             	add    $0x4,%esp
  8012cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012cf:	e8 de fd ff ff       	call   8010b2 <fd2data>
  8012d4:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012d6:	89 1c 24             	mov    %ebx,(%esp)
  8012d9:	e8 d4 fd ff ff       	call   8010b2 <fd2data>
  8012de:	83 c4 10             	add    $0x10,%esp
  8012e1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012e4:	89 f8                	mov    %edi,%eax
  8012e6:	c1 e8 16             	shr    $0x16,%eax
  8012e9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012f0:	a8 01                	test   $0x1,%al
  8012f2:	74 37                	je     80132b <dup+0x99>
  8012f4:	89 f8                	mov    %edi,%eax
  8012f6:	c1 e8 0c             	shr    $0xc,%eax
  8012f9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801300:	f6 c2 01             	test   $0x1,%dl
  801303:	74 26                	je     80132b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801305:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80130c:	83 ec 0c             	sub    $0xc,%esp
  80130f:	25 07 0e 00 00       	and    $0xe07,%eax
  801314:	50                   	push   %eax
  801315:	ff 75 d4             	pushl  -0x2c(%ebp)
  801318:	6a 00                	push   $0x0
  80131a:	57                   	push   %edi
  80131b:	6a 00                	push   $0x0
  80131d:	e8 9e f8 ff ff       	call   800bc0 <sys_page_map>
  801322:	89 c7                	mov    %eax,%edi
  801324:	83 c4 20             	add    $0x20,%esp
  801327:	85 c0                	test   %eax,%eax
  801329:	78 2e                	js     801359 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80132b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80132e:	89 d0                	mov    %edx,%eax
  801330:	c1 e8 0c             	shr    $0xc,%eax
  801333:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80133a:	83 ec 0c             	sub    $0xc,%esp
  80133d:	25 07 0e 00 00       	and    $0xe07,%eax
  801342:	50                   	push   %eax
  801343:	53                   	push   %ebx
  801344:	6a 00                	push   $0x0
  801346:	52                   	push   %edx
  801347:	6a 00                	push   $0x0
  801349:	e8 72 f8 ff ff       	call   800bc0 <sys_page_map>
  80134e:	89 c7                	mov    %eax,%edi
  801350:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801353:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801355:	85 ff                	test   %edi,%edi
  801357:	79 1d                	jns    801376 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801359:	83 ec 08             	sub    $0x8,%esp
  80135c:	53                   	push   %ebx
  80135d:	6a 00                	push   $0x0
  80135f:	e8 9e f8 ff ff       	call   800c02 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801364:	83 c4 08             	add    $0x8,%esp
  801367:	ff 75 d4             	pushl  -0x2c(%ebp)
  80136a:	6a 00                	push   $0x0
  80136c:	e8 91 f8 ff ff       	call   800c02 <sys_page_unmap>
	return r;
  801371:	83 c4 10             	add    $0x10,%esp
  801374:	89 f8                	mov    %edi,%eax
}
  801376:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801379:	5b                   	pop    %ebx
  80137a:	5e                   	pop    %esi
  80137b:	5f                   	pop    %edi
  80137c:	5d                   	pop    %ebp
  80137d:	c3                   	ret    

0080137e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80137e:	55                   	push   %ebp
  80137f:	89 e5                	mov    %esp,%ebp
  801381:	53                   	push   %ebx
  801382:	83 ec 14             	sub    $0x14,%esp
  801385:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801388:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138b:	50                   	push   %eax
  80138c:	53                   	push   %ebx
  80138d:	e8 86 fd ff ff       	call   801118 <fd_lookup>
  801392:	83 c4 08             	add    $0x8,%esp
  801395:	89 c2                	mov    %eax,%edx
  801397:	85 c0                	test   %eax,%eax
  801399:	78 6d                	js     801408 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139b:	83 ec 08             	sub    $0x8,%esp
  80139e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a1:	50                   	push   %eax
  8013a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a5:	ff 30                	pushl  (%eax)
  8013a7:	e8 c2 fd ff ff       	call   80116e <dev_lookup>
  8013ac:	83 c4 10             	add    $0x10,%esp
  8013af:	85 c0                	test   %eax,%eax
  8013b1:	78 4c                	js     8013ff <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013b3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013b6:	8b 42 08             	mov    0x8(%edx),%eax
  8013b9:	83 e0 03             	and    $0x3,%eax
  8013bc:	83 f8 01             	cmp    $0x1,%eax
  8013bf:	75 21                	jne    8013e2 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013c1:	a1 04 40 80 00       	mov    0x804004,%eax
  8013c6:	8b 40 7c             	mov    0x7c(%eax),%eax
  8013c9:	83 ec 04             	sub    $0x4,%esp
  8013cc:	53                   	push   %ebx
  8013cd:	50                   	push   %eax
  8013ce:	68 89 26 80 00       	push   $0x802689
  8013d3:	e8 1d ee ff ff       	call   8001f5 <cprintf>
		return -E_INVAL;
  8013d8:	83 c4 10             	add    $0x10,%esp
  8013db:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013e0:	eb 26                	jmp    801408 <read+0x8a>
	}
	if (!dev->dev_read)
  8013e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e5:	8b 40 08             	mov    0x8(%eax),%eax
  8013e8:	85 c0                	test   %eax,%eax
  8013ea:	74 17                	je     801403 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8013ec:	83 ec 04             	sub    $0x4,%esp
  8013ef:	ff 75 10             	pushl  0x10(%ebp)
  8013f2:	ff 75 0c             	pushl  0xc(%ebp)
  8013f5:	52                   	push   %edx
  8013f6:	ff d0                	call   *%eax
  8013f8:	89 c2                	mov    %eax,%edx
  8013fa:	83 c4 10             	add    $0x10,%esp
  8013fd:	eb 09                	jmp    801408 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ff:	89 c2                	mov    %eax,%edx
  801401:	eb 05                	jmp    801408 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801403:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801408:	89 d0                	mov    %edx,%eax
  80140a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140d:	c9                   	leave  
  80140e:	c3                   	ret    

0080140f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80140f:	55                   	push   %ebp
  801410:	89 e5                	mov    %esp,%ebp
  801412:	57                   	push   %edi
  801413:	56                   	push   %esi
  801414:	53                   	push   %ebx
  801415:	83 ec 0c             	sub    $0xc,%esp
  801418:	8b 7d 08             	mov    0x8(%ebp),%edi
  80141b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80141e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801423:	eb 21                	jmp    801446 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801425:	83 ec 04             	sub    $0x4,%esp
  801428:	89 f0                	mov    %esi,%eax
  80142a:	29 d8                	sub    %ebx,%eax
  80142c:	50                   	push   %eax
  80142d:	89 d8                	mov    %ebx,%eax
  80142f:	03 45 0c             	add    0xc(%ebp),%eax
  801432:	50                   	push   %eax
  801433:	57                   	push   %edi
  801434:	e8 45 ff ff ff       	call   80137e <read>
		if (m < 0)
  801439:	83 c4 10             	add    $0x10,%esp
  80143c:	85 c0                	test   %eax,%eax
  80143e:	78 10                	js     801450 <readn+0x41>
			return m;
		if (m == 0)
  801440:	85 c0                	test   %eax,%eax
  801442:	74 0a                	je     80144e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801444:	01 c3                	add    %eax,%ebx
  801446:	39 f3                	cmp    %esi,%ebx
  801448:	72 db                	jb     801425 <readn+0x16>
  80144a:	89 d8                	mov    %ebx,%eax
  80144c:	eb 02                	jmp    801450 <readn+0x41>
  80144e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801450:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801453:	5b                   	pop    %ebx
  801454:	5e                   	pop    %esi
  801455:	5f                   	pop    %edi
  801456:	5d                   	pop    %ebp
  801457:	c3                   	ret    

00801458 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801458:	55                   	push   %ebp
  801459:	89 e5                	mov    %esp,%ebp
  80145b:	53                   	push   %ebx
  80145c:	83 ec 14             	sub    $0x14,%esp
  80145f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801462:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801465:	50                   	push   %eax
  801466:	53                   	push   %ebx
  801467:	e8 ac fc ff ff       	call   801118 <fd_lookup>
  80146c:	83 c4 08             	add    $0x8,%esp
  80146f:	89 c2                	mov    %eax,%edx
  801471:	85 c0                	test   %eax,%eax
  801473:	78 68                	js     8014dd <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801475:	83 ec 08             	sub    $0x8,%esp
  801478:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147b:	50                   	push   %eax
  80147c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147f:	ff 30                	pushl  (%eax)
  801481:	e8 e8 fc ff ff       	call   80116e <dev_lookup>
  801486:	83 c4 10             	add    $0x10,%esp
  801489:	85 c0                	test   %eax,%eax
  80148b:	78 47                	js     8014d4 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80148d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801490:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801494:	75 21                	jne    8014b7 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801496:	a1 04 40 80 00       	mov    0x804004,%eax
  80149b:	8b 40 7c             	mov    0x7c(%eax),%eax
  80149e:	83 ec 04             	sub    $0x4,%esp
  8014a1:	53                   	push   %ebx
  8014a2:	50                   	push   %eax
  8014a3:	68 a5 26 80 00       	push   $0x8026a5
  8014a8:	e8 48 ed ff ff       	call   8001f5 <cprintf>
		return -E_INVAL;
  8014ad:	83 c4 10             	add    $0x10,%esp
  8014b0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014b5:	eb 26                	jmp    8014dd <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014ba:	8b 52 0c             	mov    0xc(%edx),%edx
  8014bd:	85 d2                	test   %edx,%edx
  8014bf:	74 17                	je     8014d8 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014c1:	83 ec 04             	sub    $0x4,%esp
  8014c4:	ff 75 10             	pushl  0x10(%ebp)
  8014c7:	ff 75 0c             	pushl  0xc(%ebp)
  8014ca:	50                   	push   %eax
  8014cb:	ff d2                	call   *%edx
  8014cd:	89 c2                	mov    %eax,%edx
  8014cf:	83 c4 10             	add    $0x10,%esp
  8014d2:	eb 09                	jmp    8014dd <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d4:	89 c2                	mov    %eax,%edx
  8014d6:	eb 05                	jmp    8014dd <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014d8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014dd:	89 d0                	mov    %edx,%eax
  8014df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e2:	c9                   	leave  
  8014e3:	c3                   	ret    

008014e4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014ea:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014ed:	50                   	push   %eax
  8014ee:	ff 75 08             	pushl  0x8(%ebp)
  8014f1:	e8 22 fc ff ff       	call   801118 <fd_lookup>
  8014f6:	83 c4 08             	add    $0x8,%esp
  8014f9:	85 c0                	test   %eax,%eax
  8014fb:	78 0e                	js     80150b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801500:	8b 55 0c             	mov    0xc(%ebp),%edx
  801503:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801506:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80150b:	c9                   	leave  
  80150c:	c3                   	ret    

0080150d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80150d:	55                   	push   %ebp
  80150e:	89 e5                	mov    %esp,%ebp
  801510:	53                   	push   %ebx
  801511:	83 ec 14             	sub    $0x14,%esp
  801514:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801517:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80151a:	50                   	push   %eax
  80151b:	53                   	push   %ebx
  80151c:	e8 f7 fb ff ff       	call   801118 <fd_lookup>
  801521:	83 c4 08             	add    $0x8,%esp
  801524:	89 c2                	mov    %eax,%edx
  801526:	85 c0                	test   %eax,%eax
  801528:	78 65                	js     80158f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152a:	83 ec 08             	sub    $0x8,%esp
  80152d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801530:	50                   	push   %eax
  801531:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801534:	ff 30                	pushl  (%eax)
  801536:	e8 33 fc ff ff       	call   80116e <dev_lookup>
  80153b:	83 c4 10             	add    $0x10,%esp
  80153e:	85 c0                	test   %eax,%eax
  801540:	78 44                	js     801586 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801542:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801545:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801549:	75 21                	jne    80156c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80154b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801550:	8b 40 7c             	mov    0x7c(%eax),%eax
  801553:	83 ec 04             	sub    $0x4,%esp
  801556:	53                   	push   %ebx
  801557:	50                   	push   %eax
  801558:	68 68 26 80 00       	push   $0x802668
  80155d:	e8 93 ec ff ff       	call   8001f5 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801562:	83 c4 10             	add    $0x10,%esp
  801565:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80156a:	eb 23                	jmp    80158f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80156c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80156f:	8b 52 18             	mov    0x18(%edx),%edx
  801572:	85 d2                	test   %edx,%edx
  801574:	74 14                	je     80158a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801576:	83 ec 08             	sub    $0x8,%esp
  801579:	ff 75 0c             	pushl  0xc(%ebp)
  80157c:	50                   	push   %eax
  80157d:	ff d2                	call   *%edx
  80157f:	89 c2                	mov    %eax,%edx
  801581:	83 c4 10             	add    $0x10,%esp
  801584:	eb 09                	jmp    80158f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801586:	89 c2                	mov    %eax,%edx
  801588:	eb 05                	jmp    80158f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80158a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80158f:	89 d0                	mov    %edx,%eax
  801591:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801594:	c9                   	leave  
  801595:	c3                   	ret    

00801596 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801596:	55                   	push   %ebp
  801597:	89 e5                	mov    %esp,%ebp
  801599:	53                   	push   %ebx
  80159a:	83 ec 14             	sub    $0x14,%esp
  80159d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a3:	50                   	push   %eax
  8015a4:	ff 75 08             	pushl  0x8(%ebp)
  8015a7:	e8 6c fb ff ff       	call   801118 <fd_lookup>
  8015ac:	83 c4 08             	add    $0x8,%esp
  8015af:	89 c2                	mov    %eax,%edx
  8015b1:	85 c0                	test   %eax,%eax
  8015b3:	78 58                	js     80160d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b5:	83 ec 08             	sub    $0x8,%esp
  8015b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015bb:	50                   	push   %eax
  8015bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015bf:	ff 30                	pushl  (%eax)
  8015c1:	e8 a8 fb ff ff       	call   80116e <dev_lookup>
  8015c6:	83 c4 10             	add    $0x10,%esp
  8015c9:	85 c0                	test   %eax,%eax
  8015cb:	78 37                	js     801604 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015d4:	74 32                	je     801608 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015d6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015d9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015e0:	00 00 00 
	stat->st_isdir = 0;
  8015e3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015ea:	00 00 00 
	stat->st_dev = dev;
  8015ed:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015f3:	83 ec 08             	sub    $0x8,%esp
  8015f6:	53                   	push   %ebx
  8015f7:	ff 75 f0             	pushl  -0x10(%ebp)
  8015fa:	ff 50 14             	call   *0x14(%eax)
  8015fd:	89 c2                	mov    %eax,%edx
  8015ff:	83 c4 10             	add    $0x10,%esp
  801602:	eb 09                	jmp    80160d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801604:	89 c2                	mov    %eax,%edx
  801606:	eb 05                	jmp    80160d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801608:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80160d:	89 d0                	mov    %edx,%eax
  80160f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801612:	c9                   	leave  
  801613:	c3                   	ret    

00801614 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	56                   	push   %esi
  801618:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801619:	83 ec 08             	sub    $0x8,%esp
  80161c:	6a 00                	push   $0x0
  80161e:	ff 75 08             	pushl  0x8(%ebp)
  801621:	e8 e3 01 00 00       	call   801809 <open>
  801626:	89 c3                	mov    %eax,%ebx
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	85 c0                	test   %eax,%eax
  80162d:	78 1b                	js     80164a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80162f:	83 ec 08             	sub    $0x8,%esp
  801632:	ff 75 0c             	pushl  0xc(%ebp)
  801635:	50                   	push   %eax
  801636:	e8 5b ff ff ff       	call   801596 <fstat>
  80163b:	89 c6                	mov    %eax,%esi
	close(fd);
  80163d:	89 1c 24             	mov    %ebx,(%esp)
  801640:	e8 fd fb ff ff       	call   801242 <close>
	return r;
  801645:	83 c4 10             	add    $0x10,%esp
  801648:	89 f0                	mov    %esi,%eax
}
  80164a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80164d:	5b                   	pop    %ebx
  80164e:	5e                   	pop    %esi
  80164f:	5d                   	pop    %ebp
  801650:	c3                   	ret    

00801651 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801651:	55                   	push   %ebp
  801652:	89 e5                	mov    %esp,%ebp
  801654:	56                   	push   %esi
  801655:	53                   	push   %ebx
  801656:	89 c6                	mov    %eax,%esi
  801658:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80165a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801661:	75 12                	jne    801675 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801663:	83 ec 0c             	sub    $0xc,%esp
  801666:	6a 01                	push   $0x1
  801668:	e8 da 08 00 00       	call   801f47 <ipc_find_env>
  80166d:	a3 00 40 80 00       	mov    %eax,0x804000
  801672:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801675:	6a 07                	push   $0x7
  801677:	68 00 50 80 00       	push   $0x805000
  80167c:	56                   	push   %esi
  80167d:	ff 35 00 40 80 00    	pushl  0x804000
  801683:	e8 5d 08 00 00       	call   801ee5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801688:	83 c4 0c             	add    $0xc,%esp
  80168b:	6a 00                	push   $0x0
  80168d:	53                   	push   %ebx
  80168e:	6a 00                	push   $0x0
  801690:	e8 d5 07 00 00       	call   801e6a <ipc_recv>
}
  801695:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801698:	5b                   	pop    %ebx
  801699:	5e                   	pop    %esi
  80169a:	5d                   	pop    %ebp
  80169b:	c3                   	ret    

0080169c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80169c:	55                   	push   %ebp
  80169d:	89 e5                	mov    %esp,%ebp
  80169f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016b0:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ba:	b8 02 00 00 00       	mov    $0x2,%eax
  8016bf:	e8 8d ff ff ff       	call   801651 <fsipc>
}
  8016c4:	c9                   	leave  
  8016c5:	c3                   	ret    

008016c6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016c6:	55                   	push   %ebp
  8016c7:	89 e5                	mov    %esp,%ebp
  8016c9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cf:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016dc:	b8 06 00 00 00       	mov    $0x6,%eax
  8016e1:	e8 6b ff ff ff       	call   801651 <fsipc>
}
  8016e6:	c9                   	leave  
  8016e7:	c3                   	ret    

008016e8 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	53                   	push   %ebx
  8016ec:	83 ec 04             	sub    $0x4,%esp
  8016ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801702:	b8 05 00 00 00       	mov    $0x5,%eax
  801707:	e8 45 ff ff ff       	call   801651 <fsipc>
  80170c:	85 c0                	test   %eax,%eax
  80170e:	78 2c                	js     80173c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801710:	83 ec 08             	sub    $0x8,%esp
  801713:	68 00 50 80 00       	push   $0x805000
  801718:	53                   	push   %ebx
  801719:	e8 5c f0 ff ff       	call   80077a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80171e:	a1 80 50 80 00       	mov    0x805080,%eax
  801723:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801729:	a1 84 50 80 00       	mov    0x805084,%eax
  80172e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801734:	83 c4 10             	add    $0x10,%esp
  801737:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80173c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80173f:	c9                   	leave  
  801740:	c3                   	ret    

00801741 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801741:	55                   	push   %ebp
  801742:	89 e5                	mov    %esp,%ebp
  801744:	83 ec 0c             	sub    $0xc,%esp
  801747:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80174a:	8b 55 08             	mov    0x8(%ebp),%edx
  80174d:	8b 52 0c             	mov    0xc(%edx),%edx
  801750:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801756:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80175b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801760:	0f 47 c2             	cmova  %edx,%eax
  801763:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801768:	50                   	push   %eax
  801769:	ff 75 0c             	pushl  0xc(%ebp)
  80176c:	68 08 50 80 00       	push   $0x805008
  801771:	e8 96 f1 ff ff       	call   80090c <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801776:	ba 00 00 00 00       	mov    $0x0,%edx
  80177b:	b8 04 00 00 00       	mov    $0x4,%eax
  801780:	e8 cc fe ff ff       	call   801651 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801785:	c9                   	leave  
  801786:	c3                   	ret    

00801787 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	56                   	push   %esi
  80178b:	53                   	push   %ebx
  80178c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80178f:	8b 45 08             	mov    0x8(%ebp),%eax
  801792:	8b 40 0c             	mov    0xc(%eax),%eax
  801795:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80179a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a5:	b8 03 00 00 00       	mov    $0x3,%eax
  8017aa:	e8 a2 fe ff ff       	call   801651 <fsipc>
  8017af:	89 c3                	mov    %eax,%ebx
  8017b1:	85 c0                	test   %eax,%eax
  8017b3:	78 4b                	js     801800 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017b5:	39 c6                	cmp    %eax,%esi
  8017b7:	73 16                	jae    8017cf <devfile_read+0x48>
  8017b9:	68 d4 26 80 00       	push   $0x8026d4
  8017be:	68 db 26 80 00       	push   $0x8026db
  8017c3:	6a 7c                	push   $0x7c
  8017c5:	68 f0 26 80 00       	push   $0x8026f0
  8017ca:	e8 c6 05 00 00       	call   801d95 <_panic>
	assert(r <= PGSIZE);
  8017cf:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017d4:	7e 16                	jle    8017ec <devfile_read+0x65>
  8017d6:	68 fb 26 80 00       	push   $0x8026fb
  8017db:	68 db 26 80 00       	push   $0x8026db
  8017e0:	6a 7d                	push   $0x7d
  8017e2:	68 f0 26 80 00       	push   $0x8026f0
  8017e7:	e8 a9 05 00 00       	call   801d95 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017ec:	83 ec 04             	sub    $0x4,%esp
  8017ef:	50                   	push   %eax
  8017f0:	68 00 50 80 00       	push   $0x805000
  8017f5:	ff 75 0c             	pushl  0xc(%ebp)
  8017f8:	e8 0f f1 ff ff       	call   80090c <memmove>
	return r;
  8017fd:	83 c4 10             	add    $0x10,%esp
}
  801800:	89 d8                	mov    %ebx,%eax
  801802:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801805:	5b                   	pop    %ebx
  801806:	5e                   	pop    %esi
  801807:	5d                   	pop    %ebp
  801808:	c3                   	ret    

00801809 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801809:	55                   	push   %ebp
  80180a:	89 e5                	mov    %esp,%ebp
  80180c:	53                   	push   %ebx
  80180d:	83 ec 20             	sub    $0x20,%esp
  801810:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801813:	53                   	push   %ebx
  801814:	e8 28 ef ff ff       	call   800741 <strlen>
  801819:	83 c4 10             	add    $0x10,%esp
  80181c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801821:	7f 67                	jg     80188a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801823:	83 ec 0c             	sub    $0xc,%esp
  801826:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801829:	50                   	push   %eax
  80182a:	e8 9a f8 ff ff       	call   8010c9 <fd_alloc>
  80182f:	83 c4 10             	add    $0x10,%esp
		return r;
  801832:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801834:	85 c0                	test   %eax,%eax
  801836:	78 57                	js     80188f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801838:	83 ec 08             	sub    $0x8,%esp
  80183b:	53                   	push   %ebx
  80183c:	68 00 50 80 00       	push   $0x805000
  801841:	e8 34 ef ff ff       	call   80077a <strcpy>
	fsipcbuf.open.req_omode = mode;
  801846:	8b 45 0c             	mov    0xc(%ebp),%eax
  801849:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80184e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801851:	b8 01 00 00 00       	mov    $0x1,%eax
  801856:	e8 f6 fd ff ff       	call   801651 <fsipc>
  80185b:	89 c3                	mov    %eax,%ebx
  80185d:	83 c4 10             	add    $0x10,%esp
  801860:	85 c0                	test   %eax,%eax
  801862:	79 14                	jns    801878 <open+0x6f>
		fd_close(fd, 0);
  801864:	83 ec 08             	sub    $0x8,%esp
  801867:	6a 00                	push   $0x0
  801869:	ff 75 f4             	pushl  -0xc(%ebp)
  80186c:	e8 50 f9 ff ff       	call   8011c1 <fd_close>
		return r;
  801871:	83 c4 10             	add    $0x10,%esp
  801874:	89 da                	mov    %ebx,%edx
  801876:	eb 17                	jmp    80188f <open+0x86>
	}

	return fd2num(fd);
  801878:	83 ec 0c             	sub    $0xc,%esp
  80187b:	ff 75 f4             	pushl  -0xc(%ebp)
  80187e:	e8 1f f8 ff ff       	call   8010a2 <fd2num>
  801883:	89 c2                	mov    %eax,%edx
  801885:	83 c4 10             	add    $0x10,%esp
  801888:	eb 05                	jmp    80188f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80188a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80188f:	89 d0                	mov    %edx,%eax
  801891:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801894:	c9                   	leave  
  801895:	c3                   	ret    

00801896 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801896:	55                   	push   %ebp
  801897:	89 e5                	mov    %esp,%ebp
  801899:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80189c:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a1:	b8 08 00 00 00       	mov    $0x8,%eax
  8018a6:	e8 a6 fd ff ff       	call   801651 <fsipc>
}
  8018ab:	c9                   	leave  
  8018ac:	c3                   	ret    

008018ad <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018ad:	55                   	push   %ebp
  8018ae:	89 e5                	mov    %esp,%ebp
  8018b0:	56                   	push   %esi
  8018b1:	53                   	push   %ebx
  8018b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018b5:	83 ec 0c             	sub    $0xc,%esp
  8018b8:	ff 75 08             	pushl  0x8(%ebp)
  8018bb:	e8 f2 f7 ff ff       	call   8010b2 <fd2data>
  8018c0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018c2:	83 c4 08             	add    $0x8,%esp
  8018c5:	68 07 27 80 00       	push   $0x802707
  8018ca:	53                   	push   %ebx
  8018cb:	e8 aa ee ff ff       	call   80077a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018d0:	8b 46 04             	mov    0x4(%esi),%eax
  8018d3:	2b 06                	sub    (%esi),%eax
  8018d5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018db:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018e2:	00 00 00 
	stat->st_dev = &devpipe;
  8018e5:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018ec:	30 80 00 
	return 0;
}
  8018ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f7:	5b                   	pop    %ebx
  8018f8:	5e                   	pop    %esi
  8018f9:	5d                   	pop    %ebp
  8018fa:	c3                   	ret    

008018fb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018fb:	55                   	push   %ebp
  8018fc:	89 e5                	mov    %esp,%ebp
  8018fe:	53                   	push   %ebx
  8018ff:	83 ec 0c             	sub    $0xc,%esp
  801902:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801905:	53                   	push   %ebx
  801906:	6a 00                	push   $0x0
  801908:	e8 f5 f2 ff ff       	call   800c02 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80190d:	89 1c 24             	mov    %ebx,(%esp)
  801910:	e8 9d f7 ff ff       	call   8010b2 <fd2data>
  801915:	83 c4 08             	add    $0x8,%esp
  801918:	50                   	push   %eax
  801919:	6a 00                	push   $0x0
  80191b:	e8 e2 f2 ff ff       	call   800c02 <sys_page_unmap>
}
  801920:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801923:	c9                   	leave  
  801924:	c3                   	ret    

00801925 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801925:	55                   	push   %ebp
  801926:	89 e5                	mov    %esp,%ebp
  801928:	57                   	push   %edi
  801929:	56                   	push   %esi
  80192a:	53                   	push   %ebx
  80192b:	83 ec 1c             	sub    $0x1c,%esp
  80192e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801931:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801933:	a1 04 40 80 00       	mov    0x804004,%eax
  801938:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80193e:	83 ec 0c             	sub    $0xc,%esp
  801941:	ff 75 e0             	pushl  -0x20(%ebp)
  801944:	e8 40 06 00 00       	call   801f89 <pageref>
  801949:	89 c3                	mov    %eax,%ebx
  80194b:	89 3c 24             	mov    %edi,(%esp)
  80194e:	e8 36 06 00 00       	call   801f89 <pageref>
  801953:	83 c4 10             	add    $0x10,%esp
  801956:	39 c3                	cmp    %eax,%ebx
  801958:	0f 94 c1             	sete   %cl
  80195b:	0f b6 c9             	movzbl %cl,%ecx
  80195e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801961:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801967:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  80196d:	39 ce                	cmp    %ecx,%esi
  80196f:	74 1e                	je     80198f <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801971:	39 c3                	cmp    %eax,%ebx
  801973:	75 be                	jne    801933 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801975:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  80197b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80197e:	50                   	push   %eax
  80197f:	56                   	push   %esi
  801980:	68 0e 27 80 00       	push   $0x80270e
  801985:	e8 6b e8 ff ff       	call   8001f5 <cprintf>
  80198a:	83 c4 10             	add    $0x10,%esp
  80198d:	eb a4                	jmp    801933 <_pipeisclosed+0xe>
	}
}
  80198f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801992:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801995:	5b                   	pop    %ebx
  801996:	5e                   	pop    %esi
  801997:	5f                   	pop    %edi
  801998:	5d                   	pop    %ebp
  801999:	c3                   	ret    

0080199a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80199a:	55                   	push   %ebp
  80199b:	89 e5                	mov    %esp,%ebp
  80199d:	57                   	push   %edi
  80199e:	56                   	push   %esi
  80199f:	53                   	push   %ebx
  8019a0:	83 ec 28             	sub    $0x28,%esp
  8019a3:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019a6:	56                   	push   %esi
  8019a7:	e8 06 f7 ff ff       	call   8010b2 <fd2data>
  8019ac:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019ae:	83 c4 10             	add    $0x10,%esp
  8019b1:	bf 00 00 00 00       	mov    $0x0,%edi
  8019b6:	eb 4b                	jmp    801a03 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019b8:	89 da                	mov    %ebx,%edx
  8019ba:	89 f0                	mov    %esi,%eax
  8019bc:	e8 64 ff ff ff       	call   801925 <_pipeisclosed>
  8019c1:	85 c0                	test   %eax,%eax
  8019c3:	75 48                	jne    801a0d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019c5:	e8 94 f1 ff ff       	call   800b5e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019ca:	8b 43 04             	mov    0x4(%ebx),%eax
  8019cd:	8b 0b                	mov    (%ebx),%ecx
  8019cf:	8d 51 20             	lea    0x20(%ecx),%edx
  8019d2:	39 d0                	cmp    %edx,%eax
  8019d4:	73 e2                	jae    8019b8 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019d9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019dd:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019e0:	89 c2                	mov    %eax,%edx
  8019e2:	c1 fa 1f             	sar    $0x1f,%edx
  8019e5:	89 d1                	mov    %edx,%ecx
  8019e7:	c1 e9 1b             	shr    $0x1b,%ecx
  8019ea:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019ed:	83 e2 1f             	and    $0x1f,%edx
  8019f0:	29 ca                	sub    %ecx,%edx
  8019f2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019f6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019fa:	83 c0 01             	add    $0x1,%eax
  8019fd:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a00:	83 c7 01             	add    $0x1,%edi
  801a03:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a06:	75 c2                	jne    8019ca <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a08:	8b 45 10             	mov    0x10(%ebp),%eax
  801a0b:	eb 05                	jmp    801a12 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a0d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a15:	5b                   	pop    %ebx
  801a16:	5e                   	pop    %esi
  801a17:	5f                   	pop    %edi
  801a18:	5d                   	pop    %ebp
  801a19:	c3                   	ret    

00801a1a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a1a:	55                   	push   %ebp
  801a1b:	89 e5                	mov    %esp,%ebp
  801a1d:	57                   	push   %edi
  801a1e:	56                   	push   %esi
  801a1f:	53                   	push   %ebx
  801a20:	83 ec 18             	sub    $0x18,%esp
  801a23:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a26:	57                   	push   %edi
  801a27:	e8 86 f6 ff ff       	call   8010b2 <fd2data>
  801a2c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a2e:	83 c4 10             	add    $0x10,%esp
  801a31:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a36:	eb 3d                	jmp    801a75 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a38:	85 db                	test   %ebx,%ebx
  801a3a:	74 04                	je     801a40 <devpipe_read+0x26>
				return i;
  801a3c:	89 d8                	mov    %ebx,%eax
  801a3e:	eb 44                	jmp    801a84 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a40:	89 f2                	mov    %esi,%edx
  801a42:	89 f8                	mov    %edi,%eax
  801a44:	e8 dc fe ff ff       	call   801925 <_pipeisclosed>
  801a49:	85 c0                	test   %eax,%eax
  801a4b:	75 32                	jne    801a7f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a4d:	e8 0c f1 ff ff       	call   800b5e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a52:	8b 06                	mov    (%esi),%eax
  801a54:	3b 46 04             	cmp    0x4(%esi),%eax
  801a57:	74 df                	je     801a38 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a59:	99                   	cltd   
  801a5a:	c1 ea 1b             	shr    $0x1b,%edx
  801a5d:	01 d0                	add    %edx,%eax
  801a5f:	83 e0 1f             	and    $0x1f,%eax
  801a62:	29 d0                	sub    %edx,%eax
  801a64:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a6c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a6f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a72:	83 c3 01             	add    $0x1,%ebx
  801a75:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a78:	75 d8                	jne    801a52 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a7a:	8b 45 10             	mov    0x10(%ebp),%eax
  801a7d:	eb 05                	jmp    801a84 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a7f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a87:	5b                   	pop    %ebx
  801a88:	5e                   	pop    %esi
  801a89:	5f                   	pop    %edi
  801a8a:	5d                   	pop    %ebp
  801a8b:	c3                   	ret    

00801a8c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a8c:	55                   	push   %ebp
  801a8d:	89 e5                	mov    %esp,%ebp
  801a8f:	56                   	push   %esi
  801a90:	53                   	push   %ebx
  801a91:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a94:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a97:	50                   	push   %eax
  801a98:	e8 2c f6 ff ff       	call   8010c9 <fd_alloc>
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	89 c2                	mov    %eax,%edx
  801aa2:	85 c0                	test   %eax,%eax
  801aa4:	0f 88 2c 01 00 00    	js     801bd6 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aaa:	83 ec 04             	sub    $0x4,%esp
  801aad:	68 07 04 00 00       	push   $0x407
  801ab2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ab5:	6a 00                	push   $0x0
  801ab7:	e8 c1 f0 ff ff       	call   800b7d <sys_page_alloc>
  801abc:	83 c4 10             	add    $0x10,%esp
  801abf:	89 c2                	mov    %eax,%edx
  801ac1:	85 c0                	test   %eax,%eax
  801ac3:	0f 88 0d 01 00 00    	js     801bd6 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ac9:	83 ec 0c             	sub    $0xc,%esp
  801acc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801acf:	50                   	push   %eax
  801ad0:	e8 f4 f5 ff ff       	call   8010c9 <fd_alloc>
  801ad5:	89 c3                	mov    %eax,%ebx
  801ad7:	83 c4 10             	add    $0x10,%esp
  801ada:	85 c0                	test   %eax,%eax
  801adc:	0f 88 e2 00 00 00    	js     801bc4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ae2:	83 ec 04             	sub    $0x4,%esp
  801ae5:	68 07 04 00 00       	push   $0x407
  801aea:	ff 75 f0             	pushl  -0x10(%ebp)
  801aed:	6a 00                	push   $0x0
  801aef:	e8 89 f0 ff ff       	call   800b7d <sys_page_alloc>
  801af4:	89 c3                	mov    %eax,%ebx
  801af6:	83 c4 10             	add    $0x10,%esp
  801af9:	85 c0                	test   %eax,%eax
  801afb:	0f 88 c3 00 00 00    	js     801bc4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b01:	83 ec 0c             	sub    $0xc,%esp
  801b04:	ff 75 f4             	pushl  -0xc(%ebp)
  801b07:	e8 a6 f5 ff ff       	call   8010b2 <fd2data>
  801b0c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b0e:	83 c4 0c             	add    $0xc,%esp
  801b11:	68 07 04 00 00       	push   $0x407
  801b16:	50                   	push   %eax
  801b17:	6a 00                	push   $0x0
  801b19:	e8 5f f0 ff ff       	call   800b7d <sys_page_alloc>
  801b1e:	89 c3                	mov    %eax,%ebx
  801b20:	83 c4 10             	add    $0x10,%esp
  801b23:	85 c0                	test   %eax,%eax
  801b25:	0f 88 89 00 00 00    	js     801bb4 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b2b:	83 ec 0c             	sub    $0xc,%esp
  801b2e:	ff 75 f0             	pushl  -0x10(%ebp)
  801b31:	e8 7c f5 ff ff       	call   8010b2 <fd2data>
  801b36:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b3d:	50                   	push   %eax
  801b3e:	6a 00                	push   $0x0
  801b40:	56                   	push   %esi
  801b41:	6a 00                	push   $0x0
  801b43:	e8 78 f0 ff ff       	call   800bc0 <sys_page_map>
  801b48:	89 c3                	mov    %eax,%ebx
  801b4a:	83 c4 20             	add    $0x20,%esp
  801b4d:	85 c0                	test   %eax,%eax
  801b4f:	78 55                	js     801ba6 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b51:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b66:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b6f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b71:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b74:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b7b:	83 ec 0c             	sub    $0xc,%esp
  801b7e:	ff 75 f4             	pushl  -0xc(%ebp)
  801b81:	e8 1c f5 ff ff       	call   8010a2 <fd2num>
  801b86:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b89:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b8b:	83 c4 04             	add    $0x4,%esp
  801b8e:	ff 75 f0             	pushl  -0x10(%ebp)
  801b91:	e8 0c f5 ff ff       	call   8010a2 <fd2num>
  801b96:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b99:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801b9c:	83 c4 10             	add    $0x10,%esp
  801b9f:	ba 00 00 00 00       	mov    $0x0,%edx
  801ba4:	eb 30                	jmp    801bd6 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ba6:	83 ec 08             	sub    $0x8,%esp
  801ba9:	56                   	push   %esi
  801baa:	6a 00                	push   $0x0
  801bac:	e8 51 f0 ff ff       	call   800c02 <sys_page_unmap>
  801bb1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801bb4:	83 ec 08             	sub    $0x8,%esp
  801bb7:	ff 75 f0             	pushl  -0x10(%ebp)
  801bba:	6a 00                	push   $0x0
  801bbc:	e8 41 f0 ff ff       	call   800c02 <sys_page_unmap>
  801bc1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801bc4:	83 ec 08             	sub    $0x8,%esp
  801bc7:	ff 75 f4             	pushl  -0xc(%ebp)
  801bca:	6a 00                	push   $0x0
  801bcc:	e8 31 f0 ff ff       	call   800c02 <sys_page_unmap>
  801bd1:	83 c4 10             	add    $0x10,%esp
  801bd4:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801bd6:	89 d0                	mov    %edx,%eax
  801bd8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bdb:	5b                   	pop    %ebx
  801bdc:	5e                   	pop    %esi
  801bdd:	5d                   	pop    %ebp
  801bde:	c3                   	ret    

00801bdf <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801be5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be8:	50                   	push   %eax
  801be9:	ff 75 08             	pushl  0x8(%ebp)
  801bec:	e8 27 f5 ff ff       	call   801118 <fd_lookup>
  801bf1:	83 c4 10             	add    $0x10,%esp
  801bf4:	85 c0                	test   %eax,%eax
  801bf6:	78 18                	js     801c10 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bf8:	83 ec 0c             	sub    $0xc,%esp
  801bfb:	ff 75 f4             	pushl  -0xc(%ebp)
  801bfe:	e8 af f4 ff ff       	call   8010b2 <fd2data>
	return _pipeisclosed(fd, p);
  801c03:	89 c2                	mov    %eax,%edx
  801c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c08:	e8 18 fd ff ff       	call   801925 <_pipeisclosed>
  801c0d:	83 c4 10             	add    $0x10,%esp
}
  801c10:	c9                   	leave  
  801c11:	c3                   	ret    

00801c12 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c12:	55                   	push   %ebp
  801c13:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c15:	b8 00 00 00 00       	mov    $0x0,%eax
  801c1a:	5d                   	pop    %ebp
  801c1b:	c3                   	ret    

00801c1c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c1c:	55                   	push   %ebp
  801c1d:	89 e5                	mov    %esp,%ebp
  801c1f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c22:	68 26 27 80 00       	push   $0x802726
  801c27:	ff 75 0c             	pushl  0xc(%ebp)
  801c2a:	e8 4b eb ff ff       	call   80077a <strcpy>
	return 0;
}
  801c2f:	b8 00 00 00 00       	mov    $0x0,%eax
  801c34:	c9                   	leave  
  801c35:	c3                   	ret    

00801c36 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c36:	55                   	push   %ebp
  801c37:	89 e5                	mov    %esp,%ebp
  801c39:	57                   	push   %edi
  801c3a:	56                   	push   %esi
  801c3b:	53                   	push   %ebx
  801c3c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c42:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c47:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c4d:	eb 2d                	jmp    801c7c <devcons_write+0x46>
		m = n - tot;
  801c4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c52:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c54:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c57:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c5c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c5f:	83 ec 04             	sub    $0x4,%esp
  801c62:	53                   	push   %ebx
  801c63:	03 45 0c             	add    0xc(%ebp),%eax
  801c66:	50                   	push   %eax
  801c67:	57                   	push   %edi
  801c68:	e8 9f ec ff ff       	call   80090c <memmove>
		sys_cputs(buf, m);
  801c6d:	83 c4 08             	add    $0x8,%esp
  801c70:	53                   	push   %ebx
  801c71:	57                   	push   %edi
  801c72:	e8 4a ee ff ff       	call   800ac1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c77:	01 de                	add    %ebx,%esi
  801c79:	83 c4 10             	add    $0x10,%esp
  801c7c:	89 f0                	mov    %esi,%eax
  801c7e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c81:	72 cc                	jb     801c4f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c86:	5b                   	pop    %ebx
  801c87:	5e                   	pop    %esi
  801c88:	5f                   	pop    %edi
  801c89:	5d                   	pop    %ebp
  801c8a:	c3                   	ret    

00801c8b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c8b:	55                   	push   %ebp
  801c8c:	89 e5                	mov    %esp,%ebp
  801c8e:	83 ec 08             	sub    $0x8,%esp
  801c91:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c96:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c9a:	74 2a                	je     801cc6 <devcons_read+0x3b>
  801c9c:	eb 05                	jmp    801ca3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c9e:	e8 bb ee ff ff       	call   800b5e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ca3:	e8 37 ee ff ff       	call   800adf <sys_cgetc>
  801ca8:	85 c0                	test   %eax,%eax
  801caa:	74 f2                	je     801c9e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801cac:	85 c0                	test   %eax,%eax
  801cae:	78 16                	js     801cc6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801cb0:	83 f8 04             	cmp    $0x4,%eax
  801cb3:	74 0c                	je     801cc1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801cb5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cb8:	88 02                	mov    %al,(%edx)
	return 1;
  801cba:	b8 01 00 00 00       	mov    $0x1,%eax
  801cbf:	eb 05                	jmp    801cc6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801cc1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801cc6:	c9                   	leave  
  801cc7:	c3                   	ret    

00801cc8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801cc8:	55                   	push   %ebp
  801cc9:	89 e5                	mov    %esp,%ebp
  801ccb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cce:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cd4:	6a 01                	push   $0x1
  801cd6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cd9:	50                   	push   %eax
  801cda:	e8 e2 ed ff ff       	call   800ac1 <sys_cputs>
}
  801cdf:	83 c4 10             	add    $0x10,%esp
  801ce2:	c9                   	leave  
  801ce3:	c3                   	ret    

00801ce4 <getchar>:

int
getchar(void)
{
  801ce4:	55                   	push   %ebp
  801ce5:	89 e5                	mov    %esp,%ebp
  801ce7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801cea:	6a 01                	push   $0x1
  801cec:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cef:	50                   	push   %eax
  801cf0:	6a 00                	push   $0x0
  801cf2:	e8 87 f6 ff ff       	call   80137e <read>
	if (r < 0)
  801cf7:	83 c4 10             	add    $0x10,%esp
  801cfa:	85 c0                	test   %eax,%eax
  801cfc:	78 0f                	js     801d0d <getchar+0x29>
		return r;
	if (r < 1)
  801cfe:	85 c0                	test   %eax,%eax
  801d00:	7e 06                	jle    801d08 <getchar+0x24>
		return -E_EOF;
	return c;
  801d02:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d06:	eb 05                	jmp    801d0d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d08:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d0d:	c9                   	leave  
  801d0e:	c3                   	ret    

00801d0f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d0f:	55                   	push   %ebp
  801d10:	89 e5                	mov    %esp,%ebp
  801d12:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d15:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d18:	50                   	push   %eax
  801d19:	ff 75 08             	pushl  0x8(%ebp)
  801d1c:	e8 f7 f3 ff ff       	call   801118 <fd_lookup>
  801d21:	83 c4 10             	add    $0x10,%esp
  801d24:	85 c0                	test   %eax,%eax
  801d26:	78 11                	js     801d39 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d31:	39 10                	cmp    %edx,(%eax)
  801d33:	0f 94 c0             	sete   %al
  801d36:	0f b6 c0             	movzbl %al,%eax
}
  801d39:	c9                   	leave  
  801d3a:	c3                   	ret    

00801d3b <opencons>:

int
opencons(void)
{
  801d3b:	55                   	push   %ebp
  801d3c:	89 e5                	mov    %esp,%ebp
  801d3e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d44:	50                   	push   %eax
  801d45:	e8 7f f3 ff ff       	call   8010c9 <fd_alloc>
  801d4a:	83 c4 10             	add    $0x10,%esp
		return r;
  801d4d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d4f:	85 c0                	test   %eax,%eax
  801d51:	78 3e                	js     801d91 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d53:	83 ec 04             	sub    $0x4,%esp
  801d56:	68 07 04 00 00       	push   $0x407
  801d5b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d5e:	6a 00                	push   $0x0
  801d60:	e8 18 ee ff ff       	call   800b7d <sys_page_alloc>
  801d65:	83 c4 10             	add    $0x10,%esp
		return r;
  801d68:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d6a:	85 c0                	test   %eax,%eax
  801d6c:	78 23                	js     801d91 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d6e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d77:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d7c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d83:	83 ec 0c             	sub    $0xc,%esp
  801d86:	50                   	push   %eax
  801d87:	e8 16 f3 ff ff       	call   8010a2 <fd2num>
  801d8c:	89 c2                	mov    %eax,%edx
  801d8e:	83 c4 10             	add    $0x10,%esp
}
  801d91:	89 d0                	mov    %edx,%eax
  801d93:	c9                   	leave  
  801d94:	c3                   	ret    

00801d95 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d95:	55                   	push   %ebp
  801d96:	89 e5                	mov    %esp,%ebp
  801d98:	56                   	push   %esi
  801d99:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d9a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d9d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801da3:	e8 97 ed ff ff       	call   800b3f <sys_getenvid>
  801da8:	83 ec 0c             	sub    $0xc,%esp
  801dab:	ff 75 0c             	pushl  0xc(%ebp)
  801dae:	ff 75 08             	pushl  0x8(%ebp)
  801db1:	56                   	push   %esi
  801db2:	50                   	push   %eax
  801db3:	68 34 27 80 00       	push   $0x802734
  801db8:	e8 38 e4 ff ff       	call   8001f5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801dbd:	83 c4 18             	add    $0x18,%esp
  801dc0:	53                   	push   %ebx
  801dc1:	ff 75 10             	pushl  0x10(%ebp)
  801dc4:	e8 db e3 ff ff       	call   8001a4 <vcprintf>
	cprintf("\n");
  801dc9:	c7 04 24 85 22 80 00 	movl   $0x802285,(%esp)
  801dd0:	e8 20 e4 ff ff       	call   8001f5 <cprintf>
  801dd5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801dd8:	cc                   	int3   
  801dd9:	eb fd                	jmp    801dd8 <_panic+0x43>

00801ddb <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ddb:	55                   	push   %ebp
  801ddc:	89 e5                	mov    %esp,%ebp
  801dde:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801de1:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801de8:	75 2a                	jne    801e14 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801dea:	83 ec 04             	sub    $0x4,%esp
  801ded:	6a 07                	push   $0x7
  801def:	68 00 f0 bf ee       	push   $0xeebff000
  801df4:	6a 00                	push   $0x0
  801df6:	e8 82 ed ff ff       	call   800b7d <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801dfb:	83 c4 10             	add    $0x10,%esp
  801dfe:	85 c0                	test   %eax,%eax
  801e00:	79 12                	jns    801e14 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801e02:	50                   	push   %eax
  801e03:	68 58 27 80 00       	push   $0x802758
  801e08:	6a 23                	push   $0x23
  801e0a:	68 5c 27 80 00       	push   $0x80275c
  801e0f:	e8 81 ff ff ff       	call   801d95 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e14:	8b 45 08             	mov    0x8(%ebp),%eax
  801e17:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801e1c:	83 ec 08             	sub    $0x8,%esp
  801e1f:	68 46 1e 80 00       	push   $0x801e46
  801e24:	6a 00                	push   $0x0
  801e26:	e8 9d ee ff ff       	call   800cc8 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801e2b:	83 c4 10             	add    $0x10,%esp
  801e2e:	85 c0                	test   %eax,%eax
  801e30:	79 12                	jns    801e44 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801e32:	50                   	push   %eax
  801e33:	68 58 27 80 00       	push   $0x802758
  801e38:	6a 2c                	push   $0x2c
  801e3a:	68 5c 27 80 00       	push   $0x80275c
  801e3f:	e8 51 ff ff ff       	call   801d95 <_panic>
	}
}
  801e44:	c9                   	leave  
  801e45:	c3                   	ret    

00801e46 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e46:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e47:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e4c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e4e:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801e51:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801e55:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801e5a:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801e5e:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801e60:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801e63:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801e64:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801e67:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801e68:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e69:	c3                   	ret    

00801e6a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e6a:	55                   	push   %ebp
  801e6b:	89 e5                	mov    %esp,%ebp
  801e6d:	56                   	push   %esi
  801e6e:	53                   	push   %ebx
  801e6f:	8b 75 08             	mov    0x8(%ebp),%esi
  801e72:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e75:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e78:	85 c0                	test   %eax,%eax
  801e7a:	75 12                	jne    801e8e <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e7c:	83 ec 0c             	sub    $0xc,%esp
  801e7f:	68 00 00 c0 ee       	push   $0xeec00000
  801e84:	e8 a4 ee ff ff       	call   800d2d <sys_ipc_recv>
  801e89:	83 c4 10             	add    $0x10,%esp
  801e8c:	eb 0c                	jmp    801e9a <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e8e:	83 ec 0c             	sub    $0xc,%esp
  801e91:	50                   	push   %eax
  801e92:	e8 96 ee ff ff       	call   800d2d <sys_ipc_recv>
  801e97:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e9a:	85 f6                	test   %esi,%esi
  801e9c:	0f 95 c1             	setne  %cl
  801e9f:	85 db                	test   %ebx,%ebx
  801ea1:	0f 95 c2             	setne  %dl
  801ea4:	84 d1                	test   %dl,%cl
  801ea6:	74 09                	je     801eb1 <ipc_recv+0x47>
  801ea8:	89 c2                	mov    %eax,%edx
  801eaa:	c1 ea 1f             	shr    $0x1f,%edx
  801ead:	84 d2                	test   %dl,%dl
  801eaf:	75 2d                	jne    801ede <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801eb1:	85 f6                	test   %esi,%esi
  801eb3:	74 0d                	je     801ec2 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801eb5:	a1 04 40 80 00       	mov    0x804004,%eax
  801eba:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  801ec0:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801ec2:	85 db                	test   %ebx,%ebx
  801ec4:	74 0d                	je     801ed3 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801ec6:	a1 04 40 80 00       	mov    0x804004,%eax
  801ecb:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  801ed1:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ed3:	a1 04 40 80 00       	mov    0x804004,%eax
  801ed8:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  801ede:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ee1:	5b                   	pop    %ebx
  801ee2:	5e                   	pop    %esi
  801ee3:	5d                   	pop    %ebp
  801ee4:	c3                   	ret    

00801ee5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ee5:	55                   	push   %ebp
  801ee6:	89 e5                	mov    %esp,%ebp
  801ee8:	57                   	push   %edi
  801ee9:	56                   	push   %esi
  801eea:	53                   	push   %ebx
  801eeb:	83 ec 0c             	sub    $0xc,%esp
  801eee:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ef1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ef4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801ef7:	85 db                	test   %ebx,%ebx
  801ef9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801efe:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801f01:	ff 75 14             	pushl  0x14(%ebp)
  801f04:	53                   	push   %ebx
  801f05:	56                   	push   %esi
  801f06:	57                   	push   %edi
  801f07:	e8 fe ed ff ff       	call   800d0a <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801f0c:	89 c2                	mov    %eax,%edx
  801f0e:	c1 ea 1f             	shr    $0x1f,%edx
  801f11:	83 c4 10             	add    $0x10,%esp
  801f14:	84 d2                	test   %dl,%dl
  801f16:	74 17                	je     801f2f <ipc_send+0x4a>
  801f18:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f1b:	74 12                	je     801f2f <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801f1d:	50                   	push   %eax
  801f1e:	68 6a 27 80 00       	push   $0x80276a
  801f23:	6a 47                	push   $0x47
  801f25:	68 78 27 80 00       	push   $0x802778
  801f2a:	e8 66 fe ff ff       	call   801d95 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801f2f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f32:	75 07                	jne    801f3b <ipc_send+0x56>
			sys_yield();
  801f34:	e8 25 ec ff ff       	call   800b5e <sys_yield>
  801f39:	eb c6                	jmp    801f01 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801f3b:	85 c0                	test   %eax,%eax
  801f3d:	75 c2                	jne    801f01 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801f3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f42:	5b                   	pop    %ebx
  801f43:	5e                   	pop    %esi
  801f44:	5f                   	pop    %edi
  801f45:	5d                   	pop    %ebp
  801f46:	c3                   	ret    

00801f47 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f47:	55                   	push   %ebp
  801f48:	89 e5                	mov    %esp,%ebp
  801f4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f4d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f52:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  801f58:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f5e:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801f64:	39 ca                	cmp    %ecx,%edx
  801f66:	75 10                	jne    801f78 <ipc_find_env+0x31>
			return envs[i].env_id;
  801f68:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  801f6e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f73:	8b 40 7c             	mov    0x7c(%eax),%eax
  801f76:	eb 0f                	jmp    801f87 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f78:	83 c0 01             	add    $0x1,%eax
  801f7b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f80:	75 d0                	jne    801f52 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f82:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f87:	5d                   	pop    %ebp
  801f88:	c3                   	ret    

00801f89 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f89:	55                   	push   %ebp
  801f8a:	89 e5                	mov    %esp,%ebp
  801f8c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f8f:	89 d0                	mov    %edx,%eax
  801f91:	c1 e8 16             	shr    $0x16,%eax
  801f94:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f9b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa0:	f6 c1 01             	test   $0x1,%cl
  801fa3:	74 1d                	je     801fc2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fa5:	c1 ea 0c             	shr    $0xc,%edx
  801fa8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801faf:	f6 c2 01             	test   $0x1,%dl
  801fb2:	74 0e                	je     801fc2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fb4:	c1 ea 0c             	shr    $0xc,%edx
  801fb7:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fbe:	ef 
  801fbf:	0f b7 c0             	movzwl %ax,%eax
}
  801fc2:	5d                   	pop    %ebp
  801fc3:	c3                   	ret    
  801fc4:	66 90                	xchg   %ax,%ax
  801fc6:	66 90                	xchg   %ax,%ax
  801fc8:	66 90                	xchg   %ax,%ax
  801fca:	66 90                	xchg   %ax,%ax
  801fcc:	66 90                	xchg   %ax,%ax
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
