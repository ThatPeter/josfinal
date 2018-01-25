
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
  800047:	e8 aa 01 00 00       	call   8001f6 <cprintf>
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
	//sys_thread_free(sys_getenvid());
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
  80006d:	e8 84 01 00 00       	call   8001f6 <cprintf>


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
  80008c:	e8 cf 0f 00 00       	call   801060 <thread_create>
  800091:	89 c6                	mov    %eax,%esi
	envid_t id2 = thread_create(test);
  800093:	c7 04 24 59 00 80 00 	movl   $0x800059,(%esp)
  80009a:	e8 c1 0f 00 00       	call   801060 <thread_create>
  80009f:	89 c3                	mov    %eax,%ebx
	thread_create(func);
  8000a1:	c7 04 24 33 00 80 00 	movl   $0x800033,(%esp)
  8000a8:	e8 b3 0f 00 00       	call   801060 <thread_create>
	thread_create(test);
  8000ad:	c7 04 24 59 00 80 00 	movl   $0x800059,(%esp)
  8000b4:	e8 a7 0f 00 00       	call   801060 <thread_create>
	cprintf("\nTHREAD CREATE RETURNED: %d\n\n", id);
  8000b9:	83 c4 08             	add    $0x8,%esp
  8000bc:	56                   	push   %esi
  8000bd:	68 69 22 80 00       	push   $0x802269
  8000c2:	e8 2f 01 00 00       	call   8001f6 <cprintf>
	cprintf("\nTHREAD CREATE RETURNED: %d\n\n", id2);
  8000c7:	83 c4 08             	add    $0x8,%esp
  8000ca:	53                   	push   %ebx
  8000cb:	68 69 22 80 00       	push   $0x802269
  8000d0:	e8 21 01 00 00       	call   8001f6 <cprintf>
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
  8000ea:	e8 51 0a 00 00       	call   800b40 <sys_getenvid>
  8000ef:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f4:	89 c2                	mov    %eax,%edx
  8000f6:	c1 e2 07             	shl    $0x7,%edx
  8000f9:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800100:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800105:	85 db                	test   %ebx,%ebx
  800107:	7e 07                	jle    800110 <libmain+0x31>
		binaryname = argv[0];
  800109:	8b 06                	mov    (%esi),%eax
  80010b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800110:	83 ec 08             	sub    $0x8,%esp
  800113:	56                   	push   %esi
  800114:	53                   	push   %ebx
  800115:	e8 65 ff ff ff       	call   80007f <umain>

	// exit gracefully
	exit();
  80011a:	e8 2a 00 00 00       	call   800149 <exit>
}
  80011f:	83 c4 10             	add    $0x10,%esp
  800122:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800125:	5b                   	pop    %ebx
  800126:	5e                   	pop    %esi
  800127:	5d                   	pop    %ebp
  800128:	c3                   	ret    

00800129 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  80012f:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  800134:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800136:	e8 05 0a 00 00       	call   800b40 <sys_getenvid>
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	50                   	push   %eax
  80013f:	e8 4b 0c 00 00       	call   800d8f <sys_thread_free>
}
  800144:	83 c4 10             	add    $0x10,%esp
  800147:	c9                   	leave  
  800148:	c3                   	ret    

00800149 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014f:	e8 18 11 00 00       	call   80126c <close_all>
	sys_env_destroy(0);
  800154:	83 ec 0c             	sub    $0xc,%esp
  800157:	6a 00                	push   $0x0
  800159:	e8 a1 09 00 00       	call   800aff <sys_env_destroy>
}
  80015e:	83 c4 10             	add    $0x10,%esp
  800161:	c9                   	leave  
  800162:	c3                   	ret    

00800163 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	53                   	push   %ebx
  800167:	83 ec 04             	sub    $0x4,%esp
  80016a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016d:	8b 13                	mov    (%ebx),%edx
  80016f:	8d 42 01             	lea    0x1(%edx),%eax
  800172:	89 03                	mov    %eax,(%ebx)
  800174:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800177:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80017b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800180:	75 1a                	jne    80019c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800182:	83 ec 08             	sub    $0x8,%esp
  800185:	68 ff 00 00 00       	push   $0xff
  80018a:	8d 43 08             	lea    0x8(%ebx),%eax
  80018d:	50                   	push   %eax
  80018e:	e8 2f 09 00 00       	call   800ac2 <sys_cputs>
		b->idx = 0;
  800193:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800199:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80019c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a3:	c9                   	leave  
  8001a4:	c3                   	ret    

008001a5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a5:	55                   	push   %ebp
  8001a6:	89 e5                	mov    %esp,%ebp
  8001a8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ae:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b5:	00 00 00 
	b.cnt = 0;
  8001b8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001bf:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c2:	ff 75 0c             	pushl  0xc(%ebp)
  8001c5:	ff 75 08             	pushl  0x8(%ebp)
  8001c8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ce:	50                   	push   %eax
  8001cf:	68 63 01 80 00       	push   $0x800163
  8001d4:	e8 54 01 00 00       	call   80032d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d9:	83 c4 08             	add    $0x8,%esp
  8001dc:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e8:	50                   	push   %eax
  8001e9:	e8 d4 08 00 00       	call   800ac2 <sys_cputs>

	return b.cnt;
}
  8001ee:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f4:	c9                   	leave  
  8001f5:	c3                   	ret    

008001f6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001fc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ff:	50                   	push   %eax
  800200:	ff 75 08             	pushl  0x8(%ebp)
  800203:	e8 9d ff ff ff       	call   8001a5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800208:	c9                   	leave  
  800209:	c3                   	ret    

0080020a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020a:	55                   	push   %ebp
  80020b:	89 e5                	mov    %esp,%ebp
  80020d:	57                   	push   %edi
  80020e:	56                   	push   %esi
  80020f:	53                   	push   %ebx
  800210:	83 ec 1c             	sub    $0x1c,%esp
  800213:	89 c7                	mov    %eax,%edi
  800215:	89 d6                	mov    %edx,%esi
  800217:	8b 45 08             	mov    0x8(%ebp),%eax
  80021a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80021d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800220:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800223:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800226:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80022e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800231:	39 d3                	cmp    %edx,%ebx
  800233:	72 05                	jb     80023a <printnum+0x30>
  800235:	39 45 10             	cmp    %eax,0x10(%ebp)
  800238:	77 45                	ja     80027f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80023a:	83 ec 0c             	sub    $0xc,%esp
  80023d:	ff 75 18             	pushl  0x18(%ebp)
  800240:	8b 45 14             	mov    0x14(%ebp),%eax
  800243:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800246:	53                   	push   %ebx
  800247:	ff 75 10             	pushl  0x10(%ebp)
  80024a:	83 ec 08             	sub    $0x8,%esp
  80024d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800250:	ff 75 e0             	pushl  -0x20(%ebp)
  800253:	ff 75 dc             	pushl  -0x24(%ebp)
  800256:	ff 75 d8             	pushl  -0x28(%ebp)
  800259:	e8 62 1d 00 00       	call   801fc0 <__udivdi3>
  80025e:	83 c4 18             	add    $0x18,%esp
  800261:	52                   	push   %edx
  800262:	50                   	push   %eax
  800263:	89 f2                	mov    %esi,%edx
  800265:	89 f8                	mov    %edi,%eax
  800267:	e8 9e ff ff ff       	call   80020a <printnum>
  80026c:	83 c4 20             	add    $0x20,%esp
  80026f:	eb 18                	jmp    800289 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800271:	83 ec 08             	sub    $0x8,%esp
  800274:	56                   	push   %esi
  800275:	ff 75 18             	pushl  0x18(%ebp)
  800278:	ff d7                	call   *%edi
  80027a:	83 c4 10             	add    $0x10,%esp
  80027d:	eb 03                	jmp    800282 <printnum+0x78>
  80027f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800282:	83 eb 01             	sub    $0x1,%ebx
  800285:	85 db                	test   %ebx,%ebx
  800287:	7f e8                	jg     800271 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800289:	83 ec 08             	sub    $0x8,%esp
  80028c:	56                   	push   %esi
  80028d:	83 ec 04             	sub    $0x4,%esp
  800290:	ff 75 e4             	pushl  -0x1c(%ebp)
  800293:	ff 75 e0             	pushl  -0x20(%ebp)
  800296:	ff 75 dc             	pushl  -0x24(%ebp)
  800299:	ff 75 d8             	pushl  -0x28(%ebp)
  80029c:	e8 4f 1e 00 00       	call   8020f0 <__umoddi3>
  8002a1:	83 c4 14             	add    $0x14,%esp
  8002a4:	0f be 80 91 22 80 00 	movsbl 0x802291(%eax),%eax
  8002ab:	50                   	push   %eax
  8002ac:	ff d7                	call   *%edi
}
  8002ae:	83 c4 10             	add    $0x10,%esp
  8002b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b4:	5b                   	pop    %ebx
  8002b5:	5e                   	pop    %esi
  8002b6:	5f                   	pop    %edi
  8002b7:	5d                   	pop    %ebp
  8002b8:	c3                   	ret    

008002b9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b9:	55                   	push   %ebp
  8002ba:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002bc:	83 fa 01             	cmp    $0x1,%edx
  8002bf:	7e 0e                	jle    8002cf <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c1:	8b 10                	mov    (%eax),%edx
  8002c3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c6:	89 08                	mov    %ecx,(%eax)
  8002c8:	8b 02                	mov    (%edx),%eax
  8002ca:	8b 52 04             	mov    0x4(%edx),%edx
  8002cd:	eb 22                	jmp    8002f1 <getuint+0x38>
	else if (lflag)
  8002cf:	85 d2                	test   %edx,%edx
  8002d1:	74 10                	je     8002e3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d3:	8b 10                	mov    (%eax),%edx
  8002d5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d8:	89 08                	mov    %ecx,(%eax)
  8002da:	8b 02                	mov    (%edx),%eax
  8002dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e1:	eb 0e                	jmp    8002f1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e3:	8b 10                	mov    (%eax),%edx
  8002e5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e8:	89 08                	mov    %ecx,(%eax)
  8002ea:	8b 02                	mov    (%edx),%eax
  8002ec:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    

008002f3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002fd:	8b 10                	mov    (%eax),%edx
  8002ff:	3b 50 04             	cmp    0x4(%eax),%edx
  800302:	73 0a                	jae    80030e <sprintputch+0x1b>
		*b->buf++ = ch;
  800304:	8d 4a 01             	lea    0x1(%edx),%ecx
  800307:	89 08                	mov    %ecx,(%eax)
  800309:	8b 45 08             	mov    0x8(%ebp),%eax
  80030c:	88 02                	mov    %al,(%edx)
}
  80030e:	5d                   	pop    %ebp
  80030f:	c3                   	ret    

00800310 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800316:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800319:	50                   	push   %eax
  80031a:	ff 75 10             	pushl  0x10(%ebp)
  80031d:	ff 75 0c             	pushl  0xc(%ebp)
  800320:	ff 75 08             	pushl  0x8(%ebp)
  800323:	e8 05 00 00 00       	call   80032d <vprintfmt>
	va_end(ap);
}
  800328:	83 c4 10             	add    $0x10,%esp
  80032b:	c9                   	leave  
  80032c:	c3                   	ret    

0080032d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
  800330:	57                   	push   %edi
  800331:	56                   	push   %esi
  800332:	53                   	push   %ebx
  800333:	83 ec 2c             	sub    $0x2c,%esp
  800336:	8b 75 08             	mov    0x8(%ebp),%esi
  800339:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80033c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80033f:	eb 12                	jmp    800353 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800341:	85 c0                	test   %eax,%eax
  800343:	0f 84 89 03 00 00    	je     8006d2 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800349:	83 ec 08             	sub    $0x8,%esp
  80034c:	53                   	push   %ebx
  80034d:	50                   	push   %eax
  80034e:	ff d6                	call   *%esi
  800350:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800353:	83 c7 01             	add    $0x1,%edi
  800356:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80035a:	83 f8 25             	cmp    $0x25,%eax
  80035d:	75 e2                	jne    800341 <vprintfmt+0x14>
  80035f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800363:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80036a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800371:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800378:	ba 00 00 00 00       	mov    $0x0,%edx
  80037d:	eb 07                	jmp    800386 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800382:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800386:	8d 47 01             	lea    0x1(%edi),%eax
  800389:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80038c:	0f b6 07             	movzbl (%edi),%eax
  80038f:	0f b6 c8             	movzbl %al,%ecx
  800392:	83 e8 23             	sub    $0x23,%eax
  800395:	3c 55                	cmp    $0x55,%al
  800397:	0f 87 1a 03 00 00    	ja     8006b7 <vprintfmt+0x38a>
  80039d:	0f b6 c0             	movzbl %al,%eax
  8003a0:	ff 24 85 e0 23 80 00 	jmp    *0x8023e0(,%eax,4)
  8003a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003aa:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003ae:	eb d6                	jmp    800386 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003bb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003be:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003c2:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003c5:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003c8:	83 fa 09             	cmp    $0x9,%edx
  8003cb:	77 39                	ja     800406 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003cd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d0:	eb e9                	jmp    8003bb <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d5:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003db:	8b 00                	mov    (%eax),%eax
  8003dd:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e3:	eb 27                	jmp    80040c <vprintfmt+0xdf>
  8003e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e8:	85 c0                	test   %eax,%eax
  8003ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ef:	0f 49 c8             	cmovns %eax,%ecx
  8003f2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f8:	eb 8c                	jmp    800386 <vprintfmt+0x59>
  8003fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003fd:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800404:	eb 80                	jmp    800386 <vprintfmt+0x59>
  800406:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800409:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80040c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800410:	0f 89 70 ff ff ff    	jns    800386 <vprintfmt+0x59>
				width = precision, precision = -1;
  800416:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800419:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80041c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800423:	e9 5e ff ff ff       	jmp    800386 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800428:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80042e:	e9 53 ff ff ff       	jmp    800386 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800433:	8b 45 14             	mov    0x14(%ebp),%eax
  800436:	8d 50 04             	lea    0x4(%eax),%edx
  800439:	89 55 14             	mov    %edx,0x14(%ebp)
  80043c:	83 ec 08             	sub    $0x8,%esp
  80043f:	53                   	push   %ebx
  800440:	ff 30                	pushl  (%eax)
  800442:	ff d6                	call   *%esi
			break;
  800444:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800447:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80044a:	e9 04 ff ff ff       	jmp    800353 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80044f:	8b 45 14             	mov    0x14(%ebp),%eax
  800452:	8d 50 04             	lea    0x4(%eax),%edx
  800455:	89 55 14             	mov    %edx,0x14(%ebp)
  800458:	8b 00                	mov    (%eax),%eax
  80045a:	99                   	cltd   
  80045b:	31 d0                	xor    %edx,%eax
  80045d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045f:	83 f8 0f             	cmp    $0xf,%eax
  800462:	7f 0b                	jg     80046f <vprintfmt+0x142>
  800464:	8b 14 85 40 25 80 00 	mov    0x802540(,%eax,4),%edx
  80046b:	85 d2                	test   %edx,%edx
  80046d:	75 18                	jne    800487 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80046f:	50                   	push   %eax
  800470:	68 a9 22 80 00       	push   $0x8022a9
  800475:	53                   	push   %ebx
  800476:	56                   	push   %esi
  800477:	e8 94 fe ff ff       	call   800310 <printfmt>
  80047c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800482:	e9 cc fe ff ff       	jmp    800353 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800487:	52                   	push   %edx
  800488:	68 ed 26 80 00       	push   $0x8026ed
  80048d:	53                   	push   %ebx
  80048e:	56                   	push   %esi
  80048f:	e8 7c fe ff ff       	call   800310 <printfmt>
  800494:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800497:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80049a:	e9 b4 fe ff ff       	jmp    800353 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80049f:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a2:	8d 50 04             	lea    0x4(%eax),%edx
  8004a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004aa:	85 ff                	test   %edi,%edi
  8004ac:	b8 a2 22 80 00       	mov    $0x8022a2,%eax
  8004b1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004b4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b8:	0f 8e 94 00 00 00    	jle    800552 <vprintfmt+0x225>
  8004be:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004c2:	0f 84 98 00 00 00    	je     800560 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c8:	83 ec 08             	sub    $0x8,%esp
  8004cb:	ff 75 d0             	pushl  -0x30(%ebp)
  8004ce:	57                   	push   %edi
  8004cf:	e8 86 02 00 00       	call   80075a <strnlen>
  8004d4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d7:	29 c1                	sub    %eax,%ecx
  8004d9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004dc:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004df:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e9:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004eb:	eb 0f                	jmp    8004fc <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004ed:	83 ec 08             	sub    $0x8,%esp
  8004f0:	53                   	push   %ebx
  8004f1:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f4:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f6:	83 ef 01             	sub    $0x1,%edi
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	85 ff                	test   %edi,%edi
  8004fe:	7f ed                	jg     8004ed <vprintfmt+0x1c0>
  800500:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800503:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800506:	85 c9                	test   %ecx,%ecx
  800508:	b8 00 00 00 00       	mov    $0x0,%eax
  80050d:	0f 49 c1             	cmovns %ecx,%eax
  800510:	29 c1                	sub    %eax,%ecx
  800512:	89 75 08             	mov    %esi,0x8(%ebp)
  800515:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800518:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051b:	89 cb                	mov    %ecx,%ebx
  80051d:	eb 4d                	jmp    80056c <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80051f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800523:	74 1b                	je     800540 <vprintfmt+0x213>
  800525:	0f be c0             	movsbl %al,%eax
  800528:	83 e8 20             	sub    $0x20,%eax
  80052b:	83 f8 5e             	cmp    $0x5e,%eax
  80052e:	76 10                	jbe    800540 <vprintfmt+0x213>
					putch('?', putdat);
  800530:	83 ec 08             	sub    $0x8,%esp
  800533:	ff 75 0c             	pushl  0xc(%ebp)
  800536:	6a 3f                	push   $0x3f
  800538:	ff 55 08             	call   *0x8(%ebp)
  80053b:	83 c4 10             	add    $0x10,%esp
  80053e:	eb 0d                	jmp    80054d <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800540:	83 ec 08             	sub    $0x8,%esp
  800543:	ff 75 0c             	pushl  0xc(%ebp)
  800546:	52                   	push   %edx
  800547:	ff 55 08             	call   *0x8(%ebp)
  80054a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054d:	83 eb 01             	sub    $0x1,%ebx
  800550:	eb 1a                	jmp    80056c <vprintfmt+0x23f>
  800552:	89 75 08             	mov    %esi,0x8(%ebp)
  800555:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800558:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80055e:	eb 0c                	jmp    80056c <vprintfmt+0x23f>
  800560:	89 75 08             	mov    %esi,0x8(%ebp)
  800563:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800566:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800569:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056c:	83 c7 01             	add    $0x1,%edi
  80056f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800573:	0f be d0             	movsbl %al,%edx
  800576:	85 d2                	test   %edx,%edx
  800578:	74 23                	je     80059d <vprintfmt+0x270>
  80057a:	85 f6                	test   %esi,%esi
  80057c:	78 a1                	js     80051f <vprintfmt+0x1f2>
  80057e:	83 ee 01             	sub    $0x1,%esi
  800581:	79 9c                	jns    80051f <vprintfmt+0x1f2>
  800583:	89 df                	mov    %ebx,%edi
  800585:	8b 75 08             	mov    0x8(%ebp),%esi
  800588:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80058b:	eb 18                	jmp    8005a5 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058d:	83 ec 08             	sub    $0x8,%esp
  800590:	53                   	push   %ebx
  800591:	6a 20                	push   $0x20
  800593:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800595:	83 ef 01             	sub    $0x1,%edi
  800598:	83 c4 10             	add    $0x10,%esp
  80059b:	eb 08                	jmp    8005a5 <vprintfmt+0x278>
  80059d:	89 df                	mov    %ebx,%edi
  80059f:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a5:	85 ff                	test   %edi,%edi
  8005a7:	7f e4                	jg     80058d <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ac:	e9 a2 fd ff ff       	jmp    800353 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b1:	83 fa 01             	cmp    $0x1,%edx
  8005b4:	7e 16                	jle    8005cc <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8d 50 08             	lea    0x8(%eax),%edx
  8005bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bf:	8b 50 04             	mov    0x4(%eax),%edx
  8005c2:	8b 00                	mov    (%eax),%eax
  8005c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ca:	eb 32                	jmp    8005fe <vprintfmt+0x2d1>
	else if (lflag)
  8005cc:	85 d2                	test   %edx,%edx
  8005ce:	74 18                	je     8005e8 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8d 50 04             	lea    0x4(%eax),%edx
  8005d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d9:	8b 00                	mov    (%eax),%eax
  8005db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005de:	89 c1                	mov    %eax,%ecx
  8005e0:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e6:	eb 16                	jmp    8005fe <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8d 50 04             	lea    0x4(%eax),%edx
  8005ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f1:	8b 00                	mov    (%eax),%eax
  8005f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f6:	89 c1                	mov    %eax,%ecx
  8005f8:	c1 f9 1f             	sar    $0x1f,%ecx
  8005fb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005fe:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800601:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800604:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800609:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80060d:	79 74                	jns    800683 <vprintfmt+0x356>
				putch('-', putdat);
  80060f:	83 ec 08             	sub    $0x8,%esp
  800612:	53                   	push   %ebx
  800613:	6a 2d                	push   $0x2d
  800615:	ff d6                	call   *%esi
				num = -(long long) num;
  800617:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80061a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80061d:	f7 d8                	neg    %eax
  80061f:	83 d2 00             	adc    $0x0,%edx
  800622:	f7 da                	neg    %edx
  800624:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800627:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80062c:	eb 55                	jmp    800683 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80062e:	8d 45 14             	lea    0x14(%ebp),%eax
  800631:	e8 83 fc ff ff       	call   8002b9 <getuint>
			base = 10;
  800636:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80063b:	eb 46                	jmp    800683 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80063d:	8d 45 14             	lea    0x14(%ebp),%eax
  800640:	e8 74 fc ff ff       	call   8002b9 <getuint>
			base = 8;
  800645:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80064a:	eb 37                	jmp    800683 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80064c:	83 ec 08             	sub    $0x8,%esp
  80064f:	53                   	push   %ebx
  800650:	6a 30                	push   $0x30
  800652:	ff d6                	call   *%esi
			putch('x', putdat);
  800654:	83 c4 08             	add    $0x8,%esp
  800657:	53                   	push   %ebx
  800658:	6a 78                	push   $0x78
  80065a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8d 50 04             	lea    0x4(%eax),%edx
  800662:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800665:	8b 00                	mov    (%eax),%eax
  800667:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80066c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80066f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800674:	eb 0d                	jmp    800683 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800676:	8d 45 14             	lea    0x14(%ebp),%eax
  800679:	e8 3b fc ff ff       	call   8002b9 <getuint>
			base = 16;
  80067e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800683:	83 ec 0c             	sub    $0xc,%esp
  800686:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80068a:	57                   	push   %edi
  80068b:	ff 75 e0             	pushl  -0x20(%ebp)
  80068e:	51                   	push   %ecx
  80068f:	52                   	push   %edx
  800690:	50                   	push   %eax
  800691:	89 da                	mov    %ebx,%edx
  800693:	89 f0                	mov    %esi,%eax
  800695:	e8 70 fb ff ff       	call   80020a <printnum>
			break;
  80069a:	83 c4 20             	add    $0x20,%esp
  80069d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a0:	e9 ae fc ff ff       	jmp    800353 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a5:	83 ec 08             	sub    $0x8,%esp
  8006a8:	53                   	push   %ebx
  8006a9:	51                   	push   %ecx
  8006aa:	ff d6                	call   *%esi
			break;
  8006ac:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006b2:	e9 9c fc ff ff       	jmp    800353 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b7:	83 ec 08             	sub    $0x8,%esp
  8006ba:	53                   	push   %ebx
  8006bb:	6a 25                	push   $0x25
  8006bd:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006bf:	83 c4 10             	add    $0x10,%esp
  8006c2:	eb 03                	jmp    8006c7 <vprintfmt+0x39a>
  8006c4:	83 ef 01             	sub    $0x1,%edi
  8006c7:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006cb:	75 f7                	jne    8006c4 <vprintfmt+0x397>
  8006cd:	e9 81 fc ff ff       	jmp    800353 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d5:	5b                   	pop    %ebx
  8006d6:	5e                   	pop    %esi
  8006d7:	5f                   	pop    %edi
  8006d8:	5d                   	pop    %ebp
  8006d9:	c3                   	ret    

008006da <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006da:	55                   	push   %ebp
  8006db:	89 e5                	mov    %esp,%ebp
  8006dd:	83 ec 18             	sub    $0x18,%esp
  8006e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ed:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f7:	85 c0                	test   %eax,%eax
  8006f9:	74 26                	je     800721 <vsnprintf+0x47>
  8006fb:	85 d2                	test   %edx,%edx
  8006fd:	7e 22                	jle    800721 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ff:	ff 75 14             	pushl  0x14(%ebp)
  800702:	ff 75 10             	pushl  0x10(%ebp)
  800705:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800708:	50                   	push   %eax
  800709:	68 f3 02 80 00       	push   $0x8002f3
  80070e:	e8 1a fc ff ff       	call   80032d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800713:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800716:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800719:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80071c:	83 c4 10             	add    $0x10,%esp
  80071f:	eb 05                	jmp    800726 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800721:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800726:	c9                   	leave  
  800727:	c3                   	ret    

00800728 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80072e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800731:	50                   	push   %eax
  800732:	ff 75 10             	pushl  0x10(%ebp)
  800735:	ff 75 0c             	pushl  0xc(%ebp)
  800738:	ff 75 08             	pushl  0x8(%ebp)
  80073b:	e8 9a ff ff ff       	call   8006da <vsnprintf>
	va_end(ap);

	return rc;
}
  800740:	c9                   	leave  
  800741:	c3                   	ret    

00800742 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800742:	55                   	push   %ebp
  800743:	89 e5                	mov    %esp,%ebp
  800745:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800748:	b8 00 00 00 00       	mov    $0x0,%eax
  80074d:	eb 03                	jmp    800752 <strlen+0x10>
		n++;
  80074f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800752:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800756:	75 f7                	jne    80074f <strlen+0xd>
		n++;
	return n;
}
  800758:	5d                   	pop    %ebp
  800759:	c3                   	ret    

0080075a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800760:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800763:	ba 00 00 00 00       	mov    $0x0,%edx
  800768:	eb 03                	jmp    80076d <strnlen+0x13>
		n++;
  80076a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076d:	39 c2                	cmp    %eax,%edx
  80076f:	74 08                	je     800779 <strnlen+0x1f>
  800771:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800775:	75 f3                	jne    80076a <strnlen+0x10>
  800777:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800779:	5d                   	pop    %ebp
  80077a:	c3                   	ret    

0080077b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
  80077e:	53                   	push   %ebx
  80077f:	8b 45 08             	mov    0x8(%ebp),%eax
  800782:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800785:	89 c2                	mov    %eax,%edx
  800787:	83 c2 01             	add    $0x1,%edx
  80078a:	83 c1 01             	add    $0x1,%ecx
  80078d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800791:	88 5a ff             	mov    %bl,-0x1(%edx)
  800794:	84 db                	test   %bl,%bl
  800796:	75 ef                	jne    800787 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800798:	5b                   	pop    %ebx
  800799:	5d                   	pop    %ebp
  80079a:	c3                   	ret    

0080079b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	53                   	push   %ebx
  80079f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a2:	53                   	push   %ebx
  8007a3:	e8 9a ff ff ff       	call   800742 <strlen>
  8007a8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ab:	ff 75 0c             	pushl  0xc(%ebp)
  8007ae:	01 d8                	add    %ebx,%eax
  8007b0:	50                   	push   %eax
  8007b1:	e8 c5 ff ff ff       	call   80077b <strcpy>
	return dst;
}
  8007b6:	89 d8                	mov    %ebx,%eax
  8007b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007bb:	c9                   	leave  
  8007bc:	c3                   	ret    

008007bd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	56                   	push   %esi
  8007c1:	53                   	push   %ebx
  8007c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c8:	89 f3                	mov    %esi,%ebx
  8007ca:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007cd:	89 f2                	mov    %esi,%edx
  8007cf:	eb 0f                	jmp    8007e0 <strncpy+0x23>
		*dst++ = *src;
  8007d1:	83 c2 01             	add    $0x1,%edx
  8007d4:	0f b6 01             	movzbl (%ecx),%eax
  8007d7:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007da:	80 39 01             	cmpb   $0x1,(%ecx)
  8007dd:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e0:	39 da                	cmp    %ebx,%edx
  8007e2:	75 ed                	jne    8007d1 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e4:	89 f0                	mov    %esi,%eax
  8007e6:	5b                   	pop    %ebx
  8007e7:	5e                   	pop    %esi
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	56                   	push   %esi
  8007ee:	53                   	push   %ebx
  8007ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f5:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007fa:	85 d2                	test   %edx,%edx
  8007fc:	74 21                	je     80081f <strlcpy+0x35>
  8007fe:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800802:	89 f2                	mov    %esi,%edx
  800804:	eb 09                	jmp    80080f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800806:	83 c2 01             	add    $0x1,%edx
  800809:	83 c1 01             	add    $0x1,%ecx
  80080c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80080f:	39 c2                	cmp    %eax,%edx
  800811:	74 09                	je     80081c <strlcpy+0x32>
  800813:	0f b6 19             	movzbl (%ecx),%ebx
  800816:	84 db                	test   %bl,%bl
  800818:	75 ec                	jne    800806 <strlcpy+0x1c>
  80081a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80081c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80081f:	29 f0                	sub    %esi,%eax
}
  800821:	5b                   	pop    %ebx
  800822:	5e                   	pop    %esi
  800823:	5d                   	pop    %ebp
  800824:	c3                   	ret    

00800825 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80082e:	eb 06                	jmp    800836 <strcmp+0x11>
		p++, q++;
  800830:	83 c1 01             	add    $0x1,%ecx
  800833:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800836:	0f b6 01             	movzbl (%ecx),%eax
  800839:	84 c0                	test   %al,%al
  80083b:	74 04                	je     800841 <strcmp+0x1c>
  80083d:	3a 02                	cmp    (%edx),%al
  80083f:	74 ef                	je     800830 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800841:	0f b6 c0             	movzbl %al,%eax
  800844:	0f b6 12             	movzbl (%edx),%edx
  800847:	29 d0                	sub    %edx,%eax
}
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	53                   	push   %ebx
  80084f:	8b 45 08             	mov    0x8(%ebp),%eax
  800852:	8b 55 0c             	mov    0xc(%ebp),%edx
  800855:	89 c3                	mov    %eax,%ebx
  800857:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80085a:	eb 06                	jmp    800862 <strncmp+0x17>
		n--, p++, q++;
  80085c:	83 c0 01             	add    $0x1,%eax
  80085f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800862:	39 d8                	cmp    %ebx,%eax
  800864:	74 15                	je     80087b <strncmp+0x30>
  800866:	0f b6 08             	movzbl (%eax),%ecx
  800869:	84 c9                	test   %cl,%cl
  80086b:	74 04                	je     800871 <strncmp+0x26>
  80086d:	3a 0a                	cmp    (%edx),%cl
  80086f:	74 eb                	je     80085c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800871:	0f b6 00             	movzbl (%eax),%eax
  800874:	0f b6 12             	movzbl (%edx),%edx
  800877:	29 d0                	sub    %edx,%eax
  800879:	eb 05                	jmp    800880 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80087b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800880:	5b                   	pop    %ebx
  800881:	5d                   	pop    %ebp
  800882:	c3                   	ret    

00800883 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088d:	eb 07                	jmp    800896 <strchr+0x13>
		if (*s == c)
  80088f:	38 ca                	cmp    %cl,%dl
  800891:	74 0f                	je     8008a2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800893:	83 c0 01             	add    $0x1,%eax
  800896:	0f b6 10             	movzbl (%eax),%edx
  800899:	84 d2                	test   %dl,%dl
  80089b:	75 f2                	jne    80088f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80089d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008aa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ae:	eb 03                	jmp    8008b3 <strfind+0xf>
  8008b0:	83 c0 01             	add    $0x1,%eax
  8008b3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008b6:	38 ca                	cmp    %cl,%dl
  8008b8:	74 04                	je     8008be <strfind+0x1a>
  8008ba:	84 d2                	test   %dl,%dl
  8008bc:	75 f2                	jne    8008b0 <strfind+0xc>
			break;
	return (char *) s;
}
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	57                   	push   %edi
  8008c4:	56                   	push   %esi
  8008c5:	53                   	push   %ebx
  8008c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008cc:	85 c9                	test   %ecx,%ecx
  8008ce:	74 36                	je     800906 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d6:	75 28                	jne    800900 <memset+0x40>
  8008d8:	f6 c1 03             	test   $0x3,%cl
  8008db:	75 23                	jne    800900 <memset+0x40>
		c &= 0xFF;
  8008dd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e1:	89 d3                	mov    %edx,%ebx
  8008e3:	c1 e3 08             	shl    $0x8,%ebx
  8008e6:	89 d6                	mov    %edx,%esi
  8008e8:	c1 e6 18             	shl    $0x18,%esi
  8008eb:	89 d0                	mov    %edx,%eax
  8008ed:	c1 e0 10             	shl    $0x10,%eax
  8008f0:	09 f0                	or     %esi,%eax
  8008f2:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008f4:	89 d8                	mov    %ebx,%eax
  8008f6:	09 d0                	or     %edx,%eax
  8008f8:	c1 e9 02             	shr    $0x2,%ecx
  8008fb:	fc                   	cld    
  8008fc:	f3 ab                	rep stos %eax,%es:(%edi)
  8008fe:	eb 06                	jmp    800906 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800900:	8b 45 0c             	mov    0xc(%ebp),%eax
  800903:	fc                   	cld    
  800904:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800906:	89 f8                	mov    %edi,%eax
  800908:	5b                   	pop    %ebx
  800909:	5e                   	pop    %esi
  80090a:	5f                   	pop    %edi
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    

0080090d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	57                   	push   %edi
  800911:	56                   	push   %esi
  800912:	8b 45 08             	mov    0x8(%ebp),%eax
  800915:	8b 75 0c             	mov    0xc(%ebp),%esi
  800918:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80091b:	39 c6                	cmp    %eax,%esi
  80091d:	73 35                	jae    800954 <memmove+0x47>
  80091f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800922:	39 d0                	cmp    %edx,%eax
  800924:	73 2e                	jae    800954 <memmove+0x47>
		s += n;
		d += n;
  800926:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800929:	89 d6                	mov    %edx,%esi
  80092b:	09 fe                	or     %edi,%esi
  80092d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800933:	75 13                	jne    800948 <memmove+0x3b>
  800935:	f6 c1 03             	test   $0x3,%cl
  800938:	75 0e                	jne    800948 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80093a:	83 ef 04             	sub    $0x4,%edi
  80093d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800940:	c1 e9 02             	shr    $0x2,%ecx
  800943:	fd                   	std    
  800944:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800946:	eb 09                	jmp    800951 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800948:	83 ef 01             	sub    $0x1,%edi
  80094b:	8d 72 ff             	lea    -0x1(%edx),%esi
  80094e:	fd                   	std    
  80094f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800951:	fc                   	cld    
  800952:	eb 1d                	jmp    800971 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800954:	89 f2                	mov    %esi,%edx
  800956:	09 c2                	or     %eax,%edx
  800958:	f6 c2 03             	test   $0x3,%dl
  80095b:	75 0f                	jne    80096c <memmove+0x5f>
  80095d:	f6 c1 03             	test   $0x3,%cl
  800960:	75 0a                	jne    80096c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800962:	c1 e9 02             	shr    $0x2,%ecx
  800965:	89 c7                	mov    %eax,%edi
  800967:	fc                   	cld    
  800968:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096a:	eb 05                	jmp    800971 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80096c:	89 c7                	mov    %eax,%edi
  80096e:	fc                   	cld    
  80096f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800971:	5e                   	pop    %esi
  800972:	5f                   	pop    %edi
  800973:	5d                   	pop    %ebp
  800974:	c3                   	ret    

00800975 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800978:	ff 75 10             	pushl  0x10(%ebp)
  80097b:	ff 75 0c             	pushl  0xc(%ebp)
  80097e:	ff 75 08             	pushl  0x8(%ebp)
  800981:	e8 87 ff ff ff       	call   80090d <memmove>
}
  800986:	c9                   	leave  
  800987:	c3                   	ret    

00800988 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	56                   	push   %esi
  80098c:	53                   	push   %ebx
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	8b 55 0c             	mov    0xc(%ebp),%edx
  800993:	89 c6                	mov    %eax,%esi
  800995:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800998:	eb 1a                	jmp    8009b4 <memcmp+0x2c>
		if (*s1 != *s2)
  80099a:	0f b6 08             	movzbl (%eax),%ecx
  80099d:	0f b6 1a             	movzbl (%edx),%ebx
  8009a0:	38 d9                	cmp    %bl,%cl
  8009a2:	74 0a                	je     8009ae <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009a4:	0f b6 c1             	movzbl %cl,%eax
  8009a7:	0f b6 db             	movzbl %bl,%ebx
  8009aa:	29 d8                	sub    %ebx,%eax
  8009ac:	eb 0f                	jmp    8009bd <memcmp+0x35>
		s1++, s2++;
  8009ae:	83 c0 01             	add    $0x1,%eax
  8009b1:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b4:	39 f0                	cmp    %esi,%eax
  8009b6:	75 e2                	jne    80099a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bd:	5b                   	pop    %ebx
  8009be:	5e                   	pop    %esi
  8009bf:	5d                   	pop    %ebp
  8009c0:	c3                   	ret    

008009c1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	53                   	push   %ebx
  8009c5:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009c8:	89 c1                	mov    %eax,%ecx
  8009ca:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009cd:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d1:	eb 0a                	jmp    8009dd <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d3:	0f b6 10             	movzbl (%eax),%edx
  8009d6:	39 da                	cmp    %ebx,%edx
  8009d8:	74 07                	je     8009e1 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009da:	83 c0 01             	add    $0x1,%eax
  8009dd:	39 c8                	cmp    %ecx,%eax
  8009df:	72 f2                	jb     8009d3 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009e1:	5b                   	pop    %ebx
  8009e2:	5d                   	pop    %ebp
  8009e3:	c3                   	ret    

008009e4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	57                   	push   %edi
  8009e8:	56                   	push   %esi
  8009e9:	53                   	push   %ebx
  8009ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f0:	eb 03                	jmp    8009f5 <strtol+0x11>
		s++;
  8009f2:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f5:	0f b6 01             	movzbl (%ecx),%eax
  8009f8:	3c 20                	cmp    $0x20,%al
  8009fa:	74 f6                	je     8009f2 <strtol+0xe>
  8009fc:	3c 09                	cmp    $0x9,%al
  8009fe:	74 f2                	je     8009f2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a00:	3c 2b                	cmp    $0x2b,%al
  800a02:	75 0a                	jne    800a0e <strtol+0x2a>
		s++;
  800a04:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a07:	bf 00 00 00 00       	mov    $0x0,%edi
  800a0c:	eb 11                	jmp    800a1f <strtol+0x3b>
  800a0e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a13:	3c 2d                	cmp    $0x2d,%al
  800a15:	75 08                	jne    800a1f <strtol+0x3b>
		s++, neg = 1;
  800a17:	83 c1 01             	add    $0x1,%ecx
  800a1a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a25:	75 15                	jne    800a3c <strtol+0x58>
  800a27:	80 39 30             	cmpb   $0x30,(%ecx)
  800a2a:	75 10                	jne    800a3c <strtol+0x58>
  800a2c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a30:	75 7c                	jne    800aae <strtol+0xca>
		s += 2, base = 16;
  800a32:	83 c1 02             	add    $0x2,%ecx
  800a35:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a3a:	eb 16                	jmp    800a52 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a3c:	85 db                	test   %ebx,%ebx
  800a3e:	75 12                	jne    800a52 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a40:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a45:	80 39 30             	cmpb   $0x30,(%ecx)
  800a48:	75 08                	jne    800a52 <strtol+0x6e>
		s++, base = 8;
  800a4a:	83 c1 01             	add    $0x1,%ecx
  800a4d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a52:	b8 00 00 00 00       	mov    $0x0,%eax
  800a57:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a5a:	0f b6 11             	movzbl (%ecx),%edx
  800a5d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a60:	89 f3                	mov    %esi,%ebx
  800a62:	80 fb 09             	cmp    $0x9,%bl
  800a65:	77 08                	ja     800a6f <strtol+0x8b>
			dig = *s - '0';
  800a67:	0f be d2             	movsbl %dl,%edx
  800a6a:	83 ea 30             	sub    $0x30,%edx
  800a6d:	eb 22                	jmp    800a91 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a6f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a72:	89 f3                	mov    %esi,%ebx
  800a74:	80 fb 19             	cmp    $0x19,%bl
  800a77:	77 08                	ja     800a81 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a79:	0f be d2             	movsbl %dl,%edx
  800a7c:	83 ea 57             	sub    $0x57,%edx
  800a7f:	eb 10                	jmp    800a91 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a81:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a84:	89 f3                	mov    %esi,%ebx
  800a86:	80 fb 19             	cmp    $0x19,%bl
  800a89:	77 16                	ja     800aa1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a8b:	0f be d2             	movsbl %dl,%edx
  800a8e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a91:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a94:	7d 0b                	jge    800aa1 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a96:	83 c1 01             	add    $0x1,%ecx
  800a99:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a9d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a9f:	eb b9                	jmp    800a5a <strtol+0x76>

	if (endptr)
  800aa1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa5:	74 0d                	je     800ab4 <strtol+0xd0>
		*endptr = (char *) s;
  800aa7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aaa:	89 0e                	mov    %ecx,(%esi)
  800aac:	eb 06                	jmp    800ab4 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aae:	85 db                	test   %ebx,%ebx
  800ab0:	74 98                	je     800a4a <strtol+0x66>
  800ab2:	eb 9e                	jmp    800a52 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ab4:	89 c2                	mov    %eax,%edx
  800ab6:	f7 da                	neg    %edx
  800ab8:	85 ff                	test   %edi,%edi
  800aba:	0f 45 c2             	cmovne %edx,%eax
}
  800abd:	5b                   	pop    %ebx
  800abe:	5e                   	pop    %esi
  800abf:	5f                   	pop    %edi
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    

00800ac2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	57                   	push   %edi
  800ac6:	56                   	push   %esi
  800ac7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac8:	b8 00 00 00 00       	mov    $0x0,%eax
  800acd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad3:	89 c3                	mov    %eax,%ebx
  800ad5:	89 c7                	mov    %eax,%edi
  800ad7:	89 c6                	mov    %eax,%esi
  800ad9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800adb:	5b                   	pop    %ebx
  800adc:	5e                   	pop    %esi
  800add:	5f                   	pop    %edi
  800ade:	5d                   	pop    %ebp
  800adf:	c3                   	ret    

00800ae0 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	57                   	push   %edi
  800ae4:	56                   	push   %esi
  800ae5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae6:	ba 00 00 00 00       	mov    $0x0,%edx
  800aeb:	b8 01 00 00 00       	mov    $0x1,%eax
  800af0:	89 d1                	mov    %edx,%ecx
  800af2:	89 d3                	mov    %edx,%ebx
  800af4:	89 d7                	mov    %edx,%edi
  800af6:	89 d6                	mov    %edx,%esi
  800af8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800afa:	5b                   	pop    %ebx
  800afb:	5e                   	pop    %esi
  800afc:	5f                   	pop    %edi
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	57                   	push   %edi
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
  800b05:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b08:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b0d:	b8 03 00 00 00       	mov    $0x3,%eax
  800b12:	8b 55 08             	mov    0x8(%ebp),%edx
  800b15:	89 cb                	mov    %ecx,%ebx
  800b17:	89 cf                	mov    %ecx,%edi
  800b19:	89 ce                	mov    %ecx,%esi
  800b1b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b1d:	85 c0                	test   %eax,%eax
  800b1f:	7e 17                	jle    800b38 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b21:	83 ec 0c             	sub    $0xc,%esp
  800b24:	50                   	push   %eax
  800b25:	6a 03                	push   $0x3
  800b27:	68 9f 25 80 00       	push   $0x80259f
  800b2c:	6a 23                	push   $0x23
  800b2e:	68 bc 25 80 00       	push   $0x8025bc
  800b33:	e8 53 12 00 00       	call   801d8b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b3b:	5b                   	pop    %ebx
  800b3c:	5e                   	pop    %esi
  800b3d:	5f                   	pop    %edi
  800b3e:	5d                   	pop    %ebp
  800b3f:	c3                   	ret    

00800b40 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b46:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b50:	89 d1                	mov    %edx,%ecx
  800b52:	89 d3                	mov    %edx,%ebx
  800b54:	89 d7                	mov    %edx,%edi
  800b56:	89 d6                	mov    %edx,%esi
  800b58:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5f                   	pop    %edi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <sys_yield>:

void
sys_yield(void)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b65:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b6f:	89 d1                	mov    %edx,%ecx
  800b71:	89 d3                	mov    %edx,%ebx
  800b73:	89 d7                	mov    %edx,%edi
  800b75:	89 d6                	mov    %edx,%esi
  800b77:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	57                   	push   %edi
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
  800b84:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b87:	be 00 00 00 00       	mov    $0x0,%esi
  800b8c:	b8 04 00 00 00       	mov    $0x4,%eax
  800b91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b94:	8b 55 08             	mov    0x8(%ebp),%edx
  800b97:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9a:	89 f7                	mov    %esi,%edi
  800b9c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9e:	85 c0                	test   %eax,%eax
  800ba0:	7e 17                	jle    800bb9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba2:	83 ec 0c             	sub    $0xc,%esp
  800ba5:	50                   	push   %eax
  800ba6:	6a 04                	push   $0x4
  800ba8:	68 9f 25 80 00       	push   $0x80259f
  800bad:	6a 23                	push   $0x23
  800baf:	68 bc 25 80 00       	push   $0x8025bc
  800bb4:	e8 d2 11 00 00       	call   801d8b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5f                   	pop    %edi
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	57                   	push   %edi
  800bc5:	56                   	push   %esi
  800bc6:	53                   	push   %ebx
  800bc7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bca:	b8 05 00 00 00       	mov    $0x5,%eax
  800bcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bdb:	8b 75 18             	mov    0x18(%ebp),%esi
  800bde:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be0:	85 c0                	test   %eax,%eax
  800be2:	7e 17                	jle    800bfb <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be4:	83 ec 0c             	sub    $0xc,%esp
  800be7:	50                   	push   %eax
  800be8:	6a 05                	push   $0x5
  800bea:	68 9f 25 80 00       	push   $0x80259f
  800bef:	6a 23                	push   $0x23
  800bf1:	68 bc 25 80 00       	push   $0x8025bc
  800bf6:	e8 90 11 00 00       	call   801d8b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c11:	b8 06 00 00 00       	mov    $0x6,%eax
  800c16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1c:	89 df                	mov    %ebx,%edi
  800c1e:	89 de                	mov    %ebx,%esi
  800c20:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c22:	85 c0                	test   %eax,%eax
  800c24:	7e 17                	jle    800c3d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c26:	83 ec 0c             	sub    $0xc,%esp
  800c29:	50                   	push   %eax
  800c2a:	6a 06                	push   $0x6
  800c2c:	68 9f 25 80 00       	push   $0x80259f
  800c31:	6a 23                	push   $0x23
  800c33:	68 bc 25 80 00       	push   $0x8025bc
  800c38:	e8 4e 11 00 00       	call   801d8b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
  800c4b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c53:	b8 08 00 00 00       	mov    $0x8,%eax
  800c58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5e:	89 df                	mov    %ebx,%edi
  800c60:	89 de                	mov    %ebx,%esi
  800c62:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c64:	85 c0                	test   %eax,%eax
  800c66:	7e 17                	jle    800c7f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c68:	83 ec 0c             	sub    $0xc,%esp
  800c6b:	50                   	push   %eax
  800c6c:	6a 08                	push   $0x8
  800c6e:	68 9f 25 80 00       	push   $0x80259f
  800c73:	6a 23                	push   $0x23
  800c75:	68 bc 25 80 00       	push   $0x8025bc
  800c7a:	e8 0c 11 00 00       	call   801d8b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c90:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c95:	b8 09 00 00 00       	mov    $0x9,%eax
  800c9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca0:	89 df                	mov    %ebx,%edi
  800ca2:	89 de                	mov    %ebx,%esi
  800ca4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca6:	85 c0                	test   %eax,%eax
  800ca8:	7e 17                	jle    800cc1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800caa:	83 ec 0c             	sub    $0xc,%esp
  800cad:	50                   	push   %eax
  800cae:	6a 09                	push   $0x9
  800cb0:	68 9f 25 80 00       	push   $0x80259f
  800cb5:	6a 23                	push   $0x23
  800cb7:	68 bc 25 80 00       	push   $0x8025bc
  800cbc:	e8 ca 10 00 00       	call   801d8b <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
  800ccf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce2:	89 df                	mov    %ebx,%edi
  800ce4:	89 de                	mov    %ebx,%esi
  800ce6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce8:	85 c0                	test   %eax,%eax
  800cea:	7e 17                	jle    800d03 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cec:	83 ec 0c             	sub    $0xc,%esp
  800cef:	50                   	push   %eax
  800cf0:	6a 0a                	push   $0xa
  800cf2:	68 9f 25 80 00       	push   $0x80259f
  800cf7:	6a 23                	push   $0x23
  800cf9:	68 bc 25 80 00       	push   $0x8025bc
  800cfe:	e8 88 10 00 00       	call   801d8b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5f                   	pop    %edi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	57                   	push   %edi
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d11:	be 00 00 00 00       	mov    $0x0,%esi
  800d16:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d21:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d24:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d27:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d29:	5b                   	pop    %ebx
  800d2a:	5e                   	pop    %esi
  800d2b:	5f                   	pop    %edi
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    

00800d2e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	57                   	push   %edi
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
  800d34:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d37:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d41:	8b 55 08             	mov    0x8(%ebp),%edx
  800d44:	89 cb                	mov    %ecx,%ebx
  800d46:	89 cf                	mov    %ecx,%edi
  800d48:	89 ce                	mov    %ecx,%esi
  800d4a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d4c:	85 c0                	test   %eax,%eax
  800d4e:	7e 17                	jle    800d67 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d50:	83 ec 0c             	sub    $0xc,%esp
  800d53:	50                   	push   %eax
  800d54:	6a 0d                	push   $0xd
  800d56:	68 9f 25 80 00       	push   $0x80259f
  800d5b:	6a 23                	push   $0x23
  800d5d:	68 bc 25 80 00       	push   $0x8025bc
  800d62:	e8 24 10 00 00       	call   801d8b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6a:	5b                   	pop    %ebx
  800d6b:	5e                   	pop    %esi
  800d6c:	5f                   	pop    %edi
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    

00800d6f <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	57                   	push   %edi
  800d73:	56                   	push   %esi
  800d74:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d75:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d7a:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d82:	89 cb                	mov    %ecx,%ebx
  800d84:	89 cf                	mov    %ecx,%edi
  800d86:	89 ce                	mov    %ecx,%esi
  800d88:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d8a:	5b                   	pop    %ebx
  800d8b:	5e                   	pop    %esi
  800d8c:	5f                   	pop    %edi
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    

00800d8f <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	57                   	push   %edi
  800d93:	56                   	push   %esi
  800d94:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d95:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d9a:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800da2:	89 cb                	mov    %ecx,%ebx
  800da4:	89 cf                	mov    %ecx,%edi
  800da6:	89 ce                	mov    %ecx,%esi
  800da8:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800daa:	5b                   	pop    %ebx
  800dab:	5e                   	pop    %esi
  800dac:	5f                   	pop    %edi
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    

00800daf <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	53                   	push   %ebx
  800db3:	83 ec 04             	sub    $0x4,%esp
  800db6:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800db9:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800dbb:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dbf:	74 11                	je     800dd2 <pgfault+0x23>
  800dc1:	89 d8                	mov    %ebx,%eax
  800dc3:	c1 e8 0c             	shr    $0xc,%eax
  800dc6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dcd:	f6 c4 08             	test   $0x8,%ah
  800dd0:	75 14                	jne    800de6 <pgfault+0x37>
		panic("faulting access");
  800dd2:	83 ec 04             	sub    $0x4,%esp
  800dd5:	68 ca 25 80 00       	push   $0x8025ca
  800dda:	6a 1e                	push   $0x1e
  800ddc:	68 da 25 80 00       	push   $0x8025da
  800de1:	e8 a5 0f 00 00       	call   801d8b <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800de6:	83 ec 04             	sub    $0x4,%esp
  800de9:	6a 07                	push   $0x7
  800deb:	68 00 f0 7f 00       	push   $0x7ff000
  800df0:	6a 00                	push   $0x0
  800df2:	e8 87 fd ff ff       	call   800b7e <sys_page_alloc>
	if (r < 0) {
  800df7:	83 c4 10             	add    $0x10,%esp
  800dfa:	85 c0                	test   %eax,%eax
  800dfc:	79 12                	jns    800e10 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800dfe:	50                   	push   %eax
  800dff:	68 e5 25 80 00       	push   $0x8025e5
  800e04:	6a 2c                	push   $0x2c
  800e06:	68 da 25 80 00       	push   $0x8025da
  800e0b:	e8 7b 0f 00 00       	call   801d8b <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e10:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e16:	83 ec 04             	sub    $0x4,%esp
  800e19:	68 00 10 00 00       	push   $0x1000
  800e1e:	53                   	push   %ebx
  800e1f:	68 00 f0 7f 00       	push   $0x7ff000
  800e24:	e8 4c fb ff ff       	call   800975 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e29:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e30:	53                   	push   %ebx
  800e31:	6a 00                	push   $0x0
  800e33:	68 00 f0 7f 00       	push   $0x7ff000
  800e38:	6a 00                	push   $0x0
  800e3a:	e8 82 fd ff ff       	call   800bc1 <sys_page_map>
	if (r < 0) {
  800e3f:	83 c4 20             	add    $0x20,%esp
  800e42:	85 c0                	test   %eax,%eax
  800e44:	79 12                	jns    800e58 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e46:	50                   	push   %eax
  800e47:	68 e5 25 80 00       	push   $0x8025e5
  800e4c:	6a 33                	push   $0x33
  800e4e:	68 da 25 80 00       	push   $0x8025da
  800e53:	e8 33 0f 00 00       	call   801d8b <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e58:	83 ec 08             	sub    $0x8,%esp
  800e5b:	68 00 f0 7f 00       	push   $0x7ff000
  800e60:	6a 00                	push   $0x0
  800e62:	e8 9c fd ff ff       	call   800c03 <sys_page_unmap>
	if (r < 0) {
  800e67:	83 c4 10             	add    $0x10,%esp
  800e6a:	85 c0                	test   %eax,%eax
  800e6c:	79 12                	jns    800e80 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e6e:	50                   	push   %eax
  800e6f:	68 e5 25 80 00       	push   $0x8025e5
  800e74:	6a 37                	push   $0x37
  800e76:	68 da 25 80 00       	push   $0x8025da
  800e7b:	e8 0b 0f 00 00       	call   801d8b <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e83:	c9                   	leave  
  800e84:	c3                   	ret    

00800e85 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	57                   	push   %edi
  800e89:	56                   	push   %esi
  800e8a:	53                   	push   %ebx
  800e8b:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e8e:	68 af 0d 80 00       	push   $0x800daf
  800e93:	e8 39 0f 00 00       	call   801dd1 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e98:	b8 07 00 00 00       	mov    $0x7,%eax
  800e9d:	cd 30                	int    $0x30
  800e9f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800ea2:	83 c4 10             	add    $0x10,%esp
  800ea5:	85 c0                	test   %eax,%eax
  800ea7:	79 17                	jns    800ec0 <fork+0x3b>
		panic("fork fault %e");
  800ea9:	83 ec 04             	sub    $0x4,%esp
  800eac:	68 fe 25 80 00       	push   $0x8025fe
  800eb1:	68 84 00 00 00       	push   $0x84
  800eb6:	68 da 25 80 00       	push   $0x8025da
  800ebb:	e8 cb 0e 00 00       	call   801d8b <_panic>
  800ec0:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800ec2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ec6:	75 25                	jne    800eed <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ec8:	e8 73 fc ff ff       	call   800b40 <sys_getenvid>
  800ecd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ed2:	89 c2                	mov    %eax,%edx
  800ed4:	c1 e2 07             	shl    $0x7,%edx
  800ed7:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800ede:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800ee3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee8:	e9 61 01 00 00       	jmp    80104e <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800eed:	83 ec 04             	sub    $0x4,%esp
  800ef0:	6a 07                	push   $0x7
  800ef2:	68 00 f0 bf ee       	push   $0xeebff000
  800ef7:	ff 75 e4             	pushl  -0x1c(%ebp)
  800efa:	e8 7f fc ff ff       	call   800b7e <sys_page_alloc>
  800eff:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f02:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f07:	89 d8                	mov    %ebx,%eax
  800f09:	c1 e8 16             	shr    $0x16,%eax
  800f0c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f13:	a8 01                	test   $0x1,%al
  800f15:	0f 84 fc 00 00 00    	je     801017 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f1b:	89 d8                	mov    %ebx,%eax
  800f1d:	c1 e8 0c             	shr    $0xc,%eax
  800f20:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f27:	f6 c2 01             	test   $0x1,%dl
  800f2a:	0f 84 e7 00 00 00    	je     801017 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f30:	89 c6                	mov    %eax,%esi
  800f32:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f35:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f3c:	f6 c6 04             	test   $0x4,%dh
  800f3f:	74 39                	je     800f7a <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f41:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f48:	83 ec 0c             	sub    $0xc,%esp
  800f4b:	25 07 0e 00 00       	and    $0xe07,%eax
  800f50:	50                   	push   %eax
  800f51:	56                   	push   %esi
  800f52:	57                   	push   %edi
  800f53:	56                   	push   %esi
  800f54:	6a 00                	push   $0x0
  800f56:	e8 66 fc ff ff       	call   800bc1 <sys_page_map>
		if (r < 0) {
  800f5b:	83 c4 20             	add    $0x20,%esp
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	0f 89 b1 00 00 00    	jns    801017 <fork+0x192>
		    	panic("sys page map fault %e");
  800f66:	83 ec 04             	sub    $0x4,%esp
  800f69:	68 0c 26 80 00       	push   $0x80260c
  800f6e:	6a 54                	push   $0x54
  800f70:	68 da 25 80 00       	push   $0x8025da
  800f75:	e8 11 0e 00 00       	call   801d8b <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f7a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f81:	f6 c2 02             	test   $0x2,%dl
  800f84:	75 0c                	jne    800f92 <fork+0x10d>
  800f86:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f8d:	f6 c4 08             	test   $0x8,%ah
  800f90:	74 5b                	je     800fed <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f92:	83 ec 0c             	sub    $0xc,%esp
  800f95:	68 05 08 00 00       	push   $0x805
  800f9a:	56                   	push   %esi
  800f9b:	57                   	push   %edi
  800f9c:	56                   	push   %esi
  800f9d:	6a 00                	push   $0x0
  800f9f:	e8 1d fc ff ff       	call   800bc1 <sys_page_map>
		if (r < 0) {
  800fa4:	83 c4 20             	add    $0x20,%esp
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	79 14                	jns    800fbf <fork+0x13a>
		    	panic("sys page map fault %e");
  800fab:	83 ec 04             	sub    $0x4,%esp
  800fae:	68 0c 26 80 00       	push   $0x80260c
  800fb3:	6a 5b                	push   $0x5b
  800fb5:	68 da 25 80 00       	push   $0x8025da
  800fba:	e8 cc 0d 00 00       	call   801d8b <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800fbf:	83 ec 0c             	sub    $0xc,%esp
  800fc2:	68 05 08 00 00       	push   $0x805
  800fc7:	56                   	push   %esi
  800fc8:	6a 00                	push   $0x0
  800fca:	56                   	push   %esi
  800fcb:	6a 00                	push   $0x0
  800fcd:	e8 ef fb ff ff       	call   800bc1 <sys_page_map>
		if (r < 0) {
  800fd2:	83 c4 20             	add    $0x20,%esp
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	79 3e                	jns    801017 <fork+0x192>
		    	panic("sys page map fault %e");
  800fd9:	83 ec 04             	sub    $0x4,%esp
  800fdc:	68 0c 26 80 00       	push   $0x80260c
  800fe1:	6a 5f                	push   $0x5f
  800fe3:	68 da 25 80 00       	push   $0x8025da
  800fe8:	e8 9e 0d 00 00       	call   801d8b <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800fed:	83 ec 0c             	sub    $0xc,%esp
  800ff0:	6a 05                	push   $0x5
  800ff2:	56                   	push   %esi
  800ff3:	57                   	push   %edi
  800ff4:	56                   	push   %esi
  800ff5:	6a 00                	push   $0x0
  800ff7:	e8 c5 fb ff ff       	call   800bc1 <sys_page_map>
		if (r < 0) {
  800ffc:	83 c4 20             	add    $0x20,%esp
  800fff:	85 c0                	test   %eax,%eax
  801001:	79 14                	jns    801017 <fork+0x192>
		    	panic("sys page map fault %e");
  801003:	83 ec 04             	sub    $0x4,%esp
  801006:	68 0c 26 80 00       	push   $0x80260c
  80100b:	6a 64                	push   $0x64
  80100d:	68 da 25 80 00       	push   $0x8025da
  801012:	e8 74 0d 00 00       	call   801d8b <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801017:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80101d:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801023:	0f 85 de fe ff ff    	jne    800f07 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801029:	a1 04 40 80 00       	mov    0x804004,%eax
  80102e:	8b 40 70             	mov    0x70(%eax),%eax
  801031:	83 ec 08             	sub    $0x8,%esp
  801034:	50                   	push   %eax
  801035:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801038:	57                   	push   %edi
  801039:	e8 8b fc ff ff       	call   800cc9 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80103e:	83 c4 08             	add    $0x8,%esp
  801041:	6a 02                	push   $0x2
  801043:	57                   	push   %edi
  801044:	e8 fc fb ff ff       	call   800c45 <sys_env_set_status>
	
	return envid;
  801049:	83 c4 10             	add    $0x10,%esp
  80104c:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80104e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801051:	5b                   	pop    %ebx
  801052:	5e                   	pop    %esi
  801053:	5f                   	pop    %edi
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    

00801056 <sfork>:

envid_t
sfork(void)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801059:	b8 00 00 00 00       	mov    $0x0,%eax
  80105e:	5d                   	pop    %ebp
  80105f:	c3                   	ret    

00801060 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	56                   	push   %esi
  801064:	53                   	push   %ebx
  801065:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801068:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  80106e:	83 ec 08             	sub    $0x8,%esp
  801071:	53                   	push   %ebx
  801072:	68 24 26 80 00       	push   $0x802624
  801077:	e8 7a f1 ff ff       	call   8001f6 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80107c:	c7 04 24 29 01 80 00 	movl   $0x800129,(%esp)
  801083:	e8 e7 fc ff ff       	call   800d6f <sys_thread_create>
  801088:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80108a:	83 c4 08             	add    $0x8,%esp
  80108d:	53                   	push   %ebx
  80108e:	68 24 26 80 00       	push   $0x802624
  801093:	e8 5e f1 ff ff       	call   8001f6 <cprintf>
	return id;
	//return 0;
}
  801098:	89 f0                	mov    %esi,%eax
  80109a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80109d:	5b                   	pop    %ebx
  80109e:	5e                   	pop    %esi
  80109f:	5d                   	pop    %ebp
  8010a0:	c3                   	ret    

008010a1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010a1:	55                   	push   %ebp
  8010a2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a7:	05 00 00 00 30       	add    $0x30000000,%eax
  8010ac:	c1 e8 0c             	shr    $0xc,%eax
}
  8010af:	5d                   	pop    %ebp
  8010b0:	c3                   	ret    

008010b1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010b1:	55                   	push   %ebp
  8010b2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b7:	05 00 00 00 30       	add    $0x30000000,%eax
  8010bc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010c1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010c6:	5d                   	pop    %ebp
  8010c7:	c3                   	ret    

008010c8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010c8:	55                   	push   %ebp
  8010c9:	89 e5                	mov    %esp,%ebp
  8010cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ce:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010d3:	89 c2                	mov    %eax,%edx
  8010d5:	c1 ea 16             	shr    $0x16,%edx
  8010d8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010df:	f6 c2 01             	test   $0x1,%dl
  8010e2:	74 11                	je     8010f5 <fd_alloc+0x2d>
  8010e4:	89 c2                	mov    %eax,%edx
  8010e6:	c1 ea 0c             	shr    $0xc,%edx
  8010e9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010f0:	f6 c2 01             	test   $0x1,%dl
  8010f3:	75 09                	jne    8010fe <fd_alloc+0x36>
			*fd_store = fd;
  8010f5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8010fc:	eb 17                	jmp    801115 <fd_alloc+0x4d>
  8010fe:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801103:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801108:	75 c9                	jne    8010d3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80110a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801110:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801115:	5d                   	pop    %ebp
  801116:	c3                   	ret    

00801117 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801117:	55                   	push   %ebp
  801118:	89 e5                	mov    %esp,%ebp
  80111a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80111d:	83 f8 1f             	cmp    $0x1f,%eax
  801120:	77 36                	ja     801158 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801122:	c1 e0 0c             	shl    $0xc,%eax
  801125:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80112a:	89 c2                	mov    %eax,%edx
  80112c:	c1 ea 16             	shr    $0x16,%edx
  80112f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801136:	f6 c2 01             	test   $0x1,%dl
  801139:	74 24                	je     80115f <fd_lookup+0x48>
  80113b:	89 c2                	mov    %eax,%edx
  80113d:	c1 ea 0c             	shr    $0xc,%edx
  801140:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801147:	f6 c2 01             	test   $0x1,%dl
  80114a:	74 1a                	je     801166 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80114c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80114f:	89 02                	mov    %eax,(%edx)
	return 0;
  801151:	b8 00 00 00 00       	mov    $0x0,%eax
  801156:	eb 13                	jmp    80116b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801158:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80115d:	eb 0c                	jmp    80116b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80115f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801164:	eb 05                	jmp    80116b <fd_lookup+0x54>
  801166:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80116b:	5d                   	pop    %ebp
  80116c:	c3                   	ret    

0080116d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80116d:	55                   	push   %ebp
  80116e:	89 e5                	mov    %esp,%ebp
  801170:	83 ec 08             	sub    $0x8,%esp
  801173:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801176:	ba c4 26 80 00       	mov    $0x8026c4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80117b:	eb 13                	jmp    801190 <dev_lookup+0x23>
  80117d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801180:	39 08                	cmp    %ecx,(%eax)
  801182:	75 0c                	jne    801190 <dev_lookup+0x23>
			*dev = devtab[i];
  801184:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801187:	89 01                	mov    %eax,(%ecx)
			return 0;
  801189:	b8 00 00 00 00       	mov    $0x0,%eax
  80118e:	eb 2e                	jmp    8011be <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801190:	8b 02                	mov    (%edx),%eax
  801192:	85 c0                	test   %eax,%eax
  801194:	75 e7                	jne    80117d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801196:	a1 04 40 80 00       	mov    0x804004,%eax
  80119b:	8b 40 54             	mov    0x54(%eax),%eax
  80119e:	83 ec 04             	sub    $0x4,%esp
  8011a1:	51                   	push   %ecx
  8011a2:	50                   	push   %eax
  8011a3:	68 48 26 80 00       	push   $0x802648
  8011a8:	e8 49 f0 ff ff       	call   8001f6 <cprintf>
	*dev = 0;
  8011ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011b0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011b6:	83 c4 10             	add    $0x10,%esp
  8011b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011be:	c9                   	leave  
  8011bf:	c3                   	ret    

008011c0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
  8011c3:	56                   	push   %esi
  8011c4:	53                   	push   %ebx
  8011c5:	83 ec 10             	sub    $0x10,%esp
  8011c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8011cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d1:	50                   	push   %eax
  8011d2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011d8:	c1 e8 0c             	shr    $0xc,%eax
  8011db:	50                   	push   %eax
  8011dc:	e8 36 ff ff ff       	call   801117 <fd_lookup>
  8011e1:	83 c4 08             	add    $0x8,%esp
  8011e4:	85 c0                	test   %eax,%eax
  8011e6:	78 05                	js     8011ed <fd_close+0x2d>
	    || fd != fd2)
  8011e8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011eb:	74 0c                	je     8011f9 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011ed:	84 db                	test   %bl,%bl
  8011ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8011f4:	0f 44 c2             	cmove  %edx,%eax
  8011f7:	eb 41                	jmp    80123a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011f9:	83 ec 08             	sub    $0x8,%esp
  8011fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ff:	50                   	push   %eax
  801200:	ff 36                	pushl  (%esi)
  801202:	e8 66 ff ff ff       	call   80116d <dev_lookup>
  801207:	89 c3                	mov    %eax,%ebx
  801209:	83 c4 10             	add    $0x10,%esp
  80120c:	85 c0                	test   %eax,%eax
  80120e:	78 1a                	js     80122a <fd_close+0x6a>
		if (dev->dev_close)
  801210:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801213:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801216:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80121b:	85 c0                	test   %eax,%eax
  80121d:	74 0b                	je     80122a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80121f:	83 ec 0c             	sub    $0xc,%esp
  801222:	56                   	push   %esi
  801223:	ff d0                	call   *%eax
  801225:	89 c3                	mov    %eax,%ebx
  801227:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80122a:	83 ec 08             	sub    $0x8,%esp
  80122d:	56                   	push   %esi
  80122e:	6a 00                	push   $0x0
  801230:	e8 ce f9 ff ff       	call   800c03 <sys_page_unmap>
	return r;
  801235:	83 c4 10             	add    $0x10,%esp
  801238:	89 d8                	mov    %ebx,%eax
}
  80123a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80123d:	5b                   	pop    %ebx
  80123e:	5e                   	pop    %esi
  80123f:	5d                   	pop    %ebp
  801240:	c3                   	ret    

00801241 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
  801244:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801247:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80124a:	50                   	push   %eax
  80124b:	ff 75 08             	pushl  0x8(%ebp)
  80124e:	e8 c4 fe ff ff       	call   801117 <fd_lookup>
  801253:	83 c4 08             	add    $0x8,%esp
  801256:	85 c0                	test   %eax,%eax
  801258:	78 10                	js     80126a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80125a:	83 ec 08             	sub    $0x8,%esp
  80125d:	6a 01                	push   $0x1
  80125f:	ff 75 f4             	pushl  -0xc(%ebp)
  801262:	e8 59 ff ff ff       	call   8011c0 <fd_close>
  801267:	83 c4 10             	add    $0x10,%esp
}
  80126a:	c9                   	leave  
  80126b:	c3                   	ret    

0080126c <close_all>:

void
close_all(void)
{
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	53                   	push   %ebx
  801270:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801273:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801278:	83 ec 0c             	sub    $0xc,%esp
  80127b:	53                   	push   %ebx
  80127c:	e8 c0 ff ff ff       	call   801241 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801281:	83 c3 01             	add    $0x1,%ebx
  801284:	83 c4 10             	add    $0x10,%esp
  801287:	83 fb 20             	cmp    $0x20,%ebx
  80128a:	75 ec                	jne    801278 <close_all+0xc>
		close(i);
}
  80128c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80128f:	c9                   	leave  
  801290:	c3                   	ret    

00801291 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801291:	55                   	push   %ebp
  801292:	89 e5                	mov    %esp,%ebp
  801294:	57                   	push   %edi
  801295:	56                   	push   %esi
  801296:	53                   	push   %ebx
  801297:	83 ec 2c             	sub    $0x2c,%esp
  80129a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80129d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012a0:	50                   	push   %eax
  8012a1:	ff 75 08             	pushl  0x8(%ebp)
  8012a4:	e8 6e fe ff ff       	call   801117 <fd_lookup>
  8012a9:	83 c4 08             	add    $0x8,%esp
  8012ac:	85 c0                	test   %eax,%eax
  8012ae:	0f 88 c1 00 00 00    	js     801375 <dup+0xe4>
		return r;
	close(newfdnum);
  8012b4:	83 ec 0c             	sub    $0xc,%esp
  8012b7:	56                   	push   %esi
  8012b8:	e8 84 ff ff ff       	call   801241 <close>

	newfd = INDEX2FD(newfdnum);
  8012bd:	89 f3                	mov    %esi,%ebx
  8012bf:	c1 e3 0c             	shl    $0xc,%ebx
  8012c2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012c8:	83 c4 04             	add    $0x4,%esp
  8012cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012ce:	e8 de fd ff ff       	call   8010b1 <fd2data>
  8012d3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012d5:	89 1c 24             	mov    %ebx,(%esp)
  8012d8:	e8 d4 fd ff ff       	call   8010b1 <fd2data>
  8012dd:	83 c4 10             	add    $0x10,%esp
  8012e0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012e3:	89 f8                	mov    %edi,%eax
  8012e5:	c1 e8 16             	shr    $0x16,%eax
  8012e8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012ef:	a8 01                	test   $0x1,%al
  8012f1:	74 37                	je     80132a <dup+0x99>
  8012f3:	89 f8                	mov    %edi,%eax
  8012f5:	c1 e8 0c             	shr    $0xc,%eax
  8012f8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012ff:	f6 c2 01             	test   $0x1,%dl
  801302:	74 26                	je     80132a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801304:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80130b:	83 ec 0c             	sub    $0xc,%esp
  80130e:	25 07 0e 00 00       	and    $0xe07,%eax
  801313:	50                   	push   %eax
  801314:	ff 75 d4             	pushl  -0x2c(%ebp)
  801317:	6a 00                	push   $0x0
  801319:	57                   	push   %edi
  80131a:	6a 00                	push   $0x0
  80131c:	e8 a0 f8 ff ff       	call   800bc1 <sys_page_map>
  801321:	89 c7                	mov    %eax,%edi
  801323:	83 c4 20             	add    $0x20,%esp
  801326:	85 c0                	test   %eax,%eax
  801328:	78 2e                	js     801358 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80132a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80132d:	89 d0                	mov    %edx,%eax
  80132f:	c1 e8 0c             	shr    $0xc,%eax
  801332:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801339:	83 ec 0c             	sub    $0xc,%esp
  80133c:	25 07 0e 00 00       	and    $0xe07,%eax
  801341:	50                   	push   %eax
  801342:	53                   	push   %ebx
  801343:	6a 00                	push   $0x0
  801345:	52                   	push   %edx
  801346:	6a 00                	push   $0x0
  801348:	e8 74 f8 ff ff       	call   800bc1 <sys_page_map>
  80134d:	89 c7                	mov    %eax,%edi
  80134f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801352:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801354:	85 ff                	test   %edi,%edi
  801356:	79 1d                	jns    801375 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801358:	83 ec 08             	sub    $0x8,%esp
  80135b:	53                   	push   %ebx
  80135c:	6a 00                	push   $0x0
  80135e:	e8 a0 f8 ff ff       	call   800c03 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801363:	83 c4 08             	add    $0x8,%esp
  801366:	ff 75 d4             	pushl  -0x2c(%ebp)
  801369:	6a 00                	push   $0x0
  80136b:	e8 93 f8 ff ff       	call   800c03 <sys_page_unmap>
	return r;
  801370:	83 c4 10             	add    $0x10,%esp
  801373:	89 f8                	mov    %edi,%eax
}
  801375:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801378:	5b                   	pop    %ebx
  801379:	5e                   	pop    %esi
  80137a:	5f                   	pop    %edi
  80137b:	5d                   	pop    %ebp
  80137c:	c3                   	ret    

0080137d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80137d:	55                   	push   %ebp
  80137e:	89 e5                	mov    %esp,%ebp
  801380:	53                   	push   %ebx
  801381:	83 ec 14             	sub    $0x14,%esp
  801384:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801387:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138a:	50                   	push   %eax
  80138b:	53                   	push   %ebx
  80138c:	e8 86 fd ff ff       	call   801117 <fd_lookup>
  801391:	83 c4 08             	add    $0x8,%esp
  801394:	89 c2                	mov    %eax,%edx
  801396:	85 c0                	test   %eax,%eax
  801398:	78 6d                	js     801407 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139a:	83 ec 08             	sub    $0x8,%esp
  80139d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a0:	50                   	push   %eax
  8013a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a4:	ff 30                	pushl  (%eax)
  8013a6:	e8 c2 fd ff ff       	call   80116d <dev_lookup>
  8013ab:	83 c4 10             	add    $0x10,%esp
  8013ae:	85 c0                	test   %eax,%eax
  8013b0:	78 4c                	js     8013fe <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013b5:	8b 42 08             	mov    0x8(%edx),%eax
  8013b8:	83 e0 03             	and    $0x3,%eax
  8013bb:	83 f8 01             	cmp    $0x1,%eax
  8013be:	75 21                	jne    8013e1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013c0:	a1 04 40 80 00       	mov    0x804004,%eax
  8013c5:	8b 40 54             	mov    0x54(%eax),%eax
  8013c8:	83 ec 04             	sub    $0x4,%esp
  8013cb:	53                   	push   %ebx
  8013cc:	50                   	push   %eax
  8013cd:	68 89 26 80 00       	push   $0x802689
  8013d2:	e8 1f ee ff ff       	call   8001f6 <cprintf>
		return -E_INVAL;
  8013d7:	83 c4 10             	add    $0x10,%esp
  8013da:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013df:	eb 26                	jmp    801407 <read+0x8a>
	}
	if (!dev->dev_read)
  8013e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e4:	8b 40 08             	mov    0x8(%eax),%eax
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	74 17                	je     801402 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8013eb:	83 ec 04             	sub    $0x4,%esp
  8013ee:	ff 75 10             	pushl  0x10(%ebp)
  8013f1:	ff 75 0c             	pushl  0xc(%ebp)
  8013f4:	52                   	push   %edx
  8013f5:	ff d0                	call   *%eax
  8013f7:	89 c2                	mov    %eax,%edx
  8013f9:	83 c4 10             	add    $0x10,%esp
  8013fc:	eb 09                	jmp    801407 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013fe:	89 c2                	mov    %eax,%edx
  801400:	eb 05                	jmp    801407 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801402:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801407:	89 d0                	mov    %edx,%eax
  801409:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140c:	c9                   	leave  
  80140d:	c3                   	ret    

0080140e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80140e:	55                   	push   %ebp
  80140f:	89 e5                	mov    %esp,%ebp
  801411:	57                   	push   %edi
  801412:	56                   	push   %esi
  801413:	53                   	push   %ebx
  801414:	83 ec 0c             	sub    $0xc,%esp
  801417:	8b 7d 08             	mov    0x8(%ebp),%edi
  80141a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80141d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801422:	eb 21                	jmp    801445 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801424:	83 ec 04             	sub    $0x4,%esp
  801427:	89 f0                	mov    %esi,%eax
  801429:	29 d8                	sub    %ebx,%eax
  80142b:	50                   	push   %eax
  80142c:	89 d8                	mov    %ebx,%eax
  80142e:	03 45 0c             	add    0xc(%ebp),%eax
  801431:	50                   	push   %eax
  801432:	57                   	push   %edi
  801433:	e8 45 ff ff ff       	call   80137d <read>
		if (m < 0)
  801438:	83 c4 10             	add    $0x10,%esp
  80143b:	85 c0                	test   %eax,%eax
  80143d:	78 10                	js     80144f <readn+0x41>
			return m;
		if (m == 0)
  80143f:	85 c0                	test   %eax,%eax
  801441:	74 0a                	je     80144d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801443:	01 c3                	add    %eax,%ebx
  801445:	39 f3                	cmp    %esi,%ebx
  801447:	72 db                	jb     801424 <readn+0x16>
  801449:	89 d8                	mov    %ebx,%eax
  80144b:	eb 02                	jmp    80144f <readn+0x41>
  80144d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80144f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801452:	5b                   	pop    %ebx
  801453:	5e                   	pop    %esi
  801454:	5f                   	pop    %edi
  801455:	5d                   	pop    %ebp
  801456:	c3                   	ret    

00801457 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801457:	55                   	push   %ebp
  801458:	89 e5                	mov    %esp,%ebp
  80145a:	53                   	push   %ebx
  80145b:	83 ec 14             	sub    $0x14,%esp
  80145e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801461:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801464:	50                   	push   %eax
  801465:	53                   	push   %ebx
  801466:	e8 ac fc ff ff       	call   801117 <fd_lookup>
  80146b:	83 c4 08             	add    $0x8,%esp
  80146e:	89 c2                	mov    %eax,%edx
  801470:	85 c0                	test   %eax,%eax
  801472:	78 68                	js     8014dc <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801474:	83 ec 08             	sub    $0x8,%esp
  801477:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147a:	50                   	push   %eax
  80147b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147e:	ff 30                	pushl  (%eax)
  801480:	e8 e8 fc ff ff       	call   80116d <dev_lookup>
  801485:	83 c4 10             	add    $0x10,%esp
  801488:	85 c0                	test   %eax,%eax
  80148a:	78 47                	js     8014d3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80148c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80148f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801493:	75 21                	jne    8014b6 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801495:	a1 04 40 80 00       	mov    0x804004,%eax
  80149a:	8b 40 54             	mov    0x54(%eax),%eax
  80149d:	83 ec 04             	sub    $0x4,%esp
  8014a0:	53                   	push   %ebx
  8014a1:	50                   	push   %eax
  8014a2:	68 a5 26 80 00       	push   $0x8026a5
  8014a7:	e8 4a ed ff ff       	call   8001f6 <cprintf>
		return -E_INVAL;
  8014ac:	83 c4 10             	add    $0x10,%esp
  8014af:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014b4:	eb 26                	jmp    8014dc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014b9:	8b 52 0c             	mov    0xc(%edx),%edx
  8014bc:	85 d2                	test   %edx,%edx
  8014be:	74 17                	je     8014d7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014c0:	83 ec 04             	sub    $0x4,%esp
  8014c3:	ff 75 10             	pushl  0x10(%ebp)
  8014c6:	ff 75 0c             	pushl  0xc(%ebp)
  8014c9:	50                   	push   %eax
  8014ca:	ff d2                	call   *%edx
  8014cc:	89 c2                	mov    %eax,%edx
  8014ce:	83 c4 10             	add    $0x10,%esp
  8014d1:	eb 09                	jmp    8014dc <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d3:	89 c2                	mov    %eax,%edx
  8014d5:	eb 05                	jmp    8014dc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014d7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014dc:	89 d0                	mov    %edx,%eax
  8014de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e1:	c9                   	leave  
  8014e2:	c3                   	ret    

008014e3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014e3:	55                   	push   %ebp
  8014e4:	89 e5                	mov    %esp,%ebp
  8014e6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014e9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014ec:	50                   	push   %eax
  8014ed:	ff 75 08             	pushl  0x8(%ebp)
  8014f0:	e8 22 fc ff ff       	call   801117 <fd_lookup>
  8014f5:	83 c4 08             	add    $0x8,%esp
  8014f8:	85 c0                	test   %eax,%eax
  8014fa:	78 0e                	js     80150a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801502:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801505:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80150a:	c9                   	leave  
  80150b:	c3                   	ret    

0080150c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80150c:	55                   	push   %ebp
  80150d:	89 e5                	mov    %esp,%ebp
  80150f:	53                   	push   %ebx
  801510:	83 ec 14             	sub    $0x14,%esp
  801513:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801516:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801519:	50                   	push   %eax
  80151a:	53                   	push   %ebx
  80151b:	e8 f7 fb ff ff       	call   801117 <fd_lookup>
  801520:	83 c4 08             	add    $0x8,%esp
  801523:	89 c2                	mov    %eax,%edx
  801525:	85 c0                	test   %eax,%eax
  801527:	78 65                	js     80158e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801529:	83 ec 08             	sub    $0x8,%esp
  80152c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152f:	50                   	push   %eax
  801530:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801533:	ff 30                	pushl  (%eax)
  801535:	e8 33 fc ff ff       	call   80116d <dev_lookup>
  80153a:	83 c4 10             	add    $0x10,%esp
  80153d:	85 c0                	test   %eax,%eax
  80153f:	78 44                	js     801585 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801541:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801544:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801548:	75 21                	jne    80156b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80154a:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80154f:	8b 40 54             	mov    0x54(%eax),%eax
  801552:	83 ec 04             	sub    $0x4,%esp
  801555:	53                   	push   %ebx
  801556:	50                   	push   %eax
  801557:	68 68 26 80 00       	push   $0x802668
  80155c:	e8 95 ec ff ff       	call   8001f6 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801561:	83 c4 10             	add    $0x10,%esp
  801564:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801569:	eb 23                	jmp    80158e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80156b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80156e:	8b 52 18             	mov    0x18(%edx),%edx
  801571:	85 d2                	test   %edx,%edx
  801573:	74 14                	je     801589 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801575:	83 ec 08             	sub    $0x8,%esp
  801578:	ff 75 0c             	pushl  0xc(%ebp)
  80157b:	50                   	push   %eax
  80157c:	ff d2                	call   *%edx
  80157e:	89 c2                	mov    %eax,%edx
  801580:	83 c4 10             	add    $0x10,%esp
  801583:	eb 09                	jmp    80158e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801585:	89 c2                	mov    %eax,%edx
  801587:	eb 05                	jmp    80158e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801589:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80158e:	89 d0                	mov    %edx,%eax
  801590:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801593:	c9                   	leave  
  801594:	c3                   	ret    

00801595 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801595:	55                   	push   %ebp
  801596:	89 e5                	mov    %esp,%ebp
  801598:	53                   	push   %ebx
  801599:	83 ec 14             	sub    $0x14,%esp
  80159c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80159f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a2:	50                   	push   %eax
  8015a3:	ff 75 08             	pushl  0x8(%ebp)
  8015a6:	e8 6c fb ff ff       	call   801117 <fd_lookup>
  8015ab:	83 c4 08             	add    $0x8,%esp
  8015ae:	89 c2                	mov    %eax,%edx
  8015b0:	85 c0                	test   %eax,%eax
  8015b2:	78 58                	js     80160c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b4:	83 ec 08             	sub    $0x8,%esp
  8015b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ba:	50                   	push   %eax
  8015bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015be:	ff 30                	pushl  (%eax)
  8015c0:	e8 a8 fb ff ff       	call   80116d <dev_lookup>
  8015c5:	83 c4 10             	add    $0x10,%esp
  8015c8:	85 c0                	test   %eax,%eax
  8015ca:	78 37                	js     801603 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015cf:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015d3:	74 32                	je     801607 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015d5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015d8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015df:	00 00 00 
	stat->st_isdir = 0;
  8015e2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015e9:	00 00 00 
	stat->st_dev = dev;
  8015ec:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015f2:	83 ec 08             	sub    $0x8,%esp
  8015f5:	53                   	push   %ebx
  8015f6:	ff 75 f0             	pushl  -0x10(%ebp)
  8015f9:	ff 50 14             	call   *0x14(%eax)
  8015fc:	89 c2                	mov    %eax,%edx
  8015fe:	83 c4 10             	add    $0x10,%esp
  801601:	eb 09                	jmp    80160c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801603:	89 c2                	mov    %eax,%edx
  801605:	eb 05                	jmp    80160c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801607:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80160c:	89 d0                	mov    %edx,%eax
  80160e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801611:	c9                   	leave  
  801612:	c3                   	ret    

00801613 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801613:	55                   	push   %ebp
  801614:	89 e5                	mov    %esp,%ebp
  801616:	56                   	push   %esi
  801617:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801618:	83 ec 08             	sub    $0x8,%esp
  80161b:	6a 00                	push   $0x0
  80161d:	ff 75 08             	pushl  0x8(%ebp)
  801620:	e8 e3 01 00 00       	call   801808 <open>
  801625:	89 c3                	mov    %eax,%ebx
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	85 c0                	test   %eax,%eax
  80162c:	78 1b                	js     801649 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80162e:	83 ec 08             	sub    $0x8,%esp
  801631:	ff 75 0c             	pushl  0xc(%ebp)
  801634:	50                   	push   %eax
  801635:	e8 5b ff ff ff       	call   801595 <fstat>
  80163a:	89 c6                	mov    %eax,%esi
	close(fd);
  80163c:	89 1c 24             	mov    %ebx,(%esp)
  80163f:	e8 fd fb ff ff       	call   801241 <close>
	return r;
  801644:	83 c4 10             	add    $0x10,%esp
  801647:	89 f0                	mov    %esi,%eax
}
  801649:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80164c:	5b                   	pop    %ebx
  80164d:	5e                   	pop    %esi
  80164e:	5d                   	pop    %ebp
  80164f:	c3                   	ret    

00801650 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801650:	55                   	push   %ebp
  801651:	89 e5                	mov    %esp,%ebp
  801653:	56                   	push   %esi
  801654:	53                   	push   %ebx
  801655:	89 c6                	mov    %eax,%esi
  801657:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801659:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801660:	75 12                	jne    801674 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801662:	83 ec 0c             	sub    $0xc,%esp
  801665:	6a 01                	push   $0x1
  801667:	e8 ce 08 00 00       	call   801f3a <ipc_find_env>
  80166c:	a3 00 40 80 00       	mov    %eax,0x804000
  801671:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801674:	6a 07                	push   $0x7
  801676:	68 00 50 80 00       	push   $0x805000
  80167b:	56                   	push   %esi
  80167c:	ff 35 00 40 80 00    	pushl  0x804000
  801682:	e8 51 08 00 00       	call   801ed8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801687:	83 c4 0c             	add    $0xc,%esp
  80168a:	6a 00                	push   $0x0
  80168c:	53                   	push   %ebx
  80168d:	6a 00                	push   $0x0
  80168f:	e8 cc 07 00 00       	call   801e60 <ipc_recv>
}
  801694:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801697:	5b                   	pop    %ebx
  801698:	5e                   	pop    %esi
  801699:	5d                   	pop    %ebp
  80169a:	c3                   	ret    

0080169b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
  80169e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a4:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016af:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b9:	b8 02 00 00 00       	mov    $0x2,%eax
  8016be:	e8 8d ff ff ff       	call   801650 <fsipc>
}
  8016c3:	c9                   	leave  
  8016c4:	c3                   	ret    

008016c5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ce:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8016db:	b8 06 00 00 00       	mov    $0x6,%eax
  8016e0:	e8 6b ff ff ff       	call   801650 <fsipc>
}
  8016e5:	c9                   	leave  
  8016e6:	c3                   	ret    

008016e7 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016e7:	55                   	push   %ebp
  8016e8:	89 e5                	mov    %esp,%ebp
  8016ea:	53                   	push   %ebx
  8016eb:	83 ec 04             	sub    $0x4,%esp
  8016ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f4:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801701:	b8 05 00 00 00       	mov    $0x5,%eax
  801706:	e8 45 ff ff ff       	call   801650 <fsipc>
  80170b:	85 c0                	test   %eax,%eax
  80170d:	78 2c                	js     80173b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80170f:	83 ec 08             	sub    $0x8,%esp
  801712:	68 00 50 80 00       	push   $0x805000
  801717:	53                   	push   %ebx
  801718:	e8 5e f0 ff ff       	call   80077b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80171d:	a1 80 50 80 00       	mov    0x805080,%eax
  801722:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801728:	a1 84 50 80 00       	mov    0x805084,%eax
  80172d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801733:	83 c4 10             	add    $0x10,%esp
  801736:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80173b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80173e:	c9                   	leave  
  80173f:	c3                   	ret    

00801740 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801740:	55                   	push   %ebp
  801741:	89 e5                	mov    %esp,%ebp
  801743:	83 ec 0c             	sub    $0xc,%esp
  801746:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801749:	8b 55 08             	mov    0x8(%ebp),%edx
  80174c:	8b 52 0c             	mov    0xc(%edx),%edx
  80174f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801755:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80175a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80175f:	0f 47 c2             	cmova  %edx,%eax
  801762:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801767:	50                   	push   %eax
  801768:	ff 75 0c             	pushl  0xc(%ebp)
  80176b:	68 08 50 80 00       	push   $0x805008
  801770:	e8 98 f1 ff ff       	call   80090d <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801775:	ba 00 00 00 00       	mov    $0x0,%edx
  80177a:	b8 04 00 00 00       	mov    $0x4,%eax
  80177f:	e8 cc fe ff ff       	call   801650 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801784:	c9                   	leave  
  801785:	c3                   	ret    

00801786 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801786:	55                   	push   %ebp
  801787:	89 e5                	mov    %esp,%ebp
  801789:	56                   	push   %esi
  80178a:	53                   	push   %ebx
  80178b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80178e:	8b 45 08             	mov    0x8(%ebp),%eax
  801791:	8b 40 0c             	mov    0xc(%eax),%eax
  801794:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801799:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80179f:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a4:	b8 03 00 00 00       	mov    $0x3,%eax
  8017a9:	e8 a2 fe ff ff       	call   801650 <fsipc>
  8017ae:	89 c3                	mov    %eax,%ebx
  8017b0:	85 c0                	test   %eax,%eax
  8017b2:	78 4b                	js     8017ff <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017b4:	39 c6                	cmp    %eax,%esi
  8017b6:	73 16                	jae    8017ce <devfile_read+0x48>
  8017b8:	68 d4 26 80 00       	push   $0x8026d4
  8017bd:	68 db 26 80 00       	push   $0x8026db
  8017c2:	6a 7c                	push   $0x7c
  8017c4:	68 f0 26 80 00       	push   $0x8026f0
  8017c9:	e8 bd 05 00 00       	call   801d8b <_panic>
	assert(r <= PGSIZE);
  8017ce:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017d3:	7e 16                	jle    8017eb <devfile_read+0x65>
  8017d5:	68 fb 26 80 00       	push   $0x8026fb
  8017da:	68 db 26 80 00       	push   $0x8026db
  8017df:	6a 7d                	push   $0x7d
  8017e1:	68 f0 26 80 00       	push   $0x8026f0
  8017e6:	e8 a0 05 00 00       	call   801d8b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017eb:	83 ec 04             	sub    $0x4,%esp
  8017ee:	50                   	push   %eax
  8017ef:	68 00 50 80 00       	push   $0x805000
  8017f4:	ff 75 0c             	pushl  0xc(%ebp)
  8017f7:	e8 11 f1 ff ff       	call   80090d <memmove>
	return r;
  8017fc:	83 c4 10             	add    $0x10,%esp
}
  8017ff:	89 d8                	mov    %ebx,%eax
  801801:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801804:	5b                   	pop    %ebx
  801805:	5e                   	pop    %esi
  801806:	5d                   	pop    %ebp
  801807:	c3                   	ret    

00801808 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801808:	55                   	push   %ebp
  801809:	89 e5                	mov    %esp,%ebp
  80180b:	53                   	push   %ebx
  80180c:	83 ec 20             	sub    $0x20,%esp
  80180f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801812:	53                   	push   %ebx
  801813:	e8 2a ef ff ff       	call   800742 <strlen>
  801818:	83 c4 10             	add    $0x10,%esp
  80181b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801820:	7f 67                	jg     801889 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801822:	83 ec 0c             	sub    $0xc,%esp
  801825:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801828:	50                   	push   %eax
  801829:	e8 9a f8 ff ff       	call   8010c8 <fd_alloc>
  80182e:	83 c4 10             	add    $0x10,%esp
		return r;
  801831:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801833:	85 c0                	test   %eax,%eax
  801835:	78 57                	js     80188e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801837:	83 ec 08             	sub    $0x8,%esp
  80183a:	53                   	push   %ebx
  80183b:	68 00 50 80 00       	push   $0x805000
  801840:	e8 36 ef ff ff       	call   80077b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801845:	8b 45 0c             	mov    0xc(%ebp),%eax
  801848:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80184d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801850:	b8 01 00 00 00       	mov    $0x1,%eax
  801855:	e8 f6 fd ff ff       	call   801650 <fsipc>
  80185a:	89 c3                	mov    %eax,%ebx
  80185c:	83 c4 10             	add    $0x10,%esp
  80185f:	85 c0                	test   %eax,%eax
  801861:	79 14                	jns    801877 <open+0x6f>
		fd_close(fd, 0);
  801863:	83 ec 08             	sub    $0x8,%esp
  801866:	6a 00                	push   $0x0
  801868:	ff 75 f4             	pushl  -0xc(%ebp)
  80186b:	e8 50 f9 ff ff       	call   8011c0 <fd_close>
		return r;
  801870:	83 c4 10             	add    $0x10,%esp
  801873:	89 da                	mov    %ebx,%edx
  801875:	eb 17                	jmp    80188e <open+0x86>
	}

	return fd2num(fd);
  801877:	83 ec 0c             	sub    $0xc,%esp
  80187a:	ff 75 f4             	pushl  -0xc(%ebp)
  80187d:	e8 1f f8 ff ff       	call   8010a1 <fd2num>
  801882:	89 c2                	mov    %eax,%edx
  801884:	83 c4 10             	add    $0x10,%esp
  801887:	eb 05                	jmp    80188e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801889:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80188e:	89 d0                	mov    %edx,%eax
  801890:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801893:	c9                   	leave  
  801894:	c3                   	ret    

00801895 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801895:	55                   	push   %ebp
  801896:	89 e5                	mov    %esp,%ebp
  801898:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80189b:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a0:	b8 08 00 00 00       	mov    $0x8,%eax
  8018a5:	e8 a6 fd ff ff       	call   801650 <fsipc>
}
  8018aa:	c9                   	leave  
  8018ab:	c3                   	ret    

008018ac <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018ac:	55                   	push   %ebp
  8018ad:	89 e5                	mov    %esp,%ebp
  8018af:	56                   	push   %esi
  8018b0:	53                   	push   %ebx
  8018b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018b4:	83 ec 0c             	sub    $0xc,%esp
  8018b7:	ff 75 08             	pushl  0x8(%ebp)
  8018ba:	e8 f2 f7 ff ff       	call   8010b1 <fd2data>
  8018bf:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018c1:	83 c4 08             	add    $0x8,%esp
  8018c4:	68 07 27 80 00       	push   $0x802707
  8018c9:	53                   	push   %ebx
  8018ca:	e8 ac ee ff ff       	call   80077b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018cf:	8b 46 04             	mov    0x4(%esi),%eax
  8018d2:	2b 06                	sub    (%esi),%eax
  8018d4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018da:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018e1:	00 00 00 
	stat->st_dev = &devpipe;
  8018e4:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018eb:	30 80 00 
	return 0;
}
  8018ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f6:	5b                   	pop    %ebx
  8018f7:	5e                   	pop    %esi
  8018f8:	5d                   	pop    %ebp
  8018f9:	c3                   	ret    

008018fa <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018fa:	55                   	push   %ebp
  8018fb:	89 e5                	mov    %esp,%ebp
  8018fd:	53                   	push   %ebx
  8018fe:	83 ec 0c             	sub    $0xc,%esp
  801901:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801904:	53                   	push   %ebx
  801905:	6a 00                	push   $0x0
  801907:	e8 f7 f2 ff ff       	call   800c03 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80190c:	89 1c 24             	mov    %ebx,(%esp)
  80190f:	e8 9d f7 ff ff       	call   8010b1 <fd2data>
  801914:	83 c4 08             	add    $0x8,%esp
  801917:	50                   	push   %eax
  801918:	6a 00                	push   $0x0
  80191a:	e8 e4 f2 ff ff       	call   800c03 <sys_page_unmap>
}
  80191f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801922:	c9                   	leave  
  801923:	c3                   	ret    

00801924 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801924:	55                   	push   %ebp
  801925:	89 e5                	mov    %esp,%ebp
  801927:	57                   	push   %edi
  801928:	56                   	push   %esi
  801929:	53                   	push   %ebx
  80192a:	83 ec 1c             	sub    $0x1c,%esp
  80192d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801930:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801932:	a1 04 40 80 00       	mov    0x804004,%eax
  801937:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80193a:	83 ec 0c             	sub    $0xc,%esp
  80193d:	ff 75 e0             	pushl  -0x20(%ebp)
  801940:	e8 35 06 00 00       	call   801f7a <pageref>
  801945:	89 c3                	mov    %eax,%ebx
  801947:	89 3c 24             	mov    %edi,(%esp)
  80194a:	e8 2b 06 00 00       	call   801f7a <pageref>
  80194f:	83 c4 10             	add    $0x10,%esp
  801952:	39 c3                	cmp    %eax,%ebx
  801954:	0f 94 c1             	sete   %cl
  801957:	0f b6 c9             	movzbl %cl,%ecx
  80195a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80195d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801963:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  801966:	39 ce                	cmp    %ecx,%esi
  801968:	74 1b                	je     801985 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80196a:	39 c3                	cmp    %eax,%ebx
  80196c:	75 c4                	jne    801932 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80196e:	8b 42 64             	mov    0x64(%edx),%eax
  801971:	ff 75 e4             	pushl  -0x1c(%ebp)
  801974:	50                   	push   %eax
  801975:	56                   	push   %esi
  801976:	68 0e 27 80 00       	push   $0x80270e
  80197b:	e8 76 e8 ff ff       	call   8001f6 <cprintf>
  801980:	83 c4 10             	add    $0x10,%esp
  801983:	eb ad                	jmp    801932 <_pipeisclosed+0xe>
	}
}
  801985:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801988:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80198b:	5b                   	pop    %ebx
  80198c:	5e                   	pop    %esi
  80198d:	5f                   	pop    %edi
  80198e:	5d                   	pop    %ebp
  80198f:	c3                   	ret    

00801990 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	57                   	push   %edi
  801994:	56                   	push   %esi
  801995:	53                   	push   %ebx
  801996:	83 ec 28             	sub    $0x28,%esp
  801999:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80199c:	56                   	push   %esi
  80199d:	e8 0f f7 ff ff       	call   8010b1 <fd2data>
  8019a2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019a4:	83 c4 10             	add    $0x10,%esp
  8019a7:	bf 00 00 00 00       	mov    $0x0,%edi
  8019ac:	eb 4b                	jmp    8019f9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019ae:	89 da                	mov    %ebx,%edx
  8019b0:	89 f0                	mov    %esi,%eax
  8019b2:	e8 6d ff ff ff       	call   801924 <_pipeisclosed>
  8019b7:	85 c0                	test   %eax,%eax
  8019b9:	75 48                	jne    801a03 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019bb:	e8 9f f1 ff ff       	call   800b5f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019c0:	8b 43 04             	mov    0x4(%ebx),%eax
  8019c3:	8b 0b                	mov    (%ebx),%ecx
  8019c5:	8d 51 20             	lea    0x20(%ecx),%edx
  8019c8:	39 d0                	cmp    %edx,%eax
  8019ca:	73 e2                	jae    8019ae <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019cf:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019d3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019d6:	89 c2                	mov    %eax,%edx
  8019d8:	c1 fa 1f             	sar    $0x1f,%edx
  8019db:	89 d1                	mov    %edx,%ecx
  8019dd:	c1 e9 1b             	shr    $0x1b,%ecx
  8019e0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019e3:	83 e2 1f             	and    $0x1f,%edx
  8019e6:	29 ca                	sub    %ecx,%edx
  8019e8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019ec:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019f0:	83 c0 01             	add    $0x1,%eax
  8019f3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019f6:	83 c7 01             	add    $0x1,%edi
  8019f9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019fc:	75 c2                	jne    8019c0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019fe:	8b 45 10             	mov    0x10(%ebp),%eax
  801a01:	eb 05                	jmp    801a08 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a03:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a0b:	5b                   	pop    %ebx
  801a0c:	5e                   	pop    %esi
  801a0d:	5f                   	pop    %edi
  801a0e:	5d                   	pop    %ebp
  801a0f:	c3                   	ret    

00801a10 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	57                   	push   %edi
  801a14:	56                   	push   %esi
  801a15:	53                   	push   %ebx
  801a16:	83 ec 18             	sub    $0x18,%esp
  801a19:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a1c:	57                   	push   %edi
  801a1d:	e8 8f f6 ff ff       	call   8010b1 <fd2data>
  801a22:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a24:	83 c4 10             	add    $0x10,%esp
  801a27:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a2c:	eb 3d                	jmp    801a6b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a2e:	85 db                	test   %ebx,%ebx
  801a30:	74 04                	je     801a36 <devpipe_read+0x26>
				return i;
  801a32:	89 d8                	mov    %ebx,%eax
  801a34:	eb 44                	jmp    801a7a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a36:	89 f2                	mov    %esi,%edx
  801a38:	89 f8                	mov    %edi,%eax
  801a3a:	e8 e5 fe ff ff       	call   801924 <_pipeisclosed>
  801a3f:	85 c0                	test   %eax,%eax
  801a41:	75 32                	jne    801a75 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a43:	e8 17 f1 ff ff       	call   800b5f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a48:	8b 06                	mov    (%esi),%eax
  801a4a:	3b 46 04             	cmp    0x4(%esi),%eax
  801a4d:	74 df                	je     801a2e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a4f:	99                   	cltd   
  801a50:	c1 ea 1b             	shr    $0x1b,%edx
  801a53:	01 d0                	add    %edx,%eax
  801a55:	83 e0 1f             	and    $0x1f,%eax
  801a58:	29 d0                	sub    %edx,%eax
  801a5a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a62:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a65:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a68:	83 c3 01             	add    $0x1,%ebx
  801a6b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a6e:	75 d8                	jne    801a48 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a70:	8b 45 10             	mov    0x10(%ebp),%eax
  801a73:	eb 05                	jmp    801a7a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a75:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a7d:	5b                   	pop    %ebx
  801a7e:	5e                   	pop    %esi
  801a7f:	5f                   	pop    %edi
  801a80:	5d                   	pop    %ebp
  801a81:	c3                   	ret    

00801a82 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	56                   	push   %esi
  801a86:	53                   	push   %ebx
  801a87:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a8d:	50                   	push   %eax
  801a8e:	e8 35 f6 ff ff       	call   8010c8 <fd_alloc>
  801a93:	83 c4 10             	add    $0x10,%esp
  801a96:	89 c2                	mov    %eax,%edx
  801a98:	85 c0                	test   %eax,%eax
  801a9a:	0f 88 2c 01 00 00    	js     801bcc <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aa0:	83 ec 04             	sub    $0x4,%esp
  801aa3:	68 07 04 00 00       	push   $0x407
  801aa8:	ff 75 f4             	pushl  -0xc(%ebp)
  801aab:	6a 00                	push   $0x0
  801aad:	e8 cc f0 ff ff       	call   800b7e <sys_page_alloc>
  801ab2:	83 c4 10             	add    $0x10,%esp
  801ab5:	89 c2                	mov    %eax,%edx
  801ab7:	85 c0                	test   %eax,%eax
  801ab9:	0f 88 0d 01 00 00    	js     801bcc <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801abf:	83 ec 0c             	sub    $0xc,%esp
  801ac2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ac5:	50                   	push   %eax
  801ac6:	e8 fd f5 ff ff       	call   8010c8 <fd_alloc>
  801acb:	89 c3                	mov    %eax,%ebx
  801acd:	83 c4 10             	add    $0x10,%esp
  801ad0:	85 c0                	test   %eax,%eax
  801ad2:	0f 88 e2 00 00 00    	js     801bba <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ad8:	83 ec 04             	sub    $0x4,%esp
  801adb:	68 07 04 00 00       	push   $0x407
  801ae0:	ff 75 f0             	pushl  -0x10(%ebp)
  801ae3:	6a 00                	push   $0x0
  801ae5:	e8 94 f0 ff ff       	call   800b7e <sys_page_alloc>
  801aea:	89 c3                	mov    %eax,%ebx
  801aec:	83 c4 10             	add    $0x10,%esp
  801aef:	85 c0                	test   %eax,%eax
  801af1:	0f 88 c3 00 00 00    	js     801bba <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801af7:	83 ec 0c             	sub    $0xc,%esp
  801afa:	ff 75 f4             	pushl  -0xc(%ebp)
  801afd:	e8 af f5 ff ff       	call   8010b1 <fd2data>
  801b02:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b04:	83 c4 0c             	add    $0xc,%esp
  801b07:	68 07 04 00 00       	push   $0x407
  801b0c:	50                   	push   %eax
  801b0d:	6a 00                	push   $0x0
  801b0f:	e8 6a f0 ff ff       	call   800b7e <sys_page_alloc>
  801b14:	89 c3                	mov    %eax,%ebx
  801b16:	83 c4 10             	add    $0x10,%esp
  801b19:	85 c0                	test   %eax,%eax
  801b1b:	0f 88 89 00 00 00    	js     801baa <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b21:	83 ec 0c             	sub    $0xc,%esp
  801b24:	ff 75 f0             	pushl  -0x10(%ebp)
  801b27:	e8 85 f5 ff ff       	call   8010b1 <fd2data>
  801b2c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b33:	50                   	push   %eax
  801b34:	6a 00                	push   $0x0
  801b36:	56                   	push   %esi
  801b37:	6a 00                	push   $0x0
  801b39:	e8 83 f0 ff ff       	call   800bc1 <sys_page_map>
  801b3e:	89 c3                	mov    %eax,%ebx
  801b40:	83 c4 20             	add    $0x20,%esp
  801b43:	85 c0                	test   %eax,%eax
  801b45:	78 55                	js     801b9c <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b47:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b50:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b55:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b5c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b62:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b65:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b67:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b6a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b71:	83 ec 0c             	sub    $0xc,%esp
  801b74:	ff 75 f4             	pushl  -0xc(%ebp)
  801b77:	e8 25 f5 ff ff       	call   8010a1 <fd2num>
  801b7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b7f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b81:	83 c4 04             	add    $0x4,%esp
  801b84:	ff 75 f0             	pushl  -0x10(%ebp)
  801b87:	e8 15 f5 ff ff       	call   8010a1 <fd2num>
  801b8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b8f:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801b92:	83 c4 10             	add    $0x10,%esp
  801b95:	ba 00 00 00 00       	mov    $0x0,%edx
  801b9a:	eb 30                	jmp    801bcc <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b9c:	83 ec 08             	sub    $0x8,%esp
  801b9f:	56                   	push   %esi
  801ba0:	6a 00                	push   $0x0
  801ba2:	e8 5c f0 ff ff       	call   800c03 <sys_page_unmap>
  801ba7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801baa:	83 ec 08             	sub    $0x8,%esp
  801bad:	ff 75 f0             	pushl  -0x10(%ebp)
  801bb0:	6a 00                	push   $0x0
  801bb2:	e8 4c f0 ff ff       	call   800c03 <sys_page_unmap>
  801bb7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801bba:	83 ec 08             	sub    $0x8,%esp
  801bbd:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc0:	6a 00                	push   $0x0
  801bc2:	e8 3c f0 ff ff       	call   800c03 <sys_page_unmap>
  801bc7:	83 c4 10             	add    $0x10,%esp
  801bca:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801bcc:	89 d0                	mov    %edx,%eax
  801bce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bd1:	5b                   	pop    %ebx
  801bd2:	5e                   	pop    %esi
  801bd3:	5d                   	pop    %ebp
  801bd4:	c3                   	ret    

00801bd5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801bd5:	55                   	push   %ebp
  801bd6:	89 e5                	mov    %esp,%ebp
  801bd8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bdb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bde:	50                   	push   %eax
  801bdf:	ff 75 08             	pushl  0x8(%ebp)
  801be2:	e8 30 f5 ff ff       	call   801117 <fd_lookup>
  801be7:	83 c4 10             	add    $0x10,%esp
  801bea:	85 c0                	test   %eax,%eax
  801bec:	78 18                	js     801c06 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bee:	83 ec 0c             	sub    $0xc,%esp
  801bf1:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf4:	e8 b8 f4 ff ff       	call   8010b1 <fd2data>
	return _pipeisclosed(fd, p);
  801bf9:	89 c2                	mov    %eax,%edx
  801bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfe:	e8 21 fd ff ff       	call   801924 <_pipeisclosed>
  801c03:	83 c4 10             	add    $0x10,%esp
}
  801c06:	c9                   	leave  
  801c07:	c3                   	ret    

00801c08 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c08:	55                   	push   %ebp
  801c09:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c0b:	b8 00 00 00 00       	mov    $0x0,%eax
  801c10:	5d                   	pop    %ebp
  801c11:	c3                   	ret    

00801c12 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c12:	55                   	push   %ebp
  801c13:	89 e5                	mov    %esp,%ebp
  801c15:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c18:	68 26 27 80 00       	push   $0x802726
  801c1d:	ff 75 0c             	pushl  0xc(%ebp)
  801c20:	e8 56 eb ff ff       	call   80077b <strcpy>
	return 0;
}
  801c25:	b8 00 00 00 00       	mov    $0x0,%eax
  801c2a:	c9                   	leave  
  801c2b:	c3                   	ret    

00801c2c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c2c:	55                   	push   %ebp
  801c2d:	89 e5                	mov    %esp,%ebp
  801c2f:	57                   	push   %edi
  801c30:	56                   	push   %esi
  801c31:	53                   	push   %ebx
  801c32:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c38:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c3d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c43:	eb 2d                	jmp    801c72 <devcons_write+0x46>
		m = n - tot;
  801c45:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c48:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c4a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c4d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c52:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c55:	83 ec 04             	sub    $0x4,%esp
  801c58:	53                   	push   %ebx
  801c59:	03 45 0c             	add    0xc(%ebp),%eax
  801c5c:	50                   	push   %eax
  801c5d:	57                   	push   %edi
  801c5e:	e8 aa ec ff ff       	call   80090d <memmove>
		sys_cputs(buf, m);
  801c63:	83 c4 08             	add    $0x8,%esp
  801c66:	53                   	push   %ebx
  801c67:	57                   	push   %edi
  801c68:	e8 55 ee ff ff       	call   800ac2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c6d:	01 de                	add    %ebx,%esi
  801c6f:	83 c4 10             	add    $0x10,%esp
  801c72:	89 f0                	mov    %esi,%eax
  801c74:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c77:	72 cc                	jb     801c45 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c7c:	5b                   	pop    %ebx
  801c7d:	5e                   	pop    %esi
  801c7e:	5f                   	pop    %edi
  801c7f:	5d                   	pop    %ebp
  801c80:	c3                   	ret    

00801c81 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c81:	55                   	push   %ebp
  801c82:	89 e5                	mov    %esp,%ebp
  801c84:	83 ec 08             	sub    $0x8,%esp
  801c87:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c8c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c90:	74 2a                	je     801cbc <devcons_read+0x3b>
  801c92:	eb 05                	jmp    801c99 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c94:	e8 c6 ee ff ff       	call   800b5f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c99:	e8 42 ee ff ff       	call   800ae0 <sys_cgetc>
  801c9e:	85 c0                	test   %eax,%eax
  801ca0:	74 f2                	je     801c94 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ca2:	85 c0                	test   %eax,%eax
  801ca4:	78 16                	js     801cbc <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ca6:	83 f8 04             	cmp    $0x4,%eax
  801ca9:	74 0c                	je     801cb7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801cab:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cae:	88 02                	mov    %al,(%edx)
	return 1;
  801cb0:	b8 01 00 00 00       	mov    $0x1,%eax
  801cb5:	eb 05                	jmp    801cbc <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801cb7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801cbc:	c9                   	leave  
  801cbd:	c3                   	ret    

00801cbe <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801cbe:	55                   	push   %ebp
  801cbf:	89 e5                	mov    %esp,%ebp
  801cc1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cc4:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cca:	6a 01                	push   $0x1
  801ccc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ccf:	50                   	push   %eax
  801cd0:	e8 ed ed ff ff       	call   800ac2 <sys_cputs>
}
  801cd5:	83 c4 10             	add    $0x10,%esp
  801cd8:	c9                   	leave  
  801cd9:	c3                   	ret    

00801cda <getchar>:

int
getchar(void)
{
  801cda:	55                   	push   %ebp
  801cdb:	89 e5                	mov    %esp,%ebp
  801cdd:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ce0:	6a 01                	push   $0x1
  801ce2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ce5:	50                   	push   %eax
  801ce6:	6a 00                	push   $0x0
  801ce8:	e8 90 f6 ff ff       	call   80137d <read>
	if (r < 0)
  801ced:	83 c4 10             	add    $0x10,%esp
  801cf0:	85 c0                	test   %eax,%eax
  801cf2:	78 0f                	js     801d03 <getchar+0x29>
		return r;
	if (r < 1)
  801cf4:	85 c0                	test   %eax,%eax
  801cf6:	7e 06                	jle    801cfe <getchar+0x24>
		return -E_EOF;
	return c;
  801cf8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cfc:	eb 05                	jmp    801d03 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801cfe:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d03:	c9                   	leave  
  801d04:	c3                   	ret    

00801d05 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d05:	55                   	push   %ebp
  801d06:	89 e5                	mov    %esp,%ebp
  801d08:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d0b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d0e:	50                   	push   %eax
  801d0f:	ff 75 08             	pushl  0x8(%ebp)
  801d12:	e8 00 f4 ff ff       	call   801117 <fd_lookup>
  801d17:	83 c4 10             	add    $0x10,%esp
  801d1a:	85 c0                	test   %eax,%eax
  801d1c:	78 11                	js     801d2f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d21:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d27:	39 10                	cmp    %edx,(%eax)
  801d29:	0f 94 c0             	sete   %al
  801d2c:	0f b6 c0             	movzbl %al,%eax
}
  801d2f:	c9                   	leave  
  801d30:	c3                   	ret    

00801d31 <opencons>:

int
opencons(void)
{
  801d31:	55                   	push   %ebp
  801d32:	89 e5                	mov    %esp,%ebp
  801d34:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d37:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d3a:	50                   	push   %eax
  801d3b:	e8 88 f3 ff ff       	call   8010c8 <fd_alloc>
  801d40:	83 c4 10             	add    $0x10,%esp
		return r;
  801d43:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d45:	85 c0                	test   %eax,%eax
  801d47:	78 3e                	js     801d87 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d49:	83 ec 04             	sub    $0x4,%esp
  801d4c:	68 07 04 00 00       	push   $0x407
  801d51:	ff 75 f4             	pushl  -0xc(%ebp)
  801d54:	6a 00                	push   $0x0
  801d56:	e8 23 ee ff ff       	call   800b7e <sys_page_alloc>
  801d5b:	83 c4 10             	add    $0x10,%esp
		return r;
  801d5e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d60:	85 c0                	test   %eax,%eax
  801d62:	78 23                	js     801d87 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d64:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d6d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d72:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d79:	83 ec 0c             	sub    $0xc,%esp
  801d7c:	50                   	push   %eax
  801d7d:	e8 1f f3 ff ff       	call   8010a1 <fd2num>
  801d82:	89 c2                	mov    %eax,%edx
  801d84:	83 c4 10             	add    $0x10,%esp
}
  801d87:	89 d0                	mov    %edx,%eax
  801d89:	c9                   	leave  
  801d8a:	c3                   	ret    

00801d8b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d8b:	55                   	push   %ebp
  801d8c:	89 e5                	mov    %esp,%ebp
  801d8e:	56                   	push   %esi
  801d8f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d90:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d93:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d99:	e8 a2 ed ff ff       	call   800b40 <sys_getenvid>
  801d9e:	83 ec 0c             	sub    $0xc,%esp
  801da1:	ff 75 0c             	pushl  0xc(%ebp)
  801da4:	ff 75 08             	pushl  0x8(%ebp)
  801da7:	56                   	push   %esi
  801da8:	50                   	push   %eax
  801da9:	68 34 27 80 00       	push   $0x802734
  801dae:	e8 43 e4 ff ff       	call   8001f6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801db3:	83 c4 18             	add    $0x18,%esp
  801db6:	53                   	push   %ebx
  801db7:	ff 75 10             	pushl  0x10(%ebp)
  801dba:	e8 e6 e3 ff ff       	call   8001a5 <vcprintf>
	cprintf("\n");
  801dbf:	c7 04 24 85 22 80 00 	movl   $0x802285,(%esp)
  801dc6:	e8 2b e4 ff ff       	call   8001f6 <cprintf>
  801dcb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801dce:	cc                   	int3   
  801dcf:	eb fd                	jmp    801dce <_panic+0x43>

00801dd1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801dd1:	55                   	push   %ebp
  801dd2:	89 e5                	mov    %esp,%ebp
  801dd4:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801dd7:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801dde:	75 2a                	jne    801e0a <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801de0:	83 ec 04             	sub    $0x4,%esp
  801de3:	6a 07                	push   $0x7
  801de5:	68 00 f0 bf ee       	push   $0xeebff000
  801dea:	6a 00                	push   $0x0
  801dec:	e8 8d ed ff ff       	call   800b7e <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801df1:	83 c4 10             	add    $0x10,%esp
  801df4:	85 c0                	test   %eax,%eax
  801df6:	79 12                	jns    801e0a <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801df8:	50                   	push   %eax
  801df9:	68 58 27 80 00       	push   $0x802758
  801dfe:	6a 23                	push   $0x23
  801e00:	68 5c 27 80 00       	push   $0x80275c
  801e05:	e8 81 ff ff ff       	call   801d8b <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0d:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801e12:	83 ec 08             	sub    $0x8,%esp
  801e15:	68 3c 1e 80 00       	push   $0x801e3c
  801e1a:	6a 00                	push   $0x0
  801e1c:	e8 a8 ee ff ff       	call   800cc9 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801e21:	83 c4 10             	add    $0x10,%esp
  801e24:	85 c0                	test   %eax,%eax
  801e26:	79 12                	jns    801e3a <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801e28:	50                   	push   %eax
  801e29:	68 58 27 80 00       	push   $0x802758
  801e2e:	6a 2c                	push   $0x2c
  801e30:	68 5c 27 80 00       	push   $0x80275c
  801e35:	e8 51 ff ff ff       	call   801d8b <_panic>
	}
}
  801e3a:	c9                   	leave  
  801e3b:	c3                   	ret    

00801e3c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e3c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e3d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e42:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e44:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801e47:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801e4b:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801e50:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801e54:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801e56:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801e59:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801e5a:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801e5d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801e5e:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e5f:	c3                   	ret    

00801e60 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e60:	55                   	push   %ebp
  801e61:	89 e5                	mov    %esp,%ebp
  801e63:	56                   	push   %esi
  801e64:	53                   	push   %ebx
  801e65:	8b 75 08             	mov    0x8(%ebp),%esi
  801e68:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e6e:	85 c0                	test   %eax,%eax
  801e70:	75 12                	jne    801e84 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e72:	83 ec 0c             	sub    $0xc,%esp
  801e75:	68 00 00 c0 ee       	push   $0xeec00000
  801e7a:	e8 af ee ff ff       	call   800d2e <sys_ipc_recv>
  801e7f:	83 c4 10             	add    $0x10,%esp
  801e82:	eb 0c                	jmp    801e90 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e84:	83 ec 0c             	sub    $0xc,%esp
  801e87:	50                   	push   %eax
  801e88:	e8 a1 ee ff ff       	call   800d2e <sys_ipc_recv>
  801e8d:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e90:	85 f6                	test   %esi,%esi
  801e92:	0f 95 c1             	setne  %cl
  801e95:	85 db                	test   %ebx,%ebx
  801e97:	0f 95 c2             	setne  %dl
  801e9a:	84 d1                	test   %dl,%cl
  801e9c:	74 09                	je     801ea7 <ipc_recv+0x47>
  801e9e:	89 c2                	mov    %eax,%edx
  801ea0:	c1 ea 1f             	shr    $0x1f,%edx
  801ea3:	84 d2                	test   %dl,%dl
  801ea5:	75 2a                	jne    801ed1 <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801ea7:	85 f6                	test   %esi,%esi
  801ea9:	74 0d                	je     801eb8 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801eab:	a1 04 40 80 00       	mov    0x804004,%eax
  801eb0:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801eb6:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801eb8:	85 db                	test   %ebx,%ebx
  801eba:	74 0d                	je     801ec9 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801ebc:	a1 04 40 80 00       	mov    0x804004,%eax
  801ec1:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  801ec7:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ec9:	a1 04 40 80 00       	mov    0x804004,%eax
  801ece:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  801ed1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ed4:	5b                   	pop    %ebx
  801ed5:	5e                   	pop    %esi
  801ed6:	5d                   	pop    %ebp
  801ed7:	c3                   	ret    

00801ed8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ed8:	55                   	push   %ebp
  801ed9:	89 e5                	mov    %esp,%ebp
  801edb:	57                   	push   %edi
  801edc:	56                   	push   %esi
  801edd:	53                   	push   %ebx
  801ede:	83 ec 0c             	sub    $0xc,%esp
  801ee1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ee4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ee7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801eea:	85 db                	test   %ebx,%ebx
  801eec:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ef1:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ef4:	ff 75 14             	pushl  0x14(%ebp)
  801ef7:	53                   	push   %ebx
  801ef8:	56                   	push   %esi
  801ef9:	57                   	push   %edi
  801efa:	e8 0c ee ff ff       	call   800d0b <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801eff:	89 c2                	mov    %eax,%edx
  801f01:	c1 ea 1f             	shr    $0x1f,%edx
  801f04:	83 c4 10             	add    $0x10,%esp
  801f07:	84 d2                	test   %dl,%dl
  801f09:	74 17                	je     801f22 <ipc_send+0x4a>
  801f0b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f0e:	74 12                	je     801f22 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801f10:	50                   	push   %eax
  801f11:	68 6a 27 80 00       	push   $0x80276a
  801f16:	6a 47                	push   $0x47
  801f18:	68 78 27 80 00       	push   $0x802778
  801f1d:	e8 69 fe ff ff       	call   801d8b <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801f22:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f25:	75 07                	jne    801f2e <ipc_send+0x56>
			sys_yield();
  801f27:	e8 33 ec ff ff       	call   800b5f <sys_yield>
  801f2c:	eb c6                	jmp    801ef4 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801f2e:	85 c0                	test   %eax,%eax
  801f30:	75 c2                	jne    801ef4 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801f32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f35:	5b                   	pop    %ebx
  801f36:	5e                   	pop    %esi
  801f37:	5f                   	pop    %edi
  801f38:	5d                   	pop    %ebp
  801f39:	c3                   	ret    

00801f3a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f3a:	55                   	push   %ebp
  801f3b:	89 e5                	mov    %esp,%ebp
  801f3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f40:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f45:	89 c2                	mov    %eax,%edx
  801f47:	c1 e2 07             	shl    $0x7,%edx
  801f4a:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  801f51:	8b 52 5c             	mov    0x5c(%edx),%edx
  801f54:	39 ca                	cmp    %ecx,%edx
  801f56:	75 11                	jne    801f69 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801f58:	89 c2                	mov    %eax,%edx
  801f5a:	c1 e2 07             	shl    $0x7,%edx
  801f5d:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801f64:	8b 40 54             	mov    0x54(%eax),%eax
  801f67:	eb 0f                	jmp    801f78 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f69:	83 c0 01             	add    $0x1,%eax
  801f6c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f71:	75 d2                	jne    801f45 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f78:	5d                   	pop    %ebp
  801f79:	c3                   	ret    

00801f7a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f7a:	55                   	push   %ebp
  801f7b:	89 e5                	mov    %esp,%ebp
  801f7d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f80:	89 d0                	mov    %edx,%eax
  801f82:	c1 e8 16             	shr    $0x16,%eax
  801f85:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f8c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f91:	f6 c1 01             	test   $0x1,%cl
  801f94:	74 1d                	je     801fb3 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f96:	c1 ea 0c             	shr    $0xc,%edx
  801f99:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fa0:	f6 c2 01             	test   $0x1,%dl
  801fa3:	74 0e                	je     801fb3 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fa5:	c1 ea 0c             	shr    $0xc,%edx
  801fa8:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801faf:	ef 
  801fb0:	0f b7 c0             	movzwl %ax,%eax
}
  801fb3:	5d                   	pop    %ebp
  801fb4:	c3                   	ret    
  801fb5:	66 90                	xchg   %ax,%ax
  801fb7:	66 90                	xchg   %ax,%ax
  801fb9:	66 90                	xchg   %ax,%ax
  801fbb:	66 90                	xchg   %ax,%ax
  801fbd:	66 90                	xchg   %ax,%ax
  801fbf:	90                   	nop

00801fc0 <__udivdi3>:
  801fc0:	55                   	push   %ebp
  801fc1:	57                   	push   %edi
  801fc2:	56                   	push   %esi
  801fc3:	53                   	push   %ebx
  801fc4:	83 ec 1c             	sub    $0x1c,%esp
  801fc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fd7:	85 f6                	test   %esi,%esi
  801fd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fdd:	89 ca                	mov    %ecx,%edx
  801fdf:	89 f8                	mov    %edi,%eax
  801fe1:	75 3d                	jne    802020 <__udivdi3+0x60>
  801fe3:	39 cf                	cmp    %ecx,%edi
  801fe5:	0f 87 c5 00 00 00    	ja     8020b0 <__udivdi3+0xf0>
  801feb:	85 ff                	test   %edi,%edi
  801fed:	89 fd                	mov    %edi,%ebp
  801fef:	75 0b                	jne    801ffc <__udivdi3+0x3c>
  801ff1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ff6:	31 d2                	xor    %edx,%edx
  801ff8:	f7 f7                	div    %edi
  801ffa:	89 c5                	mov    %eax,%ebp
  801ffc:	89 c8                	mov    %ecx,%eax
  801ffe:	31 d2                	xor    %edx,%edx
  802000:	f7 f5                	div    %ebp
  802002:	89 c1                	mov    %eax,%ecx
  802004:	89 d8                	mov    %ebx,%eax
  802006:	89 cf                	mov    %ecx,%edi
  802008:	f7 f5                	div    %ebp
  80200a:	89 c3                	mov    %eax,%ebx
  80200c:	89 d8                	mov    %ebx,%eax
  80200e:	89 fa                	mov    %edi,%edx
  802010:	83 c4 1c             	add    $0x1c,%esp
  802013:	5b                   	pop    %ebx
  802014:	5e                   	pop    %esi
  802015:	5f                   	pop    %edi
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    
  802018:	90                   	nop
  802019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802020:	39 ce                	cmp    %ecx,%esi
  802022:	77 74                	ja     802098 <__udivdi3+0xd8>
  802024:	0f bd fe             	bsr    %esi,%edi
  802027:	83 f7 1f             	xor    $0x1f,%edi
  80202a:	0f 84 98 00 00 00    	je     8020c8 <__udivdi3+0x108>
  802030:	bb 20 00 00 00       	mov    $0x20,%ebx
  802035:	89 f9                	mov    %edi,%ecx
  802037:	89 c5                	mov    %eax,%ebp
  802039:	29 fb                	sub    %edi,%ebx
  80203b:	d3 e6                	shl    %cl,%esi
  80203d:	89 d9                	mov    %ebx,%ecx
  80203f:	d3 ed                	shr    %cl,%ebp
  802041:	89 f9                	mov    %edi,%ecx
  802043:	d3 e0                	shl    %cl,%eax
  802045:	09 ee                	or     %ebp,%esi
  802047:	89 d9                	mov    %ebx,%ecx
  802049:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80204d:	89 d5                	mov    %edx,%ebp
  80204f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802053:	d3 ed                	shr    %cl,%ebp
  802055:	89 f9                	mov    %edi,%ecx
  802057:	d3 e2                	shl    %cl,%edx
  802059:	89 d9                	mov    %ebx,%ecx
  80205b:	d3 e8                	shr    %cl,%eax
  80205d:	09 c2                	or     %eax,%edx
  80205f:	89 d0                	mov    %edx,%eax
  802061:	89 ea                	mov    %ebp,%edx
  802063:	f7 f6                	div    %esi
  802065:	89 d5                	mov    %edx,%ebp
  802067:	89 c3                	mov    %eax,%ebx
  802069:	f7 64 24 0c          	mull   0xc(%esp)
  80206d:	39 d5                	cmp    %edx,%ebp
  80206f:	72 10                	jb     802081 <__udivdi3+0xc1>
  802071:	8b 74 24 08          	mov    0x8(%esp),%esi
  802075:	89 f9                	mov    %edi,%ecx
  802077:	d3 e6                	shl    %cl,%esi
  802079:	39 c6                	cmp    %eax,%esi
  80207b:	73 07                	jae    802084 <__udivdi3+0xc4>
  80207d:	39 d5                	cmp    %edx,%ebp
  80207f:	75 03                	jne    802084 <__udivdi3+0xc4>
  802081:	83 eb 01             	sub    $0x1,%ebx
  802084:	31 ff                	xor    %edi,%edi
  802086:	89 d8                	mov    %ebx,%eax
  802088:	89 fa                	mov    %edi,%edx
  80208a:	83 c4 1c             	add    $0x1c,%esp
  80208d:	5b                   	pop    %ebx
  80208e:	5e                   	pop    %esi
  80208f:	5f                   	pop    %edi
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    
  802092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802098:	31 ff                	xor    %edi,%edi
  80209a:	31 db                	xor    %ebx,%ebx
  80209c:	89 d8                	mov    %ebx,%eax
  80209e:	89 fa                	mov    %edi,%edx
  8020a0:	83 c4 1c             	add    $0x1c,%esp
  8020a3:	5b                   	pop    %ebx
  8020a4:	5e                   	pop    %esi
  8020a5:	5f                   	pop    %edi
  8020a6:	5d                   	pop    %ebp
  8020a7:	c3                   	ret    
  8020a8:	90                   	nop
  8020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	89 d8                	mov    %ebx,%eax
  8020b2:	f7 f7                	div    %edi
  8020b4:	31 ff                	xor    %edi,%edi
  8020b6:	89 c3                	mov    %eax,%ebx
  8020b8:	89 d8                	mov    %ebx,%eax
  8020ba:	89 fa                	mov    %edi,%edx
  8020bc:	83 c4 1c             	add    $0x1c,%esp
  8020bf:	5b                   	pop    %ebx
  8020c0:	5e                   	pop    %esi
  8020c1:	5f                   	pop    %edi
  8020c2:	5d                   	pop    %ebp
  8020c3:	c3                   	ret    
  8020c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020c8:	39 ce                	cmp    %ecx,%esi
  8020ca:	72 0c                	jb     8020d8 <__udivdi3+0x118>
  8020cc:	31 db                	xor    %ebx,%ebx
  8020ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020d2:	0f 87 34 ff ff ff    	ja     80200c <__udivdi3+0x4c>
  8020d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020dd:	e9 2a ff ff ff       	jmp    80200c <__udivdi3+0x4c>
  8020e2:	66 90                	xchg   %ax,%ax
  8020e4:	66 90                	xchg   %ax,%ax
  8020e6:	66 90                	xchg   %ax,%ax
  8020e8:	66 90                	xchg   %ax,%ax
  8020ea:	66 90                	xchg   %ax,%ax
  8020ec:	66 90                	xchg   %ax,%ax
  8020ee:	66 90                	xchg   %ax,%ax

008020f0 <__umoddi3>:
  8020f0:	55                   	push   %ebp
  8020f1:	57                   	push   %edi
  8020f2:	56                   	push   %esi
  8020f3:	53                   	push   %ebx
  8020f4:	83 ec 1c             	sub    $0x1c,%esp
  8020f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802103:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802107:	85 d2                	test   %edx,%edx
  802109:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80210d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802111:	89 f3                	mov    %esi,%ebx
  802113:	89 3c 24             	mov    %edi,(%esp)
  802116:	89 74 24 04          	mov    %esi,0x4(%esp)
  80211a:	75 1c                	jne    802138 <__umoddi3+0x48>
  80211c:	39 f7                	cmp    %esi,%edi
  80211e:	76 50                	jbe    802170 <__umoddi3+0x80>
  802120:	89 c8                	mov    %ecx,%eax
  802122:	89 f2                	mov    %esi,%edx
  802124:	f7 f7                	div    %edi
  802126:	89 d0                	mov    %edx,%eax
  802128:	31 d2                	xor    %edx,%edx
  80212a:	83 c4 1c             	add    $0x1c,%esp
  80212d:	5b                   	pop    %ebx
  80212e:	5e                   	pop    %esi
  80212f:	5f                   	pop    %edi
  802130:	5d                   	pop    %ebp
  802131:	c3                   	ret    
  802132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802138:	39 f2                	cmp    %esi,%edx
  80213a:	89 d0                	mov    %edx,%eax
  80213c:	77 52                	ja     802190 <__umoddi3+0xa0>
  80213e:	0f bd ea             	bsr    %edx,%ebp
  802141:	83 f5 1f             	xor    $0x1f,%ebp
  802144:	75 5a                	jne    8021a0 <__umoddi3+0xb0>
  802146:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80214a:	0f 82 e0 00 00 00    	jb     802230 <__umoddi3+0x140>
  802150:	39 0c 24             	cmp    %ecx,(%esp)
  802153:	0f 86 d7 00 00 00    	jbe    802230 <__umoddi3+0x140>
  802159:	8b 44 24 08          	mov    0x8(%esp),%eax
  80215d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802161:	83 c4 1c             	add    $0x1c,%esp
  802164:	5b                   	pop    %ebx
  802165:	5e                   	pop    %esi
  802166:	5f                   	pop    %edi
  802167:	5d                   	pop    %ebp
  802168:	c3                   	ret    
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	85 ff                	test   %edi,%edi
  802172:	89 fd                	mov    %edi,%ebp
  802174:	75 0b                	jne    802181 <__umoddi3+0x91>
  802176:	b8 01 00 00 00       	mov    $0x1,%eax
  80217b:	31 d2                	xor    %edx,%edx
  80217d:	f7 f7                	div    %edi
  80217f:	89 c5                	mov    %eax,%ebp
  802181:	89 f0                	mov    %esi,%eax
  802183:	31 d2                	xor    %edx,%edx
  802185:	f7 f5                	div    %ebp
  802187:	89 c8                	mov    %ecx,%eax
  802189:	f7 f5                	div    %ebp
  80218b:	89 d0                	mov    %edx,%eax
  80218d:	eb 99                	jmp    802128 <__umoddi3+0x38>
  80218f:	90                   	nop
  802190:	89 c8                	mov    %ecx,%eax
  802192:	89 f2                	mov    %esi,%edx
  802194:	83 c4 1c             	add    $0x1c,%esp
  802197:	5b                   	pop    %ebx
  802198:	5e                   	pop    %esi
  802199:	5f                   	pop    %edi
  80219a:	5d                   	pop    %ebp
  80219b:	c3                   	ret    
  80219c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	8b 34 24             	mov    (%esp),%esi
  8021a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021a8:	89 e9                	mov    %ebp,%ecx
  8021aa:	29 ef                	sub    %ebp,%edi
  8021ac:	d3 e0                	shl    %cl,%eax
  8021ae:	89 f9                	mov    %edi,%ecx
  8021b0:	89 f2                	mov    %esi,%edx
  8021b2:	d3 ea                	shr    %cl,%edx
  8021b4:	89 e9                	mov    %ebp,%ecx
  8021b6:	09 c2                	or     %eax,%edx
  8021b8:	89 d8                	mov    %ebx,%eax
  8021ba:	89 14 24             	mov    %edx,(%esp)
  8021bd:	89 f2                	mov    %esi,%edx
  8021bf:	d3 e2                	shl    %cl,%edx
  8021c1:	89 f9                	mov    %edi,%ecx
  8021c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021cb:	d3 e8                	shr    %cl,%eax
  8021cd:	89 e9                	mov    %ebp,%ecx
  8021cf:	89 c6                	mov    %eax,%esi
  8021d1:	d3 e3                	shl    %cl,%ebx
  8021d3:	89 f9                	mov    %edi,%ecx
  8021d5:	89 d0                	mov    %edx,%eax
  8021d7:	d3 e8                	shr    %cl,%eax
  8021d9:	89 e9                	mov    %ebp,%ecx
  8021db:	09 d8                	or     %ebx,%eax
  8021dd:	89 d3                	mov    %edx,%ebx
  8021df:	89 f2                	mov    %esi,%edx
  8021e1:	f7 34 24             	divl   (%esp)
  8021e4:	89 d6                	mov    %edx,%esi
  8021e6:	d3 e3                	shl    %cl,%ebx
  8021e8:	f7 64 24 04          	mull   0x4(%esp)
  8021ec:	39 d6                	cmp    %edx,%esi
  8021ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021f2:	89 d1                	mov    %edx,%ecx
  8021f4:	89 c3                	mov    %eax,%ebx
  8021f6:	72 08                	jb     802200 <__umoddi3+0x110>
  8021f8:	75 11                	jne    80220b <__umoddi3+0x11b>
  8021fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021fe:	73 0b                	jae    80220b <__umoddi3+0x11b>
  802200:	2b 44 24 04          	sub    0x4(%esp),%eax
  802204:	1b 14 24             	sbb    (%esp),%edx
  802207:	89 d1                	mov    %edx,%ecx
  802209:	89 c3                	mov    %eax,%ebx
  80220b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80220f:	29 da                	sub    %ebx,%edx
  802211:	19 ce                	sbb    %ecx,%esi
  802213:	89 f9                	mov    %edi,%ecx
  802215:	89 f0                	mov    %esi,%eax
  802217:	d3 e0                	shl    %cl,%eax
  802219:	89 e9                	mov    %ebp,%ecx
  80221b:	d3 ea                	shr    %cl,%edx
  80221d:	89 e9                	mov    %ebp,%ecx
  80221f:	d3 ee                	shr    %cl,%esi
  802221:	09 d0                	or     %edx,%eax
  802223:	89 f2                	mov    %esi,%edx
  802225:	83 c4 1c             	add    $0x1c,%esp
  802228:	5b                   	pop    %ebx
  802229:	5e                   	pop    %esi
  80222a:	5f                   	pop    %edi
  80222b:	5d                   	pop    %ebp
  80222c:	c3                   	ret    
  80222d:	8d 76 00             	lea    0x0(%esi),%esi
  802230:	29 f9                	sub    %edi,%ecx
  802232:	19 d6                	sbb    %edx,%esi
  802234:	89 74 24 04          	mov    %esi,0x4(%esp)
  802238:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80223c:	e9 18 ff ff ff       	jmp    802159 <__umoddi3+0x69>
